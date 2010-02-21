--[[ Copyright (c) 2010 Miika-Petteri Matikainen

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

local math_floor
    = math.floor

class "UIStaffRise" (Window)

function UIStaffRise:UIStaffRise(ui, staff, rise_amount)
  self:Window()
  local app = ui.app
  local profile = staff.profile

  self.esc_closes = false -- Do not allow closing the dialog with esc
  self.staff = staff
  self.ui = ui
  self.rise_amount = rise_amount

  local final_wage = self.staff.profile.wage + rise_amount
  self.text = string.format(_S.pay_rise.regular.__random, rise_amount, final_wage) -- Random complaint text

  self.width = 366
  self.height = 275

  -- Center the dialog
  self:setDefaultPosition(0.5, 0.5)

  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req12V", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  self.face_parts = app.gfx:loadRaw("Face01V", 65, 1350, "Data", "MPalette.dat")

  -- Left hand side
  self:addPanel(280, 0, 0)
  self:addPanel(281, 0, 54)
  self:addPanel(281, 0, 64)
  self:addPanel(281, 0, 64)
  self:addPanel(281, 0, 74)
  self:addPanel(281, 0, 84)
  self:addPanel(281, 0, 94)
  self:addPanel(281, 0, 104)
  self:addPanel(282, 0, 114)
  self:addPanel(283, 0, 171)
  self:addPanel(284, 0, 214)
  self:addColourPanel(96, 44, 72, 81, 211, 255, 255) -- Portrait background

  -- Right hand side
  self:addPanel(285, 180, 0)
  self:addPanel(286, 180, 20)
  self:addPanel(286, 180, 48)
  self:addPanel(286, 180, 76)
  self:addPanel(286, 180, 104)
  self:addPanel(286, 180, 132)
  self:addPanel(286, 180, 160)
  self:addPanel(287, 180, 188)
  self:addPanel(288, 180, 233):makeButton(0, 0, 90, 45, 289, self.increaseSalary):setSound"cashreg.wav"
  self:addPanel(290, 270, 233):makeButton(0, 0, 90, 45, 291, self.fireStaff)

  -- Hide doctor specific information
  if self.staff.profile.humanoid_class ~= "Doctor" then
    self:addColourPanel(10, 130, 160, 40, 60, 174, 203)
    self:addColourPanel(10, 198, 160, 45, 60, 174, 203)
  end
end

function UIStaffRise:getStaffPosition(dx, dy)
  local staff = self.staff
  local x, y = self.ui.app.map:WorldToScreen(staff.tile_x, staff.tile_y)
  local px, py = staff.th:getMarker()
  return x + px - (dx or 0), y + py - (dy or 0)
end

function UIStaffRise:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  local profile = self.staff.profile
  x, y = self.x + x, self.y + y
  local px, py = self:getStaffPosition(37, 61)
  local font = self.white_font

  profile:drawFace(canvas, x + 99, y + 47, self.face_parts) -- Portrait
  self.ui.app.map:draw(canvas, px, py, 71, 81, x + 16, y + 44) -- Viewport

  font:draw(canvas, profile.name, x + 20, y + 20) -- Name
  font:draw(canvas, "$" .. profile.wage, x + 60, y + 178) -- Wage

  if self.staff.profile.humanoid_class == "Doctor" then
    self:drawDoctorAttributes(canvas)
  end

  -- Complaint text
  font:drawWrapped(canvas, self.text, x + 200, y + 20, 140)
end

function UIStaffRise:drawDoctorAttributes(canvas)
  local profile = self.staff.profile
  local x, y = self.x, self.y

  -- Junior / Doctor / Consultant marker
  local marker_x = x + 98
  if profile.is_junior then
  elseif profile.is_consultant then
    marker_x = marker_x + 52
  else
    marker_x = marker_x + 22
  end

  self.panel_sprites:draw(canvas, 296, marker_x, y + 230)

  -- Ability markers
  if profile.is_surgeon >= 1.0 then
    self.panel_sprites:draw(canvas, 292, x + 74, y + 133)
  end
  if profile.is_psychiatrist >= 1.0 then
    self.panel_sprites:draw(canvas, 293, x + 90, y + 139)
  end
  if profile.is_researcher >= 1.0 then
    self.panel_sprites:draw(canvas, 294, x + 120, y + 138)
  end

  -- Attention to detail
  local attention_bar_width = math.floor(profile.attention_to_detail * 40 + 0.5)
  if attention_bar_width ~= 0 then
    for dx = 0, attention_bar_width - 1 do
      self.panel_sprites:draw(canvas, 295, x + 42 + dx, y + 230)
    end
  end
end

function UIStaffRise:fireStaff()
  self.staff:fire()
  local staff_window = self.ui:getWindow(UIStaff)
  if staff_window and staff_window.staff == self.staff then
    staff_window:close()
  end
  self:close()
end

function UIStaffRise:increaseSalary()
  self.staff:increaseWage(self.rise_amount)
  self:close()
end

