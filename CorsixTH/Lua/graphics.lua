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

local TH = require "TH"
local SDL = require "sdl"
local pathsep = package.config:sub(1, 1)
local assert, string_char, table_concat
    = assert, string.char, table.concat

class "Graphics"

function Graphics:Graphics(app)
  self.app = app
  self.target = self.app.video
  self.cache = {
    raw = {},
    tabled = {},
    palette = {},
    palette_greyscale_ghost = {},
    ghosts = {},
    anims = {},
    bitmap = {},
  }
end

function Graphics:makeGreyscaleGhost(pal)
  local entries = {}
  local remap = {}
  for i = 1, #pal, 3 do
    local entry = {pal:byte(i, i + 2)}
    entries[(i - 1) / 3] = entry
  end
  for i = 0, #entries do
    local entry = entries[i]
    local g = entry[1] * 0.299 + entry[2] * 0.587 + entry[3] * 0.114
    local g_index = 0
    local g_diff = 100000
    for j = 0, #entries do
      local entry = entries[j]
      local diff = (entry[1] - g)^2 + (entry[2] - g)^2  + (entry[3] - g)^2 
      if diff < g_diff then
        g_diff = diff
        g_index = j
      end
    end
    remap[i] = string_char(g_index)
  end
  return table_concat(remap, "", 0, 255)
end

function Graphics:loadPalette(dir, name)
  name = name or "MPalette.dat"
  if self.cache.palette[name] then
    return self.cache.palette[name],
      self.cache.palette_greyscale_ghost[name]
  end
  
  local data = self.app:readDataFile(dir or "Data", name)
  local palette = TH.palette()
  palette:load(data)
  self.cache.palette_greyscale_ghost[name] = self:makeGreyscaleGhost(data)
  self.cache.palette[name] = palette
  return palette, self.cache.palette_greyscale_ghost[name]
end

function Graphics:loadGhost(dir, name, index)
  local cached = self.cache.ghosts[name]
  if not cached then
    local data = self.app:readDataFile(dir, name)
    cached = data
    self.cache.ghosts[name] = cached
  end
  return cached:sub(index * 256 + 1, index * 256 + 256)
end

function Graphics:loadBitmap(name)
  if self.cache.bitmap[name] then
    return self.cache.bitmap[name]
  end
  
  local surface = assert(SDL.video.loadBitmap("Bitmap" .. pathsep .. name .. ".bmp", self.target))
  
  self.cache.bitmap[name] = surface
  return surface
end

function Graphics:loadRaw(name, width, height, opaque)
  if self.cache.raw[name] then
    return self.cache.raw[name]
  end
  
  local surface = assert(SDL.video.newSurface {
    data = self.app:readDataFile("QData", name .. ".dat"),
    width = width or 640,
    height = height or 480,
    depth = 8,
    target = self.target,
    transparent = not opaque,
    palette = self:loadPalette("QData", name .. ".pal"),
  })
  surface:ensureHardwareSurface()
  
  self.cache.raw[name] = surface
  return surface
end

function Graphics:loadFont(sprite_table, x_sep, y_sep)
  local font = TH.font()
  font:setSheet(sprite_table)
  font:setSeparation(x_sep or 0, y_sep or 0)
  return font
end

function Graphics:loadAnimations(dir, prefix)
  if self.cache.anims[prefix] then
    return self.cache.anims[prefix]
  end
  
  local sheet = self:loadSpriteTable(dir, prefix .. "Spr-0")
  local anims = TH.anims()
  anims:setSheet(sheet)
  if not anims:load(
  self.app:readDataFile(dir, prefix .. "Start-1.ani"),
  self.app:readDataFile(dir, prefix .. "Fra-1.ani"),
  self.app:readDataFile(dir, prefix .. "List-1.ani"),
  self.app:readDataFile(dir, prefix .. "Ele-1.ani"))
  then
    error("Cannot load animations " .. prefix)
  end
  
  self.cache.anims[prefix] = anims
  return anims
end

function Graphics:loadSpriteTable(dir, name, complex, palette)
  local cached = self.cache.tabled[name]
  if cached then
    return cached
  end
  
  local sheet = TH.sheet()
  sheet:setPalette(palette or self:loadPalette())
  local data_tab, data_dat
  if dir == "Bitmap" then
    data_tab = self.app:readBitmapDataFile(name .. ".tab")
    data_dat = self.app:readBitmapDataFile(name .. ".dat")
  else
    data_tab = self.app:readDataFile(dir, name .. ".tab")
    data_dat = self.app:readDataFile(dir, name .. ".dat")
  end
  if not sheet:load(data_tab, data_dat, complex, self.target) then
    error("Cannot load sprite sheet " .. dir .. ":" .. name)
  end
  
  self.cache.tabled[name] = sheet
  return sheet
end
