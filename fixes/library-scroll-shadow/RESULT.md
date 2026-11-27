# RESULT: library-scroll-shadow

**CONCERNS / NEEDS-MAC, NEEDS-DEVICE**

Checked 2026-11-27 on Linux against the 0.2.180-og source zip.

## What was run
Patch applies to the 0.2.180-og tree (git apply). Swift NOT typechecked or compiled (no Xcode here).

## Findings
- `=0` restores the old look exactly.
- With it on, a `.shadow` with opacity 0 and radius 0 remains and may still render off-screen; better to omit the modifier.
- Covers without art will look darker (see-through fill over a new black shape), so "same look" is not true there.
- Performance gain is unproven.

## Swift typecheck added (2026-11-27)
Earlier lines saying Swift was not typechecked are now out of date.
- Linux, Swift 6.4.3 + iOS SDK, target arm64-apple-ios17.0, all app Swift files with this fix applied: no new errors.
- The one error is also in the unpatched app: ContentView.swift:1046, Squeeze needs iOS 17.5.
- Typecheck only: not linked, no IPA, not run on a device. All .swift files on disk were checked, so a file missing from project.pbxproj would NOT show up here.
