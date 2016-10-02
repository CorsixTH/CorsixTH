--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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

dofile "ui"

--! Variant of UI for running games
class "GameUI" (UI)

---@type GameUI
local GameUI = _G["GameUI"]

local TH = require "TH"

-- The maximum distance to shake the screen from the origin during an
-- earthquake with full intensity.
local shake_screen_max_movement = 50 --pixels

--! Game UI constructor.
--!param app (Application) Application object.
--!param local_hospital Hospital to display
--!param map_editor (bool) Whether the map is editable.
function GameUI:GameUI(app, local_hospital, map_editor)
  self:UI(app)

  self.hospital = local_hospital
  self.tutorial = { chapter = 0, phase = 0 }
  if map_editor then
    self.map_editor = UIMapEditor(self)
    self:addWindow(self.map_editor)
  else
    self.adviser = UIAdviser(self)
    self.bottom_panel = UIBottomPanel(self)
    self.bottom_panel:addWindow(self.adviser)
    self:addWindow(self.bottom_panel)
  end

  -- UI widgets
  self.menu_bar = UIMenuBar(self, self.map_editor)
  self:addWindow(self.menu_bar)

  local scr_w = app.config.width
  local scr_h = app.config.height
  self.visible_diamond = self:makeVisibleDiamond(scr_w, scr_h)
  if self.visible_diamond.w <= 0 or self.visible_diamond.h <= 0 then
    -- For a standard 128x128 map, screen size would have to be in the
    -- region of 3276x2457 in order to be too large.
    if not self.map_editor then
      error("Screen size too large for the map")
    end
  end
  self.screen_offset_x, self.screen_offset_y = app.map:WorldToScreen(
    app.map.th:getCameraTile(local_hospital:getPlayerIndex()))
  self.zoom_factor = 1
  self:scrollMap(-scr_w / 2, 16 - scr_h / 2)
  self.limit_to_visible_diamond = not self.map_editor
  self.transparent_walls = false
  self.do_world_hit_test = true

  self:setRandomAnnouncementTarget()
  self.ticks_since_last_announcement = 0

  self.momentum = app.config.scrolling_momentum
  self.current_momentum = {x = 0.0, y = 0.0, z = 0.0}

  self.speed_up_key_pressed = false

  -- The currently specified intensity value for earthquakes. To abstract
  -- the effect from the implementation this value is a number between 0
  -- and 1.
  self.shake_screen_intensity = 0
end

function GameUI:setupGlobalKeyHandlers()
  UI.setupGlobalKeyHandlers(self)

  self:addKeyHandler("escape", self, self.setEditRoom, false)
  self:addKeyHandler("escape", self, self.showMenuBar)
  self:addKeyHandler("z", self, self.keySpeedUp)
  self:addKeyHandler("x", self, self.keyTransparent)
  self:addKeyHandler({"shift", "a"}, self, self.toggleAdviser)
  self:addKeyHandler({"ctrl", "d"}, self.app.world, self.app.world.dumpGameLog)
  self:addKeyHandler({"ctrl", "t"}, self.app, self.app.dumpStrings)
  self:addKeyHandler({"alt", "a"}, self, self.togglePlayAnnouncements)
  self:addKeyHandler({"alt", "s"}, self, self.togglePlaySounds)
  self:addKeyHandler({"alt", "m"}, self, self.togglePlayMusic)

  if self.app.config.debug then
    self:addKeyHandler("f11", self, self.showCheatsWindow)
  end
end

function GameUI:makeVisibleDiamond(scr_w, scr_h)
  local map_w = self.app.map.width
  local map_h = self.app.map.height
  assert(map_w == map_h, "UI limiter requires square map")

  -- The visible diamond is the region which the top-left corner of the screen
  -- is limited to, and ensures that the map always covers all of the screen.
  -- Its vertices are at (x + w, y), (x - w, y), (x, y + h), (x, y - h).
  return {
    x = - scr_w / 2,
    y = 16 * map_h - scr_h / 2,
    w = 32 * map_h - scr_h - scr_w / 2,
    h = 16 * map_h - scr_h / 2 - scr_w / 4,
  }
end

--! Calculate the minimum valid zoom value
--!
--! Zooming out too much would cause negative width/height to be returned from
--! makeVisibleDiamond. This function calculates the minimum zoom_factor that
--! would be allowed.
function GameUI:calculateMinimumZoom()
  local scr_w = self.app.config.width
  local scr_h = self.app.config.height
  local map_h = self.app.map.height

  -- Minimum width:  0 = 32 * map_h - (scr_h/factor) - (scr_w/factor) / 2,
  -- Minimum height: 0 = 16 * map_h - (scr_h/factor) / 2 - (scr_w/factor) / 4
  -- Both rearrange to:
  local factor = (scr_w + 2 * scr_h) / (64 * map_h)

  -- Due to precision issues a tolerance is needed otherwise setZoom might fail
  factor = factor + 0.001

  return factor
end

function GameUI:setZoom(factor)
  if factor <= 0 then
    return false
  end
  if not factor or math.abs(factor - 1) < 0.001 then
    factor = 1
  end

  local scr_w = self.app.config.width
  local scr_h = self.app.config.height
  local new_diamond = self:makeVisibleDiamond(scr_w / factor, scr_h / factor)
  if new_diamond.w < 0 or new_diamond.h < 0 then
    return false
  end

  self.visible_diamond = new_diamond
  local refx, refy = self.cursor_x or scr_w / 2, self.cursor_y or scr_h / 2
  local cx, cy = self:ScreenToWorld(refx, refy)
  self.zoom_factor = factor

  cx, cy = self.app.map:WorldToScreen(cx, cy)
  cx = cx - self.screen_offset_x - refx / factor
  cy = cy - self.screen_offset_y - refy / factor
  self:scrollMap(cx, cy)
  return true
end

function GameUI:draw(canvas)
  local app = self.app
  local config = app.config
  if self.map_editor or not self.in_visible_diamond then
    canvas:fillBlack()
  end
  local zoom = self.zoom_factor
  local dx = self.screen_offset_x +
      math.floor((0.5 - math.random()) * self.shake_screen_intensity * shake_screen_max_movement * 2)
  local dy = self.screen_offset_y +
      math.floor((0.5 - math.random()) * self.shake_screen_intensity * shake_screen_max_movement * 2)
  if canvas:scale(zoom) then
    app.map:draw(canvas, dx, dy, math.floor(config.width / zoom), math.floor(config.height / zoom), 0, 0)
    canvas:scale(1)
  else
    self:setZoom(1)
    app.map:draw(canvas, dx, dy, config.width, config.height, 0, 0)
  end
  Window.draw(self, canvas, 0, 0) -- NB: not calling UI.draw on purpose
  self:drawTooltip(canvas)
  if self.simulated_cursor then
    self.simulated_cursor.draw(canvas, self.cursor_x, self.cursor_y)
  end
end

function GameUI:onChangeResolution()
  -- Calculate and enforce minimum zoom
  local minimum_zoom = self:calculateMinimumZoom()
  if self.zoom_factor < minimum_zoom then
    self:setZoom(minimum_zoom)
  end
  -- Recalculate scrolling bounds
  local scr_w = self.app.config.width
  local scr_h = self.app.config.height
  self.visible_diamond = self:makeVisibleDiamond(scr_w / self.zoom_factor, scr_h / self.zoom_factor)
  self:scrollMap(0, 0)

  UI.onChangeResolution(self)
end

--! Update UI state after the UI has been depersisted
--! When an UI object is depersisted, its state will reflect how the UI was at
-- the moment of persistence, which may be different to the keyboard / mouse
-- state at the moment of depersistence.
--!param ui (UI) The previously existing UI object, from which values should be
-- taken.
function GameUI:resync(ui)
  if self.drag_mouse_move then
    -- Check that a window is actually being dragged. If none is found, then
    -- remove the drag handler.
    local something_being_dragged = false
    for _, window in ipairs(self.windows) do
      if window.dragging then
        something_being_dragged = true
        break
      end
    end
    if not something_being_dragged then
      self.drag_mouse_move = nil
    end
  end
  self.tick_scroll_amount = ui.tick_scroll_amount
  self.down_count = ui.down_count
  if ui.limit_to_visible_diamond ~= nil then
    self.limit_to_visible_diamond = ui.limit_to_visible_diamond
  end

  self.key_remaps = ui.key_remaps
  self.key_to_button_remaps = ui.key_to_button_remaps
end

local scroll_keys = {
  up    = {x =   0, y = -10},
  right = {x =  10, y =   0},
  down  = {x =   0, y =  10},
  left  = {x = -10, y =   0},
  ["keypad 8"] = {x =   0, y = -10},
  ["keypad 6"] = {x =  10, y =   0},
  ["keypad 2"] = {x =   0, y =  10},
  ["keypad 4"] = {x = -10, y =   0},
}

function GameUI:updateKeyScroll()
  local dx, dy = 0, 0
  for key, scr in pairs(scroll_keys) do
    if self.buttons_down[key] then
      dx = dx + scr.x
      dy = dy + scr.y
    end
  end
  if dx ~= 0 or dy ~= 0 then
    self.tick_scroll_amount = {x = dx, y = dy}
    return true
  else
    self.tick_scroll_amount = false
    return false
  end
end

function GameUI:keySpeedUp()
  self.speed_up_key_pressed = true
  self.app.world:speedUp()
end

function GameUI:keyTransparent()
  self:setWallsTransparent(true)
end

function GameUI:onKeyDown(rawchar, modifiers, is_repeat)
  if UI.onKeyDown(self, rawchar, modifiers, is_repeat) then
    -- Key has been handled already
    return true
  end
  local key = rawchar:lower()
  if scroll_keys[key] then
    self:updateKeyScroll()
    return
  end
end

function GameUI:onKeyUp(rawchar)
  if UI.onKeyUp(self, rawchar) then
    return true
  end

  local key = rawchar:lower()
  if scroll_keys[key] then
    self:updateKeyScroll()
    return
  end

  -- Guess that the "Speed Up" key was released because the
  -- code parameter can't provide UTF-8 key codes:
  self.speed_up_key_pressed = false
  if self.app.world:isCurrentSpeed("Speed Up") then
    self.app.world:previousSpeed()
  end

  self:setWallsTransparent(false)
end

function GameUI:makeDebugFax()
  local message = {
    {text = "debug fax"}, -- no translation needed imo
    choices = {{text = "close debug fax", choice = "close"}},
  }
  -- Don't use "strike" type here, as these open a different window and must have an owner
  local types = {"emergency", "epidemy", "personality", "information", "disease", "report"}
  self.bottom_panel:queueMessage(types[math.random(1, #types)], message)
end

function GameUI:ScreenToWorld(x, y)
  local zoom = self.zoom_factor
  return self.app.map:ScreenToWorld(self.screen_offset_x + x / zoom, self.screen_offset_y + y / zoom)
end

function GameUI:WorldToScreen(x, y)
  local zoom = self.zoom_factor
  x, y = self.app.map:WorldToScreen(x, y)
  x = x - self.screen_offset_x
  y = y - self.screen_offset_y
  return x * zoom, y * zoom
end

function GameUI:getScreenOffset()
  return self.screen_offset_x, self.screen_offset_y
end

--! Change if the World should be tested for entities under the cursor
--!param mode (boolean or room) true to enable hit test (normal), false
--! to disable, room to enable only for non-door objects in given room
function GameUI:setWorldHitTest(mode)
  self.do_world_hit_test = mode
end

function GameUI:onCursorWorldPositionChange()
  local zoom = self.zoom_factor
  local x = math.floor(self.screen_offset_x + self.cursor_x / zoom)
  local y = math.floor(self.screen_offset_y + self.cursor_y / zoom)
  local entity = nil
  if self.do_world_hit_test and not self:hitTest(self.cursor_x, self.cursor_y) then
    entity = self.app.map.th:hitTestObjects(x, y)
    if self.do_world_hit_test ~= true then
      -- limit to non-door objects in room
      local room = self.do_world_hit_test
      entity = entity and class.is(entity, Object) and
          entity:getRoom() == room and entity ~= room.door and entity
    end
  end
  if entity ~= self.cursor_entity then
    -- Stop displaying hoverable moods for the old entity
    if self.cursor_entity then
      self.cursor_entity:setMood(nil)
    end

    -- Make the entity easily accessible when debugging, and ignore "deselecting" an entity.
    if entity then
      self.debug_cursor_entity = entity
    end

    local epidemic = self.hospital.epidemic
    local infected_cursor = TheApp.gfx:loadMainCursor("epidemic")
    local epidemic_cursor = TheApp.gfx:loadMainCursor("epidemic_hover")

    self.cursor_entity = entity
    if self.cursor ~= self.edit_room_cursor and self.cursor ~= self.waiting_cursor then
      local cursor = self.default_cursor
      if self.app.world.user_actions_allowed then
        --- If the patient is infected show the infected cursor
        if epidemic and epidemic.coverup_in_progress and
          entity and entity.infected and not epidemic.timer.closed then
          cursor = infected_cursor
          -- In vaccination mode display epidemic hover cursor for all entities
        elseif epidemic and epidemic.vaccination_mode_active then
          cursor = epidemic_cursor
          -- Otherwise just show the normal cursor and hover if appropriate
        else
          cursor = entity and entity.hover_cursor or
          (self.down_count ~= 0 and self.down_cursor or self.default_cursor)
        end
      end
      self:setCursor(cursor)
    end
    if self.bottom_panel then
      self.bottom_panel:setDynamicInfo(nil)
    end
  end

  -- Queueing icons over patients
  local wx, wy = self:ScreenToWorld(self.cursor_x, self.cursor_y)
  wx = math.floor(wx)
  wy = math.floor(wy)
  local room
  if wx > 0 and wy > 0 and wx < self.app.map.width and wy < self.app.map.height then
    room = self.app.world:getRoom(wx, wy)
  end
  if room ~= self.cursor_room then
    -- Unset queue mood for patients queueing the old room
    if self.cursor_room then
      local queue = self.cursor_room.door.queue
      if queue then
        for _, humanoid in ipairs(queue) do
          humanoid:setMood("queue", "deactivate")
        end
      end
    end
    -- Set queue mood for patients queueing the new room
    if room then
      local queue = room.door.queue
      if queue then
        for _, humanoid in ipairs(queue) do
          humanoid:setMood("queue", "activate")
        end
      end
    end
    self.cursor_room = room
  end

  -- Any hoverable mood should be displayed on the new entity
  if class.is(entity, Humanoid) then
    for _, value in pairs(entity.active_moods) do
      if value.on_hover then
        entity:setMoodInfo(value)
        break
      end
    end
  end
  -- Dynamic info
  if entity and self.bottom_panel then
    self.bottom_panel:setDynamicInfo(entity:getDynamicInfo())
  end

  return Window.onCursorWorldPositionChange(self, self.cursor_x, self.cursor_y)
end

local UpdateCursorPosition = TH.cursor.setPosition

local highlight_x, highlight_y

--! Called when the mouse enters or leaves the game window.
function GameUI:onWindowActive(gain)
  if gain == 0 then
    self.tick_scroll_amount_mouse = false
  end
end

-- TODO: try to remove duplication with UI:onMouseMove
function GameUI:onMouseMove(x, y, dx, dy)
  local repaint = UpdateCursorPosition(self.app.video, x, y)
  if self.app.moviePlayer.playing then
    return false
  end

  self.cursor_x = x
  self.cursor_y = y
  if self:onCursorWorldPositionChange() or self.simulated_cursor then
    repaint = true
  end
  if self.buttons_down.mouse_middle then
    local zoom = self.zoom_factor
    self.current_momentum.x = -dx/zoom
    self.current_momentum.y = -dy/zoom
    -- Stop zooming when the middle mouse button is pressed
    self.current_momentum.z = 0
    self:scrollMap(self.current_momentum.x, self.current_momentum.y)
    repaint = true
  end

  if self.drag_mouse_move then
    self.drag_mouse_move(x, y)
    return true
  end

  local scroll_region_size
  if self.app.config.fullscreen then
    -- As the mouse is locked within the window, a 1px region feels a lot
    -- larger than it actually is.
    scroll_region_size = 1
  else
    -- In windowed mode, a reasonable size is needed, though not too large.
    scroll_region_size = 8
  end
  if not self.app.config.prevent_edge_scrolling and
      (x < scroll_region_size or y < scroll_region_size or
       x >= self.app.config.width - scroll_region_size or
       y >= self.app.config.height - scroll_region_size) then
    local scroll_dx = 0
    local scroll_dy = 0
    local scroll_power = 7
    if x < scroll_region_size then
      scroll_dx = -scroll_power
    elseif x >= self.app.config.width - scroll_region_size then
      scroll_dx = scroll_power
    end
    if y < scroll_region_size then
      scroll_dy = -scroll_power
    elseif y >= self.app.config.height - scroll_region_size then
      scroll_dy = scroll_power
    end

    if not self.tick_scroll_amount_mouse then
      self.tick_scroll_amount_mouse = {x = scroll_dx, y = scroll_dy}
    else
      self.tick_scroll_amount_mouse.x = scroll_dx
      self.tick_scroll_amount_mouse.y = scroll_dy
    end
  else
    self.tick_scroll_amount_mouse = false
  end

  if Window.onMouseMove(self, x, y, dx, dy) then
    repaint = true
  end

  self:updateTooltip()

  local map = self.app.map
  local wx, wy = self:ScreenToWorld(x, y)
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

function GameUI:onMouseUp(code, x, y)
  if self.app.moviePlayer.playing then
    return UI.onMouseUp(self, code, x, y)
  end

  local button = self.button_codes[code]
  if button == "right" and not self.map_editor and highlight_x then
    local window = self:getWindow(UIPatient)
    local patient = (window and window.patient.is_debug and window.patient) or self.hospital:getDebugPatient()
    if patient then
      patient:walkTo(highlight_x, highlight_y)
      patient:queueAction(IdleAction())
    end
  end

  if self.edit_room then
    if class.is(self.edit_room, Room) then
      if button == "right" and self.cursor == self.waiting_cursor then
        -- Still waiting for people to leave the room, abort editing it.
        self:setEditRoom(false)
      end
    else -- No room chosen yet, but about to edit one.
      if button == "left" then -- Take the clicked one.
        local room = self.app.world:getRoom(self:ScreenToWorld(x, y))
        if room and not room.crashed then
          self:setCursor(self.waiting_cursor)
          self.edit_room = room
          room:tryToEdit()
        end
      else -- right click, we don't want to edit a room after all.
        self:setEditRoom(false)
      end
    end
  end

  -- During vaccination mode you can only interact with infected patients
  local epidemic = self.hospital.epidemic
  if epidemic and epidemic.vaccination_mode_active then
    if button == "left" then
      if self.cursor_entity then
        -- Allow click behaviour for infected patients
        if self.cursor_entity.infected then
          self.cursor_entity:onClick(self,button)
        end
      end
    elseif button == "right" then
      --Right click turns vaccination mode off
      local watch = TheApp.ui:getWindow(UIWatch)
      watch:toggleVaccinationMode()
    end
  end

  return UI.onMouseUp(self, code, x, y)
end

function GameUI:onMouseWheel(x, y)
  local inside_window = false
  if self.windows then
    for _, window in ipairs(self.windows) do
      if window:hitTest(self.cursor_x - window.x, self.cursor_y - window.y) then
        inside_window = true
        break
      end
    end
  end
  if not inside_window then
    -- Apply momentum to the zoom
    if math.abs(self.current_momentum.z) < 12 then
      self.current_momentum.z = self.current_momentum.z + y
    end
  end
  return UI.onMouseWheel(self, x, y)
end

function GameUI:setRandomAnnouncementTarget()
  -- NB: Every tick is 30ms, so 2000 ticks is 1 minute
  self.random_announcement_ticks_target = math.random(8000, 12000)
end

function GameUI:playAnnouncement(name, played_callback, played_callback_delay)
  self.ticks_since_last_announcement = 0
  if self.app.world:getLocalPlayerHospital():hasStaffedDesk() then
    UI.playAnnouncement(self, name, played_callback, played_callback_delay)
  end
end

function GameUI:onTick()
  local repaint = UI.onTick(self)
  if not self.buttons_down.mouse_middle then
    if math.abs(self.current_momentum.x) < 0.2 and math.abs(self.current_momentum.y) < 0.2 then
      -- Stop scrolling
      self.current_momentum.x = 0.0
      self.current_momentum.y = 0.0
    else
      self.current_momentum.x = self.current_momentum.x * self.momentum
      self.current_momentum.y = self.current_momentum.y * self.momentum
      self:scrollMap(self.current_momentum.x, self.current_momentum.y)
    end
    if math.abs(self.current_momentum.z) < 0.2 then
      self.current_momentum.z = 0.0
    else
      self.current_momentum.z = self.current_momentum.z * self.momentum
      self.app.world:adjustZoom(self.current_momentum.z)
    end
  end
  if not self.app.world:isCurrentSpeed("Pause") then
    local ticks_since_last_announcement = self.ticks_since_last_announcement
    if ticks_since_last_announcement >= self.random_announcement_ticks_target then
      self:playAnnouncement("rand*.wav")
      self:setRandomAnnouncementTarget()
    else
      self.ticks_since_last_announcement = ticks_since_last_announcement + 1
    end
  end
  if self.tick_scroll_amount or self.tick_scroll_amount_mouse then
    -- The scroll amount per tick gradually increases as the duration of the
    -- scroll increases due to this multiplier.
    local mult = self.tick_scroll_mult
    mult = mult + 0.02
    if mult > 2 then
      mult = 2
    end
    self.tick_scroll_mult = mult

    -- Combine the mouse scroll and keyboard scroll
    local dx, dy = 0, 0
    if self.tick_scroll_amount_mouse then
      dx, dy = self.tick_scroll_amount_mouse.x, self.tick_scroll_amount_mouse.y
      -- If the middle mouse button is down, then the world is being dragged,
      -- and so the scroll direction due to the cursor being at the map edge
      -- should be opposite to normal to make it feel more natural.
      if self.buttons_down.mouse_middle then
        dx, dy = -dx, -dy
      end
    end
    if self.tick_scroll_amount then
      dx = dx + self.tick_scroll_amount.x
      dy = dy + self.tick_scroll_amount.y
    end

    -- Adjust scroll speed based on config value:
    -- there is a separate config value for whether or not shift is held.
    -- the speed is multiplied by 0.5 for consistency between the old and
    -- new configuration. In the past scroll_speed applied only to shift
    -- and defaulted to 2, where 1 was regular scroll speed. By
    -- By multiplying by 0.5, we allow for setting slower than normal
    -- scroll speeds, and ensure there is no behaviour change for players
    -- who do not modify their config file.
    if self.app.key_modifiers.shift then
      mult = mult * self.app.config.shift_scroll_speed * 0.5
    else
      mult = mult * self.app.config.scroll_speed * 0.5
    end

    self:scrollMap(dx * mult, dy * mult)
    repaint = true
  else
    self.tick_scroll_mult = 1
  end
  if self:onCursorWorldPositionChange() then
    repaint = true
  end
  return repaint
end

local abs, sqrt_5, floor = math.abs, math.sqrt(1 / 5), math.floor

function GameUI:scrollMapTo(x, y)
  local zoom = 2 * self.zoom_factor
  local config = self.app.config
  return self:scrollMap(x - self.screen_offset_x - config.width / zoom,
                        y - self.screen_offset_y - config.height / zoom)
end

function GameUI.limitPointToDiamond(dx, dy, visible_diamond, do_limit)
  -- If point outside visible diamond, then move point to the nearest position
  -- on the edge of the diamond (NB: relies on diamond.w == 2 * diamond.h).
  local rx = dx - visible_diamond.x
  local ry = dy - visible_diamond.y
  if abs(rx) + abs(ry) * 2 > visible_diamond.w then
    if do_limit then
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
      -- In the unit vector parallel to the diamond edge, resolve the two vertices and
      -- the point, and either move the point to the edge or to one of the two vertices.
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
      return math.floor(dx), math.floor(dy), true
    else
      return dx, dy, false
    end
  end
  return dx, dy, true
end

function GameUI:scrollMap(dx, dy)
  dx = dx + self.screen_offset_x
  dy = dy + self.screen_offset_y

  dx, dy, self.in_visible_diamond = self.limitPointToDiamond(dx, dy,
    self.visible_diamond, self.limit_to_visible_diamond)

  self.screen_offset_x = floor(dx + 0.5)
  self.screen_offset_y = floor(dy + 0.5)
end

--! Start shaking the screen, e.g. an earthquake effect
--!param intensity (number) The magnitude of the effect, between 0 for no
-- movement to 1 for significant shaking.
function GameUI:beginShakeScreen(intensity)
  self.shake_screen_intensity = intensity
end

--! Stop the screen from shaking after beginShakeScreen is called.
function GameUI:endShakeScreen()
  self.shake_screen_intensity = 0
end

function GameUI:limitCamera(mode)
  self.limit_to_visible_diamond = mode
  self:scrollMap(0, 0)
end

--! Applies the current setting for wall transparency to the map
function GameUI:applyTransparency()
  self.app.map.th:setWallDrawFlags(self.transparent_walls and 4 or 0)
end

--! Sets wall transparency to the specified parameter
--!param mode (boolean) whether to enable or disable wall transparency
function GameUI:setWallsTransparent(mode)
  if mode ~= self.transparent_walls then
    self.transparent_walls = mode
    self:applyTransparency()
  end
end

function UI:toggleAdviser()
  self.app.config.adviser_disabled = not self.app.config.adviser_disabled
  self.app:saveConfig()
end

function UI:togglePlaySounds()
  self.app.config.play_sounds = not self.app.config.play_sounds
  self.app.audio:playSoundEffects(self.app.config.play_sounds)
  self.app:saveConfig()
end

function UI:togglePlayAnnouncements()
  self.app.config.play_announcements = not self.app.config.play_announcements
  self.app:saveConfig()
end

function UI:togglePlayMusic(item)
  if not self.app.audio.background_music then
    self.app.config.play_music = true
    self.app.audio:playRandomBackgroundTrack() -- play
  else
    self.app.config.play_music = false
    self.app.audio:stopBackgroundTrack() -- stop
  end
 -- self.app.config.play_music = not self.app.config.play_music
  self.app:saveConfig()
end

local tutorial_phases
local function make_tutorial_phases()
tutorial_phases = {
  {
    -- 1) build reception
    { text = _A.tutorial.build_reception,              -- 1
      begin_callback = function() TheApp.ui:getWindow(UIBottomPanel):startButtonBlinking(3) end,
      end_callback = function() TheApp.ui:getWindow(UIBottomPanel):stopButtonBlinking() end, },
    { text = _A.tutorial.order_one_reception,          -- 2
      begin_callback = function() TheApp.ui:getWindow(UIFurnishCorridor):startButtonBlinking(3) end,
      end_callback = function() TheApp.ui:getWindow(UIFurnishCorridor):stopButtonBlinking(3) end, },
    { text = _A.tutorial.accept_purchase,              -- 3
      begin_callback = function() TheApp.ui:getWindow(UIFurnishCorridor):startButtonBlinking(2) end,
      end_callback = function() TheApp.ui:getWindow(UIFurnishCorridor):stopButtonBlinking(2) end, },
    _A.tutorial.rotate_and_place_reception,            -- 4
    _A.tutorial.reception_invalid_position,            -- 5
                                                       -- 6: object other than reception selected. currently no text for this phase.
  },

  {
    -- 2) hire receptionist
    { text = _A.tutorial.hire_receptionist,            -- 1
      begin_callback = function() TheApp.ui:getWindow(UIBottomPanel):startButtonBlinking(5) end,
      end_callback = function() TheApp.ui:getWindow(UIBottomPanel):stopButtonBlinking() end, },
    { text = _A.tutorial.select_receptionists,         -- 2
      begin_callback = function() TheApp.ui:getWindow(UIHireStaff):startButtonBlinking(4) end,
      end_callback = function() TheApp.ui:getWindow(UIHireStaff):stopButtonBlinking() end, },
    { text = _A.tutorial.next_receptionist,            -- 3
      begin_callback = function() TheApp.ui:getWindow(UIHireStaff):startButtonBlinking(8) end,
      end_callback = function() TheApp.ui:getWindow(UIHireStaff):stopButtonBlinking() end, },
    { text = _A.tutorial.prev_receptionist,            -- 4
      begin_callback = function() TheApp.ui:getWindow(UIHireStaff):startButtonBlinking(5) end,
      end_callback = function() TheApp.ui:getWindow(UIHireStaff):stopButtonBlinking() end, },
    { text = _A.tutorial.choose_receptionist,          -- 5
      begin_callback = function() TheApp.ui:getWindow(UIHireStaff):startButtonBlinking(6) end,
      end_callback = function() TheApp.ui:getWindow(UIHireStaff):stopButtonBlinking() end, },
    _A.tutorial.place_receptionist,                    -- 6
    _A.tutorial.receptionist_invalid_position,         -- 7
  },

  {
    -- 3) build GP's office
    -- 3.1) room window
    { text = _A.tutorial.build_gps_office,             -- 1
      begin_callback = function() TheApp.ui:getWindow(UIBottomPanel):startButtonBlinking(2) end,
      end_callback = function() TheApp.ui:getWindow(UIBottomPanel):stopButtonBlinking() end, },
    { text = _A.tutorial.select_diagnosis_rooms,       -- 2
      begin_callback = function() TheApp.ui:getWindow(UIBuildRoom):startButtonBlinking(1) end,
      end_callback = function() TheApp.ui:getWindow(UIBuildRoom):stopButtonBlinking() end, },
    { text = _A.tutorial.click_gps_office,             -- 3
      begin_callback = function() TheApp.ui:getWindow(UIBuildRoom):startButtonBlinking(5) end,
      end_callback = function() TheApp.ui:getWindow(UIBuildRoom):stopButtonBlinking() end, },

    -- 3.2) blueprint
    -- [11][58] was maybe planned to be used in this place, but is not needed.
    _A.tutorial.click_and_drag_to_build,               -- 4
    _A.tutorial.room_in_invalid_position,              -- 5
    _A.tutorial.room_too_small,                        -- 6
    _A.tutorial.room_too_small_and_invalid,            -- 7
    { text = _A.tutorial.room_big_enough,              -- 8
      begin_callback = function() TheApp.ui:getWindow(UIEditRoom):startButtonBlinking(4) end,
      end_callback = function() TheApp.ui:getWindow(UIEditRoom):stopButtonBlinking() end, },

    -- 3.3) door and windows
    _A.tutorial.place_door,                            -- 9
    _A.tutorial.door_in_invalid_position,              -- 10
    { text = _A.tutorial.place_windows,                -- 11
      begin_callback = function() TheApp.ui:getWindow(UIEditRoom):startButtonBlinking(4) end,
      end_callback = function() TheApp.ui:getWindow(UIEditRoom):stopButtonBlinking() end, },
    { text = _A.tutorial.window_in_invalid_position,   -- 12
      begin_callback = function() TheApp.ui:getWindow(UIEditRoom):startButtonBlinking(4) end,
      end_callback = function() TheApp.ui:getWindow(UIEditRoom):stopButtonBlinking() end, },

    -- 3.4) objects
    _A.tutorial.place_objects,                         -- 13
    _A.tutorial.object_in_invalid_position,            -- 14
    { text = _A.tutorial.confirm_room,                 -- 15
      begin_callback = function() TheApp.ui:getWindow(UIEditRoom):startButtonBlinking(4) end,
      end_callback = function() TheApp.ui:getWindow(UIEditRoom):stopButtonBlinking() end, },
    { text = _A.tutorial.information_window,           -- 16
      begin_callback = function() TheApp.ui:getWindow(UIInformation):startButtonBlinking(1) end,
      end_callback = function() TheApp.ui:getWindow(UIInformation):stopButtonBlinking() end, },
  },

  {
    -- 4) hire doctor
    { text = _A.tutorial.hire_doctor,                  -- 1
      begin_callback = function() TheApp.ui:getWindow(UIBottomPanel):startButtonBlinking(5) end,
      end_callback = function() TheApp.ui:getWindow(UIBottomPanel):stopButtonBlinking() end, },
    { text = _A.tutorial.select_doctors,               -- 2
      begin_callback = function() TheApp.ui:getWindow(UIHireStaff):startButtonBlinking(1) end,
      end_callback = function() TheApp.ui:getWindow(UIHireStaff):stopButtonBlinking() end, },
    { text = _A.tutorial.choose_doctor,                -- 3
      begin_callback = function() TheApp.ui:getWindow(UIHireStaff):startButtonBlinking(6) end,
      end_callback = function() TheApp.ui:getWindow(UIHireStaff):stopButtonBlinking() end, },
    _A.tutorial.place_doctor,                          -- 4
    _A.tutorial.doctor_in_invalid_position,            -- 5
  },
  {
    -- 5) end of tutorial
    { begin_callback = function()
        -- The demo uses a single string for the post-tutorial info while
        -- the real game uses three.
        local texts = TheApp.using_demo_files and {
          {_S.introduction_texts["level15"]},
          {_S.introduction_texts["demo"]},
        } or {
          {_S.introduction_texts["level15"]},
          {_S.introduction_texts["level16"]},
          {_S.introduction_texts["level17"]},
          {_S.introduction_texts["level1"]},
        }
        TheApp.ui:addWindow(UIInformation(TheApp.ui, texts))
        TheApp.ui:addWindow(UIWatch(TheApp.ui, "initial_opening"))
      end,
    },
  },
}
end
tutorial_phases = setmetatable({}, {__index = function(t, k)
  make_tutorial_phases()
  return tutorial_phases[k]
end})

-- Called to trigger step to another part of the tutorial.
-- chapter:    Individual parts of the tutorial. Step will only happen if it's the current chapter.
-- phase_from: Phase we need to be in for this step to happen. Multiple phases can be given here in an array.
-- phase_to:   Phase we want to step to or "next" to go to next chapter or "end" to end tutorial.
-- returns true if we changed phase, false if we didn't
function GameUI:tutorialStep(chapter, phase_from, phase_to, ...)
  if self.tutorial.chapter ~= chapter then
    return false
  end
  if type(phase_from) == "table" then
    local contains_current = false
    for _, phase in ipairs(phase_from) do
      if phase == self.tutorial.phase then
        contains_current = true
        break
      end
    end
    if not contains_current then return false end
  else
    if self.tutorial.phase ~= phase_from then return false end
  end

  local old_phase = tutorial_phases[self.tutorial.chapter][self.tutorial.phase]
  if old_phase and old_phase.end_callback and type(old_phase.end_callback) == "function" then
    old_phase.end_callback(...)
  end

  if phase_to == "end" then
    self.tutorial.chapter = 0
    self.tutorial.phase = 0
    return true
  elseif phase_to == "next" then
    self.tutorial.chapter = self.tutorial.chapter + 1
    self.tutorial.phase = 1
  else
    self.tutorial.phase = phase_to
  end

  if TheApp.config.debug then print("Tutorial: Now in " .. self.tutorial.chapter .. ", " .. self.tutorial.phase) end
  local new_phase = tutorial_phases[self.tutorial.chapter][self.tutorial.phase]
  local str, callback
  if (type(new_phase) == "table" and type(new_phase.text) == "table") or not new_phase.text then
    str = new_phase.text
    callback = new_phase.begin_callback
  else
    str = new_phase
  end
  if str and str.text then
    self.adviser:say(str, true, true)
  else
    self.adviser.stay_up = nil
  end
  if callback then
    callback(...)
  end
  return true
end

function GameUI:startTutorial(chapter)
  chapter = chapter or 1
  self.tutorial.chapter = chapter
  self.tutorial.phase = 0

  self:tutorialStep(chapter, 0, 1)
end

function GameUI:setEditRoom(enabled)
  -- TODO: Make the room the cursor is over flash
  if enabled then
    self:setCursor(self.edit_room_cursor)
    self.edit_room = true
  else
    -- If the actual editing hasn't started yet but is on its way,
    -- activate the room again.
    if class.is(self.edit_room, Room) and self.cursor == self.waiting_cursor then
      self.edit_room.is_active = true
    else
      -- If we are currently editing a room it may happen that we need to abort it.
      -- Also remove any dialog where the user is buying items.
      local item_window = self.app.ui:getWindow(UIFurnishCorridor)
      if item_window and item_window.edit_dialog then
        item_window:close()
      end
      local edit_window = self.app.ui:getWindow(UIEditRoom)
      if edit_window then
        edit_window:verifyOrAbortRoom()
      end
    end
    self:setCursor(self.default_cursor)
    self.edit_room = false
  end
end

function GameUI:afterLoad(old, new)
  if old < 16 then
    self.zoom_factor = 1
  end
  if old < 23 then
    self.do_world_hit_test = not self:getWindow(UIPlaceObjects)
  end
  if old < 28 then
    self:setRandomAnnouncementTarget()
    self.ticks_since_last_announcement = 0
  end
  if old < 34 then
    self.adviser.queued_messages = {}
    self.adviser.phase = 0
    self.adviser.timer = nil
    self.adviser.frame = 1
    self.adviser.number_frames = 4
  end
  if old < 70 then
    self:addKeyHandler({"shift", "a"}, self, self.toggleAdviser)
  end
  if old < 75 then
    self.current_momentum = { x = 0, y = 0 }
    self.momentum = self.app.config.scrolling_momentum
  end
  if old < 78 then
    self.current_momentum = { x = 0, y = 0, z = 0}
  end
  if old < 81 then
    self:removeKeyHandler("x", self, self.toggleWallsTransparent)
    self:addKeyHandler("z", self, self.keySpeedUp)
    self:addKeyHandler("x", self, self.keyTransparent)
  end
  if old < 115 then
    self.shake_screen_intensity = 0
  end
  return UI.afterLoad(self, old, new)
end

function GameUI:showBriefing()
  local level = self.app.world.map.level_number
  local text = {_S.information.custom_game}
  if type(level) == "number" then
    text = {_S.introduction_texts[TheApp.using_demo_files and "demo" or "level" .. level]}
  elseif self.app.world.map.level_intro then
    text = {self.app.world.map.level_intro}
  end
  self:addWindow(UIInformation(self, text))
end

--! Offers a confirmation window to quit the game and return to main menu
-- NB: overrides UI.quit, do NOT call it from here
function GameUI:quit()
  self:addWindow(UIConfirmDialog(self, _S.confirmation.quit, --[[persistable:gameui_confirm_quit]] function()
    self.app:loadMainMenu()
  end))
end

function GameUI:showCheatsWindow()
  self:addWindow(UICheats(self))
end

function GameUI:showMenuBar()
  self.menu_bar:appear()
end
