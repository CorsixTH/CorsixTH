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
#include "th_map_wrapper.h"
#include <wx/file.h>
#include <wx/filename.h>

BEGIN_EVENT_TABLE(frmMain, wxFrame)
EVT_RIBBONBAR_PAGE_CHANGED(wxID_ANY, frmMain::_onRibbonPageChanged)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_FLOOR1, frmMain::_onFloorGallery1Select)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_FLOOR2, frmMain::_onFloorGallery2Select)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_WALL1, frmMain::_onWallGallery1Select)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_WALL2, frmMain::_onWallGallery2Select)
EVT_RIBBONGALLERY_SELECTED(ID_GALLERY_PARCELS, frmMain::_onParcelGallerySelect)
EVT_RIBBONBUTTONBAR_CLICKED(wxID_NEW, frmMain::_onNew)
EVT_RIBBONBUTTONBAR_CLICKED(wxID_OPEN, frmMain::_onOpen)
EVT_RIBBONBUTTONBAR_CLICKED(wxID_SAVE, frmMain::_onSave)
EVT_RIBBONBUTTONBAR_CLICKED(wxID_UNDO, frmMain::_onUndo)
EVT_RIBBONBUTTONBAR_CLICKED(wxID_REDO, frmMain::_onRedo)
EVT_RIBBONBUTTONBAR_DROPDOWN_CLICKED(wxID_SAVE, frmMain::_onSaveMenu)
EVT_MENU(ID_SAVE_IN_DROPDOWN, frmMain::_onSaveMenuSave)
EVT_MENU(ID_SAVEAS, frmMain::_onSaveMenuSaveAs)
EVT_RIBBONBUTTONBAR_CLICKED(ID_VIEW_WALLS, frmMain::_onViewWalls)
EVT_RIBBONBUTTONBAR_CLICKED(ID_VIEW_FLAGS, frmMain::_onViewFlags)
EVT_RIBBONBUTTONBAR_CLICKED(ID_VIEW_PARCELS, frmMain::_onViewParcels)
EVT_RIBBONBUTTONBAR_CLICKED(ID_VIEW_POSITIONS, frmMain::_onViewPositions)
EVT_SIZE(frmMain::_onResize)
END_EVENT_TABLE()

frmMain::frmMain()
  : wxFrame(NULL, wxID_ANY, L"CorsixTH Map Editor",
            wxDefaultPosition, wxSize(800, 600))
{
    m_sFrameCaption = wxFrame::GetTitle();
    _setFilename(wxEmptyString);

	wxSizer *pMainSizer = new wxBoxSizer(wxVERTICAL);
	wxSplitterWindow* pSplitter = new wxSplitterWindow(this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxSP_3D);
	pSplitter->SetMinimumPaneSize(250);
	wxPanel *pLeftPanel = new wxPanel(pSplitter, wxID_ANY, wxDefaultPosition, wxDefaultSize);
	wxPanel *pRightPanel = new wxPanel(pSplitter, wxID_ANY, wxDefaultPosition, wxDefaultSize);
	wxSizer *pLeftSizer = new wxBoxSizer(wxVERTICAL);
	wxSizer *pRightSizer = new wxBoxSizer(wxVERTICAL);

    m_pRibbon = new wxRibbonBar(pLeftPanel, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxRIBBON_BAR_FLOW_VERTICAL | wxRIBBON_BAR_SHOW_PAGE_LABELS);
    m_pRibbon->SetArtProvider(new wxRibbonMSWArtProvider);
    m_pRibbon->SetTabCtrlMargins(0, 0);
    m_pHomePage = new wxRibbonPage(m_pRibbon, wxID_ANY, L"Home");
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

    m_pGamePanel = new ScrollableGamePanel(pRightPanel);
    m_pGamePanel->setExtraLuaInitFunction(_l_init, this);
    m_pGamePanel->setLogWindow(m_pLogWindow = new frmLog);
    wxPoint ptLogWindow = GetPosition();
    ptLogWindow.x += GetSize().GetWidth();
    m_pLogWindow->SetPosition(ptLogWindow);

	pLeftSizer->Add(m_pRibbon, 1, wxALL | wxEXPAND);
	pRightSizer->Add(m_pGamePanel, 1, wxALL | wxEXPAND);
	pLeftPanel->SetSizer(pLeftSizer);
	pRightPanel->SetSizer(pRightSizer);
	pSplitter->SplitVertically(pLeftPanel,pRightPanel);
	pSplitter->SetSashPosition(250);
	pMainSizer->Add(pSplitter, 1, wxEXPAND);

	SetSizer(pMainSizer);
}

void frmMain::_setFilename(const wxString& sFilename)
{
    m_sFilename = sFilename;
    wxString sShortName("Untitled");
    wxFileName oFilename(sFilename);
    if(!oFilename.GetFullName().empty())
        sShortName = oFilename.GetFullName();
    SetTitle(m_sFrameCaption + wxT(" - ") + sShortName);
}

frmMain::~frmMain()
{
    m_pLogWindow->Close();
}

void frmMain::_onRibbonPageChanged(wxRibbonBarEvent& evt)
{
    switch(m_pRibbon->GetActivePage())
    {
    case 0:
        if(m_bViewParcels)
            _setLuaParcelBrush(m_iParcelBrush);
        break;
    case 1:
        _setLuaBlockBrushFloorTab();
        break;
    case 2:
        _setLuaBlockBrushWallsTab();
        break;
    }
}

struct do_load_level_t
{
    const char* sData;
    size_t iLength;
    frmMain* pThis;
};

void frmMain::_onNew(wxRibbonButtonBarEvent& evt)
{
    do_load_level_t oParams = {NULL, 0, this};
    lua_State* L = m_pGamePanel->getLua();
    if(lua_cpcall(L, _l_do_load, reinterpret_cast<void*>(&oParams)) != 0)
        lua_pop(L, 1);
    _setFilename(wxEmptyString);
    m_pGamePanel->Refresh();
}

wxString frmMain::_getMapsDirectory()
{
    return wxEmptyString;
}

wxString frmMain::_getMapsFilter()
{
    wxString sFilter = wxT("Theme Hospital maps (*.L[0-9]+)|");
    // *.L[0-9]* isn't quite the right filter, but it is as close as reasonably
    // possible to *.L[0-9]+ which file filters can reasonably get
    wxString sTHMapEndings = wxT("");
    char cSep = ';';
    for(int i = 0; i < 10; ++i)
    {
        if(i == 9) cSep = '|';
        sTHMapEndings += wxString::Format(L"*.L%i*%c", i, cSep);
    }
    sFilter += sTHMapEndings;
    sFilter += wxT("CorsixTH maps (*.map)|*.map|");
    sFilter += wxT("All maps (*.map, *.L[0-9]+)|*.map;");
    sFilter += sTHMapEndings;
    sFilter += wxT("All files (*.*)|*.*");
    return sFilter;
}

void frmMain::_onOpen(wxRibbonButtonBarEvent& evt)
{
    wxString sDirectory = _getMapsDirectory();
    wxString sFilter = _getMapsFilter();
    wxFileDialog oOpenDialog(this, wxFileSelectorPromptStr, sDirectory,
        wxEmptyString, sFilter, wxFD_OPEN | wxFD_FILE_MUST_EXIST);
    oOpenDialog.SetFilterIndex(2);
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
    do_load_level_t oParams = {sData, iLength, this};
    lua_State* L = m_pGamePanel->getLua();
    if(lua_cpcall(L, _l_do_load, reinterpret_cast<void*>(&oParams)) != 0)
        lua_pop(L, 1);
    delete[] sData;
    _setFilename(oOpenDialog.GetPath());
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

    pParams->pThis->_applyViewWalls();
    pParams->pThis->_applyViewOverlay();

    return 0;
}

void frmMain::_onSave(wxRibbonButtonBarEvent& evt)
{
    wxCommandEvent dummy;
    _onSaveMenuSave(dummy);
}

void frmMain::_onSaveMenu(wxRibbonButtonBarEvent& evt)
{
    wxMenu mnuPopup;
    mnuPopup.Append(ID_SAVE_IN_DROPDOWN, "Save");
    mnuPopup.Append(ID_SAVEAS, "Save As");
    evt.PopupMenu(&mnuPopup);
}

void frmMain::_onUndo(wxRibbonButtonBarEvent& evt)
{
	_doLuaUndo();
}
void frmMain::_onRedo(wxRibbonButtonBarEvent& evt)
{
	_doLuaRedo();
}


struct map_save_t
{
    wxFile fFile;

    static void writer(void* pThis_, const unsigned char* pData, size_t iLen)
    {
        map_save_t* pThis = reinterpret_cast<map_save_t*>(pThis_);
        pThis->fFile.Write(reinterpret_cast<const void*>(pData), iLen);
    }
};

void frmMain::_onSaveMenuSave(wxCommandEvent& evt)
{
    if(m_sFilename.empty())
    {
        _onSaveMenuSaveAs(evt);
        return;
    }

    map_save_t oSave;
    if(oSave.fFile.Open(m_sFilename, wxFile::write))
    {
        lua_State* L = m_pGamePanel->getLua();
        luaT_execute(L, "return TheApp.world.map.th");
        THMap *pMap = reinterpret_cast<THMap*>(lua_touserdata(L, -1));
        lua_pop(L, 1);
        THMapWrapper::autoSetHelipad(pMap);
        luaT_execute(L, "return TheApp.ui:ScreenToWorld(...)",
            m_pGamePanel->GetSize().GetWidth() / 2,
            m_pGamePanel->GetSize().GetHeight() / 2);
        int iCameraX = (int)lua_tointeger(L, -2);
        int iCameraY = (int)lua_tointeger(L, -1);
        lua_pop(L, 2);
        pMap->setPlayerCameraTile(0, iCameraX, iCameraY);
        pMap->save(map_save_t::writer, reinterpret_cast<void*>(&oSave));
        ::wxMessageBox(wxT("Map saved."), wxT("Save"), wxOK | wxCENTER |
            wxICON_INFORMATION, this);
    }
}

void frmMain::_onSaveMenuSaveAs(wxCommandEvent& evt)
{
    wxString sDirectory = _getMapsDirectory();
    wxString sFilter = _getMapsFilter();
    wxFileDialog oSaveDialog(this, wxFileSelectorPromptStr, sDirectory,
        m_sFilename, sFilter, wxFD_SAVE | wxFD_OVERWRITE_PROMPT);
    oSaveDialog.SetFilterIndex(2);
    if(oSaveDialog.ShowModal() != wxID_OK)
        return;
    _setFilename(oSaveDialog.GetPath());
    _onSaveMenuSave(evt);
}

void frmMain::_onViewWalls(wxRibbonButtonBarEvent& evt)
{
    m_bViewWalls = evt.IsChecked();
    _applyViewWalls();
    m_pGamePanel->Refresh();
}

void frmMain::_onViewFlags(wxRibbonButtonBarEvent& evt)
{
    m_bViewFlags = evt.IsChecked();
    _applyViewOverlay();
    m_pGamePanel->Refresh();
}

void frmMain::_onViewParcels(wxRibbonButtonBarEvent& evt)
{
    m_bViewParcels = evt.IsChecked();
    _applyViewOverlay();
    m_pGamePanel->Refresh();

    if(evt.IsChecked())
    {
        wxRibbonPanel* pParcelPanel = new wxRibbonPanel(m_pHomePage,
            ID_PARCEL_PANEL, L"Parcels");
        wxRibbonGallery* pParcelGallery = new wxRibbonGallery(pParcelPanel,
            ID_GALLERY_PARCELS);
        _populateParcelGallery(pParcelGallery);
    }
    else
    {
        wxWindow* pParcelPanel = m_pHomePage->FindWindow(ID_PARCEL_PANEL);
        if(pParcelPanel)
            pParcelPanel->Destroy();
    }
    m_pRibbon->Realize();
}

void frmMain::_onViewPositions(wxRibbonButtonBarEvent& evt)
{
    m_bViewPositions = evt.IsChecked();
    _applyViewOverlay();
    m_pGamePanel->Refresh();
}

wxBitmap frmMain::_asBitmap(THSpriteSheet* pSheet, unsigned int iSprite)
{
    unsigned int iWidth, iHeight;
    pSheet->getSpriteSize(iSprite, &iWidth, &iHeight);
    wxImage imgSprite;
    imgSprite.Create(iWidth, iHeight);
    if(!imgSprite.HasAlpha())
        imgSprite.InitAlpha();
    pSheet->wxDrawSprite(iSprite, imgSprite.GetData(), imgSprite.GetAlpha());
    return wxBitmap(imgSprite);
}

void frmMain::_populateParcelGallery(wxRibbonGallery* pGallery)
{
    THSpriteSheet *pBlocksSheet;
    THSpriteSheet *pOutlineSheet;
    THSpriteSheet *pFontSheet;
    {
        lua_State *L = m_pGamePanel->getLua();
        luaT_execute(L, "return TheApp.map.blocks");
        pBlocksSheet = reinterpret_cast<THSpriteSheet*>(lua_touserdata(L, -1));
        luaT_execute(L, "return TheApp.map.cell_outline");
        pOutlineSheet = reinterpret_cast<THSpriteSheet*>(lua_touserdata(L, -1));
        luaT_execute(L, "return TheApp.gfx:loadBuiltinFont()");
        pFontSheet = reinterpret_cast<THBitmapFont*>(lua_touserdata(L, -1))
            ->getSpriteSheet();
        lua_pop(L, 3);
    }

    wxBitmap bmOutline(_asBitmap(pBlocksSheet, 74));
    wxMemoryDC dcMem;
    dcMem.SelectObject(bmOutline);
    for(int i = 0; i < 4; ++i)
    {
        dcMem.DrawBitmap(_asBitmap(pOutlineSheet, 18 + i), 0, 0);
    }
    dcMem.SelectObject(wxNullBitmap);

    wxBitmap bmNumbers[10];
    for(int i = 0; i < 10; ++i)
    {
        bmNumbers[i] = _asBitmap(pFontSheet, '0' + i - 31);
    }

    for(intptr_t iParcel = 0; iParcel < 32; ++iParcel)
    {
        wxBitmap bmParcel(bmOutline);
        dcMem.SelectObject(bmParcel);

        char sMsg[8];
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable: 4996)
#endif
        sprintf(sMsg, "%i", iParcel);
#ifdef _MSC_VER
#pragma warning(pop)
#endif
        int iX = 0, iY = 0;
        for(char* s = sMsg; *s; ++s)
        {
            wxBitmap& bm = bmNumbers[*s - '0'];
            iX += bm.GetWidth();
            iY = std::max(iY, bm.GetHeight());
        }
        iX = (bmParcel.GetWidth() - iX) / 2;
        iY = (bmParcel.GetHeight() - iY) / 2;

        for(char* s = sMsg; *s; ++s)
        {
            wxBitmap& bm = bmNumbers[*s - '0'];
            dcMem.DrawBitmap(bm, iX, iY);
            iX += bm.GetWidth();
        }

        dcMem.SelectObject(wxNullBitmap);
        pGallery->SetItemClientData(pGallery->Append(bmParcel, iParcel),
            reinterpret_cast<void*>(iParcel));
    }
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

    THMapWrapper::wrap(L);

    // Create a new environment table: {
    //   [1] = <light userdata pThis>,
    // }
    lua_newtable(L);
    lua_insert(L, 1);
    lua_rawseti(L, 1, 1);
    lua_replace(L, LUA_ENVIRONINDEX);
    // NB: Following functions registered with above environment table

    luaT_execute(L, "MapEditorSetBlocks = ...", _l_set_blocks);
    luaT_execute(L, "MapEditorSetBlockBrush = ...", _l_set_block_brush);
    luaT_execute(L, "MapEditorInitWithLuaApp = ...", _l_init_with_lua_app);

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
	pFileButtons->AddButton(wxID_UNDO, wxT("Undo"), BITMAP("undo"));
	pFileButtons->AddButton(wxID_REDO, wxT("Redo"), BITMAP("redo"));


    wxRibbonPanel* pViewPanel = new wxRibbonPanel(pHomePage, wxID_ANY, wxT("View"));
    wxRibbonButtonBar* pViewButtons = new FullSizeButtonBar(pViewPanel, wxID_ANY);
    pViewButtons->AddToggleButton(ID_VIEW_WALLS, wxT("Walls"), BITMAP("transparent_walls"));
    pViewButtons->ToggleButton(ID_VIEW_WALLS, pThis->m_bViewWalls = true);
    pViewButtons->AddToggleButton(ID_VIEW_FLAGS, wxT("Flags"), BITMAP("flags"));
    pViewButtons->ToggleButton(ID_VIEW_FLAGS, pThis->m_bViewFlags = false);
    pViewButtons->AddToggleButton(ID_VIEW_PARCELS, wxT("Parcels"), BITMAP("parcels"));
    pViewButtons->ToggleButton(ID_VIEW_PARCELS, pThis->m_bViewParcels = false);
    pViewButtons->AddToggleButton(ID_VIEW_POSITIONS, wxT("Positions"), BITMAP("positions"));
    pViewButtons->ToggleButton(ID_VIEW_POSITIONS, pThis->m_bViewPositions = false);


#undef BITMAP
    pThis->m_pRibbon->Realise();

    return 0;
}

void frmMain::_applyViewWalls()
{
    m_pGamePanel->getMap()->setAllWallDrawFlags(m_bViewWalls ? 0 : THDF_Alpha50);
}

void frmMain::_applyViewOverlay()
{
    if(m_bViewFlags || m_bViewParcels || m_bViewPositions)
    {
        lua_State *L = m_pGamePanel->getLua();
        luaT_execute(L, "return TheApp.gfx:loadBuiltinFont(), TheApp.map.cell_outline");
        THFont *pFont = reinterpret_cast<THFont*>(lua_touserdata(L, -2));
        THSpriteSheet *pSprites = reinterpret_cast<THSpriteSheet*>(lua_touserdata(L, -1));
        lua_pop(L, 2);

        THMapTypicalOverlay *pFlags = NULL;
        THMapTypicalOverlay *pParcels = NULL;
        THMapPositionsOverlay *pPositions = NULL;
        if(m_bViewFlags)
        {
            pFlags = new THMapFlagsOverlay;
            pFlags->setFont(pFont, false);
            pFlags->setSprites(pSprites, false);
        }
        if(m_bViewParcels)
        {
            pParcels = new THMapParcelsOverlay;
            pParcels->setFont(pFont, false);
            pParcels->setSprites(pSprites, false);
        }
        if(m_bViewPositions)
        {
            pPositions = new THMapPositionsOverlay;
            pPositions->setFont(pFont, false);
            pPositions->setSprites(pSprites, false);
            pPositions->setBackgroundSprite(2);
        }
        THMapOverlayPair *pOverlays = new THMapOverlayPair;
        pOverlays->setFirst(pParcels, true);
        pOverlays->setSecond(pFlags, true);
        THMapOverlayPair *pOverlays2 = new THMapOverlayPair;
        pOverlays2->setFirst(pOverlays, true);
        pOverlays2->setSecond(pPositions, true);
        m_pGamePanel->getMap()->setOverlay(pOverlays2, true);
    }
    else
        m_pGamePanel->getMap()->setOverlay(NULL, false);
}

int frmMain::_l_set_blocks(lua_State *L)
{
    lua_rawgeti(L, LUA_ENVIRONINDEX, 1);
    frmMain *pThis = reinterpret_cast<frmMain*>(lua_touserdata(L, -1));
    lua_pop(L, 1);

    luaL_checktype(L, 1, LUA_TUSERDATA);
    luaL_checktype(L, 2, LUA_TTABLE);

    pThis->m_iFloorTabBrushF  = 0;
    pThis->m_iFloorTabBrushW1 = 0;
    pThis->m_iFloorTabBrushW2 = 0;
    pThis->m_iWallsTabBrushF  = 0;
    pThis->m_iWallsTabBrushW1 = 0;
    pThis->m_iWallsTabBrushW2 = 0;

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
            _setLuaBlockBrushFloorTab(iBaseBlock, iBlock, 0);
        else
            _setLuaBlockBrushFloorTab(iBlock, 0, 0);
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
            _setLuaBlockBrushFloorTab(iBaseBlock, iBlock, 0);
        else
            _setLuaBlockBrushFloorTab(iBlock, 0, 0);
    }
}

void frmMain::_onParcelGallerySelect(wxRibbonGalleryEvent& evt)
{
    if(evt.GetGalleryItem() != NULL)
    {
        _setLuaParcelBrush(static_cast<int>(reinterpret_cast<intptr_t>(
            evt.GetGallery()->GetItemClientData(evt.GetGalleryItem()))));
    }
}

void frmMain::_setLuaParcelBrush(int iParcel)
{
    m_iParcelBrush = iParcel;
    lua_State *L = m_pGamePanel->getLua();
    luaT_execute(L, "_MAP_EDITOR:setBlockBrushParcel(...)", iParcel);
}

void frmMain::_onWallGallery1Select(wxRibbonGalleryEvent& evt)
{
    if(evt.GetGalleryItem() != NULL)
    {
        m_pWallGallery2->SetSelection(NULL);
        int iBlock = m_pWallGallery1->GetBlock(evt.GetGalleryItem(), NULL);
        _setLuaBlockBrushWallsTab(0, 0, iBlock);
    }
}

void frmMain::_onWallGallery2Select(wxRibbonGalleryEvent& evt)
{
    if(evt.GetGalleryItem() != NULL)
    {
        m_pWallGallery1->SetSelection(NULL);
        int iBlock = m_pWallGallery2->GetBlock(evt.GetGalleryItem(), NULL);
        _setLuaBlockBrushWallsTab(0, iBlock, 0);
    }
}

void frmMain::_setLuaBlockBrushFloorTab(int iBlockF, int iBlockW1, int iBlockW2)
{
    m_iFloorTabBrushF = iBlockF;
    m_iFloorTabBrushW1 = iBlockW1;
    m_iFloorTabBrushW2 = iBlockW2;
    _setLuaBlockBrushFloorTab();
}

void frmMain::_setLuaBlockBrushWallsTab(int iBlockF, int iBlockW1, int iBlockW2)
{
    m_iWallsTabBrushF = iBlockF;
    m_iWallsTabBrushW1 = iBlockW1;
    m_iWallsTabBrushW2 = iBlockW2;
    _setLuaBlockBrushWallsTab();
}

void frmMain::_setLuaBlockBrushFloorTab()
{
    _setLuaBlockBrush(m_iFloorTabBrushF, m_iFloorTabBrushW1, m_iFloorTabBrushW2);
}

void frmMain::_setLuaBlockBrushWallsTab()
{
    _setLuaBlockBrush(m_iWallsTabBrushF, m_iWallsTabBrushW1, m_iWallsTabBrushW2);
}

void frmMain::_setLuaBlockBrush(int iBlockF, int iBlockW1, int iBlockW2)
{
    lua_State *L = m_pGamePanel->getLua();
    luaT_execute(L, "_MAP_EDITOR:setBlockBrush(...)",
        iBlockF, iBlockW1, iBlockW2);
}

void frmMain::_doLuaUndo()
{
	lua_State *L = m_pGamePanel->getLua();
	luaT_execute(L, "_MAP_EDITOR:undo()");
	m_pGamePanel->Refresh();
}

void frmMain::_doLuaRedo()
{
	lua_State *L = m_pGamePanel->getLua();
	luaT_execute(L, "_MAP_EDITOR:redo()");
	m_pGamePanel->Refresh();
}
