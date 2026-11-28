# CHECK: fex-playport-split-mono
- NOT in any build; 4 patches against our FEX tree (0.2.180 source, release 0.2.180-og). Read README.md and REVIEW.md. Off switches: FEX_STRICTINPROCESSSPLITLOCKS=0, env.MADEIRA_FEX_SPLIT_ATOMIC = 0, env.MADEIRA_FEX_DECODE_PAST_CALL = 1.
- No ARM64EC toolchain on the laptop: apply in order, review carefully, syntax-check what you can. Second review: "Review:" heading in RESULT.md with PASS or FAIL and reasons. Check it does not conflict with l1-null-guard (both touch FEX).
- Report: RESULT.md in this folder on this branch. Do not merge or push to main.
