--[[ Copyright (c) 2009 Manuel König

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
room.id = "cardiogram"
room.level_config_id = 12
room.class = "CardiogramRoom"
room.name = _S.rooms_short.cardiogram
room.tooltip = _S.tooltip.rooms.cardiogram
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { cardio = 1, screen = 1 }
room.build_preview_animation = 918
room.categories = {
  diagnosis = 3,
}
room.minimum_size = 4
room.wall_type = "yellow"
room.floor_tile = 19
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd001.wav"
room.handyman_call_sound = "maint010.wav"

class "CardiogramRoom" (Room)

function CardiogramRoom:CardiogramRoom(...)
  self:Room(...)
end

function CardiogramRoom:commandEnteringStaff(staff)
  self.staff_member = staff
  staff:setNextAction{name = "meander"}
  return Room.commandEnteringStaff(self, staff)
end

function CardiogramRoom:commandEnteringPatient(patient)
  local screen, sx, sy = self.world:findObjectNear(patient, "screen")
  patient:walkTo(sx, sy)
  patient:queueAction{
    name = "use_screen",
    object = screen,
    after_use = --[[persistable:cardiogram_screen_after_use1]] function()
      local staff = self.staff_member
      if not staff or patient.going_home then
        -- If, by some fluke, the staff member left the room while the
        -- patient used the screen, then the patient should get changed
        -- again (they will already have been instructed to leave by the
        -- staff leaving).
        patient:queueAction({
          name = "use_screen",
          object = screen,
          must_happen = true,
        }, 1)
        return
      end
      local cardio, cx, cy = self.world:findObjectNear(patient, "cardio")
      staff:walkTo(cardio:getSecondaryUsageTile())
      local staff_idle = {name = "idle"}
      staff:queueAction(staff_idle)
      patient:walkTo(cx, cy)
      local timer = 6
      local phase = -2
      patient:queueAction{
        name = "multi_use_object",
        object = cardio,
        use_with = staff,
        must_happen = true, -- set so that the second use_screen always happens
        prolonged_usage = true,
        loop_callback = --[[persistable:cardiogram_cardio_loop_callback]] function(action)
          if not action.on_interrupt then
            action.prolonged_usage = false
            patient.num_animation_ticks = 1
            return
          end
          timer = timer - 1
          if timer == 0 then
            phase = phase + 1
            if phase == 3 then
              action.prolonged_usage = false
            else
              patient.num_animation_ticks = 3 - math.abs(phase)
            end
            timer = 6
          else
            action.secondary_anim = 1030
          end
        end,
        after_use = --[[persistable:cardiogram_cardio_after_use]] function()
          if #staff.action_queue == 1 then
            staff:setNextAction{name = "meander"}
          else
            staff:finishAction(staff_idle)
          end
        end,
      }
      patient:queueAction{
        name = "walk",
        x = sx,
        y = sy,
        must_happen = true,
        no_truncate = true,
      }
      patient:queueAction{
        name = "use_screen",
        object = screen,
        must_happen = true,
        after_use = --[[persistable:cardiogram_screen_after_use2]] function()
          if #patient.action_queue == 1 then
            self:dealtWithPatient(patient)
          end
        end,
      }
    end,
  }
  return Room.commandEnteringPatient(self, patient)
end

function CardiogramRoom:onHumanoidLeave(humanoid)
  if self.staff_member == humanoid then
    self.staff_member = nil
  end
  Room.onHumanoidLeave(self, humanoid)
end

return room
