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

---@type Disease
local disease = {
  id = "bloaty_head",
  expertise_id = 2,
  visuals_id = 0,
  name = _S.diseases.bloaty_head.name,
  cause = _S.diseases.bloaty_head.cause,
  symptoms = _S.diseases.bloaty_head.symptoms,
  cure = _S.diseases.bloaty_head.cure,
  cure_price = 850,
  emergency_sound = "emerg007.wav",
  emergency_number = 18,
  contagious = false,
  initPatient = function(patient)
    patient:setType("Standard Male Patient")
    patient:setLayer(0, math.random(6, 8) * 2)
    patient:setLayer(1, math.random(0, 3) * 2)
    patient:setLayer(2, math.random(0, 1) * 2)
    patient:setLayer(3, 0)
    patient:setLayer(4, 0)
  end,
  -- Diagnosis rooms are the rooms other than the GPs office which can be visited
  -- to aid in diagnosis. The need not be visited, and if they are visited, the
  -- order in which they are visited is not fixed.
  diagnosis_rooms = {
    "general_diag",
    "x_ray",
    "cardiogram",
    "scanner",
  },
  -- Treatment rooms are the rooms which must be visited, in the given order, to
  -- cure the disease.
  treatment_rooms = {
    "inflation",
  },

  -- If a machine is required a small icon should appear in the drug casebook.
  requires_machine = true,
}

return disease
