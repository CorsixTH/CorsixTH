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

local UIResizable = cth_require("dialogs.resizable")

--! Accessibility window used in the main menu and ingame.
class "UIAccessibility" (UIResizable)

---@class UIAccessibility: UIResizable
---@operator call: UIAccessibility
local UIAccessibility = _G["UIAccessibility"] ---@type UIAccessibility

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
  self.strings_ref = "accessibility_window"

  -- Window parts definition
  -- Title
  self.caption_label = _S.accessibility_window.caption

  self.entry_list = {
    -- Disable screen shake during earthquakes
    { name = "enable_screen_shake"},
    -- Enable subtitles
    { name = "enable_announcer_subtitles"},
    -- Set scroll speed.
    { name = "scroll_speed", func = self.buttonScrollSpeed, raised = true},
    -- Set shift scroll speed.
    { name = "shift_scroll_speed", func = self.buttonShiftScrollSpeed, raised = true},
    -- Set zoom speed.
    { name = "zoom_speed", func = self.buttonZoomSpeed, raised = true},
  }

  self:buildDialog()
end

function UIAccessibility:buttonScrollSpeed()
  local callback = function(scrollspeed_number)
    self.labels.scroll_speed:setLabel(tostring(scrollspeed_number))
    self.buttons.scroll_speed:setToggleState(false)
  end

  local UIScrollSpeed = cth_require("dialogs.resizables.scroll_speed")
  self.ui:addWindow(UIScrollSpeed(self.ui, callback))
end

function UIAccessibility:buttonBack()
  self:close()
end

function UIAccessibility:buttonShiftScrollSpeed()
  local callback = function(shift_scrollspeed_number)
    self.labels.shift_scroll_speed:setLabel( tostring(shift_scrollspeed_number) )
    self.buttons.shift_scroll_speed:setToggleState(false)
  end

  local UIShiftScrollSpeed = cth_require("dialogs.resizables.shift_scroll_speed")
  self.ui:addWindow(UIShiftScrollSpeed(self.ui, callback))
end

function UIAccessibility:buttonZoomSpeed()
  local callback = function(zoomspeed_number)
    self.labels.zoom_speed:setLabel( tostring(zoomspeed_number) )
    self.buttons.zoom_speed:setToggleState(false)
  end

  local UIZoomSpeed = cth_require("dialogs.resizables.zoom_speed")
  self.ui:addWindow(UIZoomSpeed(self.ui, callback) )
end

-- So that we can see the option has been changed reload the menu
function UIAccessibility:reload()
  local window = UIAccessibility(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIAccessibility:close()
  UIResizable.close(self)
  local UIOptions = cth_require("dialogs.resizables.options")
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

return UIAccessibility
