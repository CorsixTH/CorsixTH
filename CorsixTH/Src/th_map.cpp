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

#include "config.h"
#include "th_map.h"
#include "th_map_overlays.h"
#include "th_gfx.h"
#include "run_length_encoder.h"
#include <SDL.h>
#include <new>
#include <algorithm>
#include <cstring>
#include <cstdio>
#include <fstream>
#include <string>
#include <exception>

th_map_node_flags& th_map_node_flags::operator=(uint32_t raw)
{
    passable = (raw & static_cast<uint32_t>(th_map_node_flags::key::passable_mask)) != 0;
    can_travel_n = (raw & static_cast<uint32_t>(th_map_node_flags::key::can_travel_n_mask)) != 0;
    can_travel_e = (raw & static_cast<uint32_t>(th_map_node_flags::key::can_travel_e_mask)) != 0;
    can_travel_s = (raw & static_cast<uint32_t>(th_map_node_flags::key::can_travel_s_mask)) != 0;
    can_travel_w = (raw & static_cast<uint32_t>(th_map_node_flags::key::can_travel_w_mask)) != 0;
    hospital = (raw & static_cast<uint32_t>(th_map_node_flags::key::hospital_mask)) != 0;
    buildable = (raw & static_cast<uint32_t>(th_map_node_flags::key::buildable_mask)) != 0;
    passable_if_not_for_blueprint = (raw & static_cast<uint32_t>(th_map_node_flags::key::passable_if_not_for_blueprint_mask)) != 0;
    room = (raw & static_cast<uint32_t>(th_map_node_flags::key::room_mask)) != 0;
    shadow_half = (raw & static_cast<uint32_t>(th_map_node_flags::key::shadow_half_mask)) != 0;
    shadow_full = (raw & static_cast<uint32_t>(th_map_node_flags::key::shadow_full_mask)) != 0;
    shadow_wall = (raw & static_cast<uint32_t>(th_map_node_flags::key::shadow_wall_mask)) != 0;
    door_north = (raw & static_cast<uint32_t>(th_map_node_flags::key::door_north_mask)) != 0;
    door_west = (raw & static_cast<uint32_t>(th_map_node_flags::key::door_west_mask)) != 0;
    do_not_idle = (raw & static_cast<uint32_t>(th_map_node_flags::key::do_not_idle_mask)) != 0;
    tall_north = (raw & static_cast<uint32_t>(th_map_node_flags::key::tall_north_mask)) != 0;
    tall_west = (raw & static_cast<uint32_t>(th_map_node_flags::key::tall_west_mask)) != 0;
    buildable_n = (raw & static_cast<uint32_t>(th_map_node_flags::key::buildable_n_mask)) != 0;
    buildable_e = (raw & static_cast<uint32_t>(th_map_node_flags::key::buildable_e_mask)) != 0;
    buildable_s = (raw & static_cast<uint32_t>(th_map_node_flags::key::buildable_s_mask)) != 0;
    buildable_w = (raw & static_cast<uint32_t>(th_map_node_flags::key::buildable_w_mask)) != 0;

    return *this;
}

bool& th_map_node_flags::operator[](th_map_node_flags::key key)
{
    switch(key)
    {
    case th_map_node_flags::key::passable_mask:
        return passable;
    case th_map_node_flags::key::can_travel_n_mask:
        return can_travel_n;
    case th_map_node_flags::key::can_travel_e_mask:
        return can_travel_e;
    case th_map_node_flags::key::can_travel_s_mask:
        return can_travel_s;
    case th_map_node_flags::key::can_travel_w_mask:
        return can_travel_w;
    case th_map_node_flags::key::hospital_mask:
        return hospital;
    case th_map_node_flags::key::buildable_mask:
        return buildable;
    case th_map_node_flags::key::passable_if_not_for_blueprint_mask:
        return passable_if_not_for_blueprint;
    case th_map_node_flags::key::room_mask:
        return room;
    case th_map_node_flags::key::shadow_half_mask:
        return shadow_half;
    case th_map_node_flags::key::shadow_full_mask:
        return shadow_full;
    case th_map_node_flags::key::shadow_wall_mask:
        return shadow_wall;
    case th_map_node_flags::key::door_north_mask:
        return door_north;
    case th_map_node_flags::key::door_west_mask:
        return door_west;
    case th_map_node_flags::key::do_not_idle_mask:
        return do_not_idle;
    case th_map_node_flags::key::tall_north_mask:
        return tall_north;
    case th_map_node_flags::key::tall_west_mask:
        return tall_west;
    case th_map_node_flags::key::buildable_n_mask:
        return buildable_n;
    case th_map_node_flags::key::buildable_e_mask:
        return buildable_e;
    case th_map_node_flags::key::buildable_s_mask:
        return buildable_s;
    case th_map_node_flags::key::buildable_w_mask:
        return buildable_w;
    default:
        throw std::out_of_range("map node flag is invalid");
    }
}

const bool& th_map_node_flags::operator[](th_map_node_flags::key key) const
{
    switch(key)
    {
    case th_map_node_flags::key::passable_mask:
        return passable;
    case th_map_node_flags::key::can_travel_n_mask:
        return can_travel_n;
    case th_map_node_flags::key::can_travel_e_mask:
        return can_travel_e;
    case th_map_node_flags::key::can_travel_s_mask:
        return can_travel_s;
    case th_map_node_flags::key::can_travel_w_mask:
        return can_travel_w;
    case th_map_node_flags::key::hospital_mask:
        return hospital;
    case th_map_node_flags::key::buildable_mask:
        return buildable;
    case th_map_node_flags::key::passable_if_not_for_blueprint_mask:
        return passable_if_not_for_blueprint;
    case th_map_node_flags::key::room_mask:
        return room;
    case th_map_node_flags::key::shadow_half_mask:
        return shadow_half;
    case th_map_node_flags::key::shadow_full_mask:
        return shadow_full;
    case th_map_node_flags::key::shadow_wall_mask:
        return shadow_wall;
    case th_map_node_flags::key::door_north_mask:
        return door_north;
    case th_map_node_flags::key::door_west_mask:
        return door_west;
    case th_map_node_flags::key::do_not_idle_mask:
        return do_not_idle;
    case th_map_node_flags::key::tall_north_mask:
        return tall_north;
    case th_map_node_flags::key::tall_west_mask:
        return tall_west;
    case th_map_node_flags::key::buildable_n_mask:
        return buildable_n;
    case th_map_node_flags::key::buildable_e_mask:
        return buildable_e;
    case th_map_node_flags::key::buildable_s_mask:
        return buildable_s;
    case th_map_node_flags::key::buildable_w_mask:
        return buildable_w;
    default:
        throw std::out_of_range("map node flag is invalid");
    }
}

th_map_node_flags::operator uint32_t() const
{
    uint32_t raw = 0;
    if(passable) { raw |= static_cast<uint32_t>(th_map_node_flags::key::passable_mask); }
    if(can_travel_n) { raw |= static_cast<uint32_t>(th_map_node_flags::key::can_travel_n_mask); }
    if(can_travel_e) { raw |= static_cast<uint32_t>(th_map_node_flags::key::can_travel_e_mask); }
    if(can_travel_s) { raw |= static_cast<uint32_t>(th_map_node_flags::key::can_travel_s_mask); }
    if(can_travel_w) { raw |= static_cast<uint32_t>(th_map_node_flags::key::can_travel_w_mask); }
    if(hospital) { raw |= static_cast<uint32_t>(th_map_node_flags::key::hospital_mask); }
    if(buildable) { raw |= static_cast<uint32_t>(th_map_node_flags::key::buildable_mask); }
    if(passable_if_not_for_blueprint) { raw |= static_cast<uint32_t>(th_map_node_flags::key::passable_if_not_for_blueprint_mask); }
    if(room) { raw |= static_cast<uint32_t>(th_map_node_flags::key::room_mask); }
    if(shadow_half) { raw |= static_cast<uint32_t>(th_map_node_flags::key::shadow_half_mask); }
    if(shadow_full) { raw |= static_cast<uint32_t>(th_map_node_flags::key::shadow_full_mask); }
    if(shadow_wall) { raw |= static_cast<uint32_t>(th_map_node_flags::key::shadow_wall_mask); }
    if(door_north) { raw |= static_cast<uint32_t>(th_map_node_flags::key::door_north_mask); }
    if(door_west) { raw |= static_cast<uint32_t>(th_map_node_flags::key::door_west_mask); }
    if(do_not_idle) { raw |= static_cast<uint32_t>(th_map_node_flags::key::do_not_idle_mask); }
    if(tall_north) { raw |= static_cast<uint32_t>(th_map_node_flags::key::tall_north_mask); }
    if(tall_west) { raw |= static_cast<uint32_t>(th_map_node_flags::key::tall_west_mask); }
    if(buildable_n) { raw |= static_cast<uint32_t>(th_map_node_flags::key::buildable_n_mask); }
    if(buildable_e) { raw |= static_cast<uint32_t>(th_map_node_flags::key::buildable_e_mask); }
    if(buildable_s) { raw |= static_cast<uint32_t>(th_map_node_flags::key::buildable_s_mask); }
    if(buildable_w) { raw |= static_cast<uint32_t>(th_map_node_flags::key::buildable_w_mask); }

    return raw;
}

THMapNode::THMapNode() :
    iParcelId(0),
    iRoomId(0),
    objects()
{
    iBlock[0] = 0;
    iBlock[1] = 0;
    iBlock[2] = 0;
    iBlock[3] = 0;
    aiTemperature[0] = aiTemperature[1] = 8192;
    flags = {};
}

THMapNode::~THMapNode()
{
}

THMap::THMap()
{
    m_iWidth = 0;
    m_iHeight = 0;
    m_iPlayerCount = 0;
    m_iCurrentTemperatureIndex = 0;
    m_eTempDisplay = THMT_Red;
    m_iParcelCount = 0;
    m_pCells = nullptr;
    m_pOriginalCells = nullptr;
    m_pBlocks = nullptr;
    m_pOverlay = nullptr;
    m_bOwnOverlay = false;
    m_pPlotOwner = nullptr;
    m_pParcelTileCounts = nullptr;
    m_pParcelAdjacencyMatrix = nullptr;
    m_pPurchasableMatrix = nullptr;
}

THMap::~THMap()
{
    setOverlay(nullptr, false);
    delete[] m_pCells;
    delete[] m_pOriginalCells;
    delete[] m_pPlotOwner;
    delete[] m_pParcelTileCounts;
    delete[] m_pParcelAdjacencyMatrix;
    delete[] m_pPurchasableMatrix;
}

void THMap::setOverlay(THMapOverlay *pOverlay, bool bTakeOwnership)
{
    if(m_pOverlay && m_bOwnOverlay)
        delete m_pOverlay;
    m_pOverlay = pOverlay;
    m_bOwnOverlay = bTakeOwnership;
}

bool THMap::setSize(int iWidth, int iHeight)
{
    if(iWidth <= 0 || iHeight <= 0)
        return false;

    delete[] m_pCells;
    delete[] m_pOriginalCells;
    delete[] m_pParcelAdjacencyMatrix;
    delete[] m_pPurchasableMatrix;
    m_iWidth = iWidth;
    m_iHeight = iHeight;
    m_pCells = nullptr;
    m_pCells = new (std::nothrow) THMapNode[iWidth * iHeight];
    m_pOriginalCells = nullptr;
    m_pOriginalCells = new (std::nothrow) THMapNode[iWidth * iHeight];
    m_pParcelAdjacencyMatrix = nullptr;
    m_pPurchasableMatrix = nullptr;

    if(m_pCells == nullptr || m_pOriginalCells == nullptr)
    {
        delete[] m_pCells;
        delete[] m_pOriginalCells;
        m_pOriginalCells = nullptr;
        m_pCells = nullptr;
        m_iWidth = 0;
        m_iHeight = 0;
        return false;
    }

    return true;
}

// NB: http://connection-endpoint.de/th-format-specification/
// gives a (slightly) incorrect array, which is why it differs from this one.
static const uint8_t gs_iTHMapBlockLUT[256] = {
    0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C,
    0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18,
    0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x21, 0x22, 0x23, 0x24,
    0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30,
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C,
    0x3D, 0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48,
    0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50, 0x52, 0x53, 0x54, 0x55,
    0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F, 0x60, 0x61,
    0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D,
    0x6E, 0x6F, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79,
    0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F, 0x80, 0x81, 0x84, 0x85, 0x88, 0x89,
    0x8C, 0x8D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8E, 0x8F, 0x00, 0x00,
    0x00, 0x00, 0x8E, 0x8F, 0xD5, 0xD6, 0x9C, 0xCC, 0xCD, 0xCE, 0xCF, 0xD0,
    0xD1, 0xD2, 0xD3, 0xD4, 0xB3, 0xAF, 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5,
    0xB6, 0xB7, 0xB8, 0xB9, 0xB3, 0xB3, 0xB4, 0xB4, 0xBA, 0xBB, 0xBC, 0xBD,
    0xBE, 0xBF, 0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9,
    0xCA, 0xCB, 0x00, 0x82, 0x83, 0x86, 0x87, 0x8A, 0x8B, 0x92, 0x93, 0x94,
    0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B, 0x00, 0x9D, 0x9E, 0x9F, 0xA0,
    0xA1, 0xA2, 0xA3, 0xA4, 0xD7, 0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE,
    0xDF, 0xE0, 0xE1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00
};

void THMap::_readTileIndex(const uint8_t* pData, int& iX, int &iY) const
{
    unsigned int iIndex = static_cast<unsigned int>(pData[1]);
    iIndex = iIndex * 0x100 + static_cast<unsigned int>(pData[0]);
    iX = iIndex % m_iWidth;
    iY = iIndex / m_iWidth;
}

void THMap::_writeTileIndex(uint8_t* pData, int iX, int iY) const
{
    uint16_t iIndex = static_cast<uint16_t>(iY * m_iWidth + iX);
    pData[0] = static_cast<uint8_t>(iIndex & 0xFF);
    pData[1] = static_cast<uint8_t>(iIndex >> 8);
}

bool THMap::loadBlank()
{
    if(!setSize(128, 128))
        return false;

    m_iPlayerCount = 1;
    m_aiInitialCameraX[0] = m_aiInitialCameraY[0] = 63;
    m_aiHeliportX[0] = m_aiHeliportY[0] = 0;
    m_iParcelCount = 1;
    delete[] m_pPlotOwner;
    delete[] m_pParcelTileCounts;
    m_pPlotOwner = nullptr;
    m_pParcelTileCounts = nullptr;
    THMapNode *pNode = m_pCells;
    THMapNode *pOriginalNode = m_pOriginalCells;
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pNode, ++pOriginalNode)
        {
            pNode->iBlock[0] = static_cast<uint16_t>(2 + (iX % 2));
        }
    }
    m_pPlotOwner = new int[1];
    m_pPlotOwner[0] = 0;
    m_pParcelTileCounts = new int[1];
    m_pParcelTileCounts[0] = 128 * 128;

    return true;
}

bool THMap::loadFromTHFile(const uint8_t* pData, size_t iDataLength,
                           THMapLoadObjectCallback_t fnObjectCallback,
                           void* pCallbackToken)
{
    if(iDataLength < 163948 || !setSize(128, 128))
        return false;

    m_iPlayerCount = pData[0];
    for(int i = 0; i < m_iPlayerCount; ++i)
    {
        _readTileIndex(pData + 163876 + (i % 4) * 2,
            m_aiInitialCameraX[i], m_aiInitialCameraY[i]);
        _readTileIndex(pData + 163884 + (i % 4) * 2,
            m_aiHeliportX[i], m_aiHeliportY[i]);
    }
    m_iParcelCount = 0;
    delete[] m_pPlotOwner;
    delete[] m_pParcelTileCounts;
    m_pPlotOwner = nullptr;
    m_pParcelTileCounts = nullptr;

    THMapNode *pNode = m_pCells;
    THMapNode *pOriginalNode = m_pOriginalCells;
    const uint16_t *pParcel = reinterpret_cast<const uint16_t*>(pData + 131106);
    pData += 34;

    pNode->objects.clear();
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pNode, ++pOriginalNode, pData += 8, ++pParcel)
        {
            uint8_t iBaseTile = gs_iTHMapBlockLUT[pData[2]];
            pNode->flags.can_travel_n = true;
            pNode->flags.can_travel_e = true;
            pNode->flags.can_travel_s = true;
            pNode->flags.can_travel_w = true;
            if(iX == 0)
                pNode->flags.can_travel_w = false;
            else if(iX == 127)
                pNode->flags.can_travel_e = false;
            if(iY == 0)
                pNode->flags.can_travel_n = false;
            else if(iY == 127)
                pNode->flags.can_travel_s = false;
            pNode->iBlock[0] = iBaseTile;
#define IsDividerWall(x) (((x) >> 1) == 70)
            if(pData[3] == 0 || IsDividerWall(pData[3]))
            {
                // Tiles 71, 72 and 73 (pond foliage) are used as floor tiles,
                // but are too tall to be floor tiles, so move them to a wall,
                // and replace the floor with something similar (pond base).
                if(71 <= iBaseTile && iBaseTile <= 73)
                {
                    pNode->iBlock[1] = iBaseTile;
                    pNode->iBlock[0] = iBaseTile = 69;
                }
                else
                    pNode->iBlock[1] = 0;
            }
            else
            {
                pNode->iBlock[1] = gs_iTHMapBlockLUT[pData[3]];
                pNode->flags.can_travel_n = false;
                if(iY != 0)
                {
                    pNode[-128].flags.can_travel_s = false;
                }
            }
            if(pData[4] == 0 || IsDividerWall(pData[4]))
                pNode->iBlock[2] = 0;
            else
            {
                pNode->iBlock[2] = gs_iTHMapBlockLUT[pData[4]];
                pNode->flags.can_travel_w = false;
                if(iX != 0)
                {
                    pNode[-1].flags.can_travel_e = false;
                }
            }

            pNode->iRoomId = 0;
            pNode->iParcelId = *pParcel;
            if(*pParcel >= m_iParcelCount)
                m_iParcelCount = *pParcel + 1;

            if(!(pData[5] & 1))
            {
                pNode->flags.passable = true;
                if(*pParcel && !(pData[7] & 16))
                {
                    pNode->flags.hospital = true;
                    if(!(pData[5] & 2)) {
                        pNode->flags.buildable = true;
                    }
                    if(!(pData[5] & 4) || pData[1] == 0) {
                        pNode->flags.buildable_n = true;
                    }
                    if(!(pData[5] & 8) || pData[1] == 0) {
                        pNode->flags.buildable_e = true;
                    }
                    if(!(pData[5] & 16) || pData[1] == 0) {
                        pNode->flags.buildable_s = true;
                    }
                    if(!(pData[5] & 32) || pData[1] == 0) {
                        pNode->flags.buildable_w = true;
                    }
                }
            }

            *pOriginalNode = *pNode;
            if(IsDividerWall(pData[3]))
                pOriginalNode->iBlock[1] = gs_iTHMapBlockLUT[pData[3]];
            if(IsDividerWall(pData[4]))
                pOriginalNode->iBlock[2] = gs_iTHMapBlockLUT[pData[4]];

#undef IsDividerWall

            if(pData[1] != 0 && fnObjectCallback != nullptr)
            {
                fnObjectCallback(pCallbackToken, iX, iY, (THObjectType)pData[1], pData[0]);
            }
        }
    }
    m_pPlotOwner = new int[m_iParcelCount];
    m_pPlotOwner[0] = 0;
    for(int i = 1; i < m_iParcelCount; ++i)
        m_pPlotOwner[i] = 1;

    updateShadows();

    m_pParcelTileCounts = new int[m_iParcelCount];
    m_pParcelTileCounts[0] = 0;
    for(int i = 1; i < m_iParcelCount; ++i)
        m_pParcelTileCounts[i] = _getParcelTileCount(i);

    return true;
}

void THMap::save(std::string filename)
{
    uint8_t aBuffer[256] = {0};
    int iBufferNext = 0;
    std::basic_ofstream<uint8_t, std::char_traits<uint8_t>> os(filename, std::ios_base::trunc | std::ios_base::binary);

    // Header
    aBuffer[0] = static_cast<uint8_t>(m_iPlayerCount);
    // TODO: Determine correct contents for the next 33 bytes
    os.write(aBuffer, 34);

    uint8_t aReverseBlockLUT[256] = {0};
    for(int i = 0; i < 256; ++i)
    {
        aReverseBlockLUT[gs_iTHMapBlockLUT[i]] = static_cast<uint8_t>(i);
    }
    aReverseBlockLUT[0] = 0;

    for(THMapNode *pNode = m_pCells, *pLastNode = pNode + m_iWidth * m_iHeight;
        pNode != pLastNode; ++pNode)
    {
        // TODO: Nicer system for saving object data
        aBuffer[iBufferNext++] = pNode->flags.tall_west ? 1 : 0;
        aBuffer[iBufferNext++] = static_cast<uint8_t>(pNode->objects.empty() ? THObjectType::no_object : pNode->objects.front());

        // Blocks
        aBuffer[iBufferNext++] = aReverseBlockLUT[pNode->iBlock[0] & 0xFF];
        aBuffer[iBufferNext++] = aReverseBlockLUT[pNode->iBlock[1] & 0xFF];
        aBuffer[iBufferNext++] = aReverseBlockLUT[pNode->iBlock[2] & 0xFF];

        // Flags (TODO: Set a few more flag bits?)
        uint8_t iFlags = 63;
        if(pNode->flags.passable)
            iFlags ^= 1;
        if(pNode->flags.buildable)
            iFlags ^= 2;
        if(pNode->flags.buildable_n)
            iFlags ^= 4;
        if(pNode->flags.buildable_e)
            iFlags ^= 8;
        if(pNode->flags.buildable_s)
            iFlags ^= 16;
        if(pNode->flags.buildable_w)
            iFlags ^= 32;

        aBuffer[iBufferNext++] = iFlags;

        aBuffer[iBufferNext++] = 0;
        iFlags = 16;
        if(pNode->flags.hospital)
            iFlags ^= 16;
        aBuffer[iBufferNext++] = iFlags;

        if(iBufferNext == sizeof(aBuffer))
        {
            os.write(aBuffer, sizeof(aBuffer));
            iBufferNext = 0;
        }
    }
    for(THMapNode *pNode = m_pCells, *pLastNode = pNode + m_iWidth * m_iHeight;
        pNode != pLastNode; ++pNode)
    {
        aBuffer[iBufferNext++] = static_cast<uint8_t>(pNode->iParcelId & 0xFF);
        aBuffer[iBufferNext++] = static_cast<uint8_t>(pNode->iParcelId >> 8);
        if(iBufferNext == sizeof(aBuffer))
        {
            os.write(aBuffer, sizeof(aBuffer));
            iBufferNext = 0;
        }
    }

    // TODO: What are these two bytes?
    aBuffer[iBufferNext++] = 3;
    aBuffer[iBufferNext++] = 0;
    os.write(aBuffer, iBufferNext);
    iBufferNext = 0;

    std::memset(aBuffer, 0, 56);
    for(int i = 0; i < m_iPlayerCount; ++i)
    {
        _writeTileIndex(aBuffer + iBufferNext,
            m_aiInitialCameraX[i], m_aiInitialCameraY[i]);
        _writeTileIndex(aBuffer + iBufferNext + 8,
            m_aiHeliportX[i], m_aiHeliportY[i]);
        iBufferNext += 2;
    }
    os.write(aBuffer, 16);
    std::memset(aBuffer, 0, 16);
    // TODO: What are these 56 bytes?
    os.write(aBuffer, 56);
    os.close();
}

void THMap::setParcelOwner(int iParcelId, int iOwner)
{
    if(iParcelId <= 0 || m_iParcelCount <= iParcelId || iOwner < 0)
        return;
    m_pPlotOwner[iParcelId] = iOwner;

    THMapNode *pNode = m_pCells;
    const THMapNode *pOriginalNode = m_pOriginalCells;
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pNode, ++pOriginalNode)
        {
            if(pNode->iParcelId == iParcelId)
            {
                if(iOwner != 0)
                {
                    pNode->iBlock[0] = pOriginalNode->iBlock[0];
                    pNode->iBlock[1] = pOriginalNode->iBlock[1];
                    pNode->iBlock[2] = pOriginalNode->iBlock[2];
                    pNode->flags = pOriginalNode->flags;
                }
                else
                {
                    // Nicely mown grass pattern
                    pNode->iBlock[0] = static_cast<uint16_t>(((iX & 1) << 1) + 1);

                    pNode->iBlock[1] = 0;
                    pNode->iBlock[2] = 0;
                    pNode->flags = {};

                    // Random decoration
                    if(((iX | iY) & 0x7) == 0)
                    {
                        int iWhich = (iX ^ iY) % 9;
                        pNode->iBlock[1] = static_cast<uint16_t>(192 + iWhich);
                    }
                }
            }

#define IsDividerWall(x) (142 <= (x) && (x) <= 145)
#define CheckDividers(xy, delta, block) \
            if(xy > 0 && pOriginalNode->flags.hospital && \
                pOriginalNode[-delta].flags.hospital && \
                pNode->iParcelId != pNode[-delta].iParcelId) \
            { \
                int iOwner = m_pPlotOwner[pNode->iParcelId]; \
                int iOtherOwner = m_pPlotOwner[pNode[-delta].iParcelId]; \
                if(iOwner != iOtherOwner) \
                    pNode->iBlock[block] = block + (iOwner ? 143 : 141); \
                else if(IsDividerWall(pNode->iBlock[block])) \
                    pNode->iBlock[block] = 0; \
            }
            CheckDividers(iX,   1, 2);
            CheckDividers(iY, 128, 1);
#undef CheckDividers
#undef IsDividerWall
        }
    }

    updatePathfinding();
    updateShadows();
    _updatePurchaseMatrix();
}

void THMap::_makeAdjacencyMatrix()
{
    if(m_pParcelAdjacencyMatrix != nullptr)
        return;

    m_pParcelAdjacencyMatrix = new bool[m_iParcelCount * m_iParcelCount];
    for(int i = 0; i < m_iParcelCount; ++i)
    {
        for(int j = 0; j < m_iParcelCount; ++j)
        {
            m_pParcelAdjacencyMatrix[i * m_iParcelCount + j] = (i == j);
        }
    }

    const THMapNode *pOriginalNode = m_pOriginalCells;
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pOriginalNode)
        {
#define TestAdj(xy, delta) if(xy > 0 && \
            pOriginalNode->iParcelId != pOriginalNode[-delta].iParcelId &&  \
            pOriginalNode->flags.passable && pOriginalNode[-delta].flags.passable)\
            m_pParcelAdjacencyMatrix[pOriginalNode->iParcelId * m_iParcelCount\
            + pOriginalNode[-delta].iParcelId] = true, \
            m_pParcelAdjacencyMatrix[pOriginalNode->iParcelId + \
            pOriginalNode[-delta].iParcelId * m_iParcelCount] = true

            TestAdj(iX, 1);
            TestAdj(iY, 128);
#undef TestAdj
        }
    }
}

void THMap::_makePurchaseMatrix()
{
    if(m_pPurchasableMatrix != nullptr)
        return; // Already made
    m_pPurchasableMatrix = new bool[4 * m_iParcelCount];
    _updatePurchaseMatrix();
}

void THMap::_updatePurchaseMatrix()
{
    if(m_pPurchasableMatrix == nullptr)
        return; // Nothing to update
    for(int iPlayer = 1; iPlayer <= 4; ++iPlayer)
    {
        for(int iParcel = 0; iParcel < m_iParcelCount; ++iParcel)
        {
            bool bPurchasable = false;
            if(iParcel != 0 && m_pPlotOwner[iParcel] == 0)
            {
                for(int iParcel2 = 0; iParcel2 < m_iParcelCount; ++iParcel2)
                {
                    if((m_pPlotOwner[iParcel2] == iPlayer) || (iParcel2 == 0))
                    {
                        if(areParcelsAdjacent(iParcel, iParcel2))
                        {
                            bPurchasable = true;
                            break;
                        }
                    }
                }
            }
            m_pPurchasableMatrix[iParcel * 4 + iPlayer - 1] = bPurchasable;
        }
    }
}

bool THMap::areParcelsAdjacent(int iParcel1, int iParcel2)
{
    if(0 <= iParcel1 && iParcel1 < m_iParcelCount
    && 0 <= iParcel2 && iParcel2 < m_iParcelCount)
    {
        _makeAdjacencyMatrix();
        return m_pParcelAdjacencyMatrix[iParcel1 * m_iParcelCount + iParcel2];
    }
    return false;
}

bool THMap::isParcelPurchasable(int iParcelId, int iPlayer)
{
    if(0 <= iParcelId && iParcelId < m_iParcelCount
    && 1 <= iPlayer && iPlayer <= 4)
    {
        _makePurchaseMatrix();
        return m_pPurchasableMatrix[iParcelId * 4 + iPlayer - 1];
    }
    return false;
}

void THMap::setPlayerCount(int count)
{
    if (count < 1 || count > 4)
        throw std::out_of_range("Player count must be between 1 and 4");

    m_iPlayerCount = count;
}

bool THMap::getPlayerCameraTile(int iPlayer, int* pX, int* pY) const
{
    if(iPlayer < 0 || iPlayer >= getPlayerCount())
    {
        if(pX) *pX = 0;
        if(pY) *pY = 0;
        return false;
    }
    if(pX) *pX = m_aiInitialCameraX[iPlayer];
    if(pY) *pY = m_aiInitialCameraY[iPlayer];
    return true;
}

bool THMap::getPlayerHeliportTile(int iPlayer, int* pX, int* pY) const
{
    if(iPlayer < 0 || iPlayer >= getPlayerCount())
    {
        if(pX) *pX = 0;
        if(pY) *pY = 0;
        return false;
    }
    if(pX) *pX = m_aiHeliportX[iPlayer];
    if(pY) *pY = m_aiHeliportY[iPlayer];
    return true;
}

void THMap::setPlayerCameraTile(int iPlayer, int iX, int iY)
{
    if(0 <= iPlayer && iPlayer < getPlayerCount())
    {
        m_aiInitialCameraX[iPlayer] = iX;
        m_aiInitialCameraY[iPlayer] = iY;
    }
}

void THMap::setPlayerHeliportTile(int iPlayer, int iX, int iY)
{
    if(0 <= iPlayer && iPlayer < getPlayerCount())
    {
        m_aiHeliportX[iPlayer] = iX;
        m_aiHeliportY[iPlayer] = iY;
    }
}

int THMap::getParcelTileCount(int iParcelId) const
{
    if(iParcelId < 1 || iParcelId >= m_iParcelCount)
    {
        return 0;
    }
    return m_pParcelTileCounts[iParcelId];
}

int THMap::_getParcelTileCount(int iParcelId) const
{
    int iTiles = 0;
    for(int iY = 0; iY < m_iHeight; ++iY)
    {
        for(int iX = 0; iX < m_iWidth; ++iX)
        {
            const THMapNode* pNode = getNodeUnchecked(iX, iY);
            if(pNode->iParcelId == iParcelId) iTiles++;
        }
    }
    return iTiles;
}

THMapNode* THMap::getNode(int iX, int iY)
{
    if(0 <= iX && iX < m_iWidth && 0 <= iY && iY < m_iHeight)
        return getNodeUnchecked(iX, iY);
    else
        return nullptr;
}

const THMapNode* THMap::getNode(int iX, int iY) const
{
    if(0 <= iX && iX < m_iWidth && 0 <= iY && iY < m_iHeight)
        return getNodeUnchecked(iX, iY);
    else
        return nullptr;
}

const THMapNode* THMap::getOriginalNode(int iX, int iY) const
{
    if(0 <= iX && iX < m_iWidth && 0 <= iY && iY < m_iHeight)
        return getOriginalNodeUnchecked(iX, iY);
    else
        return nullptr;
}

THMapNode* THMap::getNodeUnchecked(int iX, int iY)
{
    return m_pCells + iY * m_iWidth + iX;
}

const THMapNode* THMap::getNodeUnchecked(int iX, int iY) const
{
    return m_pCells + iY * m_iWidth + iX;
}

const THMapNode* THMap::getOriginalNodeUnchecked(int iX, int iY) const
{
    return m_pOriginalCells + iY * m_iWidth + iX;
}

void THMap::setBlockSheet(THSpriteSheet* pSheet)
{
    m_pBlocks = pSheet;
}

void THMap::setAllWallDrawFlags(uint8_t iFlags)
{
    uint16_t iBlockOr = static_cast<uint16_t>(iFlags << 8);
    THMapNode *pNode = m_pCells;
    for(int i = 0; i < m_iWidth * m_iHeight; ++i, ++pNode)
    {
        pNode->iBlock[1] = static_cast<uint16_t>((pNode->iBlock[1] & 0xFF) | iBlockOr);
        pNode->iBlock[2] = static_cast<uint16_t>((pNode->iBlock[2] & 0xFF) | iBlockOr);
    }
}

void IntersectTHClipRect(THClipRect& rcClip,const THClipRect& rcIntersect)
{
    // The intersection of the rectangles is the higher of the lower bounds and the lower of the higher bounds, clamped to a zero size.
    THClipRect::xy_t maxX = static_cast<uint16_t>(std::min(rcClip.x + rcClip.w, rcIntersect.x + rcIntersect.w));
    THClipRect::xy_t maxY = static_cast<uint16_t>(std::min(rcClip.y + rcClip.h, rcIntersect.y + rcIntersect.h));
    rcClip.x = std::max(rcClip.x, rcIntersect.x);
    rcClip.y = std::max(rcClip.y, rcIntersect.y);
    rcClip.w = maxX - rcClip.x;
    rcClip.h = maxY - rcClip.y;

    // Make sure that we clamp the values to 0.
    if (rcClip.w <= 0)
    {
        rcClip.w = rcClip.h = 0;
    }
    else if (rcClip.h <= 0)
    {
        rcClip.w = rcClip.h = 0;
    }
}

void THMap::draw(THRenderTarget* pCanvas, int iScreenX, int iScreenY,
                 int iWidth, int iHeight, int iCanvasX, int iCanvasY) const
{
    /*
       The map is drawn in two passes, with each pass done one scanline at a
       time (a scanline is a list of nodes with the same screen Y co-ordinate).
       The first pass does floor tiles, as the entire floor needs to be painted
       below anything else (for example, see the walking north through a door
       animation, which needs to paint over the floor of the scanline below the
       animation). On the second pass, walls and entities are drawn, with the
       order controlled such that entites appear in the right order relative to
       the walls around them. For each scanline, the following is done:

       1st pass:
        1) For each node, left to right, the floor tile (layer 0)
       2nd pass:
        1) For each node, right to left, the north wall, then the early entities
        2) For each node, left to right, the west wall, then the late entities
    */

    if(m_pBlocks == nullptr || m_pCells == nullptr)
        return;

    THClipRect rcClip;
    rcClip.x = static_cast<THClipRect::xy_t>(iCanvasX);
    rcClip.y = static_cast<THClipRect::xy_t>(iCanvasY);
    rcClip.w = static_cast<THClipRect::wh_t>(iWidth);
    rcClip.h = static_cast<THClipRect::wh_t>(iHeight);
    pCanvas->setClipRect(&rcClip);

    // 1st pass
    pCanvas->startNonOverlapping();
    for(THMapNodeIterator itrNode1(this, iScreenX, iScreenY, iWidth, iHeight); itrNode1; ++itrNode1)
    {
        unsigned int iH = 32;
        unsigned int iBlock = itrNode1->iBlock[0];
        m_pBlocks->getSpriteSize(iBlock & 0xFF, nullptr, &iH);
        m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF,
            itrNode1.x() + iCanvasX - 32,
            itrNode1.y() + iCanvasY - iH + 32, iBlock >> 8);
    }
    pCanvas->finishNonOverlapping();

    bool bFirst = true;
    THMapScanlineIterator formerIterator;
    // 2nd pass
    for(THMapNodeIterator itrNode2(this, iScreenX, iScreenY, iWidth, iHeight); itrNode2; ++itrNode2)
    {
        if(itrNode2->flags.shadow_full)
        {
            m_pBlocks->drawSprite(pCanvas, 74, itrNode2.x() + iCanvasX - 32,
                itrNode2.y() + iCanvasY, THDF_Alpha75);
        }
        else if(itrNode2->flags.shadow_half)
        {
            m_pBlocks->drawSprite(pCanvas, 75, itrNode2.x() + iCanvasX - 32,
                itrNode2.y() + iCanvasY, THDF_Alpha75);
        }

        if(!itrNode2.isLastOnScanline())
            continue;

        for(THMapScanlineIterator itrNode(itrNode2, ScanlineBackward, iCanvasX, iCanvasY); itrNode; ++itrNode)
        {
            unsigned int iH;
            unsigned int iBlock = itrNode->iBlock[1];
            if(iBlock != 0 && m_pBlocks->getSpriteSize(iBlock & 0xFF,
                nullptr, &iH) && iH > 0)
            {
                m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF, itrNode.x() - 32,
                    itrNode.y() - iH + 32, iBlock >> 8);
                if(itrNode->flags.shadow_wall)
                {
                    THClipRect rcOldClip, rcNewClip;
                    pCanvas->getClipRect(&rcOldClip);
                    rcNewClip.x = static_cast<THClipRect::xy_t>(itrNode.x() - 32);
                    rcNewClip.y = static_cast<THClipRect::xy_t>(itrNode.y() - iH + 32 + 4);
                    rcNewClip.w = static_cast<THClipRect::wh_t>(64);
                    rcNewClip.h = static_cast<THClipRect::wh_t>(86 - 4);
                    IntersectTHClipRect(rcNewClip, rcOldClip);
                    pCanvas->setClipRect(&rcNewClip);
                    m_pBlocks->drawSprite(pCanvas, 156, itrNode.x() - 32,
                        itrNode.y() - 56, THDF_Alpha75);
                    pCanvas->setClipRect(&rcOldClip);
                }
            }
            THDrawable *pItem = (THDrawable*)(itrNode->oEarlyEntities.m_pNext);
            while(pItem)
            {
                pItem->m_fnDraw(pItem, pCanvas, itrNode.x(), itrNode.y());
                pItem = (THDrawable*)(pItem->m_pNext);
            }
        }

        THMapScanlineIterator itrNode(itrNode2, ScanlineForward, iCanvasX, iCanvasY);
        if(!bFirst) {
            //since the scanline count from one THMapScanlineIterator to another can differ
            //synchronization between the current iterator and the former one is neeeded
             if(itrNode.x() < -64)
                 ++itrNode;
             while(formerIterator.x() < itrNode.x())
                 ++formerIterator;
        }
        bool bPreviousTileNeedsRedraw = false;
        for(; itrNode; ++itrNode)
        {
            bool bNeedsRedraw = false;
            unsigned int iH;
            unsigned int iBlock = itrNode->iBlock[2];
            if(iBlock != 0 && m_pBlocks->getSpriteSize(iBlock & 0xFF,
                nullptr, &iH) && iH > 0)
            {
                m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF, itrNode.x() - 32,
                    itrNode.y() - iH + 32, iBlock >> 8);
            }
            iBlock = itrNode->iBlock[3];
            if(iBlock != 0 && m_pBlocks->getSpriteSize(iBlock & 0xFF,
                nullptr, &iH) && iH > 0)
            {
                m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF, itrNode.x() - 32,
                    itrNode.y() - iH + 32, iBlock >> 8);
            }
            iBlock = itrNode->iBlock[1];
            if(iBlock != 0 && m_pBlocks->getSpriteSize(iBlock & 0xFF,
                nullptr, &iH) && iH > 0)
                bNeedsRedraw = true;
            if(itrNode->oEarlyEntities.m_pNext)
                bNeedsRedraw = true;

            bool bRedrawAnimations = false;

            THDrawable *pItem = (THDrawable*)(itrNode->m_pNext);
            while(pItem)
            {
                pItem->m_fnDraw(pItem, pCanvas, itrNode.x(), itrNode.y());
                if(pItem->m_fnIsMultipleFrameAnimation(pItem))
                    bRedrawAnimations = true;
                if(pItem->getDrawingLayer() == 1)
                    bNeedsRedraw = true;
                pItem = (THDrawable*)(pItem->m_pNext);
            }

            //if the current tile contained a multiple frame animation (e.g. a doctor walking)
            //check to see if in the tile to its left and above it there are items that need to
            //be redrawn (i.e. in the tile to its left side objects to the south of the tile and
            //in the tile above it side objects to the east of the tile).
            if(bRedrawAnimations && !bFirst)
            {
                bool bTileNeedsRedraw = bPreviousTileNeedsRedraw;

                //check if an object in the adjacent tile to the left of the current tile needs to be redrawn
                //and if necessary draw it
                pItem = (THDrawable*)(formerIterator.getPreviousNode()->m_pNext);
                while(pItem)
                {
                    if (pItem->getDrawingLayer() == 9)
                    {
                        pItem->m_fnDraw(pItem, pCanvas, formerIterator.x() - 64, formerIterator.y());
                        bTileNeedsRedraw = true;
                    }
                    pItem = (THDrawable*)(pItem->m_pNext);
                }

                //check if an object in the adjacent tile above the current tile needs to be redrawn
                //and if necessary draw it
                pItem = formerIterator ? (THDrawable*)(formerIterator->m_pNext) : nullptr;
                while(pItem)
                {
                    if(pItem->getDrawingLayer() == 8)
                        pItem->m_fnDraw(pItem, pCanvas, formerIterator.x(), formerIterator.y());
                    pItem = (THDrawable*)(pItem->m_pNext);
                }


                //if an object was redrawn in the tile to the left of the current tile
                //or if the tile below it had an object in the north side or a wall to the north
                //redraw that tile
                if(bTileNeedsRedraw)
                {
                    //redraw the north wall
                    unsigned int iBlock = itrNode.getPreviousNode()->iBlock[1];
                    if(iBlock != 0 && m_pBlocks->getSpriteSize(iBlock & 0xFF,
                        nullptr, &iH) && iH > 0)
                    {
                        m_pBlocks->drawSprite(pCanvas, iBlock & 0xFF, itrNode.x() - 96,
                            itrNode.y() - iH + 32, iBlock >> 8);
                        if(itrNode.getPreviousNode()->flags.shadow_wall)
                        {
                            THClipRect rcOldClip, rcNewClip;
                            pCanvas->getClipRect(&rcOldClip);
                            rcNewClip.x = static_cast<THClipRect::xy_t>(itrNode.x() - 96);
                            rcNewClip.y = static_cast<THClipRect::xy_t>(itrNode.y() - iH + 32 + 4);
                            rcNewClip.w = static_cast<THClipRect::wh_t>(64);
                            rcNewClip.h = static_cast<THClipRect::wh_t>(86 - 4);
                            IntersectTHClipRect(rcNewClip, rcOldClip);
                            pCanvas->setClipRect(&rcNewClip);
                            m_pBlocks->drawSprite(pCanvas, 156, itrNode.x() - 96,
                                itrNode.y() - 56, THDF_Alpha75);
                            pCanvas->setClipRect(&rcOldClip);
                        }
                    }
                    pItem = (THDrawable*)(itrNode.getPreviousNode()->oEarlyEntities.m_pNext);
                    while(pItem)
                    {
                        pItem->m_fnDraw(pItem, pCanvas, itrNode.x() - 64, itrNode.y());
                        pItem = (THDrawable*)(pItem->m_pNext);
                    }

                    pItem = (THDrawable*)(itrNode.getPreviousNode())->m_pNext;
                    for(; pItem; pItem = (THDrawable*)(pItem->m_pNext))
                        pItem->m_fnDraw(pItem, pCanvas, itrNode.x() - 64, itrNode.y());
                }
            }
           bPreviousTileNeedsRedraw = bNeedsRedraw;
           if (!bFirst) ++formerIterator;
        }

     formerIterator = itrNode;
     bFirst = false;
    }

    if(m_pOverlay)
    {
        for(THMapNodeIterator itrNode(this, iScreenX, iScreenY, iWidth, iHeight); itrNode; ++itrNode)
        {
            m_pOverlay->drawCell(pCanvas, itrNode.x() + iCanvasX - 32,
                itrNode.y() + iCanvasY, this, itrNode.nodeX(), itrNode.nodeY());
        }
    }

    pCanvas->setClipRect(nullptr);
}

THDrawable* THMap::hitTest(int iTestX, int iTestY) const
{
    // This function needs to hitTest each drawable object, in the reverse
    // order to that in which they would be drawn.

    if(m_pBlocks == nullptr || m_pCells == nullptr)
        return nullptr;

    for(THMapNodeIterator itrNode2(this, iTestX, iTestY, 1, 1, ScanlineBackward); itrNode2; ++itrNode2)
    {
        if(!itrNode2.isLastOnScanline())
            continue;

        for(THMapScanlineIterator itrNode(itrNode2, ScanlineBackward); itrNode; ++itrNode)
        {
            if(itrNode->m_pNext != nullptr)
            {
                THDrawable* pResult = _hitTestDrawables(itrNode->m_pNext,
                    itrNode.x(), itrNode.y(), 0, 0);
                if(pResult)
                    return pResult;
            }
        }
        for(THMapScanlineIterator itrNode(itrNode2, ScanlineForward); itrNode; ++itrNode)
        {
            if(itrNode->oEarlyEntities.m_pNext != nullptr)
            {
                THDrawable* pResult = _hitTestDrawables(itrNode->oEarlyEntities.m_pNext,
                    itrNode.x(), itrNode.y(), 0, 0);
                if(pResult)
                    return pResult;
            }
        }
    }

    return nullptr;
}

THDrawable* THMap::_hitTestDrawables(THLinkList* pListStart, int iXs, int iYs,
                                     int iTestX, int iTestY) const
{
    THLinkList* pListEnd = pListStart;
    while(pListEnd->m_pNext)
        pListEnd = pListEnd->m_pNext;
    THDrawable* pList = (THDrawable*)pListEnd;

    while(true)
    {
        if(pList->m_fnHitTest(pList, iXs, iYs, iTestX, iTestY))
            return pList;

        if(pList == pListStart)
            return nullptr;
        else
            pList = (THDrawable*)pList->m_pPrev;
    }
}

int THMap::getNodeOwner(const THMapNode* pNode) const
{
    return m_pPlotOwner[pNode->iParcelId];
}

int THMap::getParcelOwner(int iParcel) const
{
    if(0 <= iParcel && iParcel < m_iParcelCount)
        return m_pPlotOwner[iParcel];
    else
        return 0;
}


uint16_t THMap::getNodeTemperature(const THMapNode* pNode) const
{
    return pNode->aiTemperature[m_iCurrentTemperatureIndex];
}

void THMap::setTemperatureDisplay(THMapTemperatureDisplay eTempDisplay)
{
    if (eTempDisplay < THMT_Count) m_eTempDisplay = eTempDisplay;
}

void THMap::updateTemperatures(uint16_t iAirTemperature,
                               uint16_t iRadiatorTemperature)
{
    if(iRadiatorTemperature < iAirTemperature)
        iRadiatorTemperature = iAirTemperature;
    const int iPrevTemp = m_iCurrentTemperatureIndex;
    m_iCurrentTemperatureIndex ^= 1;
    const int iNewTemp = m_iCurrentTemperatureIndex;

    THMapNode* pLastNode = m_pCells + m_iWidth * m_iHeight;
    for(THMapNode *pNode = m_pCells; pNode != pLastNode; ++pNode)
    {
        // Get average temperature of neighbour cells
        uint32_t iNeighbourSum = 0;
        uint32_t iNeighbourCount = 0;
#define NEIGHBOUR(flag, idx, pNeighbour) \
        if(flag) \
        { \
            iNeighbourCount += 4; \
            iNeighbourSum += pNode[idx].aiTemperature[iPrevTemp] * 4; \
        } \
        else \
        {  \
            bool bObjectPresent = false; \
            if(pNeighbour && pNeighbour < pLastNode && pNeighbour > m_pCells) \
            { \
                int iHospital1 = ((THMapNode * )pNeighbour)->flags.hospital; \
                int iHospital2 = pNode->flags.hospital; \
                if (iHospital1 == iHospital2) \
                    if ((((THMapNode * )pNeighbour)->flags.room) == (pNode->flags.room)) \
                        bObjectPresent = true; \
            } \
            if (bObjectPresent) \
            { \
                iNeighbourCount += 4; \
                iNeighbourSum += pNode[idx].aiTemperature[iPrevTemp] * 4; \
            } \
            else if(m_pCells <= pNode + (idx) && pNode + (idx) < pLastNode) \
            { \
                iNeighbourCount += 1; \
                iNeighbourSum += pNode[idx].aiTemperature[iPrevTemp]; \
            } \
        }

        NEIGHBOUR(pNode->flags.can_travel_n, -m_iWidth, pNode - m_iWidth);
        NEIGHBOUR(pNode->flags.can_travel_s,  m_iWidth, pNode + m_iWidth);
        NEIGHBOUR(pNode->flags.can_travel_e,  1, pNode + 1);
        NEIGHBOUR(pNode->flags.can_travel_w, -1, pNode - 1);

#undef NEIGHBOUR
#define MERGE2(src, other, ratio) (src) = static_cast<uint16_t>( \
    (static_cast<uint32_t>(src) * ((ratio) - 1) + (other)) / (ratio))
#define MERGE(other, ratio) \
    MERGE2(pNode->aiTemperature[iNewTemp], other, ratio)
        uint32_t iRadiatorNumber = 0;
        // Merge 1% against air temperature
        // or 50% against radiator temperature
        // or generally dissipate 0.1% of temperature.
        uint32_t iMergeTemp = 0;
        double iMergeRatio = 100;
        if(pNode->flags.hospital)
        {
            for(auto thob : pNode->objects)
            {
                if(thob == THObjectType::radiator)
                    iRadiatorNumber++;
            }
            if(iRadiatorNumber > 0)
            {
                iMergeTemp = iRadiatorTemperature;
                iMergeRatio = 2 - (iRadiatorNumber - 1) * 0.5;
            }
            else
                iMergeRatio = 1000;
        }
        else
            iMergeTemp = iAirTemperature;

        // Diffuse 25% with neighbours
        pNode->aiTemperature[iNewTemp] = pNode->aiTemperature[iPrevTemp];
        if(iNeighbourCount != 0)
            MERGE(iNeighbourSum / iNeighbourCount, 4 - (iRadiatorNumber > 0 ? (iRadiatorNumber - 1) * 1.5 : 0));

        MERGE(iMergeTemp, iMergeRatio);
#undef MERGE
#undef MERGE2
    }
}

void THMap::updatePathfinding()
{
    THMapNode *pNode = m_pCells;
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pNode)
        {
            pNode->flags.can_travel_n = true;
            pNode->flags.can_travel_e = true;
            pNode->flags.can_travel_s = true;
            pNode->flags.can_travel_w = true;
            if(iX == 0)
                pNode->flags.can_travel_w = false;
            else if(iX == 127)
                pNode->flags.can_travel_e = false;
            if(iY == 0)
                pNode->flags.can_travel_n = false;
            else if(iY == 127)
                pNode->flags.can_travel_s = false;
            if(pNode->iBlock[1] & 0xFF)
            {
                pNode->flags.can_travel_n = false;
                if(iY != 0)
                {
                    pNode[-128].flags.can_travel_s = false;
                }
            }
            if(pNode->iBlock[2] & 0xFF)
            {
                pNode->flags.can_travel_w = false;
                if(iX != 0)
                {
                    pNode[-1].flags.can_travel_e = false;
                }
            }
        }
    }
}

//! For shadow casting, a tile is considered to have a wall on a direction
//! if it has a door in that direction, or the block is from the hardcoded
//! range of wall-like blocks.
static inline bool is_wall(THMapNode *node, size_t block, bool flag)
{
    return flag || (82 <= (node->iBlock[block] & 0xFF) && (node->iBlock[block] & 0xFF) <= 164);
}

void THMap::updateShadows()
{   
    THMapNode *pNode = m_pCells;
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pNode)
        {
            pNode->flags.shadow_full = false;
            pNode->flags.shadow_half = false;
            pNode->flags.shadow_wall = false;
            if(is_wall(pNode, 2, pNode->flags.tall_west))
            {
                pNode->flags.shadow_half = true;
                if(is_wall(pNode, 1, pNode->flags.tall_north))
                {
                    pNode->flags.shadow_wall = true;
                }
                else if(iY != 0)
                {
                    THMapNode *pNeighbour = pNode - 128;
                    pNeighbour->flags.shadow_full = true;
                    if(iX != 0 && !is_wall(pNeighbour, 2, pNode->flags.tall_west))
                    {
                        // Wrap the shadow around a corner (no need to continue
                        // all the way along the wall, as the shadow would be
                        // occluded by the wall. If Debug->Transparent Walls is
                        // toggled on, then this optimisation becomes very
                        // visible, but it's a debug option, so it doesn't
                        // matter).
                        pNeighbour[-1].flags.shadow_full = true;
                    }
                }
            }
        }
    }

#undef IsWall
}

void THMap::persist(LuaPersistWriter *pWriter) const
{
    lua_State *L = pWriter->getStack();
    IntegerRunLengthEncoder oEncoder;

    uint32_t iVersion = 4;
    pWriter->writeVUInt(iVersion);
    pWriter->writeVUInt(m_iPlayerCount);
    for(int i = 0; i < m_iPlayerCount; ++i)
    {
        pWriter->writeVUInt(m_aiInitialCameraX[i]);
        pWriter->writeVUInt(m_aiInitialCameraY[i]);
        pWriter->writeVUInt(m_aiHeliportX[i]);
        pWriter->writeVUInt(m_aiHeliportY[i]);
    }
    pWriter->writeVUInt(m_iParcelCount);
    for(int i = 0; i < m_iParcelCount; ++i)
    {
        pWriter->writeVUInt(m_pPlotOwner[i]);
    }
    for(int i = 0; i < m_iParcelCount; ++i)
    {
        pWriter->writeVUInt(m_pParcelTileCounts[i]);
    }
    pWriter->writeVUInt(m_iWidth);
    pWriter->writeVUInt(m_iHeight);
    pWriter->writeVUInt(m_iCurrentTemperatureIndex);
    oEncoder.initialise(6);
    for(THMapNode *pNode = m_pCells, *pLastNode = m_pCells + m_iWidth * m_iHeight;
        pNode != pLastNode; ++pNode)
    {
        oEncoder.write(pNode->iBlock[0]);
        oEncoder.write(pNode->iBlock[1]);
        oEncoder.write(pNode->iBlock[2]);
        oEncoder.write(pNode->iBlock[3]);
        oEncoder.write(pNode->iParcelId);
        oEncoder.write(pNode->iRoomId);
        // Flags include THOB values, and other things which do not work
        // well with run-length encoding.
        pWriter->writeVUInt(static_cast<uint32_t>(pNode->flags));
        pWriter->writeVUInt(pNode->aiTemperature[0]);
        pWriter->writeVUInt(pNode->aiTemperature[1]);

        lua_rawgeti(L, luaT_upvalueindex(1), 2);
        lua_pushlightuserdata(L, pNode->m_pNext);
        lua_rawget(L, -2);
        pWriter->writeStackObject(-1);
        lua_pop(L, 1);
        lua_pushlightuserdata(L, pNode->oEarlyEntities.m_pNext);
        lua_rawget(L, -2);
        pWriter->writeStackObject(-1);
        lua_pop(L, 2);
    }
    oEncoder.finish();
    oEncoder.pumpOutput(pWriter);

    oEncoder.initialise(5);
    for(THMapNode *pNode = m_pOriginalCells, *pLastNode = m_pOriginalCells + m_iWidth * m_iHeight;
        pNode != pLastNode; ++pNode)
    {
        oEncoder.write(pNode->iBlock[0]);
        oEncoder.write(pNode->iBlock[1]);
        oEncoder.write(pNode->iBlock[2]);
        oEncoder.write(pNode->iParcelId);
        oEncoder.write(static_cast<uint32_t>(pNode->flags));
    }
    oEncoder.finish();
    oEncoder.pumpOutput(pWriter);
}

void THMap::depersist(LuaPersistReader *pReader)
{
    new (this) THMap; // Call constructor

    lua_State *L = pReader->getStack();
    int iWidth, iHeight;
    IntegerRunLengthDecoder oDecoder;

    uint32_t iVersion;
    if(!pReader->readVUInt(iVersion)) return;
    if(iVersion != 4)
    {
        if(iVersion < 2 || iVersion == 128)
        {
            luaL_error(L, "TODO: Write code to load map data from earlier "
                "savegame versions (if really necessary).");
        }
        else if(iVersion > 4)
        {
            luaL_error(L, "Cannot load savegame from a newer version.");
        }
    }
    if(!pReader->readVUInt(m_iPlayerCount)) return;
    for(int i = 0; i < m_iPlayerCount; ++i)
    {
        if(!pReader->readVUInt(m_aiInitialCameraX[i])) return;
        if(!pReader->readVUInt(m_aiInitialCameraY[i])) return;
        if(!pReader->readVUInt(m_aiHeliportX[i])) return;
        if(!pReader->readVUInt(m_aiHeliportY[i])) return;
    }
    if(!pReader->readVUInt(m_iParcelCount)) return;
    delete[] m_pPlotOwner;
    m_pPlotOwner = new int[m_iParcelCount];
    for(int i = 0; i < m_iParcelCount; ++i)
    {
        if(!pReader->readVUInt(m_pPlotOwner[i])) return;
    }
    delete[] m_pParcelTileCounts;
    m_pParcelTileCounts = new int[m_iParcelCount];
    m_pParcelTileCounts[0] = 0;

    if(iVersion >= 3)
    {
        for(int i = 0; i < m_iParcelCount; ++i)
        {
            if(!pReader->readVUInt(m_pParcelTileCounts[i])) return;
        }
    }

    if(!pReader->readVUInt(iWidth) || !pReader->readVUInt(iHeight))
        return;
    if(!setSize(iWidth, iHeight))
    {
        pReader->setError("Unable to set size while depersisting map");
        return;
    }
    if(iVersion >= 4)
    {
        if(!pReader->readVUInt(m_iCurrentTemperatureIndex))
            return;
    }
    for(THMapNode *pNode = m_pCells, *pLastNode = m_pCells + m_iWidth * m_iHeight;
        pNode != pLastNode; ++pNode)
    {
        uint32_t f;
        if(!pReader->readVUInt(f)) return;
        pNode->flags = f;
        if(iVersion >= 4)
        {
            if(!pReader->readVUInt(pNode->aiTemperature[0])
            || !pReader->readVUInt(pNode->aiTemperature[1])) return;
        }
        if(!pReader->readStackObject())
            return;
        pNode->m_pNext = (THLinkList*)lua_touserdata(L, -1);
        if(pNode->m_pNext)
        {
            if(pNode->m_pNext->m_pPrev != nullptr)
                std::fprintf(stderr, "Warning: THMap linked-lists are corrupted.\n");
            pNode->m_pNext->m_pPrev = pNode;
        }
        lua_pop(L, 1);
        if(!pReader->readStackObject())
            return;
        pNode->oEarlyEntities.m_pNext = (THLinkList*)lua_touserdata(L, -1);
        if(pNode->oEarlyEntities.m_pNext)
        {
            if(pNode->oEarlyEntities.m_pNext->m_pPrev != nullptr)
                std::fprintf(stderr, "Warning: THMap linked-lists are corrupted.\n");
            pNode->oEarlyEntities.m_pNext->m_pPrev = &pNode->oEarlyEntities;
        }
        lua_pop(L, 1);
    }
    oDecoder.initialise(6, pReader);
    for(THMapNode *pNode = m_pCells, *pLastNode = m_pCells + m_iWidth * m_iHeight;
        pNode != pLastNode; ++pNode)
    {
        pNode->iBlock[0] = static_cast<uint16_t>(oDecoder.read());
        pNode->iBlock[1] = static_cast<uint16_t>(oDecoder.read());
        pNode->iBlock[2] = static_cast<uint16_t>(oDecoder.read());
        pNode->iBlock[3] = static_cast<uint16_t>(oDecoder.read());
        pNode->iParcelId = static_cast<uint16_t>(oDecoder.read());
        pNode->iRoomId   = static_cast<uint16_t>(oDecoder.read());
    }
    oDecoder.initialise(5, pReader);
    for(THMapNode *pNode = m_pOriginalCells, *pLastNode = m_pOriginalCells + m_iWidth * m_iHeight;
        pNode != pLastNode; ++pNode)
    {
        pNode->iBlock[0] = static_cast<uint16_t>(oDecoder.read());
        pNode->iBlock[1] = static_cast<uint16_t>(oDecoder.read());
        pNode->iBlock[2] = static_cast<uint16_t>(oDecoder.read());
        pNode->iParcelId = static_cast<uint16_t>(oDecoder.read());
        pNode->flags = oDecoder.read();
    }

    if(iVersion < 3)
    {
        for(int i = 1; i < m_iParcelCount; ++i)
            m_pParcelTileCounts[i] = _getParcelTileCount(i);
    }
}

THMapNodeIterator::THMapNodeIterator()
    : m_pNode(nullptr)
    , m_pMap(nullptr)
    , m_iScreenX(0)
    , m_iScreenY(0)
    , m_iScreenWidth(0)
    , m_iScreenHeight(0)
{
}

THMapNodeIterator::THMapNodeIterator(const THMap *pMap, int iScreenX, int iScreenY,
                                     int iWidth, int iHeight,
                                     eTHMapScanlineIteratorDirection eScanlineDirection)
    : m_pMap(pMap)
    , m_iScreenX(iScreenX)
    , m_iScreenY(iScreenY)
    , m_iScreenWidth(iWidth)
    , m_iScreenHeight(iHeight)
    , m_iScanlineCount(0)
    , m_eDirection(eScanlineDirection)
{
    if(m_eDirection == ScanlineForward)
    {
        m_iBaseX = 0;
        m_iBaseY = (iScreenY - 32) / 16;
        if(m_iBaseY < 0)
            m_iBaseY = 0;
        else if(m_iBaseY >= m_pMap->getHeight())
        {
            m_iBaseX = m_iBaseY - m_pMap->getHeight() + 1;
            m_iBaseY = m_pMap->getHeight() - 1;
            if(m_iBaseX >= m_pMap->getWidth())
                m_iBaseX = m_pMap->getWidth() - 1;
        }
    }
    else
    {
        m_iBaseX = m_pMap->getWidth() - 1;
        m_iBaseY = m_pMap->getHeight() - 1;
    }
    m_iX = m_iBaseX;
    m_iY = m_iBaseY;
    _advanceUntilVisible();
}

THMapNodeIterator& THMapNodeIterator::operator ++ ()
{
    --m_iY;
    ++m_iX;
    _advanceUntilVisible();
    return *this;
}

void THMapNodeIterator::_advanceUntilVisible()
{
    m_pNode = nullptr;

    while(true)
    {
        m_iXs = m_iX;
        m_iYs = m_iY;
        m_pMap->worldToScreen(m_iXs, m_iYs);
        m_iXs -= m_iScreenX;
        m_iYs -= m_iScreenY;
        if(m_eDirection == ScanlineForward ?
            m_iYs >= m_iScreenHeight + ms_iMarginBottom :
            m_iYs < -ms_iMarginTop)
        {
                return;
        }
        if(m_eDirection == ScanlineForward ?
            (m_iYs > -ms_iMarginTop) :
            (m_iYs < m_iScreenHeight + ms_iMarginBottom))
        {
            while(m_iY >= 0 && m_iX < m_pMap->getWidth())
            {
                if(m_iXs < -ms_iMarginLeft)
                {
                    // Nothing to do
                }
                else if(m_iXs < m_iScreenWidth + ms_iMarginRight)
                {
                    ++m_iScanlineCount;
                    m_pNode = m_pMap->getNodeUnchecked(m_iX, m_iY);
                    return;
                }
                else
                    break;
                --m_iY;
                ++m_iX;
                m_iXs += 64;
            }
        }
        m_iScanlineCount = 0;
        if(m_eDirection == ScanlineForward)
        {
            if(m_iBaseY == m_pMap->getHeight() - 1)
            {
                if(++m_iBaseX == m_pMap->getWidth())
                    break;
            }
            else
                ++m_iBaseY;
        }
        else
        {
            if(m_iBaseX == 0)
            {
                if(m_iBaseY == 0)
                    break;
                else
                    --m_iBaseY;
            }
            else
                --m_iBaseX;
        }
        m_iX = m_iBaseX;
        m_iY = m_iBaseY;
    }
}

bool THMapNodeIterator::isLastOnScanline() const
{
    return m_iY <= 0 || m_iX + 1 >= m_pMap->getWidth() ||
        m_iXs + 64 >= m_iScreenWidth + ms_iMarginRight;
}

THMapScanlineIterator::THMapScanlineIterator()
    : m_iNodeStep(0)
    , m_iXStep(0)
    , m_takenSteps(0)
{
}

THMapScanlineIterator::THMapScanlineIterator(const THMapNodeIterator& itrNodes,
                                             eTHMapScanlineIteratorDirection eDirection,
                                             int iXOffset, int iYOffset)
    : m_iNodeStep((static_cast<int>(eDirection) - 1) * (1 - itrNodes.m_pMap->getWidth()))
    , m_iXStep((static_cast<int>(eDirection) - 1) * 64)
    , m_takenSteps(0)
{
    if(eDirection == ScanlineBackward)
    {
        m_pNode = itrNodes.m_pNode;
        m_iXs = itrNodes.x();
    }
    else
    {
        m_pNode = itrNodes.m_pNode - m_iNodeStep * (itrNodes.m_iScanlineCount - 1);
        m_iXs = itrNodes.x() - m_iXStep * (itrNodes.m_iScanlineCount - 1);
    }

    m_iXs += iXOffset;
    m_iYs = itrNodes.y() + iYOffset;

    m_pNodeEnd = m_pNode + m_iNodeStep * itrNodes.m_iScanlineCount;
    m_pNodeFirst = m_pNode;

}

THMapScanlineIterator& THMapScanlineIterator::operator ++ ()
{
    m_pNode += m_iNodeStep;
    m_iXs += m_iXStep;
    m_takenSteps++;
    return *this;
}

//copies the members of the given THMapScanlineIterator and resets the node member to the
//first element.
THMapScanlineIterator THMapScanlineIterator::operator= (const THMapScanlineIterator &iterator)
 {
     m_pNode = iterator.m_pNodeFirst;
     m_pNodeEnd = iterator.m_pNodeEnd;
     m_iXs = iterator.m_iXs - iterator.m_takenSteps * iterator.m_iXStep;
     m_iYs = iterator.m_iYs;
     m_iXStep = iterator.m_iXStep;
     m_iNodeStep = iterator.m_iNodeStep;
     return *this;
 }
