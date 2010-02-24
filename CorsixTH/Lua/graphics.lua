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
local assert, string_char, table_concat, unpack, type, pairs, ipairs
    = assert, string.char, table.concat, unpack, type, pairs, ipairs

--! Layer for loading (and subsequently caching) graphical resources.
--! The Graphics class handles loading and caching of graphics resources.
-- It can adapt as the API to C changes, and hide these changes from most of
-- the other Lua code.
class "Graphics"

local cursors_name = { 
  default = 1,
  clicked = 2,
  resize_room = 3,
  edit_room = 4,
  ns_arrow = 5,
  we_arrow = 6,
  nswe_arrow = 7,
  move_room = 8,
  sleep = 9,
  kill_rat = 10,
  kill_rat_hover = 11,
  epidemic_hover = 12,
  epidemic = 13,
  grab = 14,
  quit = 15,
  staff = 16,
  repair = 17,
  patient = 18,
  queue = 19,
}

function Graphics:Graphics(app)
  self.app = app
  self.target = self.app.video
  -- The cache is used to avoid reloading an object if it is already loaded
  self.cache = {
    raw = {},
    tabled = {},
    palette = {},
    palette_greyscale_ghost = {},
    ghosts = {},
    anims = {},
    cursors = setmetatable({}, {__mode = "k"}),
  }
  -- The load info table records how objects were loaded, and is used to
  -- persist objects as instructions on how to load them.
  self.load_info = setmetatable({}, {__mode = "k"})
  -- If the video target changes then resources will need to be reloaded
  -- (at least with some rendering engines). Note that reloading is different
  -- to loading (as in load_info), as reloading is done while the application
  -- is running, upon objects which are already loaded, whereas loading might
  -- be done with a different graphics engine, or might only need to grab an
  -- object from the cache.
  self.reload_functions = setmetatable({}, {__mode = "k"})
  -- Cursors need to be reloaded after sprite sheets, as they are created
  -- from a sprite sheet.
  self.reload_functions_cursors = setmetatable({}, {__mode = "k"})
end

function Graphics:loadMainCursor(id)
  if type(id) ~= "number" then
      id = cursors_name[id]
  end
  return self:loadCursor(self:loadSpriteTable("Data", "MPointer"), id)
end

function Graphics:loadCursor(sheet, index, hot_x, hot_y)
  local sheet_cache = self.cache.cursors[sheet]
  if not sheet_cache then
    sheet_cache = {}
    self.cache.cursors[sheet] = sheet_cache
  end
  local cursor = sheet_cache[index]
  if not cursor then
    hot_x = hot_x or 0
    hot_y = hot_y or 0
    cursor = TH.cursor()
    if not cursor:load(sheet, index, hot_x, hot_y) then
      cursor = {
        draw = function(canvas, x, y)
          sheet:draw(canvas, index, x - hot_x, y - hot_y)
        end,
      }
    else
      local function reloader(res)
        assert(res:load(sheet, index, hot_x, hot_y))
      end
      self.reload_functions_cursors[cursor] = reloader
    end
    sheet_cache[index] = cursor
    self.load_info[cursor] = {self.loadCursor, self, sheet, index, hot_x, hot_y}
  end
  return cursor
end

function Graphics:makeGreyscaleGhost(pal)
  local remap = {}
  -- Convert pal from a string to an array of palette entries
  local entries = {}
  for i = 1, #pal, 3 do
    local entry = {pal:byte(i, i + 2)} -- R, G, B at [1], [2], [3]
    entries[(i - 1) / 3] = entry
  end
  -- For each palette entry, convert it to grey and then find the nearest
  -- entry in the palette to that grey.
  for i = 0, #entries do
    local entry = entries[i]
    -- NB: g is for grey, not green
    local g = entry[1] * 0.299 + entry[2] * 0.587 + entry[3] * 0.114
    local g_index = 0
    local g_diff = 100000 -- greater than 3*63^2 (TH uses 6 bit colour channels)
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
  -- Convert remap from an array to a string
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
  self.load_info[palette] = {self.loadPalette, self, dir, name}
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

function Graphics:loadRaw(name, width, height, paldir, pal)
  if self.cache.raw[name] then
    return self.cache.raw[name]
  end
  
  width = width or 640
  height = height or 480
  local data = self.app:readDataFile("QData", name .. ".dat")
  data = data:sub(1, width * height)
  
  local bitmap = TH.bitmap()
  local palette 
  if pal and paldir then
    palette = self:loadPalette(paldir, pal)
  else
    palette = self:loadPalette("QData", name .. ".pal")
  end
  bitmap:setPalette(palette)
  assert(bitmap:load(data, width, self.target))
  local function reloader(bitmap)
    bitmap:setPalette(palette)
    local data = self.app:readDataFile("QData", name .. ".dat")
    data = data:sub(1, width * height)
    assert(bitmap:load(data, width, self.target))
  end
  self.reload_functions[bitmap] = reloader
  
  self.cache.raw[name] = bitmap
  self.load_info[bitmap] = {self.loadRaw, self, name, width, height, paldir, pal}
  return bitmap
end

function Graphics:loadFont(sprite_table, x_sep, y_sep, ...)
  -- Allow (multiple) arguments for loading a sprite table in place of the
  -- sprite_table argument.
  if type(sprite_table) == "string" then
    local arg = {sprite_table, x_sep, y_sep, ...}
    local n_pass_on_args = #arg
    for i = 2, #arg do
      if type(arg[i]) == "number" then -- x_sep
        n_pass_on_args = i - 1
        break
      end
    end
    sprite_table = self:loadSpriteTable(unpack(arg, 1, n_pass_on_args))
    if n_pass_on_args < #arg then
      x_sep, y_sep = unpack(arg, n_pass_on_args + 1, #arg)
    else
      x_sep, y_sep = nil
    end
  end
  
  local font = TH.font()
  font:setSheet(sprite_table)
  font:setSeparation(x_sep or 0, y_sep or 0)
  self.load_info[font] = {self.loadFont, self, sprite_table, x_sep, y_sep, ...}
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
  self.load_info[anims] = {self.loadAnimations, self, dir, prefix}
  return anims
end

function Graphics:loadSpriteTable(dir, name, complex, palette)
  local cached = self.cache.tabled[name]
  if cached then
    return cached
  end
  
  local sheet = TH.sheet()
  local function reloader(sheet)
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
  end
  self.reload_functions[sheet] = reloader
  reloader(sheet)
  
  self.cache.tabled[name] = sheet
  self.load_info[sheet] = {self.loadSpriteTable, self, dir, name, complex, palette}
  return sheet
end

function Graphics:updateTarget(target)
  self.target = target
  for _, res_set in ipairs{"reload_functions", "reload_functions_cursors"} do
    for resource, reloader in pairs(self[res_set]) do
      reloader(resource)
    end
  end
end

--! Utility class for setting animation markers and querying animation length.
class "AnimationManager"

function AnimationManager:AnimationManager(anims)
  self.anim_length_cache = {}
  self.anims = anims
end

function AnimationManager:getAnimLength(anim)
  local anims = self.anims
  if not self.anim_length_cache[anim] then
    local length = 0
    local seen = {}
    local frame = anims:getFirstFrame(anim)
    while not seen[frame] do
      seen[frame] = true
      length = length + 1
      frame = anims:getNextFrame(frame)
    end
    self.anim_length_cache[anim] = length
  end
  return self.anim_length_cache[anim]
end

--[[ Markers can be set using a variety of different arguments:
  setMarker(anim_number, position)
  setMarker(anim_number, start_position, end_position)
  setMarker(anim_number, keyframe_1, keyframe_1_position, keyframe_2, ...)
  
  position should be a table; {x, y} for a tile position, {x, y, "px"} for a
  pixel position, with (0, 0) being the origin in both cases.
  
  The first variant of setMarker sets the same marker for each frame.
  The second variant does linear interpolation of the two positions between
  the first frame and the last frame.
  The third variant does linear interpolation between keyframes, and then the
  final position for frames after the last keyframe. The keyframe arguments
  should be 0-based integers, as in the animation viewer.
  
  To set the markers for multiple animations at once, the anim_number argument
  can be a table, in which case the marker is set for all values in the table.
  Alternatively, the values function (defined in utility.lua) can be used in
  conjection with a for loop to set markers for multiple things.
--]]

function AnimationManager:setMarker(anim, ...)
  return self:setMarkerRaw(anim, "setFrameMarker", ...)
end

function AnimationManager:setSecondaryMarker(anim, ...)
  return self:setMarkerRaw(anim, "setFrameSecondaryMarker", ...)
end

local function TableToPixels(t)
  if t[3] == "px" then
    return t[1], t[2]
  else
    return Map:WorldToScreen(t[1] + 1, t[2] + 1)
  end
end

function AnimationManager:setMarkerRaw(anim, fn, arg1, arg2, ...)
  if type(anim) == "table" then
    for _, val in pairs(anim) do
      self:setMarkerRaw(val, fn, arg1, arg2, ...)
    end
    return
  end
  local type = type(arg1)
  local anim_length = self:getAnimLength(anim)
  local anims = self.anims
  local frame = anims:getFirstFrame(anim)
  if type == "table" then
    if arg2 then
      -- Linear-interpolation positions
      local x1, y1 = TableToPixels(arg1)
      local x2, y2 = TableToPixels(arg2)
      for i = 0, anim_length - 1 do
        local n = i / (anim_length - 1)
        anims[fn](anims, frame, (x2 - x1) * n + x1, (y2 - y1) * n + y1)
        frame = anims:getNextFrame(frame)
      end
    else
      -- Static position
      local x, y = TableToPixels(arg1)
      for i = 1, anim_length do
        anims[fn](anims, frame, x, y)
        frame = anims:getNextFrame(frame)
      end
    end
  elseif type == "number" then
    -- Keyframe positions
    local f1, x1, y1 = 0, 0, 0
    local args
    if arg1 == 0 then
      x1, y1 = TableToPixels(arg2)
      args = {...}
    else
      args = {arg1, arg2, ...}
    end
    local f2, x2, y2
    local args_i = 1
    for f = 0, anim_length - 1 do
      if f2 and f == f2 then
        f1, x1, y1 = f2, x2, y2
        f2, x2, y2 = nil
      end
      if not f2 then
        f2 = args[args_i]
        if f2 then
          x2, y2 = TableToPixels(args[args_i + 1])
          args_i = args_i + 2
        end
      end
      if f2 then
        local n = (f - f1) / (f2 - f1)
        anims[fn](anims, frame, (x2 - x1) * n + x1, (y2 - y1) * n + y1)
      else
        anims[fn](anims, frame, x1, y1)
      end
      frame = anims:getNextFrame(frame)
    end
  elseif type == "string" then
    error "TODO"
  else
    error("Invalid arguments to setMarker", 2)
  end
end
