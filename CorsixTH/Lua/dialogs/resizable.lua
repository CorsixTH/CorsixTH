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

--! Class for resizable windows.
--! If resizable is set to true, the user can resize by clicking and dragging
--any of the corners.
class "UIResizable" (Window)

local border_offset_x = 9
local border_offset_y = 9
local border_size_x = 40
local border_size_y = 40

function UIResizable:UIResizable(ui, width, height, colour, no_borders)
  self:Window()
  
  local app = ui.app
  self.ui = ui
  self.resizable = false -- by default, not user-resizable
  if not no_borders then
    self.border_sprites = app.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
  end
  
  self.background_panel =
    self:addColourPanel(0, 0, 0, 0, 0, 0, 0)

  self.border_pos = {}
  self.border_pos.left = -border_offset_x
  self.border_pos.upper = -border_offset_y
  
  self:setSize(width, height)
  self:setColour(colour)
end

function UIResizable:setSize(width, height)
  -- NB: minimum size: 50 px each. Would look strange otherwise.
  width = width < 50 and 50 or width
  height = height < 50 and 50 or height
  
  self.width = width
  self.height = height
  self.background_panel.w = width
  self.background_panel.h = height
  
  self.border_pos.right = self.width
  self.border_pos.corner_right = self.width - border_size_x

  self.border_pos.lower = self.height
  self.border_pos.corner_lower = self.height - border_size_y
  
  return width, height
end

function UIResizable:setColour(colour)
  self.colour = colour
  self.background_panel.colour = TheApp.video:mapRGB(colour.red, colour.green, colour.blue)
end

function UIResizable:draw(canvas, x, y)
  local sprites = self.border_sprites
  if sprites then
    local draw = sprites.draw
    local x = self.x + x
    local y = self.y + y
    
    canvas:nonOverlapping(true)
    draw(sprites, canvas, 10, x + self.border_pos.left        , y + self.border_pos.upper) -- upper left corner
    draw(sprites, canvas, 12, x + self.border_pos.corner_right, y + self.border_pos.upper) -- upper right corner
    draw(sprites, canvas, 15, x + self.border_pos.left        , y + self.border_pos.corner_lower) -- lower left corner
    draw(sprites, canvas, 17, x + self.border_pos.corner_right, y + self.border_pos.corner_lower) -- lower right corner
    
    for x = x + border_size_x, x + self.border_pos.corner_right - 1, border_size_x do
      draw(sprites, canvas, 11, x, y + self.border_pos.upper) -- upper edge
      draw(sprites, canvas, 16, x, y + self.border_pos.lower) -- lower edge
    end
    for y = y + border_size_y, y + self.border_pos.corner_lower - 1, border_size_y do
      draw(sprites, canvas, 13, x + self.border_pos.left, y)  -- left edge
      draw(sprites, canvas, 14, x + self.border_pos.right, y) -- right edge
    end
    
    canvas:nonOverlapping(false)
  end
  -- Draw window components
  Window.draw(self, canvas, x, y)
end

function UIResizable:onMouseDown(button, x, y)
  local repaint = Window.onMouseDown(self, button, x, y)
  if button == "left" and not repaint and not (x >= 0 and y >= 0 and
  x < self.width and y < self.height) then
    local res = self:hitTest(x, y)
    if res then
      if res == true or not self.resizable then
        return self:beginDrag(x, y)
      else
        return self:beginResize(x, y, res)
      end
    end
  end
  return repaint
end

function UIResizable:hitTest(x, y)
  if x >= 0 and y >= 0 and x < self.width and y < self.height then -- inside window, should never happen
    return true
  end
  local sprites = self.border_sprites
  if not sprites then
    return false
  end
  if x < -9 or y < -9 or x >= self.width + 9 or y >= self.height + 9 then -- outside border bounds
    return false
  end
  if (0 <= x and x < self.width) or (0 <= y and y < self.height) then -- edges (upper/lower/left/right)
    return true
  end
  local test = sprites.hitTest -- for corners, do explicit hit test because they're round
  return test(sprites, 10, x - self.border_pos.left        , y - self.border_pos.upper) and "ul"        -- upper left
      or test(sprites, 12, x - self.border_pos.corner_right, y - self.border_pos.upper) and "ur"        -- upper right
      or test(sprites, 15, x - self.border_pos.left        , y - self.border_pos.corner_lower) and "ll" -- lower left
      or test(sprites, 17, x - self.border_pos.corner_right, y - self.border_pos.corner_lower) and "lr" -- lower right
end

--[[ Initiate resizing of the resizable window.
!param x The X position of the cursor in window co-ordinatees.
!param y The Y position of the cursor in window co-ordinatees.
!param mode Either one of "ul", "ur", "ll" or "lr" to denote in which direction to resize. (upper/lower + left/right)
]]
function UIResizable:beginResize(x, y, mode)
  if not self.width or not self.height or not self.ui then
    -- Need width, height and UI to resize
    return false
  end
  
  local orig_x = self.x
  local orig_y = self.y
  local ref_x = self.x + x
  local ref_y = self.y + y
  local orig_width = self.width
  local orig_height = self.height
  
  self.dragging = true
  self.ui.drag_mouse_move = --[[persistable:window_resize_mouse_move]] function (sx, sy)
    -- sx and sy are cursor screen co-ords. Convert to relative change.
    sx = sx - ref_x
    sy = sy - ref_y
    
    local invert_x = mode == "ul" or mode == "ll"
    local invert_y = mode == "ul" or mode == "ur"
    
    sx = invert_x and -sx or sx
    sy = invert_y and -sy or sy
    
    local new_width, new_height = self:setSize(orig_width + sx, orig_height + sy)
    local new_x, new_y
    
    if invert_x then
      new_x = orig_x + orig_width - new_width
    end
    if invert_y then
      new_y = orig_y + orig_height - new_height
    end
    
    if new_x or new_y then
      self:setPosition(new_x or orig_x, new_y or orig_y)
    end
  end
  return true
end
