--[[ Copyright (c) 2010 Erlend Mongstad

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

Language("norwegian", "nb", "nob")
Inherit("english")

-- override
staff_class = {
  nurse                 = "Sykepleier",
  doctor                = "Lege",
  handyman              = "Vaktmester",
  receptionist          = "Resepsjonist",
  surgeon               = "Kirurg",
}

-- override
object = {
  desk                  = "Kontorpult",
  cabinet               = "Arkivskap",
  door                  = utf8 "Dör",
  bench                 = "Benk",
  table_1               = "Bord",
  chair                 = "Stol",
  drinks_machine        = "Brusautomat",
  bed1                  = "Seng",
  inflator              = "Pumpe",
  pool_table            = "Biljardbord",
  reception_desk        = "Resepsjon",
  table_2               = "Bord",
  cardio                = "Kardio",
  scanner               = "Skanner",
  console               = "Konsoll",
  screen                = "Skjerm",
  litter_bomb           = utf8 "Söppelbombe",
  couch                 = "Sofa",
  sofa                  = "Sofa",
  crash_trolley         = "Tralle",
  tv                    = "TV",
  ultrascanner          = "Ultraskanner",
  dna_fixer             = "DNA-fikser",
  cast_remover          = "Gipsfjerner",
  hair_restorer         = utf8 "Hårrenoverer",
  slicer                = "Tungekutter",
  x_ray                 = utf8 "Röntgen",
  radiation_shield      = utf8 "Strålingsvern",
  x_ray_viewer          = utf8 "Röntgenfremviser",
  operating_table       = "Operasjonsbord",
  lamp                  = "Lampe",
  sink1                 = "Vask",
  sink2                 = "Vask",
  sink3                 = "Vask",
  surgeon_screen        = "Forheng",
  lecture_chair         = "Forelesningsstol",
  projector             = "Prosjektor",
  bed2                  = "Seng",
  pharmacy_cabinet      = "Medisinskap",
  computer              = "Datamaskin",
  atom_analyser         = "Atomanalyser",
  blood_machine         = "Blodmaskin",
  fire_extinguisher     = "Brannslukningsapparat",
  radiator              = "Ovn",
  plant                 = "Plante",
  electrolyser          = "Elektrolyser",
  jelly_moulder         = utf8 "Geléstøper",
  gates_of_hell         = "Helvetesporten",
  bed3                  = "Seng",
  bin                   = utf8 "Söppelbötte",
  toilet                = "Toalett",
  swing_door1           = utf8 "Svingdör",
  swing_door2           = utf8 "Svingdör",
  shower                = "Saneringsdusj",
  auto_autopsy          = "Obduseringsmaskin",
  bookcase              = "Bokhylle",
  video_game            = "Videospill",
  entrance_left         = utf8 "Inngang venstre dör",
  entrance_right        = utf8 "Inngang höyre dör",
  skeleton              = "Skjelett",
  comfortable_chair     = "Komfortabel stol",
}

-- override
diseases = {
  -- none                = D( 1), -- not used/needed?
  general_practice       = "Allmennpraksis",
  bloaty_head            = "Ballonghode",
  hairyitis              = "Pelssyndrom",
  king_complex           = "Rock'n'Roll syndrom",
  invisibility           = "Usynlighet",
  serious_radiation      = utf8 "Alvorlig stråling",
  slack_tongue           = utf8 "Lös tunge",
  alien_dna              = "Utenomjordisk DNA",
  fractured_bones        = "Benbrudd",
  baldness               = "Flintskalle",
  discrete_itching       = "Skrapesyke",
  jellyitis              = utf8 "Gelésyndrom",
  sleeping_illness       = utf8 "Søvnsyke",
  pregnancy              = "Graviditet",   -- unused
  transparency           = "Gjennomsiktighet",
  uncommon_cold          = utf8 "Forkjölelse",
  broken_wind            = "Forurensende gasser",
  spare_ribs             = "Juleribbe",
  kidney_beans           = "Kikkerter",
  broken_heart           = "Knust hjerte",
  ruptured_nodules       = utf8 "Knekte nötter",
  tv_personalities       = "Programledersyndrom",
  infectious_laughter    = "Smittsom latter",
  corrugated_ankles      = utf8 "Böyde ankler",
  chronic_nosehair       = utf8 "Kronisk nesehår",
  third_degree_sideburns = "Tredjegrads koteletter",
  fake_blood             = "Teaterblod",
  gastric_ejections      = utf8 "Krydrede oppstöt",
  the_squits             = utf8 "Lös mage",
  iron_lungs             = "Jernlunger",
  sweaty_palms           = utf8 "Håndsvette",
  heaped_piles           = "Hemoroider",
  gut_rot                = utf8 "Mageråte",
  golf_stones            = "Golfsteiner",
  unexpected_swelling    = "Uventet hevelse",
  diag_scanner           = "Diag Skanner",
  diag_blood_machine     = "Diag Blodmaskin",
  diag_cardiogram        = "Diag Kardio",
  diag_x_ray             = utf8 "Diag Röntgen",
  diag_ultrascan         = "Diag Ultraskanner",
  diag_general_diag      = "Diag Generell",
  diag_ward              = "Diag Sengeavd.",
  diag_psych             = "Diag Psykiatri",
  autopsy                = "Obduksjon",
  -- mixer               = D(46), -- not used/needed?
}


-- new strings
menu_options_game_speed.pause = "  PAUSE"

menu_debug = {
  transparent_walls           = "  GJENNOMSIKTIGE VEGGER",
  limit_camera                = "  BEGRENS KAMERA",
  disable_salary_raise        = utf8 "  DEAKTIVER LÖNNSÖKNING",
  make_debug_patient          = "  LAG DEBUG PASIENT",
  spawn_patient               = "  SPAWN PASIENT",
  make_adviser_talk           = utf8 "  FÅ RÅDGIVER TIL Å SNAKKE",
  show_watch                  = "  VIS KLOKKE",
  place_objects               = "  PLASSER OBJEKTER",
  map_overlay                 = "  KART OVERLEGG",
  sprite_viewer               = "  SPRITE VISER",
}
menu_debug_overlay = {
  none                        = "  INGEN",
  flags                       = "  FLAGG",
  byte_0_1                    = "  BYTE 0 & 1",
  byte_floor                  = "  BYTE GULV",
  byte_n_wall                 = "  BYTE N VEGG",
  byte_w_wall                 = "  BYTE W VEGG",
  byte_5                      = "  BYTE 5",
  byte_6                      = "  BYTE 6",
  byte_7                      = "  BYTE 7",
  parcel                      = "  PAKKE",
}
adviser.room_forbidden_non_reachable_parts = utf8 "Ved å plassere et rom her vil noen områder på sykehuset bli utilgjengelig."