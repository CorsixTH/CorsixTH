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

local room = {}
room.name = _S(14, 21)
room.id = "electrolysis"
room.class = "ElectrolysisRoom"
room.build_cost = 7000
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { "electrolyser", "console" }
room.build_preview_animation = 930
room.categories = {
  clinics = 6,
}
room.minimum_size = 5
room.wall_type = "blue"
room.floor_tile = 17
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd019.wav"

class "ElectrolysisRoom" (Room)

function ElectrolysisRoom:ElectrolysisRoom(...)
  self:Room(...)
end

function ElectrolysisRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
end

function ElectrolysisRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local electrolyser, pat_x, pat_y = self.world:findObjectNear(patient, "electrolyser")
  local console, stf_x, stf_y = self.world:findObjectNear(staff, "console")
  
  local function loop_callback()
    -- If the other humanoid has already started to idle we move on
    if staff.action_queue[1].name == "idle" and patient.action_queue[1].name == "idle" then
      patient:setNextAction{
        name = "use_object",
        object = electrolyser,
        after_use = function()
          patient:setType("Standard Male Patient") -- Change to normal body
          self:dealtWithPatient(patient)
          self:commandEnteringStaff(staff)
        end,
      }
    
      staff:setNextAction{
        name = "use_object",
        object = console,
      }
      -- The doctor will be done before the patient is, make sure the queue doesn't get empty.
      staff:queueAction{name = "idle"}
      -- We don't want the animations to repeat (electrocuting would be nice to repeat, but
      -- there aren't enough phases after that part to finish everything if done like that.
      patient.action_queue[1].prolonged_usage = false;
      staff.action_queue[1].prolonged_usage = false;
    end
  end
  -- As soon as one starts to idle the callback is called to see if the other one is already idling.
  patient:walkTo(pat_x, pat_y)
  patient:queueAction{
    name = "idle", 
    direction = electrolyser.direction == "north" and "east" or "south",
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
