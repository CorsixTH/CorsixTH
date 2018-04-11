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

class font;
class level_map;
class render_target;
class sprite_sheet;

class map_overlay
{
public:
    virtual ~map_overlay() = default;

    virtual void draw_cell(render_target* pCanvas, int iCanvasX, int iCanvasY,
                          const level_map* pMap, int iNodeX, int iNodeY) = 0;
};

class map_overlay_pair : public map_overlay
{
public:
    map_overlay_pair();
    virtual ~map_overlay_pair();

    void set_first(map_overlay* pOverlay, bool bTakeOwnership);
    void set_second(map_overlay* pOverlay, bool bTakeOwnership);

    void draw_cell(render_target* pCanvas, int iCanvasX, int iCanvasY,
                  const level_map* pMap, int iNodeX, int iNodeY) override;

private:
    map_overlay *first, *second;
    bool owns_first, owns_second;
};

class map_typical_overlay : public map_overlay
{
public:
    map_typical_overlay();
    virtual ~map_typical_overlay();

    void set_sprites(sprite_sheet* pSheet, bool bTakeOwnership);
    void set_font(::font* font, bool take_ownership);

protected:
    void draw_text(render_target* pCanvas, int iX, int iY, std::string str);

    sprite_sheet* sprites;
    ::font* font;

private:
    bool owns_sprites;
    bool owns_font;
};

class map_text_overlay : public map_typical_overlay
{
public:
    map_text_overlay();
    virtual ~map_text_overlay() = default;

    virtual void draw_cell(render_target* pCanvas, int iCanvasX, int iCanvasY,
        const level_map* pMap, int iNodeX, int iNodeY);

    void set_background_sprite(size_t iSprite);
    virtual const std::string get_text(const level_map* pMap, int iNodeX, int iNodeY) = 0;

private:
    size_t background_sprite;
};

class map_positions_overlay final : public map_text_overlay
{
public:
    const std::string get_text(const level_map* pMap, int iNodeX, int iNodeY) override;
};

class map_flags_overlay final : public map_typical_overlay
{
public:
    void draw_cell(render_target* pCanvas, int iCanvasX, int iCanvasY,
                  const level_map* pMap, int iNodeX, int iNodeY) override;
};

class map_parcels_overlay final : public map_typical_overlay
{
public:
    void draw_cell(render_target* pCanvas, int iCanvasX, int iCanvasY,
                  const level_map* pMap, int iNodeX, int iNodeY) override;
};

#endif
