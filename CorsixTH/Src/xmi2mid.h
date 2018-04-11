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

#ifndef CORSIX_TH_XMI2MID_H_
#define CORSIX_TH_XMI2MID_H_
#include "config.h"
#ifdef CORSIX_TH_USE_SDL_MIXER

uint8_t* transcode_xmi_to_midi(const unsigned char* xmi_data,
                                 size_t xmi_length, size_t* midi_length);

#else // CORSIX_TH_USE_SDL_MIXER

inline uint8_t* transcode_xmi_to_midi(const unsigned char* xmi_data,
                                 size_t xmi_length, size_t* midi_length)
{
    // When SDL_mixer isn't being used, there is no need to transocde XMI to
    // MIDI, so the function always fails.
    return nullptr;
}

#endif // CORSIX_TH_USE_SDL_MIXER
#endif // CORSIX_TH_XMI2MID_H_
