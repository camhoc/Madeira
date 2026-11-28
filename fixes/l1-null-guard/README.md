# l1-null-guard (Overwatch 2, Nov 28 2026, OW2 Opus thread)

rev `l1-null-guard-3` (patch `l1-null-guard-3.patch`; -1 and -2 superseded). FEX only (FEXCore JIT, dispatcher, LookupCache). Base: 0.2.180 source
(`source/madeira-0.2.180/Madeira`, FEX a43e0b919). `git apply --check -p1` passes there.
Not compiled (no ARM64EC toolchain in the cloud container). Not device-tested.

**Credit / license:** idea and shape ported from MetalSharp-Wine FEX patch
`0050-FEXCore-Don-t-take-an-empty-lookup-entry-as-a-hit-fo.patch` (Avery Felts,
https://github.com/aaf2tbz, MetalSharp-Wine PR #147, commit 913b2c9, Nov 27 2026).
FEX and its fork are MIT (MetalSharp docs/LICENSES.md). Not BCD. Not AGPL.

**Off switch:** `env.MADEIRA_FEX_L1_NULL_GUARD = 0` (read once when code is emitted).
Log line at first emit: `[l1-null-guard] rev=l1-null-guard-1 on`.

## What it fixes

An empty L1 lookup entry is `{host 0, guest 0}`. A guest jump/call/ret to RIP 0
(a call through a null pointer) "hits" it, and FEX branches natively to host
address 0. The fault then carries FEX's registers and stack, not the guest's,
so a game handler meant to recover from the null call can't.

MetalSharp (same stack: Wine 11.22 + FEX ARM64EC) lists this as one of the two
fixes behind "Overwatch starts" (#147): "Overwatch's protection, at startup".

## Our code (checked in 0.2.180 source)

- `Dispatcher.cpp` loop-top probe and the EnterEC RET probe ALREADY skip a
  zero host entry (`cbz TMP4`). Not touched.
- `BranchOps.cpp` ExitFunction inline L1 probe (both the 1-way and the iOS
  2-way loop) had only `sub; cbz TMP1 -> hit`. Now also requires host != 0.
- `Dispatcher.cpp` post-syscall L1 probe had only `cbnz TMP1`. Now also
  `cbz TMP2 -> miss`.
- The call-ret shortcut is already disabled on iOS (ml305), so MetalSharp's
  call-ret part is not needed here.

A miss goes to the normal full lookup, which compiles RIP 0, and the decode
fault is raised with the guest's own state (same path as NOACCESS code).
cbz/cbnz don't touch NZCV, so guest flags are preserved, as before.

## Evidence for OUR Overwatch (honest)

UNPROVEN for us. I searched the 0.2.90-0.2.95 OW2 logs for a host fault at
pc 0 (`SEGV at pc=0x0`, `Address: 0 AV`) and found none. The last OW2 log is
0.2.97 (Nov 24; iOS closed the app at 41 s). This is a real bug in our code by
reading, cheap, and matches a twin project's Overwatch fix.

## Checked against the rest of MetalSharp's Nov 27 Overwatch set

- 0049 (don't report FEX's own icache flush; deadlock): ours already has
  `IosFlushUnderOwnLock()` in `BTCpu64FlushInstructionCache` (pending-prs/fex-flush-own-lock). Not ported.
- 0051 / Wine 0217 (keep PF across exception handlers): ours has pfaf-keep-2 +
  pfaf-int3-2 (PF/AF via a per-thread stash, CPSR bits 26/27). Not ported.
- Wine 0216 (relocated image header ImageBase): on iOS, virtual_ios.c already
  forces map_addr to the real view and writes ImageBase. Remaining gap only for
  a non-dynamic-base DLL relocated on the PE side; MetalSharp's case was Steam's
  tier0_s64.dll, which Battle.net Overwatch does not load (unchecked on device). Not ported.
- 0052 (thread-map lock): our invalidation paths still take ThreadCreationMutex. Not needed.
- 0046-0048: JIT speed only (skip for now, his "running first" rule).

## Test

Golden: one OW2 run (Battle.net config unchanged) + one normal golden game
(e.g. Stardew or Undertale) to see nothing regressed. Look for the rev line.

## Review history

- -1: second review OK TO BUILD (REVIEW.md). SHOULD 1: InvalidateCache left {old host, guest 0}, so RIP 0 (in FindBlock too) could run stale code.
- -2: L1 clear writes guest ~0. Re-review OK TO BUILD. SHOULD: RIP ~0 could still hit it.
- -3: with the guard on, the L1 clear writes {host 0, guest ~0}; every L1 reader rejects host 0. Off switch gives the original clear. Applied as the reviewer suggested; apply-check passes on 0.2.180.
