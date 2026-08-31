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

  -- Create a rat at tile (10, 10) with a single rathole B to run to, and a
  -- straight two-tile corridor path towards it.
  local function createRat(record, opts)
    opts = opts or {}
    local rat = Rat(makeFakeAnimation(record or {}))
    rat.tile_x, rat.tile_y = 10, 10
    local hole_b = {x = 11, y = 10, wall = opts.target_wall or "north"}
    rat.world = {
      map = {th = {getCellFlags = function() return {roomId = 0} end},
             width = 100, height = 100},
      getLocalPlayerHospital = function()
        return {ratholes = opts.no_holes and {} or {hole_b},
                isInHospital = function() return true end}
      end,
      getPath = opts.get_path or function() return {10, 11}, {10, 10} end,
      destroyEntity = function() end,
    }
    return rat
  end

  it("uses a bounding-box hit test so it can be clicked", function()
    local rat = createRat()
    assert.are.equal(DrawFlags.BoundBoxHitTest, rat.permanent_flags)
  end)

  it("plays the leaving animation when emerging from a north hole", function()
    local record = {}
    local rat = createRat(record)
    rat:init("north")
    assert.are.equal(1928, record.anim) -- the leaving-hole animation
  end)

  it("runs straight away when emerging from a hidden (east/south) hole", function()
    local record = {}
    local rat = createRat(record)
    rat:init("east") -- no leaving animation, so it starts walking immediately
    assert.are.equal(1912, record.anim) -- the east-facing walk animation
  end)

  it("faces east while walking to a tile to its east", function()
    local record = {}
    local rat = createRat(record)
    stub(rat.world, "destroyEntity")

    rat:init("north")
    rat.timer_function(rat) -- finish the emerge animation, then start walking
    assert.are.equal("east", rat.last_move_direction)
    assert.are.equal(1912, record.anim)
    assert.stub(rat.world.destroyEntity).was_not_called()
  end)

  it("won't take a route that passes through a room", function()
    -- The only offered path runs through a room tile (roomId ~= 0); the rat
    -- should refuse it and leave rather than clip through walls/doors.
    local rat = createRat({}, {no_holes = true,
        get_path = function() return {10, 11, 12}, {10, 10, 10} end})
    rat.world.map.th.getCellFlags = function(_, x, y)
      return {roomId = (x == 11 and y == 10) and 5 or 0}
    end
    stub(rat.world, "destroyEntity")

    rat:init("east")
    assert.stub(rat.world.destroyEntity).was_called()
  end)

  it("enters the target hole and is removed on arrival", function()
    local record = {}
    local rat = createRat(record, {target_wall = "west"})
    stub(rat.world, "destroyEntity")

    rat:init("east") -- emerge from a hidden hole and run east to the west hole
    rat.timer_function(rat) -- arrive at the target tile
    assert.are.equal(1926, record.anim) -- entering a west-wall hole
    rat.timer_function(rat) -- the enter-hole animation finishes
    assert.stub(rat.world.destroyEntity).was_called_with(rat.world, rat)
  end)

  it("shoots on left-click: splats and is removed, only once", function()
    local rat = createRat()
    rat.tile_x, rat.tile_y = 7, 8
    rat.world.newObject = function()
      return {setLitterType = function() end, setPosition = function() end}
    end
    stub(rat.world, "destroyEntity")
    local ui = {playSound = function() end}

    rat:onClick(ui, "left")
    assert.stub(rat.world.destroyEntity).was_called_with(rat.world, rat)

    -- A second click on the now-stale cursor entity must not fire again.
    rat:onClick(ui, "left")
    assert.stub(rat.world.destroyEntity).was_called(1)
  end)
end)
