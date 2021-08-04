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
end

function Rat:tick()
  local pos_x, pos_y = self:getPosition()

  -- determine if the attached tile should change based on whether the relative
  -- screen position is more than a tile out in any direction.
  local y = math.floor((pos_y + 16) / 32 + 1)
  local x = math.floor((pos_x + 32) / 64)
  local tile_dx, tile_dy = y + x - 1, y - x - 1

  if tile_dy ~= 0 or tile_dx ~= 0 then
    -- determine how far to reset the positions for the change in tile
    local pdx = 32 * (tile_dx - tile_dy)
    local pdy = 16 * (tile_dx + tile_dy)

    self.tile_x = self.tile_x + tile_dx
    self.tile_y = self.tile_y + tile_dy
    pos_x = pos_x - pdx
    pos_y = pos_y - pdy

    self:setTilePositionSpeed(
        self.tile_x, self.tile_y, pos_x, pos_y,
        rat_dirs[self.last_move_direction].dx,
        rat_dirs[self.last_move_direction].dy)
  end

  Entity.tick(self)
end

-- Called when the humanoid is about to be removed from the world.
function Humanoid:onDestroy()
  Entity.onDestroy(self)
end

-- Save game compatibility
function Rat:afterLoad(old, new)
  Entity.afterLoad(self, old, new)
end
