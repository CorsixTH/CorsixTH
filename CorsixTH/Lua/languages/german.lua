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

Language("german", "de", "ger", "deu")
Inherit("english")
Inherit("original_strings", 2)

-- NB: umlauts can be written with some special characters:
-- ‰ = Ñ
-- ˆ = î
-- ¸ = Å
-- ƒ = é
-- ÷ = ô
-- ‹ = ö
-- ﬂ = ·

-- override

diseases.broken_wind.cure = " Therapie: Eine spezielle Mixtur aus der Pharma-Theke sorgt fÅr Windstille." -- original string mentioned inflation, which is plain wrong.
-- TODO: diseases.corrugated_ankles.cure -- original string mentioned applying a cast, which is wrong and misleads people to think of fracture clinic

-- new strings

menu_options_game_speed.pause        = "  PAUSE"

menu_debug = {
  transparent_walls       = "  DURCHSICHTIGE WéNDE",
  limit_camera            = "  KAMERA BEGRENZEN",
  disable_salary_raise    = "  KEINE GEHALTSERHôHUNGEN",
  make_debug_patient      = "  DEBUG-PATIENTEN ERSTELLEN",
  spawn_patient           = "  PATIENTEN ERZEUGEN",
  make_adviser_talk       = "  BERATER REDEN LASSEN",
  show_watch              = "  UHR ANZEIGEN",
  place_objects           = "  OBJEKTE PLATZIEREN",
  map_overlay             = "  KARTEN-OVERLAY",
  sprite_viewer           = "  SPRITE-BETRACHTER",
}
menu_debug_overlay = {
  none                    = "  KEIN",
  flags                   = "  FLAGS",
  byte_0_1                = "  BYTE 0 & 1",
  byte_floor              = "  BYTE BODEN",
  byte_n_wall             = "  BYTE N WAND",
  byte_w_wall             = "  BYTE W WAND",
  byte_5                  = "  BYTE 5",
  byte_6                  = "  BYTE 6",
  byte_7                  = "  BYTE 7",
  parcel                  = "  GRUNDSTöCK"
}

adviser.room_forbidden_non_reachable_parts = "Sie kînnen den Raum hier nicht bauen, da dann Teile des Krankenhauses nicht mehr erreichbar wÑren."
