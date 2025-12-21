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

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
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

-- Private functions

--- Calculates the Y position for the dialog box in the option menu
-- and increments along the current position for the next element
-- @return The Y position to place the element at
--!param reset (boolean) Reset the index to start at the top of a column, below the title.
function UIOptions:_getOptionYPos(reset)
  if reset then self._current_option_index = 2 end
  -- Offset from top of options box
  local STARTING_Y_POS = 15
  -- Y Height is 20 for panel size + 10 for spacing
  local Y_HEIGHT = 30

  -- Multiply by the index so that index=1 is at STARTING_Y_POS
  local calculated_pos = STARTING_Y_POS + Y_HEIGHT * (self._current_option_index - 1)
  self._current_option_index = self._current_option_index + 1
  return calculated_pos
end


function UIOptions:UIOptions(ui, mode)
  self:UIResizable(ui, 620, 300, col_bg)

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
    {text = "1440x900 (16:10)",  width = 1440, height = 900},
    {text = "1680x1050 (16:10)",  width = 1680, height = 1050},
    {text = "1920x1200 (16:10)", width = 1920, height = 1200},
    {text = _S.options_window.custom_resolution, custom = true},
  }

  self.available_ui_scales = {
    {text = "100%", scale = 1},
    {text = "200%", scale = 2},
    {text = "300%", scale = 3},
  }

  -- Window parts definition
  -- Title
  local title_y_pos = self:_getOptionYPos()
  self:addBevelPanel(175, title_y_pos, BTN_WIDTH * 2, 20, col_caption):setLabel(_S.options_window.caption)
    .lowered = true

  if app:isUpdateCheckAvailable() then
    -- Check for updates
    local updates_y_pos = self:_getOptionYPos()
    local updates_string = app.config.check_for_updates and
        _S.options_window.option_enabled or _S.options_window.option_disabled
    self:addBevelPanel(20, updates_y_pos, BTN_WIDTH, BTN_HEIGHT, col_shadow, col_bg, col_bg)
        :setLabel(_S.options_window.check_for_updates):setTooltip(_S.tooltip.options_window.check_for_updates).lowered = true
    self.updates_panel =
        self:addBevelPanel(165, updates_y_pos, BTN_WIDTH, BTN_HEIGHT, col_bg):setLabel(updates_string)
    self.updates_button = self.updates_panel:makeToggleButton(0, 0, 140, BTN_HEIGHT, nil, self.buttonUpdates)
        :setToggleState(app.config.check_for_updates)
  end

  -- Fullscreen
  local fullscreen_y_pos = self:_getOptionYPos()
  self:addBevelPanel(20, fullscreen_y_pos, BTN_WIDTH, BTN_HEIGHT, col_shadow, col_bg, col_bg)
    :setLabel(_S.options_window.fullscreen):setTooltip(_S.tooltip.options_window.fullscreen).lowered = true
  self.fullscreen_panel =
    self:addBevelPanel(165, fullscreen_y_pos, BTN_WIDTH, BTN_HEIGHT, col_bg):setLabel(app.fullscreen and _S.options_window.option_on or _S.options_window.option_off)
  self.fullscreen_button = self.fullscreen_panel:makeToggleButton(0, 0, 140, BTN_HEIGHT, nil, self.buttonFullscreen)
    :setToggleState(app.fullscreen):setTooltip(_S.tooltip.options_window.fullscreen_button)

  -- Screen resolution
  local screen_res_y_pos = self:_getOptionYPos()
  self:addBevelPanel(20, screen_res_y_pos, BTN_WIDTH, BTN_HEIGHT, col_shadow, col_bg, col_bg)
    :setLabel(_S.options_window.resolution):setTooltip(_S.tooltip.options_window.resolution).lowered = true
  self.resolution_panel = self:addBevelPanel(165, screen_res_y_pos, BTN_WIDTH, BTN_HEIGHT, col_bg):setLabel(app.config.width .. "x" .. app.config.height)

  self.resolution_button = self.resolution_panel:makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.dropdownResolution):setTooltip(_S.tooltip.options_window.select_resolution)

  local scale_ui_y_pos = self:_getOptionYPos()
  local scale_label = TheApp.config.ui_scale * 100 .. "%"
  self:addBevelPanel(20, scale_ui_y_pos, BTN_WIDTH, BTN_HEIGHT, col_shadow, col_bg, col_bg)
      :setLabel(_S.options_window.scale_ui):setTooltip(_S.tooltip.options_window.scale_ui).lowered = true
  self.scale_ui_panel = self:addBevelPanel(165, scale_ui_y_pos, BTN_WIDTH, BTN_HEIGHT, col_bg):setLabel(scale_label)

  self.scale_ui_button = self.scale_ui_panel:makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.dropdownUIScale):setTooltip(_S.tooltip.options_window.select_ui_scale)

  -- Mouse capture
  local capture_mouse_y_pos = self:_getOptionYPos()
  self:addBevelPanel(20, capture_mouse_y_pos, BTN_WIDTH, BTN_HEIGHT, col_shadow, col_bg, col_bg)
    :setLabel(_S.options_window.capture_mouse):setTooltip(_S.tooltip.options_window.capture_mouse).lowered = true

  self.mouse_capture_panel =
    self:addBevelPanel(165, capture_mouse_y_pos, BTN_WIDTH, BTN_HEIGHT, col_bg):setLabel(app.config.capture_mouse and _S.options_window.option_on or _S.options_window.option_off)

  self.mouse_capture_button = self.mouse_capture_panel:makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.buttonMouseCapture)
    :setToggleState(app.config.capture_mouse):setTooltip(_S.tooltip.options_window.capture_mouse)

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
  -- Language setting.
  local lang_y_pos = self:_getOptionYPos(true)
  self:addBevelPanel(320, lang_y_pos, BTN_WIDTH, BTN_HEIGHT, col_shadow, col_bg, col_bg)
    :setLabel(_S.options_window.language):setTooltip(_S.tooltip.options_window.language).lowered = true
  self.language_panel = self:addBevelPanel(465, lang_y_pos, BTN_WIDTH, BTN_HEIGHT, col_bg):setLabel(lang)
  self.language_button = self.language_panel:makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.dropdownLanguage):setTooltip(_S.tooltip.options_window.select_language)


  -- Set scroll speed.
  local scroll_y_pos = self:_getOptionYPos()
  self:addBevelPanel(320, scroll_y_pos, BTN_WIDTH, BTN_HEIGHT, col_shadow, col_bg, col_bg) : setLabel(_S.options_window.scrollspeed):setTooltip(_S.tooltip.options_window.scrollspeed).lowered = true
  self.scrollspeed_panel = self:addBevelPanel(465, scroll_y_pos, BTN_WIDTH, BTN_HEIGHT, col_bg):setLabel(tostring(self.ui.app.config.scroll_speed))
  self.scrollspeed_button = self.scrollspeed_panel : makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.buttonScrollSpeed) : setTooltip(_S.tooltip.options_window.scrollspeed)

  -- Set shift scroll speed.
  local shiftscroll_y_pos = self:_getOptionYPos()
  self:addBevelPanel(320, shiftscroll_y_pos, BTN_WIDTH, BTN_HEIGHT, col_shadow, col_bg, col_bg) : setLabel(_S.options_window.shift_scrollspeed):setTooltip(_S.tooltip.options_window.shift_scrollspeed).lowered = true
  self.shift_scrollspeed_panel = self:addBevelPanel(465, shiftscroll_y_pos, BTN_WIDTH, BTN_HEIGHT, col_bg):setLabel( tostring(self.ui.app.config.shift_scroll_speed) )
  self.shift_scrollspeed_button = self.shift_scrollspeed_panel : makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.buttonShiftScrollSpeed) : setTooltip(_S.tooltip.options_window.shift_scrollspeed)

  -- Set zoom speed.
  local zoom_y_pos = self:_getOptionYPos()
  self:addBevelPanel(320, zoom_y_pos, BTN_WIDTH, BTN_HEIGHT, col_shadow, col_bg, col_bg) : setLabel(_S.options_window.zoom_speed):setTooltip(_S.tooltip.options_window.zoom_speed).lowered = true
  self.zoomspeed_panel = self:addBevelPanel(465, zoom_y_pos, BTN_WIDTH, BTN_HEIGHT, col_bg):setLabel( tostring(self.ui.app.config.zoom_speed) )
  self.zoomspeed_button = self.zoomspeed_panel : makeToggleButton(0, 0, BTN_WIDTH, BTN_HEIGHT, nil, self.buttonZoomSpeed) : setTooltip(_S.tooltip.options_window.zoom_speed)

  -- The right row is currently uneven with the left row, add an additional spacer
  -- to avoid an overlap.
  self:_getOptionYPos()

  local lower_row_y_pos = self:_getOptionYPos()
  -- "Customise" button
  self:addBevelPanel(20, lower_row_y_pos, BTN_WIDTH, 30, col_bg):setLabel(_S.options_window.customise)
    :makeButton(0, 0, BTN_WIDTH, 30, nil, self.buttonCustomise):setTooltip(_S.tooltip.options_window.customise_button)

  -- "Folders" button
  self:addBevelPanel(165, lower_row_y_pos, BTN_WIDTH, 30, col_bg):setLabel(_S.options_window.folder)
    :makeButton(0, 0, BTN_WIDTH, 30, nil, self.buttonFolder):setTooltip(_S.tooltip.options_window.folder_button)

  -- "Hotkeys" button
  self:addBevelPanel(320, lower_row_y_pos, BTN_WIDTH, 30, col_bg):setLabel(_S.options_window.hotkey)
    :makeButton(0, 0, BTN_WIDTH, 30, nil, self.buttonHotkey):setTooltip(_S.tooltip.options_window.hotkey)

  -- "Sound Options" button
  self:addBevelPanel(465, lower_row_y_pos, BTN_WIDTH, 30, col_bg):setLabel(_S.options_window.sound)
    :makeButton(0, 0, BTN_WIDTH, 30, nil, self.buttonSound):setTooltip(_S.tooltip.options_window.sound)

  -- "Back" button
  -- Give some extra space to back button. This is fine as long as it is the last button in the options menu
  local back_button_y_pos = self:_getOptionYPos() + 20
  self:addBevelPanel(175, back_button_y_pos, BTN_WIDTH * 2, 40, col_bg):setLabel(_S.options_window.back)
    :makeButton(0, 0, 280, 40, nil, self.buttonBack):setTooltip(_S.tooltip.options_window.back)
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
  local lang = self.app.strings.languages_english[self.available_languages[number].name]
  local app = self.ui.app
  app.config.language = (lang)
  app:initLanguage()
  app:saveConfig()
end

function UIOptions:dropdownResolution(activate)
  if activate then
    self:dropdownLanguage(false)
    self:dropdownUIScale(false)
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

function UIOptions:dropdownUIScale(activate)
  if activate then
    self:dropdownLanguage(false)
    self:dropdownResolution(false)
    self.scale_ui_dropdown = UIDropdown(self.ui, self, self.scale_ui_button, self.available_ui_scales, self.selectUIScale)
    self:addWindow(self.scale_ui_dropdown)
  else
    self.scale_ui_button:setToggleState(false)
    if self.scale_ui_dropdown then
      self.scale_ui_dropdown:close()
      self.scale_ui_dropdown = nil
    end
  end
end

function UIOptions:selectUIScale(number)
  local res = self.available_ui_scales[number]
  TheApp.config.ui_scale = res.scale
  TheApp:saveConfig()
  self.scale_ui_panel:setLabel(res.text)
  self.ui:onChangeResolution()
  TheApp.gfx:onChangeUIScale()
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

--! Closes the resolution dialog
--!param ok (boolean or nil) whether the resolution entry was confirmed (true) or aborted (false)
function UIResolution:close(ok)
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
  self:UIResizable(ui, 200, 140, col_bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.scrollspeed_temp = 2

  self.callback = callback

  self:addBevelPanel(20, 10, 160, 20, col_caption):setLabel(_S.options_window.scrollspeed).lowered = true

  self:addBevelPanel(20, 50, 90, 20, col_shadow, col_bg, col_bg):setLabel(_S.options_window.scrollspeed)
  --
  self.scrollspeed_textbox = self:addBevelPanel(110, 50, 70, 20, col_textbox, col_highlight, col_shadow)
    :setTooltip(_S.tooltip.options_window.scrollspeed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(self.ui.app.config.scroll_speed))

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col_bg):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.options_window.apply_scrollspeed)
  self:addBevelPanel(100, 90, 80, 40, col_bg):setLabel(_S.options_window.cancel)
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

--!param ok (boolean or nil) whether the resolution entry was confirmed (true) or aborted (false)
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
  self:UIResizable(ui, 200, 140, col_bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.shift_scrollspeed_temp = 4

  self.callback = callback

  self:addBevelPanel(20, 10, 160, 20, col_caption):setLabel(_S.options_window.shift_scrollspeed).lowered = true

  self:addBevelPanel(20, 50, 120, 20, col_shadow, col_bg, col_bg):setLabel(_S.options_window.shift_scrollspeed)
  --
  self.shift_scrollspeed_textbox = self:addBevelPanel(140, 50, 40, 20, col_textbox, col_highlight, col_shadow)
    :setTooltip(_S.tooltip.options_window.shift_scrollspeed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(self.ui.app.config.shift_scroll_speed))

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col_bg):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.options_window.apply_shift_scrollspeed)
  self:addBevelPanel(100, 90, 80, 40, col_bg):setLabel(_S.options_window.cancel)
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

--!param ok (boolean or nil) whether the resolution entry was confirmed (true) or aborted (false)
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
  self:UIResizable(ui, 200, 140, col_bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.zoomspeed_temp = 80

  self.callback = callback

  --
  self:addBevelPanel(20, 10, 160, 20, col_caption):setLabel(_S.options_window.zoom_speed).lowered = true

  --
  self:addBevelPanel(20, 50, 90, 20, col_shadow, col_bg, col_bg):setLabel(_S.options_window.zoom_speed)

  --
  self.zoomspeed_textbox = self:addBevelPanel(110, 50, 70, 20, col_textbox, col_highlight, col_shadow)
    :setTooltip(_S.tooltip.options_window.zoom_speed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText( tostring(self.ui.app.config.zoom_speed) )

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col_bg):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.options_window.apply_zoomspeed)
  self:addBevelPanel(100, 90, 80, 40, col_bg):setLabel(_S.options_window.cancel)
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

--!param ok (boolean or nil) whether the resolution entry was confirmed (true) or aborted (false)
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
