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

-- Cheats only needs UI to function
function Cheats:Cheats(ui)
  self.ui = ui
  -- Cheats to appear specifically in the cheats window
  self.cheat_list = {
    {name = "money",          func = self.cheatMoney},
    {name = "all_research",   func = self.cheatResearch},
    {name = "emergency",      func = self.cheatEmergency},
    {name = "epidemic",       func = self.cheatEpidemic},
    {name = "toggle_infected", func = self.cheatToggleInfected},
    {name = "vip",            func = self.cheatVip},
    {name = "earthquake",     func = self.cheatEarthquake},
    {name = "create_patient", func = self.cheatPatient},
    {name = "end_month",      func = self.cheatMonth},
    {name = "end_year",       func = self.cheatYear},
    {name = "lose_level",     func = self.cheatLose},
    {name = "win_level",      func = self.cheatWin},
    {name = "increase_prices", func = self.cheatIncreasePrices},
    {name = "decrease_prices", func = self.cheatDecreasePrices},
  }
end

function Cheats:announceCheat()
  local announcements = self.ui.app.world.cheat_announcements
  if announcements then
    self.ui:playAnnouncement(announcements[math.random(1, #announcements)], AnnouncementPriority.Critical)
  end
  self.ui.hospital.cheated = true
end

function Cheats:cheatMoney()
  self.ui.hospital:receiveMoney(10000, _S.transactions.cheat)
end

function Cheats:cheatResearch()
  local hosp = self.ui.hospital
  for _, cat in ipairs({"diagnosis", "cure"}) do
    while hosp.research.research_policy[cat].current do
      hosp.research:discoverObject(hosp.research.research_policy[cat].current)
    end
  end
end

function Cheats:cheatEmergency()
  if not self.ui.hospital:createEmergency() then
    self.ui:addWindow(UIInformation(self.ui, {_S.misc.no_heliport}))
  end
end

--[[ Creates a new contagious patient in the hospital - potentially an epidemic]]
function Cheats:cheatEpidemic()
  self.ui.hospital:spawnContagiousPatient()
end

--[[ Before an epidemic has been revealed toggle the infected icons
to easily distinguish the infected patients -- will toggle icons
for ALL future epidemics you cannot distinguish between epidemics
by disease ]]
function Cheats:cheatToggleInfected()
  local hospital = self.ui.hospital
  if hospital.future_epidemics_pool and #hospital.future_epidemics_pool > 0 then
    for _, future_epidemic in ipairs(hospital.future_epidemics_pool) do
      local show_mood = future_epidemic.cheat_always_show_mood
      future_epidemic.cheat_always_show_mood = not show_mood
      local mood_action = show_mood and "deactivate" or "activate"
      for _, patient in ipairs(future_epidemic.infected_patients) do
        patient:setMood("epidemy4",mood_action)
      end
    end
  else
    self.ui.app.world:gameLog("Unable to toggle icons - no epidemics in progress that are not revealed")
  end
end

function Cheats:cheatVip()
  self.ui.hospital:createVip()
end

function Cheats:cheatEarthquake()
  return self.ui.app.world:createEarthquake()
end

function Cheats:cheatPatient()
  self.ui.app.world:spawnPatient()
end

function Cheats:cheatMonth()
  self.ui.app.world:setEndMonth()
end

function Cheats:cheatYear()
  self.ui.app.world:setEndYear()
end

function Cheats:cheatLose()
  self.ui.app.world:loseGame(1) -- TODO adjust for multiplayer
end

function Cheats:cheatWin()
  self.ui.app.world:winGame(1) -- TODO adjust for multiplayer
end

function Cheats:cheatIncreasePrices()
  local hosp = self.ui.app.world.hospitals[1]
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
  local hosp = self.ui.app.world.hospitals[1]
  for _, casebook in pairs(hosp.disease_casebook) do
    local new_price = casebook.price - 0.5
    if new_price < 0.5 then
      casebook.price = 0.5
    else
      casebook.price = new_price
    end
  end
end
