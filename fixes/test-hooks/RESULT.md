# RESULT: test-hooks (rev 3, head f11eec6)

Checked on the Linux laptop against 0.2.180-og.

## Compile
Applies with `patch -p1` to plain 0.2.180; Swift typecheck of the whole app: no new errors (only the existing Squeeze one). winios_post_key(int vk, int down), winios_post_touch_down/up(int x, int y) exist in Winios.h with those signatures; GameProfile(windowsPath:).text has a setter, so the edit compiles.

## Review: PASS WITH NOTES
- Gate: key/tap/config only come from the command file, which only exists when `enabled` (iPad id AND env.MADEIRA_IPAD_TEST_HOOKS = 1). They are not reachable through madeira:// links.
- Who can write the command file: unchanged from rev 2 (paired PC, Files app, apps opening documents in place). On the test build that now also means sending keys/taps to the game and editing any game's config.
- Config edits: the backup is written with `try?` BEFORE the edit, but a failed backup does not stop the edit. Make the edit depend on the backup succeeding if a backup is required.
- Config edit removes every line that sets the key, then appends one; comment lines are kept. Key/value checked for spaces, '#', '=' and newlines.
- key: only listed names, A-Z, 0-9, F1-F12; released after 80 ms in reverse order. tap: game coordinates, no range check (the native side decides).
- Earlier notes stand: keepPreviousRunLog has no own `enabled` check; DateFormatters have no fixed locale; README has the iPad bundle id on a public repo.
