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

require("corsixth")
require("class_test_base")
-- (No SDL in the unit tests: the clock of the typing is not used here.)
package.loaded["sdl"] = package.loaded["sdl"] or
    {getTicks = function() return 0 end}
require("movie_player")

local MoviePlayer = _G["MoviePlayer"]

-- A movie player that notes when it is stopped.
local function player()
  local stopped = false
  local movie = setmetatable({}, {__index = MoviePlayer})
  movie.stop = function() stopped = true end
  return movie, function() return stopped end
end

describe("Clicks on a movie", function()
  it("stop it with the left button", function()
    local movie, stopped = player()
    movie:onMouseDown("right", 100, 100)
    assert.is_false(stopped())
    movie:onMouseDown("left", 100, 100)
    assert.is_true(stopped())
  end)

  it("go to the win letter first, which may keep the movie going", function()
    local movie, stopped = player()
    local takes = true
    movie.win_letter = {onMouseDown = function() return takes end}
    movie:onMouseDown("left", 100, 100)
    assert.is_false(stopped())
    takes = false
    movie:onMouseDown("left", 100, 100)
    assert.is_true(stopped())
  end)
end)

describe("The level won movie", function()
  -- The movie, as if it played, with graphics that load but draw nothing.
  local function winMovie()
    local movie, stopped = player()
    movie.playMovie = function(self) self.playing = true end
    movie.movie_length = 10000
    local loaded = {}
    movie.app = {gfx = {
      getPalette = function() return {} end,
      loadFontAndSpriteTable = function() return loaded end,
      loadSpriteTable = function() return loaded end,
    }}
    return movie, stopped
  end

  it("ends with the answer to its letter", function()
    local movie, stopped = winMovie()
    local chosen
    movie:playWinLevelMovie(nil, {"Dear player"},
        function(choice) chosen = choice end)
    local letter = movie.win_letter
    assert.is_not_nil(letter)
    -- The letter is typed out on a 1920x1080 screen; a click on the tick.
    letter.shown, letter.typed = true, true
    letter.x, letter.y, letter.vs = 240, 0, 2.25
    movie:onMouseDown("left", 240 + 410 * 2.25, 421 * 2.25)
    assert.equal(1, chosen)
    assert.is_true(stopped())
    assert.is_nil(movie.win_letter)
  end)

  it("has no letter without paragraphs", function()
    local movie = winMovie()
    movie:playWinLevelMovie(nil, {})
    assert.is_nil(movie.win_letter)
    assert.is_nil(movie.refresh_overlay)
  end)
end)
