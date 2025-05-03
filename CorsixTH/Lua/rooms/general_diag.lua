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
room.id = "general_diag"
room.vip_must_visit = false
room.level_config_id = 27
room.class = "GeneralDiagRoom"
room.name = _S.rooms_short.general_diag
room.long_name = _S.rooms_long.general_diag
room.tooltip = _S.tooltip.rooms.general_diag
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { screen = 1, crash_trolley = 1 }
room.build_preview_animation = 916
room.categories = {
  diagnosis = 2,
}
room.minimum_size = 5
room.wall_type = "green"
room.floor_tile = 21
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd021.wav"

class "GeneralDiagRoom" (Room)

---@type GeneralDiagRoom
local GeneralDiagRoom = _G["GeneralDiagRoom"]

function GeneralDiagRoom:GeneralDiagRoom(...)
  self:Room(...)
end

function GeneralDiagRoom:commandEnteringPatient(patient)
  local screen, sx, sy = self.world:findObjectNear(patient, "screen")
  -- Patient walk to screen
  patient:walkTo(sx, sy)

  local after_use_screen1 = --[[persistable:general_diag_screen_after_use1]] function()
    local after_use_screen2 = function() end
    local staff = self:getStaffMember()
    if staff then
      local trolley, cx, cy = self.world:findObjectNear(patient, "crash_trolley")

      -- Doctor walk to trolley
      local ox, oy = trolley:getSecondaryUsageTile()
      local staff_prepare = WalkAction(ox, oy)
        :setMustHappen(true)
        :disableTruncate()
        :setUninterruptable(true)
      staff:setNextAction(staff_prepare)

      -- Doctor wait patient near trolley
      local staff_idle = IdleAction()
        :setMustHappen(true)
        :disableTruncate()
        :setUninterruptable(true)
      staff:queueAction(staff_idle)

      -- Patient walk to trolley
      local go_to_trolley = WalkAction(cx, cy)
        :setMustHappen(true)
        :disableTruncate()
      patient:queueAction(go_to_trolley)

      local after_use_trolley = --[[persistable:general_diag_trolley_after_use]] function()
        -- Doctor finish wait near trolley
        staff:setNextAction(MeanderAction())
        staff:finishAction(staff_idle)
      end

      -- Patient use trolley
      local use_trolley = MultiUseObjectAction(trolley, staff)
        :disableTruncate()
        :setMustHappen(true)
        :setProlongedUsage(false)
        :setAfterUse(after_use_trolley)
      patient:queueAction(use_trolley)

      -- Patient walk back to screen
      local go_to_screen2 = WalkAction(sx, sy)
        :setIsLeaving(true)
        :setMustHappen(true)
        :disableTruncate()
      patient:queueAction(go_to_screen2)

      after_use_screen2 = --[[persistable:general_diag_screen_after_use2]] function()
        if #patient.action_queue == 1 then
          self:dealtWithPatient(patient)
        end
      end
    else
      -- Patient didn't get served
      self:makeHumanoidLeave(patient)
      patient:queueAction(SeekRoomAction(self.room_info.id))
    end

    -- Patient dress back to his clothes
    local dress_back = UseScreenAction(screen)
      :setIsLeaving(true)
      :setMustHappen(true)
      :setAfterUse(after_use_screen2)
    patient:queueAction(dress_back)
  end

  -- Patient undress for procedure
  local undress = UseScreenAction(screen):setAfterUse(after_use_screen1)
  patient:queueAction(undress)

  return Room.commandEnteringPatient(self, patient)
end

function GeneralDiagRoom:makeHumanoidLeave(humanoid)
  self:makeHumanoidDressIfNecessaryAndThenLeave(humanoid)
end

function GeneralDiagRoom:shouldHavePatientReenter(patient)
  return not patient:isLeaving()
end

return room
