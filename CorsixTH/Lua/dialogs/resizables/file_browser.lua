--[[ Copyright (c) 2011 Edvin "Lego3" Linge

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

local lfs = require("lfs")

--! A tree node representing a file (or directory) in the physical file-system
--  that meets a given file extension criterion.
class "FilteredFileTreeNode" (FileTreeNode)

---@type FilteredFileTreeNode
local FilteredFileTreeNode = _G["FilteredFileTreeNode"]

function FilteredFileTreeNode:FilteredFileTreeNode(path, filter)
  self:FileTreeNode(path)
  self.filter_by = filter
end

function FilteredFileTreeNode:isValidFile(name)
  -- Directories and files ending with .sav are valid.
  if FileTreeNode.isValidFile(self, name) then
    if lfs.attributes(self:childPath(name), "mode") == "directory" then
      return true
    end
    if type(self.filter_by) == "table" then
      for _, ext in ipairs(self.filter_by) do
        if string.sub(name:lower(), -string.len(ext)) == ext then
          return true
        end
      end
    else
      return string.sub(name:lower(), -string.len(self.filter_by)) == self.filter_by
    end
  end
  return false
  -- TODO: We don't want to show hidden files on windows. How can we check that?
end

function FilteredFileTreeNode:createNewNode(path)
  return FilteredFileTreeNode(path, self.filter_by)
end

function FilteredFileTreeNode:getLabel()
  local label = self.label
  if not label then
    label = FileTreeNode.getLabel(self)
    self.label = label
  end
  return label
end

--! A sortable tree control that accommodates a certain file type and also possibly shows
--  their last modification dates.
class "FilteredTreeControl" (TreeControl)

---@type FilteredTreeControl
local FilteredTreeControl = _G["FilteredTreeControl"]

function FilteredTreeControl:FilteredTreeControl(root, x, y, width, height, col_bg, col_fg, has_font, show_dates)
  self:TreeControl(root, x, y, width, height, col_bg, col_fg, 14, has_font)

  self.num_rows = (self.tree_rect.h - self.y_offset) / self.row_height

  -- Magic numbers used to find a static position across different screen resolutions.
  local button1x = math.floor(TheApp.ui.app.config.width / 2 - 90)
  local button2x = button1x + 210
  local buttony = math.floor(TheApp.ui.app.config.height / 4 - 95)
  -- Add the two column headers and make buttons on them.
  if show_dates then
    self:addBevelPanel(1, 1, width - 170, 13, col_bg):setLabel(_S.menu_list_window.name)
    :makeButton(0, 0, width - 170, 13, nil, self.sortByName):setTooltip(_S.tooltip.menu_list_window.name, button1x, buttony)
    self:addBevelPanel(width - 169, 1, 150, 13, col_bg):setLabel(_S.menu_list_window.save_date)
    :makeButton(0, 0, 150, 13, nil, self.sortByDate):setTooltip(_S.tooltip.menu_list_window.save_date, button2x, buttony)
  end
  self.show_dates = show_dates
end

function FilteredTreeControl:sortByName()
  if self.sort_by == "date" or (self.sort_by == "name" and self.order == "descending") then
    self:sortBy("name", "ascending")
  else
    self:sortBy("name", "descending")
  end
end

function FilteredTreeControl:sortByDate()
  if self.sort_by == "name" or (self.sort_by == "date" and self.order == "descending") then
    self:sortBy("date", "ascending")
  else
    self:sortBy("date", "descending")
  end
end

--! Sorts the list according to the given parameters.
--!param sort_by Either "name" or "date".
--!param order Either "ascending" or "descending"
function FilteredTreeControl:sortBy(sort_by, order)
  self.sort_by = sort_by
  self.order = order
  -- Find how many nodes are above the first visible one in order
  -- to make the correct new nodes show. (Because of the scrollbar)
  local number = 0
  local node = self.first_visible_node
  while node ~= self.tree_root do
    number = number + 1
    node = node:getPrevVisible()
  end
  self.tree_root:reSortChildren(sort_by, order)
  -- Now check which new node will be the first visible one.
  node = self.tree_root
  while number > 0 do
    node = node:getNextVisible()
    number = number - 1
  end
  self.first_visible_node = node
end

function FilteredTreeControl:drawExtraOnRow(canvas, node, x, y)
  -- We want to show the modification date to the right of each save.
  if not node:hasChildren() and self.show_dates then
    local last_mod = node:getLastModification()
    local daytime = _S.date_format.daymonth:format(os.date("%d", last_mod), tonumber(os.date("%m", last_mod)))
    self.font:draw(canvas, daytime .. " " .. os.date("%Y %X", last_mod), x + self.tree_rect.w  - 140, y)
  end
end

--! A file browser with a scrollbar. Used by load_game and save_game.
class "UIFileBrowser" (UIResizable)

---@type UIFileBrowser
local UIFileBrowser = _G["UIFileBrowser"]

local col_caption = {
  red = 174,
  green = 166,
  blue = 218,
}

--[[ Constructs the dialog.
!param ui (UI) The active ui.
!param mode (string) Either "menu" or "game" depending on which mode the game is in right now.
!param title (string) The desired title of the dialog.
!param vertical_size (number)
!param root
!param show_dates (boolean) Whether to show date last modified
!param submit_text (string) Optional alternative labelling of the OK button
]]
function UIFileBrowser:UIFileBrowser(ui, mode, title, vertical_size, root, show_dates, submit_text)
  self.col_bg = {
    red = 154,
    green = 146,
    blue = 198,
  }
  self.col_scrollbar = {
    red = 164,
    green = 156,
    blue = 208,
  }
  local h_size = 450
  self:UIResizable(ui, h_size, 380, self.col_bg)

  self.default_button_sound = "selectx.wav"

  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "saveload"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)

  self:addBevelPanel((h_size - 190) / 2, 10, 190, 20, col_caption):setLabel(title)
    .lowered = true

  -- Initialize the tree control
  self.control = FilteredTreeControl(root, 5, 35, h_size - 10, vertical_size, self.col_bg, self.col_scrollbar, true, show_dates)
    :setSelectCallback(--[[persistable:file_browser_select_callback]] function(node)
      if self:checkChoice(node) then self:choiceMade(node.path) end
    end)
    :setValueChangeCallback(--[[persistable:file_browser_textbox_callback]] function(node, label)
      -- Update any user input
      if self:checkChoice(node) then self:setInputValue(label) end
    end)
  self:addWindow(self.control)

  -- Create the back and ok buttons.
  local button_size = 135
  local indent = math.floor((h_size - (2*button_size))/3)
  self:addBevelPanel(indent, 340, button_size, 30, self.col_bg):setLabel(_S.menu_list_window.back)
    :makeButton(0, 0, button_size, 40, nil, self.buttonBack):setTooltip(_S.tooltip.menu_list_window.back)

  self:addBevelPanel(h_size - button_size - indent, 340, button_size, 30,
  self.col_bg):setLabel(submit_text or _S.menu_list_window.ok)
    :makeButton(0, 0, button_size, 40, nil, (--[[persistable:filebrowser_ok_callback]] function()
      if self.confirmName then
        self:confirmName()
      elseif self.control.selected_node then
        local sel_node = self.control.selected_node
        if self:checkChoice(sel_node) then self:choiceMade(sel_node.path) end
      end
    end)):setTooltip(_S.tooltip.menu_list_window.ok)
end

--! Function stub for dialogs to override. This function is called each time a file is chosen.
--!param name (string) Name of the file chosen.
function UIFileBrowser:choiceMade(name)
end

--! Function stub for dialogs with user input option. This will be called for
--! updating inputs, override it for a proper implementation in the derived class.
--!param label (string) Name of the file chosen
function UIFileBrowser:setInputValue(label)
end

--! Check selection is a valid file, and not a directory
--!param node (table) user selected element
function UIFileBrowser:checkChoice(node)
  return node.is_valid_file and (lfs.attributes(node.path, "mode") ~= "directory")
end

function UIFileBrowser:buttonBack()
  self:close()
end
