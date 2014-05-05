--[[ Copyright (c) 2014 Joseph Sheppard

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
local function action_idle_spawn_start(action, humanoid)
  action.must_happen = true

  humanoid.last_move_direction = action.point.direction
  humanoid:setTilePositionSpeed(action.point.x,action.point.y)

  if action.spawn_animation then
    humanoid:queueAction({name="idle",count = humanoid.world:getAnimLength(action.spawn_animation),
                                      loop_callback=--[[persistable:idle_spawn_animation]] function()
                                        if action.spawn_sound then humanoid:playSound(action.spawn_sound) end
                                        humanoid:setAnimation(action.spawn_animation)
                                      end})
  elseif action.spawn_sound then
    humanoid:playSound(action.spawn_sound)
  end

  humanoid:queueAction({name="idle",count = action.count,loop_callback = action.loop_callback})
  humanoid:finishAction()
end

return action_idle_spawn_start
