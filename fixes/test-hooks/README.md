# test-hooks (next build), Nov 28 2026
Extends ipad-test-hooks (0.2.180 already has launch + export-logs). Test-only, our own design, no code copied. Online: not searched (no new wall; same URL-hook + AFC pattern as ipad-test-hooks, which searched Appium/pymobiledevice3 practice).

**Gate / off switch:** unchanged. Runs only when bundle id = app.andromeda203.garnet9008 AND `env.MADEIRA_IPAD_TEST_HOOKS = 1` in madeira.cfg (default off). Every other build logs `[ipad-hooks] <host> ignored` and does nothing. No new config key, no ConfigCatalog change. Game running is untouched.

## New links (Documents/test-hooks/ is read by the PC over AFC)
1. `madeira://status` -> `status.json`: time, uptime, build, game {running, title, steam_app, sessions_this_run}, present_fps + frames_in_tail (from `[frame]` lines in the last 512 KB of madeira-log.txt; only exist while env.MADEIRA_FRAME_STATS is on, else null/0), last 40 log lines, newest 5 session log names. Also written 15 s after app start.
2. `madeira://quit` -> graceful close of the running game (requestQuit, Alt+F4); with no game, closes Madeira. `madeira://quit?force=1` -> exit(0) at once.
3. `madeira://relaunch?steam=<appid>` -> queues the game (NextSteamApp), asks the game to close, waits up to 20 s, exit(0). iOS cannot reopen an app that exited: the PC opens Madeira again and the queued game starts on its own (30 min window).
4. Run logs: Documents/logs/ already keeps 40 session logs (LogStore.startSessionLog). New: at every app start madeira-log.prev.txt is copied to test-hooks/runs/<time>-prev.txt, newest 20 kept.

## Files
`test-hooks.patch` (-p1, one file: app/Madeira/SavesAndShortcuts.swift; no pbxproj change). Applies cleanly to the 0.2.180 source (patch --dry-run checked). NOT compiled: no Swift compiler here; laptop compile check wanted. Things to look at in review: `presentFPS.map { $0 as Any } ?? NSNull()` in a [String: Any] literal, LibraryModel.current / activeEntry / requestQuit access (all non-private in 0.2.180), nested recursive func closeWhenDone.
Not included (asked to skip): in-app screenshot link.
Unproven: that requestQuit ends every game (some need a confirm dialog), that `[frame]` lines appear without env.MADEIRA_FRAME_STATS. Needs a device run: open madeira://status, check status.json over AFC.
