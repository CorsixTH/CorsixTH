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
  self.esc_closes = true
  self.world = ui.app.world
  self.ui = ui
  self.width = 242
  self.height = 323
  self:setDefaultPosition(100, 100)
  self.panel_sprites = ui.app.gfx:loadSpriteTable("QData", "Req11V", true)
  self.white_font = ui.app.gfx:loadFont("QData", "Font01V")
  self.face_parts = ui.app.gfx:loadRaw("Face01V", 65, 1350, nil, "Data", "MPalette.dat")
  self:addKeyHandler("Enter", self.hire)
  
  -- Left hand side tab backgrounds
  self:addPanel(253, 0,   0)
  self:addPanel(254, 0,  83)
  self:addPanel(254, 0, 162)
  self:addPanel(255, 0, 241)
  
  -- Left hand side tabs
  local --[[persistable:hire_staff_category]] function category(name, state, btn)
    if #self.world.available_staff[name] == 0 then
      self.ui:playSound "wrong2.wav"
      if state then
        btn:toggle()
      end
    else
      self.ui:playSound "selectx.wav"
      self:setCategory(state and name or nil)
    end
  end
  self.tabs = {
    self:addPanel(264, 8,   8):makeToggleButton(0, 0, 40, 69, 265, category, "Doctor"):setTooltip(_S.tooltip.hire_staff_window.doctors),
    self:addPanel(266, 8,  87):makeToggleButton(0, 0, 40, 69, 267, category, "Nurse"):setTooltip(_S.tooltip.hire_staff_window.nurses),
    self:addPanel(268, 8, 166):makeToggleButton(0, 0, 40, 69, 269, category, "Handyman"):setTooltip(_S.tooltip.hire_staff_window.handymen),
    self:addPanel(270, 8, 245):makeToggleButton(0, 0, 40, 69, 271, category, "Receptionist"):setTooltip(_S.tooltip.hire_staff_window.receptionists),
  }
  
  -- Right hand side
  self:addPanel(256,  56,   0) -- Dialog header
  for y = 49, 113, 11 do
    self:addPanel(257,56,   y) -- Dialog background
  end
  self.ability_bg_panel = 
  self:addPanel(260,  55, 114) -- Abilities background
  self.skill_bg_panel = 
  self:addPanel(259,  68,  95):setTooltip(_S.tooltip.hire_staff_window.staff_ability, 109, 95) -- Skill background
  self.skill_bg_panel.visible = false
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
  self:addPanel(272,  56, 277):makeButton(8, 10, 43, 27, 273, self.movePrevious):setTooltip(_S.tooltip.hire_staff_window.prev_person)
  self:addPanel(274, 106, 277):makeButton(0, 10, 58, 27, 275, self.hire):setTooltip(_S.tooltip.hire_staff_window.hire)
  self:addPanel(276, 163, 277):makeButton(0, 10, 28, 27, 277, self.close):setTooltip(_S.tooltip.hire_staff_window.cancel)
  self:addPanel(278, 190, 277):makeButton(0, 10, 44, 27, 279, self.moveNext):setTooltip(_S.tooltip.hire_staff_window.next_person)
  
  self:makeTooltip(_S.tooltip.hire_staff_window.salary, 68, 173, 227, 194)
  self:makeTooltip(_S.tooltip.hire_staff_window.doctor_seniority, 68, 44, 151, 95)
  self:makeTooltip(_S.tooltip.hire_staff_window.qualifications, 68, 134, 107, 167)

  self:makeTooltip(_S.tooltip.hire_staff_window.surgeon, 120, 136, 137, 167)
  self:makeTooltip(_S.tooltip.hire_staff_window.psychiatrist, 137, 136, 164, 167)
  self:makeTooltip(_S.tooltip.hire_staff_window.researcher, 164, 136, 191, 167)
  
  self:updateTooltips()
end

function UIHireStaff:updateTooltips()
  local cond = not not self.category
  self.tooltip_regions[1].enabled = cond
  
  cond = cond and self.category == "Doctor"
  self.tooltip_regions[2].enabled = cond
  self.tooltip_regions[3].enabled = cond
  cond = cond and self.current_index and self.world.available_staff[self.category]
  cond = cond and cond[self.current_index]
  self.tooltip_regions[4].enabled = cond and cond.is_surgeon >= 1.0
  self.tooltip_regions[5].enabled = cond and cond.is_psychiatrist >= 1.0
  self.tooltip_regions[6].enabled = cond and cond.is_researcher >= 1.0
end

function UIHireStaff:onMouseUp(button, x, y)
  self.mouse_up_x = self.x + x
  self.mouse_up_y = self.y + y
  return Window.onMouseUp(self, button, x, y)
end

function UIHireStaff:hire()
  self.ui:tutorialStep(2, {3, 4, 5}, 6)
  self.ui:tutorialStep(4, 3, 4)
  local profile
  if self.category and self.current_index then
    profile = self.world.available_staff[self.category]
    profile = profile and profile[self.current_index]
  end
  if not profile or self.ui.hospital.balance < profile.wage then
    self.ui:playSound "wrong2.wav"
    return
  end
  self.ui:playSound "YesX.wav"
  table.remove(self.world.available_staff[self.category], self.current_index)
  self.ui:addWindow(UIPlaceStaff(self.ui, profile, self.mouse_up_x, self.mouse_up_y))
end

function UIHireStaff:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y
  
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
    -- Skill bar
    if self.skill_bg_panel.visible then
      local skill_bar_width = math.floor(profile.skill * 40 + 0.5)
      if skill_bar_width ~= 0 then
        local px, py = self.skill_bg_panel.x, self.skill_bg_panel.y
        px = px + x
        py = py + y
        for x = 0, skill_bar_width - 1 do
          self.panel_sprites:draw(canvas, 3, px + 22 + x, py + 9)
        end
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
      if profile.is_surgeon >= 1.0 then
        self.panel_sprites:draw(canvas, 292, px +  65, py + 22)
      end
      if profile.is_psychiatrist >= 1.0 then
        self.panel_sprites:draw(canvas, 293, px +  82, py + 28)
      end
      if profile.is_researcher >= 1.0 then
        self.panel_sprites:draw(canvas, 294, px + 109, py + 27)
      end
    end
  end
end

function UIHireStaff:movePrevious()
  self:moveBy(-1)
  self.ui:tutorialStep(2, 4, 5)
end

function UIHireStaff:moveNext()
  self.ui:tutorialStep(2, 3, 4)
  self:moveBy(1)
end

function UIHireStaff:moveBy(n)
  if self.category then
    self.current_index = self.current_index + n
    local category = self.world.available_staff[self.category]
    if self.current_index < 1 then
      self.current_index = 1
    elseif self.current_index > #category then
      self.current_index = #category
    else
      self.ui:playSound "selectx.wav"
      self:updateTooltips()
      return true
    end
  end
  self.ui:playSound "wrong2.wav"
  return false
end

function UIHireStaff:setCategory(name)
  if name == "Receptionist" then
    self.ui:tutorialStep(2, 2, 3)
  else
    self.ui:tutorialStep(2, {3, 4, 5}, 2)
  end
  if name == "Doctor" then
    self.ui:tutorialStep(4, 2, 3)
  else
    self.ui:tutorialStep(4, 3, 2)
  end
  self.skill_bg_panel.visible = not not name
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
  self:updateTooltips()
end

function UIHireStaff:close()
  self.ui:tutorialStep(2, {2, 3, 4, 5}, 1)
  self.ui:tutorialStep(4, {2, 3}, 1)
  return Window.close(self)
end
