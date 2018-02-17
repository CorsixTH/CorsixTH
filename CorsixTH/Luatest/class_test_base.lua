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

-- Use this file to easily get started creating unit tests for CorsixTH
-- classes.

require("busted")
-- local say = require("say")
-- print(debug.traceback( ))
-- local function has_substring(state, arguments)
--   return string.match(arguments[2], arguments[1]) ~= nil
-- end
-- say:set("assertion.has_substring", "Expected substring.\n<String>: %s\n<Pattern>:%s")
-- assert:register("assertion", "has_substring", has_substring, "assertion.has_substring")

require("non_strict")
require("class")

function permanent()
  return function()
    return {}
  end
end

function values()
  return function()
    return nil
  end
end



