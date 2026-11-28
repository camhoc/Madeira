# RESULT: grounded-direct-start

Checked on the Linux laptop against 0.2.180-og.

## Compile
ALREADY IN 0.2.180. The patch does not apply (its context is older), but every line it adds is already in the 0.2.180 tree: steamDirectProgram in GameRecommendation and its summary, Grounded list version 2 with steamDirectProgram "Maine/Binaries/Win64/Maine-Win64-Shipping.exe", the apply block in GameRecommendationsApply.swift, the RemoteRecs copy, and the test stubs. RemoteRecs.swift reverse-applies exactly. The 0.2.180 app typechecks.

## Review: PASS (nothing to add)
Do not apply this patch again; it would conflict. Off switch env.MADEIRA_REC_STEAM_DIRECT = 0 is in 0.2.180.
