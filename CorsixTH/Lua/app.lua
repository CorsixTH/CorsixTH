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
local rnc = require("rnc")
local lfs = require("lfs")
local TH = require("TH")
local SDL = require("sdl")
local runDebugger = corsixth.require("run_debugger")

-- Increment each time a savegame break would occur
-- and add compatibility code in afterLoad functions
-- Recommended: Also replace/Update the summary comment

local SAVEGAME_VERSION = 194 -- CorsixTH 0.68.0 release

class "App"

---@type App
local App = _G["App"]

function App:App()
  self.command_line = {}
  self.config = {}
  self.hotkeys = {}
  self.runtime_config = {}
  self.running = false
  self.key_modifiers = {}
  self.gfx = {}
  self.last_dispatch_type = ""
  self.eventHandlers = {
    frame = self.drawFrame,
    timer = self.onTick,
    keydown = self.onKeyDown,
    keyup = self.onKeyUp,
    textediting = self.onEditingText,
    textinput = self.onTextInput,
    buttonup = self.onMouseUp,
    buttondown = self.onMouseDown,
    mousewheel = self.onMouseWheel,
    motion = self.onMouseMove,
    active = self.onWindowActive,
    window_resize = self.onWindowResize,
    music_over = self.onMusicOver,
    movie_over = self.onMovieOver,
    sound_over = self.onSoundOver,
    multigesture = self.onMultiGesture
  }
  self.strings = {}
  self.savegame_version = SAVEGAME_VERSION
  self.check_for_updates = TH.GetCompileOptions().update_check
  self.idle_tick = 0
  self.window_active_status = false -- whether window is in focus, set after App:init
end

--! Starts a Lua DBGp client & connects it to a DBGp server.
--!return error_message (String) Returns an error message or nil.
function App:connectDebugger()
  return runDebugger()
end

function App:setCommandLine(...)
  self.command_line = { ... }
  for _, arg in ipairs(self.command_line) do
    local setting, value = arg:match("^%-%-([^=]*)=(.*)$") --setting=value
    if value then
      self.command_line[setting] = value
    end
  end
end

--! Returns the full path of the local path given
--!param folders (string or table) A string of one segment or an set of many segments of the path
--!param trailing_slash (boolean) Whether the path needs to end with a local path separator
--!return fullpath (string) The OS dependent full path
function App:getFullPath(folders, trailing_slash)
  if type(folders) ~= "table" then folders = {folders} end
  local ending = trailing_slash and pathsep or ""
  return debug.getinfo(1, "S").source:sub(2, -12) .. table.concat(folders, pathsep) .. ending
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
    error("Unable to load the config file. Please ensure that CorsixTH " ..
      "has permission to read/write " .. conf_path .. ", or use the " ..
      "--config-file=filename command line option to specify a writable file. " ..
      "For reference, the error loading the config file was: " .. conf_err)
  else
    conf_chunk(self.config)
  end
  self:fixConfig()
  corsixth.require("filesystem")
  local good_install_folder, error_message = self:checkInstallFolder()
  self.good_install_folder = good_install_folder
  self.level_dir = self:getFullPath("Levels", true)
  self.campaign_dir = self:getFullPath("Campaigns", true)
  self:initUserDirectories()
  self:initSavegameDir()
  self:initScreenshotsDir()

  -- Create the window
  if not SDL.init("video", "timer") then
    return false, "Cannot initialise SDL"
  end
  local compile_opts = TH.GetCompileOptions()
  if compile_opts.audio then
    SDL.init("audio")
  end
  local api_version = corsixth.require("api_version")
  if api_version ~= compile_opts.api_version then
    api_version = api_version or 0
    compile_opts.api_version = compile_opts.api_version or 0
    if api_version < compile_opts.api_version then
      print("Notice: Compiled binary is more recent than Lua scripts.")
    elseif api_version > compile_opts.api_version then
      print("Warning: Compiled binary is out of date. CorsixTH will likely" ..
        " fail to run until you recompile the binary.")
    end
  end

  -- Report operating system
  if compile_opts.os then
    self.os = compile_opts.os
  end

  local modes = {}
  self.fullscreen = false
  if self.config.fullscreen then
    self.fullscreen = true
    modes[#modes + 1] = "fullscreen"
  end
  if self.config.track_fps then
    modes[#modes + 1] = "present immediate"
  end
  if self.config.direct_zoom == nil or self.config.direct_zoom then
    modes[#modes + 1] = "direct zoom"
  end
  self.modes = modes
  self.video = assert(TH.surface(self.config.width, self.config.height, unpack(modes)))
  self.video:setBlueFilterActive(false)
  SDL.wm.setIconWin32()

  self:setCaptureMouse()
  self.caption = "CorsixTH"

  -- Create gamelog file if missing
  self:initGamelogFile()

  -- Prereq 2: Load and initialise the graphics subsystem
  corsixth.require("persistance")
  corsixth.require("graphics")
  self.gfx = Graphics(self)

  -- Put up the loading screen
  if good_install_folder then
    self.video:startFrame()
    self.gfx:loadRaw("Load01V", 640, 480):draw(self.video,
      math.floor((self.config.width - 640) / 2), math.floor((self.config.height - 480) / 2))
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
        math.floor((self.config.width - 640) / 2), math.floor((self.config.height - 480) / 2))
      font:drawWrapped(self.video, notices, 32,
        math.floor((self.config.height + 400) / 2), math.floor(self.config.width - 64), "center")
      self.video:endFrame()
    end
  end

  -- App initialisation 2nd goal: Load remaining systems and data in an appropriate order

  math.randomseed(os.time() + SDL.getTicks())
  -- The following psuedo-random number generators are based on different
  -- disritubtion algorithms. For explanations and how to use them see the Wiki

  -- Add math.t_random globally.
  -- It generates pseudo random triangular distributed numbers in interval (a, b)
  -- mostly around c between a and b.
  strict_declare_global "math.t_random"
  math.t_random = function(a, c, b)
    assert(a < c, "Left boundary a should be less than center c.")
    assert(c < b, "Right boundary b should more than center c.")
    -- normalize c (a -> 0, b -> 1)
    local range = b - a
    c = (c - a) / range

    local u = math.random()
    if u <= c then
      return a + math.sqrt(c * u) * range
    else
      return a + (1 - math.sqrt((1 - c) * (1 - u))) * range
    end
  end

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
  corsixth.require("audio")
  self.audio = Audio(self)
  self.audio:init()

  -- Load movie player
  corsixth.require("movie_player")
  self.moviePlayer = MoviePlayer(self, self.audio, self.video)
  if good_install_folder then
    self.moviePlayer:init()
  end

  -- Load strings before UI and before additional Lua
  corsixth.require("strings")
  corsixth.require("string_extensions")
  self.strings = Strings(self)
  self.strings:init()
  local language_load_success = self:initLanguage()
  if (self.command_line.dump or ""):match("strings") then
    -- Specify --dump=strings on the command line to dump strings
    -- (or insert "true or" after the "if" in the above)
    self:dumpStrings()
  end

  -- Load/setup hotkeys.
  local hotkeys_path = self.command_line["hotkeys-file"] or "hotkeys.txt"
  local hotkeys_chunk, hotkeys_err = loadfile_envcall(hotkeys_path)
  if not hotkeys_chunk then
    error(_S.hotkeys_file_err.file_err_01 .. hotkeys_path .. _S.hotkeys_file_err.file_err_02 .. hotkeys_err)
  else
    hotkeys_chunk(self.hotkeys)
  end
  self:fixHotkeys()

  -- Load map before world
  corsixth.require("map")

  -- Load additional Lua before world
  if good_install_folder then
    self.anims = self.gfx:loadAnimations("Data", "V")
    self.animation_manager = AnimationManager(self.anims)
    self.walls = self:loadLuaFolder("walls")
    corsixth.require("entity")
    corsixth.require("entities.humanoid")
    corsixth.require("entities.object")
    corsixth.require("entities.machine")

    local objects = self:loadLuaFolder("objects")
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

    corsixth.require("room")
    self.rooms = self:loadLuaFolder("rooms")

    corsixth.require("humanoid_action")
    self.humanoid_actions = self:loadLuaFolder("humanoid_actions")

    local diseases = self:loadLuaFolder("diseases")
    self.diseases = self:loadLuaFolder("diagnosis", nil, diseases)

    -- Load world before UI
    corsixth.require("world")
  end

  -- Load UI
  corsixth.require("ui")
  if good_install_folder then
    corsixth.require("game_ui")
    self.ui = UI(self, true)
  else
    self.ui = UI(self, true)
    self.ui:setMenuBackground()
    local function callback(path)
      TheApp.config.theme_hospital_install = path
      TheApp:saveConfig()
      debug.getregistry()._RESTART = true
      TheApp.running = false
    end

    self.ui:addWindow(UIDirectoryBrowser(self.ui, nil, _S.install.th_directory, "InstallDirTreeNode", callback))
    return true
  end


  -- Load main menu (which creates UI)
  local function callback_after_movie()
    self:loadMainMenu()
    -- If we couldn't properly load the language, show an information dialog
    if not language_load_success then
      -- At this point we know the language is english, so no use having
      -- localized strings.
      self.ui:addWindow(UIInformation(self.ui, { "The game language has been reverted" ..
          " to English because the desired language could not be loaded. " ..
          "Please make sure you have specified a font file in the config file." }))
    end

    -- If the player wants to continue then load the youngest file in the Autosaves folder
    -- If they give a month number then load that month's autosave
    if self.command_line.continue then
      local num = self.command_line.continue
      local file = "Autosaves" .. pathsep .. "Autosave" .. num .. ".sav"
      if num >= "1" and num <= "12" and lfs.attributes(self.savegame_dir .. file, "size") then
        self.command_line.load = file
      else
        self.command_line.load = "Autosaves" .. pathsep ..
            FileTreeNode(self.savegame_dir .. "Autosaves"):getMostRecentlyModifiedChildFile(".%.sav$").label
      end
    end
    -- If a savegame was specified, load it
    if self.command_line.load then
      local status, err = pcall(self.load, self, self.savegame_dir .. self.command_line.load)
      if not status then
        err = _S.errors.load_prefix .. err
        print(err)
        self.ui:addWindow(UIInformation(self.ui, { err }))
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
  return true
end

--! Works out the intended location of the gamelog file.
--!return full path gamelog should exist at
function App:getGamelogPath()
  local config_path = self.command_line["config-file"] or ""
  config_path = config_path:match("^(.-)[^" .. pathsep .. "]*$")
  return config_path .. "gamelog.txt"
end

--! Checks and creates the gamelog file if it does not exist.
function App:initGamelogFile()
  local gamelog_path = self:getGamelogPath()
  local gamelog = io.open(gamelog_path, "r")
  if gamelog then gamelog:close() return end

  local fi = self:writeToFileOrTmp(gamelog_path)
  local sysinfo = self:gamelogHeader()
  fi:write(sysinfo)
  fi:close()
end

--! Tries to initialize the user level and campaign directories
-- TODO: Integrate other directory initialisations into this function
function App:initUserDirectories()
  local conf_path = self.command_line["config-file"] or "config.txt"

  -- Attempt to set the user's directory choice
  -- param dir (path) The defined path of the folder by the user
  -- param label (string) What folder was being set if there was an error
  -- return The fully qualified path
  local function setUserDir(dir, label)
    dir = dir:sub(-1, -1) == pathsep and dir:sub(1, -2) or dir
    if lfs.attributes(dir, "mode") ~= "directory" and not lfs.mkdir(dir) then
      -- A failed directory creation does not result in a crash. But the user may lose
      -- the ability to load/save properly.
      print("Warning: " .. label .. " directory does not exist and could not be created.")
    end
    dir = dir:sub(-1, -1) ~= pathsep and dir .. pathsep or dir
    return dir
  end

  self.user_level_dir = self.config.levels or
      conf_path:match("^(.-)[^" .. pathsep .. "]*$") .. "Levels"
  self.user_level_dir = setUserDir(self.user_level_dir, "User Levels")
  self.user_campaign_dir = self.config.campaigns or
      conf_path:match("^(.-)[^" .. pathsep .. "]*$") .. "Campaigns"
  self.user_campaign_dir = setUserDir(self.user_campaign_dir, "User Campaigns")
end

--! Tries to initialize the savegame directory, returns true on success and
--! false on failure.
function App:initSavegameDir()
  local conf_path = self.command_line["config-file"] or "config.txt"
  self.savegame_dir = self.config.savegames or
      conf_path:match("^(.-)[^" .. pathsep .. "]*$") .. "Saves"

  if self.savegame_dir:sub(-1, -1) == pathsep then
    self.savegame_dir = self.savegame_dir:sub(1, -2)
  end
  if lfs.attributes(self.savegame_dir, "mode") ~= "directory" then
    if not lfs.mkdir(self.savegame_dir) then
      print("Notice: Savegame directory does not exist and could not be created.")
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
  self.screenshot_dir = self.config.screenshots or
      conf_path:match("^(.-)[^" .. pathsep .. "]*$") .. "Screenshots"

  if self.screenshot_dir:sub(-1, -1) == pathsep then
    self.screenshot_dir = self.screenshot_dir:sub(1, -2)
  end
  if lfs.attributes(self.screenshot_dir, "mode") ~= "directory" then
    if not lfs.mkdir(self.screenshot_dir) then
      print("Notice: Screenshot directory does not exist and could not be created.")
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
    assert(_S.deprecated[sec] and _S.deprecated[sec][str],
      "_S(" .. sec .. ", " .. str .. ") does not exist!")

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

function App:worldExited()
  self.audio:clearCallbacks()
end

--! Initialise CorsixTH's main menu screen including relevant windows
--!param message (string) Something to display to the user
function App:loadMainMenu(message)
  if self.world then
    self:worldExited()
  end

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

  -- Reset the idle tick counter
  self:resetIdle()
end

--! Sets the mouse capture to the state set within
--! app.config.capture_mouse
function App:setCaptureMouse()
  self.video:setCaptureMouse(self.config.capture_mouse)
end

--! Loads the first level of the specified campaign and prepares the world
--! to be able to progress through that campaign.
--!param campaign_file (string) Name of a CorsixTH Campaign definition Lua file.
function App:loadCampaign(campaign_file)
  local campaign_info, level_info, errors, _

  campaign_info, errors = self:readCampaignFile(campaign_file)
  if not campaign_info then
    self.ui:addWindow(UIInformation(self.ui, { _S.errors.could_not_load_campaign:format(errors) }))
    return
  end

  level_info, errors = self:readLevelFile(campaign_info.levels[1])
  if not level_info then
    self.ui:addWindow(UIInformation(self.ui, { _S.errors.could_not_find_first_campaign_level:format(errors) }))
    return
  end

  _, errors = self:readMapDataFile(level_info.map_file)
  if errors then
    self.ui:addWindow(UIInformation(self.ui, { errors }))
    return
  end

  -- Use localised description and winning text, if available
  campaign_info.description = self.strings:getLocalisedText(campaign_info.description,
      campaign_info.description_table)
  campaign_info.winning_text = self.strings:getLocalisedText(campaign_info.winning_text,
      campaign_info.winning_text_table)

  if self:loadLevel(campaign_info.levels[1], nil, level_info.name,
      level_info.map_file, level_info.briefing, nil, _S.errors.load_level_prefix) then
    -- The new world needs to know which campaign to continue on.
    self.world.campaign_info = campaign_info
  end

  -- Play the level advance movie from a position where this campaign will end at 12
  if campaign_info.movie then
    local n = math.max(1, 12 - #campaign_info.levels)
    self.moviePlayer:playAdvanceMovie(n)
  end
end

--! Reads the given file name as a Lua chunk from the Campaigns folder in the CorsixTH install directory.
--! A correct campaign definition contains "name", "description", "levels", and "winning_text".
--!param campaign_file (string) Name of the file to read.
--!return (table) Definitions found in the campaign file.
function App:readCampaignFile(campaign_file)
  local path = self:getFullPath({"Campaigns", campaign_file})
  local chunk, err = loadfile_envcall(path)
  if not chunk then
    return nil, "Error loading " .. path .. ":\n" .. tostring(err)
  else
    local result = {}
    chunk(result)
    return result
  end
end

--! Opens the given file name and returns all Level definitions in a table.
--! Values in the returned table: "path", "level_file", "name", "map_file", "briefing", and "end_praise".
--!param level (string) Name of the file to read.
--!return (table) Level info found in the file.
function App:readLevelFile(level)
  local filename = self:getAbsolutePathToLevelFile(level)
  local file, err = io.open(filename and filename or "")
  if not file then
    return nil, "Could not open the specified level file (" .. level .. "): " .. err
  end
  local contents = file:read("*all")
  file:close()

  local level_info = {}
  level_info.path = filename
  level_info.level_file = level
  level_info.name = contents:match("%Name ?= ?\"(.-)\"") or "Unknown name"
  level_info.map_file = contents:match("%MapFile ?= ?\"(.-)\"")
  if not level_info.map_file then
    -- The old way of defining the Map File has been deprecated, but a warning is enough.
    level_info.map_file = contents:match("%LevelFile ?= ?\"(.-)\"")
    if level_info.map_file then
      print("\nWarning: The level '" .. level_info.name .. "' contains a deprecated variable definition in the level file." ..
        "'%LevelFile' has been renamed to '%MapFile'. Please advise the map creator to update the level.\n")
    end
    level_info.deprecated_variable_used = true
  end

  -- Pick a localised set of briefings, if available
  local lang_code = self.strings:getLangCode()
  local local_briefing = contents:match("%LevelBriefingTable%." .. lang_code .. " ?= ?\"(.-)\"")
  local en_briefing = contents:match("%LevelBriefingTable%.en ?= ?\"(.-)\"")
  local standard_briefing = contents:match("%LevelBriefing ?= ?\"(.-)\"")
  level_info.briefing = local_briefing or en_briefing or standard_briefing

  local local_end_praise = contents:match("%LevelDebriefingTable%." .. lang_code .. " ?= ?\"(.-)\"")
  local en_end_praise = contents:match("%LevelDebriefingTable%.en ?= ?\"(.-)\"")
  local standard_end_praise = contents:match("%LevelDebriefing ?= ?\"(.-)\"")
  level_info.end_praise = local_end_praise or en_end_praise or standard_end_praise
  return level_info
end

--! Searches for the given level file in the "Campaigns" and "Levels" folder of the
--! CorsixTH install directory.
--!param level (string) Filename to search for.
--!return (string, error) Returns the found absolute path, or nil if not found. Then
--!       a second variable is returned with an error message.
function App:getAbsolutePathToLevelFile(level)
  local paths_to_search = {
    self.user_campaign_dir,
    self.user_level_dir,
    self.campaign_dir,
    self.level_dir,
  }
  for _, parent_path in ipairs(paths_to_search) do
    local check_path = parent_path .. pathsep .. level
    local file, _ = io.open(check_path, "rb")
    if file then
      file:close()
      return check_path
    end
  end
  return nil, "Level not found: " .. level
end

--! Invokes a protected call of App:_loadLevel(...). See that function for more information.
--! This function should always be called to catch errors and properly pass the
--! error to the player
--!param error_prefix (string) (Optional) Prefixes the error relevant to what was loaded
--! return (boolean) The outcome of the pcall
function App:loadLevel(level, difficulty, level_name, level_file, level_intro, map_editor, error_prefix)
  local status, err = pcall(self._loadLevel, self, level, difficulty, level_name,
      level_file, level_intro, map_editor)
  if not status then
    err = error_prefix and error_prefix .. err or "Error while loading level: " .. err
    print(err)
    self:loadMainMenu() -- We need to unload all level elements that succeeded
    self.ui:addWindow(UIInformation(self.ui, { err }))
  end
  return status
end

--! Private Function to load the level. Call via App:loadLevel(...)
--! Loads the specified level. If a string is passed it looks for the file with the same name
-- in the "Levels" folder of CorsixTH, if it is a number it tries to load that level from
-- the original game.
function App:_loadLevel(level, difficulty, level_name, level_file, level_intro, map_editor)
  if self.world then
    self:worldExited()
  end

  -- Check that we can load the data before unloading current map
  local new_map = Map(self)
  local map_objects, errors = new_map:load(level, difficulty, level_name, level_file, level_intro, map_editor)
  if not map_objects then
    self.world.ui:addWindow(UIInformation(self.ui, { errors }))
    return
  end
  -- If going from another level, save progress.
  local campaign_data = self.world and self.world:getCampaignData()

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

  -- Enable / disable SoundEffects
  self.audio:playSoundEffects(self.config.play_sounds)

  -- Load UI
  self.ui = GameUI(self, self.world:getLocalPlayerHospital(), map_editor)
  self.world:setUI(self.ui) -- Function call allows world to set up its keyHandlers

  -- Now restore progress from previous levels.
  if campaign_data then
    self.world:setCampaignData(campaign_data)
  end

  -- Log if we're playing with the demo or full graphics set
  -- TODO: Adjust for new_gfx set when implemented
  self.world.gfx_set = self.using_demo_files and "demo" or "full"
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
  local fi = assert(io.open(dir .. "debug-strings-orig.txt", "w"))
  for i, sec in ipairs(_S.deprecated) do
    for j, str in ipairs(sec) do
      fi:write("[" .. i .. "," .. j .. "] " .. ("%q\n"):format(val(str)))
    end
    fi:write("\n")
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

  fi = assert(io.open(dir .. "debug-strings-new-lines.txt", "w"))
  dump_by_line(fi, _S, "")
  fi:close()

  fi = assert(io.open(dir .. "debug-strings-new-grouped.txt", "w"))
  dump_grouped(fi, _S, "")
  fi:close()

  self:checkMissingStringsInLanguage(dir, self.config.language)
  -- Uncomment these lines to get diffs for all languages in the game
  -- for _, lang in pairs(self.strings.languages_english) do
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
    for _, lang_eng in pairs(self.strings.languages_english) do
      if ltc[language] == ltc[lang_eng:lower()] then
        language_english = lang_eng
        break
      end
    end

    local fi = assert(io.open(dir .. "debug-strings-diff-" .. language_english:lower() .. ".txt", "w"))
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
  -- Fill in default values for things which don't exist
  local config_defaults = select(3, corsixth.require("config_finder"))
  for k, v in pairs(config_defaults) do
    if self.config[k] == nil then
      self.config[k] = v
    end
  end

  for key, value in pairs(self.config) do
    -- Trim whitespace from beginning and end string values - it shouldn't be
    -- there (at least in any current configuration options).
    if type(value) == "string" then
      if value:match("^[%s]") or value:match("[%s]$") then
        self.config[key] = value:match("^[%s]*(.-)[%s]*$")
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

    if (key == "scroll_speed" or key == "shift_scroll_speed") and
        type(value) == "number" then
      if value > 10 then
        self.config[key] = 10
      elseif value < 1 then
        self.config[key] = 1
      end
    end
  end
end

function App:saveConfig()
  -- Load lines from config file
  local config_file = self.command_line["config-file"] or "config.txt"
  local fi = io.open(config_file, "r")
  local lines = {}
  local handled_ids = {}
  if fi then
    for line in fi:lines() do
      lines[#lines + 1] = line
      if not (string.find(line, "^%s*$") or string.find(line, "^%s*%-%-")) then -- empty lines or comments
        -- Look for identifiers we want to save
        local _, _, identifier, value = string.find(line, "^%s*([_%a][_%w]*)%s*=%s*(.-)%s*$")
        if identifier then
          local _, temp
          -- Trim possible trailing comment from value
          _, _, temp = string.find(value, "^(.-)%s*%-%-.*")
          value = temp or value
          -- Remove enclosing [[]], if necessary
          _, _, temp = string.find(value, "^%[%[(.*)%]%]$")
          value = temp or value

          -- If identifier also exists in runtime options, compare their values and
          -- replace the line, if needed
          handled_ids[identifier] = true
          if value ~= tostring(self.config[identifier]) then
            lines[#lines] = string.format("%s = %s", identifier,
                serialize(self.config[identifier], { long_bracket_level_start = 1 } ))
          end
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

  fi = self:writeToFileOrTmp(config_file)
  for _, line in ipairs(lines) do
    fi:write(line .. "\n")
  end
  fi:close()
end

--! Tries to open the given file or a file in OS's temp dir.
-- Returns the file handler
--!param file The full path of the intended file
--!param mode The mode in which the file is opened, defaults to write
function App:writeToFileOrTmp(file, mode)
  local f, err = io.open(file, mode or "w")
  if err then
    local tmp_file = os.tmpname()
    f = io.open(tmp_file, mode or "w")
    if self.ui then self.ui:addWindow(UIInformation(self.ui,
        { _S.errors.save_to_tmp:format(file, tmp_file, err) }))
    else
      print("Attempt to write to " .. file .. " failed. File was written instead to temporary location " .. tmp_file .. " because of the error: " .. err)
    end
  end
  assert(f, "Error: cannot write to filesystem")
  return f
end

function App:fixHotkeys()
  -- Fill in default values for things which don't exist
  local hotkeys_defaults = select(6, corsixth.require("config_finder"))

  for k, v in pairs(hotkeys_defaults) do
    if self.hotkeys[k] == nil then
      self.hotkeys[k] = v
    end
  end

  for key, value in pairs(self.hotkeys) do
    -- Trim whitespace from beginning and end string values - it shouldn't be
    -- there (at least in any current configuration options).
    if type(value) == "string" then
      if value:match("^[%s]") or value:match("[%s]$") then
        self.hotkeys[key] = value:match("^[%s]*(.-)[%s]*$")
      end
    end
  end
end

function App:saveHotkeys()
  -- Load lines from config file
  local hotkeys_filename = self.command_line["hotkeys-file"] or "hotkeys.txt"
  local fi = io.open(hotkeys_filename, "r")
  local lines = {}
  local handled_ids = {}

  if fi then
    for line in fi:lines() do
      lines[#lines + 1] = line
      if not (string.find(line, "^%s*$") or string.find(line, "^%s*%-%-")) then -- empty lines or comments
        -- Look for identifiers we want to save
        local _, _, identifier, value = string.find(line, "^%s*([_%a][_%w]*)%s*=%s*(.-)%s*$")
        if identifier then
          local _, temp
          -- Trim possible trailing comment from value
          _, _, temp = string.find(value, "^(.-)%s*%-%-.*")
          value = temp or value
          -- Remove enclosing [[]], if necessary
          _, _, temp = string.find(value, "^%[%[(.*)%]%]$")
          value = temp or value

          -- If identifier also exists in runtime options, compare their values and
          -- replace the line, if needed
          handled_ids[identifier] = true

          if value ~= serialize(self.hotkeys[identifier]) then
            local new_value = self.hotkeys[identifier]
            if type(new_value) == "string" then
              new_value = string.format("[[%s]]", new_value)
            else
              new_value = serialize(new_value)
            end
            lines[#lines] = string.format("%s = %s", identifier, new_value)
          end
        end
      end
    end
    fi:close()
  end

  -- Append options that were not found
  for identifier, value in pairs(self.hotkeys) do
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

  fi = self:writeToFileOrTmp(hotkeys_filename)
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
  local co = coroutine.create(function(app)
    local yield = coroutine.yield
    local dispatch = app.dispatch
    local repaint = true
    while app.running do
      repaint = dispatch(app, yield(repaint))
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
  self.video:setCaptureMouse(false) -- Free the mouse, so the user can eg close the window.
  if e ~= nil then
    if where then
      -- Errors from an asynchronous callback done on the dispatcher coroutine
      -- will end up here. As the error didn't originate from a dispatched
      -- event, self.last_dispatch_type is wrong. Therefore, an extra value is
      -- returned from mainloop(), meaning that where == "callback".
      self.last_dispatch_type = where
    end
    print("An error has occurred!")
    print("Almost anything can be the cause, but the detailed information " ..
      "below can help the developers find the source of the error.")
    print("Running: The " .. self.last_dispatch_type .. " handler.")
    print("A stack trace is included below, and the handler has been disconnected.")
    print(debug.traceback(co, e, 0))
    print("")
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
      self.ui:addWindow(UIConfirmDialog(self.ui, true,
        "Sorry, but an error has occurred. There can be many reasons - see the " ..
        "log window for details. Would you like to attempt a recovery?",
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
  if (not self.moviePlayer.playing) then
    if self.world then
      self.world:onTick(...)
    end
    self.ui:onTick(...)
  end
  return true -- tick events always result in a repaint
end

--! Function for handling idle time in the main menu, which leads to playing the
--! demo gameplay trailer if left long enough
function App:idle()
  if not self.config.play_demo then return end
  -- Check if we are in a proper 'idle' state and solely on the main menu
  if not self.ui:getWindowActiveStatus() or not self.ui:getWindow(UIMainMenu) or
      self.ui:getWindow(UIUpdate) or self.ui:getWindow(UIConfirmDialog) then
    self:resetIdle()
    return
  end
  -- Have we been idle enough (~30s)
  if self.idle_tick > 1000 then
    -- User is idle, play the demo gameplay movie
    self.moviePlayer:playDemoMovie()
    self:resetIdle()
  else
    self.idle_tick = self.idle_tick + 1
  end
end

-- Reset the idle count
function App:resetIdle()
  self.idle_tick = 0
end

local fps_history = {} -- Used to average FPS over the last thirty frames
for i = 1, 30 do fps_history[i] = 0 end
local fps_sum = 0 -- Sum of fps_history array
local fps_next = 1 -- Used to loop through fps_history when [over]writing

function App:drawFrame()
  self.video:startFrame()
  if (self.moviePlayer.playing) then
    self.key_modifiers = {}
    self.moviePlayer:refresh()
  else
    self.key_modifiers = SDL.getKeyModifiers()
    self.ui:draw(self.video)
  end
  self.video:endFrame()

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

function App:onEditingText(...)
  return self.ui:onEditingText(...)
end

function App:onTextInput(...)
  return self.ui:onTextInput(...)
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

function App:onMouseWheel(...)
  return self.ui:onMouseWheel(...)
end

function App:onWindowActive(...)
  return self.ui:onWindowActive(...)
end

--! Window has been resized by the user
--! Call the UI to handle the new window size
function App:onWindowResize(...)
  return self.ui:onWindowResize(...)
end

function App:onMusicOver(...)
  return self.audio:onMusicOver(...)
end

function App:onMovieOver(...)
  self.moviePlayer:onMovieOver(...)
end

function App:onSoundOver(...)
  return self.audio:onSoundPlayed(...)
end

function App:onMultiGesture(...)
  return self.ui:onMultiGesture(...)
end

function App:isThemeHospitalPath(path)
  local ngot = 0
  for obj, _ in lfs.dir(path) do
    for _, thing in ipairs({ "data", "levels", "qdata" }) do
      if obj:lower() == thing and
          lfs.attributes(path .. pathsep .. obj, "mode") == "directory" then
        ngot = ngot + 1
      end
    end
  end
  if ngot == 3 then
    return true
  end
end

function App:checkInstallFolder()
  self.fs = FileSystem()
  local status, _
  if self.config.theme_hospital_install then
    status, _ = self.fs:setRoot(self.config.theme_hospital_install)
  end
  local message = "Please make sure that you point the game to" ..
      " a valid copy of the data files from the original game," ..
      " as said files are required for graphics and sounds."
  if not status then
    -- Table of predictable places. First three are platform independent,
    -- then macOS app and its parent folder, GOG bundle,
    -- then linux Filesystem Hierarchy Standard, then Windows Program Files
    -- mac_app_dir is the macOS app base directory named CorsixTH.app
    local mac_app_dir = debug.getinfo(1).short_src:match("(.*)/Contents/.")
    local user_dir = os.getenv("HOME") or os.getenv("USERPROFILE")
    local win_home_dir = nil;
    if os.getenv("HOMEDRIVE") and os.getenv("HOMEPATH") then
      win_home_dir = os.getenv("HOMEDRIVE") .. os.getenv("HOMEPATH")
      if win_home_dir == user_dir then win_home_dir = nil; end
    end
    local possible_locations = {
      user_dir,
      user_dir and (user_dir .. pathsep .. "Documents"),
      win_home_dir,
      select(1, corsixth.require("config_finder")):match("(.*[/\\])"):sub(1, -2),
      mac_app_dir,
      mac_app_dir and mac_app_dir:match("(.*)/.*%.app"),
      "/Applications/Theme Hospital.app/Contents/Resources/game/Theme Hospital.app/" ..
          "Contents/Resources/Theme Hospital.boxer/C.harddisk",
      "/usr/share/games/corsix-th",
      "/usr/local/share/games/corsix-th",
      os.getenv("ProgramFiles"),
      os.getenv("ProgramFiles(x86)"),
      [[C:]], [[D:]], [[E:]], [[F:]], [[G:]], [[H:]] }
    local possible_folders = { "ThemeHospital", "Theme Hospital", "HOSP", "TH97",
      [[GOG Galaxy\Games\Theme Hospital]], [[GOG.com\Theme Hospital]],
      [[GOG Games\Theme Hospital]], [[Origin Games\Theme Hospital\data\Game]],
      [[EA Games\Theme Hospital\data\Game]]
    }
    for _, dir in pairs(possible_locations) do
      if status then break end
      for _, folder in pairs(possible_folders) do
        local path = dir .. pathsep .. folder
        if lfs.attributes(path, "mode") == "directory" and self:isThemeHospitalPath(path) then
          print("Game data found at: " .. path)
          print("This will be written to the config file")
          self.config.theme_hospital_install = path
          status, _ = self.fs:setRoot(path)
          break
        end
      end
    end
    if not status then
      -- If the given directory didn't exist, then likely the config file hasn't
      -- been changed at all from the default, and we looked unsuccessfully in
      -- some likely folders for the game data, so we continue to initialise the
      -- app, and give the user a dialog asking for the correct directory.
      return false
    end
  end

  -- Check that a few core files are present
  local missing = {}
  local function check(path)
    if not self.fs:readContents(path) then
      missing[#missing + 1] = path
    end
  end

  check("Data" .. pathsep .. "VBlk-0.tab")
  check("Levels" .. pathsep .. "Level.L1")
  check("QData" .. pathsep .. "SPointer.dat")
  if #missing ~= 0 then
    missing = table.concat(missing, ", ")
    message = "Invalid Theme Hospital folder specified in config file, " ..
        "as at least the following files are missing: " .. missing .. ".\n" ..
        message
    print(message)
    print("Trying to let the user select a new one.")
    return false, { message }
  end

  -- Check for demo version
  if self.fs:readContents("DataM", "Demo.dat") then
    self.using_demo_files = true
    print("Notice: Using data files from demo version of Theme Hospital.")
    print("Consider purchasing a full copy of the game to support EA.")
  end

  -- Do a few more checks to make sure that commonly corrupted files are OK.
  local corrupt = {}

  -- Check for file corruption for local files.
  -- No check is done if the game is loaded from an ISO
  local function check_corrupt(path, correct_size)
    -- If the file exists but is smaller than usual it is probably corrupt
    if self.fs:fileExists(path) then
      local real_size = self.fs:fileSize(path)
      if real_size + 1024 < correct_size or real_size - 1024 > correct_size then
        corrupt[#corrupt + 1] = path .. " (Size: " .. math.floor(real_size / 1024) .. " kB / Correct: about " .. math.floor(correct_size / 1024) .. " kB)"
      end
    else
      corrupt[#corrupt + 1] = path .. " (This file is missing)"
    end
  end

  if self.using_demo_files then
    check_corrupt("ANIMS" .. pathsep .. "WINLEVEL.SMK", 243188)
    check_corrupt("LEVELS" .. pathsep .. "LEVEL.L1", 163948)
    check_corrupt("DATA" .. pathsep .. "BUTTON01.DAT", 252811)
  else
    check_corrupt("ANIMS" .. pathsep .. "AREA01V.SMK", 251572)
    check_corrupt("ANIMS" .. pathsep .. "WINGAME.SMK", 2066656)
    check_corrupt("ANIMS" .. pathsep .. "WINLEVEL.SMK", 335220)
    check_corrupt("INTRO" .. pathsep .. "INTRO.SM4", 33616520)
    check_corrupt("QDATA" .. pathsep .. "FONT00V.DAT", 1024)
    check_corrupt("ANIMS" .. pathsep .. "LOSE1.SMK", 1009728)
  end

  if #corrupt ~= 0 then
    table.insert(corrupt, 1, "There appears to be corrupt files in your Theme Hospital folder, " ..
      "so don't be surprised if CorsixTH crashes. At least the following files are wrong:")
    table.insert(corrupt, message)
  end

  return true, #corrupt ~= 0 and corrupt or nil
end

function App:findSoundFont()
  local data_dir = self:getFullPath()

  local possible_locations = {
    self.config.soundfont or false,
    data_dir .. "FluidR3_GM.sf2",
    data_dir .. "FluidR3.sf3",
    "/usr/share/soundfonts/default.sf2", -- default linux
    "/usr/share/sounds/sf2/FluidR3_GM.sf2", -- debian based
    "/usr/share/soundfonts/FluidR3_GM.sf2" -- archlinux and others
  }

  for _, sf_path in ipairs(possible_locations) do
    if sf_path and lfs.attributes(sf_path) then
      return sf_path
    end
  end

  return nil
end

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
  local data = file:read("*a")
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
    return self:readMapDataFile(filename)
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
function App:readMapDataFile(filename)
  -- First look in the original install directory, if not found there
  -- look in the CorsixTH directories "Levels" and "Campaigns".
  local data = self.fs:readContents("Levels" .. pathsep .. filename)
  if not data then
    local absolute_path = self:getAbsolutePathToLevelFile(filename)
    if absolute_path then
      local file = io.open(absolute_path, "rb")
      if file then
        data = file:read("*a")
        file:close()
      end
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
  if dir:sub(-1) ~= pathsep then dir = dir .. pathsep end
  local path = self:getFullPath({"Lua", dir}, true)
  local results = no_results and "" or (append_to or {})

  for file in lfs.dir(path) do
    if file:match("%.lua$") then
      local status, result = pcall(corsixth.require, dir .. file:sub(1, -5))
      if not status then
        print("Error loading " .. dir .. file .. ":\n" .. tostring(result))
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
              results[file:match("(.*)%.")] = result
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
-- a specific savegame version is from.
function App:getVersion(version)
  local ver = version or self.savegame_version

  -- Versioning format is major.minor.revision (required) Patch (optional)
  -- Old versions (<= 0.67) retain existing format
  -- All patch versions should be retained in this table (due to be replaced, see PR2518)
  if ver > 194 then
    return "Trunk"
  elseif ver > 180 then
    return "v0.68.0"
  elseif ver > 170 then
    return "v0.67"
  elseif ver > 156 then
    return "v0.66"
  elseif ver > 138 then
    return "v0.65"
  elseif ver > 134 then
    return "v0.64"
  elseif ver > 127 then
    return "v0.63"
  elseif ver > 122 then
    return "v0.62"
  elseif ver > 111 then
    return "v0.61"
  elseif ver > 105 then
    return "v0.60"
  elseif ver > 91 then
    return "0.50"
  elseif ver > 78 then
    return "0.40"
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
  return SaveGameFile(filename)
end

-- Omit the usual file extension so this file cannot be seen from the normal load and save screen and cannot be overwritten
function App:quickSave()
  local filename = "quicksave.qs"
  return SaveGameFile(self.savegame_dir .. filename)
end

function App:load(filepath)
  if self.world then
    self:worldExited()
  end
  return LoadGameFile(filepath)
end

function App:quickLoad()
  local filename = "quicksave.qs"
  if lfs.attributes(self.savegame_dir .. filename) then
    self:load(self.savegame_dir .. filename)
  else
    self:quickSave()
    self.ui:addWindow(UIInformation(self.ui, { _S.errors.load_quick_save }))
  end
end

--! Function to check the loaded game is compatible with the program
--!param save_version (num)
--!param gfx_set (string) What graphics set is used
--!return true if compatible, otherwise false
function App:checkCompatibility(save_version, gfx_set)
  local app_version = self.savegame_version
  local err

  -- First check the graphics set matches with the game files
  if (gfx_set == "demo" and not self.using_demo_files) then
    err = _S.errors.compatibility_error.demo_in_full
  elseif (gfx_set == "full" and self.using_demo_files) then
    err = _S.errors.compatibility_error.full_in_demo

    -- if that's all good, check the save and app version
  elseif app_version >= save_version or self.config.debug then
    return true
  else -- savegame newer than application
    err = _S.errors.compatibility_error.new_in_old
  end

  UILoadGame:loadError(err)
  return false
end

--! Restarts the current level (offers confirmation window first)
function App:restart()
  assert(self.map, "Trying to restart while no map is loaded.")
  self.ui:addWindow(UIConfirmDialog(self.ui, false, _S.confirmation.restart_level,
    --[[persistable:app_confirm_restart]] function()
    self:worldExited()
    local level = self.map.level_number
    local difficulty = self.map.difficulty
    local name, file, intro
    if not tonumber(level) then
      name = self.map.level_name
      file = self.map.map_file
      intro = self.map.level_intro
    end
    if level and name and not file then
      self.ui:addWindow(UIInformation(self.ui, { _S.information.cannot_restart }))
      return
    end
    self:loadLevel(level, difficulty, name, file, intro, nil, _S.errors.load_level_prefix)
  end))
end

--! Begin the map editor
function App:mapEdit()
  self:loadLevel("", nil, nil, nil, nil, true, _S.errors.load_map_prefix)
end

--! Exits the game completely (no confirmation window)
function App:exit()
  -- Save config before exiting
  self:saveConfig()
  self.running = false
end

--! Exits the game completely without saving the config i.e. Alt+F4 for Quit Application
function App:abandon()
  self.running = false
end

--! This function is automatically called after loading a game and serves for compatibility.
function App:afterLoad()
  self.ui:addOrRemoveDebugModeKeyHandlers()
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

  -- Generate the human-readable version number (old [loaded save], new [program], first [original])
  local first_version = first .. " (" .. self:getVersion(first) .. ")"
  local old_version = old .. " (" .. self:getVersion(old) .. ")"
  local new_version = new .. " (" .. self:getVersion() .. ")"

  if new == old then
    local msg_same = "Savegame version is %s, originally it was %s."
    self.world:gameLog(msg_same:format(new_version, first_version))
    self.world:playLoadedEntitySounds()
  elseif new > old then
    local msg_older = "Savegame changed from %s to %s. The save was created using %s."
    self.world:gameLog(msg_older:format(old_version, new_version, first_version))
  else -- Save is newer than the game and can only proceed in debug mode
    local get_old_release_version = self.world.release_version or "Trunk" -- For compatibility
    old_version = old .. " (" .. get_old_release_version .. ")"
    local msg_newer = "Warning: loaded savegame version %s in older version %s."
    self.world:gameLog(msg_newer:format(old_version, new_version))
    self.ui:addWindow(UIInformation(self.ui, { _S.warnings.newersave }))
  end
  self.world.release_version = self:getVersion()
  self.world.savegame_version = new

  if old < 87 then
    local new_object = corsixth.require("objects.gates_to_hell")
    Object.processTypeDefinition(new_object)
    self.objects[new_object.id] = new_object
    self.world:newObjectType(new_object)
  end

  if old < 114 then
    local rathole_type = corsixth.require("objects.rathole")
    Object.processTypeDefinition(rathole_type)
    self.objects[rathole_type.id] = rathole_type
    self.world:newObjectType(rathole_type)
  end

  --[[Information only:
  if old < 166 then
    Graphics set type was introduced at this version.
    Nothing to do here as it is handled by persistance.
    However, it introduces compatibility limitations between the demo and full game
    and should be noted.
  end
  ]] --

  self.map:afterLoad(old, new)
  self.ui:afterLoad(old, new)
  self.world:afterLoad(old, new)
end

--! Runs a comparison between the current (installed) version and the reported
--! update table hosted by Github. If the update table is newer, it will generate
--! an update window.
--! As pre-releases are not announced on the update table, the checker also assumes
--! that any current version with a patch in its name (Beta, RC, etc) will be older
--! than the update table's version if their major, minor, and revision components match.
function App:checkForUpdates()
  -- Only check for updates once per application launch
  if not self.check_for_updates or not self.config.check_for_updates then return end
  self.check_for_updates = false

  -- Default language to use for the changelog if no localised version is available
  local default_language = "en"
  local current_version = self:getVersion()

  -- Only check for updates against released versions
  if current_version == "Trunk" then
    print("Will not check for updates since this is the Trunk version.")
    return
  end

  print("Checking for CorsixTH updates...")
  local update_body, err = TH.FetchLatestVersionInfo()

  if not update_body then
    print("Couldn't check for updates: " .. err)
    return
  end

  local update_table = loadstring_envcall(update_body, "@updatechecker") {}
  update_table.revision = update_table.revision or 0
  local changelog = update_table["changelog_" .. default_language]
  local new_version = update_table.major .. '.' .. update_table.minor .. '.' .. update_table.revision

  -- Semantic version comparison of the current and update version numbers
  -- A return value of true means the current version is newer
  local function compare_versions()
    local current_major, current_minor, current_revision, current_patch =
        string.match(current_version, "(%d+)%.(%d+)%.?(%d*) ?(.*)")
    current_major, current_minor = tonumber(current_major), tonumber(current_minor)
    if current_major > update_table.major then return true
    elseif current_major < update_table.major then return false
    end
    if current_minor > update_table.minor then return true
    elseif current_minor < update_table.minor then return false
    end

    current_revision = tonumber(current_revision) or 0
    current_patch = string.len(current_patch) > 0 and current_patch
    if current_patch then return current_revision > update_table.revision end
    return current_revision >= update_table.revision
  end
  if compare_versions() then
    print("You are running the latest version of CorsixTH.")
    return
  end

  -- Check to make sure download URL is trusted
  local download_url = update_table.download_url
  local trusted_url = false
  local trusted_prefixes = { 'https://corsixth.com/', 'https://github.com/', 'https://corsixth.github.io/' }

  for _, v in ipairs(trusted_prefixes) do
    if download_url:sub(1, #v) == v then
      trusted_url = true
      break
    end
  end
  if not trusted_url then
    print("Update download url is not on the trusted domains list (" .. download_url .. ")")
    return
  end

  -- Check to see if there's a changelog in the user's language
  local current_langs = self.strings:getLanguageNames(self.config.language)
  for _, v in ipairs(current_langs) do
    if (update_table["changelog_" .. v]) then
      changelog = update_table["changelog_" .. v]
      break
    end
  end

  print("New version found: " .. new_version)
  -- Display the update window
  self.ui:addWindow(UIUpdate(self.ui, current_version, new_version, changelog, download_url))
end

-- Free up / stop any resources relying on the current video object
function App:prepareVideoUpdate()
  self.video:endFrame()
  self.moviePlayer:deallocatePictureBuffer()
end

-- Update / start any resources relying on a video object
function App:finishVideoUpdate()
  self.gfx:updateTarget(self.video)
  self.moviePlayer:updateRenderer()
  self.moviePlayer:allocatePictureBuffer()
  self.video:startFrame()
end

function App:isAudioEnabled()
  return TH.GetCompileOptions().audio
end

function App:isUpdateCheckDisabledByConfig()
  return TH.GetCompileOptions().update_check and not self.config.check_for_updates
end

function App:isUpdateCheckAvailable()
  return TH.GetCompileOptions().update_check
end

--! Generate information about user's system and the program
--!return System and program info as a string
function App:gamelogHeader()
  local gen_date = os.date("%Y-%m-%d %H:%M:%S")
  gen_date = string.format("Gamelog generated on %s\n", gen_date)
  local compile_opts = TH.GetCompileOptions()
  local comp_details = {}
  for key, value in pairs(compile_opts) do
    table.insert(comp_details, key .. ": " .. tostring(value))
  end
  table.sort(comp_details)
  local compiled = string.format("Compiled with %s\nSDL renderer: %s\n",
      table.concat(comp_details, ", "), self.video:getRendererDetails())
  local running = string.format("%s run with api version: %s, game version: %s, savegame version: %s\n",
      compile_opts.jit or _VERSION, tostring(corsixth.require("api_version")),
      self:getVersion(), tostring(SAVEGAME_VERSION))
  return (gen_date .. compiled .. running)
end

-- Do not remove, for savegame compatibility < r1891
local app_confirm_quit_stub = --[[persistable:app_confirm_quit]] function()
end
