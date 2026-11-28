# repo-backbuffer-probe-v2 (diagnostic fix, against 0.2.180 dxmt 59c7086 d3d11_swapchain.cpp)

Why: 0.2.180 iPad R.E.P.O. run with env.MADEIRA_PRESENT_PROBE = 1 logged only "[present-probe] on: ..." and "[present-probe] Map failed", then "[game-end] R.E.P.O.: it closed by itself; Windows error 0xC0000005". (Reported by the sweep thread, logs claudepot\logs\sweep-0.2.180\retest-G.)
Cause of "Map failed" (code reading): the probe builds a D3D11_USAGE_STAGING desc but creates it with dxmt::CreateDeviceTexture2D. MTLD3D11Device::CreateTexture2D1 (d3d11_device.cpp ~1039) sends STAGING to CreateStagingTexture2D. The immediate context's Map (d3d11_context_imm.cpp ~147) only maps dynamic or staging resources, so a device texture can't be mapped READ.
Whether the probe also caused the 0xC0000005: unproven (R.E.P.O. ran 3 min without closing in earlier runs without the probe).
Change: one call, CreateDeviceTexture2D -> CreateStagingTexture2D (same signature, declared next to it in d3d11_resource.hpp:512). Nothing else.
Off switch: unchanged; probe runs only with env.MADEIRA_PRESENT_PROBE = 1.
Not compiled. Needs the laptop compile check + review (Review: PASS/FAIL).
