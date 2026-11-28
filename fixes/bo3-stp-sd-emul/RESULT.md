# RESULT: bo3-stp-sd-emul

Checked on the Linux laptop against 0.2.180-og.

## Compile
Applies (patch -p0 in build/ntdll-unix); the result equals the full signal_arm64_ios.c in this folder. NOT compiled: ntdll unix needs a configured Wine build (config.h) that the laptop does not have. The decode condition was compiled and run on its own with gcc.

## Review: PASS
- Decode (run on 11 encodings): STP D8,D9,[SP,#64] (0x6d0427e8) -> D, offset +64, Rt 8, Rt2 9, Rn SP. Q pairs 0xad3f8520 (offset -16) and 0xac814570 (post +32) unchanged. Not matched: LDP D (L=1), GPR STP, opc 11, single STR S/Q.
- All four modes keep working: offset scales by 4/8/16; writeback for post/pre uses the scaled offset; SP/LR/FP bases handled as before.
- Stores 2x size bytes from the low bytes of each V register; buffer is 32 bytes, enough for Q.
- Off switch MADEIRA_STP_SD_EMUL = 0: the Q path is checked first and never calls the switch, so Q behaviour is unchanged on or off; with it off, S/D pairs are not emulated, as in 0.2.180.

## Notes
- The `[stp-sd] rev=stp-sd-1 on` line is printed only when the first S/D pair store faults, not at start; README's test expects it, but it will not appear on runs without such a fault.
- The sigbus-diag line still says "q-pair" for S/D stores (log text only).
- getenv is called inside the fault handler on first use (the file already does this elsewhere).
- Not device-tested.
