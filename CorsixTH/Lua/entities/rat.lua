--[[ Copyright (c) 2021 Stephen "TheCycoONE" Baker

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

--! A `Rat` which runs from hole to hole
class "Rat" (Entity)

---@type Rat
local Rat = _G["Rat"]

-- anims
-- rat moving north: 1908 (4)
-- rat moving north east: 1910 (9)
-- rat moving east: 1912 (4)
-- rat moving south east: 1914 (4)
-- rat moving south: 1916 (4)
-- rat moving south west: 1918 (4)
-- rat moving west: 1920 (4)
-- rat moving north west: 1922 (4)

-- rat entering hole to north: 1924 (4)
-- rat entering hole to west: 1926 (4)

-- rat leaving hole from north: 1928 (3)

-- rat hole north: 1904
-- dead rat splat: 2242

-- The rat has a dedicated animation for each tile direction it can walk in.
-- Paths from the pathfinder are 4-connected, so only the cardinals are needed.
local rat_walk_anims = {
  north = 1908,
  east = 1912,
  south = 1916,
  west = 1920,
}

-- Hole animations. Only north-wall holes have a "leaving" animation, so it is
-- reused for every emergence; entering uses the animation for the hole's wall.
local rat_leave_hole_anim = 1928
local rat_enter_hole_anims = {north = 1924, west = 1926}

-- Rats scurry at roughly twice humanoid walking speed. One tile is crossed over
-- `walk_quantity` ticks at `4 * walk_factor` px/tick; walk_factor * walk_quantity
-- must equal 8 or the movement glitches (see humanoid_actions/walk.lua, where the
-- same 2x is the "fast" preset).
local walk_factor = 2
local walk_quantity = 4

-- Rats don't head straight home; they dart to a few random nearby tiles first
-- before finally running into a hole.
local min_wander_legs = 3
local max_wander_legs = 7
local wander_radius = 5 -- tiles from the current position for a random dart

local rat_bounty = 5 -- cash awarded for shooting a rat

Rat.hover_cursor = TheApp.gfx:loadMainCursor("kill_rat_hover")
Rat.proximity_cursor = TheApp.gfx:loadMainCursor("kill_rat")

function Rat:Rat(animation)
  self:Entity(animation)
  self.last_move_direction = "east"
  -- Use a bounding-box hit test so the small, moving rat can be clicked.
  self.permanent_flags = DrawFlags.BoundBoxHitTest
end

--! Start the rat scurrying from its current tile towards a target tile. If no
-- target is given, a random rathole (or, failing that, a random reachable tile)
-- is chosen so the rat runs somewhere sensible.
--!param target_x (integer, optional) Destination tile X coordinate.
--!param target_y (integer, optional) Destination tile Y coordinate.
function Rat:init(target_x, target_y)
  local target_wall
  if not target_x or not target_y then
    target_x, target_y, target_wall = self:_chooseTarget()
  end
  -- Nowhere sensible to run to: the rat just disappears again.
  if target_x == self.tile_x and target_y == self.tile_y then
    self.world:destroyEntity(self)
    return
  end
  self.target = {x = target_x, y = target_y, wall = target_wall}
  self.wander_legs = math.random(min_wander_legs, max_wander_legs)
  self:_emerge()
end

--! Play the "leaving hole" animation, then start scurrying.
function Rat:_emerge()
  self:setSpeed(0, 0)
  self:setAnimation(rat_leave_hole_anim)
  local duration = TheApp.animation_manager:getAnimLength(rat_leave_hole_anim)
  self:setTimer(duration, --[[persistable:rat_emerged]] function(rat)
    rat:_startNextLeg()
  end)
end

--! Begin the next leg of the rat's journey: a random nearby dart while it still
-- has wandering to do, otherwise the final run to its target hole. On arrival at
-- a real rathole the rat enters it; otherwise it simply disappears.
function Rat:_startNextLeg()
  if self.wander_legs > 0 then
    self.wander_legs = self.wander_legs - 1
    local dx, dy = self:_chooseWanderTile()
    self:_determinePath(dx, dy)
    if self.path and self.path.xs[2] then
      self:_walkToNextTile()
      return
    end
    -- Couldn't dart anywhere; give up wandering and head for the hole.
    self.wander_legs = 0
  end

  self:_determinePath(self.target.x, self.target.y)
  if self.path and self.path.xs[2] then
    self:_walkToNextTile()
    return
  end

  if self.target.wall and self.tile_x == self.target.x and
      self.tile_y == self.target.y then
    self:_enterHole()
  else
    self.world:destroyEntity(self)
  end
end

--! Pick a random reachable tile within `wander_radius` of the rat for an erratic
-- dart. Falls back to the final target if nothing nearby is reachable.
--!return (integer, integer) The chosen dart tile coordinates.
function Rat:_chooseWanderTile()
  local map = self.world.map
  local hospital = self.world:getLocalPlayerHospital()
  for _ = 1, 10 do
    local tx = self.tile_x + math.random(-wander_radius, wander_radius)
    local ty = self.tile_y + math.random(-wander_radius, wander_radius)
    if tx >= 1 and ty >= 1 and tx <= map.width and ty <= map.height and
        (tx ~= self.tile_x or ty ~= self.tile_y) and
        hospital:isInHospital(tx, ty) then
      local path_x, path_y = self.world:getPath(self.tile_x, self.tile_y, tx, ty)
      if path_x and #path_x > 1 and self:_isCorridorPath(path_x, path_y) then
        return tx, ty
      end
    end
  end
  return self.target.x, self.target.y
end

--! Pick a destination for the rat: a random rathole if any exist, otherwise a
-- random reachable tile. Returns the rat's own tile if nothing is reachable.
--!return (integer, integer, string or nil) The chosen target tile, plus the
--!  hole's wall ("north"/"west") when the target is a rathole.
function Rat:_chooseTarget()
  local hospital = self.world:getLocalPlayerHospital()
  local holes = hospital and hospital.ratholes
  if holes and #holes > 0 then
    -- Prefer running to a different hole than the one we started on.
    local candidates = {}
    for _, hole in ipairs(holes) do
      if hole.x ~= self.tile_x or hole.y ~= self.tile_y then
        candidates[#candidates + 1] = hole
      end
    end
    if #candidates == 0 then candidates = holes end
    local hole = candidates[math.random(1, #candidates)]
    return hole.x, hole.y, hole.wall
  end

  local map = self.world.map
  for _ = 1, 10 do
    local tx, ty = math.random(1, map.width), math.random(1, map.height)
    if hospital:isInHospital(tx, ty) then
      local path_x = self.world:getPath(self.tile_x, self.tile_y, tx, ty)
      if path_x and #path_x > 0 then
        return tx, ty
      end
    end
  end
  return self.tile_x, self.tile_y
end

--! Whether every tile on the given path is corridor (not inside a room), so the
-- rat stays out of rooms and never squeezes through closed doors -- matching the
-- original game, where rats scurry only in corridors.
--!param xs (list) Path tile X coordinates.
--!param ys (list) Path tile Y coordinates.
--!return (boolean) True if the whole path runs through corridor tiles.
function Rat:_isCorridorPath(xs, ys)
  local th = self.world.map.th
  for i = 1, #xs do
    if th:getCellFlags(xs[i], ys[i]).roomId ~= 0 then
      return false
    end
  end
  return true
end

--! Compute and store a path from the rat's tile to the given destination.
--!param dest_x (integer) Destination tile X coordinate.
--!param dest_y (integer) Destination tile Y coordinate.
function Rat:_determinePath(dest_x, dest_y)
  local path_x, path_y = self.world:getPath(self.tile_x, self.tile_y,
      dest_x, dest_y)
  if not path_x or #path_x == 0 or not self:_isCorridorPath(path_x, path_y) then
    self.path = nil
    return
  end
  self.path = {xs = path_x, ys = path_y, index = 1}
end

--! Walk the rat one tile further along its path, mirroring how humanoids move
-- (see `action_walk_raw`). The rat animates across a single tile over
-- `walk_quantity` ticks, then this runs again for the following tile until the
-- destination hole is reached. Keeping the tile position authoritative means
-- the rat stays clickable and detectable on the entity map.
function Rat:_walkToNextTile()
  local xs, ys = self.path.xs, self.path.ys
  local i = self.path.index
  local x1, y1 = xs[i], ys[i]
  local x2, y2 = xs[i + 1], ys[i + 1]

  if not x2 then
    -- Reached the end of this leg. Snap cleanly to the arrival tile and carry
    -- straight on -- rats scurry continuously rather than pausing.
    self:setTilePositionSpeed(x1, y1)
    self:_startNextLeg()
    return
  end

  if x1 < x2 then
    self.last_move_direction = "east"
    self:setAnimation(rat_walk_anims.east)
    self:setTilePositionSpeed(x2, y2, -32, -16, 4 * walk_factor, 2 * walk_factor)
  elseif x1 > x2 then
    self.last_move_direction = "west"
    self:setAnimation(rat_walk_anims.west)
    self:setTilePositionSpeed(x1, y1, 0, 0, -4 * walk_factor, -2 * walk_factor)
  elseif y1 < y2 then
    self.last_move_direction = "south"
    self:setAnimation(rat_walk_anims.south)
    self:setTilePositionSpeed(x2, y2, 32, -16, -4 * walk_factor, 2 * walk_factor)
  else
    self.last_move_direction = "north"
    self:setAnimation(rat_walk_anims.north)
    self:setTilePositionSpeed(x1, y1, 0, 0, 4 * walk_factor, -2 * walk_factor)
  end

  self:setTimer(walk_quantity, --[[persistable:rat_walk_tick]] function(rat)
    rat.path.index = rat.path.index + 1
    rat:_walkToNextTile()
  end)
end

--! Play the entering-hole animation for the target hole's wall, then remove the
-- rat from the world.
function Rat:_enterHole()
  self:setSpeed(0, 0)
  local anim = rat_enter_hole_anims[self.target.wall] or rat_enter_hole_anims.north
  self:setAnimation(anim)
  local duration = TheApp.animation_manager:getAnimLength(anim)
  self:setTimer(duration, --[[persistable:rat_entered]] function(rat)
    rat.world:destroyEntity(rat)
  end)
end

--! Shoot the rat when it is left-clicked: play the sounds, reward the player,
-- leave a dead-rat splat, and remove the rat. Guarded so a stale cursor entity
-- cannot shoot the same rat twice.
--!param ui (GameUI) The game UI.
--!param button (string) The mouse button used.
function Rat:onClick(ui, button)
  if button ~= "left" or self.shot then
    return
  end
  self.shot = true
  ui:playSound("shotgun.wav")
  ui:playSound("deadrat2.wav")
  local hospital = self.hospital or self.world:getLocalPlayerHospital()
  hospital:receiveMoney(rat_bounty, _S.transactions.rats)
  local tile_x, tile_y = self.tile_x, self.tile_y
  local px, py = self.th:getPosition()
  self.world:destroyEntity(self)
  local splat = self.world:newObject("litter", tile_x, tile_y)
  splat:setLitterType("dead_rat")
  splat:setPosition(px, py)
end
