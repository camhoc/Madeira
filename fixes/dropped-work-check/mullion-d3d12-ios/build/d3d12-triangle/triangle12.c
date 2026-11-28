/* triangle12.c: Madeira's Direct3D 12 proof for the d3d12 = mullion lane (build/d3d12-triangle).
 * Plain C, x86_64 Windows (runs under FEX like a game). One coloured triangle, 600 frames, then exit 0.
 * Every step prints a "[d3d12-triangle]" line to stderr (the session log), so a log shows how far it got:
 *   adapter <name> / feature level / MeshShaderTier <n> / frame 1,60,...,600 / done.
 * Shaders are SM 5.0 DXBC made at build time (as build/d3d11-triangle), so no DXC is needed. */
#define COBJMACROS
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <initguid.h> /* define the IIDs here (no dxguid needed) */
#include <d3d12.h>
#include <dxgi1_4.h>
#include <stdio.h>
#include "vs_dxbc.h"
#include "ps_dxbc.h"

#define FRAMES 2
/* spelled out so older and newer mingw headers both build this */
#define FL_12_2 ((D3D_FEATURE_LEVEL)0xc200)
#define FEATURE_OPTIONS7 ((D3D12_FEATURE)32)
struct options7 { int MeshShaderTier; int SamplerFeedbackTier; };
#define LOG(...) do { fprintf(stderr, "[d3d12-triangle] " __VA_ARGS__); fputc('\n', stderr); fflush(stderr); } while (0)
#define CHECK(hr, what) do { HRESULT h_ = (hr); if (FAILED(h_)) { LOG("FAILED %s: hr=0x%08lx", what, (unsigned long)h_); return 1; } } while (0)

static LRESULT CALLBACK wndproc(HWND w, UINT m, WPARAM a, LPARAM b) {
    if (m == WM_DESTROY) { PostQuitMessage(0); return 0; }
    return DefWindowProcA(w, m, a, b);
}

int main(void) {
    const UINT width = 1280, height = 720;
    WNDCLASSA wc = {0};
    wc.lpfnWndProc = wndproc; wc.hInstance = GetModuleHandleA(NULL); wc.lpszClassName = "d3d12tri";
    RegisterClassA(&wc);
    RECT r = {0, 0, (LONG)width, (LONG)height};
    AdjustWindowRect(&r, WS_OVERLAPPEDWINDOW, FALSE);
    HWND hwnd = CreateWindowA("d3d12tri", "D3D12 triangle", WS_OVERLAPPEDWINDOW | WS_VISIBLE, 0, 0,
                              r.right - r.left, r.bottom - r.top, NULL, NULL, wc.hInstance, NULL);
    LOG("window %p", (void *)hwnd);

    IDXGIFactory4 *factory; ID3D12Device *device;
    CHECK(CreateDXGIFactory2(0, &IID_IDXGIFactory4, (void **)&factory), "CreateDXGIFactory2");
    IDXGIAdapter1 *adapter = NULL;
    if (SUCCEEDED(IDXGIFactory4_EnumAdapters1(factory, 0, &adapter))) {
        DXGI_ADAPTER_DESC1 ad; IDXGIAdapter1_GetDesc1(adapter, &ad);
        char name[128]; WideCharToMultiByte(CP_UTF8, 0, ad.Description, -1, name, sizeof name, NULL, NULL);
        LOG("adapter %s", name);
    }
    CHECK(D3D12CreateDevice((IUnknown *)adapter, D3D_FEATURE_LEVEL_11_0, &IID_ID3D12Device, (void **)&device),
          "D3D12CreateDevice");
    {
        D3D_FEATURE_LEVEL want[] = {FL_12_2, D3D_FEATURE_LEVEL_12_1, D3D_FEATURE_LEVEL_12_0,
                                    D3D_FEATURE_LEVEL_11_1, D3D_FEATURE_LEVEL_11_0};
        D3D12_FEATURE_DATA_FEATURE_LEVELS fl = {5, want, 0};
        struct options7 o7 = {0};
        if (SUCCEEDED(ID3D12Device_CheckFeatureSupport(device, D3D12_FEATURE_FEATURE_LEVELS, &fl, sizeof fl)))
            LOG("max feature level 0x%x", (unsigned)fl.MaxSupportedFeatureLevel);
        if (SUCCEEDED(ID3D12Device_CheckFeatureSupport(device, FEATURE_OPTIONS7, &o7, sizeof o7)))
            LOG("MeshShaderTier %d", (int)o7.MeshShaderTier);
        else
            LOG("MeshShaderTier: OPTIONS7 not answered");
    }

    D3D12_COMMAND_QUEUE_DESC qd = {D3D12_COMMAND_LIST_TYPE_DIRECT, 0, D3D12_COMMAND_QUEUE_FLAG_NONE, 0};
    ID3D12CommandQueue *queue;
    CHECK(ID3D12Device_CreateCommandQueue(device, &qd, &IID_ID3D12CommandQueue, (void **)&queue), "CreateCommandQueue");

    DXGI_SWAP_CHAIN_DESC1 sd = {0};
    sd.Width = width; sd.Height = height; sd.Format = DXGI_FORMAT_R8G8B8A8_UNORM; sd.SampleDesc.Count = 1;
    sd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT; sd.BufferCount = FRAMES; sd.SwapEffect = DXGI_SWAP_EFFECT_FLIP_DISCARD;
    IDXGISwapChain1 *sc1; IDXGISwapChain3 *sc;
    CHECK(IDXGIFactory4_CreateSwapChainForHwnd(factory, (IUnknown *)queue, hwnd, &sd, NULL, NULL, &sc1),
          "CreateSwapChainForHwnd");
    CHECK(IDXGISwapChain1_QueryInterface(sc1, &IID_IDXGISwapChain3, (void **)&sc), "IDXGISwapChain3");

    D3D12_DESCRIPTOR_HEAP_DESC hd = {D3D12_DESCRIPTOR_HEAP_TYPE_RTV, FRAMES, D3D12_DESCRIPTOR_HEAP_FLAG_NONE, 0};
    ID3D12DescriptorHeap *rtv_heap;
    CHECK(ID3D12Device_CreateDescriptorHeap(device, &hd, &IID_ID3D12DescriptorHeap, (void **)&rtv_heap), "RTV heap");
    UINT rtv_size = ID3D12Device_GetDescriptorHandleIncrementSize(device, D3D12_DESCRIPTOR_HEAP_TYPE_RTV);
    D3D12_CPU_DESCRIPTOR_HANDLE rtv0;
    rtv_heap->lpVtbl->GetCPUDescriptorHandleForHeapStart(rtv_heap, &rtv0); /* aggregate return: through the vtable */
    ID3D12Resource *targets[FRAMES];
    for (UINT i = 0; i < FRAMES; i++) {
        CHECK(IDXGISwapChain3_GetBuffer(sc, i, &IID_ID3D12Resource, (void **)&targets[i]), "GetBuffer");
        D3D12_CPU_DESCRIPTOR_HANDLE h = {rtv0.ptr + i * rtv_size};
        ID3D12Device_CreateRenderTargetView(device, targets[i], NULL, h);
    }

    ID3D12CommandAllocator *alloc;
    CHECK(ID3D12Device_CreateCommandAllocator(device, D3D12_COMMAND_LIST_TYPE_DIRECT, &IID_ID3D12CommandAllocator,
                                              (void **)&alloc), "CreateCommandAllocator");

    D3D12_ROOT_SIGNATURE_DESC rsd = {0, NULL, 0, NULL, D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT};
    ID3DBlob *rs_blob, *rs_err = NULL; ID3D12RootSignature *root;
    CHECK(D3D12SerializeRootSignature(&rsd, D3D_ROOT_SIGNATURE_VERSION_1, &rs_blob, &rs_err), "SerializeRootSignature");
    CHECK(ID3D12Device_CreateRootSignature(device, 0, ID3D10Blob_GetBufferPointer(rs_blob), ID3D10Blob_GetBufferSize(rs_blob),
                                           &IID_ID3D12RootSignature, (void **)&root), "CreateRootSignature");

    D3D12_INPUT_ELEMENT_DESC layout[] = {
        {"POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 0, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0},
        {"COLOR", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 12, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0},
    };
    D3D12_GRAPHICS_PIPELINE_STATE_DESC pd = {0};
    pd.pRootSignature = root;
    pd.VS.pShaderBytecode = vs_dxbc; pd.VS.BytecodeLength = vs_dxbc_len;
    pd.PS.pShaderBytecode = ps_dxbc; pd.PS.BytecodeLength = ps_dxbc_len;
    pd.BlendState.RenderTarget[0].RenderTargetWriteMask = D3D12_COLOR_WRITE_ENABLE_ALL;
    pd.SampleMask = UINT_MAX;
    pd.RasterizerState.FillMode = D3D12_FILL_MODE_SOLID; pd.RasterizerState.CullMode = D3D12_CULL_MODE_NONE;
    pd.RasterizerState.DepthClipEnable = TRUE;
    pd.InputLayout.pInputElementDescs = layout; pd.InputLayout.NumElements = 2;
    pd.PrimitiveTopologyType = D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE;
    pd.NumRenderTargets = 1; pd.RTVFormats[0] = DXGI_FORMAT_R8G8B8A8_UNORM; pd.SampleDesc.Count = 1;
    ID3D12PipelineState *pso;
    CHECK(ID3D12Device_CreateGraphicsPipelineState(device, &pd, &IID_ID3D12PipelineState, (void **)&pso),
          "CreateGraphicsPipelineState");
    LOG("pipeline made");

    float verts[] = { 0.0f, 0.6f, 0.0f, 1, 0, 0,   0.6f, -0.6f, 0.0f, 0, 1, 0,   -0.6f, -0.6f, 0.0f, 0, 0, 1 };
    D3D12_HEAP_PROPERTIES up = {D3D12_HEAP_TYPE_UPLOAD, D3D12_CPU_PAGE_PROPERTY_UNKNOWN, D3D12_MEMORY_POOL_UNKNOWN, 1, 1};
    D3D12_RESOURCE_DESC bd = {D3D12_RESOURCE_DIMENSION_BUFFER, 0, sizeof verts, 1, 1, 1, DXGI_FORMAT_UNKNOWN, {1, 0},
                              D3D12_TEXTURE_LAYOUT_ROW_MAJOR, D3D12_RESOURCE_FLAG_NONE};
    ID3D12Resource *vb;
    CHECK(ID3D12Device_CreateCommittedResource(device, &up, D3D12_HEAP_FLAG_NONE, &bd, D3D12_RESOURCE_STATE_GENERIC_READ,
                                               NULL, &IID_ID3D12Resource, (void **)&vb), "vertex buffer");
    void *p; D3D12_RANGE none = {0, 0};
    CHECK(ID3D12Resource_Map(vb, 0, &none, &p), "Map");
    memcpy(p, verts, sizeof verts); ID3D12Resource_Unmap(vb, 0, NULL);
    D3D12_VERTEX_BUFFER_VIEW vbv = {ID3D12Resource_GetGPUVirtualAddress(vb), sizeof verts, 24};

    ID3D12GraphicsCommandList *list;
    CHECK(ID3D12Device_CreateCommandList(device, 0, D3D12_COMMAND_LIST_TYPE_DIRECT, alloc, pso,
                                         &IID_ID3D12GraphicsCommandList, (void **)&list), "CreateCommandList");
    ID3D12GraphicsCommandList_Close(list);
    ID3D12Fence *fence; UINT64 fv = 0; HANDLE ev = CreateEventA(NULL, FALSE, FALSE, NULL);
    CHECK(ID3D12Device_CreateFence(device, 0, D3D12_FENCE_FLAG_NONE, &IID_ID3D12Fence, (void **)&fence), "CreateFence");

    D3D12_VIEWPORT vp = {0, 0, (float)width, (float)height, 0, 1};
    D3D12_RECT sr = {0, 0, (LONG)width, (LONG)height};
    for (int frame = 1; frame <= 600; frame++) {
        MSG msg;
        while (PeekMessageA(&msg, NULL, 0, 0, PM_REMOVE)) { TranslateMessage(&msg); DispatchMessageA(&msg); }
        UINT i = IDXGISwapChain3_GetCurrentBackBufferIndex(sc);
        CHECK(ID3D12CommandAllocator_Reset(alloc), "allocator Reset");
        CHECK(ID3D12GraphicsCommandList_Reset(list, alloc, pso), "list Reset");
        D3D12_RESOURCE_BARRIER b = {D3D12_RESOURCE_BARRIER_TYPE_TRANSITION, D3D12_RESOURCE_BARRIER_FLAG_NONE};
        b.Transition.pResource = targets[i]; b.Transition.Subresource = D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES;
        b.Transition.StateBefore = D3D12_RESOURCE_STATE_PRESENT; b.Transition.StateAfter = D3D12_RESOURCE_STATE_RENDER_TARGET;
        ID3D12GraphicsCommandList_ResourceBarrier(list, 1, &b);
        D3D12_CPU_DESCRIPTOR_HANDLE h = {rtv0.ptr + i * rtv_size};
        const float clear[4] = {0.05f, 0.05f, 0.12f, 1.0f};
        ID3D12GraphicsCommandList_OMSetRenderTargets(list, 1, &h, FALSE, NULL);
        ID3D12GraphicsCommandList_ClearRenderTargetView(list, h, clear, 0, NULL);
        ID3D12GraphicsCommandList_SetGraphicsRootSignature(list, root);
        ID3D12GraphicsCommandList_RSSetViewports(list, 1, &vp);
        ID3D12GraphicsCommandList_RSSetScissorRects(list, 1, &sr);
        ID3D12GraphicsCommandList_IASetPrimitiveTopology(list, D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
        ID3D12GraphicsCommandList_IASetVertexBuffers(list, 0, 1, &vbv);
        ID3D12GraphicsCommandList_DrawInstanced(list, 3, 1, 0, 0);
        b.Transition.StateBefore = D3D12_RESOURCE_STATE_RENDER_TARGET; b.Transition.StateAfter = D3D12_RESOURCE_STATE_PRESENT;
        ID3D12GraphicsCommandList_ResourceBarrier(list, 1, &b);
        CHECK(ID3D12GraphicsCommandList_Close(list), "list Close");
        ID3D12CommandQueue_ExecuteCommandLists(queue, 1, (ID3D12CommandList **)&list);
        CHECK(IDXGISwapChain3_Present(sc, 1, 0), "Present");
        CHECK(ID3D12CommandQueue_Signal(queue, fence, ++fv), "Signal");
        if (ID3D12Fence_GetCompletedValue(fence) < fv) {
            ID3D12Fence_SetEventOnCompletion(fence, fv, ev);
            if (WaitForSingleObject(ev, 5000) != WAIT_OBJECT_0) { LOG("FAILED: GPU did not finish frame %d in 5 s", frame); return 1; }
        }
        if (frame == 1 || frame % 60 == 0) LOG("frame %d", frame);
    }
    LOG("done: 600 frames");
    return 0;
}
