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

local io_open, assert, setmetatable, string_char, table_concat
    = io.open, assert, setmetatable, string.char, table.concat

module "spritesheet"
local mt = {__index = _M}

function open(filename_tab, filename_dat, is_complex)
  return setmetatable({
    tab = assert(io_open(filename_tab, "wb")),
    dat = assert(io_open(filename_dat, "wb")),
    encode = is_complex and encodeComplex or encodeSimple,
  }, mt)
end

function close(ss)
  ss.tab:close()
  ss.dat:close()
  return ss
end

function writeDummy(ss)
  ss.tab:write"\0\0\0\0\0\0"
  return ss
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
  return string_char(b0, b1, b2, value)
end

function write(ss, width, height, pixels)
  ss.tab:write(uint4(ss.dat:seek()))
  ss.tab:write(string_char(width, height))
  ss.dat:write(ss.encode(width, height, pixels))
  return ss
end

function encodeSimple(width, height, data)
  error "TODO"
end

function encodeComplex(width, height, data)
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
        result[#result + 1] = string_char(i - run_start)
        result[#result + 1] = data:sub(run_start, i - 1)
      end
    else
      if run_byte == 0xFF then
        while i - run_start >= 63 do
          result[#result + 1] = "\191"
          run_start = run_start + 63
        end
        if i ~= run_start then
          result[#result + 1] = string_char(i - run_start + 128)
        end
      else
        while i - run_start >= 255 do
          result[#result + 1] = "\255\255"
          result[#result + 1] = string_char(run_byte)
          run_start = run_start + 255
        end
        if i ~= run_start then
          local d = i - run_start
          if 4 <= d and d <= 67 then
            result[#result + 1] = string_char(d + 60)
            result[#result + 1] = string_char(run_byte)
          elseif 68 <= d and d <= 130 then
            result[#result + 1] = string_char(d + 124)
            result[#result + 1] = string_char(run_byte)
          else
            result[#result + 1] = "\255"
            result[#result + 1] = string_char(d)
            result[#result + 1] = string_char(run_byte)
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
  return table_concat(result)
end
