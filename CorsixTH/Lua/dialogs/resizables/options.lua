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
  self:UIResizable(ui, 320, 220, col_bg)

  local app = ui.app
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  
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
  
  -- Window parts definition
  -- Title
  self:addBevelPanel(80, 10, 160, 20, col_caption):setLabel(_S.options_window.caption)
    .lowered = true
  
  -- Fullscreen
  self:addBevelPanel(20, 50, 140, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.options_window.fullscreen):setTooltip(_S.tooltip.options_window.fullscreen).lowered = true
  self.fullscreen_panel =
    self:addBevelPanel(160, 50, 140, 20, col_bg):setLabel(app.fullscreen and _S.options_window.option_on or _S.options_window.option_off)
  self.fullscreen_button = self.fullscreen_panel:makeToggleButton(0, 0, 140, 20, nil, self.buttonFullscreen)
    :setToggleState(app.fullscreen):setTooltip(_S.tooltip.options_window.fullscreen_button)
  
  -- Screen resolution
  self:addBevelPanel(20, 70, 140, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.options_window.resolution):setTooltip(_S.tooltip.options_window.resolution).lowered = true
  local --[[persistable:options_width_textbox_reset]] function width_textbox_reset()
    if self.width_textbox.text == "" then
      self.width_textbox.panel:setLabel(_S.options_window.width)
    end
  end
  local --[[persistable:options_height_textbox_reset]] function height_textbox_reset()
    if self.height_textbox.text == "" then
      self.height_textbox.panel:setLabel(_S.options_window.height)
    end
  end
  self.width_textbox = self:addBevelPanel(160, 70, 40, 20, col_textbox, col_highlight, col_shadow)
    :setLabel(_S.options_window.width, nil, "left"):setTooltip(_S.tooltip.options_window.width)
    :makeTextbox(width_textbox_reset, width_textbox_reset):allowedInput("numbers"):characterLimit(4)
  self.height_textbox = self:addBevelPanel(200, 70, 40, 20, col_textbox, col_highlight, col_shadow)
    :setLabel(_S.options_window.height, nil, "left"):setTooltip(_S.tooltip.options_window.height)
    :makeTextbox(height_textbox_reset, height_textbox_reset):allowedInput("numbers"):characterLimit(4)
  self:addBevelPanel(240, 70, 60, 20, col_bg):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 60, 20, nil, self.buttonResolution):setTooltip(_S.tooltip.options_window.apply)

  -- Language
  self:addBevelPanel(20, 90, 140, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.options_window.language):setTooltip(_S.tooltip.options_window.language).lowered = true
  self.language_panel = self:addBevelPanel(160, 90, 140, 20, col_bg):setLabel(app.config.language)
  self.language_button = self.language_panel:makeToggleButton(0, 0, 140, 20, nil, self.dropdownLanguage):setTooltip(_S.tooltip.options_window.select_language)
  
  -- Location of original game
  local built_in = app.gfx:loadBuiltinFont()
  self:addBevelPanel(20, 110, 140, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.options_window.data_location):setTooltip(_S.tooltip.options_window.data_location)
    .lowered = true
  self:addBevelPanel(160, 110, 140, 20, col_bg)
    :setLabel(app.config.theme_hospital_install, built_in)
    :makeButton(0, 0, 140, 20, nil, self.buttonBrowse):setTooltip(_S.tooltip.options_window.browse)
  
  -- "Back" button
  self:addBevelPanel(20, 160, 280, 40, col_bg):setLabel(_S.options_window.back)
    :makeButton(0, 0, 280, 40, nil, self.buttonBack):setTooltip(_S.tooltip.options_window.back)
end

local --[[persistable:options_window_language_button]] function stub() end

function UIOptions:dropdownLanguage(activate)
  if activate then
    self.language_dropdown = UIDropdown(self.ui, self, self.language_button, self.available_languages, self.selectLanguage)
    self:addWindow(self.language_dropdown)
  else
    if self.language_dropdown then
      self.language_dropdown:close()
      self.language_dropdown = nil
    end
  end
end

function UIOptions:selectLanguage(number)
  local app = self.ui.app
  app.config.language = self.available_languages[number].text
  app:initLanguage()
  app:saveConfig()
  self.language_panel:setLabel(app.config.language)
  self.language_button:setToggleState(false)
end

function UIOptions:buttonFullscreen(checked)
  if not self.ui:toggleFullscreen() then
      local err = {_S.errors.unavailable_screen_size}
      self.ui:addWindow(UIInformation(self.ui, err))
      self.fullscreen_button:toggle()
  end
  self.fullscreen_panel:setLabel(self.ui.app.fullscreen and _S.options_window.option_on or _S.options_window.option_off)
end

function UIOptions:buttonResolution()
  local width, height = tonumber(self.width_textbox.text) or 0, tonumber(self.height_textbox.text) or 0
  if width < 640 or height < 480 then
    local err = {_S.errors.minimum_screen_size}
    self.ui:addWindow(UIInformation(self.ui, err))
  elseif width > 3000 or height > 2000 then
    local err = {_S.errors.maximum_screen_size}
    self.ui:addWindow(UIInformation(self.ui, err))
  else
    if not self.ui:changeResolution(width, height) then
      local err = {_S.errors.unavailable_screen_size}
      self.ui:addWindow(UIInformation(self.ui, err)) 
    end
  end
end

function UIOptions:buttonBrowse()
  local browser = UIInstallDirBrowser(self.ui, self.mode)
  self.ui:addWindow(browser)
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
