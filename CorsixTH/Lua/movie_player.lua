--[[ Copyright (c) 2012 Stephen Baker

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

--! Layer which handles the Lua-facing side of loading and playing video.

local TH = require "TH"
local pathsep = package.config:sub(1, 1)

class "MoviePlayer"

function MoviePlayer:MoviePlayer(app, audio)
  self.app = app
  self.audio = audio
  self.playing = false
  self.can_skip = true
  self.holding_bg_music = false
  self.channel = -1
  self.lose_movies = {}
  self.advance_movies = {}
  self.intro_movie = nil
  self.win_movie = nil
  self.wait_for_stop = false
  self.wait_for_over = false
end

function MoviePlayer:init()
  self.moviePlayer = TH.moviePlayer()

  --find movies in Anims folder
  local num
  local movie
  local movies = self.app.fs:listFiles("Anims");
  if movies then
    for _,movie in pairs(movies) do
        --lose level movies
        if movie:upper():match(pathsep .. "LOSE%d+%.[^" .. pathsep .."]+$") then
        table.insert(self.lose_movies, movie)
        end
        --advance level movies
        num = tonumber(movie:upper():match(pathsep .. "AREA(%d+)V%.[^" .. pathsep .."]+$"), 10)
        if(num ~= nil) then
        self.advance_movies[num] = movie
        end
        --win game movie
        if movie:upper():match(pathsep .. "WINGAME%.[^" .. pathsep .. "]+$") then
        self.win_movie = movie
        end
    end
  end

  --find intro
  movies = self.app.fs:listFiles("Intro")
  if movies then
    for _,movie in pairs(movies) do
      if movie:upper():match(pathsep .. "INTRO%.SM4$") then
        self.intro_movie = movie
      end
    end
  end
end

function MoviePlayer:playIntro()
  self:playMovie(self.intro_movie, false)
end

function MoviePlayer:playWinMovie()
  self:playMovie(self.win_movie, true)
end

function MoviePlayer:playAdvanceMovie(level)
  local filename = self.advance_movies[level]

  if(not self.moviePlayer:getEnabled() or not self.app.config.movies or filename == nil) then
      return
  end

  self.can_skip = false
  self.audio:stopBackgroundMusic()
  self.holding_bg_music = true
  if level == 12 then
    self.audio:playSound("DICE122M.WAV")
  else
    self.audio:playSound("DICEYFIN.WAV")
  end
  self:playMovie(filename, true)
end

function MoviePlayer:playLoseMovie()
  if #self.lose_movies > 0 then
    local filename = self.lose_movies[math.random(#self.lose_movies)]
    self:playMovie(filename, true)
  end
end

function MoviePlayer:playMovie(filename, wait_for_stop)
  local x, y, w, h = 0
  local screen_w, screen_h = self.app.config.width, self.app.config.height
  local ar

  if(not self.moviePlayer:getEnabled() or not self.app.config.movies or filename == nil) then
      return
  end

  self.moviePlayer:load(filename)

  if self.moviePlayer:hasAudioTrack() then
    self.channel = self.audio:reserveChannel()
    self.audio:stopBackgroundMusic()
    self.holding_bg_music = true
  end

  -- calculate target dimensions
  local native_w = self.moviePlayer:getNativeWidth()
  local native_h = self.moviePlayer:getNativeHeight()
  if(native_w ~= 0 and native_h ~= 0) then
    ar = native_w / native_h
    if(math.abs((screen_w / screen_h) - ar) < 0.001) then
      x, y = 0, 0
      w, h = screen_w, screen_h
    else
      if(screen_w > screen_h / native_h * native_w) then
        w = screen_h / native_h * native_w
        h = screen_h
        x = (screen_w - w) / 2
        y = 0
      else
        w = screen_w
        h = screen_w / native_w * native_h
        x = 0
        y = (screen_h - h) / 2
      end
    end
  else
    x, y = 0, 0
    w, h = screen_w, screen_h
  end

  self.app.video:startFrame()
  self.app.video:fillBlack()
  self.app.video:endFrame()

  self.wait_for_stop = wait_for_stop
  self.wait_for_over = true
  
  --TODO: Add text e.g. for newspaper headlines
  self.moviePlayer:play(x, y, w, h, self.channel)
  self.playing = true
end

function MoviePlayer:onMovieAllocatePicture()
  self.moviePlayer:allocatePicture()
end

function MoviePlayer:onMovieOver()
  self.wait_for_over = false
  if not self.wait_for_stop then
    self:_destroyMovie()
  end
end

function MoviePlayer:stop()
  if self.can_skip then
    self.moviePlayer:stop()
  end
  self.wait_for_stop = false
  if not self.wait_for_over then
    self:_destroyMovie()
  end
end

function MoviePlayer:_destroyMovie()
  self.moviePlayer:unload()
  if(self.moviePlayer:requiresVideoReset()) then
    self.app.ui:resetVideo()
  end
  if self.channel >= 0 then
    self.audio:releaseChannel(self.channel)
    self.channel = -1
  end
  if self.holding_bg_music then
    self.audio:resumeBackgroundMusic()
  end
  -- restore defaults
  self.playing = false
  self.can_skip = true
end

function MoviePlayer:refresh()
  self.moviePlayer:refresh()
end

