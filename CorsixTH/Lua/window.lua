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
  self.windows = false -- => {} when first window added
  self.active_button = false
  self.panel_sprites = false
  self.visible = true
end

function Window:close()
  self.parent:removeWindow(self)
end

local panel_mt = {
  __index = {
    makeButton = function(...)
      return (...).window:makeButtonOnPanel(...)
    end,
    makeToggleButton = function(...)
      return (...).window:makeButtonOnPanel(...):makeToggle()
    end,
  }
}

function Window:addPanel(sprite_index, x, y)
  local panel = setmetatable({
    window = self,
    x = x,
    y = y,
    sprite_index = sprite_index,
    visible = true,
  }, panel_mt)
  self.panels[#self.panels + 1] = panel
  return panel
end

local function panel_colour_draw(panel, canvas, x, y)
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

local button_mt = {
  __index = {
    setDisabledSprite = function(self, index)
      self.sprite_index_disabled = index
      return self
    end,
    
    enable = function(self, enable)
      if enable then
        self.enabled = true
        self.panel_for_sprite.sprite_index = self.sprite_index_normal
      else
        self.enabled = false
        self.panel_for_sprite.sprite_index = self.sprite_index_disabled
      end
      return self
    end,
    
    makeToggle = function(self)
      self.is_toggle = true
      self.toggled = false
      return self
    end,
    
    toggle = function(self)
      self.sprite_index_normal, self.sprite_index_active =
        self.sprite_index_active, self.sprite_index_normal
      self.panel_for_sprite.sprite_index = self.sprite_index_normal
      self.toggled = not self.toggled
      return self.toggled
    end,
    
    preservePanel = function(self)
      local window = self.panel_for_sprite.window
      self.panel_for_sprite = window:addPanel(0, self.x, self.y)
      self.sprite_index_normal = 0
      return self
    end,
    
    setSound = function(self, name)
      self.sound = name
      return self
    end,
  }
}

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

function Window:draw(canvas)
  local x, y = self.x, self.y
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
        windows[i]:draw(canvas)
      end
    end
  end
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
  return repaint
end

function Window:onMouseUp(button, x, y)
  local repaint = false

  if self.windows then
    for _, window in ipairs(self.windows) do
      if window:onMouseUp(button, x - window.x, y - window.y) then
        repaint = true
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
    local index = btn.sprite_index_normal
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
