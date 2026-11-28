# REVIEW oversize-reserve-min-mb
Status: author's own check only (Sonnet thread, Nov 28). NEEDS an independent second review and a compile before a build.
- Patch applies with `git apply --check` to a clean copy of the 0.2.180 files.
- Compare the hand-merged `ios_oversize_min()` (keeps min-gb, adds min-mb override) with the fork's version (mb only, clamp 1024..65536).
- Read signal_arm64_ios.c hunks (arena band) for the iOS-only guard.
