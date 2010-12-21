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

--! Constructor for the Information Dialog.
--!param text The text to show, held in a table. All elements of the table will be written
-- beneath each other. If instead a table within the table is supplied the texts
-- will be shown in consecutive dialogs.
function UIInformation:UIInformation(ui, text)
  self:Window()
  
  local app = ui.app
  self.modal_class = "information"
  self.esc_closes = true
  self.on_top = true
  self.ui = ui
  self.panel_sprites = app.gfx:loadSpriteTable("Data", "PulldV", true)
  self.black_font = app.gfx:loadFont("QData", "Font00V")
  
  if type(text[1]) == "table" then
    self.text = text[1][1]
    table.remove(text[1], 1)
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
  self:addKeyHandler("Enter", self.close)
end

function UIInformation:onChangeLanguage()
  local rows = 0
  for i, text in ipairs(self.text) do
    local old_rows = rows
    rows = rows + math.floor(self.black_font:sizeOf(text) / 300 + 1)
    rows = rows + 1
  end
  
  self.width = self.spacing.l + self.text_width + self.spacing.r
  self.height = self.spacing.t + rows*12 + self.spacing.b
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
  local white = canvas:mapRGB(255, 255, 255)
  canvas:drawRect(white, dx + 4, dy + 4, self.width - 8, self.height - 8)
  local last_y = dy + self.spacing.t
  for i, text in ipairs(self.text) do
    last_y = self.black_font:drawWrapped(canvas, text:gsub("//", ""), dx + self.spacing.l, last_y, self.text_width)
    last_y = self.black_font:drawWrapped(canvas, " ",                 dx + self.spacing.l, last_y, self.text_width)
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
  if self.additional_text and #self.additional_text[1] > 0 then
    self.ui:addWindow(UIInformation(self.ui, self.additional_text))
  end
end
