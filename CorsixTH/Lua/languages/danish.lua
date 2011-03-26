--[[ 
Copyright (c) 2010 Robin Madsen (RobseRob)
Copyright (c) 2010-2011 Ole Frandsen (Froksen)

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
  th_directory = utf8 "CorsixTH kræver en original installation af Theme Hospital for at virke. Angiv placeringen af spillet her.",
  exit = "Afslut",
}

-- 3. Objects
object = {
  litter               = utf8 "Skrald",
}

tooltip.fax.close = utf8 "Luk dette vindue uden at fjerne beskeden"
tooltip.message.button = utf8 "Venstreklik for at læse faxen"
tooltip.message.button_dismiss = utf8 "Venstreklik for at åbne faksen.Höjreklik for at ignorere den"

-- 4. Menu 
menu_options = {
  lock_windows = utf8 "  LÅS VINDUER  ",
  edge_scrolling = "  KANT SCROLLING  ",
  settings = "  INDSTILLINGER  ",
}

menu_options_game_speed.pause   = "  PAUSE  "

-- The demo does not contain this string
menu_file.restart = "  START FORFRA  "

menu_debug = {
  jump_to_level               = utf8 "  Gå til runde  ",
  transparent_walls           = utf8 "  (K) TRANSPERANTE VæGE  ",
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
  lua_console                 = "  (F12) LUA KONSOLE  ",
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
  room_forbidden_non_reachable_parts = "Hvis du placerede rummet her ville det resultere at dele af dit hospital ikke ville være tilgængelige.",

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
dynamic_info.patient.actions.no_gp_available = utf8 "Venter på du bygger lægens kontor"
dynamic_info.staff.actions.heading_for = "På vej til %s"
dynamic_info.staff.actions.fired = "Fyret"

-- 7. Tooltip
tooltip.research_policy.no_research = utf8 "Der forskes ikke på nuværrende tidspunkt i dette område"
tooltip.research_policy.research_progress = utf8 "Fremskidtet mod den næste opdagelse indenfor dette område: %1%/%2%"
tooltip.objects.litter = utf8 "Skrald: Smidt af dine patienter da de ikke kunne finde en skraldespand"
-- Misc
misc.not_yet_implemented = "(ikke implanteret endnu)"
misc.no_heliport = "Enten er der ikke blevet opdaget nogen sygdomme endnu, ellers er der ingen helicopter plads på denne bane."

-- Main menu
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
  width = utf8 "Indtast den önskede skærm brede",
  height = utf8 "Indtast den önskede skærm höjde",
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
  tutorial = "Gennemgang",
  cancel = "Annuller",
}

tooltip.new_game_window = {
  easy = "Hvis du ikke har erfaring inden for simulatorspil er dette niveau det rette",
  medium = utf8 "Hvis du er usikker på hvad du skal vælge er dette niveau en mellem ting",
  hard = utf8 "Hvis du er sikker på dine evner og önsker udfordring, bör du vælge denne.",
  tutorial = utf8 "Hvis du önsker lidt hjælp til at komme igang, skal du mærkere denne kasse.",
  cancel = utf8 "Hmm... Var det ikke meningen at du ville starte et nyt spil?!",
}

lua_console = {
  execute_code = utf8 "Kör",
  close = "Luk",
}

tooltip.lua_console = {
  textbox = utf8 "Skriv Lua-kode du vil köre her",
  execute_code = utf8 "Kör koden",
  close = "Luk konsollen",
}

errors = {
dialog_missing_graphics = "Undskyld, men demo data filerne har ikke en dialog.",
  save_prefix = "Fejl under gem af spil: ",
  load_prefix = utf8 "Fejl under indlæsning af spil: ",
  map_file_missing = "Kunne ikke finde kort filen %s for denne bane!",
  minimum_screen_size = utf8 "Indtast venligst en oplösning på mindst 640x480.",
   maximum_screen_size = utf8 "Indtast venligst en oplösning på maksimalt 3000x2000.",
  unavailable_screen_size = utf8 "Skærmoplösningen du valgte er ikke tilgængelig i fuldskærmsvisning.",
}

confirmation = {
  needs_restart = utf8 "Hvis du vil bruge denne indstilling, så kræver det en genstart af CorsixTH. Runder som ikke er gemt, vil gå tabt. Er du sikker på du vil bruge denne indstilling?",
  abort_edit_room = utf8 "Du er ved at opbygge eller ændre et lokale. Hvis alle obligatoriske objekter er placeret, kan du gemme lokalet. Hvis ikke, skal du slettes rummet. Fortsætte?",
  restart = utf8 "Er du sikker på at du vil pröve på ny?",
}
confirmation.restart_level = "Er du sikker på at du vil pröve på ny?"
  
information = {
  custom_game = "Velkommen til CorsixTH. Hav det sjovt med denne special bane!",
  cannot_restart = utf8 "Beklageligvis så er denne special bane lavet för at genstart funtionen blev implanteret.",
level_lost = {
    utf8 "æv! Du gennemförte ikke runden. Bedre held næste gang!",
    "Derfor tabte du:",
    reputation = utf8 "Dit omdömme var under %d.",
    balance = utf8 "Din bankbalance var under %d.",
    percentage_killed = utf8 "Du har dræbt mere end %d procent af patienterne.",
  },
  }
tooltip.information = {
  close = "Luk informationsdialogen",
}

totd_window = {
  tips = {
    utf8 "På et hvert hospital er det nödvendigt have et receptionsbord og et lægens kontor for at komme i gang. Herefter er det alt efter hvilke patienter der kommer til dit hospital, dog det altid godt at have et apotek.",
    utf8 "Maskiner, som f.eks. et pumperum, har brugt for vedligeholdelse- Ansæt en handyman eller to til at vedligeholde dine maskiner, ellers kan du risikere at dine ansatte eller patienter kommer til skade",
   utf8  "Med tiden bliver dine ansatte trætte. Husk at bygge et personalerum så de kan slappe af.",
  utf8   "Placer radiatorer så dine patienter og ansatte kan holde varmen, ellers bliver de sure. Brug oversigtskortet til at finde steder på dit hospital som skal være varmere.",
  utf8   "En læges kvalifikationsniveau betyder meget for kvaliteten og hastighedsen på hans diagnoser. Hvis du placerer en meget kvalificeret læge på lægens kontor behöver du ikke så mange ekstra diagoniselokaler.",
    --Juniors and doctors can improve their skills by learning from a consultant in the training room. If the consultant has a special qualification (surgeon, psychiatrist or researcher), he will also pass on this knowledge to his pupil(s).
   utf8  "Praktikanter og læger kan forbedre deres kvalifikationer ved at blive undervist af en konsulent i et undervisningslokale. Hvis konsulenten har specielle kvalifikationer (kirug, psykiater eller forsker) vil han også give disse kvalifikationer videre til sine elever.",
   -- "Did you try to enter the European emergency number (112) into the fax machine? Make sure your sound is on!",
  utf8   "Har du prövet at indtaste det europæriske alarm nummer (112) på fax maskinen? Husk at have lyd på!",
    --"You can adjust some settings such as the resolution and language in the options window found both in the main menu and ingame.",
   utf8  "Du kan ændre nogle indstillinger, såsom skærm oplösning og sprog i indstillingsvinduet som kan findes både i hovedmenuen og inde i spillet",
    --"You selected a language other than English, but there's English text all over the place? Help us by translating missing texts into your language!",
  utf8   "Du har valgt et andet sprog end engelsk, men der er alligevel engelsk over det hele? Hjælp os med at oversætte teksten til dit sprog",
    --"The CorsixTH team is looking for reinforcements! Are you interested in coding, translating or creating graphics for CorsixTH? Contact us at our Forum, Mailing List or IRC Channel (corsix-th at freenode).",
  utf8   "Holdet bag CorsixTH er altid på udkig efter forskærkninger! Er du interesseret i kodning, at oversættelse eller at lave grafik til CorsixTH? Kontakt os på vores forum, mailing liste eller IRC kanalen (corsix-th på freenode).",
    --"If you find a bug, please report it at our bugtracker: th-issues.corsix.org",
   utf8  "Hvis du finder en fejl, så kan du rapportere den til os på vores bugtracker: th-issues.corsix.org",
    --"Each level has certain requirements to fulfill before you can move on to the next one. Check the status window to see your progression towards the level goals.",
   utf8  "I hver runde er der forskellige krav der skal være opfyldt för du kan gå videre til den næste. Tjek statusvinduet for at se din progression hen imod rundens mål",
    --"If you want to edit or remove an existing room, you can do so with the edit room button found in the bottom toolbar.",
  utf8   "Hvis du vil ændre eller fjerne eksisterende lokaler, kan du göre det ved at trykke på rediger lokale knappen som findes i væktöjslinjen i bunden.",
   -- "In a horde of waiting patients, you can quickly find out which ones are waiting for a particular room by hovering over that room with your mouse cursor.",
  utf8   "I en gruppe af ventende patienter kan du hurtigt finde ud af hvilke der er i kö til et specifikt lokale ved at bevæge muse kursören over rummet",
    --"Click on the door of a room to see its queue. You can do useful fine tuning here, such as reordering the queue or sending a patient to another room.",
  utf8   "Klik på dören til et rum for at se dens kö. Her kan du lave brugbar tilpasning, som f.eks. sortere i köen eller sende patienter til et andet lokale.",
    --"Unhappy staff will ask for salary rises frequently. Make sure your staff is working in a comfortable environment to keep that from happening.",
  utf8   "Sure medarbejdere vil oftere spörge om lönforhöjelse. Husk at lave et komfortablet arbejdsmiljö for at holde dem glade.",
    --"Patients will get thirsty while waiting in your hospital, even more so if you turn up the heating! Place vending machines in strategic positions for some extra income.",
  utf8   "Patienter bliver törstige når de venter på dit hospital, og endnu mere hvis du skruer op for varmen! Placer drikke automater på strategiske steder for at få en ekstra indtægt",
    --"You can abort the diagnosis progress for a patient prematurely and guess the cure, if you already encountered the disease. Beware that this may increase the risk of a wrong cure, resulting in death for the patient.",
  utf8   "Du kan afbryde en patients sögen efter en diagnose för tid og gætte på en kur, hvis du allerede har mödt denne sygdom tidligere. Men pas på det kan betyde en forhöjet risiko for fejl diagonistiksering, som kan medföre en patients död.",
   -- "Emergencies can be a good source for some extra cash, provided that you have enough capacities to handle the emergency patients in time.",
  utf8 "Akuttilfælde kan være en god måde at få ekstra penge på, sålænge du har kapaciteten til at håndtere patienter fra akuttilfældet inden tiden löber ud.",
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
    money = utf8 "Giver dig 10.000 til din bank balance.",
    all_research = utf8 "Du har forsket alt.",
    emergency = utf8 "Skaber et akkuttilfælde.",
    create_patient = utf8 "Skaber en patient ved kanten af kortet.",
    end_month = utf8 "Går til slutningen af måneden.",
    end_year = utf8 "Går til slutningen af året",
    lose_level = utf8 "Du taber runden.",
    win_level = utf8 "Du vinder runden.",
  },
 }  
  
-- Cheats
  cheats_window = {
  caption = utf8 "Snyd",
  warning = utf8 "Advarsel: Det vil ikke være muligt at få bonus point ved slutningen af runden hvis du snyder!",
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
  nurse                 = "Sygeplejeske",
  doctor                = "Læge",
  handyman              = "Handyman",
  receptionist          = "Receptionist",
  surgeon               = "Kirurg",
}

-- Staff titles
-- these are titles used e.g. in the dynamic info bar
staff_class = {
  nurse                 = "Sygeplejeske",
  doctor                = "Læge",
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
  doctor                = "Læge",
  surgeon               = "Kirug",
  psychiatrist          = "Psykiater",
  consultant            = "Konsulent",
  researcher            = "Forsker",
}

-- Pay rises
pay_rise = {
  definite_quit = "Der er ikke noget du kan göre kunne behold mig. Jeg hader det her sted!",
  regular = {
    utf8 "Jeg er helt udkört. Jeg har brug for hvile og en lönforhöjelse på  %d  ellers skal du nok ikke forvente at se mig her mere.", -- %d (rise)
    utf8 "Jeg er så træt. Jeg har brug for hvile og en lönforhöjelse på %d, altså en lön på %d ialt. Giv mig den nu, din tyran!", -- %d (rise) %d (new total)
    utf8 "Helt ærligt. Jeg knokler en vis legmesdel ud af bukserne! Giv mig en bonus på %d og jeg så bliver jeg på dit hospital.", -- %d (rise)
    utf8 "Jeg er pissesur. Jeg kræver en lönforhöjelse på %d, altså en lön på %d ialt, ellers så er jeg den der er skredet.", -- %d (rise) %d (new total)
    utf8 "Mine forældre fortalte mig at medicinal industrien betalte godt. Så giv mig en lönforhöjelse på %d ellers bliver jeg en videospils producent.", -- %d (rise)
    utf8 "Jeg gidder ikke mere. Giv mig en ordenlig lön. Jeg mener at en lönforhöjelse på %d ville være på plads.", -- %d (rise)
  },
  poached = "Jeg er blevet tilbudt en lön på %d af %s. Så med mindre du betaler mig det samme så er jeg den der er smuttet.", -- %d (new total) %s (competitor)
}

-------------------- Her til er kigget igennem // Froksen
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

-- Place objects window
place_objects_window = {
  drag_blueprint                = utf8 "Træk arbejdstegningen ud indtil du er tilfreds med störrelsen",
  place_door                    = utf8 "Placer dören",
  place_windows                 = "Placer nogle vinduer hvis du har lyst, klik derefter godkend",
  place_objects                 = "Placer objekterne indtil du er tilfreds, klik derefter godkend",
  confirm_or_buy_objects        = utf8 "Du kan godkende dette rum, köbe eller flytte objekterne",
  pick_up_object                = utf8 "Klik på objektet der skal samles op, eller vælg et andet i vælgeren",
  place_objects_in_corridor     = "Placer objekterne nede i en corridor",
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
  cures      = "Kurerede",
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


-- Level names
-- No need to translate these // froksen


-- Town map
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

-- Rooms short
-- NB: includes some special "rooms"
-- reception, destroyed room and "corridor objects"
rooms_short = {
  -- S[14][1] -- unused
  -- S[14][3] -- unused
  reception         = "Reception",
  destroyed         = utf8 "Ödelagt",
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

room_descriptions = {
  ultrascan = {
    [1] = "Ultraskanner//",
    [2] = utf8 "Ultraskanneren er virtuelt i toppklassen indenfor diagnoseudstyr. Den koster meget, men kan betale sig hvis du vil kunne lave meget sikre diagnoser på dit hospital.//",
    [3] = utf8 "Ultraskanneren kan kun håndteres af ".. staff_class.doctor .."ere. Den kræver også vedligeholdelse. ",
  },
  gp = {
    [1] = utf8 "Lægens kontor//",
    [2] = utf8 "Dette er det helt fundementale diagonse redskab på dit sygehus. Nye patienter bliver sendt hertil for at finde ud af hvad de fejler. Herfra kan de blive sendt videre til andre diagnoserum, for at finde den kur som löser deres sygdom. Du skal sandsynligvis bruge flere lægens kontorer, for at undgå lange köer. Nu större rummet er og nu flere objekter du placderer i rummet, des du bedre arbejder lægen. Dette gælder for alle rum.//",
    [3] = utf8 "Lægens kontor kan kun bruges af læger. ",
  },
  fracture_clinic = {
    [1] = "Knoglebrudsklinik//",
    [2] = utf8 "Patienter som uheldigvis har fået knoglebrud kan blive behandlet her.Gipsfjerneren bruger en kraftig industrilaser for at skære gibsen væk, og forsager kun lidt smerte på patienten.//",
    [3] = utf8 "Knogleburdsklinikken kan kun bruges af en sygeplejske. Den kræver vedligeholdelse ",
  },
  tv_room = {
    [1] = "TV RUM IKKE BRUGT",
  },
  inflation = {
    [1] = "Pumperum//",
    [2] = utf8 "Patienter, som har et humoristisk, men dog smertefuldt ballonhoved skal behandles i pumperummet. Her bliver der stukket hul på hovedet så trykket forsvinder. Herefter pumper lægen hovedet op til normalstörrelse.//",
    [3] = utf8 "Pumperummet kan kun benyttes af læger. Regelmæssig vedligeholdelse er også vigtigt. ",
  },
  jelly_vat = {
    [1] = "Geléröret//",
    [2] = "Patienter som er forbannet med denne forfærdelige sygdom. Må slingre den lange vej til Geléröret. I röret bliver de kureret på en påThis cures them in a way still not fully understood by the medical profession.//",
    [3] = "Geleröret kræver en læge. Det har også brug for en handyman til vedligeholdelse.",
  },
  scanner = {
    [1] = "Scanner//",
    [2] = "Patients are accurately diagnosed using the sophisticated Scanner. They then go and see a Doctor in the GP's Office for further treatment.//",
    [3] = "The Scanner requires any Doctor. It also requires maintenance. ",
  },
  blood_machine = {
    [1] = "Blood Machine//",
    [2] = "The Blood Machine is a piece of diagnosis equipment which checks the cells in a patient's blood to find out what is wrong with them.//",
    [3] = "The Blood Machine requires any Doctor. It also requires maintenance. ",
  },
  pharmacy = {
    [1] = "Pharmacy//",
    [2] = "Patients who have been diagnosed and whose treatment is a drug must visit the Pharmacy to take their medicine. As more and more drug cures are researched and become available, this room gets busier. You might want to build another Pharmacy later.//",
    [3] = "The Pharmacy requires a Nurse. ",
  },
  cardiogram = {
    [1] = "Cardio//",
    [2] = "Patients are diagnosed and checked in here, before going back to a GP's Office to be assigned to a cure.//",
    [3] = "The Cardio requires any Doctor. It also requires maintenance. ",
  },
  ward = {
    [1] = "Ward//",
    [2] = "Patients are kept here for observation by a Nurse during diagnosis. They remain here prior to having a operation.//",
    [3] = "The Ward requires one Nurse. ",
  },
  psych = {
    [1] = "Psychiatry//",
    [2] = "Patients diagnosed with psychiatric illnesses must visit the Psychiatry Dept to receive counselling. Psychiatrists can also make diagnoses, finding out what type of illnesses the patients have and, if mental in origin, treating them using the trusty couch.//",
    [3] = "The Psychiatry Dept. requires a Psychiatrically-trained Doctor. ",
  },
  staff_room = {
    [1] = "Staff Room//",
    [2] = "Your staff get tired as they carry out their jobs. They require this room to relax and refresh themselves. Tired staff slow down, demand more money and will eventually quit. They also make more mistakes. Building a staff room with plenty for them to do is very worthwhile. Make sure there is room for several staff members at one time. ",
  },
  operating_theatre = {
    [1] = "Operating Theatre//",
    [2] = "This important installation is where a variety of conditions are treated. The Theatre has to be a good size, and must be filled with the correct equipment. It is a vital part of your hospital.//",
    [3] = "The Operating Theatre requires two Doctors with Surgeon qualifications. ",
  },
  training = {
    [1] = "Training Room//",
    [2] = "Your Juniors and Doctors can gain valuable extra qualifications by studying in this room. A Consultant with Surgery, Research or Psychiatric skills will pass these on to any Doctors being trained. Doctors who already have these skills will find their ability to use them increases whilst here.//",
    [3] = "The Training Room requires a Consultant. ",
  },
  dna_fixer = {
    [1] = "DNA Clinic//",
    [2] = "Patients who have been meddled with by aliens from another world must have their DNA replaced in this room. The DNA Fixer Machine is a very complex piece of equipment and it would be sensible to keep a fire extinguisher in the room with it, just in case.//",
    [3] = "The DNA Fixer Machine will require periodic maintenance by a Handyman. It also requires a Doctor with Research qualifications to work it. ",
  },
  research = {
    [1] = "Research Room//",
    [2] = "New drugs and cures are invented or improved in the Research Room. It's a vital part of your hospital, and will do wonders for your cure percentages.//",
    [3] = "The Research Room requires a Doctor with Research qualifications. ",
  },
  hair_restoration = {
    [1] = "Hair Restoration Clinic//",
    [2] = "Patients suffering from the extreme condition of Baldness will be directed towards the Hair Restorer Machine in this Clinic. A Doctor will operate the machine, and it will rapidly seed the patient's head with fresh hair.//",
    [3] = "The Hair Restoration Clinic requires any Doctor. It also requires periodic maintenance. ",
  },
  general_diag = {
    [1] = "General Diagnosis//",
    [2] = "Patients who require further diagnosis are sent to be checked here. If a GP's Office dösn't find out what is wrong with them, General Diagnosis often will. From here they will be sent back to the GP's office for analysis of the results produced here.//",
    [3] = "The General Diagnosis Room requires any Doctor. ",
  },
  electrolysis = {
    [1] = "Electrolysis Room//",
    [2] = "Patients with Hairyitis are directed to this room, where a special machine called the Electrolyser yanks out the hairs and seals the pores electrically using a compound not unlike grout.//",
    [3] = "The Electrolysis Room requires any Doctor. It also needs maintenance by a Handyman. ",
  },
  slack_tongue = {
    [1] = "Slack Tongue Clinic//",
    [2] = "Patients diagnosed in the GP's Office with Slack Tongue will be sent to this clinic for treatment. The Doctor will use a piece of high-tech machinery to extend the tongue and snip it off, thus returning the patient to normal good health.//",
    [3] = "The Slack Tongue Clinic requires any Doctor. It also needs maintenance every so often. ",
  },
  toilets = {
    [1] = "Toilet//",
    [2] = "Patients feeling a call of nature will need to unburden themselves in the comfort of your toilet facilities. You can build extra stalls and wash-basins if you expect a lot of visitors. In some cases, you might consider building further facilities elsewhere in the hospital. ",
  },
  no_room = {
    [1] = "",
  },
  x_ray = {
    [1] = "X-Ray//",
    [2] = "The X-Ray machine photographs people's insides using special radiation to provide staff with a good idea of what is wrong with them.//",
    [3] = "The X-Ray requires any Doctor. It also requires maintenance. ",
  },
  decontamination = {
    [1] = "Decontamination Clinic//",
    [2] = "Patients who have been exposed to Radiation are quickly shown to the Decontamination Clinic. This room contains a shower which cleanses them off all the horrid radioactivity and muck.//",
    [3] = "The Decontamination Shower requires any Doctor. It also needs maintaining by a Handyman. ",
  },
}

-- Drug companies
drug_companies = {
  "Mediciner-Til-Dig",
  "Kur R Os",
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
  choose_items      = utf8 "Vælg objekt",
  price             = "Pris: ",
  total             = "Total: ",
}


-- Research
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

-- Policy screen
policy = {
  header            = utf8 "Hospitalets politik",
  diag_procedure    = utf8 "Diagnose procedure",
  diag_termination  = utf8 "Diagnose annullering",
  staff_rest        = utf8 "Send personale til personalerum",
  staff_leave_rooms = utf8 "Personale må forlade lokaler",
  
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
  diagnosis  = "Diagnose",
  treatment  = "Behandling",
  clinics    = "Klinikker",
  facilities = "Faciliteter",
}

-- Insurance companies
insurance_companies = {
  out_of_business   = utf8 "GÅET KONKURS",
  utf8 "Nyköbt Lökke",
  utf8 "Böligen Blå",
  utf8 "Årlige Forskud AS",
  "Stygge Arr Co.",
  utf8 "Svömmeblære Co.",
  utf8 "Dörn Ærlig AS",
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
  game_speed          = "  SPIL HASTIGHED  ",
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
  and_then_some_more  = utf8 "  (5) OGSÅ LIGE LIDT MERE  ",
}  

-- Menu Display
menu_display = {
  high_res            = "  MANGE DETAILJER  ",
  mcga_lo_res         = utf8"  RIGTIGT FÅ DETAILJER  ",
  shadows             = "  SKYGGER  ",
}

-- Menu Charts
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

    --mangler
-- Trophy room
trophy_room = {
  many_cured = {
    awards = {
      utf8 "Tillykke med Marie Curie-prisen for at have været i stand til at kurere næsten alle patienter på hospitalet i det forgangende år.",
    },
    trophies = {
      utf8 "Den Internationale Behandlingsfond önsker at ære dig, fordi du har kureret en gruppe mennesker på hospitalet i det forgangende år. De giver dig så kureret-A-Haug trofæet.",
      utf8 "Du har fået tildelt Ingen-Syge-Gurglere trofæ at have kureret en höj procentdel af patienter på hospitalet i det forgangende år.",
    },
  },
  all_cured = {
    awards = {
      utf8 "Tillykke med Marie Curie-prisen for at have været i stand til at kurere alle patienter på hospitalet i det forgangende år.",
    },
    trophies = {
      utf8 "Den Internationale Behandlingsfond önsker at ære dig, fordi du har kureret alle patienter på sygehuset i det forgangende år. De gir deg derfor Kurert-Alle Trofeet.",
      utf8 "Du har fået tildelt Ingen-Syge-Gurglere trofæ at have kureret alle patienter på sygehuset i det forgangende år.",
    },
  },
  high_rep = {
    awards = {
      utf8 "Du er blevet tildelt statsministerens glitrende standard sygehus pris, som tildeles det sygehus med bedst omdömme i det forgangende år. Tillykke!",
      utf8 "Smil og vær glad for at modtage Bullfrog-prisen som tildeles sygehuset med bedst omdömme det forgangende år. Nyd det - det er vel fortjent!",
    },
    trophies = {
      utf8 "Tillykke med Rent-og-Pænt trofæet som tildeles sygehuset med best omdömme i det forgangende år. Det er faktisk fortjent.",
    },
  },
  happy_staff = {
    awards = {
    },
    trophies = {
      utf8 "Du er tildelt Smilefjes Trofeet for å holde ditt hardt-arbeidende personale så blid og fornöyd som mulig.",
      utf8 "Instituttet for Humörspredere gör dig berömt for at du ikke havde nogen galde og negative ansatte på sygehuset i det forgangende år, og giver dig derfor dette trofæ.",
      utf8 "Dette trofæ, er hermed tildelt dig for at have klaret at holde alt personale glad og fornöjet, trods en ihærdig arbejdsindsats i det forgangende år. Dine ansatte stråler!",
    },
  },
  happy_vips = {
    awards = {
      utf8 "Du har vundet Nobelprisen for at imponere VIP'erne. Alle som besögte dit sygehuset i det forgangende år snakker ikke om andet.",
      utf8 "Tillykke med VIP-prisen for at have gjort livene for de hardtarbejdende kendiser bedre, ved at sætte alle som besögte dit sygehuset i det forgangende år i et bedre lys. Fantastisk.",
    },
    trophies = {
      utf8 "Byrådet af Kendte personer vil belönne dig med Kendistrofæet for at have taget godt vare på alle VIP'er som besögte dit hospital i det forgangende år. Du nærmer dig kendis-status, næsten en af os.",
    },
  },
  no_deaths = {
    awards = {
      utf8 "Du har vundet Længe-Leve trofæet for at holde 100 procent af patienterne i live i det forgangende år.",
    },
    trophies = {
      utf8 "Foreningen Livet-Går-Videre belönner dig med dette trofæ for at have nul dödsfald i det forgangende år.",
      utf8 "Du er tildelt Holde-sig-i-live trofæet for at have undgået dödsfald på dit sygehus i det forgangende år. Storartet.",
    },
  },
  rats_killed = {
    awards = {
    },
    trophies = {
      utf8 "Du er tildelt Nul-Uhyrer trofæet for at have skudt %d rotter på dit sygehuset i det forgangende år.", -- %d (number of rats)
      utf8 "Du modtager dette trofæ af foreningen Mod Rotter og Mus, pga. dine unikke rotteskydende evner. Du dræbte %d dyr i det forgangende år.", -- %d (number of rats)
      utf8 "Du modtager rotteskyder trofæet for dine unikke evner i udryddelsen af %d rotter på sygehuset i det forgangende år.", -- %d (number of rats)
    },
  },
  rats_accuracy = {
    awards = {
    },
    trophies = {
      utf8 "Du er tildelt Nöjagtige-Skud-I-Håblös-Krig Trofæet for at have en træfprocent på %d%% i jagten på ækle rotter.", -- %d (accuracy percentage)
      utf8 "Dette trofæ er for at ære din nöjagtighed ved dræbe %d%% af rottene i det forgangende år.", -- %d (accuracy percentage)
      utf8 "For at hædre din præstation der er at dræbe %d%% af rottene på dit sygehuset, bliver du tildelt Dungeon Keepers Skadedyrfrie-Trofe, Tillykke!", -- %d (accuracy percentage)
    },
  },
  healthy_plants = {
    awards = {
      utf8 "Tillykke med Bliv-ved-med-at-gro prisen for at have holdt dine planter ekstremt friske i det forgangende år.",
    },
    trophies = {
      utf8 "Venner-af-Potteplanter önsker at give dig Grön Helse Trofæet, for at have taget godt vare på plantene de siste tolv måneder.",
      utf8 "Foreningen For Grönne Gamlinger önsker at give dig Grönnefinger Trofæet for at have holdt plantene friske i det forgangende år.",
    },
  },
  sold_drinks = {
    awards = {
    },
    trophies = {
      utf8 "Foreningen for Globale Tandlæger er stolt over at kunne give dig dette trofæ for at have solgt store mængder sodavand på dit syhehuset i det forgangende år.",
      utf8 "Sygehuset blevet tildelt Sprudlende-Begær Trofæet for antallet af sodavand som er blevet solgt på sygehuset i det forgangende år.",
      utf8 "På vegne af DK Fyllinger Co., tildeles du hermed dette trofæ dækket af Chokolade, for at have solgt enorme mængder sodavand på sygehuset i det forgangende år.",
    },
  },
}


-- Casebook screen
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
    
-- Tooltips
tooltip = {
  
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
  
  -- Buy objects window
  buy_objects_window = {
    price              = utf8 "Pris på gjenstand",
    total_value        = utf8 "Total verdi på kjöpte gjenstander",
    confirm            = utf8 "Kjöp gjenstand(er)",
    cancel             = "Avbryt",
    increase           = utf8 "Kjöp en til av denne gjenstanden",
    decrease           = utf8 "Kjöp en mindre av denne gjenstanden",
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
  
  -- Queue window
    queue_window = {
    num_in_queue       = utf8 "Antal patienter i köen",
    num_expected       = utf8 "Antal patienter som receptionen forventer der kommer i köen indenfor kort tiden",
    num_entered        = utf8 "Antal patienter som er blevet behandlet i dette rum indtil videre",
    max_queue_size     = utf8 "Den maksimale længde köen kan have",
    dec_queue_size     = utf8 "Mindre makslængde",
    inc_queue_size     = utf8 "Större makslængde",
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
  
  -- Main menu
  main_menu = {
    new_game           = "Start et nyt spil fra begyndelsen",
    load_game          = "Lav dit eget sygehus i speciale baner",
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
    confirm            = utf8 "Bekræft",
  },
  -- Patient window
  patient_window = {
    close              = "Luk vinduet",
    graph              = utf8 "Klik fir at skifte mellem graf med personens kurering og personens behandlingshistorik",
    happiness          = utf8 "Personens humör",
    thirst             = utf8 "Personens törst",
    warmth             = "Personens temperatur",
    casebook           = "Vis detaljer om patientens sygdom",
    send_home          = "Send patienten hjem fra sygehuset",
    center_view        = utf8 "Centerer personen i skærmbilledet",
    abort_diagnosis    = utf8 "Send personen til behandling istedet for at vente til diagnosen er færdig tildelt",
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
    doctor_seniority   = "Lægens evner (Praktikant, Doktor, Konsulent)",
    skills             = "specialisering",
    surgeon            = "Kirurg",
    psychiatrist       = "Psykolog",
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
    repair             = utf8 "Kald på handyman til at fixe maskinen",
    replace            = "Erstat maskinen",
  },
  
  
  -- Handyman window
  -- Spparently handymen have their own set of strings (partly) containing "handyman".
  -- We could just get rid of this category and include the three prios into staff_window.
  handyman_window = {
    name               = "Handymandens navn", -- contains "handyman"
    close              = "Luk vinduet",
    face               = "Handymandens ansigt", -- contains "handyman"
    happiness          = utf8 "Humörniveau",
    tiredness          = utf8 "Træthedsniveau",
    ability            = "Kvalifikation",
    prio_litter        = utf8 "Få handymanden til at priotere rengöring höjere", -- contains "handyman"
    prio_plants        = utf8 "Få handymanden til at priotere vanding af planter höjere.", -- contains "handyman"
    prio_machines      = utf8 "Få handymanden til at priotere reperation höjere", -- contains "handyman"
    salary             = utf8 "Månedslön",
    center_view        = "Centere i skærmbilledet", -- contains "handyman"
    sack               = "Fyr personen",
    pick_up            = "Saml op",
  },
  
  -- Place objects window
  place_objects_window = {
    cancel             = "Afbryd",
    buy_sell           = utf8 "Köb/Sælg objekter",
    pick_up            = utf8 "Saml et objekt op",
    confirm            = utf8 "Bekræft",
  },
  
  -- Casebook
  casebook = {
    up                 = "Scroll op",
    down               = "Scroll ned",
    close              = "Luk medicinbogen",
    reputation         = utf8 "Ry om behandlingen eller diagnosen er i nærområdet",
    treatment_charge   = "Pris for behandling",
    earned_money       = "Total tjente penge indtil i dag",
    cured              = "Antal kurerede patienter",
    deaths             = utf8 "Antal patienter dræbt som konsekvens af behandlingen",
    sent_home          = utf8 "Antal patienter som er blevet sendt hjem",
    decrease           = utf8 "Sænk pris",
    increase           = utf8 "Forhöj pris",
    research           = utf8 "Tryk her for at bruge forsikringsbudgettet for specialisering til at udforske denne behandling",
    cure_type = {
      drug             = utf8 "Behandlingen kræver medicin",
      drug_percentage  = utf8 "Behandlingen kræver medicin, og din er %d%% effektiv", -- %d (effectiveness percentage)
      psychiatrist     = utf8 "Behandlingen kræver en psykolog",
      surgery          = utf8 "Sygdommen kræver en operationsstue",
      machine          = utf8 "Sygdommen kræver en maskine",
    },
    
    cure_requirement = {
      possible         = utf8 "Du kan genneföre behandlingen",
      research_machine = utf8 "Du skal forske i maskiner for at kunne behandle denne sygdom",
      build_room       = utf8 "Du skal bygge et rum for at kunne lave en behandling", -- NB: no %s!
      hire_surgeons    = utf8 "Du mangler to kirurger for at kunne gennemföre behandlingen",
      hire_surgeon     = utf8 "Du skal bruge en kirug mere for at kunne gennemföre behandlingen",
      hire_staff = utf8 "Du skal ansætte noget personale for at kunne behandle denne sygdom",
      build_ward       = utf8 "Du skal bygge en sygestue for at kunne gennemföre denne behandling",
      ward_hire_nurse  = utf8 "Du mangler en sygeplejske for at kunne gennemföre behandlingen",
      not_possible     = utf8 "Du kan ikke håndtere denne behandling endnu",
    },
  },
  
  -- Statement
  statement = {
    close              = "Luk kontoutskriften",
  },
  
  -- Research
  research = {
    close              = utf8 "Gå ud af forskingsafdelingen",
    cure_dec           = utf8 "Sænk priotering af forskning på behandlingsudstyr",
    diagnosis_dec      = utf8 "Sænk priotering af forskning på diagnoseudstyr",
    drugs_dec          = utf8 "Sænk priotering af forskning på mediciner",
    improvements_dec   = utf8 "Sænk priotering af forskning på forbedringer",
    specialisation_dec = utf8 "Sænk priotering af forskning på specialiseringer",
    cure_inc           = utf8 "Ög priotering af forskning på behandlingsudstyr",
    diagnosis_inc      = utf8 "Ög priotering af forskning på diagnoseudstyr",
    drugs_inc          = utf8 "Ög priotering af forskning på mediciner",
    improvements_inc   = utf8 "Ög priotering af forskning på forbedringer",
    specialisation_inc = utf8 "Ög priotering af forskning på specialiseringer",
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
    cures              = "Vis/skjul helbrede",
    deaths             = utf8 "Vis/skjul Dödsfald",
    reputation         = utf8 "Vis/skjul Omdömme",
  },

  --- nået hertil 28 dec
  -- Town map
  town_map = {
    people             = "Vis/Skjul mennesker",
    plants             = "Vis/Skjul planter",
    fire_extinguishers = "Vis/Skjul brandslukningsudstyr",
    objects            = "Vis/Skjul objekter",
    radiators          = "Vis/Skjul radiatorer",
    heat_level         = "Temperatur",
    heat_inc           = "Skrue op for temperaturen",
    heat_dec           = "Skrue ned for temperaturen",
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
  hospital_value    = utf8 "Hospitals værdi",
  balance           = "Balance",
  current_loan      = utf8 "Nuværende lån",
    repay_5000         = "Tilbage betal 5000 til banken",
    borrow_5000        = utf8 "Lån 5000 af banken",
    interest_payment   = utf8 "Månedlige renteomkostninger",
    inflation_rate     = utf8 "Årlig inflasjon",
    inflation_rate    = "Inflations rate",
    close              = "Luk banken",
    insurance_owed     = "Penge %s skylder dig", -- %s (name of debitor)
    show_graph         = "Vis forventet tilbagebetalingsplan fra %s", -- %s (name of debitor)
    graph              = "Forventet tilbagebetalingsplan fra %s", -- %s (name of debitor)
    graph_return       = "Vend tilbage til forrige billede",
  },
  
  -- Status
  status = {
    percentage_cured   = utf8 "Du skal helbrede %d af de besögende på dit hospital. Indtil nu har du helbredt %d",
    thirst             = utf8 "Gennemsnitlig törst for dine patienter",
    close              = utf8 "Luk oversigten",
    population_chart   = utf8 "Figuren viser hvor en stor andel af lokalbefolkningen der bruger dit sygehus",
    win_progress_own   = utf8 "Vis progression i forhold til kravene for dette syghus",
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
    staff_leave        = utf8 "Klik her for at få personale som ikke er optaget til at hjælpe kollegaer, som har brug for hjælp",
    staff_stay         = utf8 "Klik her for at få personalet til at blive i det rum du har placeret dem i",
    diag_procedure     = utf8 "Hvis lægens diagonse er mindre sikker end send hjem procenten, vil patitenten blive sendt hjem. Hvis diagnosen er mere sikker end gættet kur procenten vil patienten få den aktuelle behandling",
    diag_termination   = utf8 "Der vil blive ved med at blive sögt efter en diagnose indtil lægerne er helt sikkre på på en kur, eller alle maskiner er afprövet. Du kan dog afbryde diagnostikseringen",
    staff_rest         = utf8 "Hvor træt dit personale skal være för de går til personalerummet",
  },
  
  
  -- Pay rise window
  pay_rise_window = {
    accept             = utf8 "Accepter kravene",
    decline            = "Forkast kravene - Fyr personen istedet",
  },
  
  -- Watch
  watch = {
    hospital_opening   = utf8 "Byggetid: Dette er tiden du har tilbage för hospitalet åbner. Klik på åben knappen for at åbne hospitalet med det samme.",
    emergency          = utf8 "Akkuttilfælde: Tiden som står er den tid du har tilbage til at behandle akkutte patienter.",
    epidemic           = utf8 "Epidemi: Tid til at fjerne epidemien. Når tiden er ude eller patienten forlader sygehuset, kommer der en sundhedsminister på besög. Knappen tænder og slukker for vaccinationstilstanden. Tryk på patienterne for at få en sygeplejeske til at vaccinere dem.",
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
    general_diag       = utf8 "En læge bruger lægens kontor til at stille den förste diagnose på patienten. Billigt og ofte meget effektivt",
    research_room      = utf8 "Læger med specialisering inden for forskning kan forske sig frem til nye mediciner og maskiner i forskningsavdelingen",
    toilets            = utf8 "Lav toiletter for at få patienterne til at stoppe med at snavse på hospitalet",
    decontamination    = utf8 "En læge bruger dekontaminering til at behandle patienter med radioaktiv stråling",
  },
  
  -- Objects
  objects = {
    -- NB: most objects do not have a tooltip because they're not (extra-)buyable
    desk                 = utf8 "Bord: En læge kan bruge bordet til sin computer.",
    cabinet              = "Arkivskab: Indeholder patientjournaler, noter og forsikringsdokumenter.",
    door                 = utf8 "Dör: Patienten åbner og lukker disse meget.",
    bench                = utf8 "Bænk: Giver en plads at sidde på og gör besöget mere behageligt.",
    table1               = S[40][ 6], -- unused
    chair                = utf8 "Stol: Patienten sidder på den og taler om sine problemer.",
    drinks_machine       = utf8 "Sodavandsautomat: Forbindre at patienterne i at komme til at törste og tiltrækker insekter.",
    bed                  = "Seng: Virkelig syge patienter kan ligge i dem.",
    inflator             = "Pumpe: Kurerer patienter med opsvulmet hoved.",
    pool_table           = utf8 "Billardbord: Hjælper dit personale til at slappe af.",
    reception_desk       = "Reception: Her bliver patienterne henvist videre fra.",
    table2               = S[40][13], -- unused & duplicate
    cardio               = S[40][14], -- no description
    scanner              = S[40][15], -- no description
    console              = S[40][16], -- no description
    screen               = S[40][17], -- no description
    litter_bomb          = utf8 "Skraldebombe: saboterer konkurrentens sykehus",
    couch                = S[40][19], -- no description
    sofa                 = utf8 "Sofa: Ansatte vil sidde i sofaen for at slappe af, såfremt der ikke er bedre måder at slappe af på.",
    crash_trolley        = S[40][21], -- no description
    tv                   = utf8 "TV: sörg for at personalet ikke går glip af deres ynligs tvprogram.",
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
    toilet_sink          = utf8 "Vask: Hvis dine patienter er hygine beviste kan de vaske deres hænder her. Hvis der ikke er nok håndvaske bliver de sure.",
    op_sink1             = S[40][34], -- no description
    op_sink2             = S[40][35], -- no description
    surgeon_screen       = S[40][36], -- no description
    lecture_chair        = utf8 ": Hvis dine læger sidder her og tager noter, kan de kun blive klogere. Jo flere stole du har, jo större kan klassen være.",
    projector            = S[40][38], -- no description
    bed2                 = S[40][39], -- unused duplicate
    pharmacy_cabinet     = "Apotekskab: medicinbeholdningen forefindes her",
    computer             = utf8 "Computer: genialt forskningsværktöj",
    atom_analyser        = utf8 "Atomanalyser: placeret i forskningsafdelingen, og gör hele forskningsprocessen hurtigere.",
    blood_machine        = S[40][43], -- no description
    fire_extinguisher    = "Brandslukker: minimerer risikön for fejl i dine maskiner.",
    radiator             = utf8 "Radiator: Holder sygehuset varmt.",
    plant                = utf8 "Plante: Holder patienternes humör oppe og renser luften.",
    electrolyser         = S[40][47], -- no description
    jelly_moulder        = S[40][48], -- no description
    gates_of_hell        = S[40][49], -- no description
    bed3                 = S[40][50], -- unused duplicate
    bin                  = utf8 "Skaldespand: Patienterne smider deres skrald her..",
    toilet               = utf8 "Toilet: Patienterne, æh..., bruger dette.",
    swing_door1          = S[40][53], -- no description
    swing_door2          = S[40][54], -- no description
    shower               = S[40][55], -- no description
    auto_autopsy         = utf8 "Obduktionsautomat: Godt hjælpemiddel til at opdage nye behandlingsmetoder.",
    bookcase             = utf8 "Bogreol: Opslagsværker til læger.",
    video_game           = "Videospil: Lader personale slappe af med et spil Hi-Octane.",
    entrance_left        = S[40][59], -- no description
    entrance_right       = S[40][60], -- no description
    skeleton             = "Skelet: bruges til undervisningen og til Halloween.",
    comfortable_chair    = S[40][62], -- no description
  },
}

-- 32. 
    
adviser = {
  -- Epidemic
  epidemic = {
    hurry_up         = utf8 "Hvis du ikke tager dig af epidemien nu, kan du få store problemer. Skynd dig!",
    serious_warning     = utf8 "Den smidtsomme syddom begynder at blive et seriöst problem. Du må göre noget snart!",
    multiple_epidemies     = utf8 "Det ser ud som du har mere end en epidemi samtidigt. Dette kan blive en enorm katastrofe for dig!.",
  },
  
  -- Staff advice
  staff_advice = {
    need_handyman_machines   = utf8 "Du skal ansætte flere handymænd.",
    need_doctors       = utf8 "Du har brug for flere læger. Pröv at placere lægerne i de rum hvor der er længst kö til.",
    need_handyman_plants   = utf8 "Du skal ansætte en handymand til at vande planterne.",
    need_handyman_litter   = utf8 "Folk er begyndt at svine på dit hospital. Få en handymand til at rydde op efter dine patienter.",
    need_nurses       = utf8 "Du har brug for flere sygeplejesker. Sengeafdelingerne og apotekerne skal drives af sygeplejesker.",
    too_many_doctors     = utf8 "Du har alt for mange læger. Nogle af dem laver ingen ting.",
    too_many_nurses     = utf8 "Jeg tror du alt for mange sygeplejesker.",
  },
  
  -- Earthquake
  earthquake = {
    damage     = utf8 "Jordskælvet har skadet %d maskiner og %d patienter på sygehuset.", -- %d (count machines), &d (count patients)
    alert     = utf8 "Jordskælvsvarsel. Under et jordskælv bliver dine maskiner skadet. De kan blive ödelagt hvis de ikke blive vedligeholdt.",
    ended     = utf8 "Puha!.  Jeg tror det var et stort skælv -  Det målte %d på Richters skala.",
  },
  
  -- Multiplayer
  multiplayer = {
    objective_completed       = utf8 "Du har fullfört utfordringene for dette nivået. Gratulerer!",
    everyone_failed         = utf8 "Ingen klarte de forrige utfordringene. Så alle får spille videre !",
    players_failed           = utf8 "Fölgende spiller(e) klarte ikke den forrige utfordringen : ",
    
    poaching = {
      in_progress           = utf8 "Jeg skal sige fra denne person, at han gerne vil arbejde for dig.",
      not_interested         = utf8 "Ha! De er ikke interessert i at arbejde for dig..",
      already_poached_by_someone   = utf8 "Ikke tale om! Nogle pröver allerede at overtale personen.",
    },
    objective_failed         = utf8 "Det lykkes ikke at fuldföre udfordringerne.",
  },
    
  -- Goals
  goals = {
    win = {
      money     = utf8 "Du skal opnå %d  for at nå de finansielle krav på dette niveau.",
      cure       = utf8 "Du skal kure %d patienter mere og så har du kurreret nok for at gennemföre runden.",
      reputation   = utf8 "Sörg for at have et omdömme på over %d for at du kan genneföre runden.",
      value     = utf8 "Dit sygehus skal have en værdi på over %d för du kan gennemföre runden",
    },
    lose = {
      kill       = utf8 "Dræb %d patienter mere for at tabe runden!",
    },
  },

  -- Information
  information = {
    larger_rooms           = utf8 "Större rum gör at de ansatte föler sig vigtigere, og det forbedre deres arbejde.",
    extra_items           = utf8 "Ekstra genstande i rumme får dine ansatte til at föle sig bedre tilpas og deres præstationer bliver bedre.",
    epidemic             = utf8 "Du har en smittsom epidemi på dit sygehus. Det skal du göre noget ved, NU!",
    promotion_to_doctor       = utf8 "En af dine praktikanter er blevet forfremmet til at blive læge.",
    emergency             = utf8 "Akkuttilfælde på vej, gör plads!",
    patient_abducted         = utf8 "En af dine patienter er blevet bortfört af et rumvæsen.",
    first_cure             = utf8 "Godt arbejde! Du har netop nu kureret din förste patient.",
    promotion_to_consultant     = utf8 "En af dine læger er blevet forfremmet til konsulent.",
    handyman_adjust         = utf8 "Du kan göre en handyman mere effektiv ved at justere på hans prioteringer.",
    promotion_to_specialist     = utf8 "En af dine læger er blevet forfremmt til %s.",
    patient_leaving_too_expensive   = utf8 "En patient forlader dit sygehus. Det er alt for dyrt!.",
    vip_arrived           = utf8 "Pas på! - %s er netop ankommet til dit sygehus. Sörg for at alt går på skinner for at gör ham tilfreds.",
    epidemic_health_inspector     = utf8 "Sunhedsministeren har fået besked om din epidemi. Du skal forbedrede dig på at han kommer på besög meget snart.",
    first_death           = utf8 "Du har netop dræbt din förste patient. Hvordan har du det med det?!",
    pay_rise             = utf8 "En af dine ansatte truer med at sige op. Du skal vælge om du vil gå med til lönkravene eller om du vil fyre vedkommende. Klik på ikonet nede i venstre hjörne for at se hvem det der som truer med at sige op.",
    place_windows           = utf8 "Vinduer gör rumme lysere og forbedre arbejdslysten hos dine ansatte.",
    fax_received           = utf8 "Ikonet som netop er kommet frem nede i venstre hjörne af skærmen, advarer dig om en vigtig information og beslutninger du skal tage stilling til.",
    
    initial_general_advice = {
      rats_have_arrived = utf8 "Rotterne har invaderet dit sygehus. Pröv at skyde dem med markören.",
      autopsy_available = utf8 "Obduktionsautomaten er nu færdigudviklet. Med denne har du få det bedste ud af döende og ikke velkommende patienter.  Advarsel - At benytte denne er meget kontrovatielt.",
      first_patients_thirsty = utf8 "Flere af patienterne er törstige. De ville sætte pris på en sodavandsautomat.",
      research_now_available = utf8 "Du har bygget din förste forskningsafdeling. Du kan se indstillinger til den via forskningsskærmen.",
      psychiatric_symbol = utf8 "Læger med specialisering i psykologi kan genkendes med symbolet: |",
      decrease_heating = utf8 "Folk på dit sygehus sveder. Skru ned for varmen, det kan du göre på oversigskortet.",
      surgeon_symbol = utf8 "Læger kan udföre kirugiske indgreb hvis de har symbolet: {",
      first_emergency = utf8 "Akutte patienter har et blinke blåt lys over hovederne. Behandl dem inden tiden udlöber, ellers dör de!",
      first_epidemic = utf8 "Du har en epidemi på dit sygehus. Tag stilling til om du vil behandle den selv eller om du vil betale dig fra det.",
      taking_your_staff = utf8 "Nogen pröver at stjæle dit personale. Du må kæmpe for at beholde dem.",
      place_radiators = utf8 "Patienterne fryser - du skal pladsere flere radiatorer ved at gå ind i objekt-oversigten.",
      epidemic_spreading = utf8 "Der er en smittefare på dit sygehus. Kurer de infiferede patienter för de forlader sygehuset.",
      research_symbol = "Forskere er læger med symbolet: }",
      machine_needs_repair = utf8 "Du har udstyr som har brug for at blive reperaret. Find udstyret - det ryger fra det - og klik på det. Klik derefter på handyman symbolet.",
      increase_heating = utf8 "Folk fryser. Skru op for centralvarmen på oversigtskortet.",
      first_VIP = utf8 "Du er ved at få dit förste VIP-besög. Sörg for at VIP'en ikke ser noget uhygiegnisk eller patienter er triste.",
    },
  },
  
  
  -- Build advice
  build_advice = {
    placing_object_blocks_door     = utf8 "Hvis du placere objetet her, kan folk ikke komme til dören.",
    blueprint_would_block       = utf8 "Det blåområde kommer til at blokere andre rum. Pröv at ændre på rumstörrelsen eller flyt til et andet sted!",
    door_not_reachable         = utf8 "Folk kan ikke komme til dören.",
    blueprint_invalid         = utf8 "Det er ikke et gyldigt blueprint.",
  },
}

-- Confirmation
confirmation = {
  quit                 = utf8 "Du har valgt at afslutte, er du virkeligt sikker på du vil forlade spillet?",
  return_to_blueprint  = utf8 "Er du sikker på du vil returnere til arbejdstegningen?",
  replace_machine      = utf8 "Er du sikker på du vil erstatte %s for %d?", -- %s (machine name) %d (price)
  overwrite_save       = utf8 "Der er allerede et spil gemt på denne plads. Er du sikker på du vil overskrive det nuværende gemte spil?",
  delete_room          = "Vil du virkeligt slette dette rum?",
  sack_staff           = utf8 "Er du sikker på du vil fyre dette personale medlem?",
  restart_level        = utf8 "Er du sikker på du vil starte forfra med denne bane?",
}

-- Bank manager
bank_manager = {
  hospital_value    = utf8 "Hospitals værdi",
  balance           = "Balance",
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
    balance         = "Balance",
    current_balance = utf8 "Nuværende balance",
  },
}


-- Letters
letter = {
    --original line-ends:             5          4               2    3
  [1] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Fantastisk! Du har kört sygehuset rigtig godt. Vi i ministeriet vil höre om du er intersseret i et deltage i et större projekt. Vi har et job, som vi tror ville passe dig rigtig godt. Vi kan friste med en lön på $%d. Tænk lidt på det.//",
    [3] = utf8 "Er du interessert i at tage jobbet på sygehuset %s?",
  },
  [2] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Imponerende! Sygehuset har haft en fantastisk udvikling. Vi har et andet sted, som du kan overtage, hvis du klar til at pröve noget nyt. Du SKAL ikke tage udfordringen, men det vil give en belönning. Lönnen er $%d//",
    [3] = utf8 "Er du interessert i at tage jobbet på sygehuset %s?",
  },
  [3] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Din tid på dette sygehus har været ekstremt vellykket. Vi spår dig en stor fremtid, og önsker at tilbyde dig en stilling et andet sted. Lönnen vil være $%d, og vi tror du vil elske de nye udfordringer stillingen förer med sig.//",
    [3] = utf8 "Er du interessert i at tage jobbet på sygehuset %s?",
  },
  [4] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Tillykke! Vi i mínisteriet er meget imponeret over dine evner til drive sygehus. Du er definitivt en gulddreng i sundhedsmyndighederne. Vi tror derimod at du foretrækker en lidt mere udfodrende job. Du får en lön på $%d, men det er din beslutning.//",
    [3] = utf8 "Er du interessert i at tage jobbet på sygehuset %s?",
  },
  [5] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Hej igen. Vi respekterer dine önsker om at ikke forlade dette fantastiske sygehus, men vi beder dig om at tage en ny vurdering. Vi vil tilbyde dig en god lön på $%d hvis du er klar på at flytte til et andet sygehus, og får skabt et respektabelt sygehus.//",
    [3] = utf8 "Er du interessert i at tage jobbet på sygehuset %s?",
  },
  [6] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Ministeriet hilser dig. Vi ved hvor glad du er blevet for det nydelige og velorganiserede sygehus, men vi mener du bör vurdere at fremme din karriere. Du vil få en respektabel lederlönn på $%d hvis du bestemmer dig for at flytte. Det er værd at overveje i hvertfald.//",
    [3] = utf8 "Er du interessert i at tage jobbet på sygehuset %s?",
  },
  [7] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "God dag! Sundhedsministeren tænker på om du vil revurdere din stilling på dit nuværrende sygehus. Vi sætter pris på dit nydelige sygehus, men vi tror du vil göre meget for en lidt mere udfordrende stilling, og en lön på $%d.//",
    [3] = utf8 "Er du interessert i at tage jobbet på sygehuset %s?",
  },
  [8] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Hej igen. Du tog ikke den forrige udfordring, da vi tilböd dig en alle tiders udfordring på et nyt sygehus, og en ok lön på $%d. Vi mener, derimod, at du bör revurdere beslutningen. Vi har den perfekte job til dig, tror vi.//",
    [3] = utf8 "Er du interessert i at tage jobbet på sygehuset %s?",
  },
  [9] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Du har mere end en gang bevist at du er den bedste i sundhedsvæsnet. Ingen tvivl! En så fantastisk præstation skal belönnes, så vi önsker at tilbyde dig stillingen som Administrerende Direktör for Alle Sygehuse. Dette er en ærefuld stilling, og giver dig en lön på hele $%d. Du får din egen Ticker-Tape parade, og folk kommer til at vise sin taknemmelighed, hvor end du går.//",
    [3] = utf8 "Tak for alt du har gjort. Vi önsker dig en lang og fantastisk pensionstid.//",
  },
  [10] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Tillykke! Du har drevet alle de sygehuse vi har givet dig på en udemærket fason. En sådan præstation kvalificerer dig til at få friheden til at rejse rundt verdenen. Du bliver belönnet med en pension på $%d, plus en limousine, og alt vi beder dig om er at du rejser fra by til by, möder dine lidenskabelige fans, og promoterer sygehusets arbejde hvor end du måtte befinne dig.//",
    [3] = utf8 "Vi er stolte af dig. Vi er alle taknemmelige for dit hårde arbejde som livredder.//",
  },
  [11] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Din karriere har været eksemplarisk, og du er en stor inspiration for os alle. Tak for at du har drevet så mange sygehuse, og gjort det så godt i alle jobsne. Vi önsker at give dig en livslang lön på $%d, og alt vi beder dig om er at rejse officelt fra by til by, og fortælle folk hvordan du tjente så mange penge.//",
    [3] = utf8 "Du er et pragteksempel for alle höjre-politiske mennesker, og alle i verden, uden tak, er dine kæreste ejendele.//",
  },
  [12] = {
    [1] = utf8 "Kære %s//",
    [2] = utf8 "Din succeskarriere som den beste sygehusadministrator er den bedste siden Moses sin tid, er ved vejs ende. Men siden du har haft så stor indvirkning på den medicinske verden, önsker ministeriet at tilbyde dig en lön på $%d bare for at være til stede på vore vegne, åbne fester, sösætte skibe og stille op i shows. Hele verden efterlyser dig, og du ville en god vært for PR for os alle!//",
    [3] = utf8 "Vær så venlig at tage i mod denne stilling, det bliver ikke et hårdt arbejde! Og vi skal sorge for at du får politieskorte hvorend du går. .//",
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
  health_minister = "Sundheds ministeren",
  "Bogmesteren fra Farum", -- A guy that liked to drink VERY expensive vine on the whole cities bill.
  "Prins Henrik",
  "Master fatman",
  "Anders Fogh",
  "Din nabo",
  "RobseRob",
  utf8 "A.P. MOLLER Mærsk",
  "En professionel fodbold spiller",
  "Lars larsen", -- Jysk sengetöjslager
  utf8 "Justin bæver",  -- Dont think i like him.. i hate him!
}

-- Deseases
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
    name      = "Skaldethed", 
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
      accept = utf8 "Ja, jeg kan håndtere akkuttilfældet", 
      refuse = utf8 "Nej, jeg nægter at tage mig af dette akkuttilfælde",
    },
    location                = "Der er sket en ulykke ved %s", 
    num_disease              = utf8 "Det er %d mennesker med %s som har brug for behandling.",
    cure_possible_drug_name_efficiency = utf8 "Du har det udstyr og den medicin som er nödvendig for at kunne behandle patienten. Det er %s og medicinen er %d procent effektiv.", 
    cure_possible              = utf8 "Du har det nödvendige udstyr og de færdigheder som skal bruges for at kunne håndtere dette.", 
    cure_not_possible_build_and_employ = utf8 "Du er nödt til at bygge  %s og ansætte en %s",
    cure_not_possible_build            = utf8 "Du mangler %s for at håndtere dette",
    cure_not_possible_employ           = utf8 "Du mangler en %s for at kunne håndtere dette",
    cure_not_possible                  = utf8 "Du kan ikke behandle denne sygdom i öjeblikket",
    bonus                              = utf8 "Hvis du klarer dette akkuttilfælde, vil du modtage en bonus på maksimalt %d. Om du derimod fejler, vil dit ry blive dårligere.",
    
    locations = {      
      utf8 "A.Tom's Våbenskælder",
      "Snoppeuniversitetet",       
      "Buskerud Hagecenter", 
      "Forskningsinstituttet For Farlige Emner", 
      "Foreningen For Folkedansende Mænd", 
      "Puben Frosk Og Kyr", 
      utf8 "Hallgeir Juniors Begravelsesbutik Og Spritbutik",
      "Mamma-Tai Krydderhus", 
      "Berts Varehus For Brugt Petrokemi", 
    },
  },

  emergency_result = {
    close_text     = utf8 "Klik for at gå ud",
    earned_money   = utf8 "Af den maksimale bonus på %d, har du tjent %d.",
    saved_people   = "Du reddet %d mennesker af totalt %d.",
  },  
  
  -- Deseace discovered
  disease_discovered_patient_choice = {
    choices = {
      send_home = "Send patienten hjem.",
      wait      = utf8 "Få pasienten til å vente litt på sykehuset.",
      research  = "Send patienten til forskningsafdelingen.",
    },
    need_to_build_and_employ = utf8 "Hvis du bygger %s og ansætter en %s kan du löse problemet på én gang.",
    need_to_build            = utf8 "Du skal bygge %s for at kunne håndtere dette.",
    need_to_employ           = utf8 "Ansæt en %s for at hjælpe patienten.",
    can_not_cure             = "Du kan ikke behandle denne sygdom.",
    disease_name             = utf8 "Dine ansatte har stödt på et tilfælle af %s.",
    what_to_do_question      = utf8 "Hvad vil du göre med patienten?",
    guessed_percentage_name  = "Teamet mener at de ved hvad patienten fejler. Der er %d procent sandsynlighed for at det er %s",
  },
  
  disease_discovered = {
    close_text          = "Der er blevet opdaget en ny sygdom.",
    can_cure          = "Du kan behandle denne sygdom.",
    need_to_build_and_employ = utf8 "Hvis du bygger %s og ansætter en %s kan du håndtere dette.",
    need_to_build            = utf8 "Du skal bygge %s for at håndtere dette.",
    need_to_employ           = utf8 "Ansæt en %s for at behandle patienter med denne sygdom.",
    discovered_name          = "Dit team har oppdaget et tilfælde af %s.",
  },
  
  -- Epidemic
  epidemic = {
    choices = {
      declare  = utf8 "Offentligör epidemi, betal böden og accepter at dit ry bliver svækket.",
      cover_up = utf8 "Forsög at behandle alle inficerede patienter för tiden löber ud, og för nogen forlader sygehuset.",
    },
    
    disease_name             = utf8 "Dine læger har opdaget en meget smidtsom form for %s.",
    declare_explanation_fine = utf8 "Hvis du offentliggör epidemien, skal du betale en böde på %d, dit ry bliver dårligere, og samtlige patienter blir vaccineret automatisk.",
    cover_up_explanation_1   = utf8 "Hvis du derimod forsöger at holde epidemien skjult, skal du behandle samtlige vaccinerede patienter för sundhedsmyndighederne för det at vide.",
    cover_up_explanation_2   = utf8 "Hvis en sundhedsinspektör kommer på besög og finder ud af at du har forsögt at skjule epidemien, vil han gå drastisk til værk.",
  },
  
  -- Epidemic result
  epidemic_result = {
    close_text = "Hurra!",
    
    failed = {
      part_1_name = utf8 "Gennem forsöget på at skjule det faktum at vi stod overfor et smidtsomtudbrud af %s",
      part_2      = utf8 "Selvfölgelig var dine medarbejdere i stand til at sprede epidemien til alle hospitalets nabör.",
    },
    succeeded = {
      part_1_name = utf8 "Sundhedsinspektören hörte rygter om at dit hospital kæmpede med et alvorligt tilfælde af %s.",
      part_2      = utf8 "Han har dog slet ikke kunne finde noget der kunne bekræfte rygterne.",
    },
    
    compensation_amount  = utf8 "Myndigherne har besluttet at give dig en kompensation på %d for den skade dit ellers gode rygte har lidet.",
    fine_amount          = utf8 "Myndighederne har erklæret en nation undtagelsestilstand og for langer at du betaler en böde på %d.",
    rep_loss_fine_amount = utf8 "Velkommen på forsiden! Dit rygte har fået et ordenligt spark ned af, samtidigt får du en böde på %d.",
    hospital_evacuated   = utf8 "Sundhedsmyndighederne har ikke andet valg end at evakuere dit sygehus.",
  },
  
  -- VIP visit query
  vip_visit_query = {
    choices = {
      invite = "Send en officiel invitation til en V.I.P.",
      refuse = utf8 "Afvis forespörselen fra V.I.P med en dårlig undskyldning.",
    },
    
    vip_name = utf8 "%s har ydret et önske om at besöge dit sygehus",
  },
  
  -- VIP visit result
  vip_visit_result = {
    close_text = utf8 "Tak fordi du besögte sygehuget.",
    telegram          = utf8 "Telegram!",
    vip_remarked_name = utf8 "Efter sit besög på dit syge, sagde %s fölgende:",
    cash_grant = utf8 "Du får %d i kontanter.",
    rep_boost  = utf8 "Dit ry i nærområdet har fået en optur.",
    rep_loss   = utf8 "Dit ry er gået ned.",
    
    remarks = {
      super = {
        "Det er et meget flot sygehus. Næste gang jeg er alvorlig syg vil jeg her til.",
        "Det er hvad jeg kalder for et sygehus.",
        utf8 "Et super sygehus, og det er noget jeg ved noget om, for jeg har været på en del.",
      },
      good = {
        utf8 "For et godt organiseret sygehus. Tak fordi jeg måtte komme.",
        utf8 "Hmm. Det er absolut ikke noget dårligt sted jeg har set.",
        utf8 "Jeg kan godt lide dit charmerende sygehus. Foresten, nogen der vil med ud og spise indisk?",
      },
      mediocre = {
        utf8 "Nå, jeg har set værre. Men du kunne göre en lang række forbedringer.",
        utf8 "Åh, min kære tid. Det her er ikke det sted man går hen hvis man fölger sig dårlig.",
        utf8 "Et helt normalt sygehus, for at være ærlig. Jeg havde forventet noget mere.",
      },
      bad = {
        utf8 "Hvad laver jeg egentligt her?! Det er jo værre end en fire timers opera!",
        "Det var ækelt! Kalder du det her et sygehus?! Det ligner mere end svinesti!",
        utf8 "Jeg er træt af at være en offentlig person og træt af at skulle besöge steder som dette stinkende hul! Jeg siger op!.",
      },
      very_bad = {
        utf8 "Föj for et syn! Dette sygehus skal jeg nok få lukket ned!",
        utf8 "Jeg har aldrig set magen. Det er en direkte skandale!",
        utf8 "Jeg er chokeret!. Du kan ikke kalde dette et syghus.! Jeg går ud og tager mig en stærk drink!",
      },
    },
  },
  
  -- Diagnosis failed
  diagnosis_failed = {
    choices = {
      send_home   = "Send patienten hjem",
      take_chance = utf8 "Pröv en sandsynlig behandling.",
      wait        = utf8 "Få patienten til at vente mens du bygger flere diagnoserum.",
    },
    situation = utf8 "Vi har prövet alle vores diagnoserum på denne patient, men vi er ikke helt sikre på hvad patienten fejler.",
    what_to_do_question = utf8 "Hvad skal vi göre med patienten?",
    partial_diagnosis_percentage_name = "Der er %d procent sikkert at patienten har en type af %s.",
  },
}

-- Queue window
queue_window = {
  num_in_queue       = utf8 "Kölængde",
  num_expected       = "Ventet",
  num_entered        = utf8 "Antal besög",
  max_queue_size     = "Maks str.",
}

-- Dynamic info
dynamic_info = {
  patient = {
    actions = {
      dying                       = utf8 "Döende",
      awaiting_decision           = utf8 "Venter på din beslutning",
      queueing_for                = utf8 "I köen til %s", -- %s
      on_my_way_to                = utf8 "På vej til %s", -- %s
      cured                       = "Kurert!",
      fed_up                      = "Irriteret, forlader sykehuset",
      sent_home                   = "Sendt hjem",
      sent_to_other_hospital      = "Henvist til et andet sygehus",
      no_diagnoses_available      = "Ingen flere diagnosemuligheder",
      no_treatment_available      = utf8 "Ingen behandling er mulig - Jeg går hjem",
      waiting_for_diagnosis_rooms = utf8 "Venter på at du skal bygge flere diagnoserom til mig",
      waiting_for_treatment_rooms = utf8 "Venter på at du skal bygge behandlingsrum til mig",
      prices_too_high             = utf8 "Prisene er for höje - Jeg går hjem",
      epidemic_sent_home          = utf8 "Sendt hjem af inspektör",
      epidemic_contagious         = utf8 "Jeg er smittebærende",
    },
    diagnosed                   = "Diagnose: %s", -- %s
    guessed_diagnosis           = utf8 "Gættet diagnose: %s", -- %s
    diagnosis_progress          = "Diagnoseproces",
    emergency                   = "Akutt: %s", -- %s (disease name)
  },
  vip                           = utf8 "Besögende VIP",
  health_inspector              = utf8 "Sundhedsinspektör",
  
  staff = {
    psychiatrist_abbrev         = "Psyk.",
    actions = {
      waiting_for_patient         = utf8 "Venter på patient",
      wandering                   = "Vandrer rundt omkring",
      going_to_repair             = "Skal reparere %s", -- %s (name of machine)
    },
    tiredness                   = utf8 "Træthed",
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
    [6] = utf8 "Stræb efter at få et omdömme på 300 og en banksaldo på 10,000, samt helbrede mindst 40 patienter. ",
  },
  --todo
  level7 = {
    [1] = utf8 "Her vil du være under overvågning af sundhedsmyndighederne så husk at få det til at se ud som om du tjener en masse penge og at dit omdömme er sky höjt. ",
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
    [2] = utf8 "Sundhedsmyndighederne holder öje med dig for at sikre at du skaber et overskud her. ",
    [3] = utf8 "Du vil starte med at have et godt omdömme, men så snart at hospitalet er åbent, skal du fokusere på at få tjent så mange penge som muligt. ",
    [4] = utf8 "Der er også en sandsynlighed for at der sker akuttilfælde. ",
    [5] = utf8 "Disse indeholder et stort antal patienter, som kommer samtidigt og har alle den samme sygdom. ",
    [6] = utf8 "Helbrede dem indenfor tidsbegrænsningen giver dig et godt omdömme, samt en stor bonus. ",
    [7] = utf8 "Sygdomme som konge komplekset kan forekomme og du burde bygge en operationsstue samt en sygestue i nærheden af. ",
    [8] = utf8 "Tjen $20,000 for at gennemföre.",
  },
  level10 = {
    [1] = utf8 "Så vel som at kunne behandle alle former for sygdomme vil Sundhedsmyndighederne gerne have at du bruger noget tid på at foske i mediciners effekt. ",
    [2] = utf8 "Der har været nogle klager fra foreningen af syge, de syges vagthund. Så for holde sit omdömme skal du sörge for at dine medica er effektive. ",
    [3] = utf8 "Du skal også sikre dig at dit hospital er over gennemsnittet. Holder dödstallet så lavt som muligt",
    [4] = utf8 "Et lille tip er at du holder lidt frit plads til et geléör. ",
    [5] = utf8 "Udvikl alle dine medica til min. 80 effektivitet og få et omdömme på 650 og en bankbeholdning på $500,000 for at gennemföre. ",
  },
  level11 = {
    [1] = utf8 "Du har nu fået chancen for at bygge det ultimative hospital. ",
    [2] = utf8 "Dette er et ekstremt velhavende område, hvor Sundhedsmyndighederne gerne vil sig at der kommer det bedste hospital muligt. ",
    [3] = utf8 "Vi forventer at du tjener kassen, har et sky höjt omdömme og håndtere alle uventede situationer. ",
    [4] = utf8 "Dette er en vigtig opgave",
    [5] = utf8 "Du skal være lavet af noget specielt for at dette skal lykkes. ",
    [6] = utf8 "Bemærk, at der har været set UFO'er i området. Så forbred dit personale på uventet besög. ",
    [7] = utf8 "Dit hospital skal være mindst $240,000, og du skal bruge mindst $500,000 i banken samt dit omdömme skal være på 700.",
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
progress_report.quite_unhappy = "Folk er rimelig triste. "
progress_report.header = "Progessionsrapport"
progress_report.very_unhappy = "Folk er meget triste. "
progress_report.more_drinks_machines = "Byg flere sodavandsautomater. "
progress_report.too_cold = "Det er alt for koldt. Byg flere radiatorer. "
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

adviser.level_progress.halfway_lost = "Du er ca halvejs ved at tabe denne runde."
adviser.level_progress.dont_kill_more_patients = "Du har ikke råd til at lade flere patienter dö!"
adviser.level_progress.another_patient_killed = "Åh nej! Du har dræbt endnu en patient. Det giver samlet %d dödsfald."
adviser.level_progress.halfway_won = "Du er halvejs ved at finde denne runde."
adviser.level_progress.close_to_win_increase_value = "Du er tæt på at vinde runden. Forög dit hospitals værdi med %d."
adviser.level_progress.financial_criteria_met = "Du har opnået de finatielle kriterier for denne runde. Nu skal du holde din balance over %d, imens du skal sikre dig at dit hospital köre smurt"
adviser.level_progress.nearly_won = "Du er meget tæt på at have gennemfört runden."
adviser.level_progress.hospital_value_enough = "Hold hospitalets værdi over %d og arbejds med de andre problemer for at vinde runden."
adviser.level_progress.another_patient_cured = "Meget flot - endnu en patient kureret. Det er samlet %d patienter."
adviser.level_progress.three_quarters_lost = "Du er tre fjerdedele fra at tabe runden."
adviser.level_progress.reputation_good_enough = "Okay, dit ry er godt nok for at kunne gennemföre runden. Hold det over %d og arbejd med de andre problemer for at vinde runden."
adviser.level_progress.cured_enough_patients = "Du har kureret nok patienter, men du skal foröge dit hospitals værdi for at vinde runden."
adviser.level_progress.nearly_lost = "Du er meget tæt på at vinde runden."
adviser.level_progress.improve_reputation = "Du skal forbedre dit ry med %d for at have en chance for at vinde runden."
adviser.level_progress.three_quarters_won = "Du er tre fjerdedele væk fra at vinde runden."

adviser.praise.many_benches = "Der er nok steder patienter kan sidde. Flot arbejde!"
adviser.praise.many_plants = "Smukt. Du har nok af planter. Dine patienter sætter pris på det."
adviser.praise.plants_are_well = "Hvor smukt! Du tager dig rigtigt godt af dine planter. Smukt."
adviser.praise.few_have_to_stand = "Der er næsten ingen der skal stå op på dit hospital. Dine patienter sætter pris på det."
adviser.praise.plenty_of_benches = "Der er fornuftigt mange sidde pladser, så det er ikke det store problem."
adviser.praise.plants_thriving = "Meget godt. Dine planter trives. De ser fantastiske ud. Bliv ved med det, så kan du måske vinde et trofæ for dem."
adviser.praise.patients_cured = "%d patienter kureret."

adviser.surgery_requirements.need_surgeons_ward_op = "Du skal ansætte to kirgurer og bygge en sengeafdeling, samt et operationsbord för du kan udföre operationer."
adviser.surgery_requirements.need_surgeon_ward = "Du mangler stadigt at ansætte en kirug og bygge en sengeafdeling för du kan udföre operationer."
adviser.vomit_wave.started = "Ser ud som om du har en mavevirus på dit hospital, hvis du havde det renere var det ikke sket. Måske skulle du ansætte flere handymænd."
adviser.vomit_wave.ended = "Puha! Ligner at mavevirusen er döet ud. Hold dit hospital rent i fremtiden."

adviser.room_requirements.research_room_need_researcher = "Du skal ansætte en læge med forsker evner for at kunne bruge forskningsrummet."
adviser.room_requirements.op_need_another_surgeon = "Du mangler stadigt at ansætte en kirug mere för operationsstuen er brugbar."
adviser.room_requirements.op_need_ward = "Du skal bygge en sengeafdeling til patienter der skal opereres."
adviser.room_requirements.reception_need_receptionist = "Du skal ansætte en receptionist for at kunne se dine patienter."
adviser.room_requirements.psychiatry_need_psychiatrist = "Du skal ansætte en psykiater, nu da du har bygget et rum til en psykiater."
adviser.room_requirements.pharmacy_need_nurse = "Du skal ansætte en sygeplejeske til at passe apoteket."
adviser.room_requirements.ward_need_nurse = "Du skal ansætte en sygeplejeske til at arbejde på sengeafdelingen."
adviser.room_requirements.op_need_two_surgeons = "Ansæt to kiruger for at kunne lave operationer."
adviser.room_requirements.training_room_need_consultant = "Du skal ansætte en konsulent til at undervise i undervisningslokalet."
adviser.room_requirements.gps_office_need_doctor = "Du skal ansætte en læge til at arbejde på lægenskontor."
