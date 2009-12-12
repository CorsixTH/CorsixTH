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

function Object:getRenderAttachTile()
  local x, y = self.tile_x, self.tile_y
  local offset = self.object_type.orientations
  if offset then
    offset = offset[self.direction].render_attach_position
    x = x + offset[1]
    y = y + offset[2]
  end
  return x, y
end

function Object:getSecondaryUsageTile()
  local x, y = self.tile_x, self.tile_y
  local offset = self.object_type.orientations
  if offset then
    offset = offset[self.direction].use_position_secondary
    x = x + offset[1]
    y = y + offset[2]
  end
  return x, y
end

function Object:setTile(x, y)
  if self.tile_x ~= nil then
    self.world:removeObjectFromTile(self, self.tile_x, self.tile_y)
    if self.footprint then
      local map = self.world.map.th
      for _, xy in ipairs(self.footprint) do
        map:setCellFlags(self.tile_x + xy[1], self.tile_y + xy[2], {
          buildable = true,
          passable = true,
        })
      end
    end
  end
  self.tile_x = x
  self.tile_y = y
  if x then
    self.th:setTile(self.world.map.th, self:getRenderAttachTile())
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
  else
    self.th:setTile(nil)
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

local all_pathfind_dirs = {[0] = true, [1] = true, [2] = true, [3] = true}

function Object.processTypeDefinition(object_type)
  if object_type.orientations then
    for direction, details in pairs(object_type.orientations) do
      -- Set default values
      if not details.animation_offset then
        details.animation_offset = {0, 0}
      end
      if not details.render_attach_position then
        details.render_attach_position = {0, 0}
      end
      -- Set the usage position
      if details.use_position == "passable" then
        -- "passable" => the *first* passable tile in the footprint list
        for _, point in pairs(details.footprint) do
          if point.only_passable then
            details.use_position = {point[1], point[2]}
            break
          end
        end
      elseif not details.use_position then
        details.use_position = {0, 0}
      end
      -- Find the nearest solid tile in the footprint to the usage position
      local use_position = details.use_position
      local solid_near_use_position
      local solid_near_use_position_d = 10000
      for _, point in pairs(details.footprint) do repeat
        if point.only_passable then
          break -- continue
        end
        local d = (point[1] - use_position[1])^2 + (point[2] - use_position[2])^2
        if d >= solid_near_use_position_d then
          break -- continue
        end
        solid_near_use_position = point
        solid_near_use_position_d = d
      until true end
      if solid_near_use_position_d ~= 1 then
        details.pathfind_allowed_dirs = all_pathfind_dirs
      else
        if use_position[1] < solid_near_use_position[1] then
          details.pathfind_allowed_dirs = {[1] = true}
        elseif use_position[1] > solid_near_use_position[1] then
          details.pathfind_allowed_dirs = {[3] = true}
        elseif use_position[2] < solid_near_use_position[2] then
          details.pathfind_allowed_dirs = {[2] = true}
        else
          details.pathfind_allowed_dirs = {[0] = true}
        end
      end
      -- Adjust the footprint to make this tile the origin
      local x, y = unpack(solid_near_use_position)
      local solid_points = {}
      for _, point in pairs(details.footprint) do
        point[1] = point[1] - x
        point[2] = point[2] - y
        if not point.only_passable then
          solid_points[point[1] * 100 + point[2]] = point
        end
      end
      for _, key in ipairs{"use_position_secondary", "finish_use_position", "finish_use_position_secondary"} do
        if details[key] then
          details[key][1] = details[key][1] - x
          details[key][2] = details[key][2] - y
        end
      end
      use_position[1] = use_position[1] - x
      use_position[2] = use_position[2] - y
      local rx, ry = unpack(details.render_attach_position)
      details.render_attach_position[1] = rx - x
      details.render_attach_position[2] = ry - y
      x, y = Map:WorldToScreen(rx + 1, ry + 1)
      details.animation_offset[1] = details.animation_offset[1] - x
      details.animation_offset[2] = details.animation_offset[2] - y
      -- Find the region around the solid part of the footprint
      local adjacent_set = {}
      local adjacent_list = {}
      details.adjacent_to_solid_footprint = adjacent_list
      for k, point in pairs(solid_points) do
        for _, delta in ipairs{{-1, 0}, {0, -1}, {0, 1}, {1, 0}} do
          local x = point[1] + delta[1]
          local y = point[2] + delta[2]
          local k2 = x * 100 + y
          if not solid_points[k2] and not adjacent_set[k2] then
            adjacent_set[k2] = {x, y}
            adjacent_list[#adjacent_list+1] = adjacent_set[k2]
          end
        end
      end
    end
  end
end
