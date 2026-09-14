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
-- Horizontal distance from the label to its button
local label_button_gap = 20
-- Width of the title/caption label
local title_width = 170
-- Extra vertical padding from the last element to the standard back button
local big_button_padding = 5
-- Vertical distance from the bottom of one element to the top of the next below
local element_spacing = 10

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

  -- These values can be changed per window in child classes
  -- Minimum size. Should never be smaller than this because it would result in visual glitches
  self.min_width = 50
  self.min_height = 50

  -- Standard width and height for labels and buttons
  self.label_width = 135
  self.label_height = 20
  self.btn_width = 135
  self.btn_height = 20
  self.big_button_height = 40 -- Width is derived from dialog width
  -- Gap from the border to any internal element
  self.margin = 15

  -- Standard height of the dialog, what is needed for the title, labels/buttons and back button
  self.extra_height = (self.margin + self.label_height + element_spacing + big_button_padding +
      self.big_button_height + self.margin)

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
    local s = TheApp.gfx:getUIScale()
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
  local s = TheApp.gfx:getUIScale()
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
    local s = TheApp.gfx:getUIScale()
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

-- Determine the button label contents
--!param value - Boolean/integer/string/nil, the setting value
--!param name - string, name of the config and languages strings
--!param custom_labels - Boolean, whether there are language strings more specific than "on"/"off"
--!param default_string - string, name of the language string shown when value is nil
--!return The localised display text for the button
function UIResizable:_getButtonLabel(value, name, custom_labels, default_string)
  if type(value) == "boolean" then
    if custom_labels then
      return value and _S[self.strings_ref][name .. "_on"] or _S[self.strings_ref][name .. "_off"]
    end
    return value and _S.options_window.option_on or _S.options_window.option_off
  elseif type(value) == "number" then
    return tostring(value)
  elseif (not value) and default_string then
    return _S[self.strings_ref][default_string]
  end
  return value
end

--[[! Build the dialog from the information set in the dialog class creation
This function uses the contents of the self.entry_list table, which is a list of tables containing -
  name - The internal name of the entry, used for the name of the label, button, tooltip and error strings. Required
  func - The function that changes the setting(s). If missing, a minimal function is made by UIResizable:_buttonPressed
  custom_labels - Boolean. For when there are custom on and off labels to be used on place of "On" and "Off"
  raised - Boolean, for when the button should be raised, eg leads to a further dialog
  info - Boolean, to show the user an info message after changing a setting
  default_string - A localised string to show when the setting is empty
  default_value - A value for a setting that is not held in the config file (eg savegame folder)
  reset_func - The reset button's function which clears a setting and resets the label and button.
      This also marks an entry where false should mean unset, not off.
  new_column - Boolean, in the first item of the new column
]]
function UIResizable:buildDialog()
  self.on_top = self.mode == "menu"
  self.esc_closes = true
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  self.labels = {}
  self.buttons = {}

  -- Window parts definition
  -- Title
  local title_y_pos = self:_getOptionYPos()
  local title_x_pos = math.floor((self.width - title_width) / 2)
  self:addBevelPanel(title_x_pos, title_y_pos, title_width, self.label_height, col.title)
      :setLabel(_S[self.strings_ref].caption).lowered = true

  -- Labels and buttons
  for _, entry in ipairs(self.entry_list) do
    if entry.new_column then self:_startNewColumn() end
    local name, value = entry.name, self.ui.app.config[entry.name]
    if not value and entry.reset_func and entry.default_value then value = entry.default_value end
    local current_value = self:_getButtonLabel(value, name, entry.custom_labels, entry.default_string)
    self.labels[name], self.buttons[name] = self:createOptionsElement(
      _S[self.strings_ref][name], _S.tooltip[self.strings_ref][name],
      current_value, _S.tooltip[self.strings_ref][name],
      { bg = col.setting, active = entry.raised and col.setting_active },
      self:_buttonPressed(name, entry.func, entry.info and _S.errors[name]),
      (not entry.raised) and value, entry.default_value, entry.reset_func)
  end

  -- Back
  -- Recalculate width for accurate back button width
  local width = (self.margin + self.label_width + label_button_gap + self.btn_width) * self.column_count
  if not self.custom_back_button then
    local big_button_y_pos = self:_getOptionYPos() + big_button_padding
    local big_button_width = width - self.margin * 2
    self:addBevelPanel(self.margin, big_button_y_pos, big_button_width, self.big_button_height, col.bg)
      :setLabel(_S.options_window.back)
      :makeButton(0, 0, big_button_width, self.big_button_height, nil, self.buttonBack)
      :setTooltip(_S.tooltip.options_window.back)
  else -- X co-ord for the custom back button and other additional buttons
    self.x_pos = {
      self.margin,
      self.margin + self.label_width + 5,
      self.margin + self.label_width + label_button_gap + self.label_width,
      self.margin + self.label_width + 5 + label_button_gap + self.label_width + self.btn_width,
    }
  end

  -- After building the dialog contents, adjust size to fit around them
  local height = #self.entry_list * (element_spacing + self.btn_height) + self.extra_height
  self:overrideMinSize(width, height)
  self:setSize(width, height)
end

-- Create our setting items. This create a caption/label for the setting
-- and the setting itself. We return both elements of the setting (panel
-- and the button made from the panel)
function UIResizable:createOptionsElement(option_label, option_tooltip,
    setting_label, setting_tooltip, setting_colours, callback,
    toggle_state, default_value, reset_func)
  local y_pos = self:_getOptionYPos()
  local column_width = self.label_width + label_button_gap + self.btn_width
  local x_offset = column_width * (self.column_count - 1)
  local label_x, setting_x = self.margin + x_offset, self.label_width + label_button_gap + x_offset
  local btn_width = self.btn_width - (reset_func and self.btn_height or 0)

  -- Make the setting name panel
  local setting_panel = self:addBevelPanel(label_x, y_pos, self.label_width, self.label_height,
      col.caption, col.bg, col.bg)
    :setLabel(option_label)
    :setTooltip(option_tooltip)
  setting_panel.lowered = true
  local s_col = setting_colours or { bg = col.setting }
  -- Make the setting value button
  local setting_button = self:addBevelPanel(setting_x, y_pos, btn_width, self.btn_height,
      s_col.bg, s_col.highlight, s_col.shadow, s_col.disabled, s_col.active)
    :setLabel(setting_label, self.built_in_font)
    :setTooltip(setting_tooltip)
    :setAutoClip(self.autoclip)
    :makeToggleButton(0, 0, btn_width, self.btn_height, nil, callback)
    :setToggleState(toggle_state)
  if reset_func then
    -- Add a square reset button at the end of the button
    local tooltip = type(default_value) == "function" and default_value(self) or default_value
    if tooltip then tooltip = _S.tooltip[self.strings_ref].reset_to_default:format(tooltip)
    else tooltip = _S.tooltip[self.strings_ref].clear_directory end
    self:addBevelPanel(setting_x + btn_width, y_pos, self.btn_height, self.btn_height, col.button)
      :setLabel("X")
      :makeButton(0, 0, self.btn_height, self.btn_height, nil, reset_func)
      :setTooltip(tooltip)
  end
  -- Return the setting value info
  return setting_panel, setting_button
end

--- Calculates the Y position for the dialog box in the option menu
-- and increments along the current position for the next element
-- @return The Y position to place the element at
function UIResizable:_getOptionYPos()
  -- Multiply by the index so that index=1 is at the margin (15)
  local calculated_pos = self.margin +
      (element_spacing + self.btn_height) * (self._current_option_index - 1)
  self._current_option_index = self._current_option_index + 1
  return calculated_pos
end

--! Resets the index to start at the top of a new column, below the title,
-- for the Y position calculation.
function UIResizable:_startNewColumn()
  self._current_option_index = 2
  self.column_count = self.column_count + 1
end

--! Creates the button press function
--!param setting The internal name of the setting
--!param func (function) A function from the dialog file for more complex needs
--!param info A localised info message shown after changing a setting
--!return function
function UIResizable:_buttonPressed(setting, func, info)
  return function()
    local app = self.ui.app
    if func then
      func(self, app, self.buttons[setting])
    else
      app.config[setting] = not app.config[setting]
    end
    if self.reload then self:reload() end
    app:saveConfig()
    if info then self.ui:addWindow(UIInformation(self.ui, {info})) end
  end
end

function UIResizable:afterLoad(old, new)
  Window.afterLoad(self, old, new)
  if old < 65 then
    -- added min_width and min_height
    self.min_width = 50
    self.min_height = 50
  end
end
