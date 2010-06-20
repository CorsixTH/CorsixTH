---- CorsixTH bootstrap code -------------------------------------------------
-- This is not a configuration file and should not be edited. See config.txt
-- for CorsixTH configuration options.

-- Basic sanity check that the file hasn't been invoked by the standard Lua
-- interpreter (as then various packages would be missing and SDLmain would not
-- have run).
if (package and package.preload and package.preload.TH) == nil then
  error "This file must be invoked by the CorsixTH executable"
end

-- Check Lua version
if _VERSION ~= "Lua 5.1" then
  if _VERSION == "Lua 5.2" then
    print "Notice: Lua 5.2 is not officially supported at the moment"
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
    error "Please recompile CorsixTH and link against Lua version 5.1"
  end
end

-- If being debugged in Decoda, turn off JIT compilation (as it cannot debug
-- machine code). Note that this file cannot be debugged, but all other files
-- can be. See http://www.unknownworlds.com/decoda/ for Decoda info.
if decoda_output then
  _DECODA = true
  if jit then
    jit.off()
    decoda_output "JIT compilation disabled"
  end
else
  _DECODA = false
end

_MAP_EDITOR = _MAP_EDITOR or false

-- Redefine dofile such that it adds the direction name and file extension, and
-- won't redo a file which it has previously done.
local pathsep = package.config:sub(1, 1)
local base_dir = debug.getinfo(1, "S").source:sub(2, -13)
local code_dir = base_dir .. "Lua" .. pathsep
for _, arg in ipairs{...} do
  local dir = arg:match"^%-%-lua%-dir=(.*)$"
  if dir then
    code_dir = dir .. pathsep
  end
end
local done_files = {}
local persist = require "persist"
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
function dofile(name)
  if pathsep ~= "/" then
    name = name:gsub("/", pathsep)
  end
  if done_files[name] then
    local results = done_files[name]
    return unpack(results, 1, results.n)
  end
  done_files[name] = true
  return save_results(done_files, name, persist.dofile(code_dir .. name .. ".lua"))
end

-- Load standard library extensions
dofile "utility"

-- Enable strict mode
dofile "strict"
require = destrict(require)

-- Load the class system (required for App)
dofile "class"

-- Load the main App class
dofile "app"

-- Create an instance of the App class and transfer control to it
strict_declare_global "TheApp"
TheApp = App()
TheApp:setCommandLine(
  "--bitmap-dir="..base_dir.."Bitmap",
  "--config-file="..dofile"config_finder",
  -- If a command line option is given twice, the later one is used, hence
  -- if the user gave one of the above, that will be used instead.
  ...
)
assert(TheApp:init())
return TheApp:run()

--[[!file
! Application bootstrap code
]]
