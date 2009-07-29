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
  self.ui = ui
  self.width = 191
  self.height = 310
  self.x = 80
  self.y = 80
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req02V", true)
  self.patient = patient
  
  self:addPanel(320, 15,   0) -- Graph top
  self:addPanel(321, 15,  61) -- Graph bottom
  self:addPanel(322, 15, 126) -- Happiness / thirst / temperature sliders
  self:addPanel(323,  0, 201) -- View circle top
  self:addPanel(324,  0, 254) -- View circle bottom
end

function UIPatient:draw(canvas)
  local x, y = self.x, self.y
  local map = self.ui.app.map
  local patient = self.patient
  local px, py = map:WorldToScreen(patient.tile_x, patient.tile_y)
  local dx, dy = patient.th:getPosition()
  px = px + dx - 37
  py = py + dy - 45
  self.ui.app.map:draw(canvas, px, py, 75, 76, x + 17, y + 216)
  --Window.draw(self, canvas)
end
