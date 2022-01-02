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

local TH = require("TH")

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

-- speed must be divider of 64 x and 32 y
local rat_dirs = {
  north = {
    anim = 1908,
    dx = 8,
    dy = -4
  },
  north_east = {
    anim = 1910,
    dx = 8,
    dy = 0
  },
  east = {
    anim = 1912,
    dx = 8,
    dy = 4
  },
  south_east = {
    anim = 1914,
    dx = 0,
    dy = 4
  },
  south = {
    anim = 1916,
    dx = -8,
    dy = 4
  },
  south_west = {
    anim = 1918,
    dx = -8,
    dy = 0
  },
  west = {
    anim = 1920,
    dx = -8,
    dy = -4
  },
  north_west = {
    anim = 1922,
    dx = 0,
    dy = -4
  },
}

Rat.hover_cursor = TheApp.gfx:loadMainCursor("kill_rat_hover")
Rat.proximity_cursor = TheApp.gfx:loadMainCursor("kill_rat")

function Rat:Rat(animation)
  self:Entity(animation)
  self.last_move_direction = "east"
  self.target = { x = 64, y = 64 }
end

function Rat:init()
  -- todo: target should be a rat hole (any?)
  local pos_x, pos_y = self:getPosition()
  self:_determinePath()
  self:_tileMovement(self.tile_x, self.tile_y, pos_x, pos_y)
end

function Rat:_determinePath()
  local path_x, path_y = self.world:getPath(self.tile_x, self.tile_y, self.target.x, self.target.y)
  local path_index = 1

  self.path = { xs = path_x, ys = path_y, index = path_index }
end

function Rat:_tileMovement(new_tile_x, new_tile_y, pos_x, pos_y)
  local next_x, next_y = self:_nextPathTile()

  if next_y < new_tile_y then
    if next_x < new_tile_x then
      self.last_move_direction = "north_west"
    elseif next_x == new_tile_x then
      self.last_move_direction = "north"
    elseif next_x > new_tile_x then
      self.last_move_direction = "north_east"
    end
  elseif next_y == new_tile_y then
    if next_x < new_tile_x then
      self.last_move_direction = "west"
    elseif next_x > new_tile_x then
      self.last_move_direction = "east"
    end
  else -- if next_y > new_tile_y
    if next_x < new_tile_x then
      self.last_move_direction = "south_west"
    elseif next_x == new_tile_x then
      self.last_move_direction = "south"
    elseif next_x > new_tile_x then
      self.last_move_direction = "south_east"
    end
  end

  self:setTilePositionSpeed(
      new_tile_x, new_tile_y, pos_x, pos_y,
      rat_dirs[self.last_move_direction].dx,
      rat_dirs[self.last_move_direction].dy)
end

function Rat:tick()
  local pos_x, pos_y = self:getPosition()

  -- determine if the attached tile should change based on whether the relative
  -- screen position is more than a tile out in any direction.
  local x, y = pos_y + pos_x - 1, pos_y - pos_x - 1
  local tile_dx = math.round(x / 64)
  local tile_dy = math.round(y / 32)

  if tile_dy ~= 0 or tile_dx ~= 0 then
    -- determine how far to reset the positions for the change in tile
    local pdx = 32 * (tile_dx - tile_dy)
    local pdy = 16 * (tile_dx + tile_dy)

    local new_tile_x = self.tile_x + tile_dx
    local new_tile_y = self.tile_y + tile_dy
    pos_x = pos_x - pdx
    pos_y = pos_y - pdy

    local next_x, next_y = self:_nextPathTile()

    if new_tile_x == next_x and new_tile_y == next_y then
      self.path.index = self.path.index + 1
    end

    self:setTilePositionSpeed(
        new_tile_x, new_tile_y, pos_x, pos_y,
        rat_dirs[self.last_move_direction].dx,
        rat_dirs[self.last_move_direction].dy)
  end
  if pos_x == 0 and pos_y == 0 then
    self:_tileMovement(self.tile_x, self.tile_y, pos_x, pos_y)
  end

  Entity.tick(self)
end

function Rat:_nextPathTile()
  return self.path.xs[self.path.index], self.path.ys[self.path.index]
end

-- Called when the rat is about to be removed from the world.
function Rat:onDestroy()
  Entity.onDestroy(self)
end

-- Save game compatibility
function Rat:afterLoad(old, new)
  Entity.afterLoad(self, old, new)
end
