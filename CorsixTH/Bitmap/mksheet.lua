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

-- Creates a dat and tab file from a given specification file to combine multiple BMP
-- images into a single spritesheet for use with Graphics:loadSpriteTable
-- file: the spec to instruct what the spritesheet will contain. See example.spec
-- for a template

-- FIXME: BMP images and the output files must be located at the same directory of the
-- program used to execute this. Ideally, they should all be in the location of the
-- .spec file
function makeSheet(file)
  if not file then
    print "Usage: lua mksheet.lua <spec-file>"
    print "Converts a number of bitmaps into a sprite sheet using the given spec"
    return
  end

  package.path = (debug.getinfo(1, "S").source:match("@(.*[" .. package.config
                 :sub(1, 1) .. "])") or "") .. "lib_" .. package.config:sub(5, 5)
                 .. ".lua" .. package.config:sub(3, 3) .. package.path
  local bmp = require("lib_bmp")
  local spritesheet = require("lib_spritesheet")

  local specfile = file
  specfile = assert(dofile(specfile))
  local spec = specfile

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

  local ss = spritesheet.open(spec.output_tab, spec.output_dat, spec.complex)

  for i = 0, #spec.sprites do
    local filename = spec.sprites[i]
    if not filename then
      spritesheet.writeDummy(ss)
    else
      local function err(msg, ...)
        error("Error processing " .. filename .. ":\n" .. msg:format(...))
      end
      local bitmap, e = bmp.open(filename)
      if not bitmap then
        err(e)
      end
      local width, height = bitmap.width, bitmap.height
      if width > 0xFF or height > 0xFF then
        err "Image too big (maximum size is 255x255)"
      end
      spritesheet.write(ss, width, height, bmp.getPixels(bitmap))
    end
  end
  spritesheet.close(ss)
end
