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

-- Note: This file contains UTF-8 text. Make sure your editor is set to UTF-8.

Language("german", "de", "ger", "deu")
Inherit("english")
Inherit("original_strings", 2)

-- override

object.litter = utf8 "Müll"

diseases.broken_wind.cure = utf8 " Therapie: Eine spezielle Mixtur aus der Pharma-Theke sorgt für Windstille." -- original string mentioned inflation, which is plain wrong.
diseases.corrugated_ankles.cure = utf8 "Therapie: Eine Schwester verabreicht dem Patienten ein leicht toxisches Gebräu, welches das Bein wieder strafft." -- original string mentioned applying a cast, which is wrong and misleads people to think of fracture clinic
fax.vip_visit_result.remarks.super[1] = utf8 "Was für ein Spitzen-Krankenhaus! Wenn ich das nächste mal ernsthaft krank bin, will ich hier hin!" -- storming should not be translated with 'turbulent' here
fax.epidemic.declare_explanation_fine = utf8 "Wenn Sie die Epidemie melden, zahlen Sie eine Strafe von %d und Ihr Ruf leidet. Dafür werden die Patienten automatisch geimpft." -- extend to mention reputation hit and automatic vaccination

-- new strings

menu_options_game_speed.pause        = "  PAUSE"

menu_debug = {
  transparent_walls   =utf8 "  DURCHSICHTIGE WÄNDE",
  limit_camera            = "  KAMERA BEGRENZEN",
  disable_salary_raise=utf8 "  KEINE GEHALTSERHÖHUNGEN",
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
  parcel              =utf8 "  GRUNDSTÜCK"
}

adviser.room_forbidden_non_reachable_parts = utf8 "Sie können den Raum hier nicht bauen, da dann Teile des Krankenhauses nicht mehr erreichbar wären."

fax = {
  welcome = {
    beta1 = {
      "Willkommen zu CorsixTH, einem Open-Source-Klon von Bullfrogs Spieleklassiker Theme Hospital!",
      utf8 "Dies ist die spielbare Beta 1 von CorsixTH. Viele Räume, Krankheiten etc. wurden implementiert, aber es fehlen auch noch einige Dinge.",
      utf8 "Wenn dir das Projekt gefällt, kannst du uns unterstützen, z.B. indem du Fehler berichtest oder uns bei der Programmierung hilfst.",
      utf8 "Jetzt wünschen wir aber erstmal viel Spaß mit dem Spiel! Falls du Theme Hospital nicht kennst: Baue eine Rezeption (aus dem Objekte-Menü) und eine Allgemeinmedizin (Diagnoseraum), dann diverse Behandlungsräume.",
      "-- Das CorsixTH-Team, th.corsix.org",
      "PS: Kannst du die Geheimnisse finden, die wir eingebaut haben?",
    }
  }
}
