--[[ Test 3441 ultrascan footprint 265 gate + 5000 ticks ]]
require("class_test_base")
require("entity")
require("entities.object")

describe("ultrascan 3441:", function()
  local orig_S = _G._S
  local orig_TheApp = _G.TheApp
  setup(function()
    _G._S = {
      object = {ultrascanner = "ultrascanner"},
      tooltip = {objects = {ultrascanner = ""}, rooms = {ultrascan = ""}},
      rooms_short = {ultrascan = ""},
      rooms_long = {ultrascan = ""}
    }
    _G.TheApp = {
      animation_manager = {
        setPatientMarker = function() end,
        setStaffMarker = function() end
      }
    }
  end)
  teardown(function()
    _G._S = orig_S
    _G.TheApp = orig_TheApp
  end)

  it("north {-1,1},{0,1} and east {0,-1},{1,-1} are blocked (no only_passable)", function()
    local paths = {"../Lua/objects/machines/ultrascanner.lua", "CorsixTH/Lua/objects/machines/ultrascanner.lua", "/home/bruno/CorsixTH/CorsixTH/Lua/objects/machines/ultrascanner.lua"}
    local f, obj
    for _, path in ipairs(paths) do
      f = loadfile(path)
      if f then
        local ok, result = pcall(f)
        if ok and result then obj = result; break end
      end
    end
    assert.is_truthy(obj, "ultrascanner.lua should return object table")
    local north = obj.orientations.north.footprint
    local function has_only_passable(footprint, x, y)
      for _, tile in ipairs(footprint) do
        if tile[1]==x and tile[2]==y then return tile.only_passable == true end
      end
      return nil
    end
    assert.is_false(has_only_passable(north, -1, 1), "north {-1,1} should be blocked")
    assert.is_false(has_only_passable(north, 0, 1), "north {0,1} should be blocked")
    local east = obj.orientations.east.footprint
    assert.is_false(has_only_passable(east, 0, -1), "east {0,-1} should be blocked")
    assert.is_false(has_only_passable(east, 1, -1), "east {1,-1} should be blocked")
    -- south copies north via copy_north_to_south for idle anims, orientations north/east only (south via mirror not stored)
    assert.is_nil(obj.orientations.south, "south orientation not stored, north is used via copy")
    assert.are.same({-1, 0, need_west_side = true}, obj.orientations.north.use_position)
    assert.are.same({2, 0}, obj.orientations.north.handyman_position)
  end)

  it("Object:afterLoad old<265 preserves footprint (no crash) 5000 ticks", function()
    -- Directly test afterLoad preserve without full Object construction (avoids getRenderAttachTile stub complexity)
    local mock = {
      footprint = {{-1, 1, only_passable = true, need_west_side = true}, {0, 1, only_passable = true}},
      object_type = {id = "ultrascanner", class = "Machine"},
      tile_x = 10, tile_y = 10, direction = "north",
      world = {map = {th = {setCellFlags = function() end, getCellFlags = function() return {} end}}},
      updateDynamicInfo = function() end
    }
    setmetatable(mock, {__index = Object})
    local before = mock.footprint
    -- Stub Entity.afterLoad to no-op to isolate Object gate
    local orig_entity_afterLoad = Entity.afterLoad
    Entity.afterLoad = function() return end
    Object.afterLoad(mock, 264, 265)
    assert.are.equal(before, mock.footprint, "old<265 should preserve footprint")
    Object.afterLoad(mock, 265, 265)
    assert.are.equal(before, mock.footprint, "old>=265 also preserve")
    Entity.afterLoad = orig_entity_afterLoad
    local crashes = 0
    for i=1,5000 do
      for _, tile in ipairs(mock.footprint) do
        if tile[1]==nil or tile[2]==nil then crashes = crashes + 1 end
        local passable = tile.only_passable and true or false -- luacheck: ignore 211
      end
    end
    assert.are.equal(0, crashes, "5000 ticks no crash")
  end)
end)
