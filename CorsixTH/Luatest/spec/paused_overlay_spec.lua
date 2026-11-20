--[[ Copyright (c) 2026 CorsixTH contributors
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. --]]

require("corsixth")
require("class_test_base")
require("utility")
require("map")
require("window")
require("dialogs.edit_room")

local Map = _G["Map"]
local UIEditRoom = _G["UIEditRoom"]

describe("paused room blueprint debug overlay", function()
  local function makeRoomEditor()
    local native = {}
    local flags_by_tile = {}
    local read_count = 0
    local write_count = 0
    function native:getCellFlags(x, y, flags)
      read_count = read_count + 1
      local stored = flags_by_tile[x .. ":" .. y] or {}
      flags.passable = stored.passable ~= false
      flags.avoidTile = stored.avoidTile or false
      flags.thob = 0
      flags.roomId = 0
    end
    function native:setCellFlags(x, y, flags)
      write_count = write_count + 1
      local key = x .. ":" .. y
      local stored = flags_by_tile[key] or {}
      -- As in the native setter, unspecified flags retain their values.
      if flags.avoidTile ~= nil then stored.avoidTile = flags.avoidTile end
      if flags.passable ~= nil then stored.passable = flags.passable end
      flags_by_tile[key] = stored
    end
    local map = setmetatable({width = 3, height = 3, th = native,
      debug_tick_timer = 7}, {__index = Map})
    local editor = setmetatable({
      ui = {app = {map = map}},
      blueprint_rect = {x = 1, y = 1, w = 2, h = 2},
    }, {__index = UIEditRoom})
    return map, editor, function() return read_count, write_count end
  end

  it("updates the cached avoid flags immediately in both directions without ticks", function()
    local map, editor = makeRoomEditor()
    map:loadDebugText("flags")
    assert.is_false(map.debug_flags[0].avoidTile)
    editor:_setCellFlagsOnBlueprint({avoidTile = true})
    assert.is_true(map.debug_flags[0].avoidTile)
    assert.is_true(map.debug_flags[1].avoidTile)
    assert.is_true(map.debug_flags[3].avoidTile)
    assert.is_true(map.debug_flags[4].avoidTile)
    assert.is_false(map.debug_flags[8].avoidTile)
    editor:_setCellFlagsOnBlueprint({avoidTile = false})
    assert.is_false(map.debug_flags[0].avoidTile)
    assert.is_false(map.debug_flags[4].avoidTile)
    assert.equals(7, map.debug_tick_timer)
  end)

  it("does not scan the overlay for transient passability probes", function()
    local map, editor, counts = makeRoomEditor()
    map:loadDebugText("flags")
    local initial_reads, initial_writes = counts()
    editor:_setCellFlagsOnBlueprint({passable = false})
    editor:_setCellFlagsOnBlueprint({passable = true})
    local reads, writes = counts()
    assert.equals(initial_reads, reads)
    assert.equals(initial_writes + 8, writes)
    assert.is_true(map.debug_flags[0].passable)
    assert.is_false(map.debug_flags[0].avoidTile)
    assert.equals(7, map.debug_tick_timer)
  end)

  it("scans only once on a successful real door-phase transition", function()
    local map, editor, counts = makeRoomEditor()
    map:loadDebugText("flags")
    local initial_reads, initial_writes = counts()
    editor.world = {clearCaches = function() end}
    editor.ui.app.world = editor.world
    editor.ui.tutorialStep = function() end
    editor.confirm_button = {enable = function() end}
    editor.blueprint_wall_anims = {}
    editor.checkReachability = function() return true end
    editor._humanoidsInArea = function() return {} end
    map.th.setCell = function() end

    local strings = _G._S
    _G._S = {place_objects_window = {place_door = "Place door"}}
    local ok, err = pcall(function() editor:_enterDoorPhase() end)
    _G._S = strings
    assert.is_true(ok, err)
    local reads, writes = counts()
    assert.equals("door", editor.phase)
    assert.equals(initial_reads + 9, reads)
    assert.equals(initial_writes + 12, writes)
    assert.is_true(map.debug_flags[0].avoidTile)
    assert.is_true(map.debug_flags[4].avoidTile)
    assert.is_true(map.debug_flags[0].passable)
    assert.equals(7, map.debug_tick_timer)
  end)

  it("restores passability without a refresh on rejected reachability", function()
    local map, editor, counts = makeRoomEditor()
    map:loadDebugText("flags")
    local initial_reads, initial_writes = counts()
    editor.checkReachability = function() return false end
    editor.ui.app.config = {blocking_off_areas = 1}
    assert.is_false(editor:_checkCanBuildRoomHere())
    local reads, writes = counts()
    assert.equals(initial_reads, reads)
    assert.equals(initial_writes + 8, writes)
    assert.is_true(map.debug_flags[0].passable)
    assert.is_false(map.debug_flags[0].avoidTile)
  end)

  it("does not read the map when the debug flags overlay is disabled", function()
    local map, editor, get_read_count = makeRoomEditor()
    map.debug_flags = false
    editor:_setCellFlagsOnBlueprint({avoidTile = true})
    assert.equals(0, get_read_count())
    map.debug_flags = nil
    editor:_setCellFlagsOnBlueprint({avoidTile = false})
    assert.equals(0, get_read_count())
  end)

  it("renders green, yellow, then green when room avoidance changes while paused", function()
    local map, editor = makeRoomEditor()
    map:loadDebugText("flags")
    local tile = map.debug_flags[0]
    tile.hospital = true
    tile.buildable = true
    tile.travelEast = true
    local sprites = {}
    map.cell_outline = {draw = function(_, _, sprite)
      sprites[#sprites + 1] = sprite
    end}
    local function checkSprites(expected)
      sprites = {}
      map:_drawDebugTiles(nil, 0, 0, 0, 0)
      assert.same(expected, sprites)
    end

    checkSprites({3, 8, 9, 5})
    editor:_setCellFlagsOnBlueprint({avoidTile = true})
    checkSprites({27, 8, 9, 5})
    editor:_setCellFlagsOnBlueprint({avoidTile = false})
    checkSprites({3, 8, 9, 5})
    assert.equals(7, map.debug_tick_timer)
  end)

  it("refreshes on door phase entry and cancellation without ticks", function()
    local map, editor = makeRoomEditor()
    map:loadDebugText("flags")
    editor.world = {clearCaches = function() end}
    editor.ui.app.world = editor.world
    editor.ui.tutorialStep = function() end
    editor.confirm_button = {enabled = true, enable = function(self, enabled)
      self.enabled = enabled
    end}
    editor.phase = "walls"
    editor.blueprint_wall_anims = {}
    editor.room_type = {}
    editor._checkCanBuildRoomHere = function() return true end
    editor._humanoidsInArea = function() return {} end
    editor.setBlueprintRect = function() end
    map.th.setCell = function() end

    local strings = _G._S
    _G._S = {place_objects_window = {
      place_door = "Place door", drag_blueprint = "Drag blueprint",
    }}
    local ok, err = pcall(function()
      editor:confirm()
      assert.equals("door", editor.phase)
      assert.is_true(map.debug_flags[0].avoidTile)
      assert.is_true(map.debug_flags[4].avoidTile)
      editor:cancel()
      assert.equals("walls", editor.phase)
      assert.is_false(map.debug_flags[0].avoidTile)
      assert.is_false(map.debug_flags[4].avoidTile)
      assert.equals(7, map.debug_tick_timer)
    end)
    _G._S = strings
    assert.is_true(ok, err)
  end)

  it("does not reset the periodic refresh timer after the immediate refresh", function()
    local map, editor = makeRoomEditor()
    map:loadDebugText("flags")
    editor:_setCellFlagsOnBlueprint({avoidTile = true})
    map:onTick()
    assert.equals(6, map.debug_tick_timer)
    assert.is_true(map.debug_flags[0].avoidTile)
  end)
end)
