# tf-syscall-l1 (OW2 + BO3 anti-tamper single-step, Nov 28 2026, OW2 Opus thread)

rev `tf-syscall-l1-1`. FEX only (Dispatcher.cpp post-syscall L1 probe + switch in Arm64Emitter.h/.cpp).
**Apply AFTER l1-null-guard-3** (stacked; same files). Checked: applies cleanly on 0.2.180 copies with
l1-null-guard-3 applied first. Not compiled. Not device-tested. Second review: laptop (fix branch).

**Credit / license:** port of upstream FEX-Emu main 26d8ec55fc "Dispatcher: honour TF on the L1 fast
path after SYSCALL and CPUID" (k33bs, Nov 9 2026, MIT). Lead from the fork deep-scan thread.

**Off switch:** `env.MADEIRA_FEX_TF_SYSCALL_L1 = 0`. Log: `[tf-syscall-l1] rev=tf-syscall-l1-1 on`.

## What it fixes
After a syscall the dispatcher's L1 fast path jumps straight into the cached block for the return RIP.
That block was compiled without the per-instruction single-step trap, so with TF set (a single-stepped
SYSCALL) the trap lands instructions late. The fix checks TF first and takes the loop top, which
already checks TF and compiles single-step blocks. Our loop-top and EnterEC probes already check TF;
only this post-syscall probe did not (checked in 0.2.180 Dispatcher.cpp ~859). Our tree has no
separate CPUID-stub L1 path, so upstream's CPUID half has nothing to patch here.

## Evidence for us
UNPROVEN. Overwatch's loader single-steps (int3 / trap-flag stepping seen in Nov 22 logs), and
anti-tamper timing/step checks are exactly what a late trap breaks, but no OW2 log line shows a
late trap after a syscall.
