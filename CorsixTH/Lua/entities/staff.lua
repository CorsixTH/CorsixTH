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

--! A Doctor, Nurse, Receptionist, Handyman, or Surgeon
class "Staff" (Humanoid)

function Staff:Staff(...)
  self:Humanoid(...)
  self.hover_cursor = TheApp.gfx:loadMainCursor("staff")
end

function Staff:tick()
  Entity.tick(self)
  if not self.fired and self.hospital then
    self:checkIfNeedRest()
    if self.quitting_in then
      self.quitting_in = self.quitting_in - 1
      if self.quitting_in < 0 then
        self:fire() -- Plays the sack sound, but maybe it's good that you hear a staff member leaving?
      end
    end
  end

  local room = self:getRoom()
  if not room or room.room_info.id ~= "staff_room" then
    if self.action_queue[1].name ~= "pickup" then
      self:tire(0.000115)
    end
  end
  -- is this a doctor in the training room with a consultant?
  local room = self:getRoom()
  if room and room.room_info.id == "training" and room.staff_member and self.humanoid_class == "Doctor" then
    -- tick event for consultant?
    if room.staff_member == self then
      -- TODO: Should the consultant's skills increase at all?
    else
      -- increase skills based upon what the consultant knows
      -- NB: need to figure out the optimum increase amount. possibly
      -- adjust based upon consultant's skill level? multiply by
      -- random factor to avoid all skills increasing equally?
      if room.staff_member.profile.is_surgeon >= 1.0 then
        self:updateSkill(room.staff_member, "is_surgeon", 0.00001)
      end
      if room.staff_member.profile.is_psychiatrist >= 1.0 then
        self:updateSkill(room.staff_member, "is_psychiatrist", 0.00001)
      end
      if room.staff_member.profile.is_researcher >= 1.0 then
        self:updateSkill(room.staff_member, "is_researcher", 0.00001)
      end

      self:updateSkill(room.staff_member, "skill", 0.000005)
    end
  end

  -- Make staff members request a raise if they are very unhappy
  if not self.world.debug_disable_salary_raise and self.attributes["happiness"] < 0.1 then
    if not self.timer_until_raise then
      self.timer_until_raise = 200
    end
    self.timer_until_raise = self.timer_until_raise - 1
    if self.timer_until_raise < 0 then
      self:requestRaise()
    end
  end
end

function Staff:updateSkill(consultant, trait, amount)
  local old_profile = { is_junior = self.profile.is_junior, is_consultant = self.profile.is_consultant }

  -- don't push further when they are already at 100%+
  if self.profile[trait] >= 1.0 then
    return
  end

  self.profile[trait] = self.profile[trait] + amount
  if self.profile[trait] >= 1.0 then
    self.profile[trait] = 1.0
    if trait == "is_surgeon" then
      self.world.ui.adviser:say(_S.adviser.information.promotion_to_specialist:format(_S.staff_title.surgeon))
    elseif trait == "is_psychiatrist" then
      self.world.ui.adviser:say(_S.adviser.information.promotion_to_specialist:format(_S.staff_title.psychiatrist))
    elseif trait == "is_researcher" then
      self.world.ui.adviser:say(_S.adviser.information.promotion_to_specialist:format(_S.staff_title.researcher))
    end
    self:updateStaffTitle()
  end

  if trait == "skill" then
    self.profile:parseSkillLevel()

    if old_profile.is_junior and not self.profile.is_junior then
      self.world.ui.adviser:say(_S.adviser.information.promotion_to_doctor)
    elseif not old_profile.is_consultant and self.profile.is_consultant then
      self.world.ui.adviser:say(_S.adviser.information.promotion_to_consultant)
      self:setNextAction(self:getRoom():createLeaveAction())
      self:queueAction{name = "meander"}
    end
  end
end

function Staff:fire()
  if self.fired then
    return
  end
  
  self:playSound "sack.wav"
  self:setMood("exit", true)
  self.fired = true
  self.hospital:changeReputation("kicked")
  self:setHospital(nil)
  self.hover_cursor = nil
  self.attributes["fatigue"] = nil
  -- TODO: Remove from world/hospital staff list
end

function Staff:onClick(ui, button)
  if self.fired then
    return
  end
  
  if button == "left" then
    if self.message_callback then
      self:message_callback()
    else
      ui:addWindow(UIStaff(ui, self))
    end
    if TheApp.config.debug then
      -- for debugging
      print("Fatigue: ", self.attributes["fatigue"])
    end
  elseif button == "right" then
    self:setNextAction({name = "pickup", ui = ui, must_happen = true}, true)
  end
  Humanoid.onClick(self, ui, button)
end

function Staff:setProfile(profile)
  self.profile = profile
  self:setType(profile.humanoid_class)
  if self.humanoid_class ~= "Receptionist" then
    self.attributes["fatigue"] = 0
  end
  self:setLayer(5, profile.layer5)
  self:updateStaffTitle()
end

function Staff:updateStaffTitle()
  local profile = self.profile
  if profile.humanoid_class == "Doctor" then
    local professions = ""
    local number = 0
    if profile.is_junior then
      professions = _S.staff_title.junior .. " "
      number = 1
    elseif profile.is_consultant then
      professions = _S.staff_title.consultant .. " "
      number = 1
    end
    if profile.is_researcher >= 1.0 then
      professions = professions .. _S.staff_title.researcher .. " "
      number = number + 1
    end
    if profile.is_surgeon >= 1.0 then
      if professions then
        professions = professions .. _S.staff_title.surgeon .. " "
      else
        professions = _S.staff_title.surgeon -- is this case actually needed?
      end
      number = number + 1
    end
    if profile.is_psychiatrist >= 1.0 then
      if number < 3 then
        if professions then
          professions = professions .. _S.staff_title.psychiatrist
        else
          professions = _S.staff_title.psychiatrist -- is this case actually needed?
        end
      else
        professions = professions .. _S.dynamic_info.staff.psychiatrist_abbrev
      end
    end
    
    if professions ~= "" then
      self.profile.profession = professions
    end
  end
end

-- Function for increasing fatigue. Fatigue can be between 0 and 1,
-- so amounts here should be appropriately small comma values.
function Staff:tire(amount)
  self:changeAttribute("fatigue", amount)
  self:updateDynamicInfo()
end

-- Function for decreasing fatigue. Fatigue can be between 0 and 1,
-- so amounts here should be appropriately small comma values.
function Staff:wake(amount)
  self:changeAttribute("fatigue", -amount)
  self:updateDynamicInfo()
end

-- Check if fatigue is over a certain level (decided by the hospital policy), 
-- and go to the StaffRoom if it is.
function Staff:checkIfNeedRest()
  if self.attributes["fatigue"] and self.attributes["fatigue"] >= self.hospital.policies["goto_staffroom"] 
  and not class.is(self:getRoom(), StaffRoom) then
    -- Only when the staff member is very tired should the icon emerge.
    -- TODO: Staff speed should be affected here.
    if self.attributes["fatigue"] >= 0.9 then
      self:setMood("tired", true)
    end
    -- If there's already a "seek_staffroom" action in the action queue, or staff is currently picked up, do nothing
    if self.going_to_staffroom or self.action_queue[1].name == "pickup" then
      return
    end
    -- If no staff room exists, prevent further checks until one is built
    if not self.world:findRoomNear(self, "staff_room") then
      self.going_to_staffroom = true
      local callback
      callback = --[[persistable:staff_build_staff_room_callback]] function(room)
        if room.room_info.id == "staff_room" then
          self.going_to_staffroom = false
          self.world:unregisterRoomBuildCallback(callback)
        end
      end
      self.world:registerRoomBuildCallback(callback)
      return
    end
    -- Else, if doing something important (e.g. seeing a patient)
    -- finish that first
    if (self:getRoom() and self:getRoom():getPatient()) or 
      (self.humanoid_class == "Handyman" and 
      (self.action_queue[1].is_entering or self:getRoom())) then
      self.staffroom_needed = true
    else
      -- Finally, seek a staff room now
      self:setNextAction{name = "seek_staffroom", must_happen = true}
    end
    -- No matter if the action has been set or staffroom_needed was set it will be
    -- handled - don't check in this function anymore.
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
  self:updateDynamicInfo()
end

local profile_attributes = {
  Psychiatrist = "is_psychiatrist",
  Surgeon = "is_surgeon",
  Researcher = "is_researcher",
}

-- Helper function to decide if Staff fulfills a criterium 
-- (one of "Doctor", "Nurse", "Psychiatrist", "Surgeon", "Researcher" and "Handyman")
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
  elseif criterium == "Handyman" then
    if class == "Handyman" then
      return true
    end
  else
    error("Unknown criterium " .. criterium)
  end
  return false
end

-- Function to decide if staff currently has nothing to do and can be called to a room where he's needed
function Staff:isIdle()
  -- Make sure we're not in an undesired state
  if not self.hospital or self.fired then
    return false
  end
  local room = self:getRoom()
  if room then
    -- if policy is set to not allow leaving rooms, don't allow it
    if not self.hospital.policies["staff_allowed_to_move"] then
      return false
    end
    
    -- in special rooms, never
    if room.room_info.id == "staff_room" or room.room_info.id == "research" then -- TODO training room
      return false
    end
    -- in regular rooms (diagnosis / treatment), if no patient is in sight
    -- TODO: There's a short moment where a patient is in neither of the three: when he is called to enter the room, until he enters the room.
    --       See issue #76.
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

-- Makes the staff member request a raise of fair wage + 10% of current. Shows a request raise dialog.
function Staff:requestRaise()
  -- Check whether there is already a request for raise.
  if not self:isMoodActive("pay_rise") then
    self.quitting_in = 25*30 -- Time until the staff members quits anyway
    self:setMood("pay_rise", true)
    local amount = math.floor(self.profile:getFairWage() + self.profile.wage*0.1 - self.profile.wage)
    self.world.ui.bottom_panel:queueMessage("strike", amount, self)
  end
end

-- Increases the wage of the staff member, increases happiness and clears any request raise dialogs.
function Staff:increaseWage(amount)
  self.profile.wage = self.profile.wage + amount
  self:changeAttribute("happiness", 0.99)
  self:setMood("pay_rise", false)
end

function Staff:setDynamicInfoText(text)
  self.dynamic_text = text
end

function Staff:updateDynamicInfo()
  local fatigue_text = _S.dynamic_info.staff.tiredness
  if not self.attributes["fatigue"] then
    fatigue_text = nil
  end
  self:setDynamicInfo('text', {
    self.profile.profession, 
    self.dynamic_text and self.dynamic_text or "", 
    fatigue_text,
  })
  self:setDynamicInfo('progress', self.attributes["fatigue"])
  if self.hospital then
    self:setDynamicInfo('dividers', {self.hospital.policies["goto_staffroom"]})
  end
end
