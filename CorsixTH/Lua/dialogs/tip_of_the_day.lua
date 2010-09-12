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

function UITipOfTheDay:UITipOfTheDay(ui)
  self:UIResizable(ui, 380, 110, col_bg)
  
  local app = ui.app
  self.ui = ui
  self.resizable = false
  self:setDefaultPosition(-20, -20)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  
  self.num_tips = #_S.totd_window.tips
  if self.num_tips == 0 then
    -- NB: #_S.totd_window.tips == 0, which implies something went wrong with
    -- the string localisation code, hence don't try to localise the following:
    print("Warning: No tips for tip-of-the-day window")
    self:close()
    return
  end
  self.tip_num = math.random(1, self.num_tips)
  
  self:addBevelPanel(10, self.height - 30, self.width / 2 - 20, 20, col_bg):setLabel(_S.totd_window.previous)
    :makeButton(0, 0, self.width / 2 - 20, 20, nil, self.buttonPrev):setTooltip(_S.tooltip.totd_window.previous)
  self:addBevelPanel(self.width / 2 + 10, self.height - 30, self.width / 2 - 20, 20, col_bg):setLabel(_S.totd_window.next)
    :makeButton(0, 0, self.width / 2 - 20, 20, nil, self.buttonNext):setTooltip(_S.tooltip.totd_window.next)
end

function UITipOfTheDay:draw(canvas, x, y)
  -- Draw window components
  UIResizable.draw(self, canvas, x, y)

  -- Draw tip
  x, y = self.x + x, self.y + y
  local text = _S.totd_window.tips[self.tip_num]
  self.white_font:drawWrapped(canvas, text, x + 10, y + 10, self.width - 20)
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
