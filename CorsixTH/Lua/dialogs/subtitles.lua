--[[ Copyright (c) 2026 Fraggenard

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

--! UI display area for announcer subtitles
class "Subtitles" (Window)

---@type Subtitles
local Subtitles = _G["Subtitles"]

--! Subtitles constructor
function Subtitles:Subtitles()
  self:Window()
  self.x = 0
  self.y = 0
  self.white_font = TheApp.gfx:loadFontAndSpriteTable("QData", "Font01V", nil, nil, { apply_ui_scale = true })
  
  self.queue = SubtitleQueue()
end

--! Pushes an announcer audio file's associated subtitle text to the queue for display
--!param name (string) Filename of the announcer sound to display
function Subtitles:queueSubtitle(name)
  if _S.subtitles ~= nil then
    local subtitleString = _S.subtitles[string.gsub(string.lower(name), ".wav", "")]
	if subtitleString ~= nil then
	  --Second field of subtitle object is the subtitle's display lifetime, measured in ticks
	  --280 ticks = ~5 seconds
	  self.queue:push({subtitleString, 280})
	end
  end
end

function Subtitles:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  local s = TheApp.config.ui_scale
  x, y = x + self.x * s, y + self.y * s

  if not self.queue:isEmpty() then
    if TheApp.config.enable_announcer_subtitles then
	  local displayIndex = 1
      for _, subtitle in ipairs(self.queue.subtitles) do
	    self.white_font:draw(canvas, subtitle[1], 5, (5 + 16 * s) * displayIndex, 0, 16)
	    displayIndex = displayIndex + 1
      end
	end
  end
end

--! Subtitle area's tick handler
-- Removes a subtitle from the queue if it has reached its tick lifetime
function Subtitles:onTick()
  if not self.queue:isEmpty() then
    for _, subtitle in ipairs(self.queue.subtitles) do
	  local subtitleLifetime = subtitle[2]
	  if subtitleLifetime <= 1 then 
	    self.queue:pop()
	  else
	    subtitle[2] = subtitleLifetime - 1
	  end
	end
  end
end

--! First in, first out queue for concurrently displayed subtitles
class "SubtitleQueue"

---@type SubtitleQueue
local SubtitleQueue = _G["SubtitleQueue"]

--! SubtitleQueue constructor
function SubtitleQueue:SubtitleQueue()
  self.count = 0
  self.subtitles = {}
end

--! Pushes subtitle text to the queue for display
--!param subtitle (string) Subtitle text to display
function SubtitleQueue:push(subtitle)
  table.insert(self.subtitles, subtitle)
  self.count = self.count + 1
end

--! Removes subtitle text at the top of the queue
function SubtitleQueue:pop()
  if self.subtitles[1] ~= nil then
    table.remove(self.subtitles, 1)
	self.count = self.count - 1
  end
end

--! Returns true if the queue is empty, false otherwise
function SubtitleQueue:isEmpty()
  return self.count == 0
end