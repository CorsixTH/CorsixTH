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

#include <stdexcept>
#include <type_traits>
#include <variant>
#include <vector>

#include "fluid_player.h"
#include "lua.hpp"
#include "midi_player.h"
#include "th_lua.h"
#include "th_lua_internal.h"

// Delegate object around midi_player or fluid_player with a close method
// suitable for adapting C++ RAII to lua garbage collection.
class th_lua_midi_player {
 public:
  explicit th_lua_midi_player(const std::string& soundfont)
      : player(std::in_place_type<fluid_player>, soundfont) {}

#ifdef WITH_MIDI_DEVICE
  th_lua_midi_player(std::string_view api, std::string_view port,
                     bool use_sysex)
      : player(std::in_place_type<midi_player>, api, port, use_sysex) {}
#endif
  th_lua_midi_player(const th_lua_midi_player&) = delete;
  th_lua_midi_player& operator=(const th_lua_midi_player&) = delete;

  std::vector<std::string> port_list() const {
    return std::visit(
        [](const auto& player) -> std::vector<std::string> {
          using player_type = std::decay_t<decltype(player)>;
          if constexpr (std::is_same_v<player_type, std::monostate>) {
            throw std::runtime_error("th_lua_midi_player instance is closed");
          } else if constexpr (std::is_same_v<player_type, fluid_player>) {
            return {};
          } else {
            return player.port_list();
          }
        },
        player);
  }

  void play_xmi(const unsigned char* xmiData, const size_t len) {
    std::visit(
        [&](auto& player) {
          using player_type = std::decay_t<decltype(player)>;
          if constexpr (std::is_same_v<player_type, std::monostate>) {
            throw std::runtime_error("th_lua_midi_player instance is closed");
          } else {
            player.play_xmi(xmiData, len);
          }
        },
        player);
  }

  void set_volume(const double volume) {
    std::visit(
        [&](auto& player) {
          using player_type = std::decay_t<decltype(player)>;
          if constexpr (std::is_same_v<player_type, std::monostate>) {
            throw std::runtime_error("th_lua_midi_player instance is closed");
          } else if constexpr (std::is_same_v<player_type, fluid_player>) {
            player.set_volume(static_cast<float>(volume));
          } else {
            player.set_volume(volume);
          }
        },
        player);
  }

  void stop() {
    std::visit(
        [](auto& player) {
          using player_type = std::decay_t<decltype(player)>;
          if constexpr (std::is_same_v<player_type, std::monostate>) {
            throw std::runtime_error("th_lua_midi_player instance is closed");
          } else {
            player.stop();
          }
        },
        player);
  }

  void pause() {
    std::visit(
        [](auto& player) {
          using player_type = std::decay_t<decltype(player)>;
          if constexpr (std::is_same_v<player_type, std::monostate>) {
            throw std::runtime_error("th_lua_midi_player instance is closed");
          } else {
            player.pause();
          }
        },
        player);
  }

  void resume() {
    std::visit(
        [](auto& player) {
          using player_type = std::decay_t<decltype(player)>;
          if constexpr (std::is_same_v<player_type, std::monostate>) {
            throw std::runtime_error("th_lua_midi_player instance is closed");
          } else {
            player.resume();
          }
        },
        player);
  }

  void close() { player.emplace<std::monostate>(); }

 private:
#ifdef WITH_MIDI_DEVICE
  std::variant<std::monostate, fluid_player, midi_player> player;
#else
  std::variant<std::monostate, fluid_player> player;
#endif
};

namespace {

int l_midi_player_api_list(lua_State* L) {
#ifdef WITH_MIDI_DEVICE
  std::vector<std::string> apis = midi_player::api_list();
#else
  std::vector<std::string> apis{};
#endif

  lua_createtable(L, static_cast<int>(apis.size()), 0);
  for (size_t i = 0; i < apis.size(); ++i) {
    lua_pushinteger(L, static_cast<lua_Integer>(i) + 1);
    lua_pushstring(L, apis[i].c_str());
    lua_settable(L, -3);
  }

  return 1;
}

int l_midi_player_new(lua_State* L) {
  if (lua_gettop(L) == 2) {
    const char* soundfont = luaL_checkstring(L, 2);
    try {
      luaT_stdnew<th_lua_midi_player>(L, luaT_environindex, true, soundfont);
      return 1;
    } catch (const std::exception& e) {
      return luaL_error(L, e.what());
    }
  }

  const char* apiChoice = luaL_optlstring(L, 2, "", nullptr);
  const char* portChoice = luaL_optlstring(L, 3, "", nullptr);
  bool sysexMasterVolume = lua_toboolean(L, 4);
  const char* soundfont = luaL_optlstring(L, 5, "", nullptr);

  try {
#ifdef WITH_MIDI_DEVICE
    if (apiChoice[0] != '\0') {
      luaT_stdnew<th_lua_midi_player>(L, luaT_environindex, true, apiChoice,
                                      portChoice, sysexMasterVolume);
      return 1;
    }
#endif
    luaT_stdnew<th_lua_midi_player>(L, luaT_environindex, true, soundfont);
    return 1;
  } catch (const std::invalid_argument& e) {
    return luaL_error(L, "Invalid MIDI API choice: %s", e.what());
  } catch (const std::exception& e) {
    return luaL_error(L, e.what());
  }
}

int l_midi_port_list(lua_State* L) {
  th_lua_midi_player* midiPlayer = luaT_testuserdata<th_lua_midi_player>(L);
  try {
    const std::vector<std::string> portList = midiPlayer->port_list();
    lua_createtable(L, static_cast<int>(portList.size()), 0);
    for (size_t i = 0; i < portList.size(); ++i) {
      lua_pushinteger(L, static_cast<lua_Integer>(i) + 1);
      lua_pushstring(L, portList[i].c_str());
      lua_settable(L, -3);
    }
    return 1;
  } catch (const std::exception& e) {
    return luaL_error(L, e.what());
  }
}

int l_midi_player_play_xmi(lua_State* L) {
  th_lua_midi_player* midiPlayer = luaT_testuserdata<th_lua_midi_player>(L);
  try {
    size_t xmiDataLength;
    const uint8_t* xmiData = luaT_checkfile(L, 2, &xmiDataLength);

    midiPlayer->play_xmi(xmiData, xmiDataLength);
    return 0;
  } catch (const std::exception& e) {
    return luaL_error(L, e.what());
  }
}

int l_midi_player_set_volume(lua_State* L) {
  th_lua_midi_player* midiPlayer = luaT_testuserdata<th_lua_midi_player>(L);

  try {
    double volume = static_cast<double>(luaL_checknumber(L, 2));
    midiPlayer->set_volume(volume);
    return 0;
  } catch (const std::exception& e) {
    return luaL_error(L, e.what());
  }
}

int l_midi_player_stop(lua_State* L) {
  th_lua_midi_player* midiPlayer = luaT_testuserdata<th_lua_midi_player>(L);
  try {
    midiPlayer->stop();
    return 0;
  } catch (const std::exception& e) {
    return luaL_error(L, e.what());
  }
}

int l_midi_player_pause(lua_State* L) {
  th_lua_midi_player* midiPlayer = luaT_testuserdata<th_lua_midi_player>(L);
  try {
    midiPlayer->pause();
    return 0;
  } catch (const std::exception& e) {
    return luaL_error(L, e.what());
  }
}

int l_midi_player_resume(lua_State* L) {
  th_lua_midi_player* midiPlayer = luaT_testuserdata<th_lua_midi_player>(L);
  try {
    midiPlayer->resume();
    return 0;
  } catch (const std::exception& e) {
    return luaL_error(L, e.what());
  }
}

int l_midi_player_close(lua_State* L) {
  th_lua_midi_player* midiPlayer = luaT_testuserdata<th_lua_midi_player>(L);
  try {
    midiPlayer->close();
  } catch (const std::exception& e) {
    return luaL_error(L, e.what());
  }
  return 0;
}

}  // namespace

void lua_register_midi(const lua_register_state* pState) {
  lua_class_binding<th_lua_midi_player> lcb(
      pState, "midiPlayer", l_midi_player_new, lua_metatable::midi_player);
  // static
  lcb.add_function(l_midi_player_api_list, "getAvailableApis");

  // member
  lcb.add_function(l_midi_port_list, "portList");
  lcb.add_function(l_midi_player_play_xmi, "playXmi");
  lcb.add_function(l_midi_player_set_volume, "setVolume");
  lcb.add_function(l_midi_player_stop, "stop");
  lcb.add_function(l_midi_player_pause, "pause");
  lcb.add_function(l_midi_player_resume, "resume");
  lcb.add_function(l_midi_player_close, "close");
}
