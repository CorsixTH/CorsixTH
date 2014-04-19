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

#ifndef CORSIX_TH_TH_GFX_H_
#define CORSIX_TH_TH_GFX_H_
#include "th.h"

class LuaPersistReader;
class LuaPersistWriter;

enum THScaledItems
{
    THSI_None = 0,
    THSI_SpriteSheets = 1 << 0,
    THSI_Bitmaps = 1 << 1,
    THSI_All = 3,
};

#include "th_gfx_sdl.h"
#include "th_gfx_font.h"
#include <stddef.h>

void IntersectTHClipRect(THClipRect& rcClip,const THClipRect& rcIntersect);

//! Bitflags for drawing operations
enum THDrawFlags
{
    /** Sprite drawing flags **/
    /* Where possible, designed to be the same values used by TH data files */

    //! Draw with the left becoming the right and vice versa
    THDF_FlipHorizontal = 1 <<  0,
    //! Draw with the top becoming the bottom and vice versa
    THDF_FlipVertical   = 1 <<  1,
    //! Draw with 50% transparency
    THDF_Alpha50        = 1 <<  2,
    //! Draw with 75% transparency
    THDF_Alpha75        = 1 <<  3,
    //! Draw using a remapped palette
    THDF_AltPalette     = 1 <<  4,

    /** Object attached to tile flags **/
    /* (should be set prior to attaching to a tile) */

    //! Attach to the early sprite list (right-to-left pass)
    THDF_EarlyList      = 1 << 10,
    //! Keep this sprite at the bottom of the attached list
    THDF_ListBottom     = 1 << 11,
    //! Hit-test using bounding-box precision rather than pixel-perfect
    THDF_BoundBoxHitTest= 1 << 12,
    //! Apply a cropping operation prior to drawing
    THDF_Crop           = 1 << 13,
};

//! Bitflags for animation frames
enum THFrameFlags
{
    //! First frame of an animation
    THFF_AnimationStart = 1 << 0,
};

struct THRenderTargetCreationParams
{
    int iWidth;
    int iHeight;
    int iBPP;
    uint32_t iSDLFlags;
    bool bFullscreen;
    bool bPresentImmediate;
    bool bReuseContext;
};

/*!
    Base class for a linked list of drawable objects.
    Note that "object" is used as a generic term, not in specific reference to
    game objects (though they are the most common thing in drawing lists).
*/
struct THDrawable : public THLinkList
{
    //! Draw the object at a specific point on a render target
    /*!
        Can also "draw" the object to the speakers, i.e. play sounds.
    */
    void (*m_fnDraw)(THDrawable* pSelf, THRenderTarget* pCanvas, int iDestX, int iDestY);

    //! Perform a hit test against the object
    /*!
        Should return true if when the object is drawn at (iDestX, iDestY) on a canvas,
        the point (iTestX, iTestY) is within / on the object.
    */
    bool (*m_fnHitTest)(THDrawable* pSelf, int iDestX, int iDestY, int iTestX, int iTestY);

    //! Drawing flags (zero or more list flags from THDrawFlags)
    unsigned long m_iFlags;

    /** Returns true if instance is a multiple frame animation.
        Should be overloaded in derived class.
    */
    bool (*m_fnIsMultipleFrameAnimation)(THDrawable *pSelf);
};

/*!
    Utility class for decoding Theme Hospital "chunked" graphics files.
    Generally used internally by THSpriteSheet.
*/
class THChunkRenderer
{
public:
    //! Initialise a renderer for a specific size result
    /*!
        @param width Pixel width of the resulting image
        @param height Pixel height of the resulting image
        @param buffer If NULL, then a new buffer is created to render the image
          onto. Otherwise, should be an array at least width*height in size.
          Ownership of this pointer is assumed by the class - call takeData()
          to take ownership back again.
    */
    THChunkRenderer(int width, int height, unsigned char *buffer = NULL);

    ~THChunkRenderer();

    //! Convert a stream of chunks into a raw bitmap
    /*!
        @param bComplex true if pData is a stream of "complex" chunks, false if
          pData is a stream of "simple" chunks. Passing the wrong value will
          usually result in a very visible wrong result.

        Use getData() or takeData() to obtain the resulting bitmap.
    */
    void decodeChunks(const unsigned char* pData, int iDataLen, bool bComplex);

    //! Get the result buffer, and take ownership of it
    /*!
        This transfers ownership of the buffer to the caller. After calling,
        the class will not have any buffer, and thus cannot be used for
        anything.
    */
    unsigned char* takeData();

    //! Get the result buffer
    inline const unsigned char* getData() const {return m_data;}

    //! Perform a "copy" chunk (normally called by decodeChunks)
    void chunkCopy(int npixels, const unsigned char* data);

    //! Perform a "fill" chunk (normally called by decodeChunks)
    void chunkFill(int npixels, unsigned char value);

    //! Perform a "fill to end of line" chunk (normally called by decodeChunks)
    void chunkFillToEndOfLine(unsigned char value);

    //! Perform a "fill to end of file" chunk (normally called by decodeChunks)
    void chunkFinish(unsigned char value);

protected:
    inline bool _isDone() {return m_ptr == m_end;}
    inline void _fixNpixels(int& npixels) const;
    inline void _incrementPosition(int npixels);

    unsigned char *m_data, *m_ptr, *m_end;
    int m_x, m_y, m_width, m_height;
    bool m_skip_eol;
};

//! Layer information (see THAnimationManager::drawFrame)
struct THLayers_t
{
    unsigned char iLayerContents[13];
};

//! Theme Hospital sprite animation manager
/*!
    An animation manager takes a sprite sheet and four animation information
    files, and uses them to draw animation frames and provide information about
    the animations.
*/
class THAnimationManager
{
public:
    THAnimationManager();
    ~THAnimationManager();

    void setSpriteSheet(THSpriteSheet* pSpriteSheet);

    //! Load animation information
    /*!
        setSpriteSheet() must be called before calling this.
        @param pStartData Animation first frame indicies (e.g. VSTART-1.ANI)
        @param pFrameData Frame details (e.g. VFRA-1.ANI)
        @param pListData Element indicies list (e.g. VLIST-1.ANI)
        @param pElementData Element details (e.g. VELE-1.ANI)
    */
    bool loadFromTHFile(const unsigned char* pStartData, size_t iStartDataLength,
                        const unsigned char* pFrameData, size_t iFrameDataLength,
                        const unsigned char* pListData, size_t iListDataLength,
                        const unsigned char* pElementData, size_t iElementDataLength);

    //! Get the total numer of animations
    unsigned int getAnimationCount() const;

    //! Get the total number of animation frames
    unsigned int getFrameCount() const;

    //! Get the index of the first frame of an animation
    unsigned int getFirstFrame(unsigned int iAnimation) const;

    //! Get the index of the frame after a given frame
    /*!
        To draw an animation frame by frame, call getFirstFrame() to get the
        index of the first frame, and then keep on calling getNextFrame() using
        the most recent return value from getNextFrame() or getFirstFrame().
    */
    unsigned int getNextFrame(unsigned int iFrame) const;

    //! Set the palette remap data for an animation
    /*!
        This sets the palette remap data for every single sprite used by the
        given animation. If the animation (or any of its sprites) are drawn
        using the THDF_AltPalette flag, then palette indicies will be mapped to
        new palette indicies by the 256 byte array pMap. This is typically used
        to draw things in different colours or in greyscale.
    */
    void setAnimationAltPaletteMap(unsigned int iAnimation, const unsigned char* pMap);

    //! Draw an animation frame
    /*!
        @param pCanvas The render target to draw onto.
        @param iFrame The frame index to draw (should be in range [0, getFrameCount() - 1])
        @param oLayers Information to decide what to draw on each layer.
            An animation is comprised of upto thirteen layers, numbered 0
            through 12. Some animations will have different options for what to
            render on each layer. For example, patient animations generally
            have the different options on layer 1 as different clothes, so if
            layer 1 is set to the value 0, they may have their default clothes,
            and if set to the value 2 or 4 or 6, they may have other clothes.
            Play with the AnimView tool for a better understanding of layers,
            though note that while it can draw more than one option on each
            layer, this class can only draw a single option for each layer.
        @param iX The screen position to use as the animation X origin.
        @param iY The screen position to use as the animation Y origin.
        @param iFlags Zero or more THDrawFlags flags.
    */
    void drawFrame(THRenderTarget* pCanvas, unsigned int iFrame, const THLayers_t& oLayers, int iX, int iY, unsigned long iFlags) const;

    void getFrameExtent(unsigned int iFrame, const THLayers_t& oLayers, int* pMinX, int* pMaxX, int* pMinY, int* pMaxY, unsigned long iFlags) const;
    unsigned int getFrameSound(unsigned int iFrame);

    bool hitTest(unsigned int iFrame, const THLayers_t& oLayers, int iX, int iY, unsigned long iFlags, int iTestX, int iTestY) const;

    bool setFrameMarker(unsigned int iFrame, int iX, int iY);
    bool setFrameSecondaryMarker(unsigned int iFrame, int iX, int iY);
    bool getFrameMarker(unsigned int iFrame, int* pX, int* pY);
    bool getFrameSecondaryMarker(unsigned int iFrame, int* pX, int* pY);

protected:
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(push)
#pragma pack(1)
#endif
    struct th_anim_t
    {
        uint16_t frame;
        // It could be that frame is a uint32_t rather than a uint16_t, which
        // would resolve the following unknown (which seems to always be zero).
        uint16_t unknown;
    } CORSIX_TH_PACKED_FLAGS;

    struct th_frame_t
    {
        uint32_t list_index;
        // These fields have something to do with width and height, but it's
        // not clear quite exactly how.
        uint8_t width;
        uint8_t height;
        // If non-zero, index into sound.dat filetable.
        uint8_t sound;
        // Combination of zero or more THFrameFlags values
        uint8_t flags;
        uint16_t next;
    } CORSIX_TH_PACKED_FLAGS;

    struct th_element_t
    {
        uint16_t table_position;
        uint8_t offx;
        uint8_t offy;
        // High nibble: The layer which the element belongs to [0, 12]
        // Low  nibble: Zero or more THDrawFlags flags
        uint8_t flags;
        // The layer option / layer id
        uint8_t layerid;
    } CORSIX_TH_PACKED_FLAGS;
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(pop)
#endif

    struct frame_t
    {
        unsigned int iListIndex;
        unsigned int iNextFrame;
        unsigned int iSound;
        unsigned int iFlags;
        // Bounding rectangle is with all layers / options enabled - used as a
        // quick test prior to a full pixel perfect test.
        int iBoundingLeft;
        int iBoundingRight;
        int iBoundingTop;
        int iBoundingBottom;
        // Markers are used to know where humanoids are on an frame. The
        // positions are pixels offsets from the centre of the frame's base
        // tile to the centre of the humanoid's feet.
        int iMarkerX;
        int iMarkerY;
        int iSecondaryMarkerX;
        int iSecondaryMarkerY;
    };

    struct element_t
    {
        unsigned int iSprite;
        unsigned int iFlags;
        int iX;
        int iY;
        unsigned char iLayer;
        unsigned char iLayerId;
    };

    unsigned int* m_pFirstFrames;
    frame_t* m_pFrames;
    uint16_t* m_pElementList;
    element_t* m_pElements;
    THSpriteSheet* m_pSpriteSheet;

    unsigned int m_iAnimationCount;
    unsigned int m_iFrameCount;
    unsigned int m_iElementCount;
};

struct THMapNode;
class THAnimationBase : public THDrawable
{
public:
    THAnimationBase();

    void removeFromTile();
    void attachToTile(THMapNode *pMapNode, int layer);

    unsigned long getFlags() const {return m_iFlags;}
    int getX() const {return m_iX;}
    int getY() const {return m_iY;}

    void setFlags(unsigned long iFlags) {m_iFlags = iFlags;}
    void setPosition(int iX, int iY) {m_iX = iX, m_iY = iY;}
    void setLayer(int iLayer, int iId);
    void setLayersFrom(const THAnimationBase *pSrc) {m_oLayers = pSrc->m_oLayers;}

   // bool isMultipleFrameAnimation() { return false;}
protected:
    void _clear();

    //! X position on tile (not tile x-index)
    int m_iX;
    //! Y position on tile (not tile y-index)
    int m_iY;

    THLayers_t m_oLayers;

};

class THAnimation : public THAnimationBase
{
public:
    THAnimation();

    void setParent(THAnimation *pParent);

    void tick();
    void draw(THRenderTarget* pCanvas, int iDestX, int iDestY);
    bool hitTest(int iDestX, int iDestY, int iTestX, int iTestY);
    void drawMorph(THRenderTarget* pCanvas, int iDestX, int iDestY);
    bool hitTestMorph(int iDestX, int iDestY, int iTestX, int iTestY);
    void drawChild(THRenderTarget* pCanvas, int iDestX, int iDestY);
    bool hitTestChild(int iDestX, int iDestY, int iTestX, int iTestY);

    THLinkList* getPrevious() {return m_pPrev;}
    unsigned int getAnimation() const {return m_iAnimation;}
    bool getMarker(int* pX, int* pY);
    bool getSecondaryMarker(int* pX, int* pY);
    unsigned int getFrame() const {return m_iFrame;}
    int getCropColumn() const {return m_iCropColumn;}

    void setAnimation(THAnimationManager* pManager, unsigned int iAnimation);
    void setMorphTarget(THAnimation *pMorphTarget, unsigned int iDurationFactor = 1);
    void setFrame(unsigned int iFrame);

    void setSpeed(int iX, int iY) {m_iSpeedX = iX, m_iSpeedY = iY;}
    void setCropColumn(int iColumn) {m_iCropColumn = iColumn;}

    void persist(LuaPersistWriter *pWriter) const;
    void depersist(LuaPersistReader *pReader);

    THAnimationManager* getAnimationManager(){ return m_pManager;}
protected:
    THAnimationManager *m_pManager;
    THAnimation* m_pMorphTarget;
    unsigned int m_iAnimation;
    unsigned int m_iFrame;
    union { struct {
        //! Amount to change m_iX per tick
        int m_iSpeedX;
        //! Amount to change m_iY per tick
        int m_iSpeedY;
    };
        //! Some animations are tied to the marker of another animation and
        //! hence have a parent rather than a speed.
        THAnimation* m_pParent;
    };

    unsigned int m_iSoundToPlay;
    int m_iCropColumn;
};

class THSpriteRenderList : public THAnimationBase
{
public:
    THSpriteRenderList();
    ~THSpriteRenderList();

    void tick();
    void draw(THRenderTarget* pCanvas, int iDestX, int iDestY);
    bool hitTest(int iDestX, int iDestY, int iTestX, int iTestY);

    void setSheet(THSpriteSheet* pSheet) {m_pSpriteSheet = pSheet;}
    void setSpeed(int iX, int iY) {m_iSpeedX = iX, m_iSpeedY = iY;}
    void setLifetime(int iLifetime);
    void appendSprite(unsigned int iSprite, int iX, int iY);
    bool isDead() const {return m_iLifetime == 0;}

    void persist(LuaPersistWriter *pWriter) const;
    void depersist(LuaPersistReader *pReader);

protected:
    struct _sprite_t
    {
        unsigned int iSprite;
        int iX;
        int iY;
    };

    THSpriteSheet* m_pSpriteSheet;
    _sprite_t* m_pSprites;
    int m_iNumSprites;
    int m_iBufferSize;

    //! Amount to change m_iX per tick
    int m_iSpeedX;
    //! Amount to change m_iY per tick
    int m_iSpeedY;
    //! Number of ticks until reports as dead (-1 = never dies)
    int m_iLifetime;
};

#endif // CORSIX_TH_TH_GFX_H_
