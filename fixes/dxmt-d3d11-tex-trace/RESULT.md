# RESULT: dxmt-d3d11-tex-trace

**PASS**

Checked 2026-11-27 on the Linux laptop against 0.2.180-og.

## What was run
d3d11_device.cpp, d3d11_context_imm.cpp and d3d11_context_def.cpp pass a syntax check (arm64ec clang++, -std=c++20) before and after. Not a full DXMT build.

## Findings
- Log only, off unless DXMT_D11_TEX_TRACE is set to something not starting with 0; capped at 400 lines each.
