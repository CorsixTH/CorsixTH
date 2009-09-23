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

#pragma once
// For compilers that support precompilation, includes "wx/wx.h".
#include "wx/wxprec.h"

#ifdef __BORLANDC__
    #pragma hdrstop
#endif

// for all others, include the necessary headers (this file is usually all you
// need because it includes almost all "standard" wxWidgets headers)
#ifndef WX_PRECOMP
    #include "wx/wx.h"
#endif
// ----------------------------
#include "block_gallery.h"

RibbonBlockGallery::RibbonBlockGallery(wxWindow* parent, wxWindowID id)
: wxRibbonGallery(parent, id)
{
}

void RibbonBlockGallery::Populate(THSpriteSheet *pBlocks,
                                  const char* sCategory,
                                  const char* sSubCategory,
                                  lua_State* L,
                                  int iInfoIndex)
{
    Clear();
    m_vBlocks.clear();

    // Extract relevant block information from Lua
    if(LUA_REGISTRYINDEX < iInfoIndex && iInfoIndex < 0)
        iInfoIndex = lua_gettop(L) + 1 + iInfoIndex;
    lua_pushstring(L, sCategory);
    int iCategoryIndex = lua_gettop(L);
    lua_pushstring(L, sSubCategory);
    lua_pushnil(L);
    int iBaseIndex = lua_gettop(L);
    while(lua_next(L, iInfoIndex) != 0)
    {
        lua_rawgeti(L, -1, 1);
        if(lua_equal(L, -1, iCategoryIndex))
        {
            lua_pop(L, 1);
            lua_rawgeti(L, -1, 2);
            if(lua_equal(L, -1, iCategoryIndex + 1))
            {
                lua_pop(L, 1);
                block_t oBlock;
                oBlock.iBlock = lua_tointeger(L, -2);
                oBlock.iBaseBlock = 0;
                oBlock.sCategory = L"Miscellaneous";
                lua_rawgeti(L, -1, 3);
                if(lua_type(L, -1) == LUA_TSTRING)
                    oBlock.sCategory = lua_tostring(L, -1);
                lua_pop(L, 1);
                lua_getfield(L, -1, "base");
                if(lua_type(L, -1) == LUA_TNUMBER)
                    oBlock.iBaseBlock = lua_tointeger(L, -1);
                lua_pop(L, 1);
                m_vBlocks.push_back(oBlock);
            }
        }
        lua_settop(L, iBaseIndex);
    }
    lua_pop(L, 2);

    // Load block bitmaps
    wxSize szLargestBitmap(0, 0);
    for(blocklist_t::iterator itr = m_vBlocks.begin(), itr_end = m_vBlocks.end(); itr != itr_end; ++itr)
    {
        unsigned int iWidth, iHeight;
        if(!pBlocks->getSpriteSize(itr->iBlock, &iWidth, &iHeight))
            continue;

        wxImage imgBlock(iWidth, iHeight);
        if(!imgBlock.HasAlpha())
            imgBlock.InitAlpha();

        pBlocks->wxDrawSprite(itr->iBlock, imgBlock.GetData(), imgBlock.GetAlpha());
        _trimImage(imgBlock);
        if(imgBlock.GetWidth() > szLargestBitmap.GetWidth())
            szLargestBitmap.SetWidth(imgBlock.GetWidth());
        if(imgBlock.GetHeight() > szLargestBitmap.GetHeight())
            szLargestBitmap.SetHeight(imgBlock.GetHeight());
        itr->bmpTrimmed = wxBitmap(imgBlock);
    }

    // Make block bitmaps equally sized
    for(blocklist_t::iterator itr = m_vBlocks.begin(), itr_end = m_vBlocks.end(); itr != itr_end; ++itr)
    {
        if(itr->bmpTrimmed.IsOk() && itr->bmpTrimmed.GetSize() != szLargestBitmap)
        {
            wxImage imgBlock = itr->bmpTrimmed.ConvertToImage();
            _expandImage(imgBlock, szLargestBitmap);
            itr->bmpTrimmed = wxBitmap(imgBlock);
        }
    }

    // Add blocks to gallery
    for(blocklist_t::iterator itr = m_vBlocks.begin(), itr_end = m_vBlocks.end(); itr != itr_end; ++itr)
    {
        if(itr->bmpTrimmed.IsOk())
        {
            Append(itr->bmpTrimmed, itr->iBlock, (void*)&*itr);
        }
    }
}

bool RibbonBlockGallery::SelectAndMakeVisible(int iBlock)
{
    unsigned int iCount = GetCount();
    for(unsigned int i = 0; i < iCount; ++i)
    {
        wxRibbonGalleryItem *pItem = GetItem(i);
        if(reinterpret_cast<block_t*>(GetItemClientData(pItem))->iBlock == iBlock)
        {
            SetSelection(pItem);
            EnsureVisible(pItem);
            return true;
        }
    }
    return false;
}

int RibbonBlockGallery::GetBlock(wxRibbonGalleryItem* pItem, int* pBaseBlock)
{
    block_t *pBlock = reinterpret_cast<block_t*>(GetItemClientData(pItem));
    if(pBaseBlock)
        *pBaseBlock = pBlock->iBaseBlock;
    return pBlock->iBlock;
}

void RibbonBlockGallery::_trimImage(wxImage& image)
{
    int iOpaqueTop = 0;
    int iOpaqueBottom = image.GetHeight() - 1;
    int iOpaqueLeft = 0;
    int iOpaqueRight = image.GetWidth() - 1;

    for(; iOpaqueTop <= iOpaqueBottom; ++iOpaqueTop)
    {
        for(int iX = iOpaqueLeft; iX <= iOpaqueRight; ++iX)
        {
            if(!image.IsTransparent(iX, iOpaqueTop))
                goto break1;
        }
    }
break1:;

    for(; iOpaqueBottom >= iOpaqueTop; --iOpaqueBottom)
    {
        for(int iX = iOpaqueLeft; iX <= iOpaqueRight; ++iX)
        {
            if(!image.IsTransparent(iX, iOpaqueBottom))
                goto break2;
        }
    }
break2:;

    for(; iOpaqueLeft <= iOpaqueRight; ++iOpaqueLeft)
    {
        for(int iY = iOpaqueTop; iY <= iOpaqueBottom; ++iY)
        {
            if(!image.IsTransparent(iOpaqueLeft, iY))
                goto break3;
        }
    }
break3:;

    for(; iOpaqueRight >= iOpaqueLeft; --iOpaqueRight)
    {
        for(int iY = iOpaqueTop; iY <= iOpaqueBottom; ++iY)
        {
            if(!image.IsTransparent(iOpaqueRight, iY))
                goto break4;
        }
    }
break4:;

    image = image.Size(wxSize(iOpaqueRight - iOpaqueLeft + 1, iOpaqueBottom - iOpaqueTop + 1),
        wxPoint(-iOpaqueLeft, -iOpaqueTop));
}

void RibbonBlockGallery::_expandImage(wxImage& image, wxSize size)
{
    image = image.Size(size, wxPoint(
        (size.GetWidth() - image.GetWidth()) / 2,
        size.GetHeight() - image.GetHeight()
    ));
}
