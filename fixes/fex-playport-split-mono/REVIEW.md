# REVIEW: fex-playport-split-mono (FEX fixes ported from Playport)

- Source: github.com/playportdev/playport patches/fex 0034, 0036, 0096 (repo GPL-3.0-or-later; new files carry MIT
  headers). Credit: the Playport authors. Not BCD.
- Base: our FEX tree in source/madeira-0.2.180/Madeira/FEX. Patches 0001-0003 applied EXACT (no fuzz) to it; 0004 is ours.
- 0001 (their 0034): StrictInProcessSplitLocks defaults true on an iOS host build. Their probe lost 2-8 of 4000 `lock xadd` without it.
  Off: FEX_STRICTINPROCESSSPLITLOCKS=0.
- 0002 (their 0036): inline address check on every 16/32/64-bit CASAL and LSE atomic; a split one calls a dispatcher stub instead of
  taking an alignment fault (35-55 us each per their numbers). Off: env.MADEIRA_FEX_SPLIT_ATOMIC = 0 (emits the plain atomic). Note: it
  changes generated code, so a disk cache built under the other setting may hold the other form; clear the FEX cache when A/B testing.
- 0003 (their 0096): on iOS the multiblock decoder stops past a CALL in writable executable ranges (JIT code), not only when Mono is
  detected. Fixes Mono's unpatched `call 0` placeholder getting translated (their Borderlands 2 launcher crash). Off:
  env.MADEIRA_FEX_DECODE_PAST_CALL = 1. Relevant to our Mono/Unity games (Raft, Rain World, R.E.P.O.), UNPROVEN.
- 0004: the two off switches above (our code, not Playport's).
- Checked in the cloud: apply in order to our FEX tree; no compile.
- NOT checked: compile, device run, speed (0002 adds ~3 instructions per atomic), any effect on our failing games.
- Left out: their 0003 (SMC detection off once Mono backpatcher is found). Our tree already has the same idea for 32-bit windows
  (ml1280) and deliberately skips it for 64-bit ARM64EC on iOS (ml648: guest VA can't be made writable). Their version depends on
  their madeira-unix 0019/0027 (JIT pool RW view). A Wine-side piece could be cherry-picked onto our base per Cameron's Nov 28
  rule, but it needs a device test; not done.
- Needs: laptop compile + review (build thread queues it), then a device run on a Mono game.
