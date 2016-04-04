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

#include <cstddef>
#include <string>

class THFont;
class THMap;
class THRenderTarget;
class THSpriteSheet;

class THMapOverlay
{
public:
    virtual ~THMapOverlay() = default;

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

    void drawCell(THRenderTarget* pCanvas, int iCanvasX, int iCanvasY,
                  const THMap* pMap, int iNodeX, int iNodeY) override;

private:
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
    void _drawText(THRenderTarget* pCanvas, int iX, int iY, std::string str);

    THSpriteSheet* m_pSprites;
    THFont* m_pFont;

private:
    bool m_bOwnsSprites;
    bool m_bOwnsFont;
};

class THMapTextOverlay : public THMapTypicalOverlay
{
public:
    THMapTextOverlay();
    virtual ~THMapTextOverlay() = default;

    virtual void drawCell(THRenderTarget* pCanvas, int iCanvasX, int iCanvasY,
        const THMap* pMap, int iNodeX, int iNodeY);

    void setBackgroundSprite(size_t iSprite);
    virtual const std::string getText(const THMap* pMap, int iNodeX, int iNodeY) = 0;

private:
    size_t m_iBackgroundSprite;
};

class THMapPositionsOverlay final : public THMapTextOverlay
{
public:
    const std::string getText(const THMap* pMap, int iNodeX, int iNodeY) override;
};

class THMapFlagsOverlay final : public THMapTypicalOverlay
{
public:
    void drawCell(THRenderTarget* pCanvas, int iCanvasX, int iCanvasY,
                  const THMap* pMap, int iNodeX, int iNodeY) override;
};

class THMapParcelsOverlay final : public THMapTypicalOverlay
{
public:
    void drawCell(THRenderTarget* pCanvas, int iCanvasX, int iCanvasY,
                  const THMap* pMap, int iNodeX, int iNodeY) override;
};

#endif
