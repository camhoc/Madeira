# pool-reserve (experiment, OFF by default, for an A/B test on the iPad)

Idea from Playport's `WineHost/wine_host.c` (`host_pool_reserve`, GPL-3.0-or-later; credit them; the code here
is written from its description, not copied. Copy in reference/playport/app/). A static zero-filled array
(1440 MB) is mapped with the executable image itself, before dyld, libmalloc and iOS map their own regions,
so it holds the address range the JIT pool needs. Untouched, it costs no footprint (Playport measured that on a phone).

## Why (evidence in our logs, 0.2.180)
- Requiem 11:18: `ml1135: the placeholder ended at the mapping 0x151d00000+0MB (VM tag 1, prot 3)` then
  `[exe-window] could NOT widen the window to 576MB (kr=3)` -> `wine: failed to create main module ... c0000018`.
- FFVII (Sentry c2e4adc1...): occupant at `0x141d00000` (tag 1, 16KB) inside the window.
- Older comments in JITAllocator.c: 0x15dd00000 (31MB), 0x14bd00000 (tag 1), 0x159d00000 (71MB).
  All sit at +0x1d00000 inside a 128MB-aligned block: one libmalloc region, probably. UNPROVEN.
- Requiem 11:23: low run only `0x12ec00000+276MB`, pool `SHRINKING to 288MB` -> `[jit-pool] EXHAUSTED` loading d3d12.dll.
  `[pool-occupants]` there: tag 87 (Skywalk) 63-71MB x2, a 103MB read-only mapping, RW heap runs.
- Playport 0019: first-fit placement "failed about one launch in four before the reservation existed".

## What the patch does (3 files: JITAllocator.h/.c, StikJITHelper.swift)
1. `static char madeira_pool_reserve[1440MB]` aligned 0x4000.
2. `constructor(100)`: if off (default), `vm_deallocate` the whole array (old behaviour). If on, give back
   [0x140000000, end) at once so `constructor(101)` claims the window and the run above it exactly as before,
   and keep [image end, 0x140000000) held.
3. StikJITHelper: right before the hole census, `madeira_pool_reserve_release` gives the low part back and logs
   `[pool-reserve] released 0x...+NMB held since exec for the pool census`. The census then sees one free run.

Switch: `pool-reserve = 1` in madeira.cfg or `env.MADEIRA_POOL_RESERVE = 1` turns it ON (default OFF:
`MADEIRA_POOL_RESERVE_DEFAULT 0`). `= 0` keeps it off. Marker: `[pool-reserve] released`.

## Numbers (ESTIMATES, not measured)
Image start seen 0x102..0x10a (logs `address-map=`). Main binary ~98 MB file, ~150 MB vmsize, so image end ~0x10b..0x113.
Array end = end + 1440MB = ~0x165..0x16a: past a 576MB window's end (0x164000000), under the lowest stack seen (0x16af64000).
The low run held below the window is then ~810-860 MB (Requiem today: 276 MB). Needs a device to confirm.

## Not proven / risks (device test needed)
- Where the kernel really puts the array at each slide; whether the stack ever lands inside it.
- Bundled dylibs (dyld maps them after the image) may move; dladdr names pool pcs as the main image (only labels).
- Interaction with plugs / `pool-low` / pool-split / `early-pool-above` (census logic unchanged: it just sees a bigger run).
- Constructor order: (100) before (101); `madeira_cfg_bool` already runs at (101).
- No compile in the real toolchain: host test of the constructor/release logic only (below).

## Host check done
Constructor+release logic compiled with mocks (gcc -Wall -Wextra): fake image starts 0x10d444000, 0x10b68c000,
0x11a000000 -> frees [0x140000000,end) and keeps [start,0x140000000); start >= 0x140000000 -> all back; off -> all back.
Patch dry-run applies to 0.2.180 (`patch -p1` from the Madeira/ folder). Swift part not compiled (no swiftc).

## A/B plan (iPad thread, rule 0b)
Requiem, BO3, RE4, Miku, CS2, 7 Days, 5 launches each, `pool-reserve = 1` vs unset; compare `ml1036: free holes`,
`JIT pool: ... size=`, `[pool-reserve]` line, any `could NOT widen`. Stop if any game that works today breaks.
