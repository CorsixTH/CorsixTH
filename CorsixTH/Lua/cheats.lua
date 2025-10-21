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
  self.cheat_list = {
    {name = "money",          func = self.cheatMoney},
    {name = "all_research",   func = self.cheatResearch},
    {name = "emergency",      func = self.cheatEmergency},
    {name = "show_infected",  func = self.cheatShowInfected},
    {name = "epidemic",       func = self.cheatEpidemic},
    {name = "toggle_epidemic", func = self.cheatToggleEpidemic},
    {name = "earthquake",     func = self.cheatEarthquake},
    {name = "toggle_earthquake", func = self.cheatToggleEarthquake},
    {name = "vip",            func = self.cheatVip},
    {name = "create_patient", func = self.cheatPatient},
    {name = "end_month",      func = self.cheatMonth},
    {name = "end_year",       func = self.cheatYear},
    {name = "lose_level",     func = self.cheatLose},
    {name = "win_level",      func = self.cheatWin},
    {name = "increase_prices", func = self.cheatIncreasePrices},
    {name = "decrease_prices", func = self.cheatDecreasePrices},
    {name = "reset_death_count", func = self.cheatResetDeathCount},
    {name = "max_reputation",  func = self.cheatMaxReputation},
    {name = "repair_all_machines", func = self.cheatRepairAllMachines},
    {name = "toggle_invulnerable_machines", func = self.cheatToggleInvulnerableMachines},
  }

  self.active_cheats = {} -- Toggle cheat status
  --[[ Toggle-based cheats are found at bottom of file]]
end

--! Performs a cheat from the cheat_list (menu cheats)
--!param num (integer) The cheat from the cheat_list called
--!return true if cheat was successful, false otherwise
--!return message (optional string) The text message of the cheat.
function Cheats:performCheat(num)
  local cheat_success, message = self.cheat_list[num].func(self)
  cheat_success = cheat_success ~= false
  return cheat_success and self.cheat_list[num].name ~= "lose_level", message
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
  if err == "undiscovered_disease" then
    return false, _S.misc.cant_treat_emergency
  elseif err == "no_heliport" then
    return false, _S.misc.no_heliport
  -- else 'err == nil', meaning success. The case doesn't need special handling
  end
end

function Cheats:cheatToggleInfected() end -- Stub of the old name of the function below

--[[ Before an epidemic has been revealed, show/hide the infected mood icons
to easily distinguish the infected patients. This will show/hide icons
for ALL future epidemics you cannot distinguish between epidemics
by disease ]]--
function Cheats:cheatShowInfected()
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
    return false, _S.misc.epidemic_no_icon_to_toggle
  end
end

--[[ Creates a new contagious patient in the hospital - potentially an epidemic]]
function Cheats:cheatEpidemic()
  return self.hospital:spawnContagiousPatient()
end

--! Toggles the possibility of epidemics. Cancel any ongoing or preparing epidemics.
function Cheats:cheatToggleEpidemic()
  local hosp, msg = self.hospital
  if hosp.epidemics_disabled then
    msg = _S.misc.epidemics_on
  else
    msg = _S.misc.epidemics_off
    hosp:cancelEpidemics()
  end
  hosp.epidemics_disabled = not hosp.epidemics_disabled
  return true, msg
end

function Cheats:cheatEarthquake()
  return self.hospital.world.earthquake:createEarthquake()
end

--! Toggles the possibility of earthquakes
function Cheats:cheatToggleEarthquake()
  local world, msg = self.hospital.world
  if world.earthquake.disabled then
    msg = _S.misc.earthquakes_on
  else
    msg = _S.misc.earthquakes_off
  end
  world.earthquake.disabled = not world.earthquake.disabled
  return true, msg
end

function Cheats:cheatVip()
  self.hospital:createVip()
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

function Cheats:cheatResetDeathCount()
  self.hospital:resetDeathCount()
end

function Cheats:cheatMaxReputation()
  local hosp = self.hospital
  hosp:unconditionalChangeReputation(hosp.reputation_max)
end

--! Instantly repairs all of the player's machines (regardless of condition, without decreasing strength)
function Cheats:cheatRepairAllMachines()
  local world = self.hospital.world
  local machines = world:getPlayerMachines()

  for _, machine in ipairs(machines) do
    machine:machineRepaired(machine:getRoom(), false)
  end
end

--! Toggles machine invulnerability (no wear or explosions)
function Cheats:cheatToggleInvulnerableMachines()
  local msg

  if self:isCheatActive("invulnerable_machines") then
    msg = _S.misc.invulnerable_machines_off
  else
    msg = _S.misc.invulnerable_machines_on
  end

  self.active_cheats["invulnerable_machines"] = not self.active_cheats["invulnerable_machines"]
  return true, msg
end

--[[Begin toggle-based cheat functions]]

--! Enable Roujin's challenge (spawn rate cheat)
function Cheats:roujinOn()
  self.active_cheats["spawn_rate_cheat"] = true
end

--! Disable Roujin's challenge (spawn rate cheat)
function Cheats:roujinOff()
  -- Clear the current month's spawns to give the player a break
  self.hospital.world.spawn_dates = {}
  self.active_cheats["spawn_rate_cheat"] = nil
end

--! Enables no rest cheat (staff do not tire, fast movement)
function Cheats:noRestOn()
  for _, staff in ipairs(self.hospital.staff) do
    if staff:getAttribute("fatigue") then
      staff:wake(staff:getAttribute("fatigue"))
    end
  end
  self.active_cheats["no_rest_cheat"] = true
end

--! Disable no rest cheat (re-enable staff fatigue, and normal movement)
function Cheats:noRestOff()
  self.active_cheats["no_rest_cheat"] = nil
end

--! Enable queue jump cheat (for nearly dead patients)
function Cheats:queueJumpOn()
  self.active_cheats.queuejump = true
end

--! Disable queue jump cheat (for nearly dead patients)
function Cheats:queueJumpOff()
  self.active_cheats.queuejump = false
end

--! Enable super doctors cheat (all doctors for hire have maximum skills)
function Cheats:superDoctorOn()
  self.active_cheats.super_doctor = true
  self.hospital.world:makeAvailableStaff(self.hospital.world.game_date:monthOfGame())
end

--! Disable super doctors cheat (all doctors for hire have maximum skills)
function Cheats:superDoctorOff()
  self.active_cheats.super_doctor = false
  -- Available staff are returned to normal in World:onEndMonth.
end

--[[End toggle-based cheat functions]]

--[[ The toggle_cheats list (code operated cheats)
These cheats do not appear in the Cheat UI menu, and are only accessed from fax code inputs currently.
They contain adviser strings, so cannot be persisted.
]]--
local toggle_cheats = {
    ["spawn_rate_cheat"] = {
    enable = Cheats.roujinOn,
    disable = Cheats.roujinOff,
    enableAnnouncement = _A.cheats.roujin_on_cheat,
    disableAnnouncement = _A.cheats.roujin_off_cheat,
    lower = 27868.3,
    upper = 27868.4,
  },
  ["no_rest_cheat"] = {
    enable = Cheats.noRestOn,
    disable = Cheats.noRestOff,
    enableAnnouncement = _A.cheats.norest_on_cheat,
    disableAnnouncement = _A.cheats.norest_off_cheat,
    lower = 185.5,
    upper = 185.6,
  },
  queuejump = {
    enable = Cheats.queueJumpOn,
    disable = Cheats.queueJumpOff,
    enableAnnouncement = _A.cheats.queuejump_on_cheat,
    disableAnnouncement = _A.cheats.queuejump_off_cheat,
    lower = 200.5,
    upper = 200.6,
  },
  super_doctor = {
    enable = Cheats.superDoctorOn,
    disable = Cheats.superDoctorOff,
    enableAnnouncement = _A.cheats.superdoctor_on_cheat,
    disableAnnouncement = _A.cheats.superdoctor_off_cheat,
    lower = 301.5,
    upper = 301.6,
  },
}

--! Checks if a toggle cheat is activated
--!param name (string) Name of cheat to check
--!return Returns true if active
function Cheats:isCheatActive(name)
  return self.active_cheats[name]
end

--! Checks the obfuscated cheat code for a match and executes it
--!param num (number) The obfuscated cheat value
--!return Returns name of the cheat executed from the lookup table, or nil
function Cheats:processCheatCode(num)
  local cheat_list = toggle_cheats
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
  local cheat_list = toggle_cheats
  local cheat = cheat_list[name]
  local cheatWindow = ui:getWindow(UICheats)
  local speech
  if not self:isCheatActive(name) then
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
