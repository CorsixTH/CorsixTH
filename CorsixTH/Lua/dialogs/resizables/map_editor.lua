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

class "UIMapEditor" (UIResizable)

---@type UIMapEditor
local UIMapEditor = _G["UIMapEditor"]

local col_bg = {red = 154, green = 146, blue = 198}

-- {{{ Editor sprites.

-- Unfortunately, current map file format does not support flags like FLIP_H.
-- Commented this out until flags can be stored in the file created by the map editor.
-- -- High byte sprite constants.
-- local FLIP_H = DrawFlags.FlipHorizontal * 256

-- Each variable below is an array of multi-tile sprites, which is translated
-- to a list of buttons at a page.
-- The generic form of a multi-tile sprite (see the helipad for an example) is
-- a table {sprites = .., height = .., objects = ..}. The 'height' defines the
-- height of the displayed button (between 1 and MAX_HEIGHT). The 'sprites' is
-- an array of single sprites, a table of {sprite = ..., xpos = ..., ypos =
-- ..., type = ...}. It defines which sprite to display at which relative
-- position. Positions run from 1 upward, sprites are numbers 0..255 (the low
-- byte).
-- The high byte is reserved for adding DrawFlags flags in the future, eg FLIP_H.
--
-- The type defines where the sprite is stored. 'north' and 'west' mean north
-- respectively west wall. 'floor' means it is a floor sprite. 'hospital' is
-- also a floor sprite but it also states that the tile is part of the
-- hospital. Similarly, 'road' is a floor sprite outside the hospital that can
-- be walked on. Finally, the 'objects' defines the position of objects in the
-- shape. At this time, only an entrance door can be placed.
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
  {sprite= 17, height=1, type="hospital"}, -- Dark blue/purple carpet tile
  {sprite= 70, height=1, type="hospital"}, -- Duplicate of 017
  {sprite= 18, height=1, type="hospital"}, -- Red-Blue floor tile 1
  {sprite= 19, height=1, type="hospital"}, -- Red-Blue floor tile 2
  {sprite= 23, height=1, type="hospital"}, -- Red-Blue floor tile 3
  {sprite= 16, height=1, type="hospital"}, -- Dark big checker pattern tile
  {sprite= 21, height=1, type="hospital"}, -- Small checker pattern tile
  {sprite= 22, height=1, type="hospital"}, -- Big checker pattern tile
  {sprite= 66, height=1, type="hospital"}, -- Floor tile with light center
  {sprite= 76, height=1, type="hospital"}, -- Floor tile with light center and corners
  {sprite= 20, height=1, type="hospital"}  -- Wooden floor tile
}
-- }}}
-- {{{ Outside floor sprites.
local outside={
  {sprite=  1, height=1, type="floor"}, -- Grass tile 1
  {sprite=  2, height=1, type="floor"}, -- Grass tile 2
  {sprite=  3, height=1, type="floor"}, -- Grass tile 3
  {sprite=  4, height=1, type="road" }, -- Light concrete tile
  {sprite= 15, height=1, type="road" }, -- Concrete tile
  {sprite=  5, height=1, type="road" }, -- Dark concrete tile
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
  {sprite= 41, height=1, type="road"}, -- Road with white discontinuous line North-South
  {sprite= 45, height=1, type="road"}, -- Road with double yellow lines at West edge merging at South
--{sprite= 46, height=1, type="road"}, -- Duplicate of 45
  {sprite= 42, height=1, type="road"}, -- Road with double yellow lines at West with black orthogonal lines
  {sprite= 43, height=1, type="road"}, -- Road with double yellow lines at West edge
  {sprite= 44, height=1, type="road"}, -- Road with double yellow lines at West edge merging at North
  {sprite= 47, height=1, type="road"}, -- Road with red line at East linked to yellow discontinuous line at South
  {sprite= 49, height=1, type="road"}, -- Road with red braking line at the East pointing to the West
  {sprite= 48, height=1, type="road"}, -- Road with red line at East linked to yellow discontinuous line at North
  {sprite= 53, height=1, type="road"}, -- Road with double yellow lines at East edge merging at the south
  {sprite= 52, height=1, type="road"}, -- Road with double yellow lines at East with black orthogonal lines
--{sprite= 54, height=1, type="road"}, -- Duplicate of 52
  {sprite= 51, height=1, type="road"}, -- Road with double yellow lines at East edge
  {sprite= 57, height=1, type="road"}, -- Road with red line at West linked to yellow discontinuous line at South
  {sprite= 55, height=1, type="road"}, -- Road with red braking line at the West pointing to the East
  {sprite= 56, height=1, type="road"}, -- Road with red line at West linked to yellow discontinuous line at North
  {sprite= 50, height=1, type="road"}, -- Road with grey edge at the East
  {sprite= 58, height=1, type="road"}, -- Road with grey edge at the West
}
local road = {} -- All sprites get horizontally flipped as well, for roads running north-south.
for _, spr in ipairs(road_spr) do
  road[#road + 1] = spr

  -- Unfortunately, current map file format does not support flags like FLIP_H.
  -- Commented this out until flags can be stored in the file created by the map editor.
  -- road[#road + 1] = {sprite = spr.sprite + FLIP_H, height = spr.height, type = spr.type}
end
-- }}}
-- {{{ North wall layout and floor sprites.
local north_wall = {
  {sprites = {
    {sprite=159, xpos=1, ypos=1, type="north"}, -- External doorway North outside left part
    {sprite=157, xpos=3, ypos=1, type="north"}, -- External doorway North outside right part
    },
   height = 3,
   objects = {{type="entrance_door", xpos=2, ypos=1, direction="north"}},
  },

  {sprites = {
    {sprite=163, xpos=1, ypos=1, type="north"}, -- External doorway North inside left part
    {sprite=161, xpos=3, ypos=1, type="north"}, -- External doorway North inside right part
    },
   height = 3,
   objects = {{type="entrance_door", xpos=2, ypos=1, direction="north"}},
  },

  {sprite=114, height=3, type="north"}, -- External North wall outside
  {sprite=116, height=3, type="north"}, -- External North wall outside left part of window
  {sprite=120, height=3, type="north"}, -- External North wall with window
  {sprite=118, height=3, type="north"}, -- External North wall outside right part of window
  {sprite=122, height=3, type="north"}, -- External North wall inside
  {sprite=124, height=3, type="north"}, -- External North wall inside left part of window
  {sprite=126, height=3, type="north"}, -- External North wall inside right part of window
-- Unfortunately, current map file format does not support flags like FLIP_H.
-- Commented this out until flags can be stored in the file created by the map editor.
--  {sprite=209 + FLIP_H, height=3, type="north"}, -- Lamp post pointing East
--  {sprite=210 + FLIP_H, height=3, type="north"}, -- Lamp post pointing West
}
-- }}}
-- {{{ West wall layout and floor sprites.
local west_wall = {
  {sprites = {
    {sprite=158, xpos=1, ypos=3, type="west"}, -- External doorway West outside left part
    {sprite=160, xpos=1, ypos=1, type="west"}, -- External doorway West outside right part
    },
   height = 3,
   objects = {{type="entrance_door", xpos=1, ypos=2, direction="west"}},
  },

  {sprites = {
    {sprite=162, xpos=1, ypos=3, type="west"}, -- External doorway West inside left part
    {sprite=164, xpos=1, ypos=1, type="west"}, -- External doorway West inside right part
    },
   height = 3,
   objects = {{type="entrance_door", xpos=1, ypos=2, direction="west"}},
  },

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
    {sprite=5, xpos=1, ypos=1, type="road"},
    {sprite=5, xpos=2, ypos=1, type="road"},
    {sprite=5, xpos=3, ypos=1, type="road"},
    {sprite=5, xpos=4, ypos=1, type="road"},
    {sprite=5, xpos=5, ypos=1, type="road"},

    {sprite=5, xpos=1, ypos=2, type="road"},
    {sprite=5, xpos=1, ypos=3, type="road"},
    {sprite=5, xpos=1, ypos=4, type="road"},
    {sprite=5, xpos=1, ypos=5, type="road"},

    {sprite=5, xpos=2, ypos=5, type="road"},
    {sprite=5, xpos=3, ypos=5, type="road"},
    {sprite=5, xpos=4, ypos=5, type="road"},

    {sprite=5, xpos=5, ypos=5, type="road"},
    {sprite=5, xpos=5, ypos=2, type="road"},
    {sprite=5, xpos=5, ypos=3, type="road"},
    {sprite=5, xpos=5, ypos=4, type="road"},
    -- Dark tiles in the 'H'
    {sprite=5, xpos=3, ypos=2, type="road"},
    {sprite=5, xpos=3, ypos=4, type="road"},
    -- Light tiles in the 'H'
    {sprite=4, xpos=2, ypos=2, type="road"},
    {sprite=4, xpos=2, ypos=3, type="road"},
    {sprite=4, xpos=2, ypos=4, type="road"},
    {sprite=4, xpos=4, ypos=2, type="road"},
    {sprite=4, xpos=4, ypos=3, type="road"},
    {sprite=4, xpos=4, ypos=4, type="road"},
    {sprite=4, xpos=3, ypos=3, type="road"}
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

  if spr.sprites == nil then -- {sprite = xxx, height = y} case
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
            height = spr.height,
            objects = spr.objects}
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

local EDITOR_WINDOW_XSIZE = 368
local EDITOR_WINDOW_YSIZE = 586
local EDITOR_COLUMNS = 10 -- Number of columns for the sprite buttons
local EDITOR_COLUMN_SIZE = 32 + 3 -- Width of a sprite button in pixels
local EDITOR_ROW_SIZE = 32 + 4 -- Height of a sprite button in pixels

function UIMapEditor:UIMapEditor(ui)
  self:UIResizable(ui, EDITOR_WINDOW_XSIZE, EDITOR_WINDOW_YSIZE, col_bg)
  self.resizable = false

  self.ui = ui
  self.panel_sprites = self.ui.app.map.blocks

  -- For when there are multiple things which could be sampled from a tile,
  -- keep track of the index of which one was most recently sampled, so that
  -- next time a different one is sampled.
  self.sample_i = 1

  -- Cursor data in the main world view.
  -- States:
  --  - disabled: Just show the cursor.
  --  - grid: Show an area with red rectangles (requires 'sprite' to exist).
  --  - left: Dragging with left mouse button is down, (leftx, lefty) defines the tile.
  --  - right: Dragging with right mouse button down, (rightx, righty) defines the tile.
  --  - both: Dragging with both left and right mouse buttons down (initiated with left
  --          button), (rightx, righty) defines the tile where right button got pressed.
  --  - delete: Like grid, with a 1x1 cursor for selecting tiles to remove walls from.
  --  - delete-left: Left mouse button drag of 'delete' mode.
  --  - parcel: Like grid, with a 1x1 cursor for selecting tiles to set the parcel.
  --  - parcel-left: Left mouse button drag of 'parcel' mode.
  --  - paste: Like grid, with a copy_xsize, copy_ysize cursor to show where to paste.
  --  - paste-left: Left mouse button drag of 'paste' mode. Pasting is limited to dragged
  --                area (which can be smaller than (copy_xsize, copy_ysize) area).
  --  - camera: Like grid, with a 1x1 cursor for selecting tile to set the camera
  --  - heliport: Like grid, with a 1x1 cursor for selecting tile to set the heliport
  --
  -- Notes:
  --  - The code switches back to 'grid' or 'disabled' without waiting for all
  --    buttons getting released.
  --  - Nothing gets added in the world until you let go of a mouse button.
  --  - Drag detection ('is_drag') is used to allow cancel if user moves back
  --    to the (leftx, lefty) position.
  --  - The sprite decides how you can drag (none, north-south, east-west, area)
  --
  self.cursor = {
    state = "disabled", -- State of the cursor.
    sprite = nil,       -- Selected sprite from the menu.
    is_drag = false,    -- Whether a true drag (at least 2 cells covered) has been detected.
    parcel = nil,       -- Parcel number to set in 'parcel' / 'parcel-left' mode.
    camera = nil,       -- Camera player to set in 'camera' mode.
    heliport = nil,     -- Heliport player to set in 'heliport' mode.

    xpos = 0,   -- Horizontal tile position of the mouse cursor.
    ypos = 0,   -- Vertical tile position of the mouse cursor.

    leftx = 0,  -- Horizontal tile position where the left-click was first detected.
    lefty = 0,  -- Vertical   tile position where the left-click was first detected.
    rightx = 0, -- Horizontal tile position where the right-click was first detected.
    righty = 0, -- Vertical   tile position where the right-click was first detected.

    copy_data = nil, -- Data of the copied area, 'nil' if no data available.
    copy_xsize = 0,  -- Horizontal size of the copy area.
    copy_ysize = 0,  -- Vertical size of the copy area.
  }

  -- {{{ Creation of buttons.
  -- A sprite table containing a "cell outline" sprite
  self.cell_outline = TheApp.gfx:loadSpriteTable("Bitmap", "aux_ui", true)

  self:addBevelPanel(0, 0, EDITOR_WINDOW_XSIZE, EDITOR_WINDOW_YSIZE, col_bg) -- Background of the window.

  self.block_buttons = {} -- List of table {button = .., panel = ..}
  self.selected_block = nil -- Page of of block buttons currently displayed/selected.

  -- Make the page selection buttons
  local XSTART = 10
  local XSIZE = 109
  local YSIZE = 20

  local ypos = 10
  local xpos = XSTART
  self.page_selectbuttons = {}
  for _, page in ipairs(PAGES) do
    local name = page.name
    if xpos + XSIZE >= EDITOR_WINDOW_XSIZE then -- Update ypos (and xpos) if necessary.
      xpos = XSTART
      ypos = ypos + YSIZE + 2
    end

    local p = self:addBevelPanel(xpos, ypos, XSIZE, YSIZE, col_bg)
                  :setLabel(name):makeToggleButton(0, 0, XSIZE, YSIZE, nil,
                    --[[persistable:map_editor_spritepage_clicked]] function() self:pageClicked(name) end)
    local spr_buttons = layoutButtons(page.spr_data, EDITOR_COLUMNS)
    local page_data = {button = p, name = name, sprite_buttons = spr_buttons}

    self.page_selectbuttons[#self.page_selectbuttons + 1] = page_data
    xpos = xpos + XSIZE + 10
  end
  -- Make the bottom text buttons
  xpos = XSTART
  ypos = 420

  local text_pages = {
    {name = "paste",    text = _S.map_editor_window.pages.paste},
    {name = "delete_wall", text = _S.map_editor_window.pages.delete_wall},
    {name = "parcel_0", text = _S.map_editor_window.pages.parcel_0, parcel = 0},
    {name = "parcel_1", text = _S.map_editor_window.pages.parcel_1, parcel = 1},
    {name = "parcel_2", text = _S.map_editor_window.pages.parcel_2, parcel = 2},
    {name = "parcel_3", text = _S.map_editor_window.pages.parcel_3, parcel = 3},
    {name = "parcel_4", text = _S.map_editor_window.pages.parcel_4, parcel = 4},
    {name = "parcel_5", text = _S.map_editor_window.pages.parcel_5, parcel = 5},
    {name = "parcel_6", text = _S.map_editor_window.pages.parcel_6, parcel = 6},
    {name = "parcel_7", text = _S.map_editor_window.pages.parcel_7, parcel = 7},
    {name = "parcel_8", text = _S.map_editor_window.pages.parcel_8, parcel = 8},
    {name = "parcel_9", text = _S.map_editor_window.pages.parcel_9, parcel = 9},
    {name = "camera_1", text = _S.map_editor_window.pages.camera_1, camera = 1},
    {name = "camera_2", text = _S.map_editor_window.pages.camera_2, camera = 2},
    {name = "camera_3", text = _S.map_editor_window.pages.camera_3, camera = 3},
    {name = "camera_4", text = _S.map_editor_window.pages.camera_4, camera = 4},
    {name = "heliport_1", text = _S.map_editor_window.pages.heliport_1, heliport = 1},
    {name = "heliport_2", text = _S.map_editor_window.pages.heliport_2, heliport = 2},
    {name = "heliport_3", text = _S.map_editor_window.pages.heliport_3, heliport = 3},
    {name = "heliport_4", text = _S.map_editor_window.pages.heliport_4, heliport = 4}}

  for _, page in ipairs(text_pages) do
    if xpos + XSIZE >= EDITOR_WINDOW_XSIZE then -- Update ypos (and xpos) if necessary.
      xpos = XSTART
      ypos = ypos + YSIZE + 2
    end

    local name = page.name
    local p = self:addBevelPanel(xpos, ypos, XSIZE, YSIZE, col_bg)
                  :setLabel(page.text):makeToggleButton(0, 0, XSIZE, YSIZE, nil,
                    --[[persistable:map_editor_textpage_clicked]] function() self:pageClicked(name) end)
    local page_data = {button = p, name = name, data = page}
    self.page_selectbuttons[#self.page_selectbuttons + 1] = page_data
    xpos = xpos + XSIZE + 10
  end
  self:pageClicked("") -- Initialize all above 'page_selectbuttons'.

  -- }}}

  self:setPosition(0.1, 0.1)
end

function UIMapEditor:setPlayerCount(count)
  local map = self.ui.app.map
  map:setPlayerCount(count)
  if self.cursor.state == "camera" or self.cursor.state == "heliport" then
    map:updateDebugOverlay()
  end
end

-- {{{ function UIMapEditor:pageClicked(name)

--! Update how the button is displayed based on the provided new state.
--!param button (Panel) to update.
--!param action (str) New state of the button.
local function updateToggleButton(button, action)
  if action == "raised" then
    button:enable(true)
    button:setVisible(true)
    button:setToggleState(false)

  elseif action == "lowered" then
    button:enable(true)
    button:setVisible(true)
    button:setToggleState(true)

  elseif action == "invisible" then
    button:enable(false)
    button:setVisible(false)

  elseif action == "disabled" then
    button:enable(false)
    button:setVisible(true)
    button:setToggleState(false)

  else
    assert(false) -- Should never arrive here
  end
end

--! Callback function of the page select buttons.
--!param name (string) Name of the clicked page.
function UIMapEditor:pageClicked(name)
  local map = self.ui.app.map
  if name == "paste" then
    -- Make 'paste' button non-selectable if there is no data to paste.
    name = self.cursor.copy_data and name or ""
  else
    self.cursor.copy_data = nil -- Delete copied area when selecting another item.
  end

  for _, pb in ipairs(self.page_selectbuttons) do
    if pb.name == name then
      map:clearDebugText()
      self.cursor.state = name == "paste" and "paste" or "disabled"
      updateToggleButton(pb.button, "lowered")
      if pb.sprite_buttons then
        -- 'sprite' button, display sprites to select from, by the user.
        self:buildSpriteButtons(pb.sprite_buttons)
      else
        -- 'text' button, switch cursor to the right mode directly.
        self:buildSpriteButtons({})
        if pb.name == "delete_wall" then
          self.cursor.state = "delete"
          self.cursor.sprite = nil
          self.cursor.is_drag = false

        elseif pb.name == "paste" then
          self.cursor.state = "paste"
          self.cursor.sprite = nil
          self.cursor.is_drag = false

        elseif pb.data.camera then
          self.cursor.state = "camera"
          self.cursor.spirte = nil
          self.cursor.is_drag = false
          self.cursor.camera = pb.data.camera
          map:loadDebugText("camera")

        elseif pb.data.heliport then
          self.cursor.state = "heliport"
          self.cursor.spirte = nil
          self.cursor.is_drag = false
          self.cursor.heliport = pb.data.heliport
          map:loadDebugText("heliport")

        else -- Should be a parcel button.
          assert(pb.data.parcel)

          self.cursor.state = "parcel"
          self.cursor.sprite = nil
          self.cursor.is_drag = false
          self.cursor.parcel = pb.data.parcel
          map:loadDebugText("parcel")
        end
      end

    elseif pb.name == "paste" and not self.cursor.copy_data then
      updateToggleButton(pb.button, "disabled")
    else
      updateToggleButton(pb.button, "raised")
    end
  end
end

--! Do layout of the sprite buttons of the page.
function UIMapEditor:buildSpriteButtons(buttons)
  self.selected_block = buttons

  local XBASE = 10
  local YBASE = 83
  local number = 1
  for _, button in ipairs(buttons) do
    local xpos = XBASE + (button.column - 1) * EDITOR_COLUMN_SIZE
    local ypos = YBASE + (button.row - 1) * EDITOR_ROW_SIZE
    local width = EDITOR_COLUMN_SIZE * button.width - 2
    local height = EDITOR_ROW_SIZE * button.height - 2

    local pb = self.block_buttons[number]
    if pb == nil then -- New sprite button needed
      local bbutton_number = number
      local bbutton = self:addBevelPanel(xpos, ypos, width, height, col_bg)
      bbutton = bbutton:makeToggleButton(0, 0, width, height, nil,
          --[[persistable:map_editor_block_clicked]] function() self:blockClicked(bbutton_number) end)
      updateToggleButton(bbutton, "raised")

      local bpanel = self:addPanel(number, xpos+1, ypos+1, width-2, height-2)
      bpanel.visible = true
      bpanel.editor_button = button

      bpanel.custom_draw = --[[persistable:map_editor_draw_block_sprite]] function(panel, canvas, x, y)
        x = x + panel.x + panel.editor_button.xorigin
        y = y + panel.y + panel.editor_button.yorigin
        for _, spr in ipairs(panel.editor_button.sprites) do
          local xspr = x + (spr.xpos - spr.ypos) * 32
          local yspr = y + (spr.xpos + spr.ypos) * 16 - 32
          panel.window.panel_sprites:draw(canvas, spr.sprite % 256, xspr, yspr, math.floor(spr.sprite / 256))
        end
      end

      self.block_buttons[#self.block_buttons + 1] = {button=bbutton, panel=bpanel}

    else -- Reposition & resize existing sprite button
      local bbutton = pb.button
      bbutton:setPosition(xpos, ypos)
      bbutton:setSize(width, height)
      updateToggleButton(bbutton, "raised")

      local bpanel = pb.panel
      bpanel.editor_button = button
      bpanel:setPosition(xpos+1, ypos+1)
      bpanel:setSize(width-2, height-2)
      bpanel:setVisible(true)
    end

    number = number + 1
  end

  -- Make remaining buttons and panels invisible.
  while true do
    local pb = self.block_buttons[number]
    if pb == nil then break end

    updateToggleButton(pb.button, "invisible")
    pb.panel.visible = false
    number = number + 1
  end
end
-- }}}

--! Should the given type of sprite be considered a floor sprite?
--!param sprite_type (string) Type of sprite.
--!return The (boolean) type is a floor sprite type.
local function isFloorSpriteType(sprite_type)
  return sprite_type == "floor" or sprite_type == "hospital" or sprite_type == "road"
end

--! Construct cell flags for a given kind of floor sprite.
--!param sprite_type (string) Type of sprite.
local function makeCellFlags(sprite_type)
  if sprite_type == "floor" then
    return {buildable=false, passable=false, hospital=false}

  elseif sprite_type == "road" then
    return {buildable=false, passable=true,  hospital=false}

  elseif sprite_type == "hospital" then
    return {buildable=true,  passable=true,  hospital=true}
  end
  assert(false) -- Should never get here
end

--! Get the tile area covered by two points.
--!param x1 (jnt) Horizontal coordinate of the first point.
--!param y1 (int) Vertical   coordinate of the first point.
--!param x2 (jnt) Horizontal coordinate of the second point.
--!param y2 (int) Vertical   coordinate of the second point.
--!return (4 int) Smallest horizontal, smallest vertical, largest horizontal,
--  and largest vertical coordinate.
local function getCoveredArea(x1, y1, x2, y2)
  local minx, maxx, miny, maxy
  if x1 < x2 then minx, maxx = x1, x2 else minx, maxx = x2, x1 end
  if y1 < y2 then miny, maxy = y1, y2 else miny, maxy = y2, y1 end
  return minx, miny, maxx, maxy
end

--! Get the size of an area covered by two points.
--!param x1 (jnt) Horizontal coordinate of the first point.
--!param y1 (int) Vertical   coordinate of the first point.
--!param x2 (jnt) Horizontal coordinate of the second point.
--!param y2 (int) Vertical   coordinate of the second point.
--!return (2 int) Horizontal and vertical size of the area.
local function getAreaSize(x1, y1, x2, y2)
  local minx, miny, maxx, maxy = getCoveredArea(x1, y1, x2, y2)
  return maxx - minx + 1, maxy - miny + 1
end

--! Test whether (px, py) is inside the given area.
--!param px (int) Horizontal coordinate of the point to test.
--!param py (int) Vertical   coordinate of the point to test.
--!param minx (jnt) Smallest horizontal coordinate of the area.
--!param miny (int) Smallest vertical   coordinate of the area.
--!param maxx (jnt) Largest horizontal coordinate of the area.
--!param maxy (int) Largest vertical   coordinate of the area.
--!return (bool) Whether the point is inside the given area.
local function isPointInside(px, py, minx, miny, maxx, maxy)
  return px >= minx and px <= maxx and py >= miny and py <= maxy
end


--! Compute x/y pairs to draw the cursor sprite over the area.
--!param minx (int) First horizontal position to draw the sprite.
--!param miny (int) First vertical   position to draw the sprite.
--!param maxx (int) Last horizontal position to draw the sprite.
--!param maxy (int) Last vertical   position to draw the sprite.
--!param dx (nil or int) Horizontal step size of drawing, usually same size as
--  the width of the sprite being drawn, default is 1.
--!param dy (nil or int) Vertical step size of drawing, usually same size as
--  the height of the sprite being drawn, default is 1.
--!return (array of (xpos, ypos) pairs) Points to draw the sprite cursor.
local function computeCursorSpriteAtArea(minx, miny, maxx, maxy, dx, dy)
  local coords = {}

  if not dx or not dy then dx, dy = 1, 1 end

  assert(dx > 0 and dy > 0)
  local xbase, ybase
  xbase = minx
  while xbase <= maxx do
    ybase = miny
    while ybase <= maxy do
      coords[#coords + 1] = {xpos = xbase, ypos = ybase}

      ybase = ybase + dy
    end
    xbase = xbase + dx
  end

  return coords
end

--! Compute the positions to draw the selected sprite in the world.
--!return (array of {xpos, ypos} tables) Coordinates to draw the selected sprite.
function UIMapEditor:getDrawPoints()
  if self.cursor.state == "disabled" then
    -- Nothing to compute, drop to bottom {} return.

  elseif self.cursor.state == "grid" then
    local bx, by = self:areaOnWorld(self.cursor.xpos, self.cursor.ypos,
                                    self.cursor.sprite.xsize, self.cursor.sprite.ysize)
    return {{xpos = bx, ypos = by}}

  elseif self.cursor.state == "delete" or self.cursor.state == "parcel" or
      self.cursor.state == "camera" or self.cursor.state == "heliport" or
      self.cursor.state == "paste" then
    return {{xpos = self.cursor.xpos, ypos = self.cursor.ypos}}

  elseif self.cursor.state == "left" then
    -- Simple drag (left button only).
    local minx, miny, maxx, maxy = getCoveredArea(self.cursor.leftx, self.cursor.lefty,
                                                  self.cursor.xpos, self.cursor.ypos)
    if minx ~= maxx or miny ~= maxy or not self.cursor.is_drag then
      -- Just 1 tile without starting a drag, or an area of at least two tiles.
      return computeCursorSpriteAtArea(minx, miny, maxx, maxy,
                                       self.cursor.sprite.xsize, self.cursor.sprite.ysize)
    end

  elseif self.cursor.state == "delete-left" or self.cursor.state == "parcel-left" or
      self.cursor.state == "paste-left" then
    local minx, miny, maxx, maxy = getCoveredArea(self.cursor.leftx, self.cursor.lefty,
                                                  self.cursor.xpos, self.cursor.ypos)
    if minx ~= maxx or miny ~= maxy or not self.cursor.is_drag then
      -- Just 1 tile without starting a drag, or an area of at least two tiles.
      return computeCursorSpriteAtArea(minx, miny, maxx, maxy, 1, 1)
    end

  elseif self.cursor.state == "right" then
    local minx, miny, maxx, maxy = getCoveredArea(self.cursor.rightx, self.cursor.righty,
                                                  self.cursor.xpos, self.cursor.ypos)
    if minx ~= maxx or miny ~= maxy or not self.cursor.is_drag then
      -- Just 1 tile without starting a drag, or an area of at least two tiles.
      return computeCursorSpriteAtArea(minx, miny, maxx, maxy, 1, 1)
    end

  elseif self.cursor.state == "both" then
    -- left+right drag (left initiated).
    -- Area is defined from first to last point, 'right' point must be inside the area.
    local minx, miny, maxx, maxy = getCoveredArea(self.cursor.leftx, self.cursor.lefty,
                                                  self.cursor.xpos, self.cursor.ypos)
    if minx ~= maxx or miny ~= maxy then -- Otherwise area is 1x1, either due to 'cancel', or never enlarged.
      if isPointInside(self.cursor.rightx, self.cursor.righty, minx, miny, maxx, maxy) then
        -- Get block size between left and right click.
        local dx, dy = getAreaSize(self.cursor.leftx, self.cursor.lefty,
                                   self.cursor.rightx, self.cursor.righty)
        if dx > 1 or dy > 1 then -- Otherwise, left and right click is in the same tile.
          return computeCursorSpriteAtArea(minx, miny, maxx, maxy, dx, dy)
        end
      end
    end
  end

  return {}
end

--! Fill an area of tiles with red cursor rectangles. Caller must make sure that
--   the area is completely inside the world boundaries.
--!param canvas Canvas to draw at.
--!param xpos (int) Horizontal base tile position (of the top corner).
--!param ypos (int) Vertical   base tile position (of the top corner).
--!param xsize (int) Horizontal size in tiles.
--!param ysize (int) Vertical size in tiles.
function UIMapEditor:fillCursorArea(canvas, xpos, ypos, xsize, ysize)
  local ui = self.ui
  local zoom = ui.zoom_factor

  for x = 0, xsize - 1 do
    for y = 0, ysize - 1 do
      local xcoord, ycoord = ui:WorldToScreen(xpos + x, ypos + y)
      self.cell_outline:draw(canvas, 2, math.floor(xcoord / zoom) - 32, math.floor(ycoord / zoom))
    end
  end
end

--! Draw the display (map editor window, and main world display)
--!param canvas (draw object) Canvas to draw on.
function UIMapEditor:draw(canvas, ...)
  local ui = self.ui

  -- Draw the red grid for the selected tile.
  local coords = self:getDrawPoints()
  if #coords ~= 0 then
    -- Get size of the cursor.
    local xsize, ysize
    if self.cursor.state == "delete" or self.cursor.state == "delete-left" or
        self.cursor.state == "parcel" or self.cursor.state == "parcel-left" or
        self.cursor.state == "heliport" or self.cursor.state == "camera" or
        self.cursor.state == "paste-left" or self.cursor.state == "right" then
      xsize, ysize = 1, 1
    elseif self.cursor.state == "paste" then
      xsize, ysize = self.cursor.copy_xsize, self.cursor.copy_ysize
    else
      xsize, ysize = self.cursor.sprite.xsize, self.cursor.sprite.ysize
    end
    -- Draw cursors.
    local scaled = canvas:scale(ui.zoom_factor)
    for _, coord in ipairs(coords) do
      local xpos, ypos = coord.xpos, coord.ypos
      self:fillCursorArea(canvas, xpos, ypos, xsize, ysize)
    end
    if scaled then
      canvas:scale(1)
    end
  end

  UIResizable.draw(self, canvas, ...)
end

-- {{{ several useful functions
--! User clicked at a block (a button with a sprite).
--!param num Index block number.
function UIMapEditor:blockClicked(num)
  -- Reset toggle of other block buttons.
  for bnum = 1, #self.block_buttons do
    if bnum ~= num then self.block_buttons[bnum].button:setToggleState(false) end
  end

  if self.block_buttons[num].button.toggled then
    local sprite = self.selected_block[num]
    self.cursor.state = "grid"
    self.cursor.sprite = {xsize = sprite.xsize,
                          ysize = sprite.ysize,
                          sprites = sprite.sprites,
                          objects = sprite.objects,
                          type = sprite.type}
  else
    self.cursor.state = "disabled"
    self.cursor.sprite = nil
  end
end

--! Convert mouse coordinates to tile coordinates in the world.
--!param mx (int) Mouse X screen coordinate.
--!param my (int) Mouse y screen coordinate.
--!return (int, int) Tile x,y coordinates, limited to the map.
function UIMapEditor:mouseToWorld(mx, my)
  local ui = self.ui

  local wxr, wyr = ui:ScreenToWorld(self.x + mx, self.y + my)
  local wx = math.floor(wxr)
  local wy = math.floor(wyr)
  return self:areaOnWorld(wx, wy, 1, 1)
end

--! Stay on world with the entire area, by moving the base position (if needed).
--!param xpos (int) Horizontal base position.
--!param ypos (int) Vertical base position.
--!param xsize (int) Horizontal size.
--!param ysize (int) Vertical size.
--!return (int, int) Allowed base position
function UIMapEditor:areaOnWorld(xpos, ypos, xsize, ysize)
  local map = self.ui.app.map

  xpos = math.min(math.max(xpos, 1), map.width - xsize + 1)
  ypos = math.min(math.max(ypos, 1), map.height - ysize + 1)
  return xpos, ypos
end
-- }}}

--! Retrieve what drag capabilities are allowed by the currently selected world cursor sprite.
--!return (string) "none"=not draggable, "east-west"=dragging only in east-west direction,
--  "north-south"=dragging only in north-south direction, "area"=dragging in both directions.
function UIMapEditor:getCursorDragCapabilities()
  -- Parcel and delete modes have unrestricted movement.
  if self.cursor.state == "delete" or self.cursor.state == "delete-left" or
      self.cursor.state == "parcel" or self.cursor.state == "parcel-left" or
      self.cursor.state == "paste" or self.cursor.state == "paste-left" or
      self.cursor.state == "right" then
    return "area"
  end

  -- No sprite, or not a 1x1 size -> not draggable.
  if not self.cursor.sprite then return "none" end
  if self.cursor.sprite.xsize ~= 1 or self.cursor.sprite.ysize ~= 1 then
    return "none"
  end

  if isFloorSpriteType(self.cursor.sprite.type) then return "area" end
  if self.cursor.sprite.type == "north" then return "east-west" end
  if self.cursor.sprite.type == "west" then return "north-south" end
  assert(false) -- Should never get here
end

--! The user moved the mouse!
--!param x (int) New horizontal position of the mouse at the screen.
--!param y (int) New vertical   position of the mouse at the screen.
--!param dx (int) Horizontal shift in position of the mouse at the screen.
--!param dy (int) Vertical   shift in position of the mouse at the screen.
function UIMapEditor:onMouseMove(x, y, dx, dy)
  local repaint = UIResizable.onMouseMove(self, x, y, dx, dy)

  -- Update the stored state of cursor position, and trigger a repaint as the
  -- cell outline sprite should track the cursor position.
  local wx, wy = self:mouseToWorld(x, y)
  if wx ~= self.cursor.xpos or wy ~= self.cursor.ypos then

    if self.cursor.state == "disabled" then
      self.cursor.xpos = wx -- Nothing is displayed, just keep track of the position.
      self.cursor.ypos = wy
      return repaint

    elseif self.cursor.state == "grid" or self.cursor.state == "delete" or
        self.cursor.state == "parcel" or self.cursor.state == "paste" or
        self.cursor.state == "heliport" or self.cursor.state == "camera" or
        self.cursor.state == "right" then
      self.cursor.xpos = wx -- Allow arbitrary movement.
      self.cursor.ypos = wy
      return true

    else -- Dragging in some mode.
        self.cursor.is_drag = true -- Crossing a tile boundary implies 'real' dragging.

        -- Update wx and wy according to drag capabilities.
        local cap = self:getCursorDragCapabilities()
        if cap == "north-south" then wx = self.cursor.leftx
        elseif cap == "east-west" then wy = self.cursor.lefty
        elseif cap == "none" then wx, wy = self.cursor.leftx, self.cursor.lefty -- Block all movement.
        end

        repaint = repaint or self.cursor.xpos ~= wx or self.cursor.ypos ~= wy
        self.cursor.xpos = wx
        self.cursor.ypos = wy
        return repaint
    end
  end
end

--! Mouse button got pressed.
--!param button (string) Mouse button being pressed.
--!param xpos (int) Horizontal position of the mouse at the time of the mouse button press.
--!param ypos (int) Vertical   position of the mouse at the time of the mouse button press.
--!return (bool) Whether to repaint the display.
function UIMapEditor:onMouseDown(button, xpos, ypos)
  if UIResizable.onMouseDown(self, button, xpos, ypos) then -- Button in this window.
    return true
  end

  if self:hitTest(xpos, ypos) then -- Clicked elsewhere in the window.
    return true
  end

  local repaint = false
  if self.cursor.state == "disabled" then
    if button == "right" then
      self.cursor.state = "right"
      self.cursor.rightx = self.cursor.xpos
      self.cursor.righty = self.cursor.ypos
    end

  elseif self.cursor.state == "grid" then
    -- LMB down switches to 'left'
    if button == "left" then
      self.cursor.state = "left"
      self.cursor.leftx = self.cursor.xpos
      self.cursor.lefty = self.cursor.ypos
    -- RMB down switches to 'right'
    elseif button == "right" then
      self.cursor.state = "right"
      self.cursor.rightx = self.cursor.xpos
      self.cursor.righty = self.cursor.ypos
    end
    -- Since 'grid' already shows the red rectangles, nothing changes visually.

  elseif self.cursor.state == "delete" then
    if button == "left" then
      self.cursor.state = "delete-left"
      self.cursor.leftx = self.cursor.xpos
      self.cursor.lefty = self.cursor.ypos
    elseif button == "right" then
      self.cursor.state = "right"
      self.cursor.rightx = self.cursor.xpos
      self.cursor.righty = self.cursor.ypos
    end

  elseif self.cursor.state == "parcel" then
    if button == "left" then
      self.cursor.state = "parcel-left"
      self.cursor.leftx = self.cursor.xpos
      self.cursor.lefty = self.cursor.ypos
    elseif button == "right" then
      self.cursor.state = "right"
      self.cursor.rightx = self.cursor.xpos
      self.cursor.righty = self.cursor.ypos
    end

  elseif self.cursor.state == "left" then
    -- If RMB is down, switch to 'both'.
    if button == "right" then
      self.cursor.state = "both"
      self.cursor.rightx = self.cursor.xpos
      self.cursor.righty = self.cursor.ypos
      repaint = true
    end

  elseif self.cursor.state == "right" then
    -- Ignore all down buttons, until RMB is released.

  elseif self.cursor.state == "paste" then
    if button == "left" then
      self.cursor.state = "paste-left"
      self.cursor.leftx = self.cursor.xpos
      self.cursor.lefty = self.cursor.ypos
    elseif button == "right" then
      self.cursor.state = "right"
      self.cursor.rightx = self.cursor.xpos
      self.cursor.righty = self.cursor.ypos
    end

  -- "both", "delete-left", "parcel-left", "paste-left" do not handle buttons.

  end

  return repaint
end

--! Add an object to the map. Currently, only "entrance_door" is supported.
--!param obj_type (str) Type of object ("entrance_door")
--!param xpos (int) Desired x position of the new object.
--!param ypos (int) Desired y position of the new object.
--!param direction (str) Direction of the new object ("north" or "west").
function UIMapEditor:drawObject(obj_type, xpos, ypos, direction)
  local world = self.ui.app.world

  -- TheApp.objects[name].thob
  -- name = world.object_id_by_thob[thob]
  -- generic object = world.object_types[object_id]
  -- instance: world:getObject(x, y, name)
  if obj_type == "entrance_door" then
    world:newObject("entrance_right_door", xpos, ypos, direction)
    if direction == "north" then
      world:newObject("entrance_left_door", xpos - 1, ypos, direction)
    else
      world:newObject("entrance_left_door", xpos, ypos - 1, direction)
    end
  end
end

--! Remove an entrance door from the world.
--!param door Entrance door to remove.
function UIMapEditor:removeDoor(door)
  local world = self.ui.app.world

  world:destroyEntity(door)
  if door.slave then
    world:destroyEntity(door.slave)
  end
end

--! Collect other objects that use the space needed for the specified new object.
--  If they exist, return them or delete them.
--!param obj_type (str) Type of object ("entrance_door")
--!param xpos (int) Desired x position of the new object.
--!param ypos (int) Desired y position of the new object.
--!param direction (str) Direction of the new object ("north" or "west").
--!param remove (bool) If set, remove the found objects.
--!return (list) The objects that use the space, if they are not removed.
function UIMapEditor:checkObjectSpace(obj_type, xpos, ypos, direction, remove)
  local world = self.ui.app.world
  local right_door = world.object_types["entrance_right_door"]
  local left_door  = world.object_types["entrance_left_door"]
  local th = self.ui.app.map.th

  --! Check single tile for conflicts with other doors.
  --!param x X position of the tile to check.
  --!param y Y position of the tile to check.
  --!return (int, int) position of the conflicting door, or (nil, nil) if no conflict.
  local function checkTile(x, y)
    local all_flags = th:getCellFlags(x, y)
    if not all_flags.thob then
      return nil, nil
    elseif all_flags.thob == right_door.thob then
      return x, y
    elseif all_flags.thob == left_door.thob then
      if all_flags.tallWest then
        return x, y + 1
      else
        return x + 1, y
      end
    end
    return nil, nil
  end

  -- While the general intention is 'objects', the only object that can exist
  -- and is handled here is the entrance door.
  assert(obj_type == "entrance_door")
  local doors = {}

  local x, y = checkTile(xpos, ypos)
  if x then
    doors[#doors + 1] = world:getObject(x, y, "entrance_right_door")
  end

  local x2, y2
  if direction == "north" then
    x2, y2 = checkTile(xpos - 1, ypos)
  else
    x2, y2 = checkTile(xpos, ypos - 1)
  end

  if x2 and (x2 ~= x or y2 ~= y) then
    doors[#doors + 1] = world:getObject(x2, y2, "entrance_right_door")
  end

  if remove then
    for _, door in ipairs(doors) do self:removeDoor(door) end
    return
  end
  return doors
end

--! Recognize objects in the collection of thob+tallWest entries
--!param minx (int) Base horizontal position (objects should be put relative to it).
--!param miny (int) Base vertical position (objects should be put relative to it).
--!param thobdir_positions (table xy to {thob, tallWest}) Found thobs.
--!return (array of {type, xpos, ypos, direction}) Found objects.
function UIMapEditor:findObjects(minx, miny, thobdir_positions)
  local world = self.ui.app.world
  local right_door = world.object_types["entrance_right_door"]
  local left_door  = world.object_types["entrance_left_door"]

  local objects = {} -- Found objects ordered by position.

  -- Look for right entrance door.
  for xy_right, thobdir_right in pairs(thobdir_positions) do
    if right_door.thob == thobdir_right.thob then
      -- Found right door, is there a matching left door?
      local xy_left = thobdir_right.tallWest and xy_right - 256 or xy_right - 1
      local thobdir_left = thobdir_positions[xy_left]
      if thobdir_left and thobdir_left.thob == left_door.thob and
          thobdir_left.tallWest == thobdir_right.tallWest then
        local obj = {type="entrance_door",
                     xpos = xy_right % 256 - minx + 1,
                     ypos = math.floor(xy_right / 256) - miny + 1,
                     direction=thobdir_right.tallWest and "west" or "north"}
        objects[#objects + 1] = obj
      end
    end
  end

  return objects
end

--! Draw the selected sprite at the given coordinates.
--!param coords (array or {xpos, ypos} tables) Coordinates to draw the selected sprite.
function UIMapEditor:drawCursorSpriteAtArea(coords)
  local th = self.ui.app.map.th

  if self.cursor.sprite then
    for _, coord in ipairs(coords) do
      local xbase, ybase = coord.xpos, coord.ypos

      -- Draw the selected sprite.
      xbase, ybase = self:areaOnWorld(xbase, ybase, self.cursor.sprite.xsize, self.cursor.sprite.ysize)
      for _, spr in ipairs(self.cursor.sprite.sprites) do
        local tx, ty = xbase + spr.xpos - 1, ybase + spr.ypos - 1
        local f, nw, ww = th:getCell(tx, ty) -- floor, north-wall, west-wall (, ui)
        if isFloorSpriteType(spr.type) then
          f = spr.sprite
          -- Floor sprite gets changed, also modify the cell flags.
          th:setCellFlags(tx, ty, makeCellFlags(spr.type))

        elseif spr.type == "north" then
          nw = spr.sprite

        elseif spr.type == "west" then
          ww = spr.sprite
        end

        th:setCell(tx, ty, f, nw, ww, 0)
      end

      -- Draw the objects
      if self.cursor.sprite.objects then
        for _, obj in ipairs(self.cursor.sprite.objects) do
          local tx, ty = xbase + obj.xpos - 1, ybase + obj.ypos - 1
          self:drawObject(obj.type, tx, ty, obj.direction)
        end
      end
    end
  end
end

--! Copy area from the game.
--!return (bool) Whether copying succeeded.
function UIMapEditor:copyArea()
  local th = self.ui.app.map.th

  local minx, miny, maxx, maxy = getCoveredArea(self.cursor.rightx, self.cursor.righty,
                                                self.cursor.xpos, self.cursor.ypos)
  if minx == maxx and miny == maxy and self.is_drag then
    return false -- Canceled drag
  end

  local thobdir_positions = {}

  -- Copy data.
  self.cursor.copy_data = {}
  self.cursor.copy_xsize = maxx - minx + 1
  self.cursor.copy_ysize = maxy - miny + 1

  local tx, ty
  tx = minx
  while tx <= maxx do
    ty = miny
    while ty <= maxy do
      local f, nw, ww = th:getCell(tx, ty)
      local all_flags = th:getCellFlags(tx, ty)
      self.cursor.copy_data[#self.cursor.copy_data + 1] = {
          xpos = tx - minx,
          ypos = ty - miny,
          floor = f,
          north_wall = nw,
          west_wall = ww,
          flags  = {buildable = all_flags.buildable,
                    passable  = all_flags.passable,
                    hospital  = all_flags.hospital},
      }
      if all_flags.thob and all_flags.thob ~= 0 then
        thobdir_positions[tx + 256 * ty] = {thob = all_flags.thob,
                                            tallWest = all_flags.tallWest}
      end

      ty = ty + 1
    end
    tx = tx + 1
  end
  self.cursor.copy_objects = self:findObjects(minx, miny, thobdir_positions)

  return true
end

--! Paste copied area into the destination area (one or more times).
function UIMapEditor:pasteArea()
  local th = self.ui.app.map.th

  local minx, miny, maxx, maxy
  -- Fill 'minx', 'miny' with the non-cursor corner.
  if self.cursor.leftx == self.cursor.xpos and self.cursor.lefty == self.cursor.ypos then
    if self.is_drag then
      return -- Canceled paste area.
    end

    minx = self.cursor.xpos + self.cursor.copy_xsize - 1
    miny = self.cursor.ypos + self.cursor.copy_ysize - 1
    minx, miny = self:areaOnWorld(minx, miny, 1, 1)
  else
    minx = self.cursor.leftx
    miny = self.cursor.lefty
  end

  minx, miny, maxx, maxy = getCoveredArea(minx, miny, self.cursor.xpos, self.cursor.ypos)
  -- Copy area in 'sub-areas' of (self.cursor.copy_xsize, self.cursor.copy_ysize).
  local tx, ty
  tx = minx
  while tx <= maxx do
    ty = miny
    while ty <= maxy do
      -- Copy floor and wall sprites, and set the passable/buildable/hospital flag.
      for _, elm in ipairs(self.cursor.copy_data) do
        local x, y = tx + elm.xpos, ty + elm.ypos
        if x <= maxx and y <= maxy then
          th:setCell(x, y, elm.floor, elm.north_wall, elm.west_wall, 0)
          th:setCellFlags(x, y, elm.flags)
        end
      end
      -- Make room for the new objects.
      for _, obj in ipairs(self.cursor.copy_objects) do
        local x, y = tx + obj.xpos - 1, ty + obj.ypos - 1
        if x <= maxx and y <= maxy then
          self:checkObjectSpace(obj.type, x, y, obj.direction, true)
        end
      end
      -- Paste the objects of the copied area.
      for _, obj in ipairs(self.cursor.copy_objects) do
        local x, y = tx + obj.xpos - 1, ty + obj.ypos - 1
        if x <= maxx and y <= maxy then
          self:drawObject(obj.type, x, y, obj.direction)
        end
      end

      ty = ty + self.cursor.copy_ysize
    end
    tx = tx + self.cursor.copy_xsize
  end
end

--! Delete the walls at the given coordinates.
--!param coords (array or {xpos, ypos} tables) Coordinates to remove the walls.
function UIMapEditor:deleteWallsAtArea(coords)
  local th = self.ui.app.map.th

  local thobdir_positions = {} -- Storage for found objects.

  for _, coord in ipairs(coords) do
    local tx, ty = coord.xpos, coord.ypos
    -- Remove west and north wall.
    local f = th:getCell(tx, ty) -- floor (, north-wall, west-wall , ui)
    th:setCell(tx, ty, f, 0, 0, 0)
    -- No need for map:setCellFlags, as 'passable', 'buildable', and 'hospital' are floor properties.

    -- Collect thobs, to remove next.
    local all_flags = th:getCellFlags(tx, ty)
    if all_flags.thob ~= 0 then
      thobdir_positions[tx + ty * 256] = {thob=all_flags.thob,
                                          tallWest=all_flags.tallWest}
    end
  end

  -- Remove objects from the area.
  local objects = self:findObjects(1, 1, thobdir_positions) -- Uses absolute position for the objects
  for _, obj in ipairs(objects) do
    self:checkObjectSpace(obj.type, obj.xpos, obj.ypos, obj.direction, true)
  end
end

--! Set parcel number at the given coordinates.
--!param coords (array or {xpos, ypos} tables) Coordinates to set parcel.
--!param parcel_num (int) Parcel number to set.
function UIMapEditor:setParcelAtArea(coords, parcel_num)
  local th = self.ui.app.map.th

  for _, coord in ipairs(coords) do
    local tx, ty = coord.xpos, coord.ypos
    th:setCellFlags(tx, ty, {parcelId = parcel_num})
  end
end

--! Mouse button was released.
--!param button (string) Mouse button being released.
--!param x (int) Horizontal position of the mouse at the time of the mouse button release.
--!param y (int) Vertical   position of the mouse at the time of the mouse button release.
--!return (bool) Whether to repaint the display.
function UIMapEditor:onMouseUp(button, x, y)
  local map = self.ui.app.map

  if UIResizable.onMouseUp(self, button, x, y) then
    return true
  end

  if self:hitTest(x, y) then
    return true
  end

  --! Get the cursor mode to jump to after ending the drag mode.
  --!return (string) New cursor mode.
  local function newState()
    if self.cursor.sprite then
      return "grid"
    else
      return "disabled"
    end
  end


  local repaint = false
  if self.cursor.state == "disabled" then
    -- Don't care about buttons.

  elseif self.cursor.state == "left" then
    if button == "left" then
      -- Simple drag (left button only).
      self:drawCursorSpriteAtArea(self:getDrawPoints())

      self.cursor.state = newState()
      self.cursor.is_drag = false
      repaint = true
    end

  elseif self.cursor.state == "delete-left" then
    if button == "left" then
      self:deleteWallsAtArea(self:getDrawPoints())

      self.cursor.state = "delete"
      self.cursor.is_drag = false
      repaint = true
    end

  elseif self.cursor.state == "parcel-left" then
    if button == "left" then
      self:setParcelAtArea(self:getDrawPoints(), self.cursor.parcel)
      map:updateDebugOverlay()

      self.cursor.state = "parcel"
      self.cursor.is_drag = false
      repaint = true
    end

  elseif self.cursor.state == "camera" then
    if button == "left" then
      local dp = self:getDrawPoints()
      map:setCameraTile(dp[1].xpos, dp[1].ypos, self.cursor.camera)
      map:updateDebugOverlay()
      repaint = true
    end

  elseif self.cursor.state == "heliport" then
    if button == "left" then
      local dp = self:getDrawPoints()
      map:setHeliportTile(dp[1].xpos, dp[1].ypos, self.cursor.heliport)
      map:updateDebugOverlay()
      repaint = true
    end

  elseif self.cursor.state == "right" then
    if button == "right" then
      if self:copyArea() then
        self.cursor.state = "paste"
        self:pageClicked("paste")
        self.cursor.is_drag = false
        repaint = true
      else
        self.cursor.state = "disabled" -- Copy area was canceled.
        self.cursor.is_drag = false
        repaint = true
      end
    end

  elseif self.cursor.state == "paste-left" then
    if button == "left" then
      self.cursor.state = "paste"
      self.cursor.is_drag = false
      repaint = true
      self:pasteArea()
    end

  elseif self.cursor.state == "both" then
    if button == "left" then -- Only care about left button.
      -- left+right drag ends.
      self:drawCursorSpriteAtArea(self:getDrawPoints())

      self.cursor.state = newState()
      self.cursor.is_drag = false
      repaint = true
    end
    -- "grid", "delete", "parcel", and "paste" already assumed no buttons pushed,
    -- ignore event.

  end

  return repaint
end

