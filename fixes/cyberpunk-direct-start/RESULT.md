# RESULT: cyberpunk-direct-start

**PASS**

Checked 2026-11-27 on the Linux laptop against 0.2.180-og.

## What was run
Applies with `patch -p1`. Swift typecheck of all app files with the patch (Linux, Swift 6.4.3 + iOS SDK, target ios17.0): no new errors. The one error (ContentView.swift:1046, Squeeze needs iOS 17.5) is also in the unpatched app. Not linked or run. check-game-recommendations.py exit 0 (its Swift fixture needs a Mac/swift run and was not covered).

## Findings
- Second review: the empty-matcher SteamTitle row cannot match anything by itself. The 75/104 Swift fixture counts are still unrun.
- planet-crafter-wg64 edits the same file and table; combining the two will need the test's counts and ID list updated.
