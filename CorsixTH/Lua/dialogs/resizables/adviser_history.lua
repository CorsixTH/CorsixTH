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

-- Timer, used to update the dialog only once per X ticks to reduce the burden.
local ticks_to_skip = 5
local tick_timer = ticks_to_skip

local row_height = 40
local header_height = 20
local window_margin = 15

function UIAdviserHistory:UIAdviserHistory(ui)
  local app = ui.app

  -- Calculate menu's height
  local height_divisor = 4
  local approx_rows_space = math.floor(app.config.height / height_divisor)
  self.rows = math.ceil(approx_rows_space / row_height)
  local rows_space = self.rows * row_height

  local width = 500
  local height = header_height + rows_space + window_margin * 2  -- header + values + margin (top and bottom)
  self:UIResizable(ui, width, height, col_bg)
  self.ui = ui
  self.modal_class = "adviser_history"

  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.05, 0.05)

  self.adviser_messages = {}
  self.list_table = {}

  self.default_button_sound = "selectx.wav"

  self.rows_shown = 0
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
  local rows = self.rows

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
    local delete_width = 30
    local message_width = 400
    local x = window_margin
    local y = window_margin


    -- Draw headers
    local delete_header = self:addBevelPanel(x, window_margin, delete_width, header_height, col_highlight)
    local delete_all_button = delete_header:makeButton(0, 0, delete_width, header_height, nil, deleteAllButtonClicked)
          :setTooltip(_S.tooltip.adviser_history.header.delete_message):setLabel("X", self.white_font, "center")
    x = x + delete_width

    local message_header = self:addBevelPanel(x, window_margin, message_width, header_height, col_highlight)
        :setLabel(_S.adviser_history.message):setTooltip(_S.tooltip.adviser_history.header.message)
    x = x + message_width
    y = y + header_height

    -- Draw rows
    for i = 1, rows, 1 do
      x = window_margin
      local delete_panel = self:addBevelPanel(x, y, delete_width, row_height, col_delete_button)
      local delete_button = delete_panel:makeButton(0, 0, delete_width, row_height, nil, delete_factory(i))
      x = x + delete_width

      local message_panel = self:addBevelPanel(x, y, message_width, row_height, col_bg)
          :setTooltip(_S.tooltip.adviser_history.message):setForceWrap(true)
      x = x + message_width
      y = y + row_height

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
    self.scrollbar = self:addColourPanel(x, window_margin + 20, 24, row_height * rows, --y = window_margin + close button height
          col_shadow.red, col_shadow.green, col_shadow.blue)
        :makeScrollbar(col_bg, scrollbarMovedCallback, 1, 1, 10, 1)
    -- Add close button
    self:addPanel(337, x,  8):makeButton(0, 0, 24, 24, 338, self.close)
        :setTooltip(_S.tooltip.adviser_history.close)
  end
end

function UIAdviserHistory:update()
  self.adviser_messages = self.ui.adviser.message_history
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
  -- Dialog does not update on every tick
  tick_timer = tick_timer - 1
  if tick_timer <= 0 then
    tick_timer = ticks_to_skip
    self:update()
  end
end

function UIAdviserHistory:close()
  Window.close(self)
end