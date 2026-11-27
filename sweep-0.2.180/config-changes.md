# Config changes during the 0.2.180 sweep retests (Nov 27)
## Garry's Mod, before (also config-gmod-before.png)
    # Madeira's recommended settings for Garry's Mod.
    # Reset to Recommended, at the bottom of the game's settings, brings them back.
    pool = 896
    pool-split = 1
    env.MADEIRA_X64_IMAGE_NOCOPY = 1
    env.MADEIRA_EC_HOOK_TRACE = 0
    # The defaults this list was tested with (upstream's differ).
    env.MADEIRA_FREE_DELAY_MS = 2000
    env.MADEIRA_CTX_CPU_AREA = 2
    env.MADEIRA_WAIT_CHILDREN = 1
    env.MADEIRA_JIT_DUMP = 0
- 08:27 Garry's Mod: added 'env.MADEIRA_PLAIN_DIR_LINKS = 1' and 'env.MADEIRA_FILE_TRACE = 1' (end of its own config). A typing glitch put stray underscores there for a few minutes; fixed before any launch.
- 08:36 Garry's Mod: both lines removed again; config verified identical to before (screenshot).
- 08:48 Planet Crafter: before: 'env.MADEIRA_EC_HOOK_TRACE = 0' (+2 comment lines). Added 'env.MADEIRA_WG_64BIT = 1' (kept afterwards, as asked).
- 09:10 BO2 Zombies before: 'env.MADEIRA_AUDIO_LEAD_MS = 150', 'env.MADEIRA_EC_HOOK_TRACE = 0' (+2 comment lines). Run A adds 'env.MADEIRA_FONT_ALIAS_ENUM = 0'.
- 09:21 BO2 Zombies run B: FONT_ALIAS line removed, 'gl-vulkan = kosmickrisp' added. (Run A result: menu text still missing.)
- 09:31 BO2 Zombies: restored; config identical to before (screenshot). Result B: black screen 4+ min.
- 09:35 Planet Crafter retest 2, before: 'env.MADEIRA_EC_HOOK_TRACE = 0', 'env.MADEIRA_WG_64BIT = 1' (+2 comment lines). Adding 'env.MADEIRA_WG_VIDEO_FORMAT = argb32' and 'env.MADEIRA_D3D11_NO_VIDEO_DEVICE = 1' (KEEP, as asked).
- 10:06 Cyberpunk before (also config-cyberpunk-before.png): env.MADEIRA_EC_HOOK_TRACE = 0 / oversize-reserve = 1 / oversize-reserve-mb = 2048 / # Added by Madeira: this game ran out of JIT memory / pool-split = 1 / env.MADEIRA_X64_IMAGE_NOCOPY = 1. Run 2: last two lines removed, env.MADEIRA_JIT_POOL_AUTO = 0 added (restore after).
- 10:17 Cyberpunk: restored; config identical to before (screenshot).
- 10:21 Borderlands 2 before: 'env.MADEIRA_EC_HOOK_TRACE = 0' (+2 comment lines). Adding 'gl-vulkan = kosmickrisp' (remove after).
- 10:36 Borderlands 2: restored ('env.MADEIRA_EC_HOOK_TRACE = 0' only). Result with kosmickrisp: launcher PLAY, then bare desktop 4+ min, game never showed.
- 10:52 Cyberpunk run 3 before: Steam page Start with = Madeira Dock, Steam starts = Steam's choice; (The game's Program default REDprelauncher.exe); config as logged 10:06. Changing: Start with = The game, Program bin/x64/Cyberpunk2077.exe, add env.MADEIRA_JIT_POOL_AUTO = 0. Revert after.
- 11:08 Cyberpunk run 3 reverted: config identical to before; Start with = Madeira Dock, Steam starts = Steam's choice.
- 11:13 Cyberpunk item 12: same changes as run 3 (JIT_POOL_AUTO=0 line, Start with = The game, Program bin/x64/Cyberpunk2077.exe). Revert after.
- 11:36 Cyberpunk item 12 reverted: config identical to before; Start with = Madeira Dock.
## Final state (11:40 AM MT)
- Kept on purpose: The Planet Crafter own config: env.MADEIRA_EC_HOOK_TRACE = 0 (was there), env.MADEIRA_WG_64BIT = 1, env.MADEIRA_WG_VIDEO_FORMAT = argb32, env.MADEIRA_D3D11_NO_VIDEO_DEVICE = 1.
- Restored: Garry's Mod, BO2 Zombies, Cyberpunk (config and Start with), Borderlands 2.
- Counter-Strike 2: 'Show touch buttons' switched off to press GO, then back on (first pass).
- Not mine / not touched by me: Deep Rock Galactic's JIT memory settings were changed by Madeira itself during the first pass (its own box said so).
- Changes by the earlier sweep threads are as their notes describe (not re-checked by me).
- Item 13 Cyberpunk before: as the 10:06 listing, Start with = Madeira Dock. Adding env.MADEIRA_JIT_POOL_AUTO = 0, swap-mb = 8192, swap-mode = 2, swap-min-mb = 1; Start with = The game, bin/x64/Cyberpunk2077.exe. Revert after.
- 12:01 Item 13 reverted: Cyberpunk config identical to before (screen); Start with = Madeira Dock, Steam starts = Steam's choice. Recorder stopped. madeira-swap.bin from the run is in the app's tmp folder (not removed by me).
