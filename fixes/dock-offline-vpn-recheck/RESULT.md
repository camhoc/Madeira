# RESULT: dock-offline-vpn-recheck

Checked on the Linux laptop against 0.2.180-og.

## Compile
Applies with `patch -p2` from the tree root (headers start with Madeira/app/...; -p1 from the parent folder). Swift typecheck of the whole app (Swift 6.4.3, Swift 5 language mode as the project uses): no new errors, so `MainActor.assumeIsolated { JITNetworkShortcut.shared.cellularOffOnPurpose }` compiles. Not checked under Swift 6 strict concurrency (the project is SWIFT_VERSION 5.0).

## Collisions
No other fix/* branch's patches edit MadeiraDock.swift or JITNetwork.swift (searched every +++ line). dual-network-download touches DepotDownloader.swift, Onboarding.swift and the project file only. Mentions of DockOffline/MadeiraDock in other branches are inside full-file copies (subnautica2 new/ContentView.swift, steam-layout files/Library.swift), not edits to these.

## Review: PASS WITH NOTES
- Does what README says: networkDown is false while JITNetworkShortcut still owes "done cellular"; truly offline phones are unaffected.
- Off switch env.MADEIRA_DOCK_OFFLINE_CELLULAR_WAIT = 0 keeps the old check (read once, at first use).
- Crash risk: MainActor.assumeIsolated TRAPS at run time if called off the main thread. Today the only caller is DockOffline.configure in the Dock launch path, which runs on the main actor (ContentView's launch Task), so it is safe now; any future caller from a background queue would crash the app, and only when the network is down (hard to catch in testing). Safer: keep a copy of the flag readable from any thread.
- Steam may start "online" for 1-3 s before cellular comes back (README); not device-tested.
