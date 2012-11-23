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
--  that can be loaded as a saved game or contains saved games.
class "LoadSaveFileTreeNode" (FileTreeNode)

local pathsep = package.config:sub(1, 1)

function LoadSaveFileTreeNode:LoadSaveFileTreeNode(path)
  self:FileTreeNode(path)
end

function LoadSaveFileTreeNode:isValidFile(name)
  -- Directories and files ending with .sav are valid.
  return FileTreeNode.isValidFile(self, name) 
  and (lfs.attributes(self:childPath(name), "mode") == "directory"
  or string.sub(name, -4) == ".sav")
end

function LoadSaveFileTreeNode:createNewNode(path)
  return LoadSaveFileTreeNode(path)
end

function LoadSaveFileTreeNode:getLabel()
  -- The label should be only the file name without extension or
  -- folder hierarchy.
  local label = self.label
  if not label then
    label = FileTreeNode.getLabel(self)
    if string.sub(label, -4) == ".sav" then
      label = string.sub(label, 0, -5)
    end
    self.label = label
  end
  return label
end

--! A sortable tree control that accomodates saved games and also shows
--  their last modification dates.
class "LoadSaveTreeControl" (TreeControl)

function LoadSaveTreeControl:LoadSaveTreeControl(root, x, y, width, height, col_bg, col_fg, has_font)
  self:TreeControl(root, x, y, width, height, col_bg, col_fg, 14, has_font)
  -- The most probable preference of sorting is by date - what you played last
  -- is the thing you want to play soon again.
  root:reSortChildren("date", "descending")
  self.sort_by = "date"
  self.order = "descending"

  self.num_rows = (self.tree_rect.h - self.y_offset) / self.row_height
  -- Add the two column headers and make buttons on them.
  self:addBevelPanel(1, 1, width - 170, 13, col_bg):setLabel(_S.menu_list_window.name)
  :makeButton(0, 0, width - 170, 13, nil, self.sortByName):setTooltip(_S.tooltip.menu_list_window.name)
  self:addBevelPanel(width - 169, 1, 150, 13, col_bg):setLabel(_S.menu_list_window.save_date)
  :makeButton(0, 0, width - 170, 13, nil, self.sortByDate):setTooltip(_S.tooltip.menu_list_window.save_date)
end

function LoadSaveTreeControl:sortByName()
  if self.sort_by == "date" or (self.sort_by == "name" and self.order == "descending") then
    self:sortBy("name", "ascending")
  else
    self:sortBy("name", "descending")
  end
end

function LoadSaveTreeControl:sortByDate()
  if self.sort_by == "name" or (self.sort_by == "date" and self.order == "descending") then
    self:sortBy("date", "ascending")
  else
    self:sortBy("date", "descending")
  end
end

--! Sorts the list according to the given parameters.
--!param sort_by Either "name" or "date".
--!param order Either "ascending" or "descending"
function LoadSaveTreeControl:sortBy(sort_by, order)
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

function LoadSaveTreeControl:drawExtraOnRow(canvas, node, x, y)
  -- We want to show the modification date to the right of each save.
  if not node:hasChildren() then
      local last_mod = node:getLastModification()
      local daytime = _S.date_format.daymonth:format(os.date("%d", last_mod), tonumber(os.date("%m", last_mod)))
      self.font:draw(canvas, daytime .. " " .. os.date("%Y %X", last_mod), x + self.tree_rect.w  - 140, y)
    end
end

--! A file browser with a scrollbar. Used by load_game and save_game.
class "UIFileBrowser" (UIResizable)

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
function UIFileBrowser:UIFileBrowser(ui, mode, title, vertical_size)
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
  local root = self.ui.app.savegame_dir
  local treenode = LoadSaveFileTreeNode(root)
  treenode.label = "Saves"
  local control = LoadSaveTreeControl(treenode, 5, 35, h_size - 10, vertical_size, self.col_bg, self.col_scrollbar, true)
    :setSelectCallback(--[[persistable:file_browser_select_callback]] function(node)
      if (lfs.attributes(node.path, "mode") ~= "directory") then
        local name = node.label
        while (node.parent.parent) do
          name = node.parent.label .. pathsep .. name
          node = node.parent
        end
        self:choiceMade(name)
      end
    end)
  self:addWindow(control)
  
  -- Create the back button.
  self:addBevelPanel((h_size - 160) / 2, 340, 160, 30, self.col_bg):setLabel(_S.menu_list_window.back)
    :makeButton(0, 0, 160, 40, nil, self.buttonBack):setTooltip(_S.tooltip.menu_list_window.back)
end

function UIFileBrowser:getSavedWindowPositionName()
  if self.mode == "menu" then
    return "main_menu_group"
  end
  return UIResizable.getSavedWindowPositionName(self)
end

-- Function stub for dialogs to override. This function is called each time a file is chosen.
--!param name (string) Name of the file chosen.
function UIFileBrowser:choiceMade(name)
end

function UIFileBrowser:buttonBack()
  self:close()
end

function UIFileBrowser:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end

