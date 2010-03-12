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

local bmp = ...
local ext = string.find(bmp, ".bmp")
if not ext then
  print("Error: Extention must must be .bmp")
  return
end
local dat, pal = string.gsub(bmp, ".bmp", ".dat"), string.gsub(bmp, ".bmp", ".pal")
local bmp, err = io.open(bmp, "rb")
if err then
  print("Error opening bitmap file: " .. err)
  return
end
dat = assert(io.open(dat, "wb"))
pal = assert(io.open(pal, "wb"))

-- Convert a little endian byte string into an integer
local function LE(s)
  local value = 0
  for n, i in ipairs{s:byte(1, #s)} do
    value = value + i * 256 ^ (n - 1)
  end
  return value
end

-- Convert an integer into a little endian byte string
local function uint4(value)
  local b0, b1, b2, b3
  b0 = value % 0x100
  value = (value - b0) / 0x100
  b1 = value % 0x100
  value = (value - b1) / 0x100
  b2 = value % 0x100
  value = (value - b2) / 0x100
  return string.char(b0, b1, b2, value)
end

local function err(msg, ...)
  error("Error processing bitmap:\n" .. msg:format(...))
end


-- bmp and dib header
if bmp:read(2) ~= "BM" or not bmp:seek("cur", 8) then
  err "Invalid header"
end
local bits_offset, header_size = LE(bmp:read(4)), LE(bmp:read(4)) -- dib header starting here (header_size)
if header_size ~= 40 then
  err "Expected BITMAPINFOHEADER"
end
local width, height = LE(bmp:read(4)), LE(bmp:read(4))
local planes, bpp = LE(bmp:read(2)), LE(bmp:read(2))
if planes ~= 1 then
  err "Expected single colour plane"
end
if bpp ~= 8 then
  err "Expected 8 bit paletted image"
end
local compression = LE(bmp:read(4))
if compression ~= 0 then
  err "Expected uncompressed image"
end
bmp:seek("cur", 12)
local pal_size = LE(bmp:read(4))
if pal_size == 0 then
  pal_size = 2 ^ bpp
end
bmp:seek("cur", 4)

-- palette
for pal_idx = 1, pal_size do
  local b = LE(bmp:read(1))
  local g = LE(bmp:read(1))
  local r = LE(bmp:read(1))
  bmp:seek("cur", 1)
  pal:write(string.char(r / 4, g / 4, b / 4))
end

-- image data
assert(bmp:seek() == bits_offset, "Invalid data offset")
local rows = {}
local skip = (4 - (width % 4)) % 4
for y = height, 1, -1 do
  rows[y] = bmp:read(width)
  bmp:seek("cur", skip)
end
dat:write(table.concat(rows))
