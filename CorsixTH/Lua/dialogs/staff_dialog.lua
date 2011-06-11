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

-- Test for hit within the view circle
local --[[persistable:staff_dialog_is_in_view_circle]] function is_in_view_circle(x, y, is_handyman)
  local circle_center_y = is_handyman and 276 or 248
  return (x - 55)^2 + (y - circle_center_y)^2 < 39^2
end

--! Individual staff information dialog
class "UIStaff" (Window)

function UIStaff:UIStaff(ui, staff)
  self:Window()
  
  local app = ui.app
  local profile = staff.profile
  self.esc_closes = true
  self.staff = staff
  self.ui = ui
  self.modal_class = "humanoid_info"
  self.width = 220
  if profile.humanoid_class == "Handyman" then
    self.height = 332
  else
    self.height = 304
  end
  self:setDefaultPosition(-20, 30)
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req01V", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  self.face_parts = app.gfx:loadRaw("Face01V", 65, 1350, nil, "Data", "MPalette.dat")
  
  self:addPanel(297,   15,   0) -- Dialog header
  for y = 51, 121, 10 do
    self:addPanel(298, 15,   y) -- Dialog background
  end
  self:addPanel(299,  104,  50) -- Happiness
  self:addPanel(300,  105,  82) -- Tiredness
  self:addPanel(301,   15, 114) -- Skills/Abilities
  self:addColourPanel(35, 51, 71, 81, 208, 252, 252):makeButton(0, 0, 71, 81, nil, self.openStaffManagement):setTooltip(_S.tooltip.staff_window.face) -- Portrait background
  
  if profile.humanoid_class == "Handyman" then
    self:addPanel(311,  15, 131) -- Tasks top
    for y = 149, 184, 5 do
      self:addPanel(312, 15,  y) -- Tasks buttons
    end
    self:addPanel(302,   5, 205) -- View circle top/Wage
    self:addPanel(313,  15, 189) -- Tasks bottom
    self:addPanel(314,  37, 145):makeButton(0, 0, 49, 48, 315, self.doMoreCleaning):setTooltip(_S.tooltip.handyman_window.prio_litter)
    self:addPanel(316,  92, 145):makeButton(0, 0, 49, 48, 317, self.doMoreWatering):setTooltip(_S.tooltip.handyman_window.prio_plants)
    self:addPanel(318, 148, 145):makeButton(0, 0, 49, 48, 319, self.doMoreRepairing):setTooltip(_S.tooltip.handyman_window.prio_machines)
    self:addPanel(303,   0, 253) -- View circle midpiece
    self:addPanel(304,   6, 302) -- View circle bottom
    self:addPanel(307, 106, 253):makeButton(0, 0, 50, 50, 308, self.fireStaff):setTooltip(_S.tooltip.staff_window.sack)
    self:addPanel(309, 164, 253):makeButton(0, 0, 37, 50, 310, self.placeStaff):setTooltip(_S.tooltip.staff_window.pick_up)
  else
    self:addPanel(302,   5, 178) -- View circle top/Wage
    self:addPanel(303,   0, 226) -- View circle midpiece
    self:addPanel(304,   6, 274) -- View circle bottom
    if profile.humanoid_class ~= "Doctor" then
      self:addColourPanel(32, 141, 171, 39, 85, 202, 219)  -- Hides Skills
    end
    self:addPanel(307, 106, 226):makeButton(0, 0, 50, 50, 308, self.fireStaff):setTooltip(_S.tooltip.staff_window.sack)
    self:addPanel(309, 164, 226):makeButton(0, 0, 37, 50, 310, self.placeStaff):setTooltip(_S.tooltip.staff_window.pick_up)
  end

  self:addPanel(305, 178,  18):makeButton(0, 0, 24, 24, 306, self.close):setTooltip(_S.tooltip.staff_window.close)
  
  self:makeTooltip(_S.tooltip.staff_window.name, 33, 19, 172, 42)
  self:makeTooltip(_S.tooltip.staff_window.happiness, 113,  49, 204,  74)
  self:makeTooltip(_S.tooltip.staff_window.tiredness, 113,  74, 204, 109)
  self:makeTooltip(_S.tooltip.staff_window.ability,   113, 109, 204, 134)
  
  if profile.humanoid_class == "Doctor" then
    self:makeTooltip(_S.tooltip.staff_window.doctor_seniority, 30, 141, 111, 182)
    self:makeTooltip(_S.tooltip.staff_window.skills, 111, 146, 141, 179)
    
    local skill_to_string = {
      is_surgeon = _S.tooltip.staff_window.surgeon,
      is_psychiatrist = _S.tooltip.staff_window.psychiatrist,
      is_researcher = _S.tooltip.staff_window.researcher,
    }
    local --[[persistable:staff_dialog_skill_tooltip_template]] function skill_tooltip(skill)
      return --[[persistable:staff_dialog_skill_tooltip]] function()
        if profile[skill] >= 1.0 then
          return skill_to_string[skill]
        end
      end
    end
    
    self:makeDynamicTooltip(skill_tooltip("is_surgeon"),      143, 148, 155, 177)
    self:makeDynamicTooltip(skill_tooltip("is_psychiatrist"), 155, 148, 177, 177)
    self:makeDynamicTooltip(skill_tooltip("is_researcher"),   177, 148, 202, 177)
  end
  
  -- window for handyman is slightly different
  local offset = profile.humanoid_class == "Handyman" and 27 or 0
  
  self:makeTooltip(_S.tooltip.staff_window.salary, 90, 191 + offset, 204, 214 + offset)
  -- Non-rectangular tooltip has to be realized with dynamic tooltip at the moment
  self:makeDynamicTooltip(--[[persistable:staff_dialog_center_tooltip]]function(x, y)
    if is_in_view_circle(x, y, profile.humanoid_class == "Handyman") then
      return _S.tooltip.staff_window.center_view
    end
  end, 17, 211 + offset, 92, 286 + offset)
  
end

function UIStaff:getStaffPosition(dx, dy)
  local staff = self.staff
  local x, y = self.ui.app.map:WorldToScreen(staff.tile_x, staff.tile_y)
  local px, py = staff.th:getMarker()
  return x + px - (dx or 0), y + py - (dy or 0)
end

function UIStaff:draw(canvas, x_, y_)
  local x, y = self.x + x_, self.y + y_

  local px, py = self:getStaffPosition(37, 61)
  self.ui.app.map:draw(canvas, px, py, 75, 75, x + 17, y + self.height - 93)
  Window.draw(self, canvas, x_, y_)
  
  local profile = self.staff.profile
  local font = self.white_font

  font:draw(canvas, profile.name, x + 42, y + 28) -- Name
  if profile.humanoid_class == "Handyman" then
    font:draw(canvas, "$" .. profile.wage, x + 135, y + 226) -- Wage
    -- The concentration areas
    local cleaning_width, watering_width, repairing_width = 0, 0, 0
    if self.staff.attributes["cleaning"] then -- Backwards compatibility
      cleaning_width = math_floor(self.staff.attributes["cleaning"] * 40 + 0.5)
      watering_width = math_floor(self.staff.attributes["watering"] * 40 + 0.5)
      repairing_width = math_floor(self.staff.attributes["repairing"] * 40 + 0.5)
      if cleaning_width ~= 0 then
        for dx = 0, cleaning_width - 1 do
          self.panel_sprites:draw(canvas, 351, x + 43 + dx, y + 200)
        end
      end
      if watering_width ~= 0 then
        for dx = 0, watering_width - 1 do
          self.panel_sprites:draw(canvas, 351, x + 99 + dx, y + 200)
        end
      end
      if repairing_width ~= 0 then
        for dx = 0, repairing_width - 1 do
          self.panel_sprites:draw(canvas, 351, x + 155 + dx, y + 200)
        end
      end
    end
  else
    font:draw(canvas, "$" .. profile.wage, x + 135, y + 199) -- Wage
  end
  
  if self.staff.attributes["happiness"] then
    local happiness_bar_width = math_floor(self.staff.attributes["happiness"] * 40 + 0.5)
    if happiness_bar_width ~= 0 then
      for dx = 0, happiness_bar_width - 1 do
        self.panel_sprites:draw(canvas, 348, x + 139 + dx, y + 56)
      end
    end
  end
  
  local fatigue_bar_width = 40.5
  if self.staff.attributes["fatigue"] then
    fatigue_bar_width = math_floor((1 - self.staff.attributes["fatigue"]) * 40 + 0.5)
  end
  if fatigue_bar_width ~= 0 then
    for dx = 0, fatigue_bar_width - 1 do
      self.panel_sprites:draw(canvas, 349, x + 139 + dx, y + 89)
    end
  end
  
  local skill_bar_width = math_floor(profile.skill * 40 + 0.5)
  if skill_bar_width ~= 0 then
    for dx = 0, skill_bar_width - 1 do
      self.panel_sprites:draw(canvas, 350, x + 139 + dx, y + 120)
    end
  end
  
  if profile.humanoid_class == "Doctor" then
    -- Junior / Doctor / Consultant marker
    if profile.is_junior then
      self.panel_sprites:draw(canvas, 347, x + 38, y + 173)
    elseif profile.is_consultant then
      self.panel_sprites:draw(canvas, 347, x + 89, y + 173)
    else
      self.panel_sprites:draw(canvas, 347, x + 60, y + 173)
    end
    -- Ability markers
    if profile.is_surgeon >= 1.0 then
      self.panel_sprites:draw(canvas, 344, x + 144, y + 148)
    end
    if profile.is_psychiatrist >= 1.0 then
      self.panel_sprites:draw(canvas, 345, x + 155, y + 154)
    end
    if profile.is_researcher >= 1.0 then
      self.panel_sprites:draw(canvas, 346, x + 178, y + 153)
    end
  end
  
  profile:drawFace(canvas, x + 38, y + 54, self.face_parts) -- Portrait
end

function UIStaff:onMouseDown(button, x, y)
  self.do_scroll = button == "left" and is_in_view_circle(x, y, self.staff.profile.humanoid_class == "Handyman")
  return Window.onMouseDown(self, button, x, y)
end

-- Helper function to faciliate humanoid_class comparison wrt. Surgeons
local function surg_compat(class)
  return class == "Surgeon" and "Doctor" or class
end

function UIStaff:onMouseUp(button, x, y)
  local ui = self.ui
  if button == "left" then
    self.do_scroll = false
  end
  local repaint = Window.onMouseUp(self, button, x, y)
  -- Test for hit within the view circle
  if button == "right" and is_in_view_circle(x, y, self.staff.profile.humanoid_class == "Handyman") then
    -- Right click goes to the next staff member of the same category (NB: Surgeon in same Category as Doctor)
    local staff_index = nil
    for i, staff in ipairs(ui.hospital.staff) do
      if staff_index and surg_compat(staff.humanoid_class) == surg_compat(self.staff.humanoid_class) then
        ui:addWindow(UIStaff(ui, staff))
        return false
      end
      if staff == self.staff then
        staff_index = i
      end
    end
    -- Try again from beginning of list until staff_index
    for i = 1, staff_index - 1 do
      local staff = ui.hospital.staff[i]
      if surg_compat(staff.humanoid_class) == surg_compat(self.staff.humanoid_class) then
        ui:addWindow(UIStaff(ui, staff))
        return false
      end
    end
  end
  return repaint
end

function UIStaff:onMouseMove(x, y, dx, dy)
  self.do_scroll = self.do_scroll and is_in_view_circle(x, y, self.staff.profile.humanoid_class == "Handyman")
  return Window.onMouseMove(self, x, y, dx, dy)
end

function UIStaff:onTick()
  if self.do_scroll then
    local ui = self.ui
    local staff = self.staff
    local sx, sy = ui.app.map:WorldToScreen(staff.tile_x, staff.tile_y)
    local dx, dy = staff.th:getPosition()
    ui:scrollMapTo(sx + dx, sy + dy)
  end
  return Window.onTick(self)
end

function UIStaff:placeStaff()
  self.staff:setNextAction({
    name = "pickup",
    ui = self.ui,
    todo_close = self,
    must_happen = true,
  }, true)
end

function UIStaff:fireStaff()
  self.ui:addWindow(UIConfirmDialog(self.ui, _S.confirmation.sack_staff, --[[persistable:staff_dialog_confirm_sack]] function()
    self.staff:fire()
  end))
end

local attributes = {"cleaning", "watering", "repairing"}

function UIStaff:changeHandymanAttributes(increased)
  self.staff:changeAttribute(increased, 0.1)
  local extra_decrease = 0
  for no, attr in ipairs(attributes) do
    if attr ~= increased then
      if self.staff.attributes[attr] < 0.05 then
        extra_decrease = 0.05 - self.staff.attributes[attr]
      end
      self.staff:changeAttribute(attr, -0.05)
    end
  end
  if extra_decrease ~= 0 then
    for no, attr in ipairs(attributes) do
    if attr ~= increased then
      self.staff:changeAttribute(attr, -extra_decrease)
    end
  end
  end
end

function UIStaff:doMoreCleaning()
  if self.staff.attributes["cleaning"] then
    if self.staff.attributes["cleaning"] < 0.9 then
      self:changeHandymanAttributes("cleaning")
    else
      self.staff.attributes["cleaning"] = 1.0
      self.staff.attributes["watering"] = 0.0
      self.staff.attributes["repairing"] = 0.0
    end
  end
end

function UIStaff:doMoreWatering()
  if self.staff.attributes["watering"] then
    if self.staff.attributes["watering"] < 0.9 then
      self:changeHandymanAttributes("watering")
    else
      self.staff.attributes["cleaning"] = 0.0
      self.staff.attributes["watering"] = 1.0
      self.staff.attributes["repairing"] = 0.0
    end
  end
end

function UIStaff:doMoreRepairing()
  if self.staff.attributes["repairing"] then
    if self.staff.attributes["repairing"] < 0.9 then
      self:changeHandymanAttributes("repairing")
    else
      self.staff.attributes["cleaning"] = 0.0
      self.staff.attributes["watering"] = 0.0
      self.staff.attributes["repairing"] = 1.0
    end
  end
end

function UIStaff:openStaffManagement()
  local dlg = UIStaffManagement(self.ui)
  dlg:selectStaff(self.staff)
  self.ui:addWindow(dlg)
  self:close()
end

function UIStaff:hitTest(x, y)
  return Window.hitTest(self, x, y) or is_in_view_circle(x, y, self.staff.profile.humanoid_class == "Handyman")
end
