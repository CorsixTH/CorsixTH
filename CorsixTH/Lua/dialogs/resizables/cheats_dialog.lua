--[[ Copyright (c) 2010 Manuel "Roujin" Wolf
Copyright (c) 2020 lewri

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


--! A dialog for activating cheats
class "UICheats" (UIResizable)

---@type UICheats
local UICheats = _G["UICheats"]

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

local col_caption = {
  red = 174,
  green = 166,
  blue = 218,
}

local col_border = {
  red = 134,
  green = 126,
  blue = 178,
}

local col_cheated_no = {
  red = 36,
  green = 154,
  blue = 36,
}

local col_cheated_yes = {
  red = 224,
  green = 36,
  blue = 36,
}

--[[ Constructs the cheat dialog.
!param ui (UI) The active ui.
]]
function UICheats:UICheats(ui)
  self.cheats = ui.hospital.hosp_cheats
  self.cheat_list = ui.hospital.hosp_cheats.cheat_list

  self:UIResizable(ui, 300, 560, col_bg)

  self.default_button_sound = "selectx.wav"

  self.modal_class = "cheats"
  self.esc_closes = true
  self.resizable = false

  local y = 10
  self:addBevelPanel(100, y, 360, 20, col_caption):setLabel(_S.cheats_window.caption)
    .lowered = true

  y = y + 30
  self:addColourPanel(100, y, 360, 40, col_bg.red, col_bg.green, col_bg.blue)
      :setLabel({_S.cheats_window.warning})

  y = y + 40
  self.cheated_panel = self:addBevelPanel(100, y, 360, 18, col_cheated_no, col_border, col_border)

  local function button_clicked(num)
    return --[[persistable:cheats_button]] function(window)
      window:buttonClicked(num)
    end
  end

  self.item_panels = {}
  self.item_buttons = {}

  y = y + 30
  local num = 1
  local function add_cheat_button(x, number)
    self.item_panels[number] = self:addBevelPanel(x, y, 260, 20, col_bg)
      :setLabel(_S.cheats_window.cheats[self.cheat_list[number].name])
    self.item_buttons[number] = self.item_panels[number]
      :makeButton(0, 0, 260, 20, nil, button_clicked(number))
      :setTooltip(_S.tooltip.cheats_window.cheats[self.cheat_list[number].name])
  end
  while self.cheat_list[num] do
    add_cheat_button(20, num)
    num = num + 1
    if self.cheat_list[num] then
      add_cheat_button(280, num)
      num = num + 1
    end
    y = y + 20
  end

  y = y + 20
  self:addBevelPanel(100, y, 360, 40, col_bg):setLabel(_S.cheats_window.close)
    :makeButton(0, 0, 360, 40, nil, self.buttonBack):setTooltip(_S.tooltip.cheats_window.close)

  y = y + 60
  self:setSize(560, y)
  -- Position should be set after all panels/buttons are made
  self:setDefaultPosition(0.2, 0.4)
  self:updateCheatedStatus()
end

function UICheats:updateCheatedStatus()
  local cheated = self.ui.hospital.cheated
  self.cheated_panel:setLabel(cheated and _S.cheats_window.cheated.yes or _S.cheats_window.cheated.no)
  self.cheated_panel:setColour(cheated and col_cheated_yes or col_cheated_no)
end

--! Handles the choice of a cheat from the dialog
--!param num (number) the index in the cheat list
function UICheats:buttonClicked(num)
  -- If the menu was opened by fax code, allow player to use it
  if self.ui.hospital.world:isUserActionProhibited() and not self.ui:getWindow(UIFax) then
    --TODO: Prevent selectx.wav playing with this
    return self.ui:playSound("wrong2.wav")
  end
  local success, message = self.cheats:performCheat(num)
  if success then
    self.cheats.announceCheat(self.ui)
    self:updateCheatedStatus()
  else -- cheat failed, make sure we provide feedback
    message = message or _S.information.cheat_not_possible
  end
  if message then
    self.ui:addWindow(UIInformation(self.ui, {message}))
  end
end

function UICheats:buttonBack()
  self:close()
end

function UICheats:afterLoad(old, new)
  -- Window must be closed for compatibility
  self:close()
  UIResizable.afterLoad(self, old, new)
end
