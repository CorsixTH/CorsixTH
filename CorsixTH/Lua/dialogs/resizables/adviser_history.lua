--[[ Copyright (c) 2025 Damian "ShiroAka"

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

--! Adviser message history
class "UIAdviserHistory" (UIResizable)

---@type UIAdviserHistory
local UIAdviserHistory = _G["UIAdviserHistory"]

local col_bg = { red = 60, green = 174, blue = 201, }
local col_highlight = { red = 47, green = 154, blue = 190, }
local col_shadow = { red = 36, green = 138, blue = 158 }
local col_delete_button = { red = 219, green = 36, blue = 36 }

function UIAdviserHistory:UIAdviserHistory(ui)
  local app = ui.app

  self.ui = ui
  self.modal_class = "adviser_history"

  self.esc_closes = true
  self.resizable = false

  self.adviser_messages = {} -- Contains all the messages in the adviser.adviser_history prop
  self.list_table = {}       -- List of controls in this dialog

  self.default_button_sound = "selectx.wav"

  self.rows_shown = 0

  self.row_height = 40
  self.header_height = 20
  self.window_margin = 15
  self.delete_col_width = 30
  self.message_col_width = 400

  local total_width = 500
  local height_divisor = 4

  self.approx_rows_space = math.floor(app.config.height / height_divisor)
  self.num_visible_rows = math.ceil(self.approx_rows_space / self.row_height)

  local rows_space = self.num_visible_rows * self.row_height
  local total_height = self.header_height + rows_space + self.window_margin * 2  -- header + values + margin (top and bottom)

  self:UIResizable(ui, total_width, total_height, col_bg)
  self:setDefaultPosition(0.05, 0.05)
  self:createControls()
  self:update()
end

function UIAdviserHistory:deleteButtonClicked(message_index)
  self.ui.adviser:removeMessageFromHistory(message_index)
end

local deleteAllButtonClicked = --[[persistable:adviser_history_delete_all_button]] function(self)
  self.ui.adviser:deleteAllMessagesFromHistory()
end

function UIAdviserHistory:createControls()
  local rows = self.num_visible_rows

  self.panel_sprites = self.ui.app.gfx:loadSpriteTable("QData", "Req03V", true)
  self.white_font = self.ui.app.gfx:loadFontAndSpriteTable("QData", "Font01V")

  if rows ~= self.rows_shown then
    local function delete_factory(num)
      return --[[persistable:adviser_history_delete_button]] function()
        self:deleteButtonClicked(num)
      end
    end
    local scrollbarMovedCallback = --[[persistable:adviser_history_scrollbar]] function()
      self:scrollbarMoved()
    end

    self.rows_shown = rows
    self.list_table = {}
    local x = self.window_margin
    local y = self.window_margin


    -- Draw headers
    local delete_header = self:addBevelPanel(x, self.window_margin, self.delete_col_width, self.header_height, col_highlight)
    local delete_all_button = delete_header:makeButton(0, 0, self.delete_col_width, self.header_height, nil, deleteAllButtonClicked)
          :setTooltip(_S.tooltip.adviser_history.header.delete_message):setLabel("X", self.white_font, "center")
    x = x + self.delete_col_width

    local message_header = self:addBevelPanel(x, self.window_margin, self.message_col_width, self.header_height, col_highlight)
        :setLabel(_S.adviser_history.message):setTooltip(_S.tooltip.adviser_history.header.message)
    x = x + self.message_col_width
    y = y + self.header_height

    -- Draw rows
    for i = 1, rows, 1 do
      x = self.window_margin
      local delete_panel = self:addBevelPanel(x, y, self.delete_col_width, self.row_height, col_delete_button)
      local delete_button = delete_panel:makeButton(0, 0, self.delete_col_width, self.row_height, nil, delete_factory(i))
      x = x + self.delete_col_width

      local message_panel = self:addBevelPanel(x, y, self.message_col_width, self.row_height, col_bg)
          :setTooltip(_S.tooltip.adviser_history.message):setForceTextWrap(true)
      x = x + self.message_col_width
      y = y + self.row_height

      table.insert(self.list_table, {
        delete_header = delete_header,
        delete_all_button = delete_all_button,
        message_header = message_header,
        delete_panel = delete_panel,
        delete_button = delete_button,
        message_panel = message_panel,
      })
    end

    x = x + 10 -- Add 10 pixels from end of the message rows

    -- Add scrollbar
    self.scrollbar = self:addColourPanel(x, self.window_margin + 20, 24, self.row_height * rows, --y = self.window_margin + close button height
          col_shadow.red, col_shadow.green, col_shadow.blue)
        :makeScrollbar(col_bg, scrollbarMovedCallback, 1, 1, 10, 1)
    -- Add close button
    self:addPanel(337, x,  8):makeButton(0, 0, 24, 24, 338, self.close)
        :setTooltip(_S.tooltip.adviser_history.close)
  end
end

function UIAdviserHistory:update()
  -- self.adviser_messages = self.ui.adviser.message_history --> WRONG, this way both variables point to the same table

  self.adviser_messages = {}
  -- Clone the list
  for i = 1, #self.ui.adviser.message_history do
    self.adviser_messages[i] = self.ui.adviser.message_history[i]
  end

  self.scrollbar:setRange(1, math.max(1, #self.adviser_messages), self.rows_shown, self.scrollbar.value)
  self:scrollbarMoved()
end

function UIAdviserHistory:scrollbarMoved()
  local scroll_pos = self.scrollbar.value
  for i = 1, self.rows_shown, 1 do
    local message = self.adviser_messages[i + scroll_pos - 1]
    local row = self.list_table[i]
    if message then
      row.message_panel:setLabel(" " .. message, nil, "left"):setColour(col_bg)
      row.delete_button:setLabel("X", self.white_font, "center"):setTooltip(_S.tooltip.adviser_history.delete_message)
      row.delete_button:enable(true)
    else
      row.message_panel:setLabel(""):setColour(col_shadow)
      row.delete_button:setLabel(""):setTooltip(nil)
      row.delete_button:enable(false)
    end
  end
end

function UIAdviserHistory:onTick()
  -- The adviser.message_history has a cap of 20 messages by default
  -- New messages only get added to the top (it's a stack) or, if duplicate, a message
  -- gets moved from the middle to the top.

  -- Checking the lenght of both lists would fail if a message was moved from the middle to the top due to duplication.
  -- So we just check if the top string between lists has changed to determine if we need to update
  local current_history_top = self.adviser_messages[1]
  local new_history_top = self.ui.adviser.message_history[1]

  if current_history_top ~= new_history_top then
    self:update()
  end
end

function UIAdviserHistory:close()
  Window.close(self)
end

