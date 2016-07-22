globals = { "_A", "_S",
            "action_queue_leave_bench", "class", "compare_tables",
            "decoda_output", "destrict",
            "flag_clear", "flag_isset", "flag_set", "flag_toggle",
            "lfs", "list_to_set", "loadfile_envcall", "loadstring_envcall",
            "permanent", "print_table", "rangeMapLookup", "rnc",
            "strict_declare_global", "table_length", "unpermanent", "values",
            "AIHospital", "AnimationManager", "App", "Audio",
            "CallsDispatcher", "ChildClass", "Command",
            "Door", "DrawFlags", "DummyRootNode",
            "Entity", "EntityMap", "Epidemic",
            "FileSystem", "FileTreeNode", "FilteredFileTreeNode",
            "GameUI", "Graphics", "GrimReaper",
            "Hospital", "Humanoid", "HumanoidRawWalk",
            "Inspector", "LoadGame", "LoadGameFile", "Litter",
            "Machine", "Map", "MoviePlayer", "NoRealClass", "Object",
            "ParentClass", "Patient", "Plant", "Queue",
            "ResearchDepartment", "Room",
            "SaveGame", "SaveGameFile", "Staff", "StaffProfile",
            "StaffRoom", "Strings", "SwingDoor", "TheApp", "TreeControl",
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
            "UIUpdate", "UIWatch",
            "Vip", "Window", "World"
          }

-- set standard globals
std = "lua51+lua52+lua53+luajit"
files["CorsixTH/Luatest"] = {std = "+busted"}

-- show warning codes
codes = true

-- exclude files and directories
exclude_files = {"CorsixTH/Bitmap", "CorsixTH/Lua/api_version.lua", "LDocGen"}

-- ignore "undefined global variable" warnings of language files
files["CorsixTH/Lua/languages"].ignore = {"111", "112", "113"}

-- ignore unused functions of save game compatibility
files["CorsixTH/Lua/rooms/operating_theatre.lua"].ignore = {"wait_for_ready", "after_use"}
files["CorsixTH/Lua/app.lua"].ignore = {"app_confirm_quit_stub"}
files["CorsixTH/Lua/entities/machine.lua"].ignore = {"callbackNewRoom"}
files["CorsixTH/Lua/entities/patient.lua"].ignore = {"callbackNewRoom"}
files["CorsixTH/Lua/entities/staff.lua"].ignore = {"callbackNewRoom"}
files["CorsixTH/Lua/dialogs/fullscreen/research_policy.lua"].ignore = {"adjust", "less_stub", "more_stub"}
files["CorsixTH/Lua/dialogs/bottom_panel.lua"].ignore = {"stub"}
files["CorsixTH/Lua/dialogs/resizables/options.lua"].ignore = {"language_button", "width_textbox_reset", "height_textbox_reset"}
