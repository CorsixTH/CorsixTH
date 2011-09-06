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

--! Lua extensions to the C++ THMap class
class "Map"
local pathsep = package.config:sub(1, 1)
local math_floor, tostring, table_concat
    = math.floor, tostring, table.concat
local thMap = require"TH".map

function Map:Map(app)
  self.width = false
  self.height = false
  self.th = thMap()
  self.app = app
  self.debug_text = false
  self.debug_flags = false
  self.debug_font = false
  self.debug_tick_timer = 1
end

local flag_cache = {}
function Map:getCellFlag(x, y, flag)
  return self.th:getCellFlags(x, y, flag_cache)[flag]
end

function Map:getRoomId(x, y)
  return self.th:getCellFlags(x, y).roomId
end

-- Convert between world co-ordinates and screen co-ordinates
-- World co-ordinates are (at least for standard maps) in the range [1, 128)
-- for both x and y, with the floor of the values giving the cell index.
-- Screen co-ordinates are pixels relative to the map origin - NOT relative to
-- the top-left corner of the screen (use UI:WorldToScreen and UI:ScreenToWorld
-- for this).

function Map:WorldToScreen(x, y)
  if x == nil then x = 0 end
  if y == nil then y = 0 end

  -- Adjust origin from (1, 1) to (0, 0) and then linear transform by matrix:
  -- 32 -32
  -- 16  16
  return 32 * (x - y), 16 * (x + y - 2)
end

function Map:ScreenToWorld(x, y)
  -- Transform by matrix: (inverse of the WorldToScreen matrix)
  --  1/64 1/32
  -- -1/64 1/32
  -- And then adjust origin from (0, 0) to (1, 1)
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

--[[! Loads the specified level. If a string is passed it looks for the file with the same name
 in the "Levels" folder of CorsixTH, if it is a number it tries to load that level from
 the original game.
!param level The name (or number) of the level to load. If this is a number the game assumes
the original game levels are considered.
!param level_name The name of the actual map/area/hospital as written in the config file.
!param level_file The path to the map file as supplied by the config file.
]]
function Map:load(level, difficulty, level_name, level_file, level_intro)
  local objects, i
  if not difficulty then
    difficulty = "full"
  end
  -- Load CorsixTH base configuration for all levels.
  -- We want to load the file a new each time.
  local function file (filename)
      local f = assert(loadfile(filename))
      return f()
    end
  local path = debug.getinfo(1, "S").source:sub(2, -8)
  local result = file(path .. "base_config.lua")

  local base_config = result
  local errors
  if type(level) == "number" then
    -- Playing the original campaign.
    -- Add TH's base config if possible, otherwise our own config 
    -- roughly corresponds to "full".
    errors, base_config = self:loadMapConfig(difficulty .. "00.SAM", base_config)
    -- If it couldn't be loaded the new difficulty level is full no matter what.
    if errors then
      difficulty = "full"
    end
    self.difficulty = difficulty
    self.level_number = level
    local data
    data, errors = self:getRawData(level_file)
    if data then
      i, objects = self.th:load(data)
    else
      return nil, errors
    end
    self.level_name = _S.level_names[level]:upper()
    -- Check if we're using the demo files. If we are, that special config should be loaded.
    if self.app.using_demo_files then
      -- Try to load our own configuration file for the demo. 
      local p = debug.getinfo(1, "S").source:sub(2, -12) .. "Levels" .. pathsep .. "demo.level"
      errors, result = self:loadMapConfig(p, base_config, true)
      if errors then
        print("Warning: Could not find the demo configuration, try reinstalling the game")
      end
      self.level_config = result
    else
      local level_no = level
      if level_no < 10 then
        level_no = "0" .. level
      end
      -- Override with the specific configuration for this level
      errors, result = self:loadMapConfig(difficulty .. level_no .. ".SAM", base_config)
      -- Finally load additional CorsixTH config per level (currently only for level 5)
      local p = debug.getinfo(1, "S").source:sub(2, -12) .. "Levels" .. pathsep .. "original" .. level_no .. ".level"
      errors, result = self:loadMapConfig(p, result, true)
      self.level_config = result
    end
  elseif _MAP_EDITOR then
    -- We're being fed data by the map editor.
    self.level_name = "MAP EDITOR"
    self.level_number = "MAP EDITOR"
    if level == "" then
      i, objects = self.th:loadBlank()
    else
      i, objects = self.th:load(level)
    end
    assert(base_config, "No base config has been loaded!")

    self.level_config = base_config
  else
    -- We're loading a custom level.
    self.level_name = level_name
    self.level_intro = level_intro
    self.level_number = level
    self.level_file = level_file
    local data, errors = self:getRawData(level_file)
    if data then
      i, objects = self.th:load(data)
    else
      return nil, errors
    end
    assert(base_config, "No base config has been loaded!")
    errors, result = self:loadMapConfig(level, base_config, true)
    self.level_config = result
  end

  self.width, self.height = self.th:size()

  self.parcelTileCounts = {}
  for plot = 1, self.th:getPlotCount() do
    self.parcelTileCounts[plot] = self.th:getParcelTileCount(plot)
    if plot > 1 and not _MAP_EDITOR then
      -- TODO: On multiplayer maps, assign plots 2-N to players 2-N
      self.th:setPlotOwner(plot, 0)
    end
  end

  return objects
end

--[[! Loads map configurations from files. Returns nil as first result
if no configuration could be loaded and config as second result no matter what.
!param filename
!param config If a base config already exists and only some values should be overridden
this is the base config
!param custom If true The configuration file is searched for where filename points, otherwise
it is assumed that we're looking in the theme_hospital_install path.
]]
function Map:loadMapConfig(filename, config, custom)
  local function iterator()
    if custom then
      return io.lines(filename)
    else
      return self.app.fs:readContents("Levels", filename):gmatch"[^\r\n]+"
    end
  end
  if self.app.fs:readContents("Levels", filename) or io.open(filename) then
    for line in iterator() do
      if line:sub(1, 1) == "#" then
        local parts = {}
        local nkeys = 0
        for part in line:gmatch"%.?[-?a-zA-Z0-9%[_%]]+" do
          if part:sub(1, 1) == "." and #parts == nkeys + 1 then
            nkeys = nkeys + 1
          end
          parts[#parts + 1] = part
        end
        if nkeys == 0 then
          parts[3] = parts[2]
          parts[2] = ".Value"
          nkeys = 1
        end
        for i = 2, nkeys + 1 do
          local key = parts[1] .. parts[i]
          local t, n
          for name in key:gmatch"[^.%[%]]+" do
            name = tonumber(name) or name
            if t then
              if not t[n] then
                t[n] = {}
              end
              t = t[n]
            else
              t = config
            end
            n = name
          end
          t[n] = tonumber(parts[nkeys + i]) or parts[nkeys + i]
        end
      end
    end
    return nil, config
  else
    return "Error: Could not find the configuration file", config
  end
end

local temp_debug_text
local temp_debug_flags
local temp_updateDebugOverlay
local temp_thData

-- Keep debug information in temporary local vars, do not save them
function Map:prepareForSave()
  temp_debug_text = self.debug_text
  self.debug_text = false
  temp_debug_flags = self.debug_flags
  self.debug_flags = false
  temp_updateDebugOverlay = self.updateDebugOverlay
  self.updateDebugOverlay = nil
  temp_thData = self.thData
  self.thData = nil
end

-- Restore the temporarily stored debug information after saving
function Map:afterSave()
  self.debug_text = temp_debug_text
  temp_debug_text = nil
  self.debug_flags = temp_debug_flags
  temp_debug_flags = nil
  self.updateDebugOverlay = temp_updateDebugOverlay
  temp_updateDebugOverlay = nil
  self.thData = temp_thData
  temp_thData = nil
end

function Map:clearDebugText()
  self.debug_text = false
  self.debug_flags = false
  self.updateDebugOverlay = nil
end

function Map:getRawData(level_file)
  if not self.thData then
    local data, errors
    if not level_file then
      data, errors = self.app:readDataFile("Levels", "Level.L".. self.level_number)
    else
      data, errors = self.app:readDataFile("Levels", level_file)
    end
    if data then
      self.thData = data
    else
      return nil, errors
    end
  end
  return self.thData
end

function Map:updateDebugOverlayFlags()
  for x = 1, self.width do
    for y = 1, self.height do
      local xy = (y - 1) * self.width + x - 1
      self.th:getCellFlags(x, y, self.debug_flags[xy])
    end
  end
end

function Map:updateDebugOverlayHeat()
  for x = 1, self.width do
    for y = 1, self.height do
      local xy = (y - 1) * self.width + x - 1
      self.debug_text[xy] = ("%02.1f"):format(self.th:getCellTemperature(x, y) * 50)
    end
  end
end

function Map:loadDebugText(base_offset, xy_offset, first, last, bits_)
  self.debug_text = false
  self.debug_flags = false
  self.updateDebugOverlay = nil
  if base_offset == "flags" then
    self.debug_flags = {}
    for x = 1, self.width do
      for y = 1, self.height do
        local xy = (y - 1) * self.width + x - 1
        self.debug_flags[xy] = {}
      end
    end
    self.updateDebugOverlay = self.updateDebugOverlayFlags
    self:updateDebugOverlay()
  elseif base_offset == "positions" then
    self.debug_text = {}
    for x = 1, self.width do
      for y = 1, self.height do
        local xy = (y - 1) * self.width + x - 1
        self.debug_text[xy] = x .. "," .. y
      end
    end
  elseif base_offset == "heat" then
    self.debug_text = {}
    self.updateDebugOverlay = self.updateDebugOverlayHeat
    self:updateDebugOverlay()
  else
    local thData = self:getRawData()
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
end

function Map:onTick()
  if self.debug_tick_timer == 1 then
    if self.updateDebugOverlay then
      self:updateDebugOverlay()
    end
    self.debug_tick_timer = 10
  else
    self.debug_tick_timer = self.debug_tick_timer - 1
  end
end

function Map:setBlocks(blocks)
  self.blocks = blocks
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
  -- All the heavy work is done by C code:
  self.th:draw(canvas, sx, sy, sw, sh, dx, dy)
  
  -- Draw any debug overlays
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
              if flags.thob ~= 0 then
                self.debug_font:draw(canvas, "T"..flags.thob, x, y, 64, 16)
              end
              if flags.roomId ~= 0 then
                self.debug_font:draw(canvas, "R"..flags.roomId, x, y + 16, 64, 16)
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

function Map:getParcelPrice(parcel)
  local conf = self.level_config
  conf = conf and conf.gbv
  conf = conf and conf.LandCostPerTile
  return self:getParcelTileCount(parcel) * (conf or 25)
end

function Map:getParcelTileCount(parcel)
  return self.parcelTileCounts[parcel] or 0
end

function Map:afterLoad(old, new)
  if old < 6 then
    self.parcelTileCounts = {}
    for plot = 1,self.th:getPlotCount() do
      self.parcelTileCounts[plot] = self.th:getParcelTileCount(plot)
    end
  end
  if old < 18 then
    self.difficulty = "full"
  end
  if old < 44 then
    self.level_config.expertise[2].MaxDiagDiff = 700
    self.level_config.expertise[3].MaxDiagDiff = 250
    self.level_config.expertise[4].MaxDiagDiff = 250
    self.level_config.expertise[5].MaxDiagDiff = 250
    self.level_config.expertise[6].MaxDiagDiff = 250
    self.level_config.expertise[7].MaxDiagDiff = 250
    self.level_config.expertise[8].MaxDiagDiff = 350
    self.level_config.expertise[9].MaxDiagDiff = 250
    self.level_config.expertise[10].MaxDiagDiff = 250
    self.level_config.expertise[11].MaxDiagDiff = 700
    self.level_config.expertise[12].MaxDiagDiff = 1000
    self.level_config.expertise[13].MaxDiagDiff = 700
    self.level_config.expertise[14].MaxDiagDiff = 400
    self.level_config.expertise[15].MaxDiagDiff = 350
    self.level_config.expertise[16].MaxDiagDiff = 350
    self.level_config.expertise[17].MaxDiagDiff = 1000
    self.level_config.expertise[18].MaxDiagDiff = 350
    self.level_config.expertise[19].MaxDiagDiff = 700
    self.level_config.expertise[20].MaxDiagDiff = 700
    self.level_config.expertise[21].MaxDiagDiff = 700
    self.level_config.expertise[22].MaxDiagDiff = 350
    self.level_config.expertise[23].MaxDiagDiff = 350
    self.level_config.expertise[24].MaxDiagDiff = 700
    self.level_config.expertise[25].MaxDiagDiff = 700
    self.level_config.expertise[26].MaxDiagDiff = 700
    self.level_config.expertise[27].MaxDiagDiff = 350
    self.level_config.expertise[28].MaxDiagDiff = 700
    self.level_config.expertise[29].MaxDiagDiff = 1000
    self.level_config.expertise[30].MaxDiagDiff = 700
    self.level_config.expertise[31].MaxDiagDiff = 1000
    self.level_config.expertise[32].MaxDiagDiff = 700
    self.level_config.expertise[33].MaxDiagDiff = 1000
    self.level_config.expertise[34].MaxDiagDiff = 700
    self.level_config.expertise[35].MaxDiagDiff = 700
  end
end
