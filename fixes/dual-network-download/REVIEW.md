# REVIEW: dual-network-download (second review needed)
Adds: DualNetworkDownload.swift (new file, add to app target) + 2-line hook in DepotDownloader.download() (DepotDownloader.diff).
Off switch: default OFF. UserDefaults key `dualNetworkDownload` (Settings toggle NOT written yet; build thread/UI thread adds a plain Toggle) or `env.MADEIRA_DUAL_NETWORK_DOWNLOAD = 1`. With it off, behavior is byte-identical to 0.2.180 (the `if` is skipped).
Safety: any error in the new path falls back to the old URLSession call; chunks are still decrypted + CRC-checked by the caller. 5 cellular failures -> Wi-Fi only for the run.
Reviewer check: (1) SteamError.contentHTTP visible from the new file; (2) `defer`/lock usage in fetch(); (3) HTTP parse: Content-Length only, chunked encoding throws -> fallback; (4) continuation resumed once in connect handler (guard `done`); (5) NWConnection `.waiting` treated as failure (no cellular route).
Unproven: iOS keeps a cellular route for this app while Wi-Fi is up. PC compile check (xtool/WSL) before it goes in a build. Test on iPhone: toggle on, compare `[steam-depot] speed` lines (~60 MB/s on 5G alone vs ~90 both).
