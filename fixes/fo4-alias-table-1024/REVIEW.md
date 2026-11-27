# REVIEW (second pass, fresh reviewer, Nov 26)
VERDICT: OK, no bug found in the patch.
Touched: FEX/Source/Windows/ARM64EC/IosJitAlias.cpp, Module.S (line 511 mask 0x3ff), Module.cpp.
Checked: all Module.S table loops bounded by IosAliasCount, 32-byte stride kept; 0x3ff valid immediate; off switch env.MADEIRA_ALIAS_TABLE_MAX = 256 restores old cap; log format args match; BSS 8 KB -> 32 KB.
Caveats: (1) a registration before ProcessInit reads the env var uses the default cap (unchecked that ProcessInit runs first). (2) Linear scans cost more with ~380 entries on a last-hit miss (perf risk, not correctness).
Other users: any game loading >256 images; multi-process games (GTA V Enhanced, Battle.net).
Must not break: 32-byte stride, mask >= kMaxEntries-1, sub-floor table separate, Size published last.
Golden games to run: Fallout NV (record launch mode), Undertale, Silksong, 7 Days to Die, RimWorld, Just Cause 2, plus Fallout 4, DRG dx11/dx12, GTA V Enhanced.
