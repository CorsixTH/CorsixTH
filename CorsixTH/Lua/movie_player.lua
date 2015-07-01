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

---@type MoviePlayer
local MoviePlayer = _G["MoviePlayer"]

function MoviePlayer:MoviePlayer(app, audio, video)
  self.app = app
  self.audio = audio
  self.video = video
  self.playing = false
  self.holding_bg_music = false
  self.channel = -1
  self.lose_movies = {}
  self.advance_movies = {}
  self.intro_movie = nil
  self.win_movie = nil
  self.can_skip = true
  self.wait_for_stop = false
  self.wait_for_over = false
end

function MoviePlayer:init()
  self.moviePlayer = TH.moviePlayer()
  self.moviePlayer:setRenderer(self.video)

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
      num = movie:upper():match(pathsep .. "AREA(%d+)V%.[^" .. pathsep .."]+$")
      if num ~= nil and tonumber(num, 10) ~= nil then
        self.advance_movies[tonumber(num, 10)] = movie
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

function MoviePlayer:playIntro(callback_after_movie)
  self:playMovie(self.intro_movie, false, true, callback_after_movie)
end

function MoviePlayer:playWinMovie()
  self:playMovie(self.win_movie, true, true)
end

function MoviePlayer:playAdvanceMovie(level)
  local filename = self.advance_movies[level]

  if(not self.moviePlayer:getEnabled() or not self.app.config.movies or filename == nil) then
      return
  end

  if self.audio.background_music then
    self.holding_bg_music = self.audio:pauseBackgroundTrack()
  else

  end
  if level == 12 then
    self.audio:playSound("DICE122M.WAV")
  else
    self.audio:playSound("DICEYFIN.WAV")
  end
  self:playMovie(filename, true, false)
end

function MoviePlayer:playLoseMovie()
  if #self.lose_movies > 0 then
    local filename = self.lose_movies[math.random(#self.lose_movies)]
    self:playMovie(filename, true, true)
  end
end

function MoviePlayer:playMovie(filename, wait_for_stop, can_skip, callback)
  local x, y, w, h = 0
  local screen_w, screen_h = self.app.config.width, self.app.config.height
  local ar
  local success, warning

  if(not self.moviePlayer:getEnabled() or not self.app.config.movies or filename == nil) then
    if callback then
      callback()
    end
    return
  end

  success, warning = self.moviePlayer:load(filename)
  if warning ~= nil and warning ~= "" then
    local message = "MoviePlayer:playMovie - Warning: " .. warning
    if self.app.world then
      self.app.world:gameLog(message)
    elseif self.app.config.debug then
      print(message)
    end
  end
  if not success then
    -- Indicates failure to load movie
    if callback then
      callback()
    end
    return
  end
  -- Abort any loading of music
  self.audio.load_music = false
  if self.moviePlayer:hasAudioTrack() then
    self.channel = self.audio:reserveChannel()
    if self.audio.background_music then
      self.holding_bg_music = self.audio:pauseBackgroundTrack()
    end
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
        w = math.floor(screen_h / native_h * native_w)
        h = screen_h
        x = math.floor((screen_w - w) / 2)
        y = 0
      else
        w = screen_w
        h = math.floor(screen_w / native_w * native_h)
        x = 0
        y = math.floor((screen_h - h) / 2)
      end
    end
  else
    x, y = 0, 0
    w, h = screen_w, screen_h
  end

  self.video:startFrame()
  self.video:fillBlack()
  self.video:endFrame()

  self.can_skip = can_skip
  self.wait_for_stop = wait_for_stop
  self.wait_for_over = true

  self.callback_on_destroy_movie = callback

  self.opengl_mode_index = nil
  for i=1, #self.app.modes do
    if self.app.modes[i] == "opengl" then
      self.opengl_mode_index = i
    end
  end
  if self.opengl_mode_index then
    self.app.modes[self.opengl_mode_index] = ""
  end

  --TODO: Add text e.g. for newspaper headlines
  warning = self.moviePlayer:play(x, y, w, h, self.channel)
  if warning ~= nil and warning ~= "" then
    local message = "MoviePlayer:playMovie - Warning: " .. warning
    if self.app.world then
      self.app.world:gameLog(message)
    elseif self.app.config.debug then
      print(message)
    end
  end
  self.playing = true
end

--NB: Call after any changes to TH.surface
function MoviePlayer:allocatePictureBuffer()
  self.moviePlayer:allocatePictureBuffer()
end

--NB: Call before any changes to TH.surface
function MoviePlayer:deallocatePictureBuffer()
  self.moviePlayer:deallocatePictureBuffer()
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
  if self.opengl_mode_index then
    self.app.modes[self.opengl_mode_index] = "opengl"
  end
  if self.channel >= 0 then
    self.audio:releaseChannel(self.channel)
    self.channel = -1
  end
  if self.holding_bg_music then
    -- If possible we want to continue playing music where we were
    self.audio:pauseBackgroundTrack()
  else
    self.audio:playRandomBackgroundTrack()
  end
  self.playing = false
  if self.callback_on_destroy_movie then
    self.callback_on_destroy_movie()
    self.callback_on_destroy_movie = nil
  end
end

function MoviePlayer:refresh()
  self.moviePlayer:refresh()
end

function MoviePlayer:updateRenderer()
  self.moviePlayer:setRenderer(self.video)
end
