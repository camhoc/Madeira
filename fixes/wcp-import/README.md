# wcp-import (DRAFT design + first code, not compiled)

Off switch: `env.MADEIRA_WCP_IMPORT = 0` (default ON as a button only; nothing changes unless a person picks a .wcp). Per rule 8 it only writes into ONE game's own prefix/game folder, never global.

## Online
GameNative PR #1740 (custom Vulkan wrapper import via Contents Manager, .wcp/.tzst + root profile.json, import flow untested), PR #2240 (WCP-backed DXVK selection fix; reviewer asked for source-file validation), WinNative-components README (component list), Nick088 WCP collections, Winlator forks. Schema files (Profiles/, contents.json) NOT read.

## Format (CHECKED Nov 27 on a real package: WinNative-Components Dxvk-3.0.2-gplasync-8dd0c490.wcp, 7 MB)
XZ-compressed tar (not zstd). Root `profile.json`: `type` ("DXVK"), `versionName`, `versionCode`, `description`, `author`, `files:[{source,target}]`. Folders `system32/` (64-bit DLLs: d3d8, d3d9, d3d10core, d3d11, dxgi) and `syswow64/` (32-bit). Targets are `${system32}/x.dll` / `${syswow64}/x.dll` (PR #1740 also shows `${libdir}`, `${sharedir}`). The FEXCore download URL returned plain text, not an archive, so FEX packages are still unseen.
Important: DXVK DLLs would replace d3d11/dxgi in the prefix; Madeira's D3D11 normally goes through DXMT, so a DXVK package may not even load unless the game is set to a DXVK route. Needs the DXMT owner to say whether that is useful.

## What Madeira accepts
Allowed types only: DXVK, VKD3D-Proton (Windows DLLs, any host), FEX/FEXCore, Wine/Proton files. Refused with a plain message: Turnip, Adreno/Mali drivers, Vulkan wrapper, Box64, WOWBox64 (Android-only; Madeira uses FEX/MoltenVK/KosmicKrisp/DXMT).

## Design (smallest)
1. Reuse the existing mod pipeline (ModsView picker -> ModInstaller.prepare -> ModStore record, so uninstall/disable already exist). Add one branch in `prepare`: if the file is zstd/xz tar, unpack to `files/`, read `profile.json` (WCPProfile.swift), keep it as `ModKind.component`.
2. Install = copy mapped files into that game's prefix (system32/syswow64 for DLLs, FEX folder for FEX), backing up replaced files in the mod record so uninstall restores them. Never touch another game.
3. Safety: reject `..`, absolute paths, symlinks, targets outside the allowlisted folders, and unknown `type`. Show the file list before installing. Log every file copied.
4. Per-game only; shows in log as "wcp: installed <name> <ver> (<n> files)".

## Missing / open
- Tar reader + xz/zstd call: bridging header has a zstd decoder and a liblzma shim (Steam content), not yet checked that it supports streaming a whole tar.
- ModKind is Codable; adding `.component` needs a decode fallback for old records.
- Which prefix folder FEX files go to (needs the FEX owner).
- Needs real .wcp samples from Timmy to confirm the schema.

## Findings from reading the source (Nov 27)
- Madeira's per-game `system32` is a farm of LINKS into shared Wine files (ConfigCatalog note for MADEIRA_AARCH64_D3DCOMPILER). Install must replace the link with a real file inside that game's prefix only (never write through the link into the shared copy), and uninstall restores the link. Not written yet.
- Existing helpers: itch_7z.h (streaming 7z over liblzma) and lzma_shim.h (Steam content). An xz-compressed TAR reader is NOT there; needs a small new one (xz decode via the shim + ~60-line tar parser).
- Real sample inspected only in /tmp, read-only (not extracted onto the project drive).

## REVISED DESIGN (Nov 27, after reading WineProcessBridge.m)
Madeira ALREADY has a DXVK route (`d3d11 = dxvk`) and a vkd3d-proton route (`d3d12 = vkd3d`), both marked "Experimental, not device-tested", linked from the bundle's vulkan/arm64ec-windows/ each session. The prefix is relinked every session, so writing DLLs into system32 would be undone. So the mod installer's copy-into-game-folder is the wrong fit. Instead:
- `WCPStore.swift` keeps imported DLLs in <Application Support>/WCP/<name>/ (never in a prefix).
- `wcp-import.diff` (WineProcessBridge.m, ~25 lines): per-game lines `d3d11-package = <name>` / `d3d12-package = <name>` make the existing route link from that folder instead of the bundle; missing/incomplete/unsafe name -> bundle DLLs stay and a `[wcp]` log line says so. Off: `env.MADEIRA_WCP_IMPORT = 0`.
- Undo = `WCPStore.remove(name)`; nothing else to restore.
- Scope v1: DXVK and vkd3d-proton only (64-bit set). FEX/Wine/others refused. Both existing routes are experimental, so this is a test tool for swapping their versions.
- Open: is a package's DLL ARM64EC (what the bundle uses) or plain x64? The two DXVK packages I opened both report machine 0x8664 (ARM64EC images use that too); not proven which. A wrong-arch DLL would fail to load in the session.
- Still not written: xz-tar unpack, the picker/UI button (reuse ModsView's UIDocumentPicker), config-catalog entries for the two keys.

## STATUS Nov 27 (late): pieces now written
- SwiftWCP/wcp_untar.{c,h}: xz-tar unpack (links, "..", absolute, backslash names refused; file/size caps; O_EXCL|O_NOFOLLOW) and wcp_pe_kind (told ARM64EC from plain x64 by the load config's CHPE pointer). HOST-TESTED with gcc + liblzma on two real packages: untar byte-identical to `tar` output; ARM64EC package -> kind 2, plain x64 package -> 1, 32-bit -> 4; symlink tar, "../" tar, truncated file and a non-xz file all refused with the right code; long GNU names work.
- WCPStore.swift: importPackage (unpack, profile check, every needed DLL must be ARM64EC else refused with a plain message), list, remove, setLine (edits only the one config line).
- WCPSection.swift: "Graphics packages (experimental)" section (import button, Use for this game / Stop using, Remove).
- wcp-import.diff (WineProcessBridge.m) and wcp-import-wiring.diff (bridging header, ModsView, config catalog generator overlay for d3d11-package, d3d12-package, env.MADEIRA_WCP_IMPORT).
- Build thread must: add the 5 new files (SwiftWCP/wcp_untar.c/.h, WCPProfile/WCPStore/WCPSection.swift) to Madeira.xcodeproj, apply both diffs, run build/tools/gen-config-catalog.py, typecheck, run check-config-catalog.py.
- Not done / unproven: Swift not compiled (no swiftc here); nothing run on a device; the vkd3d-proton package layout (file names d3d12.dll / d3d12core.dll) not seen in a real package; the app's own bundle DLLs' machine type not inspected (only that they are ARM64EC per the code comments).
