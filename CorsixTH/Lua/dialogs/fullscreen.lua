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

---@type UIFullscreen
local UIFullscreen = _G["UIFullscreen"]

function UIFullscreen:UIFullscreen(ui)
  self:Window()

  self.esc_closes = true
  self.ui = ui
  self.modal_class = "fullscreen"

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
  local s = app.config.ui_scale
  local sw = app.config.width / s
  local sh = app.config.height / s
  if sw > self.width or sh > self.height then
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

  self.x = math.floor((sw - self.width) / 2)

  -- NB: Bottom panel is 48 pixels high
  if sh > 480 + 48 then
    self.y = math.floor((sh - 48 - self.height) / 2)
  elseif app.config.height >= 480 then
    self.y = 0
  else
    self.y = math.floor((sh - self.height) / 2)
  end
end

function UIFullscreen:draw(canvas, x, y)
  local sprites = self.border_sprites
  if sprites then
    local s = TheApp.config.ui_scale
    local draw = sprites.draw
    local scr_x = self.x * s + x
    local scr_y = self.y * s + y
    canvas:nonOverlapping(true)
    draw(sprites, canvas, 10, scr_x - 9 * s, scr_y - 9 * s, { scaleFactor = s })
    draw(sprites, canvas, 12, scr_x + 600 * s, scr_y - 9 * s, { scaleFactor = s })
    draw(sprites, canvas, 15, scr_x - 9 * s, scr_y + 440 * s, { scaleFactor = s })
    draw(sprites, canvas, 17, scr_x + 600 * s, scr_y + 440 * s, { scaleFactor = s })
    for loop_x = scr_x + 40 * s, scr_x + 560 * s, 40 * s do
      draw(sprites, canvas, 11, loop_x, scr_y - 9 * s, { scaleFactor = s })
      draw(sprites, canvas, 16, loop_x, scr_y + 480 * s, { scaleFactor = s })
    end
    for loop_y = scr_y + 40 * s, scr_y + 400 * s, 40 * s do
      draw(sprites, canvas, 13, scr_x - 9 * s, loop_y, { scaleFactor = s })
      draw(sprites, canvas, 14, scr_x + 640 * s, loop_y, { scaleFactor = s })
    end
    canvas:nonOverlapping(false)
  end
  return Window.draw(self, canvas, x, y)
end

function UIFullscreen:onMouseDown(button, x, y)
  local repaint = Window.onMouseDown(self, button, x, y)
  local s = TheApp.config.ui_scale
  if button == "left" and not repaint and not (x >= 0 and y >= 0 and
      x < self.width * s and y < self.height * s) and self:hitTest(x, y) then
    return self:beginDrag(x, y)
  end
  return repaint
end

function UIFullscreen:hitTest(x, y)
  local s = TheApp.config.ui_scale
  if x >= 0 and y >= 0 and x < self.width * s and y < self.height * s then
    return true
  end
  local sprites = self.border_sprites
  if not sprites then
    return false
  end
  if x < -9 * s or y < -9 * s or x >= self.width * s + 9 * s or y >= self.height * s + 9 * s then
    return false
  end
  if (0 <= x and x < self.width * s) or (0 <= y and y < self.height * s) then
    return true
  end

  return sprites.hitTest(sprites, 10, x + 9 * s,   y + 9 * s) or
         sprites.hitTest(sprites, 12, x - 600 * s, y + 9 * s) or
         sprites.hitTest(sprites, 15, x + 9 * s,   y - 440 * s) or
         sprites.hitTest(sprites, 17, x - 600 * s, y - 440 * s)
end

function UIFullscreen:afterLoad(old, new)
  Window.afterLoad(self, old, new)
  if old < 22 then
    self.draggable = not not self.border_sprites
  end
end
