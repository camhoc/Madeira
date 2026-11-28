# dock-eac-offline (app, Swift), rev=dock-eac-offline-2

Written Nov 26 2026 by thread "Get Halo MCC past Easy Anti-Cheat" (cmsg_01RYsSHVyBApabNeqTgzQudYEvDSiLfB9WWMHuwv8Jzog3), for the coordinator's rule-0(c) request. Base 0.2.101. Status: WRITTEN. Not compiled (no Swift compiler here), not device-tested, REVIEW.md written, OK to queue (second review Nov 26). Patch: dock-eac-offline-2.patch (patch -p1 from the source root): app/Madeira/DockStartProgram.swift and MadeiraApp.swift. Changes after the first review: the file stays Foundation-only (the switch is a closure set in MadeiraApp.init, so tests/host/check-dock-start-program.py still compiles it alone); the path is Game/eldenring.exe.

## Why
Online EAC cannot run on iOS: Halo run 4 log shows EAC's bootstrapper calling NtAllocateVirtualMemory at 0x700100000000, 0x700200000000 ... 0x700a00000000 (ten times); each fails c0000018, then "Failed to initialize Wine helper buffer"; user space is capped at 0x8000000000 (log ml990). DroidDeck #1197 reports the same wall. The legitimate route is the game's own offline start. Madeira Dock's "Steam starts" (Game details > Steam) already swaps Steam's launch program for a chosen exe in the folder, and keeps Valve's client running, so SteamAPI still works (a direct "The game" start of Elden Ring exits 0 with "SteamAPI_IsSteamRunning() did not locate a running instance of Steam", iPad thread, 0.2.101).

## What it does
Adds a small table `eacOffline` (Elden Ring 1245620 -> Game/eldenring.exe) beside the existing `recommended` table (Rust, Assetto Corsa). Same mechanism, same apply()/restore code. A game with no stored choice gets that exe as its "Steam starts" program; picking Steam's own program turns it off for that game.

Not covered: Halo MCC. Its game exe lives in MCC/Binaries/Win64 and finds its DLLs next to itself, so a copy under mcclauncher.exe's name fails with c0000135 (run 2, eight DLLs missing). Halo's route stays "The game" + -no-eac, which has no Steam client and exits 1 by itself (cause unproven).

## Off switch
```
env.MADEIRA_DOCK_START_EAC_OFFLINE = 0
```
(madeira.cfg or process env; any value but 0 = on). Off = 0.2.101 behaviour. The per-game way off is picking Steam's own program.

## Code origin
Own code; DroidDeck PR #1039's idea only (it reads EasyAntiCheat/Settings.json). Its licence was not checked, nothing copied.

## Unchecked
- Checked by the iPad thread (Nov 26): Steam's launch entry is Game/start_protected_game.exe. That eldenring.exe sits beside it in Game/ is likely, not seen.
- Whether Elden Ring, started this way, gets past its own checks offline (it exited 0 in a direct start only because Steam was not running).
- Compile. A game with an EAC bootstrapper copy swapped by the exe is restored when the choice is cleared (existing code).
- Offline only: no online play. Verify-files in Steam restores the original launcher.

## Notes from review
- Off switch: a stored explicit choice (also Get Help's Undo, which stores the name) stays when the switch is turned off. An existing default swap is put back at the next Dock start.
- The Game details row and Get Help report show the default as if chosen.
- Golden games for this file: 7 Days to Die, Fallout: New Vegas (both use chosen()/apply()), Rust and Assetto Corsa if available, then Elden Ring.

## Build step (not done here)
A new env switch must appear in ConfigCatalog.generated.swift: the build thread runs `build/tools/gen-config-catalog.py` (needs the git checkout) and includes the regenerated file; tests/host/check-config-catalog.py fails otherwise.
