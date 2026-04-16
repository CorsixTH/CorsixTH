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

--! Class for resizable windows.
--! If resizable is set to true, the user can resize by clicking and dragging
--any of the corners.
class "UIResizable" (Window)

---@type UIResizable
local UIResizable = _G["UIResizable"]

local border_offset_x = 9
local border_offset_y = 9
local border_size_x = 40
local border_size_y = 40

-- Constants for most button's width and height
local BTN_WIDTH = 135
local BTN_HEIGHT = 20

-- Colour definitions
local col = {
  bg             = Colours.PanelDefault,
  button         = Colours.PanelDefault,
  setting        = Colours.Setting,
  setting_active = Colours.SettingActive,
  scrollbar      = Colours.Scrollbar,
  disabled       = Colours.Disabled,
  title          = Colours.Title,
  caption        = Colours.Caption,
  textbox        = Colours.Textbox,
}

function UIResizable:UIResizable(ui, width, height, colour, no_borders, background_bevel)
  self:Window()

  local app = ui.app
  self.ui = ui
  self.resizable = false -- by default, not user-resizable
  if not no_borders then
    self.border_sprites = app.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
  end

  if background_bevel then
    self.background_panel = self:addBevelPanel(0, 0, 0, 0, colour)
    self.background_panel.lowered = true
  else
    self.background_panel = self:addColourPanel(0, 0, 0, 0, 0, 0, 0)
  end

  -- Minimum size. Can be changed per window, but should never be smaller than this
  -- because it would result in visual glitches
  self.min_width = 50
  self.min_height = 50

  self.border_pos = {}
  self.border_pos.left = -border_offset_x
  self.border_pos.upper = -border_offset_y

  -- NB: intentionally calling like this to allow subclasses to extend setSize without being called from here
  UIResizable.setSize(self, width, height)
  self:setColour(colour)

  -- Tracks the current position of the object
  self._current_option_index = 1
  self.column_count = 1
end

--! Apply the initial width and height of the window
--!param width (int) The initial width
--!param height (int) The initial height
function UIResizable:setSize(width, height)
  width = math.max(self.min_width, width)
  height = math.max(self.min_height, height)

  self.width = width
  self.height = height
  self.background_panel.w = width
  self.background_panel.h = height

  self.border_pos.right = self.width
  self.border_pos.corner_right = self.width - border_size_x

  self.border_pos.lower = self.height
  self.border_pos.corner_lower = self.height - border_size_y
end

--! Must be called before UIResizable:setSize
--!param min_width (int) The new minimum width of the window
--!param min_height (int) The new minimum height of the window
function UIResizable:overrideMinSize(min_width, min_height)
  self.min_width = min_width
  self.min_height = min_height
end

function UIResizable:setColour(colour)
  self.colour = colour
  self.background_panel:setColour(colour)
end

function UIResizable:draw(canvas, x, y)
  local sprites = self.border_sprites
  if sprites then
    local s = TheApp.config.ui_scale
    local xabs = self.x * s + x
    local yabs = self.y * s + y

    for xpos = xabs + border_size_x * s, xabs + self.border_pos.corner_right * s - 1, border_size_x * s do
      sprites:draw(canvas, 11, xpos, yabs + self.border_pos.upper * s, { scaleFactor = s }) -- upper edge
      sprites:draw(canvas, 16, xpos, yabs + self.border_pos.lower * s, { scaleFactor = s }) -- lower edge
    end
    for ypos = yabs + border_size_y * s, yabs + self.border_pos.corner_lower * s - 1, border_size_y * s do
      sprites:draw(canvas, 13, xabs + self.border_pos.left * s, ypos, { scaleFactor = s })  -- left edge
      sprites:draw(canvas, 14, xabs + self.border_pos.right * s, ypos, { scaleFactor = s }) -- right edge
    end

    sprites:draw(canvas, 10, xabs + self.border_pos.left * s, yabs + self.border_pos.upper * s, { scaleFactor = s }) -- upper left corner
    sprites:draw(canvas, 12, xabs + self.border_pos.corner_right * s, yabs + self.border_pos.upper * s, { scaleFactor = s }) -- upper right corner
    sprites:draw(canvas, 15, xabs + self.border_pos.left * s, yabs + self.border_pos.corner_lower * s, { scaleFactor = s }) -- lower left corner
    sprites:draw(canvas, 17, xabs + self.border_pos.corner_right * s, yabs + self.border_pos.corner_lower * s, { scaleFactor = s }) -- lower right corner
  end
  -- Draw window components
  Window.draw(self, canvas, x, y)
end

function UIResizable:onMouseDown(button, x, y)
  local res = self.resizable and self:hitTestCorners(x, y)
  if res then
    self:beginResize(x, y, res)
    return true
  end
  return Window.onMouseDown(self, button, x, y)
end

function UIResizable:hitTest(x, y)
  local s = TheApp.config.ui_scale
  if x >= 0 and y >= 0 and x < self.width * s and y < self.height * s then -- inside window
    return Window.hitTest(self, x, y)
  end
  local sprites = self.border_sprites
  if not sprites then
    return false
  end
  if x < -9 * s or y < -9 * s or x >= self.width * s + 9 * s or y >= self.height * s + 9 * s then -- outside border bounds
    return false
  end
  if (0 <= x and x < self.width * s) or (0 <= y and y < self.height * s) then -- edges (upper/lower/left/right)
    return true
  end
  return self:hitTestCorners(x, y) and true
end

--! Tests if any of the four corners of the window border is hit
--!param x the x coordinate to test
--!param y the y coordinate to test
--!return (boolean or string) false if not hit, else a string to denote which corner was hit (can be "ul", "ur", "ll" or "lr")
function UIResizable:hitTestCorners(x, y)
  if self.border_sprites then
    local s = TheApp.config.ui_scale
    local yzone = (-9 * s <= y and y < 0) and "u" or (self.height * s <= y and y < self.height * s + 9 * s) and "l"
    local xzone = (-9 * s <= x and x < 0) and "l" or (self.width * s <= x and x < self.width * s + 9 * s) and "r"

    local sprite_ids = {ul = 10, ur = 12, ll = 15, lr = 17}
    if yzone and xzone then
      local zone = yzone .. xzone
      local dy = (yzone == "u" and self.border_pos.upper or self.border_pos.corner_lower)
      local dx = (xzone == "l" and self.border_pos.left  or self.border_pos.corner_right)
      return self.border_sprites:hitTest(sprite_ids[zone], x - dx, y - dy) and zone
    end
  end
  return false
end

--[[ Initiate resizing of the resizable window.
!param x The X position of the cursor in window coordinates.
!param y The Y position of the cursor in window coordinates.
!param mode Either one of "ul", "ur", "ll" or "lr" to denote in which direction to resize. (upper/lower + left/right)
]]
function UIResizable:beginResize(x, y, mode)
  local orig_x = self.x
  local orig_y = self.y
  local ref_x = self.x + x
  local ref_y = self.y + y
  local orig_width = self.width
  local orig_height = self.height

  self.dragging = true
  self.ui.drag_mouse_move = --[[persistable:window_resize_mouse_move]] function (sx, sy)
    -- sx and sy are cursor screen co-ords. Convert to relative change.
    sx = sx - ref_x
    sy = sy - ref_y

    local invert_x = mode == "ul" or mode == "ll"
    local invert_y = mode == "ul" or mode == "ur"

    sx = invert_x and -sx or sx
    sy = invert_y and -sy or sy

    self:setSize(orig_width + sx, orig_height + sy)
    local new_x, new_y

    if invert_x then
      new_x = orig_x + orig_width - self.width
    end
    if invert_y then
      new_y = orig_y + orig_height - self.height
    end

    if new_x or new_y then
      self:setPosition(new_x or orig_x, new_y or orig_y)
    end
  end
end

-- Create our setting items. This create a caption/label for the setting
-- and the setting itself. We return both elements of the setting (panel
-- and the button made from the panel)
function UIResizable:createOptionsElement(option_label, option_tooltip,
    setting_label, setting_tooltip, setting_colours, callback,
    toggle_state)
  local y_pos = self:_getOptionYPos()
  local x_offset = 300 * (self.column_count - 1)
  local label_x, setting_x = 20 + x_offset, 165 + x_offset

  -- Make the setting name panel
  self:addBevelPanel(label_x, y_pos, BTN_WIDTH, BTN_HEIGHT, col.caption, col.bg, col.bg)
    :setLabel(option_label)
    :setTooltip(option_tooltip)
    .lowered = true
  local s_col = setting_colours
  -- Make the setting value panel
  local setting_panel = self:addBevelPanel(setting_x, y_pos, BTN_WIDTH,
      BTN_HEIGHT, s_col.bg, s_col.highlight, s_col.shadow,
      s_col.disabled, s_col.active)
    :setLabel(setting_label)
    :setTooltip(setting_tooltip)
  -- Make the value panel a button
  local setting_button = setting_panel:makeToggleButton(0, 0, BTN_WIDTH,
      BTN_HEIGHT, nil, callback)
    :setToggleState(toggle_state)
  -- Return the setting value info
  return setting_panel, setting_button
end

--- Calculates the Y position for the dialog box in the option menu
-- and increments along the current position for the next element
-- @return The Y position to place the element at
function UIResizable:_getOptionYPos()
  -- Offset from top of options box
  local STARTING_Y_POS = 15
  -- Y Height is 20 for panel size + 10 for spacing
  local Y_HEIGHT = 30

  -- Multiply by the index so that index=1 is at STARTING_Y_POS
  local calculated_pos = STARTING_Y_POS + Y_HEIGHT * (self._current_option_index - 1)
  self._current_option_index = self._current_option_index + 1
  return calculated_pos
end

--! Resets the index to start at the top of a new column, below the title,
-- for the Y position calculation.
function UIResizable:_startNewColumn()
  self._current_option_index = 2
  self.column_count = self.column_count + 1
end

function UIResizable:afterLoad(old, new)
  Window.afterLoad(self, old, new)
  if old < 65 then
    -- added min_width and min_height
    self.min_width = 50
    self.min_height = 50
  end
end
