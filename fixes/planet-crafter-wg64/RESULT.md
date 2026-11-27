# RESULT: planet-crafter-wg64

**PASS / NEEDS-DEVICE**

Updated 2026-11-27 on the Linux laptop against 0.2.180-og.

## Fixed and run
The patch now also updates check-game-recommendations.py (new ID, title count 75, list count 104, and planet-crafter added to the lists exempt from the fork defaults). Applies with `patch -p1`; the host test exits 0; the app Swift is unchanged from the version that typechecked with no new errors.

## Still open
- The test's Swift fixture (75/104 counts) did not run here.
- Combining with cyberpunk-direct-start will conflict in the test counts and ID list.
- Not run on a device; second review of the settings still pending.
