--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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

if select('#', ...) < 3 then
  print("Usage: lua mkfont.lua <bitmap-file> <cell-width> <cell-height> "..
        "<space-width>")
  print("Converts a bitmap which contains multiple glyphs (arranged in a "..
        "grid) into a sprite sheet (.tab and .dat) and a palette (.pal).")
  return
end

package.path = (debug.getinfo(1, "S").source:match("@(.*[" .. package.config
               :sub(1, 1) .. "])") or "") .. "lib_" .. package.config:sub(5, 5)
               .. ".lua" .. package.config:sub(3, 3) .. package.path
require "bmp"
require "spritesheet"

local bitmap_name, cell_width, cell_height, space_width = ...
cell_width = assert(tonumber(cell_width), "cell width must be a number")
cell_height = assert(tonumber(cell_height), "cell height must be a number")
space_width = tonumber(space_width) or cell_width

local bitmap = assert(bmp.open(bitmap_name))
local ncells_x = bitmap.width / cell_width
assert(ncells_x % 1 == 0, "Bitmap width must be a multiple of the cell width")
local ncells_y = bitmap.height / cell_height
assert(ncells_y % 1 == 0, "Bitmap height must be a multiple of the cell height")

local filename_base = bitmap_name:match"^(.*%.)[^.]*$"
local ss = spritesheet.open(filename_base .. "tab", filename_base .. "dat", true)

local pal = assert(io.open(filename_base .. "pal", "wb"))
pal:write(bitmap.palette)
pal:close()

ss:writeDummy()
for y = 0, ncells_y - 1 do
  for x = 0, ncells_x - 1 do
    if x == 0 and y == 0 then
      ss:write(space_width, 1, bitmap:getSubPixels(0, 0, space_width, 1))
    else
      local x, y = x * cell_width, y * cell_height
      local w, h = cell_width, cell_height
      while h > 1 do
        local is_empty = true
        for d = 0, w - 1 do
          if bitmap:getPixel(x + d, y + h - 1) ~= "\255" then
            is_empty = false
          end
        end
        if is_empty then
          h = h - 1
        else
          break
        end
      end
      while w > 1 do
        local is_empty = true
        for d = 0, h - 1 do
          if bitmap:getPixel(x + w - 1, y + d) ~= "\255" then
            is_empty = false
          end
        end
        if is_empty then
          w = w - 1
        else
          break
        end
      end
      if w == 1 and h == 1 and bitmap:getPixel(x, y) == "\255" then
        ss:writeDummy()
      else
        ss:write(w, cell_height, bitmap:getSubPixels(x, y, w, cell_height))
      end
    end
  end
end
ss:close()
