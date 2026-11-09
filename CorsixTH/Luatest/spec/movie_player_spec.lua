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
require("movie_player")

local MoviePlayer = _G["MoviePlayer"]

describe("The win video's letter buttons", function()
  -- A movie player showing the letter: the movie drawn from (x, y) at `vs`
  -- screen pixels per 640x480 pixel (1920x1080: x = 240, vs = 2.25).
  local function player(shown, typed)
    local chosen, stopped = {}, false
    local movie = setmetatable({}, {__index = MoviePlayer})
    movie.stop = function() stopped = true end
    movie.letter = {shown = shown, typed = typed ~= false and shown,
        x = 240, y = 0, vs = 2.25,
        choose = function(choice) chosen[#chosen + 1] = choice end}
    return movie, chosen, function() return stopped end
  end
  -- The middle of a button at (bx, by) on the 640x480 letter, on the screen.
  local function at(bx, by) return 240 + (bx + 20) * 2.25, (by + 20) * 2.25 end

  it("answers with the tick (first choice) or the cross (second)", function()
    local movie, chosen, stopped = player(true)
    assert.equal(1, movie:letterButtonAt(at(390, 401)).choice)
    assert.equal(2, movie:letterButtonAt(at(340, 401)).choice)
    assert.is_true(movie:letterClick(at(390, 401)))
    assert.same({1}, chosen)
    assert.is_true(stopped())
    assert.is_nil(movie.letter)
    -- The cross, on another letter.
    movie, chosen = player(true)
    movie:letterClick(at(340, 401))
    assert.same({2}, chosen)
  end)

  it("takes other clicks without an answer, and the movie goes on", function()
    local movie, chosen, stopped = player(true)
    assert.is_true(movie:letterClick(at(200, 250))) -- on the paper
    assert.is_true(movie:letterClick(at(390, 360))) -- above the tick
    -- Before the letter shows, a click on the tick's place does nothing.
    local early, early_chosen, early_stopped = player(false)
    assert.is_true(early:letterClick(at(390, 401)))
    assert.same({}, chosen)
    assert.same({}, early_chosen)
    assert.is_false(stopped())
    assert.is_false(early_stopped())
  end)

  it("is typed out by a click, and has its buttons once typed", function()
    local movie, chosen, stopped = player(true, false)
    assert.is_nil(movie:letterButtonAt(at(390, 401)))
    -- A click on the tick's place: the letter is typed out.
    assert.is_true(movie:letterClick(at(390, 401)))
    assert.is_true(movie.letter.typed)
    assert.same({}, chosen)
    assert.is_false(stopped())
    assert.is_true(movie:letterClick(at(390, 401))) -- now the tick
    assert.same({1}, chosen)
  end)

  it("ends a letter without buttons with a click, once typed", function()
    local movie = player(false)
    movie.letter.choose = nil
    -- Before the letter shows, the click ends the movie as for any movie.
    assert.is_false(movie:letterClick(100, 100))
    movie.letter.shown = true
    assert.is_true(movie:letterClick(100, 100)) -- typing: finished
    assert.is_false(movie:letterClick(100, 100)) -- typed: the movie ends
    assert.is_nil(movie:letterButtonAt(at(390, 401)))
  end)

  it("leaves clicks to the movie without a letter", function()
    local movie = setmetatable({}, {__index = MoviePlayer})
    assert.is_false(movie:letterClick(100, 100))
    assert.is_nil(movie:letterButtonAt(100, 100))
  end)
end)

describe("The win letter's typewriter", function()
  -- A movie player whose audio notes what it is asked to do.
  local function player(play_sounds)
    local calls = {}
    local movie = setmetatable({}, {__index = MoviePlayer})
    movie.app = {config = {play_sounds = play_sounds}}
    movie.audio = {
      playSound = function(_, ...)
        calls[#calls + 1] = {"play", ...}
        return {handle = 1}
      end,
      stopSound = function(_, sound) calls[#calls + 1] = {"stop", sound} end,
    }
    return movie, calls
  end

  it("strikes over and over, louder than recorded, until typed", function()
    local movie, calls = player(true)
    movie:letterTyping(true)
    movie:letterTyping(true) -- (still typing: not started again)
    assert.equal(1, #calls)
    assert.equal("TYPING.WAV", calls[1][2])
    assert.equal(-1, calls[1][7]) -- (loops)
    assert.is_true(calls[1][8] > 1) -- (volume)
    movie:letterTyping(false)
    assert.equal("stop", calls[2][1])
    assert.is_nil(movie.typing_sound)
  end)

  it("is silent with sound effects off", function()
    local movie, calls = player(false)
    movie:letterTyping(true)
    assert.same({}, calls)
  end)
end)
