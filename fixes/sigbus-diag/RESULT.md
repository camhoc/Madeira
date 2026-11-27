# RESULT: sigbus-diag

**PASS (review) / NEEDS-DEVICE**

Checked 2026-11-27 on Linux against the 0.2.180-og source zip.

## What was run
Patch is already applied in the 0.2.180-og tree (reverse-apply check succeeds). Code read only: the touched module was NOT built and nothing ran on a device.

## Findings
- Pair decode and format arguments are correct; the ntdll block is attached correctly and honours the off switch.
- Note: the SMC path now calls NtQueryVirtualMemory under ThreadCreationMutex.
