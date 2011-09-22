--[[ Copyright (c) 2010 Peter "Corsix" Cawley

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

dofile("dialogs/menu_list_dialog")

class "UIMakeDebugPatient" (UIMenuList)

function UIMakeDebugPatient:UIMakeDebugPatient(ui)
  local items = {}
  for _, disease in ipairs(ui.app.diseases) do
    if disease.visuals_id or disease.non_visuals_id == 1 then
      items[#items + 1] = {
        name = disease.name,
        disease = disease,
        tooltop = disease.name,
      }
    end
  end
  self:UIMenuList(ui, "game", _S.debug_patient_window.caption, items)
end

function UIMakeDebugPatient:buttonClicked(num)
  if self.ui.hospital:hasStaffedDesk() then
    local item = self.items[num + self.scrollbar.value - 1]
    local patient = self.ui.app.world:newEntity("Patient", 2)
    patient.is_debug = true
    table.insert(self.ui.hospital.debug_patients, patient)
    item.disease.initPatient(patient)
    patient:setDisease(item.disease)
    local x, y = self.ui:ScreenToWorld(self.x + self.width / 2, self.y + self.height + 100)
    patient:setTile(math.floor(x), math.floor(y))
    patient:setMood("idea1", "activate") -- temporary, to make debug patients distinguishable from normal ones
    patient:setHospital(self.ui.hospital)
  else
    self.ui:playSound("wrong2.wav")
  end
end
