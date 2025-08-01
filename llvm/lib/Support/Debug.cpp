//===-- Debug.cpp - An easy way to add debug output to your code ----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements a handy way of adding debugging information to your
// code, without it being enabled all of the time, and without having to add
// command line options to enable it.
//
// In particular, just wrap your code with the LLVM_DEBUG() macro, and it will
// be enabled automatically if you specify '-debug' on the command-line.
// Alternatively, you can also use the SET_DEBUG_TYPE("foo") macro to specify
// that your debug code belongs to class "foo".  Then, on the command line, you
// can specify '-debug-only=foo' to enable JUST the debug information for the
// foo class.
//
// When compiling without assertions, the -debug-* options and all code in
// LLVM_DEBUG() statements disappears, so it does not affect the runtime of the
// code.
//
//===----------------------------------------------------------------------===//

#include "llvm/Support/Debug.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/Signals.h"
#include "llvm/Support/circular_raw_ostream.h"
#include "llvm/Support/raw_ostream.h"
#include <utility>

#include "DebugOptions.h"

#undef isCurrentDebugType
#undef setCurrentDebugType
#undef setCurrentDebugTypes

using namespace llvm;

/// Parse a debug type string into a pair of the debug type and the debug level.
/// The expected format is "type[:level]", where the level is an optional
/// integer.
static std::pair<std::string, std::optional<int>>
parseDebugType(StringRef DbgType) {
  std::optional<int> Level;
  size_t ColonPos = DbgType.find(':');
  if (ColonPos != StringRef::npos) {
    StringRef LevelStr = DbgType.substr(ColonPos + 1);
    DbgType = DbgType.take_front(ColonPos);
    if (LevelStr.empty())
      Level = 0;
    else {
      int parsedLevel;
      if (to_integer(LevelStr, parsedLevel, 10))
        Level = parsedLevel;
    }
  }
  return std::make_pair(DbgType.str(), Level);
}

// Even though LLVM might be built with NDEBUG, define symbols that the code
// built without NDEBUG can depend on via the llvm/Support/Debug.h header.
namespace llvm {
/// Exported boolean set by the -debug option.
bool DebugFlag = false;

/// The current debug type and an optional debug level.
/// The debug level is the verbosity of the debug output.
/// 0 is a special level that acts as an opt-out for this specific debug type.
/// If provided, the debug output is enabled only if the user specified a level
/// at least as high as the provided level.
static ManagedStatic<std::vector<std::pair<std::string, std::optional<int>>>>
    CurrentDebugType;

/// Return true if the specified string is the debug type
/// specified on the command line, or if none was specified on the command line
/// with the -debug-only=X option.
bool isCurrentDebugType(const char *DebugType, int Level) {
  if (CurrentDebugType->empty())
    return true;
  // Track if there is at least one debug type with a level, this is used
  // to allow to opt-out of some DebugType and leaving all the others enabled.
  bool HasEnabledDebugType = false;
  // See if DebugType is in list. Note: do not use find() as that forces us to
  // unnecessarily create an std::string instance.
  for (auto &D : *CurrentDebugType) {
    HasEnabledDebugType =
        HasEnabledDebugType || (!D.second.has_value() || D.second.value() > 0);
    if (D.first != DebugType)
      continue;
    if (!D.second.has_value())
      return true;
    return D.second >= Level;
  }
  return !HasEnabledDebugType;
}

/// Set the current debug type, as if the -debug-only=X
/// option were specified.  Note that DebugFlag also needs to be set to true for
/// debug output to be produced.
///
void setCurrentDebugTypes(const char **Types, unsigned Count);

void setCurrentDebugType(const char *Type) {
  setCurrentDebugTypes(&Type, 1);
}

void setCurrentDebugTypes(const char **Types, unsigned Count) {
  CurrentDebugType->clear();
  CurrentDebugType->reserve(Count);
  for (const char *Type : ArrayRef(Types, Count))
    CurrentDebugType->push_back(parseDebugType(Type));
}

} // namespace llvm

// All Debug.h functionality is a no-op in NDEBUG mode.
#ifndef NDEBUG

namespace {
struct CreateDebug {
  static void *call() {
    return new cl::opt<bool, true>("debug", cl::desc("Enable debug output"),
                                   cl::Hidden, cl::location(DebugFlag));
  }
};

// -debug-buffer-size - Buffer the last N characters of debug output
//until program termination.
struct CreateDebugBufferSize {
  static void *call() {
    return new cl::opt<unsigned>(
        "debug-buffer-size",
        cl::desc("Buffer the last N characters of debug output "
                 "until program termination. "
                 "[default 0 -- immediate print-out]"),
        cl::Hidden, cl::init(0));
  }
};
} // namespace

// -debug - Command line option to enable the DEBUG statements in the passes.
// This flag may only be enabled in debug builds.
static ManagedStatic<cl::opt<bool, true>, CreateDebug> Debug;
static ManagedStatic<cl::opt<unsigned>, CreateDebugBufferSize> DebugBufferSize;

namespace {

struct DebugOnlyOpt {
  void operator=(const std::string &Val) const {
    if (Val.empty())
      return;
    DebugFlag = true;
    SmallVector<StringRef, 8> DbgTypes;
    StringRef(Val).split(DbgTypes, ',', -1, false);
    for (auto DbgType : DbgTypes)
      CurrentDebugType->push_back(parseDebugType(DbgType));
  }
};
} // namespace

static DebugOnlyOpt DebugOnlyOptLoc;

namespace {
struct CreateDebugOnly {
  static void *call() {
    return new cl::opt<DebugOnlyOpt, true, cl::parser<std::string>>(
        "debug-only",
        cl::desc(
            "Enable a specific type of debug output (comma separated list "
            "of types using the format \"type[:level]\", where the level "
            "is an optional integer. The level can be set to 1, 2, 3, etc. to "
            "control the verbosity of the output. Setting a debug-type level "
            "to zero acts as an opt-out for this specific debug-type without "
            "affecting the others."),
        cl::Hidden, cl::value_desc("debug string"),
        cl::location(DebugOnlyOptLoc), cl::ValueRequired);
  }
};
} // namespace

static ManagedStatic<cl::opt<DebugOnlyOpt, true, cl::parser<std::string>>,
                     CreateDebugOnly>
    DebugOnly;

void llvm::initDebugOptions() {
  *Debug;
  *DebugBufferSize;
  *DebugOnly;
}

// Signal handlers - dump debug output on termination.
static void debug_user_sig_handler(void *Cookie) {
  // This is a bit sneaky.  Since this is under #ifndef NDEBUG, we
  // know that debug mode is enabled and dbgs() really is a
  // circular_raw_ostream.  If NDEBUG is defined, then dbgs() ==
  // errs() but this will never be invoked.
  llvm::circular_raw_ostream &dbgout =
      static_cast<circular_raw_ostream &>(llvm::dbgs());
  dbgout.flushBufferWithBanner();
}

/// dbgs - Return a circular-buffered debug stream.
raw_ostream &llvm::dbgs() {
  // Do one-time initialization in a thread-safe way.
  static struct dbgstream {
    circular_raw_ostream strm;

    dbgstream()
        : strm(errs(), "*** Debug Log Output ***\n",
               (!EnableDebugBuffering || !DebugFlag) ? 0 : *DebugBufferSize) {
      if (EnableDebugBuffering && DebugFlag && *DebugBufferSize != 0)
        // TODO: Add a handler for SIGUSER1-type signals so the user can
        // force a debug dump.
        sys::AddSignalHandler(&debug_user_sig_handler, nullptr);
      // Otherwise we've already set the debug stream buffer size to
      // zero, disabling buffering so it will output directly to errs().
    }
  } thestrm;

  return thestrm.strm;
}

#else
// Avoid "has no symbols" warning.
namespace llvm {
  /// dbgs - Return errs().
  raw_ostream &dbgs() {
    return errs();
  }
}
void llvm::initDebugOptions() {}
#endif

/// EnableDebugBuffering - Turn on signal handler installation.
///
bool llvm::EnableDebugBuffering = false;
