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

dofile "dialogs/fullscreen"
local TH = require "TH"

--! Progress Report fullscreen window (check level goals, competitors and alerts).
class "UIProgressReport" (UIFullscreen)

-- List of which criteria means which, and what number the corresponding icon has.
local criterias = {
  {name = "reputation",       icon = 10, formats = 2}, 
  {name = "balance",          icon = 11, formats = 2}, 
  {name = "percentage_cured", icon = 12, formats = 2}, 
  {name = "num_cured" ,       icon = 13, formats = 2}, 
  {name = "percentage_killed",icon = 14, formats = 2}, 
  {name = "value",            icon = 15, formats = 2}, 
  {name = "population",       icon = 11, formats = 1},
}

function UIProgressReport:UIProgressReport(ui)
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
  
  -- Determine winning and losing conditions
  local win = world.map.level_config.win_criteria
  local lose = world.map.level_config.lose_criteria
  local active = {}
  local total = 0
  for _, values in pairs(win) do
    if values.Criteria ~= 0 then
      total = total + 1
      local criteria = criterias[values.Criteria].name
      active[criteria] = {
        win_value = values.Value, 
        boundary = values.Bound, 
        criteria = values.Criteria,
        number = total,
      }
      active[#active + 1] = active[criteria]
    end
  end
  for _, values in pairs(lose) do
    if values.Criteria ~= 0 then
      local criteria = criterias[values.Criteria].name
      if not active[criteria] then
        active[criteria] = {number = #active + 1}
        active[#active + 1] = active[criteria]
      end
      active[criteria].lose_value = values.Value
      active[criteria].boundary = values.Bound
      active[criteria].criteria = values.Criteria
      active[active[criteria].number].lose_value = values.Value
      active[active[criteria].number].boundary = values.Bound
      active[active[criteria].number].criteria = values.Criteria
    end
  end
  
  -- Order the criteria (some icons can't be next to each other)
  table.sort(active, function(a,b) return a.criteria < b.criteria end)

  -- Add the icons for the criteria
  local x = 263
  for i, tab in ipairs(active) do
    local crit = criterias[i].name
    local str = _S.tooltip.status[crit]
    local res_value = active[crit].win_value
    active[crit].visible = true
    if active[crit].lose_value then
      if hospital[crit] < active[crit].boundary then
        active[crit].red = true
        res_value = active[crit].lose_value
        -- TODO: Make the ugly workaround for the special case "percentage_killed" better
        if crit:find("killed") then
          res_value = nil
          active[crit].visible = false
        end
      elseif not active[crit].win_value then
        active[crit].visible = false
      end
    end
    -- Only five criteria can be there at once.
    if crit:find("killed") and total > 5 then
      res_value = nil
      active[crit].visible = false
    end
    if res_value then
      if criterias[tab.criteria].formats == 2 then
        str = _S.tooltip.status[crit]:format(res_value, hospital[crit])
      else
        str = _S.tooltip.status[crit]:format(res_value)
      end
      self:addPanel(criterias[i].icon, x, 240)
      self:makeTooltip(str, x, 180, x + 30, 180 + 90)
      x = x + 30
    end
  end
  self.criterias = active
  
  self:addPanel(0, 606, 447):makeButton(0, 0, 26, 26, 8, self.close)
  
  -- Add the three markers
  self.happiness_marker = self:addPanel(5, 503, 193)
  self.thirst_marker = self:addPanel(5, 503, 223)
  self.heat_marker = self:addPanel(5, 503, 254)
  -- TODO: 6 gray, 7 exclamation, 9 long bar

end

function UIProgressReport:close()
  Window.close(self)
end

function UIProgressReport:draw(canvas, x, y)
  self.background:draw(canvas, self.x + x, self.y + y)
  UIFullscreen.draw(self, canvas, x, y)
  
  x, y = self.x + x, self.y + y
  local app      = self.ui.app
  local hospital = self.ui.hospital
  local world    = hospital.world
  local active = self.criterias
  
  -- Names of the players playing
  local ly = 73
  for _, player in ipairs(world.hospitals) do
    -- TODO: Make them clickable for real
    if player.name == "PLAYER" then
      self.red_font:draw(canvas, player.name, x + 272, y + ly)
    else
      self.normal_font:draw(canvas, player.name, x + 272, y + ly)
    end
    ly = ly + 25
  end
  
  -- Draw the vertical bars for the winning conditions
  local lx = 270
  for i, tab in ipairs(self.criterias) do
    local criteria = criterias[i].name
    if active[criteria].visible then
      local sprite_offset = active[criteria].red and 2 or 0
      local modifier = 0
      local current = hospital[criteria]
      if active[criteria].red then
        local lose = active[criteria].lose_value
        modifier = 49*(1 - ((current - lose)/(active[criteria].boundary - lose)))
      else
        modifier = 49*(current/active[criteria].win_value)
      end
      local height = 1 + modifier
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
      
  self.normal_font:draw(canvas, _S.progress_report.header .. " " 
  .. (world.year + 1999), x + 227, y + 40, 400, 0)
  self.small_font:draw(canvas, _S.progress_report.win_criteria:upper(), x + 263, y + 172)
  self.small_font:draw(canvas, _S.progress_report.percentage_pop:upper() .. " " 
  .. (hospital.population*100) .. "%", x + 450, y + 65)
end
