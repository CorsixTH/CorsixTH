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

--! Base class for 640x480px dialogs (fullscreen in original game resolution).
class "UIFullscreen" (Window)

function UIFullscreen:UIFullscreen(ui)
  self:Window()
  
  local app = ui.app
  self.esc_closes = true
  self.ui = ui
  self.modal_class = "fullscreen"
  self.on_top = true
  self.width = 640
  self.height = 480
  
  self:onChangeResolution()
end

-- Cause all fullscreen windows to share a common saved window position.
function UIFullscreen:getSavedWindowPositionName()
  return "UIFullscreen"
end

function UIFullscreen:onChangeResolution()
  local app = self.ui.app
  if app.config.width > self.width or app.config.height > self.height then
    if not self.border_sprites then
      self.border_sprites = app.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
    end
  else
    self.border_sprites = nil
  end
  -- not draggable in actual fullscreen mode
  self.draggable = not not self.border_sprites
  
  local config = self.ui.app.runtime_config.window_position
  if config then
    config = config[self:getSavedWindowPositionName()]
    if config and config.x and config.y then
      return self:setPosition(config.x, config.y)
    end
  end
  
  self.x = (app.config.width - self.width) / 2
  
  -- NB: Bottom panel is 48 pixels high
  if app.config.height > 480 + 48 then
    self.y = (app.config.height - 48 - self.height) / 2
  elseif app.config.height >= 480 then
    self.y = 0
  else
    self.y = (app.config.height - self.height) / 2
  end
end

function UIFullscreen:draw(canvas, x, y)
  local sprites = self.border_sprites
  if sprites then
    local draw = sprites.draw
    local x = self.x + x
    local y = self.y + y
    canvas:nonOverlapping(true)
    draw(sprites, canvas, 10, x - 9, y - 9)
    draw(sprites, canvas, 12, x + 600, y - 9)
    draw(sprites, canvas, 15, x - 9, y + 440)
    draw(sprites, canvas, 17, x + 600, y + 440)
    for x = x + 40, x + 560, 40 do
      draw(sprites, canvas, 11, x, y - 9)
      draw(sprites, canvas, 16, x, y + 480)
    end
    for y = y + 40, y + 400, 40 do
      draw(sprites, canvas, 13, x - 9, y)
      draw(sprites, canvas, 14, x + 640, y)
    end
    canvas:nonOverlapping(false)
  end
  return Window.draw(self, canvas, x, y)
end

function UIFullscreen:onMouseDown(button, x, y)
  local repaint = Window.onMouseDown(self, button, x, y)
  if button == "left" and not repaint and not (x >= 0 and y >= 0 and
  x < self.width and y < self.height) and self:hitTest(x, y) then
    return self:beginDrag(x, y)
  end
  return repaint
end

function UIFullscreen:hitTest(x, y)
  if x >= 0 and y >= 0 and x < self.width and y < self.height then
    return true
  end
  local sprites = self.border_sprites
  if not sprites then
    return false
  end
  if x < -9 or y < -9 or x >= self.width + 9 or y >= self.height + 9 then
    return false
  end
  if (0 <= x and x < self.width) or (0 <= y and y < self.height) then
    return true
  end
  local test = sprites.hitTest
  return test(sprites, 10, x + 9, y + 9)
      or test(sprites, 12, x - 600, y + 9)
      or test(sprites, 15, x + 9, y - 440)
      or test(sprites, 17, x - 600, y - 440)
end

function UIFullscreen:afterLoad(old, new)
  Window.afterLoad(self, old, new)
  if old < 22 then
    self.draggable = not not self.border_sprites
  end
end
