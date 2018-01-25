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
local lfs = require "lfs"
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
  check_for_updates = true
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
  fi = io.open(config_filename, "w")
  if fi then
    fi:write([=[
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
-- ]=] .. '\n' ..
'fullscreen = ' .. tostring(config_values.fullscreen) .. '\n' ..
'\n' ..
'width = ' .. tostring(config_values.width) .. '\n' ..
'height = ' .. tostring(config_values.height) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Language to use for ingame text. Between the square braces should be one of:
--  Brazilian Portuguese  / pt_br / br
--  Chinese (simplified)  / zh(s) / chi(s)
--  Chinese (traditional) / zh(s) / chi(s)
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
-- ]=] .. '\n' ..

'language = [['.. config_values.language ..']]' .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Audio global on/off switch.
-- Note that audio will also be disabled if CorsixTH was compiled without the
-- SDL_mixer library.
-- ]=] .. '\n' ..
'audio = '.. tostring(config_values.audio) .. '\n' .. [=[

--------------------------------------------- CUSTOM GAME MENU ----------------------------------------------
-- These settings can also be changed from the opening menu screen in the custom games menu
-------------------------------------------------------------------------------------------------------------------------
-- Free Build or Sandbox mode
-- You cannot win or lose custom made maps if this is set to true.
-- You also don't have to worry about money.
-- This setting does not apply to any of the campaign maps.
-- ]=] .. '\n' ..
'free_build_mode = ' .. tostring(config_values.free_build_mode) .. '\n' .. [=[

----------------------------------------------- OPTIONS MENU ---------------------------------------------------
--These settings can also be changed from within the game from the options menu
-------------------------------------------------------------------------------------------------------------------------
-- Sounds: By default enabled and set at level 0.5
-- ]=] .. '\n' ..
'play_sounds = ' .. tostring(config_values.play_sounds) .. '\n' ..
'sound_volume = ' .. tostring(config_values.sound_volume) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Announcements: By default set at level 0.5
-- ]=] .. '\n' ..
'play_announcements = ' .. tostring(config_values.play_announcements) .. '\n' ..
'announcement_volume = ' .. tostring(config_values.announcement_volume) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Background music: By default enabled and set at level 0.5
-- ]=] .. '\n' ..
'play_music = ' .. tostring(config_values.play_music) .. '\n' ..
'music_volume = ' .. tostring(config_values.music_volume) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Edge scrolling: By default enabled (prevent_edge_scrolling = false).
-- ]=] .. '\n' ..
'prevent_edge_scrolling = ' .. tostring(config_values.prevent_edge_scrolling) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Capture mouse: By default enabled (capture mouse = true).
-- ]=] .. '\n' ..
'capture_mouse = ' .. tostring(config_values.capture_mouse) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Adviser on/off: If you set this to true the adviser will no longer
-- pop up.
-- ]=] .. '\n' ..
'adviser_disabled = ' .. tostring(config_values.adviser_disabled) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Scrolling Momentum.
-- Determines the amount of momentum when scrolling the map with the mouse.
-- This should be a value between 0 and 1 where 0 is no momentum
-- ]=] .. '\n' ..
'scrolling_momentum = ' .. tostring(config_values.scrolling_momentum) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Top menu clock is by default is always on
-- setting to true will give you a twentyfour hours display
-- change to false if you want AM / PM time displayed.
-- ]=] .. '\n' ..
'twentyfour_hour_clock = ' .. tostring(config_values.twentyfour_hour_clock) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Automatically check for updates.
-- If set to true, CorsixTH will automatically check for and alert you to newer
-- versions on startup.
-- ]=] .. '\n' ..
'check_for_updates = ' .. tostring(config_values.check_for_updates) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Warmth Colors display settings.
-- This specifies which display method is set for warmth colours by default.
-- Possible values: 1 (Red), 2 (Blue Green Red) and 3 (Yellow Orange Red).
-- ]=] .. '\n' ..
'warmth_colors_display_default = ' .. tostring(config_values.warmth_colors_display_default) .. '\n' .. [=[

--------------------------------------------- CUSTOMISE SETTINGS --------------------------------------------
-- These settings can also be changed from the Customise Menu

-------------------------------------------------------------------------------
-- Wage increase request settings.
-- If set to true when wage increase requests expire automatically grant them
-- otherwise let the staff member quit.
-- ]=] .. '\n' ..
'grant_wage_increase = ' .. tostring(config_values.grant_wage_increase) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Movie global on/off switch.
-- Note that movies will also be disabled if CorsixTH was compiled without the
-- FFMPEG library.
-- ]=] .. '\n' ..
'movies = ' .. tostring(config_values.movies) .. '\n' .. [=[

-- Intro movie: By default enabled
-- ]=] .. '\n' ..
'play_intro = ' .. tostring(config_values.play_intro) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Allow user actions while game is paused
-- In Theme Hospital the player would only be allowed to use the top menu if
-- the game was paused. That is the default setting in CorsixTH too, but by
-- setting this to true everything is allowed while the game is paused.
-- ]=] .. '\n' ..
'allow_user_actions_while_paused = ' .. tostring(config_defaults.allow_user_actions_while_paused) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- VOLUME CONTROL IS OPENING THE DRUG CASEBOOK?

-- If your keyboard volume control opens the Drug Casebook at the same time
-- then change this to true.  From then on you will have to use Shift + C to open
-- the Casebook and volume down will not open it.
-- For example for shift + C to open casebook change the setting below to = true
-- ]=] .. '\n' ..
'volume_opens_casebook = ' .. tostring(config_values.volume_opens_casebook) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- To allow patients with Alien DNA to visit your hospital other than by an emergency change
-- the settings below.  Understand that there are no animations for sitting down, opening
-- or knocking on doors etc.
-- So, like with Theme Hospital to do these things they will appear to change to normal
-- looking and then change back.
-- ]=] .. '\n' ..
'alien_dna_only_by_emergency = ' .. tostring(config_values.alien_dna_only_by_emergency) .. '\n' ..
'alien_dna_must_stand = ' .. tostring(config_values.alien_dna_must_stand) .. '\n' ..
'alien_dna_can_knock_on_doors = ' .. tostring(config_values.alien_dna_can_knock_on_doors) .. '\n' .. [=[

-- To allow female patients with fractured bones, which are by default disabled due to poor
-- animation that skips and jumps a bit
-- ]=] .. '\n' ..
'disable_fractured_bones_females = ' .. tostring(config_values.disable_fractured_bones_females) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- By default the player selects any extra objects they want for each room they build.
-- If you would like the game to remember what you usually add, then change this option to true.
-- ]=] .. '\n' ..
'enable_avg_contents = ' .. tostring(config_values.enable_avg_contents) .. '\n' .. [=[

----------------------------------------------- FOLDER SETTINGS ----------------------------------------------
-- These settings can also be changed from the Folders Menu
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-- Theme hospital install folder: original game data files are loaded from this
-- folder. Between the square braces should be the folder which contains the
-- original HOSPITAL.EXE and/or HOSP95.EXE file. This can point to a copy of
-- the Theme Hospital demo, though a full install of the original game is
-- preferred.
-- ]=] .. '\n' ..
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
-- High quality (MP3 rather than MIDI) audio replacements.
-- If you want to listen to high quality MP3 audio rather than the original XMI
-- (MIDI) audio, then follow these steps:
--  1) Find MP3 versions of the original tracks (for example the remixes by ZR
--     from http://www.a-base.dds.nl/temp/ThemeHospital_ZRRemix.zip ) or any
--     other music you want to listen to.
--  2) Ensure that SMPEG.dll (or equivalent for your platform) is present.
--  3) Uncomment the next line and point it to where the mp3s are.
--  4) If you want to change the names of songs ingame, make a file called
--     "names.txt" and write the file name on one row, followed by the desired
--     ingame name on the next row.
--
audio_mp3 = nil -- [[X:\ThemeHospital\Music]]

 ----------------------------------------------- SPECIAL SETTINGS ----------------------------------------------
-- These settings can only be changed here
-------------------------------------------------------------------------------------------------------------------------
-- Audio playback settings.
-- These can be commented out to use the default values from the game binary.
-- Note: On some platforms, these settings may not effect MIDI playback - only
-- sound effects and MP3 audio. If you are experiencing poor audio playback,
-- then try doubling the buffer size.
-- ]=] .. '\n' ..
'audio_frequency = ' .. tostring(config_values.audio_frequency) .. '\n' ..
'audio_channels = ' .. tostring(config_values.audio_channels) .. '\n' ..
'audio_buffer_size = ' .. tostring(config_values.audio_buffer_size) .. '\n' .. [=[

 ------------------------------------------------------------------------------------------------------------------------

-- Debug settings.
-- If set to true more detailed information will be printed in the terminal
-- and a debug menu will be visible.
-- ]=] .. '\n' ..
'debug = ' .. tostring(config_values.debug) .. '\n' .. [=[

--Optional settings for CorsixTH's Lua DBGp client.
--Default settings are nil values, platform & workingdir will be autodected if nil.
--https://wiki.eclipse.org/LDT/User_Area/User_Guides/User_Guide_1.2#Attach_session
-- ]=] .. '\n' ..
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
-- ]=] .. '\n' ..
'track_fps = ' .. tostring(config_values.track_fps) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Zoom Speed: By default this is set at 80
-- Any number value between 10 and 1000, 10 is very slow and 1000 is very fast!
-- ]=] .. '\n' ..
'zoom_speed = ' .. tostring(config_values.zoom_speed) .. '\n' .. [=[

-------------------------------------------------------------------------------------------------------------------------
-- Scroll Speeds: The speed of scrolling with and without shift being held.
-- Any number value between 1 and 10, 1 is very slow and 10 is fast!
-- ]=] .. '\n' ..
'scroll_speed = ' .. tostring(config_values.scroll_speed) .. '\n' ..
'shift_scroll_speed = ' .. tostring(config_values.shift_scroll_speed) .. '\n' .. [=[

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

]=])
    fi:close()
  end
end

return config_filename, config_values
