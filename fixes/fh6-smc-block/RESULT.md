# RESULT: fh6-smc-block

Checked on the Linux laptop against 0.2.180-og.

## Compile
Applies with `patch -p1` in FEX/, alone and after fex-playport-split-mono and l1-null-guard (they touch neither Core.cpp nor ARM64EC/Module.cpp); halo-mcc-exit-ring and sigbus-diag are already in 0.2.180. Not compiled (no generated FEX headers).

## Review: PASS WITH NOTES
- Off by default: FEX_MadeiraSmcBlock is 0 unless MADEIRA_EC_SMC_BLOCK starts with '1' (it accepts "10" too). Off, the per-instruction check runs exactly as before.
- The chunk check copies the existing per-instruction pattern (same _ValidateCode, _PatchableGuestCRC, removal block), using the decoded bytes as before.
- Chunks follow the instructions from Block.Entry, so they assume the block's instructions are contiguous; undecodable ones (size 0) are skipped, as the per-instruction path does.
- Known weaker case (documented): code that rewrites a later instruction of the same block while running it is only caught on the next entry.
- With MADEIRA_EC_JIT_INVAL=0 the old per-instruction path checked undecodable instructions; the block path never does.
