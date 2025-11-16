/*
Copyright (c) 2025 Stephen Baker

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

#ifndef CORSIX_TH_MIDI_PLAYER_H
#define CORSIX_TH_MIDI_PLAYER_H

#include "config.h"

#ifdef WITH_MIDI_DEVICE
#include <rtmidi/RtMidi.h>

#include <atomic>
#include <climits>
#include <condition_variable>
#include <memory>
#include <optional>
#include <queue>
#include <string>
#include <thread>
#include <vector>

struct playback_state;

constexpr unsigned int MIDI_VIRTUAL_PORT_INDEX = UINT_MAX;
const char* const MIDI_EXTERNAL_VIRTUAL_PORT_NAME = "CorsixTH Virtual Port";
const char* const MIDI_EXTERNAL_PORT_NAME = "CorsixTH";

class open_midi_port {
 public:
  open_midi_port(RtMidiOut& midi_out, unsigned int port)
      : midi_out(midi_out), port(port) {
    if (port == MIDI_VIRTUAL_PORT_INDEX) {
      midi_out.openVirtualPort(MIDI_EXTERNAL_VIRTUAL_PORT_NAME);
    } else {
      midi_out.openPort(port, MIDI_EXTERNAL_PORT_NAME);
    }
  }

  ~open_midi_port() { midi_out.closePort(); }

  unsigned int get_port() const { return port; }

 private:
  RtMidiOut& midi_out;
  unsigned int port;
};

enum class player_command { stop, pause, resume, set_volume, noop };

class player_command_queue {
 public:
  void push(player_command command);
  player_command pop(bool blocking);
  void clear();

 private:
  std::mutex mut{};
  std::queue<player_command> queue{};
  std::condition_variable cv{};
};

class midi_player {
 public:
  midi_player(RtMidi::Api api, std::string_view port_name,
              bool use_master_volume_sysex);
  midi_player(midi_player&) = delete;
  midi_player& operator=(midi_player&) = delete;
  ~midi_player();

  void set_api(RtMidi::Api api);
  static std::vector<RtMidi::Api> api_list();
  std::vector<std::string> port_list() const;
  void set_port(std::string_view port_name);
  void set_volume(double volume);

  void play_xmi(const unsigned char* xmi_data, size_t xmi_length);
  void stop();
  void pause();
  void resume();

 private:
  /**!
   * Open the first successful MIDI output port, or a virtual port if supported.
   *
   * It is assumed that midi_out_mutex is held by the caller.
   */
  void open_default_port();

  static void init_playback(playback_state& state);
  static void playback_loop(playback_state&& state);

  std::unique_ptr<RtMidiOut> midi_out;
  std::optional<open_midi_port> port;
  std::thread playback_thread{};
  player_command_queue command_queue{};
  std::atomic<double> volume{1.0};
  bool use_master_volume_sysex{false};
  std::mutex midi_out_mutex{};
};

#else  // WITH_MIDI_DEVICE

class midi_player {};

#endif  // WITH_MIDI_DEVICE

#endif  // CORSIX_TH_MIDI_PLAYER_H
