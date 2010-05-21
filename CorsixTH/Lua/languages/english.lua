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

Language("english", "en", "eng")
Inherit("original_strings", 0)

-- override
adviser.warnings.money_low = "Your money is getting low!" -- Funny. Exists in German translation, but not existent in english?
-- TODO: tooltip.graphs.reputation -- this tooltip talks about hospital value. Actually it should say reputation.
-- TODO: tooltip.status.close -- it's called status window, not overview window.
-- TODO: tooltip.staff_list.next_person, prev_person is rather next/prev page (also in german, maybe more languages?)

-- The originals of these two contain one space too much
fax.emergency.cure_not_possible_build = "You will need to build a %s"
fax.emergency.cure_not_possible_build_and_employ = "You will need to build a %s and employ a %s"

-- new strings
object.litter = "Litter"
tooltip.objects.litter = "Litter: Left on the floor by a patient because he did not find a bin to throw it in."

menu_options.lock_windows = "  LOCK WINDOWS  "
menu_options_game_speed.pause = "  PAUSE  "

menu_debug = {
  transparent_walls           = "  TRANSPARENT WALLS  ",
  limit_camera                = "  LIMIT CAMERA  ",
  disable_salary_raise        = "  DISABLE SALARY RAISE  ",
  make_debug_patient          = "  MAKE DEBUG PATIENT  ",
  spawn_patient               = "  SPAWN PATIENT  ",
  make_adviser_talk           = "  MAKE ADVISER TALK  ",
  show_watch                  = "  SHOW WATCH  ",
  create_emergency            = "  CREATE EMERGENCY  ",
  place_objects               = "  PLACE OBJECTS  ",
  dump_strings                = "  DUMP STRINGS  ",
  dump_gamelog                = "  DUMP GAME LOG",
  map_overlay                 = "  MAP OVERLAY  ",
  sprite_viewer               = "  SPRITE VIEWER  ",
}
menu_debug_overlay = {
  none                        = "  NONE  ",
  flags                       = "  FLAGS  ",
  positions                   = "  POSITIONS  ",
  byte_0_1                    = "  BYTE 0 & 1  ",
  byte_floor                  = "  BYTE FLOOR  ",
  byte_n_wall                 = "  BYTE N WALL  ",
  byte_w_wall                 = "  BYTE W WALL  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  PARCEL  ",
}
adviser.room_forbidden_non_reachable_parts = "Placing the room in this location would result in parts of the hospital not being reachable."

dynamic_info.patient.actions.no_gp_available = "Waiting for you to build a GP's office"
dynamic_info.staff.actions.heading_for = "Heading for %s"

fax = {
  welcome = {
    beta1 = {
      "Welcome to CorsixTH, an open source clone of the classic game Theme Hospital by Bullfrog!",
      "This is playable beta 1 of CorsixTH. Many rooms, diseases and features have been implemented, but there are still many things missing.",
      "If you like this project, you can help us with development, e.g. by reporting bugs or starting to code something yourself.",
      "But now, have fun with the game! For those who are unfamiliar with Theme Hospital: Start by building a reception desk (from the objects menu) and a GP's office (diagnosis room). Various treatment rooms will also be needed.",
      "-- The CorsixTH team, th.corsix.org",
      "PS: Can you find the easter eggs we included?",
    },
    beta2 = {
      "Welcome to the second beta of CorsixTH, an open source clone of the classic game Theme Hospital by Bullfrog!",
      "A lot of new features have been implemented since the last release. Have a look at the changelog for an incomplete list.",
      "But first, let's play! It seems there's a message waiting for you. Close this window and click on the question mark above the bottom panel.",
      "-- The CorsixTH team, th.corsix.org",
    },
  },
  tutorial = {
    "Welcome to your first Hospital!",
    "Would you like a short tutorial?",
    "Yes, please show me the ropes.",
    "Nope, I already know how to do this.",
  },
}

misc.not_yet_implemented = "(not yet implemented)"
misc.no_heliport = "Either no diseases have been discovered yet, or there is no heliport on this map."

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
  back = "Back",
}

tooltip.load_game_window = {
  load_game = "Load game %s",
  load_game_number = "Load game %d",
  load_game_with_name = "Load the level %s",
  load_autosave = "Load autosave",
  back = "Close the load game window",
}

save_game_window = {
  caption = "Save Game",
  new_save_game = "New Savegame",
  back = "Back",
}

tooltip.save_game_window = {
  save_game = "Overwrite savegame %s",
  new_save_game = "Enter name for a new savegame",
  back = "Close the save game window",
}

errors = {
  dialog_missing_graphics = "Sorry, the demo data files don't contain this dialog.",
  save_prefix = "Error while saving game: ",
  load_prefix = "Error while loading game: ",
  map_file_missing = "Could not find the map file for this level!",
}

information = {
  custom_game = "Welcome to CorsixTH. Have fun with this custom map!",
}

totd_window = {
  tips = {
    "Every hospital needs a reception desk and a GP's office to get going. After that, it depends on what kind of patients are visiting your hospital. A pharmacy is always a good choice, though.",
    "Machines such as the Inflation need maintenance. Employ a handyman or two to repair your machines, or you'll risk your staff and patients getting hurt.",
    "After a while, your staff will get tired. Be sure to build a staff room, so they can relax.",
    "Place enough radiators to keep your staff and patients warm, or they will become unhappy.",
    "A doctor's skill level greatly influences the quality and speed of his diagnoses. Place a skilled doctor in your GP's office, and you won't need as many additional diagnosis rooms.",
    "Juniors and doctors can improve their skills by learning from a consultant in the training room. If the consultant has a special qualification (surgeon, psychiatrist or researcher), he will also pass on this knowledge to his pupil(s).",
    "Did you try to enter the European emergency number (112) into the fax machine? Make sure your sound is on!",
    "The options menu is not yet implemented, but you can adjust some settings such as the resolution and language by editing the config.txt in your game directory.",
    "You selected a language other than English, but there's English text all over the place? Help us by translating missing texts into your language!",
    "The CorsixTH team is looking for reinforcements! Are you interested in coding, translating or creating graphics for CorsixTH? Contact us at our Forum, Mailing List or IRC Channel (corsix-th at freenode).",
    "If you find a bug, please report it at our bugtracker: th-issues.corsix.org",
    "CorsixTH was first made public on July 24th, 2009. The first release was playable beta 1 on December 24th, 2009. After three more months, we are proud to present beta 2 (released March 24th, 2010).",
  },
  previous = "Previous Tip",
  next = "Next Tip",
}

tooltip.totd_window = {
  previous = "Display the previous tip",
  next = "Display the next tip",
}
