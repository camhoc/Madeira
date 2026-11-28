# oversize-reserve-min-mb: serve failed 1-64 GB pool reservations in part, and place the real part at the map's top (port with credit)

Thread "Fix Cyberpunk crash at start", Nov 28 2026. Base: source/madeira-0.2.180. Native (build/ntdll-unix) change: needs a build; NOT compiled (no iOS toolchain here), NOT device-tested.

## Credit / license
Ported from arabdogwater/Madeira (branch codex/pr-build-static), GPL-3.0, not BCD: commit 37361885c "Place an oversized reserve's real part against the top of the map" and 5c4fdc449 "serve failed pool reservations in part" (patches in plans/fork-deep-scan-data-2026-11-28/arabdogwater-cyberpunk/). Author: arabdogwater. The two patches must go together; 5c4fdc449 alone fails on 0.2.180. Mark it in the build's credits.

## Why
Cyberpunk 2077 (their notes, iPhone19,2): reserves 16 GB, 64 GB, 32 GB (fails), five 4 GB pools committing 1-24 MB each, a sixth about 3 minutes into play; with the free space in pieces of 3 GB or less the sixth request fails and the game stops ("Out of Memory"). Also Witcher 3 (coordinator). In our own 0.2.180 retests (iPad16,8): `[jumbo-limits] ... st=0xc0000017` for 0x800000000 and `[va-scan] FAILED` lines, the REDengine OOM family. Whether this is what kills our run is UNPROVEN: our current wall is a failed Metal newBuffer.

## Changes
1. 37361885c: new `oversize-reserve-top = 1`: the real part of the oversized reserve sits flush with the map's end, so commits past it fail instead of landing in Wine images, thread stacks, the arena or other pools. signal_arm64_ios.c: emulator-page repairs use the published arena instead of the fixed 0x7c00000000-0x8000000000 band (same band unless arena-mb moves it). Commit-failure logging: up to 64 lines.
2. 5c4fdc449 (adapted by hand to our tree, which already has ios_oversize_min() for `oversize-reserve-min-gb`): new `oversize-reserve-min-mb` (1024..65536 MB; default 0 = unchanged, min-gb behaviour) lets a failed unhinted reserve of at least that size be served with a real part of `oversize-pool-real-mb` (default 1024, halved down to 256 MB while no hole fits, at most half the request). Pools (< 64 GB) take a normal hole, not the top placement.
3. ConfigCatalog.generated.swift: the three keys.

## Off switch
All off by default: `oversize-reserve-top` 0, `oversize-reserve-min-mb` 0 (unset), so no game changes behaviour until its own config sets them; they also only act with `oversize-reserve = 1`. Delete the lines to switch off. Do NOT put them in a recommended list until the iPad A/B is done (coordinator).

## Not checked
- Compile; Swift catalog test; the signal-handler hunks (3, from 37361885c) were applied with line offsets +98/+301 and only read, not compiled.
- Interaction with the existing [jumbo-fit] / jumbo-half code paths in the same function (`ios_oversize_reserve` is called from both reserve paths; a 1 GB+ pool that fails reaches it).
- The coordinator said this replaces jumbo-fit-pow2; I did not remove jumbo-fit (left as is).
