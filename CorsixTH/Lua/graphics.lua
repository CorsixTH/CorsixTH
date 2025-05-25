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

local TH = require("TH")

local pathsep = package.config:sub(1, 1)

--! Layer for loading (and subsequently caching) graphical resources.
--! The Graphics class handles loading and caching of graphics resources.
-- It can adapt as the API to C changes, and hide these changes from most of
-- the other Lua code.
class "Graphics"

---@type Graphics
local Graphics = _G["Graphics"]

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
  queue_drag = 20,
  bank = 36,
  banksummary = 44,
}
local cursors_palette = {
  [36] = "Bank01V.pal",
  [44] = "Stat01V.pal",
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
    language_fonts = {},
    cursors = setmetatable({}, {__mode = "k"}),
  }

  self.custom_graphics = {}
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
  -- Cursors and fonts need to be reloaded after sprite sheets, as they are
  -- created from sprite sheets.
  self.reload_functions_last = setmetatable({}, {__mode = "k"})

  self:loadFontFile()

  local graphics_folder = nil
  if self.app.config.use_new_graphics then
    -- Check if the config specifies a place to look for graphics in.
    -- Otherwise check in the default "Graphics" folder.
    graphics_folder = self.app.config.new_graphics_folder or self.app:getFullPath("Graphics", true)
    if graphics_folder:sub(-1) ~= pathsep then
      graphics_folder = graphics_folder .. pathsep
    end

    local graphics_config_file = graphics_folder .. "file_mapping.txt"
    local result, err = loadfile_envcall(graphics_config_file)

    if not result then
      print("Warning: Failed to read custom graphics configuration:\n" .. err)
    else
      result(self.custom_graphics)
      if not self.custom_graphics.file_mapping then
        print("Error: An invalid custom graphics mapping file was found")
      end
    end
  end
  self.custom_graphics_folder = graphics_folder
end

--! Tries to load the font file given in the config file as unicode_font.
--! If it is not found it tries to use the font file from the compile setting WITH_FONT,
--!  or look for one in the CorsixTH folder, the grandparent of this file.
function Graphics:loadFontFile()
  local lfs = require("lfs")
  local function check(path) return lfs.attributes(path, "mode") == "file" end
  local config_path, compile_path = self.app.config.unicode_font, TH.GetCompileOptions().font

  local function getFontPath()
    local config_err, compile_err = "", ""
    if config_path then
      if check(config_path) then return config_path
      else config_err = "Configured font set but not found. Check path " .. config_path
      end
    end
    if compile_path then
      if check(compile_path) then return compile_path
      else compile_err = " Compiled font path set but not found. Check path " .. compile_path
      end
    end
    local path = self.app:getFullPath({})
    for file in lfs.dir(path) do
      for _, ext in pairs({"%.ttc$", "%.ttf$", "%.otc$", "%.otf$"}) do
        if file:match(ext) then
          return path .. file
        end
      end
    end
    return nil, config_err .. compile_err
  end
  local font_file, err = getFontPath()
  if not font_file then
    print("Unicode font not found, no fallback available.", err)
    return
  end

  local font = io.open(font_file, "rb")
  if font then
    self.ttf_font_data = font:read("*a")
    font:close()
    if self.ttf_font_data and config_path ~= font_file then
      self.app.config.unicode_font = font_file
      self.app:saveConfig()
      print("Configured unicode font not found, using " .. font_file .. " instead.")
      print("This will be written to the config file.")
    end
  end
end

function Graphics:loadMainCursor(id)
  if type(id) ~= "number" then
    id = cursors_name[id]
  end
  if id > 20 then -- SPointer cursors
    local cursor_palette = self:loadPalette("QData", cursors_palette[id], true)
    return self:loadCursor(self:loadSpriteTable("QData", "SPointer", false, cursor_palette), id - 20)
  else
    return self:loadCursor(self:loadSpriteTable("Data", "MPointer"), id)
  end
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
      local function cursor_reloader(res)
        assert(res:load(sheet, index, hot_x, hot_y))
      end
      self.reload_functions_last[cursor] = cursor_reloader
    end
    sheet_cache[index] = cursor
    self.load_info[cursor] = {self.loadCursor, self, sheet, index, hot_x, hot_y}
  end
  return cursor
end

local function makeGreyscaleGhost(pal)
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
    local grey = entry[1] * 0.299 + entry[2] * 0.587 + entry[3] * 0.114
    local grey_index = 0
    local grey_diff = 100000 -- greater than 3*63^2 (TH uses 6 bit colour channels)
    for j = 0, #entries do
      local replace_entry = entries[j]
      local diff_r = replace_entry[1] - grey
      local diff_g = replace_entry[2] - grey
      local diff_b = replace_entry[3] - grey
      local diff = diff_r * diff_r + diff_g * diff_g + diff_b * diff_b
      if diff < grey_diff then
        grey_diff = diff
        grey_index = j
      end
    end
    remap[i] = string.char(grey_index)
  end
  -- Convert remap from an array to a string
  return table.concat(remap, "", 0, 255)
end

--! Load a palette file
--!param dir (string) The directory of the palette relative to the HOSPITAL directory
--!param name (string) The name of the palette file
--!param transparent_255 (boolean) Whether the 255th entry in the palette should be transparent
--!return (palette, string) The palette and a string representing the palette converted to greyscale
function Graphics:loadPalette(dir, name, transparent_255)
  name = name or "MPalette.dat"

  if self.cache.palette[name] then
    local li = self.load_info[self.cache.palette[name]]
    if li and li[5] ~= transparent_255 then
      print("Warning: palette " .. name .. " requested with different flags than stored")
    end

    return self.cache.palette[name],
      self.cache.palette_greyscale_ghost[name]
  end

  local data = self.app:readDataFile(dir or "Data", name)
  local palette = TH.palette()
  palette:load(data)
  if transparent_255 then
    palette:setEntry(255, 0xFF, 0x00, 0xFF)
  end
  self.cache.palette_greyscale_ghost[name] = makeGreyscaleGhost(data)
  self.cache.palette[name] = palette
  self.load_info[palette] = {self.loadPalette, self, dir, name, transparent_255}
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

--! Load a bitmap from a dat file and palette
--!
--!param name (string) The file name of the bitmap without the .dat extension
--!param width (int) The width of the bitmap. Defaults to 640
--!param height (int) The height of the bitmap. Defaults to 480
--!param dir (string) The directory of the bitmap. Defaults to QData
--!param paldir (string) The directory of the palette.
--!param pal (string) The name of the palette
--!param transparent_255 (boolean) Whether the 255th entry of the palette should be transparent
function Graphics:loadRaw(name, width, height, dir, paldir, pal, transparent_255)
  if self.cache.raw[name] then
    return self.cache.raw[name]
  end

  width = width or 640
  height = height or 480
  dir = dir or "QData"
  paldir = paldir or dir
  pal = pal or (name .. ".pal")
  local data = self.app:readDataFile(dir, name .. ".dat")
  data = data:sub(1, width * height)

  local bitmap = TH.bitmap()
  local palette = self:loadPalette(paldir, pal, transparent_255)
  bitmap:setPalette(palette)
  assert(bitmap:load(data, width, self.target))

  local function bitmap_reloader(bm)
    bm:setPalette(palette)
    local bitmap_data = self.app:readDataFile(dir, name .. ".dat")
    bitmap_data = bitmap_data:sub(1, width * height)
    assert(bm:load(bitmap_data, width, self.target))
  end
  self.reload_functions[bitmap] = bitmap_reloader

  self.cache.raw[name] = bitmap
  self.load_info[bitmap] = {self.loadRaw, self, name, width, height, dir, paldir, pal, transparent_255}
  return bitmap
end

function Graphics:loadBuiltinFont()
  local font = self.builtin_font
  if not font then
    local dat, tab, pal = TH.GetBuiltinFont()
    local function dernc(x)
      if x:sub(1, 3) == "RNC" then
        return rnc.decompress(x)
      else
        return x
      end
    end
    local palette = TH.palette()
    palette:load(dernc(pal))
    local sheet = TH.sheet()
    sheet:setPalette(palette)
    sheet:load(dernc(tab), dernc(dat), true, self.target)
    font = TH.bitmap_font()
    font:setSheet(sheet)
    font:setSeparation(1, 0)
    self.load_info[font] = {self.loadBuiltinFont, self}
    self.builtin_font = font
  end
  return font
end

function Graphics:hasLanguageFont(font)
  if font == nil then
    -- Original game fonts are always present.
    return true
  else
    if not TH.freetype_font then
      -- CorsixTH compiled without FreeType2 support, so even if suitable font
      -- file exists, it cannot be loaded or drawn.
      return false
    end

    -- TODO: Handle more than one font

    return not not self.ttf_font_data
  end
end

--! Font proxy meta table wrapping the C++ class.
local font_proxy_mt = {
  __index = {
    sizeOf = function(self, ...)
      return self._proxy:sizeOf(...)
    end,
    draw = function(self, ...)
      return self._proxy:draw(...)
    end,
    drawWrapped = function(self, ...)
      return self._proxy:drawWrapped(...)
    end,
    drawTooltip = function(self, ...)
      return self._proxy:drawTooltip(...)
    end,
  }
}

function Graphics:onChangeLanguage()
  -- Some fonts might need changing between bitmap and freetype
  local load_info = self.load_info
  self.load_info = {} -- Any newly made objects are temporary, and shouldn't
                      -- remember reload information (also avoids insertions
                      -- into a table being iterated over).
  for object, info in pairs(load_info) do
    if object._proxy then
      local fn = info[1]
      local new_object = fn(unpack(info, 2))
      object._proxy = new_object._proxy
    end
  end
  self.load_info = load_info
end

--! Font reload function.
--!param font The font to (force) reloading.
local function font_reloader(font)
  font:clearCache()
end

--! Utility function to return preferred font for main menu ui
function Graphics:loadMenuFont()
  local font
  if self.language_font then
    font = self:loadFontAndSpriteSheet("QData", "Font01V")
  else
    font = self:loadBuiltinFont()
  end
  return font
end

local ttf_col_to_cache_key = function(ttf_col)
  if ttf_col then
    return string.format("r%d,g%d,b%d", ttf_col.red, ttf_col.green, ttf_col.blue)
  else
    return "nil"
  end
end

local language_font_cache_key = function(name, x_sep, y_sep, ttf_col, force_bitmap)
  return string.format("%s,%d,%d,%s,%s", name or "nil", x_sep or 0, y_sep or 0,
    ttf_col_to_cache_key(ttf_col), force_bitmap and "T" or "F")
end

--! Load a true type font
--!
--!param name (string) The name of the font from the language file. Always 'unicode'.
--!param sprite_table (userdata) The sprite table of the font this font is replacing. Used for default colour and metrics.
--!param x_sep (int) Unused on ttf for now, controls the horizontal separation of the font for bitmap fonts.
--!param y_sep (int) Unused on ttf for now, controls the vertical separation of the font for bitmap fonts.
--!param ttf_col (colour in form .red, .green and .blue) The colour of the font.
--  If nil, the colour will be detected from the sprite table.
--!param force_bitmap (boolean) Whether to force the font to be a bitmap font.
function Graphics:loadLanguageFont(name, sprite_table, x_sep, y_sep, ttf_col, force_bitmap)
  local font
  if name == nil then
    font = self:loadFont(sprite_table, x_sep, y_sep, ttf_col, force_bitmap)
  else
    local cache = self.cache.language_fonts[language_font_cache_key(name, x_sep, y_sep, ttf_col, force_bitmap)]
    font = cache and cache[sprite_table]
    if not font then
      font = TH.freetype_font()
      -- TODO: Choose face based on "name" rather than always using same face.
      font:setFace(self.ttf_font_data)
      if ttf_col then
        font:setSheet(sprite_table, ttf_col.red, ttf_col.green, ttf_col.blue)
      else
        font:setSheet(sprite_table)
      end
      self.reload_functions_last[font] = font_reloader

      if not cache then
        cache = {}
        self.cache.language_fonts[name] = cache
      end
      cache[sprite_table] = font
    end
  end
  self.load_info[font] = {self.loadLanguageFont, self, name, sprite_table, x_sep, y_sep, ttf_col, force_bitmap}
  return font
end

--! Load a font and the corresponding sprite sheet in one operation.
--! 
--! This is the same as calling loadFont(Graphics:loadSpriteTable(dir, name, complex, palette), x_sep, y_sep, ttf_col)
--! except that force_bitmap is set to true automatically for some sprite tables.
--!
--!param dir (string) The directory of the sprite table relative to the HOSPITAL directory.
--!param name (string) The name of the sprite table file without the .dat extension.
--!param complex (boolean) Whether the sprite table is complex or not.
--!param palette (string) The name of the palette file. If nil, the default palette will be used.
--!param x_sep (integer) Controls the horizontal separation of the font for bitmap fonts.
--!param y_sep (integer) Controls the vertical separation of the font for bitmap fonts.
--!param ttf_col (colour in form .red, .green and .blue) The colour of the font if a true type font is loaded.
--  If nil, the colour will be detected from the sprite table.
function Graphics:loadFontAndSpriteTable(dir, name, complex, palette, x_sep, y_sep, ttf_col)
  local sprite_table = self:loadSpriteTable(dir, name, complex, palette)
  local force_bitmap = (name == "Font05V" and self:arabicNumerals())

  return self:loadFont(sprite_table, x_sep, y_sep, ttf_col, force_bitmap)
end

--! Load a font for the given sprite table.
--!
--!param sprite_table (userdata) The sprite table of the font this font is replacing. Used for default colour and metrics.
--!param x_sep (integer) Controls the horizontal separation of the font for bitmap fonts.
--!param y_sep (integer) Controls the vertical separation of the font for bitmap fonts.
--!param ttf_col (colour in form .red, .green and .blue) The colour of the font if a true type font is loaded.
--  If nil, the colour will be detected from the sprite table.
--!param force_bitmap (boolean) Whether to force the font to be a bitmap font.
function Graphics:loadFont(sprite_table, x_sep, y_sep, ttf_col, force_bitmap)

  -- afterLoad fix. Saves before 215 would double the y_sep argument, but did not have ttf_col
  if type(ttf_col) == "number" then
    ttf_col = nil
  end

  -- Use a bitmap font if forced, or the language uses bitmap, or the
  -- sprite_table has no M in it, indicating it's probably a symbol file.
  local use_bitmap_font = force_bitmap or not self.language_font or not sprite_table:isVisible(46)
  local font
  if use_bitmap_font then
    font = TH.bitmap_font()
    font:setSeparation(x_sep or 0, y_sep or 0)
    font:setSheet(sprite_table)
  else
    font = self:loadLanguageFont(self.language_font, sprite_table, x_sep, y_sep, ttf_col, force_bitmap)
  end
  -- A change of language might cause the font to change between bitmap and
  -- freetype, so wrap it in a proxy object which allows the actual object to
  -- be changed easily.
  font = setmetatable({ _proxy = font }, font_proxy_mt)
  self.load_info[font] = { self.loadFont, self, sprite_table, x_sep, y_sep, ttf_col, force_bitmap }
  return font
end

function Graphics:arabicNumerals()
  local strings = self.app.strings
  local language = self.app.config.language
  local arabic_numerals = strings:isArabicNumerals(language)
  return arabic_numerals
end

function Graphics:drawNumbersFromUnicode()
  return self.language_font and not self:arabicNumerals()
end

function Graphics:loadAnimations(dir, prefix)
  if self.cache.anims[prefix] then
    return self.cache.anims[prefix]
  end

  --! Load a custom animation file (if it can be found)
  --!param path Path to the file.
  local function loadCustomAnims(path)
    local file, err = io.open(path, "rb")
    if not file then
      return nil, err
    end
    local data = file:read("*a")
    file:close()
    return data
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
    error("Cannot load original animations " .. prefix)
  end

  if self.custom_graphics_folder and self.custom_graphics.file_mapping then
    for _, fname in pairs(self.custom_graphics.file_mapping) do
      anims:setCanvas(self.target)
      local data, err = loadCustomAnims(self.custom_graphics_folder .. fname)
      if not data then
        print("Error when loading custom animations:\n" .. err)
      elseif not anims:loadCustom(data) then
        print("Warning: custom animations loading failed")
      end
    end
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

  local function sheet_reloader(sheet)
    sheet:setPalette(palette or self:loadPalette())
    local data_tab, data_dat
    data_tab = self.app:readDataFile(dir, name .. ".tab")
    data_dat = self.app:readDataFile(dir, name .. ".dat")
    if not sheet:load(data_tab, data_dat, complex, self.target) then
      error("Cannot load sprite sheet " .. dir .. ":" .. name)
    end
  end
  local sheet = TH.sheet()
  self.reload_functions[sheet] = sheet_reloader
  sheet_reloader(sheet)

  if name ~= "SPointer" then
    self.cache.tabled[name] = sheet
  end
  self.load_info[sheet] = {self.loadSpriteTable, self, dir, name, complex, palette}
  return sheet
end

function Graphics:updateTarget(target)
  self.target = target
  for _, res_set in ipairs({"reload_functions", "reload_functions_last"}) do
    for resource, reloader in pairs(self[res_set]) do
      reloader(resource)
    end
  end
end

--! Utility class for setting animation markers and querying animation length.
class "AnimationManager"

---@type AnimationManager
local AnimationManager = _G["AnimationManager"]

function AnimationManager:AnimationManager(anims)
  self.anim_length_cache = {}
  self.anims = anims
end

--! For overriding animations which have builtin repeats or excess frames
function AnimationManager:setAnimLength(anim, length)
  self.anim_length_cache[anim] = length
end

function AnimationManager:getAnimLength(anim)
  if not self.anim_length_cache[anim] then
    local length = 0
    local seen = {}
    local frame = self.anims:getFirstFrame(anim)
    while not seen[frame] do
      seen[frame] = true
      length = length + 1
      frame = self.anims:getNextFrame(frame)
    end
    self.anim_length_cache[anim] = length
  end
  return self.anim_length_cache[anim]
end

--[[ A marker position can be used to indicate the position of en entity in the
  frame of an animation relative to the position of drawing the animation.

  The marker position is used to display a humanoid in the circular area of its
  window. It is also used to position mood icons or smoke of a machine above
  the entity.

  There are two marker positions associated with each frame of an animation.
  The primary marker is reserved for patients and machines. The secondary
  marker is used for staff and other officials such as VIPs and inspectors.

  Markers are set as part of the animation definitions of entities with code like

  -- Sets the primary markers of all frames of an animation:
  local anim_mgr = TheApp.animation_manager
  anim_mgr:setPatientMarker(...)

  -- Sets the secondary markers of all frames of an animation:
  local anim_mgr = TheApp.animation_manager
  anim_mgr:setStaffMarker(...)

  Markers can be set using a variety of different arguments:
  * set{Patient/Staff}Marker(anim_number, position)
  * set{Patient/Staff}Marker(anim_number, {position1, position2, ..., positionN})
  * set{Patient/Staff}Marker(anim_number, start_position, end_position)
  * set{Patient/Staff}Marker(anim_number, keyframe_1, keyframe_1_position, keyframe_2, ...)

  The 'position' should be a table; An {x, y} pair for a tile position or
  {x, y, "px"} for a pixel position. In both cases the position should be the
  humanoid centre at floor level, with the centre of the (0, 0) tile being the
  origin in both cases.

  The first variant of set{Patient,Staff}Marker sets the same marker for each frame.
  The second variant of has a unique position for each frame. 'nil' can be used to
  repeat the previous position.
  The third variant does linear interpolation of the two positions between the first
  frame and the last frame.
  The fourth variant does linear interpolation between keyframes, and then the final
  position for frames after the last keyframe. The keyframe arguments should be
  0-based integers, as in the animation viewer.

  To set the markers for multiple animations at once, the anim_number argument
  can be a table, in which case the marker is set for all values in the table.
  Alternatively, the values function (defined in utility.lua) can be used in
  conjection with a for loop to set markers for multiple things.

  The AnimView program can be used to easily obtain position information in frames.
--]]

--! Define the centre of a patient at floor level in an animation.
function AnimationManager:setPatientMarker(anim, ...)
  self:_unfoldAnims(anim, "setFramePrimaryMarker", ...)
end

--! Define the centre of a staff member at floor level in an animation.
function AnimationManager:setStaffMarker(anim, ...)
  self:_unfoldAnims(anim, "setFrameSecondaryMarker", ...)
end

--! Convert a humanoid position to a pixel offset.
--!param pos (table) Humanoid center position to convert. Is either a tile
--  position of the form {x, y} with floating point numbers, or a pixel
--  position of the form {x, y, "px"} with integer numbers. In both cases,
--  the origin is at the center of tile (0, 0), at floor level.
--!return (int, int) The computed offset wrt to the origin in pixels.
local function positionToXy(pos)
  if pos[3] == "px" then
    return pos[1], pos[2]
  else
    local x, y = Map:WorldToScreen(pos[1] + 1, pos[2] + 1)
    return math.floor(x), math.floor(y)
  end
end

--! Unfold tables containing animation numbers.
function AnimationManager:_unfoldAnims(anim, fn, ...)
  if not anim then return end

  if type(anim) == "table" then
    for _, val in pairs(anim) do
      self:_unfoldAnims(val, fn, ...)
    end
  else
    self:setMarkerRaw(anim, fn, ...)
  end
end

function AnimationManager:setMarkerRaw(anim, fn, arg1, arg2, ...)
  local anim_length = self:getAnimLength(anim)
  local frame = self.anims:getFirstFrame(anim)

  --! Set marker position for frame
  --!param x1y1 (boolen) use values given by x1 and y1 only if true, otherwise use
  -- linear interpolation between x1/y1 and x2/y2
  --!param x1, y1, x2 (optional), y2 (optional) pixel positions
  --!param n fraction between start and end frame of linear interpolation
  local function setMarkerFramePosition(x1y1, x1, y1, x2, y2, n)
    assert(type(x1) == "number" and type(y1) == "number",
        "Anim " .. anim .. ", frame " .. frame .. " has missing marker position")
    local pos_x = x1y1 and x1 or math.floor((x2 - x1) * n + x1)
    local pos_y = x1y1 and y1 or math.floor((y2 - y1) * n + y1)
    self.anims[fn](self.anims, frame, pos_x, pos_y)
  end

  local tp_arg1 = type(arg1)
  if tp_arg1 == "table" then
    if arg2 then
      -- Linear-interpolation positions
      local x1, y1 = positionToXy(arg1)
      local x2, y2 = positionToXy(arg2)
      for i = 0, anim_length - 1 do
        local n = i / (anim_length - 1)
        setMarkerFramePosition(false, x1, y1, x2, y2, n)
        frame = self.anims:getNextFrame(frame)
      end
    elseif type(arg1[1]) == "table" then
      -- A position for each frame.
      local x, y
      for rel_frame = 1, anim_length do
        if arg1[rel_frame] then
          x, y = positionToXy(arg1[rel_frame])
        end
        setMarkerFramePosition(true, x, y)
        frame = self.anims:getNextFrame(frame)
      end
    else
      -- Static position
      local x, y = positionToXy(arg1)
      for _ = 1, anim_length do
        setMarkerFramePosition(true, x, y)
        frame = self.anims:getNextFrame(frame)
      end
    end
  elseif tp_arg1 == "number" then
    -- Keyframe positions, using liner-interpolation
    local f1, x1, y1 = 0, 0, 0
    local args
    if arg1 == 0 then
      x1, y1 = positionToXy(arg2)
      args = {...}
    else
      args = {arg1, arg2, ...}
    end
    local f2, x2, y2
    local args_i = 1
    for f = 0, anim_length - 1 do
      if f2 and f == f2 then
        f1, x1, y1 = f2, x2, y2
        f2, x2, y2 = nil, nil, nil
      end
      if not f2 then
        f2 = args[args_i]
        if f2 then
          x2, y2 = positionToXy(args[args_i + 1])
          args_i = args_i + 2
        end
      end
      if f2 then
        local n = (f - f1) / (f2 - f1)
        setMarkerFramePosition(false, x1, y1, x2, y2, n)
      else
        setMarkerFramePosition(true, x1, y1)
      end
      frame = self.anims:getNextFrame(frame)
    end
  else
    error("Invalid arguments to setMarker", 2)
  end
end
