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

require("class_test_base")

require("utility")
require("entity")
require("entities.rat")

-- The stubbed animation manager doesn't implement getAnimLength; the rat uses it
-- to time its emerge/enter-hole animations.
TheApp.animation_manager.getAnimLength = function() return 8 end

describe("rat.lua: ", function()
  -- A fake TH animation which records the animation the rat sets, so movement
  -- can be exercised without the C++ backend.
  local function makeFakeAnimation(record)
    return {
      setHitTestResult = function() end,
      setAnimation = function(_, _, anim) record.anim = anim end,
      setTile = function() end,
      setPosition = function() end,
      setSpeed = function() end,
      getPosition = function() return 0, 0 end,
      tick = function() end,
    }
  end

  local function createRat(record, get_path)
    local rat = Rat(makeFakeAnimation(record or {}))
    rat.tile_x, rat.tile_y = 10, 10
    rat.world = {
      map = {th = {getCellFlags = function() return {roomId = 0} end},
             width = 100, height = 100},
      getLocalPlayerHospital = function()
        return {ratholes = {}, isInHospital = function() return true end}
      end,
      getPath = get_path or function() return nil end,
      destroyEntity = function() end,
    }
    return rat
  end

  it("uses a bounding-box hit test so it can be clicked", function()
    local rat = createRat()
    assert.are.equal(DrawFlags.BoundBoxHitTest, rat.permanent_flags)
  end)

  it("emerges from its hole before scurrying", function()
    local record = {}
    local rat = createRat(record, function() return {10, 11}, {10, 10} end)
    rat:init(11, 10)
    assert.are.equal(1928, record.anim) -- the leaving-hole animation
  end)

  it("faces east while walking to a tile to its east", function()
    local record = {}
    local rat = createRat(record, function() return {10, 11}, {10, 10} end)
    stub(rat.world, "destroyEntity")

    rat:init(11, 10)
    rat.timer_function(rat) -- finish the emerge animation, then start walking
    assert.are.equal("east", rat.last_move_direction)
    assert.are.equal(1912, record.anim) -- the east-facing walk animation
    assert.stub(rat.world.destroyEntity).was_not_called()
  end)

  it("is removed when there is no route, without crashing", function()
    -- Regression: an unreachable target made World:getPath return nil, and the
    -- rat then indexed a nil path.
    local rat = createRat({}, function() return nil end)
    stub(rat.world, "destroyEntity")

    assert.has_no.errors(function()
      rat:init(99, 99)
      rat.timer_function(rat) -- emerge finishes, then no route -> removed
    end)
    assert.stub(rat.world.destroyEntity).was_called_with(rat.world, rat)
  end)

  it("enters the hole before it is removed", function()
    local record = {}
    local rat = createRat(record)
    rat.target = {x = 10, y = 10, wall = "north"}
    stub(rat.world, "destroyEntity")

    rat:_enterHole()
    assert.are.equal(1924, record.anim) -- entering a north-wall hole
    rat.timer_function(rat) -- the enter-hole animation finishes
    assert.stub(rat.world.destroyEntity).was_called_with(rat.world, rat)
  end)

  it("won't take a route that passes through a room", function()
    -- The only offered path runs through a room tile (roomId ~= 0); the rat
    -- should refuse it and leave rather than clip through walls/doors.
    local rat = createRat({}, function() return {10, 11, 12}, {10, 10, 10} end)
    rat.world.map.th.getCellFlags = function(_, x, y)
      return {roomId = (x == 11 and y == 10) and 5 or 0}
    end
    stub(rat.world, "destroyEntity")

    rat:init(12, 10)
    rat.timer_function(rat) -- emerge finishes; no corridor-only route exists
    assert.stub(rat.world.destroyEntity).was_called()
  end)

  it("shoots on left-click: rewards once, splats, and is removed", function()
    local rat = createRat()
    rat.tile_x, rat.tile_y = 7, 8
    local hospital = {
      received = 0,
      receiveMoney = function(self, amount) self.received = self.received + amount end,
    }
    rat.hospital = hospital
    rat.world.newObject = function()
      return {setLitterType = function() end, setPosition = function() end}
    end
    stub(rat.world, "destroyEntity")
    local ui = {playSound = function() end}

    rat:onClick(ui, "left")
    assert.stub(rat.world.destroyEntity).was_called_with(rat.world, rat)
    assert.are.equal(5, hospital.received)

    -- A second click on the now-stale cursor entity must not fire again.
    rat:onClick(ui, "left")
    assert.stub(rat.world.destroyEntity).was_called(1)
    assert.are.equal(5, hospital.received)
  end)
end)
