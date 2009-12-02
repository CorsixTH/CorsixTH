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

local function action_seek_reception_start(action, humanoid)
  local world = humanoid.world
  
  -- TODO: Look for, and then use, reception desk
  
  -- No reception desk found. One will probably be built soon, somewhere in
  -- the hospital, so either walk to the hospital, or walk around the hospital.
  local procreation
  if world.map.th:getCellFlags(humanoid.tile_x, humanoid.tile_y).hospital then
    procreation = {name = "meander", count = 1}
  else
    local _, hosp_x, hosp_y = world.pathfinder:isReachableFromHospital(humanoid.tile_x, humanoid.tile_y)
    procreation = {name = "walk", x = hosp_x, y = hosp_y}
  end
  procreation.must_happen = action.must_happen
  humanoid:queueAction(procreation, 0)
end

return action_seek_reception_start
