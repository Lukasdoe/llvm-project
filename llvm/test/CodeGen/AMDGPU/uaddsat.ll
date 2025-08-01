; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn-amd-amdpal -mcpu=tahiti < %s | FileCheck --check-prefix=GFX6 %s
; RUN: llc -mtriple=amdgcn-amd-amdpal -mcpu=fiji < %s | FileCheck --check-prefix=GFX8 %s
; RUN: llc -mtriple=amdgcn-amd-amdpal -mcpu=gfx900 < %s | FileCheck --check-prefix=GFX9 %s
; RUN: llc -mtriple=amdgcn-amd-amdpal -mcpu=gfx1010 < %s | FileCheck --check-prefix=GFX10 %s
; RUN: llc -mtriple=amdgcn-amd-amdpal -mcpu=gfx1100 -mattr=+real-true16 < %s | FileCheck --check-prefixes=GFX11,GFX11-TRUE16 %s
; RUN: llc -mtriple=amdgcn-amd-amdpal -mcpu=gfx1100 -mattr=-real-true16 < %s | FileCheck --check-prefixes=GFX11,GFX11-FAKE16 %s

define i8 @v_uaddsat_i8(i8 %lhs, i8 %rhs) {
; GFX6-LABEL: v_uaddsat_i8:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_and_b32_e32 v1, 0xff, v1
; GFX6-NEXT:    v_and_b32_e32 v0, 0xff, v0
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, v0, v1
; GFX6-NEXT:    v_min_u32_e32 v0, 0xff, v0
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_uaddsat_i8:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_add_u16_sdwa v0, v0, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:BYTE_0
; GFX8-NEXT:    v_min_u16_e32 v0, 0xff, v0
; GFX8-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-LABEL: v_uaddsat_i8:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_add_u16_sdwa v0, v0, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_0 src1_sel:BYTE_0
; GFX9-NEXT:    v_min_u16_e32 v0, 0xff, v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX10-LABEL: v_uaddsat_i8:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX10-NEXT:    v_and_b32_e32 v1, 0xff, v1
; GFX10-NEXT:    v_and_b32_e32 v0, 0xff, v0
; GFX10-NEXT:    v_add_nc_u16 v0, v0, v1
; GFX10-NEXT:    v_min_u16 v0, 0xff, v0
; GFX10-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-TRUE16-LABEL: v_uaddsat_i8:
; GFX11-TRUE16:       ; %bb.0:
; GFX11-TRUE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-TRUE16-NEXT:    v_and_b16 v0.h, 0xff, v1.l
; GFX11-TRUE16-NEXT:    v_and_b16 v0.l, 0xff, v0.l
; GFX11-TRUE16-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
; GFX11-TRUE16-NEXT:    v_add_nc_u16 v0.l, v0.l, v0.h
; GFX11-TRUE16-NEXT:    v_min_u16 v0.l, 0xff, v0.l
; GFX11-TRUE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-FAKE16-LABEL: v_uaddsat_i8:
; GFX11-FAKE16:       ; %bb.0:
; GFX11-FAKE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-FAKE16-NEXT:    v_and_b32_e32 v1, 0xff, v1
; GFX11-FAKE16-NEXT:    v_and_b32_e32 v0, 0xff, v0
; GFX11-FAKE16-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
; GFX11-FAKE16-NEXT:    v_add_nc_u16 v0, v0, v1
; GFX11-FAKE16-NEXT:    v_min_u16 v0, 0xff, v0
; GFX11-FAKE16-NEXT:    s_setpc_b64 s[30:31]
  %result = call i8 @llvm.uadd.sat.i8(i8 %lhs, i8 %rhs)
  ret i8 %result
}

define i16 @v_uaddsat_i16(i16 %lhs, i16 %rhs) {
; GFX6-LABEL: v_uaddsat_i16:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_and_b32_e32 v1, 0xffff, v1
; GFX6-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, v0, v1
; GFX6-NEXT:    v_min_u32_e32 v0, 0xffff, v0
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_uaddsat_i16:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_add_u16_e64 v0, v0, v1 clamp
; GFX8-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-LABEL: v_uaddsat_i16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_add_u16_e64 v0, v0, v1 clamp
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX10-LABEL: v_uaddsat_i16:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX10-NEXT:    v_add_nc_u16 v0, v0, v1 clamp
; GFX10-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-TRUE16-LABEL: v_uaddsat_i16:
; GFX11-TRUE16:       ; %bb.0:
; GFX11-TRUE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-TRUE16-NEXT:    v_add_nc_u16 v0.l, v0.l, v1.l clamp
; GFX11-TRUE16-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-FAKE16-LABEL: v_uaddsat_i16:
; GFX11-FAKE16:       ; %bb.0:
; GFX11-FAKE16-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-FAKE16-NEXT:    v_add_nc_u16 v0, v0, v1 clamp
; GFX11-FAKE16-NEXT:    s_setpc_b64 s[30:31]
  %result = call i16 @llvm.uadd.sat.i16(i16 %lhs, i16 %rhs)
  ret i16 %result
}

define i32 @v_uaddsat_i32(i32 %lhs, i32 %rhs) {
; GFX6-LABEL: v_uaddsat_i32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_not_b32_e32 v2, v1
; GFX6-NEXT:    v_min_u32_e32 v0, v0, v2
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, v0, v1
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_uaddsat_i32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_add_u32_e64 v0, s[4:5], v0, v1 clamp
; GFX8-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-LABEL: v_uaddsat_i32:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_add_u32_e64 v0, v0, v1 clamp
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX10-LABEL: v_uaddsat_i32:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX10-NEXT:    v_add_nc_u32_e64 v0, v0, v1 clamp
; GFX10-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-LABEL: v_uaddsat_i32:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-NEXT:    v_add_nc_u32_e64 v0, v0, v1 clamp
; GFX11-NEXT:    s_setpc_b64 s[30:31]
  %result = call i32 @llvm.uadd.sat.i32(i32 %lhs, i32 %rhs)
  ret i32 %result
}

define <2 x i16> @v_uaddsat_v2i16(<2 x i16> %lhs, <2 x i16> %rhs) {
; GFX6-LABEL: v_uaddsat_v2i16:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_and_b32_e32 v3, 0xffff, v3
; GFX6-NEXT:    v_and_b32_e32 v1, 0xffff, v1
; GFX6-NEXT:    v_and_b32_e32 v2, 0xffff, v2
; GFX6-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, v1, v3
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, v0, v2
; GFX6-NEXT:    v_min_u32_e32 v1, 0xffff, v1
; GFX6-NEXT:    v_min_u32_e32 v0, 0xffff, v0
; GFX6-NEXT:    v_lshlrev_b32_e32 v2, 16, v1
; GFX6-NEXT:    v_or_b32_e32 v0, v0, v2
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_uaddsat_v2i16:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_add_u16_sdwa v2, v0, v1 clamp dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; GFX8-NEXT:    v_add_u16_e64 v0, v0, v1 clamp
; GFX8-NEXT:    v_or_b32_e32 v0, v0, v2
; GFX8-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-LABEL: v_uaddsat_v2i16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_pk_add_u16 v0, v0, v1 clamp
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX10-LABEL: v_uaddsat_v2i16:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX10-NEXT:    v_pk_add_u16 v0, v0, v1 clamp
; GFX10-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-LABEL: v_uaddsat_v2i16:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-NEXT:    v_pk_add_u16 v0, v0, v1 clamp
; GFX11-NEXT:    s_setpc_b64 s[30:31]
  %result = call <2 x i16> @llvm.uadd.sat.v2i16(<2 x i16> %lhs, <2 x i16> %rhs)
  ret <2 x i16> %result
}

define <3 x i16> @v_uaddsat_v3i16(<3 x i16> %lhs, <3 x i16> %rhs) {
; GFX6-LABEL: v_uaddsat_v3i16:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_and_b32_e32 v4, 0xffff, v4
; GFX6-NEXT:    v_and_b32_e32 v1, 0xffff, v1
; GFX6-NEXT:    v_and_b32_e32 v5, 0xffff, v5
; GFX6-NEXT:    v_and_b32_e32 v2, 0xffff, v2
; GFX6-NEXT:    v_and_b32_e32 v3, 0xffff, v3
; GFX6-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, v1, v4
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, v0, v3
; GFX6-NEXT:    v_min_u32_e32 v1, 0xffff, v1
; GFX6-NEXT:    v_add_i32_e32 v2, vcc, v2, v5
; GFX6-NEXT:    v_min_u32_e32 v0, 0xffff, v0
; GFX6-NEXT:    v_lshlrev_b32_e32 v1, 16, v1
; GFX6-NEXT:    v_min_u32_e32 v2, 0xffff, v2
; GFX6-NEXT:    v_or_b32_e32 v0, v0, v1
; GFX6-NEXT:    v_alignbit_b32 v1, v2, v1, 16
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_uaddsat_v3i16:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_add_u16_sdwa v4, v0, v2 clamp dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; GFX8-NEXT:    v_add_u16_e64 v0, v0, v2 clamp
; GFX8-NEXT:    v_add_u16_e64 v1, v1, v3 clamp
; GFX8-NEXT:    v_or_b32_e32 v0, v0, v4
; GFX8-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-LABEL: v_uaddsat_v3i16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_pk_add_u16 v1, v1, v3 clamp
; GFX9-NEXT:    v_pk_add_u16 v0, v0, v2 clamp
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX10-LABEL: v_uaddsat_v3i16:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX10-NEXT:    v_pk_add_u16 v0, v0, v2 clamp
; GFX10-NEXT:    v_pk_add_u16 v1, v1, v3 clamp
; GFX10-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-LABEL: v_uaddsat_v3i16:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-NEXT:    v_pk_add_u16 v0, v0, v2 clamp
; GFX11-NEXT:    v_pk_add_u16 v1, v1, v3 clamp
; GFX11-NEXT:    s_setpc_b64 s[30:31]
  %result = call <3 x i16> @llvm.uadd.sat.v3i16(<3 x i16> %lhs, <3 x i16> %rhs)
  ret <3 x i16> %result
}

define <2 x float> @v_uaddsat_v4i16(<4 x i16> %lhs, <4 x i16> %rhs) {
; GFX6-LABEL: v_uaddsat_v4i16:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_and_b32_e32 v5, 0xffff, v5
; GFX6-NEXT:    v_and_b32_e32 v1, 0xffff, v1
; GFX6-NEXT:    v_and_b32_e32 v4, 0xffff, v4
; GFX6-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, v1, v5
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, v0, v4
; GFX6-NEXT:    v_min_u32_e32 v1, 0xffff, v1
; GFX6-NEXT:    v_and_b32_e32 v7, 0xffff, v7
; GFX6-NEXT:    v_and_b32_e32 v3, 0xffff, v3
; GFX6-NEXT:    v_and_b32_e32 v6, 0xffff, v6
; GFX6-NEXT:    v_and_b32_e32 v2, 0xffff, v2
; GFX6-NEXT:    v_min_u32_e32 v0, 0xffff, v0
; GFX6-NEXT:    v_lshlrev_b32_e32 v1, 16, v1
; GFX6-NEXT:    v_or_b32_e32 v0, v0, v1
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, v2, v6
; GFX6-NEXT:    v_add_i32_e32 v2, vcc, v3, v7
; GFX6-NEXT:    v_min_u32_e32 v2, 0xffff, v2
; GFX6-NEXT:    v_min_u32_e32 v1, 0xffff, v1
; GFX6-NEXT:    v_lshlrev_b32_e32 v2, 16, v2
; GFX6-NEXT:    v_or_b32_e32 v1, v1, v2
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_uaddsat_v4i16:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_add_u16_sdwa v4, v0, v2 clamp dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; GFX8-NEXT:    v_add_u16_e64 v0, v0, v2 clamp
; GFX8-NEXT:    v_add_u16_sdwa v2, v1, v3 clamp dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; GFX8-NEXT:    v_add_u16_e64 v1, v1, v3 clamp
; GFX8-NEXT:    v_or_b32_e32 v0, v0, v4
; GFX8-NEXT:    v_or_b32_e32 v1, v1, v2
; GFX8-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-LABEL: v_uaddsat_v4i16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_pk_add_u16 v0, v0, v2 clamp
; GFX9-NEXT:    v_pk_add_u16 v1, v1, v3 clamp
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX10-LABEL: v_uaddsat_v4i16:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX10-NEXT:    v_pk_add_u16 v0, v0, v2 clamp
; GFX10-NEXT:    v_pk_add_u16 v1, v1, v3 clamp
; GFX10-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-LABEL: v_uaddsat_v4i16:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-NEXT:    v_pk_add_u16 v0, v0, v2 clamp
; GFX11-NEXT:    v_pk_add_u16 v1, v1, v3 clamp
; GFX11-NEXT:    s_setpc_b64 s[30:31]
  %result = call <4 x i16> @llvm.uadd.sat.v4i16(<4 x i16> %lhs, <4 x i16> %rhs)
  %cast = bitcast <4 x i16> %result to <2 x float>
  ret <2 x float> %cast
}

define <2 x i32> @v_uaddsat_v2i32(<2 x i32> %lhs, <2 x i32> %rhs) {
; GFX6-LABEL: v_uaddsat_v2i32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_not_b32_e32 v4, v2
; GFX6-NEXT:    v_min_u32_e32 v0, v0, v4
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, v0, v2
; GFX6-NEXT:    v_not_b32_e32 v2, v3
; GFX6-NEXT:    v_min_u32_e32 v1, v1, v2
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, v1, v3
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_uaddsat_v2i32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_add_u32_e64 v0, s[4:5], v0, v2 clamp
; GFX8-NEXT:    v_add_u32_e64 v1, s[4:5], v1, v3 clamp
; GFX8-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-LABEL: v_uaddsat_v2i32:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_add_u32_e64 v0, v0, v2 clamp
; GFX9-NEXT:    v_add_u32_e64 v1, v1, v3 clamp
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX10-LABEL: v_uaddsat_v2i32:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX10-NEXT:    v_add_nc_u32_e64 v0, v0, v2 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v1, v1, v3 clamp
; GFX10-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-LABEL: v_uaddsat_v2i32:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-NEXT:    v_add_nc_u32_e64 v0, v0, v2 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v1, v1, v3 clamp
; GFX11-NEXT:    s_setpc_b64 s[30:31]
  %result = call <2 x i32> @llvm.uadd.sat.v2i32(<2 x i32> %lhs, <2 x i32> %rhs)
  ret <2 x i32> %result
}

define <3 x i32> @v_uaddsat_v3i32(<3 x i32> %lhs, <3 x i32> %rhs) {
; GFX6-LABEL: v_uaddsat_v3i32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_not_b32_e32 v6, v3
; GFX6-NEXT:    v_min_u32_e32 v0, v0, v6
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, v0, v3
; GFX6-NEXT:    v_not_b32_e32 v3, v4
; GFX6-NEXT:    v_min_u32_e32 v1, v1, v3
; GFX6-NEXT:    v_not_b32_e32 v3, v5
; GFX6-NEXT:    v_min_u32_e32 v2, v2, v3
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, v1, v4
; GFX6-NEXT:    v_add_i32_e32 v2, vcc, v2, v5
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_uaddsat_v3i32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_add_u32_e64 v0, s[4:5], v0, v3 clamp
; GFX8-NEXT:    v_add_u32_e64 v1, s[4:5], v1, v4 clamp
; GFX8-NEXT:    v_add_u32_e64 v2, s[4:5], v2, v5 clamp
; GFX8-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-LABEL: v_uaddsat_v3i32:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_add_u32_e64 v0, v0, v3 clamp
; GFX9-NEXT:    v_add_u32_e64 v1, v1, v4 clamp
; GFX9-NEXT:    v_add_u32_e64 v2, v2, v5 clamp
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX10-LABEL: v_uaddsat_v3i32:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX10-NEXT:    v_add_nc_u32_e64 v0, v0, v3 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v1, v1, v4 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v2, v2, v5 clamp
; GFX10-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-LABEL: v_uaddsat_v3i32:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-NEXT:    v_add_nc_u32_e64 v0, v0, v3 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v1, v1, v4 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v2, v2, v5 clamp
; GFX11-NEXT:    s_setpc_b64 s[30:31]
  %result = call <3 x i32> @llvm.uadd.sat.v3i32(<3 x i32> %lhs, <3 x i32> %rhs)
  ret <3 x i32> %result
}

define <4 x i32> @v_uaddsat_v4i32(<4 x i32> %lhs, <4 x i32> %rhs) {
; GFX6-LABEL: v_uaddsat_v4i32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_not_b32_e32 v8, v4
; GFX6-NEXT:    v_min_u32_e32 v0, v0, v8
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, v0, v4
; GFX6-NEXT:    v_not_b32_e32 v4, v5
; GFX6-NEXT:    v_min_u32_e32 v1, v1, v4
; GFX6-NEXT:    v_not_b32_e32 v4, v6
; GFX6-NEXT:    v_min_u32_e32 v2, v2, v4
; GFX6-NEXT:    v_not_b32_e32 v4, v7
; GFX6-NEXT:    v_min_u32_e32 v3, v3, v4
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, v1, v5
; GFX6-NEXT:    v_add_i32_e32 v2, vcc, v2, v6
; GFX6-NEXT:    v_add_i32_e32 v3, vcc, v3, v7
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_uaddsat_v4i32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_add_u32_e64 v0, s[4:5], v0, v4 clamp
; GFX8-NEXT:    v_add_u32_e64 v1, s[4:5], v1, v5 clamp
; GFX8-NEXT:    v_add_u32_e64 v2, s[4:5], v2, v6 clamp
; GFX8-NEXT:    v_add_u32_e64 v3, s[4:5], v3, v7 clamp
; GFX8-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-LABEL: v_uaddsat_v4i32:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_add_u32_e64 v0, v0, v4 clamp
; GFX9-NEXT:    v_add_u32_e64 v1, v1, v5 clamp
; GFX9-NEXT:    v_add_u32_e64 v2, v2, v6 clamp
; GFX9-NEXT:    v_add_u32_e64 v3, v3, v7 clamp
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX10-LABEL: v_uaddsat_v4i32:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX10-NEXT:    v_add_nc_u32_e64 v0, v0, v4 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v1, v1, v5 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v2, v2, v6 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v3, v3, v7 clamp
; GFX10-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-LABEL: v_uaddsat_v4i32:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-NEXT:    v_add_nc_u32_e64 v0, v0, v4 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v1, v1, v5 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v2, v2, v6 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v3, v3, v7 clamp
; GFX11-NEXT:    s_setpc_b64 s[30:31]
  %result = call <4 x i32> @llvm.uadd.sat.v4i32(<4 x i32> %lhs, <4 x i32> %rhs)
  ret <4 x i32> %result
}

define <8 x i32> @v_uaddsat_v8i32(<8 x i32> %lhs, <8 x i32> %rhs) {
; GFX6-LABEL: v_uaddsat_v8i32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_not_b32_e32 v16, v8
; GFX6-NEXT:    v_min_u32_e32 v0, v0, v16
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, v0, v8
; GFX6-NEXT:    v_not_b32_e32 v8, v9
; GFX6-NEXT:    v_min_u32_e32 v1, v1, v8
; GFX6-NEXT:    v_not_b32_e32 v8, v10
; GFX6-NEXT:    v_min_u32_e32 v2, v2, v8
; GFX6-NEXT:    v_not_b32_e32 v8, v11
; GFX6-NEXT:    v_min_u32_e32 v3, v3, v8
; GFX6-NEXT:    v_not_b32_e32 v8, v12
; GFX6-NEXT:    v_min_u32_e32 v4, v4, v8
; GFX6-NEXT:    v_not_b32_e32 v8, v13
; GFX6-NEXT:    v_min_u32_e32 v5, v5, v8
; GFX6-NEXT:    v_not_b32_e32 v8, v14
; GFX6-NEXT:    v_min_u32_e32 v6, v6, v8
; GFX6-NEXT:    v_not_b32_e32 v8, v15
; GFX6-NEXT:    v_min_u32_e32 v7, v7, v8
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, v1, v9
; GFX6-NEXT:    v_add_i32_e32 v2, vcc, v2, v10
; GFX6-NEXT:    v_add_i32_e32 v3, vcc, v3, v11
; GFX6-NEXT:    v_add_i32_e32 v4, vcc, v4, v12
; GFX6-NEXT:    v_add_i32_e32 v5, vcc, v5, v13
; GFX6-NEXT:    v_add_i32_e32 v6, vcc, v6, v14
; GFX6-NEXT:    v_add_i32_e32 v7, vcc, v7, v15
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_uaddsat_v8i32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_add_u32_e64 v0, s[4:5], v0, v8 clamp
; GFX8-NEXT:    v_add_u32_e64 v1, s[4:5], v1, v9 clamp
; GFX8-NEXT:    v_add_u32_e64 v2, s[4:5], v2, v10 clamp
; GFX8-NEXT:    v_add_u32_e64 v3, s[4:5], v3, v11 clamp
; GFX8-NEXT:    v_add_u32_e64 v4, s[4:5], v4, v12 clamp
; GFX8-NEXT:    v_add_u32_e64 v5, s[4:5], v5, v13 clamp
; GFX8-NEXT:    v_add_u32_e64 v6, s[4:5], v6, v14 clamp
; GFX8-NEXT:    v_add_u32_e64 v7, s[4:5], v7, v15 clamp
; GFX8-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-LABEL: v_uaddsat_v8i32:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_add_u32_e64 v0, v0, v8 clamp
; GFX9-NEXT:    v_add_u32_e64 v1, v1, v9 clamp
; GFX9-NEXT:    v_add_u32_e64 v2, v2, v10 clamp
; GFX9-NEXT:    v_add_u32_e64 v3, v3, v11 clamp
; GFX9-NEXT:    v_add_u32_e64 v4, v4, v12 clamp
; GFX9-NEXT:    v_add_u32_e64 v5, v5, v13 clamp
; GFX9-NEXT:    v_add_u32_e64 v6, v6, v14 clamp
; GFX9-NEXT:    v_add_u32_e64 v7, v7, v15 clamp
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX10-LABEL: v_uaddsat_v8i32:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX10-NEXT:    v_add_nc_u32_e64 v0, v0, v8 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v1, v1, v9 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v2, v2, v10 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v3, v3, v11 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v4, v4, v12 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v5, v5, v13 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v6, v6, v14 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v7, v7, v15 clamp
; GFX10-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-LABEL: v_uaddsat_v8i32:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-NEXT:    v_add_nc_u32_e64 v0, v0, v8 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v1, v1, v9 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v2, v2, v10 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v3, v3, v11 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v4, v4, v12 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v5, v5, v13 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v6, v6, v14 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v7, v7, v15 clamp
; GFX11-NEXT:    s_setpc_b64 s[30:31]
  %result = call <8 x i32> @llvm.uadd.sat.v8i32(<8 x i32> %lhs, <8 x i32> %rhs)
  ret <8 x i32> %result
}

define <16 x i32> @v_uaddsat_v16i32(<16 x i32> %lhs, <16 x i32> %rhs) {
; GFX6-LABEL: v_uaddsat_v16i32:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_not_b32_e32 v31, v16
; GFX6-NEXT:    v_min_u32_e32 v0, v0, v31
; GFX6-NEXT:    buffer_load_dword v31, off, s[0:3], s32
; GFX6-NEXT:    v_add_i32_e32 v0, vcc, v0, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v17
; GFX6-NEXT:    v_min_u32_e32 v1, v1, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v18
; GFX6-NEXT:    v_min_u32_e32 v2, v2, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v19
; GFX6-NEXT:    v_min_u32_e32 v3, v3, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v20
; GFX6-NEXT:    v_min_u32_e32 v4, v4, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v21
; GFX6-NEXT:    v_min_u32_e32 v5, v5, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v22
; GFX6-NEXT:    v_min_u32_e32 v6, v6, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v23
; GFX6-NEXT:    v_min_u32_e32 v7, v7, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v24
; GFX6-NEXT:    v_min_u32_e32 v8, v8, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v25
; GFX6-NEXT:    v_min_u32_e32 v9, v9, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v26
; GFX6-NEXT:    v_min_u32_e32 v10, v10, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v27
; GFX6-NEXT:    v_min_u32_e32 v11, v11, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v28
; GFX6-NEXT:    v_min_u32_e32 v12, v12, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v29
; GFX6-NEXT:    v_min_u32_e32 v13, v13, v16
; GFX6-NEXT:    v_not_b32_e32 v16, v30
; GFX6-NEXT:    v_min_u32_e32 v14, v14, v16
; GFX6-NEXT:    v_add_i32_e32 v1, vcc, v1, v17
; GFX6-NEXT:    v_add_i32_e32 v2, vcc, v2, v18
; GFX6-NEXT:    v_add_i32_e32 v3, vcc, v3, v19
; GFX6-NEXT:    v_add_i32_e32 v4, vcc, v4, v20
; GFX6-NEXT:    v_add_i32_e32 v5, vcc, v5, v21
; GFX6-NEXT:    v_add_i32_e32 v6, vcc, v6, v22
; GFX6-NEXT:    v_add_i32_e32 v7, vcc, v7, v23
; GFX6-NEXT:    v_add_i32_e32 v8, vcc, v8, v24
; GFX6-NEXT:    v_add_i32_e32 v9, vcc, v9, v25
; GFX6-NEXT:    v_add_i32_e32 v10, vcc, v10, v26
; GFX6-NEXT:    v_add_i32_e32 v11, vcc, v11, v27
; GFX6-NEXT:    v_add_i32_e32 v12, vcc, v12, v28
; GFX6-NEXT:    v_add_i32_e32 v13, vcc, v13, v29
; GFX6-NEXT:    v_add_i32_e32 v14, vcc, v14, v30
; GFX6-NEXT:    s_waitcnt vmcnt(0)
; GFX6-NEXT:    v_not_b32_e32 v16, v31
; GFX6-NEXT:    v_min_u32_e32 v15, v15, v16
; GFX6-NEXT:    v_add_i32_e32 v15, vcc, v15, v31
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_uaddsat_v16i32:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_add_u32_e64 v0, s[4:5], v0, v16 clamp
; GFX8-NEXT:    buffer_load_dword v16, off, s[0:3], s32
; GFX8-NEXT:    v_add_u32_e64 v1, s[4:5], v1, v17 clamp
; GFX8-NEXT:    v_add_u32_e64 v2, s[4:5], v2, v18 clamp
; GFX8-NEXT:    v_add_u32_e64 v3, s[4:5], v3, v19 clamp
; GFX8-NEXT:    v_add_u32_e64 v4, s[4:5], v4, v20 clamp
; GFX8-NEXT:    v_add_u32_e64 v5, s[4:5], v5, v21 clamp
; GFX8-NEXT:    v_add_u32_e64 v6, s[4:5], v6, v22 clamp
; GFX8-NEXT:    v_add_u32_e64 v7, s[4:5], v7, v23 clamp
; GFX8-NEXT:    v_add_u32_e64 v8, s[4:5], v8, v24 clamp
; GFX8-NEXT:    v_add_u32_e64 v9, s[4:5], v9, v25 clamp
; GFX8-NEXT:    v_add_u32_e64 v10, s[4:5], v10, v26 clamp
; GFX8-NEXT:    v_add_u32_e64 v11, s[4:5], v11, v27 clamp
; GFX8-NEXT:    v_add_u32_e64 v12, s[4:5], v12, v28 clamp
; GFX8-NEXT:    v_add_u32_e64 v13, s[4:5], v13, v29 clamp
; GFX8-NEXT:    v_add_u32_e64 v14, s[4:5], v14, v30 clamp
; GFX8-NEXT:    s_waitcnt vmcnt(0)
; GFX8-NEXT:    v_add_u32_e64 v15, s[4:5], v15, v16 clamp
; GFX8-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-LABEL: v_uaddsat_v16i32:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_add_u32_e64 v0, v0, v16 clamp
; GFX9-NEXT:    buffer_load_dword v16, off, s[0:3], s32
; GFX9-NEXT:    v_add_u32_e64 v1, v1, v17 clamp
; GFX9-NEXT:    v_add_u32_e64 v2, v2, v18 clamp
; GFX9-NEXT:    v_add_u32_e64 v3, v3, v19 clamp
; GFX9-NEXT:    v_add_u32_e64 v4, v4, v20 clamp
; GFX9-NEXT:    v_add_u32_e64 v5, v5, v21 clamp
; GFX9-NEXT:    v_add_u32_e64 v6, v6, v22 clamp
; GFX9-NEXT:    v_add_u32_e64 v7, v7, v23 clamp
; GFX9-NEXT:    v_add_u32_e64 v8, v8, v24 clamp
; GFX9-NEXT:    v_add_u32_e64 v9, v9, v25 clamp
; GFX9-NEXT:    v_add_u32_e64 v10, v10, v26 clamp
; GFX9-NEXT:    v_add_u32_e64 v11, v11, v27 clamp
; GFX9-NEXT:    v_add_u32_e64 v12, v12, v28 clamp
; GFX9-NEXT:    v_add_u32_e64 v13, v13, v29 clamp
; GFX9-NEXT:    v_add_u32_e64 v14, v14, v30 clamp
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_add_u32_e64 v15, v15, v16 clamp
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX10-LABEL: v_uaddsat_v16i32:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX10-NEXT:    buffer_load_dword v31, off, s[0:3], s32
; GFX10-NEXT:    v_add_nc_u32_e64 v0, v0, v16 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v1, v1, v17 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v2, v2, v18 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v3, v3, v19 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v4, v4, v20 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v5, v5, v21 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v6, v6, v22 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v7, v7, v23 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v8, v8, v24 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v9, v9, v25 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v10, v10, v26 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v11, v11, v27 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v12, v12, v28 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v13, v13, v29 clamp
; GFX10-NEXT:    v_add_nc_u32_e64 v14, v14, v30 clamp
; GFX10-NEXT:    s_waitcnt vmcnt(0)
; GFX10-NEXT:    v_add_nc_u32_e64 v15, v15, v31 clamp
; GFX10-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-LABEL: v_uaddsat_v16i32:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-NEXT:    scratch_load_b32 v31, off, s32
; GFX11-NEXT:    v_add_nc_u32_e64 v0, v0, v16 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v1, v1, v17 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v2, v2, v18 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v3, v3, v19 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v4, v4, v20 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v5, v5, v21 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v6, v6, v22 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v7, v7, v23 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v8, v8, v24 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v9, v9, v25 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v10, v10, v26 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v11, v11, v27 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v12, v12, v28 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v13, v13, v29 clamp
; GFX11-NEXT:    v_add_nc_u32_e64 v14, v14, v30 clamp
; GFX11-NEXT:    s_waitcnt vmcnt(0)
; GFX11-NEXT:    v_add_nc_u32_e64 v15, v15, v31 clamp
; GFX11-NEXT:    s_setpc_b64 s[30:31]
  %result = call <16 x i32> @llvm.uadd.sat.v16i32(<16 x i32> %lhs, <16 x i32> %rhs)
  ret <16 x i32> %result
}


define i64 @v_uaddsat_i64(i64 %lhs, i64 %rhs) {
; GFX6-LABEL: v_uaddsat_i64:
; GFX6:       ; %bb.0:
; GFX6-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX6-NEXT:    v_add_i32_e32 v2, vcc, v0, v2
; GFX6-NEXT:    v_addc_u32_e32 v3, vcc, v1, v3, vcc
; GFX6-NEXT:    v_cmp_lt_u64_e32 vcc, v[2:3], v[0:1]
; GFX6-NEXT:    v_cndmask_b32_e64 v0, v2, -1, vcc
; GFX6-NEXT:    v_cndmask_b32_e64 v1, v3, -1, vcc
; GFX6-NEXT:    s_setpc_b64 s[30:31]
;
; GFX8-LABEL: v_uaddsat_i64:
; GFX8:       ; %bb.0:
; GFX8-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX8-NEXT:    v_add_u32_e32 v2, vcc, v0, v2
; GFX8-NEXT:    v_addc_u32_e32 v3, vcc, v1, v3, vcc
; GFX8-NEXT:    v_cmp_lt_u64_e32 vcc, v[2:3], v[0:1]
; GFX8-NEXT:    v_cndmask_b32_e64 v0, v2, -1, vcc
; GFX8-NEXT:    v_cndmask_b32_e64 v1, v3, -1, vcc
; GFX8-NEXT:    s_setpc_b64 s[30:31]
;
; GFX9-LABEL: v_uaddsat_i64:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_add_co_u32_e32 v2, vcc, v0, v2
; GFX9-NEXT:    v_addc_co_u32_e32 v3, vcc, v1, v3, vcc
; GFX9-NEXT:    v_cmp_lt_u64_e32 vcc, v[2:3], v[0:1]
; GFX9-NEXT:    v_cndmask_b32_e64 v0, v2, -1, vcc
; GFX9-NEXT:    v_cndmask_b32_e64 v1, v3, -1, vcc
; GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX10-LABEL: v_uaddsat_i64:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX10-NEXT:    v_add_co_u32 v2, vcc_lo, v0, v2
; GFX10-NEXT:    v_add_co_ci_u32_e32 v3, vcc_lo, v1, v3, vcc_lo
; GFX10-NEXT:    v_cmp_lt_u64_e32 vcc_lo, v[2:3], v[0:1]
; GFX10-NEXT:    v_cndmask_b32_e64 v0, v2, -1, vcc_lo
; GFX10-NEXT:    v_cndmask_b32_e64 v1, v3, -1, vcc_lo
; GFX10-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-LABEL: v_uaddsat_i64:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-NEXT:    v_add_co_u32 v2, vcc_lo, v0, v2
; GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
; GFX11-NEXT:    v_add_co_ci_u32_e64 v3, null, v1, v3, vcc_lo
; GFX11-NEXT:    v_cmp_lt_u64_e32 vcc_lo, v[2:3], v[0:1]
; GFX11-NEXT:    v_cndmask_b32_e64 v0, v2, -1, vcc_lo
; GFX11-NEXT:    v_cndmask_b32_e64 v1, v3, -1, vcc_lo
; GFX11-NEXT:    s_setpc_b64 s[30:31]
  %result = call i64 @llvm.uadd.sat.i64(i64 %lhs, i64 %rhs)
  ret i64 %result
}

declare i8 @llvm.uadd.sat.i8(i8, i8) #0
declare i16 @llvm.uadd.sat.i16(i16, i16) #0
declare <2 x i16> @llvm.uadd.sat.v2i16(<2 x i16>, <2 x i16>) #0
declare <3 x i16> @llvm.uadd.sat.v3i16(<3 x i16>, <3 x i16>) #0
declare <4 x i16> @llvm.uadd.sat.v4i16(<4 x i16>, <4 x i16>) #0
declare i32 @llvm.uadd.sat.i32(i32, i32) #0
declare <2 x i32> @llvm.uadd.sat.v2i32(<2 x i32>, <2 x i32>) #0
declare <3 x i32> @llvm.uadd.sat.v3i32(<3 x i32>, <3 x i32>) #0
declare <4 x i32> @llvm.uadd.sat.v4i32(<4 x i32>, <4 x i32>) #0
declare <8 x i32> @llvm.uadd.sat.v8i32(<8 x i32>, <8 x i32>) #0
declare <16 x i32> @llvm.uadd.sat.v16i32(<16 x i32>, <16 x i32>) #0
declare i64 @llvm.uadd.sat.i64(i64, i64) #0

attributes #0 = { nounwind readnone speculatable willreturn }
