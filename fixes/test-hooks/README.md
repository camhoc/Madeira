# test-hooks (next build), Nov 28 2026
Extends ipad-test-hooks (0.2.180 already has launch + export-logs). Test-only, our own design, no code copied. Online: not searched (no new wall; same URL-hook + AFC pattern as ipad-test-hooks, which searched Appium/pymobiledevice3 practice).

**Gate / off switch:** unchanged. Runs only when bundle id = app.andromeda203.garnet9008 AND `env.MADEIRA_IPAD_TEST_HOOKS = 1` in madeira.cfg (default off). Every other build logs `[ipad-hooks] <host> ignored` and does nothing. No new config key, no ConfigCatalog change. Game running is untouched.

## Relation to ipad-test-hooks (already in 0.2.180)
This is an extension, not a second feature. It edits the same `enum IPadTestHooks` in SavesAndShortcuts.swift: one gate (`enabled`), one entry point (`handle`, the link host list just gets status/quit/relaunch added), no second launch hook. `madeira://launch?steam=` and `export-logs` stay exactly as in 0.2.180; the command file feeds `handle` with the same links, so `launch` there IS the existing launch hook. MadeiraApp.swift and ContentView.swift are not touched. Do not apply the old ipad-test-hooks.patch together with this one; this one applies on the 0.2.180 tree that already has it.

## New links (Documents/test-hooks/ is read by the PC over AFC)
1. `madeira://status` -> `status.json`: time, uptime, build, game {running, title, steam_app, sessions_this_run}, present_fps + frames_in_tail (from `[frame]` lines in the last 512 KB of madeira-log.txt; only exist while env.MADEIRA_FRAME_STATS is on, else null/0), last 40 log lines, newest 5 session log names. Also written 15 s after app start.
2. `madeira://quit` -> graceful close of the running game (requestQuit, Alt+F4); with no game, closes Madeira. `madeira://quit?force=1` -> exit(0) at once.
3. `madeira://relaunch?steam=<appid>` -> queues the game (NextSteamApp), asks the game to close, waits up to 20 s, exit(0). iOS cannot reopen an app that exited: the PC opens Madeira again and the queued game starts on its own (30 min window).
4. Run logs: Documents/logs/ already keeps 40 session logs (LogStore.startSessionLog). New: at every app start madeira-log.prev.txt is copied to test-hooks/runs/<time>-prev.txt, newest 20 kept.

## File trigger (added Nov 28 05:20Z, because the PC cannot open madeira:// links on the iPad)
Same hooks, same gate, no links. The PC writes `Documents/test-hooks/command.txt` over AFC (pymobiledevice3 house_arrest, app.andromeda203.garnet9008), first line = one command:
`launch <appid>` | `quit` | `quit force` | `relaunch <appid>` | `status` | `export-logs [appid]`.
The app polls every 2 s on a background timer (so it also runs while a game is running), deletes the file when read, and writes `command-result.txt` ("<time> <command>: done" or "not understood"/"ignored"). A file older than 120 s is deleted unread. `launch` while a game runs becomes `relaunch` (one game per app run: Madeira closes and the PC reopens it, the game starts by itself). Armed at app start, same place as the log export. When Madeira is not running nothing can read the file: the PC must open the app first (queued relaunch still works from NextSteamApp).
**Added Nov 28 05:40Z (Cameron OK'd both):** four more command-file commands, same gate, same file, same timer (function `runExtra`/`editConfig` in IPadTestHooks):
- `key <name>[+<name>]` (enter, esc, space, tab, backspace, arrows, f1-f12, a-z, 0-9, ctrl/alt/shift; e.g. `key enter`, `key alt+f4`) presses and releases through winios_post_key, as requestQuit does. Needs a running game.
- `tap <x>,<y>` touch down then up 80 ms later through winios_post_touch_down/up, in the coordinates those functions take (assumed to be game coordinates: unproven, check once on the iPad). Needs a running game.
- `config <appid> <key> = <value>` / `config <appid> unset <key>` edits that game's own config (GameProfile text, the Game details > This game's config file): drops every line setting the key, appends the new one. First copies the old file to `Documents/test-hooks/config-backups/<appid>-<time>.cfg` and logs `[ipad-hooks] config <title> (<appid>): ...`. Takes effect at the game's next start. Refuses keys with spaces, `#` or `=` and values with line breaks.
Results go to command-result.txt like the others.

Unproven: "works while a game is running" is by design only (background timer, no main-thread wait); needs an iPad run. Also unproven: that the PC can write into Documents/test-hooks over AFC (the existing own-logs export already reads there).

## Files
`test-hooks.patch` (-p1, one file: app/Madeira/SavesAndShortcuts.swift; no pbxproj change). Applies cleanly to the 0.2.180 source (patch --dry-run checked). NOT compiled: no Swift compiler here; laptop compile check wanted. Things to look at in review: `presentFPS.map { $0 as Any } ?? NSNull()` in a [String: Any] literal, LibraryModel.current / activeEntry / requestQuit access (all non-private in 0.2.180), nested recursive func closeWhenDone.
Not included (asked to skip): in-app screenshot link.
Unproven: that requestQuit ends every game (some need a confirm dialog), that `[frame]` lines appear without env.MADEIRA_FRAME_STATS. Needs a device run: open madeira://status, check status.json over AFC.
