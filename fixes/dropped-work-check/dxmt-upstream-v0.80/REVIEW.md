# Review: DXMT on upstream v0.80 (camhoc/dxmt madeira/upstream-v0.80, f2fe58c)
Second pass by a non-author, Nov 18 2026 ~10:45 PM MT, thread "Review Wine 11.22 and DXMT changes".
Verdict: OK TO COMPILE, as its own test build. Nothing was compiled or run; reading and script review.

## Findings
D1 (build break, likely). build/dxmt-patches/apply.sh skips a patch only when it reverse-applies
    exactly, and exits 1 when a patch neither applies nor reverse-applies. 0001 (index range)
    reverse-applies cleanly to f2fe58c (checked with the copy in camhoc/Madeira main), so it is skipped.
    0002 (no-video-device) was "re-placed by hand" because d3d11.cpp changed upstream, so it will most
    likely do neither and stop the build. Not checked (0002 exists only on the PC). Move both patch
    files out of build/dxmt-patches when the pin moves.
D2 (must do). The winemetal unix-call table grew from 151 to 170 slots. Slots 0-150 are unchanged
    (compared slot by slot, both the 64-bit and the 32-bit table; only renames), so madeira-d3d12's fixed
    slots 127-150 still line up. But every DXMT Windows DLL that ships prebuilt in the app (arm64ec,
    aarch64 and the 32-bit set: winemetal, d3d11, d3d9, dxgi, d3d10core, nvapi64, madeira_d3d12) must be
    rebuilt from this branch in the same build as libdxmt; an old DLL with the new unix side, or the
    reverse, calls missing slots.
D3 (fine). The shader cache version is now AIRCONV_VERSION = 26 (was our hand-bumped 19), so old
    on-device shader caches are discarded on first run. Expect a slower first launch per game.

## Checked and found fine
- Our four commits: 0001 equals the build patch (reverse-applies); BuildDrawCapture has no caller left
  on the default whole-buffer path by accident (10 call sites, 9 pass (0,0), the indexed draw passes its
  range); the two traces and MADEIRA_D3D11_NO_VIDEO_DEVICE are env-gated and off by default.
  MADEIRA_D3D9_INDEX_RANGE=0 off switch kept.
- Lost-line scan of the devs' port (every line the old Madeira line added over a3a6e8f5, looked up in
  the new tree): the misses are re-homed, not dropped. Vertex fetch bounds / align
  (MADEIRA_VFETCH_BOUNDS, MADEIRA_VFETCH_ALIGN1) moved to src/airconv/nt/dxbc_io_helper.cpp; the ml1031
  input zeroing and ml1109 render-target fill (0,0,0,1) are in the new IOHelper; SwapDeviceContextState
  is now upstream's own; memory census, remote-buffer flush and the wow64 stubs are present.
- gs-siv patch drop: upstream has the INPUT_GS_INSTANCE_ID case (author's evidence stands).

## Not reviewed
The 203-commit port itself beyond the scans above (100k lines), the build-script changes it needs
(not written yet), the air_tessellation shim. Golden games on a test build are the real check;
off switch is the old pin 0c5edfa9.
