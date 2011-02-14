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

local TH = require "TH"
local math_floor
    = math.floor

-- Test for hit within the view circle
local --[[persistable:patient_window_is_in_view_circle]] function is_in_view_circle(x, y)
  return (x - 55)^2 + (y - 254)^2 < 39^2
end

--! Individual patient information dialog
class "UIPatient" (Window)

function UIPatient:UIPatient(ui, patient)
  self:Window()
  
  local app = ui.app
  self.esc_closes = true
  self.ui = ui
  self.modal_class = "humanoid_info"
  self.width = 191
  self.height = 310
  self:setDefaultPosition(-20, 30)
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req02V", true)
  self.font = app.gfx:loadFont("QData", "Font74V") -- Font used in the treatment history
  self.patient = patient
  self.visible_diamond = ui:makeVisibleDiamond(75, 76)
  
  self:addPanel(320,  15,   0) -- Graph top
  self:addPanel(321,  15,  61) -- Graph bottom

  self.history_panel = self:addColourPanel(36, 22, 99, 88, 223, 223, 223) -- Treatment history background
  self.history_panel:makeButton(0, 0, 99, 88, nil, --[[persistable:patient_toggle_history]] function()
    self.history_panel.visible = not self.history_panel.visible
  end):setTooltip(_S.tooltip.patient_window.graph) -- Treatment history toggle
  self.history_panel.visible = false -- Hide the treatment history at start

  self:addPanel(322,  15, 126) -- Happiness / thirst / temperature sliders
  self:addPanel(323,   0, 201) -- View circle top
  self:addPanel(324,   0, 254) -- View circle bottom
  self:addPanel(325, 147,  21):makeButton(0, 0, 24, 24, 326, self.close):setTooltip(_S.tooltip.patient_window.close)
  
  -- If the patient has been diagnosed the "guess cure" button is not visible and
  -- if the patient is going home it is not possible to kick him/her anymore.
  self:addPanel(411, 14 + 132, 61 + 19):makeButton(0, 0, 25, 31, 412, self.viewQueue):setTooltip(_S.tooltip.patient_window.queue)

  -- Initialize all buttons and blankers, then call the update function which decides what to show.
  -- Show the drug casebook only after the disease has been diagnosed.
  self.disease_button = self:addPanel(329, 14 + 117, 61 + 107)
    :makeButton(0, 0, 38, 38, 330, self.viewDiseases):setTooltip(_S.tooltip.patient_window.casebook)
  self.disease_blanker = self:addColourPanel(14 + 115, 61 + 105, 45, 45, 113, 117, 170)

  self.home_button = self:addPanel(331, 14 + 95, 61 + 158):makeButton(0, 0, 60, 60, 332, self.goHome):setTooltip(_S.tooltip.patient_window.send_home)
  self.home_blanker = self:addColourPanel(14 + 93, 61 + 156, 67, 67, 113, 117, 170)

  self.guess_button = self:addPanel(413, 14 + 117, 61 + 58):makeButton(0, 0, 38, 38, 414, self.guessDisease):setTooltip(_S.tooltip.patient_window.abort_diagnosis)
  self.guess_blanker = self:addColourPanel(14 + 115, 61 + 56, 45, 45, 113, 117, 170)
  
  -- Set correct initial visibility/enabledness of the three buttons and their blankers
  self:updateInformation()
  
  self:makeTooltip(_S.tooltip.patient_window.happiness, 33, 117, 124, 141)
  self:makeTooltip(_S.tooltip.patient_window.thirst,    33, 141, 124, 169)
  self:makeTooltip(_S.tooltip.patient_window.warmth,    33, 169, 124, 203)
  
  -- Non-rectangular tooltip has to be realized with dynamic tooltip at the moment
  self:makeDynamicTooltip(--[[persistable:patient_window_center_tooltip]]function(x, y)
    if is_in_view_circle(x, y) then
      return _S.tooltip.patient_window.center_view
    end
  end, 17, 216, 92, 292)
  
  -- Always add this because of a race condition if the user clicks a patient
  -- that's already going home, then clicks another, the handler is left empty. Bad.
  -- Just do a going_home check when called.
  self:addKeyHandler("H", self.goHome)
end

function UIPatient.normaliseWarmth(warmth)
  if warmth < 0.08 then
    warmth = 0
  elseif warmth > 0.50 then
    warmth = 1
  else
    warmth = (warmth - 0.08) / (0.50 - 0.08)
  end
  return warmth
end

function UIPatient:draw(canvas, x_, y_)
  local x, y = self.x + x_, self.y + y_
  local map = self.ui.app.map
  local patient = self.patient
  -- If the patient has just despawned, then it will have no tile, hence
  -- making it impossible to render said patient. In this case, the dialog
  -- should close. Note that it is slightly better to close the dialog during
  -- the draw callback rather than the tick callback, as doing so in the tick
  -- callback would be removing from the window list while said list is being
  -- iterated, causing the next window in the list to miss it's tick (rendering
  -- is done via a reverse traversal, which does not suffer this problem).
  if not patient.tile_x then
    self:close()
    return
  end
  local px, py = map:WorldToScreen(patient.tile_x, patient.tile_y)
  local dx, dy = patient.th:getMarker()
  px = px + dx - 37
  py = py + dy - 61
  -- If the patient is spawning or despawning, or just on the map edge, then
  -- the rendering point needs adjustment to keep the rendered region entirely
  -- within the map (this situation doesn't occur very often, but we need to
  -- handle it properly when it does occur).
  px, py = self.ui.limitPointToDiamond(px, py, self.visible_diamond, true)
  self.ui.app.map:draw(canvas, px, py, 75, 76, x + 17, y + 216)
  Window.draw(self, canvas, x_, y_)
  
  -- The patients happiness. Each bar is by default half way if the actual value 
  -- cannot be found.
  local happiness_bar_width = 22
  if patient.attributes["happiness"] then
    happiness_bar_width = math_floor(patient.attributes["happiness"] * 40 + 0.5)
  end
  if happiness_bar_width ~= 0 then
    for dx = 0, happiness_bar_width - 1 do
      self.panel_sprites:draw(canvas, 348, x + 58 + dx, y + 126)
    end
  end
  -- The patients thirst level
  local thirst_bar_width = 22
  if patient.attributes["thirst"] then
    thirst_bar_width = math_floor((1 - patient.attributes["thirst"]) * 40 + 0.5)
  end
  if thirst_bar_width ~= 0 then
    for dx = 0, thirst_bar_width - 1 do
      self.panel_sprites:draw(canvas, 351, x + 58 + dx, y + 154)
    end
  end
  -- How warm the patient feels
  local warmth_bar_width = 22
  local warmth = patient.attributes["warmth"]
  if warmth then
    warmth = self.normaliseWarmth(warmth)
    warmth_bar_width = math_floor(warmth * 40 + 0.5)
  end
  if warmth_bar_width ~= 0 then
    for dx = 0, warmth_bar_width - 1 do
      self.panel_sprites:draw(canvas, 349, x + 58 + dx, y + 183)
    end
  end

  if self.history_panel.visible then
    self:drawTreatmentHistory(canvas, x + 40, y + 25)
  end
end

function UIPatient:drawTreatmentHistory(canvas, x, y)
  for _, room in ipairs(self.patient.treatment_history) do
    y = self.font:drawWrapped(canvas, room, x, y, 95)
  end
end

function UIPatient:onMouseDown(button, x, y)
  self.do_scroll = button == "left" and is_in_view_circle(x, y)
  return Window.onMouseDown(self, button, x, y)
end

function UIPatient:onMouseUp(button, x, y)
  local ui = self.ui
  if button == "left" then
    self.do_scroll = false
  end
  local repaint = Window.onMouseUp(self, button, x, y)
  if button == "right" and is_in_view_circle(x, y) then
    -- Right click goes to the next patient
    local patient_index = nil
    for i, patient in ipairs(ui.hospital.patients) do
      if patient == self.patient then
        patient_index = i
        break
      end
    end
    patient_index = (patient_index or 0) + 1
    local patient = ui.hospital.patients[patient_index] or ui.hospital.patients[1]
    if patient then
      ui:addWindow(UIPatient(ui, patient))
      return false
    end
  end
  return repaint
end

function UIPatient:onMouseMove(x, y, dx, dy)
  self.do_scroll = self.do_scroll and is_in_view_circle(x, y)
  return Window.onMouseMove(self, x, y, dx, dy)
end

function UIPatient:onTick()
  if self.do_scroll then
    local ui = self.ui
    local patient = self.patient
    local px, py = ui.app.map:WorldToScreen(patient.tile_x, patient.tile_y)
    local dx, dy = patient.th:getPosition()
    ui:scrollMapTo(px + dx, py + dy)
  end
  return Window.onTick(self)
end

function UIPatient:updateInformation()
  local patient = self.patient
  if patient.diagnosed then
    self.disease_button.enabled = true
    self.disease_button.visible = true
    self.disease_blanker.visible = false
  else
    self.disease_button.enabled = false
    self.disease_button.visible = false
    self.disease_blanker.visible = true
  end
  if patient.going_home then
    self.home_button.enabled = false
    self.home_button.visible = false
    self.home_blanker.visible = true
  else
    self.home_button.enabled = true
    self.home_button.visible = true
    self.home_blanker.visible = false
  end
  if patient.is_debug or patient.diagnosis_progress == 0 or patient.diagnosed or patient.going_home then
    self.guess_button.enabled = false
    self.guess_button.visible = false
    self.guess_blanker.visible = true
  else
    self.guess_button.enabled = true
    self.guess_button.visible = true
    self.guess_blanker.visible = false
  end
end

function UIPatient:viewQueue()
  for i, action in ipairs(self.patient.action_queue) do
    if action.name == "queue" then
      self.ui:addWindow(UIQueue(self.ui, action.queue))
      self.ui:playSound "selectx.wav"
      return
    end
  end
  self.ui:playSound "wrong2.wav"
end

function UIPatient:goHome()
  if self.going_home then
    return
  end
  self:close()
  self.patient:playSound "sack.wav"
  self.patient:goHome()
  self.patient:updateDynamicInfo(_S.dynamic_info.patient.actions.sent_home)
end

function UIPatient:viewDiseases()
  local dlg = UICasebook(self.ui, self.patient.diagnosed and self.patient.disease.id or nil)
  self.ui:addWindow(dlg)
end

function UIPatient:guessDisease()
  local patient = self.patient
  -- NB: the first line of conditions should already be ruled out by button being disabled, but just in case
  if patient.is_debug or patient.diagnosis_progress == 0 or patient.diagnosed or patient.going_home
  or patient:getRoom() or not patient.hospital.disease_casebook[patient.disease.id].discovered then
    self.ui:playSound("wrong2.wav")
    return
  end
  patient:setDiagnosed(true)
  patient:setNextAction({
    name = "seek_room", 
    room_type = patient.disease.treatment_rooms[1],
    treatment_room = true,
  }, 1)
end

function UIPatient:hitTest(x, y)
  return Window.hitTest(self, x, y) or is_in_view_circle(x, y)
end
