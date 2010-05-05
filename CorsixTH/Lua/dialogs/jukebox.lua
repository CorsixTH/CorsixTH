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
  self.esc_closes = true
  self.audio = app.audio
  self.ui = app.ui
  self.width = 259
  self.height = 74 + 30 * #self.audio.background_playlist + 18
  self:setDefaultPosition(26, 26)
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req13V", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  self.blue_font = app.gfx:loadFont("QData", "Font02V")
  
  -- Dialog head (current track title & exit button)
  self:addPanel(389, 0, 0)
  for x = 30, self.width - 61, 24 do
    self:addPanel(390, x, 0)
  end
  self:addPanel(391, self.width - 61, 0)
  self:addPanel(409, self.width - 42, 19):makeButton(0, 0, 24, 24, 410, self.close):setTooltip(_S.tooltip.jukebox.close)
  
  self.play_btn =
  self:addPanel(392,   0, 49):makeToggleButton(19, 2, 50, 24, 393, self.togglePlayPause):setSound("selectx.wav"):setTooltip(_S.tooltip.jukebox.play)
  self:updatePlayButton()
  self:addPanel(394,  87, 49):makeButton(0, 2, 24, 24, 395, self.audio.playPreviousBackgroundTrack, self.audio):setSound("selectx.wav"):setTooltip(_S.tooltip.jukebox.rewind)
  self:addPanel(396, 115, 49):makeButton(0, 2, 24, 24, 397, self.audio.playNextBackgroundTrack, self.audio):setSound("selectx.wav"):setTooltip(_S.tooltip.jukebox.fast_forward)
  self:addPanel(398, 157, 49):makeButton(0, 2, 24, 24, 399, self.stopBackgroundTrack):setSound("selectx.wav"):setTooltip(_S.tooltip.jukebox.stop)
  self:addPanel(400, 185, 49):makeButton(0, 2, 24, 24, 401, self.loopTrack):setSound("selectx.wav"):setTooltip(_S.tooltip.jukebox.loop)
  
  -- Track list
  self.track_buttons = {}
  for i, info in ipairs(self.audio.background_playlist) do
    local y = 47 + i * 30
    self:addPanel(402, 0, y)
    for x = 30, self.width - 61, 24 do
      self:addPanel(403, x, y)
    end
    self.track_buttons[i] = self:addPanel(404, self.width - 61, y):makeToggleButton(19, 4, 24, 24, 405):setSound("selectx.wav")
    if not info.enabled then
      self.track_buttons[i]:toggle()
    end
    self.track_buttons[i].on_click = --[[persistable:jukebox_toggle_track]] function(self, off)
      self:toggleTrack(i, info, not off)
    end
  end
  
  -- Dialog footer
  local y = 74 + 30 * #self.audio.background_playlist
  self:addPanel(406, 0, y)
  for x = 30, self.width - 61, 24 do
    self:addPanel(407, x, y)
  end
  self:addPanel(408, self.width - 61, y)
  
  self:makeTooltip(_S.tooltip.jukebox.current_title, 17, 17, 212, 46)
end

-- makes the play button consistent with the current status of the background music
-- running -> toggled
-- stopped -> not toggled
-- paused  -> not toggled
function UIJukebox:updatePlayButton()
  local status = not not self.audio.background_music and not self.audio.background_paused
  if status ~= self.play_btn.toggled then
    self.play_btn:toggle()
  end
end

function UIJukebox:togglePlayPause()
  if not self.audio.background_music then
    self.audio:playRandomBackgroundTrack()
  else
    self.audio:pauseBackgroundTrack()
  end
end

function UIJukebox:stopBackgroundTrack()
  self.audio:stopBackgroundTrack()
end

function UIJukebox:toggleTrack(index, info, on)
  info.enabled = on
  if not on and self.audio.background_music == info.music then
    self.audio:stopBackgroundTrack()
    self.audio:playRandomBackgroundTrack()
  end
end

function UIJukebox:loopTrack()
  local index = self.audio:findIndexOfCurrentTrack()
  local playlist = self.audio.background_playlist
  
  if playlist[index].loop then
    playlist[index].loop = false

    for i, list_entry in ipairs(playlist) do
      if list_entry.enabled_before_loop and index ~= i then
        list_entry.enabled_before_loop = nil
        self:toggleTrack(i, list_entry, true)
        self.track_buttons[i]:toggle()
      end
    end 
  else
    playlist[index].loop = true

    for i, list_entry in ipairs(playlist) do
      if list_entry.enabled and index ~= i then
        list_entry.enabled_before_loop = true
        self:toggleTrack(i, list_entry, false)
        self.track_buttons[i]:toggle()
      end
    end
  end
end

function UIJukebox:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y
  
  local playing = self.audio.background_music or ""
  for i, info in ipairs(self.audio.background_playlist) do
    local y = y + 47 + i * 30
    local font = self.white_font
    if info.music == playing then
      font = self.blue_font
    end
    local str = info.title
    while font:sizeOf(str, font) > 185 do
      str = string.sub(str, 1, string.len(str) - 5) .. "..."
    end
    font:draw(canvas, str, x + 24, y + 11)
    if info.music == playing then
      font:draw(canvas, str, x + 24, self.y + 27)
    end
  end
end
