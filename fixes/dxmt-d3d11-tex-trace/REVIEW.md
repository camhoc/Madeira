# dxmt-d3d11-tex-trace (BO2 missing menu/HUD text)

Log only. No behaviour change. Not compiled, not device-tested.

- What: DXMT_D11_TEX_TRACE=1 logs "[d11-tex-trace] create ..." for the first 400
  shader-readable Texture2D creates (size, mips, array, DXGI format, usage, bind, cpu, data y/n)
  and "[d11-tex-trace] update ..." for the first 400 UpdateSubresource calls on Texture2D
  (format, size, subresource, box, row pitch).
- Why: BO2 (t6zm/t6sp) draws through DXMT d3d11 and loses all menu/HUD text; Borderlands 2 loses
  some letters. Unproven cause. The trace shows the font texture's format/usage and whether it
  is filled at creation or updated after, to be compared with what the Metal side gets.
- Off switch: default off. Enable with `env.DXMT_D11_TEX_TRACE = 1` in the game's own config
  (never global). Unset or 0 = off; cost when off is one static bool check.
- Files: src/d3d11/d3d11_device.cpp, src/d3d11/d3d11_context_impl.cpp (patch dxmt-d3d11-tex-trace.diff,
  apply in the dxmt tree). Adds <atomic>/<cstdlib> includes where missing.
- Check for the reviewer: ERR() is str::format (concatenates, no printf, no iostream manipulators);
  the patch uses plain integers only. Confirm GetType/GetDesc are legal at that point in
  UpdateSubresource1 (taken before the context mutex, like the existing BCCensus call).
- Online: DXMT issues/PRs searched for text/glyph/font: only #141 (unrelated Steam swapchain).
- How to read: run BO2 Zombies to the title menu with the line set; send the [d11-tex-trace] lines.

## Second review (build thread, Nov 27 19:15Z)
PASS WITH NOTES. Applies cleanly (patch --dry-run) to the 0.2.180 dxmt tree. Hook sits in UpdateSubresource1 (the plain UpdateSubresource forwards to it, so both are covered), ERR(...) is the existing Logger::err macro. Note: d3d11_device.cpp does not include <atomic> or <cstdlib> itself (the context file gets them in the diff); they should arrive via <memory>/<mutex>, but if the dxmt build complains add both includes there. Not compiled. Log only, off by default.

Refreshed diff (includes added) re-checked 19:17Z: applies cleanly. Review result unchanged: PASS.
