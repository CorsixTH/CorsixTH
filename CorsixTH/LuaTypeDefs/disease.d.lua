--[[ Copyright (c) 2026 Albert "Alberth" Hofkamp

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
---@meta _

---@class Disease
---@field id string Identificiation of the disease.
---@field expertise_id integer Number of the diseas in `expertise` of the level file.
---@field visuals_id integer? Number of the disease in the `visuals` of the level file, `nil` if `non_visuals_id` has a value.
---@field non_visuals_id integer? Number of the disease in the `non_visuals` of the level file, `nil` if `visuals_id` has a value.
---@field name THStringProxy The name of the disease.
---@field cause THStringProxy A description of the cause of the disease.
---@field symptoms THStringProxy A description of the symptons of the disease.
---@field cure THStringProxy A description of how to cure the disease.
---@field cure_price integer
---@field emergency_sound string WAV filename.
---@field emergency_number integer
---@field contagious boolean
---@field initPatient fun(Patient): nil
---@field diagnosis_rooms string[] Names of rooms to aid in diagnosis.
---@field treatment_rooms string[] Names of rooms to visit for treating the illness
local Disease = {}
