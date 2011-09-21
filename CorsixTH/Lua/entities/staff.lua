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
  
--!param ... Arguments to base class constructor.
function Staff:Staff(...)
  self:Humanoid(...)
  self.hover_cursor = TheApp.gfx:loadMainCursor("staff")
end

function Staff:tickDay()
  Humanoid.tickDay(self)
  -- Pay too low  --> unhappy
  -- Pay too high -->   happy
  local fair_wage = self.profile:getFairWage(self.world)
  local wage = self.profile.wage
  self:changeAttribute("happiness", 0.05 * (wage - fair_wage) / (fair_wage ~= 0 and fair_wage or 1))

  -- if you overwork your Dr's then there is a chance that they can go crazy
  -- when this happens, find him and get him to rest straight away
  if self.attributes['fatigue'] then
    if self.attributes['fatigue'] < 0.7 then
      if self:isResting() then
        self:setMood("tired", "deactivate")
        self:setCrazy(false)
      end
    else
      -- doctor can go crazy if they're too tired
      if self.humanoid_class == "Doctor" then
        if math.random(1, 300) == 1 then
          self:setCrazy(true)
        end
      end
    end
  end

  -- is self researcher in research room?
  if self:isResearching() then
    self.hospital.research:addResearchPoints(1550 + 1000*self.profile.skill)
  -- is self using lecture chair in a training room w/ a consultant?
  elseif self:isLearning() then
    -- Find values for how fast doctors learn the different professions from the level
    local level_config = self.world.map.level_config
    local surg_thres = 1
    local psych_thres = 1
    local res_thres = 1
    if level_config and level_config.gbv.AbilityThreshold then
      surg_thres = level_config.gbv.AbilityThreshold[0]
      psych_thres = level_config.gbv.AbilityThreshold[1]
      res_thres = level_config.gbv.AbilityThreshold[2]
    end
    local general_thres = 200 -- general skill factor

    local room = self:getRoom()
    -- room_factor starts at 5 for a basic room w/ TrainingRate == 4
    -- books add +1.5, skeles add +2.0, see TrainingRoom:calculateTrainingFactor
    local room_factor = room:getTrainingFactor()
    -- number of staff includes consultant
    local staff_count = room:getStaffCount() - 1
    -- update general skill
    self:trainSkill(room.staff_member, "skill", general_thres, room_factor, staff_count)
    -- update special skill based on consultant skills
    if room.staff_member.profile.is_surgeon >= 1.0 then
      self:trainSkill(room.staff_member, "is_surgeon", surg_thres, room_factor, staff_count)
    end
    if room.staff_member.profile.is_psychiatrist >= 1.0 then
      self:trainSkill(room.staff_member, "is_psychiatrist", psych_thres, room_factor, staff_count)
    end
    if room.staff_member.profile.is_researcher >= 1.0 then
      self:trainSkill(room.staff_member, "is_researcher", res_thres, room_factor, staff_count)
    end
  end
end

function Staff:tick()
  Entity.tick(self)
  -- don't do anything if they're fired or have no hospital
  if self.fired or not self.hospital then
    return
  end

  -- check if we need to use the staff room and go there if so
  self:checkIfNeedRest()
  -- check if staff has been waiting too long for a raise and fire if so
  self:checkIfWaitedTooLong()
  
  -- Decide whether the staff member should be tiring and tire them
  if self:isTiring() then
    self:tire(0.000090)
  end

    -- if doctor is in a room and they're using an object
    -- then their skill level will increase _slowly_ over time
  if self:isLearningOnTheJob() then
    self:updateSkill(self.humanoid_class, "skill", 0.000003)
  end

  -- Make staff members request a raise if they are very unhappy
  if not self.world.debug_disable_salary_raise and self.attributes["happiness"] < 0.1 then
    if not self.timer_until_raise then
      self.timer_until_raise = 200
    end
    if self.timer_until_raise == 0 then
      self:requestRaise()
    else
      self.timer_until_raise = self.timer_until_raise - 1
    end
  else
    self.timer_until_raise = nil
  end

  self:updateSpeed()
end

function Staff:checkIfWaitedTooLong()
  if self.quitting_in then
    self.quitting_in = self.quitting_in - 1
    if self.quitting_in < 0 then
      local rise_windows = self.world.ui:getWindows(UIStaffRise)
      local staff_rise_window = nil

      -- We go through all "requesting rise" windows open, to see if we need
      -- to close them when the person is fired.
      for i = 1, #rise_windows do
        if rise_windows[i].staff == self then
          staff_rise_window = rise_windows[i]
          break
        end
      end

      -- Plays the sack sound, but maybe it's good that you hear a staff member leaving?
      if staff_rise_window then
        staff_rise_window:fireStaff()
      else
        self:fire()
      end
    end
  end
end

function Staff:isTiring()
  local tiring = true

  local room = self:getRoom()
  -- Being in a staff room is actually quite refreshing, as long as you're not a handyman watering plants.
  if room then
    if room.room_info.id == "staff_room" and not self.on_call then
      tiring = false
    end
  elseif self.humanoid_class ~= "Handyman" then
    tiring = false
  end

  -- Picking staff members up doesn't tire them, it just tires the player.
  if self.action_queue[1].name == "pickup" then
    tiring = false
  end
  
  return tiring
end

function Staff:isResting()
  local room = self:getRoom()
  if room and room.room_info.id == "staff_room" and not self.on_call then
    return true
  else
    return false
  end
end

-- Determine if the staff member should contribute to research
function Staff:isResearching()
  local room = self:getRoom()
  return room and room.room_info.id == "research" -- in research lab
    and self.humanoid_class == "Doctor" and self.profile.is_researcher >= 1.0 -- is qualified
    and self.hospital  -- is not leaving the hospital
end

-- Determine if the staff member should increase their skills
function Staff:isLearning()
  local room = self:getRoom()
  return room and room.room_info.id == "training"  -- in training room
    and room.staff_member                          -- the training room has a consultant
    and self.action_queue[1].name == "use_object"  -- is using lecture chair
    and self.action_queue[1].object.object_type.id == "lecture_chair"
end

function Staff:isLearningOnTheJob()
  local room = self:getRoom()
  return room and room.room_info.id ~= "training" and room.room_info.id ~= "staff_room" 
    and room.room_info.id ~= "toilets" -- is in room but not training room, staff room, or toilets
    and self.humanoid_class == "Doctor" -- and is a doctor
    and self.action_queue[1].name == "use_object" -- and is using something
end


function Staff:updateSkill(consultant, trait, amount)
  local old_profile = {
    is_junior = self.profile.is_junior,
    is_consultant = self.profile.is_consultant
  }

  -- don't push further when they are already at 100%+
  if self.profile[trait] >= 1.0 then
    return
  end

  self.profile[trait] = self.profile[trait] + amount
  if self.profile[trait] >= 1.0 then
    self.profile[trait] = 1.0
    local is = trait:match"^is_(.*)"
    if is == "surgeon" or is == "psychiatrist" or is == "researcher" then
      self.world.ui.adviser:say(_S.adviser.information.promotion_to_specialist:format(_S.staff_title[is]))
    end
    self:updateStaffTitle()
  end

  if trait == "skill" then
    self.profile:parseSkillLevel()

    if old_profile.is_junior and not self.profile.is_junior then
      self.world.ui.adviser:say(_S.adviser.information.promotion_to_doctor)
      self:updateStaffTitle()
    elseif not old_profile.is_consultant and self.profile.is_consultant then
      self.world.ui.adviser:say(_S.adviser.information.promotion_to_consultant)
      if self:getRoom().room_info.id == "training" then
        self:setNextAction(self:getRoom():createLeaveAction())
        self:queueAction{name = "meander"}
      end
      self:updateStaffTitle()
    end
  end
end

function Staff:trainSkill(consultant, trait, skill_thres, room_factor, staff_count)
  -- TODO: tweak/rework this algorithm
  -- TODO: possibly adjust based upon consultant's skill level?
  --       possibly based on attention to detail?
  local constant = 12.0 
  local staff_factor = constant + (staff_count-1)*(constant/6.0)
  local delta = room_factor / (skill_thres * staff_factor)
  self:updateSkill(consultant, trait, delta)
end

-- Immediately terminate the staff member's employment.
function Staff:fire()
  if self.fired then
    return
  end

  -- Ensure that there are no inspection windows open for this staff member.
  local staff_window = self.world.ui:getWindow(UIStaff)
  if staff_window and staff_window.staff == self then
      staff_window:close()
  end

  self.hospital:spendMoney(self.profile.wage, _S.transactions.severance .. ": "  .. self.profile.name)
  self:playSound "sack.wav"  
  self:setMood("exit", "activate")
  self:setDynamicInfoText(_S.dynamic_info.staff.actions.fired)
  self.fired = true
  self.hospital:changeReputation("kicked")
  self:setHospital(nil)
  self.hover_cursor = nil
  self.attributes["fatigue"] = nil
  
  -- Unregister any build callbacks or messages.
  self:unregisterCallbacks()
end

function Staff:die()
  self:setHospital(nil)
  -- Update the staff management screen (if present) accordingly
  local window = self.world.ui:getWindow(UIStaffManagement)
  if window then
    window:updateStaffList(self)
  end
  -- It may be that the staff member was fired just before dying (then self.hospital = nil)
  self.world.ui.hospital:humanoidDeath(self)
end

-- Function which is called when the user clicks on the staff member.
-- Responsible for opening a staff information dialog on left click and picking
-- up the staff member on right click.
--!param ui (GameUI) The UI which the user in question is using.
--!param button (string) One of: "left", "middle", "right".
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
  elseif button == "right" then
    self.pickup = true
    self:setNextAction({name = "pickup", ui = ui, must_happen = true}, true)
  end
  Humanoid.onClick(self, ui, button)
end

function Staff:dump()
  print("-----------------------------------")
  if self.on_call then
    print("On call: ")
    CallsDispatcher.dumpCall(self.on_call)
  else 
    print('On call: no')
  end
  print("Busy: ", (self:isIdle() and "idle" or "busy") .. (self.pickup and " and picked up" or ''))
  if self.going_to_staffroom then print("Going to staffroom") end
  if self.last_room then 
      print("Last room: ", self.last_room.room_info.id .. '@' .. self.last_room.x ..','.. self.last_room.y)
  end
  if self.humanoid_class == "Handyman" then
    print("Cleaning: " .. self.attributes["cleaning"],
          "Watering: " .. self.attributes["watering"], 
          "Repairing: " .. self.attributes["repairing"])
  end
  Humanoid.dump(self)
end

function Staff:setProfile(profile)
  self.profile = profile
  self:setType(profile.humanoid_class)
  if self.humanoid_class ~= "Receptionist" then
    self.attributes["fatigue"] = 0
  end
  -- The handyman has three additional attributes
  if self.humanoid_class == "Handyman" then
    self.attributes["cleaning"] = 0.333
    self.attributes["watering"] = 0.333
    self.attributes["repairing"] = 0.333
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
      professions = professions .. _S.staff_title.surgeon .. " "
      number = number + 1
    end
    if profile.is_psychiatrist >= 1.0 then
      if number < 3 then
        professions = professions .. _S.staff_title.psychiatrist
      else
        professions = professions .. _S.dynamic_info.staff.psychiatrist_abbrev
      end
    end
    
    if professions == "" then
      professions = _S.staff_title.doctor
    end
    self.profile.profession = professions
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

-- Update the movement speed
function Staff:updateSpeed()
  local level = 2
  if self.profile.is_junior then
    level = 1
  elseif self.profile.is_consultant then
    level = 3
  end
  local room = self:getRoom()
  if room and room.room_info.id == "training" then
    level = 1
  elseif self.attributes["fatigue"] then
    if self.attributes["fatigue"] >= 0.8 then
      level = level - 2
    elseif self.attributes["fatigue"] >= 0.7 then
      level = level - 1
    end
  end
  if level >= 3 then
    self.speed = "fast"
    self.slow_animation = false
  elseif level <= 1 then
    self.speed = "slow"
    self.slow_animation = true
  else 
    self.speed = "normal"
    self.slow_animation = false
  end
end

-- Check if fatigue is over a certain level (decided by the hospital policy),
-- and go to the StaffRoom if it is.
function Staff:checkIfNeedRest()
  if self.attributes["fatigue"] then
    -- Only when the staff member is very tired should the icon emerge.
    if self.attributes["fatigue"] >= 0.7 then
      self:setMood("tired", "activate")
    end
    -- If above the policy threshold, go to the staff room.
    if self.attributes["fatigue"] >= self.hospital.policies["goto_staffroom"] 
    and not class.is(self:getRoom(), StaffRoom) then
      local profile = self.profile
      if self.waiting_for_staffroom then
      -- The staff will get unhappy if there is no staffroom to rest in.
      -- TODO: Add corresponding adviser alert.
        self:changeAttribute("happiness", -0.01)
      end
      -- Abort if waiting for a staffroom to be built, waiting for the patient to leave,
      -- already going to staffroom or being picked up
      if self.waiting_for_staffroom or self.staffroom_needed
      or self.going_to_staffroom or self.pickup then
        return
      end
      -- If no staff room exists, prevent further checks until one is built
      if not self.world:findRoomNear(self, "staff_room") then
        self.waiting_for_staffroom = true
        local callback
        callback = --[[persistable:staff_build_staff_room_callback]] function(room)
          if room.room_info.id == "staff_room" then
            self.waiting_for_staffroom = nil
            self.world:unregisterRoomBuildCallback(callback)
            self.build_callback = nil
          end
        end
        self.build_callback = callback
        self.world:registerRoomBuildCallback(callback)
        return
      end
      local room = self:getRoom()
      if self.humanoid_class ~= "Handyman" and room and room:getPatient() then
        -- If occupied by patient, staff will go to the staffroom after the patient left.
        self.staffroom_needed = true
      else
        self:goToStaffRoom()
      end
    end
  end
end

function Staff:setCrazy(crazy)
  if crazy then
    -- make doctor crazy
    if not self.is_crazy then
      self:setLayer(5, self.profile.layer5 + 4)
      self.world.ui.adviser:say(_S.adviser.warnings.doctor_crazy_overwork)
      self.is_crazy = true
    end
  else
    -- make doctor sane
    if self.is_crazy then
      if self.humanoid_class == "Doctor" and not (self.layers[5] < 5) then
        self:setLayer(5, self.layers[5] - 4)
        self.is_crazy = false
      end
    end
  end
end

function Staff:goToStaffRoom()
  -- NB: going_to_staffroom set if (and only if) a seek_staffroom action is in the action_queue
  self.going_to_staffroom = true
  local room = self:getRoom()
  if room then
    self:setNextAction(room:createLeaveAction())
    self:queueAction{name = "seek_staffroom", must_happen = true}
  else
    self:setNextAction{name = "seek_staffroom", must_happen = true}
  end
end

function Staff:onPlaceInCorridor()
  local world = self.world
  local notify_object = world:getObjectToNotifyOfOccupants(self.tile_x, self.tile_y)
  if notify_object then
    notify_object:onOccupantChange(1)
  end
  -- Assume that if the player puts someone in the corridor they don't want the 
  -- staff member to primarily return to his/her old room.
  self.last_room = nil
  
  self:updateSpeed()
  self:setNextAction{name = "meander"}
  if self.humanoid_class == "Receptionist" then
    world:findObjectNear(self, "reception_desk", nil, function(x, y)
      local obj = world:getObject(x, y, "reception_desk")
      if not obj.receptionist and not obj.reserved_for then
        obj.reserved_for = self
        self.associated_desk = obj
        obj.receptionist = self
        local use_x, use_y = obj:getSecondaryUsageTile()
        self:setNextAction{name = "walk", x = use_x, y = use_y, must_happen = true}
        self:queueAction{name = "staff_reception", object = obj, must_happen = true}
        return true
      end
    end)
  end
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

  if self.on_call or self.pickup or self.going_to_staffroom or self.staffroom_needed then
    return false
  end

  -- if they are using a door they are not idle, this stops doctors being considered for staff selection
  -- for rooms they have not completely left yet, fixes issue 810
  if self.user_of and self.user_of.object_type.id == "door" then
    return false
  end

  local room = self:getRoom()
  if room then
    -- in special rooms, never
    if room.room_info.id == "staff_room" or room.room_info.id == "research"
    or room.room_info.id == "training" then
      return false
    end

    -- For handyman - just check the on_call flag
    if self.humanoid_class == "Handyman" and not self.on_call then
      return true
    end
    
    -- For other staff...
    -- in regular rooms (diagnosis / treatment), if no patient is in sight
    -- or if the only one in sight is actually leaving.
    if self.humanoid_class ~= "Handyman" and room.door.queue:patientSize() == 0 and not self.action_queue[1].is_leaving
    and not (room.door.reserved_for and class.is(room.door.reserved_for, Patient)) then
      if room:getPatientCount() == 0 then
        return true
      else
        -- It might still be the case that the patient is leaving
        for _, action in ipairs(room:getPatient().action_queue) do
          if action.is_leaving then
            return true
          end
        end
      end
    end
  else
    -- In the corridor and not on_call (watering or going to room), the staff is free
    -- unless going back to the training room or research department.
    local x, y = self.action_queue[1].x, self.action_queue[1].y
    if x then
      room = self.world:getRoom(x, y)
      if room and (room.room_info.id == "training" 
                   or room.room_info.id == "research") then
        return false
      end
    end
    return true
  end
  return false
end

-- Makes the staff member request a raise of 10%, or a wage exactly inbetween their current and a fair one, whichever is more.
function Staff:requestRaise()
  -- Check whether there is already a request for raise.
  if not self:isMoodActive("pay_rise") then
    local amount = math.floor(math.max(self.profile.wage * 1.1, (self.profile:getFairWage(self.world) + self.profile.wage) / 2) - self.profile.wage)
    -- At least for now, staff are timid, and only ask for raises 1/5th of the time
    if math.random(1, 5) ~= 1 or amount <= 0 then
      self.timer_until_raise = nil
      return
    end
    self.quitting_in = 25*30 -- Time until the staff members quits anyway
    self:setMood("pay_rise", "activate")
    self.world.ui.bottom_panel:queueMessage("strike", amount, self)
  end
end

-- Increases the wage of the staff member. Also increases happiness and clears
-- any request raise dialogs.
--!param amount (integer) The amount, in game dollars per month, to increase
-- the salary by.
function Staff:increaseWage(amount)
  self.profile.wage = self.profile.wage + amount
  self.world.ui:playSound "cashreg.wav"
  if self.profile.wage > 2000 then -- What cap here?
    self.profile.wage = 2000
  else -- If the cap has been reached this member of staff won't get happy
       -- ever again...
    self:changeAttribute("happiness", 0.99)
    self:setMood("pay_rise", "deactivate")
  end
end

function Staff:setDynamicInfoText(text)
  self.dynamic_text = text
  self:updateDynamicInfo()
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

function Staff:onDestroy()
  -- Remove any message related to the staff member.
  if self.message_callback then
    self:message_callback(true)
    self.message_callback = nil
  end
  Humanoid.onDestroy(self)
end

function Staff:afterLoad(old, new)
  -- Usage of going_to_staffroom flag changed slightly, so unset it.
  -- (should be safe even if someone is actually going to staffroom)
  if old < 27 then
    self.going_to_staffroom = nil
  end

  if old < 29 then
    -- Handymen could have "staffroom_needed" flag set due to a bug, unset it.
    if self.humanoid_class == "Handyman" then
      self.staffroom_needed = nil
    end
  end
end
