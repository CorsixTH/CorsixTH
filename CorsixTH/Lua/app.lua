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
  assert(loadfile_envcall(self.command_line["config-file"] or "config.txt"))(self.config)
  self:fixConfig()
  self:checkInstallFolder()
--  self:checkLanguageFile()
  
  -- Create the window
  if not SDL.init("audio", "video", "timer") then
    return false, "Cannot initialise SDL"
  end
  local compile_opts = TH.GetCompileOptions()
  local api_version = dofile "api_version"
  if api_version ~= compile_opts.api_version then
    api_version = api_version or 0
    compile_opts.api_version = compile_opts.api_version or 0
    if api_version < compile_opts.api_version then
      print "Notice: Compiled binary is more recent than Lua scripts."
    elseif api_version > compile_opts.api_version then
      print("Warning: Compiled binary is out of date. CorsixTH will likely"..
      " fail to run until you recompile the binary.")
    end
  end
  local caption_descs = {compile_opts.renderer}
  if compile_opts.jit then
    caption_descs[#caption_descs + 1] = compile_opts.jit
  end
  if compile_opts.arch_64 then
    caption_descs[#caption_descs + 1] = "64 bit"
  end
  self.caption = "CorsixTH (" .. table.concat(caption_descs, ", ") .. ")"
  SDL.wm.setCaption(self.caption)
  local modes = {"hardware", "doublebuf"}
  self.fullscreen = false
  if _MAP_EDITOR then
    modes[#modes + 1] = "reuse context"
    self.config.width = 640
    self.config.height = 480
  elseif self.config.fullscreen then
    self.fullscreen = true
    modes[#modes + 1] = "fullscreen"
  end
  if TRACK_FPS then
    modes[#modes + 1] = "present immediate"
  end
  self.modes = modes
  self.video = assert(TH.surface(self.config.width, self.config.height, unpack(modes)))
  SDL.wm.setIconWin32()
  
  -- Prereq 2: Load and initialise the graphics subsystem
  dofile "persistance"
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
  dofile "strings"
  self.strings = Strings(self)
  self.strings:init()
  local strings, speech_file = self.strings:load(self.config.language)
  strict_declare_global "_S"
  _S = strings
  -- For immediate compatibility:
  getmetatable(_S).__call = function(_S, sec, str, ...)
    assert(_S.deprecated[sec] and _S.deprecated[sec][str], "_S(".. sec ..", ".. str ..") does not exist!")
    
    str = _S.deprecated[sec][str]
    if ... then
      str = str:format(...)
    end
    return str
  end
  if (self.command_line.dump or ""):match"strings" then
    -- Specify --dump=strings on the command line to dump strings
    -- (or insert "true or" after the "if" in the above)
    self:dumpStrings "debug-strings.txt"
  end
  
  -- Load audio
  dofile "audio"
  self.audio = Audio(self)
  self.audio:init(speech_file)
  
  -- Load map before world
  dofile "map"
  
  -- Load additional Lua before world
  self.anims = self.gfx:loadAnimations("Data", "V")
  self.animation_manager = AnimationManager(self.anims)
  self.walls = self:loadLuaFolder"walls"
  dofile "entities/object"

  local objects = self:loadLuaFolder"objects"
  self.objects = self:loadLuaFolder("objects/machines", nil, objects)
  for _, v in ipairs(self.objects) do
    Object.processTypeDefinition(v)
  end
  dofile "room"
  self.rooms = self:loadLuaFolder"rooms"
  self.humanoid_actions = self:loadLuaFolder"humanoid_actions"
  local diseases = self:loadLuaFolder"diseases"
  self.diseases = self:loadLuaFolder("diagnosis", nil, diseases)
  
  -- Load world before UI
  dofile "world"
  
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
  local map_objects = self.map:load(data)
  self.map:setBlocks(self.gfx:loadSpriteTable("Data", "VBlk-0"))
  self.map:setDebugFont(self.gfx:loadFont("QData", "Font01V"))
  
  -- Load world
  self.world = World(self)
  self.world:createMapObjects(map_objects)
  
  -- Load UI
  self.ui = UI(self, self.world:getLocalPlayerHospital())
  self.world:setUI(self.ui) -- Function call allows world to set up its keyHandlers
end

-- This is a useful debug and development aid
function App:dumpStrings()
  local fi = assert(io.open("debug-strings-orig.txt", "wt"))
  for i, sec in ipairs(_S.deprecated) do
    for j, str in ipairs(sec) do
      fi:write("[" .. i .. "," .. j .. "] " .. ("%q\n"):format(str))
    end
    fi:write"\n"
  end
  fi:close()
  
  local function dump_by_line(file, obj, prefix)
    prefix = (prefix == "") and "" or (prefix .. ".")
    for n, o in pairs(obj) do
      if n ~= "deprecated" then
        if type(o) == "table" then
          dump_by_line(file, o, prefix .. n)
        else
          if type(n) == "number" then
            n = "[" .. n .. "]"
          end
          file:write(prefix .. n .. " = " .. "\"" .. o .. "\"\n")
        end
      end
    end
  end
  
  local function dump_grouped(file, obj, prefix)
    for n, o in pairs(obj) do
      if n ~= "deprecated" then
        if type(o) == "table" then
          file:write(prefix .. n .. " = {\n")
          dump_grouped(file, o, prefix .. "  ")
          file:write(prefix .. "}\n")
        else
          if type(n) == "number" then
            n = "[" .. n .. "]"
          end
          file:write(prefix .. n .. " = " .. "\"" .. o .. "\",\n")
        end
      end
    end
  end
  
  fi = assert(io.open("debug-strings-new-lines.txt", "wt"))
  dump_by_line(fi, _S, "")
  fi:close()

  fi = assert(io.open("debug-strings-new-grouped.txt", "wt"))
  dump_grouped(fi, _S, "")
  fi:close()
end

function App:fixConfig()
  for key, value in pairs(self.config) do
    -- Trim whitespace from beginning and end string values - it shouldn't be
    -- there (at least in any current configuration options).
    if type(value) == "string" then
      if value:match"^[%s]" or value:match"[%s]$" then
        self.config[key] = value:match"^[%s]*(.-)[%s]*$"
      end
    end
    
    -- For language, make language name lower case
    if key == "language" and type(value) == "string" then
      self.config[key] = value:lower()
    end
    
    -- For resolution, check that resolution is at least 640x480
    if key == "width" and type(value) == "number" and value < 640 then
      self.config[key] = 640
    end
    
    if key == "height" and type(value) == "number" and value < 480 then
      self.config[key] = 480
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
    if self.last_dispatch_type == "timer" and self.world.current_tick_entity then
      -- Disconnecting the tick handler is quite a drastic measure, so give
      -- the option of just disconnecting the offending entity and attemping
      -- to continue.
      local handler = self.eventHandlers[self.last_dispatch_type]
      local entity = self.world.current_tick_entity
      self.world.current_tick_entity = nil
      self.ui:addWindow(UIInformation(self.ui,
        "An error has occured while running the timer handler - see the log "..
        "window for details. Would you like to attempt a recovery?",
        --[[persistable:app_attempt_recovery]] function()
          entity.ticks = false
          self.eventHandlers.timer = handler
        end
      ))
    end
    self.eventHandlers[self.last_dispatch_type] = nil
    if self.last_dispatch_type ~= "frame" then
      -- If it wasn't the drawing code which failed, then it would be useful
      -- to ensure that a draw happens, as with events disconnected, a frame
      -- might not otherwise be drawn for a while.
      pcall(self.drawFrame, self)
    end
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

local fps_history = {} -- Used to average FPS over the last thirty frames
for i = 1, 30 do fps_history[i] = 0 end
local fps_sum = 0 -- Sum of fps_history array
local fps_next = 1 -- Used to loop through fps_history when [over]writing

function App:drawFrame()
  self.video:startFrame()
  self.ui:draw(self.video)
  self.video:endFrame()
  
  if TRACK_FPS then
    fps_sum = fps_sum - fps_history[fps_next]
    fps_history[fps_next] = SDL.getFPS()
    fps_sum = fps_sum + fps_history[fps_next]
    fps_next = (fps_next % #fps_history) + 1
    SDL.wm.setCaption(self.caption .. (" - %i FPS, %.1f Kb Lua memory"):format(fps_sum / #fps_history, collectgarbage"count"))
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

-- TODO: is it okay to remove this without replacement?
--[[
function App:checkLanguageFile()
  -- Some TH installs are trimmed down to a single language file, rather than
  -- providing every language file. If the user has selected a language which
  -- isn't present, then we should detect this and inform the user of their
  -- options.
  
  local filename = self:getDataFilename("Lang-" .. self.config.language .. ".dat")
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
end]]

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

function App:loadLuaFolder(dir, no_results, append_to)
  local ourpath = debug.getinfo(1, "S").source:sub(2, -8)
  dir = dir .. pathsep
  local path = ourpath .. dir
  local results = no_results and "" or (append_to or {})
  for file in lfs.dir(path) do
    if file:match"%.lua$" then
      local status, result = pcall(dofile, dir .. file:sub(1, -5))
      if not status then
        print("Error loading " .. dir ..  file .. ":\n" .. tostring(result))
      else
        if result == nil then
          if not no_results then
            print("Warning: " .. dir .. file .. " returned no value")
          end
        else
          if no_results then
            print("Warning: " .. dir .. file .. " returned a value:", result)
          end
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
  if no_results then
    return
  else
    return results
  end
end

function App:quit()
  self.ui:addWindow(UIInformation(self.ui, _S.confirmation.quit, --[[persistable:app_confirm_quit]] function()
    self.running = false
  end))
end
