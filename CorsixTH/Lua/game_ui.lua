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

--! Variant of UI for running games
class "GameUI" (UI)

local TH = require "TH"
local WM = require "sdl".wm
local SDL = require "sdl"
local lfs = require "lfs"
local pathsep = package.config:sub(1, 1)

function GameUI:GameUI(app, local_hospital)
  self:UI(app)

  self.hospital = local_hospital
  self.tutorial = { chapter = 0, phase = 0 }
  
  if _MAP_EDITOR then
    self:addWindow(UIMapEditor(self))
  else
    self.adviser = UIAdviser(self)
    self.bottom_panel = UIBottomPanel(self)
    self.menu_bar = UIMenuBar(self)
    self.bottom_panel:addWindow(self.adviser)
    self:addWindow(self.bottom_panel)
    self:addWindow(self.menu_bar)
  end

  local scr_w = app.config.width
  local scr_h = app.config.height
  self.visible_diamond = self.makeVisibleDiamond(scr_w, scr_h)
  if self.visible_diamond.w <= 0 or self.visible_diamond.h <= 0 then
    -- For a standard 128x128 map, screen size would have to be in the
    -- region of 3276x2457 in order to be too large.
    error "Screen size too large for the map"
  end
  self.screen_offset_x, self.screen_offset_y = app.map:WorldToScreen(
    app.map.th:getCameraTile(local_hospital:getPlayerIndex()))
  self:scrollMap(-scr_w / 2, 16 - scr_h / 2)
  self.limit_to_visible_diamond = not _MAP_EDITOR
  self.transparent_walls = false
  self.prevent_edge_scrolling = false
end

function GameUI:draw(canvas)
  local app = self.app
  local config = app.config
  if not self.in_visible_diamond then
    canvas:fillBlack()
  end
  app.map:draw(canvas, self.screen_offset_x, self.screen_offset_y, config.width, config.height, 0, 0)
  Window.draw(self, canvas, 0, 0) -- NB: not calling UI.draw on purpose
  self:drawTooltip(canvas)
  if self.simulated_cursor then
    self.simulated_cursor.draw(canvas, self.cursor_x, self.cursor_y)
  end
end

function GameUI:onChangeResolution()
  -- Recalculate scrolling bounds
  local scr_w = self.app.config.width
  local scr_h = self.app.config.height
  self.visible_diamond = self.makeVisibleDiamond(scr_w, scr_h)
  self:scrollMap(0, 0)
  
  UI.onChangeResolution(self)
end

local scroll_keys = {
  up    = {x =   0, y = -10},
  right = {x =  10, y =   0},
  down  = {x =   0, y =  10},
  left  = {x = -10, y =   0},
}

function GameUI:onKeyDown(code)
  if UI.onKeyDown(self, code) then
    return true
  end
  
  local key = self.key_codes[code]
  if not key then
    return
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
  if TheApp.config.debug then -- Debug commands
    if key == "F8" then -- Open an alert window
      -- Don't use "strike" type here, as these open a different window and must have an owner
      local types = {"emergency", "epidemy", "personnality", "information", "disease", "report"}
      self.bottom_panel:queueMessage(types[math.random(1, #types)])
    elseif key == "F9" then -- Make debug patient
      self.app.world:makeDebugPatient()
    
    elseif key == "F11" then -- Make Adviser say a random phrase
      self:debugMakeAdviserTalk()
    elseif key == "F12" then -- Show watch
      self:addWindow(UIWatch(self))
    elseif key == "X" then -- Toggle wall transparency
      self:makeWallsTransparent(not self.transparent_walls)
    elseif key == "D" and self.buttons_down.ctrl then
      self.app.world:dumpGameLog()
    end
  end
end

function GameUI:onKeyUp(code)
  if UI.onKeyUp(self, code) then
    return true
  end

  local key = self.key_codes[code]
  if not key then
    return
  end
  if scroll_keys[key] then
    local dx, dy = -scroll_keys[key].x, -scroll_keys[key].y
    if self.tick_scroll_amount then
      dx = dx + self.tick_scroll_amount.x
      dy = dy + self.tick_scroll_amount.y
    else
      -- NB: No current scroll (perhaps due to opposing keyboard buttons being
      -- pressed prior), and dx ~= 0 or dy ~= 0, so we need a table ready for
      -- the second branch of the next if.
      self.tick_scroll_amount = {}
    end
    if dx == 0 and dy == 0 then
      self.tick_scroll_amount = false
    else
      self.tick_scroll_amount.x = dx
      self.tick_scroll_amount.y = dy
    end
    return
  end
end

function GameUI:ScreenToWorld(x, y)
  return self.app.map:ScreenToWorld(self.screen_offset_x + x, self.screen_offset_y + y)
end

function GameUI:WorldToScreen(x, y)
  x, y = self.app.map:WorldToScreen(x, y)
  x = x - self.screen_offset_x
  y = y - self.screen_offset_y
  return x, y
end

function GameUI:getScreenOffset()
  return self.screen_offset_x, self.screen_offset_y
end

function GameUI:onCursorWorldPositionChange()
  local x = self.screen_offset_x + self.cursor_x
  local y = self.screen_offset_y + self.cursor_y
  local entity = nil
  if not self:hitTest(self.cursor_x, self.cursor_y) then
    entity = self.app.map.th:hitTestObjects(x, y)
  end
  if entity ~= self.cursor_entity then
    -- Stop displaying hoverable moods for the old entity
    if self.cursor_entity then
      self.cursor_entity:setMood(nil)
    end
    self.cursor_entity = entity
    if self.cursor ~= self.edit_room_cursor and self.cursor ~= self.waiting_cursor then
      local cursor = entity and entity.hover_cursor or
        (self.down_count ~= 0 and self.down_cursor or self.default_cursor)
      self:setCursor(cursor)
    end
    self.bottom_panel:setDynamicInfo(nil)
  end

  -- Queueing icons over patients
  local wx, wy = self:ScreenToWorld(self.cursor_x, self.cursor_y)
  wx = math.floor(wx)
  wy = math.floor(wy)
  local room
  if wx > 0 and wx > 0 and wx < self.app.map.width and wy < self.app.map.height then
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
    for key, value in pairs(entity.active_moods) do
      if value.on_hover then
        entity:setMoodInfo(value)
        break
      end
    end
  end
  -- Dynamic info
  if entity then
    self.bottom_panel:setDynamicInfo(entity:getDynamicInfo())
  end
end

local UpdateCursorPosition = TH.cursor.setPosition

local highlight_x, highlight_y

-- TODO: try to remove duplication with UI:onMouseMove
function GameUI:onMouseMove(x, y, dx, dy)
  local repaint = UpdateCursorPosition(self.app.video, x, y)
  
  self.cursor_x = x
  self.cursor_y = y
  if self:onCursorWorldPositionChange() or self.simulated_cursor then
    repaint = true
  end
  if self.buttons_down.middle then
    self:scrollMap(-dx, -dy)
    repaint = true
  end
  
  if self.drag_mouse_move then
    self.drag_mouse_move(x, y)
    return true
  end
  
  if not self.prevent_edge_scrolling and (x < 3 or y < 3
  or x >= self.app.config.width - 3 or y >= self.app.config.height - 3) then
    local dx = 0
    local dy = 0
    if x < 3 then
      dx = -10
    elseif x >= self.app.config.width - 3 then
      dx = 10
    end
    if y < 3 then
      dy = -10
    elseif y >= self.app.config.height - 3 then
      dy = 10
    end
    
    if not self.tick_scroll_amount_mouse then
      self.tick_scroll_amount_mouse = {x = dx, y = dy}
    else
      self.tick_scroll_amount_mouse.x = dx
      self.tick_scroll_amount_mouse.y = dy
    end
  else
    self.tick_scroll_amount_mouse = false
  end
  
  if Window.onMouseMove(self, x, y, dx, dy) then
    repaint = true
  end
  
  self:updateTooltip()
  
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

function GameUI:onMouseUp(code, x, y)
  local button = self.button_codes[code]
  if button == "right" and not _MAP_EDITOR and highlight_x then
    local window = self:getWindow(UIPatient)
    local patient = (window and window.patient.is_debug and window.patient) or self.hospital:getDebugPatient()
    if patient then
      patient:walkTo(highlight_x, highlight_y)
      patient:queueAction{name = "idle"}
    end
  end
  
  if self.edit_room then
    if button == "left" then
      local room = self.app.world:getRoom(self:ScreenToWorld(x, y))
      if room and not room.crashed then
        room.is_active = false -- So that no more patients go to it.
        self:setCursor(self.waiting_cursor)
        room:tryToEdit()
        self.edit_room = false
      end
    else
      self:setCursor(self.default_cursor)
      self.edit_room = false
    end
  end
  
  return UI.onMouseUp(self, code, x, y)
end

function GameUI:onTick()
  local repaint = UI.onTick(self)
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
      if self.buttons_down.middle then
        dx, dy = -dx, -dy
      end
    end
    if self.tick_scroll_amount then
      dx = dx + self.tick_scroll_amount.x
      dy = dy + self.tick_scroll_amount.y
    end
    
    -- Faster scrolling with shift key
    if self.buttons_down.shift then
      mult = mult * 2
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
  return self:scrollMap(x - self.screen_offset_x - self.app.config.width / 2,
                        y - self.screen_offset_y - self.app.config.height / 2)
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

function GameUI:limitCamera(mode)
  self.limit_to_visible_diamond = mode
  self:scrollMap(0, 0)
end

function GameUI:makeWallsTransparent(mode)
  self.transparent_walls = mode
  self.app.map.th:setWallDrawFlags(mode and 4 or 0)
end

local tutorial_phases = {
  {
    -- 1) build reception
    { text = _S.adviser.tutorial.build_reception,      -- 1
      begin_callback = function() TheApp.ui:getWindow(UIBottomPanel):startButtonBlinking(3) end,
      end_callback = function() TheApp.ui:getWindow(UIBottomPanel):stopButtonBlinking() end, },
    { text = _S.adviser.tutorial.order_one_reception,  -- 2
      begin_callback = function() TheApp.ui:getWindow(UIFurnishCorridor):startButtonBlinking(3) end,
      end_callback = function() TheApp.ui:getWindow(UIFurnishCorridor):stopButtonBlinking(3) end, },
    { text = _S.adviser.tutorial.accept_purchase,      -- 3
      begin_callback = function() TheApp.ui:getWindow(UIFurnishCorridor):startButtonBlinking(2) end,
      end_callback = function() TheApp.ui:getWindow(UIFurnishCorridor):stopButtonBlinking(2) end, },
    _S.adviser.tutorial.rotate_and_place_reception,    -- 4
    _S.adviser.tutorial.reception_invalid_position,    -- 5
                                                       -- 6: object other than reception selected. currently no text for this phase.
  },
  
  {
    -- 2) hire receptionist
    { text = _S.adviser.tutorial.hire_receptionist,             -- 1
      begin_callback = function() TheApp.ui:getWindow(UIBottomPanel):startButtonBlinking(5) end,
      end_callback = function() TheApp.ui:getWindow(UIBottomPanel):stopButtonBlinking() end, },
    { text = _S.adviser.tutorial.select_receptionists,          -- 2
      begin_callback = function() TheApp.ui:getWindow(UIHireStaff):startButtonBlinking(4) end,
      end_callback = function() TheApp.ui:getWindow(UIHireStaff):stopButtonBlinking() end, },
    { text = _S.adviser.tutorial.next_receptionist,             -- 3
      begin_callback = function() TheApp.ui:getWindow(UIHireStaff):startButtonBlinking(8) end,
      end_callback = function() TheApp.ui:getWindow(UIHireStaff):stopButtonBlinking() end, },
    { text = _S.adviser.tutorial.prev_receptionist,             -- 4
      begin_callback = function() TheApp.ui:getWindow(UIHireStaff):startButtonBlinking(5) end,
      end_callback = function() TheApp.ui:getWindow(UIHireStaff):stopButtonBlinking() end, },
    { text = _S.adviser.tutorial.choose_receptionist,           -- 5
      begin_callback = function() TheApp.ui:getWindow(UIHireStaff):startButtonBlinking(6) end,
      end_callback = function() TheApp.ui:getWindow(UIHireStaff):stopButtonBlinking() end, },
    _S.adviser.tutorial.place_receptionist,            -- 6
    _S.adviser.tutorial.receptionist_invalid_position, -- 7
  },
  
  {
    -- 3) build GP's office
    -- 3.1) room window
    { text = _S.adviser.tutorial.build_gps_office,              -- 1
      begin_callback = function() TheApp.ui:getWindow(UIBottomPanel):startButtonBlinking(2) end,
      end_callback = function() TheApp.ui:getWindow(UIBottomPanel):stopButtonBlinking() end, },
    { text = _S.adviser.tutorial.select_diagnosis_rooms,        -- 2
      begin_callback = function() TheApp.ui:getWindow(UIBuildRoom):startButtonBlinking(1) end,
      end_callback = function() TheApp.ui:getWindow(UIBuildRoom):stopButtonBlinking() end, },
    { text = _S.adviser.tutorial.click_gps_office,              -- 3
      begin_callback = function() TheApp.ui:getWindow(UIBuildRoom):startButtonBlinking(5) end,
      end_callback = function() TheApp.ui:getWindow(UIBuildRoom):stopButtonBlinking() end, },
    
    -- 3.2) blueprint
    -- [11][58] was maybe planned to be used in this place, but is not needed.
    _S.adviser.tutorial.click_and_drag_to_build,       -- 4
    _S.adviser.tutorial.room_in_invalid_position,      -- 5
    _S.adviser.tutorial.room_too_small,                -- 6
    _S.adviser.tutorial.room_too_small_and_invalid,    -- 7
    { text = _S.adviser.tutorial.room_big_enough,               -- 8
      begin_callback = function() TheApp.ui:getWindow(UIEditRoom):startButtonBlinking(4) end,
      end_callback = function() TheApp.ui:getWindow(UIEditRoom):stopButtonBlinking() end, },
    
    -- 3.3) door and windows
    _S.adviser.tutorial.place_door,                    -- 9
    _S.adviser.tutorial.door_in_invalid_position,      -- 10
    { text = _S.adviser.tutorial.place_windows,                 -- 11
      begin_callback = function() TheApp.ui:getWindow(UIEditRoom):startButtonBlinking(4) end,
      end_callback = function() TheApp.ui:getWindow(UIEditRoom):stopButtonBlinking() end, },
    { text = _S.adviser.tutorial.window_in_invalid_position,    -- 12
      begin_callback = function() TheApp.ui:getWindow(UIEditRoom):startButtonBlinking(4) end,
      end_callback = function() TheApp.ui:getWindow(UIEditRoom):stopButtonBlinking() end, },
    
    -- 3.4) objects
    _S.adviser.tutorial.place_objects,                 -- 13
    _S.adviser.tutorial.object_in_invalid_position,    -- 14
    { text = _S.adviser.tutorial.confirm_room,                  -- 15
      begin_callback = function() TheApp.ui:getWindow(UIEditRoom):startButtonBlinking(4) end,
      end_callback = function() TheApp.ui:getWindow(UIEditRoom):stopButtonBlinking() end, },
  },
  
  {
    -- 4) hire doctor
    { text = _S.adviser.tutorial.hire_doctor,                   -- 1
      begin_callback = function() TheApp.ui:getWindow(UIBottomPanel):startButtonBlinking(5) end,
      end_callback = function() TheApp.ui:getWindow(UIBottomPanel):stopButtonBlinking() end, },
    { text = _S.adviser.tutorial.select_doctors,                -- 2
      begin_callback = function() TheApp.ui:getWindow(UIHireStaff):startButtonBlinking(1) end,
      end_callback = function() TheApp.ui:getWindow(UIHireStaff):stopButtonBlinking() end, },
    { text = _S.adviser.tutorial.choose_doctor,                 -- 3
      begin_callback = function() TheApp.ui:getWindow(UIHireStaff):startButtonBlinking(6) end,
      end_callback = function() TheApp.ui:getWindow(UIHireStaff):stopButtonBlinking() end, },
    _S.adviser.tutorial.place_doctor,                  -- 4
    _S.adviser.tutorial.doctor_in_invalid_position,    -- 5
  },
  -- apparently unused tutorial strings:
  -- [11][63]
  -- [11][64]
  -- original TH continues here with three boxes displaying some more text:
  -- [54][94] to [54][96]
  -- [54][97] to [54][99]
  -- [54][101] to [54][103]
  {
    _S.adviser.tutorial.build_pharmacy,
  },
}

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
  if old_phase and old_phase.end_callback then
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
  local str
  local callback
  if type(new_phase) == "table" then
    str = new_phase.text
    callback = new_phase.begin_callback
  else
    str = new_phase
  end
    
  if str then
    self.adviser:say(str)
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
    self:setCursor(self.default_cursor)
    self.edit_room = false
  end
end

function GameUI:showBriefing()
  local level = self.app.world.map.level_number
  local text = type(level) == "number" and _S.introduction_texts["level" .. level] or {_S.information.custom_game}
  self:addWindow(UIInformation(self, text))
end
