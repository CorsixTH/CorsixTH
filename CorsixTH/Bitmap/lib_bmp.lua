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

local io_open, table_concat, setmetatable, ipairs, string_reverse, string_char
    = io.open, table.concat, setmetatable, ipairs, string.reverse, string.char
local math_floor
    = math.floor

module "bmp"
local mt = {__index = _M}

-- Convert a little endian byte string into an integer
local function LE(s)
  local value = 0
  for n, i in ipairs{s:byte(1, #s)} do
    value = value + i * 256 ^ (n - 1)
  end
  return value
end

function open(filename)
  local file, err = io_open(filename, "rb")
  if not file then
    return nil, err
  end
  if file:read(2) ~= "BM" or not file:seek("cur", 8) then
    return nil, "Invalid header"
  end
  local bits_offset, header_size = LE(file:read(4)), LE(file:read(4))
  if header_size ~= 40 then
    return nil, "Expected BITMAPINFOHEADER"
  end
  local width, height = LE(file:read(4)), LE(file:read(4))
  local planes, bpp = LE(file:read(2)), LE(file:read(2))
  if planes ~= 1 then
    return nil, "Expected single colour plane"
  end
  if bpp ~= 8 then
    return nil, "Expected 8 bit paletted image"
  end
  local compression = LE(file:read(4))
  if compression ~= 0 then
    return nil, "Expected uncompressed image"
  end
  file:seek("cur", 12)
  local pal_size = LE(file:read(4))
  if pal_size == 0 then
    pal_size = 2 ^ bpp
  end
  file:seek("cur", 4)
  local palette = {}
  for pal_idx = 1, pal_size do
    local bgr = file:read(3)
    file:seek("cur", 1)
    palette[pal_idx] = convertPal(bgr)
  end
  return setmetatable({
    file = file,
    bits_offset = bits_offset,
    width = width,
    height = height,
    pal_size = pal_size,
    palette = table_concat(palette),
  }, mt)
end

function getPixel(bmp, x, y)
  local file, width = bmp.file, bmp.width
  if x < 0 or y < 0 or x >= width or y >= bmp.height then
    return nil, "Invalid pixel"
  end
  local stride = width + ((4 - (width % 4)) % 4)
  local offset = (bmp.height - 1 - y) * stride + x
  if not file:seek("set", bmp.bits_offset + offset) then
    return nil, "Invalid data offset"
  end
  return file:read(1)
end

function getPixels(bmp)
  local file, width = bmp.file, bmp.width
  if not file:seek("set", bmp.bits_offset) then
    return nil, "Invalid data offset"
  end
  local rows = {}
  local skip = (4 - (width % 4)) % 4
  for y = bmp.height, 1, -1 do
    rows[y] = file:read(width)
    file:seek("cur", skip)
  end
  return table_concat(rows)
end

function getSubPixels(bmp, x, y, w, h)
  local file, width = bmp.file, bmp.width
  local stride = width + ((4 - (width % 4)) % 4)
  local offset = (bmp.height - y - h) * stride + x
  if not file:seek("set", bmp.bits_offset + offset) then
    return nil, "Invalid data offset"
  end
  local rows = {}
  local skip = stride - w
  for y = h, 1, -1 do
    rows[y] = file:read(w)
    file:seek("cur", skip)
  end
  return table_concat(rows)
end

function convertPal(data)
  return (data:gsub("...", string_reverse):gsub(".", function(c)
    return string_char(math_floor(c:byte() / 255 * 63 + 0.5))
  end))
end
