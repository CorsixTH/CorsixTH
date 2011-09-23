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

--! Iterface for items within a UI tree control
class "TreeNode"

function TreeNode:TreeNode()
  self.is_expanded = false
  self.num_visible_descendants = 0
end

--! Get the number of childrem which the item has
function TreeNode:getChildCount()
  error "To be implemented in subclasses"
end

--! Query if the item has any children at all.
--! The simple way of doing this is checking if getChildCount() is non-zero,
-- but often this can be implemented in a more efficient manner.
function TreeNode:hasChildren()
  return self:getChildCount() ~= 0
end

--! Get a child of the item.
--!param idx (integer) An integer between 1 and getChildCount() (inclusive).
function TreeNode:getChildByIndex(idx)
  error "To be implemented in subclasses"
end

--! Given a child of the item, determine which index it is
--!param child (TreeNode) A value returned from getChildByIndex()
function TreeNode:getIndexOfChild(child)
  error "To be implemented in subclasses"
end

--! Get the text to be displayed for the item
function TreeNode:getLabel()
  error "To be implemented in subclasses"
end

--! Get the item's parent, if it has one
function TreeNode:getParent()
  return self.parent
end

--! Get the tree control within which the item is displayed
function TreeNode:getControl()
  return self.control or self:getParent():getControl()
end

--! Query whether the item's children are visible
function TreeNode:isExpanded()
  return self.is_expanded
end

--! Get the background colour for when the item is highlighted
function TreeNode:getHighlightColour(canvas)
  return nil
end

--! Make the children of the item visible
function TreeNode:expand()
  if self.is_expanded then return end
  self.is_expanded = true
  self.num_visible_descendants = 0
  for i = 1, self:getChildCount() do
    self.num_visible_descendants = self.num_visible_descendants +
      1 + self:getChildByIndex(i).num_visible_descendants
  end
  local parent = self:getParent()
  while parent do
    parent.num_visible_descendants = parent.num_visible_descendants +
      self.num_visible_descendants
    parent = parent:getParent()
  end
  self:getControl():onNumVisibleNodesChange()
end

--! Make the children of the item invisible
function TreeNode:contract()
  if not self.is_expanded then return end
  self.is_expanded = false
  local parent = self:getParent()
  while parent do
    parent.num_visible_descendants = parent.num_visible_descendants -
      self.num_visible_descendants
    parent = parent:getParent()
  end
  self.num_visible_descendants = 0
  self:getControl():onNumVisibleNodesChange()
end

--! The number of visible items in the set of this item and all its descendants
function TreeNode:numVisibleDescendants()
  if self.hidden then
    return self.num_visible_descendants
  else
    return self.num_visible_descendants + 1
  end
end

--! Get the depth from the root item to this item.
--! The root item has level 0, its direct children have level 1, etc.
function TreeNode:getLevel()
  local level = self.level
  if not level then
    local parent = self:getParent()
    if parent then
      level = parent:getLevel() + 1
    else
      level = 0
    end
    self.level = level
  end
  return level
end

--! Get the previous item in the on-screen display order
function TreeNode:getPrevVisible()
  local parent = self:getParent()
  if not parent then
    return
  end
  local idx = parent:getIndexOfChild(self)
  if idx == 1 then
    return parent
  else
    local prev = parent:getChildByIndex(idx - 1)
    while prev:isExpanded() do
      if not prev:hasChildren() then
        break
      else
        prev = prev:getChildByIndex(prev:getChildCount())
      end
    end
    return prev
  end
end

--! Get the next item in the on-screen display order
function TreeNode:getNextVisible()
  if self:isExpanded() and self:hasChildren() then
    return self:getChildByIndex(1)
  end
  while true do
    local parent = self:getParent()
    if not parent then
      return
    end
    local idx = parent:getIndexOfChild(self)
    if idx == parent:getChildCount() then
      self = parent
    else
      return parent:getChildByIndex(idx + 1)
    end
  end
end

--! A tree node representing a file (or directory) in the physical file-system.
class "FileTreeNode" (TreeNode)

local pathsep = package.config:sub(1, 1)

function FileTreeNode:FileTreeNode(path)
  self:TreeNode()
  if path:sub(-1) == pathsep and path ~= pathsep then
    path = path:sub(1, -2)
  end
  self.path = path
  self.children = {}
  self.has_looked_for_children = false
end

function FileTreeNode:childPath(item)
  if self.path:sub(-1, -1) == pathsep then
    return self.path .. item
  else
    return self.path .. pathsep .. item
  end
end

function FileTreeNode:hasChildren()
  if self.has_looked_for_children then
    return #self.children ~= 0
  elseif self.has_children == nil then
    if self:getLevel() == 0 then
      -- Assume root level things have children until we really need to check
      return true
    end
    self.has_children = false
    local status, _f, _s, _v = pcall(lfs.dir, self.path)
    if not status then
      print("Error while fetching children for " .. self.path .. ": " .. _f)
    else
      for item in _f, _s, _v do
        if self:isValidFile(item) then
          self.has_children = true
          break
        end
      end
    end
  end
  return self.has_children
end

--! Returns whether the given file name is valid
--  in this tree. Override for desired behaviour.
function FileTreeNode:isValidFile(name)
  return name ~= "." and name ~= ".."
end

function FileTreeNode:createNewNode(path)
  return FileTreeNode(path)
end

local function sort_by_key(t1, t2)
  local second_mode = lfs.attributes(t2.path, "mode") == "directory"
  if lfs.attributes(t1.path, "mode") == "directory" then
    if second_mode then
      return t1.sort_key < t2.sort_key
    else
      return true
    end
  else
    if second_mode then
      return false
    else
      return t1.sort_key < t2.sort_key
    end
  end
end

function FileTreeNode:reSortChildren()
  for i, child in ipairs(self.children) do
    if self.sort_by_date then
      child.sort_key = -lfs.attributes(child.path, "modification")
      child.sort_by_date = true
    else
      child.sort_key = child:getLabel()
      child.sort_by_date = false
    end
  end
  table.sort(self.children, sort_by_key)
  for i, child in ipairs(self.children) do
    self.children[child] = i
    child:reSortChildren()
  end
end

function FileTreeNode:checkForChildren()
  if not self.has_looked_for_children then
    self.has_looked_for_children = true
    if self.has_children == false then
      -- Already checked and found nothing
      return
    end
    for item in lfs.dir(self.path) do
      local path = self:childPath(item)
      if self:isValidFile(item) then
        local node = self:createNewNode(path)
        node.sort_key = item:lower()
        self.children[#self.children + 1] = node
      end
    end
    table.sort(self.children, sort_by_key)
    for i, child in ipairs(self.children) do
      self.children[child] = i
      child.parent = self
    end
  end
end

function FileTreeNode:getHighlightColour(canvas)
  return self.highlight_colour
end

function FileTreeNode:getChildCount()
  self:checkForChildren()
  return #self.children
end

function FileTreeNode:getChildByIndex(idx)
  self:checkForChildren()
  return self.children[idx]
end

function FileTreeNode:getIndexOfChild(child)
  return self.children[child]
end

function FileTreeNode:getLabel()
  local label = self.label
  if not label then
    local parent = self:getParent()
    if parent and parent.path then
      if parent.path:sub(-1, -1) == pathsep then
        label = self.path:sub(#parent.path + 1, -1)
      else
        label = self.path:sub(#parent.path + 2, -1)
      end
    else
      label = self.path
    end
    self.label = label
  end
  return label
end

function FileTreeNode:getLastModification()
  return lfs.attributes(self.path, "modification")
end

--! A tree node which can be used as a root node to give the effect of having
-- multiple root nodes.
class "DummyRootNode" (TreeNode)

--!param roots (array) An array of `TreeNode`s which should be displayed as
-- root nodes.
function DummyRootNode:DummyRootNode(roots)
  self:TreeNode()
  self.children = {}
  for i, child in ipairs(roots) do
    self.children[i] = child
    self.children[child] = i
    child.parent = self
  end
  self.level = -1 -- to make children level 0
  self.hidden = true
end

function DummyRootNode:getChildCount()
  return #self.children
end

function DummyRootNode:getChildByIndex(idx)
  return self.children[idx]
end

function DummyRootNode:getIndexOfChild(child)
  return self.children[child]
end

--! A control (to be placed on a window) which allows the user to navigate a
-- tree of items and select one item from it.
class "TreeControl" (Window)

--!param root (TreeNode) The single root node of the tree (use a `DummyRootNode`
-- here if multiple root nodes are desired).
--!param x (integer) The X-position, in pixels, where the control should start
-- within its parent.
--!param y (integer) The Y-position, in pixels, where the control should start
-- within its parent.
--!param width (integer) The width, in pixels, of the control.
--!param height (integer) The height, in pixels, of the control.
--!param col_bg (table) The background colour of the control - this should be
-- a table with `red`, `green`, and `blue` fields, each an integer between 0
-- and 255.
--!param col_fg (table) The colour used for the scrollbar and highlighted items.
function TreeControl:TreeControl(root, x, y, width, height, col_bg, col_fg, y_offset, has_font)
  -- Setup the base window
  self:Window()
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.y_offset = y_offset or 0
  
  -- Load the graphical resources
  local gfx = TheApp.gfx
  if not has_font then
    self.font = gfx:loadBuiltinFont()
  else
    self.font = TheApp.gfx:loadFont("QData", "Font01V")
  end
  self.tree_sprites = gfx:loadSpriteTable("Bitmap", "tree_ctrl", true,
    gfx:loadPalette("Bitmap", "tree_ctrl.pal"))
    
  -- Calculate sizes and counts
  local scrollbar_width = 20
  self.row_height = 10
  self.tree_rect = {
    x = 0,
    y = 0,
    w = width - scrollbar_width,
    h = height - height % self.row_height,
  }
  self.num_rows = (self.tree_rect.h - self.y_offset) / self.row_height
  self:addBevelPanel(0, 0, width, height, col_bg).lowered = true
  local scrollbar_base = self:addBevelPanel(width - scrollbar_width, 0,
    scrollbar_width, height, col_bg)
  scrollbar_base.lowered = true
  self.scrollbar = scrollbar_base:makeScrollbar(col_fg,
    --[[persistable:tree_ctrl_scrollbar_callback]] function()
    self:onScroll()
  end, 1, 1, self.num_rows)
  self.tree_root = root
  if root.hidden then
    self.first_visible_node = root:getChildByIndex(1)
  else
    self.first_visible_node = root
  end
  root.control = self
  self.first_visible_ordinal = 1
  root:expand()
end


function TreeControl:hitTestTree(x, y)
  local rect = self.tree_rect
  x = x - rect.x
  y = y - rect.y - self.y_offset
  if 0 <= x and 0 <= y and x < rect.w and y < rect.h then
    local n = math.floor(y / self.row_height)
    local node = self.first_visible_node
    while n ~= 0 and node do
      node = node:getNextVisible()
      n = n - 1
    end
    if n == 0 then
      return node
    end
  end
end

function TreeControl:onMouseMove(x, y)
  local redraw = Window.onMouseMove(self, x, y)
  local node = self:hitTestTree(x, y)
  if node ~= self.highlighted_node then
    self.highlighted_node = node
    return redraw
  end
  return redraw
end

function TreeControl:onMouseDown(button, x, y)
  local redraw = Window.onMouseDown(self, button, x, y)
  if button ~= 4 and button ~= 5 then
    -- NB: 4 and 5 are scrollwheel
    self.mouse_down_in_self = false
    if 0 <= x and 0 <= y and x < self.width and y < self.height then
      self.mouse_down_in_self = true
      redraw = true
    end
  end
  return redraw
end

function TreeControl:setSelectCallback(callback)
  self.select_callback = callback
  return self
end

function TreeControl:onMouseUp(button, x, y)
  local redraw = Window.onMouseUp(self, button, x, y)
  if button == 4 or button == 5 then
    -- Scrollwheel
    self.scrollbar:setXorY(self.scrollbar:getXorY() + (button - 4.5) * 8)
  else
    local node = self.mouse_down_in_self and self:hitTestTree(x, y)
    if node then
      if self.select_callback then
        self.select_callback(node)
      end
      if node:hasChildren() then
        if node:isExpanded() then
          node:contract()
        else
          node:expand()
        end
        redraw = true
      end
    end
    self.mouse_down_in_self = false
  end
  return redraw
end

function TreeControl:onNumVisibleNodesChange()
  self.scrollbar:setRange(1, self.tree_root:numVisibleDescendants(),
    self.num_rows, self.first_visible_ordinal)
end

function TreeControl:onScroll()
  if self.scrollbar.value > self.first_visible_ordinal then
    for i = 1, self.scrollbar.value - self.first_visible_ordinal do
      self.first_visible_node = self.first_visible_node:getNextVisible()
    end
  elseif self.scrollbar.value < self.first_visible_ordinal then
    for i = 1, self.first_visible_ordinal - self.scrollbar.value do
      self.first_visible_node = self.first_visible_node:getPrevVisible()
    end
  end
  self.first_visible_ordinal = self.scrollbar.value
end

--! Override this function if a certain row should have certain text
-- or additional flavour to it.
function TreeControl:drawExtraOnRow(canvas, node, x, y)
end

function TreeControl:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y + self.y_offset
  
  local node = self.first_visible_node
  local num_nodes_drawn = 0
  local y = y + self.tree_rect.y
  local x = x + self.tree_rect.x
  while node and num_nodes_drawn < self.num_rows do
    local level = node:getLevel()
    for i = 0, level - 1 do
      self.tree_sprites:draw(canvas, 1, x + i * 10, y)
    end
    if node == self.highlighted_node then
      local offset = (level + 1) * 10
      local colour = node:getHighlightColour(canvas) or self.scrollbar.slider.colour
      canvas:drawRect(colour, x + offset - 1, y + 1, self.tree_rect.w - offset - 1, self.row_height - 2)
    end
    local icon
    if not node:hasChildren() then
      icon = 2
    elseif node:isExpanded() then
      icon = 4
    else
      icon = 3
    end
    self.tree_sprites:draw(canvas, icon, x + level * 10, y)
    self.font:draw(canvas, node:getLabel(), x + (level + 1) * 10, y)
    self:drawExtraOnRow(canvas, node, x, y)
    y = y + self.row_height
    num_nodes_drawn = num_nodes_drawn + 1
    node = node:getNextVisible()
  end
end
