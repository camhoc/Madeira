# gmod-sandbox-reparse (WRITTEN, not queued: needs REVIEW.md second pass + host build check)
What: new opt-in env switch `env.MADEIRA_PLAIN_DIR_LINKS = 1`. When set, wine/dlls/ntdll/unix/file.c get_file_info() stops flagging directory symlinks and mount points (st_dev differs) as FILE_ATTRIBUTE_REPARSE_POINT. Default OFF = identical to today. Patch: 0001-plain-dir-links.patch (against madeira-0.2.101, wine-dlls-2 zip). Not compiled yet.
Off switch: leave the line out (default) or `env.MADEIRA_PLAIN_DIR_LINKS = 0`.
Why (UNPROVEN): GMod 0.2.101 iPad logs (logs/gmod-0.2.101/gmod-sandbox-symlink.txt, gmod-runs-ABC.txt): 5x "Failed to add sandbox rule. error = 2 ... pattern 'c:\external\e91a045a-...\steamlibrary\steamapps\common\garrysmod/chromium.log'" then "The GPU process has crashed" x3, menu fails. drive_c/External/<uuid> is a symlink to the SSD. Online: lutris/lutris#6928 shows the same two lines caused by a symlinked path (Chromium sandbox refuses reparse points); Facepunch/garrysmod-issues#6921 same GPU crash, no cause. No Wine/FEX/Proton MR found. Lines 2007-2040 of file.c show the flagging.
Open doubts: (1) the sandbox path may also cross the mixed "\" and "/" before chromium.log, which this does not touch; (2) directory enumeration at lines ~1909-1922 flags mount points too and is not patched; (3) flagging symlinks plain may break tools that rely on junction detection (Steam CEG per LESSONS-FROM-THE-WORLD:460 is the other way round). Only set it in GMod's own config.
Test: add `env.MADEIRA_PLAIN_DIR_LINKS = 1` to GMod's config on the build that carries this patch; success = no "Failed to add sandbox rule" lines, no GPU crash, menu loads.

## Update after second review (REVIEW.md: PASS WITH CHANGES, applied)
- Patch now also gates fd_get_file_info() mount-point check; helper moved above it (compiles by inspection only, host compile still to run by build thread).
- Proof step: run GMod with env.MADEIRA_FILE_TRACE = 1 and env.MADEIRA_PLAIN_DIR_LINKS = 1; expect no "Failed to add sandbox rule" lines and the menu loading. If the error stays, the mixed "\" and "/" in the pattern (or Chromium's own path handling) is the cause, not this.
- Warning: with the switch on, delete or junction logic could walk through the symlinked SSD. Set it ONLY in GMod's own config, never global.
- Golden games must be run with the line absent (default) on the build carrying this patch.

## Online (Nov 26, Cameron's rule: research how others fix GMod menu)
- ValveSoftware/Proton#2848: SoraBytes got the CEF menu working under Proton Experimental by putting the game folder INSIDE the prefix (drive_c/GarrysMod) and symlinking it the other way; Cloudwalk9 logged the same "Failed to add sandbox rule." Supports the symlink-path theory (same direction as lutris#6928). https://github.com/ValveSoftware/Proton/issues/2848
- solsticegamestudios/GModPatchTool#123 (native Linux, missing packages), Droid-Deck/DroidDeck#943 (ARM64, same error, no fix), Facepunch/garrysmod-issues#6921 (GPU crash, no fix), lutris/lutris#6928.
- Linux/Mac guides: GModCEFCodecFix (updates GMod's CEF; macOS thread says remove -nochromium) and the x86-64 branch with -chromium (Steam forum 3190242182148798320). Not tried on iPad; 32-bit default branch is what the iPad runs.
- Nothing found on Wine/FEX/box64 MRs for this. ProtonDB and AppleGamingWiki pages could not be read.
