# metal-gate-skip-system (Nov 28, Sentry GET-HELP-LOGS-31W, 0x8BADF00D on leaving Madeira)
Online: nothing found for this exact symptom (standard search); fix is from our own stack. Open/merged PR check NOT run: Madeira-only code, no upstream involved.

## Evidence (quoted from Sentry event 3c0e7cdd7d96468fad4023f3b894e009, iPhone16,2, 0.2.180)
- `scene-update watchdog transgression ... exhausted real (wall clock) time allowance of 10.00 seconds`, `WatchdogVisibility: Background`.
- Log trail: `[app] Madeira is inactive` 13:26:35, `[app] Madeira is in the background` 13:26:41; killed ~5 s later.
- Thread 1: `Madeira +0x52bb4 mbg_wait + 184` <- `Madeira +0x52ac0 mbg_commit + 288` <- `RenderBox +0x2f228`. That is MetalBackgroundGate.m holding SwiftUI's own render thread.
- Crashed (main) thread: scene update in UIKitCore, blocked in `libdispatch` called from `RenderBox +0x797d8`: main waits on RenderBox, RenderBox waits in mbg_wait for DidBecomeActive.
Cause chain: the gate waits on EVERY non-main thread's -[MTLCommandBuffer commit] while inactive, including RenderBox's. Installed at app start (BackgroundRun.start), not only during a game.

## Fix
MetalBackgroundGate.m: when the commit's caller (return address, dladdr) is an Apple system image (/System/, /usr/lib/), do not wait. Game threads (MoltenVK, DXMT, Mesa, Wine, all in Madeira's own image) still wait as before.
Off switch: `env.MADEIRA_METAL_GATE_SKIP_SYSTEM = 0` restores 0.2.180 behaviour (default 1). `background-gpu-gate = 0` still leaves the whole gate out.

## Not covered (other 31W events, causes UNPROVEN)
- af239808 (iPhone, process-exit "Failed to terminate gracefully after 5.0s"): main idle in run loop; thread 3 in StikJITHelper.detachDebugger -> LogStore.log (session start). Not explained by this fix.
- 041e4539 (iPad, process-exit): main in SwiftUI layout, 5 DepotDownloader.write threads running. Not explained.
- 204bb8b1 (iPad13,18, scene-update "stuck", foreground): main idle, thread 5 `cap_main` (BackgroundCPUCap). Not explained.
- BO3 black window after the game kills itself: no link found in these stacks (none involve the gate or app inactivity). Unproven either way.
