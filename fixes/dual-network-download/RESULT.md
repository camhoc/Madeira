# RESULT: dual-network-download

**PASS (typecheck) / NEEDS-DEVICE**

Updated 2026-11-27 on the Linux laptop against 0.2.180-og.

## Fixed and run
- DepotDownloader.diff is now a real unified diff. Paths start with app/Madeira/; apply with `patch -p1` from the tree root and put DualNetworkDownload.swift in app/Madeira/SwiftSteam/Content/.
- An empty or bad Content-Length now falls back instead of crashing (parser run on Linux with 8 header cases).
- 30 s watchdog cancels a stalled transfer; 64 MB response cap; the request path stays percent-encoded.
- Swift typecheck of the whole app: no new errors (only the existing Squeeze one). Timeout and networking behaviour not run.

## Still open
- New file not in project.pbxproj; Settings toggle not written.
- Swift 6 warnings about NSLock in async code.
- Whether iOS keeps a cellular route alongside Wi-Fi is unproven.
