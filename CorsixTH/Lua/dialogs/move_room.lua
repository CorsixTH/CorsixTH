--[[ Copyright (c) 2026 CorsixTH ManoloMC

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

--! Dialog for moving a room with all its contents to a new location.
--! Activated via Ctrl+M over an existing room.
--! Left-click to confirm move, right-click or Escape to cancel.

class "UIMoveRoom" (Window)

---@type UIMoveRoom
local UIMoveRoom = _G["UIMoveRoom"]
local TH = require("TH")

--!param ui (GameUI) The active UI.
--!param room (Room) The room to move.
function UIMoveRoom:UIMoveRoom(ui, room)
  self:Window()
  self.ui = ui
  self.world = ui.app.world
  self.world.mode_deplacement = true
  self.preview_anim = TH.animation()
  self.preview_anim:setAnimation(ui.app.anims, room.room_info.build_preview_animation or room.room_info.build_preview)
  self.room = room
  self.preview_tiles = {}
  -- Store original position if cancel
  self.origin_x, self.origin_y = room.x, room.y
  -- Current position (follows cursor)
  self.target_x, self.target_y = room.x, room.y
    self.replacement_tiles = self:_captureReplacementTiles()
  self.lifted_objects = self:_liftObjects()
  self:addKeyHandler("global_cancel", self, self.cancelMove)
  self:addKeyHandler("global_confirm", self, self.confirmCurrentPosition)
end

---! Remove all objects from the room's tiles and store them with relative positions.
--!return (list) List of {object, rel_x, rel_y, direction} tables.
function UIMoveRoom:_liftObjects()
  local lifted = {}

  for obj, _ in pairs(self.room.objects) do
      local ox, oy = obj.tile_x, obj.tile_y
    -- Store relative position within the room
    lifted[#lifted + 1] = {
      object = obj,
      rel_x = obj.tile_x - self.room.x,
      rel_y = obj.tile_y - self.room.y,
      direction = obj.direction,
      old_x = ox,
      old_y = oy,
    }

      self.world:removeObjectFromTile(obj, ox, oy)
      self.world.map.th:setCellFlags(ox, oy, { buildable = true })
  end
  return lifted
end

---! Draw callback for the room move dialog.
--!
--! Parameters:
--! @param canvas (Canvas) Rendering canvas used by the UI system.
--! @param x      (integer) X offset of the window draw origin.
--! @param y      (integer) Y offset of the window draw origin.
function UIMoveRoom:draw(canvas, x, y)
    self.ui:setCursor(self.ui.grab_cursor)
end

---! Called on every mouse move: update ghost position.
function UIMoveRoom:onMouseMove(x, y, dx, dy)
    self:clearPreview()
    self:drawPreview()
    local wx, wy = self.ui:ScreenToWorld(x, y)
    if wx and wy then
        self.target_x = math.floor(wx)
        self.target_y = math.floor(wy)
    end
    self.mouse_x, self.mouse_y = x, y
    return Window.onMouseMove(self, x, y, dx, dy)
end

function UIMoveRoom:drawPreview()
    local w = self.room.width
    local h = self.room.height
    local map = self.world.map.th
    local has_radiator = self.world:hasRadiator(self.target_x, self.target_y, w, h)

    for dy = 0, h - 1 do
        for dx = 0, w - 1 do
            local x = self.target_x + dx
            local y = self.target_y + dy
            local flags = {}
            local humanoids = self.world.entity_map:getHumanoidsAtCoordinate(x, y)
            map:getCellFlags(x, y, flags)

            if flags.hospital and not has_radiator and not self.world:getRoom(x, y) and #humanoids <= 0 then
                local tile_id = map:getCell(x, y)
                map:setCell(x, y, 1, 1)
                table.insert(self.preview_tiles, {
                    x = x,
                    y = y,
                    tile_id = tile_id
                })
            else
                self:_insertBlackTiles(map, x, y)
            end
        end
    end
end

function UIMoveRoom:_insertBlackTiles(map, x, y)
    local tile_id = map:getCell(x, y)
    map:setCell(x, y, 1, 0)
    table.insert(self.preview_tiles, {
        x = x,
        y = y,
        tile_id = tile_id
    })
end

--- Clear de tile preview and put back the old tiles
function UIMoveRoom:clearPreview()
    if not self.preview_tiles then return end
    local map  = self.world.map.th

    for _, tile in ipairs(self.preview_tiles) do
        map:setCell(tile.x, tile.y, 1, tile.tile_id)
    end

    self.preview_tiles = {}
end

function UIMoveRoom:onMouseDown(button)
    if button == "left" then
        self:clearPreview()
        self:confirmCurrentPosition()
        return true
    elseif button == "right" then
        self:clearPreview()
        self:cancelMove()
        return true
    end
    return true
end

---! Confirm the move at the current cursor position (keyboard shortcut).
function UIMoveRoom:confirmCurrentPosition()
  self:_applyMove(self.target_x, self.target_y)
end


--! Validates the position, moves room tiles, then replaces or refunds objects.
function UIMoveRoom:_applyMove(new_x, new_y)
    local room, world  = self.room, self.world
    local direction_X, direction_Y = (new_x - self.origin_x), (new_y - self.origin_y)
    local old_x, old_y = room.x, room.y

    if direction_X == 0 and direction_Y == 0 then
        self:_restoreObjects(self.origin_x, self.origin_y)
        self:_cleanup()
        return
    end

    self.room_width = room.width
    self.room_height = room.height

    local adjacent_sides = self:_getAdjacentRoomSides(room.x, room.y, room.width, room.height)
    local moved_walls = world:moveRoom(room, direction_X, direction_Y)

    local room_really_moved = (room.x ~= old_x) or (room.y ~= old_y)

    if room_really_moved then
        self:_refreshAdjacentRoomWalls(adjacent_sides, moved_walls)
        self:_restoreReplacementTiles()
    else
        self:_restoreObjects(self.origin_x, self.origin_y)
        self:_cleanup()
        return
    end

    for _, entry in ipairs(self.lifted_objects) do
        local obj = entry.object
        local nx = room.x + entry.rel_x
        local ny = room.y + entry.rel_y

        if world:getRoom(nx, ny) == room then
            obj.direction = entry.direction
            obj:setTile(nx, ny)
            world:addObjectToTile(obj, nx, ny)
            room.objects[obj] = true
        else
            room.objects[obj] = nil
            if entry.old_x and entry.old_y then
                obj:setTile(entry.old_x, entry.old_y)
                world:addObjectToTile(obj, entry.old_x, entry.old_y)
            end
            -- remove from the tile list if it is still registered somewhere
            if obj.tile_x and obj.tile_y then
                world:removeObjectFromTile(obj, obj.tile_x, obj.tile_y)
            end
            obj:setTile(nil)
            room.hospital:refundObject(obj)
        end
    end
    for obj, _ in pairs(room.objects) do
        if obj.tile_x == nil or obj.tile_y == nil then
            room.objects[obj] = nil
        end
    end

    self:_cleanup()
end


--!param base_x (int) X origin of the room (original position).
--!param base_y (int) Y origin of the room (original position).
function UIMoveRoom:_restoreObjects(base_x, base_y)
  for _, entry in ipairs(self.lifted_objects) do
    local obj = entry.object
    local relative_X, relative_Y = (base_x + entry.rel_x), (base_y + entry.rel_y)
    obj:setTile(relative_X, relative_Y)
    self.world:addObjectToTile(obj, relative_X, relative_Y)
  end
end

---! Cancel the move: put all objects back at their original positions.
function UIMoveRoom:cancelMove()
  self:_restoreObjects(self.origin_x, self.origin_y)
  self:_cleanup()
end

---! Common cleanup: restore cursor and close this dialog.
function UIMoveRoom:_cleanup()
  self.ui:setCursor(self.ui.default_cursor)
  self.world.mode_deplacement = false;
  self:close()
end

---! Generate replacement tiles for the room's original area.
--! Uses the dominant surrounding tile to fill the old position after moving.
--! @return (table) list of tiles {x, y, tile_id}
function UIMoveRoom:_captureReplacementTiles()
    local room = self.room
    local tiles = {}
    local dominant_tile = self:_getMostCommonSurroundingTile()

    for dy = 0, room.height - 1 do
        for dx = 0, room.width - 1 do
            tiles[#tiles + 1] = {
                x = room.x + dx,
                y = room.y + dy,
                tile_id = dominant_tile,
            }
        end
    end

    return tiles
end

---! Restore floor tiles at the room's old position after moving.
--! Only applies tiles that are no longer covered by the moved room.
function UIMoveRoom:_restoreReplacementTiles()
    local map = self.world.map.th
    local room = self.room

    if not self.replacement_tiles then return end

    for _, tile in ipairs(self.replacement_tiles) do
        local still_inside_new_room =
        tile.x >= room.x and tile.x < room.x + room.width and
                tile.y >= room.y and tile.y < room.y + room.height

        if not still_inside_new_room then
            map:setCell(tile.x, tile.y, 1, tile.tile_id)
        end
    end
end

---! Get the most common tile surrounding the room.
--! Used to fill the old room area with a visually consistent floor.
--! @return (integer) dominant tile ID
function UIMoveRoom:_getMostCommonSurroundingTile()
    local room = self.room
    local map = self.world.map.th
    local counts = {}
    local best_tile = nil
    local best_count = 0

    local function addTile(x, y)
        local flags = {}
        map:getCellFlags(x, y, flags)

        if flags.hospital then
            local tile_id = map:getCell(x, y)
            counts[tile_id] = (counts[tile_id] or 0) + 1

            if counts[tile_id] > best_count then
                best_count = counts[tile_id]
                best_tile = tile_id
            end
        end
    end

    -- top and bottom line
    for x = room.x, room.x + room.width - 1 do
        addTile(x, room.y - 1)
        addTile(x, room.y + room.height)
    end

    -- left and right column
    for y = room.y, room.y + room.height - 1 do
        addTile(room.x - 1, y)
        addTile(room.x + room.width, y)
    end

    -- diagonal corners
    addTile(room.x - 1, room.y - 1)
    addTile(room.x + room.width, room.y - 1)
    addTile(room.x - 1, room.y + room.height)
    addTile(room.x + room.width, room.y + room.height)

    -- fallback
    if not best_tile then
        best_tile = map:getCell(room.x, room.y)
    end

    return best_tile
end

---! Detect adjacent rooms on each side of the given area.
--! Returns which sides (left, right, top, bottom) are touching another room.
--! @return (table) sides {left, right, top, bottom} as booleans
function UIMoveRoom:_getAdjacentRoomSides(x, y, w, h)
    local world = self.world
    local sides = {
        left = false,
        right = false,
        top = false,
        bottom = false,
    }

    for ty = y, y + h - 1 do
        if world:getRoom(x - 1, ty) and world:getRoom(x - 1, ty) ~= self.room then
            sides.left = true
            break
        end
    end

    for ty = y, y + h - 1 do
        if world:getRoom(x + w, ty) and world:getRoom(x + w, ty) ~= self.room then
            sides.right = true
            break
        end
    end

    for tx = x, x + w - 1 do
        if world:getRoom(tx, y - 1) and world:getRoom(tx, y - 1) ~= self.room then
            sides.top = true
            break
        end
    end

    for tx = x, x + w - 1 do
        if world:getRoom(tx, y + h) and world:getRoom(tx, y + h) ~= self.room then
            sides.bottom = true
            break
        end
    end

    return sides
end

---! Restore walls for adjacent rooms after a room move.
--! Re-applies saved wall segments on sides where neighboring rooms exist.
--! @param adjacent_sides (table) sides {left, right, top, bottom}
--! @param moved_walls (table) saved wall segments from moveRoom
function UIMoveRoom:_refreshAdjacentRoomWalls(adjacent_sides, moved_walls)
    local map = self.world.map.th
    local saved = moved_walls

    if not saved then return end

    local function restoreWallList(list)
        if not list then return end
        for _, wall in ipairs(list) do
            map:setCell(wall.x, wall.y, wall.layer, wall.block_id)
        end
    end

    -- Mapping based on the current moveRoom implementation:
    -- saved.top    = left vertical wall
    -- saved.bottom = right vertical wall
    -- saved.right  = top horizontal wall
    -- saved.left   = bottom horizontal wall

    if adjacent_sides.left then
        restoreWallList(saved.top)
    end

    if adjacent_sides.right then
        restoreWallList(saved.bottom)
    end

    if adjacent_sides.top then
        restoreWallList(saved.right)
    end

    if adjacent_sides.bottom then
        restoreWallList(saved.left)
    end
end