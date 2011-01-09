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

local room = {}
room.id = "psych"
room.level_config_id = 8
room.class = "PsychRoom"
room.name = _S.rooms_short.psychiatric
room.tooltip = _S.tooltip.rooms.psychiatry
room.objects_additional = { "extinguisher", "radiator", "plant", "bin", "bookcase", "skeleton" }
room.objects_needed = { screen = 1, couch = 1, comfortable_chair = 1 }
room.build_preview_animation = 924
room.categories = {
  treatment = 1,
  diagnosis = 8,
}
room.minimum_size = 5
room.wall_type = "white"
room.floor_tile = 18
room.required_staff = {
  Psychiatrist = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd003.wav"

class "PsychRoom" (Room)

function PsychRoom:PsychRoom(...)
  self:Room(...)
end

function PsychRoom:roomFinished()
  if not self.hospital:hasStaffOfCategory("Psychiatrist") then
    self.world.ui.adviser
    :say(_S.adviser.room_requirements.psychiatry_need_psychiatrist)
  end
  return Room.roomFinished(self)
end

function PsychRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  local obj, ox, oy = self.world:findFreeObjectNearToUse(staff, "bookcase", "near")
  if not obj then
    staff:setNextAction{name = "meander"}
  else
    staff:walkTo(ox, oy)
    staff:queueAction{name = "use_object", object = obj}
    local num_meanders = math.random(2, 8)
    staff:queueAction{
      name = "meander",
      loop_callback = --[[persistable:psych_meander_loop_callback]] function(action)
        num_meanders = num_meanders - 1
        if num_meanders == 0 then
          self:commandEnteringStaff(staff)
        end
      end
    }
  end
  return Room.commandEnteringStaff(self, staff)
end

function PsychRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  
  local obj, ox, oy = self.world:findObjectNear(patient, "couch")
  patient:walkTo(ox, oy)
  patient:queueAction{name = "use_object", object = obj}
  
  local duration = math.random(16, 72)
  local bookcase, bx, by
  local --[[persistable:psych_loop_callback]] function loop_callback()
    if bookcase == nil then
      bookcase, bx, by = self.world:findObjectNear(staff, "bookcase")
    end
    if patient and patient.user_of then
      duration = duration - 1
    end
    if duration <= 0 then
      if patient.diagnosed and patient.humanoid_class == "Elvis Patient" then
        -- Diagnosed patients (Elvis) need to change clothes
        obj, ox, oy = self.world:findObjectNear(patient, "screen")
        patient:walkTo(ox, oy)
        patient:queueAction{
          name = "use_screen",
          object = obj,
          after_use = --[[persistable:psych_screen_after_use]] function()
            self:dealtWithPatient(patient)
          end,
        }
      else
        self:dealtWithPatient(patient)
      end
      self:commandEnteringStaff(staff)
      return
    end
    if bookcase and (duration % 10) == 0 and math.random(1, 2) == 1 then
      staff:walkTo(bx, by)
      staff:queueAction{name = "use_object", object = bookcase}
      staff:queueAction{name = "walk", x = ox, y = oy}
      staff:queueAction{
        name = "use_object",
        object = obj,
        loop_callback = loop_callback,
      }
      duration = math.max(8, duration - 72)
    end
  end
  obj, ox, oy = self.world:findObjectNear(staff, "comfortable_chair")
  staff:walkTo(ox, oy)
  staff:queueAction{
    name = "use_object",
    object = obj,
    loop_callback = loop_callback,
  }
  
  return Room.commandEnteringPatient(self, patient)
end


return room
