--[[ 
Copyright (c) 2010 Robin Madsen (RobseRob)
Copyright (c) 2010-2011 Ole Frandsen (Froksen)
Copyright (c) 2011 Rene Bergfort (Kleeze)

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
-------------------------------------------------------------------------------

This danish translation is based apon the Norwegian file by Erlend Mongstad. I have changed it
so that is match the formating of the norwegian file. Danish translations is done by the danish team.
Mostly Robin Madsen (RobseRob) or by Ole Frandsen (Froksen). Please read Mongstads description 
of how the formating is done. 

Since the norwegian/DANISH language isn't in the original Theme Hospital game, this 
file is split in two sections (A and B). The first section contains all the new 
language strings, made by the Corsix-TH team, and the second section contains 
the override translation of all the original english strings.

FORMATING AND NORWEGIAN/DANISH LETTERS
This file contains UTF-8 text. Make sure your editor is set to UTF-8. For the 
norwegian/danish letters ø and Ø, you must use the old-style ö and Ö instead. That is 
because the letters ø and Ø is not included in the original ingame-font.



-------------------------------------------------------------------------------
    Table of Contents
-------------------------------------------------------------------------------
 
 -- SECTION A - NEW STRINGS

   1. Global settings
   2. Faxes
   3. Objects
   4. Menu
   5. Adviser
   6. Dynamic info
   7. Tooltip
   8. Cheats
   9. Dispatcher
 -- SECTION B - OLD STRINGS (OVERRIDE)
 
   Huge section with all original strings, translated from english.



-----------------------------------------------------------------------------]]


-------------------------------------------------------------------------------
--   SECTION A - NEW STRINGS
-------------------------------------------------------------------------------

-- 1. Global setings (do not edit!)
Language("Dansk", "Danish", "da", "dk")
Inherit("english")

date_format = {
  daymonth = "%1% %2:months%",
}

-- 2. Faxes
fax = {
  choices = {
    return_to_main_menu = "Tilbage til hovedmenuen",
    accept_new_level = utf8 "Gå videre til næste bane",
    decline_new_level = utf8 "Spil videre lidt endnu",
  },
}

letter = {
  dear_player = utf8 "Kære %s",
  custom_level_completed = utf8 "Godt arbejde! Du har opfyldt alle mål på denne speicalbane!",
  return_to_main_menu = utf8 "Vil du gå tilbage til hovedmenuen eller fortsætte med at spille?",
}
  

install = {
  title = "--------------------------------- CorsixTH Installation ---------------------------------",
  th_directory = utf8 "CorsixTH kræver en original installation af Theme Hospital for at fungere. Angiv placeringen af spillet her.",
  exit = "Afslut",
}

-- 3. Objects
object = {
  litter               = utf8 "Skrald",
}

tooltip.fax.close = utf8 "Luk dette vindue uden at fjerne beskeden"
tooltip.message.button = utf8 "Venstreklik for at læse faxen"
tooltip.message.button_dismiss = utf8 "Venstreklik for at åbne faxen.Höjreklik for at ignorere den"

-- 4. Menu 
menu_options = {
  lock_windows = utf8 "  LÅS VINDUER  ",
  edge_scrolling = "  KANTSCROLLING  ",
  settings = "  INDSTILLINGER  ",
}

menu_options_game_speed.pause   = "  PAUSE  "

-- The demo does not contain this string
menu_file.restart = "  START FORFRA  "

menu_debug = {
  jump_to_level               = utf8 "  Gå til bane  ",
  transparent_walls           = utf8 "  (K) Gennemsigtige VæGE  ",
  limit_camera                = utf8 "  BEGRæNS KAMERAET  ",
  disable_salary_raise        = utf8 "  STOP LÖNFORHÖJELSER  ",
  make_debug_fax              = "  (F8) LAV FEJLFINDINGS FAX  ",
  make_debug_patient          = utf8 " (F9) LAV FEJLFINDINGS PATIENT  ",
  spawn_patient               = utf8 "  GENERER TILFæLDIG PATIENT  ",
  make_adviser_talk           = utf8 "  FÄ RÄDGIVEREN TIL AT SNAKKE  ",
  show_watch                  = "  VIS URET ",
  create_emergency            = utf8 "  LAV ET AKUTTILFæLDE  ",
  place_objects               = "  PLACER OBJEKTER  ",
  cheats                      = "  (F11) SNYD  ",
  lua_console                 = "  (F12) LUA KONSOL  ",
  calls_dispatcher            = utf8 "  KALD På AFSENDER  ",
  dump_strings                = "  DUMP TEKT  ",
  dump_gamelog                = "  (CTRL + D) DUMP SPILLOG  ",
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

-- 5. Adviser
adviser = {
  room_forbidden_non_reachable_parts = "Hvis du placerede rummet her, ville det resultere i, at dele af dit hospital ikke ville være tilgængelige.",

  cheats = {  
    th_cheat = utf8 "Tillykke, du har nu muligheden for at snyde",
    crazy_on_cheat = utf8 "åh nej! Alle lægerne er blevet sköre!",
    crazy_off_cheat = utf8 "Puha... Alle lægerne er blevet normale igen.",
    roujin_on_cheat = utf8 "Roujin's udfordring er blevet aktiveret! Held og lykke...",
    roujin_off_cheat = utf8 "Roujin's udfordring deaktivateret.",
    hairyitis_cheat = utf8 "Skaldethed snydekoden er aktivateret!",
    hairyitis_off_cheat = utf8 "Skaldethed snydekoden deaktivateret.",
    bloaty_cheat = utf8 "Opsvulmet hoved snydekoden deaktivateret.!",
    bloaty_off_cheat = utf8 "Opsvulmet hoved snydekoden deaktivateret.",
  },
}

  
-- 6. Dynamic info
dynamic_info.patient.actions.no_gp_available = utf8 "Venter på du bygger en lægekonsultation"
dynamic_info.staff.actions.heading_for = "På vej til %s"
dynamic_info.staff.actions.fired = "Fyret"

-- 7. Tooltip
tooltip.research_policy.no_research = utf8 "Der forskes ikke på nuværrende tidspunkt i dette område"
tooltip.research_policy.research_progress = utf8 "Fremskidtet mod den næste opdagelse indenfor dette område: %1%/%2%"
tooltip.objects.litter = utf8 "Skrald: Smidt af dine patienter, da de ikke kunne finde en skraldespand"
-- Misc
misc.not_yet_implemented = "(ikke implanteret endnu)"
misc.no_heliport = "Enten er der ikke blevet opdaget nogle sygdomme endnu, ellers er der ingen helikopterplads på denne bane."

-- Main menu
main_menu = {
  new_game = "Nyt spil",
  custom_level = "Specialbane",
  load_game = utf8 "Indlæs spil",
  options = utf8 "Indstillinger",
  exit = "Afslut",
}

tooltip.main_menu = {
  new_game = "Start et nyt spil fra begyndelsen",
  custom_level = "Lav dit eget sygehus på en specialbane",
  load_game = utf8 "Indlæs et gemt spil",
  options = utf8 "Juster dine indstillinger",
  exit = utf8 "Er du sikker på, at du ikke vil spille mere?",
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
  caption = "Specialbane",
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
  width = "Bredde",
  height = utf8 "Höjde",
  change_resolution = utf8 "Skift oplösning",
  browse = "Gennemse",
  new_th_directory = utf8 "Her kan du specificere en ny installationsmappe for Theme Hospital. Så snart du har gjort det vil spillet genstarte.",
  cancel = "Annullér",
  back = "Tilbage",
}
  
tooltip.options_window = {
  fullscreen_button = utf8 "Klik for at skifte imellem fuldskærmsvisning",
  width = utf8 "Indtast den önskede skærmbrede",
  height = utf8 "Indtast den önskede skærmhöjde",
  change_resolution = utf8 "Skift skærmstörrelsen til dimmensionerne indtastet til höjre",
  language = utf8 "Vælg %s som sprog",
  original_path = "Theme Hospitals mappe",
  browse = "Gennemse et andet sted for installation af Theme Hospital",
  back = "Luk indstillingsvinduet",
}

new_game_window = {
  easy = "Praktikant (Let)",
  medium = utf8 "Læge (Mellem)",
  hard = utf8 "Konsulent (Svær)",
  tutorial = "Oplæring",
  cancel = "Annuller",
}

tooltip.new_game_window = {
  easy = "Hvis du ikke har erfaring med simulationsspil, er dette niveau det rette",
  medium = utf8 "Hvis du er usikker på hvad du skal vælge, er dette niveau en mellemting",
  hard = utf8 "Hvis du er sikker på dine evner og önsker udfordring, bör du vælge denne.",
  tutorial = utf8 "Hvis du önsker lidt hjælp til at komme godt igang, skal du mærkere denne boks.",
  cancel = utf8 "Hmm... Var det ikke meningen, at du ville starte et nyt spil?!",
}

lua_console = {
  execute_code = utf8 "Kör",
  close = "Luk",
}

tooltip.lua_console = {
  textbox = utf8 "Skriv den Lua-kode du vil köre her",
  execute_code = utf8 "Kör koden",
  close = "Luk konsollen",
}

errors = {
dialog_missing_graphics = "Undskyld, men demo datafilerne har ikke en tekst.",
  save_prefix = "Fejl under gem af spil: ",
  load_prefix = utf8 "Fejl under indlæsning af spil: ",
  map_file_missing = "Kunne ikke finde kort filen %s for denne bane!",
  minimum_screen_size = utf8 "Indtast en oplösning på mindst 640x480.",
   maximum_screen_size = utf8 "Indtast en oplösning på maksimalt 3000x2000.",
  unavailable_screen_size = utf8 "Skærmoplösningen du valgte er ikke tilgængelig i fuldskærmsvisning.",
}

confirmation = {
  needs_restart = utf8 "Hvis du vil benytte disse indstillinger, så kræver det en genstart af CorsixTH. Spil, som ikke er gemt, vil gå tabt. Er du sikker på, at du vil bruge disse indstillinger?",
  abort_edit_room = utf8 "Du er ved at opbygge eller ændre et lokale. Hvis alle obligatoriske genstande er placeret, kan du gemme lokalet. Hvis ikke, skal du slette rummet. Fortsætte?",
  restart = utf8 "Er du sikker på at du vil pröve på ny?",
}
confirmation.restart_level = "Er du sikker på at du vil begynde forfra?"
  
information = {
  custom_game = "Velkommen til CorsixTH. Hav det sjovt med denne specialbane!",
  cannot_restart = utf8 "Beklageligvis er denne specialbane lavet för genstartfuntionen blev implanteret.",
level_lost = {
    utf8 "Öv! Du gennemförte ikke banen. Bedre held næste gang!",
    "Derfor tabte du:",
    reputation = utf8 "Dit omdömme var under %d.",
    balance = utf8 "Din bankbalance var under %d.",
    percentage_killed = utf8 "Du har dræbt mere end %d procent af patienterne.",
  },
  }
tooltip.information = {
  close = "Luk informationsvinduet",
}

totd_window = {
  tips = {
    utf8 "I ethvert hospital er det nödvendigt at have en reception og en lægekonsultation for at komme i gang. Herefter er det, alt efter hvilke patienter der ankommer til dit hospital, op til dig at bygge de nödvendige rum - et apotek er dog altid godt at have.",
    utf8 "Maskiner, som for eksempel pumperum, har brug for vedligeholdelse. Ansæt en pedel eller to til at vedligeholde dine maskiner, ellers kan du risikere, at dine ansatte eller patienter kommer til skade.",
   utf8  "Med tiden bliver dine ansatte trætte. Husk at bygge et personalerum, så de kan slappe af.",
  utf8   "Placer radiatorer så dine patienter og ansatte kan holde varmen, ellers bliver de sure. Brug oversigtskortet til at lokalisere områder i dit hospital, som bör være varmere.",
  utf8   "En læges kvalifikationsniveau betyder meget for hastigheden og kvaliteten af hans diagnosticering. Hvis du placerer en meget kvalificeret læge i en lægekonsultation, behöver du ikke så mange yderligere diagnoserum.",
    --Juniors and doctors can improve their skills by learning from a consultant in the training room. If the consultant has a special qualification (surgeon, psychiatrist or researcher), he will also pass on this knowledge to his pupil(s).
   utf8  "Praktikanter og læger kan forbedre deres kvalifikationer ved at blive undervist af en konsulent i et undervisningslokale. Hvis konsulenten har specielle kvalifikationer (kirurg, psykiater eller forsker), vil han også give disse kvalifikationer videre til sine elever.",
   -- "Did you try to enter the European emergency number (112) into the fax machine? Make sure your sound is on!",
  utf8   "Har du prövet at indtaste det europæriske alarmnummer (1-1-2) på faxmaskinen? Husk at have lyd slået til!",
    --"You can adjust some settings such as the resolution and language in the options window found both in the main menu and ingame.",
   utf8  "Du kan ændre nogle indstillinger, såsom skærmoplösning og sprog, i indstillingsvinduet som findes både i hovedmenuen og inde i spillet.",
    --"You selected a language other than English, but there's English text all over the place? Help us by translating missing texts into your language!",
  utf8   "Du har valgt et andet sprog end engelsk, men der er alligevel engelsk over det hele? Hjælp os med at oversætte teksten til dit sprog.",
    --"The CorsixTH team is looking for reinforcements! Are you interested in coding, translating or creating graphics for CorsixTH? Contact us at our Forum, Mailing List or IRC Channel (corsix-th at freenode).",
  utf8   "Holdet bag CorsixTH er altid på udkig efter forskærkninger! Er du interesseret i kodning, oversættelse eller at lave grafik til CorsixTH? Så kontakt os på vores forum, mailingliste eller IRC kanalen (corsix-th på freenode).",
    --"If you find a bug, please report it at our bugtracker: th-issues.corsix.org",
   utf8  "Hvis du finder en fejl kan du rapportere den til os på vores bugtracker: th-issues.corsix.org",
    --"Each level has certain requirements to fulfill before you can move on to the next one. Check the status window to see your progression towards the level goals.",
   utf8  "På hver bane er der forskellige betingelser, som skal være opfyldt för du kan gå videre til den næste bane. Hold öje med statusvinduet for at se, hvor tæt du på at opfylde banens mål.",
    --"If you want to edit or remove an existing room, you can do so with the edit room button found in the bottom toolbar.",
  utf8   "Hvis du vil ændre eller fjerne eksisterende lokaler, kan du göre det ved at trykke på rediger lokale knappen som findes i væktöjslinjen i bunden af skærmen.",
   -- "In a horde of waiting patients, you can quickly find out which ones are waiting for a particular room by hovering over that room with your mouse cursor.",
  utf8   "I en gruppe af ventende patienter kan du hurtigt finde ud af, hvilke der er i kö til et specifikt rum, ved at bevæge musen over rummet.",
    --"Click on the door of a room to see its queue. You can do useful fine tuning here, such as reordering the queue or sending a patient to another room.",
  utf8   "Klik på dören til et rum for at se dens kö. Her kan du lave brugbar tilpasning, som for eksempel sortere i köen eller sende patienter til et andet rum.",
    --"Unhappy staff will ask for salary rises frequently. Make sure your staff is working in a comfortable environment to keep that from happening.",
  utf8   "Utilfredse medarbejdere vil oftere bede om lönforhöjelse. Husk at lave et komfortablet arbejdsmiljö for at holde dem tilfredse.",
    --"Patients will get thirsty while waiting in your hospital, even more so if you turn up the heating! Place vending machines in strategic positions for some extra income.",
  utf8   "Patienter bliver törstige mens de venter på, specielt hvis der er meget varmt på dit hospital! Placer drikkeautomater på strategiske steder for lidt ekstra indkomst.",
    --"You can abort the diagnosis progress for a patient prematurely and guess the cure, if you already encountered the disease. Beware that this may increase the risk of a wrong cure, resulting in death for the patient.",
  utf8   "Du kan afbryde en patients diagnoseproces för tid og gætte på en kur, hvis du allerede har opdaget denne sygdom tidligere. Men pas på! Det kan betyde en forhöjet risiko for fejldiagnosticering, som kan medföre patientens död.",
   -- "Emergencies can be a good source for some extra cash, provided that you have enough capacities to handle the emergency patients in time.",
  utf8 "Akuttilfælde kan være en god mulighed for at tjene lidt ekstra penge, så længe du har kapaciteten til at håndtere patienter fra akuttilfældet inden tiden löber ud.",
    },
  previous = "Forrige tip",
  next = utf8 "Næste tip",
}

tooltip.totd_window = {
  previous = "Vis det forrige tip",
  next = utf8 "Vis det næste tip",
}
  
    tooltip.cheats_window = {
  close = utf8 "Lukker dialogen",
  cheats = {
    money = utf8 "Overförer 10.000 til din bankkonto.",
    all_research = utf8 "Du har forsket alt.",
    emergency = utf8 "Skaber et akkuttilfælde.",
    create_patient = utf8 "Skaber en patient ved udkanten af kortet.",
    end_month = utf8 "Går til slutningen af måneden.",
    end_year = utf8 "Går til slutningen af året",
    lose_level = utf8 "Du taber banen.",
    win_level = utf8 "Du vinder banen.",
  },
 }  
  
-- Cheats
  cheats_window = {
  caption = utf8 "Snyd",
  warning = utf8 "Advarsel: Det vil ikke være muligt at få bonuspoint ved slutningen af banen hvis du snyder!",
  cheated = {
    no = utf8 "Brugt snyd: Nej",
    yes = utf8 "Brugt snyd: Ja",
  },
  cheats = {
    money = utf8 "Snyd med penge",
    all_research = utf8 "Alt er forsket",
    emergency = utf8 "Skab et akkuttilfælde",
    create_patient = utf8 "Lav en patient",
    end_month = utf8 "Afslut måneden",
    end_year = utf8 "Afslut året",
    lose_level = utf8 "Tab runden",
    win_level = utf8 "Vind runden",
  },
  close = "Luk",
}  

-- dispatcher
    calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = "%d kalder; %d tildelt",
  staff = "%s - %s",
  watering = "Vander @ %d,%d",
  repair = "Reparerer %s",
  close = "Luk",
}


-------------------------------------------------------------------------------
--   SECTION B - OLD STRINGS (OVERRIDE)
-------------------------------------------------------------------------------

-- Staff class
-- each of these corresponds to a sprite
staff_class = {
  nurse                 = "Sygeplejerske",
  doctor                = "Læge",
  handyman              = "Pedel",
  receptionist          = "Receptionist",
  surgeon               = "Kirurg",
}

-- Staff titles
-- these are titles used e.g. in the dynamic info bar
staff_class = {
  nurse                 = "Sygeplejerske",
  doctor                = "Læge",
  handyman              = "Pedel",
  receptionist          = "Receptionist",
  surgeon               = "Kirurg",
  -- S[1][6] unused
}

staff_title = {
  receptionist          = "Receptionist",
  general               = "Generel", -- unused?
  nurse                 = "Sygeplejerske",
  junior                = "Praktikant",
  doctor                = "Læge",
  surgeon               = "Kirurg",
  psychiatrist          = "Psykiater",
  consultant            = "Konsulent",
  researcher            = "Forsker",
}

-- Pay rises
pay_rise = {
  definite_quit = "Jeg er ligeglad med, hvad du tilbyder mig. Jeg er træt af det her sted!",
  regular = {
    utf8 "Jeg er helt udkört. Jeg har brug for hvile og en lönforhöjelse på  %d, ellers skal du nok ikke forvente at se mere til mig.", -- %d (rise)
    utf8 "Jeg er så træt. Jeg har brug for hvile og en lönforhöjelse på %d, altså en lön på %d ialt. Gör det nu, din tyran!", -- %d (rise) %d (new total)
    utf8 "Helt ærligt. Jeg arbejder som en hund på dit hospital! Giv mig en bonus på %d så bliver jeg på dit hospital.", -- %d (rise)
    utf8 "Jeg er pissesur. Jeg kræver en lönforhöjelse på %d, altså en lön på %d ialt, ellers så er jeg den der er skredet.", -- %d (rise) %d (new total)
    utf8 "Mine forældre fortalte mig, at medicinalindustrien betalte godt. Så giv mig en lönforhöjelse på %d ellers bliver jeg videospilsproducent.", -- %d (rise)
    utf8 "Jeg gider ikke mere. Betal mig en ordenlig lön. En lönforhöjelse på %d skulle klare det.", -- %d (rise)
  },
  poached = "Jeg er blevet tilbudt %d af %s. Med mindre du betaler mig det samme er jeg skredet.", -- %d (new total) %s (competitor)
}

-------------------- Her til er kigget igennem // Froksen
-- Staff descriptions
staff_descriptions = {
  good = {
    [1] = utf8 "Altid glad og en flittig medarbejder.",
    [2] = utf8 "Meget pligtopfyldende. Meget omsorgsfuld.",
    [3] = utf8 "Er meget alsidig.",
    [4] = utf8 "Er venlig og altid i godt humör.",
    [5] = utf8 "Ekstremt udholdende. Löber en tur hver dag. ",
    [6] = utf8 "Utrolig höflig og er godt opdraget.",
    [7] = utf8 "Utrolig dygtig og talentfuld.",
    [8] = utf8 "Er meget opsat på at vise, hvem han er.",
    [9] = utf8 "Er en perfektionist som aldrig giver op. ",
    [10] = utf8 "Hjælper altid patienter med et smil.",
    [11] = utf8 "Charmerende, höflig og hjælpsom.",
    [12] = utf8 "Er motiveret og dedikeret.",
    [13] = utf8 "Stille af natur, men arbejder meget.",
    [14] = utf8 "Loyal og venlig.",
    [15] = utf8 "Eftertænksom og er altid til at stole på i akutte tilfælde.",
  },
  misc = {
    [1] = utf8 " Spiller golf. ",
    [2] = utf8 " Dykker efter muslinger. ",
    [3] = utf8 " Laver is-skulpturer. ",
    [4] = utf8 " Drikker vin. ",
    [5] = utf8 " Körer rally. ",
    [6] = utf8 " Strikker i fritiden",
    [7] = utf8 " Samler på frimærker. ",
    [8] = utf8 " Elsker at hoppe ned fra scener til publikums begejstring. ",
    [9] = utf8 " Elsker at surfe. ",
    [10] = utf8 " Elsker at undervise elever.",
    [11] = utf8 " Brænder selv sin whisky. ",
    [12] = utf8 " Gör-det-selv ekspert. ",
    [13] = utf8 " Elsker franske kunstfilm. ",
    [14] = utf8 " Spiller meget Theme Park. ",
    [15] = utf8 " Har stort körekort. ",
    [16] = utf8 " Deltager i motorcykelræs. ",
    [17] = utf8 " Spiller klassisk violin og cello. ",
    [18] = utf8 " Entusiastisk tog-förer. ",
    [19] = utf8 " Hundeelsker. ",
    [20] = utf8 " Hörer meget radio. ",
    [21] = utf8 " Bader ofte. ",
    [22] = utf8 " Instruktör i bambusfletning. ",
    [23] = utf8 " Laver figurer af gröntsager. ",
    [24] = utf8 " Deltids minerydder. ",
    [25] = utf8 " Quizvært. ",
    [26] = utf8 " Samler på splinter fra 2.Verdenskrig. ",
    [27] = utf8 " Elsker at indrette. ",
    [28] = utf8 " Danser til rave og hip-hop musik. ",
    [29] = utf8 " Dræber insekter med deodorantspray. ",
    [30] = utf8 " Buher af dårlige komikere. ",
    [31] = utf8 " Stillet op til sygehusrådet. ",
    [32] = utf8 " Gartner med en hemmelig opskrift. ",
    [33] = utf8 " Smugler uægte malerier. ",
    [34] = utf8 " Vokalist i et rock'n'roll-band. ",
    [35] = utf8 " Elsker at se fjernsyn i dagtimerne. ",
    [36] = utf8 " Fisker efter örret. ",
    [37] = utf8 " Lurer på turister på museum. ",
  },
  bad = {
    [1] = utf8 "Langsom og anmasende. ",
    [2] = utf8 "Træt og meget lidt motiveret. ",
    [3] = utf8 "Dårlig trænet og ubrugelig. ",
    [4] = utf8 "Dum i arbejde. Er en reserve. ",
    [5] = utf8 "Lav udholdenhed. Har en dårlig attitude. ",
    [6] = utf8 "Meget döv. Lugter af kål. ",
    [7] = utf8 "Er ligeglad med jobbet. Tager meget lidt ansvar. ",
    [8] = utf8 "Lider af koncentrationsbesvær og bliver let distraheret. ",
    [9] = utf8 "Stresset og laver mange fejl. ",
    [10] = utf8 "Let at provokere. Sidder meget på en stol. ",
    [11] = utf8 "Uforsigtig og uheldig. ",
    [12] = utf8 "Utroværdig og ubeslutsom. ",
    [13] = utf8 "Dumdristig og laver meget lidt. ",
    [14] = utf8 "Snu, udspekuleret og bagtaler andre. ",
    [15] = utf8 "Arrogant og er en karl-smart. ",
  },
}   

-- Staff list
staff_list = {
  -- S[24][1] unused
  -- S[24][2] -- I have no idea what this is. Me neiter, seems like a early stupid way of doing the text overlay?
  morale       = "MORAL",
  tiredness    = "FRISKHED",
  skill        = "KVALIFIKATION",
  total_wages  = utf8 "TOTAL LÖN",
}

-- Objects
object = {
  -- S[2][ 1] unused
  desk                  = "Skrivebord",
  cabinet               = "Arkivskab",
  door                  = utf8 "Dör",
  bench                 = utf8 "Bænk",
  table1                = "Bord", -- unused object
  chair                 = "Stol",
  drinks_machine        = "Sodavandsautomat",
  bed                   = "Seng",
  inflator              = "Inflator",
  pool_table            = "Billiardbord",
  reception_desk        = "Receptionsbord",
  table2                = "Bord", -- unused object & duplicate
  cardio                = utf8 "Löbebånd",
  scanner               = "Skanner",
  console               = "Konsol",
  screen                = utf8 "Skærm",
  litter_bomb           = "Affaldsbombe",
  couch                 = utf8 "Lænestol",
  sofa                  = "Sofa",
  crash_trolley         = utf8 "Lægebord",
  tv                    = "Fjernsyn",
  ultrascanner          = "Ultraskanner",
  dna_fixer             = "DNA Fixer",
  cast_remover          = "Gibsfjerner",
  hair_restorer         = utf8 "Hårgenskaber",
  slicer                = "Tungeskærer",
  x_ray                 = "Röntgen",
  radiation_shield      = "Radioaktivitetsskjold",
  x_ray_viewer          = "Röntgenviser",
  operating_table       = "Operationsbord",
  lamp                  = "Lampe", -- unused object
  toilet_sink           = "Vask",
  op_sink1              = "Operationsvask",
  op_sink2              = "Operationsvask",
  surgeon_screen        = utf8 "Operationsskærm",
  lecture_chair         = "Undervisningsstol",
  projector             = "Projektor",
  bed2                  = "Seng", -- unused duplicate
  pharmacy_cabinet      = "Medicinskab",
  computer              = "Computer",
  atom_analyser         = "Atomanalyser",
  blood_machine         = "Blodmaskine",
  fire_extinguisher     = "Brandslukker",
  radiator              = "Radiator",
  plant                 = "Plante",
  electrolyser          = "Elektrolyser",
  jelly_moulder         = "Gelé former",
  gates_of_hell         = "Helvedes gab",
  bed3                  = "Seng", -- unused duplicate
  bin                   = "Skraldespand",
  toilet                = "Toilet",
  swing_door1           = utf8 "Svingdör",
  swing_door2           = utf8 "Svingdör",
  shower                = "Bruser",
  auto_autopsy          = "Auto obduktion",
  bookcase              = "Bogreol",
  video_game            = "videospil",
  entrance_left         = "Indgang venstre",
  entrance_right        = utf8 "Indgang höjre",
  skeleton              = "Skelet",
  comfortable_chair     = "Komfortabel stol",
}

-- Place objects window
place_objects_window = {
  drag_blueprint                = utf8 "Træk skitsen ud indtil du er tilfreds med rummets störrelse.",
  place_door                    = utf8 "Vælg dörens placering.",
  place_windows                 = "Placer de vinduer du har lyst til, klik derefter på godkend.",
  place_objects                 = "Placer genstandene indtil du er tilfreds, klik derefter på godkend.",
  confirm_or_buy_objects        = utf8 "Godkend rummet, köb flere genstande, eller flyt allerede placerede genstande.",
  pick_up_object                = utf8 "Klik på genstanden der skal samles op, eller vælg en anden i menuen.",
  place_objects_in_corridor     = "Placer genstanden i et gangareal.",
}

-- Competitor names
-- No need to translate!! //froksen

-- Months
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

-- Graphs
graphs = {
  money_in   = utf8 "Indtægter",
  money_out  = utf8 "Udgifter",
  wages      = utf8 "Lönninger",
  balance    = "Saldo",
  visitors   = utf8 "Besögene",
  cures      = "Helbredte",
  deaths     = utf8 "Döde",
  reputation = utf8 "Omdömme",
  
  time_spans = {
    utf8 "1 år",
    utf8 "12 år",
    utf8 "48 år",
  }
}

-- Transactions
transactions = {
  --null               = S[8][ 1], -- not needed
  wages                = utf8 "Lönninger",
  hire_staff           = "Ansat",
  buy_object           = utf8 "Köbt genstand",
  build_room           = "Bygget rum",
  cure                 = "Helbredt",
  buy_land             = utf8 "Köbt grund",
  treat_colon          = "Behandlet:",
  final_treat_colon    = "Endelige behandling:",
  cure_colon           = "Helbredt:",
  deposit              = utf8 "Behandlings indsættelse",
  advance_colon        = "Forskud",
  research             = "Forskningsomkostninger",
  drinks               = utf8 "Indtægt: Drikkevarer",
  jukebox              = utf8 "Indtægt: Jukebox", -- unused
  cheat                = "Snydepenge",
  heating              = "Varmeregning",
  insurance_colon      = "Forsikring:",
  bank_loan            = utf8 "Banklån",
  loan_repayment       = utf8 "Lån tilbagebetalning",
  loan_interest        = utf8 "Renter på lån",
  research_bonus       = "Forskningsbonus",
  drug_cost            = "Medicinomkostninger",
  overdraft            = utf8 "Renter på kredit",
  severance            = utf8 "Böde",
  general_bonus        = "Generel bonus",
  sell_object          = "Solgt genstand",
  personal_bonus       = "Personlig bonus",
  emergency_bonus      = utf8 "Akuttilfælde bonus",
  vaccination          = "Vaccinering",
  epidemy_coverup_fine = utf8 "Epidemiböde for forsög på mörklægning",
  compensation         = "Kompensation",
  vip_award            = utf8 "VIP belönning",
  epidemy_fine         = utf8 "Epidemiböde",
  eoy_bonus_penalty    = utf8 "Årsafslutning - straf",
  eoy_trophy_bonus     = utf8 "Årsafslutning - trofæbonus",
  machine_replacement  = "Udskiftning af maskine",
}


-- Level names
-- No need to translate these // froksen


-- Town map
town_map = {
  -- S[13][ 1] -- unused
  chat         = "Oversigtskort",
  for_sale     = "Til salg",
  not_for_sale = "Ikke til salg",
  number       = "Grundnummer", 
  owner        = "Grundejer",
  area         = utf8 "Grundområde",
  price        = "Grundpris",
}

-- Rooms short
-- NB: includes some special "rooms"
-- reception, destroyed room and "corridor objects"
rooms_short = {
  -- S[14][1] -- unused
  -- S[14][3] -- unused
  reception         = "Reception",
  destroyed         = utf8 "Ödelagt",
  corridor_objects  = "Korridorgenstande",
  
  gps_office        = utf8 "Lægekonsultation",
  psychiatric       = "Psykiatri",
  ward              = "Sengeafsnit",
  operating_theatre = "Operationsstue",
  pharmacy          = "Apotek",
  cardiogram        = utf8 "Kardiogram",
  scanner           = "Skanner",
  ultrascan         = "Ultraskanner",
  blood_machine     = "Blodmaskine",
  x_ray             = utf8 "Röntgen",
  inflation         = "Pumperum",
  dna_fixer         = "DNA Fixer",
  hair_restoration  = utf8 "Hårgenskaber",
  tongue_clinic     = "Tungeklinik",
  fracture_clinic   = "Knoglebrudsklinik",
  training_room     = utf8 "Undervisningsrum",
  electrolysis      = "Elektrolyse",
  jelly_vat         = "Geléröret", -- Hmm. Donno if this is translateable
  staffroom         = utf8 "Personalerum",
  -- rehabilitation = S[14][24], -- unused, i laughed when i saw this though.. They didn't however get so stupid and include this in the game :P
  general_diag      = "General diagnose",
  research_room     = "Forskningsrum",
  toilets           = "Toiletter",
  decontamination   = "Dekontaminering",
}

rooms_long = {
  -- S[53][1] -- unused
  general           = "Generelt", -- unused?
  emergency         = utf8 "Akuttilfælde",
  corridors         = "Korridorer",
  
  gps_office        = utf8 "Lægekonsultationen",
  psychiatric       = "Psykiateren",
  ward              = "Sengeafsnittet",
  operating_theatre = "Operationsstuen",
  pharmacy          = "Apotektet",
  cardiogram        = utf8 "Kardiogrammet",
  scanner           = "Skannerrum",
  ultrascan         = "Ultraskannerrum",
  blood_machine     = "Blodmaskinerum",
  x_ray             = "Röntgen",
  inflation         = "Pumperum",
  dna_fixer         = "DNA Fixer",
  hair_restoration  = utf8 "Hårgenskaber",
  tongue_clinic     = "Tungeklinik",
  fracture_clinic   = "Konglebrudklinik",
  training_room     = utf8 "Undervisningsrum",
  electrolysis      = "Elektolyseklinik",
  jelly_vat         = "Geléröret", -- Same as rooms short version
  staffroom         = utf8 "Personalerum",
  -- rehabilitation = S[53][24], -- unused
  general_diag      = "General diagnose",
  research_room     = "Forskningsrum",
  toilets           = "Toiletter",
  decontamination   = "Dekontaminering",
}

room_descriptions = {
  ultrascan = {
    [1] = "Ultraskanner//",
    [2] = utf8 "Ultraskanneren er toppen af poppen indenfor diagnoseudstyr. Den koster spidsen af en jetjager, men pengne er godt givet ud hvis du vil være i stand til at stille meget sikre diagnoser på dit hospital.//",
    [3] = utf8 "Ultraskanneren betjenes af en læge. Den kræver også vedligeholdelse. ",
  },
  gp = {
    [1] = utf8 "Lægekonsultation//",
    [2] = utf8 "Dette er det helt fundementale diagonseredskab på dit hospital. Nye patienter sendes hertil först for at finde ud af, hvad de fejler. Hvis der ikke straks kan stilles en diagnose, sendes patienten videre til andre diagnoserum. Du skal sandsynligvis med tiden bruge flere lægekonsultationer for at undgå lange köer. Jo större rummet er og jo flere genstande du placerer i rummet, des bedre arbejder lægen. Dette gælder for alle rum.//",
    [3] = utf8 "Alle typer læger kan arbejde i lægekonsultationen. ",
  },
  fracture_clinic = {
    [1] = "Knoglebrudsklinik//",
    [2] = utf8 "Patienter som har fået knoglebrud behandles her. Gipsfjerneren bruger en kraftig industrilaser til at skære gibsen væk, og forårsager kun ganske lidt smerte hos patienten.//",
    [3] = utf8 "En sygeplejerske står får betjeningen af maskinen, som også kræver vedligeholdelse af en pedel. ",
  },
  tv_room = {
    [1] = "TV RUM IKKE BRUGT",
  },
  inflation = {
    [1] = "Pumperum//",
    [2] = utf8 "Patienter som har et humoristisk, men dog smertefuldt, ballonhoved, behandles i pumperummet. Her stikkes der hul på hovedet så trykket forsvinder. Herefter pumper lægen hovedet op til normalstörrelse.//",
    [3] = utf8 "Pumperummet kan kun betjenes af læger. Regelmæssig vedligeholdelse er også vigtig. ",
  },
  jelly_vat = {
    [1] = "Geléröret//",
    [2] = "Patienter, som lider af denne forfærdelige sygdom, må slingre den lange vej til Geleröret. I röret bliver de helbredt på en måde, som stadig ikke fuldt ud kan forklares af lægevidenskaben.//",
    [3] = "Geleröret kræver en læge. Det kræver også vedligeholdelse fra af en pedel.",
  },
  scanner = {
    [1] = "Skanner//",
    [2] = "Patienter bliver præcist diagnosticeret ved brug af denne sofistikerede skanner. De skal efterfölgende se en læge i lægekonsultationen, som skal se på resultatet af skanningen og stille den endelige diagnose.//",
    [3] = "Skanneren betjenes af en læge. Den kræver vedligeholdelse af en pedel. ",
  },
  blood_machine = {
    [1] = "Blodmaskine//",
    [2] = "Blodmaskinen undersöger patientens blodceller for at finde ud af, hvad de fejler.//",
    [3] = "Blodmaskinen betjenes af en læge. Den kræver også vedligeholdelse af en pedel. ",
  },
  pharmacy = {
    [1] = "Apotek//",
    [2] = "Patienter, som er blevet diagnosticeret med en sygdom som kan kureres med medicin, sendes til apoteket. Efterhånden som flere og flere sygdomme som kan kureres med medicin opdages, kommer flere og flere patienter til apoteket. Det kan være en god idé at bygge flere apoteker når dit hospital vokser.//",
    [3] = "En sygeplejerske står for udleveringen af medicin i apoteket. ",
  },
  cardiogram = {
    [1] = "Kardio//",
    [2] = "Patienter forsöges diagnosticeret her för de sendes tilbage til lægekonsultationen for at finde en kur.//",
    [3] = "Kardioen betjenes af en læge. Den kræver også vedligeholdelse af en pedel. ",
  },
  ward = {
    [1] = "Sengeafsnit//",
    [2] = "Patienter observeres her af en sygeplejerske mens man forsöger at stille en diagnose. Patienter opholder sig også ofte i sengeafsnittet forud for operationer.//",
    [3] = "Sengeafsnittet kræver en sygeplejserke. ",
  },
  psych = {
    [1] = "Psykiatri//",
    [2] = "Patienter som diagnosticeres med en psykiatrisk sygdom, sendes til psykiateren for behandling. Psykiatere kan også holde samtaler med patienter under diagnosticeringsfasen for at finde ud af, hvad de fejler.//",
    [3] = "Psykiatrien kræver en læge med psykiatrisk uddannelse. ",
  },
  staff_room = {
    [1] = "Personalerum//",
    [2] = "Dine ansatte bliver trætte mens de udförer deres arbejde. I personalerummet kan de slappe af og komme til kræfter igen. Trætte ansatte arbejder langsommere, kræver flere penge og vil i sidste ende sige op. De laver også flere fejl. Et personalerum med flere forskellige ting for dine ansatte at give sig til, er bestemt udgiften værd. Sörg for, at der er plads til flere ansatte på samme tid. ",
  },
  operating_theatre = {
    [1] = "operationsstue//",
    [2] = "I dette vigtige rum bliver en række sygdomme behandlet. Operationsstuen kræver god plads og en masse dyrt udstyr. Den er en vital del af dit hospital.//",
    [3] = "Operationsstuen kræver to læger med kirurgisk uddannelse. ",
  },
  training = {
    [1] = "Undervisningsrum//",
    [2] = "Dine praktikanter og læger kan få nye, værdifulde færdigheder ved at studere i dette rum. En konsulent med kirurgisk, psikiatrisk eller forskningsmæssig uddannelse vil videregive disse færdigheder til de læger, de underviser. Læger, som allerede har disse færdigheder, bliver bedre til at bruge dem ved at blive undervist.//",
    [3] = "Undervisningen varetages af en konsulent. ",
  },
  dna_fixer = {
    [1] = "DNA Klinik//",
    [2] = "Patienter, som har været udsat for eksperimenter af aliens fra andre planeter, får deres DNA udskiftet i denne klinik. DNA-klinikken er udstyret med en meget avanceret maskine, og det ville nok være en god idé at have en brandslukker stående i rummet, bare for en sikkerheds skyld.//",
    [3] = "DNA-klinikken betjenes af en forskningsuddannet læge. Den kræver også vedligeholdelse af en pedel. ",
  },
  research = {
    [1] = "Forskningsrum//",
    [2] = "Ny medicin og nye kure opdages og forbedres i forskningsrummet. Det er en vital del af dit hospital, og vil med tiden forbedre dine helbredelsesprocenter.//",
    [3] = "Forskningsuddannede læger kan arbejde i forskningsrummet. ",
  },
  hair_restoration = {
    [1] = "Hårgenskabelsesklinik//",
    [2] = "Patienter som lider af en ekstrem grad af ufrivillig skaldethed, sendes til hårgenskabelsesklinikken. En læge vil betjene maskinen og vil hurtigt genskabe patientens mægtige hårpragt.//",
    [3] = "Hårgenskabelsesklinkken kræver en læge. Den kræver også vedligeholdelse af en pedel. ",
  },
  general_diag = {
    [1] = "Generel Diagnose//",
    [2] = "Patienter, som kræver yderligere diagnosticering, sendes hertil for at blive undersögt af en læge. Hvis en læge i lægekonsultationen ikke i förste omgang kan finde ud af, hvad patienten fejler, bliver de ofte sendt til Generel Diagnose for yderligere undersögelse. Herfra sendes de tilbage til lægekonsultationen hvor resultaterne bliver analyseret.//",
    [3] = "Generel Diagnose kræver en læge. ",
  },
  electrolysis = {
    [1] = "Elektrolyse//",
    [2] = "Patienter med eksplosiv hårvækst sendes til dette rum, hvor en speciel maskine kaldet en Elektrolyser, hiver hårene ud og lukker hårsækkene med elektriske stöd.//",
    [3] = "Betjening af elektrolysemaskinen kræver en læge. Den kræver også vedligeholdelse af en pedel. ",
  },
  slack_tongue = {
    [1] = "Slap-Tunge Klinik//",
    [2] = "Patienter som får stillet diagnosen slap tunge, sendes til denne klinik for behandling. Lægen anvender et stykke moderne udstyr til at forlænge tungen og skære den af, for derved at efterlade patienten med en helt normal tunge.//",
    [3] = "Slap-Tunge klinikken kræver en læge. Den kræver også vedligeholdelse af en pedel. ",
  },
  toilets = {
    [1] = "Toilet//",
    [2] = "Patienter som hörer naturens kalden, får brug for at lette byrden i dine komfortable toiletter. Du kan installere ekstra båse og vaske hvis du forventer mange besögende. Det kan være en god idé at bygge flere toiletter i dit hospital, så trængende patienter ikke skal gå for langt. ",
  },
  no_room = {
    [1] = "",
  },
  x_ray = {
    [1] = "Röntgen//",
    [2] = "Röntgenmaskinen fotograferer indersiden af folk med en speciel bestrålingsteknologi, så dine læger kan danne sig et bedre billede af, hvad de fejler.//",
    [3] = "Röntgenmaskinen betjenes af en læge. Den kræver også vedligeholdelse. ",
  },
  decontamination = {
    [1] = "DekontamineringsKlinik//",
    [2] = "Patienter, som har været udsat for radioaktivitet, sendes hurtigt til dekontamineringsklinikken. Dette rum indeholder en brusebad som renser dem for de forfærdelige radiaktive stoffer og mudder.//",
    [3] = "Dekontamineringsklinikken kræver en læge. Den kræver også vedligeholdelse af en pedel. ",
  },
}

-- Drug companies
drug_companies = {
  "Mediciner-Til-Dig",
  "Kur-R-Os",
  utf8 "Runde Små Piller Co.",
  "Dyremedicin AS",
  "Alle Piller Co.",
}

-- Build rooms
build_room_window = {
  -- S[16][1], -- unused
  pick_department   = utf8 "Vælg afdelning",
  pick_room_type    = utf8 "Vælg rumtype",
  cost              = "Pris:",
}

-- Build objects
buy_objects_window = {
  choose_items      = utf8 "Vælg genstand",
  price             = "Pris: ",
  total             = "Total: ",
}


-- Research
research = {
  categories = {
    cure            = "Behandlingsudstyr",
    diagnosis       = "Diagnoseudstyr",
    drugs           = "Medicinforskning",
    improvements    = "Forbedringer",
    specialisation  = "Specialisering",
  },
  
  funds_allocation  = "Forskningsbudget",
  allocated_amount  = "Totale budget",
}

-- Policy screen
policy = {
  header            = utf8 "Hospitalets politik",
  diag_procedure    = utf8 "Diagnose procedure",
  diag_termination  = utf8 "Diagnose annullering",
  staff_rest        = utf8 "Send personale til personalerum",
  staff_leave_rooms = utf8 "Personale må forlade rum",
  
  sliders = {
    guess           = utf8 "GæT PÅ KUR", -- belongs to diag_procedure
    send_home       = "SEND HJEM", -- also belongs to diag_procedure
    stop            = "STOP PROCEDURE", -- belongs to diag_termination
    staff_room      = utf8 "TIL PERSONALERUM", -- belongs to staff_rest
  }
}


-- Rooms
room_classes = {
  -- S[19][1] -- unused
  -- S[19][2] -- "corridors" - unused for now
  -- S[19][3] -- unused
  diagnosis  = "Diagnosticering",
  treatment  = "Behandling",
  clinics    = "Klinikker",
  facilities = "Faciliteter",
}

-- Insurance companies
insurance_companies = {
  out_of_business   = utf8 "GÅET KONKURS",
  utf8 "Nyköbt Lökke",
  utf8 "Bölgen Blå",
  utf8 "Årlige Forskud AS",
  "Stygge Arr Co.",
  utf8 "Svömmeblære Co.",
  utf8 "Drön Ærlig AS",
  "Sverres Beholdninger",
  "Kate Pus Og Kompani",
  utf8 "Larsen Jr. Forsikring",
  "Glade Forsikringer AS",
  "Mafia Forsikringer",
}

-- Menu root
-- Keep 2 spaces as prefix and suffix
menu = {
  file                = "  FILER  ",
  options             = "  INDSTILLINGER  ",
  display             = "  GRAFISKE INDSTILLINGER  ",
  charts              = "  SKEMAER  ",
  debug               = "  FEJLFINDING  ",
}

menu_file = {
  load                = utf8 "  INDLæS  ",
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

-- Menu Options
menu_options = {
  sound               = "  LYD  ",
  announcements       = "  ANNONCERINGER  ",
  music               = "  MUSIK  ",
  sound_vol           = "  LYDSTYRKE  ",
  announcements_vol   = "  ANNONCERINGSSTYRKE  ",
  music_vol           = "  MUSIKSTYRKE  ",
  autosave            = "  AUTOMATISK GEM  ",
  game_speed          = "  SPILHASTIGHED  ",
  jukebox             = "  JUKEBOX  ",
  edge_scrolling      = "  KANT SCROLLING  ",
  settings            = "  INDSTILLINGER  ",
}

-- Menu Options Game Speed
menu_options_game_speed = {
  pause               = "  (P) PAUSE  ",
  slowest             = "  (1) LANGSOMMEST  ",
  slower              = "  (2) LANGSOMMERE  ",
  normal              = "  (3) NORMAL  ",
  max_speed           = "  (4) HURTIGST  ",
  and_then_some_more  = utf8 "  (5) OG SÅ LIGE LIDT MERE  ",
}  

-- Menu Display
menu_display = {
  high_res            = "  MANGE DETALJER  ",
  mcga_lo_res         = utf8"  FÅ DETAILJER  ",
  shadows             = "  SKYGGER  ",
}

-- Menu Charts
menu_charts = {
  statement           = utf8 "  ERKLÆRINGER  ",
  casebook            = "  MEDICINBOG  ",
  policy              = "  POLITIK  ",
  research            = "  FORSKNING  ",
  graphs              = "  DIAGRAMMER  ",
  staff_listing       = utf8 "  PERSONALEHÅNDTERING  ",
  bank_manager        = "  BANKKONSULENT  ",
  status              = "  STATUS  ",
  briefing            = "  BRIEFING  ",
}


-- Menu Debug
menu_debug = {
  object_cells        = utf8 "  OBJEKTCELLER        ",
  entry_cells         = utf8 "  INDGANGSCELLER      ",
  keep_clear_cells    = utf8 "  KEEP-CLEAR CELLER   ",
  nav_bits            = utf8 "  NAV BITS            ",
  remove_walls        = utf8 "  FJERN VÆGGE        ",
  remove_objects      = utf8 "  FJERN OBJEKTER ",
  display_pager       = utf8 "  VIS PERSONSOEGER           ",
  mapwho_checking     = utf8 "  MAPWHO CHECKING        ",
  plant_pagers        = utf8 "  PLANT PERSONSOEGERE        ",
  porter_pagers       = utf8  "  PORTER PERSONSOEGERE       ",
  pixbuf_cells        = utf8 "  PIXBUE CELLER        ",
  enter_nav_debug     = utf8 "  ENTER NAV FEJLSOEGNING     ",
  show_nav_cells      = utf8 "  VIS NAV CELER      ",
  machine_pagers      = utf8 "  MASKIN PERSONSOEGER       ",
  display_room_status = utf8 "  VIS RUM STATUS       ",
  display_big_cells   = utf8 "  VIS STORE CELLER    ",
  show_help_hotspot   = utf8 "  VIS HJÆLP HOTSPOTS  ",
  win_game_anim       = utf8 "  VIND SPIL ANIM       ",
  win_level_anim      = utf8 "  VIND RUNDE ANIM      ",
  lose_game_anim = {
    [1]  = "  TAPT SPIL 1 ANIM  ",
    [2]  = "  TAPT SPIL 2 ANIM  ",
    [3]  = "  TAPT SPIL 3 ANIM  ",
    [4]  = "  TAPT SPIL 4 ANIM  ",
    [5]  = "  TAPT SPIL 5 ANIM  ",
    [6]  = "  TAPT SPIL 6 ANIM  ",
    [7]  = "  TAPT SPIL 7 ANIM  ",
  },
}

-- High score screen
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
    cures             = "ANTAL HELBREDTE",
    deaths            = utf8 "ANTAL DÖDSFALD",
    cure_death_ratio  = "HELBREDT-DÖDSFALDS RATIO",
    patient_happiness = "PATIENTTILFREDSHED",
    staff_happiness   = "PERSONALETILFREDSHED",
    staff_number      = "MEST PERSONALE",
    visitors          = utf8 "FLEST BESÖGENDE",
    total_value       = utf8 "TOTAL VÆRDI",
  },
}

    --mangler
-- Trophy room
-- Trophy room
trophy_room = {
  many_cured = {
    awards = {
      utf8 "Tillykke med Marie Curie-prisen for at have været i stand til at helbrede næsten alle patienter på hospitalet i det forgangne år.",
    },
    trophies = {
      utf8 "Den Internationale Behandlingsfond önsker at ære dig, fordi du har helbredt et stort antal mennesker på hospitalet i det forgangende år. De tildeler dig Kureret-Mange trofæet.",
      utf8 "Du har fået tildelt Sygdom-Gå-Væk trofæet for at have kureret en höj procentdel af patienter på hospitalet i det forgangne år.",
    },
  },
  all_cured = {
    awards = {
      utf8 "Tillykke med Marie Curie-prisen for at have været i stand til at helbrede alle patienter på hospitalet i det forgangne år.",
    },
    trophies = {
      utf8 "Den Internationale Behandlingsfond önsker at ære dig, fordi du har helbredt alle patienter på hospitalet i det forgangne år. De tildeler dig derfor Kureret-Alle trofæet.",
      utf8 "Du har fået tildelt Ingen-Syge-Mennesker trofæet for at have helbredt alle patienter på hospitalet i det forgangne år.",
    },
  },
  high_rep = {
    awards = {
      utf8 "Du er blevet tildelt Statsministerens Glitrende Ærespris, som tildeles det hospital med det bedste omdömme i det forgangne år. Tillykke!",
      utf8 "Smil og vær glad! Du tildeles Bullfrog-prisen for hospitalet med det bedste omdömme i det forgangne år. Nyd det - det er velfortjent!",
    },
    trophies = {
      utf8 "Tillykke med Rent-og-Pænt trofæet som tildeles hospitalet med det bedste omdömme i det forgangne år. Det er faktisk fortjent.",
    },
  },
  happy_staff = {
    awards = {
    },
    trophies = {
      utf8 "Du tildeles Smilets Pris for at holde dit hårdtarbejdende personale i godt humör.",
      utf8 "Instituttet for Humörspredere hædrer dig for ikke at have nogen sure og negative ansatte på hospitalet i det forgangne år, og giver dig derfor dette trofæ.",
      utf8 "Dette trofæ tildeles hermed dig fordi dit personle, på trods af en ihærdig arbejdsindsats, er glade og tilfredse. De ligefrem stråler af glæde!",
    },
  },
  happy_vips = {
    awards = {
      utf8 "Du har vundet Nobelprisen for at imponere VIP'erne. Alle, som besögte dit hospital i det forgangne år, taler ikke om andet.",
      utf8 "Tillykke med VIP-prisen for at have gjort livene for de hårdtarbejdende kendisser bedre, ved at sætte alle som besögte dit hospital i det forgangne år i et bedre lys. Fantastisk.",
    },
    trophies = {
      utf8 "Foreningen for Kendte Mennesker belönner dig med Kendistrofæet for at have taget dig godt af alle VIP'ere som besögte dit hospital i det forgangne år - du nærmer dig kendis-status, du er snart en af os.",
    },
  },
  no_deaths = {
    awards = {
      utf8 "Du har vundet Længe-Leve trofæet for at holde 100 procent af patienterne i live i det forgangne år.",
    },
    trophies = {
      utf8 "Foreningen Livet-Går-Videre belönner dig med dette trofæ for at have nul dödsfald i det forgangne år.",
      utf8 "Du er tildelt Længe Leve Livet trofæet for at have undgået dödsfald på dit hospital i det forgangne år. Storartet.",
    },
  },
  rats_killed = {
    awards = {
    },
    trophies = {
      utf8 "Du er tildelt Ingen-Gnavere trofæet for at have skudt %d rotter på dit sygehuset i det forgangne år.", -- %d (number of rats)
      utf8 "Du modtager dette trofæ af Foreningen For Mus og Rotters Bekæmpelse på grund af dine unikke evner til at skyde gnavere. Du fik ramt på %d af dem i det forgangne år!", -- %d (number of rats)
      utf8 "Du modtager Rotteskydertrofæet for dine unikke evner, som resulterede i udryddelsen af %d rotter på hospitalet i det forgangne år.", -- %d (number of rats)
    },
  },
  rats_accuracy = {
    awards = {
    },
    trophies = {
      utf8 "Du er tildelt Nöjagtige-Skud-I-Håblös-Krig Trofæet for at have en træfprocent på %d%% i jagten på ækle rotter.", -- %d (accuracy percentage)
      utf8 "Dette trofæ er for at ære din nöjagtighed ved dræbe %d%% af rottene i det forgangne år.", -- %d (accuracy percentage)
      utf8 "For at hædre din præstation med at dræbe intet mindre end %d%% af rottene på dit hospital, bliver du tildelt Dungeon Keepers Skadedyrspris, Tillykke!", -- %d (accuracy percentage)
    },
  },
  healthy_plants = {
    awards = {
      utf8 "Tillykke med Grönne-Glæder prisen for at have holdt dine planter ekstremt friske i det forgangne år.",
    },
    trophies = {
      utf8 "Venner-af-Potteplanter önsker at give dig Grön Helse Trofæet, fordi dine planter har strålet de sidste 12 måneder.",
      utf8 "Foreningen For Grönne Gamlinger önsker at give dig Grönfinger Trofæet for at have holdt plantene friske i det forgangne år.",
    },
  },
  sold_drinks = {
    awards = {
    },
    trophies = {
      utf8 "Foreningen for Globale Tandlæger er stolte over at kunne tildele dig dette trofæ for at have solgt utroligt store mængder sodavand på dit hospital i det forgangne år.",
      utf8 "Hospitalet tildeles Kulsyre-prisen for alle de sprudlende sodavand, der er solgt fra dine automater i de sidste 12 måneder.",
      utf8 "På vegne af Hulfyldernes Forening, tildeles du hermed dette trofæ dækket af Chokolade, for at have solgt enorme mængder sodavand på hospitalet i det forgangne år.",
    },
  },
}


-- Casebook screen
casebook = {
  reputation           = utf8 "Omdömme",
  treatment_charge     = "Behandlingspris",
  earned_money         = utf8 "Indtjent",
  cured                = "Helbredt",
  deaths               = utf8 "Dræbt",
  sent_home            = "Sendt hjem",
  research             = "Fokusér forskning",
  cure                 = "Kur",
   cure_desc = {
    build_room         = "Jeg anbefalder du bygger %s", -- %s (room name)
    build_ward         = "Du mangler stadig at bygge et sengeafsnit.",
    hire_doctors       = utf8 "Du mangler at ansætte nogle læger",
    hire_surgeons      = "Du mangler at ansætte kirurger.",
    hire_psychiatrists = "Du har ikke ansat en psykiatiker.",
    hire_nurses        = "Du skal ansætte sygeplejersker.",
    no_cure_known      = "Ingen kendt kur.",
    cure_known         = "Kur.",
    improve_cure       = "Forbedre kur.",
  },
}
    
-- Tooltips
tooltip = {
  
  -- Build room window
  build_room_window = {
    room_classes = {
      diagnosis        = utf8 "Diagnoserum",
      treatment        = utf8 "Behandlingrum",
      clinic           = utf8 "Klinikker",
      facilities       = utf8 "Faciliteter",
    },
    cost               = utf8 "Samlede omkostninger for rummet",
    close              = utf8 "Afbryd processen og vend tilbage til spillet",
  },
  
  -- Toolbar
  toolbar = {
    bank_button        = "Venstreklik for bankkonsulent, höjreklik for kontoudskrift",
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
  
  -- Hire staff window
  hire_staff_window = {
    doctors            = utf8 "Vis tilgængelige læger på arbejdsmarkedet",
    nurses             = utf8 "Vis tilgængelige sygeplejersker på abejdsmarkedet",
    handymen           = utf8 "Vis tilgængelige pedeller på arbejdsmarkedet",
    receptionists      = utf8 "Vis tilgængelige receptionister på arbejdsmarkedet",
    prev_person        = utf8 "Forrige person",
    next_person        = utf8 "Næste person",
    hire               = utf8 "Ansæt person",
    cancel             = utf8 "Afbryd",
    doctor_seniority   = utf8 "Lægens evner (Praktikant, Doktor, Konsulent)",
    staff_ability      = utf8 "Kvalifikation",
    salary             = utf8 "Lönkrav",
    qualifications     = utf8 "Lægens specialer",
    surgeon            = utf8 "Kirurg",
    psychiatrist       = utf8 "Psykiater",
    researcher         = utf8 "Forsker",
  },
  
  -- Buy objects window
  buy_objects_window = {
    price              = utf8 "Pris for genstand",
    total_value        = utf8 "Total værdi af köbte genstande",
    confirm            = utf8 "Köb genstand(e)",
    cancel             = "Afbryd",
    increase           = utf8 "Köb en til af denne genstand",
    decrease           = utf8 "Köb en færre af denne genstand",
  },
  
  -- Staff list
  staff_list = {
    doctors            = utf8 "Se en oversigt over dine læger",
    nurses             = utf8 "Se en oversigt over dine sygeplejersker",
    handymen           = utf8 "Se en oversigt over dine pedeller",
    receptionists      = utf8 "Se en oversigt over dine receptionister",
    
    happiness          = utf8 "Viser hvor tilfredse dine ansatte er",
    tiredness          = utf8 "Viser hvor trætte dine ansatte er",
    ability            = utf8 "Viser de ansattes evner",
    salary             = utf8 "Den pågældendes lön",
    
    happiness_2        = utf8 "Den ansattes moral",
    tiredness_2        = utf8 "Den ansattes træthedssniveau",
    ability_2          = utf8 "Den ansattes evner",
    
    prev_person        = utf8 "Forrige ansatte",
    next_person        = utf8 "Næste ansatte",
    
    bonus              = utf8 "Giv den ansatte 10% i bonus",
    sack               = utf8 "Giv den ansatte sparket",
    pay_rise           = utf8 "Hæv den ansattes lön med 10%",
    
    close              = utf8 "Luk og vend tilbage til spillet",
    
    doctor_seniority   = utf8 "Lægens evner",
    detail             = utf8 "Lægens öje for detaljer",
    
    view_staff         = utf8 "Fölg den ansatte",
    
    surgeon            = utf8 "Kvalificeret Kirurg",
    psychiatrist       = utf8 "Kvalificeret Psykiater",
    researcher         = utf8 "Kvalificeret Forsker",
    surgeon_train      = utf8 "%d%% gennemfört uddannelse som kirurg", -- %d (percentage trained)
    psychiatrist_train = utf8 "%d%% gennemfört uddannelse som psykiater", -- %d (percentage trained)
    researcher_train   = utf8 "%d%% gennemfört uddannelse som forsker", -- %d (percentage trained)
    
    skills             = "Ekstra evner",
  },
  
  -- Queue window
    queue_window = {
    num_in_queue       = utf8 "Antal patienter i köen",
    num_expected       = utf8 "Antal patienter som receptionen forventer ankommer til köen indenfor kort tid",
    num_entered        = utf8 "Antal patienter behandlet i dette rum",
    max_queue_size     = utf8 "Den maksimale længde köen må have",
    dec_queue_size     = utf8 "Mindre makslængde",
    inc_queue_size     = utf8 "Större makslængde",
    front_of_queue     = utf8 "Træk i en patient for at stille ham/hende forest i köen",
    end_of_queue       = utf8 "Træk i en patient for at stille ham/hende bagerst i köen",
    close              = "Luk vinduet",
    patient            = utf8 "Træk i en patient for at stille ham/hende i köen. Höjreklik på en patient for at sende patienten hjem eller til et konkurrerende hospital",
    patient_dropdown = {
      reception        = "Send patienten til receptionen",
      send_home        = "Send patienten hjem",
      hospital_1       = "Henvis patienten til et andet hospital",
      hospital_2       = "Henvis patienten til et andet hospital",
      hospital_3       = "Henvis patienten til et andet hospital",
    },
  },
  
  -- Main menu
  main_menu = {
    new_game           = "Begynd et nyt spil",
    load_game          = "Hent et gemt spil",
    continue           = utf8 "Indlæs et gemt spil",
    network            = utf8 "Ændre dine indstillinger",
    quit               = utf8 "Er du sikker på du ikke vil spille mere?",
    load_menu = {
      load_slot        = "  SPIL [slotnumber]  ", -- NB: no %d! Append " [slotnumber]".
      empty_slot       = "  TOM  ",
    },
  },
  -- Window general
  window_general = {
    cancel             = "Afbryd",
    confirm            = utf8 "Godkend",
  },
  -- Patient window
  patient_window = {
    close              = "Luk vinduet",
    graph              = utf8 "Klik for at skifte mellem en graf over patientens helbred og patientens behandlingshistorik",
    happiness          = utf8 "Patientens humör",
    thirst             = utf8 "Patientens törst",
    warmth             = "Patientens temperatur",
    casebook           = "Vis detaljer om patientens sygdom",
    send_home          = "Send patienten hjem fra hospitalet",
    center_view        = utf8 "Fokusér på patienten",
    abort_diagnosis    = utf8 "Send patienten til behandling i stedet for at vente til diagnosen er stillet med sikkerhed",
    queue              = utf8 "Se köen patienten er i",
  },
  -- window
  staff_window = {
    name               = "Den ansattes navn",
    close              = "Luk vinduet",
    face               = utf8 "Ansigtet på personen - klik for at administere de ansatte",
    happiness          = utf8 "Humörniveau",
    tiredness          = utf8 "Træthedsniveau",
    ability            = "Kvalifikation",
    doctor_seniority   = "Lægens særlige evner (Praktikant, Doktor, Konsulent)",
    skills             = "specialisering",
    surgeon            = "Kirurg",
    psychiatrist       = "Psykiater",
    researcher         = "Forsker",
    salary             = utf8 "Månedslön",
    center_view        = utf8 "Venstreklik for at finde den ansatte, höjreklik for at bladre igennem de ansatte.",
    sack               = "Fyr personen",
    pick_up            = "Saml op",
  },
  -- Machine window
  machine_window = {
    name               = utf8 "Navn",
    close              = utf8 "Luk vinduet",
    times_used         = utf8 "Antal gange maskinen har været brugt",
    status             = utf8 "Maskinstatus",
    repair             = utf8 "Kald en pedel til at vedligeholde maskinen",
    replace            = "Udskift maskinen med en ny",
  },
  
  
  -- Handyman window
  -- Spparently handymen have their own set of strings (partly) containing "handyman".
  -- We could just get rid of this category and include the three prios into staff_window.
  handyman_window = {
    name               = "Pedellens navn", -- contains "handyman"
    close              = "Luk vinduet",
    face               = "Pedellens ansigt", -- contains "handyman"
    happiness          = utf8 "Humörniveau",
    tiredness          = utf8 "Træthedsniveau",
    ability            = "Kvalifikation",
    prio_litter        = utf8 "Få pedellen til at priotere rengöring höjere", -- contains "handyman"
    prio_plants        = utf8 "Få pedellen til at priotere vanding af planter höjere.", -- contains "handyman"
    prio_machines      = utf8 "Få pedellen til at priotere vedligeholdelse af maskiner höjere", -- contains "handyman"
    salary             = utf8 "Månedslön",
    center_view        = "Fokusér på pedellen", -- contains "handyman"
    sack               = "Fyr pedellen",
    pick_up            = "Saml pedellen op",
  },
  
  -- Place objects window
  place_objects_window = {
    cancel             = "Afbryd",
    buy_sell           = utf8 "Köb/Sælg genstand",
    pick_up            = utf8 "Flyt genstand",
    confirm            = utf8 "Godkend",
  },
  
  -- Casebook
  casebook = {
    up                 = "Rul op",
    down               = "Rul ned",
    close              = "Luk medicinbogen",
    reputation         = utf8 "Ry om behandlingen eller diagnosen i nærområdet",
    treatment_charge   = "Pris for behandling",
    earned_money       = "Total tjent indtil nu",
    cured              = "Antal helbredte patienter",
    deaths             = utf8 "Antal patienter dræbt som fölge af behandlingen",
    sent_home          = utf8 "Antal patienter sendt hjem",
    decrease           = utf8 "Sænk pris",
    increase           = utf8 "Forhöj pris",
    research           = utf8 "Tryk her for at bruge forskningsbudgettet for specialisering til at forske i denne behandling",
    cure_type = {
      drug             = utf8 "Behandlingen kræver medicin",
      drug_percentage  = utf8 "Behandlingen kræver medicin, og din er %d%% effektiv", -- %d (effectiveness percentage)
      psychiatrist     = utf8 "Sygdommen kræver behandling hos en psykiater",
      surgery          = utf8 "Sygdommen kræver operation",
      machine          = utf8 "Sygdommen behandles med en maskine",
    },
    
    cure_requirement = {
      possible         = utf8 "Du kan genneföre behandlingen",
      research_machine = utf8 "Du skal forske i maskiner for at kunne behandle denne sygdom",
      build_room       = utf8 "Du skal bygge et rum for at kunne udföre behandlingen", -- NB: no %s!
      hire_surgeons    = utf8 "Du mangler to kirurger for at kunne gennemföre behandlingen",
      hire_surgeon     = utf8 "Du skal bruge en kirurg mere for at kunne gennemföre behandlingen",
      hire_staff = utf8 "Du skal ansætte noget personale for at kunne behandle denne sygdom",
      build_ward       = utf8 "Du skal bygge er sengeafsnit for at kunne gennemföre denne behandling",
      ward_hire_nurse  = utf8 "Du mangler en sygeplejerske for at kunne gennemföre behandlingen",
      not_possible     = utf8 "Du kan ikke håndtere denne behandling endnu",
    },
  },
  
  -- Statement
  statement = {
    close              = "Luk kontoudskriften",
  },
  
  -- Research
  research = {
    close              = utf8 "Luk vinduet",
    cure_dec           = utf8 "Nedprioriter forskning i behandlingsudstyr",
    diagnosis_dec      = utf8 "Nedprioriter forskning i diagnoseudstyr",
    drugs_dec          = utf8 "Nedprioriter forskning i medicin",
    improvements_dec   = utf8 "Nedprioriter forskning i forbedring af eksisterende udstyr eller medicin",
    specialisation_dec = utf8 "Nedprioriter forskning i specialiseringer",
    cure_inc           = utf8 "Opprioriter forskning i behandlingsudstyr",
    diagnosis_inc      = utf8 "Opprioriter forskning i diagnoseudstyr",
    drugs_inc          = utf8 "Opprioriter forskning i medicin",
    improvements_inc   = utf8 "Opprioriter forskning i forbedringer af eksisterende udstyr eller medicin",
    specialisation_inc = utf8 "Opprioriter forskning i specialiseringer",
    allocated_amount   = "Penge afsat til forskning",
  },
  
  -- Graphs
  graphs = {
    close              = utf8 "Gå til diagramvinduet",
    scale              = utf8 "Skala på diagram",
    money_in           = "Vis/skjul indtægter",
    money_out          = "Vis/skjul udgifter",
    wages              = utf8 "Vis/skjul Lönninger",
    balance            = "Vis/skjul Balance",
    visitors           = utf8 "Vis/skjul Besögende",
    cures              = "Vis/skjul Helbredte",
    deaths             = utf8 "Vis/skjul Dödsfald",
    reputation         = utf8 "Vis/skjul Omdömme",
  },

  --- nået hertil 28 dec
  -- Town map
  town_map = {
    people             = "Vis/Skjul mennesker",
    plants             = "Vis/Skjul planter",
    fire_extinguishers = "Vis/Skjul brandslukningsudstyr",
    objects            = "Vis/Skjul genstande",
    radiators          = "Vis/Skjul radiatorer",
    heat_level         = "Temperatur",
    heat_inc           = "Skru op for varmen",
    heat_dec           = "Skrue ned for varmen",
    heating_bill       = "varmeomkostninger",
    balance            = "Balance",
    close              = utf8 "Luk oversigtskortet",
  },
  
  -- Jukebox.
  jukebox = {
    current_title      = "Jukebox",
    close              = "Luk jukebox",
    play               = "Spil jukebox",
    rewind             = "Spol tilbage - jukebox",
    fast_forward       = "Spol frem - jukebox",
    stop               = "Stop jukebox",
    loop               = "Gentag jukebox",
  },
  
  -- Bank Manager
  bank_manager = {
  hospital_value    = utf8 "Hospitalets samlede værdi",
  balance           = "Balance",
  current_loan      = utf8 "Nuværende lån",
    repay_5000         = "Tilbagebetal 5000 til banken",
    borrow_5000        = utf8 "Lån 5000 af banken",
    interest_payment   = utf8 "Månedlige renteomkostninger",
    inflation_rate     = utf8 "Årlig inflation",
    inflation_rate    = "Inflationsrate",
    close              = "Luk banken",
    insurance_owed     = "Penge %s skylder dig", -- %s (name of debitor)
    show_graph         = "Vis forventet tilbagebetalingsplan fra %s", -- %s (name of debitor)
    graph              = "Forventet tilbagebetalingsplan fra %s", -- %s (name of debitor)
    graph_return       = "Vend tilbage til forrige billede",
  },
  
  -- Status
  status = {
    percentage_cured   = utf8 "Du skal helbrede %d % af de besögende på dit hospital. Indtil nu har du helbredt %d %",
    thirst             = utf8 "Gennemsnitlig törst for dine patienter",
    close              = utf8 "Luk oversigten",
    population_chart   = utf8 "Andel af lokalbefolkningen som benytter dit hospital",
    win_progress_own   = utf8 "Vis hvor langt du er nået for at klare banens krav",
    reputation        = utf8 "Dit omdömme skal være på mindst %d. Indtil nu er det %d",
    population        = utf8 "Du skal have %d%% af befolkningen til at bruge dit sygehus",
    warmth             = utf8 "Gennemsnitlig temperatur for patienterne på dit sygehus",
    percentage_killed  = utf8 "Kriteriet er blandet andet at dræbe færre end %d%% af dine besögende. Indtil nu har du taget livet af %d%%",
    balance        = utf8 "Din bankbalance skal være på mindst %d. Indtil nu er den %d",
    value          = utf8 "Dit sygehus skal have en værdi på $%d. Indtil nu er det værd $%d",
    win_progress_other = utf8 "Vis progression i forhold til kravene for dette niveau for %s", -- %s (name of competitor)
    num_cured        = utf8 "Kriteriet er blandet andet at helbrede %d mennesker. Indtil nu har du helbredt %d",
    happiness          = utf8 "Gennemsnitligt humör på personene på dit sygehus",
  },
  
    -- Policy
  policy = {
    close              = "Luk sygehuspolitik",
    staff_leave        = utf8 "Klik her for at tillade, at dit peronale må forlade de rum, du har placeret dem i",
    staff_stay         = utf8 "Klik her for at få personalet til at blive i de rum, du har placeret dem i",
    diag_procedure     = utf8 "Hvis lægens diagonse er mindre sikker end angivet her, vil patitenten blive sendt hjem. Hvis diagnosen er mere sikker end fastsat under gæt kur procenten, vil patienten få den relevante behandling",
    diag_termination   = utf8 "Dine læger vil blive ved med at söge efter en diagnose indtil lægerne er helt sikre på en kur, eller indtil alle maskiner er afprövet. Du kan dog altid afbryde diagnosticeringen",
    staff_rest         = utf8 "Hvor træt dit personale skal være för de går til personalerummet",
  },
  
  
  -- Pay rise window
  pay_rise_window = {
    accept             = utf8 "Accepter kravet",
    decline            = "Afvis krav og afsked vedkommende",
  },
  
  -- Watch
  watch = {
    hospital_opening   = utf8 "Tid indtil hospitalet åbner og patienter begynder at ankomme. Klik på knappen for at åbne hospitalet med det samme.",
    emergency          = utf8 "Tilbageværende tid til at få behandlet de akutte patienter.",
    epidemic           = utf8 "Resterende tid til at få styr på epidemien. Når tiden er udlöbet, eller når en smittet patient forlader hospitalet, kommer der en sundhedsindpektör forbi og inspicerer hospitalet. Knappen tænder og slukker for vaccinationstilstanden. Tryk på patienterne for at få en sygeplejerske til at vaccinere dem.",
  },
  
  -- Rooms
  rooms = {
    gps_office         = utf8 "Patienterne modtager deres förste konsultation og resultaterne af efterfölgende undersögelser i lægekonsultationen.",
    psychiatry         = utf8 "Psykiateren behandler patienter med psykiatriske lidelser og hjælper med diagnosticering af andre patienter, men forudsætter en læge med psykiatrisk uddannelse.",
    ward               = utf8 "Sengeafsnittet er nyttigt både til diagnosticering og behandling. Patienter sendes hertil for observation, men også som forberedelse til operationer. Sengeafsnittet kræver en sygeplejerske.",
    operating_theatre  = utf8 "Operationsstuen kræver to læger med speciale i kirurgi.",
    pharmacy           = utf8 "Sygeplejersken udleverer medicin på apoteket for at helbrede patienter.",
    cardiogram         = utf8 "En læge bruger löbebåndet til at udarbejde et kardiogram som kan bruges til at diagnosticere patienternes sygdomme.",
    scanner            = utf8 "En læge bruger skanneren til at diagnosticere patienterne.",
    ultrascan          = utf8 "En læge bruger ultraskanneren til at diagnosticere patienterne.",
    blood_machine      = utf8 "En læge bruger blodmaskinen til at diagnosticere patienterne.",
    x_ray              = utf8 "En læge bruger röntgenmaskinen til at diagnosticere patienterne.",
    inflation          = utf8 "En læge bruger pumperummet til at behandle patienter med opsvulmet hoved.",
    dna_fixer          = utf8 "En læge bruger DNA-Maskinen til at behandle patienter med Alien DNA.",
    hair_restoration   = utf8 "En læge bruger hårmaskinen til at behandle patienter med ekstremt hårtab.",
    tongue_clinic      = utf8 "En læge bruger tungeklinikken til at behandle patienter med slap tunge.",
    fracture_clinic    = utf8 "En sygeplejerske bruger knoglebrudsklinikken til at behandle knoglebrud.",
    training_room      = utf8 "Et undervisningsrum med en konsulent kan bruges til at oplære andre læger.",
    electrolysis       = utf8 "En læge bruger elektrolyseklinikken til at behandle patienter med ekstrem hårvækst.",
    jelly_vat          = utf8 "En læge bruger geleröret til at behandle patienter med Gelésyndrom.",
    staffroom          = utf8 "Læger, sygeplejersker og pedeller bruger personalerummet til at hvile sig og for at hæve moralen.",
    -- rehabilitation  = S[33][27], -- unused
    general_diag       = utf8 "En læge udförer forskellige undersögelser af patienter i dette rum. Billigt og ofte meget effektivt.",
    research_room      = utf8 "Læger med specialisering inden for forskning kan forske sig frem til ny medicin og maskiner i forskningsafdelingen.",
    toilets            = utf8 "Lav toiletter så patienterne ikke skal bruge deres kræfter på at klemme balderne sammen.",
    decontamination    = utf8 "En læge bruger dekontaminering til at behandle patienter som har været udsat for radioaktiv stråling.",
  },
  
  -- Objects
  objects = {
    -- NB: most objects do not have a tooltip because they're not (extra-)buyable
    desk                 = utf8 "Bord: En læge bruger bordet til sin computer.",
    cabinet              = "Arkivskab: Indeholder patientjournaler, noter og forskningsdokumenter.",
    door                 = utf8 "Dör: Patienter åbner og lukker disse meget.",
    bench                = utf8 "Bænk: Giver en plads at sidde på og gör besöget mere behageligt.",
    table1               = S[40][ 6], -- unused
    chair                = utf8 "Stol: Patienten sidder på den og taler om sine problemer.",
    drinks_machine       = utf8 "Sodavandsautomat: Forhindrer at patienterne kommer til at törste og tiltrækker insekter.",
    bed                  = "Seng: Patienterne ligger i dem.",
    inflator             = "Pumpe: Helbreder patienter med opsvulmet hoved.",
    pool_table           = utf8 "Billardbord: Hjælper dit personale til at slappe af.",
    reception_desk       = "Reception: Herfra bliver patienterne sendt videre til andre områder af dit hospital.",
    table2               = S[40][13], -- unused & duplicate
    cardio               = S[40][14], -- no description
    scanner              = S[40][15], -- no description
    console              = S[40][16], -- no description
    screen               = S[40][17], -- no description
    litter_bomb          = utf8 "Skraldebombe: Saboterer konkurrentens hospital",
    couch                = S[40][19], -- no description
    sofa                 = utf8 "Sofa: Ansatte slapper af i sofaen, hvis der ikke er bedre måder at slappe af på.",
    crash_trolley        = S[40][21], -- no description
    tv                   = utf8 "TV: Sörg for, at personalet ikke går glip af deres ynligsprogrammer.",
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
    toilet_sink          = utf8 "Vask: Her kan dine patienter vaske deres hænder. Hvis der ikke er nok håndvaske bliver de sure. Vaske er gode for hygiejnen.",
    op_sink1             = S[40][34], -- no description
    op_sink2             = S[40][35], -- no description
    surgeon_screen       = S[40][36], -- no description
    lecture_chair        = utf8 ": Når dine læger sidder her og tager noter, kan de kun blive klogere. Jo flere stole du har, jo större kan klassen være.",
    projector            = S[40][38], -- no description
    bed2                 = S[40][39], -- unused duplicate
    pharmacy_cabinet     = "Apotekskab: Fyldt med medicin.",
    computer             = utf8 "Computer: Genialt forskningsværktöj",
    atom_analyser        = utf8 "Atomanalyser: Placeres i forskningsafdelingen, og gör hele forskningsprocessen hurtigere.",
    blood_machine        = S[40][43], -- no description
    fire_extinguisher    = "Brandslukker: Mindsker risikoen for, at dine maskiner brænder sammen.",
    radiator             = utf8 "Radiator: Holder hospitalet varmt.",
    plant                = utf8 "Plante: Holder patienternes humör oppe og renser luften.",
    electrolyser         = S[40][47], -- no description
    jelly_moulder        = S[40][48], -- no description
    gates_of_hell        = S[40][49], -- no description
    bed3                 = S[40][50], -- unused duplicate
    bin                  = utf8 "Skaldespand: Patienterne smider deres skrald her.. i hvert fald de velopdragne",
    toilet               = utf8 "Toilet: Patienterne.. bruger dette.",
    swing_door1          = S[40][53], -- no description
    swing_door2          = S[40][54], -- no description
    shower               = S[40][55], -- no description
    auto_autopsy         = utf8 "Obduktionsautomat: Godt hjælpemiddel til at opdage nye behandlingsmetoder.",
    bookcase             = utf8 "Bogreol: Indeholder opslagsværker til læger.",
    video_game           = "Videospil: Lader personale slappe af med et spil Hi-Octane.",
    entrance_left        = S[40][59], -- no description
    entrance_right       = S[40][60], -- no description
    skeleton             = "Skelet: Bruges til undervisning og til Halloween.",
    comfortable_chair    = S[40][62], -- no description
  },
}

-- 32. 
    
adviser = {
  -- Epidemic
  epidemic = {
    hurry_up         = utf8 "Hvis du ikke tager dig af epidemien nu, kan du få store problemer. Skynd dig!",
    serious_warning     = utf8 "Den smitsomme sygdom begynder at blive et seriöst problem. Du må göre noget snart!",
    multiple_epidemies     = utf8 "Det ser ud som om du har mere end en epidemi i gang. Dette kan blive en enorm katastrofe for hospitalet!",
  },
  
  -- Staff advice
  staff_advice = {
    need_handyman_machines   = utf8 "Du bör ansætte flere pedeller til at tage sig af dine maskiner.",
    need_doctors       = utf8 "Du har brug for flere læger. Pröv at placere lægerne i de rum, hvor der er længst kö.",
    need_handyman_plants   = utf8 "Du skal ansætte en pedel til at vande planterne.",
    need_handyman_litter   = utf8 "Folk er begyndt at svine på dit hospital. Få en pedel til at rydde op efter dine patienter og köb eventuelt flere skraldespande.",
    need_nurses       = utf8 "Du har brug for flere sygeplejersker. Sengeafsnit og apoteker drives af sygeplejersker.",
    too_many_doctors     = utf8 "Jeg tror du har for mange læger. Nogle af dem har ikke noget at lave.",
    too_many_nurses     = utf8 "Jeg tror du har ansat for mange sygeplejersker.",
  },
  
  -- Earthquake
  earthquake = {
    damage     = utf8 "Jordskælvet har skadet %d maskiner og %d patienter i hospitalet.", -- %d (count machines), &d (count patients)
    alert     = utf8 "Jordskælvsvarsel! Under et jordskælv tager dine maskiner skade. De kan brænde sammen hvis de ikke er ordentligt vedligeholdt.",
    ended     = utf8 "Puha! Det var et stort skælv - det målte %d på Richters skala.",
  },
  
  -- Multiplayer
  multiplayer = {
    objective_completed       = utf8 "Du har klaret udfordringerne for denne bane - tillykke!",
    everyone_failed         = utf8 "Ingen klarede udfordringerne, så alle kan spille videre!",
    players_failed           = utf8 "Fölgende spiller(e) klarede ikke den forrige udfordring : ",
    
    poaching = {
      in_progress           = utf8 "Jeg skal sige fra denne person, at han gerne vil arbejde for dig.",
      not_interested         = utf8 "Ha! De er ikke interesserede i at arbejde for dig..",
      already_poached_by_someone   = utf8 "Ikke tale om! Andre pröver allerede at overtale personen.",
    },
    objective_failed         = utf8 "Det lykkedes ikke for dig at klare udfordringerne.",
  },
    
  -- Goals
  goals = {
    win = {
      money     = utf8 "Du skal opnå %d  for at klare de finansielle krav for denne bane.",
      cure       = utf8 "Når du har helbredt yderligere %d patienter har du helbredt nok til et gennemföre banen.",
      reputation   = utf8 "Sörg for at have et omdömme på over %d for at du kan genneföre banen.",
      value     = utf8 "Dit hospital skal have en værdi på over %d för du kan gennemföre banen",
    },
    lose = {
      kill       = utf8 "Dræb %d patienter mere og du har tabt banen!",
    },
  },

  -- Information
  information = {
    larger_rooms           = utf8 "Större rum får de ansatte til at föle sig bedre tilpas og forbedrer deres arbejde.",
    extra_items           = utf8 "Flere genstande i kontorer og lokaler får dine ansatte til at föle sig bedre tilpas og forbedrer deres præstationer.",
    epidemic             = utf8 "Der er en smitsom epidemi på dit hospital. Det skal du göre noget ved, NU!",
    promotion_to_doctor       = utf8 "En af dine praktikanter er blevet forfremmet til doktor.",
    emergency             = utf8 "Akkuttilfælde på vej, gör plads!",
    patient_abducted         = utf8 "En af dine patienter er blevet bortfört af et rumvæsen!",
    first_cure             = utf8 "Godt arbejde! Du har netop helbredt din förste patient! Fortsæt det gode arbejde.",
    promotion_to_consultant     = utf8 "En af dine læger er blevet forfremmet til konsulent.",
    handyman_adjust         = utf8 "Du kan göre en pedel mere effektiv ved at justere på hans prioriteringer.",
    promotion_to_specialist     = utf8 "En af dine læger er blevet forfremmet til %s.",
    patient_leaving_too_expensive   = utf8 "En patient forlader dit hospital. Dine priser er alt for höje for vedkommende!",
    vip_arrived           = utf8 "Tid til fokus! - %s er netop ankommet til dit hospital. Sörg for at alt körer på skinner, så du kan göre et godt indtryk.",
    epidemic_health_inspector     = utf8 "Sundhedsmyndighederne har fået besked om din epidemi. Du kan forvente et besög fra myndighederne meget snart.",
    first_death           = utf8 "Du har netop dræbt din förste patient. Hvordan har du det med det?!",
    pay_rise             = utf8 "En af dine ansatte truer med at sige op. Du skal vælge om du vil gå med til lönkravene eller om du vil fyre vedkommende. Klik på ikonet nede i venstre hjörne for at se, hvem som truer med at sige op.",
    place_windows           = utf8 "Vinduer gör rum lysere og forbedrer arbejdsglæden hos dine ansatte.",
    fax_received           = utf8 "Du har modtaget en fax. Du finder den i bunden af skærmen. En fax kan indeholde vigtig information som du skal forholde dig til.",
    
    initial_general_advice = {
      rats_have_arrived = utf8 "Rotterne har invaderet dit hospital! Pröv at skyde dem med musen.",
      autopsy_available = utf8 "Obduktionsautomaten er færdigudviklet. Med denne kan du få det bedste ud af patienter, som du ikke kan finde ud af hvad fejler.  Advarsel! - Brug af denne maskine er meget kontrovatielt, hvis offentligheden får kendskab til den, kan det få negative konsekvenser for dit omdömme.",
      first_patients_thirsty = utf8 "Flere af dine patienter er törstige. De ville sætte pris på flere sodavandsautomater.",
      research_now_available = utf8 "Du har bygget din förste forskningsafdeling. Du kan styre afdelingens arbejde via forskningsskærmen som du finder i bundet af skærmbilledet.",
      psychiatric_symbol = utf8 "Læger med prykiatrisk uddannelse kan genkendes med symbolet: |",
      decrease_heating = utf8 "Folk på dit hospital sveder. Skru ned for varmen, det kan du göre på oversigtskortet.",
      surgeon_symbol = utf8 "Læger kan udföre kirurgiske indgreb hvis de har symbolet: {",
      first_emergency = utf8 "Akutte patienter har et blinkende blåt lys over deres hoved. Hvis du ikke helbreder dem inden tiden löber ud, dör de!",
      first_epidemic = utf8 "Der er udbrudt en epidemi på dit hospital. Du skal tage stilling til, om du vil forsöge at behandle de ramte selv, eller om du vil betale dig fra det.",
      taking_your_staff = utf8 "Nogen pröver at stjæle dit personale. Du må kæmpe for at beholde dem.",
      place_radiators = utf8 "Patienterne fryser - du bör placere flere radiatorer i dit hospital så patienterne kan holde varmen.",
      epidemic_spreading = utf8 "Epidemien spreder sig på dit hospital. Du skal vaccinere de inficerede patienter inden de forlader hospitalet.",
      research_symbol = "Forskere er læger med symbolet: }",
      machine_needs_repair = utf8 "Du har udstyr i dit hospital som har brug for at blive repareret. Find udstyret - det ryger fra det - og klik på det for at tilkalde en pedel.",
      increase_heating = utf8 "Folk fryser på dit hospital. Du kan Skrue op for varmen på oversigtskortet.",
      first_VIP = utf8 "Du er ved at modtage dit förste VIP-besög. Sörg for at VIP'en ikke ser noget uhygiejnisk eller triste patienter.",
    },
  },
  
  
  -- Build advice
  build_advice = {
    placing_object_blocks_door     = utf8 "Hvis du placerer genstanden der, kan folk ikke komme til dören.",
    blueprint_would_block       = utf8 "Hvis du placerede rummet sådan, ville det blokere for andre rum. Pröv at ændre rumstörrelsen eller flyt rummet til et andet sted!",
    door_not_reachable         = utf8 "Folk kan ikke komme til dören.",
    blueprint_invalid         = utf8 "Det er ikke en gyldig skitse.",
  },
}

-- Confirmation
confirmation = {
  quit                 = utf8 "Du har valgt at afslutte spillet. Er du sikker på, at du vil forlade spillet?",
  return_to_blueprint  = utf8 "Er du sikker på, at du vil returnere til skitsen?",
  replace_machine      = utf8 "Er du sikker på du vil erstatte %s for %d?", -- %s (machine name) %d (price)
  overwrite_save       = utf8 "Der er allerede et spil gemt på denne plads. Skal det gemte spil overskrives?",
  delete_room          = "Vil du virkeligt slette dette rum?",
  sack_staff           = utf8 "Er du sikker på, at du vil give den ansatte sparket?",
  restart_level        = utf8 "Er du sikker på, at du vil starte forfra med denne bane?",
}

-- Bank manager
bank_manager = {
  hospital_value    = utf8 "Hospitalets værdi",
  balance           = "Balance",
  current_loan      = utf8 "Nuværende lån",
  interest_payment  = "Renter",
  insurance_owed    = "Forsikringer skyldet", -- Is this even used in the game?
  inflation_rate    = "Inflationsrate", -- Inflation rate.. never heard of that either.
  interest_rate     = "Rente",
  statistics_page = {
    date            = "Dato",
    details         = "Detaljer",
    money_out       = "Ud",
    money_in        = "Ind",
    balance         = "Balance",
    current_balance = utf8 "Nuværende balance",
  },
}


-- Letters
letter = {
    --original line-ends:             5          4               2    3
  [1] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Fantastisk! Du har drevet hospitalet virkelig godt. Vi i Ministeriet vil höre, om du er intersseret i et deltage i et större projekt. Vi har et job, som vi tror ville passe dig rigtig godt. Vi kan friste med en lön på $%d. Tænk over det.//",
    [3] = utf8 "Er du interessert i jobbet på hospitalet %s?",
  },
  [2] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Imponerende! Hospitalet er undergået en fantastisk udvikling. Vi har et andet sted, som du kan overtage, hvis du klar til nye udfordringer. Du behöver ikke tage udfordringen op, men det vil give en belönning i form af en lön på $%d//",
    [3] = utf8 "Er du interessert i at jobbet på hospitalet %s?",
  },
  [3] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Din tid på dette hospital har været ekstremt vellykket. Vi spår dig en stor fremtid, og önsker at tilbyde dig en stilling et andet sted. Lönnen vil være $%d, og vi tror du vil elske de nye udfordringer, stillingen förer med sig.//",
    [3] = utf8 "Er du interessert i jobbet på hospitalet %s?",
  },
  [4] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Tillykke! Vi i Ministeriet er meget imponerede over dine evner til drive hospitaler. Du er helt sikkert en gulddreng for sundhedsmyndighederne. Vi er overbeviste om, at du er klar til nye udfordringer på et större hospital. Vi er klar til at tilbyde en lön på $%d, men beslutningen er din.//",
    [3] = utf8 "Er du interessert i jobbet på hospitalet %s?",
  },
  [5] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Hej igen. Vi respekterer dine önsker om at ikke forlade dette fantastiske hospital som du har opbygget, men vi beder dig overveje din beslutning igen. Vi er klar til at tilbyde en god lön på $%d hvis du er klar på at flytte til et andet område og få skabt et respektabelt hospital.//",
    [3] = utf8 "Er du klar til nye udfordringer på hospitalet %s?",
  },
  [6] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Ministeriet hilser dig. Vi ved hvor glad du er blevet for dette nydelige og velorganiserede hospital, men vi mener, at du nu bör koncentrere dig om din karriere. Du vil få en respektabel lederlön på $%d hvis du bestemmer dig for at flytte. Det er i hvert fald en overvejelse værd.//",
    [3] = utf8 "Er du interessert i et nyt job på hospitalet %s?",
  },
  [7] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Goddag! Sundhedsministeren tænker på, om du vil revurdere din stilling på dit nuværende hospital. Vi sætter pris på dit nydelige hospital, men vi tror, at du vil göre meget for en lidt mere udfordrende stilling, og en lön på $%d.//",
    [3] = utf8 "Er du interessert i et job på hospitalet %s?",
  },
  [8] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Hej igen. Du tog ikke imod den forrige udfordring, da vi tilböd dig en alle tiders udfordring på et nyt hospital, og en lön på $%d. Vi mener, at tiden er inde til, at du bör revurdere beslutningen. Vi har det perfekte job til dig, tror vi.//",
    [3] = utf8 "Er du interessert i at tage jobbet på hospitalet %s?",
  },
  [9] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Du har mere end en gang bevist, at du er den bedste i sundhedsvæsnet. Ingen tvivl! En så fantastisk præstation skal belönnes, så vi önsker at tilbyde dig stillingen som Administrerende Direktör for Alle Sygehuse. Dette er en ærefuld stilling, og giver dig en lön på hele $%d. Du får din egen Ticker-Tape parade, og folk kommer til at vise deres taknemmelighed, hvor end du går.//",
    [3] = utf8 "Tak for alt du har gjort i din tid som hospitalsdirektör. Vi önsker dig en lang og fantastisk pension.//",
  },
  [10] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Tillykke! Du har drevet alle de hospitaler vi har givet dig ansvaret for på en udmærket facon. En sådan præstation kvalificerer dig til at få friheden til at rejse Jorden rundt. Du bliver belönnet med en pension på $%d, plus en limousine, og alt vi beder dig om er, at du rejser fra by til by, möder dine lidenskabelige fans, og promoverer hospitalets arbejde, hvor end du måtte befinde dig.//",
    [3] = utf8 "Vi er stolte af dig. Vi er alle taknemmelige over dit hårde arbejde som livredder.//",
  },
  [11] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Din karriere har været eksemplarisk, og du er en stor inspiration for os alle. Tak for, at du har drevet så mange hospitaler, og gjort det så godt i alle dine stillinger. Vi önsker at give dig en livslang lön på $%d, og alt vi beder dig om er at rejse officelt fra by til by, og fortælle folk, hvordan du tjente så mange penge.//",
    [3] = utf8 "Du er et pragteksempel for alle os andre, og vi önsker dig al lykke og glæde fremover!//",
  },
  [12] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Din succeskarriere som den beste hospitalsadministrator, den bedste siden Moses' tid, er ved vejs ende. Men siden du har haft så stor indvirkning på den medicinske verden, önsker Ministeriet at tilbyde dig en livsvarig lön på $%d bare for at være til stede på vore vegne, åbne fester, sösætte skibe og stille op i shows. Hele verden efterlyser dig, og du ville være fantastisk PR for os ude i verden!//",
    [3] = utf8 "Vær så venlig at tage imod denne stilling, det bliver ikke hårdt arbejde! Og vi skal sörge for, at du får politieskorte hvorend du kommer.//",
  },
}



-- Humanoid start of names
humanoid_name_starts = {
  [1] = utf8 "BJÖRN",
  [2] = utf8 "PER",
  [3] = "STOR",
  [4] = "GUL",
  [5] = "RIG",
  [6] = "SOL",
  [7] = "LANGE",
  [8] = "FLAD",
  [9] = utf8 "HÅRD",
  [10] = "MYG",
  [11] = "BAR",
  [12] = "SKODDE",
  [13] = utf8 "MÖRKE",
  [14] = utf8 "BLÅ",
  [15] = "KRIG",
  [16] = "LAT",
  [17] = "KRABBE",
  [18] = "FISK",
  [19] = utf8 "VÅD",
  [20] = "SEN",
  [21] = "GRAV",
  [22] = "BAK",
  [23] = "LAVE",
  [24] = "UD",
  [25] = "ENGE",
  [26] = utf8 "GRÖN",
  [27] = "KUR",
  [28] = "KVIT",
  [29] = "KJEVE",
  [30] = "TRYGLE",
  [31] = "KVÆAEN",
  [32] = "KRYKKE",
  [33] = "SKADE",
}

-- Humanoid end of names
humanoid_name_ends = {
  [1] = "STAD",
  [2] = "BERG",
  [3] = "NES",
  [4] = "DAL",
  [5] = "LID",
  [6] = "HEIM",
  [7] = "HEM",
  [8] = "LAND",
  [9] = "SETH",
  [10] = "RUD",
  [11] = "VIK",
  [12] = utf8 "BÖ",
  [13] = "GAARD",
  [14] = utf8 "GÅRD",
  [15] = "HAUG",
  [16] = "LUND",
  [17] = "LOFT",
  [18] = utf8 "VER",
  [19] = "SAND",
  [20] = "LIE",
  [21] = "VOLD",
  [22] = utf8 "STRÖM",
  [23] = "LI",
  [24] = "DALEN",
  [25] = "DAHL",
  [26] = "BAKKEN",
}


-- VIP names
vip_names = {
  health_minister = "Sundhedsministeren",
  "Peter Brixtofte", -- A guy that liked to drink VERY expensive vine on the whole cities bill.
  "Prins Henrik",
  "Master fatman",
  "Anders Fogh",
  "Lars Hjortshöj",
  "Svampebob",
  utf8 "Jes Dorph",
  "Michael Laudrup",
  "Lars larsen", -- Jysk sengetöjslager
  utf8 "Justin bæver",  -- Dont think i like him.. i hate him!
}

-- Deseases
diseases = {
  general_practice       = { 
    name     = utf8 "Lægekonsultation", 
  },
  bloaty_head        = { 
    name        = "Opsvulmet hoved", 
    cause       = utf8 "Årsag - Patienten har sniffet ost og drukket forurenet vand.", 
    symptoms    = "Symptomer - Den ramte har det meget ukomfortabelt. Föler mildest talt en vis oppustethed i hovedregionen.", 
    cure        = utf8 "Behandling - Der stikkes hul på det opsvulmede hoved, og ved hjælp af en genial maskine bliver hovedet sat tilbage til den korekte PSI.", 
  },
  hairyitis              = { 
    name      = "Ekstrem hårvækst", 
    cause     = utf8 "Årsag - Lange gåture i måneskin medförer en uhensigtsmæssig udsættelse for månens stråler, som beskadiger hovedbunden og forårsager hårvækst i ukontrollabelt omfang på resten af kroppen.", 
    symptoms  = "Symptomer - Nedsat fremdrift i vand.", 
    cure      = utf8 "Behandling - En elektrolysemaskine fjerner hårvæksten og tilbageförer porene til deres normale stadie.", 
  },
  king_complex           = { 
    name     = "Kongekompleks", 
    cause     = utf8 "Årsag - Elivs' ånd har taget kontrollen over patienten", 
    symptoms   = utf8 "Symptomer - Går med farvede lædersko, spiser cheesebrugere og udsætter hofter og knæ for ganske akavede stillinger", 
    cure     = utf8 "Behandling - En psykiater fortæller patienten hvor tåbelig han ser ud", 
  },
  invisibility           = { 
    name     = "Usynlighed", 
    cause     = utf8 "Årsag - Bidt af en radioaktiv (og usynlig) myre", 
    symptoms   = utf8 "Symptomer - Patienten lider ikke - tværtimod! De udnytter situationen og lurer på deres familie og venner!", 
    cure     = utf8 "Behandling - En farverig drik fra apoteket gör patienten fuldt synlig igen", 
  },
  serious_radiation      = { 
    name     = utf8 "Alvorlig bestråling",
    cause     = utf8 "Årsag - Har forvekslet plutonium-isotoper med tyggegummi", 
    symptoms   = utf8 "Symptomer - Patienten föler sig meget ukomfortabel", 
    cure     = utf8 "Behandling - Patienten placeres i en saniteringsbruser og renset fuldstændigt.", 
  },
  slack_tongue           = { 
    name     = utf8 "Slap tunge", 
    cause     = utf8 "Årsag - Kronisk overivrighed i diskussioner om sæbeoperaer.", 
    symptoms   = utf8 "Symptomer - Tungen hæver til det femdobbelte.", 
    cure     = utf8 "Behandling - Tungen bliver placeret i en tungeskærer. Hævelsen fjernes derefter hurtigt, effektivt og smertefuldt.",
  },
  alien_dna              = { 
    name     = utf8 "Udenjordisk DNA", 
    cause     = utf8 "Årsag - Patienten er blevet bidt af iler udstyret med intelligent rumvæsenblod.", 
    symptoms   = utf8 "Symptomer - Er under gradvis forvandling til et rumvæsen, og udvikler et önske om at overtage verdensherredömmet", 
    cure     = utf8 "Behandling - Alt DNA fjernes mekanisk, renses for rumvæsenceller, og bliver hurtig erstattet",
  },
  fractured_bones        = { 
    name     = "Knoglebrud",
    cause     = utf8 "Årsag - Fald fra höjder ned på beton", 
    symptoms   = utf8 "Symptomer - Höje knaselyde og meget lidt bevægelighed på de udsatte steder", 
    cure     = utf8 "Behandling - Gipsen fjernes ved hjælp af en laserstyret gipsfjerner", 
  },
  baldness               = { 
    name     = "Ekstremt hårtab", 
    cause     = utf8 "Årsag - Fortæller lögne og opdigter historier for at forbedre sin popularitet.", 
    symptoms   = "Symptomer - Forlegen patient med skinnende pande.", 
    cure     = utf8 "Behandling - Håret bliver hurtigt smeltet fast til patientens hoved med en smertefuld hårmaskine.",
  },
  discrete_itching       = { 
    name     = "Skrabesyge", 
    cause     = utf8 "Årsag - Små insekter med skarpe tænder.", 
    symptoms   = utf8 "Symptomer - Patienten klör intenst, og huden slår revner.", 
    cure     = utf8 "Behandling - En sygeplejeske giver patienten en sirupagtig drik som heler huden og som hindrer flere revner.",
  },
  jellyitis              = { 
    name     = utf8 "Gelésyndrom", 
    cause     = utf8 "Årsag - Geletholdig kost og megen motion.", 
    symptoms   = utf8 "Symptomer - Meget ustabil og falder ofte.", 
    cure     = utf8 "Behandling - Patienten bliver presset ned i et gelérör i et specielt rum.",
  },
  sleeping_illness       = { 
    name     = utf8 "Sövnsyge", 
    cause     = utf8 "Årsag - Forårsaget af overaktive sövnkirtler i ganen.", 
    symptoms   = utf8 "Symptomer - Stærkt önske om at sove, hvor og når som helst.", 
    cure     = "Behandling - En stærk dosis af stimulerende medicin uddelt af en sygeplejerske.",
  },
  pregnancy              = { 
    name     = "Graviditet", 
    cause     = utf8 "Årsag - Forårsaget af strömafbrydelser i bebyggede områder.", 
    symptoms   = utf8 "Symptomer - Spiser ustandseligt og udvikler en ölmave.", 
    cure     = "Behandling - Sprædbanet fjernes ved kejsersnit, vaskes og præsenteres derefter for sin mor.",
  },   -- unused
  transparency           = { 
    name     = "Gennemsigtighed", 
    cause     = utf8 "Årsag - Slikket på folien på gamle yougurtkartoner.", 
    symptoms   = "Symptomer - Kroppen bliver gennemsigtig og ækel.", 
    cure     = utf8 "Behandling - En kölig, farverige drik fra apoteket skulle göre underværker.",
  },
  uncommon_cold          = { 
    name     = utf8 "Forkölelse",
    cause     = utf8 "Årsag - Små smörpartikler i luften.", 
    symptoms   = "Symptomer - Rendende næse, hoste og misfarvet slim fra lungerne.", 
    cure     = utf8 "Behandling - En rigtig stor mundfuld hostesaft fra apoteket medförer öjeblikkelig lindring.", 
  },
  broken_wind            = { 
    name     = "Forurenende gasser", 
    cause     = utf8 "Årsag - Löb på en trædemölle umiddelbart efter indtagelse af frokost.", 
    symptoms   = "Symptomer - Ubehag hos folk som befinder sig i patientens nærhed.", 
    cure     = utf8 "Behandling - En stærk blandning af specielle vandatomer der drikkes hurtigt.",
  },
  spare_ribs             = { 
    name     = "Spareribs", 
    cause     = utf8 "Årsag - Patienten har siddet for længe på et koldt gulv.", 
    symptoms   = utf8 "Symptomer - Ubehagelig fölelse i brystet.", 
    cure     = "Behandling - Ribbenene fjernes af to kirurger, og leveres til patienten i en doggybag.",
  },
  kidney_beans           = { 
    name     = "Kikærter", 
    cause     = utf8 "Årsag - patienten har spist isterninger.", 
    symptoms   = utf8 "Symptomer - Smerte og hyppige ture til toilettet", 
    cure     = utf8 "Behandling - To kirurger fjerner de ærtelignende parasitter, uden at beröre nyrerne!",
  },
  broken_heart           = { 
    name     = "Knust hjerte",
    cause     = utf8 "Årsag - Nogen er rigere, yngre og slankere end patienten.", 
    symptoms   = utf8 "Symptomer - Hysterisk grædende. Blodsprængte fingerspidser efter at have revet feriebilleder i stykker.", 
    cure     = "Behandling - To kirurger sprætter brystet op og sætter derefter hjertet forsigtigt sammen, mens de holder vejret.", 
  },
  ruptured_nodules       = { 
    name     = utf8 "Ödelagte nödder", 
    cause     = utf8 "Årsag - Skihop om vinteren.", 
    symptoms   = utf8 "Symptomer - Umulig at sidde ned med vedbehag.", 
    cure     = utf8 "Behandling - To kvalificerede kirurger må fjerne nödderne med forsigtige hænder.",
  },
  tv_personalities       = { 
    name     = "Programledersyndrom", 
    cause     = utf8 "Årsag - Ser TV i dagstimerne.", 
    symptoms   = utf8 "Symptomer - Forestiller sig at han/hun er programleder på formiddagstv og elsker at introducere madseancen.", 
    cure     = utf8 "Behandling - En psykiater må overtale patienten til at köbe en radio og sælge fjernsynet.",
  },
  infectious_laughter    = { 
    name     = "Smitsom latter", 
    cause     = utf8 "Årsag - Klassisk komedie på TV.", 
    symptoms   = utf8 "Symptomer - Ler hjælpelöst hele tiden og gentager dårlige passager som absolut ikke er morsomme.", 
    cure     = utf8 "Behandling - En kvalificeret psykiater må göre det klart for patienten, at det faktisk er en alvorlig tilstand.",
  },
  corrugated_ankles      = { 
    name      = utf8 "Böjede ankler", 
    cause     = utf8 "Årsag - Kört med bus over fartbump.", 
    symptoms   = "Symptomer - Skoene passer ikke.", 
    cure     = utf8 "Behandling - En giftig blanding af urter og krydderier må drikkes for at udrette anklerne.",
  },
  chronic_nosehair       = { 
    name     = utf8 "Kronisk næsehår", 
    cause     = utf8 "Årsag - Snöfter med foragt af folk med lavere indlægt.", 
    symptoms   = utf8 "Symptomer - Så mange næsehår at en grævling kunne bo der.", 
    cure     = utf8 "Behandling - En ækel, hårfjernende kur som skal drikkes. Fås på apoteket.",
  },
  third_degree_sideburns = { 
    name     = "Tredjegrads bakkenbarter", 
    cause     = utf8 "Årsag - Længes efter 70-erne.", 
    symptoms   = utf8 "Symptomer - Stort hår, farverigt töj, lange bakkenbarter og glitter.", 
    cure     = utf8 "Behandling - Psykiatrisk personale må, ved brug af moderne teknikker, overbevise patienten om, at paryk yt.",
  },
  fake_blood             = { 
    name     = "Teaterblod", 
    cause     = utf8 "Årsag - Patienten er ofte udsat for narrestreger.", 
    symptoms   = utf8 "Symptomer - Rödt blod som fremkommer når der er kontakt med töj.", 
    cure     = utf8 "Behandling - Eneste måde at behandle dette på er at få en psykiater til at berolige patienten.",
  },
  gastric_ejections      = { 
    name     = utf8 "Sure opstöd", 
    cause     = utf8 "Årsag - Stærk krydret mexikansk eller indisk mad.", 
    symptoms   = "Symptomer - Gylper karrykylling og tacostykker op..", 
    cure     = utf8 "Behandling - En sygeplejerske giver patienten en speciel indisk komælk som forhindrer sure opstöd.",
  },
  the_squits             = { 
    name     = utf8 "Tynd mave", 
    cause     = utf8 "Årsag - Har spist pizzastykker som har været på gulvet.", 
    symptoms   = utf8 "Symptomer - Uh. Tror du kender symptomerne.", 
    cure     = utf8 "Behandling - En klæbrig blanding af kemikalier der skal drikkes for at stabilisere maven.",
  },
  iron_lungs             = { 
    name     = "Jernlunger", 
    cause     = utf8 "Årsag - Forurenet luft indeholdende bly og kebabrester.", 
    symptoms   = utf8 "Symptomer - Kan lave flammer og råbe höjlydt under vand.", 
    cure     = "Behandling - To kirurger blödgör de hårde lunger i operationsstuen.",
  },
  sweaty_palms           = { 
    name     = utf8 "Svedige håndflader", 
    cause     = utf8 "Årsag - Har lige været til jobsamtale.", 
    symptoms   = utf8 "Symptomer - At give hånd til patienten er som at give hånd til en våd svamp.", 
    cure     = utf8 "Behandling - En pskiater taler med patienten om lidelsen.",
  },
  heaped_piles           = { 
    name     = "Hæmorider", 
    cause     = utf8 "Årsag - Siddet for længe på det kolde gulv.", 
    symptoms   = utf8 "Symptomer - Patienten föler, at han/hun sidder på en pose sten.", 
    cure     = utf8 "Behandling - En behagelig, men syrlig væske som löser hæmorideproblemet.",
  },
  gut_rot                = { 
    name     = utf8 "Dårlig mave", 
    cause     = utf8 "Årsag - Onkel Georges blanding af hostesaft og whisky.", 
    symptoms   = "Symptomer - Ingen hoste, men heller ingen mavesæk.", 
    cure     = "Behandling - En sygeplejerske udskriver en række kemikalier som genskaber væggene i mavesækken.",
  },
  golf_stones            = { 
    name     = "Golfsten", 
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


-- Faxes
fax = {
  -- Debug fax
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
  
  -- Emergency
  emergency = {
    choices = {
      accept = utf8 "Ja, jeg kan håndtere dette akkuttilfælde", 
      refuse = utf8 "Nej, jeg nægter at tage mig af dette akkuttilfælde",
    },
    location                = "Der er sket en ulykke ved %s", 
    num_disease              = utf8 "Der er %d mennesker med %s som har brug for behandling med det samme.",
    cure_possible_drug_name_efficiency = utf8 "Du har den medicin som er nödvendig for at behandle patienterne. Det er %s og medicinen er %d procent effektiv.", 
    cure_possible              = utf8 "Du har det nödvendige udstyr og de færdigheder som skal bruges for at håndtere akuttilfældet.", 
    cure_not_possible_build_and_employ = utf8 "Det vil være nödvendigt at bygge %s og ansætte en %s",
    cure_not_possible_build            = utf8 "Du mangler %s for at håndtere dette",
    cure_not_possible_employ           = utf8 "Du mangler en %s for at kunne håndtere dette",
    cure_not_possible                  = utf8 "Du kan ikke behandle denne sygdom i öjeblikket",
    bonus                              = utf8 "Hvis du klarer dette akkuttilfælde, vil du modtage en bonus på maksimalt %d. Hvis du derimod fejler, vil det få negative fölger for dit omdömme.",
    
    locations = {      
      utf8 "A.Tom's Våbenkælder",
      "Snoppeuniversitetet",       
      "Buskerud Hagecenter", 
      "Forskningsinstituttet For Farlige Emner", 
      "Foreningen For Folkedansende Mænd", 
      "Puben Frosk Og Kyr", 
      utf8 "Hallgeir Juniors Begravelses- og Spritbutik",
      "Mamma-Tai Krydderhus", 
      "Berts Varehus For Brugt Petrokemi", 
    },
  },

  emergency_result = {
    close_text     = utf8 "Klik for at lukke",
    earned_money   = utf8 "Af den maksimale bonus på %d, har du tjent %d.",
    saved_people   = "Du reddede %d mennesker af i alt %d.",
  },  
  
  -- Deseace discovered
  disease_discovered_patient_choice = {
    choices = {
      send_home = "Send patienten hjem.",
      wait      = utf8 "Få patienten til at vente et stykke tid på hospitalet.",
      research  = "Send patienten til forskningsafdelingen.",
    },
    need_to_build_and_employ = utf8 "Hvis du bygger %s og ansætter en %s kan du löse problemet med det samme.",
    need_to_build            = utf8 "Du skal bygge %s for at kunne håndtere dette.",
    need_to_employ           = utf8 "Ansæt en %s for at hjælpe patienten.",
    can_not_cure             = "Du kan ikke behandle denne sygdom.",
    disease_name             = utf8 "Dine ansatte er stödt på et tilfælde af %s.",
    what_to_do_question      = utf8 "Hvad skal vi göre med patienten?",
    guessed_percentage_name  = "Dine læger mener, at de ved hvad patienten fejler. Der er %d procent sandsynlighed for at det er %s",
  },
  
  disease_discovered = {
    close_text          = "Luk.",
    can_cure          = "Du kan behandle denne sygdom.",
    need_to_build_and_employ = utf8 "Hvis du bygger %s og ansætter en %s kan du håndtere dette.",
    need_to_build            = utf8 "Du skal bygge %s for at håndtere dette.",
    need_to_employ           = utf8 "Ansæt en %s for at behandle patienter med denne sygdom.",
    discovered_name          = "Dine læger har oppdaget et tilfælde af %s.",
  },
  
  -- Epidemic
  epidemic = {
    choices = {
      declare  = utf8 "Offentliggör epidemien og betal en böde. Dit omrömme vil blive svækket.",
      cover_up = utf8 "Forsög at behandle alle inficerede patienter inden tiden löber ud, og för nogen smittede forlader hospitalet.",
    },
    
    disease_name             = utf8 "Dine læger har opdaget en meget smitsom form for %s.",
    declare_explanation_fine = utf8 "Hvis du offentliggör epidemien, skal du betale en böde på %d og dit omdömme lider et knæk, men samtlige patienter bliver vaccineret automatisk.",
    cover_up_explanation_1   = utf8 "Hvis du derimod forsöger at holde epidemien skjult, skal du behandle samtlige vaccinerede patienter för sundhedsmyndighederne opdager, hvad der foregår.",
    cover_up_explanation_2   = utf8 "Hvis en sundhedsinspektör kommer på besög og finder ud af, at du har forsögt at skjule epidemien, vil han gå drastisk til værks.",
  },
  
  -- Epidemic result
  epidemic_result = {
    close_text = "Hurra!",
    
    failed = {
      part_1_name = utf8 "Du forsögte at skjule det faktum, at vi stod overfor et smitsomt udbrud af %s.",
      part_2      = utf8 "Selvfölgelig var dine medarbejdere i stand til at sprede epidemien til alle hospitalets naboer.",
    },
    succeeded = {
      part_1_name = utf8 "Sundhedsinspektören hörte rygter om at dit hospital kæmpede med et alvorligt tilfælde af %s.",
      part_2      = utf8 "Han har dog ikke fundet noget, som har kunne bekræfte rygterne.",
    },
    
    compensation_amount  = utf8 "Myndigherne har besluttet at give dig en kompensation på %d for den skade, dit ellers gode rygte har lidt.",
    fine_amount          = utf8 "Myndighederne har erklæret en national undtagelsestilstand og forlanger, at du betaler en böde på %d.",
    rep_loss_fine_amount = utf8 "Velkommen på forsiden! Dit rygte har fået en ordenligt lussing! Samtidigt får du en böde på %d.",
    hospital_evacuated   = utf8 "Sundhedsmyndighederne ser ingen anden mulighed end at evakuere dit hospital.",
  },
  
  -- VIP visit query
  vip_visit_query = {
    choices = {
      invite = "Send en officiel invitation.",
      refuse = utf8 "Afvis besöget med en dårlig undskyldning.",
    },
    
    vip_name = utf8 "%s har ytret et önske om at besöge dit hospital",
  },
  
  -- VIP visit result
  vip_visit_result = {
    close_text = utf8 "Tak fordi du besögte hospitalet.",
    telegram          = utf8 "Telegram!",
    vip_remarked_name = utf8 "Efter sit besög på dit hospital, udtalte %s fölgende:",
    cash_grant = utf8 "Du får %d i kontanter.",
    rep_boost  = utf8 "Dit ry i nærområdet har fået en optur.",
    rep_loss   = utf8 "Dit ry i nærområdet har taget skade.",
    
    remarks = {
      super = {
        "Det er et meget flot hospital. Næste gang jeg bliver alvorligt syg, vil jeg indlægges der.",
        "Se det er hvad jeg kalder for et hospital af topklasse!",
        utf8 "Et super hospital, og det er noget jeg ved en del om, for jeg har været indlagt en hel del gange.",
      },
      good = {
        utf8 "Det er et godt organiseret hospital. Tak fordi jeg måtte komme.",
        utf8 "Hmm. Det er absolut ikke noget dårligt sted, jeg har set.",
        utf8 "Jeg kan godt lide dit charmerende hospital. Forresten, er der nogen som vil med ud at spise indisk?",
      },
      mediocre = {
        utf8 "Nå, jeg har set værre. Men du kunne göre en lang række forbedringer.",
        utf8 "Åh, min kære tid. Det her er ikke det sted man går hen, hvis man föler sig dårlig.",
        utf8 "Et helt normalt hospital, for at være ærlig. Jeg havde forventet noget mere.",
      },
      bad = {
        utf8 "Hvad laver jeg egentlig her?! Det er jo værre end en fire timers opera!",
        "Det var ækelt! Kalder du det her et hospital?! Det ligner mere en svinesti!",
        utf8 "Jeg er træt af at være en offentlig person, og træt af at skulle besöge steder som dette stinkende hul! Jeg siger op!.",
      },
      very_bad = {
        utf8 "Föj for et syn! Dette hospital skal jeg nok få lukket ned!",
        utf8 "Jeg har aldrig set magen. Det er en skandale!",
        utf8 "Jeg er chokeret! Du kan ikke kalde dette et hospital! Jeg går ud og tager mig en stærk drink!",
      },
    },
  },
  
  -- Diagnosis failed
  diagnosis_failed = {
    choices = {
      send_home   = "Send patienten hjem",
      take_chance = utf8 "Tag chancen med den mest sandsynlige diagnose.",
      wait        = utf8 "Få patienten til at vente mens du bygger flere diagnoserum.",
    },
    situation = utf8 "Vi har prövet alle vores diagnoserum på denne patient, men vi er ikke helt sikre på, hvad patienten fejler.",
    what_to_do_question = utf8 "Hvad skal vi göre med patienten?",
    partial_diagnosis_percentage_name = "Det er %d procent sikkert at patienten har en type af %s, men hvis vi tager fejl, kan det få alvorlige konsekvenser for patienten.",
  },
}

-- Queue window
queue_window = {
  num_in_queue       = utf8 "Antal ventende",
  num_expected       = "Yderligere på vej",
  num_entered        = utf8 "Antal besög",
  max_queue_size     = "Maks kö",
}

-- Dynamic info
dynamic_info = {
  patient = {
    actions = {
      dying                       = utf8 "Döende",
      awaiting_decision           = utf8 "Venter på din beslutning",
      queueing_for                = utf8 "I kö til %s", -- %s
      on_my_way_to                = utf8 "På vej til %s", -- %s
      cured                       = "Helbredt!",
      fed_up                      = "Irriteret, forlader hospitalet",
      sent_home                   = "Sendt hjem",
      sent_to_other_hospital      = "Henvist til et andet hospital",
      no_diagnoses_available      = "Ikke flere diagnosemuligheder",
      no_treatment_available      = utf8 "Ingen behandling er mulig - Jeg går hjem",
      waiting_for_diagnosis_rooms = utf8 "Venter på du byggger flere diagnoserum",
      waiting_for_treatment_rooms = utf8 "Venter på du bygger et behandlingsrum",
      prices_too_high             = utf8 "Prisene er for höje - Jeg går hjem",
      epidemic_sent_home          = utf8 "Sendt hjem af inspektör",
      epidemic_contagious         = utf8 "Jeg er smittebærende",
    },
    diagnosed                   = "Diagnose: %s", -- %s
    guessed_diagnosis           = utf8 "Gættet diagnose: %s", -- %s
    diagnosis_progress          = "Diagnoseproces",
    emergency                   = "Akut: %s", -- %s (disease name)
  },
  vip                           = utf8 "Besögende VIP",
  health_inspector              = utf8 "Sundhedsinspektör",
  
  staff = {
    psychiatrist_abbrev         = "Psyk.",
    actions = {
      waiting_for_patient         = utf8 "Venter på patient",
      wandering                   = "Vandrer rundt",
      going_to_repair             = "Skal reparere %s", -- %s (name of machine)
    },
    tiredness                   = utf8 "Udbrændthed",
    ability                     = "Evner", -- unused?
  },
  
  object = {
    strength                    = "Udholdenhed: %d", -- %d (max. uses)
    times_used                  = "Timer brugt: %d", -- %d (times used)
    queue_size                  = utf8 "Kölængde: %d", -- %d (num of patients)
    queue_expected              = utf8 "Forventet kölængde: %d", -- %d (num of patients)
  },
}


   introduction_texts = {
  level17 = {
    [1] = utf8 "Dette er sidste advarsel - hold öje med dit omdömme - det er det, som tiltrækker patienter til dit hospital. ",
    [2] = utf8 "Hvis der ikke dör for mange patienter og du samtidig holder resten af patienterne i nogenlunde godt humör, skulle denne bane ikke være noget problem.//",
    [3] = utf8 "Nu må du klare dig selv. Held og lykke!",
  },
  level1 = {
    [1] = utf8 "Velkommen til dit förste hospital!//",
    [2] = utf8 "Du kan komme godt fra start ved at ved at få placeret en reception, bygge en lægekonsultation og ansætte en læge og en receptionist. ",
    [3] = utf8 "Derefter kan du åbne hospitalet, og de første patienter vil derefter begynde at ankomme til hospitalet.",
    [4] = utf8 "Det vil være fornuftigt at bygge en psykiatri rimelig hurtigt og ansætte en læge med speciale i psykiatri. ",
    [5] = utf8 "Et apotek og en sygeplejerske er essentielle for at helbrede dine patienter. Mange sygdomme behandles nemlig med medicin. ",
    [6] = utf8 "Læg mærke til hvis der er mange tilfælde af opsvulmet hoved - et pumperum kan klare opgaven. ",
    [7] = utf8 "For at gennemföre banen skal du helbrede mindst 10 patienter og sörge for, at dit omdömme ikke dykker under 200. ",
  },
  level9 = {
    [1] = utf8 "Efter du har fyldt ministerens bankkonto op og betalt for hans nye limousine, kan du nu koncentrere dig om at lave et omsorgsfuldt, velfungerende hospital for de trængende. ",
    [2] = utf8 "Du må forvente at möde en række problemer her.",
    [3] = utf8 "Hvis du har nok lokaler og flinke ansatte, vil du sikkert få styr på banens udfordringer. ",
    [4] = utf8 "Dit hospital skal have en værdi af 200,000, og du skal have mindst 400,000 i banken. ",
    [5] = utf8 "Mindre kan ikke göre det.",
  },
  level2 = {
    [1] = utf8 "Der er store problemer med sygdomme i dette område. ",
    [2] = utf8 "Byg hospitalet med henblik på at behandle flere patienter og anlæg en forskningsafdeling. ",
    [3] = utf8 "Husk at holde hospitalet rent og stræb efter at få så höjt et omdömme som muligt - hvis du vil kunne håndtere sygdomme som slap tunge, bliver det nödvendigt at bygge en tungeklinik. ",
    [4] = utf8 "Du kan også bygge et löbebånd for at forbedre diagnosticeringen. Disse rum er först tilgængelige, når du har forsket i området i din forskningsafdeling. ",
    [5] = utf8 "Du kan udvide hospitalet så du får mere plads at bygge på - brug oversigtskortet til dette ",
    [6] = utf8 "Stræb efter at få et omdömme på 300 og en banksaldo på 10,000, samt helbrede mindst 40 patienter. ",
  },
  level7 = {
    [1] = utf8 "Her vil du være under overvågning af sundhedsmyndighederne, så husk at få det til at se ud som om du tjener kassen samtidig med at du opbygger et godt omdömme. ",
    [2] = utf8 "Vi kan ikke holde til unödvendige dödsfald - de er dårlige for virksomheden. ",
    [3] = utf8 "Vær sikker på at dit personale er i tip-top form, og at du har alt det udstyr, de har brug for. ",
    [4] = "Opbyg dit omdömme til 600, og få 200,000 ind på din bankkonto.",
  },
  level5 = {
    [1] = utf8 "Dette bliver et travlt hospital, hvor du skal håndtere en lang række sager. ",
    [2] = utf8 "Alle læger kommer direkte fra fakultetet, så det er vitalt, at du får bygget et undervisningsrum og uddanner lægerne så de bliver dygtigere, hurtigere og gerne så de får et speciale eller to. ",
    [3] = utf8 "Du har kun tre konsulenter til at undervise dit uerfarende personale med, så hold dem glade. ",
    [4] = utf8 "Hold for öje, at hospitalet er bygget på San Androids geologiske undergrund. ",
    [5] = utf8 "Der er derfor en evig risiko for, at der kommer jordskælv. ",
    [6] = utf8 "Jordskælv kan forårsage betydlig skade på dine maskiner og påvirke effektiviteten på dit hospital. ",
    [7] = utf8 "Få dit omdömme op på 400 og din bankbalance op på 50,000 for at gennemföre banen. Du skal også helbrede 200 patienter.",
  },
  level4 = {
    [1] = utf8 "Hold alle dine patienter glade, få dem hurtigt igennem systemet og hold dödstallet så lavt som muligt.",
    [2] = utf8 "Dit omdömme er på spil, sörg for at have et så godt omdömme som muligt.",
    [3] = utf8 "Lad være med at fokusere for meget på pengene - de skal nok rulle ind i takt med dit stigende omdömme. ",
    [4] = utf8 "Det vil være muligt for dig at undervise dine læger, så de kan udvikle deres evner og blive endnu hurtigere. ",
    [5] = utf8 "Undervisningen varetages af konsulenter. Hvis de har særlige færdigheder som psykiater eller kirurg, vil deres elever med tiden også blive oplært i disse færdigheder. Og det kan de hurtigt få brug for, når patienter med mere krævende sygdomme begynder at ankomme. ",
    [6] = utf8 "Opnå et omdömme på mere end 500.",
  },
  level14 = {
    [1] = utf8 "Der er lige en udfordring mere - det fuldstændigt uregerlige hospital. ",
    [2] = utf8 "Hvis det lykkedes for dig at göre dette hospital til en succes, vil du være en mester af mestrene. ",
    [3] = utf8 "Men forvent ikke, at du kan tage den på rutinen, for dette er den stöste udfordring, du nogensinde vil möde. ",
    [4] = utf8 "Held og lykke!",
  },
  level15 = {
    [1] = utf8 "Sådan, det er det mest basale, som holder et hospital sammen.//",
    [2] = utf8 "Dine læger får brug for al den hjælp de kan få til at diagosticere patienterne. Du kan hjælpe dig ved at",
    [3] = utf8 "bygge andre diagnose faciliteter, så som et generel diagnoserum.",
  },
  level8 = {
    [1] = utf8 "Det er op til dig at skabe det mest effektive og produktive hospital som muligt. ",
    [2] = utf8 "Folk fra dette område er ret velhavende, så pres dem for så mange penge som muligt. ",
    [3] = utf8 "Husk: At helbrede folk er meget rart, men du har VIRKELIG BRUG FOR de penge det giver.",
    [4] = utf8 "Flå disse patienter indtil selv Stein Bagger ville få moralske skrubler! ",
    [5] = utf8 "Opnå et massivt overskud på 300,000 for at gennemföre denne bane.",
  },
  level13 = {
    [1] = utf8 "Dine fantastiske evner til at administrere et hospital, er blevet bemærket af en speciel hemmelig afdeling under hemmelige specielle afdelinger. ",
    [2] = utf8 "De har en speciel bonus til dig; der er et rotteproblem på et hospital, som mangler en kærlig hånd. ",
    [3] = utf8 "Du skal skyde så mange rotter som muligt för pedellerne kan rydde op i skidtet. ",
    [4] = utf8 "Tror du, at du kan klare opgaven?",
  },
  level16 = {
    [1] = utf8 "Når du har diagnosticeret nogle af patienterne, bliver du nödt til at bygge behandlingsfaciliteter og klinikker til at helbrede dem - en godt sted at begynde med",
    [2] = utf8 "er et apotek. Du skal bruge en sygeplejerske til at udlevere medicinen.",
  },
  level6 = {
    [1] = utf8 "Brug al din viden til at udvikle et velfungerende og komfortabelt hospital, som kan skabe et sundt overskud og håndtere alle former for sygdomme, som samfundet smider efter det. ",
    [2] = utf8 "Du skal være opmærksom på, at atmosfæren i dette område er perfekt til at bære infektioner og sygdomme. ",
    [3] = utf8 "Med mindre du holder dit hospital helt rent, risikerer du, at der udbryder epidemier blandt patienterne. ",
    [4] = utf8 "Tjen 150,000 og forög hospitalets samlede værdi til 140,000.",
  },
  level12 = {
    [1] = utf8 "Du möder nu udfordringen over dem alle. ",
    [2] = utf8 "Ministeriet er imponeret over dine succeser og har derfor et top-job til dig: De vil have dig til at bygge det ultimative hospital, hvor du skal tjene en pokkers masse penge og have et skyhöjt omdömme. ",
    [3] = utf8 "Det forventes, at du köber alle bygninger, helbreder alle sygdomme (og vi mener alle!) og opnår banens mål og priser. ",
    [4] = utf8 "Klar til udfordringen?",
    [5] = utf8 "Tjen 650,000, helbred 750 personer, og få et omdömme på 800 for at gennemföre banen.",
  },
  level3 = {
    [1] = utf8 "Du vil denne gang skulle bygge dit hospital i et velhavende kvarter. ",
    [2] = utf8 "Sundhedsmyndighederne holder öje med dig for at sikre, at du skaber et overskud her. ",
    [3] = utf8 "Du begynder med et godt omdömme, men så snart hospitalet er åbent, skal du fokusere på at få tjent så mange penge som muligt. ",
    [4] = utf8 "Der er også stor sandsynlighed for akuttilfælde. ",
    [5] = utf8 "Disse indeholder et stort antal patienter, som ankommer samtidig og som alle har den samme sygdom. ",
    [6] = utf8 "Hvis du helbreder dem indenfor tidsgrænsen, forbedrer det dit omdömme og modtager en stor bonus. Når du ikke at helbrede dem inden tiden löber ud, dör patienterne og dit omdömme falder. ",
    [7] = utf8 "Sygdomme som kongekomplekset kan forekomme, og du bör bygge en operationsstue samt et sengeafsnit i nærheden af operationsstuen. ",
    [8] = utf8 "Tjen 20,000 for at gennemföre banen.",
  },
  level10 = {
    [1] = utf8 "Såvel som at kunne behandle alle former for sygdomme, vil Sundhedsmyndighederne gerne have, at du bruger noget tid på at forske i effektiviteten af din medicin. ",
    [2] = utf8 "Der har været nogle klager fra Foreningen af Syge, de syges vagthund. Så for at holde dit omdömme höjt skal du sörge for, at din medicin er effektiv. ",
    [3] = utf8 "Du skal også sikre dig, at dit hospital er over gennemsnittet. Hold dödstallet så lavt som muligt",
    [4] = utf8 "Et lille tip er at du holder lidt plads fri til et gelérör. ",
    [5] = utf8 "Udvikl al din medicin til mindst 80% i effektivitet og få et omdömme på 650 og en bankbeholdning på 500,000 for at gennemföre banen. ",
  },
  level11 = {
    [1] = utf8 "Du har nu fået chancen for at bygge det ultimative hospital. ",
    [2] = utf8 "Dette er et ekstremt velhavende område, hvor Sundhedsmyndighederne gerne vil sig, at der opföres det bedst mulige hospital. ",
    [3] = utf8 "Vi forventer, at du tjener kassen, har et skyhöjt omdömme og håndterer alle uventede situationer. ",
    [4] = utf8 "Dette er en vigtig opgave.",
    [5] = utf8 "Du skal være lavet af noget specielt for at dette skal lykkedes. ",
    [6] = utf8 "Bemærk, at en UFO er set i området. Så forbered dit personale på uventet besög. ",
    [7] = utf8 "Dit hospital skal være mindst 240,000 værd, og du skal have mindst 500,000 i banken samt et omdömme på 700 för syndhedsmyndighederne er tilfredse.",
  },
  level18 = {
  },     
      }    

-- Miscellangelous
-- Category of strings that fit nowhere else or we are not sure where they belong.
-- If you think a string of these fits somewhere else, please move it there.
-- Don't forget to change all references in the code and other language files.
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
  force        = "Styrke",
}
 
----- Old but strings that failed with previous setup
progress_report.quite_unhappy = "Folk er ret triste. "
progress_report.header = "Progessionsrapport"
progress_report.very_unhappy = "Folk er meget triste. "
progress_report.more_drinks_machines = "Opsæt flere sodavandsautomater. "
progress_report.too_cold = "Det er alt for koldt. Placer flere radiatorer eller skru op for varmen. "
progress_report.too_hot = "Juster varmen. Det er alt for varmt. "
progress_report.percentage_pop = "% population"
progress_report.win_criteria = "Kriterier for at vinde"

debug_patient_window.caption = "Fejlfindingspatient"
tooltip.casebook.cure_requirement.hire_staff_old = "Du skal ansætte en %s  for at kunne håndtere denne sygdom"
tooltip.casebook.cure_type.unknown = "Du kan endnu ikke behandle denne sygdom"
tooltip.bank_manager.interest_rate = "Årlig rente"
tooltip.calls_dispatcher.assigned = "Denne box er afkrydset hvis nogen har fået den pågældende opgave tildelt."
tooltip.calls_dispatcher.task = "Liste over opgaver - Klik på en opgave for at se vinduet over tildelt personale og scroll til opgaven"
tooltip.calls_dispatcher.close = "Luk kald på afsender vinduet"

adviser.level_progress.halfway_lost = "Du er omkring halvejs mod at tabe denne bane."
adviser.level_progress.dont_kill_more_patients = "Du har ikke råd til at lade flere patienter dö!"
adviser.level_progress.another_patient_killed = "Åh nej! Du har dræbt endnu en patient. Det giver samlet %d dödsfald."
adviser.level_progress.halfway_won = "Du er halvejs mod at vinde denne bane."
adviser.level_progress.close_to_win_increase_value = "Du er tæt på at vinde banen. Forög hospitalets værdi med %d."
adviser.level_progress.financial_criteria_met = "Du har opnået de finatielle kriterier for denne bane. Nu skal du holde din balance over %d, imens du skal sikre dig at dit hospital körer som smurt"
adviser.level_progress.nearly_won = "Du er meget tæt på at gennemföre banen."
adviser.level_progress.hospital_value_enough = "Hold hospitalets værdi over %d og arbejd med de andre problemer for at vinde banen."
adviser.level_progress.another_patient_cured = "Meget flot - endnu en patient helbredt. Det er samlet %d patienter."
adviser.level_progress.three_quarters_lost = "Du er tre fjerdedele fra at tabe runden."
adviser.level_progress.reputation_good_enough = "Okay, dit ry er godt nok for at kunne gennemföre runden. Hold det over %d og arbejd med de andre problemer for at vinde runden."
adviser.level_progress.cured_enough_patients = "Du har kureret nok patienter, men du skal foröge dit hospitals værdi for at vinde runden."
adviser.level_progress.nearly_lost = "Du er meget tæt på at vinde runden."
adviser.level_progress.improve_reputation = "Du skal forbedre dit ry med %d for at have en chance for at vinde runden."
adviser.level_progress.three_quarters_won = "Du er tre fjerdedele væk fra at vinde runden."

adviser.praise.many_benches = "Der er rigelig med siddeplads. Flot arbejde!"
adviser.praise.many_plants = "Smukt. Du har masser af planter. Dine patienter sætter pris på det."
adviser.praise.plants_are_well = "Hvor dejligt! Du tager dig rigtig godt af dine planter. Smukt."
adviser.praise.few_have_to_stand = "Der er næsten ingen der skal stå op på dit hospital mens de venter. Det sætter dine patienter pris på det."
adviser.praise.plenty_of_benches = "Der er fornuftigt med siddepladser, så det er ikke et problem."
adviser.praise.plants_thriving = "Meget godt. Dine planter trives. De ser fantastiske ud. Bliv ved med det, så kan du måske vinde et trofæ for dem."
adviser.praise.patients_cured = "%d patienter helbredt."

adviser.surgery_requirements.need_surgeons_ward_op = "Du skal ansætte to kirurger og bygge et sengeafsnit og en operationsstue för du kan udföre operationer."
adviser.surgery_requirements.need_surgeon_ward = "Du mangler stadigt at ansætte en kirurg og bygge et sengeafsnit för du kan udföre operationer."
adviser.vomit_wave.started = "Der ser ud til du har en mavevirus på dit hospital. Hvis hospitalet var renere var det ikke sket. Måske skulle du ansætte flere pedeller."
adviser.vomit_wave.ended = "Puha! Der ser ud til mavevirussen er döet ud. Hold dit hospital rent for fremtiden."

adviser.room_requirements.research_room_need_researcher = "Kun læger med speciale i forskning kan arbejde i forskningsrummet."
adviser.room_requirements.op_need_another_surgeon = "Du mangler stadigt at ansætte en kirurg mere för operationsstuen er brugbar."
adviser.room_requirements.op_need_ward = "Du skal bygge et sengeafsnit så patienterne kan hvile sig för de skal opereres."
adviser.room_requirements.reception_need_receptionist = "Du skal ansætte en receptionist til at tage imod dine patienter."
adviser.room_requirements.psychiatry_need_psychiatrist = "Du skal ansætte en psykiater, nu da du har bygget en psykiatri."
adviser.room_requirements.pharmacy_need_nurse = "Du skal ansætte en sygeplejerske til at passe apoteket."
adviser.room_requirements.ward_need_nurse = "Du skal ansætte en sygeplejerske til at arbejde på sengeafsnittet."
adviser.room_requirements.op_need_two_surgeons = "Ansæt to kirurger for at kunne udföre operationer."
adviser.room_requirements.training_room_need_consultant = "Du skal ansætte en konsulent til at undervise i undervisningslokalet."
adviser.room_requirements.gps_office_need_doctor = "Du skal ansætte en læge til at arbejde i lægekonsultationen."
