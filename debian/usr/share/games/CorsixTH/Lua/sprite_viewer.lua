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

-- This is a poor replacement for the sprite viewing facility of AnimView, but
-- when you don't have a copy of AnimView, or the means to compile it, then a
-- crude sprite viewer is better than no sprite viewer.

local app = TheApp
local lfs = require"lfs"
local gfx = app.gfx
gfx.cache.tabled = {}
local font = gfx:loadFont("QData", "Font00V")
local need_draw = true
local sprite_table_paths = {}
local sprite_table_index
local sprite_table
local is_complex = false
local wdown = false
local sdown = false
local y_off
local old_event_handlers

for _, dir in ipairs{"Data", "QData", "DataM", "QDataM"} do
  for item in pairs(app.fs:listFiles(dir) or {}) do
    if item:match"%.TAB$" then
      sprite_table_paths[#sprite_table_paths + 1] = {dir, item:sub(1, -5)}
    end
  end
end
table.sort(sprite_table_paths, function(lhs, rhs)
  return lhs[1] < rhs[1] or (lhs[1] == rhs[1] and lhs[2] < rhs[2])
end)

local function LoadTable(n, complex)
  sprite_table_index = n
  is_complex = complex
  local path = sprite_table_paths[n]
  local pal
  if app.fs:readContents(path[1], path[2] .. ".PAL") then
    pal = gfx:loadPalette(path[1], path[2] .. ".PAL")
  end
  sprite_table = gfx:loadSpriteTable(path[1], path[2], complex, pal)
  need_draw = true
  y_off = 0
end
LoadTable(1, false)

local function DoKey(self, code)
  if code == string.byte"c" then
    gfx.cache.tabled = {}
    LoadTable(sprite_table_index, not is_complex)
  elseif code == string.byte"a" then
    if sprite_table_index > 1 then
      LoadTable(sprite_table_index - 1, is_complex)
    end
  elseif code == string.byte"d" then
    if sprite_table_index < #sprite_table_paths then
      LoadTable(sprite_table_index + 1, is_complex)
    end
  elseif code == string.byte"w" then
    wdown = true
    need_draw = true
  elseif code == string.byte"s" then
    sdown = true
    need_draw = true
  elseif code == string.byte"q" then
    app.eventHandlers = old_event_handlers
    need_draw = false
  end
  return need_draw
end

local function DoKeyUp(self, code)
    if code == string.byte"w" then
        wdown = false
    end
    if code == string.byte"s" then
        sdown = false
    end
end

local function Render(canvas)
  local encoding = is_complex and " (Complex)" or " (Simple)"
  local msg = table.concat(sprite_table_paths[sprite_table_index], package.config:sub(1, 1)) .. encoding
  local _, fonth = font:sizeOf(msg)
  local sep = 2
  local y = y_off
  font:draw(canvas, "CorsixTH Debug Sprite Viewer - W/A/S/D to navigate, C to change mode, Q to quit", 0, y)
  y = y + fonth + sep
  font:draw(canvas, msg, 0, y)
  y = y + fonth + sep
  local x = 0
  local sw, sh = app.config.width, app.config.height
  local tallest = 0
  for i = 0, #sprite_table - 1 do
    local w, h = sprite_table:size(i)
    local lbl = "#" .. i .. " (" .. w .. "x" .. h ..")"
    local lw = font:sizeOf(lbl)
    if lw > w then w = lw end
    h = h + fonth + sep
    if x + w > sw then
      x = 0
      y = y + tallest
      if y > sh then
        break
      end
    end
    if h > tallest then tallest = h end
    font:draw(canvas, lbl, x, y)
    sprite_table:draw(canvas, i, x, y + fonth)
    x = x + w + sep
  end
end

local function DoFrame(app)
  local canvas = app.video
  canvas:startFrame()
  if need_draw then
    need_draw = app.config.track_fps
    canvas:fillBlack()
    Render(canvas)
  end
  canvas:endFrame()
end

local function DoTimer(app)
  if wdown then
    y_off = y_off + 32
    need_draw = true
  end
  if sdown then
    y_off = y_off - 32
    need_draw = true
  end
  return need_draw
end

old_event_handlers = app.eventHandlers
app.eventHandlers = {
  frame = DoFrame,
  keydown = DoKey,
  keyup = DoKeyUp,
  timer = DoTimer,
}
