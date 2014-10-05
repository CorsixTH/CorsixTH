--[[ Copyright (c) 2011 William "sadger" Gatens

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

--[[ An `Inspector` is called to the hospital after an epidemic to issue a report]]
class "Inspector" (Humanoid)

function Inspector:Inspector(...)
  self:Humanoid(...)
  self.hover_cursor = TheApp.gfx:loadMainCursor("default")
  self.has_been_announced = false
end

--[[ Labels the inspector as the "Health Inspector" ]]
function Inspector:updateDynamicInfo(action_string)
  self:setDynamicInfo('text', {_S.dynamic_info.health_inspector})
end

--[[ Sends the inspector home ]]
function Inspector:goHome()
  if self.going_home then
    return
  end
  --Store a reference to the hospital last visited to send fax to
  self.last_hospital = self.hospital

  self:unregisterCallbacks()
  self.going_home = true
  self:setHospital(nil)
end

--[[ Called when the inspector has left the map ]]
function Inspector:onDestroy()
  print("Destroying Inspector")
  return Humanoid.onDestroy(self)
end

function Inspector:announce()
  self.world.ui:playAnnouncement("vip008.wav")
end
