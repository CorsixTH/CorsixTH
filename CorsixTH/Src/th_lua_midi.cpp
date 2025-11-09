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

#include "lua.hpp"
#include "midi_player.h"
#include "th_lua.h"
#include "th_lua_internal.h"

namespace {

#ifdef WITH_MIDI_DEVICE

RtMidi::Api midi_api_from_string(std::string_view apiName) {
  if (apiName.empty() || apiName == "Native") {
    return RtMidi::UNSPECIFIED;
  } else if (apiName == "ALSA") {
    return RtMidi::LINUX_ALSA;
  } else if (apiName == "JACK") {
    return RtMidi::UNIX_JACK;
  } else if (apiName == "CoreMIDI") {
    return RtMidi::MACOSX_CORE;
  } else if (apiName == "Windows MM") {
    return RtMidi::WINDOWS_MM;
  } else if (apiName == "Web MIDI API") {
    return RtMidi::WEB_MIDI_API;
  }
#if RTMIDI_MAJOR_VERSION > 5
  if (apiName == "Windows UWP") {
    return RtMidi::WINDOWS_UWP;
  } else if (apiName == "Android AMidi") {
    return RtMidi::ANDROID_AMIDI;
  }
#endif
  throw std::invalid_argument("Unknown API name");
}

int l_midi_player_api_list(lua_State* L) {
  std::vector<RtMidi::Api> apis;
  RtMidi::getCompiledApi(apis);

  lua_createtable(L, static_cast<int>(apis.size()) + 2, 0);
  lua_pushinteger(L, 1);
  lua_pushstring(L, "Default");
  lua_settable(L, -3);
  for (size_t i = 0; i < apis.size(); ++i) {
    lua_pushinteger(L, static_cast<lua_Integer>(i) + 2);
    switch (apis[i]) {
      case RtMidi::LINUX_ALSA:
        lua_pushstring(L, "ALSA");
        break;
      case RtMidi::UNIX_JACK:
        lua_pushstring(L, "JACK");
        break;
      case RtMidi::MACOSX_CORE:
        lua_pushstring(L, "CoreMIDI");
        break;
      case RtMidi::WINDOWS_MM:
        lua_pushstring(L, "Windows MM");
        break;
      case RtMidi::WEB_MIDI_API:
        lua_pushstring(L, "Web MIDI API");
        break;
#if RTMIDI_VERSION_MAJOR > 5
      case RtMidi::WINDOWS_UWP:
        lua_pushstring(L, "Windows UWP");
        break;
      case RtMidi::ANDROID_AMIDI:
        lua_pushstring(L, "Android AMidi");
        break;
#endif
      case RtMidi::RTMIDI_DUMMY:
      case RtMidi::UNSPECIFIED:
      case RtMidi::NUM_APIS:
        // These should not be selectable
        break;
    }
    lua_settable(L, -3);
  }

  return 1;
}

int l_midi_player_new(lua_State* L) {
  const char* apiChoice = luaL_optlstring(L, 2, "", nullptr);
  const char* portChoice = luaL_optlstring(L, 3, "", nullptr);
  bool sysexMasterVolume = lua_toboolean(L, 4);

  try {
    RtMidi::Api midi_api = midi_api_from_string(apiChoice);
    luaT_stdnew<midi_player>(L, luaT_environindex, true, midi_api, portChoice,
                             sysexMasterVolume);
  } catch (const std::invalid_argument& e) {
    return luaL_error(L, "Invalid MIDI API choice: %s", e.what());
  }

  return 1;
}

int l_midi_port_list(lua_State* L) {
  midi_player* midiPlayer = luaT_testuserdata<midi_player>(L);
  const std::vector<std::string> portList = midiPlayer->port_list();
  lua_createtable(L, static_cast<int>(portList.size()), 0);
  for (size_t i = 0; i < portList.size(); ++i) {
    lua_pushinteger(L, static_cast<lua_Integer>(i) + 1);
    lua_pushstring(L, portList[i].c_str());
    lua_settable(L, -3);
  }

  return 1;
}

int l_midi_player_play_xmi(lua_State* L) {
  midi_player* midiPlayer = luaT_testuserdata<midi_player>(L);

  size_t xmiDataLength;
  const uint8_t* xmiData = luaT_checkfile(L, 2, &xmiDataLength);

  midiPlayer->play_xmi(xmiData, xmiDataLength);

  return 0;
}

int l_midi_player_set_volume(lua_State* L) {
  midi_player* midiPlayer = luaT_testuserdata<midi_player>(L);
  double volume = static_cast<double>(luaL_checknumber(L, 2));
  midiPlayer->set_volume(volume);

  return 0;
}

int l_midi_player_stop(lua_State* L) {
  midi_player* midiPlayer = luaT_testuserdata<midi_player>(L);
  midiPlayer->stop();

  return 0;
}

int l_midi_player_pause(lua_State* L) {
  midi_player* midiPlayer = luaT_testuserdata<midi_player>(L);
  midiPlayer->pause();
  return 0;
}

int l_midi_player_resume(lua_State* L) {
  midi_player* midiPlayer = luaT_testuserdata<midi_player>(L);
  midiPlayer->resume();
  return 0;
}

#else  // WITH_MIDI_DEVICE
int l_midi_player_api_list(lua_State* L) {
  lua_createtable(L, 1, 0);
  lua_pushinteger(L, 1);
  lua_pushstring(L, "Default");
  lua_settable(L, -3);

  return 1;
}

int l_midi_player_new(lua_State* L) {
  return luaL_error(L, "MIDI support not compiled in");
}

int l_midi_port_list(lua_State* L) {
  return luaL_error(L, "MIDI support not compiled in");
}

int l_midi_player_play_xmi(lua_State* L) {
  return luaL_error(L, "MIDI support not compiled in");
}

int l_midi_player_set_volume(lua_State* L) {
  return luaL_error(L, "MIDI support not compiled in");
}

int l_midi_player_stop(lua_State* L) {
  return luaL_error(L, "MIDI support not compiled in");
}

int l_midi_player_pause(lua_State* L) {
  return luaL_error(L, "MIDI support not compiled in");
}

int l_midi_player_resume(lua_State* L) {
  return luaL_error(L, "MIDI support not compiled in");
}

#endif  // WITH_MIDI_DEVICE

}  // namespace

void lua_register_midi(const lua_register_state* pState) {
  lua_class_binding<midi_player> lcb(pState, "midiPlayer", l_midi_player_new,
                                     lua_metatable::midi_player);
  lcb.add_metamethod(l_midi_player_api_list, "apiList");
  lcb.add_function(l_midi_port_list, "portList");
  lcb.add_function(l_midi_player_play_xmi, "playXmi");
  lcb.add_function(l_midi_player_set_volume, "setVolume");
  lcb.add_function(l_midi_player_stop, "stop");
  lcb.add_function(l_midi_player_pause, "pause");
  lcb.add_function(l_midi_player_resume, "resume");
}
