--[[ Copyright (c) 2018 Stephen E. Baker

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

describe("Bottom Panel:", function()
  local bottom_panel;
  local mock_canvas;
  local font;

  setup(function()
    require("corsixth")
    require("class_test_base")
    require("TH")

    require("window")
    require("dialogs/bottom_panel")
  end)

  before_each(function()
    TheApp.world.gameLog = function() end

    font = {
      draw = function() end,
      drawWrapped = function() end,
    }
    TheApp.gfx.loadFontAndSpriteTable = function() return font end

    local mock_ui = {}
    mock_ui.app = _G['TheApp']
    mock_ui.addKeyHandler = function() end

    mock_canvas = {}

    bottom_panel = UIBottomPanel(mock_ui)

    mock(font, 'draw')
    mock(font, 'drawWrapped')
    mock(TheApp.world, 'gameLog')
  end)

  it("Set nil dynamic info", function()
    bottom_panel:setDynamicInfo(nil)
    bottom_panel:drawDynamicInfo(mock_canvas, 0, 0)

    assert.stub(TheApp.world.gameLog).was_not.called_with(TheApp.world, "Dynamic info is missing text!")
  end)

  it("Set dynamic info without text", function()
    local dynamic_info = {}

    bottom_panel:setDynamicInfo(dynamic_info)
    bottom_panel:drawDynamicInfo(mock_canvas, 0, 0)

  assert.stub(TheApp.world.gameLog).was.called_with(TheApp.world, "Dynamic info is missing text!")
  end)

  it("Set dynamic info with text", function()
    local dynamic_info = { text = { "test text" } }

    bottom_panel:setDynamicInfo(dynamic_info)
    bottom_panel:drawDynamicInfo(mock_canvas, 0, 0)

    assert.stub(TheApp.world.gameLog).was_not.called_with(TheApp.world, "Dynamic info is missing text!")
    assert.stub(font.drawWrapped).was.called_with(font, mock_canvas, "test text", 20, 10, 240)
  end)
end)
