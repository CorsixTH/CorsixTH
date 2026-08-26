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

-- Constants for most button's width and height
local BTN_WIDTH = 135
local BTN_HEIGHT = 20

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

-- Private functions

--- Calculates the Y position for the dialog box in the option menu
-- and increments along the current position for the next element
-- @return The Y position to place the element at
function UIOptions:_getOptionYPos()
  -- Offset from top of options box
  local STARTING_Y_POS = 15
  -- Y Height is 20 for panel size + 10 for spacing
  local Y_HEIGHT = 30

  -- Multiply by the index so that index=1 is at STARTING_Y_POS
  local calculated_pos = STARTING_Y_POS + Y_HEIGHT * (self._current_option_index - 1)
  self._current_option_index = self._current_option_index + 1
  return calculated_pos
end

--! Resets the index to start at the top of a new column, below the title,
-- for the Y position calculation.
function UIOptions:_startNewColumn()
  self._current_option_index = 2
  self.column_count = self.column_count + 1
end

-- Generate predefined window sizes the player can choose from; as well as
-- including the custom option at the bottom. Where UI scaling prevents a
-- window size option from being selected, grey it out instead and move to
-- the bottom of the list.
local available_window_sizes = function()
  local suggested_window_sizes = {
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

  local enable_list, disable_list = {}, {}
  local max_window_width, max_window_height = TheApp.video:getMaxWindowSize()

  -- It is possible that getMaxWindowSize could fail to detect the actual
  -- available display space, in which case it will return 0, 0.
  -- In that case we don't have any information to hide a window size from the
  -- user, so set the maximum to large enough values that nothing in the list
  -- will be disabled. The numbers below are arbitrarily large.
  if max_window_width == 0 or max_window_height == 0 then
    max_window_width = 4000
    max_window_height = 3000
  end

  for _, opt in ipairs(suggested_window_sizes) do
    local enabled = opt.width <= max_window_width and opt.height <= max_window_height
    opt.disabled = not enabled
    opt.tooltip = opt.disabled and { _S.tooltip.options_window.window_size_does_not_fit }
    if enabled then
      enable_list[#enable_list + 1] = opt
    else
      disable_list[#disable_list + 1] = opt
    end
  end

  local res = enable_list
  -- Show custom button before disabled items
  res[#res + 1] = {
    text = _S.options_window.custom_window_size, custom = true
  }

  for i = 1, #disable_list do
    res[#res + 1] = disable_list[i]
  end

  return res
end

local available_ui_scales = function()
  local res = {}
  res[1] = { text = _S.options_window.scale_auto, scale = 0 }
  for s = 1, 4 do
    res[#res + 1] = { text = tostring(s * 100) .. '%', scale = s }
  end
  return res
end

local available_cursor_scales = function()
  local res = {}
  res[1] = { text = _S.options_window.scale_auto, scale = 0 }
  for s = 1, 4 do
    res[#res + 1] = { text = tostring(s * 100) .. '%', scale = s }
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
  local height = 360
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

  -- Tracks the current position of the object
  self._current_option_index = 1
  self.column_count = 1

  self:checkForAvailableLanguages()

  -- Window parts definition
  -- Title
  local title_y_pos = self:_getOptionYPos()
  self:addBevelPanel(175, title_y_pos, BTN_WIDTH * 2, 20, col.title):setLabel(_S.options_window.caption)
    .lowered = true

  -- Create our setting items. This create a caption/label for the setting
  -- and the setting itself. We return both elements of the setting (panel
  -- and the button made from the panel)
  local function createOptionsElement(option_label, option_tooltip,
      setting_label, setting_tooltip, setting_colours, callback,
      toggle_state)
    local y_pos = self:_getOptionYPos()
    local x_offset = 300 * (self.column_count - 1)
    local label_x, setting_x = 20 + x_offset, 165 + x_offset

    -- Make the setting name panel
    self:addBevelPanel(label_x, y_pos, BTN_WIDTH, BTN_HEIGHT, col.caption, col.bg, col.bg)
      :setLabel(option_label)
      :setTooltip(option_tooltip)
      .lowered = true
    local s_col = setting_colours
    -- Make the setting value panel
    local setting_panel = self:addBevelPanel(setting_x, y_pos, BTN_WIDTH,
        BTN_HEIGHT, s_col.bg, s_col.highlight, s_col.shadow,
        s_col.disabled, s_col.active)
      :setLabel(setting_label)
      :setTooltip(setting_tooltip)
    -- Make the value panel a button
    local setting_button = setting_panel:makeToggleButton(0, 0, BTN_WIDTH,
        BTN_HEIGHT, nil, callback)
      :setToggleState(toggle_state)
    -- Return the setting value info
    return setting_panel, setting_button
  end

  if app:isUpdateCheckAvailable() then
    -- Check for updates
    local updates_string = app.config.check_for_updates and
        _S.options_window.option_enabled or _S.options_window.option_disabled
    self.updates_panel, self.updates_button = createOptionsElement(
        _S.options_window.check_for_updates, _S.tooltip.options_window.check_for_updates,
        updates_string, nil, { bg = col.setting },
        self.buttonUpdates, app.config.check_for_updates)
  end

  -- Fullscreen
  local fullscreen_label = app.modes.fullscreen and _S.options_window.option_on
    or _S.options_window.option_off
  self.fullscreen_panel, self.fullscreen_button = createOptionsElement(
      _S.options_window.fullscreen, _S.tooltip.options_window.fullscreen,
      fullscreen_label, _S.tooltip.options_window.fullscreen_button, { bg = col.setting },
      self.buttonFullscreen, app.modes.fullscreen)


  -- Window size
  -- We will set the button label after making up the UI scale option below
  self.window_size_panel, self.window_size_button = createOptionsElement(
      _S.options_window.window_size, _S.tooltip.options_window.window_size,
      "", _S.tooltip.options_window.select_window_size,
      { bg = col.setting, active = col.setting_active },
      self.dropdownWindowSize, false)
  self.window_size_button:enable(not app.modes.fullscreen)

  -- UI Scale
  local scale_label = TheApp.config.ui_scale == 0 and
      _S.options_window.scale_auto or TheApp.config.ui_scale * 100 .. "%"
  self.scale_ui_panel, self.scale_ui_button = createOptionsElement(
      _S.options_window.scale_ui, _S.tooltip.options_window.scale_ui,
      scale_label, nil,
      { bg = col.setting, active = col.setting_active },
      self.dropdownUIScale, false)

  -- Cursor Scale
  scale_label = TheApp.config.cursor_scale == 0 and
      _S.options_window.scale_auto or TheApp.config.cursor_scale * 100 .. "%"
  self.cursor_scale_panel, self.cursor_scale_button = createOptionsElement(
      _S.options_window.cursor_scale, _S.tooltip.options_window.cursor_scale,
      scale_label, nil,
      { bg = col.setting, active = col.setting_active },
      self.dropdownCursorScale, false)

  -- Now set the window_size button label and the ui scale button state
  self:_processWindowResizeEvent()

  local aspect_label = app.config.original_aspect_ratio and
          _S.options_window.option_on or _S.options_window.option_off
  self.aspect_panel, self.aspect_button = createOptionsElement(
          _S.options_window.original_aspect_ratio, _S.tooltip.options_window.original_aspect_ratio,
          aspect_label, _S.tooltip.options_window.original_aspect_ratio, { bg = col.setting },
          self.buttonOriginalAspectRatio, app.config.original_aspect_ratio)

  -- Start a new column of buttons
  self:_startNewColumn()

  -- Mouse capture
  local capture_label = app.config.capture_mouse and
      _S.options_window.option_on or _S.options_window.option_off
  self.mouse_capture_panel, self.mouse_capture_button = createOptionsElement(
      _S.options_window.capture_mouse, _S.tooltip.options_window.capture_mouse,
      capture_label, _S.tooltip.options_window.capture_mouse, { bg = col.setting },
      self.buttonMouseCapture, app.config.capture_mouse)

  -- Language
  -- Get language name in the language to normalize display.
  -- If it doesn't exist, display the current config option.
  local lang = self.app.strings:getLanguageNames(app.config.language)
  if lang then
    lang = lang[1]
  else
    lang = app.config.language
  end

  -- Language setting.
  self.language_panel, self.language_button = createOptionsElement(
      _S.options_window.language, _S.tooltip.options_window.language,
      lang, _S.tooltip.options_window.select_language,
      { bg = col.setting, active = col.setting_active },
      self.dropdownLanguage, false)


  -- Set scroll speed.
  local cur_scrollspeed = tostring(self.ui.app.config.scroll_speed)
  self.scrollspeed_panel, self.scrollspeed_button = createOptionsElement(
      _S.options_window.scrollspeed, _S.tooltip.options_window.scrollspeed,
      cur_scrollspeed, _S.tooltip.options_window.scrollspeed,
      { bg = col.setting, active = col.setting_active },
      self.buttonScrollSpeed, false)

  -- Set shift scroll speed.
  local cur_shiftscrollspeed = tostring(self.ui.app.config.shift_scroll_speed)
  self.shift_scrollspeed_panel, self.shift_scrollspeed_button = createOptionsElement(
      _S.options_window.shift_scrollspeed, _S.tooltip.options_window.shift_scrollspeed,
      cur_shiftscrollspeed, _S.tooltip.options_window.shift_scrollspeed,
      { bg = col.setting, active = col.setting_active },
      self.buttonShiftScrollSpeed, false)

  -- Set zoom speed.
  local cur_zoomspeed = tostring(self.ui.app.config.zoom_speed)
  self.zoomspeed_panel, self.zoomspeed_button = createOptionsElement(
      _S.options_window.zoom_speed, _S.tooltip.options_window.zoom_speed,
      cur_zoomspeed, _S.tooltip.options_window.zoom_speed,
      { bg = col.setting, active = col.setting_active },
      self.buttonZoomSpeed, false)


  -- Autosave frequency
  local autosave_frequency_label = current_autosave_frequency()
  self.autosave_frequency_panel, self.autosave_frequency_button = createOptionsElement(
      _S.options_window.autosave_frequency, _S.tooltip.options_window.autosave_frequency,
      autosave_frequency_label, _S.tooltip.options_window.autosave_frequency,
      { bg = col.setting, active = col.setting_active },
      self.dropdownAutosaveFrequency, false)


  -- The right row is currently uneven with the left row, add an additional spacer
  -- to avoid an overlap.
  self:_getOptionYPos()

  local lower_row_y_pos = self:_getOptionYPos()
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
    self:dropdownWindowSize(false)
    self:dropdownUIScale(false)
    self:dropdownCursorScale(false)
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

function UIOptions:dropdownWindowSize(activate)
  if activate then
    self.available_window_sizes = available_window_sizes()
    self:dropdownLanguage(false)
    self:dropdownUIScale(false)
    self:dropdownCursorScale(false)
    self:dropdownAutosaveFrequency(false)
    self.window_size_dropdown = UIDropdown(self.ui, self, self.window_size_button, self.available_window_sizes, self.selectWindowSize, col.setting_active, col.scrollbar, col.disabled)
    self:addWindow(self.window_size_dropdown)
  else
    self.window_size_button:setToggleState(false)
    if self.window_size_dropdown then
      self.window_size_dropdown:close()
      self.window_size_dropdown = nil
    end
  end
end

function UIOptions:selectWindowSize(number)
  local res = self.available_window_sizes[number]

  local callback = --[[persistable:options_resolution_callback]] function(width, height)
    self.app.modes.maximized = false
    if not self.ui:changeWindow(width, height) then
      local err = {_S.errors.unavailable_screen_size}
      self.ui:addWindow(UIInformation(self.ui, err))
    end
  end

  if res.custom then
    self.window_size_panel:setLabel(self.ui.app.config.width .. "x" .. self.ui.app.config.height)
    self.ui:addWindow(UIWindowSize(self.ui, callback))
  else
    callback(res.width, res.height)
  end
end

function UIOptions:dropdownUIScale(activate)
  if activate then
    self.available_ui_scales = available_ui_scales()
    self:dropdownLanguage(false)
    self:dropdownWindowSize(false)
    self:dropdownCursorScale(false)
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

function UIOptions:dropdownCursorScale(activate)
  if activate then
    self.available_cursor_scales = available_cursor_scales()
    self:dropdownLanguage(false)
    self:dropdownWindowSize(false)
    self:dropdownUIScale(false)
    self:dropdownAutosaveFrequency(false)
    self.cursor_scale_dropdown = UIDropdown(self.ui, self, self.cursor_scale_button, self.available_cursor_scales, self.selectCursorScale, col.setting_active, col.scrollbar)
    self:addWindow(self.cursor_scale_dropdown)
  else
    self.cursor_scale_button:setToggleState(false)
    if self.cursor_scale_dropdown then
      self.cursor_scale_dropdown:close()
      self.cursor_scale_dropdown = nil
    end
  end
end

-- Check if UI scale scale button should be enabled, and update the tooltip.
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
  TheApp.gfx:onChangeUIScale()
  self.ui:onChangeResolution()
end

function UIOptions:selectCursorScale(number)
  local res = self.available_cursor_scales[number]
  TheApp.config.cursor_scale = res.scale
  TheApp:saveConfig()
  self.cursor_scale_panel:setLabel(res.text)
end

function UIOptions:dropdownAutosaveFrequency(activate)
  if activate then
    self:dropdownLanguage(false)
    self:dropdownWindowSize(false)
    self:dropdownUIScale(false)
    self:dropdownCursorScale(false)
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
  if not self.ui:toggleVideoMode("fullscreen") then
      local err = {_S.errors.unavailable_screen_size}
      self.ui:addWindow(UIInformation(self.ui, err))
      self.fullscreen_button:toggle()
  end
  self.fullscreen_panel:setLabel(self.ui.app.modes.fullscreen and _S.options_window.option_on or _S.options_window.option_off)
  self.window_size_button:enable(not self.ui.app.modes.fullscreen)
end

function UIOptions:buttonOriginalAspectRatio()
  if not self.ui:toggleVideoMode("aspect_ratio_4_3") then
    local err = {_S.errors.unavailable_screen_size}
    self.ui:addWindow(UIInformation(self.ui, err))
    self.aspect_button:toggle()
  end
  self.aspect_panel:setLabel(self.ui.app.modes.aspect_ratio_4_3 and _S.options_window.option_on or _S.options_window.option_off)
  self.ui:onChangeResolution()
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

function UIOptions:buttonScrollSpeed()
  local callback = function(scrollspeed_number)
    self.scrollspeed_panel : setLabel(tostring(scrollspeed_number))
    self.scrollspeed_button : setToggleState(false)
  end

  self.ui:addWindow(UIScrollSpeed(self.ui, callback))
end

function UIOptions:buttonBack()
  self:close()
end

function UIOptions:buttonShiftScrollSpeed()
  local callback = function(shift_scrollspeed_number)
    self.shift_scrollspeed_panel : setLabel( tostring(shift_scrollspeed_number) )
    self.shift_scrollspeed_button : setToggleState(false)
  end

  self.ui:addWindow(UIShiftScrollSpeed(self.ui, callback))
end

function UIOptions:buttonBack()
  self:close()
end

function UIOptions:buttonZoomSpeed()
  local callback = function(zoomspeed_number)
    self.zoomspeed_panel : setLabel( tostring(zoomspeed_number) )
    self.zoomspeed_button : setToggleState(false)
  end

  self.ui:addWindow( UIZoomSpeed(self.ui, callback) )
end

function UIOptions:onChangeWindowSize()
  self:_processWindowResizeEvent()
  self:setDefaultPosition(0.5, 0.25)
end

-- Handle required button changes from a window resize event from the user (via UI
-- or adjusting window boundaries)
function UIOptions:_processWindowResizeEvent()
  self:updateUIScaleAvailabilityState()
  local window_w, window_h = TheApp.video:getWindowSize()
  self.window_size_panel:setLabel(window_w .. "x" .. window_h)
end

function UIOptions:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end

--! A custom window size selection window
class "UIWindowSize" (UIResizable)

---@type UIWindowSize
local UIWindowSize = _G["UIWindowSize"]

function UIWindowSize:UIWindowSize(ui, callback)
  self:UIResizable(ui, 200, 140, col.bg)

  local app = ui.app
  self.modal_class = "window_size"
  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"

  self.callback = callback

  -- Window parts definition
  -- Title
  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.options_window.window_size)
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

function UIWindowSize:cancel()
  self:close(false)
end

function UIWindowSize:ok()
  local width, height = tonumber(self.width_textbox.text) or 0, tonumber(self.height_textbox.text) or 0
  local min_w = App.MIN_WINDOW_WIDTH
  local min_h = App.MIN_WINDOW_HEIGHT
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

function UIWindowSize:onMouseUp(button, x, y)
  if not self:hitTest(x, y) then
    self:close(false)
  end
  UIResizable.onMouseUp(self, button, x, y)
end

--! Closes the window size dialog
--!param ok (boolean or nil) whether the window size entry was confirmed (true) or aborted (false)
function UIWindowSize:close(ok)
  UIResizable.close(self)
  if ok and self.callback then
    self.callback(tonumber(self.width_textbox.text) or 0, tonumber(self.height_textbox.text) or 0)
  end
end

--! A window for setting the scroll speed of the camera.
class "UIScrollSpeed" (UIResizable)

---@type UIScrollSpeed
local UIScrollSpeed = _G["UIScrollSpeed"]

function UIScrollSpeed:UIScrollSpeed(ui, callback)
  self:UIResizable(ui, 200, 140, col.bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.scrollspeed_temp = 2

  self.callback = callback

  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.options_window.scrollspeed).lowered = true

  self:addBevelPanel(20, 50, 90, 20, col.caption, col.bg, col.bg):setLabel(_S.options_window.scrollspeed)
  --
  self.scrollspeed_textbox = self:addBevelPanel(110, 50, 70, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.options_window.scrollspeed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(self.ui.app.config.scroll_speed))

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.options_window.apply_scrollspeed)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.options_window.cancel_scrollspeed)
end

function UIScrollSpeed:ok()
  self.scrollspeed_temp = tonumber(self.scrollspeed_textbox.text) or 2

  if self.scrollspeed_temp < 1 then
    self.scrollspeed_temp = 1
  elseif self.scrollspeed_temp > 10 then
    self.scrollspeed_temp = 10
  end

  self:close(true)
end

function UIScrollSpeed:cancel()
  self:close(false)
end

function UIScrollSpeed:onMouseUp(button, x, y)
  if not self:hitTest(x, y) then
    self:close(false)
  end
  UIResizable.onMouseUp(self, button, x, y)
end

--!param ok (boolean or nil) whether the scroll speed entry was confirmed (true) or aborted (false)
function UIScrollSpeed:close(ok)
  UIResizable.close(self)

  if ok then
    self.scrollspeed_textbox.text = self.scrollspeed_temp or 2
    self.ui.app.config.scroll_speed = self.scrollspeed_textbox.text
    self.callback(self.scrollspeed_textbox.text)
  else
    self.callback(self.ui.app.config.scroll_speed)
  end
end


--! A window for setting the scroll speed of the camera while pressing the SHIFT key..
class "UIShiftScrollSpeed" (UIResizable)

---@type UIShiftScrollSpeed
local UIShiftScrollSpeed = _G["UIShiftScrollSpeed"]

function UIShiftScrollSpeed:UIShiftScrollSpeed(ui, callback)
  self:UIResizable(ui, 200, 140, col.bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.shift_scrollspeed_temp = 4

  self.callback = callback

  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.options_window.shift_scrollspeed).lowered = true

  self:addBevelPanel(20, 50, 120, 20, col.caption, col.bg, col.bg):setLabel(_S.options_window.shift_scrollspeed)
  --
  self.shift_scrollspeed_textbox = self:addBevelPanel(140, 50, 40, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.options_window.shift_scrollspeed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(self.ui.app.config.shift_scroll_speed))

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.options_window.apply_shift_scrollspeed)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.options_window.cancel_shift_scrollspeed)
end

function UIShiftScrollSpeed:ok()
  self.shift_scrollspeed_temp = tonumber(self.shift_scrollspeed_textbox.text) or 4

  if self.shift_scrollspeed_temp < 1 then
    self.shift_scrollspeed_temp = 1
  elseif self.shift_scrollspeed_temp > 10 then
    self.shift_scrollspeed_temp = 10
  end

  self:close(true)
end

function UIShiftScrollSpeed:cancel()
  self:close(false)
end

function UIShiftScrollSpeed:onMouseUp(button, x, y)
  if not self:hitTest(x, y) then
    self:close(false)
  end
  UIResizable.onMouseUp(self, button, x, y)
end

--!param ok (boolean or nil) whether the shift scroll speed was confirmed (true) or aborted (false)
function UIShiftScrollSpeed:close(ok)
  UIResizable.close(self)

  if ok then
    self.shift_scrollspeed_textbox.text = self.shift_scrollspeed_temp or 4
    self.ui.app.config.shift_scroll_speed = self.shift_scrollspeed_textbox.text
    self.callback(self.shift_scrollspeed_textbox.text)
  else
    self.callback(self.ui.app.config.shift_scroll_speed)
  end
end

--! Window to set the zoom speed of the scroll wheel while in-game.
class "UIZoomSpeed" (UIResizable)

---@type UIZoomSpeed
local UIZoomSpeed = _G["UIZoomSpeed"]

function UIZoomSpeed:UIZoomSpeed(ui, callback)
  self:UIResizable(ui, 200, 140, col.bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.zoomspeed_temp = 80

  self.callback = callback

  --
  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.options_window.zoom_speed).lowered = true

  --
  self:addBevelPanel(20, 50, 90, 20, col.caption, col.bg, col.bg):setLabel(_S.options_window.zoom_speed)

  --
  self.zoomspeed_textbox = self:addBevelPanel(110, 50, 70, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.options_window.zoom_speed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText( tostring(self.ui.app.config.zoom_speed) )

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.options_window.apply_zoomspeed)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.options_window.cancel_zoomspeed)
end

function UIZoomSpeed:ok()
  self.zoomspeed_temp = tonumber( self.zoomspeed_textbox.text ) or 80

  if self.zoomspeed_temp < 10 then
    self.zoomspeed_temp = 10
  elseif self.zoomspeed_temp > 1000 then
    self.zoomspeed_temp = 1000
  end

  self:close(true)
end

function UIZoomSpeed:cancel()
  self:close(false)
end

function UIZoomSpeed:onMouseUp(button, x, y)
  if not self:hitTest(x, y) then
    self:close(false)
  end
  UIResizable.onMouseUp(self, button, x, y)
end

--!param ok (boolean or nil) whether the zoom speed entry was confirmed (true) or aborted (false)
function UIZoomSpeed:close(ok)
  UIResizable.close(self)

  if ok then
    self.zoomspeed_textbox.text = self.zoomspeed_temp or 2
    self.ui.app.config.zoom_speed = self.zoomspeed_textbox.text
    self.callback(self.zoomspeed_textbox.text)
  else
    self.callback(self.ui.app.config.zoom_speed)
  end
end
