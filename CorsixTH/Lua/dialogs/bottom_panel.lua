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

---@type UIBottomPanel
local UIBottomPanel = _G["UIBottomPanel"]

function UIBottomPanel:UIBottomPanel(ui)
  self:Window()

  local app = ui.app

  self.ui = ui
  self.world = app.world
  self.on_top = false
  self.width = 640
  self.height = 48
  self:setDefaultPosition(0.5, -0.1)
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "Panel02V", true)
  self.money_font = app.gfx:loadFont("QData", "Font05V")
  self.date_font = app.gfx:loadFont("QData", "Font16V")
  self.white_font = app.gfx:loadFont("QData", "Font01V", 0, -2)
  self.pause_font = app.gfx:loadFont("QData", "Font124V")

  -- State relating to fax notification messages
  self.show_animation = true
  self.factory_counter = 22
  self.factory_direction = 0
  self.message_windows = {}
  self.message_queue = {}

  self.default_button_sound = "selectx.wav"
  self.countdown = 0

  self.bank_button = self:addPanel( 1,   0, 0):makeToggleButton(6, 6, 35, 36, 2, self.dialogBankManager, nil, self.dialogBankStats):setTooltip(_S.tooltip.toolbar.bank_button)
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
  local panels = {}
  local buttons = {}

  panels[1]  = self:addPanel(15, 364, 0) -- Staff management button
  buttons[1] = panels[1]:makeToggleButton(6, 6, 35, 36, 16, self.dialogStaffManagement):setTooltip(_S.tooltip.toolbar.staff_list)
  panels[2]  = self:addPanel(17, 407, 0) -- Town map button
  buttons[2] = panels[2]:makeToggleButton(1, 6, 35, 36, 18, self.dialogTownMap):setTooltip(_S.tooltip.toolbar.town_map)
  panels[3]  = self:addPanel(19, 445, 0) -- Casebook button
  buttons[3] = panels[3]:makeToggleButton(1, 6, 35, 36, 20, self.dialogDrugCasebook):setTooltip(_S.tooltip.toolbar.casebook)
  panels[4]  = self:addPanel(21, 483, 0) -- Research button
  buttons[4] = panels[4]:makeToggleButton(1, 6, 35, 36, 22, self.dialogResearch)
    :setSound():setTooltip(_S.tooltip.toolbar.research) -- Remove default sound for this button
  panels[5]  = self:addPanel(23, 521, 0) -- Status button
  buttons[5] = panels[5]:makeToggleButton(1, 6, 35, 36, 24, self.dialogStatus):setTooltip(_S.tooltip.toolbar.status)
  panels[6]  = self:addPanel(25, 559, 0) -- Charts button
  buttons[6] = panels[6]:makeToggleButton(1, 6, 35, 36, 26, self.dialogCharts):setTooltip(_S.tooltip.toolbar.charts)
  panels[7]  = self:addPanel(27, 597, 0) -- Policy button
  buttons[7] = panels[7]:makeToggleButton(1, 6, 35, 36, 28, self.dialogPolicy):setTooltip(_S.tooltip.toolbar.policy)
  for _, panel in ipairs(panels) do
    panel.visible = false
    end
  self.additional_panels = panels
  self.additional_buttons = buttons

  self:makeTooltip(_S.tooltip.toolbar.balance, 41, 5, 137, 28)
  self:makeTooltip(_S.tooltip.toolbar.date, 140, 5, 200, 42)
  self:makeDynamicTooltip(--[[persistable:reputation_tooltip]] function()
    return _S.tooltip.toolbar.reputation .. " (" .. self.ui.hospital.reputation .. ")"
  end, 41, 30, 137, 42)

  self:registerKeyHandlers()
end

function UIBottomPanel:registerKeyHandlers()
  local ui = self.ui
  local buttons = self.additional_buttons

  -- The bottom panel hotkeys.
  ui:addKeyHandler("ingame_panel_bankManager", self.bank_button, self.bank_button.handleClick, "left")  -- bank manager
  ui:addKeyHandler("ingame_panel_bankStats", self.bank_button, self.bank_button.handleClick, "right")  -- bank stats
  ui:addKeyHandler("ingame_panel_staffManage", buttons[1], buttons[1].handleClick, "left")    -- staff management
  ui:addKeyHandler("ingame_panel_townMap", buttons[2], buttons[2].handleClick, "left")    -- town map
  ui:addKeyHandler("ingame_panel_casebook", buttons[3], buttons[3].handleClick, "left")    -- casebook
  ui:addKeyHandler("ingame_panel_research", buttons[4], buttons[4].handleClick, "left")    -- research
  ui:addKeyHandler("ingame_panel_status", buttons[5], buttons[5].handleClick, "left")    -- status
  ui:addKeyHandler("ingame_panel_charts", buttons[6], buttons[6].handleClick, "left")    -- charts
  ui:addKeyHandler("ingame_panel_policy", buttons[7], buttons[7].handleClick, "left")    -- policy
  -- Hotkeys for building a room, furnishing the corridor, editing a room, and hiring staff.
  ui:addKeyHandler("ingame_panel_buildRoom", self, self.dialogBuildRoom)    -- Build room.
  ui:addKeyHandler("ingame_panel_furnishCorridor", self, self.dialogFurnishCorridor)    -- Furnish corridor.
  ui:addKeyHandler("ingame_panel_editRoom", self, self.editRoom)    -- Edit room.
  ui:addKeyHandler("ingame_panel_hireStaff", self, self.dialogHireStaff)    -- Hire staff.

  -- Alternate keyboard shortcuts for some of the fullscreen windows.
  ui:addKeyHandler("ingame_panel_map_alt", buttons[2], buttons[2].handleClick, "left") -- town map
  ui:addKeyHandler("ingame_panel_research_alt", buttons[4], buttons[4].handleClick, "left") -- research
  local config = ui.app.config
  if not config.volume_opens_casebook then
    ui:addKeyHandler("ingame_panel_casebook_alt", buttons[3], buttons[3].handleClick, "left") -- casebook
  else
    ui:addKeyHandler("ingame_panel_casebook_alt02", buttons[3], buttons[3].handleClick, "left") -- casebook
  end
  ui:addKeyHandler("ingame_loadMenu", self, self.openLoad)  -- load saved game menu
  ui:addKeyHandler("ingame_saveMenu", self, self.openSave)  -- load create save menu
  ui:addKeyHandler("ingame_restartLevel", self, self.restart)  -- restart the level
  ui:addKeyHandler("ingame_quitLevel", self, self.quit)  -- quit the game and return to main menu
  ui:addKeyHandler("ingame_quickSave", self, self.quickSave)  -- quick save
  ui:addKeyHandler("ingame_quickLoad", self, self.quickLoad)  -- load last quick save

  -- misc. keyhandlers
  ui:addKeyHandler("ingame_openFirstMessage", self, self.openFirstMessage)    -- message
  ui:addKeyHandler("ingame_toggleInfo", self, self.toggleInformation)   -- information when you first build
  ui:addKeyHandler("ingame_jukebox", self, self.openJukebox)   -- jukebox
end

function UIBottomPanel:openJukebox()
  if self.ui.app.config.audio and self.ui.app:isAudioEnabled() then
    self.ui:addWindow(UIJukebox(self.ui.app))
  end
end

function UIBottomPanel:openSave()
  self.ui:addWindow(UISaveGame(self.ui))
end

function UIBottomPanel:openLoad()
  self.ui:addWindow(UILoadGame(self.ui, "game"))
end

function UIBottomPanel:quickSave()
  self.ui.app:quickSave()
end

function UIBottomPanel:quickLoad()
  self.ui.app:quickLoad()
end

function UIBottomPanel:restart()
  self.ui.app:restart()
end

function UIBottomPanel:quit()
  self.ui:quit()
end

function UIBottomPanel:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)

  x, y = x + self.x, y + self.y
  self.money_font:draw(canvas, ("%7i"):format(self.ui.hospital.balance), x + 44, y + 9)
  local month, day = self.world:getDate()
  self.date_font:draw(canvas, _S.date_format.daymonth:format(day, month), x + 140, y + 20, 60, 0)

  -- Draw possible information in the dynamic info bar
  if not self.additional_panels[1].visible then
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
  self.panel_sprites:draw(canvas, 36, x_left + math.floor(step * (self.ui.hospital.reputation - self.ui.hospital.reputation_min)), y)
end

function UIBottomPanel:drawDynamicInfo(canvas, x, y)
  if self.world:isCurrentSpeed("Pause") and not self.world.user_actions_allowed then
    self.pause_font:drawWrapped(canvas, _S.misc.pause, x + 10, y + 14, 255, "center")
    return
  end

  if not (self.dynamic_info and self.dynamic_info["text"]) then
    return
  end

  local info = self.dynamic_info
  local font = self.white_font
  for i, text in ipairs(info["text"]) do
    font:drawWrapped(canvas, text, x + 20, y + 10 * i, 240)
    if i == #info["text"] and info["progress"] then
      local white = canvas:mapRGB(255, 255, 255)
      local black = canvas:mapRGB(0, 0, 0)
      local orange = canvas:mapRGB(221, 83, 0)
      canvas:drawRect(white, x + 165, y + 10 * i, 100, 10)
      canvas:drawRect(black, x + 166, y + 1 + 10 * i, 98, 8)
      canvas:drawRect(orange, x + 166, y + 1 + 10 * i, math.floor(98 * info["progress"]), 8)
      if info["dividers"] then
        for _, value in ipairs(info["dividers"]) do
          canvas:drawRect(white, x + 165 + math.floor(value * 100), y + 10 * i, 1, 10)
        end
      end
    end
  end
end

--! Update the information shown in the information box on the panel.
--!
--! If the info is nil then a cooldown timer is used before removing the
--! information from the display.
--!
--!param info (table) A table containing the information to display. The text
--! key is required and contains an array of lines to show. An optional
--! progress key may be given to draw a progress bar, following the text and
--! and an array of dividers may be provided to draw extra vertical lines in
--! the progress bar.
--!
--! info = {
--!   text: { "He's not the saviour", "He's very naughty boy" },
--!   progress: 50,
--!   dividers: { 25, 50, 75 }
--! }
function UIBottomPanel:setDynamicInfo(info)
  if info and not info["text"] then
    self.world:gameLog("")
    self.world:gameLog("Dynamic info is missing text!")
    self.world:gameLog("Please report this issue including the call stack below.")
    self.world:gameLog(debug.traceback())

    return
  end

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
  local panels = self.additional_panels
  if self:hitTest(x, y) then -- Inside the panel
    if not panels[1].visible then -- Are the buttons already shown?
      for _, panel in ipairs(panels) do
        panel.visible = true
      end
    end
  else -- Outside the rectangle
    if panels[1].visible then -- Are the buttons already invisible?
      for _, panel in ipairs(panels) do
        panel.visible = false
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
--!param callback (function or nil) If given, it will be called when the message is closed.
--! Structure of message (except strike):
-- message = {
--   { text = "first line of text", offset (integer, optional) }
--   { text = "second line of text", offset (integer, optional) }
--   ...
--   choices = {
--     { text = "first choice", choice = "choice_type", enabled = true or false (optional, defaults to true) }
--     ...
--   }
-- }
function UIBottomPanel:queueMessage(type, message, owner, timeout, default_choice, callback)
  -- Show a helpful message if there has been no messages before - only in campaign though
  if not self.ui.hospital.message_popup and tonumber(self.world.map.level_number) then
    self.world.ui.adviser:say(_A.information.fax_received)
    self.ui.hospital.message_popup = true
  end
  local fax = {
    type = type,
    message = message,
    owner = owner,
    timeout = timeout,
    default_choice = default_choice,
    callback = callback,
  }

  if self:canQueueFax(fax) then
    self.message_queue[#self.message_queue + 1] = fax
    -- create reference to message in owner
    if owner then
      owner.message = message
    end
  else
    self:cancelFax(fax.type)
  end
end

--[[ A fax can be queued if the event the fax causes does not affect
an event caused by any other fax that is queued. i.e both emergency
and epidemics use the timer, so both faxes cannot appear at the same time.
@param fax (table) the fax we want to determine if can be queued.
@return true if fax can be queued, false otherwise (boolean) ]]
function UIBottomPanel:canQueueFax(fax)
  --[[ Determine if fax of a particular type is queued either in the
  message queue or the message window (ui)
  @param fax_type (string) the fax type to check if any queued
  @return true if any of fax_type is queued false otherwise (boolean) ]]
  local function isFaxTypeQueued(fax_type)
    -- Check the queued messages
    for _, fax_msg in ipairs(self.message_queue) do
      if fax_msg.type == fax_type then
        return true
      end
    end
    -- Then the messages displayed on the bottom bar
    for _, fax_msg in ipairs(self.message_windows) do
      if fax_msg.type == fax_type then
        return true
      end
    end
    return false
  end

  if fax.type == "epidemy" then
    if isFaxTypeQueued("emergency") then
      return false
    end
  elseif fax.type == "emergency" then
    if isFaxTypeQueued("epidemy") then
      return false
    end
  end
  return true
end

--[[ Cancels a fax of a particular type currently only "emergency" and "epidemy"
Handles the cancelling of the event which the fax pertains to.
@param fax_type (string) type of fax event to be cancelled]]
function UIBottomPanel:cancelFax(fax_type)
  local hospital = self.ui.hospital
  if fax_type == "epidemy" then
    hospital.epidemic:clearAllInfectedPatients()
    hospital.epidemic = nil
  elseif fax_type == "emergency" then
    self.world:nextEmergency()
  end
end

-- Opens the last available message. Currently used to open the level completed message.
function UIBottomPanel:openLastMessage()
  if #self.message_queue > 0 then
    self:createMessageWindow(#self.message_queue)
    table.remove(self.message_queue, #self.message_queue)
  end
  self.message_windows[#self.message_windows]:openMessage()
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

-- Removes a message from the message queue (for example if a room is built before the player
-- says what to do with the patient.
function UIBottomPanel:removeMessage(owner)
  for i, msg_info in ipairs(self.message_queue) do
    if msg_info.owner == owner then
      -- TODO: restructure message_queue to contain UIMessage objects already, so this special handling isn't required
      owner.message = nil
      table.remove(self.message_queue, i)
      return true
    end
  end
  for _, window in ipairs(self.message_windows) do
    if window.owner == owner then
      window:removeMessage()
      return true
    end
  end
  return false
end

--! Pop the message with the given index from the message queue and turn it into an actual
-- message window; if no index is provided the first message in the queue is popped.
function UIBottomPanel:createMessageWindow(index)
  local --[[persistable:bottom_panel_message_window_close]] function onClose(window, out_of_time)
    local index_to_remove
    for i, win in ipairs(self.message_windows) do
      if index_to_remove ~= nil then
        win:setXLimit(1 + (i - 2) * 30)
      elseif win == window then
        index_to_remove = i
        if win.callback then
          win.callback()
        end
      end
    end
    table.remove(self.message_windows, index_to_remove)
  end

  if not index then
    index = 1
  end
  local message_windows = self.message_windows
  local message_info = self.message_queue[index]
  if not message_info then
    return
  end
  -- Create the message window, note this does not show it to the player on creation.
  local alert_window = UIMessage(self.ui, 175, 1 + #message_windows * 30,
    onClose, message_info.type, message_info.message, message_info.owner, message_info.timeout, message_info.default_choice, message_info.callback)
  message_windows[#message_windows + 1] = alert_window
  self:addWindow(alert_window)
  self.factory_direction = 1
  self.show_animation = true
  self.factory_counter = -50                -- Delay close of message factory
  table.remove(self.message_queue, index)   -- Delete the last element of the queue
end

function UIBottomPanel:onTick()
  -- Advance the animation on the message factory
  if self.factory_direction == 1 then
    -- Close factory animation
    if self.factory_counter < 22 then
      self.factory_counter = self.factory_counter + 1
    end
  elseif self.factory_direction == -1 then
    if #self.message_queue == 0 then
      -- Message was removed before we could display it. Reset.
      self.factory_direction = 1
      self.factory_counter = 22
    end
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
          ("FPS: %i"):format(math.floor(fps + 0.5) or 0),
          ("Lua GC: %.1f Kb"):format(collectgarbage("count") or 0),
          ("Entities: %i"):format(#self.ui.app.world.entities or 0),
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

function UIBottomPanel:dialogBankManager(enable)
  self:dialogBankCommon(enable)
end

function UIBottomPanel:dialogBankStats(enable)
  self:dialogBankCommon(enable, true)
end

function UIBottomPanel:dialogBankCommon(enable, stats)
  if not self.world.user_actions_allowed then
    self:updateButtonStates()
    return
  end

  if enable then
    self:addDialog("UIBankManager", stats and "showStatistics")
  else
    local w = self.ui:getWindow(UIBankManager)
    if w then
      if not stats and w.showingStatistics then
        w:hideStatistics()
      elseif stats and not w.showingStatistics then
        w:showStatistics()
      else
        w:close()
      end
      self:updateButtonStates()
    end
  end
end

function UIBottomPanel:dialogBuildRoom()
  if self.world.user_actions_allowed then
    local w = self.ui:getWindow(UIBuildRoom)
    local fullscreen = self.ui:getWindow(UIFullscreen)

    if w then
      if fullscreen then
        fullscreen:close()
      else
        w:close()
      end
    else
      if fullscreen then
        fullscreen:close()
      end

      local dlg = UIBuildRoom(self.ui)
      self.ui:setEditRoom(false)
      self.ui:addWindow(dlg)
      self.ui:tutorialStep(3, 1, 2)
    end
  end
end

function UIBottomPanel:dialogFurnishCorridor()
  if self.world.user_actions_allowed then
    local w = self.ui:getWindow(UIFurnishCorridor)
    local fullscreen = self.ui:getWindow(UIFullscreen)

    if w then
      if fullscreen then
        fullscreen:close()
      else
        w:close()
      end
    else
      if fullscreen then
        fullscreen:close()
      end

      local dlg = UIFurnishCorridor(self.ui)
      self.ui:setEditRoom(false)
      self.ui:addWindow(dlg)
      self.ui:tutorialStep(1, 2, 3)
    end
  end
end

function UIBottomPanel:dialogHireStaff()
  if self.world.user_actions_allowed then
    local w = self.ui:getWindow(UIHireStaff)
    local fullscreen = self.ui:getWindow(UIFullscreen)

    if w then
      if fullscreen then
        fullscreen:close()
      else
        w:close()
      end
    else
      if fullscreen then
        fullscreen:close()
      end

      local dlg = UIHireStaff(self.ui)
      self.ui:setEditRoom(false)
      self.ui:addWindow(dlg)
      self.ui:tutorialStep(2, 1, 2)
      self.ui:tutorialStep(4, 1, 2)
    end
  end
end

function UIBottomPanel:dialogStaffManagement(enable)
  if not self.world.user_actions_allowed then
    self:updateButtonStates()
    return
  end
  if enable then
    self:addDialog("UIStaffManagement")
  else
    local w = self.ui:getWindow(UIStaffManagement)
    if w then
      w:close()
    end
  end
end

function UIBottomPanel:dialogTownMap(enable)
  if not self.world.user_actions_allowed then
    self:updateButtonStates()
    return
  end
    if enable then
    self:addDialog("UITownMap")
    else
    local w = self.ui:getWindow(UITownMap)
      if w then
        w:close()
      end
    end
  end

function UIBottomPanel:dialogDrugCasebook(enable)
  if not self.world.user_actions_allowed then
    self:updateButtonStates()
    return
end
  if enable then
    self:addDialog("UICasebook")
  else
    local w = self.ui:getWindow(UICasebook)
    if w then
      w:close()
    end
  end
end

function UIBottomPanel:dialogResearch(enable)
  if not self.world.user_actions_allowed then
    self:updateButtonStates()
    return
  end
  if self.ui.hospital.research_dep_built then
    if enable then
      self:addDialog("UIResearch")
    else
      local w = self.ui:getWindow(UIResearch)
      if w then
        w:close()
      end
    end
    self.ui:playSound("selectx.wav")
  else
    self.ui:playSound("wrong2.wav")
    self:updateButtonStates()
    self:giveResearchAdvice()
  end
end

function UIBottomPanel:giveResearchAdvice()
  local can_build_research = false
  for _, room in ipairs(self.ui.app.world.available_rooms) do
    if room.class == "ResearchRoom" then
      can_build_research = true
      break
    end
  end
  local msg = can_build_research and _A.warnings.research_screen_open_1 or _A.warnings.research_screen_open_2
  self.ui.adviser:say(msg)
end

function UIBottomPanel:dialogStatus(enable)
  if not self.world.user_actions_allowed then
    self:updateButtonStates()
    return
  end
  if enable then
    self:addDialog("UIProgressReport")
  else
    local w = self.ui:getWindow(UIProgressReport)
    if w then
      w:close()
    end
  end
end

function UIBottomPanel:dialogCharts(enable)
  if not self.world.user_actions_allowed then
    self:updateButtonStates()
    return
  end
  if enable then
    self:addDialog("UIGraphs")
  else
    local w = self.ui:getWindow(UIGraphs)
    if w then
      w:close()
    end
  end
end

function UIBottomPanel:dialogPolicy(enable)
  if not self.world.user_actions_allowed then
    self:updateButtonStates()
    return
  end
  if enable then
    self:addDialog("UIPolicy")
  else
    local w = self.ui:getWindow(UIPolicy)
    if w then
      w:close()
    end
  end
end

function UIBottomPanel:toggleInformation()
  self.world:toggleInformation()
end

local fullscreen_dialogs = {
  "UIStaffManagement",
  "UITownMap",
  "UICasebook",
  "UIResearch",
  "UIProgressReport",
  "UIGraphs",
  "UIPolicy",
}

function UIBottomPanel:updateButtonStates()
  for i, button in ipairs(self.additional_buttons) do
    button:setToggleState(not not self.ui:getWindow(_G[fullscreen_dialogs[i]]))
  end
  self.bank_button:setToggleState(not not self.ui:getWindow(UIBankManager))
end

function UIBottomPanel:addDialog(dialog_class, extra_function)
  local edit_window = self.ui:getWindow(UIEditRoom)
  -- If we are currently editing a room, ask for abortion before adding any dialog.
  if edit_window then
    self.ui:addWindow(UIConfirmDialog(self.ui, false,
      _S.confirmation.abort_edit_room,
      --[[persistable:abort_edit_room_confirm_dialog]]function()
        self.ui:setEditRoom(false)
        local dialog = _G[dialog_class](self.ui)
        if extra_function then
          _G[dialog_class][extra_function](dialog)
        end
        self.ui:addWindow(dialog)
        self:updateButtonStates()
      end
      ))
    self:updateButtonStates()
  else
    self.ui:setEditRoom(false)
    local dialog = _G[dialog_class](self.ui)
    self.ui:addWindow(dialog)
    if extra_function then
      _G[dialog_class][extra_function](dialog)
    end
    self:updateButtonStates()
  end
end

-- Do not remove, for savegame compatibility < r1878
local --[[persistable:abort_edit_room_cancel_dialog]]function stub()
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
  if old < 58 then
    self.pause_font = TheApp.gfx:loadFont("QData", "Font124V")
  end
  if old < 62 then
    -- renamed additional_buttons to additional_panels
    -- additional_buttons are now the actual buttons
    self.additional_panels = self.additional_buttons
    self.additional_buttons = {}
    for i = 1, 7 do
      self.additional_buttons[i] = self.buttons[5 + i]:makeToggle() -- made them toggle buttons
    end
    self.bank_button = self.buttons[1]:makeToggle()
  end
  -- Hotfix to force re-calculation of the money font (see issue #1193)
  self.money_font = self.ui.app.gfx:loadFont("QData", "Font05V")

  self:registerKeyHandlers()

  Window.afterLoad(self, old, new)
end
