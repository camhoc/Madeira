# dock-eac-entry (app, Swift), rev=dock-eac-entry-2 (use dock-eac-entry-2.patch; -1 superseded)

Written Nov 28 2026 by thread "Get Halo running" (cmsg_01RYsSHVyBApabNeqTgzQudY2nYfPQbH7daasNuZaYhoC1). Base: 0.2.180 source (applies with `patch -p1` to source/madeira-0.2.180/Madeira, checked by dry run). Status: WRITTEN, host check passes (Python part; Swift fixture skipped, no compiler here), second review OK (REVIEW.md), F1+F2 applied in rev 2, not compiled, not device-tested.

## Why
Halo MCC (976730) has three walls, all from 0.2.101 iPad logs (sweep-0.2.101/Halo...):
- Default Dock start = mcclauncher.exe = Easy Anti-Cheat: `[win-name] ... text="Failed to initialize Wine helper buffer"`, `mcclauncher.exe status=0xeac9` (run 4). EAC's bootstrapper asks for memory at 0x7001_0000_0000+, which iOS cannot give (proved Nov 26, same as DroidDeck #1197). The 0.2.180 sweep used this route and failed the same way.
- Dock + "Steam starts" swap (copy of MCC-Win64-Shipping.exe over mcclauncher.exe): `[dll-missing] c0000135: steam_api64.dll, XAudio2_9Redist.dll, EOSSDK-Win64-Shipping.dll, ...` (run 2). 0.2.180 adds DLL links for this, but the copy still runs from the game root, while an Unreal exe finds its content relative to Binaries/Win64 (unproven for MCC, untested).
- "The game" + MCC-Win64-Shipping.exe + -no-eac: loads everything, D3D11 device made twice, then `NtTerminateProcess(handle=0x0, exit_code=0x1)` after 13 s (run 3). "The game" starts have no Steam client (Steam direct-start thread, Nov 26). steamclient64.dll loads, nothing answers. That the missing Steam client is why it quits is UNPROVEN.

Steam itself has an "Anti-Cheat Disabled" launch choice for MCC (Halo Waypoint support article 360037475251). Madeira Dock already passes a launch-option index to Valve's client (madeira-dock launch.c, MADEIRA_STEAM_HOST_LAUNCH_OPTION), but always picks the default entry (logs: `[madeira-dock] launch option 0`, 3 entries).

## What it does
For app IDs in `DockStartProgram.eacOfflineEntry` (only 976730 -> `mcc/binaries/win64/mcc-win64-shipping.exe`), a Dock start asks Valve's client for the launch entry whose program is that exe (path match, case and slash direction ignored). Valve's client then starts the exe (in the folder its entry names; not yet seen) with the entry's own arguments, and Steam keeps running. No file is swapped. If no entry matches, nothing changes (Steam's default entry). Every Dock start of Halo logs one `[dock-eac-entry]` line listing all entries (index, program, args, type), so the first run tells us the entry list even if it doesn't match.

## Off switch
```
env.MADEIRA_DOCK_EAC_ENTRY = 0
```
Off = 0.2.180 behaviour except one log line. Other games: unchanged (table lookup is nil, no log line).

## Unchecked / risks
- That Halo's launch config lists MCC-Win64-Shipping.exe as its own entry. From an earlier thread's note (Nov 25), not re-checked here. The log line will show it.
- Whether that entry's arguments already include -no-eac. If not, type `-no-eac` in Halo's Launch arguments (Dock passes them as user arguments in 0.2.180, ContentView `MadeiraDock.configure(... arguments:)`).
- A stored "Steam starts" choice for Halo (runs 1-2 used one) still swaps mcclauncher.exe; set Steam starts back to Steam's choice before testing.
- Offline only. No online matchmaking.

## Build step
New switch: build thread runs `build/tools/gen-config-catalog.py` and includes the regenerated ConfigCatalog.generated.swift.

## Golden games
Halo MCC (Dock), plus one Dock game unaffected: Fallout NV (Steam starts swap) and 7 Days to Die. Pass for them = same as 0.2.180.

## Online
Halo Waypoint support 360037475251 (Steam "Anti-Cheat Disabled" choice); WineHQ bug 58296 ("The game has an option to launch without it and it works fine", Proton/Wine 10.8); Steam discussion 3723946017836878896 (start the shipping exe directly with steam_appid.txt); Proton #2907 (msvcp140 next to the exe, not our case: run 3 loads MSVCP140.dll); CachyOS proton-cachyos #271 (XAudio2_9 crash ~8 s, PROTON_USE_PIPEWIRE=0; game ships XAudio2_9Redist.dll, loaded in run 3); GameNative/proton-wine PR #110 (open: xinput rumble lockup in MCC, relevant once it runs). Code is our own; nothing copied.
- R2: the [dock-eac-entry] line appears only when Steam's launch configuration was read. R3: a stored Steam starts swap matters only when no entry matches. No Swift host test covers eacOfflineEntryIndex yet.
