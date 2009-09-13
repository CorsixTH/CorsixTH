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

local ipairs, math_floor, unpack, select, assert
    = ipairs, math.floor, unpack, select, assert

-- Menu strings are organised an extra level beyond normal strings
local _M = {{}}
do
  local i = 2
  local section = 1
  while true do
    local s = _S(23, i)
    if s == "." then
      section = section + 1
      _M[section] = {}
    elseif s == ".." then
      break
    else
      --print(section, #_M[section] + 1, s)
      _M[section][#_M[section] + 1] = s
    end
    i = i + 1
  end
end

local function _S(section, index)
  section = _M[section]
  if index < 0 then
    return section[#section + 1 + index]
  else
    return section[index]
  end
end

class "UIMenuBar" (Window)

function UIMenuBar:UIMenuBar(ui)
  self:Window()
  
  local app = ui.app
  self.ui = ui
  self.x = 0
  self.y = 0
  self.width = app.config.width
  self.height = 16
  self.visible = false
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "PullDV", true)
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  self.blue_font = app.gfx:loadFont("QData", "Font02V")
  self.menus = {}
  self.active_menu = false
  
  self:makeMenu(app)
end

function UIMenuBar:addMenu(title, menu)
  local menu = {
    title = title,
    menu = menu,
    x = 0,
    y = 0,
    height = 16,
  }
  if self.menus[1] then
    menu.x = self.menus[#self.menus].x + self.menus[#self.menus].width
  end
  menu.width = self.white_font:sizeOf(title) + 32
  self.menus[#self.menus + 1] = menu
end

function UIMenuBar:draw(canvas)
  if not self.visible then
    return
  end
  local panel_sprites = self.panel_sprites
  local panel_sprites_draw = panel_sprites.draw
  canvas:nonOverlapping()
  panel_sprites_draw(panel_sprites, canvas, 1, 0,  0)
  panel_sprites_draw(panel_sprites, canvas, 4, 0,  6)
  panel_sprites_draw(panel_sprites, canvas, 7, 0, 10)
  for x = 10, self.width - 10, 10 do
    panel_sprites_draw(panel_sprites, canvas, 2, x,  0)
  end
  for x = 10, self.width - 10, 10 do
    panel_sprites_draw(panel_sprites, canvas, 5, x,  6)
  end
  for x = 10, self.width - 10, 10 do
    panel_sprites_draw(panel_sprites, canvas, 8, x, 10)
  end
  canvas:nonOverlapping(false)
  local x = self.width - 10
  panel_sprites_draw(panel_sprites, canvas, 3, x,  0)
  panel_sprites_draw(panel_sprites, canvas, 6, x,  6)
  panel_sprites_draw(panel_sprites, canvas, 9, x, 10)
  
  for _, menu in ipairs(self.menus) do
    self.white_font:draw(canvas, menu.title, menu.x, menu.y, 0, menu.height)
  end
  if self.active_menu then
    self:drawMenu(self.active_menu, canvas)
  end
end

function UIMenuBar:drawMenu(menu, canvas)
  if menu.parent then
    self:drawMenu(menu.parent, canvas)
  end
  local child = nil
  local panel_sprites = self.panel_sprites
  local panel_sprites_draw = panel_sprites.draw
  local x, y, w, h = menu.x, menu.y, menu.width, menu.height
  canvas:nonOverlapping()
  panel_sprites_draw(panel_sprites, canvas, 1, x, y)
  for x = x + 10, x + w - 10, 10 do
    panel_sprites_draw(panel_sprites, canvas, 2, x, y)
  end
  for y = y + 6, y + h - 6, 4 do
    panel_sprites_draw(panel_sprites, canvas, 4, x, y)
    for x = x + 10, x + w - 10, 10 do
      panel_sprites_draw(panel_sprites, canvas, 5, x, y)
    end
  end
  local btmy = y + h - 6
  panel_sprites_draw(panel_sprites, canvas, 7, x, btmy)
  for x = x + 10, x + w - 10, 10 do
    panel_sprites_draw(panel_sprites, canvas, 8, x, btmy)
  end
  canvas:nonOverlapping(false)
  panel_sprites_draw(panel_sprites, canvas, 3, x + w - 10, y)  
  for y = y + 6, y + h - 6, 4 do
    panel_sprites_draw(panel_sprites, canvas, 6, x + w - 10, y)
  end
  panel_sprites_draw(panel_sprites, canvas, 9, x + w - 10, btmy)
  
  x = menu.x
  y = menu.y + 4
  for i, item in ipairs(menu.items) do
    local font = self.white_font
    if i == menu.hover_index then
      font = self.blue_font
      child = item.submenu
    end
    font:draw(canvas, item.title, x, y)
    if item.submenu then
      font:draw(canvas, "+", x + w - 10, y)
    elseif item.checked then
      panel_sprites_draw(panel_sprites, canvas, 10, x, y)
    end
    y = y + 14
  end
  
  if child and child.x then
    child.hover_index = 0
    child.parent = nil
    self:drawMenu(child, canvas)
  end
end

function UIMenuBar:hitTestBar(x, y)
  if y < 16 then
    for _, menu in ipairs(self.menus) do
      if menu.x <= x and x < menu.x + menu.width then
        local submenu = menu.menu
        submenu.x = menu.x
        submenu.y = menu.y + menu.height - 2
        submenu.hover_index = 0
        self:calculateMenuSize(submenu)
        return submenu
      end
    end
  end
  return false
end

function UIMenuBar:onMouseMove(x, y)
  local padding = 6
  local visible = y < self.height + padding
  local newactive = false
  if self.active_menu then
    local menu = self.active_menu
    while true do
      local hit = menu:hitTest(x, y, padding)
      local toparent = true
      if hit then
        toparent = false
        visible = true
        if hit ~= true then
          menu.hover_index = hit
        else
          menu.hover_index = 0
          if menu.parent and menu.parent:hitTest(x, y, 0) then
            toparent = true
          end
        end
        local child = menu.items[menu.hover_index]
        child = not toparent and child and child.submenu
        if child then
          child.x = menu.x + menu.width - 10
          child.y = menu.y + menu.hover_index * 14 - 14
          self:calculateMenuSize(child)
          if child:hitTest(x, y, 0) then
            menu.hover_index = 0
            self.active_menu = child
            child.parent = menu
            menu = child
            newactive = true
          else
            break
          end
        elseif not toparent then
          break
        end
      end
      if toparent then
        newactive = true
        menu.hover_index = 0
        menu = menu.parent
        if not menu then
          self.active_menu = self:hitTestBar(x, y) or (visible and self.active_menu)
          break
        end
        self.active_menu = menu
      end
    end
  end
  if visible ~= self.visible then
    self.visible = visible
    return true
  end
  return newactive
end

function UIMenuBar:onMouseDown(button, x, y)
  if button ~= "left" or not self.visible then
    return
  end
  local repaint = false
  while self.active_menu do
    local menu = self.active_menu
    if menu.x <= x and x < menu.x + menu.width and menu.y <= y and y < menu.y + menu.height then
      if repaint then
        self:onMouseMove(x, y)
      end
      return repaint
    end
    self.active_menu = menu.parent
    repaint = true
  end
  local new_active = self:hitTestBar(x, y)
  if new_active ~= self.active_menu then
    self.active_menu = new_active
    repaint = true
  end
  return repaint
end

function UIMenuBar:onMouseUp(button, x, y)
  if button ~= "left" or not self.visible then
    return
  end
  while self.active_menu do
    local index = self.active_menu:hitTest(x, y, 0)
    if index == false then
      if not self.active_menu.parent and y < 16 then
        return
      else
        self.active_menu = self.active_menu.parent
      end
    elseif index == true then
      return
    else
      local item = self.active_menu.items[index]
      if item.submenu then
        return
      elseif item.is_check_item then
        if item.group then
          if not item.checked then
            item.checked = true
            for _, itm in ipairs(self.active_menu.items) do
              if itm ~= item and itm.group == item.group then
                itm.checked = false
              end
            end
            if item.handler then
              item.handler(item, self.active_menu)
            end
          end
        else
          item.checked = not item.checked
          if item.handler then
            item.handler(item, self.active_menu)
          end
        end
      else
        if item.handler then
          item.handler(item, self.active_menu)
        end
        if y > 22 then
          self.visible = false
        end
        self.active_menu = false
      end
      return true
    end
  end
end

function UIMenuBar:calculateMenuSize(menu)
  if menu.has_size ~= self then
    local w = 20
    local h = 6
    for _, item in ipairs(menu.items) do
      local item_w = self.white_font:sizeOf(item.title) + 10
      if item_w > w then
        w = item_w
      end
      h = h + 14
    end
    if h < 20 then
      h = 20
    end
    menu.width = w
    menu.height = h
    menu.has_size = self
  end
end

class "UIMenu"

function UIMenu:UIMenu()
  self.items = {}
  self.parent = false
  self.hover_index = 0
  self.has_size = false
end

function UIMenu:hitTest(x, y, padding)
  -- number -> hit that item
  -- true   -> hit menu, but not an item
  -- false  -> no hit
  if self.x - padding <= x and x < self.x + self.width + padding
  and self.y - padding <= y and y < self.y + self.height + padding then
    if self.x <= x and x < self.x + self.width then
      local index = math_floor((y - self.y + 12) / 14)
      if 1 <= index and index <= #self.items then
        return index
      end
    end
    return true
  else
    return false
  end
end

function UIMenu:appendBase(item)
  self.items[#self.items + 1] = item
  self.has_size = false
  return self
end

function UIMenu:appendItem(text, callback)
  return self:appendBase {
    title = text,
    handler = callback,
  }
end

function UIMenu:appendCheckItem(text, checked, callback, group)
  return self:appendBase {
    is_check_item = true,
    title = text,
    checked = not not checked,
    handler = callback,
    group = group,
  }
end

function UIMenu:appendMenu(text, menu)
  menu.parent = self
  return self:appendBase {
    title = text,
    submenu = assert(menu, "No submenu"),
  }
end

function UIMenuBar:makeMenu(app)
  local levels_menu = UIMenu()
  for L = 1, 12 do
    levels_menu:appendItem(("  L%i  "):format(L), function()
      app:loadLevel(("LEVEL.L%i"):format(L))
    end)
  end
  local function quit()
    app.running = false
  end
  
  self:addMenu(_S(1, 1), UIMenu() -- File
    :appendMenu(_S(2, 1), levels_menu) -- Load
    :appendItem(_S(2, -1), quit) -- Quit
  )
  local options = UIMenu()
  if app.audio.has_bg_music then
    local function vol(level)
      return level == app.audio.bg_music_volume,
        function()
          app.audio:setBackgroundVolume(level)
        end,
        ""
    end
    options
    :appendCheckItem(_S(3, 3), true) -- Music
    :appendMenu(_S(3, 6), UIMenu() -- Music Volume
      :appendCheckItem(_S(9, 1), vol(1.0)) -- 100%
      :appendCheckItem(_S(9, 2), vol(0.9))
      :appendCheckItem(_S(9, 3), vol(0.8))
      :appendCheckItem(_S(9, 4), vol(0.7))
      :appendCheckItem(_S(9, 5), vol(0.6))
      :appendCheckItem(_S(9, 6), vol(0.5))
      :appendCheckItem(_S(9, 7), vol(0.4))
      :appendCheckItem(_S(9, 8), vol(0.3))
      :appendCheckItem(_S(9, 9), vol(0.2))
      :appendCheckItem(_S(9,10), vol(0.1)) -- 10%
    )
    :appendItem(_S(3, -1), function() self.ui:addWindow(UIJukebox(app)) end) -- Jukebox
  end
  self:addMenu(_S(1, 2), options) -- Options
  self:addMenu(_S(1, 4), UIMenu() -- Charts
    :appendItem(_S(5, 1)) -- Statement
    :appendItem(_S(5, 2)) -- Casebook
    :appendItem(_S(5, 3)) -- Policy
    :appendItem(_S(5, 4)) -- Research
    :appendItem(_S(5, 5)) -- Graphs
    :appendItem(_S(5, 6)) -- Staff listing
    :appendItem(_S(5, 7)) -- Bank manager
    :appendItem(_S(5, 8)) -- Status
  )
  local function _(s) return "  " .. s:upper() .. "  " end
  local function transparent_walls(item)
    app.map.th:setWallDrawFlags(item.checked and 4 or 0)
  end
  local function overlay(...)
    local args = {n = select('#', ...), ...}
    return function(item, menu)
      if args.n > 0 then
        app.map:loadDebugText(unpack(args, 1, args.n))
      else
        app.map:clearDebugText()
      end
    end
  end
  local function place_objs()
    self.ui:addWindow(UIPlaceObjects(self.ui, {
      {object = TheApp.objects.radiator, qty = 5},
      {object = TheApp.objects.plant, qty = 5},
      {object = TheApp.objects.bench, qty = 5},
      {object = TheApp.objects.drinks_machine, qty = 5},
      {object = TheApp.objects.reception_desk, qty = 5},
      {object = TheApp.objects.extinguisher, qty = 5},
    }))
  end
  local function limit_camera(item)
    app.ui.limit_to_visible_diamond = item.checked
    app.ui:scrollMap(0, 0)
  end
  self:addMenu(_S(1, 5), UIMenu() -- Debug
    :appendCheckItem(_"Transparent walls", false, transparent_walls)
    :appendCheckItem(_"Limit camera", true, limit_camera)
    :appendItem(_"Make Patients", function() self.ui:debugMakePatients() end)
    :appendItem(_"Show Adviser", function() self.ui.adviser:show() end)
    :appendItem(_"Hide Adviser", function() self.ui.adviser:hide() end)
    :appendItem(_"Make Adviser Talk", function() self.ui:debugMakeAdviserTalk() end)
    :appendItem(_"Place Objects",place_objs)
    :appendMenu(_"Map overlay", UIMenu()
      :appendCheckItem(_"None", true, overlay(), "")
      :appendCheckItem(_"Flags", false, overlay"flags", "")
      :appendCheckItem(_"Byte 0 & 1", false, overlay(35, 8, 0, 1, false), "")
      :appendCheckItem(_"Byte Floor", false, overlay(35, 8, 2, 2, false), "")
      :appendCheckItem(_"Byte N Wall", false, overlay(35, 8, 3, 3, false), "")
      :appendCheckItem(_"Byte W Wall", false, overlay(35, 8, 4, 4, false), "")
      :appendCheckItem(_"Byte 5", false, overlay(35, 8, 5, 5, true), "")
      :appendCheckItem(_"Byte 6", false, overlay(35, 8, 6, 6, true), "")
      :appendCheckItem(_"Byte 7", false, overlay(35, 8, 7, 7, true), "")
      :appendCheckItem(_"Parcel", false, overlay(131107, 2, 0, 0, false), "")
    )
    :appendItem(_"Sprite viewer", function() dofile "sprite_viewer" end)
  )
end
