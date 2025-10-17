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

--! Tip of the Day Window
class "UITipOfTheDay" (UIResizable)

---@type UITipOfTheDay
local UITipOfTheDay = _G["UITipOfTheDay"]

local col_bg = {
  red = math.random(20, 200),
  green = math.random(20, 200),
  blue = math.random(20, 200),
}

function UITipOfTheDay:UITipOfTheDay(ui)
  local app = ui.app
  -- If the application window is not wide enough,
  --  the tips window is narrower and taller to fit beside the main menu
  local width = math.min(380, math.floor(app.config.width / 2) - 150)
  local height = width > 290 and 110 or 210
  self:UIResizable(ui, width, height, col_bg)

  self.ui = ui
  self.resizable = false
  self:setDefaultPosition(-20, -20)
  self.white_font = app.gfx:loadFontAndSpriteTable("QData", "Font01V")

  self.num_tips = #_S.totd_window.tips
  if self.num_tips == 0 then
    -- NB: #_S.totd_window.tips == 0, which implies something went wrong with
    -- the string localisation code, hence don't try to localise the following:
    print("Warning: No tips for tip-of-the-day window")
    self:close()
    return
  end
  self.tip_num = math.random(1, self.num_tips)

  -- Previous button's y, next button's x, button width
  local function add_nav_buttons(y1, x2, btn_width)
    self:addBevelPanel(10, y1, btn_width, 20, col_bg):setLabel(_S.totd_window.previous)
      :makeButton(0, 0, btn_width, 20, nil, self.buttonPrev):setTooltip(_S.tooltip.totd_window.previous)
    self:addBevelPanel(x2, height - 30, btn_width, 20, col_bg):setLabel(_S.totd_window.next)
      :makeButton(0, 0, btn_width, 20, nil, self.buttonNext):setTooltip(_S.tooltip.totd_window.next)
  end
  if width > 290 then -- The buttons are side by side
    add_nav_buttons(height - 30, math.floor(width / 2) + 10, math.floor(width / 2) - 20)
  else -- The buttons are stacked
    add_nav_buttons(height - 55, 10, width - 20)
  end
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

--! Called after the resolution of the game window changes
function UITipOfTheDay:onChangeResolution()
  self:close()
  self.ui:addWindow(UITipOfTheDay(self.ui))
  Window.onChangeResolution(self)
end
