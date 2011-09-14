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

--! The multi-purpose panel for launching dialogs / screens and dynamic information.
class "UIBottomPanel" (Window)

function UIBottomPanel:UIBottomPanel(ui)
  self:Window()
  
  local app = ui.app

  self.ui = ui
  self.world = app.world
  self.on_top = true
  self.width = 640
  self.height = 48
  self:setDefaultPosition(0.5, -0.1)
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "Panel02V", true)
  self.money_font = app.gfx:loadFont("QData", "Font05V")
  self.date_font = app.gfx:loadFont("QData", "Font16V")
  self.white_font = app.gfx:loadFont("QData", "Font01V", 0, -2)
  
  -- State relating to fax notification messages
  self.show_animation = true
  self.factory_counter = 22
  self.factory_direction = 0
  self.message_windows = {}
  self.message_queue = {}
  
  self.default_button_sound = "selectx.wav"
  self.countdown = 0
  
  self:addPanel( 1,   0, 0):makeButton(6, 6, 35, 36, 2, self.dialogBankManager, nil, self.dialogBankStats):setTooltip(_S.tooltip.toolbar.bank_button)
  self:addPanel( 3,  40, 0) -- Background for balance, rep and date
  self:addPanel( 4, 206, 0):makeButton(6, 6, 35, 36, 5, self.dialogBuildRoom):setTooltip(_S.tooltip.toolbar.rooms)
  self:addPanel( 6, 248, 0):makeButton(1, 6, 35, 36, 7, self.dialogFurnishCorridor):setTooltip(_S.tooltip.toolbar.objects)
  self:addPanel( 8, 285, 0):makeButton(1, 6, 35, 36, 9, self.editRoom)
    :setSound():setTooltip(_S.tooltip.toolbar.edit) -- Remove default sound for this button
  self:addPanel(10, 322, 0):makeButton(1, 6, 35, 36, 11, self.dialogHireStaff):setTooltip(_S.tooltip.toolbar.hire)
  -- The dynamic info bar
  self:addPanel(12, 364, 0)
  for x = 377, 630, 10 do
    self:addPanel(13, x, 0)
  end
  self:addPanel(14, 627, 0)
  
  -- Buttons that are shown instead of the dynamic info bar when hovering over it.
  local buttons = {}
  
  buttons[1] = self:addPanel(15, 364, 0) -- Staff management button
  buttons[1]:makeButton(6, 6, 35, 36, 16, self.dialogStaffManagement):setTooltip(_S.tooltip.toolbar.staff_list)
  buttons[2] = self:addPanel(17, 407, 0) -- Town map button
  buttons[2]:makeButton(1, 6, 35, 36, 18, self.dialogTownMap):setTooltip(_S.tooltip.toolbar.town_map)
  buttons[3] = self:addPanel(19, 445, 0) -- Casebook button
  buttons[3]:makeButton(1, 6, 35, 36, 20, self.dialogDrugCasebook):setTooltip(_S.tooltip.toolbar.casebook)
  buttons[4] = self:addPanel(21, 483, 0) -- Research button
  buttons[4]:makeButton(1, 6, 35, 36, 22, self.dialogResearch)
    :setSound():setTooltip(_S.tooltip.toolbar.research) -- Remove default sound for this button
  buttons[5] = self:addPanel(23, 521, 0) -- Status button
  buttons[5]:makeButton(1, 6, 35, 36, 24, self.dialogStatus):setTooltip(_S.tooltip.toolbar.status)
  buttons[6] = self:addPanel(25, 559, 0) -- Charts button
  buttons[6]:makeButton(1, 6, 35, 36, 26, self.dialogCharts):setTooltip(_S.tooltip.toolbar.charts)
  buttons[7] = self:addPanel(27, 597, 0) -- Policy button
  buttons[7]:makeButton(1, 6, 35, 36, 28, self.dialogPolicy):setTooltip(_S.tooltip.toolbar.policy)
  self.additional_buttons = buttons
  for _, buttons in ipairs(buttons) do
    buttons.visible = false
  end
  
  self:makeTooltip(_S.tooltip.toolbar.balance, 41, 5, 137, 28)
  self:makeTooltip(_S.tooltip.toolbar.date, 140, 5, 200, 42)
  self:makeDynamicTooltip(--[[persistable:reputation_tooltip]] function()
    return _S.tooltip.toolbar.reputation .. " (" .. self.ui.hospital.reputation .. ")"
  end, 41, 30, 137, 42)

  ui:addKeyHandler("R", self, self.dialogResearch)      -- R for research
  ui:addKeyHandler("M", self, self.openFirstMessage)    -- M for message
  ui:addKeyHandler("T", self, self.dialogTownMap)       -- T for town map
  ui:addKeyHandler("C", self, self.dialogDrugCasebook)  -- C for casebook
end

function UIBottomPanel:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)

  x, y = x + self.x, y + self.y
  self.money_font:draw(canvas, ("%7i"):format(self.ui.hospital.balance), x + 44, y + 9)
  local month, day = self.world:getDate()
  self.date_font:draw(canvas, _S.date_format.daymonth:format(day, month), x + 140, y + 20, 60, 0)
  
  -- Draw possible information in the dynamic info bar
  if not self.additional_buttons[1].visible then
    self:drawDynamicInfo(canvas, x + 364, y)
  end
  
  if self.show_animation then
    if self.factory_counter >= 1 then
        self.panel_sprites:draw(canvas, 40, x + 177, y + 1)
    end
  
    if self.factory_counter > 1 and self.factory_counter <= 22 then
      for dx = 0, self.factory_counter do
        self.panel_sprites:draw(canvas, 41, x + 179 + dx, y + 1)
      end
    end
  
    if self.factory_counter == 22 then
      self.panel_sprites:draw(canvas, 42, x + 201, y + 1)
    end
  end
  
  self:drawReputationMeter(canvas, x + 55, y + 35)
end

function UIBottomPanel:setPosition(x, y)
  -- Lock to bottom of screen
  return Window.setPosition(self, x, -0.1)
end

-- Draws the hospital reputation meter on canvas.
-- x_left is the leftmost x-coordinate of the reputation meter
-- y is the y-coordinate of the reputation meter
function UIBottomPanel:drawReputationMeter(canvas, x_left, y)
  local width = 65 -- Reputation meter width
  local step = width / (self.ui.hospital.reputation_max - self.ui.hospital.reputation_min)
  self.panel_sprites:draw(canvas, 36, x_left + step * (self.ui.hospital.reputation - self.ui.hospital.reputation_min), y)
end

function UIBottomPanel:drawDynamicInfo(canvas, x, y)
  if self.dynamic_info then
    local info = self.dynamic_info
    local font = self.white_font
    for i, text in ipairs(info["text"]) do
      font:drawWrapped(canvas, text, x + 20, y + 10*i, 240)
      if i == #info["text"] and info["progress"] then
        local white = canvas:mapRGB(255, 255, 255)
        local black = canvas:mapRGB(0, 0, 0)
        local orange = canvas:mapRGB(221, 83, 0)
        canvas:drawRect(white, x + 165, y + 10*i, 100, 10)
        canvas:drawRect(black, x + 166, y + 1 + 10*i, 98, 8)
        canvas:drawRect(orange, x + 166, y + 1 + 10*i, 98*info["progress"], 8)
        if info["dividers"] then
          for k, value in ipairs(info["dividers"]) do
            canvas:drawRect(white, x + 165 + value*100, y + 10*i, 1, 10)
          end
        end
      end
    end
  end
end

function UIBottomPanel:setDynamicInfo(info)
  if not info then
    self.countdown = 25
  else
    self.countdown = nil
    self.dynamic_info = info
  end
end

function UIBottomPanel:onMouseMove(x, y, dx, dy)
  local repaint = Window.onMouseMove(self, x, y, dx, dy)
  if self:showAdditionalButtons(x, y) then
    repaint = true
  end
  return repaint
end

function UIBottomPanel:showAdditionalButtons(x, y)
  local buttons = self.additional_buttons
  if self:hitTest(x, y) then -- Inside the panel
    if not buttons[1].visible then -- Are the buttons already shown?
      for _, btn in ipairs(buttons) do
        btn.visible = true
      end
    end
  else -- Outside the rectangle
    if buttons[1].visible then -- Are the buttons already invisible?
      for _, btn in ipairs(buttons) do
        btn.visible = false
      end
    end
  end
end

function UIBottomPanel:hitTest(x, y, x_offset)
  return x >= (x_offset and x_offset or 0) and y >= 0 and x < self.width and y < self.height
end

--! Queue a fax notification message to appear.
--! The arguments specify a message, which is added to a FIFO queue, and will
-- appear on screen once there is space.
--!param type (string) The type of message, can be: "emergency", "epidemy", "personality", "information", "disease", "report" or "strike"
--!param message (table or number) If type == "strike", the amount of pay rise. Else a list of texts to display, including a "choices" table with choices. See below for structure.
--!param owner (humanoid or nil) Some messages are related to one staff or patient. Otherwise this is nil.
--!param timeout (number or nil) If given, the message will expire after that many world ticks and be removed.
--!param default_choice (number or nil) If given, the choice with this number will be executed on expiration of the message.
--! Structure of message (except strike):
-- message = {
--   { text = "first line of text", offset (integer, optional) }
--   { text = "second line of text", offset (integer, optional) }
--   ...
--   choices = {
--     { text = "first choice", choice = "choice_type" }
--     ...
--   }
-- }
function UIBottomPanel:queueMessage(type, message, owner, timeout, default_choice)
  if not self.ui.hospital.message_popup then
    self.world.ui.adviser:say(_S.adviser.information.fax_received)
    self.ui.hospital.message_popup = true
  end
  self.message_queue[#self.message_queue + 1] = {
    type = type,
    message = message,
    owner = owner,
    timeout = timeout,
    default_choice = default_choice,
  }
end

--! Trigger a message to be moved from the queue into a actual window, after
-- first performing the necessary animation.
function UIBottomPanel:showMessage()
  if self.factory_direction ~= -1 then
    self.factory_direction = -1 
    if self.factory_counter < 0 then
      -- Factory is already opened so don't wait to show the message
      self.show_animation = false
      self.factory_counter = 9
    else
      -- Delay the appearance of the message to when the factory is opened
      self.factory_direction = -1
      self.factory_counter = 22
      self.show_animation = true
    end
  end
end

-- Opens the first available message in the list of message_windows.
function UIBottomPanel:openFirstMessage()
  if #self.message_windows > 0 then
    self.message_windows[1]:openMessage()
  end
end

-- Removes a message from the mesasge queue (for example if a room is built before the player
-- says what to do with the patient.
function UIBottomPanel:removeMessage(owner)
  for _, window in ipairs(self.message_windows) do
    if window.owner == owner then
      window:removeMessage()
      return true
    end
  end
  return false
end

--! Pop a message off the front of the message queue and turn it into an actual
-- message window.
function UIBottomPanel:createMessageWindow()
  local --[[persistable:bottom_panel_message_window_close]] function onClose(window, out_of_time)
    local index_to_remove
    for i, win in ipairs(self.message_windows) do
      if index_to_remove ~= nil then
        win:setXLimit(1 + (i - 2) * 30)
      elseif win == window then
        index_to_remove = i
      end
    end
    table.remove(self.message_windows, index_to_remove)
  end
  
  local message_windows = self.message_windows
  local message_info = self.message_queue[1]
  local alert_window = UIMessage(self.ui, 175, 1 + #message_windows * 30,
    onClose, message_info.type, message_info.message, message_info.owner, message_info.timeout, message_info.default_choice)
  message_windows[#message_windows + 1] = alert_window
  self:addWindow(alert_window)
  self.factory_direction = 1
  self.show_animation = true
  self.factory_counter = -50                -- Delay close of message factory
  table.remove(self.message_queue, 1)          -- Delete the last element of the queue
end

function UIBottomPanel:onTick()
  -- Advance the animation on the message factory
  if self.factory_direction == 1 then
    -- Close factory animation
    if self.factory_counter < 22 then
      self.factory_counter = self.factory_counter + 1
    end
  elseif self.factory_direction == -1 then
    -- Open factory animation
    if self.factory_counter >= 0 then
      if self.factory_counter == 0 then
        -- Animation ends so we can now show the message
        self:createMessageWindow()
      end
      self.factory_counter = self.factory_counter - 1
    end
  end
  
  -- The dynamic info bar is there a while longer when hovering an entity has stopped
  if self.countdown then
    if self.countdown < 1 then
      self.dynamic_info = nil
      -- If there is no info to display, and the app is tracking FPS, show that
      local fps = self.ui.app:getFPS()
      if fps then
        self.dynamic_info = {text = {
          ("FPS: %i"):format(fps),
          ("Lua GC: %.1f Kb"):format(collectgarbage"count"),
          ("Entities: %i"):format(#self.ui.app.world.entities),
        }}
        self.countdown = 1
      end
    else
      self.countdown = self.countdown - 1
    end
  end
  
  -- Move an item out of the message queue if there is room
  if #self.message_windows < 5 and #self.message_queue > 0 then
    self:showMessage()
  end
  
  Window.onTick(self)
end

function UIBottomPanel:dialogBankManager()
  self:addDialog(UIBankManager(self.ui))
end

function UIBottomPanel:dialogBankStats()
  local dlg = UIBankManager(self.ui)
  self:addDialog(dlg, function() dlg:showStatistics() end)
end

function UIBottomPanel:dialogBuildRoom()
  local dlg = UIBuildRoom(self.ui)
  self.ui:setEditRoom(false)
  self.ui:addWindow(dlg)
  self.ui:tutorialStep(3, 1, 2)
end

function UIBottomPanel:dialogFurnishCorridor()
  local dlg = UIFurnishCorridor(self.ui)
  self.ui:setEditRoom(false)
  self.ui:addWindow(dlg)
  self.ui:tutorialStep(1, 1, 2)
end

function UIBottomPanel:dialogHireStaff()
  local dlg = UIHireStaff(self.ui)
  self.ui:setEditRoom(false)
  self.ui:addWindow(dlg)
  self.ui:tutorialStep(2, 1, 2)
  self.ui:tutorialStep(4, 1, 2)
end

function UIBottomPanel:dialogTownMap()
  self:addDialog(UITownMap(self.ui))
end

function UIBottomPanel:dialogDrugCasebook()
  self:addDialog(UICasebook(self.ui))
end

function UIBottomPanel:dialogStaffManagement()
  self:addDialog(UIStaffManagement(self.ui))
end

function UIBottomPanel:dialogPolicy()
  self:addDialog(UIPolicy(self.ui))
end

function UIBottomPanel:dialogCharts()
  self:addDialog(UIGraphs(self.ui))
end

function UIBottomPanel:dialogResearch()
  if self.ui.hospital.research_dep_built then
    self:addDialog(UIResearch(self.ui))
    self.ui:playSound("selectx.wav")
  else
    self.ui:playSound("wrong2.wav")
  end
end

function UIBottomPanel:dialogStatus()
  self:addDialog(UIProgressReport(self.ui))
end

function UIBottomPanel:addDialog(dialog, extra_function)
  local edit_window = self.ui:getWindow(UIEditRoom)
  -- If we are currently editing a room, ask for abortion before adding any dialog.
  if edit_window then
    self.ui:addWindow(UIConfirmDialog(self.ui,
      _S.confirmation.abort_edit_room,
      --[[persistable:abort_edit_room_confirm_dialog]]function()
        self.ui:setEditRoom(false)
        if extra_function then
          extra_function()
        end
        self.ui:addWindow(dialog)
      end
    ))
  else
    self.ui:setEditRoom(false)
    if extra_function then
      extra_function()
    end
    self.ui:addWindow(dialog)
  end
end

function UIBottomPanel:editRoom()
  local ui = self.ui
  if ui.editing_allowed then
    self.ui:playSound("selectx.wav")
    if ui.edit_room then
      ui:setEditRoom(false)
    else
      ui:setEditRoom(true)
    end
  else
    -- no editing is allowed when other dialogs are open
    self.ui:playSound("wrong2.wav")
  end
end

function UIBottomPanel:afterLoad(old, new)
  if old < 40 then
    -- Find the graph dialog and enable it
    for _, button in ipairs(self.buttons) do
      if not button.on_click then
        button.on_click = self.dialogCharts
        button.enabled = true
      end
    end
  end
  Window.afterLoad(self, old, new)
end

