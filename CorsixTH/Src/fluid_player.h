/*
Copyright (c) 2026 Stephen Baker

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

#ifndef CORSIXTH_TOP_LEVEL_FLUID_PLAYER_H
#define CORSIXTH_TOP_LEVEL_FLUID_PLAYER_H
#include <SDL3/SDL.h>
#include <fluidsynth.h>

#include <array>
#include <string>

namespace th::fluid {
constexpr SDL_AudioFormat audio_format = SDL_AUDIO_F32;
constexpr int audio_channels = 2;
constexpr int audio_freq = 44100;
constexpr int frame_size = sizeof(float) * audio_channels;
constexpr int period_size = 2048;
}  // namespace th::fluid

class fluid_player {
 public:
  explicit fluid_player(const std::string& soundfont);
  fluid_player(const fluid_player&) = delete;
  fluid_player& operator=(const fluid_player&) = delete;
  ~fluid_player();

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
  static void audio_stream_callback(void* userdata, SDL_AudioStream* stream,
                                    int additional_amount, int total_amount);

  fluid_settings_t* settings;
  fluid_synth_t* synth;
  fluid_player_t* player{nullptr};
  int soundfont_id;
  SDL_AudioStream* audio_stream;
  std::array<float, th::fluid::audio_channels * th::fluid::period_size>
      buffer{};
};

#endif  // CORSIXTH_TOP_LEVEL_FLUID_PLAYER_H
