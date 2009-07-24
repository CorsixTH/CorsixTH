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
#include "th_lua.h"
#include "th_gfx_dx9.h"
#include <windows.h>
#include <string.h>
#include <SDL.h>
#include <SDL_syswm.h>
#include <D3D9.h>
#include <D3DX9.h>
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
    bool own_device;
    bool own_texture;

    l_surface_t()
    {
        target_p = &target;
        own_device = false;
        own_texture = false;
    }
};

static l_surface_t* l_check_surface(lua_State *L, int idx)
{
    return luaT_testuserdata<l_surface_t, false>(L, idx, LUA_ENVIRONINDEX, "Surface");
}

static int l_get_height(lua_State *L)
{
    l_surface_t *pSurface = l_check_surface(L, 1);
    D3DSURFACE_DESC oDesc;
    if(pSurface->target.pTexture == NULL)
        return luaL_typerror(L, 1, "Surface");
    if(pSurface->target.pTexture->GetLevelDesc(0, &oDesc) != D3D_OK)
        return luaL_error(L, "Unable to get surface descriptor");
    lua_pushinteger(L, oDesc.Height);
    return 1;
}

static int l_ensure_hw_surface(lua_State *L)
{
    // DX9 surfaces are always hardware surfaces
    lua_pushboolean(L, 1);
    return 1;
}

static int l_load_bmp(lua_State *L)
{
    const char* sFilename = luaL_checkstring(L, 1);
    l_surface_t *pTarget = l_check_surface(L, 2);
    if(pTarget->target.pDevice == NULL)
        return luaL_argerror(L, 2, "VideoSurface");

    IDirect3DDevice9 *pDevice = pTarget->target.pDevice;

    IDirect3DTexture9 *pTexture = NULL;
    if(D3DXCreateTextureFromFileExA(pDevice, sFilename, D3DX_DEFAULT,
        D3DX_DEFAULT, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, D3DX_FILTER_NONE,
        D3DX_FILTER_NONE, D3DCOLOR_ARGB(0xFF, 0xFF, 0, 0xFF), NULL, NULL,
        &pTexture) != D3D_OK || pTexture == NULL)
    {
        lua_pushnil(L);
        lua_pushliteral(L, "Cannot load bitmap");
        return 2;
    }

    l_surface_t *pSurface = luaT_new(L, l_surface_t);
    lua_pushvalue(L, LUA_ENVIRONINDEX);
    lua_setmetatable(L, -2);
    pSurface->target.pTexture = pTexture;
    pSurface->own_texture = true;
    return 1;
}

static int l_save_bmp(lua_State *L)
{
    l_surface_t *pSurface = l_check_surface(L, 1);
    if(pSurface->target.pTexture == NULL)
        return luaL_typerror(L, 1, "Surface");
    if(D3DXSaveTextureToFile(luaL_checkstring(L, 2), D3DXIFF_BMP,
        pSurface->target.pTexture, NULL) == D3D_OK)
    {
        lua_pushboolean(L, 1);
    }
    else
    {
        lua_pushboolean(L, 0);
    }
    return 1;
}

static int l_start_frame(lua_State *L)
{
    l_surface_t *pSurface = l_check_surface(L, 1);
    if(pSurface->target.pSprite)
    {
        pSurface->target.pDevice->Clear(0, NULL, D3DCLEAR_TARGET, D3DCOLOR_XRGB(0, 0, 0), 1.0f, 0);
        pSurface->target.pDevice->BeginScene();
        pSurface->target.pSprite->Begin(D3DXSPRITE_ALPHABLEND);
    }
    return 0;
}

static int l_end_frame(lua_State *L)
{
    l_surface_t *pSurface = l_check_surface(L, 1);
    if(pSurface->target.pSprite)
    {
        pSurface->target.pSprite->End();
        pSurface->target.pDevice->EndScene();
        pSurface->target.pDevice->Present(NULL,NULL,NULL,NULL);
    }
    return 0;
}

static int l_set_mode(lua_State *L)
{
#define err(msg) {} /* TODO */

    int iWidth, iHeight, iBPP, iArg, iArgCount;
    Uint32 iSDLFlags = 0;

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
    }

    SDL_Surface *pSDLSurface = SDL_SetVideoMode(iWidth, iHeight, iBPP, iSDLFlags);
    if(pSDLSurface == NULL)
    {
        err("Could not set SDL video mode");
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
        err("Could not get HWND from SDL");
    }
    
    THRenderTarget oTarget;
    oTarget.pD3D = NULL;
    oTarget.pDevice = NULL;
    oTarget.pSprite = NULL;
    
    oTarget.pD3D = Direct3DCreate9(D3D_SDK_VERSION);
    if(oTarget.pD3D == NULL)
    {
        err("Could not create Direct3D object")
    }

    D3DDISPLAYMODE d3ddm;
	oTarget.pD3D->GetAdapterDisplayMode(D3DADAPTER_DEFAULT, &d3ddm);

    D3DCAPS9 d3dCaps;
	ZeroMemory(&d3dCaps, sizeof(d3dCaps));
	D3DDEVTYPE eDeviceTypeToUse = D3DDEVTYPE_HAL;
    if(FAILED(oTarget.pD3D->GetDeviceCaps(D3DADAPTER_DEFAULT, eDeviceTypeToUse, &d3dCaps)))
	{
		eDeviceTypeToUse = D3DDEVTYPE_SW;
		if(FAILED(oTarget.pD3D->GetDeviceCaps(D3DADAPTER_DEFAULT, eDeviceTypeToUse, &d3dCaps)))
		{
			eDeviceTypeToUse = D3DDEVTYPE_REF;
			if(FAILED(oTarget.pD3D->GetDeviceCaps(D3DADAPTER_DEFAULT, eDeviceTypeToUse, &d3dCaps)))
			{
				err("Could not get D3D device caps for HAL, SW or REF");
			}
		}
	}

    D3DPRESENT_PARAMETERS oPresentParams;
	ZeroMemory(&oPresentParams, sizeof(oPresentParams));
	oPresentParams.SwapEffect = D3DSWAPEFFECT_DISCARD;
	oPresentParams.EnableAutoDepthStencil = true;
	oPresentParams.AutoDepthStencilFormat = D3DFMT_D16;
	oPresentParams.hDeviceWindow = hWindow;
	oPresentParams.BackBufferCount = 1;
    oPresentParams.Windowed = (iSDLFlags & SDL_FULLSCREEN) ? false : true;
	oPresentParams.BackBufferWidth = iWidth;
	oPresentParams.BackBufferHeight = iHeight;
	oPresentParams.BackBufferFormat = d3ddm.Format;
#ifdef CORSIX_TH_DX9_UNLIMITED_FPS
    oPresentParams.PresentationInterval = D3DPRESENT_INTERVAL_IMMEDIATE;
#endif

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

    if(FAILED(D3DXCreateSprite(oTarget.pDevice, &oTarget.pSprite)))
    {
        err("Could not create D3DX sprite");
    }

#undef err

    l_surface_t *pSurface = luaT_new(L, l_surface_t);
    lua_pushvalue(L, LUA_ENVIRONINDEX);
    lua_setmetatable(L, -2);
    pSurface->target = oTarget;
    pSurface->own_device = true;
    return 1;
}

static int l_free(lua_State *L)
{
    l_surface_t *pSurface = l_check_surface(L, 1);
    if(pSurface->own_texture)
    {
        pSurface->target.pTexture->Release();
        pSurface->target.pTexture = NULL;
        pSurface->own_texture = false;
    }
    if(pSurface->own_device)
    {
        pSurface->target.pSprite->Release();
        pSurface->target.pSprite = NULL;
        pSurface->target.pDevice->Release();
        pSurface->target.pDevice = NULL;
        pSurface->target.pD3D->Release();
        pSurface->target.pD3D = NULL;
        pSurface->own_device = false;
    }
    return 0;
}

/**
  @function sdl.video.drawSurface
  @arguments SDL_Surface src, SDL_Surface dest [, int x, int y [, int srcx, int srcy, int srcw, int srch]]
  @return bool
*/
static int l_blit_surface(lua_State *L)
{
    D3DXVECTOR3 vDestination(0, 0, 0);

    l_surface_t *src = l_check_surface(L, 1);
    if(src->target.pTexture == NULL)
        return luaL_argerror(L, 1, "Surface");
    l_surface_t *dst = l_check_surface(L, 2);
    if(dst->target.pSprite == NULL)
        return luaL_argerror(L, 2, "Video Surface");

    switch(lua_gettop(L))
    {
    case 8:
        return luaL_error(L, "TODO: Implement 8 argument DX9 surface blit");
    case 4:
        vDestination.x = (float)luaL_checknumber(L, 3);
        vDestination.y = (float)luaL_checknumber(L, 4);
    default:
        break;
    }

    if(dst->target.pSprite->Draw(src->target.pTexture, NULL, NULL,
        &vDestination, 0xFFFFFFFF) == S_OK)
    {
        lua_pushboolean(L, 1);
    }
    else
    {
        lua_pushboolean(L, 0);
    }
    return 1;
}

static int l_draw_auto(lua_State *L)
{
    l_check_surface(L, 1);
    if(lua_type(L, 2) == LUA_TUSERDATA)
    {
        return l_blit_surface(L);
    }
    else
    {
        return luaL_error(L, "Invalid draw arguments");
    }
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

static int l_new_surface(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TTABLE);

    int iWidth = -1;
    int iHeight = -1;
    int iDepth = -1;
    IDirect3DDevice9 *pDevice = NULL;
    THPalette *pPalette = NULL;
    const unsigned char *pData = NULL;
    size_t iDataLength = 0;
    size_t iDataOff = 0;

    lua_settop(L, 2);
    lua_pushnil(L);
    while(lua_next(L, 1) != 0)
    {
        if(lua_type(L, 3) == LUA_TSTRING)
        {
            const char* key = lua_tostring(L, 3);
            if(stricmp(key, "width") == 0)
                iWidth = (int)lua_tointeger(L, 4);
            else if(stricmp(key, "height") == 0)
                iHeight = (int)lua_tointeger(L, 4);
            else if(stricmp(key, "depth") == 0)
                iDepth = (int)lua_tointeger(L, 4);
            else if(stricmp(key, "data_offset") == 0)
                iDataOff = (int)lua_tointeger(L, 4);
            else if(stricmp(key, "data") == 0)
                pData = (const unsigned char*)lua_tolstring(L, 4, &iDataLength);
            else if(stricmp(key, "target") == 0)
            {
                l_surface_t *pTarget = luaT_testuserdata<l_surface_t, false>(L, 4, LUA_ENVIRONINDEX, NULL);
                if(pTarget != NULL)
                    pDevice = pTarget->target.pDevice;
            }
            else if(stricmp(key, "palette") == 0)
            {
                pPalette = (THPalette*)lua_touserdata(L, 4);
            }
        }
        lua_pop(L, 1);
    }

#define err(L, msg) lua_pushnil(L), lua_pushstring(L, msg), 2

    if(iWidth <= -1)
        return err(L, "Named width argument required");
    else if(iHeight <= -1)
        return err(L, "Named height argument required");
    else if(iDepth == -1)
        return err(L, "Named depth argument required");
    else if(iDepth != 8)
        return err(L, "Depth must be 8 bits");
    else if(pDevice == NULL)
        return err(L, "Named target argument required as VideoSurface");
    else if(pPalette == NULL)
        return err(L, "Named palette argument required");
    else if(pData == NULL)
        return err(L, "Named data argument required");
    else if(iDataOff < 0 || iDataOff >= iDataLength)
        return err(L, "Data offset is invalid");

    pData += iDataOff;
    iDataLength -= iDataOff;
    
    if(iDataLength < static_cast<size_t>(iWidth * iHeight))
        return err(L, "Data too short for given size");

    IDirect3DTexture9 *pTexture = THDX9_CreateTexture(iWidth, iHeight, pData,
        pPalette, pDevice);
    if(pTexture == NULL)
        return err(L, "Cannot create texture");

#undef err

    l_surface_t *pSurface = luaT_new(L, l_surface_t);
    lua_pushvalue(L, LUA_ENVIRONINDEX);
    lua_setmetatable(L, -2);
    pSurface->target.pTexture = pTexture;
    pSurface->own_texture = true;
    return 1;
}

static const struct luaL_reg sdl_videolib[] = {
    {"newSurface", l_new_surface},
    {"ensureHardwareSurface", l_ensure_hw_surface},
    {"getHeight", l_get_height},
    {"setMode", l_set_mode},
    {"freeSurface", l_free},
    {"draw", l_blit_surface},
    {"fillBlack", l_fill_black},
    {"startFrame", l_start_frame},
    {"endFrame", l_end_frame},
    {"saveBitmap", l_save_bmp},
    {"loadBitmap", l_load_bmp},
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
