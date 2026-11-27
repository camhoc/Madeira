# fo4-alias-table-1024 (Fallout 4 crash ~7 s after Play)

**Proven (iPad 0.2.101 log, from the iPad thread):** `[iOS-xquery] MISS ... alias-table=256/256 live=256 refused=121`, then `Unhandled page fault on execute access to 0x176B39070`, `[rip-leak] guest RIP IS POOL addr = PE 0x71e0153070 (... rva 0x203070)` = d3d11.dll's pool copy. FEX's alias table (kMaxEntries = 256, IosJitAlias.cpp) refused 121 image registrations because it was full, so FEX could not map d3d11's pool address back to its PE address and refused it as non-code.
**Unproven:** that a bigger table alone fixes the crash (the late registration of d3d11 might also need to arrive before the first call). With MADEIRA_SMC_HOT_PAGE = 0 the run showed refused=28 and the same fault, so the table being full is one factor, not yet shown to be the only one.

**Change:** table array 256 -> 1024 entries (32 KB static); Module.S last-hit mask 0xff -> 0x3ff; the cap used is a runtime variable. The [iOS-xquery] MISS line now prints the cap (`alias-table=N/<cap>`).

**Off switch:** `env.MADEIRA_ALIAS_TABLE_MAX = 256` in the game's own config restores the old cap exactly (values 1..1024 accepted; anything else ignored). With it set to 256 the behavior is the old one (the array is bigger but unused beyond 256; the mask 0x3ff is harmless for indexes < 256).

**Not touched:** unix side virtual_ios.c IOS_FEX_ALIAS_MAX (256) only limits how many *other* processes' images the drain pushes (pushed >= 256-96); left conservative on purpose. Wine's own table is 2048.

**Test:** Fallout 4 > Play, 60 s+. Look for `alias-table=` line (none = no MISS = good), `refused=0`. Golden games to check: Fallout NV, DRG dx11 + dx12, a 32-bit game, OW2/Battle.net, GTA V Enhanced (multi-process alias user).
