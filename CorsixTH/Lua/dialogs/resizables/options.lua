--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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

--! Options window used in the main menu and ingame.
class "UIOptions" (UIResizable)

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

local col_button = {
  red = 84,
  green = 200,
  blue = 84,
}

local col_textbox = {
  red = 0,
  green = 0,
  blue = 0,
}

local col_highlight = {
  red = 174,
  green = 166,
  blue = 218,
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

function UIOptions:UIOptions(ui, mode)
  self:UIResizable(ui, 320, 240, col_bg)

  local app = ui.app
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  self.app = app

  self:checkForAvailableLanguages()

  -- Set up list of resolutions
  self.available_resolutions = {
    {text = "640x480 (4:3)",    width = 640,  height = 480},
    {text = "800x600 (4:3)",    width = 800,  height = 600},
    {text = "1024x768 (4:3)",   width = 1024, height = 768},
    {text = "1280x960 (4:3)",   width = 1280, height = 960},
    {text = "1600x1200 (4:3)",  width = 1600, height = 1200},
    {text = "1280x1024 (5:4)",  width = 1280, height = 1024},
    {text = "1280x720 (16:9)",  width = 1280, height = 720},
    {text = "1366x768 (16:9)",  width = 1366, height = 768},
    {text = "1600x900 (16:9)",  width = 1600, height = 900},
    {text = "1920x1080 (16:9)", width = 1920, height = 1080},
    {text = "1280x800 (16:10)",  width = 1280, height = 800},
    {text = "1680x1050 (16:10)",  width = 1680, height = 1050},
    {text = "1920x1200 (16:10)", width = 1920, height = 1200},
    {text = _S.options_window.custom_resolution, custom = true},
  }

  -- Window parts definition
  -- Title
  self:addBevelPanel(80, 10, 165, 20, col_caption):setLabel(_S.options_window.caption)
    .lowered = true

  -- Fullscreen
  self:addBevelPanel(20, 45, 135, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.options_window.fullscreen):setTooltip(_S.tooltip.options_window.fullscreen).lowered = true
  self.fullscreen_panel =
    self:addBevelPanel(165, 45, 135, 20, col_bg):setLabel(app.fullscreen and _S.options_window.option_on or _S.options_window.option_off)
  self.fullscreen_button = self.fullscreen_panel:makeToggleButton(0, 0, 140, 20, nil, self.buttonFullscreen)
    :setToggleState(app.fullscreen):setTooltip(_S.tooltip.options_window.fullscreen_button)

  -- Screen resolution
  self:addBevelPanel(20, 70, 135, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.options_window.resolution):setTooltip(_S.tooltip.options_window.resolution).lowered = true

  self.resolution_panel = self:addBevelPanel(165, 70, 135, 20, col_bg):setLabel(app.config.width .. "x" .. app.config.height)
  self.resolution_button = self.resolution_panel:makeToggleButton(0, 0, 135, 20, nil, self.dropdownResolution):setTooltip(_S.tooltip.options_window.select_resolution)

  -- Language
  local lang = string.upper(app.config.language)
  self:addBevelPanel(20, 95, 135, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.options_window.language):setTooltip(_S.tooltip.options_window.language).lowered = true
  self.language_panel = self:addBevelPanel(165, 95, 135, 20, col_bg):setLabel(lang)
  self.language_button = self.language_panel:makeToggleButton(0, 0, 135, 20, nil, self.dropdownLanguage):setTooltip(_S.tooltip.options_window.select_language)

  -- add the Audio global switch.
  self:addBevelPanel(20, 120, 135, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.options_window.audio):setTooltip(_S.tooltip.options_window.audio_button).lowered = true
  self.volume_panel =
    self:addBevelPanel(165, 120, 135, 20, col_bg):setLabel(app.config.audio and _S.customise_window.option_on or _S.customise_window.option_off)
  self.volume_button = self.volume_panel:makeToggleButton(0, 0, 135, 20, nil, self.buttonAudioGlobal)
    :setToggleState(app.config.audio):setTooltip(_S.tooltip.options_window.audio_toggle)

  -- "Customise" button
  self:addBevelPanel(20, 150, 135, 30, col_bg):setLabel(_S.options_window.customise)
    :makeButton(0, 0, 135, 30, nil, self.buttonCustomise):setTooltip(_S.tooltip.options_window.customise_button)

  -- "Folders" button
  self:addBevelPanel(165, 150, 135, 30, col_bg):setLabel(_S.options_window.folder)
    :makeButton(0, 0, 135, 30, nil, self.buttonFolder):setTooltip(_S.tooltip.options_window.folder_button)


  -- "Back" button
  self:addBevelPanel(20, 190, 280, 40, col_bg):setLabel(_S.options_window.back)
    :makeButton(0, 0, 280, 40, nil, self.buttonBack):setTooltip(_S.tooltip.options_window.back)
end

-- Stubs for backward compatibility
local --[[persistable:options_window_language_button]] function language_button() end
local --[[persistable:options_width_textbox_reset]] function width_textbox_reset() end
local --[[persistable:options_height_textbox_reset]] function height_textbox_reset() end

function UIOptions:checkForAvailableLanguages()
  local app = self.app
  -- Set up list of available languages
  local langs = {}
  for _, lang in ipairs(app.strings.languages) do
    local font = app.strings:getFont(lang)
    if app.gfx:hasLanguageFont(font) then
      font = font and app.gfx:loadLanguageFont(font, app.gfx:loadSpriteTable("QData", "Font01V"))
      langs[#langs + 1] = {text = lang, font = font, tooltip = _S.tooltip.options_window.language_dropdown_item:format(lang)}
    end
  end
  self.available_languages = langs
end

function UIOptions:dropdownLanguage(activate)
  if activate then
    self:dropdownResolution(false)
    self.language_dropdown = UIDropdown(self.ui, self, self.language_button, self.available_languages, self.selectLanguage)
    self:addWindow(self.language_dropdown)
  else
    self.language_button:setToggleState(false)
    if self.language_dropdown then
      self.language_dropdown:close()
      self.language_dropdown = nil
    end
  end
end

function UIOptions:selectLanguage(number)
  local app = self.ui.app
  app.config.language = (self.available_languages[number].text)
  app:initLanguage()
  app:saveConfig()
end

function UIOptions:dropdownResolution(activate)
  if activate then
    self:dropdownLanguage(false)
    self.resolution_dropdown = UIDropdown(self.ui, self, self.resolution_button, self.available_resolutions, self.selectResolution)
    self:addWindow(self.resolution_dropdown)
  else
    self.resolution_button:setToggleState(false)
    if self.resolution_dropdown then
      self.resolution_dropdown:close()
      self.resolution_dropdown = nil
    end
  end
end

function UIOptions:selectResolution(number)
  local res = self.available_resolutions[number]

  local callback = --[[persistable:options_resolution_callback]] function(width, height)
    if not self.ui:changeResolution(width, height) then
      local err = {_S.errors.unavailable_screen_size}
      self.ui:addWindow(UIInformation(self.ui, err))
    end
    self.resolution_panel:setLabel(self.ui.app.config.width .. "x" .. self.ui.app.config.height)
  end

  if res.custom then
    self.resolution_panel:setLabel(self.ui.app.config.width .. "x" .. self.ui.app.config.height)
    self.ui:addWindow(UIResolution(self.ui, callback))
  else
    callback(res.width, res.height)
  end
end

function UIOptions:buttonFullscreen(checked)
  if not self.ui:toggleFullscreen() then
      local err = {_S.errors.unavailable_screen_size}
      self.ui:addWindow(UIInformation(self.ui, err))
      self.fullscreen_button:toggle()
  end
  self.fullscreen_panel:setLabel(self.ui.app.fullscreen and _S.options_window.option_on or _S.options_window.option_off)
end


function UIOptions:buttonCustomise()
  local window = UICustomise(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonFolder()
  local window = UIFolder(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonBrowseForTHInstall()
  local function callback(path)
    local app = TheApp
    app.config.theme_hospital_install = path
    app:saveConfig()
    debug.getregistry()._RESTART = true
    app.running = false
  end
  local browser = UIDirectoryBrowser(self.ui, self.mode, _S.options_window.new_th_directory, "InstallDirTreeNode", callback)
  self.ui:addWindow(browser)
end

function UIOptions:buttonAudioGlobal(checked)
  local app = self.ui.app
  app.config.audio = not app.config.audio
  app:saveConfig()
  self.volume_button:setLabel(app.config.audio and _S.customise_window.option_on or _S.customise_window.option_off)
  -- Reinit audio
  app.audio:stopBackgroundTrack()
  app.audio.has_bg_music = false
  app.audio.not_loaded = not app.config.audio
  app.audio.speech_file_name = nil
  app.audio:init()
  app:initLanguage()
end

function UIOptions:buttonBack()
  self:close()
end

function UIOptions:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end

--! A custom resolution selection window
class "UIResolution" (UIResizable)

function UIResolution:UIResolution(ui, callback)
  self:UIResizable(ui, 200, 140, col_bg)

  local app = ui.app
  self.modal_class = "resolution"
  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"

  self.callback = callback

  -- Window parts definition
  -- Title
  self:addBevelPanel(20, 10, 160, 20, col_caption):setLabel(_S.options_window.resolution)
    .lowered = true

  -- Textboxes
  self:addBevelPanel(20, 40, 80, 20, col_shadow, col_bg, col_bg):setLabel(_S.options_window.width)
  self.width_textbox = self:addBevelPanel(100, 40, 80, 20, col_textbox, col_highlight, col_shadow)
    :setTooltip(_S.tooltip.options_window.width)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(app.config.width))

  self:addBevelPanel(20, 60, 80, 20, col_shadow, col_bg, col_bg):setLabel(_S.options_window.height)
  self.height_textbox = self:addBevelPanel(100, 60, 80, 20, col_textbox, col_highlight, col_shadow)
    :setTooltip(_S.tooltip.options_window.height)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(app.config.height))

  -- Apply and cancel
  self:addBevelPanel(20, 90, 80, 40, col_bg):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.options_window.apply)
  self:addBevelPanel(100, 90, 80, 40, col_bg):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.options_window.cancel)
end

function UIResolution:cancel()
  self:close(false)
end

function UIResolution:ok()
  local width, height = tonumber(self.width_textbox.text) or 0, tonumber(self.height_textbox.text) or 0
  if width < 640 or height < 480 then
    local err = {_S.errors.minimum_screen_size}
    self.ui:addWindow(UIInformation(self.ui, err))
  elseif width > 3000 or height > 2000 then
    self.ui:addWindow(UIConfirmDialog(self.ui,
      _S.confirmation.maximum_screen_size,
      --[[persistable:maximum_screen_size_confirm_dialog]]function()
      self:close(true)
      self:close(false)
      end
      ))
  else
    self:close(true)
  end
end

--! Closes the resolution dialog
--!param ok (boolean or nil) whether the resolution entry was confirmed (true) or aborted (false)
function UIResolution:close(ok)
  UIResizable.close(self)
  if ok and self.callback then
    self.callback(tonumber(self.width_textbox.text) or 0, tonumber(self.height_textbox.text) or 0)
  end
end
