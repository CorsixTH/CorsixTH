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

class "UIFurnishCorridor" (Window)

function UIFurnishCorridor:UIFurnishCorridor(ui)
  self:Window()
  
  local app = ui.app
  self.ui = ui
  self.anims = app.anims
  self.width = 360
  self.height = 248
  self.x = (app.config.width - self.width) / 2
  self.y = (app.config.height - self.height - 48) / 2
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req10V", true)
  self.white_font = app.gfx:loadFont(app.gfx:loadSpriteTable("QData", "Font01V"))
  self.blue_font = app.gfx:loadFont(app.gfx:loadSpriteTable("QData", "Font02V"))
  self.title_text = _S(16, 4) -- Choose Items
  
  self:addPanel(228, 0, 0) -- Grid top
  for y = 33, 103, 10 do
    self:addPanel(229, 0, y) -- Grid body
  end
  self:addPanel(230, 0, 113) -- Grid bottom
  self:addPanel(231, 0, 148) -- Cost / total top
  self:addPanel(232, 0, 173) -- Cost / total body
  self:addPanel(233, 0, 215) -- Cost / total bottom
  self:addPanel(234, 0, 248) -- Close button background
  self:addPanel(234, 0, 252) -- Close button background extension
  self:addPanel(242, 9, 237):makeButton(0, 0, 129, 28, 243, self.close)
  
  self:addPanel(235, 146, 0) -- List top
  for y = 34, 205, 19 do
    self:addPanel(239, 146, y) -- List body
  end
  self:addPanel(236, 146, 223) -- List bottom
end
