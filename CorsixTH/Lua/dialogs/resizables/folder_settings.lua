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
class "UIFolder" (UIResizable)

---@type UIFolder
local UIFolder = _G["UIFolder"]

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

function UIFolder:UIFolder(ui, mode)
  self:UIResizable(ui, 360, 240, col_bg)

  local app = ui.app
  self.mode = mode
  self.modal_class = mode == "menu" and "main menu" or "options" or "folders"
  self.on_top = mode == "menu"
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  self.app = app

  -- Window parts definition
  -- Title
  self:addBevelPanel(80, 10, 200, 20, col_caption):setLabel(_S.folders_window.caption)
    .lowered = true

  -- Location of original game
  local built_in = app.gfx:loadMenuFont()

  self:addBevelPanel(20, 50, 130, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.folders_window.data_label)
    :setTooltip(_S.tooltip.folders_window.data_location)
    .lowered = true
  self:addBevelPanel(160, 50, 180, 20, col_bg)
    :setLabel(app.config.theme_hospital_install, built_in)
    :setAutoClip(true)
    :makeButton(0, 0, 180, 20, nil, self.buttonBrowseForTHInstall)
    :setTooltip(_S.tooltip.folders_window.browse_data:format(app.config.theme_hospital_install))

  -- Location of font file
  local font_location_label = app.config.unicode_font and app.config.unicode_font or _S.tooltip.folders_window.no_font_specified
  local tooltip_font = app.config.unicode_font and _S.tooltip.folders_window.browse_font:format(app.config.unicode_font) or _S.tooltip.folders_window.no_font_specified

  self:addBevelPanel(20, 75, 130, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.folders_window.font_label)
    :setTooltip(_S.tooltip.folders_window.font_location)
    .lowered = true
  self.fonts_panel = self:addBevelPanel(160, 75, 160, 20, col_bg)
    :setLabel(font_location_label, built_in)
    :setAutoClip(true)
    :makeButton(0, 0, 160, 20, nil, self.buttonBrowseForFont)
    :setTooltip(tooltip_font)

  -- Location saves alternative
  local default_savegame_dir = app:getDefaultSavegameDir()
  local saves_location = app.config.savegames and app.config.savegames or default_savegame_dir
  local tooltip_saves = _S.tooltip.folders_window.browse_saves:format(saves_location)

  self:addBevelPanel(20, 100, 130, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.folders_window.savegames_label):setTooltip(_S.tooltip.folders_window.savegames_location)
    .lowered = true
  self.saves_panel = self:addBevelPanel(160, 100, 160, 20, col_bg)
    :setLabel(saves_location , built_in)
    :setAutoClip(true)
    :makeButton(0, 0, 160, 20, nil, self.buttonBrowseForSavegames)
    :setTooltip(tooltip_saves)
  self:addBevelPanel(320, 100, 20, 20, col_bg)
    :setLabel("X")
    :makeButton(0, 0, 20, 20, nil, self.resetSavegameDir)
    :setTooltip(_S.tooltip.folders_window.reset_to_default:format(default_savegame_dir))

  -- location for screenshots
  local default_screenshots_dir = app:getDefaultScreenshotsDir()
  local screenshots_location = app.config.screenshots and app.config.screenshots or default_screenshots_dir
  local tooltip_screenshots = _S.tooltip.folders_window.browse_screenshots:format(screenshots_location)

  self:addBevelPanel(20, 125, 130, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.folders_window.screenshots_label):setTooltip(_S.tooltip.folders_window.screenshots_location)
    .lowered = true
  self.screenshots_panel = self:addBevelPanel(160, 125, 160, 20, col_bg)
    :setLabel(screenshots_location, built_in)
    :setAutoClip(true)
    :makeButton(0, 0, 160, 20, nil, self.buttonBrowseForScreenshots)
    :setTooltip(tooltip_screenshots)
  self:addBevelPanel(320, 125, 20, 20, col_bg)
    :setLabel("X")
    :makeButton(0, 0, 20, 20, nil, self.resetScreenshotDir)
    :setTooltip(_S.tooltip.folders_window.reset_to_default:format(default_screenshots_dir))

 -- location for music files
  local music_location_label = app.config.audio_music and app.config.audio_music or _S.tooltip.folders_window.not_specified
  local tooltip_music = app.config.audio_music and _S.tooltip.folders_window.browse_music:format(app.config.audio_music) or _S.tooltip.folders_window.not_specified

  self:addBevelPanel(20, 150, 130, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.folders_window.music_label):setTooltip(_S.tooltip.folders_window.music_location)
    .lowered = true
  self.music_panel = self:addBevelPanel(160, 150, 180, 20, col_bg)
    :setLabel(music_location_label, built_in)
    :setAutoClip(true)
    :makeButton(0, 0, 160, 20, nil, self.buttonBrowseForAudio_music)
    :setTooltip(tooltip_music)
  self:addBevelPanel(320, 150, 20, 20, col_bg)
    :setLabel("X")
    :makeButton(0, 0, 20, 20, nil, self.resetMusicDir)
    :setTooltip(_S.tooltip.folders_window.clear_directory)

  -- "Back" button
  self:addBevelPanel(20, 180, 320, 40, col_bg)
    :setLabel(_S.folders_window.back)
    :makeButton(0, 0, 320, 40, nil, self.buttonBack)
    :setTooltip(_S.tooltip.folders_window.back)
  self.built_in_font = built_in
end

function UIFolder:resetSavegameDir()
  local app = TheApp
  local default_savegame_dir = app:getDefaultSavegameDir()
  local tooltip_saves = _S.tooltip.folders_window.browse_saves:format(default_savegame_dir)
  app.config.savegames = nil
  app:saveConfig()
  app:initSavegameDir()
  self.saves_panel:setLabel(default_savegame_dir, self.built_in_font)
  self.saves_panel:setTooltip(tooltip_saves)
end

function UIFolder:resetScreenshotDir()
  local app = TheApp
  local default_screenshots_dir = app:getDefaultScreenshotsDir()
  local tooltip_screenshots = _S.tooltip.folders_window.browse_screenshots:format(default_screenshots_dir)
  app.config.screenshots = nil
  app:saveConfig()
  app:initScreenshotsDir()
  self.screenshots_panel:setLabel(default_screenshots_dir, self.built_in_font)
  self.screenshots_panel:setTooltip(tooltip_screenshots)
end

function UIFolder:resetMusicDir()
  local app = TheApp
  local label_music = _S.tooltip.folders_window.not_specified
  local tooltip_music = _S.tooltip.folders_window.not_specified
  app.config.audio_music = nil
  app:saveConfig()
  app.audio:init()
  self.music_panel:setLabel(label_music, self.built_in_font)
  self.music_panel:setTooltip(tooltip_music)
end

function UIFolder:buttonBrowseForFont()
  local browser = UIChooseFont(self.ui, self.mode)
  self.ui:addWindow(browser)
end

function UIFolder:buttonBrowseForSavegames()
  local app = TheApp
  local old_path = app.config.savegames
  local function callback(path)
    if old_path ~= path then
      app.config.savegames = path
      app:saveConfig()
      app:initSavegameDir()
      self.saves_panel:setLabel(app.config.savegames, self.built_in_font)
    end
  end
  local browser = UIDirectoryBrowser(self.ui, self.mode, _S.folders_window.savegames_location, "DirTreeNode", callback)
  self.ui:addWindow(browser)
end

function UIFolder:buttonBrowseForTHInstall()
  local function callback(path)
    local app = TheApp
    app.config.theme_hospital_install = path
    app:saveConfig()
    debug.getregistry()._RESTART = true
    app.running = false
  end
  local browser = UIDirectoryBrowser(self.ui, self.mode, _S.folders_window.new_th_location, "InstallDirTreeNode", callback)
  self.ui:addWindow(browser)
end

function UIFolder:buttonBrowseForScreenshots()
  local app = TheApp
  local old_path = app.config.screenshots
  local function callback(path)
    if old_path ~= path then
      app.config.screenshots = path
      app:saveConfig()
      app:initScreenshotsDir()
      self.screenshots_panel:setLabel(app.config.screenshots, self.built_in_font)
    end
  end
  local browser = UIDirectoryBrowser(self.ui, self.mode, _S.folders_window.screenshots_location, "DirTreeNode", callback)
  self.ui:addWindow(browser)
end

function UIFolder:buttonBrowseForAudio_music()
  local function callback(path)
    local app = TheApp
    app.config.audio_music = path
    app:saveConfig()
    app.audio:init()
    self.music_panel:setLabel(app.config.audio_music, self.built_in_font)
  end
  local browser = UIDirectoryBrowser(self.ui, self.mode, _S.folders_window.music_location, "DirTreeNode", callback)
  self.ui:addWindow(browser)
end

function UIFolder:buttonBack()
  self:close()
  local window = UIOptions(self.ui, "menu")
  self.ui:addWindow(window)
end

function UIFolder:close()
  UIResizable.close(self)
  if self.mode == "menu"  then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end
