# iPad sweep, Madeira Nightly 0.2.180, started Nov 26 2026 9:46 PM MT

Rules: every installed game once, screenshots in screens\<game>\, StarCraft/Overwatch launchers and Battle.net installer skipped, no EULAs or terms accepted. Per-game settings are whatever the iPad had.

Requiem (install only): resumed 9:34 PM; its file check sat at 7% (3.95 of 50.3 GB) from 9:37 to 9:44 PM with no log line after the 9:34:21 "install begin ... resume=1" (requiem-check-stuck.txt). At 9:45 a search for "requiem" showed "No Results" (cause not checked). Left alone until the sweep ends.

| # | Game | Result | Note |
|---|---|---|---|
| 1 | Black Ops III | Black window, nothing drawn by 2.5 min | 21:46 |
| 2 | Baldur's Gate 3 | WORKS: title "Press any key to continue" in about 3 min | 21:49 |
| 3 | Halo MCC | Stopped at error box | "Easy Anti-Cheat Launch Error: Failed to initialize Wine helper buffer" |
| 4 | Detroit | Shader compile screen, still 0% after 3.5 min | graphics-card box accepted with OK first; 0 FPS, 4.5 GB |
| 5 | tModLoader | Stops at error box | "Please ensure Steam is logged in and running." (starts without the Steam step) |
| 6 | Left 4 Dead 2 | WORKS to intro movie (about 2 min) | menu not waited for |
| 7 | Dave the Diver | WORKS: main menu within 80 s | |
| 8 | Raft | Never opened a window: "Waiting for its window..." for 3.3 min | Steam step passed |
| 9 | LEGO Star Wars Complete Saga | WORKS: title and intro/attract scenes within 40 s | |
| 10 | Besiege | WORKS: main menu by 100 s | |
| 11 | Megabonk | WORKS to the photosensitivity warning (Confirm) within 40 s | menu not opened |
| 12 | Stardew Valley | WORKS: main menu by 100 s | |
| 13 | Batman Arkham Asylum | WORKS: launcher, PLAY, "CLICK TO START" title | |
| 14 | Borderlands 2 | WORKS: launcher, PLAY, "Press any key" title | |
| 15 | Resident Evil 4 | WORKS to "Initial Settings" screen in under 2 min | pool-low lines still in its config; Confirm not pressed |
| 16 | Slay the Spire 2 | WORKS: main menu by 100 s | "Launch anyway" on the cloud saves box |
| 17 | Undertale | WORKS: intro playing within 30 s | |
| 18 | ULTRAKILL | WORKS: first-run audio calibration screen by 100 s | left as is |
| 19 | The Escapists 2 | WORKS: menu scenes, DLC notice, by 80 s | |

## Paused 11:13 PM MT (the owner: connecting a controller)
Games 1-19 done. Not yet run: Terraria onward. From the next game on: in-game input check (their rule, 11:10 PM). Revisit BG3, L4D2, Dave the Diver, LEGO Star Wars, Besiege with input if time allows. Zomboid tests 8/9 still queued.
Controller (11:13-11:16 PM): "Xbox Wireless Controller (Xbox One)" connected (log). Big Picture check not possible (no button in this build). madeira.cfg test line env.MADEIRA_PAD_MODE = hid added, then removed; file restored byte for byte.

| # | Game | Result | In game? / input registered / what worked | Note |
|---|---|---|---|---|
| 20 | Terraria | WORKS: main menu by 2 min, then loaded the test world | in game YES; menu input YES (touch long-press = mouse click); movement NOT confirmed (CoreDevice virtual keyboard "d" and Esc had no visible effect) | screens\Terraria\ingame-after-move.png |

Controller check 2 (11:31-11:39 PM), env.MADEIRA_PAD_MODE = hid, Dave the Diver via Dock: pad never connected ("controller none"); try 1 crashed 0xC0000005 after 41 s, try 2 menu with PlayStation glyphs; Steam controller.txt: "CHIDDeviceListSDL(): Couldn't load SDL3.dll, not enumerating devices". Line removed, cfg verified.

| 21 | Subnautica 2 | FAILS while loading: "Pure virtual function being called" then "Runtime error! ... R6025" | in game NO | Engine.ini not checked; its -dpcvars argument and config as left on the iPad |
| 22 | Risk of Rain 2 | WORKS in game (stage 1) | in game YES, input YES: Esc (skip intro, pause menu) and touch taps (Singleplayer, Ready) via PC virtual keyboard/touch; died to a golem at 01:05 during the move test | screens\Risk of Rain 2\ |
| 23 | Resident Evil 5 | WORKS: title after about 4 min, main menu, START | in game NO (stopped at a privacy-policy prompt, not accepted); keyboard input YES (Enter, Esc) | long "Waiting for its window" (3+ min) |
| 24 | Resident Evil HD | WORKS: title in under 1 min, menu, new game started (intro cinematic) | loads in game (intro); keyboard input YES (Enter, arrows, Esc) in menus; walking not tried | screens\Resident Evil HD\start2.png |
| 25 | Rain World | FAILS: black, then "Rain World Stopped. It closed unexpectedly" within 100 s | in game NO | see logs\ |
| 26 | R.E.P.O. | FAILS (same as 0.2.101): flat dark square for 3 min | in game NO | "Launch anyway" on cloud saves box |

## Subnautica 2 run A (12:46-1:00 AM): NOT completed
Long -dpcvars line typed and saved (args-runA.txt), launched; stopped at the game's "might not have exited correctly" Error box, which taps and keys would not dismiss. Run B not tried. Old 4-cvar arguments restored (verified). No Engine.ini written.

## Handed off at game 27 (about 1:05 AM MT Nov 27). Driver scripts in driver\.

## Continued by new thread, from game 27 (1:06 AM MT Nov 27)
| 27 | Portal 2 | WORKS: menu in about 75 s, new game loaded into the first room | in game YES, input YES (virtual keyboard: Enter, Esc pause menu); movement not confirmed (tutorial 'look up' prompt) | screens\Portal 2\ |
| 28 | Portal | WORKS: menu by 55 s, new game, in test chamber 00 | in game YES, input YES (touch menu taps, virtual keyboard Esc pause menu); movement not clearly confirmed | screens\Portal\ |
| 29 | Overcooked! 2 | WORKS: title by about 100 s, new game, tutorial level loaded and pause menu | in game YES, input YES (virtual keyboard Space, Esc); movement not confirmed | screens\Overcooked 2\ |
| 30 | MiSide | WORKS: menu by 100 s, new game into the bedroom, pause menu | in game YES, input YES (touch, virtual keyboard WASD/Esc) | screens\MiSide\ |
| 31 | Lethal Company | WORKS: LAN mode, hosted local-only, in the ship, pause menu | in game YES, input YES (touch menus, keyboard WASD/Esc) | screens\Lethal Company\ |
| 32 | Hollow Knight: Silksong | PARTIAL: menu works; after New Game (empty slot) the screen stayed black 4+ min | in game NO; menu input YES (keyboard) | cause unproven. Online: Team Cherry help lists black cutscenes for some Windows players; Wine user reports the same (no confirmed fix; PRs not checked) | screens\Silksong\ |
| 33 | Hatsune Miku Mega Mix+ | WORKS: menu by about 3 min, Rhythm Game started the tutorial song | in game YES, input YES (virtual keyboard Enter); pause key not shown as working in the tutorial | screens\Hatsune Miku\ |
| 34 | Grounded | FAILS: black screen with a pointer for 5 min after Play | in game NO | cause unproven. Online: only general CrossOver black-screen reports, nothing Grounded-specific found (PRs not checked) | screens\Grounded\ |
| 35 | Elden Ring | FAILS: black for 5.5 min while the overlay shows 60 FPS, about 7.2 GB | in game NO | cause unproven. Online: searched black screen + vkd3d/MoltenVK, see thread (PRs not checked) | screens\Elden Ring\ |
| 36 | Deep Rock Galactic | FAILS: first run ended with Madeira's 'ran out of JIT memory ... bigger JIT memory settings' box; relaunch stayed black 5 min | in game NO | cause of the black screen unproven | screens\Deep Rock\ |
| 37 | Cyberpunk 2077 | FAILS at start: Get Help sheet, 'redprelauncher.exe crashed about 2 seconds after Steam launched it' | in game NO | ran before: loading screen Nov 23; 0.2.101 stopped 5 s in. Online: no REDprelauncher + WINHTTP c0000017 match found, only general reports (WineHQ bug 52764); PRs not checked. Log (redprelauncher run 02:29): 'wine: Unhandled page fault on read access to 0000000000000004 at address 00000071F1DF7CFE (thread 00fc)' then '[child-end] redprelauncher.exe status=0xc0000005 lived=2.21s'; why it faults is unproven. screens\Cyberpunk\ |
| 38 | Cult of the Lamb | WORKS in game: title by 90 s, new save, walking in the opening area | in game YES, input YES (touch menus; virtual keyboard w moved the lamb) | title ignored virtual Enter, a touch tap passed it. screens\Cult of the Lamb\ |
| 39 | Cities: Skylines | NOT RUN: shows 'Steam - Not installed' (it dropped out of the library after the iPad restart in the 0.2.101 sweep) | n/a | not installed by me. screens\Cities Skylines\ |
| 40 | Black Ops II - Zombies | WORKS in game (TranZit bus depot) but ALL menu and HUD text is missing | in game YES, input YES (virtual keyboard arrows/Enter drove the invisible menu); movement not confirmed (run ended on the score board) | same blank text noted Nov 23 (0.2.97), so not new. Online: nothing matching BO2 missing text found (general CrossOver reports suggest renderer/resolution); PRs not checked. Cause unproven. screens\BO2 Zombies\ |
| 41 | Black Ops II | WORKS: intro video, title, campaign menu; all menu text missing | in game NO (stopped on purpose at an invisible box: confirming blind could overwrite the campaign save); keyboard input YES (Esc, Enter) | same blank-text bug as BO2 Zombies, see row 40. screens\BO2\ |
| 42 | Black Ops | WORKS in game: Solo zombies (Kino der Toten), pause menu, text renders fine | in game YES, input YES (touch menus, virtual keyboard arrows/Enter/Esc/W; died in round 1) | 'Run In Safe Mode?' box at start answered No. screens\Black Ops\ |
| 43 | Among Us | RUNS to its 'Privacy Policy and Terms of Use' box within 50 s; not accepted | in game NO (needs the owner to tap 'I Understand' once) | screens\Among Us\ |
| 44 | RimWorld | NOT RUN: shows 'Steam - Not installed' although its page says last played Nov 25 (the iPad has per-run logs from Nov 25) | n/a | ODDITY to check: why it is no longer installed; not reinstalled by me. screens\RimWorld\ |
| 45 | Fallout 4 | FAILS: launcher opens, then 'Fallout 4 Stopped' within 90 s of PLAY | in game NO | same as 0.2.101 (then: 'Unhandled page fault on execute access to 0000000176B39070'); not new. Online: no match for the execute fault; old Wine bug 39887 is a different fault; PRs not checked. Cause unproven for this run (its log would not open yet). screens\Fallout 4\ |
| 46 | Garry's Mod | FAILS at the menu: 'Menu failed to load' box (the HTML engine) by 60 s | in game NO | same as 0.2.101 (CEF GPU process crashes then); not new. screens\Garrys Mod\ |
| 47 | 7 Days to Die | RUNS to its license agreement (EULA) screen by 100 s; not accepted | in game NO (needs the owner to accept once) | screens\7 Days to Die\ |
| 48 | Project Zomboid | PARTIAL: main menu in about 11 min (drawn, 27-60 fps); Tutorial still on 'Loading' after 16 more min, memory rose 4.0 -> 6.6 GB | in game NO; menu input YES (touch) | same as 0.2.101 test2 (menu, never reached in-world), not new. Cause unproven. Overlay oddity: a 5-6 digit MS value wraps onto two lines. screens\Project Zomboid\ |
| 49 | Fallout: New Vegas | WORKS: launcher, PLAY, main menu with moving slideshow | in game NO (on purpose: New says it will overwrite the Autosave, and Continue is the owner's save); input YES (touch in launcher, virtual keyboard arrows/Enter) | answered No. screens\Fallout New Vegas\ |
| 50 | Counter-Strike 2 | WORKS in game: menu, Practice deathmatch on Inferno with bots, walking | in game YES, input YES (touch menus, virtual keyboard w); about 22-30 fps, 8.5 GB | with touch buttons shown, taps on the GO button area did nothing; switched 'Show touch buttons' off to press GO, then back on. screens\Counter-Strike 2\ |
| 52 | Half-Life | WORKS in game: menu in about 90 s, Training Room, walking | in game YES, input YES (touch menus, virtual keyboard w) | better than 0.2.101 (did not start, Steam code 41). screens\Half-Life\ |
| 51 | Half-Life 2 | WORKS in game: menu in about 95 s, new game, train intro, walking, about 41-43 fps | in game YES, input YES (touch menus, virtual keyboard w) | no Continue item before starting, so no earlier save was replaced. screens\Half-Life 2\ |
| 53 | PEAK | WORKS in game: menu by 100 s, Play Offline, airport lobby, walking | in game YES, input YES (touch menu, virtual keyboard w) | better than 0.2.101 (crashed after Play). screens\PEAK\ |
| 54 | People Playground | WORKS in game: menu by 55 s, Default map, spawned a human | in game YES, input YES (touch menus and item pick, virtual keyboard q spawned) | screens\People Playground\ |
| 55 | RV There Yet? | WORKS in game: menu by 100 s, new private game 'sweep1', camp site, walking to the RV | in game YES, input YES (touch menus, virtual keyboard name + w) | oddity: thin cyan/blue lines across the main menu (not checked if part of the art). screens\RV There Yet\ |
| 56 | Stray | FAILS: black screen with a pointer for 5 min after Play | in game NO | different from 0.2.101 (VC++ Runtime error box). Online: Proton/ProtonDB black-screen reports (WineD3D workaround), nothing iOS/DXMT-specific; PRs not checked. Cause unproven. screens\Stray\ |
| 57 | Skyrim Special Edition | WORKS in game: launcher, PLAY, main menu, new game into the Helgen cart ride, journal menu | in game YES, input YES (touch in launcher, virtual keyboard arrows/Enter/Esc); walking not possible during the cart ride | better than 0.2.101 (Madeira closed). Oddity: runs with a Windows title bar and black bands, not fullscreen; nothing saved (no quicksave). screens\Skyrim SE\ |
| 58 | The Planet Crafter (GOG) | PARTIAL: menu in under a minute; new world 'Standard-2' stayed on 'Loading' for 9 min with memory flat at about 8.0 GB | in game NO; menu input YES (touch) | 0.2.101 only checked the menu, so no earlier in-world result. Cause unproven. The test save 'Standard-2' was created by me (delete if unwanted). screens\The Planet Crafter\ |
| 59 | WorldBox | WORKS in game: world up in about 100 s with the tutorial | in game YES, input YES (touch advanced the tutorial; keys w/q sent) | screens\WorldBox\ |
| 60 | PRAGMATA | NOT RUN: search shows 'No Results' (not installed / not in the library) | n/a | screens\PRAGMATA\ |
| 61 | Little Nightmares | NOT RUN: shows 'Steam - Not installed' | n/a | not installed by me. screens\Little Nightmares\ |

## First pass complete 5:42 AM MT Nov 27. Second pass (games 1-19 + RE5) below.
| Game | Second pass result |
|---|---|
| Baldur's Gate 3 | CRASH: menu works, New Game -> Explorer -> Start Game, loading screen reaches about 75%, then 'Baldur's Gate 3 Stopped' (2 of 2 tries, 05:50 and 05:57) |
| Left 4 Dead 2 | WORKS in game: single player Dead Center on the roof, walking (input: touch + virtual keyboard); cloud-sync box answered Launch anyway |
| Dave the Diver | PARTIAL: menu and new-game intro work (touch input); after skipping the intro, a white loading screen with a spinner for over 5 min. Cause unproven |
| LEGO Star Wars | WORKS in game: input device select, New Game, in the cantina hub (virtual keyboard) |
| Besiege | WORKS in game: menu, entered the sandbox/level editor with the build UI (touch) |
| Megabonk | WORKS in game: Confirm warning, menu, Forest run with enemies and upgrade choice (touch) |
| Stardew Valley | WORKS in game: new character 'sweep', farmhouse, walking (nothing saved: no sleep) |
| Batman Arkham Asylum | WORKS in game: launcher, title, empty save slot, new game, walking in the intake hall |
| Borderlands 2 | PARTIAL: launcher, PLAY, title, main menu; stops at a 'Set your SHiFT Display Name' box that only has Submit (not submitted: that sets up an online identity, needs the owner). ODDITY: many letters missing in the popup text (i, p, v, w, f, y, g, k...). in game NO |
| Resident Evil 4 | CRASH-class: Initial Settings, accessibility, data question (answered 'I do not consent'), title, Main Story, Standard, then error box 'Fatal D3D error (3, E_NOTIMPL, 0x80004001)' (re4.exe). First time this error is seen in the sweep. screens\RE4 pass2\ |
| Slay the Spire 2 | WORKS in game: menu, new run in empty Save Profile 2, map, first combat (touch). Cloud box 'saves differ' answered Launch anyway |
| Undertale | WORKS in game: intro, name entry (name 'AA'), first room (virtual keyboard); runs in a window, not fullscreen |
| ULTRAKILL | WORKS in game: audio/video calibration, Standard difficulty, in the opening fall sequence (touch). Calibration saved master 100, effects 89, music 89, PC video |
| The Escapists 2 | WORKS in game: menus, New Game tutorial prison (Precinct 17), in the cell block (touch menus; spacebar via virtual keyboard) |
| Resident Evil 5 | WORKS: title, save loads, main menu; Fixed Benchmark renders in-engine at about 44 fps (keyboard input YES). Playable story NOT entered on purpose: it would run over your existing save. No privacy prompt appeared this time |

## Second pass done 8:12 AM MT. Retest queue next (RETEST-QUEUE.md).

| RETEST The Planet Crafter | PASS with env.MADEIRA_WG_64BIT = 1, env.MADEIRA_WG_VIDEO_FORMAT = argb32, env.MADEIRA_D3D11_NO_VIDEO_DEVICE = 1 in its own config (kept): loading video plays, new world opens, walking, ~40 fps |
| RETEST Dave the Diver | PASS when the intro is NOT skipped: in game with input by about 5 min. White screen only after skipping the intro (Esc) |
| RETEST Cyberpunk 2077 | Without pool-split and X64_IMAGE_NOCOPY (+ JIT_POOL_AUTO = 0) the launcher no longer crashes and cyberpunk2077.exe starts, then stops with Windows error 0xC000012D (Get Help: ran out of memory space, huge reservation). Config restored |
| RETEST Borderlands 2 | with gl-vulkan = kosmickrisp the game never shows after the launcher's PLAY (log: zink_init libvulkan_kosmickrisp.dylib, nothing after). Config restored, so the missing-letters question is unanswered |
| RETEST Stray (10:38) | WORKS in game: calibration, menu, new game in empty slot 1, opening scene, keyboard input. Earlier 05:04 and 08:39 runs black 5 min with no change in settings (cause unproven) |
| RETEST Cyberpunk run 3 | Starting Cyberpunk2077.exe directly: Madeira itself closes about 15-20 s after Play (iPad home screen). Settings reverted |
| RETEST Cyberpunk run 3 again (item 12) | Cyberpunk2077.exe runs 6+ min, black 'still starting', no crash; JIT pool 848 MB, not exhausted. Settings reverted |

## Final count (latest result per game, 61)
- Working in game: 32 (6, 7, 9-13, 16-20, 22, 24, 27-31, 33, 38, 42, 50-59)
- Partial: 11 (2 BG3, 14 Borderlands 2, 15 RE4, 23 RE5, 32 Silksong, 40 BO2 Zombies, 41 BO2, 43 Among Us terms screen, 47 7 Days license screen, 48 Zomboid, 49 Fallout NV menu only on purpose)
- Failing: 14 (1 BO3, 3 Halo MCC, 4 Detroit, 5 tModLoader, 8 Raft, 21 Subnautica 2, 25 Rain World, 26 R.E.P.O., 34 Grounded, 35 Elden Ring, 36 Deep Rock, 37 Cyberpunk, 45 Fallout 4, 46 Garry's Mod)
- Not installed: 4 (39 Cities Skylines, 44 RimWorld, 60 PRAGMATA, 61 Little Nightmares)
- Games 1, 3, 4, 5, 8, 21, 25, 26 were not retested after the first pass.
| RETEST Cyberpunk run 4 (swap 8192, item 13) | Same wall as run 3 repeat: black, newBuffer failed then breakpoint; settings reverted |
