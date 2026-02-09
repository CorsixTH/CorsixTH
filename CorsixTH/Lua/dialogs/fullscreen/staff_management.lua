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

local math_floor = math.floor

--! Staff management screen
class "UIStaffManagement" (UIFullscreen)

---@type UIStaffManagement
local UIStaffManagement = _G["UIStaffManagement"]

function UIStaffManagement:UIStaffManagement(ui)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  if not pcall(function()
    self.background = gfx:loadRaw("Staff01V", 640, 480, "QData", "QData", "Staff01V.pal", true)
    local palette = gfx:loadPalette("QData", "Staff01V.pal", true)
    self.panel_sprites = gfx:loadSpriteTable("QData", "Staff02V", true, palette)
    self.title_font = gfx:loadFontAndSpriteTable("QData", "Font01V", false, palette, { apply_ui_scale = true })
    self.blue_font = gfx:loadFontAndSpriteTable("QData", "Font02V", false, palette, { apply_ui_scale = true })
    self.face_parts = gfx:loadRaw("Face01V", 65, 1350, nil, "Data", "MPalette.dat", false, { flags = DrawFlags.Nearest })
  end) then
    ui:addWindow(UIInformation(ui, {_S.errors.dialog_missing_graphics}))
    self:close()
    return
  end

  local hosp = ui.hospital
  self.ui = ui
  self.hospital = hosp

  -- Order the staff
  self:updateStaffList()

  self.default_button_sound = "selectx.wav"
  self.hover_id = 0
  self.visual_hover_id = 0
  self.hover_sound = nil;


  -- Close button
  self:addPanel(0, 603, 443):makeButton(0, 0, 26, 26, 10, self.close):setTooltip(_S.tooltip.staff_list.close)

  -- Top categories
  local --[[persistable:staff_management_category]] function category(name)
    self:setCategory(name)
  end
  self.categories = {
    self:addPanel(0, 53, 15):makeToggleButton(0, 0, 58, 58, 1, category, "Doctor"):setTooltip(_S.tooltip.staff_list.doctors),
    self:addPanel(0, 119, 15):makeToggleButton(0, 0, 58, 58, 1, category, "Nurse"):setTooltip(_S.tooltip.staff_list.nurses),
    self:addPanel(0, 185, 15):makeToggleButton(0, 0, 58, 58, 1, category, "Handyman"):setTooltip(_S.tooltip.staff_list.handymen),
    self:addPanel(0, 251, 15):makeToggleButton(0, 0, 58, 58, 1, category, "Receptionist"):setTooltip(_S.tooltip.staff_list.receptionists),
  }
  -- Other buttons
  self:addPanel(0, 12, 86):makeButton(0, 0, 31, 74, 2, self.scrollUp):setTooltip(_S.tooltip.staff_list.prev_person)
  self:addPanel(0, 12, 274):makeButton(0, 0, 31, 74, 3, self.scrollDown):setTooltip(_S.tooltip.staff_list.next_person)
  -- Disable the default sounds on the the following three buttons as their sounds are implemented in the callback.
  self:addPanel(0, 319, 372):makeButton(0, 0, 112, 39, 7, self.payBonus):setTooltip(_S.tooltip.staff_list.bonus):setSound()
  self:addPanel(0, 319, 418):makeButton(0, 0, 112, 39, 8, self.increaseSalary):setTooltip(_S.tooltip.staff_list.pay_rise):setSound()
  self:addPanel(0, 438, 372):makeButton(0, 0, 45, 85, 9, self.fire):setTooltip(_S.tooltip.staff_list.sack):setSound()

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
  self.qualified_surgeon = self:addPanel(20, 188, 408):setTooltip(_S.tooltip.staff_list.surgeon)
  self.qualified_surgeon.visible = false
  self.progress_psychiatrist = self:addPanel(18, 228, 408)
  self.progress_psychiatrist.visible = false
  self.qualified_psychiatrist = self:addPanel(21, 228, 408):setTooltip(_S.tooltip.staff_list.psychiatrist)
  self.qualified_psychiatrist.visible = false
  self.progress_researcher = self:addPanel(19, 268, 408)
  self.progress_researcher.visible = false
  self.qualified_researcher = self:addPanel(22, 268, 408):setTooltip(_S.tooltip.staff_list.researcher)
  self.qualified_researcher.visible = false

  -- Blankers for each row
  local row_blankers = {}
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

  -- Tooltip regions
  self:makeTooltip(_S.tooltip.staff_list.happiness,  321, 51, 421, 75)
  self:makeTooltip(_S.tooltip.staff_list.tiredness,  426, 51, 526, 75)
  self:makeTooltip(_S.tooltip.staff_list.ability,    530, 51, 629, 75)
  self:makeTooltip(_S.tooltip.staff_list.detail,     146, 367, 226, 407)
  self:makeTooltip(_S.tooltip.staff_list.view_staff, 495, 371, 583, 458)

  self.row_tooltips = {}
  for line_num = 1, 10 do
    self.row_tooltips[line_num] = {
      self:makeTooltip(_S.tooltip.staff_list.salary,      193, 84 + 27 * (line_num - 1), 313, 108 + 27 * (line_num - 1)),
      self:makeTooltip(_S.tooltip.staff_list.happiness_2, 321, 84 + 27 * (line_num - 1), 421, 108 + 27 * (line_num - 1)),
      self:makeTooltip(_S.tooltip.staff_list.tiredness_2, 425, 84 + 27 * (line_num - 1), 525, 108 + 27 * (line_num - 1)),
      self:makeTooltip(_S.tooltip.staff_list.ability_2,   529, 84 + 27 * (line_num - 1), 628, 108 + 27 * (line_num - 1)),
    }
  end

  self.seniority_tooltip =
    self:makeTooltip(_S.tooltip.staff_list.doctor_seniority, 230, 367, 310, 407)
  self.skills_tooltip =
    self:makeTooltip(_S.tooltip.staff_list.skills, 146, 406, 186, 460)

  self:setCategory("Doctor")

  self:registerKeyHandlers()
end

function UIStaffManagement:registerKeyHandlers()
  -- Hotkeys.
  self:addKeyHandler("ingame_scroll_left", self.previousCategory)
  self:addKeyHandler("ingame_scroll_right", self.nextCategory)
  self:addKeyHandler("ingame_scroll_up", self.previousStaff)
  self:addKeyHandler("ingame_scroll_down", self.nextStaff)
end

function UIStaffManagement:updateTooltips()
  self.seniority_tooltip.enabled = self.category == "Doctor"
  self.skills_tooltip.enabled = self.category == "Doctor"

  for i, tooltips in ipairs(self.row_tooltips) do
    local state = 10 * (self.page - 1) + i <= #self.staff_members[self.category]
    for _, tooltip in ipairs(tooltips) do
      tooltip.enabled = state
    end
  end
end

function UIStaffManagement:updateStaffList(staff_member_removed)
  local selected_staff
  if staff_member_removed then
    -- The update was issued because someone was removed from the list, we need to handle this.
    selected_staff = self.staff_members[self.category][self.selected_staff]
    if self.staff_members[self.category][self.selected_staff] == staff_member_removed then
      self.selected_staff = nil
      selected_staff = nil
    end
  end

  local hosp = self.hospital
  local staff_members = {
    Doctor = {},
    Nurse = {},
    Handyman = {},
    Receptionist = {},
  }
  for i, staff in ipairs(hosp.staff) do
    staff.hire_order = i
    local list = staff_members[staff.profile.humanoid_class]
    list[#list + 1] = staff
    -- The selected staff might have been moved because someone else was removed from the list.
    if selected_staff == staff then
      self.selected_staff = #list
    end
  end
  -- Sort staff tables by attribute and direction
  for _, staff_tbl in pairs(staff_members) do
  if self.list_direction == "up" then
    if self.list_order == "hire" then
      table.sort(staff_tbl, function(a, b) return a.hire_order > b.hire_order end)
    elseif self.list_order == "morale" then
      table.sort(staff_tbl, function(a, b) return a:getAttribute("happiness") > b:getAttribute("happiness") end)
    elseif self.list_order == "tiredness" then
      table.sort(staff_tbl, function(a, b) return a:getAttribute("fatigue") > b:getAttribute("fatigue") end)
    elseif self.list_order == "skill" then
      table.sort(staff_tbl, function(a, b) return a.profile.skill > b.profile.skill end)
    end
  else
    if self.list_order == "hire" then
      table.sort(staff_tbl, function(a, b) return a.hire_order < b.hire_order end)
    elseif self.list_order == "morale" then
      table.sort(staff_tbl, function(a, b) return a:getAttribute("happiness") < b:getAttribute("happiness") end)
    elseif self.list_order == "tiredness" then
      table.sort(staff_tbl, function(a, b) return a:getAttribute("fatigue") < b:getAttribute("fatigue") end)
    elseif self.list_order == "skill" then
      table.sort(staff_tbl, function(a, b) return a.profile.skill < b.profile.skill end)
    end
  end
  end
  self.staff_members = staff_members
  if staff_member_removed then
    self:updateTooltips()
    -- If we're viewing a page that no longer exists, go back a page
    if self.page > math.ceil(#self.staff_members[self.category] / 10) then
      self:scrollUp()
    end
    self:updateScrollDotVisibility()
  end
end

function UIStaffManagement:setCategory(name)

  self.skill_blanker.visible = name ~= "Doctor"
  self.title_blanker.visible = name ~= "Doctor"
  self.category = name
  for _, btn in ipairs(self.categories) do
    local should_be_toggled = btn.on_click_self == name
    if btn.toggled ~= should_be_toggled then
      btn:toggle()
    end
  end
  self.selected_staff = nil
  self.page = 1
  self:updateScrollDotVisibility()

  self:updateTooltips()
end

-- Function to select given list index in the current category.
-- Includes jumping to correct page.
function UIStaffManagement:selectIndex(idx)
  if idx > #self.staff_members[self.category] or idx <= 0 then
    return
  end
  self.page = math.floor((idx - 1) / 10) + 1
  self.selected_staff = idx
end

-- Function to select a given staff member.
-- Includes switching to correct category and page.
function UIStaffManagement:selectStaff(staff)
  self:setCategory(staff.profile.humanoid_class)
  for i, s in ipairs(self.staff_members[self.category]) do
    if s == staff then
      self:selectIndex(i)
      break
    end
  end
end

function UIStaffManagement:draw(canvas, x, y)
  local s = TheApp.config.ui_scale
  canvas:scale(s, "bitmap")
  self.background:draw(canvas, self.x * s + x, self.y * s + y)
  canvas:scale(1, "bitmap")
  UIFullscreen.draw(self, canvas, x, y)
  x, y = self.x * s + x, self.y * s + y
  local titles = self.title_font

  -- Titles
  local ty = y + 31 * s
  local tw = 95 * s
  titles:draw(canvas, _S.staff_list.morale,      x + 323 * s, ty, tw, 0)
  titles:draw(canvas, _S.staff_list.tiredness,   x + 427 * s, ty, tw, 0)
  titles:draw(canvas, _S.staff_list.skill,       x + 530 * s, ty, tw, 0)

  -- Number of employees
  local ney = y + 57 * s
  titles:draw(canvas, #self.staff_members["Doctor"], x + 79 * s, ney)
  titles:draw(canvas, #self.staff_members["Nurse"], x + 145 * s, ney)
  titles:draw(canvas, #self.staff_members["Handyman"], x + 211 * s, ney)
  titles:draw(canvas, #self.staff_members["Receptionist"], x + 277 * s, ney)

  local total_happiness = 0
  local total_fatigue = 0
  local total_skill = 0
  -- Draw each listing
  local staff_list = self.staff_members[self.category]
  for i, staff in ipairs(staff_list) do
    if not staff then
      break
    end
    -- Morale, tiredness and skill, used to draw the average at the end too.
    local happiness_bar_width = 0
    if staff:getAttribute("happiness") then
      happiness_bar_width = math_floor(staff:getAttribute("happiness") * 40 * s + 0.5)
      total_happiness = total_happiness + staff:getAttribute("happiness")
    end
    local fatigue_bar_width = 40.5 * s
    if staff:getAttribute("fatigue") then
      total_fatigue = total_fatigue + staff:getAttribute("fatigue")
      fatigue_bar_width = math_floor((1 - staff:getAttribute("fatigue")) * 40 * s + 0.5)
    end
    local skill_bar_width = math_floor(staff.profile.skill * 40 * s + 0.5)
    total_skill = total_skill + staff.profile.skill
    -- Is this staff member on the visible page? Then draw him/her
    if i > (self.page-1)*10 and i <= self.page*10 then
      local row_no = i - (self.page-1)*10
      self.row_blankers[row_no].visible = false
      titles:draw(canvas, row_no + 10*(self.page-1), x + 58 * s, y + 63 * s + row_no * 27 * s)
      local font = self.title_font
      if i == self.visual_hover_id then
        font = self.blue_font
      end
      local row_y = y + 63 * s + row_no * 27 * s
      font:draw(canvas, staff.profile:getFullName(),
          x + 88 * s, row_y)
      font:draw(canvas, "$" .. staff.profile.wage, x + 230 * s, row_y, 80 * s, 0)

      -- Draw the morale, tiredness and skill for this staff member
      if happiness_bar_width ~= 0 then
        for dx = 0, happiness_bar_width - 1 do
          self.panel_sprites:draw(canvas, 16, x + 351 * s + dx, row_y + 2 * s, { scaleFactor = s })
        end
      end
      if fatigue_bar_width ~= 0 then
        for dx = 0, fatigue_bar_width - 1 do
          self.panel_sprites:draw(canvas, 15, x + 456 * s + dx, row_y + 2 * s, { scaleFactor = s })
        end
      end
      if skill_bar_width ~= 0 then
        for dx = 0, skill_bar_width - 1 do
          self.panel_sprites:draw(canvas, 14, x + 559 * s + dx, row_y + 2 * s, { scaleFactor = s })
        end
      end
    end
  end

  -- Make sure the other ones are not visible
  for i = #staff_list + 1 - (self.page-1)*10, 10 do
    self.row_blankers[i].visible = true
  end
  -- Draw the average morale, tiredness and skill
  if #staff_list ~= 0 then
    local happiness_bar_width = math_floor((total_happiness/#staff_list) * 40 * s + 0.5)
    if happiness_bar_width ~= 0 then
      for dx = 0, happiness_bar_width - 1 do
        self.panel_sprites:draw(canvas, 16, x + 351 * s + dx, y + 59 * s, { scaleFactor = s })
      end
    end

    local fatigue_bar_width = math_floor((1 - (total_fatigue/#staff_list)) * 40 * s + 0.5)
    if fatigue_bar_width ~= 0 then
      for dx = 0, fatigue_bar_width - 1 do
        self.panel_sprites:draw(canvas, 15, x + 456 * s + dx, y + 59 * s, { scaleFactor = s })
      end
    end
    local skill_bar_width = math_floor((total_skill/#staff_list) * 40 + 0.5)
    if skill_bar_width ~= 0 then
      for dx = 0, skill_bar_width - 1 do
        self.panel_sprites:draw(canvas, 14, x + 559 * s + dx, y + 59 * s, { scaleFactor = s })
      end
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
    local staff = self.staff_members[self.category][self.selected_staff]
    local profile = staff.profile
    -- Draw the red rectangle TODO: Make a neater function in C?
    local red = canvas:mapRGB(221, 83, 0)
    local y_pos = self.selected_staff - (self.page - 1)*10
    canvas:drawRect(red, x + 49 * s, y + y_pos * 27 * s + 54 * s, 581 * s, s)
    canvas:drawRect(red, x + 49 * s, y + y_pos * 27 * s + 81 * s, 581 * s, s)
    canvas:drawRect(red, x + 49 * s, y + y_pos * 27 * s + 54 * s, s, 28 * s)
    canvas:drawRect(red, x + 630 * s, y + y_pos * 27 * s + 54 * s, s, 28 * s)

    -- Current position in the game world
    local px, py = self:getStaffPosition(37, 61)
    canvas:scale(s)
    self.ui.app.map:draw(canvas, px, py, 83, 82, math.floor(x / s) + 497, math.floor(y / s) + 373)
    canvas:scale(1)
    -- Portrait
    self.portrait_back.visible = true
    profile:drawFace(canvas, x + 68 * s, y + 377 * s, self.face_parts, s)

    -- 10 % increase in salary or a bonus:
    local max_salary = self.hospital.world.map.level_config.payroll.MaxSalary
    local new_salary = math.min(math.floor(profile.wage * 1.1), max_salary)
    titles:draw(canvas, "$" .. math_floor(profile.wage*0.1), x + 377 * s, y + 387 * s, 45 * s, 0)
    titles:draw(canvas, "$" .. new_salary, x + 377 * s, y + 432 * s, 45 * s, 0)

    -- Attention to detail
    local attention_bar_width = math_floor(profile.attention_to_detail * 40 * s + 0.5)
    if attention_bar_width ~= 0 then
      for dx = 0, attention_bar_width - 1 do
        self.panel_sprites:draw(canvas, 13, x + 178 * s + dx, y + 387 * s, { scaleFactor = s })
      end
    end
    -- If it is a doctor, draw skills etc.
    if self.category == "Doctor" then
      if profile.is_surgeon > 0 then
        if profile.is_surgeon >= 1.0 then
          self.qualified_surgeon.visible = true
        elseif not profile.is_consultant then
          self.progress_surgeon.visible = true
          self.progress_surgeon:setTooltip(_S.tooltip.staff_list.surgeon_train:format(math_floor(profile.is_surgeon * 100)))
          local progress = math_floor(profile.is_surgeon * 23 * s + 0.5)
          for dx = 0, progress - 1 do
            self.panel_sprites:draw(canvas, 13, x + 196 * s + dx, y + 447 * s, { scaleFactor = s })
          end
        end
      end
      if profile.is_psychiatrist > 0 then
        if profile.is_psychiatrist >= 1.0 then
          self.qualified_psychiatrist.visible = true
        elseif not profile.is_consultant then
          self.progress_psychiatrist.visible = true
          self.progress_psychiatrist:setTooltip(_S.tooltip.staff_list.psychiatrist_train:format(math_floor(profile.is_psychiatrist * 100)))
          local progress = math_floor(profile.is_psychiatrist * 23 * s + 0.5)
          for dx = 0, progress - 1 do
            self.panel_sprites:draw(canvas, 13, x + 236 * s + dx, y + 447 * s, { scaleFactor = s })
          end
        end
      end
      if profile.is_researcher > 0 then
        if profile.is_researcher >= 1.0 then
          self.qualified_researcher.visible = true
        elseif not profile.is_consultant then
          self.progress_researcher.visible = true
          self.progress_researcher:setTooltip(_S.tooltip.staff_list.researcher_train:format(math_floor(profile.is_researcher * 100)))
          local progress = math_floor(profile.is_researcher * 23 * s + 0.5)
          for dx = 0, progress - 1 do
            self.panel_sprites:draw(canvas, 13, x + 276 * s + dx, y + 447 * s, { scaleFactor = s })
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
    local s = TheApp.config.ui_scale
    local inside_staff_list_area = (x > 50 * s and x < 624 * s) and (y > 82 * s and y < 351 * s)
    local inside_header_area = (x > 321 * s and x < 629 * s) and (y > 22 * s and y < 46 * s)
    if inside_staff_list_area then
      -- Hit staff row
      if #self.staff_members[self.category] - (self.page - 1)*10 > math_floor((y - 81 * s)/(27 * s)) then
        self.selected_staff = math_floor((y - 81 * s)/(27 * s)) + 1 + (self.page - 1)*10
        TheApp.audio:playSound("selectx.wav")
      end
    elseif inside_header_area then
      local function order_by(attribute)
        if self.list_order == attribute then -- Change direction
          if not self.list_direction or self.list_direction == "down" then
            self.list_direction = "up"
          else
            self.list_order = "hire"
            self.list_direction = "down"
          end
        else
          self.list_order = attribute -- Switch order attribute
        end
        self:updateStaffList()
      end
      if x < 422 * s then order_by("morale")
      elseif x > 425 * s and x < 527 * s then order_by("tiredness")
      elseif x > 529 * s then order_by("skill")
      end
    else
      local inside_view_of_the_staff_area = (x > 497 * s and x < 580 * s) and (y > 373 * s and y < 455 * s)
      if inside_view_of_the_staff_area and self.selected_staff then
        return false -- on false window dragging won't work
      end
    end
  end
  return UIFullscreen.onMouseDown(self, code, x, y)
end

function UIStaffManagement:onMouseMove(x, y, dx, dy)
  local s = TheApp.config.ui_scale
  local current_hover_id
  local inside_staff_list_area
  local header_height = 81 * s
  local row_height = 27 * s
  local active_hover_id = math_floor((y - header_height)/row_height)
  if self.page*10 > #self.staff_members[self.category] then
    -- Make sure area contains no hollow space
    inside_staff_list_area = (x > 50 * s and x < 624 * s) and
    (y > header_height and y < header_height + row_height * (#self.staff_members[self.category] % 10))
  else
    inside_staff_list_area = (x > 50 * s and x < 624 * s) and (y > header_height and y < 351 * s)
  end

  if inside_staff_list_area then
    if #self.staff_members[self.category] - (self.page - 1)*10 > active_hover_id then
      current_hover_id = active_hover_id + 1 + (self.page - 1)*10
      if self.hover_id ~= current_hover_id then
        if self.hover_sound then
          self.ui:stopSound(self.hover_sound)
        end
        self.hover_sound = self.ui:playSound("Hlight5.wav")
        self.hover_id = current_hover_id
        self.visual_hover_id = current_hover_id
      end
    end
  else
    self.hover_id = nil
    self.visual_hover_id = nil
  end
  return Window:onMouseMove(x, y, dx, dy)
end

function UIStaffManagement:onMouseUp(code, x, y)
  if code == "left" then
    local s = TheApp.config.ui_scale
    local inside_view_of_the_staff_area = (x > 497 * s and x < 580 * s) and (y > 373 * s and y < 455 * s)
    if inside_view_of_the_staff_area and self.selected_staff then
      -- Hit in the view of the staff.
      local ui = self.ui
      ui:scrollMapTo(self:getStaffPosition())
      ui:addWindow(UIStaff(ui, self.staff_members[self.category][self.selected_staff]))
      self:close()
    end
  end
  return UIFullscreen.onMouseUp(self, code, x, y)
end

function UIStaffManagement:onMouseWheel(x, y)
  if not UIFullscreen.onMouseWheel(self, x, y) then
    if self:hitTest(self.cursor_x, self.cursor_y) then
      if y > 0 then
        self:scrollUp()
        return true
      else
        self:scrollDown()
        return true
      end
    end
    return false
  else
    return true
  end
end

function UIFullscreen:getStaffPosition(dx, dy)
  local staff = self.staff_members[self.category][self.selected_staff]
  local x, y = self.ui.app.map:WorldToScreen(staff.tile_x, staff.tile_y)
  local px, py = staff.th:getSecondaryMarker()
  return x + px - (dx or 0), y + py - (dy or 0)
end

function UIStaffManagement:previousCategory()
  if self.category == "Nurse" then
    self:setCategory("Doctor")
  elseif self.category == "Handyman" then
    self:setCategory("Nurse")
  elseif self.category == "Receptionist" then
    self:setCategory("Handyman")
  end
end

function UIStaffManagement:nextCategory()
  if self.category == "Doctor" then
    self:setCategory("Nurse")
  elseif self.category == "Nurse" then
    self:setCategory("Handyman")
  elseif self.category == "Handyman" then
    self:setCategory("Receptionist")
  end
end

function UIStaffManagement:previousStaff()
  -- If nothing currently selected, select the last one, otherwise the previous.
  if self.selected_staff == nil then
    self:selectIndex(#self.staff_members[self.category])
  else
    self:selectIndex(self.selected_staff - 1)
  end
end

function UIStaffManagement:nextStaff()
  -- If nothing currently selected, select the first one, otherwise the next.
  if self.selected_staff == nil then
    self:selectIndex(1)
  else
    self:selectIndex(self.selected_staff + 1)
  end
end

function UIStaffManagement:scrollUp()
  if self.scroll_dot.visible and self.page > 1 then
    self.selected_staff = nil
    self.page = self.page - 1
    self:updateScrollDot()
  end
  self:updateTooltips()
end

function UIStaffManagement:scrollDown()
  if self.scroll_dot.visible and self.page*10 < #self.staff_members[self.category] then
    self.selected_staff = nil
    self.page = self.page + 1
    self:updateScrollDot()
  end
  self:updateTooltips()
end

--! Updates the position of the paging scroll indicator
function UIStaffManagement:updateScrollDot()
  local numPages = math.ceil(#self.staff_members[self.category] / 10)
  local yOffset = math_floor(83 * ((self.page - 1) / (numPages - 1)))
  self.scroll_dot.y = 168 + yOffset
end

--! Updates whether the paging scroll indicator is visible and its position if visible
function UIStaffManagement:updateScrollDotVisibility()
  if #self.staff_members[self.category] > 10 then
    self.scroll_dot.visible = true
    self:updateScrollDot()
  else
    self.scroll_dot.visible = false
  end
end

function UIStaffManagement:payBonus()
  local staff = self.staff_members[self.category][self.selected_staff]
  if self.selected_staff and self.hospital.balance > math_floor(staff.profile.wage*0.1) then
    staff:changeAttribute("happiness", 0.5)
    self.hospital:spendMoney(math_floor(staff.profile.wage*0.1), _S.transactions.personal_bonus)
    self.ui:playSound("cashreg.wav")
    return
  end
  self.ui:playSound("wrong2.wav")
end

function UIStaffManagement:increaseSalary()
  if self.selected_staff then
    local staff = self.staff_members[self.category][self.selected_staff]
    if staff:increaseWage(math_floor(staff.profile.wage * 0.1)) then
      return
    end
  end
  self.ui:playSound("wrong2.wav")
end

function UIStaffManagement:fire()
  if self.selected_staff then
    self.ui:playSound(self.default_button_sound)
    self.ui:addWindow(UIConfirmDialog(self.ui, false, _S.confirmation.sack_staff, --[[persistable:staff_management_confirm_sack]] function()
      local current_category = self.staff_members[self.category]
      current_category[self.selected_staff]:fire()
      -- Close the staff window if open
      local staff_window = self.ui:getWindow(UIStaff)
      if staff_window and staff_window.staff == current_category[self.selected_staff] then
        staff_window:close()
      end
      -- Update the staff list
      self:updateStaffList(current_category[self.selected_staff])
    end)) -- End of confirmation dialog
  else
    self.ui:playSound("wrong2.wav")
  end
end

function UIStaffManagement:close()
  UIFullscreen.close(self)
  self.ui:getWindow(UIBottomPanel):updateButtonStates()
end

function UIStaffManagement:afterLoad(old, new)
  self:registerKeyHandlers()

  if old < 175 then
    self:close()
  end
  if old < 236 then
    local gfx = TheApp.gfx
    self.background = gfx:loadRaw("Staff01V", 640, 480, "QData", "QData", "Staff01V.pal", true)
    local palette = gfx:loadPalette("QData", "Staff01V.pal", true)
    self.panel_sprites = gfx:loadSpriteTable("QData", "Staff02V", true, palette, { apply_ui_scale = true })
    self.title_font = gfx:loadFontAndSpriteTable("QData", "Font01V", false, palette, { apply_ui_scale = true })
    self.face_parts = gfx:loadRaw("Face01V", 65, 1350, nil, "Data", "MPalette.dat", false, { flags = DrawFlags.Nearest })
  end

  UIFullscreen.afterLoad(self, old, new)
end
