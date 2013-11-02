--[[ Copyright (c) 2013 William "sadger" Gatens 

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

class "Epidemic"

--[[Manages the epidemics that occur in hospitals. Generally, any epidemic
logic that happens outside this class will call functions contained here.]]
function Epidemic:Epidemic(hospital, contagious_patient)
  print("Creating a new epidemic") 
  self.hospital = hospital
  self.world = self.hospital.world

  self.infected_patients = {}

  --The contagious disease the epidemic is based around
  self.disease = contagious_patient.disease

  self:addContagiousPatient(contagious_patient)
end

--[[ The epidemic tick - currently the same rate as the hospital's tick but
not necessary dependent on it - could potentially be reduced for performance.]]
function Epidemic:tick()
end

--[[ Adds a new patient to the epidemic who is actively contagious: infected but
not vaccinated or cured]]
function Epidemic:addContagiousPatient(patient) 
  patient.infected = true
  -- This is conditional on cover up being active -- remove after testing
  patient:setMood("epidemy4","activate")
  patient:updateDynamicInfo()
  self.infected_patients[#self.infected_patients + 1] = patient
end
