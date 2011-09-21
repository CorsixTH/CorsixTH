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
      config_name = config_path:match("([^".. pathsep .."]*)$")
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
  theme_hospital_install = [[F:\ThemeHospital\hospital]],
  language = [[English]],
  width = 800,
  height = 600,
  fullscreen = false,
  audio = true,
  audio_frequency = 22050,
  audio_channels = 2,
  audio_buffer_size = 2048,
  debug = false,
  track_fps = false,
  prevent_edge_scrolling = false,
  play_music = true,
  music_volume = 0.5,
  play_announcements = true,
  announcement_volume = 0.5,
  play_sounds = true,
  sound_volume = 0.5,
}
local fi = io.open(config_filename, "r")
if fi then
  fi:close()
else
  fi = io.open(config_filename, "w")
  if fi then
    fi:write([=[
---- CorsixTH configuration file ----------------------------------------------
-- Lines starting with two dashes (like this one) are ignored.
-- Text settings should have their values between double square braces, e.g.
--  setting = [[value]]
-- Number settings should not have anything around their value, e.g.
--  setting = 42

-------------------------------------------------------------------------------
-- Theme hospital install folder: original game data files are loaded from this
-- folder. Between the square braces should be the folder which contains the
-- original HOSPITAL.EXE and/or HOSP95.EXE file. This can point to a copy of
-- the Theme Hospital demo, though a full install of the original game is
-- preferred.
theme_hospital_install = [[]=].. config_defaults.theme_hospital_install ..[=[]]
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Theme hospital option settings
--
-- Edge scrolling: By default enabled (prevent_edge_scrolling = false).
prevent_edge_scrolling = ]=].. tostring(config_defaults.prevent_edge_scrolling) ..[=[ 
--
-- Background music: By default disabled at level 0.5
play_music = ]=].. tostring(config_defaults.play_music) ..[=[ 
music_volume = ]=].. tostring(config_defaults.music_volume) ..[=[ 
--
-- Announcements: By default enabled at level 0.5
play_announcements = ]=].. tostring(config_defaults.play_announcements) ..[=[ 
announcement_volume = ]=].. tostring(config_defaults.announcement_volume) ..[=[ 
--
-- Sounds: By default enabled at level 0.5
play_sounds = ]=].. tostring(config_defaults.play_sounds) ..[=[ 
sound_volume = ]=].. tostring(config_defaults.sound_volume) ..[=[ 
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Language to use for ingame text. Between the square braces should be one of:
--  Chinese (simplified)  / zh(s) / chi(s)
--  Chinese (traditional) / zh(s) / chi(s)
--  Danish                / da / dk
--  Dutch                 / Nederlands / nl / dut / nld
--  English               / en / eng
--  Finnish               / Suomi / fi / fin
--  French                / fr / fre / fra
--  German                / de / ger / deu
--  Italian               / it / ita
--  Norwegian             / nb / nob
--  Portuguese            / pt / por
--  Russian               / ru / rus
--  Spanish               / es / spa
--  Swedish               / sv / swe

language = [[]=].. config_defaults.language ..[=[]]
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Screen size. Must be at least 640x480. Larger sizes will require better
-- hardware in order to maintain a playable framerate. The fullscreen setting
-- can be true or false, and the game will run windowed if not fullscreen.
width = ]=].. tostring(config_defaults.width) ..[=[ 
height = ]=].. tostring(config_defaults.height) ..[=[ 
fullscreen = ]=].. tostring(config_defaults.fullscreen) ..[=[ 
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Savegames. By default, the "Saves" directory alongside this config file will
-- be used for storing saved games in. Should this not be suitable, then
-- uncomment the following line, and point it to a directory which exists and
-- is more suitable.
-- savegames = [[C:\CorsixTH\Savegames]]
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Audio global on/off switch.
-- Note that audio will also be disabled if CorsixTH was compiled without the
-- SDL_mixer library.
audio = ]=].. tostring(config_defaults.audio) ..[=[ 
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Audio playback settings.
-- These can be commented out to use the default values from the game binary.
-- Note: On some platforms, these settings may not effect MIDI playback - only
-- sound effects and MP3 audio. If you are experiencing poor audio playback,
-- then try doubling the buffer size.
audio_frequency = ]=].. tostring(config_defaults.audio_frequency) ..[=[ 
audio_channels = ]=].. tostring(config_defaults.audio_channels) ..[=[ 
audio_buffer_size = ]=].. tostring(config_defaults.audio_buffer_size) ..[=[ 
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- High quality (MP3 rather than MIDI) audio replacements.
-- If you want to listen to high quality MP3 audio rather than the original XMI
-- (MIDI) audio, then follow these steps:
--  1) Find MP3 versions of the original tracks (for example the remixes by ZR
--     from http://www.mobstar.biz/openTH/forums/viewtopic.php?t=77 ) or any
--     other music you want to listen to.
--  2) Ensure that SMPEG.dll (or equivalent for your platform) is present.
--  3) Uncomment the next line and point it to where the mp3s are. 
--  4) If you want to change the names of songs ingame, make a file called 
--     "names.txt" and write the file name on one row, followed by the desired
--     ingame name on the next row.
-- audio_mp3 = [[X:\ThemeHospital\Music]]
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Debug settings.
-- If set to true more detailed information will be printed in the terminal
-- and a debug menu will be visible.
debug = ]=].. tostring(config_defaults.debug) ..[=[ 
-- If set to true, the FPS, Lua memory usage, and entity count will be shown
-- in the dynamic information bar. Note that setting this to true also turns
-- off the FPS limiter, causing much higher CPU utilisation, but resulting in
-- more useful FPS values, as they are not artificially capped.
track_fps = ]=].. tostring(config_defaults.track_fps) ..[=[ 
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Font file setting.
-- Specify a font file here if you wish to play the game in a language not
-- present in the original game. Examples include Russian, Chinese and Polish.
-- unicode_font = [[X:\ThemeHospital\font.ttc]] 
-------------------------------------------------------------------------------
]=])
  end
end

return config_filename, config_defaults
