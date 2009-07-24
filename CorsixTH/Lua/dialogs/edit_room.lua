--[[ Copyright (c) 2009 Peter "Corsix" Cawley

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

local TH = require "TH"
local math_floor
    = math.floor

class "UIEditRoom" (Window)

function UIEditRoom:UIEditRoom(ui, room_type)
  self:Window()
  
  local app = ui.app
  self.ui = ui
  self.anims = app.anims
  -- Set alt palette on wall blueprint to make it red
  self.anims:setAnimationGhostPalette(124, app.gfx:loadGhost("QData", "Ghost1.dat", 6))
  -- Set on door and window blueprints too
  self.anims:setAnimationGhostPalette(126, app.gfx:loadGhost("QData", "Ghost1.dat", 6))
  self.anims:setAnimationGhostPalette(130, app.gfx:loadGhost("QData", "Ghost1.dat", 6))
  self.width = 186
  self.height = 159
  self.x = app.config.width - self.width - 20
  self.y = 20
  self.cell_outline = app.gfx:loadBitmap"map_cell_outline"
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req05V", true)
  self.white_font = app.gfx:loadFont(app.gfx:loadSpriteTable("QData", "Font01V"))
  self.room_type = room_type
  self.title_text = room_type.name
  self.desc_text = _S(3, 11) -- Drag out the blueprint until you're happy with its size
  self.blueprint_rect = {
    x = 1,
    y = 1,
    w = 0,
    h = 0,
  }
  self.blueprint_wall_anims = {
  }
  self.blueprint_door = {
  }
  self.blueprint_window = {
  }
  self.phase = "walls" --> "door" --> "windows"
  self.mouse_down_x = false
  self.mouse_down_y = false
  self.mouse_cell_x = 0
  self.mouse_cell_y = 0
  
  self:addPanel(112, 0, 0) -- Dialog header
  for y = 48, 83, 7 do
    self:addPanel(113, 0, y) -- Desc text box
  end
  self:addPanel(114,   0, 90) -- Dialog mid-piece
  self:addPanel(115,   0, 100):makeButton(9, 8, 41, 42, 116, self.cancel)
  self:addPanel(127,  50, 100) -- Disabled purchase items button
  self:addPanel(128,  92, 100) -- Disabled pick up items button
  self.confirm_button = 
  self:addPanel(121, 134, 100):makeButton(0, 8, 43, 42, 122, self.confirm)
    :setDisabledSprite(129):enable(false)
end

function UIEditRoom:close(...)
  for k, obj in pairs(self.blueprint_wall_anims) do
    if obj.setTile then
      obj:setTile(nil)
    else
      for _, anim in pairs(obj) do
        anim:setTile(nil)
      end
    end
    self.blueprint_wall_anims[k] = nil
  end
  self:setBlueprintRect(1, 1, 0, 0)
  return Window.close(self, ...)
end

function UIEditRoom:cancel()
  if self.phase == "walls" then
    self:close()
  else
    self.phase = "walls"
    self:returnToWallPhase()
  end
end

function UIEditRoom:confirm()
  if self.phase == "walls" then
    self.phase = "door"
    self:enterDoorPhase()
  elseif self.phase == "door" then
    self.phase = "windows"
    self:enterWindowsPhase()
  else
    self:finishRoom()
  end
end

function UIEditRoom:finishRoom()
  local room_type = self.room_type
  local wall_type = self.ui.app.walls[room_type.wall_type]
  local world = self.ui.app.world
  local map = self.ui.app.map.th
  local rect = self.blueprint_rect
  for x, obj in pairs(self.blueprint_wall_anims) do
    for y, anim in pairs(obj) do
      if x == rect.x and y == rect.y then
        local _, east, north = map:getCell(x, y)
        if world:getWallIdFromBlockId(east) ~= "external" then
          map:setCell(x, y, 2, wall_type.inside_tiles.east)
        end
        if world:getWallIdFromBlockId(north) ~= "external" then
          map:setCell(x, y, 3, wall_type.inside_tiles.north)
        end
      else
        local tiles = "outside_tiles"
        if (rect.x <= x and x < rect.x + rect.w) and (rect.y <= y and y < rect.y + rect.h) then
          tiles = "inside_tiles"
        end
        local tag = anim:getTag()
        if tag == "window" then
          tiles = "window_tiles"
        end
        local dir = (anim:getFlag() % 2 == 1) and "north" or "east"
        local layer = dir == "east" and 2 or 3
        if tag == "door" then
          world:newObject("door", x, y, dir)
        elseif world:getWallIdFromBlockId(map:getCell(x, y, layer)) ~= "external" then
          map:setCell(x, y, layer, wall_type[tiles][dir])
        end
      end
      anim:setTile(nil)
    end
  end
  map:markRoom(rect.x, rect.y, rect.w, rect.h, room_type.floor_tile)
  self:close()
end

function UIEditRoom:returnToWallPhase()
  self.desc_text = _S(3, 11) -- Drag out the blueprint until you're happy with its size
  self.confirm_button:enable(true)
  for k, obj in pairs(self.blueprint_wall_anims) do
    for _, anim in pairs(obj) do
      anim:setTile(nil)
    end
    self.blueprint_wall_anims[k] = nil
  end
  local rect = self.blueprint_rect
  local x, y, w, h = rect.x, rect.y, rect.w, rect.h
  self:setBlueprintRect(1, 1, 0, 0)
  self:setBlueprintRect(x, y, w, h)
  self.blueprint_door = {}
end

function UIEditRoom:screenToWall(x, y)
  local cellx, celly = self.ui:ScreenToWorld(x, y)
  cellx = math_floor(cellx)
  celly = math_floor(celly)
  local rect = self.blueprint_rect
  
  if cellx == rect.x or cellx == rect.x - 1 or cellx == rect.x + rect.w or cellx == rect.x + rect.w - 1 or
     celly == rect.y or celly == rect.y - 1 or celly == rect.y + rect.h or celly == rect.y + rect.h - 1 then
  else
    return
  end
  
  -- NB: Doors and windows cannot be placed on corner tiles, hence walls of corner tiles
  -- are never returned, and the nearest non-corner wall is returned instead. If they
  -- could be placed on corner tiles, then you would have to consider the interaction of
  -- wall shadows with windows and doors, amonst other things.
  if cellx == rect.x and celly == rect.y then
    -- top corner
    local x_, y_ = self.ui:WorldToScreen(cellx, celly)
    if x >= x_ then
      return cellx + 1, celly, "east"
    else
      return cellx, celly + 1, "north"
    end
  elseif cellx == rect.x + rect.w - 1 and celly == rect.y + rect.h - 1 then
    -- bottom corner
    local x_, y_ = self.ui:WorldToScreen(cellx, celly)
    if x >= x_ then
      return cellx, celly - 1, "south"
    else
      return cellx - 1, celly, "west"
    end
  elseif cellx == rect.x and celly == rect.y + rect.h - 1 then
    -- left corner
    local x_, y_ = self.ui:WorldToScreen(cellx, celly)
    if y >= y_ + 16 then
      return cellx + 1, celly, "west"
    else
      return cellx, celly - 1, "north"
    end
  elseif cellx == rect.x + rect.w - 1 and celly == rect.y then
    -- right corner
    local x_, y_ = self.ui:WorldToScreen(cellx, celly)
    if y >= y_ + 16 then
      return cellx, celly + 1, "south"
    else
      return cellx - 1, celly, "east"
    end
  elseif (cellx == rect.x - 1 or cellx == rect.x) and rect.y <= celly and celly < rect.y + rect.h then
    -- north edge
    if celly == rect.y then
      celly = rect.y + 1
    elseif celly == rect.y + rect.h - 1 then
      celly = rect.y + rect.h - 2
    end
    return rect.x, celly, "north"
  elseif (celly == rect.y - 1 or celly == rect.y) and rect.x <= cellx and cellx < rect.x + rect.w then
    -- east edge
    if cellx == rect.x then
      cellx = rect.x + 1
    elseif cellx == rect.x + rect.w - 1 then
      cellx = rect.x + rect.w - 2
    end
    return cellx, rect.y, "east"
  elseif (cellx == rect.x + rect.w or cellx == rect.x + rect.w - 1)
      and rect.y <= celly and celly < rect.y + rect.h then
    -- south edge
    if celly == rect.y then
      celly = rect.y + 1
    elseif celly == rect.y + rect.h - 1 then
      celly = rect.y + rect.h - 2
    end
    return rect.x + rect.w - 1, celly, "south"
  elseif (celly == rect.y + rect.h or celly == rect.y + rect.h - 1)
      and rect.x <= cellx and cellx < rect.x + rect.w then
    -- west edge
    if cellx == rect.x then
      cellx = rect.x + 1
    elseif cellx == rect.x + rect.w - 1 then
      cellx = rect.x + rect.w - 2 
    end
    return cellx, rect.y + rect.h - 1, "west"
  end
end

function UIEditRoom:enterDoorPhase()
  self.desc_text = _S(3, 12) -- Place the door
  self.confirm_button:enable(false) -- Confirmation is via placing door
  
  -- Change the floor tiles to opaque blue
  local map = self.ui.app.map.th
  for y = self.blueprint_rect.y, self.blueprint_rect.y + self.blueprint_rect.h - 1 do
    for x = self.blueprint_rect.x, self.blueprint_rect.x + self.blueprint_rect.w - 1 do
      map:setCell(x, y, 4, 24)
    end
  end
  
  -- Re-organise wall anims to index by x and y
  local walls = {}
  for _, wall in ipairs(self.blueprint_wall_anims) do
    local map, x, y = wall:getTile()
    if not walls[x] then
      walls[x] = {}
    end
    walls[x][y] = wall
  end
  self.blueprint_wall_anims = walls
end

function UIEditRoom:enterWindowsPhase()
  self.desc_text = _S(3, 13) -- Place some windows if you like, then click confirm
  self.confirm_button:enable(true)
end

function UIEditRoom:draw(canvas)
  local ui = self.ui
  local x, y = ui:WorldToScreen(self.mouse_cell_x, self.mouse_cell_y)
  self.cell_outline:draw(canvas, x - 32, y)
  
  Window.draw(self, canvas)
  
  x, y = self.x, self.y
  self.white_font:draw(canvas, self.title_text, x + 17, y + 21, 153, 0)
  self.white_font:drawWrapped(canvas, self.desc_text, x + 20, y + 46, 147)
end

function UIEditRoom:onMouseDown(button, x, y)
  if button == "left" then
    if self.phase == "walls" then
      if 0 <= x and x < self.width and 0 <= y and y < self.height then
      else
        local x, y = self.ui:ScreenToWorld(self.x + x, self.y + y)
        self.mouse_down_x = math_floor(x)
        self.mouse_down_y = math_floor(y)
        self:setBlueprintRect(self.mouse_down_x, self.mouse_down_y, 1, 1)
      end
    elseif self.phase == "door" then
      if self.blueprint_door.valid then
        self:confirm()
      end
    elseif self.phase == "windows" then
      self:placeWindowBlueprint()
    end
  end
  
  return Window.onMouseDown(self, button, x, y) or true
end

function UIEditRoom:onMouseUp(button, x, y)
  if self.mouse_down_x then
    self.mouse_down_x = false
    self.mouse_down_y = false
  end
  
  return Window.onMouseUp(self, button, x, y)
end

function UIEditRoom:setBlueprintRect(x, y, w, h)
  local rect = self.blueprint_rect
  local map = self.ui.app.map
  if x + w > map.width  then w = map.width  - x end
  if y + h > map.height then h = map.height - y end
  
  if rect.x == x and rect.y == y and rect.w == w and rect.h == h then
    -- Nothing to do
    return
  end
  
  local too_small = w < 4 or h < 4
  
  -- Entire update of floor tiles and wall animations done in C to replace
  -- several hundred calls into C with just a single call. The price for this
  -- is reduced flexibility. See l_map_updateblueprint in th_lua.cpp for code.
  local is_valid = map.th:updateRoomBlueprint(rect.x, rect.y, rect.w, rect.h,
    x, y, w, h, self.blueprint_wall_anims, self.anims, too_small)
  
  self.confirm_button:enable(is_valid)
  
  rect.x = x
  rect.y = y
  rect.w = w
  rect.h = h
end

local door_floor_blueprint_markers = {
  north = 31,
  east = 26,
  south = 27,
  west = 30,
}

local window_floor_blueprint_markers = {
  north = 36,
  east = 33,
  south = 34,
  west = 35,
}

function UIEditRoom:setDoorBlueprint(x, y, wall)
  local orig_x = x
  local orig_y = y
  local orig_wall = wall
  
  if wall == "west" then
    y = y + 1
    wall = "east"
  elseif wall == "south" then
    x = x + 1
    wall = "north"
  end
  
  local map = self.ui.app.map.th
  
  if self.blueprint_door.anim then
    self.blueprint_door.anim:setAnimation(self.anims, self.blueprint_door.old_anim,
      self.blueprint_door.old_flags)
      self.blueprint_door.anim:setTag(nil)
    self.blueprint_door.anim = nil
    map:setCell(self.blueprint_door.floor_x, self.blueprint_door.floor_y, 4, 24)
  end
  self.blueprint_door.x = x
  self.blueprint_door.y = y
  self.blueprint_door.wall = wall
  self.blueprint_door.floor_x = orig_x
  self.blueprint_door.floor_y = orig_y
  self.blueprint_door.valid = false
  if not wall then
    return
  end
  
  local anim = self.blueprint_wall_anims[x][y]
  if anim ~= self.blueprint_door.anim then
    self.blueprint_door.anim = anim
    self.blueprint_door.anim:setTag"door"
    self.blueprint_door.old_anim = anim:getAnimation()
    self.blueprint_door.old_flags = anim:getFlag()
  end
  self.blueprint_door.valid = true
  local flags
  if wall == "north" then
    flags = 1
    if map:getCell(x, y, 3) ~= 0 then
      flags = flags + 16
      self.blueprint_door.valid = false
    end
  else--if wall == "east" then
    flags = 0
    if map:getCell(x, y, 2) ~= 0 then
      flags = flags + 16
      self.blueprint_door.valid = false
    end
  end
  anim:setAnimation(self.anims, 126, flags)
  if self.blueprint_door.valid then
    map:setCell(self.blueprint_door.floor_x, self.blueprint_door.floor_y, 4, 
      door_floor_blueprint_markers[orig_wall])
  end
end

function UIEditRoom:placeWindowBlueprint()
  if self.blueprint_window.anim and self.blueprint_window.valid then
    self.blueprint_window = {}
  end
end

function UIEditRoom:setWindowBlueprint(x, y, wall)
  local orig_x = x
  local orig_y = y
  local orig_wall = wall
  
  if wall == "west" then
    y = y + 1
    wall = "east"
  elseif wall == "south" then
    x = x + 1
    wall = "north"
  end
  
  local map = self.ui.app.map.th
  local world = self.ui.app.world
  
  if self.blueprint_window.anim then
    self.blueprint_window.anim:setAnimation(self.anims, self.blueprint_window.old_anim,
      self.blueprint_window.old_flags)
      self.blueprint_window.anim:setTag(nil)
    self.blueprint_window.anim = nil
    map:setCell(self.blueprint_window.floor_x, self.blueprint_window.floor_y, 4, 24)
  end
  
  local anim = x and self.blueprint_wall_anims[x][y]
  if anim and anim:getTag() then
    x, y, wall, orig_x, orig_y, orig_wall = nil
  end
  
  self.blueprint_window.x = x
  self.blueprint_window.y = y
  self.blueprint_window.wall = wall
  self.blueprint_window.floor_x = orig_x
  self.blueprint_window.floor_y = orig_y
  self.blueprint_window.valid = false
  if not wall then
    return
  end
  
  if anim ~= self.blueprint_window.anim then
    self.blueprint_window.anim = anim
    self.blueprint_window.anim:setTag"window"
    self.blueprint_window.old_anim = anim:getAnimation()
    self.blueprint_window.old_flags = anim:getFlag()
  end
  self.blueprint_window.valid = true
  local flags
  if wall == "north" then
    flags = 1
    if world:getWallIdFromBlockId(map:getCell(x, y, 3)) == "external" then
      self.blueprint_window.valid = false
      flags = flags + 16
    end
  else--if wall == "east" then
    flags = 0
    if world:getWallIdFromBlockId(map:getCell(x, y, 2)) == "external" then
      self.blueprint_window.valid = false
      flags = flags + 16
    end
  end
  anim:setAnimation(self.anims, 130, flags)
  if self.blueprint_window.valid then
    map:setCell(self.blueprint_window.floor_x, self.blueprint_window.floor_y, 4, 
      window_floor_blueprint_markers[orig_wall])
  end
end

function UIEditRoom:onMouseMove(x, y, dx, dy)
  local repaint = Window.onMouseMove(self, x, y, dx, dy)
  
  local ui = self.ui
  local wx, wy = ui:ScreenToWorld(self.x + x, self.y + y)
  wx = math_floor(wx)
  wy = math_floor(wy)
  
  if self.phase ~= "walls" then
    local cell_x, cell_y, wall = self:screenToWall(self.x + x, self.y + y)
    if self.phase == "door" then
      self:setDoorBlueprint(cell_x, cell_y, wall)
    else
      self:setWindowBlueprint(cell_x, cell_y, wall)
    end
  end
  
  if self.mouse_down_x then
    local x1, x2 = self.mouse_down_x, wx
    local y1, y2 = self.mouse_down_y, wy
    if x1 > x2 then x1, x2 = x2, x1 end
    if y1 > y2 then y1, y2 = y2, y1 end
    self:setBlueprintRect(x1, y1, x2 - x1 + 1, y2 - y1 + 1)
  end
  
  if wx ~= self.mouse_cell_x or wy ~= self.mouse_cell_y then
    repaint = true
  end
  self.mouse_cell_x = wx
  self.mouse_cell_y = wy
  
  return repaint
end
