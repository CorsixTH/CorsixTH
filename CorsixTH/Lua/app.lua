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
local assert, io, type, dofile, loadfile, pcall, tonumber, print, setmetatable
    = assert, io, type, dofile, loadfile, pcall, tonumber, print, setmetatable

-- Increment each time a savegame break would occur
-- and add compatibility code in afterLoad functions

local SAVEGAME_VERSION = 81

class "App"

function App:App()
  self.command_line = {}
  self.config = {}
  self.runtime_config = {}
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
    active = self.onWindowActive,
    music_over = self.onMusicOver,
    movie_over = self.onMovieOver
  }
  self.strings = {}
  self.savegame_version = SAVEGAME_VERSION
  self.check_for_updates = true
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
  
  print("")
  print("")
  print("---------------------------------------------------------------")
  print("")
  print("Welcome to CorsixTH " .. self:getVersion() .. "!")
  print("")
  print("---------------------------------------------------------------")
  print("")
  print("This window will display useful information if an error occurs.")
  print("")
  print("---------------------------------------------------------------")
  print("")
  -- Prereq 1: Config file (for screen width / height / TH folder)
  -- Note: These errors cannot be translated, as the config file specifies the language
  local conf_path = self.command_line["config-file"] or "config.txt"
  local conf_chunk, conf_err = loadfile_envcall(conf_path)
  if not conf_chunk then
    error("Unable to load the config file. Please ensure that CorsixTH "..
    "has permission to read/write ".. conf_path ..", or use the "..
    "--config-file=filename command line option to specify a writable file. "..
    "For reference, the error loading the config file was: " .. conf_err)
  else
    conf_chunk(self.config)
  end
  self:fixConfig()
  dofile "filesystem"
  local good_install_folder, error_message = self:checkInstallFolder()
  self.good_install_folder = good_install_folder
  -- self:checkLanguageFile()
  
  self:initSavegameDir()
  
  self:initScreenshotsDir()
  
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
  if compile_opts.renderer == "OpenGL" then
    modes[#modes + 1] = "opengl"
  end
  self.fullscreen = false
  if _MAP_EDITOR then
    MapEditorInitWithLuaApp(self)
    modes[#modes + 1] = "reuse context"
    self.config.width = 640
    self.config.height = 480
  elseif self.config.fullscreen then
    self.fullscreen = true
    modes[#modes + 1] = "fullscreen"
  end
  if self.config.track_fps then
    modes[#modes + 1] = "present immediate"
  end
  self.modes = modes
  self.video = assert(TH.surface(self.config.width, self.config.height, unpack(modes)))
  self.video:setBlueFilterActive(false)
  SDL.wm.setIconWin32()
  
  
  -- Prereq 2: Load and initialise the graphics subsystem
  dofile "persistance"
  dofile "graphics"
  self.gfx = Graphics(self)
  
  -- Put up the loading screen
  if good_install_folder then
    self.video:startFrame()
    self.gfx:loadRaw("Load01V", 640, 480):draw(self.video,
      (self.config.width - 640) / 2, (self.config.height - 480) / 2)
    self.video:endFrame()
    -- Add some notices to the loading screen
    local notices = {}
    local font = self.gfx:loadBuiltinFont()
    if TH.freetype_font and self.gfx:hasLanguageFont("unicode") then
      notices[#notices + 1] = TH.freetype_font.getCopyrightNotice()
      font = self.gfx:loadLanguageFont("unicode", font:getSheet())
    end
    notices = table.concat(notices)
    if notices ~= "" then
      self.video:startFrame()
      self.gfx:loadRaw("Load01V", 640, 480):draw(self.video,
        (self.config.width - 640) / 2, (self.config.height - 480) / 2)
      font:drawWrapped(self.video, notices, 32,
        (self.config.height + 400) / 2, self.config.width - 64, "center")
      self.video:endFrame()
    end
  end
  
  -- App initialisation 2nd goal: Load remaining systems and data in an appropriate order
  
  math.randomseed(os.time() + SDL.getTicks())
  -- Add math.n_random globally. It generates pseudo random normally distributed
  -- numbers using the Box-Muller transform.
  strict_declare_global "math.n_random"
  math.n_random = function(mean, variance)
    return mean + math.sqrt(-2 * math.log(math.random())) 
    * math.cos(2 * math.pi * math.random()) * variance
  end
  -- Also add the nice-to-have function math.round
  strict_declare_global "math.round"
  math.round = function(input)
    return math.floor(input + 0.5)
  end
  -- Load audio
  dofile "audio"
  self.audio = Audio(self)
  self.audio:init()
  
  -- Load movie player
  dofile "movie_player"
  self.moviePlayer = MoviePlayer(self, self.audio)
  if good_install_folder then
    self.moviePlayer:init()
  end

  -- Load strings before UI and before additional Lua
  dofile "strings"
  dofile "string_extensions"
  self.strings = Strings(self)
  self.strings:init()
  local language_load_success = self:initLanguage()
  if (self.command_line.dump or ""):match"strings" then
    -- Specify --dump=strings on the command line to dump strings
    -- (or insert "true or" after the "if" in the above)
    self:dumpStrings()
  end
  
  -- Load map before world
  dofile "map"
  
  -- Load additional Lua before world
  if good_install_folder then
    self.anims = self.gfx:loadAnimations("Data", "V")
    self.animation_manager = AnimationManager(self.anims)
    self.walls = self:loadLuaFolder"walls"
    dofile "entity"
    dofile "entities/humanoid"
    dofile "entities/object"
    dofile "entities/machine"

    local objects = self:loadLuaFolder"objects"
    self.objects = self:loadLuaFolder("objects/machines", nil, objects)
    -- Doors are in their own folder to ensure that the swing doors (which 
    -- depend on the door) are loaded after the door object.
    self.objects = self:loadLuaFolder("objects/doors", nil, objects)
    for _, v in ipairs(self.objects) do
      if v.slave_id then
        v.slave_type = self.objects[v.slave_id]
        v.slave_type.master_type = v
      end
      Object.processTypeDefinition(v)
    end
    dofile "room"
    self.rooms = self:loadLuaFolder"rooms"
    self.humanoid_actions = self:loadLuaFolder"humanoid_actions"
    local diseases = self:loadLuaFolder"diseases"
    self.diseases = self:loadLuaFolder("diagnosis", nil, diseases)
    -- Load world before UI
    dofile "world"
  end
  
  -- Load UI
  dofile "ui"
  if good_install_folder then
    dofile "game_ui"
    self.ui = UI(self, true)
  else
    self.ui = UI(self, true)
    self.ui:setMenuBackground()
    local function callback(path)
      local app = TheApp
      app.config.theme_hospital_install = path
      app:saveConfig()
      debug.getregistry()._RESTART = true
      app.running = false
    end
    self.ui:addWindow(UIDirectoryBrowser(self.ui, nil, _S.install.th_directory, "InstallDirTreeNode", callback))
    return true
  end
  
  -- Load main menu (which creates UI)
  if _MAP_EDITOR then
    self:loadLevel("")
  else
    local function callback_after_movie()
      self:loadMainMenu()
      -- If we couldn't properly load the language, show an information dialog
      if not language_load_success then
        -- At this point we know the language is english, so no use having
        -- localized strings.
        self.ui:addWindow(UIInformation(self.ui, {"The game language has been reverted"..
        " to English because the desired language could not be loaded. "..
        "Please make sure you have specified a font file in the config file."}))
      end
      
      -- If a savegame was specified, load it
      if self.command_line.load then
        local status, err = pcall(self.load, self, self.command_line.load)
        if not status then
          err = _S.errors.load_prefix .. err
          print(err)
          self.ui:addWindow(UIInformation(self.ui, {err}))
        end
      end
      -- There might also be a message from the earlier initialization process that should be shown.
      -- Show it using the built-in font in case the game's font is messed up.
      if error_message then
        self.ui:addWindow(UIInformation(self.ui, error_message, true))
      end
    end
    if self.config.play_intro then
      self.moviePlayer:playIntro(callback_after_movie)
    else
      callback_after_movie()
    end
  end
  return true
end

--! Tries to initialize the savegame directory, returns true on success and
--! false on failure.
function App:initSavegameDir()
  local conf_path = self.command_line["config-file"] or "config.txt"
  self.savegame_dir = self.config.savegames or conf_path:match("^(.-)[^".. pathsep .. "]*$") .. "Saves"
  if self.savegame_dir:sub(-1, -1) == pathsep then
    self.savegame_dir = self.savegame_dir:sub(1, -2)
  end
  if lfs.attributes(self.savegame_dir, "mode") ~= "directory" then
    if not lfs.mkdir(self.savegame_dir) then
       print "Notice: Savegame directory does not exist and could not be created."
       return false
    end
  end
  if self.savegame_dir:sub(-1, -1) ~= pathsep then
    self.savegame_dir = self.savegame_dir .. pathsep
  end
  return true
end

function App:initScreenshotsDir()
  local conf_path = self.command_line["config-file"] or "config.txt"
  self.screenshot_dir = self.config.screenshots or conf_path:match("^(.-)[^".. pathsep .. "]*$") .. "Screenshots"
  if self.screenshot_dir:sub(-1, -1) == pathsep then
    self.screenshot_dir = self.screenshot_dir:sub(1, -2)
  end
  if lfs.attributes(self.screenshot_dir, "mode") ~= "directory" then
    if not lfs.mkdir(self.screenshot_dir) then
       print "Notice: Screenshot directory does not exist and could not be created."
       return false
    end
  end
  if self.screenshot_dir:sub(-1, -1) ~= pathsep then
    self.screenshot_dir = self.screenshot_dir .. pathsep
  end
  return true
end

function App:initLanguage()
  -- Make sure that we can actually show the desired language.
  -- If we can't, then the player probably didn't specify a font file
  -- in the config file properly.
  local success = true
  local language = self.config.language
  local font = self.strings:getFont(language)
  if self.gfx:hasLanguageFont(font) then
    self.gfx.language_font = font
  else
    -- Otherwise revert to english.
    self.gfx.language_font = self.strings:getFont("english")
    language = "english"
    self.config.language = "english"
    success = false
  end

  local strings, speech_file = self.strings:load(language)
  strict_declare_global "_S"
  strict_declare_global "_A"
  local old_S = _S
  _S = strings
  -- For immediate compatibility:
  getmetatable(_S).__call = function(_, sec, str, ...)
    assert(_S.deprecated[sec] and _S.deprecated[sec][str], "_S(".. sec ..", ".. str ..") does not exist!")
    
    str = _S.deprecated[sec][str]
    if ... then
      str = str:format(...)
    end
    return str
  end
  if old_S then
    unpermanent "_S"
  end
  _S = permanent("_S", TH.stringProxy(_S))
  if old_S then
    TH.stringProxy.reload(old_S, _S)
  end
  _A = self.strings:setupAdviserMessage(_S.adviser)

  self.gfx:onChangeLanguage()
  if self.ui then
    self.ui:onChangeLanguage()
  end
  self.audio:initSpeech(speech_file)
  return success
end

function App:loadMainMenu(message)
  -- Make sure there is no blue filter active.
  self.video:setBlueFilterActive(false)

  -- Unload ui, world and map
  self.ui = nil
  self.world = nil
  self.map = nil

  self.ui = UI(self)
  self.ui:setMenuBackground()
  self.ui:addWindow(UIMainMenu(self.ui))
  self.ui:addWindow(UITipOfTheDay(self.ui))
  
  -- Show update window if there's an update
  self:checkForUpdates()
  
  -- If a message was supplied, show it
  if message then
    self.ui:addWindow(UIInformation(self.ui, message))
  end
end

-- Loads the specified level. If a string is passed it looks for the file with the same name
-- in the "Levels" folder of CorsixTH, if it is a number it tries to load that level from
-- the original game.
function App:loadLevel(level, ...)
  -- Check that we can load the data before unloading current map
  local new_map = Map(self)
  local map_objects, errors = new_map:load(level, ...)
  if not map_objects then
    error(errors)
  end
  -- If going from another level, save progress.
  local carry_to_next_level
  if self.world and tonumber(self.world.map.level_number) then
    carry_to_next_level = {
      world = {room_built = self.world.room_built},
      hospital = {
        player_salary = self.ui.hospital.player_salary,
        message_popup = self.ui.hospital.message_popup,
        hospital_littered = self.ui.hospital.hospital_littered,
        has_seen_pay_rise = self.ui.hospital.has_seen_pay_rise,
      },
    }
  end
  
  -- Make sure there is no blue filter active.
  self.video:setBlueFilterActive(false)

  -- Unload ui, world and map
  self.ui = nil
  self.world = nil
  self.map = nil
  
  -- Load map
  self.map = new_map
  self.map:setBlocks(self.gfx:loadSpriteTable("Data", "VBlk-0"))
  self.map:setDebugFont(self.gfx:loadFont("QData", "Font01V"))
  
  -- Load world
  self.world = World(self)
  self.world:createMapObjects(map_objects)
  
  -- Load UI
  self.ui = GameUI(self, self.world:getLocalPlayerHospital())
  self.world:setUI(self.ui) -- Function call allows world to set up its keyHandlers
 
  if tonumber(level) then
    self.moviePlayer:playAdvanceMovie(level)
  end
 
  -- Now restore progress from previous levels.
  if carry_to_next_level then
    self.world:initFromPreviousLevel(carry_to_next_level)
  end
end

-- This is a useful debug and development aid
function App:dumpStrings()
  -- Accessors to reach through the userdata proxies on strings
  local LUT = debug.getregistry().StringProxyValues
  local function val(o)
    if type(o) == "userdata" then
      return LUT[o]
    else
      return o
    end
  end
  local function is_table(o)
    return type(val(o)) == "table"
  end
  local dir = self.command_line["config-file"] or ""
  dir = string.sub(dir, 0, -11)
  local fi = assert(io.open(dir .. "debug-strings-orig.txt", "wt"))
  for i, sec in ipairs(_S.deprecated) do
    for j, str in ipairs(sec) do
      fi:write("[" .. i .. "," .. j .. "] " .. ("%q\n"):format(val(str)))
    end
    fi:write"\n"
  end
  fi:close()
  
  local function dump_by_line(file, obj, prefix)
    for n, o in pairs(obj) do
      if n ~= "deprecated" then
        local new_prefix
        if type(n) == "number" then
          new_prefix = prefix .. "[" .. n .. "]"
        else
          new_prefix = (prefix == "") and n or (prefix .. "." .. n)
        end
        if is_table(o) then
          dump_by_line(file, o, new_prefix)
        else
          file:write(new_prefix .. " = " .. "\"" .. val(o) .. "\"\n")
        end
      end
    end
  end
  
  local function dump_grouped(file, obj, prefix)
    for n, o in pairs(obj) do
      if n ~= "deprecated" then
        if type(n) == "number" then
          n = "[" .. n .. "]"
        end
        if is_table(o) then
          file:write(prefix .. n .. " = {\n")
          dump_grouped(file, o, prefix .. "  ")
          file:write(prefix .. "}")
        else
          file:write(prefix .. n .. " = " .. "\"" .. val(o) .. "\"")
        end
        if prefix ~= "" then
          file:write(",")
        end
        file:write("\n")
      end
    end
  end
  
  fi = assert(io.open(dir .. "debug-strings-new-lines.txt", "wt"))
  dump_by_line(fi, _S, "")
  fi:close()
  
  fi = assert(io.open(dir .. "debug-strings-new-grouped.txt", "wt"))
  dump_grouped(fi, _S, "")
  fi:close()
  
  self:checkMissingStringsInLanguage(dir, self.config.language)
  -- Uncomment these lines to get diffs for all languages in the game
  -- for _, lang in ipairs(self.strings.languages_english) do
  --   self:checkMissingStringsInLanguage(dir, lang)
  -- end
  print("")
  print("------------------------------------------------------")
  print("Dumped strings to default configuration file directory")
  print("------------------------------------------------------")
  print("")
end

--! Compares strings provided by language file of given language WITHOUT inheritance
-- with strings provided by english language with inheritance (i.e. all strings).
-- This will give translators an idea which strings are missing in their translation.
--!param dir The directory where the file to write to should be.
--!param language The language to check against.
function App:checkMissingStringsInLanguage(dir, language)

  -- Accessors to reach through the userdata proxies on strings
  local LUT = debug.getregistry().StringProxyValues
  local function val(o)
    if type(o) == "userdata" then
      return LUT[o]
    else
      return o
    end
  end
  local function is_table(o)
    return type(val(o)) == "table"
  end

  local ltc = self.strings.language_to_chunk
  if ltc[language] ~= ltc["english"] then
    local str_en = self.strings:load("english", true)
    local str_cur = self.strings:load(language, true, true)
    local function dump_diff(file, obj1, obj2, prefix)
      for n, o in pairs(obj1) do
        if n ~= "deprecated" then
          local new_prefix
          if type(n) == "number" then
            new_prefix = prefix .. "[" .. n .. "]"
          else
            new_prefix = (prefix == "") and n or (prefix .. "." .. n)
          end
          if is_table(o) then
            -- if obj2 is already nil (i.e. whole table does not exist in current language), carry over nil
            dump_diff(file, o, obj2 and obj2[n], new_prefix)
          else
            if not (obj2 and obj2[n]) then
              -- does not exist in current language
              file:write(new_prefix .. " = " .. "\"" .. val(o) .. "\"\n")
            end
          end
        end
      end
    end
    
    -- if possible, use the English name of the language for the file name.
    local language_english = language
    for _, lang_eng in ipairs(self.strings.languages_english) do
      if ltc[language] == ltc[lang_eng:lower()] then
        language_english = lang_eng
        break
      end
    end
    
    local fi = assert(io.open(dir .. "debug-strings-diff-" .. language_english:lower() .. ".txt", "wt"))
    fi:write("------------------------------------\n")
    fi:write("MISSING STRINGS IN LANGUAGE \"" .. language:upper() .. "\":\n")
    fi:write("------------------------------------\n")
    dump_diff(fi, str_en, str_cur, "")
    fi:write("------------------------------------\n")
    fi:write("SUPERFLUOUS STRINGS IN LANGUAGE \"" .. language:upper() .. "\":\n")
    fi:write("------------------------------------\n")
    dump_diff(fi, str_cur, str_en, "")
    fi:close()
  end
end

function App:fixConfig()
  -- Fill in default values for things which dont exist
  local _, config_defaults = dofile "config_finder"
  for k, v in pairs(config_defaults) do
    if self.config[k] == nil then
      self.config[k] = v
    end
  end
  
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

function App:saveConfig()
  -- Load lines from config file
  local fi = io.open(self.command_line["config-file"] or "config.txt", "r")
  local lines = {}
  local handled_ids = {}
  if fi then
    for line in fi:lines() do
      lines[#lines + 1] = line
      if not (string.find(line, "^%s*$") or string.find(line, "^%s*%-%-")) then -- empty lines or comments
        -- Look for identifiers we want to save
        local _, _, identifier, value = string.find(line, "^%s*([_%a][_%w]*)%s*=%s*(.-)%s*$")
        if identifier then
          -- Trim possible trailing comment from value
          local _, _, temp = string.find(value, "^(.-)%s*%-%-.*")
          value = temp or value
          -- Remove enclosing [[]], if necessary
          local _, _, temp = string.find(value, "^%[%[(.*)%]%]$")
          value = temp or value
          
          -- If identifier also exists in runtime options, compare their values and
          -- replace the line, if needed
          --if self.config[identifier] ~= nil then
            handled_ids[identifier] = true
            if value ~= tostring(self.config[identifier]) then
              local new_value = self.config[identifier]
              if type(new_value) == "string" then
                new_value = string.format("[[%s]]", new_value)
              else
                new_value = tostring(new_value)
              end
              lines[#lines] = string.format("%s = %s", identifier, new_value)
            end
          --end
        end
      end
    end
    fi:close()
  end
  -- Append options that were not found
  for identifier, value in pairs(self.config) do
    if not handled_ids[identifier] then
      if type(value) == "string" then
        value = string.format("[[%s]]", value)
      else
        value = tostring(value)
      end
      lines[#lines + 1] = string.format("%s = %s", identifier, value)
    end
  end
  -- Trim trailing newlines
  while lines[#lines] == "" do
    lines[#lines] = nil
  end

  fi = io.open(self.command_line["config-file"] or "config.txt", "w")
  for _, line in ipairs(lines) do
    fi:write(line .. "\n")
  end
  fi:close()
end

function App:run()
  -- The application "main loop" is an SDL event loop written in C, which calls
  -- a coroutine whenever an event occurs. Initially it may seem odd to involve
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
  
  if self.config.track_fps then
    SDL.trackFPS(true)
    SDL.limitFPS(false)
  end
  
  self.running = true
  do
    local num_iterations = 0
    self.resetInfiniteLoopChecker = function()
      num_iterations = 0
    end
    debug.sethook(co, function()
      num_iterations = num_iterations + 1
      if num_iterations == 100 then
        error("Suspected infinite loop", 2)
      end
    end, "", 1e7)
  end
  coroutine.resume(co, self)
  local e, where = SDL.mainloop(co)
  debug.sethook(co, nil)
  self.running = false
  if e ~= nil then
    if where then
      -- Errors from an asynchronous callback done on the dispatcher coroutine
      -- will end up here. As the error didn't originate from a dispatched
      -- event, self.last_dispatch_type is wrong. Therefore, an extra value is
      -- returned from mainloop(), meaning that where == "callback".
      self.last_dispatch_type = where
    end
    print("An error has occured!")
    print("Almost anything can be the cause, but the detailed information "..
    "below can help the developers find the source of the error.")
    print("Running: The " .. self.last_dispatch_type .. " handler.")
    print "A stack trace is included below, and the handler has been disconnected."
    print(debug.traceback(co, e, 0))
    print ""
    if self.world then
      self.world:gameLog("Error in " .. self.last_dispatch_type .. " handler: ")
      self.world:gameLog(debug.traceback(co, e, 0))
      self.world:dumpGameLog()
    end
    if self.world and self.last_dispatch_type == "timer" and self.world.current_tick_entity then
      -- Disconnecting the tick handler is quite a drastic measure, so give
      -- the option of just disconnecting the offending entity and attempting
      -- to continue.
      local handler = self.eventHandlers[self.last_dispatch_type]
      local entity = self.world.current_tick_entity
      self.world.current_tick_entity = nil
      if class.is(entity, Patient) then
        self.ui:addWindow(UIPatient(self.ui, entity))
      elseif class.is(entity, Staff) then
        self.ui:addWindow(UIStaff(self.ui, entity))
      end
      self.ui:addWindow(UIConfirmDialog(self.ui,
        "Sorry, but an error has occured. There can be many reasons - see the log "..
        "window for details. Would you like to attempt a recovery?",
        --[[persistable:app_attempt_recovery]] function()
          self.world:gameLog("Recovering from error in timer handler...")
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
    self:resetInfiniteLoopChecker()
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
  if(not self.moviePlayer.playing) then
    if self.world then
      self.world:onTick(...)
    end
    self.ui:onTick(...)
  end
  return true -- tick events always result in a repaint
end

local fps_history = {} -- Used to average FPS over the last thirty frames
for i = 1, 30 do fps_history[i] = 0 end
local fps_sum = 0 -- Sum of fps_history array
local fps_next = 1 -- Used to loop through fps_history when [over]writing

function App:drawFrame()
  if(self.moviePlayer.playing) then
    self.moviePlayer:refresh()
  else
    self.video:startFrame()
    self.ui:draw(self.video)
    self.video:endFrame()
  end
  
  if self.config.track_fps then
    fps_sum = fps_sum - fps_history[fps_next]
    fps_history[fps_next] = SDL.getFPS()
    fps_sum = fps_sum + fps_history[fps_next]
    fps_next = (fps_next % #fps_history) + 1
  end
end

function App:getFPS()
  if self.config.track_fps then
    return fps_sum / #fps_history
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

function App:onWindowActive(...)
  return self.ui:onWindowActive(...)
end

function App:onMusicOver(...)
  return self.audio:onMusicOver(...)
end

function App:onMovieOver(...)
  self.moviePlayer:onMovieOver(...)
end

function App:checkInstallFolder()
  self.fs = FileSystem()
  local status, err
  if self.config.theme_hospital_install then
    status, err = self.fs:setRoot(self.config.theme_hospital_install)
  end
  local message = "Please make sure that you point the game to"..
    " a valid copy of the data files from the original game,"..
    " as said files are required for graphics and sounds."
  if not status then
    -- If the given directory didn't exist, then likely the config file hasn't
    -- been changed at all from the default, so we continue to initialise the
    -- app, and give the user a dialog asking for the correct directory.
    return false
  end
  
  -- Check that a few core files are present
  local missing = {}
  local function check(path)
    if not self.fs:readContents(path) then
      missing[#missing + 1] = path
    end
  end
  check("Data".. pathsep .."VBlk-0.tab")
  check("Levels".. pathsep .."Level.L1")
  check("QData".. pathsep .."SPointer.dat")
  if #missing ~= 0 then
    missing = table.concat(missing, ", ")
    message = "Invalid Theme Hospital folder specified in config file, "..
          "as at least the following files are missing: ".. missing ..".\n"..
          message
    print(message)
    print("Trying to let the user select a new one.")
    return false, {message}
  end
    
  -- Check for demo version
  if self.fs:readContents("DataM", "Demo.dat") then
    self.using_demo_files = true
    print "Notice: Using data files from demo version of Theme Hospital."
    print "Consider purchasing a full copy of the game to support EA."
  end
  
  -- Do a few more checks to make sure that commonly corrupted files are OK.
  local corrupt = {}

  if not self.using_demo_files then
    local function check_corrupt(path, correct_size)
      local real_path = self.fs:getFilePath(path)
      -- If the file exists but is smaller than usual it is probably corrupt
      if real_path then
        local real_size = lfs.attributes(real_path, "size") 
        if real_size + 1024 < correct_size or real_size - 1024 > correct_size then
          corrupt[#corrupt + 1] = path .. " (Size: " .. math.floor(real_size/1024) .. " kB / Correct: about " .. math.floor(correct_size/1024) .. " kB)"
        end
      else
        corrupt[#corrupt + 1] = path .. " (This file is missing)"
      end
    end
    check_corrupt("ANIMS" .. pathsep .. "AREA01V.SMK", 251572)
    check_corrupt("ANIMS" .. pathsep .. "WINGAME.SMK", 2066656)
    check_corrupt("ANIMS" .. pathsep .. "WINLEVEL.SMK", 335220)
    check_corrupt("INTRO" .. pathsep .. "INTRO.SM4", 33616520)
    check_corrupt("QDATA" .. pathsep .. "FONT00V.DAT", 1024)
    check_corrupt("ANIMS" .. pathsep .. "LOSE1.SMK", 1009728)
    
    if #corrupt ~= 0 then
      table.insert(corrupt, 1, "There appears to be corrupt files in your Theme Hospital folder, " .. 
      "so don't be suprised if CorsixTH crashes. At least the following files are wrong:")
      table.insert(corrupt, message)
    end
  end
  
  return true, #corrupt ~= 0 and corrupt or nil
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

--! Get the directory containing the bitmap files.
--!return Name of the directory containing the bitmap files, ending with a
--        directory path separator.
function App:getBitmapDir()
  return (self.command_line["bitmap-dir"] or "Bitmap") .. pathsep
end

-- Load bitmap data into memory.
--!param filename Name of the file to load.
--!return The loaded data.
function App:readBitmapDataFile(filename)
  filename = self:getBitmapDir() .. filename
  local file = assert(io.open(filename, "rb"))
  local data = file:read"*a"
  file:close()
  if data:sub(1, 3) == "RNC" then
    data = assert(rnc.decompress(data))
  end
  return data
end

-- Read a data file of the application into memory (possibly with decompression).
--!param dir (string) Directory to read from. "Bitmap" and "Levels" are
--       meta-directories, and get resolved to real directories in the function.
--!param filename (string or nil) If specified, the file to load. If 'nil', the
--       'dir' parameter is the filename in the "Data" directory.
function App:readDataFile(dir, filename)
  if dir == "Bitmap" then
    return self:readBitmapDataFile(filename)
  elseif dir == "Levels" then
    return self:readLevelDataFile(filename)
  end
  if filename == nil then
    dir, filename = "Data", dir
  end
  local data = assert(self.fs:readContents(dir .. pathsep .. filename))
  if data:sub(1, 3) == "RNC" then
    data = assert(rnc.decompress(data))
  end
  return data
end

--! Get a level file.
--!param filename (string) Name of the level file.
--!return If the file could be found, the data of the file, else a
--        tuple 'nil', and an error description
function App:readLevelDataFile(filename)
  local dir = "Levels" .. pathsep .. filename
  -- First look in the original install directory, if not found there
  -- look in the CorsixTH directory "Levels".
  local data = self.fs:readContents(dir)
  if not data then
    local file = io.open(debug.getinfo(1, "S").source:sub(2, -12) .. dir, "rb")
    if file then
      data = file:read"*a"
      file:close()
    end
  end
  if data then
    if data:sub(1, 3) == "RNC" then
      data = assert(rnc.decompress(data))
    end
  else
    -- Could not find the file
    return nil, _S.errors.map_file_missing:format(filename)
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

--! Returns the version number (name) of the local copy of the game based on
--! which save game version it is. This was added after the Beta 8
--! release, which is why the checks prior to that version aren't made.
--!param version An optional value if you want to find what game version
-- a specific savegame verion is from.
function App:getVersion(version)
  local ver = version or self.savegame_version
  if ver > 78 then
    return "Trunk"
  elseif ver > 72 then
    return "0.30"
  elseif ver > 66 then
    return "0.21"
  elseif ver > 54 then
    return "0.20"
  elseif ver > 53 then
    return "0.11"
  elseif ver > 51 then
    return "0.10"
  elseif ver > 45 then
    return "0.01"
  else
    return "Beta 8 or earlier"
  end
end

function App:save(filename)
  return SaveGameFile(self.savegame_dir .. filename)
end
-- Omit the usual file extension so this file cannot be seen from the normal load and save screen and cannot be overwritten
function App:quickSave()
  local filename = "quicksave"
  return SaveGameFile(self.savegame_dir .. filename)
end

function App:load(filename)
  return LoadGameFile(self.savegame_dir .. filename)
end

function App:quickLoad()
  local filename = "quicksave"
  if lfs.attributes(self.savegame_dir .. filename) then
    self:load(filename)  
  else 
    self:quickSave()  
    self.ui:addWindow(UIInformation(self.ui, {_S.errors.load_quick_save}))
  end
end

--! Restarts the current level (offers confirmation window first)
function App:restart()
  assert(self.map, "Trying to restart while no map is loaded.")
  self.ui:addWindow(UIConfirmDialog(self.ui, _S.confirmation.restart_level,
  --[[persistable:app_confirm_restart]] function()
    local level = self.map.level_number
    local difficulty = self.map.difficulty
    local name, file, intro
    if not tonumber(level) then
      name = self.map.level_name
      file = self.map.level_file
      intro = self.map.level_intro
    end
    if level and name and not file then
      self.ui:addWindow(UIInformation(self.ui, {_S.information.cannot_restart}))
      return
    end
    local status, err = pcall(self.loadLevel, self, level, difficulty, name, file, intro)
    if not status then
      err = "Error while loading level: " .. err
      print(err)
      self.ui:addWindow(UIInformation(self.ui, {err}))
    end
  end))
end

--! Exits the game completely (no confirmation window)
function App:exit()
  -- Save config before exiting
  self:saveConfig()
  self.running = false
end

--! Exits the game completly without saving the config i.e. Alt+F4 for Quit Application
function App:abandon()
  self.running = false
end

--! This function is automatically called after loading a game and serves for compatibility.
function App:afterLoad()
  local old = self.world.savegame_version or 0
  local new = self.savegame_version
  
  if old == 0 then
    -- Game log was not present before introduction of savegame versions, so create it now.
    self.world.game_log = {}
    self.world:gameLog("Created Gamelog on load of old (pre-versioning) savegame.")
  end
  if not self.world.original_savegame_version then
    self.world.original_savegame_version = old
  end
  local first = self.world.original_savegame_version
  if new == old then
    self.world:gameLog("Savegame version is " .. new .. " (" .. self:getVersion() 
      .. "), originally it was " .. first .. " (" .. self:getVersion(first) .. ")")
    return
  elseif new > old then
    self.world:gameLog("Savegame version changed from " .. old .. " (" .. self:getVersion(old) ..
                       ") to " .. new .. " (" .. self:getVersion() .. 
                       "). The save was created using " .. first .. 
                       " (" .. self:getVersion(first) .. ")")
  else
    -- TODO: This should maybe be forbidden completely.
    self.world:gameLog("Warning: loaded savegame version " .. old .. " (" .. self:getVersion(old) ..
                       ")" .. " in older version " .. new .. " (" .. self:getVersion() .. ").")
  end
  self.world.savegame_version = new
  
  self.map:afterLoad(old, new)
  self.world:afterLoad(old, new)
  self.ui:afterLoad(old, new)
end

function App:checkForUpdates()
  -- Only check for updates once per application launch
  if not self.check_for_updates or not self.config.check_for_updates then return end
  self.check_for_updates = false
  
  -- Default language to use for the changelog if no localised version is available
  local default_language = "en"
  local update_url = 'http://www.corsixth.com/check-for-updates'
  local current_version = self:getVersion()
  
  -- Only URLs that match this list of trusted domains will be accepted.
  local trusted_domains = { 'corsixth.com', 'code.google.com' }
  
  -- Only check for updates against released versions
  if current_version == "Trunk" then
    print "Will not check for updates since this is the Trunk version."
    return
  end

  local success, socket = pcall(require, "socket")

  if not success then
    -- LuaSocket is not available, just return
    print "Cannot check for updates since LuaSocket is not available."
    return
  end
  local http = require "socket.http"
  local url = require "socket.url"

  print "Checking for CorsixTH updates..."
  local update_body, status, headers = http.request(update_url)

  if not update_body or not (status == 200) then
    print("Couldn't check for updates. Server returned code: " .. status)
    print("Check that you have an active internet connection and that CorsixTH is allowed in your firewall.")
    return
  end

  local update_table = loadstring_envcall(update_body, "@updatechecker"){}
  local changelog = update_table["changelog_" .. default_language] 
  local new_version = update_table["major"] .. '.' .. update_table["minor"] .. update_table["revision"]
  
  if (new_version <= current_version) then
    print "You are running the latest version of CorsixTH."
    return
  end
  
  -- Check to make sure download URL is trusted
  local download_url = url.parse(update_table["download_url"])
  local valid_url = false
  for _,v in ipairs(trusted_domains) do
    if download_url.host == v then
      valid_url = true
      break
    end
  end
  if not valid_url then 
    print ("Update download url is not on the trusted domains list (" .. updateTable["download_url"] .. ")")
    return
  end
  
  -- Check to see if there's a changelog in the user's language
  local current_langs = self.strings:getLanguageNames(self.config.language)
  for _,v in ipairs(current_langs) do
    if (update_table["changelog_" .. v]) then
      changelog = update_table["changelog_" .. v]
      break
    end
  end
  
  print ("New version found: " .. new_version)
  -- Display the update window
  self.ui:addWindow(UIUpdate(self.ui, current_version, new_version, changelog, update_table["download_url"]))
end

-- Do not remove, for savegame compatibility < r1891
local app_confirm_quit_stub = --[[persistable:app_confirm_quit]] function()
end
