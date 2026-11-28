# CHECK: l1-null-guard
- NOT in any build yet; ships with BO3 (OW2 work). Use l1-null-guard-3.patch only (patch -p1 at the Madeira root, 0.2.180 tree, release 0.2.180-og). FEX only: BranchOps.cpp, Dispatcher.cpp, LookupCache.h, Arm64Emitter.h/.cpp.
- The ARM64EC toolchain is not on the laptop: review the patch carefully and syntax-check what you can. Second review: "Review:" heading in RESULT.md with PASS or FAIL and reasons. Off switch env.MADEIRA_FEX_L1_NULL_GUARD = 0, rev line "[l1-null-guard] rev=l1-null-guard-3 on".
- MIT port of MetalSharp-Wine FEX 0050 (credit Avery Felts).
- Report: RESULT.md in this folder on this branch. Do not merge or push to main.
