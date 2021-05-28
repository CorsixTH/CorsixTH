/*
Copyright (c) 2009-2013 Peter "Corsix" Cawley and Edvin "Lego3" Linge

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

#include "config.h"

#include "th_gfx.h"
#ifdef CORSIX_TH_USE_FREETYPE2
#include "th_gfx_font.h"
#endif
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <iostream>
#include <limits>
#include <new>
#include <stdexcept>

#include "th_map.h"

full_colour_renderer::full_colour_renderer(int iWidth, int iHeight)
    : width(iWidth), height(iHeight) {
  x = 0;
  y = 0;
}

namespace {

//! Convert a colour to an equivalent grey scale level.
/*!
    @param iOpacity Opacity of the pixel.
    @param iR Red colour intensity.
    @param iG Green colour intensity.
    @param iB Blue colour intensity.
    @return 32bpp colour pixel in grey scale.
 */
inline uint32_t makeGreyScale(uint8_t iOpacity, uint8_t iR, uint8_t iG,
                              uint8_t iB) {
  // http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
  // 0.2126*R + 0.7152*G + 0.0722*B
  // 0.2126 * 65536 = 13932.9536 -> 1393
  // 0.7152 * 65536 = 46871.3472
  // 0.0722 * 65536 =  4731.6992 -> 4732
  // 13933 + 46871 + 4732 = 65536 = 2**16
  uint8_t iGrey =
      static_cast<uint8_t>((13933 * iR + 46871 * iG + 4732 * iB) >> 16);
  return palette::pack_argb(iOpacity, iGrey, iGrey, iGrey);
}

//! Convert a colour by swapping red and blue channel.
/*!
    @param iOpacity Opacity of the pixel.
    @param iR Red colour intensity.
    @param iG Green colour intensity.
    @param iB Blue colour intensity.
    @return 32bpp colour pixel with red and blue swapped.
 */
inline uint32_t makeSwapRedBlue(uint8_t iOpacity, uint8_t iR, uint8_t iG,
                                uint8_t iB) {
  // http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
  // The Y factor for red is 0.2126, and for blue 0.0722. This means red is
  // about 3 times stronger than blue. Simple swapping channels will thus
  // distort the balance. This code compensates for that by computing red  =
  // blue * 0.0722 / 0.2126 = blue * 1083 / 3189 blue = red  * 0.2126 / 0.0722
  // = red  * 1063 / 361 (clipped at max blue, 255)
  uint8_t iNewRed = static_cast<uint8_t>(iB * 1083 / 3189);
  int iNewBlue = iR * 1063 / 361;
  if (iNewBlue > 255) iNewBlue = 255;
  return palette::pack_argb(iOpacity, iNewRed, iG,
                            static_cast<uint8_t>(iNewBlue));
}

uint8_t convert_6bit_to_8bit_colour_component(uint8_t colour_component) {
  constexpr uint8_t mask_6bit = 0x3F;
  return static_cast<uint8_t>(std::lround(
      (colour_component & mask_6bit) * static_cast<double>(0xFF) / mask_6bit));
}

}  // namespace

palette::palette() { colour_count = 0; }

bool palette::load_from_th_file(const uint8_t* pData, size_t iDataLength) {
  if (iDataLength != 256 * 3) return false;

  colour_count = static_cast<int>(iDataLength / 3);
  for (int i = 0; i < colour_count; ++i, pData += 3) {
    uint8_t iR = convert_6bit_to_8bit_colour_component(pData[0]);
    uint8_t iG = convert_6bit_to_8bit_colour_component(pData[1]);
    uint8_t iB = convert_6bit_to_8bit_colour_component(pData[2]);
    uint32_t iColour = pack_argb(0xFF, iR, iG, iB);
    // Remap magenta to transparent
    if (iColour == pack_argb(0xFF, 0xFF, 0x00, 0xFF))
      iColour = pack_argb(0x00, 0x00, 0x00, 0x00);
    colour_index_to_argb_map[i] = iColour;
  }

  return true;
}

bool palette::set_entry(int iEntry, uint8_t iR, uint8_t iG, uint8_t iB) {
  if (iEntry < 0 || iEntry >= colour_count) return false;
  uint32_t iColour = pack_argb(0xFF, iR, iG, iB);
  // Remap magenta to transparent
  if (iColour == pack_argb(0xFF, 0xFF, 0x00, 0xFF))
    iColour = pack_argb(0x00, 0x00, 0x00, 0x00);
  colour_index_to_argb_map[iEntry] = iColour;
  return true;
}

int palette::get_colour_count() const { return colour_count; }

const uint32_t* palette::get_argb_data() const {
  return colour_index_to_argb_map;
}

void full_colour_renderer::decode_image(const uint8_t* pImg,
                                        const palette* pPalette,
                                        uint32_t iSpriteFlags) {
  if (width <= 0) {
    throw std::logic_error("width cannot be <= 0 when decoding an image");
  }
  if (height <= 0) {
    throw std::logic_error("height cannot be <= 0 when decoding an image");
  }

  iSpriteFlags &= thdf_alt32_mask;

  const uint32_t* pColours = pPalette->get_argb_data();
  for (;;) {
    uint8_t iType = *pImg++;
    size_t iLength = iType & 63;
    switch (iType >> 6) {
      case 0:  // Fixed fully opaque 32bpp pixels
        while (iLength > 0) {
          uint32_t iColour;
          if (iSpriteFlags == thdf_alt32_blue_red_swap)
            iColour = makeSwapRedBlue(0xFF, pImg[0], pImg[1], pImg[2]);
          else if (iSpriteFlags == thdf_alt32_grey_scale)
            iColour = makeGreyScale(0xFF, pImg[0], pImg[1], pImg[2]);
          else
            iColour = palette::pack_argb(0xFF, pImg[0], pImg[1], pImg[2]);
          push_pixel(iColour);
          pImg += 3;
          iLength--;
        }
        break;

      case 1:  // Fixed partially transparent 32bpp pixels
      {
        uint8_t iOpacity = *pImg++;
        while (iLength > 0) {
          uint32_t iColour;
          if (iSpriteFlags == thdf_alt32_blue_red_swap)
            iColour = makeSwapRedBlue(0xFF, pImg[0], pImg[1], pImg[2]);
          else if (iSpriteFlags == thdf_alt32_grey_scale)
            iColour = makeGreyScale(iOpacity, pImg[0], pImg[1], pImg[2]);
          else
            iColour = palette::pack_argb(iOpacity, pImg[0], pImg[1], pImg[2]);
          push_pixel(iColour);
          pImg += 3;
          iLength--;
        }
        break;
      }

      case 2:  // Fixed fully transparent pixels
      {
        static const uint32_t iTransparent = palette::pack_argb(0, 0, 0, 0);
        while (iLength > 0) {
          push_pixel(iTransparent);
          iLength--;
        }
        break;
      }

      case 3:  // Recolour layer
      {
        uint8_t iTable = *pImg++;
        pImg++;  // Skip reading the opacity for now.
        if (iTable == 0xFF) {
          // Legacy sprite data. Use the palette to recolour the
          // layer. Note that the iOpacity is ignored here.
          while (iLength > 0) {
            push_pixel(pColours[*pImg++]);
            iLength--;
          }
        } else {
          // TODO: Add proper recolour layers, where RGB comes from
          // table 'iTable' at index *pImg (iLength times), and
          // opacity comes from the byte after the iTable byte.
          //
          // For now just draw black pixels, so it won't go unnoticed.
          while (iLength > 0) {
            uint32_t iColour = palette::pack_argb(0xFF, 0, 0, 0);
            push_pixel(iColour);
            iLength--;
          }
        }
        break;
      }
    }

    if (y >= height) break;
  }
  if (y != height || x != 0) {
    throw std::logic_error("Image data does not match given dimensions");
  }
}

full_colour_storing::full_colour_storing(uint32_t* pDest, int iWidth,
                                         int iHeight)
    : full_colour_renderer(iWidth, iHeight) {
  destination = pDest;
}

void full_colour_storing::store_argb(uint32_t pixel) { *destination++ = pixel; }

wx_storing::wx_storing(uint8_t* pRGBData, uint8_t* pAData, int iWidth,
                       int iHeight)
    : full_colour_renderer(iWidth, iHeight) {
  rgb_data = pRGBData;
  alpha_data = pAData;
}

void wx_storing::store_argb(uint32_t pixel) {
  rgb_data[0] = palette::get_red(pixel);
  rgb_data[1] = palette::get_green(pixel);
  rgb_data[2] = palette::get_blue(pixel);
  rgb_data += 3;

  *alpha_data++ = palette::get_alpha(pixel);
}

render_target::render_target() {
  window = nullptr;
  renderer = nullptr;
  pixel_format = nullptr;
  game_cursor = nullptr;
  zoom_texture = nullptr;
  scale_bitmaps = false;
  blue_filter_active = false;
  apply_opengl_clip_fix = false;
  width = -1;
  height = -1;
}

render_target::~render_target() { destroy(); }

bool render_target::create(const render_target_creation_params* pParams) {
  if (renderer != nullptr) return false;

  SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "linear");
  pixel_format = SDL_AllocFormat(SDL_PIXELFORMAT_ABGR8888);
  window =
      SDL_CreateWindow("CorsixTH", SDL_WINDOWPOS_UNDEFINED,
                       SDL_WINDOWPOS_UNDEFINED, pParams->width, pParams->height,
                       SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
  if (!window) {
    return false;
  }

  Uint32 iRendererFlags =
      (pParams->present_immediate ? 0 : SDL_RENDERER_PRESENTVSYNC);
  renderer = SDL_CreateRenderer(window, -1, iRendererFlags);

  SDL_RendererInfo info;
  SDL_GetRendererInfo(renderer, &info);
  supports_target_textures = (info.flags & SDL_RENDERER_TARGETTEXTURE) != 0;

  SDL_version sdlVersion;
  SDL_GetVersion(&sdlVersion);
  apply_opengl_clip_fix = std::strncmp(info.name, "opengl", 6) == 0 &&
                          sdlVersion.major == 2 && sdlVersion.minor == 0 &&
                          sdlVersion.patch < 4;

  return update(pParams);
}

bool render_target::update(const render_target_creation_params* pParams) {
  if (window == nullptr) {
    return false;
  }

  bool bUpdateSize = (width != pParams->width) || (height != pParams->height);
  width = pParams->width;
  height = pParams->height;

  bool bIsFullscreen =
      ((SDL_GetWindowFlags(window) & SDL_WINDOW_FULLSCREEN_DESKTOP) ==
       SDL_WINDOW_FULLSCREEN_DESKTOP);
  if (bIsFullscreen != pParams->fullscreen) {
    SDL_SetWindowFullscreen(
        window, (pParams->fullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0));
  }

  if (bUpdateSize || bIsFullscreen != pParams->fullscreen) {
    SDL_SetWindowSize(window, width, height);
  }

  if (bUpdateSize) {
    SDL_RenderSetLogicalSize(renderer, width, height);
  }

  return true;
}

void render_target::destroy() {
  if (pixel_format) {
    SDL_FreeFormat(pixel_format);
    pixel_format = nullptr;
  }

  if (zoom_texture) {
    SDL_DestroyTexture(zoom_texture);
    zoom_texture = nullptr;
  }

  if (renderer) {
    SDL_DestroyRenderer(renderer);
    renderer = nullptr;
  }

  if (window) {
    SDL_DestroyWindow(window);
    window = nullptr;
  }
}

bool render_target::set_scale_factor(double fScale, scaled_items eWhatToScale) {
  flush_zoom_buffer();
  scale_bitmaps = false;

  if (fScale <= 0.000) {
    return false;
  } else if (eWhatToScale == scaled_items::all && supports_target_textures) {
    // Draw everything from now until the next scale to zoom_texture
    // with the appropriate virtual size, which will be copied scaled to
    // fit the window.
    int virtWidth = static_cast<int>(width / fScale);
    int virtHeight = static_cast<int>(height / fScale);

    zoom_texture =
        SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ABGR8888,
                          SDL_TEXTUREACCESS_TARGET, virtWidth, virtHeight);

    SDL_RenderSetLogicalSize(renderer, virtWidth, virtHeight);
    if (SDL_SetRenderTarget(renderer, zoom_texture) != 0) {
      std::cout << "Warning: Could not render to zoom texture - "
                << SDL_GetError() << std::endl;

      SDL_RenderSetLogicalSize(renderer, width, height);
      SDL_DestroyTexture(zoom_texture);
      zoom_texture = nullptr;
      return false;
    }

    // Clear the new texture to transparent/black.
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_TRANSPARENT);
    SDL_RenderClear(renderer);

    return true;
  } else if (0.999 <= fScale && fScale <= 1.001) {
    return true;
  } else if (eWhatToScale == scaled_items::bitmaps) {
    scale_bitmaps = true;
    bitmap_scale_factor = fScale;

    return true;
  }
  return false;
}

void render_target::set_caption(const char* sCaption) {
  SDL_SetWindowTitle(window, sCaption);
}

const char* render_target::get_renderer_details() const {
  SDL_RendererInfo info = {};
  SDL_GetRendererInfo(renderer, &info);
  return info.name;
}

const char* render_target::get_last_error() { return SDL_GetError(); }

bool render_target::start_frame() {
  fill_black();
  return true;
}

bool render_target::end_frame() {
  flush_zoom_buffer();

  // End the frame by adding the cursor and possibly a filter.
  if (game_cursor) {
    game_cursor->draw(this, cursor_x, cursor_y);
  }
  if (blue_filter_active) {
    SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
    SDL_SetRenderDrawColor(renderer, 51, 51, 255,
                           128);  // r=0.2, g=0.2, b=1, a=0.5 .
    SDL_RenderFillRect(renderer, nullptr);
  }

  SDL_RenderPresent(renderer);
  return true;
}

bool render_target::fill_black() {
  SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
  SDL_RenderClear(renderer);

  return true;
}

void render_target::set_blue_filter_active(bool bActivate) {
  blue_filter_active = bActivate;
}

// Actiate and Deactivate SDL function to capture mouse to window
void render_target::set_window_grab(bool bActivate) {
  SDL_SetWindowGrab(window, bActivate ? SDL_TRUE : SDL_FALSE);
}

bool render_target::fill_rect(uint32_t iColour, int iX, int iY, int iW,
                              int iH) {
  SDL_Rect rcDest = {iX, iY, iW, iH};

  Uint8 r, g, b, a;
  SDL_GetRGBA(iColour, pixel_format, &r, &g, &b, &a);

  SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
  SDL_SetRenderDrawColor(renderer, r, g, b, a);
  SDL_RenderFillRect(renderer, &rcDest);

  return true;
}

void render_target::get_clip_rect(clip_rect* pRect) const {
  SDL_RenderGetClipRect(renderer, reinterpret_cast<SDL_Rect*>(pRect));
  // SDL returns empty rect when clipping is disabled -> return full rect for
  // CTH
  if (SDL_RectEmpty(pRect)) {
    pRect->x = pRect->y = 0;
    pRect->w = width;
    pRect->h = height;
  }

  if (apply_opengl_clip_fix) {
    int renderWidth, renderHeight;
    SDL_RenderGetLogicalSize(renderer, &renderWidth, &renderHeight);
    pRect->y = renderHeight - pRect->y - pRect->h;
  }
}

void render_target::set_clip_rect(const clip_rect* pRect) {
  // Full clip rect for CTH means clipping disabled
  if (pRect == nullptr || (pRect->w == width && pRect->h == height)) {
    SDL_RenderSetClipRect(renderer, nullptr);
    return;
  }

  SDL_Rect SDLRect = {pRect->x, pRect->y, pRect->w, pRect->h};

  // For some reason, SDL treats an empty rect (h or w <= 0) as if you turned
  // off clipping, so we replace it with a rect that's outside our viewport.
  const SDL_Rect rcBogus = {-2, -2, 1, 1};
  if (SDL_RectEmpty(&SDLRect)) {
    SDLRect = rcBogus;
  }

  if (apply_opengl_clip_fix) {
    int renderWidth, renderHeight;
    SDL_RenderGetLogicalSize(renderer, &renderWidth, &renderHeight);
    SDLRect.y = renderHeight - SDLRect.y - SDLRect.h;
  }

  SDL_RenderSetClipRect(renderer, &SDLRect);
}

int render_target::get_width() const {
  int w;
  SDL_RenderGetLogicalSize(renderer, &w, nullptr);
  return w;
}

int render_target::get_height() const {
  int h;
  SDL_RenderGetLogicalSize(renderer, nullptr, &h);
  return h;
}

void render_target::start_nonoverlapping_draws() {
  // SDL has no optimisations for drawing lots of non-overlapping sprites
}

void render_target::finish_nonoverlapping_draws() {
  // SDL has no optimisations for drawing lots of non-overlapping sprites
}

void render_target::set_cursor(cursor* pCursor) { game_cursor = pCursor; }

void render_target::set_cursor_position(int iX, int iY) {
  cursor_x = iX;
  cursor_y = iY;
}

bool render_target::take_screenshot(const char* sFile) {
  int width = 0, height = 0;
  if (SDL_GetRendererOutputSize(renderer, &width, &height) == -1) return false;

  // Create a window-sized surface, RGB format (0 Rmask means RGB.)
  SDL_Surface* pRgbSurface =
      SDL_CreateRGBSurface(0, width, height, 24, 0, 0, 0, 0);
  if (pRgbSurface == nullptr) return false;

  int readStatus = -1;
  if (SDL_LockSurface(pRgbSurface) != -1) {
    // Ask the renderer to (slowly) fill the surface with renderer
    // output data.
    readStatus =
        SDL_RenderReadPixels(renderer, nullptr, pRgbSurface->format->format,
                             pRgbSurface->pixels, pRgbSurface->pitch);
    SDL_UnlockSurface(pRgbSurface);

    if (readStatus != -1) SDL_SaveBMP(pRgbSurface, sFile);
  }

  SDL_FreeSurface(pRgbSurface);

  return (readStatus != -1);
}

bool render_target::should_scale_bitmaps(double* pFactor) {
  if (!scale_bitmaps) return false;
  if (pFactor) *pFactor = bitmap_scale_factor;
  return true;
}

void render_target::flush_zoom_buffer() {
  if (zoom_texture == nullptr) {
    return;
  }

  SDL_SetRenderTarget(renderer, nullptr);
  SDL_RenderSetLogicalSize(renderer, width, height);
  SDL_SetTextureBlendMode(zoom_texture, SDL_BLENDMODE_BLEND);
  SDL_RenderCopy(renderer, zoom_texture, nullptr, nullptr);
  SDL_DestroyTexture(zoom_texture);
  zoom_texture = nullptr;
}

namespace {

//! Convert legacy 8bpp sprite data to recoloured 32bpp data, using special
//! recolour table 0xFF.
/*!
    @param pPixelData Legacy 8bpp pixels.
    @param iPixelDataLength Number of pixels in the \a pPixelData.
    @return Converted 32bpp pixel data, if succeeded else nullptr is returned.
   Caller should free the returned memory.
 */
uint8_t* convertLegacySprite(const uint8_t* pPixelData,
                             size_t iPixelDataLength) {
  // Recolour blocks are 63 pixels long.
  // XXX To reduce the size of the 32bpp data, transparent pixels can be
  // stored more compactly.
  size_t iNumFilled = iPixelDataLength / 63;
  size_t iRemaining = iPixelDataLength - iNumFilled * 63;
  size_t iNewSize =
      iNumFilled * (3 + 63) + ((iRemaining > 0) ? 3 + iRemaining : 0);
  uint8_t* pData = new uint8_t[iNewSize];

  uint8_t* pDest = pData;
  while (iPixelDataLength > 0) {
    size_t iLength = (iPixelDataLength >= 63) ? 63 : iPixelDataLength;
    *pDest++ =
        static_cast<uint8_t>(iLength + 0xC0);  // Recolour layer type of block.
    *pDest++ = 0xFF;  // Use special table 0xFF (which uses the palette as
                      // table).
    *pDest++ = 0xFF;  // Non-transparent.
    std::memcpy(pDest, pPixelData, iLength);
    pDest += iLength;
    pPixelData += iLength;
    iPixelDataLength -= iLength;
  }
  return pData;
}

}  // namespace

SDL_Texture* render_target::create_palettized_texture(
    int iWidth, int iHeight, const uint8_t* pPixels, const palette* pPalette,
    uint32_t iSpriteFlags) const {
  uint32_t* pARGBPixels = new uint32_t[iWidth * iHeight];

  full_colour_storing oRenderer(pARGBPixels, iWidth, iHeight);
  oRenderer.decode_image(pPixels, pPalette, iSpriteFlags);

  SDL_Texture* pTexture = create_texture(iWidth, iHeight, pARGBPixels);
  delete[] pARGBPixels;
  return pTexture;
}

SDL_Texture* render_target::create_texture(int iWidth, int iHeight,
                                           const uint32_t* pPixels) const {
  SDL_Texture* pTexture =
      SDL_CreateTexture(renderer, pixel_format->format,
                        SDL_TEXTUREACCESS_STATIC, iWidth, iHeight);

  if (pTexture == nullptr) {
    throw std::runtime_error(SDL_GetError());
  }

  int err = 0;
  err = SDL_UpdateTexture(pTexture, nullptr, pPixels,
                          static_cast<int>(sizeof(*pPixels) * iWidth));
  if (err < 0) {
    throw std::runtime_error(SDL_GetError());
  }

  err = SDL_SetTextureBlendMode(pTexture, SDL_BLENDMODE_BLEND);
  if (err < 0) {
    throw std::runtime_error(SDL_GetError());
  }

  err = SDL_SetTextureColorMod(pTexture, 0xFF, 0xFF, 0xFF);
  if (err < 0) {
    throw std::runtime_error(SDL_GetError());
  }

  err = SDL_SetTextureAlphaMod(pTexture, 0xFF);
  if (err < 0) {
    throw std::runtime_error(SDL_GetError());
  }

  return pTexture;
}

void render_target::draw(SDL_Texture* pTexture, const SDL_Rect* prcSrcRect,
                         const SDL_Rect* prcDstRect, int iFlags) {
  SDL_SetTextureAlphaMod(pTexture, 0xFF);
  if (iFlags & thdf_alpha_50) {
    SDL_SetTextureAlphaMod(pTexture, 0x80);
  } else if (iFlags & thdf_alpha_75) {
    SDL_SetTextureAlphaMod(pTexture, 0x40);
  }

  int iSDLFlip = SDL_FLIP_NONE;
  if (iFlags & thdf_flip_horizontal) iSDLFlip |= SDL_FLIP_HORIZONTAL;
  if (iFlags & thdf_flip_vertical) iSDLFlip |= SDL_FLIP_VERTICAL;

  if (iSDLFlip != 0) {
    SDL_RenderCopyEx(renderer, pTexture, prcSrcRect, prcDstRect, 0, nullptr,
                     (SDL_RendererFlip)iSDLFlip);
  } else {
    SDL_RenderCopy(renderer, pTexture, prcSrcRect, prcDstRect);
  }
}

void render_target::draw_line(line* pLine, int iX, int iY) {
  SDL_SetRenderDrawColor(renderer, pLine->red, pLine->green, pLine->blue,
                         pLine->alpha);

  double lastX, lastY;
  lastX = pLine->first_operation->x;
  lastY = pLine->first_operation->y;

  line::line_operation* op =
      (line::line_operation*)(pLine->first_operation->next);
  while (op) {
    if (op->type == line::line_operation_type::line) {
      SDL_RenderDrawLine(
          renderer, static_cast<int>(lastX + iX), static_cast<int>(lastY + iY),
          static_cast<int>(op->x + iX), static_cast<int>(op->y + iY));
    }

    lastX = op->x;
    lastY = op->y;

    op = (line::line_operation*)(op->next);
  }
}

raw_bitmap::raw_bitmap() {
  texture = nullptr;
  bitmap_palette = nullptr;
  target = nullptr;
  width = 0;
  height = 0;
}

raw_bitmap::~raw_bitmap() {
  if (texture) {
    SDL_DestroyTexture(texture);
  }
}

void raw_bitmap::set_palette(const palette* pPalette) {
  bitmap_palette = pPalette;
}

void raw_bitmap::load_from_th_file(const uint8_t* pPixelData,
                                   size_t iPixelDataLength, int iWidth,
                                   render_target* pEventualCanvas) {
  if (pEventualCanvas == nullptr) {
    throw std::invalid_argument("pEventualCanvas cannot be null");
  }

  uint8_t* converted_sprite = convertLegacySprite(pPixelData, iPixelDataLength);

  int iHeight = static_cast<int>(iPixelDataLength) / iWidth;
  texture = pEventualCanvas->create_palettized_texture(
      iWidth, iHeight, converted_sprite, bitmap_palette, thdf_alt32_plain);
  delete[] converted_sprite;

  width = iWidth;
  height = iHeight;
  target = pEventualCanvas;
}

namespace {

/**
 * Test whether the loaded full colour sprite loads correctly.
 * @param pData Data of the sprite.
 * @param iDataLength Length of the sprite data.
 * @param iWidth Width of the sprite.
 * @param iHeight Height of the sprite.
 * @return Whether the sprite loads correctly (at the end of the sprite, all
 * data is used).
 */
bool testSprite(const uint8_t* pData, size_t iDataLength, int iWidth,
                int iHeight) {
  if (iWidth <= 0 || iHeight <= 0) return true;

  size_t iCount = iWidth * iHeight;
  while (iCount > 0) {
    if (iDataLength < 1) return false;
    iDataLength--;
    uint8_t iType = *pData++;

    size_t iLength = iType & 63;
    switch (iType >> 6) {
      case 0:  // Fixed fully opaque 32bpp pixels
        if (iCount < iLength || iDataLength < iLength * 3) return false;
        iCount -= iLength;
        iDataLength -= iLength * 3;
        pData += iLength * 3;
        break;

      case 1:  // Fixed partially transparent 32bpp pixels
        if (iDataLength < 1) return false;
        iDataLength--;
        pData++;  // Opacity byte.

        if (iCount < iLength || iDataLength < iLength * 3) return false;
        iCount -= iLength;
        iDataLength -= iLength * 3;
        pData += iLength * 3;
        break;

      case 2:  // Fixed fully transparent pixels
        if (iCount < iLength) return false;
        iCount -= iLength;
        break;

      case 3:  // Recolour layer
        if (iDataLength < 2) return false;
        iDataLength -= 2;
        pData += 2;  // Table number, opacity byte.

        if (iCount < iLength || iDataLength < iLength) return false;
        iCount -= iLength;
        iDataLength -= iLength;
        pData += iLength;
        break;
    }
  }
  return iDataLength == 0;
}

}  // namespace

void raw_bitmap::draw(render_target* pCanvas, int iX, int iY) {
  draw(pCanvas, iX, iY, 0, 0, width, height);
}

void raw_bitmap::draw(render_target* pCanvas, int iX, int iY, int iSrcX,
                      int iSrcY, int iWidth, int iHeight) {
  double fScaleFactor;
  if (texture == nullptr) return;

  if (!pCanvas->should_scale_bitmaps(&fScaleFactor)) {
    fScaleFactor = 1;
  }

  const SDL_Rect rcSrc = {iSrcX, iSrcY, iWidth, iHeight};
  const SDL_Rect rcDest = {iX, iY, static_cast<int>(iWidth * fScaleFactor),
                           static_cast<int>(iHeight * fScaleFactor)};

  pCanvas->draw(texture, &rcSrc, &rcDest, 0);
}

sprite_sheet::sprite_sheet() {
  sprites = nullptr;
  palette = nullptr;
  target = nullptr;
  sprite_count = 0;
}

sprite_sheet::~sprite_sheet() { _freeSprites(); }

void sprite_sheet::_freeSingleSprite(size_t iNumber) {
  if (iNumber >= sprite_count) return;

  if (sprites[iNumber].texture != nullptr) {
    SDL_DestroyTexture(sprites[iNumber].texture);
    sprites[iNumber].texture = nullptr;
  }
  if (sprites[iNumber].alt_texture != nullptr) {
    SDL_DestroyTexture(sprites[iNumber].alt_texture);
    sprites[iNumber].alt_texture = nullptr;
  }
  if (sprites[iNumber].data != nullptr) {
    delete[] sprites[iNumber].data;
    sprites[iNumber].data = nullptr;
  }
}

void sprite_sheet::_freeSprites() {
  for (size_t i = 0; i < sprite_count; ++i) _freeSingleSprite(i);

  delete[] sprites;
  sprites = nullptr;
  sprite_count = 0;
}

void sprite_sheet::set_palette(const ::palette* pPalette) {
  palette = pPalette;
}

bool sprite_sheet::set_sprite_count(size_t iCount, render_target* pCanvas) {
  _freeSprites();

  if (pCanvas == nullptr) return false;
  target = pCanvas;

  sprite_count = iCount;
  sprites = new (std::nothrow) sprite[sprite_count];
  if (sprites == nullptr) {
    sprite_count = 0;
    return false;
  }

  for (size_t i = 0; i < sprite_count; i++) {
    sprite& spr = sprites[i];
    spr.texture = nullptr;
    spr.alt_texture = nullptr;
    spr.data = nullptr;
    spr.alt_palette_map = nullptr;
    spr.sprite_flags = thdf_alt32_plain;
    spr.width = 0;
    spr.height = 0;
  }

  return true;
}

bool sprite_sheet::load_from_th_file(const uint8_t* pTableData,
                                     size_t iTableDataLength,
                                     const uint8_t* pChunkData,
                                     size_t iChunkDataLength,
                                     bool bComplexChunks,
                                     render_target* pCanvas) {
  _freeSprites();
  if (pCanvas == nullptr) return false;

  size_t iCount = iTableDataLength / sizeof(th_sprite_properties);
  if (!set_sprite_count(iCount, pCanvas)) return false;

  for (size_t i = 0; i < sprite_count; ++i) {
    sprite* pSprite = sprites + i;
    const th_sprite_properties* pTHSprite =
        reinterpret_cast<const th_sprite_properties*>(pTableData) + i;

    pSprite->texture = nullptr;
    pSprite->alt_texture = nullptr;
    pSprite->data = nullptr;
    pSprite->alt_palette_map = nullptr;
    pSprite->width = pTHSprite->width;
    pSprite->height = pTHSprite->height;

    if (pSprite->width == 0 || pSprite->height == 0) continue;

    {
      uint8_t* pData = new uint8_t[pSprite->width * pSprite->height];
      chunk_renderer oRenderer(pSprite->width, pSprite->height, pData);
      int iDataLen = static_cast<int>(iChunkDataLength) -
                     static_cast<int>(pTHSprite->position);
      if (iDataLen < 0) iDataLen = 0;
      oRenderer.decode_chunks(pChunkData + pTHSprite->position, iDataLen,
                              bComplexChunks);
      pData = oRenderer.take_data();
      pSprite->data =
          convertLegacySprite(pData, pSprite->width * pSprite->height);
      delete[] pData;
    }
  }
  return true;
}

bool sprite_sheet::set_sprite_data(size_t iSprite, const uint8_t* pData,
                                   bool bTakeData, size_t iDataLength,
                                   int iWidth, int iHeight) {
  if (iSprite >= sprite_count) return false;

  if (!testSprite(pData, iDataLength, iWidth, iHeight)) {
    std::printf("Sprite number %zu has a bad encoding, skipping", iSprite);
    return false;
  }

  _freeSingleSprite(iSprite);
  sprite* pSprite = sprites + iSprite;
  if (bTakeData) {
    pSprite->data = pData;
  } else {
    uint8_t* pNewData = new (std::nothrow) uint8_t[iDataLength];
    if (pNewData == nullptr) return false;

    std::memcpy(pNewData, pData, iDataLength);
    pSprite->data = pNewData;
  }

  pSprite->width = iWidth;
  pSprite->height = iHeight;
  return true;
}

void sprite_sheet::set_sprite_alt_palette_map(size_t iSprite,
                                              const uint8_t* pMap,
                                              uint32_t iAlt32) {
  if (iSprite >= sprite_count) return;

  sprite* pSprite = sprites + iSprite;
  if (pSprite->alt_palette_map != pMap) {
    pSprite->alt_palette_map = pMap;
    pSprite->sprite_flags = iAlt32;
    if (pSprite->alt_texture) {
      SDL_DestroyTexture(pSprite->alt_texture);
      pSprite->alt_texture = nullptr;
    }
  }
}

size_t sprite_sheet::get_sprite_count() const { return sprite_count; }

bool sprite_sheet::get_sprite_size(size_t iSprite, int* pWidth,
                                   int* pHeight) const {
  if (iSprite >= sprite_count) return false;
  if (pWidth != nullptr) *pWidth = sprites[iSprite].width;
  if (pHeight != nullptr) *pHeight = sprites[iSprite].height;
  return true;
}

void sprite_sheet::get_sprite_size_unchecked(size_t iSprite, int* pWidth,
                                             int* pHeight) const {
  *pWidth = sprites[iSprite].width;
  *pHeight = sprites[iSprite].height;
}

bool sprite_sheet::get_sprite_average_colour(size_t iSprite,
                                             argb_colour* pColour) const {
  if (iSprite >= sprite_count) return false;
  const sprite* pSprite = sprites + iSprite;
  int iCountTotal = 0;
  int iUsageCounts[256] = {0};
  for (long i = 0; i < pSprite->width * pSprite->height; ++i) {
    uint8_t cPalIndex = pSprite->data[i];
    uint32_t iColour = palette->get_argb_data()[cPalIndex];
    if ((iColour >> 24) == 0) continue;
    // Grant higher score to pixels with high or low intensity (helps avoid
    // grey fonts)
    int iR = palette::get_red(iColour);
    int iG = palette::get_green(iColour);
    int iB = palette::get_blue(iColour);
    uint8_t cIntensity = static_cast<uint8_t>((iR + iG + iB) / 3);
    int iScore = 1 + std::max(0, 3 - ((255 - cIntensity) / 32)) +
                 std::max(0, 3 - (cIntensity / 32));
    iUsageCounts[cPalIndex] += iScore;
    iCountTotal += iScore;
  }
  if (iCountTotal == 0) return false;
  int iHighestCountIndex = 0;
  for (int i = 0; i < 256; ++i) {
    if (iUsageCounts[i] > iUsageCounts[iHighestCountIndex])
      iHighestCountIndex = i;
  }
  *pColour = palette->get_argb_data()[iHighestCountIndex];
  return true;
}

void sprite_sheet::draw_sprite(render_target* pCanvas, size_t iSprite, int iX,
                               int iY, uint32_t iFlags) {
  if (iSprite >= sprite_count || pCanvas == nullptr || pCanvas != target)
    return;
  sprite& sprite = sprites[iSprite];

  // Find or create the texture
  SDL_Texture* pTexture = sprite.texture;
  if (!pTexture) {
    if (sprite.data == nullptr) return;

    uint32_t iSprFlags =
        (sprite.sprite_flags & ~thdf_alt32_mask) | thdf_alt32_plain;
    pTexture = target->create_palettized_texture(
        sprite.width, sprite.height, sprite.data, palette, iSprFlags);
    sprite.texture = pTexture;
  }
  if (iFlags & thdf_alt_palette) {
    pTexture = sprite.alt_texture;
    if (!pTexture) {
      pTexture = _makeAltBitmap(&sprite);
      if (!pTexture) return;
    }
  }

  SDL_Rect rcSrc = {0, 0, sprite.width, sprite.height};
  SDL_Rect rcDest = {iX, iY, sprite.width, sprite.height};

  pCanvas->draw(pTexture, &rcSrc, &rcDest, iFlags);
}

void sprite_sheet::wx_draw_sprite(size_t iSprite, uint8_t* pRGBData,
                                  uint8_t* pAData) {
  if (iSprite >= sprite_count || pRGBData == nullptr || pAData == nullptr)
    return;
  sprite* pSprite = sprites + iSprite;

  wx_storing oRenderer(pRGBData, pAData, pSprite->width, pSprite->height);
  oRenderer.decode_image(pSprite->data, palette, pSprite->sprite_flags);
}

SDL_Texture* sprite_sheet::_makeAltBitmap(sprite* pSprite) {
  const uint32_t* pPalette = palette->get_argb_data();

  if (!pSprite->alt_palette_map)  // Use normal palette.
  {
    uint32_t iSprFlags =
        (pSprite->sprite_flags & ~thdf_alt32_mask) | thdf_alt32_plain;
    pSprite->alt_texture = target->create_palettized_texture(
        pSprite->width, pSprite->height, pSprite->data, palette, iSprFlags);
  } else if (!pPalette)  // Draw alternative palette, but no palette set (ie
                         // 32bpp image).
  {
    pSprite->alt_texture = target->create_palettized_texture(
        pSprite->width, pSprite->height, pSprite->data, palette,
        pSprite->sprite_flags);
  } else  // Paletted image, build recolour palette.
  {
    ::palette oPalette;
    for (int iColour = 0; iColour < 255; iColour++) {
      oPalette.set_argb(iColour, pPalette[pSprite->alt_palette_map[iColour]]);
    }
    oPalette.set_argb(255,
                      pPalette[255]);  // Colour 0xFF doesn't get remapped.

    pSprite->alt_texture = target->create_palettized_texture(
        pSprite->width, pSprite->height, pSprite->data, &oPalette,
        pSprite->sprite_flags);
  }

  return pSprite->alt_texture;
}

namespace {

/**
 * Get the colour data of pixel \a iPixelNumber (\a iWidth * y + x)
 * @param pImg 32bpp image data.
 * @param iWidth Width of the image.
 * @param iHeight Height of the image.
 * @param pPalette Palette of the image, or \c nullptr.
 * @param iPixelNumber Number of the pixel to retrieve.
 */
uint32_t get32BppPixel(const uint8_t* pImg, int iWidth, int iHeight,
                       const ::palette* pPalette, size_t iPixelNumber) {
  if (iWidth <= 0 || iHeight <= 0 ||
      iPixelNumber >= static_cast<size_t>(iWidth) * iHeight) {
    return palette::pack_argb(0, 0, 0, 0);
  }

  for (;;) {
    uint8_t iType = *pImg++;
    size_t iLength = iType & 63;
    switch (iType >> 6) {
      case 0:  // Fixed fully opaque 32bpp pixels
        if (iPixelNumber >= iLength) {
          pImg += 3 * iLength;
          iPixelNumber -= iLength;
          break;
        }

        while (iLength > 0) {
          if (iPixelNumber == 0)
            return palette::pack_argb(0xFF, pImg[0], pImg[1], pImg[2]);

          iPixelNumber--;
          pImg += 3;
          iLength--;
        }
        break;

      case 1:  // Fixed partially transparent 32bpp pixels
      {
        uint8_t iOpacity = *pImg++;
        if (iPixelNumber >= iLength) {
          pImg += 3 * iLength;
          iPixelNumber -= iLength;
          break;
        }

        while (iLength > 0) {
          if (iPixelNumber == 0)
            return palette::pack_argb(iOpacity, pImg[0], pImg[1], pImg[2]);

          iPixelNumber--;
          pImg += 3;
          iLength--;
        }
        break;
      }

      case 2:  // Fixed fully transparent pixels
      {
        if (iPixelNumber >= iLength) {
          iPixelNumber -= iLength;
          break;
        }

        return palette::pack_argb(0, 0, 0, 0);
      }

      case 3:  // Recolour layer
      {
        uint8_t iTable = *pImg++;
        pImg++;  // Skip reading the opacity for now.
        if (iPixelNumber >= iLength) {
          pImg += iLength;
          iPixelNumber -= iLength;
          break;
        }

        if (iTable == 0xFF && pPalette != nullptr) {
          // Legacy sprite data. Use the palette to recolour the
          // layer. Note that the iOpacity is ignored here.
          const uint32_t* pColours = pPalette->get_argb_data();
          return pColours[pImg[iPixelNumber]];
        } else {
          // TODO: Add proper recolour layers, where RGB comes from
          // table 'iTable' at index *pImg (iLength times), and
          // opacity comes from the byte after the iTable byte.
          //
          // For now just draw black pixels, so it won't go unnoticed.
          return palette::pack_argb(0xFF, 0, 0, 0);
        }
      }
    }
  }
}

}  // namespace

bool sprite_sheet::hit_test_sprite(size_t iSprite, int iX, int iY,
                                   uint32_t iFlags) const {
  if (iX < 0 || iY < 0 || iSprite >= sprite_count) return false;

  sprite& sprite = sprites[iSprite];
  int iWidth = sprite.width;
  int iHeight = sprite.height;
  if (iX >= iWidth || iY >= iHeight) return false;
  if (iFlags & thdf_flip_horizontal) iX = iWidth - iX - 1;
  if (iFlags & thdf_flip_vertical) iY = iHeight - iY - 1;

  uint32_t iCol =
      get32BppPixel(sprite.data, iWidth, iHeight, palette, iY * iWidth + iX);
  return palette::get_alpha(iCol) != 0;
}

cursor::cursor() {
  bitmap = nullptr;
  hotspot_x = 0;
  hotspot_y = 0;
  hidden_cursor = nullptr;
}

cursor::~cursor() {
  SDL_FreeSurface(bitmap);
  SDL_FreeCursor(hidden_cursor);
}

bool cursor::create_from_sprite(sprite_sheet* pSheet, size_t iSprite,
                                int iHotspotX, int iHotspotY) {
#if 0
    SDL_FreeSurface(m_pBitmap);
    m_pBitmap = nullptr;

    if(pSheet == nullptr || iSprite >= pSheet->getSpriteCount())
        return false;
    SDL_Surface *pSprite = pSheet->_getSpriteBitmap(iSprite, 0);
    if(pSprite == nullptr || (m_pBitmap = SDL_DisplayFormat(pSprite)) == nullptr)
        return false;
    m_iHotspotX = iHotspotX;
    m_iHotspotY = iHotspotY;
    return true;
#else
  return false;
#endif
}

void cursor::use(render_target* pTarget) {
#if 0
    //SDL_ShowCursor(0) is buggy in fullscreen until 1.3 (they say)
    //  use transparent cursor for same effect
    uint8_t uData = 0;
    m_pCursorHidden = SDL_CreateCursor(&uData, &uData, 8, 1, 0, 0);
    SDL_SetCursor(m_pCursorHidden);
    pTarget->setCursor(this);
#endif
}

bool cursor::set_position(render_target* pTarget, int iX, int iY) {
#if 0
    pTarget->setCursorPosition(iX, iY);
    return true;
#else
  return false;
#endif
}

void cursor::draw(render_target* pCanvas, int iX, int iY) {
#if 0
    SDL_Rect rcDest;
    rcDest.x = (Sint16)(iX - m_iHotspotX);
    rcDest.y = (Sint16)(iY - m_iHotspotY);
    SDL_BlitSurface(m_pBitmap, nullptr, pCanvas->getRawSurface(), &rcDest);
#endif
}

line::line() { initialize(); }

line::~line() {
  line_operation* op = first_operation;
  while (op) {
    line_operation* next = (line_operation*)(op->next);
    delete (op);
    op = next;
  }
}

void line::initialize() {
  width = 1;
  red = 0;
  green = 0;
  blue = 0;
  alpha = 255;

  // We start at 0,0
  first_operation = new line_operation(line_operation_type::move, 0, 0);
  current_operation = first_operation;
}

void line::move_to(double fX, double fY) {
  line_operation* previous = current_operation;
  current_operation = new line_operation(line_operation_type::move, fX, fY);
  previous->next = current_operation;
}

void line::line_to(double fX, double fY) {
  line_operation* previous = current_operation;
  current_operation = new line_operation(line_operation_type::line, fX, fY);
  previous->next = current_operation;
}

void line::set_width(double pLineWidth) { width = pLineWidth; }

void line::set_colour(uint8_t iR, uint8_t iG, uint8_t iB, uint8_t iA) {
  red = iR;
  green = iG;
  blue = iB;
  alpha = iA;
}

void line::draw(render_target* pCanvas, int iX, int iY) {
  pCanvas->draw_line(this, iX, iY);
}

void line::persist(lua_persist_writer* pWriter) const {
  pWriter->write_uint(static_cast<uint32_t>(red));
  pWriter->write_uint(static_cast<uint32_t>(green));
  pWriter->write_uint(static_cast<uint32_t>(blue));
  pWriter->write_uint(static_cast<uint32_t>(alpha));
  pWriter->write_float(width);

  line_operation* op = (line_operation*)(first_operation->next);
  uint32_t numOps = 0;
  for (; op; numOps++) {
    op = (line_operation*)(op->next);
  }

  pWriter->write_uint(numOps);

  op = (line_operation*)(first_operation->next);
  while (op) {
    pWriter->write_uint(static_cast<uint32_t>(op->type));
    pWriter->write_float<double>(op->x);
    pWriter->write_float(op->y);

    op = (line_operation*)(op->next);
  }
}

void line::depersist(lua_persist_reader* pReader) {
  initialize();

  pReader->read_uint(red);
  pReader->read_uint(green);
  pReader->read_uint(blue);
  pReader->read_uint(alpha);
  pReader->read_float(width);

  uint32_t numOps = 0;
  pReader->read_uint(numOps);

  for (uint32_t i = 0; i < numOps; i++) {
    // Initialize to invalid in case the read fails.
    uint32_t type_val = std::numeric_limits<uint32_t>::max();
    double fX = std::nan("");
    double fY = std::nan("");
    pReader->read_uint(type_val);
    pReader->read_float(fX);
    pReader->read_float(fY);

    if (std::isnan(fX) || std::isnan(fY)) {
      return;
    }

    if (type_val == static_cast<uint32_t>(line_operation_type::move)) {
      move_to(fX, fY);
    } else if (type_val == static_cast<uint32_t>(line_operation_type::line)) {
      line_to(fX, fY);
    }
  }
}

#ifdef CORSIX_TH_USE_FREETYPE2
bool freetype_font::is_monochrome() const { return false; }

void freetype_font::free_texture(cached_text* pCacheEntry) const {
  if (pCacheEntry->texture != nullptr) {
    SDL_DestroyTexture(pCacheEntry->texture);
    pCacheEntry->texture = nullptr;
  }
}

void freetype_font::make_texture(render_target* pEventualCanvas,
                                 cached_text* pCacheEntry) const {
  uint32_t* pPixels = new uint32_t[pCacheEntry->width * pCacheEntry->height];
  std::memset(pPixels, 0,
              pCacheEntry->width * pCacheEntry->height * sizeof(uint32_t));
  uint8_t* pInRow = pCacheEntry->data;
  uint32_t* pOutRow = pPixels;
  uint32_t iColBase = colour & 0xFFFFFF;
  for (int iY = 0; iY < pCacheEntry->height;
       ++iY, pOutRow += pCacheEntry->width, pInRow += pCacheEntry->width) {
    for (int iX = 0; iX < pCacheEntry->width; ++iX) {
      pOutRow[iX] = (static_cast<uint32_t>(pInRow[iX]) << 24) | iColBase;
    }
  }

  pCacheEntry->texture = pEventualCanvas->create_texture(
      pCacheEntry->width, pCacheEntry->height, pPixels);
  delete[] pPixels;
}

void freetype_font::draw_texture(render_target* pCanvas,
                                 cached_text* pCacheEntry, int iX,
                                 int iY) const {
  if (pCacheEntry->texture == nullptr) return;

  SDL_Rect rcDest = {iX, iY, pCacheEntry->width, pCacheEntry->height};
  pCanvas->draw(pCacheEntry->texture, nullptr, &rcDest, 0);
}

#endif  // CORSIX_TH_USE_FREETYPE2
