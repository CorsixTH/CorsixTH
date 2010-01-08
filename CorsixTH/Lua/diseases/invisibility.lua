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
disease.name = _S(4, 6)
disease.id = "invisibility"
disease.cause = _S(44, 71)
disease.symptoms = _S(44, 72)
disease.cure = _S(44, 73)
disease.cure_price = 1400 -- http://www.eudoxus.demon.co.uk/thc/tech.htm
disease.initPatient = function(patient)
  patient:setType("Invisible Patient")
  patient:setLayer(0, 2)
  patient:setLayer(1, 0)
  patient:setLayer(2, 0)
  patient:setLayer(3, 0)
  patient:setLayer(4, 0)
  patient.cured_layers = {
    [0] = math.random(1, 5) * 2,
    [1] = math.random(0, 3) * 2,
    [2] = 4,
  }
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
  "pharmacy",
}
-- Diagnosis difficulty: a value between 0 (instant diagnosis in GP's office) and 1.
disease.diagnosis_difficulty = 0.1

return disease
