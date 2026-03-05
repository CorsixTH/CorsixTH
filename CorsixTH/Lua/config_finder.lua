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

-- This module detects the appropriate path for the config.txt and hotkeys.txt
-- files. It also manages saving and loading from these files and their
-- contents.
--
-- To add a new config property add it's default value to the table in
-- new_config_defaults, then update the string in the config_contents with a
-- description of the property under the most relevant heading followed by
-- param(config_values, 'your_parameter_name').
--
-- If your config property does not have a default value (defaults to nil) it
-- can be helpful to include an example of the expected input, with the
-- following syntax: param(config_values, 'param_name', '[[example]]')
--
-- For new hotkeys the process is similar but use the new_hotkeys_defaults
-- function table for the default value and the string in the hotkeys_contents
-- function to include the parameter in the hotkeys.txt configuration file.
-- The same params syntax applies.
--
-- After changing the config.txt file you need to generate a new template for
-- the windows installer by running `lua scripts/generate_windows_config.lua`
-- from the root of the repository.
--
-- The format of the configuration files should not be depended on anywhere
-- outside of this module. It is a layering violation to attempt to parse or
-- update the file anywhere else in the codebase e.g. app.lua.

local pathsep = package.config:sub(1, 1)
local ourpath = debug.getinfo(1, "S").source:sub(2, -22)
local serialize = serialize -- from utility

local function pathconcat(a, b)
  if a:sub(-1) == pathsep then
    return a .. b
  else
    return a .. pathsep .. b
  end
end

local function find_config()
  local config_path
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
  local config_name = "config.txt"

  -- Check for config.path.txt
  local fi = io.open(pathconcat(ourpath, "config.path.txt"), "r")
  if fi then
    local contents = fi:read("*a")
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

  return pathconcat(config_path, config_name), config_path, config_name
end

local function new_config_defaults()
  --[[
  All the folders settings have default paths that likely do not exist.
  When adding new fields, please try and keep the end results user friendly.
  They are all grouped into the places they can be changed in game and then into a group
  that can only be changed here. Currently the player name is at the bottom of the list
  for the config as it this is where it always ends up when the file is recreated.
  The following list is in the same order.
  ]]
  return {
    fullscreen = false,
    width = 800,
    height = 600,
    ui_scale = 1,
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
    right_mouse_scrolling = false,
    adviser_disabled = false,
    scrolling_momentum = 0.8,
    twentyfour_hour_clock = true,
    warmth_colors_display_default = 1,
    grant_wage_increase = false,
    movies = true,
    play_intro = true,
    play_demo = true,
    allow_user_actions_while_paused = false,
    volume_opens_casebook = false,
    alien_dna_only_by_emergency = true,
    alien_dna_must_stand = true,
    alien_dna_can_knock_on_doors = false,
    disable_fractured_bones_females = true,
    enable_avg_contents = false,
    remove_destroyed_rooms = false,
    machine_menu_button = true,
    enable_screen_shake = true,
    enable_announcer_subtitles = false,
    autosave_frequency = 1,
    audio_frequency = 22050,
    audio_channels = 2,
    audio_buffer_size = 2048,
    midi_api = nil,
    midi_port = nil,
    midi_sysex_master_volume = false,
    theme_hospital_install = [[X:\ThemeHospital\hospital]],
    debug = false,
    track_fps = false,
    zoom_speed = 80,
    scroll_speed = 2,
    shift_scroll_speed = 4,
    new_graphics_folder = nil,
    use_new_graphics = false,
    check_for_updates = true,
    room_information_dialogs = true,
    allow_blocking_off_areas = false,
    direct_zoom = nil,
    new_machine_extra_info = true,
    player_name = [[]],
  }
end

-- Defaults for hotkeys.
local function new_hotkeys_defaults()
  return {
    global_confirm = "return",
    global_confirm_alt = "e",
    global_cancel = "escape",
    global_cancel_alt = "q",
    global_fullscreen_toggle = {"alt", "return"},
    global_exitApp = {"alt", "f4"},
    global_resetApp = {"shift", "f10"},
    global_releaseMouse = {"ctrl", "f10"},
    global_showLuaConsole = "f12",
    global_runDebugScript = {"shift", "d"},
    global_screenshot = {"ctrl", "s"},
    global_stop_movie = "escape",
    global_stop_movie_alt = "q",
    global_pause_movie = "p",
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
    ingame_toggleTransparent = {"shift", "x"},
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
    ingame_panel_machineMenu = "f10",
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
end

local function param(params, param_name, nil_example)
  if nil_example then
    return param_name .. ' = ' ..
        (params[param_name] and serialize(params[param_name]) or 'nil -- ' .. nil_example) .. '\n'
  end
  return param_name .. ' = ' .. serialize(params[param_name]) .. '\n'
end

local function config_contents(config_values)
  local parts = {}
  parts[1] = [=[
------------------------- CorsixTH configuration file -------------------------
-- Lines starting with two dashes (like this one) are ignored.
-- Text settings should have their values between double square braces, e.g.
--  setting = [[value]]
-- Number settings should not have anything around their value,
-- e.g. setting = 42
-- If you wish to go back to the default settings for everything, you can delete
-- this text file and it will be re-created when you play the game.
--
-------------------------------- SETTINGS MENU --------------------------------
-- These settings can also be changed from within the game in the settings menu
-------------------------------------------------------------------------------
-- Screen size. Must be at least 640x480. Larger sizes will require better
-- hardware in order to maintain a playable framerate. The fullscreen setting
-- can be true or false, and the game will run windowed if not fullscreen.
-- ui_scale can be set to 1, 2, or 3 to scale the user interface for higher
-- resolution displays. For example, at 1920x1080 resolution, setting ui_scale
-- to 2 will make the interface elements twice as large.
--]=] .. '\n' ..
param(config_values, 'fullscreen') ..
'\n' ..
param(config_values, 'width') ..
param(config_values, 'height') ..
param(config_values, 'ui_scale') .. [=[

-------------------------------------------------------------------------------
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
--  Japanese              / ja / jp
--  Korean                / kor / ko
--  Norwegian             / nb / nob
--  Polish                / pl / pol
--  Portuguese            / pt / por
--  Russian               / ru / rus
--  Spanish               / es / spa
--  Swedish               / sv / swe
--  Ukrainian             / uk / ukr
--]=] .. '\n' ..
param(config_values, 'language') .. [=[

-------------------------------------------------------------------------------
-- Audio global on/off switch.
--]=] .. '\n' ..
param(config_values, 'audio') .. '\n'

parts[2] = [=[
------------------------------ CUSTOM GAME MENU -------------------------------
-- These settings can also be changed from the opening menu screen
-- in the custom games or new game menus
-------------------------------------------------------------------------------
-- Free Build or Sandbox mode
-- You cannot win or lose custom made maps if this is set to true.
-- You also don't have to worry about money.
-- This setting does not apply to any of the campaign maps.
--]=] .. '\n' ..
param(config_values, 'free_build_mode') .. '\n'

parts[3] = [=[
--------------------------------- OPTIONS MENU --------------------------------
--These settings can also be changed from within the game from the options menu
-------------------------------------------------------------------------------
-- Sounds: By default enabled and set at level 0.5
--]=] .. '\n' ..
param(config_values, 'play_sounds') ..
param(config_values, 'sound_volume') .. [=[

-------------------------------------------------------------------------------
-- Announcements: By default set at level 0.5
--]=] .. '\n' ..
param(config_values, 'play_announcements') ..
param(config_values, 'announcement_volume') .. [=[

-------------------------------------------------------------------------------
-- Background music: By default enabled and set at level 0.5
--]=] .. '\n' ..
param(config_values, 'play_music') ..
param(config_values, 'music_volume') .. [=[

-------------------------------------------------------------------------------
-- Edge scrolling: By default enabled (prevent_edge_scrolling = false).
--]=] .. '\n' ..
param(config_values, 'prevent_edge_scrolling') .. [=[

-------------------------------------------------------------------------------
-- Capture mouse: By default enabled (capture mouse = true).
--]=] .. '\n' ..
param(config_values, 'capture_mouse') .. [=[

-------------------------------------------------------------------------------
-- Right Mouse Scrolling: By default, it is disabled (right_mouse_scrolling = false).
-- This means that the default scrolling method is pressing the middle mouse button.
-- Please note this an Experimental Feature and may interfere with other right mouse
-- operations. Report bugs for this on Github Issue 2469.
--]=] .. '\n' ..
param(config_values, 'right_mouse_scrolling') .. [=[

-------------------------------------------------------------------------------
-- Adviser on/off: If you set this to true the adviser will no longer
-- pop up.
--]=] .. '\n' ..
param(config_values, 'adviser_disabled') .. [=[

-------------------------------------------------------------------------------
-- Scrolling Momentum.
-- Determines the amount of momentum when scrolling the map with the mouse.
-- This should be a value between 0 and 1 where 0 is no momentum
--]=] .. '\n' ..
param(config_values, 'scrolling_momentum') .. [=[

-------------------------------------------------------------------------------
-- Top menu clock is by default is always on
-- setting to true will give you a twentyfour hours display
-- change to false if you want AM / PM time displayed.
--]=] .. '\n' ..
param(config_values, 'twentyfour_hour_clock') .. [=[

-------------------------------------------------------------------------------
-- Automatically check for updates.
-- If set to true, CorsixTH will automatically check for and alert you to newer
-- versions on startup.
--]=] .. '\n' ..
param(config_values, 'check_for_updates') .. [=[

-------------------------------------------------------------------------------
-- Warmth Colors display settings.
-- This specifies which display method is set for warmth colours by default.
-- Possible values: 1 (Red), 2 (Blue Green Red) and 3 (Yellow Orange Red).
--]=] .. '\n' ..
param(config_values, 'warmth_colors_display_default') .. '\n'

parts[4] = [=[
------------------------------ CUSTOMISE SETTINGS -----------------------------
-- These settings can also be changed from the Customise Menu

-------------------------------------------------------------------------------
-- Wage increase request settings.
-- If set to true when wage increase requests expire automatically grant them
-- otherwise let the staff member quit.
--]=] .. '\n' ..
param(config_values, 'grant_wage_increase') .. [=[

-------------------------------------------------------------------------------
-- Movie global on/off switch.
-- Note that movies will also be disabled if CorsixTH was compiled without the
-- FFMPEG library.
--]=] .. '\n' ..
param(config_values, 'movies') .. [=[

-- Intro movie: Enabled by default
--]=] .. '\n' ..
param(config_values, 'play_intro') .. [=[

-- Demo movie (played on idle at main menu): Enabled by default
--]=] .. '\n' ..
param(config_values, 'play_demo') .. [=[

-------------------------------------------------------------------------------
-- Allow user actions while game is paused
-- In Theme Hospital the player would only be allowed to use the top menu if
-- the game was paused. That is the default setting in CorsixTH too, but by
-- setting this to true everything is allowed while the game is paused.
--]=] .. '\n' ..
param(config_values, 'allow_user_actions_while_paused') .. [=[

-------------------------------------------------------------------------------
-- VOLUME CONTROL IS OPENING THE DRUG CASEBOOK?

-- If your keyboard volume control opens the Drug Casebook at the same time
-- then change this to true. From then on you will have to use Shift + C to open
-- the Casebook and volume down will not open it.
-- For example for shift + C to open casebook change the setting below to = true
--]=] .. '\n' ..
param(config_values, 'volume_opens_casebook') .. [=[

-------------------------------------------------------------------------------
-- To allow patients with Alien DNA to visit your hospital other than by an
-- emergency change the settings below. Understand that there are no animations
-- for sitting down, opening or knocking on doors etc.
-- So, like with Theme Hospital to do these things they will appear to change
-- to normal looking and then change back.
--]=] .. '\n' ..
param(config_values, 'alien_dna_only_by_emergency') ..
param(config_values, 'alien_dna_must_stand') ..
param(config_values, 'alien_dna_can_knock_on_doors') .. [=[

-- To allow female patients with fractured bones, which are by default
-- disabled due to poor animation that skips and jumps a bit
--]=] .. '\n' ..
param(config_values, 'disable_fractured_bones_females') .. [=[

-------------------------------------------------------------------------------
-- By default the player selects any extra objects they want for each room they
-- build. If you would like the game to remember what you usually add, then
-- change this option to true.
--]=] .. '\n' ..
param(config_values, 'enable_avg_contents') .. [=[

-------------------------------------------------------------------------------
-- By default destroyed rooms can't be removed. If you would like the game to
-- give you the option of removing a destroyed room change this option to true.
--]=] .. '\n' ..
param(config_values, 'remove_destroyed_rooms') .. [=[

-------------------------------------------------------------------------------
-- By default machine menu is shown in a bottom panel. If you would like the
-- game to hide it change this option to false.
--]=] .. '\n' ..
param(config_values, 'machine_menu_button') .. [=[

-------------------------------------------------------------------------------
-- By default the entire screen will shake during earthquakes. If you would
-- like the game to keep the screen stationary, change this option to false.
--]=] .. '\n' ..
param(config_values, 'enable_screen_shake') .. [=[

-------------------------------------------------------------------------------
-- By default subtitles are not displayed. If you would like the game to
-- display subtitles for your hospital's announcements, turn this option on.
--]=] .. '\n' ..
param(config_values, 'enable_announcer_subtitles') .. [=[

-------------------------------------------------------------------------------
-- By default, the game autosaves every in-game month. If you would like to
-- autosave more often, every week or every day, change this setting to 2 or 3.
-- Please note that a typical save can take up to 1 megabyte or even more.
-- This way your autosaves folder can grow to 300-500 MB with daily autosaves.
-- Set 1 for Monthly, 2 for Weekly, 3 for Daily autosaves.
--]=] .. '\n' ..
param(config_values, 'autosave_frequency') .. '\n'

  parts[5] = [=[
------------------------------- FOLDER SETTINGS -------------------------------
-- These settings can also be changed from the Folders Menu
-------------------------------------------------------------------------------
-- Theme hospital install folder: original game data files are loaded from this
-- folder. Between the square braces should be the folder which contains the
-- original HOSPITAL.EXE and/or HOSP95.EXE file. This can point to a copy of
-- the Theme Hospital demo, though a full install of the original game is
-- preferred.
--]=] .. '\n' ..
param(config_values, 'theme_hospital_install', '[[X:\\ThemeHospital]]') .. [=[

-------------------------------------------------------------------------------
-- Font file setting. Can be changed from main game menu
-- Specify a font file here if you wish to play the game in a language not
-- present in the original game. Examples include Russian, Chinese and Polish.
--]=] .. '\n' ..
param(config_values, 'unicode_font', '[[X:\\ThemeHospital\\font.ttc]]') .. [=[

-------------------------------------------------------------------------------
-- Savegames. By default, the "Saves" directory alongside this config file will
-- be used for storing saved games in. Should this not be suitable, then
-- uncomment the following line, and point it to a directory which exists and
-- is more suitable.
--]=] .. '\n' ..
param(config_values, 'savegames', '[[X:\\ThemeHospital\\Saves]]') .. [=[

-------------------------------------------------------------------------------
-- Levels and Campaigns. By default, the "Levels" and "Campaigns" directory next to
-- this config file will be used for storing new maps / levels / campaigns in. If
-- this is not suitable, then uncomment the following lines, and point it to a directory
-- which exists and is more suitable.
-- Note: Newly created maps in the Map Editor go into the "Levels" folder currently.
--]=] .. '\n' ..
param(config_values, 'levels', '[[X:\\ThemeHospital\\Levels]]') ..
param(config_values, 'campaigns', '[[X:\\ThemeHospital\\Campaigns]]') .. [=[

-------------------------------------------------------------------------------
-- Use new graphics. Whether to use the original graphics from Theme Hospital
-- or use new graphics created by the CorsixTH project.
-- Developer use only, otherwise the game will very likely crash in normal use
--]=] .. '\n' ..
param(config_values, 'use_new_graphics') .. [=[

-------------------------------------------------------------------------------
-- Graphics folder. All graphics are initially taken from the original
-- Theme Hospital, but the game can also try to find new graphics in the
-- specified folder below. Some graphics are shipped with CorsixTH, and they
-- will be used if you just switch on new graphics. If you however have
-- acquired graphics from somewhere else, then uncomment the following line
-- and point it to the directory which contains the new graphics.
--]=] .. '\n' ..
param(config_values, 'new_graphics_folder', '[[X:\\ThemeHospital\\Graphics]]') .. [=[

-------------------------------------------------------------------------------
-- Screenshots. By default, the "Screenshots" directory alongside this config
-- file will be used for saving screenshots. Should this not be suitable, then
-- uncomment the following line, and point it to a directory which exists and
-- is more suitable.
--]=] .. '\n' ..
param(config_values, 'screenshots', '[[X:\\ThemeHospital\\Screenshots]]') .. [=[

-------------------------------------------------------------------------------
-- If you want to listen to non-Theme-Hospital music, then follow these steps:
--  1) Find updated versions of the original tracks (a link to ZR's Remixes can
--     be found on the CorsixTH wiki) or any other music you want to listen to.
--  2) Uncomment the next line and point it to where the music files are.
--  3) If you want to change the names of songs ingame, make a file called
--     "names.txt" and write the file name on one row, followed by the desired
--     ingame name on the next row.
--]=] .. '\n' ..
param(config_values, 'audio_music', '[[X:\\ThemeHospital\\Music]]') .. [=[

-------------------------------------------------------------------------------
-- SoundFont: CorsixTH uses the FluidR3 SoundFont by default for playing MIDI music.
-- Windows users, and other OS versions compiled with the FluidSynth software
-- synthesiser can specify their own SoundFont file below (.sf2 or .sf3).
-- Mac(OS) Source Ports build users, and OS versions compiled with TiMidity
-- won't see any effect from this option. See our Wiki for alternative options.
--]=] .. '\n' ..
param(config_values, 'soundfont', '[[X:\\ThemeHospital\\FluidR3.sf3]]') .. '\n'

  parts[6] = [=[
-------------------------------------------------------------------------------
-- Midi API and Device settings.
-- By default, CorsixTH uses FluidSynth or build defined MIDI synthesizer.
-- You can change the API to target other available MIDI backends using these
-- settings on supported platforms.
-- Possible values for midi_api are:
--   <nil>      - Uses SDL_Mixer's MIDI backend, typically FluidSynth
--   Native     - Use any available platform MIDI API
--   ALSA       - Use the ALSA MIDI API (Linux only)
--   JACK       - Use the JACK MIDI API (Unix-like systems with JACK)
--   CoreMIDI   - Use the CoreMIDI API (MacOS only)
--   WindowsMM  - Use the Windows MultiMedia API (Windows only)
--
-- Possible values for midi_port depend on the selected midi_api, and can
-- be left nil to use the system default port. A list of available ports
-- can be obtained from the midi settings screen in game.
--]=] .. '\n' ..
param(config_values, 'midi_api', '[[Native]]') ..
param(config_values, 'midi_port', '[[Midi Through:Midi Through Port-0 14:0]]') .. [=[

------------------------------- SPECIAL SETTINGS ------------------------------
-- These settings can only be changed here
-------------------------------------------------------------------------------
-- Audio playback settings.
-- These can be commented out to use the default values from the game binary.
-- Note: On some platforms, these settings may not effect MIDI playback - only
-- sound effects and music audio. If you are experiencing poor audio playback,
-- then try doubling the buffer size.
--]=] .. '\n' ..
param(config_values, 'audio_frequency') ..
param(config_values, 'audio_channels') ..
param(config_values, 'audio_buffer_size') .. [=[

-------------------------------------------------------------------------------
-- Advanced MIDI settings.
-- These settings can enable better MIDI playback on some systems but may also
-- cause issues or be unsupported on others.
--
-- midi_sysex_master_volume: Use SysEx message instead of adjusted channel
-- volume messages to set the music volume.
--]=] .. '\n' ..
param(config_values, 'midi_sysex_master_volume') .. [=[

-------------------------------------------------------------------------------
-- Debug settings.
-- If set to true more detailed information will be printed in the terminal
-- and a debug menu will be visible.
--]=] .. '\n' ..
param(config_values, 'debug') .. [=[

-- If set to true, the FPS, Lua memory usage, and entity count will be shown
-- in the dynamic information bar. Note that setting this to true also turns
-- off the FPS limiter, causing much higher CPU utilisation, but resulting in
-- more useful FPS values, as they are not artificially capped.
--]=] .. '\n' ..
param(config_values, 'track_fps') .. [=[

-------------------------------------------------------------------------------
-- Zoom Speed: By default this is set at 80
-- Any number value between 10 and 1000, 10 is very slow and 1000 is very fast!
--]=] .. '\n' ..
param(config_values, 'zoom_speed') .. [=[

-------------------------------------------------------------------------------
-- Scroll Speeds: The speed of scrolling with and without shift being held.
-- Any number value between 1 and 10, 1 is very slow and 10 is fast!
--]=] .. '\n' ..
param(config_values, 'scroll_speed') ..
param(config_values, 'shift_scroll_speed') .. [=[

-------------------------------------------------------------------------------
-- Room information dialogs: Information about new rooms, important for
-- additional rooms in later levels. Affects campaign only.
--]=] .. '\n' ..
param(config_values, 'room_information_dialogs') .. [=[

-------------------------------------------------------------------------------
-- If true, parts of the hospital can be made inaccessible by blocking the path
-- with rooms or objects. If false, all parts of the hospital must be kept
-- accessible, the game will disallow any attempt to blocking the path.
--]=] .. '\n' ..
param(config_values, 'allow_blocking_off_areas') .. [=[

-------------------------------------------------------------------------------
-- Direct Zoom: Avoid rendering to an intermediate texture when zooming.
-- Improves performance and reliability on some hardware.
--]=] .. '\n' ..
param(config_values, 'direct_zoom') .. [=[

-------------------------------------------------------------------------------
-- Replacing Machines: By default, you will see a new machines initial strength
-- before purchasing it. If you don't want this change the value to false.
--]=] .. '\n' ..
param(config_values, 'new_machine_extra_info') .. [=[

-------------------------------------------------------------------------------
-- By default your username will be your name in the game. You can change it in
-- the New Game menu or between the brace brackets below like [[NAME]].
-- Note: space is limited in the game, so don't enter a name that is too long!
--]=] .. '\n' ..
param(config_values, 'player_name') .. '\n'

  return table.concat(parts)
end

local function hotkeys_contents(hotkeys_values)
  local parts = {}
  parts[1] = [=[
--------------------------CorsixTH Hotkey Mappings File------------------------
-- Lines starting with two dashes (like this one) are ignored.
-- Text settings should have their values between double square braces, e.g.
-- Number settings should not have anything around their value, and complex
-- settings should be surrounded by curly brackets.
--
-- EXAMPLES
--   setting = [[value]]
--   setting = 42
--   setting = { 42, [[value]] }

-----------------------------------Global Keys---------------------------------
-- These are global keys to be used at anytime while the application is open.
--]=] .. '\n' ..
param(hotkeys_values, 'global_confirm') ..
param(hotkeys_values, 'global_confirm_alt') ..
param(hotkeys_values, 'global_cancel') ..
param(hotkeys_values, 'global_cancel_alt') ..
param(hotkeys_values, 'global_fullscreen_toggle') ..
param(hotkeys_values, 'global_exitApp') ..
param(hotkeys_values, 'global_resetApp') ..
param(hotkeys_values, 'global_releaseMouse') ..
param(hotkeys_values, 'global_showLuaConsole') ..
param(hotkeys_values, 'global_runDebugScript') ..
param(hotkeys_values, 'global_screenshot') ..
param(hotkeys_values, 'global_stop_movie') ..
param(hotkeys_values, 'global_pause_movie') ..
param(hotkeys_values, 'global_window_close') ..
param(hotkeys_values, 'global_stop_movie_alt') ..
param(hotkeys_values, 'global_window_close_alt') .. [=[

-----------------------------------Scroll Keys---------------------------------
-- These are the keys to be used to scroll the camera around in-game.
--]=] .. '\n' ..
param(hotkeys_values, 'ingame_scroll_up') ..
param(hotkeys_values, 'ingame_scroll_down') ..
param(hotkeys_values, 'ingame_scroll_left') ..
param(hotkeys_values, 'ingame_scroll_right') ..
param(hotkeys_values, 'ingame_scroll_shift') .. [=[

--------------------------------------Zoom-------------------------------------
-- These are keys used to zoom the camera in and out.
--]=] .. '\n' ..
param(hotkeys_values, 'ingame_zoom_in') ..
param(hotkeys_values, 'ingame_zoom_in_more') ..
param(hotkeys_values, 'ingame_zoom_out') ..
param(hotkeys_values, 'ingame_zoom_out_more') ..
param(hotkeys_values, 'ingame_reset_zoom') .. [=[

----------------------------------In-Game Menus--------------------------------
-- These are quick keys to show the in-game menu bar and some other windows.
--]=] .. '\n' ..
param(hotkeys_values, 'ingame_showmenubar') ..
param(hotkeys_values, 'ingame_showCheatWindow') ..
param(hotkeys_values, 'ingame_loadMenu') ..
param(hotkeys_values, 'ingame_saveMenu') ..
param(hotkeys_values, 'ingame_jukebox') ..
param(hotkeys_values, 'ingame_openFirstMessage')

  parts[2] = [=[

-- These pause and control the speed of the game.
--]=] .. '\n' ..
param(hotkeys_values, 'ingame_pause') ..
param(hotkeys_values, 'ingame_gamespeed_slowest') ..
param(hotkeys_values, 'ingame_gamespeed_slower') ..
param(hotkeys_values, 'ingame_gamespeed_normal') ..
param(hotkeys_values, 'ingame_gamespeed_max') ..
param(hotkeys_values, 'ingame_gamespeed_thensome') ..
param(hotkeys_values, 'ingame_gamespeed_speedup') .. [=[

------------------------------In-Game Bottom Panel-----------------------------
-- These open in-game panel windows like the town map or the build room dialog.
--]=] .. '\n' ..
param(hotkeys_values, 'ingame_panel_bankManager') ..
param(hotkeys_values, 'ingame_panel_bankStats') ..
param(hotkeys_values, 'ingame_panel_staffManage') ..
param(hotkeys_values, 'ingame_panel_townMap') ..
param(hotkeys_values, 'ingame_panel_casebook') ..
param(hotkeys_values, 'ingame_panel_research') ..
param(hotkeys_values, 'ingame_panel_status') ..
param(hotkeys_values, 'ingame_panel_charts') ..
param(hotkeys_values, 'ingame_panel_policy') ..
param(hotkeys_values, 'ingame_panel_machineMenu') ..
param(hotkeys_values, 'ingame_panel_map_alt') ..
param(hotkeys_values, 'ingame_panel_research_alt') ..
param(hotkeys_values, 'ingame_panel_casebook_alt') ..
param(hotkeys_values, 'ingame_panel_casebook_alt02') ..
param(hotkeys_values, 'ingame_panel_buildRoom') ..
param(hotkeys_values, 'ingame_panel_furnishCorridor') ..
param(hotkeys_values, 'ingame_panel_editRoom') ..
param(hotkeys_values, 'ingame_panel_hireStaff') .. [=[

----------------------------------Rotate Object--------------------------------
-- This key rotates objects while they are being placed.
-- ]=] .. '\n' ..
param(hotkeys_values, 'ingame_rotateobject') .. [=[

-----------------------------------Quick Keys----------------------------------
-- These are keys for quick saving and loading, and for quickly restarting and
-- quitting the level.
--]=] .. '\n' ..
param(hotkeys_values, 'ingame_quickSave') ..
param(hotkeys_values, 'ingame_quickLoad') ..
param(hotkeys_values, 'ingame_restartLevel') ..
param(hotkeys_values, 'ingame_quitLevel') .. [=[

---------------------------------Set Transparent-------------------------------
-- Use these keys to make walls transparent, allowing you to see behind them.
--]=] .. '\n' ..
param(hotkeys_values, 'ingame_setTransparent') ..
param(hotkeys_values, 'ingame_toggleTransparent') .. [=[
]=]

  parts[3] = [=[

----------------------------Store and Recall Position--------------------------
-- These keys store and recall camera positions. If you press the key(s) that
-- correspond to "ingame_recallPosition_1" while looking over the
-- operating room, for instance, and then you move the camera away from there,
-- you can press "ingame_recallPosition_1" whenever you want to go back to
-- the operating room instantly.
--]=] .. '\n' ..
param(hotkeys_values, 'ingame_storePosition_1') ..
param(hotkeys_values, 'ingame_storePosition_2') ..
param(hotkeys_values, 'ingame_storePosition_3') ..
param(hotkeys_values, 'ingame_storePosition_4') ..
param(hotkeys_values, 'ingame_storePosition_5') ..
param(hotkeys_values, 'ingame_storePosition_6') ..
param(hotkeys_values, 'ingame_storePosition_7') ..
param(hotkeys_values, 'ingame_storePosition_8') ..
param(hotkeys_values, 'ingame_storePosition_9') ..
param(hotkeys_values, 'ingame_storePosition_0') ..
param(hotkeys_values, 'ingame_recallPosition_1') ..
param(hotkeys_values, 'ingame_recallPosition_2') ..
param(hotkeys_values, 'ingame_recallPosition_3') ..
param(hotkeys_values, 'ingame_recallPosition_4') ..
param(hotkeys_values, 'ingame_recallPosition_5') ..
param(hotkeys_values, 'ingame_recallPosition_6') ..
param(hotkeys_values, 'ingame_recallPosition_7') ..
param(hotkeys_values, 'ingame_recallPosition_8') ..
param(hotkeys_values, 'ingame_recallPosition_9') ..
param(hotkeys_values, 'ingame_recallPosition_0') .. [=[

---------------------------------Toggle Various--------------------------------
-- These toggle various things. The names tell all.
--]=] .. '\n' ..
param(hotkeys_values, 'ingame_toggleAnnouncements') ..
param(hotkeys_values, 'ingame_toggleSounds') ..
param(hotkeys_values, 'ingame_toggleMusic') ..
param(hotkeys_values, 'ingame_toggleAdvisor') ..
param(hotkeys_values, 'ingame_toggleInfo') .. [=[

------------------------------------Dump Log-----------------------------------
-- These keys dump logs. And strings, if too much fiber was taken.
--]=] .. '\n' ..
param(hotkeys_values, 'ingame_poopLog') ..
param(hotkeys_values, 'ingame_poopStrings') .. [=[

--------------------------------Patient, Go Home-------------------------------
-- This sends a patient home. Also a good anime episode name.
--]=] .. '\n' ..
param(hotkeys_values, 'ingame_patient_gohome') .. [=[
]=]

  return table.concat(parts)
end

local function apply_config_defaults(res)
  local config_defaults = new_config_defaults()
  for key, value in pairs(config_defaults) do
    if res[key] == nil then
      res[key] = value
    end
  end
end

local function apply_hotkeys_defaults(res)
  local hotkeys_defaults = new_hotkeys_defaults()
  for key, value in pairs(hotkeys_defaults) do
    if res[key] == nil then
      res[key] = value
    end
  end
end

local function open_for_write(path)
  if TheApp then
    return TheApp:writeToFileOrTmp(path)
  else
    return io.open(path, "w")
  end
end

local function save_config(path, values)
  local config_data = config_contents(values)
  local fi, err = open_for_write(path)
  if not fi then
    return nil, err
  end
  fi:write(config_data)
  fi:close()
  return true
end

local function save_hotkeys(path, values)
  local hotkeys_data = hotkeys_contents(values)
  local fi, err = open_for_write(path)
  if not fi then
    return nil, err
  end
  fi:write(hotkeys_data)
  fi:close()
  return true
end

local function load_config(path, res)
  res = res or {}
  local lfs = require("lfs")
  if not lfs.attributes(path) then
    save_config(path, new_config_defaults())
  end
  local chunk, err = loadfile_envcall(path)
  if chunk then
    chunk(res)
  end
  apply_config_defaults(res)

  return res, err
end

local function load_hotkeys(path, res)
  res = res or {}
  if not lfs.attributes(path) then
    save_hotkeys(path, new_hotkeys_defaults())
  end
  local chunk, err = loadfile_envcall(path)
  if chunk then
    chunk(res)
  end
  apply_hotkeys_defaults(res)

  return res, err
end

local config_filename, config_path = find_config()

-- Hotkey filename.
local hotkeys_name = "hotkeys.txt"

-- Hotkey file with full path as string.
local hotkeys_filename = pathconcat(config_path, hotkeys_name)

return {
  config_filename = config_filename,
  config_defaults = new_config_defaults,
  load_config = load_config,
  save_config = save_config,
  hotkeys_filename = hotkeys_filename,
  hotkeys_defaults = new_hotkeys_defaults,
  load_hotkeys = load_hotkeys,
  save_hotkeys = save_hotkeys,
}
