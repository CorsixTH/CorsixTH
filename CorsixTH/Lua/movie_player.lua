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

local TH = require("TH")
local pathsep = package.config:sub(1, 1)

class "MoviePlayer"

---@type MoviePlayer
local MoviePlayer = _G["MoviePlayer"]

--! Calculate the position and size for a movie
--!
--! Returns x and y position, width and height, and the scale factor of the
--! movie to be displayed based on the native size of the movie and the current
--! screen dimensions.
--!
--! Theme Hospital movies were 320x240 but played in game at 640x480 so when
--! scaling other assets to match the movies they should be scaled by half
--! the returned scaling factor. Some movies were 320x200 and those should
--! be aspect corrected to 4:3 during scaling.
--!
--!param me The MoviePlayer object
local calculateSize = function(me)
  -- calculate target dimensions
  local x, y, w, h, scale
  local screen_w, screen_h = me.app.config.width, me.app.config.height
  local native_w = me.moviePlayer:getNativeWidth()
  local native_h = me.moviePlayer:getNativeHeight()
  if native_w == 320 and native_h == 200 then
    -- This resolution was intended to be stretched for a 4:3 screen
    native_h = 240
  end
  if native_w ~= 0 and native_h ~= 0 then
    local ar = native_w / native_h
    if math.abs((screen_w / screen_h) - ar) < 0.001 then
      x, y = 0, 0
      w, h = screen_w, screen_h
      scale = screen_h / native_h
    else
      if screen_w > screen_h / native_h * native_w then
        w = math.floor(screen_h / native_h * native_w)
        h = screen_h
        x = math.floor((screen_w - w) / 2)
        y = 0
        scale = screen_h / native_h
      else
        w = screen_w
        h = math.floor(screen_w / native_w * native_h)
        x = 0
        y = math.floor((screen_h - h) / 2)
        scale = screen_w / native_w
      end
    end
  else
    x, y = 0, 0
    w, h = screen_w, screen_h
    scale = 1
  end

  return x, y, w, h, scale
end

local destroyMovie = function(me)
  me.moviePlayer:unload()
  if me.opengl_mode_index then
    me.app.modes[me.opengl_mode_index] = "opengl"
  end
  if me.channel >= 0 then
    me.audio:releaseChannel(me.channel)
    me.channel = -1
  end
  if me.holding_bg_music then
    -- If possible we want to continue playing music where we were
    me.audio:pauseBackgroundTrack()
  else
    me.audio:playRandomBackgroundTrack()
  end
  if me.sound then
    me.audio:stopSound(me.sound)
    me.sound = nil
  end
  me.refresh_overlay = nil
  me.playing = false
  me.movie_over = false
  if me.callback_on_destroy_movie then
    me.callback_on_destroy_movie()
    me.callback_on_destroy_movie = nil
  end
end

local loseMovieOverlay = function(me, lose_movie_index)

  -- These are the times in milliseconds when the headline should appear as
  -- determined experimentally
  local start_movie_pts = {
    me.movie_length - 1760,
    me.movie_length - 860,
    me.movie_length - 1600,
    me.movie_length - 1000,
    me.movie_length - 860,
    me.movie_length - 780,
  }

  local start_pts = start_movie_pts[lose_movie_index]
  local headlines = _S.newspaper[lose_movie_index]
  local headline = headlines[math.random(#headlines)]

  -- The LOSE movies are 320x240 but are drawn in the original game at 640x480
  -- before drawing the font over them. The headline area at double size is 40px
  -- tall and 590px wide if we exclude the padding which has no other ink. If we
  -- let the headline fill the entire width of the paper it could be 618px wide.
  --
  -- The widest original english headline is headline 4 for LOSE5 which is 708px
  -- wide in standard font and 520px wide in narrow font.
  local hl_font = me.lose_font
  local hl_top = 132
  local hl_w, hl_h = me.lose_font:sizeOf(headline)
  if me.lose_font:isBitmap() then
    if hl_w > 590 then
      hl_font = me.lose_font_narrow

      -- The narrow font and standard font have a different baseline so we need
      -- to adjust the top.
      hl_top = 138
    end
  else
    -- For TTF fonts we try to vertically center them in the headline area
    hl_top = 132 + math.floor((52 - hl_h) / 2)
  end

  return function(player, x, y, w, h, scale, pts)
    if pts >= start_pts then
      local vs = scale * 0.5
      player.video:scale(vs)
      hl_font:draw(player.video, headline, math.floor(x / vs), math.floor(y / vs) + hl_top, 640, 0, "center")
      player.video:scale(1)
    end
  end
end

function MoviePlayer:MoviePlayer(app, audio, video)
  self.app = app
  self.audio = audio
  self.video = video
  self.playing = false
  self.holding_bg_music = false
  self.channel = -1
  self.sound = nil
  self.lose_movies = {}
  self.advance_movies = {}
  self.intro_movie = nil
  self.demo_movie = nil
  self.win_game_movie = nil
  self.win_level_movie = nil
  self.wait_for_stop = false
  self.wait_for_over = false
  self.movie_over = false
  self.movie_length = 0
  self.lose_font = nil
  self.lose_font_narrow = nil
end

--! Initialises the different movies used in the game
function MoviePlayer:init()
  self.moviePlayer = TH.moviePlayer()
  self.moviePlayer:setRenderer(self.video)

  local lose_palette = self.app.gfx:getPalette("lose.pl8")
  self.lose_font = self.app.gfx:loadFontAndSpriteTable("QData", "Font39v", false, lose_palette)
  self.lose_font_narrow = self.app.gfx:loadFontAndSpriteTable("QData", "Font40v", false, lose_palette)

  --find movies in Anims folder
  local fs = self.app.fs
  local movies = fs:listFiles("Anims")
  if movies then
    for _, movie in pairs(movies) do
      local num

      --lose level movies
      num = movie:upper():match(pathsep .. "LOSE(%d+)%.[^" .. pathsep .. "]+$")
      if num then
        self.lose_movies[tonumber(num, 10)] = fs:fileUri(movie)
      end

      --advance level movies
      num = movie:upper():match(pathsep .. "AREA(%d+)V%.[^" .. pathsep .. "]+$")
      if num then
        self.advance_movies[tonumber(num, 10)] = fs:fileUri(movie)
      end

      --win game movie
      if movie:upper():match(pathsep .. "WINGAME%.[^" .. pathsep .. "]+$") then
        self.win_game_movie = fs:fileUri(movie)
      end

      --win level movie
      if movie:upper():match(pathsep .. "WINLEVEL%.[^" .. pathsep .. "]+$") then
        self.win_level_movie = fs:fileUri(movie)
      end
    end
  end

  --find intro and demo movies
  movies = self.app.fs:listFiles("Intro")
  if movies then
    for _, movie in pairs(movies) do
      if movie:upper():match(pathsep .. "INTRO%.SM4$") then
        self.intro_movie = fs:fileUri(movie)
      elseif movie:upper():match(pathsep .. "ATTRACT.SMK$") then
        self.demo_movie = fs:fileUri(movie)
      end
    end
  end
end

--! Plays the opening movie from TH
--!param callback_after_movie (function) What to do once movie ends
function MoviePlayer:playIntro(callback_after_movie)
  self:playMovie(self.intro_movie, false, callback_after_movie)
end

--! Plays the demo gameplay footage movie from TH
function MoviePlayer:playDemoMovie()
  self:playMovie(self.demo_movie, false)
end

--! Plays the movie for winning the game
function MoviePlayer:playWinMovie()
  self:playMovie(self.win_game_movie, false)
end

--! Play the movie for winning the level
function MoviePlayer:playWinLevelMovie()
  self:playMovie(self.win_level_movie, true)
end

--! Plays the level advance movie, which is going to the next level on the game board
--! This is for the original campaign only.
--!param level (number) What level we're going to.
function MoviePlayer:playAdvanceMovie(level)
  local filename = self.advance_movies[level]

  if self.moviePlayer == nil or not self.moviePlayer:getEnabled() or
      not self.app.config.movies or filename == nil then
    return
  end

  if self.audio.background_music then
    self.holding_bg_music = self.audio:pauseBackgroundTrack()
  end

  if level == 12 then
    self.sound = self.audio:playSound("DICE122M.WAV")
  else
    self.sound = self.audio:playSound("DICEYFIN.WAV")
  end
  self:playMovie(filename, true)
end

--! Plays one of the lose scenario movies at random
function MoviePlayer:playLoseMovie()
  if #self.lose_movies > 0 then
    local lose_movie_index = math.random(#self.lose_movies)
    local filename = self.lose_movies[lose_movie_index]
    self:playMovie(filename, true)
    self.refresh_overlay = loseMovieOverlay(self, lose_movie_index)
  end
end

--! Function used to tell the Movie Player to play something.
--!param filename (string) Location of the movie file
--!param wait_for_stop (boolean) If true, movie will not dismiss automatically
--! (requires a mouse/key press)
--!param callback (function) What to do after the movie ends
function MoviePlayer:playMovie(filename, wait_for_stop, callback)
  local success, warning

  if self.moviePlayer == nil or not self.moviePlayer:getEnabled() or
      not self.app.config.movies or filename == nil then
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

  self.movie_length = self.moviePlayer:getLength()

  self.video:startFrame()
  self.video:fillBlack()
  self.video:endFrame()

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

  warning = self.moviePlayer:play(self.channel)
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
  if self.moviePlayer == nil then return end

  self.moviePlayer:allocatePictureBuffer()
end

--NB: Call before any changes to TH.surface
function MoviePlayer:deallocatePictureBuffer()
  if self.moviePlayer == nil then return end

  self.moviePlayer:deallocatePictureBuffer()
end

--! Handles when the movie ends
function MoviePlayer:onMovieOver()
  if self.moviePlayer == nil then return end

  self.movie_over = true
  self.wait_for_over = false
  if not self.wait_for_stop then
    destroyMovie(self)
  end
end

--! Handles ending the movie prematurely (user input)
function MoviePlayer:stop()
  if self.moviePlayer == nil then return end

  self.moviePlayer:stop()
  self.wait_for_stop = false
  if not self.wait_for_over then
    destroyMovie(self)
  end
end

function MoviePlayer:refresh()
  if self.moviePlayer == nil then return end

  local x, y, w, h, scale = calculateSize(self)
  local pts = self.moviePlayer:refresh(x, y, w, h)
  if self.refresh_overlay then
    self.refresh_overlay(self, x, y, w, h, scale, pts)
  end
end

function MoviePlayer:updateRenderer()
  if self.moviePlayer == nil then return end

  self.moviePlayer:setRenderer(self.video)
end

function MoviePlayer:togglePause()
  if self.moviePlayer == nil then return end

  self.moviePlayer:togglePause()
  if self.sound then
    self.audio:togglePauseSound(self.sound)
  end
end
