--[[ Copyright (c) 2026 Stephen Baker

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

class "UIGraphicSettings" (UIResizable)

---@type UIGraphicSettings
local UIGraphicSettings = _G["UIGraphicSettings"]

local col = {
  bg = Colours.PanelDefault,
  button         = Colours.PanelDefault,
  setting        = Colours.Setting,
  setting_active = Colours.SettingActive,
  scrollbar      = Colours.Scrollbar,
  disabled       = Colours.Disabled,
  title          = Colours.Title,
  caption        = Colours.Caption,
  textbox        = Colours.Textbox,
}

local available_override_resolutions = function()
  return {
    {text = _S.graphics_window.option_off },
    {text = "640x480 (4:3)",     width = 640,  height = 480  },
    {text = "800x600 (4:3)",     width = 800,  height = 600  },
    {text = "720x480 (3:2)",     width = 720,  height = 480  },
    {text = "1280x720 (16:9)",   width = 1280, height = 720  },
  }
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
    opt.tooltip = opt.disabled and { _S.tooltip.graphics_window.window_size_does_not_fit }
    if enabled then
      enable_list[#enable_list + 1] = opt
    else
      disable_list[#disable_list + 1] = opt
    end
  end

  local res = enable_list
  -- Show custom button before disabled items
  res[#res + 1] = {
    text = _S.graphics_window.custom_window_size, custom = true
  }

  for i = 1, #disable_list do
    res[#res + 1] = disable_list[i]
  end

  return res
end

local available_ui_scales = function()
  local res = {}
  res[1] = { text = _S.graphics_window.scale_auto, scale = 0 }
  for s = 1, 4 do
    res[#res + 1] = { text = tostring(s * 100) .. '%', scale = s }
  end
  return res
end

local available_cursor_scales = function()
  local res = {}
  res[1] = { text = _S.graphics_window.scale_auto, scale = 0 }
  for s = 1, 4 do
    res[#res + 1] = { text = tostring(s * 100) .. '%', scale = s }
  end
  return res
end

function UIGraphicSettings:UIGraphicSettings(ui, mode)
  self:UIResizable(ui, 605, 209, col.bg)

  local app = _G['TheApp']

  self.app = app
  self.mode = mode
  self.strings_ref = "graphics_window"

  self.entry_list = {
    { name = "fullscreen", func = self.buttonFullscreen },
    { name = "window_size", func = self.dropdownWindowSize, raised = true },
    { name = "ui_scale", func = self.dropdownUIScale, raised = true },
    { name = "cursor_scale", func = self.dropdownCursorScale, raised = true },
    { name = "original_aspect_ratio", func = self.buttonOriginalAspectRatio, raised = true },
    { name = "override_resolution", func = self.dropdownOverrideResolution, raised = true },
  }

  self:buildDialog()

  -- Post dialog build
  -- Set the window size button and scale labels
  self:_processWindowResizeEvent()
  self.buttons.ui_scale:setLabel(app.config.ui_scale == 0 and
      _S.graphics_window.scale_auto or app.config.ui_scale * 100 .. "%")
  self.buttons.cursor_scale:setLabel(app.config.cursor_scale == 0 and
      _S.graphics_window.scale_auto or app.config.cursor_scale * 100 .. "%")
  self:_processOverrideResolution()
end

function UIGraphicSettings:buttonFullscreen()
  if not self.ui:toggleVideoMode("fullscreen") then
    local err = {_S.errors.unavailable_screen_size}
    self.ui:addWindow(UIInformation(self.ui, err))
    self.buttons.fullscreen:toggle()
  end
  self.buttons.fullscreen:setLabel(self.ui.app.modes.fullscreen and _S.graphics_window.option_on or _S.graphics_window.option_off)
  self.buttons.window_size:enable(not self.ui.app.modes.fullscreen)
end

function UIGraphicSettings:buttonOriginalAspectRatio()
  if not self.ui:toggleVideoMode("aspect_ratio_4_3") then
    local err = {_S.errors.unavailable_screen_size}
    self.ui:addWindow(UIInformation(self.ui, err))
    self.buttons.original_aspect_ratio:toggle()
  end
  self.buttons.original_aspect_ratio:setLabel(self.ui.app.modes.aspect_ratio_4_3 and _S.graphics_window.option_on or _S.graphics_window.option_off)
  self.ui:onChangeResolution()
end

function UIGraphicSettings:dropdownWindowSize(activate)
  if activate and not self.window_size_dropdown then
    self.available_window_sizes = available_window_sizes()
    self:dropdownUIScale(false)
    self:dropdownCursorScale(false)
    self:dropdownOverrideResolution(false)
    self.window_size_dropdown = UIDropdown(self.ui, self, self.buttons.window_size, self.available_window_sizes, self.selectWindowSize, col.setting_active, col.scrollbar, col.disabled)
    self:addWindow(self.window_size_dropdown)
  else
    self.buttons.window_size:setToggleState(false)
    if self.window_size_dropdown then
      self.window_size_dropdown:close()
      self.window_size_dropdown = nil
    end
  end
end

function UIGraphicSettings:selectWindowSize(number)
  local res = self.available_window_sizes[number]

  local callback = --[[persistable:options_resolution_callback]] function(width, height)
    self.app.modes.maximised = false
    if not self.ui:changeWindow(width, height) then
      local err = {_S.errors.unavailable_screen_size}
      self.ui:addWindow(UIInformation(self.ui, err))
    end
  end

  if res.custom then
    self.buttons.window_size:setLabel(self.ui.app.config.width .. "x" .. self.ui.app.config.height)
    self.ui:addWindow(UIWindowSize(self.ui, callback))
  else
    callback(res.width, res.height)
  end
end

function UIGraphicSettings:dropdownUIScale(activate)
  if activate and not self.scale_ui_dropdown then
    self.available_ui_scales = available_ui_scales()
    self:dropdownWindowSize(false)
    self:dropdownCursorScale(false)
    self:dropdownOverrideResolution(false)
    self.scale_ui_dropdown = UIDropdown(self.ui, self, self.buttons.ui_scale, self.available_ui_scales, self.selectUIScale, col.setting_active, col.scrollbar)
    self:addWindow(self.scale_ui_dropdown)
  else
    self.buttons.ui_scale:setToggleState(false)
    if self.scale_ui_dropdown then
      self.scale_ui_dropdown:close()
      self.scale_ui_dropdown = nil
    end
  end
end

function UIGraphicSettings:dropdownCursorScale(activate)
  if activate and not self.cursor_scale_dropdown then
    self.available_cursor_scales = available_cursor_scales()
    self:dropdownWindowSize(false)
    self:dropdownUIScale(false)
    self:dropdownOverrideResolution(false)
    self.cursor_scale_dropdown = UIDropdown(self.ui, self, self.buttons.cursor_scale, self.available_cursor_scales, self.selectCursorScale, col.setting_active, col.scrollbar)
    self:addWindow(self.cursor_scale_dropdown)
  else
    self.buttons.cursor_scale:setToggleState(false)
    if self.cursor_scale_dropdown then
      self.cursor_scale_dropdown:close()
      self.cursor_scale_dropdown = nil
    end
  end
end

-- Check if UI scale scale button should be enabled, and update the tooltip.
function UIGraphicSettings:updateUIScaleAvailabilityState()
  local ui_scales_available = #available_ui_scales() > 1
  self.buttons.ui_scale:enable(ui_scales_available)
  self.buttons.ui_scale:setTooltip(ui_scales_available and
      _S.tooltip.graphics_window.select_ui_scale or
      _S.tooltip.graphics_window.ui_scale_unavailable)
end

function UIGraphicSettings:selectUIScale(number)
  local res = self.available_ui_scales[number]
  TheApp.config.ui_scale = res.scale
  TheApp:saveConfig()
  self.buttons.ui_scale:setLabel(res.text)
  TheApp.gfx:onChangeUIScale()
  self.ui:onChangeResolution()
end

function UIGraphicSettings:selectCursorScale(number)
  local res = self.available_cursor_scales[number]
  TheApp.config.cursor_scale = res.scale
  TheApp:saveConfig()
  self.buttons.cursor_scale:setLabel(res.text)
end

function UIGraphicSettings:dropdownOverrideResolution(activate)
  if activate and not self.override_resolution_dropdown then
    self.override_resolutions = available_override_resolutions()
    self:dropdownWindowSize(false)
    self:dropdownUIScale(false)
    self:dropdownCursorScale(false)
    self.override_resolution_dropdown = UIDropdown(self.ui, self, self.buttons.window_size, self.override_resolutions, self.selectOverrideResolution, col.setting_active, col.scrollbar, col.disabled)
    self:addWindow(self.override_resolution_dropdown)
  else
    self.buttons.override_resolution:setToggleState(false)
    if self.override_resolution_dropdown then
      self.override_resolution_dropdown:close()
      self.override_resolution_dropdown = nil
    end
  end
end

function UIGraphicSettings:selectOverrideResolution(number)
  local res = self.override_resolutions[number]
  local config = TheApp.config

  if res.width then
    config.override_resolution_width = res.width
    config.override_resolution_height = res.height
    self.ui:setVideoMode('override_resolution', true)
  else
    self.ui:setVideoMode('override_resolution', false)
  end
  self.ui:onChangeResolution()
  self:_processOverrideResolution()
end

function UIGraphicSettings:_processOverrideResolution()
  local config = TheApp.config
  self.buttons.override_resolution:setLabel(
        not config.override_resolution and
            _S.graphics_window.option_off or
            config.override_resolution_width .. 'x' .. config.override_resolution_height)

  self.buttons.original_aspect_ratio:enable(not config.override_resolution)
end

function UIGraphicSettings:onChangeResolution()
  self:_processWindowResizeEvent()
  self:setDefaultPosition(0.5, 0.25)
end

-- Handle required button changes from a window resize event from the user (via UI
-- or adjusting window boundaries)
function UIGraphicSettings:_processWindowResizeEvent()
  self:updateUIScaleAvailabilityState()
  local window_w, window_h = TheApp.video:getWindowSize()
  self.buttons.window_size:setLabel(window_w .. "x" .. window_h)
end

--! Callback for back button
-- Opens the UIOptions window again.
function UIGraphicSettings:buttonBack()
  self:close()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
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
  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.graphics_window.window_size)
    .lowered = true

  -- Textboxes
  self:addBevelPanel(20, 40, 80, 20, col.caption, col.bg, col.bg):setLabel(_S.graphics_window.width)
  self.width_textbox = self:addBevelPanel(100, 40, 80, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.graphics_window.width)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(app.config.width))

  self:addBevelPanel(20, 60, 80, 20, col.caption, col.bg, col.bg):setLabel(_S.graphics_window.height)
  self.height_textbox = self:addBevelPanel(100, 60, 80, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.graphics_window.height)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(app.config.height))

  -- Apply and cancel
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.graphics_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.graphics_window.apply)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.graphics_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.graphics_window.cancel)
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

