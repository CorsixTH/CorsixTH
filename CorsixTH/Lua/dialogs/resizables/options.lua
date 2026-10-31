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

local UIResizable = _G['UIResizable'] ---@type UIResizable

--! Options window used in the main menu and ingame.
class "UIOptions" (UIResizable)

---@class UIOptions: UIResizable
---@operator call: UIOptions
local UIOptions = _G["UIOptions"] ---@type UIOptions

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
  self.app = app
  self.strings_ref = "options_window"
  self.custom_back_button = true
  self.extra_height = 250

  -- Tracks the current position of the object
  self._current_option_index = 1
  self.column_count = 1

  self.entry_list = {
    { name = "capture_mouse", func = self.buttonMouseCapture },
    { name = "language", func = self.dropdownLanguage, raised = true },
    { name = "autosave_frequency", func = self.dropdownAutosaveFrequency, raised = true },
  }
  if app:isUpdateCheckAvailable() then
    table.insert(self.entry_list, 1, { name = "check_for_updates", func = self.buttonUpdates })
  end

  self:buildDialog()

  -- Get language name in the language to normalize display.
  -- If it doesn't exist, keep displaying the current config option.
  self:checkForAvailableLanguages()
  local lang = self.app.strings:getLanguageNames(app.config.language)
  if lang then
    self.buttons.language:setLabel(lang[1])
  end

  self.buttons.autosave_frequency:setLabel(current_autosave_frequency())

  local big_button_padding = 5
  local element_spacing = 10
  local nav_buttons = {
    { name = "graphics", func = self.buttonGraphics },
    { name = "customise", func = self.buttonCustomise },
    { name = "folder", func = self.buttonFolder },
    { name = "hotkey", func = self.buttonHotkey },
    { name = "sound", func = self.buttonSound },
    { name = "accessibility", func = self.buttonAccessibility },
    { name = "back", func = self.buttonBack },
  }

  width = self.width
  local nav_y_pos = self:_getOptionYPos() + big_button_padding
  local nav_x_pos = self.margin
  for i, entry in ipairs(nav_buttons) do
    local name, func = entry.name, entry.func

    local btn_width = self.btn_width
    -- If back is the only bottom row button then make it full width
    if i == #nav_buttons and #nav_buttons % 2 == 1 then
      btn_width = btn_width * 2 + element_spacing
    end
    self:addBevelPanel(nav_x_pos, nav_y_pos, btn_width, self.big_button_height, col.button)
      :setLabel(_S[self.strings_ref][name])
      :makeButton(0, 0, btn_width, self.big_button_height, nil, func)
      :setTooltip(_S.tooltip[self.strings_ref][name])

    nav_x_pos = nav_x_pos + self.btn_width + element_spacing
    if nav_x_pos + self.btn_width + self.margin > width then
      nav_x_pos = self.margin
      nav_y_pos = nav_y_pos + self.big_button_height + element_spacing
    end
  end
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
        tooltip = { _S.tooltip.options_window.language_dropdown_item:format(eng_name) }
      }
    else
      langs[#langs + 1] = { text = eng_name, name = lang, font = self.builtin_font, disabled = true,
        tooltip = { _S.tooltip.options_window.language_dropdown_no_font }
      }
    end
  end
  self.available_languages = langs
end

function UIOptions:dropdownLanguage(activate)
  if activate and not self.language_dropdown then
    self:dropdownAutosaveFrequency(false)
    self.language_dropdown = UIDropdown(self.ui, self, self.buttons.language, self.available_languages, self.selectLanguage, col.setting_active, col.scrollbar, col.disabled)
    self:addWindow(self.language_dropdown)
  else
    self.buttons.language:setToggleState(false)
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

function UIOptions:dropdownAutosaveFrequency(activate)
  if activate and not self.autosave_dropdown then
    self:dropdownLanguage(false)
    self.autosave_dropdown = UIDropdown(self.ui, self, self.buttons.autosave_frequency, available_autosave_frequency(), self.selectAutosaveFrequency, col.setting_active, col.scrollbar)
    self:addWindow(self.autosave_dropdown)
  else
    self.buttons.autosave_frequency:setToggleState(false)
    if self.autosave_dropdown then
      self.autosave_dropdown:close()
      self.autosave_dropdown = nil
    end
  end
end

function UIOptions:selectAutosaveFrequency(number)
  local option = available_autosave_frequency()[number]
  self.buttons.autosave_frequency:setLabel(option.text)
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
  self.buttons.check_for_updates:setLabel(new_updates_string)
end

function UIOptions:buttonMouseCapture()
  local app = self.ui.app
  app.config.capture_mouse = not app.config.capture_mouse
  app:saveConfig()
  self.buttons.capture_mouse:setLabel(app.config.capture_mouse and _S.options_window.option_on or _S.options_window.option_off)
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

function UIOptions:buttonGraphics()
  local window = UIGraphicSettings(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonAccessibility()
  local window = UIAccessibility(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIOptions:buttonScrollSpeed()
  local callback = function(scrollspeed_number)
    self.buttons.scroll_speed:setLabel(tostring(scrollspeed_number)):setToggleState(false)
  end

  self.ui:addWindow(UIScrollSpeed(self.ui, callback))
end

function UIOptions:buttonBack()
  self:close()
end

function UIOptions:buttonShiftScrollSpeed()
  local callback = function(shift_scrollspeed_number)
    self.buttons.shift_scroll_speed:setLabel(tostring(shift_scrollspeed_number)):setToggleState(false)
  end

  self.ui:addWindow(UIShiftScrollSpeed(self.ui, callback))
end

function UIOptions:buttonZoomSpeed()
  local callback = function(zoomspeed_number)
    self.buttons.zoom_speed:setLabel(tostring(zoomspeed_number)):setToggleState(false)
  end

  self.ui:addWindow( UIZoomSpeed(self.ui, callback) )
end

function UIOptions:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end
