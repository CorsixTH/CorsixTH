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

dofile "window"

class "UI" (Window)

local TH = require "TH"
local WM = require "sdl".wm
local lfs = require "lfs"
local pathsep = package.config:sub(1, 1)

local function invert(t)
  local r = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      for _, v in ipairs(v) do
        r[v] = k
      end
    else
      r[v] = k
    end
  end
  return r
end

local key_codes = invert {
  esc = 27,
  up = 273,
  down = 274,
  right = 275,
  left = 276,
  F9 = 290,
  F10 = 291,
  F11 = 292,
  F12 = 293,
  S = 115,
  Enter = 13,
  shift = {303, 304},
  ctrl = {305, 306},
  alt = {307, 308, 313},
}

local button_codes = invert {
  left = 1,
  middle = 2,
  right = 3,
}

-- Temporary code
local patients
local function get_patient()
  local n = patients.n
  if n == #patients then
    patients.n = 1
  else
    patients.n = n + 1
  end
  return patients[n]
end

function UI:UI(app)
  self:Window()
  self.app = app
  self.screen_offset_x = 0
  self.screen_offset_y = 0
  self.cursor = nil
  self.cursor_x = 0
  self.cursor_y = 0
  self.cursor_entity = nil
  self.background = false
  self.tick_scroll_amount = false
  self.tick_scroll_mult = 1
  self.modal_windows = {
    -- [class_name] -> window,
  }
  
  self.down_count = 0
  self.default_cursor = app.gfx:loadMainCursor(1)
  self.down_cursor = app.gfx:loadMainCursor(2)
  self:setCursor(self.default_cursor)
  
  app:loadLuaFolder("dialogs", true)
  
  self.adviser = UIAdviser(self)
  self.bottom_panel = UIBottomPanel(self)
  self.menu_bar = UIMenuBar(self)
  self:addWindow(self.adviser)
  self:addWindow(self.bottom_panel)
  self:addWindow(self.menu_bar)
  
  do
    local map_w = app.map.width
    local map_h = app.map.height
    assert(map_w == map_h, "UI limiter requires square map")
    local scr_w = app.config.width
    local scr_h = app.config.height
    -- The visible diamond is the region which the top-left corner of the screen
    -- is limited to, and ensures that the map always covers all of the screen.
    -- Its verticies are at (x + w, y), (x - w, y), (x, y + h), (x, y - h).
    self.visible_diamond = {
      x = - scr_w / 2,
      y = 16 * map_h - scr_h / 2,
      w = 32 * map_h - scr_h - scr_w / 2,
      h = 16 * map_h - scr_h / 2 - scr_w / 4,
    }
    if self.visible_diamond.w <= 0 or self.visible_diamond.h <= 0 then
      -- For a standard 128x128 map, screen size would have to be in the
      -- region of 3276x2457 in order to be too large.
      error "Screen size too large for the map"
    end
    self.screen_offset_x = self.visible_diamond.x
    self.screen_offset_y = self.visible_diamond.y
    self.in_visible_diamond = true
    self.limit_to_visible_diamond = true
  end
  
  -- Temporary code
  patients = {}
  self:debugMakePatients()
end

function UI:debugMakePatients()
  if patients.n == 1 or patients.n == nil then
    patients.n = #patients + 1
  end
  for i = 1, 4 do
    local entity = self.app.world:newEntity("Humanoid", 2)
    local types = {
      -- Types with variations doubled up to make them more likely:
      "Standard Male Patient", "Standard Male Patient",
      "Alternate Male Patient", "Alternate Male Patient",
      "Slack Male Patient", "Slack Male Patient",
      "Transparent Male Patient", "Transparent Male Patient",
      "Standard Female Patient", "Standard Female Patient",
      "Transparent Female Patient", "Transparent Female Patient",
      -- Types with no variation:
      "Chewbacca Patient",
      "Elvis Patient",
      "Invisible Patient",
    }
    entity:setType(types[math.random(1, #types)])
    entity:setTile(63 + (i - 1) % 2, 63 + math.floor(i / 3))
    entity:setLayer(0, math.random(1, 4) * 2)
    entity:setLayer(1, math.random(0, 3) * 2)
    entity:setLayer(2, math.random(0, 2) * 2)
    entity:setLayer(3, math.random(0, 5) * 2)
    entity:setLayer(4, math.random(0, 5) * 2)
    patients[#patients + 1] = entity
  end
end

function UI:debugMakeAdviserTalk()
  local id = 2
  while _S(54, id) == "." do
    id = math.floor(math.random(3, 115))
  end
  self.adviser:say(_S(54, id))
end

function UI:setCursor(cursor)
  if cursor ~= self.cursor then
    self.cursor = cursor
    if cursor.use then
      -- Cursor is a true C cursor, perhaps even a hardware cursor.
      -- Make the real cursor visible, and use this as it.
      self.simulated_cursor = nil
      WM.showCursor(true)
      cursor:use(self.app.video)
    else
      -- Cursor is a Lua simulated cursor.
      -- Make the real cursor invisible, and simulate it with this.
      WM.showCursor(false)
      self.simulated_cursor = cursor
    end
  end
end

function UI:draw(canvas) 
  local app = self.app
  local config = app.config
  if not self.in_visible_diamond then
    canvas:fillBlack()
  end
  if self.background then
    canvas:draw(self.background)
  end
  app.map:draw(canvas, self.screen_offset_x, self.screen_offset_y, config.width, config.height, 0, 0)
  Window.draw(self, canvas)
  if self.simulated_cursor then
    self.simulated_cursor.draw(canvas, self.cursor_x, self.cursor_y)
  end
end

local scroll_keys = {
  up = {x = 0, y = -10},
  right = {x = 10, y = 0},
  down = {x = 0, y = 10},
  left = {x = -10, y = 0},
}

function UI:onKeyDown(code)
  local key = key_codes[code]
  if not key then
    return
  end
  if self.buttons_down[key] == false then
    self.buttons_down[key] = true
  end
  if scroll_keys[key] then
    local dx, dy = scroll_keys[key].x, scroll_keys[key].y
    if self.tick_scroll_amount then
      self.tick_scroll_amount.x = self.tick_scroll_amount.x + dx
      self.tick_scroll_amount.y = self.tick_scroll_amount.y + dy
    else
      self.tick_scroll_amount = {x = dx, y = dy}
    end
    return
  end
  if key == "esc" then
    for i = #self.windows, 1, -1 do
      local window = self.windows[i]
      if window.esc_closes then
        window:close()
        return true
      end
    end
  elseif key == "F10" then -- Restart
    debug.getregistry()._RESTART = true
    TheApp.running = false
    return true
  elseif key == "F11" then -- Make Adviser say a random phrase
    self:debugMakeAdviserTalk()
  elseif key == "F12" then -- Show watch
    self:addWindow(UIWatch(self))
  elseif self.buttons_down.alt and key == "Enter" then --Alt + Enter: Toggle Fullscreen
    local modes = self.app.modes
    
    -- Search in modes table if it contains a fullscreen value and keep the index
    -- If not found, we will add an index at end of table
    local index = #modes + 1
    for i=1, #modes do
      if modes[i] == "fullscreen" then
        index = i
        break
      end
    end
    
    -- Toggle Fullscreen mode
    self.app.fullscreen = not self.app.fullscreen
    if self.app.fullscreen then
      modes[index] = "fullscreen"
    else
      modes[index] = ""
    end
    self.app.video:endFrame()
    self.app.video = assert(TH.surface(self.app.config.width, self.app.config.height, unpack(modes))) -- Apply changements
    self.app.gfx:updateTarget(self.app.video)
    self.app.video:startFrame()
    self.cursor:use(self.app.video) -- Redraw cursor
  elseif key == "S" then -- Take a screenshot
     -- Find an index for screenshot which is not already used
    local i = 0
    local filename
    repeat
      filename = (".%sscreenshot%i.bmp"):format(pathsep, i)
      i = i + 1
    until lfs.attributes(filename, "size") == nil
    self.app.video:takeScreenshot(filename) -- Take screenshot
  end
end

function UI:onKeyUp(code)
  local key = key_codes[code]
  if not key then
    return
  end
  if self.buttons_down[key] == true then
    self.buttons_down[key] = false
  end
  if scroll_keys[key] then
    local dx, dy = scroll_keys[key].x, scroll_keys[key].y
    dx = self.tick_scroll_amount.x - dx
    dy = self.tick_scroll_amount.y - dy
    if dx == 0 and dy == 0 then
      self.tick_scroll_amount = false
      self.tick_scroll_mult = 1
    else
      self.tick_scroll_amount.x = dx
      self.tick_scroll_amount.y = dy
    end
    return
  end
end

function UI:onMouseDown(code, x, y)
  local repaint = false
  local button = button_codes[code]
  if not button then
    return
  end
  if self.cursor_entity == nil and self.down_count == 0 then
    self:setCursor(self.down_cursor)
    repaint = true
  end
  self.down_count = self.down_count + 1
  self.buttons_down[button] = true
  
  return Window.onMouseDown(self, button, x, y) or repaint
end

local highlight_x, highlight_y

function UI:onMouseUp(code, x, y)
  local repaint = false
  local button = button_codes[code]
  if not button then
    return
  end
  self.down_count = self.down_count - 1
  if self.down_count <= 0 then
    if self.cursor_entity == nil then
      self:setCursor(self.default_cursor)
      repaint = true
    end
    self.down_count = 0
  end
  self.buttons_down[button] = false
  
  if Window.onMouseUp(self, button, x, y) then
    repaint = true
  else
    if self.cursor_entity and self.cursor_entity.onClick then
      self.cursor_entity:onClick(self, button)
      repaint = true
    end
  end
  
  if button == "right" then
    if highlight_x then
      get_patient():walkTo(highlight_x, highlight_y)
    end
  end
  
  return repaint
end

function UI:ScreenToWorld(x, y)
  return self.app.map:ScreenToWorld(self.screen_offset_x + x, self.screen_offset_y + y)
end

function UI:WorldToScreen(x, y)
  x, y = self.app.map:WorldToScreen(x, y)
  x = x - self.screen_offset_x
  y = y - self.screen_offset_y
  return x, y
end

function UI:getScreenOffset()
  return self.screen_offset_x, self.screen_offset_y
end

function UI:onCursorWorldPositionChange()
  local x = self.screen_offset_x + self.cursor_x
  local y = self.screen_offset_y + self.cursor_y
  -- TODO: Hit test against UI first (-> entity = nil)
  local entity = self.app.map.th:hitTestObjects(x, y)
  if entity ~= self.cursor_entity then
    self.cursor_entity = entity
    local cursor = entity and entity.hover_cursor or
      (self.down_count ~= 0 and self.down_cursor or self.default_cursor)
    self:setCursor(cursor)
  end
end

local UpdateCursorPosition = TH.cursor.setPosition

function UI:onMouseMove(x, y, dx, dy)
  local repaint = UpdateCursorPosition(self.app.video, x, y)
  
  self.cursor_x = x
  self.cursor_y = y
  if self:onCursorWorldPositionChange() then
    repaint = true
  end
  if self.buttons_down.middle then
    self:scrollMap(-dx, -dy)
    repaint = true
  end
  
  if x <= 3 or y <= 3 or x >= self.app.config.width - 3 or y >= self.app.config.height - 3 then
    local dx = 0
    local dy = 0
    if x <= 3 then
      dx = -10
    elseif x >= self.app.config.width - 3 then
      dx = 10
    end
    if y <= 3 then
      dy = -10
    elseif y >= self.app.config.height - 3 then
      dy = 10
    end

    self.tick_scroll_amount = {x = dx, y = dy}
  else
    self.tick_scroll_amount = {x = 0, y = 0}
  end
  
  if Window.onMouseMove(self, x, y, dx, dy) then
    repaint = true
  end
  
  local map = self.app.map
  local wx, wy = map:ScreenToWorld(self.screen_offset_x + x, self.screen_offset_y + y)
  wx = math.floor(wx)
  wy = math.floor(wy)
  if highlight_x then
    --map.th:setCell(highlight_x, highlight_y, 4, 0)
    highlight_x = nil
  end
  if 1 <= wx and wx <= 128 and 1 <= wy and wy <= 128 then
    if map.th:getCellFlags(wx, wy).passable then
      --map.th:setCell(wx, wy, 4, 24 + 8 * 256)
      highlight_x = wx
      highlight_y = wy
    end
  end
  
  return repaint
end

function UI:onTick()
  Window.onTick(self)
  local repaint = false
  if self.tick_scroll_amount then
    local mult = self.tick_scroll_mult
    mult = mult + 0.02
    if mult > 2 then
      mult = 2
    end
    self.tick_scroll_mult = mult
    self:scrollMap(self.tick_scroll_amount.x * mult, self.tick_scroll_amount.y * mult)
    repaint = true
  end
  if self:onCursorWorldPositionChange() then
    repaint = true
  end
  return repaint
end

local abs, sqrt_5, floor = math.abs, math.sqrt(1 / 5), math.floor

function UI:scrollMapTo(x, y)
  return self:scrollMap(x - self.screen_offset_x - self.app.config.width / 2,
                        y - self.screen_offset_y - self.app.config.height / 2)
end

function UI:scrollMap(dx, dy)
  dx = dx + self.screen_offset_x
  dy = dy + self.screen_offset_y

  -- If point outside visible diamond, then move point to the nearest position
  -- on the edge of the diamond (NB: relies on diamond.w == 2 * diamond.h).
  local visible_diamond = self.visible_diamond
  local rx = dx - visible_diamond.x
  local ry = dy - visible_diamond.y
  self.in_visible_diamond = true
  if abs(rx) + abs(ry) * 2 > visible_diamond.w then
    if self.limit_to_visible_diamond then
      -- Determine the quadrant which the point lies in and accordingly set:
      --  (vx, vy) : a unit vector perpendicular to the diamond edge in the quadrant
      --  (p1x, p1y), (p2x, p2y) : the two diamond verticies in the quadrant
      --  d : distance from the point to the line defined by the diamond edge (not the line segment itself)
      local vx, vy, d
      local p1x, p1y, p2x, p2y = 0, 0, 0, 0
      if rx >= 0 and ry >= 0 then
        p1x, p2y =  visible_diamond.w,  visible_diamond.h
        vx, vy = sqrt_5, 2 * sqrt_5
        d = (rx * vx + ry * vy) - (p1x * vx)
      elseif rx >= 0 and ry < 0 then
        p2x, p1y =  visible_diamond.w, -visible_diamond.h
        vx, vy = sqrt_5, -2 * sqrt_5
        d = (rx * vx + ry * vy) - (p2x * vx)
      elseif rx < 0 and ry >= 0 then
        p2x, p1y = -visible_diamond.w,  visible_diamond.h
        vx, vy = -sqrt_5, 2 * sqrt_5
        d = (rx * vx + ry * vy) - (p2x * vx)
      else--if rx < 0 and ry < 0 then
        p1x, p2y = -visible_diamond.w, -visible_diamond.h
        vx, vy = -sqrt_5, -2 * sqrt_5
        d = (rx * vx + ry * vy) - (p1x * vx)
      end
      -- In the unit vector parallel to the diamond edge, resolve the two verticies and
      -- the point, and either move the point to the edge or to one of the two verticies.
      -- NB: vx, vy, p1x, p1y, p2x, p2y are set such that p1 < p2.
      local p1 = vx * p1y - vy * p1x
      local p2 = vx * p2y - vy * p2x
      local pd = vx * ry - vy * rx
      if pd < p1 then
        dx, dy = p1x + visible_diamond.x, p1y + visible_diamond.y
      elseif pd > p2 then
        dx, dy = p2x + visible_diamond.x, p2y + visible_diamond.y
      else--if p1 <= pd and pd <= p2 then
        dx, dy = dx - d * vx, dy - d * vy
      end
    else
      self.in_visible_diamond = false
    end
  end
  
  self.screen_offset_x = floor(dx + 0.5)
  self.screen_offset_y = floor(dy + 0.5)
end

function UI:addWindow(window)
  if window.modal_class then
    if self.modal_windows[window.modal_class] then
      self.modal_windows[window.modal_class]:close()
    end
    self.modal_windows[window.modal_class] = window
  end
  Window.addWindow(self, window)
end

function UI:removeWindow(window)
  if Window.removeWindow(self, window) then
    local class = window.modal_class
    if class and self.modal_windows[class] == window then
      self.modal_windows[class] = nil
    end
    return true
  else
    return false
  end
end
