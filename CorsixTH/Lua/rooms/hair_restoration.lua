--[[ Copyright (c) 2010 Miika-Petteri Matikainen

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
room.id = "hair_restoration"
room.level_config_id = 19
room.class = "HairRestorationRoom"
room.name = _S.rooms_short.hair_restoration
room.tooltip = _S.tooltip.rooms.hair_restoration
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { hair_restorer = 1, console = 1 }
room.build_preview_animation = 5074
room.categories = {
  clinics = 4,
}
room.minimum_size = 4
room.wall_type = "blue"
room.floor_tile = 17
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd016.wav"
room.handyman_call_sound = "maint007.wav"

class "HairRestorationRoom" (Room)

function HairRestorationRoom:HairRestorationRoom(...)
  self:Room(...)
end

function HairRestorationRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function HairRestorationRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local hair_restorer, pat_x, pat_y = self.world:findObjectNear(patient, "hair_restorer")
  local console, stf_x, stf_y = self.world:findObjectNear(staff, "console")

  local --[[persistable:hair_restoration_shared_loop_callback]] function loop_callback()
    if staff.action_queue[1].name == "idle" and patient.action_queue[1].name == "idle" then
      patient:setNextAction{
        name = "use_object",
        object = hair_restorer,
        loop_callback = --[[persistable:hair_restoration_loop_callback]] function(action)
          action.prolonged_usage = false
        end,
        after_use = --[[persistable:hair_restoration_after_use]] function()
          patient:setLayer(0, patient.layers[0] + 2) -- Change to normal hair
          staff:setNextAction{name = "meander"}
          self:dealtWithPatient(patient)
        end,
      }
      staff:setNextAction{
        name = "use_object",
        object = console,
      }
    end
  end

  patient:walkTo(pat_x, pat_y)
  patient:queueAction{
    name = "idle", 
    direction = hair_restorer.direction == "north" and "east" or "south",
    loop_callback = loop_callback,
  }
  staff:walkTo(stf_x, stf_y)
  staff:queueAction{
    name = "idle", 
    direction = console.direction == "north" and "east" or "south",
    loop_callback = loop_callback,
  }

  return Room.commandEnteringPatient(self, patient)
end

return room
