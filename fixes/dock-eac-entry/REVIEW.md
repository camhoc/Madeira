# Second review: dock-eac-entry-1

Reviewer: fresh second review (read only, no compiler), Nov 28 2026. `patch -p1 --dry-run` on a copy of the 3 base files from 0.2.180: applies cleanly.

## Verdict: OK to queue
Nothing blocks it. Two small code changes are recommended (F1, F2) and the README needs 4 wording fixes (R1-R4). The patch can be queued as it is, or as rev 2 with F1 and F2.

## 1. Compile
- Project is `SWIFT_VERSION = 5.0` (pbxproj), not Swift 6 language mode. Everything below holds in both.
- `nonisolated(unsafe) static var eacEntryEnabled: () -> Bool = { true }`: the same declaration as the existing
  `eacOfflineEnabled` in the same `enum DockStartProgram`, so it builds exactly as that one does. File is still Foundation-only (host check compiles it alone).
- Tuple-array parameter `[(index: UInt32?, executable: String)]`: valid. At the call site
  `list.map { (index: $0.index, executable: $0.executable) }` infers the same labelled tuple type. OK.
- `options` is `[SteamLaunchOption]?` (see `options.map { "\($0.count) entries" }` and `options.flatMap` above it), so `if let list = options` is correct.
  `SteamLaunchOption.index` is `UInt32?`, `arguments`/`type`/`executable` are non-optional `String`. All uses match.
- `$0.index.map { String($0) }` inside `list.map { ... $0 ... }`: NOT a problem. Each closure gets its own anonymous arguments and the inner `$0` shadows the outer one (the common `xs.map { $0.map { $0 + 1 } }` pattern).
  The error people remember ("anonymous closure arguments cannot be used inside a closure that has explicit arguments") applies only when the outer closure names its parameters, and this one does not.
- Quotes inside `\( )` (`?? "-"`, `? "-" :`) are valid since Swift 5.
- `chosen = index`: `chosen` is `var UInt32?` (from `steamEntry?.launchIndex`), `index` is `UInt32`. OK.
- Nested `func norm` called from the non-escaping `first(where:)` closure: OK. `String.removeFirst(2)` exists.
- Only small risk: the `described` closure is one long interpolated expression with two ternaries, a `??` and a nested closure. It should type-check because `$0` is known, but it is the kind of expression that can hit "unable to type-check in reasonable time". F3 removes that risk if the build thread sees it.

## 2. Other games / off switch
- The ContentView block is guarded by `DockStartProgram.eacOfflineEntry[game.id] != nil`, and only 976730 is in the table. For every other appID nothing runs, nothing is logged, and `chosen` is unchanged. No change for other games. CONFIRMED.
- Off switch: `MadeiraConfig.flag(name, fallback: true)` reads `all()["env." + name]` when madeira.cfg is present and returns `v != "0"`, otherwise it falls back to `getenv`. So `env.MADEIRA_DOCK_EAC_ENTRY = 0` really turns it off. `eacOfflineEntryIndex` then returns nil, `chosen` stays `steamEntry?.launchIndex`, and the only difference from 0.2.180 is the "no entry used" log line, as the README says. CONFIRMED.
- Catalog: gen-config-catalog.py finds `MadeiraConfig.flag("...")` by regex (CFG/ENV patterns), so regenerating picks the switch up. `--check` fails if ConfigCatalog.generated.swift is not regenerated, so the README's build step is needed and correct. A curated entry (like `env.MADEIRA_DOCK_LAUNCH_FALLBACK`, line ~777) is optional.

## 3. Interactions
- Index path, traced: `chosen` -> `let launchOption = chosen ?? 0` (ContentView ~4015, logged as `[madeira-dock] launch option N`) -> `MadeiraDock.configure(game, launchOption:)` -> `setenv("MADEIRA_STEAM_HOST_LAUNCH_OPTION")` -> launch.c:251-255 parses it -> it goes into the launch call (launch.c:403 and the retry at :563). So `chosen` really is what gets passed.
- Index meaning: `SteamLaunchOption.index` is the config.launch key (parse() keeps the numeric key, "not the position in the filtered array"). That is the same value `SteamDirectStart.choose` and `dockFallbackIndex` already pass, so this patch adds no new assumption about what Valve's client expects. If the key were wrong, launch.c would log `launch-option-missing` (error 22) and Dock would stop, with no silent wrong start.
- dock-launch-fallback runs only when `chosen == nil`. On a match it is skipped, which is correct. With no match, behaviour is unchanged.
- "Steam starts" swap (ContentView ~4032): `steamEntry` is still the `choose()` result (for MCC presumably mcclauncher.exe, the default), so `apply(launcher:program:)` still acts on mcclauncher.exe. With a stored choice it copies the shipping exe over mcclauncher.exe (plus DLL links in the root). Steam now starts the shipping entry, so that copy is never run: it is harmless but wasted. With no stored choice, `apply(..., program: nil)` puts back a kept launcher, which is good. The README advice to clear the stored choice is fine, but see R3.
- The `[start-scan] entry:` log line still shows `steamEntry` (mcclauncher.exe and its index), not the entry actually used. The `[dock-eac-entry]` and `[madeira-dock] launch option` lines show the truth. Worth knowing when reading logs; no fix needed.

## Recommended code fixes (non-blocking)
F1. Apply the same candidate filter as `dockFallbackIndex` to the match, so a beta-branch or non-Windows entry that names the same exe cannot be picked before the real one (that would end in launch-option-missing):
  in ContentView build `entries` from `list.filter { $0.betaKey.isEmpty && ($0.oslist.isEmpty || $0.oslist.lowercased().contains("windows")) }`
  (keep `described` on the unfiltered `list` so the log still shows every entry).
F2. In `norm`, trim whitespace first: `var p = path.trimmingCharacters(in: .whitespaces).replacingOccurrences(...)`. Steam text is untrusted, and a stray space would quietly stop the match.
F3. (Only if the compiler complains or is slow.) Make `described` an explicit-typed loop, so the long expression is split up:
  `var described: [String] = []; for o in list { let i = o.index.map { String($0) } ?? "-"; let a = o.arguments.isEmpty ? "-" : o.arguments; let t = o.type.isEmpty ? "-" : o.type; described.append("\(i):\(o.executable) args=\(a) type=\(t)") }`

## README fixes
R1. "Valve's client then starts the exe in its own folder": that depends on the entry's `workingdir`, which has not been seen. Say "with the entry's own working folder and arguments (not yet seen for MCC)".
R2. "Every Dock start of Halo logs one `[dock-eac-entry]` line": only when the launch configuration was obtained (`options != nil`). With no configuration there is no line, and Steam's default is used. Add "when Madeira got the launch configuration".
R3. "A stored 'Steam starts' choice ... still swaps mcclauncher.exe": true, but when the entry matches, the swapped file is never started, so it does not affect the test. It matters only when no entry matches. Say that, so a tester does not think the swap is breaking the new route.
R4. The Status line says "Swift fixture skipped": no Swift host test was added for `eacOfflineEntryIndex`, so state "no new host test" rather than suggest one exists.
Everything else checked out: no change for other games, the off switch, the index path and the build step.
