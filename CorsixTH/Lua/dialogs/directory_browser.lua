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

--! A tree node representing a directory in the physical file-system
class "DirTreeNode" (TreeNode)

local pathsep = package.config:sub(1, 1)

function DirTreeNode:DirTreeNode(path)
  self:TreeNode()
  if path:sub(-1) == pathsep then
    path = path:sub(1, -2)
  end
  self.path = path
  self.children = {}
  self.has_looked_for_children = false
end

local function sort_by_path(t1, t2)
  return t1.sort_key < t2.sort_key
end

function DirTreeNode:hasChildren()
  if self.has_looked_for_children then
    return #self.children ~= 0
  elseif self.has_children == nil then
    self.has_children = false
    for item in lfs.dir(self.path) do
      local path = self.path .. pathsep .. item
      if item ~= "." and item ~= ".."
      and lfs.attributes(path, "mode") == "directory" then
        self.has_children = true
        break
      end
    end
  end
  return self.has_children
end

function DirTreeNode:checkForChildren()
  if not self.has_looked_for_children then
    self.has_looked_for_children = true
    if self.has_children == false then return end
    for item in lfs.dir(self.path) do
      local path = self.path .. pathsep .. item
      if item ~= "." and item ~= ".."
      and lfs.attributes(path, "mode") == "directory" then
        local node = DirTreeNode(path)
        node.sort_key = item:lower()
        self.children[#self.children + 1] = node
      end
    end
    table.sort(self.children, sort_by_path)
    for i, child in ipairs(self.children) do
      self.children[child] = i
      child.parent = self
    end
  end
end

function DirTreeNode:getHighlightColour(canvas)
  local highlight_colour = self.highlight_colour
  if highlight_colour == nil then
    highlight_colour = false
    if self:getChildCount() >= 3 then
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

function DirTreeNode:getChildCount()
  self:checkForChildren()
  return #self.children
end

function DirTreeNode:getChildByIndex(idx)
  self:checkForChildren()
  return self.children[idx]
end

function DirTreeNode:getIndexOfChild(child)
  return self.children[child]
end

function DirTreeNode:getLabel()
  local label = self.label
  if not label then
    local parent = self:getParent()
    if parent and parent.path then
      label = self.path:sub(#parent.path + 2, -1)
    else
      label = self.path
    end
    self.label = label
  end
  return label
end

--! Prompter for Theme Hospital install directory
class "UIDirBrowser" (Window)

function UIDirBrowser:UIDirBrowser(ui)
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
  self:Window()
  self.width = 500
  self.height = 400
  self:addColourPanel(0, 0, self.width, self.height, self.col_bg.red, self.col_bg.green, self.col_bg.blue)

  self.font = ui.app.gfx:loadBuiltinFont()
  
  self.modal_class = "dir browser"
  self.resizable = false
  self:setDefaultPosition(0.5, 0.5)
  
  -- Create the root item (or items, on Windows), and set it as the
  -- first_visible_node.
  local root
  local roots = lfs.volumes()
  if #roots > 1 then
    for k, v in pairs(roots) do
      roots[k] = DirTreeNode(v)
    end
    root = DummyRootNode(roots)
  else
    root = DirTreeNode(roots[1])
  end

  self:addWindow(TreeControl(root, 5, 55, 490, 340, self.col_bg, self.col_scrollbar)
    :setSelectCallback(function(node)
      if node.is_valid_directory then
        self:chooseDirectory(node.path)
      end
    end))
end

function UIDirBrowser:chooseDirectory(path)
  local app = TheApp
  app.config.theme_hospital_install = path
  app:saveConfig()
  debug.getregistry()._RESTART = true
  app.running = false
end

function UIDirBrowser:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y
  
  self.font:drawWrapped(canvas, _S.install.title, x + 5, y + 5, self.width - 10, "center")
  self.font:drawWrapped(canvas, _S.install.th_directory, x + 5, y + 15, self.width - 10)
end
