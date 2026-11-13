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
    movie.win_letter = {shown = true, onMouseDown = function() return takes end}
    movie:onMouseDown("left", 100, 100)
    assert.is_false(stopped())
    takes = false
    movie:onMouseDown("left", 100, 100)
    assert.is_true(stopped())
  end)
end)

describe("The level won movie", function()
  -- The movie, as if it played, with graphics that load but draw nothing.
  -- The times it is skipped to are noted.
  local function winMovie()
    local movie, stopped = player()
    movie.playMovie = function(self) self.playing = true end
    movie.movie_length = 10000
    movie.skips = {}
    movie.moviePlayer = {skipTo = function(_, ms)
      movie.skips[#movie.skips + 1] = ms
    end}
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
    local x, y = 240 + 410 * 2.25, 421 * 2.25
    movie:onMouseDown("left", x, y)
    assert.is_nil(chosen) -- (a button answers on the release)
    assert.is_false(stopped())
    movie:onMouseUp("left", x, y)
    assert.equal(1, chosen)
    assert.is_true(stopped())
    assert.is_nil(movie.win_letter)
  end)

  it("skips to its letter, typed out in full, on a click before it shows", function()
    local movie, stopped = winMovie()
    movie:playWinLevelMovie(nil, {"Dear player"}, function() end)
    local letter = movie.win_letter
    movie:onMouseDown("right", 100, 100)
    assert.same({}, movie.skips)
    movie:onMouseDown("left", 100, 100)
    movie:onMouseUp("left", 100, 100)
    assert.same({9750}, movie.skips) -- (where the letter shows)
    assert.is_true(letter.typed)
    assert.is_false(stopped())
    -- Once it shows, a click does not skip.
    letter.shown = true
    letter.x, letter.y, letter.vs = 240, 0, 2.25
    movie:onMouseDown("left", 100, 100)
    assert.same({9750}, movie.skips)
    assert.is_false(stopped())
  end)

  it("has no letter without paragraphs", function()
    local movie = winMovie()
    movie:playWinLevelMovie(nil, {})
    assert.is_nil(movie.win_letter)
    assert.is_nil(movie.refresh_overlay)
  end)
end)
