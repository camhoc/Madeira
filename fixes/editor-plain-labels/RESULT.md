# RESULT: editor-plain-labels

**PASS (review) / NEEDS-MAC**

Checked 2026-11-27 on Linux against the 0.2.180-og source zip.

## What was run
Patch applies to the 0.2.180-og tree (git apply). Swift NOT typechecked or compiled (no Xcode here).

## Findings
- Types and the new mouse hint match the code. The `LayerButtons` rename also changes two panels in ContentView.swift, as the README expects.

## Swift typecheck added (2026-11-27)
Earlier lines saying Swift was not typechecked are now out of date.
- Linux, Swift 6.4.3 + iOS SDK, target arm64-apple-ios17.0, all app Swift files with this fix applied: no new errors.
- The one error is also in the unpatched app: ContentView.swift:1046, Squeeze needs iOS 17.5.
- Typecheck only: not linked, no IPA, not run on a device. All .swift files on disk were checked, so a file missing from project.pbxproj would NOT show up here.
