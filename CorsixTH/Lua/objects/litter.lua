--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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

local object = {}
object.id = "litter"
object.thob = 62 -- previously unused
object.name = _S.object.litter -- currently not shown anywhere
object.tooltip = _S.tooltip.objects.litter -- currently not shown anywhere
object.ticks = false
object.class = "Litter"

local litter_types = {}

-- All types of "litter", i.e. small objects on the ground or walls.
litter_types["pee"] = 2248
litter_types["dead_rat"] = 2242
litter_types["puke"] = 2060
litter_types["soda_can"] = 1894
litter_types["banana"] = 1896
litter_types["paper"] = 1898
litter_types["bottle"] = 1900
litter_types["soot_floor"] = 3416
litter_types["soot_wall"] = 3408
litter_types["soot_window"] = 3412

-- When randomising litter, only these should come up.
litter_types[1] = 1894
litter_types[2] = 1896
litter_types[3] = 1898
litter_types[4] = 1900

class "Litter" (Entity)

---@type Litter
local Litter = _G["Litter"]

function Litter:Litter(world, object_type, x, y, direction, etc)
  local th = TH.animation()
  self:Entity(th)
  self.object_type = object_type
  self.world = world
  self:setTile(x, y)
end

function Litter:setTile(x, y)
  Entity.setTile(self, x, y)
  if x then
    self.world:addObjectToTile(self, x, y)
  end
end
-- Litter is an Entity and not an Object so it does not inherit this method
-- This is an (effective) hack, see issue 918 --cgj
function Litter:getWalkableTiles()
  --emulate Object:getWalkableTiles() and return the tile (x,y)
  local tiles = {}
  tiles[0] = { self.tile_x, self.tile_y }
  return tiles
end

function Litter:setLitterType(anim_type, mirrorFlag)
  if anim_type then
    local anim = litter_types[anim_type]
    if anim then
      self:setAnimation(anim, mirrorFlag)
    else
      error("Unknown litter type")
    end
    if self:isCleanable() then
      local hospital = self.world:getHospital(self.tile_x, self.tile_y)
      hospital:addHandymanTask(self, "cleaning", 1, self.tile_x, self.tile_y)
    end
  end
end

--! Remove the litter from the world.
function Litter:remove()
  assert(self:isCleanable())

  self.world:removeObjectFromTile(self, self.tile_x, self.tile_y)

  local hospital = self.world:getHospital(self.tile_x, self.tile_y)
  local taskIndex = hospital:getIndexOfTask(self.tile_x, self.tile_y, "cleaning", self)
  hospital:removeHandymanTask(taskIndex, "cleaning")

  self.world:destroyEntity(self)
end

function Litter:getDrawingLayer()
  return 0
end

function Litter:vomitInducing()
  local anim = self.animation_idx
  if anim == litter_types["puke"] or
     anim == litter_types["pee"] or
     anim == litter_types["dead_rat"] then
    return true
  end
  return false
end

function Litter:isCleanable()
  return self:vomitInducing() or self:anyLitter()
end

function Litter:anyLitter()
  local anim = self.animation_idx
  if anim == litter_types["soda_can"] or
     anim == litter_types["banana"] or
     anim == litter_types["paper"] or
     anim == litter_types["bottle"] then
    return true
  end
  return false
end

function Litter:afterLoad(old, new)
  if old < 52 then
    if self.tile_x then
      self.world.hospitals[1]:addHandymanTask(self, "cleaning", 1, self.tile_x, self.tile_y)
    else
      -- This object was not properly removed from the world.
      self.world:destroyEntity(self)
    end
  end
  if old < 54 then
    if not self:isCleanable() then
      local hospital = self.world:getHospital(self.tile_x, self.tile_y)
      local taskIndex = hospital:getIndexOfTask(self.tile_x, self.tile_y, "cleaning", self)
      hospital:removeHandymanTask(taskIndex, "cleaning")
    end
  end
end

return object
