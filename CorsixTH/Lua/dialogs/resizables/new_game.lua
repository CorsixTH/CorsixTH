--[[ Copyright (c) 2010 Edvin "Lego3" Linge

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

--! Class for the difficulty choice window.
class "UINewGame" (UIResizable)

---@type UINewGame
local UINewGame = _G["UINewGame"]

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

local col_caption = {
  red = 174,
  green = 166,
  blue = 218,
}

local col_textbox = {
  red = 0,
  green = 0,
  blue = 0,
}

local col_highlight = {
  red = 174,
  green = 166,
  blue = 218,
}

local col_shadow = {
  red = 134,
  green = 126,
  blue = 178,
}

function UINewGame:UINewGame(ui)
  self:UIResizable(ui, 320, 220, col_bg)

  local app = ui.app
  self.esc_closes = true
  self.resizable = false
  self.modal_class = "main menu"
  self.on_top = true
  self:setDefaultPosition(0.5, 0.25)

  if TheApp.using_demo_files then
    -- We're using the demo version of TH. Load directly and activate the tutorial.
    -- Those who use the demo files probably want that anyway.
    self.start_tutorial = true
    self:startGame("full")
    self:close()
    return
  end

  self.border_sprites = app.gfx:loadSpriteTable("Bitmap", "aux_ui", true)
  self.start_tutorial = false
  self.difficulty = 1


  local avail_diff = {
    {text = _S.new_game_window.medium, tooltip = { _S.tooltip.new_game_window.medium,
     nil, 130 }, param = "full"}
  }
  if TheApp.fs:fileExists("Levels", "Easy01.SAM") then
    table.insert(avail_diff, 1, {text = _S.new_game_window.easy, tooltip = { _S.tooltip.new_game_window.easy,
     nil, 100 }, param = "easy"})
    self.difficulty = 2
  end
  if TheApp.fs:fileExists("Levels", "Hard01.SAM") then
    avail_diff[#avail_diff + 1] = {text = _S.new_game_window.hard, tooltip = { _S.tooltip.new_game_window.hard,
     nil, 175 }, param = "hard"}
  end
  self.available_difficulties = avail_diff

  self.default_button_sound = "selectx.wav"
  -- Window parts definition
  -- Title
  self:addBevelPanel(80, 10, 160, 20, col_caption):setLabel(_S.new_game_window.caption).lowered = true

  local pname = app.config.player_name
  self.player_name = (pname and pname:len() > 0) and pname or os.getenv("USER") or os.getenv("USERNAME") or "PLAYER"
  self:addBevelPanel(20, 45, 140, 30, col_shadow, col_bg, col_bg)
    :setLabel(_S.new_game_window.player_name).lowered = true
  self.name_textbox = self:addBevelPanel(165, 45, 140, 30, col_textbox, col_highlight, col_shadow)
    :setTooltip(_S.tooltip.new_game_window.player_name):setAutoClip(true)
    :makeTextbox(
    --[[persistable:new_game_confirm_name]]function()
      local name = self.name_textbox.text
      if not name:find("%S") then
        self.name_textbox:setText(self.player_name)
      else
        self.player_name = name
        self:saveToConfig()
      end
    end,
    --[[persistable:new_game_abort_name]]function() self.name_textbox:setText(self.player_name) end)
    :allowedInput({"alpha", "numbers", "misc"}):characterLimit(15):setText(self.player_name)

  -- Tutorial
  self:addBevelPanel(20, 80, 140, 30, col_shadow, col_bg, col_bg)
    :setLabel(_S.new_game_window.tutorial).lowered = true
  self:addBevelPanel(165, 80, 140, 30, col_bg):setLabel(_S.new_game_window.option_off)
    :makeToggleButton(0, 0, 135, 30, nil, self.buttonTutorial):setTooltip(_S.tooltip.new_game_window.tutorial)

  -- Difficulty
  self:addBevelPanel(20, 115, 140, 30, col_shadow, col_bg, col_bg)
    :setLabel(_S.new_game_window.difficulty).lowered = true
  self:addBevelPanel(165, 115, 140, 30, col_bg):setLabel(self.available_difficulties[self.difficulty].text)
    :makeToggleButton(0, 0, 135, 30, nil, self.dropdownDifficulty):setTooltip(_S.tooltip.new_game_window.difficulty)

  -- Start and Cancel
  self:addBevelPanel(20, 165, 140, 40, col_bg):setLabel(_S.new_game_window.start):makeButton(0, 0, 135, 40, nil, self.buttonStart):setTooltip(_S.tooltip.new_game_window.start)
  self:addBevelPanel(165, 165, 140, 40, col_bg):setLabel(_S.new_game_window.cancel):makeButton(0, 0, 135, 40, nil, self.buttonCancel):setTooltip(_S.tooltip.new_game_window.cancel)
end

function UINewGame:saveToConfig()
  self.ui.app.config.player_name = self.player_name
  self.ui.app:saveConfig()
end

function UINewGame:onMouseDown(button, x, y)
  local repaint = UIResizable.onMouseDown(self, button, x, y)
  if button == "left" and not repaint and not (x >= 0 and y >= 0 and
  x < self.width and y < self.height) and self:hitTest(x, y) then
    return self:beginDrag(x, y)
  end
  return repaint
end

function UINewGame:hitTest(x, y)
  if x >= 0 and y >= 0 and x < self.width and y < self.height then
    return true
  end
  local sprites = self.border_sprites
  if not sprites then
    return false
  end
  if x < -9 or y < -9 or x >= self.width + 9 or y >= self.height + 9 then
    return false
  end
  if (0 <= x and x < self.width) or (0 <= y and y < self.height) then
    return true
  end
  return sprites.hitTest(sprites, 10, x + 9,   y + 9) or
         sprites.hitTest(sprites, 12, x - 160, y + 9) or
         sprites.hitTest(sprites, 15, x + 9,   y - 240) or
         sprites.hitTest(sprites, 17, x - 160, y - 240)
end

function UINewGame:buttonTutorial(checked, button)
  self.start_tutorial = checked
  button.panel_for_sprite:setLabel(checked and _S.new_game_window.option_on or _S.new_game_window.option_off)
end

function UINewGame:dropdownDifficulty(activate, button)
  if activate and #self.available_difficulties > 1 then
    self.difficulty_dropdown = UIDropdown(self.ui, self, button, self.available_difficulties, self.selectDifficulty)
    self:addWindow(self.difficulty_dropdown)
  else
    if self.difficulty_dropdown then
      self.difficulty_dropdown:close()
      self.difficulty_dropdown = nil
    end
  end
end

function UINewGame:selectDifficulty(number)
  self.difficulty = number
end

function UINewGame:buttonStart()
  self.name_textbox:confirm()
  print("starting game with difficulty " .. self.available_difficulties[self.difficulty].param)
  self:startGame(self.available_difficulties[self.difficulty].param)
end

function UINewGame:startGame(difficulty)
  self.ui.app:loadLevel(1, difficulty)
  self.ui.app.moviePlayer:playAdvanceMovie(1)

  -- Initiate campaign progression. The UI above may now have changed.
  if not TheApp.using_demo_files then
    TheApp.world.campaign_info = "TH.campaign"
  end
  if self.start_tutorial then
    TheApp.ui.start_tutorial = true
    TheApp.ui:startTutorial()
  end
end

function UINewGame:buttonCancel()
  self.name_textbox:confirm()
  self:close()
end

function UINewGame:close()
  UIResizable.close(self)
  self.ui:addWindow(UIMainMenu(self.ui))
end
