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

local TH = require("TH")
local ipairs, math_floor
    = ipairs, math.floor

-- Visually, it looks better to have the object being placed not attached to a
-- tile (so that it is always on top of walls, etc.), but for debugging it can
-- be useful to attach it to a tile.
local ATTACH_BLUEPRINT_TO_TILE = false

--! The dialog shown when placing objects.
class "UIPlaceObjects" (Window)

---@type UIPlaceObjects
local UIPlaceObjects = _G["UIPlaceObjects"]

--[[ Constructor for the class.
!param ui (UI) The active ui.
!param object_list (table) a list of tables with objects to place. Keys are "object", "qty" and
"existing_object". The first is the object_type of the object, the second how many, and if the key
"existing_object" is set it should be an already existing object that is about to be moved.
In particular, if that object has a variable called current_frame then that frame will be used
when drawing the object as it is being moved.
]]
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
  self:setDefaultPosition(0.9, 0.1)
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
  self:addPanel(115,   0, 100):makeButton(9, 8, 41, 42, 116, self.cancel):setSound("no4.wav"):setTooltip(_S.tooltip.place_objects_window.cancel)
  self.purchase_button =
  self:addPanel(117,  50, 100):makeButton(1, 8, 41, 42, 118, self.purchaseItems):setTooltip(_S.tooltip.place_objects_window.buy_sell)
    :setDisabledSprite(127):enable(false) -- Disabled purchase items button
  self.pickup_button =
  self:addPanel(119,  92, 100):makeButton(1, 8, 41, 42, 120, self.pickupItems):setTooltip(_S.tooltip.place_objects_window.pick_up)
    :setDisabledSprite(128):enable(false):makeToggle() -- Disabled pick up items button
  self.confirm_button =
  self:addPanel(121, 134, 100):makeButton(1, 8, 43, 42, 122, self.confirm):setTooltip(_S.tooltip.place_objects_window.confirm)
    :setDisabledSprite(129):enable(false):setSound("YesX.wav") -- Disabled confirm button

  self.list_header = self:addPanel(123, 0, 146) -- Object list header
  self.list_header.visible = false

  self.objects = {}
  self.object_footprint = {}
  self.num_slots = 0

  self:addObjects(object_list, pay_for)
  ui:setWorldHitTest(false)
  UIPlaceObjects.registerKeyHandlers(self)
end

function UIPlaceObjects:registerKeyHandlers()
  self:addKeyHandler("global_cancel", self.cancel)
  self:addKeyHandler("global_cancel_alt", self.cancel)
  self:addKeyHandler("ingame_rotateobject", self.tryNextOrientation)
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
    return --[[persistable:place_objects_idx1]] function(window)
      if i == window.active_index then
        window:nextOrientation()
      else
        window.place_objects = true
        window:setActiveIndex(i)
        -- Stop picking up items when user presses object in list
        local edit_room_window = window.ui:getWindow(UIEditRoom)
        if edit_room_window and edit_room_window.in_pickup_mode then
          edit_room_window:stopPickupItems()
        end
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
    for _ = self.num_slots, num_slots + 1, -1 do
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

  -- Detect objects already existing in self.objects and increment its quantity
  -- rather than adding new objects lines.
  local new_index = 1
  while true do
    local new_object = object_list[new_index]
    if not new_object then break end
    for _, object in ipairs(self.objects) do
      if new_object.qty > 0 and new_object.object.thob == object.object.thob then
        object.qty = object.qty + new_object.qty
        if pay_for then
          local build_cost = self.ui.hospital:getObjectBuildCost(new_object.object.id)
          local msg = _S.transactions.buy_object .. ": " .. object.object.name
          self.ui.hospital:spendMoney(new_object.qty * build_cost, msg, new_object.qty * build_cost)
        end
        -- If this is an object that has been created in the world already, add it to the
        -- associated list of objects to re-place.
        if new_object.existing_object then
          if not object.existing_objects then
            object.existing_objects = {}
          end
          -- Insert the new object in the beginning of the list so that that this object
          -- is the one to be placed first. (LIFO)
          table.insert(object.existing_objects, 1, new_object.existing_object)
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
  self.object_slave_anim = TH.animation()
  local total_objects = #self.objects + #object_list
  self:resize(total_objects)

  for _, object in pairs(object_list) do
    if object.existing_object then
      object.existing_objects = {object.existing_object}
    end
    self.objects[#self.objects + 1] = object
    if pay_for then
      local build_cost = self.ui.hospital:getObjectBuildCost(object.object.id)
      local msg = _S.transactions.buy_object .. ": " .. object.object.name
      self.ui.hospital:spendMoney(object.qty * build_cost, msg, object.qty * build_cost)
    end
  end

  -- sort list by size of object (number of tiles in the first existing orientation (usually north))
  table.sort(self.objects, function(o1, o2)
    local orient1 = o1.object.orientations.north or o1.object.orientations.east or
                    o1.object.orientations.south or o1.object.orientations.west
    local orient2 = o2.object.orientations.north or o2.object.orientations.east or
                    o2.object.orientations.south or o2.object.orientations.west
    return #orient1.footprint > #orient2.footprint
  end)

  self.active_index = 0 -- avoid case of index changing from 1 to 1
  self:setActiveIndex(1)
  self:onCursorWorldPositionChange(self.ui:getCursorPosition(self))
end

-- precondition: self.active_index has to correspond to the object to be removed
function UIPlaceObjects:removeObject(object, dont_close_if_empty, refund)
  if refund then
    local build_cost = self.ui.hospital:getObjectBuildCost(object.object.id)
    local msg = _S.transactions.sell_object .. ": " .. object.object.name
    self.ui.hospital:receiveMoney(build_cost, msg, build_cost)
  end

  object.qty = object.qty - 1
  -- Prefer to remove objects not yet placed
  local existing_no = object.existing_objects and #object.existing_objects or 0
  if existing_no > 0 then
    if object.qty < #object.existing_objects then
      -- The object is already as good as destroyed. It is only known in this list.
      table.remove(object.existing_objects, 1)
    end
  end
  if object.qty == 0 then
    if #self.objects == 1 then
      self:clearBlueprint()
      self.object_cell_x = nil
      self.object_cell_y = nil
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
  else
    -- Make sure the correct frame is shown for the next object
    self:setOrientation(self.object_orientation)
  end
  -- Update blueprint
  self:setBlueprintCell(self.object_cell_x, self.object_cell_y)
end

function UIPlaceObjects:removeAllObjects(refund)
  -- There is surely a nicer way to implement this than the current hack. Rewrite it sometime later.
  self:setActiveIndex(1)
  for _ = 1, #self.objects do
    for _ = 1, self.objects[1].qty do
      self:removeObject(self.objects[1], true, refund)
    end
  end
end

function UIPlaceObjects:removeObjects(object_list, refund)
  -- rewrite at some point..
  if not object_list then
    object_list = {}
  end

  for _, o in ipairs(object_list) do
    for j, p in ipairs(self.objects) do
      if o.object.id == p.object.id then
        self.active_index = j
        for _ = 1, o.qty do
          self:removeObject(p, true, refund)
        end
      end
    end
  end
end

function UIPlaceObjects:close()
  self.ui:tutorialStep(1, {5, 6}, 2)
  self:removeAllObjects(true)
  self:clearBlueprint()
  self.ui:setWorldHitTest(true)
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
    self.ui:tutorialStep(1, 7, 5)
  else
    self.ui:tutorialStep(1, {5, 6}, 7)
  end
  local anims = self.anims
  local grey_scale = anims.Alt32_GreyScale
  local _, ghost = self.ui.app.gfx:loadPalette()
  for _, anim in pairs(object.idle_animations) do
    anims:setAnimationGhostPalette(anim, ghost, grey_scale)
  end
  if object.slave_type then
    for _, anim in pairs(object.slave_type.idle_animations) do
      anims:setAnimationGhostPalette(anim, ghost, grey_scale)
    end
  end

  if object.locked_to_wall then
    local wx, wy, wo = self:calculateBestPlacementPosition(0, 0)
    self.object_cell_x, self.object_cell_y = wx, wy
    self:setOrientation(wo)
  else
    self.object_orientation = "west"
    self:nextOrientation()
  end
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

  local object_data = self.objects[self.active_index]
  local object = object_data.object
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
  if object.slave_type then
    local slave_flag = flag - (flag % 2)
    local slave_anim = object.slave_type.idle_animations[orient]
    if not slave_anim then
      slave_anim = object.slave_type.idle_animations[orient_mirror[orient]]
      slave_flag = slave_flag + 1
    end
    self.object_slave_anim:setAnimation(self.anims, slave_anim, slave_flag)
  end
  local present_object
  if object_data.existing_objects and #object_data.existing_objects > 0 then
    present_object = object_data.existing_objects[1]
  end
  if present_object and present_object.current_frame then
    self.object_anim:setFrame(present_object.current_frame)
  end
  local px, py = unpack(object.orientations[orient].render_attach_position)
  if type(px) == "table" then
    px, py = unpack(px)
  end
  px, py = Map:WorldToScreen(px + 1, py + 1)
  px = object.orientations[orient].animation_offset[1] + px
  py = object.orientations[orient].animation_offset[2] + py
  self.object_anim:setPosition(px, py)
  if object.slave_type then
    px, py = unpack(object.slave_type.orientations[orient].render_attach_position)
    if type(px) == "table" then
      px, py = unpack(px)
    end
    local offset = object.orientations[orient].slave_position
    if offset then
      px = px + offset[1]
      py = py + offset[2]
    end
    px, py = Map:WorldToScreen(px + 1, py + 1)
    px = object.slave_type.orientations[orient].animation_offset[1] + px
    py = object.slave_type.orientations[orient].animation_offset[2] + py
    self.object_slave_anim:setPosition(px, py)
  end
  self:setBlueprintCell(self.object_cell_x, self.object_cell_y)
end

function UIPlaceObjects:nextOrientation()
  if not self.object_anim then
    return
  end
  local object = self.objects[self.active_index].object
  if object.locked_to_wall then
    -- Orientation is dictated by the nearest wall
    return
  end
  local orient = self.object_orientation
  repeat
    orient = orient_next[orient]
  until object.orientations[orient]
  self:setOrientation(orient)
end

function UIPlaceObjects:tryNextOrientation()
  if #self.objects > 0 then
    self.ui:playSound("swoosh.wav")
    self.objects[self.active_index].orientation_before = self.object_orientation
    self:nextOrientation()
  end
end

function UIPlaceObjects:onMouseUp(button, x, y)
  local repaint = Window.onMouseUp(self, button, x, y)

  -- We don't want to place objects because we are selecting new objects for adding in a room being built/edited
  -- Or the game is paused.
  if not self.place_objects or not self.world.user_actions_allowed then
    return
  end

  if button == "right" then
    self:tryNextOrientation()
    repaint = true
  elseif button == "left" then
    if #self.objects > 0 then
      if 0 <= x and x < self.width and 0 <= y and y < self.height then
        -- Click within window - do nothing
      elseif self.object_cell_x and self.object_cell_y and self.object_blueprint_good then
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
  if not self.place_objects then
    -- We don't want to place objects because we are selecting new objects for adding in a room being built/edited
    return
  end

  local object = self.objects[self.active_index]
  if object.object.id == "reception_desk" then self.ui:tutorialStep(1, {2, 5}, "next") end

  local real_obj
  -- There might be an existing object that has been picked up.
  if object.existing_objects and #object.existing_objects > 0 then
    real_obj = object.existing_objects[1]
    table.remove(object.existing_objects, 1)
  end
  local room = self.room or self.world:getRoom(self.object_cell_x, self.object_cell_y)
  if real_obj then
    -- If there is such an object then we don't want to make a new one, but move this one instead.
    if real_obj.orientation_before and real_obj.orientation_before ~= self.object_orientation then
      real_obj:initOrientation(self.object_orientation)
    end
    self.world:prepareFootprintTilesForBuild(real_obj.footprint, self.object_cell_x, self.object_cell_y)
    real_obj:setTile(self.object_cell_x, self.object_cell_y)
    self.world:objectPlaced(real_obj)
    if real_obj.slave then
      self.world:objectPlaced(real_obj.slave)
    end
    -- Some objects (e.g. the plant) uses this flag to avoid doing stupid things when picked up.
    real_obj.picked_up = false
    -- Machines may have smoke, recalculate it to ensure the animation is in the correct state
    if real_obj.strength then
      real_obj:calculateSmoke(room)
    end
    if class.is(real_obj, Machine) then
      real_obj:setHandymanRepairPosition(self.object_orientation)
    end
  else
    local object_footprint = object.object.orientations[self.object_orientation].footprint
    self.world:prepareFootprintTilesForBuild(object_footprint, self.object_cell_x, self.object_cell_y)
    real_obj = self.world:newObject(object.object.id,
        self.object_cell_x, self.object_cell_y, self.object_orientation)
    real_obj:setState(object.state)
  end

  if room then
    room.objects[real_obj] = true
  end

  self.ui:playSound("place_r.wav")

  self:removeObject(object, dont_close_if_empty)
  object.orientation_before = nil

  return real_obj
end

function UIPlaceObjects:draw(canvas, x, y)
  if not self.visible then
    return -- Do nothing if dialog is not visible
  end
  -- Don't show the object if the game is paused
  if self.world.user_actions_allowed then
    if not ATTACH_BLUEPRINT_TO_TILE and self.object_cell_x and self.object_anim then
      local xpos, ypos = self.ui:WorldToScreen(self.object_cell_x, self.object_cell_y)
      local zoom = self.ui.zoom_factor
      if canvas:scale(zoom) then
        xpos = math.floor(xpos / zoom)
        ypos = math.floor(ypos / zoom)
      end
      self.object_anim:draw(canvas, xpos, ypos)
      if self.objects[self.active_index].object.slave_type then
        self.object_slave_anim:draw(canvas, xpos, ypos)
      end
      canvas:scale(1)
    end
  end

  Window.draw(self, canvas, x, y)

  x, y = x + self.x, y + self.y
  self.white_font:draw(canvas, self.title_text, x + 17, y + 21, 153, 0)
  self.white_font:drawWrapped(canvas, self.desc_text, x + 20, y + 46, 147)

  for i, o in ipairs(self.objects) do
    local font = self.white_font
    local ypos = y + 136 + i * 29
    if i == self.active_index then
      font = self.blue_font
    end
    font:draw(canvas, o.object.name, x + 15, ypos, 130, 0)
    font:draw(canvas, o.qty, x + 151, ypos, 19, 0)
  end
end

function UIPlaceObjects:clearBlueprint()
  local map = self.map.th
  if self.object_anim then
    self.object_anim:setTile(nil)
  end
  if self.object_slave_anim then
    self.object_slave_anim:setTile(nil)
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
    local map = self.map.th
    if #object_footprint ~= #self.object_footprint then
      self.object_footprint = {}
      for i = 1, #object_footprint do
        self.object_footprint[i] = {}
      end
    end
    local optional_tiles = 0
    for _, tile in ipairs(object_footprint) do
      if tile.optional then
        optional_tiles = optional_tiles + 1
      end
    end
    local flags = {}
    local allgood = true
    local opt_tiles_blocked = 0
    local world = self.ui.app.world
    local player_id = self.ui.hospital:getPlayerIndex()
    local roomId = self.room and self.room.id
    local passable_flag
    local direction = self.object_orientation
    local direction_parameters =  {
      north = { x = 0, y = -1, buildable_flag = "buildableNorth", passable_flag = "travelNorth", needed_side = "need_north_side"},
      east = { x = 1, y = 0, buildable_flag =  "buildableEast", passable_flag = "travelEast", needed_side = "need_east_side"},
      south = { x = 0, y = 1, buildable_flag = "buildableSouth", passable_flag = "travelSouth", needed_side = "need_south_side"},
      west = { x = -1, y = 0, buildable_flag = "buildableWest", passable_flag = "travelWest", needed_side = "need_west_side"}
      }

    -- The given footprint tile is not usable, update the external 'allgood'
    -- variable accordingly.
    local function setAllGood(xy)
      if xy.optional then
        opt_tiles_blocked = opt_tiles_blocked + 1
        if opt_tiles_blocked >= optional_tiles then
          allgood = false
        end
      else
        allgood = false
      end
    end

    for i, tile in ipairs(object_footprint) do
      local xpos = x + tile[1]
      local ypos = y + tile[2]
      -- Check 1: Does the tile have valid map coordinates?:
      if not world:isOnMap(xpos, ypos) then
        setAllGood(tile)
        xpos = 0
        ypos = 0
      else
        local flag = "buildable"
        local good_tile = 24 + flag_alpha75
        local bad_tile = 67 + flag_alpha75
        if tile.only_passable then
          flag = "passable"
        end
        if tile.only_side then
          if object.thob == 50 and direction == "east" then
            direction = "west"
          end
          flag = direction_parameters[direction]["buildable_flag"]
          passable_flag = direction_parameters[direction]["passable_flag"]
        end

        -- Check 2: Is the tile in the object's allowed room?:
        local result = world:willObjectsFootprintTileBeWithinItsAllowedRoomIfLocatedAt(xpos, ypos, object, roomId)
        local is_object_allowed = result.within_room
        roomId = result.roomId

        -- Check 3: The footprint tile should either be buildable or passable, is it?:
        if not tile.only_side and is_object_allowed then
          is_object_allowed = world:isFootprintTileBuildableOrPassable(xpos, ypos, tile, object_footprint, flag, player_id)
        elseif is_object_allowed then
          is_object_allowed = map:getCellFlags(xpos, ypos, flags)[flag] and (player_id == 0 or flags.owner == player_id)
        end

        -- ignore placed object tile if it is shareable
        if not tile.shareable and is_object_allowed then
          -- Check 4: only one object per tile allowed original TH
          -- can build on litter and unoccupied tiles and only placeable if not on another objects passable footprint unless that too is a shareable tile
          local objchk = map:getCellFlags(xpos, ypos, flags)["thob"]
          is_object_allowed = objchk == 0 or objchk == 62 or objchk == 64 -- no object, litter/puke, ratholes
          is_object_allowed = is_object_allowed and world:isTileExclusivelyPassable(xpos, ypos, 10)
        end

        -- Having checked if the tile is good set its blueprint appearance flag:
        if is_object_allowed then
          if not tile.invisible then
            map:setCell(xpos, ypos, 4, good_tile)
          end
        else
          if not tile.invisible then
            map:setCell(xpos, ypos, 4, bad_tile)
          end
          setAllGood(tile)
        end
      end
      self.object_footprint[i][1] = xpos
      self.object_footprint[i][2] = ypos
    end
    if self.object_anim and object.class ~= "SideObject" then
      if allgood then
        if world:wouldNonSideObjectBreakPathfindingIfSpawnedAt(x, y, object, self.object_orientation, roomId) then
          if self.ui.app.config.allow_blocking_off_areas then
            print("Blocking off areas is allowed at " .. x .. ", " .. y .. ".")
          else
            allgood = false
          end
        end
      end
      if ATTACH_BLUEPRINT_TO_TILE then
        self.object_anim:setTile(map, x, y)
      end
      self.object_anim:setPartialFlag(flag_altpal, not allgood)
      self.object_slave_anim:setPartialFlag(flag_altpal, not allgood)
      self.object_blueprint_good = allgood
      self.ui:tutorialStep(1, allgood and 5 or 4, allgood and 4 or 5)
    elseif object.class == "SideObject" then
      if map:getCellFlags(x, y)[passable_flag] == true then
        local checked_x, checked_y = x, y
        if passable_flag == "travelNorth" or passable_flag == "travelSouth" then
          checked_y =  checked_y + (passable_flag == "travelNorth" and -1 or 1)
        else
          checked_x = checked_x + (passable_flag == "travelEast" and 1 or -1)
        end

        flags = {}
        flags[passable_flag] = false
        map:setCellFlags(x, y, flags)
        if not world.pathfinder:findDistance(x, y, checked_x, checked_y) then
          --we need to check if the failure to get the distance is due to the presence of an object in the adjacent tile
          if map:getCellFlags(checked_x, checked_y)["passable"] then
            if self.ui.app.config.allow_blocking_off_areas then
              print("Blocking off areas is allowed at " .. x .. ", " .. y .. ".")
            else
              allgood = false
            end
          end
        end
        flags[passable_flag] = true
        map:setCellFlags(x, y, flags)
      end
      if ATTACH_BLUEPRINT_TO_TILE then
        self.object_anim:setTile(map, x, y)
      end
      self.object_anim:setPartialFlag(flag_altpal, not allgood)
      self.object_slave_anim:setPartialFlag(flag_altpal, not allgood)
      self.object_blueprint_good = allgood
      self.ui:tutorialStep(1, allgood and 5 or 4, allgood and 4 or 5)
    end

  else
    self.object_footprint = {}
  end
end

local function NearestPointOnLine(lx1, ly1, lx2, ly2, px, py)
  -- Translate everything to make one line segment endpoint be on the origin
  local lx = lx1 - lx2
  local ly = ly1 - ly2
  px = px - lx2
  py = py - ly2

  -- Project point onto line (scale everything to make (lx, ly) be on the unit
  -- circle, then dot product).
  local d = (lx * px + ly * py) / (lx * lx + ly * ly)

  if d <= 0 then
    return lx2, ly2
  elseif d >= 1 then
    return lx1, ly1
  else
    return d * lx1 + (1 - d) * lx2, d * ly1 + (1 - d) * ly2
  end
end

function UIPlaceObjects:calculateBestPlacementPosition(x, y)
  local object = self.objects[self.active_index].object
  local room = self.room
  local wx, wy = self.ui:ScreenToWorld(self.x + x, self.y + y)
  local bestd = nil
  local bestx, besty = wx, wy
  local besto = self.object_orientation
  if room and object.locked_to_wall then
    if object.locked_to_wall.north then
      local px, py = NearestPointOnLine(room.x + 0.5, room.y + 0.5,
        room.x + room.width - 0.5, room.y + 0.5, wx, wy)
      local d = ((px - wx)^2 + (py - wy)^2)^0.5
      if not bestd or d < bestd then
        bestd, bestx, besty, besto = d, px, py, object.locked_to_wall.north
      end
    end
    if object.locked_to_wall.west then
      local px, py = NearestPointOnLine(room.x + 0.5, room.y + 0.5,
        room.x + 0.5, room.y + room.height - 0.5, wx, wy)
      local d = ((px - wx)^2 + (py - wy)^2)^0.5
      if not bestd or d < bestd then
        bestx, besty, besto = px, py, object.locked_to_wall.west
      end
    end
    -- TODO: East, South
  end
  bestx, besty = math_floor(bestx), math_floor(besty)
  if bestx < 1 or besty < 1 or
      bestx > self.map.width or besty > self.map.height then
    bestx, besty = nil, nil
  end
  return bestx, besty, besto
end

function UIPlaceObjects:onCursorWorldPositionChange(x, y)
  local repaint = Window.onCursorWorldPositionChange(self, x, y)
  if not self.place_objects then -- We don't want to place objects because we are selecting new objects for adding in a room being built/edited
    return repaint
  end

  repaint = true
  if self.world.user_actions_allowed then
    local wx, wy, wo = self:calculateBestPlacementPosition(x, y)
    if wx ~= self.object_cell_x or wy ~= self.object_cell_y then
      self:setBlueprintCell(wx, wy)
      repaint = true
    end
    if wo ~= self.object_orientation then
      self:setOrientation(wo)
      repaint = true
    end
  else
    self:clearBlueprint()
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

function UIPlaceObjects:afterLoad(old, new)
  Window.afterLoad(self, old, new)
  UIPlaceObjects.registerKeyHandlers(self)
end
