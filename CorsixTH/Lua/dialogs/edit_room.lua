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
    
dofile "dialogs/place_objects"

class "UIEditRoom" (UIPlaceObjects)

function UIEditRoom:UIEditRoom(ui, room_type)
  self.UIPlaceObjects(self, ui)
  
  local app = ui.app
  -- Set alt palette on wall blueprint to make it red
  self.anims:setAnimationGhostPalette(124, app.gfx:loadGhost("QData", "Ghost1.dat", 6))
  -- Set on door and window blueprints too
  self.anims:setAnimationGhostPalette(126, app.gfx:loadGhost("QData", "Ghost1.dat", 6))
  self.anims:setAnimationGhostPalette(130, app.gfx:loadGhost("QData", "Ghost1.dat", 6))
  self.cell_outline = TheApp.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
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
  self.phase = "walls" --> "door" --> "windows" --> "objects" --> "closed"
  self.mouse_down_x = false
  self.mouse_down_y = false
  self.mouse_cell_x = 0
  self.mouse_cell_y = 0
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
  self.phase = "closed"
  self:setBlueprintRect(1, 1, 0, 0)
  return UIPlaceObjects.close(self, ...)
end

function UIEditRoom:cancel()
  if self.phase == "walls" then
    self:close()
  elseif self.phase == "objects" then
    self.phase = "door"
    self:returnToDoorPhase()
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
  elseif self.phase == "windows" then
    self.phase = "objects"
    self:finishRoom()
    self:enterObjectsPhase()
  else
    -- Pay for room
    local cost = self.room_type.build_cost
    for i, obj in ipairs(self.room.objects_needed) do
      cost = cost - obj.object.build_cost
    end
    self.ui.hospital:spendMoney(cost, _S(8, 5) .. ": " .. self.title_text)
    
    self.world:markRoomAsBuilt(self.room)
    self:close()
  end
end

function UIEditRoom:finishRoom()
  local room_type = self.room_type
  local wall_type = self.ui.app.walls[room_type.wall_type]
  local world = self.ui.app.world
  local map = self.ui.app.map.th
  local rect = self.blueprint_rect
  local door
  local function check_external_window(x, y, layer)
    -- If a wall is built which is normal to an external window, then said
    -- window needs to be removed, otherwise it looks odd (see issue #59).
    local block = map:getCell(x, y, layer)
    local dir = world:getWallDirFromBlockId(block)
    local tiles = self.ui.app.walls.external[world:getWallSetFromBlockId(block)]
    if dir == "north_window_1" then
      if x ~= rect.x then
        map:setCell(x, y, layer, tiles.north)
        map:setCell(x + 1, y, layer, tiles.north)
      end
    elseif dir == "north_window_2" then
      if x == rect.x then
        map:setCell(x - 1, y, layer, tiles.north)
        map:setCell(x, y, layer, tiles.north)
      end
    elseif dir == "west_window_1" then
      if y == rect.y then
        map:setCell(x, y, layer, tiles.west)
        map:setCell(x, y - 1, layer, tiles.west)
      end
    elseif dir == "west_window_2" then
      if y ~= rect.y then
        map:setCell(x, y + 1, layer, tiles.west)
        map:setCell(x, y, layer, tiles.west)
      end
    end
  end
  for x, obj in pairs(self.blueprint_wall_anims) do
    for y, anim in pairs(obj) do
      if x == rect.x and y == rect.y then
        local _, east, north = map:getCell(x, y)
        if world:getWallIdFromBlockId(east) == "external" then
          check_external_window(x, y, 2)
        elseif world:getWallSetFromBlockId(east) == "window_tiles" then
          map:setCell(x, y, 2, wall_type.window_tiles.north)
        else
          map:setCell(x, y, 2, wall_type.inside_tiles.north)
        end
        if world:getWallIdFromBlockId(north) == "external" then
          check_external_window(x, y, 3)
        elseif world:getWallSetFromBlockId(north) == "window_tiles" then
          map:setCell(x, y, 3, wall_type.window_tiles.west)
        else
          map:setCell(x, y, 3, wall_type.inside_tiles.west)
        end
      else
        repeat
          local tiles = "outside_tiles"
          local dir = (anim:getFlag() % 2 == 1) and "west" or "north"
          local layer = dir == "north" and 2 or 3
          if world:getWallIdFromBlockId(map:getCell(x, y, layer)) == "external" then
            if layer == 2 then
              if (x == rect.x or x == rect.x + rect.w - 1) and (y == rect.y or y == rect.y + rect.h) then
                check_external_window(x, y, 2)
              end
            else
              if (x == rect.x or x == rect.x + rect.w) and (y == rect.y or y == rect.y + rect.h - 1) then
                check_external_window(x, y, 3)
              end
            end
            break
          end
          local existing = world:getWallSetFromBlockId(map:getCell(x, y, layer))
          if rect.x <= x and x < rect.x + rect.w and rect.y <= y and y < rect.y + rect.h then
            tiles = "inside_tiles"
          elseif existing then
            break
          end
          local tag = anim:getTag()
          if tag == "window" or existing == "window_tiles" then
            tiles = "window_tiles"
          end
          if tag == "door" then
            door = world:newObject("door", x, y, dir)
          else
            map:setCell(x, y, layer, wall_type[tiles][dir])
          end
        until true
      end
      anim:setTile(nil)
    end
  end
  self.room = self.world:newRoom(rect.x, rect.y, rect.w, rect.h, room_type, door)
end

function UIEditRoom:purchaseItems()
  self.visible = false
  self.place_objects = false
  self.ui:addWindow(UIFurnishCorridor(self.ui, self.room.objects_additional, self))
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

function UIEditRoom:returnToDoorPhase()
  local map = self.ui.app.map.th
  local rect = self.blueprint_rect
  local room = self.room
  
  self.purchase_button:enable(false)
  self.world.rooms[room.id] = nil
  UIPlaceObjects.removeAllObjects(self)
  
  -- Remove (and sell) any placed objects
  for x = room.x, room.x + room.width - 1 do
    for y = room.y, room.y + room.height - 1 do
      while true do
        local object = self.world:getObject(x, y)
        if not object or object == room.door then
          break
        end
        self.world:destroyEntity(object)
        local object_type = object.object_type
        self.ui.hospital:receiveMoney(object_type.build_cost, _S(8, 27) .. ": " .. object_type.name)
      end
    end
  end
  self.world:destroyEntity(self.room.door)
  
  -- Remove walls
  local function remove_wall_line(x, y, step_x, step_y, n_steps, layer, neigh_x, neigh_y)
    for i = 1, n_steps do
      local existing = map:getCell(x, y, layer)
      if self.world:getWallIdFromBlockId(existing) ~= "external" then
        local neighbour = self.world:getRoom(x + neigh_x, y + neigh_y)
        if neighbour then
          if neigh_x ~= 0 or neigh_y ~= 0 then
            local set = self.world:getWallSetFromBlockId(existing)
            local dir = self.world:getWallDirFromBlockId(existing)
            if set == "inside_tiles" then
              set = "outside_tiles"
            end
            map:setCell(x, y, layer, self.world.wall_types[neighbour.room_info.wall_type][set][dir])
          end
        else
          map:setCell(x, y, layer, 0)
        end
      end
      x = x + step_x
      y = y + step_y
    end
  end
  remove_wall_line(room.x, room.y, 0, 1, room.height, 3, -1,  0)
  remove_wall_line(room.x, room.y, 1, 0, room.width , 2,  0, -1)
  remove_wall_line(room.x + room.width, room.y , 0, 1, room.height, 3, 0, 0)
  remove_wall_line(room.x, room.y + room.height, 1, 0, room.width , 2, 0, 0)
  
  -- Reset floor tiles and flags
  self.world.map.th:unmarkRoom(room.x, room.y, room.width, room.height)
  
  -- Re-create blueprint
  local rect = self.blueprint_rect
  local old_w, old_h = rect.w, rect.h
  rect.w = 0
  rect.h = 0
  self:setBlueprintRect(rect.x, rect.y, old_w, old_h)
  
  -- We've gone all the way back to wall phase, so step forward to door phase
  self:enterDoorPhase()
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
      return cellx + 1, celly, "north"
    else
      return cellx, celly + 1, "west"
    end
  elseif cellx == rect.x + rect.w - 1 and celly == rect.y + rect.h - 1 then
    -- bottom corner
    local x_, y_ = self.ui:WorldToScreen(cellx, celly)
    if x >= x_ then
      return cellx, celly - 1, "east"
    else
      return cellx - 1, celly, "south"
    end
  elseif cellx == rect.x and celly == rect.y + rect.h - 1 then
    -- left corner
    local x_, y_ = self.ui:WorldToScreen(cellx, celly)
    if y >= y_ + 16 then
      return cellx + 1, celly, "south"
    else
      return cellx, celly - 1, "west"
    end
  elseif cellx == rect.x + rect.w - 1 and celly == rect.y then
    -- right corner
    local x_, y_ = self.ui:WorldToScreen(cellx, celly)
    if y >= y_ + 16 then
      return cellx, celly + 1, "east"
    else
      return cellx - 1, celly, "north"
    end
  elseif (cellx == rect.x - 1 or cellx == rect.x) and rect.y <= celly and celly < rect.y + rect.h then
    -- west edge
    if celly == rect.y then
      celly = rect.y + 1
    elseif celly == rect.y + rect.h - 1 then
      celly = rect.y + rect.h - 2
    end
    return rect.x, celly, "west"
  elseif (celly == rect.y - 1 or celly == rect.y) and rect.x <= cellx and cellx < rect.x + rect.w then
    -- north edge
    if cellx == rect.x then
      cellx = rect.x + 1
    elseif cellx == rect.x + rect.w - 1 then
      cellx = rect.x + rect.w - 2
    end
    return cellx, rect.y, "north"
  elseif (cellx == rect.x + rect.w or cellx == rect.x + rect.w - 1)
      and rect.y <= celly and celly < rect.y + rect.h then
    -- east edge
    if celly == rect.y then
      celly = rect.y + 1
    elseif celly == rect.y + rect.h - 1 then
      celly = rect.y + rect.h - 2
    end
    return rect.x + rect.w - 1, celly, "east"
  elseif (celly == rect.y + rect.h or celly == rect.y + rect.h - 1)
      and rect.x <= cellx and cellx < rect.x + rect.w then
    -- south edge
    if cellx == rect.x then
      cellx = rect.x + 1
    elseif cellx == rect.x + rect.w - 1 then
      cellx = rect.x + rect.w - 2 
    end
    return cellx, rect.y + rect.h - 1, "south"
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

function UIEditRoom:enterObjectsPhase()
  if #self.room.objects_additional == 0 and #self.room.objects_needed == 0 then
    self:confirm()
    return
  end
  self.desc_text = _S(3, 15)
  if #self.room.objects_additional > 0 then
    self.purchase_button:enable(true)
  end
  if #self.room.objects_needed > 0 then
    self.confirm_button:enable(false)
    self:addObjects(self.room.objects_needed)
  end
end

function UIEditRoom:draw(canvas)
  local ui = self.ui
  local x, y = ui:WorldToScreen(self.mouse_cell_x, self.mouse_cell_y)
  self.cell_outline:draw(canvas, 2, x - 32, y)
  
  UIPlaceObjects.draw(self, canvas)
end

function UIEditRoom:onMouseDown(button, x, y)
  if button == "left" then
    if self.phase == "walls" then
      if 0 <= x and x < self.width and 0 <= y and y < self.height then
      else
        local x, y = self.ui:ScreenToWorld(self.x + x, self.y + y)
        self.mouse_down_x = math_floor(x)
        self.mouse_down_y = math_floor(y)
        if self.move_rect then
          self.move_rect_x = self.mouse_down_x - self.blueprint_rect.x
          self.move_rect_y = self.mouse_down_y - self.blueprint_rect.y
        else
          self:setBlueprintRect(self.mouse_down_x, self.mouse_down_y, 1, 1)
        end
      end
    elseif self.phase == "door" then
      if self.blueprint_door.valid then
        self.ui:playSound "buildclk.wav"
        self:confirm()
      else
        self.ui.adviser:say(_S(11, 54))
      end
    elseif self.phase == "windows" then
      self:placeWindowBlueprint()
    end
  end
  
  return UIPlaceObjects.onMouseDown(self, button, x, y) or true
end

function UIEditRoom:onMouseUp(button, x, y)
  if self.mouse_down_x then
    self.mouse_down_x = false
    self.mouse_down_y = false
  end
  
  if self.move_rect_x then
    self.move_rect_x = false
    self.move_rect_y = false
  end
  
  return UIPlaceObjects.onMouseUp(self, button, x, y)
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
  
  local too_small = w < self.room_type.minimum_size or h < self.room_type.minimum_size
  
  -- Entire update of floor tiles and wall animations done in C to replace
  -- several hundred calls into C with just a single call. The price for this
  -- is reduced flexibility. See l_map_updateblueprint in th_lua.cpp for code.
  local is_valid = map.th:updateRoomBlueprint(rect.x, rect.y, rect.w, rect.h,
    x, y, w, h, self.blueprint_wall_anims, self.anims, too_small)

  if self.phase ~= "closed" then
    if too_small then
      self.ui.adviser:say(_S(11, 62))
    elseif not is_valid then
      self.ui.adviser:say(_S(11, 52))
    else
      self.ui.adviser:say(_S(11, 57))
    end
  end
  
  self.confirm_button:enable(is_valid)
  
  rect.x = x
  rect.y = y
  rect.w = w
  rect.h = h
end

local door_floor_blueprint_markers = {
  north = 25,
  east = 28,
  south = 29,
  west = 32,
}

local window_floor_blueprint_markers = {
  north = 33,
  east = 34,
  south = 35,
  west = 36,
}

function UIEditRoom:setDoorBlueprint(x, y, wall)
  local orig_x = x
  local orig_y = y
  local orig_wall = wall
  
  if wall == "south" then
    y = y + 1
    wall = "north"
  elseif wall == "east" then
    x = x + 1
    wall = "west"
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
  if wall == "west" then
    flags = 1
    -- Check for a wall to the west, and prevent placing a door on top of an
    -- existing wall.
    if map:getCell(x, y, 3) % 0x100 ~= 0 then
      flags = flags + 16
      self.blueprint_door.valid = false
    end
  else--if wall == "north" then
    flags = 0
    if map:getCell(x, y, 2) % 0x100 ~= 0 then
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
    self.ui:playSound "buildclk.wav"
  elseif self.blueprint_window.anim and not self.blueprint_window.valid then
    self.ui.adviser:say(_S(11, 55))
  end
end

function UIEditRoom:setWindowBlueprint(x, y, wall)
  local orig_x = x
  local orig_y = y
  local orig_wall = wall
  
  if wall == "south" then
    y = y + 1
    wall = "north"
  elseif wall == "east" then
    x = x + 1
    wall = "west"
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
  if wall == "west" then
    flags = 1
    if world:getWallIdFromBlockId(map:getCell(x, y, 3)) then
      self.blueprint_window.valid = false
      flags = flags + 16
    end
  else--if wall == "north" then
    flags = 0
    if world:getWallIdFromBlockId(map:getCell(x, y, 2)) then
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
  local repaint = UIPlaceObjects.onMouseMove(self, x, y, dx, dy)
  
  local ui = self.ui
  local wx, wy = ui:ScreenToWorld(self.x + x, self.y + y)
  wx = math_floor(wx)
  wy = math_floor(wy)
  
  if self.phase == "walls" then
    local rect = self.blueprint_rect
    if not self.mouse_down_x then
      if wx >= rect.x and wx < rect.x + rect.w and wy >= rect.y and wy < rect.y + rect.h then
        ui:setCursor(ui.app.gfx:loadMainCursor(8))
        self.move_rect = true
      else
        ui:setCursor(ui.default_cursor)
        self.move_rect = false
      end
    end
  else
    local cell_x, cell_y, wall = self:screenToWall(self.x + x, self.y + y)
    if self.phase == "door" then
      self:setDoorBlueprint(cell_x, cell_y, wall)
    elseif self.phase == "windows" then
      self:setWindowBlueprint(cell_x, cell_y, wall)
    end    
  end
  
  if self.mouse_down_x and self.move_rect then
    local rect = self.blueprint_rect
    self:setBlueprintRect(wx - self.move_rect_x, wy - self.move_rect_y, rect.w, rect.h)
  elseif self.mouse_down_x then
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

function UIEditRoom:placeObject()
  UIPlaceObjects.placeObject(self, true)
  local enable_confirm = true
  for _, o in pairs(self.objects) do
    if o.needed == true then
      enable_confirm = false -- While a needed object is not already placed, don't allow to confirm
    end
  end
  self.confirm_button:enable(enable_confirm)
end
