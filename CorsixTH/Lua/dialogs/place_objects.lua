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
local ipairs, math_floor
    = ipairs, math.floor

-- Visually, it looks better to have the object being placed not attached to a
-- tile (so that it is always on top of walls, etc.), but for debugging it can
-- be useful to attach it to a tile.
local ATTACH_BLUEPRINT_TO_TILE = false

class "UIPlaceObjects" (Window)

function UIPlaceObjects:UIPlaceObjects(ui, object_list, pay_for)
  self:Window()
  
  object_list = object_list or {} -- Default argument
  
  local app = ui.app
  self.modal_class = "main"
  self.ui = ui
  self.map = app.map
  self.anims = app.anims
  self.world = app.world
  self.width = 186
  self.height = 167 + #object_list * 29
  self.x = app.config.width - self.width - 20
  self.y = 20
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req05V", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  self.blue_font = app.gfx:loadFont("QData", "Font02V")
  self.title_text = _S.rooms_short.corridor_objects
  self.desc_text = _S.place_objects_window.place_objects_in_corridor
  
  self:addPanel(112, 0, 0) -- Dialog header
  for y = 48, 83, 7 do
    self:addPanel(113, 0, y) -- Desc text box
  end
  self:addPanel(114,   0, 90) -- Dialog mid-piece
  self:addPanel(115,   0, 100):makeButton(9, 8, 41, 42, 116, self.cancel):setSound"no4.wav"
  self.purchase_button =
  self:addPanel(117,  50, 100):makeButton(9, 8, 41, 42, 118, self.purchaseItems) -- Disabled purchase items button
    :setDisabledSprite(127):enable(false)
  self.pickup_button =
  self:addPanel(119,  92, 100):makeButton(9, 8, 41, 42, 120, self.pickupItems) -- Disabled pick up items button
    :setDisabledSprite(128):enable(false)
  self.confirm_button = 
  self:addPanel(121, 134, 100):makeButton(0, 8, 43, 42, 122, self.confirm)
    :setDisabledSprite(129):enable(false):setSound"YesX.wav" -- Disabled confirm button
  
  self.list_header = self:addPanel(123, 0, 146) -- Object list header
  self.list_header.visible = false
  
  self.objects = {}
  self.object_footprint = {}
  self.num_slots = 0
  
  self:addObjects(object_list, pay_for)
end

-- changes the window size and buttons to num_slots slots
function UIPlaceObjects:resize(num_slots)
  if self.num_slots == num_slots then
    return
  end
  
  if num_slots == 0 then
    self.list_header.visible = false
  else
    self.list_header.visible = true
  end
  
  local function idx(i)
    return --[[persistable:place_objects_idx1]] function(self)
      if i == self.active_index then
        self:nextOrientation()
      else
        self.place_objects = true
        self:setActiveIndex(i)
      end
    end
  end
  
  if self.num_slots < num_slots then
      -- change last panel
    if self.num_slots > 0 then
      local last_panel = self.panels[#self.panels - 1]
      last_panel.y = last_panel.y + 4
      last_panel.sprite_index = 124
    end
    
    -- add new panels (save last one)
    for i = self.num_slots + 1, num_slots - 1 do
      self:addPanel(124, 0, 121 + i * 29)
        :makeButton(15, 8, 130, 23, 125, idx(i))
        :preservePanel()
    end
    -- add last new panel
    self:addPanel(156, 0, 117 + num_slots * 29)
      :makeButton(15, 12, 130, 23, 125, idx(num_slots))
      :preservePanel()
  else
    -- remove buttons
    for i = self.num_slots, num_slots + 1, -1 do
      -- NB: Two panels per item, the latter being a dummy for the button
      self.panels[#self.panels] = nil
      self.panels[#self.panels] = nil
      self.buttons[#self.buttons] = nil
      if num_slots > 0 then
        -- change appearance of last panel
        local last_panel = self.panels[#self.panels - 1]
        last_panel.y = last_panel.y - 4
        last_panel.sprite_index = 156
      end
    end
  end
  self.num_slots = num_slots
  self.height = 167 + (num_slots) * 29
end

function UIPlaceObjects:addObjects(object_list, pay_for)
  self.visible = true -- even if no objects are to be placed, make the window visible again

  if not object_list then
    object_list = {}
  end
  
  if #object_list == 0 and #self.objects == 0 then
    return
  end
  
  local function idx(i)
    return --[[persistable:place_objects_idx2]] function(self)
      if i == self.active_index then
        self:nextOrientation()
      else
        self:setActiveIndex(i)
      end
    end
  end
  
  -- Detect objects already existing in self.objects and increment its quantity rather than adding new objects lines
  local new_index = 1
  while true do
    local new_object = object_list[new_index]
    if not new_object then break end
    for index, object in ipairs(self.objects) do
      if new_object.qty > 0 and new_object.object.thob == object.object.thob then
        object.qty = object.qty + new_object.qty
        if pay_for then
          self.ui.hospital:spendMoney(new_object.qty * new_object.object.build_cost, _S.transactions.buy_object .. ": " .. object.object.name)
        end
        table.remove(object_list, new_index)
        new_index = new_index - 1
        break
      end
    end
    new_index = new_index + 1
  end

  self.place_objects = true -- When adding objects guess we want to place objects

  self.object_anim = TH.animation()
  local total_objects = #self.objects + #object_list
  self:resize(total_objects)
  
  for _, object in pairs(object_list) do
    self.objects[#self.objects + 1] = object
    if pay_for then
      self.ui.hospital:spendMoney(object.qty * object.object.build_cost, _S.transactions.buy_object .. ": " .. object.object.name)
    end
  end
  
  -- sort list by size of object (number of tiles in the first existing orienation (usually north))
  table.sort(self.objects, function(o1, o2)
    local orient1 = o1.object.orientations.north or o1.object.orientations.east
                 or o1.object.orientations.south or o1.object.orientations.west
    local orient2 = o2.object.orientations.north or o2.object.orientations.east
                 or o2.object.orientations.south or o2.object.orientations.west
    return #orient1.footprint > #orient2.footprint
  end)
  
  self.active_index = 0 -- avoid case of index changing from 1 to 1
  self:setActiveIndex(1)
  self:onMouseMove(self.ui:getCursorPosition(self))
end

-- precondition: self.active_index has to correspond to the object to be removed
function UIPlaceObjects:removeObject(object, dont_close_if_empty, refund)
  if refund and object.object.build_cost then
    self.ui.hospital:receiveMoney(object.object.build_cost, _S.transactions.sell_object .. ": " .. object.object.name)
  end

  object.qty = object.qty - 1
  if object.qty == 0 then
    if #self.objects == 1 then
      self:clearBlueprint()
      self.object_cell_x, self.object_cell_y = nil
      if dont_close_if_empty then
        self.list_header.visible = false
        self.place_objects = false -- No object to place
      else
        self:close()
        return
      end
    end
    local idx = self.active_index
    table.remove(self.objects, idx)
    self:resize(#self.objects)
    self.active_index = 0 -- avoid case of index changing from 1 to 1
    self:setActiveIndex(1)
  end
  -- Update blueprint
  self:setBlueprintCell(self.object_cell_x, self.object_cell_y)
end

function UIPlaceObjects:removeAllObjects(refund)
  -- There is surely a nicer way to implement this than the current hack. Rewrite it sometime later.
  self.active_index = 1
  for i = 1, #self.objects do
    for j = 1, self.objects[1].qty do
      self:removeObject(self.objects[1], true, refund)
    end
  end
end

function UIPlaceObjects:removeObjects(object_list, refund)
  -- rewrite at some point..
  if not object_list then
    object_list = {}
  end
  
  for i, o in ipairs(object_list) do
    for j, p in ipairs(self.objects) do
      if o.object.id == p.object.id then
        self.active_index = j
        for k = 1, o.qty do
          self:removeObject(p, true, refund)
        end
      end
    end
  end
end

function UIPlaceObjects:close()
  self.ui:tutorialStep(1, {4, 5}, 1)
  self:removeAllObjects(true)
  self:clearBlueprint()
  return Window.close(self)
end

function UIPlaceObjects:cancel()
  self:close()
end

function UIPlaceObjects:setActiveIndex(index)
  if index == self.active_index or #self.objects == 0 then
    return
  end
  self.active_index = index
  
  local object = self.objects[self.active_index].object
  if object.id == "reception_desk" then
    self.ui:tutorialStep(1, 6, 4)
  else
    self.ui:tutorialStep(1, {4, 5}, 6)
  end
  local anims = self.anims
  local _, ghost = self.ui.app.gfx:loadPalette()
  for _, anim in pairs(object.idle_animations) do
    anims:setAnimationGhostPalette(anim, ghost)
  end
  
  self.object_orientation = "west"
  self:nextOrientation()
end

local orient_mirror = {
  north = "west",
  west = "north",
  east = "south",
  south = "east",
}

local orient_next = {
  north = "east",
  east = "south",
  south = "west",
  west = "north",
}

function UIPlaceObjects:setOrientation(orient)
  self.object_orientation = orient
  
  local object = self.objects[self.active_index].object
  local anim = object.idle_animations[orient]
  local flag = 0
  if not anim then
    anim = object.idle_animations[orient_mirror[orient]]
    flag = 1
  end
  if object.orientations[orient].early_list then
    flag = flag + 1024
  end
  self.object_anim:setAnimation(self.anims, anim, flag)
  local px, py = unpack(object.orientations[orient].render_attach_position)
  px, py = Map:WorldToScreen(px + 1, py + 1)
  px = object.orientations[orient].animation_offset[1] + px
  py = object.orientations[orient].animation_offset[2] + py
  self.object_anim:setPosition(px, py)
  self:setBlueprintCell(self.object_cell_x, self.object_cell_y)
end

function UIPlaceObjects:nextOrientation()
  if not self.object_anim then
    return
  end
  local object = self.objects[self.active_index].object
  local orient = self.object_orientation
  repeat
    orient = orient_next[orient]
  until object.orientations[orient]
  self:setOrientation(orient)
end

function UIPlaceObjects:onMouseUp(button, x, y)
  local repaint = Window.onMouseUp(self, button, x, y)
  
  if not self.place_objects then -- We don't want to place objects because we are selecting new objects for adding in a room being built/edited
    return
  end
  
  if #self.objects > 0 then
    if button == "right" then
      self.ui:playSound "swoosh.wav"
      self:nextOrientation()
      repaint = true
    elseif button == "left" then
      if self.object_cell_x and self.object_cell_y and self.object_blueprint_good then
        self:placeObject()
        repaint = true
      elseif self.object_cell_x and self.object_cell_y and not self.object_blueprint_good then
        self.ui:tutorialStep(3, {13, 15}, 14)
      end
    end
  end
  
  return repaint
end

function UIPlaceObjects:placeObject(dont_close_if_empty)
  if not self.place_objects then -- We don't want to place objects because we are selecting new objects for adding in a room being built/edited
    return
  end

  local object = self.objects[self.active_index]
  if object.object.id == "reception_desk" then self.ui:tutorialStep(1, 4, "next") end
  local real_obj =  self.world:newObject(object.object.id, self.object_cell_x,
    self.object_cell_y, self.object_orientation)
  
  local room = self.room or self.world:getRoom(self.object_cell_x, self.object_cell_y)
  if room then
    room.objects[real_obj] = true
  end

  self.ui:playSound "place_r.wav"

  self:removeObject(object, dont_close_if_empty)
  
  return real_obj
end

function UIPlaceObjects:draw(canvas, x, y)
  if not self.visible then
    return -- Do nothing if dialog is not visible
  end

  if not ATTACH_BLUEPRINT_TO_TILE and self.object_cell_x and self.object_anim then
    self.object_anim:draw(canvas, self.ui:WorldToScreen(self.object_cell_x, self.object_cell_y))
  end
  
  Window.draw(self, canvas, x, y)
  
  x, y = x + self.x, y + self.y
  self.white_font:draw(canvas, self.title_text, x + 17, y + 21, 153, 0)
  self.white_font:drawWrapped(canvas, self.desc_text, x + 20, y + 46, 147)
  
  for i, o in ipairs(self.objects) do
    local font = self.white_font
    local y = y + 136 + i * 29
    if i == self.active_index then
      font = self.blue_font
    end
    font:draw(canvas, o.object.name, x + 15, y, 130, 0)
    font:draw(canvas, o.qty, x + 151, y, 19, 0)
  end
end

function UIPlaceObjects:hitTest(x, y)
  return self.visible
end

function UIPlaceObjects:clearBlueprint()
  local map = self.map.th
  if self.object_anim then
    self.object_anim:setTile(nil)
  end
  for _, xy in ipairs(self.object_footprint) do
    if xy[1] ~= 0 then
      map:setCell(xy[1], xy[2], 4, 0)
    end
  end
end

local flag_alpha75 = 256 * 8
local flag_altpal = 16

function UIPlaceObjects:setBlueprintCell(x, y)
  self:clearBlueprint()
  self.object_cell_x = x
  self.object_cell_y = y
  if x and y and #self.objects > 0 then
    local object = self.objects[self.active_index].object
    local object_footprint = object.orientations[self.object_orientation].footprint
    local w, h = self.map.width, self.map.height
    local map = self.map.th
    if #object_footprint ~= #self.object_footprint then
      self.object_footprint = {}
      for i = 1, #object_footprint do
        self.object_footprint[i] = {}
      end
    end
    local flags = {}
    local allgood = true
    local world = self.ui.app.world
    local roomId = self.room and self.room.id
    for i, xy in ipairs(object_footprint) do
      local x = x + xy[1]
      local y = y + xy[2]
      if x < 1 or x > w or y < 1 or y > h then
        allgood = false
        x = 0
        y = 0
      else
        local flag = "buildable"
        local good_tile = 24 + flag_alpha75
        local bad_tile = 67 + flag_alpha75
        if xy.only_passable then
          flag = "passable"
        end
        local cell_flags = map:getCellFlags(x, y, flags)[flag]
        local is_object_allowed = false
        if roomId and flags.roomId ~= roomId then
          is_object_allowed = false
        elseif flags.roomId == 0 and object.corridor_object then
          is_object_allowed = true
          roomId = flags.roomId
        elseif flags.roomId == 0 and not object.corridor_object then
          is_object_allowed = false
        else
          roomId = flags.roomId
          for _, o in pairs(world.rooms[roomId].room_info.objects_additional) do
            if TheApp.objects[o].thob == object.thob then
              is_object_allowed = true
              break
            end
          end
          for o, num in pairs(world.rooms[roomId].room_info.objects_needed) do
            if TheApp.objects[o].thob == object.thob then
              is_object_allowed = true
              break
            end
          end
        end
        
        if cell_flags and is_object_allowed then
          map:setCell(x, y, 4, good_tile)
        else
          map:setCell(x, y, 4, bad_tile)
          allgood = false
        end
      end
      self.object_footprint[i][1] = x
      self.object_footprint[i][2] = y
    end
    if self.object_anim then
      if allgood then
        -- Check that pathfinding still works, i.e. that placing the object
        -- wouldn't disconnect one part of the hospital from another. To do
        -- this, we provisionally mark the footprint as unpassable (as it will
        -- become when the object is placed), and then check that the cells
        -- surrounding the footprint have not had their connectedness changed.
        local function setPassable(passable)
          local flags_to_set = {passable = passable}
          for _, xy in ipairs(object_footprint) do
            local x = x + xy[1]
            local y = y + xy[2]
            if not xy.only_passable then
              map:setCellFlags(x, y, flags_to_set)
            end
          end
        end
        local function isIsolated(x, y)
          setPassable(true)
          local result = not world.pathfinder:isReachableFromHospital(x, y)
          setPassable(false)
          return result
        end
        setPassable(false)
        local prev_x, prev_y
        for _, xy in ipairs(object.orientations[self.object_orientation].adjacent_to_solid_footprint) do
          local x = x + xy[1]
          local y = y + xy[2]
          if map:getCellFlags(x, y, flags).roomId == roomId and flags.passable then
            if prev_x then
              if not world.pathfinder:findDistance(x, y, prev_x, prev_y) then
                -- There is no route between the two map nodes. In most cases,
                -- this means that connectedness has changed, though there is
                -- one rare situation where the above test is insufficient. If
                -- (x, y) is a passable but isolated node outside the hospital
                -- and (prev_x, prev_y) is in the corridor, then the two will
                -- not be connected now, but critically, neither were they
                -- connected before.
                if not isIsolated(x, y) then
                  if not isIsolated(prev_x, prev_y) then
                    allgood = false
                    break
                  end
                else
                  x = prev_x
                  y = prev_y
                end
              end
            end
            prev_x = x
            prev_y = y
          end
        end
        setPassable(true)
      end
      if ATTACH_BLUEPRINT_TO_TILE then
        self.object_anim:setTile(map, x, y)
      end
      self.object_anim:setPartialFlag(flag_altpal, not allgood)
      self.object_blueprint_good = allgood
      self.ui:tutorialStep(1, allgood and 5 or 4, allgood and 4 or 5)
    end
  else
    self.object_footprint = {}
  end
end

function UIPlaceObjects:onMouseMove(x, y, ...)
  local repaint = Window.onMouseMove(self, x, y, ...)
  repaint = true
  
  if not self.place_objects then -- We don't want to place objects because we are selecting new objects for adding in a room being built/edited
    return
  end
  
  local ui = self.ui
  local wx, wy
  if x < 0 or x >= self.width or y < 0 or y >= self.height then
    wx, wy = ui:ScreenToWorld(self.x + x, self.y + y)
    wx = math_floor(wx)
    wy = math_floor(wy)
    if wx < 1 or wy < 1 or wx > self.map.width or wy > self.map.height then
      wx, wy = nil
    end
  end
  if wx ~= self.object_cell_x or wy ~= self.object_cell_y then
    self:setBlueprintCell(wx, wy)
    repaint = true
  end
  
  return repaint
end

function UIPlaceObjects:selectObjectType(object_type)
  for i, o in ipairs(self.objects) do
    if o.object.id == object_type.id then
      self:setActiveIndex(i)
      return
    end
  end
end
