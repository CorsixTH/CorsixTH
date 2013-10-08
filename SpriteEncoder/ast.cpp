/*
Copyright (c) 2013 Albert "Alberth" Hofkamp

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
#include <cstdio>
#include <cstdlib>
#include <cassert>
#include "ast.h"
#include "image.h"
#include "output.h"

enum Opacity
{
    OP_TRANSPARENT = 0,
    OP_OPAQUE = 255,
};

const std::string sUnset = "<unset>";

Sprite::Sprite()
{
    m_iLine = -1;
    m_iSprite = -1;
    m_iLeft = -1;
    m_iTop = -1;
    m_iWidth = -1;
    m_iHeight = -1;
    m_sBaseImage = sUnset;
    m_sRecolourImage = sUnset;
    for (int i = 0; i < 256; i++)
    {
        m_aNumber[i] = i;
    }
}

void Sprite::SetRecolour(const std::string &sFilename)
{
    m_sRecolourImage = sFilename;
}

static void Report(int iNumber, int iLine, const char *pMsg)
{
    if (iNumber < 0)
    {
        fprintf(stderr, "Sprite at line %d: Missing %s\n", iLine, pMsg);
        exit(1);
    }
}

void Sprite::Check() const
{
    Report(m_iSprite, m_iLine, "sprite number");
    Report(m_iLeft,   m_iLine, "left edge coordinate");
    Report(m_iTop,    m_iLine, "top edge coordinate");
    Report(m_iWidth,  m_iLine, "sprite width");
    Report(m_iHeight, m_iLine, "sprite height");

    if (m_sBaseImage == sUnset)
    {
        fprintf(stderr, "Sprite at line %d: Missing image filename\n", m_iLine);
        exit(1);
    }
}

/**
 * Look ahead in the recolour bitmaps to check when the next recoloured pixels will occur.
 * @param iCount Current index in the image.
 * @param iEndCount End of the image.
 * @param pLayer Recolouring bitmap (if available).
 * @return Number of pixels to go before the next recoloured pixel (limited to 63 look ahead).
 */
static int GetDistanceToNextRecolour(const uint32 iCount, const uint32 iEndCount, const Image8bpp *pLayer)
{
    uint32 iLength = iEndCount - iCount;
    if (iLength > 63) iLength = 63; // No need to look ahead further.

    if (pLayer != NULL)
    {
        for (size_t i = 0; i < iLength; i++)
        {
            if (pLayer->Get(iCount + i) != 0) return i;
        }
    }
    return iLength;
}

/**
 * Get the recolour table to use, and the number of pixels to recolour.
 * @param iCount Current index in the image.
 * @param iEndCount End of the image.
 * @param pLayer Recolouring bitmap.
 * @param pLayerNumber [out] Number of the recolouring table to use.
 * @return Number of pixels to recolour from the current position.
 */
static int GetRecolourInformation(const uint32 iCount, const uint32 iEndCount, const Image8bpp *pLayer, uint8 *pLayerNumber)
{
    uint32 iLength = iEndCount - iCount;
    if (iLength > 63) iLength = 63; // No need to look ahead further.

    *pLayerNumber = pLayer->Get(iCount);
    for (size_t i = 1; i < iLength; i++)
    {
        if (pLayer->Get(iCount + i) != *pLayerNumber) return i;
    }
    return iLength;
}

/**
 * Look ahead in the base image to check how many pixels from the current position have the same opacity.
 * @param iCount Current index in the image.
 * @param iEndCount End of the image.
 * @parswm oBase Base image.
 * @return Number of pixels to go before the opacity of the current pixel changes (limited to 63 look ahead).
 */
static int GetDistanceToNextTransparency(const uint32 iCount, const uint32 iEndCount, const Image32bpp &oBase)
{
    uint32 iLength = iEndCount - iCount;
    if (iLength > 63) iLength = 63; // No need to look ahead further.

    uint8 iOpacity = GetA(oBase.Get(iCount));
    for (uint i = 1; i < iLength; i++)
    {
        if (iOpacity != GetA(oBase.Get(iCount + i))) return i;
    }
    return iLength;
}

/**
 * Write the RGB colour for the next \a iLength pixels, starting from the \a iCount offset.
 * @param oBase Base image to encode.
 * @param iCount Current index in the image.
 * @param iLength Number of pixels to process.
 * @param pDest Destination to write to.
 */
static void WriteColour(const Image32bpp &oBase, uint32 iCount, int iLength, Output *pDest)
{
    while (iLength > 0)
    {
        uint32 iColour = oBase.Get(iCount);
        iCount++;
        pDest->Uint8(GetR(iColour));
        pDest->Uint8(GetG(iColour));
        pDest->Uint8(GetB(iColour));
        iLength--;
    }
}

/**
 * Write the table index for the next \a iLength pixels, starting from the \a iCount offset.
 * @param oBase Base image to encode.
 * @param iCount Current index in the image.
 * @param iLength Number of pixels to process.
 * @param pDest Destination to write to.
 */
static void WriteTableIndex(const Image32bpp &oBase, uint32 iCount, int iLength, Output *pDest)
{
    while (iLength > 0)
    {
        uint32 iColour = oBase.Get(iCount);
        iCount++;
        uint8 biggest = GetR(iColour);
        if (biggest < GetG(iColour)) biggest = GetG(iColour);
        if (biggest < GetB(iColour)) biggest = GetB(iColour);
        pDest->Uint8(biggest);
        iLength--;
    }
}

/**
 * Encode a 32bpp image from the \a oBase image, and optionally the recolouring \a pLayer bitmap.
 */
static void Encode32bpp(int iWidth, int iHeight, const Image32bpp &oBase, const Image8bpp *pLayer, Output *pDest, const unsigned char *pNumber)
{
    const uint32 iPixCount = iWidth * iHeight;
    uint32 iCount = 0;
    while (iCount < iPixCount)
    {
        int iLength = GetDistanceToNextRecolour(iCount, iPixCount, pLayer);
        int length2 = GetDistanceToNextTransparency(iCount, iPixCount, oBase);

        if (iLength > 63) iLength = 63;
        if (iLength == 0) { // Recolour layer.
            uint8 iTableNumber;
            iLength = GetRecolourInformation(iCount, iPixCount, pLayer, &iTableNumber);
            if (length2 < iLength) iLength = length2;
            assert(iLength > 0);

            pDest->Uint8(64 + 128 + iLength);
            pDest->Uint8(pNumber[iTableNumber]);
            pDest->Uint8(GetA(oBase.Get(iCount))); // Opacity.
            WriteTableIndex(oBase, iCount, iLength, pDest);
            iCount += iLength;
            continue;
        }
        if (length2 < iLength) iLength = length2;
        assert(iLength > 0);

        uint8 iOpacity = GetA(oBase.Get(iCount));
        if (iOpacity == OP_OPAQUE) { // Fixed non-transparent 32bpp pixels (RGB).
            pDest->Uint8(iLength);
            WriteColour(oBase, iCount, iLength, pDest);
            iCount += iLength;
            continue;
        }
        if (iOpacity == OP_TRANSPARENT) { // Fixed fully transparent pixels.
            pDest->Uint8(128 + iLength);
            iCount += iLength;
            continue;
        }
        /* Partially transparent 32bpp pixels (RGB). */
        pDest->Uint8(64 + iLength);
        pDest->Uint8(iOpacity);
        WriteColour(oBase, iCount, iLength, pDest);
        iCount += iLength;
        continue;
    }
}

void Sprite::Write(Output *pOut) const
{
    Image32bpp *pBase = Load32Bpp(m_sBaseImage, m_iLine, m_iLeft, m_iWidth, m_iTop, m_iHeight);
    if (pBase == NULL)
    {
        fprintf(stderr, "Warning: Skipping sprite %d at line %d: Image load failed.\n", m_iSprite, m_iLine);
        return;
    }

    Image8bpp *pLayer = NULL;
    if (m_sRecolourImage != sUnset)
    {
        pLayer = Load8Bpp(m_sRecolourImage, m_iLine, m_iLeft, m_iWidth, m_iTop, m_iHeight);
    }

    int iAddress = pOut->Reserve(4);
    pOut->Uint16(m_iSprite);
    pOut->Uint16(m_iWidth);
    pOut->Uint16(m_iHeight); // XXX Add length of this sprite?
    Encode32bpp(m_iWidth, m_iHeight, *pBase, pLayer, pOut, m_aNumber);

    int iLength = pOut->Reserve(0) - (iAddress + 4); // Start counting after the length.
    pOut->Write(iAddress, iLength & 0xFF);
    pOut->Write(iAddress + 1, (iLength >> 8) & 0xFF);
    pOut->Write(iAddress + 2, (iLength >> 16) & 0xFF);
    pOut->Write(iAddress + 3, (iLength >> 24) & 0xFF);

    delete pLayer;
    delete pBase;
}

// vim: et sw=4 ts=4 sts=4
