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


-- 2. Faxes
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

-- 3. Objects
object = {
  litter               = utf8 "Skrald",
}

tooltip.fax.close = utf8 "Lukk dette vinduet uten å slette meldingen"
tooltip.message.button = utf8 "Venstreklikk for å lese faksen"
tooltip.message.button_dismiss = utf8 "Venstreklikk for å åpne faksen, höyreklikk for å ignorere den"

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
tooltip.objects.litter = "Skrald: Smidt af dine patienter da de ikke kunne finde en skraldespand"
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

new_game_window = {
  easy = "Praktikant (Let)",
  medium = utf8 "Læge (Mellem)",
  hard = utf8 "Konsulent (Svær)",
  tutorial = "Gennemgang",
  cancel = "Annuller",
}

-- Mangler at blive oversat
tooltip.new_game_window = {
  easy = "Om du ikke har erfaring med simulatorspill er dette tingen for deg",
  medium = utf8 "Om du er usikker på hva du skal velge, så er dette mellomtingen",
  hard = utf8 "Om du er komfortabel med slike spill og önsker utfordring, bör du velge dette.",
  tutorial = utf8 "Om du önsker litt hjelp for å komme i gang må du merke av denne boksen.",
  cancel = utf8 "Hmm... det var ikke meningen å starte et nytt spill!",
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
  unavailable_screen_size = utf8 "Skærmoploesningen du valgte er ikke tilgængelig i fuldskærmsvisning.",
}

confirmation = {
  needs_restart = utf8 "Å forandre denne innstillingen krever en omstart av CorsixTH. Spill som ikke er lagret vil gå tapt. Er du sikker på at du vil endre innstillingen?",
  abort_edit_room = utf8 "Du holder på å bygge eller endre et rom. Om alle obligatoriske gjenstander er plassert ut, ferdigstilles rommet. Om ikke, slettes rommet. Fortsette?",
  restart = utf8 "Er du sikker på at du vil pröve på nytt?",
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
  
    tooltip.cheats_window = {
  close = utf8 "Lukker dialogen",
  cheats = {
    money = utf8 "Giver dig 10.000 til din bank balance.",
    all_research = utf8 "Du har forsket alt.",
    emergency = utf8 "Skaber et akkuttilfælde.",
    create_patient = utf8 "laver en patient ved kanten af kortet.",
    end_month = utf8 "Hopper til slutningen af måneden.",
    end_year = utf8 "Hopper til slutningen af året",
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
  repair = "Reparere %s",
  close = "Luk",
}


-------------------------------------------------------------------------------
--   SECTION B - OLD STRINGS (OVERRIDE)
-------------------------------------------------------------------------------

-- Staff class
-- each of these corresponds to a sprite
staff_class = {
  nurse                 = "Sykepleier",
  doctor                = "Lege",
  handyman              = "Vaktmester",
  receptionist          = "Resepsjonist",
  surgeon               = "Kirurg",
}

-- Staff titles
-- these are titles used e.g. in the dynamic info bar
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

-- Pay rises
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

room_descriptions = {
  ultrascan = {
    [1] = "Ultraskanner//",
    [2] = utf8 "Ultraskanneren er virtuelt i toppklassen innenfor diagnoseutstyr. Den koster mye, men det lönner seg om du vil ha superb diagnosering på ditt sykehus.//",
    [3] = utf8 "Ultraskanneren kan kun håndteres av ".. staff_class.doctor .."r. Den krever også vedlikehold. ",
  },
  gp = {
    [1] = "Allmennpraksis//",
    [2] = utf8 "Dette er det fundamentale diagnoserommet på ditt sykehus. Nye pasienter blir sendt hit for å finne ut hva som feiler de. Videre blir de sendt enten til dypere diagnosering eller til et rom hvor de kan få behandling for sine plager. Du trenger sannsynligvis flere Allmennpraksiser om det oppstår lange köer. Jo större rommet er, og jo mer ekstragjenstander du plasserer i rommet, des bedre presterer legen. Dette gjelder også for alle andre rom.//",
    [3] = "Allmennpraksisen kan kun benyttes av leger. ",
  },
  fracture_clinic = {
    [1] = "Benbruddsklinikk//",
    [2] = utf8 "Pasienter som uheldigvis har Benbrudd vil bli behandlet her. Gipsfjerneren bruker kraftig industrilaser for å kutte vekk gipsen, og forårsaker bare litt smerte for pasienten.//",
    [3] = utf8 "Benbruddsklinikken kan kun benyttes av Sykepleiere. Den krever også vedlikehold. ",
  },
  tv_room = {
    [1] = "TV ROOM NOT USED",
  },
  inflation = {
    [1] = "Pumperom//",
    [2] = utf8 "Pasienter med sitt smertefulle, men dog humoristiske Ballonghode, må behandles på Pumperommet. Her blir hodet stukket hull på, trykket forsvinner, og en lege pumper hodet opp til riktig trykknivå.//",
    [3] = utf8 "Pumperommet kan kun benyttes av Leger. Regelmessig vedlikehold er også viktig. ",
  },
  jelly_vat = {
    [1] = "Jelly Clinic//",
    [2] = "Patients cursed with the risible illness Jellyitis must wobble their way to the Jelly Clinic, and be placed in the Jelly Vat. This cures them in a way still not fully understood by the medical profession.//",
    [3] = "The Jelly Clinic requires any Doctor. It also needs a Handyman for maintenance. ",
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
    [2] = "Patients who require further diagnosis are sent to be checked here. If a GP's Office doesn't find out what is wrong with them, General Diagnosis often will. From here they will be sent back to the GP's office for analysis of the results produced here.//",
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

-- mangler
-- Menu Debug
menu_debug = {
  object_cells        = "  OBJEKTCELLER        ",
  entry_cells         = "  INNGANGSCELLER      ",
  keep_clear_cells    = "  KEEP-CLEAR CELLER   ",
  nav_bits            = "  NAV BITS            ",
  remove_walls        = "  FJERN VEGGER        ",
  remove_objects      = "  FJERN GJENSTANDERER ",
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
    close              = "Lukk vindu",
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
  -- window
  staff_window = {
    name               = "Den ansattes navn",
    close              = "Lukk vindu",
    face               = utf8 "Ansiktet til personen - Klikk for å administrere de ansatte",
    happiness          = utf8 "Humörnivå",
    tiredness          = utf8 "Tretthetsnivå",
    ability            = "Evner",
    doctor_seniority   = "Stilling (Turnuslege, Doktor, Konsulent)",
    skills             = "Spesialisering",
    surgeon            = "Kirurg",
    psychiatrist       = "Psykolog",
    researcher         = "Forsker",
    salary             = utf8 "Månedslönn",
    center_view        = utf8 "Venstreklikk for å finne den ansatte, höyreklikk for å bla gjennom de ansatte.",
    sack               = "Si opp",
    pick_up            = "Plukk opp",
  },
  -- Machine window
  machine_window = {
    name               = "Navn",
    close              = "Lukk vindu",
    times_used         = "Antall gangen maskinen er brukt",
    status             = "Maskinstatus",
    repair             = utf8 "Kall på vaktmester for å fikse maskinen",
    replace            = "Erstatt maskin",
  },
  
  
  -- Handyman window
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
  
  -- Place objects window
  place_objects_window = {
    cancel             = "Avbryt",
    buy_sell           = utf8 "Kjöp/Selg gjenstander",
    pick_up            = "Plukk opp en gjenstand",
    confirm            = "Bekreft",
  },
  
  -- Casebook
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
      surgery          = "Denne sykdommen krever en operasjon",
      machine          = "Denne sykdommen krever en maskin for behandling",
    },
    
    cure_requirement = {
      possible         = utf8 "Du kan gjennomföre behandling",
      research_machine = utf8 "Du må forske på maskiner for å gjennomföre behandlingen",
      build_room       = utf8 "Du må bygge et rom for å gjennomföre behandlingen", -- NB: no %s!
      hire_surgeons    = utf8 "Du trenger to Kirurger for å gjennomföre behandlingen",
      hire_surgeon     = utf8 "Du trenger en Kirurg til for å gjennomföre behandlingen",
      hire_staff = utf8 "Du skal hyre personale for at kunne håndtere denne sygdom",
      build_ward       = utf8 "Du må bygge en Sengeavdeling for å kunne gjennomföre behandlingen",
      ward_hire_nurse  = utf8 "Du trenger en Sykepleier på Sengeavdelingen for å gjennomföre behandlingen",
      not_possible     = utf8 "Du kan ikke håndtere denne behandlingen enda",
    },
  },
  
  -- Statement
  statement = {
    close              = "Lukk kontoutskriften",
  },
  
  -- Research
  research = {
    close              = utf8 "Gå ut av forskningsavdelingen",
    cure_dec           = utf8 "Senk prioritering av forskning på behandlingsutstyr",
    diagnosis_dec      = utf8 "Senk prioritering av forskning på diagnoseutstyr",
    drugs_dec          = utf8 "Senk prioritering av forskning på medisiner",
    improvements_dec   = utf8 "Senk prioritering av forskning på forbedringer",
    specialisation_dec = utf8 "Senk prioritering av forskning på spesialiseringer",
    cure_inc           = utf8 "Ök prioritering av forskning på behandlingsutstyr",
    diagnosis_inc      = utf8 "Ök prioritering av forskning på diagnoseutstyr",
    drugs_inc          = utf8 "Ök prioritering av forskning på medisiner",
    improvements_inc   = utf8 "Ök prioritering av forskning på forbedringer",
    specialisation_inc = utf8 "Ök prioritering av forskning på spesialiseringer",
    allocated_amount   = "Penger satt av til forskning",
  },
  
  -- Graphs
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

  --- nået hertil 28 dec
  -- Town map
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
  
  -- Jukebox.
  jukebox = {
    current_title      = "Jukebox",
    close              = "Lukk jukebox",
    play               = "Spill jukebox",
    rewind             = "Spol tilbake jukebox",
    fast_forward       = "Spol fremover jukebox",
    stop               = "Stopp jukebox",
    loop               = "Repeter jukebox",
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
    percentage_cured   = utf8 "Du må kurere %d besökende på sykehuset ditt. Nå har du kurert %d",
    thirst             = utf8 "Gjennomsnittlig törste på personene på ditt sykehus",
    close              = "Lukk oversikten",
    population_chart   = "Figur som viser hvor stor andel av lokalbefolkningen hvert sykehus tiltrekker seg",
    win_progress_own   = utf8 "Vis progresjon i forhold til kravene for dette nivået",
    reputation        = utf8 "Omdömmet ditt må være minst %d. Nå er det %d",
    population        = utf8 "Du må ha %d%% av befolkningen til å bruke ditt sykehus",
    warmth             = utf8 "Gjennomsnittlig temperatur på personene på ditt sykehus",
    percentage_killed  = utf8 "Kriteriet er blant annet å drepe ferre enn %d%% av dine besökende. Så langt har du tatt livet av %d%%",
    balance        = utf8 "Din bankbalanse må være på minst %d. Nå er den %d",
    value          = utf8 "Sykehuset ditt må være verdt $%d. Så langt er det verdt $%d",
    win_progress_other = utf8 "Vis progresjon i forhold til kravene for dette nivået for %s", -- %s (name of competitor)
    num_cured        = utf8 "Kriteriet er blant annet å kurere &d mennesker. Så langt har du kurert %d",
    happiness          = utf8 "Gjennomsnittlig humör på personene på ditt sykehus",
  },
  
  -- Policy
  policy = {
    close              = "Lukk sykehuspolicy",
    staff_leave        = utf8 "Klikk her for å få personale som ikke er opptatt til å hjelpe kollegaer som trenger det",
    staff_stay         = utf8 "Klikk her for å få personale til å bli i rommene du plasserer dem i",
    diag_procedure     = "Om en leges stilte diagnose er mindre sikker en SEND HJEM prosenten, vil pasienten bli sendt hjem. Om diagnosen er sikrere enn GJETT KUR prosenten, vil pasienten sendes til aktuell behandling",
    diag_termination   = utf8 "En pasients diagnosering vil fortsette helt til Legene er så sikker som AVBRYT PROSESS prosenten, eller til alle diagnosemaskiner er forsökt på pasienten",
    staff_rest         = utf8 "Hvor trött personale må være för de kan hvile",
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
    general_diag       = utf8 "En læge bruger lægens kontor til at stille den föste diagnose på patienten. Billigt og ofte meget effektivt",
    research_room      = utf8 "Læger med specialisering inden for forskning kan forske sig frem til nye mediciner og maskiner i forskningsavdelingen",
    toilets            = utf8 "Lav toiletter for at få patienterne til at stoppe med at snavse på hospitalet",
    decontamination    = utf8 "En læge bruger dekontaminering til at behandle patienter med radioaktiv stråling",
  },
  
  -- Objects
  objects = {
    -- NB: most objects do not have a tooltip because they're not (extra-)buyable
    desk                 = "Pult: en Lege kan bruke pulten til PC'en sin.",
    cabinet              = "Kabinett: inneholder pasientdata, notater og forskningsdokumenter.",
    door                 = utf8 "Dör: personer åpner og lukker disse en del.",
    bench                = utf8 "Benk: gir pasienter en plass å sitte og gjör ventingen mer komfortabel.",
    table1               = S[40][ 6], -- unused
    chair                = "Stol: Pasienter sitter her og diskuterer sine problemer.",
    drinks_machine       = utf8 "Brusautomat: hindrer pasientene å bli törste og genererer inntekter.",
    bed                  = "Seng: virkelig syke pasienter ligger i disse.",
    inflator             = "Pumpe: Kurerer pasienter med Ballonghode.",
    pool_table           = utf8 "Biljardbord: Hjelper personalet ditt med å slappe av.",
    reception_desk       = "Resepsjon: trenger en Resepsjonist som kan henvise pasienter videre.",
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
    auto_autopsy         = utf8 "Obduksjonsautomat: flott hjelpemiddel for å oppdage nye behandlingsmetoder.",
    bookcase             = "Bokhylle: referansemateriell for Leger.",
    video_game           = "Videospill: la personalet ditt slappe av med Hi-Octane.",
    entrance_left        = S[40][59], -- no description
    entrance_right       = S[40][60], -- no description
    skeleton             = "Skjelett: brukt til undervisning og Halloween.",
    comfortable_chair    = S[40][62], -- no description
  },
}

-- 32. 
    
adviser = {
  
  -- Tutorial
  tutorial = {
    build_reception         = utf8 "Heisann. Först, trenger sykehuset ditt en Resepsjon. Velg en fra Inventarmenyen.",
    order_one_reception       = utf8 "Klikk en gang på den blinkende linjen med venstre museknapp for å kjöpe en Resepsjon.",
    accept_purchase         = utf8 "Venstreklikk på den blinkende linjen for å kjöpe den.",
    rotate_and_place_reception     = utf8 "Klikk med höyre museknapp for å rotere Resepsjonen, og venstreklikk for å plassere den i sykehuset.",
    reception_invalid_position     = utf8 "Resepsjonen er nå grå fordi det er en ugyldig plassering. Pröv å flytte eller rotere den.",
    hire_receptionist         = utf8 "Du trenger nå en Resepsjonist til å stå i resepsjonen og henvise dine pasienter.",
    select_receptionists       = utf8 "Venstreklikk på det blinkende ikonet for å se gjennom tilgjengelige resepsjonister. Nummeret på ikonet viser antall som er tilgjengelig.",
    next_receptionist         = utf8 "Dette er den förste resepsjonisten i listen. Venstreklikk på det blinkende ikonet for å se på neste person.",
    prev_receptionist         = utf8 "Venstreklikk på det blinkende ikonet for å se på forrige person.",
    choose_receptionist       = utf8 "Avgjör hvilken resepsjonist som har gode evner og akseptable lönnskrav, og venstreklikk på det blinkende ikonet for å ansette henne.",
    place_receptionist         = utf8 "Flytt resepsjonisten og plasser henne hvor som helst. Hun klarer å finne veien til resepsjonen selv.",
    receptionist_invalid_position   = utf8 "Du kan ikke plassere henne der.",
    window_in_invalid_position     = utf8 "Dette vinduet kan ikke være her. Pröv å plassere det en annen plass på veggen, er du snill.",
    choose_doctor           = utf8 "Se nöye gjennom evnene til hver enkelt Lege för du bestemmer deg for hvem du vil ansette.",
    click_and_drag_to_build       = utf8 "For å bygge en Allmennpraksis, må du först avgjöre hvor stor den skal være. Klikk og hold inne venstre museknapp for å justere rommets störrelse.",
    build_gps_office         = utf8 "For å starte å diagnosere pasientene dine, må du ha en Allmennpraksis.",
    door_in_invalid_position     = utf8 "Oj, sann! Du prövde å plassere dören i en ugyldig posisjon. Pröv en annen plass på veggen av blåkopien.",
    confirm_room           = utf8 "Venstreklikk på det blinkende ikonet for å ferdigstille rommet ditt, eller klikk på X'en for å gå et trinn tilbake.",
    select_diagnosis_rooms       = utf8 "Venstreklikk på det blinkende ikonet for å se en liste over diagnoserom du kan bygge.",
    hire_doctor           = utf8 "Du trenger en Lege for å diagnosere og behandle syke mennesker.",
    select_doctors           = utf8 "Venstreklikk på det blinkende ikonet for å se hvilke Leger som er tilgjengelig i arbeidsmarkedet.",
    place_windows           = utf8 "Plasser vinduer på samme måten som du plasserte dören. Du trenger ikke vinduer, men de ansatte setter veldig pris på det, og blir blidere når de har noe å se ut gjennom.",
    place_doctor           = utf8 "Plasser Legen hvor som helst i Sykehuset. Han vil spasere til Allmennpraksisen så snart noen trenger å diagnoseres.",
    room_in_invalid_position     = utf8 "Oj! Denne blåkopien er ikke gyldig - det röde området indikerer hvor du har overlappet et annet rom eller sykehusets vegger.",
    doctor_in_invalid_position     = utf8 "Hei! Du kan ikke slippe Legen her.",
    place_objects           = utf8 "Höyreklikk for å rotere gjenstander, og venstreklikk for å plassere dem.",
    room_too_small           = utf8 "Denne blåkopien er röd fordi den er for liten. Strekk den ut for å gjöre den större.",
    click_gps_office         = utf8 "Venstreklikk på den blinkende linjen for å velge en Allmennpraksis.",
    
    room_too_small_and_invalid     = utf8 "Blåkopien er for liten og er ugyldig plassert. Kom igjen.",
    object_in_invalid_position     = utf8 "Denne gjenstanden er ugyldig plassert. Vær vennlig å plasser den et annet sted, eller roter den for å få den til å passe.",
    place_door             = utf8 "Flytt musen rundt om kring på blåkopiens vegger for å plassere dören der du vil ha den.",
    room_big_enough         = utf8 "Blåkopien er nå stor nok. Når du slipper museknappen, plasserer du den. Du kan allikevel fortsette å flytte den eller endre störrelse om du vil.",
    build_pharmacy           = utf8 "Gratulerer! Nå må du bygge et Apotek og ansette en sykepleier for å ha et fungerende sykehus.",
  },
  
  -- Epidemic
  epidemic = {
    hurry_up         = utf8 "Om du ikke tar deg av epidemien nå, får du store problemer. Fort deg!",
    serious_warning     = utf8 "Den smittsomme sykdomen begynner å bli et seriöst problem. Du må gjöre noe snart!",
    multiple_epidemies     = utf8 "Det ser ut som at du har mer enn en epidemi gående samtidig. Dette kan bli en enorm katastrofe, så fort deg.",
  },
  
  -- Staff advice
  staff_advice = {
    need_handyman_machines   = utf8 "Du må ansette Vaktmestre om du vil holde maskinene dine ved like.",
    need_doctors       = utf8 "Du trenger flere Leger. Pröv å plassere dine beste leger i rommene med lengst kö.",
    need_handyman_plants   = utf8 "Du må ansette en Vaktmester for å vanne plantene.",
    need_handyman_litter   = utf8 "Folk har begynt å forsöple sykehuset ditt. Ansett en Vaktmester for å rydde opp etter pasientene dine.",
    need_nurses       = utf8 "Du trenger flere Sykepleiere. Sengeavdelinger og Apotek kan bare driftes av Sykepleiere.",
    too_many_doctors     = utf8 "Du har for mange Leger. Noen av dem har ingenting å gjöre.",
    too_many_nurses     = utf8 "Jeg tror du har for mange Sykepleiere.",
  },
  
  -- Earthquake
  earthquake = {
    damage     = utf8 "Det jordskjelvet skadet %d maskiner og %d pasienter på sykehuset.", -- %d (count machines), &d (count patients)
    alert     = utf8 "Jordskjelv-varsel. Under et jordskjelv blir maskinene dine skadet. De kan bli ödelagt om de er dårlig vedlikeholdt.",
    ended     = utf8 "Puh. Jeg trodde det var et stort skjelv - Det målte %d på Richters skala.",
  },
  
  -- Multiplayer
  multiplayer = {
    objective_completed       = utf8 "Du har fullfört utfordringene for dette nivået. Gratulerer!",
    everyone_failed         = utf8 "Ingen klarte de forrige utfordringene. Så alle får spille videre !",
    players_failed           = utf8 "Fölgende spiller(e) klarte ikke den forrige utfordringen : ",
    
    poaching = {
      in_progress           = utf8 "Jeg skal si ifra om denne personen vil komme å jobbe for deg.",
      not_interested         = utf8 "Ha! De er ikke interessert i å jobbe for deg - de har det bra der de er.",
      already_poached_by_someone   = utf8 "Ikke snakk om! Noen pröver allerede å overtale personen.",
    },
    objective_failed         = utf8 "Du har ikke lykkes i å fullföre utfordringene.",
  },
  
  -- Surgery requirements
  surgery_requirements = {
    need_surgeons_ward_op   = utf8 "Du trenger to Kirurger og en Sengeavdeling i tillegg til Operasjonssal for å gjöre kirurgiske inngrep.",
    need_surgeon_ward     = utf8 "Du trenger en til Kirurg og en Sengeavdeling for å gjöre kirurgiske inngrep.",
  },
  
  -- Vomit wave
  vomit_wave = {
    started   = utf8 "Ser ut som du har et magevirus på sykehuset ditt. Om du hadde holdt det renere ville ikke dette skjedd. Kanskje du burde hatt flere Vaktmestre.",
    ended     = utf8 "Puh! Ser ut som viruset som forårsaket bölgen med oppkast er så godt som borte. Hold sykehuset ditt rent i fremtiden.",
  },
  
  -- Level progress
  level_progress = {
    nearly_won       = utf8 "Du har nesten fullfört dette nivået nå.",
    three_quarters_lost = utf8 "Du er nå tre fjerdedeler på vei til å tape dette nivået.",
    halfway_won     = utf8 "Du er nå omtrent halvveis på dette nivået.",
    halfway_lost     = utf8 "Du er omtrent halvveis til å tape dette nivået.",
    nearly_lost     = utf8 "Det er like för du taper dette nivået nå.",
    three_quarters_won   = utf8 "Du er nå tre fjerdedeler på vei til å fullföre dette nivået.",
  },
  progress_report = {
    quite_unhappy = utf8 "Folket ditt er i dårlig humör. ",
    header = "Progresjonsrapport",
    very_unhappy = utf8 "Folket ditt er i svært dårlig humör. ",
    more_drinks_machines = "Bygg flere Brusautomater. ",
    too_cold = utf8 "Det er alt for kaldt. Sett ut noen ovner. ",
    too_hot = utf8 "Du bör regulere sentralvarmen. Det er alt for varmt. ",
    percentage_pop = utf8 "% befolkning",
    win_criteria = utf8 "KRITERIER FOR Å VINNE",
  },

  
  -- Staff place advice
  staff_place_advice = {
    receptionists_only_at_desk     = utf8 "Resepsjonister kan kun jobbe i Resepsjoner.",
    only_psychiatrists         = utf8 "Leger kan bare jobbe i Psykiatri dersom de er kvalifiserte Psykologer.",
    only_surgeons           = utf8 "Leger kan bare jobbe i Operasjonssalen dersom de er kvalifiserte Kirurger.",
    only_nurses_in_room       = utf8 "Det er kun Sykepleiere som kan jobbe på %s",
    only_doctors_in_room       = utf8 "%s kan kun håndteres av Leger",
    only_researchers         = utf8 "Leger kan bare jobbe på Forskningsavdelingen dersom de er kvalifiserte Forskere.",
    nurses_cannot_work_in_room     = utf8 "%s kan ikke håndteres av Sykepleiere",
    doctors_cannot_work_in_room   = utf8 "%s kan ikke håndteres av Leger",
  },
  
  -- Research
  research = {
    machine_improved         = utf8 "%s er forbedret av Forskningsavdelingen.",
    autopsy_discovered_rep_loss   = utf8 "Din Obdiseringsautomat er blitt offentlig kjent. Forvent en negativ reaksjon fra allmennheten.",
    drug_fully_researched       = utf8 "Du har utforsket %s til 100%.",
    new_machine_researched       = utf8 "En ny %s er akkurat utviklet.",
    drug_improved           = utf8 "%s medisinen er forbedret av Forskningsavdelingen din.",
    new_available           = utf8 "En ny %s er tilgjengelig.",
    new_drug_researched       = utf8 "En ny medisin for å kurere %s er utviklet.",
  },
  
  -- Boiler issue
  boiler_issue = {
    minimum_heat   = utf8 "Å, der er du. Sentralovnen i kjelleren er gått i stykker. Ser ut som at personene på sykehuset ditt kommer til å fryse litt.",
    maximum_heat   = utf8 "Sentralovnen i kjelleren er löpt löpsk. Ovnene har hengt seg opp på maksimal varme. Folk kommer til å smelte! Plasser ut flere Brusautomater.",
    resolved     = utf8 "Gode nyheter. Sentralvarmen fungerer slik som de skal nå. Temperaturen skal nå være grei både for pasientene og personalet.",
  },
  
  -- Competitors
  competitors = {
    staff_poached     = utf8 "En av dine ansatte har fått seg jobb på et annet sykehus.",
    hospital_opened   = utf8 "Et konkurrerende sykehus er åpnet i området av %s.",
    land_purchased     = utf8 "%s har akkurat kjöpt en tomt.",
  },
  
  -- Room requirements
  room_requirements = {
    research_room_need_researcher   = utf8 "Du må ansette en Lege med spesialisering innenfor Forskning for å kunne ta i bruk Forskningsavdelingen.",
    op_need_another_surgeon     = utf8 "Du trenger fremdeles en Kirurg til, for å kunne ta i bruk Operasjonssalen.",
    op_need_ward           = utf8 "Du må bygge en Sengeavdeling for å overvåke pasienter som skal opereres.",
    reception_need_receptionist   = utf8 "Du må ansette en Resepsjonist for å ta imot pasientene.",
    psychiatry_need_psychiatrist   = utf8 "Du må ansette en Psykolog, nå som du har bygget Psykiatri.",
    pharmacy_need_nurse       = utf8 "Du må ansette en Sykepleier for å drifte Apoteket.",
    ward_need_nurse         = utf8 "Du må ansette en Sykepleier som kan jobbe på denne Sengeavdelingen.",
    op_need_two_surgeons       = utf8 "Ansett to Kirurger for å utföre kirurgiske inngrep i Operasjonssalen.",
    training_room_need_consultant   = utf8 "Du må ansette en Konsulent som kan undervise i Klasserommet.",
    gps_office_need_doctor       = utf8 "Du må ansette en Lege som kan jobbe på Allmennpraksisen.",
  },
  
  -- Goals
  goals = {
    win = {
      money     = utf8 "Du trenger %d til for å oppnå de finansielle kriteriene på dette nivået.",
      cure       = utf8 "Kurer %d pasienter til og du har kurert nok for å fullföre dette nivået.",
      reputation   = utf8 "Sörg for å ha et omdömme på over %d for at du skal kunne fullföre nivået.",
      value     = utf8 "Sykehuset ditt må ha en verdi på over %d for at du skal kunne fullföre dette nivået",
    },
    lose = {
      kill       = utf8 "Drep %d pasienter til for å tape dette nivået !",
    },
  },
  
  -- Warnings
  warnings = {
    charges_too_low       = utf8 "Du tar deg for lite betalt. Dette vil tiltrekke mange syke mennesker til sykehuset ditt, men du tjener mindre pr. pasient.",
    charges_too_high       = utf8 "Dine priser er for höye. Dette gir deg god profitt på kort sikt, men på lengre sikt vil de höye prisene skremme bort pasientene.",
    plants_thirsty         = utf8 "Du må huske på plantene dine. De er törste.",
    staff_overworked       = utf8 "Personalet ditt er meget overarbeidet. De blir ineffektive og gjör fatale feil når di er trötte.",
    queue_too_long_at_reception = utf8 "Du har for mange pasienter som venter ved Resepsjonen. Plasser ut flere Resepsjoner og ansett en resepsjonist til.",
    queue_too_long_send_doctor   = utf8 "Köen til %s er for lang. Sörg for at det er en Lege i rommet.",
    handymen_tired         = utf8 "Dine Vaktmestere er veldig trött. Gi dem hvile nå.",
    money_low           = utf8 "Du begynner å gå tom for penger!",
    money_very_low_take_loan   = utf8 "Din balanse er ganske så lav. Du kan jo alltids låne penger av banken.",
    staff_unhappy         = utf8 "Personalet ditt er i dårlig humör. Pröv å gi dem bonuser, eller bedre, bygg et Personalrom. Du kan også forandre Hvilepraksisen på Sykehuspolicy-skjermen.",
    no_patients_last_month     = utf8 "Ingen nye pasienter besökte sykehuset ditt forrige måned. Sjokkerende!",
    queues_too_long       = utf8 "Köene dine er for lange.",
    patient_stuck         = utf8 "Noen har gått seg vill. Du må organisere sykehuset ditt bedre.",
    patients_too_hot       = utf8 "Pasientene er for varme. Du må enten fjerne noen ovner, skru ned temperaturen, eller plassere ut flere Brusautomater.",
    doctors_tired         = utf8 "Dine Leger er veldig trötte. Gi dem hvile snarest.",
    need_toilets         = utf8 "Pasientene trenger toaletter. Bygg dem på lett tilgjengelige steder.",
    machines_falling_apart     = utf8 "Maskinene dine faller sammen. Få Vaktmestre til å fikse de snarest!",
    nobody_cured_last_month   = utf8 "Absolutt ingen ble kurert forrige måned.",
    patients_thirsty       = utf8 "Pasientene dine er törste. Du burde gi dem tilgang på brus.",
    nurses_tired         = utf8 "Sykepleierene dine er trötte. Gi dem hvile nå.",
    machine_severely_damaged   = utf8 "%s er veldig nær å bli totalskadet.",
    reception_bottleneck     = utf8 "Det er en flaskehals i Resepsjonen. Ansett en Resepsjonist til.",
    bankruptcy_imminent     = utf8 "Hallo! Du nærmer deg konkurs. Vær forsiktig!",
    receptionists_tired     = utf8 "Resepsjonistene dine er meget trötte. Gi dem hvile nå.",
    too_many_plants       = utf8 "Du har for mange planter. Dette er jo rene jungelen.",
    many_killed         = utf8 "Du har nå drept %d mennesker. Poenget er liksom å gjöre de friske, vet du.",
    need_staffroom         = utf8 "Bygg et Personalrom slik at dine ansatte kan slappe av.",
    staff_too_hot         = utf8 "Dine ansatte holder på å smelte bort. Skru ned temperaturen eller fjern noen ovner fra rommene deres.",
    patients_unhappy       = utf8 "Pasientene misliker sykehuset ditt. Du burde gjöre noe for å forbedre miljöet på sykehuset.",
  },
  
  -- Placement info
  placement_info = {
    door_can_place       = utf8 "Du kan plassere dören her, om du vil.",
    window_can_place     = utf8 "Du kan plassere vinduet her. Det går fint.",
    door_cannot_place     = utf8 "Beklager, men du kan ikke plassere dören her.",
    object_can_place     = utf8 "Du kan plassere gjenstanden her.",
    reception_can_place   = utf8 "Du kan plassere Resepsjonen her.",
    staff_cannot_place     = utf8 "Du kan ikke plassere den ansatte her. Beklager.",
    staff_can_place     = utf8 "Du kan plassere den ansatte her. ",
    object_cannot_place   = utf8 "Hallo, du kan ikke plassere gjenstanden her.",
    room_cannot_place     = utf8 "Du kan ikke plassere rommet her.",
    room_cannot_place_2   = utf8 "Du kan ikke bygge rommet her.",
    window_cannot_place   = utf8 "Ah. Du kan faktisk ikke plassere vinduet her.",
    reception_cannot_place   = utf8 "Du kan ikke plassere Resepsjonen her.",
  },
  
  -- Praise
  praise = {
    many_benches   = utf8 "Pasientene har nok sitteplasser nå. Fint.",
    many_plants   = utf8 "Flott. Du har mange planter. Pasientene vil sette pris på det.",
    patients_cured   = utf8 "%d pasienter kurert.",
  },
  
  -- Information
  information = {
    larger_rooms           = utf8 "Större rom gjör at de ansatte föler seg viktigere, og det forbedrer deres prestasjoner.",
    extra_items           = utf8 "Ekstra gjenstander i rommene får de ansatte til å föle seg mer komfortabel og prestasjonene blir bedre.",
    epidemic             = utf8 "Du har en smittsom epidemi på sykehuset ditt. Det må du gjöre noe med nå!",
    promotion_to_doctor       = utf8 "En av dine TURNUSLEGER er nå blitt DOKTOR.",
    emergency             = utf8 "Nödstilfelle! Unna vei! Flytt dere!",
    patient_abducted         = utf8 "En av dine pasienter er blitt bortfört av romvesen.",
    first_cure             = utf8 "Bra jobbet! Du har akkurat kurert din förste pasient.",
    promotion_to_consultant     = utf8 "En av dine DOKTORER er nå blitt KONSULENT.",
    handyman_adjust         = utf8 "Du kan gjöre Vaktmesterene mer effektiv ved å justere deres prioriteringer.",
    promotion_to_specialist     = utf8 "En av dine Leger er blitt forfremmet til %s.",
    patient_leaving_too_expensive   = utf8 "En pasient forlater sykehuset ditt uten å gjöre opp for seg ved %s. Det er for dyrt.",
    vip_arrived           = utf8 "Pass på! - %s har akkurat ankommet sykehuset ditt! La alt gå på skinner nå, for å tilfredstille han.",
    epidemic_health_inspector     = utf8 "Helseministeren har nå fått med seg nyhetene om epidemien din. Du må forberede deg på et besök av ministeren ganske snart.",
    first_death           = utf8 "Du har akkurat drept din förste pasient. Hvordan föles det?",
    pay_rise             = utf8 "En av dine ansatte truer med å si opp. Velg om du vil gå med på lönnskravene eller om du vil sparke han/henne. Klikk på ikonet nede i venstre hjörne for å se hvem som truer med oppsigelse.",
    place_windows           = utf8 "Vinduer gjör rommene lysere og öker arbeidslysten til dine ansatte.",
    fax_received           = utf8 "Ikonet som akkurat poppet opp nede i venstre hjörne av skjermen, varsler deg om viktig informasjon og beslutninger du må ta.",
    
    initial_general_advice = {
      rats_have_arrived = utf8 "Rotter har infisert sykehuset ditt. Pröv å skyt dem med musen din.",
      autopsy_available = utf8 "Obduksjonsautomaten er nå ferdigutviklet. Med denne kan du kvitte deg med tröblete eller ikke-velkomne pasienter, og gjöre forskning ut av restene. Advarsel - Å benytte denne er svært kontroversielt.",
      first_patients_thirsty = utf8 "Flere av pasientene dine begynner å bli dehydrert. De ville satt pris på en Brusautomat.",
      research_now_available = utf8 "Du har bygd din förste Forskningsavdeling. Du har nå tilgang til Forskningsskjermen.",
      psychiatric_symbol = utf8 "Leger med spesialisering innen Psykologi gjenkjennes med symbolet: |",
      decrease_heating = utf8 "Folk på sykehuset ditt svetter. Skru ned sentralvarment. Dette gjöres på Områdekartet.",
      surgeon_symbol = utf8 "Leger kan utföre kirurgiske inngrep om de har symbolet: {",
      first_emergency = utf8 "Akutte pasienter har et blinkende blått lys over hodet. Behandle dem i tide, ellers dör de.",
      first_epidemic = utf8 "Du har en epidemi på sykehuset ditt! Avgjör om du vil rydde opp, eller legge deg paddeflat.",
      taking_your_staff = utf8 "Noen pröver å stjele personalet ditt. Du må kjempe for å beholde de.",
      place_radiators = utf8 "Pasientene fryser - du kan plassere flere ovner ved å gå inn på oversikten med gjenstander.",
      epidemic_spreading = utf8 "Det er smittefare på sykehuset. Kurer infiserte pasienter för de forlater sykehuset.",
      research_symbol = "Forskere er leger med symbolet: }",
      machine_needs_repair = utf8 "Du har utstyr som trenger reperasjon. Finn utstyret - det ryker av det - og klikk på den. Klikk deretter på Vaktmestersymbolet.",
      increase_heating = utf8 "Folk fryser. Skru opp sentralvarmen på Områdekartet.",
      first_VIP = utf8 "Du er i ferd med å ta imot ditt förste VIP-besök. Sörg for at VIP'er ikke ser noe uhygienisk eller pasienter som henger med hodet.",
    },
  },
  
  
  -- Build advice
  build_advice = {
    placing_object_blocks_door     = utf8 "Om du plasserer gjenstander der, kommer ikke folk seg til dören.",
    blueprint_would_block       = utf8 "Den blåkopien kommer til å blokkere andre rom. Pröv å endre rommets störrelse, eller flytt det en annen plass!",
    door_not_reachable         = utf8 "Folk kommer ikke til å komme seg til den dören. Tenk litt.",
    blueprint_invalid         = utf8 "Det er ikke en gyldig blåkopi.",
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


-- Newspaper headlines
newspaper = {
  -- Seven categories of funny headlines. I think each category is related
  -- to one criterium you can lose to. TODO: categorize
  { "DR SKREKK OG GRU", "SKUMMEL LEGE LEKER GUD", "DR ACULA SJOKKERER", "HVEM FALT FOR KNIVEN?", "FARLIG FORSKNING STOPPET ETTER RAZZIA" },
  { "DR ANKER", "KNUST KIRURG", utf8 "KONSULENT PÅ KJÖRET", "KIRURGISK SHOT", "KIRURG DRIKKER OPP", "KIRURGISK SPIRIT" },
  { "LEKENDE KIRURG", "DOKTOR PANTSDOWN", utf8 "DOKTOR LANGT NEDE", "GLUPSK KIRURG" },
  { "LEGE TUKLER MED BALANSEN", "ORGAN-ISERT KRIMINALITET", "BANKMESSIG BYPASS-OPERASJON", "LEGE MED KONTANTBEHOLDNING" },
  { "MEDISINSK RAID AV KISTER", utf8 "DOKTOR TÖMMER GRAVPLASS", "LIK I GARDEROBEN", utf8 "FIN DAG FOR DR DÖD", "SISTE FEILBEHANDLING", "GRAVENDE DOKTOR OPPDAGET" },
  { "LEGE SPIST OPP!", "SLAKK KVAKK", "LIVSFARLIG DIAGNOSE", "UFORSIKTIG KONSULENT", },
  { utf8 "DOKTOR BLÅSER LETTET UT", "KIRURG 'OPERERER' SEG SELV", utf8 "LEGE MED UTBLÅSNING", "DOKTOR LEGGER KABEL", "MEDISIN ER NOE DRITT" },
}

-- Letters
-- TODO
letter = {
    --original line-ends:             5          4               2    3
  [1] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Fantastisk! Dette sykehuset har du driftet helt utmerket. Vi i departementet vil vite om du er interessert i å gå lös på et större prosjekt. Vi har en jobbstilling vi tror du ville passet perfekt i. Vi kan friste deg med en lönn på $%d. Tenk litt på det.//",
    [3] = utf8 "Er du interessert i å jobbe på sykehuset %s?",
  },
  [2] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Veldig bra! Sykehuset ditt har hatt en fantastisk utvikling. Vi har en annen institusjon vi vil du skal ta over, om du er klar for forandringer. Du MÅ ikke ta utfordringen, men det vil nok lönne seg. Lönnen er $%d//",
    [3] = utf8 "Vil du jobbe på sykehuset %s?",
  },
  [3] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Din tid på dette sykehuset har vært enormt vellykket. Vi spår en stor fremtid for deg, og önsker å tilby deg en stilling et annet sted. Lönnen vil være $%d, og vi tror du vil elske de nye utfordringene stillingen förer med seg.//",
    [3] = utf8 "Vil du ha stillingen på sykehuset %s?",
  },
  [4] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Gratulerer! Vi i departementet er meget imponert over dine evner til å drifte sykehus. Du er definitivt en gullgutt i Helsedepartementet. Vi tror derimot at du foretrekker en litt töffere jobb. Du får en lönn på $%d, men det er din beslutning.//",
    [3] = utf8 "Er du interessert i å jobbe på sykehuset %s?",
  },
  [5] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Hei igjen. Vi respekterer dine önsker om å ikke forlate dette sjarmerende sykehuset, men vi ber deg om å ta en ny vurdering. Vi vil tilby deg en god lönn på $%d om du er klar for å flytte til et annet sykehus, og får opp driften til et respektabelt nivå.//",
    [3] = utf8 "Er du interessert i å flytte til sykehuset %s nå?",
  },
  [6] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Departementet hilser deg. Vi vet hvor glad du er blitt i denne nydelige, velorganiserte institusjonen, men vi tror du bör vurdere å fremme karrieren din nå. Du vil få en respektabel lederlönn på $%d om du bestemmer deg for å flytte. Det er verdt å tenke på det i hvertfall.//",
    [3] = utf8 "Vil du ta imot stillingen på sykehuset %s?",
  },
  [7] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "God dag! Helseministeren lurer på om du vil revurdere din stilling på ditt nåværende sykehus. Vi setter pris på ditt nydelige sykehus, men vi tror du vil gjöre mye for en litt mer utfordrende stilling, og en lönn på $%d.//",
    [3] = utf8 "Tar du utfordringen på sykehuset %s?",
  },
  [8] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Hallo igjen. Du tok ikke vår forrige utfordring, der vi tilbydte deg en alle tiders stilling på et nytt sykehus, og en ökt lönn på $%d. Vi mener, derimot, at du bör revurdere beslutningen din. Vi har den perfekte jobben for deg, skjönner du.//",
    [3] = utf8 "Tar du imot stillingen på sykehuset %s? Vær så snill?",
  },
  [9] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Du har nok en gang bevist at du er den beste innen helseadministrasjon. Ingen tvil! En slik betydningsfull prestasjon må belönnes, så vi önsker å tilby deg stillingen som Administrerende Direktör for Alle Sykehus. Dette er en ærefull stilling, og gir deg en lönn på hele $%d. Du får din egen Ticker-Tape parade, og folk kommer til å vise sin takknemlighet ovenfor deg, hvor enn du går.//",
    [3] = utf8 "Takk for alt du har gjort. Vi önsker deg en lang og trivelig pensjonstid.//",
  },
  [10] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Gratulerer! Du har driftet alle sykehus vi har gitt deg på en utmerket måte. En slik prestasjon kvalifiserer deg for friheten til å reise rundt i verden. Du blir belönnet med en pensjon på $%d, pluss en limousin, og alt vi ber om er at du reiser fra by til by, möter dine lidenskaplige fans, og promoterer sykehusets arbeid hvor enn du måtte befinne deg.//",
    [3] = utf8 "Vi er alle stolte av deg. Det er ikke en av oss som ikke er takknemlig for ditt harde arbeid som livredder.//",
  },
  [11] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Din karriere har vært eksemplarisk, og du er en stor inspirasjon for oss alle. Takk for at du har driftet så mange sykehus, og gjort det så bra i alle jobbene. Vi önsker å gi deg en livslang lönn på $%d, og alt vi ber deg om er å reise offisielt med kabriolet fra by til by, og fortelle folk hvordan du tjente så mye penger så fort.//",
    [3] = utf8 "Du er et prakteksempel for alle höyre-politiske mennesker, og alle i verden, uten unntak, er dine kjæreste eiendeler.//",
  },
  [12] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Din suksessrike karriere som den beste sykehusadministratoren siden Moses sin tid, er ved veis ende. Men siden du har hatt så stor innvirkning på den koselige medisin-verdenen, önsker departementet å tilby deg en lönn på $%d bare for å være til stede på våre vegne, åpne fester, sjösette skip og stille opp på show. Hele verden etterlyser deg, og det ville vært god PR for oss alle!//",
    [3] = utf8 "Vær så snill å ta imot denne stillingen, det blir ikke hardt arbeid! Og vi skal sörge for at du får politieskorte hvor enn du går.//",
  },
}



-- Humanoid start of names
humanoid_name_starts = {
  [1] = utf8 "BJÖRN",
  [2] = utf8 "HÖY",
  [3] = "STOR",
  [4] = "GULL",
  [5] = "RIK",
  [6] = "SOL",
  [7] = "LANGE",
  [8] = "FLAT",
  [9] = "HARD",
  [10] = "MYK",
  [11] = "BAR",
  [12] = "SKODDE",
  [13] = utf8 "MÖRKE",
  [14] = utf8 "BLÅ",
  [15] = "KRIG",
  [16] = "LAT",
  [17] = "KRABBE",
  [18] = "FISK",
  [19] = utf8 "VÅT",
  [20] = "SEN",
  [21] = "GRAV",
  [22] = "BAK",
  [23] = "LAVE",
  [24] = "UT",
  [25] = "ENGE",
  [26] = utf8 "GRÖN",
  [27] = "KUR",
  [28] = "KVIT",
  [29] = "KJEVE",
  [30] = "TRYGLE",
  [31] = "KVERN",
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
  "Lars larsen", -- Jysk sengetøjslager
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
      accept = utf8 "Ja, jeg er klar til å håndtere dette", 
      refuse = utf8 "Nei, jeg nekter å ta meg av dette",
    },
    location                = "Det har skjedd en ulykke ved %s", 
    num_disease              = "Det er %d mennesker med %s som trenger akutt behandling.",
    cure_possible_drug_name_efficiency = utf8 "Du har det som trengs av nödvendig utstyr og ferdigheter, og du har medisinen de trenger. Det er %s og medisinen er %d prosent effektiv.", 
    cure_possible              = utf8 "Du har nödvendig utstyr og de ferdigheter som trengs for å ta deg av dette.", 
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
    close_text     = utf8 "Klikk for å gå ut",
    earned_money   = utf8 "Av en maksimal bonus på %d, har du tjent %d.",
    saved_people   = "Du reddet %d mennesker av totalt %d.",
  },  
  
  -- Deseace discovered
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
    disease_name             = utf8 "Dine ansatte har stött på et tilfelle av %s.",
    what_to_do_question      = utf8 "Hva vil du gjöre med pasienten?",
    guessed_percentage_name  = "Teamet ditt mener de vet hva som feiler pasienten. Det er %d prosent sannsynlighet for at det er %s",
  },
  
  disease_discovered = {
    close_text          = "En ny sykdom er oppdaget.",
    can_cure          = "Du kan behandle denne sykdommen.",
    need_to_build_and_employ = utf8 "Om du bygger %s og ansetter en %s kan du håndtere dette.",
    need_to_build            = utf8 "Du må bygge %s for å håndtere dette.",
    need_to_employ           = utf8 "Ansett en %s for å behandle pasienter med denne sykdommen.",
    discovered_name          = "Ditt team har oppdaget et tilfelle av %s.",
  },
  
  -- Epidemic
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
  
  -- Epidemic result
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
  
  -- VIP visit query
  vip_visit_query = {
    choices = {
      invite = "Send offisiell invitasjon til V.I.P.",
      refuse = utf8 "Avvis forespörselen fra V.I.P med dårlige unnskyldninger.",
    },
    
    vip_name = utf8 "%s har ytret et önske om å få besöke sykehuset ditt",
  },
  
  -- VIP visit result
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
  
  -- Diagnosis failed
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

-- Queue window
queue_window = {
  num_in_queue       = utf8 "Kölengde",
  num_expected       = "Ventet",
  num_entered        = utf8 "Antall besök",
  max_queue_size     = "Maks str.",
}

-- Dynamic info
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
    tiredness                   = utf8 "Tretthet",
    ability                     = "Evner", -- unused?
  },
  
  object = {
    strength                    = "Holdbarhet: %d", -- %d (max. uses)
    times_used                  = "Ganger brukt: %d", -- %d (times used)
    queue_size                  = utf8 "Kölengde: %d", -- %d (num of patients)
    queue_expected              = utf8 "Forventet kölengde: %d", -- %d (num of patients)
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
    
 --[[ 
 -----------------------
 ***** TODO ************
-----------------------
    
* tooltip.new_game_window
* confirmation 
* room_descriptions
* insurance_companies
* menu_debug
* trophy_room

**Under tooltip ****
  * buy_objects_window
  * patient_window
  * staff_window
  * machine_window
  * handyman_window
  * place_objects_window
  * casebook
  * cure_requirement
  * statement
  * research
  * graphs
  * town_map
  * jukebox
  * status
  * policy
  * objects
  * adviser
  * epidemic
  * staff_advice
  * earthquake
  * multiplayer
  * poaching
  * surgery_requirements
  * level_progress
  * progress_report
  * staff_place_advice
  * research
  * boiler_issue
  * competitors
  * room_requirements
  * goals
  * warnings
  * placement_info
  * praise
  * information
  * build_advice

* newspaper
* letter
* humanoid_name_starts
* humanoid_name_ends

** Under fax ****
  *debug_fax
  * emergency
  * locations
  * emergency_result
  * disease_discovered_patient_choice
  * disease_discovered
  * epidemic
  * disease_name
  * epidemic_result
  * vip_visit_query
  * vip_visit_result
  * diagnosis_failed
  * 

-----------------------------------------------------------------------------]]   
    