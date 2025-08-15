# RUN: rm -rf %t; split-file %s %t

# with call targets
# RUN: llvm-mc -triple=wasm32-unknown-unknown -mcpu=mvp -filetype=obj %t/f1ct.S -o %t/f1.o
# RUN: llvm-mc -triple=wasm32-unknown-unknown -mcpu=mvp -filetype=obj %t/f2ct.S -o %t/f2.o
# RUN: wasm-ld --export-all -o %t.wasm %t/f2.o %t/f1.o
# RUN: obj2yaml %t.wasm | FileCheck --check-prefixes=CHECK %s

# CHECK:          - Type:            CUSTOM
# CHECK:            Name:            metadata.code.call_targets
# CHECK-NEXT:       Entries:
# CHECK-NEXT:         - FuncIdx:         2
# CHECK-NEXT:           Hints:
# CHECK-NEXT:             - Offset:          69
# CHECK-NEXT:               Size:            30
# CHECK-NEXT:               Data:
# CHECK-NEXT:                 - FuncIdx:         3
# CHECK-NEXT:                   CallFrequency:     50
# CHECK-NEXT:                 - FuncIdx:         4
# CHECK-NEXT:                   CallFrequency:     30
# CHECK-NEXT:                 - FuncIdx:         1
# CHECK-NEXT:                   CallFrequency:     20
# CHECK-NEXT:         - FuncIdx:         5
# CHECK-NEXT:           Hints:
# CHECK-NEXT:             - Offset:          18
# CHECK-NEXT:               Size:            20
# CHECK-NEXT:               Data:
# CHECK-NEXT:                 - FuncIdx:         3
# CHECK-NEXT:                   CallFrequency:     99
# CHECK-NEXT:                 - FuncIdx:         4
# CHECK-NEXT:                   CallFrequency:     1

# CHECK:          - Type:            CUSTOM
# CHECK:            Name:            name
# CHECK-NEXT:       FunctionNames:
# CHECK-NEXT:        - Index:           0
# CHECK-NEXT:          Name:            __wasm_call_ctors
# CHECK-NEXT:        - Index:           1
# CHECK-NEXT:          Name:            baz
# CHECK-NEXT:        - Index:           2
# CHECK-NEXT:          Name:            test_multiple_targets
# CHECK-NEXT:        - Index:           3
# CHECK-NEXT:          Name:            foo
# CHECK-NEXT:        - Index:           4
# CHECK-NEXT:          Name:            bar
# CHECK-NEXT:        - Index:           5
# CHECK-NEXT:          Name:            _start

# CHECK:        - Type:            CUSTOM
# CHECK:          Name:            target_features
# CHECK-NEXT:     Features:
# CHECK-NEXT:       - Prefix:          USED
# CHECK-NEXT:         Name:            compilation-hints-call-targets

# without call targets
# RUN: llvm-mc -triple=wasm32-unknown-unknown -mcpu=mvp -filetype=obj %t/f1.S -o %t/f1.o
# RUN: llvm-mc -triple=wasm32-unknown-unknown -mcpu=mvp -filetype=obj %t/f2.S -o %t/f2.o
# RUN: wasm-ld --export-all -o %t.wasm %t/f2.o %t/f1.o
# RUN: obj2yaml %t.wasm | FileCheck --check-prefixes=NCHECK %s

# NCHECK-NOT:         Name:            metadata.code.call_targets
# NCHECK-NOT:         Name:            compilation-hints-call-targets

# with call targets, but only the _start function is not removed by lld (no --export-all)
# RUN: llvm-mc -triple=wasm32-unknown-unknown -mcpu=mvp -filetype=obj %t/f1ct.S -o %t/f1.o
# RUN: llvm-mc -triple=wasm32-unknown-unknown -mcpu=mvp -filetype=obj %t/f2ct.S -o %t/f2.o
# RUN: wasm-ld -o %t.wasm %t/f2.o %t/f1.o
# RUN: obj2yaml %t.wasm | FileCheck --check-prefixes=RCHECK %s

# RCHECK:          - Type:            CUSTOM
# RCHECK:            Name:            metadata.code.call_targets
# RCHECK-NEXT:       Entries:
# RCHECK-NEXT:         - FuncIdx:         2
# RCHECK-NEXT:           Hints:
# RCHECK-NEXT:             - Offset:          18
# RCHECK-NEXT:               Size:            20
# RCHECK-NEXT:               Data:
# RCHECK-NEXT:                 - FuncIdx:         0
# RCHECK-NEXT:                   CallFrequency:     99
# RCHECK-NEXT:                 - FuncIdx:         1
# RCHECK-NEXT:                   CallFrequency:     1

# RCHECK:         - Type:            CUSTOM
# RCHECK-NEXT:      Name:            name
# RCHECK-NEXT:      FunctionNames:
# RCHECK-NEXT:        - Index:           0
# RCHECK-NEXT:          Name:            foo
# RCHECK-NEXT:        - Index:           1
# RCHECK-NEXT:          Name:            bar
# RCHECK-NEXT:        - Index:           2
# RCHECK-NEXT:          Name:            _start

# RCHECK:        - Type:            CUSTOM
# RCHECK:          Name:            target_features
# RCHECK-NEXT:     Features:
# RCHECK-NEXT:       - Prefix:          USED
# RCHECK-NEXT:         Name:            compilation-hints-call-targets

#--- f1.S
# Assembly generated based on following ir and
# `llc -mcpu=mvp -filetype=asm ./f1.ll -o f1.S -mattr=-branch-hinting`
# `llc -mcpu=mvp -filetype=asm ./f1.ll -o f1ct.S -mattr=+branch-hinting`
#target triple = "wasm32-unknown-unknown"
#
#define i32 @foo(i32 %a) {
#entry:
#  %0 = add i32 %a, 1
#  ret i32 %0
#}
#
#define i32 @bar(i32 %a) {
#entry:
#  %0 = mul i32 %a, 2
#  ret i32 %0
#}
#
#define i32 @_start(i32 %cond, i32 %val) {
#  ; Select function pointer at runtime
#  %cond_bool = icmp eq i32 %cond, 0
#  %func_ptr = select i1 %cond_bool, i32 (i32)* @foo, i32 (i32)* @bar
#  ; Indirect call with value profiling metadata
#  %result = notail call i32 %func_ptr(i32 %val), !prof !1
#  ret i32 %result
#}
#
#; md5sum_64("foo") = 6699318081062747564
#; md5sum_64("bar") = 16434608426314478903
#; foo = 99%, bar = 1%
#!1 = !{!"VP", i32 0, i64 100, i64 6699318081062747564, i64 99, i64 16434608426314478903, i64 1}
	.file	"f1.ll"
	.tabletype	__indirect_function_table, funcref
	.functype	foo (i32) -> (i32)
	.functype	bar (i32) -> (i32)
	.functype	_start (i32, i32) -> (i32)
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
# %bb.0:
	local.get	1
	i32.const	bar
	i32.const	foo
	local.get	0
	i32.select
	call_indirect	 (i32) -> (i32)
                                        # fallthrough-return
	end_function
                                        # -- End function
	.no_dead_strip	__indirect_function_table

#--- f1ct.S
 	.file	"f1.ll"
 	.tabletype	__indirect_function_table, funcref
 	.functype	foo (i32) -> (i32)
 	.functype	bar (i32) -> (i32)
 	.functype	_start (i32, i32) -> (i32)
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
 # %bb.0:
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
 	.no_dead_strip	__indirect_function_table
 	.section	.custom_section.target_features,"",@
 	.int8	1
 	.int8	43
 	.int8	30
 	.ascii	"compilation-hints-call-targets"
 	.section	.text._start,"",@
 	.section	.custom_section.metadata.code.call_targets,"",@
 	.int8	1
 	.uleb128 _start@FUNCINDEX
 	.int8	1
 	.uleb128 .Ltmp0@DEBUGREF
 	.int8	20
 	.uleb128 foo@FUNCINDEX
 	.asciz	"\343\200\200\200"
 	.uleb128 bar@FUNCINDEX
 	.asciz	"\201\200\200\200"
 	.section	.text._start,"",@

#--- f2.S
# Assembly generated based on following ir and
# `llc -mcpu=mvp -filetype=asm ./f2.ll -o f2.S -mattr=-branch-hinting`
# `llc -mcpu=mvp -filetype=asm ./f2.ll -o f2ct.S -mattr=+branch-hinting`
#target triple = "wasm32-unknown-unknown"
#
#declare i32 @foo(i32)
#declare i32 @bar(i32)
#define i32 @baz(i32 %x) {
#entry:
#  %result = sub nsw i32 %x, 1
#  ret i32 %result
#}
#
#define i32 @test_multiple_targets(i32 %selector, i32 %val) {
#entry:
#  ; Function pointer table
#  %func_table = alloca [3 x i32 (i32)*], align 8
#  %func_table_ptr = getelementptr inbounds [3 x i32 (i32)*], [3 x i32 (i32)*]* %func_table, i64 0, i64 0
#  store i32 (i32)* @foo, i32 (i32)** %func_table_ptr, align 8
#  %func_table_ptr1 = getelementptr inbounds [3 x i32 (i32)*], [3 x i32 (i32)*]* %func_table, i64 0, i64 1
#  store i32 (i32)* @bar, i32 (i32)** %func_table_ptr1, align 8
#  %func_table_ptr2 = getelementptr inbounds [3 x i32 (i32)*], [3 x i32 (i32)*]* %func_table, i64 0, i64 2
#  store i32 (i32)* @baz, i32 (i32)** %func_table_ptr2, align 8
#
#  ; Select function based on selector
#  %idx = urem i32 %selector, 3
#  %idx_ext = zext i32 %idx to i64
#  %func_ptr_addr = getelementptr inbounds [3 x i32 (i32)*], [3 x i32 (i32)*]* %func_table, i64 0, i64 %idx_ext
#  %func_ptr = load i32 (i32)*, i32 (i32)** %func_ptr_addr, align 8
#
#  ; Indirect call with multiple target profiling
#  %result = notail call i32 %func_ptr(i32 %val), !prof !2
#  ret i32 %result
#}
#
#; md5sum_64("foo") = 6699318081062747564
#; md5sum_64("bar") = 16434608426314478903
#; md5sum_64("baz") = 7546896869197086323
#; foo = 50%, bar = 30%, baz = 20%
#!2 = !{!"VP", i32 0, i64 100, i64 6699318081062747564, i64 50, i64 16434608426314478903, i64 30, i64 7546896869197086323, i64 20}
	.file	"f2.ll"
	.tabletype	__indirect_function_table, funcref
	.globaltype	__stack_pointer, i32
	.functype	foo (i32) -> (i32)
	.functype	bar (i32) -> (i32)
	.functype	baz (i32) -> (i32)
	.functype	test_multiple_targets (i32, i32) -> (i32)
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
	.no_dead_strip	__indirect_function_table
#--- f2ct.S
	.file	"f2.ll"
	.tabletype	__indirect_function_table, funcref
	.globaltype	__stack_pointer, i32
	.functype	foo (i32) -> (i32)
	.functype	bar (i32) -> (i32)
	.functype	baz (i32) -> (i32)
	.functype	test_multiple_targets (i32, i32) -> (i32)
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
.Ltmp0:
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
	.no_dead_strip	__indirect_function_table
	.section	.custom_section.target_features,"",@
	.int8	1
	.int8	43
	.int8	30
	.ascii	"compilation-hints-call-targets"
	.section	.text.test_multiple_targets,"",@
	.section	.custom_section.metadata.code.call_targets,"",@
	.int8	1
	.uleb128 test_multiple_targets@FUNCINDEX
	.int8	1
	.uleb128 .Ltmp0@DEBUGREF
	.int8	30
	.uleb128 foo@FUNCINDEX
	.asciz	"\262\200\200\200"
	.uleb128 bar@FUNCINDEX
	.asciz	"\236\200\200\200"
	.uleb128 baz@FUNCINDEX
	.asciz	"\224\200\200\200"
	.section	.text.test_multiple_targets,"",@
