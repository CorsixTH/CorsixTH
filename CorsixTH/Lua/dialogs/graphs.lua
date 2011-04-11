--[[ Copyright (c) 2011 Ted "IntelOrca" John

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

--! Charts fullscreen window
class "UIGraphs" (UIFullscreen)

function UIGraphs:UIGraphs(ui)
  self:UIFullscreen(ui)
  local gfx = ui.app.gfx
  if not pcall(function()
    self.background = gfx:loadRaw("Graph01V", 640, 480)
    local palette = gfx:loadPalette("QData", "Graph01V.pal")
    palette:setEntry(255, 0xFF, 0x00, 0xFF) -- Make index 255 transparent
    self.panel_sprites = gfx:loadSpriteTable("QData", "Graph02V", true, palette)
    self.white_font = gfx:loadFont("QData", "Font01V", false, palette)
  end) then
    ui:addWindow(UIInformation(ui, {_S.errors.dialog_missing_graphics}))
    self:close()
    return
  end
  
  local hosp = ui.hospital
  self.hospital = hosp
  
  -- Buttons
  self:addPanel(0, 63, 384):makeButton(0, 0, 26, 26, 3, self.close):setTooltip(_S.tooltip.graphs.close)
  
  self.graph_scale_panel = self:addPanel(0, 371, 384)
  self.graph_scale_button = self.graph_scale_panel:makeButton(0, 0, 65, 26, 2, self.toggleGraphScale):setTooltip(_S.tooltip.graphs.scale)
  
  self.hide_graph = {}
  
  local function buttons(num)
    return --[[persistable:graphs_button]] function()
      self:toggleGraph(num)
    end
  end
  self.graph_buttons = {
    self:addPanel(0, 590, 34):makeToggleButton(0, 0, 42, 42, 1, buttons(1)):setTooltip(_S.tooltip.graphs.money_in),
    self:addPanel(0, 590, 86):makeToggleButton(0, 0, 42, 42, 1, buttons(2)):setTooltip(_S.tooltip.graphs.money_out),
    self:addPanel(0, 590, 138):makeToggleButton(0, 0, 42, 42, 1, buttons(3)):setTooltip(_S.tooltip.graphs.wages),
    self:addPanel(0, 590, 190):makeToggleButton(0, 0, 42, 42, 1, buttons(4)):setTooltip(_S.tooltip.graphs.balance),
    self:addPanel(0, 590, 243):makeToggleButton(0, 0, 42, 42, 1, buttons(5)):setTooltip(_S.tooltip.graphs.visitors),
    self:addPanel(0, 590, 295):makeToggleButton(0, 0, 42, 42, 1, buttons(6)):setTooltip(_S.tooltip.graphs.cures),
    self:addPanel(0, 590, 347):makeToggleButton(0, 0, 42, 42, 1, buttons(7)):setTooltip(_S.tooltip.graphs.deaths),
    self:addPanel(0, 590, 400):makeToggleButton(0, 0, 42, 42, 1, buttons(8)):setTooltip(_S.tooltip.graphs.reputation)
  }
  
end

function UIGraphs:draw(canvas, x, y)
  self.background:draw(canvas, self.x + x, self.y + y)
  UIFullscreen.draw(self, canvas, x, y)
  x, y = self.x + x, self.y + y

  self.white_font:draw(canvas, _S.graphs.money_in, x + 502, y + 41, 80, 27)
  self.white_font:draw(canvas, _S.graphs.money_out, x + 502, y + 93, 80, 27)
  self.white_font:draw(canvas, _S.graphs.wages, x + 502, y + 145, 80, 27)
  self.white_font:draw(canvas, _S.graphs.balance, x + 502, y + 197, 80, 27)
  self.white_font:draw(canvas, _S.graphs.visitors, x + 502, y + 249, 80, 27)
  self.white_font:draw(canvas, _S.graphs.cures, x + 502, y + 301, 80, 27)
  self.white_font:draw(canvas, _S.graphs.deaths, x + 502, y + 353, 80, 27)
  self.white_font:draw(canvas, _S.graphs.reputation, x + 502, y + 405, 80, 27)

end

function UIGraphs:toggleGraphScale()
  self.graph_scale = not self.graph_scale
  self.ui:playSound("selectx.wav")
end

function UIGraphs:toggleGraph(num)
  self.hide_graph[num] = not self.hide_graph[num]
  self.ui:playSound("selectx.wav")
end
