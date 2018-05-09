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
#include "th_gfx.h"
#include "persist_lua.h"
#include "th_map.h"
#include "th_sound.h"
#include <new>
#include <algorithm>
#include <cstring>
#include <climits>
#include <cassert>

/** Data retrieval class, simulating sequential access to the data, keeping track of available length. */
class memory_reader
{
public:
    memory_reader(const uint8_t *pData, size_t iLength)
    {
        data = pData;
        remaining_bytes = iLength;
    }

    const uint8_t *data; ///< Pointer to the remaining data.
    size_t remaining_bytes;       ///< Remaining number of bytes.

    //! Can \a iSize bytes be read from the file?
    /*!
        @param iSize Number of bytes that are queried.
        @return Whether the requested number of bytes is still available.
     */
    bool are_bytes_available(size_t iSize)
    {
        return iSize <= remaining_bytes;
    }

    //! Is EOF reached?
    /*!
        @return Whether EOF has been reached.
     */
    bool is_at_end_of_file()
    {
        return remaining_bytes == 0;
    }

    //! Get an 8 bit value from the file.
    /*!
        @return Read 8 bit value.
        @pre There should be at least a byte available for reading.
     */
    uint8_t read_uint8()
    {
        assert(remaining_bytes > 0);

        uint8_t iVal = *data;
        data++;
        remaining_bytes--;
        return iVal;
    }

    //! Get a 16 bit value from the file.
    /*!
        @return Read 16 bit value.
        @pre There should be at least 2 bytes available for reading.
     */
    uint16_t read_uint16()
    {
        uint16_t iVal = read_uint8();
        uint16_t iVal2 = read_uint8();
        return static_cast<uint16_t>(iVal | (iVal2 << 8));
    }

    //! Get a signed 16 bit value from the file.
    /*!
        @return The read signed 16 bit value.
        @pre There should be at least 2 bytes available for reading.
     */
    int read_int16()
    {
        int val = read_uint16();
        if (val < 0x7FFF)
            return val;

        int ret = -1;
        return (ret & ~0xFFFF) | val;
    }

    //! Get a 32 bit value from the file.
    /*!
        @return Read 32 bit value.
        @pre There should be at least 4 bytes available for reading.
     */
    uint32_t read_uint32()
    {
        uint32_t iVal = read_uint16();
        uint32_t iVal2 = read_uint16();
        return iVal | (iVal2 << 16);
    }

    //! Load string from the memory_reader.
    /*!
        @param [out] pStr String to load.
        @return Whether the string could be loaded.
     */
    bool read_string(std::string *pStr)
    {
        char buff[256];

        if (is_at_end_of_file())
            return false;

        size_t iLength = read_uint8();
        if (!are_bytes_available(iLength))
            return false;

        size_t idx;
        for (idx = 0; idx < iLength; idx++)
            buff[idx] = read_uint8();
        buff[idx] = '\0';
        *pStr = std::string(buff);
        return true;
    }
};

animation_manager::animation_manager()
{
    first_frames.clear();
    frames.clear();
    element_list.clear();
    elements.clear();
    custom_sheets.clear();

    sheet = nullptr;

    animation_count = 0;
    frame_count = 0;
    element_list_count = 0;
    element_count = 0;
}

animation_manager::~animation_manager()
{
    for (size_t i = 0; i < custom_sheets.size(); i++)
        delete custom_sheets[i];
}

void animation_manager::set_sprite_sheet(sprite_sheet* pSpriteSheet)
{
    sheet = pSpriteSheet;
}

bool animation_manager::load_from_th_file(
                        const uint8_t* pStartData, size_t iStartDataLength,
                        const uint8_t* pFrameData, size_t iFrameDataLength,
                        const uint8_t* pListData, size_t iListDataLength,
                        const uint8_t* pElementData, size_t iElementDataLength)
{
    size_t iAnimationCount = iStartDataLength / sizeof(th_animation_properties);
    size_t iFrameCount     = iFrameDataLength / sizeof(th_frame_properties);
    size_t iListCount      = iListDataLength / 2;
    size_t iElementCount   = iElementDataLength / sizeof(th_element_properties);

    if(iAnimationCount == 0 || iFrameCount == 0 || iListCount == 0 || iElementCount == 0)
        return false;

    // Start offset of the file data into the vectors.
    size_t iAnimationStart = animation_count;
    size_t iFrameStart     = frame_count;
    size_t iListStart      = element_list_count;
    size_t iElementStart   = element_count;

    // Original data file must start at offset 0 due to the hard-coded animation numbers in the Lua code.
    if (iAnimationStart > 0 || iFrameStart > 0 || iListStart > 0 || iElementStart > 0)
        return false;

    if (iElementStart + iElementCount >= 0xFFFF) // Overflow of list elements.
        return false;

    // Create new space for the data.
    first_frames.reserve(iAnimationStart + iAnimationCount);
    frames.reserve(iFrameStart + iFrameCount);
    element_list.reserve(iListStart + iListCount + 1);
    elements.reserve(iElementStart + iElementCount);

    // Read animations.
    for(size_t i = 0; i < iAnimationCount; ++i)
    {
        size_t iFirstFrame = reinterpret_cast<const th_animation_properties*>(pStartData)[i].first_frame;
        if(iFirstFrame > iFrameCount)
            iFirstFrame = 0;

        iFirstFrame += iFrameStart;
        first_frames.push_back(iFirstFrame);
    }

    // Read frames.
    for(size_t i = 0; i < iFrameCount; ++i)
    {
        const th_frame_properties* pFrame = reinterpret_cast<const th_frame_properties*>(pFrameData) + i;

        frame oFrame;
        oFrame.list_index = iListStart + (pFrame->list_index < iListCount ? pFrame->list_index : 0);
        oFrame.next_frame = iFrameStart + (pFrame->next < iFrameCount ? pFrame->next : 0);
        oFrame.sound = pFrame->sound;
        oFrame.flags = pFrame->flags;
        // Bounding box fields initialised later
        oFrame.marker_x = 0;
        oFrame.marker_y = 0;
        oFrame.secondary_marker_x = 0;
        oFrame.secondary_marker_y = 0;

        frames.push_back(oFrame);
    }

    // Read element list.
    for(size_t i = 0; i < iListCount; ++i)
    {
        uint16_t iElmNumber = *(reinterpret_cast<const uint16_t*>(pListData) + i);
        if (iElmNumber >= iElementCount)
        {
            iElmNumber = 0xFFFF;
        }
        else
        {
            iElmNumber = static_cast<uint16_t>(iElmNumber + iElementStart);
        }

        element_list.push_back(iElmNumber);
    }
    element_list.push_back(0xFFFF);

    // Read elements.
    size_t iSpriteCount = sheet->get_sprite_count();
    for(size_t i = 0; i < iElementCount; ++i)
    {
        const th_element_properties* pTHElement = reinterpret_cast<const th_element_properties*>(pElementData) + i;

        element oElement;
        oElement.sprite = pTHElement->table_position / 6;
        oElement.flags = pTHElement->flags & 0xF;
        oElement.x = static_cast<int>(pTHElement->offx) - 141;
        oElement.y = static_cast<int>(pTHElement->offy) - 186;
        oElement.layer = static_cast<uint8_t>(pTHElement->flags >> 4); // High nibble, layer of the element.
        if(oElement.layer > 12)
            oElement.layer = 6; // Nothing lives on layer 6
        oElement.layer_id = pTHElement->layerid;
        if (oElement.sprite < iSpriteCount) {
            oElement.element_sprite_sheet = sheet;
        } else {
            oElement.element_sprite_sheet = nullptr;
        }

        elements.push_back(oElement);
    }

    // Compute bounding box of the animations using the sprite sheet.
    for(size_t i = 0; i < iFrameCount; ++i)
    {
        set_bounding_box(frames[iFrameStart + i]);
    }

    animation_count += iAnimationCount;
    frame_count += iFrameCount;
    element_list_count += iListCount + 1;
    element_count += iElementCount;

    assert(first_frames.size() == animation_count);
    assert(frames.size() == frame_count);
    assert(element_list.size() == element_list_count);
    assert(elements.size() == element_count);

    return true;
}

//! Update \a iLeft with the smallest of both values.
/*!
    @param [inout] iLeft Left value to check and update.
    @param iRight Second value to check.
 */
static void set_left_to_min(int& iLeft, int iRight)
{
    if(iRight < iLeft)
        iLeft = iRight;
}

//! Update \a iLeft with the biggest of both values.
/*!
    @param [inout] iLeft Left value to check and update.
    @param iRight Second value to check.
 */
static void set_left_to_max(int& iLeft, int iRight)
{
    if(iRight > iLeft)
        iLeft = iRight;
}

void animation_manager::set_bounding_box(frame &oFrame)
{
    oFrame.bounding_left   = INT_MAX;
    oFrame.bounding_right  = INT_MIN;
    oFrame.bounding_top    = INT_MAX;
    oFrame.bounding_bottom = INT_MIN;
    size_t iListIndex = oFrame.list_index;
    for(; ; ++iListIndex)
    {
        uint16_t iElement = element_list[iListIndex];
        if(iElement >= elements.size())
            break;

        element& oElement = elements[iElement];
        if(oElement.element_sprite_sheet == nullptr)
            continue;

        unsigned int iWidth, iHeight;
        oElement.element_sprite_sheet->get_sprite_size_unchecked(oElement.sprite, &iWidth, &iHeight);
        set_left_to_min(oFrame.bounding_left  , oElement.x);
        set_left_to_min(oFrame.bounding_top   , oElement.y);
        set_left_to_max(oFrame.bounding_right , oElement.x - 1 + (int)iWidth);
        set_left_to_max(oFrame.bounding_bottom, oElement.y - 1 + (int)iHeight);
    }
}

void animation_manager::set_canvas(render_target *pCanvas)
{
    canvas = pCanvas;
}

//! Load the header.
/*!
    @param [inout] input Data to read.
    @return Number of consumed bytes, a negative number indicates an error.
 */
static int load_header(memory_reader &input)
{
    static const uint8_t aHdr[] = {'C', 'T', 'H', 'G', 1, 2};

    if (!input.are_bytes_available(6))
        return false;
    for (int i = 0; i < 6; i++)
    {
        if (input.read_uint8() != aHdr[i])
            return false;
    }
    return true;
}

size_t animation_manager::load_elements(memory_reader &input, sprite_sheet *pSpriteSheet,
                                        size_t iNumElements, size_t &iLoadedElements,
                                        size_t iElementStart, size_t iElementCount)
{
    size_t iFirst = iLoadedElements + iElementStart;

    size_t iSpriteCount = pSpriteSheet->get_sprite_count();
    while (iNumElements > 0)
    {
        if (iLoadedElements >= iElementCount || !input.are_bytes_available(12))
            return SIZE_MAX;

        size_t iSprite = input.read_uint32();
        int iX = input.read_int16();
        int iY = input.read_int16();
        uint8_t iLayerClass = input.read_uint8();
        uint8_t iLayerId = input.read_uint8();
        uint32_t iFlags = input.read_uint16();

        if (iLayerClass > 12)
            iLayerClass = 6; // Nothing lives on layer 6

        element oElement;
        oElement.sprite = iSprite;
        oElement.flags = iFlags;
        oElement.x = iX;
        oElement.y = iY;
        oElement.layer = iLayerClass;
        oElement.layer_id = iLayerId;
        if (oElement.sprite >= iSpriteCount)
            oElement.element_sprite_sheet = nullptr;
        else
            oElement.element_sprite_sheet = pSpriteSheet;

        elements.push_back(oElement);
        iLoadedElements++;
        iNumElements--;
    }
    return iFirst;
}

size_t animation_manager::make_list_elements(size_t iFirstElement, size_t iNumElements,
                                             size_t &iLoadedListElements,
                                             size_t iListStart, size_t iListCount)
{
    size_t iFirst = iLoadedListElements + iListStart;

    // Verify there is enough room for all list elements + 0xFFFF
    if (iLoadedListElements + iNumElements + 1 > iListCount)
        return SIZE_MAX;
    assert(iFirstElement + iNumElements < 0xFFFF); // Overflow for list elements.

    while (iNumElements > 0)
    {
        element_list.push_back(static_cast<uint16_t>(iFirstElement));
        iLoadedListElements++;
        iFirstElement++;
        iNumElements--;
    }
    // Add 0xFFFF.
    element_list.push_back(0xFFFF);
    iLoadedListElements++;

    return iFirst;
}

//! Shift the first frame if all frames are available.
/*!
    @param iFirst First frame number, or 0xFFFFFFFFu if no animation.
    @param iLength Number of frames in the animation.
    @param iStart Start of the frames for this file.
    @param iLoaded Number of loaded frames.
    @return The shifted first frame, or 0xFFFFFFFFu.
 */
static uint32_t shift_first(uint32_t iFirst, size_t iLength,
                            size_t iStart, size_t iLoaded)
{
    if (iFirst == 0xFFFFFFFFu || iFirst + iLength > iLoaded)
        return 0xFFFFFFFFu;
    return iFirst + static_cast<uint32_t>(iStart);
}

void animation_manager::fix_next_frame(uint32_t iFirst, size_t iLength)
{
    if (iFirst == 0xFFFFFFFFu)
        return;

    frame &oFirst = frames[iFirst];
    oFirst.flags |= 0x1; // Start of animation flag.

    frame &oLast = frames[iFirst + iLength - 1];
    oLast.next_frame = iFirst; // Loop last frame back to the first.
}

bool animation_manager::load_custom_animations(const uint8_t* pData, size_t iDataLength)
{
    memory_reader input(pData, iDataLength);

    if (!load_header(input))
        return false;

    if (!input.are_bytes_available(5*4))
        return false;

    size_t iAnimationCount = input.read_uint32();
    size_t iFrameCount = input.read_uint32();
    size_t iElementCount = input.read_uint32();
    size_t iSpriteCount = input.read_uint32();
    input.read_uint32(); // Total number of bytes sprite data is not used.

    // Every element is referenced once, and one 0xFFFF for every frame.
    size_t iListCount = iElementCount + iFrameCount;

    size_t iFrameStart = frame_count;
    size_t iListStart = element_list_count;
    size_t iElementStart = element_count;

    if (iAnimationCount == 0 || iFrameCount == 0 || iElementCount == 0 || iSpriteCount == 0)
        return false;

    if (iElementStart + iElementCount >= 0xFFFF) // Overflow of list elements.
        return false;

    // Create new space for the elements.
    first_frames.reserve(first_frames.size() + iAnimationCount * 4); // Be optimistic in reservation.
    frames.reserve(iFrameStart + iFrameCount);
    element_list.reserve(iListStart + iListCount);
    elements.reserve(iElementStart + iElementCount);

    // Construct a sprite sheet for the sprites to be loaded.
    sprite_sheet *pSheet = new sprite_sheet;
    pSheet->set_sprite_count(iSpriteCount, canvas);
    custom_sheets.push_back(pSheet);

    size_t iLoadedFrames = 0;
    size_t iLoadedListElements = 0;
    size_t iLoadedElements = 0;
    size_t iLoadedSprites = 0;

    // Read the blocks of the file, until hitting EOF.
    for (;;)
    {
        if (input.is_at_end_of_file())
            break;

        // Read identification bytes at the start of each block, and dispatch loading.
        if (!input.are_bytes_available(2))
            return false;
        int first = input.read_uint8();
        int second = input.read_uint8();

        // Recognized a grouped animation block, load it.
        if (first == 'C' && second == 'A')
        {
            animation_key oKey;

            if (!input.are_bytes_available(2+4))
                return false;
            oKey.tile_size = input.read_uint16();
            size_t iNumFrames = input.read_uint32();
            if (iNumFrames == 0)
                return false;

            if (!input.read_string(&oKey.name))
                return false;

            if (!input.are_bytes_available(4*4))
                return false;
            uint32_t iNorthFirst = input.read_uint32();
            uint32_t iEastFirst  = input.read_uint32();
            uint32_t iSouthFirst = input.read_uint32();
            uint32_t iWestFirst  = input.read_uint32();

            iNorthFirst = shift_first(iNorthFirst, iNumFrames, iFrameStart, iLoadedFrames);
            iEastFirst  = shift_first(iEastFirst,  iNumFrames, iFrameStart, iLoadedFrames);
            iSouthFirst = shift_first(iSouthFirst, iNumFrames, iFrameStart, iLoadedFrames);
            iWestFirst  = shift_first(iWestFirst,  iNumFrames, iFrameStart, iLoadedFrames);

            animation_start_frames oFrames;
            oFrames.north = -1;
            oFrames.east  = -1;
            oFrames.south = -1;
            oFrames.west  = -1;

            if (iNorthFirst != 0xFFFFFFFFu)
            {
                fix_next_frame(iNorthFirst, iNumFrames);
                oFrames.north = static_cast<long>(first_frames.size());
                first_frames.push_back(iNorthFirst);
            }
            if (iEastFirst != 0xFFFFFFFFu)
            {
                fix_next_frame(iEastFirst, iNumFrames);
                oFrames.east = static_cast<long>(first_frames.size());
                first_frames.push_back(iEastFirst);
            }
            if (iSouthFirst != 0xFFFFFFFFu)
            {
                fix_next_frame(iSouthFirst, iNumFrames);
                oFrames.south = static_cast<long>(first_frames.size());
                first_frames.push_back(iSouthFirst);
            }
            if (iWestFirst != 0xFFFFFFFFu)
            {
                fix_next_frame(iWestFirst, iNumFrames);
                oFrames.west = static_cast<long>(first_frames.size());
                first_frames.push_back(iWestFirst);
            }

            named_animation_pair p(oKey, oFrames);
            named_animations.insert(p);
            continue;
        }

        // Recognized a frame block, load it.
        else if (first == 'F' && second == 'R')
        {
            if (iLoadedFrames >= iFrameCount)
                return false;

            if (!input.are_bytes_available(2+2))
                return false;
            int iSound = input.read_uint16();
            size_t iNumElements = input.read_uint16();

            size_t iElm = load_elements(input, pSheet, iNumElements,
                                    iLoadedElements, iElementStart, iElementCount);
            if (iElm == SIZE_MAX)
                return false;

            size_t iListElm = make_list_elements(iElm, iNumElements,
                                            iLoadedListElements, iListStart, iListCount);
            if (iListElm == SIZE_MAX)
                return false;

            frame oFrame;
            oFrame.list_index = iListElm;
            oFrame.next_frame = iFrameStart + iLoadedFrames + 1; // Point to next frame (changed later).
            oFrame.sound = iSound;
            oFrame.flags = 0; // Set later.
            oFrame.marker_x = 0;
            oFrame.marker_y = 0;
            oFrame.secondary_marker_x = 0;
            oFrame.secondary_marker_y = 0;

            set_bounding_box(oFrame);

            frames.push_back(oFrame);
            iLoadedFrames++;
            continue;
        }

        // Recognized a Sprite block, load it.
        else if (first == 'S' && second == 'P')
        {
            if (iLoadedSprites >= iSpriteCount)
                return false;

            if (!input.are_bytes_available(2+2+4))
                return false;
            int iWidth = input.read_uint16();
            int iHeight = input.read_uint16();
            uint32_t iSize = input.read_uint32();
            if (iSize > INT_MAX) // Check it is safe to use as 'int'
                return false;

            // Load data.
            uint8_t *pData = new (std::nothrow) uint8_t[iSize];
            if (pData == nullptr) {
                return false;
            }
            if (!input.are_bytes_available(iSize)) {
                delete[] pData;
                return false;
            }
            for (uint32_t i = 0; i < iSize; i++)
                pData[i] = input.read_uint8();

            if (!pSheet->set_sprite_data(iLoadedSprites, pData, true, iSize,
                                       iWidth, iHeight))
                return false;

            iLoadedSprites++;
            continue;
        }

        // Unrecognized block, fail.
        else
        {
            return false;
        }
    }

    assert(iLoadedFrames == iFrameCount);
    assert(iLoadedListElements == iListCount);
    assert(iLoadedElements == iElementCount);
    assert(iLoadedSprites == iSpriteCount);

    // Fix the next pointer of the last frame in case it points to non-existing frames.
    frame &oFrame = frames[iFrameStart + iFrameCount - 1];
    if (iFrameCount > 0 && oFrame.next_frame >= iFrameStart + iFrameCount)
        oFrame.next_frame = iFrameStart; // Useless, but maybe less crashy.

    animation_count = first_frames.size();
    frame_count += iFrameCount;
    element_list_count += iListCount;
    element_count += iElementCount;
    assert(frames.size() == frame_count);
    assert(element_list.size() == element_list_count);
    assert(elements.size() == element_count);

    return true;
}

const animation_start_frames &animation_manager::get_named_animations(const std::string &sName, int iTilesize) const
{
    static const animation_start_frames oNoneAnimations = {-1, -1, -1, -1};

    animation_key oKey;
    oKey.name = sName;
    oKey.tile_size = iTilesize;

    named_animations_map::const_iterator iter = named_animations.find(oKey);
    if (iter == named_animations.end())
        return oNoneAnimations;
    return (*iter).second;
}

size_t animation_manager::get_animation_count() const
{
    return animation_count;
}

size_t animation_manager::get_frame_count() const
{
    return frame_count;
}

size_t animation_manager::get_first_frame(size_t iAnimation) const
{
    if(iAnimation < animation_count)
        return first_frames[iAnimation];
    else
        return 0;
}

size_t animation_manager::get_next_frame(size_t iFrame) const
{
    if(iFrame < frame_count)
        return frames[iFrame].next_frame;
    else
        return iFrame;
}

void animation_manager::set_animation_alt_palette_map(size_t iAnimation, const uint8_t* pMap, uint32_t iAlt32)
{
    if(iAnimation >= animation_count)
        return;

    size_t iFrame = first_frames[iAnimation];
    size_t iFirstFrame = iFrame;
    do
    {
        size_t iListIndex = frames[iFrame].list_index;
        for(; ; ++iListIndex)
        {
            uint16_t iElement = element_list[iListIndex];
            if(iElement >= element_count)
                break;

            element& oElement = elements[iElement];
            if (oElement.element_sprite_sheet != nullptr)
                oElement.element_sprite_sheet->set_sprite_alt_palette_map(oElement.sprite, pMap, iAlt32);
        }
        iFrame = frames[iFrame].next_frame;
    } while(iFrame != iFirstFrame);
}

bool animation_manager::set_frame_marker(size_t iFrame, int iX, int iY)
{
    if(iFrame >= frame_count)
        return false;
    frames[iFrame].marker_x = iX;
    frames[iFrame].marker_y = iY;
    return true;
}

bool animation_manager::set_frame_secondary_marker(size_t iFrame, int iX, int iY)
{
    if(iFrame >= frame_count)
        return false;
    frames[iFrame].secondary_marker_x = iX;
    frames[iFrame].secondary_marker_y = iY;
    return true;
}

bool animation_manager::get_frame_marker(size_t iFrame, int* pX, int* pY)
{
    if(iFrame >= frame_count)
        return false;
    *pX = frames[iFrame].marker_x;
    *pY = frames[iFrame].marker_y;
    return true;
}

bool animation_manager::get_frame_secondary_marker(size_t iFrame, int* pX, int* pY)
{
    if(iFrame >= frame_count)
        return false;
    *pX = frames[iFrame].secondary_marker_x;
    *pY = frames[iFrame].secondary_marker_y;
    return true;
}

bool animation_manager::hit_test(size_t iFrame, const ::layers& oLayers,
                                 int iX, int iY, uint32_t iFlags,
                                 int iTestX, int iTestY) const
{
    if(iFrame >= frame_count)
        return false;

    const frame& oFrame = frames[iFrame];
    iTestX -= iX;
    iTestY -= iY;

    if(iFlags & thdf_flip_horizontal)
        iTestX = -iTestX;
    if(iTestX < oFrame.bounding_left || iTestX > oFrame.bounding_right)
        return false;

    if(iFlags & thdf_flip_vertical)
    {
        if(-iTestY < oFrame.bounding_top || -iTestY > oFrame.bounding_bottom)
            return false;
    }
    else
    {
        if(iTestY < oFrame.bounding_top || iTestY > oFrame.bounding_bottom)
            return false;
    }

    if(iFlags & thdf_bound_box_hit_test)
        return true;

    size_t iListIndex = oFrame.list_index;
    for(; ; ++iListIndex)
    {
        uint16_t iElement = element_list[iListIndex];
        if(iElement >= element_count)
            break;

        const element &oElement = elements[iElement];
        if((oElement.layer_id != 0 && oLayers.layer_contents[oElement.layer] != oElement.layer_id)
         || oElement.element_sprite_sheet == nullptr)
        {
            continue;
        }

        if(iFlags & thdf_flip_horizontal)
        {
            unsigned int iWidth, iHeight;
            oElement.element_sprite_sheet->get_sprite_size_unchecked(oElement.sprite, &iWidth, &iHeight);
            if(oElement.element_sprite_sheet->hit_test_sprite(oElement.sprite, oElement.x + iWidth - iTestX,
                iTestY - oElement.y, oElement.flags ^ thdf_flip_horizontal))
            {
                return true;
            }
        }
        else
        {
            if(oElement.element_sprite_sheet->hit_test_sprite(oElement.sprite, iTestX - oElement.x,
                iTestY - oElement.y, oElement.flags))
            {
                return true;
            }
        }
    }

    return false;
}

void animation_manager::draw_frame(render_target* pCanvas, size_t iFrame,
                                   const ::layers& oLayers,
                                   int iX, int iY, uint32_t iFlags) const
{
    if(iFrame >= frame_count)
        return;

    uint32_t iPassOnFlags = iFlags & thdf_alt_palette;

    size_t iListIndex = frames[iFrame].list_index;
    for(; ; ++iListIndex)
    {
        uint16_t iElement = element_list[iListIndex];
        if(iElement >= element_count)
            break;

        const element &oElement = elements[iElement];
        if (oElement.element_sprite_sheet == nullptr)
            continue;

        if(oElement.layer_id != 0 && oLayers.layer_contents[oElement.layer] != oElement.layer_id)
        {
            // Some animations involving doctors (i.e. #72, #74, maybe others)
            // only provide versions for heads W1 and B1, not W2 and B2. The
            // quickest way to fix this is this dirty hack here, which draws
            // the W1 layer as well as W2 if W2 is being used, and similarly
            // for B1 / B2. A better fix would be to go into each animation
            // which needs it, and duplicate the W1 / B1 layers to W2 / B2.
            if(oElement.layer == 5 && oLayers.layer_contents[5] - 4 == oElement.layer_id)
                /* don't skip */;
            else
                continue;
        }

        if(iFlags & thdf_flip_horizontal)
        {
            unsigned int iWidth, iHeight;
            oElement.element_sprite_sheet->get_sprite_size_unchecked(oElement.sprite, &iWidth, &iHeight);

            oElement.element_sprite_sheet->draw_sprite(pCanvas, oElement.sprite, iX - oElement.x - iWidth,
                iY + oElement.y, iPassOnFlags | (oElement.flags ^ thdf_flip_horizontal));
        }
        else
        {
            oElement.element_sprite_sheet->draw_sprite(pCanvas, oElement.sprite,
                iX + oElement.x, iY + oElement.y, iPassOnFlags | oElement.flags);
        }
    }
}

size_t animation_manager::get_frame_sound(size_t iFrame)
{
    if(iFrame < frame_count)
        return frames[iFrame].sound;
    else
        return 0;
}

void animation_manager::get_frame_extent(size_t iFrame, const ::layers& oLayers,
                                         int* pMinX, int* pMaxX,
                                         int* pMinY, int* pMaxY,
                                         uint32_t iFlags) const
{
    int iMinX = INT_MAX;
    int iMaxX = INT_MIN;
    int iMinY = INT_MAX;
    int iMaxY = INT_MIN;
    if(iFrame < frame_count)
    {
        size_t iListIndex = frames[iFrame].list_index;

        for(; ; ++iListIndex)
        {
            uint16_t iElement = element_list[iListIndex];
            if(iElement >= element_count)
                break;

            const element &oElement = elements[iElement];
            if((oElement.layer_id != 0 && oLayers.layer_contents[oElement.layer] != oElement.layer_id)
                || oElement.element_sprite_sheet == nullptr)
            {
                continue;
            }

            int iX = oElement.x;
            int iY = oElement.y;
            unsigned int iWidth_, iHeight_;
            oElement.element_sprite_sheet->get_sprite_size_unchecked(oElement.sprite, &iWidth_, &iHeight_);
            int iWidth = static_cast<int>(iWidth_);
            int iHeight = static_cast<int>(iHeight_);
            if(iFlags & thdf_flip_horizontal)
                iX = -(iX + iWidth);
            if(iX < iMinX)
                iMinX = iX;
            if(iY < iMinY)
                iMinY = iY;
            if(iX + iWidth + 1 > iMaxX)
                iMaxX = iX + iWidth + 1;
            if(iY + iHeight + 1 > iMaxY)
                iMaxY = iY + iHeight + 1;
        }
    }
    if(pMinX)
        *pMinX = iMinX;
    if(pMaxX)
        *pMaxX = iMaxX;
    if(pMinY)
        *pMinY = iMinY;
    if(pMaxY)
        *pMaxY = iMaxY;
}

chunk_renderer::chunk_renderer(int width, int height, uint8_t *buffer)
{
    data = buffer ? buffer : new uint8_t[width * height];
    ptr = data;
    end = data + width * height;
    x = 0;
    y = 0;
    this->width = width;
    this->height = height;
    skip_eol = false;
}

chunk_renderer::~chunk_renderer()
{
    delete[] data;
}

uint8_t* chunk_renderer::take_data()
{
    uint8_t *buffer = data;
    data = 0;
    return buffer;
}

void chunk_renderer::chunk_fill_to_end_of_line(uint8_t value)
{
    if(x != 0 || !skip_eol)
    {
        chunk_fill(width - x, value);
    }
    skip_eol = false;
}

void chunk_renderer::chunk_finish(uint8_t value)
{
    chunk_fill(static_cast<int>(end - ptr), value);
}

void chunk_renderer::chunk_fill(int npixels, uint8_t value)
{
    fix_n_pixels(npixels);
    if(npixels > 0)
    {
        std::memset(ptr, value, npixels);
        increment_position(npixels);
    }
}

void chunk_renderer::chunk_copy(int npixels, const uint8_t* in_data)
{
    fix_n_pixels(npixels);
    if(npixels > 0)
    {
        std::memcpy(ptr, in_data, npixels);
        increment_position(npixels);
    }
}


void chunk_renderer::fix_n_pixels(int& npixels) const
{
    if(ptr + npixels > end)
    {
        npixels = static_cast<int>(end - ptr);
    }
}

void chunk_renderer::increment_position(int npixels)
{
    ptr += npixels;
    x += npixels;
    y += x / width;
    x = x % width;
    skip_eol = true;
}

void chunk_renderer::decode_chunks(const uint8_t* data, int datalen, bool complex)
{
    if(complex)
    {
        while(!is_done() && datalen > 0)
        {
            uint8_t b = *data;
            --datalen;
            ++data;
            if(b == 0)
            {
                chunk_fill_to_end_of_line(0xFF);
            }
            else if(b < 0x40)
            {
                int amt = b;
                if(datalen < amt)
                    amt = datalen;
                chunk_copy(amt, data);
                data += amt;
                datalen -= amt;
            }
            else if((b & 0xC0) == 0x80)
            {
                chunk_fill(b - 0x80, 0xFF);
            }
            else
            {
                int amt;
                uint8_t colour = 0;
                if(b == 0xFF)
                {
                    if(datalen < 2)
                    {
                        break;
                    }
                    amt = (int)data[0];
                    colour = data[1];
                    data += 2;
                    datalen -= 2;
                }
                else
                {
                    amt = b - 60 - (b & 0x80) / 2;
                    if(datalen > 0)
                    {
                        colour = *data;
                        ++data;
                        --datalen;
                    }
                }
                chunk_fill(amt, colour);
            }
        }
    }
    else
    {
        while(!is_done() && datalen > 0)
        {
            uint8_t b = *data;
            --datalen;
            ++data;
            if(b == 0)
            {
                chunk_fill_to_end_of_line(0xFF);
            }
            else if(b < 0x80)
            {
                int amt = b;
                if(datalen < amt)
                    amt = datalen;
                chunk_copy(amt, data);
                data += amt;
                datalen -= amt;
            }
            else
            {
                chunk_fill(0x100 - b, 0xFF);
            }
        }
    }
    chunk_finish(0xFF);
}

#define ARE_FLAGS_SET(val, flags) (((val) & (flags)) == (flags))

void animation::draw(render_target* pCanvas, int iDestX, int iDestY)
{
    if(ARE_FLAGS_SET(flags, thdf_alpha_50 | thdf_alpha_75))
        return;

    iDestX += x_relative_to_tile;
    iDestY += y_relative_to_tile;
    if(sound_to_play)
    {
        sound_player *pSounds = sound_player::get_singleton();
        if(pSounds)
            pSounds->play_at(sound_to_play, iDestX, iDestY);
        sound_to_play = 0;
    }
    if(manager)
    {
        if(flags & thdf_crop)
        {
            clip_rect rcOld, rcNew;
            pCanvas->get_clip_rect(&rcOld);
            rcNew.y = rcOld.y;
            rcNew.h = rcOld.h;
            rcNew.x = iDestX + (crop_column - 1) * 32;
            rcNew.w = 64;
            clip_rect_intersection(rcNew, rcOld);
            pCanvas->set_clip_rect(&rcNew);
            manager->draw_frame(pCanvas, frame_index, layers, iDestX, iDestY,
                                  flags);
            pCanvas->set_clip_rect(&rcOld);
        }
        else
            manager->draw_frame(pCanvas, frame_index, layers, iDestX, iDestY,
                                  flags);
    }
}

void animation::draw_child(render_target* pCanvas, int iDestX, int iDestY)
{
    if(ARE_FLAGS_SET(flags, thdf_alpha_50 | thdf_alpha_75))
        return;
    if(ARE_FLAGS_SET(parent->flags, thdf_alpha_50 | thdf_alpha_75))
        return;
    int iX = 0, iY = 0;
    parent->get_marker(&iX, &iY);
    iX += x_relative_to_tile + iDestX;
    iY += y_relative_to_tile + iDestY;
    if(sound_to_play)
    {
        sound_player *pSounds = sound_player::get_singleton();
        if(pSounds)
            pSounds->play_at(sound_to_play, iX, iY);
        sound_to_play = 0;
    }
    if(manager)
        manager->draw_frame(pCanvas, frame_index, layers, iX, iY, flags);
}

bool animation::hit_test_child(int iDestX, int iDestY, int iTestX, int iTestY)
{
    // TODO
    return false;
}

static void CalculateMorphRect(const clip_rect& rcOriginal, clip_rect& rcMorph, int iYLow, int iYHigh)
{
    rcMorph = rcOriginal;
    if(rcMorph.y < iYLow)
    {
        rcMorph.h += rcMorph.y - iYLow;
        rcMorph.y = iYLow;
    }
    if(rcMorph.y + rcMorph.h >= iYHigh)
    {
         rcMorph.h = iYHigh - rcMorph.y - 1;
    }
}

void animation::draw_morph(render_target* pCanvas, int iDestX, int iDestY)
{
    if(ARE_FLAGS_SET(flags, thdf_alpha_50 | thdf_alpha_75))
        return;

    if(!manager)
        return;

    iDestX += x_relative_to_tile;
    iDestY += y_relative_to_tile;
    if(sound_to_play)
    {
        sound_player *pSounds = sound_player::get_singleton();
        if(pSounds)
            pSounds->play_at(sound_to_play, iDestX, iDestY);
        sound_to_play = 0;
    }

    clip_rect oClipRect;
    pCanvas->get_clip_rect(&oClipRect);
    clip_rect oMorphRect;
    CalculateMorphRect(oClipRect, oMorphRect, iDestY + morph_target->x_relative_to_tile,
                       iDestY + morph_target->y_relative_to_tile + 1);
    pCanvas->set_clip_rect(&oMorphRect);
    manager->draw_frame(pCanvas, frame_index, layers, iDestX, iDestY,
                          flags);
    CalculateMorphRect(oClipRect, oMorphRect, iDestY + morph_target->y_relative_to_tile,
                       iDestY + morph_target->speed.dx);
    pCanvas->set_clip_rect(&oMorphRect);
    manager->draw_frame(pCanvas, morph_target->frame_index,
                          morph_target->layers, iDestX,
                          iDestY, morph_target->flags);
    pCanvas->set_clip_rect(&oClipRect);
}


bool animation::hit_test(int iDestX, int iDestY, int iTestX, int iTestY)
{
    if(ARE_FLAGS_SET(flags, thdf_alpha_50 | thdf_alpha_75))
        return false;
    if(manager == nullptr)
        return false;
    return manager->hit_test(frame_index, layers, x_relative_to_tile + iDestX,
        y_relative_to_tile + iDestY, flags, iTestX, iTestY);
}

bool animation::hit_test_morph(int iDestX, int iDestY, int iTestX, int iTestY)
{
    if(ARE_FLAGS_SET(flags, thdf_alpha_50 | thdf_alpha_75))
        return false;
    if(manager == nullptr)
        return false;
    return manager->hit_test(frame_index, layers, x_relative_to_tile + iDestX,
        y_relative_to_tile + iDestY, flags, iTestX, iTestY) || morph_target->hit_test(
        iDestX, iDestY, iTestX, iTestY);
}

#undef ARE_FLAGS_SET

static bool THAnimation_hit_test_child(drawable* pSelf, int iDestX, int iDestY, int iTestX, int iTestY)
{
    return reinterpret_cast<animation*>(pSelf)->hit_test_child(iDestX, iDestY, iTestX, iTestY);
}

static void THAnimation_draw_child(drawable* pSelf, render_target* pCanvas, int iDestX, int iDestY)
{
    reinterpret_cast<animation*>(pSelf)->draw_child(pCanvas, iDestX, iDestY);
}

static bool THAnimation_hit_test_morph(drawable* pSelf, int iDestX, int iDestY, int iTestX, int iTestY)
{
    return reinterpret_cast<animation*>(pSelf)->hit_test_morph(iDestX, iDestY, iTestX, iTestY);
}

static void THAnimation_draw_morph(drawable* pSelf, render_target* pCanvas, int iDestX, int iDestY)
{
    reinterpret_cast<animation*>(pSelf)->draw_morph(pCanvas, iDestX, iDestY);
}

static bool THAnimation_hit_test(drawable* pSelf, int iDestX, int iDestY, int iTestX, int iTestY)
{
    return reinterpret_cast<animation*>(pSelf)->hit_test(iDestX, iDestY, iTestX, iTestY);
}

static void THAnimation_draw(drawable* pSelf, render_target* pCanvas, int iDestX, int iDestY)
{
    reinterpret_cast<animation*>(pSelf)->draw(pCanvas, iDestX, iDestY);
}

static bool THAnimation_is_multiple_frame_animation(drawable* pSelf)
{
    animation *pAnimation = reinterpret_cast<animation *>(pSelf);
    if(pAnimation)
    {
        size_t firstFrame = pAnimation->get_animation_manager()->get_first_frame(pAnimation->get_animation());
        size_t nextFrame = pAnimation->get_animation_manager()->get_next_frame(firstFrame);
        return nextFrame != firstFrame;
    }
    else
        return false;

}

animation_base::animation_base()
{
    x_relative_to_tile = 0;
    y_relative_to_tile = 0;
    for(int i = 0; i < 13; ++i)
        layers.layer_contents[i] = 0;
    flags = 0;
}

animation::animation():
    manager(nullptr),
    morph_target(nullptr),
    animation_index(0),
    frame_index(0),
    speed({0,0}),
    sound_to_play(0),
    crop_column(0)
{
    draw_fn = THAnimation_draw;
    hit_test_fn = THAnimation_hit_test;
    is_multiple_frame_animation_fn = THAnimation_is_multiple_frame_animation;
}

void animation::persist(lua_persist_writer *pWriter) const
{
    lua_State *L = pWriter->get_stack();

    // Write the next chained thing
    lua_rawgeti(L, luaT_environindex, 2);
    lua_pushlightuserdata(L, next);
    lua_rawget(L, -2);
    pWriter->fast_write_stack_object(-1);
    lua_pop(L, 2);

    // Write the drawable fields
    pWriter->write_uint(flags);
#define IS_USING_FUNCTION_SET(d, ht) draw_fn == (THAnimation_ ## d) \
                            && hit_test_fn == (THAnimation_ ## ht)

    if(IS_USING_FUNCTION_SET(draw, hit_test))
        pWriter->write_uint(1);
    else if(IS_USING_FUNCTION_SET(draw_child, hit_test_child))
        pWriter->write_uint(2);
    else if(IS_USING_FUNCTION_SET(draw_morph, hit_test_morph))
    {
        // NB: Prior version of code used the number 3 here, and forgot
        // to persist the morph target.
        pWriter->write_uint(4);
        lua_rawgeti(L, luaT_environindex, 2);
        lua_pushlightuserdata(L, morph_target);
        lua_rawget(L, -2);
        pWriter->write_stack_object(-1);
        lua_pop(L, 2);
    }
    else
        pWriter->write_uint(0);

#undef IS_USING_FUNCTION_SET

    // Write the simple fields
    pWriter->write_uint(animation_index);
    pWriter->write_uint(frame_index);
    pWriter->write_int(x_relative_to_tile);
    pWriter->write_int(y_relative_to_tile);
    pWriter->write_int((int)sound_to_play); // Not a uint, for compatibility
    pWriter->write_int(0); // For compatibility
    if(flags & thdf_crop)
        pWriter->write_int(crop_column);

    // Write the unioned fields
    if(draw_fn != THAnimation_draw_child)
    {
        pWriter->write_int(speed.dx);
        pWriter->write_int(speed.dy);
    }
    else
    {
        lua_rawgeti(L, luaT_environindex, 2);
        lua_pushlightuserdata(L, parent);
        lua_rawget(L, -2);
        pWriter->write_stack_object(-1);
        lua_pop(L, 2);
    }

    // Write the layers
    int iNumLayers = 13;
    for( ; iNumLayers >= 1; --iNumLayers)
    {
        if(layers.layer_contents[iNumLayers - 1] != 0)
            break;
    }
    pWriter->write_uint(iNumLayers);
    pWriter->write_byte_stream(layers.layer_contents, iNumLayers);
}

void animation::depersist(lua_persist_reader *pReader)
{
    lua_State *L = pReader->get_stack();

    do
    {
        // Read the chain
        if(!pReader->read_stack_object())
            break;
        next = reinterpret_cast<link_list*>(lua_touserdata(L, -1));
        if(next)
            next->prev = this;
        lua_pop(L, 1);

        // Read drawable fields
        if(!pReader->read_uint(flags))
            break;
        int iFunctionSet;
        if(!pReader->read_uint(iFunctionSet))
            break;
        switch(iFunctionSet)
        {
        case 3:
            // 3 should be the morph set, but the actual morph target is
            // missing, so settle for a graphical bug rather than a segfault
            // by reverting to the normal function set.
        case 1:
            draw_fn = THAnimation_draw;
            hit_test_fn = THAnimation_hit_test;
            break;
        case 2:
            draw_fn = THAnimation_draw_child;
            hit_test_fn = THAnimation_hit_test_child;
            break;
        case 4:
            draw_fn = THAnimation_draw_morph;
            hit_test_fn = THAnimation_hit_test_morph;
            pReader->read_stack_object();
            morph_target = reinterpret_cast<animation*>(lua_touserdata(L, -1));
            lua_pop(L, 1);
            break;
        default:
            pReader->set_error(lua_pushfstring(L, "Unknown animation function set #%i", iFunctionSet));
            return;
        }

        // Read the simple fields
        if(!pReader->read_uint(animation_index))
            break;
        if(!pReader->read_uint(frame_index))
            break;
        if(!pReader->read_int(x_relative_to_tile))
            break;
        if(!pReader->read_int(y_relative_to_tile))
            break;
        int iDummy;
        if(!pReader->read_int(iDummy))
            break;
        if(iDummy >= 0)
            sound_to_play = (unsigned int)iDummy;
        if(!pReader->read_int(iDummy))
            break;
        if(flags & thdf_crop)
        {
            if(!pReader->read_int(crop_column))
                break;
        }
        else
            crop_column = 0;

        // Read the unioned fields
        if(draw_fn != THAnimation_draw_child)
        {
            if(!pReader->read_int(speed.dx))
                break;
            if(!pReader->read_int(speed.dy))
                break;
        }
        else
        {
            if(!pReader->read_stack_object())
                break;
            parent = (animation*)lua_touserdata(L, -1);
            lua_pop(L, 1);
        }

        // Read the layers
        std::memset(layers.layer_contents, 0, sizeof(layers.layer_contents));
        int iNumLayers;
        if(!pReader->read_uint(iNumLayers))
            break;
        if(iNumLayers > 13)
        {
            if(!pReader->read_byte_stream(layers.layer_contents, 13))
                break;
            if(!pReader->read_byte_stream(nullptr, iNumLayers - 13))
                break;
        }
        else
        {
            if(!pReader->read_byte_stream(layers.layer_contents, iNumLayers))
                break;
        }

        // Fix the m_pAnimator field
        luaT_getenvfield(L, 2, "animator");
        manager = (animation_manager*)lua_touserdata(L, -1);
        lua_pop(L, 1);

        return;
    } while(false);

    pReader->set_error("Cannot depersist animation instance");
}

void animation::tick()
{
    frame_index = manager->get_next_frame(frame_index);
    if(draw_fn != THAnimation_draw_child)
    {
        x_relative_to_tile += speed.dx;
        y_relative_to_tile += speed.dy;
    }
    if(morph_target)
    {
        morph_target->y_relative_to_tile += morph_target->speed.dy;
        if(morph_target->y_relative_to_tile < morph_target->x_relative_to_tile)
            morph_target->y_relative_to_tile = morph_target->x_relative_to_tile;
    }

    //Female flying to heaven sound fix:
    if(frame_index == 6987)
        sound_to_play = 123;
    else
        sound_to_play = manager->get_frame_sound(frame_index);
}

void animation_base::remove_from_tile()
{
    link_list::remove_from_list();
}

void animation_base::attach_to_tile(map_tile *pMapNode, int layer)
{
    remove_from_tile();
    link_list *pList;
    if(flags & thdf_early_list)
        pList = &pMapNode->oEarlyEntities;
    else
        pList = pMapNode;

    this->set_drawing_layer(layer);

#define GetFlags(x) (reinterpret_cast<drawable*>(x)->m_iFlags)
    while(pList->next && pList->next->get_drawing_layer() < layer)
    {
        pList = pList->next;
    }
#undef GetFlags

    prev = pList;
    if(pList->next != nullptr)
    {
        pList->next->prev = this;
        this->next = pList->next;
    }
    else
    {
        next = nullptr;
    }
    pList->next = this;
}

void animation::set_parent(animation *pParent)
{
    remove_from_tile();
    if(pParent == nullptr)
    {
        draw_fn = THAnimation_draw;
        hit_test_fn = THAnimation_hit_test;
        speed = { 0, 0 };
    }
    else
    {
        draw_fn = THAnimation_draw_child;
        hit_test_fn = THAnimation_hit_test_child;
        parent = pParent;
        next = parent->next;
        if(next)
            next->prev = this;
        prev = parent;
        parent->next = this;
    }
}

void animation::set_animation(animation_manager* pManager, size_t iAnimation)
{
    manager = pManager;
    animation_index = iAnimation;
    frame_index = pManager->get_first_frame(iAnimation);
    if(morph_target)
    {
        morph_target = nullptr;
        draw_fn = THAnimation_draw;
        hit_test_fn = THAnimation_hit_test;
    }
}

bool animation::get_marker(int* pX, int* pY)
{
    if(!manager || !manager->get_frame_marker(frame_index, pX, pY))
        return false;
    if(flags & thdf_flip_horizontal)
        *pX = -*pX;
    *pX += x_relative_to_tile;
    *pY += y_relative_to_tile + 16;
    return true;
}

bool animation::get_secondary_marker(int* pX, int* pY)
{
    if(!manager || !manager->get_frame_secondary_marker(frame_index, pX, pY))
        return false;
    if(flags & thdf_flip_horizontal)
        *pX = -*pX;
    *pX += x_relative_to_tile;
    *pY += y_relative_to_tile + 16;
    return true;
}

static int GetAnimationDurationAndExtent(animation_manager *pManager,
                                         size_t iFrame,
                                         const ::layers& oLayers,
                                         int* pMinY, int* pMaxY,
                                         uint32_t iFlags)
{
    int iMinY = INT_MAX;
    int iMaxY = INT_MIN;
    int iDuration = 0;
    size_t iCurFrame = iFrame;
    do
    {
        int iFrameMinY;
        int iFrameMaxY;
        pManager->get_frame_extent(iCurFrame, oLayers, nullptr, nullptr, &iFrameMinY, &iFrameMaxY, iFlags);
        if(iFrameMinY < iMinY)
            iMinY = iFrameMinY;
        if(iFrameMaxY > iMaxY)
            iMaxY = iFrameMaxY;
        iCurFrame = pManager->get_next_frame(iCurFrame);
        ++iDuration;
    } while(iCurFrame != iFrame);
    if(pMinY)
        *pMinY = iMinY;
    if(pMaxY)
        *pMaxY = iMaxY;
    return iDuration;
}

void animation::set_morph_target(animation *pMorphTarget, unsigned int iDurationFactor)
{
    morph_target = pMorphTarget;
    draw_fn = THAnimation_draw_morph;
    hit_test_fn = THAnimation_hit_test_morph;

    /* Morphing is the process by which two animations are combined to give a
    single animation of one animation turning into another. At the moment,
    morphing is done by having a y value, above which the original animation is
    rendered, and below which the new animation is rendered, and having the y
    value move upward a bit each frame.
    One example of where this is used is when transparent or invisible patients
    are cured at the pharmacy cabinet.
    The process of morphing requires four state variables, which are stored in
    the morph target animation:
      * The y value top limit - morph_target->x
      * The y value threshold - morph_target->y
      * The y value bottom limit - morph_target->speed.dx
      * The y value increment per frame - morph_target->speed.dy
    This obviously means that the morph target should not be ticked or rendered
    as it's position and speed contain other values.
    */

    int iOrigMinY, iOrigMaxY;
    int iMorphMinY, iMorphMaxY;

#define GADEA GetAnimationDurationAndExtent
    int iOriginalDuration = GADEA(manager, frame_index, layers, &iOrigMinY,
                                  &iOrigMaxY, flags);
    int iMorphDuration = GADEA(morph_target->manager,
                               morph_target->frame_index,
                               morph_target->layers, &iMorphMinY,
                               &iMorphMaxY, morph_target->flags);
    if(iMorphDuration > iOriginalDuration)
        iMorphDuration = iOriginalDuration;
#undef GADEA

    iMorphDuration *= iDurationFactor;
    if(iOrigMinY < iMorphMinY)
        morph_target->x_relative_to_tile = iOrigMinY;
    else
        morph_target->x_relative_to_tile = iMorphMinY;

    if(iOrigMaxY > iMorphMaxY)
        morph_target->speed.dx = iOrigMaxY;
    else
        morph_target->speed.dx = iMorphMaxY;

    int iDist = morph_target->x_relative_to_tile - morph_target->speed.dx;
    morph_target->speed.dy = (iDist - iMorphDuration + 1) / iMorphDuration;
    morph_target->y_relative_to_tile = morph_target->speed.dx;
}

void animation::set_frame(size_t iFrame)
{
    frame_index = iFrame;
}

void animation_base::set_layer(int iLayer, int iId)
{
    if(0 <= iLayer && iLayer <= 12)
    {
        layers.layer_contents[iLayer] = static_cast<uint8_t>(iId);
    }
}

static bool THSpriteRenderList_hit_test(drawable* pSelf, int iDestX,
                                       int iDestY, int iTestX, int iTestY)
{
    return reinterpret_cast<sprite_render_list*>(pSelf)->
        hit_test(iDestX, iDestY, iTestX, iTestY);
}

static void THSpriteRenderList_draw(drawable* pSelf, render_target* pCanvas,
                                    int iDestX, int iDestY)
{
    reinterpret_cast<sprite_render_list*>(pSelf)->
        draw(pCanvas, iDestX, iDestY);
}

static bool THSpriteRenderList_is_multiple_frame_animation(drawable* pSelf)
{
    return false;
}
sprite_render_list::sprite_render_list()
{
    draw_fn = THSpriteRenderList_draw;
    hit_test_fn = THSpriteRenderList_hit_test;
    is_multiple_frame_animation_fn = THSpriteRenderList_is_multiple_frame_animation;
    buffer_size = 0;
    sprite_count = 0;
    sheet = nullptr;
    sprites = nullptr;
    dx_per_tick = 0;
    dy_per_tick = 0;
    lifetime = -1;
}

sprite_render_list::~sprite_render_list()
{
    delete[] sprites;
}

void sprite_render_list::tick()
{
    x_relative_to_tile += dx_per_tick;
    y_relative_to_tile += dy_per_tick;
    if(lifetime > 0)
        --lifetime;
}

void sprite_render_list::draw(render_target* pCanvas, int iDestX, int iDestY)
{
    if(!sheet)
        return;

    iDestX += x_relative_to_tile;
    iDestY += y_relative_to_tile;
    for(sprite *pSprite = sprites, *pLast = sprites + sprite_count;
        pSprite != pLast; ++pSprite)
    {
        sheet->draw_sprite(pCanvas, pSprite->index,
            iDestX + pSprite->x, iDestY + pSprite->y, flags);
    }
}

bool sprite_render_list::hit_test(int iDestX, int iDestY, int iTestX, int iTestY)
{
    // TODO
    return false;
}

void sprite_render_list::set_lifetime(int iLifetime)
{
    if(iLifetime < 0)
        iLifetime = -1;
    lifetime = iLifetime;
}

void sprite_render_list::append_sprite(size_t iSprite, int iX, int iY)
{
    if(buffer_size == sprite_count)
    {
        int iNewSize = buffer_size * 2;
        if(iNewSize == 0)
            iNewSize = 4;
        sprite* pNewSprites = new sprite[iNewSize];
#ifdef _MSC_VER
#pragma warning(disable: 4996)
#endif
        std::copy(sprites, sprites + sprite_count, pNewSprites);
#ifdef _MSC_VER
#pragma warning(default: 4996)
#endif
        delete[] sprites;
        sprites = pNewSprites;
        buffer_size = iNewSize;
    }
    sprites[sprite_count].index = iSprite;
    sprites[sprite_count].x = iX;
    sprites[sprite_count].y = iY;
    ++sprite_count;
}

void sprite_render_list::persist(lua_persist_writer *pWriter) const
{
    lua_State *L = pWriter->get_stack();

    pWriter->write_uint(sprite_count);
    pWriter->write_uint(flags);
    pWriter->write_int(x_relative_to_tile);
    pWriter->write_int(y_relative_to_tile);
    pWriter->write_int(dx_per_tick);
    pWriter->write_int(dy_per_tick);
    pWriter->write_int(lifetime);
    for(sprite *pSprite = sprites, *pLast = sprites + sprite_count;
        pSprite != pLast; ++pSprite)
    {
        pWriter->write_uint(pSprite->index);
        pWriter->write_int(pSprite->x);
        pWriter->write_int(pSprite->y);
    }

    // Write the layers
    int iNumLayers = 13;
    for( ; iNumLayers >= 1; --iNumLayers)
    {
        if(layers.layer_contents[iNumLayers - 1] != 0)
            break;
    }
    pWriter->write_uint(iNumLayers);
    pWriter->write_byte_stream(layers.layer_contents, iNumLayers);

    // Write the next chained thing
    lua_rawgeti(L, luaT_environindex, 2);
    lua_pushlightuserdata(L, next);
    lua_rawget(L, -2);
    pWriter->fast_write_stack_object(-1);
    lua_pop(L, 2);
}

void sprite_render_list::depersist(lua_persist_reader *pReader)
{
    lua_State *L = pReader->get_stack();

    if(!pReader->read_uint(sprite_count))
        return;
    buffer_size = sprite_count;
    delete[] sprites;
    sprites = new sprite[buffer_size];

    if(!pReader->read_uint(flags))
        return;
    if(!pReader->read_int(x_relative_to_tile))
        return;
    if(!pReader->read_int(y_relative_to_tile))
        return;
    if(!pReader->read_int(dx_per_tick))
        return;
    if(!pReader->read_int(dy_per_tick))
        return;
    if(!pReader->read_int(lifetime))
        return;
    for(sprite *pSprite = sprites, *pLast = sprites + sprite_count;
        pSprite != pLast; ++pSprite)
    {
        if(!pReader->read_uint(pSprite->index))
            return;
        if(!pReader->read_int(pSprite->x))
            return;
        if(!pReader->read_int(pSprite->y))
            return;
    }

    // Read the layers
    std::memset(layers.layer_contents, 0, sizeof(layers.layer_contents));
    int iNumLayers;
    if(!pReader->read_uint(iNumLayers))
        return;
    if(iNumLayers > 13)
    {
        if(!pReader->read_byte_stream(layers.layer_contents, 13))
            return;
        if(!pReader->read_byte_stream(nullptr, iNumLayers - 13))
            return;
    }
    else
    {
        if(!pReader->read_byte_stream(layers.layer_contents, iNumLayers))
            return;
    }

    // Read the chain
    if(!pReader->read_stack_object())
        return;
    next = reinterpret_cast<link_list*>(lua_touserdata(L, -1));
    if(next)
        next->prev = this;
    lua_pop(L, 1);

    // Fix the sheet field
    luaT_getenvfield(L, 2, "sheet");
    sheet = (sprite_sheet*)lua_touserdata(L, -1);
    lua_pop(L, 1);
}
