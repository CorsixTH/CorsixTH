--[[ Copyright (c) 2011 Mark "MarkL" Lawlor

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
disease.id = "pregnant"
disease.expertise_id = 14
disease.non_visuals_id = 19
disease.name = _S.diseases.pregnancy.name
disease.cause = _S.diseases.pregnancy.cause
disease.symptoms = _S.diseases.pregnancy.symptoms
disease.cure = _S.diseases.pregnancy.cure
disease.cure_price = 200
disease.emergency_sound = "emerg021.wav"
disease.initPatient = function(patient)
  patient:setType("Standard Female Patient")
  patient:setLayer(0, math.random(1, 4) * 2)
  patient:setLayer(2, 0)
  patient:setLayer(1, math.random(0, 3) * 2)
  patient:setLayer(3, 0)
  patient:setLayer(4, 0)
end

-- Diagnosis rooms are the rooms other than the GPs office which can be visited
-- to aid in diagnosis. They need not be visited, and if they are visited, the
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
  "ward",
  "operating_theatre",
}

return disease
