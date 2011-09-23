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

menu_options = {
  lock_windows = "  LOCK WINDOWS  ",
  edge_scrolling = "  EDGE SCROLLING  ",
  settings = "  SETTINGS  ",
}

menu_options_game_speed = {
  pause               = "  (P) PAUSE  ",
  slowest             = "  (1) SLOWEST  ",
  slower              = "  (2) SLOWER  ",
  normal              = "  (3) NORMAL  ",
  max_speed           = "  (4) MAX SPEED  ",
  and_then_some_more  = "  (5) AND THEN SOME MORE  ",
}

-- The demo does not contain this string
menu_file.restart = "  RESTART  "

menu_debug = {
  jump_to_level               = "  JUMP TO LEVEL  ",
  transparent_walls           = "  (X) TRANSPARENT WALLS  ",
  limit_camera                = "  LIMIT CAMERA  ",
  disable_salary_raise        = "  DISABLE SALARY RAISE  ",
  make_debug_fax              = "  (F8) MAKE DEBUG FAX  ",
  make_debug_patient          = "  (F9) MAKE DEBUG PATIENT  ",
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
    no_desk ="You should build a reception desk and hire a receptionist at some point!",
    no_desk_1 = "If you want patients to come to your hospital, you will need to hire a receptionist and build her a desk to work at!",
    no_desk_2 = "Well done, that must be a world record: nearly a year and no patients! If you want to continue as Manager of this hospital, you will need to hire a receptionist and build a reception desk for her to work from!",
  },
  cheats = {  
    th_cheat = "Congratulations, you have unlocked cheats!",
    crazy_on_cheat = "Oh no! All doctors have gone crazy!",
    crazy_off_cheat = "Phew... the doctors regained their sanity.",
    roujin_on_cheat = "Roujin's challenge activated! Good luck...",
    roujin_off_cheat = "Roujin's challenge deactivated.",
    hairyitis_cheat = "Hairyitis cheat activated!",
    hairyitis_off_cheat = "Hairyitis cheat deactivated.",
    bloaty_cheat = "Bloaty Head cheat activated!",
    bloaty_off_cheat = "Bloaty Head cheat deactivated.",
  },
}

dynamic_info.patient.actions.no_gp_available = "Waiting for you to build a GP's office"
dynamic_info.staff.actions.heading_for = "Heading for %s"
dynamic_info.staff.actions.fired = "Fired"

fax = {
  choices = {
    return_to_main_menu = "Return to the main menu",
    accept_new_level = "Move on to the next level",
    decline_new_level = "Continue playing a while longer",
  },
  emergency = {
    num_disease_singular = "There is 1 person with %s and they require immediate attention.",
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
  exit = "Exit",
}

misc.not_yet_implemented = "(not yet implemented)"
misc.no_heliport = "Either no diseases have been discovered yet, or there is no heliport on this map.  It might be that you need to build a reception desk and hire a receptionist"

main_menu = {
  new_game = "New Game",
  custom_level = "Custom Level",
  load_game = "Load Game",
  options = "Options",
  exit = "Exit",
}

tooltip.main_menu = {
  new_game = "Start a completely new game from scratch",
  custom_level = "Build your hospital in a custom level",
  load_game = "Load a saved game",
  options = "Tweak various settings",
  exit = "No, no, please don't leave!",
}

load_game_window = {
  caption = "Load Game",
}

tooltip.load_game_window = {
  load_game = "Load game %s",
  load_game_number = "Load game %d",
  load_autosave = "Load autosave",
}

custom_game_window = {
  caption = "Custom Game",
}

tooltip.custom_game_window = {
  start_game_with_name = "Load the level %s",
}

save_game_window = {
  caption = "Save Game",
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
  fullscreen = "Fullscreen",
  width = "Width",
  height = "Height",
  change_resolution = "Change resolution",
  browse = "Browse...",
  new_th_directory = "Here you can specify a new Theme Hospital installation directory. As soon as you choose the new directory the game will be restarted.",
  cancel = "Cancel",
  back = "Back",
}

tooltip.options_window = {
  fullscreen_button = "Click to toggle fullscreen mode",
  width = "Enter desired screen width",
  height = "Enter desired screen height",
  change_resolution = "Change the window resolution to the dimensions entered on the left",
  language = "Select %s as language",
  original_path = "The currently chosen directory of the original Theme Hospital installation",
  browse = "Browse for another location of a Theme Hospital installation",
  back = "Close the options window",
}

new_game_window = {
  easy = "Junior (Easy)",
  medium = "Doctor (Medium)",
  hard = "Consultant (Hard)",
  tutorial = "Tutorial",
  cancel = "Cancel",
}

tooltip.new_game_window = {
  easy = "If you are new to simulation games this is the option for you",
  medium = "This is the middle way to go if you are unsure what to choose",
  hard = "If you are used to this kind of game and want more of a challenge, pick this option",
  tutorial = "If you want some help to get started once in the game, tick this box",
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
  map_file_missing = "Could not find the map file %s for this level!",
  minimum_screen_size = "Please enter a screen size of at least 640x480.",
  maximum_screen_size = "Please enter a screen size of at most 3000x2000.",
  unavailable_screen_size = "The screen size you requested is not available in fullscreen mode.",
}

confirmation = {
  needs_restart = "Changing this setting requires CorsixTH to restart. Any unsaved progress will be lost. Are you sure you want to do this?",
  abort_edit_room = "You are currently building or editing a room. If all required objects are placed it will be finished, but otherwise it will be deleted. Continue?",
}

information = {
  custom_game = "Welcome to CorsixTH. Have fun with this custom map!",
  cannot_restart = "Unfortunately this custom game was saved before the restart feature was implemented.",
  level_lost = {
    "Bummer! You failed the level. Better luck next time!",
    "The reason you lost:",
    reputation = "Your reputation fell below %d.",
    balance = "Your bank balance fell below %d.",
    percentage_killed = "You killed more than %d percent of the patients.",
  },
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
    "Unfortunately the demo version only contains this level (apart from custom levels). However, there is more than enough to do here to keep you busy for a while!",
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
