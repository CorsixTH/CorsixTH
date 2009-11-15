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

local TH = require "TH"
dofile "entity"

class "Object" (Entity)

local orient_mirror = {
  north = "west",
  west = "north",
  east = "south",
  south = "east",
}

function Object:Object(world, object_type, x, y, direction, etc)
  local th = TH.animation()
  self:Entity(th)
  
  if etc == "map object" then
    if direction % 2 == 0 then
      direction = "north"
    else
      direction = "west"
    end
  end
  
  self.ticks = object_type.ticks
  self.object_type = object_type
  self.world = world
  self.direction = direction
  self.user = false

  local flags = self.init_anim_flags or 0
  local anim = object_type.idle_animations[direction]
  if not anim then
    anim = object_type.idle_animations[orient_mirror[direction]]
    flags = 1
  end
  local footprint = object_type.orientations
  footprint = footprint and footprint[direction]
  if footprint and footprint.early_list then
    flags = flags + 1024
  end
  if footprint and footprint.animation_offset then
    self:setPosition(unpack(footprint.animation_offset))
  end
  footprint = footprint and footprint.footprint
  if footprint then
    self.footprint = footprint
  end
  self:setAnimation(anim, flags)
  self:setTile(x, y)
end

function Object:setTile(x, y)
  if self.tile_x ~= nil then
    self.world:removeObjectFromTile(self, self.tile_x, self.tile_y)
  end
  Entity.setTile(self, x, y)
  if x then
    self.world:addObjectToTile(self, x, y)
    if self.footprint then
      local map = self.world.map.th
      for _, xy in ipairs(self.footprint) do
        map:setCellFlags(x + xy[1], y + xy[2], {
          buildable = false,
          passable = not not xy.only_passable,
        })
      end
    end
  end
  self.world:clearCaches()
  return self
end

function Object:setUser(user)
  self.user = user or false
  if user then
    self.th:makeInvisible()
    self.reserved_for = nil
  else
    self.th:makeVisible()
  end
end

function Object.processTypeDefinition(object_type)
  if object_type.orientations then
    for direction, details in pairs(object_type.orientations) do
      if not details.animation_offset then
        details.animation_offset = {0, 0}
      end
      if details.footprint_origin then
        local x, y = unpack(details.footprint_origin)
        for _, point in pairs(details.footprint) do
          point[1] = point[1] - x
          point[2] = point[2] - y
        end
        x, y = Map:WorldToScreen(x + 1, y + 1)
        details.animation_offset[1] = details.animation_offset[1] - x
        details.animation_offset[2] = details.animation_offset[2] - y
      end
    end
  end
end
