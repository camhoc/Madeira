# RESULT: wcp-import

**FAIL**

Checked 2026-11-27 on Linux against the 0.2.180-og source zip.

## What was run
Patch applies to the 0.2.180-og tree (git apply). Swift NOT typechecked or compiled (no Xcode here).

`wcp_untar.c` built with clang + ASan/UBSan against liblzma and tested with crafted tars. Normal, `../` and symlink archives behaved correctly.

## Findings
- SwiftWCP/wcp_untar.c:94: size cap bypass by integer overflow (base-256 size 0xFFFF...FF); with a 1 MB cap it wrote 8 MB. Use `u->remain > u->max_bytes - u->bytes` and refuse huge base-256 sizes.
- wcp_untar.c:169: `pe + 0x18` wraps in uint32; `e_lfanew=0xFFFFFFF0` segfaults. Compare in uint64.
- wcp_untar.c:86: empty name reads `name[-1]`.
- WCPStore.swift:55: duplicate keys in profile.json trap `Dictionary(uniqueKeysWithValues:)` and crash the app.
- The five new files are not registered in project.pbxproj.
- Minor: WCPSection.swift substring match makes `dxvk-2.0` match `dxvk-2.0.1`.
