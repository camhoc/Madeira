ac-mirage-developer-mode  (queued Nov 16 2026 for 0.2.29, Wine-side)
Fixes: Assassin's Creed Mirage (ACMirage.exe) stops before its window, exit code 1. The game's OWN d3d12.dll (C:\...\Assassin's Creed Mirage\d3d12.dll, loaded x64 at 0x71f6490000) delay-loads
api-ms-win-appmodel-unlock-l1-1-0.dll!IsDeveloperModeEnabled during DllMain. Our Wine has neither the apiset nor the export:
  load_dll [dll-missing] api-ms-win-appmodel-unlock-l1-1-0.dll c0000135
  LdrResolveDelayLoadedAPI [delay-fail] ... import="IsDeveloperModeEnabled"
  wine: Call from ... to unimplemented function api-ms-win-appmodel-unlock-l1-1-0.dll.IsDeveloperModeEnabled, aborting
  loader_init "d3d12.dll" failed to initialize, aborting
Evidence: sentry/reports-nov16d/7851023483-c9c30e59/z/game-run.txt line ~3810 (0.2.26 / Test 18, iPhone16,1), also -b1563f38 and -eb026133 (3 events).
Fix (own code, no BCD): 3 files
 - dlls/apisetschema/apisetschema.spec: apiset api-ms-win-appmodel-unlock-l1-1-0 = kernelbase.dll
 - dlls/kernelbase/kernelbase.spec: @ stdcall IsDeveloperModeEnabled(ptr)  (was commented stub)
 - dlls/kernelbase/main.c: HRESULT IsDeveloperModeEnabled(BOOL*): writes FALSE if the pointer is writable, returns S_OK, one FIXME line "IsDeveloperModeEnabled ... stub, reporting off".
Fix marker (log): "IsDeveloperModeEnabled" FIXME line in game log; source marker: dlls/kernelbase/main.c | IsDeveloperModeEnabled
Status: patch made against PUBLIC willfaust/wine HEAD abf22e09 (our pin 3a257903 is not fetchable from the cloud). Dry-run on the pin NOT done: build thread must `git apply --check` on the pin; if the iOS tree has its own apiset/kernelbase layout, port by hand. NOT compiled (no mingw here), NOT device-tested. Needs a Wine rebuild (kernelbase.dll + apisetschema.dll, arm64ec and x64 variants).
UNPROVEN: the real Windows signature. I assumed (BOOL *) returning HRESULT; I could not check it. The IsBadWritePtr guard avoids a crash if it really takes no argument. If d3d12 still aborts or misbehaves after this, disassemble the call in the game's d3d12.dll first.
Possible follow-up (not checked): the Unity-style process 0074 shows the same abort, so any d3d12.dll that ships with it benefits; ACMirage may fail later on something else (earlier event b1563f38 also shows loader_section waits, unrelated).
