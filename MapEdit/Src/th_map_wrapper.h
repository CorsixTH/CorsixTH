/*
Copyright (c) 2010 Peter "Corsix" Cawley

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
#include "game.h"

class THMapWrapper
{
public:
    //! Wrap around the Map class of a Lua state
    /*!
        This should be called at the initialisation time of a Lua state (after
        luaopen_th has been registered to package.preload, but before any map
        instances have been created). After calling, all map instances created
        by the state will have this wrapper around them.
    */
    static void wrap(lua_State *L);

    static void autoSetHelipad(THMap *pMap);

protected:
    static int _l_set_cell(lua_State *L);
    static void _do_set_cell(lua_State *L, THMap* pMap, int iX, int iY, uint16_t iNewBlocks[4]);
    static bool _check_door(lua_State *L, THMap* pMap, int iX, int iY, int iDX, int iDY);
    static void _check_door_unbuildability(THMap* pMap, int iX, int iY);

    static const int ms_iDoorframeWallFirst = 157;
    static const int ms_iDoorframeNearExternal = 157;
    static const int ms_iDoorframeFarExternal = 159;
    static const int ms_iDoorframeNearInternal = 161;
    static const int ms_iDoorframeFarInternal = 163;
    static const int ms_iDoorframeWallLast = 164;

    static bool _isDoorframe(int iTile);
    static bool _isPassable(int iTile);
    static bool _isWall(int iTile);
    static bool _isCertainlyHospital(THMap* pMap, int iX, int iY);
};
