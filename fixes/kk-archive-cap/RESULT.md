# RESULT: kk-archive-cap

Checked on the Linux laptop against 0.2.180-og.

## Compile
Applies with `git apply` on Mesa 26.3.1 + our 9 kosmickrisp-ios patches, and also after kk-playport-pack rev 2 (which does not touch mtl_compiler.m): no collision. Not compiled (no meson/mako).

## Review: PASS
- Only active with env.MADEIRA_KK_METAL_ARCHIVE = 1 (the existing gate in the same file); the new code runs inside that load path.
- 2048 MB default cap on archive bytes opened at launch, newest first; files over the cap are kept on disk, not opened. 120 s flush by default.
- Both env values are range-checked (5..3600 s, 0..1048576 MB; 0 = no cap); bad values keep the defaults.
- Capped files still count toward the 256-file limit, so the folder stays bounded.
