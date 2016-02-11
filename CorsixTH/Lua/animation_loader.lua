--[[ Copyright (c) 2013 William "sadger" Gatens

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

class "AnimationLoader"

---@type AnimationLoader
local AnimationLoader = _G["AnimationLoader"]

--! Returns a table of animation numbers for each direction the content of which depends on
--! if custom graphics are enabled in the config file.
--! @param animation_name (String) the name of the animation to load
--! @param original_animation_number the number of the animation from the original graphic set
--! @return table of animation numbers (table), keys being one of the cardinal directions
function AnimationLoader.getIdleAnimations(animation_name, original_animation_number)
  local anims = TheApp.anims
  local config = TheApp.config
  if config.use_new_graphics then
    local n, e, s, w = anims:getAnimations(64, animation_name)
    return {north = n, east = e, south = s, west = w}
  else
    return {north = original_animation_number, east = original_animation_number,
             south = original_animation_number, west = original_animation_number}
  end
end

