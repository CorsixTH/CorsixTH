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
#include "../../CorsixTH/Src/main.h"

BEGIN_EVENT_TABLE(EmbeddedGamePanel, wxGLCanvas)
  EVT_MOTION(EmbeddedGamePanel::_onMouseMove)
  EVT_PAINT(EmbeddedGamePanel::_onPaint)
  EVT_LEFT_UP(EmbeddedGamePanel::_onLeftUp)
  EVT_LEFT_DOWN(EmbeddedGamePanel::_onLeftDown)
  EVT_MIDDLE_UP(EmbeddedGamePanel::_onMiddleUp)
  EVT_MIDDLE_DOWN(EmbeddedGamePanel::_onMiddleDown)
  EVT_RIGHT_UP(EmbeddedGamePanel::_onRightUp)
  EVT_RIGHT_DOWN(EmbeddedGamePanel::_onRightDown)
END_EVENT_TABLE()

EmbeddedGamePanel::EmbeddedGamePanel(wxWindow *pParent)
  : wxGLCanvas(pParent, wxID_ANY, NULL, wxDefaultPosition,
        wxDefaultSize, 0, wxGLCanvasName, wxNullPalette)
  , m_pGLCanvas(NULL)
  , m_pGLContext(NULL)
  , m_pPrintTarget(NULL)
  , m_L(NULL)
  , m_Lthread(NULL)
  , m_fnExtraLuaInit(NULL)
  , m_pExtraLuaInitArg(NULL)
{
    m_pGLCanvas = this;
    m_pGLContext = new wxGLContext(m_pGLCanvas);
}

EmbeddedGamePanel::~EmbeddedGamePanel()
{
    if(m_L)
        lua_close(m_L);
    delete m_pGLContext;
}

void EmbeddedGamePanel::setExtraLuaInitFunction(lua_CFunction fn, void* arg)
{
    m_fnExtraLuaInit = fn;
    m_pExtraLuaInitArg = arg;
}

void EmbeddedGamePanel::setLogWindow(frmLog *pLogWindow)
{
    m_pPrintTarget = pLogWindow->getTextControl();
}

bool EmbeddedGamePanel::loadLua()
{
    m_L = luaL_newstate();
    lua_pushliteral(m_L, "wxWindow");
    lua_pushlightuserdata(m_L, reinterpret_cast<wxWindow*>(this));
    lua_settable(m_L, LUA_REGISTRYINDEX);
    lua_pushliteral(m_L, "_MAP_EDITOR");
    lua_pushboolean(m_L, 1);
    lua_settable(m_L, LUA_GLOBALSINDEX);
    lua_atpanic(m_L, _l_panic);
    luaL_openlibs(m_L);
    lua_pushcfunction(m_L, _l_print);
    lua_setglobal(m_L, "print");
    lua_settop(m_L, 0);
    lua_pushcfunction(m_L, CorsixTH_lua_stacktrace);
    lua_pushcfunction(m_L, CorsixTH_lua_main_no_eval);
    lua_checkstack(m_L, wxTheApp->argc);
    for(int i = 0; i < wxTheApp->argc; ++ i)
        lua_pushstring(m_L, wxTheApp->argv[i]);
    if(lua_pcall(m_L, wxTheApp->argc, 1, 1))
    {
        if(m_pPrintTarget)
        {
            m_pPrintTarget->AppendText(L"Error initialising Lua: ");
            m_pPrintTarget->AppendText(lua_tostring(m_L, -1));
            m_pPrintTarget->AppendText(L"\n");
        }
        return false;
    }
    // NB: THMain_l_main will have loaded CorsixTH.lua but not yet run it

    // package.preload.sdl = _l_open_sdl
    lua_getglobal(m_L, "package");
    lua_getfield(m_L, -1, "preload");
    lua_pushliteral(m_L, "sdl");
    lua_pushcfunction(m_L, _l_open_sdl);
    lua_settable(m_L, -3);
    lua_pop(m_L, 2);

    // require"TH".surface.endFrame = _l_end_frame
    lua_getglobal(m_L, "require");
    lua_pushliteral(m_L, "TH");
    lua_call(m_L, 1, 1);
    lua_getfield(m_L, -1, "surface");
    lua_getfield(m_L, -1, "endFrame");
    lua_pushcclosure(m_L, _l_end_frame, 1);
    lua_setfield(m_L, -2, "endFrame");
    lua_pop(m_L, 2);

    // Perform extra initialisation
    if(m_fnExtraLuaInit)
    {
        if(lua_cpcall(m_L, m_fnExtraLuaInit, m_pExtraLuaInitArg) != 0)
            lua_pop(m_L, 1);
    }

    // Execute CorsixTH.lua in a coroutine
    lua_getglobal(m_L, "coroutine");
    lua_getfield(m_L, -1, "create");
    lua_replace(m_L, -2);
    lua_insert(m_L, -2);
    lua_call(m_L, 1, 1);
    lua_State *L = lua_tothread(m_L, -1);
    if(lua_resume(L, 0) != LUA_YIELD)
    {
        if(m_pPrintTarget)
        {
            lua_getglobal(L, "debug");
            lua_getfield(L, -1, "traceback");
            lua_replace(L, -2);
            lua_pushthread(L);
            lua_getglobal(L, "tostring");
            lua_pushvalue(L, -4);
            lua_call(L, 1, 1);
            lua_pushinteger(L, 1);
            lua_call(L, 3, 1);
            m_pPrintTarget->AppendText(L"Error initialising Lua: ");
            m_pPrintTarget->AppendText(lua_tostring(L, -1));
            m_pPrintTarget->AppendText(L"\n");
        }
        return false;
    }
    lua_settop(L, 1); // the event coroutine
    m_Lthread = L;

    return true;
}

bool EmbeddedGamePanel::_resume(lua_State *L, int iNArgs, int iNRes)
{
    bool bGood = true;
    if(lua_resume(L, iNArgs) != LUA_YIELD)
    {
        bGood = false;
        int iNTransfer = lua_gettop(L);
        if(lua_status(L) >= LUA_ERRRUN)
            iNTransfer = 1;
        lua_checkstack(m_Lthread, iNTransfer);
        lua_xmove(L, m_Lthread, iNTransfer);
        lua_settop(L, 0);
        lua_resume(m_Lthread, 1);
    }
    else
    {
        if(lua_toboolean(L, -1) != 0)
        {
            Refresh(false);
        }
    }
    lua_settop(L, iNRes);
    return bGood;
}

void EmbeddedGamePanel::_onMouseMove(wxMouseEvent& evt)
{
    if(m_Lthread)
    {
        lua_State *L = lua_tothread(m_Lthread, 1);
        lua_pushliteral(L, "motion");
        lua_pushinteger(L, evt.GetX());
        lua_pushinteger(L, evt.GetY());
        wxPoint ptNew = evt.GetPosition();
        wxPoint ptDelta = ptNew - m_ptMouse;
        m_ptMouse = ptNew;
        lua_pushinteger(L, ptDelta.x);
        lua_pushinteger(L, ptDelta.y);
        _resume(L, 5, 0);
    }
}

void EmbeddedGamePanel::_onLeftUp(wxMouseEvent& evt)
{
    if(m_Lthread)
    {
        lua_State *L = lua_tothread(m_Lthread, 1);
        lua_pushliteral(L, "buttonup");
        lua_pushinteger(L, SDL_BUTTON_LEFT);
        lua_pushinteger(L, evt.GetX());
        lua_pushinteger(L, evt.GetY());
        _resume(L, 4, 0);
    }
}

void EmbeddedGamePanel::_onLeftDown(wxMouseEvent& evt)
{
    if(m_Lthread)
    {
        lua_State *L = lua_tothread(m_Lthread, 1);
        lua_pushliteral(L, "buttondown");
        lua_pushinteger(L, SDL_BUTTON_LEFT);
        lua_pushinteger(L, evt.GetX());
        lua_pushinteger(L, evt.GetY());
        _resume(L, 4, 0);
    }
}

void EmbeddedGamePanel::_onRightUp(wxMouseEvent& evt)
{
    if(m_Lthread)
    {
        lua_State *L = lua_tothread(m_Lthread, 1);
        lua_pushliteral(L, "buttonup");
        lua_pushinteger(L, SDL_BUTTON_RIGHT);
        lua_pushinteger(L, evt.GetX());
        lua_pushinteger(L, evt.GetY());
        _resume(L, 4, 0);
    }
}

void EmbeddedGamePanel::_onRightDown(wxMouseEvent& evt)
{
    if(m_Lthread)
    {
        lua_State *L = lua_tothread(m_Lthread, 1);
        lua_pushliteral(L, "buttondown");
        lua_pushinteger(L, SDL_BUTTON_RIGHT);
        lua_pushinteger(L, evt.GetX());
        lua_pushinteger(L, evt.GetY());
        _resume(L, 4, 0);
    }
}

void EmbeddedGamePanel::_onMiddleUp(wxMouseEvent& evt)
{
    if(m_Lthread)
    {
        lua_State *L = lua_tothread(m_Lthread, 1);
        lua_pushliteral(L, "buttonup");
        lua_pushinteger(L, SDL_BUTTON_MIDDLE);
        lua_pushinteger(L, evt.GetX());
        lua_pushinteger(L, evt.GetY());
        _resume(L, 4, 0);
    }
}

void EmbeddedGamePanel::_onMiddleDown(wxMouseEvent& evt)
{
    if(m_Lthread)
    {
        lua_State *L = lua_tothread(m_Lthread, 1);
        lua_pushliteral(L, "buttondown");
        lua_pushinteger(L, SDL_BUTTON_MIDDLE);
        lua_pushinteger(L, evt.GetX());
        lua_pushinteger(L, evt.GetY());
        _resume(L, 4, 0);
    }
}

void EmbeddedGamePanel::_onPaint(wxPaintEvent& evt)
{
    wxPaintDC dc(this);
    m_pGLContext->SetCurrent(*m_pGLCanvas);

    if(m_L == NULL)
    {
        // Its rather hacky to be loading the Lua side of things from within
        // the paint handler, but Lua needs an OpenGL context to be active, and
        // we cannot give it one during the EmbeddedGamePanel constructor.
        loadLua();
    }

    // Update the OpenGL projection matrix and Lua window size settings to keep
    // a 1:1 mapping between world space and screen space
    const wxSize szClient = GetClientSize();
    glViewport(0, 0, szClient.x, szClient.y);
    GLdouble fWidth = (GLdouble)szClient.x;
    GLdouble fHeight = (GLdouble)szClient.y;
    THRenderTarget::setGLProjection(fWidth, fHeight);
    if(m_L)
    {
        lua_getglobal(m_L, "TheApp");
        if(lua_isnil(m_L, -1))
            lua_pop(m_L, 1);
        else
        {
            lua_getfield(m_L, -1, "config");
            lua_pushinteger(m_L, szClient.x);
            lua_setfield(m_L, -2, "width");
            lua_pushinteger(m_L, szClient.y);
            lua_setfield(m_L, -2, "height");
            lua_pop(m_L, 2);
        }
    }

    // Do the actual painting
    if(m_Lthread)
    {
        lua_State *L = lua_tothread(m_Lthread, 1);
        lua_pushliteral(L, "frame");
        _resume(L, 1, 0);
    }
}

int EmbeddedGamePanel::_l_print(lua_State *L)
{
    lua_pushliteral(L, "wxWindow");
    lua_gettable(L, LUA_REGISTRYINDEX);
    EmbeddedGamePanel *pThis = reinterpret_cast<EmbeddedGamePanel*>(
        reinterpret_cast<wxWindow*>(lua_touserdata(L, -1)));
    lua_pop(L, 1);
    if(pThis->m_pPrintTarget)
    {
        int iCount = lua_gettop(L);
        lua_getglobal(L, "tostring");
        for(int iArg = 1; iArg <= iCount; ++iArg)
        {
            lua_pushvalue(L, -1);
            lua_pushvalue(L, iArg);
            lua_call(L, 1, 1);
            pThis->m_pPrintTarget->AppendText(lua_tostring(L, -1));
            lua_pop(L, 1);
            if(iArg != iCount)
                pThis->m_pPrintTarget->AppendText(L"\t");
        }
        pThis->m_pPrintTarget->AppendText(L"\n");
    }
    return 0;
}

int EmbeddedGamePanel::_l_panic(lua_State *L)
{
    const char *sMessage = lua_tostring(L, -1);
    ::wxMessageBox(wxString(L"Lua Panic!\n") + wxString(sMessage ? sMessage : ""),
        wxString(L"Lua Panic"), wxOK | wxICON_ERROR | wxCENTRE);
    return 0;
}

int EmbeddedGamePanel::_l_end_frame(lua_State *L)
{
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_insert(L, 1);
    lua_call(L, lua_gettop(L) - 1, LUA_MULTRET);
    lua_pushliteral(L, "wxWindow");
    lua_gettable(L, LUA_REGISTRYINDEX);
    EmbeddedGamePanel *pThis = reinterpret_cast<EmbeddedGamePanel*>(
        reinterpret_cast<wxWindow*>(lua_touserdata(L, -1)));
    lua_pop(L, 1);
    pThis->m_pGLCanvas->SwapBuffers();
    return lua_gettop(L);
}

static int l_init(lua_State *L)
{
    lua_pushboolean(L, 1);
    return 1;
}

static int l_get_fps(lua_State *L)
{
    lua_pushnumber(L, 1);
    return 1;
}

static int l_nop(lua_State *L)
{
    return 0;
}

static int l_get_ticks(lua_State *L)
{
    // Not the same as the game's sdl.getTicks(), but it is sufficient for the
    // purpose (initialising the random number generator).
    lua_pushnumber(L, ::wxGetLocalTime());
    return 1;
}

static const struct luaL_reg sdllib[] = {
    {"init", l_init},
  //{"mainloop", coroutine.yield},
    {"getFPS", l_get_fps},
    {"trackFPS", l_nop},
    {"limitFPS", l_nop},
    {"getTicks", l_get_ticks},
    {NULL, NULL}
};

static const struct luaL_reg sdl_wmlib[] = {
    {"setIconWin32", l_nop},
    {"setCaption", l_nop},
    {"showCursor", l_nop},
    {NULL, NULL}
};

int EmbeddedGamePanel::_l_open_sdl(lua_State *L)
{
    luaL_register(L, "sdl", sdllib);
    lua_getglobal(L, "coroutine");
    lua_getfield(L, -1, "yield");
    lua_setfield(L, -3, "mainloop");
    lua_pop(L, 1);
    lua_newtable(L);
    lua_pushvalue(L, -1);
    lua_setfield(L, -3, "wm");
    luaL_register(L, NULL, sdl_wmlib);
    lua_pop(L, 1);
    lua_newtable(L);
    lua_pushboolean(L, 0);
    lua_setfield(L, -2, "loaded");
    lua_setfield(L, -2, "audio");
    return 1;
}
