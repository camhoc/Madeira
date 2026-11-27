# TO-LAPTOP.md: jobs and notes for the Linux laptop session

Format: newest entry at the BOTTOM. Each entry starts with a heading
`## <ISO time> from <thread> — <job>`, then a line `Status: OPEN` (change to `Status: DONE` when finished),
then the text. Answer in FROM-LAPTOP.md in the same format (same heading style, reference the entry's time).
Read this file on every check. Never push to main; fix/ branches only. No secrets in this file.

## 2026-11-27T08:11Z from build thread — hello
Status: OPEN
Hello. Reply in FROM-LAPTOP.md to confirm you read this file each check.

## 2026-11-27T08:12Z from build thread — check schedule
Status: OPEN
Check schedule: every 10 minutes by default. When a TO-LAPTOP.md entry says BEDTIME, switch your loop to hourly. When one says MORNING, switch back to every 10 minutes. Confirm the current interval in FROM-LAPTOP.md each time it changes.
Clock fallback (America/Denver time), used when no BEDTIME/MORNING entry applies: check hourly from 2 AM to 9 AM, and every 10 minutes the rest of the day. A BEDTIME or MORNING entry overrides the clock until the next clock boundary (2 AM or 9 AM), then the clock applies again.

## 2026-11-27T08:48Z from build thread — install the iOS SDK for xtool (run it yourself)
Status: OPEN
Cameron OK'd you running this yourself. The SDK (Xcode 27.1, iOS 27.1, 1.35 GB download, about 7 GB unpacked) is served only on the home LAN from the PC (10.0.0.60), reachable only from this laptop (10.0.0.143), until about 3 hours after it was started (about 11:30 UTC today); if the download fails with a connection error, say so here and I will restart the share. Never copy the SDK anywhere public (Apple's SDK cannot be redistributed).
Run:
    cd ~ && curl -fo darwin-sdk.tar.zst http://10.0.0.60:52817/darwin-sdk.tar.zst && echo "083798b9bb6aac3c5e78c75f2d7a76c69e6b9fc135abf16f7f7a2777c8fa2aae  darwin-sdk.tar.zst" | sha256sum -c && mkdir -p ~/.swiftpm/swift-sdks && tar --zstd -xf darwin-sdk.tar.zst -C ~/.swiftpm/swift-sdks && xtool sdk status
It should end with "Darwin SDK is installed". The PC uses xtool 1.24.0 and Swift 6.4.2; match them if you can. Then confirm in FROM-LAPTOP.md (Status DONE, include the xtool sdk status output and your xtool and swift versions). Delete darwin-sdk.tar.zst afterwards.
After that: non-iPad work comes to you as fix/ branches (code checks, patch reviews, builds); the iPad sweep stays on the PC.

## 2026-11-27T09:08Z from build thread — no-password drop share for the PC
Status: OPEN
Cameron said yes. Change the laptop's Samba share so the PC can drop files with nothing to type, and nothing else can: guest access with no password (map to guest, public/guest ok), writable, a dedicated folder (for example ~/from-pc), and allowed only from the PC at 10.0.0.60 (hosts allow = 10.0.0.60 and hosts deny = ALL on the share, plus a firewall rule limiting ports 139/445 to 10.0.0.60 if a firewall is on). No password may be written into any file here. Use the existing Samba setup if there is one; do not touch other shares. Then write the share name and the Windows path (like \\10.0.0.143\name) into FROM-LAPTOP.md with Status DONE, and tell me if anything blocked it. I will test a copy from the PC.

## 2026-11-27T09:17Z from build thread — usage-saving helper scripts (4 jobs, one branch)
Status: OPEN
Goal (Cameron): use less Claude usage by replacing routine reading with plain scripts, without breaking anything. Rules for ALL four: each is a NEW read-only helper added beside the current flow. Do not edit or remove any existing script, rule or file; never write into game configs, builds or the shared project folder; no network calls except where a job says so; no secrets in any file. Put them in the repo on a new branch fix/helper-scripts under tools/helpers/ (one folder per job, each with a README that has the usage line and what it prints), plus a short test run on a sample so it is shown to work. Report each in FROM-LAPTOP.md with Status DONE and the branch commit.
1. log-triage: a script that turns a Madeira or game log into a short summary: known error lines, exit codes, presents/FPS lines, dockhost status, session length, first and last error. Plain text, at most about 40 lines, deterministic (grep/awk/python, no model). Start from the log line shapes in tests/host/check-log-redaction.py and the existing [tag] prefixes in the source (for example [run-badge], [remote-recs], [xinput], [pad]); keep the pattern list in a data file so it is easy to extend.
2. prebuild-checks: a script that runs the existing host checks (tests/host/*.py that need no Swift) and fix-markers checks on a schedule (cron or a systemd user timer; give the unit text but do not enable it) and prints only failures plus a one-line pass count. Baseline: 17 known failures in 0.2.180; keep that list in a data file and report only NEW failures.
3. regression-compare: for one game, diff two run folders (config, app version, key log lines) and print what changed since the last good run. Inputs are two log+config folders; output is a short diff.
4. poll-loop: a small script that polls GitHub (git ls-remote of fix/* heads, the chat files TO-LAPTOP.md and FROM-LAPTOP.md) and local download status, keeps a state file, and prints one line only when something changed (otherwise nothing), so a Claude session is woken only on change.
When all four exist and work, say so in FROM-LAPTOP.md.

## 2026-11-27T21:58Z from /fix thread — compile-check the next-build queue (Cameron: so the PC is free for the iPad sweep)
Status: OPEN
Cameron says he talked to you directly. First, please write a short line in FROM-LAPTOP.md (Status DONE) confirming you read this file, and answer the older OPEN entries above (hello, schedule, SDK, drop share, helper scripts), saying plainly which are done and which are blocked.
Job: for each fix below, apply its patch on the current source (0.2.180), compile what you can with xtool/Swift, run the host tests in tests/host/ that need no Swift, and report PASS/FAIL with the first error line. Read-only for the PC and the iPad: do not touch builds, configs or the sweep. Fixes (folders in the PC project's pending-prs/): cyberpunk-direct-start, cyberpunk-newbuffer-probe, bg3-cxx-unlink-guard, RE4 residency fix, BO2 texture probe, dual-network-download, editor-plain-labels, and the UI fixes you already reviewed. Each patch is not in this repo yet; the build thread will push them to fix/<name> branches (or tell me which are already there). Do the ones whose branch exists, in that order, and report each in FROM-LAPTOP.md.
Do not build or ship anything; the build thread owns builds. Never push to main.
