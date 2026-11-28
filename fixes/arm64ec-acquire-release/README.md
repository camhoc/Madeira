# arm64ec-acquire-release (Wine header, Nov 28 2026, fork deep scan thread)

rev `arm64ec-acquire-release-1` (patch `arm64ec-acquire-release-1.patch`). Wine only: `include/winnt.h`, 2 lines.
Base: the 0.2.180 Wine tree (`source/madeira-0.2.180`, zips unpacked; queue/wine-1203 14250a53). `git apply --check -p1` passes there.
Not compiled (no ARM64EC toolchain in the cloud container). Not device-tested.

**Credit / license:** Chad Cormier Roussel, Mac-Neutron/wine branch main, commit cc3ba790ac62a
("include: Use acquire/release for ReadAcquire and WriteRelease on ARM64EC", Oct 9 2026). Wine is LGPL-2.1-or-later. Not BCD. Not AGPL.

**Off switch:** none at run time. These are header macros compiled into every ARM64EC module.
Reverting the patch is the off switch. (REVIEW.md says why that is acceptable here.)

## What it fixes (by reading; unproven on our device)
ARM64EC code is compiled with `__x86_64__` defined. In our winnt.h (line 8467) the x86 branch of the
`__WINE_ATOMIC_*` macros is chosen by `#if defined(__x86_64__) || defined(__i386__)`, so on ARM64EC
`ReadAcquire`/`WriteRelease` (and the 64-bit and pointer forms) become plain loads/stores behind a
compiler barrier. That is correct under x86 TSO, but ARM64EC code runs natively on ARM64's weak memory
model. The patch excludes `__arm64ec__` (as InterlockedCompareExchange128 already does), so ARM64EC
gets `__atomic_load`/`__atomic_store` with acquire/release.

Sites the original commit names in ARM64EC code: RtlRunOnce's state word, RtlBarrier, the LFH bin's
enabled flag, GetOverlappedResult's status read, msvcp/concrt queue-lock unlock.

## Evidence for our games (honest)
UNPROVEN. No log line ties a failing game to this. It is a real ordering bug by reading, in code
every ARM64EC process runs, and the fix is the compiler's own atomics. Symptoms it could cause:
rare hangs or wrong results in one-time init (RtlRunOnce), barriers, overlapped I/O status.

## Test
Build the Wine PE side (ARM64EC). Then any sweep game; nothing should change except possibly fewer rare hangs.
Disassembly check: ReadAcquire in an ARM64EC ntdll function (e.g. RtlRunOnceBeginInitialize) should be `ldar`, not `ldr`.
