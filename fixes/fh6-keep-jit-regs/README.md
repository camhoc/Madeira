# fh6-keep-jit-regs (Nov 28 2026, Discord-games thread)

Patch `fh6-keep-jit-regs.patch` against `source/madeira-0.2.180/Madeira/build/ntdll-unix/signal_arm64_ios.c` (`patch -p1` from the Madeira dir applies clean). **Not compiled** (needs the Wine/iOS headers; no toolchain in the cloud container), **not device-tested**.

**Switch:** `env.MADEIRA_EC_KEEP_JIT_REGS = 1` turns it ON. Default OFF: every new helper returns at once and nothing changes. Log (first 8 uses, stderr): `[keep-jit-regs] suspend|frame: restored ...  rev=keep-jit-regs-1`.

**What (from the fork's commit message):** an ARM64EC CONTEXT has no slots for x13, x14, x23, x24, x28 (x64 has no such registers), so converting a context to or from the ARM64EC form zeroes them, but FEX's JIT keeps live values there (x28 = the state pointer). When a thread is suspended (SIGUSR1 path, both branches) or `signal_set_full_context` resumes into JIT code, the thread comes back with x28 = 0 and dies. The patch saves the five registers before `wait_suspend`, puts them back afterwards, and for the set-context path copies x23/x24/x28 from the syscall frame. Both only fire when the context still names the same instruction (pc check), x28 is zero and a saved x28 exists.
**Our differences:** our `signal_set_full_context` has no `suspend_pending` block, so only the syscall-frame helper goes there; the suspend save/restore sits in `usr1_handler`'s two branches. Logging uses `dprintf(2, ...)` (signal context), not `ERR`. `is_arm64ec()` replaced by `ios_is_arm64ec_cur()` (already used in this file). The thread-start `wait_suspend` (line ~17376) is not touched.

**UNPROVEN that we hit this on iOS.** Nothing in our logs names it; the fork saw it on Android/Wine 11.x with FH6. Enable it only to test FH6 or a game that suspends threads (anti-cheat, .NET GC).

**Credit / license:** from TimmyTurner51/fh6-wine-fex `wine/arm64ec-frame-regs.patch` (applies to his proton-wine fork, Wine = LGPL-2.1). Permission to use the code was given by the author on Discord, per Cameron (Nov 28). He plans to open his own PR later; this stays close to his code so it can be replaced by or merged with it. Not BCD, not AGPL.

**Overlap checked:** `getctx-guest` (cross-thread GetThreadContext, different function), `ctx-x64-fields` (signal_arm64ec.c exception contexts), `df-ctx`, `ki-legacy-frame`: none touch usr1_handler or signal_set_full_context's entry. Re-check apply after they land (getctx-guest also edits signal_arm64_ios.c).
