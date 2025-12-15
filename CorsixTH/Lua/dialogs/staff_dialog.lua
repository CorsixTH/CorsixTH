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

-- Test for hit within the view circle
local --[[persistable:staff_dialog_is_in_view_circle]] function is_in_view_circle(x, y, is_handyman)
  local s = TheApp.config.ui_scale
  local circle_center_y = is_handyman and 276 * s or 248 * s
  return (x - 55 * s)^2 + (y - circle_center_y)^2 < (39 * s)^2
end

--! Individual staff information dialog
class "UIStaff" (Window)

---@type UIStaff
local UIStaff = _G["UIStaff"]

--! Callback function for handyman to change his parcel.
function UIStaff:changeParcel()
  local index = 0
  for i, v in ipairs(self.staff.hospital.ownedPlots) do
    if v == self.staff.parcelNr then
      index = i
      break
    end
  end
  if not self.staff.hospital.ownedPlots[index + 1] then
    self.staff.parcelNr = 0
  else
    self.staff.parcelNr = self.staff.hospital.ownedPlots[index + 1]
  end
end

function UIStaff:getParcelText()
  if not self.staff.parcelNr then
    self.staff.parcelNr = 0
  end
  if self.staff.parcelNr == 0 then
    return _S.handyman_window.all_parcels --"All parcels"
  else
    return _S.handyman_window.parcel .. " " .. self.staff.parcelNr
  end
end

function UIStaff:UIStaff(ui, staff)
  self:Window()

  local app = ui.app
  local profile = staff.profile
  self.esc_closes = true
  self.staff = staff
  self.ui = ui
  self.modal_class = "humanoid_info"
  self.width = 220
  if class.is(staff, Handyman) then
    self.height = 332
  else
    self.height = 304
  end
  self:setDefaultPosition(-20, 30)
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req01V", true)
  self.white_font = app.gfx:loadFontAndSpriteTable("QData", "Font01V", nil, nil, { apply_ui_scale = true })
  self.face_parts = app.gfx:loadRaw("Face01V", 65, 1350, nil, "Data", "MPalette.dat", false, { nearest = true })

  self:addPanel(297,   15,   0) -- Dialog header
  for y = 51, 121, 10 do
    self:addPanel(298, 15,   y) -- Dialog background
  end
  self:addPanel(299,  104,  50) -- Happiness
  self:addPanel(300,  105,  82) -- Tiredness
  self:addPanel(301,   15, 114) -- Skills/Abilities
  self:addColourPanel(35, 51, 71, 81, 208, 252, 252):makeButton(0, 0, 71, 81, nil, self.openStaffManagement):setTooltip(_S.tooltip.staff_window.face) -- Portrait background

  if class.is(staff, Handyman) then
    self:addPanel(311,  15, 131) -- Tasks top
    for y = 149, 184, 5 do
      self:addPanel(312, 15,  y) -- Tasks buttons
    end
    self:addPanel(302,   5, 205) -- View circle top/Wage
    self:addPanel(313,  15, 189) -- Tasks bottom
    self:addPanel(314,  37, 145):makeRepeatButton(0, 0, 49, 48, 315, self.doMoreCleaning):setTooltip(_S.tooltip.handyman_window.prio_litter):setSound("selectx.wav")
    self:addPanel(316,  92, 145):makeRepeatButton(0, 0, 49, 48, 317, self.doMoreWatering):setTooltip(_S.tooltip.handyman_window.prio_plants):setSound("selectx.wav")
    self:addPanel(318, 148, 145):makeRepeatButton(0, 0, 49, 48, 319, self.doMoreRepairing):setTooltip(_S.tooltip.handyman_window.prio_machines):setSound("selectx.wav")
    self:addPanel(240,  21, 210):makeButton(0, 0, 73, 30, 240, self.changeParcel):setTooltip(_S.tooltip.handyman_window.parcel_select):setSound("selectx.wav")
  self:addPanel(303,   0, 253) -- View circle midpiece
    self:addPanel(304,   6, 302) -- View circle bottom
    self:addPanel(307, 106, 253):makeButton(0, 0, 50, 50, 308, self.fireStaff):setTooltip(_S.tooltip.staff_window.sack):setSound("selectx.wav")
    self:addPanel(309, 164, 253):makeButton(0, 0, 37, 50, 310, self.pickupStaff):setTooltip(_S.tooltip.staff_window.pick_up)
  else
    self:addPanel(302,   5, 178) -- View circle top/Wage
    self:addPanel(303,   0, 226) -- View circle midpiece
    self:addPanel(304,   6, 274) -- View circle bottom
    if not class.is(staff, Doctor) then
      self:addColourPanel(32, 141, 171, 39, 85, 202, 219)  -- Hides Skills
    end
    self:addPanel(307, 106, 226):makeButton(0, 0, 50, 50, 308, self.fireStaff):setTooltip(_S.tooltip.staff_window.sack):setSound("selectx.wav")
    self:addPanel(309, 164, 226):makeButton(0, 0, 37, 50, 310, self.pickupStaff):setTooltip(_S.tooltip.staff_window.pick_up)
  end

  self:addPanel(305, 178,  18):makeButton(0, 0, 24, 24, 306, self.close):setTooltip(_S.tooltip.staff_window.close)

  self:makeTooltip(_S.tooltip.staff_window.name, 33, 19, 172, 42)
  self:makeTooltip(_S.tooltip.staff_window.happiness, 113,  49, 204,  74)
  self:makeTooltip(_S.tooltip.staff_window.tiredness, 113,  74, 204, 109)
  self:makeTooltip(_S.tooltip.staff_window.ability,   113, 109, 204, 134)

  if class.is(staff, Doctor) then
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
  local offset = class.is(staff, Handyman) and 27 or 0

  self:makeTooltip(_S.tooltip.staff_window.salary, 90, 191 + offset, 204, 214 + offset)
  -- Non-rectangular tooltip has to be realized with dynamic tooltip at the moment
  self:makeDynamicTooltip(--[[persistable:staff_dialog_center_tooltip]]function(x, y)
    if is_in_view_circle(x, y, class.is(staff, Handyman)) then
      return _S.tooltip.staff_window.center_view
    end
  end, 17, 211 + offset, 92, 286 + offset)

end

function UIStaff:getStaffPosition(dx, dy)
  local staff = self.staff
  local x, y = self.ui.app.map:WorldToScreen(staff.tile_x, staff.tile_y)
  local px, py = staff.th:getSecondaryMarker()
  return x + px - (dx or 0), y + py - (dy or 0)
end

function UIStaff:draw(canvas, x_, y_)
  local s = TheApp.config.ui_scale
  local x, y = self.x * s + x_, self.y * s + y_

  local px, py = self:getStaffPosition(37, 61)
  canvas:scale(s)
  self.ui.app.map:draw(canvas, px, py, 75, 75, math.floor(x / s) + 17, math.floor(y / s) + self.height - 93)
  canvas:scale(1)
  Window.draw(self, canvas, x_, y_)

  local profile = self.staff.profile
  local font = self.white_font

  font:draw(canvas, profile:getFullName(), x + 42 * s, y + 28 * s) -- Name
  if class.is(self.staff, Handyman)then
    font:draw(canvas, "$" .. profile.wage, x + 135 * s, y + 225 * s) -- Wage
    font:draw(canvas, self:getParcelText(), x + 35 * s, y + 215 * s, 50 * s, 0)
    -- The concentration areas
    local cleaning_width = math.floor(self.staff:getAttribute("cleaning") * 40 * s + 0.5)
    local watering_width = math.floor(self.staff:getAttribute("watering") * 40 * s + 0.5)
    local repairing_width = math.floor(self.staff:getAttribute("repairing") * 40 * s + 0.5)
    if cleaning_width ~= 0 then
      for dx = 0, cleaning_width - 1, s do
        self.panel_sprites:draw(canvas, 351, x + 43 * s + dx, y + 200 * s, { scaleFactor = s })
      end
    end
    if watering_width ~= 0 then
      for dx = 0, watering_width - 1 do
        self.panel_sprites:draw(canvas, 351, x + 99 * s + dx, y + 200 * s, { scaleFactor = s })
      end
    end
    if repairing_width ~= 0 then
      for dx = 0, repairing_width - 1 do
        self.panel_sprites:draw(canvas, 351, x + 155 * s + dx, y + 200 * s, { scaleFactor = s })
      end
    end
  else
    font:draw(canvas, "$" .. profile.wage, x + 135 * s, y + 198 * s) -- Wage
  end

  if self.staff:getAttribute("happiness") then
    local happiness_bar_width = math.floor(self.staff:getAttribute("happiness") * 40 * s + 0.5)
    if happiness_bar_width ~= 0 then
      for dx = 0, happiness_bar_width - 1, s do
        self.panel_sprites:draw(canvas, 348, x + 139 * s + dx, y + 56 * s, { scaleFactor = s })
      end
    end
  end

  local fatigue_bar_width = 40.5
  if self.staff:getAttribute("fatigue") then
    fatigue_bar_width = math.floor((1 - self.staff:getAttribute("fatigue")) * 40 * s + 0.5)
  end
  if fatigue_bar_width ~= 0 then
    for dx = 0, fatigue_bar_width - 1, s do
      self.panel_sprites:draw(canvas, 349, x + 139 * s + dx, y + 89 * s, { scaleFactor = s })
    end
  end

  local skill_bar_width = math.floor(profile.skill * 40 * s + 0.5)
  if skill_bar_width ~= 0 then
    for dx = 0, skill_bar_width - 1, s do
      self.panel_sprites:draw(canvas, 350, x + 139 * s + dx, y + 120 * s, { scaleFactor = s })
    end
  end

  if class.is(self.staff, Doctor) then
    -- Junior / Doctor / Consultant marker
    if profile.is_junior then
      self.panel_sprites:draw(canvas, 347, x + 38 * s, y + 173 * s, { scaleFactor = s })
    elseif profile.is_consultant then
      self.panel_sprites:draw(canvas, 347, x + 89 * s, y + 173 * s, { scaleFactor = s })
    else
      self.panel_sprites:draw(canvas, 347, x + 60 * s, y + 173 * s, { scaleFactor = s })
    end
    -- Ability markers
    if profile.is_surgeon >= 1.0 then
      self.panel_sprites:draw(canvas, 344, x + 144 * s, y + 148 * s, { scaleFactor = s })
    end
    if profile.is_psychiatrist >= 1.0 then
      self.panel_sprites:draw(canvas, 345, x + 155 * s, y + 154 * s, { scaleFactor = s })
    end
    if profile.is_researcher >= 1.0 then
      self.panel_sprites:draw(canvas, 346, x + 178 * s, y + 153 * s, { scaleFactor = s })
    end
  end

  profile:drawFace(canvas, x + 38 * s, y + 54 * s, self.face_parts, s) -- Portrait
end

function UIStaff:onMouseDown(button, x, y)
  self.do_scroll = button == "left" and is_in_view_circle(x, y, class.is(self.staff, Handyman))
  return Window.onMouseDown(self, button, x, y)
end

function UIStaff:onMouseUp(button, x, y)
  local ui = self.ui
  if button == "left" then
    self.do_scroll = false
  end
  local repaint = Window.onMouseUp(self, button, x, y)
  -- Test for hit within the view circle and name box
  local hit_namebox = x > self.tooltip_regions[1].x and x < self.tooltip_regions[1].r
                      and y > self.tooltip_regions[1].y and y < self.tooltip_regions[1].b
  if button == "right" and is_in_view_circle(x, y, class.is(self.staff, Handyman))
     or button == "right" and hit_namebox then
    -- Right click goes to the next staff member of the same category (NB: Surgeon in same Category as Doctor)
    local staff_index = nil
    for i, staff in ipairs(ui.hospital.staff) do
      if staff_index and staff.profile:isType(self.staff.profile.humanoid_class) then
        ui:addWindow(UIStaff(ui, staff))
        if hit_namebox then
          local sx, sy = ui.app.map:WorldToScreen(staff.tile_x, staff.tile_y)
          local dx, dy = staff.th:getPosition()
          ui:scrollMapTo(sx + dx, sy + dy)
        end
        return false
      end
      if staff == self.staff then
        staff_index = i
      end
    end
    -- Try again from beginning of list until staff_index
    for i = 1, staff_index - 1 do
      local staff = ui.hospital.staff[i]
      if staff.profile:isType(self.staff.profile.humanoid_class) then
        ui:addWindow(UIStaff(ui, staff))
        if hit_namebox then
          local sx, sy = ui.app.map:WorldToScreen(staff.tile_x, staff.tile_y)
          local dx, dy = staff.th:getPosition()
          ui:scrollMapTo(sx + dx, sy + dy)
        end
        return false
      end
    end
  end
  return repaint
end

function UIStaff:onMouseMove(x, y, dx, dy)
  self.do_scroll = self.do_scroll and is_in_view_circle(x, y, class.is(self.staff, Handyman))
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

function UIStaff:pickupStaff()
  self.staff:setPickup(self.ui, self)
end

function UIStaff:fireStaff()
  self.ui:addWindow(UIConfirmDialog(self.ui, false, _S.confirmation.sack_staff, --[[persistable:staff_dialog_confirm_sack]] function()
    self.staff:fire()
  end))
end


--! Function to balance 'cleaning','watering', and 'repairing', where
--! one of them is increased, and the other two are decreased.
--!param increased Attribute to increase.
function UIStaff:changeHandymanAttributes(increased)
  if not self.staff:getAttribute(increased) then
    return
  end

  -- Show a helpful message if this dialog hasn't been opened yet
  if not self.ui.hospital.handyman_popup then
    self.ui.adviser:say(_A.information.handyman_adjust)
    self.ui.hospital.handyman_popup = true
  end

  local incr_value = 0.1  -- Increase of 'increased'
  local smallest_decr = 0.05 -- Smallest decrement that can be performed.
  local decr_attrs = {}

  local attributes = {"cleaning", "watering", "repairing"}
  for _, attr in ipairs(attributes) do
    if attr == increased then
      -- Adding too much is not a problem, it gets clipped to 1.
      self.staff:changeAttribute(attr, incr_value)
      if self.staff:getAttribute(attr) == 1 then
        incr_value = 2.0 -- Doing 'increased' 100%, set other attributes to 0.
      end
    else
      decr_attrs[#decr_attrs + 1] = attr
      smallest_decr = math.min(smallest_decr, self.staff:getAttribute(attr))
    end
  end
  assert(#decr_attrs == 2)

  -- The decreasing attributes should together decrease '-incr_value', but one
  -- or both may be smaller than '-incr_value / 2'.
  -- Compensate by subtracting the biggest value from both.
  local decr_value = incr_value - smallest_decr
  for _, attr in ipairs(decr_attrs) do
    -- Subtracting too much is not a problem, it gets clipped to 0.
    self.staff:changeAttribute(attr, -decr_value)
  end
end

--! UI callback function to increase 'cleaning' (wiping litter).
function UIStaff:doMoreCleaning()
  self:changeHandymanAttributes("cleaning")
end

--! UI callback function to increase 'watering' (plants).
function UIStaff:doMoreWatering()
  self:changeHandymanAttributes("watering")
end

--! UI callback function to increase 'repairing' (machines).
function UIStaff:doMoreRepairing()
  self:changeHandymanAttributes("repairing")
end

function UIStaff:openStaffManagement()
  local dlg = UIStaffManagement(self.ui)
  -- Make sure that the dialog managed to create itself properly.
  -- For example, if using the demo files closed will be true because the dialog could not be loaded.
  if not dlg.closed then
    dlg:selectStaff(self.staff)
    self.ui:addWindow(dlg)
    self:close()
  end
end

function UIStaff:hitTest(x, y)
  return Window.hitTest(self, x, y) or is_in_view_circle(x, y, class.is(self.staff, Handyman))
end

function UIStaff:afterLoad(old, new)
  if old < 205 then
    self:close()
  end
  Window.afterLoad(self, old, new)
end
