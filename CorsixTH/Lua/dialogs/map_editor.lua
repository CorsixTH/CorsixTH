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

class "UIMapEditor" (Window)

local math_floor
    = math.floor

function UIMapEditor:UIMapEditor(ui)
  -- Put ourselves in an easily findable global for the UI code to find.
  _MAP_EDITOR = self
  self:Window()
  self.x = 0
  self.y = 0
  self.width = math.huge
  self.height = math.huge
  self.ui = ui
  
  -- For when there are multiple things which could be sampled from a tile,
  -- keep track of the index of which one was most recently sampled, so that
  -- next time a different one is sampled.
  self.sample_i = 1
  
  -- The block to put on the UI layer as a preview for what will be placed
  -- by the current drawing operation.
  self.block_brush_preview = 0
  
  self:classifyBlocks()
  
  -- A sprite table containing a "cell outline" sprite
  self.cell_outline = TheApp.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
  
  -- Coordinates in Lua tile space of the mouse cursor.
  self.mouse_cell_x = 0
  self.mouse_cell_y = 0
end
  
function UIMapEditor:classifyBlocks()
  -- Classify each block / tile with a type, subtype, and category.
  -- Type and subtype are used by this file, and by the UI code to determine
  -- which gallery to put the block in. Category is used purely by the UI to
  -- allow subsets of a gallery to be hidden.
  local block_info = {}
  for i = 1, 15 do
    block_info[i] = {"floor", "simple", "Outside"}
  end
  for i = 16, 23 do
    block_info[i] = {"floor", "simple", "Inside"}
  end
  for i = 24, 40 do
    block_info[i] = {"floor", "simple", "UI"}
  end
  for i = 41, 58 do
    block_info[i] = {"floor", "simple", "Road"}
  end
  block_info[59] = {"floor", "simple", "Pond"}
  block_info[60] = {"floor", "simple", "Pond"}
  for i = 61, 64 do
    block_info[i] = {"floor", "simple", "Outside"}
  end
  block_info[65] = {"floor", "simple", "Pond"}
  block_info[66] = {"floor", "simple", "Inside"}
  block_info[67] = {"floor", "simple", "UI"}
  block_info[68] = {"floor", "simple", "Pond"}
  block_info[69] = {"floor", "simple", "Pond"}
  block_info[70] = {"floor", "simple", "Inside"}
  for i = 71, 73 do
    block_info[i] = {"floor", "decorated", "Pond", base = 69}
  end
  block_info[76] = {"floor", "simple", "Inside"}
  for i = 77, 80 do
    block_info[i] = {"floor", "simple", "Pond"}
  end
  for i = 82, 164 do
    local pair
    local category = "Internal"
    local dir = i % 2 == 0 and "north" or "west"
    if (82 <= i and i <= 89) or (98 <= i and i <= 105) then
      pair = i + 8
    elseif (i <= 90 and i < 97) or (106 <= i and i <= 113) then
      pair = i - 8
    elseif 114 <= i and i <= 127 then
      category = "External"
      if 114 <= i and i <= 119 then
        pair = i + 8
      elseif 122 <= i and i < 127 then
        pair = i - 8
      end
    elseif 142 <= i and i <= 145 then
      category = "Barrier"
    elseif 157 <= i and i <= 164 then
      category = "External"
      if 157 <= i and i <= 160 then
        pair = i + 4
      elseif 161 <= i and i < 164 then
        pair = i - 4
      end
      dir = dir == "north" and "west" or "north"
    end
    if i ~= 144 and i ~= 145 and i ~= 156 then
      block_info[i] = {"wall", dir, category, pair = pair}
    end
  end
  for i = 176, 191 do
    block_info[i] = {"floor", "decorated", "Hegderow", base = 2}
  end
  for i = 192, 196 do
    block_info[i] = {"floor", "decorated", "Foliage", base = 2}
  end
  for i = 198, 204 do
    block_info[i] = {"floor", "decorated", "Foliage", base = 2}
  end
  for i = 205, 208 do
    block_info[i] = {"floor", "simple", "Outside"}
  end
  block_info[208].base = 3
  for i = 209, 210 do
    block_info[i] = {"object"}
  end
  MapEditorSetBlocks(self.ui.app.map.blocks, block_info) -- pass data to UI
  self.block_info = block_info
end

function UIMapEditor:draw(canvas, ...)
  local ui = self.ui
  local x, y = ui:WorldToScreen(self.mouse_cell_x, self.mouse_cell_y)
  self.cell_outline:draw(canvas, 2, x - 32, y)
  
  Window.draw(self, canvas, ...)
end


function UIMapEditor:onMouseMove(x, y, dx, dy)
  local repaint = Window.onMouseMove(self, x, y, dx, dy)
  
  local ui = self.ui
  local wxr, wyr = ui:ScreenToWorld(self.x + x, self.y + y)
  local wx = math_floor(wxr)
  local wy = math_floor(wyr)
  local map = self.ui.app.map
  
  -- Update the stored state of cursor position, and trigger a repaint as the
  -- cell outline sprite should track the cursor position.
  if wx ~= self.mouse_cell_x or wy ~= self.mouse_cell_y then
    repaint = true
    self.mouse_cell_x = wx
    self.mouse_cell_y = wy
    -- Right button down: sample the block under the cursor (unless left is
    -- held, as that indicates a paint in progress).
    if self.buttons_down.mouse_right and not self.buttons_down.mouse_left then
      self:sampleBlock(x, y)
    end
  end

  -- Left button down: Expand / contract the rectangle which will be painted to
  -- include the original mouse down cell and the current cell, or clear the
  -- rectangle if the cursor is returned to where the mouse down position.
  if self.buttons_down.mouse_left and self.paint_rect and 1 <= wx and 1 <= wy
  and wx <= map.width and wy <= map.height then
    local p1x = math_floor(self.paint_start_wx)
    local p1y = math_floor(self.paint_start_wy)
    local p2x = wx
    local p2y = wy
    local x, y, w, h
    if p1x < p2x then
      x = p1x
      w = p2x - p1x + 1
    else
      x = p2x
      w = p1x - p2x + 1
    end
    if p1y < p2y then
      y = p1y
      h = p2y - p1y + 1
    else
      y = p2y
      h = p1y - p2y + 1
    end
    if w*h > 1 then
      -- The paint rectangle extends beyond the original mouse down cell, so
      -- make the area in the middle of said cell into a "null area" so that
      -- the paint operation can be cancelled by returning the cursor to this
      -- area and ending the drag.
      self.has_paint_null_area = true
    elseif w == 1 and h == 1 and self.has_paint_null_area then
      if ((wxr % 1) - 0.5)^2 + ((wyr % 1) - 0.5)^2 < 0.25^2 then
        w = 0
        h = 0
      end
    end
    local rect = self.paint_rect
    if x ~= rect.x or y ~= rect.y or w ~= rect.w or h ~= rect.h then
      self:setPaintRect(x, y, w, h)
      repaint = true
    end
  end
  
  return repaint
end

function UIMapEditor:onMouseDown(button, x, y)
  local repaint = false
  if button == "right" then
    if self.buttons_down.mouse_left then
      -- Right click while left is down: set paint step size
      local wx, wy = self.ui:ScreenToWorld(x, y)
      local xstep = math.max(1, math.abs(math.floor(wx) - math.floor(self.paint_start_wx)))
      local ystep = math.max(1, math.abs(math.floor(wy) - math.floor(self.paint_start_wy)))
      local rect = self.paint_rect
      self:setPaintRect(rect.x, rect.y, rect.w, rect.h, xstep, ystep)
      repaint = true
    else
      -- Normal right click: sample the block under the cursor
      self:sampleBlock(x, y)
    end
  elseif button == "left" then
    self:startPaint(x, y)
    repaint = true
  elseif button == "left_double" then
    self:doLargePaint(x, y)
    -- Set a dummy paint rect for the mouse up event.
    self:setPaintRect(0, 0, 0, 0)
    repaint = true
  end
  
  return Window.onMouseDown(self, button, x, y) or repaint
end

function UIMapEditor:onMouseUp(button, x, y)
  local repaint = false
  if button == "left" and self.paint_rect then
    self:finishPaint(true)
    repaint = true
  end
  
  return Window.onMouseUp(self, button, x, y) or repaint
end

function UIMapEditor:startPaint(x, y)
  -- Save the Lua world coordinates of where the painting started.
  self.paint_start_wx, self.paint_start_wy = self.ui:ScreenToWorld(x, y)
  -- Initialise an empty paint rectangle.
  self.paint_rect = {
    x = math_floor(self.paint_start_wx),
    y = math_floor(self.paint_start_wy),
    w = 0, h = 0,
  }
  self.has_paint_null_area = false
  -- Check that starting point isn't out of bounds
  local map = self.ui.app.map
  if self.paint_rect.x < 1 or self.paint_rect.y < 1
  or self.paint_rect.x > map.width or self.paint_rect.y > map.height then
    self.paint_rect = nil
    return
  end
  -- Reset the paint step.
  self.paint_step_x = 1
  self.paint_step_y = 1
  -- Extend the paint rectangle to the single cell.
  self:setPaintRect(self.paint_rect.x, self.paint_rect.y, 1, 1)
end

-- Injective function from NxN to N which allows for a pair of positive
-- integers to be combined into a single value suitable for use as a key in a
-- table.
local function combine_ints(x, y)
  local sum = x + y
  return y + sum * (sum + 1) / 2
end

function UIMapEditor:doLargePaint(x, y)
  -- Perform a "large" paint. At the moment, this is triggered by a double
  -- left click, and results in a floor tile "flood fill" operation.
  
  -- Get the Lua tile coordinate of the tile to start filling from.
  x, y = self.ui:ScreenToWorld(x, y)
  x = math_floor(x)
  y = math_floor(y)
  if x <= 0 or y <= 0 then
    return
  end
  
  -- The click which preceeded the double click should have set "old_floors"
  -- with the contents of the tile prior to the single click.
  if not self.old_floors then
    return
  end
  -- brush_f is the tile which is to be painted
  local brush_f = self.block_brush_f
  if not brush_f or brush_f == 0 then
    return
  end
  local map = self.ui.app.map.th
  local key = combine_ints(x, y)
  -- match_f is the tile which is to be replaced by brush_f
  local match_f = self.old_floors[key]
  if not match_f then
    return
  end
  match_f = match_f % 256 -- discard shadow flags, etc.
  -- If the operation wouldn't change anything, don't do it.
  if match_f == brush_f then
    return
  end
  
  -- Reset the starting tile as to simplify the upcoming loop.
  map:setCell(x, y, 1, match_f)
  
  local to_visit = {[key] = {x, y}}
  local visited = {[key] = true}
  -- Mark the tiles beyond the edge of the map as visited, as to prevent the
  -- pathfinding from exceeding the bounds of the map.
  local size = map:size()
  for i = 1, size do
    visited[combine_ints(0, i)] = true
    visited[combine_ints(i, 0)] = true
    visited[combine_ints(size + 1, i)] = true
    visited[combine_ints(i, size + 1)] = true
  end
  -- When a tile is added to "visited" to the first time, also add it to
  -- "to_visit". This ensures each tile is visited no more than once.
  setmetatable(visited, {__newindex = function(t, k, v)
    rawset(t, k, v)
    to_visit[k] = v
  end})
  -- Iterate over the tiles to visit, and if they are suitable for replacement,
  -- do the replacement and add their neighbours to the list of things to do.
  repeat
    x = to_visit[key][1]
    y = to_visit[key][2]
    to_visit[key] = nil
    local f = map:getCell(x, y)
    if f % 256 == match_f then
      map:setCell(x, y, 1, f - match_f + brush_f)
      visited[combine_ints(x, y + 1)] = {x, y + 1}
      visited[combine_ints(x, y - 1)] = {x, y - 1}
      visited[combine_ints(x + 1, y)] = {x + 1, y}
      visited[combine_ints(x - 1, y)] = {x - 1, y}
    end
    to_visit[key] = nil
    key = next(to_visit)
  until not key
end

-- Remove the paint preview from the UI layer, and optionally apply the paint
-- to the actual layers.
function UIMapEditor:finishPaint(apply)
  -- Grab local copies of all the fields which we need
  local map = self.ui.app.map.th
  local brush_f = self.block_brush_f
  local brush_parcel = self.block_brush_parcel
  if brush_parcel then
    brush_parcel = {parcelId = brush_parcel}
  end
  local brush_w1 = self.block_brush_w1
  local brush_w1p = (self.block_info[brush_w1] or '').pair
  local brush_w2 = self.block_brush_w2
  local brush_w2p = (self.block_info[brush_w2] or '').pair
  local x_first, x_last = self.paint_rect.x, self.paint_rect.x + self.paint_rect.w - 1
  local y_first, y_last = self.paint_rect.y, self.paint_rect.y + self.paint_rect.h - 1
  local step_base_x = math.floor(self.paint_start_wx)
  local step_base_y = math.floor(self.paint_start_wy)
  local xstep = self.paint_step_x
  local ystep = self.paint_step_y
  
  -- Determine what kind of thing is being painted.
  local is_wall = self.block_info[self.block_brush_preview]
  is_wall = is_wall and is_wall[1] == "wall" and is_wall[2]
  local is_simple_floor = self.block_info[self.block_brush_preview]
  is_simple_floor = is_simple_floor and is_simple_floor[1] == "floor" and is_simple_floor[2] == "simple"
  
  -- To allow the double click handler to know what was present before the
  -- single click which preceeds it, the prior contents of the floor layer is
  -- saved.
  local old_floors = {}
  self.old_floors = old_floors
  
  for tx = x_first, x_last do
    for ty = y_first, y_last do
      -- Grab and save the contents of the tile
      local f, w1, w2 = map:getCell(tx, ty)
      old_floors[combine_ints(tx, ty)] = f
      local flags
      -- Change the contents according to what is being painted
      repeat
        -- If not painting, do not change anything (apart from UI layer).
        if not apply then
          break
        end
        -- If the paint is happening at an interval, do not change things
        -- apart from at the occurances of the interval.
        if ((tx - step_base_x) % xstep) ~= 0 then
          break
        end
        if ((ty - step_base_y) % ystep) ~= 0 then
          break
        end
        flags = brush_parcel
        -- If painting walls, only apply to the two edges which get painted.
        if is_wall == "north" and ty ~= y_first and ty ~= y_last then
          break
        end
        if is_wall == "west"  and tx ~= x_first and tx ~= x_last then
          break
        end
        -- If painting a floor component, apply it.
        if not brush_parcel and brush_f and brush_f ~= 0 then
          f = f - (f % 256) + brush_f
          -- If painting just a floor component, then remove any decoration
          -- and/or walls which get painted over.
          if is_simple_floor then
            local w1b = self.block_info[w1 % 256]
            if not w1b or w1b[1] ~= "wall" or ty ~= y_first then
              w1 = w1 - (w1 % 256)
            end
            local w2b = self.block_info[w2 % 256]
            if not w2b or w2b[1] ~= "wall" or tx ~= x_first then
              w2 = w2 - (w2 % 256)
            end
          end
        end
        -- If painting wall components, apply them.
        if brush_w1 and brush_w1 ~= 0 then
          w1 = w1 - (w1 % 256) + (ty ~= step_base_y and brush_w1p or brush_w1)
        end
        if brush_w2 and brush_w2 ~= 0 then
          w2 = w2 - (w2 % 256) + (tx ~= step_base_x and brush_w2p or brush_w2)
        end
      until true
      -- Remove the UI layer and perform the adjustment of the other layers.
      map:setCell(tx, ty, f, w1, w2, 0)
      if flags then
        map:setCellFlags(tx, ty, flags)
      end
    end
  end
  map:updateShadows()
end

-- Move/resize the rectangle to be painted, and update the UI preview layer
-- to reflect the new rectangle.
function UIMapEditor:setPaintRect(x, y, w, h, xstep, ystep)
  local map = self.ui.app.map.th
  local rect = self.paint_rect
  local old_xstep = self.paint_step_x or 1
  local old_ystep = self.paint_step_y or 1
  local step_base_x = math.floor(self.paint_start_wx)
  local step_base_y = math.floor(self.paint_start_wy)
  xstep = xstep or old_xstep
  ystep = ystep or old_ystep
  
  -- Create a rectangle which contains both the old and new rectangles, as
  -- this contains all tiles which may need to change.
  local left, right, top, bottom = x, x + w - 1, y, y + h - 1
  if rect then
    if rect.x < left then
      left = rect.x
    end
    if rect.x + rect.w - 1 > right then
      right = rect.x + rect.w - 1
    end
    if rect.y < top then
      top = rect.y
    end
    if rect.y + rect.h - 1 > bottom then
      bottom = rect.y + rect.h - 1
    end
  end
  
  -- Determine what kind of thing is being painted
  local is_wall = self.block_info[self.block_brush_preview]
  local block_brush_preview_pair = is_wall and is_wall.pair
  is_wall = is_wall and is_wall[1] == "wall" and is_wall[2]
  
  
  for tx = left, right do
    for ty = top, bottom do
      local now_in, was_in
      -- Non-walls: paint at every tile within the rectangle
      if not is_wall then
        now_in = (x <= tx and tx < x + w and y <= ty and ty < y + h)
        was_in = (rect.x <= tx and tx < rect.x + rect.w and rect.y <= ty and ty < rect.y + rect.h)
      -- Walls: paint at two edges of the rectangle
      elseif is_wall == "north" then
        now_in = (x <= tx and tx < x + w and (y == ty or ty == y + h - 1))
        was_in = (rect.x <= tx and tx < rect.x + rect.w and (rect.y == ty or ty == rect.y + rect.h - 1))
      elseif is_wall == "west" then
        now_in = ((x == tx or tx == x + w - 1) and y <= ty and ty < y + h)
        was_in = ((rect.x == tx or tx == rect.x + rect.w - 1) and rect.y <= ty and ty < rect.y + rect.h)
      end
      -- Restrict the paint to tiles which fall on the appropriate intervals
      now_in = now_in and ((tx - step_base_x) % xstep) == 0
      now_in = now_in and ((ty - step_base_y) % ystep) == 0
      was_in = was_in and ((tx - step_base_x) % old_xstep) == 0
      was_in = was_in and ((ty - step_base_y) % old_ystep) == 0
      -- Update the tile, but only if it needs changing
      if now_in ~= was_in then
        local ui_layer = 0
        if now_in then
          local brush = self.block_brush_preview
          if is_wall == "north" and ty ~= step_base_y then
            brush = block_brush_preview_pair or brush
          end
          if is_wall == "west" and tx ~= step_base_x then
            brush = block_brush_preview_pair or brush
          end
          ui_layer = brush + 256 * DrawFlags.Alpha50
        end
        map:setCell(tx, ty, 4, ui_layer)
      end
    end
  end
  
  -- Save the details of the new rectangle
  if not rect then
    rect = {}
    self.paint_rect = rect
  end
  rect.x = x
  rect.y = y
  rect.w = w
  rect.h = h
  self.paint_step_x = xstep
  self.paint_step_y = ystep
end

function UIMapEditor:sampleBlock(x, y)
  local ui = self.ui
  local wx, wy = self.ui:ScreenToWorld(x, y)
  wx = math_floor(wx)
  wy = math_floor(wy)
  local map = self.ui.app.map
  if wx < 1 or wy < 1 or wx > map.width or wy > map.height then
    return
  end
  local floor, wall1, wall2 = map.th:getCell(wx, wy)
  local set = {}
  set[floor % 256] = true
  set[wall1 % 256] = true
  set[wall2 % 256] = true
  if wx < map.width then
    floor, wall1, wall2 = map.th:getCell(wx + 1, wy)
    set[wall2 % 256] = true
  end
  if wy < map.height then
    floor, wall1, wall2 = map.th:getCell(wx, wy + 1)
    set[wall1 % 256] = true
  end
  set[0] = nil
  local floor_list = {}
  local wall_list = {}
  for i in pairs(set) do
    if self.block_info[i] then
      if self.block_info[i][1] == "floor" then
        floor_list[#floor_list + 1] = i
      elseif self.block_info[i][1] == "wall" then
        wall_list[#wall_list + 1] = i
      end
    end
  end
  
  if wx == self.recent_sample_x and wy == self.recent_sample_y then
    self.sample_i = self.sample_i + 1
  else
    self.sample_i = 1
    self.recent_sample_x = wx
    self.recent_sample_y = wy
  end
  MapEditorSetBlockBrush(
    floor_list[1 + (self.sample_i - 1) % #floor_list] or 0,
    wall_list [1 + (self.sample_i - 1) % #wall_list ] or 0
  )
end

-- Called by the UI to set what should be painted.
function UIMapEditor:setBlockBrush(f, w1, w2)
  local preview = f
  if w2 ~= 0 then
    preview = w2
  elseif w1 ~= 0 then
    preview = w1
  end
  self.block_brush_preview = preview
  self.block_brush_parcel = nil
  self.block_brush_f = f
  self.block_brush_w1 = w1
  self.block_brush_w2 = w2
end

function UIMapEditor:setBlockBrushParcel(parcel)
  self.block_brush_preview = 24
  self.block_brush_parcel = parcel
  self.block_brush_f = self.block_brush_preview
  self.block_brush_w1 = 0
  self.block_brush_w2 = 0
end
