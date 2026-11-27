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
