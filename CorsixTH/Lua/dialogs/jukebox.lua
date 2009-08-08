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

local ipairs
    = ipairs

class "UIJukebox" (Window)

function UIJukebox:UIJukebox(app)
  self:Window()
  self.modal_class = "jukebox"
  self.audio = app.audio
  self.x = 26
  self.y = 26
  self.width = 259
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req13V", true)
  self.white_font = app.gfx:loadFont(app.gfx:loadSpriteTable("QData", "Font01V"))
  self.blue_font = app.gfx:loadFont(app.gfx:loadSpriteTable("QData", "Font02V"))
  
  -- Dialog head (current track title & exit button)
  self:addPanel(389, 0, 0)
  for x = 30, self.width - 61, 24 do
    self:addPanel(390, x, 0)
  end
  self:addPanel(391, self.width - 61, 0)
  self:addPanel(409, self.width - 42, 19):makeButton(0, 0, 24, 24, 410, self.close)
  
  self.play_btn =
  self:addPanel(392,   0, 49):makeToggleButton(19, 2, 50, 24, 393)
  if self.audio.background_music then
    self.play_btn:toggle()
  end
  self:addPanel(394,  87, 49) -- Previous
  self:addPanel(396, 115, 49):makeButton(0, 2, 24, 24, 397, self.audio.playNextBackgroundTrack, self.audio)
  self:addPanel(398, 157, 49) -- Stop
  self:addPanel(400, 185, 49) -- Loop
  
  -- Track list
  for i, info in ipairs(self.audio.background_playlist) do
    local y = 47 + i * 30
    self:addPanel(402, 0, y)
    for x = 30, self.width - 61, 24 do
      self:addPanel(403, x, y)
    end
    local btn = self:addPanel(404, self.width - 61, y):makeToggleButton(19, 4, 24, 24, 405)
    if not info.enabled then
      btn:toggle()
    end
    btn.on_click = function(self, off) self:toggleTrack(i, info, not off) end
  end
  
  -- Dialog footer
  local y = 74 + 30 * #self.audio.background_playlist
  self:addPanel(406, 0, y)
  for x = 30, self.width - 61, 24 do
    self:addPanel(407, x, y)
  end
  self:addPanel(408, self.width - 61, y)
end

function UIJukebox:toggleTrack(index, info, on)
  info.enabled = on
  if not on and self.audio.background_music == info.music then
    self.audio:stopBackgroundTrack()
    self.audio:playRandomBackgroundTrack()
  end
end

function UIJukebox:draw(canvas)
  Window.draw(self, canvas)
  
  local playing = self.audio.background_music or ""
  local x, y = self.x, self.y
  for i, info in ipairs(self.audio.background_playlist) do
    local y = y + 47 + i * 30
    local font = self.white_font
    if info.music == playing then
      font = self.blue_font
    end
    font:draw(canvas, info.title, x + 24, y + 11)
    if info.music == playing then
      font:draw(canvas, info.title, x + 24, self.y + 27)
    end
  end
end
