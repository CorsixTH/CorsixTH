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

#include "th_map_overlays.h"

#include <array>
#include <list>
#include <sstream>
#include <string>
#include <string_view>

#include "th_gfx_font.h"
#include "th_gfx_sdl.h"
#include "th_map.h"

map_overlay_pair::~map_overlay_pair() {
  set_first(nullptr, false);
  set_second(nullptr, false);
}

void map_overlay_pair::set_first(map_overlay* pOverlay, bool bTakeOwnership) {
  if (first && owns_first) {
    delete first;
  }
  first = pOverlay;
  owns_first = bTakeOwnership;
}

void map_overlay_pair::set_second(map_overlay* pOverlay, bool bTakeOwnership) {
  if (second && owns_second) {
    delete second;
  }
  second = pOverlay;
  owns_second = bTakeOwnership;
}

void map_overlay_pair::draw_cell(render_target* pCanvas, int iCanvasX,
                                 int iCanvasY, const level_map* pMap,
                                 int iNodeX, int iNodeY) {
  if (first) {
    first->draw_cell(pCanvas, iCanvasX, iCanvasY, pMap, iNodeX, iNodeY);
  }
  if (second) {
    second->draw_cell(pCanvas, iCanvasX, iCanvasY, pMap, iNodeX, iNodeY);
  }
}

void map_text_overlay::set_background_sprite(size_t iSprite) {
  background_sprite = iSprite;
}

void map_text_overlay::draw_cell(render_target* pCanvas, int iCanvasX,
                                 int iCanvasY, const level_map* pMap,
                                 int iNodeX, int iNodeY) {
  if (sprites && background_sprite) {
    sprites->draw_sprite(pCanvas, background_sprite, iCanvasX, iCanvasY, 0);
  }
  if (font) {
    draw_text(pCanvas, iCanvasX, iCanvasY, get_text(pMap, iNodeX, iNodeY));
  }
}

const std::string map_positions_overlay::get_text(const level_map* pMap,
                                                  int iNodeX, int iNodeY) {
  std::ostringstream str;
  str << iNodeX + 1 << ',' << iNodeY + 1;
  return str.str();
}

map_typical_overlay::~map_typical_overlay() {
  set_sprites(nullptr, false);
  set_font(nullptr, false);
}

void map_flags_overlay::draw_cell(render_target* pCanvas, int iCanvasX,
                                  int iCanvasY, const level_map* pMap,
                                  int iNodeX, int iNodeY) {
  const map_tile* pNode = pMap->get_tile(iNodeX, iNodeY);
  if (!pNode) {
    return;
  }
  if (sprites) {
    if (pNode->flags.passable) {
      sprites->draw_sprite(pCanvas, 3, iCanvasX, iCanvasY, 0);
    }
    if (pNode->flags.hospital) {
      sprites->draw_sprite(pCanvas, 8, iCanvasX, iCanvasY, 0);
    }
    if (pNode->flags.buildable) {
      sprites->draw_sprite(pCanvas, 9, iCanvasX, iCanvasY, 0);
    }
    if (pNode->flags.can_travel_n &&
        pMap->get_tile(iNodeX, iNodeY - 1)->flags.passable) {
      sprites->draw_sprite(pCanvas, 4, iCanvasX, iCanvasY, 0);
    }
    if (pNode->flags.can_travel_e &&
        pMap->get_tile(iNodeX + 1, iNodeY)->flags.passable) {
      sprites->draw_sprite(pCanvas, 5, iCanvasX, iCanvasY, 0);
    }
    if (pNode->flags.can_travel_s &&
        pMap->get_tile(iNodeX, iNodeY + 1)->flags.passable) {
      sprites->draw_sprite(pCanvas, 6, iCanvasX, iCanvasY, 0);
    }
    if (pNode->flags.can_travel_w &&
        pMap->get_tile(iNodeX - 1, iNodeY)->flags.passable) {
      sprites->draw_sprite(pCanvas, 7, iCanvasX, iCanvasY, 0);
    }
  }
  if (font) {
    if (!pNode->objects.empty()) {
      std::ostringstream str;
      str << 'T' << static_cast<int>(pNode->objects.front());
      draw_text(pCanvas, iCanvasX, iCanvasY - 8, str.str());
    }
    if (pNode->iRoomId) {
      std::ostringstream str;
      str << 'R' << static_cast<int>(pNode->iRoomId);
      draw_text(pCanvas, iCanvasX, iCanvasY + 8, str.str());
    }
  }
}

namespace {

// The sprite to include if the tile in the direction indicated by dx,dy is
// not from the same parcel.
struct parcel_edge_sprite {
  int dx;
  int dy;
  size_t sprite;
};

// Parcel edge sprites for all four directions
constexpr std::array<parcel_edge_sprite, 4> parcel_edges{
    {{0, -1, 18}, {1, 0, 19}, {0, 1, 20}, {-1, 0, 21}}};

}  // namespace

void map_parcels_overlay::draw_cell(render_target* pCanvas, int iCanvasX,
                                    int iCanvasY, const level_map* pMap,
                                    int iNodeX, int iNodeY) {
  const map_tile* pNode = pMap->get_tile(iNodeX, iNodeY);
  if (!pNode) {
    return;
  }
  if (font) {
    draw_text(pCanvas, iCanvasX, iCanvasY, std::to_string(pNode->iParcelId));
  }
  if (sprites) {
    for (const parcel_edge_sprite& dir_sprite : parcel_edges) {
      const map_tile* dir_node =
          pMap->get_tile(iNodeX + dir_sprite.dx, iNodeY + dir_sprite.dy);
      if (!dir_node || dir_node->iParcelId == pNode->iParcelId) {
        sprites->draw_sprite(pCanvas, dir_sprite.sprite, iCanvasX, iCanvasY, 0);
      }
    }
  }
}

void map_typical_overlay::draw_text(render_target* pCanvas, int iX, int iY,
                                    const std::string_view str) {
  text_layout oArea = font->get_text_dimensions(str.data(), str.length());
  font->draw_text(pCanvas, str.data(), str.length(),
                  iX + (64 - oArea.end_x) / 2, iY + (32 - oArea.end_y) / 2);
}

void map_typical_overlay::set_sprites(sprite_sheet* pSheet,
                                      bool bTakeOwnership) {
  if (sprites && owns_sprites) {
    delete sprites;
  }
  sprites = pSheet;
  owns_sprites = bTakeOwnership;
}

void map_typical_overlay::set_font(::font* font, bool take_ownership) {
  if (this->font && owns_font) {
    delete this->font;
  }
  this->font = font;
  owns_font = take_ownership;
}
