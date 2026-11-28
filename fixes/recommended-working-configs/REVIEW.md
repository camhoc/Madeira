# REVIEW recommended-working-configs

Review 1 (author, Nov 28, no Swift compiler): both patches apply with `patch -p1` to pristine 0.2.180 (dry-run and real); `check-game-recommendations.py` PASSES (source checks) with both applied; the two lists follow the pattern of other own-written lists (EC_HOOK_TRACE = 0 + game lines, no BCD defaults, version 1); keys exist in the config catalog (checker verified `pool-split`, `env.` names are free-form).
Not done: the Swift fixture (ids by folder/program, counts 76/105) was not run. Second review + compile: laptop (fix branch RESULT.md "Review:").
Risk: very low (data-only, per-game, two games with no other config path). Worst case: a list applied to the wrong game if a folder name collides; limited to `SMC_HOT_PAGE = 0` / the two pool lines.
