# msvcr-mixed-builtin: Outlast (64-bit) dies at "MSVCP100.dll failed to initialize"

Written Nov 28, 2026 (thread "Fix Outlast crash at load"). Patch is against the 0.2.180 loader (applies clean with `patch -p3` on wine/dlls/ntdll/loader.c). NOT compiled, NOT device-tested.

## Symptom (0.2.180, iPhone15,4, player MD-9E97-JK, Sentry GET-HELP-LOGS-34E, events 1a11696e / 591d11ef)
    0100:err:seh:ios_wild_exec_probe [wild-exec] #1 ... code=c000001d target=00000070ECAD0000 (in system DLL MSVCP100.dll +0x0 sect=none)
    0100:err:module:loader_init "MSVCP100.dll" failed to initialize, aborting
Both the 64-bit OLGame.exe and the 64-bit launcher path die this way. The same player's run that worked for about an hour (event 5afdafc5) had the library argument `-32`, i.e. the 32-bit game.

## Cause (PROVEN by log lines + disassembly of the shipped 0.2.180 msvcp100.dll)
1. Outlast's Binaries\Win64 folder has Microsoft's x64 msvcr100.dll (files.txt: `829264 Binaries/Win64/msvcr100.dll`) and NO msvcp100.dll. Game log: `[jit-pool] image 0x70ecfe0000+0xd2000 (MSVCR100.dll)` (the builtin ARM64EC msvcr100 is 0x140000 big, so this is the game's x64 copy), then msvcp100 loads as Wine's builtin: `[x64-ntdll-file] ...MSVCP100.dll -> ...\sysx64\MSVCP100.dll`, `[jit-pool] image 0x70ecad0000+0x140000 (msvcp100.dll)`.
2. msvcp100 (ARM64EC) calls memcpy through a linker thunk (disassembly of arm64ec-windows/msvcp100.dll in the 0.2.180 IPA, `#memcpy` at RVA 0x80574): `adrp x16,.. ; ldr x16,[..]; br x16` and, on the indirect path, `adrp x10,<image base>; add x10,x10,#0` -- the exit thunk is the image base itself (no exit thunk exists for memcpy/memmove/memset, the ARM64EC ABI expects an EC target).
3. The import is bound to the game's x64 msvcr100 memcpy. Fault registers: `x9=0x70ed01bf60` (inside the x64 msvcr100 at 0x70ecfe0000), `x10=0x1707d8000 x11=0x1707d8000` (the pool alias of msvcp100's image base). arm64x_check_call (signal_arm64ec.c) says "not EC code" for the x64 target and goes to `.Lexit`: `mov x9,x11; mov x11,x10`, so the thunk branches to x10 = the image base = the MZ header (`words ... 00785a4d` in `[illegal-insn]`, bytes `4d 5a 78 00`). ARM64 sees an illegal instruction: c000001d at msvcp100.dll+0x0.
4. The call site: `lr PE: msvcp100.dll+0x7700c` = after `bl #memcpy` in `_Yarn_char_op_assign_cstr`, called from msvcp100's init.
The 32-bit game is untouched because the i386 msvcp100/msvcr100 call each other as plain x86.
Not AVX (Get Help's text and the AVX hint in the report are wrong for this one).

## Fix
`madeira_msvcr_mixed_builtin` (loader.c, ARM64EC build only): when the load path reaches an `msvcr<NN>.dll` request (NN = 71, 80, 90, 100, 110, 120) and no `msvcp<NN>.dll` sits in any folder before system32, search system32 only for it, so the builtin ARM64EC msvcr<NN> is used (same mechanism as the existing ucrtbase rule in madeira_force_builtin_dll). A game that ships BOTH msvcr and msvcp natively is not touched. Logs `[msvcr-builtin] ...` (max 8).
Only msvcr100 is proven by a log. The others are the same mixed layout with the same thunk pattern (disassembly count of `adrp x10,base` thunks: msvcp71/80/90/100/110/120 all have 3-4); no report for them yet.

## Off switch
`env.MADEIRA_NATIVE_MSVCR = 1` (read once with RtlQueryEnvironmentVariable_U) gives the old behaviour (the crash for Outlast).

## Test
1. Outlast 64-bit (Steam 238320), launch with no `-32` argument. Expect `[msvcr-builtin] msvcr100.dll: no msvcp100.dll beside it ...`, no `[wild-exec]`, no `MSVCP100.dll failed to initialize`, and the game window.
2. Controls (golden): one 64-bit game that ships its own msvcr100.dll AND msvcp100.dll (no `[msvcr-builtin]` line, same as before), and one 64-bit game that ships only msvcr100/110/120.dll and no msvcp (`[msvcr-builtin]` line, must still start). Games to look for: UE3/Unity titles with VC2010/2012/2013 runtime in their Win64 folder.
3. Then BO3 + OW2 (every build carries them) as usual.

## Skipped / unchecked
No compile (needs the Wine tree), no device run. Whether the builtin ARM64EC msvcr100 serves the 64-bit OLGame.exe's own CRT calls correctly (it is Wine's msvcrt) is unproven; ucrtbase takes the same route today. Why the other c000001d reports (Minecraft Dungeons II, StS2, Blue Prince, CarX 2: pool pc ending in 50c, not an image base) look similar is not checked and not claimed to be this bug.
