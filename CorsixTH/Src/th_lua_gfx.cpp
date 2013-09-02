/*
Copyright (c) 2010-2013 Peter "Corsix" Cawley and Edvin "Lego3" Linge

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

#include "th_lua_internal.h"
#include "th_gfx.h"
#include <SDL.h>
#include <assert.h>

static int l_palette_new(lua_State *L)
{
    luaT_stdnew<THPalette>(L);
    return 1;
}

static int l_palette_load(lua_State *L)
{
    THPalette* pPalette = luaT_testuserdata<THPalette>(L);
    size_t iDataLen;
    const unsigned char* pData = luaT_checkfile(L, 2, &iDataLen);

    if(pPalette->loadFromTHFile(pData, iDataLen))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);
    return 1;
}

static int l_palette_set_entry(lua_State *L)
{
    THPalette* pPalette = luaT_testuserdata<THPalette>(L);
    lua_pushboolean(L, pPalette->setEntry(luaL_checkint(L, 2),
        static_cast<uint8_t>(luaL_checkinteger(L, 3)),
        static_cast<uint8_t>(luaL_checkinteger(L, 4)),
        static_cast<uint8_t>(luaL_checkinteger(L, 5)))
        ? 1 : 0);
    return 1;
}

static int l_rawbitmap_new(lua_State *L)
{
    luaT_stdnew<THRawBitmap>(L, luaT_environindex, true);
    return 1;
}

static int l_rawbitmap_set_pal(lua_State *L)
{
    THRawBitmap* pBitmap = luaT_testuserdata<THRawBitmap>(L);
    THPalette* pPalette = luaT_testuserdata<THPalette>(L, 2);
    lua_settop(L, 2);

    pBitmap->setPalette(pPalette);
    luaT_setenvfield(L, 1, "palette");
    return 1;
}

static int l_rawbitmap_load(lua_State *L)
{
    THRawBitmap* pBitmap = luaT_testuserdata<THRawBitmap>(L);
    size_t iDataLen;
    const unsigned char* pData = luaT_checkfile(L, 2, &iDataLen);
    int iWidth = luaL_checkint(L, 3);
    THRenderTarget* pSurface = luaT_testuserdata<THRenderTarget>(L, 4, luaT_upvalueindex(1), false);

    if(pBitmap->loadFromTHFile(pData, iDataLen, iWidth, pSurface))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);

    return 1;
}

static int l_rawbitmap_draw(lua_State *L)
{
    THRawBitmap* pBitmap = luaT_testuserdata<THRawBitmap>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);

    if(lua_gettop(L) >= 8)
    {
        pBitmap->draw(pCanvas, luaL_checkint(L, 3), luaL_checkint(L, 4),
            luaL_checkint(L, 5), luaL_checkint(L, 6), luaL_checkint(L, 7),
            luaL_checkint(L, 8));
    }
    else
        pBitmap->draw(pCanvas, luaL_optint(L, 3, 0), luaL_optint(L, 4, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_spritesheet_new(lua_State *L)
{
    luaT_stdnew<THSpriteSheet>(L, luaT_environindex, true);
    return 1;
}

static int l_spritesheet_set_pal(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);
    THPalette* pPalette = luaT_testuserdata<THPalette>(L, 2);
    lua_settop(L, 2);

    pSheet->setPalette(pPalette);
    luaT_setenvfield(L, 1, "palette");
    return 1;
}

static int l_spritesheet_load(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);
    size_t iDataLenTable, iDataLenChunk;
    const unsigned char* pDataTable = luaT_checkfile(L, 2, &iDataLenTable);
    const unsigned char* pDataChunk = luaT_checkfile(L, 3, &iDataLenChunk);
    bool bComplex = lua_toboolean(L, 4) != 0;
    THRenderTarget* pSurface = luaT_testuserdata<THRenderTarget>(L, 5, luaT_upvalueindex(1), false);

    if(pSheet->loadFromTHFile(pDataTable, iDataLenTable, pDataChunk, iDataLenChunk, bComplex, pSurface))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);

    return 1;
}

static int l_spritesheet_count(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);

    lua_pushinteger(L, pSheet->getSpriteCount());
    return 1;
}

static int l_spritesheet_size(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);
    int iSprite = luaL_checkint(L, 2); // No array adjustment
    if(iSprite < 0 || (unsigned int)iSprite >= pSheet->getSpriteCount())
        return luaL_argerror(L, 2, "Sprite index out of bounds");

    unsigned int iWidth, iHeight;
    pSheet->getSpriteSizeUnchecked((unsigned int)iSprite, &iWidth, &iHeight);

    lua_pushinteger(L, iWidth);
    lua_pushinteger(L, iHeight);
    return 2;
}

static int l_spritesheet_draw(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    int iSprite = luaL_checkint(L, 3); // No array adjustment

    pSheet->drawSprite(pCanvas, iSprite, luaL_optint(L, 4, 0), luaL_optint(L, 5, 0), luaL_optint(L, 6, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_spritesheet_hittest(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);
    unsigned int iSprite = (unsigned int)luaL_checkinteger(L, 2);
    int iX = luaL_checkint(L, 3);
    int iY = luaL_checkint(L, 4);
    unsigned long iFlags = (unsigned long)luaL_optint(L, 5, 0);
    return pSheet->hitTestSprite(iSprite, iX, iY, iFlags);
}

static int l_spritesheet_isvisible(lua_State *L)
{
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L);
    unsigned int iSprite = (unsigned int)luaL_checkinteger(L, 2);
    THColour oDummy;
    lua_pushboolean(L, pSheet->getSpriteAverageColour(iSprite, &oDummy) ? 1:0);
    return 1;
}

static int l_font_new(lua_State *L)
{
    return luaL_error(L, "Cannot instantiate an interface");
}

static int l_bitmap_font_new(lua_State *L)
{
    luaT_stdnew<THBitmapFont>(L, luaT_environindex, true);
    return 1;
}

static int l_bitmap_font_set_spritesheet(lua_State *L)
{
    THBitmapFont* pFont = luaT_testuserdata<THBitmapFont>(L);
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L, 2);
    lua_settop(L, 2);

    pFont->setSpriteSheet(pSheet);
    luaT_setenvfield(L, 1, "sprites");
    return 1;
}

static int l_bitmap_font_get_spritesheet(lua_State *L)
{
    luaT_testuserdata<THBitmapFont>(L);
    luaT_getenvfield(L, 1, "sprites");
    return 1;
}

static int l_bitmap_font_set_sep(lua_State *L)
{
    THBitmapFont* pFont = luaT_testuserdata<THBitmapFont>(L);

    pFont->setSeparation(luaL_checkint(L, 2), luaL_optint(L, 3, 0));

    lua_settop(L, 1);
    return 1;
}

#ifdef CORSIX_TH_USE_FREETYPE2
static void l_freetype_throw_error_code(lua_State *L, FT_Error e)
{
    if(e != FT_Err_Ok)
    {
        switch(e)
        {
#undef __FTERRORS_H__
#define FT_ERRORDEF(e, v, s) case e: lua_pushliteral(L, s); break;
#define FT_ERROR_START_LIST
#define FT_ERROR_END_LIST
#include FT_ERRORS_H
            default:
                lua_pushliteral(L, "Unrecognised FreeType2 error");
                break;
        };
        lua_error(L);
    }
}

static int l_freetype_font_new(lua_State *L)
{
    THFreeTypeFont *pFont = luaT_stdnew<THFreeTypeFont>(L, LUA_ENVIRONINDEX,
        true);
    l_freetype_throw_error_code(L, pFont->initialise());
    return 1;
}

static int l_freetype_font_set_spritesheet(lua_State *L)
{
    THFreeTypeFont* pFont = luaT_testuserdata<THFreeTypeFont>(L);
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L, 2);
    lua_settop(L, 2);

    l_freetype_throw_error_code(L, pFont->matchBitmapFont(pSheet));
    lua_settop(L, 1);
    return 1;
}

static int l_freetype_font_get_copyright(lua_State *L)
{
    lua_pushstring(L, THFreeTypeFont::getCopyrightNotice());
    return 1;
}

static int l_freetype_font_set_face(lua_State *L)
{
    THFreeTypeFont* pFont = luaT_testuserdata<THFreeTypeFont>(L);
    size_t iLength;
    const unsigned char* pData = luaT_checkfile(L, 2, &iLength);
    lua_settop(L, 2);

    l_freetype_throw_error_code(L, pFont->setFace(pData, iLength));
    luaT_setenvfield(L, 1, "face");
    return 1;
}
#endif

static int l_font_get_size(lua_State *L)
{
    THFont* pFont = luaT_testuserdata<THFont>(L);
    size_t iMsgLen;
    const char* sMsg = luaT_checkstring(L, 2, &iMsgLen);

    int iWidth, iHeight;
    pFont->getTextSize(sMsg, iMsgLen, &iWidth, &iHeight);

    lua_pushinteger(L, iWidth);
    lua_pushinteger(L, iHeight);
    return 2;
}

static int l_font_draw(lua_State *L)
{
    THFont* pFont = luaT_testuserdata<THFont>(L);
    THRenderTarget* pCanvas = NULL;
    if(!lua_isnoneornil(L, 2))
    {
        pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    }
    size_t iMsgLen;
    const char* sMsg = luaT_checkstring(L, 3, &iMsgLen);
    int iX = luaL_checkint(L, 4);
    int iY = luaL_checkint(L, 5);
    eTHAlign eAlign = Align_Center;
    if(!lua_isnoneornil(L, 8))
    {
        const char* sAlign = luaL_checkstring(L, 8);
        if(strcmp(sAlign, "right") == 0)
            eAlign = Align_Right;
        else if(strcmp(sAlign, "left") == 0)
            eAlign = Align_Left;
        else if(strcmp(sAlign, "center") == 0
             || strcmp(sAlign, "centre") == 0
             || strcmp(sAlign, "middle") == 0)
        {
            eAlign = Align_Center;
        }
        else
            return luaL_error(L, "Invalid alignment: \"%s\"", sAlign);
    }
    int iWidth, iHeight;
    pFont->getTextSize(sMsg, iMsgLen, &iWidth, &iHeight);
    if(!lua_isnoneornil(L, 7))
    {
        int iW = luaL_checkint(L, 6);
        int iH = luaL_checkint(L, 7);
        if(iW > iWidth && eAlign != Align_Left)
            iX += (iW - iWidth) / ((eAlign == Align_Center) ? 2 : 1);
        if(iH > iHeight)
            iY += (iH - iHeight) / 2;
    }
    if(pCanvas != NULL)
    {
        pFont->drawText(pCanvas, sMsg, iMsgLen, iX, iY);
    }
    lua_pushinteger(L, iY + iHeight);
    lua_pushinteger(L, iX + iWidth);

    return 2;
}

static int l_font_draw_wrapped(lua_State *L)
{
    THFont* pFont = luaT_testuserdata<THFont>(L);
    THRenderTarget* pCanvas = NULL;
    if(!lua_isnoneornil(L, 2))
    {
        pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    }
    size_t iMsgLen;
    const char* sMsg = luaT_checkstring(L, 3, &iMsgLen);
    int iX = luaL_checkint(L, 4);
    int iY = luaL_checkint(L, 5);
    int iW = luaL_checkint(L, 6);
    eTHAlign eAlign = Align_Left;
    if(!lua_isnoneornil(L, 7))
    {
        const char* sAlign = luaL_checkstring(L, 7);
        if(strcmp(sAlign, "right") == 0)
            eAlign = Align_Right;
        else if(strcmp(sAlign, "left") == 0)
            eAlign = Align_Left;
        else if(strcmp(sAlign, "center") == 0
             || strcmp(sAlign, "centre") == 0
             || strcmp(sAlign, "middle") == 0)
        {
            eAlign = Align_Center;
        }
        else
            return luaL_error(L, "Invalid alignment: \"%s\"", sAlign);
    }

    int iLastX;
    int iLastY = pFont->drawTextWrapped(pCanvas, sMsg, iMsgLen, iX, iY,
                                              iW, NULL, &iLastX, eAlign);
    lua_pushinteger(L, iLastY);
    lua_pushinteger(L, iLastX);

    return 2;
}

static int l_font_draw_tooltip(lua_State *L)
{
    THFont* pFont = luaT_testuserdata<THFont>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    size_t iMsgLen;
    const char* sMsg = luaT_checkstring(L, 3, &iMsgLen);
    int iX = luaL_checkint(L, 4);
    int iY = luaL_checkint(L, 5);
    int iScreenWidth = pCanvas->getWidth();

    int iW = 200; // (for now) hardcoded width of tooltips
    int iRealW;
    uint32_t iBlack = pCanvas->mapColour(0x00, 0x00, 0x00);
    uint32_t iWhite = pCanvas->mapColour(0xFF, 0xFF, 0xFF);
    int iLastY = pFont->drawTextWrapped(NULL, sMsg, iMsgLen, iX + 2, iY + 1, iW - 4, &iRealW);
    int iLastX = iX + iRealW + 3;
    int iFirstY = iY - (iLastY - iY) - 1;

    int iXOffset = iLastX > iScreenWidth ? iScreenWidth - iLastX : 0;
    int iYOffset = iFirstY < 0 ? -iFirstY : 0;

    pCanvas->fillRect(iBlack, iX + iXOffset, iFirstY + iYOffset, iRealW + 3, iLastY - iY + 2);
    pCanvas->fillRect(iWhite, iX + iXOffset + 1, iFirstY + 1 + iYOffset, iRealW + 1, iLastY - iY);

    pFont->drawTextWrapped(pCanvas, sMsg, iMsgLen, iX + 2 + iXOffset, iFirstY + 1 + iYOffset, iW - 4);

    lua_pushinteger(L, iLastY);

    return 1;
}

static int l_layers_new(lua_State *L)
{
    THLayers_t* pLayers = luaT_stdnew<THLayers_t>(L, luaT_environindex, false);
    for(int i = 0; i < 13; ++i)
        pLayers->iLayerContents[i] = 0;
    return 1;
}

static int l_layers_get(lua_State *L)
{
    THLayers_t* pLayers = luaT_testuserdata<THLayers_t>(L);
    int iLayer = luaL_checkint(L, 2);
    if(0 <= iLayer && iLayer < 13)
        lua_pushinteger(L, pLayers->iLayerContents[iLayer]);
    else
        lua_pushnil(L);
    return 1;
}

static int l_layers_set(lua_State *L)
{
    THLayers_t* pLayers = luaT_testuserdata<THLayers_t>(L);
    int iLayer = luaL_checkint(L, 2);
    int iValue = luaL_checkint(L, 3);
    if(0 <= iLayer && iLayer < 13)
        pLayers->iLayerContents[iLayer] = (unsigned char)iValue;
    return 0;
}

static int l_layers_persist(lua_State *L)
{
    THLayers_t* pLayers = luaT_testuserdata<THLayers_t>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistWriter* pWriter = (LuaPersistWriter*)lua_touserdata(L, 1);

    int iNumLayers = 13;
    for( ; iNumLayers >= 1; --iNumLayers)
    {
        if(pLayers->iLayerContents[iNumLayers - 1] != 0)
            break;
    }
    pWriter->writeVUInt(iNumLayers);
    pWriter->writeByteStream(pLayers->iLayerContents, iNumLayers);
    return 0;
}

static int l_layers_depersist(lua_State *L)
{
    THLayers_t* pLayers = luaT_testuserdata<THLayers_t>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistReader* pReader = (LuaPersistReader*)lua_touserdata(L, 1);

    memset(pLayers->iLayerContents, 0, sizeof(pLayers->iLayerContents));
    int iNumLayers;
    if(!pReader->readVUInt(iNumLayers))
        return 0;
    if(iNumLayers > 13)
    {
        if(!pReader->readByteStream(pLayers->iLayerContents, 13))
            return 0;
        if(!pReader->readByteStream(NULL, iNumLayers - 13))
            return 0;
    }
    else
    {
        if(!pReader->readByteStream(pLayers->iLayerContents, iNumLayers))
            return 0;
    }
    return 0;
}

static int l_cursor_new(lua_State *L)
{
    luaT_stdnew<THCursor>(L, luaT_environindex, false);
    return 1;
}

static int l_cursor_load(lua_State *L)
{
    THCursor* pCursor = luaT_testuserdata<THCursor>(L);
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L, 2);
    if(pCursor->createFromSprite(pSheet, (unsigned int)luaL_checkint(L, 3),
        luaL_optint(L, 4, 0), luaL_optint(L, 5, 0)))
    {
        lua_settop(L, 1);
        return 1;
    }
    else
    {
        lua_pushboolean(L, 0);
        return 1;
    }
}

static int l_cursor_use(lua_State *L)
{
    THCursor* pCursor = luaT_testuserdata<THCursor>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    pCursor->use(pCanvas);
    return 0;
}

static int l_cursor_position(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 1, luaT_upvalueindex(1));
    lua_pushboolean(L, THCursor::setPosition(pCanvas, luaL_checkint(L, 2), luaL_checkint(L, 3)) ? 1 : 0);
    return 1;
}

static int l_surface_new(lua_State *L)
{
    lua_remove(L, 1); // Value inserted by __call

    THRenderTargetCreationParams oParams;
    oParams.iWidth = luaL_checkint(L, 1);
    oParams.iHeight = luaL_checkint(L, 2);
    int iArg = 3;
    if(lua_type(L, iArg) == LUA_TNUMBER)
        oParams.iBPP = luaL_checkint(L, iArg++);
    else
        oParams.iBPP = 0;
    oParams.iSDLFlags = 0;
    oParams.bFullscreen = false;
    oParams.bPresentImmediate = false;
    oParams.bReuseContext = false;

#define FLAG(name, field, flag) \
    else if(stricmp(sOption, name) == 0) \
        oParams.field = true, oParams.iSDLFlags |= flag
    
    for(int iArgCount = lua_gettop(L); iArg <= iArgCount; ++iArg)
    {
        const char* sOption = luaL_checkstring(L, iArg);
        if(sOption[0] == 0)
            continue;
        FLAG("fullscreen",          bFullscreen,        SDL_WINDOW_FULLSCREEN_DESKTOP   );
        FLAG("present immediate",   bPresentImmediate,  0                               );
        FLAG("reuse context",       bReuseContext,      0                               );
    }

#undef FLAG

    THRenderTarget* pCanvas = luaT_stdnew<THRenderTarget>(L);
    if(pCanvas->create(&oParams))
        return 1;

    lua_pushnil(L);
    lua_pushstring(L, pCanvas->getLastError());
    return 2;
}

static int l_surface_fill_black(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    lua_settop(L, 1);
    if(pCanvas->fillBlack())
        return 1;
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->getLastError());
    return 2;
}

static int l_surface_start_frame(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    lua_settop(L, 1);
    if(pCanvas->startFrame())
        return 1;
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->getLastError());
    return 2;
}

static int l_surface_end_frame(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    lua_settop(L, 1);
    if(pCanvas->endFrame())
        return 1;
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->getLastError());
    return 2;
}

static int l_surface_nonoverlapping(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    if(lua_isnone(L, 2) || lua_toboolean(L, 2) != 0)
        pCanvas->startNonOverlapping();
    else
        pCanvas->finishNonOverlapping();
    lua_settop(L, 1);
    return 1;
}

static int l_surface_set_blue_filter_active(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    pCanvas->setBlueFilterActive(lua_isnoneornil(L, 2) ? false : lua_toboolean(L, 2));
    return 1;
}

static int l_surface_map(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    lua_pushnumber(L, (lua_Number)pCanvas->mapColour(
        (Uint8)luaL_checkinteger(L, 2),
        (Uint8)luaL_checkinteger(L, 3),
        (Uint8)luaL_checkinteger(L, 4)));
    return 1;
}

static int l_surface_rect(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    if(pCanvas->fillRect((uint32_t)luaL_checknumber(L, 2),
        luaL_checkint(L, 3), luaL_checkint(L, 4), luaL_checkint(L, 5),
        luaL_checkint(L, 6)))
    {
        lua_settop(L, 1);
        return 1;
    }
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->getLastError());
    return 2;
}

static int l_surface_screenshot(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    const char *sFile = luaL_checkstring(L, 2);
    if(pCanvas->takeScreenshot(sFile))
    {
        lua_settop(L, 1);
        return 1;
    }
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->getLastError());
    return 2;
}

static int l_surface_get_clip(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    THClipRect rcClip;
    pCanvas->getClipRect(&rcClip);
    lua_pushinteger(L, rcClip.x);
    lua_pushinteger(L, rcClip.y);
    lua_pushinteger(L, rcClip.w);
    lua_pushinteger(L, rcClip.h);
    return 4;
}

static int l_surface_set_clip(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    THClipRect rcClip;
    rcClip.x = static_cast<THClipRect::xy_t>(luaL_checkint(L, 2));
    rcClip.y = static_cast<THClipRect::xy_t>(luaL_checkint(L, 3));
    rcClip.w = static_cast<THClipRect::wh_t>(luaL_checkint(L, 4));
    rcClip.h = static_cast<THClipRect::wh_t>(luaL_checkint(L, 5));
    if(lua_toboolean(L, 6) != 0)
    {
        THClipRect rcExistingClip;
        pCanvas->getClipRect(&rcExistingClip);
        IntersectTHClipRect(rcClip, rcExistingClip);
    }
    pCanvas->setClipRect(&rcClip);
    lua_settop(L, 1);
    return 1;
}

static int l_surface_scale(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    THScaledItems eToScale = THSI_None;
    if(lua_isnoneornil(L, 3))
    {
        eToScale = THSI_All;
    }
    else
    {
        size_t iLength;
        const char* sOption = lua_tolstring(L, 3, &iLength);
        if(sOption && iLength >= 6 && memcmp(sOption, "bitmap", 6) == 0)
        {
            eToScale = THSI_Bitmaps;
        }
        else
            luaL_error(L, "Expected \"bitmap\" as 2nd argument");
    }
    lua_pushboolean(L, pCanvas->setScaleFactor(static_cast<float>(
        luaL_checknumber(L, 2)), eToScale) ? 1 : 0);
    return 1;
}

static int l_surface_set_caption(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    pCanvas->setCaption(luaL_checkstring(L, 2));

    lua_settop(L, 1);
    return 1;
}

static int l_surface_get_renderer_details(lua_State *L)
{
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L);
    lua_pushstring(L, pCanvas->getRendererDetails());
    return 1;
}

static int l_line_new(lua_State *L)
{
    luaT_stdnew<THLine>(L);
    return 1;
}

static int l_move_to(lua_State *L)
{
    THLine* pLine = luaT_testuserdata<THLine>(L);
    pLine->moveTo(luaL_optnumber(L, 2, 0), luaL_optnumber(L, 3, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_line_to(lua_State *L)
{
    THLine* pLine = luaT_testuserdata<THLine>(L);
    pLine->lineTo(luaL_optnumber(L, 2, 0), luaL_optnumber(L, 3, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_set_width(lua_State *L)
{
    THLine* pLine = luaT_testuserdata<THLine>(L);
    pLine->setWidth(luaL_optnumber(L, 2, 1));

    lua_settop(L, 1);
    return 1;
}

static int l_set_colour(lua_State *L)
{
    THLine* pLine = luaT_testuserdata<THLine>(L);
    pLine->setColour(luaL_optint(L, 2, 0), luaL_optint(L, 3, 0), luaL_optint(L, 4, 0), luaL_optint(L, 5, 255));

    lua_settop(L, 1);
    return 1;
}

static int l_line_draw(lua_State *L)
{
    THLine* pLine = luaT_testuserdata<THLine>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    pLine->draw(pCanvas, luaL_optint(L, 3, 0), luaL_optint(L, 4, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_line_persist(lua_State *L)
{
    THLine* pLine = luaT_testuserdata<THLine>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistWriter* pWriter = (LuaPersistWriter*)lua_touserdata(L, 1);
    pLine->persist(pWriter);
    return 0;
}

static int l_line_depersist(lua_State *L)
{
    THLine* pLine = luaT_testuserdata<THLine>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistReader* pReader = (LuaPersistReader*)lua_touserdata(L, 1);
    pLine->depersist(pReader);
    return 0;
}

void THLuaRegisterGfx(const THLuaRegisterState_t *pState)
{
    // Palette
    luaT_class(THPalette, l_palette_new, "palette", MT_Palette);
    luaT_setfunction(l_palette_load, "load");
    luaT_setfunction(l_palette_set_entry, "setEntry");
    luaT_endclass();

    // Raw bitmap
    luaT_class(THRawBitmap, l_rawbitmap_new, "bitmap", MT_Bitmap);
    luaT_setfunction(l_rawbitmap_load, "load", MT_Surface);
    luaT_setfunction(l_rawbitmap_set_pal, "setPalette", MT_Palette);
    luaT_setfunction(l_rawbitmap_draw, "draw", MT_Surface);
    luaT_endclass();

    // Sprite sheet
    luaT_class(THSpriteSheet, l_spritesheet_new, "sheet", MT_Sheet);
    luaT_setmetamethod(l_spritesheet_count, "len");
    luaT_setfunction(l_spritesheet_load, "load", MT_Surface);
    luaT_setfunction(l_spritesheet_set_pal, "setPalette", MT_Palette);
    luaT_setfunction(l_spritesheet_size, "size");
    luaT_setfunction(l_spritesheet_draw, "draw", MT_Surface);
    luaT_setfunction(l_spritesheet_hittest, "hitTest");
    luaT_setfunction(l_spritesheet_isvisible, "isVisible");
    luaT_endclass();

    // Font
    luaT_class(THFont, l_font_new, "font", MT_Font);
    luaT_setfunction(l_font_get_size, "sizeOf");
    luaT_setfunction(l_font_draw, "draw", MT_Surface);
    luaT_setfunction(l_font_draw_wrapped, "drawWrapped", MT_Surface);
    luaT_setfunction(l_font_draw_tooltip, "drawTooltip", MT_Surface);
    luaT_endclass();

    // BitmapFont
    luaT_class(THBitmapFont, l_bitmap_font_new, "bitmap_font", MT_BitmapFont);
    luaT_superclass(MT_Font);
    luaT_setfunction(l_bitmap_font_set_spritesheet, "setSheet", MT_Sheet);
    luaT_setfunction(l_bitmap_font_get_spritesheet, "getSheet", MT_Sheet);
    luaT_setfunction(l_bitmap_font_set_sep, "setSeparation");
    luaT_endclass();

#ifdef CORSIX_TH_USE_FREETYPE2
    // FreeTypeFont
    luaT_class(THFreeTypeFont, l_freetype_font_new, "freetype_font", MT_FreeTypeFont);
    luaT_superclass(MT_Font);
    luaT_setfunction(l_freetype_font_set_spritesheet, "setSheet", MT_Sheet);
    luaT_setfunction(l_freetype_font_set_face, "setFace");
    luaT_setfunction(l_freetype_font_get_copyright, "getCopyrightNotice");
    luaT_endclass();
#endif

    // Layers
    luaT_class(THLayers_t, l_layers_new, "layers", MT_Layers);
    luaT_setmetamethod(l_layers_get, "index");
    luaT_setmetamethod(l_layers_set, "newindex");
    luaT_setmetamethod(l_layers_persist, "persist");
    luaT_setmetamethod(l_layers_depersist, "depersist");
    luaT_endclass();

    // Cursor
    luaT_class(THCursor, l_cursor_new, "cursor", MT_Cursor);
    luaT_setfunction(l_cursor_load, "load", MT_Sheet);
    luaT_setfunction(l_cursor_use, "use", MT_Surface);
    luaT_setfunction(l_cursor_position, "setPosition", MT_Surface);
    luaT_endclass();

    // Surface
    luaT_class(THRenderTarget, l_surface_new, "surface", MT_Surface);
    luaT_setfunction(l_surface_fill_black, "fillBlack");
    luaT_setfunction(l_surface_start_frame, "startFrame");
    luaT_setfunction(l_surface_end_frame, "endFrame");
    luaT_setfunction(l_surface_nonoverlapping, "nonOverlapping");
    luaT_setfunction(l_surface_map, "mapRGB");
    luaT_setfunction(l_surface_set_blue_filter_active, "setBlueFilterActive");
    luaT_setfunction(l_surface_rect, "drawRect");
    luaT_setfunction(l_surface_get_clip, "getClip");
    luaT_setfunction(l_surface_set_clip, "setClip");
    luaT_setfunction(l_surface_screenshot, "takeScreenshot");
    luaT_setfunction(l_surface_scale, "scale");
    luaT_setfunction(l_surface_set_caption, "setCaption");
    luaT_setfunction(l_surface_get_renderer_details, "getRendererDetails");
    luaT_endclass();

    // Line
    luaT_class(THLine, l_line_new, "line", MT_Line);
    luaT_setfunction(l_move_to, "moveTo");
    luaT_setfunction(l_line_to, "lineTo");
    luaT_setfunction(l_set_width, "setWidth");
    luaT_setfunction(l_set_colour, "setColour");
    luaT_setfunction(l_line_draw, "draw", MT_Surface);
    luaT_setmetamethod(l_line_persist, "persist");
    luaT_setmetamethod(l_line_depersist, "depersist");
    luaT_endclass();
}
