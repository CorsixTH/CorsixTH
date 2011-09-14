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

--! Small fax notification window which sits on the bottom bar.
class "UIMessage" (Window)

function UIMessage:UIMessage(ui, x, stop_x, onClose, type, message, owner, timeout, default_choice)
  self:Window()
  
  local app = ui.app
  ui:playSound("NewFax.wav")
  
  self.esc_closes = false
  self.on_top = false
  self.onClose = onClose
  self.timer = timeout
  self.default_choice = default_choice
  self.ui = ui
  self.message = message
  if owner then
    self.owner = owner
    if owner.message_callback then
      owner:message_callback(true) -- There can be only one message per owner, just remove any existing one
    end
    assert(owner.message_callback == nil)
    owner.message_callback = --[[persistable:owner_of_message_callback]] function(humanoid, do_remove)
      if do_remove then
        self:removeMessage()
      else
        self:openMessage()
      end
    end
  end
  self.width = 30
  self.height = 28
  self.stop_x = stop_x
  self.stop_y = -24
  self.x = x
  self.y = 4
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "Panel02V", true)
  self.type = type
  
  local types = { emergency = 43, epidemy = 45, strike = 47, personality = 49, information = 51, disease = 53, report = 55 }
  local type = types[type]
  
  self.can_dismiss = self.type ~= "strike" and #self.message.choices == 1
  
  self.button = self:addPanel(type, 0, 0)
    :setTooltip(self.can_dismiss and _S.tooltip.message.button_dismiss or _S.tooltip.message.button) -- FIXME: tooltip doesn't work very well here
    :makeToggleButton(0, 0, 30, 28, type + 1, self.openMessage, nil, self.dismissMessage)
  -- The emergency has a rotating siren
  if type == 43 then
    self.rotator = {}
    for i = 57, 60 do
      self.rotator[i] = self:addPanel(i, 10, 8)
      self.rotator[i].visible = false
    end
    self.active = 57
  end
end

function UIMessage:draw(canvas, x, y)
  if self.on_top then
    Window.draw(self, canvas, x, y)
  else
    local x_, y_, w, h = canvas:getClip()
    canvas:setClip(x_, y + self.stop_y, w, self.height, true)
    Window.draw(self, canvas, x, y)
    canvas:setClip(x_, y_, w, h)
  end
end

function UIMessage:close(...)
  assert(self.onClose == nil, "UIMessage closed improperly")
  return Window.close(self, ...)
end

-- Adjust the toggle state to match if the message is open or not
function UIMessage:adjustToggle()
  if self.button.toggled and not self.fax
  or not self.button.toggled and self.fax then
    self.button:toggle()
  end
end

function UIMessage:openMessage()
  if self.type == "strike" then -- strikes are special cases, as they are not faxes
    self.ui:addWindow(UIStaffRise(self.ui, self.owner, self.message))
    self:removeMessage()
  else
    if self.fax then
      self.fax:close()
    else
      self.fax = UIFax(self.ui, self)
      self.ui:addWindow(self.fax)
      self.ui:playSound("fax_in.wav")
    end
    -- Manual adjustion of toggle state is necessary if owner's message_callback was used
    self:adjustToggle()
  end
end

-- Removes the Message, executing a choice if given, else just deletes it
--!param choice_number (number) if given, removes the message by executing this choice.
function UIMessage:removeMessage(choice_number)
  if choice_number then
    if not self.fax then
      self.fax = UIFax(self.ui, self) -- NB: just create, don't add to ui
    end
    self.fax:choice(self.message.choices[choice_number].choice)
  else
    if self.fax then
      self.fax:close()
    end
    if self.owner and self.owner.message_callback then
      self.owner.message_callback = nil
    end
    self:onClose(false)
    self.onClose = nil
    self:close()
  end
end

-- Tries to dismiss the message. This is only possible if there is only one choice.
function UIMessage:dismissMessage()
  if self.can_dismiss then
    self:removeMessage(1)
  else
    self.ui:playSound("wrong2.wav")
    self:adjustToggle()
  end
end

function UIMessage:setXLimit(stop_x)
  assert(stop_x <= self.stop_x, "UIMessage moved in wrong direction")
  self.stop_x = stop_x
end

function UIMessage:onTick()
  if self.on_top == false and self.y == self.stop_y then
    self.on_top = true
  end
  if self.y > self.stop_y then
    local y = self.y - 8
    if y > self.stop_y then
      self.y = y
    else
      self.y = self.stop_y
    end
  elseif self.x > self.stop_x then
    local x = self.x - 3
    if x > self.stop_x then
      self.x = x
    else
      self.x = self.stop_x
    end
  end
end

function UIMessage:onWorldTick()
  if self.timer then
    self.timer = self.timer - 1
    if self.timer <= 0 then
      self.timer = nil
      self:removeMessage(self.default_choice)
    end
  end
  if self.active then
    self.rotator[self.active].visible = false
    if self.active == 60 then
      self.active = 57
    else
      self.active = self.active + 1
    end
    self.rotator[self.active].visible = true
  end
end

function UIMessage:afterLoad(old, new)
  if old < 21 then
    -- self.button added; however check for existence first
    -- since the savegame bump was a couple of revisions later
    if not self.button then
      self.button = self.buttons[1]
    end
  end
  Window.afterLoad(self, old, new)
end
