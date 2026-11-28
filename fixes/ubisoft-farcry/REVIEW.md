# ubisoft-farcry (Far Cry 3/4 + Ubisoft Connect) — port of willfaust PR #615 (Russell Barton, rbarton124) to 0.2.180
Status: PORT STARTED, NOT COMPILED, NOT DEVICE-TESTED. Licence: Madeira's own (credit Russell Barton in notes). Patches: ../upstream-615-ubisoft-split/.
Online: willfaust/Madeira PR #615 (via fork-deep-scan; fork rbarton124/madeira); searched Wine bugs/CrossOver Far Cry 3 tips/ProtonDB 220240 (links: https://www.codeweavers.com/compatibility/crossover/tips/Ubisoft-Connect-Installer/far-cry-3 , https://protondb.com/app/220240 , https://list.winehq.org/archives/list/wine-bugs@list.winehq.org/thread/S34UXJPHNJLNAPVJDRTICC6RPBWQG7EM). Nothing there about iOS/FEX specifics; no open Wine/FEX PR checked beyond that. Search was light.
## What the series gives (author's own words, from the commit messages; device result = theirs on iPhone18,2, not ours)
FC3 and FC4 sign in via Ubisoft Connect and play (FC4 ~53 min at 40 fps). FC3 FEX 0x82 opcode crash (upc.exe, Get Help case) is already fixed in our FEX (INDEX).
## Applied to a scratch copy of 0.2.180 (wine zips merged), in order
Clean/auto: 0001 0002 0003 0004 0006* 0010 0011 0012 0013 0014 0016* 0019*; (*one hunk rejected). Hand-merged: 0007 (Ubisoft Chromium switches; off: env.MADEIRA_UBI_CEF = 0), 0015 (x64 data imports). Rejects left: 0005 gen-config-catalog (add xbox360 choice), 0006 process_ios.c hunk, 0008/0009 DockInstallers.swift, build.sh/docs. Test files for tests missing from the trimmed tree (laptop has full tree?).
## One approach per problem (Cameron's rule) — DROPPED
- 0017 OpenGL 32-bit strings: 0.2.180 already has [gl-wow64-patch] in build/ntdll-unix/build.sh. Do not apply.
- 0018 `inside()` external-folder part: 0.2.180 DockInstallers.inside already handles C:\External drive libraries. Only its one-time-install part may be worth keeping: unreviewed.
## CONFLICTS to resolve before queueing (checklist Conflicts section)
- Pool/JIT: 0002, 0004, 0012 (pool code-buffers, JIT pool) touch the same area as pool-reserve, jumbo-fit-pow2, pool-window-guard, pool-split-auto (Memory pool thread). Highest risk; hold until that thread signs off.
- 0005 PAD_MODE=xbox360 vs Controllers thread / Vuqar05 Steam Input port. FC4-only; hold.
- 0011/0013 GameRecommendations.swift + check-game-recommendations.py: join the hand-merge (fixture counts +3 titles / +3 lists... verify) with planet-crafter, cyberpunk-direct-start, subnautica2-engine-ini.
- 0010 wine pin bump (sleep/WaitOnAddress/DxDiag): conflicts with Cameron's "NO Wine update" call: split out the Wine fixes only, or drop.
- 0019 FEX split-lock: FEX patch number 0002 collides with existing name; rename. FEX rebuild = whole-build impact.
- MADEIRA_UBI_CEF edits two bytes of Ubisoft's libcef.dll in memory (Cameron decides, per README).
## Suggested order
1) Lists-only (0011+0013 minus unknown env lines) is NOT useful alone: lists depend on the engine env vars. 2) So smallest working unit = 0001,0007,0011,0013,0014,0015,0006 (KILL_REAP), 0010 pieces, 0019, and pool 0004/0012 last. iPad test: only games Cameron owns.
Next: laptop compile via build thread; Cameron decides on libcef edit and pool.

## Update 05:3xZ (coordinator's calls)
- jumbo-fit-pow2 is dropped (replaced by oversize-reserve-min-mb). 0002/0004/0012 sent to Memory pool thread; 0005 sent to Controllers thread. apply.sh skips them unless POOL=1 / PAD=1.
- 0010 split: wine pin bump dropped. The three Wine fixes (SLEEP_KERNEL_APC, WOA_RECHECK, dxdiagn DirectShow) are in wine/*.patch (git format-patch of willfaust/wine PR #77 commits 79aa8c7, 886feac, aaa3ae1, author Russell Barton); `git apply --check` passes on the 0.2.180 wine tree. Both env switches off by default. 0010's app-side hunks (catalog, WineProcessBridge.m) stay.
- FEX patch renamed to 0028-ios-split-lock-atomics-inline (done by apply.sh, README row updated).
- Hand merges (0007 Chromium switches, 0015 nocopy line, FEX README) in hand-merge.py. 0016/0017 OpenGL build.sh note and docs hunks dropped (0.2.180 has its own gl-wow64-patch).
- Still open: lists 0011/0013 reference env vars from the held pool/pad patches (unproven whether unknown env lines are harmless); Cameron's libcef call; Far Cry ownership for iPad test.

- 05:29Z Controllers thread: 0005 does NOT clash with the pad patches; apply it by default (hand-merge of the PAD_MODE catalog choice is in hand-merge.py). 0003 (self-write) is the single approach; the Steam Input port will not bring its own copy.
