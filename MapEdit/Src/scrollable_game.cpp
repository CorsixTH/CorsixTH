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
#include <algorithm>
#include "scrollable_game.h"

BEGIN_EVENT_TABLE(ScrollableGamePanel, wxPanel)
  EVT_SIZE(ScrollableGamePanel::_onResize)
  EVT_COMMAND_SCROLL(ID_X_SCROLL, ScrollableGamePanel::_onScroll)
  EVT_COMMAND_SCROLL(ID_Y_SCROLL, ScrollableGamePanel::_onScroll)
  EVT_TIMER(wxID_ANY, ScrollableGamePanel::_onTimer)
END_EVENT_TABLE()

ScrollableGamePanel::ScrollableGamePanel(wxWindow *pParent)
: wxPanel(pParent)
, m_pGamePanel(NULL)
, m_pMapScrollX(NULL)
, m_pMapScrollY(NULL)
, m_bShouldRespondToScroll(true)
{
    wxFlexGridSizer *pSizer = new wxFlexGridSizer(2, 2, 0, 0);
    pSizer->AddGrowableRow(0, 1);
    pSizer->AddGrowableCol(0, 1);

    pSizer->Add(m_pGamePanel = new EmbeddedGamePanel(this), 1, wxEXPAND);
    m_pGamePanel->setExtraLuaInitFunction(_l_extra_init,
        reinterpret_cast<void*>(this));
    pSizer->Add(m_pMapScrollY = new wxScrollBar(this, ID_Y_SCROLL,
        wxDefaultPosition, wxDefaultSize, wxVERTICAL), 0, wxEXPAND);
    pSizer->Add(m_pMapScrollX = new wxScrollBar(this, ID_X_SCROLL,
        wxDefaultPosition, wxDefaultSize, wxHORIZONTAL), 0, wxEXPAND);
    pSizer->AddSpacer(0);

    m_pTimer = new wxTimer(this, wxID_ANY);
    m_pTimer->Start(100, false);

    SetSizer(pSizer);
}

ScrollableGamePanel::~ScrollableGamePanel()
{
	m_pTimer->Stop();
}

void ScrollableGamePanel::setExtraLuaInitFunction(lua_CFunction fn, void* arg)
{
    m_fnExtraInit = fn;
    m_pExtraInitArg = arg;
}

void ScrollableGamePanel::setLogWindow(frmLog *pLogWindow)
{
    m_pGamePanel->setLogWindow(pLogWindow);
}

bool ScrollableGamePanel::loadLua()
{
    return m_pGamePanel->loadLua();
}

lua_State* ScrollableGamePanel::getLua()
{
    return m_pGamePanel->getLua();
}

THMap* ScrollableGamePanel::getMap()
{
    return m_pGamePanel->getMap();
}

void ScrollableGamePanel::_onResize(wxSizeEvent& evt)
{
    lua_State *L = m_pGamePanel->getLua();
    if(!L)
        goto default_resize;

    // Get old world-coordinates of window center
    lua_Number fX, fY;
    lua_getglobal(L, "TheApp");
    if(lua_isnil(L, -1))
    {
        lua_pop(L, 1);
        goto default_resize;
    }
    lua_getfield(L, -1, "ui");
    if(lua_isnil(L, -1))
    {
        lua_pop(L, 2);
        goto default_resize;
    }
    lua_getfield(L, -1, "ScreenToWorld");
    lua_pushvalue(L, -2);
    lua_pushinteger(L, m_pGamePanel->GetSize().GetWidth() / 2);
    lua_pushinteger(L, m_pGamePanel->GetSize().GetHeight() / 2);
    lua_call(L, 3, 2);
    fX = lua_tonumber(L, -2) - 1.0;
    fY = lua_tonumber(L, -1) - 1.0;
    lua_pop(L, 2);

    // Change window center
    Layout();

    // Move window center to same world co-ordinates
    THMap::worldToScreen(fX, fY);
    lua_getfield(L, -1, "scrollMapTo");
    lua_insert(L, -2);
    lua_pushnumber(L, fX);
    lua_pushnumber(L, fY);
    lua_call(L, 3, 0);
    lua_pop(L, 1);
    return;
default_resize:
    evt.Skip();
}

int ScrollableGamePanel::_l_extra_init(lua_State *L)
{
    ScrollableGamePanel* pThis = reinterpret_cast<ScrollableGamePanel*>(
        lua_touserdata(L, 1));

    // Perform the original extra initialisation
    if(pThis->m_fnExtraInit != NULL)
    {
        if(lua_cpcall(L, pThis->m_fnExtraInit, pThis->m_pExtraInitArg) != 0)
            lua_pop(L, 1);
    }

    // Hook around the MapEditorInitWithLuaApp function
    lua_getglobal(L, "MapEditorInitWithLuaApp");
    lua_pushvalue(L, 1);
    lua_pushcclosure(L, _l_init_with_app, 2);
    lua_setglobal(L, "MapEditorInitWithLuaApp");

    return 0;
}

int ScrollableGamePanel::_l_init_with_app(lua_State *L)
{
    // Call the original MapEditorInitWithLuaApp function
    lua_pushvalue(L, lua_upvalueindex(1));
    if(lua_type(L, -1) == LUA_TNIL)
        lua_pop(L, 1);
    else
    {
        lua_insert(L, 1);
        lua_call(L, lua_gettop(L) - 1, LUA_MULTRET);
    }

    // Wrap our _l_on_ui_scroll_map function around GameUI:scrollMap()
    // 1st upvalue: original GameUI:scrollMap() function
    // 2nd upvalue: light userdata this
    // This has to be done with the Lua App initialisation as we need for
    // dofile() to be the custom dofile() used by CorsixTH, rather than the
    // default one present at Lua initialisation time.
    luaT_execute(L, "dofile [[game_ui]]");
    lua_getglobal(L, "GameUI");
    lua_getfield(L, -1, "scrollMap");
    lua_pushvalue(L, lua_upvalueindex(2));
    lua_pushcclosure(L, _l_on_ui_scroll_map, 2);
    lua_setfield(L, -2, "scrollMap");

    return lua_gettop(L);
}

int ScrollableGamePanel::_l_on_ui_scroll_map(lua_State *L)
{
    ScrollableGamePanel *pThis = reinterpret_cast<ScrollableGamePanel*>(
        lua_touserdata(L, lua_upvalueindex(2)));

    // Make a copy of the "self" parameter at the bottom of the stack
    lua_pushvalue(L, 1);
    lua_insert(L, 1);

    // Call original GameUI:scrollMap() function
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_insert(L, 2);
    lua_call(L, lua_gettop(L) - 2, LUA_MULTRET);

    if(pThis->m_bShouldRespondToScroll)
    {
        int iPanelW, iPanelH;
        pThis->m_pGamePanel->GetSize(&iPanelW, &iPanelH);

        // Get world co-ordinates of window center
        lua_checkstack(L, 4);
        lua_getfield(L, 1, "ScreenToWorld");
        lua_pushvalue(L, 1);
        lua_pushinteger(L, iPanelW / 2);
        lua_pushinteger(L, iPanelH / 2);
        lua_call(L, 3, 2);
        lua_Number fX = lua_tonumber(L, -2) - 1.0;
        lua_Number fY = lua_tonumber(L, -1) - 1.0;
        lua_pop(L, 2);

        // Get map extents
        THMap* pMap = pThis->m_pGamePanel->getMap();
        int iMapH = pMap->getHeight();
        int iTemp = pMap->getWidth();
        pMap->worldToScreen(iTemp, iMapH);
        int iMapW = pMap->getWidth();
        iTemp = 0;
        pMap->worldToScreen(iMapW, iTemp);

        // Get screen co-ordinates of window center
        // We could get these directly from the GameUI, but we'd be delving into
        // its member variables, and also perhaps not properly accounting for zoom.
        pMap->worldToScreen(fX, fY);
        int iX = (int)fX;
        int iY = (int)fY;

        // Update scrollbars
        pThis->m_pMapScrollX->SetScrollbar(iX + iMapW, iPanelW, iMapW * 2 + iPanelW, iPanelW);
        pThis->m_pMapScrollY->SetScrollbar(iY        , iPanelH, iMapH     + iPanelH, iPanelH);
    }

    // Return results from original call
    return lua_gettop(L) - 1;
}

void ScrollableGamePanel::_onScroll(wxScrollEvent& evt)
{
    _positionMap();
}

void ScrollableGamePanel::_onTimer(wxTimerEvent& evt)
{
    const int KEY_SENSITIVITY = 20;
    int x = m_pMapScrollX->GetThumbPosition();
    int y = m_pMapScrollY->GetThumbPosition();
    bool bChanges = false;

    if(wxGetKeyState(WXK_LEFT))
    {
        m_pMapScrollX->SetThumbPosition(std::max(0, x - KEY_SENSITIVITY));
        bChanges = true;
    }
    if(wxGetKeyState(WXK_RIGHT))
    {
        m_pMapScrollX->SetThumbPosition(std::min(m_pMapScrollX->GetRange(), x + KEY_SENSITIVITY));
        bChanges = true;
    }
    if(wxGetKeyState(WXK_UP))
    {
        m_pMapScrollY->SetThumbPosition(std::max(0, y - KEY_SENSITIVITY));
        bChanges = true;
    }
    if(wxGetKeyState(WXK_DOWN))
    {
        m_pMapScrollY->SetThumbPosition(std::min(m_pMapScrollY->GetRange(), y + KEY_SENSITIVITY));
        bChanges = true;
    }
    if (bChanges)
    {
        _positionMap();
    }
}

void ScrollableGamePanel::_positionMap()
{
    lua_State *L = getLua();
    if(!L)
    {
        return;
    }
    lua_getglobal(L, "TheApp");
    if(lua_isnil(L, -1))
    {
        lua_pop(L, 1);
        return;
    }
    lua_getfield(L, -1, "ui");
    if(lua_isnil(L, -1))
    {
        lua_pop(L, 2);
        return;
    }
    lua_replace(L, -2);
    lua_getfield(L, -1, "scrollMapTo");
    lua_insert(L, -2);
    lua_pushinteger(L, m_pMapScrollX->GetThumbPosition() - m_pMapScrollX->GetRange() / 2 + m_pMapScrollX->GetThumbSize() / 2);
    lua_pushinteger(L, m_pMapScrollY->GetThumbPosition());
    m_bShouldRespondToScroll = false;
    lua_call(L, 3, 1);
    m_bShouldRespondToScroll = true;
    m_pGamePanel->Refresh(false);
}
