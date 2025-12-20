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

local TH = require("TH")

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
    self.background = gfx:loadRaw("Graph01V", 640, 480, "QData", "QData", "Graph01V.pal", true)
    local palette = gfx:loadPalette("QData", "Graph01V.pal", true)
    self.panel_sprites = gfx:loadSpriteTable("QData", "Graph02V", true, palette)
    self.white_font = gfx:loadFontAndSpriteTable("QData", "Font01V", false, palette, { apply_ui_scale = true })
    self.black_font = gfx:loadFontAndSpriteTable("QData", "Font00V", false, palette, { apply_ui_scale = true })
  end) then
    ui:addWindow(UIInformation(ui, {_S.errors.dialog_missing_graphics}))
    self:close()
    return
  end

  self.hospital = ui.hospital

  -- Buttons
  self:addPanel(0, 63, 384):makeButton(0, 0, 26, 26, 3, self.close):setTooltip(_S.tooltip.graphs.close)

  self.graph_scale_panel = self:addPanel(0, 371, 384)
  self.graph_scale_button = self.graph_scale_panel:makeButton(0, 0, 65, 26, 2, self.toggleGraphScale):setTooltip(_S.tooltip.graphs.scale)

  local config = self:initRuntimeConfig()
  self.graph_scale = config.graph_scale

  local function toggleButton(sprite, x, y, option, str)
    local panel = self:addPanel(sprite, x, y)
    local btn = panel:makeToggleButton(0, 0, 42, 42, 1, --[[persistable:graphs_button]] function() self:toggleGraph(option) end):setTooltip(str)
    btn:setToggleState(not config[option])
  end
  toggleButton(0, 590, 34,  "money_in",   _S.tooltip.graphs.money_in)
  toggleButton(0, 590, 86,  "money_out",  _S.tooltip.graphs.money_out)
  toggleButton(0, 590, 138, "wages",      _S.tooltip.graphs.wages)
  toggleButton(0, 590, 190, "balance",    _S.tooltip.graphs.balance)
  toggleButton(0, 590, 243, "visitors",   _S.tooltip.graphs.visitors)
  toggleButton(0, 590, 295, "cures",      _S.tooltip.graphs.cures)
  toggleButton(0, 590, 347, "deaths",     _S.tooltip.graphs.deaths)
  toggleButton(0, 590, 400, "reputation", _S.tooltip.graphs.reputation)

  self.display_month = self.hospital.world.game_date:monthOfGame()
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

function UIGraphs:initRuntimeConfig()
  -- config is a *runtime* configuration list; re-instantiations of the dialog
  -- share the same values, but it's not saved across saves or sessions
  local config = TheApp.runtime_config.graphs_dialog
  if config == nil then
    config = {}
    TheApp.runtime_config.graphs_dialog = config
    config.money_in = true
    config.money_out = true
    config.wages = true
    config.balance = true
    config.visitors = true
    config.cures = true
    config.deaths = true
    config.reputation = true
    config.graph_scale = 3
  end
  return config
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

--! Reposition the given sequence of text entries vertically such that the maximum
--  absolute deviation from the ideal position is minimized.
--!param label_datas (array) Text entries
--!param start_index (int) First entry to move.
--!param last_index (int) Last entry to move.
local function moveSequence(label_datas, start_index, last_index)
  -- min_y, max_y Smallest and biggest vertical position of the labels. Since
  --    they are sorted on y, it's the position of the first and last visible entry.
  -- min_y_shift, max_y_shift Vertical movement of the label of the first and
  --    last visible entry for vertically centering the text.
  -- min_dev, max_dev Smallest and biggest deviation from the optimal position,
  --    for all visible labels.
  local min_y = nil
  local max_y, min_y_shift, max_y_shift, min_dev, max_dev
  for i = start_index, last_index do
    local label = label_datas[i]
    if label.pos_y then -- Label is visible
      local deviation = label.pos_y - label.ideal_y -- Positive if moved down
      if min_y then -- Updating the max y, and deviations
        max_y = label.pos_y
        max_y_shift = label.shift_y
        min_dev = math.min(min_dev, deviation)
        max_dev = math.max(max_dev, deviation)
      else -- First time entering the loop
        min_y = label.pos_y
        max_y = label.pos_y
        min_y_shift = label.shift_y
        max_y_shift = label.shift_y
        min_dev = deviation
        max_dev = deviation
      end
    end
  end

  -- There should be at least one visible entry in the provided range.
  assert(min_y ~= nil)

  local move = -math.floor((max_dev + min_dev) / 2) -- Suggested movement of the sequence.

  -- Verify the sequence will stay inside graph upper and lower limits, adjust otherwise.
  if min_y + min_y_shift + move < TOP_Y then
    move = TOP_Y - min_y - min_y_shift
  elseif max_y + max_y_shift + move > BOTTOM_Y then
    move = BOTTOM_Y - max_y - max_y_shift
  end

  -- And update the positions.
  for i = start_index, last_index do
    local label = label_datas[i]
    if label.pos_y then label.pos_y = label.pos_y + move end
  end
end

--! Compute new actual position of the labels.
--!param graph (UIGraphs) Graph window object
local function updateTextPositions(graph)
  local config = TheApp.runtime_config.graphs_dialog

  -- Reset vertical position of the text back to its ideal position.
  -- Disable computations on invisible graphs by removing the actual y position of it.
  for _, label in ipairs(graph.label_datas) do
    if config[label.stat] then
      label.pos_y = label.ideal_y
    else
      label.pos_y = nil
    end
  end

  -- Move labels of the graphs such that they stay at the right of the graph
  -- between their upper and lower boundaries.
  local sequence_moved = true
  local collision_count = 8 -- In theory the loop should terminate, but better safe than sorry.
  while sequence_moved and collision_count > 0 do
    collision_count = collision_count - 1
    sequence_moved = false

    -- Find sequences of text entries that partly overlap or have no vertical
    -- space between them. Entries in such a sequence cannot be moved
    -- individually, the sequence as a whole must move.
    local start_index, last_index = nil, nil -- Start and end of the sequence.
    local collision = false -- True collision detected in the sequence
    local prev_index, prev_label = nil, nil
    for i, label in ipairs(graph.label_datas) do
      if label.pos_y then -- Label is visible
        if prev_label then
          -- Bottom y of previous label, top of current label
          local bottom_prev = prev_label.pos_y + prev_label.shift_y + prev_label.size_y
          local top_current = label.pos_y + label.shift_y

          if top_current < bottom_prev then
            -- True collision, text has to move
            collision = true
            sequence_moved = true
            label.pos_y = bottom_prev - label.shift_y
            if not start_index then start_index = prev_index end
            last_index = i

          elseif top_current == bottom_prev then
            -- Entry is concatenated to the sequence, position is fine.
            if not start_index then start_index = prev_index end
            last_index = i
          else
            -- Entry is not part of the sequence, move previous sequence to its
            -- optimal spot if required
            if collision then
              moveSequence(graph.label_datas, start_index, last_index)
            end

            collision = false
            start_index = nil
            last_index = nil
            -- Do not consider the current text in this round. The next entry may
            -- see it as the start of a next sequence.
          end
        end
        prev_label = label
        prev_index = i
      end
    end

    if collision then
      moveSequence(graph.label_datas, start_index, last_index)
    end
  end
end

function UIGraphs:updateLines()
  local s = TheApp.config.ui_scale
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
    line:setWidth(2 * s)
    local hue = colours[stat]
    line:setColour(hue[1], hue[2], hue[3], 255)
    graph_data.line = line
  end

  -- Add the graph line pieces. Doing this separately is more efficient as all
  -- graph lines can be extended to the left in the same iteration.
  local xpos = (RIGHT_X * s)
  for i, stats in ipairs(self.values) do
    for stat, value in pairs(stats) do
      local line = graph_datas[stat].line
      local ypos = computeVerticalValuePosition(graph_datas[stat], value) * s
      if i == 1 then
        line:moveTo(xpos, ypos)
      else
        line:lineTo(xpos, ypos)
      end
    end
    xpos = xpos - (VERT_DX * s)
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

  xpos = (RIGHT_X * s)
  for _ = 1, #self.values do
    local line = TH.line()
    line:setWidth(s)
    line:moveTo(xpos, BOTTOM_Y * s + 4 * s)
    line:lineTo(xpos, BOTTOM_Y * s + 8 * s)
    aux_lines[#aux_lines + 1] = line
    xpos = xpos - (VERT_DX * s)
  end
end

function UIGraphs:draw(canvas, x, y)
  local config = TheApp.runtime_config.graphs_dialog
  if not config then
    config = self:initRuntimeConfig()
  end

  -- Update graph automatically every month
  if self.display_month ~= self.hospital.world.game_date:monthOfGame() then
    self:updateLines()
  end

  local s = TheApp.config.ui_scale
  canvas:scale(s, "bitmap")
  self.background:draw(canvas, self.x * s + x, self.y * s + y)
  canvas:scale(1, "bitmap")
  UIFullscreen.draw(self, canvas, x, y)
  x, y = self.x * s + x, self.y * s + y

  local lx = x + 502 * s
  local lw = 80 * s
  local lh = 27 * s
  self.white_font:draw(canvas, _S.graphs.money_in, lx, y + 41 * s, lw, lh)
  self.white_font:draw(canvas, _S.graphs.money_out, lx, y + 93 * s, lw, lh)
  self.white_font:draw(canvas, _S.graphs.wages, lx, y + 145 * s, lw, lh)
  self.white_font:draw(canvas, _S.graphs.balance, lx, y + 197 * s, lw, lh)
  self.white_font:draw(canvas, _S.graphs.visitors, lx, y + 249 * s, lw, lh)
  self.white_font:draw(canvas, _S.graphs.cures, lx, y + 301 * s, lw, lh)
  self.white_font:draw(canvas, _S.graphs.deaths, lx, y + 353 * s, lw, lh)
  self.white_font:draw(canvas, _S.graphs.reputation, lx, y + 405 * s, lw, lh)

  -- Draw the different lines
  for stat, graph in pairs(self.graph_datas) do
    if config[stat] then
      graph.line:draw(canvas, x, y)
    end
  end

  -- Draw strings showing what values each entry has at the moment just to the right of the graph.
  -- TODO: These should be coloured according to the colour of the corresponding line.
  for _, label in pairs(self.label_datas) do
    if label.pos_y then
      local ypos = label.pos_y + label.shift_y * s
      self.black_font:draw(canvas, label.text, x + RIGHT_X * s + 3 * s, y + ypos * s)
      self.black_font:draw(canvas, string.format("%.0f", label.value), x + RIGHT_X * s + 60 * s, y + ypos * s)
    end
  end

  local stats_stepsize = getStatisticsStepsize(self.graph_scale)
  local xpos = x + RIGHT_X * s - math.floor(VERT_DX / 2) * s

  -- Draw numbers (or month names) below the graph
  assert(#self.hospital.statistics > 0) -- Avoid negative months and years.
  if stats_stepsize >= 12 then
    -- Display years
    local year_number = math.floor((#self.hospital.statistics - 1) / stats_stepsize)
    local year_steps = math.floor(stats_stepsize / 12)
    year_number = year_number * year_steps
    for i = 1, #self.values do
      self.black_font:drawWrapped(canvas, year_number, xpos, y + BOTTOM_Y * s + 10 * s, 25 * s, "center")
      xpos = xpos - VERT_DX * s
      year_number = year_number - year_steps

      -- And the small black line
      self.aux_lines[i]:draw(canvas, x, y)
    end
  else
    -- Display months
    local month_number = #self.hospital.statistics - math.floor((#self.hospital.statistics - 1) / 12) * 12
    for i = 1, #self.values do
      self.black_font:drawWrapped(canvas, _S.months[month_number], xpos, y + BOTTOM_Y * s + 10 * s, 25 * s, "center")
      xpos = xpos - VERT_DX * s
      month_number = month_number - stats_stepsize
      if month_number < 1 then month_number = month_number + 12 end

      -- And the small black line
      self.aux_lines[i]:draw(canvas, x, y)
    end
  end
end

function UIGraphs:toggleGraphScale()
  -- The possible scales are:
  -- 1: Increments of four years per line
  -- 2: Increments of one year per line
  -- 3: Increments of one month per line
  self.graph_scale = self.graph_scale - 1
  if self.graph_scale == 0 then self.graph_scale = 3 end

  local config = self.ui.app.runtime_config.graphs_dialog
  config.graph_scale = self.graph_scale

  self:updateLines()
  self.ui:playSound("selectx.wav")
end

function UIGraphs:toggleGraph(name)
  TheApp.runtime_config.graphs_dialog[name] = not TheApp.runtime_config.graphs_dialog[name]
  self.ui:playSound("selectx.wav")
  updateTextPositions(self)
end

function UIGraphs:close()
  UIFullscreen.close(self)
  self.ui:getWindow(UIBottomPanel):updateButtonStates()
end

function UIGraphs:onChangeResolution()
  UIFullscreen.onChangeResolution(self)
  -- onChangeResolution gets called during initialization before the data is ready.
  if self.graph_scale then
    self:updateLines()
  end
end

function UIGraphs:afterLoad(old, new)
  if old < 236 then
    local gfx = TheApp.gfx

    self.background = gfx:loadRaw("Graph01V", 640, 480, "QData", "QData", "Graph01V.pal", true)
    local palette = gfx:loadPalette("QData", "Graph01V.pal", true)
    self.panel_sprites = gfx:loadSpriteTable("QData", "Graph02V", true, palette)
    self.white_font = gfx:loadFontAndSpriteTable("QData", "Font01V", false, palette, { apply_ui_scale = true })
    self.black_font = gfx:loadFontAndSpriteTable("QData", "Font00V", false, palette, { apply_ui_scale = true })
  end
  UIFullscreen.afterLoad(self, old, new)
  if old < 231 then
    self:close()
  end
  self:updateLines()
end
