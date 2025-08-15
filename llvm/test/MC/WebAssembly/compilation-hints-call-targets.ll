# RUN: rm -rf %t; split-file %s %t

; check ll -> asm
; make sure it works both with and without fast isel (O0 vs O3)
; RUN: llc -O0 -mcpu=mvp -filetype=asm %t/1.ll -mattr=+compilation-hints -o - | FileCheck --check-prefixes=ASM-CHECK %s
; RUN: llc -O3 -mcpu=mvp -filetype=asm %t/1.ll -mattr=+compilation-hints -o - | FileCheck --check-prefixes=ASM-CHECK %s
; RUN: llc -O0 -mcpu=mvp -filetype=asm %t/1.ll -mattr=-compilation-hints -o - | FileCheck --check-prefixes=ASM-NCHECK %s
; RUN: llc -O3 -mcpu=mvp -filetype=asm %t/1.ll -mattr=-compilation-hints -o - | FileCheck --check-prefixes=ASM-NCHECK %s
; RUN: llc -O0 -mcpu=mvp -filetype=asm %t/1.ll -o - | FileCheck --check-prefixes=ASM-NCHECK %s
; RUN: llc -O3 -mcpu=mvp -filetype=asm %t/1.ll -o - | FileCheck --check-prefixes=ASM-NCHECK %s

; check asm -> obj -> yaml
; RUN: llvm-mc -mcpu=mvp -triple=wasm32-unknown-unknown -filetype=obj %t/1-ch.S -o - | obj2yaml | FileCheck --check-prefixes=YAML-CHECK %s
; RUN: llvm-mc -mcpu=mvp -triple=wasm32-unknown-unknown -filetype=obj %t/1-no-ch.S -o - | obj2yaml | FileCheck --check-prefixes=YAML-NCHECK %s

; This test checks that value profiling metadata (!prof) with VP (call targets) is correctly lowered to
; the WebAssembly call targets custom section.

; ASM-CHECK:        _start:                                 # @_start
; ASM-CHECK:        .Ltmp0:
; ASM-CHECK-NEXT:     call_indirect    (i32) -> (i32)

; ASM-CHECK:        test_multiple_targets:                  # @test_multiple_targets
; ASM-CHECK:        .Ltmp1:
; ASM-CHECK-NEXT:     call_indirect    (i32) -> (i32)

; ASM-CHECK:        .section        .custom_section.target_features,"",@
; ASM-CHECK-NEXT:   .int8   3
; ASM-CHECK-NEXT:   .int8   43
; ASM-CHECK-NEXT:   .int8   14
; ASM-CHECK-NEXT:   .ascii  "branch-hinting"
; ASM-CHECK-NEXT:   .int8   43
; ASM-CHECK-NEXT:   .int8   17
; ASM-CHECK-NEXT:   .ascii  "compilation-hints"
; ASM-CHECK-NEXT:   .int8   43
; ASM-CHECK-NEXT:   .int8   30
; ASM-CHECK-NEXT:   .ascii  "compilation-hints-call-targets"

; ASM-CHECK:        .section        .custom_section.metadata.code.call_targets,"",@
; ASM-CHECK-NEXT:   .int8   2
; ASM-CHECK-NEXT:   .uleb128 _start@FUNCINDEX
; ASM-CHECK-NEXT:   .int8   1
; ASM-CHECK-NEXT:   .uleb128 .Ltmp0@DEBUGREF
; ASM-CHECK-NEXT:   .int8   20
; ASM-CHECK-NEXT:   .uleb128 foo@FUNCINDEX
; ASM-CHECK-NEXT:   .asciz  "\343\200\200\200"
; ASM-CHECK-NEXT:   .uleb128 bar@FUNCINDEX
; ASM-CHECK-NEXT:   .asciz  "\201\200\200\200"
; ASM-CHECK-NEXT:   .uleb128 test_multiple_targets@FUNCINDEX
; ASM-CHECK-NEXT:   .int8   1
; ASM-CHECK-NEXT:   .uleb128 .Ltmp1@DEBUGREF
; ASM-CHECK-NEXT:   .int8   30
; ASM-CHECK-NEXT:   .uleb128 foo@FUNCINDEX
; ASM-CHECK-NEXT:   .asciz  "\262\200\200\200"
; ASM-CHECK-NEXT:   .uleb128 bar@FUNCINDEX
; ASM-CHECK-NEXT:   .asciz  "\236\200\200\200"
; ASM-CHECK-NEXT:   .uleb128 baz@FUNCINDEX
; ASM-CHECK-NEXT:   .asciz  "\224\200\200\200"

; ASM-NCHECK-NOT:   .ascii      "compilation-hints"
; ASM-NCHECK-NOT:   .section        metadata.code.call_targets,"",@

; YAML-CHECK:        - Type:            CUSTOM
; YAML-CHECK-NEXT:     Relocations:
; YAML-CHECK-NEXT:       - Type:            R_WASM_FUNCTION_INDEX_LEB
; YAML-CHECK-NEXT:         Index:           2
; YAML-CHECK-NEXT:         Offset:          0x1
; YAML-CHECK-NEXT:       - Type:            R_WASM_FUNCTION_INDEX_LEB
; YAML-CHECK-NEXT:         Index:           0
; YAML-CHECK-NEXT:         Offset:          0x9
; YAML-CHECK-NEXT:       - Type:            R_WASM_FUNCTION_INDEX_LEB
; YAML-CHECK-NEXT:         Index:           1
; YAML-CHECK-NEXT:         Offset:          0x13
; YAML-CHECK-NEXT:       - Type:            R_WASM_FUNCTION_INDEX_LEB
; YAML-CHECK-NEXT:         Index:           3
; YAML-CHECK-NEXT:         Offset:          0x1D
; YAML-CHECK-NEXT:       - Type:            R_WASM_FUNCTION_INDEX_LEB
; YAML-CHECK-NEXT:         Index:           0
; YAML-CHECK-NEXT:         Offset:          0x25
; YAML-CHECK-NEXT:       - Type:            R_WASM_FUNCTION_INDEX_LEB
; YAML-CHECK-NEXT:         Index:           1
; YAML-CHECK-NEXT:         Offset:          0x2F
; YAML-CHECK-NEXT:       - Type:            R_WASM_FUNCTION_INDEX_LEB
; YAML-CHECK-NEXT:         Index:           5
; YAML-CHECK-NEXT:         Offset:          0x39
; YAML-CHECK-NEXT:     Name:            metadata.code.call_targets
; YAML-CHECK-NEXT:     Entries:
; YAML-CHECK-NEXT:       - FuncIdx:         2
; YAML-CHECK-NEXT:         Hints:
; YAML-CHECK-NEXT:           - Offset:          18
; YAML-CHECK-NEXT:             Size:            20
; YAML-CHECK-NEXT:             Data:
; YAML-CHECK-NEXT:               - FuncIdx:         0
; YAML-CHECK-NEXT:                 CallFrequency:     99
; YAML-CHECK-NEXT:               - FuncIdx:         1
; YAML-CHECK-NEXT:                 CallFrequency:     1
; YAML-CHECK-NEXT:       - FuncIdx:         3
; YAML-CHECK-NEXT:         Hints:
; YAML-CHECK-NEXT:           - Offset:          69
; YAML-CHECK-NEXT:             Size:     30
; YAML-CHECK-NEXT:             Data:
; YAML-CHECK-NEXT:               - FuncIdx:         0
; YAML-CHECK-NEXT:                 CallFrequency:     50
; YAML-CHECK-NEXT:               - FuncIdx:         1
; YAML-CHECK-NEXT:                 CallFrequency:     30
; YAML-CHECK-NEXT:               - FuncIdx:         4
; YAML-CHECK-NEXT:                 CallFrequency:     20

; YAML-CHECK:        - Type:            CUSTOM
; YAML-CHECK-NEXT:     Name:            linking

; YAML-CHECK:        - Type:            CUSTOM
; YAML-CHECK-NEXT:     Name:            target_features
; YAML-CHECK-NEXT:     Features:
; YAML-CHECK-NEXT:     - Prefix:          USED
; YAML-CHECK-NEXT:       Name:            branch-hinting
; YAML-CHECK-NEXT:     - Prefix:          USED
; YAML-CHECK-NEXT:       Name:            compilation-hints
; YAML-CHECK-NEXT:     - Prefix:          USED
; YAML-CHECK-NEXT:       Name:            compilation-hints-call-targets

; YAML-NCHECK-NOT:     Name:            metadata.code.call_targets
; YAML-NCHECK-NOT:     Name:            compilation-hints

#--- 1.ll
target triple = "wasm32-unknown-unknown"

define i32 @foo(i32 %x) {
entry:
  %result = add nsw i32 %x, 1
  ret i32 %result
}

define i32 @bar(i32 %x) {
entry:
  %result = mul nsw i32 %x, 2
  ret i32 %result
}

define i32 @_start(i32 %cond, i32 %val) {
entry:
  ; Select function pointer at runtime
  %cond_bool = icmp eq i32 %cond, 0
  %func_ptr = select i1 %cond_bool, i32 (i32)* @foo, i32 (i32)* @bar
  ; Indirect call with value profiling metadata
  %result = notail call i32 %func_ptr(i32 %val), !prof !1
  ret i32 %result
}

define i32 @test_multiple_targets(i32 %selector, i32 %val) {
entry:
  ; Function pointer table
  %func_table = alloca [3 x i32 (i32)*], align 8
  %func_table_ptr = getelementptr inbounds [3 x i32 (i32)*], [3 x i32 (i32)*]* %func_table, i64 0, i64 0
  store i32 (i32)* @foo, i32 (i32)** %func_table_ptr, align 8
  %func_table_ptr1 = getelementptr inbounds [3 x i32 (i32)*], [3 x i32 (i32)*]* %func_table, i64 0, i64 1
  store i32 (i32)* @bar, i32 (i32)** %func_table_ptr1, align 8
  %func_table_ptr2 = getelementptr inbounds [3 x i32 (i32)*], [3 x i32 (i32)*]* %func_table, i64 0, i64 2
  store i32 (i32)* @baz, i32 (i32)** %func_table_ptr2, align 8

  ; Select function based on selector
  %idx = urem i32 %selector, 3
  %idx_ext = zext i32 %idx to i64
  %func_ptr_addr = getelementptr inbounds [3 x i32 (i32)*], [3 x i32 (i32)*]* %func_table, i64 0, i64 %idx_ext
  %func_ptr = load i32 (i32)*, i32 (i32)** %func_ptr_addr, align 8

  ; Indirect call with multiple target profiling
  %result = notail call i32 %func_ptr(i32 %val), !prof !2
  ret i32 %result
}

define i32 @baz(i32 %x) {
entry:
  %result = sub nsw i32 %x, 1
  ret i32 %result
}

; md5sum_64("foo") = 6699318081062747564
; md5sum_64("bar") = 16434608426314478903
; foo = 99%, bar = 1%
!1 = !{!"VP", i32 0, i64 100, i64 6699318081062747564, i64 99, i64 16434608426314478903, i64 1}

; md5sum_64("foo") = 6699318081062747564
; md5sum_64("bar") = 16434608426314478903
; md5sum_64("baz") = 7546896869197086323
; foo = 50%, bar = 30%, baz = 20%
!2 = !{!"VP", i32 0, i64 100, i64 6699318081062747564, i64 50, i64 16434608426314478903, i64 30, i64 7546896869197086323, i64 20}

#--- 1-no-ch.S
# Assembly generated based on 1.ll and
# `llc -mcpu=mvp -filetype=asm ./1.ll -o 1-no-ch.S -mattr=-compilation-hints`
		.file	"1.ll"
    	.tabletype	__indirect_function_table, funcref
    	.globaltype	__stack_pointer, i32
    	.functype	foo (i32) -> (i32)
    	.functype	bar (i32) -> (i32)
    	.functype	_start (i32, i32) -> (i32)
    	.functype	test_multiple_targets (i32, i32) -> (i32)
    	.functype	baz (i32) -> (i32)
    	.section	.text.foo,"",@
    	.globl	foo                             # -- Begin function foo
    	.type	foo,@function
    foo:                                    # @foo
    	.functype	foo (i32) -> (i32)
    # %bb.0:                                # %entry
    	local.get	0
    	i32.const	1
    	i32.add
                                            # fallthrough-return
    	end_function
                                            # -- End function
    	.section	.text.bar,"",@
    	.globl	bar                             # -- Begin function bar
    	.type	bar,@function
    bar:                                    # @bar
    	.functype	bar (i32) -> (i32)
    # %bb.0:                                # %entry
    	local.get	0
    	i32.const	1
    	i32.shl
                                            # fallthrough-return
    	end_function
                                            # -- End function
    	.section	.text._start,"",@
    	.globl	_start                          # -- Begin function _start
    	.type	_start,@function
    _start:                                 # @_start
    	.functype	_start (i32, i32) -> (i32)
    # %bb.0:                                # %entry
    	local.get	1
    	i32.const	bar
    	i32.const	foo
    	local.get	0
    	i32.select
    	call_indirect	 (i32) -> (i32)
                                            # fallthrough-return
    	end_function
                                            # -- End function
    	.section	.text.test_multiple_targets,"",@
    	.globl	test_multiple_targets           # -- Begin function test_multiple_targets
    	.type	test_multiple_targets,@function
    test_multiple_targets:                  # @test_multiple_targets
    	.functype	test_multiple_targets (i32, i32) -> (i32)
    	.local  	i32
    # %bb.0:                                # %entry
    	global.get	__stack_pointer
    	i32.const	16
    	i32.sub
    	local.tee	2
    	global.set	__stack_pointer
    	local.get	2
    	i32.const	baz
    	i32.store	8
    	local.get	2
    	i32.const	bar
    	i32.store	4
    	local.get	2
    	i32.const	foo
    	i32.store	0
    	local.get	1
    	local.get	2
    	local.get	0
    	i32.const	3
    	i32.rem_u
    	i32.const	2
    	i32.shl
    	i32.add
    	i32.load	0
    	call_indirect	 (i32) -> (i32)
    	local.set	0
    	local.get	2
    	i32.const	16
    	i32.add
    	global.set	__stack_pointer
    	local.get	0
                                            # fallthrough-return
    	end_function
                                            # -- End function
    	.section	.text.baz,"",@
    	.globl	baz                             # -- Begin function baz
    	.type	baz,@function
    baz:                                    # @baz
    	.functype	baz (i32) -> (i32)
    # %bb.0:                                # %entry
    	local.get	0
    	i32.const	-1
    	i32.add
                                            # fallthrough-return
    	end_function
                                            # -- End function
    	.no_dead_strip	__indirect_function_table

#--- 1-ch.S
		.file	"1.ll"
    	.tabletype	__indirect_function_table, funcref
    	.globaltype	__stack_pointer, i32
    	.functype	foo (i32) -> (i32)
    	.functype	bar (i32) -> (i32)
    	.functype	_start (i32, i32) -> (i32)
    	.functype	test_multiple_targets (i32, i32) -> (i32)
    	.functype	baz (i32) -> (i32)
    	.section	.text.foo,"",@
    	.globl	foo                             # -- Begin function foo
    	.type	foo,@function
    foo:                                    # @foo
    	.functype	foo (i32) -> (i32)
    # %bb.0:                                # %entry
    	local.get	0
    	i32.const	1
    	i32.add
                                            # fallthrough-return
    	end_function
                                            # -- End function
    	.section	.text.bar,"",@
    	.globl	bar                             # -- Begin function bar
    	.type	bar,@function
    bar:                                    # @bar
    	.functype	bar (i32) -> (i32)
    # %bb.0:                                # %entry
    	local.get	0
    	i32.const	1
    	i32.shl
                                            # fallthrough-return
    	end_function
                                            # -- End function
    	.section	.text._start,"",@
    	.globl	_start                          # -- Begin function _start
    	.type	_start,@function
    _start:                                 # @_start
    	.functype	_start (i32, i32) -> (i32)
    # %bb.0:                                # %entry
    	local.get	1
    	i32.const	bar
    	i32.const	foo
    	local.get	0
    	i32.select
    .Ltmp0:
    	call_indirect	 (i32) -> (i32)
                                            # fallthrough-return
    	end_function
                                            # -- End function
    	.section	.text.test_multiple_targets,"",@
    	.globl	test_multiple_targets           # -- Begin function test_multiple_targets
    	.type	test_multiple_targets,@function
    test_multiple_targets:                  # @test_multiple_targets
    	.functype	test_multiple_targets (i32, i32) -> (i32)
    	.local  	i32
    # %bb.0:                                # %entry
    	global.get	__stack_pointer
    	i32.const	16
    	i32.sub
    	local.tee	2
    	global.set	__stack_pointer
    	local.get	2
    	i32.const	baz
    	i32.store	8
    	local.get	2
    	i32.const	bar
    	i32.store	4
    	local.get	2
    	i32.const	foo
    	i32.store	0
    	local.get	1
    	local.get	2
    	local.get	0
    	i32.const	3
    	i32.rem_u
    	i32.const	2
    	i32.shl
    	i32.add
    	i32.load	0
    .Ltmp1:
    	call_indirect	 (i32) -> (i32)
    	local.set	0
    	local.get	2
    	i32.const	16
    	i32.add
    	global.set	__stack_pointer
    	local.get	0
                                            # fallthrough-return
    	end_function
                                            # -- End function
    	.section	.text.baz,"",@
    	.globl	baz                             # -- Begin function baz
    	.type	baz,@function
    baz:                                    # @baz
    	.functype	baz (i32) -> (i32)
    # %bb.0:                                # %entry
    	local.get	0
    	i32.const	-1
    	i32.add
                                            # fallthrough-return
    	end_function
                                            # -- End function
    	.no_dead_strip	__indirect_function_table
    	.section	.custom_section.target_features,"",@
    	.int8	3
    	.int8	43
    	.int8	14
    	.ascii	"branch-hinting"
    	.int8	43
    	.int8	17
    	.ascii	"compilation-hints"
    	.int8	43
    	.int8	30
    	.ascii	"compilation-hints-call-targets"
    	.section	.text.baz,"",@
    	.section	.custom_section.metadata.code.call_targets,"",@
    	.int8	2
    	.uleb128 _start@FUNCINDEX
    	.int8	1
    	.uleb128 .Ltmp0@DEBUGREF
    	.int8	20
    	.uleb128 foo@FUNCINDEX
    	.asciz	"\343\200\200\200"
    	.uleb128 bar@FUNCINDEX
    	.asciz	"\201\200\200\200"
    	.uleb128 test_multiple_targets@FUNCINDEX
    	.int8	1
    	.uleb128 .Ltmp1@DEBUGREF
    	.int8	30
    	.uleb128 foo@FUNCINDEX
    	.asciz	"\262\200\200\200"
    	.uleb128 bar@FUNCINDEX
    	.asciz	"\236\200\200\200"
    	.uleb128 baz@FUNCINDEX
    	.asciz	"\224\200\200\200"
    	.section	.text.baz,"",@
