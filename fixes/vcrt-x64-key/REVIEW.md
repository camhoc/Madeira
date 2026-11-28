# vcrt-x64-key (for the build after 0.2.101)

**What:** publishes the x64 Visual C++ 2015-2022 "Installed" marker (HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64, volatile,
native view) the same way the arm64 one is, for Unreal games. C: `ios_vcrt_arm64_key_publish` now calls a shared helper for both
(env.MADEIRA_VCRT_ARM64_KEY, env.MADEIRA_VCRT_X64_KEY). Swift: `applyVCRTArm64` also sets MADEIRA_VCRT_X64_KEY=1 for Unreal games.

**Why (evidence, iPad 0.2.101, Stray; Grounded same box):**
- Box "The following component(s) are required to run this program: Microsoft Visual C++ Runtime" raised by Stray.exe / Grounded.exe.
- file trace: last open before the box = Engine\Extras\Redist\en-us\UE4PrereqSetup_x64.exe -> 0xc000003a (path not found); nothing opened vcruntime140/msvcp140.
- prefix registry (logs/sweep-0.2.101/Stray/vcrt-registry.txt): the only VC\Runtimes key is Wow6432Node\...\x86 (Installed=1, 14.24.28127.04); no x64, no arm64 key. Stray.exe is 64-bit.
- arm64 marker (incl. 14.50.35717) already written, box stays. wine-vcrt on, installers skipped: box stays. 2010 redist installers exit status=3 (unrelated, unproven).
**Cause: UNPROVEN.** That the bootstrap reads the x64 key is a reading of the above; it was not seen reading it. x64 key by hand was not tested (no run-once option).

**Off switch:** env.MADEIRA_VCRT_X64_AUTO = 0 (madeira.cfg) stops the automatic value; env.MADEIRA_VCRT_X64_KEY = 0 in a game config turns it off for that game.
**Risk:** a game whose own installer later writes ...\Runtimes\x64 meets an existing volatile leaf (leaf only; parents ordinary via env.MADEIRA_VCRT_PARENTS default), like arm64; the existing Little Nightmares 1627 note concerned volatile parents. Not tested.
**Not checked:** NOT compiled (C and Swift). Patch applies (dry run). Test: Stray and Grounded (Dock mode, no direct start) on the next build: look for "[vcrt-x64] ... 1 of 1 view(s) written" then box or no box. Regression: Satisfactory, Subnautica 2.
**Second review (read-only, nothing compiled): no blocking problems.** Log format args match; arm64 behaviour unchanged; patch applies with `patch -p1` from the `Madeira/` folder. Notes: X64_AUTO only applies when ARM64_AUTO and the Unreal check pass; a later installer writing Runtimes\x64 would lose its values at session end (volatile leaf); env.MADEIRA_VCRT_X64_AUTO is not in ConfigCatalog.generated.swift (gen script not run).
