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

---@type Disease
local disease = {
  id = "baldness",
  expertise_id = 10,
  visuals_id = 8,
  name = _S.diseases.baldness.name,
  cause = _S.diseases.baldness.cause,
  symptoms = _S.diseases.baldness.symptoms,
  cure = _S.diseases.baldness.cure,
  cure_price = 950,
  emergency_sound = "emerg012.wav",
  emergency_number = 18,
  contagious = false,
  initPatient = function(patient)
    patient:setType("Slack Male Patient")
    patient:setLayer(0, 12)
    patient:setLayer(1, math.random(0, 3) * 2)
    patient:setLayer(2, 0)
    patient:setLayer(3, 0)
    patient:setLayer(4, 0)
    -- Disable knocking doors as there is no door knocking animation in layer 0 with 12 (bald head)
    patient.should_knock_on_doors = false
  end,

  -- Diagnosis rooms are the rooms other than the GPs office which can be visited
  -- to aid in diagnosis. The need not be visited, and if they are visited, the
  -- order in which they are visited is not fixed.
  diagnosis_rooms = {
    "x_ray",
    "blood_machine",
    "scanner",
  },

  -- Treatment rooms are the rooms which must be visited, in the given order, to
  -- cure the disease.
  treatment_rooms = {
    "hair_restoration",
  },

  -- If a machine is required a small icon should appear in the drug casebook.
  requires_machine = true,
}

return disease
