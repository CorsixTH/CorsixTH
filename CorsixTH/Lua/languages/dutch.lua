--[[ Copyright (c) 2010 RAS

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
SOFTWARE.


-------------------------------------------------------------------------------
   READ BEFORE DOING ANY CHANGES

   LEES VOORDAT JE AANPASSINGEN DOET
-------------------------------------------------------------------------------

This file contains UTF-8 text. Make sure your editor is set to UTF-8.

De huidige lijst met vertaalde strings is gemaakt op basis van het
debug-strings-new-grouped.txt bestand dat gegenereerd kan worden als je het spel
in de debug-mode hebt gestart. Onderstaande strings staan in dezelfde volgorde
als in dit bestand, echter met nog veel gaten ertussen. Zorg dat alles in de
dezelfde volgorde als het debug-strings-new-grouped.txt-bestand blijft staan!




-------------------------------------------------------------------------------
   TABLE OF CONTENTS

   INHOUDSOPGAVE
-------------------------------------------------------------------------------


   SECTION A - NEW STRINGS

   1. Global settings
   2. Misc
   3. 
-----------------------------------------------------------------------------]]



-------------------------------------------------------------------------------
--   SECTION A - NEW STRINGS - NIEUWE STRINGS
-------------------------------------------------------------------------------

-- 1. Global settings (do not edit!)
Language("Dutch", "nl", "dut", "nld")
Inherit("English")

-- 2. Misc
misc = {
  hospital_open = "Ziekenhuis open",
  save_success = "Spel succesvol opgeslagen",
  save_failed = "ERROR: Opslaan mislukt",
  low_res = "Lage resolutie",
  no_heliport = "Er zijn nog geen ziektebeelden ontdekt, of er is geen helikopter-landingsplaats op deze kaart.",
  grade_adverb = {
    extremely = "extreem",
    mildly = "eenvoudig",
    moderately = "normaal",
  },
  not_yet_implemented = utf8 "(nog niet geïmplementeerd)",
  send_message = "Stuur bericht naar speler %d",
  out_of_sync = "Het spel loopt niet meer synchroon",
  balance = "Balans Bestand:",
  load_failed = "Spel laden mislukt",
  mouse = "Muis",
  done = "Gereed",
  force = "Force",
  pause = "Pauze",
  send_message_all = "Stuur een bericht naar alle spelers",
}

menu_charts = {
  briefing = "  BRIEFING  ",
  casebook = "  ZIEKTEBEELDEN  ",
  graphs = "  GRAFIEKEN  ",
  policy = "  REGELS  ",
  bank_manager = "  BANK MANAGER  ",
  statement = "  BRIEFING  ",
  staff_listing = "  PERSONEEL  ",
  research = "  ONDERZOEK  ",
  status = "  STATUS  ",
}

menu_debug_overlay = {
  byte_w_wall = "  BYTE W MUUR  ",
  byte_6 = "  BYTE 6  ",
  byte_0_1 = "  BYTE 0 & 1  ",
  byte_7 = "  BYTE 7  ",
  byte_5 = "  BYTE 5  ",
  byte_floor = "  BYTE VLOER  ",
  positions = "  POSITIES  ",
  flags = "  VLAGGEN  ",
  parcel = "  PARCEEL  ",
  byte_n_wall = "  BYTE N MUUR  ",
  none = "  NIKS  ",
}

dynamic_info = {
  patient = {
    emergency = "Noodgeval: %s",
    guessed_diagnosis = "vermoedelijke diagnose: %s ",
    diagnosis_progress = "Diagnose verloop",
    actions = {
      sent_to_other_hospital = "Naar ander ziekenhuis verwezen",
      prices_too_high = "Je prijzen zijn veel te hoog - Ik ga naar huis",
      no_gp_available = "Wachtend op bouw huisartspraktijk",
      waiting_for_treatment_rooms = "wachtend op bouw behandelingskamer",
      dying = "Stervende!",
      no_diagnoses_available = "Geen diagnoses meer beschikbaar - Ik ga naar huis",
      epidemic_sent_home = "Weg gestuurd door de inspecteur",
      cured = "Genezen!",
      waiting_for_diagnosis_rooms = "Wachtend op bouw van meer diagnose faciliteiten",
      epidemic_contagious = "Ik heb een besmettelijke ziekte",
      awaiting_decision = "Wachtend op jouw beslissing",
      sent_home = "Naar huis gestuurd",
      fed_up = "Ik ben het zat, ajuu",
      no_treatment_available = "Geen behandeling beschikbaar - Ik ga naar huis",
      on_my_way_to = "Op weg naar %s",
      queueing_for = "In wachtrij voor %s",
    },
    diagnosed = "Gediagnosticeerd: %s ",
  },
  health_inspector = "Gezondheidsinspecteur",
  vip = "VIP bezoeker",
  object = {
    times_used = "Aantal keer gebruikt %d",
    queue_size = "Lengte Wachtrij %d",
    strength = "Sterkte %d",
    queue_expected = "Verwacht %d",
  },
  staff = {
    ability = "Kwaliteiten",
    psychiatrist_abbrev = "Psych.",
    actions = {
      waiting_for_patient = utf8 "wachtend op patiënt",
      wandering = "Gewoon wat rondbanjeren",
      going_to_repair = "Op weg voor reparatie van %s",
      heading_for = "Op weg naar %s",
    },
    tiredness = "Vermoeidheid",
  },
}

main_menu = {
  exit = "Afsluiten",
  custom_level = "Zelf gemaakt Level",
  new_game = "Nieuw spel",
  load_game = "Laad spel",
  options = "Opties",
}

menu_file_load = {
  [1] = "  SPEL 1  ",
  [2] = "  SPEL 2  ",
  [3] = "  SPEL 3  ",
  [4] = "  SPEL 4  ",
  [5] = "  SPEL 5  ",
  [6] = "  SPEL 6  ",
  [7] = "  SPEL 7  ",
  [8] = "  SPEL 8  ",
}

menu_file = {
  quit = "  AFSLUITEN  ",
  save = "  OPSLAAN  ",
  load = "  LADEN  ",
  restart = "(no string) restart",
}

menu_debug = {
  sprite_viewer = "  SPRITE VIEWER  ",
  lose_game_anim = {
    [1] = "  VERLIES SPEL 1 ANIM     ",
    [2] = "  VERLIES SPEL 2 ANIM     ",
    [3] = "  VERLIES SPEL 3 ANIM     ",
    [4] = "  VERLIES SPEL 4 ANIM     ",
    [5] = "  VERLIES SPEL 5 ANIM     ",
    [6] = "  VERLIES SPEL 6 ANIM     ",
    [7] = "  VERLIES SPEL 7 ANIM     ",
  },
  show_watch = "  TOON KLOK  ",
  disable_salary_raise = "  INACTIVEER SALARIS VERHOGING  ",
  object_cells = "  OBJECT CELLEN         ",
  create_emergency = utf8 "  CREËER NOODGEVAL  ",
  make_adviser_talk = "  LAAT ADVISEUR SPREKEN  ",
  dump_strings = "  DUMP STRINGS  ",
  limit_camera = "  LIMITEER CAMERA  ",
  machine_pagers = "  MACHINE PAGERS       ",
  remove_walls = "  VERWIJDER MUREN         ",
  place_objects = "  PLAATS OBJECTEN  ",
  enter_nav_debug = "  ENTER NAV DEBUG      ",
  remove_objects = "  VERWIJDER OBJECTEN       ",
  display_pager = "  TOON PAGER        ",
  map_overlay = "  MAP OVERLAY  ",
  spawn_patient = utf8 "  CREëER PATIENT  ",
  pixbuf_cells = "  PIXBUF CELLEN         ",
  win_game_anim = "  WIN SPEL ANIM        ",
  transparent_walls = "  TRANSPARANTE MUREN  ",
  show_help_hotspot = "  TOON HELP HOTSPOTS   ",
  entry_cells = "  INGANG CELLEN          ",
  nav_bits = "  NAV BITS             ",
  display_big_cells = "  TOON GROTE CELLEN    ",
  win_level_anim = "  WIN LEVEL ANIM       ",
  make_debug_patient = utf8 "  MAAK DEBUG PATIËNT  ",
  porter_pagers = "  PORTER PAGERS        ",
  keep_clear_cells = "  HOU CELLEN VRIJ     ",
  show_nav_cells = "  TOON NAV CELLEN       ",
  display_room_status = "  TOON KAMER STATUS  ",
  mapwho_checking = "  MAPWHO CONTROLE      ",
  plant_pagers = "  PLAATS PAGERS       ",
}

months = {
  [1] = "Jan",
  [2] = "Feb",
  [3] = "Maa",
  [4] = "Apr",
  [5] = "Mei",
  [6] = "Jun",
  [7] = "Jul",
  [8] = "Aug",
  [9] = "Sep",
  [10] = "Okt",
  [11] = "Nov",
  [12] = "Dec",
}

menu_options = {
  game_speed = "  SNELHEID  ",
  sound_vol = "  GELUIDEN VOLUME  ",
  announcements = "  MEDEDELINGEN   ",
  lock_windows = "  LOCK WINDOWS  ",
  music_vol = "  MUZIEK VOLUME  ",
  sound = "  GELUIDEN   ",
  announcements_vol = "  MEDEDELINGEN VOLUME  ",
  music = "  MUZIEK   ",
  autosave = "  AUTOSAVE  ",
  jukebox = "  JUKEBOX  ",
}
menu_options_game_speed = {
  normal = "  NORMAAL  ",
  slower = "  LANGZAAM  ",
  pause = "  PAUZE  ",
  max_speed = "  MAX SNELHEID ",
  slowest = "  LANGZAAMST  ",
  and_then_some_more = "  NOG NET IETS MEER ",
}
menu = {
  debug = "  DEBUG  ",
  display = "  BEELD  ",
  file = "  BESTAND  ",
  options = "  OPTIES  ",
  charts = "  INFORMATIE  ",
}




-------------------------------------------------------------------------------
--   SECTION B - OLD STRINGS (OVERRIDE) - OUDE STRINGS (OVERSCHRIJVEN)
-------------------------------------------------------------------------------

-- Empty for now

