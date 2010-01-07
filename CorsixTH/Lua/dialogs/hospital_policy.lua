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

dofile "dialogs/fullscreen"

class "UIPolicy" (UIFullscreen)

function UIPolicy:UIPolicy(ui, disease_selection)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  self.background = gfx:loadRaw("Pol01V", 640, 480)
  local palette = gfx:loadPalette("QData", "Pol01V.pal")
  palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
  self.panel_sprites = gfx:loadSpriteTable("QData", "Pol02V", true, palette)
  self.label_font = gfx:loadFont("QData", "Font74V", false, palette)
  self.text_font = gfx:loadFont("QData", "Font105V", false, palette)
  
  local hosp = ui.hospital
  self.hospital = hosp
  
  local function allowStaff(name, state, btn)
    if name == "Allow" then
      if self.prohibit_button.toggled then -- Changing setting from prohibit to allow
        hosp.policies["staff_allowed_to_move"] = true
        self.prohibit_button:toggle()
      else -- Already allowed, toggle again
        self.allow_button:toggle()
      end
    else -- Clicking the prohibit button
      if self.allow_button.toggled then -- Changing setting from allow to prohibit
        hosp.policies["staff_allowed_to_move"] = false
        self.allow_button:toggle()
      else -- Already prohibited, toggle again
        self.prohibit_button:toggle()
      end
    end
  end
  
  -- Buttons
  self:addPanel(0, 607, 447):makeButton(0, 0, 26, 26, 6, self.close)
  self.allow_button = self:addPanel(0, 348, 379):makeToggleButton(0, 0, 48, 17, 4, allowStaff, "Allow") -- Allow staff to move
  self.prohibit_button = self:addPanel(0, 395, 379):makeToggleButton(0, 0, 48, 17, 5, allowStaff, "Prohibit") -- Prohibit staff to move
  
  if self.hospital.policies["staff_allowed_to_move"] then
    self.allow_button:toggle()
  else
    self.prohibit_button:toggle()
  end
  
  -- Slider positions
  local guess = 129 + hosp.policies["guess_cure"]*299
  local home = 129 + hosp.policies["send_home"]*299
  local stop = 124 + hosp.policies["stop_procedure"]*299
  local staffroom = 149 + hosp.policies["goto_staffroom"]*250
  
  -- Sliders
  self.sliders = {}
  self.sliders["guess_cure"] = self:addPanel(2, guess, 119, 82, 44)
  self.sliders["send_home"] = self:addPanel(1, home, 135, 82, 28)
  self.sliders["stop_procedure"] = self:addPanel(3, stop, 210, 92, 28)
  self.sliders["goto_staffroom"] = self:addPanel(3, staffroom, 285, 92, 28)
  self.sliders["guess_cure"].min_x = home
  self.sliders["guess_cure"].total_min_x = 129 -- Needed to get the correct value set
  self.sliders["guess_cure"].max_x = 428
  self.sliders["send_home"].min_x = 129
  self.sliders["send_home"].max_x = guess
  self.sliders["send_home"].total_max_x = 428
  self.sliders["stop_procedure"].min_x = 124
  self.sliders["stop_procedure"].max_x = 423
  self.sliders["goto_staffroom"].min_x = 149
  self.sliders["goto_staffroom"].max_x = 399
end

function UIPolicy:draw(canvas)
  self.background:draw(canvas, self.x, self.y)
  UIFullscreen.draw(self, canvas)
  
  local x, y = self.x, self.y
  local text = self.text_font
  local label = self.label_font

  -- Labels on the panels
  local added_x, added_y = self.sliders["send_home"].x, self.sliders["send_home"].y
  label:draw(canvas, _S(18, 7), x + added_x, y + added_y + 2, 82, 0) -- SEND HOME
  added_x, added_y = self.sliders["guess_cure"].x, self.sliders["guess_cure"].y
  label:draw(canvas, _S(18, 6), x + added_x, y + added_y + 2, 82, 0) -- GUESS AT CURE
  added_x, added_y = self.sliders["stop_procedure"].x, self.sliders["stop_procedure"].y
  label:draw(canvas, _S(18, 8), x + added_x, y + added_y + 2, 92, 0) -- STOP PROCEDURE
  added_x, added_y = self.sliders["goto_staffroom"].x, self.sliders["goto_staffroom"].y
  label:draw(canvas, _S(18, 9), x + added_x, y + added_y + 2, 92, 0) -- GO TO STAFF ROOM
  
  -- All other text
  text:draw(canvas, _S(18, 1), x + 160, y + 78, 300, 0) -- Hospital Policy
  text:draw(canvas, _S(18, 2), x + 161, y + 100) -- diagnosis procedure
  text:draw(canvas, _S(18, 3), x + 161, y + 181) -- diagnosis termination
  text:draw(canvas, _S(18, 4), x + 161, y + 262) -- send staff to rest
  text:draw(canvas, _S(18, 5), x + 161, y + 374) -- staff leave rooms

end

function UIPolicy:onMouseMove(x, y, dx, dy)
  local repaint = Window.onMouseMove(self, x, y, dx, dy)
  if self.moving_panel then -- A slider is being moved.
    local p = self.moving_panel
    self.moved_x = self.moved_x + dx
    local new_x = self.moved_x + self.down_x - self.moving_panel.w / 2 - self.offset
    if new_x > p.min_x then
      if new_x < p.max_x then
        self.moving_panel.x = new_x
        self.position_x = new_x
      else
        self.moving_panel.x = self.moving_panel.max_x
        self.position_x = self.moving_panel.max_x
      end
    else
      self.moving_panel.x = self.moving_panel.min_x
      self.position_x = self.moving_panel.min_x
    end
    repaint = true
  end
  return repaint
end

function UIPolicy:onMouseDown(code, x, y)
  if code == "left" then
    self.moving_panel = self:panelHit(x, y)
    if self.moving_panel then
      self.down_x = x
      self.offset = x - (self.moving_panel.x + self.moving_panel.w / 2)
      self.moved_x = 0
      self.position_x = self.moving_panel.x
    end
  end
  return Window.onMouseDown(self, code, x, y)
end

function UIPolicy:onMouseUp(code, x, y)
  if self.moving_panel then
    if self.moving_panel == self.sliders["guess_cure"] then
      self.sliders["send_home"].max_x = self.position_x
    elseif self.moving_panel == self.sliders["send_home"] then
      self.sliders["guess_cure"].min_x = self.position_x
    end
  end
  self.moving_panel = nil
  return Window.onMouseUp(self, code, x, y)
end

function UIPolicy:panelHit(x, y)
  for name, panel in pairs(self.sliders) do
    if x > panel.x and y > panel.y and x < panel.x + panel.w and y < panel.y + panel.h then
      return panel
    end
  end
end

function UIPolicy:close()
  for key, s in pairs(self.sliders) do
    local divider = (s.total_max_x or s.max_x) - (s.total_min_x or s.min_x)
    self.hospital.policies[key] = (s.x - (s.total_min_x or s.min_x))/divider
  end
  Window.close(self)
end

