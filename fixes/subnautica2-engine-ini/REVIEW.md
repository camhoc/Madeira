# REVIEW: subnautica2-engine-ini (second reviewer, Nov 28; read only, not compiled)

**Verdict: PASS WITH FIXES** (fixes 1-3 are needed or the host tests fail; 4-6 are small)

## Fixes
1. **tests/host/check-game-recommendations.py:500 fails.** It requires subnautica-2 `version == 2`. Version 3 needs that test edited (remove subnautica-2 from the `2 if ident in (...)` tuple and add a 3 case).
2. **The same test fails at lines 203-205 and 216.** A list must END with the FORK_DEFAULTS block (`p['lines'][c:] == tail`), and the lines above it may not start with `#`. new/GameRecommendations.swift:2691-2693 puts 2 comment lines and the seed line AFTER `env.MADEIRA_JIT_DUMP = 0`. Move `env.MADEIRA_UE_INI_SEED = ...` above line 2686 (`# The defaults this list was tested with`). Drop the two `#` lines and put that text in the `//` comment next to `programArguments`.
3. **check-config-catalog.py fails until ConfigCatalog.generated.swift is regenerated** (gen-config-catalog.py `--check`). README already says this; it is a must before the build.
4. **The patch and new/ differ on one line.** new/DockInstallers.swift:489 is `(read ?? IniFileText(data: Data()))?.data(doc.text)`, but the .patch has `(...Data())!).data(...)`. new/ was saved 39 s after the patch. Both compile and act the same (empty Data always decodes as UTF-8). The build thread should take new/ or re-make the patch.
5. **An existing file that does not decode gets overwritten.** DockInstallers.swift:483-489: when `old != nil` and `IniFileText(data:)` returns nil (a UTF-16 file that does not round-trip), `read` is nil. The doc then starts from "" and the file is replaced with only the seed lines, so the game's other Engine.ini lines are lost. Suggest `if old != nil && read == nil { log; continue }`. This is rare: Engine.ini is normally ASCII/UTF-8.
6. **A skip leaves no log line.** DockInstallers.swift:467-468 returns with no log when a session runs (wine_process/wineserver running). This can happen on the library path (ContentView.swift:2977) when Steam or the Desktop already runs in the Dock. Engine.ini is then not seeded and the FATAL comes back with nothing in the log to explain it. Suggest logging `[ue-ini-seed] ... skipped: a session runs` when a seed was set. The Dock path (4053) is already guarded at 4022, so it is fine.

## Checked, OK
- **Swift.** The `guard let raw = raw?...` shadowing and the Substring `trimmingCharacters` (Foundation) are fine. The `?:` returning `nil`/`(project, pairs)` converts to the labelled optional tuple; if the compiler objects, write `(project: project, pairs: pairs)` (low risk). `old.flatMap`, `data == old` (Data vs Data?), the nested quotes in `\(old == nil ? "missing" : "present")` and the `where` that re-reads the mutated `doc` are all fine. `@MainActor` matches RockstarPipeTimeout at the same 2 call sites. `LogStore.log(level:)`, `wine_process_is_running`/`wineserver_is_running` and `GameConfigFolders.matches` all exist with these signatures.
- **IniDocument.add on an empty or missing file.** `lines` is `[""]`, `wasEmpty` empties it, then `[SystemSettings]` + the key, with a newline at the end. Later adds go after the section's last setting. On an existing UE Engine.ini, other sections and lines are kept and a key already there (case-insensitive) is set in place. CRLF/LF and the BOM/encoding are kept by IniFileText. A new file is UTF-8 with LF, which UE reads. A second run with the same values writes nothing ("already has" log).
- **User folders.** `users/*` minus `Public`, only those with `AppData`. If none, an error is logged. Every Wine user gets the file, which does no harm.
- **Path safety.** Project is limited to Unicode alphanumerics plus `_-.`, and `.`/`..` are refused, so no `/` and no traversal. A name like `...` is a legal folder name. Keys with `[ ] ;` are dropped, values cannot hold `,` or a newline, and a key with no `=` is skipped.
- **The long value (~1 KB, with `: , =`).**
  - GameProfile.parse splits on the first `=` only.
  - WineProcessBridge.m:2526-2537 splits on the first `=` and calls `setenv`. The variable lands in the Wine and game environment, which does no harm (UE ignores it), and adds one long `[madeira-env] game` log line.
  - madeira_cfg.h `madeira_cfg__scan` has no per-line limit (only the MADEIRA_CFG_MAX file size).
  - The test regex sees no `\` escape.
- **`programArguments: ""`.**
  - GameRecommendationsApply.swift:271 sets `entry.arguments = ""` only on a Reset or a new entry (takeEntryFields). On Reset this clears the player's own Launch arguments, the same as v2 did with -dpcvars.
  - A v2 player whose config is unchanged gets the v3 config file (`.updated`), but their old `-dpcvars` stays in Launch arguments until Reset. The game ignores it, so no harm, but README's "clears on Reset/apply" means Reset or a new entry only.
  - A player with an edited config gets the seed line once through RecommendedMerge.
- **Games without the line.** Each launch parses the game's config and returns nil, so nothing is written and nothing is logged. madeira.cfg's global env is not read. Only `subnautica2` has the line.

## Files touched
- DockInstallers.swift: new enum, lines 440-503.
- ContentView.swift:2977 (library launch, every library game) and 4053 (Dock start, every Dock game).
- GameRecommendations.swift:2673-2699 (subnautica-2 only).
- Still to edit: tests/host/check-game-recommendations.py and ConfigCatalog.generated.swift.
- On the device it writes only `Documents/wine/drive_c/users/<u>/AppData/Local/Subnautica2/Saved/Config/Windows/Engine.ini`.

## Must not break
- No file is written for any game without the line.
- No write while a session runs, because the registry and prefix are shared.
- An existing Engine.ini keeps its other sections, lines, encoding and line ends.
- `= 0`, an empty value or no line all mean off.
- Reset to Recommended for other games is unchanged.
- Host tests pass: check-game-recommendations, check-config-catalog, check-ini-editor.

## Golden games to run (GOLDEN-GAMES.md)
- **#3 Satisfactory (Epic, Unreal).** Library path, same AppData/Local/<Project>/Saved/Config layout. Confirm no `[ue-ini-seed]` line and an unchanged Engine.ini.
- **#2 7 Days to Die.** Dock start path at 4053.
- **#1 Silksong and #4 Stardew Valley.** Plain library launches.
- **Subnautica 2 (target, not golden).** Log has `[ue-ini-seed] ... wrote 28`, then the game log has `Set CVar [[RHI.TransientAllocator.MinimumHeapSize:256]]` and no FATAL. A second start shows the file written again after the game deleted it.
- The other golden games, per WORKFLOW step 6.

## Author fixes after review (Nov 28)
1. Test edited: new/tests-host/check-game-recommendations.py expects subnautica-2 version 3 (in the patch).
2. Seed line moved above "# The defaults this list was tested with"; the two # lines dropped, text moved to the Swift // comment.
3. Catalog regenerate: STILL for the build thread (gen-config-catalog.py on the full tree).
4. Patch regenerated from new/ (no force unwrap).
5. Existing Engine.ini that won't decode: now logged and left alone.
6. Skip while a Wine session runs: now logged ([ue-ini-seed] ... not written: a Wine session is running).
Host checks on a copy of 0.2.180 + these files: check-game-recommendations PASS, check-ini-editor PASS (Swift parts SKIP: no swiftc here).
