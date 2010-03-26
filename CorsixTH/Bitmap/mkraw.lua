--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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

if not ... then
  print "Usage: lua mkraw.lua <bitmap-file>"
  print "Converts a bitmap into a raw .dat file and a .pal file"
  return
end

package.path = (debug.getinfo(1, "S").source:match("@(.*[" .. package.config
               :sub(1, 1) .. "])") or "") .. "lib_" .. package.config:sub(5, 5)
               .. ".lua" .. package.config:sub(3, 3) .. package.path
require "bmp"

local filename = ...
if not filename:match("%.bmp$") then
  print("Error: Extension must must be .bmp")
  return
end
local filename_base = filename:match"^(.*%.)[^.]*$"
local dat, pal = filename_base .."dat", filename_base .. "pal"
local bitmap = assert(bmp.open(filename))
dat = assert(io.open(dat, "wb"))
pal = assert(io.open(pal, "wb"))

-- palette
pal:write(bitmap.palette)

-- image data
dat:write(assert(bitmap:getPixels()))

if bitmap.pal_size ~= 256 then
  print("Warning: palette size is " .. bitmap.pal_size .. ". Currently only palettes of size 256 will work in CorsixTH.")
end
