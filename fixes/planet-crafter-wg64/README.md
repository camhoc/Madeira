# planet-crafter-wg64: recommended list for The Planet Crafter (GOG, Unity 6 Mono 64-bit)

Thread "Fix Planet Crafter world loading". Written Nov 27 2026. STATUS: QUEUED for the next build (data only): planet-crafter-wg64.patch (GameRecommendations.swift, new list + SteamTitle row). Retest 2 PASSED Nov 27.

## Symptom (0.2.180 sweep, log Planet Crafter.exe-2026-11-27_05-19-24, iPad16,8)
New world sits on "Loading" for 9+ min. Game config held only `env.MADEIRA_EC_HOOK_TRACE = 0`. Lines:
    Player.log: WindowsVideoMedia error 0xc00d36bb while reading C:/GOG Games/The Planet Crafter/Planet Crafter_Data/sharedassets4.resource / Context: CreateObjectFromByteStream
    Madeira log @49287 mfreadwrite.dll loads, @49425 "[unixlib] winegstreamer (wma, libav*; 64-bit)", @49509 "[guest-log] #16 ... WindowsVideoMedia error 0xc00d36bb" (all 05:23:55); no [wg-parser] lines.
    [footprint] flat from 05:26 (phys 8044-8048 MB), [gpu-perf] 60 fps to the end.
Not the cause: "Unhandled JIT SIGBUS" 10854 lines (0x3c9b00c1 = STUR Q1,[X6,#-80], Mono code-write noise), last line 05:23:55; no [fexlock]/STUCK/memory warning.

## Prior knowledge (reference/madeira-library.md, Planet Crafter)
Madeira refuses wg_parser for 64-bit unless `env.MADEIRA_WG_64BIT = 1` -> 0xc00d36bb. After that (build 67, Nov 2): 0xc00d5212 (no colour converter) and missing msvproc.dll. 0.2.180 Wine source has wine/dlls/msvproc/ (checked in source zip) but the iPad prefix had no msvproc.dll (file listing). Second wall likely.

## Proposed change (data only, after test passes)
New GameRecommendation (modelled on `aviciiInvector`, program name "Planet Crafter.exe", GOG so a program match, not Steam App ID):
    env.MADEIRA_EC_HOOK_TRACE = 0
    env.MADEIRA_WG_64BIT = 1
Possibly also `env.MADEIRA_WG_VIDEO_FORMAT = argb32` (as AVICII Invector) if the retest shows the converter wall.
Off switch: the line itself. Set `env.MADEIRA_WG_64BIT = 0` in the game's config (or Reset to Recommended after deleting the entry). Off = today's behaviour (video parser refused, Loading hang).

## Retest (asked of the sweep thread, Nov 27 14:36Z)
Game config = the two lines above, NEW world, 8+ min untouched. Pass = loading video plays or is skipped and the world opens. Send back [wg-parser], 0xc00d, [vconv], msvproc lines.

## Retest 1 result (Nov 27 ~16:03Z, sweep thread's PC session): NOT a pass, wall moved
Config WG_64BIT=1 + EC_HOOK_TRACE=0, new world "Standard-3", 08:54:30-09:02:50 MT: still Loading, 59-60 fps, 8009 MB flat.
Player.log (twice): `WindowsVideoMedia error 0xc00d5212 while reading .../sharedassets4.resource / Context: Setting media type for first video stream / Error details: No suitable transform was found to encode or decode the content. / Track types: Video 1920x1080 NV12 (x2), YV12, YUY2, I420, IYUV; Audio %03, %01`
(Before: 0xc00d36bb at CreateObjectFromByteStream.) So the file now parses; the reader finds no colour-converter MFT.
Checked: iPad prefix has no msvproc.dll (system32/sysx64 listing). 0.2.180 Wine source has wine/dlls/msvproc/ (msvproc.c, video_processor.c using libswscale sws_scale_frame) but build/wine-pe/farm-modules.txt does NOT list msvproc, so it is never built or shipped.
## Next (proposal, needs second review)
Add `msvproc` to build/wine-pe/farm-modules.txt (same one-line shape as msmpeg2vdec msauddecmft). Open question for the build thread: msvproc imports $(FFMPEG_PE_LIBS) (libavutil + libswscale as PE libs); is that available in the farm build? Unproven.
Off switch: `msvproc=d` in the game's env.WINEDLLOVERRIDES (same as the msmpeg2vdec line). Blast radius: every game that CoCreates CLSID_VideoProcessorMFT (Unity video) now finds it instead of failing.

## Facts added Nov 27 ~16:07Z
- Build thread: farm build has NO libavutil/libswscale PE libs (build/wine-pe/build-modules.sh has no FFMPEG_PE_LIBS handling; build/ffmpeg/build.sh builds only static iOS unix-side libs, no libswscale). So adding msvproc to farm-modules.txt alone will not link.
- PC session: 0.2.180 IPA ships msvproc.dll and mfasfsrcsnk.dll ONLY in i386-windows (no arm64ec/aarch64). Retest 1 Player.log: 0xc00d5212 twice, tracks NV12/NV12/YV12/YUY2/I420/IYUV + 2 audio. Madeira log of that run not readable over AFC.
## Retest 2 (settings only, asked 16:07Z): the shipped AVICII Invector Unity-video recipe
    env.MADEIRA_WG_64BIT = 1
    env.MADEIRA_WG_VIDEO_FORMAT = argb32      (docs/MEDIA.md: native format the stream reports)
    env.MADEIRA_D3D11_NO_VIDEO_DEVICE = 1
    env.MADEIRA_EC_HOOK_TRACE = 0
Idea: stream reports ARGB32 so no colour-converter MFT is needed. Nov 2 notes (test6 cfg, argb32) got E_NOINTERFACE (needed msvproc service) on build 67; unknown whether 0.2.180 behaves the same. Off switch: remove the lines / WG_64BIT = 0.
If retest 2 fails, real fix = write the converter fresh (CPU NV12/I420/YV12/YUY2 -> RGB in the unix wg_transform, no swscale) or build libswscale as ARM64EC PE libs for msvproc. Medium size; second review needed.

## Retest 2 RESULT: PASS (Nov 27 ~16:43Z, PC session): world Standard-4, Load 09:41:00 MT, loading video played, world open 09:41:24, walked, ~40 fps, 8.4 GB.
Player.log: WindowsVideoMedia error lines NONE; instead "Color primaries 0 is unknown or unsupported by WindowsMediaFoundation" (video plays). msvproc NOT needed with these settings. Madeira log not read (game still running); not proven that the Mono SIGBUS noise is gone, only that the world opens.
## The patch
planet-crafter-wg64.patch (34 lines, against 0.2.180 app/Madeira/GameRecommendations.swift): new `planetCrafter` list (version 1: EC_HOOK_TRACE=0, WG_64BIT=1, WG_VIDEO_FORMAT=argb32, D3D11_NO_VIDEO_DEVICE=1) and a `steamTitles` row (App ID 1284190, folder "the planet crafter", program "planet crafter.exe", so the GOG copy matches by program). Included in `all` through `steamTitles.map(\.list)`. Not compiled. Build thread: tests/host/check-game-recommendations.py keeps id lists (MERGED etc.); add 'planet-crafter' there if it fails. Only a game with no config of its own gets the list once; Cameron's existing config already has these lines.
Off switch: `env.MADEIRA_WG_64BIT = 0` in the game's config (parser refused again as before); or drop the patch.

## Madeira log of the passing run (PC session, Nov 27 ~16:46Z)
@45384 "[wg-parser] ml1990 mp4/mov enabled: video on videotoolbox, aac on audiotoolbox, native video format bgra"; @45430 "connect container=mp4 codec=h264 backend=videotoolbox 1920x1080 fps=60 out=bgra duration=11216ms"; @45431 "codec=aac rate=48000 channels=2 backend=audiotoolbox". No 0xc00d or [vconv] hits in the first matches. So the video is an H.264 MP4 decoded by VideoToolbox, output BGRA; no converter needed. (Run header's "last step Wine finished +29.0 s" looks stale.)

## Update Nov 27 ~22:30Z: host test updated
Laptop check (fix/planet-crafter-wg64 RESULT.md): patch applied and typechecked, but tests/host/check-game-recommendations.py failed (preset id set, title count). planet-crafter-wg64.patch now also edits that test (paths relative to the Madeira root): add 'planet-crafter' to the expected id set, to the "recognised once" loop, to the "tested without madeira-bcd defaults" tuple, and SteamTitle count len(MERGED)+4 -> +5. Not run here (no swiftc in this session); needs a laptop re-run.
