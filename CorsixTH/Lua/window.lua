--[[ Copyright (c) 2009 Peter "Corsix" Cawley

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

dofile "persistance"

--! Base class for user-interface dialogs.
class "Window"

-- NB: pressed mouse buttons are denoted with a "mouse_" prefix in buttons_down,
-- i.e. mouse_left, mouse_middle, mouse_right
Window.buttons_down = permanent"Window.buttons_down" {}

function Window:Window()
  self.x = 0
  self.y = 0
  self.panels = {
  }
  self.buttons = {
  }
  self.tooltip_regions = {
  }
  self.scrollbars = {
  }
  self.textboxes = { -- list of textboxes in that window. NB: (Game)UI also uses this.
  }                  -- Take care not to handle things twice as UI is subclass of window!
  self.key_handlers = {--[[a set]]}
  self.windows = false -- => {} when first window added
  self.active_button = false
  self.blinking_button = false
  self.blink_counter = 0
  self.panel_sprites = false
  self.visible = true
  self.draggable = true
end

-- Sets the window's onscreen position. Each of x and y can be:
-- Integers >= 0 - Absolute pixel positions of top/left edge of window relative
--                 to top/left edge of screen
-- Integers < 0 - Absolute pixel positions of right/bottom edge of window
--                relative to right/bottom edge of screen. Use -0.1 to mean -0.
-- Reals in [0, 1) - 
function Window:setPosition(x, y)
  -- Save values to recalculate x and y on screen resolution change
  self.x_original = x
  self.y_original = y
  -- Convert x and y to absolute pixel positions with regard to top/left
  local w, h = TheApp.config.width, TheApp.config.height
  if x < 0 then
    x = math.ceil(w - self.width + x)
  elseif x < 1 then
    x = math.floor((w - self.width) * x + 0.5)
  end
  if y < 0 then
    y = math.ceil(h - self.height + y)
  elseif y < 1 then
    y = math.floor((h - self.height) * y + 0.5)
  end
  self.x = x
  self.y = y
end

-- Sets the window's default onscreen position and onscreen position.
-- The given x and y are interpreted as for setPosition(x, y), and are the
-- default position for the window. If the user has previously repositioned a
-- window of the same type, then setDefaultPosition() will set the window to
-- that previous position, otherwise it sets it to the default position.
function Window:setDefaultPosition(x, y)
  if self.ui then
    local config = self.ui.app.runtime_config.window_position
    if config then
      config = config[self:getSavedWindowPositionName()]
      if config then
        return self:setPosition(config.x, config.y)
      end
    end
  end
  return self:setPosition(x, y)
end

-- Called after the resolution of the game window changes
function Window:onChangeResolution()
  if self.x_original and self.y_original then
    self:setPosition(self.x_original, self.y_original)
  end
end

-- Called before the window is closed
function Window:close()
  if self.dragging then
    self.dragging = false
    self.ui.drag_mouse_move = nil
  end
  if self.parent then
    self.parent:removeWindow(self)
  end
  for key in pairs(self.key_handlers) do
    self.ui:removeKeyHandler(key, self)
  end
  for _, box in pairs(self.textboxes) do
    self.ui:unregisterTextBox(box)
  end
  self.closed = true
end

function Window:addKeyHandler(key, handler, ...)
  self.ui:addKeyHandler(key, self, handler, ...)
  self.key_handlers[key] = true
end

--! The basic component which makes up most `Window`s.
--! The visual parts of most ingame dialogs are sprites from a sprite sheet.
-- A `Panel` is an instance of a particular sprite, consisting of a sprite
-- index and a position. It is advantageous to construct dialogs out of panels
-- (using `Window:addPanel`) as the common operations on panels (like drawing
-- them and hit-testing against them) are implemented in the `Window` class,
-- thus reducing the amount of work that each individual dialog has to do.
class "Panel"

-- !dummy
function Panel:Panel()
  self.window = nil
  self.x = nil
  self.y = nil
  self.w = nil
  self.h = nil
  self.colour = nil
  self.custom_draw = nil
  self.visible = nil
end

local panel_mt = permanent("Window.<panel_mt>", getmetatable(Panel()))

function Panel:makeButton(...)
  return self.window:makeButtonOnPanel(self, ...)
end

function Panel:makeToggleButton(...)
  return self.window:makeButtonOnPanel(self, ...):makeToggle()
end

function Panel:makeRepeatButton(...)
  return self.window:makeButtonOnPanel(self, ...):makeRepeat()
end

function Panel:makeScrollbar(...)
  return self.window:makeScrollbarOnPanel(self, ...)
end

function Panel:makeTextbox(...)
  return self.window:makeTextboxOnPanel(self, ...)
end

--[[ Set the colour of a panel
! Note: This works only with ColourPanel and BevelPanel, not normal (sprite) panels.
!param col (table) Colour given as a table with three fields red, green and blue, each an integer value in [0, 255].
]]
function Panel:setColour(col)
  if self.colour then
    self.colour = TheApp.video:mapRGB(col.red, col.green, col.blue)
  end
  return self
end

-- Specify a tooltip to be displayed when hovering this panel.
-- x and y are optional position of bottom left of the tooltip.
-- If not specified, will default to mouse position.
function Panel:setTooltip(tooltip, x, y)
  self.tooltip = {
    text = tooltip,
    tooltip_x = x,
    tooltip_y = y,
  }
  return self
end

function Panel:setDynamicTooltip(callback, x, y)
  self.tooltip = {
    callback = callback,
    tooltip_x = x,
    tooltip_y = y,
  }
  return self
end

--! Specify a label to be drawn on top of the panel.
-- Note: This works only with ColourPanel and BevelPanel, not normal (sprite) panels.
--!param label (string) The text to be drawn on top of the label.
--!param font (font) [optional] The font to use. Default is Font01V in QData.
--!param align (string) [optional] Alignment for non-multiline labels (multiline is always left)
--!  can be either of "left", "center"/"centre"/"middle", "right"
function Panel:setLabel(label, font, align)
  self.label = label or ""
  self.label_font = font or self.label_font or TheApp.gfx:loadFont("QData", "Font01V")
  self.align = align or self.align
  return self
end

--! Draw function for the label on a panel
--!param canvas The canvas to draw on (can be nil for test)
--!param x x position to start drawing on
--!param y y position to start drawing on
--!param limit (nil or {int, int}) limit after which line and with character on that line to stop drawing
--!return for single line panels x, for multiline panels x and y end positions after drawing
function Panel:drawLabel(canvas, x, y, limit)
  if type(self.label) == "table" then -- multiline label
    local width
    local next_y = y + self.y + 1
    for i, line in ipairs(self.label) do
      if limit and limit[1] == i then
        line = string.sub(line, 1, limit[2])
      end
      local last_y = next_y
      next_y, width = self.label_font:drawWrapped(canvas, line, x + self.x + 2, next_y, self.w - 4)
      if next_y == last_y then
        -- Special handling for empty lines
        local _, h = self.label_font:sizeOf("A")
        next_y = next_y + h
      end
      if limit and limit[1] == i then
        break
      end
    end
    return x + self.x + 2 + width, next_y
  else
    local line = self.label
    if limit then
      line = string.sub(line, 1, limit[2])
    end
    return self.label_font:draw(canvas, line, x + self.x + 2, y + self.y, self.w - 4, self.h, self.align)
  end
end

--[[ Add a `Panel` to the window.
! Panels form the basic building blocks of most windows. A panel is a small
bitmap coupled with a position, and by combining several panels, a window can
be made. By using panels to construct windows, all of the common tasks like
drawing and hit-testing are provided for you by the base class methods, thus
reducing the amount of code required elsewhere.
!param sprite_index (integer) Index into the window's sprite table of the
bitmap to be displayed.
!param x (integer) The X pixel position to display the bitmap at.
!param y (integer) The Y pixel position to display the bitmap at.
!param w (integer, nil) If the panel is totally opaque, and the width of the
panel (in pixels) is known, it should be specified here to speed up hit-tests.
!param h (integer, nil) If the panel is totally opaque, and the height of the
panel (in pixels) is known, it should be specified here to speed up hit-tests.
]]
function Window:addPanel(sprite_index, x, y, w, h)
  local panel = setmetatable({
    window = self,
    x = x,
    y = y,
    w = w,
    h = h,
    sprite_index = sprite_index,
    visible = true,
  }, panel_mt)
  self.panels[#self.panels + 1] = panel
  return panel
end

function Window:removeAllPanels()
  self.panels = {}
  self.buttons = {} -- Buttons cannot live without a panel
end

local --[[persistable: window_panel_colour_draw]] function panel_colour_draw(panel, canvas, x, y)
  canvas:drawRect(panel.colour, x + panel.x, y + panel.y, panel.w, panel.h)
  if panel.label then
    panel:drawLabel(canvas, x, y)
  end
end

--[[ Add a solid-colour `Panel` to the window.
! A solid-colour panel is like a normal panel, expect it displays a solid
colour rather than a bitmap.
!param x (integer) The X pixel position to start the panel at.
!param y (integer) The Y pixel position to start the panel at.
!param w (integer) The width of the panel, in pixels.
!param h (integer) The height of the panel, in pixels.
!param r (integer) Value in [0, 255] giving the red component of the colour.
!param g (integer) Value in [0, 255] giving the green component of the colour.
!param b (integer) Value in [0, 255] giving the blue component of the colour.
]]
function Window:addColourPanel(x, y, w, h, r, g, b)
  local panel = setmetatable({
    window = self,
    x = x,
    y = y,
    w = w,
    h = h,
    colour = TheApp.video:mapRGB(r, g, b),
    custom_draw = panel_colour_draw,
    visible = true,
  }, panel_mt)
  self.panels[#self.panels + 1] = panel
  return panel
end

local --[[persistable: window_panel_bevel_draw]] function panel_bevel_draw(panel, canvas, x, y)
  if panel.lowered then
    canvas:drawRect(panel.highlight_colour, x + panel.x, y + panel.y, panel.w, panel.h)
    canvas:drawRect(panel.shadow_colour, x + panel.x, y + panel.y, panel.w - 1, panel.h - 1)
    canvas:drawRect(panel.colour, x + panel.x + 1, y + panel.y + 1, panel.w - 2, panel.h - 2)
  else
    canvas:drawRect(panel.shadow_colour, x + panel.x + 1, y + panel.y + 1, panel.w - 1, panel.h - 1)
    canvas:drawRect(panel.highlight_colour, x + panel.x, y + panel.y, panel.w - 1, panel.h - 1)
    canvas:drawRect(panel.colour, x + panel.x + 1, y + panel.y + 1, panel.w - 2, panel.h - 2)
  end
  if panel.label then
    panel:drawLabel(canvas, x, y)
  end
end

local function sanitize(colour)
  if colour > 255 then
    colour = 255
  elseif colour < 0 then
    colour = 0
  end
  return colour
end

--[[ Add a beveled `Panel` to the window.
! A bevel panel is similar to a solid colour panel, except that it
features a highlight and a shadow that makes it appear either lowered or raised.
!param x (integer) The X pixel position to start the panel at.
!param y (integer) The Y pixel position to start the panel at.
!param w (integer) The width of the panel, in pixels.
!param h (integer) The height of the panel, in pixels.
!param colour (colour in form .red, .green and .blue) The colour for the panel.
!param highlight_colour (colour in form .red, .green and .blue or nil) [optional] The colour for the highlight.
!param shadow_colour (colour in form .red, .green and .blue or nil) [optional] The colour for the shadow.
!param disabled_colour (colour in form .red, .green and .blue or nil) [optional] The colour for the disabled panel.
]]
function Window:addBevelPanel(x, y, w, h, colour, highlight_colour, shadow_colour, disabled_colour)
  highlight_colour = highlight_colour or {
    red = sanitize(colour.red + 40),
    green = sanitize(colour.green + 40),
    blue = sanitize(colour.blue + 40),
  }
  shadow_colour = shadow_colour or {
    red = sanitize(colour.red - 40),
    green = sanitize(colour.green - 40),
    blue = sanitize(colour.blue - 40),
  }
  disabled_colour = disabled_colour or {
    red = sanitize(math.floor((colour.red + 100) / 2)),
    green = sanitize(math.floor((colour.green + 100) / 2)),
    blue = sanitize(math.floor((colour.blue + 100) / 2)),
  }
  
  local panel = setmetatable({
    window = self,
    x = x,
    y = y,
    w = w,
    h = h,
    colour = TheApp.video:mapRGB(colour.red, colour.green, colour.blue),
    highlight_colour = TheApp.video:mapRGB(highlight_colour.red, highlight_colour.green, highlight_colour.blue),
    shadow_colour = TheApp.video:mapRGB(shadow_colour.red, shadow_colour.green, shadow_colour.blue),
    disabled_colour = TheApp.video:mapRGB(disabled_colour.red, disabled_colour.green, disabled_colour.blue),
    custom_draw = panel_bevel_draw,
    visible = true,
    lowered = false,
  }, panel_mt)
  self.panels[#self.panels + 1] = panel
  return panel
end

function Window:addWindow(window)
  if window.closed then
    return
  end
  if not self.windows then
    self.windows = {}
  end
  window.parent = self
  if window.on_top then
    -- As self.windows array is ordered from top to bottom and drawn by the end, a "On Top" window has be added at start
    table.insert(self.windows, 1, window)
  else
    -- Normal windows, are added in the first position after on_top windows
    local pos = false
    for i = 1, #self.windows do
      if not self.windows[i].on_top then
        pos = i
        break
      end
    end
    pos = pos or #self.windows + 1
    table.insert(self.windows, pos, window)
  end
end

function Window:removeWindow(window)
  if self.windows then
    for n = 1, #self.windows do
      if self.windows[n] == window then
        if #self.windows == 1 then
          self.windows = false
        else
          table.remove(self.windows, n)
        end
        return true
      end
    end
  end
  return false
end

-- Searches (direct) child windows for window of the given class, and returns
-- one (or nil if there weren't any at all).
-- !param window_class (class) The class of window to search for.
function Window:getWindow(window_class)
  if self.windows then
    for _, window in ipairs(self.windows) do
      if class.is(window, window_class) then
        return window
      end
    end
  end
end

-- Searches (direct) child windows for window of the given class, and returns
-- a (potentially empty) list of matching windows.
-- !param window_class (class) The class of window to search for.
function Window:getWindows(window_class)
  local matching_windows = {}
  if self.windows then
    for _, window in ipairs(self.windows) do
      if class.is(window, window_class) then
        matching_windows[#matching_windows+1] = window
      end
    end
  end
  return matching_windows
end

--! A region of a `Panel` which causes some action when clicked.
class "Button"

--!dummy
function Button:Button()
  self.ui = nil
  self.is_toggle = nil
  self.is_repeat = nil
  self.x = nil
  self.y = nil
  self.r = nil
  self.b = nil
  self.panel_for_sprite = nil
  self.sprite_index_normal = nil
  self.sprite_index_disabled = nil
  self.sprite_index_active = nil
  self.panel_lowered_normal = nil
  self.panel_lowered_active = nil
  self.on_click = nil
  self.on_click_self = nil
  self.on_rightclick = nil
  self.enabled = nil
end

local button_mt = permanent("Window.<button_mt>", getmetatable(Button()))

function Button:setDisabledSprite(index)
  self.sprite_index_disabled = index
  return self
end

function Button:enable(enable)
  if enable then
    self.enabled = true
    self.panel_for_sprite.sprite_index = self.sprite_index_normal
    if self.panel_for_sprite.colour_backup then
      self.panel_for_sprite.colour = self.panel_for_sprite.colour_backup
    end
  else
    self.enabled = false
    self.panel_for_sprite.sprite_index = self.sprite_index_disabled
    if self.panel_for_sprite.disabled_colour then
      self.panel_for_sprite.colour_backup = self.panel_for_sprite.colour
      self.panel_for_sprite.colour = self.panel_for_sprite.disabled_colour
    end
  end
  return self
end

function Button:makeToggle()
  self.is_toggle = true
  self.is_repeat = false
  self.toggled = false
  return self
end

function Button:makeRepeat()
  self.is_repeat = true
  self.is_toggle = false
  self.toggled = false
  return self
end

function Button:toggle()
  self.sprite_index_normal, self.sprite_index_active =
    self.sprite_index_active, self.sprite_index_normal
  self.panel_lowered_active, self.panel_lowered_normal =
    self.panel_lowered_normal, self.panel_lowered_active
  self.panel_for_sprite.sprite_index = self.sprite_index_normal
  self.panel_for_sprite.lowered = self.panel_lowered_normal
  self.toggled = not self.toggled
  return self.toggled
end

function Button:setToggleState(state)
  if self.toggled ~= state then
    self:toggle()
  end
  return self
end

function Button:preservePanel()
  local window = self.panel_for_sprite.window
  self.panel_for_sprite = window:addPanel(0, self.x, self.y)
  self.sprite_index_normal = 0
  return self
end

function Button:setSound(name)
  self.sound = name
  return self
end

local --[[persistable:window_drag_round]] function round(value, amount)
  return amount * math.floor(value / amount + 0.5)
end

-- Specify a tooltip to be displayed when hovering this button.
-- x and y are optional position of bottom left of the tooltip.
-- If not specified, will default to top center of button.
function Button:setTooltip(tooltip, x, y)
  self.tooltip = {
    text = tooltip,
    tooltip_x = x or round((self.x + self.r) / 2, 1),
    tooltip_y = y or self.y,
  }
  return self
end

function Button:setDynamicTooltip(callback, x, y)
  self.tooltip =  {
    callback = callback,
    tooltip_x = x or round((self.x + self.r) / 2, 1),
    tooltip_y = y or self.y,
  }
  return self
end

--! Called whenever a click on the button should be handled. This depends on the type of button.
--! Normally this is called when a MouseUp occurs over the button (if the MouseDown occurred over
--! this or another button). However for repeat buttons, it is called once on MouseDown and, after
--! a short delay, repeatedly.
--!param mouse_button (string) either "left" or "right"
function Button:handleClick(mouse_button)
  local arg = nil
  if self.is_toggle then
    arg = self:toggle()
  end
  if self.sound then
    self.ui:playSound(self.sound)
  end
  local callback = mouse_button == "left" and self.on_click or self.on_rightclick
  if callback then
    callback(self.on_click_self, arg, self)
  else
    if mouse_button == "left" then
      print("Warning: No handler for button click")
      self.on_click = --[[persistable:button_on_click_handler_stub]] function() end
    end
  end
end

--[[ Convert a static panel into a clickable button.
!param panel (Panel) The panel to convert into a button.
!param x (integer) The X co-ordinate of the clickable rectangle on the panel.
!param y (integer) The Y co-ordinate of the clickable rectangle on the panel.
!param w (integer) The width of the clickable rectangle on the panel.
!param h (integer) The height of the clickable rectangle on the panel.
!param sprite (integer) An index into the window's sprite sheet. The panel will
display this sprite when the button is being pressed.
!param on_click (function) The function to be run when the user left-clicks the
button. Takes three arguments: `on_click_self`, the toggle state (nil for
normal buttons, true/false for toggle buttons), the button itself.
!param on_click_self (function, nil) The first value to pass to `on_click`. If
nil or not given, then the window is passed as the first argument.
!param on_rightclick (function, nil) The function to be called when the user
right-clicks the button.
]]
function Window:makeButtonOnPanel(panel, x, y, w, h, sprite, on_click, on_click_self, on_rightclick)
  x = x + panel.x
  y = y + panel.y
  local button = setmetatable({
    ui = self.ui,
    is_toggle = false,
    is_repeat = false,
    x = x,
    y = y,
    r = x + w,
    b = y + h,
    panel_for_sprite = panel,
    sprite_index_normal = panel.sprite_index,
    sprite_index_disabled = panel.sprite_index,
    sprite_index_active = sprite,
    on_click = on_click,
    on_click_self = on_click_self or self,
    on_rightclick = on_rightclick,
    enabled = true,
    panel_lowered_normal = false,
    panel_lowered_active = true,
  }, button_mt)
  if self.ui and on_click == self.close then
    button.sound = "no4.wav"
  elseif self.default_button_sound then
    button.sound = self.default_button_sound
  end
  self.buttons[#self.buttons + 1] = button
  return button
end

--! A window element used to scroll in lists
class "Scrollbar"

--!dummy
function Scrollbar:Scrollbar()
  self.base = nil
  self.slider = nil
  self.min_value = nil
  self.max_value = nil
  self.value = nil
  self.page_size = nil
  self.direction = nil
  self.visible = nil
end

function Scrollbar:setRange(min_value, max_value, page_size, value)
  page_size = math.min(page_size, max_value - min_value + 1) -- page size must be number of elements at most
  value = math.min(value or min_value, math.max(min_value, max_value - page_size + 1))
  
  self.min_value = min_value
  self.max_value = max_value
  self.page_size = page_size
  self.value = value
  
  local slider = self.slider
  slider.w = slider.max_w
  slider.h = slider.max_h
  slider.max_x = slider.min_x + slider.max_w - slider.w
  slider.max_y = slider.min_y + slider.max_h - slider.h
  
  if self.direction == "y" then
    slider.h = math.ceil((page_size / (max_value - min_value + 1)) * slider.max_h)
    slider.max_y = slider.min_y + slider.max_h - slider.h
    slider.y = (value - min_value) / (max_value - min_value - page_size + 2) * (slider.max_y - slider.min_y) + slider.min_y
  else
    slider.w = math.ceil((page_size / (max_value - min_value + 1)) * slider.max_w)
    slider.max_x = slider.min_x + slider.max_w - slider.w
    slider.x = (value - min_value) / (max_value - min_value - page_size + 2) * (slider.max_x - slider.min_x) + slider.min_x
  end
  
  return self
end

--! Get the pixel position of the slider in the axis which the slider can move
function Scrollbar:getXorY()
  return self.slider[self.direction]
end

--! Set the pixel position of the slider in the axis which the slider can move
function Scrollbar:setXorY(xy)
  local dir = self.direction
  local min, max
  if dir == "x" then
    min = self.slider.min_x
    max = self.slider.max_x
  else
    min = self.slider.min_y
    max = self.slider.max_y
  end
  if xy < min then
    xy = min
  end
  if xy > max then
    xy = max
  end
  self.slider[dir] = xy
  local old_value = self.value
  self.value = math.floor(((xy - min) / (max - min + 1)) * (self.max_value - self.min_value - self.page_size + 2)) + 1
  if old_value ~= self.value then
    self.callback()
  end
end

local scrollbar_mt = permanent("Window.<scrollbar_mt>", getmetatable(Scrollbar()))

--[[ Convert a static panel into a scrollbar.
! Scrollbars consist of a base panel (the panel given as a parameter)
and an additional slider panel (automatically created BevelPanel).
!param panel (panel) The panel that will serve as the scrollbar base.
!param slider_colour (colour in form .red, .green and .blue) The colour for the slider.
!param callback (function) Function that is called whenever the slider position changes.
!param min_value (integer) The minimum value the scrollbar can represent.
!param max_value (integer) The maximum value the scrollbar can represent.
!param page_size (integer) The amount of objects represented on one page.
!param value (integer, nil) The current value, or min_value if not specified.
]]
function Window:makeScrollbarOnPanel(panel, slider_colour, callback, min_value, max_value, page_size, value)
  local slider = self:addBevelPanel(panel.x + 1, panel.y + 1, panel.w - 2, panel.h - 2, slider_colour)
  local scrollbar = setmetatable({
    base = panel,
    slider = slider,
    direction = "y",
    callback = callback,
    visible = true,
    enabled = true,
  }, scrollbar_mt)
  slider.min_x = slider.x
  slider.min_y = slider.y
  slider.max_w = slider.w
  slider.max_h = slider.h
  scrollbar:setRange(min_value, max_value, page_size, value)
  self.scrollbars[#self.scrollbars + 1] = scrollbar
  
  return scrollbar
end

--! A window element used to enter text
class "Textbox"

--!dummy
function Textbox:Textbox()
  self.panel = nil
  self.confirm_callback = nil
  self.abort_callback = nil
  self.button = nil
  self.text = nil
  self.allowed_input = nil
  self.char_limit = nil
  self.visible = nil
  self.enabled = nil
  self.active = nil
  self.cursor_counter = nil
  self.cursor_state = nil
  self.cursor_pos = nil
end

local textbox_mt = permanent("Window.<textbox_mt>", getmetatable(Textbox()))

function Textbox:onTick()
  if self.active then
    self.cursor_counter = self.cursor_counter + 1
    if self.cursor_counter >= 40 then
      self.cursor_state = true
      self.cursor_counter = self.cursor_counter - 40
    elseif self.cursor_counter >= 20 then
      self.cursor_state = false
    end
  end
end

function Textbox:drawCursor(canvas, x, y)
  if self.cursor_state then
    local col = TheApp.video:mapRGB(255, 255, 255)
    local cursor_x, cursor_y = self.panel:drawLabel(nil, x, y, self.cursor_pos)
    local w, h = self.panel.label_font:sizeOf("A")
    cursor_y = cursor_y and cursor_y - 3 or self.panel.y + y + h -- cursor_y not returned for single line labels
    -- Add x separation, but only if there was actually some text in this line.
    if self.text[self.cursor_pos[1]] ~= "" then
      cursor_x = cursor_x + 1 -- TODO font:getSeparation?
    end
    canvas:drawRect(col, cursor_x, cursor_y, w, 2)
  end
end

--! Set the box to not active and run confirm callback, if any
function Textbox:confirm()
  self:setActive(false)
  if self.confirm_callback then
    self.confirm_callback()
  end
end

--! Set the box to not active and run abort callback, if any
function Textbox:abort()
  self:setActive(false)
  if self.abort_callback then
    self.abort_callback()
  end
end

--! Set the textbox active status to true or false, taking care of any
-- additional things that need to be done: deactivate any other textboxes,
-- handle blinking cursor, keyboard repeat on/off, set button state accordingly
--!param active (boolean) whether to activate (true) or deactivate (false) the box
function Textbox:setActive(active)
  local ui = self.panel.window.ui
  if active then
    -- Unselect any other textbox
    for _, textbox in ipairs(ui.textboxes) do
      if textbox ~= self and textbox.active then
        textbox:abort()
      end
    end
    self.cursor_counter = 0
    self.cursor_state = true
    self.cursor_pos[1] = type(self.text) == "table" and #self.text or 1
    self.cursor_pos[2] = type(self.text) == "table" and string.len(self.text[#self.text]) or string.len(self.text)
    -- Update text
    self.panel:setLabel(self.text)
    -- Enable Keyboard repeat
    ui:enableKeyboardRepeat()
  else
    self.cursor_state = false
    -- Disable Keyboard repeat
    ui:disableKeyboardRepeat()
  end
  
  self.active = active
  -- Update button if necessary
  if self.button.toggled ~= active then
    self.button:toggle()
  end
end

function Textbox:clicked()
  local active = self.button.toggled
  if active then
    self:setActive(true)
  else
    if self.text == "" then
      self:abort()
    else
      self:confirm()
    end
  end
end

function Textbox:input(char, rawchar, code)
  if not self.active then
    return false
  end
  local ui = self.panel.window.ui
  local line = type(self.text) == "table" and self.text[self.cursor_pos[1]] or self.text
  local new_line
  local handled = false
  if not self.char_limit or string.len(line) < self.char_limit then
    -- Upper- and lowercase letters
    if self.allowed_input.alpha then
      if #rawchar == 1 and (("a" <= rawchar and rawchar <= "z")
      or ("A" <= rawchar and rawchar <= "Z")) then
        handled = true
      end
    end
    -- Numbers
    if not handled and self.allowed_input.numbers then
      if 256 <= code and code <= 265 then
        -- Numeric keypad
        rawchar = string.char(string.byte"0" + code - 256)
      end
      if #rawchar == 1 and "0" <= rawchar and rawchar <= "9" then
        handled = true
      end
    end
    -- Space and hyphen
    if not handled and self.allowed_input.misc then
      if rawchar == " " or rawchar == "-" then
        handled = true
      end
    end
    if handled then
      new_line = line:sub(1, self.cursor_pos[2]) .. rawchar .. line:sub(self.cursor_pos[2] + 1, -1)
      self.cursor_pos[2] = self.cursor_pos[2] + 1
    end
  end
  -- Backspace (delete last char)
  if not handled and char == "backspace" then
    if self.cursor_pos[2] == 0 then
      if type(self.text) == "table" and #self.text > 1 then
        table.remove(self.text, self.cursor_pos[1])
        self.cursor_pos[1] = self.cursor_pos[1] - 1
        self.cursor_pos[2] = string.len(self.text[self.cursor_pos[1]])
        new_line = self.text[self.cursor_pos[1]] .. line
      end
    else
      new_line = line:sub(1, self.cursor_pos[2] - 1) .. line:sub(self.cursor_pos[2] + 1, -1)
      self.cursor_pos[2] = self.cursor_pos[2] - 1
    end
    handled = true
  end
  -- Delete (delete next char)
  if not handled and char == "delete" then
    if self.cursor_pos[2] == string.len(line) then
      if type(self.text) == "table" and self.cursor_pos[1] < #self.text then
        new_line = line .. self.text[self.cursor_pos[1] + 1]
        table.remove(self.text, self.cursor_pos[1] + 1)
      end
    else
      new_line = line:sub(1, self.cursor_pos[2]) .. line:sub(self.cursor_pos[2] + 2, -1)
    end
    handled = true
  end
  -- Enter (newline or confirm)
  if not handled and char == "enter" then
    if type(self.text) == "table" then
      local remainder = line:sub(self.cursor_pos[2] + 1, -1)
      self.text[self.cursor_pos[1]] = line:sub(1, self.cursor_pos[2])
      table.insert(self.text, self.cursor_pos[1] + 1, remainder)
      self.cursor_pos[1] = self.cursor_pos[1] + 1
      self.cursor_pos[2] = 0
      handled = true
    else
      self:confirm()
      return true
    end
  end
  -- Escape (abort)
  if not handled and char == "esc" then
    self:abort()
    return true
  end
  -- Arrow keys (code >= 273 and code <= 276)
  if not handled and code >= 273 and code <= 276 then
    if code == 273 then -- up
      if type(self.text) ~= "table" or self.cursor_pos[1] == 1 then
        -- to beginning of line
        self.cursor_pos[2] = 0
      else
        -- one line up
        self.cursor_pos[1] = self.cursor_pos[1] - 1
        self.cursor_pos[2] = math.min(self.cursor_pos[2], string.len(self.text[self.cursor_pos[1]]))
      end
    elseif code == 274 then -- down
      if type(self.text) ~= "table" or self.cursor_pos[1] == #self.text then
        -- to end of line
        self.cursor_pos[2] = string.len(line)
      else
        -- one line down
        self.cursor_pos[1] = self.cursor_pos[1] + 1
        self.cursor_pos[2] = math.min(self.cursor_pos[2], string.len(self.text[self.cursor_pos[1]]))
      end
    elseif code == 275 then -- right
      if self.cursor_pos[2] == string.len(line) then
        -- next line
        if type(self.text) == "table" and self.cursor_pos[1] < #self.text then
          self.cursor_pos[1] = self.cursor_pos[1] + 1
          self.cursor_pos[2] = 0
        end
      else
        -- one to the right
        self.cursor_pos[2] = self.cursor_pos[2] + 1
      end
    elseif code == 276 then -- left
      if self.cursor_pos[2] == 0 then
        -- previous line
        if type(self.text) == "table" and self.cursor_pos[1] > 1 then
          self.cursor_pos[1] = self.cursor_pos[1] - 1
          self.cursor_pos[2] = string.len(self.text[self.cursor_pos[1]])
        end
      else
        -- one to the left
        self.cursor_pos[2] = self.cursor_pos[2] - 1
      end
    end
    -- make cursor visible
    self.cursor_counter = 0
    self.cursor_state = true
    return true
  end
  -- Tab (reserved)
  if not handled and code == 9 then
    return true
  end
  if not self.char_limit or string.len(self.text) < self.char_limit then
    -- Experimental "all" category
    if not handled and self.allowed_input.all
       and not (char == "shift" or char == "ctrl" or char == "alt")
       and not (282 <= code and code <= 293) then -- F-Keys
      new_line = line:sub(1, self.cursor_pos[2]) .. rawchar .. line:sub(self.cursor_pos[2] + 1, -1)
      self.cursor_pos[2] = self.cursor_pos[2] + 1
      handled = true
    end
  end
  if new_line then
    if type(self.text) == "table" then
      self.text[self.cursor_pos[1]] = new_line
    else
      self.text = new_line
    end
  end
  -- make cursor visible
  self.cursor_counter = 0
  self.cursor_state = true
  -- update label
  self.panel:setLabel(self.text)
  return handled
end

--[[ Limit input handled by textbox to specific classes of characters
!param types (string or table) One of, or an table of any number of input types
! valid input types are:
!  "alpha": Letters (lower and uppercase)
!  "numbers": 0-9
!  "misc": other characters, currently space and hyphen
!  "all": experimental category that allows, theoretically, all input
]]
function Textbox:allowedInput(types)
  if type(types) ~= "table" then types = {types} end
  self.allowed_input = {}
  for _, t in ipairs(types) do
    self.allowed_input[t] = true
  end
  return self
end

--[[ Limit input to a maximum of [limit] characters.
!param limit (integer or nil) Number of characters until the textbox will stop accepting input, or nil to deactivate limit.
]]
function Textbox:characterLimit(limit)
  self.char_limit = limit
  return self
end

--[[ Set the text of the textbox to a given string or list of strings.
! Use empty string to make textbox a single line textbox (default).
! Use table with empty string {""} to make it a multiline textbox.
!param text (string or table) The string or list of strings the textbox should contain.
]]
function Textbox:setText(text)
  self.text = text
  return self
end

--[[ Convert a static panel into a textbox.
! Textboxes consist of the panel given as a parameter, which is made into a
ToggleButton automatically, and handle keyboard input while active.
!param panel (panel) The panel that will serve as the textbox base.
!param confirm_callback (function) The function to call when text is confirmed.
!param abort_callback (function) The function to call when entering is aborted.
]]
function Window:makeTextboxOnPanel(panel, confirm_callback, abort_callback)
  local textbox = setmetatable({
    panel = panel,
    confirm_callback = confirm_callback,
    abort_callback = abort_callback,
    button = nil, -- placeholder
    text = "",
    allowed_input = {
      alpha = true,
      numbers = true,
      misc = true,
    },
    char_limit = nil,
    visible = true,
    enabled = true,
    active = false,
    cursor_counter = 0,
    cursor_state = false,
    cursor_pos = {1, 1},
  }, textbox_mt)
  
  local button = panel:makeToggleButton(0, 0, panel.w, panel.h, nil, textbox.clicked, textbox)
  textbox.button = button
  
  self.textboxes[#self.textboxes + 1] = textbox
  self.ui:registerTextBox(textbox)
  return textbox
end


function Window:draw(canvas, x, y)
  x, y = x + self.x, y + self.y
  if self.panels[1] then
    local panel_sprites = self.panel_sprites
    local panel_sprites_draw = panel_sprites and panel_sprites.draw
    for _, panel in ipairs(self.panels) do
      if panel.visible then
        if panel.custom_draw then
          panel:custom_draw(canvas, x, y)
        else
          panel_sprites_draw(panel_sprites, canvas, panel.sprite_index, x + panel.x, y + panel.y)
        end
      end
    end
  end
  if not class.is(self, UI) then -- prevent UI (sub)class from handling the textboxes too
    for _, box in ipairs(self.textboxes) do
      box:drawCursor(canvas, x, y)
    end
  end
  if self.windows then
    local windows = self.windows
    for i = #windows, 1, -1 do
      if windows[i].visible then
        windows[i]:draw(canvas, x, y)
      end
    end
  end
end

function Window:onChangeLanguage()
  if self.windows then
    for _, window in ipairs(self.windows) do
      window:onChangeLanguage()
    end
  end
end

function Window:onCursorWorldPositionChange(x, y)
  local repaint = false
  if self.windows then
    for _, window in ipairs(self.windows) do
      if window:onCursorWorldPositionChange(x - window.x, y - window.y) then
        repaint = true
      end
    end
  end
  return repaint
end

function Window:hitTestPanel(x, y, panel)
  local x, y = x - panel.x, y - panel.y
  if panel.visible and x >= 0 and y >= 0 then
    if panel.w and panel.h then
      if x <= panel.w and y <= panel.h then
        return true
      end
    else
      if self.panel_sprites:hitTest(panel.sprite_index, x, y) then
        return true
      end
    end
  end
  return false
end

--[[ Used to test if the window has a (non-transparent) pixel at the given position.
!param x (integer) The X co-ordinate of the pixel to test, relative to the
top-left corner of the window.
!param y (integer) The Y co-ordinate of the pixel to test, relative to the
top-left corner of the window.
]]
function Window:hitTest(x, y)
  if x < 0 or y < 0 or (self.width and x >= self.width) or (self.height and y >= self.height) then
    return false
  end
  if self.panels[1] then
    for _, panel in ipairs(self.panels) do
      if self:hitTestPanel(x, y, panel) then
        return true
      end
    end
  end
  if self.windows then
    for _, child in ipairs(self.windows) do
      if child:hitTest(x - child.x, y - child.y) then
        return true
      end
    end
  end
  return false
end

function Window:onMouseDown(button, x, y)
  local repaint = false
  if self.windows then
    for _, window in ipairs(self.windows) do
      if window:onMouseDown(button, x - window.x, y - window.y) then
        repaint = true
        break
      end
    end
  end
  if not repaint and (button == "left" or button == "right") then
    for _, btn in ipairs(self.buttons) do
      if btn.enabled and btn.x <= x and x < btn.r and btn.y <= y and y < btn.b and (button == "left" or btn.on_rightclick ~= nil) then
        btn.panel_for_sprite.sprite_index = btn.sprite_index_active
        self.active_button = btn
        btn.active = true
        btn.panel_for_sprite.lowered = btn.panel_lowered_active
        if btn.is_repeat then
          -- execute callback once, then wait some ticks before repeatedly executing
          btn:handleClick(button)
        end
        self.btn_repeat_delay = 10
        repaint = true
        break
      end
    end
    for _, bar in ipairs(self.scrollbars) do
      if bar.enabled and self:hitTestPanel(x, y, bar.slider) then
        self.active_scrollbar = bar
        bar.active = true
        bar.down_x = x - bar.slider.x
        bar.down_y = y - bar.slider.y
        repaint = true
        break
      end
    end
  end
  if self:hitTest(x, y) then
    if button == "left" and not repaint then
      self:beginDrag(x, y)
    end
    repaint = true
  end
  
  if repaint then
    self:bringToTop()
  end
  return repaint
end

--[[ Get the name of the saved window position group.
! When the user drags a window, the new position of the window is saved, and
then when any windows in the same group are opened in the future, the position
of the new window is set to the saved position. By default, each window class
is its own group, but by overriding this method, that can be changed.
]]
function Window:getSavedWindowPositionName()
  return class.type(self)
end

function Window:onMouseUp(button, x, y)
  local repaint = false
  
  if self.dragging then
    self.ui.drag_mouse_move = nil
    self.dragging = false
    local config = self.ui.app.runtime_config
    if not config.window_position then
      config.window_position = {}
    end
    config = config.window_position
    local name = self:getSavedWindowPositionName()
    if not config[name] then
      config[name] = {}
    end
    config = config[name]
    config.x = self.x_original
    config.y = self.y_original
    return false
  end

  if self.windows then
    for _, window in ipairs(self.windows) do
      if window:onMouseUp(button, x - window.x, y - window.y) then
        repaint = true
        break -- Click has been handled. No need to look any further.
      end
    end
  end
  
  if button == "left" or button == "right" then
    local btn = self.active_button
    if btn then
      btn.panel_for_sprite.sprite_index = btn.sprite_index_normal
      btn.active = false
      btn.panel_for_sprite.lowered = btn.panel_lowered_normal
      self.active_button = false
      self.btn_repeat_delay = nil
      if btn.enabled and not btn.is_repeat and btn.x <= x and x < btn.r and btn.y <= y and y < btn.b then
        btn:handleClick(button)
      end
      repaint = true
    end
    local bar = self.active_scrollbar
    if bar then
      self.active_scrollbar = nil
      bar.active = false
      bar.down_x = nil
      bar.down_y = nil
    end
  end
  
  return repaint
end

local --[[persistable:window_drag_position_representation]] function getNicestPositionRepresentation(pos, size, dim_size)
  if size == dim_size then
    return 0.5
  end
  
  local left_rel = pos
  local right_rel = pos + size - dim_size
  local rel = pos / (dim_size - size)
  if 0.15 < rel and rel < 0.85 then
    return rel
  end
  if left_rel <= 0 then
    return 0
  end
  if right_rel >= 0 then
    return -0.1
  end
  if left_rel <= -right_rel then
    return left_rel
  else
    return right_rel
  end
end

--[[ Initiate dragging of the window.
!param x The X position of the cursor in window co-ordinatees.
!param y The Y position of the cursor in window co-ordinatees.
]]
function Window:beginDrag(x, y)
  if not self.width or not self.height or not self.ui
  or self.ui.app.runtime_config.lock_windows or not self.draggable then
    -- Need width, height and UI to do a drag
    return false
  end
  
  self.dragging = true
  self.ui.drag_mouse_move = --[[persistable:window_drag_mouse_move]] function (sx, sy)
    -- sx and sy are cursor screen co-ords. Convert to window's new abs co-ords
    sx = sx - x
    sy = sy - y
    -- Calculate best positioning
    local w, h = TheApp.config.width, TheApp.config.height
    if self.buttons_down.ctrl then
      local px = round(sx / (w - self.width), 0.1)
      local py = round(sy / (h - self.height), 0.1)
      if px >= 1 then
        px = -0.1
      elseif px < 0 then
        px = 0
      end
      if py >= 1 then
        py = -0.1
      elseif py < 0 then
        py = 0
      end
      self:setPosition(px, py)
    else
      local px = getNicestPositionRepresentation(sx, self.width , w)
      local py = getNicestPositionRepresentation(sy, self.height, h)
      self:setPosition(px, py)
    end
  end
  return true
end

--[[ Called when the user moves the mouse.
!param x (integer) The new X co-ordinate of the cursor, relative to the top-left
corner of the window.
!param y (integer) The new Y co-ordinate of the cursor, relative to the top-left
corner of the window.
!param dx (integer) The number of pixels which the cursor moved horizontally.
!param dy (integer) The number of pixels which the cursor moved vertically.
]]
function Window:onMouseMove(x, y, dx, dy)
  local repaint = false
  if self.windows then
    for _, window in ipairs(self.windows) do
      if window:onMouseMove(x - window.x, y - window.y, dx, dy) then
        repaint = true
      end
    end
  end
  
  if self.active_button then
    local btn = self.active_button
    local index = btn.sprite_index_blink or btn.sprite_index_normal
    if btn.x <= x and x < btn.r and btn.y <= y and y < btn.b then
      index = btn.sprite_index_active
      self.active_button.active = true
      btn.panel_for_sprite.lowered = btn.panel_lowered_active
    else
      self.active_button.active = false
      btn.panel_for_sprite.lowered = btn.panel_lowered_normal
      for _, btn in ipairs(self.buttons) do
        if btn.enabled and btn.x <= x and x < btn.r and btn.y <= y and y < btn.b then
          btn.panel_for_sprite.sprite_index = btn.sprite_index_active
          btn.active = true
          btn.panel_for_sprite.lowered = btn.panel_lowered_active
          self.active_button = btn
          repaint = true
          break
        end
      end
    end
    if btn.panel_for_sprite.sprite_index ~= index then
      btn.panel_for_sprite.sprite_index = index
      repaint = true
    end
  end
  
  if self.active_scrollbar then
    local bar = self.active_scrollbar
    if bar.direction == "x" then
      bar:setXorY(x - bar.down_x)
    elseif bar.direction == "y" then
      bar:setXorY(y - bar.down_y)
    end
  end
  
  return repaint
end

-- Called regularly at a rate independent of the game speed.
function Window:onTick()
  if self.active_button then
    local btn = self.active_button
    local mouse_btn = self.buttons_down.mouse_left and "left" or self.buttons_down.mouse_right and "right" or nil
    if mouse_btn then
      if self.btn_repeat_delay > 0 then
        self.btn_repeat_delay = self.btn_repeat_delay - 1
      else
        if btn.active and btn.is_repeat then
          self.btn_repeat_delay = 2
          btn:handleClick(mouse_btn)
        end
      end
    end
  end
  if self.blinking_button then
    self.blink_counter = self.blink_counter + 1
    if self.blink_counter == 20 then
      self.blink_counter = 0
      local btn = self.buttons[self.blinking_button]
      btn.sprite_index_blink = btn.sprite_index_blink == btn.sprite_index_active and btn.sprite_index_normal or btn.sprite_index_active
      if btn.enabled and not btn.active then
        btn.panel_for_sprite.sprite_index = btn.sprite_index_blink
      end
    end
  end
  if not class.is(self, UI) then -- prevent UI (sub)class from handling the textboxes too
    for _, box in ipairs(self.textboxes) do
      box:onTick()
    end
  end
  if self.windows then
    for _, window in ipairs(self.windows) do
      window:onTick()
    end
  end
end

-- Called regularly at the same rate that entities are ticked.
function Window:onWorldTick()
  if self.windows then
    for _, window in ipairs(self.windows) do
      window:onWorldTick()
    end
  end
end

-- Bring the window to the top of its parent
function Window:bringToTop()
  if self.parent then
    self.parent:sendToTop(self)
  end
end

-- Tell the window to bring the specified sub-window to its top
function Window:sendToTop(window)
  local window_index
  if self.windows then
    for i = 1, #self.windows do -- Search specified window in windows list
      if self.windows[i] == window then
        window_index = i -- Keep window index
      end
    end
  end

  if window_index ~= nil then
    local insert_pos
    if window.on_top then
      insert_pos = 1
    else
      -- First position after any on_top windows
      for i = 1, #self.windows do
        if not self.windows[i].on_top then
          insert_pos = i
          break
        end
      end
      insert_pos = insert_pos or #self.windows + 1
    end
    table.remove(self.windows, window_index)       -- Remove the window from the list
    table.insert(self.windows, insert_pos, window) -- And reinsert it at the before computed position
  end
end

function Window:startButtonBlinking(button_index)
  
  self.blinking_button = button_index
  self.blink_counter = 0
  local btn = self.buttons[button_index]
  btn.sprite_index_blink = btn.sprite_index_normal
end

function Window:stopButtonBlinking()
  local btn = self.buttons[self.blinking_button]
  btn.panel_for_sprite.sprite_index = btn.sprite_index_normal
  btn.sprite_index_blink = nil
  self.blinking_button = false
  self.blink_counter = 0
end

--! Create a static (non-changeable) tooltip to be displayed in a certain region.
--! tooltip_x and tooltip_y are optional; if not specified, it will default to top center of region.
--!param text (string) The string to display.
--!param x (integer) The X co-ordinate relative to the top-left corner.
--!param y (integer) The Y co-ordinate relative to the top-left corner.
--!param r (integer) The right (X + width) co-ordinate relative to the top-left corner.
--!param b (integer) The bottom (Y + height) co-ordinate relative to the top-left corner.
--!param tooltip_x (integer) [optional] The X co-ordinate to display the tooltip at.
--!param tooltip_y (integer) [optional] The Y co-ordinate to display the tooltip at.
function Window:makeTooltip(text, x, y, r, b, tooltip_x, tooltip_y)
  local region = {
    text = text, x = x, y = y, r = r, b = b,
    tooltip_x = tooltip_x or round((x + r) / 2, 1), -- optional
    tooltip_y = tooltip_y or y,                     -- optional
  }
  self.tooltip_regions[#self.tooltip_regions + 1] = region
  return region
end

--! Create a dynamic tooltip to be displayed in a certain region.
--! tooltip_x and tooltip_y are optional; if not specified, it will default to top center of region.
--!param callback (function) A function that returns the string to display or nil for no tooltip.
--!param x (integer) The X co-ordinate relative to the top-left corner.
--!param y (integer) The Y co-ordinate relative to the top-left corner.
--!param r (integer) The right (X + width) co-ordinate relative to the top-left corner.
--!param b (integer) The bottom (Y + height) co-ordinate relative to the top-left corner.
--!param tooltip_x (integer) [optional] The X co-ordinate to display the tooltip at.
--!param tooltip_y (integer) [optional] The Y co-ordinate to display the tooltip at.
function Window:makeDynamicTooltip(callback, x, y, r, b, tooltip_x, tooltip_y)
  local region = {
    callback = callback, x = x, y = y, r = r, b = b,
    tooltip_x = tooltip_x or round((x + r) / 2, 1), -- optional
    tooltip_y = tooltip_y or y,                     -- optional
  }
  self.tooltip_regions[#self.tooltip_regions + 1] = region
  return region
end

-- An 'element' can either be a panel, a button, or a tooltip region.
function Window:getTooltipForElement(elem, x, y)
  local text
  if elem.callback then
    text = elem.callback(x, y)
  else
    text = elem.text
  end
  local x, y = elem.tooltip_x, elem.tooltip_y
  if x then x = x + self.x end -- NB: can be nil, then it means position at mouse cursor
  if y then y = y + self.y end
  if text then
    return { text = text, x = x, y = y }
  end
end

--! Query the window for tooltip text to display for a particular position.
--! Tooltips are either associated with buttons, panels, or a region.
-- (see Button:setTooltip, Panel:setTooltip, Window:make[Dynamic]Tooltip)
--! Button tooltips take precedence over region tooltips, which again take precedence over panels.
-- Returns tooltip in form of { text = .. , x = .. , y = .. } or nil for no tooltip.
--!param x (integer) The X co-ordinate relative to the top-left corner.
--!param y (integer) The Y co-ordinate relative to the top-left corner.
function Window:getTooltipAt(x, y)
  if x < 0 or y < 0 or (self.width and x >= self.width) or (self.height and y >= self.height) then
    return
  end
  if self.windows then
    for _, window in ipairs(self.windows) do
      if window:hitTest(x - window.x, y - window.y) then
        return window:getTooltipAt(x - window.x, y - window.y)
      end
    end
  end
  for _, btn in ipairs(self.buttons) do
    if btn.visible ~= false and btn.tooltip and btn.x <= x and x < btn.r and btn.y <= y and y < btn.b then
      return self:getTooltipForElement(btn.tooltip, x, y)
    end
  end
  if not self.tooltip_regions then self.tooltip_regions = {} end -- TEMPORARY for compatibility of pre-r649 savegames. Remove when compatibility is broken anyway.
  for _, region in ipairs(self.tooltip_regions) do
    if region.enabled ~= false and region.x <= x and x < region.r and region.y <= y and y < region.b then
      return self:getTooltipForElement(region, x, y)
    end
  end
  for _, pnl in ipairs(self.panels) do
    if pnl.tooltip and self:hitTestPanel(x, y, pnl) then
      return self:getTooltipForElement(pnl.tooltip, x, y)
    end
  end
end

--! Stub to be extended in subclasses, if needed.
function Window:afterLoad(old, new)
  if old < 2 then
    -- Scrollbars were added
    self.scrollbars = {}
  end
  if old < 3 then
    -- Textboxes were added
    self.textboxes = {}
  end
  if old < 22 then
    self.draggable = true
  end
  if old < 32 then
    -- ui added to buttons
    for _, btn in ipairs(self.buttons) do
      btn.ui = self.ui
    end
  end
  
  if self.windows then
    for _, w in pairs(self.windows) do
      w:afterLoad(old, new)
    end
  end
end
