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
#include <wx/ribbon/gallery.h>
#include <vector>
#include "game.h"

class RibbonBlockGallery : public wxRibbonGallery
{
public:
    RibbonBlockGallery(wxWindow* parent, wxWindowID id = wxID_ANY);
    ~RibbonBlockGallery();

    void Populate(THSpriteSheet *pBlocks, const char* sCategory,
        const char* sSubCategory, lua_State* L, int iInfoIndex);

    bool SelectAndMakeVisible(int iBlock);

    int GetBlock(wxRibbonGalleryItem* pItem, int* pBaseBlock);

    void OnExtButton(wxCommandEvent& evt);
    void OnToggleCategory(wxCommandEvent& evt);

protected:
    struct category_t
    {
        wxString sName;
        bool bEnabled;
        int iID;
    };
    struct block_t
    {
        wxBitmap bmpTrimmed;
        category_t* pCategory;
        int iBlock;
        int iBaseBlock;
    };

    // wxWidgets encourages use of wxArray over std::vector, but this isn't in
    // wxWidgets core (and never will be), so it doesn't matter ^_^
    typedef std::vector<block_t> blocklist_t;
    typedef std::vector<category_t*> categorylist_t;

    blocklist_t m_vBlocks;
    categorylist_t m_vCategories;

    void _trimImage(wxImage& image);
    void _expandImage(wxImage& image, wxSize size);
    void _clearCategories();
    void _repopulate();

    DECLARE_EVENT_TABLE();
};
