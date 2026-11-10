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

  it("answer with the tick (first choice) or the cross (second)", function()
    local win_letter, chosen = letter(true)
    assert.equal(1, win_letter:buttonAt(at(390, 401)).choice)
    assert.equal(2, win_letter:buttonAt(at(340, 401)).choice)
    assert.is_true(win_letter:onMouseDown("left", at(390, 401)))
    assert.same({1}, chosen)
    -- The cross, on another letter.
    win_letter, chosen = letter(true)
    win_letter:onMouseDown("left", at(340, 401))
    assert.same({2}, chosen)
  end)

  it("take other clicks without an answer", function()
    local win_letter, chosen = letter(true)
    assert.is_true(win_letter:onMouseDown("left", at(200, 250))) -- on the paper
    assert.is_true(win_letter:onMouseDown("left", at(390, 360))) -- above the tick
    assert.is_false(win_letter:onMouseDown("right", at(390, 401)))
    -- Before the letter shows, a click on the tick's place does nothing.
    local early, early_chosen = letter(false)
    assert.is_true(early:onMouseDown("left", at(390, 401)))
    assert.same({}, chosen)
    assert.same({}, early_chosen)
  end)

  it("are there once a click has typed the letter out", function()
    local win_letter, chosen = letter(true, false)
    assert.is_nil(win_letter:buttonAt(at(390, 401)))
    -- A click on the tick's place: the letter is typed out.
    assert.is_true(win_letter:onMouseDown("left", at(390, 401)))
    assert.is_true(win_letter.typed)
    assert.same({}, chosen)
    assert.is_true(win_letter:onMouseDown("left", at(390, 401))) -- now the tick
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
  -- A letter whose audio notes what it is asked to do.
  local function letter(play_sounds)
    local calls = {}
    local audio = {
      playSound = function(_, ...)
        calls[#calls + 1] = {"play", ...}
        return {handle = 1}
      end,
      stopSound = function(_, sound) calls[#calls + 1] = {"stop", sound} end,
    }
    local win_letter = setmetatable({shown = true, typed = false,
        app = {audio = audio, config = {play_sounds = play_sounds}}},
        {__index = WinLetter})
    return win_letter, calls
  end

  it("strikes over and over, louder than recorded, until typed", function()
    local win_letter, calls = letter(true)
    win_letter:setTypewriter(true)
    win_letter:setTypewriter(true) -- (still typing: not started again)
    assert.equal(1, #calls)
    assert.equal("TYPING.WAV", calls[1][2])
    assert.equal(-1, calls[1][7]) -- (loops)
    assert.is_true(calls[1][8] > 1) -- (volume)
    win_letter:setTypewriter(false)
    assert.equal("stop", calls[2][1])
    assert.is_nil(win_letter.typing_sound)
  end)

  it("stops at once when a click types the letter out", function()
    local win_letter, calls = letter(true)
    win_letter:setTypewriter(true)
    win_letter:onMouseDown("left", 100, 100)
    assert.equal("stop", calls[2][1])
  end)

  it("is silent with sound effects off", function()
    local win_letter, calls = letter(false)
    win_letter:setTypewriter(true)
    assert.same({}, calls)
  end)
end)
