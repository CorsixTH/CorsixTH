--[[ Copyright (c) 2011 Ted "IntelOrca" John
                   2013 Edvin "Lego3" Linge

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

--! Charts fullscreen window
class "UIGraphs" (UIFullscreen)

---@type UIGraphs
local UIGraphs = _G["UIGraphs"]

local TH = require "TH"

-- These values are based on the background colours of the pen symbols
local colours = {
  money_in = {182, 32, 16},
  money_out = {215, 81, 8},
  wages = {194, 162, 0},
  balance = {28, 138, 36},
  visitors = {0, 101, 198},
  cures = {36, 40, 154},
  deaths = {130, 0, 178},
  reputation = {215, 12, 101}
}

function UIGraphs:UIGraphs(ui)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  if not pcall(function()
    self.background = gfx:loadRaw("Graph01V", 640, 480)
    local palette = gfx:loadPalette("QData", "Graph01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    self.panel_sprites = gfx:loadSpriteTable("QData", "Graph02V", true, palette)
    self.white_font = gfx:loadFont("QData", "Font01V", false, palette)
    self.black_font = gfx:loadFont("QData", "Font00V", false, palette)
  end) then
    ui:addWindow(UIInformation(ui, {_S.errors.dialog_missing_graphics}))
    self:close()
    return
  end

  local hosp = ui.hospital
  self.hospital = hosp

  -- Buttons
  self:addPanel(0, 63, 384):makeButton(0, 0, 26, 26, 3, self.close):setTooltip(_S.tooltip.graphs.close)

  -- The possible scales are:
  -- 1: Increments of four years per line
  -- 2: Increments of one year per line
  -- 3: Increments of one month per line
  self.graph_scale = 3

  self.graph_scale_panel = self:addPanel(0, 371, 384)
  self.graph_scale_button = self.graph_scale_panel:makeButton(0, 0, 65, 26, 2, self.toggleGraphScale):setTooltip(_S.tooltip.graphs.scale)

  self.hide_graph = {}

  local function buttons(name)
    return --[[persistable:graphs_button]] function()
      self:toggleGraph(name)
    end
  end
  self.graph_buttons = {
    self:addPanel(0, 590, 34):makeToggleButton(0, 0, 42, 42, 1, buttons("money_in")):setTooltip(_S.tooltip.graphs.money_in),
    self:addPanel(0, 590, 86):makeToggleButton(0, 0, 42, 42, 1, buttons("money_out")):setTooltip(_S.tooltip.graphs.money_out),
    self:addPanel(0, 590, 138):makeToggleButton(0, 0, 42, 42, 1, buttons("wages")):setTooltip(_S.tooltip.graphs.wages),
    self:addPanel(0, 590, 190):makeToggleButton(0, 0, 42, 42, 1, buttons("balance")):setTooltip(_S.tooltip.graphs.balance),
    self:addPanel(0, 590, 243):makeToggleButton(0, 0, 42, 42, 1, buttons("visitors")):setTooltip(_S.tooltip.graphs.visitors),
    self:addPanel(0, 590, 295):makeToggleButton(0, 0, 42, 42, 1, buttons("cures")):setTooltip(_S.tooltip.graphs.cures),
    self:addPanel(0, 590, 347):makeToggleButton(0, 0, 42, 42, 1, buttons("deaths")):setTooltip(_S.tooltip.graphs.deaths),
    self:addPanel(0, 590, 400):makeToggleButton(0, 0, 42, 42, 1, buttons("reputation")):setTooltip(_S.tooltip.graphs.reputation)
  }

  self:updateLines()
end

function UIGraphs:updateLines()

  local statistics = self.hospital.statistics
  -- Make one line for each graph
  local lines = {}
  for stat, _ in pairs(statistics[1]) do
    local line = TH.line()
    line:setWidth(2)
    local hue = colours[stat]
    line:setColour(hue[1], hue[2], hue[3], 255)
    lines[stat] = {line = line, maximum = 0, minimum = 0}
  end
  self.lines = lines

  -- Pick the relevant values starting from the end of the statistics table
  local values = {}
  local decrements = -4 * 12 -- Four years
  if self.graph_scale == 2 then
    decrements = -12 -- One year
  elseif self.graph_scale == 3 then
    decrements = -1 -- A month
  end
  for i = #statistics, #statistics + decrements*11, decrements do
    if i < 1 then
      break
    end
    values[#values + 1] = statistics[i]
  end
  self.values = values

  -- Decide maximum and minimum for normalisation of each line
  for _, part in ipairs(values) do
    if type(part) == "table" then
      for stat, value in pairs(part) do
        if value < lines[stat].minimum then
          lines[stat].minimum = value
        end
        if value > lines[stat].maximum then
          lines[stat].maximum = value
        end
      end
    end
  end

  -- Start from the right part of the graph window
  local top_y = 85
  local bottom_y = 353
  local first_x = 346
  local dx = -25
  local text = {}

  -- First start at the correct place
  local part = values[1]
  for stat, value in pairs(part) do
    -- The zero point may not be at the bottom of the graph for e.g. balance when it has been negative
    local zero_point = lines[stat].minimum < 0 and lines[stat].minimum*(bottom_y-top_y)/(lines[stat].maximum - lines[stat].minimum) or 0
    local normalized_value = value == 0 and 0 or value*(bottom_y-top_y)/(lines[stat].maximum - lines[stat].minimum)
    -- Save the starting point for text drawing purposes.
    local start = top_y + (bottom_y - top_y) - normalized_value + zero_point
    text[#text + 1] = {stat = stat, start_y = start, value = value}
    lines[stat].line:moveTo(first_x, start)
  end

  -- Sort the y positions where to put text to draw the top text first.
  local function compare(a,b)
    return a.start_y < b.start_y
  end
  table.sort(text, compare)
  self.text_positions = text


  local aux_lines = {}
  -- Then add all the nodes available for each graph
  for i, part in ipairs(values) do
    for stat, value in pairs(part) do
      -- The zero point may not be at the bottom of the graph for e.g. balance when it has been negative
      local zero_point = lines[stat].minimum < 0 and lines[stat].minimum*(bottom_y-top_y)/(lines[stat].maximum - lines[stat].minimum) or 0
      local normalized_value = value == 0 and 0 or value*(bottom_y-top_y)/(lines[stat].maximum - lines[stat].minimum)
      lines[stat].line:lineTo(first_x, top_y + (bottom_y - top_y) - normalized_value + zero_point)
    end
    -- Also add a small line going from the number of month name to the actual graph.
    local line = TH.line()
    line:setWidth(1)
    --local hue = colours[stat]
    --line:setColour(hue[1], hue[2], hue[3], 255)
    line:moveTo(first_x, bottom_y + 2)
    line:lineTo(first_x, bottom_y + 8)
    aux_lines[#aux_lines + 1] = line
    first_x = first_x + dx
  end
  self.aux_lines = aux_lines

end

function UIGraphs:draw(canvas, x, y)
  self.background:draw(canvas, self.x + x, self.y + y)
  UIFullscreen.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y

  self.white_font:draw(canvas, _S.graphs.money_in, x + 502, y + 41, 80, 27)
  self.white_font:draw(canvas, _S.graphs.money_out, x + 502, y + 93, 80, 27)
  self.white_font:draw(canvas, _S.graphs.wages, x + 502, y + 145, 80, 27)
  self.white_font:draw(canvas, _S.graphs.balance, x + 502, y + 197, 80, 27)
  self.white_font:draw(canvas, _S.graphs.visitors, x + 502, y + 249, 80, 27)
  self.white_font:draw(canvas, _S.graphs.cures, x + 502, y + 301, 80, 27)
  self.white_font:draw(canvas, _S.graphs.deaths, x + 502, y + 353, 80, 27)
  self.white_font:draw(canvas, _S.graphs.reputation, x + 502, y + 405, 80, 27)

  -- Draw the different lines
  for stat, values in pairs(self.lines) do
    if not self.hide_graph[stat] then
      values.line:draw(canvas, x, y)
    end
  end

  local first_x = 334

  -- Draw strings showing what values each entry has at the moment just to the right of the graph.
  -- TODO: These should be coloured according to the colour of the corresponding line.
  local cur_y = 85
  for _, values in pairs(self.text_positions) do
    if not self.hide_graph[values.stat] then
      -- -5 makes the text appear just to the right of the line instead of just beneath it.
      cur_y = (cur_y > values.start_y and cur_y or values.start_y - 5)
      -- The last y compensates that draw returns the last y position relative to the top of the window, not the dialog.
      -- To get all values in the same "column", draw them separately.
      self.black_font:draw(canvas, _S.graphs[values.stat] .. ":", x + first_x + 15, y + cur_y)
      cur_y = self.black_font:draw(canvas, values.value, x + first_x + 72, y + cur_y) - y
    end
  end


  local dx = -25
  local number = math.floor(#self.hospital.statistics / 12)

  local decrements = -4 -- Four years
  if self.graph_scale == 2 then
    decrements = -1 -- One year
  elseif self.graph_scale == 3 then
    decrements = -1 -- A month
    number = #self.hospital.statistics - number * 12
  end
  local no = 1

  -- Draw numbers (or month names) below the graph
  for _, _ in ipairs(self.values) do
    self.black_font:drawWrapped(canvas, self.graph_scale == 3 and _S.months[(number - 1) % 12 + 1] or number, x + first_x, y + 363, 25, "center")
    first_x = first_x + dx
    number = number + decrements
    -- And the small black line
    self.aux_lines[no]:draw(canvas, x, y)
    no = no + 1
  end
end

function UIGraphs:toggleGraphScale()
  self.graph_scale = self.graph_scale + 1
  if self.graph_scale == 4 then self.graph_scale = 1 end
  self:updateLines()
  self.ui:playSound("selectx.wav")
end

function UIGraphs:toggleGraph(name)
  self.hide_graph[name] = not self.hide_graph[name]
  self.ui:playSound("selectx.wav")
end

function UIGraphs:close()
  UIFullscreen.close(self)
  self.ui:getWindow(UIBottomPanel):updateButtonStates()
end

function UIGraphs:afterLoad(old, new)
  if old < 60 then
    self:close()
  end
end
