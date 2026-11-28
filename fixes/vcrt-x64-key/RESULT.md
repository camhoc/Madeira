# RESULT: vcrt-x64-key

Checked on the Linux laptop against 0.2.180-og.

## Compile
ALREADY IN 0.2.180: the whole patch reverse-applies cleanly (git apply --check -R), so server_ios.c and LibraryBCD.swift already have it. The 0.2.180 app typechecks.

## Review: PASS (nothing to add)
Do not apply again. Off switches: env.MADEIRA_VCRT_X64_AUTO = 0, MADEIRA_VCRT_X64_KEY unset/0. Native view only, as README says.
