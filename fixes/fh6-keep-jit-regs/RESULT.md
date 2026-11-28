# RESULT: fh6-keep-jit-regs

Checked on the Linux laptop against 0.2.180-og.

## Compile
Applies with `patch -p1`, alone and after bo3-stp-sd-emul and oversize-reserve-min-mb (offset 36 lines, no shared hunks). Not compiled. ios_is_arm64ec_cur and is_ec_code exist.

## Review: PASS WITH NOTES
- Off by default: every helper returns at once unless MADEIRA_EC_KEEP_JIT_REGS is exactly "1".
- Suspend path: registers are saved before wait_suspend and put back only if the context still has the same pc, x28 was non-zero and is now zero. A debugger or anti-cheat that sets a new context at the same pc with x28 = 0 on purpose would get the old values back.
- Frame path: x23/x24/x28 restored from the syscall frame only when x28 is zero and pc is EC code.
- Declarations after statements in usr1_handler (C99; fine unless the build uses -Werror=declaration-after-statement).
- That iOS hits this at all is unproven (README).
