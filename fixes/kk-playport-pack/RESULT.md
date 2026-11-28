# RESULT: kk-playport-pack

**FAIL: 0010, 0012 and 0013 will not compile**

Checked on the Linux laptop: Mesa 26.3.1 (archive.mesa3d.org; sha256 4e4e438eac7b840a9383988cbb7c08dad8041da544b9319fc26d319fa7348961, not checked against a published checksum), our 9 kosmickrisp-ios patches, then 0001-0018.

All 29 apply in order with `git apply`. Applying is not enough: see below.

## Review: FAIL
Read only the eight fuzz patches.

| Patch | Hunk placement |
|---|---|
| 0010 | BROKEN. kk_query_pool.c: `case VK_QUERY_TYPE_PIPELINE_STATISTICS` sits inside the parameter list of kk_ts_heap_for_query (line ~44); kk_pool_is_ps is defined inside the body of kk_query_available_map (~81); the early `return` is at file scope before kk_CmdBeginQuery (~474). |
| 0012 | BROKEN. kk_debug.c: `{"unroll_hints", ...}` is outside any array (belongs in debug_flags). kk_debug.h: KK_DEBUG_UNROLL_HINTS is after the #endif (belongs in enum kk_debug). The kk_shader.c part looks right. |
| 0013 | WILL NOT COMPILE. Uses KK_DEBUG(GPU), but there is no KK_DEBUG_GPU; uses device->zero_page_addr, which is defined nowhere in src/kosmickrisp. Likely missing prerequisite patches. |
| 0002 | OK. Adds unconditional (bounded) stderr tracing. |
| 0008 | OK. |
| 0011 | OK. New function splits an existing comment from its function (cosmetic). The fragment key still uses the unclamped sample count; check that is intended. |
| 0015 | OK. util_format_name comes in through kk_format.h -> util/format/u_format.h. |
| 0018 | OK by reading. |

## Not done
No compile or syntax check: meson, ninja and Python mako are not installed, so Mesa's generated headers cannot be made. The other ten patches and the PR's per-patch intent were not reviewed. Off switch: none found in the eight patches read, apart from MESA_KK_DEBUG=unroll_hints (broken as above).
