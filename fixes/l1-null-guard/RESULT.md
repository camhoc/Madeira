# RESULT: l1-null-guard (rev 3)

**Review: PASS** (code reading only; NOT compiled)

Checked on the Linux laptop against 0.2.180-og.

## Run
l1-null-guard-3.patch applies with `patch -p1`. Syntax check not possible: FEXCore/Config/ConfigValues.inl is generated and missing.

## Reasons
- Does what README says. Both ExitFunction probes (1-way and 2-way) and the syscall-return probe now require host != 0. Registers: TMP1 is already 0 on the hit path, and TMP2 is overwritten with DispatcherLoopTop on a miss.
- The other probes (EC return, loop top, L2 lookup) already reject host 0; no L1 probe found elsewhere in the FEX sources.
- InvalidateCache writing {GuestCode ~0, HostCode 0} is safe against those probes. Insertion is a FIFO and does not look for empty ways.
- Off switch env.MADEIRA_FEX_L1_NULL_GUARD = 0: restores the old emitted code and the old clearing.

## Notes
- FindBlock returns 0 early for RIP 0 (matches an empty way). That the compiler then raises a clean guest fault for RIP 0 is not verified here.
- During a concurrent invalidation FindBlock can return 0 for a matching way and recompile; looks harmless.
- All games are affected (one extra branch per indirect exit hit).
- README says the log line is rev=l1-null-guard-1; the patch prints rev=l1-null-guard-3.
