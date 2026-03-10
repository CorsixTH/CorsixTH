--[[ Copyright (c) 2013 Manuel "Roujin" Wolf
Copyright (c) 2026 "lewri"

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
--       the field text, and optionally fields font and/or tooltip, which is a table containing text, x and y positions.
--!param callback (function) A function to be called when an item is selected. It is called with two parameters:
--       The parent window and the index of the selected item
--!param colour (table) Colour of the dropdown's list items, in the form of {red = ..., green = ..., blue = ...}.
-- Optional if parent_window is a UIResizable
--!param scrollbar_colour (table) Colour of the scrollbar's 'thumb', and
-- button hover in the form of {red = ..., green = ..., blue = ...}.
-- Optional if parent_window is a UIResizable
--!param disabled_colour (table) Colour of the disabled items in the form of {red = ..., green = ..., blue = ...}.
-- Optional.
function UIDropdown:UIDropdown(ui, parent_window, parent_button, items, callback, colour, scrollbar_colour, disabled_colour)
  assert(colour or parent_window.colour,
      "Dropdown has no colours available to it. Please specify one in the colour parameter.")
  self.colour = colour or parent_window.colour
  self.scrollbar_colour = scrollbar_colour
  if not self.scrollbar_colour then
    self.scrollbar_colour = {
      red = math.floor(self.colour.red * 0.9),
      green = math.floor(self.colour.green * 0.9),
      blue = math.floor(self.colour.blue * 0.9)
    }
  end
  self.disabled_colour = disabled_colour
  self:UIResizable(ui, 1, 1, self.colour, true, true)

  self.modal_class = "dropdown"
  self.esc_closes = true
  self.resizable = false
  self.default_button_sound = "selectx.wav"

  self.parent_window = parent_window
  self.parent_button = parent_button
  self.items = items
  self.callback = callback
  local scrollbar_threshold = 7
  local show_scrollbar = #items > scrollbar_threshold
  self.num_rows = math.min(scrollbar_threshold, #items)


  local panel = parent_button.panel_for_sprite

  local width = panel.w
  local height = panel.h

  self:setPosition(panel.x, panel.y + panel.h)

  self.item_panels = {}
  self.item_buttons = {}

  local y = 0
  for num = 1, self.num_rows do
    self.item_panels[num] = self:addBevelPanel(1, y + 1, width, height,
        self.colour, nil, nil, self.disabled_colour, self.scrollbar_colour)
      :setLabel(nil, nil, "center")
      :setTooltip(nil)
    self.item_buttons[num] = self.item_panels[num]
      :makeToggleButton(0, 0, width, height, nil,
        --[[persistable:dropdown_callback]] function() self:selectItem(num) end)
    y = y + height
  end

  if show_scrollbar then
    local scrollbar_width = 20
    local scrollbar_base = self:addBevelPanel(width, 1, scrollbar_width, self.num_rows * height, self.colour)
    scrollbar_base.lowered = true
    self.scrollbar = scrollbar_base:makeScrollbar(self.scrollbar_colour,
        --[[persistable:dropdown_scrollbar_callback]] function() self:updateButtons() end,
        1, math.max(#items, 1), self.num_rows)
    width = width + scrollbar_width
  end
  -- Adjust size
  self:overrideMinSize(width, height)
  self:setSize(width, y)
  self:updateButtons()
end

-- Updates buttons when scrolling.
function UIDropdown:updateButtons()
  for num = 1, self.num_rows do
    local panel = self.item_panels[num]
    local button = self.item_buttons[num]
    local item_index = self.scrollbar and num + self.scrollbar.value - 1 or num
    local item = self.items[item_index]
    if item then
      panel.label_font = nil
      panel:setLabel(item.text, item.font)
      panel:setTooltip(item.tooltip and unpack(item.tooltip) or nil)
      button:enable(not item.disabled)
    else
      panel:setLabel()
      panel:setTooltip()
      button:enable(false)
    end
  end
end

function UIDropdown:selectItem(number)
  local item_index = self.scrollbar and number + self.scrollbar.value - 1 or number
  local item = self.items[item_index]
  UIResizable.close(self)
  self.parent_button:setLabel(item.text, item.font):setToggleState(false)
  if self.callback then
    self.callback(self.parent_window, item_index)
  end
end

function UIDropdown:beginDrag(x, y)
  -- TODO: It may be undesirable anyway for dropdowns, but for dragging of sub-windows
  --       offsets are wrongly calculated (results in jump when dragging)
  -- Disable dragging
  return false
end

--! Let dropdown close when clicked outside of
--!param button (button) mouseclick
--!param x (coord) x coordinate
--!param y (coord) y coordinate
--!return continue triggering parent function
function UIDropdown:onMouseDown(button, x, y)
  if not self:hitTest(x, y) then
    self.parent_button:toggle()
    self:close()
    return false
  end
  return UIResizable.onMouseDown(self, button, x, y)
end

--! Allow the dropdown to scroll through mousewheel input
--!param x (int) UNUSED, 1 on down scroll, -1 on up scroll
--!param y (int) 1 on down scroll, -1 on up scroll
function UIDropdown:onMouseWheel(x, y)
  if x ~= 0 then return false end -- Do nothing on x scroll
  local bar = self.scrollbar

  if not self:hitTest(self.cursor_x, self.cursor_y) or not (bar and bar.enabled) then
    return false
  end

  local slider = bar.slider
  local track_len = slider.max_y - slider.min_y
  local steps = bar.max_value - bar.page_size

  -- Identify the nearest normalised slider position to our y position
  local slider_y = bar:getXorY() - slider.min_y
  local nearest_slot = math.round((slider_y * steps) / track_len)

  -- Next position
  local next_slot = nearest_slot - y

  -- Calculate the new slider y position
  local offset = math.round((next_slot * track_len) / steps)
  bar:setXorY(slider.min_y + offset)

  return true
end

function UIDropdown:onMouseMove(x, y, dx, dy)
  local panels = self.item_panels
  local buttons = self.item_buttons
  -- Items in the dropdown list overlap on the last pixel, causing two
  -- panels to appear 'active', however the higher up panel is what is
  -- actually selected. Separation by 1px causes gaps when UI scaled.
  local hit = false
  for row = 1, self.num_rows do
    if buttons[row].enabled then
      if self:hitTestPanel(x, y, panels[row]) and not hit then
        panels[row]:setColour(self.scrollbar_colour, true)
        hit = true
      else
        panels[row]:setColour(self.colour, true)
      end
    end
  end
  return UIResizable.onMouseMove(self, x, y, dx, dy)
end
