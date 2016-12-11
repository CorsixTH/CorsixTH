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

  self.hospital = ui.hospital

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

local TOP_Y = 85 -- Top of the graph area
local BOTTOM_Y = 353 -- Bottom of the graph area
local RIGHT_X = 346 -- Right side of the graph area
local VERT_DX = 25 -- Spacing between the vertical lines in the graph
local VERT_COUNT = 12 -- Number of vertical lines in the graph
local GRAPH_HEIGHT = BOTTOM_Y - TOP_Y

--! Compute the vertical position of a value in the graph given the line extremes
--!param graph_line (table) Meta data of the line, including extreme values.
--!param value (number) Value to position vertically in the graph.
--!return Y position in the graph of the value.
local function computeVerticalValuePosition(graph_line, value)
  -- 0 is always included in the range.
  assert(graph_line.maximum >= 0 and graph_line.minimum <= 0)
  local range = graph_line.maximum - graph_line.minimum
  if range == 0 then return BOTTOM_Y end

  return BOTTOM_Y - math.floor(((value - graph_line.minimum) / range) * GRAPH_HEIGHT)
end

--! Convert graph scale to a stepsize in months.
--!param graph_scale (int, 1 to 3) Graph scale to display.
--!return Number of months to jump between statistics values in the hospital statistics data.
local function getStatisticsStepsize(graph_scale)
  local stepsize = 4 * 12 -- Four years
  if graph_scale == 2 then
    stepsize = 12 -- One year
  elseif graph_scale == 3 then
    stepsize = 1 -- A month
  end
  return stepsize
end

--! Get the statistics from the hospital that should be displayed.
--! Selection starts at the last (=newest) entry, and goes back in time.
--!return The values of all statistics to plot in the graph display.
function UIGraphs:getHospitalStatistics()
  local statistics = self.hospital.statistics

  local values = {}
  local i = #statistics -- Picking hospital statistics from right to left (recent to old).
  local stats_stepsize = getStatisticsStepsize(self.graph_scale)
  while #values < VERT_COUNT and i >= 1 do
    values[#values + 1] = statistics[i]
    i = i - stats_stepsize
  end
  return values
end

--! Compute new actual position of the labels.
--!param graph (UIGraphs) Graph window object
local function updateTextPositions(graph)
  -- Reset vertical position of the text back to its ideal position.
  -- Disable computations on invisible graphs by removing the actual y position of it.
  for _, label in ipairs(graph.label_datas) do
    if graph.hide_graph[label.stat] then
      label.pos_y = nil
    else
      label.pos_y = label.ideal_y
    end
  end

  local bottom_prev = TOP_Y
  for _, label in pairs(graph.label_datas) do
    if label.pos_y then
      local top_current = label.pos_y + label.shift_y
      if top_current < bottom_prev then
        label.pos_y = bottom_prev - label.shift_y
      end
      bottom_prev = label.pos_y + label.shift_y + label.size_y
    end
  end
end

function UIGraphs:updateLines()
  self.values = self:getHospitalStatistics()

  -- Construct meta data about each graph line.
  local graph_datas = {} -- Table ordered by statistics name.
  self.graph_datas = graph_datas
  for stat, _ in pairs(self.values[1]) do
    graph_datas[stat] = {line = nil, maximum = 0, minimum = 0}
  end

  -- Decide maximum and minimum for normalisation of each line.
  -- 0 is always included in the computed range.
  for _, stats in ipairs(self.values) do
    for stat, value in pairs(stats) do
      if value < graph_datas[stat].minimum then
        graph_datas[stat].minimum = value
      end
      if value > graph_datas[stat].maximum then
        graph_datas[stat].maximum = value
      end
    end
  end

  -- Add the line objects of the graph.
  for stat, graph_data in pairs(self.graph_datas) do
    local line = TH.line()
    line:setWidth(2)
    local hue = colours[stat]
    line:setColour(hue[1], hue[2], hue[3], 255)
    graph_data.line = line
  end

  -- Add the graph line pieces. Doing this separately is more efficient as all
  -- graph lines can be extended to the left in the same iteration.
  local xpos = RIGHT_X
  for i, stats in ipairs(self.values) do
    for stat, value in pairs(stats) do
      local line = graph_datas[stat].line
      local ypos = computeVerticalValuePosition(graph_datas[stat], value)
      if i == 1 then
        line:moveTo(xpos, ypos)
      else
        line:lineTo(xpos, ypos)
      end
    end
    xpos = xpos - VERT_DX
  end

  -- Compute label data for each statistic, and order by vertical position.
  -- The newest statistic values are displayed at the right edge of the graph,
  -- which decides the optimal position of the graph label text and value.
  local label_datas = {}
  self.label_datas = label_datas

  for stat, value in pairs(self.values[1]) do
    local ideal_y = computeVerticalValuePosition(graph_datas[stat], value)
    local text = _S.graphs[stat] .. ":"
    local _, size_y, _ = self.black_font:sizeOf(text)
    label_datas[#label_datas + 1] = {
        stat = stat, -- Name of the statistic it belongs to.
        text = text, -- Translated label text.
        ideal_y = ideal_y, -- Ideal vertical position.
        pos_y = nil, -- Actual position for drawing.
        size_y = size_y, -- Vertical size of the text.
        shift_y = -math.floor(size_y / 2), -- Amount of shift to center the text.
        value = value} -- Numeric value to display.
  end

  -- Sort the labels of the graph on ideal y position, and compute actual position.
  local function compare(a,b)
    return a.ideal_y < b.ideal_y
  end
  table.sort(label_datas, compare)
  updateTextPositions(self)

  -- Create small lines going from the number of month name to the actual graph.
  -- Like the lines, index runs from right to left at the screen.
  local aux_lines = {}
  self.aux_lines = aux_lines

  xpos = RIGHT_X
  for _ = 1, #self.values do
    local line = TH.line()
    line:setWidth(1)
    line:moveTo(xpos, BOTTOM_Y + 2)
    line:lineTo(xpos, BOTTOM_Y + 8)
    aux_lines[#aux_lines + 1] = line
    xpos = xpos - VERT_DX
  end
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
  for stat, graph in pairs(self.graph_datas) do
    if not self.hide_graph[stat] then
      graph.line:draw(canvas, x, y)
    end
  end

  -- Draw strings showing what values each entry has at the moment just to the right of the graph.
  -- TODO: These should be coloured according to the colour of the corresponding line.
  for _, label in pairs(self.label_datas) do
    if label.pos_y then
      local ypos = label.pos_y + label.shift_y
      self.black_font:draw(canvas, label.text, x + RIGHT_X + 3, y + ypos)
      self.black_font:draw(canvas, label.value, x + RIGHT_X + 60, y + ypos)
    end
  end

  local stats_stepsize = getStatisticsStepsize(self.graph_scale)
  local xpos = x + RIGHT_X

  -- Draw numbers (or month names) below the graph
  if stats_stepsize >= 12 then
    -- Display years
    local year_number = math.floor(#self.hospital.statistics / 12)
    for i = 1, #self.values do
      self.black_font:drawWrapped(canvas, year_number, xpos, y + BOTTOM_Y + 10, 25, "center")
      xpos = xpos - VERT_DX
      year_number = year_number - math.floor(stats_stepsize / 12)

      -- And the small black line
      self.aux_lines[i]:draw(canvas, x, y)
    end
  else
    -- Display months
    local month_number = #self.hospital.statistics - math.floor(#self.hospital.statistics / 12) * 12
    for i = 1, #self.values do
      self.black_font:drawWrapped(canvas, _S.months[month_number], xpos, y + BOTTOM_Y + 10, 25, "center")
      xpos = xpos - VERT_DX
      month_number = month_number - stats_stepsize
      if month_number < 1 then month_number = month_number + 12 end

      -- And the small black line
      self.aux_lines[i]:draw(canvas, x, y)
    end
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
  updateTextPositions(self)
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
