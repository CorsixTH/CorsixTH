--[[ Copyright (c) 2013 Alan Woolley

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

--! Options window used in the main menu and ingame.
class "UIUpdate" (UIResizable)

---@type UIUpdate
local UIUpdate = _G["UIUpdate"]

local col_bg = {
  red = 154,
  green = 146,
  blue = 198,
}

local col_button = {
  red = 84,
  green = 200,
  blue = 84,
}


local col_old_version = {
  red = 255,
  green = 0,
  blue = 0,
}

local col_new_version = {
  red = 0,
  green = 255,
  blue = 0,
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

function UIUpdate:UIUpdate(ui, this_version, new_version, brief_description, download_url)
  self:UIResizable(ui, 320, 320, col_bg)

  local app = ui.app
  self.modal_class = "main"
  self.on_top = true
  self.esc_closes = true
  self.resizable = false
  self:setDefaultPosition(0.5, 0.25)
  self.default_button_sound = "selectx.wav"
  self.description_text = brief_description
  self.app = app
  self.white_font = app.gfx:loadFont("QData", "Font01V")
  self.download_url = download_url

  local pathsep = package.config:sub(1, 1)

  if pathsep == "\\" then
    self.os_is_windows = true
  else
    self.os_is_windows = false
  end

  self:addBevelPanel(20, 50, 140, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.update_window.current_version).lowered = true
  self:addBevelPanel(20, 70, 140, 20, col_shadow, col_bg, col_bg)
    :setLabel(_S.update_window.new_version).lowered = true

  self:addBevelPanel (160,50,140,20, col_old_version, col_bg, col_bg):setLabel(this_version)
  self:addBevelPanel (160,70,140,20, col_new_version, col_bg, col_bg):setLabel(new_version)

  -- Title
  self:addBevelPanel(80, 10, 160, 20, col_caption):setLabel(_S.update_window.caption)
    .lowered = true

  -- Download button
  self:addBevelPanel(20, 225, 280, 40, col_bg):setLabel(_S.update_window.download)
    :makeButton(0, 0, 280, 40, nil, self.buttonDownload):setTooltip(_S.tooltip.update_window.download)

  -- Ignore button
  self:addBevelPanel(20, 270, 280, 40, col_bg):setLabel(_S.update_window.ignore)
    :makeButton(0, 0, 280, 40, nil, self.buttonIgnore):setTooltip(_S.tooltip.update_window.ignore)
end

function UIUpdate:draw(canvas, x, y)
  -- Draw window components
  UIResizable.draw(self, canvas, x, y)

  -- Draw description
  x, y = self.x + x, self.y + y
  self.white_font:drawWrapped(canvas, self.description_text, x + 20, y + 100, self.width - 20)
end

function UIUpdate:buttonDownload()

  if self.os_is_windows then
    os.execute("start " .. self.download_url)
  else
    os.execute("xdg-open " .. self.download_url)
  end

end

function UIUpdate:buttonIgnore()
  self:close()
end




