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

/*
    Note that this file contains similar functionality to th.h / th_gfx.h from
    the main CorsixTH project. It is reimplemented rather than reused for good
    reasons:
     1) Animations need to be rendered onto a wxWidgets canvas rather than onto
         an SDL or DirectX canvas.
     2) Modifications and experimentation can be performed on this version
         before being implemented on the game copy, resulting in better code
         when the game version is implemented.
     3) Simplicity rather than speed is the aim of this copy, so it will render
         slower than the game copy, but will be easier to understand and make
         changes to.
*/

#pragma once
#include <wx/string.h>
#include <wx/file.h>
#include <wx/image.h>
#include <wx/txtstrm.h>
#include "tinyxml.h"
#ifdef _MSC_VER
typedef signed __int8 int8_t;
typedef signed __int16 int16_t;
typedef signed __int32 int32_t;
typedef unsigned __int8 uint8_t;
typedef unsigned __int16 uint16_t;
typedef unsigned __int32 uint32_t;
#else
#include <stdint.h>
#endif // _MSC_VER

#pragma pack(push)
#pragma pack(1)

struct th_anim_t
{
    uint16_t frame;
    uint16_t unknown;
};

struct th_frame_t
{
    uint32_t list_index;
    uint8_t width;
    uint8_t height;
    uint16_t flags;
    uint16_t next;
};

struct th_element_t
{
    uint16_t table_position;
    uint8_t offx;
    uint8_t offy;
    uint8_t flags;
    uint8_t layerid;
};

struct th_sprite_t
{
    uint32_t offset;
    uint8_t width;
    uint8_t height;
};

struct th_colour_t
{
    uint8_t r;
    uint8_t g;
    uint8_t b;
};

#pragma pack(pop)

class THLayerMask
{
public:
    THLayerMask();

    inline void set(int iLayer, int iID)
    {
        if(0 <= iLayer && iLayer < 13 && 0 <= iID && iID < 32)
            m_iMask[iLayer] |= (1 << iID);
    }

    void clear();

    inline void clear(int iLayer, int iID)
    {
        if(0 <= iLayer && iLayer < 13 && 0 <= iID && iID < 32)
            m_iMask[iLayer] &= ~(1 << iID);
    }

    inline bool isSet(int iLayer, int iID) const
    {
        if(0 <= iLayer && iLayer < 13 && 0 <= iID && iID < 32)
            return (m_iMask[iLayer] & (1 << iID)) != 0;
        else
            return false;
    }
    inline bool isSet(int iLayer) const
    {
        if(0 <= iLayer && iLayer < 13)
            for(int iId = 0; iId < 32; ++iId)
            {
                if((m_iMask[iLayer] & (1 << iId)) != 0)
                    return true;
            }
        return false;
    }

protected:
    uint32_t m_iMask[13];
};

class Bitmap
{
public:
    Bitmap();
    ~Bitmap();

    void create(int iWidth, int iHeight);
    void create(int iWidth, int iHeight, const uint8_t* pData);

    inline uint8_t pixel(int iX, int iY) const {return m_pData[iY * m_iWidth + iX];}
    inline uint8_t& pixel(int iX, int iY) {return m_pData[iY * m_iWidth + iX];}

    int getWidth() const {return m_iWidth;}
    int getHeight() const {return m_iHeight;}

    void blit(Bitmap& bmpCanvas, int iX, int iY, int iFlags = 0) const;
    void blit(wxImage& imgCanvas, int iX, int iY, const unsigned char* pColourTranslate, const th_colour_t* pPalette, int iFlags = 0) const;

    bool IsOk() {return m_pData != NULL;}

protected:
    int m_iWidth;
    int m_iHeight;
    uint8_t* m_pData;
};

class THAnimations
{
public:
    THAnimations();
    ~THAnimations();

    bool loadAnimationFile(wxString sFilename) {return _loadArray(m_pAnims, m_iAnimCount, sFilename);}
    bool loadFrameFile(wxString sFilename);
    bool loadListFile(wxString sFilename) {return _loadArray(m_pElementList, m_iElementListCount, sFilename);}
    bool loadElementFile(wxString sFilename) {return _loadArray(m_pElements, m_iElementCount, sFilename);}
    bool loadTableFile(wxString sFilename);
    bool loadSpriteFile(wxString sFilename) {return _loadArray(m_pChunks, m_iChunkCount, sFilename);}
    bool loadPaletteFile(wxString sFilename);
    bool loadGhostFile(wxString sFilename, int iIndex);
    bool loadXMLFile(TiXmlDocument* xmlDocument);

    void writeElementData(wxString aPath, wxTextOutputStream *outputLog, wxTextOutputStream *outputXml,
        size_t iAnimation, size_t iFrame, const THLayerMask* pMask, wxSize& size, int* iListIndex);
    void writeTableDataHeader(wxTextOutputStream *outputLog);

    size_t markDuplicates();

    size_t getAnimationCount();
    size_t getSpriteCount();
    size_t getFrameCount(size_t iAnimation);
    uint16_t getUnknownField(size_t iAnimation) {return m_pAnims[iAnimation].unknown; }
    uint16_t getFrameField(size_t iAnimation) {return m_pAnims[iAnimation].frame; }
    //uint32_t getListIndexField(size_t iFrame) {return m_pFrames[iFrame].list_index; }
    //uint8_t getFrameWidthField(size_t iFrame) {return m_pFrames[iFrame].width; }
    //uint8_t getFrameHeightField(size_t iFrame) {return m_pFrames[iFrame].height; }
    th_frame_t* getFrameStruct(size_t iAnimation, size_t iFrame);
    bool isAnimationDuplicate(size_t iAnimation);
    bool doesAnimationIncludeFrame(size_t iAnimation, size_t iFrame);
    void getAnimationMask(size_t iAnimation, THLayerMask& mskLayers);
    void setSpritePath(wxString aPath);

    Bitmap* getSpriteBitmap(size_t iSprite, bool bComplex = false);
    th_colour_t* getPalette() {return m_pColours;}

    void setGhost(int iFile, int iIndex);
    void drawFrame(wxImage& imgCanvas, size_t iAnimation, size_t iFrame, const THLayerMask* pMask, wxSize& size, int iXOffset = 0, int iYOffset = 0);
    void copySpriteToCanvas(wxString spriteFile, int iSpriteIndex, wxImage& imgCanvas, int iX, int iY, int iFlags = 0);

    static unsigned char* Decompress(unsigned char* pData, size_t& iLength);
protected:
    template <class T>
    bool _loadArray(T*& pArray, size_t& iCount, wxString sFilename)
    {
        if(pArray != NULL)
        {
            delete[] pArray;
            pArray = NULL;
        }
        iCount = 0;

        wxFile oFile(sFilename);
        if(!oFile.IsOpened())
            return false;
        size_t iLen = oFile.Length();
        unsigned char* pBuffer = new unsigned char[iLen];
        oFile.Read(pBuffer, iLen);
        if(memcmp(pBuffer, "RNC\001", 4) == 0)
        {
            pBuffer = Decompress(pBuffer, iLen);
            if(!pBuffer)
            {
                return false;
            }
        }
        pArray = (T*)pBuffer;
        iCount = iLen / sizeof(T);
        return true;
    }
    th_element_t* _getElement(uint32_t iListIndex);

    th_anim_t* m_pAnims;
    th_frame_t* m_pFrames;
    uint16_t* m_pElementList;
    th_element_t* m_pElements;
    th_sprite_t* m_pSprites;
    Bitmap* m_pSpriteBitmaps;
    wxImage* m_pSpriteImages;
    uint8_t* m_pSpriteScaleFactors;
    uint8_t* m_pChunks;
    th_colour_t* m_pColours;
    unsigned char* m_pGhostMaps;
    size_t m_iGhostMapOffset;
    size_t m_iAnimCount;
    size_t m_iFrameCount;
    size_t m_iElementListCount;
    size_t m_iElementCount;
    size_t m_iSpriteCount;
    size_t m_iChunkCount;
    size_t m_iColourCount;
    bool m_bXmlLoaded;
    wxString m_sSpritePath;
};
