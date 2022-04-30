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

local AnnouncementPriority = _G["AnnouncementPriority"]

--! A Doctor, Nurse, Receptionist, Handyman, or Surgeon
class "Staff" (Humanoid)

---@type Staff
local Staff = _G["Staff"]

--!param ... Arguments to base class constructor.
function Staff:Staff(...)
  self:Humanoid(...)
  self.hover_cursor = TheApp.gfx:loadMainCursor("staff")
  self.parcelNr = 0
  self.leave_sounds = {}
  self.leave_priority = AnnouncementPriority.High
end

--! Handle daily adjustments to staff.
--!return (boolean) Whether the caller should continue processing
function Staff:tickDay()
  if not Humanoid.tickDay(self) then
    return false
  end
  -- Pay too low  --> unhappy
  -- Pay too high -->   happy
  local fair_wage = self.profile:getFairWage()
  local wage = self.profile.wage
  self:changeAttribute("happiness", 0.05 * (wage - fair_wage) / (fair_wage ~= 0 and fair_wage or 1))
  -- if you overwork your Dr's then there is a chance that they can go crazy
  -- when this happens, find him and get him to rest straight away
  if self.attributes["fatigue"] then
    if self.attributes["fatigue"] < 0.7 then
      if self:isResting() then
        self:setMood("tired", "deactivate")
        self:changeAttribute("happiness", 0.006)
      end
    end
  -- Working when you should be taking a break will make you unhappy
    if self.attributes["fatigue"] >= self.hospital.policies["goto_staffroom"] then
      self:changeAttribute("happiness", -0.02)
    end
  -- You will also start to become unhappy as you become tired
    if self.attributes["fatigue"] >= 0.5 then
      self:changeAttribute("happiness", -0.01)
    end
  end
  -- It is nice to see plants, but dead plants make you unhappy
  self.world:findObjectNear(self, "plant", 2, function(x, y)
    local plant = self.world:getObject(x, y, "plant")
    if plant then
      self:changeAttribute("happiness", -0.003 + (plant:isPleasingFactor() * 0.001))
    end
  end)
  -- It always makes you happy to see you are in safe place
  self.world:findObjectNear(self, "extinguisher", 2, function()
    self:changeAttribute("happiness", 0.002)
  end)
  -- Extra room items add to your happiness (some more than others)
  self.world:findObjectNear(self, "bin", 2, function()
    self:changeAttribute("happiness", 0.001)
  end)
  self.world:findObjectNear(self, "bookcase", 2, function()
    self:changeAttribute("happiness", 0.003)
  end)
  self.world:findObjectNear(self, "skeleton", 2, function()
    self:changeAttribute("happiness", 0.002)
  end)
  self.world:findObjectNear(self, "tv", 2, function()
    self:changeAttribute("happiness", 0.0005)
  end)
  -- Being able to rest from work and play the video game or pool will make you happy
  if (self:getCurrentAction().name == "use_object" and self:getCurrentAction().object.object_type.id == "video_game") then
   self:changeAttribute("happiness", 0.08)
  end
  if (self:getCurrentAction().name == "use_object" and self:getCurrentAction().object.object_type.id == "pool_table") then
   self:changeAttribute("happiness", 0.074)
  end
  if (self:getCurrentAction().name == "use_object" and self:getCurrentAction().object.object_type.id == "sofa") then
   self:changeAttribute("happiness", 0.05)
  end

  local room = self:getRoom()
  if room then
    -- It always makes you happy to see the outdoors (or windows to anywhere)
    local count = room:countWindows()
    if room.room_info.id == "staff_room" then -- Pleased another bit
      count = count * 2
    end
    if count > 0 then
      -- More windows help but in smaller increments
      self:changeAttribute("happiness", math.round(math.log(count)) / 1000)
    end

    -- Extra space in the room you are in adds to your happiness
    local extraspace = (room.width * room.height) / (room.room_info.minimum_size * room.room_info.minimum_size)
    -- Greater space helps but in smaller increments
    self:changeAttribute("happiness", math.round(math.log(extraspace)) / 1000)
  end

  return true
end

function Staff:tick()
  Entity.tick(self)
  -- don't do anything if they're fired or picked up or have no hospital
  if self.fired or self.pickup or not self.hospital or self.dead then
    return
  end

  -- check if we need to use the staff room and go there if so
  self:checkIfNeedRest()
  -- check if staff has been waiting too long for a raise and fire if so
  self:checkIfWaitedTooLong()

  -- Decide whether the staff member should be tiring and tire them
  if self:isTiring() then
    self:tire(0.000090)
    self:changeAttribute("happiness", -0.00002)
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
  -- seeing litter will make you unhappy. If it is pee or puke it is worse
  self.world:findObjectNear(self, "litter", 2, function(x, y)
  local litter = self.world:getObject(x, y, "litter")
  if not litter then
    return
  end
    if litter:anyLitter() then
      self:changeAttribute("happiness", -0.0002)
    else
      self:changeAttribute("happiness", -0.0004)
    end
  end)
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
      --If the hospital policy is set to automatically grant wage increases, grant the requested raise
      --instead of firing the staff member
      if self.hospital.policies.grant_wage_increase then
        local amount = math.floor(math.max(self.profile.wage * 1.1, (self.profile:getFairWage(self.world) + self.profile.wage) / 2) - self.profile.wage)
        self.quitting_in = nil
        self:setMood("pay_rise", "deactivate")
        self.world.ui.bottom_panel:removeMessage(self)
        self:increaseWage(amount)
        return
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
  if self:getCurrentAction().name == "pickup" then
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
  self.hospital:spendMoney(self.profile.wage, _S.transactions.severance .. ": "
      .. self.profile:getFullName())
  self.world.ui:playSound("sack.wav")
  self:setMood("exit", "activate")
  self:setDynamicInfoText(_S.dynamic_info.staff.actions.fired)
  self.fired = true
  self.going_home = true
  self.hospital:changeReputation("kicked")
  self:despawn()
  self.hover_cursor = nil
  self.hospital:announceStaffLeave(self)
  -- Unregister any build callbacks or messages.
  self:unregisterCallbacks()
  -- Update the staff management window if it is open.
  local window = self.world.ui:getWindow(UIStaffManagement)
  if window then
    window:updateStaffList(self)
  end
end

function Staff:die()
  -- Update the staff management screen (if present) accordingly
  local window = self.world.ui:getWindow(UIStaffManagement)
  if window then
    window:updateStaffList(self)
  end
  self.dead = true
end

-- Despawns the staff member and removes them from the hospital
function Staff:despawn()
  self.hospital:removeStaff(self)
  Humanoid.despawn(self)
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
    self:setNextAction(PickupAction(ui), true)
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

  Humanoid.dump(self)
end

function Staff:setProfile(profile)
  self.profile = profile
  self:setType(profile.humanoid_class)
  self.attributes["fatigue"] = 0
  self:setLayer(5, profile.layer5)
  self.waiting_for_staffroom = false -- Staff member has detected there is no staff room to rest.
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
  if room and room.room_info.id == "training" and self:fulfillsCriterion("Doctor") then
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
  -- Only when the staff member is very tired should the icon emerge. Unhappiness will also escalate
  if self.attributes["fatigue"] >= 0.7 then
    self:setMood("tired", "activate")
    self:changeAttribute("happiness", -0.0002)
  end
  -- If above the policy threshold, go to the staff room.
  if self.attributes["fatigue"] >= self.hospital.policies["goto_staffroom"] and
      not class.is(self:getRoom(), StaffRoom) then
    -- The staff will get unhappy if there is no staffroom to rest in.
    if self.waiting_for_staffroom then
      self:changeAttribute("happiness", -0.001)
    end

    local room = self:getRoom()
    -- Nurses can leave a ward with patients remaining in their beds,
    -- nurses in other rooms and other staff must leave after all patients exit
    local may_leave = room and (room.room_info.id == "ward" or not room:getPatient())
    if (self.staffroom_needed and (may_leave or not room)) or
        (room and self.going_to_staffroom) then
      if self:getCurrentAction().name ~= "walk" and self:getCurrentAction().name ~= "queue" then
        self.staffroom_needed = nil
        self:goToStaffRoom()
      end
    end

    -- Abort if waiting for a staffroom to be built, waiting for the patient to leave,
    -- already going to staffroom or being picked up
    if self.waiting_for_staffroom or self.staffroom_needed or
        self.going_to_staffroom or self.pickup then
      return
    end

    -- If no staff room exists, prevent further checks until one is built
    if not self.world:findRoomNear(self, "staff_room") then
      self.waiting_for_staffroom = true -- notifyNewRoom resets it when a staff room gets built.
      return
    end

    if self.humanoid_class ~= "Handyman" and room and room:getPatient() then
      -- If occupied by patient, staff will go to the staffroom after the patient left.
      self.staffroom_needed = true
    else
      self:goToStaffRoom()
    end
  end
end

function Staff:notifyNewRoom(room)
  if room.room_info.id == "staff_room" then
    self.waiting_for_staffroom = false
  end
end

function Staff:goToStaffRoom()
  -- NB: going_to_staffroom set if (and only if) a seek_staffroom action is in the action_queue
  self.going_to_staffroom = true

  local room = self:getRoom()
  if room then
    room.staff_leaving = true
    self:setNextAction(room:createLeaveAction())
    self:queueAction(SeekStaffRoomAction())
  else
    self:setNextAction(SeekStaffRoomAction())
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
  self:setNextAction(MeanderAction())
end

-- Sets the Hospital for a member of staff
--!param hospital (Hospital) - hospital to assign to member of staff
function Staff:setHospital(hospital)
  Humanoid.setHospital(self, hospital)
  self:updateDynamicInfo()
end

-- Helper function to decide if Staff fulfills a criterion
-- (one of "Doctor", "Nurse", "Psychiatrist", "Surgeon", "Researcher" and "Handyman", "Receptionist", "Junior", "Consultant")
function Staff:fulfillsCriterion(criterion) -- luacheck: ignore 212 keep args from parent class
  return false
end

function Staff:adviseWrongPersonForThisRoom()
  local room = self:getRoom()
  local room_name = room.room_info.long_name
  local required = (room.room_info.maximum_staff or room.room_info.required_staff)
  if required then
    if required.Nurse then
      self.hospital:giveAdvice({ _A.staff_place_advice.only_nurses_in_room:format(room_name) })
    elseif required.Surgeon then
      self.hospital:giveAdvice({ _A.staff_place_advice.only_surgeons })
    elseif required.Researcher then
      self.hospital:giveAdvice({ _A.staff_place_advice.only_researchers })
    elseif required.Psychiatrist then
      self.hospital:giveAdvice({ _A.staff_place_advice.only_psychiatrists })
    else
      self.hospital:giveAdvice({ _A.staff_place_advice.only_doctors_in_room:format(room_name) })
    end
  end
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

  if self.waiting_on_other_staff then
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
    if room.room_info.id == "staff_room" or room.room_info.id == "research" or
        room.room_info.id == "training" then
      return false
    end

    -- For handyman - just check the on_call flag
    if self.humanoid_class == "Handyman" and not self.on_call then
      return true
    end

    -- For other staff...
    -- in regular rooms (diagnosis / treatment), if no patient is in sight
    -- or if the only one in sight is actually leaving.
    if self.humanoid_class ~= "Handyman" and room.door.queue:patientSize() == 0 and
        not self:getCurrentAction().is_leaving and
        not (room.door.reserved_for and class.is(room.door.reserved_for, Patient)) then
      if room:getPatientCount() == 0 then
        return true
      else
        -- It might still be the case that the patient is leaving
        if room:getPatient():isLeaving() then
          return true
        end
      end
    end
  else
    -- In the corridor and not on_call (watering or going to room), the staff is free
    -- unless going back to the training room or research department.
    local x, y = self:getCurrentAction().x, self:getCurrentAction().y
    if x then
      room = self.world:getRoom(x, y)
      if room and (room.room_info.id == "training" or room.room_info.id == "research") then
        return false
      end
    end
    return true
  end
  return false
end

-- Makes the staff member request a raise of 10%, or a wage exactly in the middle of their current and a fair one, whichever is more.
function Staff:requestRaise()
  assert(self.hospital, "A staff member asked for a pay rise who doesn't belong to a hospital!")
  -- Check whether there is already a request for raise.
  if not self:isMoodActive("pay_rise") then
    local amount = math.floor(math.max(self.profile.wage * 1.1, (self.profile:getFairWage() + self.profile.wage) / 2) - self.profile.wage)
    -- At least for now, staff are timid, and only ask for raises 1/5th of the time
    if math.random(1, 5) ~= 1 or amount <= 0 then
      self.timer_until_raise = nil
      return -- too timid
    end
    -- The staff member can now successfully ask for a raise
    self.hospital:makeRaiseRequest(amount, self)
    self.quitting_in = 25*30 -- Time until the staff members quits anyway
    self:setMood("pay_rise", "activate")
  end
end

-- Increases the wage of the staff member. Also increases happiness and clears
-- any request raise dialogs.
--!param amount (integer) The amount, in game dollars per month, to increase
-- the salary by.
function Staff:increaseWage(amount)
  self.profile.wage = self.profile.wage + amount
  self.world.ui:playSound("cashreg.wav")
  if self.profile.wage > 2000 then -- What cap here?
    self.profile.wage = 2000
  else -- If the cap has been reached this member of staff won't get unhappy
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
  if old < 27 and new >= 27 then
    self.going_to_staffroom = nil
  end

  if old < 29 and new >= 29 then
    -- Handymen could have "staffroom_needed" flag set due to a bug, unset it.
    if self.humanoid_class == "Handyman" then
      self.staffroom_needed = nil
    end
  end

  if old < 64 and new >= 64 then
    -- added reference to world for staff profiles
    self.profile.world = self.world
  end
  if old < 68 and new >= 68 then
    if self.attributes["fatigue"] then
      if self.attributes["fatigue"] >= self.hospital.policies["goto_staffroom"] then
        self:goToStaffRoom()
        self.going_to_staffroom = true
      end
    end
  end

  if old < 121 and new >= 121 then
    if self.humanoid_class == "Handyman" and self.user_of and self.user_of.object_type.class == "Litter" then
      local litter = self.user_of
      local hospital = self.world:getHospital(litter.tile_x, litter.tile_y)
      local taskIndex = hospital:getIndexOfTask(litter.tile_x, litter.tile_y, "cleaning", litter)
      hospital:removeHandymanTask(taskIndex, "cleaning")
    end
  end

  if old < 133 and new >= 133 then
    if self.humanoid_class == "Handyman" then
      setmetatable(self, Handyman._metatable)
    elseif self.humanoid_class == "Receptionist" then
      setmetatable(self, Receptionist._metatable)
    elseif self.humanoid_class == "Nurse" then
      setmetatable(self, Nurse._metatable)
    else
      setmetatable(self, Doctor._metatable)
    end

    -- The new class's afterLoad calls staff.afterLoad, so to avoid
    -- infinite recursion we need to finish afterLoad actions up to
    -- this version, and then pretend we are starting from this
    -- version to avoid running them a second time.
    Humanoid.afterLoad(self, old, 133)
    self:afterLoad(133, new)
    return
  end

  Humanoid.afterLoad(self, old, new)
end

function Staff:getDrawingLayer()
  return 4
end

--! Estimate staff service quality based on skills, restfulness (inverse of fatigue) and happiness.
--!return (float) between [0-1] indicating quality of the service.
function Staff:getServiceQuality()
  -- weights
  local skill_weight = 0.7
  local restfulness_weight = 0.2
  local happiness_weight = 0.1

  local weighted_skill = skill_weight * self.profile.skill
  -- Less fatigue is better
  local weighted_restfulness = restfulness_weight * (1 - self.attributes["fatigue"])
  local weighted_happiness = happiness_weight * self.attributes["happiness"]

  return weighted_skill + weighted_restfulness + weighted_happiness
end

--[[ Return string representation
!return (string)
]]
function Staff:tostring()
  return Humanoid.tostring(self)
end

-- Dummy callback for savegame compatibility
local callbackNewRoom = --[[persistable:staff_build_staff_room_callback]] function() end
