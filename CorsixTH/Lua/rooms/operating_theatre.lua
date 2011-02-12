--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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

local room = {}
room.id = "operating_theatre"
room.level_config_id = 10
room.class = "OperatingTheatreRoom"
room.name = _S.rooms_short.operating_theatre
room.tooltip = _S.tooltip.rooms.operating_theatre
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = {
  operating_table = 1,
  surgeon_screen = 1,
  op_sink1 = 1,
  x_ray_viewer = 1
}
room.build_preview_animation = 5080
room.categories = {
  treatment = 3,
}
room.minimum_size = 6
room.wall_type = "white"
room.floor_tile = 21
room.swing_doors = true
room.required_staff = {
  Surgeon = 2,
}
room.call_sound = "reqd010.wav" -- TODO: There is also an unused sound
-- "Another surgeon needed [...]", reqd011.wav
-- room.handyman_call_sound = "maint007.wav" TODO: No sound for this room?

class "OperatingTheatreRoom" (Room)

function OperatingTheatreRoom:OperatingTheatreRoom(...)
  self:Room(...)
  self.staff_member_set = {}
end

function OperatingTheatreRoom:roomFinished()
  -- Find the X-ray viewer
  local fx, fy = self:getEntranceXY(true)
  local objects = self.world:findAllObjectsNear(fx, fy, 2^30)
  for object in pairs(objects) do
    local id = object.object_type.id
    if id == "x_ray_viewer" then
      self[id] = object
    end
  end
  -- Tell the player what is missing, if anything.
  if not self.hospital:hasRoomOfType("ward") then
    self.world.ui.adviser:say(_S.adviser.room_requirements.op_need_ward)
  end
  if not self.hospital:hasStaffOfCategory("Surgeon") then
    self.world.ui.adviser:say(_S.adviser.room_requirements.op_need_two_surgeons)
  elseif self.hospital:hasStaffOfCategory("Surgeon") == 1 then
    self.world.ui.adviser:say(_S.adviser.room_requirements.op_need_another_surgeon)
  end
  return Room.roomFinished(self)
end

local function wait_for_object(humanoid, obj, must_happen)
  return {
    name = "idle",
    must_happen = must_happen,
    loop_callback = --[[persistable:operatring_theatre_wait]] function(action)
      if action.todo_interrupt or not obj.user then
        humanoid:finishAction(action)
      else
        humanoid:queueAction({
          name = "idle",
          count = 5,
          must_happen = must_happen,
        }, 0)
      end
    end,
  }
end

function OperatingTheatreRoom:commandEnteringStaff(staff)
  self.staff_member_set[staff] = true
  
  -- Put surgeon outfit on 
  local obj, ox, oy = self.world:findObjectNear(staff, "surgeon_screen")
  staff:walkTo(ox, oy)
  staff:queueAction(wait_for_object(staff, obj))
  staff:queueAction{
    name = "use_screen",
    object = obj
  }
  
  -- Wait around for patients
  local meander = {name = "meander", must_happen = true, 
    loop_callback = --[[persistable:operatring_theatre_after_surgeon_clothes_on]] function()
      self.staff_member_set[staff] = "ready"
      self:tryAdvanceQueue()
    end
  }
  staff:queueAction(meander)
  
  -- Ensure that surgeons turn back into doctors when they leave
  staff:queueAction{
    name = "walk",
    x = ox,
    y = oy,
    must_happen = true,
    truncate_only_on_high_priority = true,
    is_leaving = true,
  }
  staff:queueAction{name = "use_screen", object = obj, must_happen = true, is_leaving = true}
  
  return Room.commandEnteringStaff(self, staff)
end

function OperatingTheatreRoom:commandEnteringPatient(patient)
  -- Turn on x-ray viewer
  self.x_ray_viewer:setLayer(11, 2)
  
  -- Identify the staff
  local surgeon1 = next(self.staff_member_set)
  local surgeon2 = next(self.staff_member_set, surgeon1)
  assert(surgeon1 and surgeon2, "Not enough staff in operating theatre")
  
  -- Patient changes into surgical gown
  local screen, sx, sy = self.world:findObjectNear(patient, "surgeon_screen")
  patient:walkTo(sx, sy)
  patient:queueAction{name = "use_screen", object = screen}
  
  -- Meanwhile, surgeons wash their hands
  local obj, ox, oy = self.world:findObjectNear(surgeon1, "op_sink1")
  surgeon1:queueAction({name = "walk", x = ox, y = oy, must_happen = true, no_truncate = true}, 1)
  surgeon2:queueAction({name = "walk", x = ox, y = oy, must_happen = true, no_truncate = true}, 1)
  surgeon1:queueAction(wait_for_object(surgeon1, obj, true), 2)
  surgeon1:queueAction({name = "use_object", object = obj, must_happen = true}, 3)
  surgeon2:queueAction(wait_for_object(surgeon2, obj, true), 2)
  surgeon2:queueAction({name = "use_object", object = obj, must_happen = true}, 3)
  
  local num_ready = {0}
  ----- BEGIN Save game compatibility -----
  -- These function are merely for save game compability. 
  -- And they does not participate in the current game logic.
  -- Do not move or edit
  local --[[persistable:operatring_theatre_wait_for_ready]] function wait_for_ready(action)
    action.on_interrupt = nil
    if not action.done_ready then
      num_ready[1] = num_ready[1] + 1
      action.done_ready = true
    end
    if num_ready[1] == 3 then
      surgeon1:finishAction()
      surgeon2:finishAction()
    end
  end
  local after_use = --[[persistable:operatring_theatre_after_multi_use]] function()
    self:dealtWithPatient(patient)
    patient:finishAction()
  end 
  ----- END Save game compatibility -----

  local room = self
  local --[[persistable:operatring_theatre_operation_standby]] function operation_standby(action, humanoid)
    action.on_interrupt = nil
    if not action.done_ready then
      num_ready[1] = num_ready[1] + 1
      action.done_ready = true
    end
    if room.staff_member_set[humanoid] and room.staff_member_set[humanoid] == "abort" then
      humanoid:finishAction()
    elseif num_ready[1] == 3 then
      -- Only if everyone (2 Surgeons and Patient) ready, we schedule the operation action
      local obj, ox, oy = room.world:findObjectNear(surgeon1, "operating_table")
      local multi_use = {
        name = "multi_use_object",
        object = obj,
        use_with = patient,
        prolonged_usage = true,
        loop_callback = --[[persistable:operatring_theatre_multi_use_callback]] function(action)
          -- dirty hack to make the truncated animation work
          surgeon1.animation_idx = nil
        end,
        after_use = --[[persistable:operatring_theatre_table_after_use]] function()
          room:dealtWithPatient(patient)
          -- Tell the patient that it's time to leave, but only if the first action
          -- is really an idle action.
          if patient.action_queue[1].name == "idle" then
            patient:finishAction()
          end
        end,
        must_happen = true,
        no_truncate = true,
      }
      surgeon1:queueAction(multi_use, 1)

      obj, ox, oy = self.world:findObjectNear(surgeon1, "operating_table_b")
      local num_loops = math.random(2, 5)
      surgeon2:queueAction({
        name = "use_object",
        object = obj,
        loop_callback = --[[persistable:operatring_theatre_use_callback]] function(action)
          num_loops = num_loops - 1
          if num_loops <= 0 then
            action.prolonged_usage = false
          end
        end,
        after_use = --[[persistable:operatring_theatre_after_use]] function()
          multi_use.prolonged_usage = false
        end,
        must_happen = true,
        no_truncate = true,
      }, 1)
      
      -- Kick off
      surgeon1:finishAction()
      surgeon2:finishAction()
    end
  end

  ---- Everyone standby...and sync start the operation
  --
  -- first surgeon walk over to the operating table
  obj, ox, oy = self.world:findObjectNear(surgeon1, "operating_table")
  surgeon1:queueAction({name = "walk", x = ox, y = oy, must_happen = true, no_truncate = true}, 4)
  surgeon1:queueAction({name = "idle", loop_callback = operation_standby, must_happen = true}, 5)

  -- Patient walk to the side of the operating table
  ox, oy = obj:getSecondaryUsageTile()
  patient:queueAction{name = "walk", x = ox, y = oy, must_happen = true, no_truncate = true}
  patient:queueAction{name = "idle", loop_callback = operation_standby, must_happen = true}
      
  -- Patient changes out of the gown afterwards
  patient:queueAction{
    name = "walk",
    x = sx,
    y = sy,
    must_happen = true,
    no_truncate = true,
  }
  patient:queueAction{name = "use_screen", object = screen, must_happen = true}  

  -- Meanwhile, second surgeon walks over to other side of operating table
  obj, ox, oy = self.world:findObjectNear(surgeon1, "operating_table_b")
  surgeon2:queueAction({name = "walk", x = ox, y = oy, must_happen = true, no_truncate = true}, 4)
  surgeon2:queueAction({name = "idle", loop_callback = operation_standby, must_happen = true}, 5)
  
  return Room.commandEnteringPatient(self, patient)
end

function OperatingTheatreRoom:onHumanoidLeave(humanoid)
  self.staff_member_set[humanoid] = nil
  -- Turn off x-ray viewer
  if class.is(humanoid, Patient) then
    self.x_ray_viewer:setLayer(11, 0)
    local surgeon1 = next(self.staff_member_set)
    local surgeon2 = next(self.staff_member_set, surgeon1)
    if surgeon1 then
      self.staff_member_set[surgeon1] = "abort"
    end
    if surgeon2 then
      self.staff_member_set[surgeon2] = "abort"
    end
  end
  return Room.onHumanoidLeave(self, humanoid)
end

function OperatingTheatreRoom:canHumanoidEnter(humanoid)
  local can = Room.canHumanoidEnter(self, humanoid)
  if can and class.is(humanoid, Patient) then
    -- Patients can only enter once all doctors are in surgeon clothes
    for staff, is_ready in pairs(self.staff_member_set) do
      if staff.humanoid_class == "Doctor" or is_ready ~= "ready" then
        return false
      end
    end
  end
  return can
end

return room
