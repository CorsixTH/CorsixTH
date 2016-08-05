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

  self.vip_rating = 50

  self.cash_reward = 0

  self.enter_deaths = 0
  self.enter_visitors = 0
  self.enter_explosions = 0
  self.enter_cures = 0
  self.num_vomit_noninducing = 0
  self.num_vomit_inducing = 0
  self.found_vomit = {}
  self.num_visited_rooms = 0
  self.room_eval = 0
  self.waiting = 0
end

-- Check if it is cold or hot around the vip and increase/decrease the
-- feeling of warmth accordingly. Returns whether the calling function should proceed.
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
      else
        self.num_vomit_inducing = self.num_vomit_inducing + 1
      end
    end
  end)

  return Humanoid.tickDay(self)
end

-- display the VIP name in the info box
function Vip:updateDynamicInfo(action_string)
  self:setDynamicInfo('text', {self.name})
end

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

-- called when the vip is out of the hospital grounds
function Vip:onDestroy()
  local message
  -- First of all there's a special message if we're in free build mode.
  if self.world.free_build_mode then
    self.last_hospital.reputation = self.last_hospital.reputation + 20
    message = {
      {text = _S.fax.vip_visit_result.vip_remarked_name:format(self.name)},
      {text = _S.fax.vip_visit_result.remarks.free_build[math.random(1, 3)]},
      choices = {{text = _S.fax.vip_visit_result.close_text, choice = "close"}}
    }
  elseif self.vip_rating == 1 then
    self.last_hospital.reputation = self.last_hospital.reputation - 10
    message = {
      {text = _S.fax.vip_visit_result.vip_remarked_name:format(self.name)},
      {text = _S.fax.vip_visit_result.remarks.very_bad[math.random(1, 3)]},
      {text = _S.fax.vip_visit_result.rep_loss},
      choices = {{text = _S.fax.vip_visit_result.close_text, choice = "close"}}
    }
  elseif self.vip_rating == 2 then
    self.last_hospital.reputation = self.last_hospital.reputation - 5
    message = {
      {text = _S.fax.vip_visit_result.vip_remarked_name:format(self.name)},
      {text = _S.fax.vip_visit_result.remarks.bad[math.random(1, 3)]},
      {text = _S.fax.vip_visit_result.rep_loss},
      choices = {{text = _S.fax.vip_visit_result.close_text, choice = "close"}}
    }
  elseif self.vip_rating == 3 then
    message = {
      {text = _S.fax.vip_visit_result.vip_remarked_name:format(self.name)},
      {text = _S.fax.vip_visit_result.remarks.mediocre[math.random(1, 3)]},
      choices = {{text = _S.fax.vip_visit_result.close_text, choice = "close"}}
    }
  elseif self.vip_rating == 4 then
    self.last_hospital:receiveMoney(self.cash_reward, _S.transactions.vip_award)
    self.last_hospital.reputation = self.last_hospital.reputation + (math.round(self.cash_reward / 100))
    message = {
      {text = _S.fax.vip_visit_result.vip_remarked_name:format(self.name)},
      {text = _S.fax.vip_visit_result.remarks.good[math.random(1, 3)]},
      {text = _S.fax.vip_visit_result.rep_boost},
      {text = _S.fax.vip_visit_result.cash_grant:format(self.cash_reward)},
      choices = {{text = _S.fax.vip_visit_result.close_text, choice = "close"}}
    }
  else
    self.last_hospital:receiveMoney(self.cash_reward, _S.transactions.vip_award)
    self.last_hospital.reputation = self.last_hospital.reputation + (math.round(self.cash_reward / 100))
    self.last_hospital.pleased_vips_ty = self.last_hospital.pleased_vips_ty + 1
    if self.vip_rating == 5 then
      message = {
        {text = _S.fax.vip_visit_result.vip_remarked_name:format(self.name)},
        {text = _S.fax.vip_visit_result.remarks.super[math.random(1, 3)]},
        {text = _S.fax.vip_visit_result.rep_boost},
        {text = _S.fax.vip_visit_result.cash_grant:format(self.cash_reward)},
        choices = {{text = _S.fax.vip_visit_result.close_text, choice = "close"}}
      }
    end
  end
  self.world.ui.bottom_panel:queueMessage("report", message, nil, 24 * 20, 1)

  self.world:nextVip()

  return Humanoid.onDestroy(self)
end

function Vip:announce()
  local announcements = {
    "vip001.wav", "vip002.wav", "vip003.wav", "vip004.wav", "vip005.wav",
  }   -- there is also vip008 which announces a man from the ministry
  self.world.ui:playAnnouncement(announcements[math.random(1, #announcements)])
  if self.hospital.num_vips < 1 then
    self.world.ui.adviser:say(_A.information.initial_general_advice.first_VIP)
  else
    self.world.ui.adviser:say(_A.information.vip_arrived:format(self.name))
  end
end

function Vip:evaluateRoom()
  -- Another room visited.
  self.num_visited_rooms = self.num_visited_rooms + 1
  local room = self.next_room
  -- if the player is about to kill a live patient for research, lower their rating dramatically
  if room.room_info.id == "research" then
    if room:getPatient() then
      self.vip_rating = self.vip_rating - 80
    end
  end

  if room.staff_member then
    if room.staff_member.profile.skill > 0.9 then
      self.room_eval = self.room_eval + 3
    end
    if room.staff_member.attributes["fatigue"] then
      if room.staff_member.attributes["fatigue"] < 0.4 then
        self.room_eval = self.room_eval + 2
      end
    end
  end

  -- evaluate the room we're currently looking at
  for object, value in pairs(room.objects) do
    if object.object_type.id == "extinguisher" then
      self.room_eval = self.room_eval + 1
      break
    elseif object.object_type.id == "plant" then
      if object.days_left >= 10 then
        self.room_eval = self.room_eval + 1
      elseif object.days_left <= 3 then
        self.room_eval = self.room_eval - 1
      end
      break
    end

    if object.strength then
      if object.strength > (object.object_type.default_strength / 2) then
        self.room_eval = self.room_eval + 1
      else
        self.room_eval = self.room_eval - 3
      end
    end
  end
end

function Vip:evaluateEmergency(success)
  -- Make sure that the VIP is still actually in the process of evaluation
  if not self.going_home then
    if success then
      self.vip_rating = self.vip_rating + 10
    else
      self.vip_rating = self.vip_rating - 15
    end
  end
end

function Vip:setVIPRating()
  --check the visitor to patient death ratio
  local death_diff = self.hospital.num_deaths - self.enter_deaths
  local visitors_diff = self.hospital.num_visitors - self.enter_visitors
  if death_diff == 0 then
    if visitors_diff ~= 0 then --if there have been no new patients, no +/- points
      self.vip_rating = self.vip_rating + 20
    end
  else
    local death_ratio = visitors_diff / death_diff
    local death_ratio_rangemap = {
      {upper = 2, value = -20},
      {upper = 4, value = -10},
      {upper = 8, value = 0},
      {upper = 12, value = 5},
                  {value = 10}
    }
    self.vip_rating = self.vip_rating + rangeMapLookup(death_ratio, death_ratio_rangemap)
  end

  --check the visitor to patient cure ratio
  local cure_diff = self.hospital.num_cured - self.enter_cures
  local visitors_diff = self.hospital.num_visitors - self.enter_visitors
  if cure_diff == 0 then
    if visitors_diff ~= 0 then --if there have been no new patients, no +/- points
      self.vip_rating = self.vip_rating - 10
    end
  else
    local cure_ratio = visitors_diff / cure_diff
    local cure_ratio_rangemap = {
      {upper = 3, value = 20},
      {upper = 6, value = 10},
      {upper = 10, value = 0},
      {upper = 12, value = -5},
                 {value = -10}
    }
    self.vip_rating = self.vip_rating + rangeMapLookup(cure_ratio, cure_ratio_rangemap)
  end

  -- check for the average queue length
  local sum_queue = 0
  for _, room in pairs(self.world.rooms) do
    -- this can be nil if there has been a room explosion
    if room.door.queue then
      sum_queue = sum_queue + room.door.queue:size()
    end
  end

  if sum_queue == 0 then
    self.vip_rating = self.vip_rating + 6
  else
    local queue_ratio = sum_queue / #self.world.rooms
    local queue_ratio_rangemap = {
      {upper = 2, value = 6},
      {upper = 5, value = 3},
      {upper = 9, value = 0},
      {upper = 11, value = -3},
                  {value = -6}
    }
    self.vip_rating = self.vip_rating + rangeMapLookup(queue_ratio, queue_ratio_rangemap)
  end

  -- now we check for toilet presence
  local sum_toilets = 0
  for i, room in pairs(self.world.rooms) do
    if room.room_info.id == "toilets" then
      for object, value in pairs(room.objects) do
        if object.object_type.id == "loo" then
          sum_toilets = sum_toilets + 1
        end
      end
    end
  end
  if sum_toilets == 0 then
    self.vip_rating = self.vip_rating - 6
  else
    local patients_per_toilet = #self.hospital.patients / sum_toilets
    local toilet_ratio_rangemap = {
      {upper = 10, value = 6},
      {upper = 20, value = 3},
      {upper = 40, value = 0},
                  {value = -3}
    }
    self.vip_rating = self.vip_rating + rangeMapLookup(patients_per_toilet, toilet_ratio_rangemap)
  end

  -- check the levels of non-vomit inducing litter in the hospital
  local litter_ratio_rangemap = {
    {upper = 3, value = 4},
    {upper = 5, value = 2},
    {upper = 7, value = 0},
    {upper = 8, value = -2},
               {value = -4}
  }
  self.vip_rating = self.vip_rating + rangeMapLookup(self.num_vomit_noninducing, litter_ratio_rangemap)

  -- check the levels of vomit inducing litter in the hospital
  local inducing_ratio_rangemap = {
    {upper = 3, value = 8},
    {upper = 5, value = 4},
    {upper = 6, value = 0},
    {upper = 7, value = -6},
    {upper = 10, value = -12},
    {upper = 12, value = -16},
                {value = -20}
  }
  self.vip_rating = self.vip_rating + rangeMapLookup(self.num_vomit_inducing, inducing_ratio_rangemap)

  -- if there were explosions, hit the user hard
  if self.hospital.num_explosions ~= self.enter_explosions then
    self.vip_rating = self.vip_rating - 70
  end

  -- check the vip heat level
  local heat_ratio_rangemap = {
    {upper = 0.20, value = -5},
    {upper = 0.40, value = -3},
    {upper = 0.60, value = 0},
    {upper = 0.80, value = 3},
                  {value = 5}
  }
  self.vip_rating = self.vip_rating + rangeMapLookup(self.attributes["warmth"], heat_ratio_rangemap)

  -- check the seating : standing ratio of waiting patients
  -- find all the patients who are currently waiting around
  local sum_sitting, sum_standing = self.hospital:countSittingStanding()
  if sum_sitting >= sum_standing then
    self.vip_rating = self.vip_rating + 4
  else
    self.vip_rating = self.vip_rating - 4
  end

  -- check average patient thirst
  local avg_thirst = self.hospital:getAveragePatientAttribute("thirst", nil)
  if avg_thirst then
    local thirst_ratio_rangemap = {
      {upper = 0.20, value = -5},
      {upper = 0.40, value = -1},
      {upper = 0.60, value = 0},
      {upper = 0.80, value = 1},
                    {value = 3}
    }
    self.vip_rating = self.vip_rating + rangeMapLookup(avg_thirst, thirst_ratio_rangemap)
  end

  if self.num_visited_rooms ~= 0 then
    self.vip_rating = self.vip_rating + self.room_eval / self.num_visited_rooms
  end

  -- check average patient happiness
  local avg_happiness = self.hospital:getAveragePatientAttribute("happiness", nil)
  if avg_happiness then
    local patients_happy_ratio_rangemap = {
      {upper = 0.20, value = -10},
      {upper = 0.40, value = -5},
      {upper = 0.60, value = 0},
      {upper = 0.80, value = 5},
                    {value = 10}
    }
    self.vip_rating = self.vip_rating + rangeMapLookup(avg_happiness, patients_happy_ratio_rangemap)
  end

  -- check average staff happiness
  local avg_happiness = self.hospital:getAverageStaffAttribute("happiness", nil)
  if avg_happiness then
    local staff_happy_ratio_rangemap = {
      {upper = 0.20, value = -10},
      {upper = 0.40, value = -5},
      {upper = 0.60, value = 0},
      {upper = 0.80, value = 5},
                    {value = 10}
    }
    self.vip_rating = self.vip_rating + rangeMapLookup(avg_happiness, staff_happy_ratio_rangemap)
  end

  -- set the cash reward value
  if tonumber(self.world.map.level_number) then
    self.cash_reward = math.round(self.world.map.level_number * self.vip_rating) * 10
  else
    -- custom level, it has no level number. Default back to one.
    self.cash_reward = math.round(1 * self.vip_rating) * 10
  end
  if self.cash_reward > 2000 then
    self.cash_reward = 2000
  end

  -- give the rating between 1 and 5
  local rating_ratio_rangemap = {
    {upper = 25, value = 1},
    {upper = 45, value = 2},
    {upper = 65, value = 3},
    {upper = 85, value = 4},
                {value = 5}
  }
  self.vip_rating = rangeMapLookup(self.vip_rating, rating_ratio_rangemap)
  self.hospital.num_vips_ty = self.hospital.num_vips_ty + 1
end

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


