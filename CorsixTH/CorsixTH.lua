---- CorsixTH bootstrap code -------------------------------------------------
-- This is not a configuration file and should not be edited. See config.txt
-- for CorsixTH configuration options.

-- Basic sanity check that the file hasn't been invoked by the standard Lua
-- interpreter (as then various packages would be missing and SDLmain would not
-- have run).
if (package and package.preload and package.preload.TH) == nil then
  error "This file must be invoked by the CorsixTH executable"
end

-- Parse script parameters:
local run_debugger = false
for _, arg in ipairs({...}) do
  if arg:match("^%-%-connect%-lua%-dbgp") then
    run_debugger = true
  end
end

-- Finds a code directory so that it can add it to paths to look for modules
local pathsep = package.config:sub(1, 1)
local base_dir = debug.getinfo(1, "S").source:sub(2, -13)
local code_dir = base_dir .. "Lua" .. pathsep
for _, arg in ipairs{...} do
  local dir = arg:match"^%-%-lua%-dir=(.*)$"
  if dir then
    code_dir = dir .. pathsep
  end
end

package.path = code_dir .. "?" .. pathsep .. "init.lua" .. ";" .. package.path
package.path = code_dir .. "?.lua" .. ";" .. package.path

-- Load standard library extensions
require("utility")

-- If requested run a Lua DBGp Debugger Client
if run_debugger then
  require("run_debugger")
end

-- Check Lua version
if _VERSION ~= "Lua 5.1" then
  if _VERSION == "Lua 5.2" or _VERSION == "Lua 5.3" then
    -- Compatibility: Keep the global unpack function
    unpack = table.unpack
    -- Compatibility: Provide a replacement for deprecated ipairs()
    -- NB: It might be wiser to migrate away from ipairs entirely, but the
    -- following works as an immediate band-aid
    local rawget, error, type = rawget, error, type
    if not pcall(ipairs, {}) then
      local function next_int(t, i)
        i = i + 1
        local v = rawget(t, i)
        if v ~= nil then
          return i, v
        end
      end
      function ipairs(t)
        if type(t) ~= "table" then
          error("table expected, got " .. type(t))
        end
        return next_int, t, 0
      end
    end
  else
    error "Please recompile CorsixTH and link against Lua version 5.1, 5.2 or 5.3"
  end
end
--
-- A DBGp debugger can debug this file if you start a CorsixTH DBGp client & connect
-- it to a running server, using this CorsixTH startup arg: -debugger

-- Enable strict mode
require("strict")

-- Load the class system (required for App)
require("class")

-- Load the main App class
require("app")

-- Create an instance of the App class and transfer control to it
strict_declare_global "TheApp"
TheApp = App()
TheApp:setCommandLine(
  "--bitmap-dir=" .. base_dir .. "Bitmap",
  "--config-file=" .. require("config_finder")["filename"],
  -- If a command line option is given twice, the later one is used, hence
  -- if the user gave one of the above, that will be used instead.
  ...
)
assert(TheApp:init())
return TheApp:run()

--[[!file
! Application bootstrap code
]]
