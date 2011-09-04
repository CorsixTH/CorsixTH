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

local disease = {}
disease.id = "bloaty_head"
disease.expertise_id = 2
disease.visuals_id = 0
disease.name = _S.diseases.bloaty_head.name
disease.cause = _S.diseases.bloaty_head.cause
disease.symptoms = _S.diseases.bloaty_head.symptoms
disease.cure = _S.diseases.bloaty_head.cure
disease.cure_price = 850
disease.emergency_sound = "emerg007.wav"
disease.initPatient = function(patient)
  patient:setType("Standard Male Patient")
  patient:setLayer(0, math.random(6, 8) * 2)
  patient:setLayer(1, math.random(0, 3) * 2)
  patient:setLayer(2, math.random(0, 1) * 2)
  patient:setLayer(3, 0)
  patient:setLayer(4, 0)
end
-- Diagnosis rooms are the rooms other than the GPs office which can be visited
-- to aid in diagnosis. The need not be visited, and if they are visited, the
-- order in which they are visited is not fixed.
disease.diagnosis_rooms = {
  "general_diag",
  "x_ray",
  "cardiogram",
  "scanner",
}
-- Treatment rooms are the rooms which must be visited, in the given order, to
-- cure the disease.
disease.treatment_rooms = {
  "inflation",
}

 
-- If a machine is required a small icon should appear in the drug casebook.
disease.requires_machine = true

return disease
