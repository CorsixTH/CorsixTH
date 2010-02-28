--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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

--! Dialog that informs the player of for example what the goals for the level are.
class "UIInformation" (Window)

function UIInformation:UIInformation(ui, text)
  self:Window()
  
  local app = ui.app
  self.modal_class = "information"
  self.esc_closes = true
  self.on_top = true
  self.ui = ui
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "PulldV", true)
  self.black_font = app.gfx:loadFont("QData", "Font00V")
  self.text = text
  
  -- Make an estimate of the size needed. TODO: Make it more sophisticated, how?
  local rows = 1
  for i, text in ipairs(text) do
    rows = rows + string.len(text)*7 / 140
    rows = rows + 1
  end
  self.width = 40 + 300 + 40 
  self.height = 40 + rows*5 + 40 
  self:setDefaultPosition(0.5, 0.5)
  
  for x = 4, self.width - 4, 4 do
    self:addPanel(12, x, 0)  -- Dialog top and bottom borders
    self:addPanel(16, x, self.height-4)
  end
  for y = 4, self.height - 4, 4 do
    self:addPanel(18, 0, y)  -- Dialog left and right borders
    self:addPanel(14, self.width-4, y)
  end
  self:addPanel(11, 0, 0)  -- Border top left corner
  self:addPanel(17, 0, self.height-4)  -- Border bottom left corner
  self:addPanel(13, self.width-4, 0)  -- Border top right corner
  self:addPanel(15, self.width-4, self.height-4)  -- Border bottom right corner
  
  -- Close button
  self:addPanel(19, self.width - 30, self.height - 30):makeButton(0, 0, 18, 18, 20, self.close)
end

function UIInformation:draw(canvas, x, y)
 
  local dx, dy = x + self.x, y + self.y
  local white = canvas:mapRGB(255, 255, 255)
  canvas:drawRect(white, dx + 4, dy + 4, self.width - 8, self.height - 8)
  local last_y = dy + 20
  for i, text in ipairs(self.text) do
    last_y = self.black_font:drawWrapped(canvas, text, dx + 40, last_y, self.width - 80)
    last_y = self.black_font:drawWrapped(canvas, " ", dx + 40, last_y, self.width - 80)
  end
  
  Window.draw(self, canvas, x, y)
end
