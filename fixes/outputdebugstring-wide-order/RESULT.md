# RESULT: outputdebugstring-wide-order

**CONCERNS / NEEDS-DEVICE**

Checked 2026-11-27 on Linux against the 0.2.180-og source zip.

## What was run
Patch is already applied in the 0.2.180-og tree (reverse-apply check succeeds). Code read only: the touched module was NOT built and nothing ran on a device.

## Findings
- The wide/ANSI parameter order fix is correct.
- signal_arm64ec.c:6501 keeps the FIRST 600 messages per code, not the last, so the lines before exit(1) can still be lost, which is the stated goal.
- Messages from other threads are dropped while one prints; about 3000 extra lines per run for every game, with no off switch.
