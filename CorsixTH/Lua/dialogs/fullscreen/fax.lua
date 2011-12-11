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

class "UIFax" (UIFullscreen)

function UIFax:UIFax(ui, icon)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  self.background = gfx:loadRaw("Fax01V", 640, 480)
  local palette = gfx:loadPalette("QData", "Fax01V.pal")
  palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
  self.panel_sprites = gfx:loadSpriteTable("QData", "Fax02V", true, palette)
  self.fax_font = gfx:loadFont("QData", "Font51V", false, palette)
  self.icon = icon
  self.message = icon.message or {}
  self.owner = icon.owner
  
  self.code = ""
  
  -- Add choice buttons
  local choices = false
  local orig_y = 175
  if self.message["choices"] then
    choices = true
    local last_y
    for k = 3, 3 - #self.message["choices"] + 1, -1 do
      last_y = orig_y + (k-1)*48
      if self.message["choices"][k - (3 - #self.message["choices"])].choice ~= "disabled" then
        local --[[persistable:fax_choice_button]] function callback()
          self:choice(self.message["choices"][k - (3 - #self.message["choices"])].choice)
        end
        self:addPanel(17, 492, last_y):makeButton(0, 0, 43, 43, 18, callback)
      else
        self:addPanel(19, 492, last_y)
      end
    end
  end
  
  -- Close button
  self:addPanel(0, 598, 440):makeButton(0, 0, 26, 26, 16, self.close):setTooltip(_S.tooltip.fax.close)
  
  self:addPanel(0, 471, 349):makeButton(0, 0, 87, 20, 14, self.cancel) -- Cancel code button
  self:addPanel(0, 474, 372):makeButton(0, 0, 91, 27, 15, self.validate) -- Validate code button
  
  self:addPanel(0, 168, 348):makeButton(0, 0, 43, 10, 1, self.correct) -- Correction button
  
  local function button(char)
    return --[[persistable:fax_button]] function() self:appendNumber(char) end
  end
  
  self:addPanel(0, 220, 348):makeButton(0, 0, 43, 10,  2, button"1"):setSound"Fax_1.wav"
  self:addPanel(0, 272, 348):makeButton(0, 0, 44, 10,  3, button"2"):setSound"Fax_2.wav"
  self:addPanel(0, 327, 348):makeButton(0, 0, 43, 10,  4, button"3"):setSound"Fax_3.wav"
  
  self:addPanel(0, 219, 358):makeButton(0, 0, 44, 10,  5, button"4"):setSound"Fax_4.wav"
  self:addPanel(0, 272, 358):makeButton(0, 0, 43, 10,  6, button"5"):setSound"Fax_5.wav"
  self:addPanel(0, 326, 358):makeButton(0, 0, 44, 10,  7, button"6"):setSound"Fax_6.wav"
  
  self:addPanel(0, 218, 370):makeButton(0, 0, 44, 11,  8, button"7"):setSound"Fax_7.wav"
  self:addPanel(0, 271, 370):makeButton(0, 0, 44, 11,  9, button"8"):setSound"Fax_8.wav"
  self:addPanel(0, 326, 370):makeButton(0, 0, 44, 11, 10, button"9"):setSound"Fax_9.wav"
  
  self:addPanel(0, 217, 382):makeButton(0, 0, 45, 12, 11, button"*")
  self:addPanel(0, 271, 382):makeButton(0, 0, 44, 11, 12, button"0"):setSound"Fax_0.wav"
  self:addPanel(0, 326, 382):makeButton(0, 0, 44, 11, 13, button"#")
end

function UIFax:draw(canvas, x, y)
  self.background:draw(canvas, self.x + x, self.y + y)
  UIFullscreen.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y
  
  if self.message then
    local last_y = y + 40
    for i, message in ipairs(self.message) do
      last_y = self.fax_font:drawWrapped(canvas, message.text, x + 190, 
                                         last_y + (message.offset or 0), 330,
                                         "center")
    end
    local choices = self.message["choices"]
    if choices then
      local orig_y = y + 190
      for k = 3, 3 - #choices + 1, -1 do
        local choice = choices[k - (3 - #choices)]
        last_y = orig_y + (k - 1) * 47
        self.fax_font:drawWrapped(canvas, choice.text, x + 190,
                                  last_y + (choice.offset or 0), 300)
      end
    end
  end
end

function UIFax:choice(choice)
  local owner = self.owner
  if owner then
    -- A choice was made, the patient is no longer waiting for a decision
    owner:setMood("patient_wait", "deactivate")
    owner.message_callback = nil
    if choice == "send_home" then
      owner:goHome()
      if owner.diagnosed then
        -- No treatment rooms
        owner:updateDynamicInfo(_S.dynamic_info.patient.actions.no_treatment_available)
      else
        -- No diagnosis rooms
        owner:updateDynamicInfo(_S.dynamic_info.patient.actions.no_diagnoses_available)
      end
    elseif choice == "wait" then
      -- Wait two months before going home
      owner.waiting = 60
      if owner.diagnosed then
        -- Waiting for treatment room
        owner:updateDynamicInfo(_S.dynamic_info.patient.actions.waiting_for_treatment_rooms)
      else
        -- Waiting for diagnosis room
        owner:updateDynamicInfo(_S.dynamic_info.patient.actions.waiting_for_diagnosis_rooms)
      end
    elseif choice == "guess_cure" then
      owner:setDiagnosed(true)
      owner:setNextAction{
        name = "seek_room",
        room_type = owner.disease.treatment_rooms[1],
        treatment_room = true,
      }
    elseif choice == "research" then
      owner:setMood("idea", "activate")
      owner:setNextAction {
        name = "seek_room",
        room_type = "research",
      }
    end
  end
  if choice == "accept_emergency" then
    self.ui.app.world:newObject("helicopter", self.ui.hospital, "north")
    self.ui:addWindow(UIWatch(self.ui, "emergency"))
    self.ui:playAnnouncement(self.ui.hospital.emergency.disease.emergency_sound)
    self.ui.adviser:say(_A.information.emergency)
  elseif choice == "refuse_emergency" then
    self.ui.app.world:nextEmergency()
  elseif choice == "accept_vip" then
    self.ui.hospital.num_vips = self.ui.hospital.num_vips+1
    self.ui.app.world:spawnVIP()
  elseif choice == "refuse_vip" then
    self.ui.app.world:nextVip() -- don't start an inspection
  elseif choice == "accept_new_level" then
    -- Set the new salary.
    self.ui.hospital.player_salary = self.ui.hospital.salary_offer
    if tonumber(self.ui.app.world.map.level_number) then
      self.ui.app:loadLevel(self.ui.app.world.map.level_number + 1, self.ui.app.map.difficulty)
    else
      -- TODO: Allow some kind of custom campaign with custom levels
    end
  elseif choice == "return_to_main_menu" then
    self.ui.app:loadMainMenu()
  end
  self.icon:removeMessage()
  self:close()
end

function UIFax:cancel()
  self.code = ""
end

function UIFax:correct()
  if self.code ~= "" then
    self.code = string.sub(self.code, 1, -2) --Remove last character
  end
end

function UIFax:validate()
  if self.code == "" then
    return
  end
  local code = self.code
  self.code = ""
  local code_n = (tonumber(code) or 0) / 10^5
  local x = math.abs((code_n ^ 5.00001 - code_n ^ 5) * 10^5 - code_n ^ 5)
  print("Code typed on fax:", code)
  if code == "24328" then
    -- Original game cheat code
    self.ui.adviser:say(_A.cheats.th_cheat)
    self.ui:addWindow(UICheats(self.ui))
  elseif code == "112" then
    -- simple, unobfuscated cheat for everyone :)
    self.ui:playAnnouncement("rand*.wav")
  elseif 27868.3 < x and x < 27868.4 then
    -- Roujin's challenge cheat
    local hosp = self.ui.hospital
    if not hosp.spawn_rate_cheat then
      self.ui.adviser:say(_A.cheats.roujin_on_cheat)
      hosp.spawn_rate_cheat = true
    else
      self.ui.adviser:say(_A.cheats.roujin_off_cheat)
      hosp.spawn_rate_cheat = nil
    end
  else
    -- no valid cheat entered
    self.ui:playSound("fax_no.wav")
    return
  end
  self.ui:playSound("fax_yes.wav")
  
  -- TODO: Other cheats (preferably with slight obfuscation, as above)
end

function UIFax:appendNumber(number)
  self.code = self.code .. number
end

function UIFax:close()
  self.icon.fax = nil
  self.icon:adjustToggle()
  UIFullscreen.close(self)
end
