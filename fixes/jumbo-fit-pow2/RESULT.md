# RESULT: jumbo-fit-pow2

Checked on the Linux laptop against 0.2.180-og.

## Compile
NOT in 0.2.180; applies cleanly on top (git apply --check, then patch -p1). virtual_ios.c not compiled (needs a configured Wine build). No host test covers ios_jumbo_fit.

## Review: PASS WITH NOTES
- Off by default: with MADEIRA_JUMBO_FIT_POW2 unset or not exactly "1", powers of two return early as before.
- When on, the existing rules still apply (reserve-only, PAGE_NOACCESS, no hint/limit/alignment, >= 16 GB, the Steam/CEF image skip) and it also needs MADEIRA_JUMBO_FIT_GB.
- Risk: it applies to every power-of-two reserve of 16 GB+ in that game, including an in-process V8/Chromium cage inside the game exe itself (the skip only covers the Steam client and CEF helper programs by name). Set it only per game, as README suggests.
- The flag is read once per process (static), so it must be in the game's own config before the process starts.
- That 16 GB is enough for The Witcher 3 is unproven (README says so).
