# RESULT: repo-backbuffer-probe-v2

Checked on the Linux laptop against 0.2.180-og.

## Compile
Applies with `patch -p1` from the tree root. d3d11_swapchain.cpp passes a syntax check with arm64ec-w64-mingw32-clang++ (-std=c++20, DXMT include dirs), with and without dxmt-d3d11-tex-trace applied. Not a full DXMT build.

## Review: PASS
- CreateStagingTexture2D has exactly CreateDeviceTexture2D's signature (d3d11_resource.hpp:512 vs 528), and it is what MTLD3D11Device::CreateTexture2D1 calls for D3D11_USAGE_STAGING (d3d11_device.cpp:1040). The desc is STAGING with CPU_ACCESS_READ and no bind flags, so the texture is mappable for reading, which v1 was not.
- Diagnostic only: MadeiraPresentProbe runs only when MADEIRA_PRESENT_PROBE is exactly "1", and only at presents #30, #300 and #900.
- No overlap with dxmt-d3d11-tex-trace: that one edits d3d11_device.cpp and d3d11_context_impl.cpp, this one d3d11_swapchain.cpp only.
