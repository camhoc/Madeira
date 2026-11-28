# RESULT: dual-network-download (rev 2)

**PASS (typecheck) / NEEDS-DEVICE**

Checked 2026-11-27 on the Linux laptop against 0.2.180-og.

## Run
`patch -p1` from the app folder with dual-network.patch: applies. The standalone DualNetworkDownload.swift matches the patched one. Swift typecheck of the whole app: no new errors (only the existing Squeeze one).

## Review
The Content-Length crash, stalls, path encoding and size cap are handled.
Minor: the Host header omits a non-default port.

## Correction
A laptop commit made one minute after rev 2 overwrote its DualNetworkDownload.swift and re-added DepotDownloader.diff. Both are now back to rev 2 (a4e6071). Do not use the laptop's earlier diff.

## Still open
No Xcode build (project.pbxproj unproven), no device test, cellular alongside Wi-Fi unproven.

Header parser (same lines run on Linux): bad, empty, negative, oversized or missing Content-Length are rejected; 0 and 5 accepted.
