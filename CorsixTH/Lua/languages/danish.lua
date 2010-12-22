--[[ Copyright (c) 2010 Robin Madsen (RobseRob)

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

Language("Dansk", "Danish", "da", "dk")
Inherit("english")
Inherit("original_strings", 0)

calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = "%d kalder; %d tildelte",
  staff = "%s - %s",
  watering = "Vander @ %d,%d",
  repair = "Reparere %s",
  close = "Luk",
}

  menu_debug = {
  jump_to_level               = utf8 "  Gå til runde  ",
  transparent_walls           = utf8 "  (K) TRANSPERANTE VÆGE  ",
  limit_camera                = utf8 "  BEGRÆNS KAMERAET  ",
  disable_salary_raise        = utf8 "  STOP LÖNFORHÖJELSER  ",
  make_debug_fax              = "  (F8) LAV FEJLFINDINGS FAX  ",
  make_debug_patient          = utf8 " (F9) LAV FEJLFINDINGS PATIENT  ",
  spawn_patient               = utf8 "  GENERER TILFÆLDIG PATIENT  ",
  make_adviser_talk           = utf8 "  FÄ RÄDGIVEREN TIL AT SNAKKE  ",
  show_watch                  = "  VIS URET ",
  create_emergency            = utf8 "  LAV ET AKUTTILFÆLDE  ",
  place_objects               = "  PLACER OBJEKTER  ",
  cheats                      = "  (F11) SNYD  ",
  lua_console                 = "  (F12) LUA KONSOLE  ",
  calls_dispatcher            = utf8 "  KALD På AFSENDER  ",
  dump_strings                = "  DUMP TEKT  ",
  dump_gamelog                = "  (CTRL + D) DUMP SPILLOG  ",
  map_overlay                 = "  KORTOVERSIGT  ",
  sprite_viewer               = "  SPRITE VISER  ",
}
  
  tooltip.calls_dispatcher = {
  task = utf8 "Liste over opgaver -  klik for at åbne det tildelte personales vindue og scroll til den önskede opgave",
  assigned = utf8 "Dette valgfelt er markeret hvis nogen har fået tildelt den pågældende opgave opgave.",
  close = utf8 "Luk dialogen",
}

menu_options = {
  lock_windows = utf8 "  LÅS VINDUER  ",
  edge_scrolling = "  KANT SCROLLING  ",
  settings = "  INDSTILLINGER  ",
}

-- menu_options_game_speed.pause = "  PAUSE  "


  
menu_debug_overlay = {
  none                        = "  INTET  ",
  flags                       = "  FLAG  ",
  positions                   = "  KORDINATER  ",
  heat                        = "  TEMPERATUR  ",
  byte_0_1                    = "  BYTE 0 & 1  ",
  byte_floor                  = "  BYTE GULV  ",
  byte_n_wall                 = utf8 "  BYTE N VÆG  ",
  byte_w_wall                 = utf8 "  BYTE W VÆG  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  TOMT  ",
}

-- new strings
object.litter = "Skrald"
tooltip.objects.litter = "Skrald: Smidt af dine patienter da de ikke kunne finde en skraldespand"

adviser.room_forbidden_non_reachable_parts = "Hvis du placerede rummet her ville det resultere at dele af dit hospital ikke ville være tilgængelige."

dynamic_info.patient.actions.no_gp_available = utf8 "Venter på du bygger lægens kontor"
dynamic_info.staff.actions.heading_for = "På vej til %s"
dynamic_info.staff.actions.fired = "Fyret"

fax = {
    welcome = {
    beta1 = {
      --"Welcome to CorsixTH, an open source clone of the classic game Theme Hospital by Bullfrog!", 
      "Velkommen til CorsixTH, som er en open source klon af det klassiske spil Theme Hospital af Bullfrog!",
      --"This is playable beta 1 of CorsixTH. Many rooms, diseases and features have been implemented, but there are still many things missing.",
      "Dette er den spilbare beta 1 af CorsixTH. Mange af sygdommene, rummene og funktionerne er blevet implementeret, men der er stadigt mange ting som mangler.",
      --"If you like this project, you can help us with development, e.g. by reporting bugs or starting to code something yourself.",
      "Hvis du kan lide dette projekt, kan du hjælpe os med udviklingen f.eks. ved at informatere os om fejl og starte med at kode noget for dig selv.",
      --"But now, have fun with the game! For those who are unfamiliar with Theme Hospital: Start by building a reception desk (from the objects menu) and a GP's office (diagnosis room). Various treatment rooms will also be needed.",
      "Men nu skal du have det sjovt med spillet. Hvis du ikke er bekendt med Theme Hospital: Start med at bygge en receptionsbord (fra objekt menuen) og et lægens kontor (diagnose rum)",
      "-- The CorsixTH team, th.corsix.org",
   --   "PS: Can you find the easter eggs we included?",
      "PS: Kan du finde de easter eggs der er i spillet?",
    },
    beta2 = {
      --"Welcome to the second beta of CorsixTH, an open source clone of the classic game Theme Hospital by Bullfrog!",
       "Velkommen til CorsixTH, som er en open source klon af det klassiske spil Theme Hospital af Bullfrog!",
	--"A lot of new features have been implemented since the last release. Have a look at the changelog for an incomplete list.",
      "Der er blevet tilföjet en masse nye funktioner siden sidste udgivelse. Tag og kig i changeloggen for at se en ukomplet liste",
	   "But first, let's play! It seems there's a message waiting for you. Close this window and click on the question mark above the bottom panel.",
      "-- The CorsixTH team, th.corsix.org",
    },
  },  
  tutorial = {
    utf8 "Velkommen til dit förste hospital!",
    utf8 "önsker du en kort vejledning til spillet?",
    "Ja gerne.",
    "Nej tak, jeg ved allerede hvordan man spillet.",
  },
  choices = {
    return_to_main_menu = "Tilbage til hovedmenuen",
    accept_new_level = utf8 "Gå videre til næste bane",
    decline_new_level = utf8 "Spil videre en smule længere",
  },
}

letter = {
  dear_player = utf8 "Kære %s",
  custom_level_completed = utf8 "Godt arbejde! Du har opfyldt alle mål på denne speical bane!",
  return_to_main_menu = utf8 "Vil du gå tilbage til hoved menuen eller fortsætte med at spille?",
}

install = {
  title = "--------------------------------- CorsixTH Installation ---------------------------------",
  th_directory = utf8 "CorsixTH har brug for en kopi af Theme Hospitals datafiler for at kunne fungere. Vælg venligst mappen hvori Theme Hospitals datafiler er placeret med vælgeren herunder.",
}

misc.not_yet_implemented = "(ikke implanteret endnu)"
misc.no_heliport = "Enten er der ikke blevet opdaget nogen sygdomme endnu, ellers er der ingen helicopter plads på denne bane."

main_menu = {
  new_game = "Nyt spil",
  custom_level = "Special bane",
  load_game = utf8 "Indlæs spil",
  options = utf8 "Indstillinger",
  exit = "Afslut",
}

tooltip.main_menu = {
  new_game = "Start et nyt spil fra begyndelsen",
  custom_level = "Lav dit eget sygehus i speciale baner",
  load_game = utf8 "Indlæs et gemt spil",
  options = utf8 "Ændre dine indstillinger",
  exit = utf8 "Er du sikker på du ikke vil spille mere?",
}

load_game_window = {
  caption = utf8 "Indlæs spil",
}

tooltip.load_game_window = {
  load_game = utf8 "Indlæs spil %s",
  load_game_number = utf8 "Indlæs spil %d",
  load_autosave = utf8 "Indlæs autogem",
}

custom_game_window = {
  caption = "Special bane",
}

tooltip.custom_game_window = {
  start_game_with_name = utf8 "Indlæs banen %s",
}

save_game_window = {
  caption = "Gem spil",
  new_save_game = "Nyt gemt spil",
}

tooltip.save_game_window = {
  save_game = "Overskriv gemmet %s",
  new_save_game = "Skriv navnet for det nye gem",
}

menu_list_window = {
  back = "Tilbage",
}

tooltip.menu_list_window = {
  back = "Luk dette vindue",
}

options_window = {
  fullscreen = utf8 "Fuldskærm",
  width = "Brede",
  height = utf8 "Höjde",
  change_resolution = utf8 "Skift oplösning",
  back = "Tilbage",
}

tooltip.options_window = {
  fullscreen_button = utf8 "Klik for at skifte imellem fuldskærmsvisning",
  width = utf8 "Indtast den önskede skærm brede",
  height = utf8 "Indtast den önskede skærm höjde",
  change_resolution = utf8 "Skift skærmstörrelsen til dimmensionerne indtastet til höjre",
  language = utf8 "Vælg %s som sprog",
  back = "Luk indstillings vinduet",
}

errors = {
  dialog_missing_graphics = "Undskyld, men demo data filerne har ikke en dialog.",
  save_prefix = "Fejl under gem af spil: ",
  load_prefix = utf8 "Fejl under indlæsning af spil: ",
  map_file_missing = "Kunne ikke finde kort filen %s for denne bane!",
  minimum_screen_size = utf8 "Indtast venligst en oplösning på mindst 640x480.",
}

confirmation = {
  needs_restart = utf8 "Skiftning af denne indstilling kræver genstart af CorsixTH. Alle ugemte data vil gå tabt. Er du sikker på du vil göre dette?"
}

information = {
  custom_game = "Velkommen til CorsixTH. Hav det sjovt med denne special bane!",
  cannot_restart = utf8 "Beklageligvis så er denne special bane lavet för at genstart funtionen blev implanteret.",
level_lost = {
    utf8 "æv! Du gennemförte ikke runden. Bedre held næste gang!",
    "Grundene til du tabte:",
    reputation = utf8 "Dit omdömme var under %d.",
    balance = utf8 "Din bankbalance (eks. lån) var under %d.",
    percentage_killed = utf8 "Du har dræbt mere end %d procent af patienterne.",
  },
  }

tooltip.information = {
  close = "Luk informations dialogen",
}
-- I translatet these tips that show up on the main menu screen //froksen
totd_window = {
  tips = {
    utf8 "I et hvert hospital er det nödvendigt have et receptions bord og lægens kontor for at komme i gang. Herefter er det alt efter hvilke patienter der kommer til dit hospital, dog er et apotek altid et fornuftigt valg.",
    utf8 "Maskiner, som f.eks. pumperum, har brugt for vedligeholdelse. Ansæt en handyman eller to til at vedligeholde dine maskiner, ellers kan du risikere at dine ansatte eller patienter kommer til skade",
   utf8  "Med tiden bliver dine ansatte trætte. Husk at bygge et personale rum så de kan slappe af.",
  utf8   "Placer radiatorer så dine patienter og ansatte kan holde varmen, ellers bliver de galde. Brug by kortet til at lokalisere steder på dit hospital som skal være varmere.",
  utf8   "En læges kvalifikationsniveau betyder meget for kvaliteten og hastighedsen på hans diagnoser. Hvis du placer en meget kvalificeret læge pa lægens kontor behöver du ikke så mange ekstra diagonise rum.",
    --Juniors and doctors can improve their skills by learning from a consultant in the training room. If the consultant has a special qualification (surgeon, psychiatrist or researcher), he will also pass on this knowledge to his pupil(s).
   utf8  "Praktikanter og læger kan forbedre deres kvalifikationer ved at blive undervist af en konsulent i et træningsrum. Hvis konsulenten har specielle kvalifikationer (Kirug, psykiater eller forsker) vil han også give disse kvalifikationer videre til sine elever.",
   -- "Did you try to enter the European emergency number (112) into the fax machine? Make sure your sound is on!",
  utf8   "Har du prövet at indtaste det europæriske alarm nummer (112) på fax maskinen? Husk at have lyd på!",
    --"You can adjust some settings such as the resolution and language in the options window found both in the main menu and ingame.",
   utf8  "Du kan ændre nogle indstillinger, som skærm oplösning og sprog i indstillingsvinduet som kan findes både i hoved menuen og inde i spillet",
    --"You selected a language other than English, but there's English text all over the place? Help us by translating missing texts into your language!",
  utf8   "Du har valgt et andet sprog end engelsk, men der er alligevel engelsk over det hele? Hjælp os med at oversætte teksten til dit sprog",
    --"The CorsixTH team is looking for reinforcements! Are you interested in coding, translating or creating graphics for CorsixTH? Contact us at our Forum, Mailing List or IRC Channel (corsix-th at freenode).",
  utf8   "Holdet bag CorsixTH er altid på udkig efter forskærkninger! Er du interesseret i kodning, oversættelse eller at lave grafik til CorsixTH? Kontakt os på vores forum, mailing liste eller IRC kanalen (corsix-th på freenode).",
    --"If you find a bug, please report it at our bugtracker: th-issues.corsix.org",
   utf8  "Hvis du finder en fejl, så kan du rapportere den til os på vores bugtracker: th-issues.corsix.org",
    --"Each level has certain requirements to fulfill before you can move on to the next one. Check the status window to see your progression towards the level goals.",
   utf8  "I hver runde er der forskellige krav der skal være opfyldt för du kan gå videre til den næste. Check status vinduet for at se din progression mod rundens mål",
    --"If you want to edit or remove an existing room, you can do so with the edit room button found in the bottom toolbar.",
  utf8   "Hvis du vil ændre eller fjerne eksiterende rum, kan du göre det ved at trykke på rediger rum knappen som findes i væktöjslinjen i bunden.",
   -- "In a horde of waiting patients, you can quickly find out which ones are waiting for a particular room by hovering over that room with your mouse cursor.",
  utf8   "I en gruppe af ventende patienter kan du hurtigt finde ud af hvilke der er i kö til et specifikt rum ved at bevæge musen kursören over rummet",
    --"Click on the door of a room to see its queue. You can do useful fine tuning here, such as reordering the queue or sending a patient to another room.",
  utf8   "Klik dören til et rum for at se dens kö. Her kan du lave brugbar tilpasning, som f.eks. sotere i köen eller sende patienter til et andet rum.",
    --"Unhappy staff will ask for salary rises frequently. Make sure your staff is working in a comfortable environment to keep that from happening.",
  utf8   "Galde medarbejdere vil oftere spöge efter lönforhöjelse. Husk at lave et komfortablet arbejdsmiljö for at holde dem glade.",
    --"Patients will get thirsty while waiting in your hospital, even more so if you turn up the heating! Place vending machines in strategic positions for some extra income.",
  utf8   "Patienter bliver törstige når de venter på dit hospital, og endnu mere hvis du skruer op for varmen! Placer drikke automater på strategiske steder for at ekstra indtægt",
    --"You can abort the diagnosis progress for a patient prematurely and guess the cure, if you already encountered the disease. Beware that this may increase the risk of a wrong cure, resulting in death for the patient.",
  utf8   "Du kan afbryde en patients diagnose proges för tid og gætte på en kur, hvis du allerede har mödt denne sygdom. Men pas på det kan betyde en forhöjet risiko for fejl diagonistiksering, som kan medföre en patients död.",
   -- "Emergencies can be a good source for some extra cash, provided that you have enough capacities to handle the emergency patients in time.",
  utf8 "Akuttilfælde kan være en god möde at få ekstra penge på, sålænge du har kapaciteten til at håndtere patienter fra akuttilfældet inden tiden löber ud.",
    },
  previous = "Forrige tip",
  next = utf8 "Næste tip",
}

tooltip.totd_window = {
  previous = "Vis det forrige tip",
  next = utf8 "Vis det næste tip",
}

-- All from here is done
menu = {
  file                = "  FILER  ",
  options             = "  INDSTILLINGER  ",
  display             = "  GRAFISKE INDSTILLINGER  ",
  charts              = "  SKEMAER  ",
  debug               = "  FEJLFINDING  ",
}

menu_file = {
  load                = utf8 "  INDLÆS  ",
  save                = "  GEM  ",
  restart             = "  START FORFRA  ",
  quit                = "  AFSLUT  ",
}

menu_file_load = {
  [1]              = "  Gemt spil 1  ",
  [2]              = "  Gemt spil 2  ",
  [3]              = "  Gemt spil 3  ",
  [4]              = "  Gemt spil 4  ",
  [5]              = "  Gemt spil 5  ",
  [6]              = "  Gemt spil 6  ",
  [7]              = "  Gemt spil 7  ",
  [8]              = "  Gemt spil 8  ",
}
menu_file_save = menu_file_load

menu_options = {
  sound               = "  LYD  ",
  announcements       = "  ANNONCERINGER  ",
  music               = "  MUSIK  ",
  sound_vol           = "  LYDSTYRKE  ",
  announcements_vol   = "  ANNONCERINGSSTYRKE  ",
  music_vol           = "  MUSIKSTYRKE  ",
  autosave            = "  AUTOMATISK GEM  ",
  game_speed          = "  SPIL HASTIGHED  ",
  jukebox             = "  JUKEBOX  ",
  edge_scrolling      = "  KANT SCROLLING  ",
  settings            = "  INDSTILLINGER  ",
}
menu_options = {
  lock_windows = utf8 "  LÅS VINDUER  ",
  edge_scrolling = "  KANT SCROLLING  ",
  settings = "  INDSTILLINGER  ",
}
  
menu_options_game_speed = {
  pause               = "  (P) PAUSE  ",
  slowest             = "  (1) LANGSOMMEST  ",
  slower              = "  (2) LANGSOMMERE  ",
  normal              = "  (3) NORMAL  ",
  max_speed           = "  (4) HURTIGST  ",
  and_then_some_more  = utf8 "  (5) OGSÅ LIGE LIDT MERE  ",
}  

menu_display = {
  high_res            = "  MANGE DETAILJER  ",
  mcga_lo_res         = utf8"  RIGTIGT FÅ DETAILJER  ",
  shadows             = "  SKYGGER  ",
}

menu_charts = {
  statement           = utf8 "  ERKLAERINGER  ",
  casebook            = "  MEDICINBOG  ",
  policy              = "  POLITIK  ",
  research            = "  FORSKNING  ",
  graphs              = "  DIAGRAMMER  ",
  staff_listing       = utf8 "  PERSONALEHÅNDTERING  ",
  bank_manager        = "  BANK KONSULENT  ",
  status              = "  STATUS  ",
  briefing            = "  BRIEFING  ",
}


casebook = {
  reputation           = utf8 "Omdömme",
  treatment_charge     = "Behandlingspris",
  earned_money         = utf8 "Indtjent",
  cured                = "Kureret",
  deaths               = utf8 "Dræbt",
  sent_home            = "Sendt hjem",
  research             = "Koncentrer forskning",
  cure                 = "Kur",
  cure_desc = {
    build_room         = "Jeg anbefalder du bygger %s", -- %s (room name)
    build_ward         = "Du mangler stadig at bygge en sygestue.",
    hire_doctors       = utf8 "Du mangler at hyre nogle læger",
    hire_surgeons      = "Du mangler at hyre kiruger.",
    hire_psychiatrists = "Du har ikke en psykiatiker.",
    hire_nurses        = "Du skal hyre sygeplejesker.",
    no_cure_known      = "Ingen kendt kur.",
    cure_known         = "Kur.",
    improve_cure       = "Forbedre kur.",
  },
}

staff_class = {
  nurse                 = "Sygeplejeske",
  doctor                = "Laege",
  handyman              = "Handyman",
  receptionist          = "Receptionist",
  surgeon               = "Kirug",
  -- S[1][6] unused
}

staff_title = {
  receptionist          = "Receptionist",
  general               = "Generel", -- unused?
  nurse                 = "Sygeplejeske",
  junior                = "Praktikant",
  doctor                = "Laege",
  surgeon               = "Kirug",
  psychiatrist          = "Psykiater",
  consultant            = "Konsulent",
  researcher            = "Forsker",
}
  
-- Staff descriptions
staff_descriptions = {
  good = {
    [1] = utf8 " Altid glad og en flittig arbejder.",
    [2] = utf8 " Meget pligtopfyldende. Meget omsorgsfuld.",
    [3] = utf8 " Er meget alsidig.",
    [4] = utf8 " Er venlig og altid i godt humör.",
    [5] = utf8 " Ekstremt udholdende. Löber en tur hver dag. ",
    [6] = utf8 " Utrolig höflig og er godt opdraget.",
    [7] = utf8 " Utrolig dygtig og talentfuld.",
    [8] = utf8 " Er meget opsat på at vise hvem han er.",
    [9] = utf8 " Er en perfektionist som aldrig giver op. ",
    [10] = utf8 " Hjælper altid patienter med et smil.",
    [11] = utf8 " Sjarmerende, höflig og hjælpsom.",
    [12] = utf8 " Er motiveret og dedikeret.",
    [13] = utf8 " Stille af natur, men arbejder meget.",
    [14] = utf8 " Loyal og venlig.",
    [15] = utf8 " Eftertænksom og er altid til at stole på i akutte tilfælde.",
  },
  misc = {
    [1] = utf8 " Spiller golf. ",
    [2] = utf8 " Dykker efter muslinger. ",
    [3] = utf8 " Laver is-skulpturer. ",
    [4] = utf8 " Drikker vin. ",
    [5] = utf8 " Körer rally. ",
    [6] = utf8 " Strikker i fritiden",
    [7] = utf8 " Samler på frimærker. ",
    [8] = utf8 " Elsker at stage-dive. ",
    [9] = utf8 " Elsker at surfe. ",
    [10] = utf8 " Elsker at undervise elever.",
    [11] = utf8 " Destillerer whisky. ",
    [12] = utf8 " Gör-det-selv ekspert. ",
    [13] = utf8 " Elsker franske kunstfilm. ",
    [14] = utf8 " Spiller meget Theme Park. ",
    [15] = utf8 " Har certifikat klasse C. ",
    [16] = utf8 " Deltager i motorcykelræs. ",
    [17] = utf8 " Spiller klassisk violin og cello. ",
    [18] = utf8 " Entusiastisk tog-förer. ",
    [19] = utf8 " Hundeelsker. ",
    [20] = utf8 " Hörer meget radio. ",
    [21] = utf8 " Bader ofte. ",
    [22] = utf8 " Instruktör i bambusfletning. ",
    [23] = utf8 " Laver figurer af grönsager. ",
    [24] = utf8 " Deltids minerydder. ",
    [25] = utf8 " Quizvært. ",
    [26] = utf8 " Samler på splinter fra 2.verdenskrig. ",
    [27] = utf8 " Elsker at indrette. ",
    [28] = utf8 " Hörer på rave og hip-hop musik. ",
    [29] = utf8 " Dræber insekter med deodorantspray. ",
    [30] = utf8 " Pifter af dårlige standupartister. ",
    [31] = utf8 " Stillet op til sygehusrådet. ",
    [32] = utf8 " Gartner med en hemmeligopskrift. ",
    [33] = utf8 " Smugler uægte malerier. ",
    [34] = utf8 " Vokalist i et rock'n'roll-band. ",
    [35] = utf8 " Elsker at se fjernsyn i dagtimerne. ",
    [36] = utf8 " Fisker efter örret. ",
    [37] = utf8 " Lurer på turister på museum. ",
  },
  bad = {
    [1] = utf8 " Langsom og anmasende. ",
    [2] = utf8 " Træt og meget lidt motivert. ",
    [3] = utf8 " Dårlig trænet og ubrugelig. ",
    [4] = utf8 " Dum i arbejde. Er en reserve. ",
    [5] = utf8 " Lav udholdenhed. Har en dårlig attitude. ",
    [6] = utf8 " Meget döv. Lugter af kål. ",
    [7] = utf8 " Er ligeglad med jobbet. Tager meget lidt ansvar. ",
    [8] = utf8 " Konsentrationsvanskligheder og bliver let distrahert. ",
    [9] = utf8 " Stresset og laver mange fejl. ",
    [10] = utf8 " Let at provokere. Sidder meget på en stol. ",
    [11] = utf8 " Uforsigtig og uheldig. ",
    [12] = utf8 " Bryder sig ikke om jobbet. Inaktiv. ",
    [13] = utf8 " Dumdristig og laver meget lidt. ",
    [14] = utf8 " Snu, udspekulert og bagtaler andre. ",
    [15] = utf8 " Arrogant og er en karl-smart. ",
  },
}   

pay_rise = {
  definite_quit = "Ligemeget hvad end du gör så kan du ikke beholde mig her, jeg er træt af det her sted!",
  regular = {
    utf8 "Jeg er helt udkört. Jeg har brug for hvile og en lönforhöjelse af  %d  ellers så skal du nok ikke forvente at se mig her mere.", -- %d (rise)
    utf8 "Jeg er så træt. Jeg har brug for hvile og en lönforhöjelse på %d, altså en lön på %d ialt. Gör det nu din tyran!", -- %d (rise) %d (new total)
    utf8 "Helt ærligt. Jeg arbejder ligesom en hund her! Giv mig en bonus på %d og jeg bliver i dit hospital.", -- %d (rise)
    utf8 "Jeg er pissesur. Jeg kræver en lönforhöjelse på %d, altså en lön på %d ialt, ellers så er jeg den der er skredet.", -- %d (rise) %d (new total)
    utf8 "Mine forældre fortalte mig at medicinal industrien betalte godt. Så giv mig en lönforhöjelse på %d ellers bliver jeg en video spils producent.", -- %d (rise)
    utf8 "Jeg gidder ikke mere. Betal mig en ordenlig lön. Jeg menes at en lönforhöjelse på %d ville hjælpe.", -- %d (rise)
  },
  poached = "Jeg er blevet tilbudt %d af %s. Ved mindre du betaler mig det samme så er jeg skredet.", -- %d (new total) %s (competitor)
}

-- VIPs.. hmm well ill add in my own funny translations for danish people lol.
vip_names = {
  health_minister = "Sundheds ministeren",
  "Bogmesteren fra Farum", -- A guy that liked to drink VERY expensive vine on the whole cities bill.
  "Prins Henrik",
  "Master fatman",
  "Anders Fogh",
  "Din nabo",
  "RobseRob",
  utf8 "A.P. MOLLER Mærsk",
  "En professionel fodbold spiller",
  "Lars larsen", -- Jysk sengetøjslager
  utf8 "Justin bæver",  -- Dont think i like him.. i hate him!
}

-- Credits. Lol no thanks.

-- Faxes here

-- Staff descriptions


dynamic_info = {
  patient = {
    actions = {
      dying                       = utf8 "Dör!",
      awaiting_decision           = utf8 "Venter på din beslutning",
      queueing_for                = utf8 "Er i kö til %s", -- %s
      on_my_way_to                = utf8 "På vej til %s", -- %s
      cured                       = "Kurered!",
      fed_up                      = utf8 "Har fået nok af det her sted!",
      sent_home                   = "Sendt hjem",
      sent_to_other_hospital      = "Sendt til andet hospital",
      no_diagnoses_available      = utf8 "Ingen dianogse tilgængelig - Jeg går hjem",
      no_treatment_available      = utf8 "Ingen kur tilgængelig - Jeg går hjem",
      waiting_for_diagnosis_rooms = utf8 "Venter på du bygger nogle diagnose faciliteter til mig.",
      waiting_for_treatment_rooms = utf8 "Venter på du bygger en behandlings klinik til mig.",
      prices_too_high             = utf8 "Dine priser er alt for höje - Jeg går hjem",
      epidemic_sent_home          = utf8 "Sendt hjem af inspektör",
      epidemic_contagious         = utf8 "Jeg er smitsom",
    },
    diagnosed                   = "Diagnosticeret: %s", -- %s
    guessed_diagnosis           = utf8 "Gættet diagnose: %s", -- %s
    diagnosis_progress          = "Diagnose fremgang",
    emergency                   = utf8 "Akuttilfælde: %t", -- %s (disease name)
  },
  vip                           = "VIP",
  health_inspector              = "Sundheds ministeren",
  
  staff = {
    psychiatrist_abbrev         = "Psykiat",
    actions = {
      waiting_for_patient         = utf8 "Venter på patient",
      wandering                   = utf8 "Går bare rundt",
      going_to_repair             = "På vej for at reperere: %s", -- %s (name of machine)
    },
    tiredness                   = "Friskhed",
    ability                     = "Evne", -- unused? Jep i think so.
  },
  
  object = {
    strength                    = "Styrke: %d", -- %d (max. uses)
    times_used                  = "Gange brugt: %d", -- %d (times used)
    queue_size                  = utf8 "Kö störrelse: %d", -- %d (num of patients)
    queue_expected              = utf8"Kö forventet: %d", -- %d (num of patients)
  },
}

progress_report = {
  header                = "Fremgangs raport",
  very_unhappy          = "Dine folk er ikke ret glade",
  quite_unhappy         = "Dine folk er rimeligt galde",
  more_drinks_machines  = utf8 "Köb flere drikkevare automater",
  too_hot               = utf8 "Få fixet dit opvarmnings system. Det er alt for varmt!",
  too_cold              = utf8 "Det er alt for koldt. Placer radiatore rundt omkring",
  percentage_pop        = "% befolkningen",
  win_criteria          = "KRITERIA FOR SUCCESS",
}

confirmation = {
  quit                 = utf8 "Du har valgt at afslutte, er du virkeligt sikker på du vil forlade spillet?",
  return_to_blueprint  = utf8 "Er du sikker på du vil returnere til arbejdstegningen?",
  replace_machine      = utf8 "Er du sikker på du vil erstatte %s for %d?", -- %s (machine name) %d (price)
  overwrite_save       = utf8 "Der er allerede et spil gemt på denne plads. Er du sikker på du vil overskrive det nuværende gemte spil?",
  delete_room          = "Vil du virkeligt slette dette rum?",
  sack_staff           = utf8 "Er du sikker på du vil fyre dette personale medlem?",
  restart_level        = utf8 "Er du sikker på du vil starte forfra med denne bane?",
}

bank_manager = {
  hospital_value    = utf8 "Hospitals værdi",
  balance           = "Saldo",
  current_loan      = utf8 "Nuværende lån",
  interest_payment  = "Renter",
  insurance_owed    = "Forsikringer skyldet", -- Is this even used in the game?
  inflation_rate    = "Inflations rate", -- Inflation rate.. never heard of that either.
  interest_rate     = "Rente rate",
  statistics_page = {
    date            = "Dato",
    details         = "Detailjer",
    money_out       = "Ud",
    money_in        = "Ind",
    balance         = "Saldo",
    current_balance = utf8 "Nuværende saldo",
  },
}

research = {
  categories = {
    cure            = "Kurerings udstyr",
    diagnosis       = "Diagnose udstyr",
    drugs           = "Medicin forskning",
    improvements    = "Forbedring",
    specialisation  = "Specialisering",
  },
  
  funds_allocation  = "Forsknings budget",
  allocated_amount  = "Totale budget",
}

policy = {
  header            = "Hospital politik",
  diag_procedure    = "Dianogse procedure",
  diag_termination  = utf8 "Dianogse annulæring",
  staff_rest        = utf8 "Send personale til afslapning",
  staff_leave_rooms = utf8 "Personale må forlade rum",
  
  sliders = {
    guess           = utf8 "GæT PÅ KUR", -- belongs to diag_procedure
    send_home       = "SEND HJEM", -- also belongs to diag_procedure
    stop            = "STOP PROCEDURE", -- belongs to diag_termination
    staff_room      = utf8 "TIL PERSONALERUM", -- belongs to staff_rest
  }
}

town_map = {
  -- S[13][ 1] -- unused
  chat         = "By detalje kort",
  for_sale     = "Til salg",
  not_for_sale = "Ikke til salg",
  number       = "Grund nummer", 
  owner        = "Grund ejer",
  area         = utf8 "Grund område",
  price        = "Grund pris",
}

place_objects_window = {
  drag_blueprint                = utf8 "Træk arbejdstegningen ud indtil du er tilfreds med störrelsen",
  place_door                    = utf8 "Placer dören",
  place_windows                 = "Placer nogle vinduer hvis du har lyst, klik derefter godkend",
  place_objects                 = "Placer objekterne indtil du er tilfreds, klik derefter godkend",
  confirm_or_buy_objects        = utf8 "Du kan godkende dette rum, köbe eller flytte objekterne",
  pick_up_object                = utf8 "Klik på objektet der skal samles op, eller vælg et andet i vælgeren",
  place_objects_in_corridor     = "Placer objekterne nede i en corridor",
}

graphs = {
  money_in   = utf8 "Indtægter",
  money_out  = utf8 "Udgifter",
  wages      = utf8 "Lönninger",
  balance    = "Saldo",
  visitors   = utf8 "Besögene",
  cures      = "Kurerede",
  deaths     = utf8 "Döde",
  reputation = utf8 "Omdömme",
  
  time_spans = {
    utf8 "1 år",
    utf8 "12 år",
    utf8 "48 år",
  }
}

transactions = {
  --null               = S[8][ 1], -- not needed
  wages                = utf8 "Lönninger",
  hire_staff           = "Hyring",
  buy_object           = utf8 "Köbt objekt",
  build_room           = "Bygget rum",
  cure                 = "Kureret",
  buy_land             = utf8 "Köbt grund",
  treat_colon          = "Behandlet:",
  final_treat_colon    = "Endelige behandling:",
  cure_colon           = "Kureret:",
  deposit              = utf8 "Behanlings insættelse",
  advance_colon        = "Forskud",
  research             = "Forsknings omkostninger",
  drinks               = utf8 "Indtægt: Drikkevarer",
  jukebox              = utf8 "Indtægt: Jukebox", -- unused
  cheat                = "Snyde penge",
  heating              = "Varmeregning",
  insurance_colon      = "Forsikring:",
  bank_loan            = utf8 "Bank lån",
  loan_repayment       = utf8 "Lån tilbagebetalning",
  loan_interest        = utf8 "Lån omkostninger",
  research_bonus       = "Forsknings bonus",
  drug_cost            = "Medicins omkostninger",
  overdraft            = utf8 "Overtræks omkostninger",
  severance            = utf8 "Böde",
  general_bonus        = "Generel bonus",
  sell_object          = "Solgt objekt",
  personal_bonus       = "Personlig bonus",
  emergency_bonus      = utf8 "Akuttilfælde bonus",
  vaccination          = "Vacinering",
  epidemy_coverup_fine = utf8 "Epidemy böde for forsög på skjulning",
  compensation         = "Kompensation",
  vip_award            = utf8 "VIP belönning",
  epidemy_fine         = utf8 "Epidemy böde",
  eoy_bonus_penalty    = utf8 "Slutning på året bonus/böde",
  eoy_trophy_bonus     = utf8 "Slutning på året trofæ bonus",
  machine_replacement  = "Skiftning af maskine",
}

rooms_short = {
  -- S[14][1] -- unused
  -- S[14][3] -- unused
  reception         = "Reception",
  destroyed         = utf8 "Ødelagt",
  corridor_objects  = "Korridor objekter",
  
  gps_office        = utf8 "Lægens kontor",
  psychiatric       = "Psykiateren",
  ward              = "Sygestuen",
  operating_theatre = "Operationsstuen",
  pharmacy          = "Apoteket",
  cardiogram        = utf8 "Löbetest",
  scanner           = "Scanner",
  ultrascan         = "Ultrascan",
  blood_machine     = "Blod maskine",
  x_ray             = utf8 "Röntgen",
  inflation         = "Pumperum",
  dna_fixer         = "DNA Fixer",
  hair_restoration  = utf8 "Hår genskaber",
  tongue_clinic     = "Tunge klinik",
  fracture_clinic   = "Knoglebrud klinik",
  training_room     = utf8 "Undervisningsrum",
  electrolysis      = "Elektrolyse",
  jelly_vat         = "Geléröret", -- Hmm. Donno if this is translateable
  staffroom         = utf8 "Personalerum",
  -- rehabilitation = S[14][24], -- unused, i laughed when i saw this though.. They didn't however get so stupid and include this in the game :P
  general_diag      = "General diagnose",
  research_room     = "Forsknings rum",
  toilets           = "Toiletter",
  decontamination   = "Dekontaminering",
}

rooms_long = {
  -- S[53][1] -- unused
  general           = "Generelt", -- unused?
  emergency         = utf8 "Akuttilfælde",
  corridors         = "Korridore",
  
  gps_office        = utf8 "Lægens kontor",
  psychiatric       = "Psykiateren",
  ward              = "Sygestuen",
  operating_theatre = "Operationsstuen",
  pharmacy          = "Apotektet",
  cardiogram        = utf8 "Löbetest rum",
  scanner           = "Scanner rum",
  ultrascan         = "Ultrascan rum",
  blood_machine     = "Blodmaskine rum",
  x_ray             = "Röntgen",
  inflation         = "Pumperum",
  dna_fixer         = "DNA Fixer",
  hair_restoration  = utf8 "Hår genskaber",
  tongue_clinic     = "Tunge klinik",
  fracture_clinic   = "Konglebrud klinik",
  training_room     = utf8 "Undervisningsrum",
  electrolysis      = "Elektolyse klinik",
  jelly_vat         = "Geléröret", -- Same as rooms short version
  staffroom         = utf8 "Personalerum",
  -- rehabilitation = S[53][24], -- unused
  general_diag      = "General diagnose",
  research_room     = "Forsknings rum",
  toilets           = "Toiletter",
  decontamination   = "Dekontaminering",
}

build_room_window = {
  -- S[16][1], -- unused
  pick_department   = utf8 "Vælg afdelning",
  pick_room_type    = utf8 "Vælg rumtype",
  cost              = "Pris:",
}

buy_objects_window = {
  choose_items      = utf8 "Vælg ting",
  price             = "Pris: ",
  total             = "Total: ",
}

room_classes = {
  -- S[19][1] -- unused
  -- S[19][2] -- "corridors" - unused for now
  -- S[19][3] -- unused
  diagnosis  = "Diagnose",
  treatment  = "Behandling",
  clinics    = "Klinikker",
  facilities = "Faciliteter",
}

staff_list = {
  -- S[24][1] unused
  -- S[24][2] -- I have no idea what this is. Me neiter, seems like a early stupid way of doing the text overlay?
  morale       = "MORAL",
  tiredness    = "FRISKHED",
  skill        = "KVALIFIKATION",
  total_wages  = utf8 "TOTAL LÖN",
}

high_score = {
  -- S[25][1] unused
  pos          = "POS",
  player       = "SPILLER",
  score        = "SCORE",
  best_scores  = "HALL OF FAME",
  worst_scores = "HALL OF SHAME",
  killed       = "DRÆBT", -- is this used? No its not.
  
  categories = {
    money             = "RIGESTE",
    salary            = utf8 "HÖJESTE LÖN",
    clean             = "RENESTE",
    cures             = "ANTAL KUREREDE",
    deaths            = utf8 "ANTAL DÖDSFALD",
    cure_death_ratio  = "KUREREING DÖDSFALDS RATIO",
    patient_happiness = "PATIENT TILFREDSHED",
    staff_happiness   = "PERSONALE TILFREDSHED",
    staff_number      = "MEST PERSONALE",
    visitors          = utf8 "FLEST BESÖGENE",
    total_value       = utf8 "TOTAL VÆRDI",
  },
}

object = {
  -- S[2][ 1] unused
  desk                  = "Skrivebord",
  cabinet               = "Arkivskab",
  door                  = utf8 "Dör",
  bench                 = utf8 "Bænk",
  table1                = "Bord", -- unused object
  chair                 = "Stol",
  drinks_machine        = "Sodavands automat",
  bed                   = "Seng",
  inflator              = "Inflator",
  pool_table            = "Pool bord",
  reception_desk        = "Receptions bord",
  table2                = "Bord", -- unused object & duplicate
  cardio                = utf8 "Löbebånd",
  scanner               = "Scanner",
  console               = "Konsol",
  screen                = utf8 "Skærm",
  litter_bomb           = "Affaldsbombe",
  couch                 = utf8 "Lænestol",
  sofa                  = "Sofa",
  crash_trolley         = utf8 "Lægebord",
  tv                    = "Fjernsyn",
  ultrascanner          = "Ultrascanner",
  dna_fixer             = "DNA Fixer",
  cast_remover          = "Gibs fjerner",
  hair_restorer         = utf8 "Hår genskaber",
  slicer                = "Slicer",
  x_ray                 = "Röntgen",
  radiation_shield      = "Radioaktivitets skjold",
  x_ray_viewer          = "Röntgen viser",
  operating_table       = "Operations bord",
  lamp                  = "Lampe", -- unused object
  toilet_sink           = "Toilet vask",
  op_sink1              = "Operations vask",
  op_sink2              = "Operations vask",
  surgeon_screen        = utf8 "Operations skærm",
  lecture_chair         = "Elev bord",
  projector             = "Projekter",
  bed2                  = "Seng", -- unused duplicate
  pharmacy_cabinet      = "Medicin skab",
  computer              = "Computer",
  atom_analyser         = "Atom analyser",
  blood_machine         = "Blod maskine",
  fire_extinguisher     = "Brandslukker",
  radiator              = "Radiator",
  plant                 = "Plante",
  electrolyser          = "Elektrolyser",
  jelly_moulder         = "gelé former",
  gates_of_hell         = "Helvedes gab",
  bed3                  = "Seng", -- unused duplicate
  bin                   = "Skraldespand",
  toilet                = "Toilet",
  swing_door1           = utf8 "Sving dör",
  swing_door2           = utf8 "Sving dör",
  shower                = "Bruser",
  auto_autopsy          = "Auto obduktion",
  bookcase              = "Boghylde",
  video_game            = "video spil",
  entrance_left         = "Indgang venstre",
  entrance_right        = utf8 "Indgang höjre",
  skeleton              = "Skelet",
  comfortable_chair     = "Komfortabel stol",
}

-- Todo
diseases = {
  general_practice       = { 
    name     = utf8 "Lægens kontor", 
  },
  bloaty_head        = { 
    name        = "Opsvulmet hoved", 
    cause       = utf8 "Årsag - Patienten har sniffet ost og drukket forurenet vand.", 
    symptoms    = "Symptomer - Den ramte har det meget ukomfortabelt.", 
    cure        = utf8 "Behandling - Der stikkes hul på det opsvulmede hoved, og ved hjælp af en genial maskine blir hovedet sat tilbage til den korekte PSI.", 
  },
  hairyitis              = { 
    name      = "Hairyitis", 
    cause     = utf8 "Årsag - Fuldmåne.", 
    symptoms  = "Symptomer - Forbedret lugtesans.", 
    cure      = utf8 "Behandling - En elektrolyse maskine fjerner håret og fortætter porene til deres normale stadie.", 
  },
  king_complex           = { 
    name     = "Konge komplekset", 
    cause     = utf8 "Årsag - Elivs' ånd har taget kontrollen over patienten", 
    symptoms   = utf8 "Symptomer - Går med farvede læder sko og spiser cheesebrugere", 
    cure     = utf8 "Behandling - En psykiater fortæller patienten hvor tåbelig han eller hun ser ud", 
  },
  invisibility           = { 
    name     = "Usynlighed", 
    cause     = utf8 "Årsag - Bidt af en radioaktiv (og usynlig) myre", 
    symptoms   = utf8 "Symptomer - Patienten lider ikke - tvært imod! De udnytter situationen og lurer på deres familie og venner!", 
    cure     = utf8 "Behandling - En farverig drik fra apoteket gör patienten fuldt synlig igen", 
  },
  serious_radiation      = { 
    name     = utf8 "Alvorlig stråling", 
    cause     = utf8 "Årsag - Har forvekslet plutonium-isotoper med tyggegummi.", 
    symptoms   = utf8 "Symptomer - Patienten föler sig meget ukomfortabel.", 
    cure     = utf8 "Behandling - Patienten blir placeret i en saniteringsbruser og renset fulldstændigt.", 
  },
  slack_tongue           = { 
    name     = utf8 "Lös tunge", 
    cause     = utf8 "Årsag - Kronisk overivrighed idiskusioner om sæbeopera.", 
    symptoms   = utf8 "Symptomer - Tungen hæver sig til det femdobbelte.", 
    cure     = utf8 "Behandling - Tungen blir placeret i en tungeskære. Hævelsen fjernes deretter hurtig, effektivt og smertefuldt.",
  },
  alien_dna              = { 
    name     = utf8 "Rumvæsen DNA", 
    cause     = utf8 "Årsag - Bidt af iler udstyret med intelligent rumvæsen blod.", 
    symptoms   = utf8 "Symptomer - Er under gradvis forvandling til et rumvæsen, og har et önske om at overtage planeten.", 
    cure     = utf8 "Behandling - Alt DNA blir fjernet mekanisk, renset for rumvæsen celler, og blir hurtig erstattet.",
  },
  fractured_bones        = { 
    name     = "Knogle brud",
    cause     = utf8 "Årsag - Fald fra höjder ned i beton.", 
    symptoms   = utf8 "Symptomer - Höje knaselyde og meget lidt bevægelighed på de udsatte steder.", 
    cure     = utf8 "Behandling - Gipsen bliver fjernet ved hjælp av en laserstyret gipsfjerner.", 
  },
  baldness               = { 
    name     = "Hårtab", 
    cause     = utf8 "Årsag - Fortæller lögne og opdigter historier for at forbedre sin popularitet.", 
    symptoms   = "Symptomer - Forlegen patient med skinnede panne.", 
    cure     = utf8 "Behandling - Håret bliver hurtigt smeltet fast til patients hoved med en smertefuld hårmaskin.",
  },
  discrete_itching       = { 
    name     = "Skrabesyge", 
    cause     = utf8 "Årsag - Små insekter med skarpe tænder.", 
    symptoms   = utf8 "Symptomer - Patienten klör intenst, og huden slår revner.", 
    cure     = utf8 "Behandling - En sygeplejeske giver patienten en sirupagtig drik som healer uden og som hindrer flere revner.",
  },
  jellyitis              = { 
    name     = utf8 "Gelésyndrom", 
    cause     = utf8 "Årsag - gelatinholdig kost og meget motion.", 
    symptoms   = utf8 "Symptomer - Meget ustabil og falder ofte.", 
    cure     = utf8 "Behandling - Patienten bliver presset ned i et gelérör i et specielt rum.",
  },
  sleeping_illness       = { 
    name     = utf8 "Sövnsyge", 
    cause     = utf8 "Årsag - Forsaget af overaktive sövnkitler i ganen.", 
    symptoms   = utf8 "Symptomer - Stærkt önke om at sove, hvor og når som helst.", 
    cure     = "Behandling - En stærk dose af stimulerende medicin uddelt af sygeplejsker.",
  },
  pregnancy              = { 
    name     = "Graviditet", 
    cause     = utf8 "Årsag - Forsaget af ström afbrydddelser i bebyggede områder", 
    symptoms   = utf8 "Symptomer - Træt af at spise med en konstant ölmave.", 
    cure     = "Behandling - Sprædbanet bliver fjernet ved kejsersnit og bliver derefter vasket og præsenteret for sin nye mor.",
  },   -- unused
  transparency           = { 
    name     = "Gennemsigtighed", 
    cause     = utf8 "Årsag - Slikket på foliet på gamle yougurtkatoner.", 
    symptoms   = "Symptomer - Kroppen bliver gennemsigtig og ækel.", 
    cure     = utf8 "Behandling - En kölig, farverige drink fra apoteket göre det trick.",
  },
  uncommon_cold          = { 
    name     = utf8 "Forkölelse",
    cause     = utf8 "Årsag - Små smörpartikler i luften.", 
    symptoms   = "Symptomer - Rendselse af næse, hoste og misfarvet slim fra lungerne.", 
    cure     = utf8 "Behandling - En rigtig stor mundfuld hostesaft fra apoteket kan göre det trick.", 
  },
  broken_wind            = { 
    name     = "Forurensende gasser", 
    cause     = utf8 "Årsag - Har löbt på en 3D mölle lige efter middag.", 
    symptoms   = "Symptomer - Ubehag hos folk som befinder sig lige bag patienten.", 
    cure     = utf8 "Behandling - En stærk blandning af specielle vandatomer der drikkes hurtigt.",
  },
  spare_ribs             = { 
    name     = "Spareribs", 
    cause     = utf8 "Årsag - Patienten har siddet sig på det kolde gulv.", 
    symptoms   = utf8 "Symptomer - Ubehagelig fölelse i brystet.", 
    cure     = "Behandling - Ribenene fjernes af to kirurger, og leveres til patienten i en doggybag.",
  },
  kidney_beans           = { 
    name     = "Kikærter", 
    cause     = utf8 "Årsag - patienten har spist isterninger.", 
    symptoms   = utf8 "Symptomer - Smerte og hyppige turer til toilettet", 
    cure     = utf8 "Behandling - To kirurger fjerner de ærteligende parasitter, uden at berörer nyerne!",
  },
  broken_heart           = { 
    name     = "Knust hjerte",
    cause     = utf8 "Årsag - Nogen er rigere, yngere og slakere end patienten.", 
    symptoms   = utf8 "Symptomer - Hysterisk grædende. Blodsprængte fingerspidser efter at have revet feriebilleder istykker.", 
    cure     = "Behandling - To kirurger sprætter brystet op og sætter deretter hjertet forsigtigt sammen, mens de holder pusten.", 
  },
  ruptured_nodules       = { 
    name     = utf8 "ödelagte nödder", 
    cause     = utf8 "Årsag - Skihop om vinteren.", 
    symptoms   = utf8 "Symptomer - Umulig at sætte ned med vedbehag.", 
    cure     = utf8 "Behandling - To kvalificerede kirurger må fjerne nödderne med forsigtige hænder.",
  },
  tv_personalities       = { 
    name     = "Programledersyndrom", 
    cause     = utf8 "Årsag - Ser TV i dagstimerne.", 
    symptoms   = utf8 "Symptomer - Forestiller sig at han/hun er programleder på formiddagstv og elsker at introducere madseancen", 
    cure     = utf8 "Behandling - En psykolog må overtale patienten til at köbe en radio og sælge fjernsynet.",
  },
  infectious_laughter    = { 
    name     = "Smidtsom latter", 
    cause     = utf8 "Årsag - klassisk komedie på TV.", 
    symptoms   = utf8 "Symptomer - Ler hjælpelöst hele tiden og gentager dårlige pasager som absolut ikke er morsomme.", 
    cure     = utf8 "Behandling - En kvalificeret psykolog må minde paitenten om at det faktisk er en alvorlig tilstand.",
  },
  corrugated_ankles      = { 
    name      = utf8 "Böjde anḱler", 
    cause     = utf8 "Årsag - Kört med bus over fartbump.", 
    symptoms   = "Symptomer - Sköne passer ikke.", 
    cure     = utf8 "Behandling - En giftig blanding af urter og kryderier må drikkes for at udrette anklerne.",
  },
  chronic_nosehair       = { 
    name     = utf8 "Kronisk næsehår", 
    cause     = utf8 "Årsag - Snöfter med forakt på folk med lavere indlægt.", 
    symptoms   = utf8 "Symptomer - Så mange næsehår at en grævling kunne bo der.", 
    cure     = utf8 "Behandling - En ækel hårfjernende kur som skal drikkes. Fåes på apoteket.",
  },
  third_degree_sideburns = { 
    name     = "Tredjegrads koteletter", 
    cause     = utf8 "Årsag - Længtes efter 70-erne.", 
    symptoms   = utf8 "Symptomer - Stort hår, op-montering töj, lange bakkenbarter og glitter.", 
    cure     = utf8 "Behandling - Psykologisk personel må, ved brug af moderne teknikker overbevise patienten om at parryk yt.",
  },
  fake_blood             = { 
    name     = "Teaterblod", 
    cause     = utf8 "Årsag - Patienten er ofte udsat for naresteger.", 
    symptoms   = utf8 "Symptomer - Rödt blod som fremkommer når der er kontakt med töj.", 
    cure     = utf8 "Behandling - Eneste måde at behandle dette på er at få en psykolog til at berolige patienten.",
  },
  gastric_ejections      = { 
    name     = utf8 "Sure opstöd", 
    cause     = utf8 "Årsag - Stærk krydret mexicansk eller indisk mad.", 
    symptoms   = "Symptomer - Gylper karrykylling og tarcostykker op..", 
    cure     = utf8 "Behandling - En sygeplejeske giver patienten speciel indisk komælk som forhindre sure opstöd.",
  },
  the_squits             = { 
    name     = utf8 "Tynd mage", 
    cause     = utf8 "Årsag - Har spist pizzastykker som har været på gulvet.", 
    symptoms   = utf8 "Symptomer - Uh. Tror du kender symptonerne.", 
    cure     = utf8 "Behandling - En klæbrig behandling af kemikalier der skal drilles for at stabilisere maven.",
  },
  iron_lungs             = { 
    name     = "Jernlunger", 
    cause     = utf8 "Årsag - Forurenet luft indeholdende bly og kebabrester.", 
    symptoms   = utf8 "Symptomer - Kan lave flammer og råbe höjlyt under vand.", 
    cure     = "Behandling - To kiruger blödgörer de hårde lunger på operationsstuen.",
  },
  sweaty_palms           = { 
    name     = utf8 "Svedige hænder", 
    cause     = utf8 "Årsag - Har lige været til jobinterview.", 
    symptoms   = utf8 "Symptomer - At give hånd til patienten er som at give hånd til en våd svamp.", 
    cure     = utf8 "Behandling - En psykolog der snakker med patienten om lidelsen.",
  },
  heaped_piles           = { 
    name     = "Hæmoroider", 
    cause     = utf8 "Årsag - Siddet forlænge på det kolde gulv.", 
    symptoms   = utf8 "Symptomer - Patienten föler at han/hun sidder på en pose sten.", 
    cure     = utf8 "Behandling - En behagelig, men syrlig væske som löser hæmorideproblemet.",
  },
  gut_rot                = { 
    name     = utf8 "Dårlig mave", 
    cause     = utf8 "Årsag - Onkel Georgs blanding af hostesaft og whisky.", 
    symptoms   = "Symptomer - Ingen hoste, men heller ingen magesæk.", 
    cure     = "Behandling - En sygeplejeske udskriver en række kemikalier som genskaber væggene i mavesækken.",
  },
  golf_stones            = { 
    name     = "Golfsteiner", 
    cause     = utf8 "Årsag - Udsat for giftige gasser fra golfbolde.", 
    symptoms   = utf8 "Symptomer - Forvirring og en kraftig skamfölelse.", 
    cure     = "Behandling - Stenene fjernes hurtigt og effektivt af to kirurger.",
  },
  unexpected_swelling    = { 
    name     = "Uventet hævelse", 
    cause     = utf8 "Årsag - Hvad som helst uventet.", 
    symptoms   = utf8 "Symptomer - Hævelse.", 
    cure     = utf8 "Behandling - Hævelsen må skæres bort af to kirurger.",
  },
  diag_scanner           = { name = "Diag Skanner", },
  diag_blood_machine     = { name = "Diag Blodmaskine", },
  diag_cardiogram        = { name = utf8 "Diag löbebånd", },
  diag_x_ray             = { name = utf8 "Diag Röntgen", },
  diag_ultrascan         = { name = "Diag Ultraskanner", },
  diag_general_diag      = { name = "Diag Generel", },
  diag_ward              = { name = "Diag Sengeafd.", },
  diag_psych             = { name = "Diag Psykiatri", },
  autopsy                = { name = "Obduktion", },
}

-- Competitor names skipped. No reason to localize them

-- Adviser not translated so far

-- Levelnames.. bleh. Such things should never get translated!

-- Drug companies.. lol funny to find out how much never vent into the game in the end.

-- Insurance companies.. Wow the game sure was going to be advanced!

-- Trophy room not translated so far

-- Multiplayer stuff.. well that will come when the time comes :D

-- Tooltips argh.

-- Newspaper stuff.. Bah thats non importent for now

months = {
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "Maj",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Okt",
  "Nov",
  "Dec",
}
   
misc = {
  grade_adverb = {
    mildly     = "Mildt",
    moderately = "Moderat",
    extremely  = "Ekstremt",
  },
  done  = utf8 "Færdig",
  pause = utf8 "Pause",
  
  send_message     = "Beskeden er sendt til: %d", -- %d (player number)
  send_message_all = "Beskeden er sendt til alle",
  
  save_success = "Gemt med success",
  save_failed  = "Mislykkedes at gemme",
  
  hospital_open = utf8 "Åbent hospital",
  out_of_sync   = "Spillet er ikke synkroniseret",
  
  load_failed  =  utf8 "Indlæsning fejlede",
  low_res      = utf8 "Lav oplösning",
  balance      = "Balance fil: ",
  
  mouse        = "Mus",
  force        = "Tvang",
}
    
    new_game_window = {
  easy = "Praktikant (Let)",
  medium = utf8 "Læge (Mellem)",
  hard = utf8 "Konsulent (Svær)",
  tutorial = "Gennemgang",
  cancel = "Annuller",
}


  -- Tooltips
tooltip = {
  
  
    -- Watch
  watch = {
    hospital_opening   = utf8 "Byggetid: Dette er tiden du har tilbage för hospitalet åbner. Klik på åben knappen for at åbne hospitalet med det samme.",
    emergency          = utf8 "Akkuttilfælde: Tiden som står er den tid du har tilbage til at behandle akkutte patienter.",
    epidemic           = utf8 "Epidemi: Tid til at fjerne epidemien. Når tiden er ude eller patienten forlader sygehuset, kommer der en sundhedsminister på besög. Knappen tænder og slukker for vaccinationstilstanden. Tryk på patienterne for at få en sygeplejeske til at vaccinere dem.",
  },
    
  -- Queue window, that describe what the different things dös. 
    queue_window = {
    num_in_queue       = utf8 "Antal patienter i köen",
    num_expected       = utf8 "Antal patienter som receptionen forventer der kommer i köen indenfor kort tiden",
    num_entered        = utf8 "Antal patienter som er blevet behandlet i dette rum indtil videre",
    max_queue_size     = utf8 "Den maksimale længde köen kan have",
    dec_queue_size     = utf8 "Mindre makslængde",
    inc_queue_size     = utf8 "Godkend makslængde",
    front_of_queue     = utf8 "Træk i en patient for at stille ham/hende forest i köen",
    end_of_queue       = utf8 "Træk i en patient for at stille ham/hende bagerst i köen",
    close              = "Luk vinduet",
    patient            = utf8 "Træk i en patient for at stille ham/hende i köen. Höjreklik på en patient for at sende patienten hjem eller til et konkurrende hospital",
    patient_dropdown = {
      reception        = "Send patienten til receptionen",
      send_home        = "Send patienten hjem",
      hospital_1       = "Henvis pasienten til et andet sygehus",
      hospital_2       = "Henvis pasienten til et andet sygehus",
      hospital_3       = "Henvis pasienten til et andet sygehus",
    },
  },
 
  -- Build room window
  build_room_window = {
    room_classes = {
      diagnosis        = utf8 "Vælg diagnoserum",
      treatment        = utf8 "Vælg generelle behandlingrum",
      clinic           = utf8 "Vælg specielle klinikker",
      facilities       = utf8 "Vælg faciliteter",
    },
    cost               = utf8 "Omkostninger for det pågælenderum",
    close              = utf8 "Afbryd processen og vend tilbage til spillet",
  },
  
  -- Toolbar
  toolbar = {
    bank_button        = "Venstreklik for bank konsulent, höjreklik for kontoudskrift",
    balance            = "Din Balance",
    reputation         = utf8 "Dit omdömme: ", -- NB: no %d! Append " ([reputation])".
    date               = "Dato",
    rooms              = "Byg rum",
    objects            = utf8 "Köb genstande",
    edit               = utf8"Ændre rum/genstande",
    hire               = utf8"Ansæt personale",
    staff_list         = utf8 "Personalhåndtering",
    town_map           = "Oversigtskort",
    casebook           = "Medicinbog",
    research           = "Forskning",
    status             = "Status",
    charts             = "Diagrammer",
    policy             = "Politik",
  },
  
    -- Staff list
  staff_list = {
    doctors            = utf8 "Se en oversigt over dine læger",
    nurses             = utf8 "Se en oversigt over dine sygeplejesker",
    handymen           = utf8 "Se en oversigt over dine handymænd",
    receptionists      = utf8 "Se en oversigt over dine receptionister",
    
    happiness          = utf8 "Viser hvordan humöret er på dine ansatte",
    tiredness          = utf8 "Viser hvor træt dine ansatte er",
    ability            = utf8 "Viser den ansattes evner",
    salary             = utf8 "Den pågældendes lön",
    
    happiness_2        = utf8 "Den ansattes moral",
    tiredness_2        = utf8 "Den ansattes træthedssniveau",
    ability_2          = utf8 "Den ansattes evner",
    
    prev_person        = utf8 "Vælg den forrige side",
    next_person        = utf8 "Vælg den næste side",
    
    bonus              = utf8 "Giv den ansatte 10% bonus",
    sack               = utf8 "Giv den ansatte sparket",
    pay_rise           = utf8 "Hæv den ansattes lön med 10%",
    
    close              = utf8 "Luk og vend tilbage til spillet",
    
    doctor_seniority   = utf8 "Lægens evner",
    detail             = utf8 "Lægens Kvalifikation",
    
    view_staff         = utf8 "Vis den ansatte på jobbet",
    
    surgeon            = utf8 "Kvalificeret Kirurg",
    psychiatrist       = utf8 "Kvalificeret Psykolog",
    researcher         = utf8 "Kvalificeret Forsker",
    surgeon_train      = utf8 "%d%% gennemfört uddannelse som kirurgi", -- %d (percentage trained)
    psychiatrist_train = utf8 "%d%% gennemfört uddannelse som psykologi", -- %d (percentage trained)
    researcher_train   = utf8 "%d%% gennemfört uddannelse som forskning", -- %d (percentage trained)
    
    skills             = "Ekstra evner",
  },
  
  -- Hire staff window
  hire_staff_window = {
    doctors            = utf8 "Vis læger som er tilgængelige på arbejdsmarkedet",
    nurses             = utf8 "Vis sygeplejesker som er tilgængelige på abejdsmarkedet",
    handymen           = utf8 "Vis handymænd som er tilgængelige på arbejdsmarket",
    receptionists      = utf8 "Vis receptionister som er tilgængelige på arbejdsmarkedet",
    prev_person        = utf8 "Vis forrige person",
    next_person        = utf8 "Vis næste person",
    hire               = utf8 "Ansæt person",
    cancel             = utf8 "Afbryd",
    doctor_seniority   = utf8 "Lægens evner (Praktikant, Doktor, Konsulent)",
    staff_ability      = utf8 "Kvalifikation",
    salary             = utf8 "Lön krav",
    qualifications     = utf8 "Lægens specialer",
    surgeon            = utf8 "Kirurg",
    psychiatrist       = utf8 "Psykolog",
    researcher         = utf8 "Forsker",
  },
    -- Rooms
  rooms = {
    gps_office         = utf8 "Patienterne får deres föste konsultation og tilhörende resultater fra lægenskontor",
    psychiatry         = utf8 "Psykiateren kurerer galde patienter og hjælper til med diagonistiksering af andre patienter, men har brug for en læge med psykiatri som speciale",
    ward               = utf8 "Sygestuen er nyttige både for diagnostisering og behandling. Patienter bliver sendt her til for at kunne blive observeret, men også får at komme sig oven på en operation. Sygestuen kræver en sygeplejeske",
    operating_theatre  = utf8 "Operationsstuen kræver to læger med speciale i kirugi",
    pharmacy           = utf8 "Sygeplejesken udskriver medicin på apoteket for at kurere patienter",
    cardiogram         = utf8 "En læge bruger löbebåndet til at diagostisere patienterne",
    scanner            = utf8 "En læge bruger scanneren til at diagostisere patienterne",
    ultrascan          = utf8 "En læge bruger ultrascanneren til at diagostisere patienterne",
    blood_machine      = utf8 "En læge bruger blodmaskinen til at diagostisere patienterne",
    x_ray              = utf8 "En læge bruger röntgen til at diagostisere patienterne",
    inflation          = utf8 "En læge bruger pumperummet til at behandle patienter med opsvulmet hoved",
    dna_fixer          = utf8 "En læge bruger DNA-Maskinen til at behandle patienter med Alien DNA",
    hair_restoration   = utf8 "En læge bruger hår genskaber til at behandle patienter med hår tab",
    tongue_clinic      = utf8 "En læge bruger tungeklinikken til at behandle patienter med lös tunge",
    fracture_clinic    = utf8 "En sygeplejeske bruger knoglebrudsklinikken til at samle benbrud",
    training_room      = utf8 "Et undervisningsrum med en konsulent kan bruges til at oplære andre læger",
    electrolysis       = utf8 "En læge bruger elektrolyseklinikken til at behandle patienter med Pelssyndrom",
    jelly_vat          = utf8 "En læge bruger geléröret til at behandle patienter med Gelésyndrom",
    staffroom          = utf8 "Læger, sygeplejesker og handymænd bruger personalerummet til at hvilke sig og for at hæve moralen",
    -- rehabilitation  = S[33][27], -- unused
    general_diag       = utf8 "En læge bruger lægens kontor til at stille den föste diagnose på patienten. Billigt og ofte meget effektivt",
    research_room      = utf8 "Læger med specialisering inden for forskning kan forske sig frem til nye mediciner og maskiner i forskningsavdelingen",
    toilets            = utf8 "Lav toiletter for at få patienterne til at stoppe med at snavse på hospitalet",
    decontamination    = utf8 "En læge bruger dekontaminering til at behandle patienter med radioaktiv stråling",
  },
  }
    introduction_texts = {
  level17 = {
    [1] = utf8 "Dette er sidste advarsel - hold öje med dit omdömme - det er det som tiltrækker patienter til dit sygehus. ",
    [2] = utf8 "Hvis der ikke er for mange patienter der dör og du samtidigt holder resten af patienterne i nogenlunde godt humör hvilket dette niveau ikke være noget problem.//",
    [3] = utf8 "Nu må du klare dig selv. Held og lykke!",
  },
  level1 = {
    [1] = utf8 "Velkommen til dit förste sygehus!//",
    [2] = utf8 "Kom godt i gang ved at få placeret en reception, bygge lægens kontor, samt ansætte en læge og en receptionist. ",
    [3] = utf8 "Vent derefter til ting begynder at ske.",
    [4] = utf8 "Det er et fornuftigt valg at bygge en psykiatri og ansætte en læge med special indenfor psykiatri. ",
    [5] = utf8 "Et apotek og en sygeplejeske er essentielt for at kurerer dine patienter. ",
    [6] = utf8 "Læg mærke til hvis der er mange tilfælde af opsvulmet hoved - et pumperum vil for det meste være til stor hjælp. ",
    [7] = utf8 "Du skal kurere mindst 10 patienter og sörge for at dit omdömme ikke kommer under 200 for at gennemföre runden.. ",
  },
  level9 = {
    [1] = utf8 "Efter at du har fyldt ministerens bankkonto op, og betalt for hans nye limousine, kan du nå koncentrere dig om at lave et omsorgsfuldt, velfungerende sygehus for de trængende. ",
    [2] = utf8 "Du må forvente at möde en række problemer her.",
    [3] = utf8 "Hvis du har nok af rum og flinke ansatte, vil du have styr på runden. ",
    [4] = utf8 "Dit sygehuset skal have en værdi af $200,000, og du skal have mindst $400,000 i banken. ",
    [5] = utf8 "Med mindre gennemförer du ikke runden.",
  },
  level2 = {
    [1] = utf8 "Der er store problemer med plager i dette område. ",
    [2] = utf8 "Byg sygehuset for at behandle flere patienter og anlæg en forskningsafdeling. ",
    [3] = utf8 "Husk at holde hospitalet rent og stræb efter at få et så höjt omdömme som muligt - Hvis du vil kunne håndtere sygedomme som lös tunge, så skal du bruge en tungeklinik. ",
    [4] = utf8 "Du kan også bygge et löbebånd for at forbedre diagostieringen. ",
    [5] = utf8 "Begge rum skal forskes fremtil för de kan bygges. Du kan udvide sygehuspladsen så du får mere plads at bygge på - Brug oversigtskortet til dette ",
    [6] = utf8 "Stræb efter at få et omdömme på 300 og en banksaldo på 10000, samt helbrede mindst 40 patienter. ",
  },
  --todo
  level7 = {
    [1] = utf8 "Her vil du være under overvågning af sundhedsministeriet så husk at få det til at se ud som om du tjener en masse penge og at dit omdömme er sky höjt. ",
    [2] = utf8 "Vi kan ikke holde til unödvendige dödsfald - de er dårlige for virksomheden. ",
    [3] = utf8 "Vær sikker på at dit personale er i tip-top form, og at du har alt det udstyr de har brug for. ",
    [4] = "Get a reputation of 600, plus $200,000 in the bank.",
  },
  level5 = {
    [1] = utf8 "Dette vil blive et travlt hospital, hvor du vil skulle håndtere en langrække sager. ",
    [2] = utf8 "Alle dine læger kommer direkte fra skolen, så det er vitalt at du får bygget et undervisningsrum og uddanner dem til de er på et acceptabelt niveau. ",
    [3] = utf8 "Du har kun tre konsulenter til at undervise dit uerfarende personale, så hold dem glade. ",
    [4] = utf8 "Hold for öje at hospitalet er bygget på San Androids geologiske undergrund. ",
    [5] = utf8 "Derfor er der en evig risiko for at der kommer jordskælv. ",
    [6] = utf8 "De vil lave betydlig skade på dine maskine og påvirke effektiviteten på dit hospital. ",
    [7] = utf8 "Få dit omdömme op på 400 og din bankbalance på $50,000 for at gennemföre. Du skal også helbrede 200 patienter.",
  },
  level4 = {
    [1] = utf8 "Hold alle dine patienter glade, få dem hurtigt gennem systemet og hold dödstallet så lav som muligt.",
    [2] = utf8 "Dit omdömme er på spil, sörg for at have et så godt omdömme som muligt.",
    [3] = utf8 "Lad vær med at fokusere for meget på pengene - det kommer altsammen når dit omdömme stiger. ",
    [4] = utf8 "Det vil være muligt for dig at træne dine læger, så de kan udvikle deres evner endnu mere.",
    [5] = utf8 "De kunne meget muligt være igang med patienter der er mindre trængende. ",
    [6] = utf8 "Opnå et omdömme der er over 500",
  },
  level14 = {
    [1] = utf8 "Der er lige en udfordring mere - det fuldstændige reagerlige hospital. ",
    [2] = utf8 "Hvis du opnår at dette bliver en succes, vil du være en mester af mestere. ",
    [3] = utf8 "Men forvent ikke at du kan tage den på rutinen, for dette er den stöste udfordring du nogensinde vil möde. ",
    [4] = utf8 "Held og lykke!",
  },
  level15 = {
    [1] = utf8 "Sådan, det er det mest basale som holder et hospital sammen.//",
    [2] = utf8 "Dine læger får brug får brug for al den hjælp de kan få til at diagostisere patienterne. Du kan hjælpe dig ved at",
    [3] = utf8 "bygge andre diagnose faciliteter så som et general diagnoserum.",
  },
  level8 = {
    [1] = utf8 "Det er up til dig at skabe det mest effektive og produktive hospital muligt. ",
    [2] = utf8 "Folk fra dette område er rimelig velhavende, så pres dem for så mange penge som muligt. ",
    [3] = utf8 "Husk, at helbrede folk er meget rart, men du har VIRKELIG BRUG FOR de penge det giver.",
    [4] = utf8 "Send disse syge mennesker til renseriet. ",
    [5] = utf8 "Opnå et massivt overskud på $300,000 for at gennemföre denne runde.",
  },
  level13 = {
    [1] = utf8 "Dine fantastiske evner til at administere et hospital er blevet bemærket af en speciel hemmelig afdeling under hemmelige specielle afdelinger. ",
    [2] = utf8 "De har en speciel bonus til dig; der er et rotteproblem på et hospital, som mangler en kærlig hånd. ",
    [3] = utf8 "Du skal skyde så mange rotter som muligt feor handymændene kan rydde op i skidtet. ",
    [4] = utf8 "Tror du at du kan klare opgaven?",
  },
  level16 = {
    [1] = utf8 "Når du har diagnostiseret nogle af patienterne, bliver du nödt til at bygge behandlingsfaciliteter og klinikker til at helbrede - en god en at starte med ",
    [2] = utf8 "er et apotek. Du skal bruge en sygeplejeske til at give de forskellige medica i apoteket.",
  },
  level6 = {
    [1] = utf8 "Brug al din viden til at velfungere og komfortabelt hospital som kan skabe et sundt overskud og kan håndtere alle former for sygdomme, som samfundet smider efter det. ",
    [2] = utf8 "Du skal være opmærksom på at den atmosfære her omkring, er perfekt til at bære infektioner og sygdomme. ",
    [3] = utf8 "Med mindre du holder dit hospital helt rent, så risikere du at der kommer epidemier blandt patienterne. ",
    [4] = utf8 "Opnå at du har tjent $150,000, og at dit hospital er mindst $140,000 værd.",
  },
  level12 = {
    [1] = utf8 "Du möder nu udfordringeren over dem alle. ",
    [2] = utf8 "Ministeriet er imponeret over dine succeser og har derfor et top-job til dig: De vil have dig til at bygge det ultimative hospital, hvor du skal tjene en pokkers masse penge og have et sky höjt omdömme. ",
    [3] = utf8 "Du er forventligt at du köber alle bygninger du kan, helbreder alle sygdomme (og vi mener alle!) og opnår rundens mål, samt priser. ",
    [4] = utf8 "Klar til udfordringen?",
    [5] = utf8 "Tjen $650,000, helbred 750 personer, og få et omdömme på 800 for at gennemföre runden.",
  },
  level3 = {
    [1] = utf8 "Du vil denne gang skulle bygge dit hospital i et velhavende kvarter. ",
    [2] = utf8 "Sundhedsministeriet holder öje med dig for at sikre at du skaber et overskud her. ",
    [3] = utf8 "Du vil starte med at have et godt omdömme, men så snart at hospitalet er åbent, skal du fokusere på at få tjent så mange penge som muligt. ",
    [4] = utf8 "Der er også en sandsynlighed for at der sker akuttilfælde. ",
    [5] = utf8 "Disse indeholder et stort antal patienter, som kommer samtidigt og har alle den samme sygdom. ",
    [6] = utf8 "Helbrede dem indenfor tidsbegrænsningen giver dig et godt omdömme, samt en stor bonus. ",
    [7] = utf8 "Sygdomme som konge komplekset kan forekomme og du burde bygge en operationsstue samt en sygestue i nærheden af. ",
    [8] = utf8 "Tjen $20,000 for at gennemföre.",
  },
  level10 = {
    [1] = utf8 "Så vel som at kunne behandle alle former for sygdomme vil sundhedsministeriet gerne have at du bruger noget tid på at foske i mediciners effekt. ",
    [2] = utf8 "Der har været nogle klager fra foreningen af syge, de syges vagthund. Så for holde sit omdömme skal du sörge for at dine medica er effektive. ",
    [3] = utf8 "Du skal også sikre dig at dit hospital er over gennemsnittet. Holder dödstallet så lavt som muligt",
    [4] = utf8 "Et lille tip er at du holder lidt frit plads til et geléör. ",
    [5] = utf8 "Udvikl alle dine medica til min. 80 effektivitet og få et omdömme på 650 og en bankbeholdning på $500,000 for at gennemföre. ",
  },
  level11 = {
    [1] = utf8 "Du har nu fået chancen for at bygge det ultimative hospital. ",
    [2] = utf8 "Dette er et ekstremt velhavende område, hvor sundhedsministeriet gerne vil sig at der kommer det bedste hospital muligt. ",
    [3] = utf8 "Vi forventer at du tjener kassen, har et sky höjt omdömme og håndtere alle uventede situationer. ",
    [4] = utf8 "Dette er en vigtig opgave",
    [5] = utf8 "Du skal være lavet af noget specielt for at dette skal lykkes. ",
    [6] = utf8 "Bemærk, at der har været set UFO'er i området. Så forbred dit personale på uventet besög. ",
    [7] = utf8 "Dit hospital skal være mindst $240,000, og du skal bruge mindst $500,000 i banken samt dit omdömme skal være på 700.",
  },
  level18 = {
  },     
      }    
     
  queue_window = {
  num_in_queue       = utf8 "Kölængde",
  num_expected       = "Forventet",
  num_entered        = utf8 "Antal besög",
  max_queue_size     = "Maks str.",
}
