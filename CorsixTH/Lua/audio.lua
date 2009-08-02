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

class "Audio"

function Audio:Audio(app)
  self.app = app
  self.background_playlist = {
    -- {title = "", filename = ""},
  }
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
    local midis = {}
    local function midi(filename)
      local t = midis[filename:upper()]
      if t == nil then
        t = {}
        midis[filename:upper()] = t
      end
      return t
    end
    for item in lfs.dir(midi_dir) do
      if item:upper():match"%.XMI$" then
        midi(item).filename = midi_dir .. item
      elseif item:upper():match"^MIDI.*%.TXT$" then
        for filename, title in linepairs(midi_dir .. item) do
          midi(filename).title = title
        end
      end
    end
    for short_name, info in pairs(midis) do
      if not info.filename then
        print(('Notice: Background track "%s" named in list file, but it '..
          'does not exist'):format(short_name))
      else
        if not info.title then
          info.title = short_name:sub(1, 1) .. short_name:match".(.*)%.":lower()
        end
        self.background_playlist[#self.background_playlist + 1] = info
      end
    end
    if #self.background_playlist == 0 then
      print "Notice: Audio system loaded, but found no background MIDI tracks"
    else
      table.sort(self.background_playlist, function(left, right)
        return left.title:lower() < right.title:lower()
      end)
    end
  end
  
  assert(SDL.audio.init())
  self:playRandomBackgroundTrack()
end

function Audio:playRandomBackgroundTrack()
  if self.not_loaded or #self.background_playlist == 0 then
    return
  end
  local index = math.random(1, #self.background_playlist)
  local info = self.background_playlist[index]
  local file = assert(io.open(info.filename, "rb"))
  local data = file:read"*a"
  file:close()
  if data:sub(1, 3) == "RNC" then
    data = assert(rnc.decompress(data))
  end
  data = SDL.audio.transcodeXmiToMid(data)  
  local music = assert(SDL.audio.loadMusic(data))
  SDL.audio.setMusicVolume(0.5)
  assert(SDL.audio.playMusic(music))
  self.background_music = music
end
