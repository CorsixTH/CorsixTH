--[[ Copyright (c) 2010 Edvin "Lego3" Linge

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

--! Progress Report fullscreen window (check level goals, competitors and alerts).
class "UIProgressReport" (UIFullscreen)

function UIProgressReport:UIProgressReport(ui)
  -- TODO: Refactor this file!
  self:UIFullscreen(ui)

  local world = self.ui.app.world
  local hospital = ui.hospital
  local gfx   = ui.app.gfx

  if not pcall(function()
    local palette   = gfx:loadPalette("QData", "Rep01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent

    self.background = gfx:loadRaw("Rep01V", 640, 480)
    self.red_font  = gfx:loadFont("QData", "Font101V", false, palette)
    self.normal_font = gfx:loadFont("QData", "Font100V", false, palette)
    self.small_font = gfx:loadFont("QData", "Font106V")
    self.panel_sprites = gfx:loadSpriteTable("QData", "Rep02V", true, palette)
  end) then
    ui:addWindow(UIInformation(ui, {_S.errors.dialog_missing_graphics}))
    self:close()
    return
  end
  
  self.default_button_sound = "selectx.wav"
  
  -- Selected hospital number
  self.selected = 1
  
  -- Get goals
  local active = world.goals

  -- Add the icons for the criteria
  local x = 263
  for i, tab in ipairs(active) do
    local crit_name = world.level_criteria[tab.criterion].name
    local str = _S.tooltip.status[crit_name]
    local res_value = active[crit_name].win_value
    active[crit_name].visible = true
    -- Special case for money, subtract loans
    local current = hospital[crit_name]
    if crit_name == "balance" then
      current = current - hospital.loan
    end
    if active[crit_name].lose_value then
      active[crit_name].red = false
      
      if current < active[crit_name].boundary then
        active[crit_name].red = true
        res_value = active[crit_name].lose_value
        -- TODO: Make the ugly workaround for the special case "percentage_killed" better
        if crit_name:find("killed") then
          res_value = nil
          active[crit_name].visible = false
        end
      elseif not active[crit_name].win_value then
        active[crit_name].visible = false
      end
    end
    -- Only five criteria can be there at once.
    if crit_name:find("killed") and world.winning_goal_count > 5 then
      res_value = nil
      active[crit_name].visible = false
    end
    if res_value then
      if world.level_criteria[tab.criterion].formats == 2 then
        str = _S.tooltip.status[crit_name]:format(res_value, current)
      else
        str = _S.tooltip.status[crit_name]:format(res_value)
      end
      self:addPanel(world.level_criteria[tab.criterion].icon, x, 240)
      self:makeTooltip(str, x, 180, x + 30, 180 + 90)
      x = x + 30
    end
  end
  self.criteria = active
  
  self:addPanel(0, 606, 447):makeButton(0, 0, 26, 26, 8, self.close):setTooltip(_S.tooltip.status.close)
  
  -- Own and competitor hospital buttons
  local function btn_handler(num)
    return --[[persistable:progress_report_hospital_button]] function()
      self.selected = num
    end
  end
  local function tooltip(num)
    return (num == 1) and _S.tooltip.status.win_progress_own or
      _S.tooltip.status.win_progress_other:format(world.hospitals[num].name) .. " " .. _S.misc.not_yet_implemented
  end
  local function make_hosp_button(num)
    self:addPanel(0, 265, 71 + (num - 1) * 25)
      :makeButton(0, 0, 147, 20, 9, btn_handler(num))
      :setTooltip(tooltip(num))
      :enable(num == 1)
  end
  
  for i = 1, math.min(#world.hospitals, 4) do
    make_hosp_button(i)
  end
  
  self:makeTooltip(_S.tooltip.status.population_chart .. " " .. _S.misc.not_yet_implemented, 433, 64, 578, 179)
  self:makeTooltip(_S.tooltip.status.happiness, 433, 179, 578, 209)
  self:makeTooltip(_S.tooltip.status.thirst, 433, 209, 578, 239)
  self:makeTooltip(_S.tooltip.status.warmth, 433, 239, 578, 270)
  
  self.warning = self:addPanel(7, 252, 295)
  self.warning.visible = false
  -- TODO: 6 gray
end

function UIProgressReport:close()
  UIFullscreen.close(self)
  self.ui:getWindow(UIBottomPanel):updateButtonStates()
end

function UIProgressReport:drawMarkers(canvas, x, y)
  local x_min = 455
  local x_max = 551
  local width = x_max - x_min
  local happiness = self.ui.hospital:getAveragePatientAttribute("happiness")
  local thirst = 1 - self.ui.hospital:getAveragePatientAttribute("thirst")
  local warmth = self.ui.hospital:getAveragePatientAttribute("warmth")
  local world = self.ui.app.world

  warmth = UIPatient.normaliseWarmth(warmth)
  self.panel_sprites:draw(canvas, 5, x + x_min + width * happiness, y + 193)
  self.panel_sprites:draw(canvas, 5, x + x_min + width * thirst, y + 223)
  self.panel_sprites:draw(canvas, 5, x + x_min + width * warmth, y + 254)
  
  if world.free_build_mode then
    self.normal_font:drawWrapped(canvas, _S.progress_report.free_build, x + 265, y + 194, 150, "center")
  end

  -- Possibly show warning that it's too cold, too hot, patients not happy 
  -- or if theres need to build drink machines as folks are thirsty.  Only show one at a time though!
  -- TODO the levels may need adjustment
  local msg = self.ui.hospital.show_progress_screen_warnings
  if warmth < 0.3 and msg == 1 then
    self.warning.visible = true
    self.normal_font:drawWrapped(canvas, _S.progress_report.too_cold, x + 285, y + 285, 285)
  elseif warmth > 0.7 and msg == 1 then
    self.warning.visible = true
    self.normal_font:drawWrapped(canvas, _S.progress_report.too_hot, x + 285, y + 285, 285)
  elseif thirst > 0.7 and msg == 2 then
    self.warning.visible = true
    self.normal_font:drawWrapped(canvas, _S.progress_report.more_drinks_machines, x + 285, y + 285, 285)
  elseif happiness < 0.8 and happiness >= 0.6 and msg == 3 then
    self.warning.visible = true
    self.normal_font:drawWrapped(canvas, _S.progress_report.quite_unhappy, x + 285, y + 285, 285)
  elseif happiness < 0.6 and msg == 3 then
    self.warning.visible = true
    self.normal_font:drawWrapped(canvas, _S.progress_report.very_unhappy, x + 285, y + 285, 285)
  else
    self.warning.visible = false
  end
end

function UIProgressReport:draw(canvas, x, y)
  self.background:draw(canvas, self.x + x, self.y + y)
  UIFullscreen.draw(self, canvas, x, y)
  
  x, y = self.x + x, self.y + y
  local app      = self.ui.app
  local hospital = self.ui.hospital
  local world    = hospital.world
  local active = self.criteria
  
  -- Names of the players playing
  local ly = 73
  for pnum, player in ipairs(world.hospitals) do
    local font = (pnum == self.selected) and self.red_font or self.normal_font
    font:draw(canvas, player.name:upper(), x + 272, y + ly)
    ly = ly + 25
  end
  
  -- Draw the vertical bars for the winning conditions
  local lx = 270
  for i, tab in ipairs(self.criteria) do
    local crit_name = world.level_criteria[tab.criterion].name
    if active[crit_name].visible then
      local sprite_offset = active[crit_name].red and 2 or 0
      local current = hospital[crit_name]
      -- Balance is special
      if crit_name == "balance" then
        current = current - hospital.loan
      end
      local height
      if active[crit_name].red then
        local lose = active[crit_name].lose_value
        height = 1 + 49*(1 - ((current - lose)/(active[crit_name].boundary - lose)))
      else
        height = 1 + 49*(current/active[crit_name].win_value)
      end
      if height > 50 then height = 50 end
      local result_y = 0
      for dy = 0, height - 1 do
        self.panel_sprites:draw(canvas, 1 + sprite_offset, x + lx, y + 237 - dy)
        result_y = result_y + 1
      end
      self.panel_sprites:draw(canvas, 2 + sprite_offset, x + lx, y + 237 - result_y)
      lx = lx + 30
    end
  end

  self:drawMarkers(canvas, x, y)
      
  self.normal_font:draw(canvas, _S.progress_report.header .. " " 
  .. (world.year + 1999), x + 227, y + 40, 400, 0)
  self.small_font:draw(canvas, _S.progress_report.win_criteria:upper(), x + 263, y + 172)
  self.small_font:draw(canvas, _S.progress_report.percentage_pop:upper() .. " " 
  .. (hospital.population*100) .. "%", x + 450, y + 65)
end
