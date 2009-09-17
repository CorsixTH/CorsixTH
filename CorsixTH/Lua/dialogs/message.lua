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

class "UIMessage" (Window)

function UIMessage:UIMessage(ui, x, stop_x, onClose, type)
  self:Window()
  
  local app = ui.app
  
  self.esc_closes = false
  self.on_top = false
  self.onClose = onClose
  self.timer = 25 * 24 -- Time to wait before considering to choose an automatic response
  self.ui = ui
  self.width = 30
  self.height = 28
  self.stop_x = stop_x
  self.stop_y = app.config.height - 72
  self.x = x
  self.y = app.config.height - 44
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "Panel02V", true)
  
  local types = { emergency = 43, epidemy = 45, strike = 47, personnality = 49, information = 51, disease = 53, report = 55 }
  local type = types[type]
  
  self:addPanel(type, 0, 0):makeButton(0, 0, 30, 28, type + 1, self.openMessage)
end

function UIMessage:draw(canvas)
  Window.draw(self, canvas)
end

function UIMessage:openMessage(out_of_time)
  self:close()
  self:onClose(out_of_time or false)
  --TODO
end

function UIMessage:moveLeft()
  self.stop_x = self.stop_x - self.width
end

function UIMessage:onTick()
  if self.on_top == false and self.y == self.stop_y then
    self.ui:sendToTop(self)
    self.on_top = true
  end
  
  if self.y > self.stop_y then
    local y = self.y - 8
    if y > self.stop_y then
      self.y = y
    else
      self.y = self.stop_y
    end
  elseif self.x > self.stop_x then
    local x = self.x - 3
    if x > self.stop_x then
      self.x = x
    else
      self.x = self.stop_x
    end
  end
end

function UIMessage:onWorldTick()
  if self.timer > 0 then
    self.timer = self.timer - 1
  else
    self:openMessage(true)
  end
end
