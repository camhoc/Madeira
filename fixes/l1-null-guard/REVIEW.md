VERDICT: OK TO BUILD

Second review of l1-null-guard-1 (cold, Nov 28 2026). Patch applies cleanly (`patch -p1 --dry-run` on copies of the 4 files from 0.2.180). Not compiled.
Line numbers below are in the PATCHED files unless marked "base".

What I verified as correct:
- LookupCacheEntry is {HostCode @0, GuestCode @8} (LookupCache.h:188). Every changed probe does `ldp TMP2, TMP1, [..]`, so TMP2 = host, TMP1 = guest; `sub TMP1, TMP1, rip` then tests TMP1 (guest match) and TMP2 (host != 0). Roles are right in all three sites.
- BranchOps.cpp:380-388 (L1_WAYS==1) and :401-410 (iOS 2-way loop): `cbnz TMP1 -> L1NullMiss; cbnz TMP2 -> SkipFullLookup; bind L1NullMiss`. The ForwardLabel is declared per iteration inside the `if` scope and bound exactly once in the same scope, with one user. A guest mismatch or a zero host falls through to the next way, then to `ldr TMP2, DispatcherLoopTop; str rip` (the full-lookup path). TMP2 from a missed way is reloaded by the next ldp or overwritten by that ldr. A hit reaches SkipFullLookup with TMP2 = host, as before.
- Dispatcher.cpp:876-882 (post-syscall): extra `cbz TMP2` to LoopTop (last way) / NextWay (other ways). LoopTop is a BiDirectionalLabel already bound at base :258; cbz on it is used already at base :226. State.rip is already in memory on this path, so LoopTop re-reads it. Correct.
- NZCV: only cbz/cbnz and a flagless sub are added. Flags are preserved.
- Declaration: Arm64Emitter.h:40, inside `namespace FEXCore::CPU`, outside the `#ifndef ARCHITECTURE_arm64ec` block, so it is visible in ARM64EC, WOW64 and Linux builds. Definition: Arm64Emitter.cpp:44, inside the same namespace, not under any #ifdef. `<cstdlib>` is added and LogManager.h is already included. Dispatcher.h:4 and JITClass.h:10 include Arm64Emitter.h, and both callers are in FEXCore::CPU. The static-lambda pattern matches ALUOps.cpp:20.
- Off switch: with `MADEIRA_FEX_L1_NULL_GUARD=0` the else branches emit the base instructions exactly (one cbz in BranchOps, no extra cbz in Dispatcher). Byte-for-byte the original. The only leftover is the one log line.
- No legitimate entry has HostCode 0: the code buffer is never mapped at address 0. The C++ FindBlock returns 0 on such an L1 match, which the callers treat as "not found", and the compile path handles a low RIP (Core.cpp base ~2020, [low-rip-fault]). Guarding host==0 cannot reject a real block.
- The other probes are already guarded: the loop-top L1 (Dispatcher.cpp base :339-340), the EnterEC RET probe (base :225-229) and the L2 (base :391). The ARM64EC frontend (Module.S / Module.cpp) has no L1 probe of its own.

Findings:

1. SHOULD - LookupCache.h:409 (base; not touched by the patch). InvalidateCache clears an L1 way by setting only `GuestCode = 0` and deliberately leaves the old HostCode (see the comment there). So an invalidated way is {stale_host != 0, 0}. A guest jump/call/ret to RIP 0 that lands in set 0 still "hits" it, in every probe (the ExitFunction inline probe, post-syscall, the loop top and the C++ FindBlock at LookupCache.h:239-242). The patch's `host != 0` test does not catch it. The result is worse than before the patch's case: no fault at all, but invalidated code for an unrelated RIP runs with the guest's state. Set 0 holds RIPs whose low set-index bits are zero, which is common for aligned function and section starts. Code invalidation is heavy during anti-tamper unpacking, which is exactly the Overwatch startup case. The patch is still correct and safe for the {0,0} case, but it may not fix OW2 alone. Suggested follow-up (separate rev): give invalidated ways a sentinel GuestCode that no guest can execute (e.g. `~0ULL`) instead of 0, at :409, and in any other place that writes a non-zero host with guest 0. Then {0,0} is only the never-filled state, which this patch handles. Check that nothing else treats GuestCode==0 as "empty" (InsertL1 at :519-527 does not).

2. NIT - BranchOps.cpp base :362 and Dispatcher.cpp base :241-249 (non-iOS only). The upstream call-ret shortcut is still unguarded. `stp zr, zr` (BranchOps base :437) pushes {0,0} entries, and a RET to guest 0 would `ret` to host 0. MetalSharp's 0050 guards this. On iOS both paths are compiled out (`(void)SkipFullLookup` / IosEcReturnWithRet branch), so this does not matter for Madeira's shipping build. It matters only if the patch is meant for upstream or non-iOS builds. The README says this correctly.

3. NIT - Arm64Emitter.h:40 / .cpp:44. The name says `Ios...`, but the guard is unconditional and also active on Linux and non-iOS builds. That is harmless (semantically safe everywhere), but the name is misleading. Either drop the `Ios` prefix or wrap the call sites in FEX_IOS_HOST, whichever matches local convention.

4. NIT - LookupCache.h:239-242 (base). FindBlock returns on the first guest match, even when its HostCode is 0, without trying the other way or L2/L3. For RIP 0 with an empty way this means a recompile request instead of finding an existing RIP-0 block. CompileBlock should dedupe it, so the cost is performance only on a rare path. No action needed for this rev.

5. NIT - Arm64Emitter.cpp:49. The log is at E (error) level, like the other MADEIRA rev lines. Fine, just noting that it prints even when the guard is off (by design, it says "off").

---

## Re-review (l1-null-guard-2)

VERDICT: OK TO BUILD

Scope: the new LookupCache.h hunk, the ~0 sentinel, and whether -2 equals -1 apart from that hunk. Patch applies cleanly to copies of the 5 files from 0.2.180. Not compiled.

- Same as -1: `diff l1-null-guard-1.patch.superseded l1-null-guard-2.patch` shows only the two rev strings (Arm64Emitter.cpp log line, Arm64Emitter.h comment) and the new LookupCache.h hunk. The emitter, dispatcher and BranchOps hunks are byte-identical.
- Compiles (by reading): LookupCache.h:23-26 forward-declares `bool FEXCore::CPU::IosL1NullGuardEnabled();` with the same signature and namespace as Arm64Emitter.h:40 and Arm64Emitter.cpp:44. Redeclaring it is legal. It is a plain declaration with no new include, so there is no include cycle. The `CPU::` at LookupCache.h:417 is inside `namespace FEXCore`, so it resolves to FEXCore::CPU, the same way `CPU::CodeBuffer` already does at :236. `~uintptr_t {0}` is well-formed. Every TU that includes LookupCache.h is in FEXCore/Source, and FEXCore/Source/CMakeLists.txt:37 builds Arm64Emitter.cpp unconditionally, so the symbol links in every config. Calling it from InvalidateCache, maybe before the first emit and from another thread under the write lock, is fine: static init is thread-safe, and only the time of the log line changes.
- Nothing treats GuestCode 0 as "empty". The only GuestCode readers are the probes (BranchOps, Dispatcher loop top, EnterEC, post-syscall, L2) and FindBlock (:240), and all of them compare against the RIP. InsertL1 (:519-527) overwrites unconditionally. Shrinking the dynamic L1 (:341-349) decommits the tail (pages come back as zero, {0,0}, which the guard handles). ClearThreadLocalCaches and the clears in LookupCache.cpp (:181, :221) VirtualDontNeed the whole region ({0,0}). The ARM64EC and WOW64 frontends (Source/Windows) never touch GuestCode or L1. The coordinator's FindBlock point is right: :240 now no longer returns a stale HostCode for Address 0.
- On ~0 vs a real RIP: in a WOW64 (32-bit) guest RIP is at most 0xFFFFFFFF, so no collision is possible. In an x64 guest FEX does not check that RIP is canonical, so `jmp/call reg` with reg = -1 (for example an INVALID_HANDLE_VALUE-style sentinel called as a function pointer) would set RIP = ~0. That matches a cleared way in the last L1 set and runs stale host code, the same bug class as before, just at -1 instead of 0. This is far rarer than a null call and not a blocker.

R1. SHOULD - LookupCache.h:417. Close the -1 case as well: with the guard on, also set `L1Set[Way].HostCode = 0` (before writing GuestCode = ~0). The upstream reason for keeping HostCode ("concurrent lookups won't read a null pointer") no longer holds while the guard is on, because every L1 reader now rejects host 0:
- ExitFunction: guard on.
- post-syscall: guard on.
- loop top: cbz TMP4, base Dispatcher.cpp:340.
- EnterEC RET: base :226/229.
- FindBlock: returns 0, which is a miss in Core.cpp:1552/2922/2932 and JIT.cpp:610.

A torn read by a concurrent reader then gives either (old guest, 0), which is rejected, or (~0, old host), which needs RIP == ~0 and a race at the same moment. Keep the guard-off branch as it is.

## Applied after re-review (l1-null-guard-3)
Re-review SHOULD applied as suggested: guard on => InvalidateCache L1 clear writes GuestCode=~0 and HostCode=0. Nothing else changed. git apply --check passes on 0.2.180.
