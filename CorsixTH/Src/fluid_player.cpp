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

#include "fluid_player.h"

#include <cstdio>
#include <memory>
#include <stdexcept>

#include "xmi2mid.h"

fluid_player::fluid_player(const std::string& soundfont) {
  SDL_AudioSpec spec;
  spec.format = th::fluid::audio_format;
  spec.channels = th::fluid::audio_channels;
  spec.freq = th::fluid::audio_freq;

  audio_stream = SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK,
                                           &spec, audio_stream_callback, this);

  settings = new_fluid_settings();

  // match SDL audio settings
  fluid_settings_setint(settings, "audio.period-size", th::fluid::period_size);
  fluid_settings_setstr(settings, "audio.sample-format", "float");
  fluid_settings_setint(settings, "synth.audio-channels", 1);
  fluid_settings_setint(settings, "synth.audio-groups", 1);
  fluid_settings_setnum(settings, "synth.sample-rate", th::fluid::audio_freq);

  // Let SDL3 manage the volume
  fluid_settings_setnum(settings, "synth.gain", 1.0);

  // sound settings, matching defaults from fluidsynth 2.6
  // older defaults were not ideal.
  fluid_settings_setnum(settings, "synth.chorus.depth", 4.25);
  fluid_settings_setnum(settings, "synth.chorus.level", 0.6);
  fluid_settings_setint(settings, "synth.chorus.nr", 3);
  fluid_settings_setnum(settings, "synth.chorus.speed", 0.2);
  fluid_settings_setnum(settings, "synth.reverb.damp", 0.3);
  fluid_settings_setnum(settings, "synth.reverb.level", 0.7);
  fluid_settings_setnum(settings, "synth.reverb.room-size", 0.5);
  fluid_settings_setnum(settings, "synth.reverb.width", 0.8);

  // xmi / TH music settings
  fluid_settings_setstr(settings, "synth.midi-bank-select", "gm");

  synth = new_fluid_synth(settings);
  soundfont_id = fluid_synth_sfload(synth, soundfont.c_str(), true);
  if (soundfont_id == FLUID_FAILED) {
    std::fprintf(stderr, "Failed to load soundfont: %s\n", soundfont.c_str());
  }
}

fluid_player::~fluid_player() {
  stop();
  SDL_PauseAudioStreamDevice(audio_stream);
  SDL_DestroyAudioStream(audio_stream);
  delete_fluid_synth(synth);
  delete_fluid_settings(settings);
}

void fluid_player::set_volume(double volume) {
  SDL_SetAudioStreamGain(audio_stream, static_cast<float>(volume));
}

void fluid_player::play_xmi(const unsigned char* xmi_data, size_t xmi_length) {
  if (player) {
    stop();
  }

  size_t midi_length;
  const std::unique_ptr<uint8_t[]> midi_data{
      transcode_xmi_to_midi(xmi_data, xmi_length, &midi_length)};
  if (midi_data == nullptr) {
    throw std::runtime_error("Unable to transcode XMI data");
  }

  player = new_fluid_player(synth);
  fluid_player_add_mem(player, midi_data.get(), midi_length);
  fluid_player_seek(player, 0);
  fluid_player_play(player);
  SDL_ResumeAudioStreamDevice(audio_stream);
}

void fluid_player::pause() { fluid_player_stop(player); }

void fluid_player::resume() { fluid_player_play(player); }

void fluid_player::stop() {
  if (player == nullptr) {
    return;
  }

  fluid_player_stop(player);
  fluid_synth_all_notes_off(synth, -1);
  delete_fluid_player(player);
  SDL_PauseAudioStreamDevice(audio_stream);
  player = nullptr;
}

void fluid_player::audio_stream_callback(void* userdata,
                                         SDL_AudioStream* stream,
                                         int additional_amount,
                                         int /*total_amount*/) {
  auto* plr = static_cast<fluid_player*>(userdata);

  while (additional_amount > 0) {
    int buffer_size =
        std::min(additional_amount,
                 static_cast<int>(plr->buffer.size() * sizeof(float)));
    fluid_synth_write_float(plr->synth, buffer_size / th::fluid::frame_size,
                            plr->buffer.data(), 0, 2, plr->buffer.data(), 1, 2);
    SDL_PutAudioStreamData(stream, plr->buffer.data(), buffer_size);
    additional_amount -= buffer_size;
  }
}
