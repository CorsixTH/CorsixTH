--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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

--! A tree node representing a directory in the physical file-system.
class "DirTreeNode" (FileTreeNode)

local pathsep = package.config:sub(1, 1)

function DirTreeNode:DirTreeNode(path)
  self:FileTreeNode(path)
end

function DirTreeNode:isValidFile(name)
  -- Check parent criteria and that it's a directory.
  if FileTreeNode.isValidFile(self, name)
  and lfs.attributes(self:childPath(name), "mode") == "directory" then
    -- Make sure that we are allowed to read the directory.
    local status, result = pcall(lfs.dir, self:childPath(name))
    return status
  end
end

function DirTreeNode:getSelectColour(canvas)
  if self.is_valid_directory then
    return self.highlight_colour
  else
    return canvas:mapRGB(174, 166, 218)
  end
end




--! This tree only shows directories and highlights valid TH directories.
class "InstallDirTreeNode" (DirTreeNode)

function InstallDirTreeNode:InstallDirTreeNode(path)
  self:FileTreeNode(path)
end

function InstallDirTreeNode:createNewNode(path)
  return InstallDirTreeNode(path)
end

function InstallDirTreeNode:select()
  -- Do nothing as an override. getHighlightColour solves this instead.
end

function InstallDirTreeNode:getHighlightColour(canvas)
  local highlight_colour = self.highlight_colour
  if highlight_colour == nil then
    highlight_colour = false

    if self:getLevel() == 0 and not self.has_looked_for_children then
      -- Assume root-level things are not TH directories, unless we've already
      -- got a list of their children.
      highlight_colour = nil
    elseif self:getChildCount() >= 3 then
      local ngot = 0
      local things_to_check = {"data", "levels", "qdata"}
      for _, thing in ipairs(things_to_check) do
        if not self.children[thing:lower()] then
          break
        else
          ngot = ngot + 1
        end
      end
      if ngot == 3 then
        highlight_colour = canvas:mapRGB(0, 255, 0)
        self.is_valid_directory = true
      end
    end
    self.highlight_colour = highlight_colour
  end
  return highlight_colour or nil
end

--! Prompter for Theme Hospital install directory
class "UIDirectoryBrowser" (UIResizable)

--! Creates a new directory browser window
--!param ui The active UI to hook into.
--!param mode Whether the dialog has been opened from the main_menu or somewhere else. Currently
--! valid are "menu" or "dir_browser".
--!param instruction The textual instruction what the user should do in the dialog.
--!param treenode_class What TreeNode subclass the nodes will be built from. E.g. "InstallDirTreeNode"
--!param callback The function that is called when the user has chosen a directory. Gets
--! a path string as argument.
function UIDirectoryBrowser:UIDirectoryBrowser(ui, mode, instruction, treenode_class, callback)
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

  self:UIResizable(ui, 500, 423, self.col_bg, mode == nil and true or false)
  self.ui = ui
  self.mode = mode
  self.instruction = instruction
  self:setSize(500, 423)
  self:addColourPanel(0, 0, self.width, self.height, self.col_bg.red, self.col_bg.green, self.col_bg.blue)

  self.modal_class = mode == "menu" and "main menu" or "dir browser"
  self.resizable = false
  self.exit_button = self:addBevelPanel(260, 400, 100, 18, self.col_bg)

  if mode ~= nil then
    self.font = TheApp.gfx:loadFont("QData", "Font01V")
    self:setDefaultPosition(0.5, 0.25)
    self.on_top = true
    self.esc_closes = true
    self.exit_button:setLabel(_S.install.cancel, self.font):makeButton(0, 0, 100, 18, nil, self.close)
  else
    self.font = ui.app.gfx:loadBuiltinFont()
    self:setDefaultPosition(0.05, 0.5)
    self:addKeyHandler("esc", self.exit)
    self.exit_button:setLabel(_S.install.exit, self.font):makeButton(0, 0, 100, 18, nil, self.exit)
  end

  -- Create the root item (or items, on Windows), and set it as the
  -- first_visible_node.
  local root
  local roots = lfs.volumes()
  if #roots > 1 then
    for k, v in pairs(roots) do
      roots[k] = _G[treenode_class](v)
    end
    root = DummyRootNode(roots)
  else
    root = _G[treenode_class](roots[1])
  end

  local select_function = function(node)
    if node.is_valid_directory then
      callback(node.path)
      self:close()
    end
  end

  local control = TreeControl(root, 5, 55, 490, 340, self.col_bg, self.col_scrollbar)
    :setSelectCallback(select_function)

  local ok_function = function()
    if control.selected_node then
      select_function(control.selected_node)
    end
  end
  self.ok_button = self:addBevelPanel(130, 400, 100, 18, self.col_bg)
    :setLabel(_S.install.ok, self.font):makeButton(0, 0, 100, 18, nil, ok_function)

  self:addWindow(control)
end

function UIDirectoryBrowser:exit()
  self.ui.app:exit()
end

function UIDirectoryBrowser:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIFolder(self.ui, "menu"))
  end
end

function UIDirectoryBrowser:draw(canvas, x, y)
  UIResizable.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y
  if not self.mode then
    self.font:drawWrapped(canvas, _S.install.title, x + 5, y + 5, self.width - 10, "center")
    self.font:drawWrapped(canvas, self.instruction, x + 5, y + 15, self.width - 10)
  else
    self.font:drawWrapped(canvas, self.instruction, x + 5, y + 15, self.width - 10)
  end
end
