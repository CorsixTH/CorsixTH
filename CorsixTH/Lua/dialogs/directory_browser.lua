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
dofile("dialogs/tree_ctrl")
dofile("dialogs/resizable")

--! A tree node representing a directory in the physical file-system.
--! This tree only shows directories and highlights valid TH directories.
class "InstallDirTreeNode" (FileTreeNode)

local pathsep = package.config:sub(1, 1)

function InstallDirTreeNode:InstallDirTreeNode(path)
  self:FileTreeNode(path)
end

function InstallDirTreeNode:isValidFile(name)
  return FileTreeNode.isValidFile(self, name) 
  and lfs.attributes(self:childPath(name), "mode") == "directory"
end

function InstallDirTreeNode:createNewNode(path)
  return InstallDirTreeNode(path)
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
      local nxt = things_to_check[ngot + 1]
      for i = 1, self:getChildCount() do
        local item = self:getChildByIndex(i).sort_key
        if item == nxt then
          ngot = ngot + 1
          if ngot == 3 then
            highlight_colour = canvas:mapRGB(0, 255, 0)
            self.is_valid_directory = true
            break
          end
          nxt = things_to_check[ngot + 1]
        elseif item > nxt then
          break
        end
      end
    end
    self.highlight_colour = highlight_colour
  end
  return highlight_colour or nil
end

--! Prompter for Theme Hospital install directory
class "UIInstallDirBrowser" (UIResizable)

function UIInstallDirBrowser:UIInstallDirBrowser(ui, mode)
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

  self:UIResizable(ui, 500, 423, self.col_bg, mode ~= "menu" and true or false)
  self.ui = ui
  self.mode = mode
  self:setSize(500, 423)
  self:addColourPanel(0, 0, self.width, self.height, self.col_bg.red, self.col_bg.green, self.col_bg.blue)

  self.modal_class = mode == "menu" and "main menu" or "dir browser"
  self.resizable = false
  self.exit_button = self:addBevelPanel(230, 400, 50, 18, self.col_bg)
  if mode == "menu" then
    self.font = TheApp.gfx:loadFont("QData", "Font01V")
    self:setDefaultPosition(0.5, 0.25)
    self.on_top = true
    self.esc_closes = true
    self.exit_button:setLabel(_S.options_window.cancel, self.font):makeButton(0, 0, 50, 18, nil, self.close)
  else
    self.font = ui.app.gfx:loadBuiltinFont()
    self:setDefaultPosition(0.05, 0.5)
    self:addKeyHandler("esc", self.exit)
    self.exit_button:setLabel(_S.install.exit, self.font):makeButton(0, 0, 50, 18, nil, self.exit)
  end

  -- Create the root item (or items, on Windows), and set it as the
  -- first_visible_node.
  local root
  local roots = lfs.volumes()
  if #roots > 1 then
    for k, v in pairs(roots) do
      roots[k] = InstallDirTreeNode(v)
    end
    root = DummyRootNode(roots)
  else
    root = InstallDirTreeNode(roots[1])
  end

  self:addWindow(TreeControl(root, 5, 55, 490, 340, self.col_bg, self.col_scrollbar)
    :setSelectCallback(function(node)
      if node.is_valid_directory then
        self:chooseDirectory(node.path)
      end
    end))
end

function UIInstallDirBrowser:exit()
  self.ui.app:exit()
end

function UIInstallDirBrowser:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIOptions(self.ui, "menu"))
  end
end

function UIInstallDirBrowser:chooseDirectory(path)
  local app = TheApp
  app.config.theme_hospital_install = path
  app:saveConfig()
  debug.getregistry()._RESTART = true
  app.running = false
end

function UIInstallDirBrowser:draw(canvas, x, y)
  UIResizable.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y
  if self.mode ~= "menu" then
    self.font:drawWrapped(canvas, _S.install.title, x + 5, y + 5, self.width - 10, "center")
    self.font:drawWrapped(canvas, _S.install.th_directory, x + 5, y + 15, self.width - 10)
  else
    self.font:drawWrapped(canvas, _S.options_window.new_th_directory, x + 5, y + 15, self.width - 10)
  end
end
