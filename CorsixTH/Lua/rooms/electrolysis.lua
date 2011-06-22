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
room.id = "electrolysis"
room.level_config_id = 23
room.class = "ElectrolysisRoom"
room.name = _S.rooms_short.electrolysis
room.tooltip = _S.tooltip.rooms.electrolysis
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { electrolyser = 1, console = 1 }
room.build_preview_animation = 930
room.categories = {
  clinics = 5,
}
room.minimum_size = 5
room.wall_type = "blue"
room.floor_tile = 17
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd019.wav"
room.handyman_call_sound = "maint008.wav"

class "ElectrolysisRoom" (Room)

function ElectrolysisRoom:ElectrolysisRoom(...)
  self:Room(...)
end

function ElectrolysisRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function ElectrolysisRoom:commandEnteringPatient(patient)
  local staff = self.staff_member
  local electrolyser, pat_x, pat_y = self.world:findObjectNear(patient, "electrolyser")
  local console, stf_x, stf_y = self.world:findObjectNear(staff, "console")
  
  local --[[persistable:electrolysis_shared_loop_callback]] function loop_callback()
    -- If the other humanoid has already started to idle we move on
    if staff.action_queue[1].name == "idle" and patient.action_queue[1].name == "idle" then
      -- Skilled doctors require less electrocutions
      local num_electrocutions = math.random(1, 5) * (2 - staff.profile.skill)
      -- We need to change to another type before starting, to be able
      -- to have different animations depending on gender.
      if math.random(0, 1) == 1 then
        patient:setType("Standard Male Patient") -- Other attributes already set
      else
        patient:setType("Standard Female Patient")
        patient:setLayer(0, math.random(1, 4) * 2)
        patient:setLayer(1, math.random(0, 3) * 2)
        patient:setLayer(2, 0)
      end
      patient:setNextAction{
        name = "use_object",
        object = electrolyser,
        loop_callback = --[[persistable:electrolysis_loop_callback]] function(action)
          num_electrocutions = num_electrocutions - 1
          if num_electrocutions <= 0 then
            -- Tired doctors can continue electrocuting for a bit too long...
            -- Fatigue 0.00 - normal number of electrocutions
            -- Fatigue 0.45 - normal number of electrocutions
            -- Fatigue 0.80 - expect 1 extra electrocution
            -- Fatigue 1.00 - expect 9 extra electrocutions
            if math.random() <= 0.1 + 2 * (1 - staff.attributes["fatigue"]) then
              action.prolonged_usage = false
            end
          end
        end,
        after_use = --[[persistable:electrolysis_after_use]] function()
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
