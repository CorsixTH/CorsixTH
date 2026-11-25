---@meta _

---@class OptWallDirTiles
---@field north? integer
---@field west? integer
local OptWallDirTiles

---@class WallDirTiles: OptWallDirTiles
---@field north integer
---@field west integer
local WallDirTiles = {}

---@class ExtendedWallDirTiles: WallDirTiles
---@field [string] integer
local ExtendedWallDirTiles = {}

---@class WallSwingTiles
---@field north_left integer
---@field west_left integer
---@field north_right integer
---@field west_right integer
local WallSwingTiles = {}

---@class Wall
---@field id string
---@field inside_tiles WallDirTiles
---@field outside_tiles WallDirTiles
---@field window_tiles OptWallDirTiles
local Wall = {}

---@class InteriorWall: Wall
---@field window_tiles WallDirTiles
---@field swing_inside_tiles WallSwingTiles
---@field swing_outside_tiles WallSwingTiles
local InteriorWall = {}

---@class ExteriorWall: Wall
---@field inside_tiles ExtendedWallDirTiles
---@field outside_tiles ExtendedWallDirTiles
local ExteriorWall = {}
