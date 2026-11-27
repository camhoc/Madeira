# RESULT: dual-network-download

**PASS (typecheck) / NEEDS-DEVICE**

Updated 2026-11-27 on the Linux laptop against 0.2.180-og.

## Apply
`patch -p1 < DepotDownloader.diff` from the tree root, and copy DualNetworkDownload.swift to app/Madeira/SwiftSteam/Content/.
The diff now holds the download hook, the project.pbxproj entries and a Settings toggle (Onboarding.swift, next to LAN downloads; off by default).

## Run
Applies cleanly. Swift typecheck of the app: no new errors (only the existing Squeeze one). Header parser tested on Linux.

## Still open
- No Xcode build, so the project.pbxproj entries are unproven. Not run on a device.
- Swift 6 NSLock warnings. Cellular alongside Wi-Fi is unproven.
