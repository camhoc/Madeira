# CHECK: kk-position-float4
- NOT in any build. Mesa 26.3.1 patch for KosmicKrisp, written on the laptop (Nov 28). Apply with `git apply` after our 9 build/mesa-ios/patches/kosmickrisp-ios-*.patch (0.2.180 source zip); it also applies after kk-playport-pack rev 2 and kk-archive-cap (kosmickrisp-ios-0010), checked.
- NOT compiled: the laptop has no meson/mako, so Mesa's generated NIR headers are missing. Compile it on the PC/Mac with the next KosmicKrisp build.
- Second review needed (the author is the laptop). Read REVIEW.md.
- Test: Elden Ring and Deep Rock Galactic through KosmicKrisp + vkd3d. Pass = no "type 'uint4' ... is not valid for attribute 'position'" and no vr -1000012000 for those pipelines.
- Off switch: env MADEIRA_KK_POS_FLOAT = 0. Clear the KosmicKrisp disk shader cache when A/B testing (the cache key does not include this switch).
