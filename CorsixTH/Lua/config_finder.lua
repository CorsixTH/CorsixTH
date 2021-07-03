--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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

local config_path, config_name
local pathsep = package.config:sub(1, 1)
local ourpath = debug.getinfo(1, "S").source:sub(2, -22)
local function pathconcat(a, b)
  if a:sub(-1) == pathsep then
    return a .. b
  else
    return a .. pathsep .. b
  end
end

-- Decide on a sensible place to put config.txt, etc.
if pathsep == "\\" then
  -- Windows
  config_path = os.getenv("AppData") or ourpath
else
  -- Linux, OS X, etc.
  config_path = os.getenv("XDG_CONFIG_HOME") or pathconcat(os.getenv("HOME") or "~", ".config")
end
if config_path ~= ourpath then
  config_path = pathconcat(config_path, "CorsixTH")
end

-- Config filename.
config_name = "config.txt"

-- Check for config.path.txt
local fi = io.open(pathconcat(ourpath, "config.path.txt"), "r")
if fi then
  local contents = fi:read"*a"
  contents = contents:match("^%s*(.-)%s*$")
  fi:close()
  if #contents ~= 0 then
    config_path = contents
    if config_path:sub(-4, -1):lower() == ".txt" then
      config_name = config_path:match("([^" .. pathsep .. "]*)$")
      config_path = config_path:sub(1, -1-#config_name)
    end
  end
end

-- Check / create config_path
local lfs = require("lfs")
local function check_dir_exists(path)
  if path:sub(-1) == pathsep then
    path = path:sub(1, -2)
  end
  if lfs.attributes(path, "mode") == "directory" then
    return true
  else
    local subpath = path:match("^(.*)[" .. pathsep .. "]")
    if subpath then
      return check_dir_exists(subpath) and lfs.mkdir(path)
    else
      return false
    end
  end
end
if not check_dir_exists(config_path) then
  config_path = ourpath
end

-- Config file with full path as string.
local config_filename = pathconcat(config_path, config_name)

-- Create config.txt if it doesn't exist
local config_defaults = {
  -- This directory is deliberately obscure so that it doesn't exist by default
  --[[ NOTE to developers
  When adding new fields, please try and keep the end results user friendly
  They are all grouped into the places they can be changed in game and then into a group
 that can only be changed here.  Currently the player name is at the bottom of the list for the config
  as it this is where it always ends up when the file is recreated.
  for ease of reference I have also ordered the fields into the same order]]
  fullscreen = false,
  width = 800,
  height = 600,
  language = [[English]],
  audio = true,
  free_build_mode = false,
  play_sounds = true,
  sound_volume = 0.5,
  play_announcements = true,
  announcement_volume = 0.5,
  play_music = true,
  music_volume = 0.5,
  prevent_edge_scrolling = false,
  capture_mouse = true,
  adviser_disabled = false,
  scrolling_momentum = 0.8,
  twentyfour_hour_clock = true,
  warmth_colors_display_default = 1,
  grant_wage_increase = false,
  movies = true,
  play_intro = true,
  allow_user_actions_while_paused = false,
  volume_opens_casebook = false,
  alien_dna_only_by_emergency = true,
  alien_dna_must_stand = true,
  alien_dna_can_knock_on_doors = false,
  disable_fractured_bones_females = true,
  enable_avg_contents = false,
  remove_destroyed_rooms = false,
  audio_frequency = 22050,
  audio_channels = 2,
  audio_buffer_size = 2048,
  theme_hospital_install = [[F:\ThemeHospital\hospital]],
  debug = false,
  DBGp_client_idehost = nil,
  DBGp_client_ideport = nil,
  DBGp_client_idekey = nil,
  DBGp_client_transport = nil,
  DBGp_client_platform = nil,
  DBGp_client_workingdir = nil,
  track_fps = false,
  zoom_speed = 80,
  scroll_speed = 2,
  shift_scroll_speed = 4,
  new_graphics_folder = nil,
  use_new_graphics = false,
  check_for_updates = true,
  room_information_dialogs = true,
  allow_blocking_off_areas = false,
  direct_zoom = nil
}

fi = io.open(config_filename, "r")
local config_values = {}
local needs_rewrite = false
for key, value in pairs(config_defaults) do
  config_values[key] = value
end

if fi then
  -- Read all the values from the config file and put them in config_values. If at least one value is missing rewrite the configuration file.
  local file_contents = fi:read("*all")
  fi:close()
  for key, value in pairs(config_defaults) do
    local ind = string.find(file_contents, "\n" .. "%s*" .. key .. "%s*=")
    if not ind then
      needs_rewrite = true
    else
      ind = ind + (string.find(file_contents, key, ind) - ind) + string.len(key)
      ind = string.find(file_contents, "=", ind) + 1
      if type(value) ~= "string" then
        ind = string.find(file_contents, "[%a%d]", ind)
        config_values[key] = string.sub(file_contents, ind, string.find(file_contents, "[ \n-]", ind + 1) - 1)
      else
        ind = string.find(file_contents, "[", ind + 1, true) + 1
        config_values[key] = string.sub(file_contents, ind + 1, string.find(file_contents, "]", ind, true) - 1)
      end
    end
  end
else
  needs_rewrite = true
end

if needs_rewrite then
  local string_01 = [=[
----------------------------------------- CorsixTH configuration file -------------------------------------------
-- Lines starting with two dashes (like this one) are ignored.
-- Text settings should have their values between double square braces, e.g.
--  setting = [[value]]
-- Number settings should not have anything around their value,
-- e.g. setting = 42
--
--------------------------------------------  SETTINGS MENU ---------------------------------------------
-- These settings can also be changed from within the game from the settings menu
-------------------------------------------------------------------------------------------------------------------------
-- Screen size. Must be at least 640x480. Larger sizes will require better
-- hardware in order to maintain a playable framerate. The fullscreen setting
-- can be true or false, and the game will run windowed if not fullscreen.
--]=] .. '\n' ..
'fullscreen = ' .. tostring(config_values.fullscreen) .. '\n' ..
'\n' ..
'width = ' .. tostring(config_values.width) .. '\n' ..
'height = ' .. tostring(config_values.height) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Language to use for ingame text. Between the square braces should be one of:
--  Brazilian Portuguese  / pt_br / br
--  Chinese (simplified)  / zh(s) / chi(s)
--  Chinese (traditional) / zh(t) / chi(t)
--  Czech                 / cs / cze
--  Danish                / da / dk
--  Dutch                 / Nederlands / nl / dut / nld
--  English               / en / eng
--  Finnish               / Suomi / fi / fin
--  French                / fr / fre / fra
--  German                / de / ger / deu
--  Hungarian             / hu / hun
--  Italian               / it / ita
--  Korean                / kor / ko
--  Norwegian             / nb / nob
--  Polish                / pl / pol
--  Portuguese            / pt / por
--  Russian               / ru / rus
--  Spanish               / es / spa
--  Swedish               / sv / swe
--]=] .. '\n' ..
'language = [['.. config_values.language ..']]' .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Audio global on/off switch.
-- Note that audio will also be disabled if CorsixTH was compiled without the
-- SDL_mixer library.
--]=] .. '\n' ..
'audio = ' .. tostring(config_values.audio) .. '\n' .. [=[

--------------------------------------------- CUSTOM GAME MENU ----------------------------------------------
-- These settings can also be changed from the opening menu screen in the custom games menu
-------------------------------------------------------------------------------------------------------------------------
-- Free Build or Sandbox mode
-- You cannot win or lose custom made maps if this is set to true.
-- You also don't have to worry about money.
-- This setting does not apply to any of the campaign maps.
--]=] .. '\n' ..
'free_build_mode = ' .. tostring(config_values.free_build_mode) .. '\n' .. [=[

----------------------------------------------- OPTIONS MENU ---------------------------------------------------
--These settings can also be changed from within the game from the options menu
-------------------------------------------------------------------------------------------------------------------------
-- Sounds: By default enabled and set at level 0.5
--]=] .. '\n' ..
'play_sounds = ' .. tostring(config_values.play_sounds) .. '\n' ..
'sound_volume = ' .. tostring(config_values.sound_volume) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Announcements: By default set at level 0.5
--]=] .. '\n' ..
'play_announcements = ' .. tostring(config_values.play_announcements) .. '\n' ..
'announcement_volume = ' .. tostring(config_values.announcement_volume) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Background music: By default enabled and set at level 0.5
--]=] .. '\n' ..
'play_music = ' .. tostring(config_values.play_music) .. '\n' ..
'music_volume = ' .. tostring(config_values.music_volume) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Edge scrolling: By default enabled (prevent_edge_scrolling = false).
--]=] .. '\n' ..
'prevent_edge_scrolling = ' .. tostring(config_values.prevent_edge_scrolling) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Capture mouse: By default enabled (capture mouse = true).
--]=] .. '\n' ..
'capture_mouse = ' .. tostring(config_values.capture_mouse) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Adviser on/off: If you set this to true the adviser will no longer
-- pop up.
--]=] .. '\n' ..
'adviser_disabled = ' .. tostring(config_values.adviser_disabled) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Scrolling Momentum.
-- Determines the amount of momentum when scrolling the map with the mouse.
-- This should be a value between 0 and 1 where 0 is no momentum
--]=] .. '\n' ..
'scrolling_momentum = ' .. tostring(config_values.scrolling_momentum) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Top menu clock is by default is always on
-- setting to true will give you a twentyfour hours display
-- change to false if you want AM / PM time displayed.
--]=] .. '\n' ..
'twentyfour_hour_clock = ' .. tostring(config_values.twentyfour_hour_clock) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Automatically check for updates.
-- If set to true, CorsixTH will automatically check for and alert you to newer
-- versions on startup.
--]=] .. '\n' ..
'check_for_updates = ' .. tostring(config_values.check_for_updates) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Warmth Colors display settings.
-- This specifies which display method is set for warmth colours by default.
-- Possible values: 1 (Red), 2 (Blue Green Red) and 3 (Yellow Orange Red).
--]=] .. '\n' ..
'warmth_colors_display_default = ' .. tostring(config_values.warmth_colors_display_default) .. '\n' .. [=[

--------------------------------------------- CUSTOMISE SETTINGS --------------------------------------------
-- These settings can also be changed from the Customise Menu

-------------------------------------------------------------------------------
-- Wage increase request settings.
-- If set to true when wage increase requests expire automatically grant them
-- otherwise let the staff member quit.
--]=] .. '\n' ..
'grant_wage_increase = ' .. tostring(config_values.grant_wage_increase) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Movie global on/off switch.
-- Note that movies will also be disabled if CorsixTH was compiled without the
-- FFMPEG library.
--]=] .. '\n' ..
'movies = ' .. tostring(config_values.movies) .. '\n' .. [=[

-- Intro movie: By default enabled
--]=] .. '\n' ..
'play_intro = ' .. tostring(config_values.play_intro) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Allow user actions while game is paused
-- In Theme Hospital the player would only be allowed to use the top menu if
-- the game was paused. That is the default setting in CorsixTH too, but by
-- setting this to true everything is allowed while the game is paused.
--]=] .. '\n' ..
'allow_user_actions_while_paused = ' .. tostring(config_defaults.allow_user_actions_while_paused) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- VOLUME CONTROL IS OPENING THE DRUG CASEBOOK?

-- If your keyboard volume control opens the Drug Casebook at the same time
-- then change this to true.  From then on you will have to use Shift + C to open
-- the Casebook and volume down will not open it.
-- For example for shift + C to open casebook change the setting below to = true
--]=] .. '\n' ..
'volume_opens_casebook = ' .. tostring(config_values.volume_opens_casebook) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- To allow patients with Alien DNA to visit your hospital other than by an emergency change
-- the settings below.  Understand that there are no animations for sitting down, opening
-- or knocking on doors etc.
-- So, like with Theme Hospital to do these things they will appear to change to normal
-- looking and then change back.
--]=] .. '\n' ..
'alien_dna_only_by_emergency = ' .. tostring(config_values.alien_dna_only_by_emergency) .. '\n' ..
'alien_dna_must_stand = ' .. tostring(config_values.alien_dna_must_stand) .. '\n' ..
'alien_dna_can_knock_on_doors = ' .. tostring(config_values.alien_dna_can_knock_on_doors) .. '\n' .. [=[

-- To allow female patients with fractured bones, which are by default disabled due to poor
-- animation that skips and jumps a bit
--]=] .. '\n' ..
'disable_fractured_bones_females = ' .. tostring(config_values.disable_fractured_bones_females) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- By default the player selects any extra objects they want for each room they build.
-- If you would like the game to remember what you usually add, then change this option to true.
--]=] .. '\n' ..
'enable_avg_contents = ' .. tostring(config_values.enable_avg_contents) .. '\n' .. [=[

---------------------------------------------------------------------------------------------------
-- By default destroyed rooms can't be removed.
-- If you would like the game to give you the option of removing a destroyed room change this option to true.
--]=] .. '\n' ..
'remove_destroyed_rooms = ' .. tostring(config_values.remove_destroyed_rooms) .. '\n' .. [=[]=]

  local string_02 = [=[

----------------------------------------------- FOLDER SETTINGS ----------------------------------------------
-- These settings can also be changed from the Folders Menu
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-- Theme hospital install folder: original game data files are loaded from this
-- folder. Between the square braces should be the folder which contains the
-- original HOSPITAL.EXE and/or HOSP95.EXE file. This can point to a copy of
-- the Theme Hospital demo, though a full install of the original game is
-- preferred.
--]=] .. '\n' ..
'theme_hospital_install = [[' .. config_values.theme_hospital_install ..']]' .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Font file setting. Can be changed from main game menu
-- Specify a font file here if you wish to play the game in a language not
-- present in the original game. Examples include Russian, Chinese and Polish.
--
unicode_font = nil -- [[X:\ThemeHospital\font.ttc]]

-------------------------------------------------------------------------------------------------------------------------
-- Savegames. By default, the "Saves" directory alongside this config file will
-- be used for storing saved games in. Should this not be suitable, then
-- uncomment the following line, and point it to a directory which exists and
-- is more suitable.
--
savegames = nil -- [[X:\ThemeHospital\Saves]]

-------------------------------------------------------------------------------------------------------------------------
-- Levels. By default, the "Levels" directory alongside this config file will
-- be used for storing new maps / levels in. Should this not be suitable, then
-- uncomment the following line, and point it to a directory which exists and
-- is more suitable.
--
levels = nil -- [[X:\ThemeHospital\Levels]]

 ------------------------------------------------------------------------------------------------------------------------
-- Use new graphics. Whether to use the original graphics from Theme Hospital
-- or use new graphics created by the CorsixTH project.
use_new_graphics = false

-------------------------------------------------------------------------------------------------------------------------
-- Graphics folder. All graphics are initially taken from the original Theme Hospital,
-- but the game can also try to find new graphics in the specified folder below.
-- Some graphics are shipped with CorsixTH, and they will be used if you just switch
-- on new graphics. If you however have acquired graphics from somewhere else, then
-- uncomment the following line and point it to the directory which contains the new
-- graphics.
new_graphics_folder = nil -- [[X:\ThemeHospital\Graphics]]

-------------------------------------------------------------------------------------------------------------------------
-- Screenshots. By default, the "Screenshots" directory alongside this config
-- file will be used for saving screenshots. Should this not be suitable, then
-- uncomment the following line, and point it to a directory which exists and
-- is more suitable.
--
screenshots = nil -- [[X:\ThemeHospital\Screenshots]]

-------------------------------------------------------------------------------------------------------------------------
-- If you want to listen to non-Theme-Hospital music, then follow these steps:
--  1) Find updated versions of the original tracks (for example the remixes by ZR
--     from http://www.a-base.dds.nl/temp/ThemeHospital_ZRRemix.zip ) or any
--     other music you want to listen to.
--  2) Uncomment the next line and point it to where the music files are.
--  3) If you want to change the names of songs ingame, make a file called
--     "names.txt" and write the file name on one row, followed by the desired
--     ingame name on the next row.
--
audio_music = nil -- [[X:\ThemeHospital\Music]]

 ----------------------------------------------- SPECIAL SETTINGS ----------------------------------------------
-- These settings can only be changed here
-------------------------------------------------------------------------------------------------------------------------
-- Audio playback settings.
-- These can be commented out to use the default values from the game binary.
-- Note: On some platforms, these settings may not effect MIDI playback - only
-- sound effects and music audio. If you are experiencing poor audio playback,
-- then try doubling the buffer size.
--]=] .. '\n' ..
'audio_frequency = ' .. tostring(config_values.audio_frequency) .. '\n' ..
'audio_channels = ' .. tostring(config_values.audio_channels) .. '\n' ..
'audio_buffer_size = ' .. tostring(config_values.audio_buffer_size) .. '\n' .. [=[

 ------------------------------------------------------------------------------------------------------------------------

-- Debug settings.
-- If set to true more detailed information will be printed in the terminal
-- and a debug menu will be visible.
--]=] .. '\n' ..
'debug = ' .. tostring(config_values.debug) .. '\n' .. [=[

--Optional settings for CorsixTH's Lua DBGp client.
--Default settings are nil values, platform & workingdir will be autodected if nil.
--https://wiki.eclipse.org/LDT/User_Area/User_Guides/User_Guide_1.2#Attach_session
--]=] .. '\n' ..
'idehost = ' .. tostring(config_values.DBGp_client_idehost) .. '\n' ..
'ideport = ' .. tostring(config_values.DBGp_client_ideport) .. '\n' ..
'idekey = ' .. tostring(config_values.DBGp_client_idekey) .. '\n' ..
'transport = ' .. tostring(config_values.DBGp_client_transport) .. '\n' ..
'platform = ' .. tostring(config_values.DBGp_platform) .. '\n' ..
'workingdir = ' .. tostring(config_values.DBGp_workingdir) .. '\n' .. [=[

-- If set to true, the FPS, Lua memory usage, and entity count will be shown
-- in the dynamic information bar. Note that setting this to true also turns
-- off the FPS limiter, causing much higher CPU utilisation, but resulting in
-- more useful FPS values, as they are not artificially capped.
--]=] .. '\n' ..
'track_fps = ' .. tostring(config_values.track_fps) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Zoom Speed: By default this is set at 80
-- Any number value between 10 and 1000, 10 is very slow and 1000 is very fast!
--]=] .. '\n' ..
'zoom_speed = ' .. tostring(config_values.zoom_speed) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Scroll Speeds: The speed of scrolling with and without shift being held.
-- Any number value between 1 and 10, 1 is very slow and 10 is fast!
--]=] .. '\n' ..
'scroll_speed = ' .. tostring(config_values.scroll_speed) .. '\n' ..
'shift_scroll_speed = ' .. tostring(config_values.shift_scroll_speed) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Room information dialogs: Information about new rooms, important for
-- additional rooms in later levels. Affects campaign only.
--]=] .. '\n' ..
'room_information_dialogs = ' .. tostring(config_values.room_information_dialogs)  .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- If true, parts of the hospital can be made inaccessible by blocking the path
-- with rooms or objects. If false, all parts of the hospital must be kept
-- accessible, the game will disallow any attempt to blocking the path.
--]=] .. '\n' ..
'allow_blocking_off_areas = ' .. tostring(config_values.allow_blocking_off_areas) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Direct Zoom: An experimental enhancement to avoid rendering to an
-- intermediate texture when zooming. Improves performance and reliability on
-- some hardware.
--]=] .. '\n' ..
'direct_zoom = ' .. tostring(config_values.direct_zoom) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------

------------------------------------------------ CAMPAIGN MENU -----------------------------------------------
-- By default your computer log in will be your name in the game.  You can change it in the
-- campaign menu or between the brace brackets below [[YOUR NAME]].
-- Note: space is limited in the game, so don't enter a name that is too long!
--
-- If you have specified any other locations for things like saves, music or screenshots you will find these below.  If
-- you change your mind and wish to go back to the default folders, just delete the relevant line.
--
-- If you wish to go back to the default settings for everything, you can delete this text file and it will be re-created
-- you play the game.
-------------------------------------------------------------------------------------------------------------------------

]=]
  fi = TheApp:writeToFileOrTmp(config_filename)
  fi:write(string_01 .. string_02)
  fi:close()
end

-- Hotkey filename.
local hotkeys_name = "hotkeys.txt"

-- Hotkey file with full path as string.
local hotkeys_filename = pathconcat(config_path, hotkeys_name)

-- Defaults for hotkeys.
local hotkeys_defaults = {
  global_confirm = "return",
  global_confirm_alt = "e",
  global_cancel = "escape",
  global_cancel_alt = "q",
  global_fullscreen_toggle = {"alt", "return"},
  global_exitApp = {"alt", "f4"},
  global_resetApp = {"shift", "f10"},
  global_releaseMouse = {"ctrl", "f10"},
  global_connectDebugger = {"ctrl", "c"},
  global_showLuaConsole = "f12",
  global_runDebugScript = {"shift", "d"},
  global_screenshot = {"ctrl", "s"},
  global_stop_movie = "escape",
  global_stop_movie_alt = "q",
  global_window_close = "escape",
  global_window_close_alt = "q",
  ingame_showmenubar = "escape",
  ingame_showCheatWindow = "f11",
  ingame_pause = "p",
  ingame_gamespeed_slowest = "1",
  ingame_gamespeed_slower = "2",
  ingame_gamespeed_normal = "3",
  ingame_gamespeed_max = "4",
  ingame_gamespeed_thensome = "5",
  ingame_gamespeed_speedup = "z",
  ingame_scroll_up = "up",
  ingame_scroll_down = "down",
  ingame_scroll_left = "left",
  ingame_scroll_right = "right",
  ingame_scroll_shift = "shift",
  ingame_zoom_in = "=",
  ingame_zoom_in_more = {"shift", "="},
  ingame_zoom_out = "-",
  ingame_zoom_out_more = {"shift", "-"},
  ingame_reset_zoom = "0",
  ingame_setTransparent = "x",
  ingame_toggleAdvisor = {"shift", "a"},
  ingame_poopLog = {"ctrl", "d"},
  ingame_poopStrings = {"ctrl", "t"},
  ingame_toggleAnnouncements = {"alt", "a"},
  ingame_toggleSounds = {"alt", "s"},
  ingame_toggleMusic = {"alt", "m"},
  ingame_panel_bankManager = "f1",
  ingame_panel_bankStats = "f2",
  ingame_panel_staffManage = "f3",
  ingame_panel_townMap = "f4",
  ingame_panel_casebook = "f5",
  ingame_panel_research = "f6",
  ingame_panel_status = "f7",
  ingame_panel_charts = "f8",
  ingame_panel_policy = "f9",
  ingame_panel_map_alt = "t",
  ingame_panel_research_alt = "r",
  ingame_panel_casebook_alt = "c",
  ingame_panel_casebook_alt02 = {"shift", "c"},
  ingame_panel_buildRoom = "f",
  ingame_panel_furnishCorridor = "g",
  ingame_panel_editRoom = "v",
  ingame_panel_hireStaff = "b",
  ingame_loadMenu = {"shift", "l"},
  ingame_saveMenu = {"shift", "s"},
  ingame_restartLevel = {"shift", "r"},
  ingame_quitLevel = {"shift", "q"},
  ingame_quickSave = {"alt", "shift", "s"},
  ingame_quickLoad = {"alt", "shift", "l"},
  ingame_openFirstMessage = "m",
  ingame_toggleInfo = "i",
  ingame_jukebox = "j",
  ingame_rotateobject = "space",
  ingame_patient_gohome = "h",
  ingame_storePosition_1 = {"alt", "1"},
  ingame_storePosition_2 = {"alt", "2"},
  ingame_storePosition_3 = {"alt", "3"},
  ingame_storePosition_4 = {"alt", "4"},
  ingame_storePosition_5 = {"alt", "5"},
  ingame_storePosition_6 = {"alt", "6"},
  ingame_storePosition_7 = {"alt", "7"},
  ingame_storePosition_8 = {"alt", "8"},
  ingame_storePosition_9 = {"alt", "9"},
  ingame_storePosition_0 = {"alt", "0"},
  ingame_recallPosition_1 = {"ctrl", "1"},
  ingame_recallPosition_2 = {"ctrl", "2"},
  ingame_recallPosition_3 = {"ctrl", "3"},
  ingame_recallPosition_4 = {"ctrl", "4"},
  ingame_recallPosition_5 = {"ctrl", "5"},
  ingame_recallPosition_6 = {"ctrl", "6"},
  ingame_recallPosition_7 = {"ctrl", "7"},
  ingame_recallPosition_8 = {"ctrl", "8"},
  ingame_recallPosition_9 = {"ctrl", "9"},
  ingame_recallPosition_0 = {"ctrl", "0"},
}

-- Clear the loaded file variable.
fi = io.open(hotkeys_filename, "r")
local hotkeys_values = {}
local hotkeys_needs_rewrite = false
for key, value in pairs(hotkeys_defaults) do
  hotkeys_values[key] = serialize(value)
end

-- If the file opened successfully...
if fi then
  local file_contents = fi:read("*all")
  fi:close()

  for key, _ in pairs(hotkeys_defaults) do
    local ind = string.find(file_contents, "\n" .. "%s*" .. key .. "%s*=")

    -- If we couldn't find the key in the hotkeys.txt file...
    if not ind then
      hotkeys_needs_rewrite = true
    else
      ind = ind + (string.find(file_contents, key, ind) - ind) + string.len(key)
      ind = string.find(file_contents, "=", ind) + 1

      ind = string.find(file_contents, "[%[{]", ind)
      hotkeys_values[key] = string.sub(file_contents, ind, string.find(file_contents, "[\n]", ind + 1) - 1)
    end
  end
else
  hotkeys_needs_rewrite = true
end

--
if hotkeys_needs_rewrite then
  -- The config file that will be written is divided into separate strings, which are concatenated when they are written into the file.
  -- This is done to avoid a "Too many C levels" error.
  local string_01 = [=[
--------------------------CorsixTH Hotkey Mappings File-------------------------
-- Lines starting with two dashes (like this one) are ignored.
-- Text settings should have their values between double square braces, e.g.
-- Number settings should not have anything around their value, and complex
-- settings should be surrounded by curly brackets.
--
-- EXAMPLES
--   setting = [[value]]
--   setting = 42
--   setting = { 42, [[value]] }

-----------------------------------Global Keys----------------------------------
-- These are global keys to be used at anytime while the application is open.
--]=] .. '\n' ..
'global_confirm = ' .. hotkeys_values.global_confirm .. '\n' ..
'global_confirm_alt = ' .. hotkeys_values.global_confirm_alt .. '\n' ..
'global_cancel = ' .. hotkeys_values.global_cancel .. '\n' ..
'global_cancel_alt = ' .. hotkeys_values.global_cancel_alt .. '\n' ..
'global_fullscreen_toggle = ' .. hotkeys_values.global_fullscreen_toggle .. '\n' ..
'global_exitApp = ' .. hotkeys_values.global_exitApp .. '\n' ..
'global_resetApp = ' .. hotkeys_values.global_resetApp .. '\n' ..
'global_releaseMouse = ' .. hotkeys_values.global_releaseMouse .. '\n' ..
'global_connectDebugger = ' .. hotkeys_values.global_connectDebugger .. '\n' ..
'global_showLuaConsole = ' .. hotkeys_values.global_showLuaConsole .. '\n' ..
'global_runDebugScript = ' .. hotkeys_values.global_runDebugScript .. '\n' ..
'global_screenshot = ' .. hotkeys_values.global_screenshot .. '\n' ..
'global_stop_movie = ' .. hotkeys_values.global_stop_movie .. '\n' ..
'global_window_close = ' .. hotkeys_values.global_window_close .. '\n' ..
'global_stop_movie_alt =' .. hotkeys_values.global_stop_movie_alt .. '\n' ..
'global_window_close_alt =' .. hotkeys_values.global_window_close_alt .. '\n' .. [=[

-----------------------------------Scroll Keys----------------------------------
-- These are the keys to be used to scroll the camera around in-game.
--]=] .. '\n' ..
'ingame_scroll_up = ' .. hotkeys_values.ingame_scroll_up .. '\n' ..
'ingame_scroll_down = ' .. hotkeys_values.ingame_scroll_down .. '\n' ..
'ingame_scroll_left = ' .. hotkeys_values.ingame_scroll_left .. '\n' ..
'ingame_scroll_right = ' .. hotkeys_values.ingame_scroll_right .. '\n' ..
'ingame_scroll_shift = ' .. hotkeys_values.ingame_scroll_shift .. '\n' .. [=[

--------------------------------------Zoom--------------------------------------
-- These are keys used to zoom the camera in and out.
--]=] .. '\n' ..
'ingame_zoom_in = '.. hotkeys_values.ingame_zoom_in .. '\n' ..
'ingame_zoom_in_more = ' .. hotkeys_values.ingame_zoom_in_more .. '\n' ..
'ingame_zoom_out = ' .. hotkeys_values.ingame_zoom_out .. '\n' ..
'ingame_zoom_out_more = ' .. hotkeys_values.ingame_zoom_out_more .. '\n' ..
'ingame_reset_zoom = ' .. hotkeys_values.ingame_reset_zoom .. '\n' .. [=[

----------------------------------In-Game Menus---------------------------------
-- These are quick keys to show the in-game menu bar and some other windows.
--]=] .. '\n' ..
'ingame_showmenubar = ' .. hotkeys_values.ingame_showmenubar .. '\n' ..
'ingame_showCheatWindow = ' .. hotkeys_values.ingame_showCheatWindow .. '\n' ..
'ingame_loadMenu = ' .. hotkeys_values.ingame_loadMenu .. '\n' ..
'ingame_saveMenu = ' .. hotkeys_values.ingame_saveMenu .. '\n' ..
'ingame_jukebox = ' .. hotkeys_values.ingame_jukebox .. '\n' ..
'ingame_openFirstMessage = ' .. hotkeys_values.ingame_openFirstMessage .. '\n' .. [=[]=]

  local string_02 = [=[

----------------------------------Speed Control---------------------------------
-- These pause and control the speed of the game.
--]=] .. '\n' ..
'ingame_pause = ' .. hotkeys_values.ingame_pause .. '\n' ..
'ingame_gamespeed_slowest = ' .. hotkeys_values.ingame_gamespeed_slowest .. '\n' ..
'ingame_gamespeed_slower = ' .. hotkeys_values.ingame_gamespeed_slower .. '\n' ..
'ingame_gamespeed_normal = ' .. hotkeys_values.ingame_gamespeed_normal .. '\n' ..
'ingame_gamespeed_max = ' .. hotkeys_values.ingame_gamespeed_max .. '\n' ..
'ingame_gamespeed_thensome = ' .. hotkeys_values.ingame_gamespeed_thensome .. '\n' ..
'ingame_gamespeed_speedup = ' .. hotkeys_values.ingame_gamespeed_speedup .. '\n' .. [=[

------------------------------In-Game Bottom Panel------------------------------
-- These open in-game panel windows like the town map or the "build room" dialog.
--]=] .. '\n' ..
'ingame_panel_bankManager = ' .. hotkeys_values.ingame_panel_bankManager .. '\n' ..
'ingame_panel_bankStats = ' .. hotkeys_values.ingame_panel_bankStats .. '\n' ..
'ingame_panel_staffManage = ' .. hotkeys_values.ingame_panel_staffManage .. '\n' ..
'ingame_panel_townMap = ' .. hotkeys_values.ingame_panel_townMap .. '\n' ..
'ingame_panel_casebook = ' .. hotkeys_values.ingame_panel_casebook .. '\n' ..
'ingame_panel_research = ' .. hotkeys_values.ingame_panel_research .. '\n' ..
'ingame_panel_status = ' .. hotkeys_values.ingame_panel_status .. '\n' ..
'ingame_panel_charts = ' .. hotkeys_values.ingame_panel_charts .. '\n' ..
'ingame_panel_policy = ' .. hotkeys_values.ingame_panel_policy .. '\n' ..
'ingame_panel_map_alt = ' .. hotkeys_values.ingame_panel_map_alt .. '\n' ..
'ingame_panel_research_alt = ' .. hotkeys_values.ingame_panel_research_alt .. '\n' ..
'ingame_panel_casebook_alt = ' .. hotkeys_values.ingame_panel_casebook_alt .. '\n' ..
'ingame_panel_casebook_alt02 = ' .. hotkeys_values.ingame_panel_casebook_alt02 .. '\n' ..
'ingame_panel_buildRoom = ' .. hotkeys_values.ingame_panel_buildRoom .. '\n' ..
'ingame_panel_furnishCorridor = ' .. hotkeys_values.ingame_panel_furnishCorridor .. '\n' ..
'ingame_panel_editRoom = ' .. hotkeys_values.ingame_panel_editRoom .. '\n' ..
'ingame_panel_hireStaff = ' .. hotkeys_values.ingame_panel_hireStaff .. '\n' .. [=[

----------------------------------Rotate Object---------------------------------
-- This key rotates objects while they are being placed.
--]=] .. '\n' ..
'ingame_rotateobject = ' .. hotkeys_values.ingame_rotateobject .. '\n' .. [=[

-----------------------------------Quick Keys-----------------------------------
-- These are keys for quick saving and loading, and for quickly restarting and quitting the level.
--]=] .. '\n' ..
'ingame_quickSave = ' .. hotkeys_values.ingame_quickSave .. '\n' ..
'ingame_quickLoad = ' .. hotkeys_values.ingame_quickLoad .. '\n' ..
'ingame_restartLevel = ' .. hotkeys_values.ingame_restartLevel .. '\n' ..
'ingame_quitLevel = ' .. hotkeys_values.ingame_quitLevel .. '\n' .. [=[

---------------------------------Set Transparent--------------------------------
-- While held down any walls will be transparent, allowing you to see behind them.
--]=] .. '\n' ..
'ingame_setTransparent = ' .. hotkeys_values.ingame_setTransparent .. '\n' .. [=[
]=]

local string_03 = [=[

----------------------------Store and Recall Position---------------------------
-- These keys store and recall camera positions. If you press the key(s) that correspond to
-- "ingame_recallPosition_1" while looking over the operating room, for instance, and then
-- you move the camera away from there, you can press "ingame_recallPosition_1" whenever
-- you want to go back to the operating room instantly.
--]=] .. '\n' ..
'ingame_storePosition_1 = ' .. hotkeys_values.ingame_storePosition_1 .. '\n' ..
'ingame_storePosition_2 = ' .. hotkeys_values.ingame_storePosition_2 .. '\n' ..
'ingame_storePosition_3 = ' .. hotkeys_values.ingame_storePosition_3 .. '\n' ..
'ingame_storePosition_4 = ' .. hotkeys_values.ingame_storePosition_4 .. '\n' ..
'ingame_storePosition_5 = ' .. hotkeys_values.ingame_storePosition_5 .. '\n' ..
'ingame_storePosition_6 = ' .. hotkeys_values.ingame_storePosition_6 .. '\n' ..
'ingame_storePosition_7 = ' .. hotkeys_values.ingame_storePosition_7 .. '\n' ..
'ingame_storePosition_8 = ' .. hotkeys_values.ingame_storePosition_8 .. '\n' ..
'ingame_storePosition_9 = ' .. hotkeys_values.ingame_storePosition_9 .. '\n' ..
'ingame_storePosition_0 = ' .. hotkeys_values.ingame_storePosition_0 .. '\n' ..
'ingame_recallPosition_1 = ' .. hotkeys_values.ingame_recallPosition_1 .. '\n' ..
'ingame_recallPosition_2 = ' .. hotkeys_values.ingame_recallPosition_2 .. '\n' ..
'ingame_recallPosition_3 = ' .. hotkeys_values.ingame_recallPosition_3 .. '\n' ..
'ingame_recallPosition_4 = ' .. hotkeys_values.ingame_recallPosition_4 .. '\n' ..
'ingame_recallPosition_5 = ' .. hotkeys_values.ingame_recallPosition_5 .. '\n' ..
'ingame_recallPosition_6 = ' .. hotkeys_values.ingame_recallPosition_6 .. '\n' ..
'ingame_recallPosition_7 = ' .. hotkeys_values.ingame_recallPosition_7 .. '\n' ..
'ingame_recallPosition_8 = ' .. hotkeys_values.ingame_recallPosition_8 .. '\n' ..
'ingame_recallPosition_9 = ' .. hotkeys_values.ingame_recallPosition_9 .. '\n' ..
'ingame_recallPosition_0 = ' .. hotkeys_values.ingame_recallPosition_0 .. '\n' .. [=[

---------------------------------Toggle Various---------------------------------
-- These toggle various things. The names tell all.
--]=] .. '\n' ..
'ingame_toggleAnnouncements = ' .. hotkeys_values.ingame_toggleAnnouncements .. '\n' ..
'ingame_toggleSounds = ' .. hotkeys_values.ingame_toggleSounds .. '\n' ..
'ingame_toggleMusic = ' .. hotkeys_values.ingame_toggleMusic .. '\n' ..
'ingame_toggleAdvisor = ' .. hotkeys_values.ingame_toggleAdvisor .. '\n' ..
'ingame_toggleInfo = ' .. hotkeys_values.ingame_toggleInfo .. '\n' .. [=[

------------------------------------Dump Log------------------------------------
-- These keys dump logs. And strings, if too much fiber was taken.
--]=] .. '\n' ..
'ingame_poopLog = ' .. hotkeys_values.ingame_poopLog .. '\n' ..
'ingame_poopStrings = ' .. hotkeys_values.ingame_poopStrings .. '\n' .. [=[

--------------------------------Patient, Go Home--------------------------------
-- This sends a patient home. Also a good anime episode name.
--]=] .. '\n' ..
'ingame_patient_gohome = ' .. hotkeys_values.ingame_patient_gohome .. '\n' .. [=[
]=]
  fi = TheApp:writeToFileOrTmp(hotkeys_filename)
  fi:write(string_01 .. string_02 .. string_03)
  fi:close()
end

for k, str_val in pairs(hotkeys_values) do
  local status, lua_val = pcall(loadstring_envcall('return ' .. str_val), {})
  if status then
    hotkeys_values[k] = lua_val
  end
end

return config_filename, config_values, hotkeys_filename, hotkeys_values, hotkeys_defaults
