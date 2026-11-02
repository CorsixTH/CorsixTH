---@meta TH

---@class THFileBlob
local THFileBlob = {}

---@alias THFile THFileBlob | string

---@class THSpriteSheet
local THSpriteSheet = {}

---@class THRenderTarget
local THRenderTarget = {}

---@class THLayers
local THLayers = {}

---@class THAnimationManager
---@operator call: fun(): THAnimationManager
---@field Alt32_GreyScale integer
---@field Alt32_BlueRedSwap integer
local THAnimationManager = {}

---@param startData THFile
---@param frameData THFile
---@param listData THFile
---@param elementData THFile
---@return boolean # True if the animation data was loaded successfully, false otherwise
function THAnimationManager:load(startData, frameData, listData, elementData) end

--- @param data THFile
--- @return boolean # True if the animation data was loaded successfully, false otherwise
function THAnimationManager:loadCustom(data) end

--- @param sheet THSpriteSheet
--- @return THAnimationManager # Returns self for method chaining
function THAnimationManager:setSheet(sheet) end

--- @param canvas THRenderTarget
--- @return THAnimationManager # Returns self for method chaining
function THAnimationManager:setCanvas(canvas) end


--- Lua interface for getting a set of animations by name and tile size (one for
--- each view direction, 'nil' if no animation is available for a direction).
---
---  getAnimations(<tile-size>, <animation-name>) -> (<anim-north>, <anim-east>,
---  <anim-south>, <anim-west>)
--- @param tileSize
--- @param name string
--- @return number?, number?, number?, number? # The animation IDs for north, east, south, and west directions
function THAnimationManager:getAnimations(tileSize, name) end

--- @param animId integer
--- @return integer
function THAnimationManager:getFirstFrame(animId) end

--- @param frameId integer
--- @return integer
function THAnimationManager:getNextFrame(frameId) end

--- @param animId integer
--- @param palette THFile
--- @param alt32 integer
function THAnimationManager:setAnimationGhostPalette(animId, palette, alt32) end

--- @param frameId integer
--- @param x integer
--- @param y integer
--- @return boolean # True if the primary marker was set successfully, false otherwise
function THAnimationManager:setFramePrimaryMarker(frameId, x, y) end

--- @param frameId integer
--- @param x integer
--- @param y integer
--- @return boolean # True if the primary marker was set successfully, false otherwise
function THAnimationManager:setFrameSecondaryMarker(frameId, x, y) end

--- @param canvas THRenderTarget
--- @param frameId integer
--- @param layers THLayers
--- @param x integer
--- @param y integer
--- @param flags integer?
--- @return THAnimationManager # Returns self for method chaining
function THAnimationManager:draw(canvas, frameId, layers, x, y, flags) end

function THAnimationManager:tick() end


---@class TH
local TH = {}

--- Load a translation file and return a table of strings.
--- @param file THFile # The translation file to load
--- @return table | boolean # Table of strings or boolean false if the file could not be loaded
function TH.LoadStrings(file) end

--- @return table
function TH.GetCompileOptions() end

--- @return THFileBlob, THFileBlob, THFileBlob # Tab, Dat, Pal
function TH.GetBuiltinFont() end

--- Fetch the latest version information from the update endpoint.
--- @return string?, string? # The body of the update endpoint, and the error message if the request failed or curl is not available.
function TH.FetchLatestVersionInfo() end

--- @param file THFile # The file to calculate the CRC32 for
--- @return integer # The CRC32 checksum of the file
function TH.CRC32File(file) end

return TH