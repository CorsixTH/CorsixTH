--[[ Copyright (c) 2013 William "sadger" Gatens

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

class "EntityMap"

---@type EntityMap
local EntityMap = _G["EntityMap"]

--[[ An entity map is a structure is a 2 dimensional structure created from a
game map, it has the same dimensions as the game map which intitalises it.
The purpose of the map is store the location of entities in the map in
real-time. Each cell given by an (x,y) coordinate is a
table {humanoids ={}, objects = {}} where the tables of humanoids/objects
may be empty or contain the entity/entities that currently exist in that tile.]]
function EntityMap:EntityMap(map)
  self.width, self.height = map.th:size()
  self.entity_map = {}
  for x = 1, self.width do
    self.entity_map[x] = {}
    for y = 1, self.height do
      self.entity_map[x][y] = {humanoids = {}, objects = {}}
    end
  end
end

--[[Adds an entity to the entity map in a specified location
@param x (integer) the x coordinate of the entity
@param y (integer) the y coordinate of the entity
@param entity (Entity) the entity to be added to the map in the (x,y) position]]
function EntityMap:addEntity(x,y,entity)
  local function add_entity_to_table(entity,entity_table)
    entity_table[#entity_table+1] = entity
  end
  -- Distinguish between entity types and add them
  -- to the respective tables
  if x and y and entity then
    if class.is(entity,Humanoid) then
      add_entity_to_table(entity,self:getHumanoidsAtCoordinate(x,y))
    elseif class.is(entity, Object) then
      add_entity_to_table(entity, self:getObjectsAtCoordinate(x,y))
    end
  end
end

--[[Removes an entity from the entity map given specified location
Assumes the entity already has been added in the (x,y) position or will cause
the assertion that the entity is contained in the map to fail.
@param x (integer) the x coordinate of the entity
@param y (integer) the y coordinate of the entity
@param entity (Entity) the entity to be removed from the map in the (x,y) position ]]
function EntityMap:removeEntity(x,y,entity)
  -- Iterates through a table and removes the given entity
  local function remove_entity_from_table(entity, entity_table)
    local index = -1
    for i, h in ipairs(entity_table) do
      if h == entity then
        -- If we have found it no need to keep looking
        index = i
        break
      end
    end
    -- We haven't found it so we have incorrectly tried to remove it
    assert(index ~= -1, "Tried to remove entity from entity_map - entity not found")
    table.remove(entity_table,index)
  end

  -- Distinguish between entity types to find table to remove from
  -- then remove the entity from that table
  if x and y and entity then
    if class.is(entity,Humanoid) then
      remove_entity_from_table(entity, self:getHumanoidsAtCoordinate(x,y))
    elseif class.is(entity, Object) then
      remove_entity_from_table(entity,self:getObjectsAtCoordinate(x,y))
    end
  end
end


--[[Returns a map of all entities (objects and humanoids) at a specified coordinate
@param x (integer) the x coordinate to retrieve entities from
@param y (integer) the y coordinate to retrieve entities from
@return entity_map (table) containing the entities at the (x,y) coordinate ]]
function EntityMap:getEntitiesAtCoordinate(x,y)
  --Add all the humanoids
  local entity_table = {}
  for _, obj in ipairs(self:getHumanoidsAtCoordinate(x,y)) do
    table.insert(entity_table,obj)
  end

  --Add all the objects
  for _, obj in ipairs(self:getObjectsAtCoordinate(x,y)) do
    table.insert(entity_table,obj)
  end

  return entity_table
end

--[[Returns a table of all humanoids at a specified coordinate
@param x (integer) the x coordinate to retrieve entities from
@param y (integer) the y coordinate to retrieve entities from
@return (table) containing the humanoids at the (x,y) coordinate ]]
function EntityMap:getHumanoidsAtCoordinate(x,y)
  assert(x >= 1 and y >= 1 and x <= self.width and y <= self.height,
  "Coordinate requested is out of the entity map bounds")
  return self.entity_map[x][y]["humanoids"]
end

--[[Returns a table of all objects at a specified coordinate
@param x (integer) the x coordinate to retrieve entities from
@param y (integer) the y coordinate to retrieve entities from
@return (table) containing the objects at the (x,y) coordinate ]]
function EntityMap:getObjectsAtCoordinate(x,y)
  assert(x >= 1 and y >= 1 and x <= self.width and y <= self.height,
  "Coordinate requested is out of the entity map bounds")
  return self.entity_map[x][y]["objects"]
end


--[[ Returns a map of coordinates {{x1,y1}, ... {xn,yn}} directly
adjacent to a given (x,y) coordinate - no diagonals
@param x (integer) the x coordinate to obtain adjacent tiles from
@param y (integer) the y coordinate to obtain adjacent tiles from ]]
function EntityMap:getAdjacentSquares(x,y)
  -- Table of coordinates {x=integer, y=integer} representing (x,y) coordinates
  local adjacent_squares = {}
  if x and y then
    if x ~= 1 then
      adjacent_squares[#adjacent_squares+1] = {x = x-1, y = y}
    end
    if x ~= self.width then
      adjacent_squares[#adjacent_squares+1] = {x = x+1, y = y}
    end
    if y ~= 1 then
      adjacent_squares[#adjacent_squares+1] = {x = x, y = y-1}
    end
    if y ~= self.height then
      adjacent_squares[#adjacent_squares+1] = {x = x, y = y+1}
    end
  end
  return adjacent_squares
end

--[[ Returns all the entities which are patients in the squares directly adjacent
to the given (x,y) coordinate - diagonals are not considered
@param x (integer) the x coordinate to obtain adjacent patients from
@param y (integer) the y coordinate to obtain adjacent patients from ]]
function EntityMap:getPatientsInAdjacentSquares(x,y)
  local adjacent_patients = {}
  for _, coord in ipairs(self:getAdjacentSquares(x,y)) do
    for _, humanoid in ipairs(self:getHumanoidsAtCoordinate(coord['x'],coord['y'])) do
      if class.is(humanoid,Patient) then
        adjacent_patients[#adjacent_patients+1] = humanoid
      end
    end
  end
  return adjacent_patients
end

--[[ Returns a map of coordinates {{x1,y1}, ... {xn,yn}} of
the adjacent tiles (no diagonals) which do not contain any humanoids or objects
does NOT determine if the tile is reachable from (x,y)  may even be in a
different room
@param x (integer) the x coordinate to obtain free tiles from
@param y (integer) the y coordinate to obtain free tiles from ]]
function EntityMap:getAdjacentFreeTiles(x,y)
  local adjacent_free_tiles = {}
  for _, coord in ipairs(self:getAdjacentSquares(x,y)) do
    local x_coord = coord['x']
    local y_coord = coord['y']
    -- If no object or humanoid occupy the til_coorde
    if self:getHumanoidsAtCoordinate(x_coord,y_coord) == nil and
      self:getObjectsAtCoordinate(x_coord,y_coord) == nil then
      adjacent_free_tiles[#adjacent_free_tiles+1] = coord
    end
  end
  return adjacent_free_tiles
end

