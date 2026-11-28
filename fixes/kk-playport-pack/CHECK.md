# CHECK: kk-playport-pack
- NOT in any build; second review and a compile check come first.
- 18 KosmicKrisp patches ported from Playport, in patches/ (apply in order 0001-0018) onto Mesa 26.3.1 plus our 9 build/mesa-ios/patches/kosmickrisp-ios-*.patch (those are in the 0.2.180 source zip, release 0.2.180-og).
- Read REVIEW.md first. Eight patches applied with fuzz (0002, 0008, 0010, 0011, 0012, 0013, 0015, 0018 by our numbering): for each, look at where the hunks landed and say whether the placement is right (fuzz 3 ignores context lines).
- Compile: the Metal parts need macOS, so on Linux do what you can: apply the series, then at least syntax-check the touched C files where the headers are available, or say plainly what could not be compiled. Check specifically 0015 (util_format_name use) and 0010/0011.
- Report: write RESULT.md in this folder on this branch (per patch: applies / hunk placement OK or odd / compile result). Do not merge or push to main.
