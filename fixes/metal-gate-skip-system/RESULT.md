# RESULT: metal-gate-skip-system

**Review: FAIL**

Checked on the Linux laptop against 0.2.180-og.

## Run
- Applies with `patch -p1`. MetalBackgroundGate.m passes an iOS-SDK syntax check; Swift typecheck has no new errors.

## Why FAIL
1. It breaks tests/host/check-background-run.py: "Metal gate: off the main thread a commit waits first, then the original runs" passes before the patch and FAILS after (the test expects the exact old line).
2. The same test's Swift stubs have no madeira_metal_gate_skip_system and no MadeiraConfig.flag, so its Swift part should fail to compile where it runs (inferred; that part already fails on this laptop without the patch).
3. dladdr runs on EVERY off-main-thread commit, even while Madeira is active (it is evaluated before mbg_wait checks mbg_inactive). That is a symbol lookup on the render hot path. Check the caller only when inactive.

## Wrong-skip question
The winemetal and WiniosGL commit calls are not tail calls, so the return address should be in Madeira's image. A commit that is the last statement of a block or function could be tail-called and appear to come from a system library; MoltenVK and Mesa binaries were not checked.

## Also
Off switch env.MADEIRA_METAL_GATE_SKIP_SYSTEM = 0 is correct. Needs the ConfigCatalog entry. Not run on a device.
