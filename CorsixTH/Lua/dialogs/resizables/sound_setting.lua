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

local UIDropdown = cth_require("dialogs.resizables.dropdown")
local UIResizable = cth_require("dialogs.resizable")

class "UISoundSettings" (UIResizable)

---@class UISoundSettings: UIResizable
---@operator call: UISoundSettings
local UISoundSettings = _G["UISoundSettings"] ---@type UISoundSettings

local col = {
   bg = Colours.PanelDefault,
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
  self:UIResizable(ui, 605, 295, col.bg)

  local app = ui.app
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options" or "folders"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.app = ui.app
  self.label_width = 160
  self.btn_width = 400
  self.strings_ref = "audio_window"
  self.custom_back_button = true
  self.extra_height = 100

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

  self.entry_list = {
    { name = "audio", func = self.buttonAudioGlobal },
    { name = "sound_volume", func = self.dropdownVolume, raised = true },
    { name = "announcement_volume", func = self.dropdownVolume, raised = true },
    { name = "music_volume", func = self.dropdownVolume, raised = true },
    { name = "play_own_music", func = self.playOwnMusic },
    { name = "midi_api", func = self.dropdownMidiApi,
        default_string = "default_midi_port", raised = true },
    { name = "soundfont", func = self.buttonBrowseForSoundfont,
        default_string = "no_soundfont_specified", raised = true, unicode = true },
    { name = "midi_port", func = self.dropdownMidiPort, raised = true },
  }

  self:buildDialog()
  local y_pos = self:_getOptionYPos()
  local btn_width = (self.label_width + self.btn_width) / 2
  local x_pos, x_pos2 = self.margin, self.margin + btn_width + 5
  -- Jukebox
  self:addBevelPanel(x_pos, y_pos, btn_width, self.big_button_height, col.bg)
      :setLabel(_S.audio_window.jukebox)
      :makeButton(0, 0, btn_width, self.big_button_height, nil, self.buttonJukebox)
      :setTooltip(_S.tooltip.audio_window.jukebox)

  -- Back button at custom level below jukebox
  self:addBevelPanel(x_pos2, y_pos, btn_width, self.big_button_height, col.bg)
      :setLabel(_S.audio_window.back)
      :makeButton(0, 0, btn_width, self.big_button_height, nil, self.buttonBack)
      :setTooltip(_S.tooltip.audio_window.back)

  -- Post dialog build
  -- Set volume displays
  local function set_display_value(boolean, number) self.buttons[number]:setLabel(app.config[boolean] and
  _S.menu_options_volume[app.config[number] * 100] or _S.customise_window.option_off) end
  set_display_value("play_sounds", "sound_volume")
  set_display_value("play_announcements", "announcement_volume")
  set_display_value("play_music", "music_volume")

  -- Adjust buttons for own music, soundfont and port
  self.buttons.play_own_music:enable(app.config.audio_music)
  if not app.config.audio_music then
    self.buttons.play_own_music:setTooltip(_S.tooltip.audio_window.play_own_music_no_folder_set)
  end
  self.buttons.soundfont:enable(not app.config.midi_api)
  self.buttons.midi_port:enable(not not app.config.midi_api)
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
  self.buttons.audio:setLabel(app.config.audio and _S.customise_window.option_on or _S.customise_window.option_off)
  app.audio:reinitAudioSystem()
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
    if btn == self.buttons.sound_volume then
      select_callback = self.selectSoundVolume
    elseif btn == self.buttons.announcement_volume then
      select_callback = self.selectAnnouncementVolume
    elseif btn == self.buttons.music_volume then
      select_callback = self.selectMusicVolume
    end

    self.volume_dropdown = UIDropdown(self.ui, self, btn, self.volume_options,
      select_callback, Colours.SettingActive, Colours.Scrollbar)
    self:addWindow(self.volume_dropdown)
  else
    self.buttons.sound_volume:setToggleState(false)
    self.buttons.announcement_volume:setToggleState(false)
    self.buttons.music_volume:setToggleState(false)
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
  if activate and not self.midi_api_dropdown then
    self:closeAllDropdowns()
    self.buttons.midi_api:setToggleState(true)

    self.midi_api_dropdown = UIDropdown(self.ui, self, self.buttons.midi_api,
      self.midi_api_options, self.selectMidiApi, Colours.SettingActive, Colours.Scrollbar)
    self:addWindow(self.midi_api_dropdown)
  else
    self.buttons.midi_api:setToggleState(false)
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
  if activate and not self.midi_port_dropdown then
    self:closeAllDropdowns()
    self.buttons.midi_port:setToggleState(true)

    self.midi_port_dropdown = UIDropdown(self.ui, self, self.buttons.midi_port,
      self.midi_port_options, self.selectMidiPort, Colours.SettingActive, Colours.Scrollbar)
    self:addWindow(self.midi_port_dropdown)
  else
    self.buttons.midi_port:setToggleState(false)
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
  self.buttons.sound_volume:setLabel(self.volume_options[index].text)
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
  self.buttons.announcement_volume:setLabel(self.volume_options[index].text)
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
  self.buttons.music_volume:setLabel(self.volume_options[index].text)
  self.app:saveConfig()
end

--! Button function to switch between own music and TH97's
function UISoundSettings:playOwnMusic()
  local app = self.ui.app
  app.config.play_own_music = not app.config.play_own_music
  app:saveConfig()
  self.buttons.play_own_music:setLabel(app.config.play_own_music and
      _S.customise_window.option_on or
      _S.customise_window.option_off)
    :setTooltip(_S.tooltip.audio_window.play_own_music)
  -- Reload audio system to start playing updated music choice
  app.audio:reinitAudioSystem()
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

  self.app.audio:reinitAudioSystem()
  self.buttons.midi_port:setLabel(_S.audio_window.default_midi_port)
  self.midi_port_options = midi_port_options(self.app)
  self.buttons.soundfont:enable(not value)
  self.buttons.midi_port:enable(not not value)
end

--! Triggered when a MIDI port is selected from the dropdown
-- Sets the MIDI port and resets the audio.
--!param index (number) the index of the option selected
function UISoundSettings:selectMidiPort(index)
  local value = self.midi_port_options[index].value
  self.app.config.midi_port = value
  self.app:saveConfig()
  self.app.audio:reinitAudioSystem()
end

--! Button handler for soundfont
-- Opens a file chooser dialog for selecting a soundfont.
function UISoundSettings:buttonBrowseForSoundfont()
  local UIChooseSoundfont = cth_require("dialogs.resizables.file_browsers.choose_soundfont")
  local browser = UIChooseSoundfont(self.ui, self.mode, self, self.selectSoundfont)
  self.ui:addWindow(browser)
end

--! Callback when a soundfont is chosen
-- Saves the soundfont and reinitializes audio.
function UISoundSettings:selectSoundfont(name)
  self.app.config.soundfont = name
  self.app:saveConfig()
  self.app.audio:reinitAudioSystem()
end

--! Callback for Jukebox button
-- Opens the jukebox window.
function UISoundSettings:buttonJukebox()
  if self.app.config.audio then
    local UIJukebox = cth_require("dialogs.jukebox")
    self.ui:addWindow(UIJukebox(self.app))
  end
end

--! Close window
function UISoundSettings:close()
  UIResizable.close(self)
  local UIOptions = cth_require("dialogs.resizables.options")
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

return UISoundSettings
