# cyberpunk-pool-arena: Cyberpunk list v2 = pool-low JIT lines + 4 GB arena (replaces cyberpunk-direct-start)

Thread "Fix Cyberpunk crash at start", Nov 28 2026. Base: source/madeira-0.2.180. Settings only, Swift only, no native rebuild. Host test passes in a scratch copy (Swift part skipped: no compiler).
SUPERSEDES pending-prs/cyberpunk-direct-start (NOCOPY + direct start + GOG list): do not build both.

## Evidence (iPad16,8, 0.2.180, sweep thread's retests)
- NOCOPY + pool-split: launcher faults in PocoFoundation.dll (`status=0xc0000005 lived=2.21s`); without NOCOPY the pool runs out (`[jit-pool] EXHAUSTED ... FAILING the load`).
- 5a (fork lines: pool-split, pool-low, pool-page-fit, MADEIRA_POOL_LOW_IMAGES, MADEIRA_POOL_RECYCLE_IMAGES; no NOCOPY): EXHAUSTED 0, newBuffer failed 0, but `Assert: Out of Memory! Failed to allocate 4294967296 bytes with alignment 65536 (systemOOMHandlerBreak.cpp)` then int3, `[child-end] cyberpunk2077.exe status=0x80000003 lived=13.46s`.
- 5c (5a + `arena-mb = 4096` + `env.MADEIRA_FEX_ARENA_GROW = 1`): no OOM assert, EXHAUSTED 0, newBuffer failed 0; alive ~9 min, title screen at 60 FPS, ~6.3 GB; stopped at CD Projekt's data-consent screen (not tapped through). `[alloc-fail]` 65 lines and some commits past the 2048 MB real part still fail (log lines in logs on the PC, cyberpunk-5\).
- The earlier newBuffer failure appeared only in the direct-start + NOCOPY runs; not seen in 5a/5c (cause unproven).

## Credit
pool-low / image switches / arena idea from arabdogwater/Madeira 6307d9f28 (GPL-3.0, not BCD), keys already in our tree.

## Change
List v2: adds pool-split, pool-low, pool-page-fit, env.MADEIRA_POOL_LOW_IMAGES, env.MADEIRA_POOL_RECYCLE_IMAGES, arena-mb = 4096, env.MADEIRA_FEX_ARENA_GROW = 1, env.MADEIRA_JIT_POOL_AUTO = 0 (so jit-pool-auto cannot add NOCOPY and break the launcher). Same list for Steam and GOG (no separate GOG list, no direct start). Host test updated (version table, tested lines).

## Off switch
Delete the lines (or Reset the game's config). arena-mb = 4096 affects every thing that needs the arena; it only applies to Cyberpunk.

## Not checked / limits
- Not compiled/Swift fixture not run; the list as applied by the app not device-tested; each iPad run was one run.
- Past the consent screen (menu, loading a save, play) UNPROVEN. 4 GB arena may be too small later (FEX peak seen by the fork: 2.66 GB on iPhone).
- GOG copy not tested; iPhone not tested.
- The probe pending-prs/cyberpunk-newbuffer-probe is still useful if newBuffer failures return.
