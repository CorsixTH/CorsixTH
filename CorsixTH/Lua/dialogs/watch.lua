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

--! Timer / clock / watch / countdown dialog for emergencies / level start
--! The timer lasts approximately 100 days, split into 13 segments
class "UIWatch" (Window)

---@type UIWatch
local UIWatch = _G["UIWatch"]

local TICK_DAYS = 100
local TICK_DAYS_EMERGENCY = 52
local TIMER_SEGMENTS = 13

--!param count_type (string) One of: "open_countdown" or "emergency" or "epidemic"
function UIWatch:UIWatch(ui, count_type)
  self:Window()

  local app = ui.app

  self.esc_closes = false
  self.modal_class = "open_countdown"
  if count_type == "emergency" then
    self.tick_rate = math.floor((TICK_DAYS_EMERGENCY * Date.hoursPerDay()) / TIMER_SEGMENTS)
    self.tick_timer = self.tick_rate
  elseif count_type == "tutorial" then
    self.tick_rate = 0
    self.tick_timer = 0
  else
    self.tick_rate = math.floor((TICK_DAYS * Date.hoursPerDay()) / TIMER_SEGMENTS)
    self.tick_timer = self.tick_rate  -- Initialize tick timer
  end
  self.open_timer = 12
  self.ui = ui
  self.hospital = ui.hospital
  self.width = 39
  self.height = 79
  self:setDefaultPosition(20, -100)
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "Watch01V", true)
  self.epidemic = false
  self.count_type = count_type
  -- For cycling the list of epidemic/emergency patients which index to use
  self.current_index = nil
  -- The last patient whose dialog was opened by clicking the timer
  self.lastCycledPatient = nil

  local end_sprite = (count_type == "epidemic") and 14 or 16

  local tooltips = {
    ["initial_opening"] = _S.tooltip.watch.hospital_opening,
    ["emergency"]       = _S.tooltip.watch.emergency,
    ["epidemic"]        = _S.tooltip.watch.epidemic,
    ["tutorial"]        = _S.tooltip.watch.tutorial,
  }

  if count_type == "epidemic" then
    self.end_button = self:addPanel(end_sprite, 4, 0)
    :makeButton(4, 0, 27, 28, end_sprite + 1, self.toggleVaccinationMode)
    :setTooltip(tooltips[count_type])
  elseif count_type ~= "emergency" then
    self.end_button = self:addPanel(end_sprite, 4, 0)
      :makeButton(4, 0, 27, 28, end_sprite + 1, self.onCountdownEnd)
      :setTooltip(tooltips[count_type])
  end

  local timer_sprite = 13
  if count_type == "epidemic" or count_type == "emergency" then
    self:addPanel(timer_sprite, 0, 28)
      :setTooltip(tooltips[count_type])
      :makeButton(timer_sprite, 0, 25, 50, timer_sprite,
        self.scrollToTimerEventPatient, nil, self.cycleTimerEventPatient)
  else
    self:addPanel(timer_sprite, 0, 28):setTooltip(tooltips[count_type])
  end
  self:addPanel(1, 2, 47)
end

--! Manually set the watch position
--!param num (int) Numerator
--!param den (int) Denominator of the fraction the watch is set to
function UIWatch:setWatch(num, den)
  local new_position = num / den * TIMER_SEGMENTS
  self.panels[#self.panels].sprite_index = math.ceil(new_position)
end

function UIWatch:onCountdownEnd()
  self:close()
  if self.count_type == "emergency" then
    self.ui.hospital:resolveEmergency()
  elseif self.count_type == "epidemic" then
    local epidemic = self.hospital.epidemic
    if epidemic and not epidemic.inspector then
      epidemic:spawnInspector()
      if epidemic.vaccination_mode_active then
        epidemic:toggleVaccinationMode()
      end
    end
  elseif self.count_type == "initial_opening" then
    self.ui.hospital.opened = true
    self.ui:playSound("fanfare.wav")
  elseif self.count_type == "tutorial" then
    self.ui:tutorialStep("end")
  end
end

function UIWatch:onWorldTick()
  if self.count_type == "tutorial" then return end
  if self.tick_timer == 0 and self.open_timer >= 0 then -- Used for making a smooth animation
    self.tick_timer = self.tick_rate
    self.open_timer = self.open_timer - 1
    if self.open_timer == 11 then
      self:addPanel(2, 2, 47)
    elseif self.open_timer == 0 then
      self.panels[#self.panels].sprite_index = 0
    elseif self.open_timer < 11 and self.open_timer > 0 then
      self.panels[#self.panels].sprite_index = 13 - self.open_timer
      if self.open_timer == 5 then
        table.remove(self.panels, #self.panels - 1)
      end
    end
  elseif self.open_timer == -1 then -- the timer is at 0 when it is completely red.
    self:onCountdownEnd() -- Countdown terminated, so we open the hospital or ends the epidemic panic
  else
    self.tick_timer = self.tick_timer - 1
  end
end

--[[! Toggles vaccination mode by toggling the button then
toggling the mode in the current epidemic.]]
function UIWatch:toggleVaccinationMode()
  local epidemic = self.hospital.epidemic
  self.end_button:toggle()
  epidemic:toggleVaccinationMode()
end

--[[! During an emergency - Cycles through the patient dialogs of all the emergency patients
    ! During an epidemic - Cycles to the first patient who is infected but not vaccinated]]
function UIWatch:cycleTimerEventPatient()
  self.ui:playSound("camclick.wav")
  local hospital = self.ui.hospital

  if self.count_type == "emergency" then
    local patients = hospital.emergency_patients

    if #patients > 0 then
      if not self.current_index or self.current_index == #patients then
        self.current_index = 1
      else
        self.current_index = self.current_index + 1
      end
      self.lastCycledPatient = patients[self.current_index]
      self.ui:addWindow(UIPatient(self.ui, self.lastCycledPatient))
    end
  else
    for _, infected_patient in ipairs(hospital.epidemic.infected_patients) do
      if not infected_patient.vaccinated and not infected_patient.cured then
        self.lastCycledPatient = infected_patient
        self.ui:addWindow(UIPatient(self.ui, self.lastCycledPatient))
        break
      end
    end
  end
end

--[[! While cycling through timer event patients (@see
  UIWatch:cycleTimerEventPatient) scrolls the screen to centre on the selected patient
  If a patient dialog is open that does not belong to the timer event, does nothing]]
function UIWatch:scrollToTimerEventPatient()
  self.ui:playSound("camclick.wav")
  local patient = self.lastCycledPatient
  if patient then
    -- Current open dialog
    local current_patient_dialog = self.ui:getWindow(UIPatient)
    if not current_patient_dialog then
      -- Create the dialog but don't add it to the window
      local patient_dialog = UIPatient(self.ui, patient)
      patient_dialog:scrollToPatient()
    elseif patient == current_patient_dialog.patient then
      current_patient_dialog:scrollToPatient()
    end
  end
end
