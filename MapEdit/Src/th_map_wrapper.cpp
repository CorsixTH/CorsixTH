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
#include "th_map_wrapper.h"
#include <stack>
#include <utility>

void THMapWrapper::autoSetHelipad(THMap *pMap)
{
    // Search the map for a "H" pattern made up from two ground tiles.
    // xxxxx
    // xHxHx
    // xHHHx
    // xHxHx
    // xxxxx
    for(int iX = 2; iX < pMap->getWidth() - 2; ++iX)
    {
        for(int iY = 2; iY < pMap->getHeight() - 2; ++iY)
        {
            THMapNode *pNode = pMap->getNodeUnchecked(iX, iY);
            if((pNode->iBlock[1] | pNode->iBlock[2]) & 0xFF)
                continue;
            uint16_t iFloor1 = pNode->iBlock[0] & 0xFF;
            uint16_t iFloor2 = pNode[-2].iBlock[0] & 0xFF;
            if(iFloor1 == iFloor2)
                continue;
            for(int iDX = -2; iDX <= 2; ++iDX)
            {
                for(int iDY = -2; iDY <= 2; ++iDY)
                {
                    pNode = pMap->getNodeUnchecked(iX + iDX, iY + iDY);
                    if(-1 <= iDX && iDX <= 1 && -1 <= iDY && iDY <= 1)
                    {
                        if((iDX | iDY) == 0)
                            continue;
                        if((pNode->iBlock[1] | pNode->iBlock[2]) & 0xFF)
                            goto next_xy;
                        if((pNode->iBlock[0] & 0xFF) !=
                            (iDX == 0 ? iFloor2 : iFloor1))
                        {
                            goto next_xy;
                        }
                    }
                    else
                    {
                        if((pNode->iBlock[0] & 0xFF) != iFloor2)
                            goto next_xy;
                    }
                }
            }
            pMap->setPlayerHeliportTile(0, iX, iY);
            return;
next_xy:;
        }
    }
}

void THMapWrapper::wrap(lua_State *L)
{
    luaT_execute(L, "require[[TH]].map.setCell = ...", _l_set_cell);
}

int THMapWrapper::_l_set_cell(lua_State *L)
{
    // Perform same argument handling as normal setCell function
    THMap* pMap = reinterpret_cast<THMap*>(lua_touserdata(L, 1));
    int iX = luaL_checkint(L, 2) - 1; // Lua arrays start at 1 - pretend
    int iY = luaL_checkint(L, 3) - 1; // the map does too.
    THMapNode* pNode = pMap->getNode(iX, iY);
    if(pNode == NULL)
        return luaL_argerror(L, 2, "Map co-ordinates out of bounds");
    uint16_t iNewBlocks[4] = {
        pNode->iBlock[0],
        pNode->iBlock[1],
        pNode->iBlock[2],
        pNode->iBlock[3]
    };
    if(lua_gettop(L) >= 7)
    {
        iNewBlocks[0] = (uint16_t)luaL_checkint(L, 4);
        iNewBlocks[1] = (uint16_t)luaL_checkint(L, 5);
        iNewBlocks[2] = (uint16_t)luaL_checkint(L, 6);
        iNewBlocks[3] = (uint16_t)luaL_checkint(L, 7);
    }
    else
    {
        int iLayer = luaL_checkint(L, 4) - 1;
        if(iLayer < 0 || iLayer >= 4)
            return luaL_argerror(L, 4, "Layer index is out of bounds (1-4)");
        int iBlock = luaL_checkint(L, 5);
        iNewBlocks[iLayer] = (uint16_t)iBlock;
    }

    // Dispatch the call
    _do_set_cell(L, pMap, iX, iY, iNewBlocks);

    lua_settop(L, 1);
    return 1;
}

bool THMapWrapper::_isDoorframe(int iTile)
{
    return ms_iDoorframeWallFirst <= iTile && iTile <= ms_iDoorframeWallLast;
}

bool THMapWrapper::_isPassable(int iTile)
{
    iTile &= 0xFF;
    if(iTile <= 5)
        return iTile >= 4;
    else if(iTile <= 0x17)
        return iTile >= 0xF;
    else if(iTile <= 0x3A)
        return iTile >= 0x29;
    else
        return iTile == 0x42 || iTile == 0x46 || iTile == 0x4C;
}

bool THMapWrapper::_isWall(int iTile)
{
    iTile &= 0xFF;
    if(82 <= iTile && iTile <= 155)
        return true;
    // NB: 157 through 160 are walls, but not the purposes of defining
    // hospital tiles.
    if(161 <= iTile && iTile <= 164)
        return true;
    return false;
}

bool THMapWrapper::_isCertainlyHospital(THMap* pMap, int iX, int iY)
{
    THMapNode *pNode = pMap->getNode(iX, iY);
    if(pNode && (pNode->iFlags & THMN_Passable))
    {
        if(_isWall(pNode->iBlock[1]) || _isWall(pNode->iBlock[2]))
            return true;
        THMapNode *pNeighbour = pMap->getNode(iX, iY + 1);
        if(pNeighbour && _isWall(pNeighbour->iBlock[1]))
            return true;
        pNeighbour = pMap->getNode(iX + 1, iY);
        if(pNeighbour && _isWall(pNeighbour->iBlock[2]))
            return true;
    }
    return false;
}

void THMapWrapper::_do_set_cell(lua_State *L, THMap* pMap, int iX, int iY, uint16_t iNewBlocks[4])
{
    THMapNode *pNode = pMap->getNodeUnchecked(iX, iY);

    bool bShouldCheckHospitality = false;
    bool bWasCertainlyHospital = _isCertainlyHospital(pMap, iX, iY);

    // Check for wall blocks which should have sliding doors
    bool bShouldCheckNeighbourDoors = false;
    bool bShouldCheckOwnDoor = false;
    for(int iDir = 0; iDir <= 1; ++iDir)
    {
        uint16_t iOld = pNode->iBlock[1 + iDir] & 0xFF;
        uint16_t iNew = iNewBlocks[1 + iDir] & 0xFF;
        if(iOld == iNew)
            continue;

        bShouldCheckHospitality = true;
        if(_isDoorframe(iOld) || _isDoorframe(iNew))
            bShouldCheckNeighbourDoors = true;
        if((iOld == 0) != (iNew == 0))
            bShouldCheckOwnDoor = true;
    }

    uint32_t iOldFlags = pNode->iFlags;
    if(_isPassable(iNewBlocks[0]))
        pNode->iFlags |= THMN_Passable;
    else
        pNode->iFlags &=~ THMN_Passable;
    if(pNode->iFlags != iOldFlags)
        bShouldCheckHospitality = true;

    pNode->iBlock[0] = iNewBlocks[0];
    pNode->iBlock[1] = iNewBlocks[1];
    pNode->iBlock[2] = iNewBlocks[2];
    pNode->iBlock[3] = iNewBlocks[3];

    if(bShouldCheckOwnDoor)
    {
        _check_door(L, pMap, iX, iY, 1, 0) ||
        _check_door(L, pMap, iX, iY, 0, 1);
    }
    if(bShouldCheckNeighbourDoors)
    {
        _check_door(L, pMap, iX - 1, iY    , 1, 0);
        _check_door(L, pMap, iX    , iY - 1, 0, 1);
        _check_door(L, pMap, iX + 1, iY    , 1, 0);
        _check_door(L, pMap, iX    , iY + 1, 0, 1);
    }

    std::stack<std::pair<int, int> > stkToCheckHospitality;
    if(bWasCertainlyHospital && !_isCertainlyHospital(pMap, iX, iY))
    {
        std::stack<std::pair<int, int> > stkToRemoveHospitality;
        stkToRemoveHospitality.push(std::make_pair(iX, iY));
        while(!stkToRemoveHospitality.empty())
        {
            int iX = stkToRemoveHospitality.top().first;
            int iY = stkToRemoveHospitality.top().second;
            stkToRemoveHospitality.pop();
            THMapNode *pNode = pMap->getNode(iX, iY);
            if(pNode && (pNode->iFlags & THMN_Hospital) != 0
            && !_isCertainlyHospital(pMap, iX, iY))
            {
                stkToCheckHospitality.push(std::make_pair(iX, iY));
                pNode->iFlags &=~ THMN_Hospital;
                for(int iDir = 0; iDir <= 1; ++iDir)
                {
                    for(int iDelta = -1; iDelta <= 1; iDelta += 2)
                    {
                        stkToRemoveHospitality.push(std::make_pair(
                            iX + iDelta * iDir, iY + iDelta * (1 - iDir)));
                    }
                }
            }
        }
    }
    if(bShouldCheckHospitality)
    {
        stkToCheckHospitality.push(std::make_pair(iX, iY));
        stkToCheckHospitality.push(std::make_pair(iX - 1, iY    ));
        stkToCheckHospitality.push(std::make_pair(iX    , iY - 1));
    }
    if(!stkToCheckHospitality.empty())
        pMap->updatePathfinding();
    while(!stkToCheckHospitality.empty())
    {
        int iX = stkToCheckHospitality.top().first;
        int iY = stkToCheckHospitality.top().second;
        stkToCheckHospitality.pop();
        THMapNode *pNode = pMap->getNode(iX, iY);
        if(!pNode)
            continue;
        bool bShouldBeHospital = false;
        if(pNode->iFlags & THMN_Passable)
        {
            bShouldBeHospital = _isCertainlyHospital(pMap, iX, iY);
            int iNumHospitalNeighbours = 0;
#define CHECK(dir_flag, dx, dy) \
            if(pNode->iFlags & dir_flag) \
            { \
                iNumHospitalNeighbours += (pMap->getNode(iX + dx, iY + dy) \
                    ->iFlags & THMN_Hospital) >> THMN_Hospital_Shift; \
            }
            CHECK(THMN_CanTravelN,  0, -1);
            CHECK(THMN_CanTravelE,  1,  0);
            CHECK(THMN_CanTravelS,  0,  1);
            CHECK(THMN_CanTravelW, -1,  0);
#undef CHECK
            if(iNumHospitalNeighbours >= 2)
                bShouldBeHospital = true;
        }
        if(bShouldBeHospital != ((pNode->iFlags & THMN_Hospital) != 0))
        {
            if(bShouldBeHospital)
            {
                pNode->iFlags |= THMN_Hospital;
                _check_door_unbuildability(pMap, iX, iY);
            }
            else
                pNode->iFlags &=~ (THMN_Hospital | THMN_Buildable);
            for(int iDir = 0; iDir <= 1; ++iDir)
            {
                for(int iDelta = -1; iDelta <= 1; iDelta += 2)
                {
                    stkToCheckHospitality.push(std::make_pair(
                        iX + iDelta * iDir, iY + iDelta * (1 - iDir)));
                }
            }
        }
    }

}

void THMapWrapper::_check_door_unbuildability(THMap* pMap, int iX, int iY)
{
    THMapNode *pNode = pMap->getNode(iX, iY);
    if(!pNode)
        return;
    bool bBuildable = (pNode->iFlags & THMN_Hospital) != 0;
    for(int iDX = -1; iDX <= 1; ++iDX)
    {
        for(int iDY = -1; iDY <= 1; ++iDY)
        {
            THMapNode *pNode = pMap->getNode(iX + iDX, iY + iDY);
            if(!pNode || (pNode->iFlags >> 24) != THOB_EntranceRightDoor)
                continue;
            bool bIsNorthFacing = (pNode[-1].iFlags >> 24) == THOB_EntranceLeftDoor;
            if(bIsNorthFacing)
            {
                if(iDY != -1)
                    bBuildable = false;
            }
            else
            {
                if(iDX != -1)
                    bBuildable = false;
            }
        }
    }
    if(bBuildable)
        pNode->iFlags |= THMN_Buildable;
    else
        pNode->iFlags &=~ THMN_Buildable;
}

bool THMapWrapper::_check_door(lua_State *L, THMap* pMap, int iX, int iY, int iDX, int iDY)
{
    bool bShouldHaveDoor = false;
    THMapNode *pNode = pMap->getNode(iX, iY);
    if(pNode && !(pNode->iBlock[1] & 0xFF) && !(pNode->iBlock[2] & 0xFF))
    {
        THMapNode *pFarNode = pMap->getNode(iX - iDX, iY - iDY);
        THMapNode *pNearNode = pMap->getNode(iX + iDX, iY + iDY);
        if(pFarNode && pNearNode)
        {
            int iFarBlock = pFarNode->iBlock[1 + iDY] & 0xFF;
            int iNearBlock = pNearNode->iBlock[1 + iDY] & 0xFF;
            if(iFarBlock == ms_iDoorframeFarExternal + iDY
            || iFarBlock == ms_iDoorframeFarInternal + iDY)
            {
                if(iNearBlock == ms_iDoorframeNearExternal + iDY
                || iNearBlock == ms_iDoorframeNearInternal + iDY)
                {
                    bShouldHaveDoor = true;
                }
            }
        }
    }
    THObjectType eNodeThob = (THObjectType)(pNode->iFlags >> 24);
    bool bGotDoor = eNodeThob == THOB_EntranceLeftDoor ||
                    eNodeThob == THOB_EntranceRightDoor;
    if(bGotDoor == bShouldHaveDoor)
    {
        return false;
    }
    else if(bShouldHaveDoor)
    {
        for(int i = 1; i >= 0; --i)
        {
            luaT_execute(L, "TheApp.world:newObject(...)",
                i == 1 ? "entrance_left_door" : "entrance_right_door",
                iX + 1 - i * iDX,
                iY + 1 - i * iDY,
                iDX == 1 ? "north" : "west");
        }
    }
    else
    {
        luaT_execute(L,
            "local world = TheApp.world\n"
            "local door = world:getObject(...)\n"
            "if door then world:destroyEntity(door)\n"
            "if door.slave then world:destroyEntity(door.slave) end end\n",
            iX + 1,
            iY + 1);
    }
    for(int iDX = -1; iDX <= 1; ++iDX)
    {
        for(int iDY = -1; iDY <= 1; ++iDY)
        {
            _check_door_unbuildability(pMap, iX + iDX, iY + iDY);
        }
    }
    return bShouldHaveDoor;
}
