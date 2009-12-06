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

class "UIBottomPanel" (Window)

function UIBottomPanel:UIBottomPanel(ui)
  self:Window()
  
  local app = ui.app

  self.ui = ui
  self.world = app.world
  self.x = (app.config.width - 640) / 2
  self.y = app.config.height - 48
  self.show_animation = true
  self.factory_counter = 22
  self.factory_direction = 0
  self.message_windows = {}
  self.message_queue = {}
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "Panel02V", true)
  self.money_font = app.gfx:loadFont("QData", "Font05V")
  self.date_font = app.gfx:loadFont("QData", "Font16V")
  
  self:addPanel( 1,   0, 0) -- $ button
  self:addPanel( 3,  40, 0) -- Background for balance, rep and date
  self:addPanel( 4, 206, 0):makeButton(6, 6, 35, 36, 5, self.dialogBuildRoom)
  self:addPanel( 6, 248, 0):makeButton(1, 6, 35, 36, 7, self.dialogFurnishCorridor)
  self:addPanel( 8, 285, 0) -- Edit rooms / items button
  self:addPanel(10, 322, 0):makeButton(1, 6, 35, 36, 11, self.dialogHireStaff)
  self:addPanel(15, 364, 0) -- Staff management button
  self:addPanel(17, 407, 0) -- Town map button
  self:addPanel(19, 445, 0) -- Drug casebook button
  self:addPanel(21, 483, 0) -- Research button
  self:addPanel(23, 521, 0) -- Status button
  self:addPanel(25, 559, 0) -- Charts button
  self:addPanel(27, 597, 0) -- Policy button
end

function UIBottomPanel:draw(canvas)
  Window.draw(self, canvas)

  local x, y = self.x, self.y
  self.money_font:draw(canvas, ("%7i"):format(self.ui.hospital.balance), x + 44, y + 9)
  local month, day = self.world:getDate()
  self.date_font:draw(canvas, day .. " " .. _S(6, month), x + 140, y + 20, 60, 0)
  
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
end

function UIBottomPanel:queueMessage(type)
  self.message_queue[#self.message_queue + 1] = {type = type} -- Queue a message
end

function UIBottomPanel:showMessage()
  if self.factory_direction ~= -1 then
    self.factory_direction = -1 
    if self.factory_counter < 0 then
      self.show_animation = false -- Factory is already opened so don't wait to show the message
      self.factory_counter = 9
    else
      self.factory_direction = -1 -- Delay the apparition of the message to when the factory is opened
      self.factory_counter = 22
      self.show_animation = true
    end
  end
end

function UIBottomPanel:createMessageWindow()
  local function onClose(window, out_of_time)
    local message_windows = self.message_windows
    local index_to_remove
    for i = 1, #message_windows do
      if index_to_remove ~= nil and message_windows[i].x > self.x then
        message_windows[i]:moveLeft()   -- This windows are to the right of the window closed, so move them left
      end
      
      if message_windows[i] == window then
        index_to_remove = i             -- This is the window closed, so mark this index to be removed
      end
    end
    table.remove(message_windows, index_to_remove)
  end
  
  local message_windows = self.message_windows
  local message_type = self.message_queue[#self.message_queue].type
  local alert_window = UIMessage(self.ui, self.x + 175, self.x + 1 + #message_windows * 30, onClose, message_type) -- Create the message window
  message_windows[#message_windows + 1] = alert_window
  self.ui:addWindow(alert_window)
  self.factory_direction = 1
  self.show_animation = true
  self.factory_counter = -50                -- Delay close of message factory
  table.remove(self.message_queue)          -- Delete the last element of the queue
end

function UIBottomPanel:onTick()
  if self.factory_direction == 1 then       -- Close factory animation
    if self.factory_counter < 22 then
      self.factory_counter = self.factory_counter + 1
    end
  elseif self.factory_direction == -1 then  -- Open factory animation
    if self.factory_counter >= 0 then
      if self.factory_counter == 0 then
        self:createMessageWindow()          -- Animation ends so we can now show the message
      end
      self.factory_counter = self.factory_counter - 1
    end
  end
  
  if #self.message_windows < 5 and #self.message_queue > 0 then
    self:showMessage() -- Proceed queue
  end
end

function UIBottomPanel:dialogBuildRoom()
  local dlg = UIBuildRoom(self.ui)
  self.ui:addWindow(dlg)
end

function UIBottomPanel:dialogFurnishCorridor()
  local dlg = UIFurnishCorridor(self.ui)
  self.ui:addWindow(dlg)
end

function UIBottomPanel:dialogHireStaff()
  local dlg = UIHireStaff(self.ui)
  self.ui:addWindow(dlg)
end
