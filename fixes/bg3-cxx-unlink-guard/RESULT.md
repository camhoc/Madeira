# RESULT: bg3-cxx-unlink-guard

**PASS (review) / NOT COMPILED**

Checked 2026-11-27 on the Linux laptop against 0.2.180-og.

## What was run
Applies to wine/. msvcrt/except.c could NOT be compiled: 'unknwn.h' file not found, on unpatched source too (Wine is not configured here).

## Findings
- Guard only acts when the frame list is empty; non-empty behaviour is unchanged.
- The new exc_record NULL check is not covered by the off switch.
- Root cause of the empty list is unproven.
