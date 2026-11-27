# REVIEW: dual-network-download (second review needed)
Adds: DualNetworkDownload.swift (new file, add to app target) + 2-line hook in DepotDownloader.download() (DepotDownloader.diff).
Off switch: default OFF. UserDefaults key `dualNetworkDownload` (Settings toggle NOT written yet; build thread/UI thread adds a plain Toggle) or `env.MADEIRA_DUAL_NETWORK_DOWNLOAD = 1`. With it off, behavior is byte-identical to 0.2.180 (the `if` is skipped).
Safety: any error in the new path falls back to the old URLSession call; chunks are still decrypted + CRC-checked by the caller. 5 cellular failures -> Wi-Fi only for the run.
Reviewer check: (1) SteamError.contentHTTP visible from the new file; (2) `defer`/lock usage in fetch(); (3) HTTP parse: Content-Length only, chunked encoding throws -> fallback; (4) continuation resumed once in connect handler (guard `done`); (5) NWConnection `.waiting` treated as failure (no cellular route).
Unproven: iOS keeps a cellular route for this app while Wi-Fi is up. PC compile check (xtool/WSL) before it goes in a build. Test on iPhone: toggle on, compare `[steam-depot] speed` lines (~60 MB/s on 5G alone vs ~90 both).

## Rev 2 (fixes after laptop compile-check failed)
Apply: from the app folder (the one holding Madeira.xcodeproj): `patch -p1 < dual-network.patch` (tested with dry run on the 0.2.180 tree; adds the new file, the 2-line hook, the pbxproj entries and the Settings toggle). DepotDownloader.diff removed.
Fixed: header "Content-Length:" with no value no longer crashes; 20 s stall/connect timeouts cancel the connection (caller falls back); request path/query keep their percent-encoding; body capped at 32 MB; new file added to project.pbxproj (ids A1DN0001/A2DN0001); Settings toggle added in Onboarding.swift Steam section next to "Downloads from PCs on this network" (key dualNetworkDownload, default off).
Not compiled yet. Standalone DualNetworkDownload.swift is the same file the patch adds.
