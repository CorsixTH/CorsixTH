--[[ Copyright (c) 2025 Stephen Baker

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

class "UISoundSettings" (UIResizable)

-- Constants for most button's width and height
local LBL_X = 20
local LBL_WIDTH = 160
local LBL_HEIGHT = 20
local BTN_WIDTH = 165
local BTN_HEIGHT = 20
local BTN_X = LBL_X + LBL_WIDTH + 5
local BIG_BTN_WIDTH = 400
local BIG_BTN_HEIGHT = 30

--@type UISoundSettings
local UISoundSettings = _G["UISoundSettings"]

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

local col_shadow = {
  red = 134,
  green = 126,
  blue = 178,
}

local col_caption = {
  red = 174,
  green = 166,
  blue = 218,
}

function UISoundSettings:UISoundSettings(ui, mode)
  self:UIResizable(ui, 320, 480, col_bg)

  local app = ui.app
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options" or "folders"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  self.app = ui.app

  self.volume_options = { { text = _S.customise_window.option_off, volume = 0 } }
  for i = 10, 100, 10 do
    self.volume_options[#self.volume_options + 1] = { text = _S.menu_options_volume[i], volume = i / 100 }
  end

  local y = 30

  -- global audio on/off
  self:addBevelPanel(LBL_X, y, LBL_WIDTH, LBL_HEIGHT, col_shadow, col_bg, col_bg)
      :setLabel(_S.audio_window.audio)
      :setTooltip(_S.tooltip.audio_window.audio_button).lowered = true
  self.onoff_panel = self:addBevelPanel(BTN_X, y, BTN_WIDTH, BTN_HEIGHT, col_bg)
      :setLabel(app.config.audio and _S.customise_window.option_on or _S.customise_window.option_off)
  self.onoff_button = self.onoff_panel
      :makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.buttonAudioGlobal)
      :setToggleState(app.config.audio)
      :setTooltip(_S.tooltip.audio_window.audio_toggle)

  y = y + 25

  -- sound volume

  local sound_volume_label = app.config.play_sounds and _S.menu_options_volume[app.config.sound_volume * 100] or
      _S.customise_window.option_off
  self:addBevelPanel(LBL_X, y, LBL_WIDTH, LBL_HEIGHT, col_shadow, col_bg, col_bg)
      :setLabel(_S.audio_window.sound_volume)
      :setTooltip(_S.tooltip.audio_window.sound_volume).lowered = true
  self.sound_volume_panel = self:addBevelPanel(BTN_X, y, BTN_WIDTH, BTN_HEIGHT, col_bg)
      :setLabel(sound_volume_label)
  self.sound_volume_button = self.sound_volume_panel
      :makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.dropdownVolume)
      :setTooltip(_S.tooltip.audio_window.sound_volume)

  y = y + 25

  local announcement_volume_label = app.config.play_announcements and
      _S.menu_options_volume[app.config.announcement_volume * 100] or _S.customise_window.option_off
  self:addBevelPanel(LBL_X, y, LBL_WIDTH, LBL_HEIGHT, col_shadow, col_bg, col_bg)
      :setLabel(_S.audio_window.announcement_volume)
      :setTooltip(_S.tooltip.audio_window.announcement_volume).lowered = true
  self.announcement_volume_panel = self:addBevelPanel(BTN_X, y, BTN_WIDTH, BTN_HEIGHT, col_bg)
      :setLabel(announcement_volume_label)
  self.announcement_volume_button = self.announcement_volume_panel
      :makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.dropdownVolume)
      :setTooltip(_S.tooltip.audio_window.announcement_volume)

  y = y + 25

  local music_volume_label = app.config.play_music and _S.menu_options_volume[app.config.music_volume * 100] or
      _S.customise_window.option_off
  self:addBevelPanel(LBL_X, y, LBL_WIDTH, LBL_HEIGHT, col_shadow, col_bg, col_bg)
      :setLabel(_S.audio_window.music_volume)
      :setTooltip(_S.tooltip.audio_window.music_volume).lowered = true
  self.music_volume_panel = self:addBevelPanel(BTN_X, y, BTN_WIDTH, BTN_HEIGHT, col_bg)
      :setLabel(music_volume_label)
  self.music_volume_button = self.music_volume_panel
      :makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.dropdownVolume)
      :setTooltip(_S.tooltip.audio_window.music_volume)

  y = y + 25

  -- Location of soundfont file
  self:addBevelPanel(LBL_X, y, LBL_WIDTH, LBL_HEIGHT, col_shadow, col_bg, col_bg)
      :setLabel(_S.audio_window.soundfont)
      :setTooltip(_S.tooltip.audio_window.soundfont_location).lowered = true
  local tooltip_soundfont = app.config.soundfont and
      _S.tooltip.audio_window.browse_soundfont:format(app.config.soundfont) or
      _S.tooltip.audio_window.no_soundfont_specified
  self:addBevelPanel(BTN_X, y, BTN_WIDTH, BTN_HEIGHT, col_bg)
      :setLabel(app.config.soundfont and app.config.soundfont or tooltip_soundfont)
      :setAutoClip(true)
      :makeButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.buttonBrowseForSoundfont)
      :setTooltip(tooltip_soundfont)

  -- jukebox
  self:addBevelPanel(20, 300, BIG_BTN_WIDTH, BIG_BTN_HEIGHT, col_bg)
      :setLabel(_S.audio_window.jukebox)
      :makeButton(0, 0, BIG_BTN_WIDTH, BIG_BTN_HEIGHT, nil, self.buttonJukebox)
      :setTooltip(_S.tooltip.audio_window.jukebox)

  -- back
  self:addBevelPanel(20, 340, BIG_BTN_WIDTH, BIG_BTN_HEIGHT, col_bg)
      :setLabel(_S.audio_window.back)
      :makeButton(0, 0, BIG_BTN_WIDTH, BIG_BTN_HEIGHT, nil, self.buttonBack)
      :setTooltip(_S.tooltip.audio_window.back)
end

function UISoundSettings:reinitAudio()
  local app = self.ui.app
  app.audio:stopBackgroundTrack()
  app.audio.has_bg_music = false
  app.audio.not_loaded = not app.config.audio
  app.audio.speech_file_name = nil
  app.audio:init()
  app:initLanguage()
  app.audio:playRandomBackgroundTrack()
end

function UISoundSettings:buttonAudioGlobal()
  local app = self.ui.app
  app.config.audio = not app.config.audio
  app:saveConfig()
  self.onoff_button:setLabel(app.config.audio and _S.customise_window.option_on or _S.customise_window.option_off)
  self:reinitAudio()
end

function UISoundSettings:dropdownVolume(activate, btn)
  if activate then
    self:dropdownVolume(false)
    btn:setToggleState(true)

    local select_callback
    if btn == self.sound_volume_button then
      select_callback = self.selectSoundVolume
    elseif btn == self.announcement_volume_button then
      select_callback = self.selectAnnouncementVolume
    elseif btn == self.music_volume_button then
      select_callback = self.selectMusicVolume
    end

    self.volume_dropdown = UIDropdown(self.ui, self, btn, self.volume_options, select_callback)
    self:addWindow(self.volume_dropdown)
  else
    self.sound_volume_button:setToggleState(false)
    self.announcement_volume_button:setToggleState(false)
    self.music_volume_button:setToggleState(false)
    if self.volume_dropdown then
      self.volume_dropdown:close()
      self.volume_dropdown = nil
    end
  end
end

function UISoundSettings:selectSoundVolume(index)
  local vol = self.volume_options[index].volume
  if vol == 0 then
    self.app.config.play_sounds = false
  else
    self.app.config.play_sounds = true
    self.app.config.sound_volume = vol
  end
  self.sound_volume_panel:setLabel(self.volume_options[index].text)
  self.app:saveConfig()
end

function UISoundSettings:selectAnnouncementVolume(index)
  local vol = self.volume_options[index].volume
  if vol == 0 then
    self.app.config.play_announcements = false
  else
    self.app.config.play_announcements = true
    self.app.config.announcement_volume = vol
  end
  self.announcement_volume_panel:setLabel(self.volume_options[index].text)
  self.app:saveConfig()
end

function UISoundSettings:selectMusicVolume(index)
  local vol = self.volume_options[index].volume
  if vol == 0 then
    self.app.config.play_music = false
  else
    self.app.config.play_music = true
    self.app.config.music_volume = vol
  end
  self.music_volume_panel:setLabel(self.volume_options[index].text)
  self.app:saveConfig()
end

function UISoundSettings:buttonBrowseForSoundfont()
  -- Todo: soundfont not font
  local browser = UIChooseFont(self.ui, self.mode)
  self.ui:addWindow(browser)
end

function UISoundSettings:buttonJukebox()
  if self.app.config.audio then
    self.ui:addWindow(UIJukebox(self.app))
  end
end

function UISoundSettings:buttonBack()
  self:close()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

function UISoundSettings:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end
