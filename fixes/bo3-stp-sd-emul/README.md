# bo3-stp-sd-emul (rev=stp-sd-1)
File: Madeira/build/ntdll-unix/signal_arm64_ios.c (full file here, patch vs 0.2.180 = bo3-stp-sd-emul.patch). ntdll unix only.
Off switch: env.MADEIRA_STP_SD_EMUL = 0 (default on). Log line once: `[stp-sd] rev=stp-sd-1 on ...`.

## Problem (0.2.180 iPad sweep log, blackops3.exe-2026-11-26_21-46-58.txt)
BO3's own kill fires (`[crashmailer-exit-probe] exit: NtTerminateProcess, on thread 0128`), then:
`[store-undecoded] #1 rev=ml350 insn=0x6d0427e8 pc=0x166d0adbc addr=0x73f1f23f40 ... ADD THIS ENCODING to the case-4 emulator`
`[exc-stack] cannot deliver exception: 0x73f1f23aa0..0x73f1f23f00 not writable ... aborting thread instead of faulting forever`
0x6d0427e8 = STP D8, D9, [SP, #64] (ntdll exit path) onto the kill stub's RWX stack page, which ml638 keeps
PHYSICALLY RX (`[alias-prot] ml638 #3 0x73f1f24000+0x1000 ... PHYSICAL forced RX`). The ml629 alias store emulator
only decodes the Q (128-bit) SIMD pair. The store fails, the thread is aborted, the process never exits, and then
the main thread and a new thread deadlock (heap lock vs xtajit64.dll+0x651640). Result: a black window forever.
Earlier builds (0.2.100/0.2.101) exited cleanly with status 0.

## Change
The ml629 Q-pair branch now also takes S (opc 00) and D (opc 01) pair stores: same four modes, offset scaled by
the register size (4/8), stores 2x size bytes from the low bytes of Vt/Vt2. Loads (L=1), GPR pairs (V=0) and
opc 11 stay excluded. Decode checked on the host: 0x6d0427e8 -> D, offset +64, Rt=8 Rt2=9 Rn=SP;
Q forms 0xad3f8520 / 0xac814570 unchanged; 0x6d400000 (LDP D) and 0xa9000000 (GPR STP) not matched.

## What it does NOT do
It does not fix BO3's self-kill. It makes the kill end the process cleanly (exit 0, as on 0.2.101) instead
of hanging with a black window. The exit-time block-ring dump should then complete too (it was cut off by
this fault), which shows what decided the kill.
Not compiled with the iOS SDK (laptop compile + review).
Test: BO3 on iPad. Pass = `[stp-sd] rev=stp-sd-1 on`, no `[store-undecoded] insn=0x6d0427e8`,
`[child-end] blackops3.exe status=0x0`, and the `[crashmailer-exit-probe] blocks (exiting thread)` list printed.
