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

--! An `Object` which needs occasional repair (to prevent explosion).
class "Machine" (Object)

function Machine:Machine(world, object_type, x, y, direction, etc)
  
  self.total_usage = -1 -- Incremented in the constructor of Object.
  self:Object(world, object_type, x, y, direction, etc)
  
  -- Initialize machines with strength values. (TODO: according to current research)
  local config
  local level = world.map.level_config
  local id = self:getRoom().room_info.level_config_id
  if level and id and level.objects[id]
  and level.objects[id].StartStrength then
    config = level.objects[id]
  end
  self.strength = config and config.StartStrength or object_type.default_strength
  
  -- We actually don't want any dynamic info just yet
  self:clearDynamicInfo()
  -- TODO: Smoke, 3424
  -- Change hover cursor once the room has been finished.
  local callback
  callback = --[[persistable:machine_build_callback]] function(room)
    if room.objects[self] then
      self:finalize(room)
      self.world:unregisterRoomBuildCallback(callback)
    end
  end
  local orientation = object_type.orientations[direction]
  local handyman_position = orientation.handyman_position
  if handyman_position then
  -- If there are many possible handyman tiles, choose one that is accessible from the use_position.
    if type(handyman_position[1]) == "table" then
      for _, position in ipairs(handyman_position) do
        local hx, hy = x + position[1], y + position[2]
        local ux, uy = x + orientation.use_position[1], y + orientation.use_position[2]
        if world.pathfinder:findDistance(hx, hy, ux, uy) then
          -- Also make sure the tile is not in another room or in the corridor.
          local room = world:getRoom(hx, hy)
          if room and room == self:getRoom() then
            self.handyman_position = {position[1], position[2]}
            break
          end
        end
      end
    else
      self.handyman_position = {handyman_position[1], handyman_position[2]}
    end
  else
    self.handyman_position = {orientation.use_position[1], orientation.use_position[2]}
  end
  self.world:registerRoomBuildCallback(callback)
end

function Machine:machineUsed(room)
  self:updateDynamicInfo()
  local threshold = self.times_used/self.strength
  if threshold > 0.85 then
    room:crashRoom()
    self:setAnimation(self.object_type.crashed_animation)
  elseif threshold > 0.65 then
    self.world:callForStaff(room, self, true)
    -- TODO: 3428 is smoke, add it when additional objects can be made
  elseif threshold > 0.35 then
    self.world:callForStaff(room, self) 
  end
end

function Machine:getRepairTile()
  local x = self.tile_x + self.handyman_position[1]
  local y = self.tile_y + self.handyman_position[2]
  return x, y
end

function Machine:createRepairAction(handyman)
  local --[[persistable:handyman_repair_after_use]] function after_use()
    self:machineRepaired(self:getRoom())
    handyman:setDynamicInfoText("")
  end
  return {
    name = "use_object",
    object = self,
    must_happen = true,
    prolonged_usage = false,
    loop_callback = --[[persistable:handyman_repair_loop_callback]] function()
      action_use.prolonged_usage = false
    end,
    after_use = after_use,
  }
end

function Machine:machineRepaired(room)
  room.needs_repair = nil
  local str = self.strength
  if self.times_used/str > 0.55 then
    self.strength = str - 1
  end
  self.times_used = 0
  self:setRepairing(false)
  self:updateDynamicInfo(true)
end

function Machine:setRepairing(activate)
  local anim = {icon = 4564} -- The only icon for machinery
  self:setMoodInfo(activate and anim or nil)
  if activate then
    self.ticks = true
  else
    self.ticks = self.object_type.ticks
  end
end

-- Currently used to make the hover cursor of the machine be special
-- only if the room is active at the moment (e.g. not being edited)
function Machine:finalize(room)
  if room.is_active then
    self.hover_cursor = TheApp.gfx:loadMainCursor("repair")
    self:updateDynamicInfo(true)
  else
    self:clearDynamicInfo()
    self.hover_cursor = nil
  end
end

function Machine:updateDynamicInfo(only_update)
  if not only_update then
    self.times_used = self.times_used + 1
    self.total_usage = self.total_usage + 1
  end
  if self.strength then
    self:setDynamicInfo("text", {
      self.object_type.name, 
      _S.dynamic_info.object.strength:format(self.strength),
      _S.dynamic_info.object.times_used:format(self.times_used),
    })
  end
end

function Machine:onClick(ui, button)
  if button == "left" and self.strength then
    local room = self:getRoom()
    if room.is_active then
      ui:addWindow(UIMachine(ui, self, room))
    end
  else
    Object.onClick(self, ui, button)
  end
end

function Machine:onDestroy()
  Object.onDestroy(self)
end
