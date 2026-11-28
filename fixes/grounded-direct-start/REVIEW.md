# grounded-direct-start (for 0.2.102)

**What:** Grounded's recommended list (v1 -> v2) now also sets Game details > Steam > Start with = "The game" on
`Maine/Binaries/Win64/Maine-Win64-Shipping.exe`. New field `GameRecommendation.steamDirectProgram`, applied in
`takeEntryFields` (new entry or Reset to Recommended; existing entries keep their own fields, as for every list).

**Why (proven on device, 0.2.101 iPad sweep):** Grounded.exe (launcher stub) shows "The following component(s) are
required to run this program: Microsoft Visual C++ Runtime". Not fixed by the auto vcrt-arm64 marker, env.MADEIRA_VCRT_ARM64_KEY = 1,
wine-vcrt, or the VC++ installers (both `[dock-installers] exit ... status=3 failed`). Starting the Shipping exe directly:
box gone, `argv[1] = ...\Maine\Binaries\Win64\Maine-Win64-Shipping.exe`, `game shown (present) at +22 s`.
Cause of the stub's check: unproven. Old build line also started the Shipping exe (list matches `maine-win64-shipping.exe`).

**Off switch:** `env.MADEIRA_REC_STEAM_DIRECT = 0` in madeira.cfg (the field is then ignored; Madeira Dock stays).
Also safe-fails: if the exe is not in the install folder, Dock stays and a log line says so.

**Not checked:** NOT compiled (no Xcode here). `SteamSignIn.flag(_:default:)` and `LibraryEntry.hostURL` signatures copied from
other call sites. Not in ConfigCatalog.generated.swift (gen script not run). Direct start skips Steam: cloud-save sync still runs via
`cloudClear` in the launch path; online/Steam-API features unchecked. After direct start Grounded hits a black screen (4+ min, 60 fps),
a separate wall (black-screen thread).
**Second review (done, read-only, nothing compiled):** patch applies; symbols match. Found and FIXED: (1) host test stand-ins missing (added to tests/host/check-game-recommendations.py); (2) RemoteRecs.swift dropped the field (copied now); (3) program stored in on-disk spelling. Still true: existing library entries get nothing until Reset to Recommended.
Patch touches 4 files: GameRecommendations.swift, GameRecommendationsApply.swift, RemoteRecs.swift, tests/host/check-game-recommendations.py.
