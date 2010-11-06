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
#include <wx/glcanvas.h>
#include "game.h"
#include "frmLog.h"

class IEmbeddedGamePanel
{
public:
    virtual ~IEmbeddedGamePanel();

    virtual void setExtraLuaInitFunction(lua_CFunction fn, void* arg) = 0;
    virtual void setLogWindow(frmLog *pLogWindow) = 0;
    virtual bool loadLua() = 0;

    virtual lua_State* getLua() = 0;
    virtual THMap* getMap() = 0;
};

//! GUI component which acts as an instance of CorsixTH
/*!
    The component contains a Lua instance which executes the normal CorsixTH
    Lua scripts. Mouse and keyboard events to the component are forwarded to
    said Lua instance in the same way as they are for a standalone CorsixTH
    instance, and the visual representation of the component is what would
    normally get displayed in a standalone CorsixTH window.

    Lua scripts can tell if they are being executed from within this, as the
    global variable _MAP_EDITOR will be set to true.
*/
class EmbeddedGamePanel : public wxGLCanvas, public IEmbeddedGamePanel
{
public:
    EmbeddedGamePanel(wxWindow *pParent);
    ~EmbeddedGamePanel();

    void setExtraLuaInitFunction(lua_CFunction fn, void* arg);
    void setLogWindow(frmLog *pLogWindow);
    bool loadLua();

    lua_State* getLua() {return m_L;}
    THMap* getMap();

protected:
    // OpenGL rendering stuff
    wxGLCanvas* m_pGLCanvas;
    wxGLContext* m_pGLContext;

    //! A text control which is used for the output of print() calls
    wxTextCtrl* m_pPrintTarget;
    //! The top-level Lua instance
    lua_State* m_L;
    //! A substate of m_L which is used for executing the CorsixTH instance,
    // as this allows the execution to yield and resume "asynchronously".
    lua_State* m_Lthread;
    //! A user-supplied function to be called during Lua initialisation.
    lua_CFunction m_fnExtraLuaInit;
    //! An argument to m_fnExtraLuaInit, delivered as a light userdata.
    void* m_pExtraLuaInitArg;
    //! The last recorded position of the mouse cursor - used to calculate
    // the difference in position each time the mouse is moved.
    wxPoint m_ptMouse;

    static int _l_print(lua_State *L);
    static int _l_panic(lua_State *L);
    static int _l_open_sdl(lua_State *L);
    static int _l_end_frame(lua_State *L);
    static EmbeddedGamePanel* _getThis(lua_State *L);

    void _onPaint(wxPaintEvent& evt);
    void _onMouseMove(wxMouseEvent& evt);
    void _onLeftUp(wxMouseEvent& evt);
    void _onLeftDown(wxMouseEvent& evt);
    void _onLeftDoubleClick(wxMouseEvent& evt);
    void _onRightUp(wxMouseEvent& evt);
    void _onRightDown(wxMouseEvent& evt);
    void _onMiddleUp(wxMouseEvent& evt);
    void _onMiddleDown(wxMouseEvent& evt);

    template <typename T1, typename T2, typename T3>
    void _dispatchEvent(const char* sName, T1 a1, T2 a2, T3 a3)
    {
        if(m_Lthread)
        {
            lua_State *L = lua_tothread(m_Lthread, 1);
            lua_pushstring(L, sName);
            luaT_push(L, a1);
            luaT_push(L, a2);
            luaT_push(L, a3);
            _resume(L, 4, 0);
        }
    }

    template <typename T1, typename T2, typename T3, typename T4>
    void _dispatchEvent(const char* sName, T1 a1, T2 a2, T3 a3, T4 a4)
    {
        if(m_Lthread)
        {
            lua_State *L = lua_tothread(m_Lthread, 1);
            lua_pushstring(L, sName);
            luaT_push(L, a1);
            luaT_push(L, a2);
            luaT_push(L, a3);
            luaT_push(L, a4);
            _resume(L, 5, 0);
        }
    }

    bool _resume(lua_State *L, int iNArgs, int iNRes);

    DECLARE_EVENT_TABLE();
};
