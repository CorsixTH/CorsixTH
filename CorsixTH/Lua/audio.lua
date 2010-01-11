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

class "Audio"

function Audio:Audio(app)
  self.app = app
  self.background_playlist = {
    -- {title = "", filename = "", enabled = true, music = nil},
  }
  self.has_bg_music = false
  self.not_loaded = not app.config.audio
  self.bg_music_volume = 0.5
  self.announcement_volume = 0.5
  self.sound_volume = 0.5
  self.play_sounds = true
  self.play_announcements = true
end

local function linepairs(filename)
  local lines = io.lines(filename)
  local iterator
  iterator = function()
    local first, second
    repeat
      first = lines()
      if not first then return end
      first = first:gsub("[\r\n]", "")
      second = lines()
      if not second then return end
      second = second:gsub("[\r\n]", "")
    until #first > 2 and #second > 2
    return first, second
  end
  return iterator
end

function Audio:init()
  if self.not_loaded then
    return
  end
  local sound_dir = self.app.data_dir_map.SOUND
  if not sound_dir or not SDL.audio.loaded then
    if not sound_dir then
      print "Notice: Audio system not loaded as no SOUND directory found"
    else
      print "Notice: Audio system not loaded as CorsixTH compiled without it"
    end
    self.not_loaded = true
    return
  end
  sound_dir = self.app.config.theme_hospital_install .. sound_dir .. pathsep
  local mp3 = self.app.config.audio_mp3
  local subdirs = {
    DATA = false,
    MIDI = false,
  }
  for item in lfs.dir(sound_dir) do
    if subdirs[item:upper()] ~= nil then
      subdirs[item:upper()] = item
    end
  end
  if subdirs.MIDI == false then
    print "Notice: No background music as no SOUND/MIDI directory found"
  else
    local midi_dir = sound_dir .. subdirs.MIDI .. pathsep
    local musicArray = {}
    local function musicFileTable(filename)
      local t = musicArray[filename:upper()]
      if t == nil then
        t = {}
        musicArray[filename:upper()] = t
      end
      return t
    end
    
    
    --[[
      Find the music files on disk.
      -----------------------------
        
      - Will search through all the files in midi_dir.
      - Adds xmi and mp3 files.
      - If ATLANTIS.XMI and ATLANTIS.MP3 exists, the MP3 is preferred.
      - Uses titles from MIDI.TXT if found, else the filename.
    --]]
    local midi_txt = ''      -- File name of midi.txt file, if any.
    local mp3 = true         -- Yes, do load mp3 files.
    
    for foundFile in lfs.dir(midi_dir) do
      -- Music file found (mp3/xmi).
      if (mp3 and foundFile:upper():match"%.MP3$") or (foundFile:upper():match"%.XMI$") then
        -- Extract only the base name of the file ("ATLANTIS" instead of "ATLANTIS.XMI")
        local foundFile_filenameBase = foundFile:sub( 0, foundFile:find(".", 1, true)-1 )
        -- Make one version uppercase
        local foundFile_filenameBase_upper = foundFile_filenameBase:upper()
      
        if (foundFile:upper():match"%.MP3$") then
           musicFileTable(foundFile_filenameBase_upper).filename_mp3 = midi_dir .. foundFile
           -- Remove the xmi version of this file, if found.
           if musicFileTable(foundFile_filenameBase_upper).filename then
             musicFileTable(foundFile_filenameBase_upper).filename = nil
           end
           -- If the mp3 version exists
        elseif foundFile:upper():match"%.XMI$" and 
          not musicFileTable(foundFile_filenameBase_upper).filename_mp3 then
          musicFileTable(foundFile_filenameBase_upper).filename = midi_dir .. foundFile -- ignore this file
        end
        -- This title might be replaced later by the midi_txt.
        musicFileTable(foundFile_filenameBase_upper).title = foundFile_filenameBase
      elseif foundFile:upper():match"^MIDI.*%.TXT$" then -- Looks like the midi.txt.
        -- Remember it for later.
        midi_txt = foundFile                                    
      end
    end
      
    -- Enable music files and add them to the playlist.
    for filename, musicData in pairs(musicArray) do
      musicData.enabled = true
      self.background_playlist[#self.background_playlist + 1] = musicData
    end
      
    -- This is later. If we found a midi.txt, go through it and add the titles to the files we know
    if midi_txt:len() > 0 then
      for name, title in linepairs(midi_dir .. midi_txt) do
        local filename = name:sub( 0, name:find(".", 1, true)-1 )
        if next(musicFileTable(filename:upper())) ~= nil then
           musicFileTable(filename:upper()).title = title
        else
          print(" ")
          print(('Notice: Background track "%s" named in list file, but it '..
            'does not exist. '):format(filename))
          print(" ")
        end
      end
    end
    if #self.background_playlist == 0 then
      print "Notice: Audio system loaded, but found no background MIDI tracks"
    else
      table.sort(self.background_playlist, function(left, right)
        return left.title:lower() < right.title:lower()
      end)
      self.has_bg_music = true
    end
  end
  
  local status, err = SDL.audio.init(self.app.config.audio_frequency,
    self.app.config.audio_channels, self.app.config.audio_buffer_size)
  if status then
    self:playRandomBackgroundTrack()
  else
    print("Notice: Audio system could not initialise (SDL error: " .. tostring(err) .. ")")
    self.not_loaded = true
    self.has_bg_music = false
    self.background_playlist = {}
    return
  end
  
  if subdirs.DATA == false then
    print "Notice: No sound effects as no SOUND/DATA directory found"
  else
    local data_dir = sound_dir .. subdirs.DATA .. pathsep
    local sound_file = "SOUND-" .. self.app.config.language .. ".DAT"
    local archive_name
    local function find_sound_file(dir, file)
      for item in lfs.dir(dir) do
        if item:upper() == file then
          return item
        end
      end
    end
    
    archive_name = find_sound_file(data_dir, sound_file)
    
    -- If sound file not found and language choosen is not English, 
    -- maybe we can have more chance loading English sounds
    if not archive_name and self.app.config.language ~= "0" then
      print("Notice: Attempt to load English sounds as no SOUND/DATA/" .. sound_file .. " file found")        
      archive_name = find_sound_file(data_dir, "SOUND-0.DAT")
    end
    
    if not archive_name then
      print("Notice: No sound effects as no SOUND/DATA/" .. sound_file .. " file found")
    else
      local file = assert(io.open(data_dir .. archive_name, "rb"))
      local data = file:read"*a"
      file:close()
      if data:sub(1, 3) == "RNC" then
        data = assert(rnc.decompress(data))
      end
      self.sound_archive = TH.soundArchive()
      if not self.sound_archive:load(data) then
        print("Notice: No sound effects as SOUND/DATA/" .. sound_file .. " could not be loaded")
      else
        self.sound_fx = TH.soundEffects()
        self.sound_fx:setSoundArchive(self.sound_archive)
        local w, h = self.app.config.width / 2, self.app.config.height / 2
        self.sound_fx:setCamera(w, h, (w^2 + h^2)^0.5)
        --self:dumpSoundArchive[[E:\CPP\2K8\CorsixTH\DataRaw\Sound\]]
      end
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

function Audio:playSound(name, where, is_announcement)
  local sound_fx = self.sound_fx
  if sound_fx then
    local _, warning
    local volume = is_announcement and self.announcement_volume or self.sound_volume
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
    -- SDL doesn't seeem to support pausing/resuming for this format/driver,
    -- so just stop the music instead.
    self:stopBackgroundTrack()
  else
    -- SDL can also be odd and report music as paused even though it is still
    -- playing. If it really is paused, then there is no harm in muting it.
    -- If it wasn't really paused, then muting it is the next best thing that
    -- we can do (even though it'll continue playing).
    if self.background_paused then
      self.old_bg_music_volume = self.bg_music_volume
      self.bg_music_volume = 0
      SDL.audio.setMusicVolume(0)
    else
      self.bg_music_volume = self.old_bg_music_volume
      SDL.audio.setMusicVolume(self.old_bg_music_volume)
      self.old_bg_music_volume = nil
    end
  end

  self:notifyJukebox()
end

function Audio:stopBackgroundTrack()
  if self.background_paused then
    -- unpause first in order to clear the backupped volume
    self:pauseBackgroundTrack()
  end
  SDL.audio.stopMusic()
  self.background_music = nil

  self:notifyJukebox()
end

function Audio:playBackgroundTrack(index)
  local info = self.background_playlist[index]
  assert(info, "Index not valid")
  local music = info.music
  if not music then
    local file = assert(io.open(info.filename_mp3 or info.filename, "rb"))
    local data = file:read"*a"
    file:close()
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
  SDL.audio.setMusicVolume(self.bg_music_volume)
  assert(SDL.audio.playMusic(music))
  self.background_music = music
  
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
    self.bg_music_volume = volume
    SDL.audio.setMusicVolume(volume)
  end
end

function Audio:setSoundVolume(volume)
  self.sound_volume = volume
  if self.sound_fx then
    -- Since some sounds are played automatically (using computers etc)
    -- we need to set a value on C level too.
    self.sound_fx:setSoundVolume(volume)
  end
end

function Audio:playSoundEffects(play_effects)
  self.play_sounds = play_effects
  if self.sound_fx then
    -- As above.
    self.sound_fx:setSoundEffectsOn(play_effects)
  end
end

function Audio:setAnnouncementVolume(volume)
  self.announcement_volume = volume
end

-- search for jukebox and notify it to update its play button
function Audio:notifyJukebox()
  local jukebox = self.app.ui:getWindow(UIJukebox)
  if jukebox then
    jukebox:updatePlayButton()
  end
end
