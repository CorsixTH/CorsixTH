--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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

-- luacheck: globals _
strict_declare_global "_"
_ = nil

--! Interactive Machine List
class "UIMachineMenu" (UIResizable)

---@type UIMachineMenu
local UIMachineMenu = _G["UIMachineMenu"]

local col_bg = {
  red = 219,
  green = 81,
  blue = 12,
}

local col_shadow = {
  red = 202,
  green = 69,
  blue = 8,
}

local col_assigned_button = {
  red = 84,
  green = 200,
  blue = 84,
}

local col_smoke_button = {
  red = 219,
  green = 36,
  blue = 36,
}


function UIMachineMenu:UIMachineMenu(ui)
  self:UIResizable(ui, 420, 400, col_bg)
  self.ui = ui

  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.05, 0.05)

  self.machine_list = {}
  self.list_table = {}

  -- Window parts definition
  self.default_button_sound = "selectx.wav"

  self.rows_shown = 0
  self:createControls()

  self:update()

end

local row_height = 20
local window_margin = 15

function UIMachineMenu:createControls()
  local rows = math.floor((self.height - window_margin * 3 - 60) / row_height)

  if rows ~= self.rows_shown then
    local function assigned_factory(num)
      return --[[persistable:machine_menu_assigned_button]] function(window)
        window:itemButtonClicked(num)
      end
    end
    local function smoke_factory(num)
      return --[[persistable:machine_menu_smoke_button]] function(window)
        window:itemButtonClicked(num)
      end
    end
    local function task_factory(num)
      return --[[persistable:machine_menu_task_button]] function(window)
        window:itemButtonClicked(num)
      end
    end
    local callback = --[[persistable:machine_menu_scrollbar]] function()
      self:scrollbarChange()
    end

    self.rows_shown = rows
    self.list_table = {}
    local y = window_margin
    for i = 1, rows, 1 do
      local smoke_panel = self:addBevelPanel(window_margin, y, 20, row_height, col_smoke_button)
      local smoke_button = smoke_panel:makeButton(0, 0, 20, row_height, nil, smoke_factory(i))
        :setTooltip(_S.tooltip.machine_menu.smoking)
      local assigned_panel = self:addBevelPanel(window_margin+20, y, 20, row_height, col_assigned_button)
      local assigned_button = assigned_panel:makeButton(0, 0, 20, row_height, nil, assigned_factory(i))
        :setTooltip(_S.tooltip.machine_menu.assigned)
      local task_panel = self:addBevelPanel(70, y, self.width - 130 - 40 - window_margin, row_height, col_bg)
      local task_button = task_panel:makeButton(0, 0, self.width - 130 - 40 - window_margin, row_height, nil, task_factory(i))
        :setTooltip(_S.tooltip.machine_menu.machine)
      local remaining_strength_panel = self:addBevelPanel(290, y, 40, row_height, col_shadow)
        :setTooltip(_S.tooltip.machine_menu.remaining_strength)
      local strength_panel = self:addBevelPanel(330, y, 40, row_height, col_shadow)
        :setTooltip(_S.tooltip.machine_menu.strength)
      table.insert(self.list_table, {
        assigned_panel = assigned_panel,
        assigned_button = assigned_button,
        smoke_panel = smoke_panel,
        smoke_button = smoke_button,
        task_panel = task_panel,
        task_button = task_button,
        remaining_strength_panel = remaining_strength_panel,
        strength_panel = strength_panel,
      })
      y = y + row_height
    end
    self.summary_panel = self:addColourPanel(50, y + 10, self.width - 50 - 40 - window_margin, 20,
                                             col_bg.red, col_bg.green, col_bg.blue)
    self.scrollbar = self:addColourPanel(self.width - window_margin - 20, window_margin, 20, row_height * rows,
                                         col_shadow.red, col_shadow.green, col_shadow.blue)
                         :makeScrollbar(col_bg, callback, 1, 1, 10, 1)
    self.close_button = self:addBevelPanel(window_margin, y + 20 + window_margin, self.width - 2 * window_margin, 40, col_bg):setLabel(_S.machine_menu.close)
      :makeButton(0, 0, self.width - 2 * window_margin, 40, nil, self.close):setTooltip(_S.tooltip.machine_menu.close)
  end
end

function UIMachineMenu:update()
  self.machine_list = {}
  local dispatcher = self.ui.app.world.dispatcher
  local assigned = 0
  local assign

  for _, entity in ipairs(self.ui.app.world.entities) do
    if class.is(entity, Machine) and not entity.master then
      if entity:getRemainingUses() > 0 then
        if dispatcher.call_queue[entity] then
          if dispatcher.call_queue[entity]["repair"].assigned then
            assign = true
            assigned = assigned + 1
          else
            assign = false
          end
        else
          assign = false
        end
        local machine = {
          object = entity,
          assigned = assign,
          name = entity.object_type.name,
          strength = entity.strength,
          remaining_strength = entity:getRemainingUses(),
          smoking = entity:isBreaking()
        }
        table.insert(self.machine_list, machine)
      end
    end
  end

  table.sort(self.machine_list,
    function(a,b)
      if a.remaining_strength == nil or b.remaining_strength == nil then return false end
      return a.remaining_strength < b.remaining_strength
    end
  )

  self.summary_panel:setLabel(_S.machine_menu.summary:format(#self.machine_list, assigned), nil, "left")
  self.scrollbar:setRange(1, math.max(1, #self.machine_list), self.rows_shown, self.scrollbar.value)
  self:scrollbarChange()
end

function UIMachineMenu:scrollToEntity(entity)
  local x, y = self.ui.app.map:WorldToScreen(entity.tile_x, entity.tile_y)
  local px, py = entity.th:getMarker()
  self.ui:scrollMapTo(x + px, y + py)
  self.ui:addWindow(UIMachine(self.ui, entity, entity:getRoom()))
end

function UIMachineMenu:itemButtonClicked(index)
  local machine = self.machine_list[index + self.scrollbar.value - 1]
  if machine and machine.object then
    if class.is(machine.object, Room) then
      self:scrollToRoom(machine.object)
    elseif class.is(machine.object, Entity) then
      self:scrollToEntity(machine.object)
    end
  end
end

function UIMachineMenu:scrollbarChange()
  local scroll_pos = self.scrollbar.value
  for i = 1, self.rows_shown, 1 do
    local machine = self.machine_list[i + scroll_pos - 1]
    local row = self.list_table[i]
    if machine then
      row.assigned_panel:setLabel(machine.assigned and "@" or '')
      row.assigned_button:enable(machine.assigned and true or false)
      row.smoke_panel:setLabel(machine.smoking and "!" or '')
      row.smoke_button:enable(machine.smoking and true or false)
      row.task_panel:setLabel(_S.machine_menu.description:format(machine.name, machine.object.tile_x, machine.object.tile_y), nil, "left")
      row.task_button:enable(true)
      row.remaining_strength_panel:setLabel(tostring(machine.remaining_strength))
      row.strength_panel:setLabel(tostring(machine.strength))
    else
      row.assigned_panel:setLabel("")
      row.task_panel:setLabel("")
      row.assigned_button:enable(false)
      row.smoke_button:enable(false)
      row.task_button:enable(false)
    end
  end
end

function UIMachineMenu:onTick()
  self:update()
end

function UIMachineMenu:close()
  Window.close(self)
end