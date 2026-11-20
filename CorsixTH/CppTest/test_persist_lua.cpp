#include <catch2/catch_test_macros.hpp>
#include <string>

#include "lua.hpp"
#include "persist_lua.h"
#include "th_lua.h"

namespace {

// Run a chunk of Lua code. Returns the error message, or an empty string if
// the code ran without an error.
std::string run_lua(lua_State* L, const char* code) {
  if (luaL_dostring(L, code) == 0) {
    return "";
  }
  const char* message = lua_tostring(L, -1);
  std::string error = message != nullptr ? message : "unknown error";
  lua_pop(L, 1);
  return error;
}

}  // namespace

TEST_CASE("numbers load as they were saved", "[persist]") {
  lua_state_unique_ptr L(luaL_newstate());
  luaL_openlibs(L.get());
  preload_lua_package(L.get(), "persist", luaopen_persist);

  // On Lua 5.3 and later the subtype must survive too: an integer must load
  // as an integer and a float as a float, whether it is small or large.
  const char* code = R"lua(
    local persist = require("persist")
    local numbers = {0, 7, 16383, 16384, 50000, -5, 0.5, 3.0, -2.0, 2^40, 1e300}
    if math.tointeger then
      numbers[#numbers + 1] = math.tointeger(2^40)
      numbers[#numbers + 1] = math.maxinteger
      numbers[#numbers + 1] = math.mininteger
    end
    local data = assert(persist.dump(numbers, {}))
    local loaded = assert(persist.load(data, {}))
    for i, saved in ipairs(numbers) do
      local got = loaded[i]
      local same = got == saved
      if math.type and math.type(got) ~= math.type(saved) then
        same = false
      end
      if not same then
        error("saved " .. tostring(saved) .. ", loaded " .. tostring(got))
      end
    end
  )lua";
  REQUIRE(run_lua(L.get(), code) == "");
}
