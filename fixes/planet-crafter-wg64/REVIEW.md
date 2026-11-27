# REVIEW (author's note, Nov 27 2026): second pass NOT done yet (needs a fresh reviewer before build thread lists it).
What it can break: only a game matched as "Planet Crafter.exe"; every other game keeps the standard list. WG_64BIT turns the 64-bit video parser on for that game; known to expose 0xc00d5212/msvproc.dll next (INDEX Nov 2).
Golden games: not affected (per-program list). Run Planet Crafter only.
Off switch: env.MADEIRA_WG_64BIT = 0 in the game's config.

Update: patch written (data-only Swift: one list + one steamTitles row; matches program 'planet crafter.exe', App ID 1284190, folder 'the planet crafter'). Touches no other game's list. Compile and tests/host/check-game-recommendations.py not run.
Update: patch now includes the check-game-recommendations.py edits (id set, title count +5, no-fork-defaults tuple). Not run; second review still pending.

## Second review (build thread, Nov 27 22:25Z)
PASS. Rev with test edits applies cleanly to the 0.2.180 tree; check-game-recommendations.py on the patched copy: all PASS, Swift part SKIP (no compiler; laptop typechecks, macOS CI runs the fixture). Settings match the device-tested set (WG_64BIT=1, WG_VIDEO_FORMAT=argb32, D3D11_NO_VIDEO_DEVICE=1, EC_HOOK_TRACE=0); off: env.MADEIRA_WG_64BIT = 0. Not device-tested as an applied list.
