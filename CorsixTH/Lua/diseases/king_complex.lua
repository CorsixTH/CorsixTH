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
  id = "king_complex",
  expertise_id = 4,
  visuals_id = 2,
  name = _S.diseases.king_complex.name,
  cause = _S.diseases.king_complex.cause,
  symptoms = _S.diseases.king_complex.symptoms,
  cure = _S.diseases.king_complex.cure,
  cure_price = 1600,
  emergency_sound = "emerg009.wav",
  emergency_number = 18,
  contagious = false,
  initPatient = function(patient)
    patient:setType("Elvis Patient")
    patient:setLayer(0, math.random(1, 3)*2)
    patient:setLayer(1, 0)
    patient:setLayer(2, 0)
    patient:setLayer(3, 0)
    patient:setLayer(4, 0)
  end,
  -- Diagnosis rooms are the rooms other than the GPs office which can be visited
  -- to aid in diagnosis. The need not be visited, and if they are visited, the
  -- order in which they are visited is not fixed.
  diagnosis_rooms = {
    "x_ray",
    "scanner",
  },
  -- Treatment rooms are the rooms which must be visited, in the given order, to
  -- cure the disease.
  treatment_rooms = {
    "psych",
  },
}

return disease
