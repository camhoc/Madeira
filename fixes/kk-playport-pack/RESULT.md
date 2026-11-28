# RESULT: kk-playport-pack (rev 2, 14 patches)

Checked on the Linux laptop: Mesa 26.3.1 + our 9 kosmickrisp-ios patches + 0001-0014.

## Compile
All 14 apply in order with `git apply`. NOT compiled (no meson/mako; Mesa's generated headers missing). Instead: read 0010 and 0011 in full, and checked every identifier the series adds against the whole tree.

## Review: FAIL (one patch)
- 0013 ("say what ran out when Metal gives no heap") will NOT compile: it uses `kk_memory_stats`, `KK_BO_KIND_COUNT` and `KK_BO_KIND_DEVICE_MEMORY`, which are defined nowhere in the tree (they come from another Playport patch that is not in this pack). Drop 0013 or add the memory-stats struct.
- 0010 (unroll hints) is now right: the flag sits inside `enum kk_debug` (1<<3, no clash), the name is in `debug_flags[]`, the hash key and the pass before nir_opt_loop_unroll are in the right functions.
- 0011 (timestamp fence): the one caller of mtl_command_resolve_counter_heap is updated, the stub matches, mtl_new_fence / mtl_wait_for_fence / MTL_STAGE_* / mtl_sync.h exist, and the fence is released in kk_destroy_cmd_buffer.
- Everything else: every function, type and constant the series uses exists in the tree or is defined by the series. A name check does not prove correct placement of every hunk.
- Off switches: only MESA_KK_DEBUG=unroll_hints (as README says); the rest is all-or-nothing through the per-game vulkan dylib.
