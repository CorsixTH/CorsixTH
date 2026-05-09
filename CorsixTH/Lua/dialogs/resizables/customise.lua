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

local col = {
  bg             = Colours.PanelDefault,
}

function UICustomise:UICustomise(ui, mode)
  self:UIResizable(ui, 340, 375, col.bg)

  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options" or "customise"
  self.strings_ref = "customise_window"

  -- Window parts definition
  self.label_width = 165

  self.entry_list = {
    -- Movies, global switch
    { name = "movies" },
    -- Intro movie
    { name = "play_intro" },
    -- Allow user actions when paused
    { name = "allow_user_actions_while_paused" },
    -- Alien DNA from emergencies only/must stand/can knock on doors
    { name = "alien_dna_only_by_emergency", func = self.buttonAliens,
        custom_labels = true, err = true },
    -- Allow female patients with Fractured Bones
    { name = "disable_fractured_bones_females", custom_labels = true, err = true },
    -- Allow average contents when building rooms
    { name = "enable_avg_contents" },
    -- Allow removal of destroyed rooms
    { name = "remove_destroyed_rooms" },
    -- Allow machine menu button in a toolbar
    { name = "machine_menu_button" },
    -- Allow user to disable screen shake during earthquakes
    { name = "enable_screen_shake" },
    -- Add subtitles for announcer messages
    { name = "enable_announcer_subtitles" }
  }

  self:buildDialog()
end

function UICustomise:buttonAliens(app)
  app.config.alien_dna_only_by_emergency = not app.config.alien_dna_only_by_emergency
  app.config.alien_dna_must_stand = not app.config.alien_dna_must_stand
  app.config.alien_dna_can_knock_on_doors = not app.config.alien_dna_can_knock_on_doors
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
