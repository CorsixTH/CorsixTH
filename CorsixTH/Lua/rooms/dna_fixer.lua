--[[ Copyright (c) 2011 Manuel "Roujin" Wolf

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
room.id = "dna_fixer"
room.level_config_id = 23
room.class = "DNAFixerRoom"
room.name = _S.rooms_short.dna_fixer
room.tooltip = _S.tooltip.rooms.dna_fixer
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { dna_fixer = 1, console = 1 }
room.build_preview_animation = 5070
room.categories = {
  clinics = 6,
}
room.minimum_size = 5
room.wall_type = "blue"
room.floor_tile = 17
room.swing_doors = true
room.required_staff = {
  Researcher = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd015.wav"
room.handyman_call_sound = "maint006.wav"

class "DNAFixerRoom" (Room)

function DNAFixerRoom:DNAFixerRoom(...)
  self:Room(...)
end

function DNAFixerRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function DNAFixerRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local dna_fixer, pat_x, pat_y = self.world:findObjectNear(patient, "dna_fixer")
  local console, stf_x, stf_y = self.world:findObjectNear(staff, "console")
  
  local --[[persistable:dna_fixer_shared_loop_callback]] function loop_callback()
    -- If the other humanoid has already started to idle we move on
    if staff.action_queue[1].name == "idle" and patient.action_queue[1].name == "idle" then
      -- We need to change to another type before starting, to be able
      -- to have different animations depending on gender.
      patient:setType(patient.change_into)
      patient:setNextAction{
        name = "use_object",
        object = dna_fixer,
        prolonged_usage = false,
        after_use = --[[persistable:dna_fixer_after_use]] function()
          self:dealtWithPatient(patient)
          staff:setNextAction{name = "meander"}
        end,
      }
    
      staff:setNextAction{
        name = "use_object",
        object = console,
      }
    end
  end
  -- As soon as one starts to idle the callback is called to see if the other one is already idling.
  patient:walkTo(pat_x, pat_y)
  patient:queueAction{
    name = "idle", 
    direction = dna_fixer.direction == "north" and "north" or "west",
    loop_callback = loop_callback,
  }
  staff:walkTo(stf_x, stf_y)
  staff:queueAction{
    name = "idle", 
    direction = console.direction == "north" and "north" or "west",
    loop_callback = loop_callback,
  }
  
  return Room.commandEnteringPatient(self, patient)
end

return room
