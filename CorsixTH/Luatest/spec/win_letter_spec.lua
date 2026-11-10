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

require("class_test_base")
-- (No SDL in the unit tests: the clock of the typing is not used here.)
package.loaded["sdl"] = package.loaded["sdl"] or
    {getTicks = function() return 0 end}
require("win_letter")

local WinLetter = _G["WinLetter"]

describe("The win letter's buttons", function()
  -- A letter on the screen: the movie drawn from (x, y) at vs screen pixels
  -- per 640x480 pixel (1920x1080: x = 240, vs = 2.25).
  local function letter(shown, typed)
    local chosen = {}
    local win_letter = setmetatable({shown = shown,
        typed = typed ~= false and shown, x = 240, y = 0, vs = 2.25,
        choose = function(choice) chosen[#chosen + 1] = choice end},
        {__index = WinLetter})
    return win_letter, chosen
  end
  -- The middle of a button at (bx, by) on the 640x480 letter, on the screen.
  local function at(bx, by) return 240 + (bx + 20) * 2.25, (by + 20) * 2.25 end
  -- A left click: the press and the release at the same place.
  local function click(win_letter, x, y)
    local took = win_letter:onMouseDown("left", x, y)
    win_letter:onMouseUp("left", x, y)
    return took
  end

  it("answer with the tick (first choice) or the cross (second)", function()
    local win_letter, chosen = letter(true)
    assert.equal(1, win_letter:buttonAt(at(390, 401)).choice)
    assert.equal(2, win_letter:buttonAt(at(340, 401)).choice)
    assert.is_true(click(win_letter, at(390, 401)))
    assert.same({1}, chosen)
    -- The cross, on another letter.
    win_letter, chosen = letter(true)
    click(win_letter, at(340, 401))
    assert.same({2}, chosen)
  end)

  it("answer on the release over the button pressed, as in a window", function()
    local win_letter, chosen = letter(true)
    -- Pressed: held down, no answer yet.
    assert.is_true(win_letter:onMouseDown("left", at(390, 401)))
    assert.same({}, chosen)
    -- Released elsewhere: no answer.
    win_letter:onMouseUp("left", at(200, 250))
    -- Pressed on the tick, released on the cross: no answer.
    win_letter:onMouseDown("left", at(390, 401))
    win_letter:onMouseUp("left", at(340, 401))
    -- Pressed on the paper, released on the tick: no answer.
    win_letter:onMouseDown("left", at(200, 250))
    win_letter:onMouseUp("left", at(390, 401))
    assert.same({}, chosen)
    -- Pressed and released on the tick.
    win_letter:onMouseDown("left", at(390, 401))
    win_letter:onMouseUp("left", at(390, 401))
    assert.same({1}, chosen)
  end)

  it("take other clicks without an answer", function()
    local win_letter, chosen = letter(true)
    assert.is_true(click(win_letter, at(200, 250))) -- on the paper
    assert.is_true(click(win_letter, at(390, 360))) -- above the tick
    assert.is_false(win_letter:onMouseDown("right", at(390, 401)))
    win_letter:onMouseUp("right", at(390, 401))
    -- Before the letter shows, a click on the tick's place does nothing.
    local early, early_chosen = letter(false)
    assert.is_true(click(early, at(390, 401)))
    assert.same({}, chosen)
    assert.same({}, early_chosen)
  end)

  it("are there once a click has typed the letter out", function()
    local win_letter, chosen = letter(true, false)
    assert.is_nil(win_letter:buttonAt(at(390, 401)))
    -- A click on the tick's place: the letter is typed out, and the release
    -- of that click does not answer it.
    assert.is_true(click(win_letter, at(390, 401)))
    assert.is_true(win_letter.typed)
    assert.same({}, chosen)
    assert.is_true(click(win_letter, at(390, 401))) -- now the tick
    assert.same({1}, chosen)
  end)

  it("are not there without an answer to give", function()
    local win_letter = letter(false)
    win_letter.choose = nil
    -- Before the letter shows, the click is left to the movie.
    assert.is_false(win_letter:onMouseDown("left", 100, 100))
    win_letter.shown = true
    assert.is_true(win_letter:onMouseDown("left", 100, 100)) -- typing: finished
    assert.is_false(win_letter:onMouseDown("left", 100, 100)) -- typed: left to the movie
    assert.is_nil(win_letter:buttonAt(at(390, 401)))
  end)
end)

describe("The win letter's typewriter", function()
  local SDL = require("sdl")
  local real_ticks = SDL.getTicks
  local now = 0
  before_each(function()
    now = 0
    SDL.getTicks = function() return now end
  end)
  after_each(function() SDL.getTicks = real_ticks end)

  -- A letter of one paragraph, drawn on nothing, whose audio notes the
  -- strikes.
  local function letter(play_sounds, text)
    local strikes = {}
    local audio = {
      playSound = function(_, name, _, _, _, _, loops, volume, pitch)
        strikes[#strikes + 1] =
            {name = name, loops = loops, volume = volume, pitch = pitch}
      end,
    }
    local font = {
      sizeOf = function(_, t) return 7 * #t, 10 end,
      draw = function() end,
    }
    local win_letter = setmetatable({shown = false, typed = false, struck = 0,
        app = {audio = audio, config = {play_sounds = play_sounds}},
        font = font, texts = {text}, bottom = 452}, {__index = WinLetter})
    return win_letter, strikes
  end
  local canvas = {scale = function() end}
  -- Frames 10 ms apart, for the given time.
  local function run(win_letter, ms)
    for _ = 1, ms / 10 do
      win_letter:draw(canvas, 0, 0, 2)
      now = now + 10
    end
  end

  it("strikes once for each character typed, at a random pitch", function()
    local win_letter, strikes = letter(true, "Dear player") -- 11 characters
    run(win_letter, 1000)
    assert.is_true(win_letter.typed)
    assert.equal(11, #strikes)
    local pitches = {}
    for _, strike in ipairs(strikes) do
      assert.equal("TYPING.WAV", strike.name)
      assert.equal(0, strike.loops) -- (once)
      assert.is_true(strike.volume > 1) -- (louder than recorded)
      assert.is_true(strike.pitch >= 0.9 and strike.pitch <= 1.1)
      pitches[strike.pitch] = true
    end
    local different = 0
    for _ in pairs(pitches) do different = different + 1 end
    assert.is_true(different > 1)
  end)

  it("types at the speed of the original game", function()
    local win_letter = letter(true, "Dear player")
    run(win_letter, 500)
    win_letter:draw(canvas, 0, 0, 2)
    -- 18 characters a second: 9 typed after half a second.
    assert.equal(9, win_letter.struck)
    assert.is_false(win_letter.typed)
  end)

  it("stops when a click types the letter out", function()
    local win_letter, strikes = letter(true, "Dear player")
    run(win_letter, 200)
    local before = #strikes
    win_letter:onMouseDown("left", 0, 0)
    run(win_letter, 1000)
    assert.is_true(win_letter.typed)
    assert.equal(before, #strikes)
  end)

  it("is silent with sound effects off", function()
    local win_letter, strikes = letter(false, "Dear player")
    run(win_letter, 1000)
    assert.is_true(win_letter.typed)
    assert.same({}, strikes)
  end)
end)
