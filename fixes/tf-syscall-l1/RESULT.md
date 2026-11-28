# RESULT: tf-syscall-l1 (stacked on l1-null-guard-3)

Checked on the Linux laptop against 0.2.180-og.

## Compile
The branch's l1-null-guard-3.patch is identical to fix/l1-null-guard's. Both apply in order (l1-null-guard-3, then tf-syscall-l1-1, patch -p1, no offsets). Not compiled (no generated FEX headers).

## Review: PASS
- Same TF test the JIT already uses (ldrb State.flags[RFLAG_TF_RAW_LOC], JIT.cpp:859 and BranchOps.cpp:279); TMP1 is free there (the L1 probe reloads it next); LoopTop is the label the probe already uses on a miss.
- With TF set, the post-syscall path now always goes through the loop top, which handles single-step; with TF clear only one load and branch are added.
- Off switch MADEIRA_FEX_TF_SYSCALL_L1 = 0 skips the emitted check (read once, at dispatcher emit time). Default on, for every game.
- That OW2/BO3 hit this is unproven (README). Needs a ConfigCatalog entry (yours).
