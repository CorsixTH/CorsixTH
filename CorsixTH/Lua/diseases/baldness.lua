--[[ Copyright (c) 2010 Miika-Petteri Matikainen

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
disease.name = _S(4, 11)
disease.id = "baldness"
disease.symptoms = _S(44, 87)
disease.cure = _S(44, 88)
disease.cause = _S(44, 86)
disease.cure_price = 950 -- http://www.eudoxus.demon.co.uk/thc/tech.htm
disease.initPatient = function(patient)
  patient:setType("Slack Male Patient")
  patient:setLayer(0, 12)
  patient:setLayer(1, math.random(0, 3) * 2)
  patient:setLayer(2, 0)
  patient:setLayer(3, 0)
  patient:setLayer(4, 0)
  -- Disable knocking doors as there is no door knocking animation in layer 0 with 12 (bald head)
  patient.should_knock_on_doors = false
end

-- Diagnosis rooms are the rooms other than the GPs office which can be visited
-- to aid in diagnosis. The need not be visited, and if they are visited, the
-- order in which they are visited is not fixed.
disease.diagnosis_rooms = {
  "x_ray",
  -- TODO
}

-- Treatment rooms are the rooms which must be visited, in the given order, to
-- cure the disease.
disease.treatment_rooms = {
  "hair_restoration",
}

-- Diagnosis difficulty: a value between 0 (instant diagnosis in GP's office) and 1.
disease.diagnosis_difficulty = 0.8

-- If a machine is required a small icon should appear in the drug casebook.
disease.requires_machine = true

return disease
