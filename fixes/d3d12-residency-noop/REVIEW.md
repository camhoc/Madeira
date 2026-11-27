# REVIEW: d3d12-residency-noop
Second review (fresh reviewer, code only): PASS WITH NOTES. Read-through and patch --dry-run; not compiled.
- Compile: mad_cfg_int_pe declared at madeira_d3d12.c:993 before use; stubs header included; vtable fields and signatures match madeira_d3d12_stubs.h:145-152, 355-356.
- Order: madeira_fill_ID3D12Device10 runs first, implemented methods assigned after; nothing reassigns MakeResident/Evict. Only one device vtable in the PE path.
- No host test asserts these stay stubs. Optional: a static check in the style of check-d3d12-optin-stubs.py.
- Semantics: S_OK is right on unified memory (SetResidencyPriority already does the same). Limitation: a game that probes MakeResident for E_OUTOFMEMORY never sees it.
- Notes: dxmt/src/d3d12/d3d12_device.cpp:704 Evict still returns E_NOTIMPL (separate implementation, not the Madeira PE path, out of scope). That the E_NOTIMPL from Evict is what shows RE4's dialog is UNPROVEN.
