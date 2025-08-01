; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn -mcpu=gfx900 < %s | FileCheck -enable-var-scope --check-prefix=GFX9 %s
; RUN: llc -mtriple=amdgcn -mcpu=tonga < %s | FileCheck -enable-var-scope --check-prefix=VI %s
; RUN: llc -mtriple=amdgcn -mcpu=bonaire < %s | FileCheck -enable-var-scope --check-prefix=CI %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx1010 < %s | FileCheck -enable-var-scope --check-prefix=GFX10 %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx1100 < %s | FileCheck -enable-var-scope --check-prefix=GFX11 %s

define amdgpu_kernel void @s_lshr_v2i16(ptr addrspace(1) %out, <2 x i16> %lhs, <2 x i16> %rhs) #0 {
; GFX9-LABEL: s_lshr_v2i16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX9-NEXT:    v_mov_b32_e32 v0, 0
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v1, s2
; GFX9-NEXT:    v_pk_lshrrev_b16 v1, s3, v1
; GFX9-NEXT:    global_store_dword v0, v1, s[0:1]
; GFX9-NEXT:    s_endpgm
;
; VI-LABEL: s_lshr_v2i16:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    s_lshr_b32 s4, s3, 16
; VI-NEXT:    s_lshr_b32 s5, s2, 16
; VI-NEXT:    s_and_b32 s2, s2, 0xffff
; VI-NEXT:    s_lshr_b32 s4, s5, s4
; VI-NEXT:    s_lshr_b32 s2, s2, s3
; VI-NEXT:    s_lshl_b32 s3, s4, 16
; VI-NEXT:    s_or_b32 s2, s2, s3
; VI-NEXT:    v_mov_b32_e32 v0, s0
; VI-NEXT:    v_mov_b32_e32 v1, s1
; VI-NEXT:    v_mov_b32_e32 v2, s2
; VI-NEXT:    flat_store_dword v[0:1], v2
; VI-NEXT:    s_endpgm
;
; CI-LABEL: s_lshr_v2i16:
; CI:       ; %bb.0:
; CI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; CI-NEXT:    s_mov_b32 s7, 0xf000
; CI-NEXT:    s_mov_b32 s6, -1
; CI-NEXT:    s_waitcnt lgkmcnt(0)
; CI-NEXT:    s_mov_b32 s4, s0
; CI-NEXT:    s_mov_b32 s5, s1
; CI-NEXT:    s_and_b32 s0, s2, 0xffff
; CI-NEXT:    s_lshr_b32 s1, s2, 16
; CI-NEXT:    s_lshr_b32 s2, s3, 16
; CI-NEXT:    s_lshr_b32 s1, s1, s2
; CI-NEXT:    s_lshl_b32 s1, s1, 16
; CI-NEXT:    s_lshr_b32 s0, s0, s3
; CI-NEXT:    s_or_b32 s0, s0, s1
; CI-NEXT:    v_mov_b32_e32 v0, s0
; CI-NEXT:    buffer_store_dword v0, off, s[4:7], 0
; CI-NEXT:    s_endpgm
;
; GFX10-LABEL: s_lshr_v2i16:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX10-NEXT:    v_mov_b32_e32 v0, 0
; GFX10-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-NEXT:    v_pk_lshrrev_b16 v1, s3, s2
; GFX10-NEXT:    global_store_dword v0, v1, s[0:1]
; GFX10-NEXT:    s_endpgm
;
; GFX11-LABEL: s_lshr_v2i16:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_load_b128 s[0:3], s[4:5], 0x24
; GFX11-NEXT:    v_mov_b32_e32 v0, 0
; GFX11-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-NEXT:    v_pk_lshrrev_b16 v1, s3, s2
; GFX11-NEXT:    global_store_b32 v0, v1, s[0:1]
; GFX11-NEXT:    s_endpgm
  %result = lshr <2 x i16> %lhs, %rhs
  store <2 x i16> %result, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @v_lshr_v2i16(ptr addrspace(1) %out, ptr addrspace(1) %in) #0 {
; GFX9-LABEL: v_lshr_v2i16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX9-NEXT:    v_lshlrev_b32_e32 v2, 2, v0
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[0:1], v2, s[2:3]
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_pk_lshrrev_b16 v0, v1, v0
; GFX9-NEXT:    global_store_dword v2, v0, s[0:1]
; GFX9-NEXT:    s_endpgm
;
; VI-LABEL: v_lshr_v2i16:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; VI-NEXT:    v_lshlrev_b32_e32 v2, 2, v0
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s3
; VI-NEXT:    v_add_u32_e32 v0, vcc, s2, v2
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dwordx2 v[0:1], v[0:1]
; VI-NEXT:    v_mov_b32_e32 v3, s1
; VI-NEXT:    v_add_u32_e32 v2, vcc, s0, v2
; VI-NEXT:    v_addc_u32_e32 v3, vcc, 0, v3, vcc
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    v_lshrrev_b16_e32 v4, v1, v0
; VI-NEXT:    v_lshrrev_b16_sdwa v0, v1, v0 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; VI-NEXT:    v_or_b32_e32 v0, v4, v0
; VI-NEXT:    flat_store_dword v[2:3], v0
; VI-NEXT:    s_endpgm
;
; CI-LABEL: v_lshr_v2i16:
; CI:       ; %bb.0:
; CI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; CI-NEXT:    s_mov_b32 s7, 0xf000
; CI-NEXT:    s_mov_b32 s6, 0
; CI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; CI-NEXT:    v_mov_b32_e32 v1, 0
; CI-NEXT:    s_waitcnt lgkmcnt(0)
; CI-NEXT:    s_mov_b64 s[4:5], s[2:3]
; CI-NEXT:    buffer_load_dwordx2 v[2:3], v[0:1], s[4:7], 0 addr64
; CI-NEXT:    s_mov_b64 s[2:3], s[6:7]
; CI-NEXT:    s_waitcnt vmcnt(0)
; CI-NEXT:    v_lshrrev_b32_e32 v4, 16, v2
; CI-NEXT:    v_and_b32_e32 v2, 0xffff, v2
; CI-NEXT:    v_lshrrev_b32_e32 v5, 16, v3
; CI-NEXT:    v_lshrrev_b32_e32 v2, v3, v2
; CI-NEXT:    v_lshrrev_b32_e32 v3, v5, v4
; CI-NEXT:    v_lshlrev_b32_e32 v3, 16, v3
; CI-NEXT:    v_or_b32_e32 v2, v2, v3
; CI-NEXT:    buffer_store_dword v2, v[0:1], s[0:3], 0 addr64
; CI-NEXT:    s_endpgm
;
; GFX10-LABEL: v_lshr_v2i16:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX10-NEXT:    v_lshlrev_b32_e32 v2, 2, v0
; GFX10-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-NEXT:    global_load_dwordx2 v[0:1], v2, s[2:3]
; GFX10-NEXT:    s_waitcnt vmcnt(0)
; GFX10-NEXT:    v_pk_lshrrev_b16 v0, v1, v0
; GFX10-NEXT:    global_store_dword v2, v0, s[0:1]
; GFX10-NEXT:    s_endpgm
;
; GFX11-LABEL: v_lshr_v2i16:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_load_b128 s[0:3], s[4:5], 0x24
; GFX11-NEXT:    v_and_b32_e32 v0, 0x3ff, v0
; GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; GFX11-NEXT:    v_lshlrev_b32_e32 v2, 2, v0
; GFX11-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-NEXT:    global_load_b64 v[0:1], v2, s[2:3]
; GFX11-NEXT:    s_waitcnt vmcnt(0)
; GFX11-NEXT:    v_pk_lshrrev_b16 v0, v1, v0
; GFX11-NEXT:    global_store_b32 v2, v0, s[0:1]
; GFX11-NEXT:    s_endpgm
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %tid.ext = sext i32 %tid to i64
  %in.gep = getelementptr inbounds <2 x i16>, ptr addrspace(1) %in, i64 %tid.ext
  %out.gep = getelementptr inbounds <2 x i16>, ptr addrspace(1) %out, i64 %tid.ext
  %b_ptr = getelementptr <2 x i16>, ptr addrspace(1) %in.gep, i32 1
  %a = load <2 x i16>, ptr addrspace(1) %in.gep
  %b = load <2 x i16>, ptr addrspace(1) %b_ptr
  %result = lshr <2 x i16> %a, %b
  store <2 x i16> %result, ptr addrspace(1) %out.gep
  ret void
}

define amdgpu_kernel void @lshr_v_s_v2i16(ptr addrspace(1) %out, ptr addrspace(1) %in, <2 x i16> %sgpr) #0 {
; GFX9-LABEL: lshr_v_s_v2i16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX9-NEXT:    s_load_dword s6, s[4:5], 0x34
; GFX9-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v1, v0, s[2:3]
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_pk_lshrrev_b16 v1, s6, v1
; GFX9-NEXT:    global_store_dword v0, v1, s[0:1]
; GFX9-NEXT:    s_endpgm
;
; VI-LABEL: lshr_v_s_v2i16:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; VI-NEXT:    s_load_dword s4, s[4:5], 0x34
; VI-NEXT:    v_lshlrev_b32_e32 v2, 2, v0
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s3
; VI-NEXT:    v_add_u32_e32 v0, vcc, s2, v2
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dword v3, v[0:1]
; VI-NEXT:    v_mov_b32_e32 v1, s1
; VI-NEXT:    s_lshr_b32 s1, s4, 16
; VI-NEXT:    v_add_u32_e32 v0, vcc, s0, v2
; VI-NEXT:    v_mov_b32_e32 v2, s1
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    v_lshrrev_b16_e32 v4, s4, v3
; VI-NEXT:    v_lshrrev_b16_sdwa v2, v2, v3 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; VI-NEXT:    v_or_b32_e32 v2, v4, v2
; VI-NEXT:    flat_store_dword v[0:1], v2
; VI-NEXT:    s_endpgm
;
; CI-LABEL: lshr_v_s_v2i16:
; CI:       ; %bb.0:
; CI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; CI-NEXT:    s_load_dword s8, s[4:5], 0xd
; CI-NEXT:    s_mov_b32 s7, 0xf000
; CI-NEXT:    s_mov_b32 s6, 0
; CI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; CI-NEXT:    s_waitcnt lgkmcnt(0)
; CI-NEXT:    s_mov_b64 s[4:5], s[2:3]
; CI-NEXT:    v_mov_b32_e32 v1, 0
; CI-NEXT:    buffer_load_dword v2, v[0:1], s[4:7], 0 addr64
; CI-NEXT:    s_lshr_b32 s4, s8, 16
; CI-NEXT:    s_mov_b64 s[2:3], s[6:7]
; CI-NEXT:    s_waitcnt vmcnt(0)
; CI-NEXT:    v_lshrrev_b32_e32 v3, 16, v2
; CI-NEXT:    v_and_b32_e32 v2, 0xffff, v2
; CI-NEXT:    v_lshrrev_b32_e32 v3, s4, v3
; CI-NEXT:    v_lshrrev_b32_e32 v2, s8, v2
; CI-NEXT:    v_lshlrev_b32_e32 v3, 16, v3
; CI-NEXT:    v_or_b32_e32 v2, v2, v3
; CI-NEXT:    buffer_store_dword v2, v[0:1], s[0:3], 0 addr64
; CI-NEXT:    s_endpgm
;
; GFX10-LABEL: lshr_v_s_v2i16:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX10-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX10-NEXT:    s_load_dword s4, s[4:5], 0x34
; GFX10-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-NEXT:    global_load_dword v1, v0, s[2:3]
; GFX10-NEXT:    s_waitcnt vmcnt(0)
; GFX10-NEXT:    v_pk_lshrrev_b16 v1, s4, v1
; GFX10-NEXT:    global_store_dword v0, v1, s[0:1]
; GFX10-NEXT:    s_endpgm
;
; GFX11-LABEL: lshr_v_s_v2i16:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_load_b128 s[0:3], s[4:5], 0x24
; GFX11-NEXT:    v_and_b32_e32 v0, 0x3ff, v0
; GFX11-NEXT:    s_load_b32 s4, s[4:5], 0x34
; GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; GFX11-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX11-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-NEXT:    global_load_b32 v1, v0, s[2:3]
; GFX11-NEXT:    s_waitcnt vmcnt(0)
; GFX11-NEXT:    v_pk_lshrrev_b16 v1, s4, v1
; GFX11-NEXT:    global_store_b32 v0, v1, s[0:1]
; GFX11-NEXT:    s_endpgm
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %tid.ext = sext i32 %tid to i64
  %in.gep = getelementptr inbounds <2 x i16>, ptr addrspace(1) %in, i64 %tid.ext
  %out.gep = getelementptr inbounds <2 x i16>, ptr addrspace(1) %out, i64 %tid.ext
  %vgpr = load <2 x i16>, ptr addrspace(1) %in.gep
  %result = lshr <2 x i16> %vgpr, %sgpr
  store <2 x i16> %result, ptr addrspace(1) %out.gep
  ret void
}

define amdgpu_kernel void @lshr_s_v_v2i16(ptr addrspace(1) %out, ptr addrspace(1) %in, <2 x i16> %sgpr) #0 {
; GFX9-LABEL: lshr_s_v_v2i16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX9-NEXT:    s_load_dword s6, s[4:5], 0x34
; GFX9-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v1, v0, s[2:3]
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_pk_lshrrev_b16 v1, v1, s6
; GFX9-NEXT:    global_store_dword v0, v1, s[0:1]
; GFX9-NEXT:    s_endpgm
;
; VI-LABEL: lshr_s_v_v2i16:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; VI-NEXT:    s_load_dword s4, s[4:5], 0x34
; VI-NEXT:    v_lshlrev_b32_e32 v2, 2, v0
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s3
; VI-NEXT:    v_add_u32_e32 v0, vcc, s2, v2
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dword v3, v[0:1]
; VI-NEXT:    v_mov_b32_e32 v1, s1
; VI-NEXT:    s_lshr_b32 s1, s4, 16
; VI-NEXT:    v_add_u32_e32 v0, vcc, s0, v2
; VI-NEXT:    v_mov_b32_e32 v2, s1
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    v_lshrrev_b16_e64 v4, v3, s4
; VI-NEXT:    v_lshrrev_b16_sdwa v2, v3, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; VI-NEXT:    v_or_b32_e32 v2, v4, v2
; VI-NEXT:    flat_store_dword v[0:1], v2
; VI-NEXT:    s_endpgm
;
; CI-LABEL: lshr_s_v_v2i16:
; CI:       ; %bb.0:
; CI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; CI-NEXT:    s_load_dword s8, s[4:5], 0xd
; CI-NEXT:    s_mov_b32 s7, 0xf000
; CI-NEXT:    s_mov_b32 s6, 0
; CI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; CI-NEXT:    s_waitcnt lgkmcnt(0)
; CI-NEXT:    s_mov_b64 s[4:5], s[2:3]
; CI-NEXT:    v_mov_b32_e32 v1, 0
; CI-NEXT:    buffer_load_dword v2, v[0:1], s[4:7], 0 addr64
; CI-NEXT:    s_lshr_b32 s4, s8, 16
; CI-NEXT:    s_and_b32 s5, s8, 0xffff
; CI-NEXT:    s_mov_b64 s[2:3], s[6:7]
; CI-NEXT:    s_waitcnt vmcnt(0)
; CI-NEXT:    v_lshrrev_b32_e32 v3, 16, v2
; CI-NEXT:    v_lshr_b32_e32 v3, s4, v3
; CI-NEXT:    v_lshr_b32_e32 v2, s5, v2
; CI-NEXT:    v_lshlrev_b32_e32 v3, 16, v3
; CI-NEXT:    v_or_b32_e32 v2, v2, v3
; CI-NEXT:    buffer_store_dword v2, v[0:1], s[0:3], 0 addr64
; CI-NEXT:    s_endpgm
;
; GFX10-LABEL: lshr_s_v_v2i16:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX10-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX10-NEXT:    s_load_dword s4, s[4:5], 0x34
; GFX10-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-NEXT:    global_load_dword v1, v0, s[2:3]
; GFX10-NEXT:    s_waitcnt vmcnt(0)
; GFX10-NEXT:    v_pk_lshrrev_b16 v1, v1, s4
; GFX10-NEXT:    global_store_dword v0, v1, s[0:1]
; GFX10-NEXT:    s_endpgm
;
; GFX11-LABEL: lshr_s_v_v2i16:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_load_b128 s[0:3], s[4:5], 0x24
; GFX11-NEXT:    v_and_b32_e32 v0, 0x3ff, v0
; GFX11-NEXT:    s_load_b32 s4, s[4:5], 0x34
; GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; GFX11-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX11-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-NEXT:    global_load_b32 v1, v0, s[2:3]
; GFX11-NEXT:    s_waitcnt vmcnt(0)
; GFX11-NEXT:    v_pk_lshrrev_b16 v1, v1, s4
; GFX11-NEXT:    global_store_b32 v0, v1, s[0:1]
; GFX11-NEXT:    s_endpgm
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %tid.ext = sext i32 %tid to i64
  %in.gep = getelementptr inbounds <2 x i16>, ptr addrspace(1) %in, i64 %tid.ext
  %out.gep = getelementptr inbounds <2 x i16>, ptr addrspace(1) %out, i64 %tid.ext
  %vgpr = load <2 x i16>, ptr addrspace(1) %in.gep
  %result = lshr <2 x i16> %sgpr, %vgpr
  store <2 x i16> %result, ptr addrspace(1) %out.gep
  ret void
}

define amdgpu_kernel void @lshr_imm_v_v2i16(ptr addrspace(1) %out, ptr addrspace(1) %in) #0 {
; GFX9-LABEL: lshr_imm_v_v2i16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX9-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v1, v0, s[2:3]
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_pk_lshrrev_b16 v1, v1, 8 op_sel_hi:[1,0]
; GFX9-NEXT:    global_store_dword v0, v1, s[0:1]
; GFX9-NEXT:    s_endpgm
;
; VI-LABEL: lshr_imm_v_v2i16:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; VI-NEXT:    v_lshlrev_b32_e32 v2, 2, v0
; VI-NEXT:    v_mov_b32_e32 v4, 8
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s3
; VI-NEXT:    v_add_u32_e32 v0, vcc, s2, v2
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dword v3, v[0:1]
; VI-NEXT:    v_mov_b32_e32 v1, s1
; VI-NEXT:    v_add_u32_e32 v0, vcc, s0, v2
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    v_lshrrev_b16_e64 v2, v3, 8
; VI-NEXT:    v_lshrrev_b16_sdwa v3, v3, v4 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; VI-NEXT:    v_or_b32_e32 v2, v2, v3
; VI-NEXT:    flat_store_dword v[0:1], v2
; VI-NEXT:    s_endpgm
;
; CI-LABEL: lshr_imm_v_v2i16:
; CI:       ; %bb.0:
; CI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; CI-NEXT:    s_mov_b32 s7, 0xf000
; CI-NEXT:    s_mov_b32 s6, 0
; CI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; CI-NEXT:    v_mov_b32_e32 v1, 0
; CI-NEXT:    s_waitcnt lgkmcnt(0)
; CI-NEXT:    s_mov_b64 s[4:5], s[2:3]
; CI-NEXT:    buffer_load_dword v2, v[0:1], s[4:7], 0 addr64
; CI-NEXT:    s_mov_b64 s[2:3], s[6:7]
; CI-NEXT:    s_waitcnt vmcnt(0)
; CI-NEXT:    v_lshrrev_b32_e32 v3, 16, v2
; CI-NEXT:    v_lshr_b32_e32 v3, 8, v3
; CI-NEXT:    v_lshr_b32_e32 v2, 8, v2
; CI-NEXT:    v_lshlrev_b32_e32 v3, 16, v3
; CI-NEXT:    v_or_b32_e32 v2, v2, v3
; CI-NEXT:    buffer_store_dword v2, v[0:1], s[0:3], 0 addr64
; CI-NEXT:    s_endpgm
;
; GFX10-LABEL: lshr_imm_v_v2i16:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX10-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX10-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-NEXT:    global_load_dword v1, v0, s[2:3]
; GFX10-NEXT:    s_waitcnt vmcnt(0)
; GFX10-NEXT:    v_pk_lshrrev_b16 v1, v1, 8 op_sel_hi:[1,0]
; GFX10-NEXT:    global_store_dword v0, v1, s[0:1]
; GFX10-NEXT:    s_endpgm
;
; GFX11-LABEL: lshr_imm_v_v2i16:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_load_b128 s[0:3], s[4:5], 0x24
; GFX11-NEXT:    v_and_b32_e32 v0, 0x3ff, v0
; GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; GFX11-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX11-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-NEXT:    global_load_b32 v1, v0, s[2:3]
; GFX11-NEXT:    s_waitcnt vmcnt(0)
; GFX11-NEXT:    v_pk_lshrrev_b16 v1, v1, 8 op_sel_hi:[1,0]
; GFX11-NEXT:    global_store_b32 v0, v1, s[0:1]
; GFX11-NEXT:    s_endpgm
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %tid.ext = sext i32 %tid to i64
  %in.gep = getelementptr inbounds <2 x i16>, ptr addrspace(1) %in, i64 %tid.ext
  %out.gep = getelementptr inbounds <2 x i16>, ptr addrspace(1) %out, i64 %tid.ext
  %vgpr = load <2 x i16>, ptr addrspace(1) %in.gep
  %result = lshr <2 x i16> <i16 8, i16 8>, %vgpr
  store <2 x i16> %result, ptr addrspace(1) %out.gep
  ret void
}

define amdgpu_kernel void @lshr_v_imm_v2i16(ptr addrspace(1) %out, ptr addrspace(1) %in) #0 {
; GFX9-LABEL: lshr_v_imm_v2i16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX9-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v1, v0, s[2:3]
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_pk_lshrrev_b16 v1, 8, v1 op_sel_hi:[0,1]
; GFX9-NEXT:    global_store_dword v0, v1, s[0:1]
; GFX9-NEXT:    s_endpgm
;
; VI-LABEL: lshr_v_imm_v2i16:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; VI-NEXT:    v_lshlrev_b32_e32 v2, 2, v0
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s3
; VI-NEXT:    v_add_u32_e32 v0, vcc, s2, v2
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dword v3, v[0:1]
; VI-NEXT:    v_add_u32_e32 v0, vcc, s0, v2
; VI-NEXT:    v_mov_b32_e32 v1, s1
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    v_lshrrev_b32_e32 v2, 24, v3
; VI-NEXT:    v_lshlrev_b32_e32 v2, 16, v2
; VI-NEXT:    v_or_b32_sdwa v2, v3, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_1 src1_sel:DWORD
; VI-NEXT:    flat_store_dword v[0:1], v2
; VI-NEXT:    s_endpgm
;
; CI-LABEL: lshr_v_imm_v2i16:
; CI:       ; %bb.0:
; CI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; CI-NEXT:    s_mov_b32 s7, 0xf000
; CI-NEXT:    s_mov_b32 s6, 0
; CI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; CI-NEXT:    v_mov_b32_e32 v1, 0
; CI-NEXT:    s_waitcnt lgkmcnt(0)
; CI-NEXT:    s_mov_b64 s[4:5], s[2:3]
; CI-NEXT:    buffer_load_dword v2, v[0:1], s[4:7], 0 addr64
; CI-NEXT:    s_mov_b64 s[2:3], s[6:7]
; CI-NEXT:    s_waitcnt vmcnt(0)
; CI-NEXT:    v_lshrrev_b32_e32 v2, 8, v2
; CI-NEXT:    v_and_b32_e32 v2, 0xff00ff, v2
; CI-NEXT:    buffer_store_dword v2, v[0:1], s[0:3], 0 addr64
; CI-NEXT:    s_endpgm
;
; GFX10-LABEL: lshr_v_imm_v2i16:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX10-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX10-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-NEXT:    global_load_dword v1, v0, s[2:3]
; GFX10-NEXT:    s_waitcnt vmcnt(0)
; GFX10-NEXT:    v_pk_lshrrev_b16 v1, 8, v1 op_sel_hi:[0,1]
; GFX10-NEXT:    global_store_dword v0, v1, s[0:1]
; GFX10-NEXT:    s_endpgm
;
; GFX11-LABEL: lshr_v_imm_v2i16:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_load_b128 s[0:3], s[4:5], 0x24
; GFX11-NEXT:    v_and_b32_e32 v0, 0x3ff, v0
; GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; GFX11-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GFX11-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-NEXT:    global_load_b32 v1, v0, s[2:3]
; GFX11-NEXT:    s_waitcnt vmcnt(0)
; GFX11-NEXT:    v_pk_lshrrev_b16 v1, 8, v1 op_sel_hi:[0,1]
; GFX11-NEXT:    global_store_b32 v0, v1, s[0:1]
; GFX11-NEXT:    s_endpgm
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %tid.ext = sext i32 %tid to i64
  %in.gep = getelementptr inbounds <2 x i16>, ptr addrspace(1) %in, i64 %tid.ext
  %out.gep = getelementptr inbounds <2 x i16>, ptr addrspace(1) %out, i64 %tid.ext
  %vgpr = load <2 x i16>, ptr addrspace(1) %in.gep
  %result = lshr <2 x i16> %vgpr, <i16 8, i16 8>
  store <2 x i16> %result, ptr addrspace(1) %out.gep
  ret void
}

define amdgpu_kernel void @v_lshr_v4i16(ptr addrspace(1) %out, ptr addrspace(1) %in) #0 {
; GFX9-LABEL: v_lshr_v4i16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX9-NEXT:    v_lshlrev_b32_e32 v4, 3, v0
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx4 v[0:3], v4, s[2:3]
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_pk_lshrrev_b16 v1, v3, v1
; GFX9-NEXT:    v_pk_lshrrev_b16 v0, v2, v0
; GFX9-NEXT:    global_store_dwordx2 v4, v[0:1], s[0:1]
; GFX9-NEXT:    s_endpgm
;
; VI-LABEL: v_lshr_v4i16:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; VI-NEXT:    v_lshlrev_b32_e32 v4, 3, v0
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s3
; VI-NEXT:    v_add_u32_e32 v0, vcc, s2, v4
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dwordx4 v[0:3], v[0:1]
; VI-NEXT:    v_mov_b32_e32 v5, s1
; VI-NEXT:    v_add_u32_e32 v4, vcc, s0, v4
; VI-NEXT:    v_addc_u32_e32 v5, vcc, 0, v5, vcc
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    v_lshrrev_b16_e32 v6, v3, v1
; VI-NEXT:    v_lshrrev_b16_sdwa v1, v3, v1 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; VI-NEXT:    v_lshrrev_b16_e32 v3, v2, v0
; VI-NEXT:    v_lshrrev_b16_sdwa v0, v2, v0 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:WORD_1
; VI-NEXT:    v_or_b32_e32 v1, v6, v1
; VI-NEXT:    v_or_b32_e32 v0, v3, v0
; VI-NEXT:    flat_store_dwordx2 v[4:5], v[0:1]
; VI-NEXT:    s_endpgm
;
; CI-LABEL: v_lshr_v4i16:
; CI:       ; %bb.0:
; CI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; CI-NEXT:    s_mov_b32 s7, 0xf000
; CI-NEXT:    s_mov_b32 s6, 0
; CI-NEXT:    v_lshlrev_b32_e32 v4, 3, v0
; CI-NEXT:    v_mov_b32_e32 v5, 0
; CI-NEXT:    s_waitcnt lgkmcnt(0)
; CI-NEXT:    s_mov_b64 s[4:5], s[2:3]
; CI-NEXT:    buffer_load_dwordx4 v[0:3], v[4:5], s[4:7], 0 addr64
; CI-NEXT:    s_mov_b64 s[2:3], s[6:7]
; CI-NEXT:    s_waitcnt vmcnt(0)
; CI-NEXT:    v_lshrrev_b32_e32 v6, 16, v0
; CI-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; CI-NEXT:    v_lshrrev_b32_e32 v7, 16, v1
; CI-NEXT:    v_and_b32_e32 v1, 0xffff, v1
; CI-NEXT:    v_lshrrev_b32_e32 v8, 16, v2
; CI-NEXT:    v_lshrrev_b32_e32 v9, 16, v3
; CI-NEXT:    v_lshrrev_b32_e32 v1, v3, v1
; CI-NEXT:    v_lshrrev_b32_e32 v3, v9, v7
; CI-NEXT:    v_lshrrev_b32_e32 v0, v2, v0
; CI-NEXT:    v_lshrrev_b32_e32 v2, v8, v6
; CI-NEXT:    v_lshlrev_b32_e32 v3, 16, v3
; CI-NEXT:    v_lshlrev_b32_e32 v2, 16, v2
; CI-NEXT:    v_or_b32_e32 v1, v1, v3
; CI-NEXT:    v_or_b32_e32 v0, v0, v2
; CI-NEXT:    buffer_store_dwordx2 v[0:1], v[4:5], s[0:3], 0 addr64
; CI-NEXT:    s_endpgm
;
; GFX10-LABEL: v_lshr_v4i16:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX10-NEXT:    v_lshlrev_b32_e32 v4, 3, v0
; GFX10-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-NEXT:    global_load_dwordx4 v[0:3], v4, s[2:3]
; GFX10-NEXT:    s_waitcnt vmcnt(0)
; GFX10-NEXT:    v_pk_lshrrev_b16 v1, v3, v1
; GFX10-NEXT:    v_pk_lshrrev_b16 v0, v2, v0
; GFX10-NEXT:    global_store_dwordx2 v4, v[0:1], s[0:1]
; GFX10-NEXT:    s_endpgm
;
; GFX11-LABEL: v_lshr_v4i16:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_load_b128 s[0:3], s[4:5], 0x24
; GFX11-NEXT:    v_and_b32_e32 v0, 0x3ff, v0
; GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; GFX11-NEXT:    v_lshlrev_b32_e32 v4, 3, v0
; GFX11-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-NEXT:    global_load_b128 v[0:3], v4, s[2:3]
; GFX11-NEXT:    s_waitcnt vmcnt(0)
; GFX11-NEXT:    v_pk_lshrrev_b16 v1, v3, v1
; GFX11-NEXT:    v_pk_lshrrev_b16 v0, v2, v0
; GFX11-NEXT:    global_store_b64 v4, v[0:1], s[0:1]
; GFX11-NEXT:    s_endpgm
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %tid.ext = sext i32 %tid to i64
  %in.gep = getelementptr inbounds <4 x i16>, ptr addrspace(1) %in, i64 %tid.ext
  %out.gep = getelementptr inbounds <4 x i16>, ptr addrspace(1) %out, i64 %tid.ext
  %b_ptr = getelementptr <4 x i16>, ptr addrspace(1) %in.gep, i32 1
  %a = load <4 x i16>, ptr addrspace(1) %in.gep
  %b = load <4 x i16>, ptr addrspace(1) %b_ptr
  %result = lshr <4 x i16> %a, %b
  store <4 x i16> %result, ptr addrspace(1) %out.gep
  ret void
}

define amdgpu_kernel void @lshr_v_imm_v4i16(ptr addrspace(1) %out, ptr addrspace(1) %in) #0 {
; GFX9-LABEL: lshr_v_imm_v4i16:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX9-NEXT:    v_lshlrev_b32_e32 v2, 3, v0
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[0:1], v2, s[2:3]
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_pk_lshrrev_b16 v1, 8, v1 op_sel_hi:[0,1]
; GFX9-NEXT:    v_pk_lshrrev_b16 v0, 8, v0 op_sel_hi:[0,1]
; GFX9-NEXT:    global_store_dwordx2 v2, v[0:1], s[0:1]
; GFX9-NEXT:    s_endpgm
;
; VI-LABEL: lshr_v_imm_v4i16:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; VI-NEXT:    v_lshlrev_b32_e32 v2, 3, v0
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s3
; VI-NEXT:    v_add_u32_e32 v0, vcc, s2, v2
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dwordx2 v[0:1], v[0:1]
; VI-NEXT:    v_mov_b32_e32 v3, s1
; VI-NEXT:    v_add_u32_e32 v2, vcc, s0, v2
; VI-NEXT:    v_addc_u32_e32 v3, vcc, 0, v3, vcc
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    v_lshrrev_b32_e32 v4, 24, v1
; VI-NEXT:    v_lshrrev_b32_e32 v5, 24, v0
; VI-NEXT:    v_lshlrev_b32_e32 v4, 16, v4
; VI-NEXT:    v_lshlrev_b32_e32 v5, 16, v5
; VI-NEXT:    v_or_b32_sdwa v1, v1, v4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_1 src1_sel:DWORD
; VI-NEXT:    v_or_b32_sdwa v0, v0, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_1 src1_sel:DWORD
; VI-NEXT:    flat_store_dwordx2 v[2:3], v[0:1]
; VI-NEXT:    s_endpgm
;
; CI-LABEL: lshr_v_imm_v4i16:
; CI:       ; %bb.0:
; CI-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x9
; CI-NEXT:    s_mov_b32 s7, 0xf000
; CI-NEXT:    s_mov_b32 s6, 0
; CI-NEXT:    v_lshlrev_b32_e32 v0, 3, v0
; CI-NEXT:    v_mov_b32_e32 v1, 0
; CI-NEXT:    s_waitcnt lgkmcnt(0)
; CI-NEXT:    s_mov_b64 s[4:5], s[2:3]
; CI-NEXT:    buffer_load_dwordx2 v[2:3], v[0:1], s[4:7], 0 addr64
; CI-NEXT:    s_mov_b64 s[2:3], s[6:7]
; CI-NEXT:    s_waitcnt vmcnt(0)
; CI-NEXT:    v_lshrrev_b32_e32 v3, 8, v3
; CI-NEXT:    v_lshrrev_b32_e32 v2, 8, v2
; CI-NEXT:    v_and_b32_e32 v3, 0xff00ff, v3
; CI-NEXT:    v_and_b32_e32 v2, 0xff00ff, v2
; CI-NEXT:    buffer_store_dwordx2 v[2:3], v[0:1], s[0:3], 0 addr64
; CI-NEXT:    s_endpgm
;
; GFX10-LABEL: lshr_v_imm_v4i16:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x24
; GFX10-NEXT:    v_lshlrev_b32_e32 v2, 3, v0
; GFX10-NEXT:    s_waitcnt lgkmcnt(0)
; GFX10-NEXT:    global_load_dwordx2 v[0:1], v2, s[2:3]
; GFX10-NEXT:    s_waitcnt vmcnt(0)
; GFX10-NEXT:    v_pk_lshrrev_b16 v1, 8, v1 op_sel_hi:[0,1]
; GFX10-NEXT:    v_pk_lshrrev_b16 v0, 8, v0 op_sel_hi:[0,1]
; GFX10-NEXT:    global_store_dwordx2 v2, v[0:1], s[0:1]
; GFX10-NEXT:    s_endpgm
;
; GFX11-LABEL: lshr_v_imm_v4i16:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_load_b128 s[0:3], s[4:5], 0x24
; GFX11-NEXT:    v_and_b32_e32 v0, 0x3ff, v0
; GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; GFX11-NEXT:    v_lshlrev_b32_e32 v2, 3, v0
; GFX11-NEXT:    s_waitcnt lgkmcnt(0)
; GFX11-NEXT:    global_load_b64 v[0:1], v2, s[2:3]
; GFX11-NEXT:    s_waitcnt vmcnt(0)
; GFX11-NEXT:    v_pk_lshrrev_b16 v1, 8, v1 op_sel_hi:[0,1]
; GFX11-NEXT:    v_pk_lshrrev_b16 v0, 8, v0 op_sel_hi:[0,1]
; GFX11-NEXT:    global_store_b64 v2, v[0:1], s[0:1]
; GFX11-NEXT:    s_endpgm
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %tid.ext = sext i32 %tid to i64
  %in.gep = getelementptr inbounds <4 x i16>, ptr addrspace(1) %in, i64 %tid.ext
  %out.gep = getelementptr inbounds <4 x i16>, ptr addrspace(1) %out, i64 %tid.ext
  %vgpr = load <4 x i16>, ptr addrspace(1) %in.gep
  %result = lshr <4 x i16> %vgpr, <i16 8, i16 8, i16 8, i16 8>
  store <4 x i16> %result, ptr addrspace(1) %out.gep
  ret void
}

declare i32 @llvm.amdgcn.workitem.id.x() #1

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
