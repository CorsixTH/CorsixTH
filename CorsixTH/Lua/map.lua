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

class "Map"
local math_floor, tostring, table_concat
    = math.floor, tostring, table.concat
local thMap = require"TH".map

function Map:Map()
  self.width = false
  self.height = false
  self.th = thMap()
  self.debug_text = false
  self.debug_flags = false
  self.debug_font = false
end

-- Convert between world co-ordinates and screen co-ordinates
-- World co-ordinates are (at least for standard maps) in the range [1, 128)
-- for both x and y, with the floor of the values giving the cell index.
-- Screen co-ordinates are pixels relative to the map origin - NOT relative to
-- the top-left corner of the screen (use UI:WorldToScreen and UI:ScreenToWorld
-- for this).

function Map:WorldToScreen(x, y)
  return 32 * (x - y), 16 * (x + y - 2)
end

function Map:ScreenToWorld(x, y)
  y = (y / 32) + 1
  x = x / 64
  return y + x, y - x
end

local function bits(n)
  local vals = {}
  local m = 256
  while m >= 1 do
    if n >= m then
      vals[#vals + 1] = m
      n = n - m
    end
    m = m / 2
  end
  if vals[1] then
    return unpack(vals)
  else
    return 0
  end
end

function Map:load(thData)
  assert(self.th:load(thData))
  self.thData = thData
  self.width, self.height = self.th:size()
end

function Map:clearDebugText()
  self.debug_text = false
  self.debug_flags = false
end

function Map:loadDebugText(base_offset, xy_offset, first, last, bits_)
  self.debug_text = false
  self.debug_flags = false
  if base_offset == "flags" then
    self.debug_flags = {}
    for x = 1, self.width do
      for y = 1, self.height do
        local xy = (y - 1) * self.width + x - 1
        self.debug_flags[xy] = assert(self.th:getCellFlags(x, y))
      end
    end
    return
  end
  local thData = self.thData
  for x = 1, self.width do
    for y = 1, self.height do
      local xy = (y - 1) * self.width + x - 1
      local offset = base_offset + xy * xy_offset
      if bits_ then
        self:setDebugText(x, y, bits(thData:byte(offset + first, offset + last)))
      else
        self:setDebugText(x, y, thData:byte(offset + first, offset + last))
      end
    end
  end
end

function Map:setBlocks(blocks)
  self.th:setSheet(blocks)
end

function Map:setCellFlags(...)
  self.th:setCellFlags(...)
end

function Map:setDebugFont(font)
  self.debug_font = font
  self.cell_outline = TheApp.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
end

function Map:setDebugText(x, y, msg, ...)
  if not self.debug_text then
    self.debug_text = {}
  end
  local text
  if ... then
    text = {msg, ...}
    for i, v in ipairs(text) do
      text[i] = tostring(v)
    end
    text = table_concat(text, ",")
  else
    text = msg ~= 0 and msg or nil
  end
  self.debug_text[(y - 1) * self.width + x - 1] = text
end

--[[!
  @arguments canvas, screen_x, screen_y, screen_width, screen_height, destination_x, destination_y
  
  Draws the rectangle of the map given by (sx, sy, sw, sh) at position (dx, dy) on the canvas
--]]
function Map:draw(canvas, sx, sy, sw, sh, dx, dy)
  self.th:draw(canvas, sx, sy, sw, sh, dx, dy)
  
  if self.debug_font and (self.debug_text or self.debug_flags) then
    local startX = 0
    local startY = math_floor((sy - 32) / 16)
    if startY < 0 then
      startY = 0
    elseif startY >= self.height then
      startX = startY - self.height + 1
      startY = self.height - 1
      if startX >= self.width then
        startX = self.width - 1
      end
    end
    local baseX = startX
    local baseY = startY
    while true do
      local x = baseX
      local y = baseY
      local screenX = 32 * (x - y) - sx
      local screenY = 16 * (x + y) - sy
      if screenY >= sh + 70 then
        break
      elseif screenY > -32 then
        repeat
          if screenX < -32 then
          elseif screenX < sw + 32 then
            local xy = y * self.width + x
            local x = dx + screenX - 32
            local y = dy + screenY
            if self.debug_flags then
              local flags = self.debug_flags[xy]
              if flags.passable then
                self.cell_outline:draw(canvas, 3, x, y)
              end
              if flags.hospital then
                self.cell_outline:draw(canvas, 8, x, y)
              end
              if flags.buildable then
                self.cell_outline:draw(canvas, 9, x, y)
              end
              if flags.travelNorth and self.debug_flags[xy - self.width].passable then
                self.cell_outline:draw(canvas, 4, x, y)
              end
              if flags.travelEast and self.debug_flags[xy + 1].passable then
                self.cell_outline:draw(canvas, 5, x, y)
              end
              if flags.travelSouth and self.debug_flags[xy + self.width].passable then
                self.cell_outline:draw(canvas, 6, x, y)
              end
              if flags.travelWest and self.debug_flags[xy - 1].passable then
                self.cell_outline:draw(canvas, 7, x, y)
              end
            else
              local msg = self.debug_text[xy]
              if msg and msg ~= "" then
                self.cell_outline:draw(canvas, 2, x, y)
                self.debug_font:draw(canvas, msg, x, y, 64, 32)
              end
            end
          else
            break
          end
          x = x + 1
          y = y - 1
          screenX = screenX + 64
        until y < 0 or x >= self.width
      end
      if baseY == self.height - 1 then
        baseX = baseX + 1
        if baseX == self.width then
          break
        end
      else
        baseY = baseY + 1
      end
    end
  end
end
