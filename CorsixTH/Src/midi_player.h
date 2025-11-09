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

/**
 * An index representing the virtual port
 */
constexpr unsigned int midi_virtual_port_index = UINT_MAX;

/**
 * The port name for the corsixth source
 */
const char* const midi_external_port_name = "midi_out";

/**
 * Holds a MIDI port open for the lifetime of the object and releases it after.
 *
 * Instances of this class must not out-live the midi_out they reference.
 */
class open_midi_port {
 public:
  /**
   * Open the given port on midi_out
   * @param midi_out The midi library
   * @param port The RtMidiOut port index, or midi_virtual_port_index for a
   *             virtual port.
   */
  open_midi_port(RtMidiOut& midi_out, unsigned int port)
      : midi_out(midi_out), port(port) {
    if (port == midi_virtual_port_index) {
      midi_out.openVirtualPort(midi_external_port_name);
    } else {
      midi_out.openPort(port, midi_external_port_name);
    }
  }
  open_midi_port(const open_midi_port&) = delete;
  open_midi_port& operator=(const open_midi_port&) = delete;
  open_midi_port(const open_midi_port&&) = delete;
  open_midi_port& operator=(const open_midi_port&&) = delete;

  /**
   * Release the open port
   */
  ~open_midi_port() { midi_out.closePort(); }

  /**
   * True if the port is virtual (midi_virtual_port_index)
   */
  bool is_virtual() const { return port == midi_virtual_port_index; }

  /**
   * The owned port index
   */
  unsigned int get_port() const { return port; }

 private:
  /// Reference to MIDI API
  RtMidiOut& midi_out;

  /// Owned/opened port index
  unsigned int port;
};

/**
 * Commands between the midi_player and the playback thread
 */
enum class player_command {
  /// Stop MIDI playback
  stop,

  /// Pause MIDI playback with the intention to resume from the same point
  pause,

  /// Resume MIDI playback after pause
  resume,

  /// Adjust the master volume level, based on the currently set value in
  /// midi_player
  set_volume,

  /// Continue processing as if there was no command
  noop
};

/**
 * A thread safe queue of player_command with optional blocking on pop
 *
 * For sharing commands between the playback thread and the main thread.
 */
class player_command_queue {
 public:
  /**
   * Push a command to the back of the queue
   * @param command The command to push
   */
  void push(player_command command);

  /**
   * Pop a command off the queue
   *
   * Waits if the queue is empty and blocking is set to true.
   * @param blocking Whether to block and wait for a command if the queue is
   *                 empty
   * @return The command at the front of the queue, or noop if the queue is
   *         empty.
   */
  player_command pop(bool blocking);

  /**
   * Empty the queue
   */
  void clear();

 private:
  /// Mutex to guard the queue
  std::mutex mut{};

  /// The queue
  std::queue<player_command> queue{};

  /// Condition to wait on when empty and notify when populated
  std::condition_variable cv{};
};

/**
 * Control class for playing MIDI
 */
class midi_player {
 public:
  /**
   * Initialize a connection on a given MIDI API and port for playing CorsixTH
   * XMI files
   *
   * @param api The MIDI API to use, one of:
   *   \li <empty string> or "Native" - Any available API
   *   \li "ALSA" - Linux ALSA
   *   \li "JACK" - JACK on Linux and Unix where available
   *   \li "CoreMIDI" - MacOS CoreMIDI
   *   \li "Windows MM" - Windows MIDI Api
   *   \li "Web MIDI API" - Web MIDI API
   *   \li "Windows UWP" - Universal Windows Platform MIDI API (RtMidi 6+)
   *   \li "Android AMIDI" - Android MIDI API (AMIDI) (RtMidi 6+)
   *
   *   Use media_player::api_list() to find the list available for the target
   *   device
   *
   * @param port_name The MIDI port name to connect to. Empty string will
   *   connect to any available port. A list can be obtained from
   *   midi_player::port_list(). The list depends on the selected api.
   *
   * @param use_master_volume_sysex If true volume is assigned using the master
   *   volume sysex sequence. If false then the volume is set by relatively
   *   adjusting the control volumes of each channel during playback. Many
   *   synthesizers do not support the master volume sysex.
   */
  midi_player(std::string_view api, std::string_view port_name,
              bool use_master_volume_sysex);
  midi_player(const midi_player&) = delete;
  midi_player& operator=(const midi_player&) = delete;
  ~midi_player();

  /**
   * List of available APIs on the target
   */
  static std::vector<std::string> api_list();

  /**
   * List of available port names for the current API
   */
  std::vector<std::string> port_list() const;

  /**
   * Change the currently connected port
   *
   * \see midi_player:port_list()
   */
  void set_port(std::string_view port_name);

  /**
   * Set the relative playback volume
   * @param volume volume between 0 and 1
   */
  void set_volume(double volume);

  /**
   * Play the given XMI file
   * @param xmi_data The raw bytes of the uncompressed XMI file
   * @param xmi_length The length of the data
   */
  void play_xmi(const unsigned char* xmi_data, size_t xmi_length);

  /**
   * Stop the currently playing MIDI track
   *
   * Resets the MIDI device and stops the playback thread.
   */
  void stop();

  /**
   * Pause the currently playing MIDI track
   */
  void pause();

  /**
   * Resume the current MIDI track if paused
   */
  void resume();

 private:
  /**
   * Open the first successful MIDI output port, or a virtual port if supported.
   *
   * It is assumed that midi_out_mutex is held by the caller.
   */
  void open_default_port();

  /**
   * Return true if the MIDI port is open both according to our code and the
   * RtMidi library.
   *
   * \remark RtMidi isPortOpen always returns false on virtual ports. This
   * method returns true if we expect a virtual port to be open.
   */
  bool is_port_open() const;

  /**
   * Setup the MIDI device for playback
   *
   * \remark Intended to be called from the playback thread
   * @param state Playback data for the current song
   */
  static void init_playback(playback_state& state);

  /**
   * Play a MIDI song until completion or interruption by a stop command
   *
   * \remark Intended to be the target of the playback thread
   * @param state Playback data for the current song
   */
  static void playback_loop(playback_state&& state);

  /// The MIDI library
  std::unique_ptr<RtMidiOut> midi_out;

  /// Port currently in use if any
  std::optional<open_midi_port> port;

  /// The thread that runs the playback_loop while the MIDI is playing or paused
  std::thread playback_thread{};

  /// Queue for communicating between the main thread and the playback thread
  player_command_queue command_queue{};

  /// The currently assigned music volume
  std::atomic<double> volume{1.0};

  /// Whether to use sysex master volume, if true or control volume (CC 7), if
  /// false
  bool use_master_volume_sysex{false};

  /// Mutex to prevent race conditions on access to midi_out
  std::mutex midi_out_mutex{};
};

#else  // WITH_MIDI_DEVICE

class midi_player {};

#endif  // WITH_MIDI_DEVICE

#endif  // CORSIX_TH_MIDI_PLAYER_H
