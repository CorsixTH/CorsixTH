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
local SDL = require("sdl")
local pathsep = package.config:sub(1, 1)

class "MoviePlayer"

---@class MoviePlayer
---@operator call: MoviePlayer
local MoviePlayer = _G["MoviePlayer"] ---@type MoviePlayer

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
  local screen_w, screen_h = me.app.video:getRenderSize()
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
  if me.holding_bg_music then
    -- If possible we want to continue playing music where we were
    me.audio:pauseBackgroundTrack()
    me.holding_bg_music = false
  end
  if me.sound then
    me.audio:stopSound(me.sound)
    me.sound = nil
  end
  me.refresh_overlay = nil
  me.letter = nil
  if me.typing_sound then me.audio:stopSound(me.typing_sound) end
  me.typing_sound = nil
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

-- The letter's cross and tick (LETTR02V in the movie's palette: 1 tick,
-- 2 tick lit, 3 cross, 4 cross lit; 41x40), where the original game has them
-- on the paper (at 640x480). The tick takes the first choice, the cross the
-- second.
local LETTER_BUTTONS = {
  {sprite = 3, lit = 4, x = 340, y = 401, choice = 2},
  {sprite = 1, lit = 2, x = 390, y = 401, choice = 1},
}
local LETTER_BUTTON_W, LETTER_BUTTON_H = 41, 40

-- Where the text of the letter goes on the paper (at 640x480), as in the
-- original game. Once it has settled, the paper runs from x = 161 to 466 and
-- from y = 25 to 470, and its letter head ends at y = 88. The text ends above
-- the buttons, or near the bottom of the paper if there are none.
local LETTER_LEFT, LETTER_TOP, LETTER_WIDTH = 187, 158, 258
local LETTER_BOTTOM, LETTER_BOTTOM_NO_BUTTONS = 396, 452

-- The letter shows once the paper has settled, this many milliseconds before
-- the end of the movie.
local LETTER_SHOWS_MS = 250

-- The letter types itself out, as in the original game, at this many
-- characters a second.
local LETTER_TYPING_CPS = 45

-- The typewriter is part of the movie, whose own sound plays at full volume
-- whatever the volume settings, so it does not follow them either. Its
-- recording (TYPING.WAV) is quiet: it peaks at -25 dB, the movie's fanfare at
-- -1 dB. This volume plays it 6.3 times (16 dB) louder (Audio:playSound; the
-- sound effects' gain is 0.01 * e^(4.6 * volume), 1 at a volume of 1).
local LETTER_TYPING_VOLUME = 1.4

--! The UTF-8 characters of `text`, in a list.
--!param text (string) the text
--!return (table) its characters (strings)
local function utf8Chars(text)
  local chars = {}
  for c in text:gmatch("[^\128-\191][\128-\191]*") do
    chars[#chars + 1] = c
  end
  return chars
end

--! `text` in lines of at most `width` pixels of `font`, broken between words.
-- A word wider than a line is broken between characters (Chinese and Japanese
-- have no spaces). The lines are laid out before the typing starts, so a word
-- being typed does not jump to the next line when it is complete.
--!param font (font) the font of the lines
--!param text (string) the text
--!param width (number) the widest a line may be, in pixels
--!return (table) the lines (strings)
local function wrapLines(font, text, width)
  local lines, line = {}, ""
  local function fits(t) return (font:sizeOf(t)) <= width end
  for word in text:gmatch("%S+") do
    local longer = line == "" and word or line .. " " .. word
    if fits(longer) then
      line = longer
    else
      if line ~= "" then lines[#lines + 1] = line end
      line = ""
      if fits(word) then
        line = word
      else
        for _, c in ipairs(utf8Chars(word)) do
          if line ~= "" and not fits(line .. c) then
            lines[#lines + 1] = line
            line = ""
          end
          line = line .. c
        end
      end
    end
  end
  if line ~= "" then lines[#lines + 1] = line end
  return lines
end

--! The rows of a letter: its paragraphs in lines of at most `width` pixels of
-- `font`, with a blank line between paragraphs.
--!param font (font) the font of the letter
--!param texts (table) the paragraphs (strings)
--!param width (number) the widest a line may be, in pixels
--!return (table, number, number) the rows ({text, chars, y}), their height
-- and how many characters they have
local function layoutLetter(font, texts, width)
  local _, line_h = font:sizeOf("Ag")
  local rows, y, total = {}, 0, 0
  for i, text in ipairs(texts) do
    if i > 1 then y = y + line_h end
    for _, line in ipairs(wrapLines(font, text, width)) do
      local chars = utf8Chars(line)
      rows[#rows + 1] = {text = line, chars = chars, y = y}
      total = total + #chars
      y = y + line_h
    end
  end
  return rows, y, total
end

--! The text of `letter` laid out for a screen with `vs` screen pixels per
-- pixel of the letter. Its pixel font is drawn at a whole number of screen
-- pixels per font pixel, as stretched by an uneven factor (such as 3.33) its
-- strokes come out in uneven widths: the nearest whole number at which the
-- text fits on the paper, else a smaller one, down to half the letter's
-- size. If none fits, the text is drawn smaller still, down to half size.
--!param letter (table) the letter (makeWinLetter)
--!param vs (number) screen pixels per pixel of the movie at 640x480
--!return (table) the text: its rows, total (characters) and scale (screen
-- pixels per font pixel)
local function layoutLetterText(letter, vs)
  local font, texts = letter.font, letter.texts
  local page_h = letter.bottom - LETTER_TOP
  local k = math.max(1, math.floor(vs + 0.5))
  while k >= 1 and k >= vs * 0.5 do
    local width = math.floor(LETTER_WIDTH * vs / k)
    local rows, height, total = layoutLetter(font, texts, width)
    if height * k <= page_h * vs then
      return {rows = rows, total = total, scale = k}
    end
    k = k - 1
  end
  local fit = 1
  local rows, height, total = layoutLetter(font, texts, LETTER_WIDTH)
  while fit > 0.5 and height * fit > page_h do
    fit = fit - 0.05
    local width = math.floor(LETTER_WIDTH / fit)
    rows, height, total = layoutLetter(font, texts, width)
  end
  return {rows = rows, total = total, scale = vs * fit}
end

--! The letter at the end of the level won movie (WINLEVEL), as the original
-- game writes it there: its paragraphs on the paper below the letter head,
-- in Font35V in the movie's own palette (winlevel.pl8), with a blank line
-- between them. It is laid out for the screen when it is drawn
-- (layoutLetterText).
--!param me (MoviePlayer) the movie player, with the movie loaded
--!param paragraphs (table) the paragraphs (strings or _S strings)
--!param choose (function) [optional] called with the answer (1 tick,
-- 2 cross); without it the letter has no buttons
--!return (table) the letter, for MoviePlayer.letter, or nil if its font
-- could not be loaded
local function makeWinLetter(me, paragraphs, choose)
  local gfx = me.app.gfx
  local ok, font, buttons = pcall(function()
    local palette = gfx:getPalette("winlevel.pl8")
    return gfx:loadFontAndSpriteTable("QData", "Font35V", false, palette),
        choose and gfx:loadSpriteTable("QData", "Lettr02V", true, palette)
  end)
  if not ok or not font then return nil end

  -- The paragraphs as plain strings, to be cut into characters: without the
  -- empty ones, and with the fax's line breaks (//) as spaces.
  local texts = {}
  for _, text in ipairs(paragraphs) do
    if type(text) ~= "string" then
      text = tostring((TH.stringProxy._unwrap(text)))
    end
    text = text:gsub("//", " ")
    if text:find("%S") then texts[#texts + 1] = text end
  end
  return {
    shown = false, -- (on the screen yet)
    typed = false, -- (all of it)
    choose = choose,
    font = font,
    buttons = buttons,
    texts = texts,
    bottom = buttons and LETTER_BOTTOM or LETTER_BOTTOM_NO_BUTTONS,
    start_pts = me.movie_length - LETTER_SHOWS_MS,
  }
end

--! Draw the text of `letter`, as much of it as is typed.
--!param canvas (video) where to draw it
--!param letter (table) the letter (makeWinLetter), laid out for the screen
--!param x (number) the left of the movie on the screen
--!param y (number) the top of the movie on the screen
--!param vs (number) screen pixels per pixel of the movie at 640x480
--!param chars (number) how many characters are typed
local function drawLetterText(canvas, letter, x, y, vs, chars)
  local s = letter.text.scale
  canvas:scale(s)
  local tx = math.floor((x + LETTER_LEFT * vs) / s)
  local ty = math.floor((y + LETTER_TOP * vs) / s)
  for _, row in ipairs(letter.text.rows) do
    if chars <= 0 then break end
    local text = row.text
    if chars < #row.chars then
      text = table.concat(row.chars, "", 1, chars)
    end
    letter.font:draw(canvas, text, tx, ty + row.y)
    chars = chars - #row.chars
  end
  canvas:scale(1)
end

--! Draw the win letter over the frame of the movie, typed as far as it is by
-- now (the overlay of MoviePlayer:playWinLevelMovie).
--!param player (MoviePlayer) the movie player
--!param letter (table) the letter (makeWinLetter)
--!param x (number) the left of the movie on the screen
--!param y (number) the top of the movie on the screen
--!param scale (number) screen pixels per pixel of the movie
--!param pts (number) the time in the movie, in milliseconds
local function drawWinLetter(player, letter, x, y, scale, pts)
  if pts < letter.start_pts then return end
  -- Hold the movie on the letter until it is answered or skipped: its very
  -- last frame is its first one again (a Smacker ring frame, for looping,
  -- which shows the casebook). Paused again if the pause key lets it run on.
  if not letter.hold_pts or pts > letter.hold_pts + 40 then
    player:togglePause()
    letter.hold_pts = pts
  end
  -- The movie is 320x240; the letter is laid out at 640x480.
  local vs = scale * 0.5
  local ui = player.app.ui
  local now = SDL.getTicks()
  if not letter.shown then
    letter.shown = true
    letter.typing_from = now
    if letter.buttons and ui and ui.default_cursor then
      ui:setCursor(ui.default_cursor) -- (the pointer, to click the buttons)
    end
  end
  letter.x, letter.y, letter.vs = x, y, vs
  if letter.text_vs ~= vs then
    letter.text, letter.text_vs = layoutLetterText(letter, vs), vs
  end
  local total = letter.text.total
  local chars = total
  if not letter.typed then
    chars = math.floor((now - letter.typing_from) * LETTER_TYPING_CPS / 1000)
    letter.typed = chars >= total
  end
  player:letterTyping(not letter.typed)

  local canvas = player.video
  drawLetterText(canvas, letter, x, y, vs, chars)
  if letter.buttons and letter.typed then
    canvas:scale(vs)
    local hover = player:letterButtonAt(player.mouse_x, player.mouse_y)
    for _, button in ipairs(LETTER_BUTTONS) do
      local sprite = hover == button and button.lit or button.sprite
      letter.buttons:draw(canvas, sprite, math.floor(x / vs) + button.x,
          math.floor(y / vs) + button.y)
    end
    canvas:scale(1)
  end
  -- A cursor that the game draws itself (no hardware cursor) is drawn on the
  -- letter too, as the screen is not drawn during a movie.
  local cursor = letter.buttons and ui and ui.simulated_cursor
  if cursor and player.mouse_x then
    cursor.draw(canvas, player.mouse_x, player.mouse_y)
  end
end

function MoviePlayer:MoviePlayer(app, audio, video)
  self.app = app
  self.audio = audio
  self.video = video
  self.playing = false
  self.holding_bg_music = false
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
  self.letter = nil -- (the letter of the level won movie)
  self.typing_sound = nil
  self.mouse_x, self.mouse_y = nil, nil
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

--! Play the movie for winning the level.
--!param callback (function) [optional] what to do after the movie ends (at
-- once if it cannot be played)
--!param letter (table) [optional] the paragraphs of the letter it ends with
-- (strings or _S strings), typed out on its paper; without them the letter
-- stays blank
--!param choose (function) [optional] with a letter, its cross and tick to
-- answer it: called with the answer (1 tick, 2 cross), after which the movie
-- ends (and `callback` follows)
function MoviePlayer:playWinLevelMovie(callback, letter, choose)
  self:playMovie(self.win_level_movie, true, callback)
  if not (self.playing and letter and #letter > 0) then return end
  local win_letter = makeWinLetter(self, letter, choose)
  if not win_letter then return end
  self.letter = win_letter
  -- The mouse is where it was: the screen does not follow it during a movie
  -- (MoviePlayer:mouseMove does).
  local ui = self.app.ui
  self.mouse_x, self.mouse_y = ui and ui.cursor_x, ui and ui.cursor_y
  self.refresh_overlay = function(player, x, y, _, _, scale, pts)
    drawWinLetter(player, win_letter, x, y, scale, pts)
  end
end

--! The button of the win letter (LETTER_BUTTONS) at screen position
-- (mx, my), or nil. The buttons are there once the letter is typed.
--!param mx (number) x on the screen
--!param my (number) y on the screen
--!return (table) the button, or nil
function MoviePlayer:letterButtonAt(mx, my)
  local letter = self.letter
  if not (letter and letter.shown and letter.typed and letter.choose) or
      not (mx and my) then
    return nil
  end
  local lx, ly = (mx - letter.x) / letter.vs, (my - letter.y) / letter.vs
  for _, button in ipairs(LETTER_BUTTONS) do
    if lx >= button.x and lx < button.x + LETTER_BUTTON_W and
        ly >= button.y and ly < button.y + LETTER_BUTTON_H then
      return button
    end
  end
  return nil
end

--! The typewriter while the win letter types itself out: the game's own key
-- strike (TYPING.WAV), over and over until the letter is typed, unless sound
-- effects are off.
--!param on (boolean) whether the letter is being typed
function MoviePlayer:letterTyping(on)
  if on and not self.typing_sound and self.app.config.play_sounds then
    self.typing_sound = self.audio:playSound("TYPING.WAV", nil, false, nil,
        nil, -1, LETTER_TYPING_VOLUME)
  elseif not on and self.typing_sound then
    self.audio:stopSound(self.typing_sound)
    self.typing_sound = nil
  end
end

--! The mouse has moved while a movie plays (the buttons of the win letter
-- light up under it).
--!param x (number) x on the screen
--!param y (number) y on the screen
function MoviePlayer:mouseMove(x, y)
  self.mouse_x, self.mouse_y = x, y
end

--! A left click while a movie plays. While the win letter is being typed,
-- the click finishes it. Once it is typed, a click on a button answers it
-- and ends the movie, and a click anywhere else does nothing; a letter
-- without buttons ends with the click. Before a letter with buttons shows, a
-- click does nothing. (The key to stop movies still ends it without an
-- answer.)
--!param x (number) x on the screen
--!param y (number) y on the screen
--!return (boolean) true if the letter took the click (the movie goes on)
function MoviePlayer:letterClick(x, y)
  local letter = self.letter
  if not letter then return false end
  if not letter.shown then return letter.choose ~= nil end
  if not letter.typed then
    letter.typed = true
    return true
  end
  if not letter.choose then return false end
  local button = self:letterButtonAt(x, y)
  if button then
    self.letter = nil
    letter.choose(button.choice)
    self:stop()
  end
  return true
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

  warning = self.moviePlayer:play()
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
