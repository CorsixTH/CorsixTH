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

--! The (ideally) helpful advisor who pops up from the bottom dialog during a game.
class "UIAdviser" (Window)

function UIAdviser:UIAdviser(ui)
  self:Window()
  
  local app = ui.app
  
  self.esc_closes = false
  self.modal_class = "adviser"
  self.tick_rate = app.world.tick_rate
  self.tick_timer = self.tick_rate -- Initialize tick timer
  self.frame = 1                   -- Current frame
  self.visible = false
  self.number_frames = 4           -- Used for playing animation only once
  self.speech = nil                -- Store what adviser is going to say
  self.is_talking = false          -- If adviser is already been saying something
  self.timer = nil                 -- Timer which hide adviser when ends
  self.ui = ui
  self.width = 200
  self.height = 64
  self.x = 378
  self.y = -16
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "Panel02V", true)
  self.black_font = app.gfx:loadFont("QData", "Font50V")
  
  local th = TH.animation()
  self.th = th
end

function UIAdviser:show()
  self.th:setAnimation(self.ui.app.world.anims, 438)
  self.frame = 1
  self.visible = true
  self.number_frames = 4
end

function UIAdviser:hide()
  self.th:setAnimation(self.ui.app.world.anims, 440)
  self.frame = 1
  self.visible = false
  self.number_frames = 4
  self.speech = nil
  self.is_talking = false
  self.timer = nil
end

function UIAdviser:idle()
  self.speech = nil
  self.is_talking = false
  self.timer = 150
end

function UIAdviser:say(speech)
  if speech ~= self.speech then
    self.speech = speech
  end
  
  self.timer = nil

  if self.visible == false then
    self:show()
    return
  end
  
  self.th:setAnimation(self.ui.app.world.anims, 460)
  self.frame = 1
  self.number_frames = 45
  
  -- Calculate number of lines needed for the text. Each "/" at end of string indicates a blank line
  local number_lines = 3
  local speech_trimmed = speech:gsub("/*$", "")
  number_lines = number_lines - (#speech - #speech_trimmed)
  speech = speech_trimmed
  
  -- Calculate balloon width from string len
  self.balloon_width = math.floor(#speech / number_lines) * 7
  if self.balloon_width >= 420 then -- Balloon too large
    self.balloon_width = 420
  elseif self.balloon_width <= 40 then -- Balloon too small
    self.balloon_width = 40
  end
  self.is_talking = true
end

function UIAdviser:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  
  x, y = x + self.x, y + self.y
  self.th:draw(canvas, x + 200, y)
  if self.is_talking == true then
    -- Draw ballon
    local x_left_sprite
    for dx=0, self.balloon_width, 16 do
      x_left_sprite = x + 139 - dx
      self.panel_sprites:draw(canvas, 38, x_left_sprite, y - 25)
    end
    self.panel_sprites:draw(canvas, 37, x_left_sprite - 16, y - 25)
    self.panel_sprites:draw(canvas, 39, x + 155, y - 40)
    -- Draw text
    self.black_font:drawWrapped(canvas, self.speech, x_left_sprite - 8, y - 20, self.balloon_width + 60)
  end
end

function UIAdviser:onTick()
   if self.timer == 0 then
      self:hide() -- Timer ends, so we hide the adviser
   elseif self.timer ~= nil then
      self.timer = self.timer - 1
  end

  if self.frame < self.number_frames then
    if self.tick_timer == 0 then -- Used for making a smooth animation
      self.tick_timer = self.tick_rate
      if self.th:getAnimation() ~= 0 then -- If no animation set (adviser not being shown already)
        self.th:tick()
        self.frame = self.frame + 1
      end
    else
      self.tick_timer = self.tick_timer - 1
    end
  elseif self.visible == false and self.frame == self.number_frames then
    -- Visibility is set to false so we want to hide adviser but we have to wait until the animation ends
    self.th:makeInvisible()
  elseif self.visible == true and self.speech ~= nil and self.is_talking == false then
    -- Adviser not already talking and he has something to say so let's him speak
    self:say(self.speech)
  elseif self.visible == true and self.is_talking == true and self.frame == self.number_frames then
    -- Adviser finished to talk so make him idle
    self:idle()
  end
end
