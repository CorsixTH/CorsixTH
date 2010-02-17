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

-- new strings
object.litter = "Litter"

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
  place_objects               = "  PLACE OBJECTS  ",
  dump_strings                = "  DUMP STRINGS  ",
  tutorial                    = "  TUTORIAL  ",
  map_overlay                 = "  MAP OVERLAY  ",
  sprite_viewer               = "  SPRITE VIEWER  ",
}
menu_debug_overlay = {
  none                        = "  NONE  ",
  flags                       = "  FLAGS  ",
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

fax = {
  welcome = {
    beta1 = {
      "Welcome to CorsixTH, an open source clone of the classic game Theme Hospital by Bullfrog!",
      "This is playable beta 1 of CorsixTH. Many rooms, diseases and features have been implemented, but there are still many things missing.",
      "If you like this project, you can help us with development, e.g. by reporting bugs or starting to code something yourself.",
      "But now, have fun with the game! For those who are unfamiliar with Theme Hospital: Start by building a reception desk (from the objects menu) and a GP's office (diagnosis room). Various treatment rooms will also be needed.",
      "-- The CorsixTH team, th.corsix.org",
      "PS: Can you find the easter eggs we included?",
    }
  }
}
