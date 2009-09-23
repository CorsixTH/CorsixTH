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
#include "frmMain.h"

BEGIN_EVENT_TABLE(frmMain, wxFrame)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_FLOOR1, frmMain::_onFloorGallery1Select)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_FLOOR2, frmMain::_onFloorGallery2Select)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_WALL1, frmMain::_onWallGallery1Select)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_WALL2, frmMain::_onWallGallery2Select)
END_EVENT_TABLE()

frmMain::frmMain()
  : wxFrame(NULL, wxID_ANY, L"CorsixTH Map Editor",
            wxDefaultPosition, wxSize(640, 480))
{
    m_pRibbon = new wxRibbonBar(this);
    wxRibbonPage* pHomePage = new wxRibbonPage(m_pRibbon, wxID_ANY, L"Home");
    wxRibbonPanel* pFilePanel = new wxRibbonPanel(pHomePage, wxID_ANY, L"File",
        wxNullBitmap, wxDefaultPosition, wxDefaultSize, wxRIBBON_PANEL_NO_AUTO_MINIMISE);
    wxRibbonPage* pFloorPage = new wxRibbonPage(m_pRibbon, wxID_ANY, L"Floors");
    wxRibbonPanel* pFloorSimplePanel = new wxRibbonPanel(pFloorPage, wxID_ANY, L"Simple Tiles");
    m_pFloorGallery1 = new RibbonBlockGallery(pFloorSimplePanel, ID_GALLERY_FLOOR1);
    wxRibbonPanel* pFloorDecoratedPanel = new wxRibbonPanel(pFloorPage, wxID_ANY, L"Decorated Tiles");
    m_pFloorGallery2 = new RibbonBlockGallery(pFloorDecoratedPanel, ID_GALLERY_FLOOR2);
    wxRibbonPage* pWallPage = new wxRibbonPage(m_pRibbon, wxID_ANY, L"Walls");
    wxRibbonPanel* pWallWestPanel = new wxRibbonPanel(pWallPage, wxID_ANY, L"West");
    m_pWallGallery1 = new RibbonBlockGallery(pWallWestPanel, ID_GALLERY_WALL1);
    wxRibbonPanel* pWallNorthPanel = new wxRibbonPanel(pWallPage, wxID_ANY, L"North");
    m_pWallGallery2 = new RibbonBlockGallery(pWallNorthPanel, ID_GALLERY_WALL2);
    m_pRibbon->Realize();

    m_pGamePanel = new EmbeddedGamePanel(this);
    m_pGamePanel->setExtraLuaInitFunction(_l_init, this);
    m_pGamePanel->setLogWindow(m_pLogWindow = new frmLog);
    wxPoint ptLogWindow = GetPosition();
    ptLogWindow.x += GetSize().GetWidth();
    m_pLogWindow->SetPosition(ptLogWindow);

    wxSizer *pTopSizer = new wxBoxSizer(wxVERTICAL);
    pTopSizer->Add(m_pRibbon, 0, wxEXPAND);
    pTopSizer->Add(m_pGamePanel, 1, wxEXPAND);
    SetSizer(pTopSizer);
}

frmMain::~frmMain()
{
    m_pLogWindow->Close();
}

int frmMain::_l_init(lua_State *L)
{
    frmMain *pThis = reinterpret_cast<frmMain*>(lua_touserdata(L, 1));
    lua_newtable(L);
    lua_insert(L, 1);
    lua_rawseti(L, 1, 1);
    lua_replace(L, LUA_ENVIRONINDEX);

    lua_pushcfunction(L, _l_set_blocks);
    lua_setglobal(L, "MapEditorSetBlocks");
    lua_pushcfunction(L, _l_set_block_brush);
    lua_setglobal(L, "MapEditorSetBlockBrush");

    return 0;
}

int frmMain::_l_set_blocks(lua_State *L)
{
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    frmMain *pThis = reinterpret_cast<frmMain*>(lua_touserdata(L, -1));
    lua_pop(L, 1);

    luaL_checktype(L, 1, LUA_TUSERDATA);
    luaL_checktype(L, 2, LUA_TTABLE);

    THSpriteSheet *pSheet = reinterpret_cast<THSpriteSheet*>(lua_touserdata(L, 1));
    pThis->m_pFloorGallery1->Populate(pSheet, "floor", "simple", L, 2);
    pThis->m_pFloorGallery2->Populate(pSheet, "floor", "decorated", L, 2);
    pThis->m_pWallGallery1->Populate(pSheet, "wall", "west", L, 2);
    pThis->m_pWallGallery2->Populate(pSheet, "wall", "north", L, 2);
    pThis->m_pRibbon->Realize();
    pThis->Layout();

    return 0;
}

int frmMain::_l_set_block_brush(lua_State *L)
{
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    frmMain *pThis = reinterpret_cast<frmMain*>(lua_touserdata(L, -1));
    lua_pop(L, 1);

    int iBlock;

    if(pThis->m_pRibbon->GetActivePage() == 0)
        pThis->m_pRibbon->SetActivePage(1);

    wxRibbonGalleryEvent evt(wxEVT_COMMAND_RIBBONGALLERY_SELECTED);
    if(pThis->m_pRibbon->GetActivePage() == 1)
    {
        // Floor
        iBlock = luaL_checkint(L, 1);
        if(pThis->m_pFloorGallery1->SelectAndMakeVisible(iBlock))
        {
            pThis->m_pFloorGallery2->SetSelection(NULL);
            evt.SetGallery(pThis->m_pFloorGallery1);
        }
        else if(pThis->m_pFloorGallery2->SelectAndMakeVisible(iBlock))
        {
            pThis->m_pFloorGallery1->SetSelection(NULL);
            evt.SetGallery(pThis->m_pFloorGallery2);
        }
        else
            return 0;
    }
    else
    {
        // Wall
        iBlock = luaL_checkint(L, 2);
        if(pThis->m_pWallGallery1->SelectAndMakeVisible(iBlock))
        {
            pThis->m_pWallGallery2->SetSelection(NULL);
            evt.SetGallery(pThis->m_pWallGallery1);
        }
        else if(pThis->m_pWallGallery2->SelectAndMakeVisible(iBlock))
        {
            pThis->m_pWallGallery1->SetSelection(NULL);
            evt.SetGallery(pThis->m_pWallGallery2);
        }
        else
            return 0;
    }

    evt.SetId(evt.GetGallery()->GetId());
    evt.SetGalleryItem(evt.GetGallery()->GetSelection());
    pThis->ProcessEvent(evt);
    return 0;
}

void frmMain::_onFloorGallery1Select(wxRibbonGalleryEvent& evt)
{
    if(evt.GetGalleryItem() != NULL)
    {
        m_pFloorGallery2->SetSelection(NULL);
        int iBaseBlock;
        int iBlock = m_pFloorGallery1->GetBlock(evt.GetGalleryItem(), &iBaseBlock);
        if(iBaseBlock != 0)
            _setLuaBlockBrush(iBaseBlock, iBlock, 0);
        else
            _setLuaBlockBrush(iBlock, 0, 0);
    }
}

void frmMain::_onFloorGallery2Select(wxRibbonGalleryEvent& evt)
{
    if(evt.GetGalleryItem() != NULL)
    {
        m_pFloorGallery1->SetSelection(NULL);
        int iBaseBlock;
        int iBlock = m_pFloorGallery2->GetBlock(evt.GetGalleryItem(), &iBaseBlock);
        if(iBaseBlock != 0)
            _setLuaBlockBrush(iBaseBlock, iBlock, 0);
        else
            _setLuaBlockBrush(iBlock, 0, 0);
    }
}

void frmMain::_onWallGallery1Select(wxRibbonGalleryEvent& evt)
{
    if(evt.GetGalleryItem() != NULL)
    {
        m_pWallGallery2->SetSelection(NULL);
        int iBlock = m_pWallGallery1->GetBlock(evt.GetGalleryItem(), NULL);
        _setLuaBlockBrush(0, 0, iBlock);
    }
}

void frmMain::_onWallGallery2Select(wxRibbonGalleryEvent& evt)
{
    if(evt.GetGalleryItem() != NULL)
    {
        m_pWallGallery1->SetSelection(NULL);
        int iBlock = m_pWallGallery2->GetBlock(evt.GetGalleryItem(), NULL);
        _setLuaBlockBrush(0, iBlock, 0);
    }
}

void frmMain::_setLuaBlockBrush(int iBlockF, int iBlockW1, int iBlockW2)
{
    lua_State *L = m_pGamePanel->getLua();

    // _MAP_EDITOR:setBlockBrush(iBlockF, iBlockW1, iBlockW2)
    lua_getglobal(L, "_MAP_EDITOR");
    lua_getfield(L, -1, "setBlockBrush");
    lua_insert(L, -2);
    lua_pushinteger(L, iBlockF);
    lua_pushinteger(L, iBlockW1);
    lua_pushinteger(L, iBlockW2);
    lua_pcall(L, 4, 0, 0);
}
