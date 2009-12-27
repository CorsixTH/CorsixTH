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

class "Staff" (Humanoid)

function Staff:Staff(...)
  self:Humanoid(...)
  self.hover_cursor = TheApp.gfx:loadMainCursor("staff")
end

function Staff:tick()
  Entity.tick(self)
  self:checkIfNeedRest()
end

function Staff:fire()
  if self.fired then
    return
  end
  
  self:playSound "sack.wav"
  self:setMood("exit", true)
  self.fired = true
  self:setHospital(nil)
  self.hover_cursor = nil
  self.fatigue = nil
  -- TODO: Remove from world/hospital staff list
end

function Staff:onClick(ui, button)
  if self.fired then
    return
  end
  
  if button == "left" then
    ui:addWindow(UIStaff(ui, self))
    -- temporary for debugging
    print("Fatigue: ", self.fatigue)
  elseif button == "right" then
    self:setNextAction({name = "pickup", ui = ui, must_happen = true}, true)
  end
  Humanoid.onClick(self, ui, button)
end

function Staff:setProfile(profile)
  self.profile = profile
  self:setType(profile.humanoid_class)
  if self.humanoid_class ~= "Receptionist" then
    self.fatigue = 0
  end
  self:setLayer(5, profile.layer5)
end

-- Function for increasing fatigue. Fatigue can be between 0 and 1,
-- so amounts here should be appropriately small comma values.
function Staff:tire(amount)
  if self.fatigue then
    self.fatigue = self.fatigue + amount
    if self.fatigue > 1 then
      self.fatigue = 1
    end
  end
end

-- Function for decreasing fatigue. Fatigue can be between 0 and 1,
-- so amounts here should be appropriately small comma values.
function Staff:wake(amount)
  if self.fatigue then
    self.fatigue = self.fatigue - amount
    if self.fatigue < 0 then
      self.fatigue = 0
    end
  end
end

-- Check if fatigue is over a certain level (now: 0.8, later: configurable), and go to the StaffRoom if it is.
function Staff:checkIfNeedRest()
  if self.fatigue and self.fatigue >= 0.8 and not class.is(self:getRoom(), StaffRoom) then
    self:setMood("tired", true)
    -- If there's already a "seek_staffroom" action in the action queue, or staff is currently picked up, do nothing
    if self.going_to_staffroom or self.action_queue[1].name == "pickup" then
      return
    end
    -- If no staff room exists, prevent further checks until one is built
    if not self.world:findRoomNear(self, "staff_room") then
      self.going_to_staffroom = true
      local callback
      callback = function(room)
        if room.room_info.id == "staff_room" then
          self.going_to_staffroom = false
          self.world:unregisterRoomBuildCallback(callback)
        end
      end
      self.world:registerRoomBuildCallback(callback)
      return
    end
    -- Else, seek a staff room now
    self:setNextAction{name = "seek_staffroom", must_happen = true}
    self.going_to_staffroom = true
    -- NB: going_to_staffroom set if (and only if) a seek_staffroom action is in the action_queue
    -- Exception: if no staff room exists, it is also set to true until one is built
  end
end

function Staff:onPlaceInCorridor()
  if self.humanoid_class ~= "Receptionist" then
    return
  end
  
  local world = self.world
  world:findObjectNear(self, "reception_desk", nil, function(x, y)
    local obj = world:getObject(x, y, "reception_desk")
    if not obj.receptionist and not obj.reserved_for then
      obj.reserved_for = self
      self.associated_desk = obj
      local use_x, use_y = obj:getSecondaryUsageTile()
      self:setNextAction{name = "walk", x = use_x, y = use_y, must_happen = true}
      self:queueAction{name = "staff_reception", object = obj, must_happen = true}
      return true
    end
  end)
end

function Staff:setHospital(hospital)
  if self.hospital then
    self.hospital:removeStaff(self)
  end
  Humanoid.setHospital(self, hospital)
  if hospital then
    hospital:addStaff(self)
  end
end

local profile_attributes = {
  Psychiatrist = "is_psychiatrist",
  Surgeon = "is_surgeon",
  Researcher = "is_researcher",
}

-- Helper function to decide if Staff fulfills a criterium (one of "Doctor", "Nurse", "Psychiatrist", "Surgeon" and "Researcher")
function Staff:fulfillsCriterium(criterium)
  local class = self.humanoid_class
  if criterium == "Doctor" then
    if class == "Doctor" or class == "Surgeon" then
      return true
    end
  elseif criterium == "Nurse" then
    if class == "Nurse" then
      return true
    end
  elseif criterium == "Psychiatrist" or criterium == "Surgeon" or criterium == "Researcher" then
    if self.profile and self.profile[profile_attributes[criterium]] == 1.0 then
      return true
    end
  else
    error("Unknown criterium " .. criterium)
  end
  return false
end

-- Function to decide if staff currently has nothing to do and can be called to a room where he's needed
function Staff:isIdle()
  local room = self:getRoom()
  if room then
    -- in special rooms, never
    if room.room_info.id == "staff_room" or room.room_info.id == "research" then -- TODO training room
      return false
    end
    -- in regular rooms (diagnosis / treatment), if no patient is in sight
    -- TODO: There's a short moment where a patient is in neither of the three: when he is called to enter the room, until he enters the room.
    --       Solve this by only removing patients from the queue in the moment they are actually entering.
    if room:getPatientCount() == 0 and room.door.queue:reportedSize() == 0 and room.door.queue.expected_count == 0 then
      return true
    end
  else
    -- on the corridor, if not heading to a room already
    if not self.action_queue[1].is_entering then
      return true
    end
  end
  return false
end
