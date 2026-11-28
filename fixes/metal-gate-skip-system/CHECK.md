# CHECK: metal-gate-skip-system
- NOT in any build; patch against the 0.2.180 source tree (release 0.2.180-og), patch -p1 from the Madeira dir. Read README.md and REVIEW.md. Fixes Sentry 31W (0x8BADF00D on leaving Madeira) for 1 of 4 events: MetalBackgroundGate holds SwiftUI's RenderBox render thread in mbg_wait. Off switch env.MADEIRA_METAL_GATE_SKIP_SYSTEM = 0 (default on); needs a ConfigCatalog entry.
- Apply, typecheck/compile what the laptop can (iOS SDK), second review: "Review:" in RESULT.md with PASS or FAIL and reasons. Check carefully: this is native code on the quit path, so a wrong skip could let a Metal commit through while backgrounded.
- Report: RESULT.md in this folder on this branch. Do not merge or push to main.
