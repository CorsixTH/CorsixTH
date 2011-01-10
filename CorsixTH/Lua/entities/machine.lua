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

  if object_type.default_strength then
    -- Only for the main object. The slave doesn't need any strength
    local progress = world.ui.hospital.research.research_progress[object_type]
    self.strength = progress.start_strength
  end

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

function Machine:setCrashedAnimation()
  self:setAnimation(self.object_type.crashed_animation)
end

function Machine:machineUsed(room)
  self:updateDynamicInfo()
  local threshold = self.times_used/self.strength
  if threshold >= 1 then
    room:crashRoom()
    self:setCrashedAnimation()
    self.hover_cursor = nil
    self:clearDynamicInfo()
    local window = self.world.ui:getWindow(UIMachine)
    if window and window.machine == self then
      window:close()
    end
    self:setRepairing(nil)
    return true
  elseif threshold >= 0.75 then
    -- TODO: 3428 is smoke, add it when additional objects can be made
    -- Urgent
    self.world.dispatcher:callForRepair(self, true)
  elseif threshold >= 0.25 then
    -- Not urgent
    self.world.dispatcher:callForRepair(self)
  end
end

function Machine:getRepairTile()
  local x = self.tile_x + self.handyman_position[1]
  local y = self.tile_y + self.handyman_position[2]
  return x, y
end

function Machine:createHandymanActions(handyman)
  local ux, uy = self:getRepairTile()
  local this_room = self:getRoom()
  local handyman_room = handyman:getRoom()
  assert(this_room, "machine should always in a room")

  self.repairing = handyman
  self:setRepairingMode()

  local --[[persistable:handyman_repair_after_use]] function after_use()
    handyman:setCallCompleted()
    handyman:setDynamicInfoText("") 
    self:machineRepaired(self:getRoom())
  end
  local action = {name = "walk", x = ux, y = uy, is_entering = this_room and true or false}
  local repair_action = {
    name = "use_object",
    object = self,
    prolonged_usage = false,
    loop_callback = --[[persistable:handyman_repair_loop_callback]] function()
      action_use.prolonged_usage = false
    end,
    after_use = after_use,
    min_length = 20,
  }
  if handyman_room and handyman_room ~= this_room then
    handyman:setNextAction(handyman_room:createLeaveAction())
    handyman:queueAction(action)
  else
    handyman:setNextAction(action)
  end
  handyman:queueAction(repair_action)
  CallsDispatcher.queueCallCheckpointAction(handyman)
  handyman:queueAction{name = "answer_call"}
  handyman:setDynamicInfoText(_S.dynamic_info.staff.actions.going_to_repair
    :format(self.object_type.name))
end

function Machine:machineRepaired(room)
  room.needs_repair = nil
  local str = self.strength
  if self.times_used/str > 0.55 then
    self.strength = str - 1
  end
  self.times_used = 0
  self:setRepairing(nil)
end

--! Tells the machine to start showing the icon that it needs repair.
--!   also lock the room from patient entering
--!param handyman The handyman heading to this machine. nil if repairing is finished
function Machine:setRepairing(handyman)
  -- If mode is set to true manually through the dialog, boost the urgency despite of the strength
  local anim = {icon = 4564} -- The only icon for machinery
  local room = self:getRoom()
  self:setMoodInfo(handyman and anim or nil)
  room.needs_repair = handyman
  if handyman then
    self.ticks = true
  else
    self.ticks = self.object_type.ticks
    self.world.dispatcher:dropFromQueue(self)
    if not room.crashed then
      self:updateDynamicInfo(true)
      self:getRoom():tryAdvanceQueue()
    end
  end
end

function Machine:setRepairingMode(lock_room)
  if lock_room ~= nil then
    self.repairing_lock_room = lock_room
  end
  if self.repairing and self.repairing_lock_room then
    self:setRepairing(self.repairing)
  end
end

function Machine.slaveMixinClass(class_method_table)
  local slave_to_master, master_to_slave = Object.slaveMixinClass(class_method_table)
  master_to_slave("finalize")
  master_to_slave("setCrashedAnimation")
  slave_to_master("createRepairAction")
  slave_to_master("getRepairTile")
  return slave_to_master, master_to_slave
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
  local room = self:getRoom()
  if button == "left" and room.is_active then
    -- If the room is crashed is_active is false.
    ui:addWindow(UIMachine(ui, self, room))
  else
    Object.onClick(self, ui, button)
  end
end

function Machine:onDestroy()
  local room = self:getRoom()
  if room then
    room.needs_repair = nil
  end
  Object.onDestroy(self)
end

function Machine:afterLoad(old, new)
  if old < 15 then
    if self.object_type.id == "cardio" then
      -- Fix THOB value being wrong
      self.world.map.th:setCellFlags(self.tile_x, self.tile_y, {
        thob = self.object_type.thob
      })
    end
  end
  return Entity.afterLoad(self, old, new)
end
