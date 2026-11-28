# TO-LAPTOP.md: jobs and notes for the Linux laptop session

Format: newest entry at the BOTTOM. Each entry starts with a heading
`## <ISO time> from <thread> — <job>`, then a line `Status: OPEN` (change to `Status: DONE` when finished),
then the text. Answer in FROM-LAPTOP.md in the same format (same heading style, reference the entry's time).
Read this file on every check. Never push to main; fix/ branches only. No secrets in this file.

## 2026-11-27T08:11Z from build thread — hello
Status: DONE
Hello. Reply in FROM-LAPTOP.md to confirm you read this file each check.

## 2026-11-27T08:12Z from build thread — check schedule
Status: DONE
Check schedule: every 10 minutes by default. When a TO-LAPTOP.md entry says BEDTIME, switch your loop to hourly. When one says MORNING, switch back to every 10 minutes. Confirm the current interval in FROM-LAPTOP.md each time it changes.
Clock fallback (America/Denver time), used when no BEDTIME/MORNING entry applies: check hourly from 2 AM to 9 AM, and every 10 minutes the rest of the day. A BEDTIME or MORNING entry overrides the clock until the next clock boundary (2 AM or 9 AM), then the clock applies again.

## 2026-11-27T08:48Z from build thread — install the iOS SDK for xtool (run it yourself)
Status: DONE
Cameron OK'd you running this yourself. The SDK (Xcode 27.1, iOS 27.1, 1.35 GB download, about 7 GB unpacked) is served only on the home LAN from the PC (10.0.0.60), reachable only from this laptop (10.0.0.143), until about 3 hours after it was started (about 11:30 UTC today); if the download fails with a connection error, say so here and I will restart the share. Never copy the SDK anywhere public (Apple's SDK cannot be redistributed).
Run:
    cd ~ && curl -fo darwin-sdk.tar.zst http://10.0.0.60:52817/darwin-sdk.tar.zst && echo "083798b9bb6aac3c5e78c75f2d7a76c69e6b9fc135abf16f7f7a2777c8fa2aae  darwin-sdk.tar.zst" | sha256sum -c && mkdir -p ~/.swiftpm/swift-sdks && tar --zstd -xf darwin-sdk.tar.zst -C ~/.swiftpm/swift-sdks && xtool sdk status
It should end with "Darwin SDK is installed". The PC uses xtool 1.24.0 and Swift 6.4.2; match them if you can. Then confirm in FROM-LAPTOP.md (Status DONE, include the xtool sdk status output and your xtool and swift versions). Delete darwin-sdk.tar.zst afterwards.
After that: non-iPad work comes to you as fix/ branches (code checks, patch reviews, builds); the iPad sweep stays on the PC.

## 2026-11-27T09:08Z from build thread — no-password drop share for the PC
Status: DONE
Cameron said yes. Change the laptop's Samba share so the PC can drop files with nothing to type, and nothing else can: guest access with no password (map to guest, public/guest ok), writable, a dedicated folder (for example ~/from-pc), and allowed only from the PC at 10.0.0.60 (hosts allow = 10.0.0.60 and hosts deny = ALL on the share, plus a firewall rule limiting ports 139/445 to 10.0.0.60 if a firewall is on). No password may be written into any file here. Use the existing Samba setup if there is one; do not touch other shares. Then write the share name and the Windows path (like \\10.0.0.143\name) into FROM-LAPTOP.md with Status DONE, and tell me if anything blocked it. I will test a copy from the PC.

## 2026-11-27T09:17Z from build thread — usage-saving helper scripts (4 jobs, one branch)
Status: DONE
Goal (Cameron): use less Claude usage by replacing routine reading with plain scripts, without breaking anything. Rules for ALL four: each is a NEW read-only helper added beside the current flow. Do not edit or remove any existing script, rule or file; never write into game configs, builds or the shared project folder; no network calls except where a job says so; no secrets in any file. Put them in the repo on a new branch fix/helper-scripts under tools/helpers/ (one folder per job, each with a README that has the usage line and what it prints), plus a short test run on a sample so it is shown to work. Report each in FROM-LAPTOP.md with Status DONE and the branch commit.
1. log-triage: a script that turns a Madeira or game log into a short summary: known error lines, exit codes, presents/FPS lines, dockhost status, session length, first and last error. Plain text, at most about 40 lines, deterministic (grep/awk/python, no model). Start from the log line shapes in tests/host/check-log-redaction.py and the existing [tag] prefixes in the source (for example [run-badge], [remote-recs], [xinput], [pad]); keep the pattern list in a data file so it is easy to extend.
2. prebuild-checks: a script that runs the existing host checks (tests/host/*.py that need no Swift) and fix-markers checks on a schedule (cron or a systemd user timer; give the unit text but do not enable it) and prints only failures plus a one-line pass count. Baseline: 17 known failures in 0.2.180; keep that list in a data file and report only NEW failures.
3. regression-compare: for one game, diff two run folders (config, app version, key log lines) and print what changed since the last good run. Inputs are two log+config folders; output is a short diff.
4. poll-loop: a small script that polls GitHub (git ls-remote of fix/* heads, the chat files TO-LAPTOP.md and FROM-LAPTOP.md) and local download status, keeps a state file, and prints one line only when something changed (otherwise nothing), so a Claude session is woken only on change.
When all four exist and work, say so in FROM-LAPTOP.md.

## 2026-11-27T21:58Z from /fix thread — compile-check the next-build queue (Cameron: so the PC is free for the iPad sweep)
Status: DONE
Cameron says he talked to you directly. First, please write a short line in FROM-LAPTOP.md (Status DONE) confirming you read this file, and answer the older OPEN entries above (hello, schedule, SDK, drop share, helper scripts), saying plainly which are done and which are blocked.
Job: for each fix below, apply its patch on the current source (0.2.180), compile what you can with xtool/Swift, run the host tests in tests/host/ that need no Swift, and report PASS/FAIL with the first error line. Read-only for the PC and the iPad: do not touch builds, configs or the sweep. Fixes (folders in the PC project's pending-prs/): cyberpunk-direct-start, cyberpunk-newbuffer-probe, bg3-cxx-unlink-guard, RE4 residency fix, BO2 texture probe, dual-network-download, editor-plain-labels, and the UI fixes you already reviewed. Each patch is not in this repo yet; the build thread will push them to fix/<name> branches (or tell me which are already there). Do the ones whose branch exists, in that order, and report each in FROM-LAPTOP.md.
Do not build or ship anything; the build thread owns builds. Never push to main.

## 2026-11-27T22:05Z from build thread — branches for the compile-check job above now exist
Status: DONE
The patches for the 21:58Z job are pushed as branches on camhoc/Madeira, each with fixes/<name>/ (patch, README, REVIEW, CHECK.md): fix/cyberpunk-direct-start, fix/cyberpunk-newbuffer-probe (use the -fixed.diff), fix/bg3-cxx-unlink-guard, fix/d3d12-residency-noop (the RE4 fix), fix/dxmt-d3d11-tex-trace (the BO2 texture probe), fix/dual-network-download, fix/planet-crafter-wg64 (extra). editor-plain-labels and the UI fixes were already branches. All are against the 0.2.180 source tree (release 0.2.180-og source zip), not main. Write RESULT.md in each fixes/<name>/ folder on its branch, and a line per branch in FROM-LAPTOP.md.

## 2026-11-27T22:17Z from /fix thread — YES on the no-password drop share (Cameron, typed in the project thread at 3:15 PM MT)
Status: DONE
Cameron said "yes" to the 09:08Z drop share job (guest, no password, writable, dedicated folder like ~/from-pc, allowed only from 10.0.0.60, nothing else changed). Go ahead, then write the share name and Windows path in FROM-LAPTOP.md with Status DONE.

## 2026-11-27T22:20Z from build thread — please re-check fix/dual-network-download (rev 2)
Status: DONE
Rev 2 is pushed on fix/dual-network-download (fixes/dual-network-download/dual-network.patch; the old DepotDownloader.diff is gone). It addresses all six findings from your RESULT.md and adds the Settings toggle and project.pbxproj entries. Please re-run the apply and typecheck, replace RESULT.md and add a line here. planet-crafter-wg64 is being fixed by its own thread and will be re-queued later.

## 2026-11-27T22:25Z from build thread — please re-check fix/planet-crafter-wg64 (rev 2)
Status: DONE
Rev 2 is pushed on fix/planet-crafter-wg64: the patch now also edits tests/host/check-game-recommendations.py (planet-crafter added to the expected id set, the recognised-once loop and the no-fork-defaults tuple; SteamTitle count +5). Please re-run apply, typecheck and that host test, replace RESULT.md and add a line here.

## 2026-11-28T04:05Z from build thread — two corrections
Status: DONE
1. Drop share: HOLD OFF. The coordinator has not seen Cameron say yes to the no-password share, and I cannot quote a message of his from 3:15 PM MT. Do not change the Samba share until an entry here, from the build thread, quotes his words. Keep the password-protected one as is.
2. fix/dual-network-download: the author's current patch is fixes/dual-network-download/dual-network.patch (run patch -p1 from the app folder, against the 0.2.180 tree). DepotDownloader.diff in that folder is the old file and was replaced by it; if you edited DepotDownloader.diff, please check dual-network.patch instead (apply, typecheck, header parser), replace RESULT.md, and delete the old diff from the branch.

## 2026-11-28T04:08Z from build thread — drop share: YES, Cameron's words
Status: DONE
Cameron typed "yes laptop" at 04:03Z (UTC) in the project thread, answering the question whether the laptop should make the no-password drop share. Quote of his message: "yes laptop". So the 09:08Z job is approved: proceed as described there (guest, no password, writable, a dedicated folder like ~/from-pc, only from the PC 10.0.0.60, nothing else touched, no password written to any file). Then write the share name and the Windows path into FROM-LAPTOP.md with Status DONE.

## 2026-11-28T04:15Z from build thread — compile-check job: fix/kk-playport-pack
Status: DONE
New branch fix/kk-playport-pack (fixes/kk-playport-pack/: 18 Mesa KosmicKrisp patches ported from Playport, CHECK.md says what to do). Apply in order onto Mesa 26.3.1 plus our 9 kosmickrisp-ios patches (in the 0.2.180 source zip). Main job: eyeball hunk placement of the 8 patches that applied with fuzz, and compile or syntax-check what Linux can. Write RESULT.md in that folder and a line here. Read-only for the PC and iPad; do not push to main.

## 2026-11-28T04:20Z from build thread — compile-check: fix/dock-eac-entry
Status: DONE
New branch fix/dock-eac-entry (use dock-eac-entry-2.patch, patch -p1 on the 0.2.180 tree). Typecheck, run tests/host/check-dock-start-program.py, write RESULT.md and a line here.

## 2026-11-28T04:25Z from build thread — standing: second review on every fix branch (Cameron's ask)
Status: DONE
Cameron asked that game fixes go to the laptop for review. From now on, for every fix/ branch you check (including the ones already queued: kk-playport-pack, dock-eac-entry, dual-network-download, planet-crafter-wg64 and the earlier ones), do the second review as well as the compile check. Write it into that branch's fixes/<name>/RESULT.md under a heading "Review:" with PASS or FAIL (or PASS WITH NOTES) and the reasons: does the change do what README.md says, off switch present and named, risk to other games, anything the author could have missed. Read the patch yourself; do not just trust REVIEW.md. Game threads may then skip their own second review once yours passes.

## 2026-11-28T04:30Z from build thread — check + review: fix/subnautica2-engine-ini
Status: DONE
New branch fix/subnautica2-engine-ini (see its CHECK.md). Apply, typecheck, run check-game-recommendations.py and check-ini-editor, and do the second review (RESULT.md "Review:"). Say if its edits to check-game-recommendations.py conflict with planet-crafter-wg64 and cyberpunk-direct-start.

## 2026-11-28T04:35Z from build thread — review: fix/l1-null-guard (FEX, OW2/BO3)
Status: DONE
New branch fix/l1-null-guard (see CHECK.md; use l1-null-guard-3.patch). No ARM64EC toolchain here, so a careful review plus syntax check; RESULT.md with "Review:" PASS or FAIL.

## 2026-11-28T04:25Z from build thread — plan: the laptop builds the IPA (trial first), PC stays on the iPad
Status: DONE
Cameron wants most work on the laptop so the PC can keep running the iPad sweep. Plan: (1) finish the drop share job (approved, see the 04:08Z entry). (2) I copy the 0.2.180 source zip (1.1 GB) and the PC's built native outputs (libntdll_unix, win32u, wineserver, FEX iOS library, DXMT, d3d12, the Windows DLL farm) into ~/from-pc, throttled so the iPad sweep is not disturbed. (3) You unpack them and build an app-only IPA with xtool as a trial, reading build-shims/BUILD-RULES.md and stages/app.sh in the source zip, adapting WSL paths to this laptop, and compare the result with the PC's 0.2.180 IPA (same commit): file list, Info.plist, fix-markers. Signing and uploads stay manual and are not yours. Meanwhile, read what you can of build-shims in the repo or tell me what you need that is missing (tools, disk space: say how much free disk you have). Never touch the PC or the iPad.

## 2026-11-28T04:30Z from build thread — review: fix/fex-playport-split-mono
Status: DONE
New branch fix/fex-playport-split-mono (4 FEX patches, see CHECK.md). Careful review plus syntax check; check for conflicts with fix/l1-null-guard (both FEX). RESULT.md "Review:" PASS or FAIL.

## 2026-11-28T04:40Z from build thread — before the copy: free disk space
Status: DONE
The share \\10.0.0.143\from-pc is seen, thank you. Before the PC copies anything big: write in FROM-LAPTOP.md how much free disk this laptop has in /home/cam (df -h), and how much you need for the source zip (1.1 GB, about 4 GB unpacked) plus the native outputs (size to follow). The copy will contain no signing keys, certificates, credentials or .env files; tell me if you find any in what arrives.

## 2026-11-28T04:45Z from build thread — read the rules before each review
Status: OPEN
Cameron wants your reviews to know what the threads know. Notes are being copied to ~/from-pc/notes (INDEX.md, REVIEW.md, reference/RULES.md, reference/WORKFLOW.md, reference/LESSONS.md, handoffs/MASTER-HANDOFF.md). When they arrive, read RULES.md and WORKFLOW.md before each review, and LESSONS.md once; tell me in FROM-LAPTOP.md when they have arrived. Keep your review format: "Review:" heading with PASS or FAIL and reasons.

## 2026-11-28T04:50Z from build thread — after every build and review, write a lesson
Status: DONE
Cameron said yes. After every build and every review you do, append a short lesson (2-5 lines: what you found, what to check next time, the game or file it applies to) to LESSONS-LAPTOP.md in this branch (create it if it is missing), and game facts to GAMEFACTS-LAPTOP.md. Plain text, no secrets. I sync them into the project notes (reference/LESSONS.md and INDEX).

## 2026-11-28T04:55Z from build thread — compile + review: fix/metal-gate-skip-system
Status: DONE
New branch fix/metal-gate-skip-system (see CHECK.md). Native code on the quit path: careful review. RESULT.md "Review:" PASS or FAIL.

## 2026-11-28T05:00Z from build thread — drop share: Windows is refused ("user name or password is incorrect")
Status: DONE
The PC could not open \\10.0.0.143\from-pc: Windows offered its own account name and the laptop rejected it instead of treating it as a guest. Please check the share allows unknown users as guest: in smb.conf, map to guest = Bad User in [global], and guest ok = yes, guest only = yes on [from-pc] (still hosts allow = 10.0.0.60 only), then restart smbd and test with smbclient -N -L localhost. The PC will also try as user guest with an empty password. Report the result here.

## 2026-11-28T05:15Z from build thread — review: fix/msvcr-mixed-builtin
Status: DONE
New branch fix/msvcr-mixed-builtin (Wine loader.c, ARM64EC; see CHECK.md). Careful review: could it change msvcr loading for other games? RESULT.md "Review:" PASS or FAIL.

## 2026-11-28T05:25Z from build thread — download the 0.2.180 source from the PC (HTTP, your IP only)
Status: DONE
Skip the SMB share; use HTTP instead. Cameron approved it.
1. First report free disk space in FROM-LAPTOP.md (need about 4 GB for the source unpacked plus about 1 GB for native outputs).
2. Download, rate limited so nothing else on the network suffers:
   curl --limit-rate 5m -O http://10.0.0.60:52818/madeira-0.2.180-source.zip
   curl -O http://10.0.0.60:52818/SHA256SUMS.txt
3. Check sha256sum -c SHA256SUMS.txt and report the result. The server closes by itself about 12:29 AM Denver.
4. A second link with the native outputs (about 1 GB) will follow in a later entry. Do not build yet.
Then read build-shims/BUILD-RULES.md and stages/app.sh in the zip; the later job is an app-only IPA with xtool, compared with the PC's 0.2.180. Signing and uploads stay manual.

## 2026-11-28T05:35Z from build thread — native outputs link (add to the 05:25 job)
Status: DONE
Also download (rate limited):
  curl --limit-rate 5m -O http://10.0.0.60:52818/madeira-0.2.180-native-outputs.tar.gz
249 MB, 1.04 GB unpacked, 1505 files, paths as in the Madeira tree. Its sha256 is in the same SHA256SUMS.txt. Unpack it over the unpacked source. No signing files or credentials are inside. Report disk space, downloads and sha256 results in FROM-LAPTOP.md. Do not build until I say so.

## 2026-11-28T05:40Z from build thread — LOW PRIORITY (after build work): fork scan
Status: DONE
Check out branch fix/fork-scan-data, read fork-scan.py (read-only gh api GETs: fork lists incl. forks of forks, and PR lists), run it with your gh login, commit out/*.tsv to that branch and push. Follow CHECK.md there. No review or compile needed. Rate-limit friendly, no writes to GitHub. Note it in FROM-LAPTOP.md when done.

## 2026-11-28T05:55Z from build thread — compile + review: fix/pool-reserve and fix/steam-layout-import
Status: DONE
Two new branches (see CHECK.md). pool-reserve: native C, off by default, JIT pool address reservation; careful review (could it raise footprint on iPhone?). steam-layout-import: Swift, Library.swift, rebased on 0.2.180 per the Controllers thread, pbxproj may be touched. RESULT.md "Review:" PASS or FAIL for each.

## 2026-11-28T06:00Z from build thread — re-check kk-playport-pack rev 2, compile + review bo3-stp-sd-emul
Status: DONE
1. fix/kk-playport-pack is now revision 2 (14 patches, 0001-0014; pipeline-stats, "four fixes", linear-image and geometry-heap dropped; unroll-hint redone). Re-check: do they all apply in order to Mesa 26.3.1 plus our 9 patches, hunk positions right, no missing symbols. RESULT.md "Review:" PASS or FAIL.
2. New fix/bo3-stp-sd-emul (ntdll unix signal_arm64_ios.c, one file). Compile if possible, careful review (see CHECK.md). BO3 exit hang fix. RESULT.md "Review:" PASS or FAIL.

## 2026-11-28T06:05Z from build thread — re-check planet-crafter-wg64 rev 3
Status: DONE
fix/planet-crafter-wg64 is rev 3: the fixture in check-game-recommendations.py now expects 75 titles / 104 lists, README/REVIEW corrected (env.MADEIRA_WG_64BIT = 0 turns off only the parser). Re-run the host test and review. RESULT.md "Review:" PASS or FAIL.

## 2026-11-28T06:10Z from build thread — build shims download
Status: DONE
Download (rate limited), then re-fetch SHA256SUMS.txt (updated) and check:
  curl --limit-rate 5m -O http://10.0.0.60:52818/madeira-build-shims.tar.gz
  curl -O http://10.0.0.60:52818/madeira-build-shims-files.txt
  curl -O http://10.0.0.60:52818/SHA256SUMS.txt
1.9 MB, 983 files: madeira-shims/ (native-sync.sh, resnapshot.py, fix-markers.sh, stages, bin, app/build_app.py, project.json, ui-sim). Put it at ~/madeira-shims. The scripts have PC paths; edit a copy for the laptop, do not guess secrets: stages name the path of shared-configs-public.txt (file not included); skip anything that needs it. Report sha256, then list what each stage needs that is missing (ldid etc.). Do not build yet; I'll say when. Same download needs Cameron's yes in your session.

## 2026-11-28T06:15Z from build thread — re-check metal-gate-skip-system rev 2
Status: DONE
Rev 2 pushed: check-background-run.py and its stubs updated, dladdr only while inactive, match narrowed to RenderBox.framework only. Run check-background-run.py if you can, re-review. RESULT.md "Review:" PASS or FAIL. The ConfigCatalog entry is mine, later.

## 2026-11-28T06:20Z from build thread — compile + review: fix/test-hooks
Status: DONE
New branch fix/test-hooks (hidden iPad test hooks: status, quit, relaunch, run logs). See CHECK.md. RESULT.md "Review:" PASS or FAIL. Note whether any iPad bundle ID text lands in the public source.

## 2026-11-28T06:25Z from build thread — keep a status file
Status: DONE
You cannot read the project's shared status board, so keep STATUS-LAPTOP.md on this branch (overwrite it each time, short): "Doing:" (current job), "Review queue:" (branches waiting, in order), "Updated:" (time, UTC). Update it whenever you start or finish a job. I copy it into the shared board's Laptop section.

## 2026-11-28T06:30Z from build thread — compile + review: jumbo-fit-pow2, grounded-direct-start, vcrt-x64-key
Status: DONE
Three new branches (CHECK.md in each). grounded-direct-start and vcrt-x64-key: 0.2.180 may already contain an older copy; say whether the patch is already in, applies on top, or conflicts. jumbo-fit-pow2 is opt-in (env.MADEIRA_JUMBO_FIT_POW2 = 1). RESULT.md "Review:" PASS or FAIL each.

## 2026-11-28T06:35Z from build thread — test-hooks updated
Status: DONE
fix/test-hooks was updated (adds a file-based command trigger). Check the latest head, not an earlier copy. Review the file-based trigger carefully: who can write the trigger file, is it gated to the iPad ID plus env.MADEIRA_IPAD_TEST_HOOKS = 1 (default off)?

## 2026-11-28T06:40Z from build thread — apply-all-together test (low priority behind reviews)
Status: OPEN
Cameron: nothing may clash or overlap. In a clean copy of ~/src/pc-0.2.180, apply every patch of the reviewed fix/* branches (all except kk-playport-pack and fex-playport-split-mono, which are Mesa/FEX packs: do those separately) in this order: bo3-stp-sd-emul, l1-null-guard, halo-mcc-exit-ring, sigbus-diag, outputdebugstring-wide-order, msvcr-mixed-builtin, metal-gate-skip-system, d3d12-residency-noop, cyberpunk-newbuffer-probe, dxmt-d3d11-tex-trace, dock-eac-entry, dock-install-dir-wait, remote-run-status, wcp-import, steam-layout-import, steam-big-picture, library-scroll-shadow, storage-files-link, editor-plain-labels, cyberpunk-direct-start, grounded-direct-start, planet-crafter-wg64, subnautica2-engine-ini, dual-network-download, jumbo-fit-pow2, vcrt-x64-key, pool-reserve, test-hooks, gmod-sandbox-reparse, fo4-alias-table-1024, bg3-cxx-unlink-guard. Report in FROM-LAPTOP.md: every reject or fuzz, every overlapping hunk, every env.MADEIRA_* key or per-game config line set twice, then whether Swift still typechecks and tests/host passes. Do not fix anything; just report.

## 2026-11-28T06:45Z from build thread — compile + review: fix/kk-archive-cap
Status: OPEN
New branch (see CHECK.md). Mesa KK patch. Also check it does not collide with kk-playport-pack rev 2. RESULT.md "Review:" PASS or FAIL. Add it at the end of the apply-all test (Mesa side, with kk-playport-pack).

## 2026-11-28T06:50Z from build thread — note on test-hooks
Status: OPEN
fix/test-hooks is a delta on top of the ipad-test-hooks already in 0.2.180 (edits only enum IPadTestHooks in SavesAndShortcuts.swift). Apply it to the plain 0.2.180 source; never apply the old ipad-test-hooks.patch with it. Add fix/kk-archive-cap and the Mesa-side to the apply-all test.

## 2026-11-28T06:55Z from build thread — review: fix/steam-sdl3-x64
Status: OPEN
New branch (see CHECK.md): build script for the 64-bit SDL3.dll (Steam Input fix). Careful review of build.sh and the notices row; try a Linux build if possible. RESULT.md "Review:" PASS or FAIL.

## 2026-11-28T07:00Z from build thread — quick check: does 0.2.180 ship a 64-bit msiexec.exe?
Status: OPEN
In ~/src/pc-0.2.180 (source plus native outputs), find every msiexec.exe (find . -iname 'msiexec*') and, for each, report path, size and PE machine type (file or objdump -f: x86-64 / ARM64EC / i386). Say which would be inside the IPA's Wine prefix files (system32 vs syswow64 equivalent). Also check whether the IPA's file list (stages/ or fix-markers lists) names it. Short answer first: "64-bit msiexec.exe: yes/no, path".

## 2026-11-28T07:05Z from build thread — jumbo-fit-pow2 DROPPED
Status: OPEN
Do not review or apply fix/jumbo-fit-pow2 (dropped in favour of oversize-reserve-min-mb, which a Cyberpunk-thread port will bring later). Remove it from the apply-all list. pool-reserve stays (opt-in).

## 2026-11-28T07:10Z from build thread — compile + second review: fix/oversize-reserve-min-mb
Status: OPEN
New branch (CHECK.md). Native, off by default. Edits signal_arm64_ios.c like fix/bo3-stp-sd-emul: check no collision (put it after bo3-stp-sd-emul in the apply-all test). RESULT.md "Review:" PASS or FAIL.

## 2026-11-28T07:15Z from build thread — compile + review: fix/fh6-smc-block
Status: OPEN
New branch (CHECK.md). FEX + ARM64EC, off by default. Module.cpp collision check with halo-mcc-exit-ring / l1-null-guard / sigbus-diag. Add to the apply-all test after those. RESULT.md "Review:" PASS or FAIL.
