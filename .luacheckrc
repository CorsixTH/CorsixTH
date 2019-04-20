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
            "serialize","array_join","shallow_clone",

            -- Game classes
            "AIHospital", "AnimationManager", "App", "Audio",
            "CallsDispatcher", "ChildClass", "Command", "Door", "DrawFlags",
            "DummyRootNode", "Entity", "EntityMap", "Epidemic", "FileSystem",
            "FileTreeNode", "FilteredFileTreeNode", "GameUI", "Graphics",
            "GrimReaper", "Hospital", "Humanoid", "HumanoidRawWalk",
            "Inspector", "LoadGame", "LoadGameFile", "Litter", "Machine",
            "Map", "MoviePlayer", "NoRealClass", "Object", "ParentClass",
            "Patient", "Plant", "Queue", "ResearchDepartment", "Room",
            "SaveGame", "SaveGameFile", "Staff", "StaffProfile", "StaffRoom",
            "Strings", "SwingDoor", "TheApp", "TreeControl", "Vip", "Window",
            "World", "Date", "Doctor", "Handyman", "Nurse", "Receptionist",

            -- UI
            "UI", "UIAdviser", "UIAnnualReport", "UIAudio", "UIBankManager",
            "UIBottomPanel", "UIBuildRoom", "UICallsDispatcher", "UICasebook",
            "UICheats", "UIChooseFont", "UIConfirmDialog", "UICustomCampaign",
            "UICustomGame", "UICustomise", "UIDirectoryBrowser", "UIDropdown",
            "UIEditRoom", "UIFax", "UIFileBrowser", "UIFolder", "UIFullscreen",
            "UIFurnishCorridor", "UIGraphs", "UIHireStaff" ,"UIInformation",
            "UIJukebox", "UILoadGame", "UILoadMap", "UILuaConsole", "UIMachine",
            "UIMakeDebugPatient", "UIMainMenu", "UIMapEditor", "UIMenuBar",
            "UIMenuList", "UIMessage", "UINewGame", "UIOptions", "UIPatient",
            "UIPlaceObjects", "UIPlaceStaff", "UIPolicy", "UIProgressReport",
            "UIQueue", "UIQueuePopup", "UIResizable", "UIResearch",
            "UIResolution", "UISaveGame", "UISaveMap", "UIStaff",
            "UIStaffManagement", "UIStaffRise", "UITipOfTheDay", "UITownMap",
            "UIUpdate", "UIWatch", "UIHotkeyAssign", "UIScrollSpeed",
            "UIShiftScrollSpeed", "UIZoomSpeed", "UIHotkeyAssign_Panels",
            "UIHotkeyAssign_storeRecallPos",

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
            "math.n_random", "math.round", "math.randomdump",

            -- Unit Tests
            "assertion_matches"
          }

-- Set standard globals
std = "lua51+lua52+lua53+luajit"
files["CorsixTH/Luatest"] = {std = "+busted"}

codes = true            -- Show warning codes
max_line_length = false -- No maximum line length

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
    "dutch", "english", "finnish", "french", "german", "hungarian",
    "iberic_portuguese", "italian", "korean", "norwegian", "original_strings",
    "polish", "russian", "simplified_chinese", "spanish", "swedish",
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

-- W111: setting non-standard global variable XYZ
-- W113: accessing undefined variable XYZ
-- W121: setting read-only global variable XYZ
-- W122: mutating read-only global variable XYZ
-- W211: unused variable XYZ
-- W212: unused argument XYZ
-- W231: variable XYZ is never accessed
-- W542: empty if branch
add_ignore("CorsixTH/CorsixTH.lua", "121")
add_ignore("CorsixTH/Lua/app.lua", "122")
add_ignore("CorsixTH/Lua/app.lua", "212")
add_ignore("CorsixTH/Lua/calls_dispatcher.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/bottom_panel.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/confirm_dialog.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/edit_room.lua", "113") -- accessing hasBit and bitOr utility.lua functions
add_ignore("CorsixTH/Lua/dialogs/edit_room.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/edit_room.lua", "542")
add_ignore("CorsixTH/Lua/dialogs/fullscreen.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/fullscreen/bank_manager.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/fullscreen/graphs.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/fullscreen/hospital_policy.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/fullscreen/research_policy.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/fullscreen/staff_management.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/furnish_corridor.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/grim_reaper.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/hire_staff.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/information.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/jukebox.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/menu.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/message.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/place_objects.lua", "542")
add_ignore("CorsixTH/Lua/dialogs/queue_dialog.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/resizables/customise.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/resizables/directory_browser.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/resizables/dropdown.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/resizables/file_browser.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/resizables/lua_console.lua", "111")
add_ignore("CorsixTH/Lua/dialogs/resizables/main_menu.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/resizables/map_editor.lua", "542")
add_ignore("CorsixTH/Lua/dialogs/resizables/menu_list_dialog.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/resizables/options.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/staff_rise.lua", "212")
add_ignore("CorsixTH/Lua/dialogs/staff_rise.lua", "542")
add_ignore("CorsixTH/Lua/dialogs/tree_ctrl.lua", "212")
add_ignore("CorsixTH/Lua/entities/humanoid.lua", "212")
add_ignore("CorsixTH/Lua/entities/machine.lua", "212")
add_ignore("CorsixTH/Lua/entities/object.lua", "212")
add_ignore("CorsixTH/Lua/entities/humanoids/grim_reaper.lua", "212")
add_ignore("CorsixTH/Lua/entities/humanoids/inspector.lua", "212")
add_ignore("CorsixTH/Lua/entities/humanoids/patient.lua", "212")
add_ignore("CorsixTH/Lua/entities/humanoids/patient.lua", "542")
add_ignore("CorsixTH/Lua/entities/humanoids/staff.lua", "212")
add_ignore("CorsixTH/Lua/entities/humanoids/vip.lua", "212")
add_ignore("CorsixTH/Lua/entity.lua", "212")
add_ignore("CorsixTH/Lua/epidemic.lua", "212")
add_ignore("CorsixTH/Lua/filesystem.lua", "212")
add_ignore("CorsixTH/Lua/game_ui.lua", "212")
add_ignore("CorsixTH/Lua/graphics.lua", "542")
add_ignore("CorsixTH/Lua/hospital.lua", "212")
add_ignore("CorsixTH/Lua/humanoid_action.lua", "212")
add_ignore("CorsixTH/Lua/humanoid_actions/idle.lua", "212")
add_ignore("CorsixTH/Lua/humanoid_actions/multi_use_object.lua", "212")
add_ignore("CorsixTH/Lua/humanoid_actions/pickup.lua", "212")
add_ignore("CorsixTH/Lua/humanoid_actions/seek_reception.lua", "212")
add_ignore("CorsixTH/Lua/humanoid_actions/seek_reception.lua", "542")
add_ignore("CorsixTH/Lua/humanoid_actions/seek_room.lua", "212")
add_ignore("CorsixTH/Lua/humanoid_actions/staff_reception.lua", "113") -- ReceptionDesk does exist
add_ignore("CorsixTH/Lua/humanoid_actions/use_object.lua", "542")
add_ignore("CorsixTH/Lua/humanoid_actions/vaccinate.lua", "212")
add_ignore("CorsixTH/Lua/humanoid_actions/vip_go_to_next_room.lua", "212")
add_ignore("CorsixTH/Lua/map.lua", "212")
add_ignore("CorsixTH/Lua/map.lua", "542")
add_ignore("CorsixTH/Lua/movie_player.lua", "542")
add_ignore("CorsixTH/Lua/objects/analyser.lua", "212")
add_ignore("CorsixTH/Lua/objects/door.lua", "212")
add_ignore("CorsixTH/Lua/objects/litter.lua", "212")
add_ignore("CorsixTH/Lua/objects/machines/operating_table.lua", "542")
add_ignore("CorsixTH/Lua/persistance.lua", "231") -- th_getupvalue assignments in lua5.2/5.3 code
add_ignore("CorsixTH/Lua/research_department.lua", "212")
add_ignore("CorsixTH/Lua/room.lua", "212")
add_ignore("CorsixTH/Lua/rooms/cardiogram.lua", "212")
add_ignore("CorsixTH/Lua/rooms/general_diag.lua", "212")
add_ignore("CorsixTH/Lua/rooms/psych.lua", "212")
add_ignore("CorsixTH/Lua/rooms/research.lua", "212")
add_ignore("CorsixTH/Lua/rooms/scanner_room.lua", "212")
add_ignore("CorsixTH/Lua/rooms/staff_room.lua", "212")
add_ignore("CorsixTH/Lua/rooms/staff_room.lua", "542")
add_ignore("CorsixTH/Lua/rooms/ward.lua", "212")
add_ignore("CorsixTH/Lua/sprite_viewer.lua", "212")
add_ignore("CorsixTH/Lua/strict.lua", "212")
add_ignore("CorsixTH/Lua/strings.lua", "212")
add_ignore("CorsixTH/Lua/strings.lua", "122")
add_ignore("CorsixTH/Lua/ui.lua", "111") -- _ is set in debug code
add_ignore("CorsixTH/Lua/ui.lua", "212")
add_ignore("CorsixTH/Lua/utility.lua", "111") -- defining hasBit and bitOr
add_ignore("CorsixTH/Lua/utility.lua", "121")
add_ignore("CorsixTH/Lua/window.lua", "212")
add_ignore("CorsixTH/Lua/window.lua", "542")
add_ignore("CorsixTH/Lua/world.lua", "212")
add_ignore("CorsixTH/Lua/world.lua", "542")
add_ignore("CorsixTH/Luatest/non_strict.lua", "212")
