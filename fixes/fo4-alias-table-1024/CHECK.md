# CHECK: fo4-alias-table-1024
- Laptop-checkable: C/C++/Python only (no Xcode needed). Review the patch, apply it to the 0.2.180 Wine/FEX/dxmt tree, build the touched module, run any tests/host script the README names.
- Already in the 0.2.180 build (not device-tested); this branch is for a second review.
- Base: the patch is written against the Madeira 0.2.180 source tree (release 0.2.180-og, source zip), NOT against this repository's main (older upstream layout). Paths inside the patch are relative to that tree. Do not expect it to apply to main.
- What to verify: see README.md and REVIEW.md in this folder (symptom, change, off switch). FEX IosJitAlias/Module; golden games: Fallout 4, DRG, GTA V Enhanced.
- Report: post the result to the Madeira project (pass/fail, compiler output if any). Do not merge or push to main.
