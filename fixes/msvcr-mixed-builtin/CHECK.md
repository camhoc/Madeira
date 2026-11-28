# CHECK: msvcr-mixed-builtin
- NOT in any build; Wine loader.c patch (ARM64EC build only), patch -p3 against the 0.2.180 wine tree (release 0.2.180-og source). Read README.md and REVIEW.md. Off switch env.MADEIRA_NATIVE_MSVCR = 1. Ships with BO3 + OW2 as usual: touches the loader, so say whether any other game's msvcr loading could change (any msvcr71..120 served from system32).
- No Wine toolchain on the laptop: apply, review carefully, syntax-check what you can. Second review: "Review:" in RESULT.md with PASS or FAIL and reasons.
- Report: RESULT.md in this folder on this branch. Do not merge or push to main.
