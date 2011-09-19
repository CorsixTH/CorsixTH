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

dofile("dialogs/resizable")

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

function UIOptions:UIOptions(ui, mode)
  self:UIResizable(ui, 320, 240, col_bg)

  local app = ui.app
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  
  -- Window parts definition
  self.default_button_sound = "selectx.wav"
  
  -- Fullscreen
  self.fullscreen_button =
    self:addBevelPanel(20, 20, 20, 20, col_button)
    :makeToggleButton(0, 0, 20, 20, nil, self.buttonFullscreen)
    :setTooltip(_S.tooltip.options_window.fullscreen_button)
  if app.fullscreen then
    self.fullscreen_button:toggle()
  end
  self:addBevelPanel(50, 20, 250, 20, col_bg)
    :setLabel(_S.options_window.fullscreen).lowered = true
  
  -- Screen resolution
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
  self.width_textbox = self:addBevelPanel(20, 50, 50, 20, col_textbox, col_highlight, col_shadow)
    :setLabel(_S.options_window.width, nil, "left"):setTooltip(_S.tooltip.options_window.width)
    :makeTextbox(width_textbox_reset, width_textbox_reset):allowedInput("numbers"):characterLimit(4)
  self.height_textbox = self:addBevelPanel(80, 50, 50, 20, col_textbox, col_highlight, col_shadow)
    :setLabel(_S.options_window.height, nil, "left"):setTooltip(_S.tooltip.options_window.height)
    :makeTextbox(height_textbox_reset, height_textbox_reset):allowedInput("numbers"):characterLimit(4)
  self.resolution_button =
    self:addBevelPanel(140, 50, 160, 20, col_bg):setLabel(_S.options_window.change_resolution)
    :makeButton(0, 0, 160, 20, nil, self.buttonResolution):setTooltip(_S.tooltip.options_window.change_resolution)

  -- Also load the built in font
  local built_in = app.gfx:loadBuiltinFont()
  -- Location of original game
  self:addBevelPanel(20, 80, 280, 20, col_bg)
    :setLabel(app.config.theme_hospital_install, built_in, "left")
    :setTooltip(_S.tooltip.options_window.original_path).lowered = true

  self.browse_button =
    self:addBevelPanel(20, 110, 70, 20, col_bg):setLabel(_S.options_window.browse)
    :makeButton(0, 0, 70, 20, nil, self.buttonBrowse):setTooltip(_S.tooltip.options_window.browse)

  -- Language
  local y = 140
  for _, lang in ipairs(app.strings.languages) do
    local font = app.strings:getFont(lang)
    if app.gfx:hasLanguageFont(font) then
      if font then
        font = app.gfx:loadLanguageFont(font, app.gfx:loadSpriteTable("QData", "Font01V"))
      end
      self:addBevelPanel(20, y, 280, 20, col_bg)
        :setLabel(lang, font)
        :makeButton(0, 0, 280, 20, nil,
          --[[persistable:options_window_language_button]] function()
            app.config.language = lang
            app:initLanguage()
            app:saveConfig()
          end)
        :setTooltip(_S.tooltip.options_window.language:format(lang))
      y = y + 20
    end
  end
  
  -- Adjust size
  y = y + 70
  if y > self.height then
    self:setSize(self.width, y)
  end
  
  -- "Back" button
  self:addBevelPanel(20, self.height - 60, 280, 40, col_bg):setLabel(_S.options_window.back)
    :makeButton(0, 0, 280, 40, nil, self.buttonBack):setTooltip(_S.tooltip.options_window.back)
end

function UIOptions:buttonFullscreen(checked)
  if not self.ui:toggleFullscreen() then
      local err = {_S.errors.unavailable_screen_size}
      self.ui:addWindow(UIInformation(self.ui, err))
      self.fullscreen_button:toggle()
  end
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
  local browser = UIInstallDirBrowser(self.ui, "menu")
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
