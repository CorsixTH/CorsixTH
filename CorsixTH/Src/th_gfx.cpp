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
#include <memory.h>
#include <limits.h>
#include <cassert>
#include <cstdint>

/** Data retrieval class, simulating sequential access to the data, keeping track of available length. */
class Input
{
public:
    Input(const uint8_t *pData, size_t iLength)
    {
        m_pData = pData;
        m_iLength = iLength;
    }

    const uint8_t *m_pData; ///< Pointer to the remaining data.
    size_t m_iLength;       ///< Remaining number of bytes.

    //! Can \a iSize bytes be read from the file?
    /*!
        @param iSize Number of bytes that are queried.
        @return Whether the requested number of bytes is still available.
     */
    inline bool Available(size_t iSize)
    {
        return iSize <= m_iLength;
    }

    //! Is EOF reached?
    /*!
        @return Whether EOF has been reached.
     */
    inline bool AtEOF()
    {
        return m_iLength == 0;
    }

    //! Get an 8 bit value from the file.
    /*!
        @return Read 8 bit value.
        @pre There should be at least a byte available for reading.
     */
    inline uint8_t Uint8()
    {
        assert(m_iLength > 0);

        uint8_t iVal = *m_pData;
        m_pData++;
        m_iLength--;
        return iVal;
    }

    //! Get a 16 bit value from the file.
    /*!
        @return Read 16 bit value.
        @pre There should be at least 2 bytes available for reading.
     */
    inline uint16_t Uint16()
    {
        uint16_t iVal = Uint8();
        uint16_t iVal2 = Uint8();
        return static_cast<uint16_t>(iVal | (iVal2 << 8));
    }

    //! Get a signed 16 bit value from the file.
    /*!
        @return The read signed 16 bit value.
        @pre There should be at least 2 bytes available for reading.
     */
    inline int Int16()
    {
        int val = Uint16();
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
    inline uint32_t Uint32()
    {
        uint32_t iVal = Uint16();
        uint32_t iVal2 = Uint16();
        return iVal | (iVal2 << 16);
    }

    //! Load string from the input.
    /*!
        @param [out] pStr String to load.
        @return Whether the string could be loaded.
     */
    inline bool String(std::string *pStr)
    {
        char buff[256];

        if (AtEOF())
            return false;

        size_t iLength = Uint8();
        if (!Available(iLength))
            return false;

        size_t idx;
        for (idx = 0; idx < iLength; idx++)
            buff[idx] = Uint8();
        buff[idx] = '\0';
        *pStr = std::string(buff);
        return true;
    }
};

THAnimationManager::THAnimationManager()
{
    m_vFirstFrames.clear();
    m_vFrames.clear();
    m_vElementList.clear();
    m_vElements.clear();
    m_vCustomSheets.clear();

    m_pSpriteSheet = NULL;

    m_iAnimationCount = 0;
    m_iFrameCount = 0;
    m_iElementListCount = 0;
    m_iElementCount = 0;
}

THAnimationManager::~THAnimationManager()
{
    for (size_t i = 0; i < m_vCustomSheets.size(); i++)
        delete m_vCustomSheets[i];
}

void THAnimationManager::setSpriteSheet(THSpriteSheet* pSpriteSheet)
{
    m_pSpriteSheet = pSpriteSheet;
}

bool THAnimationManager::loadFromTHFile(
                        const uint8_t* pStartData, size_t iStartDataLength,
                        const uint8_t* pFrameData, size_t iFrameDataLength,
                        const uint8_t* pListData, size_t iListDataLength,
                        const uint8_t* pElementData, size_t iElementDataLength)
{
    size_t iAnimationCount = iStartDataLength / sizeof(th_anim_t);
    size_t iFrameCount     = iFrameDataLength / sizeof(th_frame_t);
    size_t iListCount      = iListDataLength / 2;
    size_t iElementCount   = iElementDataLength / sizeof(th_element_t);

    if(iAnimationCount == 0 || iFrameCount == 0 || iListCount == 0 || iElementCount == 0)
        return false;

    // Start offset of the file data into the vectors.
    size_t iAnimationStart = m_iAnimationCount;
    size_t iFrameStart     = m_iFrameCount;
    size_t iListStart      = m_iElementListCount;
    size_t iElementStart   = m_iElementCount;

    // Original data file cannot must start at offset 0 due to the hard-coded animation numbers in the Lua code.
    if (iAnimationStart > 0 || iFrameStart > 0 || iListStart > 0 || iElementStart > 0)
        return false;

    if (iElementStart + iElementCount >= 0xFFFF) // Overflow of list elements.
        return false;

    // Create new space for the data.
    m_vFirstFrames.reserve(iAnimationStart + iAnimationCount);
    m_vFrames.reserve(iFrameStart + iFrameCount);
    m_vElementList.reserve(iListStart + iListCount + 1);
    m_vElements.reserve(iElementStart + iElementCount);

    // Read animations.
    for(size_t i = 0; i < iAnimationCount; ++i)
    {
        size_t iFirstFrame = reinterpret_cast<const th_anim_t*>(pStartData)[i].frame;
        if(iFirstFrame > iFrameCount)
            iFirstFrame = 0;

        iFirstFrame += iFrameStart;
        m_vFirstFrames.push_back(iFirstFrame);
    }

    // Read frames.
    for(size_t i = 0; i < iFrameCount; ++i)
    {
        const th_frame_t* pFrame = reinterpret_cast<const th_frame_t*>(pFrameData) + i;

        frame_t oFrame;
        oFrame.iListIndex = iListStart + (pFrame->list_index < iListCount ? pFrame->list_index : 0);
        oFrame.iNextFrame = iFrameStart + (pFrame->next < iFrameCount ? pFrame->next : 0);
        oFrame.iSound = pFrame->sound;
        oFrame.iFlags = pFrame->flags;
        // Bounding box fields initialised later
        oFrame.iMarkerX = 0;
        oFrame.iMarkerY = 0;
        oFrame.iSecondaryMarkerX = 0;
        oFrame.iSecondaryMarkerY = 0;

        m_vFrames.push_back(oFrame);
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

        m_vElementList.push_back(iElmNumber);
    }
    m_vElementList.push_back(0xFFFF);

    // Read elements.
    size_t iSpriteCount = m_pSpriteSheet->getSpriteCount();
    for(size_t i = 0; i < iElementCount; ++i)
    {
        const th_element_t* pTHElement = reinterpret_cast<const th_element_t*>(pElementData) + i;

        element_t oElement;
        oElement.iSprite = pTHElement->table_position / 6;
        oElement.iFlags = pTHElement->flags & 0xF;
        oElement.iX = static_cast<int>(pTHElement->offx) - 141;
        oElement.iY = static_cast<int>(pTHElement->offy) - 186;
        oElement.iLayer = static_cast<uint8_t>(pTHElement->flags >> 4); // High nibble, layer of the element.
        if(oElement.iLayer > 12)
            oElement.iLayer = 6; // Nothing lives on layer 6
        oElement.iLayerId = pTHElement->layerid;
        if (oElement.iSprite < iSpriteCount) {
            oElement.pSpriteSheet = m_pSpriteSheet;
        } else {
            oElement.pSpriteSheet = NULL;
        }

        m_vElements.push_back(oElement);
    }

    // Compute bounding box of the animations using the sprite sheet.
    for(size_t i = 0; i < iFrameCount; ++i)
    {
        setBoundingBox(m_vFrames[iFrameStart + i]);
    }

    m_iAnimationCount += iAnimationCount;
    m_iFrameCount += iFrameCount;
    m_iElementListCount += iListCount + 1;
    m_iElementCount += iElementCount;

    assert(m_vFirstFrames.size() == m_iAnimationCount);
    assert(m_vFrames.size() == m_iFrameCount);
    assert(m_vElementList.size() == m_iElementListCount);
    assert(m_vElements.size() == m_iElementCount);

    return true;
}

//! Update \a iLeft with the smallest of both values.
/*!
    @param [inout] iLeft Left value to check and update.
    @param iRight Second value to check.
 */
inline static void _setmin(int& iLeft, int iRight)
{
    if(iRight < iLeft)
        iLeft = iRight;
}

//! Update \a iLeft with the biggest of both values.
/*!
    @param [inout] iLeft Left value to check and update.
    @param iRight Second value to check.
 */
inline static void _setmax(int& iLeft, int iRight)
{
    if(iRight > iLeft)
        iLeft = iRight;
}

void THAnimationManager::setBoundingBox(frame_t &oFrame)
{
    oFrame.iBoundingLeft   = INT_MAX;
    oFrame.iBoundingRight  = INT_MIN;
    oFrame.iBoundingTop    = INT_MAX;
    oFrame.iBoundingBottom = INT_MIN;
    size_t iListIndex = oFrame.iListIndex;
    for(; ; ++iListIndex)
    {
        uint16_t iElement = m_vElementList[iListIndex];
        if(iElement >= m_vElements.size())
            break;

        element_t& oElement = m_vElements[iElement];
        if(oElement.pSpriteSheet == NULL)
            continue;

        unsigned int iWidth, iHeight;
        oElement.pSpriteSheet->getSpriteSizeUnchecked(oElement.iSprite, &iWidth, &iHeight);
        _setmin(oFrame.iBoundingLeft  , oElement.iX);
        _setmin(oFrame.iBoundingTop   , oElement.iY);
        _setmax(oFrame.iBoundingRight , oElement.iX - 1 + (int)iWidth);
        _setmax(oFrame.iBoundingBottom, oElement.iY - 1 + (int)iHeight);
    }
}

void THAnimationManager::setCanvas(THRenderTarget *pCanvas)
{
    m_pCanvas = pCanvas;
}

//! Load the header.
/*!
    @param [inout] input Data to read.
    @return Number of consumed bytes, a negative number indicates an error.
 */
static int loadHeader(Input &input)
{
    static const uint8_t aHdr[] = {'C', 'T', 'H', 'G', 1, 2};

    if (!input.Available(6))
        return false;
    for (int i = 0; i < 6; i++)
    {
        if (input.Uint8() != aHdr[i])
            return false;
    }
    return true;
}

size_t THAnimationManager::loadElements(Input &input, THSpriteSheet *pSpriteSheet,
                                        size_t iNumElements, size_t &iLoadedElements,
                                        size_t iElementStart, size_t iElementCount)
{
    size_t iFirst = iLoadedElements + iElementStart;

    size_t iSpriteCount = pSpriteSheet->getSpriteCount();
    while (iNumElements > 0)
    {
        if (iLoadedElements >= iElementCount || !input.Available(12))
            return SIZE_MAX;

        size_t iSprite = input.Uint32();
        int iX = input.Int16();
        int iY = input.Int16();
        uint8_t iLayerClass = input.Uint8();
        uint8_t iLayerId = input.Uint8();
        uint32_t iFlags = input.Uint16();

        if (iLayerClass > 12)
            iLayerClass = 6; // Nothing lives on layer 6

        element_t oElement;
        oElement.iSprite = iSprite;
        oElement.iFlags = iFlags;
        oElement.iX = iX;
        oElement.iY = iY;
        oElement.iLayer = iLayerClass;
        oElement.iLayerId = iLayerId;
        if (oElement.iSprite >= iSpriteCount)
            oElement.pSpriteSheet = NULL;
        else
            oElement.pSpriteSheet = pSpriteSheet;

        m_vElements.push_back(oElement);
        iLoadedElements++;
        iNumElements--;
    }
    return iFirst;
}

size_t THAnimationManager::makeListElements(size_t iFirstElement, size_t iNumElements,
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
        m_vElementList.push_back(static_cast<uint16_t>(iFirstElement));
        iLoadedListElements++;
        iFirstElement++;
        iNumElements--;
    }
    // Add 0xFFFF.
    m_vElementList.push_back(0xFFFF);
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
static uint32_t shiftFirst(uint32_t iFirst, size_t iLength,
                           size_t iStart, size_t iLoaded)
{
    if (iFirst == 0xFFFFFFFFu || iFirst + iLength > iLoaded)
        return 0xFFFFFFFFu;
    return iFirst + static_cast<uint32_t>(iStart);
}

void THAnimationManager::fixNextFrame(uint32_t iFirst, size_t iLength)
{
    if (iFirst == 0xFFFFFFFFu)
        return;

    frame_t &oFirst = m_vFrames[iFirst];
    oFirst.iFlags |= 0x1; // Start of animation flag.

    frame_t &oLast = m_vFrames[iFirst + iLength - 1];
    oLast.iNextFrame = iFirst; // Loop last frame back to the first.
}

bool THAnimationManager::loadCustomAnimations(const uint8_t* pData, size_t iDataLength)
{
    Input input(pData, iDataLength);

    if (!loadHeader(input))
        return false;

    if (!input.Available(5*4))
        return false;

    size_t iAnimationCount = input.Uint32();
    size_t iFrameCount = input.Uint32();
    size_t iElementCount = input.Uint32();
    size_t iSpriteCount = input.Uint32();
    input.Uint32(); // Total number of bytes sprite data is not used.

    // Every element is referenced once, and one 0xFFFF for every frame.
    size_t iListCount = iElementCount + iFrameCount;

    size_t iFrameStart = m_iFrameCount;
    size_t iListStart = m_iElementListCount;
    size_t iElementStart = m_iElementCount;

    if (iAnimationCount == 0 || iFrameCount == 0 || iElementCount == 0 || iSpriteCount == 0)
        return false;

    if (iElementStart + iElementCount >= 0xFFFF) // Overflow of list elements.
        return false;

    // Create new space for the elements.
    m_vFirstFrames.reserve(m_vFirstFrames.size() + iAnimationCount * 4); // Be optimistic in reservation.
    m_vFrames.reserve(iFrameStart + iFrameCount);
    m_vElementList.reserve(iListStart + iListCount);
    m_vElements.reserve(iElementStart + iElementCount);

    // Construct a sprite sheet for the sprites to be loaded.
    THSpriteSheet *pSheet = new THSpriteSheet;
    pSheet->setSpriteCount(iSpriteCount, m_pCanvas);
    m_vCustomSheets.push_back(pSheet);

    size_t iLoadedFrames = 0;
    size_t iLoadedListElements = 0;
    size_t iLoadedElements = 0;
    size_t iLoadedSprites = 0;

    // Read the blocks of the file, until hitting EOF.
    for (;;)
    {
        if (input.AtEOF())
            break;

        // Read identification bytes at the start of each block, and dispatch loading.
        if (!input.Available(2))
            return false;
        int first = input.Uint8();
        int second = input.Uint8();

        // Recognized a grouped animation block, load it.
        if (first == 'C' && second == 'A')
        {
            AnimationKey oKey;

            if (!input.Available(2+4))
                return false;
            oKey.iTilesize = input.Uint16();
            size_t iNumFrames = input.Uint32();
            if (iNumFrames == 0)
                return false;

            if (!input.String(&oKey.sName))
                return false;

            if (!input.Available(4*4))
                return false;
            uint32_t iNorthFirst = input.Uint32();
            uint32_t iEastFirst  = input.Uint32();
            uint32_t iSouthFirst = input.Uint32();
            uint32_t iWestFirst  = input.Uint32();

            iNorthFirst = shiftFirst(iNorthFirst, iNumFrames, iFrameStart, iLoadedFrames);
            iEastFirst  = shiftFirst(iEastFirst,  iNumFrames, iFrameStart, iLoadedFrames);
            iSouthFirst = shiftFirst(iSouthFirst, iNumFrames, iFrameStart, iLoadedFrames);
            iWestFirst  = shiftFirst(iWestFirst,  iNumFrames, iFrameStart, iLoadedFrames);

            AnimationStartFrames oFrames;
            oFrames.iNorth = -1;
            oFrames.iEast  = -1;
            oFrames.iSouth = -1;
            oFrames.iWest  = -1;

            if (iNorthFirst != 0xFFFFFFFFu)
            {
                fixNextFrame(iNorthFirst, iNumFrames);
                oFrames.iNorth = static_cast<long>(m_vFirstFrames.size());
                m_vFirstFrames.push_back(iNorthFirst);
            }
            if (iEastFirst != 0xFFFFFFFFu)
            {
                fixNextFrame(iEastFirst, iNumFrames);
                oFrames.iEast = static_cast<long>(m_vFirstFrames.size());
                m_vFirstFrames.push_back(iEastFirst);
            }
            if (iSouthFirst != 0xFFFFFFFFu)
            {
                fixNextFrame(iSouthFirst, iNumFrames);
                oFrames.iSouth = static_cast<long>(m_vFirstFrames.size());
                m_vFirstFrames.push_back(iSouthFirst);
            }
            if (iWestFirst != 0xFFFFFFFFu)
            {
                fixNextFrame(iWestFirst, iNumFrames);
                oFrames.iWest = static_cast<long>(m_vFirstFrames.size());
                m_vFirstFrames.push_back(iWestFirst);
            }

            NamedAnimationPair p(oKey, oFrames);
            m_oNamedAnimations.insert(p);
            continue;
        }

        // Recognized a frame block, load it.
        else if (first == 'F' && second == 'R')
        {
            if (iLoadedFrames >= iFrameCount)
                return false;

            if (!input.Available(2+2))
                return false;
            int iSound = input.Uint16();
            size_t iNumElements = input.Uint16();

            size_t iElm = loadElements(input, pSheet, iNumElements,
                                    iLoadedElements, iElementStart, iElementCount);
            if (iElm == SIZE_MAX)
                return false;

            size_t iListElm = makeListElements(iElm, iNumElements,
                                            iLoadedListElements, iListStart, iListCount);
            if (iListElm == SIZE_MAX)
                return false;

            frame_t oFrame;
            oFrame.iListIndex = iListElm;
            oFrame.iNextFrame = iFrameStart + iLoadedFrames + 1; // Point to next frame (changed later).
            oFrame.iSound = iSound;
            oFrame.iFlags = 0; // Set later.
            oFrame.iMarkerX = 0;
            oFrame.iMarkerY = 0;
            oFrame.iSecondaryMarkerX = 0;
            oFrame.iSecondaryMarkerY = 0;

            setBoundingBox(oFrame);

            m_vFrames.push_back(oFrame);
            iLoadedFrames++;
            continue;
        }

        // Recognized a Sprite block, load it.
        else if (first == 'S' && second == 'P')
        {
            if (iLoadedSprites >= iSpriteCount)
                return false;

            if (!input.Available(2+2+4))
                return false;
            int iWidth = input.Uint16();
            int iHeight = input.Uint16();
            uint32_t iSize = input.Uint32();
            if (iSize > INT_MAX) // Check it is safe to use as 'int'
                return false;

            // Load data.
            uint8_t *pData = new (std::nothrow) uint8_t[iSize];
            if (pData == NULL)
                return false;
            if (!input.Available(iSize))
                return false;
            for (uint32_t i = 0; i < iSize; i++)
                pData[i] = input.Uint8();

            if (!pSheet->setSpriteData(iLoadedSprites, pData, true, iSize,
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
    frame_t &oFrame = m_vFrames[iFrameStart + iFrameCount - 1];
    if (iFrameCount > 0 && oFrame.iNextFrame >= iFrameStart + iFrameCount)
        oFrame.iNextFrame = iFrameStart; // Useless, but maybe less crashy.

    m_iAnimationCount = m_vFirstFrames.size();
    m_iFrameCount += iFrameCount;
    m_iElementListCount += iListCount;
    m_iElementCount += iElementCount;
    assert(m_vFrames.size() == m_iFrameCount);
    assert(m_vElementList.size() == m_iElementListCount);
    assert(m_vElements.size() == m_iElementCount);

    return true;
}

const AnimationStartFrames &THAnimationManager::getNamedAnimations(const std::string &sName, int iTilesize) const
{
    static const AnimationStartFrames oNoneAnimations = {-1, -1, -1, -1};

    AnimationKey oKey;
    oKey.sName = sName;
    oKey.iTilesize = iTilesize;

    NamedAnimationsMap::const_iterator iter = m_oNamedAnimations.find(oKey);
    if (iter == m_oNamedAnimations.end())
        return oNoneAnimations;
    return (*iter).second;
}

size_t THAnimationManager::getAnimationCount() const
{
    return m_iAnimationCount;
}

size_t THAnimationManager::getFrameCount() const
{
    return m_iFrameCount;
}

size_t THAnimationManager::getFirstFrame(size_t iAnimation) const
{
    if(iAnimation < m_iAnimationCount)
        return m_vFirstFrames[iAnimation];
    else
        return 0;
}

size_t THAnimationManager::getNextFrame(size_t iFrame) const
{
    if(iFrame < m_iFrameCount)
        return m_vFrames[iFrame].iNextFrame;
    else
        return iFrame;
}

void THAnimationManager::setAnimationAltPaletteMap(size_t iAnimation, const uint8_t* pMap, uint32_t iAlt32)
{
    if(iAnimation >= m_iAnimationCount)
        return;

    size_t iFrame = m_vFirstFrames[iAnimation];
    size_t iFirstFrame = iFrame;
    do
    {
        size_t iListIndex = m_vFrames[iFrame].iListIndex;
        for(; ; ++iListIndex)
        {
            uint16_t iElement = m_vElementList[iListIndex];
            if(iElement >= m_iElementCount)
                break;

            element_t& oElement = m_vElements[iElement];
            if (oElement.pSpriteSheet != NULL)
                oElement.pSpriteSheet->setSpriteAltPaletteMap(oElement.iSprite, pMap, iAlt32);
        }
        iFrame = m_vFrames[iFrame].iNextFrame;
    } while(iFrame != iFirstFrame);
}

bool THAnimationManager::setFrameMarker(size_t iFrame, int iX, int iY)
{
    if(iFrame >= m_iFrameCount)
        return false;
    m_vFrames[iFrame].iMarkerX = iX;
    m_vFrames[iFrame].iMarkerY = iY;
    return true;
}

bool THAnimationManager::setFrameSecondaryMarker(size_t iFrame, int iX, int iY)
{
    if(iFrame >= m_iFrameCount)
        return false;
    m_vFrames[iFrame].iSecondaryMarkerX = iX;
    m_vFrames[iFrame].iSecondaryMarkerY = iY;
    return true;
}

bool THAnimationManager::getFrameMarker(size_t iFrame, int* pX, int* pY)
{
    if(iFrame >= m_iFrameCount)
        return false;
    *pX = m_vFrames[iFrame].iMarkerX;
    *pY = m_vFrames[iFrame].iMarkerY;
    return true;
}

bool THAnimationManager::getFrameSecondaryMarker(size_t iFrame, int* pX, int* pY)
{
    if(iFrame >= m_iFrameCount)
        return false;
    *pX = m_vFrames[iFrame].iSecondaryMarkerX;
    *pY = m_vFrames[iFrame].iSecondaryMarkerY;
    return true;
}

bool THAnimationManager::hitTest(size_t iFrame, const THLayers_t& oLayers,
                                 int iX, int iY, uint32_t iFlags,
                                 int iTestX, int iTestY) const
{
    if(iFrame >= m_iFrameCount)
        return false;

    const frame_t& oFrame = m_vFrames[iFrame];
    iTestX -= iX;
    iTestY -= iY;

    if(iFlags & THDF_FlipHorizontal)
        iTestX = -iTestX;
    if(iTestX < oFrame.iBoundingLeft || iTestX > oFrame.iBoundingRight)
        return false;

    if(iFlags & THDF_FlipVertical)
    {
        if(-iTestY < oFrame.iBoundingTop || -iTestY > oFrame.iBoundingBottom)
            return false;
    }
    else
    {
        if(iTestY < oFrame.iBoundingTop || iTestY > oFrame.iBoundingBottom)
            return false;
    }

    if(iFlags & THDF_BoundBoxHitTest)
        return true;

    size_t iListIndex = oFrame.iListIndex;
    for(; ; ++iListIndex)
    {
        uint16_t iElement = m_vElementList[iListIndex];
        if(iElement >= m_iElementCount)
            break;

        const element_t &oElement = m_vElements[iElement];
        if((oElement.iLayerId != 0 && oLayers.iLayerContents[oElement.iLayer] != oElement.iLayerId)
         || oElement.pSpriteSheet == NULL)
        {
            continue;
        }

        if(iFlags & THDF_FlipHorizontal)
        {
            unsigned int iWidth, iHeight;
            oElement.pSpriteSheet->getSpriteSizeUnchecked(oElement.iSprite, &iWidth, &iHeight);
            if(oElement.pSpriteSheet->hitTestSprite(oElement.iSprite, oElement.iX + iWidth - iTestX,
                iTestY - oElement.iY, oElement.iFlags ^ THDF_FlipHorizontal))
            {
                return true;
            }
        }
        else
        {
            if(oElement.pSpriteSheet->hitTestSprite(oElement.iSprite, iTestX - oElement.iX,
                iTestY - oElement.iY, oElement.iFlags))
            {
                return true;
            }
        }
    }

    return false;
}

void THAnimationManager::drawFrame(THRenderTarget* pCanvas, size_t iFrame,
                                   const THLayers_t& oLayers,
                                   int iX, int iY, uint32_t iFlags) const
{
    if(iFrame >= m_iFrameCount)
        return;

    uint32_t iPassOnFlags = iFlags & THDF_AltPalette;

    size_t iListIndex = m_vFrames[iFrame].iListIndex;
    for(; ; ++iListIndex)
    {
        uint16_t iElement = m_vElementList[iListIndex];
        if(iElement >= m_iElementCount)
            break;

        const element_t &oElement = m_vElements[iElement];
        if (oElement.pSpriteSheet == NULL)
            continue;

        if(oElement.iLayerId != 0 && oLayers.iLayerContents[oElement.iLayer] != oElement.iLayerId)
        {
            // Some animations involving doctors (i.e. #72, #74, maybe others)
            // only provide versions for heads W1 and B1, not W2 and B2. The
            // quickest way to fix this is this dirty hack here, which draws
            // the W1 layer as well as W2 if W2 is being used, and similarly
            // for B1 / B2. A better fix would be to go into each animation
            // which needs it, and duplicate the W1 / B1 layers to W2 / B2.
            if(oElement.iLayer == 5 && oLayers.iLayerContents[5] - 4 == oElement.iLayerId)
                /* don't skip */;
            else
                continue;
        }

        if(iFlags & THDF_FlipHorizontal)
        {
            unsigned int iWidth, iHeight;
            oElement.pSpriteSheet->getSpriteSizeUnchecked(oElement.iSprite, &iWidth, &iHeight);

            oElement.pSpriteSheet->drawSprite(pCanvas, oElement.iSprite, iX - oElement.iX - iWidth,
                iY + oElement.iY, iPassOnFlags | (oElement.iFlags ^ THDF_FlipHorizontal));
        }
        else
        {
            oElement.pSpriteSheet->drawSprite(pCanvas, oElement.iSprite,
                iX + oElement.iX, iY + oElement.iY, iPassOnFlags | oElement.iFlags);
        }
    }
}

size_t THAnimationManager::getFrameSound(size_t iFrame)
{
    if(iFrame < m_iFrameCount)
        return m_vFrames[iFrame].iSound;
    else
        return 0;
}

void THAnimationManager::getFrameExtent(size_t iFrame, const THLayers_t& oLayers,
                                        int* pMinX, int* pMaxX,
                                        int* pMinY, int* pMaxY,
                                        uint32_t iFlags) const
{
    int iMinX = INT_MAX;
    int iMaxX = INT_MIN;
    int iMinY = INT_MAX;
    int iMaxY = INT_MIN;
    if(iFrame < m_iFrameCount)
    {
        size_t iListIndex = m_vFrames[iFrame].iListIndex;

        for(; ; ++iListIndex)
        {
            uint16_t iElement = m_vElementList[iListIndex];
            if(iElement >= m_iElementCount)
                break;

            const element_t &oElement = m_vElements[iElement];
            if((oElement.iLayerId != 0 && oLayers.iLayerContents[oElement.iLayer] != oElement.iLayerId)
                || oElement.pSpriteSheet == NULL)
            {
                continue;
            }

            int iX = oElement.iX;
            int iY = oElement.iY;
            unsigned int iWidth_, iHeight_;
            oElement.pSpriteSheet->getSpriteSizeUnchecked(oElement.iSprite, &iWidth_, &iHeight_);
            int iWidth = static_cast<int>(iWidth_);
            int iHeight = static_cast<int>(iHeight_);
            if(iFlags & THDF_FlipHorizontal)
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

THChunkRenderer::THChunkRenderer(int width, int height, uint8_t *buffer)
{
    m_data = buffer ? buffer : new uint8_t[width * height];
    m_ptr = m_data;
    m_end = m_data + width * height;
    m_x = 0;
    m_y = 0;
    m_width = width;
    m_height = height;
    m_skip_eol = false;
}

THChunkRenderer::~THChunkRenderer()
{
    delete[] m_data;
}

uint8_t* THChunkRenderer::takeData()
{
    uint8_t *buffer = m_data;
    m_data = 0;
    return buffer;
}

void THChunkRenderer::chunkFillToEndOfLine(uint8_t value)
{
    if(m_x != 0 || !m_skip_eol)
    {
        chunkFill(m_width - m_x, value);
    }
    m_skip_eol = false;
}

void THChunkRenderer::chunkFinish(uint8_t value)
{
    chunkFill(static_cast<int>(m_end - m_ptr), value);
}

void THChunkRenderer::chunkFill(int npixels, uint8_t value)
{
    _fixNpixels(npixels);
    if(npixels > 0)
    {
        memset(m_ptr, value, npixels);
        _incrementPosition(npixels);
    }
}

void THChunkRenderer::chunkCopy(int npixels, const uint8_t* data)
{
    _fixNpixels(npixels);
    if(npixels > 0)
    {
        memcpy(m_ptr, data, npixels);
        _incrementPosition(npixels);
    }
}


inline void THChunkRenderer::_fixNpixels(int& npixels) const
{
    if(m_ptr + npixels > m_end)
    {
        npixels = static_cast<int>(m_end - m_ptr);
    }
}

inline void THChunkRenderer::_incrementPosition(int npixels)
{
    m_ptr += npixels;
    m_x += npixels;
    m_y += m_x / m_width;
    m_x = m_x % m_width;
    m_skip_eol = true;
}

void THChunkRenderer::decodeChunks(const uint8_t* data, int datalen, bool complex)
{
    if(complex)
    {
        while(!_isDone() && datalen > 0)
        {
            uint8_t b = *data;
            --datalen;
            ++data;
            if(b == 0)
            {
                chunkFillToEndOfLine(0xFF);
            }
            else if(b < 0x40)
            {
                int amt = b;
                if(datalen < amt)
                    amt = datalen;
                chunkCopy(amt, data);
                data += amt;
                datalen -= amt;
            }
            else if((b & 0xC0) == 0x80)
            {
                chunkFill(b - 0x80, 0xFF);
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
                chunkFill(amt, colour);
            }
        }
    }
    else
    {
        while(!_isDone() && datalen > 0)
        {
            uint8_t b = *data;
            --datalen;
            ++data;
            if(b == 0)
            {
                chunkFillToEndOfLine(0xFF);
            }
            else if(b < 0x80)
            {
                int amt = b;
                if(datalen < amt)
                    amt = datalen;
                chunkCopy(amt, data);
                data += amt;
                datalen -= amt;
            }
            else
            {
                chunkFill(0x100 - b, 0xFF);
            }
        }
    }
    chunkFinish(0xFF);
}

#define AreFlagsSet(val, flags) (((val) & (flags)) == (flags))

void THAnimation::draw(THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    if(AreFlagsSet(m_iFlags, THDF_Alpha50 | THDF_Alpha75))
        return;

    iDestX += m_iX;
    iDestY += m_iY;
    if(m_iSoundToPlay)
    {
        THSoundEffects *pSounds = THSoundEffects::getSingleton();
        if(pSounds)
            pSounds->playSoundAt(m_iSoundToPlay, iDestX, iDestY);
        m_iSoundToPlay = 0;
    }
    if(m_pManager)
    {
        if(m_iFlags & THDF_Crop)
        {
            THClipRect rcOld, rcNew;
            pCanvas->getClipRect(&rcOld);
            rcNew.y = rcOld.y;
            rcNew.h = rcOld.h;
            rcNew.x = iDestX + (m_iCropColumn - 1) * 32;
            rcNew.w = 64;
            IntersectTHClipRect(rcNew, rcOld);
            pCanvas->setClipRect(&rcNew);
            m_pManager->drawFrame(pCanvas, m_iFrame, m_oLayers, iDestX, iDestY,
                                  m_iFlags);
            pCanvas->setClipRect(&rcOld);
        }
        else
            m_pManager->drawFrame(pCanvas, m_iFrame, m_oLayers, iDestX, iDestY,
                                  m_iFlags);
    }
}

void THAnimation::drawChild(THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    if(AreFlagsSet(m_iFlags, THDF_Alpha50 | THDF_Alpha75))
        return;
    if(AreFlagsSet(m_pParent->m_iFlags, THDF_Alpha50 | THDF_Alpha75))
        return;
    int iX = 0, iY = 0;
    m_pParent->getMarker(&iX, &iY);
    iX += m_iX + iDestX;
    iY += m_iY + iDestY;
    if(m_iSoundToPlay)
    {
        THSoundEffects *pSounds = THSoundEffects::getSingleton();
        if(pSounds)
            pSounds->playSoundAt(m_iSoundToPlay, iX, iY);
        m_iSoundToPlay = 0;
    }
    if(m_pManager)
        m_pManager->drawFrame(pCanvas, m_iFrame, m_oLayers, iX, iY, m_iFlags);
}

bool THAnimation::hitTestChild(int iDestX, int iDestY, int iTestX, int iTestY)
{
    // TODO
    return false;
}

static void CalculateMorphRect(const THClipRect& rcOriginal, THClipRect& rcMorph, int iYLow, int iYHigh)
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

void THAnimation::drawMorph(THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    if(AreFlagsSet(m_iFlags, THDF_Alpha50 | THDF_Alpha75))
        return;

    if(!m_pManager)
        return;

    iDestX += m_iX;
    iDestY += m_iY;
    if(m_iSoundToPlay)
    {
        THSoundEffects *pSounds = THSoundEffects::getSingleton();
        if(pSounds)
            pSounds->playSoundAt(m_iSoundToPlay, iDestX, iDestY);
        m_iSoundToPlay = 0;
    }

    THClipRect oClipRect;
    pCanvas->getClipRect(&oClipRect);
    THClipRect oMorphRect;
    CalculateMorphRect(oClipRect, oMorphRect, iDestY + m_pMorphTarget->m_iX,
                       iDestY + m_pMorphTarget->m_iY + 1);
    pCanvas->setClipRect(&oMorphRect);
    m_pManager->drawFrame(pCanvas, m_iFrame, m_oLayers, iDestX, iDestY,
                          m_iFlags);
    CalculateMorphRect(oClipRect, oMorphRect, iDestY + m_pMorphTarget->m_iY,
                       iDestY + m_pMorphTarget->m_iSpeedX);
    pCanvas->setClipRect(&oMorphRect);
    m_pManager->drawFrame(pCanvas, m_pMorphTarget->m_iFrame,
                          m_pMorphTarget->m_oLayers, iDestX,
                          iDestY, m_pMorphTarget->m_iFlags);
    pCanvas->setClipRect(&oClipRect);
}


bool THAnimation::hitTest(int iDestX, int iDestY, int iTestX, int iTestY)
{
    if(AreFlagsSet(m_iFlags, THDF_Alpha50 | THDF_Alpha75))
        return false;
    if(m_pManager == NULL)
        return false;
    return m_pManager->hitTest(m_iFrame, m_oLayers, m_iX + iDestX,
        m_iY + iDestY, m_iFlags, iTestX, iTestY);
}

bool THAnimation::hitTestMorph(int iDestX, int iDestY, int iTestX, int iTestY)
{
    if(AreFlagsSet(m_iFlags, THDF_Alpha50 | THDF_Alpha75))
        return false;
    if(m_pManager == NULL)
        return false;
    return m_pManager->hitTest(m_iFrame, m_oLayers, m_iX + iDestX,
        m_iY + iDestY, m_iFlags, iTestX, iTestY) || m_pMorphTarget->hitTest(
        iDestX, iDestY, iTestX, iTestY);
}

#undef AreFlagsSet

static bool THAnimation_HitTestChild(THDrawable* pSelf, int iDestX, int iDestY, int iTestX, int iTestY)
{
    return reinterpret_cast<THAnimation*>(pSelf)->hitTestChild(iDestX, iDestY, iTestX, iTestY);
}

static void THAnimation_DrawChild(THDrawable* pSelf, THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    reinterpret_cast<THAnimation*>(pSelf)->drawChild(pCanvas, iDestX, iDestY);
}

static bool THAnimation_HitTestMorph(THDrawable* pSelf, int iDestX, int iDestY, int iTestX, int iTestY)
{
    return reinterpret_cast<THAnimation*>(pSelf)->hitTestMorph(iDestX, iDestY, iTestX, iTestY);
}

static void THAnimation_DrawMorph(THDrawable* pSelf, THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    reinterpret_cast<THAnimation*>(pSelf)->drawMorph(pCanvas, iDestX, iDestY);
}

static bool THAnimation_HitTest(THDrawable* pSelf, int iDestX, int iDestY, int iTestX, int iTestY)
{
    return reinterpret_cast<THAnimation*>(pSelf)->hitTest(iDestX, iDestY, iTestX, iTestY);
}

static void THAnimation_Draw(THDrawable* pSelf, THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    reinterpret_cast<THAnimation*>(pSelf)->draw(pCanvas, iDestX, iDestY);
}

static bool THAnimation_isMultipleFrameAnimation(THDrawable* pSelf)
{
    THAnimation *pAnimation = reinterpret_cast<THAnimation *>(pSelf);
    if(pAnimation)
    {
        size_t firstFrame = pAnimation->getAnimationManager()->getFirstFrame(pAnimation->getAnimation());
        size_t nextFrame = pAnimation->getAnimationManager()->getNextFrame(firstFrame);
        return nextFrame != firstFrame;
    }
    else
        return false;

}

THAnimationBase::THAnimationBase()
{
    m_iX = 0;
    m_iY = 0;
    for(int i = 0; i < 13; ++i)
        m_oLayers.iLayerContents[i] = 0;
    m_iFlags = 0;
}

THAnimation::THAnimation()
{
    m_fnDraw = THAnimation_Draw;
    m_fnHitTest = THAnimation_HitTest;
    m_fnIsMultipleFrameAnimation = THAnimation_isMultipleFrameAnimation;
    m_pManager = NULL;
    m_pMorphTarget = NULL;
    m_iAnimation = 0;
    m_iFrame = 0;
    m_iCropColumn = 0;
    m_iSpeedX = 0;
    m_iSpeedY = 0;
    m_iSoundToPlay = 0;
}

void THAnimation::persist(LuaPersistWriter *pWriter) const
{
    lua_State *L = pWriter->getStack();

    // Write the next chained thing
    lua_rawgeti(L, luaT_environindex, 2);
    lua_pushlightuserdata(L, m_pNext);
    lua_rawget(L, -2);
    pWriter->fastWriteStackObject(-1);
    lua_pop(L, 2);

    // Write the THDrawable fields
    pWriter->writeVUInt(m_iFlags);
#define IsUsingFunctionSet(d, ht) m_fnDraw == (THAnimation_ ## d) \
                            && m_fnHitTest == (THAnimation_ ## ht)

    if(IsUsingFunctionSet(Draw, HitTest))
        pWriter->writeVUInt(1);
    else if(IsUsingFunctionSet(DrawChild, HitTestChild))
        pWriter->writeVUInt(2);
    else if(IsUsingFunctionSet(DrawMorph, HitTestMorph))
    {
        // NB: Prior version of code used the number 3 here, and forgot
        // to persist the morph target.
        pWriter->writeVUInt(4);
        lua_rawgeti(L, luaT_environindex, 2);
        lua_pushlightuserdata(L, m_pMorphTarget);
        lua_rawget(L, -2);
        pWriter->writeStackObject(-1);
        lua_pop(L, 2);
    }
    else
        pWriter->writeVUInt(0);

#undef IsUsingFunctionSet

    // Write the simple fields
    pWriter->writeVUInt(m_iAnimation);
    pWriter->writeVUInt(m_iFrame);
    pWriter->writeVInt(m_iX);
    pWriter->writeVInt(m_iY);
    pWriter->writeVInt((int)m_iSoundToPlay); // Not a VUInt, for compatibility
    pWriter->writeVInt(0); // For compatibility
    if(m_iFlags & THDF_Crop)
        pWriter->writeVInt(m_iCropColumn);

    // Write the unioned fields
    if(m_fnDraw != THAnimation_DrawChild)
    {
        pWriter->writeVInt(m_iSpeedX);
        pWriter->writeVInt(m_iSpeedY);
    }
    else
    {
        lua_rawgeti(L, luaT_environindex, 2);
        lua_pushlightuserdata(L, m_pParent);
        lua_rawget(L, -2);
        pWriter->writeStackObject(-1);
        lua_pop(L, 2);
    }

    // Write the layers
    int iNumLayers = 13;
    for( ; iNumLayers >= 1; --iNumLayers)
    {
        if(m_oLayers.iLayerContents[iNumLayers - 1] != 0)
            break;
    }
    pWriter->writeVUInt(iNumLayers);
    pWriter->writeByteStream(m_oLayers.iLayerContents, iNumLayers);
}

void THAnimation::depersist(LuaPersistReader *pReader)
{
    lua_State *L = pReader->getStack();

    do
    {
        // Read the chain
        if(!pReader->readStackObject())
            break;
        m_pNext = reinterpret_cast<THLinkList*>(lua_touserdata(L, -1));
        if(m_pNext)
            m_pNext->m_pPrev = this;
        lua_pop(L, 1);

        // Read THDrawable fields
        if(!pReader->readVUInt(m_iFlags))
            break;
        int iFunctionSet;
        if(!pReader->readVUInt(iFunctionSet))
            break;
        switch(iFunctionSet)
        {
        case 3:
            // 3 should be the morph set, but the actual morph target is
            // missing, so settle for a graphical bug rather than a segfault
            // by reverting to the normal function set.
        case 1:
            m_fnDraw = THAnimation_Draw;
            m_fnHitTest = THAnimation_HitTest;
            break;
        case 2:
            m_fnDraw = THAnimation_DrawChild;
            m_fnHitTest = THAnimation_HitTestChild;
            break;
        case 4:
            m_fnDraw = THAnimation_DrawMorph;
            m_fnHitTest = THAnimation_HitTestMorph;
            pReader->readStackObject();
            m_pMorphTarget = reinterpret_cast<THAnimation*>(lua_touserdata(L, -1));
            lua_pop(L, 1);
            break;
        default:
            pReader->setError(lua_pushfstring(L, "Unknown animation function set #%i", iFunctionSet));
            return;
        }

        // Read the simple fields
        if(!pReader->readVUInt(m_iAnimation))
            break;
        if(!pReader->readVUInt(m_iFrame))
            break;
        if(!pReader->readVInt(m_iX))
            break;
        if(!pReader->readVInt(m_iY))
            break;
        int iDummy;
        if(!pReader->readVInt(iDummy))
            break;
        if(iDummy >= 0)
            m_iSoundToPlay = (unsigned int)iDummy;
        if(!pReader->readVInt(iDummy))
            break;
        if(m_iFlags & THDF_Crop)
        {
            if(!pReader->readVInt(m_iCropColumn))
                break;
        }
        else
            m_iCropColumn = 0;

        // Read the unioned fields
        if(m_fnDraw != THAnimation_DrawChild)
        {
            if(!pReader->readVInt(m_iSpeedX))
                break;
            if(!pReader->readVInt(m_iSpeedY))
                break;
        }
        else
        {
            if(!pReader->readStackObject())
                break;
            m_pParent = (THAnimation*)lua_touserdata(L, -1);
            lua_pop(L, 1);
        }

        // Read the layers
        memset(m_oLayers.iLayerContents, 0, sizeof(m_oLayers.iLayerContents));
        int iNumLayers;
        if(!pReader->readVUInt(iNumLayers))
            break;
        if(iNumLayers > 13)
        {
            if(!pReader->readByteStream(m_oLayers.iLayerContents, 13))
                break;
            if(!pReader->readByteStream(NULL, iNumLayers - 13))
                break;
        }
        else
        {
            if(!pReader->readByteStream(m_oLayers.iLayerContents, iNumLayers))
                break;
        }

        // Fix the m_pAnimator field
        luaT_getenvfield(L, 2, "animator");
        m_pManager = (THAnimationManager*)lua_touserdata(L, -1);
        lua_pop(L, 1);

        return;
    } while(false);

    pReader->setError("Cannot depersist THAnimation instance");
}

void THAnimation::tick()
{
    m_iFrame = m_pManager->getNextFrame(m_iFrame);
    if(m_fnDraw != THAnimation_DrawChild)
    {
        m_iX += m_iSpeedX;
        m_iY += m_iSpeedY;
    }
    if(m_pMorphTarget)
    {
        m_pMorphTarget->m_iY += m_pMorphTarget->m_iSpeedY;
        if(m_pMorphTarget->m_iY < m_pMorphTarget->m_iX)
            m_pMorphTarget->m_iY = m_pMorphTarget->m_iX;
    }

    //Female flying to heaven sound fix:
    if(m_iFrame == 6987)
        m_iSoundToPlay = 123;
    else
        m_iSoundToPlay = m_pManager->getFrameSound(m_iFrame);
}

void THAnimationBase::removeFromTile()
{
    THLinkList::removeFromList();
}

void THAnimationBase::attachToTile(THMapNode *pMapNode, int layer)
{
    removeFromTile();
    THLinkList *pList;
    if(m_iFlags & THDF_EarlyList)
        pList = &pMapNode->oEarlyEntities;
    else
        pList = pMapNode;

    this->setDrawingLayer(layer);

#define GetFlags(x) (reinterpret_cast<THDrawable*>(x)->m_iFlags)
    while(pList->m_pNext && pList->m_pNext->getDrawingLayer() < layer)
    {
        pList = pList->m_pNext;
    }
#undef GetFlags

    m_pPrev = pList;
    if(pList->m_pNext != NULL)
    {
        pList->m_pNext->m_pPrev = this;
        this->m_pNext = pList->m_pNext;
    }
    else
    {
        m_pNext = NULL;
    }
    pList->m_pNext = this;
}

void THAnimation::setParent(THAnimation *pParent)
{
    removeFromTile();
    if(pParent == NULL)
    {
        m_fnDraw = THAnimation_Draw;
        m_fnHitTest = THAnimation_HitTest;
        m_iSpeedX = 0;
        m_iSpeedY = 0;
    }
    else
    {
        m_fnDraw = THAnimation_DrawChild;
        m_fnHitTest = THAnimation_HitTestChild;
        m_pParent = pParent;
        m_pNext = m_pParent->m_pNext;
        if(m_pNext)
            m_pNext->m_pPrev = this;
        m_pPrev = m_pParent;
        m_pParent->m_pNext = this;
    }
}

void THAnimation::setAnimation(THAnimationManager* pManager, size_t iAnimation)
{
    m_pManager = pManager;
    m_iAnimation = iAnimation;
    m_iFrame = pManager->getFirstFrame(iAnimation);
    if(m_pMorphTarget)
    {
        m_pMorphTarget = NULL;
        m_fnDraw = THAnimation_Draw;
        m_fnHitTest = THAnimation_HitTest;
    }
}

bool THAnimation::getMarker(int* pX, int* pY)
{
    if(!m_pManager || !m_pManager->getFrameMarker(m_iFrame, pX, pY))
        return false;
    if(m_iFlags & THDF_FlipHorizontal)
        *pX = -*pX;
    *pX += m_iX;
    *pY += m_iY + 16;
    return true;
}

bool THAnimation::getSecondaryMarker(int* pX, int* pY)
{
    if(!m_pManager || !m_pManager->getFrameSecondaryMarker(m_iFrame, pX, pY))
        return false;
    if(m_iFlags & THDF_FlipHorizontal)
        *pX = -*pX;
    *pX += m_iX;
    *pY += m_iY + 16;
    return true;
}

static int GetAnimationDurationAndExtent(THAnimationManager *pManager,
                                         size_t iFrame,
                                         const THLayers_t& oLayers,
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
        pManager->getFrameExtent(iCurFrame, oLayers, NULL, NULL, &iFrameMinY, &iFrameMaxY, iFlags);
        if(iFrameMinY < iMinY)
            iMinY = iFrameMinY;
        if(iFrameMaxY > iMaxY)
            iMaxY = iFrameMaxY;
        iCurFrame = pManager->getNextFrame(iCurFrame);
        ++iDuration;
    } while(iCurFrame != iFrame);
    if(pMinY)
        *pMinY = iMinY;
    if(pMaxY)
        *pMaxY = iMaxY;
    return iDuration;
}

void THAnimation::setMorphTarget(THAnimation *pMorphTarget, unsigned int iDurationFactor)
{
    m_pMorphTarget = pMorphTarget;
    m_fnDraw = THAnimation_DrawMorph;
    m_fnHitTest = THAnimation_HitTestMorph;

    /* Morphing is the process by which two animations are combined to give a
    single animation of one animation turning into another. At the moment,
    morphing is done by having a y value, above which the original animation is
    rendered, and below which the new animation is rendered, and having the y
    value move upward a bit each frame.
    One example of where this is used is when transparent or invisible patients
    are cured at the pharmacy cabinet.
    The process of morphing requires four state variables, which are stored in
    the morph target animation:
      * The y value top limit - m_pMorphTarget->m_iX
      * The y value threshold - m_pMorphTarget->m_iY
      * The y value bottom limit - m_pMorphTarget->m_iSpeedX
      * The y value increment per frame - m_pMorphTarget->m_iSpeedY
    This obviously means that the morph target should not be ticked or rendered
    as it's position and speed contain other values.
    */

    int iOrigMinY, iOrigMaxY;
    int iMorphMinY, iMorphMaxY;

#define GADEA GetAnimationDurationAndExtent
    int iOriginalDuration = GADEA(m_pManager, m_iFrame, m_oLayers, &iOrigMinY,
                                  &iOrigMaxY, m_iFlags);
    int iMorphDuration = GADEA(m_pMorphTarget->m_pManager,
                               m_pMorphTarget->m_iFrame,
                               m_pMorphTarget->m_oLayers, &iMorphMinY,
                               &iMorphMaxY, m_pMorphTarget->m_iFlags);
    if(iMorphDuration > iOriginalDuration)
        iMorphDuration = iOriginalDuration;
#undef GADEA

    iMorphDuration *= iDurationFactor;
    if(iOrigMinY < iMorphMinY)
        m_pMorphTarget->m_iX = iOrigMinY;
    else
        m_pMorphTarget->m_iX = iMorphMinY;

    if(iOrigMaxY > iMorphMaxY)
        m_pMorphTarget->m_iSpeedX = iOrigMaxY;
    else
        m_pMorphTarget->m_iSpeedX = iMorphMaxY;

    int iDist = m_pMorphTarget->m_iX - m_pMorphTarget->m_iSpeedX;
    m_pMorphTarget->m_iSpeedY = (iDist - iMorphDuration + 1) / iMorphDuration;
    m_pMorphTarget->m_iY = m_pMorphTarget->m_iSpeedX;
}

void THAnimation::setFrame(size_t iFrame)
{
    m_iFrame = iFrame;
}

void THAnimationBase::setLayer(int iLayer, int iId)
{
    if(0 <= iLayer && iLayer <= 12)
    {
        m_oLayers.iLayerContents[iLayer] = static_cast<uint8_t>(iId);
    }
}

static bool THSpriteRenderList_HitTest(THDrawable* pSelf, int iDestX,
                                       int iDestY, int iTestX, int iTestY)
{
    return reinterpret_cast<THSpriteRenderList*>(pSelf)->
        hitTest(iDestX, iDestY, iTestX, iTestY);
}

static void THSpriteRenderList_Draw(THDrawable* pSelf, THRenderTarget* pCanvas,
                                    int iDestX, int iDestY)
{
    reinterpret_cast<THSpriteRenderList*>(pSelf)->
        draw(pCanvas, iDestX, iDestY);
}

static bool THSpriteRenderList_isMultipleFrameAnimation(THDrawable* pSelf)
{
    return false;
}
THSpriteRenderList::THSpriteRenderList()
{
    m_fnDraw = THSpriteRenderList_Draw;
    m_fnHitTest = THSpriteRenderList_HitTest;
    m_fnIsMultipleFrameAnimation = THSpriteRenderList_isMultipleFrameAnimation;
    m_iBufferSize = 0;
    m_iNumSprites = 0;
    m_pSpriteSheet = NULL;
    m_pSprites = NULL;
    m_iSpeedX = 0;
    m_iSpeedY = 0;
    m_iLifetime = -1;
}

THSpriteRenderList::~THSpriteRenderList()
{
    delete[] m_pSprites;
}

void THSpriteRenderList::tick()
{
    m_iX += m_iSpeedX;
    m_iY += m_iSpeedY;
    if(m_iLifetime > 0)
        --m_iLifetime;
}

void THSpriteRenderList::draw(THRenderTarget* pCanvas, int iDestX, int iDestY)
{
    if(!m_pSpriteSheet)
        return;

    iDestX += m_iX;
    iDestY += m_iY;
    for(_sprite_t *pSprite = m_pSprites, *pLast = m_pSprites + m_iNumSprites;
        pSprite != pLast; ++pSprite)
    {
        m_pSpriteSheet->drawSprite(pCanvas, pSprite->iSprite,
            iDestX + pSprite->iX, iDestY + pSprite->iY, m_iFlags);
    }
}

bool THSpriteRenderList::hitTest(int iDestX, int iDestY, int iTestX, int iTestY)
{
    // TODO
    return false;
}

void THSpriteRenderList::setLifetime(int iLifetime)
{
    if(iLifetime < 0)
        iLifetime = -1;
    m_iLifetime = iLifetime;
}

void THSpriteRenderList::appendSprite(size_t iSprite, int iX, int iY)
{
    if(m_iBufferSize == m_iNumSprites)
    {
        int iNewSize = m_iBufferSize * 2;
        if(iNewSize == 0)
            iNewSize = 4;
        _sprite_t* pNewSprites = new _sprite_t[iNewSize];
#ifdef _MSC_VER
#pragma warning(disable: 4996)
#endif
        std::copy(m_pSprites, m_pSprites + m_iNumSprites, pNewSprites);
#ifdef _MSC_VER
#pragma warning(default: 4996)
#endif
        delete[] m_pSprites;
        m_pSprites = pNewSprites;
        m_iBufferSize = iNewSize;
    }
    m_pSprites[m_iNumSprites].iSprite = iSprite;
    m_pSprites[m_iNumSprites].iX = iX;
    m_pSprites[m_iNumSprites].iY = iY;
    ++m_iNumSprites;
}

void THSpriteRenderList::persist(LuaPersistWriter *pWriter) const
{
    lua_State *L = pWriter->getStack();

    pWriter->writeVUInt(m_iNumSprites);
    pWriter->writeVUInt(m_iFlags);
    pWriter->writeVInt(m_iX);
    pWriter->writeVInt(m_iY);
    pWriter->writeVInt(m_iSpeedX);
    pWriter->writeVInt(m_iSpeedY);
    pWriter->writeVInt(m_iLifetime);
    for(_sprite_t *pSprite = m_pSprites, *pLast = m_pSprites + m_iNumSprites;
        pSprite != pLast; ++pSprite)
    {
        pWriter->writeVUInt(pSprite->iSprite);
        pWriter->writeVInt(pSprite->iX);
        pWriter->writeVInt(pSprite->iY);
    }

    // Write the layers
    int iNumLayers = 13;
    for( ; iNumLayers >= 1; --iNumLayers)
    {
        if(m_oLayers.iLayerContents[iNumLayers - 1] != 0)
            break;
    }
    pWriter->writeVUInt(iNumLayers);
    pWriter->writeByteStream(m_oLayers.iLayerContents, iNumLayers);

    // Write the next chained thing
    lua_rawgeti(L, luaT_environindex, 2);
    lua_pushlightuserdata(L, m_pNext);
    lua_rawget(L, -2);
    pWriter->fastWriteStackObject(-1);
    lua_pop(L, 2);
}

void THSpriteRenderList::depersist(LuaPersistReader *pReader)
{
    lua_State *L = pReader->getStack();

    if(!pReader->readVUInt(m_iNumSprites))
        return;
    m_iBufferSize = m_iNumSprites;
    delete[] m_pSprites;
    m_pSprites = new _sprite_t[m_iBufferSize];

    if(!pReader->readVUInt(m_iFlags))
        return;
    if(!pReader->readVInt(m_iX))
        return;
    if(!pReader->readVInt(m_iY))
        return;
    if(!pReader->readVInt(m_iSpeedX))
        return;
    if(!pReader->readVInt(m_iSpeedY))
        return;
    if(!pReader->readVInt(m_iLifetime))
        return;
    for(_sprite_t *pSprite = m_pSprites, *pLast = m_pSprites + m_iNumSprites;
        pSprite != pLast; ++pSprite)
    {
        if(!pReader->readVUInt(pSprite->iSprite))
            return;
        if(!pReader->readVInt(pSprite->iX))
            return;
        if(!pReader->readVInt(pSprite->iY))
            return;
    }

    // Read the layers
    memset(m_oLayers.iLayerContents, 0, sizeof(m_oLayers.iLayerContents));
    int iNumLayers;
    if(!pReader->readVUInt(iNumLayers))
        return;
    if(iNumLayers > 13)
    {
        if(!pReader->readByteStream(m_oLayers.iLayerContents, 13))
            return;
        if(!pReader->readByteStream(NULL, iNumLayers - 13))
            return;
    }
    else
    {
        if(!pReader->readByteStream(m_oLayers.iLayerContents, iNumLayers))
            return;
    }

    // Read the chain
    if(!pReader->readStackObject())
        return;
    m_pNext = reinterpret_cast<THLinkList*>(lua_touserdata(L, -1));
    if(m_pNext)
        m_pNext->m_pPrev = this;
    lua_pop(L, 1);

    // Fix the m_pSpriteSheet field
    luaT_getenvfield(L, 2, "sheet");
    m_pSpriteSheet = (THSpriteSheet*)lua_touserdata(L, -1);
    lua_pop(L, 1);
}
