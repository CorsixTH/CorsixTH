--[[ Copyright (c) 2010 Sam Wong

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

dofile("dialogs/resizable")

--! Calls Dispatcher Window
class "UICallsDispatcher" (UIResizable)

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

local col_button = {
  red = 84,
  green = 200,
  blue = 84,
}

local col_shadow = {
  red = 134,
  green = 126,
  blue = 178,
}

function UICallsDispatcher:UICallsDispatcher(ui)
  local app = ui.app
  self:UIResizable(ui, 320, 350, col_bg)
  self.ui = ui
  self.dispatcher = app.world.dispatcher
  self.on_top = false
  self.esc_closes = true
  self.resizable = false

  self.call_list = {}
  self.list_table = {}
  self.rows_shown = 0
  self:createControls()  
  self:setDefaultPosition(0.05, 0.05)
  
  self.default_button_sound = "selectx.wav"

  self.dispatcher:addChangeCallback(self.update, self)
  self:update()
end

local row_height = 20
local window_margin = 15

function UICallsDispatcher:createControls()
  local rows = math.floor((self.height - window_margin * 3 - 60) / row_height)
  
  if rows ~= self.rows_shown then
    local function assigned_factory(num)
      return --[[persistable:calls_dispatcher_assigned_button]] function(self)
        self:itemButtonClicked(num)
      end
    end
    local function task_factory(num)
      return --[[persistable:calls_dispatcher_task_button]] function(self)
        self:itemButtonClicked(num)
      end
    end
    local callback = --[[persistable:calls_dispatcher_scrollbar]] function() 
      self:scrollbarChange()
    end

    self.rows_shown = rows
    self.list_table = {}
    local y = window_margin
    for i = 1, rows, 1 do
      local assigned_panel = self:addBevelPanel(window_margin, y, 20, row_height, col_button)
      local assigned_button = assigned_panel:makeButton(0, 0, 20, row_height, nil, assigned_factory(i))
        :setTooltip(_S.tooltip.calls_dispatcher.assigned)
      local task_panel = self:addBevelPanel(50, y, self.width - 50 - 40 - window_margin, row_height, col_bg)
      local task_button = task_panel:makeButton(0, 0, self.width - 50 - 40 - window_margin, row_height, nil, task_factory(i))
        :setTooltip(_S.tooltip.calls_dispatcher.task)
      table.insert(self.list_table, {
        assigned_panel = assigned_panel,
        assigned_button = assigned_button,
        task_panel = task_panel,
        task_button = task_button,
      })
      y = y + row_height
    end
    self.summary_panel = self:addColourPanel(50, y + 10, self.width - 50 - 40 - window_margin, 20,
                                             col_bg.red, col_bg.green, col_bg.blue)
    self.scrollbar = self:addColourPanel(self.width - window_margin - 20, window_margin, 20, row_height * rows,
                                         col_shadow.red, col_shadow.green, col_shadow.blue)
                         :makeScrollbar(col_bg, callback, 1, 1, 10, 1)
    self.close_button = self:addBevelPanel(window_margin, y + 20 + window_margin, self.width - 2 * window_margin, 40, col_bg):setLabel(_S.calls_dispatcher.close)
      :makeButton(0, 0, self.width - 2 * window_margin, 40, nil, self.close):setTooltip(_S.tooltip.calls_dispatcher.close)
  end
end

function UICallsDispatcher:update()
  self.call_list = {}
  local assigned = 0
  for object, queue in pairs(self.dispatcher.call_queue) do
    for key, call in pairs(queue) do
      table.insert(self.call_list, call)
      if call.assigned then
        assigned = assigned + 1
      end
    end
  end
  table.sort(self.call_list, 
    function(a,b)
      if a.created == nil or b.created == nil then return false end
      return a.created < b.created
    end
  )
  
  self.summary_panel:setLabel(_S.calls_dispatcher.summary:format(#self.call_list, assigned), nil, "left")
  self.scrollbar:setRange(1, math.max(1, #self.call_list), self.rows_shown, self.scrollbar.value)
  self:scrollbarChange()
end

function UICallsDispatcher:scrollToEntity(entity)
  local x, y = self.ui.app.map:WorldToScreen(entity.tile_x, entity.tile_y)
  local px, py = entity.th:getMarker()
  self.ui:scrollMapTo(x + px, y + py)
end

function UICallsDispatcher:scrollToRoom(room)
  local x, y = self.ui.app.map:WorldToScreen(room.x + room.width / 2, room.y + room.height / 2)
  self.ui:scrollMapTo(x, y)
end

function UICallsDispatcher:itemButtonClicked(index)
  local call = self.call_list[index + self.scrollbar.value - 1]
  if call and call.assigned then
    self.ui:addWindow(UIStaff(self.ui, call.assigned))
  end
  if call and call.object then
    if class.is(call.object, Room) then
      self:scrollToRoom(call.object)
    elseif class.is(call.object, Entity) then
      self:scrollToEntity(call.object)
    end
  end
end

function UICallsDispatcher:scrollbarChange()
  local scroll_pos = self.scrollbar.value
  for i = 1, self.rows_shown, 1 do
    local call = self.call_list[i + scroll_pos - 1]
    local row = self.list_table[i]
    if call then
      row.assigned_panel:setLabel(call.assigned and "@" or '')
      row.assigned_button:enable(call.assigned and true or false)
      row.task_panel:setLabel((call.description and call.description or call.key), nil, "left")
      row.task_button:enable(true)
    else
      row.assigned_panel:setLabel("")
      row.task_panel:setLabel("")
      row.assigned_button:enable(false)
      row.task_button:enable(false)
    end
  end
end

function UICallsDispatcher:close()
  self.dispatcher:removeChangeCallback(self.update)
  Window.close(self)
end
