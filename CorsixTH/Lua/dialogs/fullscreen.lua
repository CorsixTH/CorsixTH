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
  if app.config.width > self.width or app.config.height > self.height then
    self.border_sprites = TheApp.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
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

function UIFullscreen:draw(canvas)
  local sprites = self.border_sprites
  if sprites then
    local draw = sprites.draw
    local x = self.x
    local y = self.y
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
  return Window.draw(self, canvas)
end
