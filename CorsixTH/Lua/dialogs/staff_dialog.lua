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
  self.face_parts = app.gfx:loadRaw("Face01V", 65, 1350, "Data", "MPalette.dat")
  
  self:addPanel(297,   15,   0) -- Dialog header
  for y = 51, 121, 10 do
    self:addPanel(298, 15,   y) -- Dialog background
  end
  self:addPanel(299,  104,  50) -- Happiness
  self:addPanel(300,  105,  82) -- Tiredness
  self:addPanel(301,   15, 114) -- Skills/Abilities
  self:addColourPanel(35, 51, 71, 81, 208, 252, 252) -- Portrait background
  
  if profile.humanoid_class == "Handyman" then
    self:addPanel(311,  15, 131) -- Tasks top
    for y = 149, 184, 5 do
      self:addPanel(312, 15,  y) -- Tasks buttons
    end
    self:addPanel(302,   5, 205) -- View circle top/Wage
    self:addPanel(313,  15, 189) -- Tasks bottom
    self:addPanel(314,  37, 145):makeButton(0, 0, 49, 48, 315, self.doMoreCleaning)
    self:addPanel(316,  92, 145):makeButton(0, 0, 49, 48, 317, self.doMoreWatering)
    self:addPanel(318, 148, 145):makeButton(0, 0, 49, 48, 319, self.doMoreRepairing)
    self:addPanel(303,   0, 253) -- View circle midpiece
    self:addPanel(304,   6, 302) -- View circle bottom
    self:addPanel(307, 106, 253):makeButton(0, 0, 37, 50, 308, self.fireStaff)
    self:addPanel(309, 164, 253):makeButton(0, 0, 37, 50, 310, self.placeStaff)
  else
    self:addPanel(302,   5, 178) -- View circle top/Wage
    self:addPanel(303,   0, 226) -- View circle midpiece
    self:addPanel(304,   6, 274) -- View circle bottom
    if profile.humanoid_class ~= "Doctor" then
      self:addColourPanel(32, 141, 171, 39, 85, 202, 219)  -- Hides Skills
    end
    self:addPanel(307, 106, 226):makeButton(0, 0, 50, 50, 308, self.fireStaff)
    self:addPanel(309, 164, 226):makeButton(0, 0, 37, 50, 310, self.placeStaff)
  end

  self:addPanel(305, 178,  18):makeButton(0, 0, 24, 24, 306, self.close)
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

function UIStaff:onMouseUp(button, x, y)
  self.mouse_up_x = self.x + x
  self.mouse_up_y = self.y + y
  local repaint = Window.onMouseUp(self, button, x, y)

  local circle_center_y
  if self.staff.profile.humanoid_class == "Handyman" then
    circle_center_y = 276
  else
    circle_center_y = 248
  end
  -- Test for hit within the view circle
  if button == "left" and (x - 55)^2 + (y - circle_center_y)^2 < 38^2 then
    local ui = self.ui
    ui:scrollMapTo(self:getStaffPosition())
    repaint = true
  elseif button == "right" then
    --TODO: Right clicking on staff view should go to the next staff
  end
  return repaint
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
  self:close()
  self.staff:fire()
end

function UIStaff:doMoreCleaning()
  -- TODO
end

function UIStaff:doMoreWatering()
  -- TODO
end

function UIStaff:doMoreRepairing()
  -- TODO
end
