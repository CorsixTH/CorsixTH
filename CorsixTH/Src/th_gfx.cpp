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

#include "th_gfx.h"

#include "config.h"

#include <algorithm>
#include <cassert>
#include <climits>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <new>

#include "persist_lua.h"
#include "th_gfx_sdl.h"
#include "th_lua.h"
#include "th_map.h"
#include "th_sound.h"

/** Data retrieval class, simulating sequential access to the data, keeping
 * track of available length. */
class memory_reader {
 public:
  memory_reader(const uint8_t* pData, const size_t iLength)
      : data(pData), remaining_bytes(iLength) {}

  const uint8_t* data;     ///< Pointer to the remaining data.
  size_t remaining_bytes;  ///< Remaining number of bytes.

  //! Can \a iSize bytes be read from the file?
  /*!
      @param iSize Number of bytes that are queried.
      @return Whether the requested number of bytes is still available.
   */
  bool are_bytes_available(size_t iSize) const {
    return iSize <= remaining_bytes;
  }

  //! Is EOF reached?
  /*!
      @return Whether EOF has been reached.
   */
  bool is_at_end_of_file() const { return remaining_bytes == 0; }

  //! Get an 8 bit value from the file.
  /*!
      @return Read 8 bit value.
      @pre There should be at least a byte available for reading.
   */
  uint8_t read_uint8() {
    assert(remaining_bytes > 0);

    uint8_t iVal = *data;
    data++;
    remaining_bytes--;
    return iVal;
  }

  //! Get a 16 bit value from the file.
  /*!
      @return Read 16 bit value.
      @pre There should be at least 2 bytes available for reading.
   */
  uint16_t read_uint16() {
    uint16_t iVal = read_uint8();
    uint16_t iVal2 = read_uint8();
    return static_cast<uint16_t>(iVal | (iVal2 << 8));
  }

  //! Get a signed 16 bit value from the file.
  /*!
      @return The read signed 16 bit value.
      @pre There should be at least 2 bytes available for reading.
   */
  int read_int16() {
    int val = read_uint16();
    if (val < 0x7FFF) return val;

    int ret = -1;
    return (ret & ~0xFFFF) | val;
  }

  //! Get a 32 bit value from the file.
  /*!
      @return Read 32 bit value.
      @pre There should be at least 4 bytes available for reading.
   */
  uint32_t read_uint32() {
    uint32_t iVal = read_uint16();
    uint32_t iVal2 = read_uint16();
    return iVal | (iVal2 << 16);
  }

  //! Load string from the memory_reader.
  /*!
      @param [out] pStr String to load.
      @return Whether the string could be loaded.
   */
  bool read_string(std::string* pStr) {
    char buff[256];

    if (is_at_end_of_file()) {
      return false;
    }

    size_t iLength = read_uint8();
    if (!are_bytes_available(iLength)) {
      return false;
    }

    size_t idx;
    for (idx = 0; idx < iLength; idx++) {
      buff[idx] = read_uint8();
    }
    buff[idx] = '\0';
    *pStr = std::string(buff);

    return true;
  }
};

animation_manager::animation_manager()
    : sheet(nullptr),
      canvas(nullptr),
      animation_count(0),
      frame_count(0),
      element_list_count(0),
      element_count(0),
      game_ticks(0) {}

void animation_manager::set_sprite_sheet(sprite_sheet* pSpriteSheet) {
  sheet = pSpriteSheet;
}

constexpr size_t bytes_per_animation_property = 4;

// Frame information structure reinterpreted from Theme Hospital data.
// https://github.com/CorsixTH/theme-hospital-spec/blob/master/format-specification.md#frame
struct th_frame_properties {
  constexpr static size_t size = 10;

  explicit th_frame_properties(const uint8_t* pData)
      : list_index{bytes_to_uint32_le(pData)},
        // skipping width and height (1 byte each)
        sound{pData[6]},
        flags{pData[7]},
        next{bytes_to_uint16_le(pData + 8)} {}

  uint32_t list_index;
  uint8_t sound;
  uint8_t flags;
  uint16_t next;
};

// Structure reinterpreted from Theme Hospital data.
// https://github.com/CorsixTH/theme-hospital-spec/blob/master/format-specification.md#spriteelement
struct th_element_properties {
  constexpr static size_t size = 6;

  explicit th_element_properties(const uint8_t* pData)
      : table_position{bytes_to_uint16_le(pData)},
        offset_x{pData[2]},
        offset_y{pData[3]},
        layer{static_cast<uint8_t>(pData[4] >> 4)},
        flags{static_cast<uint8_t>(pData[4] & 0xF)},
        layer_id{pData[5]} {}

  uint16_t table_position;
  uint8_t offset_x;
  uint8_t offset_y;
  uint8_t layer;  // High nibble of byte 4
  uint8_t flags;  // Low nibble of byte 4
  uint8_t layer_id;
};

bool animation_manager::load_from_th_file(
    const uint8_t* pStartData, size_t iStartDataLength,
    const uint8_t* pFrameData, size_t iFrameDataLength,
    const uint8_t* pListData, size_t iListDataLength,
    const uint8_t* pElementData, size_t iElementDataLength) {
  size_t iAnimationCount = iStartDataLength / bytes_per_animation_property;
  size_t iFrameCount = iFrameDataLength / th_frame_properties::size;
  size_t iListCount = iListDataLength / 2;
  size_t iElementCount = iElementDataLength / th_element_properties::size;

  if (iAnimationCount == 0 || iFrameCount == 0 || iListCount == 0 ||
      iElementCount == 0) {
    return false;
  }

  // Start offset of the file data into the vectors.
  size_t iAnimationStart = animation_count;
  size_t iFrameStart = frame_count;
  size_t iListStart = element_list_count;
  size_t iElementStart = element_count;

  // Original data file must start at offset 0 due to the hard-coded animation
  // numbers in the Lua code.
  if (iAnimationStart > 0 || iFrameStart > 0 || iListStart > 0 ||
      iElementStart > 0) {
    return false;
  }

  // Overflow of list elements.
  if (iElementStart + iElementCount >= 0xFFFF) {
    return false;
  }

  // Create new space for the data.
  first_frames.reserve(iAnimationStart + iAnimationCount);
  frames.reserve(iFrameStart + iFrameCount);
  element_list.reserve(iListStart + iListCount + 1);
  elements.reserve(iElementStart + iElementCount);

  // Read animations.
  for (size_t i = 0; i < iAnimationCount; ++i) {
    size_t iFirstFrame =
        bytes_to_uint16_le(pStartData + i * bytes_per_animation_property);
    if (iFirstFrame > iFrameCount) {
      iFirstFrame = 0;
    }

    iFirstFrame += iFrameStart;
    first_frames.push_back(iFirstFrame);
  }

  // Read frames.
  for (size_t i = 0; i < iFrameCount; ++i) {
    const th_frame_properties thFrame(pFrameData +
                                      i * th_frame_properties::size);

    frame oFrame;
    oFrame.list_index =
        iListStart + (thFrame.list_index < iListCount ? thFrame.list_index : 0);
    oFrame.next_frame =
        iFrameStart + (thFrame.next < iFrameCount ? thFrame.next : 0);
    oFrame.sound = thFrame.sound;
    oFrame.flags = thFrame.flags;
    // Bounding box fields initialised later
    oFrame.primary_marker_x = 0;
    oFrame.primary_marker_y = 0;
    oFrame.secondary_marker_x = 0;
    oFrame.secondary_marker_y = 0;

    frames.push_back(oFrame);
  }

  // Read the element list.
  for (size_t i = 0; i < iListCount; ++i) {
    uint16_t iElmNumber = bytes_to_uint16_le(pListData + i * 2);
    if (iElmNumber >= iElementCount) {
      iElmNumber = 0xFFFF;
    } else {
      iElmNumber = static_cast<uint16_t>(iElmNumber + iElementStart);
    }

    element_list.push_back(iElmNumber);
  }
  element_list.push_back(0xFFFF);

  // Read elements.
  size_t iSpriteCount = sheet->get_sprite_count();
  for (size_t i = 0; i < iElementCount; ++i) {
    const th_element_properties thElement(pElementData +
                                          i * th_element_properties::size);

    element oElement;
    oElement.sprite =
        thElement.table_position / 6;  // sprite table entries are 6 bytes
    oElement.flags = thElement.flags;
    oElement.x = static_cast<int>(thElement.offset_x) - 141;
    oElement.y = static_cast<int>(thElement.offset_y) - 186;
    oElement.layer = thElement.layer;

    if (oElement.layer >= max_number_of_layers) {
      // Nothing lives on layer 6
      oElement.layer = 6;
    }
    oElement.layer_id = thElement.layer_id;
    if (oElement.sprite < iSpriteCount) {
      oElement.element_sprite_sheet = sheet;
    } else {
      oElement.element_sprite_sheet = nullptr;
    }

    elements.push_back(oElement);
  }

  // Compute bounding box of the animations using the sprite sheet.
  for (size_t i = 0; i < iFrameCount; ++i) {
    set_bounding_box(frames[iFrameStart + i]);
  }

  animation_count += iAnimationCount;
  frame_count += iFrameCount;
  element_list_count += iListCount + 1;
  element_count += iElementCount;

  assert(first_frames.size() == animation_count);
  assert(frames.size() == frame_count);
  assert(element_list.size() == element_list_count);
  assert(elements.size() == element_count);

  return true;
}

namespace {

//! Update \a iLeft with the smallest of both values.
/*!
    @param [inout] iLeft Left value to check and update.
    @param iRight Second value to check.
 */
void set_left_to_min(int& iLeft, int iRight) {
  if (iRight < iLeft) iLeft = iRight;
}

//! Update \a iLeft with the biggest of both values.
/*!
    @param [inout] iLeft Left value to check and update.
    @param iRight Second value to check.
 */
void set_left_to_max(int& iLeft, int iRight) {
  if (iRight > iLeft) iLeft = iRight;
}

}  // namespace

void animation_manager::set_bounding_box(frame& oFrame) {
  oFrame.bounding_left = INT_MAX;
  oFrame.bounding_right = INT_MIN;
  oFrame.bounding_top = INT_MAX;
  oFrame.bounding_bottom = INT_MIN;

  size_t iListIndex = oFrame.list_index;
  for (;; ++iListIndex) {
    uint16_t iElement = element_list[iListIndex];
    if (iElement >= elements.size()) {
      break;
    }

    element& oElement = elements[iElement];
    if (oElement.element_sprite_sheet == nullptr) {
      continue;
    }

    int iWidth;
    int iHeight;
    oElement.element_sprite_sheet->get_sprite_size_unchecked(oElement.sprite,
                                                             &iWidth, &iHeight);
    set_left_to_min(oFrame.bounding_left, oElement.x);
    set_left_to_min(oFrame.bounding_top, oElement.y);
    set_left_to_max(oFrame.bounding_right, oElement.x - 1 + (int)iWidth);
    set_left_to_max(oFrame.bounding_bottom, oElement.y - 1 + (int)iHeight);
  }
}

void animation_manager::set_canvas(render_target* pCanvas) { canvas = pCanvas; }

namespace {

//! Load the header.
/*!
    @param [inout] input Data to read.
    @return Number of consumed bytes, a negative number indicates an error.
 */
int load_header(memory_reader& input) {
  static const uint8_t aHdr[] = {'C', 'T', 'H', 'G', 1, 2};

  if (!input.are_bytes_available(6)) {
    return false;
  }

  for (int i = 0; i < 6; i++) {
    if (input.read_uint8() != aHdr[i]) {
      return false;
    }
  }
  return true;
}

}  // namespace

size_t animation_manager::load_elements(
    memory_reader& input, sprite_sheet* pSpriteSheet, size_t iNumElements,
    size_t& iLoadedElements, size_t iElementStart, size_t iElementCount) {
  size_t iFirst = iLoadedElements + iElementStart;

  size_t iSpriteCount = pSpriteSheet->get_sprite_count();
  while (iNumElements > 0) {
    if (iLoadedElements >= iElementCount || !input.are_bytes_available(12)) {
      return SIZE_MAX;
    }

    size_t iSprite = input.read_uint32();
    int iX = input.read_int16();
    int iY = input.read_int16();
    uint8_t iLayerClass = input.read_uint8();
    uint8_t iLayerId = input.read_uint8();
    uint32_t iFlags = input.read_uint16();

    if (iLayerClass >= max_number_of_layers) {
      // Nothing lives on layer 6
      iLayerClass = 6;
    }

    element oElement;
    oElement.sprite = iSprite;
    oElement.flags = iFlags;
    oElement.x = iX;
    oElement.y = iY;
    oElement.layer = iLayerClass;
    oElement.layer_id = iLayerId;
    if (oElement.sprite >= iSpriteCount)
      oElement.element_sprite_sheet = nullptr;
    else
      oElement.element_sprite_sheet = pSpriteSheet;

    elements.push_back(oElement);
    iLoadedElements++;
    iNumElements--;
  }
  return iFirst;
}

size_t animation_manager::make_list_elements(size_t iFirstElement,
                                             size_t iNumElements,
                                             size_t& iLoadedListElements,
                                             size_t iListStart,
                                             size_t iListCount) {
  size_t iFirst = iLoadedListElements + iListStart;

  // Verify there is enough room for all list elements + 0xFFFF
  if (iLoadedListElements + iNumElements + 1 > iListCount) {
    return SIZE_MAX;
  }

  // Overflow for list elements.
  assert(iFirstElement + iNumElements < 0xFFFF);

  while (iNumElements > 0) {
    element_list.push_back(static_cast<uint16_t>(iFirstElement));
    iLoadedListElements++;
    iFirstElement++;
    iNumElements--;
  }
  // Add 0xFFFF.
  element_list.push_back(0xFFFF);
  iLoadedListElements++;

  return iFirst;
}

namespace {

//! Shift the first frame if all frames are available.
/*!
    @param iFirst First frame number, or 0xFFFFFFFFu if no animation.
    @param iLength Number of frames in the animation.
    @param iStart Start of the frames for this file.
    @param iLoaded Number of loaded frames.
    @return The shifted first frame, or 0xFFFFFFFFu.
 */
uint32_t shift_first(uint32_t iFirst, size_t iLength, size_t iStart,
                     size_t iLoaded) {
  if (iFirst == 0xFFFFFFFFu || iFirst + iLength > iLoaded) {
    return 0xFFFFFFFFu;
  }
  return iFirst + static_cast<uint32_t>(iStart);
}

}  // namespace

void animation_manager::fix_next_frame(uint32_t iFirst, size_t iLength) {
  if (iFirst == 0xFFFFFFFFu) {
    return;
  }

  frame& oFirst = frames[iFirst];
  oFirst.flags |= 0x1;  // Start of animation flag.

  frame& oLast = frames[iFirst + iLength - 1];
  oLast.next_frame = iFirst;  // Loop last frame back to the first.
}

bool animation_manager::load_custom_animations(const uint8_t* pData,
                                               size_t iDataLength) {
  memory_reader input(pData, iDataLength);

  if (!load_header(input)) {
    return false;
  }

  if (!input.are_bytes_available(5 * 4)) {
    return false;
  }

  size_t iAnimationCount = input.read_uint32();
  size_t iFrameCount = input.read_uint32();
  size_t iElementCount = input.read_uint32();
  size_t iSpriteCount = input.read_uint32();
  input.read_uint32();  // Total number of bytes sprite data is not used.

  // Every element is referenced once, and one 0xFFFF for every frame.
  size_t iListCount = iElementCount + iFrameCount;

  size_t iFrameStart = frame_count;
  size_t iListStart = element_list_count;
  size_t iElementStart = element_count;

  if (iAnimationCount == 0 || iFrameCount == 0 || iElementCount == 0 ||
      iSpriteCount == 0) {
    return false;
  }

  // Overflow of list elements.
  if (iElementStart + iElementCount >= 0xFFFF) {
    return false;
  }

  // Create new space for the elements.
  // Be optimistic in reservation.
  first_frames.reserve(first_frames.size() + iAnimationCount * 4);
  frames.reserve(iFrameStart + iFrameCount);
  element_list.reserve(iListStart + iListCount);
  elements.reserve(iElementStart + iElementCount);

  // Construct a sprite sheet for the sprites to be loaded.
  sprite_sheet pSheet;
  pSheet.set_sprite_count(iSpriteCount, canvas);
  custom_sheets.push_back(pSheet);

  size_t iLoadedFrames = 0;
  size_t iLoadedListElements = 0;
  size_t iLoadedElements = 0;
  size_t iLoadedSprites = 0;

  // Read the blocks of the file, until hitting EOF.
  for (;;) {
    if (input.is_at_end_of_file()) break;

    // Read identification bytes at the start of each block, and dispatch
    // loading.
    if (!input.are_bytes_available(2)) return false;
    int first = input.read_uint8();
    int second = input.read_uint8();

    // Recognized a grouped animation block, load it.
    if (first == 'C' && second == 'A') {
      animation_key oKey;

      if (!input.are_bytes_available(2 + 4)) {
        return false;
      }

      oKey.tile_size = input.read_uint16();
      size_t iNumFrames = input.read_uint32();
      if (iNumFrames == 0) {
        return false;
      }

      if (!input.read_string(&oKey.name)) {
        return false;
      }

      if (!input.are_bytes_available(4 * 4)) {
        return false;
      }

      uint32_t iNorthFirst = input.read_uint32();
      uint32_t iEastFirst = input.read_uint32();
      uint32_t iSouthFirst = input.read_uint32();
      uint32_t iWestFirst = input.read_uint32();

      iNorthFirst =
          shift_first(iNorthFirst, iNumFrames, iFrameStart, iLoadedFrames);
      iEastFirst =
          shift_first(iEastFirst, iNumFrames, iFrameStart, iLoadedFrames);
      iSouthFirst =
          shift_first(iSouthFirst, iNumFrames, iFrameStart, iLoadedFrames);
      iWestFirst =
          shift_first(iWestFirst, iNumFrames, iFrameStart, iLoadedFrames);

      animation_start_frames oFrames;
      if (iNorthFirst != 0xFFFFFFFFu) {
        fix_next_frame(iNorthFirst, iNumFrames);
        oFrames.north = static_cast<long>(first_frames.size());
        first_frames.push_back(iNorthFirst);
      }
      if (iEastFirst != 0xFFFFFFFFu) {
        fix_next_frame(iEastFirst, iNumFrames);
        oFrames.east = static_cast<long>(first_frames.size());
        first_frames.push_back(iEastFirst);
      }
      if (iSouthFirst != 0xFFFFFFFFu) {
        fix_next_frame(iSouthFirst, iNumFrames);
        oFrames.south = static_cast<long>(first_frames.size());
        first_frames.push_back(iSouthFirst);
      }
      if (iWestFirst != 0xFFFFFFFFu) {
        fix_next_frame(iWestFirst, iNumFrames);
        oFrames.west = static_cast<long>(first_frames.size());
        first_frames.push_back(iWestFirst);
      }

      named_animation_pair p(oKey, oFrames);
      named_animations.insert(p);
      continue;
    } else if (first == 'F' && second == 'R') {
      // Recognized a frame block, load it.

      if (iLoadedFrames >= iFrameCount) {
        return false;
      }

      if (!input.are_bytes_available(2 + 2)) {
        return false;
      }

      int iSound = input.read_uint16();
      size_t iNumElements = input.read_uint16();

      size_t iElm = load_elements(input, &pSheet, iNumElements, iLoadedElements,
                                  iElementStart, iElementCount);
      if (iElm == SIZE_MAX) {
        return false;
      }

      size_t iListElm = make_list_elements(
          iElm, iNumElements, iLoadedListElements, iListStart, iListCount);
      if (iListElm == SIZE_MAX) {
        return false;
      }

      frame oFrame;
      oFrame.list_index = iListElm;

      // Point to next frame.
      // Last frame of each animation corrected later.
      oFrame.next_frame = iFrameStart + iLoadedFrames + 1;

      oFrame.sound = iSound;

      // Set later
      oFrame.flags = 0;
      oFrame.primary_marker_x = 0;
      oFrame.primary_marker_y = 0;
      oFrame.secondary_marker_x = 0;
      oFrame.secondary_marker_y = 0;

      set_bounding_box(oFrame);

      frames.push_back(oFrame);
      iLoadedFrames++;
      continue;
    } else if (first == 'S' && second == 'P') {
      // Recognized a Sprite block, load it.

      if (iLoadedSprites >= iSpriteCount) {
        return false;
      }

      if (!input.are_bytes_available(2 + 2 + 4)) {
        return false;
      }

      int iWidth = input.read_uint16();
      int iHeight = input.read_uint16();
      uint32_t iSize = input.read_uint32();

      // Check it is safe to use as 'int'
      if (iSize > INT_MAX) {
        return false;
      }

      // Load data.
      uint8_t* pData = new (std::nothrow) uint8_t[iSize];
      if (pData == nullptr) {
        return false;
      }

      if (!input.are_bytes_available(iSize)) {
        delete[] pData;
        return false;
      }

      for (uint32_t i = 0; i < iSize; i++) {
        pData[i] = input.read_uint8();
      }

      if (!pSheet.set_sprite_data(iLoadedSprites, pData, true, iSize, iWidth,
                                  iHeight)) {
        return false;
      }

      iLoadedSprites++;
      continue;
    } else {
      // Unrecognized block, fail.
      return false;
    }
  }

  assert(iLoadedFrames == iFrameCount);
  assert(iLoadedListElements == iListCount);
  assert(iLoadedElements == iElementCount);
  assert(iLoadedSprites == iSpriteCount);

  // Fix the next pointer of the last frame in case it points to non-existing
  // frames.
  frame& oFrame = frames[iFrameStart + iFrameCount - 1];
  if (iFrameCount > 0 && oFrame.next_frame >= iFrameStart + iFrameCount) {
    // Useless, but maybe less crashy.
    oFrame.next_frame = iFrameStart;
  }

  animation_count = first_frames.size();
  frame_count += iFrameCount;
  element_list_count += iListCount;
  element_count += iElementCount;
  assert(frames.size() == frame_count);
  assert(element_list.size() == element_list_count);
  assert(elements.size() == element_count);

  return true;
}

const animation_start_frames& animation_manager::get_named_animations(
    const std::string_view sName, const int iTilesize) const {
  static const animation_start_frames oNoneAnimations = {-1, -1, -1, -1};

  animation_key oKey;
  oKey.name = sName;
  oKey.tile_size = iTilesize;

  named_animations_map::const_iterator iter = named_animations.find(oKey);
  if (iter == named_animations.end()) {
    return oNoneAnimations;
  }
  return (*iter).second;
}

size_t animation_manager::get_animation_count() const {
  return animation_count;
}

size_t animation_manager::get_frame_count() const { return frame_count; }

size_t animation_manager::get_first_frame(size_t iAnimation) const {
  if (iAnimation < animation_count) {
    return first_frames[iAnimation];
  } else {
    return 0;
  }
}

size_t animation_manager::get_next_frame(size_t iFrame) const {
  if (iFrame < frame_count) {
    return frames[iFrame].next_frame;
  } else {
    return iFrame;
  }
}

void animation_manager::set_animation_alt_palette_map(size_t iAnimation,
                                                      const uint8_t* pMap,
                                                      uint32_t iAlt32) {
  if (iAnimation >= animation_count) {
    return;
  }

  size_t iFrame = first_frames[iAnimation];
  size_t iFirstFrame = iFrame;
  do {
    size_t iListIndex = frames[iFrame].list_index;
    for (;; ++iListIndex) {
      uint16_t iElement = element_list[iListIndex];
      if (iElement >= element_count) {
        break;
      }

      element& oElement = elements[iElement];
      if (oElement.element_sprite_sheet != nullptr) {
        oElement.element_sprite_sheet->set_sprite_alt_palette_map(
            oElement.sprite, pMap, iAlt32);
      }
    }
    iFrame = frames[iFrame].next_frame;
  } while (iFrame != iFirstFrame);
}

bool animation_manager::set_frame_primary_marker(size_t iFrame, int iX,
                                                 int iY) {
  if (iFrame >= frame_count) {
    return false;
  }

  frames[iFrame].primary_marker_x = iX;
  frames[iFrame].primary_marker_y = iY;
  return true;
}

bool animation_manager::set_frame_secondary_marker(size_t iFrame, int iX,
                                                   int iY) {
  if (iFrame >= frame_count) {
    return false;
  }

  frames[iFrame].secondary_marker_x = iX;
  frames[iFrame].secondary_marker_y = iY;
  return true;
}

bool animation_manager::get_frame_primary_marker(size_t iFrame, int* pX,
                                                 int* pY) {
  if (iFrame >= frame_count) {
    return false;
  }

  *pX = frames[iFrame].primary_marker_x;
  *pY = frames[iFrame].primary_marker_y;
  return true;
}

bool animation_manager::get_frame_secondary_marker(size_t iFrame, int* pX,
                                                   int* pY) {
  if (iFrame >= frame_count) {
    return false;
  }

  *pX = frames[iFrame].secondary_marker_x;
  *pY = frames[iFrame].secondary_marker_y;
  return true;
}

void animation_manager::tick() { ++game_ticks; }

bool animation_manager::hit_test(size_t iFrame, const ::layers& oLayers, int iX,
                                 int iY, uint32_t iFlags, int iTestX,
                                 int iTestY) const {
  if (iFrame >= frame_count) {
    return false;
  }

  const frame& oFrame = frames[iFrame];
  iTestX -= iX;
  iTestY -= iY;

  if (iFlags & thdf_flip_horizontal) {
    iTestX = -iTestX;
  }

  if (iTestX < oFrame.bounding_left || iTestX > oFrame.bounding_right) {
    return false;
  }

  if (iFlags & thdf_flip_vertical) {
    if (-iTestY < oFrame.bounding_top || -iTestY > oFrame.bounding_bottom) {
      return false;
    }
  } else {
    if (iTestY < oFrame.bounding_top || iTestY > oFrame.bounding_bottom) {
      return false;
    }
  }

  if (iFlags & thdf_bound_box_hit_test) {
    return true;
  }

  size_t iListIndex = oFrame.list_index;
  for (;; ++iListIndex) {
    uint16_t iElement = element_list[iListIndex];
    if (iElement >= element_count) {
      break;
    }

    const element& oElement = elements[iElement];
    if ((oElement.layer_id != 0 &&
         oLayers.layer_contents[oElement.layer] != oElement.layer_id) ||
        oElement.element_sprite_sheet == nullptr) {
      continue;
    }

    if (iFlags & thdf_flip_horizontal) {
      int iWidth;
      int iHeight;
      oElement.element_sprite_sheet->get_sprite_size_unchecked(
          oElement.sprite, &iWidth, &iHeight);
      if (oElement.element_sprite_sheet->hit_test_sprite(
              oElement.sprite, oElement.x + iWidth - iTestX,
              iTestY - oElement.y, oElement.flags ^ thdf_flip_horizontal)) {
        return true;
      }
    } else {
      if (oElement.element_sprite_sheet->hit_test_sprite(
              oElement.sprite, iTestX - oElement.x, iTestY - oElement.y,
              oElement.flags)) {
        return true;
      }
    }
  }

  return false;
}

void animation_manager::draw_frame(render_target* pCanvas, size_t iFrame,
                                   const ::layers& oLayers, int iX, int iY,
                                   uint32_t iFlags,
                                   animation_effect patient_effect,
                                   size_t patient_effect_offset) const {
  if (iFrame >= frame_count) {
    return;
  }

  uint32_t iPassOnFlags = iFlags & thdf_alt_palette;

  size_t iListIndex = frames[iFrame].list_index;
  for (;; ++iListIndex) {
    uint16_t iElement = element_list[iListIndex];
    if (iElement >= element_count) {
      break;
    }

    const element& oElement = elements[iElement];
    if (oElement.element_sprite_sheet == nullptr) {
      continue;
    }

    if (oElement.layer_id != 0 &&
        oLayers.layer_contents[oElement.layer] != oElement.layer_id) {
      // Some animations involving doctors (i.e. #72, #74, maybe others)
      // only provide versions for heads W1 and B1, not W2 and B2. The
      // quickest way to fix this is this dirty hack here, which draws
      // the W1 layer as well as W2 if W2 is being used, and similarly
      // for B1 / B2. A better fix would be to go into each animation
      // which needs it, and duplicate the W1 / B1 layers to W2 / B2.
      if (oElement.layer == 5 &&
          oLayers.layer_contents[5] - 4 == oElement.layer_id) {
        /* don't skip */;
      } else {
        continue;
      }
    }

    // Only apply patient animation effect to patient sprites. Layer 0, 0
    // represents non-patient sprites such as doors, benches, etc.
    // TODO: Some animations such as leaving radiation chamber have part of
    // patient in layer 0, 0, so this condition is not quite correct.
    animation_effect render_effect =
        (oElement.layer > 0 || oElement.layer_id > 0) ? patient_effect
                                                      : animation_effect::none;
    size_t effect_ticks = game_ticks + patient_effect_offset;
    if (iFlags & thdf_flip_horizontal) {
      int iWidth;
      int iHeight;
      oElement.element_sprite_sheet->get_sprite_size_unchecked(
          oElement.sprite, &iWidth, &iHeight);

      oElement.element_sprite_sheet->draw_sprite(
          pCanvas, oElement.sprite, iX - oElement.x - iWidth, iY + oElement.y,
          iPassOnFlags | (oElement.flags ^ thdf_flip_horizontal), effect_ticks,
          render_effect);
    } else {
      oElement.element_sprite_sheet->draw_sprite(
          pCanvas, oElement.sprite, iX + oElement.x, iY + oElement.y,
          iPassOnFlags | oElement.flags, effect_ticks, render_effect);
    }
  }
}

size_t animation_manager::get_frame_sound(size_t iFrame) {
  if (iFrame < frame_count) {
    return frames[iFrame].sound;
  } else {
    return 0;
  }
}

void animation_manager::get_frame_extent(size_t iFrame, const ::layers& oLayers,
                                         int* pMinX, int* pMaxX, int* pMinY,
                                         int* pMaxY, uint32_t iFlags) const {
  int iMinX = INT_MAX;
  int iMaxX = INT_MIN;
  int iMinY = INT_MAX;
  int iMaxY = INT_MIN;
  if (iFrame < frame_count) {
    size_t iListIndex = frames[iFrame].list_index;

    for (;; ++iListIndex) {
      uint16_t iElement = element_list[iListIndex];
      if (iElement >= element_count) {
        break;
      }

      const element& oElement = elements[iElement];
      if ((oElement.layer_id != 0 &&
           oLayers.layer_contents[oElement.layer] != oElement.layer_id) ||
          oElement.element_sprite_sheet == nullptr) {
        continue;
      }

      int iX = oElement.x;
      int iY = oElement.y;
      int iWidth;
      int iHeight;
      oElement.element_sprite_sheet->get_sprite_size_unchecked(
          oElement.sprite, &iWidth, &iHeight);
      if (iFlags & thdf_flip_horizontal) iX = -(iX + iWidth);
      if (iX < iMinX) iMinX = iX;
      if (iY < iMinY) iMinY = iY;
      if (iX + iWidth + 1 > iMaxX) iMaxX = iX + iWidth + 1;
      if (iY + iHeight + 1 > iMaxY) iMaxY = iY + iHeight + 1;
    }
  }
  if (pMinX) *pMinX = iMinX;
  if (pMaxX) *pMaxX = iMaxX;
  if (pMinY) *pMinY = iMinY;
  if (pMaxY) *pMaxY = iMaxY;
}

chunk_renderer::chunk_renderer(const int width, const int height,
                               std::vector<uint8_t>::iterator start)
    : ptr(start),
      end(start + (width * height)),
      width(width) {}

void chunk_renderer::chunk_fill_to_end_of_line(uint8_t value) {
  if (x != 0 || !skip_eol) {
    chunk_fill(width - x, value);
  }
  skip_eol = false;
}

void chunk_renderer::chunk_finish(uint8_t value) {
  chunk_fill(static_cast<int>(end - ptr), value);
}

void chunk_renderer::chunk_fill(int npixels, uint8_t value) {
  fix_n_pixels(npixels);
  if (npixels > 0) {
    std::fill_n(ptr, npixels, value);
    increment_position(npixels);
  }
}

void chunk_renderer::chunk_copy(int npixels, const uint8_t* in_data) {
  fix_n_pixels(npixels);
  if (npixels > 0) {
    std::copy_n(in_data, npixels, ptr);
    increment_position(npixels);
  }
}

void chunk_renderer::fix_n_pixels(int& npixels) const {
  if (ptr + npixels > end) {
    npixels = static_cast<int>(end - ptr);
  }
}

void chunk_renderer::increment_position(int npixels) {
  ptr += npixels;
  x += npixels;
  y += x / width;
  x = x % width;
  skip_eol = true;
}

void chunk_renderer::decode_chunks(const uint8_t* data, int datalen,
                                   bool complex) {
  if (complex) {
    while (!is_done() && datalen > 0) {
      uint8_t b = *data;
      --datalen;
      ++data;
      if (b == 0) {
        chunk_fill_to_end_of_line(0xFF);
      } else if (b < 0x40) {
        int amt = b;
        if (datalen < amt) amt = datalen;
        chunk_copy(amt, data);
        data += amt;
        datalen -= amt;
      } else if ((b & 0xC0) == 0x80) {
        chunk_fill(b - 0x80, 0xFF);
      } else {
        int amt;
        uint8_t colour = 0;
        if (b == 0xFF) {
          if (datalen < 2) {
            break;
          }
          amt = (int)data[0];
          colour = data[1];
          data += 2;
          datalen -= 2;
        } else {
          amt = b - 60 - (b & 0x80) / 2;
          if (datalen > 0) {
            colour = *data;
            ++data;
            --datalen;
          }
        }
        chunk_fill(amt, colour);
      }
    }
  } else {
    while (!is_done() && datalen > 0) {
      uint8_t b = *data;
      --datalen;
      ++data;
      if (b == 0) {
        chunk_fill_to_end_of_line(0xFF);
      } else if (b < 0x80) {
        int amt = b;
        if (datalen < amt) amt = datalen;
        chunk_copy(amt, data);
        data += amt;
        datalen -= amt;
      } else {
        chunk_fill(0x100 - b, 0xFF);
      }
    }
  }
  chunk_finish(0xFF);
}

animation_base::animation_base() : drawable() {}

void animation_base::remove_from_tile() {
  link_list::remove_from_list();
  tile = {-1, -1};
}

void animation_base::attach_to_tile(int x, int y, map_tile* node, int layer) {
  remove_from_tile();
  link_list* pList = &node->entities;

  this->set_drawing_layer(layer);
  this->set_tile(x, y);

  while (pList->next &&
         static_cast<drawable*>(pList->next)->get_drawing_layer() < layer) {
    pList = pList->next;
  }

  prev = pList;
  if (pList->next != nullptr) {
    pList->next->prev = this;
    this->next = pList->next;
  } else {
    next = nullptr;
  }
  pList->next = this;
}

void animation_base::set_layer(int iLayer, int iId) {
  if (0 <= iLayer && iLayer < max_number_of_layers) {
    layers.layer_contents[iLayer] = static_cast<uint8_t>(iId);
  }
}


animation_proxy::animation_proxy(animation* const parent_anim, int8_t dx,
                                 int8_t dy, int8_t crop_base,
                                 int8_t crop_width)
    : parent_anim(parent_anim),
      dx(dx),
      dy(dy),
      crop_base(crop_base),
      crop_width(crop_width) { }

void animation_proxy::attach_to_map(level_map* game_map, int x, int y,
                                    int layer) {
    throw std::runtime_error("Unexpected attach_to_map call.");
}

void animation_proxy::remove_from_tile() {
  remove_self_from_tile(); // Better be safe than sorry.
  parent_anim->remove_from_tile();
}

void animation_proxy::remove_self_from_tile() {
  animation_base::remove_from_tile();
}

void animation_proxy::draw_fn(render_target* canvas, int dest_x, int dest_y) {
  // Compute offset of the xy position of the proxy wrt the animation.
  int delta_x = (dx - dy) * 32;
  int delta_y = (dx + dy) * 16;

  if (crop_width > 0) {
      clip_rect new_clipt_rectangle;
      new_clipt_rectangle.y = 0;
      new_clipt_rectangle.h = canvas->get_height();
      new_clipt_rectangle.x = delta_x + crop_base * 32;
      new_clipt_rectangle.w = crop_width * 32;

      parent_anim->draw_fn(canvas, dest_x - delta_x, dest_y - delta_y);
  } else {
    parent_anim->draw_fn(canvas, dest_x - delta_x, dest_y - delta_y);
  }
}
bool animation_proxy::hit_test_fn(int dest_x, int dest_y, int test_x,
                                  int test_y)  {
  // Compute offset of the xy position of the proxy wrt the animation.
  int delta_x = (dx - dy) * 32;
  int delta_y = (dx + dy) * 16;

  return parent_anim->hit_test_fn(dest_x - delta_x, dest_y - delta_y, test_x,
                                  test_y);
}
bool animation_proxy::is_multiple_frame_animation_fn() {
  return parent_anim->is_multiple_frame_animation_fn();
}


namespace {

bool are_flags_set(uint32_t val, uint32_t flags) {
  return (val & flags) == flags;
}

}  // namespace

animation::animation() { patient_effect_offset = rand(); }

animation::~animation() {
  animation::remove_from_tile();
}

void animation::attach_to_map(level_map* game_map, int x, int y, int layer) {
  map_tile* node = game_map->get_tile(x, y);
  attach_to_tile(x, y, node, layer);
  // XXX Attach proxies as well.
}

void animation::remove_from_tile() {
  animation_base::remove_from_tile();
  remove_all_proxies_from_tile();
}

void animation::draw(render_target* pCanvas, int iDestX, int iDestY) {
  if (are_flags_set(flags, thdf_alpha_50 | thdf_alpha_75)) return;

  if (sound_to_play) {
    sound_player* pSounds = sound_player::get_singleton();
    if (pSounds) pSounds->play_at(sound_to_play, iDestX, iDestY);
    sound_to_play = 0;
  }
  if (manager) {
    if (flags & thdf_crop) {
      clip_rect rcNew;
      rcNew.y = 0;
      rcNew.h = pCanvas->get_height();
      rcNew.x = iDestX + (crop_column - 1) * 32;
      rcNew.w = 64;
      render_target::scoped_clip clip(pCanvas, &rcNew);
      manager->draw_frame(pCanvas, frame_index, layers, iDestX + pixel_offset.x,
                          iDestY + pixel_offset.y, flags, patient_effect,
                          patient_effect_offset);
    } else
      manager->draw_frame(pCanvas, frame_index, layers, iDestX + pixel_offset.x,
                          iDestY + pixel_offset.y, flags, patient_effect,
                          patient_effect_offset);
  }
}

void animation::draw_child(render_target* pCanvas, int iDestX, int iDestY,
                           bool use_primary) {
  if (are_flags_set(flags, thdf_alpha_50 | thdf_alpha_75)) return;
  if (are_flags_set(parent->flags, thdf_alpha_50 | thdf_alpha_75)) return;
  int iX = 0, iY = 0;
  if (use_primary)
    parent->get_primary_marker(&iX, &iY);
  else
    parent->get_secondary_marker(&iX, &iY);

  iX += pixel_offset.x + iDestX;
  iY += pixel_offset.y + iDestY;
  if (sound_to_play) {
    sound_player* pSounds = sound_player::get_singleton();
    if (pSounds) pSounds->play_at(sound_to_play, iX, iY);
    sound_to_play = 0;
  }
  if (manager) manager->draw_frame(pCanvas, frame_index, layers, iX, iY, flags);
}

bool animation::hit_test_child(int iDestX, int iDestY, int iTestX, int iTestY) {
  // TODO
  return false;
}

void animation::draw_morph(render_target* pCanvas, int iDestX, int iDestY) {
  if (are_flags_set(flags, thdf_alpha_50 | thdf_alpha_75)) return;

  if (!manager) return;

  iDestX += pixel_offset.x;
  iDestY += pixel_offset.y;
  if (sound_to_play) {
    sound_player* pSounds = sound_player::get_singleton();
    if (pSounds) pSounds->play_at(sound_to_play, iDestX, iDestY);
    sound_to_play = 0;
  }

  clip_rect oMorphRect;
  // We set the morph rect x and w clip to the entire canvas, so that only
  // vertical clipping is applied.
  oMorphRect.x = 0;
  oMorphRect.w = pCanvas->get_width();
  oMorphRect.y = iDestY + morph_target->pixel_offset.x;
  oMorphRect.h = morph_target->pixel_offset.y - morph_target->pixel_offset.x;
  {
    render_target::scoped_clip clip(pCanvas, &oMorphRect);
    manager->draw_frame(pCanvas, frame_index, layers, iDestX, iDestY, flags);
  }
  oMorphRect.y = iDestY + morph_target->pixel_offset.y;
  oMorphRect.h = morph_target->speed.x - morph_target->pixel_offset.y;
  {
    render_target::scoped_clip clip(pCanvas, &oMorphRect);
    manager->draw_frame(pCanvas, morph_target->frame_index,
                        morph_target->layers, iDestX, iDestY,
                        morph_target->flags);
  }
}

bool animation::hit_test(int iDestX, int iDestY, int iTestX, int iTestY) {
  if (are_flags_set(flags, thdf_alpha_50 | thdf_alpha_75)) {
    return false;
  }

  if (manager == nullptr) {
    return false;
  }

  return manager->hit_test(frame_index, layers, pixel_offset.x + iDestX,
                           pixel_offset.y + iDestY, flags, iTestX, iTestY);
}

bool animation::hit_test_morph(int iDestX, int iDestY, int iTestX, int iTestY) {
  if (are_flags_set(flags, thdf_alpha_50 | thdf_alpha_75)) {
    return false;
  }

  if (manager == nullptr) {
    return false;
  }

  return manager->hit_test(frame_index, layers, pixel_offset.x + iDestX,
                           pixel_offset.y + iDestY, flags, iTestX, iTestY) ||
         morph_target->hit_test(iDestX, iDestY, iTestX, iTestY);
}

void animation::persist(lua_persist_writer* pWriter) const {
  lua_State* L = pWriter->get_stack();

  // Write the next chained thing
  lua_rawgeti(L, luaT_environindex, 2);
  void* np = dynamic_cast<animation*>(next);
  if (np == nullptr) {
    np = dynamic_cast<sprite_render_list*>(next);
  }
  lua_pushlightuserdata(L, np);
  lua_rawget(L, -2);
  pWriter->fast_write_stack_object(-1);
  lua_pop(L, 2);

  // Write the drawable fields
  pWriter->write_uint(flags);

  if (anim_kind == animation_kind::normal) {
    pWriter->write_uint(1);
  } else if (anim_kind == animation_kind::primary_child) {
    pWriter->write_uint(2);
  } else if (anim_kind == animation_kind::morph) {
    // NB: Prior version of code used the number 3 here, and forgot
    // to persist the morph target.
    pWriter->write_uint(4);
    lua_rawgeti(L, luaT_environindex, 2);
    lua_pushlightuserdata(L, morph_target);
    lua_rawget(L, -2);
    pWriter->write_stack_object(-1);
    lua_pop(L, 2);
  } else if (anim_kind == animation_kind::secondary_child) {
    pWriter->write_uint(5);
  } else {
    pWriter->write_uint(0);
  }

  // Write the simple fields
  pWriter->write_uint(animation_index);
  pWriter->write_uint(frame_index);
  pWriter->write_int(pixel_offset.x);
  pWriter->write_int(pixel_offset.y);

  // Not a uint, for compatibility
  pWriter->write_int((int)sound_to_play);

  pWriter->write_int(static_cast<int>(patient_effect));

  if (flags & thdf_crop) {
    pWriter->write_int(crop_column);
  }

  // Write the unioned fields
  if (anim_kind != animation_kind::primary_child &&
      anim_kind != animation_kind::secondary_child) {
    pWriter->write_int(speed.x);
    pWriter->write_int(speed.y);
  } else {
    lua_rawgeti(L, luaT_environindex, 2);
    lua_pushlightuserdata(L, parent);
    lua_rawget(L, -2);
    pWriter->write_stack_object(-1);
    lua_pop(L, 2);
  }

  // Write the layers
  int iNumLayers = max_number_of_layers;
  for (; iNumLayers >= 1; --iNumLayers) {
    if (layers.layer_contents[iNumLayers - 1] != 0) break;
  }
  pWriter->write_uint(iNumLayers);
  pWriter->write_byte_stream(layers.layer_contents, iNumLayers);
}

void animation::depersist(lua_persist_reader* pReader) {
  lua_State* L = pReader->get_stack();

  do {
    // Read the chain
    if (!pReader->read_stack_object()) break;

    next = luaT_toanimationbase(L, -1);
    if (next) next->prev = this;
    lua_pop(L, 1);

    // Read drawable fields
    if (!pReader->read_uint(flags)) break;
    int iFunctionSet;
    if (!pReader->read_uint(iFunctionSet)) break;
    switch (iFunctionSet) {
      case 3:
        // 3 should be the morph set, but the actual morph target is
        // missing, so settle for a graphical bug rather than a segfault
        // by reverting to the normal function set.
      case 1:
        set_animation_kind(animation_kind::normal);
        break;
      case 2:
        set_animation_kind(animation_kind::primary_child);
        break;
      case 4:
        set_animation_kind(animation_kind::morph);
        pReader->read_stack_object();
        morph_target = static_cast<animation*>(lua_touserdata(L, -1));
        lua_pop(L, 1);
        break;
      case 5:
        set_animation_kind(animation_kind::secondary_child);
        break;
      default:
        pReader->set_error(lua_pushfstring(
            L, "Unknown animation function set #%i", iFunctionSet));
        return;
    }

    // Read the simple fields
    if (!pReader->read_uint(animation_index)) break;
    if (!pReader->read_uint(frame_index)) break;
    if (!pReader->read_int(pixel_offset.x)) break;
    if (!pReader->read_int(pixel_offset.y)) break;
    int iDummy;
    if (!pReader->read_int(iDummy)) break;
    if (iDummy >= 0) sound_to_play = (unsigned int)iDummy;
    if (!pReader->read_int(iDummy)) break;
    patient_effect = static_cast<animation_effect>(iDummy);
    if (flags & thdf_crop) {
      if (!pReader->read_int(crop_column)) {
        break;
      }
    } else {
      crop_column = 0;
    }

    // Read the unioned fields
    if (anim_kind != animation_kind::primary_child &&
        anim_kind != animation_kind::secondary_child) {
      if (!pReader->read_int(speed.x)) break;
      if (!pReader->read_int(speed.y)) break;
    } else {
      if (!pReader->read_stack_object()) break;
      parent = static_cast<animation*>(lua_touserdata(L, -1));
      lua_pop(L, 1);
    }

    // Read the layers
    std::memset(layers.layer_contents, 0, sizeof(layers.layer_contents));
    int iNumLayers;
    if (!pReader->read_uint(iNumLayers)) {
      break;
    }

    if (iNumLayers > max_number_of_layers) {
      if (!pReader->read_byte_stream(layers.layer_contents,
                                     max_number_of_layers)) {
        break;
      }
      if (!pReader->read_byte_stream(nullptr,
                                     iNumLayers - max_number_of_layers)) {
        break;
      }
    } else {
      if (!pReader->read_byte_stream(layers.layer_contents, iNumLayers)) break;
    }

    // Fix the m_pAnimator field
    luaT_getenvfield(L, 2, "animator");
    manager = static_cast<animation_manager*>(lua_touserdata(L, -1));
    lua_pop(L, 1);

    return;
  } while (false);

  pReader->set_error("Cannot depersist animation instance");
}

void animation::set_patient_effect(animation_effect patient_effect) {
  this->patient_effect = patient_effect;
}

void animation::set_animation_kind(animation_kind anim_kind) {
  this->anim_kind = anim_kind;
}

namespace {
//! Storage of one or two sounds. If two sounds are stored, both are selected in
//! 50% of the cases.
struct sound_pair {
  sound_pair(int16_t sound) : soundA(sound), soundB(-1) {}
  sound_pair(int16_t soundA, int16_t soundB) : soundA(soundA), soundB(soundB) {}

  int16_t get_sound() const {
    if (soundB < 0) {
      return soundA;
    } else {
      int value = rand();
      int counter = 0;
      for (int i = 0; i < 7; i++) {
        counter = counter + (value & 1);
        value >>= 1;
      }
      return (counter < 4) ? soundA : soundB;
    }
  }

 private:
  const int16_t soundA;  //!< First available sound.
  const int16_t soundB;  //!< If non-negative, the second available sound.
};

typedef std::map<size_t, sound_pair> sound_replacement_map;

// Map of frame numbers to sounds to play.
const sound_replacement_map frame_sound_replacements{
    // Female flying to heaven (anim 3220)
    {6987, sound_pair(123)},

    // Using Computer (anim 2098)
    {4213, sound_pair(35)},
    {4215, sound_pair(35)},
    {4224, sound_pair(35)},
    {4230, sound_pair(35)},

    // Vomit sounds.
    {1902, sound_pair(58, 114)},   // Animation 1034
    {4149, sound_pair(58, 114)},   // Animation 2056
    {6901, sound_pair(58, 114)},   // Animation 3184
    {8819, sound_pair(58, 114)},   // Animation 4138
    {9105, sound_pair(58, 114)},   // Animation 4204
    {9565, sound_pair(58, 114)},   // Animation 4324
    {9654, sound_pair(58, 114)},   // Animation 4384
    {9944, sound_pair(58, 114)},   // Animation 4452
    {10007, sound_pair(58, 114)},  // Animation 4476
    {10989, sound_pair(58, 114)},  // Animation 4792

    // Using Atom Analyser. Actually a generic animation of Researcher pushing
    // buttons (anim 4878)
    {11136, sound_pair(35)},
    {11138, sound_pair(35)},
    {11147, sound_pair(35)},
    {11152, sound_pair(35)},
    {11153, sound_pair(35)},
    {11154, sound_pair(35)}};
}  // Namespace

void animation::tick() {
  frame_index = manager->get_next_frame(frame_index);
  if (anim_kind != animation_kind::primary_child &&
      anim_kind != animation_kind::secondary_child) {
    pixel_offset.x += speed.x;
    pixel_offset.y += speed.y;
  }

  if (morph_target) {
    morph_target->pixel_offset.y += morph_target->speed.y;
    if (morph_target->pixel_offset.y < morph_target->pixel_offset.x) {
      morph_target->pixel_offset.y = morph_target->pixel_offset.x;
    }
  }

  // Decide sound to play.
  sound_replacement_map::const_iterator pos =
      frame_sound_replacements.find(frame_index);
  if (pos == frame_sound_replacements.end()) {
    sound_to_play = manager->get_frame_sound(frame_index);
  } else {
    sound_to_play = pos->second.get_sound();
  }
}

void animation::set_parent(animation* pParent, bool use_primary) {
  remove_from_tile();
  if (pParent == nullptr) {
    set_animation_kind(animation_kind::normal);
    speed = {0, 0};
  } else {
    set_animation_kind(use_primary ? animation_kind::primary_child
                                   : animation_kind::secondary_child);
    parent = pParent;
    next = parent->next;
    if (next) next->prev = this;
    prev = parent;
    parent->next = this;
  }
}

void animation::set_animation(animation_manager* pManager, size_t iAnimation) {
  manager = pManager;
  animation_index = iAnimation;
  frame_index = pManager->get_first_frame(iAnimation);
  if (morph_target) {
    morph_target = nullptr;
    set_animation_kind(animation_kind::normal);
  }
}

bool animation::get_primary_marker(int* pX, int* pY) {
  if (!manager || !manager->get_frame_primary_marker(frame_index, pX, pY)) {
    return false;
  }

  if (flags & thdf_flip_horizontal) {
    *pX = -*pX;
  }

  *pX += pixel_offset.x;
  *pY += pixel_offset.y + 16;
  return true;
}

bool animation::get_secondary_marker(int* pX, int* pY) {
  if (!manager || !manager->get_frame_secondary_marker(frame_index, pX, pY)) {
    return false;
  }

  if (flags & thdf_flip_horizontal) {
    *pX = -*pX;
  }

  *pX += pixel_offset.x;
  *pY += pixel_offset.y + 16;
  return true;
}

namespace {

int GetAnimationDurationAndExtent(animation_manager* pManager, size_t iFrame,
                                  const ::layers& oLayers, int* pMinY,
                                  int* pMaxY, uint32_t iFlags) {
  int iMinY = INT_MAX;
  int iMaxY = INT_MIN;
  int iDuration = 0;
  size_t iCurFrame = iFrame;
  do {
    int iFrameMinY;
    int iFrameMaxY;
    pManager->get_frame_extent(iCurFrame, oLayers, nullptr, nullptr,
                               &iFrameMinY, &iFrameMaxY, iFlags);
    if (iFrameMinY < iMinY) iMinY = iFrameMinY;
    if (iFrameMaxY > iMaxY) iMaxY = iFrameMaxY;
    iCurFrame = pManager->get_next_frame(iCurFrame);
    ++iDuration;
  } while (iCurFrame != iFrame);
  if (pMinY) {
    *pMinY = iMinY;
  }
  if (pMaxY) {
    *pMaxY = iMaxY;
  }
  return iDuration;
}

}  // namespace

void animation::set_morph_target(animation* pMorphTarget, int iDurationFactor) {
  morph_target = pMorphTarget;
  set_animation_kind(animation_kind::morph);

  /* Morphing is the process by which two animations are combined to give a
  single animation of one animation turning into another. At the moment,
  morphing is done by having a y value, above which the original animation is
  rendered, and below which the new animation is rendered, and having the y
  value move upward a bit each frame.
  One example of where this is used is when transparent or invisible patients
  are cured at the pharmacy cabinet.
  The process of morphing requires four state variables, which are stored in
  the morph target animation:
    * The y value top limit - morph_target->x
    * The y value threshold - morph_target->y
    * The y value bottom limit - morph_target->speed.x
    * The y value increment per frame - morph_target->speed.y
  This obviously means that the morph target should not be ticked or rendered
  as it's position and speed contain other values.
  */

  int iOrigMinY, iOrigMaxY;
  int iMorphMinY, iMorphMaxY;

  int iOriginalDuration = GetAnimationDurationAndExtent(
      manager, frame_index, layers, &iOrigMinY, &iOrigMaxY, flags);
  int iMorphDuration = GetAnimationDurationAndExtent(
      morph_target->manager, morph_target->frame_index, morph_target->layers,
      &iMorphMinY, &iMorphMaxY, morph_target->flags);
  if (iMorphDuration > iOriginalDuration) {
    iMorphDuration = iOriginalDuration;
  }

  iMorphDuration *= iDurationFactor;
  if (iOrigMinY < iMorphMinY) {
    morph_target->pixel_offset.x = iOrigMinY;
  } else {
    morph_target->pixel_offset.x = iMorphMinY;
  }

  if (iOrigMaxY > iMorphMaxY) {
    morph_target->speed.x = iOrigMaxY;
  } else {
    morph_target->speed.x = iMorphMaxY;
  }

  int iDist = morph_target->pixel_offset.x - morph_target->speed.x;
  morph_target->speed.y = (iDist - iMorphDuration + 1) / iMorphDuration;
  morph_target->pixel_offset.y = morph_target->speed.x;
}

void animation::set_frame(size_t iFrame) { frame_index = iFrame; }

void animation::add_proxy(int8_t dx, int8_t dy, int8_t crop_base,
                          int8_t crop_width) {
  proxies.emplace_back(this, dx, dy, crop_base, crop_width);
}

void animation::remove_all_proxies_from_tile() {
  for (auto &proxy: proxies) {
    proxy.remove_self_from_tile();
  }
}

void animation::remove_all_proxies() {
  remove_all_proxies_from_tile();
  proxies.clear();
}

void sprite_render_list::tick() {
  pixel_offset.x += dx_per_tick;
  pixel_offset.y += dy_per_tick;
  if (lifetime > 0) {
    --lifetime;
  }
}

void sprite_render_list::draw(render_target* pCanvas, int iDestX, int iDestY) {
  if (!sheet || sprites.empty()) {
    return;
  }

  iDestX += pixel_offset.x;
  iDestY += pixel_offset.y;

  std::unique_ptr<render_target::scoped_buffer> intermediate_buffer;
  if (use_intermediate_buffer) {
    int minX = INT_MAX, minY = INT_MAX, maxX = INT_MIN, maxY = INT_MIN;
    for (const sprite& pSprite : sprites) {
      int spriteX = iDestX + pSprite.x;
      int spriteY = iDestY + pSprite.y;
      int spriteWidth, spriteHeight;
      sheet->get_sprite_size_unchecked(pSprite.index, &spriteWidth,
                                       &spriteHeight);
      minX = std::min(minX, spriteX);
      minY = std::min(minY, spriteY);
      maxX = std::max(maxX, spriteX + spriteWidth);
      maxY = std::max(maxY, spriteY + spriteHeight);
    }
    intermediate_buffer = pCanvas->begin_intermediate_drawing(
        minX, minY, maxX - minX, maxY - minY);
  }

  for (const sprite& pSprite : sprites) {
    sheet->draw_sprite(pCanvas, pSprite.index, iDestX + pSprite.x,
                       iDestY + pSprite.y, flags);
  }
}

bool sprite_render_list::hit_test(int iDestX, int iDestY, int iTestX,
                                  int iTestY) {
  // TODO
  return false;
}

void sprite_render_list::attach_to_map(level_map* game_map, int x, int y,
                                       int layer) {
  map_tile* node = game_map->get_tile(x, y);
  attach_to_tile(x, y, node, layer);
}

void sprite_render_list::set_lifetime(int iLifetime) {
  if (iLifetime < 0) {
    iLifetime = -1;
  }
  lifetime = iLifetime;
}

void sprite_render_list::set_use_intermediate_buffer() {
  use_intermediate_buffer = true;
}

void sprite_render_list::append_sprite(size_t iSprite, int iX, int iY) {
  sprite s{iSprite, iX, iY};
  sprites.push_back(s);
}

void sprite_render_list::persist(lua_persist_writer* pWriter) const {
  lua_State* L = pWriter->get_stack();

  pWriter->write_uint(sprites.size());
  pWriter->write_uint(flags);
  pWriter->write_int(pixel_offset.x);
  pWriter->write_int(pixel_offset.y);
  pWriter->write_int(dx_per_tick);
  pWriter->write_int(dy_per_tick);
  pWriter->write_int(lifetime);

  for (const sprite& pSprite : sprites) {
    pWriter->write_uint(pSprite.index);
    pWriter->write_int(pSprite.x);
    pWriter->write_int(pSprite.y);
  }

  // Write the layers
  int iNumLayers = max_number_of_layers;
  for (; iNumLayers >= 1; --iNumLayers) {
    if (layers.layer_contents[iNumLayers - 1] != 0) {
      break;
    }
  }
  pWriter->write_uint(iNumLayers);
  pWriter->write_byte_stream(layers.layer_contents, iNumLayers);

  // Write the next chained thing
  lua_rawgeti(L, luaT_environindex, 2);
  void* np = dynamic_cast<animation*>(next);
  if (np == nullptr) {
    np = dynamic_cast<sprite_render_list*>(next);
  }
  lua_pushlightuserdata(L, np);
  lua_rawget(L, -2);
  pWriter->fast_write_stack_object(-1);
  lua_pop(L, 2);
}

void sprite_render_list::depersist(lua_persist_reader* pReader) {
  lua_State* L = pReader->get_stack();

  uint32_t sprite_count;
  if (!pReader->read_uint(sprite_count)) return;
  sprites.resize(sprite_count);

  if (!pReader->read_uint(flags)) return;
  if (!pReader->read_int(pixel_offset.x)) return;
  if (!pReader->read_int(pixel_offset.y)) return;
  if (!pReader->read_int(dx_per_tick)) return;
  if (!pReader->read_int(dy_per_tick)) return;
  if (!pReader->read_int(lifetime)) return;
  for (sprite& pSprite : sprites) {
    if (!pReader->read_uint(pSprite.index)) return;
    if (!pReader->read_int(pSprite.x)) return;
    if (!pReader->read_int(pSprite.y)) return;
  }

  // Read the layers
  std::memset(layers.layer_contents, 0, sizeof(layers.layer_contents));
  int iNumLayers;
  if (!pReader->read_uint(iNumLayers)) {
    return;
  }

  if (iNumLayers > max_number_of_layers) {
    if (!pReader->read_byte_stream(layers.layer_contents,
                                   max_number_of_layers)) {
      return;
    }

    if (!pReader->read_byte_stream(nullptr,
                                   iNumLayers - max_number_of_layers)) {
      return;
    }
  } else {
    if (!pReader->read_byte_stream(layers.layer_contents, iNumLayers)) {
      return;
    }
  }

  // Read the chain
  if (!pReader->read_stack_object()) {
    return;
  }

  next = luaT_toanimationbase(L, -1);
  if (next) {
    next->prev = this;
  }
  lua_pop(L, 1);

  // Fix the sheet field
  luaT_getenvfield(L, 2, "sheet");
  sheet = static_cast<sprite_sheet*>(lua_touserdata(L, -1));
  lua_pop(L, 1);
}
