--[[ Copyright (c) 2026 Jan Bakalar

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

describe("Resizable dialog:", function()
  local ui

  setup(function()
    require("corsixth")
    require("class_test_base")
    require("TH")
    require("utility")
    require("window")
    require("dialogs.resizable")
  end)

  before_each(function()
    TheApp.video.mapRGB = function() return 0 end
    ui = {app = TheApp, opened = {}}
    function ui:addWindow(window)
      self.opened[#self.opened + 1] = window
    end
  end)

  local function dialog()
    return UIResizable(ui, 100, 100, Colours.PanelDefault)
  end

  it("opens nothing when it closes without a dialog to go back to", function()
    local d = dialog()
    d:close()
    assert.is_true(d.closed)
    assert.equal(0, #ui.opened)
  end)

  it("opens the dialog it was given when it closes", function()
    local made = 0
    local back = dialog()
    local d = dialog():setBackTo(function()
      made = made + 1
      return back
    end)
    assert.equal(0, made)
    d:close()
    assert.is_true(d.closed)
    assert.equal(1, made)
    assert.equal(1, #ui.opened)
    assert.equal(back, ui.opened[1])
  end)

  it("goes back from the back button too", function()
    local back = dialog()
    local d = dialog():setBackTo(function() return back end)
    d:buttonBack()
    assert.equal(back, ui.opened[1])
  end)

  it("can be told to go nowhere again", function()
    local d = dialog():setBackTo(function() return dialog() end)
    d:setBackTo(nil)
    d:close()
    assert.equal(0, #ui.opened)
  end)
end)
