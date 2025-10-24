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
  sound_player();
  sound_player(const sound_player&) = delete;
  sound_player& operator=(const sound_player&) = delete;
  ~sound_player();

  static sound_player* get_singleton();

  void populate_from(sound_archive* pArchive);

  void play(size_t iIndex, double dVolume);
  void play_at(size_t iIndex, int iX, int iY);
  void play_at(size_t iIndex, double dVolume, int iX, int iY);
  void set_sound_effect_volume(double dVolume);
  void set_sound_effects_enabled(bool bOn);
  void set_camera(int iX, int iY, int iRadius);
  int reserve_channel();
  void release_channel(int iChannel);

 private:
  static sound_player* singleton;
  static void on_channel_finished(int iChannel);

  inline void play_raw(size_t iIndex, int iVolume);

  Mix_Chunk** sounds;
  size_t sound_count;
  uint32_t available_channels_bitmap;  ///< The bit index corresponding to a
                                       ///< channel is 1 if the channel is
                                       ///< available and 0 if it is reserved
                                       ///< or in use.
  int camera_x;
  int camera_y;
  double camera_radius;
  double master_volume;
  double sound_effect_volume;
  int positionless_volume;
  bool sound_effects_enabled;
};

#endif  // CORSIX_TH_TH_SOUND_H_
