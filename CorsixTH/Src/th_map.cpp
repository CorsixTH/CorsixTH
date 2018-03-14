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

map_tile_flags& map_tile_flags::operator=(uint32_t raw)
{
    passable = (raw & static_cast<uint32_t>(map_tile_flags::key::passable_mask)) != 0;
    can_travel_n = (raw & static_cast<uint32_t>(map_tile_flags::key::can_travel_n_mask)) != 0;
    can_travel_e = (raw & static_cast<uint32_t>(map_tile_flags::key::can_travel_e_mask)) != 0;
    can_travel_s = (raw & static_cast<uint32_t>(map_tile_flags::key::can_travel_s_mask)) != 0;
    can_travel_w = (raw & static_cast<uint32_t>(map_tile_flags::key::can_travel_w_mask)) != 0;
    hospital = (raw & static_cast<uint32_t>(map_tile_flags::key::hospital_mask)) != 0;
    buildable = (raw & static_cast<uint32_t>(map_tile_flags::key::buildable_mask)) != 0;
    passable_if_not_for_blueprint = (raw & static_cast<uint32_t>(map_tile_flags::key::passable_if_not_for_blueprint_mask)) != 0;
    room = (raw & static_cast<uint32_t>(map_tile_flags::key::room_mask)) != 0;
    shadow_half = (raw & static_cast<uint32_t>(map_tile_flags::key::shadow_half_mask)) != 0;
    shadow_full = (raw & static_cast<uint32_t>(map_tile_flags::key::shadow_full_mask)) != 0;
    shadow_wall = (raw & static_cast<uint32_t>(map_tile_flags::key::shadow_wall_mask)) != 0;
    door_north = (raw & static_cast<uint32_t>(map_tile_flags::key::door_north_mask)) != 0;
    door_west = (raw & static_cast<uint32_t>(map_tile_flags::key::door_west_mask)) != 0;
    do_not_idle = (raw & static_cast<uint32_t>(map_tile_flags::key::do_not_idle_mask)) != 0;
    tall_north = (raw & static_cast<uint32_t>(map_tile_flags::key::tall_north_mask)) != 0;
    tall_west = (raw & static_cast<uint32_t>(map_tile_flags::key::tall_west_mask)) != 0;
    buildable_n = (raw & static_cast<uint32_t>(map_tile_flags::key::buildable_n_mask)) != 0;
    buildable_e = (raw & static_cast<uint32_t>(map_tile_flags::key::buildable_e_mask)) != 0;
    buildable_s = (raw & static_cast<uint32_t>(map_tile_flags::key::buildable_s_mask)) != 0;
    buildable_w = (raw & static_cast<uint32_t>(map_tile_flags::key::buildable_w_mask)) != 0;

    return *this;
}

bool& map_tile_flags::operator[](map_tile_flags::key key)
{
    switch(key)
    {
    case map_tile_flags::key::passable_mask:
        return passable;
    case map_tile_flags::key::can_travel_n_mask:
        return can_travel_n;
    case map_tile_flags::key::can_travel_e_mask:
        return can_travel_e;
    case map_tile_flags::key::can_travel_s_mask:
        return can_travel_s;
    case map_tile_flags::key::can_travel_w_mask:
        return can_travel_w;
    case map_tile_flags::key::hospital_mask:
        return hospital;
    case map_tile_flags::key::buildable_mask:
        return buildable;
    case map_tile_flags::key::passable_if_not_for_blueprint_mask:
        return passable_if_not_for_blueprint;
    case map_tile_flags::key::room_mask:
        return room;
    case map_tile_flags::key::shadow_half_mask:
        return shadow_half;
    case map_tile_flags::key::shadow_full_mask:
        return shadow_full;
    case map_tile_flags::key::shadow_wall_mask:
        return shadow_wall;
    case map_tile_flags::key::door_north_mask:
        return door_north;
    case map_tile_flags::key::door_west_mask:
        return door_west;
    case map_tile_flags::key::do_not_idle_mask:
        return do_not_idle;
    case map_tile_flags::key::tall_north_mask:
        return tall_north;
    case map_tile_flags::key::tall_west_mask:
        return tall_west;
    case map_tile_flags::key::buildable_n_mask:
        return buildable_n;
    case map_tile_flags::key::buildable_e_mask:
        return buildable_e;
    case map_tile_flags::key::buildable_s_mask:
        return buildable_s;
    case map_tile_flags::key::buildable_w_mask:
        return buildable_w;
    default:
        throw std::out_of_range("map tile flag is invalid");
    }
}

const bool& map_tile_flags::operator[](map_tile_flags::key key) const
{
    switch(key)
    {
    case map_tile_flags::key::passable_mask:
        return passable;
    case map_tile_flags::key::can_travel_n_mask:
        return can_travel_n;
    case map_tile_flags::key::can_travel_e_mask:
        return can_travel_e;
    case map_tile_flags::key::can_travel_s_mask:
        return can_travel_s;
    case map_tile_flags::key::can_travel_w_mask:
        return can_travel_w;
    case map_tile_flags::key::hospital_mask:
        return hospital;
    case map_tile_flags::key::buildable_mask:
        return buildable;
    case map_tile_flags::key::passable_if_not_for_blueprint_mask:
        return passable_if_not_for_blueprint;
    case map_tile_flags::key::room_mask:
        return room;
    case map_tile_flags::key::shadow_half_mask:
        return shadow_half;
    case map_tile_flags::key::shadow_full_mask:
        return shadow_full;
    case map_tile_flags::key::shadow_wall_mask:
        return shadow_wall;
    case map_tile_flags::key::door_north_mask:
        return door_north;
    case map_tile_flags::key::door_west_mask:
        return door_west;
    case map_tile_flags::key::do_not_idle_mask:
        return do_not_idle;
    case map_tile_flags::key::tall_north_mask:
        return tall_north;
    case map_tile_flags::key::tall_west_mask:
        return tall_west;
    case map_tile_flags::key::buildable_n_mask:
        return buildable_n;
    case map_tile_flags::key::buildable_e_mask:
        return buildable_e;
    case map_tile_flags::key::buildable_s_mask:
        return buildable_s;
    case map_tile_flags::key::buildable_w_mask:
        return buildable_w;
    default:
        throw std::out_of_range("map tile flag is invalid");
    }
}

map_tile_flags::operator uint32_t() const
{
    uint32_t raw = 0;
    if(passable) { raw |= static_cast<uint32_t>(map_tile_flags::key::passable_mask); }
    if(can_travel_n) { raw |= static_cast<uint32_t>(map_tile_flags::key::can_travel_n_mask); }
    if(can_travel_e) { raw |= static_cast<uint32_t>(map_tile_flags::key::can_travel_e_mask); }
    if(can_travel_s) { raw |= static_cast<uint32_t>(map_tile_flags::key::can_travel_s_mask); }
    if(can_travel_w) { raw |= static_cast<uint32_t>(map_tile_flags::key::can_travel_w_mask); }
    if(hospital) { raw |= static_cast<uint32_t>(map_tile_flags::key::hospital_mask); }
    if(buildable) { raw |= static_cast<uint32_t>(map_tile_flags::key::buildable_mask); }
    if(passable_if_not_for_blueprint) { raw |= static_cast<uint32_t>(map_tile_flags::key::passable_if_not_for_blueprint_mask); }
    if(room) { raw |= static_cast<uint32_t>(map_tile_flags::key::room_mask); }
    if(shadow_half) { raw |= static_cast<uint32_t>(map_tile_flags::key::shadow_half_mask); }
    if(shadow_full) { raw |= static_cast<uint32_t>(map_tile_flags::key::shadow_full_mask); }
    if(shadow_wall) { raw |= static_cast<uint32_t>(map_tile_flags::key::shadow_wall_mask); }
    if(door_north) { raw |= static_cast<uint32_t>(map_tile_flags::key::door_north_mask); }
    if(door_west) { raw |= static_cast<uint32_t>(map_tile_flags::key::door_west_mask); }
    if(do_not_idle) { raw |= static_cast<uint32_t>(map_tile_flags::key::do_not_idle_mask); }
    if(tall_north) { raw |= static_cast<uint32_t>(map_tile_flags::key::tall_north_mask); }
    if(tall_west) { raw |= static_cast<uint32_t>(map_tile_flags::key::tall_west_mask); }
    if(buildable_n) { raw |= static_cast<uint32_t>(map_tile_flags::key::buildable_n_mask); }
    if(buildable_e) { raw |= static_cast<uint32_t>(map_tile_flags::key::buildable_e_mask); }
    if(buildable_s) { raw |= static_cast<uint32_t>(map_tile_flags::key::buildable_s_mask); }
    if(buildable_w) { raw |= static_cast<uint32_t>(map_tile_flags::key::buildable_w_mask); }

    return raw;
}

map_tile::map_tile() :
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

map_tile::~map_tile()
{
}

level_map::level_map()
{
    width = 0;
    height = 0;
    player_count = 0;
    current_temperature_index = 0;
    current_temperature_theme = temperature_theme::red;
    parcel_count = 0;
    cells = nullptr;
    original_cells = nullptr;
    blocks = nullptr;
    overlay = nullptr;
    owns_overlay = false;
    plot_owner = nullptr;
    parcel_tile_counts = nullptr;
    parcel_adjacency_matrix = nullptr;
    purchasable_matrix = nullptr;
}

level_map::~level_map()
{
    set_overlay(nullptr, false);
    delete[] cells;
    delete[] original_cells;
    delete[] plot_owner;
    delete[] parcel_tile_counts;
    delete[] parcel_adjacency_matrix;
    delete[] purchasable_matrix;
}

void level_map::set_overlay(map_overlay *pOverlay, bool bTakeOwnership)
{
    if(overlay && owns_overlay)
        delete overlay;
    overlay = pOverlay;
    owns_overlay = bTakeOwnership;
}

bool level_map::set_size(int iWidth, int iHeight)
{
    if(iWidth <= 0 || iHeight <= 0)
        return false;

    delete[] cells;
    delete[] original_cells;
    delete[] parcel_adjacency_matrix;
    delete[] purchasable_matrix;
    width = iWidth;
    height = iHeight;
    cells = nullptr;
    cells = new (std::nothrow) map_tile[iWidth * iHeight];
    original_cells = nullptr;
    original_cells = new (std::nothrow) map_tile[iWidth * iHeight];
    parcel_adjacency_matrix = nullptr;
    purchasable_matrix = nullptr;

    if(cells == nullptr || original_cells == nullptr)
    {
        delete[] cells;
        delete[] original_cells;
        original_cells = nullptr;
        cells = nullptr;
        width = 0;
        height = 0;
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

void level_map::read_tile_index(const uint8_t* pData, int& iX, int &iY) const
{
    unsigned int iIndex = static_cast<unsigned int>(pData[1]);
    iIndex = iIndex * 0x100 + static_cast<unsigned int>(pData[0]);
    iX = iIndex % width;
    iY = iIndex / width;
}

void level_map::write_tile_index(uint8_t* pData, int iX, int iY) const
{
    uint16_t iIndex = static_cast<uint16_t>(iY * width + iX);
    pData[0] = static_cast<uint8_t>(iIndex & 0xFF);
    pData[1] = static_cast<uint8_t>(iIndex >> 8);
}

bool level_map::load_blank()
{
    if(!set_size(128, 128))
        return false;

    player_count = 1;
    initial_camera_x[0] = initial_camera_y[0] = 63;
    heliport_x[0] = heliport_y[0] = 0;
    parcel_count = 1;
    delete[] plot_owner;
    delete[] parcel_tile_counts;
    plot_owner = nullptr;
    parcel_tile_counts = nullptr;
    map_tile *pNode = cells;
    map_tile *pOriginalNode = original_cells;
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pNode, ++pOriginalNode)
        {
            pNode->iBlock[0] = static_cast<uint16_t>(2 + (iX % 2));
        }
    }
    plot_owner = new int[1];
    plot_owner[0] = 0;
    parcel_tile_counts = new int[1];
    parcel_tile_counts[0] = 128 * 128;

    return true;
}

bool level_map::load_from_th_file(const uint8_t* pData, size_t iDataLength,
                           map_load_object_callback_fn fnObjectCallback,
                           void* pCallbackToken)
{
    if(iDataLength < 163948 || !set_size(128, 128))
        return false;

    player_count = pData[0];
    for(int i = 0; i < player_count; ++i)
    {
        read_tile_index(pData + 163876 + (i % 4) * 2,
            initial_camera_x[i], initial_camera_y[i]);
        read_tile_index(pData + 163884 + (i % 4) * 2,
            heliport_x[i], heliport_y[i]);
    }
    parcel_count = 0;
    delete[] plot_owner;
    delete[] parcel_tile_counts;
    plot_owner = nullptr;
    parcel_tile_counts = nullptr;

    map_tile *pNode = cells;
    map_tile *pOriginalNode = original_cells;
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
            if(*pParcel >= parcel_count)
                parcel_count = *pParcel + 1;

            if(!(pData[5] & 1))
            {
                pNode->flags.passable = true;
                if(!(pData[7] & 16))
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
                fnObjectCallback(pCallbackToken, iX, iY, (object_type)pData[1], pData[0]);
            }
        }
    }
    plot_owner = new int[parcel_count];
    plot_owner[0] = 0;
    for(int i = 1; i < parcel_count; ++i)
        plot_owner[i] = 1;

    update_shadows();

    parcel_tile_counts = new int[parcel_count];
    parcel_tile_counts[0] = 0;
    for(int i = 1; i < parcel_count; ++i)
        parcel_tile_counts[i] = count_parcel_tiles(i);

    return true;
}

void level_map::save(std::string filename)
{
    uint8_t aBuffer[256] = {0};
    int iBufferNext = 0;
    std::ofstream os(filename, std::ios_base::trunc | std::ios_base::binary);

    // Header
    aBuffer[0] = static_cast<uint8_t>(player_count);
    // TODO: Determine correct contents for the next 33 bytes
    os.write(reinterpret_cast<char*>(aBuffer), 34);

    uint8_t aReverseBlockLUT[256] = {0};
    for(int i = 0; i < 256; ++i)
    {
        aReverseBlockLUT[gs_iTHMapBlockLUT[i]] = static_cast<uint8_t>(i);
    }
    aReverseBlockLUT[0] = 0;

    for(map_tile *pNode = cells, *pLimitNode = pNode + width * height;
        pNode != pLimitNode; ++pNode)
    {
        // TODO: Nicer system for saving object data
        aBuffer[iBufferNext++] = pNode->flags.tall_west ? 1 : 0;
        aBuffer[iBufferNext++] = static_cast<uint8_t>(pNode->objects.empty() ? object_type::no_object : pNode->objects.front());

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
            os.write(reinterpret_cast<char*>(aBuffer), sizeof(aBuffer));
            iBufferNext = 0;
        }
    }
    for(map_tile *pNode = cells, *pLimitNode = pNode + width * height;
        pNode != pLimitNode; ++pNode)
    {
        aBuffer[iBufferNext++] = static_cast<uint8_t>(pNode->iParcelId & 0xFF);
        aBuffer[iBufferNext++] = static_cast<uint8_t>(pNode->iParcelId >> 8);
        if(iBufferNext == sizeof(aBuffer))
        {
            os.write(reinterpret_cast<char*>(aBuffer), sizeof(aBuffer));
            iBufferNext = 0;
        }
    }

    // TODO: What are these two bytes?
    aBuffer[iBufferNext++] = 3;
    aBuffer[iBufferNext++] = 0;
    os.write(reinterpret_cast<char*>(aBuffer), iBufferNext);
    iBufferNext = 0;

    std::memset(aBuffer, 0, 56);
    for(int i = 0; i < player_count; ++i)
    {
        write_tile_index(aBuffer + iBufferNext,
            initial_camera_x[i], initial_camera_y[i]);
        write_tile_index(aBuffer + iBufferNext + 8,
            heliport_x[i], heliport_y[i]);
        iBufferNext += 2;
    }
    os.write(reinterpret_cast<char*>(aBuffer), 16);
    std::memset(aBuffer, 0, 16);
    // TODO: What are these 56 bytes?
    os.write(reinterpret_cast<char*>(aBuffer), 56);
    os.close();
}

//! Add or remove divider wall for the given tile
/*!
   If the given 'pNode' has an indoor border to another parcel in the 'delta' direction:
   * A divider wall is added in the layer specified by 'block' if the owners
     of the two parcels are not the same, or
   * A divider wall is removed if the owners are the same and 'iParcelId' is involved.
   \return True if a border was removed, false otherwise
*/
static bool addRemoveDividerWalls(level_map* pMap, map_tile* pNode, const map_tile* pOriginalNode,
                                  int iXY, int delta, int block, int iParcelId)
{
    if (iXY > 0 && pOriginalNode->flags.hospital &&
        pOriginalNode[-delta].flags.hospital &&
        pNode->iParcelId != pNode[-delta].iParcelId)
    {
        int iOwner = pMap->get_parcel_owner(pNode->iParcelId);
        int iOtherOwner = pMap->get_parcel_owner(pNode[-delta].iParcelId);
        if (iOwner != iOtherOwner)
        {
            pNode->iBlock[block] = block + (iOwner ? 143 : 141);
        }
        else if (pNode->iParcelId == iParcelId || pNode[-delta].iParcelId == iParcelId)
        {
            pNode->iBlock[block] = 0;
            return true;
        }
    }
    return false;
}

std::vector<std::pair<int, int>> level_map::set_parcel_owner(int iParcelId, int iOwner)
{
    std::vector<std::pair<int, int>> vSplitTiles;
    if(iParcelId <= 0 || parcel_count <= iParcelId || iOwner < 0)
        return vSplitTiles;
    plot_owner[iParcelId] = iOwner;

    map_tile *pNode = cells;
    const map_tile *pOriginalNode = original_cells;
    
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
            if (addRemoveDividerWalls(this, pNode, pOriginalNode, iX, 1, 2, iParcelId))
            {
                vSplitTiles.push_back(std::make_pair(iX, iY));
            }
            if (addRemoveDividerWalls(this, pNode, pOriginalNode, iY, 128, 1, iParcelId))
            {
                vSplitTiles.push_back(std::make_pair(iX, iY));
            }
        }
    }

    update_pathfinding();
    update_shadows();
    update_purchase_matrix();
    return vSplitTiles;
}

void level_map::make_adjacency_matrix()
{
    if(parcel_adjacency_matrix != nullptr)
        return;

    parcel_adjacency_matrix = new bool[parcel_count * parcel_count];
    for(int i = 0; i < parcel_count; ++i)
    {
        for(int j = 0; j < parcel_count; ++j)
        {
            parcel_adjacency_matrix[i * parcel_count + j] = (i == j);
        }
    }

    const map_tile *pOriginalNode = original_cells;
    for(int iY = 0; iY < 128; ++iY)
    {
        for(int iX = 0; iX < 128; ++iX, ++pOriginalNode)
        {
#define TEST_ADJ(xy, delta) if(xy > 0 && \
            pOriginalNode->iParcelId != pOriginalNode[-delta].iParcelId &&  \
            pOriginalNode->flags.passable && pOriginalNode[-delta].flags.passable)\
            parcel_adjacency_matrix[pOriginalNode->iParcelId * parcel_count\
            + pOriginalNode[-delta].iParcelId] = true, \
            parcel_adjacency_matrix[pOriginalNode->iParcelId + \
            pOriginalNode[-delta].iParcelId * parcel_count] = true

            TEST_ADJ(iX, 1);
            TEST_ADJ(iY, 128);
#undef TEST_ADJ
        }
    }
}

void level_map::make_purchase_matrix()
{
    if(purchasable_matrix != nullptr)
        return; // Already made
    purchasable_matrix = new bool[4 * parcel_count];
    update_purchase_matrix();
}

void level_map::update_purchase_matrix()
{
    if(purchasable_matrix == nullptr)
        return; // Nothing to update
    for(int iPlayer = 1; iPlayer <= 4; ++iPlayer)
    {
        for(int iParcel = 0; iParcel < parcel_count; ++iParcel)
        {
            bool bPurchasable = false;
            if(iParcel != 0 && plot_owner[iParcel] == 0)
            {
                for(int iParcel2 = 0; iParcel2 < parcel_count; ++iParcel2)
                {
                    if((plot_owner[iParcel2] == iPlayer) || (iParcel2 == 0))
                    {
                        if(are_parcels_adjacent(iParcel, iParcel2))
                        {
                            bPurchasable = true;
                            break;
                        }
                    }
                }
            }
            purchasable_matrix[iParcel * 4 + iPlayer - 1] = bPurchasable;
        }
    }
}

bool level_map::are_parcels_adjacent(int iParcel1, int iParcel2)
{
    if(0 <= iParcel1 && iParcel1 < parcel_count
    && 0 <= iParcel2 && iParcel2 < parcel_count)
    {
        make_adjacency_matrix();
        return parcel_adjacency_matrix[iParcel1 * parcel_count + iParcel2];
    }
    return false;
}

bool level_map::is_parcel_purchasable(int iParcelId, int iPlayer)
{
    if(0 <= iParcelId && iParcelId < parcel_count
    && 1 <= iPlayer && iPlayer <= 4)
    {
        make_purchase_matrix();
        return purchasable_matrix[iParcelId * 4 + iPlayer - 1];
    }
    return false;
}

void level_map::set_player_count(int count)
{
    if (count < 1 || count > 4)
        throw std::out_of_range("Player count must be between 1 and 4");

    player_count = count;
}

bool level_map::get_player_camera_tile(int iPlayer, int* pX, int* pY) const
{
    if(iPlayer < 0 || iPlayer >= get_player_count())
    {
        if(pX) *pX = 0;
        if(pY) *pY = 0;
        return false;
    }
    if(pX) *pX = initial_camera_x[iPlayer];
    if(pY) *pY = initial_camera_y[iPlayer];
    return true;
}

bool level_map::get_player_heliport_tile(int iPlayer, int* pX, int* pY) const
{
    if(iPlayer < 0 || iPlayer >= get_player_count())
    {
        if(pX) *pX = 0;
        if(pY) *pY = 0;
        return false;
    }
    if(pX) *pX = heliport_x[iPlayer];
    if(pY) *pY = heliport_y[iPlayer];
    return true;
}

void level_map::set_player_camera_tile(int iPlayer, int iX, int iY)
{
    if(0 <= iPlayer && iPlayer < get_player_count())
    {
        initial_camera_x[iPlayer] = iX;
        initial_camera_y[iPlayer] = iY;
    }
}

void level_map::set_player_heliport_tile(int iPlayer, int iX, int iY)
{
    if(0 <= iPlayer && iPlayer < get_player_count())
    {
        heliport_x[iPlayer] = iX;
        heliport_y[iPlayer] = iY;
    }
}

int level_map::get_parcel_tile_count(int iParcelId) const
{
    if(iParcelId < 1 || iParcelId >= parcel_count)
    {
        return 0;
    }
    return parcel_tile_counts[iParcelId];
}

int level_map::count_parcel_tiles(int iParcelId) const
{
    int iTiles = 0;
    for(int iY = 0; iY < height; ++iY)
    {
        for(int iX = 0; iX < width; ++iX)
        {
            const map_tile* pNode = get_tile_unchecked(iX, iY);
            if(pNode->iParcelId == iParcelId) iTiles++;
        }
    }
    return iTiles;
}

map_tile* level_map::get_tile(int iX, int iY)
{
    if(0 <= iX && iX < width && 0 <= iY && iY < height)
        return get_tile_unchecked(iX, iY);
    else
        return nullptr;
}

const map_tile* level_map::get_tile(int iX, int iY) const
{
    if(0 <= iX && iX < width && 0 <= iY && iY < height)
        return get_tile_unchecked(iX, iY);
    else
        return nullptr;
}

const map_tile* level_map::get_original_tile(int iX, int iY) const
{
    if(0 <= iX && iX < width && 0 <= iY && iY < height)
        return get_original_tile_unchecked(iX, iY);
    else
        return nullptr;
}

map_tile* level_map::get_tile_unchecked(int iX, int iY)
{
    return cells + iY * width + iX;
}

const map_tile* level_map::get_tile_unchecked(int iX, int iY) const
{
    return cells + iY * width + iX;
}

const map_tile* level_map::get_original_tile_unchecked(int iX, int iY) const
{
    return original_cells + iY * width + iX;
}

void level_map::set_block_sheet(sprite_sheet* pSheet)
{
    blocks = pSheet;
}

void level_map::set_all_wall_draw_flags(uint8_t iFlags)
{
    uint16_t iBlockOr = static_cast<uint16_t>(iFlags << 8);
    map_tile *pNode = cells;
    for(int i = 0; i < width * height; ++i, ++pNode)
    {
        pNode->iBlock[1] = static_cast<uint16_t>((pNode->iBlock[1] & 0xFF) | iBlockOr);
        pNode->iBlock[2] = static_cast<uint16_t>((pNode->iBlock[2] & 0xFF) | iBlockOr);
    }
}

// Definition is in th_gfx.h so this should move
void clip_rect_intersection(clip_rect& rcClip,const clip_rect& rcIntersect)
{
    // The intersection of the rectangles is the higher of the lower bounds and the lower of the higher bounds, clamped to a zero size.
    clip_rect::x_y_type maxX = static_cast<uint16_t>(std::min(rcClip.x + rcClip.w, rcIntersect.x + rcIntersect.w));
    clip_rect::x_y_type maxY = static_cast<uint16_t>(std::min(rcClip.y + rcClip.h, rcIntersect.y + rcIntersect.h));
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

void level_map::draw(render_target* pCanvas, int iScreenX, int iScreenY,
                 int iWidth, int iHeight, int iCanvasX, int iCanvasY) const
{
    /*
       The map is drawn in two passes, with each pass done one scanline at a
       time (a scanline is a list of tiles with the same screen Y co-ordinate).
       The first pass does floor tiles, as the entire floor needs to be painted
       below anything else (for example, see the walking north through a door
       animation, which needs to paint over the floor of the scanline below the
       animation). On the second pass, walls and entities are drawn, with the
       order controlled such that entites appear in the right order relative to
       the walls around them. For each scanline, the following is done:

       1st pass:
        1) For each tile, left to right, the floor tile (layer 0)
       2nd pass:
        1) For each tile, right to left, the north wall, then the early entities
        2) For each tile, left to right, the west wall, then the late entities
    */

    if(blocks == nullptr || cells == nullptr)
        return;

    clip_rect rcClip;
    rcClip.x = static_cast<clip_rect::x_y_type>(iCanvasX);
    rcClip.y = static_cast<clip_rect::x_y_type>(iCanvasY);
    rcClip.w = static_cast<clip_rect::w_h_type>(iWidth);
    rcClip.h = static_cast<clip_rect::w_h_type>(iHeight);
    pCanvas->set_clip_rect(&rcClip);

    // 1st pass
    pCanvas->start_nonoverlapping_draws();
    for(map_tile_iterator itrNode1(this, iScreenX, iScreenY, iWidth, iHeight); itrNode1; ++itrNode1)
    {
        unsigned int iH = 32;
        unsigned int iBlock = itrNode1->iBlock[0];
        blocks->get_sprite_size(iBlock & 0xFF, nullptr, &iH);
        blocks->draw_sprite(pCanvas, iBlock & 0xFF,
            itrNode1.tile_x_position_on_screen() + iCanvasX - 32,
            itrNode1.tile_y_position_on_screen() + iCanvasY - iH + 32, iBlock >> 8);
    }
    pCanvas->finish_nonoverlapping_draws();

    bool bFirst = true;
    map_scanline_iterator formerIterator;
    // 2nd pass
    for(map_tile_iterator itrNode2(this, iScreenX, iScreenY, iWidth, iHeight); itrNode2; ++itrNode2)
    {
        if(itrNode2->flags.shadow_full)
        {
            blocks->draw_sprite(pCanvas, 74, itrNode2.tile_x_position_on_screen() + iCanvasX - 32,
                itrNode2.tile_y_position_on_screen() + iCanvasY, thdf_alpha_75);
        }
        else if(itrNode2->flags.shadow_half)
        {
            blocks->draw_sprite(pCanvas, 75, itrNode2.tile_x_position_on_screen() + iCanvasX - 32,
                itrNode2.tile_y_position_on_screen() + iCanvasY, thdf_alpha_75);
        }

        if(!itrNode2.is_last_on_scanline())
            continue;

        for(map_scanline_iterator itrNode(itrNode2, map_scanline_iterator_direction::backward, iCanvasX, iCanvasY); itrNode; ++itrNode)
        {
            unsigned int iH;
            unsigned int iBlock = itrNode->iBlock[1];
            if(iBlock != 0 && blocks->get_sprite_size(iBlock & 0xFF,
                nullptr, &iH) && iH > 0)
            {
                blocks->draw_sprite(pCanvas, iBlock & 0xFF, itrNode.x() - 32,
                    itrNode.y() - iH + 32, iBlock >> 8);
                if(itrNode->flags.shadow_wall)
                {
                    clip_rect rcOldClip, rcNewClip;
                    pCanvas->get_clip_rect(&rcOldClip);
                    rcNewClip.x = static_cast<clip_rect::x_y_type>(itrNode.x() - 32);
                    rcNewClip.y = static_cast<clip_rect::x_y_type>(itrNode.y() - iH + 32 + 4);
                    rcNewClip.w = static_cast<clip_rect::w_h_type>(64);
                    rcNewClip.h = static_cast<clip_rect::w_h_type>(86 - 4);
                    clip_rect_intersection(rcNewClip, rcOldClip);
                    pCanvas->set_clip_rect(&rcNewClip);
                    blocks->draw_sprite(pCanvas, 156, itrNode.x() - 32,
                        itrNode.y() - 56, thdf_alpha_75);
                    pCanvas->set_clip_rect(&rcOldClip);
                }
            }
            drawable *pItem = (drawable*)(itrNode->oEarlyEntities.next);
            while(pItem)
            {
                pItem->draw_fn(pItem, pCanvas, itrNode.x(), itrNode.y());
                pItem = (drawable*)(pItem->next);
            }
        }

        map_scanline_iterator itrNode(itrNode2, map_scanline_iterator_direction::forward, iCanvasX, iCanvasY);
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
            if(iBlock != 0 && blocks->get_sprite_size(iBlock & 0xFF,
                nullptr, &iH) && iH > 0)
            {
                blocks->draw_sprite(pCanvas, iBlock & 0xFF, itrNode.x() - 32,
                    itrNode.y() - iH + 32, iBlock >> 8);
            }
            iBlock = itrNode->iBlock[3];
            if(iBlock != 0 && blocks->get_sprite_size(iBlock & 0xFF,
                nullptr, &iH) && iH > 0)
            {
                blocks->draw_sprite(pCanvas, iBlock & 0xFF, itrNode.x() - 32,
                    itrNode.y() - iH + 32, iBlock >> 8);
            }
            iBlock = itrNode->iBlock[1];
            if(iBlock != 0 && blocks->get_sprite_size(iBlock & 0xFF,
                nullptr, &iH) && iH > 0)
                bNeedsRedraw = true;
            if(itrNode->oEarlyEntities.next)
                bNeedsRedraw = true;

            bool bRedrawAnimations = false;

            drawable *pItem = (drawable*)(itrNode->next);
            while(pItem)
            {
                pItem->draw_fn(pItem, pCanvas, itrNode.x(), itrNode.y());
                if(pItem->is_multiple_frame_animation_fn(pItem))
                    bRedrawAnimations = true;
                if(pItem->get_drawing_layer() == 1)
                    bNeedsRedraw = true;
                pItem = (drawable*)(pItem->next);
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
                pItem = (drawable*)(formerIterator.get_previous_tile()->next);
                while(pItem)
                {
                    if (pItem->get_drawing_layer() == 9)
                    {
                        pItem->draw_fn(pItem, pCanvas, formerIterator.x() - 64, formerIterator.y());
                        bTileNeedsRedraw = true;
                    }
                    pItem = (drawable*)(pItem->next);
                }

                //check if an object in the adjacent tile above the current tile needs to be redrawn
                //and if necessary draw it
                pItem = formerIterator ? (drawable*)(formerIterator->next) : nullptr;
                while(pItem)
                {
                    if(pItem->get_drawing_layer() == 8)
                        pItem->draw_fn(pItem, pCanvas, formerIterator.x(), formerIterator.y());
                    pItem = (drawable*)(pItem->next);
                }


                //if an object was redrawn in the tile to the left of the current tile
                //or if the tile below it had an object in the north side or a wall to the north
                //redraw that tile
                if(bTileNeedsRedraw)
                {
                    //redraw the north wall
                    unsigned int iBlock = itrNode.get_previous_tile()->iBlock[1];
                    if(iBlock != 0 && blocks->get_sprite_size(iBlock & 0xFF,
                        nullptr, &iH) && iH > 0)
                    {
                        blocks->draw_sprite(pCanvas, iBlock & 0xFF, itrNode.x() - 96,
                            itrNode.y() - iH + 32, iBlock >> 8);
                        if(itrNode.get_previous_tile()->flags.shadow_wall)
                        {
                            clip_rect rcOldClip, rcNewClip;
                            pCanvas->get_clip_rect(&rcOldClip);
                            rcNewClip.x = static_cast<clip_rect::x_y_type>(itrNode.x() - 96);
                            rcNewClip.y = static_cast<clip_rect::x_y_type>(itrNode.y() - iH + 32 + 4);
                            rcNewClip.w = static_cast<clip_rect::w_h_type>(64);
                            rcNewClip.h = static_cast<clip_rect::w_h_type>(86 - 4);
                            clip_rect_intersection(rcNewClip, rcOldClip);
                            pCanvas->set_clip_rect(&rcNewClip);
                            blocks->draw_sprite(pCanvas, 156, itrNode.x() - 96,
                                itrNode.y() - 56, thdf_alpha_75);
                            pCanvas->set_clip_rect(&rcOldClip);
                        }
                    }
                    pItem = (drawable*)(itrNode.get_previous_tile()->oEarlyEntities.next);
                    while(pItem)
                    {
                        pItem->draw_fn(pItem, pCanvas, itrNode.x() - 64, itrNode.y());
                        pItem = (drawable*)(pItem->next);
                    }

                    pItem = (drawable*)(itrNode.get_previous_tile())->next;
                    for(; pItem; pItem = (drawable*)(pItem->next))
                        pItem->draw_fn(pItem, pCanvas, itrNode.x() - 64, itrNode.y());
                }
            }
           bPreviousTileNeedsRedraw = bNeedsRedraw;
           if (!bFirst) ++formerIterator;
        }

     formerIterator = itrNode;
     bFirst = false;
    }

    if(overlay)
    {
        for(map_tile_iterator itrNode(this, iScreenX, iScreenY, iWidth, iHeight); itrNode; ++itrNode)
        {
            overlay->draw_cell(pCanvas, itrNode.tile_x_position_on_screen() + iCanvasX - 32,
                itrNode.tile_y_position_on_screen() + iCanvasY, this, itrNode.tile_x(), itrNode.tile_y());
        }
    }

    pCanvas->set_clip_rect(nullptr);
}

drawable* level_map::hit_test(int iTestX, int iTestY) const
{
    // This function needs to hitTest each drawable object, in the reverse
    // order to that in which they would be drawn.

    if(blocks == nullptr || cells == nullptr)
        return nullptr;

    for(map_tile_iterator itrNode2(this, iTestX, iTestY, 1, 1, map_scanline_iterator_direction::backward); itrNode2; ++itrNode2)
    {
        if(!itrNode2.is_last_on_scanline())
            continue;

        for(map_scanline_iterator itrNode(itrNode2, map_scanline_iterator_direction::backward); itrNode; ++itrNode)
        {
            if(itrNode->next != nullptr)
            {
                drawable* pResult = hit_test_drawables(itrNode->next,
                    itrNode.x(), itrNode.y(), 0, 0);
                if(pResult)
                    return pResult;
            }
        }
        for(map_scanline_iterator itrNode(itrNode2, map_scanline_iterator_direction::forward); itrNode; ++itrNode)
        {
            if(itrNode->oEarlyEntities.next != nullptr)
            {
                drawable* pResult = hit_test_drawables(itrNode->oEarlyEntities.next,
                    itrNode.x(), itrNode.y(), 0, 0);
                if(pResult)
                    return pResult;
            }
        }
    }

    return nullptr;
}

drawable* level_map::hit_test_drawables(link_list* pListStart, int iXs, int iYs,
                                        int iTestX, int iTestY) const
{
    link_list* pListEnd = pListStart;
    while(pListEnd->next)
        pListEnd = pListEnd->next;
    drawable* pList = (drawable*)pListEnd;

    while(true)
    {
        if(pList->hit_test_fn(pList, iXs, iYs, iTestX, iTestY))
            return pList;

        if(pList == pListStart)
            return nullptr;
        else
            pList = (drawable*)pList->prev;
    }
}

int level_map::get_tile_owner(const map_tile* pNode) const
{
    return plot_owner[pNode->iParcelId];
}

int level_map::get_parcel_owner(int iParcel) const
{
    if(0 <= iParcel && iParcel < parcel_count)
        return plot_owner[iParcel];
    else
        return 0;
}


uint16_t level_map::get_tile_temperature(const map_tile* pNode) const
{
    return pNode->aiTemperature[current_temperature_index];
}

void level_map::set_temperature_display(temperature_theme eTempDisplay)
{
    current_temperature_theme = eTempDisplay;
}

uint32_t level_map::thermal_neighbour(uint32_t &iNeighbourSum, bool canTravel, std::ptrdiff_t relative_idx, map_tile* pNode, int prevTemp) const
{
    int iNeighbourCount = 0;

    map_tile* pNeighbour = pNode + relative_idx;

    // Ensure the neighbour is within the map bounds
    map_tile* pLimitNode = cells + width * height;
    if (pNeighbour < cells || pNeighbour >= pLimitNode) {
        return 0;
    }

    if (canTravel) {
        iNeighbourCount += 4;
        iNeighbourSum += pNeighbour->aiTemperature[prevTemp] * 4;
    } else {
        bool bObjectPresent = false;
        int iHospital1 = pNeighbour->flags.hospital;
        int iHospital2 = pNode->flags.hospital;
        if (iHospital1 == iHospital2) {
            if (pNeighbour->flags.room == pNode->flags.room) {
                bObjectPresent = true;
            }
        }
        if (bObjectPresent) {
            iNeighbourCount += 4;
            iNeighbourSum += pNeighbour->aiTemperature[prevTemp] * 4;
        } else {
            iNeighbourCount += 1;
            iNeighbourSum += pNeighbour->aiTemperature[prevTemp];
        }
    }

    return iNeighbourCount;
}


void level_map::update_temperatures(uint16_t iAirTemperature,
                               uint16_t iRadiatorTemperature)
{
    if(iRadiatorTemperature < iAirTemperature) {
        iRadiatorTemperature = iAirTemperature;
    }
    const int iPrevTemp = current_temperature_index;
    current_temperature_index ^= 1;
    const int iNewTemp = current_temperature_index;

    map_tile* pLimitNode = cells + width * height;
    for(map_tile *pNode = cells; pNode != pLimitNode; ++pNode) {
        // Get average temperature of neighbour cells
        uint32_t iNeighbourSum = 0;
        uint32_t iNeighbourCount = 0;

        iNeighbourCount += thermal_neighbour(iNeighbourSum, pNode->flags.can_travel_n, -width, pNode, iPrevTemp);
        iNeighbourCount += thermal_neighbour(iNeighbourSum, pNode->flags.can_travel_s,  width, pNode, iPrevTemp);
        iNeighbourCount += thermal_neighbour(iNeighbourSum, pNode->flags.can_travel_e,  1, pNode, iPrevTemp);
        iNeighbourCount += thermal_neighbour(iNeighbourSum, pNode->flags.can_travel_w, -1, pNode, iPrevTemp);

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
        if(pNode->flags.hospital) {
            for(auto thob : pNode->objects) {
                if(thob == object_type::radiator) {
                    iRadiatorNumber++;
                }
            }
            if(iRadiatorNumber > 0) {
                iMergeTemp = iRadiatorTemperature;
                iMergeRatio = 2 - (iRadiatorNumber - 1) * 0.5;
            } else {
                iMergeRatio = 1000;
            }
        } else {
            iMergeTemp = iAirTemperature;
        }

        // Diffuse 25% with neighbours
        pNode->aiTemperature[iNewTemp] = pNode->aiTemperature[iPrevTemp];
        if(iNeighbourCount != 0) {
            MERGE(iNeighbourSum / iNeighbourCount, 4 - (iRadiatorNumber > 0 ? (iRadiatorNumber - 1) * 1.5 : 0));
        }

        MERGE(iMergeTemp, iMergeRatio);
#undef MERGE
#undef MERGE2
    }
}

void level_map::update_pathfinding()
{
    map_tile *pNode = cells;
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
static inline bool is_wall(map_tile *tile, size_t block, bool flag)
{
    return flag || (82 <= (tile->iBlock[block] & 0xFF) && (tile->iBlock[block] & 0xFF) <= 164);
}

void level_map::update_shadows()
{   
    map_tile *pNode = cells;
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
                    map_tile *pNeighbour = pNode - 128;
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

void level_map::persist(lua_persist_writer *pWriter) const
{
    lua_State *L = pWriter->get_stack();
    integer_run_length_encoder oEncoder;

    uint32_t iVersion = 4;
    pWriter->write_uint(iVersion);
    pWriter->write_uint(player_count);
    for(int i = 0; i < player_count; ++i)
    {
        pWriter->write_uint(initial_camera_x[i]);
        pWriter->write_uint(initial_camera_y[i]);
        pWriter->write_uint(heliport_x[i]);
        pWriter->write_uint(heliport_y[i]);
    }
    pWriter->write_uint(parcel_count);
    for(int i = 0; i < parcel_count; ++i)
    {
        pWriter->write_uint(plot_owner[i]);
    }
    for(int i = 0; i < parcel_count; ++i)
    {
        pWriter->write_uint(parcel_tile_counts[i]);
    }
    pWriter->write_uint(width);
    pWriter->write_uint(height);
    pWriter->write_uint(current_temperature_index);
    oEncoder.initialise(6);
    for(map_tile *pNode = cells, *pLimitNode = cells + width * height;
        pNode != pLimitNode; ++pNode)
    {
        oEncoder.write(pNode->iBlock[0]);
        oEncoder.write(pNode->iBlock[1]);
        oEncoder.write(pNode->iBlock[2]);
        oEncoder.write(pNode->iBlock[3]);
        oEncoder.write(pNode->iParcelId);
        oEncoder.write(pNode->iRoomId);
        // Flags include THOB values, and other things which do not work
        // well with run-length encoding.
        pWriter->write_uint(static_cast<uint32_t>(pNode->flags));
        pWriter->write_uint(pNode->aiTemperature[0]);
        pWriter->write_uint(pNode->aiTemperature[1]);

        lua_rawgeti(L, luaT_upvalueindex(1), 2);
        lua_pushlightuserdata(L, pNode->next);
        lua_rawget(L, -2);
        pWriter->write_stack_object(-1);
        lua_pop(L, 1);
        lua_pushlightuserdata(L, pNode->oEarlyEntities.next);
        lua_rawget(L, -2);
        pWriter->write_stack_object(-1);
        lua_pop(L, 2);
    }
    oEncoder.finish();
    oEncoder.pump_output(pWriter);

    oEncoder.initialise(5);
    for(map_tile *pNode = original_cells, *pLimitNode = original_cells + width * height;
        pNode != pLimitNode; ++pNode)
    {
        oEncoder.write(pNode->iBlock[0]);
        oEncoder.write(pNode->iBlock[1]);
        oEncoder.write(pNode->iBlock[2]);
        oEncoder.write(pNode->iParcelId);
        oEncoder.write(static_cast<uint32_t>(pNode->flags));
    }
    oEncoder.finish();
    oEncoder.pump_output(pWriter);
}

void level_map::depersist(lua_persist_reader *pReader)
{
    new (this) level_map; // Call constructor

    lua_State *L = pReader->get_stack();
    int iWidth, iHeight;
    integer_run_length_decoder oDecoder;

    uint32_t iVersion;
    if(!pReader->read_uint(iVersion)) return;
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
    if(!pReader->read_uint(player_count)) return;
    for(int i = 0; i < player_count; ++i)
    {
        if(!pReader->read_uint(initial_camera_x[i])) return;
        if(!pReader->read_uint(initial_camera_y[i])) return;
        if(!pReader->read_uint(heliport_x[i])) return;
        if(!pReader->read_uint(heliport_y[i])) return;
    }
    if(!pReader->read_uint(parcel_count)) return;
    delete[] plot_owner;
    plot_owner = new int[parcel_count];
    for(int i = 0; i < parcel_count; ++i)
    {
        if(!pReader->read_uint(plot_owner[i])) return;
    }
    delete[] parcel_tile_counts;
    parcel_tile_counts = new int[parcel_count];
    parcel_tile_counts[0] = 0;

    if(iVersion >= 3)
    {
        for(int i = 0; i < parcel_count; ++i)
        {
            if(!pReader->read_uint(parcel_tile_counts[i])) return;
        }
    }

    if(!pReader->read_uint(iWidth) || !pReader->read_uint(iHeight))
        return;
    if(!set_size(iWidth, iHeight))
    {
        pReader->set_error("Unable to set size while depersisting map");
        return;
    }
    if(iVersion >= 4)
    {
        if(!pReader->read_uint(current_temperature_index))
            return;
    }
    for(map_tile *pNode = cells, *pLimitNode = cells + width * height;
        pNode != pLimitNode; ++pNode)
    {
        uint32_t f;
        if(!pReader->read_uint(f)) return;
        pNode->flags = f;
        if(iVersion >= 4)
        {
            if(!pReader->read_uint(pNode->aiTemperature[0])
            || !pReader->read_uint(pNode->aiTemperature[1])) return;
        }
        if(!pReader->read_stack_object())
            return;
        pNode->next = (link_list*)lua_touserdata(L, -1);
        if(pNode->next)
        {
            if(pNode->next->prev != nullptr)
                std::fprintf(stderr, "Warning: THMap linked-lists are corrupted.\n");
            pNode->next->prev = pNode;
        }
        lua_pop(L, 1);
        if(!pReader->read_stack_object())
            return;
        pNode->oEarlyEntities.next = (link_list*)lua_touserdata(L, -1);
        if(pNode->oEarlyEntities.next)
        {
            if(pNode->oEarlyEntities.next->prev != nullptr)
                std::fprintf(stderr, "Warning: THMap linked-lists are corrupted.\n");
            pNode->oEarlyEntities.next->prev = &pNode->oEarlyEntities;
        }
        lua_pop(L, 1);
    }
    oDecoder.initialise(6, pReader);
    for(map_tile *pNode = cells, *pLimitNode = cells + width * height;
        pNode != pLimitNode; ++pNode)
    {
        pNode->iBlock[0] = static_cast<uint16_t>(oDecoder.read());
        pNode->iBlock[1] = static_cast<uint16_t>(oDecoder.read());
        pNode->iBlock[2] = static_cast<uint16_t>(oDecoder.read());
        pNode->iBlock[3] = static_cast<uint16_t>(oDecoder.read());
        pNode->iParcelId = static_cast<uint16_t>(oDecoder.read());
        pNode->iRoomId   = static_cast<uint16_t>(oDecoder.read());
    }
    oDecoder.initialise(5, pReader);
    for(map_tile *pNode = original_cells, *pLimitNode = original_cells + width * height;
        pNode != pLimitNode; ++pNode)
    {
        pNode->iBlock[0] = static_cast<uint16_t>(oDecoder.read());
        pNode->iBlock[1] = static_cast<uint16_t>(oDecoder.read());
        pNode->iBlock[2] = static_cast<uint16_t>(oDecoder.read());
        pNode->iParcelId = static_cast<uint16_t>(oDecoder.read());
        pNode->flags = oDecoder.read();
    }

    if(iVersion < 3)
    {
        for(int i = 1; i < parcel_count; ++i)
            parcel_tile_counts[i] = get_parcel_tile_count(i);
    }
}

map_tile_iterator::map_tile_iterator()
    : tile(nullptr)
    , container(nullptr)
    , screen_offset_x(0)
    , screen_offset_y(0)
    , screen_width(0)
    , screen_height(0)
{
}

map_tile_iterator::map_tile_iterator(const level_map* pMap, int iScreenX, int iScreenY,
                                     int iWidth, int iHeight,
                                     map_scanline_iterator_direction eScanlineDirection)
    : container(pMap)
    , screen_offset_x(iScreenX)
    , screen_offset_y(iScreenY)
    , screen_width(iWidth)
    , screen_height(iHeight)
    , scanline_count(0)
    , direction(eScanlineDirection)
{
    if(direction == map_scanline_iterator_direction::forward)
    {
        base_x = 0;
        base_y = (iScreenY - 32) / 16;
        if(base_y < 0)
            base_y = 0;
        else if(base_y >= container->get_height())
        {
            base_x = base_y - container->get_height() + 1;
            base_y = container->get_height() - 1;
            if(base_x >= container->get_width())
                base_x = container->get_width() - 1;
        }
    }
    else
    {
        base_x = container->get_width() - 1;
        base_y = container->get_height() - 1;
    }
    world_x = base_x;
    world_y = base_y;
    advance_until_visible();
}

map_tile_iterator& map_tile_iterator::operator ++ ()
{
    --world_y;
    ++world_x;
    advance_until_visible();
    return *this;
}

void map_tile_iterator::advance_until_visible()
{
    tile = nullptr;

    while(true)
    {
        x_relative_to_screen = world_x;
        y_relative_to_screen = world_y;
        container->world_to_screen(x_relative_to_screen, y_relative_to_screen);
        x_relative_to_screen -= screen_offset_x;
        y_relative_to_screen -= screen_offset_y;
        if(direction == map_scanline_iterator_direction::forward ?
            y_relative_to_screen >= screen_height + margin_bottom :
            y_relative_to_screen < -margin_top)
        {
                return;
        }
        if(direction == map_scanline_iterator_direction::forward ?
            (y_relative_to_screen > -margin_top) :
            (y_relative_to_screen < screen_height + margin_bottom))
        {
            while(world_y >= 0 && world_x < container->get_width())
            {
                if(x_relative_to_screen < -margin_left)
                {
                    // Nothing to do
                }
                else if(x_relative_to_screen < screen_width + margin_right)
                {
                    ++scanline_count;
                    tile = container->get_tile_unchecked(world_x, world_y);
                    return;
                }
                else
                    break;
                --world_y;
                ++world_x;
                x_relative_to_screen += 64;
            }
        }
        scanline_count = 0;
        if(direction == map_scanline_iterator_direction::forward)
        {
            if(base_y == container->get_height() - 1)
            {
                if(++base_x == container->get_width())
                    break;
            }
            else
                ++base_y;
        }
        else
        {
            if(base_x == 0)
            {
                if(base_y == 0)
                    break;
                else
                    --base_y;
            }
            else
                --base_x;
        }
        world_x = base_x;
        world_y = base_y;
    }
}

bool map_tile_iterator::is_last_on_scanline() const
{
    return world_y <= 0 || world_x + 1 >= container->get_width() ||
        x_relative_to_screen + 64 >= screen_width + margin_right;
}

map_scanline_iterator::map_scanline_iterator()
    : tile_step(0)
    , x_step(0)
    , steps_taken(0)
{
}

map_scanline_iterator::map_scanline_iterator(const map_tile_iterator& itrNodes,
                                             map_scanline_iterator_direction eDirection,
                                             int iXOffset, int iYOffset)
    : tile_step((static_cast<int>(eDirection) - 1) * (1 - itrNodes.container->get_width()))
    , x_step((static_cast<int>(eDirection) - 1) * 64)
    , steps_taken(0)
{
    if(eDirection == map_scanline_iterator_direction::backward)
    {
        tile = itrNodes.tile;
        x_relative_to_screen = itrNodes.tile_x_position_on_screen();
    }
    else
    {
        tile = itrNodes.tile - tile_step * (itrNodes.scanline_count - 1);
        x_relative_to_screen = itrNodes.tile_x_position_on_screen() - x_step * (itrNodes.scanline_count - 1);
    }

    x_relative_to_screen += iXOffset;
    y_relative_to_screen = itrNodes.tile_y_position_on_screen() + iYOffset;

    end_tile = tile + tile_step * itrNodes.scanline_count;
    first_tile = tile;

}

map_scanline_iterator& map_scanline_iterator::operator ++ ()
{
    tile += tile_step;
    x_relative_to_screen += x_step;
    steps_taken++;
    return *this;
}

//copies the members of the given THMapScanlineIterator and resets the tile member to the
//first element.
map_scanline_iterator map_scanline_iterator::operator= (const map_scanline_iterator &iterator)
 {
     tile = iterator.first_tile;
     end_tile = iterator.end_tile;
     x_relative_to_screen = iterator.x_relative_to_screen - iterator.steps_taken * iterator.x_step;
     y_relative_to_screen = iterator.y_relative_to_screen;
     x_step = iterator.x_step;
     tile_step = iterator.tile_step;
     return *this;
 }
