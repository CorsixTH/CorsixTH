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

#ifndef CORSIX_TH_TH_SOUND_H_
#define CORSIX_TH_TH_SOUND_H_
#include "config.h"

#include <SDL_mixer.h>
#include <SDL_rwops.h>

#include <array>
#include <mutex>
#include <vector>

//! Utility class for accessing Theme Hospital's SOUND-0.DAT
class sound_archive {
 public:
  bool load_from_th_file(const uint8_t* pData, size_t iDataLength);

  //! Returns the number of sounds present in the archive
  size_t get_number_of_sounds() const;

  //! Gets the name of the sound at a given index
  const char* get_sound_name(size_t iIndex) const;

  //! Gets the duration (in milliseconds) of the sound at a given index
  size_t get_sound_duration(size_t iIndex);

  //! Opens the sound at a given index into an SDL_RWops structure
  /*!
      The caller is responsible for closing/freeing the result.
  */
  SDL_RWops* load_sound(size_t iIndex);

 private:
  struct sound_dat_sound_info {
    std::array<char, 18> sound_name;
    uint32_t position;
    uint32_t length;
  };

  std::vector<uint8_t> data;
  std::vector<sound_dat_sound_info> sound_files;
};

class sound_player {
 public:
  enum class toggle_pause_result { error, paused, resumed };
  static constexpr uint32_t null_handle = 0u;
  static constexpr int number_of_channels = 32;

  sound_player();
  sound_player(const sound_player&) = delete;
  sound_player& operator=(const sound_player&) = delete;
  ~sound_player();

  static sound_player* get_singleton();

  void populate_from(sound_archive* pArchive);

  //! Plays the sound effect in the sound_archive with the given index.
  //!
  //! \param iIndex Index of the sound effect to play.
  //! \param dVolume Volume to play the sound effect at, in the range 0.0 to
  //!        1.0.
  //! \param loops The number of times to play the sound, -1 for 'practically'
  //!              infinite.
  //! \return The sound handle
  //! \see <a
  //! href="https://wiki.libsdl.org/SDL2_mixer/Mix_PlayChannel">Mix_PlayChannel</a>
  uint32_t play(size_t iIndex, double dVolume, int loops);

  //! Plays the sound effect in the sound_archive with the given index with
  //! volume attenuation based on the distance from the given position to the
  //! camera.
  //!
  //! \param iIndex Index of the sound effect to play.
  //! \param iX X coordinate of the sound effect.
  //! \param iY Y coordinate of the sound effect.
  //! \param loops The number of times to play the sound, -1 for 'practically'
  //!              infinite.
  //! \return The sound handle or 0 on error
  uint32_t play_at(size_t iIndex, int iX, int iY, int loops);

  //! Plays the sound effect in the sound_archive with the given index with
  //! volume attenuation based on the distance from the given position to the
  //! camera.
  //!
  //! \param iIndex Index of the sound effect to play.
  //! \param dVolume Volume to play the sound effect at before attenuation, in
  //!        the range 0.0 to 1.0.
  //! \param iX X coordinate of the sound effect.
  //! \param iY Y coordinate of the sound effect.
  //! \param loops The number of times to play the sound, -1 for 'practically'
  //!              infinite.
  //! \return The sound handle or 0 on error
  uint32_t play_at(size_t iIndex, double dVolume, int iX, int iY, int loops);

  //! Pause playback on a given channel if playing, or resume if paused.
  //!
  //! \param handle The sound to toggle pause on.
  //! \return The result of the toggle: paused, resumed, or error.
  toggle_pause_result toggle_pause(uint32_t handle);

  //! Stops playback on a given channel.
  //!
  //! \param handle The sound to stop.
  void stop(uint32_t handle);

  //! Returns whether the sound matching the given handle is playing
  bool is_playing(uint32_t handle);

  //! Sets the default volume for sound effects.
  void set_sound_effect_volume(double dVolume);

  //! Enables or disables sound effects.
  //! Note: Only affects sounds played via play_at(int, int, int).
  void set_sound_effects_enabled(bool bOn);

  //! Sets the position of the camera for play_at calculations.
  void set_camera(int iX, int iY, int iRadius);

  //! Reserves an SDL_mixer channel for exclusive use.
  //!
  //! Not necessary to use in conjunction with play() or play_at(), as these
  //! methods will automatically reserve and release channels.
  //!
  //! \return The reserved channel index, or -1 if no channels are available.
  int reserve_channel();

  //! Releases a previously reserved SDL_mixer channel.
  void release_channel(int iChannel);

 private:
  static sound_player* singleton;
  static void on_channel_finished(int iChannel);

  uint32_t play_raw(size_t iIndex, int iVolume, int loops);

  //! Returns the channel that the handle is playing on or -1 if it is not
  //! playing.
  int playing_channel_for_handle(uint32_t handle);

  Mix_Chunk** sounds;
  size_t sound_count;
  int camera_x;
  int camera_y;
  double camera_radius;
  double master_volume;
  double sound_effect_volume;
  int positionless_volume;
  bool sound_effects_enabled;

  //! Each channel holds the handle of the track playing on it or null_handle
  //! if it is free.
  std::array<uint32_t, number_of_channels> channels{};
  uint32_t next_playing_track_handle{0};
  std::recursive_mutex channel_mutex{};
};

#endif  // CORSIX_TH_TH_SOUND_H_
