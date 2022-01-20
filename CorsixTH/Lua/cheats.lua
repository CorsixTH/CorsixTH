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
  -- New cheats require an afterLoad when added
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

  --[[ Toggle-based cheats are found in below function ]]
end

--! A private function to return the toggle_cheats list (code operated cheats)
--! These cheats do not appear in the Cheat UI menu, and are only accessed from fax code inputs currently.
--! They contain adviser strings, so cannot be persisted.
--!return the cheat list
function Cheats:_toggleCheatList()
  local toggle_cheats = {
      ["spawn_rate_cheat"] = {
      enable = self.roujinOn,
      disable = self.roujinOff,
      enableAnnouncement = _A.cheats.roujin_on_cheat,
      disableAnnouncement = _A.cheats.roujin_off_cheat,
      lower = 27868.3,
      upper = 27868.4,
    },
    ["no_rest_cheat"] = {
      enable = self.noRestOn,
      disable = self.noRestOff,
      enableAnnouncement = _A.cheats.norest_on_cheat,
      disableAnnouncement = _A.cheats.norest_off_cheat,
      lower = 185.5,
      upper = 185.6,
    },
  }
  return toggle_cheats
end

--! Performs a cheat from the cheat_list (menu cheats)
--!param num (integer) The cheat from the cheat_list called
--!return true if cheat was successful, false otherwise
function Cheats:performCheat(num)
  local cheat_success = self.cheat_list[num].func(self) ~= false
  return cheat_success and self.cheat_list[num].name ~= "lose_level"
end

--! Checks the obfuscated cheat code for a match and executes it
--!param num (number) The obfuscated cheat value
--!return Returns name of the cheat executed from the lookup table, or nil
function Cheats:processCheatCode(num)
  local cheat_list = self:_toggleCheatList()
  for name, data in pairs(cheat_list) do
    if data.lower < num and data.upper > num then
      self:toggleCheat(name)
      return name
    end
  end
  return -- cheat not found
end


--! Performs a cheat from fax_cheats
--!param name (string) The cheat called from the list
function Cheats:toggleCheat(name)
  local ui = self.hospital.world.ui
  local cheat_list = self:_toggleCheatList()
  local cheat = cheat_list[name]
  local cheatWindow = ui:getWindow(UICheats)
  local speech
  if not self.hospital.active_cheats[name] then
    cheat.enable(self)
    speech = cheat.enableAnnouncement
    self:announceCheat(speech)
  else
    cheat.disable(self)
    speech = cheat.disableAnnouncement
    self:announceCheat(speech)
  end
  -- If a cheats window is open, make sure the UI is updated
  if cheatWindow then
    cheatWindow:updateCheatedStatus()
  end
end

--! Updates the cheated status of the player, with a matching announcement
--!param speech (string) Optional text for the adviser to say
function Cheats:announceCheat(speech)
  local announcements = self.hospital.world.cheat_announcements
  local ui = self.hospital.world.ui
  if announcements then
    ui:playAnnouncement(announcements[math.random(1, #announcements)], AnnouncementPriority.Critical)
  end
  if speech then
    ui.adviser:say(speech)
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
  local err = self.hospital:createEmergency()
  local ui = self.hospital.world.ui
  if err == "undiscovered_disease" then
    ui:addWindow(UIInformation(ui, {_S.misc.cant_treat_emergency}))
  elseif err == "no_heliport" then
    ui:addWindow(UIInformation(ui, {_S.misc.no_heliport}))
  -- else 'err == nil', meaning success. The case doesn't need special handling
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

--[[Cheats operated through Faxes go here]]

--! Enable Roujin's challenge (spawn rate cheat)
function Cheats:roujinOn()
  self.hospital.active_cheats["spawn_rate_cheat"] = true
end

--! Disable Roujin's challenge (spawn rate cheat)
function Cheats:roujinOff()
  -- Clear the current month's spawns to give the player a break
  self.hospital.world.spawn_dates = {}
  self.hospital.active_cheats["spawn_rate_cheat"] = nil
end

--! Enables no rest cheat (staff do not tire, fast movement)
function Cheats:noRestOn()
  for _, staff in ipairs(self.hospital.staff) do
    if staff.attributes["fatigue"] then
      staff:wake(staff.attributes["fatigue"])
    end
  end
  self.hospital.active_cheats["no_rest_cheat"] = true
end

--! Disable no rest cheat (re-enable staff fatigue, and normal movement)
function Cheats:noRestOff()
  self.hospital.active_cheats["no_rest_cheat"] = nil
end
