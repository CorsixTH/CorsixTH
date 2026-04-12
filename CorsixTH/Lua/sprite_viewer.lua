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

local is_open = false
local gfx = TheApp.gfx
local font -- Set on open
local need_draw = true
local sprite_table_paths = {}
local palettes = {}
local palette_index = 1
local palette_name
local sprite_table_index
local sprite_table
local is_complex = false
local wdown = false
local sdown = false
local scale = 1
local bg_colour_index = 1
local y_off
local old_event_handlers
local mpalette_index

local background_colours = {
  Colours.Black,
  Colours.White,
  Colours.Magenta,
  Colours.Cyan,
  Colours.Yellow,
}

for _, dir in ipairs({"Data", "QData", "DataM", "QDataM"}) do
  for item in pairs(TheApp.fs:listFiles(dir) or {}) do
    if item:match("%.TAB$") then
      local basename = item:sub(1, -5)
      if TheApp.fs:fileExists(dir, basename .. ".DAT") then
        sprite_table_paths[#sprite_table_paths + 1] = {dir, item:sub(1, -5)}
      else
        print("Sprite table " .. dir .. "/" .. item .. " has no matching .DAT file. Skipping.")
      end
    end
  end
end
table.sort(sprite_table_paths, function(lhs, rhs)
  return lhs[1] < rhs[1] or (lhs[1] == rhs[1] and lhs[2] < rhs[2])
end)

for name, _ in pairs(TheApp.gfx:allPalettes()) do
  palettes[#palettes + 1] = name
end
table.sort(palettes)

for i, name in ipairs(palettes) do
  if name == "MPalette.dat" then
    mpalette_index = i
    break
  end
end

-- Find the palette with the longest common prefix with the sprite table path,
-- as this is likely the correct palette to use for the sprite table.
-- Avoids hardcoding a mapping of sprites to palettes and accounts for THs
-- naming e.g. AWARD01.PAL and AWARD02.PAL used for AWARD03.TAB
--
--!param sprite_table_name (string) The name of the sprite table, without the
--        .TAB extension
--!return (number) The index of the closest matching palette in the palettes
local function closest_matching_palette(sprite_table_name)
  local best_score = 0
  local best_index
  local lower_st = sprite_table_name:lower()

  for i, pal_name in ipairs(palettes) do
    local score = 0
    local lower_pal = pal_name:lower()

    for j = 3, math.min(#lower_pal, #lower_st) do
      if lower_pal:sub(1, j) == lower_st:sub(1, j) then
        score = j
      else
        break
      end
    end
    if score > best_score then
      best_score = score
      best_index = i
    end
  end

  return best_index
end

local function LoadTable(n, complex, detect_palette)
  sprite_table_index = n
  is_complex = complex
  local path = sprite_table_paths[n]
  local pal
  if detect_palette then
    palette_index = closest_matching_palette(path[2]) or mpalette_index
  end
  palette_name = palettes[palette_index]
  pal = gfx:getPalette(palette_name)
  sprite_table = gfx:loadSpriteTable(path[1], path[2], complex, pal)
  need_draw = true
  y_off = 0
end
LoadTable(1, false, true)

local function DoKey(_, rawchar)
  local key = rawchar:lower()
  if key == "c" then
    gfx.cache.tabled = {}
    LoadTable(sprite_table_index, not is_complex, false)
  elseif key == "a" then
    if sprite_table_index > 1 then
      LoadTable(sprite_table_index - 1, is_complex, true)
    end
  elseif key == "d" then
    if sprite_table_index < #sprite_table_paths then
      LoadTable(sprite_table_index + 1, is_complex, true)
    end
  elseif key == "p" then
    palette_index = (palette_index or 1) % #palettes + 1
    gfx.cache.tabled = {}
    LoadTable(sprite_table_index, is_complex, false)
  elseif key == "w" then
    wdown = true
    need_draw = true
  elseif key == "s" then
    sdown = true
    need_draw = true
  elseif key == "-" then
    if scale > 1 then
      scale = scale - 1
      need_draw = true
    end
  elseif key == "=" then
    if scale < 8 then
      scale = scale + 1
      need_draw = true
    end
  elseif key == "b" then
    bg_colour_index = bg_colour_index % #background_colours + 1
    need_draw = true
  end
  return need_draw
end

local function DoKeyUp(_, rawchar)
    local key = rawchar:lower()
    if key == "q" then -- Exit sprite viewer
      TheApp.eventHandlers = old_event_handlers
      is_open = false
      return
    end
    if key == "w" then
        wdown = false
    end
    if key == "s" then
        sdown = false
    end
end

local function DoTextInput()
  return false
end

local function Render(canvas)
  local encoding = is_complex and " (Complex) " or " (Simple) "
  local msg = table.concat(sprite_table_paths[sprite_table_index], package.config:sub(1, 1)) .. encoding .. palette_name
  local _, fonth = font:sizeOf(msg)
  local sep = 2
  local y = y_off
  font:draw(canvas, "CorsixTH Debug Sprite Viewer", 0, y)
  y = y + (fonth + sep)
  font:draw(canvas, "W/A/S/D to navigate, C to change mode, P to switch palette, -/= to scale, B to change background, Q to quit", 0, y)
  y = y + (fonth + sep)
  font:draw(canvas, msg, 0, y)
  y = y + fonth + sep
  local x = 0
  local sw, sh = TheApp.config.width, TheApp.config.height
  local tallest = 0
  for i = 0, #sprite_table - 1 do
    local w, h = sprite_table:size(i)
    w = w * scale
    h = h * scale
    local lbl = "#" .. i .. " (" .. w .. "x" .. h .. ")"
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
    sprite_table:draw(
        canvas,
        i,
        x,
        y + fonth,
        { scaleFactor = scale })
    x = x + w + sep
  end
end

local function DoFrame(app)
  local canvas = app.video
  canvas:startFrame()
  if need_draw then
    need_draw = app.config.track_fps
    canvas:fillColour(background_colours[bg_colour_index])
    Render(canvas)
  end
  canvas:endFrame()
end

local function DoTimer()
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

local function open()
  if is_open then
    return
  end
  is_open = true
  gfx.cache.tabled = {}
  font = gfx:loadFontAndSpriteTable("QData", "Font00V")

  old_event_handlers = TheApp.eventHandlers
  TheApp.eventHandlers = {
    frame = DoFrame,
    keydown = DoKey,
    keyup = DoKeyUp,
    timer = DoTimer,
    textinput = DoTextInput
  }

  need_draw = true
end

return open
