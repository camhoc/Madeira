# RESULT: test-hooks

Checked on the Linux laptop against 0.2.180-og.

## Compile
Applies with `patch -p1`. Swift typecheck of the whole app: no new errors (only the existing Squeeze one); the [String: Any] literal and LibraryModel / NextSteamApp calls typecheck. One file only, so no project.pbxproj change is needed.
Host tests: check-restart-next-game.py passes before and after. check-game-handoff.py failed on the unpatched tree here (its native C part did not compile) and passed on the patched copy; the patch touches no C, so that difference is not the patch.

## Review: PASS WITH NOTES
- Inert unless the bundle id is the iPad id AND env.MADEIRA_IPAD_TEST_HOOKS = 1: handle() returns before any new code when `enabled` is false, and writeStatus / quit / relaunch check it again.
- Exception: keepPreviousRunLog() has no `enabled` check of its own. It is only called from exportAtStart(), which checks first, so it is inert today; add the guard so a later caller cannot run it on public builds.
- Bundle id: the patch adds NO new bundle-id text to the code (the existing iPadBundleID line is reused). But this branch's README.md contains the iPad bundle id in plain text, and camhoc/Madeira is a PUBLIC repo, so the id is now published on this branch. Remove it from README.md (and its history) if the removal plan requires it.
- madeira://quit with no game closes Madeira at once; any page or app that opens a madeira:// link can do it on the iPad test build.
- keepPreviousRunLog's DateFormatter has no fixed locale/calendar; set en_US_POSIX so file names sort by time on every device.
- Not device-tested (status.json over AFC, requestQuit ending every game).
