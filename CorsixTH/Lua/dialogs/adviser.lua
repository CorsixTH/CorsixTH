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

local TH = require("TH")

--! The (ideally) helpful advisor who pops up from the bottom dialog during a game.
class "UIAdviser" (Window)

---@type UIAdviser
local UIAdviser = _G["UIAdviser"]

function UIAdviser:UIAdviser(ui)
  self:Window()

  local app = ui.app

  self.esc_closes = false
  self.modal_class = "adviser"
  self.tick_rate = app.world.tick_rate
  self.tick_timer = self.tick_rate -- Initialize tick timer
  self.frame = 1                   -- Current frame
  self.number_frames = 4           -- Used for playing animation only once
  self.speech = nil                -- Store what adviser is going to say
  self.queued_messages = {}        -- There might be many messages in a row
  self.timer = nil                 -- Timer which hides adviser at the end

  -- There are 5 phases the adviser might be in on a given time point.
  -- Not visible, getting up, talking, idling, getting_down.
  self.phase = 0

  self.ui = ui
  self.width = 80
  self.height = 74
  self.x = 378
  self.y = -16
  self.balloon_width = 0
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "Panel02V", true)
  self.black_font = app.gfx:loadFont("QData", "Font50V")

  local th = TH.animation()
  self.th = th
end

-- Shows the adviser by running the "popup" animation.
-- Then moves on to the next phase automatically.
function UIAdviser:show()
  self.phase = 1
  self.th:setAnimation(self.ui.app.world.anims, 438)
  self.frame = 1
  self.number_frames = 4
end

-- Displays the text bubble along with the next message
-- from the queue.
function UIAdviser:talk()
  self.phase = 2
  self.th:setAnimation(self.ui.app.world.anims, 460)
  self.frame = 1
  self.timer = nil -- Reset the idle timer
  self.number_frames = 45
  -- Fetch the next message from the queue.
  local best = 1
  if self.queued_messages[1].priority then
    for i = 1, #self.queued_messages do
      if best ~= i and self.queued_messages[best].priority < self.queued_messages[i].priority then
        best = i
      end
    end
  end
  local speech = self.queued_messages[best].speech
  self.stay_up = self.queued_messages[best].stay_up
  table.remove(self.queued_messages, best)
  self.speech = speech
  -- Calculate number of lines needed for the text.
  -- Each "/" at end of string indicates a blank line
  local number_lines = 3
  local speech_trimmed = speech:gsub("/*$", "")
  number_lines = number_lines - (#speech - #speech_trimmed)
  speech = speech_trimmed

  -- Calculate balloon width from string length
  self.balloon_width = math.floor(#speech / number_lines) * 7
  if self.balloon_width >= 420 then -- Balloon too large
    self.balloon_width = 420
  elseif self.balloon_width <= 40 then -- Balloon too small
    self.balloon_width = 40
  end
end

-- Makes the adviser idle for a while before disappearing.
-- This means that the text bubble is removed.
function UIAdviser:idle()
  self.phase = 3
  -- Remove the bubble and start a timer for disappearance
  -- unless he should stay up until the next message.
  if not self.stay_up then
    self.speech = nil
    self.timer = 150
  end
end

-- Hides the adviser by running the appropriate animation.
function UIAdviser:hide()
  self.timer = nil
  self.phase = 4
  self.th:setAnimation(self.ui.app.world.anims, 440)
  self.frame = 1
  self.number_frames = 4
  self.ui:tutorialStep(1, 1, 2)
end

-- Makes the adviser say something
--!param speech The table containing the text he should say and the priority.
--!param talk_until_next_announce Whether he should stay up
-- until the next say() call is made. Useful for the tutorial.
--!param override_current Cancels previous messages (if any) immediately
-- and shows this new one instead.
function UIAdviser:say(speech, talk_until_next_announce, override_current)
  assert(type(speech) == "table")
  if not self.ui.app.config.adviser_disabled then
    -- Queue the new message
    self.queued_messages[#self.queued_messages + 1] = {
      speech = speech.text,
      stay_up = talk_until_next_announce,
      priority = speech.priority
    }
    if self.phase == 0 then
      -- The adviser is not active at all at the moment.
      self:show()
    elseif self.phase == 3 then
      -- He's not talking, so we can show the new message.
      self:talk()
    elseif self.phase == 4 then
      -- He's getting down. Let him do that and then tell him
      -- to go up again.
      self.up_again = true
    elseif override_current then
      -- He was saying/was about to say something else. Discard those messages.
      self.queued_messages[1] = self.queued_messages[#self.queued_messages]
      while #self.queued_messages > 1 do
        table.remove(self.queued_messages)
      end
      -- Now say the new thing instead.
      self:talk()
    end
    -- If none of the above apply the message is now queued and will be shown in
    -- due time.
  end
end

function UIAdviser:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)

  x, y = x + self.x, y + self.y
  self.th:draw(canvas, x + 200, y)
  if self.phase == 2 then
    -- Draw ballon only in the "talk" phase.
    local x_left_sprite
    for dx = 0, self.balloon_width, 16 do
      x_left_sprite = x + 139 - dx
      self.panel_sprites:draw(canvas, 38, x_left_sprite, y - 25)
    end
    self.panel_sprites:draw(canvas, 37, x_left_sprite - 16, y - 25)
    self.panel_sprites:draw(canvas, 39, x + 155, y - 40)
    -- Draw text
    self.black_font:drawWrapped(canvas, self.speech, x_left_sprite - 8, y - 20, self.balloon_width + 60)
  end
end

function UIAdviser:onMouseDown(button, x, y)
  -- If the adviser is not up, don't do anything.
  if self.phase == 0 or self.phase == 4 then
    return Window.onMouseDown(self, button, x, y)
  end
  -- Normal operation outside the adviser bounds
  if x + self.balloon_width < 128 or x > 200 or
      y + self.y > 0 or y + self.y + 40 < 0 then
    if x < self.x - 200 or y < self.y - 40 or
        x > self.x - 200 + self.width or y > self.y + self.height - 40 then
      return Window.onMouseDown(self, button, x, y)
    end
  end

  -- Dismiss the current message if left click. If right click,
  -- dismiss the whole queue.
  if button == "left" then
    if #self.queued_messages > 0 then
      self:talk()
    else
      self:hide()
    end
  elseif button == "right" then
    self:hide()
    self.queued_messages = {}
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
      -- If no animation set (adviser not being shown already)
      if self.th:getAnimation() ~= 0 then
        self.th:tick()
        self.frame = self.frame + 1
      end
    else
      self.tick_timer = self.tick_timer - 1
    end
  elseif self.frame == self.number_frames then
    if self.phase == 1 then
      -- Adviser is now up, let him speak.
      self:talk()
    elseif self.phase == 2 then
      -- Adviser finished to talk so make him idle unless
      -- there's another message waiting.
      if #self.queued_messages > 0 then
        -- Show the next queued message
        self:talk()
      elseif not self.stay_up then
        -- Continue to talk if stay_up is set
        self:idle()
      end
    elseif self.phase == 4 then
      -- The adviser is getting down so we want to hide him, but we have
      -- to wait until the animation ends.
      if self.up_again then
        -- Another message arrived while getting down.
        self:show()
        self.up_again = false
      else
        self.phase = 0
        self.th:makeInvisible()
      end
    end
  end
end

function UIAdviser:afterLoad(old, new)
  if old < 47 then
    self.enabled = true
  end
  Window.afterLoad(self, old, new)
end
