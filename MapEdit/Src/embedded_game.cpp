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
  EVT_LEFT_DCLICK(EmbeddedGamePanel::_onLeftDoubleClick)
END_EVENT_TABLE()

IEmbeddedGamePanel::~IEmbeddedGamePanel()
{
}

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

THMap* EmbeddedGamePanel::getMap()
{
    THMap *pMap = NULL;
    int iTop = lua_gettop(m_L);
    lua_checkstack(m_L, 5);
    lua_getglobal(m_L, "TheApp");
    if(!lua_isnil(m_L, -1))
    {
        lua_getfield(m_L, -1, "map");
        if(!lua_isnil(m_L, -1))
        {
            lua_getfield(m_L, -1, "th");
            pMap = reinterpret_cast<THMap*>(lua_touserdata(m_L, -1));
        }
    }
    lua_settop(m_L, iTop);
    return pMap;
}

bool EmbeddedGamePanel::loadLua()
{
    // Create state
    m_L = luaL_newstate();
    lua_atpanic(m_L, _l_panic);

    // Save a pointer to ourselves in the registry
    lua_pushliteral(m_L, "wxWindow");
    lua_pushlightuserdata(m_L, reinterpret_cast<wxWindow*>(this));
    lua_settable(m_L, LUA_REGISTRYINDEX);

    // Open default libraries, and override appropriate bits
    luaL_openlibs(m_L);
    luaT_execute(m_L, "print = ...", _l_print);

    // Set _MAP_EDITOR to true, to allow scripts to notice that they are
    // running inside this component, rather than standalone.
    luaT_execute(m_L, "_MAP_EDITOR = true");

    // Load CorsixTH.lua and perform other initialisation needed by it
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
    // NB: CorsixTH_lua_main_no_eval will have loaded CorsixTH.lua and left it
    // as the top value on the stack, but will not have executed it.
    // The stack will hence have two things on it: the stacktrace function,
    // and the loaded CorsixTH.lua

    // Overwrite what CorsixTH_lua_main_no_eval registered for require("sdl")
    // with our own function that uses wxWidgets to do what SDL would have.
    luaT_execute(m_L, "package.preload.sdl = ...", _l_open_sdl);

    // Replace the Surface:endFrame() function with our own
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
            // Push debug.traceback onto m_L
            lua_getglobal(m_L, "debug");
            lua_getfield(m_L, -1, "traceback");
            lua_replace(m_L, -2);
            // Push the thread onto m_L
            lua_pushvalue(m_L, -2);
            // Push tostring(errmsg) onto m_L
            lua_getglobal(m_L, "tostring");
            lua_xmove(L, m_L, 1);
            lua_call(m_L, 1, 1);
            // Push constant 1 onto m_L
            lua_pushinteger(m_L, 1);
            // Call debug.traceback(thread, tostring(err), 1)
            lua_call(m_L, 3, 1);
            // Display resulting string and pop it
            m_pPrintTarget->AppendText(L"Error initialising Lua: ");
            m_pPrintTarget->AppendText(lua_tostring(m_L, -1));
            m_pPrintTarget->AppendText(L"\n");
            lua_pop(m_L, 1);
        }
        return false;
    }
    lua_settop(L, 1);
    m_Lthread = L;

    // The stack of the Lua states is now as follows:
    // m_L: stacktrace function, m_Lthread <top
    // m_Lthread: event dispatch coroutine <top

    return true;
}

bool EmbeddedGamePanel::_resume(lua_State *L, int iNArgs, int iNRes)
{
    // L will be an event handling coroutine.
    // Start by sending the event to the coroutine by resuming it with the
    // event arguments.
    bool bGood = true;
    if(lua_resume(L, iNArgs) != LUA_YIELD)
    {
        // Error occured during event processing.
        bGood = false;
        // Transfer the error details to m_Lthread
        int iNTransfer = lua_gettop(L);
        if(lua_status(L) >= LUA_ERRRUN)
            iNTransfer = 1;
        lua_checkstack(m_Lthread, iNTransfer);
        lua_xmove(L, m_Lthread, iNTransfer);
        lua_settop(L, 0);
        // Allow m_Lthread to respond to the error in an appropriate way
        lua_resume(m_Lthread, iNTransfer);
    }
    else
    {
        // Event processed without errors, and will have returned true if
        // a redraw needs to occur.
        if(lua_toboolean(L, -1) != 0)
        {
            Refresh(false);
        }
    }
    // Leave L with the desired number of return values.
    lua_settop(L, iNRes);
    return bGood;
}

void EmbeddedGamePanel::_onMouseMove(wxMouseEvent& evt)
{
    // Keep track of relative mouse movements as well as absolute
    wxPoint ptNew = evt.GetPosition();
    wxPoint ptDelta = ptNew - m_ptMouse;
    m_ptMouse = ptNew;

    _dispatchEvent("motion", ptNew.x, ptNew.y, ptDelta.x, ptDelta.y);
}

void EmbeddedGamePanel::_onLeftUp(wxMouseEvent& evt)
{
    _dispatchEvent("buttonup", SDL_BUTTON_LEFT, evt.GetX(), evt.GetY());
}

void EmbeddedGamePanel::_onLeftDown(wxMouseEvent& evt)
{
    _dispatchEvent("buttondown", SDL_BUTTON_LEFT, evt.GetX(), evt.GetY());
}

void EmbeddedGamePanel::_onLeftDoubleClick(wxMouseEvent& evt)
{
    _dispatchEvent("buttondown", "left_double", evt.GetX(), evt.GetY());
}

void EmbeddedGamePanel::_onRightUp(wxMouseEvent& evt)
{
    _dispatchEvent("buttonup", SDL_BUTTON_RIGHT, evt.GetX(), evt.GetY());
}

void EmbeddedGamePanel::_onRightDown(wxMouseEvent& evt)
{
    _dispatchEvent("buttondown", SDL_BUTTON_RIGHT, evt.GetX(), evt.GetY());
}

void EmbeddedGamePanel::_onMiddleUp(wxMouseEvent& evt)
{
    _dispatchEvent("buttonup", SDL_BUTTON_MIDDLE, evt.GetX(), evt.GetY());
}

void EmbeddedGamePanel::_onMiddleDown(wxMouseEvent& evt)
{
    _dispatchEvent("buttondown", SDL_BUTTON_MIDDLE, evt.GetX(), evt.GetY());
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
        if(L == NULL)
        {
            for(int i = 1; i <= lua_gettop(m_L); ++i)
            {
                wxPrintf("m_L stack %i: %s\n", i, lua_typename(m_L, lua_type(m_L, i)));
            }
            for(int i = 1; i <= lua_gettop(m_Lthread); ++i)
            {
                wxPrintf("m_Lthread stack %i: %s\n", i, lua_typename(m_Lthread, lua_type(m_Lthread, i)));
            }
        }
        lua_pushliteral(L, "frame");
        _resume(L, 1, 0);
    }
}

EmbeddedGamePanel* EmbeddedGamePanel::_getThis(lua_State *L)
{
    lua_pushliteral(L, "wxWindow");
    lua_gettable(L, LUA_REGISTRYINDEX);
    EmbeddedGamePanel *pThis = reinterpret_cast<EmbeddedGamePanel*>(
        reinterpret_cast<wxWindow*>(lua_touserdata(L, -1)));
    lua_pop(L, 1);
    return pThis;
}

int EmbeddedGamePanel::_l_print(lua_State *L)
{
    EmbeddedGamePanel *pThis = _getThis(L);
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
    // Call the original Surface:endFrame() function
    lua_pushvalue(L, lua_upvalueindex(1));
    lua_insert(L, 1);
    lua_call(L, lua_gettop(L) - 1, LUA_MULTRET);

    // Update the display
    EmbeddedGamePanel *pThis = _getThis(L);
    pThis->m_pGLCanvas->SwapBuffers();

    // Return whatever the original returned
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
    {"modifyKeyboardRepeat", l_nop},
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
