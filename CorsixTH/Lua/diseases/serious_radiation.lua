--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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
disease.id = "serious_radiation"
disease.expertise_id = 6
disease.visuals_id = 4
disease.name = _S.diseases.serious_radiation.name
disease.cause = _S.diseases.serious_radiation.cause
disease.symptoms = _S.diseases.serious_radiation.symptoms
disease.cure = _S.diseases.serious_radiation.cure
disease.cure_price = 1800
disease.emergency_sound = "emerg010.wav"
disease.initPatient = function(patient)
  if math.random(0, 1) == 0 then
    patient:setType("Standard Male Patient")
    patient:setLayer(0, math.random(1, 5) * 2)
    patient:setLayer(2, math.random(0, 2) * 2)
  else
    patient:setType("Standard Female Patient")
    patient:setLayer(0, math.random(1, 4) * 2)
    patient:setLayer(2, 0)
  end
  patient:setLayer(1, math.random(0, 3) * 2)
  patient:setLayer(3, 0)
  patient:setLayer(4, 0)
end
-- TODO: visual radiation effect

-- Diagnosis rooms are the rooms other than the GPs office which can be visited
-- to aid in diagnosis. The need not be visited, and if they are visited, the
-- order in which they are visited is not fixed.
disease.diagnosis_rooms = {
  "general_diag",
  "cardiogram",
  "scanner",
  "ultrascan",
  "blood_machine",
  "x_ray",
  "psych",
  "ward", 
}
-- Treatment rooms are the rooms which must be visited, in the given order, to
-- cure the disease.
disease.treatment_rooms = {
  "decontamination",
}

-- If a machine is required a small icon should appear in the drug casebook.
disease.requires_machine = true

return disease
