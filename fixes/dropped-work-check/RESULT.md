# RESULT: dropped-work-check

Checked on the Linux laptop against ~/src/pc-0.2.180 (source + native outputs; source identical to 0.2.180-og). Method: forward and reverse `patch --dry-run` at several roots/strip levels, plus a search for every added line (12+ chars) in the target file.

| Folder | In 0.2.180? | Evidence |
|---|---|---|
| dxmt-gs-siv-instanceid | IN | reverse-applies in dxmt/ (3/3 added lines present) |
| dxmt-upstream-v0.80 | MISSING | no patch here (a submodule move to camhoc/dxmt f2fe58c). 0.2.180 pins dxmt 59c7086 (queue/dxmt-1203); its winemetal call table has about 148-151 entries, not v0.80's 170. Its kept commits' switches (DXMT_D9_TEX/DRAW_TRACE, MADEIRA_D3D9_INDEX_RANGE, MADEIRA_D3D11_NO_VIDEO_DEVICE) are already in the old line. |
| dock-start-dll-links (-2) | IN | reverse-applies (38/38 lines) |
| dock-eac-offline (-2) | IN | context moved, but 17/17 added lines present |
| tap-premove | IN | reverse-applies; 35/35 lines in ContentView.swift |
| direct-relative-touch | IN | reverse-applies; 34/34 lines in ContentView.swift |
| dock-launch-entry-fallback | IN | reverse-applies (27/27) |
| dock-registry-create | IN | 24/24 added lines in madeira-dock/src/launch.c |
| ac-mirage-developer-mode | IN | apiset line, kernelbase.spec export and IsDeveloperModeEnabled in kernelbase/main.c are all in wine/. WARNING: its main.c hunk still applies forward (offset 626), so re-applying would add the function twice. Do not apply. |
| mullion-d3d12-ios | MISSING | patches/madeira/0001-d3d12-mullion-lane.patch applies (patch -p1, root); 15/54 of its lines exist only by coincidence |
| dockhost-cjk-locale (asked) | IN | build/ntdll-unix/env_ios.c line 112 ("dockhost-cjk-locale: this used to be opt-in...") |
| fo4-alias-table-1024 (asked) | IN | reverse-applies (see fix/fo4-alias-table-1024) |

## The MISSING ones
### mullion-d3d12-ios: Review not possible to PASS here; link step NOT re-tested
- The Madeira part (WineProcessBridge.m, build/ntdll-unix/build.sh, virtual_ios.c) applies to 0.2.180, also after wcp-import and oversize-reserve-min-mb (offsets only, no shared hunks).
- Re-testing the link step needs: (1) a download of Mullion from GitHub (rev 11e77a8) and (2) xcrun/ld/ar/nm for iOS. The laptop has the iOS SDK and xtool, and the PC's shims (bin/xcrun etc.) are unpacked but not set up. Both need Cameron's yes (download; using the shims is part of the 07:45 build plan). Not done.
- Not compiled. The lane is opt-in (`d3d12 = mullion` per game, and only with MADEIRA_MULLION=1 at build).

### dxmt-upstream-v0.80: not applied
A submodule move, not a patch: needs fetching camhoc/dxmt (network) and a rebuild of every DXMT PE DLL (the unix-call table grows). Not done.

## Overlaps
- mullion-d3d12-ios vs queued branches: shares WineProcessBridge.m with wcp-import and virtual_ios.c with oversize-reserve-min-mb; different places, applies after both.
- mullion vs dxmt-upstream-v0.80: same area (both add or change winemetal in libdxmt_combined.a). mullion's build.sh must run after build-dxmt-ios.sh; if v0.80 moves the pin, rebuild Mullion's object after it. Not a duplicate fix.
- No two of these fix the same problem.
