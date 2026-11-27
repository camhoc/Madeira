# REVIEW (author's note, Nov 27 2026): second pass NOT done yet (needs a fresh reviewer before build thread lists it).
What it can break: only a game matched as "Planet Crafter.exe"; every other game keeps the standard list. WG_64BIT turns the 64-bit video parser on for that game; known to expose 0xc00d5212/msvproc.dll next (INDEX Nov 2).
Golden games: not affected (per-program list). Run Planet Crafter only.
Off switch: env.MADEIRA_WG_64BIT = 0 in the game's config.

Update: patch written (data-only Swift: one list + one steamTitles row; matches program 'planet crafter.exe', App ID 1284190, folder 'the planet crafter'). Touches no other game's list. Compile and tests/host/check-game-recommendations.py not run.
