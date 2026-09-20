--[[ Copyright (c) 2026 Joshua "gojomoso1" DeVries

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

require("utility")
require("map")
require("hospital")

local Hospital = _G["Hospital"]

describe("hospital.lua: ", function()
  -- Build a minimal duck-typed hospital that reuses the real rathole/debug
  -- rat methods, with only the map and world primitives stubbed out.
  local function createHospital(opts)
    opts = opts or {}
    local map = {
      th = {getCellFlags = function() return {roomId = 0, buildable = true} end},
      width = 10,
      height = 10,
      WorldToScreen = function(_, x, y) return x * 10, y * 10 end,
    }
    setmetatable(map, {__index = Map})

    local rat_spawns = {}
    local hospital = setmetatable({
      ratholes = opts.ratholes or {},
      world = {
        map = map,
        newObject = function() return {} end,
        newEntity = function()
          return {
            setTile = function(_, x, y) rat_spawns[#rat_spawns + 1] = {x = x, y = y} end,
            setTilePositionSpeed = function() end,
            init = function() end,
          }
        end,
      },
      isInHospital = function() return true end,
      getWallsAround = opts.get_walls_around or function() return {} end,
    }, {__index = Hospital})
    return hospital, rat_spawns
  end

  it("does not spawn a debug rat when no rathole can be found or created", function()
    local hospital, rat_spawns = createHospital()
    hospital:makeDebugRat(0, 0, 100, 100)
    assert.are.equal(0, #rat_spawns)
  end)

  it("does not fall back to an off-screen rathole for the debug spawn", function()
    local off_screen_hole = {x = 50, y = 50, wall = "north"}
    local hospital, rat_spawns = createHospital({ratholes = {off_screen_hole}})
    hospital:makeDebugRat(0, 0, 10, 10)
    assert.are.equal(0, #rat_spawns)
  end)

  it("spawns from a newly created visible hole", function()
    local get_walls_around = function(_, x, y)
      if x == 1 and y == 1 then return {{wall = "north", parcel = 1}} end
      return {}
    end
    local hospital, rat_spawns = createHospital({get_walls_around = get_walls_around})
    hospital:makeDebugRat(0, 0, 100, 100)
    assert.are.equal(1, #rat_spawns)
    assert.are.equal(1, rat_spawns[1].x)
    assert.are.equal(1, rat_spawns[1].y)
  end)

  it("spawns from an existing visible hole without adding new ones", function()
    local hole_a = {x = 2, y = 2, wall = "north"}
    local hole_b = {x = 3, y = 3, wall = "west"}
    local hospital, rat_spawns = createHospital({ratholes = {hole_a, hole_b}})
    hospital:makeDebugRat(0, 0, 100, 100)
    assert.are.equal(2, #hospital.ratholes) -- no new holes were created
    assert.are.equal(1, #rat_spawns)
    assert.is_true((rat_spawns[1].x == hole_a.x and rat_spawns[1].y == hole_a.y) or
        (rat_spawns[1].x == hole_b.x and rat_spawns[1].y == hole_b.y))
  end)
end)
