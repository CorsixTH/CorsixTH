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
local col_shaded_assigned_button = { red = 92, green = 150, blue = 92 }
local col_disabled_assigned_button = { red = 84, green = 112, blue = 84 }
local col_warning_button = { red = 219, green = 36, blue = 36 }
local col_disabled = { red = 159, green = 90, blue = 56 }

-- Timer, used to update machine menu only once per X ticks to reduce the burden.
local ticks_to_skip = 10
local tick_timer = ticks_to_skip

local row_height = 32
local window_margin = 15

function UIMachineMenu:UIMachineMenu(ui)
  local app = ui.app

  -- Calculate menu's height
  local height_divisor = 4
  local approx_rows_space = math.floor(app.config.height / height_divisor)
  self.rows = math.ceil(approx_rows_space / row_height)
  local rows_space = self.rows * row_height

  local width = 480
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
  self.white_font = self.ui.app.gfx:loadFontAndSpriteTable("QData", "Font01V", nil, nil, { apply_ui_scale = true })

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
    local indicator_width = 32
    local name_width = 180
    local status_width = 112
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
        :setLabel(_S.machine_menu.machine)
        :makeButton(0, 0, name_width, row_height, nil, self.setSortByName)
        :setTooltip(_S.tooltip.machine_menu.header.machine)
    x = x + name_width
    local status_panel_header = self:addBevelPanel(x, window_margin, status_width, row_height,
          col_highlight)
        :setLabel(_S.machine_menu.status)
        :makeButton(0, 0, status_width, row_height, nil, self.setSortByRatio)
        :setTooltip(_S.tooltip.machine_menu.header.status .. " " .. _S.tooltip.machine_menu.sort)
    x = x + status_width
    local remaining_strength_panel_header = self:addBevelPanel(x, window_margin, indicator_width, row_height, col_highlight)
        :makeButton(0, 0, indicator_width, row_height, nil, self.setSortByRemain)
        :setTooltip(_S.tooltip.machine_menu.header.remaining_strength .. " " .. _S.tooltip.machine_menu.sort)
    x = x + indicator_width
    local strength_panel_header = self:addBevelPanel(x, window_margin, indicator_width, row_height, col_highlight)
        :makeButton(0, 0, indicator_width, row_height, nil, self.setSortByStrength)
        :setTooltip(_S.tooltip.machine_menu.header.total_strength .. " " .. _S.tooltip.machine_menu.sort)

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
      local status_panel = self:addBevelPanel(x, y + row_height, status_width, row_height, col_bg)
          :setTooltip(_S.tooltip.machine_window.status)
      x = x + status_width
      local remaining_strength_panel = self:addBevelPanel(x, y + row_height, indicator_width, row_height, col_bg)
          :setTooltip(_S.tooltip.machine_menu.remaining_strength)
      x = x + indicator_width
      local strength_panel = self:addBevelPanel(x, y + row_height, indicator_width, row_height, col_bg)
          :setTooltip(_S.tooltip.machine_menu.total_strength)

      table.insert(self.list_table, {
        warning_header = warning_header,
        assigned_header = assigned_header,
        name_header = name_header,
        status_panel_header = status_panel_header,
        remaining_strength_panel_header = remaining_strength_panel_header,
        strength_panel_header = strength_panel_header,
        assigned_panel = assigned_panel,
        assigned_button = assigned_button,
        warning_panel = warning_panel,
        warning_button = warning_button,
        name_panel = name_panel,
        name_button = name_button,
        status_panel = status_panel,
        remaining_strength_panel = remaining_strength_panel,
        strength_panel = strength_panel,
      })
      y = y + row_height
    end

    -- Add scrollbar
    self.scrollbar = self:addColourPanel(446, window_margin + 30, 24, row_height * rows,
          col_shadow.red, col_shadow.green, col_shadow.blue)
        :makeScrollbar(col_bg, scrollbarMovedCallback, 1, 1, 10, 1)
    -- Add close button
    self:addPanel(337, 446,  15):makeButton(0, 0, 24, 24, 338, self.close)
        :setTooltip(_S.tooltip.machine_menu.close)
  end
end

function UIMachineMenu:scrollToEntity(entity)
  local x, y = self.ui.app.map:WorldToScreen(entity.tile_x, entity.tile_y)
  self.ui:scrollMapTo(x, y)
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
  local room = machine.object:getRoom()

  if machine and machine.assigned_to and room.is_active then
    self.ui:addWindow(UIStaff(ui, machine.assigned_to))
  end
end

function UIMachineMenu:setSortByName()
  self.sort_method = "sortByName"
end

function UIMachineMenu:setSortByRemain()
  self.sort_method = "sortByRemain"
end

function UIMachineMenu:setSortByRatio()
  self.sort_method = "sortByRatio"
end

function UIMachineMenu:setSortByStrength()
  self.sort_method = "sortByStrength"
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

        if a.smoking and not b.smoking then
          return true
        elseif not a.smoking and b.smoking then
          return false
        end

        if (a.smoking or b.smoking) and (a.remaining_strength ~= b.remaining_strength) then
          return a.remaining_strength < b.remaining_strength
        end

        return a.percentage_strength < b.percentage_strength
     end)
  elseif method == "sortByName" then
    table.sort(self.machine_list,
      function(a, b)
        return a.object.object_type.name < b.object.object_type.name
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
  local world = self.ui.app.world
  local dispatcher = world.dispatcher
  local machines = world:getPlayerMachines()

  for _, machine in ipairs(machines) do
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

  self:sortMachines(self.sort_method)

  self.scrollbar:setRange(1, math.max(1, #self.machine_list), self.rows_shown, self.scrollbar.value)
  self:scrollbarMoved()
end

function UIMachineMenu:draw(canvas, x, y)
  UIResizable.draw(self, canvas, x, y)
  local panel_sprites = self.ui.app.gfx:loadSpriteTable("QData", "Req03V", true)
  local bitmap_sprites = self.ui.app.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
  local scroll_pos = self.scrollbar.value
  local s = TheApp.config.ui_scale
  x, y = self.x * s, self.y * s
  bitmap_sprites:draw(canvas, 25, x + 374 * s, y + (window_margin + 2) * s, { scaleFactor = s })
  bitmap_sprites:draw(canvas, 26, x + 407 * s, y + (window_margin + 2) * s, { scaleFactor = s })

  for i = 1, self.rows_shown, 1 do
    local machine = self.machine_list[i + scroll_pos - 1]
    if machine then
      bitmap_sprites:draw(canvas, 24, x + 264 * s, y + (window_margin + row_height * i + 3) * s, { scaleFactor = s })
      local status_bar_width = math.floor((1 - machine.object.times_used/machine.object.strength) * 40 * s + 0.5)
      if status_bar_width ~= 0 then
        for dx = 0, status_bar_width - 1 do
          panel_sprites:draw(canvas, 352, x + 293 * s + dx, y + (window_margin + row_height * i + math.floor(row_height/2) - 2) * s, { scaleFactor = s })
        end
      end
    end
  end
end

function UIMachineMenu:scrollbarMoved()
  local scroll_pos = self.scrollbar.value
  for i = 1, self.rows_shown, 1 do
    local machine = self.machine_list[i + scroll_pos - 1]
    local row = self.list_table[i]
    if machine then
      row.assigned_panel:setColour(machine.assigned and col_assigned_button or col_shaded_assigned_button)
      row.assigned_panel:setLabel(machine.assigned and "X" or "")
      row.assigned_button:enable(machine.assigned and true or false)
      row.warning_panel:setLabel(machine.smoking and "!" or "")
      row.warning_panel:setColour(machine.smoking and col_warning_button or col_bg)
      row.warning_button:enable(true)
      row.name_panel:setLabel(" " .. machine.name, nil, "left")
      row.name_panel:setColour(col_bg)
      row.name_button:enable(true)
      row.status_panel:setColour(col_bg)
      row.remaining_strength_panel:setLabel(tostring(machine.remaining_strength))
      row.remaining_strength_panel:setColour(col_bg)
      row.strength_panel:setLabel(tostring(machine.strength))
      row.strength_panel:setColour(col_bg)
    else
      row.warning_panel:setColour(col_disabled)
      row.assigned_panel:setColour(col_disabled_assigned_button)
      row.assigned_panel:setLabel("")
      row.name_panel:setLabel("")
      row.assigned_button:enable(false)
      row.warning_button:enable(false)
      row.name_button:enable(false)
      row.status_panel:setColour(col_disabled)
      row.remaining_strength_panel:setColour(col_disabled)
      row.name_panel:setColour(col_disabled)
      row.strength_panel:setColour(col_disabled)
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

function UIMachineMenu:afterLoad(old, new)
  if old < 236 then
    self.white_font = TheApp.gfx:loadFontAndSpriteTable("QData", "Font01V", nil, nil, { apply_ui_scale = true })
  end
  if old < 242 then
    self:close()
  end
  Window.afterLoad(self, old, new)
end
