--[[ Copyright (c) 2013 Mark (Mark L) Lawlor

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

--! Customise window used in the main menu and ingame.
class "UICustomise" (UIResizable)

---@type UICustomise
local UICustomise = _G["UICustomise"]

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

local col_shadow = {
  red = 134,
  green = 126,
  blue = 178,
}

local col_caption = {
  red = 174,
  green = 166,
  blue = 218,
}

function UICustomise:UICustomise(ui, mode)
  self:UIResizable(ui, 340, 350, col_bg)

  local app = ui.app
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options" or "customise"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  self.app = app

  -- Window parts definition
  -- Title
  self:addBevelPanel(85, 10, 170, 20, col_caption):setLabel(_S.customise_window.caption)
    .lowered = true

  -- Movies, global switch
  self:addBevelPanel(15, 40, 165, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.customise_window.movies):setTooltip(_S.tooltip.customise_window.movies).lowered = true
  self.movies_panel =
    self:addBevelPanel(185, 40, 140, 20, col_bg):setLabel(app.config.movies and _S.customise_window.option_on or _S.customise_window.option_off)
  self.movies_button = self.movies_panel:makeToggleButton(0, 0, 140, 20, nil, self.buttonMoviesGlobal)
    :setToggleState(app.config.movies):setTooltip(_S.tooltip.customise_window.movies)

  -- Intro movie
  self:addBevelPanel(15, 65, 165, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.customise_window.intro):setTooltip(_S.tooltip.customise_window.intro).lowered = true
  self.intro_panel =
    self:addBevelPanel(185, 65, 140, 20, col_bg):setLabel(app.config.play_intro and _S.customise_window.option_on or _S.customise_window.option_off)
  self.intro_button = self.intro_panel:makeToggleButton(0, 0, 140, 20, nil, self.buttonIntro)
    :setToggleState(app.config.play_intro):setTooltip(_S.tooltip.customise_window.intro)

  -- Allow user actions when paused
  self:addBevelPanel(15, 90, 165, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.customise_window.paused):setTooltip(_S.tooltip.customise_window.paused).lowered = true
  self.paused_panel =
    self:addBevelPanel(185, 90, 140, 20, col_bg):setLabel(app.config.allow_user_actions_while_paused and _S.customise_window.option_on or _S.customise_window.option_off)
  self.paused_button = self.paused_panel:makeToggleButton(0, 0, 140, 20, nil, self.buttonPaused)
    :setToggleState(app.config.allow_user_actions_while_paused):setTooltip(_S.tooltip.customise_window.paused)

  -- Volume down is opening casebook
  self:addBevelPanel(15, 115, 165, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.customise_window.volume):setTooltip(_S.tooltip.customise_window.volume).lowered = true
  self.volume_panel =
    self:addBevelPanel(185, 115, 140, 20, col_bg):setLabel(app.config.volume_opens_casebook and _S.customise_window.option_on or _S.customise_window.option_off)
  self.volume_button = self.volume_panel:makeToggleButton(0, 0, 140, 20, nil, self.buttonVolume)
    :setToggleState(app.config.volume_opens_casebook):setTooltip(_S.tooltip.customise_window.volume)

  -- Alien DNA from emergencies only/must stand/can knock on doors
  self:addBevelPanel(15, 140, 165, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.customise_window.aliens):setTooltip(_S.tooltip.customise_window.aliens).lowered = true
  self.aliens_panel =
    self:addBevelPanel(185, 140, 140, 20, col_bg):setLabel(app.config.alien_dna_only_by_emergency and _S.customise_window.option_on or _S.customise_window.option_off)
  self.aliens_button = self.aliens_panel:makeToggleButton(0, 0, 140, 20, nil, self.buttonAliens)
    :setToggleState(app.config.alien_dna_only_by_emergency):setTooltip(_S.tooltip.customise_window.aliens)

  -- Allow female patients with Fractured Bones
  self:addBevelPanel(15, 165, 165, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.customise_window.fractured_bones):setTooltip(_S.tooltip.customise_window.fractured_bones).lowered = true
  self.fractured_bones_panel =
    self:addBevelPanel(185, 165, 140, 20, col_bg):setLabel(app.config.disable_fractured_bones_females and _S.customise_window.option_on or _S.customise_window.option_off)
  self.fractured_bones_button = self.fractured_bones_panel:makeToggleButton(0, 0, 140, 20, nil, self.buttonFractured_bones)
    :setToggleState(app.config.disable_fractured_bones_females):setTooltip(_S.tooltip.customise_window.fractured_bones)

  -- Allow average contents when building rooms
  self:addBevelPanel(15, 190, 165, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.customise_window.average_contents):setTooltip(_S.tooltip.customise_window.average_contents).lowered = true
  self.average_contents_panel =
    self:addBevelPanel(185, 190, 140, 20, col_bg):setLabel(app.config.enable_avg_contents and _S.customise_window.option_on or _S.customise_window.option_off)
  self.average_contents_button = self.average_contents_panel:makeToggleButton(0, 0, 140, 20, nil, self.buttonAverage_contents)
    :setToggleState(app.config.enable_avg_contents):setTooltip(_S.tooltip.customise_window.average_contents)

  -- Allow removal of destroyed rooms
  self:addBevelPanel(15, 215, 165, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.customise_window.remove_destroyed_rooms):setTooltip(_S.tooltip.customise_window.remove_destroyed_rooms).lowered = true
  self.destroyed_rooms_panel =
    self:addBevelPanel(185, 215, 140, 20, col_bg):setLabel(app.config.remove_destroyed_rooms and _S.customise_window.option_on or _S.customise_window.option_off)
  self.destroyed_rooms_button = self.destroyed_rooms_panel:makeToggleButton(0, 0, 140, 20, nil, self.buttonDestroyed_rooms)
    :setToggleState(app.config.remove_destroyed_rooms):setTooltip(_S.tooltip.customise_window.remove_destroyed_rooms)

  -- Allow machine menu button in a toolbar
  self:addBevelPanel(15, 240, 165, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.customise_window.machine_menu_button):setTooltip(_S.tooltip.customise_window.machine_menu_button).lowered = true
  self.machine_menu_panel =
    self:addBevelPanel(185, 240, 140, 20, col_bg):setLabel(app.config.machine_menu_button and _S.customise_window.option_on or _S.customise_window.option_off)
  self.machine_menu_button = self.machine_menu_panel:makeToggleButton(0, 0, 140, 20, nil, self.buttonMachine_menu)
    :setToggleState(app.config.machine_menu_button):setTooltip(_S.tooltip.customise_window.machine_menu_button)

  -- Allow user to disable screen shake during earthquakes
  self:addBevelPanel(15, 265, 165, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.customise_window.enable_screen_shake):setTooltip(_S.tooltip.customise_window.enable_screen_shake).lowered = true
  self.screen_shake_panel =
    self:addBevelPanel(185, 265, 140, 20, col_bg):setLabel(app.config.enable_screen_shake and _S.customise_window.option_on or _S.customise_window.option_off)
  self.screen_shake_button = self.screen_shake_panel:makeToggleButton(0, 0, 140, 20, nil, self.buttonScreen_shake)
    :setToggleState(app.config.enable_screen_shake):setTooltip(_S.tooltip.customise_window.enable_screen_shake)

  -- "Back" button
  self:addBevelPanel(15, 295, 310, 40, col_bg):setLabel(_S.customise_window.back)
    :makeButton(0, 0, 310, 40, nil, self.buttonBack):setTooltip(_S.tooltip.customise_window.back)
end

function UICustomise:buttonAudioGlobal()
  local window = UIAudio(self.ui, "menu")
  self.ui:addWindow(window)
end

function UICustomise:buttonMoviesGlobal()
  local app = self.ui.app
  app.config.movies = not app.config.movies
  self.movies_button:toggle()
  self.movies_panel:setLabel(app.config.movies and _S.customise_window.option_on or _S.customise_window.option_off)
  self:reload()
  app:saveConfig()
end

function UICustomise:buttonIntro()
  local app = self.ui.app
  app.config.play_intro = not app.config.play_intro
  self.intro_button:toggle()
  self.intro_panel:setLabel(app.config.play_intro and _S.customise_window.option_on or _S.customise_window.option_off)
  self:reload()
  app:saveConfig()
end

function UICustomise:buttonPaused()
  local app = self.ui.app
  app.config.allow_user_actions_while_paused = not app.config.allow_user_actions_while_paused
  self.paused_button:toggle()
  self.paused_panel:setLabel(app.config.allow_user_actions_while_paused and _S.customise_window.option_on or _S.customise_window.option_off)
  self:reload()
  app:saveConfig()
end

function UICustomise:buttonVolume()
  local app = self.ui.app
  app.config.volume_opens_casebook = not app.config.volume_opens_casebook
  self.volume_button:toggle()
  self.volume_panel:setLabel(app.config.volume_opens_casebook and _S.customise_window.option_on or _S.customise_window.option_off)
  self:reload()
  app:saveConfig()
end

function UICustomise:buttonAliens()
  local app = self.ui.app
  app.config.alien_dna_only_by_emergency = not app.config.alien_dna_only_by_emergency
  app.config.alien_dna_must_stand = not app.config.alien_dna_must_stand
  app.config.alien_dna_can_knock_on_doors = not app.config.alien_dna_can_knock_on_doors
  self.aliens_button:toggle()
  self.aliens_panel:setLabel(app.config.alien_dna_only_by_emergency and _S.customise_window.option_on or _S.customise_window.option_off)
  app:saveConfig()
  self:reload()
  local err = {_S.errors.alien_dna}
  self.ui:addWindow(UIInformation(self.ui, err))
end

function UICustomise:buttonFractured_bones()
  local app = self.ui.app
  app.config.disable_fractured_bones_females = not app.config.disable_fractured_bones_females
  self.fractured_bones_button:toggle()
  self.fractured_bones_panel:setLabel(app.config.disable_fractured_bones_females and _S.customise_window.option_on or _S.customise_window.option_off)
  app:saveConfig()
  self:reload()
  local err = {_S.errors.fractured_bones}
  self.ui:addWindow(UIInformation(self.ui, err))
end

function UICustomise:buttonAverage_contents()
  local app = self.ui.app
  app.config.enable_avg_contents = not app.config.enable_avg_contents
  self.average_contents_button:toggle()
  self.average_contents_panel:setLabel(app.config.enable_avg_contents and _S.customise_window.option_on or _S.customise_window.option_off)
  app:saveConfig()
  self:reload()
end

function UICustomise:buttonDestroyed_rooms()
  local app = self.ui.app
  app.config.remove_destroyed_rooms = not app.config.remove_destroyed_rooms
  self.destroyed_rooms_button:toggle()
  self.destroyed_rooms_panel:setLabel(app.config.remove_destroyed_rooms and _S.customise_window.option_on or _S.customise_window.option_off)
  app:saveConfig()
  self:reload()
end

function UICustomise:buttonMachine_menu()
  local app = self.ui.app
  app.config.machine_menu_button = not app.config.machine_menu_button
  self.destroyed_rooms_button:toggle()
  self.destroyed_rooms_panel:setLabel(app.config.machine_menu_button and _S.customise_window.option_on or _S.customise_window.option_off)
  app:saveConfig()
  self:reload()
end

function UICustomise:buttonScreen_shake()
  local app = self.ui.app
  app.config.enable_screen_shake = not app.config.enable_screen_shake
  self.screen_shake_button:toggle()
  self.screen_shake_panel:setLabel(app.config.enable_screen_shake and _S.customise_window.option_on or _S.customise_window.option_off)
  app:saveConfig()
  self:reload()
end

function UICustomise:buttonBack()
  self:close()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

-- So that we can see the option has been changed reload the menu
function UICustomise:reload()
  local window = UICustomise(self.ui, "menu")
  self.ui:addWindow(window)
end

function UICustomise:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end
