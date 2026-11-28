# REVIEW (author pass Nov 28 2026; second review = the laptop compile check + "Review:" in RESULT.md)
**Verdict so far: OK to queue, low risk, one open question.**
- Scope: wine/dlls/ntdll/loader.c only, `#ifdef __arm64ec__` (the i386 and plain ARM64 ntdlls are unchanged, so 32-bit games such as OutlastLauncher.exe are not affected).
- Hook point: the same `if (...) load_path = system_dir` block as the xinput/ucrtbase rule in find_dll_file, relative names only.
- The path walk stops at C:\windows\system32\ so a copy in system32/PATH beyond it does not count as "shipped with the game". Path buffer is MAX_PATH with a length guard. `names[i]` copy fits companion[16] ("msvcp100.dll" = 12 chars + NUL).
- Check at read: `companion[4] = 'p'` turns "msvcr100.dll" into "msvcp100.dll" (index 4 is the 'r').
- Open: a 64-bit game with only msvcr<NN> natively and no msvcp<NN> that runs today on its native msvcr (never uses msvcp) would now get the builtin msvcr. Same route ucrtbase takes; needs one control game to confirm (README test 2).
- Golden: Outlast without `-32` is the target; no golden game expected to change.
Off switch: env.MADEIRA_NATIVE_MSVCR = 1.
