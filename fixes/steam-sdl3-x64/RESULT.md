# RESULT: steam-sdl3-x64

Checked on the Linux laptop against 0.2.180-og.

## Compile
NOT built here: build.sh clones SDL from GitHub (network) and needs cmake and ninja, which the laptop does not have (installing them needs Cameron's yes). llvm-mingw 20260421 for Linux is installed, so a Linux build should work once those are in place (README says the cloud built it on Linux with the same toolchain).

## Review: PASS WITH NOTES
- Source is pinned by full commit SHA (b1362f8a427b...), and the script checks HEAD equals it after checkout: that is a content check, so no separate checksum is needed.
- Output and notices: SDL3.dll (x86-64, as README says, not ARM64EC despite the arm64ec-windows folder name) and sdl3-notices.txt with SDL's LICENSE.txt. The notices row (zlib, unmodified upstream) is correct.
- An existing work/src clone that lacks the commit (no fetch) fails at checkout: re-clone by deleting build/sdl3/work.
- Any x64 program that loads SDL3.dll by name and does not ship its own will now get this one from system32. Games that ship their own load theirs first.
- Off switch: none in code; remove the DLL. Not device-tested.
