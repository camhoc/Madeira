# RESULT: planet-crafter-wg64 (rev 2)

**FAIL**

Checked 2026-11-27 on the Linux laptop against 0.2.180-og.

## First error
check-game-recommendations.py exit 1: `FAILED (main.swift line 175): 74 titles in the Steam table, 103 lists`.

## Fix needed
The Swift fixture inside the test still expects steamTitles.count 74 and all.count 103. With this patch they should be 75 and 104 (update the message too).

## Passed
Patch applies with `patch -p1`. Swift typecheck of the app: no new errors (only the existing Squeeze one).
