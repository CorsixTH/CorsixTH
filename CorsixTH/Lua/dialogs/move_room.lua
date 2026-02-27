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
  self.preview_color = {r = 0, g = 255, b = 255, a = 120}
  
  self.preview_anim = TH.animation()
  self.preview_anim:setAnimation(ui.app.anims, room.room_info.build_preview_animation or room.room_info.build_preview)
    
  self.room = room
  
  -- Store original position if cancel
  self.origin_x = room.x
  self.origin_y = room.y

  -- Current position (follows cursor)
  self.target_x = room.x
  self.target_y = room.y
    
  self._old_speed = nil
  pcall(function()
      if ui.app.getGameSpeed then
          self._old_speed = ui.app:getGameSpeed()
      end
  end)
  pcall(function()
      if ui.app.setGameSpeed then
          ui.app:setGameSpeed(0)
      elseif ui.app.setSpeed then
          ui.app:setSpeed(0)
      elseif ui.app.pause then
          ui.app:pause()
      end
  end)
  
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
    Window.draw(self, canvas, x, y)

    if self.preview_anim and self.mouse_x then
        local s = TheApp.config.ui_scale
        canvas:scale(s)
        self.preview_anim:draw(canvas, math.floor(self.mouse_x / s), math.floor(self.mouse_y / s))
        canvas:scale(1)
    end
end

---! Called on every mouse move: update ghost position.
function UIMoveRoom:onMouseMove(x, y, dx, dy)
    local wx, wy = self.ui:ScreenToWorld(x, y)
    if wx and wy then
        self.target_x = math.floor(wx)
        self.target_y = math.floor(wy)
    end
    self.mouse_x, self.mouse_y = x, y
    return Window.onMouseMove(self, x, y, dx, dy)
end

function UIMoveRoom:onMouseDown(button, x, y)
    if button == "left" then
        self:confirmCurrentPosition()
        return true
    elseif button == "right" then
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
    local room  = self.room
    local world = self.world
    local direction_X = new_x - self.origin_x
    local direction_Y = new_y - self.origin_y

    if direction_X == 0 and direction_Y == 0 then
        self:_restoreObjects(self.origin_x, self.origin_y)
        self:_cleanup()
        return
    end

    world:moveRoom(room, direction_X, direction_Y)

    for _, entry in ipairs(self.lifted_objects) do
        local obj = entry.object
        local nx = room.x + entry.rel_x
        local ny = room.y + entry.rel_y

        if world:getRoom(nx, ny) == room then
            -- 0) Safety: detach if still registered somewhere
            if obj.tile_x and obj.tile_y then
                world:removeObjectFromTile(obj, obj.tile_x, obj.tile_y)
            end

            -- 1) Direction first
            obj.direction = entry.direction

            -- 2) Place on map
            obj:setTile(nx, ny)
            world:addObjectToTile(obj, nx, ny)

            -- 3) Re-attach to room ownership
            room.objects[obj] = true    
        else
            -- IMPORTANT: ne pas laisser un objet "sans tile" dans room.objects
            room.objects[obj] = nil
            
            if entry.old_x and entry.old_y then
                obj:setTile(entry.old_x, entry.old_y)
                world:addObjectToTile(obj, entry.old_x, entry.old_y)
            end

            -- remove from the tile list if it is still registered somewhere
            if obj.tile_x and obj.tile_y then
                world:removeObjectFromTile(obj, obj.tile_x, obj.tile_y)
            end

            -- also ensure it doesn't remain positioned
            obj:setTile(nil)

            -- refund money
            room.hospital:refundObject(obj)
        end
    end

    -- Sanity check: aucun objet de room ne doit avoir tile nil
    for obj, _ in pairs(room.objects) do
        if obj.tile_x == nil or obj.tile_y == nil then
            -- Le sortir de la room pour éviter les crashs du place_objects.lua
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
    local relative_X = base_x + entry.rel_x
    local relative_Y = base_y + entry.rel_y
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
    pcall(function()
        if self._old_speed ~= nil then
            if self.ui.app.setGameSpeed then
                self.ui.app:setGameSpeed(self._old_speed)
            elseif self.ui.app.setSpeed then
                self.ui.app:setSpeed(self._old_speed)
            end
        elseif self.ui.app.unpause then
            self.ui.app:unpause()
        end
    end)
  self.ui:setCursor(self.ui.default_cursor)
  self.world.mode_deplacement = false;
  self:close()
end
