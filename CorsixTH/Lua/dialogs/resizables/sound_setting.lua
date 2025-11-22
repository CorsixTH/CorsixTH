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

---@type UISoundSettings
local UISoundSettings = _G["UISoundSettings"]

-- Constants for most button's width and height
local LBL_X = 20
local LBL_WIDTH = 160
local LBL_HEIGHT = 20
local BTN_WIDTH = 400
local BTN_HEIGHT = 20
local BTN_X = LBL_X + LBL_WIDTH + 5
local BIG_BTN_WIDTH = 565
local BIG_BTN_HEIGHT = 30

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

--! Midi port list in format expected by UIDropdown
--!param app (App)
local function midi_port_options(app)
  local ports = app.audio:getMidiPortList()

  local res = {{ text = _S.audio_window.default_midi_port }}
  for _, p in ipairs(ports) do
    res[#res + 1] = { text = p, value = p }
  end

  return res
end

--! Construct new UISoundSettings window
--!param ui (UI) The game ui
--!param mode (string) 'menu' or 'game', depending on whether the window is
--  displayed from the main menu or in game.
function UISoundSettings:UISoundSettings(ui, mode)
  self:UIResizable(ui, 605, 295, col_bg)

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
    self.volume_options[#self.volume_options + 1] = {
      text = _S.menu_options_volume[i],
      volume = i / 100
    }
  end

  self.midi_api_options = { { text = _S.audio_window.default_midi_port, value = nil } }
  for _, api in ipairs(app.audio:getMidiApiList()) do
    self.midi_api_options[#self.midi_api_options + 1] = { text = api, value = api }
  end

  self.midi_port_options = midi_port_options(app)

  local y = 10

  -- Title
  self:addBevelPanel(200, y, 245, 20, col_caption):setLabel(_S.audio_window.caption)
      .lowered = true

  y = y + 30

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

  local music_volume_label_text = app.config.play_music and
      _S.menu_options_volume[app.config.music_volume * 100] or
      _S.customise_window.option_off
  self:addBevelPanel(LBL_X, y, LBL_WIDTH, LBL_HEIGHT, col_shadow, col_bg, col_bg)
      :setLabel(_S.audio_window.music_volume)
      :setTooltip(_S.tooltip.audio_window.music_volume).lowered = true
  self.music_volume_panel = self:addBevelPanel(BTN_X, y, BTN_WIDTH, BTN_HEIGHT, col_bg)
      :setLabel(music_volume_label_text)
  self.music_volume_button = self.music_volume_panel
      :makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.dropdownVolume)
      :setTooltip(_S.tooltip.audio_window.music_volume)

  y = y + 25

  local midi_api_label = app.config.midi_api or _S.audio_window.default_midi_api
  self:addBevelPanel(LBL_X, y, LBL_WIDTH, LBL_HEIGHT, col_shadow, col_bg, col_bg)
      :setLabel(_S.audio_window.midi_api)
      :setTooltip(_S.tooltip.audio_window.midi_api).lowered = true
  self.midi_api_panel = self:addBevelPanel(BTN_X, y, BTN_WIDTH, BTN_HEIGHT, col_bg)
      :setLabel(midi_api_label)
  self.midi_api_button = self.midi_api_panel
      :makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.dropdownMidiApi)
      :setTooltip(_S.tooltip.audio_window.midi_api)

  y = y + 25

  -- Location of soundfont file (only for default api)
  local soundfont_label_panel = self:addBevelPanel(LBL_X, y, LBL_WIDTH, LBL_HEIGHT, col_shadow, col_bg, col_bg)
  soundfont_label_panel
      :setLabel(_S.audio_window.soundfont)
      :setTooltip(_S.tooltip.audio_window.soundfont_location)
      :setVisible(not app.config.midi_api)
  soundfont_label_panel.lowered = true
  local tooltip_soundfont = app.config.soundfont and
      _S.tooltip.audio_window.browse_soundfont:format(app.config.soundfont) or
      _S.tooltip.audio_window.no_soundfont_specified
  local soundfont_button_panel = self:addBevelPanel(BTN_X, y, BTN_WIDTH, BTN_HEIGHT, col_bg)
  soundfont_button_panel
      :setLabel(app.config.soundfont and app.config.soundfont or tooltip_soundfont)
      :setAutoClip(true)
      :setVisible(not app.config.midi_api)
  local soundfont_button = soundfont_button_panel
      :makeButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.buttonBrowseForSoundfont)
      :setTooltip(tooltip_soundfont)
      :setVisible(not app.config.midi_api)
      :enable(not app.config.midi_api)

  -- midi port (only for non-default api)
  local midi_port_label_text = app.config.midi_port or _S.audio_window.default_midi_port
  local midi_port_label_panel = self:addBevelPanel(LBL_X, y, LBL_WIDTH, LBL_HEIGHT, col_shadow, col_bg, col_bg)
  midi_port_label_panel
      :setLabel(_S.audio_window.midi_port)
      :setTooltip(_S.tooltip.audio_window.midi_port)
      :setVisible(not not app.config.midi_api)
  midi_port_label_panel.lowered = true

  self.midi_port_panel = self:addBevelPanel(BTN_X, y, BTN_WIDTH, BTN_HEIGHT, col_bg)
      :setLabel(midi_port_label_text)
      :setVisible(not not app.config.midi_api)
  self.midi_port_button = self.midi_port_panel
      :makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.dropdownMidiPort)
      :setTooltip(_S.tooltip.audio_window.midi_port)
      :setVisible(not not app.config.midi_api)
      :enable(not not app.config.midi_api)

  self.default_api_panels = { soundfont_label_panel, soundfont_button_panel, soundfont_button }
  self.midi_api_panels = { midi_port_label_panel, self.midi_port_panel, self.midi_port_button }

  -- jukebox
  self:addBevelPanel(20, 220, BIG_BTN_WIDTH, BIG_BTN_HEIGHT, col_bg)
      :setLabel(_S.audio_window.jukebox)
      :makeButton(0, 0, BIG_BTN_WIDTH, BIG_BTN_HEIGHT, nil, self.buttonJukebox)
      :setTooltip(_S.tooltip.audio_window.jukebox)

  -- back
  self:addBevelPanel(20, 255, BIG_BTN_WIDTH, BIG_BTN_HEIGHT, col_bg)
      :setLabel(_S.audio_window.back)
      :makeButton(0, 0, BIG_BTN_WIDTH, BIG_BTN_HEIGHT, nil, self.buttonBack)
      :setTooltip(_S.tooltip.audio_window.back)
end

--! Reinitialize the game audio
-- Allows all the changed audio settings to take effect by shutting down the
-- game audio and starting it up again.
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

--! Close any UIDropdown that may be open
function UISoundSettings:closeAllDropdowns()
  self:dropdownVolume(false)
  self:dropdownMidiApi(false)
  self:dropdownMidiPort(false)
end

--! Click action for the global audio toggle
-- Turns all game audio off or on.
function UISoundSettings:buttonAudioGlobal()
  local app = self.ui.app
  app.config.audio = not app.config.audio
  app:saveConfig()
  self.onoff_button:setLabel(app.config.audio and _S.customise_window.option_on or _S.customise_window.option_off)
  self:reinitAudio()
end

--! Click action for any of the audio buttons
-- Displays a drop down of volume options.
--!param activate (bool) true when the control is is activated, false when
--  deactivated
--!param btn (UIButton) the button clicked to fire this event
function UISoundSettings:dropdownVolume(activate, btn)
  if activate then
    self:closeAllDropdowns()
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

--! Click action for midi api button
-- Shows a drop down list of MIDI API options that are supported by the
-- current build.
--!param activate true when the control is is activated, false when deactivated
function UISoundSettings:dropdownMidiApi(activate)
  if activate then
    self:closeAllDropdowns()
    self.midi_api_button:setToggleState(true)

    self.midi_api_dropdown = UIDropdown(self.ui, self, self.midi_api_button, self.midi_api_options, self.selectMidiApi)
    self:addWindow(self.midi_api_dropdown)
  else
    self.midi_api_button:setToggleState(false)
    if self.midi_api_dropdown then
      self.midi_api_dropdown:close()
      self.midi_api_dropdown = nil
    end
  end
end

--! Click action for the midi port button
-- Shows a drop down list of the MIDI ports available for the selected API.
--!param activate true when the control is is activated, false when deactivated
function UISoundSettings:dropdownMidiPort(activate)
  if activate then
    self:closeAllDropdowns()
    self.midi_port_button:setToggleState(true)

    self.midi_port_dropdown = UIDropdown(self.ui, self, self.midi_port_button, self.midi_port_options, self.selectMidiPort)
    self:addWindow(self.midi_port_dropdown)
  else
    self.midi_port_button:setToggleState(false)
    if self.midi_port_dropdown then
      self.midi_port_dropdown:close()
      self.midi_port_dropdown = nil
    end
  end
end

--! Triggered when a sound volume option is selected from the dropdown
-- Sets the sound volume or turns sound off in the config.
--!param index (number) the index of the option selected
function UISoundSettings:selectSoundVolume(index)
  local vol = self.volume_options[index].volume
  if vol == 0 then
    self.app.audio:playSoundEffects(false)
  else
    self.app.audio:playSoundEffects(true)
    self.app.audio:setSoundVolume(vol)
  end
  self.sound_volume_panel:setLabel(self.volume_options[index].text)
  self.app:saveConfig()
end

--! Triggered when an announcement volume option is selected from the dropdown
-- Sets the announcement volume or turns announcements off in the config.
--!param index (number) the index of the option selected
function UISoundSettings:selectAnnouncementVolume(index)
  local vol = self.volume_options[index].volume
  if vol == 0 then
    self.app.config.play_announcements = false
  else
    self.app.config.play_announcements = true
    self.app.audio:setAnnouncementVolume(vol)
  end
  self.announcement_volume_panel:setLabel(self.volume_options[index].text)
  self.app:saveConfig()
end

--! Triggered when a music volume option is selected from the dropdown
-- Sets the music volume or turns announcements off in the config.
--!param index (number) the index of the option selected
function UISoundSettings:selectMusicVolume(index)
  local vol = self.volume_options[index].volume
  if vol == 0 then
    self.app.config.play_music = false
    self.app.audio:stopBackgroundTrack()
  else
    self.app.audio:setBackgroundVolume(vol)
    if not self.app.config.play_music then
      self.app.config.play_music = true
      self.app.audio:playRandomBackgroundTrack()
    end
  end
  self.music_volume_panel:setLabel(self.volume_options[index].text)
  self.app:saveConfig()
end

--! Triggered when a MIDI API is selected from the dropdown
-- Sets the MIDI API in the config and resets the MIDI port selection,
-- since the MIDI port is specific to the selected API.
--!param index (number) the index of the option selected
function UISoundSettings:selectMidiApi(index)
  local value = self.midi_api_options[index].value

  self.app.config.midi_api = value
  self.app.config.midi_port = nil
  self.app:saveConfig()

  self:reinitAudio()
  self.midi_port_button:setLabel(_S.audio_window.default_midi_port)
  self.midi_port_options = midi_port_options(self.app)

  for _, p in ipairs(self.default_api_panels) do
    p:setVisible(not value)
    if p.enable then
      p:enable(not value)
    end
  end
  for _, p in ipairs(self.midi_api_panels) do
    p:setVisible(not not value)
    if p.enable then
      p:enable(not not value)
    end
  end
end

--! Triggered when a MIDI port is selected from the dropdown
-- Sets the MIDI port and resets the audio.
--!param index (number) the index of the option selected
function UISoundSettings:selectMidiPort(index)
  local value = self.midi_port_options[index].value
  self.app.config.midi_port = value
  self.app:saveConfig()
  self:reinitAudio()
end

--! Button handler for soundfont
-- Opens a file chooser dialog for selecting a soundfont.
function UISoundSettings:buttonBrowseForSoundfont()
  local browser = UIChooseSoundfont(self.ui, self.mode, self, self.selectSoundfont)
  self.ui:addWindow(browser)
end

--! Callback when a soundfont is chosen
-- Saves the soundfont and reinitializes audio.
function UISoundSettings:selectSoundfont(name)
  self.app.config.soundfont = name
  self.app:saveConfig()
  self:reinitAudio()
end

--! Callback for Jukebox button
-- Opens the jukebox window.
function UISoundSettings:buttonJukebox()
  if self.app.config.audio then
    self.ui:addWindow(UIJukebox(self.app))
  end
end

--! Callback for back button
-- Opens the UIOptions window again.
function UISoundSettings:buttonBack()
  self:close()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

--! Close window
function UISoundSettings:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end
