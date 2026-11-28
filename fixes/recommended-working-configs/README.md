# recommended-working-configs

Two new per-game recommended lists (data only, no code path). Written Nov 28 against the 0.2.180 source.

## What it adds
| Game | Recognised by | Lines | Evidence |
|---|---|---|---|
| Resident Evil 5 (`resident-evil-5`) | folder `resident evil 5`, program `re5dx9.exe` (no App ID) | `env.MADEIRA_SMC_HOT_PAGE = 0` | PROVEN on 0.2.101 (Nov 25): without it RE5 crashed at launch, with it the game ran and played its intro video at ~200 s. Same line as The Escapists 2. Cause of the crash unproven. NOT re-tested on 0.2.180. |
| Euro Truck Simulator 2 (`euro-truck-simulator-2`) | folder `euro truck simulator 2`, program `eurotrucks2.exe` (no App ID) | `pool-split = 1`, `env.MADEIRA_X64_IMAGE_NOCOPY = 1` | Proven on 0.2.26 (Nov 17, iPad17,1): first launch ran out of JIT memory (`[jit-pool] EXHAUSTED ... want=0x430000` x6); Madeira then wrote these two lines itself and the relaunch ran (exit 0 after 2 min). NOT re-tested on 0.2.180; `pool-split` is automatic there, so that line may be redundant. |

Both lists carry `env.MADEIRA_EC_HOOK_TRACE = 0` like the other own-written lists and none of the BCD "tested defaults" lines.

## Off switch
Delete the lines from the game's own config, or remove the entry (Reset to Recommended brings back whatever the list says). Data-only (WORKFLOW exception).

## Known limits (be honest)
- Neither list has a Steam App ID, because I could not verify one from our files. Recognition is by Steam folder and program name only. If the build thread can confirm the IDs (RE5, ETS2) from Steam, add them to `appIDs: []`; a wrong ID would give the list to the wrong game, so I left them out.
- The RE5 list does not fix the ~190 s startup (fault loop on 4 pages, page 0x72055d0000 hit 264 times). That is a separate open question waiting on Cameron.
- `merged-recommendation` (recommended-merge) will push the new lines to existing configs of these two games once, with the Keep/Undo alert.

## Checked
- `tests/host/check-game-recommendations.py` PASSES on the 0.2.180 tree with both patches (source checks). The Swift fixture step is SKIPPED here (no compiler): it needs macOS CI / the laptop.
- Two fixture lines in `check-game-recommendations.patch` (id recognition for both games, in the Swift test block) and the new counts are NOT run anywhere yet.
- Overlap: no other pending patch or checklist row names RE5 or ETS2 (grep of pending-prs README/PR/patch files).

## Hand-merge with the other list patches (one merge for all)
This patch edits the same two files as planet-crafter-wg64, cyberpunk-direct-start, grounded-direct-start, subnautica2-engine-ini (and ubisoft-farcry if it ships). Against pristine 0.2.180 it sets counts to **76 titles / 105 lists** (74 / 103 + 2). In the combined merge, ADD 2 to whatever the count is after the other patches (the line is `R.steamTitles.count == N && R.all.count == M` in the Swift fixture, and the note text after it). The `MERGED` id set and the "no BCD defaults" list in the checker also gain `resident-evil-5` and `euro-truck-simulator-2`: those two edits also need to be carried in the merge.

## Deliberately NOT included (already there or not proven)
- BeamNG CEF lines, GOALS and the .NET program `DOTNET_GCRegionRange = 400000000` (+ `EnableWriteXorExecute = 0`): already in 0.2.180 lists (`beamng-drive` v2, `goals` v2, `dotnet-large-heap` v2). Nothing to add.
- Project Zomboid test 7 Java line: 0.2.180 already has v2 (`-XX:+UseG1GC -XX:TieredStopAtLevel=1`). Test 7 (SerialGC, CICompilerCount=1, -BackgroundCompilation) reached the menu in ~7 min vs ~10, but New Game text was garbled and tests 8 and 9 have no result; the Zomboid thread (cmsg_..AEsjrAM) owns writing that list. One approach per problem, so I did not add a competing v3.
- Deep Rock Galactic `-dx11`: the "worked on 0.2.97" claim is unproven (the 0.2.97 FSD log was never pulled), and `-dx11` renders black on 0.2.101. DX12 on KosmicKrisp fails 3 shaders (-1000012000). No working config exists to recommend. The Rain World / DRG thread owns this.
