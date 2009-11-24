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

class "UIQueue" (Window)

--TODO: interact with patients in the queue
--TODO: max_size doesn't do anything
--TODO: implement "expected" patients

function UIQueue:UIQueue(ui, queue)
  self:Window()
  
  local app = ui.app
  self.esc_closes = true
  self.ui = ui
  self.modal_class = "main"
  self.width = 604
  self.height = 122
  self.x = (app.config.width - self.width) / 2
  self.y = (app.config.height - self.height) / 2
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req06V", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  
  self.queue = queue
  
  self:addPanel(364,  0,  0) -- Right extremity of the panel
  for x = 21, 83, 4 do
    self:addPanel(365,  x, 0)
  end
  self:addPanel(366,  85, 0)
  for x = 223, 531, 7 do
    self:addPanel(367, x, 0)
  end
  self:addPanel(368, 529, 0)  -- Left extremity of the panel
  self:addPanel(369, 97,  self.height - 33):makeButton(0, 0, 17, 17, 370, self.decrease_max_size)
  self:addPanel(371, 144, self.height - 33):makeButton(0, 0, 17, 17, 372, self.increase_max_size)
  self:addPanel(373, self.width - 42, 17):makeButton(0, 0, 24, 24, 374, self.close) 
end

function UIQueue:decrease_max_size()
  self.queue:decrease_max_size()
end

function UIQueue:increase_max_size()
  self.queue:increase_max_size()
end

function UIQueue:draw(canvas)
  local x, y = self.x, self.y
  local font = self.white_font
  local queue = self.queue  
    
  Window.draw(self, canvas)

  local num_patients = queue:reportedSize()
  font:draw(canvas, _S(49, 1), x + 22, y + 22) -- Queue Size
  font:draw(canvas, num_patients, x + 140, y + 22)
    
  font:draw(canvas, _S(49, 2), x + 22, y + 45) -- Expected
  font:draw(canvas, queue.expected, x + 140, y + 45)
    
  font:draw(canvas, _S(49, 3), x + 22, y + 68) -- Visitor Count
  font:draw(canvas, queue.visitor_count, x + 140, y + 68)
  
  font:draw(canvas, _S(49, 4), x + 22, y + 93) -- Max Size
  font:draw(canvas, queue.max_size, x + 119, y + 93)
  
  local dx = 0
  if num_patients ~= 1 then
    local width_to_use = 276
    if num_patients < 8 then
      dx = width_to_use / num_patients
    else
      dx = width_to_use / (num_patients - 1)
    end
  end
  for index = 1, num_patients do
    local patient = queue:reportedHumanoid(index)
    local anim = TH.animation()
    local idle_anim = patient.getIdleAnimation(patient.humanoid_class)
    anim:setAnimation(self.ui.app.world.anims, idle_anim, 1) --flag 1 is for having patients in west position (looking the door in the dialog)
    for layer, id in pairs(patient.layers) do
      anim:setLayer(layer, id)
    end
    anim:draw(canvas, x + 239 + dx * (index - 1), y + 72)
  end
end
