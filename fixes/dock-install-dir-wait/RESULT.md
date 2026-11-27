# RESULT: dock-install-dir-wait

**PASS (minor concern) / NEEDS-DEVICE**

Checked 2026-11-27 on Linux against the 0.2.180-og source zip.

## What was run
Patch is already applied in the 0.2.180-og tree (reverse-apply check succeeds). Code read only: the touched module was NOT built and nothing ran on a device.

## Findings
- Retry loop is bounded (20 queries, about 9.5 s) and still returns 41 on failure; `MADEIRA_DOCK_INSTALL_DIR_WAIT=0` gives a single query.
- madeira-dock/src/launch.c:315: if `actual_utf8` has no NUL after the last query, `%s` can read past the buffer. Force termination or use `%.*s`.
- A query that always fails logs the failure 20 times.

## Compile check added (2026-11-27)
The line above about the module not being built is now out of date.
- madeira-dock `tools/build.sh` with llvm-mingw 20260421 (Linux): x86-64 and i386 build cleanly with -Werror, patch included.
- `tools/check.sh` unit tests pass with `gcc -D_GNU_SOURCE`. Without that define they fail to compile on Linux (`strnlen` undeclared in friends_format.c).
- Not run on Windows or a device; the launch.c:315 concern still stands.
