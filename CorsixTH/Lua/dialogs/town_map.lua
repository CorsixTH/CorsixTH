--[[ Copyright (c) 2010 Sjors Gielen

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

dofile "dialogs/fullscreen"
local TH = require "TH"

--! Town map fullscreen window (purchase land, set radiator levels, map overview).
class "UITownMap" (UIFullscreen)

function UITownMap:UITownMap(ui)
  self:UIFullscreen(ui)

  local app      = self.ui.app
  local hospital = self.ui.hospital
  local gfx      = app.gfx

  if not pcall(function()
    local palette   = gfx:loadPalette("QData", "Town01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent

    self.background = gfx:loadRaw("Town01V", 640, 480)
    self.info_font  = gfx:loadFont("QData", "Font34V", false, palette)
    self.city_font = gfx:loadFont("QData", "Font31V", false, palette)
    self.money_font = gfx:loadFont("QData", "Font05V")
    self.panel_sprites = gfx:loadSpriteTable("QData", "Town02V", true, palette)
  end) then
    ui:addWindow(UIInformation(ui, {_S.errors.dialog_missing_graphics}))
    self:close()
    return
  end
  
  self.default_button_sound = "selectx.wav"
  self.default_buy_sound    = "buy.wav"

  -- config is a *runtime* configuration list; re-instantiations of the dialog
  -- share the same values, but it's not saved across saves or sessions
  local config   = app.runtime_config.town_dialog
  if config == nil then
    config = {}
    app.runtime_config.town_dialog = config
    config.people_enabled = true
    config.plants_enabled = true
    config.fire_ext_enabled = true
    config.objects_enabled = true
    config.radiators_enabled = true  
  end

  -- A list of areas in the town, including the owner.
  -- In single player there are only bought and available areas, in multiplayer
  -- areas are owned by players and when a player wants to buy a piece of
  -- terrain, an auction is started.
  -- TODO display the areas, in the right color
  -- TODO display everything in the areas
  -- TODO make it possible to buy areas
  -- TODO multiplayer mode
  
  -- NB: original TH closed the town map on right click of balance button.
  -- This is likely a bug and we do not copy this behavior.
  self:addPanel(0, 30,  420):makeButton(0, 0, 200, 50, 0, self.bankManager, nil, self.bankStats):setTooltip(_S.tooltip.town_map.balance)
  self:addPanel(0, 594, 437):makeButton(0, 0, 26, 26, 8, self.close):setTooltip(_S.tooltip.town_map.close)
  self:addPanel(0, 171, 315):makeButton(0, 0, 20, 20, 6, self.increaseHeat):setTooltip(_S.tooltip.town_map.heat_inc)
  self:addPanel(0, 70,  314):makeButton(0, 0, 20, 20, 7, self.decreaseHeat):setTooltip(_S.tooltip.town_map.heat_dec)

  -- add the toggle buttons
  local function toggle_button(sprite, x, y, option, str)
    local panel = self:addPanel(sprite, x, y)
    local btn = panel:makeToggleButton(0, 0, 46, 46, 0, --[[persistable:town_map_config_button]] function(state)
      app.runtime_config.town_dialog[option] = state
    end):setTooltip(str)
    btn:setToggleState(config[option])
  end
  toggle_button(1, 140,  37, "people_enabled", _S.tooltip.town_map.people)
  toggle_button(2, 140,  89, "plants_enabled", _S.tooltip.town_map.plants)
  toggle_button(3, 140, 141, "fire_ext_enabled", _S.tooltip.town_map.fire_extinguishers)
  toggle_button(4, 140, 193, "objects_enabled", _S.tooltip.town_map.objects)
  toggle_button(5, 140, 246, "radiators_enabled", _S.tooltip.town_map.radiators)
  
  self:makeTooltip(_S.tooltip.town_map.heat_level, 94, 318, 167, 331)
  self:makeTooltip(_S.tooltip.town_map.heating_bill, 72, 351, 167, 374)
end

function UITownMap:close()
  self.ui:disableKeyboardRepeat()
  Window.close(self)
end

function UITownMap:draw(canvas, x, y)
  self.background:draw(canvas, self.x + x, self.y + y)
  UIFullscreen.draw(self, canvas, x, y)
  
  x, y = self.x + x, self.y + y
  local app      = self.ui.app
  local hospital = self.ui.hospital
  local world    = hospital.world
  -- config is a *runtime* configuration list; re-instantiations of the dialog
  -- share the same values, but it's not saved across saves or sessions
  local config   = app.runtime_config.town_dialog
  
  -- We need to draw number of people, plants, fire extinguisers, other objects
  -- and radiators, heat level and radiator total costs, to the left.
  -- NB: original TH's patient count was always 1 too big (started counting at 1)
  -- This is likely a bug and we do not copy this behavior.
  local patientcount = 0
  local plants = world.object_counts.plant
  local fireext = world.object_counts.extinguisher
  local objs = world.object_counts.general
  local radiators = world.object_counts.radiator

  -- Even though it says "people", staff and guests like VIPS aren't included.
  -- TH counts someone as a patient the moment he walks into the hospital; when
  -- he walks out to really go away, he isn't counted anymore.
  for _, patient in pairs(hospital.patients) do
    -- only count patients that are in the hospital
    if hospital:isInHospital(patient.tile_x, patient.tile_y) then
      patientcount = patientcount + 1
    end
  end

  self.info_font:draw(canvas, patientcount, x +  95, y +  57)
  self.info_font:draw(canvas, plants,       x +  95, y + 110)
  self.info_font:draw(canvas, fireext,      x +  95, y + 157)
  self.info_font:draw(canvas, objs,         x +  95, y + 211)
  self.info_font:draw(canvas, radiators,    x +  95, y + 265)
  -- TODO how is radiator cost computed?
  self.info_font:draw(canvas, "0",          x + 100, y + 355)
  
  -- draw money balance
  self.money_font:draw(canvas, ("%7i"):format(hospital.balance), x + 49, y + 431)

  -- radiator heat
  local rad_max_width = 60 -- Radiator indicator width
  local rad_width = rad_max_width * hospital.radiator_heat
  for dx = 0, rad_width do
    self.panel_sprites:draw(canvas, 9, x + 101 + dx, y + 319)
  end

  -- city name
  self.city_font:draw(canvas, world.map.level_name, x + 300, y + 43, 260, 15)

  -- plots
  -- TODO maybe this can be cached! a lot of this stuff is unlikely to change,
  -- only people actually move.
  --[[
  local color_myhosp  = canvas:mapRGB(0, 0, 70) -- darkish blue
  local color_buyhosp = canvas:mapRGB(255, 0, 0) -- bright red
  local color_wall    = canvas:mapRGB(255, 255, 255) -- white
  local color_door    = canvas:mapRGB(200, 200, 200) -- grayish
  local map_xstart    = x + 227
  local map_ystart    = y + 25
  local flag_cache = {}
  local th_map = world.map.th
  local height = world.map.height
  local drawRect = canvas.drawRect
  for xi = 1, world.map.width do
    for yi = 1, height do
      local l_objects = world:getObjects(xi, yi)
      local flags     = th_map:getCellFlags(xi, yi, flag_cache)
      local _, north_layer, west_layer = th_map:getCell(xi, yi)
      north_layer = north_layer % 0x100
      west_layer = west_layer % 0x100

      -- first, paint blue-ish if hospital=true (we don't know whether it's
      -- our area yet, but currently we assume it is)
      if flags.hospital then
        drawRect(canvas, color_myhosp, map_xstart + (3*xi), map_ystart + (3*yi),
          3, 3)
      end

      -- then, paint the walls and doors, if we're in the hospital
      -- TODO: there's no drawLine, so we take drawRect with width 1
      if 82 <= north_layer and north_layer <= 164 then -- north wall present
        drawRect(canvas, color_wall, map_xstart + (3*xi),
          map_ystart + (3*yi), 3, 1)
      end
      if 82 <= west_layer and west_layer <= 164 then -- west wall present
        drawRect(canvas, color_wall, map_xstart + (3*xi),
          map_ystart + (3*yi), 1, 3)
      end

      -- paint objects
      if flags.doorNorth then
        drawRect(canvas, color_door, map_xstart + (3*xi),
          map_ystart - 2 + (3*yi), 2, 3)
      end
      if flags.doorEast then
        drawRect(canvas, color_door, map_xstart + 3 + (3*xi),
          map_ystart + (3*yi), 3, 2)
      end
      if flags.doorSouth then
        drawRect(canvas, color_door, map_xstart + (3*xi),
          map_ystart + 3 + (3*yi), 2, 3)
      end
      if flags.doorWest then
        drawRect(canvas, color_door, map_xstart - 2 + (3*xi),
          map_ystart + (3*yi), 3, 2)
      end

      -- paint people
    end
  end
  --]]
  TH.windowHelpers.townMapDraw(self, world.map.th, canvas, x + 227, y + 25) 

  -- plot number, owner, area and price
  self.city_font:draw(canvas, _S.town_map.number, x + 227, y + 435)
  self.city_font:draw(canvas, ":",                x + 300, y + 435)
  self.city_font:draw(canvas, "-",                x + 315, y + 435)
  self.city_font:draw(canvas, _S.town_map.owner,  x + 227, y + 450)
  self.city_font:draw(canvas, ":",                x + 300, y + 450)
  self.city_font:draw(canvas, "-",                x + 315, y + 450)
  self.city_font:draw(canvas, _S.town_map.area,   x + 432, y + 435)
  self.city_font:draw(canvas, ":",                x + 495, y + 435)
  self.city_font:draw(canvas, "-",                x + 515, y + 435)
  self.city_font:draw(canvas, _S.town_map.price,  x + 432, y + 450)
  self.city_font:draw(canvas, ":",                x + 495, y + 450)
  self.city_font:draw(canvas, "-",                x + 515, y + 450)
end

function UITownMap:decreaseHeat()
  local h = self.ui.hospital
  local heat = math.floor(h.radiator_heat * 10 + 0.5)
  heat = heat - 1
  if heat < 1 then
    heat = 1
  end
  h.radiator_heat = heat / 10
end

function UITownMap:increaseHeat()
  local h = self.ui.hospital
  local heat = math.floor(h.radiator_heat * 10 + 0.5)
  heat = heat + 1
  if heat > 10 then
    heat = 10
  end
  h.radiator_heat = heat / 10
end

function UITownMap:bankManager()
  local dlg = UIBankManager(self.ui)
  self.ui:addWindow(dlg)
end

function UITownMap:bankStats()
  local dlg = UIBankManager(self.ui)
  dlg:showStatistics()
  self.ui:addWindow(dlg)
end
