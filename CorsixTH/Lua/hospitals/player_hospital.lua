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

corsixth.require("announcer")

local AnnouncementPriority = _G["AnnouncementPriority"]

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
    reception_advice = nil, -- Whether advice was given about building the reception.
    cured_died_message = nil, -- Whether the adviser reported about a cure or death.

    sitting_ratios = {}, -- Measurements of recent sitting/standing ratios.
    sitting_index = 1 -- Next entry in 'sitting_ratios' to update.
  }

  self.win_declined = false -- Has not yet declined the level win fax
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
  if day == 3 and self:countRoomOfType("staff_room", 1) == 0 then
    local staffroom_advice = {
      _A.warnings.build_staffroom, _A.warnings.need_staffroom,
      _A.warnings.staff_overworked, _A.warnings.staff_tired,
    }
    self:giveAdvice(staffroom_advice)
  end

  -- Warn about lack of toilets.
  if day == 8 and self:countRoomOfType("toilets", 1) == 0 then
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

  if day == 10 then
    self:warnForLongQueues()
  end

  -- Reset advise flags at the end of the month.
  if day == 28 then
    self.adviser_data.temperature_advice = false
  end
end

--! Give advice to the player at the end of a month.
function PlayerHospital:monthlyAdviceChecks()
  local today = self.world:date()
  local current_month = today:monthOfYear()
  local current_year = today:year()

  if not self:hasStaffedDesk() then
    self:checkReceptionAdvice(current_month, current_year)
    -- No other checks should happen in this month
    return
  end

  -- Check for advice on money.
  if not self.world.free_build_mode then
    if self.balance < 2000 and self.balance >= -500 then
      local cashlow_advice = {
        _A.warnings.money_low, _A.warnings.money_very_low_take_loan,
        _A.warnings.cash_low_consider_loan,
      }
      self:giveAdvice(cashlow_advice)

    elseif self.balance < -2000 and current_month > 8 then
      -- TODO: Ideally this should be linked to the lose criteria for balance.
      self:giveAdvice({_A.warnings.bankruptcy_imminent})

    elseif self.balance > 6000 and self.loan > 0 then
      self:giveAdvice({_A.warnings.pay_back_loan})
    end
  end
end

--! Make players aware of the need for a receptionist and desk.
--!param current_month (int) Month of the year.
--!param current_year (int) Current game year.
function PlayerHospital:checkReceptionAdvice(current_month, current_year)
  if current_year > 1 then return end -- Playing too long.

  local num_receptionists = self:countStaffOfCategory("Receptionist", 1)
  if num_receptionists ~= 0 and current_month > 2 and not self.adviser_data.reception_advice then
    self:giveAdvice({_A.warnings.no_desk_6})
    self.adviser_data.reception_advice = true

  elseif num_receptionists == 0 and current_month > 2 and self:countReceptionDesks() ~= 0  then
    self:giveAdvice({_A.warnings.no_desk_7})

  elseif current_month == 3 then
    self:giveAdvice({_A.warnings.no_desk}, 1, true)

  elseif current_month == 8 then
    self:giveAdvice({_A.warnings.no_desk_1}, 1, true)

  elseif current_month == 11 then
    if self.visitors == 0 then
      self:giveAdvice({_A.warnings.no_desk_2}, 1, true)
    else
      self:giveAdvice({_A.warnings.no_desk_3}, 1, true)
    end
  end
end

--! Give advice to the user about the need to buy the first reception desk.
function PlayerHospital:msgNeedFirstReceptionDesk()
  if self.adviser_data.reception_advice then return end

  if self:countReceptionDesks() == 0 then
    self.world.ui.adviser:say(_A.warnings.no_desk_4)
    self.adviser_data.reception_advice = true
  end
end

--! Give advice to the user about having bought a reception desk.
function PlayerHospital:msgReceptionDesk()
  local num_receptionists = self:countStaffOfCategory("Receptionist", 1)

  if not self.world.ui.start_tutorial and num_receptionists == 0 then
    self:giveAdvice({_A.room_requirements.reception_need_receptionist})
  elseif num_receptionists > 0 and self:countReceptionDesks() == 1 and
      not self.adviser_data.reception_advice and self.world:date():monthOfGame() > 3 then
    self:giveAdvice({_A.warnings.no_desk_5})
    self.adviser_data.reception_advice = true
  end
end

--! Give advice about having more desks.
function Hospital:msgMultiReceptionDesks()
  -- Compute total queue length at staffed receptions.
  local num_desks = 0
  local queue_total = 0
  for _, desk in ipairs(self:findReceptionDesks()) do
    num_desks = num_desks + 1
    if desk.receptionist or desk.reserved_for then
      queue_total = queue_total + #desk.queue
    end
  end

  local receptionists = self:countStaffOfCategory("Receptionist")
  if (receptionists > 1 and num_desks > 0) or (receptionists > 0 and num_desks > 1) then
    local queue_avg = math.floor(queue_total / num_desks)
    if receptionists < num_desks and queue_avg > 5 then
      self.world.ui.adviser:say(_A.warnings.reception_bottleneck)
    elseif queue_avg > 4 then
      self.world.ui.adviser:say(_A.warnings.queue_too_long_at_reception)
    elseif receptionists > num_desks then
      self.world.ui.adviser:say(_A.warnings.another_desk)
    end
  end
end

--! Give advice to the user about maintenance of plants.
function PlayerHospital:msgPlant()
  local num_handyman = self:countStaffOfCategory("Handyman", 1)

  if num_handyman == 0 then
    self:giveAdvice({_A.staff_advice.need_handyman_plants})
  end
end

--! Show the 'Gates to hell' animation.
--!param entity (Entity) Gates to hell.
function PlayerHospital:showGatesToHell(entity)
  local anim_func = --[[persistable:lava_hole_spawn_animation_end]]
    function(anim_entity)
      anim_entity:setAnimation(1602)
    end

  entity:playEntitySounds("LAVA00*.WAV", {0,1350,1150,950,750,350},
      {0,1450,1250,1050,850,450}, 40)
  entity:setTimer(entity.world:getAnimLength(2550), anim_func)
  entity:setAnimation(2550)
end

--! Advises the player.
--!param msgs (array of string) Messages to select from.
--!param rnd_frac (optional float in range (0, 1]) Fraction of times that the
--    call actually says something.
--!param stay_up (bool) If true, let the adviser remain visible afterwards.
--!return (boolean) Whether a message was given to the user.
function PlayerHospital:giveAdvice(msgs, rnd_frac, stay_up)
  local max_rnd = #msgs
  if rnd_frac and rnd_frac > 0 and rnd_frac < 1 then
    -- Scale by the fraction.
    max_rnd = math.floor(max_rnd / rnd_frac)
  end

  local index = (max_rnd == 1) and 1 or math.random(1, max_rnd)
  if index <= #msgs then
    self.world.ui.adviser:say(msgs[index], stay_up)
    return true
  end
  return false
end

--! Give the user possibly a message about a cured patient.
function PlayerHospital:msgCured()
  self.world.ui:playSound("cheer.wav") -- This sound is always heard

  if self.num_cured < 1 then -- First cure is always reported.
    self:giveAdvice({_A.information.first_cure})

  elseif self.num_cured > 1 and not self.adviser_data.cured_died_message then
    local cured_msgs = {
      _A.level_progress.another_patient_cured:format(self.num_cured),
      _A.praise.patients_cured:format(self.num_cured)
    }
    self.adviser_data.cured_died_message = self:giveAdvice(cured_msgs, 2/15)
  end
end

--! Give the user possibly a message about a dead patient.
function PlayerHospital:msgKilled()
  self.world.ui:playSound("boo.wav") -- this sound is always heard

  if self.num_deaths < 1 then -- First death is always reported.
    self:giveAdvice({_A.information.first_death})

  elseif self.num_deaths > 1 and not self.adviser_data.cured_died_message then
    local died_msgs = {
      _A.warnings.many_killed:format(self.num_deaths),
      _A.level_progress.another_patient_killed:format(self.num_deaths)
    }
    self.adviser_data.cured_died_message = self:giveAdvice(died_msgs, 6/10)
  end
end

--! Once a month the advisor may warn about long queues.
--! Rooms requiring a doctor occasionally trigger the generic message
function PlayerHospital:warnForLongQueues()
  local chosen_room = self:getRandomBusyRoom()
  if not chosen_room then return end
  chosen_room = chosen_room.room_info
  -- Required staff that is not nurse is doctor, researcher, surgeon or psych
  if chosen_room.required_staff and not chosen_room.required_staff["Nurse"]
      and math.random(1, 3) > 1 then
    local warn_msgs = {
      _A.warnings.queue_too_long_send_doctor:format(chosen_room.name),
      _A.staff_advice.need_doctors
    }
    self:giveAdvice(warn_msgs)
  else
    self.world.ui.adviser:say(_A.warnings.queues_too_long)
  end
end

function PlayerHospital:adviseDiscoverDisease(disease)
 -- Generate a message about the discovery
  local message = {
    {text = _S.fax.disease_discovered.discovered_name:format(disease.name)},
    {text = disease.cause, offset = 12},
    {text = disease.symptoms, offset = 12},
    {text = disease.cure, offset = 12},
    choices = {
      {text = _S.fax.disease_discovered.close_text, choice = "close"},
    },
  }
  self.world.ui.bottom_panel:queueMessage("disease", message, nil, 25*24, 1)

  -- If the drug casebook is open, update it.
  local window = self.world.ui:getWindow(UICasebook)
  if window then
    window:updateDiseaseList()
  end
end

--! Select a relevant message to be displayed to the user
--!param broken_heat (0 or 1) Boiler output due to being broken.
function PlayerHospital:adviseBoilerBreakdown(broken_heat)
  local ui = self.world.ui
  if broken_heat == 0 then
    ui.adviser:say(_A.boiler_issue.minimum_heat)
    ui:playRandomAnnouncement({ "sorry002.wav", "sorry004.wav" })
  else
    ui.adviser:say(_A.boiler_issue.maximum_heat)
    ui:playRandomAnnouncement({ "sorry003.wav", "sorry004.wav" })
  end
end

--! Announces a machine needing repair
--!param room The room of the machine
function PlayerHospital:announceRepair(room)
  local sound = room.room_info.handyman_call_sound
  local earthquake = self.world.next_earthquake
  self.world.ui:playAnnouncement("machwarn.wav", AnnouncementPriority.Critical)
  -- If an earthquake is happening don't play the call sound to prevent spamming
  if earthquake.active and earthquake.warning_timer == 0 then return end
  if self:countStaffOfCategory("Handyman", 1) == 0 then return end
  if sound then self.world.ui:playAnnouncement(sound, AnnouncementPriority.Critical) end
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
  -- Advise the player on the need for a staffed reception desk and cash flow.
  self:monthlyAdviceChecks()

  self.adviser_data.cured_died_message = nil -- Enable the message again.

  -- Check if a player has won the level at months 3, 6 and 9. The annual report
  -- window will perform this check at month 12 when it has been closed.
  -- If the offer is declined then the next check is at month 6 and the annual report.
  local check_months = {
    [3] = not self.win_declined,
    [6] = true,
    [9] = not self.win_declined
  }
  if check_months[self.world.game_date:monthOfYear()] then self.world:checkIfGameWon() end

  Hospital.onEndMonth(self)
end

--! Give visual warning that player doesn't have enough $ to build
-- Let the message remain until cancelled by the player as it is being displayed behind the town map
function PlayerHospital:adviseCannotAffordPlot()
  self.world.ui.adviser:say(_A.warnings.cannot_afford_2, true, true)
end

--! Tell the player, through the advisor, about the impact of casebook prices
--!param judgment (string - under, over, fair) The judgment of the price,
-- from Hospital:computePriceLevelImpact
--!param name (string) The name of the casebook entry of the diagnosis or disease
function PlayerHospital:advisePriceLevelImpact(judgment, name)
  local message
  if judgment == "under" then
    message = _A.warnings.low_prices:format(name)
  elseif judgment == "over" then
    message = _A.warnings.high_prices:format(name)
  else
    assert(judgment == "fair", "Price level impact judgements must be under, over or fair")
    message = _A.warnings.fair_prices:format(name)
  end
  self.world.ui.adviser:say(message)
end

--! Makes the raise request for a staff member
--!param amount (num) the requested raise increase
--!param staff (table) the staff member
function PlayerHospital:makeRaiseRequest(amount, staff)
  -- Show advice if it is the first time the player has experienced
  -- a staff member requesting a raise.
  -- Only show the help if the player is playing the campaign.
  if not self.has_seen_pay_rise and tonumber(self.world.map.level_number) then
    self.world.ui.adviser:say(_A.information.pay_rise)
    self.has_seen_pay_rise = true
  end
  self.world.ui.bottom_panel:queueMessage("strike", amount, staff)
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

  if old < 147 then
    -- Copy value of the previous name of the variable.
    self.adviser_data.reception_advice = self.receptionist_msg
  end
  if old < 148 then
    self.adviser_data.cured_died_message = nil
  end
  if old < 149 then
    self.win_declined = false -- Has not yet declined the level win fax
  end
  if old < 159 then
    self.adviser_data.reception_advice = self.adviser_data.reception_advice or self.receptionist_msg
  end

  Hospital.afterLoad(self, old, new)
end
