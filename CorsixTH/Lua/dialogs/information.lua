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

--! Dialog that informs the player of for example what the goals for the level are.
class "UIInformation" (Window)

---@type UIInformation
local UIInformation = _G["UIInformation"]

--! Constructor for the Information Dialog.
--!param text The text to show, held in a table. All elements of the table will be written
-- beneath each other. If instead a table within the table is supplied the texts
-- will be shown in consecutive dialogs.
--!param use_built_in_font Whether the built-in font should be used to make sure that
-- the given message can be read without distortions.
function UIInformation:UIInformation(ui, text, use_built_in_font)
  self:Window()

  local app = ui.app
  self.modal_class = "information"
  self.esc_closes = true
  self.on_top = true
  self.ui = ui
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "PulldV", true)
  if not use_built_in_font then
    self.black_font = app.gfx:loadFont("QData", "Font00V")
  else
    self.black_font = app.gfx:loadBuiltinFont()
    self.black_background = true
  end

  if type(text[1]) == "table" then
    self.text = text[1]
    table.remove(text, 1)
    self.additional_text = text
  else
    self.text = text
  end

  -- Window size parameters
  self.text_width = 300
  self.spacing = {
    l = 40,
    r = 40,
    t = 20,
    b = 20,
  }

  self:onChangeLanguage()

  -- Enter closes the window
  self:addKeyHandler("return", self.close)
  self:addKeyHandler("keypad enter", self.close)
end

function UIInformation:onChangeLanguage()
  local total_req_height = 0
  for i, text in ipairs(self.text) do
    local req_width, req_height = self.black_font:sizeOf(text, self.text_width)
    total_req_height = total_req_height + req_height
  end

  self.width = self.spacing.l + self.text_width + self.spacing.r
  self.height = self.spacing.t + total_req_height + self.spacing.b
  self:setDefaultPosition(0.5, 0.5)

  self:removeAllPanels()

  for x = 4, self.width - 4, 4 do
    self:addPanel(12, x, 0)  -- Dialog top and bottom borders
    self:addPanel(16, x, self.height-4)
  end
  for y = 4, self.height - 4, 4 do
    self:addPanel(18, 0, y)  -- Dialog left and right borders
    self:addPanel(14, self.width-4, y)
  end
  self:addPanel(11, 0, 0)  -- Border top left corner
  self:addPanel(17, 0, self.height-4)  -- Border bottom left corner
  self:addPanel(13, self.width-4, 0)  -- Border top right corner
  self:addPanel(15, self.width-4, self.height-4)  -- Border bottom right corner

  -- Close button
  self:addPanel(19, self.width - 30, self.height - 30):makeButton(0, 0, 18, 18, 20, self.close):setTooltip(_S.tooltip.information.close)
end

function UIInformation:draw(canvas, x, y)
  local dx, dy = x + self.x, y + self.y
  local background = self.black_background and canvas:mapRGB(0, 0, 0) or canvas:mapRGB(255, 255, 255)
  canvas:drawRect(background, dx + 4, dy + 4, self.width - 8, self.height - 8)
  local last_y = dy + self.spacing.t
  for i, text in ipairs(self.text) do
    last_y = self.black_font:drawWrapped(canvas, text, dx + self.spacing.l, last_y, self.text_width)
  end

  Window.draw(self, canvas, x, y)
end

function UIInformation:hitTest(x, y)
  if x >= 0 and y >= 0 and x < self.width and y < self.height then
    return true
  else
    return Window.hitTest(self, x, y)
  end
end

function UIInformation:close()
  self.ui:tutorialStep(3, 16, "next")
  Window.close(self)
  if self.additional_text and #self.additional_text > 0 then
    self.ui:addWindow(UIInformation(self.ui, self.additional_text))
  end
end

function UIInformation:afterLoad(old, new)
  if old < 101 then
    self:removeKeyHandler("enter")
    self:addKeyHandler("return", self.close)
  end
  if old < 104 then
    self:addKeyHandler("keypad enter", self.close)
  end
end
