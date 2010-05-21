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

--! Dialog for "Are you sure you want to quit?" and similar yes/no questions.
class "UIConfirmDialog" (Window)

function UIConfirmDialog:UIConfirmDialog(ui, text, callback)
  self:Window()
  
  local app = ui.app
  self.modal_class = "information"
  self.esc_closes = true
  self.on_top = true
  self.ui = ui
  self.width = 183
  self.height = 199
  self:setDefaultPosition(0.5, 0.5)
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req04V", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  self.text = text
  self.callback = callback  -- Callback function to launch if user choose ok
  
  self:addPanel(357, 0, 0)  -- Dialog header
  for y = 22, 136, 11 do
    self:addPanel(358, 0, y)  -- Dialog background
  end
  self:addPanel(359, 0, 136)  -- Dialog footer
  self:addPanel(360, 0, 146):makeButton(8, 10, 82, 34, 361, self.close):setTooltip(_S.tooltip.window_general.cancel):setSound"No4.wav"
  self:addPanel(362, 90, 146):makeButton(0, 10, 82, 34, 363, self.ok):setTooltip(_S.tooltip.window_general.confirm):setSound"YesX.wav"
  
  self:addKeyHandler("Enter", self.ok)
end

function UIConfirmDialog:ok()
  self:close()
  self.callback()
end

function UIConfirmDialog:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  
  x, y = x + self.x, y + self.y
  self.white_font:drawWrapped(canvas, self.text, x + 17, y + 17, 153)
end
