# RESULT: oversize-reserve-min-mb

Checked on the Linux laptop against 0.2.180-og.

## Compile
Applies with `patch -p1`, alone and after bo3-stp-sd-emul (signal_arm64_ios.c hunks at different places, offsets 14-23 lines). fh6-keep-jit-regs then also applies after it. Not compiled (needs a configured Wine build). Symbols used exist: ios_fex_arena_base_unix / _end_unix (virtual_ios.c), ios_fft_arena_size, madeira_cfg_int, IOS_OVERSIZE_MIN.

## Review: PASS WITH NOTES
- The three new keys are off by default and only act with oversize-reserve = 1, as README says.
- NOT fully off: the signal_arm64_ios.c change (ios_in_fex_arena) applies to everyone. When an arena is published, emulator-page repairs now use the published range instead of the fixed 0x7C00000000-0x8000000000 band. The arena is placed dynamically (virtual_ios.c ~36900), so on devices where it is published outside that band, which pages get repaired changes for every game. Probably intended (README item 1), but say so and confirm with logs.
- oversize-reserve-top only for reserves >= IOS_OVERSIZE_MIN and with no fft arena; pools take a normal hole. Top placement tries at most 2048 candidates at 16 MB steps.
- Pool real part: min(oversize-pool-real-mb, half the request), floor 256 MB.
- Not device-tested; do not put in a recommended list yet (README).
