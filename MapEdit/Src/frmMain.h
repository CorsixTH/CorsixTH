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
#include "scrollable_game.h"
#include <wx/ribbon/bar.h>
#include <wx/ribbon/buttonbar.h>
#include "block_gallery.h"

class frmMain : public wxFrame
{
public:
    frmMain();
    ~frmMain();

    enum
    {
        ID_GALLERY_FLOOR1 = wxID_HIGHEST + 1,
        ID_GALLERY_FLOOR2,
        ID_GALLERY_WALL1,
        ID_GALLERY_WALL2,
        ID_GALLERY_PARCELS,
        ID_VIEW_WALLS,
        ID_VIEW_FLAGS,
        ID_VIEW_PARCELS,
        ID_VIEW_POSITIONS,
        ID_PARCEL_PANEL,
        ID_SAVE_IN_DROPDOWN,
        ID_SAVEAS
    };

protected:
    wxRibbonBar* m_pRibbon;
    wxRibbonPage* m_pHomePage;
    frmLog* m_pLogWindow;
    ScrollableGamePanel* m_pGamePanel;
    RibbonBlockGallery* m_pFloorGallery1;
    RibbonBlockGallery* m_pFloorGallery2;
    RibbonBlockGallery* m_pWallGallery1;
    RibbonBlockGallery* m_pWallGallery2;
    wxString m_sFrameCaption;
    wxString m_sFilename;
    bool m_bViewFlags;
    bool m_bViewParcels;
    bool m_bViewPositions;
    bool m_bViewWalls;
    int m_iFloorTabBrushF;
    int m_iFloorTabBrushW1;
    int m_iFloorTabBrushW2;
    int m_iWallsTabBrushF;
    int m_iWallsTabBrushW1;
    int m_iWallsTabBrushW2;
    int m_iParcelBrush;

    void _applyViewWalls();
    void _applyViewOverlay();
    wxString _getMapsDirectory();
    wxString _getMapsFilter();
    void _setFilename(const wxString& sFilename);
    void _onFloorGallery1Select(wxRibbonGalleryEvent& evt);
    void _onFloorGallery2Select(wxRibbonGalleryEvent& evt);
    void _onWallGallery1Select(wxRibbonGalleryEvent& evt);
    void _onWallGallery2Select(wxRibbonGalleryEvent& evt);
    void _onParcelGallerySelect(wxRibbonGalleryEvent& evt);
    void _onNew(wxRibbonButtonBarEvent& evt);
    void _onOpen(wxRibbonButtonBarEvent& evt);
    void _onSave(wxRibbonButtonBarEvent& evt);
    void _onSaveMenu(wxRibbonButtonBarEvent& evt);
    void _onSaveMenuSave(wxCommandEvent& evt);
    void _onSaveMenuSaveAs(wxCommandEvent& evt);
    void _onResize(wxSizeEvent& evt);
    void _onViewWalls(wxRibbonButtonBarEvent& evt);
    void _onViewFlags(wxRibbonButtonBarEvent& evt);
    void _onViewParcels(wxRibbonButtonBarEvent& evt);
    void _onViewPositions(wxRibbonButtonBarEvent& evt);
    void _onRibbonPageChanged(wxRibbonBarEvent& evt);
    void _populateParcelGallery(wxRibbonGallery* pGallery);
    static wxBitmap _asBitmap(THSpriteSheet* pSheet, unsigned int iSprite);
    static int _l_init(lua_State *L);
    static int _l_init_with_lua_app(lua_State *L);
    static int _l_set_blocks(lua_State *L);
    static int _l_set_block_brush(lua_State *L);
    static int _l_do_load(lua_State *L);
    void _setLuaBlockBrushFloorTab(int iBlockF, int iBlockW1, int iBlockW2);
    void _setLuaBlockBrushWallsTab(int iBlockF, int iBlockW1, int iBlockW2);
    void _setLuaBlockBrushFloorTab();
    void _setLuaBlockBrushWallsTab();
    void _setLuaBlockBrush(int iBlockF, int iBlockW1, int iBlockW2);
    void _setLuaParcelBrush(int iParcel);

    DECLARE_EVENT_TABLE();
};
