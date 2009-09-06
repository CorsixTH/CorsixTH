/*
Copyright (c) 2009 Peter "Corsix" Cawley

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
#include "th_lua.h"
#include "th_gfx_dx9.h"
#include <string.h>
#include <windows.h>
#include <SDL.h>
#include <SDL_syswm.h>
#include <D3D9.h>
#ifndef _MSC_VER
#define stricmp strcasecmp
#else
#pragma warning(disable: 4996) // Deprecated CRT
#endif

struct l_surface_t
{
    // Start the structure with a pointer to itself for things which
    // want to dethunk it.
    THRenderTarget* target_p;
    THRenderTarget target;

    l_surface_t()
    {
        target_p = &target;
    }
};

static l_surface_t* l_check_surface(lua_State *L, int idx)
{
    return luaT_testuserdata<l_surface_t, false>(L, idx, LUA_ENVIRONINDEX, "Surface");
}

static int l_ensure_hw_surface(lua_State *L)
{
    // DX9 surfaces are always hardware surfaces
    lua_pushboolean(L, 1);
    return 1;
}

static int l_start_frame(lua_State *L)
{
    l_surface_t *pSurface = l_check_surface(L, 1);
    if(pSurface->target.pDevice)
    {
        pSurface->target.pDevice->Clear(0, NULL, D3DCLEAR_TARGET,
            D3DCOLOR_XRGB(0, 0, 0), 1.0f, 0);
        pSurface->target.pDevice->BeginScene();
    }
    return 0;
}

static int l_end_frame(lua_State *L)
{
    l_surface_t *pSurface = l_check_surface(L, 1);
    if(pSurface->target.pDevice)
    {
        THDX9_FlushSprites(pSurface->target_p);
        pSurface->target.pDevice->EndScene();
        pSurface->target.pDevice->Present(NULL,NULL,NULL,NULL);
    }
    return 0;
}

static int l_set_mode(lua_State *L)
{
#define err(msg, ...) do { \
    lua_pushnil(L); \
    lua_pushfstring(L, msg, ## __VA_ARGS__); \
    return 2; } while(0)

    int iWidth, iHeight, iBPP, iArg, iArgCount;
    Uint32 iSDLFlags = 0;
    UINT iPresentInterval = D3DPRESENT_INTERVAL_DEFAULT;
    THRenderTarget oTarget;

    iWidth = luaL_checkint(L, 1);
    iHeight = luaL_checkint(L, 2);
    if(lua_type(L, 3) == LUA_TNUMBER)
    {
        iBPP = luaL_checkint(L, 3);
        iArg = 4;
    }
    else
    {
        iBPP = 0;
        iArg = 3;
    }
    iArgCount = lua_gettop(L);

    for(; iArg <= iArgCount; ++iArg)
    {
        const char* option = luaL_checkstring(L, iArg);
        if(*option == 0)
            continue;
        else if(stricmp(option, "hardware") == 0)
            iSDLFlags |= SDL_HWSURFACE;
        else if(stricmp(option, "doublebuf") == 0)
            iSDLFlags |= SDL_DOUBLEBUF;
        else if(stricmp(option, "fullscreen") == 0)
            iSDLFlags |= SDL_FULLSCREEN;
        else if(stricmp(option, "present immediate") == 0)
            iPresentInterval = D3DPRESENT_INTERVAL_IMMEDIATE;
    }

    SDL_Surface *pSDLSurface = SDL_SetVideoMode(iWidth, iHeight, iBPP, iSDLFlags);
    if(pSDLSurface == NULL)
        err("Could not set SDL video mode (%ix%ix%i)", iWidth, iHeight, iBPP);

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
        err("Could not get HWND from SDL");
    
    oTarget.pD3D = Direct3DCreate9(D3D_SDK_VERSION);
    if(oTarget.pD3D == NULL)
        err("Could not create Direct3D object");

    D3DDISPLAYMODE d3ddm;
	if(oTarget.pD3D->GetAdapterDisplayMode(D3DADAPTER_DEFAULT, &d3ddm) != D3D_OK)
        err("Could not query display adapter");

    D3DCAPS9 d3dCaps;
	ZeroMemory(&d3dCaps, sizeof(d3dCaps));
	D3DDEVTYPE eDeviceTypeToUse = D3DDEVTYPE_HAL;
    if(oTarget.pD3D->GetDeviceCaps(D3DADAPTER_DEFAULT, eDeviceTypeToUse, &d3dCaps) != D3D_OK)
	{
		eDeviceTypeToUse = D3DDEVTYPE_SW;
		if(oTarget.pD3D->GetDeviceCaps(D3DADAPTER_DEFAULT, eDeviceTypeToUse, &d3dCaps) != D3D_OK)
		{
			eDeviceTypeToUse = D3DDEVTYPE_REF;
			if(oTarget.pD3D->GetDeviceCaps(D3DADAPTER_DEFAULT, eDeviceTypeToUse, &d3dCaps) != D3D_OK)
			{
				err("Could not get DirectX device capabilities for HAL, SW or REF");
			}
		}
	}

    D3DPRESENT_PARAMETERS oPresentParams;
	ZeroMemory(&oPresentParams, sizeof(oPresentParams));
	oPresentParams.SwapEffect = D3DSWAPEFFECT_DISCARD;
	oPresentParams.EnableAutoDepthStencil = false;
	oPresentParams.AutoDepthStencilFormat = D3DFMT_D16;
	oPresentParams.hDeviceWindow = hWindow;
	oPresentParams.BackBufferCount = 1;
    oPresentParams.Windowed = (iSDLFlags & SDL_FULLSCREEN) ? false : true;
	oPresentParams.BackBufferWidth = iWidth;
	oPresentParams.BackBufferHeight = iHeight;
	oPresentParams.BackBufferFormat = d3ddm.Format;
    oPresentParams.PresentationInterval = iPresentInterval;

    DWORD dwBehaviour = D3DCREATE_FPU_PRESERVE; // For Lua
    if(d3dCaps.DevCaps & D3DDEVCAPS_HWTRANSFORMANDLIGHT)
        dwBehaviour |= D3DCREATE_HARDWARE_VERTEXPROCESSING;
    else
        dwBehaviour |= D3DCREATE_SOFTWARE_VERTEXPROCESSING;

    if(FAILED(oTarget.pD3D->CreateDevice(D3DADAPTER_DEFAULT, eDeviceTypeToUse,
        hWindow, dwBehaviour, &oPresentParams, &oTarget.pDevice)))
    {
        err("Could not create device");
    }

    oTarget.iVertexCount = 0;
    oTarget.iVertexLength = 768;
    oTarget.pVerticies = (THDX9_Vertex*)malloc(sizeof(THDX9_Vertex) * oTarget.iVertexLength);
    if(oTarget.pVerticies == NULL)
        err("Could not allocate vertex buffer");
    oTarget.iNonOverlapping = 0;
    if(oTarget.pDevice->SetFVF(D3DFVF_XYZ | D3DFVF_DIFFUSE | D3DFVF_TEX1) != D3D_OK)
        err("Could not set the DirectX fixed function vertex type");

    oTarget.pDevice->SetRenderState(D3DRS_ZENABLE, FALSE);
    oTarget.pDevice->SetRenderState(D3DRS_ALPHABLENDENABLE, TRUE);
    oTarget.pDevice->SetRenderState(D3DRS_CLIPPING, FALSE);
    oTarget.pDevice->SetRenderState(D3DRS_COLORWRITEENABLE, D3DCOLORWRITEENABLE_ALPHA | D3DCOLORWRITEENABLE_RED | D3DCOLORWRITEENABLE_GREEN | D3DCOLORWRITEENABLE_BLUE);
    oTarget.pDevice->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
    oTarget.pDevice->SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
    oTarget.pDevice->SetRenderState(D3DRS_LIGHTING, FALSE);
    oTarget.pDevice->SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
    oTarget.pDevice->SetRenderState(D3DRS_LOCALVIEWER, FALSE);
    oTarget.pDevice->SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
    oTarget.pDevice->SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE);
    oTarget.pDevice->SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
    oTarget.pDevice->SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
    oTarget.pDevice->SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
    oTarget.pDevice->SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, 0);
    oTarget.pDevice->SetTextureStageState(1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
    oTarget.pDevice->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
    oTarget.pDevice->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);
    if(d3dCaps.TextureFilterCaps & D3DPTFILTERCAPS_MAGFANISOTROPIC)
        oTarget.pDevice->SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_ANISOTROPIC);
    else
        oTarget.pDevice->SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
    oTarget.pDevice->SetSamplerState(0, D3DSAMP_MAXANISOTROPY, d3dCaps.MaxAnisotropy);
    if(d3dCaps.TextureFilterCaps & D3DPTFILTERCAPS_MINFANISOTROPIC)
        oTarget.pDevice->SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_ANISOTROPIC);
    else
        oTarget.pDevice->SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
    if(d3dCaps.TextureFilterCaps & D3DPTFILTERCAPS_MIPFLINEAR)
        oTarget.pDevice->SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
    else
        oTarget.pDevice->SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_POINT);

    D3DMATRIX mtxIdentity = {
        1.0f, 0.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f};

    if(oTarget.pDevice->SetTransform(D3DTS_WORLD, &mtxIdentity) != D3D_OK)
        err("Could not set DirectX world transform matrix");
    if(oTarget.pDevice->SetTransform(D3DTS_VIEW, &mtxIdentity) != D3D_OK)
        err("Could not set DirectX view transform matrix");

    float fWidth = (float)iWidth;
    float fHeight = (float)iHeight;

    // Change the meaning of the identity matrix to the matrix required to make
    // world space identical to screen space.
    mtxIdentity.m[0][0] = 2.0f / fWidth;
    mtxIdentity.m[1][1] = -2.0f / fHeight;
    mtxIdentity.m[3][0] = -1.0f - (1.0f / fWidth);
    mtxIdentity.m[3][1] =  1.0f + (1.0f / fHeight);

    if(oTarget.pDevice->SetTransform(D3DTS_PROJECTION, &mtxIdentity) != D3D_OK)
        err("Could not set DirectX projection transform matrix");

    THDX9_FillIndexBuffer(oTarget.aiVertexIndicies, 0, THDX9_INDEX_BUFFER_LENGTH);

	if((oTarget.pWhiteTexture = THDX9_CreateSolidTexture(1, 1,
		D3DCOLOR_ARGB(0xFF, 0xFF, 0xFF, 0xFF), oTarget.pDevice)) == NULL)
	{
		err("Could not create reference texture");
	}

#undef err

    l_surface_t *pSurface = luaT_new(L, l_surface_t);
    lua_pushvalue(L, LUA_ENVIRONINDEX);
    lua_setmetatable(L, -2);
    pSurface->target = oTarget;
    oTarget.pD3D = NULL;
    oTarget.pDevice = NULL;
    oTarget.pVerticies = NULL;
	oTarget.pWhiteTexture = NULL;
    return 1;
}

static int l_free(lua_State *L)
{
    l_surface_t *pSurface = l_check_surface(L, 1);
    pSurface->target.~THRenderTarget();
    return 0;
}

static int l_fill_black(lua_State *L)
{
    l_surface_t *pSource = l_check_surface(L, 1);
    if(pSource->target.pDevice)
    {
        pSource->target.pDevice->Clear(0, NULL, D3DCLEAR_TARGET,
            D3DCOLOR_ARGB(0xFF, 0, 0, 0), 0.0f, 0);
    }
    lua_settop(L, 1);
    return 1;
}

static int l_non_overlapping(lua_State *L)
{
    l_surface_t *pSource = l_check_surface(L, 1);
    if(lua_isnone(L, 2) || lua_toboolean(L, 2) != 0)
        THRenderTarget_StartNonOverlapping(pSource->target_p);
    else
        THRenderTarget_FinishNonOverlapping(pSource->target_p);
    return 0;
}

static int l_map_rgb(lua_State *L)
{
	lua_pushnumber(L, (lua_Number)D3DCOLOR_ARGB(0xFF,
		(uint8_t)luaL_checkinteger(L, 2),
		(uint8_t)luaL_checkinteger(L, 3),
		(uint8_t)luaL_checkinteger(L, 4)));
	return 1;
}

static int l_fill_rect(lua_State *L)
{
	l_surface_t *pSource = l_check_surface(L, 1);
	Uint32 iColour = (Uint32)luaL_checknumber(L, 2);
	int iX = luaL_checkint(L, 3);
	int iY = luaL_checkint(L, 4);
	int iW = luaL_checkint(L, 5);
	int iH = luaL_checkint(L, 6);
	THDX9_Draw(pSource->target_p, pSource->target.pWhiteTexture, iW, iH, iX,
		iY, 0, 1, 1, 0, 0);
	THDX9_Vertex *pVerts = pSource->target.pVerticies;
	for(size_t i = 1; i <= 4; ++i)
	{
		pVerts[pSource->target.iVertexCount - i].colour = iColour;
	}
	return 0;
}

static const struct luaL_reg sdl_videolib[] = {
    {"ensureHardwareSurface", l_ensure_hw_surface},
    {"setMode", l_set_mode},
    {"fillBlack", l_fill_black},
    {"startFrame", l_start_frame},
    {"nonOverlapping", l_non_overlapping},
    {"endFrame", l_end_frame},
	{"mapRGB", l_map_rgb},
	{"drawRect", l_fill_rect},
    {NULL, NULL}
};

int luaopen_sdl_video(lua_State *L)
{
    lua_settop(L, 0);
    lua_newtable(L);
    lua_pushvalue(L, 1);
    lua_replace(L, LUA_ENVIRONINDEX);

    lua_pushliteral(L, "Surface_meta");
    lua_pushvalue(L, 1);
    lua_settable(L, LUA_REGISTRYINDEX);

    lua_pushliteral(L, "__gc");
    lua_pushcfunction(L, l_free);
    lua_settable(L, -3);

    lua_newtable(L);
    lua_pushliteral(L, "__index");
    lua_pushvalue(L, -2);
    lua_settable(L, 1);
    luaL_register(L, NULL, sdl_videolib);

    return 1;
}

#endif // CORSIX_TH_USE_DX9_RENDERER
