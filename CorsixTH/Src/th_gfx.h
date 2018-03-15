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

class lua_persist_reader;
class lua_persist_writer;

enum class scaled_items {
    none,
    sprite_sheets,
    bitmaps,
    all
};

#include "th_gfx_sdl.h"
#include "th_gfx_font.h"
#include <vector>
#include <map>
#include <string>

void clip_rect_intersection(clip_rect& rcClip, const clip_rect& rcIntersect);

//! Bitflags for drawing operations
enum draw_flags : uint32_t
{
    /** Sprite drawing flags **/
    /* Where possible, designed to be the same values used by TH data files */

    //! Draw with the left becoming the right and vice versa
    thdf_flip_horizontal = 1 <<  0,
    //! Draw with the top becoming the bottom and vice versa
    thdf_flip_vertical   = 1 <<  1,
    //! Draw with 50% transparency
    thdf_alpha_50        = 1 <<  2,
    //! Draw with 75% transparency
    thdf_alpha_75        = 1 <<  3,
    //! Draw using a remapped palette
    thdf_alt_palette     = 1 <<  4,

    /** How to draw alternative palette in 32bpp. */
    /* A 3 bit field (bits 5,6,7), currently 2 bits used. */

    //! Lowest bit of the field.
    thdf_alt32_start = 5,
    //! Mask for the 32bpp alternative drawing values.
    thdf_alt32_mask = 0x7 << thdf_alt32_start,

    //! Draw the sprite with the normal palette (fallback option).
    thdf_alt32_plain = 0 << thdf_alt32_start,
    //! Draw the sprite in grey scale.
    thdf_alt32_grey_scale = 1 << thdf_alt32_start,
    //! Draw the sprite with red and blue colours swapped.
    thdf_alt32_blue_red_swap = 2 << thdf_alt32_start,

    /** Object attached to tile flags **/
    /* (should be set prior to attaching to a tile) */

    //! Attach to the early sprite list (right-to-left pass)
    thdf_early_list = 1 << 10,
    //! Keep this sprite at the bottom of the attached list
    thdf_list_bottom = 1 << 11,
    //! Hit-test using bounding-box precision rather than pixel-perfect
    thdf_bound_box_hit_test = 1 << 12,
    //! Apply a cropping operation prior to drawing
    thdf_crop = 1 << 13,
};

/** Helper structure with parameters to create a #THRenderTarget. */
struct render_target_creation_params
{
    int width;              ///< Expected width of the render target.
    int height;             ///< Expected height of the render target.
    int bpp;                ///< Expected colour depth of the render target.
    bool fullscreen;        ///< Run full-screen.
    bool present_immediate; ///< Whether to present immediately to the user (else wait for Vsync).
};

/*!
    Base class for a linked list of drawable objects.
    Note that "object" is used as a generic term, not in specific reference to
    game objects (though they are the most common thing in drawing lists).
*/
// TODO: Replace this struct with something cleaner
struct drawable : public link_list
{
    //! Draw the object at a specific point on a render target
    /*!
        Can also "draw" the object to the speakers, i.e. play sounds.
    */
    void (*draw_fn)(drawable* pSelf, render_target* pCanvas, int iDestX, int iDestY);

    //! Perform a hit test against the object
    /*!
        Should return true if when the object is drawn at (iDestX, iDestY) on a canvas,
        the point (iTestX, iTestY) is within / on the object.
    */
    bool (*hit_test_fn)(drawable* pSelf, int iDestX, int iDestY, int iTestX, int iTestY);

    //! Drawing flags (zero or more list flags from #draw_flags).
    uint32_t flags;

    /** Returns true if instance is a multiple frame animation.
        Should be overloaded in derived class.
    */
    bool (*is_multiple_frame_animation_fn)(drawable *pSelf);
};

/*!
    Utility class for decoding Theme Hospital "chunked" graphics files.
    Generally used internally by sprite_sheet.
*/
class chunk_renderer
{
public:
    //! Initialise a renderer for a specific size result
    /*!
        @param width Pixel width of the resulting image
        @param height Pixel height of the resulting image
        @param buffer If nullptr, then a new buffer is created to render the image
          onto. Otherwise, should be an array at least width*height in size.
          Ownership of this pointer is assumed by the class - call takeData()
          to take ownership back again.
    */
    chunk_renderer(int width, int height, uint8_t *buffer = nullptr);

    ~chunk_renderer();

    // TODO: Should be function, not method of chunk_renderer
    //! Convert a stream of chunks into a raw bitmap
    /*!
        @param pData Stream data.
        @param iDataLen Length of \a pData.
        @param bComplex true if pData is a stream of "complex" chunks, false if
          pData is a stream of "simple" chunks. Passing the wrong value will
          usually result in a very visible wrong result.

        Use getData() or takeData() to obtain the resulting bitmap.
    */
    void decode_chunks(const uint8_t* pData, int iDataLen, bool bComplex);

    //! Get the result buffer, and take ownership of it
    /*!
        This transfers ownership of the buffer to the caller. After calling,
        the class will not have any buffer, and thus cannot be used for
        anything.
    */
    uint8_t* take_data();

    //! Get the result buffer
    inline const uint8_t* get_data() const {return data;}

    //! Perform a "copy" chunk (normally called by decodeChunks)
    void chunk_copy(int npixels, const uint8_t* in_data);

    //! Perform a "fill" chunk (normally called by decodeChunks)
    void chunk_fill(int npixels, uint8_t value);

    //! Perform a "fill to end of line" chunk (normally called by decodeChunks)
    void chunk_fill_to_end_of_line(uint8_t value);

    //! Perform a "fill to end of file" chunk (normally called by decodeChunks)
    void chunk_finish(uint8_t value);

private:
    inline bool is_done() {return ptr == end;}
    inline void fix_n_pixels(int& npixels) const;
    inline void increment_position(int npixels);

    uint8_t *data, *ptr, *end;
    int x, y, width, height;
    bool skip_eol;
};

//! Layer information (see animation_manager::draw_frame)
struct layers
{
    uint8_t layer_contents[13];
};

class memory_reader;

/** Key value for finding an animation. */
struct animation_key
{
    std::string name; ///< Name of the animations.
    int tile_size;    ///< Size of a tile.
};

//! Less-than operator for map-sorting.
/*!
    @param oK First key value.
    @param oL Second key value.
    @return Whether \a oK should be before \a oL.
 */
inline bool operator<(const animation_key &oK, const animation_key &oL)
{
    if (oK.tile_size != oL.tile_size) return oK.tile_size < oL.tile_size;
    return oK.name < oL.name;
}

/**
 * Start frames of an animation, in each view direction.
 * A negative number indicates there is no animation in that direction.
 */
struct animation_start_frames
{
    long north; ///< Animation start frame for the 'north' view.
    long east;  ///< Animation start frame for the 'east' view.
    long south; ///< Animation start frame for the 'south' view.
    long west;  ///< Animation start frame for the 'west' view.
};

/** Map holding the custom animations. */
typedef std::map<animation_key, animation_start_frames> named_animations_map;

/** Insertion data structure. */
typedef std::pair<animation_key, animation_start_frames> named_animation_pair;

//! Theme Hospital sprite animation manager
/*!
    An animation manager takes a sprite sheet and four animation information
    files, and uses them to draw animation frames and provide information about
    the animations.
*/
class animation_manager
{
public:
    animation_manager();
    ~animation_manager();

    void set_sprite_sheet(sprite_sheet* pSpriteSheet);

    //! Load original animations.
    /*!
        set_sprite_sheet() must be called before calling this.
        @param pStartData Animation first frame indices (e.g. VSTART-1.ANI)
        @param iStartDataLength Length of \a pStartData.
        @param pFrameData Frame details (e.g. VFRA-1.ANI)
        @param iFrameDataLength Length of \a pFrameData
        @param pListData Element indices list (e.g. VLIST-1.ANI)
        @param iListDataLength Length of \a pListData
        @param pElementData Element details (e.g. VELE-1.ANI)
        @param iElementDataLength Length of \a pElementData
        @return Loading was successful.
    */
    bool load_from_th_file(const uint8_t* pStartData, size_t iStartDataLength,
                           const uint8_t* pFrameData, size_t iFrameDataLength,
                           const uint8_t* pListData, size_t iListDataLength,
                           const uint8_t* pElementData, size_t iElementDataLength);

    //! Set the video target.
    /*!
       @param pCanvas Video surface to use.
     */
    void set_canvas(render_target *pCanvas);

    //! Load free animations.
    /*!
        @param pData Start of the loaded data.
        @param iDataLength Length of the loaded data.
        @return Loading was successful.
    */
    bool load_custom_animations(const uint8_t* pData, size_t iDataLength);

    //! Get the total numer of animations
    size_t get_animation_count() const;

    //! Get the total number of animation frames
    size_t get_frame_count() const;

    //! Get the index of the first frame of an animation
    size_t get_first_frame(size_t iAnimation) const;

    //! Get the index of the frame after a given frame
    /*!
        To draw an animation frame by frame, call get_first_frame() to get the
        index of the first frame, and then keep on calling get_next_frame() using
        the most recent return value from get_next_frame() or get_first_frame().
    */
    size_t get_next_frame(size_t iFrame) const;

    //! Set the palette remap data for an animation
    /*!
        This sets the palette remap data for every single sprite used by the
        given animation. If the animation (or any of its sprites) are drawn
        using the thdf_alt_palette flag, then palette indices will be mapped to
        new palette indices by the 256 byte array pMap. This is typically used
        to draw things in different colours or in greyscale.
    */
    void set_animation_alt_palette_map(size_t iAnimation, const uint8_t* pMap, uint32_t iAlt32);

    //! Draw an animation frame
    /*!
        @param pCanvas The render target to draw onto.
        @param iFrame The frame index to draw (should be in range [0, getFrameCount() - 1])
        @param oLayers Information to decide what to draw on each layer.
            An animation is comprised of up to thirteen layers, numbered 0
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
    void draw_frame(render_target* pCanvas, size_t iFrame,
                    const ::layers& oLayers,
                    int iX, int iY, uint32_t iFlags) const;

    void get_frame_extent(size_t iFrame, const ::layers& oLayers,
                          int* pMinX, int* pMaxX, int* pMinY, int* pMaxY,
                          uint32_t iFlags) const;
    size_t get_frame_sound(size_t iFrame);

    bool hit_test(size_t iFrame, const ::layers& oLayers,
                  int iX, int iY, uint32_t iFlags, int iTestX, int iTestY) const;

    bool set_frame_marker(size_t iFrame, int iX, int iY);
    bool set_frame_secondary_marker(size_t iFrame, int iX, int iY);
    bool get_frame_marker(size_t iFrame, int* pX, int* pY);
    bool get_frame_secondary_marker(size_t iFrame, int* pX, int* pY);

    //! Retrieve a custom animation by name and tile size.
    /*!
        @param sName Name of the animation.
        @param iTilesize Tile size of the animation.
        @return A set starting frames for the queried animation.
     */
    const animation_start_frames &get_named_animations(const std::string &sName, int iTilesize) const;

private:
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(push)
#pragma pack(1)
#endif
    // Animation information structure reinterpreted from Theme Hospital data.
    struct th_animation_properties
    {
        uint16_t first_frame;
        // It could be that frame is a uint32_t rather than a uint16_t, which
        // would resolve the following unknown (which seems to always be zero).
        uint16_t unknown;
    } CORSIX_TH_PACKED_FLAGS;

    // Frame information structure reinterpreted from Theme Hospital data.
    struct th_frame_properties
    {
        uint32_t list_index;
        // These fields have something to do with width and height, but it's
        // not clear quite exactly how.
        uint8_t width;
        uint8_t height;
        // If non-zero, index into sound.dat filetable.
        uint8_t sound;
        // Combination of zero or more fame_flags values
        uint8_t flags;
        uint16_t next;
    } CORSIX_TH_PACKED_FLAGS;

    // Structure reinterpreted from Theme Hospital data.
    struct th_element_properties
    {
        uint16_t table_position;
        uint8_t offx;
        uint8_t offy;
        // High nibble: The layer which the element belongs to [0, 12]
        // Low  nibble: Zero or more draw_flags
        uint8_t flags;
        // The layer option / layer id
        uint8_t layerid;
    } CORSIX_TH_PACKED_FLAGS;
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(pop)
#endif

    struct frame
    {
        size_t list_index;       ///< First entry in #element_list (pointing to an element) for this frame.
        size_t next_frame;       ///< Number of the next frame.
        unsigned int sound;     ///< Sound to play, if non-zero.
        unsigned int flags;     ///< Flags of the frame. Bit 0=start of animation.

        // Bounding rectangle is with all layers / options enabled - used as a
        // quick test prior to a full pixel perfect test.
        int bounding_left;       ///< Left edge of the bounding rectangle of this frame.
        int bounding_right;      ///< Right edge of the bounding rectangle of this frame.
        int bounding_top;        ///< Top edge of the bounding rectangle of this frame.
        int bounding_bottom;     ///< Bottom edge of the bounding rectangle of this frame.

        // Markers are used to know where humanoids are on an frame. The
        // positions are pixels offsets from the centre of the frame's base
        // tile to the centre of the humanoid's feet.
        int marker_x;            ///< X position of the first center of a humanoids feet.
        int marker_y;            ///< Y position of the first center of a humanoids feet.
        int secondary_marker_x;   ///< X position of the second center of a humanoids feet.
        int secondary_marker_y;   ///< Y position of the second center of a humanoids feet.
    };

    struct element
    {
        size_t sprite;    ///< Sprite number of the sprite sheet to display.
        uint32_t flags;   ///< Flags of the sprite.
                           ///< bit 0=flip vertically, bit 1=flip horizontally,
                           ///< bit 2=draw 50% alpha, bit 3=draw 75% alpha.
        int x;            ///< X offset of the sprite.
        int y;            ///< Y offset of the sprite.
        uint8_t layer;    ///< Layer class (0..12).
        uint8_t layer_id; ///< Value of the layer class to match.

        sprite_sheet *element_sprite_sheet; ///< Sprite sheet to use for this element.
    };

    std::vector<size_t> first_frames;          ///< First frame number of an animation.
    std::vector<frame> frames;                 ///< The loaded frames.
    std::vector<uint16_t> element_list;        ///< List of elements for a frame.
    std::vector<element> elements;             ///< Sprite Elements.
    std::vector<sprite_sheet *> custom_sheets; ///< Sprite sheets with custom graphics.
    named_animations_map named_animations;     ///< Collected named animations.

    sprite_sheet* sheet;       ///< Sprite sheet to use.
    render_target *canvas;     ///< Video surface to use.

    size_t animation_count;    ///< Number of animations.
    size_t frame_count;        ///< Number of frames.
    size_t element_list_count; ///< Number of list elements.
    size_t element_count;      ///< Number of sprite elements.

    //! Compute the bounding box of the frame.
    /*!
        @param oFrame Frame to inspect/set.
     */
    void set_bounding_box(frame &oFrame);

    //! Load sprite elements from the input.
    /*!
        @param [inout] input Data to read.
        @param pSpriteSheet Sprite sheet to use.
        @param iNumElements Number of elements to read.
        @param [inout] iLoadedElements Number of loaded elements so far.
        @param iElementStart Offset of the first element.
        @param iElementCount Number of elements to load.
        @return Index of the first loaded element in #elements. Negative value means failure.
     */
    size_t load_elements(memory_reader &input, sprite_sheet *pSpriteSheet,
                         size_t iNumElements, size_t &iLoadedElements,
                         size_t iElementStart, size_t iElementCount);

    //! Construct a list element for every element, and a 0xFFFF at the end.
    /*!
        @param iFirstElement Index of the first element in #elements.
        @param iNumElements Number of elements to add.
        @param [inout] iLoadedListElements Number of created list elements so far.
        @param iListStart Offset of the first created list element.
        @param iListCount Expected number of list elements to create.
        @return Index of the list elements, or a negative value to indicate failure.
     */
    size_t make_list_elements(size_t iFirstElement, size_t iNumElements,
                              size_t &iLoadedListElements,
                              size_t iListStart, size_t iListCount);

    //! Fix the flags of the first frame, and set the next frame of the last frame back to the first frame.
    /*!
        @param iFirst First frame of the animation, or 0xFFFFFFFFu.
        @param iLength Number of frames in the animation.
     */
    void fix_next_frame(uint32_t iFirst, size_t iLength);
};

struct map_tile;
class animation_base : public drawable
{
public:
    animation_base();

    void remove_from_tile();
    void attach_to_tile(map_tile *pMapNode, int layer);

    uint32_t get_flags() const {return flags;}
    int get_x() const {return x_relative_to_tile;}
    int get_y() const {return y_relative_to_tile;}

    void set_flags(uint32_t iFlags) {flags = iFlags;}
    void set_position(int iX, int iY) {x_relative_to_tile = iX, y_relative_to_tile = iY;}
    void set_layer(int iLayer, int iId);
    void set_layers_from(const animation_base *pSrc) {layers = pSrc->layers;}

   // bool isMultipleFrameAnimation() { return false;}
protected:
    //! X position on tile (not tile x-index)
    int x_relative_to_tile;
    //! Y position on tile (not tile y-index)
    int y_relative_to_tile;

    ::layers layers;
};

class animation : public animation_base
{
public:
    animation();

    void set_parent(animation *pParent);

    void tick();
    void draw(render_target* pCanvas, int iDestX, int iDestY);
    bool hit_test(int iDestX, int iDestY, int iTestX, int iTestY);
    void draw_morph(render_target* pCanvas, int iDestX, int iDestY);
    bool hit_test_morph(int iDestX, int iDestY, int iTestX, int iTestY);
    void draw_child(render_target* pCanvas, int iDestX, int iDestY);
    bool hit_test_child(int iDestX, int iDestY, int iTestX, int iTestY);

    link_list* get_previous() {return prev;}
    size_t get_animation() const {return animation_index;}
    bool get_marker(int* pX, int* pY);
    bool get_secondary_marker(int* pX, int* pY);
    size_t get_frame() const {return frame_index;}
    int get_crop_column() const {return crop_column;}

    void set_animation(animation_manager* pManager, size_t iAnimation);
    void set_morph_target(animation *pMorphTarget, unsigned int iDurationFactor = 1);
    void set_frame(size_t iFrame);

    void set_speed(int iX, int iY) {speed.dx = iX, speed.dy = iY;}
    void set_crop_column(int iColumn) {crop_column = iColumn;}

    void persist(lua_persist_writer *pWriter) const;
    void depersist(lua_persist_reader *pReader);

    animation_manager* get_animation_manager(){ return manager;}
private:
    animation_manager *manager;
    animation* morph_target;
    size_t animation_index; ///< Animation number.
    size_t frame_index;     ///< Frame number.
    union {
        struct {
            //! Amount to change x per tick
            int dx;
            //! Amount to change y per tick
            int dy;
        } speed;
        //! Some animations are tied to the marker of another animation and
        //! hence have a parent rather than a speed.
        animation* parent;
    };

    size_t sound_to_play;
    int crop_column;
};

class sprite_render_list : public animation_base
{
public:
    sprite_render_list();
    ~sprite_render_list();

    void tick();
    void draw(render_target* pCanvas, int iDestX, int iDestY);
    bool hit_test(int iDestX, int iDestY, int iTestX, int iTestY);

    void set_sheet(sprite_sheet* pSheet) {sheet = pSheet;}
    void set_speed(int iX, int iY) {dx_per_tick = iX, dy_per_tick = iY;}
    void set_lifetime(int iLifetime);
    void append_sprite(size_t iSprite, int iX, int iY);
    bool is_dead() const {return lifetime == 0;}

    void persist(lua_persist_writer *pWriter) const;
    void depersist(lua_persist_reader *pReader);

private:
    struct sprite
    {
        size_t index;
        int x;
        int y;
    };

    sprite_sheet* sheet;
    sprite* sprites;
    int sprite_count;
    int buffer_size;

    //! Amount to change x per tick
    int dx_per_tick;
    //! Amount to change y per tick
    int dy_per_tick;
    //! Number of ticks until reports as dead (-1 = never dies)
    int lifetime;
};

#endif // CORSIX_TH_TH_GFX_H_
