--[[ Copyright (c) 2011 John Pirie

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

--[[
---------------------------------- VIP Rating System ---------------------------------
| Vip rating is calculated between 0 and 15                                          |
| If rating exceeds values, it will be capped as necessary                           |
| 1. LITTER OBJECTS                                                                  |
|  - a. General litter and vomit 'litter' is counted                                 |
|  - b. At end of visit, if number <=10 award -1                                     |
|  - c. Otherwise, award +1                                                          |
| 2. STAFF TIREDNESS                                                                 |
|  - a. If staff <=1, award +4 and skip other checks                                 |
|  - b. If any staff member very tired (over 0.7), award 2                           |
|  - c. If average staff tiredness over tired (0.5), award 1                         |
|  - d. Else award -1                                                                |
| 3. PATIENTS                                                                        |
|  - a. If average patient health >= 0.2, award -1                                   |
|  - b. If average patient health < 0.2, award +1                                    |
|  - c. Assess patient warmth, too hot/cold award +2, perfect -1, just over 1        |
|  - d. Average happiness, award 3 if <0.2; 2 if <0.4, 1 if <0.6, 0 if <0.8, else -1 |
|  - e. Check if anyone has died during visit, punish based on severity              |
| 4. DOCTORS                                                                         |
|  - a. If no doctors, award +4 and skip other checks                                |
|  - b. If more than half doctors are consultants, award -2                          |
|  - c. If more than half doctors are juniors, award +2                              |
| 5. ROOMS                                                                           |
|  - a. If there are no active rooms, award +4                                       |
|  - b. If rooms not crashed (exploded) <3, award +1                                 |
| 6. SEATING                                                                         |
|  - a. If more standing than siting, award +1, else -1                              |
--------------------------------------------------------------------------------------
--]]

--[[ initialisation --]]
corsixth.require("announcer")

local AnnouncementPriority = _G["AnnouncementPriority"]
--local Hospital = require 'Hospital'

--! A `Vip` who is in the hospital to evaluate the hospital and produce a report
class "Vip" (Humanoid)

---@type Vip
local Vip = _G["Vip"]

function Vip:Vip(...)
  self:Humanoid(...)
  self.hover_cursor = TheApp.gfx:loadMainCursor("default")
  self.action_string = ""
  self.name=""
  self.announced = false

    --original value is 50
    --First we should generate an initial VIP rating
  self.vip_rating = 8 - math.floor(math.random(0,5))
  print("My initial rating is " .. self.vip_rating)

  self.cash_reward = 0
  self.rep_reward = 0
  self.vip_message = 0
  self.enter_deaths = 0
  self.enter_visitors = 0
  self.enter_explosions = 0
  self.num_vomit_noninducing = 0
  self.num_vomit_inducing = 0
  self.found_vomit = {}
  self.num_visited_rooms = 0
  self.room_eval = 0
  self.waiting = 0
end

--[[--VIP while on premesis--]]
function Vip:tickDay()
  -- for the vip
if self.waiting then
    self.waiting = self.waiting - 1
    if self.waiting == 0 then
      if #self.world.rooms == 0 then
        -- No rooms have been built yet
        self:goHome()
      end
      -- First let the previous room go.
      -- Include this when the VIP is supposed to block doors again.
      --[[if self.next_room then
        self.next_room.door.reserved_for = nil
        self.next_room:tryAdvanceQueue()
      end--]]
      -- Find out which next room to visit.
      self.next_room_no, self.next_room = next(self.world.rooms, self.next_room_no)
      -- Make sure that this room is active
      while self.next_room and not self.next_room.is_active do
        self.next_room_no, self.next_room = next(self.world.rooms, self.next_room_no)
      end
      self:setNextAction(VipGoToNextRoomAction())
    end
  end

  self.world:findObjectNear(self, "litter", 8, function(x, y)
    local litter = self.world:getObject(x, y, "litter")
    if not litter then
      return
    end

    local alreadyFound = false
    for i=1, (self.num_vomit_noninducing + self.num_vomit_inducing) do
      if self.found_vomit[i] == litter then
        alreadyFound = true
        break
      end
    end

    self.found_vomit[(self.num_vomit_noninducing + self.num_vomit_inducing + 1)] = litter

    if not alreadyFound then
      if litter:anyLitter() then
        self.num_vomit_noninducing = self.num_vomit_noninducing + 1
          print("Found a litter")
      else
        self.num_vomit_inducing = self.num_vomit_inducing + 1
          print("Found a vomit")
      end
    end
  end)

  return Humanoid.tickDay(self)
end

-- display the VIP name in the info box
function Vip:updateDynamicInfo(action_string)
  self:setDynamicInfo('text', {self.name})
end

--[[--VIP is leaving--]]
function Vip:goHome()
  if self.going_home then
    return
  end

  self:unregisterCallbacks()
  -- Set the rating.
  self:setVIPRating()

  self.going_home = true
  -- save self.hospital so we can reference it in self:onDestroy
  self.last_hospital = self.hospital
  self:despawn()
end

function Vip:evaluateRoom()
    --do nothing. Just keeping it here to prevent a breakage, needs removing from vip_go_to_next_room.lua
end

--[[--VIP has left--]]
-- called when the vip is out of the hospital grounds
function Vip:onDestroy()
  local message
  -- First of all there's a special message if we're in free build mode.
    --debug
    print("I rate this hospital " .. self.vip_rating .. " penalty points out of 15")
    --end-debug
  if self.world.free_build_mode then
    self.last_hospital.reputation = self.last_hospital.reputation + 20
    message = {
      {text = _S.fax.vip_visit_result.vip_remarked_name:format(self.name)},
      {text = _S.fax.vip_visit_result.remarks.free_build[math.random(1, 3)]},
      choices = {{text = _S.fax.vip_visit_result.close_text, choice = "close"}}
    }
  elseif self.vip_rating <= 7 then
    self.last_hospital:receiveMoney(self.cash_reward, _S.transactions.vip_award)
    self.last_hospital.reputation = self.last_hospital.reputation + self.rep_reward
    self.last_hospital.pleased_vips_ty = self.last_hospital.pleased_vips_ty + 1
      message = {
        {text = _S.fax.vip_visit_result.vip_remarked_name:format(self.name)},
        {text = _S.fax.vip_visit_result.ordered_remarks[self.vip_message]},
        {text = _S.fax.vip_visit_result.rep_boost},
        {text = _S.fax.vip_visit_result.cash_grant:format(self.cash_reward)},
        choices = {{text = _S.fax.vip_visit_result.close_text, choice = "close"}}
      }
  elseif self.vip_rating >=8 and self.vip_rating <= 11 then
    -- dont tell player about any rep change in this range
    self.last_hospital.reputation = self.last_hospital.reputation + self.rep_reward
      message = {
        {text = _S.fax.vip_visit_result.vip_remarked_name:format(self.name)},
        {text = _S.fax.vip_visit_result.ordered_remarks[self.vip_message]},
        choices = {{text = _S.fax.vip_visit_result.close_text, choice = "close"}}
      }
  else
    self.last_hospital.reputation = self.last_hospital.reputation + self.rep_reward
      message = {
        {text = _S.fax.vip_visit_result.vip_remarked_name:format(self.name)},
        {text = _S.fax.vip_visit_result.ordered_remarks[self.vip_message]},
        {text = _S.fax.vip_visit_result.rep_loss},
        choices = {{text = _S.fax.vip_visit_result.close_text, choice = "close"}}
      }
  end
  self.world.ui.bottom_panel:queueMessage("report", message, nil, 24 * 20, 1)

  self.world:nextVip()

  return Humanoid.onDestroy(self)
end

function Vip:announce()
  local announcements = {
    "vip001.wav", "vip002.wav", "vip003.wav", "vip004.wav", "vip005.wav",
  }   -- there is also vip008 which announces a man from the ministry
  self.world.ui:playAnnouncement(announcements[math.random(1, #announcements)], AnnouncementPriority.High)
  if self.hospital.num_vips < 1 then
    self.world.ui.adviser:say(_A.information.initial_general_advice.first_VIP)
  else
    self.world.ui.adviser:say(_A.information.vip_arrived:format(self.name))
  end
end

function Vip:setVIPRating()
--[[-- Group factor 1: Litter--]]
      if (self.num_vomit_noninducing + self.num_vomit_inducing) <= 10 then
        self.vip_rating = self.vip_rating - 1
      else
        self.vip_rating = self.vip_rating + 1
      end
      print("I have assessed litter. My rating is now " .. self.vip_rating .. " points")

--[[-- Group factor 2: Staff tiredness--]]
--First get staff members
      local count_staff = 0
      for _, staff in ipairs(self.hospital.staff) do
        count_staff = count_staff + 1
      end
--Count number, if only 1 staff member, exit and award 4 points
      if count_staff > 1 then

-- Loop through staff tiredness, if any above verytired, break loop and award 2 points
        for _, staff in ipairs(self.hospital.staff) do
      print(staff.attributes["fatigue"])
      if staff.attributes["fatigue"] ~= nil then
          if staff.attributes["fatigue"] >= 0.7 then
            self.vip_rating = self.vip_rating + 2
            break --exit when triggered once
          end
        end
        end           
-- Average all staff tiredness. If above tiredness level award 1, else -1
    local avg_tired = 0    
    avg_tired = self.hospital:getAverageStaffAttribute("fatigue", 1)
  print(avg_tired .. " avg_tired")
        if avg_tired >= 0.5 then
          self.vip_rating = self.vip_rating + 1
        else
          self.vip_rating = self.vip_rating - 1
        end
      else 
        self.vip_rating = self.vip_rating + 4
      end
  print("I have assessed staff tiredness. My rating is now " .. self.vip_rating)
--[[-- Group factor 3: Patients--]]
-- Average all patient health, if below 20% award 1, else -1
      local avg_health = self.hospital:getAveragePatientAttribute("health", 0.19)
      if avg_health >= 0.2 then
        self.vip_rating = self.vip_rating - 1
      else
        self.vip_rating = self.vip_rating + 1
      end
      print("I have assessed patient health. My rating is now" .. self.vip_rating)
  -- do patient warmth
  local avg_warmth = self.hospital:getAveragePatientAttribute("warmth", nil)
  -- punish if too cold/hot
  if avg_warmth then
    local patients_warmth_ratio_rangemap = {
      {upper = 0.21, value = 2},
      {upper = 0.36, value = -1},
      {upper = 0.43, value = 1},
      {value = 2}
    }
    self.vip_rating = self.vip_rating + rangeMapLookup(avg_warmth, patients_warmth_ratio_rangemap)
    end
    -- check average patient happiness
  local avg_happiness = self.hospital:getAveragePatientAttribute("happiness", nil)
  if avg_happiness then
    local patients_happy_ratio_rangemap = {
      {upper = 0.20, value = 3},
      {upper = 0.40, value = 2},
      {upper = 0.60, value = 1},
      {upper = 0.80, value = 0},
                    {value = -1}
    }
    self.vip_rating = self.vip_rating + rangeMapLookup(avg_happiness, patients_happy_ratio_rangemap)
  end
print("I have assessed patient happiness. My rating is now " .. self.vip_rating .. " points")
  --check the visitor to patient death ratio
  local death_diff = self.hospital.num_deaths - self.enter_deaths
  local visitors_diff = self.hospital.num_visitors - self.enter_visitors
  if death_diff == 0 then
    if visitors_diff ~= 0 then --if there have been no new patients, no +/- points
      self.vip_rating = self.vip_rating - 4
    end
  else
    local death_ratio = visitors_diff / death_diff
    local death_ratio_rangemap = {
      {upper = 2, value = 4},
      {upper = 4, value = 3},
      {upper = 8, value = 2},
      {upper = 12, value = 1},
                  {value = 0}
    }
    self.vip_rating = self.vip_rating + rangeMapLookup(death_ratio, death_ratio_rangemap)
    print("I have assessed deaths. My rating is now " .. self.vip_rating .. " points")
  end
--[[--Group factor 4: Doctor ratios--]]
-- First get all doctors
  local num_docs = self.hospital:hasStaffOfCategory("Doctor")
  --if there's no doctors award +4
  if not num_docs then
    self.vip_rating = self.vip_rating + 4
  else
-- Count num. consultants, num. juniors
    local num_cons = self.hospital:hasStaffOfCategory("Consultant")
    if not num_cons then
      num_cons = 0
    end
    local num_junior = self.hospital:hasStaffOfCategory("Junior")
    if not num_junior then
      num_junior = 0
    end

-- If num. consultants / all doctors > 50%, award -1
    print(num_cons / num_docs .. " condocratio")
    print(num_junior / num_docs .. " jundocratio")
    if num_cons / num_docs > 0.5 then
      self.vip_rating = self.vip_rating - 1
-- If num. juniors / all doctors > 50%, award 1
    elseif num_junior / num_docs > 0.5 then
      self.vip_rating = self.vip_rating + 1
    end
  end
  print("I have assessed doctor numbers. My rating is now" .. self.vip_rating)
--[[--Group factor 5: Rooms--]]
-- Get number of rooms
  local count_rooms = 0
  for _, room in ipairs(self.world.rooms) do
    if not room.crashed then
      count_rooms = count_rooms + 1
    end
  end
-- If number of rooms is nil, award 4. If number of rooms <3, award 1. Else award 0
  if count_rooms < 1 then
  self.vip_rating = self.vip_rating + 4
  elseif count_rooms >= 1 and count_rooms < 3 then
    self.vip_rating = self.vip_rating + 1
  end
  print("I have assessed rooms. My rating is now" .. self.vip_rating)

  --[[Group factor 6: Seating--]]
  -- check the seating : standing ratio of waiting patients
  -- find all the patients who are currently waiting around
  local sum_sitting, sum_standing = self.hospital:countSittingStanding()
  if sum_sitting >= sum_standing then
    self.vip_rating = self.vip_rating - 1
  else
    self.vip_rating = self.vip_rating + 1
  end
print("I have assessed seating. My rating is now " .. self.vip_rating .. " points")
--[[--Finalise score--]]
  --documented rewards. Use +6 to account for numbering
local rewards = {
        [1] = 4000,
        [2] = 2000,
        [3] = 1500,
        [4] = 1200,
        [5] = 800,
        [6] = 400,
        [7] = 200,
        [8] = 0,
    }
--documented reps, values guessed. Use +6 to account for numbering
local rep_change = {
        [1] = 50,
        [2] = 45,
        [3] = 40,
        [4] = 35,
        [5] = 30,
        [6] = 25,
        [7] = 20,
        [8] = 15,
        [9] = 10,
        [10] = 5,
        [11] = -5,
        [12] = -10,
        [13] = -15,
        [14] = -20,
        [15] = -25,
    }
  if self.vip_rating >= 8 then
    self.cash_reward = rewards[8]
  elseif self.vip_rating <= 1 then
    self.cash_reward = rewards[1]
  else
    self.cash_reward = rewards[self.vip_rating]
  end
  print("cash reward " .. self.cash_reward)
  if self.vip_rating >= 15 then
    self.rep_reward = rep_change[15]
  elseif self.vip_rating <= 1 then
    self.rep_reward = rep_change[1]
  else
    self.rep_reward = rep_change[self.vip_rating]
  end
  print("rep reward " .. self.rep_reward)
  if self.vip_rating <= 1 then
  self.vip_message = 1
  elseif self.vip_rating >= 15 then
    self.vip_message = 15
  else
    self.vip_message = self.vip_rating
  end
  print("message number: " .. self.vip_message)
  self.hospital.num_vips_ty = self.hospital.num_vips_ty + 1
end

--remarks order pulled from orignal strings

function Vip:afterLoad(old, new)
  if old < 50 then
    self.num_visited_rooms = 0
    self:setNextAction(IdleAction())
    self.waiting = 1
    for _, room in pairs(self.world.rooms) do
      if room.door.reserved_for == self then
        room.door.reserved_for = nil
        room:tryAdvanceQueue()
      end
    end
  end
  if old < 79 then
    self.name = self.hospital.visitingVIP
  end
  Humanoid.afterLoad(self, old, new)
end