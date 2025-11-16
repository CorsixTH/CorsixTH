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

#include <vector>

// MIDI Events are from the MIDI 1.0 Spec
// MIDI Meta Events are from the Standard MIDI File Spec 1.0
// Both specs are available from the MIDI Association website:
// https://www.midi.org

constexpr uint8_t midi_event_note_off = 0x80;
constexpr uint8_t midi_event_note_on = 0x90;
constexpr uint8_t midi_event_poly_key_pressure = 0xA0;
constexpr uint8_t midi_event_control_change = 0xB0;
constexpr uint8_t midi_event_program_change = 0xC0;
constexpr uint8_t midi_event_channel_pressure = 0xD0;
constexpr uint8_t midi_event_pitch_bend = 0xE0;

constexpr uint8_t midi_event_sysex = 0xF0;
constexpr uint8_t midi_event_end_of_sysex = 0xF7;
constexpr uint8_t midi_event_meta = 0xFF;

constexpr uint8_t midi_meta_event_end_of_track = 0x2F;
constexpr uint8_t midi_meta_event_set_tempo = 0x51;

constexpr uint8_t midi_control_code_volume = 7;

constexpr uint8_t midi_channel_code_all_notes_off = 123;
constexpr uint8_t midi_channel_code_all_sound_off = 120;
constexpr uint8_t midi_channel_code_reset_controllers = 121;

namespace {

// Multiply the time duration of XMI events and the tempo by this factor.
// The idea is to reduce the rounding errors that occur when converting from
// XMI's 120Hz timing to MIDI's microseconds per quarter note timing.
// Larger values reduce rounding errors but also increase the chance of hitting
// the maximum MIDI division of 0x7FFF (32767).
//
// Experimentally 100 results in a division of 10000 for the fastest tempo in
// Theme Hospital. Many but not all tracks have exact timing with a value of 1.
constexpr int time_multiplier = 100;

}  // namespace

// There are 120 ticks per second in XMI timing (which reduces to 3 / 25000us).
constexpr double xmi_ticks_per_microsecond = (3.0 * time_multiplier) / 25000.0;
constexpr double xmi_microseconds_per_tick = 25000.0 / (3.0 * time_multiplier);

struct midi_token {
  int time;
  std::vector<uint8_t> buffer{};
  uint8_t type;
  uint8_t data{0};

  midi_token(int time, uint8_t type) : time(time), type(type) {}
};

bool operator<(const midi_token& oLeft, const midi_token& oRight);

using midi_token_list = std::vector<midi_token>;

midi_token_list xmi_to_midi_token_list(const unsigned char* xmi_data,
                                       size_t xmi_length, uint32_t& iTempo);

uint8_t* transcode_xmi_to_midi(const unsigned char* xmi_data, size_t xmi_length,
                               size_t* midi_length);

#endif  // CORSIX_TH_XMI2MID_H_
