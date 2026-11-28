# REVIEW - metal-gate-skip-system
Author check (Nov 28): patch dry-run clean on 0.2.180 source; dladdr/strncmp snippet syntax-checked on host (gcc). NOT built with the iOS toolchain; Obj-C/Swift untested on device.
Off switch: env.MADEIRA_METAL_GATE_SKIP_SYSTEM = 0. Default ON (it only stops holding Apple's own threads).
Known gap (rev 2): test not run here; only RenderBox callers skip the wait; ConfigCatalog entry needed. Laptop FAIL items 1-3 addressed (see README rev 2).
Test on device: leave Madeira to the Home screen from the library and from a game, 5 times; no 0x8BADF00D; `[metal-bg] ... waits` lines still appear for game threads.
Second review: laptop compile check + review after the build thread pushes it as fix/metal-gate-skip-system (Cameron, Nov 28).
