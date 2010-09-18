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
#include <wx/file.h>

BEGIN_EVENT_TABLE(frmMain, wxFrame)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_FLOOR1, frmMain::_onFloorGallery1Select)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_FLOOR2, frmMain::_onFloorGallery2Select)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_WALL1, frmMain::_onWallGallery1Select)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_WALL2, frmMain::_onWallGallery2Select)
EVT_RIBBONBUTTONBAR_CLICKED(wxID_NEW, frmMain::_onNew)
EVT_RIBBONBUTTONBAR_CLICKED(wxID_OPEN, frmMain::_onOpen)
EVT_SIZE(frmMain::_onResize)
END_EVENT_TABLE()

frmMain::frmMain()
  : wxFrame(NULL, wxID_ANY, L"CorsixTH Map Editor",
            wxDefaultPosition, wxSize(640, 480))
{
    m_pRibbon = new wxRibbonBar(this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxRIBBON_BAR_FLOW_VERTICAL | wxRIBBON_BAR_SHOW_PAGE_LABELS);
    m_pRibbon->SetTabCtrlMargins(0, 0);
    m_pHomePage = new wxRibbonPage(m_pRibbon, wxID_ANY, L"Home");
    /*
    wxRibbonPanel* pFilePanel = new wxRibbonPanel(pHomePage, wxID_ANY, L"File",
        wxNullBitmap, wxDefaultPosition, wxDefaultSize, wxRIBBON_PANEL_NO_AUTO_MINIMISE);
    */
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

    wxSizer *pTopSizer = new wxBoxSizer(wxHORIZONTAL);
    pTopSizer->Add(m_pRibbon, 0, wxEXPAND);
    pTopSizer->Add(m_pGamePanel, 1, wxEXPAND);
    SetSizer(pTopSizer);
}

frmMain::~frmMain()
{
    m_pLogWindow->Close();
}

struct do_load_level_t
{
    const char* sData;
    size_t iLength;
};

void frmMain::_onNew(wxRibbonButtonBarEvent& evt)
{
    do_load_level_t oParams = {NULL, 0};
    lua_State* L = m_pGamePanel->getLua();
    if(lua_cpcall(L, _l_do_load, reinterpret_cast<void*>(&oParams)) != 0)
        lua_pop(L, 1);
    m_pGamePanel->Refresh();
}

void frmMain::_onOpen(wxRibbonButtonBarEvent& evt)
{
    wxString sDirectory;
    wxString sFilter = wxT("Theme Hospital maps (*.L[0-9]+)");
    char cSep = '|';
    for(int i = 0; i < 10; ++i)
    {
        sFilter += wxString::Format(L"%c*.L%i*", cSep, i);
        cSep = ';';
    }
    sFilter += wxT("|All files (*.*)|*.*");
    wxFileDialog oOpenDialog(this, wxFileSelectorPromptStr, sDirectory,
        wxEmptyString, sFilter, wxFD_OPEN | wxFD_FILE_MUST_EXIST);
    if(oOpenDialog.ShowModal() != wxID_OK)
        return;
    wxFile fFile;
    if(!fFile.Open(oOpenDialog.GetPath()))
        return;
    size_t iLength = static_cast<size_t>(fFile.Length());
    char* sData = new (std::nothrow) char[iLength];
    if(!sData)
        return;
    if(fFile.Read(sData, iLength) != iLength)
    {
        delete[] sData;
        return;
    }
    do_load_level_t oParams = {sData, iLength};
    lua_State* L = m_pGamePanel->getLua();
    if(lua_cpcall(L, _l_do_load, reinterpret_cast<void*>(&oParams)) != 0)
        lua_pop(L, 1);
    delete[] sData;
    m_pGamePanel->Refresh();
}

int frmMain::_l_do_load(lua_State *L)
{
    lua_getglobal(L, "TheApp");
    lua_getfield(L, -1, "loadLevel");
    lua_insert(L, -2);
    do_load_level_t *pParams = reinterpret_cast<do_load_level_t*>(lua_touserdata(L, 1));
    size_t iLength = pParams->iLength;
    const char* sData = pParams->sData;
    lua_pushlstring(L, sData, iLength);
    if(iLength >= 3 && sData[0] == 'R' && sData[1] == 'N' && sData[2] == 'C')
    {
        lua_getglobal(L, "require");
        lua_pushliteral(L, "rnc");
        lua_call(L, 1, 1);
        lua_getfield(L, -1, "decompress");
        lua_insert(L, -3);
        lua_call(L, 2, 1);
    }
    lua_call(L, 2, 0);
    return 0;
}

void frmMain::_onResize(wxSizeEvent& evt)
{
    wxRect rcLogWindow = wxRect(GetPosition(), m_pLogWindow->GetSize());
    rcLogWindow.x += evt.GetSize().GetWidth();
    rcLogWindow.height = evt.GetSize().GetHeight();
    m_pLogWindow->SetSize(rcLogWindow);
    evt.Skip();
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

    lua_pushcfunction(L, _l_init_with_lua_app);
    lua_setglobal(L, "MapEditorInitWithLuaApp");

    return 0;
}

class FullSizeButtonBar : public wxRibbonButtonBar
{
public:
    FullSizeButtonBar(wxWindow* parent, wxWindowID id)
        : wxRibbonButtonBar(parent, id)
    {
    }

    virtual wxSize GetMinSize() const
    {
        return DoGetBestSize();
    }

protected:
    virtual wxSize DoGetNextSmallerSize(wxOrientation direction,
                                      wxSize relative_to) const
    {
        return relative_to;
    }
};

int frmMain::_l_init_with_lua_app(lua_State *L)
{
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    frmMain *pThis = reinterpret_cast<frmMain*>(lua_touserdata(L, -1));
    lua_pop(L, 1);

    lua_getfield(L, 1, "getBitmapDir");
    lua_pushvalue(L, 1);
    lua_call(L, 1, 1);
    wxString sBitmapDir = lua_tostring(L, -1);
    lua_pop(L, 1);

    wxRibbonPage* pHomePage = pThis->m_pHomePage;
    wxRibbonPanel* pFilePanel = new wxRibbonPanel(pHomePage, wxID_ANY, wxT("File"));
    wxRibbonButtonBar* pFileButtons = new FullSizeButtonBar(pFilePanel, wxID_ANY);
#define BITMAP(name) wxBitmap(sBitmapDir + (wxT(name) wxT("32.png")), wxBITMAP_TYPE_PNG)
    pFileButtons->AddButton(wxID_NEW, wxT("New"), BITMAP("new"));
    pFileButtons->AddButton(wxID_OPEN, wxT("Load"), BITMAP("open"));
    pFileButtons->AddHybridButton(wxID_SAVE, wxT("Save"), BITMAP("save"));
#undef BITMAP
    pThis->m_pRibbon->Realise();

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
