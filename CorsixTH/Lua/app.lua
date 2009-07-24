--[[ Copyright (c) 2009 Peter "Corsix" Cawley

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
SOFTWARE. --]]

local pathsep = package.config:sub(1, 1)
local rnc = require "rnc"
local lfs = require "lfs"
local TH = require "TH"
local SDL = require "sdl"
local assert, io, type
    = assert, io, type

-- Change to true to show FPS and Lua memory usage in the window title
-- Note that this also turns off the FPS limiter, causing the engine to render
-- frames even when it doesn't need to.
local TRACK_FPS = false

class "App"

function App:App()
  self.command_line = {}
  self.config = {}
  self.running = false
  self.gfx = {}
  self.last_dispatch_type = ""
  self.eventHandlers = {
    frame = self.drawFrame,
    timer = self.onTick,
    keydown = self.onKeyDown,
    keyup = self.onKeyUp,
    buttonup = self.onMouseUp,
    buttondown = self.onMouseDown,
    motion = self.onMouseMove,
  }
  self.strings = {}
end

function App:setCommandLine(...)
  self.command_line = {...}
end

function App:init()
  -- App initialisation 1st goal: Get the loading screen up
  
  -- Prereq 1: Config file (for screen width / height / TH folder)
  setfenv(assert(loadfile"config.txt"), self.config)()
  self:fixConfig()
  self:checkInstallFolder()
  
  -- Create the window
  if not SDL.init("video", "timer") then
    return false, "Cannot initialise SDL"
  end
  SDL.wm.setCaption "CorsixTH"
  self.video = assert(SDL.video.setMode(self.config.width, self.config.height, "hardware", "doublebuf", self.config.fullscreen and "fullscreen" or ""))
  SDL.wm.setIconWin32()
  
  -- Prereq 2: Load and initialise the graphics subsystem
  dofile "graphics"
  self.gfx = Graphics(self)
  
  -- Put up the loading screen
  self.video:startFrame()
  self.gfx:loadRaw"Load01V":draw(self.video, (self.config.width - 640) / 2, (self.config.height - 480) / 2)
  self.video:endFrame()
  
  -- App initialisation 2nd goal: Load remaining systems and data in an appropriate order
  
  -- Load strings before UI and before additional Lua
  self.strings = assert(TH.LoadStrings(self:readDataFile("Data", self.config.language .. ".dat")), "Cannot load strings")
  _S = function(sec, str, ...)
    str = self.strings[sec][str]
    if ... then
      str = str:format(...)
    end
    return str
  end
  
  -- Load map before world
  dofile "map"
  self.map = Map()
  self.map:load(self:readDataFile("Levels", "Level.L1"))
  self.map:setBlocks(self.gfx:loadSpriteTable("Data", "VBlk-0"))
  
  -- Load additional Lua before world
  self.walls = self:loadLuaFolder"walls"
  dofile "object"
  self.objects = self:loadLuaFolder"objects"
  self.rooms = self:loadLuaFolder"rooms"
  
  -- Load world before UI
  dofile "world"
  self.anims = self.gfx:loadAnimations("Data", "V")
  self.world = World(self.map, self.anims, self.walls, self.objects)
  
  -- Load UI
  dofile "ui"
  self.ui = UI(self)
 
  return true
end

local function invert_lang_table(t)
  local r = {}
  for language_file, names in pairs(t) do
    for _, name in ipairs(names) do
      r[name] = language_file
    end
  end
  return r
end

local languages = invert_lang_table {
  -- Language name (in english) along with ISO 639 codes for it
  ["Lang-0"] = {"english", "en", "eng"},
  ["Lang-1"] = {"french" , "fr", "fre", "fra"},
  ["Lang-2"] = {"german" , "de", "ger", "deu"},
  ["Lang-3"] = {"italian", "it", "ita"},
  ["Lang-4"] = {"spanish", "es", "spa"},
  ["Lang-5"] = {"swedish", "sv", "swe"},
}

function App:fixConfig()
  for key, value in pairs(self.config) do
    -- Trim whitespace from beginning and end string values - it shouldn't be
    -- there (at least in any current configuration options).
    if type(value) == "string" then
      if value:match"^[%s]" or value:match"[%s]$" then
        self.config[key] = value:match"^[%s]*(.-)[%s]*$"
      end
    end
    
    -- For language, replace language name with filename
    if key == "language" and type(value) == "string" then
      self.config[key] = languages[value:lower()] or value
    end
  end
end

function App:run()
  local co = coroutine.create(function(self)
    local yield = coroutine.yield
    local dispatch = self.dispatch
    local repaint = true
    while self.running do
      repaint = dispatch(self, yield(repaint))
    end
  end)
  
  if TRACK_FPS then
    SDL.trackFPS(true)
    SDL.limitFPS(false)
  end
  
  self.running = true
  coroutine.resume(co, self)
  local e = SDL.mainloop(co)
  self.running = false
  if e ~= nil then
    print("An error has occured while running the " .. self.last_dispatch_type .. " handler.")
    print("A stack trace is included below, and the handler has been disconnected.")
    print(debug.traceback(co, e, 0))
    print""
    self.eventHandlers[self.last_dispatch_type] = nil
    return self:run()
  end
end

local done_no_handler_warning = {}

function App:dispatch(evt_type, ...)
  local handler = self.eventHandlers[evt_type]
  if handler then
    self.last_dispatch_type = evt_type
    return handler(self, ...)
  else
    if not done_no_handler_warning[evt_type] then
      print("Warning: No event handler for " .. evt_type)
      done_no_handler_warning[evt_type] = true
    end
    return false
  end
end

function App:onTick(...)
  self.world:onTick(...)
  self.ui:onTick(...)
  return true
end

local sx = 0
local sy = 0

function App:drawFrame()
  self.video:startFrame()
  self.ui:draw(self.video)
  self.video:endFrame()
  
  if TRACK_FPS then
    SDL.wm.setCaption(("%i FPS, %.1f Kb Lua memory"):format(SDL.getFPS(), collectgarbage"count"))
  end
end

function App:onKeyDown(...)
  return self.ui:onKeyDown(...)
end

function App:onKeyUp(...)
  return self.ui:onKeyUp(...)
end

function App:onMouseUp(...)
  return self.ui:onMouseUp(...)
end

function App:onMouseDown(...)
  return self.ui:onMouseDown(...)
end

function App:onMouseMove(...)
  return self.ui:onMouseMove(...)
end

function App:checkInstallFolder()
  -- Check that it is actually a folder
  local install_folder = self.config.theme_hospital_install
  if install_folder:sub(-1) == pathsep then
    -- Trim off the trailing separator (lfs doesn't like querying the mode of a
    -- directory with a trailing slash on win32)
    install_folder = install_folder:sub(1, -2)
  end
  
  if lfs.attributes(install_folder, "mode") ~= "directory" then
    error(("Theme Hospital folder specified in config file ('%s') is not a directory."):format(install_folder))
  end
  
  -- Put a path separator back on the folder
  install_folder = install_folder .. pathsep
  self.config.theme_hospital_install = install_folder
  
  -- *nix is case sensitive, so discover the case of various required directories.
  -- At the same time, check that the expected directories actually exist.
  local dir_map = {
    ANIMS = true,
    DATA = true,
    DATAM = true,
    INTRO = true,
    LEVELS = true,
    QDATA = true,
    QDATAM = true,
    SOUND = true,
  }
  for item in lfs.dir(install_folder) do
    if dir_map[item:upper()] then
      dir_map[item:upper()] = item
    end
  end
  for dir, name in pairs(dir_map) do
    if name == true then
      error(("Directory '%s' not present in specified Theme Hospital  folder ('%s')"):format(dir, install_folder))
    end
  end
  self.data_dir_map = dir_map
  
  -- Check for demo version
  local demo = io.open(install_folder .. dir_map.DATAM .. pathsep .. "DEMO.DAT")
  if demo then
    demo:close()
    print "Notice: Using data files from demo version of Theme Hospital."
    print "Consider purchasing a full copy of the game to support EA."
  end
end

function App:readDataFile(dir, filename)
  if filename == nil then
    dir, filename = "DATA", dir
  end
  dir = dir:upper()
  dir = self.data_dir_map[dir] or dir
  filename = self.config.theme_hospital_install .. dir .. pathsep .. filename:upper()
  local file = assert(io.open(filename, "rb"))
  local data = file:read"*a"
  file:close()
  if data:sub(1, 3) == "RNC" then
    data = assert(rnc.decompress(data))
  end
  return data
end

function App:loadLuaFolder(dir, no_results)
  local ourpath = debug.getinfo(1, "S").source:sub(2, -8)
  local path = ourpath .. dir .. pathsep
  local results = no_results and "" or {}
  for file in lfs.dir(path) do
    if file:match"[.]lua$" then
      local chunk, e = loadfile(path .. file)
      if e then
        print("Error loading " .. dir .. "/" .. file .. ":\n" .. tostring(e))
      else
        local status, result = pcall(chunk, self)
        if not status then
          print("Runtime error loading " .. dir .. "/" .. file .. ":\n" .. tostring(e))
        else
          if result == nil then
            if not no_results then
              print("Warning: " .. dir .. "/" .. file .. " returned no value")
            end
          else
            if type(result) == "table" and result.id then
              results[result.id] = result
            end
            results[#results + 1] = result
          end
        end
      end
    end
  end
  if no_results then
    return
  else
    return results
  end
end
