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

local lfs = require "lfs"

--! A tree node representing a file (or directory) in the physical file-system
--  that meets a given file extension criterion.
class "FilteredFileTreeNode" (FileTreeNode)

---@type FilteredFileTreeNode
local FilteredFileTreeNode = _G["FilteredFileTreeNode"]

local pathsep = package.config:sub(1, 1)

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
  -- The label was previously only the file name without extension or
  -- folder hierarchy. TODO: Is there some reason to not show the extension?
  local label = self.label
  if not label then
    label = FileTreeNode.getLabel(self)
    --[[if type(self.filter_by) == "table" then
      for _, ext in ipairs(self.filter_by) do
        if string.sub(label:lower(), -string.len(ext)) == ext then
          label = string.sub(label:lower(), 0, -string.len(ext) - 1)
        end
      end
    elseif string.sub(label:lower(), -string.len(self.filter_by)) == self.filter_by then
      label = string.sub(label:lower(), 0, -string.len(self.filter_by) - 1)
    end--]]
    self.label = label
  end
  return label
end

--! A sortable tree control that accomodates a certain file type and also possibly shows
--  their last modification dates.
class "FilteredTreeControl" (TreeControl)

---@type FilteredTreeControl
local FilteredTreeControl = _G["FilteredTreeControl"]

function FilteredTreeControl:FilteredTreeControl(root, x, y, width, height, col_bg, col_fg, has_font, show_dates)
  self:TreeControl(root, x, y, width, height, col_bg, col_fg, 14, has_font)

  self.num_rows = (self.tree_rect.h - self.y_offset) / self.row_height

  -- Add the two column headers and make buttons on them.
  if show_dates then
    self:addBevelPanel(1, 1, width - 170, 13, col_bg):setLabel(_S.menu_list_window.name)
    :makeButton(0, 0, width - 170, 13, nil, self.sortByName):setTooltip(_S.tooltip.menu_list_window.name)
    self:addBevelPanel(width - 169, 1, 150, 13, col_bg):setLabel(_S.menu_list_window.save_date)
    :makeButton(0, 0, 150, 13, nil, self.sortByDate):setTooltip(_S.tooltip.menu_list_window.save_date)
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

local col_scrollbar = {
  red = 164,
  green = 156,
  blue = 208,
}

--[[ Constructs the dialog.
!param ui (UI) The active ui.
!param mode (string) Either "menu" or "game" depending on which mode the game is in right now.
!param title (string) The desired title of the dialog.
]]
function UIFileBrowser:UIFileBrowser(ui, mode, title, vertical_size, root, show_dates)
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

  local app = ui.app
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
      if node.is_valid_file and (lfs.attributes(node.path, "mode") ~= "directory") then
        local name = node.label
        while (node.parent.parent) do
          name = node.parent.label .. pathsep .. name
          node = node.parent
        end
        self:choiceMade(name)
      end
    end)
  self:addWindow(self.control)

  -- Create the back button.
  self:addBevelPanel((h_size - 160) / 2, 340, 160, 30, self.col_bg):setLabel(_S.menu_list_window.back)
    :makeButton(0, 0, 160, 40, nil, self.buttonBack):setTooltip(_S.tooltip.menu_list_window.back)
end

-- Function stub for dialogs to override. This function is called each time a file is chosen.
--!param name (string) Name of the file chosen.
function UIFileBrowser:choiceMade(name)
end

function UIFileBrowser:buttonBack()
  self:close()
end

