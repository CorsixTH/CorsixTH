--[[ Copyright (c) 2020 Albert "Alberth" Hofkamp

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

class "PlayerHospital" (Hospital)

---@type PlayerHospital
local PlayerHospital = _G["PlayerHospital"]

local num_sitting_ratios = 15 -- Number of stored recent sitting ratio measurements.
local ratio_interval = 2 -- Measurement interval in days.

function PlayerHospital:PlayerHospital(world, avail_rooms, name)
  self:Hospital(world, avail_rooms, name)
  -- The player hospital in single player can access the Cheat System should they wish to.
  self.hosp_cheats = Cheats(self)

  self.adviser_data = { -- Variables handling player advice.
    temperature_advice = nil, -- Whether the player received advice about room temp.

    sitting_ratios = {}, -- Measurements of recent sitting/standing ratios.
    sitting_index = 1 -- Next entry in 'sitting_ratios' to update.
  }
end

--! Give advice to the player at the end of a day.
function PlayerHospital:dailyAdviceChecks()
  local current_date = self.world:date()
  local day = current_date:dayOfMonth()

  -- Hold any advice back until the game has somewhat started.
  if current_date < Date(1, 5) then
    return
  end

  -- Warn about lack of a staff room.
  if day == 3 and self:countRoomOfType("staff_room") == 0 then
    local staffroom_advice = {
      _A.warnings.build_staffroom, _A.warnings.need_staffroom,
      _A.warnings.staff_overworked, _A.warnings.staff_tired,
    }
    self:giveAdvice(staffroom_advice)
  end

  -- Warn about lack of toilets.
  if day == 8 and self:countRoomOfType("toilets") == 0 then
    local toilet_advice = {
      _A.warnings.need_toilets, _A.warnings.build_toilets,
      _A.warnings.build_toilet_now,
    }
    self:giveAdvice(toilet_advice)
  end

  -- Make players more aware of the need for radiators
  if self:countRadiators() == 0 then
    self:giveAdvice({_A.information.initial_general_advice.place_radiators})
  end

  -- Verify patients well-being with respect to room temperature.
  if day == 15 and not self.adviser_data.temperature_advice
      and not self.heating.heating_broke then
    -- Check patients warmth, default value does not result in a message.
    local warmth = self:getAveragePatientAttribute("warmth", 0.3)
    if warmth < 0.22 then
      local cold_advice = {
        _A.information.initial_general_advice.increase_heating,
        _A.warnings.patients_very_cold, _A.warnings.people_freezing,
      }
      self:giveAdvice(cold_advice)
      self.adviser_data.temperature_advice = true

    elseif warmth >= 0.36 then
      local hot_advice = {
        _A.information.initial_general_advice.decrease_heating,
        _A.warnings.patients_too_hot, _A.warnings.patients_getting_hot,
      }
      self:giveAdvice(hot_advice)
      self.adviser_data.temperature_advice = true
    end
  end

  -- Verify staff well-being with respect to room temperature.
  if day == 20 and not self.adviser_data.temperature_advice
      and not self.heating.heating_broke then
    -- Check staff warmth, default value does not result in a message.
    local warmth = self:getAverageStaffAttribute("warmth", 0.25)
    if warmth < 0.22 then
      self:giveAdvice({_A.warnings.staff_very_cold})
      self.adviser_data.temperature_advice = true

    elseif warmth >= 0.36 then
      self:giveAdvice({_A.warnings.staff_too_hot})
      self.adviser_data.temperature_advice = true
    end
  end

  -- Are there sufficient drinks available?
  if day == 24 then
    -- Check patients thirst, default value does not result in a message.
    local thirst = self:getAveragePatientAttribute("thirst", 0)

    -- Increase need after the first year.
    local threshold = current_date:year() == 1 and 0.9 or 0.8
    if thirst > threshold then
      self:giveAdvice({_A.warnings.patients_very_thirsty})
    elseif thirst > 0.6 then
      local thirst_advice = {
        _A.warnings.patients_thirsty, _A.warnings.patients_thirsty2,
      }
      self:giveAdvice(thirst_advice)
    end
  end

  -- Track sitting / standing ratio of patients.
  if day % ratio_interval == 0 then
    -- Compute the ratio of today.
    local num_sitting, num_standing = self:countSittingStanding()
    local ratio = (num_sitting + num_standing > 10)
        and num_sitting / (num_sitting + num_standing) or nil

    -- Store the measured ratio.
    self.adviser_data.sitting_ratios[self.adviser_data.sitting_index] = ratio
    self.adviser_data.sitting_index = (self.adviser_data.sitting_index >= num_sitting_ratios)
        and 1 or self.adviser_data.sitting_index + 1
  end

  -- Check for enough (well-placed) benches.
  if day == 12 then
    -- Compute average sitting ratio.
    local sum_ratios = 0
    local index = 1
    while index <= num_sitting_ratios do
      local ratio = self.adviser_data.sitting_ratios[index]
      if ratio == nil then
        sum_ratios = nil
        break
      else
        sum_ratios = sum_ratios + ratio
      end

      index = index + 1
    end

    if sum_ratios ~= nil then -- Sufficient data available.
      local ratio = sum_ratios / num_sitting_ratios
      if ratio < 0.7 then -- At least 30% standing.
        local bench_advice = {
          _A.warnings.more_benches, _A.warnings.people_have_to_stand,
        }
        self:giveAdvice(bench_advice)

      elseif ratio > 0.9 then
        -- Praise having enough well placed seats about once a year.
        local bench_advice = {
          _A.praise.many_benches, _A.praise.plenty_of_benches,
          _A.praise.few_have_to_stand,
        }
        self:giveAdvice(bench_advice, 1/12)
      end
    end
  end

  -- Reset advise flags at the end of the month.
  if day == 28 then
    self.adviser_data.temperature_advice = false
  end
end

--! Give advice to the player at the end of a month.
function PlayerHospital:monthlyAdviceChecks()
  if not self.world.free_build_mode then
    if self.balance < 2000 and self.balance >= -500 then
      local cashlow_advice = {
        _A.warnings.money_low, _A.warnings.money_very_low_take_loan,
        _A.warnings.cash_low_consider_loan,
      }
      self:giveAdvice(cashlow_advice)

    elseif self.balance < -2000 and self.world:date():monthOfYear() > 8 then
      -- TODO: Ideally this should be linked to the lose criteria for balance.
      self:giveAdvice({_A.warnings.bankruptcy_imminent})

    elseif self.balance > 6000 and self.loan > 0 then
      self:giveAdvice({_A.warnings.pay_back_loan})
    end
  end
end

--! Advises the player.
--!param msgs (array of string) Messages to select from.
--!param rnd_frac (optional float in range (0, 1]) Fraction of times that the
--    call actually says something.
function PlayerHospital:giveAdvice(msgs, rnd_frac)
  local max_rnd = #msgs
  if rnd_frac and rnd_frac > 0 and rnd_frac < 1 then
    -- Scale by the fraction.
    max_rnd = math.floor(max_rnd / rnd_frac)
  end

  local index = (max_rnd == 1) and 1 or math.random(1, max_rnd)
  if index <= #msgs then self.world.ui.adviser:say(msgs[index]) end
end

--! Called at the end of each day.
function PlayerHospital:onEndDay()
  -- Advise the player.
  if self:hasStaffedDesk() then
    self:dailyAdviceChecks()
  end

  Hospital.onEndDay(self)
end

-- Called at the end of each day.
function PlayerHospital:onEndMonth()
  -- Advise the player on cash flow.
  if self:hasStaffedDesk() then
    self:monthlyAdviceChecks()
  end

  Hospital.onEndMonth(self)
end

function PlayerHospital:afterLoad(old, new)
  if old < 145 then
    self.hosp_cheats = Cheats(self)
  end
  if old < 146 then
    self.adviser_data = {
      temperature_advise = nil,
      sitting_ratios = {},
      sitting_index = 1
    }
  end

  Hospital.afterLoad(self, old, new)
end
