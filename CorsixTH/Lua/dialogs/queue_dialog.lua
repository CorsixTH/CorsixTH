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

local TH = require "TH"
local math_floor
    = math.floor

--! Room / door / reception desk queue visualisation dialog.
class "UIQueue" (Window)

function UIQueue:UIQueue(ui, queue)
  self:Window()
  
  local app = ui.app
  self.esc_closes = true
  self.ui = ui
  self.modal_class = "main"
  self.width = 604
  self.height = 122
  self:setDefaultPosition(0.5, 0.5)
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req06V", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  
  self.queue = queue
  
  self:addPanel(364,  0,  0) -- Right extremity of the panel
  for x = 21, 83, 4 do
    self:addPanel(365,  x, 0)
  end
  self:addPanel(366,  85, 0)
  for x = 223, 531, 7 do
    self:addPanel(367, x, 0)
  end
  self:addPanel(368, 529, 0)  -- Left extremity of the panel
  self:addPanel(369, 97,  self.height - 33):makeButton(0, 0, 17, 17, 370, self.decreaseMaxSize):setTooltip(_S.tooltip.queue_window.dec_queue_size)
  self:addPanel(371, 144, self.height - 33):makeButton(0, 0, 17, 17, 372, self.increaseMaxSize):setTooltip(_S.tooltip.queue_window.inc_queue_size)
  self:addPanel(373, self.width - 42, 17):makeButton(0, 0, 24, 24, 374, self.close):setTooltip(_S.tooltip.queue_window.close)
  
  self:makeTooltip(_S.tooltip.queue_window.num_in_queue, 15, 15, 163, 36)
  self:makeTooltip(_S.tooltip.queue_window.num_expected, 15, 39, 163, 60)
  self:makeTooltip(_S.tooltip.queue_window.num_entered,  15, 62, 163, 83)
  self:makeTooltip(_S.tooltip.queue_window.max_queue_size, 15, 87, 163, 108)
  
  self:makeTooltip(_S.tooltip.queue_window.front_of_queue, 168, 25, 213, 105)
  self:makeTooltip(_S.tooltip.queue_window.end_of_queue, 543, 51, 586, 105)
  self:makeTooltip(_S.tooltip.queue_window.patient        .. " " .. _S.misc.not_yet_implemented, 218, 15, 537, 107)
end

function UIQueue:decreaseMaxSize()
  local amount = 1
  if self.buttons_down.ctrl then
    amount = amount * 10
  elseif self.buttons_down.shift then
    amount = amount * 5
  end
  self.queue:decreaseMaxSize(amount)
end

function UIQueue:increaseMaxSize()
  local amount = 1
  if self.buttons_down.ctrl then
    amount = amount * 10
  elseif self.buttons_down.shift then
    amount = amount * 5
  end
  self.queue:increaseMaxSize(amount)
end

function UIQueue:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y
  
  local font = self.white_font
  local queue = self.queue  
  local num_patients = queue:reportedSize()

  font:draw(canvas, _S.queue_window.num_in_queue, x + 22, y + 22)
  font:draw(canvas, num_patients, x + 140, y + 22)
    
  font:draw(canvas, _S.queue_window.num_expected, x + 22, y + 45)
  font:draw(canvas, queue.expected_count, x + 140, y + 45)
    
  font:draw(canvas, _S.queue_window.num_entered, x + 22, y + 68)
  font:draw(canvas, queue.visitor_count, x + 140, y + 68)
  
  font:draw(canvas, _S.queue_window.max_queue_size, x + 22, y + 93)
  font:draw(canvas, queue.max_size, x + 119, y + 93)
  
  self:drawPatients(canvas, x, y)

  -- Draw dragged patient in the cursor location
  if self.dragged then
    self:drawPatient(canvas, self.dragged.x, self.dragged.y, self.dragged.patient)
  end
end

function UIQueue:isInsideQueueBoundingBox(x, y)
  local x_min = 219
  local x_max = 534
  local y_min = 15
  local y_max = 105
  return not (x < x_min or x > x_max or y < y_min or y > y_max)
end

function UIQueue:onMouseDown(button, x, y)
  -- Allow normal window operations if the mouse is outside the listing of patients
  if not self:isInsideQueueBoundingBox(x, y) then
    return Window.onMouseDown(self, button, x, y)
  end
  local x_min = 219
  local y_min = 15
  self.hovered = self:getHoveredPatient(x - x_min, y - y_min)
  -- Select patient to drag - if left clicking.
  if button == "left" then
    self.dragged = self.hovered
    if self.dragged then
      self.dragged.x = x + self.x
      self.dragged.y = y + self.y
    end
  elseif button == "right" and self.hovered then
    -- Otherwise bring up the choice screen.
    self.just_added = true
    self.ui:addWindow(UIQueuePopup(self.ui, self.x + x, self.y + y, self.hovered.patient))
  end
end

function UIQueue:onMouseUp(button, x, y)
  if self.just_added then
    self.just_added = false
  else
    -- Always remove any leftover popup windows
    local window = self.ui:getWindow(UIQueuePopup)
    if window then
      window:close()
    end
  end
  if button == "left" then
    local queue = self.queue
    local num_patients = queue:reportedSize()
    local width = 276
    self.ui:setCursor(self.ui.default_cursor) -- reset cursor

    if not self.dragged then
      return Window.onMouseUp(self, button, x, y)
    end

    -- Check whether the dragged patient is still in the queue
    local index = -1
    for i = 1, num_patients do
      if self.dragged.patient == queue:reportedHumanoid(i) then
        index = i
        break
      end
    end

    if index == -1 then
      self.dragged = nil
      return
    end

    if x > 170 and x < 210 and y > 25 and y < 105 then -- Inside door bounding box
      queue:move(index, 1) -- move to front
    elseif x > 542 and x < 585 and y > 50 and y < 105 then -- Inside exit sign bounding box
      queue:move(index, num_patients) -- move to back
    elseif self:isInsideQueueBoundingBox(x, y) then -- Inside queue bounding box
      local dx = 1
      if num_patients ~= 1 then
        dx = width / (num_patients - 1)
      end
      queue:move(index, math.floor((x - 220) / dx) + 1) -- move to dropped position
      self:onMouseMove(x, y, 0, 0)
    end

    -- Try to drop to another room
    local room
    local wx, wy = self.ui:ScreenToWorld(x + self.x, y + self.y)
    wx = math.floor(wx)
    wy = math.floor(wy)
    if wx > 0 and wy > 0 and wx < self.ui.app.map.width and wy < self.ui.app.map.height then
      room = self.ui.app.world:getRoom(wx, wy)
    end

    -- The new room must be of the same class as the current one
    local this_room = self.dragged.patient.next_room_to_visit
    if this_room and room and room ~= this_room and room.room_info.id == this_room.room_info.id then
      -- Move to another room
      local patient = self.dragged.patient
      patient:setNextAction(room:createEnterAction())
      patient.next_room_to_visit = room
      patient:updateDynamicInfo(_S.dynamic_info.patient.actions.on_my_way_to:format(room.room_info.name))
      room.door.queue:expect(patient)
      room.door:updateDynamicInfo()
    end
  end
  self.dragged = nil
end

function UIQueue:onMouseMove(x, y, dx, dy)
  local x_min = 219
  local y_min = 15
  if self.dragged then
    self.dragged.x = x + self.x
    self.dragged.y = y + self.y

    -- Change cursor when outside queue dialog
    if x > 0 and x < 605 and y > 0 and y < 120 then
      self.ui:setCursor(self.ui.default_cursor)
    else
      self.ui:setCursor(self.ui.app.gfx:loadMainCursor("queue_drag"))
    end
  end
  if not self:isInsideQueueBoundingBox(x, y) then
    self.hovered = nil
    Window:onMouseMove(x, y, dx, dy)
    return
  end

  -- Update hovered patient
  self.hovered = self:getHoveredPatient(x - x_min, y - y_min)
  Window:onMouseMove(x, y, dx, dy)
end

function UIQueue:close()
  -- Always remove any leftover popup windows
  local window = self.ui:getWindow(UIQueuePopup)
  if window then
    window:close()
  end
  Window.close(self)
end

function UIQueue:getHoveredPatient(x, y)
  local queue = self.queue
  local num_patients = queue:reportedSize()
  local width = 276
  local gap = 10
  x = x - 15 -- sprite offset

  local dx = 0
  if num_patients ~= 1 then
    dx = width / (num_patients - 1)
  end

  local offset = 0
  local closest = nil

  -- Find the closest patient to the given x-coordinate
  for index = 1, num_patients do
    local patient = queue:reportedHumanoid(index)
    local patient_x = (index - 1) * dx + offset
    local diff = math.abs(patient_x - x)

    -- Take into account the gap between the hovered patient and other patients
    if self.hovered and patient == self.hovered.patient then
      offset = gap * 2
      diff = diff + gap
    end

    if not closest or diff < closest.diff then
      closest = {patient = patient, diff = diff, x = x}
    end
  end

  -- The closest patient must be close enough (i.e. almost over the patient sprite)
  if not closest or closest.diff > 25 then
    return nil
  end

  return {patient = closest.patient, x = closest.x}
end

function UIQueue:drawPatients(canvas, x, y)
  local queue = self.queue
  local num_patients = queue:reportedSize()
  local width = 276
  local gap = 10
  local dx = 0

  if not self.hovered then
    if num_patients ~= 1 then
      dx = width / (num_patients - 1)
    end

    for index = 1, num_patients do
      local patient = queue:reportedHumanoid(index)
      self:drawPatient(canvas, x + 239 + dx * (index - 1), y + 75, patient)
    end
  else
    if num_patients ~= 1 then
      dx = (width - 2 * gap) / (num_patients - 1)
    end

    x = x + 239
    y = y + 75
    for index = 1, num_patients do
      local patient = queue:reportedHumanoid(index)
      if patient == self.hovered.patient then
        x = x + gap
        self:drawPatient(canvas, x, y - 10, patient)
        x = x + gap + dx
      else
        self:drawPatient(canvas, x, y, patient)
        x = x + dx
      end
    end
  end
end

function UIQueue:drawPatient(canvas, x, y, patient)
  local anim = TH.animation()
  local idle_anim = patient.getIdleAnimation(patient.humanoid_class)
  anim:setAnimation(self.ui.app.world.anims, idle_anim, 1) -- flag 1 is for having patients in west position (looking the door in the dialog)
  for layer, id in pairs(patient.layers) do
    anim:setLayer(layer, id)
  end
  anim:draw(canvas, x, y)
  -- Also draw the mood of the patient, if any.
  local mood = patient:getCurrentMood()
  if mood then
    mood:draw(canvas, x, y + 24)
  end
end

class "UIQueuePopup" (Window)

function UIQueuePopup:UIQueuePopup(ui, x, y, patient)
  self:Window()
  self.esc_closes = true
  self.ui = ui
  self.patient = patient
  self.width = 188
  self.height = 68
  local app = ui.app
  self.modal_class = "popup"
  self:setDefaultPosition(x, y)

  -- Background sprites
  self:addPanel(375, 0, 0)

  local function send_to_hospital(i)
    return --[[persistable:queue_dialog_popup_hospital_button]] function()
      -- TODO: Actually send to another hospital (when they exist)
      self.patient:goHome()
      local str = _S.dynamic_info.patient.actions.sent_to_other_hospital
      self.patient:updateDynamicInfo(str)
      self:close()
    end
  end

  -- Buttons
  self:addPanel(0, 12, 12):makeButton(0, 0, 81, 54, 378, self.sendToReception)
  self:addPanel(0, 95, 12):makeButton(0, 0, 81, 54, 379, self.sendHome)
  local bottom = 58
  -- TODO: Add this when there are other hospitals to send patients to.
  --[[for i, hospital in ipairs(ui.app.world.hospitals) do
    self:addPanel(376, 0, 68 + (i-1)*34)
    self:addPanel(0, 12, 34 + i*34):makeButton(0, 0, 164, 32, 380, send_to_hospital(i))
    bottom = bottom + 34
  end]]
  self:addPanel(377, 0, bottom)

  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req06V", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
end

function UIQueuePopup:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y
  -- TODO: Same as above.
  --[[for i, hospital in ipairs(self.ui.app.world.hospitals) do
    self.white_font:draw(canvas, hospital.name:upper() , x + 74, y + 78 + (i-1)*34, 92, 0)
  end]]
end

function UIQueuePopup:sendToReception()
  self.patient:setNextAction{name = "seek_reception"}
  self:close()
end

function UIQueuePopup:sendHome()
  self.patient:goHome()
  self:close()
end