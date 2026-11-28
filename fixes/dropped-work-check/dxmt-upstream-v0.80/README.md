# DXMT moved onto newest upstream (3Shain/dxmt 0df86108, tag v0.80)
Thread "Update DXMT to newest upstream", Nov 18 2026 (MT). WRITTEN and pushed, NOT compiled, NOT in a build list, NOT device-tested. Non-author review done: REVIEW.md (OK to compile as its own test build, no branch change).

## The branch
- camhoc/dxmt branch `madeira/upstream-v0.80`, head f2fe58c. Nothing pushed to 3Shain or willfaust.
- Base: willfaust/dxmt `codex/dxmt-upstream-port` e2cced74 (intraducine, Nov 12, marked "[skip ci]" work in progress). It is 0 commits behind upstream 0df86108 and 203 ahead (checked: git rev-list).
- All 163 non-merge commits of the old line (a3a6e8f5..3d62913b, D3D9 and the rest) are on that base by subject (checked: comm of sorted subjects, 0 missing). Their off switches come with them unchanged; not re-audited one by one.

## Our own changes (old pin 0c5edfa9 = 3d62913b + 6 commits, plus 2 build-time patches)
| Old | What | Result on the new branch |
|---|---|---|
| ebb9189 | Share D3D11 video textures within the iOS host process (intraducine) | Already in base (same commit is an ancestor) |
| 7bb5e80 | Preserve lossless compression on colour typeless textures (intraducine) | Already in base |
| 1aab69f | Keep typeless texture compression opt-in (intraducine) | Already in base (`git merge-base --is-ancestor 1aab69f` true) |
| f78548b | airconv: accept clip/cull distance siv and SV_GSInstanceID in geometry shaders (pending-prs/dxmt-gs-siv-instanceid) | DROPPED, upstream covers it. Evidence: applying our patch to the base changes nothing; src/airconv/dxbc_signature.cpp already has `case microsoft::D3D11_SB_OPERAND_TYPE_INPUT_GS_INSTANCE_ID:` from upstream 7854fdf "fix(airconv): do handle `SV_GSInstanceID` in dxbc geometry shader", and clip/cull siv from upstream 767d462 "handle more gs siv from vs" |
| 28bbbd7 | d3d9 texture trace, DXMT_D9_TEX_TRACE=1 | Kept: a019572 (patch applied cleanly) |
| 0c5edfa | d3d9 draw trace, DXMT_D9_DRAW_TRACE=1 | Kept: 0496166 (applied, one hunk moved 4 lines) |
| build/dxmt-patches/0002 | MADEIRA_D3D11_NO_VIDEO_DEVICE=1 | Kept as commit 4c5aa08 (re-placed by hand, d3d11.cpp header changed upstream) |
| build/dxmt-patches/0001 | d3d9 index range per draw, off switch MADEIRA_D3D9_INDEX_RANGE=0 | Kept as commit f2fe58c (d3d9_buffer applied as-is; d3d9_device re-placed by hand, same 9 call sites) |
| air_tessellation.metal 1-line "madeira-wsl" comment | WSL build shim writes it at build time | Not carried; the build writes it again |

## What the build thread must do (app side)
1. Point the dxmt submodule at camhoc/dxmt f2fe58c.
2. MOVE BOTH build/dxmt-patches/0001 and 0002 OUT of the folder when the pin moves. They are now commits on the branch. Reviewer (REVIEW.md, D1): apply.sh exits 1 when a patch neither applies nor reverse-applies; 0001 reverse-applies and would be skipped, but 0002 was re-placed by hand, so it will most likely stop the build.
2b. REBUILD EVERY DXMT WINDOWS DLL in the same build as libdxmt (REVIEW.md, D2): the winemetal unix-call table grew from 151 to 170 slots (0-150 unchanged). That means all prebuilt DXMT PE DLLs for all three architectures plus madeira_d3d12. A new libdxmt with old DLLs is not a valid mix.
3. The new DXMT needs build script changes. The Madeira devs' matching app branch is willfaust/Madeira `codex/dxmt-upstream-build-port` (a87db58): it changes build/dxmt-ios/build.sh, tools/build/build-shader-headers.sh, tools/build/build-runtime-component.sh, build/windows-runtime/build.sh and madeira-d3d12 (pe/madeira_d3d12.c, unix cache files). It also moves FEX and wine pins and gnutls, which we should NOT take blindly. Pick only the dxmt/d3d12 build pieces.
4. Whether the "madeira-wsl 4-arg atomics" shim still fits the new air_tessellation.metal is not checked.
5. One heavy compile at a time.

## Off switch for the whole thing
Set the dxmt submodule back to 0c5edfa9, put the two patch files back, and rebuild the DXMT DLLs with it. That needs a rebuild; there is no runtime switch for a whole-library update.

## Not checked
Compile (no iOS/mingw toolchain in the cloud thread), device behaviour, golden games, per-commit diff of the devs' replay versus the old line, PC export in claudepot\dxmt-rebase\ (ours.bundle etc., only used for the log and dirty diff).
