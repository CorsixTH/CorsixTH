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
#ifndef CORSIX_TH_TH_GFX_COMMON_H_
#define CORSIX_TH_TH_GFX_COMMON_H_

#include "config.h"

// This header is meant to be shared with GFX and GFX_SDL

//! Animation Overlay Flags for drawing an overlay on top of all the frame
enum animation_overlay_flags : uint32_t {
  //! No Overlay
  thaof_none = 0,
  //! Serious Radiation Overlay
  thaof_glowing = 1 << 0,
  //! Jellyitis animation
  thaof_jelly = 1 << 1,
};

#endif
