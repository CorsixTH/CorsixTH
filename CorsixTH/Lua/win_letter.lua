--[[ Copyright (c) 2026 Jan Bachelor

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

--- The letter at the end of the level won movie (WINLEVEL), as in the original
--- game: typed out on its paper to the sound of a typewriter, and answered
--- there with the tick or the cross. MoviePlayer:playWinLevelMovie shows it
--- over the movie and passes the mouse on to it.

local TH = require("TH")
local SDL = require("sdl")

class "WinLetter"

---@class WinLetter
---@operator call: WinLetter
local WinLetter = _G["WinLetter"] ---@type WinLetter

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

-- The letter types itself out, as in the original game, at this many
-- characters a second.
local LETTER_TYPING_CPS = 45

-- The typewriter is part of the movie, whose own sound plays at full volume
-- whatever the volume settings, so it does not follow them either. Its
-- recording (TYPING.WAV) is quiet: it peaks at -25 dB, the movie's fanfare at
-- -1 dB. This volume plays it 6.3 times (16 dB) louder (Audio:playSound; the
-- sound effects' gain is 0.01 * e^(4.6 * volume), 1 at a volume of 1).
local LETTER_TYPING_VOLUME = 1.4

--- The UTF-8 characters of a text, in a list.
--- @param text (string) the text
--- @return (string[]) # its characters
local function utf8Chars(text)
  local chars = {}
  for c in text:gmatch("[^\128-\191][\128-\191]*") do
    chars[#chars + 1] = c
  end
  return chars
end

--- A text in lines no wider than the given width, broken between words.
---
--- A word wider than a line is broken between characters (Chinese and Japanese
--- have no spaces). The lines are laid out before the typing starts, so a word
--- being typed does not jump to the next line when it is complete.
--- @param font (THFont) the font of the lines
--- @param text (string) the text
--- @param width (number) the widest a line may be, in pixels
--- @return (string[]) # the lines
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

--- The rows of a letter: its paragraphs in lines no wider than the given
--- width, with a blank line between paragraphs.
--- @param font (THFont) the font of the letter
--- @param texts (string[]) the paragraphs
--- @param width (number) the widest a line may be, in pixels
--- @return ({text: string, chars: string[], y: integer}[]) rows # the rows
--- @return (integer) height # their height, in pixels
--- @return (integer) total # how many characters they have
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

--- The text of a letter laid out for a screen with vs screen pixels per pixel
--- of the letter.
---
--- Its pixel font is drawn at a whole number of screen pixels per font pixel,
--- as stretched by an uneven factor (such as 3.33) its strokes come out in
--- uneven widths: the nearest whole number at which the text fits on the
--- paper, else a smaller one, down to half the letter's size. If none fits,
--- the text is drawn smaller still, down to half size.
--- @param letter (WinLetter) the letter
--- @param vs (number) screen pixels per pixel of the movie at 640x480
--- @return ({rows: table[], total: integer, scale: number}) # the text: its rows (layoutLetter), total (characters) and scale (screen pixels per font pixel)
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

--- Load the letter's graphics and take its paragraphs.
---
--- The paragraphs go on the paper below the letter head, in Font35V in the
--- movie's own palette (winlevel.pl8), with a blank line between them. They
--- are laid out for the screen when the letter is drawn. If the font cannot
--- be loaded, the letter has no font and is not shown.
--- @param app (App) the app
--- @param paragraphs ((string|THStringProxy)[]) the paragraphs (strings or _S strings)
--- @param choose (function?) called with the answer (1 tick, 2 cross); without it the letter has no buttons
function WinLetter:WinLetter(app, paragraphs, choose)
  self.app = app
  self.choose = choose
  self.shown = false -- (on the screen yet)
  self.typed = false -- (all of it)
  self.typing_sound = nil
  self.mouse_x, self.mouse_y = nil, nil
  self.pressed = nil -- (the button held down)

  local gfx = app.gfx
  local ok, font, buttons = pcall(function()
    local palette = gfx:getPalette("winlevel.pl8")
    return gfx:loadFontAndSpriteTable("QData", "Font35V", false, palette),
        choose and gfx:loadSpriteTable("QData", "Lettr02V", true, palette)
  end)
  if ok then
    self.font, self.buttons = font, buttons or nil
  end
  self.bottom = self.buttons and LETTER_BOTTOM or LETTER_BOTTOM_NO_BUTTONS

  -- The paragraphs as plain strings, to be cut into characters: without the
  -- empty ones, and with the fax's line breaks (//) as spaces.
  self.texts = {}
  for _, text in ipairs(paragraphs) do
    if type(text) ~= "string" then
      text = tostring((TH.stringProxy._unwrap(text)))
    end
    text = text:gsub("//", " ")
    if text:find("%S") then self.texts[#self.texts + 1] = text end
  end
end

--- Draw the letter over the frame of the movie, typed as far as it is by now.
--- @param canvas (THRenderTarget) where to draw it
--- @param x (number) the left of the movie on the screen
--- @param y (number) the top of the movie on the screen
--- @param scale (number) screen pixels per pixel of the movie
function WinLetter:draw(canvas, x, y, scale)
  -- The movie is 320x240; the letter is laid out at 640x480.
  local vs = scale * 0.5
  local now = SDL.getTicks()
  if not self.shown then
    self:_show(now)
  end
  self.x, self.y, self.vs = x, y, vs
  if self.text_vs ~= vs then
    self.text, self.text_vs = layoutLetterText(self, vs), vs
  end
  local chars = self:_typedChars(now)
  self:setTypewriter(not self.typed)

  self:_drawText(canvas, chars)
  if self.buttons and self.typed then
    self:_drawButtons(canvas)
  end
  self:_drawCursor(canvas)
end

--- The letter comes on the screen: the typing starts.
--- @param now (integer) the time, in milliseconds
function WinLetter:_show(now)
  self.shown = true
  self.typing_from = now
  local ui = self.app.ui
  if self.buttons and ui and ui.default_cursor then
    ui:setCursor(ui.default_cursor) -- (the pointer, to click the buttons)
  end
end

--- How many characters of the letter are typed by now.
--- @param now (integer) the time, in milliseconds
--- @return (integer) # the number of characters
function WinLetter:_typedChars(now)
  local total = self.text.total
  if self.typed then return total end
  local chars = math.floor((now - self.typing_from) * LETTER_TYPING_CPS / 1000)
  self.typed = chars >= total
  return math.min(chars, total)
end

--- Draw the text of the letter, as much of it as is typed.
--- @param canvas (THRenderTarget) where to draw it
--- @param chars (integer) how many characters are typed
function WinLetter:_drawText(canvas, chars)
  local s = self.text.scale
  canvas:scale(s)
  local tx = math.floor((self.x + LETTER_LEFT * self.vs) / s)
  local ty = math.floor((self.y + LETTER_TOP * self.vs) / s)
  for _, row in ipairs(self.text.rows) do
    if chars <= 0 then break end
    local text = row.text
    if chars < #row.chars then
      text = table.concat(row.chars, "", 1, chars)
    end
    self.font:draw(canvas, text, tx, ty + row.y)
    chars = chars - #row.chars
  end
  canvas:scale(1)
end

--- Draw the cross and the tick, the one under the mouse lit. While a button
--- is held down, only that one lights up.
--- @param canvas (THRenderTarget) where to draw them
function WinLetter:_drawButtons(canvas)
  local vs = self.vs
  canvas:scale(vs)
  local hover = self:buttonAt(self.mouse_x, self.mouse_y)
  if self.pressed and hover ~= self.pressed then
    hover = nil
  end
  for _, button in ipairs(LETTER_BUTTONS) do
    local sprite = hover == button and button.lit or button.sprite
    self.buttons:draw(canvas, sprite, math.floor(self.x / vs) + button.x,
        math.floor(self.y / vs) + button.y)
  end
  canvas:scale(1)
end

--- Draw the cursor if the game draws it itself (no hardware cursor), as the
--- screen is not drawn during a movie.
--- @param canvas (THRenderTarget) where to draw it
function WinLetter:_drawCursor(canvas)
  local ui = self.app.ui
  local cursor = self.buttons and ui and ui.simulated_cursor
  if cursor and self.mouse_x then
    cursor.draw(canvas, self.mouse_x, self.mouse_y)
  end
end

--- The button (LETTER_BUTTONS) at screen position (x, y), or nil. The buttons
--- are there once the letter is typed.
--- @param x (number?) x on the screen
--- @param y (number?) y on the screen
--- @return (table?) # the button, or nil
function WinLetter:buttonAt(x, y)
  if not (self.shown and self.typed and self.choose) or not (x and y) then
    return nil
  end
  local lx, ly = (x - self.x) / self.vs, (y - self.y) / self.vs
  for _, button in ipairs(LETTER_BUTTONS) do
    if lx >= button.x and lx < button.x + LETTER_BUTTON_W and
        ly >= button.y and ly < button.y + LETTER_BUTTON_H then
      return button
    end
  end
  return nil
end

--- The typewriter while the letter types itself out: the game's own key
--- strike (TYPING.WAV), over and over until the letter is typed, unless sound
--- effects are off.
--- @param on (boolean) whether the letter is being typed
function WinLetter:setTypewriter(on)
  if on and not self.typing_sound and self.app.config.play_sounds then
    self.typing_sound = self.app.audio:playSound("TYPING.WAV", nil, false, nil,
        nil, -1, LETTER_TYPING_VOLUME)
  elseif not on and self.typing_sound then
    self.app.audio:stopSound(self.typing_sound)
    self.typing_sound = nil
  end
end

--- The mouse has moved (the button under it lights up).
--- @param x (number?) x on the screen
--- @param y (number?) y on the screen
function WinLetter:onMouseMove(x, y)
  self.mouse_x, self.mouse_y = x, y
end

--- A mouse button is pressed on the movie.
---
--- While the letter is being typed, a left click finishes it. Once it is
--- typed, a left press on a button holds it down until the release
--- (onMouseUp), and a click anywhere else does nothing; a letter without
--- buttons leaves the click to the movie. Before a letter with buttons shows,
--- a click does nothing.
--- @param button (string) the mouse button ("left", "right", ...)
--- @param x (number) x on the screen
--- @param y (number) y on the screen
--- @return (boolean) # true if the letter took the click (the movie goes on)
function WinLetter:onMouseDown(button, x, y)
  if button ~= "left" then return false end
  if not self.shown then return self.choose ~= nil end
  if not self.typed then
    self.typed = true
    self:setTypewriter(false)
    return true
  end
  if not self.choose then return false end
  self.pressed = self:buttonAt(x, y)
  return true
end

--- A mouse button is released on the movie. As with the buttons of a window,
--- the letter is answered (choose) if the left button is released over the
--- button it was pressed on.
--- @param button (string) the mouse button ("left", "right", ...)
--- @param x (number) x on the screen
--- @param y (number) y on the screen
function WinLetter:onMouseUp(button, x, y)
  if button ~= "left" then return end
  local pressed = self.pressed
  self.pressed = nil
  if pressed and self:buttonAt(x, y) == pressed then
    self.choose(pressed.choice)
  end
end

--- The movie is over: stop the typewriter.
function WinLetter:close()
  self:setTypewriter(false)
end
