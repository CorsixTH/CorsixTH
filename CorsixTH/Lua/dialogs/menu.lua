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
local TH = require("TH")

--! The ingame menu bar which sits (nominally hidden) at the top of the screen.
class "UIMenuBar" (Window)

---@type UIMenuBar
local UIMenuBar = _G["UIMenuBar"]

function UIMenuBar:UIMenuBar(ui, map_editor)
  self:Window()

  local app = ui.app
  self.ui = ui
  self.on_top = true
  self.x = 0
  self.y = 0
  self.width = app.config.width
  self.height = 16
  self.visible = false
  local selected_label_color = { red = 40, green = 40, blue = 250 }
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "PullDV", true)
  self.white_font = app.gfx:loadFontAndSpriteTable("QData", "Font01V")
  self.blue_font = app.gfx:loadFontAndSpriteTable("QData", "Font02V", nil, nil, 0, 0, selected_label_color)
  -- The list of top-level menus, from left to right
  self.menus = {}
  -- The menu which the cursor was most recently over
  -- This should be present in self.open_menus, else it won't be drawn
  self.active_menu = false
  -- The list of menus which should be displayed
  -- This list satisfies: open_menus[x] == nil or open_menus[x].level == x
  self.open_menus = {}

  if map_editor then
    self:makeMapeditorMenu(app)
  else
    self:makeGameMenu(app)
  end
end

function UIMenuBar:onTick()
  if #self.open_menus > 0 then
    -- If the deepest menu has no need to be open, close it after a short time
    -- It needs to be open if the cursor is over it, or the cursor is over the
    -- item in its parent corresponding to it.
    local deepest = self.open_menus[#self.open_menus]
    local parent = deepest.parent
    if deepest == self.active_menu or
        (parent and parent == self.active_menu and parent.items[parent.hover_index] and
        parent.items[parent.hover_index].submenu == deepest) then
      self.menu_disappear_counter = nil
    else
      if self.menu_disappear_counter == 0 then
        self.ui.app:saveConfig()
        self.menu_disappear_counter = nil
        local close_to = self.active_menu and self.active_menu.level or 0
        for i = #self.open_menus, close_to + 1, -1 do
          self.open_menus[i] = nil
        end
      else
        self.menu_disappear_counter = (self.menu_disappear_counter or 26) - 1
      end
    end
  end
  if self.disappear_counter then
    if self.disappear_counter == 0 then
      for i = #self.open_menus, 1, -1 do
        self.open_menus[i] = nil
      end
      self.active_menu = false
      self.visible = false
      self.disappear_counter = nil
      if self.on_top then
        self.ui:sendToBottom(self)
        self.on_top = false
      end
    else
      self.disappear_counter = self.disappear_counter - 1
    end
  end
  Window.onTick(self)
end

function UIMenuBar:onChangeResolution()
  self.width = self.ui.app.config.width
end

function UIMenuBar:onChangeLanguage()
  local function check_size(menu)
    menu.has_size = false
    for _, item in ipairs(menu.items) do
      if item.submenu then
        check_size(item.submenu)
      end
    end
  end
  for _, menu in ipairs(self.menus) do
    check_size(menu.menu)
  end
end

local function assign_menu_levels(menu, level)
  menu.level = level
  for _, item in ipairs(menu.items) do
    if item.submenu then
      assign_menu_levels(item.submenu, level + 1)
    end
  end
end

--! Add a menu to the menu bar.
--!param title Title of the menu (at the bar).
--!param menu Menu to add.
function UIMenuBar:addMenu(title, menu)
  assign_menu_levels(menu, 1)
  local menu_item = {
    title = title,
    menu = menu,
    x = 0,
    y = 0,
    height = 16,
  }
  if self.menus[1] then
    menu_item.x = self.menus[#self.menus].x + self.menus[#self.menus].width
  end
  menu_item.width = self.white_font:sizeOf(title) + 32
  self.menus[#self.menus + 1] = menu_item
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
  for _, menu in ipairs(self.open_menus) do
    self:drawMenu(menu, canvas)
  end

  -- Draw clock
  if self.ui.app.config.twentyfour_hour_clock then
    self.white_font:draw(canvas, os.date("%H:%M"), self.width-45, 2,  0)
  else
    self.white_font:draw(canvas, os.date("%I:%M %p"), self.width-65, 2,  0)
  end
end

function UIMenuBar:drawMenu(menu, canvas)
  local panel_sprites = self.panel_sprites
  local panel_sprites_draw = panel_sprites.draw
  local x, y, w, h = menu.x, menu.y, menu.width, menu.height
  canvas:nonOverlapping()
  menu.render_list:draw(canvas, x, y)
  canvas:nonOverlapping(false)
  local btmy = y + h - 6
  panel_sprites_draw(panel_sprites, canvas, 3, x + w - 10, y)
  for ypos = y + 6, y + h - 6, 4 do
    panel_sprites_draw(panel_sprites, canvas, 6, x + w - 10, ypos)
  end
  panel_sprites_draw(panel_sprites, canvas, 9, x + w - 10, btmy)

  x = menu.x
  y = menu.y + 4
  for i, item in ipairs(menu.items) do
    -- Update the checkbox status if necessary before drawing
    if item.is_check_item and item.condition then
      item.checked = item.condition()
    end

    local font = self.white_font
    if i == menu.hover_index then
      font = self.blue_font
    end
    font:draw(canvas, item.title, x, y)
    if item.submenu then
      font:draw(canvas, "+", x + w - 10, y)
    elseif item.checked then
      panel_sprites_draw(panel_sprites, canvas, 10, x, y)
    end
    y = y + 14
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

function UIMenuBar:onMouseMove(x, y, dx, dy)
  local padding = 6
  local visible = y < self.height + padding
  local newactive = false
  if not self.active_menu then
    for i = #self.open_menus, 1, -1 do
      if self.open_menus[i]:hitTest(x, y, padding) then
        self.active_menu = self.open_menus[i]
        newactive = true
        break
      end
    end
  end
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
          self.open_menus[child.level] = child
          for i = #self.open_menus, child.level + 1, -1 do
            self.open_menus[i] = nil
          end
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
          local bar_menu = self:hitTestBar(x, y)
          if bar_menu then
            self.open_menus = {bar_menu}
          end
          self.active_menu = bar_menu or (visible and self.active_menu)
          break
        end
        self.active_menu = menu
      end
    end
  elseif self.ui.down_count ~= 0 then
    local bar_menu = self:hitTestBar(x, y)
    if bar_menu then
      self.open_menus = {bar_menu}
      self.active_menu = bar_menu
    end
  end
  newactive = newactive or (visible and not self.visible)
  if visible then
    self:appear()
  else
    self:disappear()
  end
  return newactive
end

function UIMenuBar:appear()
  self.disappear_counter = nil
  self.visible = true
  if not self.on_top then
    self.ui:sendToTop(self)
    self.on_top = true
  end
end

function UIMenuBar:disappear()
  if not self.disappear_counter then
    self.disappear_counter = 100
  end
end

function UIMenuBar:onMouseDown(button, x, y)
  if button ~= "left" or not self.visible then
    return
  end
  local repaint = false
  while self.active_menu do
    local menu = self.active_menu
    if menu:hitTest(x, y, 0) then
      if repaint then
        self:onMouseMove(x, y)
      end
      return true
    end
    for i = #self.open_menus, self.active_menu.level, -1 do
      self.open_menus[i] = nil
    end
    self.active_menu = menu.parent
    repaint = true
  end
  local new_active = self:hitTestBar(x, y)
  if new_active ~= self.active_menu then
    self.open_menus = {new_active}
    self.active_menu = new_active
    repaint = true
    self.ui:playSound("selectx.wav")
  end
  return repaint
end

function UIMenuBar:onMouseUp(button, x, y)
  if button ~= "left" or not self.visible then
    return
  end
  local repaint = false
  while self.active_menu do
    local index = self.active_menu:hitTest(x, y, 0)
    if index == false then
      if not self.active_menu.parent and y < 16 then
        break
      else
        self.active_menu = self.active_menu.parent
      end
    elseif index == true then
      break
    else
      local item = self.active_menu.items[index]
      if item.submenu then
        break
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
          self:disappear()
        end
        self.active_menu = false
      end
      self.ui:playSound("selectx.wav")
      repaint = true
      break
    end
  end
  for i = #self.open_menus, (self.active_menu and self.active_menu.level or 0) + 1, -1 do
    self.open_menus[i] = nil
  end
  return repaint
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
    local render_list = TH.spriteList()
    menu.render_list = render_list
    render_list:setSheet(self.panel_sprites)

    render_list:append(1, 0, 0)
    for x = 10, w - 10, 10 do
      render_list:append(2, x, 0)
    end
    for y = 6, h - 6, 4 do
      render_list:append(4, 0, y)
      for x = 10, w - 10, 10 do
        render_list:append(5, x, y)
      end
    end
    local btmy = h - 6
    render_list:append(7, 0, btmy)
    for x = 10, w - 10, 10 do
      render_list:append(8, x, btmy)
    end

  end
end

class "UIMenu"

---@type UIMenu
local UIMenu = _G["UIMenu"]

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
  if self.x - padding <= x and x < self.x + self.width + padding and
      self.y - padding <= y and y < self.y + self.height + padding then
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

function UIMenu:appendCheckItem(text, checked, callback, group, condition)
  return self:appendBase {
    is_check_item = true,
    title = text,
    checked = not not checked,
    handler = callback,
    group = group,
    condition = condition
  }
end

function UIMenu:appendMenu(text, menu)
  menu.parent = self
  return self:appendBase {
    title = text,
    submenu = assert(menu, "No submenu"),
  }
end

-- A function to set the menu hotkey strings, whether a string or table.
-- Usage: hotkey_value_label(hotkey name as string)
-- Ex: hotkey_value_label("ingame_loadMenu") will produce (SHIFT+L) by default.
--!param hotkey_name (string) Name of hotkey to be converted to string.
--!param hotkeys (table) The app's hotkey table. I.E. app.hotkeys
--!return (string) The hotkey returned in this format: (KEY+KEY)
local function hotkey_value_label(hotkey_name, hotkeys)
  local hotkey_value = hotkeys[hotkey_name]
  if hotkey_value == nil then
    return ""
  end
  return string.upper(array_join(hotkey_value, "+"))
end

-- Add audio options to the menu. These are on/off and volume control for
-- announcements, game sounds and music, and open the jukebox.
--!param menu (object) The menu that the options are added to.
--!param game (boolean) True if this menu is for the game, where announcements and
-- game sounds controls are added.
local function audio_options(menu, game)
  local app = TheApp

  local function vol(level, setting)
    if setting == "music" then
      return level == app.config.music_volume,
        function()
          app.audio:setBackgroundVolume(level)
        end,
        ""
    elseif setting == "sound" then
      return level == app.config.sound_volume,
        function()
          app.audio:setSoundVolume(level)
        end,
        ""
    else
      return level == app.config.announcement_volume,
        function()
          app.audio:setAnnouncementVolume(level)
        end,
        ""
    end
  end

  local hotkeys = app.hotkeys
  if game then
    -- Hospital sounds
    menu:appendCheckItem(_S.menu_options.sound:format(hotkey_value_label("ingame_toggleSounds", hotkeys)),
      app.config.play_sounds,
      function(item)
        app.audio:playSoundEffects(item.checked)
      end,
      nil,
      function()
        return app.config.play_sounds
      end)

    -- Hospital announcements
    menu:appendCheckItem(_S.menu_options.announcements:format(hotkey_value_label("ingame_toggleAnnouncements", hotkeys)),
      app.config.play_announcements,
      function(item)
        app.config.play_announcements = item.checked
      end,
      nil,
      function()
        return app.config.play_announcements
      end)
  end

  -- Jukebox music
  if app.audio.has_bg_music then
    menu:appendCheckItem(_S.menu_options.music:format(hotkey_value_label("ingame_toggleMusic", hotkeys)),
      app.config.play_music,
      function(item)
        app.config.play_music = item.checked
        app.ui:togglePlayMusic(item)
      end,
      nil,
      function()
        return app.config.play_music
      end)
  end

  -- The three volume menus, and jukebox
  local function appendVolume(setting)
    local volume_menu = UIMenu()
    for level = 10, 100, 10 do
      volume_menu:appendCheckItem(_S.menu_options_volume[level], vol(level / 100, setting))
    end
    return volume_menu
  end
  if game then
    menu:appendMenu(_S.menu_options.sound_vol, appendVolume("sound"))
      :appendMenu(_S.menu_options.announcements_vol, appendVolume("announcement"))
  end
  if app.audio.has_bg_music then
    menu:appendMenu(_S.menu_options.music_vol, appendVolume("music"))
      :appendItem(_S.menu_options.jukebox:format(hotkey_value_label("ingame_jukebox", hotkeys)),
          function() app.ui:addWindow(UIJukebox(app)) end)
  end
end

-- Add display options to the menu.
--!param menu (object) The menu that the options are added to.
local function display_options(menu)
  local app = TheApp

  -- Lock windows
  local function boolean_runtime_config(option)
    return not not app.runtime_config[option], function(item)
      app.runtime_config[option] = item.checked
    end
  end
  menu:appendCheckItem(_S.menu_options.lock_windows, boolean_runtime_config("lock_windows"))

  -- Edge scrolling
  menu:appendCheckItem(_S.menu_options.edge_scrolling,
    not app.config.prevent_edge_scrolling,
    function(item) app.config.prevent_edge_scrolling = not item.checked end,
    nil,
    function() return not app.config.prevent_edge_scrolling end)

  -- Mouse capture
  menu:appendCheckItem(_S.menu_options.capture_mouse,
    app.config.capture_mouse,
    function(item) app.config.capture_mouse = item.checked
      app:setCaptureMouse()
    end)

  -- 24 hour clock
  menu:appendCheckItem(_S.menu_options.twentyfour_hour_clock,
    app.config.twentyfour_hour_clock,
    function(item)
      app.config.twentyfour_hour_clock = item.checked
    end)
end

local function overlay(...)
  local args = {n = select('#', ...), ...}
  return function(item, m)
    if args.n > 0 then
      TheApp.map:loadDebugText(unpack(args, 1, args.n))
    else
      TheApp.map:clearDebugText()
    end
  end
end

--! Make a menu for the map editor.
--!param app Application.
function UIMenuBar:makeMapeditorMenu(app)
  local menu = UIMenu()
  local hotkeys = app.hotkeys

  menu:appendItem(_S.menu_file.load:format(hotkey_value_label("ingame_loadMenu", hotkeys)), function() self.ui:addWindow(UILoadMap(self.ui, "map")) end)
    :appendItem(_S.menu_file.save:format(hotkey_value_label("ingame_saveMenu", hotkeys)), function() self.ui:addWindow(UISaveMap(self.ui)) end)
    :appendItem(_S.menu_file.restart:format(hotkey_value_label("ingame_restartLevel", hotkeys)), function() self.ui:restartMapEditor() end)
    :appendItem(_S.menu_file.quit:format(hotkey_value_label("ingame_quitLevel", hotkeys)), function() self.ui:quit(true) end)
  self:addMenu(_S.menu.file, menu)

  menu = UIMenu()
  audio_options(menu)
  display_options(menu)

  menu:appendMenu(_S.menu_debug.map_overlay, UIMenu()
    :appendCheckItem(_S.menu_debug_overlay.none, true, overlay(), "overlay")
    :appendCheckItem(_S.menu_debug_overlay.flags, false, overlay("flags"), "overlay")
    :appendCheckItem(_S.menu_debug_overlay.positions, false, overlay("positions"), "overlay")
    :appendCheckItem(_S.menu_debug_overlay.parcel, false, overlay("parcel"), "overlay"))
  self:addMenu(_S.menu.options, menu)

  menu = UIMenu()
  for i = 1, 4 do
    menu:appendCheckItem(_S.menu_player_count["players_" .. i],
        self.ui.app.map:getPlayerCount() == i,
        function() self.ui.map_editor:setPlayerCount(i) end,
        "playercount",
        function () return self.ui.app.map:getPlayerCount() == i end)
  end
  self:addMenu(_S.menu.player_count, menu)
end

--! Make a menu for the game.
--!param app Application.
function UIMenuBar:makeGameMenu(app)
  local menu = UIMenu()
  local hotkeys = app.hotkeys

  menu:appendItem(_S.menu_file.load:format(hotkey_value_label("ingame_loadMenu", hotkeys)), function() self.ui:addWindow(UILoadGame(self.ui, "game")) end)
    :appendItem(_S.menu_file.save:format(hotkey_value_label("ingame_saveMenu", hotkeys)), function() self.ui:addWindow(UISaveGame(self.ui)) end)
    :appendItem(_S.menu_file.restart:format(hotkey_value_label("ingame_restartLevel", hotkeys)), function() app:restart() end)
    :appendItem(_S.menu_file.quit:format(hotkey_value_label("ingame_quitLevel", hotkeys)), function() self.ui:quit() end)
  self:addMenu(_S.menu.file, menu)

  local options = UIMenu()
  audio_options(options, true)
  display_options(options)

  options:appendCheckItem(_S.menu_options.adviser_disabled:format(hotkey_value_label("ingame_toggleAdvisor", hotkeys)),
    not app.config.adviser_disabled,
    function(item)
      app.config.adviser_disabled = not item.checked
    end,
    nil,
    function()
      return not app.config.adviser_disabled
    end)

  local function temperatureDisplay(method)
    return method == 1, function()
      app.world.map:setTemperatureDisplayMethod(method)
    end, "", function ()
      return app.world.map.temperature_display_method == method
    end
  end

  local function wageIncreaseRequests(grant)
    return grant, function()
      app.world:getLocalPlayerHospital().policies.grant_wage_increase = grant
    end, "", function ()
      if app.world:getLocalPlayerHospital().policies.grant_wage_increase == nil then
        app.world:getLocalPlayerHospital().policies.grant_wage_increase = app.config.grant_wage_increase
      end
      return app.world:getLocalPlayerHospital().policies.grant_wage_increase == grant
    end
  end

  options:appendMenu(_S.menu_options.wage_increase, UIMenu()
    :appendCheckItem(_S.menu_options_wage_increase.grant, wageIncreaseRequests(true))
    :appendCheckItem(_S.menu_options_wage_increase.deny, wageIncreaseRequests(false))
  )

  options:appendMenu(_S.menu_options.warmth_colors, UIMenu()
    :appendCheckItem(_S.menu_options_warmth_colors.choice_1, temperatureDisplay(1))
    :appendCheckItem(_S.menu_options_warmth_colors.choice_2, temperatureDisplay(2))
    :appendCheckItem(_S.menu_options_warmth_colors.choice_3, temperatureDisplay(3))
  )

  local function rate(speed)
    return speed == "Normal", function()
      app.world:setSpeed(speed)
    end, "", function()
      return app.world:isCurrentSpeed(speed)
    end
  end

  options:appendMenu(_S.menu_options.game_speed, UIMenu()
    :appendCheckItem(_S.menu_options_game_speed.pause:format(hotkey_value_label("ingame_pause", hotkeys)),                          rate("Pause"))
    :appendCheckItem(_S.menu_options_game_speed.slowest:format(hotkey_value_label("ingame_gamespeed_slowest", hotkeys)),             rate("Slowest"))
    :appendCheckItem(_S.menu_options_game_speed.slower:format(hotkey_value_label("ingame_gamespeed_slower", hotkeys)),               rate("Slower"))
    :appendCheckItem(_S.menu_options_game_speed.normal:format(hotkey_value_label("ingame_gamespeed_normal", hotkeys)),               rate("Normal")) -- (default)
    :appendCheckItem(_S.menu_options_game_speed.max_speed:format(hotkey_value_label("ingame_gamespeed_max", hotkeys)),               rate("Max speed"))
    :appendCheckItem(_S.menu_options_game_speed.and_then_some_more:format(hotkey_value_label("ingame_gamespeed_thensome", hotkeys)), rate("And then some more"))
  )

  self:addMenu(_S.menu.options, options)

  self:addMenu(_S.menu.charts, UIMenu()
    :appendItem(_S.menu_charts.bank_manager:format(hotkey_value_label("ingame_panel_bankManager", hotkeys)), function() self.ui.bottom_panel:dialogBankManager(true) end)
    :appendItem(_S.menu_charts.statement:format(hotkey_value_label("ingame_panel_bankStats", hotkeys)), function() self.ui.bottom_panel:dialogBankStats(true) end)
    :appendItem(_S.menu_charts.staff_listing:format(hotkey_value_label("ingame_panel_staffManage", hotkeys)), function() self.ui.bottom_panel:dialogStaffManagement(true) end)
    :appendItem(_S.menu_charts.town_map:format(hotkey_value_label("ingame_panel_townMap", hotkeys)), function() self.ui.bottom_panel:dialogTownMap(true) end)
    :appendItem(_S.menu_charts.casebook:format(hotkey_value_label("ingame_panel_casebook", hotkeys)), function() self.ui.bottom_panel:dialogDrugCasebook(true) end)
    :appendItem(_S.menu_charts.research:format(hotkey_value_label("ingame_panel_research", hotkeys)), function() self.ui.bottom_panel:dialogResearch(true) end)
    :appendItem(_S.menu_charts.status:format(hotkey_value_label("ingame_panel_status", hotkeys)), function() self.ui.bottom_panel:dialogStatus(true) end)
    :appendItem(_S.menu_charts.graphs:format(hotkey_value_label("ingame_panel_charts", hotkeys)), function() self.ui.bottom_panel:dialogCharts(true) end)
    :appendItem(_S.menu_charts.policy:format(hotkey_value_label("ingame_panel_policy", hotkeys)), function() self.ui.bottom_panel:dialogPolicy(true) end)
    :appendItem(_S.menu_charts.machine_menu:format(hotkey_value_label("ingame_panel_machineMenu", hotkeys)), function() self.ui:addWindow(UIMachineMenu(self.ui)) end)
    :appendItem(_S.menu_charts.briefing, function() self.ui:showBriefing() end)
  )

  local function limit_camera(item)
    app.ui:limitCamera(item.checked)
  end
  local function disable_salary_raise(item)
    app.world:debugDisableSalaryRaise(item.checked)
  end
  local function allowBlockingAreas(item)
    app.config.allow_blocking_off_areas = item.checked
  end
  local function allowFalling(item)
    app.config.debug_falling = item.checked
  end
  local levels_menu = UIMenu()
  for L = 1, 12 do
    levels_menu:appendItem(("  L%i  "):format(L), function()
      if app:loadLevel(L, nil, nil, nil, nil, nil, _S.errors.load_level_prefix, nil) then
        self.ui.app.moviePlayer:playAdvanceMovie(L)
      end
    end)
  end
  if self.ui.app.config.debug then
    self:addMenu(_S.menu.debug, UIMenu() -- Debug
      :appendMenu(_S.menu_debug.jump_to_level, levels_menu)
      :appendCheckItem(_S.menu_debug.limit_camera,         true, limit_camera, nil, function() return self.ui.limit_to_visible_diamond end)
      :appendCheckItem(_S.menu_debug.disable_salary_raise, false, disable_salary_raise, nil, function() return self.ui.app.world.debug_disable_salary_raise end)
      :appendCheckItem(_S.menu_debug.allow_blocking_off_areas, false, allowBlockingAreas, nil, function() return self.ui.app.config.allow_blocking_off_areas end)
      :appendCheckItem(_S.menu_debug.allow_falling, false, allowFalling, nil, function() return self.ui.app.config.debug_falling end)
      :appendItem(_S.menu_debug.make_debug_fax,     function() self.ui:makeDebugFax() end)
      :appendItem(_S.menu_debug.make_debug_patient, function() self.ui:addWindow(UIMakeDebugPatient(self.ui)) end)
      :appendItem(_S.menu_debug.cheats:format(hotkey_value_label("ingame_showCheatWindow", hotkeys)),             function() self.ui:addWindow(UICheats(self.ui)) end)
      :appendItem(_S.menu_debug.lua_console:format(hotkey_value_label("global_showLuaConsole", hotkeys)),        function() self.ui:addWindow(UILuaConsole(self.ui)) end)
      :appendItem(_S.menu_debug.debug_script:format(hotkey_value_label("global_runDebugScript", hotkeys)),       function() self.ui:runDebugScript() end)
      :appendItem(_S.menu_debug.calls_dispatcher,   function() self.ui:addWindow(UICallsDispatcher(self.ui)) end)
      :appendItem(_S.menu_debug.dump_strings:format(hotkey_value_label("ingame_poopStrings", hotkeys)),       function() self.ui.app:dumpStrings() end)
      :appendItem(_S.menu_debug.dump_gamelog:format(hotkey_value_label("ingame_poopLog", hotkeys)),       function() self.ui.app.world:dumpGameLog() end)
      :appendMenu(_S.menu_debug.map_overlay,        UIMenu()
        :appendCheckItem(_S.menu_debug_overlay.none,         true, overlay(), "")
        :appendCheckItem(_S.menu_debug_overlay.flags,       false, overlay("flags"), "")
        :appendCheckItem(_S.menu_debug_overlay.positions,   false, overlay("positions"), "")
        :appendCheckItem(_S.menu_debug_overlay.heat,        false, overlay("heat"), "")
        :appendCheckItem(_S.menu_debug_overlay.byte_0_1,    false, overlay(0, 1, false), "")
        :appendCheckItem(_S.menu_debug_overlay.byte_floor,  false, overlay(2, 2, false), "")
        :appendCheckItem(_S.menu_debug_overlay.byte_n_wall, false, overlay(3, 3, false), "")
        :appendCheckItem(_S.menu_debug_overlay.byte_w_wall, false, overlay(4, 4, false), "")
        :appendCheckItem(_S.menu_debug_overlay.byte_5,      false, overlay(5, 5, true), "")
        :appendCheckItem(_S.menu_debug_overlay.byte_6,      false, overlay(6, 6, true), "")
        :appendCheckItem(_S.menu_debug_overlay.byte_7,      false, overlay(7, 7, true), "")
        :appendCheckItem(_S.menu_debug_overlay.parcel,      false, overlay("parcel"), "")
      )
      :appendItem(_S.menu_debug.sprite_viewer, function() corsixth.require("sprite_viewer") end)
    )
  end
end
