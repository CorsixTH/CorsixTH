--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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

dofile "dialogs/fullscreen"

local math_floor = math.floor
    
class "UIStaffManagement" (UIFullscreen)

function UIStaffManagement:UIStaffManagement(ui, disease_selection)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  if not pcall(function()
    self.background = gfx:loadRaw("Staff01V", 640, 480)
    local palette = gfx:loadPalette("QData", "Staff01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    self.panel_sprites = gfx:loadSpriteTable("QData", "Staff02V", true, palette)
    self.title_font = gfx:loadFont("QData", "Font01V", false, palette)
    self.face_parts = ui.app.gfx:loadRaw("Face01V", 65, 1350, nil, "Data", "MPalette.dat")
  end) then
    ui:addWindow(UIInformation(ui, {_S.errors.dialog_missing_graphics}))
    self:close()
    return
  end
  
  local hosp = ui.hospital
  self.ui = ui
  self.hospital = hosp
  
  -- Order the staff
  local staff_members = {
    Doctor = {},
    Nurse = {},
    Handyman = {},
    Receptionist = {},
  }
  for _, staff in ipairs(hosp.staff) do
    staff_members[staff.humanoid_class][#staff_members[staff.humanoid_class] + 1] = staff
  end
  self.staff_members = staff_members
  
  self.default_button_sound = "selectx.wav"
  
  -- Close button
  self:addPanel(0, 603, 443):makeButton(0, 0, 26, 26, 10, self.close)
  
  -- Top categories
  local --[[persistable:staff_management_category]] function category(name, state, btn)
    self:setCategory(name)
  end
  self.categories = {
    self:addPanel(0, 53, 15):makeToggleButton(0, 0, 58, 58, 1, category, "Doctor"),
    self:addPanel(0, 119, 15):makeToggleButton(0, 0, 58, 58, 1, category, "Nurse"),
    self:addPanel(0, 185, 15):makeToggleButton(0, 0, 58, 58, 1, category, "Handyman"),
    self:addPanel(0, 251, 15):makeToggleButton(0, 0, 58, 58, 1, category, "Receptionist"),
  }
  -- Other buttons
  self:addPanel(0, 12, 86):makeButton(0, 0, 31, 74, 2, self.scrollUp)
  self:addPanel(0, 12, 274):makeButton(0, 0, 31, 74, 3, self.scrollDown)
  self:addPanel(0, 319, 372):makeButton(0, 0, 112, 39, 7, self.payBonus):setSound"cashreg.wav"
  self:addPanel(0, 319, 418):makeButton(0, 0, 112, 39, 8, self.increaseSalary):setSound"cashreg.wav"
  self:addPanel(0, 438, 372):makeButton(0, 0, 45, 85, 9, self.fire)
  
  -- "Arrow" to show title of doctors
  self.arrow = self:addPanel(12, 259, 397)
  self.arrow_position = 259
  self.arrow.visible = false
  
  -- Scroll bar dot
  self.scroll_dot = self:addPanel(11, 21, 168)
  self.scroll_dot.visible = false
  
  -- Doctors' skills or progress towards them
  self.progress_surgeon = self:addPanel(17, 188, 408)
  self.progress_surgeon.visible = false
  self.qualified_surgeon = self:addPanel(20, 188, 408)
  self.qualified_surgeon.visible = false
  self.progress_psychiatrist = self:addPanel(18, 228, 408)
  self.progress_psychiatrist.visible = false
  self.qualified_psychiatrist = self:addPanel(21, 228, 408)
  self.qualified_psychiatrist.visible = false
  self.progress_researcher = self:addPanel(19, 268, 408)
  self.progress_researcher.visible = false
  self.qualified_researcher = self:addPanel(22, 268, 408)
  self.qualified_researcher.visible = false
  
  -- Blankers for each row
  local row_blankers = {}
  local i
  for i = 1, 10 do
    row_blankers[i] = self:addColourPanel(50, 55 + i*27, 580, 27, 60, 174, 203)
  end
  self.row_blankers = row_blankers
  
  -- Extra background for the portrait
  self.portrait_back = self:addColourPanel(65, 374, 71, 81, 210, 255, 255)
  self.portrait_back.visible = false
  
  -- Doctor skill blankers
  self.title_blanker = self:addColourPanel(225, 365, 90, 39, 57, 166, 198)
  self.skill_blanker = self:addColourPanel(142, 406, 168, 54, 57, 166, 198)
  
  self:setCategory("Doctor")
end

function UIStaffManagement:setCategory(name)

  self.skill_blanker.visible = name ~= "Doctor"
  self.title_blanker.visible = name ~= "Doctor"
  self.category = name
  for i, btn in ipairs(self.categories) do
    local should_be_toggled = btn.on_click_self == name
    if btn.toggled ~= should_be_toggled then
      btn:toggle()
    end
  end
  self.selected_staff = nil
  self.page = 1
  if #self.staff_members[self.category] > 10 then
    self.scroll_dot.visible = true
    self.scroll_dot.y = 168
  else
    self.scroll_dot.visible = false
  end
end

function UIStaffManagement:draw(canvas, x, y)
  self.background:draw(canvas, self.x + x, self.y + y)
  UIFullscreen.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y
  local titles = self.title_font
  
  -- Titles
  titles:draw(canvas, _S.staff_list.morale,      x + 323, y + 31, 95, 0)
  titles:draw(canvas, _S.staff_list.tiredness,   x + 427, y + 31, 95, 0)
  titles:draw(canvas, _S.staff_list.skill,       x + 530, y + 31, 95, 0)
  
  -- Number of employees
  titles:draw(canvas, #self.staff_members["Doctor"], x + 79, y + 57)
  titles:draw(canvas, #self.staff_members["Nurse"], x + 145, y + 57)
  titles:draw(canvas, #self.staff_members["Handyman"], x + 211, y + 57)
  titles:draw(canvas, #self.staff_members["Receptionist"], x + 277, y + 57)
  
  local total_happiness = 0
  local total_fatigue = 0
  local total_skill = 0
  -- Draw each listing
  for i, staff in ipairs(self.staff_members[self.category]) do
    if not staff then
      break
    end
    -- Morale, tiredness and skill, used to draw the average at the end too.
    local happiness_bar_width = 0
    if staff.attributes["happiness"] then
      happiness_bar_width = math_floor(staff.attributes["happiness"] * 40 + 0.5)
      total_happiness = total_happiness + staff.attributes["happiness"]
    end
    local fatigue_bar_width = 40.5
    if staff.attributes["fatigue"] then
      total_fatigue = total_fatigue + staff.attributes["fatigue"]
      fatigue_bar_width = math_floor((1 - staff.attributes["fatigue"]) * 40 + 0.5)
    end
    local skill_bar_width = math_floor(staff.profile.skill * 40 + 0.5)
    total_skill = total_skill + staff.profile.skill
    -- Is this staff member on the visible page? Then draw him/her
    if i > (self.page-1)*10 and i <= self.page*10 then
      local row_no = i - (self.page-1)*10
      self.row_blankers[row_no].visible = false
      titles:draw(canvas, row_no + 10*(self.page-1), x + 58, y + 63 + row_no*27)
      titles:draw(canvas, staff.profile.name,        x + 88, y + 63 + row_no*27)
      titles:draw(canvas, "$" .. staff.profile.wage, x + 230, y + 63 + row_no*27, 80, 0)
    
      -- Draw the morale, tiredness and skill for this staff member
      if happiness_bar_width ~= 0 then
        for dx = 0, happiness_bar_width - 1 do
          self.panel_sprites:draw(canvas, 16, x + 351 + dx, y + 65 + row_no*27)
        end
      end
      if fatigue_bar_width ~= 0 then
        for dx = 0, fatigue_bar_width - 1 do
          self.panel_sprites:draw(canvas, 15, x + 456 + dx, y + 65 + row_no*27)
        end
      end
      if skill_bar_width ~= 0 then
        for dx = 0, skill_bar_width - 1 do
          self.panel_sprites:draw(canvas, 14, x + 559 + dx, y + 65 + row_no*27)
        end
      end
    end
  end
  -- Make sure the other ones are not visible
  for i = #self.staff_members[self.category] + 1 - (self.page-1)*10, 10 do
    self.row_blankers[i].visible = true
  end
  -- Draw the average morale, tiredness and skill
  local happiness_bar_width = math_floor((total_happiness/#self.staff_members[self.category]) * 40 + 0.5)
  if happiness_bar_width ~= 0 then
    for dx = 0, happiness_bar_width - 1 do
      self.panel_sprites:draw(canvas, 16, x + 351 + dx, y + 59)
    end
  end
  
  local fatigue_bar_width = math_floor((1 - (total_fatigue/#self.staff_members[self.category])) * 40 + 0.5)
  if fatigue_bar_width ~= 0 then
    for dx = 0, fatigue_bar_width - 1 do
      self.panel_sprites:draw(canvas, 15, x + 456 + dx, y + 59)
    end
  end
  local skill_bar_width = math_floor((total_skill/#self.staff_members[self.category]) * 40 + 0.5)
  if skill_bar_width ~= 0 then
    for dx = 0, skill_bar_width - 1 do
      self.panel_sprites:draw(canvas, 14, x + 559 + dx, y + 59)
    end
  end
  -- Reset
  self.progress_surgeon.visible = false
  self.qualified_surgeon.visible = false
  self.progress_psychiatrist.visible = false
  self.qualified_psychiatrist.visible = false
  self.progress_researcher.visible = false
  self.qualified_researcher.visible = false
  self.arrow.visible = false
  self.portrait_back.visible = false
  -- If a staff member is selected, draw picture, skill etc
  if self.selected_staff then
    local profile = self.staff_members[self.category][self.selected_staff].profile
    -- Draw the red rectangle TODO: Make a neater function in C?
    local red = canvas:mapRGB(221, 83, 0)
    local y_pos = self.selected_staff - (self.page - 1)*10
    canvas:drawRect(red, x + 49, y + y_pos*27 + 54, 581, 1)
    canvas:drawRect(red, x + 49, y + y_pos*27 + 81, 581, 1)
    canvas:drawRect(red, x + 49, y + y_pos*27 + 54, 1, 28)
    canvas:drawRect(red, x + 630, y + y_pos*27 + 54, 1, 28)

    -- Current position in the game world
    local px, py = self:getStaffPosition(37, 61)
    self.ui.app.map:draw(canvas, px, py, 83, 82, x + 497, y + 373)
    -- Portrait
    self.portrait_back.visible = true
    profile:drawFace(canvas, x + 68, y + 377, self.face_parts)
    
    -- 10 % increase in salary or a bonus:
    titles:draw(canvas, "$" .. math_floor(profile.wage*0.1), x + 377, y + 387, 45, 0)
    titles:draw(canvas, "$" .. math_floor(profile.wage*0.1 + profile.wage), x + 377, y + 432, 45, 0)
    
    -- Attention to detail
    local attention_bar_width = math_floor(profile.attention_to_detail * 40 + 0.5)
    if attention_bar_width ~= 0 then
      for dx = 0, attention_bar_width - 1 do
        self.panel_sprites:draw(canvas, 13, x + 178 + dx, y + 387)
      end
    end
    -- If it is a doctor, draw skills etc.
    if self.category == "Doctor" then
      if profile.is_surgeon > 0 then
        if profile.is_surgeon >= 1.0 then
          self.qualified_surgeon.visible = true
        else
          self.progress_surgeon.visible = true
          local progress = math_floor(profile.is_surgeon * 23 + 0.5)
          for dx = 0, progress - 1 do
            self.panel_sprites:draw(canvas, 13, x + 196 + dx, y + 447)
          end
        end
      end
      if profile.is_psychiatrist > 0 then
        if profile.is_psychiatrist >= 1.0 then
          self.qualified_psychiatrist.visible = true
        else
          self.progress_psychiatrist.visible = true
          local progress = math_floor(profile.is_psychiatrist * 23 + 0.5)
          for dx = 0, progress - 1 do
            self.panel_sprites:draw(canvas, 13, x + 236 + dx, y + 447)
          end
        end
      end
      if profile.is_researcher > 0 then
        if profile.is_researcher >= 1.0 then
          self.qualified_researcher.visible = true
        else
          self.progress_researcher.visible = true
          local progress = math_floor(profile.is_researcher * 23 + 0.5)
          for dx = 0, progress - 1 do
            self.panel_sprites:draw(canvas, 13, x + 276 + dx, y + 447)
          end
        end
      end
      -- Draw type of doctor
      self.arrow.visible = true
      if profile.is_consultant then
        self.arrow.x = self.arrow_position + 29
      elseif profile.is_junior then
        self.arrow.x = self.arrow_position - 23
      else
      self.arrow.x = self.arrow_position
      end
    end
  end
end

function UIStaffManagement:onMouseDown(code, x, y)
  if code == "left" then
    if x > 50 and x < 490 then
      if y > 82 and y < 351 then
        if #self.staff_members[self.category] - (self.page - 1)*10 > math_floor((y - 81)/27) then
          self.selected_staff = math_floor((y - 81)/27) + 1 + (self.page - 1)*10
        end
      end
    elseif x > 497 and x < 580 and y > 373 and y < 455 and self.selected_staff then
      -- Hit in the view of the staff
      local ui = self.ui
      ui:scrollMapTo(self:getStaffPosition())
    end
  end
  return UIFullscreen.onMouseDown(self, code, x, y)
end

function UIFullscreen:getStaffPosition(dx, dy)
  local staff = self.staff_members[self.category][self.selected_staff]
  local x, y = self.ui.app.map:WorldToScreen(staff.tile_x, staff.tile_y)
  local px, py = staff.th:getMarker()
  return x + px - (dx or 0), y + py - (dy or 0)
end

function UIStaffManagement:scrollUp()
  if self.scroll_dot.visible and self.page > 1 then
    self.selected_staff = nil
    self.page = self.page - 1
    self.scroll_dot.y = 168 + 83*((self.page - 1)/math.floor((#self.staff_members[self.category]-1)/10))
  end
end

function UIStaffManagement:scrollDown()
  if self.scroll_dot.visible and self.page*10 < #self.staff_members[self.category] then
    self.selected_staff = nil
    self.page = self.page + 1
    self.scroll_dot.y = 168 + 83*((self.page - 1)/math.floor((#self.staff_members[self.category]-1)/10))
  end
end

function UIStaffManagement:payBonus()
  if self.selected_staff then
    local staff = self.staff_members[self.category][self.selected_staff]
    staff:changeAttribute("Happiness", 0.3)
    self.hospital:spendMoney(math_floor(staff.profile.wage*0.1), _S.transactions.personal_bonus)
  end
end

function UIStaffManagement:increaseSalary()
  if self.selected_staff then
    local staff = self.staff_members[self.category][self.selected_staff]
    staff:increaseWage(math_floor(staff.profile.wage*0.1))
  end
end

function UIStaffManagement:fire()
  if self.selected_staff then
    local current_category = self.staff_members[self.category]
    current_category[self.selected_staff]:fire()
    -- Close the staff window if open
    local staff_window = self.ui:getWindow(UIStaff)
    if staff_window and staff_window.staff == current_category[self.selected_staff] then
      staff_window:close()
    end
    -- Update the staff list
    table.remove(current_category, self.selected_staff)
    self.selected_staff = nil
  end
end
