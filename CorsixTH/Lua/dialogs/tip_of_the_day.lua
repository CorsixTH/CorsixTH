--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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

dofile("dialogs/resizable")

--! Tip of the Day Window
class "UITipOfTheDay" (UIResizable)

local col_bg = {
  red = math.random(20, 200),
  green = math.random(20, 200),
  blue = math.random(20, 200),
}
local col_panels = {
  red = col_bg.red - 20,
  green = col_bg.green -20,
  blue = col_bg.blue - 20,
}

function UITipOfTheDay:UITipOfTheDay(ui)
  self:UIResizable(ui, 380, 110, col_bg)
  
  local app = ui.app
  self.ui = ui
  self.resizable = false
  self:setDefaultPosition(20, -20)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  
  self.num_tips = #_S.totd_window.tips
  self.tip_num = math.random(1, self.num_tips)
  
  self:addColourPanel(10, self.height - 20, self.width / 2 - 20, 10, col_panels.red, col_panels.green, col_panels.blue):makeButton(0, 0, self.width / 2 - 20, 10, nil, self.buttonPrev)
    :setTooltip(_S.tooltip.totd_window.previous)
  self:addColourPanel(self.width / 2 + 10, self.height - 20, self.width / 2 - 20, 10, col_panels.red, col_panels.green, col_panels.blue):makeButton(0, 0, self.width / 2 - 20, 10, nil, self.buttonNext)
    :setTooltip(_S.tooltip.totd_window.next)
end

function UITipOfTheDay:draw(canvas, x, y)
  -- Draw window components
  UIResizable.draw(self, canvas, x, y)
  -- Draw labels
  x, y = self.x + x, self.y + y
  
  local text = _S.totd_window.tips[self.tip_num]

  self.white_font:drawWrapped(canvas, text, x + 10, y + 10, self.width - 20)
  
  self.white_font:draw(canvas, _S.totd_window.previous, x + 10, y + self.height - 20, self.width / 2 - 20, 10)
  self.white_font:draw(canvas, _S.totd_window.next, x + self.width / 2 + 10, y + self.height - 20, self.width / 2 - 20, 10)
end

function UITipOfTheDay:buttonPrev()
  self.tip_num = self.tip_num - 1
  if self.tip_num == 0 then
    self.tip_num = self.num_tips
  end
end

function UITipOfTheDay:buttonNext()
  self.tip_num = self.tip_num + 1
  if self.tip_num > self.num_tips then
    self.tip_num = 1
  end
end
