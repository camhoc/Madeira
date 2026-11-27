# RESULT: library-scroll-shadow

**CONCERNS / NEEDS-MAC, NEEDS-DEVICE**

Checked 2026-11-27 on Linux against the 0.2.180-og source zip.

## What was run
Patch applies to the 0.2.180-og tree (git apply). Swift NOT typechecked or compiled (no Xcode here).

## Findings
- `=0` restores the old look exactly.
- With it on, a `.shadow` with opacity 0 and radius 0 remains and may still render off-screen; better to omit the modifier.
- Covers without art will look darker (see-through fill over a new black shape), so "same look" is not true there.
- Performance gain is unproven.
