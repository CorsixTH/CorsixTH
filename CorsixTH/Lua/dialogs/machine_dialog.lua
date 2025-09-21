--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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

require("languages.string_ids")

class "UIMachine" (Window)

---@type UIMachine
local UIMachine = _G["UIMachine"]

function UIMachine:UIMachine(ui, machine, room)
  self:Window()

  local app = ui.app
  self.esc_closes = true
  self.machine = machine
  self.room = room
  self.ui = ui
  self.modal_class = "humanoid_info"
  self.width = 188
  self.height = 206
  self:setDefaultPosition(-20, 30)
  self.panel_sprites = app.gfx:loadSpriteTable("QData", "Req03V", true)
  self.white_font = app.gfx:loadFontAndSpriteTable("QData", "Font01V")

  self:addPanel(333,    0,   0) -- Dialog header
  self:addPanel(334,    0,  74) -- The next part
  for y = 131, 180, 7 do
    self:addPanel(335,  0,   y) -- Some background
  end
  self:addPanel(336,   0,  182) -- Dialog footer

  -- Call button
  self:addPanel(339, 20, 127)
    :makeButton(0, 0, 63, 60, 340, self.callHandyman)
    :setTooltip(_S.tooltip.machine_window.repair)
    :setSound("selectx.wav")
  -- Replace button
  self:addPanel(341, 92, 127)
    :makeButton(0, 0, 45, 60, 342, self.replaceMachine)
    :setTooltip(_S.tooltip.machine_window.replace)
    :setSound("selectx.wav")
  -- Close button
  self:addPanel(337, 146,  18):makeButton(0, 0, 24, 24, 338, self.close)
    :setTooltip(_S.tooltip.machine_window.close)

  self:makeTooltip(_S.tooltip.machine_window.name, 18, 19, 139, 42)
  self:makeTooltip(_S.tooltip.machine_window.times_used, 18, 49, 139, 77)
  self:makeTooltip(_S.tooltip.machine_window.status, 24, 88, 128, 115)
end

function UIMachine:draw(canvas, x, y)
  Window.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y
  local mach = self.machine

  local font = self.white_font
  local output
  if self.room.needs_repair then
    output = "(" .. mach.object_type.name .. ")"
  else
    output = mach.object_type.name
  end
  font:draw(canvas, output, x + 27, y + 27) -- Name
  font:draw(canvas, mach.total_usage, x + 60, y + 59) -- Total number of times used

  local status_bar_width = math.floor((1 - mach.times_used/mach.strength) * 40 + 0.5)
  if status_bar_width ~= 0 then
    for dx = 0, status_bar_width - 1 do
      self.panel_sprites:draw(canvas, 352, x + 53 + dx, y + 99) -- Or 5
    end
  end
end

function UIMachine:callHandyman()
  if self.machine.times_used ~= 0 then
    local taskIndex = self.machine.hospital:getIndexOfTask(self.machine.tile_x, self.machine.tile_y, "repairing")
    if taskIndex == -1 then
      local call = self.ui.app.world.dispatcher:callForRepair(self.machine, false, true)
      self.machine.hospital:addHandymanTask(self.machine, "repairing", 2, self.machine.tile_x, self.machine.tile_y, call)
    else
      self.machine.hospital:modifyHandymanTaskPriority(taskIndex, 2, "repairing")
    end
  end
end

--! Function checks we can afford a new machine
--! Then offers player to purchase
function UIMachine:replaceMachine()
  -- Maybe TODO: Prevent purchase of a machine of same strength?
  local machine = self.machine
  local hosp = self.ui.hospital
  local cost = hosp.research.research_progress[machine.object_type].cost
  if hosp.balance < cost then
    -- give visual warning that player doesn't have enough $ to buy
    local advice = _A.warnings.cannot_afford_machine:format(cost, machine.object_type.name)
    local advice_id = AdviserStringIds.warnings.cannot_afford_machine
    self.ui.adviser:say(advice, advice_id, false, true)
    self.ui:playSound("wrong2.wav")
    return
  end

  local prompt = _S.confirmation.replace_machine:format(machine.object_type.name, cost)
  if self.ui.app.config.new_machine_extra_info then
    local new_strength = hosp.research.research_progress[machine.object_type].start_strength
    local current_strength = machine.strength
    prompt = (_S.confirmation.replace_machine_extra_info):format(new_strength, current_strength) .. "//" .. prompt
  end

  self.ui:addWindow(UIConfirmDialog(self.ui, true, prompt,
    --[[persistable:replace_machine_confirm_dialog]]function() machine:replaceMachine(cost)
    end
  ))
end

function UIMachine:onMouseDown(code, x, y)
  -- cycle through all machines when you right click on the machine title
  if code == "right" then
    local is_hit_namebox = x > self.tooltip_regions[1].x and x < self.tooltip_regions[1].r
                       and y > self.tooltip_regions[1].y and y < self.tooltip_regions[1].b
    if is_hit_namebox then
      -- move to next machine
      local ui = self.ui
      local first_machine, next_machine = nil, self.machine
      local next_room
      for _, entity in ipairs(ui.app.world.entities) do
        -- is a machine and not a slave (e.g. operating_table_b)
        if class.is(entity, Machine) and not entity.master then
          next_room = entity:getRoom()
          if next_room.is_active then
            if not first_machine then
              first_machine = entity
            end
            if not next_machine then
              next_machine = entity
              break
            elseif entity == next_machine then
              next_machine = nil
            end
          end
        end
      end
      if not next_machine or next_machine == self.machine then
        next_machine = first_machine
      end
      if next_machine and next_machine ~= self.machine then
        -- center screen on machine
        local sx, sy = ui.app.map:WorldToScreen(next_machine.tile_x, next_machine.tile_y)
        local dx, dy = next_machine.th:getPosition()
        ui:scrollMapTo(sx + dx, sy + dy)
        -- switch machine window
        ui:addWindow(UIMachine(ui, next_machine, next_room))
        ui:playSound("camclick.wav")
        -- show machine info in dynamic info
        ui.bottom_panel:setDynamicInfo(next_machine:getDynamicInfo())
      end
    end
  end
  return Window.onMouseDown(self, code, x, y)
end
