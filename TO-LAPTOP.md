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
