# RESULT: gmod-sandbox-reparse

**PASS (review) / NEEDS-DEVICE**

Checked 2026-11-27 on Linux against the 0.2.180-og source zip.

## What was run
Patch is already applied in the 0.2.180-og tree (reverse-apply check succeeds). Code read only: the touched module was NOT built and nothing ran on a device.

## Findings
- All reparse flags in unix/file.c are gated; unset or `0` keeps the old logic.
- Root cause is still unproven. Keep the switch in GMod's own config only (delete-through-symlink risk).
