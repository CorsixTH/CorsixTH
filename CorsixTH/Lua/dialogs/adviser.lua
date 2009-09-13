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

local TH = require "TH"

class "UIAdviser" (Window)

function UIAdviser:UIAdviser(ui)
  self:Window()
  
  local app = ui.app
  
  self.esc_closes = false
  self.modal_class = "adviser"
  self.tick_count = 0
  self.frame = 1
  self.visible = false
  self.number_frames = 4
  self.speech = nil
  self.is_talking = false
  self.timer = nil
  self.ui = ui
  self.width = 200
  self.height = 64
  self.x = 0.5 * app.config.width
  self.y = app.config.height - self.height
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "Panel02V", true)
  self.black_font = app.gfx:loadFont("QData", "Font50V")
  
  local th = TH.animation()
  th:setSpeed(0, 0)
  self.th = th
end

function UIAdviser:show()
  self.th:setAnimation(self.ui.app.world.anims, 438)
  self.tick_count = 0
  self.frame = 1
  self.visible = true
  self.number_frames = 4
end

function UIAdviser:hide()
  self.th:setAnimation(self.ui.app.world.anims, 440)
  self.tick_count = 0
  self.frame = 1
  self.visible = false
  self.number_frames = 4
  self.speech = nil
  self.is_talking = false
  self.timer = nil
end

function UIAdviser:say(speech)
  if speech ~= self.speech then
    self.speech = speech
  end

  if self.visible == false then
    self:show()
    return
  end
  
  self.th:setAnimation(self.ui.app.world.anims, 460)
  self.tick_count = 0
  self.frame = 1
  self.number_frames = 28
  
  local number_lines = 3
  for i=1, 2 do
    if speech:sub(-1) == "/" then
      number_lines = number_lines - 1
      speech = speech:sub(0, -2)
    end
  end
  
  self.balloon_width = math.floor(#speech / number_lines) * 7
  if self.balloon_width >= 400 then
    self.balloon_width = 400
  elseif self.balloon_width <= 40 then
    self.balloon_width = 40
  end
  self.is_talking = true
  self.timer = 300
end

function UIAdviser:draw(canvas)
  local x, y = self.x, self.y

  Window.draw(self, canvas)
  self.th:draw(canvas, x + 200, y)
  if self.is_talking == true then
    local x_left_sprite
    for dx=0, self.balloon_width, 16 do
      x_left_sprite = x + 139 - dx
      self.panel_sprites:draw(canvas, 38, x_left_sprite, y - 25)
    end
    self.panel_sprites:draw(canvas, 37, x_left_sprite - 16, y - 25)
    self.panel_sprites:draw(canvas, 39, x + 155, y - 40)
    self.black_font:drawWrapped(canvas, self.speech, x_left_sprite - 8, y - 20, self.balloon_width + 60)
  end
end

function UIAdviser:onTick()
   if self.timer == 0 then
    self:hide()
   elseif self.timer ~= nil then
      self.timer = self.timer - 1
  end

  if self.frame < self.number_frames then
    if self.tick_count == 6 then
      self.tick_count = 0
      if self.th:getAnimation() ~= 0 then
        self.th:tick()
        self.frame = self.frame + 1
      end
    else
      self.tick_count = self.tick_count + 1
    end
  elseif self.visible == false and self.frame == self.number_frames then
    self.th:makeInvisible()
  elseif self.visible == true and self.speech ~= nil and self.is_talking == false then
    self:say(self.speech)
  end
end
