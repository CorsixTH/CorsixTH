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

dofile "dialogs/fullscreen"

class "UIFax" (UIFullscreen)

function UIFax:UIFax(ui, message)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  self.background = gfx:loadRaw("Fax01V", 640, 480)
  local palette = gfx:loadPalette("QData", "Fax01V.pal")
  palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
  self.panel_sprites = gfx:loadSpriteTable("QData", "Fax02V", true, palette)
  self.fax_font = gfx:loadFont("QData", "Font51V", false, palette)
  ui:playSound "fax_in.wav"
  if message then
    self.message = message
  else
    self.message = {
      {text = "Welcome to CorsixTH, an open source clone of the classic game Theme Hospital by Bullfrog!"},
      {offset = 8, text = "This is playable beta 1 of CorsixTH. Many rooms, diseases and features have been implemented, but there are still many things missing."},
      {offset = 8, text = "If you like this project, you can help us with development, e.g. by reporting bugs or starting to code something yourself."},
      {offset = 8, text = "But now, have fun with the game! For those who are unfamiliar with Theme Hospital: Start by building a reception desk (from the objects menu) and a GP's office (diagnosis room). Various treatment rooms will also be needed."},
      {offset = 16, text = "-- The CorsixTH team, th.corsix.org"},
      {offset = 8, text = "PS: can you find the easter eggs we included?"},
    }
  end
  
  self.code = ""
  
  -- There may be an owner of the message
  if self.message["owner"] then
    self.owner = self.message["owner"]
  end
  
  -- Add choice buttons
  local choices = false
  local last_y = self.y
  if self.message["choices"] then
    choices = true
    for k = 1, #self.message["choices"] do
      if self.message["choices"][k].choice ~= "disabled" then
        local --[[persistable:fax_choice_button]] function callback()
          self:choice(self.message["choices"][k].choice)
        end
        self:addPanel(17, self.x + 170, last_y):makeButton(0, 0, 43, 43, 18, callback)
      else
        self:addPanel(19, self.x + 170, last_y)
      end
      last_y = last_y + 60
    end
  end
  
  -- Some faxes can be dismissed by pressing the close button, while others
  -- need to be dismissed by making a choice. For now, just display the close
  -- button.
  if choices then
    -- Blanker over close button
    self:addPanel(20, 596, 435)
  else
    -- Close button
    self:addPanel(0, 598, 440):makeButton(0, 0, 26, 26, 16, self.close)
  end
  
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

function UIFax:draw(canvas)
  self.background:draw(canvas, self.x, self.y)
  
  if self.message then
    local last_y = self.y + 40
    for i = 1, #self.message do
      last_y = self.fax_font:drawWrapped(canvas, self.message[i].text, self.x + 170, 
          last_y + (self.message[i].offset or 0), 380)
    end
    if self.message["choices"] then
      last_y = self.y + 100
      for k = 1, #self.message["choices"] do
        last_y = self.fax_font:drawWrapped(canvas, self.message["choices"][k].text, 
            self.x + 190, last_y + (self.message["choices"][k].offset or 0), 280)
      end
    end
  end
  return UIFullscreen.draw(self, canvas)
end

function UIFax:choice(choice)
  local owner = self.owner
  if owner then
    -- A choice was made, the patient is no longer waiting for a decision
    owner:setMood("patient_wait", nil)
    if choice == "send_home" then
      owner:goHome()
      if owner.diagnosed then
        -- No treatment rooms
        owner:updateDynamicInfo(_S(59, 17))
      else
        -- No diagnosis rooms
        owner:updateDynamicInfo(_S(59, 16))
      end
    elseif choice == "wait" then
      -- Wait two months before going home
      owner.waiting = 60
      if owner.diagnosed then
        -- Waiting for treatment room
        owner:updateDynamicInfo(_S(59, 19))
      else
        -- Waiting for diagnosis room
        owner:updateDynamicInfo(_S(59, 18))
      end
    elseif choice == "guess_cure" then
      owner.diagnosed = true
      owner:setNextAction{
        name = "seek_room",
        room_type = owner.disease.treatment_rooms[1],
      }
      owner:updateDynamicInfo()
    elseif choice == "research" then
      -- TODO
    end
  end
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

local announcements = {
  "rand001.wav", "rand002.wav", "rand003.wav",
  "rand005.wav", "rand006.wav",                "rand008.wav",
  "rand009.wav", "rand010.wav",                "rand012.wav",
  "rand013.wav",                               "rand016.wav",
  "rand017.wav", "rand018.wav", "rand019.wav",
  "rand021.wav", "rand022.wav",                "rand024.wav",
  "rand025.wav", "rand026.wav", "rand027.wav", "rand028.wav",
  "rand029.wav", "rand030.wav", "rand031.wav", "rand032.wav",
  "rand033.wav", "rand034.wav", "rand035.wav", "rand036.wav",
  "rand037.wav", "rand038.wav", "rand039.wav", "rand040.wav",
  "rand041.wav",                               "rand044.wav",
  "rand045.wav", "rand046.wav",
  }

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
    print("Congratulations, you have unlocked cheats! .. or you would have, if this were the original game. Try something else.")
  elseif code == "112" then
    -- simple, unobfuscated cheat for everyone :)
    print("Random announcement cheat activated!")
    self.ui:playSound(announcements[math.random(1, #announcements)])
  elseif 0.0006422 < x and x < 0.0006423 then
    -- Bloaty head patient cheat
    -- Anyone with a 'large' head should be able to spot the required code
    print("Bloaty Head cheat activated!")
    self.ui.app.world:initDiseases(self.ui.app) -- undo any previous disease cheat, i.e. make all diseases available again
    local diseases = self.ui.app.world.available_diseases
    diseases[1] = diseases.bloaty_head
    for i = #diseases, 2, -1 do
      diseases[diseases[i].id] = nil
      diseases[i] = nil
    end
    diseases.bloaty_head = diseases[1]
  elseif 0.006602 < x and x < 0.006603 then
    -- Hairyitis cheat
    print("Hairyitis cheat activated!")
    self.ui.app.world:initDiseases(self.ui.app) -- undo any previous disease cheat, i.e. make all diseases available again
    local diseases = self.ui.app.world.available_diseases
    diseases[1] = diseases.hairyitis
    for i = #diseases, 2, -1 do
      diseases[diseases[i].id] = nil
      diseases[i] = nil
    end
    diseases.bloaty_head = diseases[1]
  elseif 27868.3 < x and x < 27868.4 then
    -- Roujin's challenge cheat
    local hosp = self.ui.hospital
    if not hosp.spawn_rate_cheat then
      print("Roujin's challenge activated! Good luck...")
      hosp.spawn_rate_cheat = true
    else
      print("Roujin's challenge deactivated.")
      hosp.spawn_rate_cheat = nil
    end
  elseif 7.8768e-11 < x and x < 7.8769e-11 then
    -- Crazy doctors enabled
    local hosp = self.ui.hospital
    if not hosp.crazy_doctors then
      print("Oh no! All doctors have gone crazy!")
      hosp:setCrazyDoctors(true)
    else
      print("Phew... the doctors regained their sanity.")
      hosp:setCrazyDoctors(nil)
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
