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
  up = 273,
  down = 274,
  right = 275,
  left = 276,
  F9 = 290,
  F10 = 291,
  shift = {303, 304},
  ctrl = {305, 306},
  alt = {307, 308, 313},
}

local button_codes = invert {
  left = 1,
  middle = 2,
  right = 3,
}

local entity

function UI:UI(app)
  self:Window()
  self.app = app
  self.screen_offset_x = 0
  self.screen_offset_y = 0
  self.background = false
  self.tick_scroll_amount = false
  self.tick_scroll_mult = 1
  
  app:loadLuaFolder("dialogs", true)
  
  self.bottom_panel = UIBottomPanel(self)
  self.menu_bar = UIMenuBar(self)
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
  entity = TheApp.world:newEntity("Humanoid", 2)
  entity:setType"Standard Male Patient"
  entity:setTile(63, 63)
  entity:setLayer(0, 8)
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
  if key == "F10" then
    debug.getregistry()._RESTART = true
    TheApp.running = false
    return true
  elseif key == "F9" then
    self:addWindow(UIPatient(self, entity))
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
  local button = button_codes[code]
  if not button then
    return
  end
  self.buttons_down[button] = true
  if button == "right" then
    self.app.map.th:setWallDrawFlags(4)
  end
  
  return Window.onMouseDown(self, button, x, y)
end

local highlight_x, highlight_y

function UI:onMouseUp(code, x, y)
  local button = button_codes[code]
  if not button then
    return
  end
  self.buttons_down[button] = false
  if button == "right" then
    self.app.map.th:setWallDrawFlags(0)
  end
  
  Window.onMouseUp(self, button, x, y)
  
  if button == "left" or button == "right" then
    if highlight_x then
      entity:walkTo(highlight_x, highlight_y)
    end
  end
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

function UI:onMouseMove(x, y, dx, dy)
  local repaint = false
  
  if self.buttons_down.middle then
    self:scrollMap(-dx, -dy)
    repaint = true
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
  return repaint
end

local abs, sqrt_5, floor = math.abs, math.sqrt(1 / 5), math.floor

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
