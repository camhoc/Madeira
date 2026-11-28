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
