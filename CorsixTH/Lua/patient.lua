--[[ Copyright (c) 2009 Peter "Corsix" Cawley

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

class "Patient" (Humanoid)

function Patient:Patient(...)
  self:Humanoid(...)
  self.hover_cursor = TheApp.gfx:loadMainCursor("patient")
end

function Patient:onClick(ui, button)
  if button == "left" then
    ui:addWindow(UIPatient(ui, self))
  end
end

function Patient:setDisease(disease)
  self.disease = disease
  disease.initPatient(self)
  self.diagnosed = false
  self.diagnosis_progress = 0
  self.cure_rooms_visited = 0
end

function Patient:setHospital(hospital)
  if self.hospital then
    self.hospital:removePatient(self)
  end
  Humanoid.setHospital(self, hospital)
  if hospital then
    if hospital.is_in_world then
      self:setNextAction{name = "seek_reception", hospital = hospital}
    end
    hospital:addPatient(self)
  end
end

function Patient:goHome(cured)
  if self.going_home then
    return
  end
  if cured then
    self:setMood "happy"
    self:playSound "cheer.wav"
  else
    self:setMood "exit"
  end
  
  self.going_home = true
  self:setHospital(nil)
  self.happiness = nil
  self.thirst = nil
  self.warmth = nil
end
