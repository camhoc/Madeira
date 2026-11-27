# cyberpunk-direct-start: Cyberpunk 2077 starts its game program directly, with pool-split + NOCOPY (list v2)

Thread "Fix Cyberpunk crash at start", Nov 27 2026. Base: source/madeira-0.2.180 (GameRecommendations.swift, tests/host/check-game-recommendations.py). Settings only, Swift only, no native rebuild. NOT device-tested as a list; the same settings were tested by hand (below).

## Why (quoted from the iPad16,8 sweep retests, 0.2.180)
- Config with pool-split + env.MADEIRA_X64_IMAGE_NOCOPY (written by jit-pool-auto, "# Added by Madeira: this game ran out of JIT memory"): redprelauncher.exe `[child-end] ... status=0xc0000005 lived=2.21s`, `[crash-report]` module PocoFoundation.dll +0x27cfe, read of 0x4.
- Same config minus the two lines: launcher OK, game dies: `[jit-pool] EXHAUSTED (image 0x73fee40000+0x300000): want=0x310000 ... FAILING the load` x5, `[code-buffer] EXEC ALLOC FAILED ... JIT pool exhausted`, exit c000012d.
- Two lines back + Steam "Start with: The game", program bin/x64/Cyberpunk2077.exe, fresh Madeira: 0 EXHAUSTED, pool 848 MB, renderer runs (`last 600 lists: 24615 commands, 1940 draws`), then `[madeira-d3d12] newBuffer failed while the device is still responding` and `[task-exc] BREAKPOINT` (REDengine abort). One earlier run of this setup closed Madeira itself (.ips: abort() on a failed String allocation, log-tail thread); the next run did not.
- Regression guess (unproven): 0.2.97 -> 0.2.101 changed nothing in this list; the lines arrive from jit-pool-auto and break the launcher.

## Change
Cyberpunk list v2: adds `pool-split = 1`, `env.MADEIRA_X64_IMAGE_NOCOPY = 1` and `steamDirectProgram: "bin/x64/Cyberpunk2077.exe"` (the existing grounded-direct-start mechanism). Plus the GOG list described below. Host test updated (version table, tested lines, set of ids, counts 75/104). Host test run in a scratch copy: all PASS, Swift part SKIP (no compiler).

## Off switch
`env.MADEIRA_REC_STEAM_DIRECT = 0` in madeira.cfg stops the direct start (existing key, see the steamDirectProgram comment); delete the two lines in the game's config to drop them.

## Not checked / limits
- Swift not compiled. The list as applied by the app (first sight, Reset to Recommended) not device-tested.
- Does not make the game play: the failed newBuffer wall remains (see pending-prs/cyberpunk-newbuffer-probe).
- GOG copies (library entry REDprelauncher.exe, matched in `match`) get a separate list `cyberpunk-2077-gog` (v1): the old three lines WITHOUT pool-split/NOCOPY, so the launcher does not hit the Poco crash (coordinator's call, Nov 27). Added to `steamTitles` with empty matchers so `all` holds it (count 75 titles / 104 lists; host test updated). NOT tested on a GOG copy; whether those old lines let a GOG copy start is unknown.
