# RESULT: project-zomboid-rec-v3

Checked on the Linux laptop against 0.2.180-og.

## Compile
Both patches apply with `patch -p1`; check-game-recommendations.py exit 0, Swift fixture included (the laptop runs it). Counts unchanged (74 titles / 103 lists): no new title.

## Review: PASS WITH NOTES
- It is a version bump of the existing entry (projectZomboid, id project-zomboid, 2 -> 3), not a second entry. No key appears twice in the list.
- env.MADEIRA_X64_RWX_PLAIN exists in 0.2.180 (ConfigCatalog, gen-config-catalog.py). The new _JAVA_OPTIONS replaces the G1GC one in the same line.
- Old v2 configs, by the code (GameRecommendationsApply.due / RecommendedMerge.merge):
  - a config Madeira wrote at v2 and nobody changed is REPLACED by v3 (Madeira's own additions are kept below it);
  - a config the player changed gets only MISSING keys: env.MADEIRA_X64_RWX_PLAIN = 1 is added, but `env._JAVA_OPTIONS` already exists, so the old G1GC line STAYS. Those players keep the crashing GC until Reset to Recommended.
- README is honest that this reaches the menu only; world load is still open.

## Merged result (apply-all game lists: recommended-working-configs, planet-crafter-wg64, subnautica2-engine-ini, cyberpunk-pool-arena, project-zomboid-rec-v3)
Swift parts all apply; check-game-recommendations.py hand-merged; merged test exit 0 with the Swift fixture. Final counts: 77 titles, 106 lists; SteamTitle count = len(MERGED) + 5. Versions: subnautica-2 3, project-zomboid 3, cyberpunk-2077 2.
```diff
--- a/tests/host/check-game-recommendations.py
+++ b/tests/host/check-game-recommendations.py
@@ -74,12 +74,12 @@
           'batman-arkham-city-goty', 'trails-in-the-sky-1st-chapter', 'subnautica-2', 'rdr1-steam', 'resident-evil-requiem', 'resident-evil-requiem-demo',
           'life-is-strange-remastered', 'life-is-strange-2', 'project-zomboid', 'spiderheck', 'rounds', 'plateup',
           'final-fantasy-tactics-ivalice-chronicles', 'jetboard-joust', 'dead-as-disco', 'tung', 'sekiro-shadows-die-twice', 'stardew-valley', 'slay-the-spire-2',
-          'glyphica-typing-survival', 'football-manager-27', 'the-adventures-of-elliot', 'the-escapists-2', 'garrys-mod', 'persona-3-reload', 'grounded', 'innerspace', 'satisfactory-steam', 'blue-prince', 'the-forest', 'steep', 'just-cause-2', 'goals', 'dotnet-large-heap', 'cyberpunk-2077'}
+          'glyphica-typing-survival', 'football-manager-27', 'the-adventures-of-elliot', 'the-escapists-2', 'garrys-mod', 'persona-3-reload', 'grounded', 'innerspace', 'satisfactory-steam', 'blue-prince', 'the-forest', 'steep', 'just-cause-2', 'goals', 'dotnet-large-heap', 'cyberpunk-2077', 'resident-evil-5', 'euro-truck-simulator-2'}
 assert set(presets) == {'rdr2-steam', 'rdr2-other', 'gta5e-steam', 'gta5e-other', 'gta5l-steam', 'gta5l-other', 'gta4-steam',
                         'ghost-of-tsushima', 'god-of-war', 'horizon-zero-dawn', 'horizon-forbidden-west', 'ratchet-clank-rift-apart',
                         'crysis-remastered', 'crysis-2-remastered', 'crysis-3-remastered', 'rockstar-launcher', 'rockstar-launcher-setup',
                         'battle-net', 'battle-net-setup', 'steam-big-picture', 'dark-souls-remastered', 'dark-souls-iii', 'fallout-new-vegas', 'fallout-3', 'black-ops-1', 'black-ops-2', 'borderlands-2',
-                        'standard', 'melonloader', 'avicii-invector', 'final-fantasy-resonance', 'sonic-generations', 'detroit-become-human'} | MERGED, \
+                        'standard', 'melonloader', 'avicii-invector', 'planet-crafter', 'final-fantasy-resonance', 'sonic-generations', 'detroit-become-human'} | MERGED, \
     sorted(presets)
 assert ('static let all = [rdr2Steam, rdr2Other, gta5EnhancedSteam, gta5EnhancedOther, gta5LegacySteam, gta5LegacyOther, gta4Steam,\n'
         '                      ghostOfTsushima, godOfWar, horizonZeroDawn, horizonForbiddenWest, ratchetClankRiftApart, crysisRemastered,\n'
@@ -131,10 +131,10 @@
 assert 'if let on = rec.startServices { entry.startServices = on ? true : nil }' in apply_src
 # Each list in the Steam title table is recognised once.
 titles_src = block(lists_src, '    static let steamTitles: [SteamTitle] = [', '\n    ]\n')
-for ident in MERGED | {'avicii-invector'}:
+for ident in MERGED | {'avicii-invector', 'planet-crafter'}:
     assert titles_src.count('list: %s)' % presets[ident]['name']) == 1, ident
 assert titles_src.count('list: finalFantasyResonance)') == 1
-assert titles_src.count('SteamTitle(') == len(MERGED) + 4   # AVICII Invector, FINAL FANTASY RESONANCE, Sonic Generations, Detroit: Become Human
+assert titles_src.count('SteamTitle(') == len(MERGED) + 5   # AVICII Invector, The Planet Crafter, FINAL FANTASY RESONANCE, Sonic Generations, Detroit: Become Human
 # ml2021: the Big Picture entry (C:\big-picture.bat) is recognised by its batch name and gets the Steam Big Picture list
 assert 'if last == "big-picture.bat" { return steamBigPicture }' in lists_src
 assert 'static var bigPictureEntry: LibraryEntry' in library and 'relativePath: "big-picture.bat"' in library \
@@ -192,8 +192,8 @@
         p['tested'], p['fork'] = [line for line in p['lines'][2:] if not line.startswith('#')], []
         continue
     # These lists were tested without madeira-bcd's defaults.
-    if ident in ('standard', 'fallout-new-vegas', 'fallout-3', 'black-ops-1', 'black-ops-2', 'borderlands-2', 'persona-3-reload', 'avicii-invector',
-                  'satisfactory-steam', 'melonloader', 'final-fantasy-resonance', 'metaphor-refantazio', 'dying-light-2', 'baldurs-gate-3', 'blue-prince', 'the-forest', 'steep', 'just-cause-2', 'sonic-generations', 'detroit-become-human', 'cyberpunk-2077', 'football-manager-27'):
+    if ident in ('standard', 'fallout-new-vegas', 'fallout-3', 'black-ops-1', 'black-ops-2', 'borderlands-2', 'persona-3-reload', 'avicii-invector', 'planet-crafter',
+                  'satisfactory-steam', 'melonloader', 'final-fantasy-resonance', 'metaphor-refantazio', 'dying-light-2', 'baldurs-gate-3', 'blue-prince', 'the-forest', 'steep', 'resident-evil-5', 'euro-truck-simulator-2', 'just-cause-2', 'sonic-generations', 'detroit-become-human', 'cyberpunk-2077', 'football-manager-27'):
         # steep-epic-launcher-wait: Steep's own fix IS the wait-for-children rule, not the community defaults
         own_fix = {'env.MADEIRA_WAIT_CHILDREN = 1'} if ident == 'steep' else set()
         assert not (set(FORK_DEFAULTS) - own_fix) & set(p['lines']), (ident, "the standard list has none of madeira-bcd's defaults")
@@ -497,14 +497,17 @@
 # variant or app-side switches, and no MADEIRA_SPAWN_SWAP (its engine code is not in this tree).
 for ident in MERGED:
     p = presets[ident]
-    assert p['version'] == (4 if ident == 'baldurs-gate-3' else 2 if ident in ('batman-arkham-city-goty', 'counter-strike-2', 'beamng-drive', 'metaphor-refantazio', 'goals', 'dotnet-large-heap', 'project-zomboid', 'slay-the-spire-2', 'the-escapists-2', 'subnautica-2', 'resident-evil-requiem', 'grounded') else 1), ident
+    assert p['version'] == (4 if ident == 'baldurs-gate-3' else 3 if ident in ('subnautica-2', 'project-zomboid') else 2 if ident in ('batman-arkham-city-goty', 'counter-strike-2', 'beamng-drive', 'metaphor-refantazio', 'goals', 'dotnet-large-heap', 'cyberpunk-2077', 'slay-the-spire-2', 'the-escapists-2', 'resident-evil-requiem', 'grounded') else 1), ident
     assert not any(line.startswith(('env.MADEIRA_WINTYPES', 'env.MADEIRA_OPTIN_DLLS', 'env.MADEIRA_D3D8 ',
                                     'env.MADEIRA_STEAM_IDENTITY', 'env.MADEIRA_MFC_DOCK', 'pool-split-retry'))
                    for line in p['lines']), (ident, p['lines'])
 assert [ident for ident, p in presets.items() if any(line.startswith('env.MADEIRA_SPAWN_SWAP') for line in p['lines'])] == []
 # cyberpunk-oversize-2gb: Cyberpunk 2077 is the standard line plus a 2 GB real part for its 64 GB reservation (the
 # 8 GB real part of the first reports left no room for its later 4 GB one). No other list sets the size.
-assert presets['cyberpunk-2077']['tested'] == ['env.MADEIRA_EC_HOOK_TRACE = 0', 'oversize-reserve = 1', 'oversize-reserve-mb = 2048'] \
+assert presets['cyberpunk-2077']['tested'] == ['env.MADEIRA_EC_HOOK_TRACE = 0', 'oversize-reserve = 1', 'oversize-reserve-mb = 2048',
+                                                'pool-split = 1', 'pool-low = 1', 'pool-page-fit = 1', 'env.MADEIRA_POOL_LOW_IMAGES = 1',
+                                                'env.MADEIRA_POOL_RECYCLE_IMAGES = 1', 'arena-mb = 4096', 'env.MADEIRA_FEX_ARENA_GROW = 1',
+                                                'env.MADEIRA_JIT_POOL_AUTO = 0'] \
     and presets['cyberpunk-2077']['switches'] == '', presets['cyberpunk-2077']
 assert [i for i, p in presets.items() if any(l.startswith('oversize-reserve-mb') for l in p['lines'])] == ['cyberpunk-2077']
 assert ('        case "redprelauncher.exe":\n' in lists_src
@@ -932,6 +935,10 @@
       "the first Black Ops' multiplayer shares the folder and has no list")
 check(id(steam + #"\The Escapists 2"#, 641990) == "the-escapists-2" && id(steam + #"\The Escapists 2\TheEscapists2.exe"#) == "the-escapists-2",
       "The Escapists 2 by App ID, folder and program")
+check(id(steam + #"\Resident Evil 5"#) == "resident-evil-5" && id(steam + #"\Resident Evil 5\re5dx9.exe"#) == "resident-evil-5",
+      "Resident Evil 5 by folder and program (no App ID)")
+check(id(steam + #"\Euro Truck Simulator 2"#) == "euro-truck-simulator-2" && id(steam + #"\Euro Truck Simulator 2\bin\win_x64\eurotrucks2.exe"#) == "euro-truck-simulator-2",
+      "Euro Truck Simulator 2 by folder and program (no App ID)")
 check(id(steam + #"\GarrysMod"#, 4000) == "garrys-mod" && id(steam + #"\GarrysMod\bin\win64\gmod.exe"#) == "garrys-mod",
       "Garry's Mod by App ID and folder (either branch) and by its 64-bit program")
 check(id(steam + #"\P3R"#, 2161700) == "persona-3-reload" && id(steam + #"\P3R\P3R\Binaries\Win64\P3R.exe"#) == "persona-3-reload",
@@ -954,7 +961,7 @@
          files: [#"C:\Program Files\Epic Games\InnerSpace\version.dll"#, #"C:\Program Files\Epic Games\InnerSpace\MelonLoader"#]) == "innerspace",
       "a game's own list wins over the MelonLoader list")
 check(R.melonLoader.fileText.contains("\noversize-reserve = 1\n"), "the MelonLoader list serves large reservations in part")
-check(R.steamTitles.count == 74 && R.all.count == 103, "74 titles in the Steam table, 103 lists (+ Football Manager 27, GOALS, Portal, .NET program, The Forest, Steep, Just Cause 2, Sonic Generations, Detroit, Hades II, L.A. Noire, Cyberpunk 2077; The Witcher 3 dropped)")
+check(R.steamTitles.count == 77 && R.all.count == 106, "77 titles in the Steam table, 106 lists (+ The Planet Crafter, Resident Evil 5, Euro Truck Simulator 2, Football Manager 27, GOALS, Portal, .NET program, The Forest, Steep, Just Cause 2, Sonic Generations, Detroit, Hades II, L.A. Noire, Cyberpunk 2077; The Witcher 3 dropped)")
 check(id(steam + #"\Cyberpunk 2077"#, 1091500) == "cyberpunk-2077" && id(steam + #"\Cyberpunk 2077"#) == "cyberpunk-2077"
       && id(#"C:\GOG Games\Cyberpunk 2077\bin\x64\Cyberpunk2077.exe"#) == "cyberpunk-2077"
       && id(#"C:\GOG Games\Cyberpunk 2077\REDprelauncher.exe"#, files: [#"C:\GOG Games\Cyberpunk 2077\bin\x64\Cyberpunk2077.exe"#]) == "cyberpunk-2077"
```
