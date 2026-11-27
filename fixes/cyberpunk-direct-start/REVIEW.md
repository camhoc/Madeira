# REVIEW cyberpunk-direct-start
Status: author's own check only (Sonnet thread, Nov 27). NEEDS an independent second review before a build.
- Host test (python, scratch copy of the 0.2.180 tree) passes; Swift not compiled.
- Check: steamDirectProgram uses the same mechanism as Grounded (GameRecommendations.swift ~line 2725); confirm the list applies it for App ID 1091500 only when the program exists (SteamDirectStart.blocker).
- Check the new cyberpunk-2077-gog list: matched only by the redprelauncher.exe case; in steamTitles with empty matchers (Reset to Recommended finds it through `all`); count asserts 75/104 in the Swift fixture were edited by hand (not run).

## Second review (build thread, Nov 27 19:10Z)
cyberpunk-direct-start: PASS. Applies cleanly (patch --dry-run) to the 0.2.180 tree; check-game-recommendations.py on the patched copy: all PASS, Swift part SKIP (no compiler, so the 75/104 counts and the Swift fixture are still unrun; macOS side must run it). steamDirectProgram path matches GameRecommendationsApply.swift:274 (Steam App ID only, program must exist, off = env.MADEIRA_REC_STEAM_DIRECT = 0). GOG list is untested on a real GOG copy (author said so). Memberwise init order fine.
cyberpunk-newbuffer-probe: content PASS, FILE FAILS. The .diff has bad hunk counts and "unexpected end of file" under patch. Identifiers in scope (ph, heap_type, desc, info, MTLDevice_currentAllocatedSize used the same way at line 10520). Use cyberpunk-newbuffer-probe-fixed.diff (regenerated, applies cleanly to 0.2.180). Not compiled.
