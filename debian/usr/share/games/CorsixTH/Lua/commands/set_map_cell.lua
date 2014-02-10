--[[ Copyright (c) 2013 Alan Woolley

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

class "SetMapCellCommand" (Command)

function SetMapCellCommand:SetMapCellCommand(map)
  self:Command(true)
  self.map = map
  self.paint_list = {}
end

function SetMapCellCommand:addTile(x_tile, y_tile, ...)
  local old = {self.map:getCell(x_tile, y_tile)}
  table.insert(self.paint_list, #self.paint_list + 1, {x = x_tile, y = y_tile, new_flags = {...}, old_flags = old})
end

function SetMapCellCommand:perform()
  for i = 1 , #self.paint_list do
    local cell_table = self.paint_list[i]
    self.map:setCell(cell_table.x, cell_table.y, unpack(cell_table.new_flags))
  end
end

function SetMapCellCommand:undo()
  for i = #self.paint_list, 1, -1 do
    local cell_table = self.paint_list[i]
    self.map:setCell(cell_table.x, cell_table.y, unpack(cell_table.old_flags))
  end
end

