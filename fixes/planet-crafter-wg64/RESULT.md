# RESULT: planet-crafter-wg64

**FAIL**

Checked 2026-11-27 on the Linux laptop against 0.2.180-og.

## What was run
Applies with `patch -p1`. Swift typecheck of all app files with the patch (Linux, Swift 6.4.3 + iOS SDK, target ios17.0): no new errors. The one error (ContentView.swift:1046, Squeeze needs iOS 17.5) is also in the unpatched app. Not linked or run. check-game-recommendations.py: exit 1.

## Findings
- First error: AssertionError listing the preset IDs. The test's expected ID set does not include `planet-crafter`; update it (and its title counts).
