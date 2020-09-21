--[[ Copyright (c) 2010 Manuel "Roujin" Wolf
Copyright (c) 2020 lewri

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

--! A holder for all cheats in the game
class "Cheats"

---@type Cheats
local Cheats = _G["Cheats"]

-- Cheats System
function Cheats:Cheats(hospital)
  self.hospital = hospital
  -- Cheats to appear specifically in the cheats window
  -- New cheats require a persistable and a wrapped function in func
  self.cheat_list = {
    {name = "money",          func = --[[persistable:cheatMoney]] function() self:cheatMoney() end},
    {name = "all_research",   func = --[[persistable:cheatResearch]] function() self:cheatResearch() end},
    {name = "emergency",      func = --[[persistable:cheatEmergency]] function() self:cheatEmergency() end},
    {name = "epidemic",       func = --[[persistable:CheatEpidemic]] function() self:cheatEpidemic() end},
    {name = "toggle_infected", func = --[[persistable:cheatToggleInfected]] function() self:cheatToggleInfected() end},
    {name = "vip",            func = --[[persistable:cheatVip]] function() self:cheatVip() end},
    {name = "earthquake",     func = --[[persistable:cheatEarthquake]] function() self:cheatEarthquake() end},
    {name = "create_patient", func = --[[persistable:cheatPatient]] function() self:cheatPatient() end},
    {name = "end_month",      func = --[[persistable:cheatMonth]] function() self:cheatMonth() end},
    {name = "end_year",       func = --[[persistable:cheatYear]] function() self:cheatYear() end},
    {name = "lose_level",     func = --[[persistable:cheatLose]] function() self:cheatLose() end},
    {name = "win_level",      func = --[[persistable:cheatWin]] function() self:cheatWin() end},
    {name = "increase_prices", func = --[[persistable:cheatIncreasePrices]] function() self:cheatIncreasePrices() end},
    {name = "decrease_prices", func = --[[persistable:cheatDecreasePrices]] function() self:cheatDecreasePrices() end},
  }
end

function Cheats:announceCheat()
  local announcements = self.hospital.world.cheat_announcements
  if announcements then
    self.hospital.world.ui:playAnnouncement(announcements[math.random(1, #announcements)], AnnouncementPriority.Critical)
  end
  self.hospital.cheated = true
end

function Cheats:cheatMoney()
  self.hospital:receiveMoney(10000, _S.transactions.cheat)
end

function Cheats:cheatResearch()
  local hosp = self.hospital
  for _, cat in ipairs({"diagnosis", "cure"}) do
    while hosp.research.research_policy[cat].current do
      hosp.research:discoverObject(hosp.research.research_policy[cat].current)
    end
  end
end

function Cheats:cheatEmergency()
  if not self.hospital:createEmergency() then
    self.hospital.world.ui:addWindow(UIInformation(self.hospital.world.ui, {_S.misc.no_heliport}))
  end
end

--[[ Creates a new contagious patient in the hospital - potentially an epidemic]]
function Cheats:cheatEpidemic()
  self.hospital:spawnContagiousPatient()
end

--[[ Before an epidemic has been revealed toggle the infected icons
to easily distinguish the infected patients -- will toggle icons
for ALL future epidemics you cannot distinguish between epidemics
by disease ]]
function Cheats:cheatToggleInfected()
  local hosp = self.hospital
  if hosp.future_epidemics_pool and #hosp.future_epidemics_pool > 0 then
    for _, future_epidemic in ipairs(hosp.future_epidemics_pool) do
      local show_mood = future_epidemic.cheat_always_show_mood
      future_epidemic.cheat_always_show_mood = not show_mood
      local mood_action = show_mood and "deactivate" or "activate"
      for _, patient in ipairs(future_epidemic.infected_patients) do
        patient:setMood("epidemy4",mood_action)
      end
    end
  else
    self.hospital.world:gameLog("Unable to toggle icons - no epidemics in progress that are not revealed")
  end
end

function Cheats:cheatVip()
  self.hospital:createVip()
end

function Cheats:cheatEarthquake()
  return self.hospital.world:createEarthquake()
end

function Cheats:cheatPatient()
  self.hospital.world:spawnPatient()
end

function Cheats:cheatMonth()
  self.hospital.world:setEndMonth()
end

function Cheats:cheatYear()
  self.hospital.world:setEndYear()
end

function Cheats:cheatLose()
  self.hospital.world:loseGame(1) -- TODO adjust for multiplayer
end

function Cheats:cheatWin()
  self.hospital.world:winGame(1) -- TODO adjust for multiplayer
end

function Cheats:cheatIncreasePrices()
  local hosp = self.hospital
  for _, casebook in pairs(hosp.disease_casebook) do
    local new_price = casebook.price + 0.5
    if new_price > 2 then
      casebook.price = 2
    else
      casebook.price = new_price
    end
  end
end

function Cheats:cheatDecreasePrices()
  local hosp = self.hospital
  for _, casebook in pairs(hosp.disease_casebook) do
    local new_price = casebook.price - 0.5
    if new_price < 0.5 then
      casebook.price = 0.5
    else
      casebook.price = new_price
    end
  end
end
