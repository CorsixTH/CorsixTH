--[[ Copyright (c) 2016 Albert "AlbertH" Hofkamp

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

self = false

globals = { -- Globals
            "_A", "_S",
            "corsixth",
            "action_queue_leave_bench", "class", "compare_tables",
            "destrict", "flag_clear", "flag_isset", "flag_set", "flag_toggle",
            "lfs", "list_to_set", "loadfile_envcall", "loadstring_envcall",
            "permanent", "print_table", "rangeMapLookup", "rnc",
            "strict_declare_global", "table_length", "unpermanent", "values",
            "serialize", "array_join", "shallow_clone", "staff_initials_cache",
            "hasBit", "bitOr", "inspect",

            -- Game classes
            "AIHospital", "AnimationManager", "AnimationEffect", "App", "Audio",
            "CallsDispatcher", "Cheats", "ChildClass", "Command", "Door", "DrawFlags",
            "DummyRootNode", "Earthquake", "EndConditions", "Entity", "EntityMap",
            "Epidemic", "FileSystem", "FileTreeNode", "FilteredFileTreeNode", "GameUI",
            "Graphics", "GrimReaper", "Hospital", "Humanoid", "HumanoidRawWalk",
            "Inspector", "LoadGame", "LoadGameFile", "Litter", "Machine",
            "Map", "MoviePlayer", "NoRealClass", "Object", "ParentClass",
            "Patient", "Plant", "PlayerHospital", "Queue", "ResearchDepartment", "Room",
            "SaveGame", "SaveGameFile", "Staff", "StaffProfile", "StaffRoom",
            "Strings", "SwingDoor", "TheApp", "TreeControl", "Vip", "Window",
            "World", "Date", "Doctor", "Handyman", "Nurse", "Receptionist",

            -- UI
            "UI", "UIAdviser", "UIAnnualReport", "UIAudio", "UIBankManager",
            "UIBottomPanel", "UIBuildRoom", "UICallsDispatcher", "UICasebook",
            "UICheats", "UIChooseFont", "UIConfirmDialog", "UICustomCampaign",
            "UICustomGame", "UICustomise", "UIDirectoryBrowser", "UIDropdown",
            "UIEditRoom", "UIFatalError", "UIFax", "UIFileBrowser", "UIFolder",
            "UIFullscreen", "UIFurnishCorridor", "UIGraphs", "UIHireStaff",
            "UIHotkeyAssign", "UIHotkeyAssignKeyPane", "UIInformation", "UIJukebox",
            "UILoadGame", "UILoadMap", "UILuaConsole", "UIMachine",
            "UIMakeDebugPatient", "UIMainMenu", "UIMapEditor", "UIMenuBar",
            "UIMenuList", "UIMessage", "UINewGame", "UIOptions", "UIPatient",
            "UIMachineMenu", "UIPlaceObjects", "UIPlaceStaff", "UIPolicy",
            "UIProgressReport", "UIQueue", "UIQueuePopup", "UIResizable",
            "UIResearch", "UIResolution", "UISaveGame", "UISaveMap", "UIScrollSpeed",
            "UIShiftScrollSpeed", "UIStaff", "UIStaffManagement", "UIStaffRise",
            "UITipOfTheDay", "UITownMap", "UIUpdate", "UIWatch", "UIZoomSpeed",

            -- Actions
            "AnswerCallAction", "CallCheckPointAction", "CheckWatchAction",
            "DieAction", "FallingAction", "GetUpAction", "HumanoidAction",
            "IdleAction", "IdleSpawnAction", "KnockDoorAction", "MeanderAction",
            "MultiUseObjectAction", "OnGroundAction", "PeeAction",
            "PickupAction", "QueueAction", "SeekReceptionAction",
            "SeekRoomAction", "SeekStaffRoomAction", "SeekToiletsAction",
            "ShakeFistAction", "SpawnAction", "StaffReceptionAction",
            "SweepFloorAction", "TapFootAction", "UseObjectAction",
            "UseScreenAction", "UseStaffRoomAction", "VaccinateAction",
            "VipGoToNextRoomAction", "VomitAction", "WalkAction", "YawnAction",

            -- Math extensions
            "math.n_random", "math.round", "math.randomdump", "math.t_random",
            "math.p_random",

            -- Unit Tests
            "assertion_matches"
          }

-- Set standard globals
files["CorsixTH/Luatest"] = {std = "+busted"}

codes = true            -- Show warning codes
max_line_length = false -- No maximum line length
unused_args = false     -- Permit unused arguments

-- Exclude files and directories
exclude_files = {"CorsixTH/Bitmap", "CorsixTH/Lua/api_version.lua", "LDocGen"}

--! Helper function to add an ignore for a filename to 'files'.
--!param filename (str) Name of the file to add an ignore.
--!param value Ignore value to add.
local function add_ignore(filename, value)
  ignores = files[filename]
  if not ignores then
    files[filename].ignore = {value}
  else
    ignores[#ignores + 1] = value
    files[filename].ignore = ignores
  end
end

-- For languages, ignore
-- W111: setting non-standard global variable XYZ
-- W112: mutating non-standard global variable XYZ
-- W113: accessing undefined variable XYZ
-- W314: value assigned to field XYZ is unused
for _, lng in ipairs({"brazilian_portuguese", "czech", "danish", "developer",
    "dutch", "english", "finnish", "french", "german", "greek", "hungarian",
    "iberic_portuguese", "italian", "japanese", "korean", "norwegian", "original_strings",
    "polish", "russian", "simplified_chinese", "spanish", "swedish", "ukrainian",
    "traditional_chinese"}) do
  local filename = "CorsixTH/Lua/languages/" .. lng .. ".lua"
  add_ignore(filename, "111")
  add_ignore(filename, "112")
  add_ignore(filename, "113")
  add_ignore(filename, "314")
end

-- Ignore unused functions of save game compatibility
add_ignore("CorsixTH/Lua/app.lua", "app_confirm_quit_stub")
add_ignore("CorsixTH/Lua/dialogs/bottom_panel.lua", "stub")
add_ignore("CorsixTH/Lua/dialogs/fullscreen/research_policy.lua", "adjust")
add_ignore("CorsixTH/Lua/dialogs/fullscreen/research_policy.lua", "less_stub")
add_ignore("CorsixTH/Lua/dialogs/fullscreen/research_policy.lua", "more_stub")
add_ignore("CorsixTH/Lua/dialogs/resizables/options.lua", "language_button")
add_ignore("CorsixTH/Lua/dialogs/resizables/options.lua", "width_textbox_reset")
add_ignore("CorsixTH/Lua/dialogs/resizables/options.lua", "height_textbox_reset")
add_ignore("CorsixTH/Lua/entities/machine.lua", "callbackNewRoom")
add_ignore("CorsixTH/Lua/entities/machine.lua", "repair_loop_callback")
add_ignore("CorsixTH/Lua/entities/humanoids/patient.lua", "callbackNewRoom")
add_ignore("CorsixTH/Lua/entities/humanoids/staff.lua", "callbackNewRoom")
add_ignore("CorsixTH/Lua/humanoid_actions/vip_go_to_next_room.lua", "action_vip_go_to_next_room_end")
add_ignore("CorsixTH/Lua/rooms/operating_theatre.lua", "after_use")
add_ignore("CorsixTH/Lua/rooms/operating_theatre.lua", "wait_for_ready")
