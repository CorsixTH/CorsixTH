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

--! An `Entity` which occupies at least a single map tile and does not move.
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
  self.user = false
  self.times_used = -1 -- Incremented in the call on the next line
  self:updateDynamicInfo()
  self:initOrientation(direction)
  self:setTile(x, y)
end

--! Initializes the footprint, finds out what to draw and checks for
--  split animations.
--!param direction The orientation in which the object is facing.
function Object:initOrientation(direction)
  self.direction = direction
  local object_type = self.object_type
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
  if footprint and footprint.list_bottom then
    flags = flags + 2048
  end
  local rap = footprint and footprint.render_attach_position
  if rap and rap[1] and type(rap[1]) == "table" then
    self.split_anims = {self.th}
    self.split_anim_positions = rap
    self.th:setCrop(rap[1].column)
    for i = 2, #rap do
      local point = rap[i]
      local th = TH.animation()
      th:setCrop(point.column)
      th:setHitTestResult(self)
      th:setPosition(Map:WorldToScreen(1-point[1], 1-point[2]))
      self.split_anims[i] = th
    end
  else
    -- Make sure these variables aren't left behind. The object
    -- might just have been moved and rotated.
    self.split_anims = nil
    self.split_anim_positions = nil
  end
  if footprint and footprint.animation_offset then
    self:setPosition(unpack(footprint.animation_offset))
  end
  footprint = footprint and footprint.footprint
  if footprint then
    self.footprint = footprint
  else
    self.footprint = nil
  end
  self:setAnimation(anim, flags)
end

--! Add methods to a class for creating and controlling a slave object
function Object.slaveMixinClass(class_method_table)
  local name = class.name(class_method_table)
  local super = class.superclass(class_method_table)
  local super_constructor = super[class.name(super)]
  
  -- Constructor
  class_method_table[name] = function(self, world, object_type, x, y, direction, ...)
    super_constructor(self, world, object_type, x, y, direction, ...)
    if object_type.slave_id then
      local orientation = object_type.orientations
      orientation = orientation and orientation[direction]
      if orientation.slave_position then
        x = x + orientation.slave_position[1]
        y = y + orientation.slave_position[2]
      end
      self.slave = world:newObject(object_type.slave_id, x, y, direction, ...)
      self.slave.master = self
    end
  end
  
  -- Slave -> Master redirects
  local function slave_to_master(method)
    local super_method = super[method]
    class_method_table[method] = function(self, ...)
      local master = self.master
      if master then
        return master[method](master, ...)
      else
        return super_method(self, ...)
      end
    end
  end
  slave_to_master("onClick")
  slave_to_master("updateDynamicInfo")
  slave_to_master("getDynamicInfo")
  
  -- Master -> Slave notifications
  local function master_to_slave(method)
    local super_method = super[method]
    class_method_table[method] = function(self, ...)
      local slave = self.slave
      if slave then
        slave[method](slave, ...)
      end
      return super_method(self, ...)
    end
  end
  master_to_slave("initOrientation")
  class_method_table.onDestroy = function(self, ...)
    local slave = self.slave
    if slave then
      self.world:destroyEntity(slave)
    end
    return super.onDestroy(self, ...)
  end
  class_method_table.setTile = function(self, x, y)
    if self.slave then
      local dx, dy = 0, 0
      local orientation = self.object_type.orientations
      orientation = orientation and orientation[self.direction]
      if orientation.slave_position then
        dx = orientation.slave_position[1]
        dy = orientation.slave_position[2]
      end
      if x then
        self.slave:setTile(x + dx, y + dy)
      else
        self.slave:setTile(x, y)
      end
    end
    return super.setTile(self, x, y)
  end
  
  return slave_to_master, master_to_slave
end

function Object:tick()
  if self.split_anims then
    if self.num_animation_ticks then
      for i = 2, #self.split_anims do
        local th = self.split_anims[i]
        for i = 1, self.num_animation_ticks do
          th:tick()
        end
      end
    else
      for i = 2, #self.split_anims do
        self.split_anims[i]:tick()
      end
    end
  end
  return Entity.tick(self)
end

function Object:setPosition(x, y)
  if self.split_anims then
    -- The given position is for the primary tile, so position non-primary
    -- animations relative to the primary one.
    local bx, by = unpack(self.split_anim_positions[1])
    for i, th in ipairs(self.split_anims) do
      local point = self.split_anim_positions[i]
      local dx, dy = Map:WorldToScreen(1-point[1]+bx, 1-point[2]+by)
      th:setPosition(x + dx, y + dy)
    end
  else
    self.th:setPosition(x, y)
  end
  return self
end

function Object:setAnimation(animation, flags)
  if self.split_anims then
    flags = (flags or 0) + DrawFlags.Crop
    if self.permanent_flags then
      flags = flags + self.permanent_flags
    end
    if animation ~= self.animation_idx or flags ~= self.animation_flags then
      self.animation_idx = animation
      self.animation_flags = flags
      local anims = self.world.anims
      for _, th in ipairs(self.split_anims) do
        th:setAnimation(anims, animation, flags)
      end
    end
    return self
  else
    return Entity.setAnimation(self, animation, flags)
  end
end

--! Get the primary tile which the object is attached to for rendering
--[[! For objects which attach to a single tile for rendering, this method will
return the X and Y Lua world co-ordinates of that tile. For objects which split
their rendering over multiple tiles, one of them is arbitrarily designated as
the primary tile, and its co-ordinates are returned.
]]
function Object:getRenderAttachTile()
  local x, y = self.tile_x, self.tile_y
  local offset = self.object_type.orientations
  if x and offset then
    offset = offset[self.direction].render_attach_position
    if self.split_anims then
      offset = offset[1]
    end
    x = x + offset[1]
    y = y + offset[2]
  end
  return x, y
end

function Object:updateDynamicInfo()
  self.times_used = self.times_used + 1
  local object = self.object_type
  if object.dynamic_info then
    self:setDynamicInfo("text", {object.name, "", _S.dynamic_info.object.times_used:format(self.times_used)})
  end
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

-- This function returns a list of all "only_passable" tiles belonging to an object.
-- It must be overridden by objects which do not have a footprint, but walkable tiles (e.g. doors of any kind)
function Object:getWalkableTiles()
  local tiles = {}
  for _, xy in ipairs(self.footprint) do
    if xy.only_passable then
      tiles[#tiles + 1] = { self.tile_x + xy[1], self.tile_y + xy[2] }
    end
  end
  return tiles
end

function Object:setTile(x, y)
  if self.tile_x ~= nil then
    self.world:removeObjectFromTile(self, self.tile_x, self.tile_y)
    if self.footprint then
      local map = self.world.map.th
      for _, xy in ipairs(self.footprint) do
        local x, y = self.tile_x + xy[1], self.tile_y + xy[2]
        
        if not map:getCellFlags(x, y).passable then
          map:setCellFlags(x, y, {
            buildable = true,
            passable = true,
          })
        else
          -- passable tiles can "belong" to multiple objects, so we have to check that
          if not self.world:isTilePartOfNearbyObject(x, y, 10) then
            -- assumption: no object defines a passable tile further than 10 tiles away from its origin
            map:setCellFlags(x, y, {
              buildable = true,
            })
          end
        end
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
      local optional_found = false
      local flags = {}
      local room = self.world:getRoom(x, y)
      local roomId = room and room.id

      for _, xy in ipairs(self.footprint) do
        local change_flags = true
        local lx = x + xy[1]
        local ly = y + xy[2]

        if xy.optional then
          if optional_found then
            -- An optional tile has been accepted, we don't need anymore such tiles.
            change_flags = false
          else
            -- Check if this optional tile is acceptable
            local flag = "buildable"
            if xy.only_passable then
              flag = "passable"
            end
            local cell_flags = map:getCellFlags(lx, ly, flags)[flag]
            local is_object_allowed = true
            if roomId and flags.roomId ~= roomId then
              is_object_allowed = false
            elseif xy.only_passable and not self.world.pathfinder:isReachableFromHospital(lx, ly) then
              is_object_allowed = false
            end
            if is_object_allowed then
              change_flags = true
              optional_found = true
            else
              change_flags = false
            end
          end
        end
        if change_flags then
          map:setCellFlags(lx, ly, {
            buildable = false,
            passable = not not xy.only_passable,
          })
        end
      end
    end
    if self.split_anims then
      local map = self.world.map.th
      local pos = self.split_anim_positions
      for i = 2, #self.split_anims do
        self.split_anims[i]:setTile(map, x + pos[i][1], y + pos[i][2])
      end
    end
  else
    self.th:setTile(nil)
    if self.split_anims then
      for i = 2, #self.split_anims do
        self.split_anims[i]:setTile(nil)
      end
    end
  end
  self.world:clearCaches()
  return self
end

function Object:setUser(user)
  self.user = user or false
  if user then
    if self.multiple_users_allowed then
      if not self.user_list then
        self.user_list = {}
      end
      self.user_list[#self.user_list + 1] = user
    end
    self.th:makeInvisible()
    self.reserved_for = nil
  else
    self.th:makeVisible()
  end
end

-- The functions below works in the same way as using the variables "reserved_for"
-- and "user" as long as the flag multiple_users_allowed isn't set.
function Object:removeUser(user)
  self.user = nil
  if self.multiple_users_allowed then
    if not user or not self.user_list then
      -- No user specified, empty the list; or the list didn't exist
      self.user_list = {}
    end
    for i, users in ipairs(self.user_list) do
      if users == user then
        table.remove(self.user_list, i)
      end
    end
    if #self.user_list == 0 then
      self.th:makeVisible()
    end
  else 
    self.th:makeVisible()
  end
end

-- Removes the user specified from this object's list of reserved users (if one exists).
-- If the argument is nil it is assumed that the list should be emptied.
function Object:removeReservedUser(user)
  self.reserved_for = nil
  if self.multiple_users_allowed then
    -- No user specified, delete the whole list; or no list found, make it.
    if not user or not self.reserved_for_list then
      self.reserved_for_list = {}
    end
    for i, users in ipairs(self.reserved_for_list) do
      if users == user then
        table.remove(self.reserved_for_list, i)
      end
    end
  end
end

-- If multiple_users_allowed is not set this will remove any previously reserved users
-- from the object.
function Object:addReservedUser(user)
  assert(user, "Expected a user, got nil") -- It makes no sense to add a nil value
  if self.multiple_users_allowed then
    if not self.reserved_for_list then
      self.reserved_for_list = {}
    end
    self.reserved_for_list[#self.reserved_for_list + 1] = user
  else
    self.user = user
  end
end

-- Checks whether the object is reserved for the specified user.
-- If the argument is nil a check for any reserved user is done.
function Object:isReservedFor(user)
  if not user then
    return #self.reserved_for_list > 0 or self.reserved_for
  end
  if self.user == user then -- "Normal" use
    return true
  end
  if self.multiple_users_allowed then
    if not self.reserved_for_list then
      self.reserved_for_list = {}
    end
    for i, users in ipairs(self.reserved_for_list) do
      if users == user then
        return true
      end
    end
  end
  return false
end

--[[ Called when the object is clicked
!param ui (UI) The active ui.
!param button (string) Which button was clicked.
!param data (table) If some data should be retained after moving an object it is in this table.
]]
function Object:onClick(ui, button, data)
  local window = ui:getWindow(UIEditRoom)
  if button == "right" or (button == "left" and window and window.in_pickup_mode) then
    -- This flag can be used if for example some things should only happen as long as the
    -- object is not picked up. How lovely when it is so logical. :-)
    local object_list = {{object = self.object_type, qty = 1, existing_object = self}}
    local room = self:getRoom()
    window = window and window.visible and window
    local direction = self.direction
    if (not room and window) 
    or (room and not (window and window.room == room) and not self.object_type.corridor_object)
    or (not room and not self.object_type.corridor_object) then
      return
    end
    
    self.picked_up = true
    self.world:destroyEntity(self)
    -- NB: the object has to be destroyed before updating/creating the window,
    -- or the blueprint will be wrong
    if not window then
      window = UIPlaceObjects(ui, object_list, false) -- don't pay for
      ui:addWindow(window)
    else
      window:stopPickupItems()
      window:addObjects(object_list, false) -- don't pay for
      window:selectObjectType(self.object_type)
      window:checkEnableConfirm() -- since we removed an object from the room, the requirements may not be met anymore
    end
    window:setOrientation(direction)
    self.orientation_before = self.direction
    ui:playSound("pickup.wav")
  end
end

function Object:onDestroy()
  local room = self:getRoom()
  if room then
    room.objects[self] = nil
  end
  if self.user then
    self.user:handleRemovedObject(self)
  end
  if self.user_list then
    for i, user in ipairs(self.user_list) do
      user:handleRemovedObject(self)
    end
  end
  if self.reserved_for then
    self.reserved_for:handleRemovedObject(self)
    self.reserved_for = nil
  end
  if self.reserved_for_list then
    for i, reserver in ipairs(self.reserved_for_list) do
      reserver:handleRemovedObject(self)
    end
    self.reserved_for_list = {}
  end
  Entity.onDestroy(self)
end

local all_pathfind_dirs = {[0] = true, [1] = true, [2] = true, [3] = true}

function Object.processTypeDefinition(object_type)
  if object_type.id == "extinguisher"
  or object_type.id == "radiator"
  or object_type.id == "plant" 
  or object_type.id == "reception_desk" then
    object_type.count_category = object_type.id
  elseif object_type.id ~= "bin"
  and not object_type.corridor_object
  and not object_type.id:find("door") then
    object_type.count_category = "general"
  end
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
      -- Set handyman repair tile 
      if object_type.default_strength and not details.handyman_position then
        details.handyman_position = details.use_position
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
      local solid_points = {}
      if solid_near_use_position then
        local x, y = unpack(solid_near_use_position)
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
        if details.slave_position then
          details.slave_position[1] = details.slave_position[1] - x
          details.slave_position[2] = details.slave_position[2] - y
        end
        local rx, ry = unpack(details.render_attach_position)
        if type(rx) == "table" then
          rx, ry = unpack(details.render_attach_position[1])
          for _, point in ipairs(details.render_attach_position) do
            point.column = point[1] - point[2]
            point[1] = point[1] - x
            point[2] = point[2] - y
          end
        else
          details.render_attach_position[1] = rx - x
          details.render_attach_position[2] = ry - y
        end
        x, y = Map:WorldToScreen(rx + 1, ry + 1)
        details.animation_offset[1] = details.animation_offset[1] - x
        details.animation_offset[2] = details.animation_offset[2] - y
      end
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
