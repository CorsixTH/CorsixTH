--[[ Copyright (c) 2009 Edvin "Lego3" Linge

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
disease.id = "hairyitis"
disease.expertise_id = 3
disease.visuals_id = 1
disease.name = _S.diseases.hairyitis.name
disease.cause = _S.diseases.hairyitis.cause
disease.symptoms = _S.diseases.hairyitis.symptoms
disease.cure = _S.diseases.hairyitis.cure
disease.cure_price = 1150
disease.emergency_sound = "emerg008.wav"
disease.emergency_number = 12
disease.initPatient = function(patient)
  patient:setType("Chewbacca Patient")
  -- NB: Layers have no effect on the appearance until cured, at which point
  -- they are standard male patient layers. The clinic does however sometimes  
  -- change this so that a female emerge.
  patient:setLayer(0, math.random(1, 5) * 2)
  patient:setLayer(1, math.random(0, 3) * 2)
  patient:setLayer(2, math.random(0, 1) * 2)
  patient:setLayer(3, 0)
  patient:setLayer(4, 0)
end
-- Diagnosis rooms are the rooms other than the GPs office which can be visited
-- to aid in diagnosis. The need not be visited, and if they are visited, the
-- order in which they are visited is not fixed.
disease.diagnosis_rooms = {
  "x_ray",
  "scanner",
}
-- Treatment rooms are the rooms which must be visited, in the given order, to
-- cure the disease.
disease.treatment_rooms = {
  "electrolysis",
}
  
-- If a machine is required a small icon should appear in the drug casebook.
disease.requires_machine = true

return disease
