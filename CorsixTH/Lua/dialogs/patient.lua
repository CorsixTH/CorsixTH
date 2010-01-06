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

class "UIPatient" (Window)

function UIPatient:UIPatient(ui, patient)
  self:Window()
  
  local app = ui.app
  self.esc_closes = true
  self.ui = ui
  self.modal_class = "humanoid_info"
  self.width = 191
  self.height = 310
  self.x = app.config.width - self.width - 20
  self.y = 30
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req02V", true)
  self.font = app.gfx:loadFont("QData", "Font74V") -- Font used in the treatment history
  self.patient = patient
  self.visible_diamond = ui.makeVisibleDiamond(75, 76)
  
  self:addPanel(320,  15,   0) -- Graph top
  self:addPanel(321,  15,  61) -- Graph bottom

  self.history_panel = self:addColourPanel(36, 22, 99, 88, 223, 223, 223) -- Treatment history background
  self.history_panel:makeButton(0, 0, 99, 88, nil, function()
    self.history_panel.visible = not self.history_panel.visible
  end) -- Treatment history toggle
  self.history_panel.visible = false -- Hide the treatment history at start

  self:addPanel(322,  15, 126) -- Happiness / thirst / temperature sliders
  self:addPanel(323,   0, 201) -- View circle top
  self:addPanel(324,   0, 254) -- View circle bottom
  self:addPanel(325, 147,  21):makeButton(0, 0, 24, 24, 326, self.close)
  
  -- If the patient has been diagnosed the "guess cure" button is not visible and
  -- if the patient is going home it is not possible to kick him/her anymore.
  self:addPanel(411, 14 + 132, 61 + 19):makeButton(0, 0, 25, 31, 412, self.viewQueue)

  -- Show the drug casebook only after the disease has been diagnosed.
  if patient.diagnosed then
    self:addPanel(329, 14 + 117, 61 + 107):makeButton(0, 0, 38, 38, 330, self.viewDiseases)
  else
    self:addColourPanel(14 + 115, 61 + 105, 45, 45, 113, 117, 170)
  end
  if patient.going_home then
    self:addColourPanel(14 + 93, 61 + 156, 67, 67, 113, 117, 170)
  else
    self:addPanel(331, 14 + 95, 61 + 158):makeButton(0, 0, 60, 60, 332, self.goHome)
  end
  if patient.diagnosed or patient.going_home then
    self:addColourPanel(14 + 115, 61 + 56, 45, 45, 113, 117, 170)
  else
    self:addPanel(413, 14 + 117, 61 + 58):makeButton(0, 0, 38, 38, 414, self.guessDisease)
  end

  -- 104 = H. Always add this because of a race condition if the user clicks a patient
  -- that's already going home, then clicks another, the handler is left empty. Bad.
  -- Just do a going_home check when called.
  ui:addKeyHandler(104, self, self.goHome)		  
end

function UIPatient:close()
  self.ui:removeKeyHandler(104, self)
  self.parent:removeWindow(self)
end

function UIPatient:draw(canvas)
  local x, y = self.x, self.y
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
  Window.draw(self, canvas)
  
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
  if patient.attributes["warmth"] then
    warmth_bar_width = math_floor(patient.attributes["warmth"] * 40 + 0.5)
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

function UIPatient:onMouseUp(button, x, y)
  local repaint = Window.onMouseUp(self, button, x, y)
  -- Test for hit within the view circle
  if button == "left" and (x - 55)^2 + (y - 254)^2 < 38^2 then
    local ui = self.ui
    local patient = self.patient
    local px, py = ui.app.map:WorldToScreen(patient.tile_x, patient.tile_y)
    local dx, dy = patient.th:getPosition()
    ui:scrollMapTo(px + dx, py + dy)
    repaint = true
  elseif button == "right" then
    --TODO: Right clicking on patient view should go to the next patient
  end  return repaint
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
end

function UIPatient:viewDiseases()
  local dlg = UICasebook(self.ui, self.patient.diagnosed and self.patient.disease.id or nil)
  self.ui:addWindow(dlg)
end

function UIPatient:guessDisease()
  -- TODO
end
