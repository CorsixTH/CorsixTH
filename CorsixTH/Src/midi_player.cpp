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

#include "midi_player.h"

#include "config.h"

#include <SDL_events.h>

#include <algorithm>
#include <chrono>
#include <cstdio>
#include <queue>

#include "lua_sdl.h"
#include "xmi2mid.h"

#ifdef WITH_MIDI_DEVICE

namespace {

const char* const MIDI_VIRTUAL_PORT_NAME = "Virtual Port";
const unsigned int MIDI_CHANNELS = 16;

bool api_supports_virtual_port(RtMidi::Api api) {
  switch (api) {
    case RtMidi::MACOSX_CORE:
    case RtMidi::LINUX_ALSA:
    case RtMidi::UNIX_JACK:
      return true;
    default:
      return false;
  }
}

void send_stop_playback(RtMidiOut& midi_out) {
  std::vector<uint8_t> buffer(3);
  for (unsigned int channel = 0; channel < MIDI_CHANNELS; ++channel) {
    buffer[0] = static_cast<unsigned char>(midi_event_control_change | channel);
    buffer[2] = 0x00;

    buffer[1] = midi_channel_code_all_notes_off;
    midi_out.sendMessage(&buffer);

    buffer[1] = midi_channel_code_all_sound_off;
    midi_out.sendMessage(&buffer);

    buffer[1] = midi_channel_code_reset_controllers;
    midi_out.sendMessage(&buffer);
  }
}

void send_all_notes_off(RtMidiOut& midi_out) {
  std::vector<uint8_t> buffer(3);
  for (unsigned int channel = 0; channel < MIDI_CHANNELS; ++channel) {
    buffer[0] = static_cast<unsigned char>(midi_event_control_change | channel);
    buffer[1] = midi_channel_code_all_notes_off;
    buffer[2] = 0x00;

    midi_out.sendMessage(&buffer);
  }
}

/**
 * Sends a message to enable GM mode.
 *
 * From the MIDI 1.0 Detailed Specification: General MIDI System Messages
 */
void send_gsm_enable(RtMidiOut& midi_out) {
  std::vector<unsigned char> buffer;
  buffer.push_back(midi_event_sysex);
  buffer.push_back(0x7E);  // Non-realtime
  buffer.push_back(0x7F);  // All devices
  buffer.push_back(0x09);  // General MIDI
  buffer.push_back(0x01);  // Enable
  buffer.push_back(midi_event_end_of_sysex);
  midi_out.sendMessage(&buffer);
}

/**
 * Sends the master volume level.
 *
 * From the MIDI 1.0 Detailed Specification: Device Control
 * \param midi_out The MIDI output device
 * \param volume The volume level, in the range 0.0 (silent) to 1.0 (maximum)
 */
void send_master_volume(RtMidiOut& midi_out, double volume) {
  uint16_t vol14bit = std::clamp(static_cast<int>(volume * 16383.0), 0, 16383);

  std::vector<unsigned char> buffer;
  buffer.push_back(midi_event_sysex);
  buffer.push_back(0x7F);                    // Realtime
  buffer.push_back(0x7F);                    // All devices
  buffer.push_back(0x04);                    // Device Control
  buffer.push_back(0x01);                    // Master Volume MSB
  buffer.push_back(vol14bit & 0x7F);         // (least significant 7 bits)
  buffer.push_back((vol14bit >> 7) & 0x7F);  // (most significant 7 bits)
  buffer.push_back(midi_event_end_of_sysex);

  midi_out.sendMessage(&buffer);
}

void send_control_change_volume(RtMidiOut& midi_out,
                                std::vector<uint8_t> channel_volumes,
                                double volume) {
  if (channel_volumes.size() != MIDI_CHANNELS) {
    throw std::invalid_argument("channel_volumes must have 16 elements");
  }

  std::vector<uint8_t> buffer(3);
  for (unsigned int channel = 0; channel < MIDI_CHANNELS; ++channel) {
    uint8_t vol7bit =
        std::clamp(static_cast<int>(volume * channel_volumes[channel]), 0, 127);
    buffer[0] = static_cast<unsigned char>(midi_event_control_change | channel);
    buffer[1] = midi_control_code_volume;
    buffer[2] = vol7bit;

    midi_out.sendMessage(&buffer);
  }
}

void send_control_change_volume(RtMidiOut& midi_out, double volume) {
  send_control_change_volume(midi_out, std::vector<uint8_t>(MIDI_CHANNELS, 127),
                             volume);
}

void midi_music_over_callback() {
  SDL_Event e;
  e.type = SDL_USEREVENT_MUSIC_OVER;
  SDL_PushEvent(&e);
}

}  // namespace

void player_command_queue::push(player_command cmd) {
  std::unique_lock lock(mut);
  queue.push(cmd);
  cv.notify_one();
}

player_command player_command_queue::pop(bool blocking) {
  std::unique_lock lock(mut);
  while (blocking && queue.empty()) {
    cv.wait(lock);
  }
  if (queue.empty()) {
    return player_command::noop;
  }
  player_command cmd = queue.front();
  queue.pop();
  return cmd;
}

void player_command_queue::clear() {
  std::unique_lock lock(mut);
  while (!queue.empty()) {
    queue.pop();
  }
}

struct playback_state {
  midi_player& player;
  player_command_queue& command_queue;
  midi_token_list events;

  size_t current_event_index{0};

  //! Start time, adjusted for any pauses
  std::chrono::time_point<std::chrono::steady_clock> adjusted_start_time{
      std::chrono::steady_clock::now()};

  explicit playback_state(midi_player& player,
                          player_command_queue& command_queue,
                          midi_token_list&& events)
      : player{player},
        command_queue{command_queue},
        events{std::move(events)} {}
};

midi_player::midi_player(RtMidi::Api api, std::string_view device_name,
                         bool use_sysex_master_volume)
    : midi_out(std::make_unique<RtMidiOut>(api)),
      use_master_volume_sysex(use_sysex_master_volume) {
  set_port(device_name);
}

midi_player::~midi_player() { stop(); }

std::vector<RtMidi::Api> midi_player::api_list() {
  std::vector<RtMidi::Api> apis;
  RtMidi::getCompiledApi(apis);
  return apis;
}

std::vector<std::string> midi_player::port_list() const {
  unsigned int pc = midi_out->getPortCount();
  std::vector<std::string> devices;
  devices.reserve(pc);
  for (unsigned int i = 0; i < pc; i++) {
    devices.push_back(midi_out->getPortName(i));
  }

  // A few APIs support virtual ports, add those too
  if (api_supports_virtual_port(midi_out->getCurrentApi())) {
    devices.emplace_back(MIDI_VIRTUAL_PORT_NAME);
  }

  return devices;
}

void midi_player::set_api(RtMidi::Api api) {
  std::unique_lock lock(midi_out_mutex);
  RtMidiOut tmp(api);
  midi_out = std::make_unique<RtMidiOut>(api);
  open_default_port();
}

void midi_player::set_port(std::string_view device_name) {
  std::unique_lock lock(midi_out_mutex);
  if (device_name.empty()) {
    open_default_port();
    return;
  }
  for (unsigned int i = 0; i < midi_out->getPortCount(); i++) {
    if (midi_out->getPortName(i) == device_name) {
      port.emplace(*midi_out, i);
      return;
    }
  }
  if (device_name == MIDI_VIRTUAL_PORT_NAME) {
    port.emplace(*midi_out, MIDI_VIRTUAL_PORT_INDEX);
    return;
  }
  std::fprintf(stderr, "MIDI device not found: %s\n",
               std::string(device_name).c_str());
}

void midi_player::play_xmi(const unsigned char* xmi_data, size_t xmi_length) {
  if (!midi_out->isPortOpen()) {
    std::fprintf(stderr, "No MIDI port is open for playback\n");
    return;
  }

  uint32_t tempo;
  midi_token_list events = xmi_to_midi_token_list(xmi_data, xmi_length, tempo);

  playback_state song(*this, command_queue, std::move(events));
  stop();
  playback_thread = std::thread(playback_loop, std::move(song));
}

void midi_player::set_volume(double v) {
  volume.store(v);
  command_queue.push(player_command::set_volume);
}

void midi_player::stop() {
  if (playback_thread.joinable()) {
    command_queue.push(player_command::stop);
    playback_thread.join();
  }
  command_queue.clear();

  std::unique_lock lock(midi_out_mutex);
  if (midi_out->isPortOpen()) {
    send_stop_playback(*midi_out);
  }
}

void midi_player::pause() { command_queue.push(player_command::pause); }

void midi_player::resume() { command_queue.push(player_command::resume); }

void midi_player::open_default_port() {
  for (unsigned int i = 0; i < midi_out->getPortCount(); i++) {
    try {
      port.emplace(*midi_out, i);
      return;
    } catch (RtMidiError& err) {
      // Ignore errors finding a port
      std::fprintf(stderr, "Failed to open MIDI port %u: %s\n", i,
                   err.getMessage().c_str());
    }
  }
  if (api_supports_virtual_port(midi_out->getCurrentApi())) {
    try {
      port.emplace(*midi_out, MIDI_VIRTUAL_PORT_INDEX);
    } catch (RtMidiError& err) {
      std::fprintf(stderr, "Failed to open Virtual MIDI port: %s\n",
                   err.getMessage().c_str());
    }
  }
  std::fprintf(stderr, "No suitable MIDI output port found\n");
}

void midi_player::init_playback(playback_state& state) {
  std::unique_lock lock(state.player.midi_out_mutex);

  if (!state.player.midi_out->isPortOpen() || !state.player.port.has_value()) {
    // Should not be possible due to checks before starting playback
    throw std::runtime_error("MIDI port is not open for playback");
  }

  send_gsm_enable(*state.player.midi_out);

  if (state.player.use_master_volume_sysex) {
    send_master_volume(*state.player.midi_out, state.player.volume.load());
  } else {
    send_control_change_volume(*state.player.midi_out,
                               state.player.volume.load());
  }

  state.adjusted_start_time = std::chrono::steady_clock::now();
}

void midi_player::playback_loop(playback_state&& state) {
  try {
    init_playback(state);
  } catch (std::exception& e) {
    fprintf(stderr, "Aborting MIDI playback: %s", e.what());
    return;
  }

  bool paused = false;
  std::chrono::time_point<std::chrono::steady_clock> pause_time;
  std::vector<unsigned char> msg_buffer;
  std::vector<uint8_t> channel_volumes(MIDI_CHANNELS, 127);
  while (state.current_event_index < state.events.size()) {
    // Block for commands if paused, otherwise just check for them
    const player_command cmd = state.command_queue.pop(paused);

    switch (cmd) {
      case player_command::stop:
        return;
      case player_command::pause: {
        paused = true;
        pause_time = std::chrono::steady_clock::now();
        std::unique_lock lock(state.player.midi_out_mutex);
        send_all_notes_off(*state.player.midi_out);
      } break;
      case player_command::resume:
        if (paused) {
          paused = false;
          auto pause_duration = std::chrono::steady_clock::now() - pause_time;
          state.adjusted_start_time += pause_duration;
        }
        break;
      case player_command::set_volume:
        if (state.player.use_master_volume_sysex) {
          send_master_volume(*state.player.midi_out,
                             state.player.volume.load());
        } else {
          send_control_change_volume(*state.player.midi_out, channel_volumes,
                                     state.player.volume.load());
        }
        break;
      case player_command::noop:
        // No operation
        break;
    }

    if (paused) {
      continue;
    }

    const midi_token& event = state.events[state.current_event_index];
    if (event.type == midi_event_meta &&
        event.data == midi_meta_event_end_of_track) {
      break;
    }

    std::chrono::microseconds event_time_microseconds{
        static_cast<int64_t>(event.time * xmi_microseconds_per_tick)};

    std::chrono::duration event_wait = state.adjusted_start_time -
                                       std::chrono::steady_clock::now() +
                                       event_time_microseconds;
    if (event_wait.count() > 0) {
      std::this_thread::sleep_for(event_wait);
    }

    if (event.type == midi_event_meta) {
      // Skip meta events except end of track
      state.current_event_index++;
      continue;
    }

    msg_buffer.clear();
    msg_buffer.push_back(event.type);
    msg_buffer.push_back(event.data);
    if (!event.buffer.empty()) {
      msg_buffer.insert(msg_buffer.end(), event.buffer.begin(),
                        event.buffer.end());
    }

    if ((event.type & 0xF0) == midi_event_control_change &&
        event.data == midi_control_code_volume && msg_buffer.size() == 3 &&
        !state.player.use_master_volume_sysex) {
      channel_volumes[event.type & 0x0F] = msg_buffer[2];
      msg_buffer[2] = static_cast<uint8_t>(std::clamp(
          static_cast<int>(msg_buffer[2] * state.player.volume.load() * 127.0),
          0, 127));
    }

    std::unique_lock lock(state.player.midi_out_mutex);
    state.player.midi_out->sendMessage(&msg_buffer);
    state.current_event_index++;
  }

  midi_music_over_callback();
}

#endif  // WITH_MIDI_DEVICE
