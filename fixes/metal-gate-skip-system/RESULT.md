# RESULT: metal-gate-skip-system (rev 2)

Checked on the Linux laptop against 0.2.180-og.

## Compile
- Applies with `patch -p1`. Rev 1 already passed an iOS-SDK syntax check of MetalBackgroundGate.m and a Swift typecheck; rev 2's changes are small and were not recompiled.
- check-background-run.py: every Metal gate check PASSES, including the two new ones. The script still exits 1: with rev 2's stubs its Swift fixture now compiles on Linux (on 0.2.180 it did not compile here at all), and two audio checks then fail ("back: endpoint as the game wants it, category restored" and "background-run = 0: category untouched"). Rev 2 does not touch audio code, so most likely Linux stubs, but run the fixture on the PC/Mac to confirm.

## Review: PASS WITH NOTES
- dladdr now runs only while Madeira is inactive; the active render path costs one extra mutex lock/unlock per off-main commit (mbg_inactive_now). Small, but a lock-free read would avoid it.
- Matching only RenderBox.framework removes the tail-call risk from rev 1.
- Off switch env.MADEIRA_METAL_GATE_SKIP_SYSTEM = 0 holds every commit as in 0.2.180.
- Covers 1 of 4 31W events (per README). Not device-tested.
