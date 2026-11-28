# RESULT: test-hooks (with the command file)

Checked the latest head (450a852) on the Linux laptop against 0.2.180-og.

## Compile
Applies with `patch -p1`; Swift typecheck of the whole app: no new errors (only the existing Squeeze one). One file, no project.pbxproj change.

## Review: PASS WITH NOTES
- Gate: startCommandFile returns at once unless `enabled` (iPad bundle id AND env.MADEIRA_IPAD_TEST_HOOKS = 1); it is only called from exportAtStart, which checks too. No timer runs on any other build.
- Who can write command.txt: anything that can write Madeira's Documents folder. Info.plist has UIFileSharingEnabled and LSSupportsOpeningDocumentsInPlace, so that is the paired PC (AFC/Finder), the Files app, and other apps working on documents in place. Whether Windows programs inside Wine can reach Documents/test-hooks was not confirmed. On the test build with the switch on, any of them can make Madeira quit, relaunch or start a game. Acceptable for a test build; keep the switch off otherwise.
- Commands are a fixed list, app ids must be positive numbers, a file older than 120 s is ignored, the file is deleted when read. Bad input cannot crash it (words[1] only read when there are two words).
- A 2-second timer runs for the whole app run while enabled.
- keepPreviousRunLog still lacks its own `enabled` check, and its date format has no fixed locale (see earlier note).
- README.md again contains the iPad bundle id, on a PUBLIC repo.
