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

--! Dialog for purchasing `Object`s (for the corridor or for rooms).
class "UIFurnishCorridor" (Window)

function UIFurnishCorridor:UIFurnishCorridor(ui, objects, edit_dialog)
  self:Window()
  
  local app = ui.app
  if edit_dialog then
    self.modal_class = "furnish"
    self.edit_dialog = edit_dialog
  else
    self.modal_class = "main"
  end
  self.esc_closes = true
  self.ui = ui
  self.anims = app.anims
  self.width = 360
  self.height = 274
  self:setDefaultPosition(0.5, 0.4)
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req10V", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  self.blue_font = app.gfx:loadFont("QData", "Font02V")
  self.title_text = _S.buy_objects_window.choose_items
  self.price_text = (_S.buy_objects_window.price .. " "):gsub("  $", " ")
  self.total_text = (_S.buy_objects_window.total .. " "):gsub("  $", " ")
  self.item_price = 0
  self.total_price = 0
  
  self.list_hover_index = 0
  self.preview_anim = TH.animation()
  
  self.objects = {
  }
  if objects then
    for _, object in pairs(objects) do
      self.objects[#self.objects + 1] = {object = object.object, start_qty = object.qty, qty = object.qty, min_qty = object.min_qty} -- Had to make a copy of objects list. Otherwise, we will modify the original variable (Opening dialog twice keeps memory of previously choosen quantities)
    end
  else
    for _, object in ipairs(app.objects) do
      if object.corridor_object then
        self.objects[#self.objects + 1] = {object = object, start_qty = 0, qty = 0, min_qty = 0}
      end
    end
    table.sort(self.objects, function(o1, o2)
      return o1.object.corridor_object < o2.object.corridor_object
    end)
  end
  
  self:addPanel(228, 0, 0) -- Grid top
  for y = 33, 103, 10 do
    self:addPanel(229, 0, y) -- Grid body
  end
  self:addPanel(230, 0, 113) -- Grid bottom
  self:addPanel(231, 0, 148) -- Cost / total top
  self:addPanel(232, 0, 173) -- Cost / total body
  self:addPanel(233, 0, 215) -- Cost / total bottom
  self:addPanel(234, 0, 248) -- Close button background
  self:addPanel(234, 0, 252) -- Close button background extension
  self:addPanel(242, 9, 237):makeButton(0, 0, 129, 28, 243, self.close):setTooltip(_S.tooltip.buy_objects_window.cancel)
  
  self:addPanel(235, 146, 0) -- List top
  self:addPanel(236, 146, 223) -- List bottom
  self:addPanel(237, 154, 238):makeButton(0, 0, 197, 28, 238, self.confirm):setTooltip(_S.tooltip.buy_objects_window.confirm)
  local i = 1
  local function item_callback(index, qty)
    return --[[persistable:furnish_corridor_item_callback]] function(self)
      if self:purchaseItem(index, qty) == 0 then
        self.ui:playSound "wrong2.wav"
      elseif qty > 0 then
        self.ui:playSound "AddItemJ.wav"
      else
        self.ui:playSound "DelItemJ.wav"
      end
    end
  end
  for y = 34, 205, 19 do
    local x = 146
    self:addPanel(239, x, y) -- List body
    if i <= #self.objects then
      self:addPanel(240, x + 12, y):makeButton(0, 0, 125, 19, 241, item_callback(i, 1), nil, item_callback(i, -1)):setTooltip(self.objects[i].object.tooltip)
      self:addPanel(244, x + 139, y + 1):makeButton(0, 0, 17, 17, 245, item_callback(i, -1)):setTooltip(_S.tooltip.buy_objects_window.decrease)
      self:addPanel(246, x + 183, y + 1):makeButton(0, 0, 17, 17, 247, item_callback(i, 1)):setTooltip(_S.tooltip.buy_objects_window.increase)
    end
    i = i + 1
  end
  
  self:makeTooltip(_S.tooltip.buy_objects_window.price,       20, 168, 127, 187)
  self:makeTooltip(_S.tooltip.buy_objects_window.total_value, 20, 196, 127, 215)

  self:addKeyHandler("Enter", self.confirm)
end

function UIFurnishCorridor:purchaseItem(index, quantity)
  local o = self.objects[index]
  if self.buttons_down.ctrl then
    quantity = quantity * 10
  elseif self.buttons_down.shift then
    quantity = quantity * 5
  end
  quantity = quantity + o.qty
  if quantity < o.min_qty then
    quantity = o.min_qty
  elseif quantity > 99 then
    quantity = 99
  end
  quantity = quantity - o.qty
  if self.ui.hospital.balance >= self.total_price + quantity * o.object.build_cost then
    o.qty = o.qty + quantity
    self.total_price = self.total_price + quantity * o.object.build_cost
    if o.object.id == "reception_desk" then
      if o.qty > 0 then
        self.ui:tutorialStep(1, 2, 3)
      else
        self.ui:tutorialStep(1, 3, 2)
      end
    end
  else
    quantity = 0
  end
  return quantity
end

function UIFurnishCorridor:confirm()
  self.ui:tutorialStep(1, 3, 4)
  
  local to_purchase = {}
  local to_sell = {}
  for i, o in ipairs(self.objects) do
    if o.qty - o.start_qty > 0 then
      local diff_qty = o.qty - o.start_qty
      to_purchase[#to_purchase + 1] = { object = o.object, qty = diff_qty }
      self.ui.hospital:spendMoney(o.object.build_cost * diff_qty, _S.transactions.buy_object .. ": " .. o.object.name, o.object.build_cost * diff_qty)
    elseif o.qty - o.start_qty < 0 then
      local diff_qty = o.start_qty - o.qty
      to_sell[#to_sell + 1] = { object = o.object, qty = diff_qty }
      self.ui.hospital:receiveMoney(o.object.build_cost * diff_qty, _S.transactions.sell_object .. ": " .. o.object.name, o.object.build_cost * diff_qty)
    end
  end
  
  if self.edit_dialog then
    self.edit_dialog:addObjects(to_purchase, false) -- payment already handled here
    self.edit_dialog:removeObjects(to_sell, false) -- payment already handled here
    self:close()
  else
    if #to_purchase == 0 then
      self:close()
    else
      self.ui:addWindow(UIPlaceObjects(self.ui, to_purchase))
    end
  end
end

function UIFurnishCorridor:close()
  self.ui:tutorialStep(1, {2, 3}, 1)
  if self.edit_dialog then
    self.edit_dialog:addObjects() -- No objects added. Call the function anyway to handle visibility etc.
  end
  Window.close(self)
end

function UIFurnishCorridor:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  
  x, y = x + self.x, y + self.y
  self.white_font:draw(canvas, self.title_text, x + 163, y + 18)
  self.white_font:draw(canvas, self.price_text .. self.item_price, x + 24, y + 173)
  self.white_font:draw(canvas, self.total_text .. self.total_price, x + 24, y + 202)
  
  for i, o in ipairs(self.objects) do
    local font = self.white_font
    if i == self.list_hover_index then
      font = self.blue_font
    end
    font:draw(canvas, o.object.name, x + 163, y + 20 + i * 19)
    font:draw(canvas, o.qty, x + 306, y + 20 + i * 19, 19, 0)
  end
  
  self.preview_anim:draw(canvas, x + 72, y + 57)
end

function UIFurnishCorridor:onMouseMove(x, y, dx, dy)
  local repaint = Window.onMouseMove(self, x, y, dx, dy)
  
  local hover_idx = 0
  if 158 <= x and x < 346 and 34 <= y and y < 224 then
    hover_idx = math_floor((y - 15) / 19)
  end
  
  if hover_idx ~= self.list_hover_index then
    if 1 <= hover_idx and hover_idx <= #self.objects then
      local obj = self.objects[hover_idx].object
      self.item_price = obj.build_cost
      self.preview_anim:setAnimation(self.anims, obj.build_preview_animation)
    end
    self.list_hover_index = hover_idx
    repaint = true
  end
  
  return repaint
end
