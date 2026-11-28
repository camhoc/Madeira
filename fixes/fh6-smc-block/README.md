# fh6-smc-block (Nov 28 2026, Discord-games thread)

Patch `fh6-smc-block.patch` (FEX, base 0.2.180 source `source/madeira-0.2.180/Madeira/FEX`; `patch -p1` from the FEX dir applies clean). **Not compiled** (no ARM64EC toolchain in the cloud container), **not device-tested**.

**Switch:** `env.MADEIRA_EC_SMC_BLOCK = 1` turns it ON. Default OFF: nothing changes. Log at start: `[smc-block] rev=smc-block-1 xtajit64 on|off`.

**What:** under full SMC checks (or ForceFullSMCDetection / a hot SMC block) FEX emits one `_ValidateCode` CRC per instruction. With the switch on, the block gets one CRC per chunk of up to 255 bytes (whole instructions) at block entry instead. A mismatch drops the block and recompiles. Cheaper in blocks of writable, checked code (Denuvo-style titles such as Forza Horizon 6). Known limit (same as the fork): code that rewrites its own next instruction inside the same block is not seen until the block is entered again; a function-entry decrypt is.

**Differences from the fork's patch (kept as close as our tree allows):** chunks are built from the DECODED bytes (`InstBytes`), not a second read of guest memory, to keep our existing rationale (HotSpot placeholder race); chunk boundaries sit on instruction boundaries; the block placement follows our `FEX_MadeiraSectionViews`; undecodable instructions are skipped like the per-instruction path. NOT ported: the fork's "skip checks for non-writable code" half (needs `ContainsWritableCode` tracking in the decoder; risky next to our Overwatch NoExec stub handling).

**Credit / license:** idea and code shape from TimmyTurner51/fh6-wine-fex `fex/0002-block-level-smc-validation.patch` (author TimmyTurner51 "TimmyCraft"). FEX is MIT; the repo shows no separate LICENSE file, and its README says patches carry the parent project's license. Permission to use the code was given by the author on Discord, per Cameron (Nov 28). The author plans to open his own PR later (slowly); this port stays close to his code so his PR can replace or merge with it. Not BCD, not AGPL.

**Overlap checked (pending-prs):** `l1-null-guard` (BranchOps/Dispatcher L1 probe, different lines), `fex-playport-split-mono` (PR.md/REVIEW.md/patches, not read in full; touches mono backpatcher, not the SMC emit loop). Both leave Core.cpp's per-instruction check alone. Re-check `git apply` against the build tree after they land.

**Other fork pieces:**
- `0003-l1-recommit-on-grow`: already covered. Our grow path only widens the mask and never writes the upper half; the shrink recommits by default (ml1180, `FEX_LOOKUP_RECOMMIT=0` is the off switch). Nothing to port.
- `0001-per-block-invalidation`, `0004-jit-stability-and-smc-batching` (108 KB, JIT, dispatcher, Module.S, 19 files), `0005-pool-stub-slots`: NOT ported. They depend on each other, change JIT/dispatcher internals and Windows invalidation tracking, and our tree has diverged (iOS RX/RW alias, SMC fast paths). Porting without a build and a Forza copy risks BO3/OW2 goldens. Needs an owner that can build and test.
- `wine/spec32-arm64x-import-thunk.patch`: already adapted as `arm64x-hotpatch-thunks`. `wine/arm64ec-frame-regs.patch`: not looked at yet.
