# CHECK: subnautica2-engine-ini
- NOT in any build yet. Patch is against the 0.2.180 source tree (release 0.2.180-og), NOT main. Read README.md and REVIEW.md (PASS WITH FIXES, fixes applied).
- Do: apply, typecheck the app (new UnrealIniSeed in DockInstallers.swift), run tests/host/check-game-recommendations.py and check-ini-editor. Second review too: "Review:" heading in RESULT.md with PASS or FAIL and reasons (off switch env.MADEIRA_UE_INI_SEED = 0, only Subnautica 2 list v3 turns it on).
- It edits tests/host/check-game-recommendations.py, as do planet-crafter-wg64 and cyberpunk-direct-start: say if the three conflict.
- Report: RESULT.md in this folder on this branch. Do not merge or push to main.
