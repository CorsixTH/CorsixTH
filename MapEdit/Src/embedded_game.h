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

class EmbeddedGamePanel : public wxGLCanvas
{
public:
    EmbeddedGamePanel(wxWindow *pParent);
    ~EmbeddedGamePanel();

    void setExtraLuaInitFunction(lua_CFunction fn, void* arg);
    void setLogWindow(frmLog *pLogWindow);
    bool loadLua();

    lua_State* getLua() {return m_L;}

protected:
    wxGLCanvas* m_pGLCanvas;
    wxGLContext* m_pGLContext;
    wxTextCtrl* m_pPrintTarget;
    lua_State* m_L;
    lua_State* m_Lthread;
    lua_CFunction m_fnExtraLuaInit;
    void* m_pExtraLuaInitArg;
    wxPoint m_ptMouse;

    static int _l_print(lua_State *L);
    static int _l_panic(lua_State *L);
    static int _l_open_sdl(lua_State *L);
    static int _l_end_frame(lua_State *L);

    void _onPaint(wxPaintEvent& evt);
    void _onMouseMove(wxMouseEvent& evt);
    void _onLeftUp(wxMouseEvent& evt);
    void _onLeftDown(wxMouseEvent& evt);
    void _onLeftDoubleClick(wxMouseEvent& evt);
    void _onRightUp(wxMouseEvent& evt);
    void _onRightDown(wxMouseEvent& evt);
    void _onMiddleUp(wxMouseEvent& evt);
    void _onMiddleDown(wxMouseEvent& evt);

    bool _resume(lua_State *L, int iNArgs, int iNRes);

    DECLARE_EVENT_TABLE();
};
