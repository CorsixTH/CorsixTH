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


--! Dialog for staff member requesting a salaray raise.
class "UIStaffRise" (Window)

---@type UIStaffRise
local UIStaffRise = _G["UIStaffRise"]

function UIStaffRise:UIStaffRise(ui, staff, rise_amount)
  self:Window()
  local app = ui.app
  local profile = staff.profile

  self.esc_closes = false -- Do not allow closing the dialog with esc
  self.staff = staff
  self.ui = ui
  self.rise_amount = rise_amount
  self.on_top = true

  local final_wage = self.staff.profile.wage + rise_amount
  self.text = _S.pay_rise.regular.__random:format(rise_amount, final_wage) -- Random complaint text

  self.width = 362
  self.height = 288

  -- Center the dialog
  self:setDefaultPosition(0.5, 0.5)

  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req12V", true)
  self.white_font = app.gfx:loadFontAndSpriteTable("QData", "Font01V", nil, nil, { apply_ui_scale = true })
  self.black_font = app.gfx:loadFontAndSpriteTable("QData", "Font00V", nil, nil, { apply_ui_scale = true })
  self.face_parts = app.gfx:loadRaw("Face01V", 65, 1350, nil, "Data", "MPalette.dat", false, { flags = DrawFlags.Nearest })

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
  self:addPanel(288, 180, 233):makeButton(0, 0, 90, 45, 289, self.increaseSalary):setTooltip(_S.tooltip.pay_rise_window.accept)
  self:addPanel(290, 270, 233):makeButton(0, 0, 90, 45, 291, self.fireStaff):setTooltip(_S.tooltip.pay_rise_window.decline)

  self:makeTooltip(_S.tooltip.staff_window.name, 14, 15, 169, 38)
  self:makeTooltip(_S.tooltip.staff_window.face, 96, 44, 168, 125)
  self:makeTooltip(_S.tooltip.staff_window.salary, 14, 171, 168, 193)
  self:makeTooltip(_S.tooltip.staff_window.ability, 12, 213, 89, 243)

  if class.is(staff, Doctor) then
    self:makeTooltip(_S.tooltip.staff_window.doctor_seniority, 89, 197, 168, 243)
    self:makeTooltip(_S.tooltip.staff_window.skills, 14, 132, 47, 166)

    -- NB: should be sufficient here to check only once, not make a dynamic tooltip
    if profile.is_surgeon >= 1.0 then
      self:makeTooltip(_S.tooltip.staff_window.surgeon, 72, 133, 87, 164)
    end
    if profile.is_psychiatrist >= 1.0 then
      self:makeTooltip(_S.tooltip.staff_window.psychiatrist, 87, 133, 116, 164)
    end
    if profile.is_researcher >= 1.0 then
      self:makeTooltip(_S.tooltip.staff_window.researcher, 116, 133, 146, 164)
    end
  else
    -- Hide doctor specific information
    self:addColourPanel(10, 130, 160, 40, 60, 174, 203)
    self:addColourPanel(89, 198, 81, 45, 60, 174, 203)
  end
end

-- Staff raise requests pause game
function UIStaffRise:mustPause()
  return true
end

function UIStaffRise:getStaffPosition(dx, dy)
  local staff = self.staff
  local x, y = self.ui.app.map:WorldToScreen(staff.tile_x, staff.tile_y)
  local px, py = staff.th:getSecondaryMarker()
  return x + px - (dx or 0), y + py - (dy or 0)
end

function UIStaffRise:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  local profile = self.staff.profile
  local s = TheApp.config.ui_scale
  x, y = self.x * s + x, self.y * s + y
  local px, py = self:getStaffPosition(37, 61)
  local font = self.white_font

  profile:drawFace(canvas, x + 99 * s, y + 47 * s, self.face_parts, s) -- Portrait
  canvas:scale(s)
  self.ui.app.map:draw(canvas, px, py, 71, 81, math.floor(x / s) + 16, math.floor(y / s) + 44) -- Viewport
  canvas:scale(1)

  font:draw(canvas, profile:getFullName(), x + 20 * s, y + 20 * s) -- Name
  font:draw(canvas, "$" .. profile.wage, x + 60 * s, y + 178 * s) -- Wage

  -- Ability
  -- Note: The bar looks like "attention to detail", but actually ability level
  -- is displayed here. This was the same in TH, and makes more sense.
  -- However at some point we should fix the graphics to look like an ability bar.
  local ability_bar_width = math.floor(profile.skill * 40 * s + 0.5)
  if ability_bar_width ~= 0 then
    for dx = 0, ability_bar_width - 1 do
      self.panel_sprites:draw(canvas, 295, x + 42 * s + dx, y + 230 * s, { scaleFactor = s })
    end
  end

  if class.is(self.staff, Doctor) then
    self:drawDoctorAttributes(canvas)
  end

  -- Complaint text
  self.black_font:drawWrapped(canvas, self.text, x + 200 * s, y + 20 * s, 140 * s)
end

function UIStaffRise:drawDoctorAttributes(canvas)
  local profile = self.staff.profile
  local s = TheApp.config.ui_scale
  local x, y = self.x * s, self.y * s

  -- Junior / Doctor / Consultant marker
  local marker_x = x + 98 * s
  if profile.is_consultant then
    marker_x = marker_x + 52 * s
  elseif not profile.is_junior then
    marker_x = marker_x + 22 * s
  end

  self.panel_sprites:draw(canvas, 296, marker_x, y + 230 * s, { scaleFactor = s })

  -- Ability markers
  if profile.is_surgeon >= 1.0 then
    self.panel_sprites:draw(canvas, 292, x + 74 * s, y + 133 * s, { scaleFactor = s })
  end
  if profile.is_psychiatrist >= 1.0 then
    self.panel_sprites:draw(canvas, 293, x + 90 * s, y + 139 * s, { scaleFactor = s })
  end
  if profile.is_researcher >= 1.0 then
    self.panel_sprites:draw(canvas, 294, x + 120 * s, y + 138 * s, { scaleFactor = s})
  end
end

function UIStaffRise:fireStaff()
  self.staff.message_callback = nil
  self.staff:fire()
  self:close()
end

function UIStaffRise:increaseSalary()
  self.staff.message_callback = nil
  self.staff:increaseWage(self.rise_amount)
  self.staff.quitting_in = nil
  self:close()
end

function UIStaffRise:afterLoad(old, new)
  Window.afterLoad(self, old, new)
  if old < 236 then
    self.white_font = TheApp.gfx:loadFontAndSpriteTable("QData", "Font01V", nil, nil, { apply_ui_scale = true })
    self.black_font = TheApp.gfx:loadFontAndSpriteTable("QData", "Font00V", nil, nil, { apply_ui_scale = true })
    self.face_parts = TheApp.gfx:loadRaw("Face01V", 65, 1350, nil, "Data", "MPalette.dat", false, { flags = DrawFlags.Nearest })
  end
end
