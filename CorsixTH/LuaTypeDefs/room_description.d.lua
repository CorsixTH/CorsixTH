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

---@alias StaffRequirementsName
---| "Doctor"
---| "Nurse"
---| "Surgeon"
---| "Psychiatrist"
---| "Researcher"

---@alias StaffRequirements table<StaffRequirementsName, integer?>
---@alias ObjectRequirements table<string, integer?>

---@alias RoomCategory
---| "treatment"
---| "diagnosis"
---| "clinics"

---@alias WallType
---| "green"
---| "white"
---| "yellow"
---| "blue"

---@class RoomProperties
---@field id string Id of the room.
---@field vip_must_visit boolean Whether the VIP should visit the room.
---@field level_config_id integer Id of the room in the level config.
---@field class string Name of the class implenting the room.
---@field name THStringProxy Short name of the room.
---@field long_name THStringProxy Long name of the room.
---@field tooltip THStringProxy Tooltip of the room.
---@field objects_additional string[] Additional objects that may be put in the room.
---@field objects_needed ObjectRequirements Objects that must be put in the room.
---@field build_preview_animation integer Animation number for the preview of the room
---@field categories table<RoomCategory, integer> Category and sorting order of the room.
---@field minimum_size integer Smallest square needed for the room.
---@field wall_type WallType Typf of the wall in the room.
---@field floor_tile integer number of the floortile sprite.
---@field required_staff StaffRequirements? Minimal needed staff
---@field maximum_staff StaffRequirements? Maximal allowed staff
---@field call_sound string? Sound filename.
---@field has_no_queue_dialog boolean?
local RoomProperties = {}
