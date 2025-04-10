--[[ Copyright (c) 2025 Matthew "Matroftt"

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

--! Interactive Machine List
class "UIMachineMenu" (UIResizable)

---@type UIMachineMenu
local UIMachineMenu = _G["UIMachineMenu"]

local col_bg = { red = 219, green = 81, blue = 12, }
local col_shadow = { red = 202, green = 69, blue = 8, }
local col_highlight = { red = 232, green = 95, blue = 16 }
local col_assigned_button = { red = 84, green = 200, blue = 84 }
local col_warning_button = { red = 219, green = 36, blue = 36 }

-- Timer, used to update machine menu only once per X ticks to reduce the burden.
local ticks_to_skip = 10
local tick_timer = ticks_to_skip

local row_height = 20
local window_margin = 15

function UIMachineMenu:UIMachineMenu(ui)
  local app = ui.app

  -- Calculate menu's height
  local height_divisor = 4
  local approx_rows_space = math.floor(app.config.height / height_divisor)
  self.rows = math.ceil(approx_rows_space / row_height)
  local rows_space = self.rows * row_height

  local width = 500
  local height = row_height + rows_space + window_margin * 2  -- header + values + margin (top and bottom)
  self:UIResizable(ui, width, height, col_bg)
  self.ui = ui
  self.modal_class = "machine_menu"

  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.05, 0.05)

  self.machine_list = {}
  self.list_table = {}

  self.default_button_sound = "selectx.wav"

  self.sort_method = "sortByRatio"
  self.rows_shown = 0
  self:createControls()

  self:update()
end

function UIMachineMenu:createControls()
  local rows = self.rows

  self.panel_sprites = self.ui.app.gfx:loadSpriteTable("QData", "Req03V", true)
  self.white_font = self.ui.app.gfx:loadFont("QData", "Font01V")

  if rows ~= self.rows_shown then
    local function assigned_factory(num)
      return --[[persistable:machine_menu_assigned_button]] function(window)
        window:assignedHandymanButtonClicked(num)
      end
    end
    local function warning_factory(num)
      return --[[persistable:machine_menu_warning_button]] function(window)
        window:warningButtonClicked(num)
      end
    end
    local function name_factory(num)
      return --[[persistable:machine_menu_name_button]] function(window)
        window:machineButtonClicked(num)
      end
    end
    local scrollbarMovedCallback = --[[persistable:machine_menu_scrollbar]] function()
      self:scrollbarMoved()
    end

    self.rows_shown = rows
    self.list_table = {}
    local indicator_width = 20
    local name_width = 180
    local values_width = 70
    local x = window_margin
    local y = window_margin


    -- Draw headers
    local warning_header = self:addBevelPanel(x, window_margin, indicator_width, row_height, col_highlight)
        :setLabel("!"):setTooltip(_S.tooltip.machine_menu.header.smoking)
    x = x + indicator_width
    local assigned_header = self:addBevelPanel(x, window_margin, indicator_width, row_height, col_highlight)
        :setLabel("X"):setTooltip(_S.tooltip.machine_menu.header.assigned)
    x = x + indicator_width
    local name_header = self:addBevelPanel(x, window_margin, name_width, row_height, col_highlight)
        :setLabel(_S.machine_menu.machine):setTooltip(_S.tooltip.machine_menu.header.machine)
    x = x + name_width
    local remaining_strength_panel_header = self:addBevelPanel(x, window_margin, values_width, row_height,
          col_highlight)
        :setLabel(_S.machine_menu.remaining_strength)
        :makeButton(0, 0, 70, 20, nil, self.setSortByRemain)
        :setTooltip(_S.tooltip.machine_menu.header.remaining_strength .. " " .. _S.tooltip.machine_menu.sort)
    x = x + values_width
    local strength_panel_header = self:addBevelPanel(x, window_margin, values_width, row_height, col_highlight)
        :setLabel(_S.machine_menu.total_strength)
        :makeButton(0, 0, 70, 20, nil, self.setSortByStrength)
        :setTooltip(_S.tooltip.machine_menu.header.total_strength .. " " .. _S.tooltip.machine_menu.sort)
    x = x + values_width
    local ratio_panel_header = self:addBevelPanel(x, window_margin, values_width, row_height, col_highlight)
        :setLabel(_S.machine_menu.ratio)
        :makeButton(0, 0, 70, 20, nil, self.setSortByRatio)
        :setTooltip(_S.tooltip.machine_menu.header.ratio .. " " .. _S.tooltip.machine_menu.sort)

    -- Draw rows
    for i = 1, rows, 1 do
      x = window_margin
      local warning_panel = self:addBevelPanel(x, y + row_height, indicator_width, row_height, col_warning_button)
      local warning_button = warning_panel:makeButton(0, 0, indicator_width, row_height, nil, warning_factory(i))
          :setTooltip(_S.tooltip.machine_menu.smoking)
      x = x + indicator_width
      local assigned_panel = self:addBevelPanel(x, y + row_height, indicator_width, row_height, col_assigned_button)
      local assigned_button = assigned_panel:makeButton(0, 0, indicator_width, row_height, nil, assigned_factory(i))
          :setTooltip(_S.tooltip.machine_menu.assigned)
      x = x + indicator_width
      local name_panel = self:addBevelPanel(x, y + row_height, 180, row_height, col_bg)
      local name_button = name_panel:makeButton(0, 0, 200, row_height, nil, name_factory(i))
          :setTooltip(_S.tooltip.machine_menu.machine)
      x = x + name_width
      local remaining_strength_panel = self:addBevelPanel(x, y + row_height, 70, row_height, col_shadow)
          :setTooltip(_S.tooltip.machine_menu.remaining_strength)
      x = x + values_width
      local strength_panel = self:addBevelPanel(x, y + row_height, 70, row_height, col_shadow)
          :setTooltip(_S.tooltip.machine_menu.total_strength)
      x = x + values_width
      local percentage_panel = self:addBevelPanel(x, y + row_height, 70, row_height, col_shadow)
          :setTooltip(_S.tooltip.machine_menu.ratio)

      table.insert(self.list_table, {
        warning_header = warning_header,
        assigned_header = assigned_header,
        name_header = name_header,
        remaining_strength_panel_header = remaining_strength_panel_header,
        strength_panel_header = strength_panel_header,
        ratio_panel_header = ratio_panel_header,
        assigned_panel = assigned_panel,
        assigned_button = assigned_button,
        warning_panel = warning_panel,
        warning_button = warning_button,
        name_panel = name_panel,
        name_button = name_button,
        remaining_strength_panel = remaining_strength_panel,
        strength_panel = strength_panel,
        percentage_panel = percentage_panel,
      })
      y = y + row_height
    end

    -- Add scrollbar
    self.scrollbar = self:addColourPanel(461, window_margin + 20, 24, row_height * rows,
          col_shadow.red, col_shadow.green, col_shadow.blue)
        :makeScrollbar(col_bg, scrollbarMovedCallback, 1, 1, 10, 1)
    -- Add close button
    self:addPanel(337, 461,  8):makeButton(0, 0, 24, 24, 338, self.close)
        :setTooltip(_S.tooltip.machine_menu.close)
  end
end

function UIMachineMenu:scrollToEntity(entity)
  local x, y = self.ui.app.map:WorldToScreen(entity.tile_x, entity.tile_y)
  local px, py = entity.th:getMarker()
  self.ui:scrollMapTo(x + px, y + py)
  self.ui:addWindow(UIMachine(self.ui, entity, entity:getRoom()))
end

function UIMachineMenu:machineButtonClicked(index)
  local machine_index = index + self.scrollbar.value - 1
  local machine = self.machine_list[machine_index]
  if machine and machine.object then
    if class.is(machine.object, Room) then
      self:scrollToRoom(machine.object)
    elseif class.is(machine.object, Entity) then
      self:scrollToEntity(machine.object)
    end
  end
end

function UIMachineMenu:warningButtonClicked(index)
  local ui = self.ui
  local machine_index = index + self.scrollbar.value - 1
  local machine = self.machine_list[machine_index]
  local room = machine.object:getRoom()

  if machine and room.is_active then
    local UIMachine = UIMachine(ui, machine.object, room)
    UIMachine:replaceMachine()
    ui:addWindow(UIMachine)
  end
end

function UIMachineMenu:assignedHandymanButtonClicked(index)
  local ui = self.ui
  local machine_index = index + self.scrollbar.value - 1
  local machine = self.machine_list[machine_index]
  if machine and machine.assigned_to then
    self.ui:addWindow(UIStaff(ui, machine.assigned_to))
  end
end

function UIMachineMenu:setSortByRemain()
  self.sort_method = "sortByRemain"
end

function UIMachineMenu:setSortByStrength()
  self.sort_method = "sortByStrength"
end

function UIMachineMenu:setSortByRatio()
  self.sort_method = "sortByRatio"
end

function UIMachineMenu:sortMachines(method)
  if method == "sortByRemain" then
    table.sort(self.machine_list,
      function(a, b)
        if a.remaining_strength == nil or b.remaining_strength == nil then return false end
        return a.remaining_strength < b.remaining_strength
      end)
  elseif method == "sortByStrength" then
    table.sort(self.machine_list,
      function(a, b)
        if a.strength == nil or b.strength == nil then return false end
        return a.strength < b.strength
      end)
  elseif method == "sortByRatio" then
    table.sort(self.machine_list,
      function(a, b)
        if a.percentage_strength == nil or b.percentage_strength == nil then return false end
        return a.percentage_strength < b.percentage_strength
      end)
  end
end

function UIMachineMenu:update()
  local function machineForList(machine, assigned_handyman)
    local remaining_uses_count = machine:getRemainingUses()
    local percentage_strength = math.floor((remaining_uses_count / machine.strength) * 100)
    local is_assigned = assigned_handyman ~= nil
    local result = {
      object = machine,
      smoking = machine:isBreaking(),
      assigned = is_assigned,
      assigned_to = assigned_handyman,
      name = machine.object_type.name,
      strength = machine.strength,
      remaining_strength = remaining_uses_count,
      percentage_strength = percentage_strength,
      total_usage = machine.total_usage
    }
    return result
  end

  self.machine_list = {}
  local dispatcher = self.ui.app.world.dispatcher

  for _, entity in ipairs(self.ui.app.world.entities) do
    -- is entity a machine and not a slave (e.g. operating_table_b)
    if class.is(entity, Machine) and not entity.master then
      local machine = entity
      if not machine:getRoom().crashed then
        local assigned_handyman
        local repair_call = dispatcher.call_queue[machine]
        if repair_call then
          assigned_handyman = repair_call["repair"].assigned
        end
        local machine_for_list = machineForList(machine, assigned_handyman)
        table.insert(self.machine_list, machine_for_list)
      end
    end
  end

  self:sortMachines(self.sort_method)

  self.scrollbar:setRange(1, math.max(1, #self.machine_list), self.rows_shown, self.scrollbar.value)
  self:scrollbarMoved()
end

function UIMachineMenu:scrollbarMoved()
  local scroll_pos = self.scrollbar.value
  for i = 1, self.rows_shown, 1 do
    local machine = self.machine_list[i + scroll_pos - 1]
    local row = self.list_table[i]
    if machine then
      row.assigned_panel:setLabel(machine.assigned and "X" or "")
      row.assigned_button:enable(machine.assigned and true or false)
      row.warning_panel:setLabel(machine.smoking and "!" or "")
      row.warning_button:enable(true)
      row.name_panel:setLabel(" " .. machine.name, nil, "left")
      row.name_button:enable(true)
      row.remaining_strength_panel:setLabel(tostring(machine.remaining_strength))
      row.strength_panel:setLabel(tostring(machine.strength))
      row.percentage_panel:setLabel(_S.machine_menu.percentage:format(machine.percentage_strength))
    else
      row.assigned_panel:setLabel("")
      row.name_panel:setLabel("")
      row.assigned_button:enable(false)
      row.warning_button:enable(false)
      row.name_button:enable(false)
    end
  end
end

function UIMachineMenu:onTick()
  -- menu updates not every tick
  tick_timer = tick_timer - 1
  if tick_timer <= 0 then
    tick_timer = ticks_to_skip
    self:update()
  end
end

function UIMachineMenu:close()
  Window.close(self)
end
