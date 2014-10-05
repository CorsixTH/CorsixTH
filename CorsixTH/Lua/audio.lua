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

  self.has_bg_music = false
  self.not_loaded = not app.config.audio
  self.unused_played_callback_id = 0
  self.played_sound_callbacks = {}
  self.entities_waiting_for_sound_to_be_enabled = {}
end

function Audio:clearCallbacks()
  self.unused_played_callback_id = 0
  self.played_sound_callbacks = {}
  self.entities_waiting_for_sound_to_be_enabled = {}
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
  self.background_playlist = {
    -- {title = "", filename = "", enabled = true, music = nil},
  }
  if self.not_loaded then
    return
  end
  if not SDL.audio.loaded then
    if not _MAP_EDITOR then
      print "Notice: Audio system not loaded as CorsixTH compiled without it"
    end
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
  if #self.background_playlist == 0 and self.app.good_install_folder then
    print "Notice: Audio system loaded, but found no background tracks"
    self.has_bg_music = false
  else
    table.sort(self.background_playlist, function(left, right)
      return left.title:upper() < right.title:upper()
    end)
    self.has_bg_music = true
  end

  local status, err = SDL.audio.init(self.app.config.audio_frequency,
    self.app.config.audio_channels, self.app.config.audio_buffer_size)
  if status then
    -- NB: Playback will not start if play_music is set to false
    self:playRandomBackgroundTrack()
  else
    print("Notice: Audio system could not initialise (SDL error: " .. tostring(err) .. ")")
    self.not_loaded = true
    self.has_bg_music = false
    self.background_playlist = {}
    return
  end
end

function Audio:initSpeech(speech_file)
  self.sound_archive = nil
  self.sound_fx = nil
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
  if not archive_data and speech_file ~= "Sound-0.dat" and self.app.good_install_folder then
    if self.speech_file_name == "Sound-0.dat" then
      return
    end
    print("Notice: Attempt to load English sounds as no SOUND/DATA/" .. speech_file .. " file found")
    speech_file = "Sound-0.dat"
    archive_data = load_sound_file(speech_file)
  end

  if not archive_data then
    if self.app.good_install_folder then
      print("Notice: No sound effects as no SOUND/DATA/".. speech_file ..
          " file could be found / opened.")
      print("The reported error was: ".. err)
    end
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
  local info,warning = io.open(out_dir .. "info.csv", "wt")

  if info == nil then
    print("Error: Audio dump failed because info.csv couldn't be created and/or opened in the dump directory:" .. out_dir)
    print(warning)
    return
  end

  for i = 1, #self.sound_archive - 1 do
    local filename = self.sound_archive:getFilename(i)
    info:write(i, ",", filename, ",", self.sound_archive:getDuration(i), ",\n")
    local file = io.open(out_dir .. i .. "_" .. filename, "wb")
    file:write(self.sound_archive:getFileData(i))
    file:close()
    print("".. i .. "/" .. #self.sound_archive - 1)
  end
  info:close()
  print("Sounds dumped to: " .. out_dir)
end

local wilcard_cache = permanent "audio_wildcard_cache" {}

function Audio:playSound(name, where, is_announcement, played_callback, played_callback_delay)
  local sound_fx = self.sound_fx
  if sound_fx then
    if name:find("*") then
      -- Resolve wildcard to one particular sound
      local list = self:cacheSoundFilenamesAssociatedWithName(name)
      name = list[1] and list[math.random(1, #list)] or name
    end
    local _, warning
    local volume = is_announcement and self.app.config.announcement_volume or self.app.config.sound_volume
    local x, y
    local played_callbacks_id
    if played_callback then
      played_callbacks_id = self.unused_played_callback_id
      self.unused_played_callback_id = self.unused_played_callback_id + 1
      self.played_sound_callbacks[tostring(played_callbacks_id)] = played_callback
    end
    if where then
      x, y = Map:WorldToScreen(where.tile_x, where.tile_y)
      local dx, dy = where.th:getPosition()
      local ui = self.app.ui
      x = x + dx - ui.screen_offset_x
      y = y + dy - ui.screen_offset_y
    end
    _, warning = sound_fx:play(name, volume, x, y, played_callbacks_id, played_callback_delay)

    if warning then
      -- Indicates something happened
      self.app.world:gameLog("Audio:playSound - Warning: " .. warning)
    end
  end
end

function Audio:cacheSoundFilenamesAssociatedWithName(name)
  local list = wilcard_cache[name]
  if not list then
    local filename
    list = {}
    wilcard_cache[name] = list
    local pattern = ("^" .. name:gsub("%*",".*") .. "$"):upper()
    for i = 1, #self.sound_archive - 1 do
      filename = self.sound_archive:getFilename(i):upper()
      if filename:find(pattern) then
        list[#list + 1] = filename
      end
    end
  end
  return list
end

--[[
Plays related sounds at an entity in a random sequence, with random length silences between the sounds.

This function's integer array parameters for the min and max silence lengths should provide lengths
for this game's different speeds, indexed as follows:
[1] Slowest [2] Slow [3] Normal [4] Fast [5] Maximum Speed

!param names (string) A name pattern for the sequence of related sounds to be played for example: LAVA00*.wav
!param entity : Where the sounds will be played at, the player won't hear the sounds being played at the entity
when it isn't in their view.
!param min_silence_lengths (integer array) The desired minimum silence lengths for this game's different speeds.
!param max_silence_lengths (integer array) The desired maximum silence lengths for this game's different speeds.
!param num_silences (integer) How many different silence lengths should be used, this can be a nil parameter.
--]]
function Audio:playSoundsAtEntityInRandomSequence(names, entity, min_silence_lengths, max_silence_lengths, num_silences)
  if self.sound_fx then
    self:cacheSoundFilenamesAssociatedWithName(names)
    self:playSoundsAtEntityInRandomSequenceRecursionHandler(wilcard_cache[names],
                                                            entity,
                                                            self:getRandomSilenceLengths(min_silence_lengths,
                                                                                         max_silence_lengths,
                                                                                         num_silences),
                                                            1)
  end
end

--[[
Called by the above function.

This function's integer array parameters for the min and max silence lengths should provide lengths
for this game's different speeds, indexed as follows:
[1] Slowest [2] Slow [3] Normal [4] Fast [5] Maximum Speed

!param sounds (string) A name pattern for the sequence of related sounds to be played for example: LAVA00*.wav
!param entity : Where the sounds will be played at, the player won't hear the sounds being played at the entity
when it isn't in their view.
!param silences (integer array) the different pause durations to be used between the played sounds.
!param silences_pointer (integer) the index for the pause duration which should be used after this call's sound has been played.
--]]
function Audio:playSoundsAtEntityInRandomSequenceRecursionHandler(sounds, entity, silences, silences_pointer)
  if entity.playing_sounds_in_random_sequence then
    local sound_played_callback = function()
                                    self:playSoundsAtEntityInRandomSequenceRecursionHandler(sounds,
                                                                                            entity,
                                                                                            silences,
                                                                                            silences_pointer)
                                  end

    if self:canSoundsBePlayed() then
      local _, warning
      local x, y = Map:WorldToScreen(entity.tile_x, entity.tile_y)
      local dx, dy = entity.th:getPosition()
      x = x + dx - self.app.ui.screen_offset_x
      y = y + dy - self.app.ui.screen_offset_y

      self.played_sound_callbacks[tostring(self.unused_played_callback_id)] = sound_played_callback
      _, warning = self.sound_fx:play(sounds[math.random(1,#sounds)],
                                      self.app.config.sound_volume,
                                      x,
                                      y,
                                      self.unused_played_callback_id,
                                      silences_pointer)

      self.unused_played_callback_id = self.unused_played_callback_id + 1
      if #silences > 1 then
        silences_pointer = (silences_pointer % #silences) + 1
      end
    --If the sound can't be played now:
    else
      self.entities_waiting_for_sound_to_be_enabled[entity] = sound_played_callback
	    entity:setWaitingForSoundEffectsToBeTurnedOn(true)
	  end
  else
    if self.entities_waiting_for_sound_to_be_enabled[entity] then
      self.entities_waiting_for_sound_to_be_enabled[entity] = nil
    end
  end
end

function Audio:canSoundsBePlayed()
  return TheApp.config.play_sounds and not TheApp.world:isPaused()
end

--[[
This function's integer array parameters for the min and max silence lengths should provide lengths
for this game's different speeds, indexed as follows:
[1] Slowest [2] Slow [3] Normal [4] Fast [5] Maximum

!param min_silence_lengths (integer array) The desired minimum silence lengths for this game's different speeds.
!param max_silence_lengths (integer array) The desired maximum silence lengths for this game's different speeds.
!param num_silences (integer) How many silence lengths should be in the returned table of generated lengths.
!return (table) A table of randomly ordered integers for the generated silence lengths.
--]]
function Audio:getRandomSilenceLengths(min_silence_lengths, max_silence_lengths, num_silences)
  local min_silence = min_silence_lengths[TheApp.world.tick_rate]
  local max_silence = max_silence_lengths[TheApp.world.tick_rate]

  local silences = {}
  if min_silence == max_silence then
    silences[1] = min_silence
  else
    for i = 1, num_silences do
      silences[i] = math.random(min_silence,max_silence)
    end
  end

  return silences
end

function Audio:onEndPause()
  if TheApp.config.play_sounds then
    self:tellInterestedEntitiesTheyCanNowPlaySounds()
  end
end

function Audio:onSoundPlayed(played_callbacks_id)
  if TheApp.world ~= nil then
    if self.played_sound_callbacks[tostring(played_callbacks_id)] then
      self.played_sound_callbacks[tostring(played_callbacks_id)]()
      self.played_sound_callbacks[tostring(played_callbacks_id)] = nil
    end
  end
end

--! Returns whether the given sound (either a string or a number)
--! exists in the sound archive
--!param sound The sound to look for, either a string (name) or a
-- number (position in the list of sounds)
function Audio:soundExists(sound)
  if self.sound_archive then
    return self.sound_archive:soundExists(sound)
  else
    return false
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

--! Pauses or unpauses background music depending on the current state.
--! Returns whether music is currently paused or not after the call.
--! If nil is returned music might either be playing or completely stopped.
function Audio:pauseBackgroundTrack()
  assert(self.background_music, "Trying to pause music while music is stopped")
  -- TODO: There is a bug in SDL for Windows that makes all sound, not just music stop
  -- when pausing. For the time being, stop the music instead to prevent this.
  self:stopBackgroundTrack()
  return false
  -------------------------------------------------
  -- Real pause logic
  -------------------------------------------------
  --[[local status
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
    self.background_paused = nil
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
  self:notifyJukebox()
  return self.background_paused--]]
end

--! Stops playing background music for the time being.
--! Does not affect the configuration setting play_music.
function Audio:stopBackgroundTrack()
  if self.background_paused then
    -- unpause first in order to clear the backupped volume
    self:pauseBackgroundTrack()
  end
  SDL.audio.stopMusic()
  self.background_music = nil

  self:notifyJukebox()
end

--! Plays a given background track.
--! Playback will only start if the configuration says it's ok. (play_music = true)
--!param index Index of the track to play in the playlist.
function Audio:playBackgroundTrack(index)
  local info = self.background_playlist[index]
  assert(info, "Index not valid")
  if self.app.config.play_music then
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
      -- Someone might want to stop the player from
      -- starting to play once it's loaded though.
      self.load_music = true
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
          -- Do we still want it to play?
          if self.load_music then
            return self:playBackgroundTrack(index)
          end
        end
      end)
      return
    end
    SDL.audio.setMusicVolume(self.app.config.music_volume)
    assert(SDL.audio.playMusic(music))
    self.background_music = music

    self:notifyJukebox()
  end
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

  if self:canSoundsBePlayed() then
    self:tellInterestedEntitiesTheyCanNowPlaySounds()
  end
end

function Audio:tellInterestedEntitiesTheyCanNowPlaySounds()
  if table_length(self.entities_waiting_for_sound_to_be_enabled) > 0 then
    for entity,callback in pairs(self.entities_waiting_for_sound_to_be_enabled) do
      callback()
      self.entities_waiting_for_sound_to_be_enabled[entity] = nil
    end
  end
end

function Audio:entityNoLongerWaitingForSoundsToBeTurnedOn(entity)
  self.entities_waiting_for_sound_to_be_enabled[entity] = nil
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

function Audio:reserveChannel()
  if self.sound_fx then
    return self.sound_fx:reserveChannel()
  else
    return -1
  end
end

function Audio:releaseChannel(channel)
  if self.sound_fx and channel > -1 then
    self.sound_fx:releaseChannel(channel)
  end
end
