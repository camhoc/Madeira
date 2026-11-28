# REVIEW: kk-playport-pack (KosmicKrisp fixes ported from Playport)

- Source: github.com/playportdev/playport, patches/mesa (GPL-3.0-or-later repo; its Mesa series is offered
  under Mesa's MIT licence, per its docs/decisions/0040). Credit: the Playport authors. Not BCD.
- Base: Mesa 26.3.1 + our 9 build/mesa-ios/patches/kosmickrisp-ios-*.patch (all 9 apply to 26.3.1).
  Playport's series is on Mesa main b39d173, so 8 of 18 needed fuzz (list below). Patches here are
  re-generated against OUR base and apply with `git apply` in order 0001-0018.
- REVISION 2 (Nov 28, after the laptop review FAILED rev 1): 14 patches, 0001-0014. Dropped from rev 1 because their fuzz-3 hunks
  landed in wrong places or needed symbols we lack: pipeline-statistics pool, 'four small correctness fixes' (needs KK_DEBUG_GPU,
  zero_page_addr from other Playport patches), linear-image texture (large, fuzz), geometry-heap overflow. Unroll-hint patch
  (now 0010) was re-done by hand: enum bit KK_DEBUG_UNROLL_HINTS = 1<<3, debug table, hash key, and the pass before nir_opt_loop_unroll.
  Too-many-samples patch (0009) had its comment moved back above the right function. All 14 apply with `git apply` in order, exactly.
  Order now: 0001 memory budget, 0002 present wait, 0003/0004/0005 WSI, 0006/0007 undefined image, 0008 fcanonicalize, 0009 samples,
  0010 unroll hints, 0011 timestamp fence, 0012 texel-buffer NULL, 0013 heap message, 0014 dynamic_rendering_unused_attachments.
  Patches 0002, 0011, 0012 still applied with fuzz 1-2 (eyeballed, hunks sit in the right functions; not compiled).
- What each one is for (all from Playport's commit messages, run on their games, not ours):
  0001 iOS memory budget = process limit (os_proc_available_memory), so Vulkan doesn't promise memory iOS kills us for.
  0002 present wait gives up after 100 ms (DXVK hang after first frame). 0003/0004 no suboptimal-loop for scaled layer,
  opaque layer on iOS (composited vs direct). 0005 layer reconfigured when a 2nd swap chain changed it.
  0006/0007 sampling/storage access of an OpUndef image no longer asserts/segfaults. 0008 linear images Metal can't make.
  0009 fcanonicalize translated (Metal rejected the whole library otherwise: "expected ';'"). 0010 pipeline-stats pool
  accepted (was UNREACHABLE). 0011 too-many-samples clamped. 0012 big [unroll] loops lose the hint (iOS jetsam kills
  MTLCompilerService). 0013 dispatch counts, attribute with no data, occlusion across split. 0014 timestamp resolve fence.
  0015 NULL deref on a texel-buffer format with no entry. 0016 clearer heap-failure message. 0017 exposes
  VK_EXT_dynamic_rendering_unused_attachments (vkd3d-proton wants it). 0018 geometry/tess heap overflow draws nothing.
- Off switches: NONE at runtime except 0012 (MESA_KK_DEBUG=unroll_hints keeps every hint). Honest gap: Playport added no
  switch to the others. Off switch for the whole pack = same as kk-mesa-26.3.1: per-game
  `vulkan = gl/libvulkan_kosmickrisp-<old>.dylib` (keep the pre-pack dylib in the IPA). Each patch is independent of the
  others except 0002/0005 (both wsi_metal.c) and 0006/0007 (same file); drop individually by deleting the file.
- Checked in the cloud: every patch applies in order to 26.3.1 + our 9 patches (git apply on the final series).
- NOT checked: compile (e.g. 0015 uses util_format_name, 0010/0011 hunks need a look), device run, whether any of this
  fixes one of our failing games. Every claim above about a game is Playport's (RDR2, Witcher 3, DIRT 5, Hollow Knight),
  not ours. Playport itself lists Detroit as broken; no atomic64 help (Playport leaves VK_KHR_shader_atomic_int64 absent).
- Needs: laptop compile check (build thread hands it over), then second review.
- Left out on purpose: 0147 (descriptor write stays in its element: could be the DX12 black-screen cause; depends on
  Playport 0122-0125 and a kk_descriptor_set.c refactor, needs a hand port, see triage doc), 0062 (known-fail MSL list),
  0081 (depth-stencil cache), 0019 (compression), 0007 (texel buffer views), diagnostics, MESA_KK_EXPERIMENTAL items.
