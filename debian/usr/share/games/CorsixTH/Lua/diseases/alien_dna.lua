--[[ Copyright (c) 2011 Manuel "Roujin" Wolf

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
disease.id = "alien_dna"
disease.expertise_id = 8
disease.visuals_id = 6
disease.name = _S.diseases.alien_dna.name
disease.cause = _S.diseases.alien_dna.cause
disease.symptoms = _S.diseases.alien_dna.symptoms
disease.cure = _S.diseases.alien_dna.cure
disease.cure_price = 2000
disease.emergency_sound = "emerg020.wav"
disease.emergency_number = 16
disease.must_stand = TheApp.config.alien_dna_must_stand -- Alien Patients are forced to stand while queueing because of missing animation
disease.only_emergency = TheApp.config.alien_dna_only_by_emergency -- TODO implement (there are no normal door animations, so they cannot go to GP)
disease.initPatient = function(patient)
  local which = math.random(0, 1) -- male or female?
  patient:setType((which == 0) and "Alien Male Patient" or "Alien Female Patient")
  patient.change_into = (which == 0) and "Standard Male Patient" or "Standard Female Patient"
  if which == 0 then
    patient:setLayer(0, math.random(1, 5) * 2) -- 5 variations for males
    patient:setLayer(2, math.random(0, 1) * 2) -- + alternate shoes
  else
    patient:setLayer(0, math.random(2, 4) * 2) -- NB: for layer0 = 2 head is missing in death animation, so it's not used
    patient:setLayer(2, 0)
  end
  patient:setLayer(1, math.random(0, 3) * 2) -- 3 clothes variations for both genders
  patient:setLayer(3, 0)
  patient:setLayer(4, 0)
  patient.should_knock_on_doors = TheApp.config.alien_dna_can_knock_on_doors
end

-- Diagnosis rooms are the rooms other than the GPs office which can be visited
-- to aid in diagnosis. The need not be visited, and if they are visited, the
-- order in which they are visited is not fixed.
disease.diagnosis_rooms = {
}
-- Treatment rooms are the rooms which must be visited, in the given order, to
-- cure the disease.
disease.treatment_rooms = {
  "dna_fixer",
}
-- If a machine is required a small icon should appear in the drug casebook.
disease.requires_machine = true

return disease
