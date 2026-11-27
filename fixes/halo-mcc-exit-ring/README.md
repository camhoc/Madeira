# halo-mcc-exit-ring (FEX, LOG ONLY), rev=halo-mcc-exit-ring-1

Written Nov 25 2026 by thread "Get Halo MCC past Easy Anti-Cheat" (cmsg_01RYsSHVyBApabNeqTgzQudYEvDSiLfB9WWMHuwv8Jzog3). Base: 0.2.101 source. Status: WRITTEN, not queued (no REVIEW.md yet, not compiled, not device-tested).
Two patches. `halo-mcc-exit-ring-1.patch`: FEX folder (Source/Windows/ARM64EC/Module.cpp), one condition changed. `halo-mcc-exit-ring-2-ntdll.patch`: wine folder (dlls/ntdll/signal_arm64ec.c), ios_xp_exit_event only.

## Why
0.2.101 iPad, Halo MCC via The game + MCC-Win64-Shipping.exe + -no-eac: all DLLs load, a D3D11 device is created and destroyed twice, no window or frame, then the main thread calls NtTerminateProcess(exit_code=1) from MCC-Win64-Shipping.exe+0x2653be8 (run 3 log, sweep-0.2.101). Configs that changed nothing: X64_IMAGE_NOCOPY, -no-eac, DXMT_ENABLE_NVEXT, CPU_IDENTITY = 0. The game writes no UE log. The log shows "[crashmailer-exit-probe] ... blocks: no block ring on thread 0000", because the existing block ring (65536 blocks, dumped at a non-zero exit) is switched on only for Overwatch.exe.

## What it does
Switches the same ring on for MCC-Win64-Shipping.exe. At the exit the existing probe dumps the last blocks before the exit(1), which shows the code path that decided to quit. No other behaviour changes; 512 KB per thread extra memory for that exe only.

## Off switch
```
env.MADEIRA_HALO_EXIT_RING = 0
```
Also off with env.MADEIRA_BLOCK_RING = 0 or env.MADEIRA_EC_CRASHMAILER_DUMP = 0 (existing). Off = same as 0.2.101 except the thread id in the "no block ring" log line.

## Unchecked
- Not compiled. Host check: not run.
- ntdll gap: ios_xp_main_teb is the FIRST thread that read the switch (tid 0000 in the Halo log), not the thread that exits (0024). Patch 2 keeps the main-thread snapshot and, when another thread ends the process and has a ring, snapshots it too (reviewer's suggestion, REVIEW.md). Patch 2 has no switch: with MADEIRA_HALO_EXIT_RING = 0 no ring exists, so only one thread-id in the 'no block ring' line differs from 0.2.101. Whether thread 0000 gets a ring when the ring is on is unchecked; needs a device run. Not compiled.
- Needs a second-pass REVIEW.md by a fresh reviewer (GOLDEN-GAMES: touches the Overwatch ring path, so run OW2 once).

## Build step (not done here)
A new env switch must appear in ConfigCatalog.generated.swift: the build thread runs `build/tools/gen-config-catalog.py` (needs the git checkout) and includes the regenerated file; tests/host/check-config-catalog.py fails otherwise.
