# CHECK: planet-crafter-wg64
- NOT in any build yet; queued for the next build.
- Base: the patch is written against the Madeira 0.2.180 source tree (release 0.2.180-og, source zip), NOT against this repository's main (older upstream layout). Paths inside the patch are relative to that tree. Do not expect it to apply to main.
- Swift or C++ cannot be compiled on the laptop without the matching toolchain: review the diff, check it is well-formed, and run only host checks the README names.
- What to verify: see README.md and REVIEW.md in this folder.
- Report: write RESULT.md in this folder on this branch. Do not merge or push to main.

## Rev 2 (Nov 27 22:25Z): replaces the first version after your FAIL
The patch now also edits tests/host/check-game-recommendations.py (planet-crafter in the expected id set, recognised-once loop, no-fork-defaults tuple, SteamTitle count +5). Please re-check and replace RESULT.md.
