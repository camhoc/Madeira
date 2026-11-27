# REVIEW: gmod-sandbox-reparse (0001-plain-dir-links.patch), second pass, Nov 26 2026
Reviewer: fresh agent, not the author. Source read: file.c from madeira-0.2.101 wine-dlls-2 zip. Not compiled (no host build here); read-only analysis.

## Files touched
- wine/dlls/ntdll/unix/file.c only. New static `madeira_plain_dir_links()` (cached getenv, ==1) and two extra conditions in `get_file_info()` (by-name): the directory-symlink branch (line ~2012) and the mount-point branch (~2026).
- Compile check (read of includes): OK. file.c includes stdlib.h (getenv), config.h/windef.h (BOOL); the same getenv + static-cache pattern is already used at lines 281, 308, 1263, 5993 etc. Function is defined before first use and before the `#define get_file_info(...)` macro at ~2786, so it is not macro-mangled. Nit: the patch inserts the helper between the "get the stat info..." comment and `get_file_info`, so that old comment now sits above the helper; cosmetic. Could warn "unused" only if get_file_info were removed; it is not.
- Default off: with the env unset, `cached` = 0, `!0` = 1, both conditions reduce to the original expressions. Behaviour is logically identical (one extra getenv on first call, cached after). Same-thread race on the static is benign (idempotent value). Byte-identical binary is not claimed, only behaviour.

## Other users
`get_file_info` (by name) callers: the ios dir-entry cache macro (`ios_get_dir_entry_info`, ~2739-2761, caches result in struct ios_dir_info; static env makes cache consistent), `get_dir_data_entry` (~2805, NtQueryDirectoryFile/NtQueryDirectoryFileEx enumeration), `NtQueryFullAttributesFile` (~5854), `NtQueryAttributesFile` (~5891). Not touched by the patch (separate function `fd_get_file_info`, by handle): ~1897-1925, used by NtQueryInformationFile classes at ~6118-6241 (FileBasic, FileNetworkOpen, FileAttributeTag, FileStat), via `madeira_fd_stat_only` at ~5996, and by NtOpen/NtCreate paths (~5500/5535 pass options & FILE_OPEN_REPARSE_POINT).

## Must-not-break
- Windows semantics: a directory symlink / mount point reporting FILE_ATTRIBUTE_REPARSE_POINT is what FindFirstFile, GetFileAttributes and RemoveDirectory/CopyFile/recursive-delete code use to avoid following junctions. With the switch on, installers or Steam "delete folder" routines could recurse INTO a symlinked dir (e.g. the SSD library) and delete the real contents. Only safe in a game's own config, and only for a game that never deletes/relocates its tree.
- Steam CEG / library-folder junction checks (LESSONS-FROM-THE-WORLD:460 notes it is the opposite direction): not provable from the patch; any launcher that runs in the same wineserver prefix is unaffected only because env is per process (env.* set in the game's config applies to the game process tree, which includes steam.exe/children if they inherit it).
- Mount flag also matters for the `C:\` root, `Z:\` and drive_c/dosdevices symlinks: they are dirs on a different st_dev, so with the switch on they stop being reparse points everywhere in the game process (path canonicalisation, GetFinalPathNameByHandle callers).

## Golden games to run
Switch is opt-in per game, so golden risk is only for the game it is enabled in (GMod, not on the list). Run after the build with the line absent to confirm the zero-change claim: Fallout NV (#10), a 32-bit (Undertale #5), Silksong (#1), Satisfactory (#3, Epic launcher path uses junctions), plus Battle.net/OW2 and Steam launch (CEG) from the anti-regression list, 2 launches each, 60 s+. Then GMod with the line = 1.

## Risks
1. **The fix may not take effect.** `get_file_info()` is the by-name path only. Chromium's sandbox rule creation almost certainly opens the path (CreateFile/GetFinalPathNameByHandle or NtQueryFullAttributesFile on each component). The handle path `fd_get_file_info` (line 1909-1922) flags mount points when FILE_OPEN_REPARSE_POINT is in options and is NOT patched; a symlink there is followed by fstat so it is not flagged at all by that function, but the mount-point branch is. Since drive_c/External/<uuid> is a symlink to the SSD, by-name queries (attributes/enumeration of c:\external\<uuid>) are the likely hit, so the patch is plausible but unproven. Open doubt (1) from the README stands: the mixed "\" and "/" before chromium.log is not touched, and error=2 (FILE_NOT_FOUND) is not obviously a reparse error; it may come from Chromium's own path canonicalisation (GetLongPathName/FindFirstFile on a component) failing, not from the attribute flag.
2. Wine itself resolves symlinks transparently, so the attribute flag may not be what Chromium checks; no log line shows which call fails. Cheapest proof first: run GMod with MADEIRA_FILE_TRACE (exists at line 308) and look for the last call on the `external\<uuid>` path before the "Failed to add sandbox rule" line.
3. Directory enumeration uses the cached macro version of get_file_info (~2786); dir cache entries are keyed by dir mtime, fine, but entries created before the env is read cannot exist (env is read on first call, process-wide).
4. Cosmetic: helper inserted between the old comment and the function.

## Verdict
PASS WITH CHANGES. Safe as an opt-in: default off is logically identical, compiles by inspection, switch name and off line are documented.
Requested changes before it is called queued:
1. Also gate the mount-point flag in `fd_get_file_info()` (lines 1910-1917: `if ((options & FILE_OPEN_REPARSE_POINT) && !madeira_plain_dir_links())`), so handle-based queries agree with by-name ones. Move `madeira_plain_dir_links()` above `fd_is_mount_point` (line ~1881) so both use it.
2. Move the helper below the "get the stat info..." comment (cosmetic).
3. README: change "Why" to say the cause is UNPROVEN and the first test is the MADEIRA_FILE_TRACE run above; add a warning that the switch must not be set in launcher/Steam configs (delete-through-symlink risk).
4. Host compile check, then run the golden list above with the line absent.
Without 1 the fix may silently do nothing for handle-based checks.
