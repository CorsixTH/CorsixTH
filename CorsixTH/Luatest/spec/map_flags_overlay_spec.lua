require("corsixth")
require("class_test_base")
require("utility")
require("map")

local Map = _G["Map"]

describe("Map flags overlay", function()
it("marks avoided tiles whether or not they are passable", function()
    local sprites = {}
    local flags = {passable = true, avoidTile = true, thob = 0, roomId = 0}
    local map = setmetatable({
      width = 2,
      debug_flags = {[0] = flags},
      cell_outline = {draw = function(_, _, sprite)
        sprites[#sprites + 1] = sprite
      end},
    }, {__index = Map})
    map:_drawDebugTiles(nil, 0, 0, 0, 0)
    assert.same({27}, sprites)

    sprites = {}
    flags.passable = false
    map:_drawDebugTiles(nil, 0, 0, 0, 0)
    assert.same({27}, sprites)

    sprites = {}
    flags.avoidTile = false
    map:_drawDebugTiles(nil, 0, 0, 0, 0)
    assert.same({}, sprites)

    sprites = {}
    flags.passable = true
    map:_drawDebugTiles(nil, 0, 0, 0, 0)
    assert.same({3}, sprites)
  end)

  it("draws hospital and directional flags over an avoided yellow tile", function()
    local sprites = {}
    local map = setmetatable({
      width = 2, height = 2,
      debug_flags = {
        [0] = {
          passable = true, avoidTile = true, hospital = true,
          buildable = true, travelEast = true, travelSouth = true,
          thob = 0, roomId = 0,
        },
        [1] = {passable = true},
        [2] = {passable = true},
      },
      cell_outline = {draw = function(_, _, sprite)
        sprites[#sprites + 1] = sprite
      end},
    }, {__index = Map})

    map:_drawDebugTiles(nil, 0, 0, 0, 0)
    assert.same({27, 8, 9, 5, 6}, sprites)
  end)

it("does not read outside the map or wrap travel neighbours across rows", function()
    local sprites = {}
    local flags = {}
    for i = 0, 5 do
      flags[i] = {
        passable = true,
        travelNorth = true, travelEast = true,
        travelSouth = true, travelWest = true,
        thob = 0, roomId = 0,
      }
    end
    local map = setmetatable({
      width = 3, height = 2, debug_flags = flags,
      cell_outline = {draw = function(_, _, sprite)
        sprites[#sprites + 1] = sprite
      end},
    }, {__index = Map})

    local function assertSprites(x, y, expected)
      sprites = {}
      map:_drawDebugTiles(nil, x, y, 0, 0)
      assert.same(expected, sprites)
    end

    -- In all cases the passable tile marker (3) is followed by only valid
    -- directional markers: north (4), east (5), south (6), west (7).
    assertSprites(0, 0, {3, 5, 6})
    assertSprites(2, 0, {3, 6, 7})
    assertSprites(0, 1, {3, 4, 5})
    assertSprites(2, 1, {3, 4, 7})
    assertSprites(1, 0, {3, 5, 6, 7})
    assertSprites(1, 1, {3, 4, 5, 7})
  end)

  it("handles 1x1, single-row and single-column maps", function()
    local function markers(width, height, x, y)
      local seen = {}
      local flags = {}
      for index = 0, width * height - 1 do
        flags[index] = {
          passable = true, travelNorth = true, travelEast = true,
          travelSouth = true, travelWest = true, thob = 0, roomId = 0,
        }
      end
      local map = setmetatable({
        width = width, height = height, debug_flags = flags,
        cell_outline = {draw = function(_, _, sprite)
          seen[#seen + 1] = sprite
        end},
      }, {__index = Map})
      map:_drawDebugTiles(nil, x, y, 0, 0)
      return seen
    end

    assert.same({3}, markers(1, 1, 0, 0))
    assert.same({3, 6}, markers(1, 3, 0, 0))
    assert.same({3, 4, 6}, markers(1, 3, 0, 1))
    assert.same({3, 4}, markers(1, 3, 0, 2))
    assert.same({3, 5}, markers(3, 1, 0, 0))
    assert.same({3, 5, 7}, markers(3, 1, 1, 0))
    assert.same({3, 7}, markers(3, 1, 2, 0))
  end)
end)
