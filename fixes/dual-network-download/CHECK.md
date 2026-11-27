# dual-network-download (Wi-Fi + 5G chunks at once)

Status: DRAFT, not compiled, needs second review. Default OFF.

Online: Apple's MPTCP "aggregate" mode is the only built-in way to use both links, but (unverified, my fetch of mptcp.dev/Apple docs returned nothing usable) it needs a restricted Apple entitlement a sideloaded app cannot get, and Steam's CDN would have to speak MPTCP. So this patch splits chunks itself.

How the downloader works (DepotDownloader.swift): 8 parallel chunk tasks (16 with LAN PC), each calls `download()` -> one shared URLSession (`Self.http`, max 8 conns/host). URLSession cannot pin an interface.

Patch: `DualNetworkDownload.swift` opens one NWConnection per chunk with `requiredInterfaceType` = .wifi or .cellular, tiny HTTP/1.1 GET (Content-Length only, Connection: close). Picks the link by lowest (inflight+1)/measured-speed, so ~1:2 Wi-Fi:5G adapts on its own. Any error falls back to URLSession; 5 cellular failures turns cellular off for the run.
Hook: 2 lines in `download()` (DepotDownloader.diff).
Switch: UserDefaults `dualNetworkDownload` (Settings toggle, label "Use Wi-Fi and cellular together for downloads (uses mobile data)") or `env.MADEIRA_DUAL_NETWORK_DOWNLOAD = 1`. The Settings toggle UI is NOT written (needs the Mac runner to compile the view).

Can the Linux laptop check it? Probably yes to COMPILE (Cameron: the PC builds IPAs with xtool + WSL Ubuntu; xtool's iOS SDK has Network.framework). Needs xtool + the SDK on the laptop; not checked whether installed. Compiling is not testing: only the iPhone proves the split. Unproven: that iOS keeps a cellular route up while on Wi-Fi for a sideloaded app (works in other apps via requiredInterfaceType; not tested here). Test on iPhone: toggle on, watch `[steam-depot] speed` log lines (expect ~90 MB/s vs ~60 alone). Risks: a TLS handshake per chunk; cellular data use; Wi-Fi-only Low Data Mode.
Also need `SteamError.contentHTTP` reachable from this file (same module, should be).

## Rev 2 (Nov 27 22:20Z): replaces the first version after your FAIL
Use dual-network.patch (patch -p1 from the app folder, against the 0.2.180 tree). It fixes the six findings in your RESULT.md and adds the Settings toggle and project.pbxproj entries. Please re-check and replace RESULT.md.
