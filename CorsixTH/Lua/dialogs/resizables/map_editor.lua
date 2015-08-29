--[[ Copyright (c) 2010 Peter "Corsix" Cawley
Copyright (c) 2014 Stephen Baker

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

dofile "command_stack"
dofile "command"
dofile "commands/set_map_cell"
dofile "commands/set_map_cell_flags"
dofile "commands/compound"

class "UIMapEditor" (UIResizable)

---@type UIMapEditor
local UIMapEditor = _G["UIMapEditor"]

local math_floor
    = math.floor

local col_scrollbar = {
  red = 164,
  green = 156,
  blue = 208,
}

local col_bg = {red = 154, green = 146, blue = 198}

-- {{{ Editor sprites.
-- High byte sprite constants.
local FLIP_H = DrawFlags.FlipHorizontal << 8

-- Each variable below is an array of multi-tile sprites, which is translated
-- to a list of buttons at a page.
-- The generic form of a multi-tile sprite (see the helipad for an example) is
-- a table {sprites = .., height = ..}. The 'height' defines the height of the
-- displayed button (between 1 and MAX_HEIGHT).
-- The 'sprites' is an array of single sprites, a table of {sprite = ...,
-- xpos = ..., ypos = ..., type = ...}. It defines which sprite to display at
-- which relative position. Positions run from 1 upward, sprites are numbers
-- 0..255 (the low byte) while the high byte is used for DrawFlags flags, eg
-- FLIP_H. Last but not least 'floor', 'north', and 'west' types defne where
-- to put the sprite (as floor sprites, north wall sprite or west wall
-- sprite).
--
-- As there are a lot of single tile sprite buttons, there is a simplified
-- form to specify those (and they get expanded to the generic multi-tile
-- sprite form automagically). The short form for a single sprite button is a
-- table {sprite = ..., height = ..., type = ...}, where all the fields have
-- the same meaning as described above for the generic form.
--
-- {{{ Foliage sprites.
local foliage = {
  {sprite=192, height=3, type="floor"}, -- Regular European shrub 1
  {sprite=193, height=2, type="floor"}, -- Ground plant, green 1
  {sprite=194, height=2, type="floor"}, -- Bush
  {sprite=195, height=3, type="floor"}, -- Ground plant, red flowers
  {sprite=196, height=3, type="floor"}, -- Shrub
  {sprite=197, height=4, type="floor"}, -- Dead tree (very high)
  {sprite=198, height=2, type="floor"}, -- Low ground plant
  {sprite=199, height=3, type="floor"}, -- Regular European shrub 2
  {sprite=200, height=2, type="floor"}, -- Ground plant, flowers
  {sprite=201, height=1, type="floor"}, -- Flowerbed East/South
  {sprite=202, height=1, type="floor"}, -- Flowerbed West/South
  {sprite=203, height=1, type="floor"}, -- Flowerbed West/North
  {sprite=204, height=1, type="floor"}, -- Flowerbed North/South
}
-- }}}
-- {{{ Hedge row sprites.
local hedgerow={
  {sprite=176, height=2, type="floor"}, -- Hedge West-North
  {sprite=177, height=2, type="floor"}, -- Hedge West-South
  {sprite=178, height=2, type="floor"}, -- Hedge East-South
  {sprite=179, height=2, type="floor"}, -- Hedge East-North
  {sprite=180, height=2, type="floor"}, -- Hedge West-East
  {sprite=181, height=2, type="floor"}, -- Hedge North-South
  {sprite=182, height=2, type="floor"}, -- Hedge East-West-South
  {sprite=183, height=2, type="floor"}, -- Hedge East-West-North
  {sprite=184, height=2, type="floor"}, -- Hedge West-North-South
  {sprite=185, height=2, type="floor"}, -- Hedge East-North-South
  {sprite=186, height=2, type="floor"}, -- Hedge East-West-North-South
  {sprite=187, height=2, type="floor"}, -- Hedge North-South with shrub
  {sprite=188, height=2, type="floor"}, -- Hedge North-South with holes
  {sprite=189, height=2, type="floor"}, -- Hedge East-West with shrub 1
  {sprite=190, height=2, type="floor"}, -- Hedge East-West with holes
  {sprite=191, height=2, type="floor"}, -- Hedge East-West with shrub 2
}
-- }}}
-- {{{ Pond sprites.
local pond={
  {sprite= 60, height=1, type="floor"}, -- South edge of a pond
  {sprite= 65, height=1, type="floor"}, -- West edge of a pond
  {sprite= 68, height=1, type="floor"}, -- North edge of a pond
  {sprite= 78, height=1, type="floor"}, -- East edge of a pond
  {sprite= 59, height=1, type="floor"}, -- South-West corner of a pond
  {sprite= 77, height=1, type="floor"}, -- North-East corner of a pond
  {sprite= 79, height=1, type="floor"}, -- South-East corner of a pond
  {sprite= 80, height=1, type="floor"}, -- North-West corner of a pond
  {sprite= 69, height=1, type="floor"}, -- Water tile of a pond
  {sprite= 71, height=1, type="floor"}, -- Water tile of a pond with water lilies
  {sprite= 72, height=2, type="floor"}, -- Water tile of a pond with water plant 1
  {sprite= 73, height=2, type="floor"}  -- Water tile of a pond with water plant 2
}
-- }}}
-- {{{ Inside floor sprites.
local inside={
  {sprite= 17, height=1, type="floor"}, -- Dark blue/purple carpet tile
  {sprite= 70, height=1, type="floor"}, -- Duplicate of 017
  {sprite= 18, height=1, type="floor"}, -- Red-Blue floor tile 1
  {sprite= 19, height=1, type="floor"}, -- Red-Blue floor tile 2
  {sprite= 23, height=1, type="floor"}, -- Red-Blue floor tile 3
  {sprite= 16, height=1, type="floor"}, -- Dark big checker pattern tile
  {sprite= 21, height=1, type="floor"}, -- Small checker pattern tile
  {sprite= 22, height=1, type="floor"}, -- Big checker pattern tile
  {sprite= 66, height=1, type="floor"}, -- Floor tile with light center
  {sprite= 76, height=1, type="floor"}, -- Floor tile with light center and corners
  {sprite= 20, height=1, type="floor"}  -- Wooden floor tile
}
-- }}}
-- {{{ Outside floor sprites.
local outside={
  {sprite=  1, height=1, type="floor"}, -- Grass tile 1
  {sprite=  2, height=1, type="floor"}, -- Grass tile 2
  {sprite=  3, height=1, type="floor"}, -- Grass tile 3
  {sprite=  4, height=1, type="floor"}, -- Light concrete tile
  {sprite= 15, height=1, type="floor"}, -- Concrete tile
  {sprite=  5, height=1, type="floor"}, -- Dark concrete tile
  {sprite=  6, height=1, type="floor"}, -- Grass tile with South-East concrete corner
  {sprite=  8, height=1, type="floor"}, -- Grass tile with South-West concrete corner
  {sprite= 10, height=1, type="floor"}, -- Grass tile with North-West concrete corner
  {sprite= 12, height=1, type="floor"}, -- Grass tile with North-East concrete corner
  {sprite=  7, height=1, type="floor"}, -- Grass tile with South concrete edge
  {sprite=  9, height=1, type="floor"}, -- Grass tile with West concrete edge
  {sprite= 11, height=1, type="floor"}, -- Grass tile with North concrete edge
  {sprite= 13, height=1, type="floor"}, -- Grass tile with East concrete edge
  {sprite= 14, height=1, type="floor"}, -- Concrete tile with North-East grass corner
  {sprite= 61, height=1, type="floor"}, -- Concrete tile with South-West grass corner
  {sprite= 62, height=1, type="floor"}, -- Concrete tile with South-East grass corner
  {sprite= 63, height=1, type="floor"}, -- Concrete tile with North-West grass corner
  {sprite= 64, height=1, type="floor"}, -- Grass tile with rocks
  {sprite=205, height=1, type="floor"}, -- Fully cracked garden marble tile
  {sprite=206, height=1, type="floor"}, -- Broken garden marble tile
  {sprite=207, height=1, type="floor"}, -- Partially cracked garden marble tile
  {sprite=208, height=1, type="floor"}, -- Garden marble tile
}
-- }}}
-- {{{ Road floor sprites.
local road_spr = {
  {sprite= 41, height=1, type="floor"}, -- Road with white discontinuous line North-South
  {sprite= 45, height=1, type="floor"}, -- Road with double yellow lines at West edge merging at South
--{sprite= 46, height=1, type="floor"}, -- Duplicate of 45
  {sprite= 42, height=1, type="floor"}, -- Road with double yellow lines at West with black orthogonal lines
  {sprite= 43, height=1, type="floor"}, -- Road with double yellow lines at West edge
  {sprite= 44, height=1, type="floor"}, -- Road with double yellow lines at West edge merging at North
  {sprite= 47, height=1, type="floor"}, -- Road with red line at East linked to yellow discontinuous line at South
  {sprite= 49, height=1, type="floor"}, -- Road with red braking line at the East pointing to the West
  {sprite= 48, height=1, type="floor"}, -- Road with red line at East linked to yellow discontinuous line at North
  {sprite= 53, height=1, type="floor"}, -- Road with double yellow lines at East edge merging at the south
  {sprite= 52, height=1, type="floor"}, -- Road with double yellow lines at East with black orthogonal lines
--{sprite= 54, height=1, type="floor"}, -- Duplicate of 52
  {sprite= 51, height=1, type="floor"}, -- Road with double yellow lines at East edge
  {sprite= 57, height=1, type="floor"}, -- Road with red line at West linked to yellow discontinuous line at South
  {sprite= 55, height=1, type="floor"}, -- Road with red braking line at the West pointing to the East
  {sprite= 56, height=1, type="floor"}, -- Road with red line at West linked to yellow discontinuous line at North
  {sprite= 50, height=1, type="floor"}, -- Road with grey edge at the East
  {sprite= 58, height=1, type="floor"}, -- Road with grey edge at the West
}
local road = {} -- All sprites get horizontally flipped as well, for roads running north-south.
for _, spr in ipairs(road_spr) do
  road[#road + 1] = spr
  road[#road + 1] = {sprite = spr.sprite + FLIP_H, height = spr.height, type = spr.type}
end
-- }}}
-- {{{ North wall layout and floor sprites.
local north_wall = {
  {sprites = {
    {sprite=159, xpos=1, ypos=1, type="north"}, -- External doorway North outside left part
    {sprite=157, xpos=3, ypos=1, type="north"}, -- External doorway North outside right part
    },
   height = 3},

  {sprites = {
    {sprite=163, xpos=1, ypos=1, type="north"}, -- External doorway North inside left part
    {sprite=161, xpos=3, ypos=1, type="north"}, -- External doorway North inside right part
    },
   height = 3},

  {sprite=114, height=3, type="north"}, -- External North wall outside
  {sprite=116, height=3, type="north"}, -- External North wall outside left part of window
  {sprite=120, height=3, type="north"}, -- External North wall with window
  {sprite=118, height=3, type="north"}, -- External North wall outside right part of window
  {sprite=122, height=3, type="north"}, -- External North wall inside
  {sprite=124, height=3, type="north"}, -- External North wall inside left part of window
  {sprite=126, height=3, type="north"}, -- External North wall inside right part of window
  {sprite=209 + FLIP_H, height=3, type="north"}, -- Lamp post pointing East
  {sprite=210 + FLIP_H, height=3, type="north"}, -- Lamp post pointing West
}
-- }}}
-- {{{ West wall layout and floor sprites.
local west_wall = {
  {sprites = {
    {sprite=158, xpos=1, ypos=3, type="west"}, -- External doorway West outside left part
    {sprite=160, xpos=1, ypos=1, type="west"}, -- External doorway West outside right part
    },
   height = 3},

  {sprites = {
    {sprite=162, xpos=1, ypos=3, type="west"}, -- External doorway West inside left part
    {sprite=164, xpos=1, ypos=1, type="west"}, -- External doorway West inside right part
    },
   height = 3},

  {sprite=115, height=3, type="west"}, -- External West wall outside
  {sprite=119, height=3, type="west"}, -- External West wall outside left part of window
-- No external west-wall with just glass. 121 (below) isn't finished, 120 (north above) has different lighting
-- {sprite=121, height=3, type="west"}, -- External West wall with window glass (UNFINISHED?)
  {sprite=117, height=3, type="west"}, -- External West wall outside right part of window
  {sprite=123, height=3, type="west"}, -- External West wall inside
  {sprite=127, height=3, type="west"}, -- External West wall inside left part of window
  {sprite=125, height=3, type="west"}, -- External West wall inside right part of window
  {sprite=210, height=3, type="west"}, -- Lamp post pointing South
  {sprite=209, height=3, type="west"}, -- Lamp post pointing North
}
-- }}}
-- {{{ Helipad layout.
local helipad = {
  {sprites = {
    -- Dark tiles around the edges.
    {sprite=5, xpos=1, ypos=1, type="floor"},
    {sprite=5, xpos=2, ypos=1, type="floor"},
    {sprite=5, xpos=3, ypos=1, type="floor"},
    {sprite=5, xpos=4, ypos=1, type="floor"},
    {sprite=5, xpos=5, ypos=1, type="floor"},

    {sprite=5, xpos=1, ypos=2, type="floor"},
    {sprite=5, xpos=1, ypos=3, type="floor"},
    {sprite=5, xpos=1, ypos=4, type="floor"},
    {sprite=5, xpos=1, ypos=5, type="floor"},

    {sprite=5, xpos=2, ypos=5, type="floor"},
    {sprite=5, xpos=3, ypos=5, type="floor"},
    {sprite=5, xpos=4, ypos=5, type="floor"},

    {sprite=5, xpos=5, ypos=5, type="floor"},
    {sprite=5, xpos=5, ypos=2, type="floor"},
    {sprite=5, xpos=5, ypos=3, type="floor"},
    {sprite=5, xpos=5, ypos=4, type="floor"},
    -- Dark tiles in the 'H'
    {sprite=5, xpos=3, ypos=2, type="floor"},
    {sprite=5, xpos=3, ypos=4, type="floor"},
    -- Light tiles in the 'H'
    {sprite=4, xpos=2, ypos=2, type="floor"},
    {sprite=4, xpos=2, ypos=3, type="floor"},
    {sprite=4, xpos=2, ypos=4, type="floor"},
    {sprite=4, xpos=4, ypos=2, type="floor"},
    {sprite=4, xpos=4, ypos=3, type="floor"},
    {sprite=4, xpos=4, ypos=4, type="floor"},
    {sprite=4, xpos=3, ypos=3, type="floor"}
   },
   height=5
  }
}
-- }}}

local MAX_HEIGHT = 5 -- Biggest height in above sprites
local PAGES = {
  {name = _S.map_editor_window.pages.inside,     spr_data = inside},
  {name = _S.map_editor_window.pages.outside,    spr_data = outside},
  {name = _S.map_editor_window.pages.foliage,    spr_data = foliage},
  {name = _S.map_editor_window.pages.hedgerow,   spr_data = hedgerow},
  {name = _S.map_editor_window.pages.pond,       spr_data = pond},
  {name = _S.map_editor_window.pages.road,       spr_data = road},
  {name = _S.map_editor_window.pages.north_wall, spr_data = north_wall},
  {name = _S.map_editor_window.pages.west_wall,  spr_data = west_wall},
  {name = _S.map_editor_window.pages.helipad,    spr_data = helipad}
}
-- {{{ Functions
--! Normalize the editor sprite in the table to always have a 'sprites' field, as well as have sizes and a column width (for the display).
--!param (table) Sprite from the 'PAGES[#].spr_data' table.
--!return (table 'sprites', 'xsize', 'ysize', 'width', and 'height')
local function normalizeEditSprite(spr)
  assert(MAX_HEIGHT >= spr.height) -- Verify that sprite fits in the maximum height.

  if spr.sprites == nil then -- {spritex=xxx, height=y} case
    return {sprites = {{sprite = spr.sprite, xpos = 1, ypos = 1, type=spr.type}},
            xsize = 1,
            ysize = 1,
            type = spr.type,
            xorigin = 0,
            yorigin = 0,
            width = 2,
            height = spr.height}
  else
    -- {sprites={...}, height=y} case, compute sizes, and width
    local xsize = 1
    local ysize = 1
    local spr_type = nil
    for _, sp in ipairs(spr.sprites) do
      if sp.xpos > xsize then xsize = sp.xpos end
      if sp.ypos > ysize then ysize = sp.ypos end

      assert(not spr_type or spr_type == sp.type) -- Ensure all sprites have the same type.
      spr_type = sp.type
    end
    -- Position to draw (1,1) sprite, by default (0,0)
    -- Since sprites are drawn top to bottom, yorigin never changes.
    local xorigin = (ysize - 1) * 32
    local yorigin = 0

    local width = ysize - 1 + xsize - 1 + 2
    if width < ysize then width = ysize end

    return {sprites = spr.sprites,
            xsize = xsize,
            ysize = ysize,
            type = spr_type,
            xorigin = xorigin,
            yorigin = yorigin,
            width = width,
            height = spr.height}
  end
end

--!Decide the highest possible placement for 'width' columns.
--!param cols (list int) First available position in each column, higher number is lower.
--!param width (int) Required width as number of columns.
--!return (int, int) Starting column and placement height.
local function getHighestRowcol(cols, width)
  local best = cols[1] + 100000
  local best_col = 0

  for left = 1, #cols - width + 1 do -- Try starting in each column.
    if cols[left] < best then -- First column is potentially better.
      local top = cols[left]
      for i = 1, width - 1 do
        if top < cols[left + i] then
          top = cols[left + i]
          if top >= best then break end -- i-th column breaks improvement.
        end
      end
      if top < best then
        best = top
        best_col = left
      end
    end
  end
  return best_col, best
end

--! Layout buttons from a tab of editor sprites.
--!param esprs (list) Editor sprite tab to layout.
--!param num_cols (int) Number of columns available in the layout.
--!return (list) Sprites with button positions in ('column', 'row').
local function layoutButtons(esprs, num_cols)
  local buttons = {}

  local cols = {}
  for i = 1, num_cols do
    cols[i] = 1
  end

  for hgt = MAX_HEIGHT, 1, -1 do -- Fit highest sprites first.
    for _, espr in ipairs(esprs) do
      espr = normalizeEditSprite(espr)
      if espr.height == hgt then
        local spr_col, spr_height = getHighestRowcol(cols, espr.width)
        buttons[#buttons + 1] = espr
        buttons[#buttons].column = spr_col
        buttons[#buttons].row = spr_height

        for i = spr_col, spr_col + espr.width - 1 do -- Update height in the affected columns
          assert(cols[i] <= spr_height)
          cols[i] = spr_height + hgt
        end

      end
    end
  end
  return buttons
end
-- }}}
-- }}}

local num_blocks = 8
local num_visible_blocks = 2

local EDITOR_WINDOW_XSIZE = 368
local EDITOR_WINDOW_YSIZE = 516

function UIMapEditor:UIMapEditor(ui)
  self:UIResizable(ui, EDITOR_WINDOW_XSIZE, EDITOR_WINDOW_YSIZE, col_bg)
  self.resizable = false

  self.ui = ui
  self.panel_sprites = self.ui.app.map.blocks

  self.command_stack = CommandStack()

  -- For when there are multiple things which could be sampled from a tile,
  -- keep track of the index of which one was most recently sampled, so that
  -- next time a different one is sampled.
  self.sample_i = 1

  -- The block to put on the UI layer as a preview for what will be placed
  -- by the current drawing operation.
  self.block_brush_preview = 0

  self:classifyBlocks()

  -- A sprite table containing a "cell outline" sprite
  self.cell_outline = TheApp.gfx:loadSpriteTable("Bitmap", "aux_ui", true)

  -- Coordinates in Lua tile space of the mouse cursor.
  self.mouse_cell_x = 0
  self.mouse_cell_y = 0

  self.block_panel = self:addBevelPanel(0, 0, 190, 130, col_bg)
  self.scroll_base = self:addBevelPanel(190, 0, 20, 130, col_bg)
  self.scroll_base.lowered = true
  self.block_scroll = self.scroll_base:makeScrollbar(col_scrollbar, --[[persistable:map_editor_scrollbar_callback]] function()
    self:updateBlocks()
  end, 1, num_blocks, 1, 1)
  self.block_buttons = {}
  self.block_panels = {}

  for i = 1, num_visible_blocks do
    self.block_buttons[i] = self:addBevelPanel(30, 30 + 78 * (i - 1), 64, 40, col_bg):makeToggleButton(0, 0, 64, 64, nil, --[[persistable:map_editor_block_clicked]] function()
      self:blockClicked(i)
    end)
    self.block_buttons[i].lowered = true
    self.block_panels[i] = self:addPanel(i, 30, 33 + 78 * (i - 1), 64, 32)
  end

  self:setPosition(0.1, 0.1)
  self:updateBlocks()
end

function UIMapEditor:classifyBlocks()
  -- Classify each block / tile with a type, subtype, and category.
  -- Type and subtype are used by this file, and by the UI code to determine
  -- which gallery to put the block in. Category is used purely by the UI to
  -- allow subsets of a gallery to be hidden.
  local block_info = {}
  for i = 1, 15 do
    block_info[i] = {"floor", "simple", "Outside"}
  end
  for i = 16, 23 do
    block_info[i] = {"floor", "simple", "Inside"}
  end
  for i = 24, 40 do
    block_info[i] = {"object"}
  end
  for i = 41, 58 do
    block_info[i] = {"floor", "simple", "Road"}
  end
  block_info[59] = {"floor", "decorated", "Pond"}
  block_info[60] = {"floor", "decorated", "Pond"}
  for i = 61, 64 do
    block_info[i] = {"floor", "simple", "Outside"}
  end
  block_info[65] = {"floor", "decorated", "Pond"}
  block_info[66] = {"floor", "simple", "Inside"} -- 67 is UI.
  block_info[68] = {"floor", "decorated", "Pond"}
  block_info[69] = {"floor", "decorated", "Pond"}
  block_info[70] = {"floor", "simple", "Inside"}
  for i = 71, 73 do
    block_info[i] = {"floor", "decorated", "Pond", base = 69}
  end
  block_info[76] = {"floor", "simple", "Inside"}
  for i = 77, 80 do
    block_info[i] = {"floor", "decorated", "Pond"}
  end
  for i = 114, 164 do -- 82-113 are internal walls
    local pair
    local category = "External"
    local dir = i % 2 == 0 and "north" or "west"
    if 114 <= i and i <= 127 then
      if 114 <= i and i <= 119 then
        pair = i + 8
      elseif 122 <= i and i < 127 then
        pair = i - 8
      end
    elseif 157 <= i and i <= 164 then
      category = "Doorway"
      if 157 <= i and i <= 160 then
        pair = i + 4
      elseif 161 <= i and i < 164 then
        pair = i - 4
      end
      dir = dir == "north" and "west" or "north"
    end
    for i = 128, 156 do
    block_info[i] = {"object"}
    end
    for i = 120, 121 do  -- removes the complete windows as they disappear in the game
    block_info[i] = {"object"}
    end
    if i ~= 144 and i ~= 145 and i ~= 156 then
      block_info[i] = {"wall", dir, category, pair = pair}
    end
  end
  for i = 176, 191 do
    block_info[i] = {"floor", "decorated", "Hegderow", base = 2}
  end
  for i = 192, 196 do
    block_info[i] = {"floor", "decorated", "Foliage", base = 2}
  end
  for i = 197, 204 do
    block_info[i] = {"floor", "decorated", "Foliage", base = 2}
  end
  for i = 205, 208 do
    block_info[i] = {"floor", "simple", "Outside"}
  end
  block_info[208].base = 3
  -- adds street lights, could do with mirrors of these to have lamps facing different directions
  for i = 209, 210 do
  local pair
  local category = "External"
  local dir = i % 2 == 0 and "north" or "west"
  if i ~= 209 then
    pair = i - 1
  end
  block_info[i] = {"wall", dir, category, pair = pair}
  end

  --XXX: MapEditorSetBlocks(self.ui.app.map.blocks, block_info) -- pass data to UI
  self.block_info = block_info
end

function UIMapEditor:draw(canvas, ...)
  local ui = self.ui
  local x, y = ui:WorldToScreen(self.mouse_cell_x, self.mouse_cell_y)
  self.cell_outline:draw(canvas, 2, x - 32, y)

  UIResizable.draw(self, canvas, ...)
end

function UIMapEditor:updateBlocks()
  for i = 1, num_visible_blocks do
    local block_num = self.block_scroll.value + i - 1
    if block_num < num_blocks then
      self.block_buttons[i]:enable(true)
      self.block_buttons[i].visable = true
      self.block_panels[i].visible = true
      self.block_panels[i].sprite_index = block_num
      self.block_buttons[i]:setToggleState(self.block_brush_preview == block_num)
    else
      self.block_buttons[i]:enable(false)
      self.block_buttons[i].visable = false
      self.block_panels[i].visible = false
    end
  end
end

function UIMapEditor:blockClicked(num)
  local block_clicked = self.block_scroll.value + num - 1
  if self.block_buttons[num].toggled then
    -- TODO: What are w1 and w2?
    self:setBlockBrush(block_clicked, 0, 0)
  else
    self:setBlockBrush(0, 0, 0)
  end

  self:updateBlocks()
end

function UIMapEditor:onMouseMove(x, y, dx, dy)
  local repaint = Window.onMouseMove(self, x, y, dx, dy)

  local ui = self.ui
  local wxr, wyr = ui:ScreenToWorld(self.x + x, self.y + y)
  local wx = math_floor(wxr)
  local wy = math_floor(wyr)
  local map = self.ui.app.map

  -- Update the stored state of cursor position, and trigger a repaint as the
  -- cell outline sprite should track the cursor position.
  if wx ~= self.mouse_cell_x or wy ~= self.mouse_cell_y then
    repaint = true
    self.mouse_cell_x = wx
    self.mouse_cell_y = wy
    -- Right button down: sample the block under the cursor (unless left is
    -- held, as that indicates a paint in progress).
    if self.buttons_down.mouse_right and not self.buttons_down.mouse_left then
      self:sampleBlock(x, y)
    end
  end

  -- Left button down: Expand / contract the rectangle which will be painted to
  -- include the original mouse down cell and the current cell, or clear the
  -- rectangle if the cursor is returned to where the mouse down position.
  if self.buttons_down.mouse_left and self.paint_rect and 1 <= wx and 1 <= wy
  and wx <= map.width and wy <= map.height then
    local p1x = math_floor(self.paint_start_wx)
    local p1y = math_floor(self.paint_start_wy)
    local p2x = wx
    local p2y = wy
    local x, y, w, h
    if p1x < p2x then
      x = p1x
      w = p2x - p1x + 1
    else
      x = p2x
      w = p1x - p2x + 1
    end
    if p1y < p2y then
      y = p1y
      h = p2y - p1y + 1
    else
      y = p2y
      h = p1y - p2y + 1
    end
    if w*h > 1 then
      -- The paint rectangle extends beyond the original mouse down cell, so
      -- make the area in the middle of said cell into a "null area" so that
      -- the paint operation can be cancelled by returning the cursor to this
      -- area and ending the drag.
      self.has_paint_null_area = true
    elseif w == 1 and h == 1 and self.has_paint_null_area then
      if ((wxr % 1) - 0.5)^2 + ((wyr % 1) - 0.5)^2 < 0.25^2 then
        w = 0
        h = 0
      end
    end
    local rect = self.paint_rect
    if x ~= rect.x or y ~= rect.y or w ~= rect.w or h ~= rect.h then
      self:setPaintRect(x, y, w, h)
      repaint = true
    end
  end

  return repaint
end

function UIMapEditor:onMouseDown(button, x, y)
  local repaint = false
  local map = self.ui.app.map.th
  if button == "right" then
    if self.buttons_down.mouse_left then
      -- Right click while left is down: set paint step size
      local wx, wy = self.ui:ScreenToWorld(x, y)
      local xstep = math.max(1, math.abs(math.floor(wx) - math.floor(self.paint_start_wx)))
      local ystep = math.max(1, math.abs(math.floor(wy) - math.floor(self.paint_start_wy)))
      local rect = self.paint_rect
      self:setPaintRect(rect.x, rect.y, rect.w, rect.h, xstep, ystep)
      repaint = true
    else
      -- Normal right click: sample the block under the cursor
      self:sampleBlock(x, y)
    end
  elseif button == "left" then
    self.current_command = CompoundCommand()
    self.current_command_cell = SetMapCellCommand(map)
    self.current_command_cell_flags = SetMapCellFlagsCommand(map)
    self:startPaint(x, y)
    repaint = true
  elseif button == "left_double" then
    self.current_command = CompoundCommand()
    self.current_command_cell = SetMapCellCommand(map)
    self.current_command_cell_flags = SetMapCellFlagsCommand(map)
    self:doLargePaint(x, y)
    -- Set a dummy paint rect for the mouse up event.
    self:setPaintRect(0, 0, 0, 0)
    repaint = true
  end

  return Window.onMouseDown(self, button, x, y) or repaint
end

function UIMapEditor:onMouseUp(button, x, y)
  local repaint = false
  if button == "left" and self.paint_rect then
    self:finishPaint(true)
    if #self.current_command_cell.paint_list ~=0 then
      self.current_command:addCommand(self.current_command_cell)
    end
    if #self.current_command_cell_flags.paint_list ~= 0 then
      self.current_command:addCommand(self.current_command_cell_flags)
    end
    self.command_stack:add(self.current_command)
    repaint = true
  end

  return Window.onMouseUp(self, button, x, y) or repaint
end

function UIMapEditor:startPaint(x, y)
  -- Save the Lua world coordinates of where the painting started.
  self.paint_start_wx, self.paint_start_wy = self.ui:ScreenToWorld(x, y)
  -- Initialise an empty paint rectangle.
  self.paint_rect = {
    x = math_floor(self.paint_start_wx),
    y = math_floor(self.paint_start_wy),
    w = 0, h = 0,
  }
  self.has_paint_null_area = false
  -- Check that starting point isn't out of bounds
  local map = self.ui.app.map
  if self.paint_rect.x < 1 or self.paint_rect.y < 1
  or self.paint_rect.x > map.width or self.paint_rect.y > map.height then
    self.paint_rect = nil
    return
  end
  -- Reset the paint step.
  self.paint_step_x = 1
  self.paint_step_y = 1
  -- Extend the paint rectangle to the single cell.
  self:setPaintRect(self.paint_rect.x, self.paint_rect.y, 1, 1)
end

-- Injective function from NxN to N which allows for a pair of positive
-- integers to be combined into a single value suitable for use as a key in a
-- table.
local function combine_ints(x, y)
  local sum = x + y
  return y + sum * (sum + 1) / 2
end

function UIMapEditor:doLargePaint(x, y)
  -- Perform a "large" paint. At the moment, this is triggered by a double
  -- left click, and results in a floor tile "flood fill" operation.

  -- Get the Lua tile coordinate of the tile to start filling from.
  x, y = self.ui:ScreenToWorld(x, y)
  x = math_floor(x)
  y = math_floor(y)
  if x <= 0 or y <= 0 then
    return
  end

  -- The click which preceeded the double click should have set "old_floors"
  -- with the contents of the tile prior to the single click.
  if not self.old_floors then
    return
  end
  -- brush_f is the tile which is to be painted
  local brush_f = self.block_brush_f
  if not brush_f or brush_f == 0 then
    return
  end
  local map = self.ui.app.map.th
  local key = combine_ints(x, y)
  -- match_f is the tile which is to be replaced by brush_f
  local match_f = self.old_floors[key]
  if not match_f then
    return
  end
  match_f = match_f % 256 -- discard shadow flags, etc.
  -- If the operation wouldn't change anything, don't do it.
  if match_f == brush_f then
    return
  end

  -- Reset the starting tile as to simplify the upcoming loop.
  self.current_command_cell:addTile(x, y, 1, match_f)
  map:setCell(x, y, 1, match_f)


  local to_visit = {[key] = {x, y}}
  local visited = {[key] = true}
  -- Mark the tiles beyond the edge of the map as visited, as to prevent the
  -- pathfinding from exceeding the bounds of the map.
  local size = map:size()
  for i = 1, size do
    visited[combine_ints(0, i)] = true
    visited[combine_ints(i, 0)] = true
    visited[combine_ints(size + 1, i)] = true
    visited[combine_ints(i, size + 1)] = true
  end
  -- When a tile is added to "visited" to the first time, also add it to
  -- "to_visit". This ensures each tile is visited no more than once.
  setmetatable(visited, {__newindex = function(t, k, v)
    rawset(t, k, v)
    to_visit[k] = v
  end})
  -- Iterate over the tiles to visit, and if they are suitable for replacement,
  -- do the replacement and add their neighbours to the list of things to do.
  repeat
    x = to_visit[key][1]
    y = to_visit[key][2]
    to_visit[key] = nil
    local f = map:getCell(x, y)
    if f % 256 == match_f then
      self.current_command_cell:addTile(x, y, 1, f - match_f + brush_f)
      map:setCell(x, y, 1, f - match_f + brush_f)
      visited[combine_ints(x, y + 1)] = {x, y + 1}
      visited[combine_ints(x, y - 1)] = {x, y - 1}
      visited[combine_ints(x + 1, y)] = {x + 1, y}
      visited[combine_ints(x - 1, y)] = {x - 1, y}
    end
    to_visit[key] = nil
    key = next(to_visit)
  until not key
end

-- Remove the paint preview from the UI layer, and optionally apply the paint
-- to the actual layers.
function UIMapEditor:finishPaint(apply)
  -- Grab local copies of all the fields which we need
  local map = self.ui.app.map.th
  local brush_f = self.block_brush_f
  local brush_parcel = self.block_brush_parcel
  if brush_parcel then
    brush_parcel = {parcelId = brush_parcel}
  end
  local brush_w1 = self.block_brush_w1
  local brush_w1p = (self.block_info[brush_w1] or '').pair
  local brush_w2 = self.block_brush_w2
  local brush_w2p = (self.block_info[brush_w2] or '').pair
  local x_first, x_last = self.paint_rect.x, self.paint_rect.x + self.paint_rect.w - 1
  local y_first, y_last = self.paint_rect.y, self.paint_rect.y + self.paint_rect.h - 1
  local step_base_x = math.floor(self.paint_start_wx)
  local step_base_y = math.floor(self.paint_start_wy)
  local xstep = self.paint_step_x
  local ystep = self.paint_step_y

  -- Determine what kind of thing is being painted.
  local is_wall = self.block_info[self.block_brush_preview]
  is_wall = is_wall and is_wall[1] == "wall" and is_wall[2]
  local is_simple_floor = self.block_info[self.block_brush_preview]
  is_simple_floor = is_simple_floor and is_simple_floor[1] == "floor" and is_simple_floor[2] == "simple"

  -- To allow the double click handler to know what was present before the
  -- single click which preceeds it, the prior contents of the floor layer is
  -- saved.
  local old_floors = {}
  self.old_floors = old_floors
  for tx = x_first, x_last do
    for ty = y_first, y_last do
      -- Grab and save the contents of the tile
      local f, w1, w2 = map:getCell(tx, ty)
      old_floors[combine_ints(tx, ty)] = f
      local flags
      -- Change the contents according to what is being painted
      repeat
        -- If not painting, do not change anything (apart from UI layer).
        if not apply then
          break
        end
        -- If the paint is happening at an interval, do not change things
        -- apart from at the occurances of the interval.
        if ((tx - step_base_x) % xstep) ~= 0 then
          break
        end
        if ((ty - step_base_y) % ystep) ~= 0 then
          break
        end
        flags = brush_parcel
        -- If painting walls, only apply to the two edges which get painted.
        if is_wall == "north" and ty ~= y_first and ty ~= y_last then
          break
        end
        if is_wall == "west"  and tx ~= x_first and tx ~= x_last then
          break
        end
        -- If painting a floor component, apply it.
        if not brush_parcel and brush_f and brush_f ~= 0 then
          f = f - (f % 256) + brush_f
          -- If painting just a floor component, then remove any decoration
          -- and/or walls which get painted over.
          if is_simple_floor then
            local w1b = self.block_info[w1 % 256]
            if not w1b or w1b[1] ~= "wall" or ty ~= y_first then
              w1 = w1 - (w1 % 256)
            end
            local w2b = self.block_info[w2 % 256]
            if not w2b or w2b[1] ~= "wall" or tx ~= x_first then
              w2 = w2 - (w2 % 256)
            end
          end
        end
        -- If painting wall components, apply them.
        if brush_w1 and brush_w1 ~= 0 then
          w1 = w1 - (w1 % 256) + (ty ~= step_base_y and brush_w1p or brush_w1)
        end
        if brush_w2 and brush_w2 ~= 0 then
          w2 = w2 - (w2 % 256) + (tx ~= step_base_x and brush_w2p or brush_w2)
        end
      until true
      -- Remove the UI layer and perform the adjustment of the other layers.
      self.current_command_cell:addTile(tx,ty,f,w1,w2,0)
      map:setCell(tx, ty, f, w1, w2, 0)
      if flags then
        self.current_command_cell_flags:addTile(tx, ty, flags)
        map:setCellFlags(tx, ty, flags)
      end
    end
  end
  map:updateShadows()

end

-- Move/resize the rectangle to be painted, and update the UI preview layer
-- to reflect the new rectangle.
function UIMapEditor:setPaintRect(x, y, w, h, xstep, ystep)
  local map = self.ui.app.map.th
  local rect = self.paint_rect
  local old_xstep = self.paint_step_x or 1
  local old_ystep = self.paint_step_y or 1
  local step_base_x = math.floor(self.paint_start_wx)
  local step_base_y = math.floor(self.paint_start_wy)
  xstep = xstep or old_xstep
  ystep = ystep or old_ystep

  -- Create a rectangle which contains both the old and new rectangles, as
  -- this contains all tiles which may need to change.
  local left, right, top, bottom = x, x + w - 1, y, y + h - 1
  if rect then
    if rect.x < left then
      left = rect.x
    end
    if rect.x + rect.w - 1 > right then
      right = rect.x + rect.w - 1
    end
    if rect.y < top then
      top = rect.y
    end
    if rect.y + rect.h - 1 > bottom then
      bottom = rect.y + rect.h - 1
    end
  end

  -- Determine what kind of thing is being painted
  local is_wall = self.block_info[self.block_brush_preview]
  local block_brush_preview_pair = is_wall and is_wall.pair
  is_wall = is_wall and is_wall[1] == "wall" and is_wall[2]

  for tx = left, right do
    for ty = top, bottom do
      local now_in, was_in
      -- Non-walls: paint at every tile within the rectangle
      if not is_wall then
        now_in = (x <= tx and tx < x + w and y <= ty and ty < y + h)
        was_in = (rect.x <= tx and tx < rect.x + rect.w and rect.y <= ty and ty < rect.y + rect.h)
      -- Walls: paint at two edges of the rectangle
      elseif is_wall == "north" then
        now_in = (x <= tx and tx < x + w and (y == ty or ty == y + h - 1))
        was_in = (rect.x <= tx and tx < rect.x + rect.w and (rect.y == ty or ty == rect.y + rect.h - 1))
      elseif is_wall == "west" then
        now_in = ((x == tx or tx == x + w - 1) and y <= ty and ty < y + h)
        was_in = ((rect.x == tx or tx == rect.x + rect.w - 1) and rect.y <= ty and ty < rect.y + rect.h)
      end
      -- Restrict the paint to tiles which fall on the appropriate intervals
      now_in = now_in and ((tx - step_base_x) % xstep) == 0
      now_in = now_in and ((ty - step_base_y) % ystep) == 0
      was_in = was_in and ((tx - step_base_x) % old_xstep) == 0
      was_in = was_in and ((ty - step_base_y) % old_ystep) == 0
      -- Update the tile, but only if it needs changing
      if now_in ~= was_in then
        local ui_layer = 0
        if now_in then
          local brush = self.block_brush_preview
          if is_wall == "north" and ty ~= step_base_y then
            brush = block_brush_preview_pair or brush
          end
          if is_wall == "west" and tx ~= step_base_x then
            brush = block_brush_preview_pair or brush
          end
          ui_layer = brush + 256 * DrawFlags.Alpha50
        end
        self.current_command_cell:addTile(tx, ty, 4, ui_layer)
        map:setCell(tx, ty, 4, ui_layer)
      end
    end
  end

  -- Save the details of the new rectangle
  if not rect then
    rect = {}
    self.paint_rect = rect
  end
  rect.x = x
  rect.y = y
  rect.w = w
  rect.h = h
  self.paint_step_x = xstep
  self.paint_step_y = ystep
end

function UIMapEditor:sampleBlock(x, y)
  local ui = self.ui
  local wx, wy = self.ui:ScreenToWorld(x, y)
  wx = math_floor(wx)
  wy = math_floor(wy)
  local map = self.ui.app.map
  if wx < 1 or wy < 1 or wx > map.width or wy > map.height then
    return
  end
  local floor, wall1, wall2 = map.th:getCell(wx, wy)
  local set = {}
  set[floor % 256] = true
  set[wall1 % 256] = true
  set[wall2 % 256] = true
  if wx < map.width then
    floor, wall1, wall2 = map.th:getCell(wx + 1, wy)
    set[wall2 % 256] = true
  end
  if wy < map.height then
    floor, wall1, wall2 = map.th:getCell(wx, wy + 1)
    set[wall1 % 256] = true
  end
  set[0] = nil
  local floor_list = {}
  local wall_list = {}
  for i in pairs(set) do
    if self.block_info[i] then
      if self.block_info[i][1] == "floor" then
        floor_list[#floor_list + 1] = i
      elseif self.block_info[i][1] == "wall" then
        wall_list[#wall_list + 1] = i
      end
    end
  end

  if wx == self.recent_sample_x and wy == self.recent_sample_y then
    self.sample_i = self.sample_i + 1
  else
    self.sample_i = 1
    self.recent_sample_x = wx
    self.recent_sample_y = wy
  end
  -- XXX: MapEditorSetBlockBrush(
  --  floor_list[1 + (self.sample_i - 1) % #floor_list] or 0,
  --  wall_list [1 + (self.sample_i - 1) % #wall_list ] or 0
  -- )
end

-- Called by the UI to set what should be painted.
function UIMapEditor:setBlockBrush(f, w1, w2)
  local preview = f
  if w2 ~= 0 then
    preview = w2
  elseif w1 ~= 0 then
    preview = w1
  end
  self.block_brush_preview = preview
  self.block_brush_parcel = nil
  self.block_brush_f = f
  self.block_brush_w1 = w1
  self.block_brush_w2 = w2
end

function UIMapEditor:setBlockBrushParcel(parcel)
  self.block_brush_preview = 24
  self.block_brush_parcel = parcel
  self.block_brush_f = self.block_brush_preview
  self.block_brush_w1 = 0
  self.block_brush_w2 = 0
end

function UIMapEditor:undo()
  local last = self.command_stack:undo()
  self.ui.app.map.th:updateShadows()
  return last
end

function UIMapEditor:redo()
  local last = self.command_stack:redo()
  self.ui.app.map.th:updateShadows()
  return last
end
