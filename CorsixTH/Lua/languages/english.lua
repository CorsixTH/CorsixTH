--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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

Language("English", "en", "eng")
Inherit("original_strings", 0)

-------------------------------  OVERRIDE  ----------------------------------
adviser.warnings.money_low = "Your money is getting low!" -- Funny. Exists in German translation, but not existent in english?
-- TODO: tooltip.graphs.reputation -- this tooltip talks about hospital value. Actually it should say reputation.
-- TODO: tooltip.status.close -- it's called status window, not overview window.

-- tooltip.staff_list.next_person, prev_person is rather next/prev page (also in german, maybe more languages?)
tooltip.staff_list.next_person = "Show next page"
tooltip.staff_list.prev_person = "Show previous page"
tooltip.status.reputation = "Your Reputation should not be less than %d. Currently it's %d"
tooltip.status.balance = "Your bank balance should not be less than %d. Currently it's %d"

-- The originals of these two contain one space too much
fax.emergency.cure_not_possible_build = "You will need to build a %s"
fax.emergency.cure_not_possible_build_and_employ = "You will need to build a %s and employ a %s"
fax.emergency.num_disease = "There are %d people with %s and they require immediate attention."
adviser.goals.lose.kill = "Kill another %d patients to lose the level!"

-- Improve tooltips in staff window to mention hidden features
tooltip.staff_window.face = "This person's face - click to open management screen"
tooltip.staff_window.center_view = "Left click to zoom to staff, right click to cycle through staff members"

-- These strings are missing in some versions of TH (unpatched?)
confirmation.restart_level = "Are you sure you want to restart the level?"
-- TODO adviser.multiplayer.objective_completed
-- TODO adviser.multiplayer.objective_failed

-- A small error in the introduction text of level 2
introduction_texts.level2[6] = "Aim for a reputation of 300 a bank balance of $10,000 and 40 people cured."
-- An override for the squits becoming the the squits see issue 1646
adviser.research.drug_improved_1 = "%s drug has been improved by your Research Department."
-------------------------------  NEW STRINGS  -------------------------------
date_format = {
  daymonth = "%1% %2:months%",
}

object.litter = "Litter"
tooltip.objects.litter = "Litter: Left on the floor by a patient because he did not find a bin to throw it in."

tooltip.fax.close = "Close this window without deleting the message"
tooltip.message.button = "Left click to open message"
tooltip.message.button_dismiss = "Left click to open message, right click to dismiss it"
tooltip.casebook.cure_requirement.hire_staff = "You need to employ staff to handle this treatment"
tooltip.casebook.cure_type.unknown = "You do not yet know how to treat this disease"
tooltip.research_policy.no_research = "No research is being carried out in this category at the moment"
tooltip.research_policy.research_progress = "Progress towards the next discovery in this category: %1%/%2%"

menu_file = {
  load =    " (SHIFT+L) LOAD   ",
  save =    " (SHIFT+S) SAVE   ",
  restart = " (SHIFT+R) RESTART",
  quit =    " (SHIFT+Q) QUIT   "
}

menu_options = {
  sound = "  (ALT+S)  SOUND   ",
  announcements = "  (ALT+A)  ANNOUNCEMENTS   ",
  music = "  (ALT+M)  MUSIC   ",
  jukebox = "  (J) JUKEBOX  ",
  lock_windows = "  LOCK WINDOWS  ",
  edge_scrolling = "  EDGE SCROLLING  ",
  adviser_disabled = "  (SHIFT+A) ADVISER  ",
  warmth_colors = "  WARMTH COLOURS  ",
  wage_increase = "  WAGE REQUESTS",
  twentyfour_hour_clock = "  24 HOUR CLOCK  "
}

menu_options_game_speed = {
  pause               = "  (P) PAUSE  ",
  slowest             = "  (1) SLOWEST  ",
  slower              = "  (2) SLOWER  ",
  normal              = "  (3) NORMAL  ",
  max_speed           = "  (4) MAX SPEED  ",
  and_then_some_more  = "  (5) AND THEN SOME MORE  ",
}

menu_options_warmth_colors = {
  choice_1 = "  RED  ",
  choice_2 = "  BLUE GREEN RED  ",
  choice_3 = "  YELLOW ORANGE RED  ",
}
 
menu_options_wage_increase = {
  grant = "    GRANT ",
  deny =  "    DENY ",
}

-- Add F-keys to entries in charts menu (except briefing), also town_map was added.
menu_charts = {
  bank_manager  = "  (F1) BANK MANAGER  ",
  statement     = "  (F2) STATEMENT  ",
  staff_listing = "  (F3) STAFF LISTING  ",
  town_map      = "  (F4) TOWN MAP  ",
  casebook      = "  (F5) CASEBOOK  ",
  research      = "  (F6) RESEARCH  ",
  status        = "  (F7) STATUS  ",
  graphs        = "  (F8) GRAPHS  ",
  policy        = "  (F9) POLICY  ",
}

menu_debug = {
  jump_to_level               = "  JUMP TO LEVEL  ",
  transparent_walls           = "  (X) TRANSPARENT WALLS  ",
  limit_camera                = "  LIMIT CAMERA  ",
  disable_salary_raise        = "  DISABLE SALARY RAISE  ",
  make_debug_fax              = "  MAKE DEBUG FAX  ",
  make_debug_patient          = "  MAKE DEBUG PATIENT  ",
  cheats                      = "  (F11) CHEATS  ",
  lua_console                 = "  (F12) LUA CONSOLE  ",
  calls_dispatcher            = "  CALLS DISPATCHER  ",
  dump_strings                = "  DUMP STRINGS  ",
  dump_gamelog                = "  (CTRL+D) DUMP GAME LOG  ",
  map_overlay                 = "  MAP OVERLAY  ",
  sprite_viewer               = "  SPRITE VIEWER  ",
}
menu_debug_overlay = {
  none                        = "  NONE  ",
  flags                       = "  FLAGS  ",
  positions                   = "  POSITIONS  ",
  heat                        = "  TEMPERATURE  ",
  byte_0_1                    = "  BYTE 0 & 1  ",
  byte_floor                  = "  BYTE FLOOR  ",
  byte_n_wall                 = "  BYTE N WALL  ",
  byte_w_wall                 = "  BYTE W WALL  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  PARCEL  ",
}
adviser = {
  room_forbidden_non_reachable_parts = "Placing the room in this location would result in parts of the hospital not being reachable.",
  warnings = {
    no_desk = "You should build a reception desk and hire a receptionist at some point!",
    no_desk_1 = "If you want patients to come to your hospital, you will need to hire a receptionist and build her a desk to work at!",
    no_desk_2 = "Well done, that must be a world record: nearly a year and no patients! If you want to continue as Manager of this hospital, you will need to hire a receptionist and build a reception desk for her to work from!",
    no_desk_3 = "That's just brilliant, nearly a year and you don't have a staffed reception! How do you expect to get any patients, now get it sorted out and stop messing around!",
    no_desk_4 = "A Receptionist needs to have her own work station to greet your patients as they arrive",
    no_desk_5 = "Well it's about time, you should start to see some patients arriving soon!", 
    no_desk_6 = "You have a receptionist, so how about building a reception desk for her to work from?",
    no_desk_7 = "You've built the reception desk, so how about hiring a receptionist?  You won't see any patients until you get this sorted out you know!",
    cannot_afford = "You don't have enough money in the bank to hire that person!", -- I can't see anything like this in the original strings
    cannot_afford_2 = "You don't have enough money in the bank to make that purchase!", 
    falling_1 = "Hey! that is not funny, watch where you click that mouse; someone could get hurt!",
    falling_2 = "Stop messing about, how would you like it?",
    falling_3 = "Ouch, that had to hurt, someone call a Doctor!",
    falling_4 = "This is an Hospital, not a Theme Park!",
    falling_5 = "This is not the place for knocking people over, they're ill you know!",
    falling_6 = "This is not a bowling alley, sick people should not be treated like that!",
    research_screen_open_1 = "You have to build a Research Department before you can access the Research screen.",
    research_screen_open_2 = "Research is disabled for the current level.",
    researcher_needs_desk_1 = "A Researcher needs to have a desk to work at.",
    researcher_needs_desk_2 = "Your Researcher is pleased that you have allowed him to have a break. If you were intending to have more staff researching, then you need to provide them each with a desk to work from.",
    researcher_needs_desk_3 = "Each Researcher needs to have his own desk to work from.",
    nurse_needs_desk_1 = "Each Nurse needs to have her own desk to work from.",
    nurse_needs_desk_2 = "Your Nurse is pleased that you have allowed her to have a break. If you were intending to have more than one working in the ward, then you need to provide them each with a desk to work from.",
  },
  cheats = {  
    th_cheat = "Congratulations, you have unlocked cheats!",
    roujin_on_cheat = "Roujin's challenge activated! Good luck...",
    roujin_off_cheat = "Roujin's challenge deactivated.",
  },
}

dynamic_info.patient.actions.no_gp_available = "Waiting for you to build a GP's office"
dynamic_info.staff.actions.heading_for = "Heading for %s"
dynamic_info.staff.actions.fired = "Fired"

progress_report.free_build = "FREE BUILD"

fax = {
  choices = {
    return_to_main_menu = "Return to the main menu",
    accept_new_level = "Move on to the next level",
    decline_new_level = "Continue playing a while longer",
  },
  emergency = {
    num_disease_singular = "There is 1 person with %s and they require immediate attention.",
    free_build = "If you are successful your reputation will increase but if you fail your reputation will be seriously dented.",
  },
  vip_visit_result = {
    remarks = {
      free_build = {
        "It is a very nice hospital you have there! Not very hard to get it working without money limitations though, eh?",
        "I'm no economist, but I think I could run this hospital too if you know what I mean...",
        "A very well run hospital. Watch out for the recession though! Right... you don't have to worry about that.",
      }
    }
  }
}

letter = {
  dear_player = "Dear %s",
  custom_level_completed = "Well done! You've completed all goals on this custom level!",
  return_to_main_menu = "Would you like to return to the main menu or continue playing?",
}

install = {
  title = "--------------------------------- CorsixTH Setup ---------------------------------",
  th_directory = "CorsixTH needs a copy of the data files from the original Theme Hospital game (or demo) in order to run. Please use the below selector to locate the Theme Hospital install directory.",
  ok = "OK",
  exit = "Exit",
  cancel = "Cancel",
}

misc.not_yet_implemented = "(not yet implemented)"
misc.no_heliport = "Either no diseases have been discovered yet, or there is no heliport on this map.  It might be that you need to build a reception desk and hire a receptionist"

main_menu = {
  new_game = "Campaign",
  custom_level = "Single Scenario",
  load_game = "Load Game",
  options = "Settings",
  savegame_version = "Savegame version: ",
  version = "Version: ",
  exit = "Exit",
}

tooltip.main_menu = {
  new_game = "Start the first level on the campaign",
  custom_level = "Build your hospital in a single scenario",
  load_game = "Load a saved game",
  options = "Tweak various settings",
  exit = "No, no, please don't leave!",
  quit = "You are about to quit from CorsixTH.   Are you sure this is what you want to do?",
}

load_game_window = {
  caption = "Load Game (%1%)",
}

tooltip.load_game_window = {
  load_game = "Load game %s",
  load_game_number = "Load game %d",
  load_autosave = "Load autosave",
}

custom_game_window = {
  caption = "Custom Game",
  free_build = "Free Build",
}

tooltip.custom_game_window = {
  start_game_with_name = "Information about this scenario which is using: %s           Briefing: %s",
  free_build = "Tick this box if you want to play without money or winning and losing conditions",
}

save_game_window = {
  caption = "Save Game (%1%)",
  new_save_game = "New Savegame",
}

tooltip.save_game_window = {
  save_game = "Overwrite savegame %s",
  new_save_game = "Enter name for a new savegame",
}

menu_list_window = {
  name = "Name",
  save_date = "Modified",
  back = "Back",
}

tooltip.menu_list_window = {
  name = "Click here to sort the list by name",
  save_date = "Click here to sort the list by last modification date",
  back = "Close this window",
}

options_window = {
  caption = "Settings",
  option_on = "On",
  option_off = "Off",
  fullscreen = "Fullscreen",
  resolution = "Resolution",
  custom_resolution = "Custom...",
  width = "Width",
  height = "Height",
  audio = "Global Audio",
  customise = "Customise",
  folder = "Folders",
  language = "Game language",
  apply = "Apply",
  cancel = "Cancel",
  back = "Back",
}

tooltip.options_window = {
  fullscreen = "Whether the game should run in fullscreen or windowed mode",
  fullscreen_button = "Click to toggle fullscreen mode",
  resolution = "The resolution the game should run in",
  select_resolution = "Select a new resolution",
  width = "Enter desired screen width",
  height = "Enter desired screen height",
  apply = "Apply the entered resolution",
  cancel = "Return without changing the resolution",
  audio_button = "Turn on or off all game audio", 
  audio_toggle = "Toggle on or off",   
  customise_button = "More settings you can change to customise your game play experience",
  folder_button = "Folder Options",  
  language = "The language texts in the game will appear in",
  select_language = "Select the game language",
  language_dropdown_item = "Choose %s as language",
  back = "Close the Settings window",
}

customise_window = {
  caption = "Custom Settings",
  option_on = "On",
  option_off = "Off",
  back = "Back",
  movies = "Global Movie Control",
  intro = "Play Intro Movie",
  paused = "Build on Paused",
  volume = "Volume down hotkey",
  aliens = "Alien Patients",
  fractured_bones = "Fractured Bones",
  average_contents = "Average contents",
}

tooltip.customise_window = {
  movies = "Global movie control, this will allow you to disable all the movies",  
  intro = "Turn off or on the intro movie, global movies will need to be on if you want the intro movie to play each time you load CorsixTH",
  paused = "In Theme Hospital the player would only be allowed to use the top menu if the game was paused. That is the default setting in CorsixTH too, but by turning this on everything is allowed while the game is paused",
  volume = "If the volume down button is opening the casebook as well, turn this on to change the hotkey for the casebook to Shift + C",
  aliens = "Because of the lack of proper animations we have by default made patients with Alien DNA so that they can only come from an emergency. To allow patients with Alien DNA to visit your hospital, other than by an emergency, turn this off",
  fractured_bones = "Because of a poor animation we have by default made it so there are no patients with Fractured Bones that are female. To allow female patients with Fractured Bones to visit your hospital, turn this off",
  average_contents = "If you would like the game to remember what extra objects you usually add when you build rooms, then turn this option on",  
  back = "Close this menu and go back to the Settings Menu",
}

folders_window = {
  caption = "Folder Locations",
  data_label = "TH Data",
  font_label = "Font",  
  music_label = "MP3's",
  savegames_label = "Saves",
  screenshots_label = "Screenshots",
  -- next four are the captions for the browser window, which are called from the folder setting menu
  new_th_location = "Here you can specify a new Theme Hospital installation directory. As soon as you choose the new directory the game will be restarted.", 
  savegames_location = "Select the directory you want to use for Saves",
  music_location = "Select the directory you want to use for your Music", 
  screenshots_location = "Select the directory you want to use for Screenshots",
  back  = "Back",
}

tooltip.folders_window = {
  browse = "Browse for folder location",
  data_location = "The directory of the original Theme Hospital installation, which is required to run CorsixTH",
  font_location = "Location of a font file that is capable of displaying Unicode characters required by your language. If this is not specified you will not be able to choose languages that need more characters than the original game can supply. Example: Russian and Chinese",    
  savegames_location = "By default, the Saves directory is alongside the config file and will be used for storing saved games in. Should this not be suitable, then you can choose your own, just browse to the directory which you want to use.", 
  screenshots_location = "By default, the Screenshots are stored in a folder alongside the config file. Should this not be suitable, then you can choose your own, just browse to the directory which you want to use.",  
  music_location = "Select a location for your mp3 music files.  You must have created the directory already, then browse to the directory which you just created.",
  browse_data = "Browse for another location of a Theme Hospital installation (current location: %1%)", 
  browse_font = "Browse for another font file ( current location: %1% )",
  browse_saves = "Browse for another location for your Saves directory  ( Current location: %1% ) ",
  browse_screenshots = "Browse for another location for your Screenshots directory  ( Current location: %1% ) ",
  browse_music = "Browse for another location for your Music directory  ( Current location: %1% ) ",  
  no_font_specified = "No font location specified yet!",  
  not_specified = "No folder location specified yet!",
  default = "Default location",
  reset_to_default = "Reset the directory to its default location",
 -- original_path = "The currently chosen directory of the original Theme Hospital installation", -- where is this used, I have left if for the time being?
  back  = "Close this menu and go back to the Settings Menu",
}

font_location_window = {
  caption = "Choose font (%1%)",
}

handyman_window = {
  all_parcels = "All parcels",
  parcel = "Parcel"
}

tooltip.handyman_window = {
  parcel_select = "The parcel where the handyman accepts tasks, click to change setting"
}

new_game_window = {
  caption = "Campaign",
  player_name = "Player name",
  option_on = "On",
  option_off = "Off",
  difficulty = "Difficulty",
  easy = "Junior (Easy)",
  medium = "Doctor (Medium)",
  hard = "Consultant (Hard)",
  tutorial = "Tutorial",
  start = "Start",
  cancel = "Cancel",
}

tooltip.new_game_window = {
  player_name = "Enter the name you wish to be referred to as in the game",
  difficulty = "Select the difficulty level you want to play the game in",
  easy = "If you are new to simulation games this is the option for you",
  medium = "This is the middle way to go if you are unsure what to choose",
  hard = "If you are used to this kind of game and want more of a challenge, pick this option",
  tutorial = "Click here to turn on some help to get you started once in the game",
  start = "Start the game with the chosen settings",
  cancel = "Oh, I didn't really mean to start a new game!",
}

lua_console = {
  execute_code = "Execute",
  close = "Close",
}

tooltip.lua_console = {
  textbox = "Enter Lua code to run here",
  execute_code = "Run the code you have entered",
  close = "Close the console",
}

errors = {
  dialog_missing_graphics = "Sorry, the demo data files don't contain this dialog.",
  save_prefix = "Error while saving game: ",
  load_prefix = "Error while loading game: ",
  load_quick_save = "Error, cannot load the quicksave as it does not exist, not to worry as we have now created one for you!",
  map_file_missing = "Could not find the map file %s for this level!",
  minimum_screen_size = "Please enter a screen size of at least 640x480.",
  unavailable_screen_size = "The screen size you requested is not available in fullscreen mode.",
  alien_dna = "NOTE: There are no animations for Alien patients for sitting down, opening or knocking on doors etc. So, like with Theme Hospital to do these things they will appear to change to normal looking and then change back.  Patients with Alien DNA will only appear if they are set to in the level file", 
  fractured_bones = "NOTE: The animation for female patients with Fractured Bones is not perfect",
}

confirmation = {
  needs_restart = "Changing this setting requires CorsixTH to restart. Any unsaved progress will be lost. Are you sure you want to do this?",
  abort_edit_room = "You are currently building or editing a room. If all required objects are placed it will be finished, but otherwise it will be deleted. Continue?",
  maximum_screen_size = "The screen size you have entered is greater than 3000 x 2000.  Larger resolutions are possible, but will require better hardware in order to maintain a playable frame rate.  Are you sure you want to continue?",
  music_warning = "Before choosing to use mp3's for your in game music, you will need to have smpeg.dll or the equivalent for your operating system, otherwise you will have no music in the game.  Currently there is no equivalent file for 64bit systems.  Do you want to continue?",
}

information = {
  custom_game = "Welcome to CorsixTH. Have fun with this custom map!",
  no_custom_game_in_demo = "Sorry, but in the demo version you can't play any custom maps.",
  cannot_restart = "Unfortunately this custom game was saved before the restart feature was implemented.",
  very_old_save = "There have been a lot of updates to the game since you started this level. To be sure that all features work as intended please consider restarting it.",
  level_lost = {
    "Bummer! You failed the level. Better luck next time!",
    "The reason you lost:",
    reputation = "Your reputation fell below %d.",
    balance = "Your bank balance fell below %d.",
    percentage_killed = "You killed more than %d percent of the patients.",
    cheat = "This was your choice or did you select the wrong button? So you can't even cheat correctly, not that funny huh?",
  },
  cheat_not_possible = "Cannot use that cheat on this level. You even fail to cheat, not that funny huh?",
}

tooltip.information = {
  close = "Close the information dialog",
}

totd_window = {
  tips = {
    "Every hospital needs a reception desk and a GP's office to get going. After that, it depends on what kind of patients are visiting your hospital. A pharmacy is always a good choice, though.",
    "Machines such as the Inflation need maintenance. Employ a handyman or two to repair your machines, or you'll risk your staff and patients getting hurt.",
    "After a while, your staff will get tired. Be sure to build a staff room, so they can relax.",
    "Place enough radiators to keep your staff and patients warm, or they will become unhappy. Use the town map to locate any spots in your hospital that need more heating.",
    "A doctor's skill level greatly influences the quality and speed of his diagnoses. Place a skilled doctor in your GP's office, and you won't need as many additional diagnosis rooms.",
    "Juniors and doctors can improve their skills by learning from a consultant in the training room. If the consultant has a special qualification (surgeon, psychiatrist or researcher), he will also pass on this knowledge to his pupil(s).",
    "Did you try to enter the European emergency number (112) into the fax machine? Make sure your sound is on!",
    "You can adjust some settings such as the resolution and language in the options window found both in the main menu and ingame.",
    "You selected a language other than English, but there's English text all over the place? Help us by translating missing texts into your language!",
    "The CorsixTH team is looking for reinforcements! Are you interested in coding, translating or creating graphics for CorsixTH? Contact us at our Forum, Mailing List or IRC Channel (corsix-th at freenode).",
    "If you find a bug, please report it at our bugtracker: th-issues.corsix.org",
    "Each level has certain requirements to fulfill before you can move on to the next one. Check the status window to see your progression towards the level goals.",
    "If you want to edit or remove an existing room, you can do so with the edit room button found in the bottom toolbar.",
    "In a horde of waiting patients, you can quickly find out which ones are waiting for a particular room by hovering over that room with your mouse cursor.",
    "Click on the door of a room to see its queue. You can do useful fine tuning here, such as reordering the queue or sending a patient to another room.",
    "Unhappy staff will ask for salary rises frequently. Make sure your staff is working in a comfortable environment to keep that from happening.",
    "Patients will get thirsty while waiting in your hospital, even more so if you turn up the heating! Place vending machines in strategic positions for some extra income.",
    "You can abort the diagnosis progress for a patient prematurely and guess the cure, if you already encountered the disease. Beware that this may increase the risk of a wrong cure, resulting in death for the patient.",
    "Emergencies can be a good source for some extra cash, provided that you have enough capacities to handle the emergency patients in time.",
  },
  previous = "Previous Tip",
  next = "Next Tip",
}

tooltip.totd_window = {
  previous = "Display the previous tip",
  next = "Display the next tip",
}

debug_patient_window = {
  caption = "Debug Patient",
}

cheats_window = {
  caption = "Cheats",
  warning = "Warning: You will not get any bonus points at the end of the level if you cheat!",
  cheated = {
    no = "Cheats used: No",
    yes = "Cheats used: Yes",
  },
  cheats = {
    money = "Money Cheat",
    all_research = "All Research Cheat",
    emergency = "Create Emergency",
    vip = "Create VIP",
    earthquake = "Create Earthquake",
    create_patient = "Create Patient",
    end_month = "End of Month",
    end_year = "End of Year",
    lose_level = "Lose Level",
    win_level = "Win Level",
  },
  close = "Close",
}

tooltip.cheats_window = {
  close = "Close the cheats dialog",
  cheats = {
    money = "Adds 10.000 to your bank balance.",
    all_research = "Completes all research.",
    emergency = "Creates an emergency.",
    vip = "Creates a VIP.",
    earthquake = "Creates an earthquake.",
    create_patient = "Creates a Patient at the map border.",
    end_month = "Jumps to the end of the month.",
    end_year = "Jumps to the end of the year.",
    lose_level = "Lose the current level.",
    win_level = "Win the current level.",
  }
}

introduction_texts = {
  demo = {
    "Welcome to the demo hospital!",
    "Unfortunately the demo version only contains this level. However, there is more than enough to do here to keep you busy for a while!",
    "You will encounter various diseases that require different rooms to cure. From time to time, emergencies may occur. And you will need to research additional rooms using a research room.",
    "Your goal is to earn $100,000, have a hospital value of $70,000 and a reputation of 700, while having cured at least 75% of your patients.",
    "Make sure your reputation does not fall below 300 and that you don't kill off more than 40% of your patients, or you will lose.",
    "Good luck!",
  },
}

calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = "%d calls; %d assigned",
  staff = "%s - %s",
  watering = "Watering @ %d,%d",
  repair = "Repair %s",
  close = "Close",
}

tooltip.calls_dispatcher = {
  task = "List of tasks - click task to open assigned staff's window and scroll to location of task",
  assigned = "This box is marked if someone is assigned to the corresponding task.",
  close = "Close the calls dispatcher dialog",
}

update_window = {
  caption = "Update Available!",
  new_version = "New Version:",
  current_version = "Current Version:",
  download = "Go to download page",
  ignore = "Skip and go to main menu",
}

tooltip.update_window = {
  download = "Go to the download page for the very latest version of CorsixTH",
  ignore = "Ignore this update for now. You will be notified again when you next open CorsixTH",
}

--------------------------------  UNUSED  -----------------------------------
------------------- (kept for backwards compatibility) ----------------------

options_window.change_resolution = "Change resolution"
tooltip.options_window.change_resolution = "Change the window resolution to the dimensions entered on the left"
