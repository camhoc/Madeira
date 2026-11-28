# Mullion D3D12 lane (d3d12 = mullion) — triangle proof, step 1 of mesh shaders

Requested by Cameron, Nov 23 2026 (picked "Mullion, triangle proof first" on the mesh-shader route card).
Thread: Add mesh shaders to KosmicKrisp. Plan + comparison: plans/kk-mesh-shaders-plan-2026-11-23.md.

## What it is
Mullion (github.com/dttdrv/mullion, rev 11e77a8 of Nov 22, LGPL-2.1+, DXMT parts MIT) is DXMT's D3D12-on-Metal
fork. It already reports Mesh Shader Tier 1 on every Apple GPU and can reach DX12 Ultimate (FL 12_2).
This adds it as an OPT-IN lane next to madeira-d3d12 and vkd3d, for x64 games only. Default changes nothing.

## Off switch
- Per game: `d3d12 = mullion` in that game's own config turns it on. Anything else = today's behaviour.
- Build: ntdll-unix only binds Mullion's tables when built with MADEIRA_MULLION=1. Without it the lane's DLLs
  load but find no unix side (the session log then shows the winemetal bind failing for "mlnmetal").

## Files
- build/mullion-ios/build.sh: checks out Mullion 11e77a8, applies patches/0001-0002, builds its unix side for
  iOS (winemetal unix, cache, airconv, DXBCParser) into ONE prelinked object whose only globals are
  mullion_winemetal_unix_call{,_wow64}_funcs (ld -r -exported_symbols_list + an nm check), and adds it to
  app/Madeira/libdxmt_combined.a. Must run AFTER tools/build/build-dxmt-ios.sh (that recreates the archive).
- build/mullion-ios/build-pe.sh: ARM64EC DLLs into app/Madeira/vulkan/mullion/ (inside the existing "vulkan"
  folder reference, so no Xcode project change): d3d12, d3d12core, dxgi, d3d11, d3d10core, mlnmetal.
  Fails if any DLL still imports winemetal.dll.
- build/mullion-ios/patches (Mullion):
  0001 winemetal unix for iOS: UIKit/stub headers like our DXMT; @available/API_AVAILABLE get iOS versions
       (macOS 15->iOS 18, 16/26->26, 26.4, 27.0); SDK checks via MLN_SDK_AT_LEAST; Mac-only code gated:
       displaySyncEnabled, NSView host-view fallback (wineios.drv exports macdrv_functions, same path our
       DXMT uses), CGDisplay/ColorSync/NSScreen (iOS: one display, sRGB, SDR), managed buffers,
       setShouldMaximizeConcurrentCompilation, shared-texture mach port (0, as ours, ml866), IOKit GPU
       core count (iOS: 4, a safe low guess, or env MADEIRA_MULLION_GPU_CORES) and GPU statistics (none).
       ObjC classes CacheReader/CacheWriter/WMTListenerHold/WMTSharedNameKeeper renamed on iOS (ours has
       CacheReader/CacheWriter too; ObjC class names are process-wide). Tables renamed.
  0002 meson options: winemetal_name (PE winemetal under another name, Madeira uses mlnmetal; trace.cpp
       finds it) and build_unix_side=false (Windows DLLs only).
- patches/madeira/0001-d3d12-mullion-lane.patch (Madeira, applies to 0.2.96 source):
  virtual_ios.c "mlnmetal" branch (under MADEIRA_MULLION; 64-bit callers only), ntdll-unix/build.sh MADEIRA_MULLION=1 flag,
  WineProcessBridge.m madeira_setup_mullion() links the six DLLs into system32 + sysx64; refuses with
  d3d11 = dxvk; log lines start "[mullion]".
- build/d3d12-triangle: triangle12.exe (x86_64, plain C, SM 5.0 DXBC made at build time like d3d11-triangle).
  Logs "[d3d12-triangle]" lines: adapter, max feature level, MeshShaderTier, frame 1..600, done.
  Compile-checked in the cloud with mingw-w64 gcc (with stub shader headers): builds, imports d3d12+dxgi.

## Build thread steps
1. tools/build/build-dxmt-ios.sh as usual, then build/mullion-ios/build.sh.
2. Build ntdll-unix with MADEIRA_MULLION=1.
3. build/mullion-ios/build-pe.sh (after build/windows-runtime so wine/build-arm64ec exists).
4. Apply patches/madeira/0001-d3d12-mullion-lane.patch.
5. build/d3d12-triangle/build.sh; copy triangle12.exe into the same iCloud folder as the IPA (not into the app).
Expect compile errors on the first try in 0001 (NOT compiled: the cloud has no iOS SDK). Fix in place, keep
every change iOS-only (#if TARGET_OS_IOS) so Mullion's Mac build stays identical.

## Test (Cameron)
Add triangle12.exe as a game, give it `d3d12 = mullion`, run it. Pass = a coloured triangle on a dark blue
background for ~10 s and the log has "[d3d12-triangle] done: 600 frames" and a "MeshShaderTier 1" line.
Then the same exe without the line (madeira-d3d12) for comparison.

## Next (not in this PR)
Microsoft's MIT D3D12 mesh shader sample (MeshletRender, needs DXC-built DXIL) on the same lane.

Credits: Mullion by dttdrv, Avery Felts (aaf2tbz) and contributors (LGPL-2.1+); DXMT by 3Shain (MIT).
No BCD code. No AGPL.
