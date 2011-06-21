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
    local btn = panel:makeToggleButton(0, 0, 46, 46, 0, --[[persistable:town_map_config_button]] function(_, state)
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
  Window.close(self)
end

local flag_cache = {}
function UITownMap:onMouseMove(x, y)
  local tx = math.floor((x - 227) / 3)
  local ty = math.floor((y - 25) / 3)
  self.hover_plot = nil
  if 0 <= tx and tx < 128 and 0 <= ty and ty < 128 then
    local map = self.ui.hospital.world.map.th
    self.hover_plot = map:getCellFlags(tx + 1, ty + 1, flag_cache).parcelId
  end
  return UIFullscreen.onMouseMove(self, x, y)
end

function UITownMap:onMouseUp(button, x, y)
  local redraw = false
  if button == "left" then
    local tx = math.floor((x - 227) / 3)
    local ty = math.floor((y - 25) / 3)
    if 0 <= tx and tx < 128 and 0 <= ty and ty < 128 then
      local map = self.ui.hospital.world.map.th
      local plot = map:getCellFlags(tx + 1, ty + 1, flag_cache).parcelId
      if plot ~= 0 then
        if self.ui.hospital:purchasePlot(plot) then
          self.ui:playSound("cashreg.wav")
          redraw = true
        else
          self.ui:playSound("Wrong2.wav")
        end
      end
    end
  end
  return UIFullscreen.onMouseUp(self, button, x, y) or redraw
end

function UITownMap:draw(canvas, x, y)
  self.background:draw(canvas, self.x + x, self.y + y)
  UIFullscreen.draw(self, canvas, x, y)
  
  x, y = self.x + x, self.y + y
  local app      = self.ui.app
  local hospital = self.ui.hospital
  local world    = hospital.world
  local map      = world.map
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
    local tx, ty = patient.tile_x, patient.tile_y
    if tx and ty and hospital:isInHospital(tx, ty) then
      patientcount = patientcount + 1
    end
  end

  self.info_font:draw(canvas, patientcount, x +  95, y +  57)
  self.info_font:draw(canvas, plants,       x +  95, y + 110)
  self.info_font:draw(canvas, fireext,      x +  95, y + 157)
  self.info_font:draw(canvas, objs,         x +  95, y + 211)
  self.info_font:draw(canvas, radiators,    x +  95, y + 265)
  
  -- Heating costs
  local heating_costs = math.floor(((hospital.radiator_heat *10)* radiators)* 7.5)
  self.info_font:draw(canvas, ("%8i"):format(heating_costs),  x + 100, y + 355)

  -- draw money balance
  self.money_font:draw(canvas, ("%7i"):format(hospital.balance), x + 49, y + 431)

  -- radiator heat
  local rad_max_width = 60 -- Radiator indicator width
  local rad_width = rad_max_width * hospital.radiator_heat
  for dx = 0, rad_width do
    self.panel_sprites:draw(canvas, 9, x + 101 + dx, y + 319)
  end

  -- city name
  self.city_font:draw(canvas, map.level_name, x + 300, y + 43, 260, 15)

  TH.windowHelpers.townMapDraw(self, map.th, canvas, x + 227, y + 25,
    config.radiators_enabled)

  -- plot number, owner, area and price
  local plot_num = "-"
  local tile_count = "-"
  local price = "-"
  local owner = "-"
  if self.hover_plot then
    if self.hover_plot == 0 then
      price = _S.town_map.not_for_sale
    else
      tile_count = map:getParcelTileCount(self.hover_plot)
      local owner_num = map.th:getPlotOwner(self.hover_plot)
      if owner_num == 0 then
        owner = _S.town_map.for_sale
        price = "$" .. map:getParcelPrice(self.hover_plot)
      else
        owner = world.hospitals[owner_num].name
      end
      plot_num = self.hover_plot
    end
  end
  self.city_font:draw(canvas, _S.town_map.number, x + 227, y + 435)
  self.city_font:draw(canvas, ":",                x + 300, y + 435)
  self.city_font:draw(canvas, plot_num,           x + 315, y + 435)
  self.city_font:draw(canvas, _S.town_map.owner,  x + 227, y + 450)
  self.city_font:draw(canvas, ":",                x + 300, y + 450)
  self.city_font:draw(canvas, owner,              x + 315, y + 450)
  self.city_font:draw(canvas, _S.town_map.area,   x + 432, y + 435)
  self.city_font:draw(canvas, ":",                x + 495, y + 435)
  self.city_font:draw(canvas, tile_count,         x + 515, y + 435)
  self.city_font:draw(canvas, _S.town_map.price,  x + 432, y + 450)
  self.city_font:draw(canvas, ":",                x + 495, y + 450)
  self.city_font:draw(canvas, price,              x + 515, y + 450)
end

function UITownMap:decreaseHeat()
  local h = self.ui.hospital
  local heat = math.floor(h.radiator_heat * 10 + 0.5)
  if not h.heating_broke then
    heat = heat - 1
  end
  if heat < 1 then
    heat = 1
  end
  h.radiator_heat = heat / 10
end

function UITownMap:increaseHeat()
  local h = self.ui.hospital
  local heat = math.floor(h.radiator_heat * 10 + 0.5)
  if not h.heating_broke then
    heat = heat + 1
  end
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
