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
  self.patient = patient
  self.visible_diamond = ui.makeVisibleDiamond(75, 76)
  
  self:addPanel(320,  15,   0) -- Graph top
  self:addPanel(321,  15,  61) -- Graph bottom
  self:addPanel(322,  15, 126) -- Happiness / thirst / temperature sliders
  self:addPanel(323,   0, 201) -- View circle top
  self:addPanel(324,   0, 254) -- View circle bottom
  self:addPanel(325, 147,  21):makeButton(0, 0, 24, 24, 326, self.close)
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
  local dx, dy = patient.th:getPosition()
  px = px + dx - 37
  py = py + dy - 45
  -- If the patient is spawning or despawning, or just on the map edge, then
  -- the rendering point needs adjustment to keep the rendered region entirely
  -- within the map (this situation doesn't occur very often, but we need to
  -- handle it properly when it does occur).
  px, py = self.ui.limitPointToDiamond(px, py, self.visible_diamond, true)
  self.ui.app.map:draw(canvas, px, py, 75, 76, x + 17, y + 216)
  Window.draw(self, canvas)
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
