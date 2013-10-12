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
#include <cstdlib>
#include <cassert>
#include <string>
#include <png.h>
#include "image.h"

uint32 MakeRGBA(uint8 r, uint8 g, uint8 b, uint8 a)
{
    assert(sizeof(uint32) == 4); // Not really the good place, but it has to be checked somewhere!

    uint32 ret;
    uint32 x;
    x = r; ret = x;
    x = g; ret |= (x << 8);
    x = b; ret |= (x << 16);
    x = a; ret |= (x << 24);
    return ret;
}

uint8 GetR(uint32 rgba) { return  rgba        & 0xFF; }
uint8 GetG(uint32 rgba) { return (rgba >> 8)  & 0xFF; }
uint8 GetB(uint32 rgba) { return (rgba >> 16) & 0xFF; }
uint8 GetA(uint32 rgba) { return (rgba >> 24) & 0xFF; }


Image32bpp::Image32bpp(int iWidth, int iHeight)
{
    this->iWidth = iWidth;
    this->iHeight = iHeight;
    pData = (uint32 *)malloc(4 * iWidth * iHeight);
}

Image32bpp::~Image32bpp()
{
    free(pData);
}

uint32 Image32bpp::Get(int offset) const
{
    int x, y;
    y = offset / iWidth;
    x = offset - y * iWidth;
    assert(x >= 0 && x < iWidth && y >= 0 && y < iHeight);
    return pData[offset];
}


Image8bpp::Image8bpp(int iWidth, int iHeight)
{
    this->iWidth = iWidth;
    this->iHeight = iHeight;
    pData = (uint8 *)malloc(iWidth * iHeight);
}

Image8bpp::~Image8bpp()
{
    free(pData);
}

unsigned char Image8bpp::Get(int offset) const
{
    int x, y;
    y = offset / iWidth;
    x = offset - y * iWidth;
    assert(x >= 0 && x < iWidth && y >= 0 && y < iHeight);
    return pData[offset];
}

static void OpenFile(const std::string &sFilename, png_structp *pngPtr, png_infop *infoPtr, png_infop *endInfo, uint8 ***pRows)
{
    FILE *pFile = fopen(sFilename.c_str(), "rb");
    if(pFile == NULL)
    {
        fprintf(stderr, "PNG file \"%s\" could not be opened.\n", sFilename.c_str());
        exit(1);
    }

    unsigned char header[4];
    if(fread(header, 1, 4, pFile) != 4)
    {
        fprintf(stderr, "Could not read header of \"%s\".\n", sFilename.c_str());
        fclose(pFile);
        exit(1);
    }
    bool bIsPng = !png_sig_cmp(header, 0, 4);
    if(!bIsPng)
    {
        fprintf(stderr, "Header of \"%s\" indicates it is not a PNG file.\n", sFilename.c_str());
        fclose(pFile);
        exit(1);
    }

    *pngPtr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!*pngPtr)
    {
        fprintf(stderr, "Could not initialize PNG data.\n");
        fclose(pFile);
        exit(1);
    }
    *infoPtr = png_create_info_struct(*pngPtr);
    if(!*infoPtr)
    {
        fprintf(stderr, "Could not initialize PNG info data.\n");
        png_destroy_read_struct(pngPtr, (png_infopp)NULL, (png_infopp)NULL);
        fclose(pFile);
        exit(1);
    }

    *endInfo = png_create_info_struct(*pngPtr);
    if(!*endInfo)
    {
        fprintf(stderr, "Could not initialize PNG end data.\n");
        png_destroy_read_struct(pngPtr, infoPtr, (png_infopp)NULL);
        fclose(pFile);
        exit(1);
    }

    /* Setup callback in case of errors. */
    if(setjmp(png_jmpbuf(*pngPtr))) {
        fprintf(stderr, "Error detected while reading PNG file.\n");
        png_destroy_read_struct(pngPtr, infoPtr, endInfo);
        fclose(pFile);
        exit(1);
    }

    /* Initialize for file reading. */
    png_init_io(*pngPtr, pFile);
    png_set_sig_bytes(*pngPtr, 4);

    png_read_png(*pngPtr, *infoPtr, PNG_TRANSFORM_IDENTITY, NULL);
    *pRows = png_get_rows(*pngPtr, *infoPtr);
    fclose(pFile);
}


Image32bpp *Load32Bpp(const std::string &sFilename, int line, int left, int width, int top, int height)
{
    png_structp pngPtr;
    png_infop infoPtr;
    png_infop endInfo;
    uint8 **pRows;
    OpenFile(sFilename, &pngPtr, &infoPtr, &endInfo, &pRows);

    int iWidth = png_get_image_width(pngPtr, infoPtr);
    int iHeight = png_get_image_height(pngPtr, infoPtr);
    int iBitDepth = png_get_bit_depth(pngPtr, infoPtr);
    int iColorType = png_get_color_type(pngPtr, infoPtr);

    if (iWidth < left + width)
    {
        fprintf(stderr, "Sprite at line %d: Sprite is not wide enough, require %d columns (%d + %d) while only %d columns are available.\n", line, left + width, left, width, iWidth);
        exit(1);
    }
    if (iHeight < top + height)
    {
        fprintf(stderr, "Sprite at line %d: Sprite is not high enough, require %d rows (%d + %d) while only %d rows are available.\n", line, top + height, top, height, iHeight);
        exit(1);
    }

    if (iBitDepth != 8)
    {
        fprintf(stderr, "Sprite at line %d: \"%s\" is not an 32bpp file (channels are not 8 bit wide)\n", line, sFilename.c_str());
        png_destroy_read_struct(&pngPtr, &infoPtr, &endInfo);
        exit(1);
    }
    if (iColorType != PNG_COLOR_TYPE_RGB_ALPHA)
    {
        fprintf(stderr, "Sprite at line %d: \"%s\" is not an RGBA file\n", line, sFilename.c_str());
        png_destroy_read_struct(&pngPtr, &infoPtr, &endInfo);
        exit(1);
    }

    Image32bpp *img = new Image32bpp(width, height);
    uint32 *pData = img->pData;
    for (int i = 0; i < height; i++)
    {
        uint8 *pRow = pRows[top + i] + left;
        for (int j = 0; j < width; j++)
        {
            *pData++ = MakeRGBA(pRow[0], pRow[1], pRow[2], pRow[3]);
            pRow += 4;
        }
    }

    png_destroy_read_struct(&pngPtr, &infoPtr, &endInfo);
    return img;
}

Image8bpp *Load8Bpp(const std::string &sFilename, int line, int left, int width, int top, int height)
{
    png_structp pngPtr;
    png_infop infoPtr;
    png_infop endInfo;
    uint8 **pRows;
    OpenFile(sFilename, &pngPtr, &infoPtr, &endInfo, &pRows);

    int iWidth = png_get_image_width(pngPtr, infoPtr);
    int iHeight = png_get_image_height(pngPtr, infoPtr);
    int iBitDepth = png_get_bit_depth(pngPtr, infoPtr);
    int iColorType = png_get_color_type(pngPtr, infoPtr);

    if (iWidth < left + width)
    {
        fprintf(stderr, "Sprite at line %d: Sprite is not wide enough, require %d columns (%d + %d) while only %d columns are available.\n", line, left + width, left, width, iWidth);
        exit(1);
    }
    if (iHeight < top + height)
    {
        fprintf(stderr, "Sprite at line %d: Sprite is not high enough, require %d rows (%d + %d) while only %d rows are available.\n", line, top + height, top, height, iHeight);
        exit(1);
    }

    if (iBitDepth != 8)
    {
        fprintf(stderr, "Sprite at line %d: \"%s\" is not an 8bpp file (the channel is not 8 bit wide\n", line, sFilename.c_str());
        png_destroy_read_struct(&pngPtr, &infoPtr, &endInfo);
        exit(1);
    }
    if (iColorType != PNG_COLOR_TYPE_PALETTE)
    {
        fprintf(stderr, "Sprite at line %d: \"%s\" is not a palleted image file\n", line, sFilename.c_str());
        png_destroy_read_struct(&pngPtr, &infoPtr, &endInfo);
        exit(1);
    }

    Image8bpp *img = new Image8bpp(width, height);
    uint8 *pData = img->pData;
    for (int i = 0; i < height; i++)
    {
        int y = top + i;
        for (int j = 0; j < width; j++)
        {
            int x = left + j;
            uint8 v = pRows[y][x];
            *pData = v;
            pData++;
        }
    }
    return img;
}

// vim: et sw=4 ts=4 sts=4
