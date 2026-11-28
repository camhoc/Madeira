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

## 2026-11-28T05:02Z from laptop — re 06:00, 06:05, 06:15 and fork scan
Status: DONE
- kk-playport-pack rev 2: Review FAIL, only 0013: kk_memory_stats / KK_BO_KIND_* do not exist. Others look right (not compiled).
- bo3-stp-sd-emul: Review PASS (not compiled; decode tested on 11 encodings). The [stp-sd] log line appears only on the first S/D fault, not at start.
- planet-crafter-wg64 rev 3: host test exit 0; Review PASS WITH NOTES (still conflicts with cyberpunk-direct-start and subnautica2 in the test file).
- metal-gate-skip-system rev 2: all Metal gate checks pass; Review PASS WITH NOTES. Its Swift fixture now compiles on Linux and two audio checks fail there; probably Linux, please confirm on the PC.
- fork-scan-data pushed: 10,348 forks, 9,178 PRs, 6 unreachable repos (incl. mesa3d/mesa: on GitLab). Rate limit fine.

## 2026-11-28T05:02Z from laptop — re 06:10 build shims download
Status: OPEN
Waiting for Cameron's yes in the laptop session (asked).

## 2026-11-28T05:05Z from laptop — re 06:20 test-hooks
Status: DONE
Typechecks; Review PASS WITH NOTES. No new bundle-id text in the code, BUT fixes/test-hooks/README.md on this public repo contains the iPad bundle id. See RESULT.md.

## 2026-11-28T05:05Z from laptop — re 06:25 status file
Status: DONE
STATUS-LAPTOP.md added on this branch; I will overwrite it as jobs start and finish.

## 2026-11-28T05:12Z from laptop — re 06:10 build shims
Status: DONE
Cameron said yes in the laptop session. madeira-build-shims.tar.gz and -files.txt: sha256sum -c OK (983 regular files, no links, no ../ or absolute paths). Secret scan: no keys or tokens found; shared-configs-public.txt is not included (scripts point at /mnt/c/Users/cam/Desktop/secrets/...).
Unpacked at ~/madeira-shims-unpack/madeira-shims (NOT yet at ~/madeira-shims: moving it needs Cameron). Nothing run, no copy edited yet.
What the app stage (stages/app.sh + app/build_app.py) needs that the laptop lacks:
- ldid (signing): missing. bin/ has no ldid; get-ldid.sh would download one (needs Cameron's yes).
- source tree at $HOME/Madeira: not there; ours is ~/src/pc-0.2.180/Madeira Nightly 0.2.180 source/Madeira (source + native outputs).
- the shims at $HOME/madeira-shims (paths are hard-coded there; also $HOME/.swiftly/bin, which does not exist: swiftly is at ~/.local/share/swiftly).
- 7zz, ccache, cmake, ninja, meson: missing (bin/ has wrapper scripts for some; not checked which stages need them).
- $HOME/madeira-queue/Info.plist.with-key and /mnt/c/... reference-only paths: not present.
Present: swiftc 6.4.3 (PC 6.4.2), xtool 1.24.0 + iOS SDK, zip/unzip, python3, ld64.lld.
bin/ holds prebuilt x86-64 ELF tools (cctools lipo, otool, nm, install_name_tool, ar, strip) from the PC; not run.
Not building.

## 2026-11-28T05:21Z from laptop — re 06:30 and 06:35
Status: DONE
- jumbo-fit-pow2: NOT in 0.2.180, applies on top; Review PASS WITH NOTES (not compiled; per-game only).
- grounded-direct-start: ALREADY IN 0.2.180 (every added line is there; patch conflicts only because its context is older). Do not apply again.
- vcrt-x64-key: ALREADY IN 0.2.180 (reverse-applies cleanly). Do not apply again.
- test-hooks (head 450a852): typechecks; Review PASS WITH NOTES. Command file is gated like the links; anything that can write Madeira's Documents (paired PC, Files app, apps opening documents in place) can trigger it on the test build. README still has the iPad bundle id on the public repo.

## 2026-11-28T05:31Z from laptop — re 06:40 apply-all-together
Status: DONE
Clean copy of ~/src/pc-0.2.180 (source identical to 0.2.180-og), the 31 fixes in your order. Nothing fixed, report only.

Already in 0.2.180, skipped: halo-mcc-exit-ring (both), sigbus-diag FEX 0025, outputdebugstring-wide-order, dock-install-dir-wait, vcrt-x64-key, gmod-sandbox-reparse, fo4-alias-table-1024, grounded-direct-start (lines present; patch rejects on old context).

REJECTS (real clashes):
- planet-crafter-wg64 after cyberpunk-direct-start: all 4 hunks of check-game-recommendations.py rejected (same lines 79, 131-140, 192-198, 954-963: ID set, title count, defaults tuple, Swift fixture counts).
- subnautica2-engine-ini after them: its check-game-recommendations.py hunk at line 497 (version assert) rejected; its Swift parts applied.
=> These three need one combined edit of the test file.

DUPLICATE (worse than a reject): sigbus-diag's ntdll-sigbus-diag.patch is already in 0.2.180 but still applies forward with fuzz 1 (offset 51), so applying it again DUPLICATES its block in signal_arm64_ios.c (rev=sigbus-diag-1 appears 4 times instead of 2). Drop it from the apply list. It also sits right after bo3-stp-sd-emul's hunk (lines 5544-5559): bo3 must go first, as it did.

Fuzz/offset only (applied fine): wcp-import (offsets 71 and 14), remote-run-status (2), steam-big-picture (28), library-scroll-shadow (9). No other overlapping hunks between pending fixes.

Config keys: no key set twice for the same game. Shared: env.MADEIRA_EC_HOOK_TRACE = 0 in both the Cyberpunk and Planet Crafter lists (separate games, fine); MADEIRA_REC_STEAM_DIRECT read by both direct-start fixes (same switch, already in 0.2.180).

Swift: the whole app typechecks with everything applied (only the existing Squeeze error).
tests/host: 0.2.180 base 301/392 pass; all fixes 300/393. Changes:
- check-game-recommendations.py: pass -> FAIL (the rejected test hunks above).
- check-dock-installers.py: pass -> FAIL, caused by subnautica2-engine-ini ALONE (its UnrealIniSeed in DockInstallers.swift uses GameConfigFolders and IniFileText, which the test's standalone compile lacks). I missed this in its first review; correction added to its RESULT.md.
- check-storage-files-link.py: new test, passes.
Not covered: Mesa/FEX packs (separate), native C compile (no Wine/FEX build here).

## 2026-11-28T05:35Z from laptop — re 06:45 to 07:30
Status: DONE
- 07:00 msiexec: 64-bit msiexec.exe: NO. Only app/Madeira/i386-windows/msiexec.exe (106,496 bytes, PE32 Intel 80386), the 32-bit (syswow64-side) set. Not in arm64ec-windows (429 files) or aarch64-windows, not in prefix-template.tar.gz, not named in stages/app.sh or fix-markers.txt.
- kk-archive-cap: Review PASS. Applies on our 9 Mesa patches and after kk-playport-pack rev 2; no collision.
- steam-sdl3-x64: Review PASS WITH NOTES. Not built: needs a GitHub clone plus cmake/ninja (not on the laptop; Cameron's yes needed).
- oversize-reserve-min-mb: Review PASS WITH NOTES. Applies after bo3-stp-sd-emul. Note: the arena-range change in signal_arm64_ios.c is not behind the switches.
- fh6-keep-jit-regs: Review PASS WITH NOTES. Applies after bo3 and oversize; no shared hunks.
- fh6-smc-block: Review PASS WITH NOTES. No overlap with l1-null-guard / fex-playport (different files).
- ubisoft-farcry: FAIL (incomplete): fixes/upstream-615-ubisoft-split/ is not on the branch, so apply.sh cannot run. The three wine patches apply and were reviewed.
- 06:50 test-hooks note: noted; it was applied to plain 0.2.180 only.
- 07:05 jumbo-fit-pow2 dropped: noted, removed from my apply-all list.

## 2026-11-28T05:43Z from laptop — re 07:40, 07:50, 07:55
Status: DONE
- tf-syscall-l1: Review PASS (applies after l1-null-guard-3; not compiled).
- test-hooks rev 3: typechecks, signatures match; Review PASS WITH NOTES (a failed config backup does not stop the edit).
- recommended-working-configs: Review PASS. Merged with cyberpunk-direct-start, planet-crafter-wg64, subnautica2-engine-ini: test passes; final counts 78 titles / 107 lists. Merged test-file diff is in its RESULT.md.
Next: dropped-work-check (07:35), then the build plan (07:45).

## 2026-11-28T05:45Z from laptop — re 07:35 dropped-work-check
Status: DONE
8 of 10 are IN 0.2.180 (plus dockhost-cjk-locale and fo4-alias-table-1024: IN). MISSING: mullion-d3d12-ios (Madeira patch applies; link step not re-tested: needs a Mullion download and the iOS tool shims, i.e. Cameron's yes) and dxmt-upstream-v0.80 (a submodule move; 0.2.180 is still on the old DXMT line). Warning: ac-mirage-developer-mode is IN but its main.c hunk still applies forward, so re-applying duplicates the function. Table in its RESULT.md.

## 2026-11-28T05:45Z from laptop — re 07:45 build plan
Status: OPEN
Step 1 done earlier (shims downloaded, verified, unpacked at ~/madeira-shims-unpack/madeira-shims). Steps 2-3 need Cameron's yes in the laptop session for: moving them to ~/madeira-shims, editing a laptop copy, and getting ldid (a download). Asking him now.

## 2026-11-28T05:53Z from laptop — re 08:00 dock-offline-vpn-recheck
Status: DONE
Typechecks (assumeIsolated compiles, Swift 5 mode); Review PASS WITH NOTES. No other branch edits MadeiraDock.swift or JITNetwork.swift. Note: assumeIsolated traps if networkDown is ever read off the main thread (safe for today's only caller). Apply with patch -p2 from the tree root.

## 2026-11-28T05:58Z from laptop — re 07:45 build plan (progress)
Status: OPEN
Cameron said yes in the laptop session.
1. Shims at ~/madeira-shims (from the verified tarball; unchanged so far).
2. ldid installed at ~/.local/bin/ldid: ProcursusTeam/ldid release v2.1.5-procursus8 (GitHub, no published checksum; sha256 d7d8c8b06ec913b2778e3e2e0306b5383e83fafe994a3f8acf25f4a525e2a9e9). No PC paths needed editing yet: the scripts already use $HOME/madeira-shims and ROOT/MADEIRA_PROJECT_JSON env overrides. swiftly is at ~/.local/share/swiftly (env.sh already sources it).
3. Dry run on a copy of ~/src/pc-0.2.180 (source + native outputs) at ~/build-laptop/Madeira, skipping native-sync (the zip has no git) and signing:
   - dump.py on its project.pbxproj gives exactly the same project.json as yours.
   - build_app.py stops at the first ObjC++ file: FEX/FEXCore/include/FEXCore/Config/Config.h:38 'FEXCore/Config/ConfigValues.inl' file not found. That is a CMake-generated header; the native-outputs tarball has FEX/build-ios/*.a but no generated headers.
   Please add FEX/build-ios's generated include files (ConfigValues.inl and whatever else lives under build-ios/generated or the like) to the native outputs, or tell me to generate them here (needs cmake, which needs Cameron's yes to install).
Not compared with your IPA yet (nothing built). No keys, nothing signed, nothing uploaded.
