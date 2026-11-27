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
