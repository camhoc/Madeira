# RESULT: arm64ec-acquire-release

Checked on the Linux laptop against 0.2.180-og.

## Compile
Applies with `git apply -p1` in wine/. Compiled a small test (WriteRelease/ReadAcquire and the 64-bit forms) against wine/include with llvm-mingw 20260421, before and after:
- arm64ec, before: plain `str` / `ldr` (no ordering).
- arm64ec, after: `stlr` / `ldar` (release store / acquire load), as intended.
- x86_64: generated code identical before and after (same hash). i386 is outside the changed condition.
The Wine tree itself was not built.

## Review: PASS
- The change only moves ARM64EC from the x86 branch (plain access + compiler barrier, correct only under x86 ordering) to the generic __atomic branch, which the ARM/ARM64 builds already use. On ARM64's weak memory model the old code could let RtlRunOnce, barriers, LFH flags or overlapped-I/O status be seen out of order, as README says.
- Blast radius: every ARM64EC module compiled from Wine's include/winnt.h that uses ReadAcquire*/WriteRelease*/ReadNoFence*/WriteNoFence* (ntdll, kernelbase, msvcp/concrt and others) once rebuilt. Native unix side (__aarch64__) and x64 code run by FEX are unaffected. Cost: ldar/stlr instead of ldr/str: tiny.
- The C_ASSERT size check of the x86 branch is gone for ARM64EC (the generic branch never had it): fine.
- No run-time off switch (header macros): reverting is the off switch, as README says. The whole Wine ARM64EC side must be rebuilt for it to take effect.
- That any game is helped is unproven.
