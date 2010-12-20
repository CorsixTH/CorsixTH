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

menu_options_game_speed.pause = "  PAUSE  "

menu_debug = {
  transparent_walls           = utf8 "  TRANSPERANTE VÆGE  ",
  limit_camera                = utf8 "  BEGRÆNS CAMERAET  ",
  disable_salary_raise        = utf8 "  STOP LÖNFORHÖJELSER  ",
  make_debug_patient          = utf8 "  LAV FEJLFINDINGS PATIENT  ",
  spawn_patient               = utf8 "  GENERER TILFÆLDIG PATIENT  ",
  make_adviser_talk           = utf8 "  FÄ RÄDGIVEREN TIL AT SNAKKE  ",
  show_watch                  = "  VIS URET ",
  create_emergency            = "  LAV ET AKUTTILFÆLDE  ",
  place_objects               = "  PLACER OBJECTER  ",
  dump_strings                = "  DUMP TEXT  ",
  dump_gamelog                = "  DUMP SPILLOG  ",
  map_overlay                 = "  KORTOVERSIGT  ",
  sprite_viewer               = "  SPRITE VISER  ",
}
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
  tutorial = {
    utf8 "Velkommen til dit förste hospital!",
    utf8 "önsker du en kort guide af spillet?",
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
  th_directory = utf8 "CorsixTH har brug for en kopi af Theme Hospitals datafiler for at kunne fungere. Vælg venligst mappen hvori Theme Hispitals datafiler er placeret med vælgeren herunder.",
}

misc.not_yet_implemented = "(ikke implanteret endnu)"
misc.no_heliport = "Enten er der ikke blevet opdaget nogen sygdomme endnu, ellers er der ingen helicopter plads på denne bane."

main_menu = {
  new_game = "Nyt spil",
  custom_level = "Special bane",
  load_game = "Indlaes spil",
  options = utf8 "Indstillinger",
  exit = "Afslut",
}

tooltip.main_menu = {
  new_game = "Start et nyt spil fra begyndelsen",
  custom_level = "Lav dit eget sygehus i speciale baner",
  load_game = "Load et gemt spil",
  options = utf8 "Ændre dine indstillinger",
  exit = utf8 "Er du sikker på du ikke vil spille mere?",
}

load_game_window = {
  caption = "Indlaes spil",
}

tooltip.load_game_window = {
  load_game = "Indlaes spil %s",
  load_game_number = "Indlaes spil %d",
  load_autosave = "Indlaes autogem",
}

custom_game_window = {
  caption = "Special bane",
}

tooltip.custom_game_window = {
  start_game_with_name = "Indlaes banen %s",
}

save_game_window = {
  caption = "Gem spil",
  new_save_game = "Nyt gem",
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
  load_prefix = "Fejl under indlaesning af spil: ",
  map_file_missing = "Kunne ikke finde kort filen %s for denne bane!",
  minimum_screen_size = utf8 "Indtast venligst en oplösning på mindst 640x480.",
}

confirmation = {
  needs_restart = utf8 "Skiftning af denne indstilling kræver genstart af CorsixTH. Alle ugemte datær går tabt. Er du sikker på du vil göre dette?"
}

information = {
  custom_game = "Velkommen til CorsixTH. Hav det sjovt med denne special bane!",
  cannot_restart = utf8 "Beklageligvis så er denne special bane lavet för at genstart funtionen blev implanteret.",
  level_lost = {
    utf8 "Ej! Du har desvære tabt banen. Bedre held næste gang!",
  },
}

tooltip.information = {
  close = "Luk informations dialogen",
}
-- I translatet these tips that show up on the main menu screen //froksen
totd_window = {
  tips = {
    utf8 "I et hvert hospital er det nödvendigt have et receptions bord og lægens kontor for at komme i gang. Herefter er det alt efter hvilke patienter der kommer til dit hospital, dog er et apotek altid et fornuftigt valg.",
    utf8 "Maskiner, som f.eks. inflation, har brugt for vedligeholdelse. Ansæt en handyman eller to til at vedligeholde dine maskiner, ellers kan du risikere at dine ansatte eller patienter kommer til skade",
    utf8  "Med tiden bliver dine ansatte trætte. Husk at bygge et personale rum så de kan slappe af.",
    utf8   "Placer radiatorer så dine patienter og ansatte kan holde varmen, ellers bliver de galde. Brug by kortet til at lokalisere steder på dit hospital som skal være varmere.",
    utf8   "En læges kvalifikationsniveau betyder meget for kvaliteten og hastighedsen på hans diagnoser. Hvis du placer en meget kvalificeret læge pa lægens kontor behöver du ikke så mange ekstra diagonise rum.",
    --Juniors and doctors can improve their skills by learning from a consultant in the training room. If the consultant has a special qualification (surgeon, psychiatrist or researcher), he will also pass on this knowledge to his pupil(s).
    utf8  "Juniorer og læger kan forbedre deres kvalifikationer ved at blive undervist af en konsulent i et træningsrum. Hvis konsulenten har specielle kvalifikationer (Kirug, psykiater eller forsker) vil han også give disse kvalifikationer videre til sine elever.",
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
    utf8 "Akuttilfælde kan være en god møde at få ekstra penge på, sålænge du har kapaciteten til at håndtere patienter fra akuttilfældet inden tiden löber ud.",
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
  load                = utf8 "  INDLAES  ",
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
  lock_windows = "  FASTLAAS VINDUER  ",
  edge_scrolling = "  EDGE SCROLLING  ",
  settings = "  INDSTILLINGER  ",
}
menu_options_game_speed.pause = "  PAUSE  "

menu_options_game_speed = {
  slowest             = "  LANGSOMMEST  ",
  slower              = "  LANGSOMMERE  ",
  normal              = "  NORMAL  ",
  max_speed           = "  HURTIGST  ",
  and_then_some_more  = utf8 "  OGSÅ LIGE LIDT MERE  ",
}

menu_display = {
  high_res            = "  MANGE DETAILJER  ",
  mcga_lo_res         = utf8"  RIGTIGT FÅ DETAILJER  ",
  shadows             = "  SKYGGER  ",
}

menu_charts = {
  statement           = "  ARGOMENTER  ",
  casebook            = "  SAGSBOG  ",
  policy              = "  POLITIK  ",
  research            = "  FORSKNING  ",
  graphs              = "  GRAFER  ",
  staff_listing       = "  PERSONALET  ",
  bank_manager        = "  BANK MANAGER  ",
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
    hire_doctors       = "Du mangler at hyre nogle laeger",
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
  junior                = "Junior",
  doctor                = "Laege",
  surgeon               = "Kirug",
  psychiatrist          = "Psykiater",
  consultant            = "Konsulent",
  researcher            = "Forsker",
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

queue_window = {
  num_in_queue       = utf8 "Kø størrelse",
  num_expected       = "Forudset",
  num_entered        = utf8 "Besøgstal",
  max_queue_size     = utf8 "Maksimal kø størrelse",
}

dynamic_info = {
  patient = {
    actions = {
      dying                       = utf8 "Dør!",
      awaiting_decision           = utf8 "Venter på din beslutning",
      queueing_for                = utf8 "Er i kø til %s", -- %s
      on_my_way_to                = utf8 "På vej til %s", -- %s
      cured                       = "Kurered!",
      fed_up                      = utf8 "Har fået nok af det her sted!",
      sent_home                   = "Sendt hjem",
      sent_to_other_hospital      = "Sendt til andet hospital",
      no_diagnoses_available      = utf8 "Ingen dianogse tilgængelig - Jeg går hjem",
      no_treatment_available      = utf8 "Ingen kur tilgængelig - Jeg går hjem",
      waiting_for_diagnosis_rooms = utf8 "Venter på du bygger nogle diagnose faciliteter til mig.",
      waiting_for_treatment_rooms = utf8 "Venter på du bygger en behandlings klinik til mig.",
      prices_too_high             = utf8 "Dine priser er alt for høje - Jeg går hjem",
      epidemic_sent_home          = utf8 "Sendt hjem af inspektør",
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
    queue_size                  = utf8 "Kø størrelse: %d", -- %d (num of patients)
    queue_expected              = utf8"Kø forventet: %d", -- %d (num of patients)
  },
}

progress_report = {
  header                = "Fremgangs raport",
  very_unhappy          = "Dine folk er ikke ret glade",
  quite_unhappy         = "Dine folk er rimeligt galde",
  more_drinks_machines  = utf8 "Köb flere drikkevare automater",
  too_hot               = utf8 "Få fixet dit opvarmnings system. Det er alt for varmt!",
  too_cold              = utf8 "Det er alt for koldt. Placer radiatore rundt omkring.",
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
  ward              = "Sygetuen",
  operating_theatre = "Operationsstuen",
  pharmacy          = "Apoteket",
  cardiogram        = utf8 "Löbetest",
  scanner           = "Scanner",
  ultrascan         = "Ultrascan",
  blood_machine     = "Blod maskine",
  x_ray             = "Xray",
  inflation         = "Inflation",
  dna_fixer         = "DNA Fixer",
  hair_restoration  = utf8 "Hår restorere",
  tongue_clinic     = "Tunge klinik",
  fracture_clinic   = "Knoglebrud klinik",
  training_room     = utf8 "Trænings lokale",
  electrolysis      = "Elektrolyse",
  jelly_vat         = "Jelly vat", -- Hmm. Donno if this is translateable
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
  x_ray             = "Xray rum",
  inflation         = "Inflation rum",
  dna_fixer         = "DNA Fixer",
  hair_restoration  = utf8 "Hår restorere",
  tongue_clinic     = "Tunge klinik",
  fracture_clinic   = "Konglebrud klinik",
  training_room     = utf8 "Trænings rum",
  electrolysis      = "Elektolyse klinik",
  jelly_vat         = "Jelly vat", -- Same as rooms short version
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
  hair_restorer         = utf8 "Hår restorere",
  slicer                = "Slicer",
  x_ray                 = "Xray",
  radiation_shield      = "Radioaktivitets skjold",
  x_ray_viewer          = "Xray viser",
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
  jelly_moulder         = "Budings former",
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
    name     = "Konge komplexet", 
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
    name     = "Skrapesyke", 
    cause     = utf8 "Årsag - Små insekter med skarpe tenner.", 
    symptoms   = utf8 "Symptomer - Pasienten klör intenst, og huden flasser.", 
    cure     = utf8 "Behandling - En sykepleier gir pasienten en sirupaktig drikk som leger huden og hindrer videre klöe.",
  },
  jellyitis              = { 
    name     = utf8 "Gelésyndrom", 
    cause     = utf8 "Årsag - Gelatinrik diett og for mye mosjon.", 
    symptoms   = utf8 "Symptomer - Meget ustödig og faller mye.", 
    cure     = utf8 "Behandling - Pasienten blir presset ned i en gelétönne i et spesielt rom.",
  },
  sleeping_illness       = { 
    name     = utf8 "Søvnsyge", 
    cause     = utf8 "Årsag - Forsaget af overaktive søvnkitler i ganen.", 
    symptoms   = utf8 "Symptomer - Stærkt önke om at sove, hvor og når som helst.", 
    cure     = "Behandling - En stærk dose af stimulerende medicin uddelt af sygeplejsker.",
  },
  pregnancy              = { 
    name     = "Graviditet", 
    cause     = utf8 "Årsag - Forsaget af strömbrud i Forårsaket av strömbrudd i bebyggede områder", 
    symptoms   = utf8 "Symptomer - Træt af at spise med en konstant ølmave.", 
    cure     = "Behandling - Sprædbanet bliver fjernet ved kejsersnit og bliver derefter vasket og præsenteret for sin nye mor.",
  },   -- unused
  transparency           = { 
    name     = "Gennemsigtighed", 
    cause     = utf8 "Årsag - Slikket på foliet på gamle yougurtkatoner.", 
    symptoms   = "Symptomer - Kroppen bliver gennemsigtig og ækel.", 
    cure     = utf8 "Behandling - En kölig, farverige drink fra apoteket gøre det trick.",
  },
  uncommon_cold          = { 
    name     = utf8 "Forkölelse",
    cause     = utf8 "Årsag - Små smörpartikler i luften.", 
    symptoms   = "Symptomer - Rendselse af næse, hoste og misfarvet slim fra lungerne.", 
    cure     = utf8 "Behandling - En rigtig stor mundfuld hostesaft fra apoteket kan gøre det trick.", 
  },
  broken_wind            = { 
    name     = "Forurensende gasser", 
    cause     = utf8 "Årsag - Har løbt på en 3D mølle lige efter middag.", 
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
    cure     = utf8 "Behandling - To kirurger fjerner de ærteligende parasitter, uden at berører nyerne!",
  },
  broken_heart           = { 
    name     = "Knust hjerte",
    cause     = utf8 "Årsag - Nogen er rigere, yngere og slakere end patienten.", 
    symptoms   = utf8 "Symptomer - Hysterisk grædende. Blodsprængte finderspidser efter at have revet feriebilleder istykker.", 
    cure     = "Behandling - To kirurger sprætter brystet op og sætter deretter hjertet forsigtigt sammen, mens de holder pusten.", 
  },
  ruptured_nodules       = { 
    name     = utf8 "Oedelagte noedder", 
    cause     = utf8 "Årsag - Skihop om vinteren.", 
    symptoms   = utf8 "Symptomer - Umulig at sætte ned med vedbehag.", 
    cure     = utf8 "Behandling - To kvalificerede kirurger må fjerne noedderne med forsigtige hænder.",
  },
  tv_personalities       = { 
    name     = "Programledersyndrom", 
    cause     = utf8 "Årsag - Ser TV i dagstimerne.", 
    symptoms   = utf8 "Symptomer - Forestiller sig at han/hun er programleder på formiddagstv og elsker at introducere madseancen", 
    cure     = utf8 "Behandling - En psykolog må overtale patienten til at koebe en radio og sælge fjernsynet.",
  },
  infectious_laughter    = { 
    name     = "Smidtsom latter", 
    cause     = utf8 "Årsag - klassisk komedie på TV.", 
    symptoms   = utf8 "Symptomer - Ler hjælpeloest hele tiden og gentager dårlige pasager som absolut ikke er morsomme.", 
    cure     = utf8 "Behandling - En kvalificeret psykolog må minde paitenten om at det faktisk er en alvorlig tilstand.",
  },
  corrugated_ankles      = { 
    name      = utf8 "Boejde anḱler", 
    cause     = utf8 "Årsag - Koert med bus over fartbump.", 
    symptoms   = "Symptomer - Skoene passer ikke.", 
    cure     = utf8 "Behandling - En giftig blanding af urter og kryderier må drikkes for at udrette anklerne.",
  },
  chronic_nosehair       = { 
    name     = utf8 "Kronisk næsehår", 
    cause     = utf8 "Årsag - Snoefter med forakt på folk med lavere indlægt.", 
    symptoms   = utf8 "Symptomer - Så mange næsehår at en grævling kunne bo der.", 
    cure     = utf8 "Behandling - En ækel hårfjernende kur som skal drikkes. Fåes på apoteket.",
  },
  third_degree_sideburns = { 
    name     = "Tredjegrads koteletter", 
    cause     = utf8 "Årsag - Længtes efter 70-erne.", 
    symptoms   = utf8 "Symptomer - Stort hår, op-montering toej, lange bakkenbarter og glitter.", 
    cure     = utf8 "Behandling - Psykologisk personel må, ved brug af moderne teknikker overbevise patienten om at parryk yt.",
  },
  fake_blood             = { 
    name     = "Teaterblod", 
    cause     = utf8 "Årsag - Patienten er ofte udsat for naresteger.", 
    symptoms   = utf8 "Symptomer - Roedt blod som fremkommer når der er kontakt med toej.", 
    cure     = utf8 "Behandling - Eneste måde at behandle dette paa er at få en psykolog til at berolige patienten.",
  },
  gastric_ejections      = { 
    name     = utf8 "Sure opstoed", 
    cause     = utf8 "Årsag - Stærk krydret mexicansk eller indisk mad.", 
    symptoms   = "Symptomer - Gylper karrykylling og tarcostykker op..", 
    cure     = utf8 "Behandling - En sygeplejeske giver patienten speciel indisk komælk som forhindre sure opstød.",
  },
  the_squits             = { 
    name     = utf8 "Lös mage", 
    cause     = utf8 "Årsag - Har spist pizzabiter som har falt bak komfyren.", 
    symptoms   = utf8 "Symptomer - æsj. Tipper du vet symptomene.", 
    cure     = utf8 "Behandling - En klebig blanding kjemikalier må drikkes for å stabilisere magen innvendig.",
  },
  iron_lungs             = { 
    name     = "Jernlunger", 
    cause     = utf8 "Årsag - Forurenset byluft blandet med kebabrester.", 
    symptoms   = utf8 "Symptomer - Kan puste flammer og bröle höyt under vann.", 
    cure     = "Behandling - To kirurger mykner de solide lungene i operasjonssalen.",
  },
  sweaty_palms           = { 
    name     = utf8 "Håndsvette", 
    cause     = utf8 "Årsag - Er livredd jobbintervjuer.", 
    symptoms   = utf8 "Symptomer - Å håndhilse på pasienten er som å ta tak i en våt svamp.", 
    cure     = utf8 "Behandling - En psykolog må snakke pasienten ut av denne oppdiktede lidelsen.",
  },
  heaped_piles           = { 
    name     = "Hemoroider", 
    cause     = utf8 "Årsag - Står i nærheten av drikkevannskjölere.", 
    symptoms   = utf8 "Symptomer - Pasienten föler han/hun sitter på en pose med stein.", 
    cure     = utf8 "Behandling - En behagelig, men meget syrlig drikk, lösner opp hemoroidene innenifra.",
  },
  gut_rot                = { 
    name     = utf8 "Mageråte", 
    cause     = utf8 "Årsag - Onkel Georgs miks av hostesaft og whisky.", 
    symptoms   = "Symptomer - Ingen hoste, men ingen magesekk heller.", 
    cure     = "Behandling - En sykepleier skriver ut en rekke kjemikalier og gjenskaper veggen i magesekken.",
  },
  golf_stones            = { 
    name     = "Golfsteiner", 
    cause     = utf8 "Årsag - Utsatt for giftige gasser fra golfballer.", 
    symptoms   = utf8 "Symptomer - Forvirring og kraftig skamfölelse.", 
    cure     = "Behandling - Steinene fjernes kjapt og effektivt av to kirurger.",
  },
  unexpected_swelling    = { 
    name     = "Uventet hevelse", 
    cause     = utf8 "Årsag - Hva som helst uventet.", 
    symptoms   = "Symptomer - Hevelse.", 
    cure     = utf8 "Behandling - Hevelsen må skjæres bort av to kirurger.",
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
  
  load_failed  = "Indlaesning fejlede",
  low_res      = utf8 "Lav oplösning",
  balance      = "Balance fil: ",
  
  mouse        = "Mus",
  force        = "Tvang",
}
    
new_game_window = {
  easy = "Junior (Let)",
  medium = "Laege (Mellem)",
  hard = "Konsulent (Svaer)",
  tutorial = "Gennemgang",
  cancel = "Annuller",
}
