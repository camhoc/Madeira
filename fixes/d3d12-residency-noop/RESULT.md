# RESULT: d3d12-residency-noop

**PASS**

Checked 2026-11-27 on the Linux laptop against 0.2.180-og.

## What was run
madeira_d3d12.c compiled with arm64ec-w64-mingw32-clang -O2 -Wall: 0 errors, 3 warnings, same count as unpatched. Compile of this one file only; DLL not linked, not run.

## Findings
- S_OK matches the neighbouring unified-memory stubs; residency-noop = 0 restores E_NOTIMPL.
- On by default. That it fixes RE4's dialog is unproven.
