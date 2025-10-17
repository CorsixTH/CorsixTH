---- CorsixTH bootstrap code -------------------------------------------------
-- This is not a configuration file and should not be edited. See config.txt
-- for CorsixTH configuration options.

-- Basic sanity check that the file hasn't been invoked by the standard Lua
-- interpreter (as then various packages would be missing and SDLmain would not
-- have run).
if (package and package.preload and package.preload.TH) == nil then
  error "This file must be invoked by the CorsixTH executable"
end

-- Set a large enough cstacklimit to load complex saves in stack based
-- versions of lua, such as 5.4.[01]
if debug.setcstacklimit then
  debug.setcstacklimit(30000)
end

-- Redefine dofile such that it adds the direction name and file extension, and
-- won't redo a file which it has previously done.
local pathsep = package.config:sub(1, 1)
local base_dir = debug.getinfo(1, "S").source:sub(2, -13)
local code_dir = base_dir .. "Lua" .. pathsep
package.cpath = base_dir .. '?.so;' .. package.cpath
for _, arg in ipairs{...} do
  local dir = arg:match"^%-%-lua%-dir=(.*)$"
  if dir then
    code_dir = dir .. pathsep
  end
end

package.path = code_dir .. "?.lua;" .. code_dir .. "?/init.lua;" .. package.path

local done_files = {}
local persist = require("persist")
local save_results
if table.pack then
  -- Lua 5.2
  save_results = function(t, k, ...)
    t[k] = table.pack(...)
    return ...
  end
else
  -- Lua 5.1
  save_results = function(t, k, ...)
    t[k] = {n = select('#', ...), ...}
    return ...
  end
end

_G['corsixth'] = {}

--! Loads and runs a lua file.
-- Similar to the built in require function with three important differences:
--  * This function searches for --[[persistance: comments and maps the
--    following function into the persistence table.
--  * This function only searches in the Lua code directory
--  * This function is only able to load lua source files (not C modules or
--    compiled lua.
--!param name (string)
--   The name of the lua source file to run. Use dots to separate directories,
--   and do not include the .lua file extension.
--!return The return value of whatever source file is opened.
corsixth.require = function(name)
  name = name:gsub("%.", pathsep)
  if done_files[name] then
    local results = done_files[name]
    return unpack(results, 1, results.n)
  end
  done_files[name] = true
  return save_results(done_files, name, persist.dofile(code_dir .. name .. ".lua"))
end

-- Load standard library extensions
corsixth.require("utility")

-- Check Lua version
local support = list_to_set({"Lua 5.1", "Lua 5.2", "Lua 5.3", "Lua 5.4"})
if not support[_VERSION] then
  error "Please recompile CorsixTH and link against Lua version 5.1, 5.2, 5.3 or 5.4"
end
if _VERSION ~= "Lua 5.1" then
  -- Compatibility: Keep the global unpack function
  unpack = table.unpack -- luacheck: ignore 121
end

-- Enable strict mode
corsixth.require("strict")
require = destrict(require) -- luacheck: ignore 121
dofile = destrict(dofile) -- luacheck: ignore 121

-- Load the class system (required for App)
corsixth.require("class")

-- Load the main App class
corsixth.require("app")

-- Create an instance of the App class and transfer control to it
strict_declare_global "TheApp"
TheApp = App()
TheApp:setCommandLine(
  "--bitmap-dir=" ..base_dir.. "Bitmap",
  "--config-file=" .. select(1, corsixth.require("config_finder")),
  "--hotkeys-file=" .. select(4, corsixth.require("config_finder")),
  -- If a command line option is given twice, the later one is used, hence
  -- if the user gave one of the above, that will be used instead.
  ...
)
assert(TheApp:init())
return TheApp:run()

--[[!file
! Application bootstrap code
]]
