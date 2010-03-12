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

if not ... then
  print "Usage: lua mksheet.lua <spec-file>"
  print "Converts a number of bitmaps into a sprite sheet using the given spec"
  return
end

local specfile = ...
specfile = assert(loadfile(specfile))
local spec = {}
setfenv(specfile, spec)()

assert(type(spec.sprites) == "table", "spec is missing sprite list")
local required_fields = {
  palette = {
    ["from bitmap"] = true,
  },
  complex = {
    [true] = true,
    -- [false] = true, -- Not yet supported
  },
  rnc = {
    -- [true] = true, -- Not yet supported
    [false] = true,
  },
  output_tab = true,
  output_dat = true,
}
for field, options in pairs(required_fields) do
  assert(spec[field] ~= nil, "spec is missing '" .. field .. "' field")
  if options ~= true then
    assert(options[spec[field]], "spec field '" .. field .. "' is invalid")
  end
end

local function encode_complex(width, height, data)
  local result = {}
  local run_start = 1
  local run_byte = false
  local prev = false
  local function flush_run(i)
    if run_byte == false then
      while i - run_start > 63 do
        result[#result + 1] = "\63"
        result[#result + 1] = data:sub(run_start, run_start + 62)
        run_start = run_start + 63
      end
      if i ~= run_start then
        result[#result + 1] = string.char(i - run_start)
        result[#result + 1] = data:sub(run_start, i - 1)
      end
    else
      if run_byte == 0xFF then
        while i - run_start >= 63 do
          result[#result + 1] = "\191"
          run_start = run_start + 63
        end
        if i ~= run_start then
          result[#result + 1] = string.char(i - run_start + 128)
        end
      else
        while i - run_start >= 255 do
          result[#result + 1] = "\255\255"
          result[#result + 1] = string.char(run_byte)
          run_start = run_start + 255
        end
        if i ~= run_start then
          local d = i - run_start
          if 4 <= d and d <= 67 then
            result[#result + 1] = string.char(d + 60)
            result[#result + 1] = string.char(run_byte)
          elseif 68 <= d and d <= 130 then
            result[#result + 1] = string.char(d + 124)
            result[#result + 1] = string.char(run_byte)
          else
            result[#result + 1] = "\255"
            result[#result + 1] = string.char(d)
            result[#result + 1] = string.char(run_byte)
          end
        end
      end
      run_byte = false
    end
    run_start = i
  end
  for i = 2, #data, 1 do
    local byte = data:byte(i)
    if run_byte then
      if byte ~= run_byte then
        flush_run(i)
      end
    elseif byte == prev and i - run_start >= 4 and data:byte(i - 3) == byte and data:byte(i - 2) == byte then
      flush_run(i - 3)
      run_byte = byte
    end
    prev = byte
  end
  flush_run(#data + 1)
  return table.concat(result)
end
local encode = spec.complex and encode_complex or encode_simple

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

local tab = assert(io.open(spec.output_tab, "wb"))
local dat = assert(io.open(spec.output_dat, "wb"))

for i = 0, table.maxn(spec.sprites) do
  local bitmap = spec.sprites[i]
  if not bitmap then
    tab:write"\0\0\0\0\0\0"
  else
    local data = assert(io.open(bitmap, "rb"))
    local function err(msg, ...)
      error("Error processing " .. bitmap .. ":\n" .. msg:format(...))
    end
    if data:read(2) ~= "BM" or not data:seek("cur", 8) then
      err "Invalid header"
    end
    local bits_offset, header_size = LE(data:read(4)), LE(data:read(4))
    if header_size ~= 40 then
      err "Expected BITMAPINFOHEADER"
    end
    local width, height = LE(data:read(4)), LE(data:read(4))
    if width > 0xFF or height > 0xFF then
      err "Image too big (maximum size is 255x255)"
    end
    tab:write(uint4(dat:seek()))
    tab:write(string.char(width, height))
    local planes, bpp = LE(data:read(2)), LE(data:read(2))
    if planes ~= 1 then
      err "Expected single colour plane"
    end
    if bpp ~= 8 then
      err "Expected 8 bit paletted image"
    end
    local compression = LE(data:read(4))
    if compression ~= 0 then
      err "Expected uncompressed image"
    end
    data:seek("cur", 12)
    local pal_size = LE(data:read(4))
    if pal_size == 0 then
      pal_size = 2 ^ bpp
    end
    if not data:seek("set", bits_offset) then
      err "Invalid data offset"
    end
    local rows = {}
    local skip = (4 - (width % 4)) % 4
    for y = height, 1, -1 do
      rows[y] = data:read(width)
      data:seek("cur", skip)
    end
    dat:write(encode(width, height, table.concat(rows)))
  end
end
