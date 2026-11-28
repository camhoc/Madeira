# subnautica2-engine-ini (WRITTEN + reviewed Nov 28, Subnautica 2 thread; PASS WITH FIXES, fixes applied; not compiled, not device-tested)

Replaces the -dpcvars part of `subnautica2-dpcvars` (already in 0.2.180).

## Why
- 0.2.180 Subnautica2.log (claudepot\logs\sweep-0.2.180\Subnautica 2\): line 522 `LogInit: Command Line: -dpcvars=RHI.TransientAllocator.MinimumHeapSize=256,...` but NO `Set CVar` line for any of those cvars, then `Fatal error: ... RHICoreTransientResourceAllocator.cpp] [Line: 726] Transient allocator failed to allocate Buffer Nanite.MainAndPostCandidateClustersBuffer. Size: 134217728`.
- 0.2.101 good run (sweep-0.2.101\Subnautica 2\dpcvars-run1\Subnautica2-ue.log) lines 534-543: `Set CVar [[RHI.TransientAllocator.MinimumHeapSize:256]]` ... `[[r.Lumen.DiffuseIndirect.Allow:0]]`, `[[r.Shadow.Virtual.Enable:0]]`. The last two exist only in Engine.ini, so those lines came from Engine.ini, which was in the prefix at launch.
- Online: Epic staff say command-line config overrides are disabled in shipping builds (forums.unrealengine.com/t/1625694); User*.ini overrides also off in shipping (forums.unrealengine.com/t/2587610). Saved/Config/<Platform>/Engine.ini is read in shipping.
- So: the cvars only work from Saved/Config/Windows/Engine.ini, and the game deletes that file during a run (Nov 25 iPad checks). Cause of the deletion: unproven.

## What it does
New `UnrealIniSeed` (DockInstallers.swift, next to RockstarPipeTimeout, same call sites in ContentView.swift: Dock start and library launch). Before each start, while no session runs, if the game's own config has
`env.MADEIRA_UE_INI_SEED = <Project>: key=value,key=value`
it writes those keys into `[SystemSettings]` of `drive_c/users/<each user with AppData>/AppData/Local/<Project>/Saved/Config/Windows/Engine.ini` (creates folders/file; existing other lines kept, same keys get the seed's value; IniDocument.add + IniFileText, same encoding). Logs `[ue-ini-seed] ...`.
Subnautica 2 recommended list: version 2 -> 3, adds the line with all 28 low-memory-v5 cvars (Project = Subnautica2), and `programArguments: ""` (clears the useless -dpcvars on Reset/apply).

## Off switch
`env.MADEIRA_UE_INI_SEED = 0` (or remove the line) in the game's own config: nothing is written, exactly as before. No global effect: the line exists only in Subnautica 2's list.

## Build thread
- Swift not compiled here (no swiftc). Compile first.
- ConfigCatalog.generated.swift likely needs a regenerate for the new key (gen-config-catalog.py; I could not run it on a partial tree). Add a note: "[ue-ini-seed] per game: <Project>: key=value,... written into Saved/Config/Windows/Engine.ini [SystemSettings] before each start. 0: off."
- Files: patch `subnautica2-engine-ini.patch`, full files in `new/`. Based on source/madeira-0.2.180.

## Proof status
Device proof that Engine.ini present at launch passes: 0.2.101 iPad runs (499 s, no FATAL). Retest on 0.2.180 with Engine.ini hand-written (Run B) asked of the sweep thread Nov 28; result pending.
