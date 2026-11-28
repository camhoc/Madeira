# REVIEW: dock-start-dll-links-1 (second pass, fresh reviewer, Nov 26 2026)

Reviewed: README.md, dock-start-dll-links-1.patch, source/madeira-0.2.101/Madeira/app/Madeira/{DockStartProgram.swift (whole), ContentView.swift 3995-4025, ConfigCatalog.generated.swift, MadeiraConfig.swift 236}, tests/host/check-dock-start-program.py, pending-prs/dock-eac-offline/{README,REVIEW}.md, INDEX.md, reference/GOLDEN-GAMES.md. The patch was not edited. No Swift compiler here: nothing compiled or run on a device. I did not look online (the owner's "are we looking online" was not part of this task); nothing below comes from web sources. I applied the patch to a scratch copy (patch -p1, clean) and ran the host Python checks that need no compiler.

## VERDICT: CHANGES NEEDED (do not queue as -1)
Two small blockers, both CI/build hygiene, plus three recommended hardening edits. The core idea and the link arithmetic read correct.

1. BLOCKER, PROVEN by running it on the patched copy: `tests/host/check-dock-start-program.py` now prints `FAIL: the Unity data link has its switch (env.MADEIRA_DOCK_START_UNITY_DATA = 0 turns it off)`. The check greps for the exact text
   `unityData: MadeiraConfig.flag("MADEIRA_DOCK_START_UNITY_DATA"))`
   and the patch changes that line to `...UNITY_DATA"),` plus a new line `dllLinks: MadeiraConfig.flag("MADEIRA_DOCK_START_DLL_LINKS"))`. Fix: update that check (e.g. look for `unityData: MadeiraConfig.flag("MADEIRA_DOCK_START_UNITY_DATA")` without the closing parens, and add a check for the new dllLinks line), in the same patch. The script exits 1, so macOS CI goes red.
2. BLOCKER (likely): the new env switch is not in `app/Madeira/ConfigCatalog.generated.swift` (the UNITY_DATA switch is, line 44). `tests/host/check-config-catalog.py` runs `build/tools/gen-config-catalog.py --check` and fails when the generated file differs ("so a new env switch cannot be added without appearing in Settings"). Run the generator and put the generated diff in the patch. UNCHECKED whether it fails today for this exact reason: in my scratch copy the generator also reported "out of date" on an unpatched copy, so my copy may be incomplete.
3. RECOMMENDED: add fixture coverage (the fixture never passes dllLinks: true, see 3), see "Suggested edits".

## (1) Compile, by reading
- `try removeDllLinks(...)` / `try linkDlls(...)` inside `static func apply`: legal, they are inside the existing `do { } catch`. The two new private static funcs are `throws`, called with `try`. OK.
- `for name in try files.contentsOfDirectory(atPath: from.path).sorted() where name.lowercased().hasSuffix(".dll") {`: `try` inside the sequence expression of a for-in is allowed in a throwing function; `where` clause has no `try` of its own. OK. `name` is String (contentsOfDirectory returns [String]).
- `text.split(separator: "\n") where !name.contains("/") && !name.hasPrefix(".")`: `name` is Substring. `Substring.contains("/")` resolves (Character literal or Foundation StringProtocol.contains, both fine; common idiom). `hasPrefix(".")` fine. split drops empty lines by default. A "\r\n" manifest would keep "\r" in the name; not produced by this code. OK.
- `try made.joined(separator: "\n").write(toFile: target.path + linksSuffix, atomically: true, encoding: .utf8)`: String.write(toFile:atomically:encoding:) exists in Foundation and throws. OK.
- `isLink(link, files: files)`: existing `private static func isLink(_ url: URL, files: FileManager) -> Bool` in the same enum, called with the right labels. OK. `attributesOfItem` on a symlink describes the link itself (lstat), so a dangling link is seen as a link; that is why the `fileExists || isLink` pair is right (fileExists follows links and says false for a dangling one).
- `let from = ...` as a local name and then `relativePath(from: into, to: ...)`: a local named `from` does not clash with an argument label. OK.
- `relativePath` is `static func` (not private), used correctly.
- `private static let linksSuffix` declared after use inside the same enum: order does not matter. OK.
- Default parameter order `unityData: Bool = true, dllLinks: Bool = false, files: FileManager = .default`: the only existing call sites are ContentView (labels unityData/dllLinks, in order) and the fixture (uses `unityData:` or nothing, never `files:` positionally). OK. grep over app/ finds no other apply( caller.
- `MadeiraConfig.flag("MADEIRA_DOCK_START_DLL_LINKS")` in ContentView: signature `flag(_ name: String, fallback: Bool = true)`, default on unless `env.NAME = 0` (madeira.cfg) or env var "0". Matches the README. DockStartProgram.swift itself still uses no app type; the host fixture still compiles it alone. OK.
- Nothing else in the file is touched. No compile error found by reading; UNCHECKED by a compiler.

## (2) Correctness
- Link destination: for a link at `into/<name>`, the code writes `relativePath(from: into, to: from/<name>)`. A relative symlink is resolved against the link's own folder (= `into`), so this is right. Halo example: into=`<game>`, from=`<game>/MCC/Binaries/Win64` gives `MCC/Binaries/Win64/steam_api64.dll`. Both URLs are `.standardizedFileURL` (no symlink resolution, same on both sides), so it is consistent. The same helper is already tested for the Unity link (`u-rel` in the fixture).
- Same folder: `guard enabled, from.path != into.path else { return }` after the stale links are removed. 7 Days to Die, Rust, Assetto Corsa, Fallout NV (program and launcher in one folder) link nothing. Case/trailing-slash difference in paths: both come from the same `folder` base, so equal in practice.
- Real file with a DLL's name in the launcher's folder: `if files.fileExists(atPath: link.path) || isLink(link, files: files) { continue }`. Skipped, not listed in the manifest, never touched at restore. Note the consequence: that real DLL is the one used (could be a different version than the one beside the program). A symlink that is not ours is also skipped and not listed. Good.
- Stale manifest / second start: `linkDlls` calls `removeDllLinks` first (removes our listed links and the manifest), then re-creates. So every Dock start with a cross-folder program deletes and re-makes N links (N = number of DLLs in the program folder; Halo's folder: at least the 8 in the log). Cheap, but it means a manifest line whose link was replaced by a real file is not removed (only symlinks go; see below). Correct.
- Two different choices in a row: A (other folder) then B (same folder or none) removes A's links first. A then C (another folder): removed, re-linked to C's folder. Correct. Launcher changed between runs (Steam's entry differs): the old manifest is named after the old launcher and would be left; very unlikely, harmless (symlinks only).
- Restore removes only ours: `removeDllLinks` reads `<launcher>.madeira-dlllinks`, filters names, removes an item only if `isLink` (lstat type = symbolic link), then removes the manifest. A real file or folder with a listed name is never removed. A listed name that is now a link someone else made would be removed (theoretical).
- Path traversal via the manifest: names containing "/" or starting with "." are skipped; so ".." , "../x", "a/b", ".hidden" cannot be used. Only plain names inside the launcher's folder, and only if they are symlinks. A name with a backslash is a plain file name on iOS. Acceptable. The manifest is written by us and sits in the game folder, so only a hostile local writer could change it.
- Does restore always run? The call `try removeDllLinks(for: target, files: files)` is the FIRST line of the restore branch, before `removeDataLink` and before the launcher is moved back. If removing a link or the manifest throws (read-only, odd permissions), `apply` returns `.failed` and the kept launcher is NOT put back that start. Same exposure exists for removeDataLink, but there it is one link. Suggested: `try?` for the cleanup in the restore branch, or do the launcher move first.
- Partial failure while linking: links are made one by one and the manifest is written only at the end. If `createSymbolicLink` throws on the 5th DLL (or the manifest write fails), the earlier links exist but nothing lists them, so they stay forever (the next start skips them as "isLink" and never removes them). apply returns `.failed` although the swap itself already happened. Suggested: collect, and on a throw write the manifest first / `defer` the write, or use `try?` per link and log how many were made.
- Outcome value: `linkDlls` does not change the returned Outcome. A first start with a program that was already swapped (copy in place) but new links returns `.unchanged`; the ContentView log still prints because `program != nil`, but it shows nothing about links. Suggested: log the count ("linked N DLLs") so the next Halo log proves the links were made.
- Whole-folder scope: for ANY chosen program in a different folder than the launcher, every ".dll" of the program's folder is now linked into the launcher's folder, default on, including for existing users who already picked such a program. Names that exist are skipped, so it only adds. If the roles are reversed (program in the root, launcher in a subfolder, e.g. `Launcher/x.exe`) the root's DLLs are linked into the subfolder. Harmless for lookups by name, but it is a bigger change than "Halo only". The README says this correctly ("When a Dock swap puts a program from another folder over the launcher").
- RISK to the goal itself (UNPROVEN): the copy runs as `<game>/mcclauncher.exe`, so the module path Windows reports is the game root, not `MCC/Binaries/Win64`. Unreal-style games commonly derive the content root from the exe's own folder (`../../..` from Binaries/Win64). From the root that points outside the game folder, so the DLLs may load and the next wall may be a content-path one. I have not verified how Halo MCC finds its content. The README already says "Halo's real next wall after the DLLs load" is open; add this as a likely candidate.
- Do symlinked DLLs load in this Wine on iOS: UNCHECKED (the README says so too). The Unity precedent is a folder link, which works. Wine opens files with normal open/stat, which follow links; I did not find a case in the app that blocks symlinks, but I did not test.

## (3) Does the existing fixture still pass? (reading, plus the Python source checks run)
Swift fixture: not run (no swiftc). By reading, all results are unchanged, because the fixture calls `apply` without `dllLinks`, so the default `false` applies:
- Restore path (`none`, `same`, `steam`, `after`, `u-steam`, `u-realsteam`): `removeDllLinks` runs first; no manifest exists, `try? String(contentsOfFile:)` is nil, `guard ... else { return }`; nothing changes. Outcomes `unchanged` / `restored` are decided by the lines after it, untouched.
- Swap path (`swap`, `again`, `repaired`, `other`, `u-swap` ... `u-on`): `linkDlls` runs after the copy and before `linkData`. It calls `removeDllLinks` (nothing to remove), then `guard enabled` fails (enabled is false) and returns before reading any directory. No file is created. `again`/`u-again`/`u-realsteam` keep `unchanged` (copied false, linkData decides).
- `bin/Other.exe` over `FalloutNVLauncher.exe` (different folders) would link `bin/*.dll` if enabled; with false it links nothing, and `bin/` has no DLLs anyway.
- Fallout NV (FalloutNV.exe beside FalloutNVLauncher.exe) and 7 Days to Die (7DaysToDie.exe beside 7dLauncher.exe, plus the `_Data` link): same folder, so a real run (flag on) also links nothing. The Unity data link code is unchanged and runs after linkDlls.
Python source checks, run on the patched scratch copy: all PASS except the one in blocker 1 (the exact-text UNITY_DATA check). Everything else (apply is called after the "no session runs" guard and before DockInstallers.prepare, the Xcode project count of 4, no `removeItem(at: folder`) still passes. The fixture itself has NO test for dllLinks: true; none of the new code (links made, skipped real file, manifest, restore, stale links, traversal names) is exercised by CI. Suggested additions in the "Suggested edits" below.

## (4) Risks
- Steam verify/update: Steam checks files in its manifest. Extra files and links in the game folder are not in any depot, so verify should ignore them; verify would re-download a changed launcher (existing, see the dock-eac-offline review, covered by "repaired"). UNCHECKED: whether Steam's updater ever deletes unknown files in the install folder or follows symlinks while hashing; I did not find evidence either way. If it deleted our links, the next Dock start re-makes them (the manifest entries would just not be links any more and are skipped at restore).
- A depot file with the same name as a link: we never create over an existing name. If a later game update adds a DLL with a linked name, Steam would write over/through our symlink. Writing through a symlink could modify the program folder's real file with the downloaded content (same content, since it is the same depot name? not necessarily, it lands in the root's name, Steam's own write target). UNCHECKED, low probability: the DLLs are in the program's folder, not the root.
- Cloud saves: Auto-Cloud patterns are for save files; DLL links should not match. UNCHECKED per game.
- Disk: symlinks cost nothing; the exe copy is the existing cost. The manifest is a few hundred bytes. Other Madeira code that walks the install folder (size, Get Help files.txt, move/copy library) could see N extra entries; a walker that follows links could double-count or loop. I did not audit those walkers: UNCHECKED. `grep` shows no other code in app/ reading `.madeira-launcher` or the new suffix.
- Program picker: lists .exe only (existing), so the manifest file does not appear.
- Off: `env.MADEIRA_DOCK_START_DLL_LINKS = 0` makes `dllLinks` false, so the next Dock start removes listed links (they are removed in linkDlls before the guard) and makes none. That is a true "old behaviour" except that links removed need a Dock start, same as the other switches. README's statement matches the code. The switch line exists, so the WORKFLOW step 2 requirement is met (catalog entry missing, see blocker 2).
- Offline/old games: none other than the cross-folder choice are affected. Games that currently use "Steam starts" with a different-folder program on a user's phone (unknown list; Borderlands 2 `Binaries/Win32/Borderlands2.exe` is the example in the fixture) will get links at their next Dock start. Those games previously could not find DLLs next to a root-level copy either, so this is likely an improvement, but it changes behaviour for them by default.

## (5) Files, golden games, INDEX
Files touched: app/Madeira/DockStartProgram.swift (apply signature, restore branch, new linkDlls/removeDllLinks), app/Madeira/ContentView.swift (one call, ~4012-4014; this is the Dock start path, shared with all Dock games). Also needed: tests/host/check-dock-start-program.py, ConfigCatalog.generated.swift.
Other users of `apply`: only ContentView. Users of `chosen/setChosen` unchanged.
INDEX.md entries that matter (line numbers in /mnt/project-files/INDEX.md):
- line 121: Unity "Data folder not found" fix dock-start-unity-data 3fc36fec, WORKS Wave 16, `env.MADEIRA_DOCK_START_UNITY_DATA = 0`. Invariant: the data link must still be made and removed exactly as before.
- line 127: Across the Obelisk, `launcher=dowser.exe program=AcrossTheObelisk.exe unchanged` (Wave 13 had no Unity-data fix). Invariant: the `unchanged` outcome and its log line.
- line 225: 7 Days to Die (251570) WORKS on Wave 16 via Madeira Dock + Steam starts = 7DaysToDie.
- line 20-21 and 290: Fallout: New Vegas WORKS (0.2.77 launcher hang fix by Cameron Nov 22; golden 10, 32-bit). The FNV launcher and FalloutNV.exe are in one folder.
- reference/index-structured.md line 11: MUST NOT BREAK: Steam launch for games that work now (golden 2, 7 Days to Die via Dock).
Golden games to run (2 launches each, 60 s+):
- #2 7 Days to Die via Madeira Dock with Steam starts = 7DaysToDie.exe: proves swap + Unity data link + same-folder = no DLL links, and that "Steam's choice" restores. Also run it once with the choice switched back to Steam's own program and check `7dLauncher.exe` is the original and `7dLauncher_Data` is gone.
- #10 Fallout: New Vegas via the way that works for Cameron (Dock + Steam starts = FalloutNV.exe).
- Any other golden game started through Dock (none besides these two are listed).
- The new thing itself: Halo MCC via Dock, Steam starts = MCC/Binaries/Win64/MCC-Win64-Shipping.exe; check the log line, `ls` of the game folder for the links and `mcclauncher.exe.madeira-dlllinks`, then switch to Steam's own program and confirm the links and the manifest are gone and `mcclauncher.exe` is the original. Not a golden game.
Also (rule 3 of the Nov 20 anti-regression list: one change per build where possible): this and dock-eac-offline both edit DockStartProgram.swift and the Dock start path; they apply together cleanly per the README (UNCHECKED by me), but a Dock regression in the same build would point at two causes. The two switches (`MADEIRA_DOCK_START_DLL_LINKS`, `MADEIRA_DOCK_START_EAC_OFFLINE`) allow bisecting.

## Suggested edits (author's choice; the first two are the blockers)
1. Update check-dock-start-program.py: the exact-text UNITY_DATA check and a new check `dllLinks: MadeiraConfig.flag("MADEIRA_DOCK_START_DLL_LINKS")` in `start`.
2. Run build/tools/gen-config-catalog.py and include ConfigCatalog.generated.swift in the patch.
3. Add fixture lines to main.swift (the fixture compiles only DockStartProgram.swift + main.swift, so it works): a game folder `Halo/` with `Binaries/Win64/Shipping.exe`, `a.dll`, `b.DLL`, `x.txt` and a root `launcher.exe` plus a real root `b.DLL`; check (a) dllLinks true links `a.dll` only and `b.DLL` stays a real file, the manifest lists only `a.dll`, `Binaries/Win64/a.dll` content readable through the root link, (b) a second start gives the same, (c) dllLinks false removes the link and manifest, (d) `program: nil` restore removes link and manifest and the real `b.DLL` is untouched, (e) a hand-written manifest naming `../evil.dll`, `.hidden`, a real file name -> nothing outside or real is removed. Map `isLink`-style results with `destinationOfSymbolicLink`.
4. Make the cleanup in the restore branch non-fatal (`try?`) so a link that cannot be removed never stops the launcher from being put back, and write the manifest even when linking throws part-way.
5. Log the number of links in the Dock start line.
6. README: add the content-path risk (exe path reported as the game root) to Unchecked, and say the switch needs a Dock start to take effect and that all cross-folder choices are affected.

Not verified by me: compile, device behaviour, Steam updater behaviour with symlinks, whether the Halo copy finds its content from the game root, other folder walkers in the app.

---

# Re-review: -2 (fresh reviewer, Nov 26 2026; only what changed)

Applied dock-start-dll-links-2.patch to a scratch copy of 0.2.101 (patch -p1, clean) and ran `python3 -I tests/host/check-dock-start-program.py`: every line PASS, Swift part SKIPPED (no swiftc). Nothing compiled; no device run.

## VERDICT: OK TO QUEUE, with the catalog regeneration done by the build thread (blocker 2 below) as the one condition.

## Blocker status
1. Host check text: FIXED, PROVEN by the run above. ContentView now has `dllLinks: ...` on the line before `unityData: MadeiraConfig.flag("MADEIRA_DOCK_START_UNITY_DATA"))`, so the old exact-text check still matches; the new check (`dllLinks: MadeiraConfig.flag("MADEIRA_DOCK_START_DLL_LINKS")` in `start` and `madeira-dlllinks` in source) passes.
2. ConfigCatalog.generated.swift: NOT in the patch (README says the build thread regenerates it; the generator needs the git checkout). Acceptable only if the pre-build step does it: `build/tools/gen-config-catalog.py`, then check-config-catalog.py must pass. Unchecked here. Put it on the build thread's list for this fix.

## Signature reorder: no caller breaks
`apply(launcher:program:folder:dllLinks: = false, unityData: = true, files: = .default)`. grep of all callers: ContentView.swift 4012 (labels in the new order, dllLinks then unityData: correct) and the fixture main.swift in check-dock-start-program.py (lines 100-111, 149-159). The fixture calls use only `launcher/program/folder`, plus `unityData: false` once (line 153). Omitting a defaulted parameter that sits before another labelled one is legal, and labels are still in declaration order. No other `apply(` caller in app/ or tests/. OK.

## `defer` in linkDlls (reading)
```
guard enabled, from.path != into.path else { return }
var made: [String] = []
defer {
    if !made.isEmpty { try? made.joined(separator: "\n").write(toFile: target.path + linksSuffix, atomically: true, encoding: .utf8) }
}
for name in try files.contentsOfDirectory(...)... { ...; made.append(name) }
```
- Scope/order: `made` is declared before the `defer`, so it is in scope; defer reads the variable when the function exits, so it sees the final value (after the loop), also when the loop throws part-way (links created so far are listed), and on the normal exit. The early `guard ... return` is before the defer is registered, so it does not run it (nothing made, correct). The first line `try removeDllLinks` is also before.
- Compile: `try?` inside a defer is allowed (a defer body cannot throw, `try?` does not). `String.write(toFile:atomically:encoding:)` throws, `try?` swallows. The `try?` result is `()?` and unused: Swift does not warn for that. Defer in a `throws` function is fine. `made` is mutated in the loop and captured by reference by defer: legal for a local var. No label or scope problem.
- Behaviour: if the manifest write itself fails (disk full), the links stay unlisted (silent). Very low risk; acceptable, but a log line would be nicer. Same-start second run: `removeDllLinks` at the top removes the old manifest first, then the defer writes a new one. Correct.
- When the loop throws, `apply` still returns `.failed`, with the swap done and the partial links listed; next start restores or re-links them. OK.

## `try?` in the restore path
`try? removeDllLinks(for: target, files: files)` is now first in the restore branch. A failure to remove a link or the manifest no longer blocks putting the launcher back. Inside removeDllLinks the first throwing `removeItem` aborts the loop, leaving the remaining links AND the manifest in place (the manifest is removed last), so the next start retries the whole list: links already removed are no longer links and are skipped, so it is safe and idempotent. Cost: leftover links stay until a later start. In `linkDlls` the call is still `try removeDllLinks(...)` (not `try?`): a failure there fails the swap for that start with `.failed` before any new link is made and leaves Steam's program started as before (the copy is already in place, so the chosen program still runs, just without new links). Acceptable; if you want the DLL feature never to break the swap, make that one `try?` too (optional).
Restore still returns the same outcomes (`.restored`/`.unchanged`): the removal result never affects them, so the earlier fixture analysis (3) still holds: default `dllLinks=false`, no manifest, no change.

## Other earlier points still open (unchanged, from the first review)
- Fixture has no `dllLinks: true` case (suggested edit 3); not added. CI cannot catch a regression in the new code. Not a blocker; a build-thread-run device test of Halo and the golden games stands in.
- Log line has no link count (suggested 5), content-path risk for Halo (unproven) and symlinked DLL loading in Wine (unchecked) stay as written.
- Golden games to run are unchanged: 7 Days to Die via Dock (+ restore to Steam's own), Fallout: New Vegas; plus Halo MCC as the target test.
