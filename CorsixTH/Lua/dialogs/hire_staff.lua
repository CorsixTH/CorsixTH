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
  self.world = ui.app.world
  self.x = 100
  self.y = 100
  self.panel_sprites = ui.app.gfx:loadSpriteTable("QData", "Req11V", true)
  self.white_font = ui.app.gfx:loadFont("QData", "Font01V")
  self.face_parts = ui.app.gfx:loadRaw("Face01V", 65, 1350, "Data", "MPalette.dat")
  
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
  for y = 49, 113, 11 do
    self:addPanel(257,56,   y) -- Dialog background
  end
  self.ability_bg_panel = 
  self:addPanel(260,  55, 114) -- Abilities background
  self.skill_bg_panel = 
  self:addPanel(259,  68,  95) -- Skill background
  self:addPanel(261,  55, 160) -- Wage background
  self.abilities_blanker =
  self:addColourPanel(73, 133, 156, 34, 60, 174, 203) -- Hides abilities list
  for y = 207, 262, 3 do
    self:addPanel(262, 54,  y) -- Description background
  end
  self:addColourPanel(155, 45, 72, 81, 211, 255, 255) -- Portrait background
  self:addPanel(263,  56, 263) -- Dialog midpiece
  self.complete_blanker =
  self:addColourPanel(68, 15, 161, 257, 60, 174, 203) -- Hides all staff info
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

function UIHireStaff:draw(canvas)
  local x, y = self.x, self.y
  Window.draw(self, canvas)
  local font = self.white_font
  local staff = self.world.available_staff
  font:draw(canvas, #staff.Doctor      , x + 16, y +  58, 26, 0)
  font:draw(canvas, #staff.Nurse       , x + 16, y + 137, 26, 0)
  font:draw(canvas, #staff.Handyman    , x + 16, y + 216, 26, 0)
  font:draw(canvas, #staff.Receptionist, x + 16, y + 295, 26, 0)
  if self.category and self.current_index then
    local profile = staff[self.category]
    profile = profile and profile[self.current_index]
    if not profile then
      return
    end
    font:draw(canvas, profile.name, x + 79, y + 21)
    profile:drawFace(canvas, x + 158, y + 48, self.face_parts)
    font:draw(canvas, "$" .. profile.wage, x + 116, y + 179)
    font:drawWrapped(canvas, profile.desc, x + 74, y + 205, 149)
    local skill_bar_width = math.floor(profile.skill * 40 + 0.5)
    if skill_bar_width ~= 0 then
      local px, py = self.skill_bg_panel.x, self.skill_bg_panel.y
      px = px + x
      py = py + y
      for x = 0, skill_bar_width - 1 do
        self.panel_sprites:draw(canvas, 3, px + 22 + x, py + 9)
      end
    end
    if self.category == "Doctor" then
      -- Junior / Doctor / Consultant marker
      self.panel_sprites:draw(canvas, 258, x + 71, y + 49)
      if profile.is_junior then
        self.panel_sprites:draw(canvas, 296, x +  79, y + 80)
      elseif profile.is_consultant then
        self.panel_sprites:draw(canvas, 296, x + 131, y + 80)
      else
        self.panel_sprites:draw(canvas, 296, x + 101, y + 80)
      end
      -- Ability markers
      local px, py = self.ability_bg_panel.x, self.ability_bg_panel.y
      px = px + x
      py = py + y
      if profile.is_surgeon then
        self.panel_sprites:draw(canvas, 292, px +  65, py + 22)
      end
      if profile.is_psychiatrist then
        self.panel_sprites:draw(canvas, 293, px +  82, py + 28)
      end
      if profile.is_researcher then
        self.panel_sprites:draw(canvas, 294, px + 109, py + 27)
      end
    end
  end
end

function UIHireStaff:movePrevious()
  self:moveBy(-1)
end

function UIHireStaff:moveNext()
  self:moveBy(1)
end

function UIHireStaff:moveBy(n)
  self.current_index = self.current_index + n
  local category = self.world.available_staff[self.category]
  if self.current_index < 1 then
    self.current_index = 1
  elseif self.current_index > #category then
    self.current_index = #category
  else
    return true
  end
  return false
end

function UIHireStaff:setCategory(name)
  self.complete_blanker.visible = not name
  self.abilities_blanker.visible = name ~= "Doctor"
  self.category = name
  for i, btn in ipairs(self.tabs) do
    local should_be_toggled = btn.on_click_self == name
    if btn.toggled ~= should_be_toggled then
      btn:toggle()
    end
  end
  self.current_index = 1
end
