--[[ Copyright (c) 2009 Peter "Corsix" Cawley

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

local object = {}
object.id = "entrance_right_door"
object.thob = 59
object.name = _S.object.entrance_right
object.tooltip = _S.tooltip.objects.entrance_right
object.class = "EntranceDoor"
object.ticks = false
object.idle_animations = {
  north = 308,
  west = 312,
}
object.supports_creation_for_map = true

class "EntranceDoor" (Object)

function EntranceDoor:EntranceDoor(world, object_type, x, y, direction, etc)
  self.is_master = object_type == object
  self:Object(world, object_type, x, y, direction, etc)
  self.occupant_count = 0
  self.is_open = false
  if self.is_master then
    local slave_type = "entrance_left_door"
    self.slave = world:getObject(x - 1, y, slave_type) or world:getObject(x, y - 1, slave_type) or nil
  end
  local anim = self.object_type.idle_animations[self.direction]
  local anims = self.world.anims
  self.anim_frames = {anims:getFirstFrame(anim)}
  while true do
    local nxt = anims:getNextFrame(self.anim_frames[#self.anim_frames])
    if nxt == self.anim_frames[1] then
      break
    end
    self.anim_frames[#self.anim_frames + 1] = nxt
  end
  self.frame_index = 1
end

function EntranceDoor:onOccupantChange(count_delta)
  self.occupant_count = self.occupant_count + count_delta
  local is_open = self.occupant_count > 0
  if is_open ~= self.is_open then
    self:playSound "eledoor2.wav"
    self.is_open = is_open
    self.ticks = true
  end
  if self.slave then
    self.slave:onOccupantChange(count_delta)
  end
end

local additional_walkable_tiles = {
  north = {
    {0, -1},
  },
  west = {
    {-1, 0},
  },
}

local additional_walkable_tiles_master = {
  north = {
    {0, -1}, {1, 0}, {1, -1},
  },
  west = {
    {-1, 0}, {0, 1}, {-1, 1},
  },
}

function EntranceDoor:setTile(x, y)
  local offsets = self.is_master and additional_walkable_tiles_master or additional_walkable_tiles
  offsets = offsets[self.direction]
  local flag_name = self.direction == "north" and "tallNorth" or "tallWest"
  
  if self.tile_x then
    if self.is_master then
      -- NB: only the tile of the door itself and the one additional tile from additional_walkable_tiles notify the door
      self.world:notifyObjectOfOccupants(self.tile_x, self.tile_y, nil)
      for _, offset in ipairs(additional_walkable_tiles[self.direction]) do
        self.world:notifyObjectOfOccupants(self.tile_x + offset[1], self.tile_y + offset[2], nil)
      end
    end
    self.world.map:setCellFlags(self.tile_x, self.tile_y, {[flag_name] = false, buildable = true, doNotIdle = false})
    for _, offset in ipairs(offsets) do
      self.world.map:setCellFlags(self.tile_x + offset[1], self.tile_y + offset[2], {buildable = true, doNotIdle = false})
    end
  end
  Object.setTile(self, x, y)
  if x then
    if self.is_master then
      self.world:notifyObjectOfOccupants(x, y, self)
      for _, offset in ipairs(additional_walkable_tiles[self.direction]) do
        self.world:notifyObjectOfOccupants(x + offset[1], y + offset[2], self)
      end
    end
    self.world.map:setCellFlags(x, y, {[flag_name] = true, buildable = false, doNotIdle = true})
    for _, offset in ipairs(offsets) do
      self.world.map:setCellFlags(x + offset[1], y + offset[2], {buildable = false, doNotIdle = true})
    end
  end
  self.world.map.th:updateShadows()
end

function EntranceDoor:getWalkableTiles()
  local result = {}
  local offsets = self.is_master and additional_walkable_tiles_master or additional_walkable_tiles
  result[1] = {self.tile_x, self.tile_y}
  for _, offset in ipairs(offsets[self.direction]) do
    result[#result + 1] = {self.tile_x + offset[1], self.tile_y + offset[2]}
  end
  return result
end

function EntranceDoor:tick()
  local target_index = self.is_open and #self.anim_frames or 1
  if self.frame_index == target_index then
    self.ticks = false
  elseif self.frame_index < target_index then
    self.frame_index = self.frame_index + 1
  elseif self.frame_index > target_index then
    self.frame_index = self.frame_index - 1
  end
  self.th:setFrame(self.anim_frames[self.frame_index])
end

return object
