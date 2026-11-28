# RESULT: ubisoft-farcry (head 8289bf8)

Checked on the Linux laptop against 0.2.180-og.

## Compile
INCOMPLETE: apply.sh reads its patches from fixes/upstream-615-ubisoft-split/, which is NOT on this branch. Only the three wine/*.patch files are here, so the series (0001-0019, including the pool patches 0002/0004/0012 and pad 0005) could not be applied or reviewed. apply.sh and hand-merge.py were read, not run.
The three Wine patches each apply cleanly to 0.2.180's wine/ (git apply --check). Not compiled.

## Review: FAIL (incomplete), Wine part PASS WITH NOTES
- Push fixes/upstream-615-ubisoft-split/ (or put the patches in this folder) and re-queue; then CARVE_MERGE vs pool-low / POOL_CODE_KEEP_BIG and "0004 off in the Cyberpunk list" can be checked.
- apply.sh: no network use. It renames build/fex-patches/0002-... to 0028 (git mv) and edits README with sed; hand-merge.py asserts its anchors. Fine on a scratch copy.
- 0001 SLEEP_KERNEL_APC: off unless exactly "1". getenv on every non-alertable sleep (a hot path), and when on, every sleep becomes a server call instead of a host select(): slower.
- 0002 WOA_RECHECK: the 32-bit ntdll now always waits infinite waits in -10000001 slices; the unix side turns a slice back into an infinite wait when the switch is off. Side effect even when off: any caller (any process) whose timeout is exactly -10000001 (1.0000001 s) gets an infinite wait. Rare, but a unique marker would be safer.
- 0003 dxdiagn: a missing DirectShow enumerator now leaves the section empty instead of failing; logs ERR. Fine.
