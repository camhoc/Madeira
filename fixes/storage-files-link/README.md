# storage-files-link (base 0.2.180, for the next build)

Cameron, 0.2.180, Nov 26 2026: "In storage, why are the white text clickable? It'll take you to it in files, but it doesn't."
Then: "clicking on it, could it take you to files, or show where it is in files? People want to delete stuff from there."

**Cause (from the code, StorageManager.swift rowView in 0.2.180):** every row was a Button. For rows that cannot be deleted
here (Everything on this device, store games installed by Valve) the button's tap did nothing, but the row looked tappable.

**Fix.** Each row now knows its folder under Documents (`filesPath`, the path Files shows it as).
- A row you cannot delete here, with a folder in Documents: tapping opens that folder in Files (`shareddocuments://<Documents path>`), with a small arrow icon.
- A row you can delete: the tap still asks to delete (unchanged). Swipe right = Files, long press = Show in Files / Copy Files path.
- A row with nothing to do (folder not in Documents: Application Support, Caches, tmp, external drive): plain text, not a button.
Games, added programs and clear rows get their folder too (Steam/Epic/GOG/EA/itch/program folders under drive_c; not External/...).
`env.MADEIRA_STORAGE_FILES_LINK = 0` turns all of it off (rows behave as in 0.2.180).
Log: `[storage] open in Files: <path>` and `[storage] Files did not open <path>`.

Not device-tested: that `shareddocuments://` opens the folder (Info.plist has UIFileSharingEnabled and LSSupportsOpeningDocumentsInPlace, so Documents is in Files). Not compiled.
Files Files can show only Documents; Caches, Application Support and tmp have no link.
Online: not searched (own code).
Apply: patch -p1 on 0.2.180 (needs storage-screen already in, as 0.2.180 has). Test: tests/host/check-storage-files-link.py.

## Review (independent, Nov 27)
No compile errors or data-loss path found (nothing compiled). Fixed from it: an external Windows drive no longer gets wrong Files links;
"external/" matched in any letter case; Copy Files path uses the app's display name; two doc comments were on the wrong switches.
Left: plain rows are skipped by the controller highlight (intended); the Files folder name in Copy path is the display name, unchecked on device.

## Added Nov 27: the ".Trash" row (player Sambecat: "Documents: .Trash 20.91 GB", can't find or delete it)
What it is (checked: the player's Discord screenshots, Madeira's Wine source, Madeira code; Apple's own page was not read):
- Madeira's code never creates Documents/.Trash (grep of the app source: no ".Trash"). The name matches iOS's Files app, which keeps things
  deleted from an app's folder in a hidden .Trash inside that folder ("Recently Deleted"). I believe this is the 20 GB, but it is not proven
  from the player's device. The Discord reply pasted from Gemini ("Wine moves it there") is wrong for this folder: Wine's own trash is
  HOME/.Trash (shell32 init_trash_dirs, macOS branch), and HOME is the Wine prefix, so Wine's is Documents/wine/.Trash (unchecked on a device).
- Emptying the unzip app's trash does not touch it: it belongs to Madeira's folder.
Change: two rows under "Safe to clear", each with the usual confirm sheet: "Recently Deleted (from Files)" (Documents/.Trash) and
"Windows recycle bin" (Documents/wine/.Trash). The text says emptying is permanent. In Everything on this device the rows are named the same, no Files link
(hidden folders get none). `env.MADEIRA_STORAGE_TRASH_ROWS = 0` leaves them as plain rows.
Player's way without the update: Files > Browse > Recently Deleted > Select > Delete All (it should list what was deleted from Madeira's folder). Unverified on a device.

## Review of the trash rows (independent, Nov 27)
Emptying cannot reach outside the two folders (links are never followed or removed; Documents, drive_c, saves and games are never the target);
the running-game / move / batch / download guards apply. Fixed from it: removeChildren now refuses a folder that is itself a link; the confirm
sheet now shows each clear-row's full text and says "Deleted here is gone for good: it does not go to Recently Deleted." (the permanent warning had only been in the row text, cut to two lines).
Left: a stray doc comment order, harmless. Not compiled, not device-tested.
