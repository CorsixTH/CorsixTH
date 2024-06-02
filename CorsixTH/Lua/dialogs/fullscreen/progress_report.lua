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

--! Progress Report fullscreen window (check level goals, competitors and alerts).
class "UIProgressReport" (UIFullscreen)

---@type UIProgressReport
local UIProgressReport = _G["UIProgressReport"]

function UIProgressReport:UIProgressReport(ui)
  self:UIFullscreen(ui)

  local world = self.ui.app.world
  local gfx   = ui.app.gfx

  if not pcall(function()
    local palette = gfx:loadPalette("QData", "Rep01V.pal", true)

    self.background = gfx:loadRaw("Rep01V", 640, 480, "QData", "QData", "Rep01V.pal", true)
    self.red_font = gfx:loadFont("QData", "Font101V", false, palette)
    self.normal_font = gfx:loadFont("QData", "Font100V", false, palette)
    self.small_font = gfx:loadFont("QData", "Font106V")
    -- Load all sprite tables needed for all goal icons
    self.panel_sprites_table = {
      MPointer = gfx:loadSpriteTable("Data", "MPointer"),
      Rep02V = gfx:loadSpriteTable("QData", "Rep02V", true, palette)
    }
    self.panel_sprites = self.panel_sprites_table.Rep02V -- The default goals icons
  end) then
    ui:addWindow(UIInformation(ui, {_S.errors.dialog_missing_graphics}))
    self:close()
    return
  end

  self.default_button_sound = "selectx.wav"

  -- Selected hospital number
  self.selected = 1
  local hospital = world.hospitals[self.selected]

  -- Collect which criteria to show here, draw columns in draw
  -- Add the icons for the criteria
  local x = 263
  local crit_data = world.endconditions:generateReportTable(hospital)
  for _, crit_table in ipairs(crit_data) do
    crit_table.visible = true
    local crit_name = crit_table.name
    local res_value = crit_table.win_value
    local cur_value = world.endconditions:getAttribute(hospital, crit_name)
    if crit_table.lose_value then
      crit_table.red = true
      res_value = crit_table.lose_value
    end
    -- FIXME: res_value and cure_value are depersisted as floating points, using
    -- string.format("%.0f", x) is not suitable due to %d (num) param in _S string
    local tooltip
    if crit_table.formats == 2 then
      tooltip = _S.tooltip.status[crit_name]:format(math.floor(res_value), math.floor(cur_value))
    else
      tooltip = _S.tooltip.status[crit_name]:format(math.floor(res_value))
    end
    if not crit_table.icon_file then -- Icons from QData/Rep02V
      self:addPanel(crit_table.icon, x, 240)
    end
    self:makeTooltip(tooltip, x, 180, x + 30, 180 + 90)
    x = x + 30
  end
  self.crit_data = crit_data

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
  local happiness = self.ui.hospital:getAveragePatientAttribute("happiness", 0.5)
  local thirst = 1 - self.ui.hospital:getAveragePatientAttribute("thirst", 0.5)
  local warmth = self.ui.hospital:getAveragePatientAttribute("warmth", nil)
  warmth = UIPatient.normaliseWarmth(warmth)

  self.panel_sprites:draw(canvas, 5, math.floor(x + x_min + width * happiness), y + 193)
  self.panel_sprites:draw(canvas, 5, math.floor(x + x_min + width * thirst), y + 223)
  self.panel_sprites:draw(canvas, 5, math.floor(x + x_min + width * warmth), y + 254)

  local world = self.ui.app.world
  if world.free_build_mode then
    self.normal_font:drawWrapped(canvas, _S.progress_report.free_build, x + 265, y + 194, 150, "center")
  end

  -- Possibly show warning that it's too cold, too hot, patients not happy
  -- or if there's need to build drink machines as folks are thirsty.  Only show one at a time though!
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
  local world    = self.ui.app.world
  local hospital = world.hospitals[self.selected]

  -- Names of the players playing
  local ly = 73
  for pnum, player in ipairs(world.hospitals) do
    local font = (pnum == self.selected) and self.red_font or self.normal_font
    font:draw(canvas, player.name:upper(), x + 272, y + ly)
    ly = ly + 25
  end

  -- Draw the vertical bars for the selected conditions
  local lx = 270
  for _, crit_table in ipairs(self.crit_data) do
    if crit_table.visible then
      local sprite_offset = crit_table.red and 2 or 0
      local crit_name = crit_table.name
      local cur_value = world.endconditions:getAttribute(hospital, crit_name)
      local height
      if crit_table.red then
        local lose = crit_table.lose_value
        height = 1 + 49 * (1 - ((cur_value - lose)/(crit_table.boundary - lose)))
      else
        height = 1 + 49 * (cur_value/crit_table.win_value)
      end
      if height > 50 then height = 50 end
      local result_y = 0
      for dy = 0, height - 1 do
        self.panel_sprites:draw(canvas, 1 + sprite_offset, x + lx, y + 237 - dy)
        result_y = result_y + 1
      end
      self.panel_sprites:draw(canvas, 2 + sprite_offset, x + lx, y + 237 - result_y)
      if crit_table.icon_file then -- Icons not from QData/Rep02V
        local icon_sprites = self.panel_sprites_table[crit_table.icon_file]
        icon_sprites:draw(canvas, crit_table.icon, x + lx, y + 240)
      end
      lx = lx + 30
    end
  end

  self:drawMarkers(canvas, x, y)

  self.normal_font:draw(canvas, _S.progress_report.header .. " " ..
      (world:date():year() + 1999), x + 227, y + 40, 400, 0)
  self.small_font:draw(canvas, _S.progress_report.win_criteria:upper(), x + 263, y + 172)
  self.small_font:draw(canvas, _S.progress_report.percentage_pop:upper() .. " " ..
      (hospital.population * 100) .. "%", x + 450, y + 65)
end

function UIProgressReport:afterLoad(old, new)
  if old < 188 then
    self:close()
  end

  UIFullscreen.afterLoad(self, old, new)
end
