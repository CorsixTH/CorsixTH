--[[ Copyright (c) 2010-2020 Manuel "Roujin" Wolf, Edvin "Lego3" Linge, lewri et al.

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

Language("English", "English", "en", "eng")
Inherit("original_strings", 0)

--Note: All strings should use a single space after full-stops. Only exception is level descriptions.
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

-- Replace Billy Savile
-- this is only relevant to the English game so does not need adding
-- in other language files
vip_names = {
 [6] = "Sir Lancelot Spratt",
}

-- An override for the squits becoming the the squits see issue 1646
adviser.research.drug_improved_1 = "%s drug has been improved by your Research Department."

-- Disease overrides where there are typos
diseases.golf_stones.cure = "Cure - These must be removed by an operation requiring two Surgeons."
diseases.ruptured_nodules.cure = "Cure - Two qualified Surgeons must remove the nodules using steady hands."
diseases.slack_tongue.cause = "Cause - Chronic over-discussion of soap operas."
diseases.slack_tongue.cure = "Cure - The tongue is placed in the Slicer Machine and removed quickly, efficiently, and painfully."
diseases.the_squits.cure = "Cure - A glutinous mix of stringy pharmaceutical chemicals solidify the patient's innards."
diseases.bloaty_head.cure = "Cure - The swollen head is popped, then re-inflated to the correct PSI using a clever machine."

-- Rooms overrides where there are typos
room_descriptions.inflation[2] = "Patients with the painful-yet-humorous condition of Bloaty Head must come to the Inflation Clinic, where the overlarge cranium will be popped and instantly re-inflated to the correct pressure.//"
room_descriptions.staff_room[2] = "Your staff get tired as they carry out their jobs. They require this room to relax and refresh themselves. Tired staff slow down, demand more money, and will eventually quit. They also make more mistakes. Building a staff room with plenty for them to do is very worthwhile. Make sure there is room for several staff members at one time. "

-- Staff description overrides where there are typos
staff_descriptions.bad[14] = "Sly, cunning, and subversive. "
staff_descriptions.misc[11] = "Distils whisky. "

-- Correction to a pay rise prompt with typos
pay_rise.regular[1] = "I'm totally frazzled. I need a good rest, plus a rise of %d if you don't want to see me jack in this poxy job."

-- Level description overrides where there are typos. Note: This is the only portion of the game that SHOULD use double space after fullstops etc.
introduction_texts.level17 = " Last word of warning - keep a keen eye on your Reputation - this is what will attract the patients from far and wide to your establishment.  If you don't kill too many people and keep them reasonably happy you shouldn't have too much trouble on this level!// You're on you own now.  Good luck and all that."
introduction_texts.level11 = " You've been given the chance to build the ultimate in hospitals.  This is an exceedingly prestigious area, and the Ministry would like to see the best possible hospital.  We'll be expecting you to make big money, have a superbly high reputation and cover every possible eventuality.  It's an important job, this.  You'll have to be something special to pull it off.  Note, too, that there have sightings of UFOs in the area.  Make sure your staff are prepared for some unexpected visitors.  Your hospital will need to be worth $240,000, you'll need $500,000 in the bank, and your reputation will need to be 700."
introduction_texts.level9 = " Having filled the Ministry's bank account and paid for a new limousine for the Minister himself, you can now get back to creating a caring, well-run hospital for the benefit of the unwell and needy.  You can expect a lot of different problems to crop up here.  If you have enough well-trained staff and rooms, you should have all the angles covered.  Your hospital will need to be worth $200,000, and you'll need $400,000 in the bank.  Any less and you won't be able to finish the level."
introduction_texts.level16 = " Once you have diagnosed some of the patients you will need to build treatment facilities and clinics to cure them - a good one to start off with is the Pharmacy.  You'll also need a Nurse to dispense the various drugs in the Pharmacy."
introduction_texts.level10 = " As well as covering all the illnesses which crop up in this neck of the woods, the Ministry request that you spend some time concentrating on the efficiency of your drugs.  There have been some complaints from Ofsick, the Health Watchdog, so in order to look good you must make sure all your drugs are extremely efficient.  Also, make sure your hospital is above reproach as well. Keep those deaths down.  As a hint, you might like to keep space free for a Jelly Vat.  Develop all your drugs to at least 80 per cent efficiency, get a reputation of 650 and stash $500,000 in the bank to win."
introduction_texts.level12 = " You've got the mother of all challenges now.  Impressed with your success, the Ministry has got the top job for you; they want someone to build another ultimate hospital, make a vast amount of dosh and have an incredible reputation.  You'll also be expected to buy all the land you can, cure everything (and we mean everything) and win all the awards.  Think you're up to it?  Earn $650,000, cure 750 people, and get a reputation of 800 to win this one."
introduction_texts.level15 = " Okay that's the basic mechanics of putting a hospital together.// Your Doctors are going to need all the help they can get to diagnose some of these patients.  You can assist them by building another diagnosis facility such as the General Diagnosis Room."
-- A small error in the introduction text of level 2
introduction_texts.level2 = " There is a greater variety of ailments in this area.  Set up your hospital to deal with more patients, " ..
                            "and plan to build a Research Department.  Remember to keep your establishment clean, and try to get your " ..
                            "reputation as high as possible - you'll be dealing with diseases like Slack Tongue, so you'll need a Slack " ..
                            "Tongue Clinic.  You can also build a Cardiogram to help you diagnose new illnesses.  Both these rooms will " ..
                            "need to be researched before you can build them.  Now you can also buy extra plots of land to expand your " ..
                            "hospital - use the Town map for this.  Aim for a reputation of 300 a bank balance of $10,000 and 40 people cured."

-- Override for level progress typo
level_progress.hospital_value_enough = "Keep the value of your hospital above %d and attend to your other problems to win the level."
level_progress.cured_enough_patients = "You've cured enough of your patients, but you need to get your hospital in better order to win the level."

-- Override for multiplayer typos
multiplayer.players_failed = "The following player(s) failed to achieve the last objective:"
multiplayer.everyone_failed = "Everyone failed to satisfy that last objective. So everyone gets to play on!"

-- Override for a disease patient choice typo
disease_discovered_patient_choice.need_to_employ = "Employ a %s to be able to handle this situation."

-- Override for shorter messages and a typo in 12.2
letter[9][2] = "You have proved yourself to be the best hospital administrator in medicine's long and chequered history. Such a momentous achievement cannot go unrewarded, so we would like to offer you the honorary post of Supreme Chief of All Hospitals. This comes with a salary of $%d. You will be given a tickertape parade, and people will show their appreciation wherever you go.//"
letter[10][2] = "Congratulations on successfully running every hospital we assigned you to. Such a superb performance qualifies you for the freedom of all the world's cities. You are to be given a pension of $%d, and all we ask is that you travel, for free, around the nation, promoting the work of all hospitals to your adoring public.//"
letter[11][2] = "Your career has been exemplary, and you are an inspiration to all of us. Thank you for running so many hospitals so well. We would like to grant you a lifetime salary of $%d, and would ask simply that you travel by official open-topped car from city to city, giving lectures about how you achieved so much so fast.//"
letter[11][3] = "You are an example to every wise person, and without exception, everybody in the world regards you as a supreme asset.//"
letter[12][2] = "Your successful career as the best hospital administrator since Moses is nearing an end. Befitting your impact on the nation, the Ministry would like to offer you a salary of $%d simply to appear on our behalf, opening fetes, launching ships, and doing chat shows. It would be great PR for us all!//"

-------------------------------  NEW STRINGS  -------------------------------
date_format = {
  daymonth = "%1% %2:months%",
}

object.litter = "Litter"
tooltip.objects.litter = "Litter: Left on the floor by a patient because he did not find a bin to throw it in."

object.rathole = "Rathole"
tooltip.objects.rathole = "Home of a rat family that found your hospital dirty enough to live here."

tooltip.fax.close = "Close this window without deleting the message"
tooltip.message.button = "Left click to open message"
tooltip.message.button_dismiss = "Left click to open message, right click to dismiss it"
tooltip.casebook.cure_requirement.hire_staff = "You need to employ staff to handle this treatment"
tooltip.casebook.cure_type.unknown = "You do not yet know how to treat this disease"
tooltip.research_policy.no_research = "No research is being carried out in this category at the moment"
tooltip.research_policy.research_progress = "Progress towards the next discovery in this category: %1%/%2%"

tooltip.watch.tutorial = "Quit tutorial"

menu["player_count"] = "PLAYER COUNT"

menu_file = {
  load =    "  (%1%) LOAD  ",
  save =    "  (%1%) SAVE   ",
  restart = "  (%1%) RESTART",
  quit =    "  (%1%) QUIT   "
}

menu_options = {
  sound = "  (%1%) SOUND   ",
  announcements = "  (%1%) ANNOUNCEMENTS   ",
  music = "  (%1%) MUSIC   ",
  jukebox = "  (%1%) JUKEBOX  ",
  lock_windows = "  LOCK WINDOWS  ",
  edge_scrolling = "  EDGE SCROLLING  ",
  capture_mouse = "  CAPTURE MOUSE  ",
  adviser_disabled = "  (%1%) ADVISER  ",
  warmth_colors = "  WARMTH COLOURS  ",
  wage_increase = "  WAGE REQUESTS  ",
  twentyfour_hour_clock = "  24 HOUR CLOCK  "
}

menu_options_game_speed = {
  pause               = "  (%1%) PAUSE  ",
  slowest             = "  (%1%) SLOWEST  ",
  slower              = "  (%1%) SLOWER  ",
  normal              = "  (%1%) NORMAL  ",
  max_speed           = "  (%1%) MAX SPEED  ",
  and_then_some_more  = "  (%1%) AND THEN SOME MORE  ",
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
  bank_manager  = "  (%1%) BANK MANAGER  ",
  statement     = "  (%1%) STATEMENT  ",
  staff_listing = "  (%1%) STAFF LISTING  ",
  town_map      = "  (%1%) TOWN MAP  ",
  casebook      = "  (%1%) CASEBOOK  ",
  research      = "  (%1%) RESEARCH  ",
  status        = "  (%1%) STATUS  ",
  graphs        = "  (%1%) GRAPHS  ",
  policy        = "  (%1%) POLICY  ",
}

menu_debug = {
  jump_to_level               = "  JUMP TO LEVEL  ",
  connect_debugger            = "  (%1%) CONNECT LUA DBGp SERVER  ",
  transparent_walls           = "  (%1%) TRANSPARENT WALLS  ",
  limit_camera                = "  LIMIT CAMERA  ",
  disable_salary_raise        = "  DISABLE SALARY RAISE  ",
  allow_blocking_off_areas    = "  ALLOW BLOCKING OFF AREAS  ",
  make_debug_fax              = "  MAKE DEBUG FAX  ",
  make_debug_patient          = "  MAKE DEBUG PATIENT  ",
  cheats                      = "  (%1%) CHEATS  ",
  lua_console                 = "  (%1%) LUA CONSOLE  ",
  debug_script                = "  (%1%) RUN DEBUG SCRIPT  ",
  calls_dispatcher            = "  CALLS DISPATCHER  ",
  dump_strings                = "  (%1%) DUMP STRINGS  ",
  dump_gamelog                = "  (%1%) DUMP GAME LOG  ",
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
menu_player_count = {
	players_1 = "  1 PLAYER  ",
	players_2 = "  2 PLAYERS  ",
	players_3 = "  3 PLAYERS  ",
	players_4 = "  4 PLAYERS  ",
}
adviser = {
  room_forbidden_non_reachable_parts = "Placing the room in this location would result in parts of the hospital not being reachable.",
  warnings = {
    no_desk = "You should build a reception desk and hire a receptionist at some point!",
    no_desk_1 = "If you want patients to come to your hospital, you will need to hire a receptionist and build her a desk to work at!",
    no_desk_2 = "Well done, that must be a world record: nearly a year and no patients! If you want to continue as Manager of this hospital, you will need to hire a receptionist and build a reception desk for her to work from!",
    no_desk_3 = "That's just brilliant, nearly a year and you don't have a staffed reception! How do you expect to get any patients? Now get it sorted out and stop messing around!",
    no_desk_4 = "A Receptionist needs to have her own work station to greet your patients as they arrive.",
    no_desk_5 = "Well it's about time, you should start to see some patients arriving soon!",
    no_desk_6 = "You have a receptionist, so how about building a reception desk for her to work from?",
    no_desk_7 = "You've built the reception desk, so how about hiring a receptionist? You won't see any patients until you get this sorted out you know!",
    another_desk = "You'll need to build another desk for that new receptionist.",
    cannot_afford = "You don't have enough money in the bank to hire that person!", -- I can't see anything like this in the original strings
    cannot_afford_2 = "You don't have enough money in the bank to make that purchase!",
    falling_1 = "Hey! That is not funny, watch where you click that mouse; someone could get hurt!",
    falling_2 = "Stop messing about, how would you like it?",
    falling_3 = "Ouch, that had to hurt, someone call a Doctor!",
    falling_4 = "This is a Hospital, not a Theme Park!",
    falling_5 = "This is not the place for knocking people over, they're ill you know!",
    falling_6 = "This is not a bowling alley, sick people should not be treated like that!",
    research_screen_open_1 = "You have to build a Research Department before you can access the Research screen.",
    research_screen_open_2 = "Research is disabled for the current level.",
    researcher_needs_desk_1 = "A Researcher needs to have a desk to work at.",
    researcher_needs_desk_2 = "Your Researcher is pleased that you have allowed him to have a break. If you were intending to have more staff researching, then you need to provide them each with a desk to work from.",
    researcher_needs_desk_3 = "Each Researcher needs to have his own desk to work from.",
    nurse_needs_desk_1 = "Each Nurse needs to have her own desk to work from.",
    nurse_needs_desk_2 = "Your Nurse is pleased that you have allowed her to have a break. If you were intending to have more than one working in the ward, then you need to provide them each with a desk to work from.",
    low_prices = "You're charging too little for %s. This will bring people to your hospital, but you won't make a lot of profit from each one.",
    high_prices = "Your charges for %s are high. This will make big profits in the short-term, but ultimately you'll start to drive people away.",
    fair_prices = "Your charges for %s seem fair and balanced.",
    patient_not_paying = "A patient left without paying for %s because it's too expensive!",
  },
  cheats = {
    th_cheat = "Congratulations, you have unlocked cheats!",
    roujin_on_cheat = "Roujin's challenge activated! Good luck in the coming months...",
    roujin_off_cheat = "Roujin's challenge deactivated. Everything will be back to normal soon.",
  },
  tutorial = {
    start = "Welcome to the tutorial. Click me or my speech button to move to the next step. Click the button above the watch to leave the tutorial.",
  },
}

dynamic_info.patient.actions.no_gp_available = "Waiting for you to build a GP's office"
dynamic_info.staff.actions.heading_for = "Heading for %s"
dynamic_info.staff.actions.fired = "Fired"
dynamic_info.staff.actions.vaccine = "Vaccinating a patient"
dynamic_info.patient.actions.epidemic_vaccinated = "I am no longer contagious"

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
  dear_player = "Dear %s\n",
  custom_level_completed = "Well done! You've completed all goals on this custom level!",
  return_to_main_menu = "Would you like to return to the main menu or continue playing?",
  campaign_level_completed = "Good job! You beat the level. But it's not over yet!\n Would you like a position at %s Hospital?",
  campaign_completed = "Incredible! You managed to finish all the levels. You can now relax and enjoy filling forums across the Internet of your achievements. Good luck!",
  campaign_level_missing = "Sorry, but the next level of this campaign seems to be missing. (Name: %s)",
}

install = {
  title = "--------------------------------- CorsixTH Setup ---------------------------------",
  th_directory = "CorsixTH needs a copy of the data files from the original Theme Hospital game (or demo) in order to run. Please use the below selector to locate the Theme Hospital install directory.",
  ok = "OK",
  exit = "Exit",
  cancel = "Cancel",
}

misc.not_yet_implemented = "(not yet implemented)"
misc.no_heliport = "Either no diseases have been discovered yet, or there is no heliport on this map. It might be that you need to build a reception desk and hire a receptionist"
misc.cant_treat_emergency = "Your hospital cannot treat this emergency because its disease has not been discovered. Feel free to try again."

main_menu = {
  new_game = "Campaign",
  custom_campaign = "Custom Campaign",
  custom_level = "Single Scenario",
  continue = "Continue Game",
  load_game = "Load Game",
  options = "Settings",
  map_edit = "Map Editor",
  savegame_version = "Savegame version: ",
  version = "Version: ",
  exit = "Exit",
}

tooltip.main_menu = {
  new_game = "Start the first level on the campaign",
  custom_campaign = "Play a campaign created by the community",
  custom_level = "Build your hospital in a single scenario",
  continue = "Continue your latest saved game",
  load_game = "Load a saved game",
  options = "Tweak various settings",
  map_edit = "Create a custom map",
  exit = "No, no, please don't leave!",
  quit = "You are about to quit from CorsixTH. Are you sure this is what you want to do?",
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
  load_selected_level = "Start",
}

tooltip.custom_game_window = {
  choose_game = "Click a level to read more about it",
  free_build = "Tick this box if you want to play without money or winning and losing conditions",
  load_selected_level = "Load and play the selected level",
}

custom_campaign_window = {
  caption = "Custom Campaign",
  start_selected_campaign = "Start campaign",
}

tooltip.custom_campaign_window = {
  choose_campaign = "Choose a campaign to read more about it",
  start_selected_campaign = "Load the first level of this campaign",
}

save_game_window = {
  caption = "Save Game (%1%)",
  new_save_game = "New Savegame",
}

tooltip.save_game_window = {
  save_game = "Overwrite savegame %s",
  new_save_game = "Enter name for a new savegame",
}

save_map_window = {
  caption = "Save Map (%1%)",
  new_map = "New Map",
}

tooltip.save_map_window = {
  map = "Overwrite map %s",
  new_map = "Enter name for a map savegame",
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
  capture_mouse = "Capture Mouse",
  custom_resolution = "Custom...",
  width = "Width",
  height = "Height",
  audio = "Global Audio",
  customise = "Customise",
  folder = "Folders",
  language = "Game Language",
  apply = "Apply",
  cancel = "Cancel",
  back = "Back",
  scrollspeed = "Scroll Speed",
  shift_scrollspeed = "Shift Scroll Speed",
  zoom_speed = "Zoom Speed",
  hotkey = "Hotkeys",
}

tooltip.options_window = {
  fullscreen = "Whether the game should run in fullscreen or windowed mode",
  fullscreen_button = "Click to toggle fullscreen mode",
  resolution = "The resolution the game should run in",
  select_resolution = "Select a new resolution",
  capture_mouse = "Click to toggle capturing the cursor in the game window",
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
  scrollspeed = "Set the scroll speed between 1 (slowest) to 10 (fastest). The default is 2.",
  shift_scrollspeed = "Set the speed of scrolling while the shift key is pressed. 1 (slowest) to 10 (fastest). The default is 4.",
  zoom_speed = "Set the camera zoom speed from 10 (slowest) to 1000 (fastest). The default is 80.",
  apply_scrollspeed = "Apply the entered scroll speed.",
  cancel_scrollspeed = "Return without changing the scroll speed.",
  apply_shift_scrollspeed = "Apply the entered shift scroll speed.",
  cancel_shift_scrollspeed = "Return without changing the shift scroll speed.",
  apply_zoomspeed = "Apply the entered zoom speed.",
  cancel_zoomspeed = "Return without changing the zoom speed.",
  hotkey = "Change keyboard hotkeys.",
}

customise_window = {
  caption = "Custom Settings",
  option_on = "On",
  option_off = "Off",
  back = "Back",
  movies = "Global Movie Control",
  intro = "Play Intro Movie",
  paused = "Build on Paused",
  volume = "Volume Down Hotkey",
  aliens = "Alien Patients",
  fractured_bones = "Fractured Bones",
  average_contents = "Average Contents",
  remove_destroyed_rooms = "Remove destroyed rooms",
}

tooltip.customise_window = {
  movies = "Global movie control, this will allow you to disable all the movies",
  intro = "Turn off or on the intro movie, global movies will need to be on if you want the intro movie to play each time you load CorsixTH",
  paused = "In Theme Hospital the player would only be allowed to use the top menu if the game was paused. That is the default setting in CorsixTH too, but by turning this on everything is allowed while the game is paused",
  volume = "If the volume down button is also opening the casebook, turn this on to change the hotkey for the casebook to Shift + C",
  aliens = "Because of the lack of proper animations we have by default made patients with Alien DNA only come from an emergency. To allow patients with Alien DNA to visit your hospital, other than by an emergency, turn this off",
  fractured_bones = "Because of a poor animation we have by default made it so there are no female patients with Fractured Bones. To allow female patients with Fractured Bones to visit your hospital, turn this off",
  average_contents = "If you would like the game to remember what extra objects you usually add when you build rooms, then turn this option on",
  remove_destroyed_rooms = "If you would like to be able to remove destroyed rooms, for a fee, turn this option on",
  back = "Close this menu and go back to the Settings Menu",
}

folders_window = {
  caption = "Folder Locations",
  data_label = "TH Data",
  font_label = "Font",
  music_label = "Music",
  savegames_label = "Saves",
  screenshots_label = "Screenshots",
  -- next four are the captions for the browser window, which are called from the folder setting menu
  new_th_location = "Here you can specify a new Theme Hospital installation directory or ISO file. As soon as you choose the new directory the game will be restarted. Note that file extensions are not currently shown.",
  savegames_location = "Select the directory you want to use for Saves",
  music_location = "Select the directory you want to use for your Music",
  screenshots_location = "Select the directory you want to use for Screenshots",
  back  = "Back",
}

tooltip.folders_window = {
  browse = "Browse for folder location",
  data_location = "The directory or ISO file of the original Theme Hospital installation, which is required to run CorsixTH",
  font_location = "Location of a font file that is capable of displaying Unicode characters required by your language. If this is not specified you will not be able to choose languages that need more characters than the original game can supply. Example: Russian and Chinese",
  savegames_location = "By default, the Saves directory is alongside the config file and will be used for storing saved games in. Alternatively, you can choose your own by browsing to the directory that you want to use.",
  screenshots_location = "By default, the Screenshots are stored in a folder alongside the config file. Alternatively, you can choose your own by browsing to the directory that you want to use.",
  music_location = "Select a location for your music files by browsing to the directory you want to use (directory must already exist beforehand).",
  browse_data = "Browse for another location for your Theme Hospital installation ( Current location: %1% ) ",
  browse_font = "Browse for another font file ( Current location: %1% ) ",
  browse_saves = "Browse for another location for your Saves directory ( Current location: %1% ) ",
  browse_screenshots = "Browse for another location for your Screenshots directory ( Current location: %1% ) ",
  browse_music = "Browse for another location for your Music directory ( Current location: %1% ) ",
  no_font_specified = "No font location specified yet!",
  not_specified = "No folder location specified yet!",
  default = "Default location",
  reset_to_default = "Reset the directory to its default location",
 -- original_path = "The currently chosen directory of the original Theme Hospital installation", -- where is this used, I have left if for the time being?
  back  = "Close this menu and go back to the Settings Menu",
}

hotkey_window = {
  caption_main = "Hotkey Assignment",
  caption_panels = "Panel Keys",
  button_accept = "Accept",
  button_defaults = "Reset to Defaults",
  button_cancel = "Cancel",
  button_back = "Back",
  button_toggleKeys = "Toggle Keys",
  button_recallPosKeys = "Recall Position Keys",
  panel_globalKeys = "Global Keys",
  panel_generalInGameKeys = "General In-Game Keys",
  panel_scrollKeys = "Scroll Keys",
  panel_zoomKeys = "Zoom Keys",
  panel_gameSpeedKeys = "Game Speed Keys",
  panel_miscInGameKeys = "Misc. In-Game Keys",
  panel_toggleKeys = "Toggle Keys",
  panel_debugKeys = "Debug Keys",
  panel_storePosKey = "Store Position Keys",
  panel_recallPosKeys = "Recall Position Keys",
  panel_altPanelKeys = "Alternate Panel Keys",
  global_confirm = "Confirm",
  global_confirm_alt = "Confirm Alt",
  global_cancel = "Cancel",
  global_cancel_alt = "Cancel Alt",
  global_fullscreen_toggle = "Fullscreen",
  global_exitApp = "Exit App",
  global_resetApp = "Reset App",
  global_releaseMouse = "Release Mouse",
  global_connectDebugger = "Debugger",
  global_showLuaConsole = "Lua Console",
  global_runDebugScript = "Debug Script",
  global_screenshot = "Screenshot",
  global_stop_movie_alt = "Stop Movie",
  global_window_close_alt = "Close Window",
  ingame_scroll_up = "Scroll Up",
  ingame_scroll_down = "Scroll Down",
  ingame_scroll_left = "Scroll Left",
  ingame_scroll_right = "Scroll Right",
  ingame_scroll_shift = "Speed Shift",
  ingame_zoom_in = "Zoom In",
  ingame_zoom_in_more = "Zoom In More",
  ingame_zoom_out = "Zoom Out",
  ingame_zoom_out_more = "Zoom Out More",
  ingame_reset_zoom = "Reset Zoom",
  ingame_showmenubar = "Show Menu Bar",
  ingame_showCheatWindow = "Cheat Menu",
  ingame_loadMenu = "Load Game",
  ingame_saveMenu = "Save Game",
  ingame_jukebox = "Jukebox",
  ingame_openFirstMessage = "Level Message",
  ingame_pause = "Pause",
  ingame_gamespeed_slowest = "Slowest",
  ingame_gamespeed_slower = "Slower",
  ingame_gamespeed_normal = "Normal",
  ingame_gamespeed_max = "Max",
  ingame_gamespeed_thensome = "Then Some",
  ingame_gamespeed_speedup = "Speed Up",
  ingame_panel_bankManager = "Bank Manager",
  ingame_panel_bankStats = "Bank Status",
  ingame_panel_staffManage = "Manage Staff",
  ingame_panel_townMap = "Town Map",
  ingame_panel_casebook = "Casebook",
  ingame_panel_research = "Research",
  ingame_panel_status = "Status",
  ingame_panel_charts = "Charts",
  ingame_panel_policy = "Policy",
  ingame_panel_map_alt = "Town Map 2",
  ingame_panel_research_alt = "Research 2",
  ingame_panel_casebook_alt = "Casebook 2",
  ingame_panel_casebook_alt02 = "Casebook 3",
  ingame_panel_buildRoom = "Build Room",
  ingame_panel_furnishCorridor = "Furnish Corridor",
  ingame_panel_editRoom = "Edit Room",
  ingame_panel_hireStaff = "Hire Staff",
  ingame_rotateobject = "Rotate Object",
  ingame_quickSave = "Quick Save",
  ingame_quickLoad = "Quick Load",
  ingame_restartLevel = "Restart Level",
  ingame_quitLevel = "Quit Level",
  ingame_setTransparent = "Transparent",
  ingame_toggleAnnouncements = "Announcements",
  ingame_toggleSounds = "Sounds",
  ingame_toggleMusic = "Music",
  ingame_toggleAdvisor = "Advisor",
  ingame_toggleInfo = "Info",
  ingame_poopLog = "Dump Log",
  ingame_poopStrings = "Dump Strings",
  ingame_patient_gohome = "Send Home",
  ingame_storePosition_1 = "1",
  ingame_storePosition_2 = "2",
  ingame_storePosition_3 = "3",
  ingame_storePosition_4 = "4",
  ingame_storePosition_5 = "5",
  ingame_storePosition_6 = "6",
  ingame_storePosition_7 = "7",
  ingame_storePosition_8 = "8",
  ingame_storePosition_9 = "9",
  ingame_storePosition_0 = "10",
  ingame_recallPosition_1 = "1",
  ingame_recallPosition_2 = "2",
  ingame_recallPosition_3 = "3",
  ingame_recallPosition_4 = "4",
  ingame_recallPosition_5 = "5",
  ingame_recallPosition_6 = "6",
  ingame_recallPosition_7 = "7",
  ingame_recallPosition_8 = "8",
  ingame_recallPosition_9 = "9",
  ingame_recallPosition_0 = "10",
}

tooltip.hotkey_window = {
  button_accept = "Accept and save hotkey assignments",
  button_defaults = "Reset all hotkeys to the program's defaults",
  button_cancel = "Cancel the assignment and go back to the options menu",
  caption_panels = "Open window to assign panel keys",
  button_recallPosKeys = "Open window to set keys to store and recall camera positions",
  button_back_02 = "Go back to the main hotkey window. Hotkeys changed in this window can be accepted there",
}

font_location_window = {
  caption = "Choose font (%1%)",
}

handyman_window = {
  all_parcels = "All plots",
  parcel = "Plot"
}

tooltip.handyman_window = {
  parcel_select = "The plot where the handyman accepts tasks, click to change setting"
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
  compatibility_error = "Sorry, this save was created with a newer version of CorsixTH and is not compatible. Please update to a more recent version.",
  no_games_to_contine = "There are no saved games.",
  load_quick_save = "Error, cannot load the quicksave as it does not exist, not to worry as we have now created one for you!",
  map_file_missing = "Could not find the map file %s for this level!",
  minimum_screen_size = "Please enter a screen size of at least 640x480.",
  unavailable_screen_size = "The screen size you requested is not available in fullscreen mode.",
  alien_dna = "NOTE: There are no animations for Alien patients for sitting down, opening or knocking on doors etc. Like with Theme Hospital, performing those actions will change the patient to normal then back to Alien. Patients with Alien DNA will only appear if they are set to in the level file.",
  fractured_bones = "NOTE: The animation for female patients with Fractured Bones is not perfect",
  could_not_load_campaign = "Failed to load the campaign: %s",
  could_not_find_first_campaign_level = "Could not find the first level of this campaign: %s",
  save_to_tmp = "The file at %s could not be used. The game has been saved to %s. Error: %s",
}

warnings = {
  levelfile_variable_is_deprecated = "Notice: The level '%s' contains a deprecated variable definition in the level file." ..
                                     "'%LevelFile' has been renamed to '%MapFile'. Please advise the map creator to update the level.",
  newersave = "Warning, you have loaded a save from a newer version of CorsixTH. It is not recommended to continue as crashes may occur. Play at your own risk."
}

confirmation = {
  needs_restart = "Changing this setting requires CorsixTH to restart. Any unsaved progress will be lost. Are you sure you want to do this?",
  abort_edit_room = "You are currently building or editing a room. If all required objects are placed it will be finished, but otherwise it will be deleted. Continue?",
  maximum_screen_size = "The screen size you have entered is greater than 3000 x 2000. Larger resolutions are possible but will require better hardware in order to maintain a playable frame rate. Are you sure you want to continue?",
  remove_destroyed_room = "Would you like to remove the room for $%d?",
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
    "Machines such as the Inflator need maintenance. Employ a handyman or two to repair your machines, or you'll risk your staff and patients getting hurt.",
    "After a while, your staff will get tired. Be sure to build a staff room, so they can relax.",
    "Place enough radiators to keep your staff and patients warm, or they will become unhappy. Use the town map to locate any spots in your hospital that need more heating.",
    "A doctor's skill level greatly influences the quality and speed of his diagnoses. Place a skilled doctor in your GP's office, and you won't need as many additional diagnosis rooms.",
    "Juniors and doctors can improve their skills by learning from a consultant in the training room. If the consultant has a special qualification (surgeon, psychiatrist, or researcher), he will also pass on this knowledge to his pupil(s).",
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
    epidemic = "Spawn contagious patient",
    toggle_infected = "Toggle infected icons",
    create_patient = "Create Patient",
    end_month = "End of Month",
    end_year = "End of Year",
    lose_level = "Lose Level",
    win_level = "Win Level",
    increase_prices = "Increase prices",
    decrease_prices = "Decrease prices",
  },
  close = "Close",
}

tooltip.cheats_window = {
  close = "Close the cheats dialog",
  cheats = {
    money = "Adds $10,000 to your bank balance",
    all_research = "Completes all research",
    emergency = "Creates an emergency",
    vip = "Creates a VIP",
    earthquake = "Creates an earthquake",
    epidemic = "Creates a contagious patient who may cause an epidemic to happen",
    toggle_infected = "Toggle the infected icons for the active, discovered epidemic",
    create_patient = "Creates a Patient at the map border",
    end_month = "Jumps to the end of the month",
    end_year = "Jumps to the end of the year",
    lose_level = "Lose the current level",
    win_level = "Win the current level",
    increase_prices = "Increase all prices by 50% (max. 200%)",
    decrease_prices = "Decrease all prices by 50% (min. 50%)",
  }
}

--Level description, can be double spaced after full-stop
introduction_texts = {
  demo =
    "Welcome to the demo hospital!//" ..
    "Unfortunately the demo version only contains this level.  However, there is more than enough to do here to keep you busy for a while!  " ..
    "You will encounter various diseases that require different rooms to cure.  From time to time, emergencies may occur.  And you will need to research additional rooms using a research room.  " ..
    "Your goal is to earn $100,000, have a hospital value of $70,000 and a reputation of 700, while having cured at least 75% of your patients.  " ..
    "Make sure your reputation does not fall below 300 and that you don't kill off more than 40% of your patients, or you will lose.//" ..
    "Good luck!",
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

map_editor_window = {
  pages = {
    inside = "Inside",
    outside = "Outside",
    foliage = "Foliage",
    hedgerow = "Hedgerow",
    pond = "Pond",
    road = "Road",
    north_wall = "North wall",
    west_wall = "West wall",
    helipad = "Helipad",
    delete_wall = "Delete walls",
    parcel_0 = "Parcel 0",
    parcel_1 = "Parcel 1",
    parcel_2 = "Parcel 2",
    parcel_3 = "Parcel 3",
    parcel_4 = "Parcel 4",
    parcel_5 = "Parcel 5",
    parcel_6 = "Parcel 6",
    parcel_7 = "Parcel 7",
    parcel_8 = "Parcel 8",
    parcel_9 = "Parcel 9",
    camera_1 = "Camera 1",
    camera_2 = "Camera 2",
    camera_3 = "Camera 3",
    camera_4 = "Camera 4",
    heliport_1 = "Heliport 1",
    heliport_2 = "Heliport 2",
    heliport_3 = "Heliport 3",
    heliport_4 = "Heliport 4",
    paste = "Paste area",
  }
}

fax = {
vip_visit_result = {
  ordered_remarks = {
    [1] = "What a storming hospital. When I'm next seriously ill, take me there.",
    [2] = "Now that's what I call a hospital.",
    [3] = "That's a super hospital. And I should know; I've been in a few.",
    [4] = "What a well-run hospital. Thanks for inviting me to it.",
    [5] = "Hmm. Not a bad medical establishment, certainly.",
    [6] = "I did enjoy your charming hospital. Now, anyone fancy a curry at the Taj?",
    [7] = "Well, I've seen worse. But you should make some improvements.",
    [8] = "Oh dear. Not a nice place to go if you're feeling peaky.",
    [9] = "It's a standard hospital, to be honest. Frankly, I expected more.",
    [10] = "Why did I bother? It was worse than going to see a four-hour opera!",
    [11] = "I'm disgusted by what I saw. Call that a hospital? Pig-sty, more like!",
    [12] = "I'm fed up of being in the public spotlight and visiting smelly holes like this! I resign.",
    [13] = "What a dump. I'm going to try and get it closed down.",
    [14] = "I have never seen such a dreadful hospital. What a disgrace!",
    [15] = "I'm shocked. You can't call that a hospital! I'm off for a pint.",
    }
  }
}

hotkeys_file_err = {
  file_err_01 = "Unable to load hotkeys.txt file. Please ensure that CorsixTH " ..
        "has permission to read/write ",
  file_err_02 = ", or use the --hotkeys-file=filename command line option to specify a writable file. " ..
        "For reference, the error loading the hotkeys file was: ",
}

transactions.remove_room = "Build: Remove destroyed room"
--------------------------------  UNUSED  -----------------------------------
------------------- (kept for backwards compatibility) ----------------------

options_window.change_resolution = "Change resolution"
tooltip.options_window.change_resolution = "Change the window resolution to the dimensions entered on the left"
