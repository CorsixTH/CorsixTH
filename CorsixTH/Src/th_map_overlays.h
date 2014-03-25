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

#ifndef CORSIX_TH_TH_MAP_OVERLAYS_H_
#define CORSIX_TH_TH_MAP_OVERLAYS_H_

class THFont;
class THMap;
class THRenderTarget;
class THSpriteSheet;

class THMapOverlay
{
public:
    virtual ~THMapOverlay();

    virtual void drawCell(THRenderTarget* pCanvas, int iCanvasX, int iCanvasY,
        const THMap* pMap, int iNodeX, int iNodeY) = 0;
};

class THMapOverlayPair : public THMapOverlay
{
public:
    THMapOverlayPair();
    virtual ~THMapOverlayPair();

    void setFirst(THMapOverlay* pOverlay, bool bTakeOwnership);
    void setSecond(THMapOverlay* pOverlay, bool bTakeOwnership);

    virtual void drawCell(THRenderTarget* pCanvas, int iCanvasX, int iCanvasY,
        const THMap* pMap, int iNodeX, int iNodeY);

protected:
    THMapOverlay *m_pFirst, *m_pSecond;
    bool m_bOwnFirst, m_bOwnSecond;
};

class THMapTypicalOverlay : public THMapOverlay
{
public:
    THMapTypicalOverlay();
    virtual ~THMapTypicalOverlay();

    void setSprites(THSpriteSheet* pSheet, bool bTakeOwnership);
    void setFont(THFont* pFont, bool bTakeOwnership);

protected:
    void _drawText(THRenderTarget* pCanvas, int iX, int iY,
        const char* sFormat, ...);

    THSpriteSheet* m_pSprites;
    THFont* m_pFont;
    bool m_bOwnsSprites;
    bool m_bOwnsFont;
};

class THMapTextOverlay : public THMapTypicalOverlay
{
public:
    THMapTextOverlay();

    virtual void drawCell(THRenderTarget* pCanvas, int iCanvasX, int iCanvasY,
        const THMap* pMap, int iNodeX, int iNodeY);

    void setBackgroundSprite(unsigned int iSprite);
    virtual const char* getText(const THMap* pMap, int iNodeX, int iNodeY) = 0;

protected:
    unsigned int m_iBackgroundSprite;
};

class THMapPositionsOverlay : public THMapTextOverlay
{
public:
    virtual const char* getText(const THMap* pMap, int iNodeX, int iNodeY);

protected:
    char m_sBuffer[16];
};

class THMapFlagsOverlay : public THMapTypicalOverlay
{
public:
    virtual void drawCell(THRenderTarget* pCanvas, int iCanvasX, int iCanvasY,
        const THMap* pMap, int iNodeX, int iNodeY);
};

class THMapParcelsOverlay : public THMapTypicalOverlay
{
public:
    virtual void drawCell(THRenderTarget* pCanvas, int iCanvasX, int iCanvasY,
        const THMap* pMap, int iNodeX, int iNodeY);
};

#endif
