# RESULT: remote-run-status

**CONCERNS / NEEDS-MAC**

Checked 2026-11-27 on Linux against the 0.2.180-og source zip.

## What was run
Patch applies to the 0.2.180-og tree (git apply). Swift NOT typechecked or compiled (no Xcode here).

`check-run-status.py` passes (0 failed) with all queued patches applied.

## Findings
- Signature verification is enforced and fails closed; the off switch works.
- RemoteRunStatus.swift is not registered in project.pbxproj, so the build will fail; ConfigCatalog needs regenerating.
- A signed file with a future `generated` date never expires and blocks later files. Reject dates more than about a day ahead.
- REVIEW.md asks for a decode/older/newer host test; none was found.

## Swift typecheck added (2026-11-27)
Earlier lines saying Swift was not typechecked are now out of date.
- Linux, Swift 6.4.3 + iOS SDK, target arm64-apple-ios17.0, all app Swift files with this fix applied: no new errors.
- The one error is also in the unpatched app: ContentView.swift:1046, Squeeze needs iOS 17.5.
- Typecheck only: not linked, no IPA, not run on a device. All .swift files on disk were checked, so a file missing from project.pbxproj would NOT show up here.
