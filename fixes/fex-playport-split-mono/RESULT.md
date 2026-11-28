# RESULT: fex-playport-split-mono

**Review: PASS WITH NOTES** (code reading only; NOT compiled)

Checked on the Linux laptop against 0.2.180-og.

## Run
0001-0004 apply in order, no failed hunks or fuzz. l1-null-guard-3 still applies on top (dry run, one hunk offset 1 line). Syntax check not possible (generated FEX headers missing).

## Fix before queueing
The patches carry 9 *.orig files (CMakeLists.txt.orig, Dispatcher.cpp.orig, Arm64.cpp.orig and others). Remove them; they make up most of 0002.

## Reasons for PASS
- FEX_IOS_HOST and FEX_IOS_HOST_BUILD are set by both FEX build scripts, so the new code is built.
- Split test ((addr & 15) + size > 16) is right, does not touch NZCV; the handler finds the atomic at lr+8; register save/restore offsets are in range; helper signatures match.
- The new JITPointers field is appended; found no native code reading the later frame fields by fixed offset.
- Off switches present: FEX_STRICTINPROCESSSPLITLOCKS=0, MADEIRA_FEX_SPLIT_ATOMIC=0, MADEIRA_FEX_DECODE_PAST_CALL=1.

## Risks not verified
- A split atomic on a bad or write-protected address now faults inside FEX C++ code, not at a JIT address; guest exception delivery or SMC handling there is untested.
- A thread suspended inside the helper has guest registers on the stack.
- If a helper returns "unhandled", the atomic is skipped and execution continues (only logged).
- All games: split locks now serialised by one lock; on iOS no writable code is decoded past a CALL (may cost speed in .NET/Java/Mono).
- JITClass.h calls getenv without including <cstdlib> itself.
