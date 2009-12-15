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

dofile "dialogs/fullscreen"

class "UIFax" (UIFullscreen)

function UIFax:UIFax(ui)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  self.background = gfx:loadRaw("Fax01V", 640, 480)
  self.panel_sprites = gfx:loadSpriteTable("QData", "Fax02V", true, gfx:loadPalette("QData", "Fax01V.pal"))
  
  self.code = ""
  
  if false then
    -- Close button
    self:addPanel(0, 598, 440):makeButton(0, 0, 26, 26, 16, self.close)
  else
    -- Blanker over close button
    self:addPanel(20, 596, 435)
  end
  
  self:addPanel(0, 471, 349):makeButton(0, 0, 87, 20, 14, self.cancel) -- Cancel code button
  self:addPanel(0, 474, 372):makeButton(0, 0, 91, 27, 15, self.validate) -- Validate code button
  
  self:addPanel(0, 168, 348):makeButton(0, 0, 43, 10, 1, self.correct) -- Correction button
  
  self:addPanel(0, 220, 348):makeButton(0, 0, 43, 10, 2,  function() self:appendNumber("1") end) -- Button 1
  self:addPanel(0, 272, 348):makeButton(0, 0, 44, 10, 3,  function() self:appendNumber("2") end) -- Button 2
  self:addPanel(0, 327, 348):makeButton(0, 0, 43, 10, 4,  function() self:appendNumber("3") end) -- Button 3
  
  self:addPanel(0, 219, 358):makeButton(0, 0, 44, 10, 5,  function() self:appendNumber("4") end) -- Button 4
  self:addPanel(0, 272, 358):makeButton(0, 0, 43, 10, 6,  function() self:appendNumber("5") end) -- Button 5
  self:addPanel(0, 326, 358):makeButton(0, 0, 44, 10, 7,  function() self:appendNumber("6") end) -- Button 6
  
  self:addPanel(0, 218, 370):makeButton(0, 0, 44, 11, 8,  function() self:appendNumber("7") end) -- Button 7
  self:addPanel(0, 271, 370):makeButton(0, 0, 44, 11, 9,  function() self:appendNumber("8") end) -- Button 8
  self:addPanel(0, 326, 370):makeButton(0, 0, 44, 11, 10, function() self:appendNumber("9") end) -- Button 9
  
  self:addPanel(0, 217, 382):makeButton(0, 0, 45, 12, 11, function() self:appendNumber("*") end) -- Button *
  self:addPanel(0, 271, 382):makeButton(0, 0, 44, 11, 12, function() self:appendNumber("0") end) -- Button 0
  self:addPanel(0, 326, 382):makeButton(0, 0, 44, 11, 13, function() self:appendNumber("#") end) -- Button #
end

function UIFax:draw(canvas)
  self.background:draw(canvas, self.x, self.y)
  return UIFullscreen.draw(self, canvas)
end

function UIFax:cancel()
  self.code = ""
end

function UIFax:correct()
  if self.code ~= "" then
    self.code = string.sub(self.code, 1, -2) --Remove last character
  end
end

function UIFax:validate()
  --TODO: Validate code
  if self.code == "24328" then
    print("Congratulations, you have unlocked cheats!")
    self.code = ""
  elseif self.code ~= "" then
    print("Code typed on fax:", self.code)
    self.code = ""
  end
end

function UIFax:appendNumber(number)
  self.code = self.code .. number
end
