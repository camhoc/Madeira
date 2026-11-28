# REVIEW: kk-playport-pack (KosmicKrisp fixes ported from Playport)

- Source: github.com/playportdev/playport, patches/mesa (GPL-3.0-or-later repo; its Mesa series is offered
  under Mesa's MIT licence, per its docs/decisions/0040). Credit: the Playport authors. Not BCD.
- Base: Mesa 26.3.1 + our 9 build/mesa-ios/patches/kosmickrisp-ios-*.patch (all 9 apply to 26.3.1).
  Playport's series is on Mesa main b39d173, so 8 of 18 needed fuzz (list below). Patches here are
  re-generated against OUR base and apply with `git apply` in order 0001-0018.
- Original number -> our number (fuzz): 0004->0001 (exact), 0010->0002 (f2), 0011->0003, 0012->0004,
  0045->0005, 0037->0006, 0040->0007, 0041->0008 (f1,f2), 0042->0009, 0038->0010 (f3), 0039->0011 (f1,f3),
  0060->0012 (f2,f3), 0090->0013 (f3), 0093->0014 (f1), 0126->0015 (f3), 0127->0016, 0152->0017,
  0155->0018 (f1,f2). Fuzz 3 = context lines ignored; hunk placement must be eyeballed on the laptop.
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
