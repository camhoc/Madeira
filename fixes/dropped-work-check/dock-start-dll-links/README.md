# dock-start-dll-links (app, Swift), rev=dock-start-dll-links-2

Written Nov 26 2026 by thread "Get Halo MCC past Easy Anti-Cheat" (cmsg_01RYsSHVyBApabNeqTgzQudYEvDSiLfB9WWMHuwv8Jzog3). Base 0.2.101. Status: WRITTEN, not compiled (no Swift compiler here), not device-tested, REVIEW.md pending. Patch: dock-start-dll-links-2.patch (patch -p1 from the source root): app/Madeira/DockStartProgram.swift, ContentView.swift, tests/host/check-dock-start-program.py. Applies cleanly alone and together with pending-prs/dock-eac-offline (checked with patch, in that order: dll-links first, then dock-eac-offline-2).

## Why
Halo MCC, 0.2.101 iPad run 2 (Madeira Dock, Steam starts = MCC/Binaries/Win64/MCC-Win64-Shipping.exe): `mcclauncher.exe status=0xc0000135` and `[dll-missing] c0000135: steam_api64.dll, XAudio2_9Redist.dll, EOSSDK-Win64-Shipping.dll, bink2w64.dll, SimpleNetworkLibrary-x64-Release.dll, liblz4.dll, HaloNetworkLayer_Ship.dll, cell_Release_x64_4_0.dll`. The swap copies the chosen exe over the launcher in the game's root; Windows looks for DLLs next to the exe, not beside the original. In run 3 (exe run in place, no Steam client) all those DLLs load and the game then exits 1 by itself; the Dock route has Valve's Steam client running (it fixed Elden Ring: SteamAPI found Steam). Winlator/Odin guides also launch the shipping exe from its own folder (Online: redlib OdinHandheld thread, Halo MCC on Winlator).
Whether Steam being present stops Halo's exit(1) is UNPROVEN.

## What it does
When a Dock swap puts a program from another folder over the launcher, every ".dll" in the program's folder is linked (relative symbolic link, never over an existing name) into the launcher's folder. Names are listed in `<launcher>.madeira-dlllinks`; a restore (no choice, or Steam's own program) removes exactly those links. Same-folder swaps (7 Days to Die, Rust, Assetto Corsa, Fallout NV) link nothing. Same idea as the existing Unity data-folder link.

## Off switch
```
env.MADEIRA_DOCK_START_DLL_LINKS = 0
```
(default on; ContentView passes it to apply(); the file stays Foundation-only and the default parameter is false, so the host fixture is unchanged). Off: no links made and any listed links are removed at the next Dock start.

## Unchecked
- Not compiled. Do symlinked DLLs load in the iOS Wine path? Unity's data link precedent works for folders; DLL loading through a symlink is unproven.
- Halo's real next wall after the DLLs load.
- Halo MCC in Madeira Dock still starts through Steam's default entry, so it is the EAC-enabled start unless the shipping exe replaces mcclauncher.exe (that is the swap).
- Needs the golden games touching apply(): 7 Days to Die, Fallout: New Vegas.

## After the first review (-2)
- Fixed: the host check's exact text for the Unity switch is untouched (dllLinks is passed on the line before it, and sits before unityData in the signature); one new check line covers the new switch and the list file. Ran tests/host/check-dock-start-program.py (Python part) on a copy with this patch and dock-eac-offline-2 both applied: all PASS, Swift part SKIPPED (no compiler here).
- Fixed: restore uses try? for the link clean-up so the launcher always goes back; links made before a failure are still listed (defer).
- NOT done here: ConfigCatalog.generated.swift needs regenerating for the new switch (tests/host/check-config-catalog.py runs build/tools/gen-config-catalog.py --check, which needs the git checkout). The build thread must run `build/tools/gen-config-catalog.py` and include the result. The same applies to dock-eac-offline (env.MADEIRA_DOCK_START_EAC_OFFLINE) and halo-mcc-exit-ring (env.MADEIRA_HALO_EXIT_RING).
- Known: any existing cross-folder choice now gets links by default (off: the switch). The outcome text does not mention links. Likely next Halo wall, unproven: the copy runs as <game>/mcclauncher.exe, so Unreal-style relative content lookup may point outside the game folder.
