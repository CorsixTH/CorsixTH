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

class "UIHireStaff" (Window)

function UIHireStaff:UIHireStaff(ui)
  self:Window()
  self.modal_class = "main"
  self.x = 100
  self.y = 100
  self.panel_sprites = ui.app.gfx:loadSpriteTable("QData", "Req11V", true)
  self.white_font = ui.app.gfx:loadFont("QData", "Font01V")
  
  -- Left hand side tab backgrounds
  self:addPanel(253, 0,   0)
  self:addPanel(254, 0,  83)
  self:addPanel(254, 0, 162)
  self:addPanel(255, 0, 241)
  
  -- Left hand side tabs
  local function category(name, state)
    self:setCategory(state and name or nil)
  end
  self.tabs = {
    self:addPanel(264, 8,   8):makeToggleButton(0, 0, 40, 69, 265, category, "Doctor"),
    self:addPanel(266, 8,  87):makeToggleButton(0, 0, 40, 69, 267, category, "Nurse"),
    self:addPanel(268, 8, 166):makeToggleButton(0, 0, 40, 69, 269, category, "Handyman"),
    self:addPanel(270, 8, 245):makeToggleButton(0, 0, 40, 69, 271, category, "Receptionist"),
  }
  
  -- Right hand side
  self:addPanel(256,  56,   0) -- Dialog header
  self:addPanel(263,  56, 263) -- Dialog midpiece
  self:addPanel(272,  56, 277):makeButton(8, 10, 43, 27, 273, self.movePrevious)
  self:addPanel(274, 106, 277):makeButton(0, 10, 58, 27, 275, self.hire)
  self:addPanel(276, 163, 277):makeButton(0, 10, 28, 27, 277, self.close)
  self:addPanel(278, 190, 277):makeButton(0, 10, 44, 27, 279, self.moveNext)
  
  do return end
  
  -- Dialog head (current track title & exit button)
  self:addPanel(389, 0, 0)
  for x = 30, self.width - 61, 24 do
    self:addPanel(390, x, 0)
  end
  self:addPanel(391, self.width - 61, 0)
  self:addPanel(409, self.width - 42, 19):makeButton(0, 0, 24, 24, 410, self.close)
  
  self.play_btn =
  self:addPanel(392,   0, 49):makeToggleButton(19, 2, 50, 24, 393)
  if self.audio.background_music then
    self.play_btn:toggle()
  end
  self:addPanel(394,  87, 49) -- Previous
  self:addPanel(396, 115, 49):makeButton(0, 2, 24, 24, 397, self.audio.playNextBackgroundTrack, self.audio)
  self:addPanel(398, 157, 49) -- Stop
  self:addPanel(400, 185, 49) -- Loop
  
  -- Track list
  for i, info in ipairs(self.audio.background_playlist) do
    local y = 47 + i * 30
    self:addPanel(402, 0, y)
    for x = 30, self.width - 61, 24 do
      self:addPanel(403, x, y)
    end
    local btn = self:addPanel(404, self.width - 61, y):makeToggleButton(19, 4, 24, 24, 405)
    if not info.enabled then
      btn:toggle()
    end
    btn.on_click = function(self, off) self:toggleTrack(i, info, not off) end
  end
  
  -- Dialog footer
  local y = 74 + 30 * #self.audio.background_playlist
  self:addPanel(406, 0, y)
  for x = 30, self.width - 61, 24 do
    self:addPanel(407, x, y)
  end
  self:addPanel(408, self.width - 61, y)
end

function UIHireStaff:setCategory(name)
  for i, btn in ipairs(self.tabs) do
    local should_be_toggled = btn.on_click_self == name
    if btn.toggled ~= should_be_toggled then
      btn:toggle()
    end
  end
end
