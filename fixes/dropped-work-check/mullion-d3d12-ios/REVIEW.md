# REVIEW: mullion-d3d12-ios

- License: Mullion LGPL-2.1+ (its DXMT-derived files MIT). Copy allowed with credit (rule 5). Patches 0001-0003
  are ours under Mullion's license. LGPL: we ship Mullion's DLLs and a prelinked object inside the app; the
  patched source must be published with the build that carries it (source zip already goes with builds).
  No BCD code. No AGPL files.
- Off switches: per-game `d3d12 = mullion` (default off); build flag MADEIRA_MULLION=1 (default off);
  env MADEIRA_MULLION_GPU_CORES (core-count guess, default 4).
- Symbol isolation: Mullion's unix side is one ld -r object with only its two tables global (build.sh checks
  with nm). ObjC classes renamed on iOS. PE winemetal renamed mlnmetal.dll (build-pe.sh checks imports).
- Checked in the cloud: both Mullion patches apply to 11e77a8 in order; the Madeira patch reverse-applies to
  the 0.2.96 source it was made from; both shell scripts pass bash -n; triangle12.c compiles with mingw-w64.
- NOT checked: any iOS compile, the meson PE build, the link, anything on device. Whether Mullion's PE side
  makes Mac-only assumptions (it reads the OS version: iOS 26/27 is read as macOS 26/27): unproven.
- Known gaps: no 32-bit (Mullion D3D12 is 64-bit only); Madeira's present-size fix (ml1140) is not ported
  (it is off for 64-bit callers in our DXMT anyway); no Library UI picker entry (config line only).
- Second review: see below.

## Second review (Nov 23, separate reviewer, read-only, not compiled): PASS with fixes. All 6 fixed:
1. GPU core default 10 could make "all at once" dispatch parts too big on 5-6 core GPUs (spin forever):
   now 4 (lower is safe). 2. build.sh failed on a 2nd run (untracked mullion_ios.h): git clean -fdq added.
3. build/dxmt-ios refresh copies its own libdxmt_combined.a over the app's and would drop Mullion's member:
   build.sh now adds it to both. 4. Mullion's wow64 table is upstream WoW64: 32-bit callers now refused
   (funcs_wow64 = NULL). 5. Stale Mullion links into a non-ARM64EC session: all six names cleaned.
6. build-pe.sh now always reconfigures. Reviewer also confirmed: no macOS-only API outside !TARGET_OS_IOS,
   #if blocks balance, availability mappings sane, class/table isolation complete, triangle12.c API use correct.
