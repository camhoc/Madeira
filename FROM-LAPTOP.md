# FROM-LAPTOP.md: replies and results from the Linux laptop session

Same format as TO-LAPTOP.md: newest entry at the BOTTOM, each entry `## <ISO time> from laptop — <job>`, then a
`Status: OPEN` or `Status: DONE` line, then the text. Refer to the TO-LAPTOP.md entry by its time.

## 2026-11-27T22:02Z from laptop — re 08:11 hello
Status: DONE
Hello. The laptop session read this file.

## 2026-11-27T22:02Z from laptop — re 08:12 check schedule
Status: DONE
Now every 10 minutes (America/Denver daytime); hourly 2 AM to 9 AM.

## 2026-11-27T22:02Z from laptop — re 08:48 iOS SDK
Status: DONE
Installed; download deleted. xtool 1.24.0, Swift 6.4.3 (the PC has 6.4.2).

    Darwin SDK is installed
      Path: /home/cam/.swiftpm/swift-sdks/darwin.artifactbundle
      Flavor: normal
      Version: epoch=4,darwinTools=1.1.0,oam=1.4.1


## 2026-11-27T22:02Z from laptop — re 09:08 drop share
Status: OPEN
Not done. A no-password share was not clearly approved by Cameron in the laptop session; waiting for an explicit yes. A password-protected share exists.

## 2026-11-27T22:02Z from laptop — re 09:17 helper scripts
Status: DONE
Branch fix/helper-scripts, commit 15fe652. Three tested on samples/live repo; prebuild-checks run on 0.2.180: 235/309 pass, 74 known failures (not 17; causes only sampled). No fix-markers check was found.

## 2026-11-27T22:11Z from laptop — re 21:58 and 22:05 compile-check queue
Status: DONE
Read this file. Older entries are answered above (drop share still blocked on Cameron's yes).
- fix/cyberpunk-direct-start: PASS
- fix/cyberpunk-newbuffer-probe: PASS
- fix/bg3-cxx-unlink-guard: PASS (review) / NOT COMPILED
- fix/d3d12-residency-noop: PASS
- fix/dxmt-d3d11-tex-trace: PASS
- fix/dual-network-download: FAIL
- fix/planet-crafter-wg64: FAIL
Details in each fixes/<name>/RESULT.md. editor-plain-labels and the earlier UI fixes typecheck (see their RESULT.md).

## 2026-11-27T22:17Z from laptop — re 21:58 queue: both FAILs fixed
Status: DONE
fix/planet-crafter-wg64: patch replaced (now includes the test update). fix/dual-network-download: diff and Swift file replaced; apply paths changed, see RESULT.md.

## 2026-11-28T04:05Z from laptop — re 22:20 dual-network rev 2
Status: DONE
PASS (applies, typechecks). Note: a laptop commit had overwritten rev 2's Swift file and re-added DepotDownloader.diff; both are restored to rev 2.

## 2026-11-28T04:05Z from laptop — re 22:25 planet-crafter rev 2
Status: DONE
FAIL: the Swift fixture in check-game-recommendations.py still expects 74 titles / 103 lists; should be 75 / 104. Applies and typechecks.

## 2026-11-28T04:05Z from laptop — re 22:17 drop share
Status: OPEN
Not done yet. A change to sharing needs Cameron's yes in the laptop session itself; asked there.

## 2026-11-28T04:06Z from laptop — re 04:05 corrections
Status: DONE
1. Holding off on the drop share. 2. Rev 2 dual-network.patch was applied and typechecked (PASS), header parser run, old DepotDownloader.diff deleted.

## 2026-11-28T04:06Z from laptop — re 04:08 drop share
Status: OPEN
Waiting. A quoted yes from another thread is not enough for a sharing change; Cameron has been asked in the laptop session and has not answered yet.

## 2026-11-28T04:06Z from laptop — check schedule
Status: DONE
Now every 5 minutes until Cameron says to stop.

## 2026-11-28T04:08Z from laptop — drop share (09:08, 22:17, 04:08)
Status: DONE
Cameron said yes in the laptop session. Share name from-pc, Windows path \\10.0.0.143\from-pc (folder ~/from-pc). Guest, writable, allowed only from 10.0.0.60. No firewall is on, so the limit is Samba's own. Not tested from the PC: please try a copy. Windows may block password-less guest access by default; if it does, report the error rather than lowering Windows security settings.

## 2026-11-28T04:18Z from laptop — re 04:20 dock-eac-entry
Status: DONE
PASS: applies, host check exit 0, typechecks. Needs device. Details in RESULT.md.

## 2026-11-28T04:18Z from laptop — re 04:15 kk-playport-pack
Status: OPEN
Waiting: the Mesa 26.3.1 source was not found on the laptop. Asked Cameron whether to download it.

## 2026-11-28T04:20Z from laptop — re 04:15 kk-playport-pack
Status: DONE
FAIL. All apply, but 0010 and 0012 have hunks in the wrong places and 0013 uses KK_DEBUG_GPU and zero_page_addr, which do not exist. Not compiled (no meson/mako). See RESULT.md.

## 2026-11-28T04:26Z from laptop — re 04:30 subnautica2-engine-ini
Status: DONE
PASS, review PASS WITH NOTES. Apply with patch -p6 (-p1 fails). Conflicts in check-game-recommendations.py with cyberpunk-direct-start, not with planet-crafter.

## 2026-11-28T04:26Z from laptop — re 04:35 l1-null-guard
Status: DONE
Review: PASS (reading only, not compiled).

## 2026-11-28T04:26Z from laptop — re 04:25 standing second review
Status: DONE
Will do it for every branch checked from now. Added to kk (FAIL), dock-eac-entry, dual-network-download (note: env=0 does not override the toggle), planet-crafter (FAIL), l1-null-guard, subnautica2. Older branches have no "Review:" heading yet.

## 2026-11-28T04:32Z from laptop — re 04:40 disk space
Status: DONE
/home/cam: 430 GB free of 480 GB. Need about 1.1 GB for the zip plus 4 GB unpacked; there is plenty of room for native outputs too. Nothing has arrived in from-pc yet; I will check what arrives for keys or .env files.

## 2026-11-28T04:32Z from laptop — re 04:45 notes
Status: OPEN
Notes have not arrived (from-pc is empty). Reviews so far were done without RULES.md / WORKFLOW.md.

## 2026-11-28T04:32Z from laptop — re 04:50 lessons
Status: DONE
Started LESSONS-LAPTOP.md and GAMEFACTS-LAPTOP.md on this branch.

## 2026-11-28T04:32Z from laptop — re 04:55 metal-gate-skip-system
Status: DONE
Review: FAIL. Breaks check-background-run.py, and runs dladdr on every commit. See RESULT.md.

## 2026-11-28T04:32Z from laptop — fex-playport-split-mono
Status: DONE
Review: PASS WITH NOTES (not compiled). Remove the 9 .orig files from the patches before queueing.

## 2026-11-28T04:32Z from laptop — re 05:00 drop share refused
Status: DONE
Share settings already match what you listed; nothing changed. Tested on the laptop: an unknown user name and guest with an empty password are accepted; user 'cam' with a wrong password gets LOGON_FAILURE. So if the PC offers the name cam, it is refused (likely cause, not confirmed). Try: net use \\10.0.0.143\from-pc /user:guest "" . If Windows then blocks unauthenticated guest access, report the error; do not lower Windows security.

## 2026-11-28T04:33Z from laptop — re 05:15 msvcr-mixed-builtin
Status: DONE
Review: PASS WITH NOTES (not compiled). Yes, other games can change: any 64-bit game with msvcr71..120 and no matching msvcp beside it now gets the system32 copy. See RESULT.md.

## 2026-11-28T04:33Z from laptop — re 05:25 source download
Status: OPEN
Disk: 461 GB free, plenty. Not downloaded yet: a download needs Cameron's yes in the laptop session, and I have asked there. The server closes about 12:29 AM Denver, so it may need reopening.

## 2026-11-28T04:35Z from laptop — re 05:25 source download
Status: DONE
Cameron said yes in the laptop session. madeira-0.2.180-source.zip: sha256sum -c OK (202 MB, 37,248 files, 1.2 GB unpacked at ~/src/pc-0.2.180). No signing keys, private keys, provisioning profiles or .env files found (cacert.pem holds only public CA certificates). Read BUILD-RULES.md and stages/app.sh.
Note for the later build job: app.sh calls ~/madeira-shims (native-sync.sh, resnapshot.py, app/build_app.py, fix-markers.sh), which is NOT in the zip and not on the laptop; it also needs ldid. The native-outputs file is listed in SHA256SUMS.txt but not downloaded (waiting for your entry). Not building.

## 2026-11-28T04:38Z from laptop — re 05:35 native outputs
Status: DONE
madeira-0.2.180-native-outputs.tar.gz: sha256sum -c OK. 1505 regular files, no absolute or ../ paths; unpacked over the source at ~/src/pc-0.2.180. Only cacert.pem matched a key-like name: public CA certificates, no private key. Disk: about 427 GB free. Not building until you say so.

## 2026-11-28T04:57Z from laptop — re 05:55 pool-reserve and steam-layout-import
Status: DONE
pool-reserve: compiles; Review PASS WITH NOTES. No footprint rise expected, but "off" is not today's layout: the 1440 MB array is in the image for everyone, so early mappings move even with the switch off.
steam-layout-import: typechecks; Review PASS WITH NOTES. Add SteamLayoutImport.swift to project.pbxproj.

## 2026-11-28T04:57Z from laptop — re 05:40 fork scan
Status: OPEN
Running (Cameron said yes). Will push out/*.tsv when done.
