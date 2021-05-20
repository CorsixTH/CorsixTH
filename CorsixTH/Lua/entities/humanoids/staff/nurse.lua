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

corsixth.require("announcer")
corsixth.require("entities.humanoids.staff")

local AnnouncementPriority = _G["AnnouncementPriority"]

--! A Doctor, Nurse, Receptionist, Handyman, or Surgeon
class "Nurse" (Staff)

---@type Nurse
local Nurse = _G["Nurse"]

--!param ... Arguments to base class constructor.
function Nurse:Nurse(...)
  self:Staff(...)
end

function Nurse:leaveAnnounce()
  local announcement_priority = AnnouncementPriority.High

  local nurse_leave_sounds = {"sack004.wav", "sack005.wav",}
  self.world.ui:playAnnouncement(nurse_leave_sounds[math.random(1, #nurse_leave_sounds)], announcement_priority)
end

-- Helper function to decide if Staff fulfills a criterion
-- (one of "Doctor", "Nurse", "Psychiatrist", "Surgeon", "Researcher" and "Handyman", "Receptionist", "Junior", "Consultant")
function Nurse:fulfillsCriterion(criterion)
  return criterion == "Nurse"
end

function Nurse:adviseWrongPersonForThisRoom()
  local room = self:getRoom()
  local room_name = room.room_info.long_name
  self.world.ui.adviser:say(_A.staff_place_advice.nurses_cannot_work_in_room:format(room_name))
end

function Nurse:afterLoad(old, new)
  Staff.afterLoad(self, old, new)
end
