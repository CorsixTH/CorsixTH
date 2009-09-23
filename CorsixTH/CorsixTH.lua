----  CorsixTH bootstrap code -------------------------------------------------
-- This is not a configuration file and should not be edited. See config.txt
-- for CorsixTH configuration options.

-- Basic sanity check that the file hasn't been invoked by the standard Lua
-- interpreter (as then various packages would be missing and SDLmain would not
-- have run).
if (package and package.preload and package.preload.TH) == nil then
  error "This file must be invoked by the CorsixTH executable"
end
if _VERSION ~= "Lua 5.1" then
  error "Please recompile CorsixTH and link against Lua version 5.1"
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
local code_dir = "Lua" .. pathsep
for _, arg in ipairs{...} do
  local dir = arg:match"^%-%-lua%-dir=(.*)$"
  if dir then
    code_dir = dir .. pathsep
  end
end
local done_files = {}
local do_file = dofile
function dofile(name)
  if done_files[name] then
    return
  end
  done_files[name] = true
  return do_file(code_dir .. name .. ".lua")
end

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
TheApp:setCommandLine(...)
assert(TheApp:init())
return TheApp:run()
