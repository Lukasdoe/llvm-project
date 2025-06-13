//==-- WebAssemblyTargetStreamer.cpp - WebAssembly Target Streamer Methods --=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file defines WebAssembly-specific target streamer classes.
/// These are for implementing support for target-specific assembly directives.
///
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/WebAssemblyTargetStreamer.h"
#include "MCTargetDesc/WebAssemblyMCTypeUtilities.h"
#include "WebAssemblyFixupKinds.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCSectionWasm.h"
#include "llvm/MC/MCSymbolWasm.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/FormattedStream.h"

using namespace llvm;

WebAssemblyTargetStreamer::WebAssemblyTargetStreamer(MCStreamer &S)
    : MCTargetStreamer(S) {}

void WebAssemblyTargetStreamer::emitValueType(wasm::ValType Type) {
  Streamer.emitIntValue(uint8_t(Type), 1);
}

WebAssemblyTargetAsmStreamer::WebAssemblyTargetAsmStreamer(
    MCStreamer &S, formatted_raw_ostream &OS)
    : WebAssemblyTargetStreamer(S), OS(OS) {}

WebAssemblyTargetWasmStreamer::WebAssemblyTargetWasmStreamer(MCStreamer &S)
    : WebAssemblyTargetStreamer(S) {}

static void printTypes(formatted_raw_ostream &OS,
                       ArrayRef<wasm::ValType> Types) {
  bool First = true;
  for (auto Type : Types) {
    if (First)
      First = false;
    else
      OS << ", ";
    OS << WebAssembly::typeToString(Type);
  }
  OS << '\n';
}

void WebAssemblyTargetAsmStreamer::emitLocal(ArrayRef<wasm::ValType> Types) {
  if (!Types.empty()) {
    OS << "\t.local  \t";
    printTypes(OS, Types);
  }
}

void WebAssemblyTargetAsmStreamer::emitFunctionType(const MCSymbolWasm *Sym) {
  assert(Sym->isFunction());
  OS << "\t.functype\t" << Sym->getName() << " ";
  OS << WebAssembly::signatureToString(Sym->getSignature());
  OS << "\n";
}

void WebAssemblyTargetAsmStreamer::emitGlobalType(const MCSymbolWasm *Sym) {
  assert(Sym->isGlobal());
  OS << "\t.globaltype\t" << Sym->getName() << ", "
     << WebAssembly::typeToString(
            static_cast<wasm::ValType>(Sym->getGlobalType().Type));
  if (!Sym->getGlobalType().Mutable)
    OS << ", immutable";
  OS << '\n';
}

void WebAssemblyTargetAsmStreamer::emitTableType(const MCSymbolWasm *Sym) {
  assert(Sym->isTable());
  const wasm::WasmTableType &Type = Sym->getTableType();
  OS << "\t.tabletype\t" << Sym->getName() << ", "
     << WebAssembly::typeToString(static_cast<wasm::ValType>(Type.ElemType));
  bool HasMaximum = Type.Limits.Flags & wasm::WASM_LIMITS_FLAG_HAS_MAX;
  if (Type.Limits.Minimum != 0 || HasMaximum) {
    OS << ", " << Type.Limits.Minimum;
    if (HasMaximum)
      OS << ", " << Type.Limits.Maximum;
  }
  OS << '\n';
}

void WebAssemblyTargetAsmStreamer::emitTagType(const MCSymbolWasm *Sym) {
  assert(Sym->isTag());
  OS << "\t.tagtype\t" << Sym->getName() << " ";
  OS << WebAssembly::typeListToString(Sym->getSignature()->Params);
  OS << "\n";
}

void WebAssemblyTargetAsmStreamer::emitImportModule(const MCSymbolWasm *Sym,
                                                    StringRef ImportModule) {
  OS << "\t.import_module\t" << Sym->getName() << ", "
                             << ImportModule << '\n';
}

void WebAssemblyTargetAsmStreamer::emitImportName(const MCSymbolWasm *Sym,
                                                  StringRef ImportName) {
  OS << "\t.import_name\t" << Sym->getName() << ", "
                           << ImportName << '\n';
}

void WebAssemblyTargetAsmStreamer::emitExportName(const MCSymbolWasm *Sym,
                                                  StringRef ExportName) {
  OS << "\t.export_name\t" << Sym->getName() << ", "
                           << ExportName << '\n';
}

void WebAssemblyTargetAsmStreamer::emitIndIdx(const MCExpr *Value) {
  OS << "\t.indidx  \t" << *Value << '\n';
}

void WebAssemblyTargetWasmStreamer::emitLocal(ArrayRef<wasm::ValType> Types) {
  SmallVector<std::pair<wasm::ValType, uint32_t>, 4> Grouped;
  for (auto Type : Types) {
    if (Grouped.empty() || Grouped.back().first != Type)
      Grouped.push_back(std::make_pair(Type, 1));
    else
      ++Grouped.back().second;
  }

  Streamer.emitULEB128IntValue(Grouped.size());
  for (auto Pair : Grouped) {
    Streamer.emitULEB128IntValue(Pair.second);
    emitValueType(Pair.first);
  }
}

void WebAssemblyTargetWasmStreamer::emitULEBValue(const MCExpr *Value,
                                                  unsigned Size, SMLoc Loc) {
  // have object streamer create the data fragment and (wrong) fixup. We can't
  // use emitULEB128Value since it assumes the value is constant (doesn't emit
  // relocation / fixup)
  Streamer.emitValue(Value, Size, Loc);
  MCDataFragment *DF = dyn_cast<MCDataFragment>(Streamer.getCurrentFragment());
  assert(DF && "Current fragment must be the data fragment MCObjectStreamer "
               "just created");
  assert(!DF->getFixups().empty() &&
         "fixup expected in current data fragment - use "
         "MCObjectStreamer::emitValueImpl for uleb128 constants");
  assert(DF->getFixups().back().getValue() == Value &&
         "Unexpected fixup in current data fragment");
  WebAssembly::Fixups RequiredFixup;
  switch (Size) {
  case 4:
    RequiredFixup = WebAssembly::Fixups::fixup_uleb128_i32;
    // the relocation is 5 bytes, 1 byte larger than the original size
    DF->appendContents(1, 0);
    break;
  case 8:
    RequiredFixup = WebAssembly::Fixups::fixup_uleb128_i64;
    // the relocation is 10 bytes, 2 byte larger than the original size
    DF->appendContents(2, 0);
    break;
  default:
    llvm_unreachable("Unexpected size for uleb128 fixup");
  }
  // replace fixup created by MCObjectStreamer::emitValueImpl with a uleb128
  // fixup
  DF->getFixups().back() =
      MCFixup::create(DF->getContents().size() - 5, Value, RequiredFixup, Loc);
}

void WebAssemblyTargetAsmStreamer::emitULEBValue(const MCExpr *Value,
                                                 unsigned Size, SMLoc Loc) {
  // for normal assembly output, we don't need to fiddle with the fixups (treat
  // value like normal data) this doesn't work for the object writer, since the
  // MCObjectStreamer assumes uleb128 values are always constant
  Streamer.emitULEB128Value(Value);
}

void WebAssemblyTargetWasmStreamer::emitIndIdx(const MCExpr *Value) {
  llvm_unreachable(".indidx encoding not yet implemented");
}
