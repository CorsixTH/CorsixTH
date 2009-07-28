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

class "UIBottomPanel" (Window)

function UIBottomPanel:UIBottomPanel(ui)
  self:Window()
  
  local app = ui.app
  self.ui = ui
  self.x = (app.config.width - 640) / 2
  self.y = app.config.height - 48
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "Panel02V", true)
  self.money_font = app.gfx:loadFont(app.gfx:loadSpriteTable("QData", "Font05V"))
  self.date_font = app.gfx:loadFont(app.gfx:loadSpriteTable("QData", "Font16V"))
  
  self:addPanel( 1,   0, 0) -- $ button
  self:addPanel( 3,  40, 0) -- Background for balance, rep and date
  self:addPanel( 4, 206, 0):makeButton(6, 6, 35, 36, 5, self.dialogBuildRoom)
  self:addPanel( 6, 248, 0):makeButton(1, 6, 35, 36, 7, self.dialogFurnishCorridor)
  self:addPanel( 8, 285, 0) -- Edit rooms / items button
  self:addPanel(10, 322, 0) -- Hire staff button
  self:addPanel(15, 364, 0) -- Staff management button
  self:addPanel(17, 407, 0) -- Town map button
  self:addPanel(19, 445, 0) -- Drug casebook button
  self:addPanel(21, 483, 0) -- Research button
  self:addPanel(23, 521, 0) -- Status button
  self:addPanel(25, 559, 0) -- Charts button
  self:addPanel(27, 597, 0) -- Policy button
end

function UIBottomPanel:draw(canvas)
  Window.draw(self, canvas)

  local x, y = self.x, self.y
  self.money_font:draw(canvas, ("%7i"):format(40000), x + 44, y + 9)
  self.date_font:draw(canvas, "7 " .. _S(6, 2), x + 140, y + 20, 60, 0)
end

function UIBottomPanel:dialogBuildRoom()
  local dlg = UIBuildRoom(self.ui)
  self.ui:addWindow(dlg)
end

function UIBottomPanel:dialogFurnishCorridor()
  local dlg = UIFurnishCorridor(self.ui)
  self.ui:addWindow(dlg)
end
