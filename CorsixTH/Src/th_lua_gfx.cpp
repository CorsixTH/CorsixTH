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
#include <cstring>

static int l_palette_new(lua_State *L)
{
    luaT_stdnew<palette>(L);
    return 1;
}

static int l_palette_load(lua_State *L)
{
    palette* pPalette = luaT_testuserdata<palette>(L);
    size_t iDataLen;
    const uint8_t* pData = luaT_checkfile(L, 2, &iDataLen);

    if(pPalette->load_from_th_file(pData, iDataLen))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);
    return 1;
}

static int l_palette_set_entry(lua_State *L)
{
    palette* pPalette = luaT_testuserdata<palette>(L);
    lua_pushboolean(L, pPalette->set_entry(static_cast<int>(luaL_checkinteger(L, 2)),
        static_cast<uint8_t>(luaL_checkinteger(L, 3)),
        static_cast<uint8_t>(luaL_checkinteger(L, 4)),
        static_cast<uint8_t>(luaL_checkinteger(L, 5)))
        ? 1 : 0);
    return 1;
}

static int l_rawbitmap_new(lua_State *L)
{
    luaT_stdnew<raw_bitmap>(L, luaT_environindex, true);
    return 1;
}

static int l_rawbitmap_set_pal(lua_State *L)
{
    raw_bitmap* pBitmap = luaT_testuserdata<raw_bitmap>(L);
    palette* pPalette = luaT_testuserdata<palette>(L, 2);
    lua_settop(L, 2);

    pBitmap->set_palette(pPalette);
    luaT_setenvfield(L, 1, "palette");
    return 1;
}

static int l_rawbitmap_load(lua_State *L)
{
    raw_bitmap* pBitmap = luaT_testuserdata<raw_bitmap>(L);
    size_t iDataLen;
    const uint8_t* pData = luaT_checkfile(L, 2, &iDataLen);
    int iWidth = static_cast<int>(luaL_checkinteger(L, 3));
    render_target* pSurface = luaT_testuserdata<render_target>(L, 4, luaT_upvalueindex(1), false);

    if(pBitmap->load_from_th_file(pData, iDataLen, iWidth, pSurface))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);

    return 1;
}

static int l_rawbitmap_draw(lua_State *L)
{
    raw_bitmap* pBitmap = luaT_testuserdata<raw_bitmap>(L);
    render_target* pCanvas = luaT_testuserdata<render_target>(L, 2);

    if(lua_gettop(L) >= 8)
    {
        pBitmap->draw(pCanvas, static_cast<int>(luaL_checkinteger(L, 3)), static_cast<int>(luaL_checkinteger(L, 4)),
            static_cast<int>(luaL_checkinteger(L, 5)), static_cast<int>(luaL_checkinteger(L, 6)), static_cast<int>(luaL_checkinteger(L, 7)),
            static_cast<int>(luaL_checkinteger(L, 8)));
    }
    else
        pBitmap->draw(pCanvas, static_cast<int>(luaL_optinteger(L, 3, 0)), static_cast<int>(luaL_optinteger(L, 4, 0)));

    lua_settop(L, 1);
    return 1;
}

static int l_spritesheet_new(lua_State *L)
{
    luaT_stdnew<sprite_sheet>(L, luaT_environindex, true);
    return 1;
}

static int l_spritesheet_set_pal(lua_State *L)
{
    sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L);
    palette* pPalette = luaT_testuserdata<palette>(L, 2);
    lua_settop(L, 2);

    pSheet->set_palette(pPalette);
    luaT_setenvfield(L, 1, "palette");
    return 1;
}

static int l_spritesheet_load(lua_State *L)
{
    sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L);
    size_t iDataLenTable, iDataLenChunk;
    const uint8_t* pDataTable = luaT_checkfile(L, 2, &iDataLenTable);
    const uint8_t* pDataChunk = luaT_checkfile(L, 3, &iDataLenChunk);
    bool bComplex = lua_toboolean(L, 4) != 0;
    render_target* pSurface = luaT_testuserdata<render_target>(L, 5, luaT_upvalueindex(1), false);

    if(pSheet->load_from_th_file(pDataTable, iDataLenTable, pDataChunk, iDataLenChunk, bComplex, pSurface))
        lua_pushboolean(L, 1);
    else
        lua_pushboolean(L, 0);

    return 1;
}

static int l_spritesheet_count(lua_State *L)
{
    sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L);

    lua_pushinteger(L, pSheet->get_sprite_count());
    return 1;
}

static int l_spritesheet_size(lua_State *L)
{
    sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L);
    size_t iSprite = luaL_checkinteger(L, 2); // No array adjustment
    if(iSprite < 0 || iSprite >= pSheet->get_sprite_count())
        return luaL_argerror(L, 2, "Sprite index out of bounds");

    unsigned int iWidth, iHeight;
    pSheet->get_sprite_size_unchecked(iSprite, &iWidth, &iHeight);

    lua_pushinteger(L, iWidth);
    lua_pushinteger(L, iHeight);
    return 2;
}

static int l_spritesheet_draw(lua_State *L)
{
    sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L);
    render_target* pCanvas = luaT_testuserdata<render_target>(L, 2);
    int iSprite = static_cast<int>(luaL_checkinteger(L, 3)); // No array adjustment

    pSheet->draw_sprite(pCanvas, iSprite, static_cast<int>(luaL_optinteger(L, 4, 0)), static_cast<int>(luaL_optinteger(L, 5, 0)), static_cast<int>(luaL_optinteger(L, 6, 0)));

    lua_settop(L, 1);
    return 1;
}

static int l_spritesheet_hittest(lua_State *L)
{
    sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L);
    size_t iSprite = luaL_checkinteger(L, 2);
    int iX = static_cast<int>(luaL_checkinteger(L, 3));
    int iY = static_cast<int>(luaL_checkinteger(L, 4));
    uint32_t iFlags = static_cast<uint32_t>(luaL_optinteger(L, 5, 0));
    return pSheet->hit_test_sprite(iSprite, iX, iY, iFlags);
}

static int l_spritesheet_isvisible(lua_State *L)
{
    sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L);
    size_t iSprite = luaL_checkinteger(L, 2);
    argb_colour oDummy;
    lua_pushboolean(L, pSheet->get_sprite_average_colour(iSprite, &oDummy) ? 1:0);
    return 1;
}

static int l_font_new(lua_State *L)
{
    return luaL_error(L, "Cannot instantiate an interface");
}

static int l_bitmap_font_new(lua_State *L)
{
    luaT_stdnew<bitmap_font>(L, luaT_environindex, true);
    return 1;
}

static int l_bitmap_font_set_spritesheet(lua_State *L)
{
    bitmap_font* pFont = luaT_testuserdata<bitmap_font>(L);
    sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L, 2);
    lua_settop(L, 2);

    pFont->set_sprite_sheet(pSheet);
    luaT_setenvfield(L, 1, "sprites");
    return 1;
}

static int l_bitmap_font_get_spritesheet(lua_State *L)
{
    luaT_testuserdata<bitmap_font>(L);
    luaT_getenvfield(L, 1, "sprites");
    return 1;
}

static int l_bitmap_font_set_sep(lua_State *L)
{
    bitmap_font* pFont = luaT_testuserdata<bitmap_font>(L);

    pFont->set_separation(static_cast<int>(luaL_checkinteger(L, 2)), static_cast<int>(luaL_optinteger(L, 3, 0)));

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
    freetype_font *pFont = luaT_stdnew<freetype_font>(L, luaT_environindex,
        true);
    l_freetype_throw_error_code(L, pFont->initialise());
    return 1;
}

static int l_freetype_font_set_spritesheet(lua_State *L)
{
    freetype_font* pFont = luaT_testuserdata<freetype_font>(L);
    sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L, 2);
    lua_settop(L, 2);

    l_freetype_throw_error_code(L, pFont->match_bitmap_font(pSheet));
    lua_settop(L, 1);
    return 1;
}

static int l_freetype_font_get_copyright(lua_State *L)
{
    lua_pushstring(L, freetype_font::get_copyright_notice());
    return 1;
}

static int l_freetype_font_set_face(lua_State *L)
{
    freetype_font* pFont = luaT_testuserdata<freetype_font>(L);
    size_t iLength;
    const uint8_t* pData = luaT_checkfile(L, 2, &iLength);
    lua_settop(L, 2);

    l_freetype_throw_error_code(L, pFont->set_face(pData, iLength));
    luaT_setenvfield(L, 1, "face");
    return 1;
}

static int l_freetype_font_clear_cache(lua_State *L)
{
    freetype_font* pFont = luaT_testuserdata<freetype_font>(L);
    pFont->clear_cache();
    return 0;
}

#endif

static int l_font_get_size(lua_State *L)
{
    font* pFont = luaT_testuserdata<font>(L);
    size_t iMsgLen;
    const char* sMsg = luaT_checkstring(L, 2, &iMsgLen);

    int iMaxWidth = INT_MAX;
    if(!lua_isnoneornil(L, 3))
        iMaxWidth = static_cast<int>(luaL_checkinteger(L, 3));

    text_layout oDrawArea = pFont->get_text_dimensions(sMsg, iMsgLen, iMaxWidth);

    lua_pushinteger(L, oDrawArea.end_x);
    lua_pushinteger(L, oDrawArea.end_y);
    lua_pushinteger(L, oDrawArea.row_count);

    return 3;
}

static int l_font_draw(lua_State *L)
{
    font* pFont = luaT_testuserdata<font>(L);
    render_target* pCanvas = nullptr;
    if(!lua_isnoneornil(L, 2))
    {
        pCanvas = luaT_testuserdata<render_target>(L, 2);
    }
    size_t iMsgLen;
    const char* sMsg = luaT_checkstring(L, 3, &iMsgLen);
    int iX = static_cast<int>(luaL_checkinteger(L, 4));
    int iY = static_cast<int>(luaL_checkinteger(L, 5));

    text_alignment eAlign = text_alignment::center;
    if(!lua_isnoneornil(L, 8)) {
        const char* sAlign = luaL_checkstring(L, 8);
        if(std::strcmp(sAlign, "right") == 0) {
            eAlign = text_alignment::right;
        } else if(std::strcmp(sAlign, "left") == 0) {
            eAlign = text_alignment::left;
        } else if(std::strcmp(sAlign, "center") == 0 ||
                std::strcmp(sAlign, "centre") == 0 ||
                std::strcmp(sAlign, "middle") == 0) {
            eAlign = text_alignment::center;
        } else {
            return luaL_error(L, "Invalid alignment: \"%s\"", sAlign);
        }
    }

    text_layout oDrawArea = pFont->get_text_dimensions(sMsg, iMsgLen);
    if(!lua_isnoneornil(L, 7))
    {
        int iW = static_cast<int>(luaL_checkinteger(L, 6));
        int iH = static_cast<int>(luaL_checkinteger(L, 7));
        if(iW > oDrawArea.end_x && eAlign != text_alignment::left) {
            iX += (iW - oDrawArea.end_x) / ((eAlign == text_alignment::center) ? 2 : 1);
        }
        if(iH > oDrawArea.end_y) {
            iY += (iH - oDrawArea.end_y) / 2;
        }
    }
    if(pCanvas != nullptr)
    {
        pFont->draw_text(pCanvas, sMsg, iMsgLen, iX, iY);
    }
    lua_pushinteger(L, iY + oDrawArea.end_y);
    lua_pushinteger(L, iX + oDrawArea.end_x);

    return 2;
}

static int l_font_draw_wrapped(lua_State *L)
{
    font* pFont = luaT_testuserdata<font>(L);
    render_target* pCanvas = nullptr;
    if(!lua_isnoneornil(L, 2))
    {
        pCanvas = luaT_testuserdata<render_target>(L, 2);
    }
    size_t iMsgLen;
    const char* sMsg = luaT_checkstring(L, 3, &iMsgLen);
    int iX = static_cast<int>(luaL_checkinteger(L, 4));
    int iY = static_cast<int>(luaL_checkinteger(L, 5));
    int iW = static_cast<int>(luaL_checkinteger(L, 6));

    text_alignment eAlign = text_alignment::left;
    if(!lua_isnoneornil(L, 7)) {
        const char* sAlign = luaL_checkstring(L, 7);
        if(std::strcmp(sAlign, "right") == 0) {
            eAlign = text_alignment::right;
        } else if(std::strcmp(sAlign, "left") == 0) {
            eAlign = text_alignment::left;
        } else if(std::strcmp(sAlign, "center") == 0 ||
                std::strcmp(sAlign, "centre") == 0 ||
                std::strcmp(sAlign, "middle") == 0) {
            eAlign = text_alignment::center;
        } else {
            return luaL_error(L, "Invalid alignment: \"%s\"", sAlign);
        }
    }

    int iMaxRows = INT_MAX;
    if(!lua_isnoneornil(L, 8))
    {
      iMaxRows = static_cast<int>(luaL_checkinteger(L, 8));
    }

    int iSkipRows = 0;
    if(!lua_isnoneornil(L, 9))
    {
        iSkipRows = static_cast<int>(luaL_checkinteger(L, 9));
    }

    text_layout oDrawArea = pFont->draw_text_wrapped(pCanvas, sMsg, iMsgLen, iX, iY,
                                              iW, iMaxRows, iSkipRows, eAlign);
    lua_pushinteger(L, oDrawArea.end_y);
    lua_pushinteger(L, oDrawArea.end_x);
    lua_pushinteger(L, oDrawArea.row_count);

    return 3;
}

static int l_font_draw_tooltip(lua_State *L)
{
    font* pFont = luaT_testuserdata<font>(L);
    render_target* pCanvas = luaT_testuserdata<render_target>(L, 2);
    size_t iMsgLen;
    const char* sMsg = luaT_checkstring(L, 3, &iMsgLen);
    int iX = static_cast<int>(luaL_checkinteger(L, 4));
    int iY = static_cast<int>(luaL_checkinteger(L, 5));
    int iScreenWidth = pCanvas->get_width();

    int iW = 200; // (for now) hardcoded width of tooltips
    uint32_t iBlack = pCanvas->map_colour(0x00, 0x00, 0x00);
    uint32_t iWhite = pCanvas->map_colour(0xFF, 0xFF, 0xFF);
    text_layout oArea = pFont->draw_text_wrapped(nullptr, sMsg, iMsgLen, iX + 2, iY + 1, iW - 4, INT_MAX, 0);
    int iLastX = iX + oArea.width + 3;
    int iFirstY = iY - (oArea.end_y - iY) - 1;

    int iXOffset = iLastX > iScreenWidth ? iScreenWidth - iLastX : 0;
    int iYOffset = iFirstY < 0 ? -iFirstY : 0;

    pCanvas->fill_rect(iBlack, iX + iXOffset, iFirstY + iYOffset, oArea.width + 3, oArea.end_y - iY + 2);
    pCanvas->fill_rect(iWhite, iX + iXOffset + 1, iFirstY + 1 + iYOffset, oArea.width + 1, oArea.end_y - iY);

    pFont->draw_text_wrapped(pCanvas, sMsg, iMsgLen, iX + 2 + iXOffset, iFirstY + 1 + iYOffset, iW - 4);

    lua_pushinteger(L, oArea.end_y);

    return 1;
}

static int l_layers_new(lua_State *L)
{
    layers* pLayers = luaT_stdnew<layers>(L, luaT_environindex, false);
    for(int i = 0; i < 13; ++i)
        pLayers->layer_contents[i] = 0;
    return 1;
}

static int l_layers_get(lua_State *L)
{
    layers* pLayers = luaT_testuserdata<layers>(L);
    lua_Integer iLayer = luaL_checkinteger(L, 2);
    if(0 <= iLayer && iLayer < 13)
        lua_pushinteger(L, pLayers->layer_contents[iLayer]);
    else
        lua_pushnil(L);
    return 1;
}

static int l_layers_set(lua_State *L)
{
    layers* pLayers = luaT_testuserdata<layers>(L);
    lua_Integer iLayer = luaL_checkinteger(L, 2);
    uint8_t iValue = static_cast<uint8_t>(luaL_checkinteger(L, 3));
    if(0 <= iLayer && iLayer < 13)
        pLayers->layer_contents[iLayer] = iValue;
    return 0;
}

static int l_layers_persist(lua_State *L)
{
    layers* pLayers = luaT_testuserdata<layers>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    lua_persist_writer* pWriter = (lua_persist_writer*)lua_touserdata(L, 1);

    int iNumLayers = 13;
    for( ; iNumLayers >= 1; --iNumLayers)
    {
        if(pLayers->layer_contents[iNumLayers - 1] != 0)
            break;
    }
    pWriter->write_uint(iNumLayers);
    pWriter->write_byte_stream(pLayers->layer_contents, iNumLayers);
    return 0;
}

static int l_layers_depersist(lua_State *L)
{
    layers* pLayers = luaT_testuserdata<layers>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    lua_persist_reader* pReader = (lua_persist_reader*)lua_touserdata(L, 1);

    std::memset(pLayers->layer_contents, 0, sizeof(pLayers->layer_contents));
    int iNumLayers;
    if(!pReader->read_uint(iNumLayers))
        return 0;
    if(iNumLayers > 13)
    {
        if(!pReader->read_byte_stream(pLayers->layer_contents, 13))
            return 0;
        if(!pReader->read_byte_stream(nullptr, iNumLayers - 13))
            return 0;
    }
    else
    {
        if(!pReader->read_byte_stream(pLayers->layer_contents, iNumLayers))
            return 0;
    }
    return 0;
}

static int l_cursor_new(lua_State *L)
{
    luaT_stdnew<cursor>(L, luaT_environindex, false);
    return 1;
}

static int l_cursor_load(lua_State *L)
{
    cursor* pCursor = luaT_testuserdata<cursor>(L);
    sprite_sheet* pSheet = luaT_testuserdata<sprite_sheet>(L, 2);
    if(pCursor->create_from_sprite(pSheet, static_cast<int>(luaL_checkinteger(L, 3)),
        static_cast<int>(luaL_optinteger(L, 4, 0)), static_cast<int>(luaL_optinteger(L, 5, 0))))
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
    cursor* pCursor = luaT_testuserdata<cursor>(L);
    render_target* pCanvas = luaT_testuserdata<render_target>(L, 2);
    pCursor->use(pCanvas);
    return 0;
}

static int l_cursor_position(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L, 1, luaT_upvalueindex(1));
    lua_pushboolean(L, cursor::set_position(pCanvas, static_cast<int>(luaL_checkinteger(L, 2)), static_cast<int>(luaL_checkinteger(L, 3))) ? 1 : 0);
    return 1;
}

/** Construct the helper structure for making a #THRenderTarget. */
static render_target_creation_params l_surface_creation_params(lua_State *L, int iArgStart)
{
    render_target_creation_params oParams;
    oParams.width = static_cast<int>(luaL_checkinteger(L, iArgStart));
    oParams.height = static_cast<int>(luaL_checkinteger(L, iArgStart + 1));

    oParams.fullscreen = false;
    oParams.present_immediate = false;

    // Parse string arguments, looking for matching parameter names.
    for(int iArg = iArgStart + 2, iArgCount = lua_gettop(L); iArg <= iArgCount; ++iArg)
    {
        const char* sOption = luaL_checkstring(L, iArg);
        if(sOption[0] == 0)
            continue;

        if (std::strcmp(sOption, "fullscreen") == 0)        oParams.fullscreen       = true;
        if (std::strcmp(sOption, "present immediate") == 0) oParams.present_immediate = true;
    }

    return oParams;
}

static int l_surface_new(lua_State *L)
{
    lua_remove(L, 1); // Value inserted by __call

    render_target_creation_params oParams = l_surface_creation_params(L, 1);
    render_target* pCanvas = luaT_stdnew<render_target>(L);
    if(pCanvas->create(&oParams))
        return 1;

    lua_pushnil(L);
    lua_pushstring(L, pCanvas->get_last_error());
    return 2;
}

static int l_surface_update(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    render_target_creation_params oParams = l_surface_creation_params(L, 2);
    if(pCanvas->update(&oParams))
    {
        lua_pushnil(L);
        return 1;
    }

    lua_pushstring(L, pCanvas->get_last_error());
    return 1;
}

static int l_surface_destroy(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    pCanvas->end_frame();
    pCanvas->destroy();
    return 1;
}

static int l_surface_fill_black(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    lua_settop(L, 1);
    if(pCanvas->fill_black())
        return 1;
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->get_last_error());
    return 2;
}

static int l_surface_start_frame(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    lua_settop(L, 1);
    if(pCanvas->start_frame())
        return 1;
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->get_last_error());
    return 2;
}

static int l_surface_end_frame(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    lua_settop(L, 1);
    if(pCanvas->end_frame())
        return 1;
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->get_last_error());
    return 2;
}

static int l_surface_nonoverlapping(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    if(lua_isnone(L, 2) || lua_toboolean(L, 2) != 0)
        pCanvas->start_nonoverlapping_draws();
    else
        pCanvas->finish_nonoverlapping_draws();
    lua_settop(L, 1);
    return 1;
}

static int l_surface_set_blue_filter_active(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    pCanvas->set_blue_filter_active((lua_isnoneornil(L, 2) != 0) ? false : (lua_toboolean(L, 2) != 0));
    return 1;
}

static int l_surface_map(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    lua_pushnumber(L, (lua_Number)pCanvas->map_colour(
        (Uint8)luaL_checkinteger(L, 2),
        (Uint8)luaL_checkinteger(L, 3),
        (Uint8)luaL_checkinteger(L, 4)));
    return 1;
}

static int l_surface_rect(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    if(pCanvas->fill_rect(static_cast<uint32_t>(luaL_checkinteger(L, 2)),
        static_cast<int>(luaL_checkinteger(L, 3)), static_cast<int>(luaL_checkinteger(L, 4)), static_cast<int>(luaL_checkinteger(L, 5)),
        static_cast<int>(luaL_checkinteger(L, 6))))
    {
        lua_settop(L, 1);
        return 1;
    }
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->get_last_error());
    return 2;
}

static int l_surface_screenshot(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    const char *sFile = luaL_checkstring(L, 2);
    if(pCanvas->take_screenshot(sFile))
    {
        lua_settop(L, 1);
        return 1;
    }
    lua_pushnil(L);
    lua_pushstring(L, pCanvas->get_last_error());
    return 2;
}

static int l_surface_get_clip(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    clip_rect rcClip;
    pCanvas->get_clip_rect(&rcClip);
    lua_pushinteger(L, rcClip.x);
    lua_pushinteger(L, rcClip.y);
    lua_pushinteger(L, rcClip.w);
    lua_pushinteger(L, rcClip.h);
    return 4;
}

static int l_surface_set_clip(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    clip_rect rcClip;
    rcClip.x = static_cast<clip_rect::x_y_type>(luaL_checkinteger(L, 2));
    rcClip.y = static_cast<clip_rect::x_y_type>(luaL_checkinteger(L, 3));
    rcClip.w = static_cast<clip_rect::w_h_type>(luaL_checkinteger(L, 4));
    rcClip.h = static_cast<clip_rect::w_h_type>(luaL_checkinteger(L, 5));
    if(lua_toboolean(L, 6) != 0)
    {
        clip_rect rcExistingClip;
        pCanvas->get_clip_rect(&rcExistingClip);
        clip_rect_intersection(rcClip, rcExistingClip);
    }
    pCanvas->set_clip_rect(&rcClip);
    lua_settop(L, 1);
    return 1;
}

static int l_surface_scale(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    scaled_items eToScale = scaled_items::none;
    if(lua_isnoneornil(L, 3))
    {
        eToScale = scaled_items::all;
    }
    else
    {
        size_t iLength;
        const char* sOption = lua_tolstring(L, 3, &iLength);
        if(sOption && iLength >= 6 && std::memcmp(sOption, "bitmap", 6) == 0)
        {
            eToScale = scaled_items::bitmaps;
        }
        else
            luaL_error(L, "Expected \"bitmap\" as 2nd argument");
    }
    lua_pushboolean(L, pCanvas->set_scale_factor(static_cast<float>(
        luaL_checknumber(L, 2)), eToScale) ? 1 : 0);
    return 1;
}

static int l_surface_set_caption(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    pCanvas->set_caption(luaL_checkstring(L, 2));

    lua_settop(L, 1);
    return 1;
}

static int l_surface_get_renderer_details(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    lua_pushstring(L, pCanvas->get_renderer_details());
    return 1;
}

// Lua to THRenderTarget->setWindowGrab
static int l_surface_set_capture_mouse(lua_State *L)
{
    render_target* pCanvas = luaT_testuserdata<render_target>(L);
    pCanvas->set_window_grab((lua_isnoneornil(L, 2) != 0) ? false : (lua_toboolean(L, 2) != 0));
    return 0;
}

static int l_line_new(lua_State *L)
{
    luaT_stdnew<line>(L);
    return 1;
}

static int l_move_to(lua_State *L)
{
    line* pLine = luaT_testuserdata<line>(L);
    pLine->move_to(luaL_optnumber(L, 2, 0), luaL_optnumber(L, 3, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_line_to(lua_State *L)
{
    line* pLine = luaT_testuserdata<line>(L);
    pLine->line_to(luaL_optnumber(L, 2, 0), luaL_optnumber(L, 3, 0));

    lua_settop(L, 1);
    return 1;
}

static int l_set_width(lua_State *L)
{
    line* pLine = luaT_testuserdata<line>(L);
    pLine->set_width(luaL_optnumber(L, 2, 1));

    lua_settop(L, 1);
    return 1;
}

static int l_set_colour(lua_State *L)
{
    line* pLine = luaT_testuserdata<line>(L);
    pLine->set_colour(static_cast<uint8_t>(luaL_optinteger(L, 2, 0)),
                     static_cast<uint8_t>(luaL_optinteger(L, 3, 0)),
                     static_cast<uint8_t>(luaL_optinteger(L, 4, 0)),
                     static_cast<uint8_t>(luaL_optinteger(L, 5, 255)));

    lua_settop(L, 1);
    return 1;
}

static int l_line_draw(lua_State *L)
{
    line* pLine = luaT_testuserdata<line>(L);
    render_target* pCanvas = luaT_testuserdata<render_target>(L, 2);
    pLine->draw(pCanvas, static_cast<int>(luaL_optinteger(L, 3, 0)), static_cast<int>(luaL_optinteger(L, 4, 0)));

    lua_settop(L, 1);
    return 1;
}

static int l_line_persist(lua_State *L)
{
    line* pLine = luaT_testuserdata<line>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    lua_persist_writer* pWriter = (lua_persist_writer*)lua_touserdata(L, 1);
    pLine->persist(pWriter);
    return 0;
}

static int l_line_depersist(lua_State *L)
{
    line* pLine = luaT_testuserdata<line>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    lua_persist_reader* pReader = (lua_persist_reader*)lua_touserdata(L, 1);
    pLine->depersist(pReader);
    return 0;
}

void lua_register_gfx(const lua_register_state *pState)
{
    // Palette
    luaT_class(palette, l_palette_new, "palette", lua_metatable::palette);
    luaT_setfunction(l_palette_load, "load");
    luaT_setfunction(l_palette_set_entry, "setEntry");
    luaT_endclass();

    // Raw bitmap
    luaT_class(raw_bitmap, l_rawbitmap_new, "bitmap", lua_metatable::bitmap);
    luaT_setfunction(l_rawbitmap_load, "load", lua_metatable::surface);
    luaT_setfunction(l_rawbitmap_set_pal, "setPalette", lua_metatable::palette);
    luaT_setfunction(l_rawbitmap_draw, "draw", lua_metatable::surface);
    luaT_endclass();

    // Sprite sheet
    luaT_class(sprite_sheet, l_spritesheet_new, "sheet", lua_metatable::sheet);
    luaT_setmetamethod(l_spritesheet_count, "len");
    luaT_setfunction(l_spritesheet_load, "load", lua_metatable::surface);
    luaT_setfunction(l_spritesheet_set_pal, "setPalette", lua_metatable::palette);
    luaT_setfunction(l_spritesheet_size, "size");
    luaT_setfunction(l_spritesheet_draw, "draw", lua_metatable::surface);
    luaT_setfunction(l_spritesheet_hittest, "hitTest");
    luaT_setfunction(l_spritesheet_isvisible, "isVisible");
    luaT_endclass();

    // Font
    // Also adapt the font proxy meta table (font_proxy_mt) in graphics.lua.
    luaT_class(font, l_font_new, "font", lua_metatable::font);
    luaT_setfunction(l_font_get_size, "sizeOf");
    luaT_setfunction(l_font_draw, "draw", lua_metatable::surface);
    luaT_setfunction(l_font_draw_wrapped, "drawWrapped", lua_metatable::surface);
    luaT_setfunction(l_font_draw_tooltip, "drawTooltip", lua_metatable::surface);
    luaT_endclass();

    // BitmapFont
    luaT_class(bitmap_font, l_bitmap_font_new, "bitmap_font", lua_metatable::bitmap_font);
    luaT_superclass(lua_metatable::font);
    luaT_setfunction(l_bitmap_font_set_spritesheet, "setSheet", lua_metatable::sheet);
    luaT_setfunction(l_bitmap_font_get_spritesheet, "getSheet", lua_metatable::sheet);
    luaT_setfunction(l_bitmap_font_set_sep, "setSeparation");
    luaT_endclass();

#ifdef CORSIX_TH_USE_FREETYPE2
    // FreeTypeFont
    luaT_class(freetype_font, l_freetype_font_new, "freetype_font", lua_metatable::freetype_font);
    luaT_superclass(lua_metatable::font);
    luaT_setfunction(l_freetype_font_set_spritesheet, "setSheet", lua_metatable::sheet);
    luaT_setfunction(l_freetype_font_set_face, "setFace");
    luaT_setfunction(l_freetype_font_get_copyright, "getCopyrightNotice");
    luaT_setfunction(l_freetype_font_clear_cache, "clearCache");
    luaT_endclass();
#endif

    // Layers
    luaT_class(layers, l_layers_new, "layers", lua_metatable::layers);
    luaT_setmetamethod(l_layers_get, "index");
    luaT_setmetamethod(l_layers_set, "newindex");
    luaT_setmetamethod(l_layers_persist, "persist");
    luaT_setmetamethod(l_layers_depersist, "depersist");
    luaT_endclass();

    // Cursor
    luaT_class(cursor, l_cursor_new, "cursor", lua_metatable::cursor);
    luaT_setfunction(l_cursor_load, "load", lua_metatable::sheet);
    luaT_setfunction(l_cursor_use, "use", lua_metatable::surface);
    luaT_setfunction(l_cursor_position, "setPosition", lua_metatable::surface);
    luaT_endclass();

    // Surface
    luaT_class(render_target, l_surface_new, "surface", lua_metatable::surface);
    luaT_setfunction(l_surface_update, "update");
    luaT_setfunction(l_surface_destroy, "destroy");
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
    luaT_setfunction(l_surface_set_capture_mouse, "setCaptureMouse");
    luaT_endclass();

    // Line
    luaT_class(line, l_line_new, "line", lua_metatable::line);
    luaT_setfunction(l_move_to, "moveTo");
    luaT_setfunction(l_line_to, "lineTo");
    luaT_setfunction(l_set_width, "setWidth");
    luaT_setfunction(l_set_colour, "setColour");
    luaT_setfunction(l_line_draw, "draw", lua_metatable::surface);
    luaT_setmetamethod(l_line_persist, "persist");
    luaT_setmetamethod(l_line_depersist, "depersist");
    luaT_endclass();
}
