/*
Copyright (c) 2009-2017 Peter "Corsix" Cawley, Edvin "Lego3" Linge and David Fairbrother

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

#include "sprite.h"

#include <cstdint>

// Todo remove these
#include <new>
#include <cstring>


//! Convert legacy 8bpp sprite data to recoloured 32bpp data, using special recolour table 0xFF.
/*!
@param pPixelData Legacy 8bpp pixels.
@param iPixelDataLength Number of pixels in the \a pPixelData.
@return Converted 32bpp pixel data, if succeeded else nullptr is returned. Caller should free the returned memory.
*/
uint8_t *convertLegacySprite(const uint8_t* pPixelData, size_t iPixelDataLength)
{
	// Recolour blocks are 63 pixels long.
	// XXX To reduce the size of the 32bpp data, transparent pixels can be stored more compactly.
	size_t numBlocks = iPixelDataLength / 63;
	size_t remainingPixels = iPixelDataLength - numBlocks * 63;

	const int blockLength = 63;
	const int numExtraBlocks = 3;

	size_t iNewSize = numBlocks * (blockLength + numExtraBlocks);

	// If there are remaining pixels add enough space for our extra blocks and those pixels
	// in the destination buffer
	iNewSize += (remainingPixels > 0) ? numExtraBlocks + remainingPixels : 0;

	uint8_t *pData = new (std::nothrow) uint8_t[iNewSize];
	if (pData == nullptr)
		return nullptr;

	uint8_t *pDest = pData;
	while (iPixelDataLength > 0)
	{
		size_t iLength = (iPixelDataLength >= 63) ? 63 : iPixelDataLength;
		*pDest++ = static_cast<uint8_t>(iLength + 0xC0); // Recolour layer type of block.
		*pDest++ = 0xFF; // Use special table 0xFF (which uses the palette as table).
		*pDest++ = 0xFF; // Non-transparent.
		std::memcpy(pDest, pPixelData, iLength);
		pDest += iLength;
		pPixelData += iLength;
		iPixelDataLength -= iLength;
	}
	return pData;
}