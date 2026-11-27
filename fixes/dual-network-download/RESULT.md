# RESULT: dual-network-download

**FAIL**

Checked 2026-11-27 on the Linux laptop against 0.2.180-og.

## What was run
First error: `patch: **** Only garbage was found in the patch input.` (DepotDownloader.diff has no hunk line numbers.) With the hook added by hand: Swift typecheck of all app files with the patch (Linux, Swift 6.4.3 + iOS SDK, target ios17.0): no new errors. The one error (ContentView.swift:1046, Squeeze needs iOS 17.5) is also in the unpatched app. Not linked or run.

## Findings
- DualNetworkDownload.swift: a header line of just `Content-Length:` crashes the app (`l.split(separator: ":")[1]` is out of range).
- No timeout on receive, so a stalled server hangs the chunk instead of falling back.
- `url.path` is percent-decoded before being put in the request line; use the encoded path.
- No cap on response size.
- New file is not in project.pbxproj; Settings toggle not written.
