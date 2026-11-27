# D3D12: MakeResident / Evict succeed (RE4 "Fatal D3D error ... E_NOTIMPL")

Online: Capcom's "Fatal D3D error" is mostly a Windows driver/VRAM message in the generic guides (Prima Games, NVIDIA forum), none for E_NOTIMPL; the precedent is in our own tree: Ghost of Tsushima read E_NOTIMPL from GetDeviceRemovedReason as "device removed" (fixed in madeira_d3d12.c, comment above device_GetDeviceRemovedReason).

## Evidence (RE4 0.2.180 iPad, after New Game; re4.exe-2026-11-27_07-10-57.txt, PC session's extract)
- line 382381 "[madeira-d3d12] unimplemented: ID3D12Device10::Evict", near the end of rendering; then 382603 "Queue::Wait: fence never reached 34655 in 5 s; continuing".
- The dialog is "Fatal D3D error (3, E_NOTIMPL, 0x80004001)". The stub for Evict (madeira_d3d12_stubs.h:149) returns E_NOTIMPL. That the dialog comes from this call is UNPROVEN (the dialog text is not in the log).
- Other d3d12 lines in that run (not addressed here): CreatePipelineState "stream carried no VS and no CS; refused" x2; geometry pipeline FAILED CoarseAO_GS x2; "draw without a pipeline state; skipped"; ResourceBarrier-unrelated; ID3D12Resource2::GetHeapProperties unimplemented (early, harmless so far).

## Change
madeira-d3d12/src/pe/madeira_d3d12.c: device_MakeResident and device_Evict return S_OK (unified memory: everything is resident, nothing pages), assigned in the device vtable next to SetResidencyPriority. Same file, no other.
Off switch: game config `residency-noop = 0` puts the E_NOTIMPL stubs back (and the "[madeira-d3d12] unimplemented" log line).

## Test
RE4 New Game on a build with this: does the Fatal D3D error still show? Look for the absence of "unimplemented: ID3D12Device10::Evict". If the error remains with a different call named, that is the next one. Needs a madeira-d3d12 rebuild (build thread).
