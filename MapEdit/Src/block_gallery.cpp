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

#include "block_gallery.h"
#include <map>

BEGIN_EVENT_TABLE(RibbonBlockGallery, wxRibbonGallery)
EVT_BUTTON(wxID_ANY, RibbonBlockGallery::OnExtButton)
END_EVENT_TABLE()

RibbonBlockGallery::RibbonBlockGallery(wxWindow* parent, wxWindowID id)
: wxRibbonGallery(parent, id)
{
}

RibbonBlockGallery::~RibbonBlockGallery()
{
    _clearCategories();
}

#define FOREACH(container_t, itr_name, container_name) \
    for(container_t::iterator itr_name = container_name.begin(), \
        itr_name##_end = container_name.end(); itr_name != itr_name##_end; \
        ++itr_name)

void RibbonBlockGallery::_clearCategories()
{
    FOREACH(categorylist_t, itr, m_vCategories)
    {
        Unbind(wxEVT_COMMAND_MENU_SELECTED,
            &RibbonBlockGallery::OnToggleCategory, this, (**itr).iID);
        delete *itr;
    }
    m_vCategories.clear();
}

void RibbonBlockGallery::Populate(THSpriteSheet *pBlocks,
                                  const char* sCategory,
                                  const char* sSubCategory,
                                  lua_State* L,
                                  int iInfoIndex)
{
    m_vBlocks.clear();
    _clearCategories();
    typedef std::map<wxString, category_t*> category_map_t;
    category_map_t mapCategories;

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
                wxString sCategory(L"Miscellaneous");
                lua_rawgeti(L, -1, 3);
                if(lua_type(L, -1) == LUA_TSTRING)
                    sCategory = lua_tostring(L, -1);
                oBlock.pCategory = mapCategories[sCategory];
                if(oBlock.pCategory == NULL)
                {
                    oBlock.pCategory = new category_t;
                    oBlock.pCategory->bEnabled = true;
                    oBlock.pCategory->sName = sCategory;
                    oBlock.pCategory->iID = wxID_HIGHEST + 1 +
                        mapCategories.size();
                    Bind(wxEVT_COMMAND_MENU_SELECTED,
                        &RibbonBlockGallery::OnToggleCategory, this,
                        oBlock.pCategory->iID);
                    mapCategories[sCategory] = oBlock.pCategory;
                }
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

    FOREACH(category_map_t, itr, mapCategories)
    {
        m_vCategories.push_back(itr->second);
    }

    // Load block bitmaps
    wxSize szLargestBitmap(0, 0);
    FOREACH(blocklist_t, itr, m_vBlocks)
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
    FOREACH(blocklist_t, itr, m_vBlocks)
    {
        if(itr->bmpTrimmed.IsOk() && itr->bmpTrimmed.GetSize() != szLargestBitmap)
        {
            wxImage imgBlock = itr->bmpTrimmed.ConvertToImage();
            _expandImage(imgBlock, szLargestBitmap);
            itr->bmpTrimmed = wxBitmap(imgBlock);
        }
    }

    // Add blocks to gallery
    _repopulate();
}

void RibbonBlockGallery::_repopulate()
{
    Clear();
    FOREACH(blocklist_t, itr, m_vBlocks)
    {
        if(itr->pCategory->bEnabled && itr->bmpTrimmed.IsOk())
        {
            Append(itr->bmpTrimmed, itr->iBlock, (void*)&*itr);
        }
    }
    Realise();
}

void RibbonBlockGallery::OnToggleCategory(wxCommandEvent& evt)
{
    FOREACH(categorylist_t, itr, m_vCategories)
    {
        if((**itr).iID == evt.GetId())
        {
            (**itr).bEnabled = !(**itr).bEnabled;
            _repopulate();
            break;
        }
    }
}

bool RibbonBlockGallery::SelectAndMakeVisible(int iBlock)
{
    unsigned int iCount = GetCount();
    for(unsigned int i = 0; i < iCount; ++i)
    {
        wxRibbonGalleryItem *pItem = GetItem(i);
        block_t *pBlock = reinterpret_cast<block_t*>(GetItemClientData(pItem));
        if(pBlock->iBlock == iBlock)
        {
            SetSelection(pItem);
            EnsureVisible(pItem);
            return true;
        }
    }
    FOREACH(blocklist_t, itr, m_vBlocks)
    {
        if(itr->iBlock == iBlock && !itr->pCategory->bEnabled)
        {
            itr->pCategory->bEnabled = true;
            _repopulate();
            return SelectAndMakeVisible(iBlock);
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

void RibbonBlockGallery::OnExtButton(wxCommandEvent& evt)
{
    wxMenu mnCategories;
    FOREACH(categorylist_t, itr, m_vCategories)
    {
        mnCategories.AppendCheckItem((**itr).iID, (**itr).sName)
            ->Check((**itr).bEnabled);
    }
    PopupMenu(&mnCategories);
}
