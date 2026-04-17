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

---@type UIOptions
local UIOptions = _G["UIOptions"]

-- Constants for most button's width
local BTN_WIDTH = 135

-- Colour definitions
local col = {
  bg             = Colours.PanelDefault,
  button         = Colours.PanelDefault,
  setting        = Colours.Setting,
  setting_active = Colours.SettingActive,
  scrollbar      = Colours.Scrollbar,
  disabled       = Colours.Disabled,
  title          = Colours.Title,
  caption        = Colours.Caption,
  textbox        = Colours.Textbox,
}

-- Generate predefined resolutions the player can choose from; as well as
-- including the custom option at the bottom. Where UI scaling prevents a
-- resolution option from being selected, grey it out instead and move to
-- the bottom of the list.
local available_resolutions = function()
  local suggested_resolutions = {
    {text = "640x480 (4:3)",     width = 640,  height = 480  },
    {text = "800x600 (4:3)",     width = 800,  height = 600  },
    {text = "1024x768 (4:3)",    width = 1024, height = 768  },
    {text = "1280x960 (4:3)",    width = 1280, height = 960  },
    {text = "1600x1200 (4:3)",   width = 1600, height = 1200 },
    {text = "1920x1440 (4:3)",   width = 1920, height = 1440 },
    {text = "1280x1024 (5:4)",   width = 1280, height = 1024 },
    {text = "1280x720 (16:9)",   width = 1280, height = 720  },
    {text = "1366x768 (16:9)",   width = 1366, height = 768  },
    {text = "1600x900 (16:9)",   width = 1600, height = 900  },
    {text = "1920x1080 (16:9)",  width = 1920, height = 1080 },
    {text = "2560x1440 (16:9)",  width = 2560, height = 1440 },
    {text = "3840x2160 (16:9)",  width = 3840, height = 2160 },
    {text = "1280x800 (16:10)",  width = 1280, height = 800  },
    {text = "1440x900 (16:10)",  width = 1440, height = 900  },
    {text = "1680x1050 (16:10)", width = 1680, height = 1050 },
    {text = "1920x1200 (16:10)", width = 1920, height = 1200 },
  }

  local s = TheApp.config.ui_scale
  local enable_list, disable_list = {}, {}
  for _, opt in ipairs(suggested_resolutions) do
    local enabled = App.MIN_WINDOW_WIDTH * s <= opt.width and
        App.MIN_WINDOW_HEIGHT * s <= opt.height
    opt.disabled = not enabled
    opt.tooltip = opt.disabled and { _S.tooltip.options_window.resolution_unavailable }
    if enabled then
      enable_list[#enable_list + 1] = opt
    else
      disable_list[#disable_list + 1] = opt
    end
  end

  local res = enable_list
  -- Show custom button before disabled items
  res[#res + 1] = {
    text = _S.options_window.custom_resolution, custom = true
  }

  for i = 1, #disable_list do
    res[#res + 1] = disable_list[i]
  end

  return res
end

local available_ui_scales = function()
  local res = {}
  local s = 1
  while s * App.MIN_WINDOW_WIDTH <= TheApp.config.width and
      s * App.MIN_WINDOW_HEIGHT <= TheApp.config.height do
    res[#res + 1] = { text = tostring(s * 100) .. '%', scale = s }
    s = s + 1
  end
  return res
end

local available_autosave_frequency = function()
  local options = {
    { text = _S.autosave_frequency.monthly, value = 1, tooltip = { _S.tooltip.autosave_frequency.monthly } },
    { text = _S.autosave_frequency.weekly, value = 2, tooltip = { _S.tooltip.autosave_frequency.weekly } },
    { text = _S.autosave_frequency.daily, value = 3, tooltip = { _S.tooltip.autosave_frequency.daily } },
  }
  return options
end

local current_autosave_frequency = function()
  local value = TheApp.config.autosave_frequency
  local options = available_autosave_frequency()
  for _, option in pairs(options) do
    if option.value == value then
      return option.text
    end
  end
  return ""
end

function UIOptions:UIOptions(ui, mode)
  local width = 620
  local height = 300
  self:UIResizable(ui, width, height, col.bg)

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

  -- Window parts definition
  -- Title
  local title_y_pos = self:_getOptionYPos()
  self:addBevelPanel(175, title_y_pos, BTN_WIDTH * 2, 20, col.title):setLabel(_S.options_window.caption)
    .lowered = true

  if app:isUpdateCheckAvailable() then
    -- Check for updates
    local updates_string = app.config.check_for_updates and
        _S.options_window.option_enabled or _S.options_window.option_disabled
    self.updates_panel, self.updates_button = self:createOptionsElement(
        _S.options_window.check_for_updates, _S.tooltip.options_window.check_for_updates,
        updates_string, nil, { bg = col.setting },
        self.buttonUpdates, app.config.check_for_updates)
  end

  -- Fullscreen
  local fullscreen_label = app.fullscreen and _S.options_window.option_on
    or _S.options_window.option_off
  self.fullscreen_panel, self.fullscreen_button = self:createOptionsElement(
      _S.options_window.fullscreen, _S.tooltip.options_window.fullscreen,
      fullscreen_label, _S.tooltip.options_window.fullscreen_button, { bg = col.setting },
      self.buttonFullscreen, app.fullscreen)

  -- Screen resolution
  -- We will set the button label after making up the UI scale option below
  self.resolution_panel, self.resolution_button = self:createOptionsElement(
      _S.options_window.resolution, _S.tooltip.options_window.resolution,
      "", _S.tooltip.options_window.select_resolution,
      { bg = col.setting, active = col.setting_active },
      self.dropdownResolution, false)

  -- UI Scale
  local scale_label = TheApp.config.ui_scale * 100 .. "%"
  self.scale_ui_panel, self.scale_ui_button = self:createOptionsElement(
      _S.options_window.scale_ui, _S.tooltip.options_window.scale_ui,
      scale_label, nil,
      { bg = col.setting, active = col.setting_active },
      self.dropdownUIScale, false)

  -- Now set the resolution button label and the ui scale button state
  self:processWindowResizeEvent()

  -- Language
  -- Get language name in the language to normalize display.
  -- If it doesn't exist, display the current config option.
  local lang = self.app.strings:getLanguageNames(app.config.language)
  if lang then
    lang = lang[1]
  else
    lang = app.config.language
  end

  -- Start a new column of buttons
  self:_startNewColumn()

  -- Language setting.
  self.language_panel, self.language_button = self:createOptionsElement(
      _S.options_window.language, _S.tooltip.options_window.language,
      lang, _S.tooltip.options_window.select_language,
      { bg = col.setting, active = col.setting_active },
      self.dropdownLanguage, false)

  -- Mouse capture
  local capture_label = app.config.capture_mouse and
      _S.options_window.option_on or _S.options_window.option_off
  self.mouse_capture_panel, self.mouse_capture_button = self:createOptionsElement(
      _S.options_window.capture_mouse, _S.tooltip.options_window.capture_mouse,
      capture_label, _S.tooltip.options_window.capture_mouse, { bg = col.setting },
      self.buttonMouseCapture, app.config.capture_mouse)

  -- Autosave frequency
  local autosave_frequency_label = current_autosave_frequency()
  self.autosave_frequency_panel, self.autosave_frequency_button = self:createOptionsElement(
      _S.options_window.autosave_frequency, _S.tooltip.options_window.autosave_frequency,
      autosave_frequency_label, _S.tooltip.options_window.autosave_frequency,
      { bg = col.setting, active = col.setting_active },
      self.dropdownAutosaveFrequency, false)

  -- Odd number of settings, skip a row
  self:_getOptionYPos()

  local upper_row_y_pos = self:_getOptionYPos()
    -- "Accessibility" button
  self:addBevelPanel(20, upper_row_y_pos, BTN_WIDTH, 30, col.button):setLabel(_S.options_window.accessibility)
    :makeButton(0, 0, BTN_WIDTH, 30, nil, self.buttonAccessibility)
    :setTooltip(_S.tooltip.options_window.accessibility_button)


  local lower_row_y_pos = self:_getOptionYPos() + 10
  -- "Customise" button
  self:addBevelPanel(20, lower_row_y_pos, BTN_WIDTH, 30, col.button):setLabel(_S.options_window.customise)
    :makeButton(0, 0, BTN_WIDTH, 30, nil, self.buttonCustomise)
    :setTooltip(_S.tooltip.options_window.customise_button)

  -- "Folders" button
  self:addBevelPanel(165, lower_row_y_pos, BTN_WIDTH, 30, col.button):setLabel(_S.options_window.folder)
    :makeButton(0, 0, BTN_WIDTH, 30, nil, self.buttonFolder)
    :setTooltip(_S.tooltip.options_window.folder_button)

  -- "Hotkeys" button
  self:addBevelPanel(320, lower_row_y_pos, BTN_WIDTH, 30, col.button):setLabel(_S.options_window.hotkey)
    :makeButton(0, 0, BTN_WIDTH, 30, nil, self.buttonHotkey)
    :setTooltip(_S.tooltip.options_window.hotkey)

  -- "Sound Options" button
  self:addBevelPanel(465, lower_row_y_pos, BTN_WIDTH, 30, col.button):setLabel(_S.options_window.sound)
    :makeButton(0, 0, BTN_WIDTH, 30, nil, self.buttonSound)
    :setTooltip(_S.tooltip.options_window.sound)

  -- "Back" button
  -- Give some extra space to back button. This is fine as long as it is the last button in the options menu
  local back_button_y_pos = self:_getOptionYPos() + 20
  self:addBevelPanel(175, back_button_y_pos, BTN_WIDTH * 2, 40, col.button):setLabel(_S.options_window.back)
    :makeButton(0, 0, 280, 40, nil, self.buttonBack)
    :setTooltip(_S.tooltip.options_window.back)
end

-- Stubs for backward compatibility
local --[[persistable:options_window_language_button]] function language_button() end
local --[[persistable:options_width_textbox_reset]] function width_textbox_reset() end
local --[[persistable:options_height_textbox_reset]] function height_textbox_reset() end

function UIOptions:checkForAvailableLanguages()
  local app = self.app
  -- Set up list of available languages
  local langs, c = {}, 1
  for _, lang in pairs(app.strings.languages) do
    local font = app.strings:getFont(lang)
    local eng_name = app.strings.languages_english[lang]
    c = c + 1
    -- If freetype support and a unicode font setting are not present then
    -- languages not supported by the builtin font are named in English and cannot be selected
    if app.gfx:hasLanguageFont(font) then
      font = font and app.gfx:loadLanguageFont(font, app.gfx:loadSpriteTable("QData", "Font01V"), { apply_ui_scale = true })
      langs[#langs + 1] = { text = lang, name = lang, font = font, disabled = false,
      tooltip = { _S.tooltip.options_window.language_dropdown_item:format(eng_name) } }
    else
      langs[#langs + 1] = { text = eng_name, name = lang, font = self.builtin_font, disabled = true,
      tooltip = { _S.tooltip.options_window.language_dropdown_no_font } }
    end
  end
  self.available_languages = langs
end

function UIOptions:dropdownLanguage(activate)
  if activate then
    self:dropdownResolution(false)
    self:dropdownUIScale(false)
    self:dropdownAutosaveFrequency(false)
    self.language_dropdown = UIDropdown(self.ui, self, self.language_button, self.available_languages, self.selectLanguage, col.setting_active, col.scrollbar, col.disabled)
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
  local lang = self.app.strings.languages_english[self.available_languages[number].name]
  local app = self.ui.app
  app.config.language = (lang)
  app:initLanguage()
  app:saveConfig()
end

function UIOptions:dropdownResolution(activate)
  if activate then
    self.available_resolutions = available_resolutions()
    self:dropdownLanguage(false)
    self:dropdownUIScale(false)
    self:dropdownAutosaveFrequency(false)
    self.resolution_dropdown = UIDropdown(self.ui, self, self.resolution_button, self.available_resolutions, self.selectResolution, col.setting_active, col.scrollbar, col.disabled)
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
  end

  if res.custom then
    self.resolution_panel:setLabel(self.ui.app.config.width .. "x" .. self.ui.app.config.height)
    self.ui:addWindow(UIResolution(self.ui, callback))
  else
    callback(res.width, res.height)
  end
end

function UIOptions:dropdownUIScale(activate)
  if activate then
    self.available_ui_scales = available_ui_scales()
    self:dropdownLanguage(false)
    self:dropdownResolution(false)
    self:dropdownAutosaveFrequency(false)
    self.scale_ui_dropdown = UIDropdown(self.ui, self, self.scale_ui_button, self.available_ui_scales, self.selectUIScale, col.setting_active, col.scrollbar)
    self:addWindow(self.scale_ui_dropdown)
  else
    self.scale_ui_button:setToggleState(false)
    if self.scale_ui_dropdown then
      self.scale_ui_dropdown:close()
      self.scale_ui_dropdown = nil
    end
  end
end

-- Check if UI scale button should be enabled, and update the tooltip.
function UIOptions:updateUIScaleAvailabilityState()
  local ui_scales_available = #available_ui_scales() > 1
  self.scale_ui_button:enable(ui_scales_available)
  self.scale_ui_button:setTooltip(ui_scales_available and
      _S.tooltip.options_window.select_ui_scale or
      _S.tooltip.options_window.ui_scale_unavailable)
end

function UIOptions:selectUIScale(number)
  local res = self.available_ui_scales[number]
  TheApp.config.ui_scale = res.scale
  TheApp:saveConfig()
  self.scale_ui_panel:setLabel(res.text)
  self.ui:changeResolution(TheApp.config.width, TheApp.config.height)
  TheApp.gfx:onChangeUIScale()
end

function UIOptions:dropdownAutosaveFrequency(activate)
  if activate then
    self:dropdownLanguage(false)
    self:dropdownResolution(false)
    self:dropdownUIScale(false)
    self.autosave_dropdown = UIDropdown(self.ui, self, self.autosave_frequency_button, available_autosave_frequency(), self.selectAutosaveFrequency, col.setting_active, col.scrollbar)
    self:addWindow(self.autosave_dropdown)
  else
    self.autosave_frequency_button:setToggleState(false)
    if self.autosave_dropdown then
      self.autosave_dropdown:close()
      self.autosave_dropdown = nil
    end
  end
end

function UIOptions:selectAutosaveFrequency(number)
  local option = available_autosave_frequency()[number]
  self.autosave_frequency_panel:setLabel(option.text)
  TheApp.config.autosave_frequency = option.value
  TheApp:saveConfig()
end

--! Changes check for update setting to on/of
function UIOptions:toggleUpdateCheck()
  self.ui.app.config.check_for_updates = not self.ui.app.config.check_for_updates
  self.ui.app:saveConfig()
end

--! Function handles button toggle of checking for updates
function UIOptions:buttonUpdates()
  self:toggleUpdateCheck()
  local new_updates_string = self.ui.app.config.check_for_updates and
      _S.options_window.option_enabled or _S.options_window.option_disabled
  self.updates_panel:setLabel(new_updates_string)
end

function UIOptions:buttonFullscreen()
  if not self.ui:toggleFullscreen() then
      local err = {_S.errors.unavailable_screen_size}
      self.ui:addWindow(UIInformation(self.ui, err))
      self.fullscreen_button:toggle()
  end
  self.fullscreen_panel:setLabel(self.ui.app.fullscreen and _S.options_window.option_on or _S.options_window.option_off)
end

function UIOptions:buttonMouseCapture()
  local app = self.ui.app
  app.config.capture_mouse = not app.config.capture_mouse
  app:saveConfig()
  self.mouse_capture_button:setLabel(app.config.capture_mouse and _S.options_window.option_on or _S.options_window.option_off)
end

function UIOptions:buttonCustomise()
  local window = UICustomise(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonAccessibility()
  local window = UIAccessibility(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonFolder()
  local window = UIFolder(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonHotkey()
  local window = UIHotkeyAssign(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonSound()
  local window = UISoundSettings(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonBack()
  self:close()
end

function UIOptions:onChangeResolution()
  self:processWindowResizeEvent()
  self:setDefaultPosition(0.5, 0.25)
end

-- Handle required button changes from a window resize event from the user (via UI
-- or adjusting window boundaries)
function UIOptions:processWindowResizeEvent()
  self:updateUIScaleAvailabilityState()
  self.resolution_panel:setLabel(self.ui.app.config.width .. "x" ..
      self.ui.app.config.height)
end

function UIOptions:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end

--! A custom resolution selection window
class "UIResolution" (UIResizable)

---@type UIResolution
local UIResolution = _G["UIResolution"]

function UIResolution:UIResolution(ui, callback)
  self:UIResizable(ui, 200, 140, col.bg)

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
  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.options_window.resolution)
    .lowered = true

  -- Textboxes
  self:addBevelPanel(20, 40, 80, 20, col.caption, col.bg, col.bg):setLabel(_S.options_window.width)
  self.width_textbox = self:addBevelPanel(100, 40, 80, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.options_window.width)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(app.config.width))

  self:addBevelPanel(20, 60, 80, 20, col.caption, col.bg, col.bg):setLabel(_S.options_window.height)
  self.height_textbox = self:addBevelPanel(100, 60, 80, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.options_window.height)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(app.config.height))

  -- Apply and cancel
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.options_window.apply)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.options_window.cancel)
end

function UIResolution:cancel()
  self:close(false)
end

function UIResolution:ok()
  local width, height = tonumber(self.width_textbox.text) or 0, tonumber(self.height_textbox.text) or 0
  local s = TheApp.config.ui_scale
  local min_w = App.MIN_WINDOW_WIDTH * s
  local min_h = App.MIN_WINDOW_HEIGHT * s
  if width < min_w or height < min_h then
    local err = {_S.errors.minimum_screen_size:format(min_w, min_h)}
    self.ui:addWindow(UIInformation(self.ui, err))
  elseif width > 3000 or height > 2000 then
    self.ui:addWindow(UIConfirmDialog(self.ui, false,
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

function UIResolution:onMouseUp(button, x, y)
  if not self:hitTest(x, y) then
    self:close(false)
  end
  UIResizable.onMouseUp(self, button, x, y)
end

--! Closes the resolution dialog
--!param ok (boolean or nil) whether the resolution entry was confirmed (true) or aborted (false)
function UIResolution:close(ok)
  UIResizable.close(self)
  if ok and self.callback then
    self.callback(tonumber(self.width_textbox.text) or 0, tonumber(self.height_textbox.text) or 0)
  end
end

