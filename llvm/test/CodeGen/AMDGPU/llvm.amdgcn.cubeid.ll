; RUN: llc -mtriple=amdgcn -mcpu=tahiti < %s | FileCheck -check-prefix=GCN %s
; RUN: llc -mtriple=amdgcn -mcpu=fiji < %s | FileCheck -check-prefix=GCN %s

declare float @llvm.amdgcn.cubeid(float, float, float) #0

; GCN-LABEL: {{^}}test_cubeid:
; GCN: v_cubeid_f32 v{{[0-9]+}}, s{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
define amdgpu_kernel void @test_cubeid(ptr addrspace(1) %out, float %a, float %b, float %c) #1 {
  %result = call float @llvm.amdgcn.cubeid(float %a, float %b, float %c)
  store float %result, ptr addrspace(1) %out
  ret void
}

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind }
