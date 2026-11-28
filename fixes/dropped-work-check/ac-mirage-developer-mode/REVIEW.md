# REVIEW (second pass, Nov 17 2026, for 0.2.30): README + full patch read (3 files). Not compiled/run.
**Verdict: OK to queue, medium blast radius (rebuilds kernelbase + apisetschema for every game); low code risk.**
What it can break:
1. Every game: kernelbase.dll is loaded by every Windows process, so a build mistake here (wrong arch variant, missing export in one of x64/arm64ec/i386) breaks everything, not just ACMirage. The change itself is tiny: one apiset line (alphabetically placed), one export (`@ stdcall IsDeveloperModeEnabled(ptr)`), one function that writes FALSE if the pointer is writable and returns S_OK.
2. Signature is UNPROVEN (README says so). If the real one takes no argument or a different one, a caller passing garbage is guarded by IsBadWritePtr, so no crash from us; the game could still misbehave later. Reporting "developer mode off" is the right default.
3. Patch was made against PUBLIC willfaust/wine HEAD abf22e09, not our pin 3a257903: build thread must `git apply --check` on the pin; the iOS tree may differ.
4. Adding the apiset entry changes resolution for any DLL importing api-ms-win-appmodel-unlock-l1-1-0: it now resolves (was c0000135); intended.
5. Possible later failures in ACMirage after this (loader_section waits seen in b1563f38): fix may not make the game run.
Golden games: run ALL golden games (kernelbase is global). Check the new log line `IsDeveloperModeEnabled ... stub` appears only in ACMirage/Unity d3d12 cases.
Off switch: none (Wine DLL export). Revert = drop the patch.
