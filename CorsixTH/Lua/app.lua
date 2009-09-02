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
local assert, io, type, dofile, loadfile, pcall, tonumber, print
    = assert, io, type, dofile, loadfile, pcall, tonumber, print

-- Change to true to show FPS and Lua memory usage in the window title.
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
    music_over = self.onMusicOver,
  }
  self.strings = {}
end

function App:setCommandLine(...)
  self.command_line = {...}
  for i, arg in ipairs(self.command_line) do
    local setting, value = arg:match"^%-%-([^=]*)=(.*)$" --setting=value
	  if value then
	    self.command_line[setting] = value
	  end
  end
end

function App:init()
  -- App initialisation 1st goal: Get the loading screen up
  
  -- Prereq 1: Config file (for screen width / height / TH folder)
  setfenv(assert(loadfile(self.command_line["config-file"] or "config.txt")), self.config)()
  self:fixConfig()
  self:checkInstallFolder()
  self:checkLanguageFile()
  
  -- Create the window
  if not SDL.init("audio", "video", "timer") then
    return false, "Cannot initialise SDL"
  end
  SDL.wm.setCaption "CorsixTH"
  local modes = {"hardware", "doublebuf"}
  if self.config.fullscreen then
    modes[#modes + 1] = "fullscreen"
  end
  if TRACK_FPS then
    modes[#modes + 1] = "present immediate"
  end
  self.video = assert(SDL.video.setMode(self.config.width, self.config.height, unpack(modes)))
  SDL.wm.setIconWin32()
  
  -- Prereq 2: Load and initialise the graphics subsystem
  dofile "graphics"
  self.gfx = Graphics(self)
  
  -- Put up the loading screen
  self.video:startFrame()
  self.gfx:loadRaw("Load01V", 640, 480):draw(self.video,
    (self.config.width - 640) / 2, (self.config.height - 480) / 2)
  self.video:endFrame()
  
  -- App initialisation 2nd goal: Load remaining systems and data in an appropriate order
  
  math.randomseed(os.time() + SDL.getTicks())
  
  -- Load strings before UI and before additional Lua
  self.strings = assert(TH.LoadStrings(self:readDataFile(self.config.language .. ".dat")), "Cannot load strings")
  strict_declare_global "_S"
  _S = function(sec, str, ...)
    str = self.strings[sec][str]
    if ... then
      str = str:format(...)
    end
    return str
  end
  
  -- Load audio
  dofile "audio"
  self.audio = Audio(self)
  self.audio:init()
  
  -- Load map before world
  dofile "map"
  
  -- Load additional Lua before world
  self.walls = self:loadLuaFolder"walls"
  dofile "object"
  self.objects = self:loadLuaFolder"objects"
  self.rooms = self:loadLuaFolder"rooms"
  self.humanoid_actions = self:loadLuaFolder"humanoid_actions"
  
  -- Load world before UI
  dofile "world"
  self.anims = self.gfx:loadAnimations("Data", "V")
  
  -- Load UI
  dofile "ui"
  
  -- Load level (which creates the map, world, and UI)
  self:loadLevel "Level.L1"
 
  return true
end

function App:loadLevel(filename)
  -- Check that we can load the data before unloading current map
  local data = self:readDataFile("Levels", filename)
  
  -- Unload ui, world and map
  self.ui = nil
  self.world = nil
  self.map = nil
  
  -- Load map
  self.map = Map()
  self.map:load(data)
  self.map:setBlocks(self.gfx:loadSpriteTable("Data", "VBlk-0"))
  self.map:setDebugFont(self.gfx:loadFont("QData", "Font01V"))
  
  -- Load world
  self.world = World(self)
  
  -- Load UI
  self.ui = UI(self)
end

local function invert_lang_table(t)
  local name_to_filename = {}
  local number_to_name = {}
  for language_file, names in pairs(t) do
    for _, name in ipairs(names) do
      name_to_filename[name] = language_file
    end
    number_to_name[tonumber(language_file:match"[0-9]+")] = names[1]
  end
  return name_to_filename, number_to_name
end

local languages, languages_by_num = invert_lang_table {
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
  -- The application "main loop" is an SDL event loop written in C, which calls
  -- a coroutine whenver an event occurs. Initially it may seem odd to involve
  -- coroutines, but it does give a few advantages:
  --  1) Lua can signal the main loop to exit by finishing the coroutine
  --  2) If an error occurs, the call stack is preserved in the coroutine, so
  --     Lua can query or print the call stack as required, rather than
  --     hardcoding error behaviour in C.
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
  local e, where = SDL.mainloop(co)
  self.running = false
  if e ~= nil then
    if where then
      -- Errors from an asynchronous callback done on the dispatcher coroutine
      -- will end up here. As the error didn't originate from a dispatched
      -- event, self.last_dispatch_type is wrong. Therefore, an extra value is
      -- returned from mainloop(), meaning that where == "callback".
      self.last_dispatch_type = where
    end
    print("An error has occured while running the " .. self.last_dispatch_type .. " handler.")
    print "A stack trace is included below, and the handler has been disconnected."
    print(debug.traceback(co, e, 0))
    print ""
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
  return true -- tick events always result in a repaint
end

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

function App:onMusicOver(...)
  return self.audio:onMusicOver(...)
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
  local required = true
  local optional = false
  local dir_map = {
    ANIMS  = optional,
    DATA   = required,
    DATAM  = optional,
    INTRO  = optional,
    LEVELS = required,
    QDATA  = required,
    QDATAM = optional,
    SOUND  = optional,
  }
  for item in lfs.dir(install_folder) do
    if dir_map[item:upper()] ~= nil then
      dir_map[item:upper()] = item
    end
  end
  for dir, name in pairs(dir_map) do
    if name == required then
      error(("Directory '%s' not present in specified Theme Hospital folder ('%s')"):format(dir, install_folder))
    elseif name == optional then
      print(("Notice: Directory \'%s\' not present in specified Theme Hospital folder."):format(dir))
      dir_map[dir] = nil
    end
  end
  self.data_dir_map = dir_map
  
  -- Check for demo version
  local demo = io.open(self:getDataFilename("DataM", "Demo.dat"), "rb")
  if demo then
    demo:close()
    print "Notice: Using data files from demo version of Theme Hospital."
    print "Consider purchasing a full copy of the game to support EA."
  end
end

function App:checkLanguageFile()
  -- Some TH installs are trimmed down to a single language file, rather than
  -- providing every language file. If the user has selected a language which
  -- isn't present, then we should detect this and inform the user of their
  -- options.
  
  local filename = self:getDataFilename(self.config.language .. ".dat")
  local file, err = io.open(filename, "rb")
  if file then
    -- Everything is fine
    file:close()
    return
  end
  
  print "Theme Hospital install seems to be missing the language file for the language which you requested."
  print "The following language files are present:"
  local none = true
  local is_win32 = not not package.cpath:lower():find(".dll", 1, true)
  for item in lfs.dir(self.config.theme_hospital_install .. self.data_dir_map.DATA) do
    local n = item:upper():match"^LANG%-([0-9]+)%.DAT$"
    if n then
      local name = languages_by_num[tonumber(n)] or "??"
      local warning = ""
      if not is_win32 and item ~= item:upper() then
        warning = " (Needs to be renamed to " .. item:upper() .. ")"
      end
      print(" " .. item .. " (" .. name .. ")" .. warning)
      none = false
    end
  end
  if none then
    print " (none)"
  end
  error(err)
end

function App:readBitmapDataFile(filename)
  filename = (self.command_line["bitmap-dir"] or "Bitmap") .. pathsep .. filename
  local file = assert(io.open(filename, "rb"))
  local data = file:read"*a"
  file:close()
  if data:sub(1, 3) == "RNC" then
    data = assert(rnc.decompress(data))
  end
  return data
end

function App:getDataFilename(dir, filename)
  if filename == nil then
    filename = dir
    dir = "DATA"
  end
  dir = dir:upper()
  dir = self.data_dir_map[dir] or dir
  return self.config.theme_hospital_install .. dir .. pathsep .. filename:upper()
end

function App:readDataFile(dir, filename)
  filename = self:getDataFilename(dir, filename)
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
  dir = dir .. pathsep
  local path = ourpath .. dir
  local results = no_results and "" or {}
  for file in lfs.dir(path) do
    if file:match"%.lua$" then
      local chunk, e = loadfile(path .. file)
      if e then
        print("Error loading " .. dir .. file .. ":\n" .. tostring(e))
      else
        local status, result = pcall(chunk, self)
        if not status then
          print("Runtime error loading " .. dir ..  file .. ":\n" .. tostring(result))
        else
          if result == nil then
            if not no_results then
              print("Warning: " .. dir .. file .. " returned no value")
            end
          else
            if type(result) == "table" and result.id then
              results[result.id] = result
            elseif type(result) == "function" then
              results[file:match"(.*)%."] = result
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
