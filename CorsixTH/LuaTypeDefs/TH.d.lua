--[[ Copyright (c) 2026 Stephen Baker

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
---@meta TH

---@class THFileBlob
local THFileBlob = {}

---@alias THFile THFileBlob | string

-- th_lua_gfx.cpp

---@class THPalette
---@overload fun(file: THFile, pal8: boolean): THPalette
local THPalette = {}

---@param index integer # the palette index to set (0-255)
---@param r integer # red component (0-255)
---@param g integer # green component (0-255)
---@param b integer # blue component (0-255)
---@return boolean # True if the palette entry was set successfully, false otherwise
function THPalette:setEntry(index, r, g, b) end

---@class THRawBitmap
---@overload fun(): THRawBitmap
local THRawBitmap = {}

---@param file THFile # bitmap data file
---@param width integer # width of the bitmap in pixels
---@param canvas THRenderTarget # the canvas to load the bitmap into
---@param options {flags: integer?}?
---@return THRawBitmap # self
function THRawBitmap:load(file, width, canvas, options) end

---@param palette THPalette
---@return THRawBitmap # self
function THRawBitmap:setPalette(palette) end

---@param canvas THRenderTarget
---@param x number?
---@param y number?
---@return THRawBitmap # self
function THRawBitmap:draw(canvas, x, y) end

---@param canvas THRenderTarget
---@param x number
---@param y number
---@param srcX integer
---@param srcY integer
---@param width integer
---@param height integer
---@return THRawBitmap # self
function THRawBitmap:draw(canvas, x, y, srcX, srcY, width, height) end

---@class THSpriteSheet
---@overload fun(): THSpriteSheet
---@operator len: integer
local THSpriteSheet = {}

---@param dataTable THFile
---@param dataChunk THFile
---@param complex boolean
---@param canvas THRenderTarget?
---@return boolean
function THSpriteSheet:load(dataTable, dataChunk, complex, canvas) end

---@param pal THPalette
---@return THSpriteSheet # self
function THSpriteSheet:setPalette(pal) end

---@param sprite integer
---@return integer width
---@return integer height
function THSpriteSheet:size(sprite) end

---@param canvas THRenderTarget
---@param sprite integer
---@param x number? default 0
---@param y number? default 0
---@param options {flags?:integer,scaleFactor?:integer}?
---@return THSpriteSheet # self
function THSpriteSheet:draw(canvas, sprite, x, y, options) end

--- Test if the given pixel of the given sprite is opaque
---@param sprite integer
---@param x number
---@param y number
---@param flags integer?
---@return boolean
function THSpriteSheet:hitTest(sprite, x, y, flags) end

--- Test if any pixel of the given sprite is visible
---@param sprite integer
---@return boolean
function THSpriteSheet:isVisible(sprite) end

---@alias THFontAlign "left"|"center"|"centre"|"middle"|"right"

---@class THRgba
---@field red integer
---@field blue integer
---@field green integer
---@field alpha integer
local THRgba = {}

---@class THFontOptions
---@field x_sep? integer The horizontal separation of the font. Defaults to 0.
---@field y_sep? integer The vertical separation of the font. Defaults to 0.
---@field ttf_color? THRgba The colour of the font. If nil, the colour will be detected from the sprite table.
---@field force_bitmap? boolean Whether to force the font to be a bitmap font. If nil, this will be set to true for Font05V if the language uses Arabic numerals.
---@field ttf_width? integer The nominal width of the font, in pixels. If nil, the width will be detected from the sprite table.
---@field ttf_height? integer The nominal height of the font, in pixels. If nil, the height will be detected from the sprite table.
---@field ttf_shadow? {offset_x?: integer, offset_y?: integer, color?: THRgba}|boolean If the ttf_shadow field is present, the font will be drawn with a shadow of the specified colour and offset. color is optional and defaults to opaque black. offset_x and offset_y are optional and default to 1. If the field is omitted entirely, no shadow is drawn. Alternately ttf_shadow can be set to true to draw a shadow with default parameters, or false to disable any shadow.
---@field apply_ui_scale? boolean Whether to apply the UI scale factor to the font size.
local THFontOptions = {}

---@class THFont
local THFont = {}

---@param str string A string to test the drawn size of
---@param maxWidth integer? Width to draw text before wrapping
---@return integer width
---@return integer height
---@return integer rowCount
function THFont:sizeOf(str, maxWidth) end

---@param canvas THRenderTarget? Target to draw to. If nil then only calculate draw area.
---@param str string The message to draw
---@param x number
---@param y number
---@param width integer?
---@param height integer?
---@param align THFontAlign?
---@return number endY bottom edge pixel
---@return number endX right edge pixel
function THFont:draw(canvas, str, x, y, width, height, align) end

---@param canvas THRenderTarget? Target to draw to. If nil then only calculate draw area.
---@param str string The message to draw
---@param x number
---@param y number
---@param width integer
---@param align THFontAlign?
---@param maxRows integer?
---@param skipRows integer?
---@return integer endY bottom edge pixel
---@return integer endX right edge pixel
---@return integer rowCount
function THFont:drawWrapped(canvas, str, x, y, width, align, maxRows, skipRows) end

---@param canvas THRenderTarget
---@param str string The message to draw
---@param x number
---@param y number
---@param width integer?
---@return integer endY bottom edge pixel
function THFont:drawTooltip(canvas, str, x, y, width) end

---@return boolean # true if instance of THBitmapFont
function THFont:isBitmap() end

---@class THBitmapFont: THFont
---@overload fun(): THBitmapFont
local THBitmapFont = {}

---@param sheet THSpriteSheet
---@param charset THFontCharset?
---@return THBitmapFont # self
function THBitmapFont:setSheet(sheet, charset) end

---@return THSpriteSheet
function THBitmapFont:getSheet() end

---@param charSep integer
---@param lineSep integer?
---@return THBitmapFont # self
function THBitmapFont:setSeparation(charSep, lineSep) end

---@param scale integer
---@return THBitmapFont # self
function THBitmapFont:setScaleFactor(scale) end

---@class THFreetypeFont: THFont
---@overload fun(): THFreetypeFont
local THFreetypeFont = {}

---@param sheet THSpriteSheet Used to find a default size and colour
---@param options THFontOptions
---@return THFreetypeFont # self
function THFreetypeFont:setFontOptions(sheet, options) end

---@param data THFile
---@return THFreetypeFont # self
function THFreetypeFont:setFace(data) end

---@return string
function THFreetypeFont.getCopyrightNotice() end

function THFreetypeFont:clearCache() end

---@class THLayers
---@overload fun(): THLayers
---@field [integer] integer
local THLayers = {}

---@class THCursor
---@overload fun(): THCursor
local THCursor = {}

---@param sheet THSpriteSheet
---@param hotspotX integer?
---@param hotspotY integer?
---@return THCursor|boolean # self if loaded, false otherwise
function THCursor:load(sheet, hotspotX, hotspotY) end

---@param canvas THRenderTarget
function THCursor:use(canvas) end

---@param canvas THRenderTarget
---@param x number
---@param y number
---@return boolean success
function THCursor.setPosition(canvas, x, y) end

---@class THRenderTargetCreationParams
---@field width? integer Window width (window pixels)
---@field height? integer Window height (window pixels)
---@field min_width? integer Minimum window width (window pixels)
---@field min_height? integer Minimum window height (window pixels)
---@field resolution_width? integer Render width (resolution pixels)
---@field resolution_height? integer Render height (resolution pixels)
---@field modes? {[string]: boolean} Display mode options
local THRenderTargetCreationParams = {}

---@class THRenderTarget
---@overload fun(parms: THRenderTargetCreationParams): THRenderTarget
local THRenderTarget = {}

---@param params THRenderTargetCreationParams
---@return string? error
function THRenderTarget:update(params) end

--- Fills the render target with black
---@return nil
---@return string? error
function THRenderTarget:fillBlack() end

--- Fills the render target with the specified colour
---@param colour THRgba
---@return nil
---@return string? error
function THRenderTarget:fillColour(colour) end

--- Call at the start of each render frame
---@return nil
---@return string? error
function THRenderTarget:startFrame() end

--- Call at the end of each render frame
---@return nil
---@return string? error
function THRenderTarget:endFrame() end

--- Meant to be called in pairs at the start and end of a non-overlapping
--- sequence of draw calls as an optimization hint.
---@param start boolean? if absent or true start the non-overlapping region, otherwise end
---@return THRenderTarget # self
function THRenderTarget:nonOverlapping(start) end

--- Convert rgb triplet to packed representation
---@param r integer Red component [0-255]
---@param g integer Green component [0-255]
---@param b integer Blue component [0-255]
---@return integer colour
function THRenderTarget:mapRGB(r, g, b) end

--- Activate or deactivate blue 'pause' filter
---@param activate boolean? default true
function THRenderTarget:setBlueFilterActive(activate) end

---@param colour integer Packed RGB
---@param x number
---@param y number
---@param width number
---@param height number
---@return THRenderTarget? # self on success
---@return string? error
function THRenderTarget:drawRect(colour, x, y, width, height) end

---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@return THRenderTarget # self
function THRenderTarget:pushClip(x, y, width, height) end

---@return THRenderTarget # self
function THRenderTarget:popClip() end

---@return integer width target width in render pixels
---@return integer height target height in render pixels
function THRenderTarget:getRenderSize() end

---@return integer width width of target in window pixels
---@return integer height height of target in window pixels
function THRenderTarget:getWindowSize() end

---@return integer width maximum window width in window pixels
---@return integer height maximum window height in window pixels
function THRenderTarget:getMaxWindowSize() end

---@return number scale the display scale reported by the window system
function THRenderTarget:getWindowDisplayScale() end

---@param filePath string Path to save the screenshot to
---@return THRenderTarget? # self on success
---@return string error
function THRenderTarget:takeScreenshot(filePath) end

---@param s number scale factor
---@param whatToScale "bitmap"?
---@return boolean success
function THRenderTarget:scale(s, whatToScale) end

---@param str string
---@return THRenderTarget # self
function THRenderTarget:setCaption(str) end

--- Get the name of the renderer
---@return string
function THRenderTarget:getRendererDetails() end

--- Whether to capture the mouse in the render target
---@param activate boolean? default true
function THRenderTarget:setCaptureMouse(activate) end

---@class THLineSequence
---@overload fun(): THLineSequence
local THLineSequence = {}

---@param x number? default 0
---@param y number? default 0
---@return THLineSequence # self
function THLineSequence:moveTo(x, y) end

---@param x number? default 0
---@param y number? default 0
---@return THLineSequence # self
function THLineSequence:lineTo(x, y) end

---@param w number? default 1
---@return THLineSequence # self
function THLineSequence:setWidth(w) end

---@param r integer? Red component. Default 0 [0-255]
---@param g integer? Green component. Default 0 [0-255]
---@param b integer? Blue component. Default 0 [0-255]
---@param a integer? Alpha component. Default 255 [0-255]
function THLineSequence:setColour(r, g, b, a) end

---@param canvas THRenderTarget
---@param x number?
---@param y number?
---@return THLineSequence # self
function THLineSequence:draw(canvas, x, y) end

-- th_lua_map.cpp

---@class THCellFlags
---@field passable? boolean
---@field hospital? boolean
---@field buildable? boolean
---@field room? boolean
---@field doorWest? boolean
---@field doorNorth? boolean
---@field tallWest? boolean
---@field tallNorth? boolean
---@field travelNorth? boolean
---@field travelEast? boolean
---@field travelSouth? boolean
---@field travelWest? boolean
---@field doNotIdle? boolean
---@field buildableNorth? boolean
---@field buildableEast? boolean
---@field buildableSouth? boolean
---@field buildableWest? boolean
---@field avoidTile? boolean
---@field roomId? integer
---@field parcelId? integer
---@field owner? integer
---@field thob? integer
local THCellFlags = {}

---@class THLevelMap
---@overload fun(): THLevelMap
local THLevelMap = {}

---@class THMapObject
---@field [1] integer x
---@field [2] integer y
---@field [3] integer thob
---@field [4] integer flags
local THMapObject = {}

--- Load a map from a file
---@param data THFile
---@return boolean success
---@return THMapObject[] mapObjects
function THLevelMap:load(data) end

--- Load an empty map
---@return boolean success
---@return THMapObject[] mapObjects
function THLevelMap:loadBlank() end

---@param filename string
function THLevelMap:save(filename) end

---@return integer width
---@return integer height
function THLevelMap:size() end

---@return integer playerCount
function THLevelMap:getPlayerCount() end

---@param cnt integer
function THLevelMap:setPlayerCount(cnt) end

--- Get the initial camera map tile location in lua coordinates
---@param player integer? player to check, 1 by default
---@return integer x
---@return integer y
function THLevelMap:getCameraTile(player) end

---@param x integer
---@param y integer
---@param player integer? default 1
function THLevelMap:setCameraTile(x, y, player) end

--- Get the heliport map tile location in lua coordinates
---@param player integer? player to check, 1 by default
---@return integer x
---@return integer y
function THLevelMap:getHeliportTile(player) end

---@param x integer
---@param y integer
---@param player integer? default 1
function THLevelMap:setHeliportTile(x, y, player) end

---@param x integer
---@param y integer
---@return integer ground
---@return integer north_wall
---@return integer west_wall
---@return integer ui
function THLevelMap:getCell(x, y) end

---@param x integer
---@param y integer
---@param layer integer
---@return integer layer_data
function THLevelMap:getCell(x, y, layer) end

---@param x integer
---@param y integer
---@return number
function THLevelMap:getCellTemperature(x, y) end

---@param x integer
---@param y integer
---@return integer
function THLevelMap:getRoomId(x, y) end

---@param x integer
---@param y integer
---@param tbl table? If provided then the table will be populated with the cell flags
---@return THCellFlags
function THLevelMap:getCellFlags(x, y, tbl) end

---@param x integer
---@param y integer
---@param tbl THCellFlags
function THLevelMap:setCellFlags(x, y, tbl) end

---@param x integer
---@param y integer
---@return string
function THLevelMap:getCellRaw(x, y) end

---@param x integer
---@param y integer
---@param layer integer [1-4]
---@param val integer
---@return THLevelMap # self
function THLevelMap:setCell(x, y, layer, val) end

---@param x integer
---@param y integer
---@param ground integer
---@param northWall integer
---@param westWall integer
---@param ui integer
---@return THLevelMap # self
function THLevelMap:setCell(x, y, ground, northWall, westWall, ui) end

---@param flags integer
---@return THLevelMap # self
function THLevelMap:setWallDrawFlags(flags) end

---@param method integer
---@return integer # the parameter is returned
function THLevelMap:setTemperatureDisplay(method) end

---@param air number [0-1]
---@param radiator number [0-1]
function THLevelMap:updateTemperatures(air, radiator) end

---@param oldX integer
---@param oldY integer
---@param oldW integer
---@param oldH integer
---@param newX integer
---@param newY integer
---@param newW integer
---@param newH integer
---@param player integer
---@return boolean valid
function THLevelMap:updateRoomBlueprint(oldX, oldY, oldW, oldH, newX, newY, newW, newH, player) end

---@return THLevelMap # self
function THLevelMap:updateShadows() end

---@return THLevelMap # self
function THLevelMap:updatePathfinding() end

---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param tile integer
---@param room integer?
---@return THLevelMap # self
function THLevelMap:markRoom(x, y, width, height, tile, room) end

---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@return THLevelMap # self
function THLevelMap:unmarkRoom(x, y, width, height) end

---@param spriteSheet THSpriteSheet
---@return THLevelMap # self
function THLevelMap:setSheet(spriteSheet) end

---@param canvas THRenderTarget
---@param screenX integer
---@param screenY integer
---@param width integer
---@param height integer
---@param canvasX integer?
---@param canvasY integer?
function THLevelMap:draw(canvas, screenX, screenY, width, height, canvasX, canvasY) end

--- See THAnimation:setHitTestResult
---@param x integer
---@param y integer
---@return table? object # Entity in our usage
function THLevelMap:hitTestObjects(x, y) end

---@param parcel integer
---@return integer count
function THLevelMap:getParcelTileCount(parcel) end

---@return integer count
function THLevelMap:getPlotCount() end

---@param parcel integer
---@param player integer
---@param tbl table?
---@return {[1]: integer, [2]: integer}[]
function THLevelMap:setPlotOwner(parcel, player, tbl) end

---@param parcel integer
---@return integer owner
function THLevelMap:getPlotOwner(parcel) end

---@param parcel integer
---@param player integer
---@return boolean
function THLevelMap:isParcelPurchasable(parcel, player) end

---@param x integer
---@param y integer
---@return integer # This return value is a bug, it returns y
function THLevelMap:eraseObjectTypes(x, y) end

---@param x integer
---@param y integer
---@param thob integer
---@return integer # This return value is a bug, it returns thob
function THLevelMap:removeObjectType(x, y, thob) end

---@param owner integer
---@return number
function THLevelMap:getLitterFraction(owner) end

---@class THPathfinder
---@overload fun(): THPathfinder
local THPathfinder = {}

---@param startX integer
---@param startY integer
---@param endX integer
---@param endY integer
---@return integer|boolean # Distance, or false if not found
function THPathfinder:findDistance(startX, startY, endX, endY) end

---@param startX integer
---@param startY integer
---@return boolean reachable
---@return integer? endX
---@return integer? endY
function THPathfinder:isReachableFromHospital(startX, startY) end

---@param startX integer
---@param startY integer
---@param endX integer
---@param endY integer
---@return integer[]? # x's in path, or null if no path
---@return integer[]|string # y's in path or error message if no path
function THPathfinder:findPath(startX, startY, endX, endY) end

--- Either nothing is returned or the coordinates of the found tile.
--- The tileNumber should be a random number, to get the (random) Nth tile.
--- That gives more variation in returned positions.
---@param queueX integer
---@param queueY integer
---@param tileNumber integer?
---@param parcel integer?
---@return boolean? endX
---@return boolean? endY
function THPathfinder:findIdleTile(queueX, queueY, tileNumber, parcel) end

--- Search for any object of the given type within the given distance of the
--- start position. The callback is called as objects are found, and if the
--- callback returns true then the search is stopped and the function returns
--- true.
---@param startX integer
---@param startY integer
---@param objectType integer
---@param maxDistance integer
---@param cb fun(x: integer, y: integer, direction: integer, distance: integer): boolean callback function
---@return boolean found
function THPathfinder:findObject(startX, startY, objectType, maxDistance, cb) end

---@param map THLevelMap
---@return THPathfinder # self
function THPathfinder:setMap(map) end

-- th_lua_anims.cpp

---@class THAnimationManager
---@overload fun(): THAnimationManager
---@field Alt32_GreyScale integer
---@field Alt32_BlueRedSwap integer
local THAnimationManager = {}

---@param startData THFile
---@param frameData THFile
---@param listData THFile
---@param elementData THFile
---@return boolean # True if the animation data was loaded successfully, false otherwise
function THAnimationManager:load(startData, frameData, listData, elementData) end

---@param data THFile
---@return boolean # True if the animation data was loaded successfully, false otherwise
function THAnimationManager:loadCustom(data) end

---@param sheet THSpriteSheet
---@return THAnimationManager # Returns self for method chaining
function THAnimationManager:setSheet(sheet) end

---@param canvas THRenderTarget
---@return THAnimationManager # Returns self for method chaining
function THAnimationManager:setCanvas(canvas) end


--- Lua interface for getting a set of animations by name and tile size (one for
--- each view direction, 'nil' if no animation is available for a direction).
---
---  getAnimations(<tile-size>, <animation-name>) -> (<anim-north>, <anim-east>,
---  <anim-south>, <anim-west>)
---@param tileSize integer
---@param name string
---@return number? north
---@return number? east
---@return number? south
---@return number? west
function THAnimationManager:getAnimations(tileSize, name) end

---@param animId integer
---@return integer
function THAnimationManager:getFirstFrame(animId) end

---@param frameId integer
---@return integer
function THAnimationManager:getNextFrame(frameId) end

---@param animId integer
---@param palette THFile
---@param alt32 integer
function THAnimationManager:setAnimationGhostPalette(animId, palette, alt32) end

---@param frameId integer
---@param x integer
---@param y integer
---@return boolean # True if the primary marker was set successfully, false otherwise
function THAnimationManager:setFramePrimaryMarker(frameId, x, y) end

---@param frameId integer
---@param x integer
---@param y integer
---@return boolean # True if the primary marker was set successfully, false otherwise
function THAnimationManager:setFrameSecondaryMarker(frameId, x, y) end

---@param canvas THRenderTarget
---@param frameId integer
---@param layers THLayers
---@param x integer
---@param y integer
---@param flags integer?
---@return THAnimationManager # Returns self for method chaining
function THAnimationManager:draw(canvas, frameId, layers, x, y, flags) end

function THAnimationManager:tick() end

---@class THAnimation
---@overload fun(): THAnimation
local THAnimation = {}

---@param animationManager THAnimationManager
---@param animId integer
---@param flags integer?
---@return THAnimation # self
function THAnimation:setAnimation(animationManager, animId, flags) end

---@param cropColumn integer
---@return THAnimation # self
function THAnimation:setCrop(cropColumn) end

---@return integer # crop column
function THAnimation:getCrop() end

---@param morphTarget THAnimation
---@param durationFactor integer?
---@return THAnimation # self
function THAnimation:setMorph(morphTarget, durationFactor) end

---@param frameId integer
---@return THAnimation # self
function THAnimation:setFrame(frameId) end

---@return integer
function THAnimation:getFrame() end

---@return integer # AnimId
function THAnimation:getAnimation() end

--- Add or Remove the animation from the map
---@return THAnimation # self
function THAnimation:setTile() end

---@param levelMap THLevelMap
---@param x integer
---@param y integer
---@param drawingLayer integer
---@return THAnimation # self
function THAnimation:setTile(levelMap, x, y, drawingLayer) end

---@return integer?, integer?
function THAnimation:getTile() end

---@param parent THAnimation
---@param markerIndex? 1|2
---@return THAnimation # self
function THAnimation:setParent(parent, markerIndex) end

---@param flags integer
---@return THAnimation # self
function THAnimation:setFlag(flags) end

---@param flags integer
---@param add boolean? # unset or true to add flags, false to remove
---@return THAnimation # self
function THAnimation:setPartialFlag(flags, add) end

---@return integer
function THAnimation:getFlag() end

--- False if both thdf_alpha_50 and thdf_alpha_75 are set
---@return boolean
function THAnimation:isVisible() end

--- Disable transparency flags
---@return THAnimation # self
function THAnimation:makeVisible() end

--- Set thdf_alpha_50 and thdf_alpha_75, rendering the animation invisible.
---@return THAnimation # self
function THAnimation:makeInvisible() end

--- Associate a tagged value with the animation
---@param tag any
---@return THAnimation # self
function THAnimation:setTag(tag) end

--- Get the tagged value associated with the animation
---@return any
function THAnimation:getTag() end

--- Set the pixel offset of the animation
---@param x integer
---@param y integer
---@return THAnimation # self
function THAnimation:setPosition(x, y) end

--- Get the pixel offset (x, y) of the animation
---@return integer x
---@return integer y
function THAnimation:getPosition() end

---@param x integer? # x speed, default 0
---@param y integer? # y speed, default 0
---@return THAnimation # self
function THAnimation:setSpeed(x, y) end

---@param layer integer
---@param id integer? # default 0
---@return THAnimation # self
function THAnimation:setLayer(layer, id) end

---@param animation THAnimation
---@return THAnimation # self
function THAnimation:setLayersFrom(animation) end

---@param scale integer
function THAnimation:setScaleFactor(scale) end

---@param val any # Typically an Entity to associate with the animation.
---@return THAnimation # self
function THAnimation:setHitTestResult(val) end

---@return integer x
---@return integer y
function THAnimation:getPrimaryMarker() end

---@return integer x
---@return integer y
function THAnimation:getSecondaryMarker() end

---@return THAnimation # self
function THAnimation:tick() end

---@param canvas THRenderTarget
---@param x integer
---@param y integer
---@return THAnimation # self
function THAnimation:draw(canvas, x, y) end

---@param effect AnimationEffect
function THAnimation:setPatientEffect(effect) end

---@class THSpriteRenderList
---@overload fun(): THSpriteRenderList
local THSpriteRenderList = {}

---@param sheet THSpriteSheet
---@return THSpriteRenderList # self
function THSpriteRenderList:setSheet(sheet) end

---@param spriteNumber integer
---@param x integer
---@param y integer
---@return THSpriteRenderList # self
function THSpriteRenderList:append(spriteNumber, x, y) end

---@param lifetime integer
---@return THSpriteRenderList # self
function THSpriteRenderList:setLifetime(lifetime) end

function THSpriteRenderList:setUseIntermediateBuffer() end

---@return boolean
function THSpriteRenderList:isDead() end

--- Add or Remove the animation from the map
---@return THSpriteRenderList # self
function THSpriteRenderList:setTile() end

---@param levelMap THLevelMap
---@param x integer
---@param y integer
---@param drawingLayer integer
---@return THSpriteRenderList # self
function THSpriteRenderList:setTile(levelMap, x, y, drawingLayer) end

---@param flags integer
---@return THSpriteRenderList # self
function THSpriteRenderList:setFlag(flags) end

---@param flags integer
---@param add boolean? # unset or true to add flags, false to remove
---@return THSpriteRenderList # self
function THSpriteRenderList:setPartialFlag(flags, add) end

---@return integer
function THSpriteRenderList:getFlag() end

--- False if both thdf_alpha_50 and thdf_alpha_75 are set
---@return boolean
function THSpriteRenderList:isVisible() end

--- Disable transparency flags
---@return THSpriteRenderList # self
function THSpriteRenderList:makeVisible() end

--- Set thdf_alpha_50 and thdf_alpha_75, rendering the animation invisible.
---@return THSpriteRenderList # self
function THSpriteRenderList:makeInvisible() end

--- Set the pixel offset of the animation
---@param x integer
---@param y integer
---@return THSpriteRenderList # self
function THSpriteRenderList:setPosition(x, y) end

---@param x integer? # x speed, default 0
---@param y integer? # y speed, default 0
---@return THSpriteRenderList # self
function THSpriteRenderList:setSpeed(x, y) end

---@param layer integer
---@param id integer? # default 0
---@return THSpriteRenderList # self
function THSpriteRenderList:setLayer(layer, id) end

---@return THSpriteRenderList # self
function THSpriteRenderList:tick() end

---@param canvas THRenderTarget
---@param x integer
---@param y integer
---@return THSpriteRenderList # self
function THSpriteRenderList:draw(canvas, x, y) end

-- th_lua_iso.cpp

---@class THIsoFilesystem
---@overload fun(path: string, sep: string?): THIsoFilesystem
local THIsoFilesystem = {}

---@param fileName string
---@return boolean? # true if found, nil otherwise
---@return string? error
function THIsoFilesystem:fileExists(fileName) end

---@param fileName string
---@return integer? size # size in bytes if found, nil otherwise
---@return string? error
function THIsoFilesystem:fileSize(fileName) end

--- Get the start and end bytes of a given file.
--- Called on an iso_filesystem, passing in a filename. If the file exists in
--- the iso then the byte position of the start of the file inclusive and the
--- end of the file exclusive is returned to the caller.
---@param fileName string
---@return integer? start
---@return integer? end
---@return string? error
function THIsoFilesystem:fileOffsets(fileName) end

---@param fileName string
---@return string? fileData
---@return string? error
function THIsoFilesystem:readContents(fileName) end

--- Returns the files in the given directory
---@param path string
---@return {[string]: string}
function THIsoFilesystem:listFiles(path) end

--- Determine if the given path is an ISO
---@param path string path to potential iso file
---@return boolean
function THIsoFilesystem.isValidRoot(filePath) end

-- th_lua_lfs_ext.cpp

---@class THLfsExt
---@overload fun(): THLfsExt
local THLfsExt = {}

--- Get all the root volumes of the system, e.g. {"/"} on unix or
--- {"C:\\", "D:\\"} on Windows
--- @return string[]
function THLfsExt.volumes() end

-- th_lua_midi.cpp

---@class THMidiPlayer
---@overload fun(soundFont: string): THMidiPlayer
---@overload fun(api: string?, port: string?, sysexMasterVolume: boolean, soundFont: string?): THMidiPlayer
local THMidiPlayer = {}

--- Get the available MIDI APIs on the current system
---@return string[] apis
function THMidiPlayer.getAvailableApis() end

--- Get the list of ports available on the current MIDI API
---@return string[] ports
function THMidiPlayer:portList() end

--- Play the given XMI (Miles Sound System) file
---@param xmiData THFile
function THMidiPlayer:playXmi(xmiData) end

--- Set the music volume. vol should be between 0 and 1.
---@param vol number
function THMidiPlayer:setVolume(vol) end

--- Stop the currently playing track (cannot resume)
function THMidiPlayer:stop() end

--- Pause the currently playing track
function THMidiPlayer:pause() end

--- Resume playing the track that was previously paused
function THMidiPlayer:resume() end

--- Destroy the THMidiPlayer
function THMidiPlayer:close() end

-- th_lua_movie.cpp

---@class THMoviePlayer
---@overload fun(): THMoviePlayer
local THMoviePlayer = {}

---@param canvas THRenderTarget
function THMoviePlayer:setRenderer(canvas) end

--- Check if movie support is compiled in
---@return boolean
function THMoviePlayer:getEnabled() end

--- Load a movie to play
---@param filePath string
---@return boolean loaded
---@return string error
function THMoviePlayer:load(filePath) end

--- Unload a movie when finished playing
function THMoviePlayer:unload() end

--- Play the currently loaded movie
---@return string error
function THMoviePlayer:play() end

--- Stop the movie
function THMoviePlayer:stop() end

--- Pause or unpause the movie
function THMoviePlayer:togglePause() end

--- Get the height of the video frame in pixels
---@return integer height
function THMoviePlayer:getNativeHeight() end

--- Get the width of the video frame in pixels
---@return integer width
function THMoviePlayer:getNativeWidth() end

--- Check if the video has an audio track
---@return boolean
function THMoviePlayer:hasAudioTrack() end

--- Get the length of the movie in milliseconds
---@return number length
function THMoviePlayer:getLength() end

--- Draw the appropriate frame of the movie to the renderer
---@param x integer
---@param y integer
---@param width integer
---@param height integer
function THMoviePlayer:refresh(x, y, width, height) end

--- Allocate the picture buffer for the current renderer
--- Call after making any changes to the render target, e.g. resizing the
--- window.
function THMoviePlayer:allocatePictureBuffer() end

--- Deallocate the picture buffer for the current renderer
--- Call before making changes to the render target.
function THMoviePlayer:deallocatePictureBuffer() end

-- th_lua_sound.cpp

---@class THSoundArchive
---@overload fun(): THSoundArchive
---@operator len(): number
local THSoundArchive = {}

---@param data THFile
---@return boolean success
function THSoundArchive:load(data) end

--- Get the name of the audio at the given index
---@param idx number|string
---@return string? filename
---@return string? error
function THSoundArchive:getFilename(idx) end

--- Get the duration in seconds of the audio at the given index
---@param idx number|string
---@return number? duration
---@return string? error
function THSoundArchive:getDuration(idx) end

--- Get the sound data at the given index
---@param idx number|string
---@return string? data
---@return string? error
function THSoundArchive:getFileData() end

--- Check if the given sound index exists
---@param idx number|string
---@return boolean
function THSoundArchive:soundExists(idx) end

---@class THSoundFx
---@overload fun(): THSoundFx
local THSoundFx = {}

---@param archive THSoundArchive
---@return THSoundFx # self
function THSoundFx:setSoundArchive(archive) end

--- Play the sound effect with the given index.
---
--- x and y may be provided if the sound effect should be positional, in which
--- case the volume will depend on the distance from the location provided in
--- setCamera. Either both x and y must be set or neither set.
---
--- When the sound is over, if a callbackId is provided then a sound_over event
--- will be dispatched with the given index.
---@param idx string|number
---@param vol number
---@param x integer?
---@param y integer?
---@param callbackId integer?
---@param callbackDelay number? milliseconds to wait after finishing audio before callback
---@param loops integer? how many times to repeat, e.g. 1 plays audio twice, -1 for infinite
---@param pitch number? frequency ratio, 1 (the default) as recorded, more is higher and faster
---@return integer? handle nil if failed
function THSoundFx:play(idx, vol, x, y, callbackId, callbackDelay, loops, pitch) end

--- Pause/resume the audio with the given handle
---@param handle integer
---@param callbackId integer?
function THSoundFx:togglePause(handle, callbackId) end

--- Stop the audio playing with the given handle. Cancels the callback.
---@param handle integer
---@param callbackId integer?
function THSoundFx:stop(handle, callbackId) end

--- Check if the given handle is playing
---@param handle integer
---@return boolean
function THSoundFx:isPlaying(handle) end

--- Set the volume of all sound effects
---@param vol number
---@return THSoundFx # self
function THSoundFx:setSoundVolume(vol) end

--- Enable or disable all sound effects
---@param on boolean
---@return THSoundFx # self
function THSoundFx:setSoundEffectsOn(on) end

--- Set the camera location for positional audio
---@param x integer
---@param y integer
---@param radius integer
function THSoundFx:setCamera(x, y, radius) end

--- Reserve a sound channel
---@return integer channel
function THSoundFx:reserveChannel() end

--- Release a previously reserved channel
---@param chanel integer
---@return THSoundFx # self
function THSoundFx:releaseChannel(channel) end

-- th_lua_strings.cpp

---@class THStringProxy: string
---@overload fun(x: any, ...): THStringProxy
local THStringProxy = {}

--- Return the object inside the THStringProxy
---@return any
---@return boolean
function THStringProxy:_unwrap() end

--- Reloads the proxies from the old root, storing
--- the results in the new root.
--- This applies all the operations that have been performed on the underlying
--- object again.
---@param oldRoot THStringProxy
---@param newRoot THStringProxy
function THStringProxy.reload(oldRoot, newRoot) end

-- th_lua_ui.cpp

---@class THAbstractWindow
local THAbstractWindow = {}

--- Draw the map in Town Map style on the canvas
---@param window Window
---@param map THLevelMap
---@param canvas THRenderTarget
---@param x integer
---@param y integer
---@param showHeat boolean
---@param scale integer? Default 1
function THAbstractWindow.townMapDraw(window, map, canvas, x, y, showHeat, scale) end

---@class TH
---@field palette THPalette
---@field bitmap THRawBitmap
---@field sheet THSpriteSheet
---@field font THFont
---@field bitmap_font THBitmapFont
---@field freetype_font THFreetypeFont
---@field layers THLayers
---@field cursor THCursor
---@field surface THRenderTarget
---@field line THLineSequence
---@field map THLevelMap
---@field pathfinder THPathfinder
---@field anims AnimationManager
---@field animation THAnimation
---@field spriteList THSpriteRenderList
---@field iso_fs THIsoFilesystem
---@field lfsExt THLfsExt
---@field midiPlayer THMidiPlayer
---@field moviePlayer THMoviePlayer
---@field soundArchive THSoundArchive
---@field soundEffects THSoundFx
---@field stringProxy THStringProxy
---@field windowHelpers THAbstractWindow
local TH = {}

--- Load a translation file and return a table of strings.
--- @param file THFile # The translation file to load
--- @return table | boolean # Table of strings or boolean false if the file could not be loaded
function TH.LoadStrings(file) end

--- @return table
function TH.GetCompileOptions() end

--- @return THFileBlob tab
--- @return THFileBlob dat
--- @return THFileBlob pal
function TH.GetBuiltinFont() end

--- Fetch the latest version information from the update endpoint.
--- @return string? body
--- @return string? err
function TH.FetchLatestVersionInfo() end

--- @param file THFile # The file to calculate the CRC32 for
--- @return integer # The CRC32 checksum of the file
function TH.CRC32File(file) end

return TH
