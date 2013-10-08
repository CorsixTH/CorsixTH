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

#ifndef IMAGE_H
#define IMAGE_H

typedef unsigned char uint8;
typedef unsigned int uint32;

class Image32bpp
{
public:
    Image32bpp(int iWidth, int iHeight);
    ~Image32bpp();

    uint32 Get(int offset) const;

    int iWidth;
    int iHeight;
    uint32 *pData;
};

class Image8bpp
{
public:
    Image8bpp(int iWidth, int iHeight);
    ~Image8bpp();

    unsigned char Get(int offset) const;

    int iWidth;
    int iHeight;
    uint8 *pData;
};

uint8 GetR(uint32 rgba);
uint8 GetG(uint32 rgba);
uint8 GetB(uint32 rgba);
uint8 GetA(uint32 rgba);

Image32bpp *Load32Bpp(const std::string &sFilename, int line, int left, int width, int top, int height);
Image8bpp *Load8Bpp(const std::string &sFilename, int line, int left, int width, int top, int height);

#endif

// vim: et sw=4 ts=4 sts=4
