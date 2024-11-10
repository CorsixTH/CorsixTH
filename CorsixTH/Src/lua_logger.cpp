#include "lua_logger.h"

#include <spdlog/common.h>
#include <spdlog/spdlog.h>

#include "th_lua.h"

namespace {
int log(lua_State* L, spdlog::level::level_enum level) {
  if (lua_gettop(L) > 1) {
    // It would be better if we did support fmt strings, I'm just not sure how.
    spdlog::warn(
        "logger called from lua with more than one arg, but fmt strings are "
        "not supported.");
  }
  const char* str = luaT_checkstring(L, 1, nullptr);

  spdlog::log(level, str);
  return 0;
}

int l_trace(lua_State* L) { return log(L, spdlog::level::trace); }

int l_debug(lua_State* L) { return log(L, spdlog::level::debug); }

int l_info(lua_State* L) { return log(L, spdlog::level::info); }

int l_warn(lua_State* L) { return log(L, spdlog::level::warn); }

int l_error(lua_State* L) { return log(L, spdlog::level::err); }

}  // namespace

constexpr std::array<luaL_Reg, 6> loggerlib{{{"trace", l_trace},
                                             {"debug", l_debug},
                                             {"info", l_info},
                                             {"warn", l_warn},
                                             {"error", l_error},
                                             {nullptr, nullptr}}};

int luaopen_logger(lua_State* L) {
  luaT_register(L, "logger", loggerlib);
  return 1;
}