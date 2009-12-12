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

class "UIInformation" (Window)

function UIInformation:UIInformation(ui, text, callback)
  self:Window()
  
  local app = ui.app
  self.modal_class = "information"
  self.esc_closes = true
  self.ui = ui
  self.width = 183
  self.height = 199
  self.x = (app.config.width - self.width) / 2
  self.y = (app.config.height - self.height) / 2
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req04V", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  self.text = text
  self.callback = callback  -- Callback function to launch if user choose ok
  
  self:addPanel(357, 0, 0)  -- Dialog header
  for y = 22, 136, 11 do
    self:addPanel(358, 0, y)  -- Dialog background
  end
  self:addPanel(359, 0, 136)  -- Dialog footer
  self:addPanel(360, 0, 146):makeButton(8, 10, 82, 34, 361, self.close)  -- Cancel button
  self:addPanel(362, 90, 146):makeButton(8, 10, 82, 34, 363, self.ok)  -- OK button
end

function UIInformation:ok()
  self:close()
  self.callback()
end

function UIInformation:draw(canvas)
  Window.draw(self, canvas)
  
  local x, y = self.x, self.y
  self.white_font:drawWrapped(canvas, self.text, x + 17, y + 17, 153, 0, 149)
end
