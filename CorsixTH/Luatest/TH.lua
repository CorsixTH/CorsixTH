--[[ Copyright (c) 2014 Edvin "Lego3" Linge

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

-- A stub implementation of the TH C++ object, to be able to run
-- unit tests without any backend.

local loadFont = function()
  return {
    draw = function() end,
    drawWrapped = function() end,
  }
end

TheApp = {
  gfx = {
    loadMainCursor = function() end,
    loadSpriteTable = function() end,
    loadFont = loadFont,
    loadFontAndSpriteTable = loadFont,
  },
  runtime_config = {},
  config = {
    width = 600,
    height = 800,
    ui_scale = 1,
  },
  world = {
    speed = "Normal",
    isCurrentSpeed = function(self, s) return s == self.speed end,
    gameLog = function() end,
  },
  animation_manager = {
    setPatientMarker = function(...) end,
    setStaffMarker = function(...) end,
  },
}

local sub_S = setmetatable({key = ''}, {
  __index = function(t, k)
    t.key = t.key .. '.' .. k
    return t
  end,

  __tostring = function(t)
    return t.key
  end,
})

_G['_S'] = setmetatable({key = ''}, {
  __index = function(_, k)
    sub_S.key = '_S.' .. k
    return sub_S
  end,

  __tostring = function(_)
    return '_S'
  end,
})

return {
  animation = function()
    return {
        setHitTestResult = function() end,
        setAnimation = function() end,
        setTile = function() end,
      }
    end
}
