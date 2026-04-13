--[[ Copyright (c) 2026 Toby "tobylane"

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

--! Accessibility window used in the main menu and ingame.
class "UIAccessibility" (UIResizable)

---@type UIAccessibility
local UIAccessibility = _G["UIAccessibility"]

-- Constants for most button's width and height
local BTN_WIDTH = 135
local BTN_HEIGHT = 20

local col = {
   bg = Colours.PanelDefault,
   setting = Colours.Setting,
   title = Colours.Title,
   caption = Colours.Caption,
   button = Colours.PanelDefault,
   textbox = Colours.Textbox
}

function UIAccessibility:UIAccessibility(ui, mode)
  self:UIResizable(ui, 320, 280, col.bg)

  local app = ui.app
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options" or "accessibility"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  self.app = app

  -- Tracks the current position of the object
  self._current_option_index = 1
  self.column_count = 1

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

  -- Window parts definition
  -- Title
  local title_y_pos = self:_getOptionYPos()
  self:addBevelPanel(75, title_y_pos, 170, 20, col.title):setLabel(_S.accessibility_window.caption)
    .lowered = true

  -- Disable screen shake during earthquakes
  local cur_screen_shake = app.config.enable_screen_shake and _S.accessibility_window.option_on
    or _S.accessibility_window.option_off
  self.screen_shake_panel, self.screen_shake_button = createOptionsElement(
      _S.accessibility_window.enable_screen_shake, _S.tooltip.accessibility_window.enable_screen_shake,
      cur_screen_shake, _S.tooltip.accessibility_window.enable_screen_shake,
      { bg = col.setting, active = col.setting_active },
      self.buttonScreen_shake, app.config.enable_screen_shake)

  -- Enable subtitles
  local cur_subtitle = app.config.enable_announcer_subtitles and _S.accessibility_window.option_on
    or _S.accessibility_window.option_off
  self.subtitles_panel, self.subtitles_button = createOptionsElement(
      _S.accessibility_window.enable_announcer_subtitles, _S.tooltip.accessibility_window.enable_announcer_subtitles,
      cur_subtitle, _S.tooltip.accessibility_window.enable_announcer_subtitles,
      { bg = col.setting, active = col.setting_active },
      self.buttonAnnouncer_subtitles, app.config.enable_announcer_subtitles)

  -- Set volume down as opening casebook
  local cur_volume_casebook = app.config.volume_opens_casebook and _S.accessibility_window.option_on
    or _S.accessibility_window.option_off
  self.volume_casebook_panel, self.volume_casebook_button = createOptionsElement(
      _S.accessibility_window.volume, _S.tooltip.accessibility_window.volume,
      cur_volume_casebook, _S.tooltip.accessibility_window.volume,
      { bg = col.setting, active = col.setting_active },
      self.buttonVolume, app.config.volume_opens_casebook)

  -- Set scroll speed.
  local cur_scrollspeed = tostring(self.ui.app.config.scroll_speed)
  self.scrollspeed_panel, self.scrollspeed_button = createOptionsElement(
      _S.accessibility_window.scrollspeed, _S.tooltip.accessibility_window.scrollspeed,
      cur_scrollspeed, _S.tooltip.accessibility_window.scrollspeed,
      { bg = col.setting, active = col.setting_active },
      self.buttonScrollSpeed, false)

  -- Set shift scroll speed.
  local cur_shiftscrollspeed = tostring(self.ui.app.config.shift_scroll_speed)
  self.shift_scrollspeed_panel, self.shift_scrollspeed_button = createOptionsElement(
      _S.accessibility_window.shift_scrollspeed, _S.tooltip.accessibility_window.shift_scrollspeed,
      cur_shiftscrollspeed, _S.tooltip.accessibility_window.shift_scrollspeed,
      { bg = col.setting, active = col.setting_active },
      self.buttonShiftScrollSpeed, false)

  -- Set zoom speed.
  local cur_zoomspeed = tostring(self.ui.app.config.zoom_speed)
  self.zoomspeed_panel, self.zoomspeed_button = createOptionsElement(
      _S.accessibility_window.zoom_speed, _S.tooltip.accessibility_window.zoom_speed,
      cur_zoomspeed, _S.tooltip.accessibility_window.zoom_speed,
      { bg = col.setting, active = col.setting_active },
      self.buttonZoomSpeed, false)

  -- "Back" button
  local back_button_y_pos = self:_getOptionYPos()
  self:addBevelPanel(15, back_button_y_pos, 290, 40, col.bg):setLabel(_S.accessibility_window.back)
    :makeButton(0, 0, 290, 40, nil, self.buttonBack):setTooltip(_S.tooltip.accessibility_window.back)
end

function UIAccessibility:buttonScreen_shake()
  local app = self.ui.app
  app.config.enable_screen_shake = not app.config.enable_screen_shake
  self.screen_shake_button:toggle()
  self.screen_shake_panel:setLabel(app.config.enable_screen_shake and _S.accessibility_window.option_on or _S.accessibility_window.option_off)
  app:saveConfig()
  self:reload()
end

function UIAccessibility:buttonAnnouncer_subtitles()
  local app = self.ui.app
  app.config.enable_announcer_subtitles = not app.config.enable_announcer_subtitles
  self.subtitles_button:toggle()
  self.subtitles_panel:setLabel(app.config.enable_announcer_subtitles and _S.accessibility_window.option_on or _S.accessibility_window.option_off)
  app:saveConfig()
  self:reload()
end

function UIAccessibility:buttonVolume()
  local app = self.ui.app
  app.config.volume_opens_casebook = not app.config.volume_opens_casebook
  self.volume_casebook_button:toggle()
  self.volume_casebook_panel:setLabel(app.config.volume_opens_casebook and _S.accessibility_window.option_on or _S.accessibility_window.option_off)
  app:saveConfig()
  self:reload()
end

function UIAccessibility:buttonScrollSpeed()
  local callback = function(scrollspeed_number)
    self.scrollspeed_panel : setLabel(tostring(scrollspeed_number))
    self.scrollspeed_button : setToggleState(false)
  end

  self.ui:addWindow(UIScrollSpeed(self.ui, callback))
end

function UIAccessibility:buttonBack()
  self:close()
end

function UIAccessibility:buttonShiftScrollSpeed()
  local callback = function(shift_scrollspeed_number)
    self.shift_scrollspeed_panel : setLabel( tostring(shift_scrollspeed_number) )
    self.shift_scrollspeed_button : setToggleState(false)
  end

  self.ui:addWindow(UIShiftScrollSpeed(self.ui, callback))
end

function UIAccessibility:buttonZoomSpeed()
  local callback = function(zoomspeed_number)
    self.zoomspeed_panel : setLabel( tostring(zoomspeed_number) )
    self.zoomspeed_button : setToggleState(false)
  end

  self.ui:addWindow( UIZoomSpeed(self.ui, callback) )
end

function UIAccessibility:buttonBack()
  self:close()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

-- So that we can see the option has been changed reload the menu
function UIAccessibility:reload()
  local window = UIAccessibility(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIAccessibility:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end

-- Private functions

--- Calculates the Y position for the dialog box in the option menu
-- and increments along the current position for the next element
-- @return The Y position to place the element at
function UIAccessibility:_getOptionYPos()
  -- Offset from top of options box
  local STARTING_Y_POS = 45
  -- Y Height is 20 for panel size + 10 for spacing
  local Y_HEIGHT = 30

  -- Multiply by the index so that index=1 is at STARTING_Y_POS
  local calculated_pos = STARTING_Y_POS + Y_HEIGHT * (self._current_option_index - 1)
  self._current_option_index = self._current_option_index + 1
  return calculated_pos
end

--! Resets the index to start at the top of a new column, below the title,
-- for the Y position calculation.
function UIAccessibility:_startNewColumn()
  self._current_option_index = 2
  self.column_count = self.column_count + 1
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

  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.accessibility_window.scrollspeed).lowered = true

  self:addBevelPanel(20, 50, 90, 20, col.caption, col.bg, col.bg):setLabel(_S.accessibility_window.scrollspeed)
  --
  self.scrollspeed_textbox = self:addBevelPanel(110, 50, 70, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.accessibility_window.scrollspeed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(self.ui.app.config.scroll_speed))

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.accessibility_window.apply_scrollspeed)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.accessibility_window.cancel_scrollspeed)
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
  self:UIResizable(ui, 200, 140, col.bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.shift_scrollspeed_temp = 4

  self.callback = callback

  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.accessibility_window.shift_scrollspeed).lowered = true

  self:addBevelPanel(20, 50, 120, 20, col.caption, col.bg, col.bg):setLabel(_S.accessibility_window.shift_scrollspeed)
  --
  self.shift_scrollspeed_textbox = self:addBevelPanel(140, 50, 40, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.accessibility_window.shift_scrollspeed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText(tostring(self.ui.app.config.shift_scroll_speed))

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.accessibility_window.apply_shift_scrollspeed)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.accessibility_window.cancel_shift_scrollspeed)
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
  self:UIResizable(ui, 200, 140, col.bg)

  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  self.default_button_sound = "selectx.wav"
  self.zoomspeed_temp = 80

  self.callback = callback

  --
  self:addBevelPanel(20, 10, 160, 20, col.title):setLabel(_S.accessibility_window.zoom_speed).lowered = true

  --
  self:addBevelPanel(20, 50, 90, 20, col.caption, col.bg, col.bg):setLabel(_S.accessibility_window.zoom_speed)

  --
  self.zoomspeed_textbox = self:addBevelPanel(110, 50, 70, 20, col.textbox, col.bg, col.bg)
    :setTooltip(_S.tooltip.accessibility_window.zoom_speed)
    :makeTextbox():allowedInput("numbers"):characterLimit(4):setText( tostring(self.ui.app.config.zoom_speed) )

  --Apply and cancel.
  self:addBevelPanel(20, 90, 80, 40, col.button):setLabel(_S.options_window.apply)
    :makeButton(0, 0, 80, 40, nil, self.ok):setTooltip(_S.tooltip.accessibility_window.apply_zoomspeed)
  self:addBevelPanel(100, 90, 80, 40, col.button):setLabel(_S.options_window.cancel)
    :makeButton(0, 0, 80, 40, nil, self.cancel):setTooltip(_S.tooltip.accessibility_window.cancel_zoomspeed)
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
