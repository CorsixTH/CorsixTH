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
local SDL = require "sdl"
local TH = require "TH"
local ipairs
    = ipairs

--! Layer which handles the Lua-facing side of loading and playing audio.
class "Audio"

function Audio:Audio(app)
  self.app = app
  self.background_playlist = {
    -- {title = "", filename = "", enabled = true, music = nil},
  }
  self.has_bg_music = false
  self.not_loaded = not app.config.audio
end

local function GetFileData(path)
  local f, e = io.open(path, "rb")
  if not f then
    return f, e
  end
  e = f:read"*a"
  f:close()
  return e
end

function Audio:init()
  if self.not_loaded then
    return
  end
  if not SDL.audio.loaded then
    print "Notice: Audio system not loaded as CorsixTH compiled without it"
    self.not_loaded = true
    return
  end
  local mp3 = self.app.config.audio_mp3
  local music_dir
  if mp3 then
    music_dir = mp3
    if music_dir:sub(-1) ~= pathsep then
      music_dir = music_dir .. pathsep
    end
  end

  local music_array = {}
  local function musicFileTable(filename)
    filename = filename:upper()
    local t = music_array[filename]
    if t == nil then
      t = {}
      music_array[filename] = t
    end
    return t
  end
    
  --[[
    Find the music files on disk.
    -----------------------------
      
    - Will search through all the files in music_dir.
    - Adds xmi and mp3 files.
    - If ATLANTIS.XMI and ATLANTIS.MP3 exists, the MP3 is preferred.
    - Uses titles from MIDI.TXT if found, else the filename.
  --]]
  local midi_txt -- File name of midi.txt file, if any.
  
  local _f, _s, _v
  if music_dir then
    _f, _s, _v = lfs.dir(music_dir)
  else
    _f, _s, _v = pairs(self.app.fs:listFiles("Sound", "Midi") or {})
  end
  for file in _f, _s, _v do
    local filename, ext = file:match"^(.*)%.([^.]+)$"
    ext = ext and ext:upper()
    -- Music file found (mp3/xmi).
    if ext == "MP3" or ext == "XMI" then  
      local info = musicFileTable(filename)
      info.title = filename
      if ext == "MP3" then
        if music_dir then
          info.filename_mp3 = music_dir .. file
        else
          print("Warning: CorsixTH only supports xmi if audio_mp3"
            .. " is not defined in the config file.")
            music_array[filename:upper()] = nil
        end
         -- Remove the xmi version of this file, if found.
         info.filename = nil
      elseif ext == "XMI" and not info.filename_mp3 then
        -- NB: If the mp3 version exists, this file is ignored
        info.filename = table.concat({"Sound", "Midi", file}, pathsep)
      end
      -- This title might be replaced later by the midi_txt.
    elseif ext == "TXT" and (file:sub(1, 4):upper() == "MIDI" or
                             file:sub(1, 5):upper() == "NAMES") then
      -- If it Looks like the midi.txt or equiv, then remember it for later.
      midi_txt = file                                    
    end
  end
    
  -- Enable music files and add them to the playlist.
  for _, info in pairs(music_array) do
    info.enabled = true
    self.background_playlist[#self.background_playlist + 1] = info
  end
    
  -- This is later. If we found a midi.txt, go through it and add the titles to the files we know
  if midi_txt then
    local data
    if music_dir then
      data = assert(GetFileData(music_dir .. midi_txt))
    else
      data = assert(self.app.fs:readContents("Sound", "Midi", midi_txt))
    end
    for file, title in data:gmatch"([^\r\n\26]+).-([^\r\n\26]+)" do
      local info = musicFileTable(file:match"^(.*)%." or file)
      if next(info) ~= nil then
        info.title = title
      else
        print('Notice: Background track "'.. file ..'" named in list file, '..
              'but it does not exist.')
      end
    end
  end
  if #self.background_playlist == 0 then
    print "Notice: Audio system loaded, but found no background tracks"
  else
    table.sort(self.background_playlist, function(left, right)
      return left.title:upper() < right.title:upper()
    end)
    self.has_bg_music = true
  end
  
  local status, err = SDL.audio.init(self.app.config.audio_frequency,
    self.app.config.audio_channels, self.app.config.audio_buffer_size)
  if status then
    -- Start playing unless the configuration says otherwise.
    if self.app.config.play_music then
      self:playRandomBackgroundTrack()
    end
  else
    print("Notice: Audio system could not initialise (SDL error: " .. tostring(err) .. ")")
    self.not_loaded = true
    self.has_bg_music = false
    self.background_playlist = {}
    return
  end
end

function Audio:initSpeech(speech_file)
  if self.not_loaded then
    return
  end
  
  local function load_sound_file(file)
    return self.app.fs:readContents("Sound", "Data", file)
  end

  speech_file = speech_file or "Sound-0.dat"
  if self.speech_file_name == speech_file then
    return
  end
  local archive_data, err = load_sound_file(speech_file)
  
  -- If sound file not found and language choosen is not English, 
  -- maybe we can have more chance loading English sounds
  if not archive_data and speech_file ~= "Sound-0.dat" then
    if self.speech_file_name == "Sound-0.dat" then
      return
    end
    print("Notice: Attempt to load English sounds as no SOUND/DATA/" .. speech_file .. " file found")
    speech_file = "Sound-0.dat"
    archive_data = load_sound_file(speech_file)
  end
  
  if not archive_data then
    print("Notice: No sound effects as no SOUND/DATA/".. speech_file ..
          " file could be found / opened. The reported error was:\n".. err)
  else
    if archive_data:sub(1, 3) == "RNC" then
      archive_data = assert(rnc.decompress(archive_data))
    end
    self.sound_archive = TH.soundArchive()
    if not self.sound_archive:load(archive_data) then
      print("Notice: No sound effects as SOUND/DATA/" .. speech_file .. " could not be loaded")
      if #self.background_playlist == 0 then 
        self.not_loaded = true
      end
    else
      self.speech_file_name = speech_file
      self.sound_fx = TH.soundEffects()
      self.sound_fx:setSoundArchive(self.sound_archive)
      local w, h = self.app.config.width / 2, self.app.config.height / 2
      self.sound_fx:setCamera(w, h, (w^2 + h^2)^0.5)
      --self:dumpSoundArchive[[E:\CPP\2K8\CorsixTH\DataRaw\Sound\]]
    end
  end
end

function Audio:dumpSoundArchive(out_dir)
  local info = io.open(out_dir .. "info.csv", "wt")
  for i = 1, #self.sound_archive - 1 do
    local filename = self.sound_archive:getFilename(i)
    info:write(i, ",", filename, ",", self.sound_archive:getDuration(i), ",\n")
    local file = io.open(out_dir .. i .. "_" .. filename, "wb")
    file:write(self.sound_archive:getFileData(i))
    file:close()
  end
  info:close()
end

local wilcard_cache = permanent "audio_wildcard_cache" {}

function Audio:playSound(name, where, is_announcement)
  local sound_fx = self.sound_fx
  if sound_fx then
    if name:find("*") then
      -- Resolve wildcard to one particular sound
      local list = wilcard_cache[name]
      if not list then
        list = {}
        wilcard_cache[name] = list
        local pattern = ("^" .. name:gsub("%*",".*") .. "$"):upper()
        for i = 1, #self.sound_archive - 1 do
          local filename = self.sound_archive:getFilename(i):upper()
          if filename:find(pattern) then
            list[#list + 1] = filename
          end
        end
      end
      name = list[1] and list[math.random(1, #list)] or name
    end
    local _, warning
    local volume = is_announcement and self.app.config.announcement_volume or self.app.config.sound_volume
    if where then
      local x, y = Map:WorldToScreen(where.tile_x, where.tile_y)
      local dx, dy = where.th:getPosition()
      local ui = self.app.ui
      x = x + dx - ui.screen_offset_x
      y = y + dy - ui.screen_offset_y
      _, warning = sound_fx:play(name, volume, x, y)
    else
      _, warning = sound_fx:play(name, volume)
    end
    if warning then
      print("Audio:playSound - Warning: " .. warning)
    end
  end
end

function Audio:playRandomBackgroundTrack()
  if self.not_loaded or #self.background_playlist == 0 then
    return
  end
  local enabled = {}
  for i, info in ipairs(self.background_playlist) do
    if info.enabled then
      enabled[#enabled + 1] = i
    end
  end
  if not enabled[1] then
    return
  end
  local index = enabled[math.random(1, #enabled)]
  self:playBackgroundTrack(index)
end

function Audio:findIndexOfCurrentTrack()
  for i, info in ipairs(self.background_playlist) do
    if info.music == self.background_music then
      return i
    end
  end
  
  return 1
end

function Audio:playNextOrPreviousBackgroundTrack(direction)
  if self.not_loaded or #self.background_playlist == 0 then
    return
  end
  
  if not self.background_music then
    self:playRandomBackgroundTrack()
    return
  end
  
  local index = self:findIndexOfCurrentTrack()
  
  -- Find next/previous track
  for i = 1, #self.background_playlist do
    i = ((index + direction * i - 1) % #self.background_playlist) + 1
    if self.background_playlist[i].enabled then
      self:playBackgroundTrack(i)
      return
    end
  end
end

function Audio:playNextBackgroundTrack()
  self:playNextOrPreviousBackgroundTrack(1)
end

function Audio:playPreviousBackgroundTrack()
  self:playNextOrPreviousBackgroundTrack(-1)
end

function Audio:pauseBackgroundTrack()
  assert(self.background_music, "Trying to pause music while music is stopped")
  local status
  if self.background_paused then
    self.background_paused = nil
    status = SDL.audio.resumeMusic()
  else
    status = SDL.audio.pauseMusic()
    self.background_paused = true
  end
  
  -- NB: Explicit false check, as old C side returned nil in all cases
  if status == false then
    -- SDL doesn't seem to support pausing/resuming for this format/driver,
    -- so just stop the music instead.
    self:stopBackgroundTrack()
  else
    -- SDL can also be odd and report music as paused even though it is still
    -- playing. If it really is paused, then there is no harm in muting it.
    -- If it wasn't really paused, then muting it is the next best thing that
    -- we can do (even though it'll continue playing).
    if self.background_paused then
      self.old_bg_music_volume = self.app.config.music_volume
      SDL.audio.setMusicVolume(0)
    else
      self.app.config.music_volume = self.old_bg_music_volume
      SDL.audio.setMusicVolume(self.old_bg_music_volume)
      self.old_bg_music_volume = nil
    end
  end
  -- Update configuration that we don't want music
  self.app.config.play_music = false
  self:notifyJukebox()
end

function Audio:stopBackgroundTrack()
  if self.background_paused then
    -- unpause first in order to clear the backupped volume
    self:pauseBackgroundTrack()
  end
  SDL.audio.stopMusic()
  self.background_music = nil
  -- Update configuration that we don't want music
  self.app.config.play_music = false
  self:notifyJukebox()
end

function Audio:playBackgroundTrack(index)
  local info = self.background_playlist[index]
  assert(info, "Index not valid")
  local music = info.music
  if not music then
    local data
    if info.filename_mp3 then
      data = assert(GetFileData(info.filename_mp3))
    else
      data = assert(self.app.fs:readContents(info.filename))
    end
    if data:sub(1, 3) == "RNC" then
      data = assert(rnc.decompress(data))
    end
    if not info.filename_mp3 then
      data = SDL.audio.transcodeXmiToMid(data)
    end
    -- Loading of music files can incur a slight pause, which is why it is
    -- done asynchronously.
    SDL.audio.loadMusicAsync(data, function(music, e)
      if music == nil then
        error("Could not load music file \'" .. (info.filename_mp3 or info.filename) .. "\'"
          .. (e and (" (" .. e .. ")" or "")))
      else
        if _DECODA then
          debug.getmetatable(music).__tostring = function(ud)
            return debug.getfenv(ud).tostring
          end
          debug.getfenv(music).tostring = "Music <".. info.filename .. ">"
        end
        info.music = music
        return self:playBackgroundTrack(index)
      end
    end)
    return
  end
  SDL.audio.setMusicVolume(self.app.config.music_volume)
  assert(SDL.audio.playMusic(music))
  self.background_music = music
  -- Update configuration that we want music
  self.app.config.play_music = not not self.background_music
  self:notifyJukebox()
end

function Audio:onMusicOver()
  if self.not_loaded or #self.background_playlist == 0 then
    return
  end
  self:playNextBackgroundTrack()
end

function Audio:setBackgroundVolume(volume)
  if self.background_paused then
    self.old_bg_music_volume = volume
  else
    self.app.config.music_volume = volume
    SDL.audio.setMusicVolume(volume)
  end
end

function Audio:setSoundVolume(volume)
  self.app.config.sound_volume = volume
  if self.sound_fx then
    -- Since some sounds are played automatically (using computers etc)
    -- we need to set a value on C level too.
    self.sound_fx:setSoundVolume(volume)
  end
end

function Audio:playSoundEffects(play_effects)
  self.app.config.play_sounds = play_effects
  if self.sound_fx then
    -- As above.
    self.sound_fx:setSoundEffectsOn(play_effects)
  end
end

function Audio:setAnnouncementVolume(volume)
  self.app.config.announcement_volume = volume
end

-- search for jukebox and notify it to update its play button
function Audio:notifyJukebox()
  local jukebox = self.app.ui:getWindow(UIJukebox)
  if jukebox then
    jukebox:updatePlayButton()
  end
end
