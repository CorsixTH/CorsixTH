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

--! A menu list with a scrollbar. Used by load_game, save_game and custom_game.
class "UIMenuList" (UIResizable)

local col_caption = {
  red = 174,
  green = 166,
  blue = 218,
}

local col_scrollbar = {
  red = 164,
  green = 156,
  blue = 208,
}

--[[ Constructs the menu list dialog.
!param ui (UI) The active ui.
!param mode (string) Either "menu" or "game" depending on which mode the game is in right now.
!param title (string) The desired title of the dialog.
!param items (table) A list of items to include in the list. Each listing should be a table with
keys "name" and "tooltip" with the corresponding values.
!param num_rows (integer) The number of rows displayed at a given time. Default is 10.
]]
function UIMenuList:UIMenuList(ui, mode, title, items, num_rows)
  self.col_bg = {
    red = 154,
    green = 146,
    blue = 198,
  }
  self:UIResizable(ui, 200, 280, self.col_bg)

  self.default_button_sound = "selectx.wav"
  self.items = items
  self.num_rows = num_rows and num_rows or 10
  
  local app = ui.app
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "saveload"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  
  self:addBevelPanel(20, 10, 160, 20, col_caption):setLabel(title)
    .lowered = true
  
  local scrollbar_base = self:addBevelPanel(160, 40, 20, self.num_rows*17, self.col_bg)
  scrollbar_base.lowered = true
  self.scrollbar = scrollbar_base:makeScrollbar(col_scrollbar, --[[persistable:menu_list_scrollbar_callback]] function()
    self:updateButtons()
  end, 1, math.max(#items, 1), self.num_rows)
  
  local function button_clicked(num)
    return --[[persistable:menu_list_button]] function(self)
      self:buttonClicked(num)
    end
  end
  
  self.item_panels = {}
  self.item_buttons = {}
  
  for num = 1, self.num_rows do
    self.item_panels[num] = self:addBevelPanel(20, 40 + (num - 1) * 17, 130, 17, self.col_bg):setLabel(nil, nil, "left")
    self.item_buttons[num] = self.item_panels[num]:makeButton(0, 0, 130, 17, nil, button_clicked(num))
  end
  
  self:addBevelPanel(20, 220, 160, 40, self.col_bg):setLabel(_S.menu_list_window.back)
    :makeButton(0, 0, 160, 40, nil, self.buttonBack):setTooltip(_S.tooltip.menu_list_window.back)
  
  self:updateButtons()
end

function UIMenuList:getSavedWindowPositionName()
  if self.mode == "menu" then
    return "main_menu_group"
  end
  return UIResizable.getSavedWindowPositionName(self)
end

-- Function stub for dialogs to override. This function is called each time a button is clicked.
--!param num (integer) Number of the button pressed.
function UIMenuList:buttonClicked(num)
end

-- Updates buttons when scrolling.
function UIMenuList:updateButtons()
  for num = 1, self.num_rows do
    local panel = self.item_panels[num]
    local button = self.item_buttons[num]
    local item = self.items[num + self.scrollbar.value - 1]
    if item then
      panel:setLabel(item.name)
      panel:setTooltip(item.tooltip)
      button:enable(true)
    else
      panel:setLabel()
      panel:setTooltip()
      button:enable(false)
    end
  end
end

function UIMenuList:buttonBack()
  self:close()
end

function UIMenuList:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end

