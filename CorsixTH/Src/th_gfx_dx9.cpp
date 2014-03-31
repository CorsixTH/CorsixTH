/*
Copyright (c) 2009-2013 Peter "Corsix" Cawley and Edvin "Lego3" Linge

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "config.h"
#ifdef CORSIX_TH_USE_DX9_RENDERER
#ifndef CORSIX_TH_USE_WIN32_SDK
#error Windows Platform SDK usage must be enabled to use DX9 renderer
#endif
#include "th_gfx.h"
#include <new>
#include <SDL.h>
#include <SDL_syswm.h>
#include <assert.h>
#include <math.h>
#ifdef _MSC_VER
#pragma comment(lib, "D3D9")
#pragma comment(lib, "D3DX9.lib")
#pragma warning(disable: 4996) // Deprecated fopen
#endif

template <class T>
static void THDX9_OnDeviceChangeThunk(THDX9_DeviceResource *pThis,
                                      eTHDX9DeviceChangeType eType)
{
    reinterpret_cast<T*>(pThis)->onDeviceChange(eType);
}

THRenderTarget::THRenderTarget()
{
    fnOnDeviceChange = THDX9_OnDeviceChangeThunk<THRenderTarget>;
    m_pD3D = NULL;
    m_pDevice = NULL;
    m_pPixelShader = NULL;
    m_pVerticies = NULL;
    m_pWhiteTexture = NULL;
    m_pZoomRenderTexture = NULL;
    m_pZoomRenderSurface = NULL;
    m_pOriginalBackBuffer = NULL;
    m_sLastError = "";
    setClipRect(NULL);
    m_iVertexCount = 0;
    m_iVertexLength = 0;
    m_iNonOverlappingStart = 0;
    m_iNonOverlapping = 0;
    m_iWidth = 0;
    m_iHeight = 0;
    m_iZoomTextureSize = 0;
    m_fZoomScale = 0.0f;
    m_pCursor = NULL;
    m_bHasLostDevice = false;
}

THRenderTarget::~THRenderTarget()
{
    if(m_pPixelShader != NULL) {
        m_pPixelShader->Release();
        m_pPixelShader = NULL;
    }
    if(m_pOriginalBackBuffer != NULL)
    {
        if(m_pDevice != NULL)
            m_pDevice->SetRenderTarget(0, m_pOriginalBackBuffer);
        m_pOriginalBackBuffer->Release();
        m_pOriginalBackBuffer = NULL;
    }
    if(m_pZoomRenderSurface != NULL)
    {
        m_pZoomRenderSurface->Release();
        m_pZoomRenderSurface = NULL;
    }
    if(m_pZoomRenderTexture != NULL)
    {
        m_pZoomRenderTexture->Release();
        m_pZoomRenderTexture = NULL;
    }
    if(m_pWhiteTexture != NULL)
    {
        m_pWhiteTexture->Release();
        m_pWhiteTexture = NULL;
    }
    if(m_pVerticies != NULL)
    {
        free(m_pVerticies);
        m_pVerticies = NULL;
    }
    if(m_pDevice != NULL)
    {
        while(m_pNext)
        {
            THDX9_DeviceResource* pResource =
                reinterpret_cast<THDX9_DeviceResource*>(m_pNext);
            pResource->fnOnDeviceChange(pResource, THDX9DCT_DeviceDestroyed);
        }
        D3DDEVICE_CREATION_PARAMETERS oParams;
        m_pDevice->GetCreationParameters(&oParams);
        if(this == (THRenderTarget*)GetWindowLongPtr(oParams.hFocusWindow, GWLP_USERDATA))
            SetWindowLongPtr(oParams.hFocusWindow, GWLP_USERDATA, 0);
        assert(m_pDevice->Release() == 0);
        m_pDevice = NULL;
    }
    if(m_pD3D != NULL)
    {
        m_pD3D->Release();
        m_pD3D = NULL;
    }
}

void THRenderTarget::onDeviceChange(eTHDX9DeviceChangeType eChangeType)
{
    // We caused the device change, so there is no need to do anything in
    // response to that change.
}

IDirect3DDevice9* THRenderTarget::getRawDevice(THDX9_DeviceResource* pUser)
{
    pUser->removeFromList();
    pUser->m_pPrev = this;
    pUser->m_pNext = m_pNext;
    if(m_pNext)
        m_pNext->m_pPrev = pUser;
    m_pNext = pUser;
    return getRawDevice();
}

static WNDPROC g_fnSDLWindowProc = NULL;
LRESULT CALLBACK WindowProcIntercept(HWND hWnd, UINT iMessage, WPARAM wParam, LPARAM lParam)
{
    if(iMessage == WM_SETCURSOR)
    {
        THRenderTarget* pTarget = reinterpret_cast<THRenderTarget*>(GetWindowLongPtr(hWnd, GWLP_USERDATA));
        if(pTarget && pTarget->hasCursor())
        {
            IDirect3DDevice9* pDevice = pTarget->getRawDevice();
            if(pDevice)
            {
                SetCursor(NULL);
                pDevice->ShowCursor(TRUE);
                return TRUE;
            }
        }
    }
    return CallWindowProc(g_fnSDLWindowProc, hWnd, iMessage, wParam, lParam);
}

bool THRenderTarget::create(const THRenderTargetCreationParams* pParams)
{
    SDL_Surface *pSDLSurface = SDL_SetVideoMode(pParams->iWidth,
        pParams->iHeight, pParams->iBPP, pParams->iSDLFlags);
    if(pSDLSurface == NULL)
    {
        m_sLastError = SDL_GetError();
        return false;
    }

    SDL_SysWMinfo oWindowInfo;
    HWND hWindow;
    oWindowInfo.version.major = SDL_MAJOR_VERSION;
    oWindowInfo.version.minor = SDL_MINOR_VERSION;
    oWindowInfo.version.patch = SDL_PATCHLEVEL;
    if(SDL_GetWMInfo(&oWindowInfo) == 1)
    {
        hWindow = oWindowInfo.window;
    }
    else
    {
        m_sLastError = "Could not get HWND from SDL";
        return false;
    }

    // When the video mode is changed (i.e. from windowed to fullscreen), SDL
    // reuses the same HWND, so be careful not to subclass it twice, as that
    // will lead to a stack overflow.
    if(g_fnSDLWindowProc == NULL)
        g_fnSDLWindowProc = (WNDPROC)GetWindowLongPtr(hWindow, GWLP_WNDPROC);
    if(g_fnSDLWindowProc == (WNDPROC)GetWindowLongPtr(hWindow, GWLP_WNDPROC))
    {
        SetWindowLongPtr(hWindow, GWLP_WNDPROC, (LONG_PTR)WindowProcIntercept);
    }

    m_pD3D = Direct3DCreate9(D3D_SDK_VERSION);
    if(m_pD3D == NULL)
    {
        m_sLastError = "Could not create Direct3D object";
        return false;
    }

    D3DDISPLAYMODE d3ddm;
    if(m_pD3D->GetAdapterDisplayMode(D3DADAPTER_DEFAULT, &d3ddm) != D3D_OK)
    {
        m_sLastError = "Could not query display adapter";
        return false;
    }

    ZeroMemory(&m_oDeviceCaps, sizeof(m_oDeviceCaps));
    D3DDEVTYPE eDeviceTypeToUse = D3DDEVTYPE_HAL;
    if(m_pD3D->GetDeviceCaps(D3DADAPTER_DEFAULT, eDeviceTypeToUse, &m_oDeviceCaps) != D3D_OK)
    {
        eDeviceTypeToUse = D3DDEVTYPE_SW;
        if(m_pD3D->GetDeviceCaps(D3DADAPTER_DEFAULT, eDeviceTypeToUse, &m_oDeviceCaps) != D3D_OK)
        {
            eDeviceTypeToUse = D3DDEVTYPE_REF;
            if(m_pD3D->GetDeviceCaps(D3DADAPTER_DEFAULT, eDeviceTypeToUse, &m_oDeviceCaps) != D3D_OK)
            {
                m_sLastError = "Could not get DirectX device capabilities for HAL, SW or REF";
                return false;
            }
        }
    }

    ZeroMemory(&m_oPresentParams, sizeof(m_oPresentParams));
    m_oPresentParams.SwapEffect = D3DSWAPEFFECT_DISCARD;
    m_oPresentParams.EnableAutoDepthStencil = false;
    m_oPresentParams.AutoDepthStencilFormat = D3DFMT_D16;
    m_oPresentParams.hDeviceWindow = hWindow;
    m_oPresentParams.BackBufferCount = 1;
    m_oPresentParams.Windowed = pParams->bFullscreen ? FALSE : TRUE;
    m_oPresentParams.BackBufferWidth = pParams->iWidth;
    m_oPresentParams.BackBufferHeight = pParams->iHeight;
    m_oPresentParams.BackBufferFormat = d3ddm.Format;
    m_oPresentParams.PresentationInterval = pParams->bPresentImmediate ?
        D3DPRESENT_INTERVAL_IMMEDIATE : D3DPRESENT_INTERVAL_DEFAULT;

    DWORD dwBehaviour = D3DCREATE_FPU_PRESERVE; // For Lua
    if(m_oDeviceCaps.DevCaps & D3DDEVCAPS_HWTRANSFORMANDLIGHT)
        dwBehaviour |= D3DCREATE_HARDWARE_VERTEXPROCESSING;
    else
        dwBehaviour |= D3DCREATE_SOFTWARE_VERTEXPROCESSING;

    D3DPRESENT_PARAMETERS oPresentParams = m_oPresentParams;
    if(FAILED(m_pD3D->CreateDevice(D3DADAPTER_DEFAULT, eDeviceTypeToUse,
        hWindow, dwBehaviour, &oPresentParams, &m_pDevice)))
    {
        m_sLastError = "Could not create device";
        return false;
    }

    m_bIsWindowed = !pParams->bFullscreen;
    m_bIsHardwareCursorSupported = (m_oDeviceCaps.CursorCaps & (pParams->iHeight
        < 400 ? D3DCURSORCAPS_LOWRES : D3DCURSORCAPS_COLOR)) != 0;
    m_iVertexCount = 0;
    m_iVertexLength = 768;
    m_pVerticies = (THDX9_Vertex*)malloc(sizeof(THDX9_Vertex) * m_iVertexLength);
    if(m_pVerticies == NULL)
    {
        m_sLastError = "Could not allocate vertex buffer";
        return false;
    }
    m_iNonOverlapping = 0;
    m_iWidth = pParams->iWidth;
    m_iHeight = pParams->iHeight;
    if(!_initialiseDeviceSettings())
        return false;

    THDX9_FillIndexBuffer(m_aiVertexIndicies, 0, THDX9_INDEX_BUFFER_LENGTH);

    if((m_pWhiteTexture = THDX9_CreateSolidTexture(1, 1,
        D3DCOLOR_ARGB(0xFF, 0xFF, 0xFF, 0xFF), m_pDevice)) == NULL)
    {
        m_sLastError = "Could not create reference texture";
        return false;
    }

    // Create the pixel shader used for making a blue filter effect
    // when the game is paused.
    m_bBlueFilterActive = false;
    if (m_pPixelShader == NULL) {
        LPD3DXBUFFER m_pCode;
        m_pResult = D3DXCompileShaderFromFile("Src/shaders/blue_filter.psh",
                                   NULL,          //macro's
                                   NULL,          //includes
                                   "ps_main",     //main function
                                   "ps_2_0",      //shader profile
                                   0,             //flags
                                   &m_pCode,      //compiled operations
                                   NULL,          //errors
                                   NULL);         //constants

        m_pDevice->CreatePixelShader((DWORD*)m_pCode->GetBufferPointer(),
                                   &m_pPixelShader);
    }

    SetWindowLongPtr(hWindow, GWLP_USERDATA, (LONG_PTR)this);
    return true;
}

bool THRenderTarget::_initialiseDeviceSettings()
{
    if(m_pDevice->SetFVF(D3DFVF_XYZ | D3DFVF_DIFFUSE | D3DFVF_TEX1) != D3D_OK)
    {
        m_sLastError = "Could not set the DirectX fixed function vertex type";
        return false;
    }

    m_pDevice->SetRenderState(D3DRS_ZENABLE, FALSE);
    m_pDevice->SetRenderState(D3DRS_ALPHABLENDENABLE, TRUE);
    m_pDevice->SetRenderState(D3DRS_CLIPPING, FALSE);
    m_pDevice->SetRenderState(D3DRS_COLORWRITEENABLE, D3DCOLORWRITEENABLE_ALPHA
        | D3DCOLORWRITEENABLE_RED | D3DCOLORWRITEENABLE_GREEN | D3DCOLORWRITEENABLE_BLUE);
    m_pDevice->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
    m_pDevice->SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
    m_pDevice->SetRenderState(D3DRS_LIGHTING, FALSE);
    m_pDevice->SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
    m_pDevice->SetRenderState(D3DRS_LOCALVIEWER, FALSE);
    m_pDevice->SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
    m_pDevice->SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
    m_pDevice->SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
    m_pDevice->SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    m_pDevice->SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
    m_pDevice->SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, 0);
    m_pDevice->SetTextureStageState(1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
    m_pDevice->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
    m_pDevice->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
    if(m_oDeviceCaps.TextureFilterCaps & D3DPTFILTERCAPS_MAGFANISOTROPIC)
        m_pDevice->SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_ANISOTROPIC);
    else
        m_pDevice->SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
    m_pDevice->SetSamplerState(0, D3DSAMP_MAXANISOTROPY, m_oDeviceCaps.MaxAnisotropy);
    if(m_oDeviceCaps.TextureFilterCaps & D3DPTFILTERCAPS_MINFANISOTROPIC)
        m_pDevice->SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_ANISOTROPIC);
    else
        m_pDevice->SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
    if(m_oDeviceCaps.TextureFilterCaps & D3DPTFILTERCAPS_MIPFLINEAR)
        m_pDevice->SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
    else
        m_pDevice->SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_POINT);

    D3DMATRIX mtxIdentity = {
        1.0f, 0.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f};

    if(m_pDevice->SetTransform(D3DTS_WORLD, &mtxIdentity) != D3D_OK)
    {
        m_sLastError = "Could not set DirectX world transform matrix";
        return false;
    }
    if(m_pDevice->SetTransform(D3DTS_VIEW, &mtxIdentity) != D3D_OK)
    {
        m_sLastError = "Could not set DirectX view transform matrix";
        return false;
    }

    return _setProjectionMatrix(m_iWidth, m_iHeight);
}

bool THRenderTarget::_setProjectionMatrix(int iWidth, int iHeight)
{
    float fWidth = (float)iWidth;
    float fHeight = (float)iHeight;

    D3DMATRIX mtxWorldToScreen = {
        1.0f, 0.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f};

    mtxWorldToScreen.m[0][0] = 2.0f / fWidth;
    mtxWorldToScreen.m[1][1] = -2.0f / fHeight;
    mtxWorldToScreen.m[3][0] = -1.0f - (1.0f / fWidth);
    mtxWorldToScreen.m[3][1] =  1.0f + (1.0f / fHeight);

    if(m_pDevice->SetTransform(D3DTS_PROJECTION, &mtxWorldToScreen) != D3D_OK)
    {
        m_sLastError = "Could not set DirectX projection transform matrix";
        return false;
    }

    return true;
}

void THRenderTarget::_flushZoomBuffer()
{
    if(m_pOriginalBackBuffer == NULL)
    {
        // No zoom buffer in use
        return;
    }

    // Restore original render settings
    m_pDevice->SetRenderTarget(0, m_pOriginalBackBuffer);
    _setProjectionMatrix(m_iWidth, m_iHeight);
    m_pOriginalBackBuffer->Release();
    m_pOriginalBackBuffer = NULL;

    // Draw zoom buffer onto screen (the scaling here performs the actual
    // zooming).
    float fFactor = m_fZoomScale * static_cast<float>(m_iZoomTextureSize);
#define SetVertexData(n, x_, y_) \
    pVerticies[n].x = (float)x_; \
    pVerticies[n].y = (float)y_; \
    pVerticies[n].z = 0.0f; \
    pVerticies[n].colour = D3DCOLOR_ARGB(0xFF, 0xFF, 0xFF, 0xFF); \
    pVerticies[n].u = (float)x_ / fFactor; \
    pVerticies[n].v = (float)y_ / fFactor

    THDX9_Vertex *pVerticies = allocVerticies(4, m_pZoomRenderTexture);
    SetVertexData(0, 0, 0);
    SetVertexData(1, m_iWidth, 0);
    SetVertexData(2, m_iWidth, m_iHeight);
    SetVertexData(3, 0, m_iHeight);
#undef SetVertexData
    m_pDevice->SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE2X);
    flushSprites();
    m_pDevice->SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
}

bool THRenderTarget::setScaleFactor(float fScale, THScaledItems eWhatToScale)
{
    flushSprites();
    _flushZoomBuffer();

    if(eWhatToScale == THSI_None || (0.999 <= fScale && fScale <= 1.001))
    {
        // Effectively back to no scaling, so nothing more to do
        return true;
    }
    if(eWhatToScale != THSI_All)
    {
        // TODO: Implement selective scaling.
        return false;
    }

    // Calculate "virtual screen size" and round up to a power of 2 (as
    // textures need to be powers of 2)
    if(fScale <= 0.0f)
        return false;
    float fVirtualSize = static_cast<float>(max(m_iWidth, m_iHeight)) / fScale;
    unsigned int iZoomTextureSize = 1 << static_cast<unsigned int>(
        ceil(logf(fVirtualSize) / logf(2)));
    if(iZoomTextureSize == 0) // Catch integer overflow
        return false;

    // Create the render texture
    if(m_iZoomTextureSize != iZoomTextureSize)
    {
        if(m_pZoomRenderSurface)
        {
            m_pZoomRenderSurface->Release();
            m_pZoomRenderSurface = NULL;
        }
        if(m_pZoomRenderTexture)
        {
            m_pZoomRenderTexture->Release();
            m_pZoomRenderTexture = NULL;
        }
        m_iZoomTextureSize = 0;
        if(m_pDevice->CreateTexture(iZoomTextureSize, iZoomTextureSize, 1,
            D3DUSAGE_RENDERTARGET, D3DFMT_A8R8G8B8,
            D3DPOOL_DEFAULT, &m_pZoomRenderTexture, NULL) != D3D_OK)
        {
            return false;
        }
        if(m_pZoomRenderTexture->GetSurfaceLevel(0, &m_pZoomRenderSurface)
            != D3D_OK)
        {
            return false;
        }
        m_iZoomTextureSize = iZoomTextureSize;
    }

    // Set device to render to the zoom texture (for pixel-art like in TH, it
    // looks much nicer to have all sprites rendered pixel-perfectly into the
    // zoom texture, and then scale the zoom texture, as compared to zooming
    // each sprite as it is drawn directly onto the screen).
    if(m_pDevice->GetRenderTarget(0, &m_pOriginalBackBuffer) != D3D_OK)
        return false;
    if(m_pDevice->SetRenderTarget(0, m_pZoomRenderSurface) != D3D_OK)
    {
        m_pDevice->SetRenderTarget(0, m_pOriginalBackBuffer);
        m_pOriginalBackBuffer->Release();
        m_pOriginalBackBuffer = NULL;
        return false;
    }
    m_pDevice->Clear(0, NULL, D3DCLEAR_TARGET,
        D3DCOLOR_ARGB(0x00, 0x00, 0x00, 0x00), 1.0f, 0);
    m_fZoomScale = fScale;
    m_iZoomTextureSize = iZoomTextureSize;

    return _setProjectionMatrix(iZoomTextureSize, iZoomTextureSize);
}

const char* THRenderTarget::getLastError()
{
    return m_sLastError;
}

bool THRenderTarget::takeScreenshot(const char* sFile)
{
    D3DDISPLAYMODE oMode;
    if(m_pDevice->GetDisplayMode(0, &oMode) != D3D_OK)
    {
        m_sLastError = "Could not get display mode";
        return false;
    }
    IDirect3DSurface9 *pSurfaceBuffer;
    if(m_pDevice->CreateOffscreenPlainSurface(oMode.Width, oMode.Height,
        D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, &pSurfaceBuffer, NULL) != D3D_OK)
    {
        m_sLastError = "Could not create screenshot buffer";
        return false;
    }
    if(m_pDevice->GetFrontBufferData(0, pSurfaceBuffer) != D3D_OK)
    {
        m_sLastError = "Could not obtain screenshot data";
        pSurfaceBuffer->Release();
        return false;
    }
    D3DLOCKED_RECT oLock;
    if(pSurfaceBuffer->LockRect(&oLock, NULL, D3DLOCK_READONLY) != D3D_OK)
    {
        m_sLastError = "Could not lock screenshot data";
        pSurfaceBuffer->Release();
        return false;
    }
    FILE* fBitmap = fopen(sFile, "wb");
    if(fBitmap == NULL)
    {
        m_sLastError = "Could not open output file";
        pSurfaceBuffer->UnlockRect();
        pSurfaceBuffer->Release();
        return false;
    }
    BITMAPFILEHEADER oFileHeader;
    oFileHeader.bfType = 'MB';
    oFileHeader.bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
    oFileHeader.bfSize = oFileHeader.bfOffBits + oMode.Width * oMode.Height * 4;
    oFileHeader.bfReserved1 = 0;
    oFileHeader.bfReserved2 = 0;
    BITMAPINFOHEADER oInfoHeader;
    oInfoHeader.biSize = sizeof(BITMAPINFOHEADER);
    oInfoHeader.biWidth = oMode.Width;
    oInfoHeader.biHeight = oMode.Height;
    oInfoHeader.biPlanes = 1;
    oInfoHeader.biBitCount = 32;
    oInfoHeader.biCompression = BI_RGB;
    oInfoHeader.biSizeImage = 0;
    oInfoHeader.biXPelsPerMeter = 72;
    oInfoHeader.biYPelsPerMeter = 72;
    oInfoHeader.biClrUsed = 0;
    oInfoHeader.biClrImportant = 0;
    fwrite(&oFileHeader, sizeof(BITMAPFILEHEADER), 1, fBitmap);
    fwrite(&oInfoHeader, sizeof(BITMAPINFOHEADER), 1, fBitmap);
    for(int iY = oMode.Height - 1; iY >= 0; --iY)
    {
        fwrite(reinterpret_cast<char*>(oLock.pBits) + oLock.Pitch * iY,
            4, oMode.Width, fBitmap);
    }
    fclose(fBitmap);
    pSurfaceBuffer->UnlockRect();
    pSurfaceBuffer->Release();
    return true;
}

bool THRenderTarget::startFrame()
{
    if(!m_pDevice)
    {
        m_sLastError = "No device";
        return false;
    }
    if(m_bHasLostDevice)
    {
        if(m_pZoomRenderSurface)
        {
            m_pZoomRenderSurface->Release();
            m_pZoomRenderSurface = NULL;
        }
        if(m_pZoomRenderTexture)
        {
            m_pZoomRenderTexture->Release();
            m_pZoomRenderTexture = NULL;
        }
        m_iZoomTextureSize = 0;
        if(m_pDevice->TestCooperativeLevel() != D3DERR_DEVICENOTRESET)
            return false;
        D3DPRESENT_PARAMETERS oPresentParams = m_oPresentParams;
        if(m_pDevice->Reset(&oPresentParams) == D3D_OK)
        {
            m_bHasLostDevice = false;
            _initialiseDeviceSettings();
            if(hasCursor())
                setCursor(m_pCursor);
        }
        else
            return false;
    }
    m_pDevice->Clear(0, NULL, D3DCLEAR_TARGET, D3DCOLOR_XRGB(0, 0, 0), 1.0f, 0);
    m_pDevice->BeginScene();
    return true;
}

bool THRenderTarget::endFrame()
{
    if(!m_pDevice)
    {
        m_sLastError = "No device";
        return false;
    }
    flushSprites();
    _flushZoomBuffer();
    m_pDevice->EndScene();
    switch(m_pDevice->Present(NULL, NULL, NULL, NULL))
    {
    case D3D_OK:
        return true;
    case D3DERR_DEVICELOST:
        m_sLastError = "Could not present (device lost)";
        m_bHasLostDevice = true;
        break;
    default:
        m_sLastError = "Could not present";
        break;
    }
    return false;
}

bool THRenderTarget::fillBlack()
{
    if(!m_pDevice)
    {
        m_sLastError = "No device";
        return false;
    }
    m_pDevice->Clear(0, NULL, D3DCLEAR_TARGET, D3DCOLOR_XRGB(0, 0, 0), 1.0f, 0);
    return true;
}

void THRenderTarget::setBlueFilterActive(bool bActivate)
{
    m_bBlueFilterActive = bActivate;
    if (m_bBlueFilterActive)
    {
        m_pDevice->SetPixelShader(m_pPixelShader);
    }
    else
    {
        m_pDevice->SetPixelShader(NULL);
    }
}

uint32_t THRenderTarget::mapColour(uint8_t iR, uint8_t iG, uint8_t iB)
{
    return D3DCOLOR_ARGB(0xFF, iR, iG, iB);
}

bool THRenderTarget::fillRect(uint32_t iColour, int iX, int iY, int iW, int iH)
{
    draw(m_pWhiteTexture, iW, iH, iX, iY, 0, 1, 1, 0, 0);
    THDX9_Vertex* pVerts = m_pVerticies + m_iVertexCount;
    for(int i = 1; i <= 4; ++i)
    {
        pVerts[-i].colour = iColour;
    }
    return true;
}

void THRenderTarget::getClipRect(THClipRect* pRect) const
{
    *pRect = m_rcClip;
}

int THRenderTarget::getWidth() const
{
    return m_iWidth;
}

int THRenderTarget::getHeight() const
{
    return m_iHeight;
}

void THRenderTarget::setClipRect(const THClipRect* pRect)
{
    if(pRect != NULL)
    {
        m_rcClip = *pRect;
    }
    else
    {
        m_rcClip.x = -1000;
        m_rcClip.y = -1000;
        m_rcClip.w = 0xFFFF;
        m_rcClip.h = 0xFFFF;
    }
}

void THRenderTarget::startNonOverlapping()
{
    if(m_iNonOverlapping++ == 0)
        m_iNonOverlappingStart = m_iVertexCount;
}

static int sprite_tex_compare(const void* left, const void* right)
{
    const THDX9_Vertex *pLeft  = reinterpret_cast<const THDX9_Vertex*>(left);
    const THDX9_Vertex *pRight = reinterpret_cast<const THDX9_Vertex*>(right);

    if(pLeft->tex == pRight->tex)
        return 0;
    else if(pLeft->tex < pRight->tex)
        return -1;
    else
        return 1;
}

void THRenderTarget::finishNonOverlapping()
{
    if(--m_iNonOverlapping > 0)
        return;

    // If more than one texture is used in the range of non-overlapping
    // sprites, then sort the entire range by texture.

    size_t iStart = m_iNonOverlappingStart;
    IDirect3DTexture9 *pTexture = m_pVerticies[iStart].tex;
    for(size_t i = iStart + 4; i < m_iVertexCount; i += 4)
    {
        if(m_pVerticies[i].tex != pTexture)
        {
            qsort(m_pVerticies + iStart, (m_iVertexCount - iStart) / 4,
                sizeof(THDX9_Vertex) * 4, sprite_tex_compare);
            break;
        }
    }
}

THPalette::THPalette()
{
}

static const unsigned char gs_iTHColourLUT[0x40] = {
    // Maps 0-63 to 0-255
    0x00, 0x04, 0x08, 0x0C, 0x10, 0x14, 0x18, 0x1C,
    0x20, 0x24, 0x28, 0x2D, 0x31, 0x35, 0x39, 0x3D,
    0x41, 0x45, 0x49, 0x4D, 0x51, 0x55, 0x59, 0x5D,
    0x61, 0x65, 0x69, 0x6D, 0x71, 0x75, 0x79, 0x7D,
    0x82, 0x86, 0x8A, 0x8E, 0x92, 0x96, 0x9A, 0x9E,
    0xA2, 0xA6, 0xAA, 0xAE, 0xB2, 0xB6, 0xBA, 0xBE,
    0xC2, 0xC6, 0xCA, 0xCE, 0xD2, 0xD7, 0xDB, 0xDF,
    0xE3, 0xE7, 0xEB, 0xEF, 0xF3, 0xF7, 0xFB, 0xFF,
};

bool THPalette::loadFromTHFile(const unsigned char* pData, size_t iDataLength)
{
    if(iDataLength != 256 * 3)
        return false;

    m_iNumColours = static_cast<int>(iDataLength / 3);
    for(int i = 0; i < m_iNumColours; ++i, pData += 3)
    {
        unsigned char iR = gs_iTHColourLUT[pData[0] & 0x3F];
        unsigned char iG = gs_iTHColourLUT[pData[1] & 0x3F];
        unsigned char iB = gs_iTHColourLUT[pData[2] & 0x3F];
        D3DCOLOR iColour = D3DCOLOR_ARGB(0xFF, iR, iG, iB);
        // Remap magenta to transparent
        if(iColour == D3DCOLOR_ARGB(0xFF, 0xFF, 0x00, 0xFF))
            iColour = D3DCOLOR_ARGB(0x00, 0x00, 0x00, 0x00);
        m_aColoursARGB[i] = iColour;
    }

    return true;
}

bool THPalette::setEntry(int iEntry, uint8_t iR, uint8_t iG, uint8_t iB)
{
    if(iEntry < 0 || iEntry >= m_iNumColours)
        return false;
    D3DCOLOR iColour = D3DCOLOR_ARGB(0xFF, iR, iG, iB);
    // Remap magenta to transparent
    if(iColour == D3DCOLOR_ARGB(0xFF, 0xFF, 0x00, 0xFF))
        iColour = D3DCOLOR_ARGB(0x00, 0x00, 0x00, 0x00);
    m_aColoursARGB[iEntry] = iColour;
    return true;
}

int THPalette::getColourCount() const
{
    return m_iNumColours;
}

const uint32_t* THPalette::getARGBData() const
{
    return m_aColoursARGB;
}

IDirect3DTexture9* THDX9_CreateSolidTexture(int iWidth, int iHeight,
                                            uint32_t iColour,
                                            IDirect3DDevice9* pDevice)
{
    IDirect3DTexture9 *pTexture = NULL;
    if(pDevice->CreateTexture(iWidth, iHeight, 1, 0, D3DFMT_A8R8G8B8,
        D3DPOOL_MANAGED, &pTexture, NULL) != D3D_OK || pTexture == NULL)
    {
        return NULL;
    }
    D3DLOCKED_RECT rcLocked;
    if(pTexture->LockRect(0, &rcLocked, NULL, D3DLOCK_DISCARD) != D3D_OK)
    {
        pTexture->Release();
        return NULL;
    }

    uint8_t* pData = reinterpret_cast<uint8_t*>(rcLocked.pBits);
    for(int y = 0; y < iHeight; ++y, pData += rcLocked.Pitch)
    {
        uint32_t* pRow = reinterpret_cast<uint32_t*>(pData);
        for(int x = 0; x < iWidth; ++x, ++pRow)
        {
            *pRow = iColour;
        }
    }

    pTexture->UnlockRect(0);
    return pTexture;
}

IDirect3DTexture9* THDX9_CreateTexture(int iWidth, int iHeight,
                                       const unsigned char* pPixels,
                                       const THPalette* pPalette,
                                       IDirect3DDevice9* pDevice,
                                       int* pWidth2,
                                       int* pHeight2)
{
    int iWidth2 = 1;
    int iHeight2 = 1;
    while(iWidth2 < iWidth)
        iWidth2 <<= 1;
    while(iHeight2 < iHeight)
        iHeight2 <<= 1;
    if(pWidth2)
        *pWidth2 = iWidth2;
    if(pHeight2)
        *pHeight2 = iHeight2;

    // It might seem attractive to try and use 8-bit paletted textures rather
    // than 32-bit RGBA textures, but very few cards support 8-bit textures, so
    // it isn't worth implementing.

    IDirect3DTexture9 *pTexture = NULL;
    if(pDevice->CreateTexture(iWidth2, iHeight2, 1, 0, D3DFMT_A8R8G8B8,
        D3DPOOL_MANAGED, &pTexture, NULL) != D3D_OK || pTexture == NULL)
    {
        return NULL;
    }
    D3DLOCKED_RECT rcLocked;
    if(pTexture->LockRect(0, &rcLocked, NULL, D3DLOCK_DISCARD) != D3D_OK)
    {
        pTexture->Release();
        return NULL;
    }

    uint8_t* pData = reinterpret_cast<uint8_t*>(rcLocked.pBits);
    const uint32_t* pColours = pPalette->getARGBData();
    for(int y = 0; y < iHeight; ++y, pData += rcLocked.Pitch)
    {
        uint32_t* pRow = reinterpret_cast<uint32_t*>(pData);
        for(int x = 0; x < iWidth; ++x, ++pPixels, ++pRow)
        {
            *pRow = pColours[*pPixels];
        }
        for(int x = iWidth; x < iWidth2; ++x, ++pRow)
        {
            *pRow = D3DCOLOR_ARGB(0, 0, 0, 0);
        }
    }
    for(int y = iHeight; y < iHeight2; ++y, pData += rcLocked.Pitch)
    {
        uint32_t* pRow = reinterpret_cast<uint32_t*>(pData);
        for(int x = 0; x < iWidth2; ++x, ++pRow)
        {
            *pRow = D3DCOLOR_ARGB(0, 0, 0, 0);
        }
    }

    pTexture->UnlockRect(0);
    return pTexture;
}

THDX9_Vertex* THRenderTarget::allocVerticies(size_t iCount,
                                             IDirect3DTexture9* pTexture)
{
    if(m_iVertexCount + iCount > m_iVertexLength)
    {
        m_iVertexLength = (m_iVertexLength * 2) + iCount;
        m_pVerticies = (THDX9_Vertex*)realloc(m_pVerticies,
            sizeof(THDX9_Vertex) * m_iVertexLength);
    }
    THDX9_Vertex *pResult = m_pVerticies + m_iVertexCount;
    pResult[0].tex = pTexture;
    m_iVertexCount += iCount;
    return pResult;
}

void THRenderTarget::_drawVerts(size_t iFirst, size_t iLast)
{
    // Note: Convential wisdom might suggest that DrawIndexedPrimitive
    // would be more efficient to use than DrawIndexedPrimitiveUP, however the
    // vertex buffer would have to be modified each frame. My experiments have
    // shown that using vertex buffers and index buffers yields no frame rate
    // increase, whilst still increasing the complexity. Therefore the code
    // should stick to using DrawIndexedPrimitiveUP for the immediate future.

    UINT iCount = static_cast<UINT>(iLast - iFirst);
    m_pDevice->DrawIndexedPrimitiveUP(D3DPT_TRIANGLELIST, 0, iCount,
        iCount / 2, m_aiVertexIndicies, D3DFMT_INDEX16, m_pVerticies + iFirst,
        static_cast<UINT>(sizeof(THDX9_Vertex)));
}

void THRenderTarget::flushSprites()
{
    if(m_iVertexCount == 0)
        return;

    IDirect3DTexture9 *pTexture = m_pVerticies[0].tex;
    m_pDevice->SetTexture(0, pTexture);
    size_t iStart = 0;
    size_t iIndexCount = 0;
    for(size_t i = 4; i < m_iVertexCount; i += 4)
    {
        iIndexCount += 6;
        if(m_pVerticies[i].tex != pTexture ||
            iIndexCount == THDX9_INDEX_BUFFER_LENGTH)
        {
            _drawVerts(iStart, i);
            iIndexCount = 0;
            iStart = i;
            pTexture = m_pVerticies[i].tex;
            m_pDevice->SetTexture(0, pTexture);
        }
    }
    _drawVerts(iStart, m_iVertexCount);

    m_iVertexCount = 0;
}

THRawBitmap::THRawBitmap()
{
    fnOnDeviceChange = THDX9_OnDeviceChangeThunk<THRawBitmap>;
    m_pBitmap = NULL;
    m_pPalette = NULL;
    m_iWidth = -1;
    m_iHeight = -1;
}

THRawBitmap::~THRawBitmap()
{
    if(m_pBitmap)
        m_pBitmap->Release();
}

void THRawBitmap::onDeviceChange(eTHDX9DeviceChangeType eChangeType)
{
    if(m_pBitmap)
    {
        m_pBitmap->Release();
        m_pBitmap = NULL;
    }
    removeFromList();
}

void THRawBitmap::setPalette(const THPalette* pPalette)
{
    m_pPalette = pPalette;
}

bool THRawBitmap::loadFromTHFile(const unsigned char* pPixelData,
                                 size_t iPixelDataLength,
                                 int iWidth, THRenderTarget *pEventualCanvas)
{
    if(m_pPalette == NULL || pEventualCanvas == NULL)
        return false;

    if(m_pBitmap)
    {
        m_pBitmap->Release();
        m_pBitmap = NULL;
    }

    m_iWidth = iWidth;
    m_iHeight = static_cast<int>(iPixelDataLength) / iWidth;
    m_pBitmap = THDX9_CreateTexture(iWidth, m_iHeight, pPixelData, m_pPalette,
        pEventualCanvas->getRawDevice(this), &m_iWidth2, &m_iHeight2);

    return m_pBitmap != NULL;
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY)
{
    pCanvas->draw(m_pBitmap, m_iWidth, m_iHeight, iX, iY, 0, m_iWidth2,
        m_iHeight2, 0, 0);
}

void THRawBitmap::draw(THRenderTarget* pCanvas, int iX, int iY,
              int iSrcX, int iSrcY, int iWidth, int iHeight)
{
    pCanvas->draw(m_pBitmap, iWidth, iHeight, iX, iY, 0, m_iWidth2, m_iHeight2,
        iSrcX, iSrcY);
}

THSpriteSheet::THSpriteSheet()
{
    fnOnDeviceChange = THDX9_OnDeviceChangeThunk<THSpriteSheet>;
    m_pSprites = 0;
    m_iSpriteCount = 0;
    m_pPalette = NULL;
    m_pDevice = NULL;
    m_pMegaSheet = NULL;
}

THSpriteSheet::~THSpriteSheet()
{
    _freeSprites();
}

void THSpriteSheet::onDeviceChange(eTHDX9DeviceChangeType eChangeType)
{
    _freeSprites();
}

void THSpriteSheet::_freeSprites()
{
    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        if(m_pSprites[i].pBitmap && m_pSprites[i].pBitmap != m_pMegaSheet)
            m_pSprites[i].pBitmap->Release();
        if(m_pSprites[i].pAltBitmap)
            m_pSprites[i].pAltBitmap->Release();
        if(m_pSprites[i].pData)
            delete[] m_pSprites[i].pData;
    }
    if(m_pMegaSheet)
    {
        m_pMegaSheet->Release();
        m_pMegaSheet = NULL;
    }
    delete[] m_pSprites;
    m_pSprites = NULL;
    m_iSpriteCount = 0;
    if(m_pDevice)
    {
        m_pDevice->Release();
        m_pDevice = NULL;
    }
    removeFromList();
}

void THSpriteSheet::setPalette(const THPalette* pPalette)
{
    m_pPalette = pPalette;
}

bool THSpriteSheet::loadFromTHFile(
                    const unsigned char* pTableData, size_t iTableDataLength,
                    const unsigned char* pChunkData, size_t iChunkDataLength,
                    bool bComplexChunks, THRenderTarget* pCanvas)
{
    _freeSprites();
    if(pCanvas == NULL)
    {
        return false;
    }
    m_pDevice = pCanvas->getRawDevice(this);
    m_pDevice->AddRef();

    m_iSpriteCount = (unsigned int)(iTableDataLength / sizeof(th_sprite_t));
    m_pSprites = new (std::nothrow) sprite_t[m_iSpriteCount];
    if(m_pSprites == NULL)
    {
        m_iSpriteCount = 0;
        return false;
    }

    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        sprite_t *pSprite = m_pSprites + i;
        const th_sprite_t *pTHSprite = reinterpret_cast<const th_sprite_t*>(pTableData) + i;

        pSprite->pBitmap = NULL;
        pSprite->pAltBitmap = NULL;
        pSprite->pData = NULL;
        pSprite->pAltPaletteMap = NULL;
        pSprite->iWidth = pTHSprite->width;
        pSprite->iHeight = pTHSprite->height;
        pSprite->iWidth2 = 1;
        pSprite->iHeight2 = 1;
        while(pSprite->iWidth2 < pSprite->iWidth)
            pSprite->iWidth2 <<= 1;
        while(pSprite->iHeight2 < pSprite->iHeight)
            pSprite->iHeight2 <<= 1;

        if(pSprite->iWidth == 0 || pSprite->iHeight == 0)
            continue;

        {
            unsigned char *pData = new unsigned char[pSprite->iWidth * pSprite->iHeight];
            THChunkRenderer oRenderer(pSprite->iWidth, pSprite->iHeight, pData);
            int iDataLen = static_cast<int>(iChunkDataLength) - static_cast<int>(pTHSprite->position);
            if(iDataLen < 0 || iDataLen > static_cast<int>(iChunkDataLength))
                iDataLen = 0;
            oRenderer.decodeChunks(pChunkData + pTHSprite->position, iDataLen, bComplexChunks);
            pSprite->pData = oRenderer.takeData();
        }
    }

    sprite_t **ppSortedSprites = new sprite_t*[m_iSpriteCount];
    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        ppSortedSprites[i] = m_pSprites + i;
    }
    qsort(ppSortedSprites, m_iSpriteCount, sizeof(sprite_t*), _sortSpritesHeight);

    unsigned int iSize;
    if(_tryFitSingleTex(ppSortedSprites, 2048))
    {
        iSize = 2048;
        if(_tryFitSingleTex(ppSortedSprites, 1024))
        {
            iSize = 1024;
            if(_tryFitSingleTex(ppSortedSprites, 512))
            {
                iSize = 512;
                if(_tryFitSingleTex(ppSortedSprites, 256))
                {
                    iSize = 256;
                    if(_tryFitSingleTex(ppSortedSprites, 128))
                        iSize = 128;
                }
            }
        }
    }
    else
    {
        delete[] ppSortedSprites;
        return true;
    }

    _makeSingleTex(ppSortedSprites, iSize);
    delete[] ppSortedSprites;
    return true;
}

void THSpriteSheet::_makeSingleTex(sprite_t** ppSortedSprites, unsigned int iSize)
{
    IDirect3DTexture9 *pTexture = NULL;
    if(m_pDevice->CreateTexture(iSize, iSize, 1, 0, D3DFMT_A8R8G8B8,
        D3DPOOL_MANAGED, &pTexture, NULL) != D3D_OK || pTexture == NULL)
    {
        return;
    }
    D3DLOCKED_RECT rcLocked;
    if(pTexture->LockRect(0, &rcLocked, NULL, D3DLOCK_DISCARD) != D3D_OK)
    {
        pTexture->Release();
        return;
    }

    // Pass 1: Fill entirely transparent
    uint8_t* pData = reinterpret_cast<uint8_t*>(rcLocked.pBits);
    for(unsigned int y = 0; y < iSize; ++y, pData += rcLocked.Pitch)
    {
        uint32_t* pRow = reinterpret_cast<uint32_t*>(pData);
        for(unsigned int x = 0; x < iSize; ++x, ++pRow)
        {
            *pRow = D3DCOLOR_ARGB(0, 0, 0, 0);
        }
    }

    // Pass 2: Blit sprites onto sheet
    const uint32_t* pColours = m_pPalette->getARGBData();
    unsigned int iX = 0;
    unsigned int iY = 0;
    unsigned int iTallest = ppSortedSprites[0]->iHeight;
    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        sprite_t *pSprite = ppSortedSprites[i];
        if(pSprite->pData == NULL)
            break;

        pSprite->pBitmap = pTexture;
        if(iX + pSprite->iWidth > iSize)
        {
            iX = 0;
            iY += iTallest;
            iTallest = pSprite->iHeight;
        }
        pSprite->iSheetX = iX;
        pSprite->iSheetY = iY;
        iX += pSprite->iWidth;

        const unsigned char *pPixels = pSprite->pData;
        uint8_t* pData = reinterpret_cast<uint8_t*>(rcLocked.pBits);
        pData += pSprite->iSheetY * rcLocked.Pitch + pSprite->iSheetX * 4;
        for(unsigned int y = 0; y < pSprite->iHeight; ++y, pData += rcLocked.Pitch)
        {
            uint32_t* pRow = reinterpret_cast<uint32_t*>(pData);
            for(unsigned int x = 0; x < pSprite->iWidth; ++x, ++pRow, ++pPixels)
            {
                *pRow = pColours[*pPixels];
            }
        }
    }

    pTexture->UnlockRect(0);
    m_pMegaSheet = pTexture;
    m_iMegaSheetSize = iSize;
}

int THSpriteSheet::_sortSpritesHeight(const void* left, const void* right)
{
    const sprite_t *pLeft = *reinterpret_cast<const sprite_t* const*>(left);
    const sprite_t *pRight = *reinterpret_cast<const sprite_t* const*>(right);

    // Move all NULL datas to the end
    if(pLeft->pData == NULL || pRight->pData == NULL)
    {
        if(pLeft->pData == NULL && pRight->pData == NULL)
            return 0;
        if(pLeft->pData == NULL)
            return 1;
        else
            return -1;
    }

    // Sort from tallest to shortest
    return static_cast<int>(pRight->iHeight) - static_cast<int>(pLeft->iHeight);
}

bool THSpriteSheet::_tryFitSingleTex(sprite_t** ppSortedSprites, unsigned int iSize)
{
    // There are probably better algorithms for trying to fit lots of small
    // rectangular sprites onto a single square sheet, but sorting them by
    // height and then filling up one row at a time is simple and yields a good
    // enough result.

    unsigned int iX = 0;
    unsigned int iY = 0;
    unsigned int iTallest = ppSortedSprites[0]->iHeight;
    for(unsigned int i = 0; i < m_iSpriteCount; ++i)
    {
        sprite_t *pSprite = ppSortedSprites[i];
        if(pSprite->pData == NULL)
            break;
        if(pSprite->iWidth > iSize || pSprite->iHeight > iSize)
            return false;
        if(iX + pSprite->iWidth > iSize)
        {
            iX = 0;
            iY += iTallest;
            iTallest = pSprite->iHeight;
        }
        iX += pSprite->iWidth;
    }

    iY += iTallest;
    return iY <= iSize;
}

void THSpriteSheet::setSpriteAltPaletteMap(unsigned int iSprite, const unsigned char* pMap)
{
    if(iSprite >= m_iSpriteCount)
        return;

    sprite_t *pSprite = m_pSprites + iSprite;
    if(pSprite->pAltPaletteMap != pMap)
    {
        pSprite->pAltPaletteMap = pMap;
        if(pSprite->pAltBitmap)
        {
            pSprite->pAltBitmap->Release();
            pSprite->pAltBitmap = NULL;
        }
    }
}

unsigned int THSpriteSheet::getSpriteCount() const
{
    return m_iSpriteCount;
}

bool THSpriteSheet::getSpriteSize(unsigned int iSprite, unsigned int* pX, unsigned int* pY) const
{
    if(iSprite >= m_iSpriteCount)
        return false;
    if(pX != NULL)
        *pX = m_pSprites[iSprite].iWidth;
    if(pY != NULL)
        *pY = m_pSprites[iSprite].iHeight;
    return true;
}

void THSpriteSheet::getSpriteSizeUnchecked(unsigned int iSprite, unsigned int* pX, unsigned int* pY) const
{
    *pX = m_pSprites[iSprite].iWidth;
    *pY = m_pSprites[iSprite].iHeight;
}

bool THSpriteSheet::getSpriteAverageColour(unsigned int iSprite, THColour* pColour) const
{
    if(iSprite >= m_iSpriteCount)
        return false;
    const sprite_t *pSprite = m_pSprites + iSprite;
    int iCountTotal = 0;
    int iUsageCounts[256] = {0};
    for(unsigned int i = 0; i < pSprite->iWidth * pSprite->iHeight; ++i)
    {
        unsigned char cPalIndex = pSprite->pData[i];
        uint32_t iColour = m_pPalette->getARGBData()[cPalIndex];
        if((iColour >> 24) == 0)
            continue;
        // Grant higher score to pixels with high or low intensity (helps avoid grey fonts)
        unsigned char iR = static_cast<uint8_t> ((iColour >> 16) & 0xFF);
        unsigned char iG = static_cast<uint8_t> ((iColour >>  8) & 0xFF);
        unsigned char iB = static_cast<uint8_t> ((iColour >>  0) & 0xFF);
        unsigned char cIntensity = (unsigned char)(((int)iR + (int)iG + (int)iB) / 3);
        int iScore = 1 + max(0, 3 - ((255 - cIntensity) / 32)) + max(0, 3 - (cIntensity / 32));
        iUsageCounts[cPalIndex] += iScore;
        iCountTotal += iScore;
    }
    if(iCountTotal == 0)
        return false;
    int iHighestCountIndex = 0;
    for(int i = 0; i < 256; ++i)
    {
        if(iUsageCounts[i] > iUsageCounts[iHighestCountIndex])
            iHighestCountIndex = i;
    }
    *pColour = m_pPalette->getARGBData()[iHighestCountIndex];
    return true;
}

void THSpriteSheet::drawSprite(THRenderTarget* pCanvas, unsigned int iSprite, int iX, int iY, unsigned long iFlags)
{
    if(iSprite >= m_iSpriteCount || pCanvas == NULL)
        return;
    sprite_t *pSprite = m_pSprites + iSprite;

    // Find or create the texture
    IDirect3DTexture9 *pTexture = pSprite->pBitmap;
    if(pTexture == NULL)
    {
        if(pSprite->pData == NULL)
            return;

        pTexture = THDX9_CreateTexture(pSprite->iWidth, pSprite->iHeight,
            pSprite->pData, m_pPalette, m_pDevice);
        pSprite->pBitmap = pTexture;
    }
    if(iFlags & THDF_AltPalette)
    {
        pTexture = pSprite->pAltBitmap;
        if(pTexture == NULL)
        {
            pTexture = _makeAltBitmap(pSprite);
            if(pTexture == NULL)
                return;
        }
    }

    if(pTexture == m_pMegaSheet)
    {
        pCanvas->draw(pTexture, m_pSprites[iSprite].iWidth,
            m_pSprites[iSprite].iHeight, iX, iY, iFlags, m_iMegaSheetSize,
            m_iMegaSheetSize, m_pSprites[iSprite].iSheetX,
            m_pSprites[iSprite].iSheetY);
    }
    else
    {
        pCanvas->draw(pTexture, m_pSprites[iSprite].iWidth,
            m_pSprites[iSprite].iHeight, iX, iY, iFlags,
            m_pSprites[iSprite].iWidth2, m_pSprites[iSprite].iHeight2, 0, 0);
    }
}

bool THSpriteSheet::hitTestSprite(unsigned int iSprite, int iX, int iY, unsigned long iFlags) const
{
    if(iX < 0 || iY < 0 || iSprite >= m_iSpriteCount)
        return false;
    int iWidth = m_pSprites[iSprite].iWidth;
    int iHeight = m_pSprites[iSprite].iHeight;
    if(iX >= iWidth || iY >= iHeight)
        return false;
    if(iFlags & THDF_FlipHorizontal)
        iX = iWidth - iX - 1;
    if(iFlags & THDF_FlipVertical)
        iY = iHeight - iY - 1;
    return (m_pPalette->getARGBData()
        [m_pSprites[iSprite].pData[iY * iWidth + iX]] >> 24) != 0;
}

void THRenderTarget::draw(IDirect3DTexture9 *pTexture, unsigned int iWidth,
                          unsigned int iHeight, int iX, int iY,
                          unsigned long iFlags, unsigned int iWidth2,
                          unsigned int iHeight2, unsigned int iTexX,
                          unsigned int iTexY, D3DCOLOR cColour)
{
    // Crop to clip rectangle
    RECT rcSource;
    rcSource.left = 0;
    rcSource.top = 0;
    rcSource.right = iWidth;
    rcSource.bottom = iHeight;
    if(iX + rcSource.right > m_rcClip.x + m_rcClip.w)
    {
        rcSource.right = m_rcClip.x + m_rcClip.w - iX;
    }
    if(iY + rcSource.bottom > m_rcClip.y + m_rcClip.h)
    {
        rcSource.bottom = m_rcClip.y + m_rcClip.h - iY;
    }
    if(iX + rcSource.left < m_rcClip.x)
    {
        rcSource.left = m_rcClip.x - iX;
        iX = m_rcClip.x;
    }
    if(iY + rcSource.top < m_rcClip.y)
    {
        rcSource.top = m_rcClip.y - iY;
        iY = m_rcClip.y;
    }
    if(rcSource.right < rcSource.left)
        rcSource.right = rcSource.left;
    if(rcSource.bottom < rcSource.top)
        rcSource.bottom = rcSource.top;

    rcSource.left += iTexX;
    rcSource.right += iTexX;
    rcSource.bottom += iTexY;
    rcSource.top += iTexY;

    // Set alpha blending options
    switch(iFlags & (THDF_Alpha50 | THDF_Alpha75))
    {
    case 0:
        cColour |= 0xFF000000UL;
        break;
    case THDF_Alpha50:
        cColour |= 0x80000000UL;
        break;
    default:
        cColour |= 0x40000000UL;
        break;
    }
    float fX = (float)iX;
    float fY = (float)iY;
    float fWidth = (float)(rcSource.right - rcSource.left);
    float fHeight = (float)(rcSource.bottom - rcSource.top);
    float fSprWidth = (float)iWidth2;
    float fSprHeight = (float)iHeight2;
    if(iFlags & THDF_FlipHorizontal)
    {
        rcSource.left = iTexX * 2 + iWidth - rcSource.left;
        rcSource.right = iTexX * 2 + iWidth - rcSource.right;
    }
    if(iFlags & THDF_FlipVertical)
    {
        rcSource.top = iTexY * 2 + iHeight - rcSource.top;
        rcSource.bottom = iTexY * 2 + iHeight - rcSource.bottom;
    }

#define SetVertexData(n, x_, y_, u_, v_) \
    pVerticies[n].x = fX + (float) x_; \
    pVerticies[n].y = fY + (float) y_; \
    pVerticies[n].z = 0.0f; \
    pVerticies[n].colour = cColour; \
    pVerticies[n].u = (float) u_; \
    pVerticies[n].v = (float) v_

    THDX9_Vertex *pVerticies = allocVerticies(4, pTexture);
    SetVertexData(0, 0, 0, rcSource.left / fSprWidth, rcSource.top / fSprHeight);
    SetVertexData(1, fWidth, 0, rcSource.right  / fSprWidth, pVerticies[0].v);
    SetVertexData(2, fWidth, fHeight, pVerticies[1].u, rcSource.bottom / fSprHeight);
    SetVertexData(3, 0, fHeight, pVerticies[0].u, pVerticies[2].v);
#undef SetVertexData
}

uint16_t gs_iIndexLUT[6] = {0, 1, 2, 0, 2, 3};

void THDX9_FillIndexBuffer(uint16_t* pVerticies, size_t iFirst, size_t iCount)
{
    for(; iCount > 0; ++iFirst, --iCount)
    {
        size_t iMod = iFirst % 6;
        size_t iBase = (iFirst / 6) * 4;
        pVerticies[iFirst] = static_cast<uint16_t>(iBase) + gs_iIndexLUT[iMod];
    }
}

IDirect3DTexture9* THSpriteSheet::_makeAltBitmap(sprite_t *pSprite)
{
    if(pSprite->pAltPaletteMap == NULL)
    {
        pSprite->pAltBitmap = pSprite->pBitmap;
        pSprite->pAltBitmap->AddRef();
    }
    else
    {
        int iPixelCount = pSprite->iHeight * pSprite->iWidth;
        unsigned char *pData = new unsigned char[iPixelCount];
        for(int i = 0; i < iPixelCount; ++i)
        {
            unsigned char iPixel = pSprite->pData[i];
            if(iPixel != 0xFF)
                iPixel = pSprite->pAltPaletteMap[iPixel];
            pData[i] = iPixel;
        }
        pSprite->pAltBitmap = THDX9_CreateTexture(pSprite->iWidth,
            pSprite->iHeight, pData, m_pPalette, m_pDevice);
        delete[] pData;
    }
    return pSprite->pAltBitmap;
}

THCursor::THCursor()
{
    fnOnDeviceChange = THDX9_OnDeviceChangeThunk<THCursor>;
    m_pBitmap = NULL;
    m_iHotspotX = 0;
    m_iHotspotY = 0;
    m_bHardwareCompatible = false;
}

THCursor::~THCursor()
{
    if(m_pBitmap)
        m_pBitmap->Release();
}

void THCursor::onDeviceChange(eTHDX9DeviceChangeType eChangeType)
{
    if(m_pBitmap)
    {
        m_pBitmap->Release();
        m_pBitmap = NULL;
    }
    removeFromList();
}

bool THCursor::createFromSprite(THSpriteSheet* pSheet, unsigned int iSprite,
                                int iHotspotX, int iHotspotY)
{
    if(m_pBitmap)
        m_pBitmap->Release();
    m_pBitmap = NULL;
    m_bHardwareCompatible = false;
    removeFromList();

    if(iHotspotX < 0 || iHotspotY < 0)
        return false;

    unsigned int iWidth, iHeight;
    if(pSheet == NULL || !pSheet->getSpriteSize(iSprite, &iWidth, &iHeight)
    || pSheet->m_pDevice == NULL)
    {
        return false;
    }

    m_pPrev = pSheet->m_pPrev;
    m_pNext = pSheet;
    m_pPrev->m_pNext = this;
    m_pNext->m_pPrev = this;

    // Hardware cursors must be size 32x32
    unsigned int iSize = 32;
    if(iWidth > 32 || iHeight > 32)
    {
        m_bHardwareCompatible = false;
        while(iSize < iWidth || iSize < iHeight)
            iSize <<= 1;
    }
    else
        m_bHardwareCompatible = true;

    if(pSheet->m_pDevice->CreateOffscreenPlainSurface(iSize, iSize,
        D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, &m_pBitmap, NULL) != D3D_OK)
    {
        return false;
    }

    D3DLOCKED_RECT rcLocked;
    if(m_pBitmap->LockRect(&rcLocked, NULL, D3DLOCK_DISCARD) != D3D_OK)
    {
        m_pBitmap->Release();
        m_pBitmap = NULL;
        return false;
    }

    const unsigned char* pPixels = pSheet->m_pSprites[iSprite].pData;
    uint8_t* pData = reinterpret_cast<uint8_t*>(rcLocked.pBits);
    const uint32_t* pColours = pSheet->m_pPalette->getARGBData();
    for(unsigned int y = 0; y < iHeight; ++y, pData += rcLocked.Pitch)
    {
        uint32_t* pRow = reinterpret_cast<uint32_t*>(pData);
        for(unsigned int x = 0; x < iWidth; ++x, ++pPixels, ++pRow)
        {
            uint32_t iColour = pColours[*pPixels];
            // Cursors cannot have semi-transparency
            if((iColour >> 24) != 0)
                iColour |= 0xFF000000;
            *pRow = iColour;
        }
        for(unsigned int x = iWidth; x < iSize; ++x, ++pRow)
        {
            *pRow = D3DCOLOR_ARGB(0, 0, 0, 0);
        }
    }
    for(unsigned int y = iHeight; y < iSize; ++y, pData += rcLocked.Pitch)
    {
        uint32_t* pRow = reinterpret_cast<uint32_t*>(pData);
        for(unsigned int x = 0; x < iSize; ++x, ++pRow)
        {
            *pRow = D3DCOLOR_ARGB(0, 0, 0, 0);
        }
    }

    m_pBitmap->UnlockRect();
    return true;
}

void THRenderTarget::setCursor(THCursor* pCursor)
{
    SetCursor(NULL);
    m_pDevice->SetCursorProperties(pCursor->m_iHotspotX,
        pCursor->m_iHotspotY, pCursor->m_pBitmap);
    m_pDevice->ShowCursor(TRUE);
    m_pCursor = pCursor;
    m_bIsCursorInHardware = m_bIsWindowed || (m_bIsHardwareCursorSupported &&
        pCursor->m_bHardwareCompatible);
}

void THCursor::use(THRenderTarget* pTarget)
{
    pTarget->setCursor(this);
}

bool THRenderTarget::setCursorPosition(int iX, int iY)
{
    if(m_bIsCursorInHardware)
    {
        // Cursor movement done by operating system / hardware - no need to do
        // anything or repaint anything.
        return false;
    }

    m_pDevice->SetCursorPosition(iX, iY, 0);
    return true;
}

bool THCursor::setPosition(THRenderTarget* pTarget, int iX, int iY)
{
    return pTarget->setCursorPosition(iX, iY);
}

THLine::THLine()
{
    initialize();
}

void THLine::initialize()
{
    m_fWidth = 1;
    m_iR = 0;
    m_iG = 0;
    m_iB = 0;
    m_iA = 255;

    // We start at 0,0
    m_pFirstOp = new THLineOperation(THLOP_MOVE, 0, 0);
    m_pCurrentOp = m_pFirstOp;
}


THLine::~THLine()
{
    THLineOperation* op = m_pFirstOp;
    while (op) {
        THLineOperation* next = (THLineOperation*)(op->m_pNext);
        delete(op);
        op = next;
    }
}

void THLine::moveTo(double fX, double fY)
{
    THLineOperation* previous = m_pCurrentOp;
    m_pCurrentOp = new THLineOperation(THLOP_MOVE, fX, fY);
    previous->m_pNext = m_pCurrentOp;
}

void THLine::lineTo(double fX, double fY)
{
    THLineOperation* previous = m_pCurrentOp;
    m_pCurrentOp = new THLineOperation(THLOP_LINE, fX, fY);
    previous->m_pNext = m_pCurrentOp;
}

void THLine::setWidth(double pLineWidth)
{
    m_fWidth = pLineWidth;
}

void THLine::setColour(uint8_t iR, uint8_t iG, uint8_t iB, uint8_t iA)
{
    m_iR = iR;
    m_iG = iG;
    m_iB = iB;
    m_iA = iA;
}

void THLine::draw(THRenderTarget* pCanvas, int iX, int iY)
{
    pCanvas->flushSprites(); // Without this the lines are draw behind sprites/textures

    IDirect3DDevice9* device = pCanvas->getRawDevice();
    device->BeginScene();

    double lastX, lastY;
    lastX = m_pFirstOp->m_fX;
    lastY = m_pFirstOp->m_fY;

    D3DCOLOR colour = D3DCOLOR_ARGB(m_iA, m_iR, m_iG, m_iB);

    LPD3DXLINE line = NULL;
    THLineOperation* op = (THLineOperation*)(m_pFirstOp->m_pNext);
    while (op) {
        if (op->type == THLOP_LINE) {
            if (!line) {
                D3DXCreateLine(device, &line);
                line->SetWidth(m_fWidth);
                line->Begin();
            }

            D3DXVECTOR2 lineVec[] = {D3DXVECTOR2(lastX + iX, lastY +iY), D3DXVECTOR2(op->m_fX + iX, op->m_fY + iY)};
            line->Draw(lineVec, 2, colour);

        } if (op->type == THLOP_MOVE && line) {
            line->End();
            line->Release();
            line = NULL;
        }

        lastX = op->m_fX;
        lastY = op->m_fY;

        op = (THLineOperation*)(op->m_pNext);
    }

    if (line) {
        line->End();
        line->Release();
    }

    device->EndScene();
}

void THLine::persist(LuaPersistWriter *pWriter) const
{
    pWriter->writeVUInt((uint32_t)m_iR);
    pWriter->writeVUInt((uint32_t)m_iG);
    pWriter->writeVUInt((uint32_t)m_iB);
    pWriter->writeVUInt((uint32_t)m_iA);
    pWriter->writeVFloat(m_fWidth);

    THLineOperation* op = (THLineOperation*)(m_pFirstOp->m_pNext);
    uint32_t numOps = 0;
    for (; op; numOps++) {
        op = (THLineOperation*)(op->m_pNext);
    }

    pWriter->writeVUInt(numOps);

    op = (THLineOperation*)(m_pFirstOp->m_pNext);
    while (op) {
        pWriter->writeVUInt((uint32_t)op->type);
        pWriter->writeVFloat<double>(op->m_fX);
        pWriter->writeVFloat(op->m_fY);

        op = (THLineOperation*)(op->m_pNext);
    }
}

void THLine::depersist(LuaPersistReader *pReader)
{
    initialize();

    pReader->readVUInt(m_iR);
    pReader->readVUInt(m_iG);
    pReader->readVUInt(m_iB);
    pReader->readVUInt(m_iA);
    pReader->readVFloat(m_fWidth);

    uint32_t numOps = 0;
    pReader->readVUInt(numOps);
    for (uint32_t i = 0; i < numOps; i++) {
        THLineOpType type;
        double fX, fY;
        pReader->readVUInt((uint32_t&)type);
        pReader->readVFloat(fX);
        pReader->readVFloat(fY);

        if (type == THLOP_MOVE) {
            moveTo(fX, fY);
        } else if (type == THLOP_LINE) {
            lineTo(fX, fY);
        }
    }
}

#ifdef CORSIX_TH_USE_FREETYPE2
bool THFreeTypeFont::_isMonochrome() const
{
    return false;
}

void THFreeTypeFont::_setNullTexture(cached_text_t* pCacheEntry) const
{
    pCacheEntry->pTexture = NULL;
}

class THDX9_FontTexture : public THDX9_DeviceResource
{
public:
    THDX9_FontTexture()
    {
        fnOnDeviceChange = THDX9_OnDeviceChangeThunk<THDX9_FontTexture>;
        m_pDevice = NULL;
        m_pTexture = NULL;
        m_pData = NULL;
        m_iWidth = 0;
        m_iHeight = 0;
    }

    ~THDX9_FontTexture()
    {
        if(m_pTexture != NULL)
            m_pTexture->Release();
    }

    void make(unsigned char* pData, int iWidth, int iHeight)
    {
        m_pData = pData;
        m_iWidth = iWidth;
        m_iHeight = iHeight;
        if(m_pTexture != NULL)
        {
            m_pTexture->Release();
            m_pTexture = NULL;
            m_pDevice = NULL;
        }
        removeFromList();
    }

    void onDeviceChange(eTHDX9DeviceChangeType eChangeType)
    {
        if(m_pTexture)
        {
            m_pTexture->Release();
            m_pTexture = NULL;
        }
        removeFromList();
    }

    void draw(THRenderTarget* pCanvas, int iX, int iY, uint32_t iColour)
    {
        if(m_pTexture == NULL || pCanvas->getRawDevice() != m_pDevice)
        {
            _makeFor(pCanvas);
        }
        if(m_pTexture)
        {
            if(m_bIsA8Texture)
            {
                pCanvas->flushSprites();
                m_pDevice->SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_CURRENT);
            }
            pCanvas->draw(m_pTexture, m_iWidth, m_iHeight, iX, iY, 0, m_iWidth2, m_iHeight2, 0, 0, iColour & 0xFFFFFF);
            pCanvas->flushSprites();
            if(m_bIsA8Texture)
            {
                m_pDevice->SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
            }
        }
    }

protected:
    static int _roundUp2(int x)
    {
        int rounded = 1;
        while(rounded < x)
            rounded <<= 1;
        return rounded;
    }

    void _makeFor(THRenderTarget* pCanvas)
    {
        removeFromList();
        if(m_pTexture != NULL)
        {
            m_pTexture->Release();
            m_pTexture = NULL;
        }
        m_pDevice = pCanvas->getRawDevice(this);

        D3DCAPS9 oCaps;
        bool bGotCaps = SUCCEEDED(m_pDevice->GetDeviceCaps(&oCaps));

        // Get power of 2 sizes
        m_iWidth2 = _roundUp2(m_iWidth);
        m_iHeight2 = _roundUp2(m_iHeight);
        if(m_iWidth2 != m_iHeight2 && (!bGotCaps
        || (oCaps.TextureCaps & D3DPTEXTURECAPS_SQUAREONLY)))
        {
            if(m_iWidth2 < m_iHeight2)
                m_iWidth2 = m_iHeight2;
            else
                m_iHeight2 = m_iWidth2;
        }

        // Check aspect ratio
        if(bGotCaps)
        {
            if(m_iWidth2 < m_iHeight2)
            {
                if(m_iHeight2 / m_iWidth2 > static_cast<int>(oCaps.MaxTextureAspectRatio))
                    m_iWidth2 = _roundUp2(m_iHeight2 / oCaps.MaxTextureAspectRatio);
            }
            else
            {
                if(m_iWidth2 / m_iHeight2 > static_cast<int>(oCaps.MaxTextureAspectRatio))
                    m_iHeight2 = _roundUp2(m_iWidth2 / oCaps.MaxTextureAspectRatio);
            }
        }

        // Make the texture
        if(SUCCEEDED(m_pDevice->CreateTexture(m_iWidth2, m_iHeight2, 1, 0,
            D3DFMT_A8, D3DPOOL_MANAGED, &m_pTexture, NULL)))
        {
            m_bIsA8Texture = true;
        }
        else if(SUCCEEDED(m_pDevice->CreateTexture(m_iWidth2, m_iHeight2, 1,
            0, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, &m_pTexture, NULL)))
        {
            m_bIsA8Texture = false;
        }
        else
        {
            return;
        }

        // Copy in texture data
        D3DLOCKED_RECT rcLocked;
        if(m_pTexture->LockRect(0, &rcLocked, NULL, D3DLOCK_DISCARD) != D3D_OK)
        {
            m_pTexture->Release();
            m_pTexture = NULL;
            return;
        }
        const unsigned char* pInRow = m_pData;
        unsigned char* pOutRow = reinterpret_cast<unsigned char*>(rcLocked.pBits);
        for(int iY = 0; iY < m_iHeight; ++iY, pInRow += m_iWidth, pOutRow += rcLocked.Pitch)
        {
            if(m_bIsA8Texture)
            {
                memcpy(pOutRow, pInRow, m_iWidth);
            }
            else
            {
                uint32_t iColour;
                for(int iX = 0; iX < m_iWidth; ++iX)
                {
                    iColour = (static_cast<uint32_t>(pInRow[iX]) << 24) | 0xffffff;
                    reinterpret_cast<uint32_t*>(pOutRow)[iX] = iColour;
                }
            }
        }
        m_pTexture->UnlockRect(0);
    }

    IDirect3DDevice9* m_pDevice;
    IDirect3DTexture9* m_pTexture;
    const unsigned char* m_pData;
    int m_iWidth;
    int m_iWidth2;
    int m_iHeight;
    int m_iHeight2;
    bool m_bIsA8Texture;
};

void THFreeTypeFont::_freeTexture(cached_text_t* pCacheEntry) const
{
    if(pCacheEntry->pTexture != NULL)
    {
        delete reinterpret_cast<THDX9_FontTexture*>(pCacheEntry->pTexture);
    }
}

void THFreeTypeFont::_makeTexture(cached_text_t* pCacheEntry) const
{
    THDX9_FontTexture *pTexture = new THDX9_FontTexture;
    pTexture->make(pCacheEntry->pData, pCacheEntry->iWidth, pCacheEntry->iHeight);
    pCacheEntry->pTexture = reinterpret_cast<void*>(pTexture);
}

void THFreeTypeFont::_drawTexture(THRenderTarget* pCanvas, cached_text_t* pCacheEntry, int iX, int iY) const
{
    if(pCacheEntry->pTexture == NULL)
        return;
    reinterpret_cast<THDX9_FontTexture*>(pCacheEntry->pTexture)->draw(pCanvas, iX, iY, m_oColour);
}
#endif // CORSIX_TH_USE_FREETYPE2

#endif // CORSIX_TH_USE_DX9_RENDERER
