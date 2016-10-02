--[[ Copyright (c) 2013 Manuel "Roujin" Wolf

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

--! Dropdown "window" used for selection of one item from a list.
class "UIDropdown" (UIResizable)

---@type UIDropdown
local UIDropdown = _G["UIDropdown"]

--! Constructor for the dropdown "window"
--!param ui (UI) The ui the window is created in
--!param parent_window (Window) The window that this dropdown will be attached to
--!param parent_button (Button) The button in the parent_window that this dropdown will be positioned under
--!param items (table) A list of items for the list to display, where each item is a table with at least
--       the field text, and optionally fields font and/or tooltip
--!param callback (function) A function to be called when an item is selected. It is called with two parameters:
--       The parent window and the index of the selected item
--!param colour (table) A colour in the form of {red = ..., green = ..., blue = ...}. Optional if parent_window is a UIResizable
function UIDropdown:UIDropdown(ui, parent_window, parent_button, items, callback, colour)
  local col = colour or parent_window.colour
  self:UIResizable(ui, 1, 1, col, true, true)

  self.modal_class = "dropdown"
  self.esc_closes = true
  self.resizable = false
  self.default_button_sound = "selectx.wav"

  self.parent_window = parent_window
  self.parent_button = parent_button
  self.items = items
  self.callback = callback

  local panel = parent_button.panel_for_sprite

  local width = panel.w
  local height = panel.h

  -- TODO: Somehow make the dropdown disappear if the user clicks outside it.
  self:setPosition(panel.x, panel.y + panel.h)

  local y = 0
  for i, item in ipairs(items) do
    self:addBevelPanel(1, y + 1, width - 2, height - 2, parent_window.colour):setLabel(item.text, item.font)
      :makeButton(-1, -1, width, height, nil, --[[persistable:dropdown_callback]] function() self:selectItem(i) end)
      -- TODO: tooltips for dropdown items currently deactivated because alignment and conditions for displaying are off for tooltips on sub-windows
      --:setTooltip(item.tooltip)
    y = y + height
  end

  -- Adjust size
  self:setSize(width, y)
end

function UIDropdown:selectItem(number)
  UIResizable.close(self)
  self.parent_button:setLabel(self.items[number].text, self.items[number].font):setToggleState(false)
  if self.callback then
    self.callback(self.parent_window, number)
  end
end

function UIDropdown:beginDrag(x, y)
  -- TODO: It may be undesirable anyway for dropdowns, but for dragging of sub-windows
  --       offsets are wrongly calculated (results in jump when dragging)
  -- Disable dragging
  return false
end
