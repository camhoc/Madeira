# REVIEW: dock-launch-entry-fallback
Second review by a fresh reviewer (Nov 25 2026): PASS, no fixes required. Read-only; not compiled, not device-tested.
- Types fit: SteamLaunchOption.index is UInt32?, requiredDLC String?, betaKey/oslist/osarch/type String; `var chosen` keeps `chosen == nil` and `chosen ?? 0` working; the `best!` unwrap is guarded.
- Ranking is identical to SteamDirectStart.choose (same filters, kind*3+arch, same tie-break); only the .exe-on-disk checks are skipped.
- Behaviour changes only when options is non-nil and choose() returns nil (no .exe entry on disk: .bat/.cmd/.lnk-only games, exe not yet installed, missing working dir). Then entry 0 is replaced by the best non-beta Windows entry. Differs from 0 only if entry 0 is beta/server/VR/non-Windows/DLC-gated/lower ranked.
- Golden games: none expected to be touched; confirm no "[dock-launch-fallback]" line appears for 7 Days to Die (#2).
