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
class "Receptionist" (Staff)

---@type Receptionist
local Receptionist = _G["Receptionist"]

--!param ... Arguments to base class constructor.
function Receptionist:Receptionist(...)
  self:Staff(...)
  self.leave_sounds = {"sack007.wav", "sack008.wav"}
  self.leave_priority = AnnouncementPriority.Critical -- must always be played even without receptionist
end

function Receptionist:tickDay()
  if not Staff.tickDay(self) then
    return false
  end
  self:needsWorkStation()
end

function Receptionist:isTiring()
  return false
end

function Receptionist:isResting()
  return false
end

function Receptionist:setProfile(profile)
  Staff.setProfile(self, profile)
  self.attributes["fatigue"] = nil
end

function Receptionist:needsWorkStation()
  if self.hospital then
    self.hospital:msgNeedFirstReceptionDesk()
  end
end

-- Receptionists do not need rest
function Receptionist:checkIfNeedRest()
  return
end

function Receptionist:onPlaceInCorridor()
  Staff.onPlaceInCorridor(self)

  local world = self.world
  world:findObjectNear(self, "reception_desk", nil, function(x, y)
    local obj = world:getObject(x, y, "reception_desk")
    return obj and obj:occupy(self)
  end)
end


-- Helper function to decide if Staff fulfills a criterion
-- (one of "Doctor", "Nurse", "Psychiatrist", "Surgeon", "Researcher" and "Handyman", "Receptionist", "Junior", "Consultant")
function Receptionist:fulfillsCriterion(criterion)
  return criterion == "Receptionist"
end

function Receptionist:getDrawingLayer()
  local direction = self.last_move_direction
  if direction == "west" or direction == "north" then
    return DrawingLayers.ReceptionistFacingAway
  end
  return DrawingLayers.ReceptionistFacingUser
end

function Receptionist:afterLoad(old, new)
  if old < 163 then
    self.leave_sounds = {"sack007.wav", "sack008.wav"}
    self.leave_priority = AnnouncementPriority.Critical -- must always be played even without receptionist
  end
  Staff.afterLoad(self, old, new)
end
