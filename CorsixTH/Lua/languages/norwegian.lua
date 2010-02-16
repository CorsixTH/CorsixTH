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


-- READ FIRST!
-- Note: This file contains UTF-8 text. Make sure your editor is set to UTF-8.
-- For the norwegian letters ø and Ø, you must use the old-style ö and Ö instead. 
-- Thats because the letters ø and Ø is not included in the original ingame-font.

Language("norwegian", "nb", "nob")
Inherit("english")
-- ..


-- STAFF
-- each of these corresponds to a sprite
staff_class = {
  nurse                 = "Sykepleier",
  doctor                = "Lege",
  handyman              = "Vaktmester",
  receptionist          = "Resepsjonist",
  surgeon               = "Kirurg",
  -- S[1][6] unused
}

-- these are titles used e.g. in the dynamic info bar
staff_title = {
  receptionist          = "Resepsjonist",
  general               = "Generelt", -- unused?
  nurse                 = "Sykepleier",
  junior                = "Turnuslege",
  doctor                = "Doktor",
  surgeon               = "Kirurg",
  psychiatrist          = "Psykolog",
  consultant            = "Konsulent",
  researcher            = "Forsker",
}


-- OBJECTS
-- override
object = {
  desk                  = "Kontorpult",
  cabinet               = "Arkivskap",
  door                  = utf8 "Dör",
  bench                 = "Benk",
  table1                = "Bord", -- unused object
  chair                 = "Stol",
  drinks_machine        = "Brusautomat",
  bed                   = "Seng",
  inflator              = "Pumpe",
  pool_table            = "Biljardbord",
  reception_desk        = "Resepsjon",
  table2                = "Bord", -- unused object & duplicate
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
  lamp                  = "Lampe", -- unused object
  toilet_sink           = "Vask",
  op_sink1              = "Vask",
  op_sink2              = "Vask",
  surgeon_screen        = "Forheng",
  lecture_chair         = "Forelesningsstol",
  projector             = "Prosjektor",
  bed2                  = "Seng", -- unused duplicate
  pharmacy_cabinet      = "Medisinskap",
  computer              = "Datamaskin",
  atom_analyser         = "Atomanalyser",
  blood_machine         = "Blodmaskin",
  fire_extinguisher     = "Brannslukningsapp.",
  radiator              = "Ovn",
  plant                 = "Plante",
  electrolyser          = "Elektrolyser",
  jelly_moulder         = utf8 "Gelétönne",
  gates_of_hell         = "Helvetesporten",
  bed3                  = "Seng", -- unused duplicate
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

-- STAFF COMPLAINTS
pay_rise = {
  definite_quit = utf8 "Du kan ikke gjöre noe for å beholde meg lenger. Jeg er ferdig her!",
  regular = {
    utf8 "Jeg er helt utslitt. Jeg trenger en god pause, pluss en lnnsökning på %d om du ikke vil se meg gå rundt å sutre i korridorene.", -- %d (rise)
    utf8 "Jeg er veldig trett. Jeg trenger hvile og en lönnskning på %d, totalt %d. Fiks det nå, din tyrann!", -- %d (rise) %d (new total)
    utf8 "Kom igjen. Jeg jobber som en hund her. Gi meg en bonus på %d og jeg blir på sykehuset ditt.", -- %d (rise)
    utf8 "Jeg er så deppa. Jeg krever en lönnskning på %d, som blir totalt %d, ellers er jeg ferdig her.", -- %d (rise) %d (new total)
    utf8 "Foreldrene mine sa at medisinyrket ville gi meg mye penger. Så gi meg en lönnskning på %d, ellers blir jeg spillutvikler istedenfor.", -- %d (rise)
    utf8 "Nå er jeg sint. Gi meg en anstendig lönn. Jeg tror en ökning på %d skal gjöre susen.", -- %d (rise)
  },
  poached = utf8 "Jeg er blitt tilbudt %d av %s. Om ikke du gir meg det samme, så stikker jeg.", -- %d (new total) %s (competitor)
}

place_objects_window = {
  drag_blueprint                = utf8 "Juster blåkopien til du er fornöyd med störrelsen",
  place_door                    = utf8 "Velg hvor dören skal være",
  place_windows                 = utf8 "Lag noen vinduer om du vil. Bekreft når du er ferdig",
  place_objects                 = utf8 "Plasser objektene. Bekreft når du er fornöyd",
  confirm_or_buy_objects        = utf8 "Du kan ferdigstille rommet, evt. fortsette å kjöpe eller flytte objekter",
  pick_up_object                = utf8 "Klikk på objekter for å plukke de opp, eller gjör et annet valg fra boksen",
  place_objects_in_corridor     = "Plasser objektene i korridoren",
}

-- Category of strings that fit nowhere else or we are not sure where they belong.
-- If you think a string of these fits somewhere else, please move it there.
-- Don't forget to change all references in the code and other language files.
misc = {
  grade_adverb = {
    mildly     = "mild",
    moderately = "moderat",
    extremely  = "ekstrem",
  },
  done  = "Ferdig",
  pause = "Pause",
  
  send_message     = "Send beskjed til spiller %d", -- %d (player number)
  send_message_all = "Send beskjed til alle spillere",
  
  save_success = "Spill lagret",
  save_failed  = "FEIL: Kunne ikke lagre spill",
  
  hospital_open = utf8 "Sykehus åpent",
  out_of_sync   = utf8 "Spillet ute av synk",
  
  load_failed  = "Kunne ikke laste tidligere spill",
  low_res      = "Lav oppl.",
  balance      = "Balansefil:",
  
  mouse        = "Mus",
  force        = "Styrke",
}

competitor_names = {
  "ORAC",
  "HAL",
  "COLOSSUS",
  "MULTIVAC",
  "HOLLY",
  "DEEP THOUGHT",
  "ZEN",
  "LEON",
  "AKIRA",
  "SAM",
  "CHARLIE",
  "JAYNE",
  "ARTHUR",
  "MAGNUS",
  "MOTHER",
  "SAL",
  "MARVIN",
  "JOSHUA",
  "DANEEL",
  "OLIVAW",
  "NIC",
}
-- MONTHS
-- override
months = {
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "Mai",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Okt",
  "Nov",
  "Des",
}
-- S[7][ 1], -- not needed?
-- S[7][ 2], -- unused(?)
-- S[7][ 3], -- unused(?)

graphs = {
  money_in   = "Inntekter",
  money_out  = "Utgifter",
  wages      = utf8 "Lönninger",
  balance    = "Balanse",
  visitors   = utf8 "Besökende",
  cures      = "Kurerte",
  deaths     = utf8 "Dödsfall",
  reputation = utf8 "Omdömme",
  
  time_spans = {
    utf8 "1 år",
    utf8 "12 år",
    utf8 "48 år",
  }
}
-- TRANSACTIONS
-- override
transactions = {
  --null               = S[8][ 1], -- not needed
  wages                = utf8 "Lönninger",
  hire_staff           = "Ansett personale",
  buy_object           = utf8 "Kjöp inv.",
  build_room           = "Bygg rom",
  cure                 = "Kur",
  buy_land             = utf8 "Kjöp område",
  treat_colon          = "Behandling:",
  final_treat_colon    = "Siste behandling:",
  cure_colon           = "Kurert:",
  deposit              = "Behandlingsinnskudd",
  advance_colon        = "Forskudd:",
  research             = "Forskningskostnader",
  drinks               = "Inntekt: Brusautomater",
  jukebox              = "Inntekt: Jukebox", -- unused
  cheat                = "Monopolpenger",
  heating              = "Oppvarmingskostnader",
  insurance_colon      = "Forsikring:",
  bank_loan            = utf8 "Banklån",
  loan_repayment       = "Bankinnskudd",
  loan_interest        = utf8 "Lånerente",
  research_bonus       = "Forskningsbonus",
  drug_cost            = "Medisinkostnader",
  overdraft            = "Strafferente",
  severance            = "Oppsigelseskostnader",
  general_bonus        = "Bonus Generell",
  sell_object          = "Salg inventar",
  personal_bonus       = "Bonusutbetaling Personale",
  emergency_bonus      = utf8 "Bonusutbetaling Nödstilfeller",
  vaccination          = "Vaksinering",
  epidemy_coverup_fine = utf8 "Opprydningskostnader epidemiutbrudd",
  compensation         = "Statlig erstatning",
  vip_award            = "Pengepremier VIP",
  epidemy_fine         = utf8 "Epidemiböter",
  eoy_bonus_penalty    = utf8 "Årsbonus/böter",
  eoy_trophy_bonus     = utf8 "Årets trofé bonus",
  machine_replacement  = "Utskiftning av maskiner",
}
--...

level_names = {
  -- S[12][ 1] -- unused
  "ToxiCity",
  "Sleepy Hollow",
  "Largechester",
  "Frimpton-on-Sea",
  "Simpleton",
  "Festering-on-the-Wold",
  "Greenpool",
  "Manquay",
  "Eastville",
  "Eggsenham",
  "Croaking",
  "Battenburg",
  "Chumleigh",
  "Little Drubbing",
  "Bury Bury",
}

town_map = {
  -- S[13][ 1] -- unused
  chat         = "Town Detail Chat",
  for_sale     = "Til salgs",
  not_for_sale = "Ikke til salgs",
  number       = "Tomt nummer", 
  owner        = "Tomt eier",
  area         = utf8 "Tomt område",
  price        = "Tomt pris",
}

-- NB: includes some special "rooms"
-- reception, destroyed room and "corridor objects"
rooms_short = {
  -- S[14][1] -- unused
  -- S[14][3] -- unused
  reception         = "Resepsjon",
  destroyed         = utf8 "Ödelagt",
  corridor_objects  = "Korridor objekter",
  
  gps_office        = "Allmennpraksis",
  psychiatric       = "Psykiatri",
  ward              = "Sengeavdeling",
  operating_theatre = "Operasjonssal",
  pharmacy          = "Apotek",
  cardiogram        = "Kardio",
  scanner           = "Skanner",
  ultrascan         = "Ultraskanner",
  blood_machine     = "Blodmaskin",
  x_ray             = utf8 "Röntgen",
  inflation         = "Pumperom",
  dna_fixer         = "DNA-klinikk",
  hair_restoration  = utf8 "Hårklinikk",
  tongue_clinic     = "Tungeklinikk",
  fracture_clinic   = "Benbruddsklinikk",
  training_room     = "Klasserom",
  electrolysis      = "Elektrolyseklinikk",
  jelly_vat         = utf8 "Gelétönne",
  staffroom         = "Personalrom",
  -- rehabilitation = "Rehabilitering", -- unused
  general_diag      = "Generell diagnose",
  research_room     = "Forskningsavd.",
  toilets           = "Toalett",
  decontamination   = "Saneringsklinikk",
}

rooms_long = {
  -- S[53][1] -- unused
  general           = "Generell", -- unused?
  emergency         = utf8 "Nödstilfelle",
  corridors         = "Korridorer",
  
  gps_office        = "Allmennpraksis",
  psychiatric       = "Psykiatri",
  ward              = "Sengeavdeling",
  operating_theatre = "Operasjonssal",
  pharmacy          = "Apotek",
  cardiogram        = "Kardiorom",
  scanner           = "Skannerrom",
  ultrascan         = "Ultraskanner",
  blood_machine     = "Blodmaskinrom",
  x_ray             = utf8 "Röntgenrom",
  inflation         = "Pumperom",
  dna_fixer         = "DNA-klinikk",
  hair_restoration  = utf8 "Hårklinikk",
  tongue_clinic     = "Tungeklinikk",
  fracture_clinic   = "Benbruddsklinikk",
  training_room     = "Klasserom",
  electrolysis      = "Elektrolyseklinikk",
  jelly_vat         = utf8 "Gelétönnerom",
  staffroom         = "Personalrom",
  -- rehabilitation = "Rehabiliteringsrom", -- unused
  general_diag      = "Generell diagnose",
  research_room     = "Forskningsavd.",
  toilets           = "Toalett",
  decontamination   = "Saneringsklinikk",
}

-- TODO where is this used?
drug_companies = {
  -- S[15][1], -- unused
  "Medisiner-For-Deg",
  "Kur R Oss",
  "Runde Små Piller Co.",
  "Dyremedisin AS",
  "Alle Piller Co.",
}

build_room_window = {
  -- S[16][1], -- unused
  pick_department   = "Velg avdeling",
  pick_room_type    = "Velg romtype",
  cost              = "Pris:",
}

buy_objects_window = {
  choose_items      = "Velg objekter",
  price             = "Pris:",
  total             = "Sum:",
}

research = {
  categories = {
    cure            = "Behandlingsutstyr",
    diagnosis       = "Diagnoseutstyr",
    drugs           = "Medisinforskning",
    improvements    = "Forbedringer",
    specialisation  = "Spesialisering",
  },
  
  funds_allocation  = "Tildelt fondmiddel",
  allocated_amount  = utf8 "Tildelt belöp",
}

policy = {
  header            = "SYKEHUS POLICY",
  diag_procedure    = "diagnoserutiner",
  diag_termination  = "diagnosering",
  staff_rest        = utf8 "pauserutiner",
  staff_leave_rooms = "personale forlater rom",
  
  sliders = {
    guess           = "GJETT KUR", -- belongs to diag_procedure
    send_home       = "SEND HJEM", -- also belongs to diag_procedure
    stop            = "AVBRYT PROSESS", -- belongs to diag_termination
    staff_room      = utf8 "TIL PERSONALROM", -- belongs to staff_rest
  }
}

room_classes = {
  -- S[19][1] -- unused
  -- S[19][2] -- "corridors" - unused for now
  -- S[19][3] -- unused
  diagnosis  = "Diagnose",
  treatment  = "Behandling",
  clinics    = "Klinikker",
  facilities = "Fasiliteter",
}

-- INSURANCE COMPANIES
-- These are better of in a list with numbers
insurance_companies = {
  out_of_business   = "IKKE I DRIFT",
  utf8 "Nykjöpt Lök",
  utf8 "Böljan Blå",
  utf8 "Årlige Forskudd AS",
  "Stygge Arr Co.",
  utf8 "Svömmeblære Co.",
  utf8 "Dönn Ærlig AS",
  "Sverres Beholdninger",
  "Kate Pus Og Kompani",
  utf8 "Larsen Jr. Forsikring",
  "Glade Forsikringer AS",
  "Mafia Forsikringer",
}

-- MENU STRINGS
-- override
menu = {
  file                	= "  FIL  ",
  options             	= "  INNSTILLINGER  ",
  display             	= "  VIS  ",
  charts              	= "  LISTER  ",
  debug               	= "  DEBUG  ",
}

menu_file = {
  load                	= "  LAST INN  ",
  save                	= "  LAGRE  ",
  restart             	= utf8 "  START PÅ NYTT  ",
  quit                	= "  AVSLUTT  ",
}

menu_options = {
  sound               = "  LYD  ",
  announcements       = "  SPEAKER  ",
  music               = "  MUSIKK  ",
  sound_vol           = "  LYDVOLUM  ",
  announcements_vol   = "  SPEAKERVOLUM  ",
  music_vol           = "  MUSIKKVOLUM  ",
  autosave            = "  AUTOLAGRING  ",
  game_speed          = "  SPILLHASTIGHET  ",
  jukebox             = "  JUKEBOX  ",
}

menu_options_game_speed = {
  slowest             = "  TREGEST  ",
  slower              = "  TREGERE  ",
  normal              = "  NORMAL  ",
  max_speed           = "  MAKSIMAL HASTIGHET  ",
  and_then_some_more  = "  OG LITT RASKERE  ",
}

menu_display = {
  high_res            = utf8 "  HÖY OPPLÖSNING  ",
  mcga_lo_res         = "  MCGA LAV OPPL.  ",
  shadows             = "  SKYGGER  ",
}

menu_charts = {
  statement           = "  KONTOUTSKRIFT  ",
  casebook            = "  MEDISINBOK  ",
  policy              = "  SYKEHUSPOLICY  ",
  research            = "  FORSKNING  ",
  graphs              = "  DIAGRAMMER  ",
  staff_listing       = "  PERSONALBEHANDLING  ",
  bank_manager        = "  BANKMANAGER  ",
  status              = "  STATUS  ",
  briefing            = "  BRIEFING  ",
}

menu_debug = {
  object_cells        = "  OBJEKTCELLER        ",
  entry_cells         = "  INNGANGSCELLER      ",
  keep_clear_cells    = "  KEEP CLEAR CELLS    ",
  nav_bits            = "  NAV BITS            ",
  remove_walls        = "  FJERN VEGGER        ",
  remove_objects      = "  FJERN OBJEKTER      ",
  display_pager       = "  VIS PAGER           ",
  mapwho_checking     = "  MAPWHO SJEKK        ",
  plant_pagers        = "  PLANT PAGERS        ",
  porter_pagers       = "  PORTER PAGERS       ",
  pixbuf_cells        = "  PIXBUE CELLS        ",
  enter_nav_debug     = "  ENTER NAV DEBUG     ",
  show_nav_cells      = "  SHOW NAV CELLS      ",
  machine_pagers      = "  MASKIN PAGERS       ",
  display_room_status = "  VIS ROMSTATUS       ",
  display_big_cells   = "  VIS STORE CELLER    ",
  show_help_hotspot   = "  VIS HJELP HOTSPOTS  ",
  win_game_anim       = "  WIN GAME ANIM       ",
  win_level_anim      = "  WIN LEVEL ANIM      ",
  lose_game_anim = {
    [1]  = "  TAPT SPILL 1 ANIM  ",
    [2]  = "  TAPT SPILL 2 ANIM  ",
    [3]  = "  TAPT SPILL 3 ANIM  ",
    [4]  = "  TAPT SPILL 4 ANIM  ",
    [5]  = "  TAPT SPILL 5 ANIM  ",
    [6]  = "  TAPT SPILL 6 ANIM  ",
    [7]  = "  TAPT SPILL 7 ANIM  ",
  },
}

-- ...
staff_list = {
  -- S[24][1] unused
  -- S[24][2] -- I have no idea what this is.
  morale       = "MORAL",
  tiredness    = utf8 "TRÖTTHET",
  skill        = "FERDIGHETER",
  total_wages  = utf8 "TOTAL LÖNN",
}

high_score = {
  -- S[25][1] unused
  pos          = "POS",
  player       = "SPILLER",
  score        = "POENG",
  best_scores  = "HALL OF FAME",
  worst_scores = "HALL OF SHAME",
  killed       = "Drepte", -- is this used?
  
  categories = {
    money             = "RIKEST",
    salary            = "HÖYESTE LÖNN",
    clean             = "RENSLIGHET",
    cures             = "ANTALL KURERT",
    deaths            = "ANTALL DÖDSFALL",
    cure_death_ratio  = "ANTALL BEHANDLINGSDÖDSFALL",
    patient_happiness = "TILFREDSTILLHET PASIENTER",
    staff_happiness   = "TILFREDSTILLHET PERSONALE",
    staff_number      = "MEST PERSONALE",
    visitors          = "FLEST PASIENTER",
    total_value       = "TOTAL VERDI",
  },
}

trophy_room = {
  -- S[27][1] unused
  many_cured = {
    awards = {
      utf8 "Gratulerer med Marie Curie Prisen for å ha klart å kurere nesten alle pasientene på sykehuset ditt i fjor.",
    },
    trophies = {
      utf8 "Den Internasjonale Behandlingsstiftelsen önsker å ære deg fordi du kurerte en haug med mennesker på sykehuset ditt i fjor. De gir deg derfor Kurert-En-Haug Trofeet.",
      utf8 "Du er blitt tildelt Ingen-Syke-Gurglere Trofeet for å ha kurert en stor prosent av pasientene på sykehuset ditt i fjor.",
    },
  },
  all_cured = {
    awards = {
      utf8 "Gratulerer med Marie Curie Prisen for å ha klart å kurere alle pasienter på sykehuset ditt i fjor.",
    },
    trophies = {
      utf8 "Den Internasjonale Behandlingsstiftelsen önsker å ære deg fordi du kurerte alle pasienter på sykehuset ditt i fjor. De gir deg derfor Kurert-Alle Trofeet.",
      utf8 "Du er blitt tildelt Ingen-Syke-Gurglere Trofeet for å ha kurert alle pasienter på sykehuset ditt i fjor.",
    },
  },
  high_rep = {
    awards = {
      utf8 "Du er herved tildelt statsministerens Glitrende Sykehusstandard Pris, som tildeles sykehuset med best omdömme i fjor. Flott!",
      utf8 "Vær snill å ta imot Bullfrog-prisen som tildeles sykehuset med best omdömme i fjor. Nyt det - det er vel fortjent!",
    },
    trophies = {
      utf8 "Gratulerer med Rent-Og-Pent Trofeet som tildeles sykehuset med best omdömme i fjor. Vel, det er faktisk fortjent.",
    },
  },
  happy_staff = {
    awards = {
    },
    trophies = {
      utf8 "Du er tildelt Smilefjes Trofeet for å holde ditt hardt-arbeidende personale så blid og fornöyd som mulig.",
      utf8 "Instituttet for Humörspredere berömmer deg for at du ikke hadde noen sure og sinte ansatte på sykehuset ditt i fjor, og gir deg derfor dette trofeet.",
      utf8 "Dette trofeet, Stråle Mer Begeret, er herved tildelt deg for å ha klart å holde alt personell blid og fornöyd, tross en iherdig arbeidsinnsats i fjor. Dine ansatte stråler!",
    },
  },
  happy_vips = {
    awards = {
      utf8 "Du har vunnet Nobelprisen for Imponerte VIP'er. Alle som besökte sykehuset ditt i fjor snakker ikke om annet.",
      utf8 "Gratulerer med VIP-prisen for å ha gjort livene til hardtarbeidende kjendiser bedre, ved å sette alle som besökte sykehuset ditt i fjor i et bedre lys. Fantastisk.",
    },
    trophies = {
      utf8 "Byrået for Kjente Personer vil belönne deg med Kjendistrofeet for å ha tatt godt vare på alle VIP'er som besökte instutisjonen din i fjor. Du nærmer deg kjendis-status, nesten en av oss.",
    },
  },
  no_deaths = {
    awards = {
      utf8 "Du har vunnet Leve Lenge Trofeet for å holde 100 prosent av pasientene levende i hele fjor.",
    },
    trophies = {
      utf8 "Livet Går Videre Stiftelsen belönner deg med dette trofeet for å ha oppnådd null dödsfall i hele fjor.",
      utf8 "Du er tildelt Holde Seg I Live Trofeet for å ha unngått dödsfall på ditt flotte sykehus dette året. Storartet.",
    },
  },
  rats_killed = {
    awards = {
    },
    trophies = {
      utf8 "Du er tildelt Null Uhyrer Trofeet for å ha skutt %d rotter på sykehuset ditt i löpet av fjoråret.", -- %d (number of rats)
      utf8 "Du mottar dette trofeet fra Organisasjonen Mot Rotter og Mus, pga. dine unike rotteskytende evner. Du drepte %d dyr i fjor.", -- %d (number of rats)
      utf8 "Du mottar Rotteskytter Trofeet for å ha vist unike evner i utryddelsen av %d rotter på sykehuset ditt i fjor.", -- %d (number of rats)
    },
  },
  rats_accuracy = {
    awards = {
    },
    trophies = {
      utf8 "Du er tildelt Nöyaktige Skudd I Håplös Krig Trofeet for å ha en treffprosent på %d%% i jakten på ekle rotter.", -- %d (accuracy percentage)
      utf8 "Dette trofeet er for å berömme din nöyaktighet ved å drepe %d%% av rottene du sköyt på i fjor.", -- %d (accuracy percentage)
      "For å hedre prestasjonen det er å drepe %d%% av alle rottene på sykehuset ditt, blir du tildelt Dungeon Keepers Skadedyrfrie Trofe, gRATulerer!", -- %d (accuracy percentage)
    },
  },
  healthy_plants = {
    awards = {
      utf8 "Gratulerer med Voks-Videre prisen for å ha holdt plantene dine ekstremt friske i hele år.",
    },
    trophies = {
      utf8 "Venner Av Potteplanter önsker å gi deg Grönn Helse Trofeet, for å ha tatt godt vare på plantene dine de siste tolv måneder.",
      utf8 "Foreningen For Grönne Gamlinger önsker å gi deg Grönnfinger Trofeet for å ha holdt plantene dine friske i hele fjor.",
    },
  },
  sold_drinks = {
    awards = {
    },
    trophies = {
      utf8 "Foreningen for Globale Tannleger er stolt over å kunne gi deg dette trofeet for å ha solgt store menger brus på sykehuset ditt i fjor.",
      utf8 "Sykehuset ditt er blitt tildelt Sprudlende-Begjær Trofeet for antall læskedrikker som ble solgt på sykehuset ditt i fjor.",
      utf8 "På vegne av DK Fyllinger Co., tildeles du herved dette trofeet dekket av sjokolade, for å ha solgt enorme mengder læskedrikker på sykehuset ditt forrige år.",
    },
  },
}

casebook = {
  reputation           = utf8 "omdömme",
  treatment_charge     = "behandlingspris",
  earned_money         = "totale inntekter",
  cured                = "behandlet",
  deaths               = utf8 "dödsfall",
  sent_home            = "sendt hjem",
  research             = "konsentrer forskning",
  cure                 = "kur",
  cure_desc = {
    build_room         = utf8 "Jeg anbefaler deg å bygge %s", -- %s (room name)
    build_ward         = "Du trenger fremdeles en Sengeavdeling.",
    hire_doctors       = utf8 "Du må ansette noen leger.",
    hire_surgeons      = utf8 "Du må ansette kirurger.",
    hire_psychiatrists = utf8 "Du må ansette psykologer.",
    hire_nurses        = utf8 "Du må ansette sykepleiere.",
    no_cure_known      = "Ingen kjente kurer.",
    cure_known         = "Kur.",
    improve_cure       = "Forbedre kur",
  },
}

-- TOOLTIPS
tooltip = {
  -- S[32][1] unused
  build_room_window = {
    room_classes = {
      diagnosis        = "Velg diagnoserom",
      treatment        = "Velg generelle behandlingsrom",
      clinic           = "Velg spesielle klinikker",
      facilities       = "Velg fasiliteter",
    },
    cost               = "Kostnad for gjeldende rom",
    close              = "Avbryt prosessen og returner til spillet",
  },
  
  toolbar = {
    bank_button        = utf8 "Venstreklikk for Bankmanager, höyreklikk for Kontoutskrift",
    balance            = "Din Balanse",
    reputation         = "Ditt rykte (omdömme)",
    date               = "Dato",
    rooms              = "Bygg rom",
    objects            = utf8 "Kjöp gjenstander",
    edit               = "Endre rom/gjenstander",
    hire               = "Ansett personale",
    staff_list         = "Personalbehandling",
    town_map           = utf8 "Områdekart",
    casebook           = "Medisinbok",
    research           = "Forskning",
    status             = "Status",
    charts             = "Diagrammer",
    policy             = "Sykehuspolicy",
  },
  
  hire_staff_window = {
    doctors            = utf8 "Vis Leger tilgjengelig på arbeidsmarkedet",
    nurses             = utf8 "Vis Sykepleiere tilgjengelig på arbeidsmarkedet",
    handymen           = utf8 "Vis Vaktmestere tilgjengelig på arbeidsmarkedet",
    receptionist       = utf8 "Vis Resepsjonister tilgjengelig på arbeidsmarkedet",
    prev_person        = "Vis forrige person",
    next_person        = "Vis neste person",
    hire               = "Ansett person",
    cancel             = "Avbryt",
    doctor_seniority   = "Legens erfaring (Turnuslege, Doktor, Konsulent)",
    staff_ability      = "Evner",
    salary             = utf8 "Lönnskrav",
    qualifications     = "Legens spesialisering",
    surgeon            = "Kirurg",
    psychiatrist       = "Psykolog",
    researcher         = "Forsker",
  },
  
  buy_objects_window = {
    price              = utf8 "Pris på gjenstand",
    total_value        = utf8 "Total verdi på kjöpte gjenstander",
    confirm            = utf8 "Kjöp gjenstand(er)",
    cancel             = "Avbryt",
    increase           = utf8 "Kjöp en til av denne gjenstanden",
    decrease           = utf8 "Kjöp en mindre av denne gjenstanden",
  },
  
  staff_list = {
    doctors            = "Se en oversikt over dine leger",
    nurses             = "Se en oversikt over dine sykepleiere",
    handymen           = "Se en oversikt over dine vaktmestere",
    receptionists      = "Se en oversikt over dine resepsjonister",
    
    happiness          = utf8 "Viser hvordan humöret på dine ansatte er",
    tiredness          = utf8 "Viser hvor trött dine ansatte er",
    ability            = "Viser evnene til dine ansatte",
    salary             = utf8 "Den enkeltes gjeldende lönn",
    
    happiness_2        = "Den ansattes moral",
    tiredness_2        = utf8 "Den ansattes trötthetsnivå",
    ability_2          = "Den ansattes evner",
    
    prev_person        = "Velg forrige person i listen",
    next_person        = "Velg neste person i listen",
    
    bonus              = "Gi denne ansatte 10% bonus",
    sack               = "Si opp denne ansatte",
    pay_rise           = utf8 "Hev lönnen til denne ansatte med 10%",
    
    close              = "Lukk og returner til spillet",
    
    doctor_seniority   = "Legens erfaring",
    detail             = utf8 "Oppmerksom på detaljer",
    
    view_staff         = utf8 "Vis ansatt på jobb",
    
    surgeon            = "Kvalifisert Kirurg",
    psychiatrist       = "Kvalifisert Psykolog",
    researcher         = "Kvalifisert Forsker",
    surgeon_train      = "%d%% ferdig med fordypning innen kirurgi", -- %d (percentage trained)
    psychiatrist_train = "%d%% ferdig med fordypning innen psykologi", -- %d (percentage trained)
    researcher_train   = "%d%% ferdig med fordypning innen forskning", -- %d (percentage trained)
    
    skills             = "Ekstra evner",
  },
  
  queue_window = {
    num_in_queue       = utf8 "Antall pasienter i köen",
    num_expected       = utf8 "Antall pasienter resepsjonisten forventer i köen innen kort tid",
    num_entered        = utf8 "Antall pasienter som er behandlet i dette rommet så langt",
    max_queue_size     = utf8 "Maksimal lengde på köen som resepsjonisten skal etterstrebe",
    dec_queue_size     = utf8 "Senk maksimal kölengde",
    inc_queue_size     = utf8 "Ök maksimal kölengde",
    front_of_queue     = utf8 "Dra en pasient hit for å stille han/henne fremst i köen",
    end_of_queue       = utf8 "Dra en pasient hit for å stille han/henne bakerst i köen",
    close              = "Lukk vindu",
    patient            = utf8 "Dra en pasient for å flytte han/henne i köen. Höyreklikk på en pasient for å sende han/henne hjem eller til et konkurrerende sykehus",
    patient_dropdown = {
      reception        = "Henvis pasient til resepsjonist",
      send_home        = "Send pasienten hjem",
      hospital_1       = "Henvis pasienten til et annet sykehus",
      hospital_2       = "Henvis pasienten til et annet sykehus",
      hospital_3       = "Henvis pasienten til et annet sykehus",
    },
  },
  
  main_menu = {
    new_game           = "Start et nytt spill",
    load_game          = "Last inn et tidligere spill",
    continue           = "Fortsett forrige spill",
    network            = "Start nettverksspill",
    quit               = "Avslutt",
    load_menu = {
      load_slot        = S[41][  1], -- NB: no %d! Append " [slotnumber]".
      empty_slot       = S[41][  2],
    },
  },
  
  window_general = {
    cancel             = "Avbryt",
    confirm            = "Bekreft",
    close_window       = "Lukk vindu",
  },
  
  patient_window = {
    graph              = utf8 "Klikk for å veksle mellom graf med personens helse og personens behandlingshistorikk",
    happiness          = utf8 "Personens humör",
    thirst             = utf8 "Personens törste",
    warmth             = "Personens temperatur",
    casebook           = "Vis detaljer for pasientens sykdom",
    send_home          = "Send pasienten hjem fra sykehuset",
    center_view        = utf8 "Sentrer personen i skjermbildet",
    abort_diagnosis    = utf8 "Send personen til behandling istedenfor å vente til diagnosen er ferdigstilt",
    queue              = utf8 "Se köen pasienten befinner seg i",
  },
  
  staff_window = {
    name               = "Den ansattes navn",
    close              = "Lukk vindu",
    face               = "Denne personens ansikt",
    happiness          = utf8 "Humörnivå",
    tiredness          = utf8 "Tretthetsnivå",
    ability            = "Evner",
    doctor_seniority   = "Stilling (Turnuslege, Doktor, Konsulent)",
    skills             = "Spesialisering",
    surgeon            = "Kirurg",
    psychiatrist       = "Psykolog",
    researcher         = "Forsker",
    salary             = utf8 "Månedslönn",
    center_view        = "Sentrer i skjermbildet",
    sack               = "Si opp",
    pick_up            = "Plukk opp",
  },
  
  machine_window = {
    name               = "Navn",
    close              = "Lukk vindu",
    times_used         = "Antall gangen maskinen er brukt",
    status             = "Maskinstatus",
    repair             = utf8 "Kall på vaktmester for å fikse maskinen",
    replace            = "Erstatt maskin",
  },
  
  -- Spparently handymen have their own set of strings (partly) containing "handyman".
  -- We could just get rid of this category and include the three prios into staff_window.
  handyman_window = {
    name               = "Vaktmesterens navn", -- contains "handyman"
    close              = "Lukk vindu",
    face               = "Vaktmesterens ansikt", -- contains "handyman"
    happiness          = utf8 "Humörnivå",
    tiredness          = utf8 "Tretthetsnivå",
    ability            = "Evner",
    prio_litter        = utf8 "Be vaktmesteren om å prioritere rengjöring av gulv höyere", -- contains "handyman"
    prio_plants        = utf8 "Be vaktmesteren om å prioritere vanning av planter höyere", -- contains "handyman"
    prio_machines      = utf8 "Be vaktmesteren om å prioritere reperasjon av maskiner höyere", -- contains "handyman"
    salary             = utf8 "Månedslönn",
    center_view        = "Sentrer i skjermbildet", -- contains "handyman"
    sack               = "Si opp",
    pick_up            = "Plukk opp",
  },
  
  place_objects_window = {
    cancel             = "Avbryt",
    buy_sell           = "Kjöp/Selg gjenstander",
    pick_up            = "Plukk opp en gjenstand",
    confirm            = "Bekreft",
  },
  
  casebook = {
    up                 = "Rull oppover",
    down               = "Rull nedover",
    close              = "Lukk medisinbok",
    reputation         = utf8 "Ryktet behandlingen eller diagnosen har i nærområdet",
    treatment_charge   = "Pris for behandling",
    earned_money       = "Totalt opptjente penger frem til i dag",
    cured              = "Antall kurerte pasienter",
    deaths             = utf8 "Antall pasienter drept som fölge av behandlingen",
    sent_home          = utf8 "Antall pasienter som har snudd og gått hjem",
    decrease           = "Senk pris",
    increase           = utf8 "Ök pris",
    research           = utf8 "Trykk her for å bruke forskingsbudsjettet for spesialisering til å forske på denne behandlingen",
    cure_type = {
      drug             = "Denne behandlingen krever medisin",
      drug_percentage  = "Denne behandlingen krever medisin - din er %d%% effektiv", -- %d (effectiveness percentage)
      psychiatrist     = "En psykolog kreves for behandling",
      operation        = "Denne sykdommen krever en operasjon",
      machine          = "Denne sykdommen krever en maskin for behandling",
    },
    cure_requirement = {
      possible         = utf8 "Du kan gjennomföre behandling",
      research_machine = utf8 "Du må forske på maskiner for å gjennomföre behandlingen",
      build_room       = utf8 "Du må bygge et rom for å gjennomföre behandlingen", -- NB: no %s!
      hire_surgeons    = utf8 "Du trenger to Kirurger for å gjennomföre behandlingen",
      hire_surgeon     = utf8 "Du trenger en Kirurg til for å gjennomföre behandlingen",
      hire_staff       = utf8 "Du må ansette en %s for å gjennomföre behandlingen", -- %s (staff type)
      build_ward       = utf8 "Du må bygge en Sengeavdeling for å kunne gjennomföre behandlingen",
      ward_hire_nurse  = utf8 "Du trenger en Sykepleier på Sengeavdelingen for å gjennomföre behandlingen",
      not_possible     = utf8 "Du kan ikke håndtere denne behandlingen enda",
    },
  },
  
  statement = {
    close              = "Lukk kontoutskriften",
  },
  
  research = {
    close              = utf8 "Gå ut av forskningsavdelingen",
    cure_dec           = "Senk prioritering av forskning på behandlingsutstyr",
    diagnosis_dec      = "Senk prioritering av forskning på diagnoseutstyr",
    drugs_dec          = "Senk prioritering av forskning på medisiner",
    improvements_dec   = "Senk prioritering av forskning på forbedringer",
    specialisation_dec = "Senk prioritering av forskning på spesialiseringer",
    cure_inc           = utf8 "Ök prioritering av forskning på behandlingsutstyr",
    diagnosis_inc      = utf8 "Ök prioritering av forskning på diagnoseutstyr",
    drugs_inc          = utf8 "Ök prioritering av forskning på medisiner",
    improvements_inc   = utf8 "Ök prioritering av forskning på forbedringer",
    specialisation_inc = utf8 "Ök prioritering av forskning på spesialiseringer",

    -- S[32][174] unused
    allocated_amount   = "Penger satt av til forskning",
  },
  
  graphs = {
    close              = utf8 "Gå ut av diagramvinduet",
    scale              = utf8 "Skala på diagram",
    money_in           = "Vis/skjul Inntekter",
    money_out          = "Vis/skjul Utgifter",
    wages              = utf8 "Vis/skjul Lönninger",
    balance            = "Vis/skjul Balanse",
    visitors           = utf8 "Vis/skjul Besökende",
    cures              = "Vis/skjul Kurerte",
    deaths             = utf8 "Vis/skjul Dödsfall",
    reputation         = utf8 "Vis/skjul Omdömme",
  },
  
  -- S[32][186] through S[32][190] inserted further above
  
  town_map = {
    people             = "Vis/Skjul mennesker",
    plants             = "Vis/Skjul planter",
    fire_extinguishers = "Vis/Skjul brannslukningsapparat",
    objects            = "Vis/Skjul gjenstander",
    radiators          = "Vis/Skjul ovner",
    heat_level         = "Temperatur",
    heat_inc           = "Skru opp temperaturen",
    heat_dec           = "Skru ned temperaturen",
    heating_bill       = "Varmekostnader",
    balance            = "Balanse",
    close              = utf8 "Lukk områdekart",
  },
  
  -- S[32][202] unused.
  jukebox = {
    current_title      = "Jukebox",
    close              = "Lukk jukebox",
    play               = "Spill jukebox",
    rewind             = "Spol tilbake jukebox",
    fast_forward       = "Spol fremover jukebox",
    stop               = "Stopp jukebox",
    loop               = "Repeter jukebox",
  },
  
  bank_manager = {
    hospital_value     = utf8 "Nåværende verdi på sykehuset ditt",
    balance            = "Din balanse i banken",
    current_loan       = utf8 "Gjeldende lån i banken",
    repay_5000         = "Betal tilbake 5000 til banken",
    borrow_5000        = utf8 "Lån 5000 av banken",
    interest_payment   = utf8 "Månedlige rentekostnader",
    inflation_rate     = utf8 "Årlig inflasjon",
    interest_rate      = utf8 "Årlig rente",
    close              = "Lukk bankmanageren",
    insurance_owed     = "Penger %s skylder deg", -- %s (name of debitor)
    show_graph         = "Vis forventet tilbakebetalingsplan fra %s", -- %s (name of debitor)
    graph              = "Forventet tilbakebetalingsplan fra %s", -- %s (name of debitor)
    graph_return       = "Returner til forrige visning",
  },
  
  status = {
    win_progress_own   = utf8 "Vis progresjon i forhold til kravene for dette nivået",
    win_progress_other = utf8 "Vis progresjon i forhold til kravene for dette nivået for %s", -- %s (name of competitor)
    population_chart   = "Figur som viser hvor stor andel av lokalbefolkningen hvert sykehus tiltrekker seg",
    happiness          = utf8 "Gjennomsnittlig humör på personene på ditt sykehus",
    thirst             = utf8 "Gjennomsnittlig törste på personene på ditt sykehus",
    warmth             = "Gjennomsnittlig temperatur på personene på ditt sykehus",
    close              = "Lukk oversikten",
  },
  
  policy = {
    close              = "Lukk sykehuspolicy",
    staff_leave        = utf8 "Klikk her for å få personale som ikke er opptatt til å hjelpe kollegaer som trenger det",
    staff_stay         = utf8 "Klikk her for å få personale til å bli i rommene du plasserer dem i",
    diag_procedure     = "Om en leges stilte diagnose er mindre sikker en SEND HJEM prosenten, vil pasienten bli sendt hjem. Om diagnosen er sikrere enn GJETT KUR prosenten, vil pasienten sendes til aktuell behandling",
    diag_termination   = utf8 "En pasients diagnosering vil fortsette helt til Legene er så sikker som AVBRYT PROSESS prosenten, eller til alle diagnosemaskiner er forsökt på pasienten",
    staff_rest         = utf8 "Hvor trött personale må være för de kan hvile",
  },
  
  pay_rise_window = {
    accept             = utf8 "Imötekom kravene",
    decline            = "Ikke godta kravene - Si opp istedenfor",
  },
  
  watch = {
    hospital_opening   = utf8 "Byggetid: Dette er tiden du har igjen för sykehuset åpner. Klikk på ÅPNE knappen vil åpne sykehuset umiddelbart.",
    emergency          = utf8 "Nödstilfelle: Tid som gjenstår til å behandle alle akutte pasienter.",
    epidemic           = utf8 "Epidemi: Tid som gjenstår til å skjule epidemien. Når tiden er ute ELLER en smittsom pasient forlater sykehuset, kommer en Helseinspektör på besök. Knappen skrur av og på vaksineringsmodus. Klikk på pasienter for å få en sykepleier til å vaksinere de.",
  },
  
  rooms = {
    -- S[33][1] through S[33][7] unused.
    gps_office         = utf8 "Pasientene får sin förste konsultasjon og tilhörende resultater på Allmennpraksisen",
    psychiatry         = utf8 "Psykiatrien kurerer gale pasienter og hjelper til med diagnosering av andre pasienter, men trenger en Lege med spesialisering innenfor Psykiatri",
    ward               = utf8 "Sengeavdelinger er nyttige for både diagnosering og behandling. Pasienter blir sendt hit for observasjon men også for overvåkning etter operasjoner. Sengeavdelingen krever en Sykepleier",
    operating_theatre  = "Operasjonssalen krever to Leger med spesialisering innenfor Kirurgi",
    pharmacy           = utf8 "Sykepleieren skriver ut medisiner på apoteket for å kurere pasienter",
    cardiogram         = utf8 "En Lege bruker Kardio for å diagnosere pasienter",
    scanner            = utf8 "En Lege bruker Skanneren for å diagnosere pasienter",
    ultrascan          = utf8 "En Lege bruker Ultraskanneren for å diagnosere pasienter",
    blood_machine      = utf8 "En Lege bruker Blodmaskinen for å diagnosere pasienter",
    x_ray              = utf8 "En Lege bruker Röntgen for å diagnosere pasienter",
    inflation          = utf8 "En Lege bruker Pumperommet for å behandle pasienter med Ballonghode",
    dna_fixer          = utf8 "En Lege bruker DNA-maskinen for å behandle pasienter med Utenomjordisk DNA",
    hair_restoration   = utf8 "En Lege bruker Hårklinikken for å behandle pasienter med Flintskalle",
    tongue_clinic      = utf8 "En Lege bruker Tungekutteren for å behandle pasienter med Lös tunge",
    fracture_clinic    = utf8 "En Sykepleier bruker Benbruddsklinikken for å reparere Benbrudd",
    training_room      = utf8 "Et klasserom med en Konsulent kan brukes til å lære opp andre leger",
    electrolysis       = utf8 "En Lege bruker Elektrolyseklinikken for å behandle pasienter med Pelssyndrom",
    jelly_vat          = utf8 "En Lege bruker Gelétönnen for å behandle pasienter med Gelésyndrom",
    staffroom          = utf8 "Leger, Sykepleiere og Vaktmestre bruker personalrommet for å hvile og heve humöret",
    -- rehabilitation  = S[33][27], -- unused
    general_diag       = utf8 "En Lege bruker trallen for å stille grunnleggende diagnose på pasienter. Billig og ofte veldig effektivt",
    research_room      = utf8 "Leger med spesialisering innen Forskning kan forske frem nye medisiner og maskiner på Forskningsavdelingen",
    toilets            = utf8 "Bygg toaletter for å få pasientene til å stoppe å skitne til sykehuset!",
    decontamination    = utf8 "En Lege bruker Saneringsdusjen for å behandle pasienter med Alvorlig Stråling",
  },
  
  objects = {
    -- S[40][1] unused.
    -- NB: most objects do not have a tooltip because they're not (extra-)buyable
    desk                 = "Pult: en Lege kan bruke pulten til PC'en sin.",
    cabinet              = "Kabinett: inneholder pasientdata, notater og forskningsdokumenter.",
    door                 = utf8 "Dör: personer åpner og lukker disse en del.",
    bench                = "Benk: gir pasienter en plass å sitte og gjör ventingen mer komfortabelt.",
    table1               = S[40][ 6], -- unused
    chair                = "Stol: Pasienter sitter her og diskuterer sine problemer.",
    drinks_machine       = utf8 "Brusautomat: hindrer pasientene å bli törste og genererer inntekter.",
    bed                  = "Seng: virkelig syke pasienter ligger i disse.",
    inflator             = "Pumpe: Kurerer pasienter med Ballonghode.",
    pool_table           = utf8 "Biljardbord: Hjelper personalet ditt med å slappe av.",
    reception_desk       = "Resepsjon: trenger en Resepsjonist som kan henvise pasienter til dine Leger.",
    table2               = S[40][13], -- unused & duplicate
    cardio               = S[40][14], -- no description
    scanner              = S[40][15], -- no description
    console              = S[40][16], -- no description
    screen               = S[40][17], -- no description
    litter_bomb          = utf8 "Söppelbombe: saboterer konkurrenters sykehus",
    couch                = S[40][19], -- no description
    sofa                 = utf8 "Sofa: ansatte som slapper av på Personalrommet vil sitte stille i en sofa så fremt det ikke er en bedre måte å slappe av på.",
    crash_trolley        = S[40][21], -- no description
    tv                   = utf8 "TV: sörg for at personalet ditt ikke går glipp av favorittprogrammet sitt.",
    ultrascanner         = S[40][23], -- no description
    dna_fixer            = S[40][24], -- no description
    cast_remover         = S[40][25], -- no description
    hair_restorer        = S[40][26], -- no description
    slicer               = S[40][27], -- no description
    x_ray                = S[40][28], -- no description
    radiation_shield     = S[40][29], -- no description
    x_ray_viewer         = S[40][30], -- no description
    operating_table      = S[40][31], -- no description
    lamp                 = S[40][32], -- unused
    toilet_sink          = utf8 "Vask: dine hygienebevisste pasienter kan vaske sine tilgrisede hender i disse. Om det ikke er nok vasker, blir pasientene sure.",
    op_sink1             = S[40][34], -- no description
    op_sink2             = S[40][35], -- no description
    surgeon_screen       = S[40][36], -- no description
    lecture_chair        = utf8 "Forelesningsstol: dine legestudenter sitter her og tar notater, kjeder seg og rabler ivrig. Jo flere stoler du har, jo större kan klassen være.",
    projector            = S[40][38], -- no description
    bed2                 = S[40][39], -- unused duplicate
    pharmacy_cabinet     = "Apotekskap: medisinbeholdningen din finnes her",
    computer             = utf8 "Datamaskin: genialt forskningsverktöy",
    atom_analyser        = utf8 "Atomanalyser: plassert i Forskningsavdelingen, gjör denne gjenstanden hele forskningsprosessen raskere.",
    blood_machine        = S[40][43], -- no description
    fire_extinguisher    = "Brannslukningsapparat: minimerer faren for feil i dine maskiner.",
    radiator             = utf8 "Ovn: sörger for at sykehuset ditt ikke blir kaldt.",
    plant                = utf8 "Plante: holder pasientenes humör oppe og renser luften.",
    electrolyser         = S[40][47], -- no description
    jelly_moulder        = S[40][48], -- no description
    gates_of_hell        = S[40][49], -- no description
    bed3                 = S[40][50], -- unused duplicate
    bin                  = utf8 "Söppelbötte: pasientene kaster söppelet her.",
    toilet               = utf8 "Toalett: pasientene, æh..., bruker dette.",
    swing_door1          = S[40][53], -- no description
    swing_door2          = S[40][54], -- no description
    shower               = S[40][55], -- no description
    auto_autopsy         = utf8 "Obduseringsmaskin: flott hjelpemiddel for å oppdage nye behandlingsmetoder.",
    bookcase             = "Bokhylle: referansemateriell for Leger.",
    video_game           = "Videospill: la personalet ditt slappe av med Hi-Octane.",
    entrance_left        = S[40][59], -- no description
    entrance_right       = S[40][60], -- no description
    skeleton             = "Skjelett: brukt til undervisning og Halloween.",
    comfortable_chair    = S[40][62], -- no description
  },
}

-- 34: staff titles, inserted further above

confirmation = {
  quit                 = utf8 "Du har valgt å avslutte. Er du sikker på at du vil forlate spillet?",
  return_to_blueprint  = utf8 "Er du sikker på at du vil returnere til Blåkopi-modus?",
  replace_machine      = utf8 "Er du sikker på at du vil erstatte %s for $%d?", -- %s (machine name) %d (price)
  overwrite_save       = utf8 "Et spill er allerede lagret her. Er du sikker på at du vil overskrive det?",
  delete_room          = utf8 "Önsker du virkelig å fjerne dette rommet?",
  sack_staff           = utf8 "Er du sikker på at du vil si opp denne personen?",
  restart_level        = utf8 "Er du sikker på at du vil starte dette nivået på nytt?",
}

-- BANK MANAGER
-- override
bank_manager = {
  hospital_value    = "Sykehusets verdi",
  balance           = "Din balanse",
  current_loan      = utf8 "Nåværende lån",
  interest_payment  = utf8 "Rentekostnader",
  insurance_owed    = "Forsikringsgjeld",
  inflation_rate    = "Inflasjon",
  interest_rate     = "Rentesats",
  statistics_page = {
    date            = "Dato",
    details         = "Detaljer",
    money_out       = "Utg.",
    money_in        = "Innt.",
    balance         = "Saldo",
    current_balance = "Balanse",
  },
}


-- TODO
newspaper = {
  -- Seven categories of funny headlines. I think each category is related
  -- to one criterium you can lose to. TODO: categorize
  { "DOC SHOCK HORROR", "CREEPY GP PLAYS GOD", "PRANKENSTEIN SHOCK", "WHAT WAS ON LAB SLAB?", "RAID HALTS RISKY RESEARCH" },
  { "DR-UNK AS A SKUNK", "SMASHED SURGEON", "CAROUSING CONSULTANT", "SURGICAL SNIFTER", "SURGEON SWILLS IT", "SURGICAL SPIRITS" },
  { "SURGIN' SURGEON", "DOCTOR PANTSDOWN", "DOCTOR GOING DOWN", "INSATIABLE SURGEON" },
  { "DOCTOR-ING THE FIGURES", "ORGAN-ISED CRIME", "BANK BYPASS OPERATION", "FUND HOLDING GP" },
  { "MEDICAL BOFFIN RAIDS COFFIN", "DOC EMPTIES GRAVES", "CAUGHT WITH CORPSE", "DR DEATH'S DAY OF RECKONING", "TERMINAL MALPRACTICE", "DOCTOR'S DIG DENOUNCED" },
  { "DOC STITCHED UP!", "SLACK QUACK", "DAMNING DIAGNOSIS", "CLUMSY CONSULTANT", },
  { "DOC FEELS AT LOOSE END", "SURGEON 'OPERATES' HIMSELF", "BOG BISHOP-BASHING", "DOCTOR'S HANDLE SCANDAL", "MEDIC MAKES A MESS" },
}

--TODO
vip_names = {
  health_minister = "Helseministeren",
  "The Mayor of Greater Trumpton", -- the rest is better organized in an array.
  "Lawrence Nightingale",
  "King Bernard of The Netherlands",
  "Aung Sang Su Kyi, the Burmese Democratic Opposition Leader",
  "Sir Reginald Crumbly",
  "Billy Savile OBE",
  "Councillor Crawford Purves",
  "Rocket Ronnie Jepson",
  "A Premiership footballer",
  "L. F. Probst, III",
}

-- DESEASES
-- override
diseases = {
  -- none                = D( 1), -- not used/needed?
  general_practice       = { 
  	name 		= "Allmennpraksis", 
  },
  bloaty_head 			 = { 
    name 		= "Ballonghode", 
    cause 		= utf8 "Årsak - Pasienten har sniffet ost og drukket forurenset vann.", 
    symptoms 	= utf8 "Symptomer - Den rammede er meget ukomfortabel.", 
    cure 		= utf8 "Behandling - Man stikker hull på det oppsvulmede hodet, og pumper det opp igjen til korrekt PSI med en intelligent maskin.", 
  },
  hairyitis              = { 
  	name 		= "Pelssyndrom", 
  	cause 		= utf8 "Årsak - Fullmåne.", 
  	symptoms 	= utf8 "Symptomer - Ökt luktesans.", 
  	cure		= utf8 "Behandling - En elektrosjokkmaskin fjerner håret, og tetter igjen porene.", 
  },
  king_complex           = { 
  	name 		= "Rock'n'Roll syndrom", 
  	cause 		= utf8 "Årsak - Elivs' ånd tar over kontrollen over pasientens hode", 
  	symptoms 	= utf8 "Symptomer - Går med fargede lærsko, og spiser cheeseburgere", 
  	cure 		= utf8 "Behandling - En psykolog forteller pasienten hvor tåpelig han eller hun ser ut", 
  },
  invisibility           = { 
  	name 		= "Usynlighet", 
  	cause 		= utf8 "Årsak - Bitt av en radioaktiv (og usynlig) maur", 
  	symptoms 	= utf8 "Symptomer - Pasienten lider ikke - tvert imot! De utnytter situasjonen, og lurer familie og venner trill rundt", 
  	cure 		= utf8 "Behandling - En fargerik kur fra apoteket gjör pasienten fullt synlig igjen", 
  },
  serious_radiation      = { 
  	name 		= utf8 "Alvorlig stråling", 
  	cause 		= utf8 "Årsak - Har forvekslet plutonium-isotoper med tyggegummi.", 
  	symptoms 	= utf8 "Symptomer - Pasienten föler seg meget ukomfortabel.", 
  	cure 		= utf8 "Behandling - Pasienten blir plassert i en saneringsdusj og renset fullstendig.", 
  },
  slack_tongue           = { 
  	name 		= utf8 "Lös tunge", 
  	cause 		= utf8 "Årsak - Kronisk overivrig i diskusjoner om såpeopera.", 
  	symptoms 	= "Symptomer - Tungen hever seg til det femdoble.", 
  	cure 		= "Behandling - Tungen blir plassert i en tungekutter. Hevelsen fjernes deretter hurtig, effektivt og smertefullt.",
  },
  alien_dna              = { 
  	name 		= "Utenomjordisk DNA", 
  	cause 		= utf8 "Årsak - Bitt av facehuggere utstyrt med intelligent utenomjordisk blod.", 
  	symptoms 	= utf8 "Symptomer - Er under gradvis forvandling til romvesen, og har et önske om å ta over våre byer.", 
  	cure 		= "Behandling - Alt DNA blir fjernet mekanisk, renset for utenomjordiske celler, og blir hurtig erstattet.",
  },
  fractured_bones        = { 
  	name 		= "Benbrudd",
  	cause 		= utf8 "Årsak - Fall fra store höyder mot betong.", 
  	symptoms 	= utf8 "Symptomer - Höye knaselyder og liten bevegelighet på utsatte steder.", 
  	cure 		= "Behandling - Gipsen blir fjernet ved hjelp av en laserstyrt gipsfjerner.", 
  },
  baldness               = { 
  	name 		= "Flintskalle", 
  	cause 		= utf8 "Årsak - Forteller lögner og dikter opp historier for å öke sin popularitet.", 
  	symptoms 	= "Symptomer - Forlegen pasient med skinnende skalle.", 
  	cure 		= utf8 "Behandling - Hår blir hurtig smeltet fast til pasientens hode med en smertefull hårmaskin.",
  },
  discrete_itching       = { 
  	name 		= "Skrapesyke", 
  	cause 		= utf8 "Årsak - Små insekter med skarpe tenner.", 
  	symptoms 	= utf8 "Symptomer - Pasienten klör intenst, og huden flasser.", 
  	cure 		= utf8 "Behandling - En sykepleier gir pasienten en sirupaktig drikk som leger huden og hindrer videre klöe.",
  },
  jellyitis              = { 
  	name 		= utf8 "Gelésyndrom", 
  	cause 		= utf8 "Årsak - Gelatinrik diett og for mye mosjon.", 
  	symptoms 	= utf8 "Symptomer - Meget ustödig og faller mye.", 
  	cure 		= utf8 "Behandling - Pasienten blir presset ned i en gelétönne i et spesielt rom.",
  },
  sleeping_illness       = { 
  	name 		= utf8 "Sövnsyke", 
  	cause 		= utf8 "Forårsaket av overaktive sövnkjertler i munnens gane.", 
  	symptoms 	= utf8 "Symptomer - Sterkt önske om å sove, hvor og når som helst.", 
  	cure 		= "Behandling - En sterk dose stimulerende medisin blir delt ut av en sykepleier.",
  },
  pregnancy              = { 
  	name 		= "Graviditet", 
  	cause 		= utf8 "Forårsaket av strömbrudd i urbane strök.", 
  	symptoms 	= utf8 "Symptomer - Lei av å spise med konstant ölmage.", 
  	cure 		= "Behandling - Spedbarnet blir fjernet med keisersnitt, blir deretter vasket og presentert for sin nye mor.",
  },   -- unused
  transparency           = { 
  	name 		= "Gjennomsiktighet", 
  	cause 		= utf8 "Årsak - Slikket folien på et gammelt yoghurtbeger.", 
  	symptoms 	= "Symptomer - Kroppen blir gjennomsiktig og ekkel.", 
  	cure 		= utf8 "Behandling - En kald og fargerik drikk fra apoteket gjör susen.",
  },
  uncommon_cold          = { 
  	name 		= utf8 "Forkjölelse",
  	cause 		= utf8 "Årsak - Små snörrpartikler i luften.", 
  	symptoms 	= "Symptomer - Rennende nese, hoste og misfarget slim fra lungene.", 
  	cure 		= utf8 "Behandling - En real slurk hostesaft fra apoteket vil gjöre susen.", 
  },
  broken_wind            = { 
  	name 		= "Forurensende gasser", 
  	cause 		= utf8 "Årsak - Har löpt på 3d-mölle rett etter middag.", 
  	symptoms 	= "Symptomer - Ubehag hos folk som befinner seg rett bak pasienten.", 
  	cure 		= utf8 "Behandling - En sterk blanding av spesielle vannatomer må svelges hurtig.",
  },
  spare_ribs             = { 
  	name 		= "Juleribbe", 
  	cause 		= utf8 "Årsak - Pasienten har sittet på kalde steingulv.", 
  	symptoms 	= utf8 "Symptomer - Ubehagelig fölelse i brystet.", 
  	cure 		= "Behandling - Ribben fjernes av to kirurger, og leveres til pasienten i en doggybag.",
  },
  kidney_beans           = { 
  	name 		= "Kikkerter", 
  	cause 		= utf8 "Årsak - Pasienten har spist isbiter.", 
  	symptoms 	= utf8 "Symptomer - Smerte og hyppige turer til toalettet.", 
  	cure 		= utf8 "Behandling - To kirurger fjerner de ertelignende parasittene, uten å beröre nyrene!",
  },
  broken_heart           = { 
  	name 		= "Knust hjerte",
  	cause 		= utf8 "Årsak - Noen er rikere, yngre og slankere enn pasienten.", 
  	symptoms 	= utf8 "Symptomer - Hysterisk gråtende. Blodsprengte fingertupper etter å ha revet opp feriebilder.", 
  	cure 		= "Behandling - To kirurger spretter opp brystet og setter deretter hjertet forsiktig sammen, mens de holder pusten.", 
  },
  ruptured_nodules       = { 
  	name 		= utf8 "Knekte nötter", 
  	cause 		= utf8 "Årsak - Strikkhopp om vinteren.", 
  	symptoms 	= utf8 "Symptomer - Umulig å sitte behagelig.", 
  	cure 		= utf8 "Behandling - To kvalifiserte kirurger må fjerne nöttene med stödige hender.",
  },
  tv_personalities       = { 
  	name 		= "Programledersyndrom", 
  	cause 		= utf8 "Årsak - TV-titting på dagtid.", 
  	symptoms 	= utf8 "Symptomer - Forestiller seg at han/hun er programleder i frokost-tv, og elsker å introdusere kjökkenseansen.", 
  	cure 		= utf8 "Behandling - En psykolog må overtale pasienten til å selge fjernsynet og heller kjöpe radio.",
  },
  infectious_laughter    = { 
  	name 		= "Smittsom latter", 
  	cause 		= utf8 "Årsak - Klassisk situasjonskomedie på TV.", 
  	symptoms 	= utf8 "Symptomer - Ler hjelpelöst hele tiden, og repeterer stadig dårlige poeng som absolutt ikke er morsomme.", 
  	cure 		= utf8 "Behandling - En kvalifisert psykolog må minne pasienten på at dette faktisk er en alvorlig tilstand.",
  },
  corrugated_ankles      = { 
  	name 	 	= utf8 "Böyde ankler", 
  	cause 		= utf8 "Årsak - Busskjöring over fartsdempere.", 
  	symptoms 	= "Symptomer - Skoene passer ikke.", 
  	cure 		= utf8 "Behandling - En giftig blanding av urter og krydder må drikkes for å rette ut anklene.",
  },
  chronic_nosehair       = { 
  	name 		= utf8 "Kronisk nesehår", 
  	cause 		= utf8 "Årsak - Snöfter med forakt på folk med lavere inntekt.", 
  	symptoms 	= utf8 "Symptomer - Så mye nesehår at en grevling kunne bodd der.", 
  	cure 		= utf8 "Behandling - En ekkel hårfjernende drikk blir inntatt gjennom munnen. Fåes på apoteket.",
  },
  third_degree_sideburns = { 
  	name 		= "Tredjegrads koteletter", 
  	cause 		= utf8 "Årsak - Lengter tilbake til 70-tallet.", 
  	symptoms 	= utf8 "Symptomer - Stort hår, inntilsittende klær, langt skinnskjegg og glitter.", 
  	cure 		= utf8 "Behandling - Psykologisk personell må, ved hjelp av nåtidens teknikker, overbevise pasienten om at parykk er noe tull.",
  },
  fake_blood             = { 
  	name 		= "Teaterblod", 
  	cause 		= utf8 "Årsak - Pasienten er ofte utsatt for narrestreker.", 
  	symptoms 	= utf8 "Symptomer - Rödt blod som dunster ved kontakt med klær.", 
  	cure 		= utf8 "Behandling - Eneste måten å behandle dette på, er å få en psykolog til å roe ned pasienten.",
  },
  gastric_ejections      = { 
  	name 		= utf8 "Krydrede oppstöt", 
  	cause 		= utf8 "Årsak - Sterkt krydret meksikansk eller indisk mat har skylden.", 
  	symptoms 	= "Symptomer - Gulper karrikylling og tacolefser.", 
  	cure 		= utf8 "Behandling - En sykepleier gir pasienten en bindende indisk kumelk-blanding som forhindrer nye oppstöt..",
  },
  the_squits             = { 
  	name 		= utf8 "Lös mage", 
  	cause 		= utf8 "Årsak - Har spist pizzabiter som har falt bak komfyren.", 
  	symptoms 	= utf8 "Symptomer - æsj. Tipper du vet symptomene.", 
  	cure 		= utf8 "Behandling - En klebig blanding kjemikalier må drikkes for å stabilisere magen innvendig.",
  },
  iron_lungs             = { 
  	name 		= "Jernlunger", 
  	cause 		= utf8 "Årsak - Forurenset byluft blandet med kebabrester.", 
  	symptoms 	= utf8 "Symptomer - Kan puste flammer og bröle höyt under vann.", 
  	cure 		= "Behandling - To kirurger mykner de solide lungene i operasjonssalen.",
  },
  sweaty_palms           = { 
  	name 		= utf8 "Håndsvette", 
  	cause 		= utf8 "Årsak - Er livredd jobbintervjuer.", 
  	symptoms 	= utf8 "Symptomer - Å håndhilse på pasienten er som å ta tak i en våt svamp.", 
  	cure 		= utf8 "Behandling - En psykolog må snakke pasienten ut av denne oppdiktede lidelsen.",
  },
  heaped_piles           = { 
  	name 		= "Hemoroider", 
  	cause 		= utf8 "Årsak - Står i nærheten av drikkevannskjölere.", 
  	symptoms 	= utf8 "Symptomer - Pasienten föler han/hun sitter på en pose med stein.", 
  	cure 		= utf8 "Behandling - En behagelig, men meget syrlig drikk, lösner opp hemoroidene innenifra.",
  },
  gut_rot                = { 
  	name 		= utf8 "Mageråte", 
  	cause 		= utf8 "Årsak - Onkel Georgs miks av hostesaft og whisky.", 
  	symptoms 	= "Symptomer - Ingen hoste, men ingen magesekk heller.", 
  	cure 		= "Behandling - En sykepleier skriver ut en rekke kjemikalier og gjenskaper veggen i magesekken.",
  },
  golf_stones            = { 
  	name 		= "Golfsteiner", 
  	cause 		= utf8 "Årsak - Utsatt for giftige gasser fra golfballer.", 
  	symptoms 	= utf8 "Symptomer - Forvirring og kraftig skamfölelse.", 
  	cure 		= "Behandling - Steinene fjernes kjapt og effektivt av to kirurger.",
  },
  unexpected_swelling    = { 
  	name 		= "Uventet hevelse", 
  	cause 		= utf8 "Årsak - Hva som helst uventet.", 
  	symptoms 	= "Symptomer - Hevelse.", 
  	cure 		= utf8 "Behandling - Hevelsen må skjæres bort av to kirurger.",
  },
  diag_scanner           = { name = "Diag Skanner", },
  diag_blood_machine     = { name = "Diag Blodmaskin", },
  diag_cardiogram        = { name = "Diag Kardio", },
  diag_x_ray             = { name = utf8 "Diag Röntgen", },
  diag_ultrascan         = { name = "Diag Ultraskanner", },
  diag_general_diag      = { name = "Diag Generell", },
  diag_ward              = { name = "Diag Sengeavd.", },
  diag_psych             = { name = "Diag Psykiatri", },
  autopsy                = { name = "Obduksjon", },
  -- mixer               = D(46), -- not used/needed?
}
-- ...


-- FAXES
-- override
fax = {
 debug_fax = {
    -- never seen this, must be a debug option of original TH
    -- TODO: make this nicer if we ever want to make use of it
    close_text = "Yes, yes, yes!",
    text1      = "BEST COUNT %d", -- %d
    text2      = "TOTAL PEOPLE IN HOSPITAL %d CHECKING AGAINST %d", -- %d %d
    text3      = "FIGURES  : DOCS %d  NURSES %d  AREA %d  ROOMS %d  PRICING %d", -- %d %d %d %d %d
    text4      = "FACTORS  : DOCS %d  NURSES %d  AREA %d  ROOMS %d  PRICING %d", -- %d %d %d %d %d
    text5      = "CONTRIBN : DOCS %d  NURSES %d  AREA %d  ROOMS %d  PRICING %d PERCENT", -- %d %d %d %d %d
    text6      = "THE FOLLOWING FACTORS ARE ALSO APPLIED",
    text7      = "REPUTATION: %d EXPECTED %d REDUCTION %d", -- %d %d %d
    text8      = "AMENITIES %d PEEPS HANDLED %d REDUCTION %d", -- %d %d %d
    text9      = "DISASTERS %d ALLOWED (MTHS) %d (%d)REDUCTION %d", -- %d %d %d %d
    text10     = "KILLS %d ALLOWED (MTHS) %d (%d) REDUCTION %d", -- %d %d %d %d
    text11     = "PEOPLE THIS MONTH %d", -- %d
  },
  
  emergency = {
    choices = {
      accept = utf8 "Ja, jeg er klar til å håndtere dette", 
      refuse = utf8 "Nei, jeg nekter å ta meg av dette",
    },
    location 						   = "Det har skjedd en ulykke ved %s", 
    num_disease 					   = "Det er %d mennesker med %s som trenger akutt behandling.",
    cure_possible_drug_name_efficiency = utf8 "Du har det som trengs av nödvendig utstyr og ferdigheter, og du har medisinen de trenger. Det er %s og medisinen er %d prosent effektiv.", 
    cure_possible 					   = utf8 "Du har nödvendig utstyr og de ferdigheter som trengs for å ta deg av dette.", 
    cure_not_possible_build_and_employ = utf8 "Du vil måtte bygge  %s og ansette en %s",
    cure_not_possible_build            = utf8 "Du mangler %s for å håndtere dette",
    cure_not_possible_employ           = utf8 "Du mangler en %s for å kunne håndtere dette",
    cure_not_possible                  = utf8 "Du kan ikke behandle denne sykdommen for öyeblikket",
    bonus                              = utf8 "Om du klarer å håndtere dette nödstilfellet, vil du få en bonus på maksimalt %d. Om du feiler derimot, vil ryktet ditt få en kraftig smell.",
    
    locations = {      
      utf8 "A.Tom's Våpenkjeller",
      "Snobbeuniversitetet",       
      "Buskerud Hagesenter", 
      "Forskningsinstituttet For Farlige Emner", 
      "Foreningen For Folkedansende Menn", 
      "puben Frosk Og Kyr", 
      utf8 "Hallgeir Juniors Begravelsesbyrå Og Spritbutikk",
      "Mama-Tai Krydderhus", 
      "Berts Varehus For Brukt Petrokjemi", 
    },
  },

  emergency_result = {
    close_text 		= utf8 "Klikk for å gå ut",
    earned_money 	= utf8 "Av en maksimal bonus på %d, har du tjent %d.",
    saved_people 	= "Du reddet %d mennesker av totalt %d.",
  },  
  
  disease_discovered_patient_choice = {
    choices = {
      send_home = "Send pasienten hjem.",
      wait      = utf8 "Få pasienten til å vente litt på sykehuset.",
      research  = "Send pasienten til forskningsavdelingen.",
    },
    need_to_build_and_employ = utf8 "Om du bygger %s og ansetter en %s kan du löse problemet med en gang.",
    need_to_build            = utf8 "Du må bygge %s for å håndtere dette.",
    need_to_employ           = utf8 "Ansett en %s for å hjelpe pasienten.",
    can_not_cure             = "Du kan ikke behandle denne sykdommen.",
    disease_name             = "Dine ansatte har oppdaget et tilfelle av %s",
    what_to_do_question      = utf8 "Hva vil du gjöre med pasienten?",
    guessed_percentage_name  = "Teamet ditt mener de vet hva som feiler pasienten. Det er %d prosent sannsynlighet for at det er %s",
  },
  
  disease_discovered = {
    close_text 				 = "En ny sykdom er oppdaget.",
    can_cure 				 = "Du kan behandle denne sykdommen.",
    need_to_build_and_employ = utf8 "Om du bygger %s og ansetter en %s kan du håndtere dette.",
    need_to_build            = utf8 "Du må bygge %s for å håndtere dette.",
    need_to_employ           = utf8 "Ansett en %s for å behandle pasienter med denne sykdommen.",
    discovered_name          = "Ditt team har oppdaget et tilfelle av %s",
  },
  
  epidemic = {
    choices = {
      declare  = utf8 "Offentliggjör epidemi, betal boten og godta at ryktet ditt blir svekket.",
      cover_up = utf8 "Forsök å behandle alle infiserte pasienter för tiden renner ut, og för noen forlater sykehuset.",
    },
    
    disease_name             = utf8 "Dine leger har oppdaget en svært smittsom form for %s.",
    declare_explanation_fine = utf8 "Om du offentliggjör epidemien, må du betale en bot på %d, ditt rykte får en smell, og samtlige pasienter blir vaksinert automatisk.",
    cover_up_explanation_1   = utf8 "Om du deriomt forsöker å holde epidemien skjult, må du behandle samtlige infiserte pasienter för helsemyndighetene får rede på det.",
    cover_up_explanation_2   = utf8 "Om en helseinspektör kommer på besök og finner ut at du pröver å skjule epidemien, kan han gå drastisk til verks.",
  },
  
  epidemic_result = {
    close_text = "Hurra!",
    
    failed = {
      part_1_name = utf8 "Gjennom forsöket på å skjule det faktum at vi sto ovenfor et smittsomt utbrudd av %s",
      part_2      = utf8 "klarte personalet ditt selvfölgelig å spre epidemien ut til alle sykehusets naboer.",
    },
    succeeded = {
      part_1_name = utf8 "Helseinspektören hörte rykter om at institusjonen din slet med et alvorlig tilfelle av %s.",
      part_2      = utf8 "Han har derimot ikke lykkes i å finne beviser som bekrefter ryktene.",
    },
    
    compensation_amount  = utf8 "Myndighetene har besluttet å gi deg %d i kompensasjon for skaden disse lögnene har påfört ditt gode rykte.",
    fine_amount          = utf8 "Myndighetene har erklært nasjonal unntakstilstand og bötelegger deg med %d.",
    rep_loss_fine_amount = utf8 "Avisene har nå nytt forsidestoff, og ditt rykte får en kraftig smell. I tillegg blir du bötelagt med %d.",
    hospital_evacuated   = utf8 "Helserådet har ikke annet valg enn å evakuere sykehuset ditt.",
  },
  
  vip_visit_query = {
    choices = {
      invite = "Send offisiell invitasjon til V.I.P.",
      refuse = utf8 "Avvis forespörselen fra V.I.P med dårlige unnskyldninger.",
    },
    
    vip_name = utf8 "%s har ytret et önske om å få besöke sykehuset ditt",
  },
  
  vip_visit_result = {
    close_text = utf8 "Takk for at du besökte sykehuset.",
    telegram          = "Telegram!",
    vip_remarked_name = utf8 "Etter sitt besök på sykehuset ditt, sa %s fölgende:",
    cash_grant = "Du er blitt tildelt %d i kontanter.",
    rep_boost  = utf8 "Ditt rykte i næromrdet har fått en opptur.",
    rep_loss   = utf8 "Ditt rykte har fått seg en smell.",
    
    remarks = {
      super = {
        "For et flott sykehus. Neste gang jeg er alvorlig syk vil jeg hit.",
        "Dette er hva jeg kaller sykehus.",
        utf8 "Et supert sykehus. Og jeg burde vite; jeg har vært på en del.",
      },
      good = {
        "For et velorganisert sykehus. Takk for at jeg fikk komme hit.",
        utf8 "Hmm. Ingen dårlig medisinsk instutisjon dette, det skal være visst.",
        utf8 "Jeg likte ditt sjarmerende sykehus. Forresten, noen som blir med å spise indisk?",
      },
      mediocre = {
        utf8 "Vel, jeg har sett verre. Men du burde gjöre noen forbedringer.",
        utf8 "Å kjære min tid. Dette er ikke stedet å gå om du föler deg dårlig.",
        utf8 "Et helt allminnelig sykehus, for å være ærlig. Jeg hadde forventet meg noe mer.",
      },
      bad = {
        utf8 "Hva gjör jeg her egentlig? Dette her var verre enn en firetimers opera!",
        "Dette var ekkelt. Kaller du dette et sykehus? Ser mer ut som en svinesti!",
        utf8 "Jeg er lei av å være en offentlig person og lei stinkende hull som dette! Jeg sier opp.",
      },
      very_bad = {
        utf8 "For et syn. Dette sykehuset skal jeg pröve å få lagt ned.",
        utf8 "Jeg har aldri sett på maken. For en skandale!",
        utf8 "Jeg er sjokkert. Du kan ikke kalle dette et sykehus! Jeg går og tar meg en sterk drink.",
      },
    },
  },
  
  diagnosis_failed = {
    choices = {
      send_home   = "Send pasienten hjem",
      take_chance = utf8 "Gjett sannsynlig behandling.",
      wait        = utf8 "Få pasienten til å vente mens du bygger flere diagnoserom.",
    },
    situation = utf8 "Vi har brukt alle våre diagnosemaskiner på denne pasienten, men vi vet fremdeles ikke sikkert hva som er galt.",
    what_to_do_question = utf8 "Hva skal vi gjöre med pasienten?",
    partial_diagnosis_percentage_name = "Det er %d prosent sikkert at vi vet hvilken type %s pasienten har.",
  },
}
-- ...

queue_window = {
  num_in_queue       = utf8 "Kölengde",
  num_expected       = "Ventet",
  num_entered        = utf8 "Antall besök",
  max_queue_size     = "Maks str.",
}


dynamic_info = {
  patient = {
    actions = {
      dying                       = utf8 "Döende",
      awaiting_decision           = "Venter din beslutning",
      queueing_for                = utf8 "I köen til %s", -- %s
      on_my_way_to                = utf8 "På vei til %s", -- %s
      cured                       = "Kurert!",
      fed_up                      = "Sint, forlater sykehuset",
      sent_home                   = "Sendt hjem",
      sent_to_other_hospital      = "Henvist til annet sykehus",
      no_diagnoses_available      = "Ingen flere diagnosemuligheter",
      no_treatment_available      = utf8 "Ingen behandling mulig - Jeg går hjem",
      waiting_for_diagnosis_rooms = utf8 "Venter på at du skal bygge flere diagnoserom for meg",
      waiting_for_treatment_rooms = utf8 "Venter på at du skal bygge behandlingsrom for meg",
      prices_too_high             = utf8 "Prisene er for höye - Jeg går hjem",
      epidemic_sent_home          = utf8 "Sendt hjem av inspektör",
      epidemic_contagious         = "Jeg er smittsom",
    },
    diagnosed                   = "Diagnose: %s", -- %s
    guessed_diagnosis           = "Gjettet diagnose: %s", -- %s
    diagnosis_progress          = "Diagnoseprosess",
    emergency                   = "Akutt: %s", -- %s (disease name)
  },
  vip                           = utf8 "Besökende VIP",
  health_inspector              = utf8 "Helseinspektör",
  
  staff = {
    psychiatrist_abbrev         = "Psyk.",
    actions = {
      waiting_for_patient         = utf8 "Venter på pasient",
      wandering                   = "Vandrer rundt omkring",
      going_to_repair             = "Skal reparere %s", -- %s (name of machine)
    },
    tiredness                   = utf8 "Trötthet",
    ability                     = "Evner", -- unused?
  },
  
  object = {
    strength                    = "Holdbarhet %d", -- %d (max. uses)
    times_used                  = "Ganger brukt %d", -- %d (times used)
    queue_size                  = utf8 "Kölengde %d", -- %d (num of patients)
    queue_expected              = utf8 "Forventet kölengde %d", -- %d (num of patients)
  },
}


-- new strings
object.litter 				  = utf8 "Söppel"

menu_options_game_speed.pause = "  PAUSE  "

menu_debug = {
  transparent_walls           = "  GJENNOMSIKTIGE VEGGER  ",
  limit_camera                = "  BEGRENS KAMERA  ",
  disable_salary_raise        = utf8 "  DEAKTIVER LÖNNSÖKNINGER  ",
  make_debug_patient          = "  LAG DEBUG-PASIENT  ",
  spawn_patient               = "  SPAWN PASIENT  ",
  make_adviser_talk           = utf8 "  FÅ RÅDGIVER TIL Å SNAKKE  ",
  show_watch                  = "  VIS KLOKKE  ",
  place_objects               = "  PLASSER OBJEKTER  ",
  dump_strings                = "  DUMP SPRÅKSTRENG  ",
  map_overlay                 = "  KARTOVERLEGG  ",
  sprite_viewer               = "  SPRITEVISNING  ",
}

menu_debug_overlay = {
  none                        = "  INGEN  ",
  flags                       = "  FLAGG  ",
  byte_0_1                    = "  BYTE 0 & 1  ",
  byte_floor                  = "  BYTE GULV  ",
  byte_n_wall                 = "  BYTE N VEGG  ",
  byte_w_wall                 = "  BYTE W VEGG  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  PAKKE  ",
}

adviser.room_forbidden_non_reachable_parts = utf8 "Ved å plassere et rom her vil noen områder på sykehuset bli utilgjengelig."

fax = {
  welcome = {
    beta1 = {
      utf8 "Velkommen til CorsixTH, en klone av klassikeren Theme Hospital (Bullfrog) i åpen kildekode!",
      "Dette er en spillbar beta 1 av CorsixTH. Mange rom, sykdommer og funksjoner er implementert, men det er fremdeles mye som mangler.",
      utf8 "Om du liker dette prosjektet, kan du hjelpe oss med utviklingen, f.eks ved å rapportere feil, bidra med oversettelser, eller begynne å programmere noe selv.",
      utf8 "Men nå, kos deg med spillet! For dere som ikke kjenner til Theme Hospital: Start med å bygge en resepsjon (fra inventarmenyen) og en Allmennpraksis (diagnoserom). Ulike behandlingsrom blir også nödvendig.",
      "-- CorsixTH teamet, th.corsix.org",
      utf8 "PS: Kan du finne de sjulte påskeeggene?",
    }
  }
}
