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

--! Base class for user-interface dialogs.
class "Window"

Window.buttons_down = {
  left = false,
  middle = false,
  right = false,
  
  alt = false,
  ctrl = false,
  shift = false,
}

function Window:Window()
  self.x = 0
  self.y = 0
  self.panels = {
  }
  self.buttons = {
  }
  self.key_handlers = {--[[a set]]}
  self.windows = false -- => {} when first window added
  self.active_button = false
  self.blinking_button = false
  self.blink_counter = 0
  self.panel_sprites = false
  self.visible = true
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

function Window:onChangeResolution()
  if self.x_original and self.y_original then
    self:setPosition(self.x_original, self.y_original)
  end
end

function Window:close()
  self.parent:removeWindow(self)
  for key in pairs(self.key_handlers) do
    self.ui:removeKeyHandler(key, self)
  end
end

function Window:addKeyHandler(key, handler)
  self.ui:addKeyHandler(key, self, handler)
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

local --[[persistable: window_panel_colour_draw]] function panel_colour_draw(panel, canvas, x, y)
  canvas:drawRect(panel.colour, x + panel.x, y + panel.y, panel.w, panel.h)
end

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

function Window:addWindow(window)
  if not self.windows then
    self.windows = {}
  end
  window.parent = self
  if window.on_top then
    -- As self.windows array is ordered from top to bottom and drawn by the end, a "On Top" window has be added at start
    table.insert(self.windows, 1, window) 
  else
    -- Normal windows, are added to the end
    self.windows[#self.windows + 1] = window
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

-- searches in child windows for window of given class, and returns it (or nil)
function Window:getWindow(window_class)
  if self.windows then
    for _, window in ipairs(self.windows) do
      if class.is(window, window_class) then
        return window
      end
    end
  end
end

--! A region of a `Panel` which causes some action when clicked.
class "Button"

--!dummy
function Button:Button()
  self.is_toggle = nil
  self.x = nil
  self.y = nil
  self.r = nil
  self.b = nil
  self.panel_for_sprite = nil
  self.sprite_index_normal = nil
  self.sprite_index_disabled = nil
  self.sprite_index_active = nil
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
  else
    self.enabled = false
    self.panel_for_sprite.sprite_index = self.sprite_index_disabled
  end
  return self
end

function Button:makeToggle()
  self.is_toggle = true
  self.toggled = false
  return self
end

function Button:toggle()
  self.sprite_index_normal, self.sprite_index_active =
    self.sprite_index_active, self.sprite_index_normal
  self.panel_for_sprite.sprite_index = self.sprite_index_normal
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

function Button:setTooltip(tooltip)
  self.tooltip = tooltip
  return self
end

function Window:makeButtonOnPanel(panel, x, y, w, h, sprite, on_click, on_click_self, on_rightclick)
  x = x + panel.x
  y = y + panel.y
  local button = setmetatable({
    is_toggle = false,
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
  }, button_mt)
  if self.ui and on_click == self.close then
    button.sound = "no4.wav"
  elseif self.default_button_sound then
    button.sound = self.default_button_sound
  end
  self.buttons[#self.buttons + 1] = button
  return button
end

function Window:draw(canvas, x, y)
  x, y = x + self.x, y + self.y
  if self.panels[1] then
    local panel_sprites = self.panel_sprites
    local panel_sprites_draw = panel_sprites.draw
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
  if self.windows then
    local windows = self.windows
    for i = #windows, 1, -1 do
      if windows[i].visible then
        windows[i]:draw(canvas, x, y)
      end
    end
  end
end

function Window:hitTest(x, y)
  if x < 0 or y < 0 or (self.width and x >= self.width) or (self.height and y >= self.height) then
    return false
  end
  if self.panels[1] then
    local panel_sprites = self.panel_sprites
    local panel_sprites_hittest = panel_sprites.hitTest
    for _, panel in ipairs(self.panels) do repeat
      if not panel.visible then
        break -- continue
      end
      local x, y = x - panel.x, y - panel.y
      if x < 0 or y < 0 then
        break -- continue
      end
      if panel.w and panel.h then
        if x <= panel.w and y <= panel.h then
          return true
        end
      else
        if panel_sprites_hittest(panel_sprites, panel.sprite_index, x, y) then
          return true
        end
      end
    until true end
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
      end
    end
  end
  if button == "left" or button == "right" then
    for _, btn in ipairs(self.buttons) do
      if btn.enabled and btn.x <= x and x < btn.r and btn.y <= y and y < btn.b and (button == "left" or btn.on_rightclick ~= nil) then
        btn.panel_for_sprite.sprite_index = btn.sprite_index_active
        self.active_button = btn
        btn.active = true
        repaint = true
        break
      end
    end
  end
  if button == "left" and not repaint and Window.hitTest(self, x, y) then
    return self:beginDrag(x, y)
  end
  return repaint
end

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
        break			-- Click has been handled. No need to look any further.
      end
    end
  end
  
  if button == "left" or button == "right" then
    local btn = self.active_button
    if btn then
      btn.panel_for_sprite.sprite_index = btn.sprite_index_normal
      btn.active = false
      self.active_button = false
      if btn.enabled and btn.x <= x and x < btn.r and btn.y <= y and y < btn.b then
        local arg = nil
        if btn.is_toggle then
          arg = btn:toggle()
        end
        if button == "left" then
          if btn.sound then
            self.ui:playSound(btn.sound)
          end
          if btn.on_click == nil then
            print("Warning: No handler for button click")
            btn.on_click = function() end
          else
            btn.on_click(btn.on_click_self, arg, btn)
          end
        else
          if btn.sound then
            self.ui:playSound(btn.sound)
          end
          if btn.on_rightclick ~= nil then
            btn.on_rightclick(btn.on_click_self, arg)
          end
        end
      end
      repaint = true
    end
  end
  
  return repaint
end

local --[[persistable:window_drag_round]] function round(value, amount)
  return amount * math.floor(value / amount + 0.5)
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

function Window:beginDrag(x, y)
  if not self.width or not self.height or not self.ui
  or self.ui.app.runtime_config.lock_windows then
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
    else
      self.active_button.active = false
      for _, btn in ipairs(self.buttons) do
        if btn.enabled and btn.x <= x and x < btn.r and btn.y <= y and y < btn.b then
          btn.panel_for_sprite.sprite_index = btn.sprite_index_active
          btn.active = true
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
  
  return repaint
end

function Window:onTick()
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
  if self.windows then
    for _, window in ipairs(self.windows) do
      window:onTick()
    end
  end
end

function Window:onWorldTick()
  if self.windows then
    for _, window in ipairs(self.windows) do
      window:onWorldTick()
    end
  end
end

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
    table.remove(self.windows, window_index) -- Remove the window from the list
    table.insert(self.windows, 1, window)    -- And reinsert it at start of the table
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

-- Override/Extend in window classes for additional (non-button) tooltips.
-- return tooltip in form of { text = .. , x = .. , y = .. } or nil for no tooltip.
-- x, y are optional - if not specified, cursor position will be used for tooltip.
function Window:getTooltipAt(x, y)
  if x < 0 or y < 0 or (self.width and x >= self.width) or (self.height and y >= self.height) then
    return
  end
  if self.windows then
    for _, window in ipairs(self.windows) do
      local tooltip = window:getTooltipAt(x - window.x, y - window.y)
      if tooltip then
        return tooltip
      end
    end
  end
  for _, btn in ipairs(self.buttons) do
    if btn.tooltip and btn.x <= x and x < btn.r and btn.y <= y and y < btn.b then
      return { text = btn.tooltip, x = self.x + round((btn.x + btn.r) / 2, 1), y = self.y + btn.y }
    end
  end
end
