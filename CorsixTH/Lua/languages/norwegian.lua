--[[ Copyright (c) 2010 Erlend Mongstad, Ola Skogrand

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

Since the norwegian language isn't in the original Theme Hospital game, this 
file is split in two sections (A and B). The first section contains all the new 
language strings, made by the Corsix-TH team, and the second section contains 
the override translation of all the original english strings.

FORMATING AND NORWEGIAN LETTERS
This file contains UTF-8 text. Make sure your editor is set to UTF-8. For the 
norwegian letters ø and Ø, you must use the old-style ö and Ö instead. That is 
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
 
 -- SECTION B - OLD STRINGS (OVERRIDE)
 
   Huge section with all original strings, translated from english.



-----------------------------------------------------------------------------]]


-------------------------------------------------------------------------------
--   SECTION A - NEW STRINGS
-------------------------------------------------------------------------------

-- 1. Global setings (do not edit!)
Language("Norsk", "Norwegian", "nb", "nob")
Inherit("english")


-- 2. Faxes
fax = {
  choices = {
    return_to_main_menu = utf8 "Gå tilbake til hovedmenyen",
    accept_new_level = utf8 "Fortsett til neste nivå",
    decline_new_level = utf8 "Fortsett å spille litt til",
  },
}
letter = {
  dear_player = utf8 "Kjære %s",
  custom_level_completed = utf8 "Bra gjort! Du har fullfört alle utfordringene på dette brukerdefinerte brettet.!",
  return_to_main_menu = utf8 "Vil du gå tilbake til hovedmenyen eller fortsette å spille?",
}

install = {
  title = "--------------------------------- CorsixTH Setup ---------------------------------",
  exit = "Avslutt",
  th_directory = "CorsixTH trenger en kopi av datafilene fra et ekte Theme Hospital spill (eller demo) for å kjöre. Vennligst velg plasseringen til originalspillet nedenfor.",
}

-- 3. Objects
object = {
  litter               = utf8 "Söppel",
}

tooltip.fax.close = utf8 "Lukk dette vinduet uten å slette meldingen"
tooltip.message.button = utf8 "Venstreklikk for å lese faksen"
tooltip.message.button_dismiss = utf8 "Venstreklikk for å åpne faksen, höyreklikk for å ignorere den"

-- 4. Menu 
menu_options = {
  lock_windows = utf8 "  LÅS VINDUER  ",
  edge_scrolling = "  KANTSCROLLING  ",
  settings = "  INNSTILLINGER  ",
}

menu_options_game_speed.pause   = "  PAUSE  "

-- The demo does not contain this string
menu_file.restart = "  RESTART  "

menu_debug = {
  jump_to_level                 = utf8 "  GÅ TIL NIVÅ  ",
  transparent_walls             = "  GJENNOMSIKTIGE VEGGER  ",
  limit_camera                  = "  BEGRENS KAMERA  ",
  disable_salary_raise          = utf8 "  DEAKTIVER LÖNNSÖKNINGER  ",
  make_debug_patient            = "  LAG TESTPASIENT  ",
  cheats                        = "  (F11) JUKSEKODER  ",
  make_debug_fax                = "  (F8) LAG DEBUG FAKS  ",
  dump_strings                  = utf8 "  DUMP SPRÅKSTRENGER  ",
  dump_gamelog                  = "  DUMP SPILL-LOGGEN  ",
  map_overlay                   = "  KARTOVERLEGG  ",
  sprite_viewer                 = "  SPRITE-VISNING  ",
  lua_console                   = "  LUA KONSOLL ",
  calls_dispatcher              = "  ANROPSEKSPEDERING  ",
}

menu_debug_overlay = {
  none                          = "  INGEN  ",
  flags                         = "  FLAGG  ",
  positions                     = "  POSISJONER  ",
  heat                          = "  TEMPERATUR  ",
  byte_0_1                      = "  BYTE 0 & 1  ",
  byte_floor                    = "  BYTE GULV  ",
  byte_n_wall                   = "  BYTE N VEGG  ",
  byte_w_wall                   = "  BYTE W VEGG  ",
  byte_5                        = "  BYTE 5  ",
  byte_6                        = "  BYTE 6  ",
  byte_7                        = "  BYTE 7  ",
  parcel                        = "  PAKKE  ",
}

-- 5. Adviser
adviser = {
  room_forbidden_non_reachable_parts = utf8 "Ved å plassere et rom her vil noen områder på sykehuset bli utilgjengelig.",
  praise = {
    plants_are_well = utf8 "Det er fint. Du tar godt vare på plantene dine. Storartet.",
    few_have_to_stand = utf8 "Nesten ingen trenger å stå i Sykehuset ditt. Pasientene dine vil være glade for det.",
    plenty_of_benches = utf8 "Det er masse sitteplasser, så det er ikke noe problem.",
    plants_thriving = utf8 "Veldig bra. Plantene dine blomstrer. De ser fantastiske ut. Fortsett slik, så vinner du kanskje en trofé for dem."
  },
}

-- 6. Dynamic info
dynamic_info.patient.actions.no_gp_available   = utf8 "Venter på at du skal bygge Allmennpraksis"
dynamic_info.staff.actions.heading_for       = utf8 "På vei til %s"
dynamic_info.staff.actions.fired = "Sparket"

-- 7. Tooltip
tooltip.objects.litter     = utf8 "Söppel: Slengt på gulvet av en pasient, fordi vedkommende ikke fant en söppelbötte å kaste det i."

-- Misc
misc.not_yet_implemented   = "(ikke implementert enda)"
misc.no_heliport       = utf8 "Enten er ingen sykdommer utforsket enda, eller så er det ingen heliport ved dette sykehuset."

-- Main menu
main_menu = {
  new_game     = "Ny karriere",
  custom_level   = "Valgfritt brett",
  load_game   = "Last inn",
  options     = "Innstillinger",
  exit       = "Avslutt",
}

tooltip.main_menu = {
  new_game     = "Start et nytt spill fra begynnelsen",
  custom_level   = utf8 "Bygg sykehuset ditt på et valgfritt område",
  load_game   = "Last inn et tidligere spill",
  options     = "Endre diverse innstillinger",
  exit       = utf8 "Nei, nei, vær så snill å ikke stikk!",
}

load_game_window = {
  caption = "Last inn spill",
}

tooltip.load_game_window = {
  load_game = "Last spill %s",
  load_game_number   = "Last spill %d",
  load_autosave   = "Last autolagring",
}

custom_game_window = {
  caption = "Brukerdefinert spill",
}

tooltip.custom_game_window = {
  start_game_with_name = utf8 "Last nivå %s",
}
save_game_window = {
  caption = "Lagre spill",
  new_save_game = "Nytt spill",
}
tooltip.save_game_window = {
  save_game = "Overskriv spill %s",
  new_save_game = utf8 "Skriv navn på nytt spill",
}
menu_list_window = {
  back = "Tilbake",
  name = "Navn",
  save_date = "Endret",
}
tooltip.menu_list_window = {
  back = utf8 "Lukk dette vinduet",
  name = utf8 "Klikk her for å sortere listen etter navn",
  save_date = utf8 "Klikk her for å sortere listen etter siste endringer",
}
options_window = {
  fullscreen = "Fullskjerm",
  width = "Bredde",
  height = utf8 "Höyde",
  change_resolution = utf8 "Endre opplösning",
  back = "Tilbake",
  browse = "Bla gjennom...",
  cancel = "Avbryt",
  new_th_directory = utf8 "Her kan du spesifisere en annen installasjonsmappe for Theme Hospital. Så fort du velger en ny mappe vil spillet starte på nytt.",  --kalle det "corsixth" isteden for "theme hospital"?
}
tooltip.options_window = {
  fullscreen_button = "Klikk for å gå i fullskjermmodus",
  width = utf8 "Skriv inn önsket skjermbredde",
  height = utf8 "Skriv inn önsket skjermhöyde",
  change_resolution = utf8 "Endre opplösningen til dimensjonene du har angitt til venstre.",
  language = utf8 "Velg %s som språk",
  back = "Lukk vinduet med innstillinger",
  original_path = "Valgt mappe for Theme Hospital installasjonen",
  browse = utf8 "Bla gjennom mappene for å finne et annet sted for Theme Hospital-installasjonen",
}

calls_dispatcher = {
  repair = "Reparere %s",
  summary = "%d Tilkallinger; %d tildelt",
  close = "Lukk",
  watering = "Vanne @ %d,%d",
  staff = "%s - %s",

}

tooltip.calls_dispatcher = {
  assigned = "Denne boksen er huket av om noen er tildet oppdraget.",
  task = utf8 "Liste over oppdrag - Klikk på oppdrag for å se lokasjonen",
  close = "Lukk ekspedisjonsvinduet",
}

cheats_window = {
  close = "Lukk",
  caption = "Juksekoder",
  warning = utf8 "Advarsel: Du vil ikke få noen bonuspoeng på slutten av nivået om du bruker juksekoder!",
  
  cheated = {
    no = "Juksekoder benyttet: Nei",
    yes = "Juksekoder benyttet: Ja",
  },
  
  cheats = {
    end_month = utf8 "Slutten av måneden",
    emergency = utf8 "Lag nödstilfelle",
    win_level = utf8 "Vinn nivå",
    create_patient = "Lag pasient",
    vip = "Lag VIP",
    money = "Penger", 
    lose_level = utf8 "Tap nivå",
    all_research = "All forskning",
    end_year = utf8 "Slutten av året",
  },
}

tooltip.cheats_window = {
  close = "Lukk juksekodevinduet",
  cheats = {
  end_month = utf8 "Gå til slutten av denne måneden.",
  emergency = utf8 "Lag en nödssituasjon.",
  win_level = utf8 "Vinn dette nivået.",
  create_patient = "Lag en pasient på enden av kartet.",
  vip = "Lag en VIP.",
  money = "Sett 10,000 i bankkontoen din.",
  lose_level = utf8 "Tap dette nivået.",
  all_research = utf8 "Fullförer all forskning.",
  end_year = utf8 "Gå til slutten av dette året.",
  },
}
  
new_game_window = {
  easy = "Turnuslege (Lett)",
  medium = "Lege (Medium)",
  hard = "Konsulent (Vanskelig)",
  tutorial = utf8 "Innföring",
  cancel = "Avbryt",
}

tooltip.new_game_window = {
  easy = "Om du ikke har erfaring med simulatorspill er dette tingen for deg",
  medium = utf8 "Om du er usikker på hva du skal velge, så er dette mellomtingen",
  hard = utf8 "Om du er komfortabel med slike spill og önsker utfordring, bör du velge dette.",
  tutorial = utf8 "Om du önsker litt hjelp for å komme i gang må du merke av denne boksen.",
  cancel = utf8 "Hmm... Det var ikke meningen å starte et nytt spill!",
}

lua_console = {
  execute_code = utf8 "Kjör",
  close = "Lukk",
}

tooltip.lua_console = {
  textbox = utf8 "Skriv Lua-kode du vil kjöre her",
  execute_code = utf8 "Kjör koden",
  close = "Lukk konsollen",
}

errors = {
  dialog_missing_graphics   = "Beklager, datafilene i demoen tillater ikke denne dialogen.",
  save_prefix = "Feil under lagring av spill: ",
  load_prefix = "Feil under lasting av spill: ",
  map_file_missing = utf8 "Kunne ikke finne kartfilen %s for dette nivået!",
  minimum_screen_size = utf8 "Vennligst sett opplösningen til minst 640x480.",
  maximum_screen_size = utf8 "Vennligst velg en skjermopplösning ikke större enn 3000x2000.",
  unavailable_screen_size = utf8 "Skjermopplösningen du valgte er ikke tilgjengelig i fullskjermmodus.",
}

confirmation = {
  needs_restart = utf8 "Å forandre denne innstillingen krever en omstart av CorsixTH. Spill som ikke er lagret vil gå tapt. Er du sikker på at du vil endre innstillingen?",
  abort_edit_room = utf8 "Du holder på å bygge eller endre et rom. Om alle obligatoriske gjenstander er plassert ut, ferdigstilles rommet. Om ikke, slettes rommet. Fortsette?",
}

information = {
  custom_game = utf8 "Velkommen til CorsixTH. Kos deg med dette egenutviklede kartet!",
  cannot_restart = utf8 "Dette spillet ble dessverre lagret för restartfunksjonen ble implementert.",
  level_lost = {
    "Kjipt! Du klarte ikke brettet. Bedre lykke neste gang!",
    "Grunnen til at du tapte:",
    reputation = utf8 "Omdömmet ditt gikk under %d.",
    balance = utf8 "Banksaldoen din (minus lån) falt under %d.",
    percentage_killed = "Du drepte mer enn %d prosent av pasientene.", --bruke %-tegn?
  },
}
tooltip.information = {
  close = "Lukk informasjonsdialogen",
}
-- Tips
totd_window = {
  tips = {
    utf8 "Ethvert sykehus trenger en Resepsjon og en Allmennpraksis for å fungere. Etter det avhenger det av hvilke pasienter som besöker sykehuset. Apotek er som regel en god start.",
    utf8 "Maskiner som f.eks. Pumpen i Pumperommet trenger vedlikehold. Ansett en Vaktmester eller to for å vedlikeholde maskinene, ellers risikerer du å skade ansatte og pasienter.",
    utf8 "Etter en stund blir personalet ditt trött. Sörg for å bygge et Personalrom så de kan hvile seg.",
    utf8 "Plasser ovner nok til å holde pasientene og personalet varme, ellers blir de fort misfornöyd. Bruk kartet for å lokalisere områder på sykehuset ditt som trenger mer varme.",
    utf8 "En Lege sine evner påvirker hvor langt tid han bruker på å stille diagnose, samt kvaliteten på diagnosen. Plasser en flink Lege i Allmennpraksisen, da trenger du færre diagnoserom.",
    utf8 "Turnusleger og Doktorer kan utvikle sine evner ved å bli undervist av en Konsulent i Klasserommet. Om Konsulenten har spesielle kvalifikasjoner (Kirurgi, Psykiatri eller Forskning) vil han også lære sine elever dette.",
    utf8 "Har du prövd å slå inn det europeiske nödnummeret (112) på faksen? Sörg for at lyden er på!",
    utf8 "Du kan forandre noen innstillinger som opplösning og språk i innstillinger-vinduet som du finner på hovedmenyen eller på menyen inne i spillet.",
    utf8 "Hvert nivå har en rekke utfordringer som må fullföres för du kan gå videre til neste nivå. Sjekk statusen på utfordringene for nivået i Statusvinduet.",
    utf8 "Om du vil endre eller fjerne et rom, kan du gjöre det med å klikke på Endre Rom knappen på panelet i bunnen av skjermen.",
    utf8 "Du kan alltids finne fort ut hvilke pasienter som venter på å slippe inn i de ulike rommene, ved å flytte musepekeren over rommet.",
    utf8 "Klikk på dören til et rom for å se köen. Du kan gjöre nyttige finjusteringer her, som å organisere köen og sende pasienter til andre lignende rom.",
    utf8 "Irritert personale vil spörre om lönnspålegg jevnlig. Sörg for at dine ansatte jobber i komfortable omgivelser for å hindre at det skjer.",
    utf8 "Pasientene svetter av spenning når de venter på behandling, og gjerne enda mer om du fyrer opp varmen. Plasser noen Brusautomater i strategiske punkter på sykehuset for å tjene noen ekstra lapper.",
    utf8 "Du kan avbryte diagnose-prosessen ganske tidlig og gjette på riktig behandling, dersom du allerede har truffet på tilfeller av sykdommen. Vær oppmerksom på at dette öker sjangsen for feilbehandling. Du vil vel ikke avlive pasientene dine, vel?",
    utf8 "Nödtilfeller kan gjöre deg rik, så sant du har kapasitet til å behandle pasientene i tide.",
    utf8 "Har du valgt norsk språk, men ser likevel engelsk tekst rundt omkring i spillet? Hjelp oss å oversette resten av spillet til norsk!",
    utf8 "CorsixTH-teamet er ute etter forsterkninger! Er du interessert i å programmere, oversette, eller kanskje lage grafikk til CorsixTH? Kontakt oss gjennom Forum, Nyhetsbrev eller IRC (corsix-th på freenode).",
    utf8 "Om du finner feil eller mangler, vær snill å rapportere det gjennom vår feilmeldingstjeneste: th-issues.corsix.org",
  },
  previous = "Forrige tips",
  next = "Neste tips",
}

tooltip.totd_window = {
  previous = "Vis forrige tips",
  next = "Vis neste tips",
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
staff_title = {
  receptionist          = "Resepsjonist",
  general               = "Generelt", -- unused?
  nurse                 = "Sykepleier",
  junior                = "Turnuslege",
  doctor                = "Doktor",
  surgeon               = "Kirurg",
  psychiatrist          = "Psykiater",
  consultant            = "Konsulent",
  researcher            = "Forsker",
}

-- Pay rises
pay_rise = {
  definite_quit = utf8 "Du kan ikke gjöre noe for å beholde meg lenger. Jeg er ferdig her!",
  regular = {
    utf8 "Jeg er helt utslitt. Jeg trenger en god pause, pluss en lönnsökning på %d om du ikke vil se meg gå rundt å sutre i korridorene.", -- %d (rise)
    utf8 "Jeg er veldig trött. Jeg trenger hvile og en lönnsökning på %d, totalt %d. Fiks det nå, din tyrann!", -- %d (rise) %d (new total)
    utf8 "Kom igjen. Jeg jobber som en hund her. Gi meg en bonus på %d og jeg blir på sykehuset ditt.", -- %d (rise)
    utf8 "Jeg er så deppa. Jeg krever en lönnsökning på %d, som blir totalt %d, ellers er jeg ferdig her.", -- %d (rise) %d (new total)
    utf8 "Foreldrene mine sa at medisinyrket ville gi meg mye penger. Så gi meg en lönnsökning på %d, ellers blir jeg spillutvikler istedenfor.", -- %d (rise)
    utf8 "Nå er jeg sint. Gi meg en anstendig lönn. Jeg tror en ökning på %d skal gjöre susen.", -- %d (rise)
  },
  poached = utf8 "Jeg er blitt tilbudt %d av %s. Om ikke du gir meg det samme, så stikker jeg.", -- %d (new total) %s (competitor)
}

-- Staff descriptions
staff_descriptions = {
  good = {
    [1] = "Veldig rask og flittig arbeider. ",
    [2] = "Veldig pliktoppfyllende. Meget omsorgsfull. ",
    [3] = "Er meget allsidig. ",
    [4] = utf8 "Vennlig og alltid i godt humör. ",
    [5] = "Ekstremt utholden. Jobber dag og natt. ",
    [6] = utf8 "Utrolig höflig og har gode manerer. ",
    [7] = "Utrolig talentfull og dyktig. ",
    [8] = utf8 "Er meget opptatt av å prestere på jobben. ",
    [9] = "Er en perfeksjonist som aldri gir opp. ",
    [10] = "Hjelper alltid mennesker med et smil. ",
    [11] = utf8 "Sjarmerende, höflig og hjelpsom. ",
    [12] = "Godt motivert og dedikert til jobben. ",
    [13] = "Snill av natur og meget hardt arbeidende. ",
    [14] = "Lojal og vennlig. ",
    [15] = utf8 "Omtenksom og til å stole på i akutte situasjoner. ",
  },
  misc = {
    [1] = "Spiller golf. ",
    [2] = "Dykker etter kamskjell. ",
    [3] = "Lager isskulpturer. ",
    [4] = "Drikker vin. ",
    [5] = utf8 "Kjörer rally. ",
    [6] = utf8 "Gjör strikkhopp. ",
    [7] = utf8 "Samler på ölbrikker. ",
    [8] = utf8 "Liker å stage-dive. ",
    [9] = "Nyter fjertesurfing. ",
    [10] = utf8 "Liker å utvide elver. ",
    [11] = "Destillerer whisky. ",
    [12] = utf8 "Gjör-det-selv ekspert. ",
    [13] = "Liker franske kunstfilmer. ",
    [14] = "Spiller mye Theme Park. ",
    [15] = "Har sertifikat klasse C. ",
    [16] = "Deltar i motorsykkelrace. ",
    [17] = "Spiller klassisk fiolin og cello. ",
    [18] = "Entusiastisk tog-vraker. ",
    [19] = "Hundeelsker. ",
    [20] = utf8 "Hörer på radio. ",
    [21] = "Bader ofte. ",
    [22] = utf8 "Instruktör i bambusfletting. ",
    [23] = utf8 "Lager såpeholdere av grönnsaker. ",
    [24] = "Deltids minerydder. ",
    [25] = "Quizvert. ",
    [26] = utf8 "Samler på splinter fra 2.verdenskrig. ",
    [27] = utf8 "Liker å ommöblere. ",
    [28] = utf8 "Hörer på rave og trip-hop musikk. ",
    [29] = "Dreper insekter med deodorantspray. ",
    [30] = utf8 "Piper ut dårlige standupartiser. ",
    [31] = utf8 "Gjör innkjöp for sykehusrådet. ",
    [32] = "Hemmelighetsfull gartner. ",
    [33] = "Smugler falske klokker. ",
    [34] = "Vokalist i et rockeband. ",
    [35] = utf8 "Forguder tv-titting på dagtid. ",
    [36] = utf8 "Fisker etter örret. ",
    [37] = utf8 "Lurer turister på museum. ",
  },
  bad = {
    [1] = "Langsom og masete. ",
    [2] = "Lat og lite motivert. ",
    [3] = utf8 "Dårlig trent og ubrukelig. ",
    [4] = "Dum og slitsom. Er en reserve. ",
    [5] = utf8 "Lav utholdenhet. Har en dårlig holdning. ",
    [6] = utf8 "Döv som et papir. Lukter kål. ",
    [7] = "Skitner til jobben. Tar lite ansvar. ",
    [8] = "Konsentrasjonsvansker og lett distrahert. ",
    [9] = utf8 "Stresset og gjör mye feil. ",
    [10] = "Lett antennelig. Sitter inne med mye hat. ",
    [11] = "Uforsiktig og uheldig. ",
    [12] = "Bryr seg ikke om jobben. Inaktiv. ",
    [13] = "Dumdristig og bryr seg lite. ",
    [14] = "Slu, utspekulert og baksnakker andre. ",
    [15] = utf8 "Arrogant og ovenpå. ",
  },
} 

-- Staff list
staff_list = {
  morale       = "MORAL",
  tiredness    = "TRETTHET",
  skill        = "FERDIGHETER",
  total_wages  = utf8 "TOTAL LÖNN",
}

-- Objects
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
  electrolyser          = "Elektrolysator",
  jelly_moulder         = utf8 "Gelétönne",
  gates_of_hell         = "Helvetesporten",
  bed3                  = "Seng", -- unused duplicate
  bin                   = utf8 "Söppelbötte",
  toilet                = "Toalett",
  swing_door1           = utf8 "Svingdör",
  swing_door2           = utf8 "Svingdör",
  shower                = "Saneringsdusj",
  auto_autopsy          = "Obdksjonsautomat",
  bookcase              = "Bokhylle",
  video_game            = "Videospill",
  entrance_left         = utf8 "Inngang venstre dör",
  entrance_right        = utf8 "Inngang höyre dör",
  skeleton              = "Skjelett",
  comfortable_chair     = "Komfortabel stol",
}

-- Place objects window
place_objects_window = {
  drag_blueprint                = utf8 "Juster blåkopien til du er fornöyd med störrelsen",
  place_door                    = utf8 "Velg hvor dören skal være",
  place_windows                 = utf8 "Lag noen vinduer om du vil. Bekreft når du er ferdig",
  place_objects                 = utf8 "Plasser gjenstandene. Bekreft når du er fornöyd",
  confirm_or_buy_objects        = utf8 "Du kan ferdigstille rommet, evt. fortsette å kjöpe eller flytte gjenstander",
  pick_up_object                = utf8 "Klikk på gjenstander for å plukke de opp, eller gjör et annet valg fra boksen",
  place_objects_in_corridor     = "Plasser gjenstander i korridoren",
}

-- Competitor names
competitor_names = {
  [1] = "ORAKEL",
  [2] = "HALL",
  [3] = "KOLOSS",
  [4] = "SLAMSUGER",
  [5] = "HELLIG",
  [6] = "DYPE TANKER",
  [7] = "ZEN",
  [8] = "LEO",
  [9] = "AKIRA",
  [10] = "SAM",
  [11] = "CHARLIE",
  [12] = "JANNE",
  [13] = "ARTUR",
  [14] = "MAGNUS",
  [15] = "MAMMA",
  [16] = "STEFAN",
  [17] = "MATS",
  [18] = "JONAS",
  [19] = "DANIEL",
  [20] = "OLIVIA",
  [21] = "NILS",
  [22] = "THOR",
  [23] = "RISK",
  [24] = "NIC",
}

-- Months
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

-- Date format
date_format.daymonth = "%1% %2:months%"

-- Graphs
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

-- Transactions
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


-- Level names
level_names = {
  "Giftigby",
  "Soveby",
  "Storestad",
  utf8 "Frimpton-på-Sjöen",
  utf8 "Lettåker",
  "Varberget",
  "Langtbort",
  "Halvestrad",
  "Austby",
  "Eggtorp",
  "Kvekkestad",
  "Snylteby",
  "Polartorp",
  "Lille Riseby",
  "Gravland",
}


-- Town map
town_map = {
  chat         = "Bykart Chat",
  for_sale     = "Til salgs",
  not_for_sale = "Ikke til salgs",
  number       = "Tomt nummer", 
  owner        = "Tomt eier",
  area         = utf8 "Tomt område",
  price        = "Tomt pris",
}


-- Rooms short
-- NB: includes some special "rooms"
-- reception, destroyed room and "corridor objects"
rooms_short = {
  reception         = "Resepsjon",
  destroyed         = utf8 "Ödelagt",
  corridor_objects  = "Korridorgjenstander",
  
  gps_office        = "Allmennpraksis",
  psychiatric       = "Psykiatri",
  ward              = "Sykestue",
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

-- Rooms long
rooms_long = {
  general           = "Generell", -- unused?
  emergency         = utf8 "Nödstilfelle",
  corridors         = "Korridorer",
  
  gps_office        = "Allmennpraksis",
  psychiatric       = "Psykiatri",
  ward              = "Sykestue",
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

room_descriptions = {
  ultrascan = {
    [1] = "Ultraskanner//",
    [2] = utf8 "Ultraskanneren er virtuelt i toppklassen innenfor diagnoseutstyr. Den koster mye, men det lönner seg om du vil ha superb diagnostisering på ditt sykehus.//",
    [3] = utf8 "Ultraskanneren kan kun håndteres av ".. staff_class.doctor .."r. Den krever også vedlikehold. ",
  },
  gp = {
    [1] = "Allmennpraksis//",
    [2] = utf8 "Dette er det fundamentale diagnoserommet på ditt sykehus. Nye pasienter blir sendt hit for å finne ut hva som feiler dem. Videre blir de sendt enten til dypere diagnostisering eller til et rom hvor de kan få behandling for sine plager. Du trenger sannsynligvis flere Allmennpraksiser om det oppstår lange köer. Jo större rommet er og jo mer utstyr du plasserer i rommet, desto bedre presterer Legen. Dette gjelder også for alle andre rom.//",
    [3] = utf8 "Allmennpraksisen kan kun håndteres av Leger. ",
  },
  fracture_clinic = {
    [1] = "Benbruddsklinikk//",
    [2] = utf8 "Pasienter som uheldigvis har Benbrudd vil bli behandlet her. Gipsfjerneren bruker en kraftig industrilaser for å kutte vekk gipsen, og forårsaker bare litt smerte for pasienten.//",
    [3] = utf8 "Benbruddsklinikken kan kun håndteres av Sykepleiere. Den krever også vedlikehold. ",
  },
  tv_room = {
    [1] = "TV ROOM NOT USED",
  },
  inflation = {
    [1] = "Pumperom//",
    [2] = utf8 "Pasienter med sitt smertefulle, men dog humoristiske Ballonghode, må behandles på Pumperommet. Her blir hodet stukket hull på, trykket forsvinner, og en Lege pumper hodet opp til riktig trykknivå.//",
    [3] = utf8 "Pumperommet kan kun håndteres av Leger. Regelmessig vedlikehold er også viktig. ",
  },
  jelly_vat = {
    [1] = utf8 "Gelétönne//",
    [2] = utf8 "Pasienter med den snodige sykdommen gelésyndrom må skjelve seg fram til gelétönnerommet, for så å bli plassert i gelétönnen. Dette vil kurere dem på en måte som ikke er helt begripelig for det medisinske faget.//",
    [3] = utf8 "Gelétönnen kan kun håndteres av Leger. Det kreves også vedlikehold. ",
  },
  scanner = {
    [1] = "Skanner//",
    [2] = utf8 "Pasienter får veldig nöyaktig diagnostisert sin sykdom ved bruk av den sofistikerte Skanneren. Deretter går de til Allmennpraksisen og snakker med en Lege for videre behandling.//",
    [3] = utf8 "Skanneren kan kun håndteres av Leger. Det kreves også vedlikehold. ",
  },
  blood_machine = {
    [1] = "Blodmaskin//",
    [2] = utf8 "Blodmaskinen er et diagnoseverktöy som sjekker alle cellene i pasientens blod for å finne ut hva som feiler dem.//",
    [3] = utf8 "Blodmaskinen kan kun håndteres av Leger. Det kreves også vedlikehold. ",
  },
  pharmacy = {
    [1] = "Apotek//",
    [2] = utf8 "Pasienter som har blitt diagnostisert og trenger behandling av et medikament må besöke Apoteket for å få medisinen sin. Ettersom fler og fler medisinkurer er forsket på og blir tilgjengelige, blir dette rommet stadig travlere. Du önsker kanskje å bygge et nytt Apotek senere.//",
    [3] = utf8 "Apoteket kan kun håndteres av Sykepleiere. ",
  },
  cardiogram = {
    [1] = "Kardiorom//",
    [2] = utf8 "Pasienter blir undersökt og diagnostisert her, för de går tilbake til Allmennpraksisen for å få utpekt en kur.//",
    [3] = utf8 "Kardiorommet kan kun håndteres av Leger. Det kreves også vedlikehold. ",
  },
  ward = {
    [1] = "Sykestue//",
    [2] = utf8 "Pasientene blir lagt inn her for observasjon av en Sykepleier mens de diagnostiseres. De forblir her til de er klare for å legges under kniven på Operasjonssalen.//",
    [3] = utf8 "Sengeavdelingen kan kun håndteres av Sykepleiere. ",
  },
  psych = {
    [1] = "Psykiatri//",
    [2] = utf8 "Pasienter diagnostisert med psykiske lidelser må gå til Psykiatrien for å få rådgivning. Psykiatrene kan kjöre diagnose for å finne ut hva slags type sykdom pasientene lider av, og hvis mental opprinnelse, så behandle dem ved å benytte den trygge sofaen.//",
    [3] = utf8 "Psykiatrien kan kun håndteres av kvalifisert Psykiater. ",
  },
  staff_room = {
    [1] = "Personalrom//",
    [2] = utf8 "De ansatte blir slitne etter hvert som de utförer pliktene sine. De trenger dette rommet for å slappe av og heve humöret. Om de ansatte er slitne, så blir de tregere, krever mer lönn og vil til slutt si opp. De gjör også flere feilgrep. Å bygge et Personalrom med masse aktiviteter for dem er vel anvendte penger. Pass på at det er plass til flere ansatte på en gang. ",
  },
  operating_theatre = {
    [1] = "Operasjonssal//",
    [2] = utf8 "Denne viktige installasjonen er der en rekke forhold blir behandlet. Operasjonssalen må være av en god störrelse, og må fylles med riktig utstyr. Det er en viktig del av sykehuset.//",
    [3] = utf8 "Operasjonssalen kan kun håndteres av to Kvalifiserte Kirurger. ",
  },
  training = {
    [1] = "Klasserom//",
    [2] = utf8 "Turnuslegene og Doktorene dine kan få, verdifulle, ekstra kvalifikasjoner ved å studere i dette rommet. En Konsulent med Kirurgi-, Forsker- eller Psykiatri-fordypning vil lære bort dette til de Legene som sitter i rommet. Leger som allerede har disse ferdighetene vil bli enda flinkere mens de er her.//",
    [3] = utf8 "Klasserommet kan kun håndteres av en Konsulent. ",
  },
  dna_fixer = {
    [1] = "DNA-klinikk//",
    [2] = utf8 "Pasienter som har befattet seg med romvesener fra en annen verden må få DNA-et sitt byttet ut i dette rommet. DNA-fikseren er en veldig kompleks maskin, og det ville være fornuftig å holde et brannslukningsapparat i nærheten av den, bare i tilfelle.//",
    [3] = utf8 "DNA-fikseren kan kun håndteres av en kvalifisert Forsker. Den behöver periodisk vedlikehold av en Vaktmester. ",
  },
  research = {
    [1] = "Forskningsavdeling//",
    [2] = utf8 "Nye medikamenter og kurer blir funnet opp og forbedret i Forskningsavdelingen. Det er en vital del av sykehuset ditt, og vil gjöre underverker for kureringsstatistikken din.//",
    [3] = utf8 "Forskningsavdelingen kan kun håndteres av en kvalifisert Forsker. ",
  },
  hair_restoration = {
    [1] = utf8 "Hårklinikk//",
    [2] = utf8 "Pasienter som lider av ekstreme tilfeller av Flintskallethet må henvende seg til Hårrenoveringsmaskinen i denne klinikken. En Lege vil operere maskinen, og den vil sette avleggere i pasientens hode som raskt blir til nytt hår.//",
    [3] = utf8 "Hårklinikken kan kun håndteres av Leger. Det kreves også periodisk vedlikehold. ",
  },
  general_diag = {
    [1] = "Generell Diagnose//",
    [2] = utf8 "Pasienter som trenger videre diagnose blir sendt hit for undersökelse. Om Allmennpraksisen ikke finner ut hva som feiler dem, så vil Generell Diagnose ofte finne det ut. Herfra vil de bli sendt tilbake til Allmennpraksisen for analyse av resultatet.//",
    [3] = utf8 "Generell Diagnose kan kun håndteres av Leger. ",
  },
  electrolysis = {
    [1] = "Elektrolyseklinikk//",
    [2] = utf8 "Pasienter med Pelssyndrom blir sendt hit, hvor en spesialmaskin brenner av håret og forsegler porene elektrisk med en sammensetning som ikke er ulik fugemasse.//",
    [3] = utf8 "Elektrolyseklinikken kan kun håndteres av Leger. Den behöver vedlikehold av en Vaktmester. ",
  },
  slack_tongue = {
    [1] = "Tungeklinikk//",
    [2] = utf8 "Pasienter som blir diagnostisert med Lös tunge fra Allmennpraksisen, vil bli sendt til denne klinikken for behandling. Legen bruker en höyteknologisk maskin som forlenger tungen og kutter den av, dermed bringes pasienten tilbake til normal, god helse.//",
    [3] = utf8 "Tungekutteren kan kun håndteres av Leger. Det kreves også vedlikehold nok så ofte. ",
  },
  toilets = {
    [1] = "Toalett//",
    [2] = utf8 "Pasienter som föler at naturen kaller, må gå og lette på trykket i dine behagelige toalettfasiliteter. Du kan bygge ekstra toalettbåser og vasker om du forventer mange besökende. I noen tilfeller bör du kanskje vurdere å bygge flere Toaletter andre steder i sykehuset. ",
  },
  no_room = {
    [1] = "",
  },
  x_ray = {
    [1] = utf8 "Röntgenrom//",
    [2] = utf8 "Röntgenmaskinen fotograferer pasientenes innside ved bruk av spesiell stråling for å gi en god indikasjon på hva som er galt med dem.//",
    [3] = utf8 "Röntgenmaskinen kan kun håndteres av Leger. Det kreves også vedlikehold. ",
  },
  decontamination = {
    [1] = "Saneringsklinikk//",
    [2] = utf8 "Pasienter som har blitt utsatt for Stråling blir fort henvist til Saneringsklinikken. Dette rommet inneholder en dusj som skyller av dem all den vemmelige Radioaktiviteten og skitt.//",
    [3] = utf8 "Saneringsdusjen kan kun håndteres av Leger. Den behöver vedlikehold av en Vaktmester. ",
  },
}

-- Drug companies
drug_companies = {
  "Medisiner-For-Deg",
  "Kur R Oss",
  utf8 "Runde Små Piller Co.",
  "Dyremedisin AS",
  "Alle Piller Co.",
}

-- Build rooms
build_room_window = {
  pick_department   = "Velg avdeling",
  pick_room_type    = "Velg romtype",
  cost              = "Pris: ",
}

-- Build objects
buy_objects_window = {
  choose_items      = "Velg gjenstander",
  price             = "Pris:",
  total             = "Sum:",
}

-- Research
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

-- Research policy tooltip
tooltip.research_policy = {
research_progress = "Progresjon mot den nesten oppdagelsen i denne kategorien: %1%/%2%",
no_research = utf8 "Ingen forskning blir utfört i denne kategorien for öyeblikket",
}

-- Policy screen
policy = {
  header            = "SYKEHUSPOLICY",
  diag_procedure    = "diagnoserutiner",
  diag_termination  = "diagnostisering",
  staff_rest        = utf8 "pauserutiner",
  staff_leave_rooms = "forlate rom",
  
  sliders = {
    guess           = "GJETT KUR", -- belongs to diag_procedure
    send_home       = "SEND HJEM", -- also belongs to diag_procedure
    stop            = "AVBRYT PROSESS", -- belongs to diag_termination
    staff_room      = utf8 "TIL PERSONALROM", -- belongs to staff_rest
  }
}

-- Rooms
room_classes = {
  -- S[19][2] -- "corridors" - unused for now
  diagnosis  = "Diagnose",
  treatment  = "Behandling",
  clinics    = "Klinikker",
  facilities = "Fasiliteter",
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
  file                  = "  FIL  ",
  options               = "  INNSTILLINGER  ",
  display               = "  VIS  ",
  charts                = "  OVERSIKTER  ",
  debug                 = "  DEBUG  ",
}

-- Menu File
menu_file = {
  load                  = "  LAST INN  ",
  save                  = "  LAGRE  ",
  restart               = utf8 "  START PÅ NYTT  ",
  quit                  = "  AVSLUTT  ",
}
menu_file_load = {
  [1] = "  SPILL 1  ",
  [2] = "  SPILL 2  ",
  [3] = "  SPILL 3  ",
  [4] = "  SPILL 4  ",
  [5] = "  SPILL 5  ",
  [6] = "  SPILL 6  ",
  [7] = "  SPILL 7  ",
  [8] = "  SPILL 8  ",
}
menu_file_save = {
  [1] = "  SPILL 1  ",
  [2] = "  SPILL 2  ",
  [3] = "  SPILL 3  ",
  [4] = "  SPILL 4  ",
  [5] = "  SPILL 5  ",
  [6] = "  SPILL 6  ",
  [7] = "  SPILL 7  ",
  [8] = "  SPILL 8  ",
}

-- Menu Options
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

-- Menu Options Volume
menu_options_volume = {
  [10] = "  10%  ",
  [20] = "  20%  ",
  [30] = "  30%  ",
  [40] = "  40%  ",
  [50] = "  50%  ",
  [60] = "  60%  ",
  [70] = "  70%  ",
  [80] = "  80%  ",
  [90] = "  90%  ",
  [100] = "  100%  ",
}

-- Menu Options Game Speed
menu_options_game_speed = {
  slowest             = "  TREGEST  ",
  slower              = "  TREGERE  ",
  normal              = "  NORMAL  ",
  max_speed           = "  MAKSIMAL HASTIGHET  ",
  and_then_some_more  = "  OG LITT RASKERE  ",
}

-- Menu Display
menu_display = {
  high_res            = utf8 "  HÖY OPPLÖSNING  ",
  mcga_lo_res         = "  MCGA LAV OPPL.  ",
  shadows             = "  SKYGGER  ",
}

-- Menu Charts
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

debug_patient_window = {
  caption = "Testpasient",
}

-- High score screen
high_score = {
  pos          = "POS",
  player       = "SPILLER",
  score        = "POENG",
  best_scores  = "HALL OF FAME",
  worst_scores = "HALL OF SHAME",
  killed       = "Drepte", -- is this used?
  
  categories = {
    money             = "RIKEST",
    salary            = utf8 "HÖYESTE LÖNN",
    clean             = "RENSLIGHET",
    cures             = "ANTALL KURERT",
    deaths            = utf8 "ANTALL DÖDSFALL",
    cure_death_ratio  = utf8 "ANTALL BEHANDLINGSDÖDSFALL",
    patient_happiness = "TILFREDSTILLHET PASIENTER",
    staff_happiness   = "TILFREDSTILLHET PERSONALE",
    staff_number      = "MEST PERSONALE",
    visitors          = "FLEST PASIENTER",
    total_value       = "TOTAL VERDI",
  },
}

-- Trophy room
trophy_room = {
  reputation = utf8 "OMDÖMME",
  cash = "KONTANTER",
  pop_percentage = {
    awards = {
    [1] = utf8 "Legg merke til at du har fått en höy andel av byen befolkning til ditt sykehus det siste året. Bra gjort",
    [2] = utf8 "Gratulerer. En höyere andel av lokalbefolkningen besöker sykehuset ditt enn noen andre institusjoner.",
    [3] = utf8 "Strålende. Du har lokket mer av befolkningen inn ditt sykehus enn det som har besökt alle de andre sykehusene til sammen.",
    },
  },
  many_cured = {
    awards = {
      [1] = utf8 "Gratulerer med Marie Curie Prisen for å ha klart å kurere nesten alle pasientene på sykehuset ditt i fjor.",
      [2] = utf8 "Gratulerer med å ha kurert mengder av pasienter det siste året. Mange mennesker föler seg mye bedre på grunn av ditt arbeid.",
      [3] = utf8 "Vær så snill å ta imot denne prisen for å ha kurert flere pasienter enn noe annet sykehuset. En enestående innstats.",
      [4] = utf8 "Du er herved tildelt den ultimate kureringsprisen for å ha kurert flere mennesker enn alle de andre sykehusene til sammen.",

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
      [1] = utf8 "Du er herved tildelt statsministerens Glitrende Sykehusstandard Pris, som tildeles sykehuset med best omdömme i fjor. Flott!",
      [2] = utf8 "Vær snill å ta imot Bullfrog-prisen som tildeles sykehuset med best omdömme i fjor. Nyt det - det er vel fortjent!",
      [3] = utf8 "Godt gjort. Du vinner en liten pris for å ha oppnådd et ganske imponerende rykte det siste året.",
      [4] = utf8 "Fantastisk! Ditt sykehus vinner en pris for å ha bygd opp best omdömme det siste året.",
      [5] = utf8 "Dette året har ditt sykehus sitt omdömme overgått alle de andre sykehusene satt sammen. En stor prestasjon.",
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
      utf8 "Du har vunnet Nobelprisen for Imponerte VIP-er. Alle som besökte sykehuset ditt i fjor snakker ikke om annet.",
      utf8 "Gratulerer med VIP-prisen for å ha gjort livene til hardtarbeidende kjendiser bedre, ved å sette alle som besökte sykehuset ditt i fjor i et bedre lys. Fantastisk.",
    },
    trophies = {
      utf8 "Byrået for Kjente Personer vil belönne deg med Kjendistrofeet for å ha tatt godt vare på alle VIP-er som besökte institusjonen din i fjor. Du nærmer deg kjendis-status, nesten en av oss.",
    },
  },
  no_deaths = {
    awards = {
      [1] = utf8 "Du har vunnet Leve Lenge Trofeet for å holde 100 prosent av pasientene levende i hele fjor.",
      [2] = utf8 "Du har fått denne prisen til minne om lavt antall dödsfall på ditt sykehus dette året. Dette er flott.",
      [3] = utf8 "Dödstallene i ditt sykehus i fjor var lavere enn noen andre sykehus. Vennligst ta imot denne prisen.",
      [4] = utf8 "Din geniale styring har holdt dödsfall i sykehuset til et minimum. Du kan være svært fornöyd med dette resultatet.",

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
      utf8 "Sykehuset ditt er blitt tildelt Sprudlende-Begjær Trofeet for antall leskedrikker som ble solgt på sykehuset ditt i fjor.",
      utf8 "På vegne av DK Fyllinger Co., tildeles du herved dette trofeet dekket av sjokolade, for å ha solgt enorme mengder leskedrikker på sykehuset ditt forrige år.",
    },
  },
}


-- Casebook screen
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
    build_ward         = "Du trenger fremdeles en Sykestue.",
    hire_doctors       = utf8 "Du må ansette noen Leger.",
    hire_surgeons      = utf8 "Du må ansette Kirurger.",
    hire_psychiatrists = utf8 "Du må ansette Psykiatere.",
    hire_nurses        = utf8 "Du må ansette Sykepleiere.",
    no_cure_known      = "Ingen kjente kurer.",
    cure_known         = "Kur.",
    improve_cure       = "Forbedre kur",
  },
}

-- Tooltips
tooltip = {
  
  -- Build room window
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
  
  -- Toolbar
  toolbar = {
    bank_button        = utf8 "Venstreklikk for Bankmanager, höyreklikk for Kontoutskrift",
    balance            = "Din Balanse",
    reputation         = utf8 "Ditt omdömme: ", -- NB: no %d! Append " ([reputation])".
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
  
  -- Hire staff window
  hire_staff_window = {
    doctors            = utf8 "Vis Leger tilgjengelig på arbeidsmarkedet",
    nurses             = utf8 "Vis Sykepleiere tilgjengelig på arbeidsmarkedet",
    handymen           = utf8 "Vis Vaktmestere tilgjengelig på arbeidsmarkedet",
    receptionists      = utf8 "Vis Resepsjonister tilgjengelig på arbeidsmarkedet",
    prev_person        = "Vis forrige person",
    next_person        = "Vis neste person",
    hire               = "Ansett person",
    cancel             = "Avbryt",
    doctor_seniority   = "Legens erfaring (Turnuslege, Doktor, Konsulent)",
    staff_ability      = "Evner",
    salary             = utf8 "Lönnskrav",
    qualifications     = "Legens spesialisering",
    surgeon            = "Kirurg",
    psychiatrist       = "Psykiater",
    researcher         = "Forsker",
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
    doctors            = "Se en oversikt over dine Leger",
    nurses             = "Se en oversikt over dine Sykepleiere",
    handymen           = "Se en oversikt over dine Vaktmestere",
    receptionists      = "Se en oversikt over dine Resepsjonister",
    
    happiness          = utf8 "Viser hvordan humöret på dine ansatte er",
    tiredness          = utf8 "Viser hvor trött dine ansatte er",
    ability            = "Viser evnene til dine ansatte",
    salary             = utf8 "Den enkeltes gjeldende lönn",
    
    happiness_2        = "Den ansattes moral",
    tiredness_2        = utf8 "Den ansattes tretthetsnivå",
    ability_2          = "Den ansattes evner",
    
    prev_person        = "Velg forrige side",
    next_person        = "Velg neste side",
    
    bonus              = "Gi denne ansatte 10% bonus",
    sack               = "Si opp denne ansatte",
    pay_rise           = utf8 "Hev lönnen til denne ansatte med 10%",
    
    close              = "Lukk og returner til spillet",
    
    doctor_seniority   = "Legens erfaring",
    detail             = utf8 "Oppmerksom på detaljer",
    
    view_staff         = utf8 "Vis ansatt på jobb",
    
    surgeon            = "Kvalifisert Kirurg",
    psychiatrist       = "Kvalifisert Psykiater",
    researcher         = "Kvalifisert Forsker",
    surgeon_train      = "%d%% ferdig med fordypning innen kirurgi", -- %d (percentage trained)
    psychiatrist_train = "%d%% ferdig med fordypning innen psykiatri", -- %d (percentage trained)
    researcher_train   = "%d%% ferdig med fordypning innen forskning", -- %d (percentage trained)
    
    skills             = "Ekstra evner",
  },
  
  -- Queue window
  queue_window = {
    num_in_queue       = utf8 "Antall pasienter i köen",
    num_expected       = utf8 "Antall pasienter Resepsjonisten forventer i köen innen kort tid",
    num_entered        = utf8 "Antall pasienter som er behandlet i dette rommet så langt",
    max_queue_size     = utf8 "Maksimal lengde på köen som Resepsjonisten skal etterstrebe",
    dec_queue_size     = utf8 "Senk maksimal kölengde",
    inc_queue_size     = utf8 "Ök maksimal kölengde",
    front_of_queue     = utf8 "Dra en pasient hit for å stille han/henne fremst i köen",
    end_of_queue       = utf8 "Dra en pasient hit for å stille han/henne bakerst i köen",
    close              = "Lukk vindu",
    patient            = utf8 "Dra en pasient for å flytte han/henne i köen. Höyreklikk på en pasient for å sende han/henne hjem eller til et konkurrerende sykehus",
    patient_dropdown = {
      reception        = "Henvis pasient til Resepsjonist",
      send_home        = "Send pasienten hjem",
      hospital_1       = "Henvis pasienten til et annet sykehus",
      hospital_2       = "Henvis pasienten til et annet sykehus",
      hospital_3       = "Henvis pasienten til et annet sykehus",
    },
  },
  
  -- Main menu
  main_menu = {
    new_game           = "Start en ny karriere",
    load_game          = "Last inn et tidligere spill",
    continue           = "Fortsett forrige spill",
    network            = "Start nettverksspill",
    quit               = "Avslutt",
    load_menu = {
      load_slot        = "  SPILL [slotnumber]  ", -- NB: no %d! Append " [slotnumber]".
      empty_slot       = "  TOM  ",
    },
  },
  -- Window general
  window_general = {
    cancel             = "Avbryt",
    confirm            = "Bekreft",
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
    psychiatrist       = "Psykiater",
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
    repair             = utf8 "Kall på Vaktmester for å fikse maskinen",
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
    prio_litter        = utf8 "Be Vaktmesteren om å prioritere rengjöring av gulv höyere", -- contains "handyman"
    prio_plants        = utf8 "Be Vaktmesteren om å prioritere vanning av planter höyere", -- contains "handyman"
    prio_machines      = utf8 "Be Vaktmesteren om å prioritere reparasjon av maskiner höyere", -- contains "handyman"
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
      psychiatrist     = "En Psykiater kreves for behandling",
      surgery          = "Denne sykdommen krever en operasjon",
      machine          = "Denne sykdommen krever en maskin for behandling",
      unknown          = "Du vet ikke hvordan du skal behandle denne sykdommen enda",
    },
    
    cure_requirement = {
      possible         = utf8 "Du kan gjennomföre behandling",
      research_machine = utf8 "Du må forske på maskiner for å gjennomföre behandlingen",
      build_room       = utf8 "Du må bygge et rom for å gjennomföre behandlingen", -- NB: no %s!
      hire_surgeons    = utf8 "Du trenger to Kirurger for å gjennomföre behandlingen",
      hire_surgeon     = utf8 "Du trenger en Kirurg til for å gjennomföre behandlingen",
      hire_staff       = utf8 "Du må ansette en %s for å gjennomföre behandlingen", -- %s (staff type)
      hire_staff_old   = utf8 "Du må ansette en %s for å gjennomföre behandlingen",
      build_ward       = utf8 "Du må bygge en Sykestue for å kunne gjennomföre behandlingen",
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
  
  -- Status
  status = {
    percentage_cured   = utf8 "Du må kurere %d% besökende på sykehuset ditt. Nå har du kurert %d%",
    thirst             = utf8 "Gjennomsnittlig törste på personene på ditt sykehus",
    close              = "Lukk oversikten",
    population_chart   = "Figur som viser hvor stor andel av lokalbefolkningen hvert sykehus tiltrekker seg",
    win_progress_own   = utf8 "Vis progresjon i forhold til kravene for dette nivået",
    reputation        = utf8 "Omdömmet ditt må være minst %d. Nå er det %d",
    population        = utf8 "Du må ha %d%% av befolkningen til å bruke ditt sykehus",
    warmth             = utf8 "Gjennomsnittlig temperatur på personene på ditt sykehus",
    percentage_killed  = utf8 "Du må drepe færre enn %d%% av dine besökende. Så langt har du tatt livet av %d%%",
    balance        = utf8 "Din bankbalanse må være på minst %d. Nå er den %d",
    value          = utf8 "Sykehuset ditt må være verdt $%d. Så langt er det verdt $%d",
    win_progress_other = utf8 "Vis progresjon i forhold til kravene for dette nivået for %s", -- %s (name of competitor)
    num_cured        = utf8 "Du må kurere %d mennesker. Så langt har du kurert %d",
    happiness          = utf8 "Gjennomsnittlig humör på personene på ditt sykehus",
  },
  
  -- Policy
  policy = {
    close              = "Lukk sykehuspolicy",
    staff_leave        = utf8 "Klikk her for å få personale som ikke er opptatt til å hjelpe kollegaer som trenger det",
    staff_stay         = utf8 "Klikk her for å få personale til å bli i rommene du plasserer dem i",
    diag_procedure     = "Om en Leges stilte diagnose er mindre sikker enn SEND HJEM prosenten, vil pasienten bli sendt hjem. Om diagnosen er sikrere enn GJETT KUR prosenten, vil pasienten sendes til aktuell behandling",
    diag_termination   = utf8 "En pasients diagnostisering vil fortsette helt til Legene er så sikker som AVBRYT PROSESS prosenten, eller til alle diagnosemaskiner er forsökt på pasienten",
    staff_rest         = utf8 "Hvor trött personalet må være för de kan hvile",
  },
  
  -- Pay rise window
  pay_rise_window = {
    accept             = utf8 "Imötekom kravene",
    decline            = "Ikke godta kravene - Si opp istedenfor",
  },
  
  -- Watch
  watch = {
    hospital_opening   = utf8 "Byggetid: Dette er tiden du har igjen för sykehuset åpner. Klikk på ÅPNE-knappen, så vil sykehuset åpne umiddelbart.",
    emergency          = utf8 "Nödstilfelle: Tid som gjenstår til å behandle alle akutte pasienter.",
    epidemic           = utf8 "Epidemi: Tid som gjenstår til å skjule epidemien. Når tiden er ute ELLER en smittsom pasient forlater sykehuset, så kommer en Helseinspektör på besök. Knappen skrur av og på vaksineringsmodus. Klikk på pasienter for å få en Sykepleier til å vaksinere dem.",
  },
  
  -- Rooms
  rooms = {
    gps_office         = utf8 "Pasientene får sin förste konsultasjon og tilhörende resultater på Allmennpraksisen",
    psychiatry         = utf8 "Psykiatrien kurerer gale pasienter og hjelper til med diagnostiseringen av andre pasienter, men trenger en Lege med spesialisering innenfor Psykiatri",
    ward               = utf8 "Sengeavdelinger er nyttige for både diagnostisering og behandling. Pasienter blir sendt hit for observasjon men også for overvåkning etter operasjoner. Sengeavdelingen krever en Sykepleier",
    operating_theatre  = "Operasjonssalen krever to Leger med spesialisering innenfor Kirurgi",
    pharmacy           = utf8 "Sykepleieren skriver ut medisiner på apoteket for å kurere pasienter",
    cardiogram         = utf8 "En Lege bruker Kardio for å diagnostisere pasienter",
    scanner            = utf8 "En Lege bruker Skanneren for å diagnostisere pasienter",
    ultrascan          = utf8 "En Lege bruker Ultraskanneren for å diagnostisere pasienter",
    blood_machine      = utf8 "En Lege bruker Blodmaskinen for å diagnostisere pasienter",
    x_ray              = utf8 "En Lege bruker Röntgen for å diagnostisere pasienter",
    inflation          = utf8 "En Lege bruker Pumperommet for å behandle pasienter med Ballonghode",
    dna_fixer          = utf8 "En Lege bruker DNA-maskinen for å behandle pasienter med Utenomjordisk DNA",
    hair_restoration   = utf8 "En Lege bruker Hårklinikken for å behandle pasienter med Flintskalle",
    tongue_clinic      = utf8 "En Lege bruker Tungekutteren for å behandle pasienter med Lös tunge",
    fracture_clinic    = utf8 "En Sykepleier bruker Benbruddsklinikken for å reparere Benbrudd",
    training_room      = utf8 "Et klasserom med en Konsulent kan brukes til å lære opp andre Leger",
    electrolysis       = utf8 "En Lege bruker Elektrolyseklinikken for å behandle pasienter med Pelssyndrom",
    jelly_vat          = utf8 "En Lege bruker Gelétönnen for å behandle pasienter med Gelésyndrom",
    staffroom          = utf8 "Leger, Sykepleiere og Vaktmestre bruker personalrommet for å hvile og heve humöret",
    -- rehabilitation  = S[33][27], -- unused
    general_diag       = utf8 "En Lege bruker trallen for å stille grunnleggende diagnose på pasienter. Billig og ofte veldig effektivt",
    research_room      = utf8 "Leger med spesialisering innen Forskning kan forske frem nye medisiner og maskiner på Forskningsavdelingen",
    toilets            = utf8 "Bygg toaletter for å få pasientene til å stoppe å skitne til sykehuset!",
    decontamination    = utf8 "En Lege bruker Saneringsdusjen for å behandle pasienter med Alvorlig Stråling",
  },
  
  -- Objects
  objects = {
    -- NB: most objects do not have a tooltip because they're not (extra-)buyable
    desk                 = "Pult: en Lege kan bruke pulten til PC-en sin.",
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
    lecture_chair        = utf8 "Forelesningsstol: dine Legestudenter sitter her og tar notater, kjeder seg og rabler ivrig. Jo flere stoler du har, jo större kan klassen være.",
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

-- 32. Adviser
adviser = {
  
  -- Tutorial
  tutorial = {
    start_tutorial         = utf8 "Les Oppdragsbriefingen og klikk venstre museknapp for å starte innföring.",
    information_window         = "Hjelpeboksen forteller deg alt om den fine Allmennpraksisen du nettopp har bygd.",
    build_reception         = utf8 "Heisann. Först, trenger sykehuset ditt en Resepsjon. Velg en fra Inventarmenyen.",
    order_one_reception       = utf8 "Klikk en gang på den blinkende linjen med venstre museknapp for å kjöpe en Resepsjon.",
    accept_purchase         = utf8 "Venstreklikk på den blinkende linjen for å kjöpe den.",
    rotate_and_place_reception     = utf8 "Klikk med höyre museknapp for å rotere Resepsjonen, og venstreklikk for å plassere den i sykehuset.",
    reception_invalid_position     = utf8 "Resepsjonen er nå grå fordi det er en ugyldig plassering. Pröv å flytte eller rotere den.",
    hire_receptionist         = utf8 "Du trenger nå en Resepsjonist til å stå i resepsjonen og henvise dine pasienter.",
    select_receptionists       = utf8 "Venstreklikk på det blinkende ikonet for å se gjennom tilgjengelige Resepsjonister. Nummeret på ikonet viser antall som er tilgjengelig.",
    next_receptionist         = utf8 "Dette er den förste Resepsjonisten i listen. Venstreklikk på det blinkende ikonet for å se på neste person.",
    prev_receptionist         = utf8 "Venstreklikk på det blinkende ikonet for å se på forrige person.",
    choose_receptionist       = utf8 "Avgjör hvilken Resepsjonist som har gode evner og akseptable lönnskrav, og venstreklikk på det blinkende ikonet for å ansette henne.",
    place_receptionist         = utf8 "Flytt Resepsjonisten og plasser henne hvor som helst. Hun klarer å finne veien til resepsjonen selv.",
    receptionist_invalid_position   = utf8 "Du kan ikke plassere henne der.",
    window_in_invalid_position     = utf8 "Dette vinduet kan ikke være her. Pröv å plassere det en annen plass på veggen, er du snill.",
    choose_doctor           = utf8 "Se nöye gjennom evnene til hver enkelt Lege för du bestemmer deg for hvem du vil ansette.",
    click_and_drag_to_build       = utf8 "For å bygge en Allmennpraksis, må du först avgjöre hvor stor den skal være. Klikk og hold inne venstre museknapp for å justere rommets störrelse.",
    build_gps_office         = utf8 "For å starte å diagnostisere pasientene dine, må du ha en Allmennpraksis.",
    door_in_invalid_position     = utf8 "Oj, sann! Du prövde å plassere dören i en ugyldig posisjon. Pröv en annen plass på veggen av blåkopien.",
    confirm_room           = utf8 "Venstreklikk på det blinkende ikonet for å ferdigstille rommet ditt, eller klikk på X-en for å gå et trinn tilbake.",
    select_diagnosis_rooms       = utf8 "Venstreklikk på det blinkende ikonet for å se en liste over diagnoserom du kan bygge.",
    hire_doctor           = utf8 "Du trenger en Lege for å diagnostisere og behandle syke mennesker.",
    select_doctors           = utf8 "Venstreklikk på det blinkende ikonet for å se hvilke Leger som er tilgjengelig i arbeidsmarkedet.",
    place_windows           = utf8 "Plasser vinduer på samme måten som du plasserte dören. Du trenger ikke vinduer, men de ansatte setter veldig pris på det, og blir blidere når de har noe å se ut gjennom.",
    place_doctor           = utf8 "Plasser Legen hvor som helst i Sykehuset. Han vil spasere til Allmennpraksisen så snart noen trenger å diagnostiseres.",
    room_in_invalid_position     = utf8 "Oj! Denne blåkopien er ikke gyldig - det röde området indikerer hvor du har overlappet et annet rom eller sykehusets vegger.",
    doctor_in_invalid_position     = utf8 "Hei! Du kan ikke slippe Legen her.",
    place_objects           = utf8 "Höyreklikk for å rotere gjenstander, og venstreklikk for å plassere dem.",
    room_too_small           = utf8 "Denne blåkopien er röd fordi den er for liten. Strekk den ut for å gjöre den större.",
    click_gps_office         = utf8 "Venstreklikk på den blinkende linjen for å velge en Allmennpraksis.",
    
    room_too_small_and_invalid     = utf8 "Blåkopien er for liten og er ugyldig plassert. Kom igjen.",
    object_in_invalid_position     = utf8 "Denne gjenstanden er ugyldig plassert. Vær vennlig å plasser den et annet sted, eller roter den for å få den til å passe.",
    place_door             = utf8 "Flytt musen rundt om kring på blåkopiens vegger for å plassere dören der du vil ha den.",
    room_big_enough         = utf8 "Blåkopien er nå stor nok. Når du slipper museknappen, plasserer du den. Du kan allikevel fortsette å flytte den eller endre störrelse om du vil.",
    build_pharmacy           = utf8 "Gratulerer! Nå må du bygge et Apotek og ansette en Sykepleier for å ha et fungerende sykehus.",
  },
  
  -- Cheats
  cheats = {
    th_cheat = utf8 "Gratulerer du har låst opp juksekodene!",
    hairyitis_cheat = "Pelssyndom-kode aktivert!",
    hairyitis_off_cheat = "Pelssyndom-kode deaktivert.",
    roujin_on_cheat = "Roujins utfordring aktivert! Lykke til...",
    roujin_off_cheat = "Roujins utfordring deaktivert.",
    crazy_on_cheat = utf8 "Å nei! Alle Legene har blitt gale!",
    crazy_off_cheat = utf8 "Puh... Legene har fått tilbake forstanden.",
    bloaty_cheat = "Ballonghode-kode aktivert!",
    bloaty_off_cheat = "Ballonghode-kode deaktivert.",
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
    need_doctors       = utf8 "Du trenger flere Leger. Pröv å plassere dine beste Leger i rommene med lengst kö.",
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
    need_surgeons_ward_op   = utf8 "Du trenger to Kirurger og en Sykestue i tillegg til Operasjonssal for å gjöre kirurgiske inngrep.",
    need_surgeon_ward     = utf8 "Du trenger en Kirurg til og en Sykestue for å gjöre kirurgiske inngrep.",
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
    dont_kill_more_patients   = utf8 "Du har virkelig ikke råd til å drepe flere pasienter!",
    another_patient_killed   = utf8 "Å nei! Du har drept enda en pasient. Du har drept %d nå.",
    close_to_win_increase_value   = utf8 "Du er virkelig nær ved å vinne. Ök sykehusets verdi med %d.",
    financial_criteria_met   = utf8 "Du har tilfredsstilt de finansielle kriteriene for dette nivået. Hold banksaldoen din over %d, mens du passer på at sykehuset ditt drives effektivt.",
    hospital_value_enough   = utf8 "Hold verdien av ditt sykehus over %d og forsök å fölge med på de andre problemene for å vinne dette nivået.",
    another_patient_cured   = utf8 "Bra jobbet - enda en pasient kurert. Det blir den %d.",
    reputation_good_enough   = utf8 "Ok, omdömmet ditt er er godt nok for å vinne dette nivået. Hold det over %d og fiks eventuelle andre problemet for klare det.",
    cured_enough_patients   = utf8 "Du har kurert nok pasienter, men du trenger å få sykehuset ditt i bedre stand for å vinne dette nivået.",
    improve_reputation   = utf8 "Du må forbedre omdömmet ditt med %d for å ha en sjanse til å vinne dette nivået.",
  },
  
  -- Staff place advice
  staff_place_advice = {
    receptionists_only_at_desk     = utf8 "Resepsjonister kan kun jobbe i Resepsjoner.",
    only_psychiatrists         = utf8 "Leger kan bare jobbe i Psykiatri dersom de er kvalifiserte Psykiatere.",
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
    autopsy_discovered_rep_loss   = utf8 "Din Obduseringsautomat er blitt offentlig kjent. Forvent en negativ reaksjon fra allmennheten.",
    drug_fully_researched       = utf8 "Du har utforsket %s til 100%.",
    new_machine_researched       = utf8 "En ny %s er akkurat utviklet.",
    drug_improved           = utf8 "%s medisinen er forbedret av Forskningsavdelingen din.",
    new_available           = utf8 "En ny %s er tilgjengelig.",
    new_drug_researched       = utf8 "En ny medisin for å kurere %s er utviklet.",
  },
  
  -- Boiler issue
  boiler_issue = {
    minimum_heat   = utf8 "Der er du! Sentralfyren i kjelleren er gått i stykker. Ser ut som at personene på sykehuset ditt kommer til å fryse litt.",
    maximum_heat   = utf8 "Sentralfyren i kjelleren er löpt löpsk. Ovnene har hengt seg opp på maksimal varme. Folk kommer til å smelte! Plasser ut flere Brusautomater.",
    resolved     = utf8 "Gode nyheter. Sentralvarmen fungerer slik som den skal nå. Temperaturen skal nå være grei både for pasientene og personalet.",
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
    op_need_ward           = utf8 "Du må bygge en Sykestue for å overvåke pasienter som skal opereres.",
    reception_need_receptionist   = utf8 "Du må ansette en Resepsjonist for å ta imot pasientene.",
    psychiatry_need_psychiatrist   = utf8 "Du må ansette en Psykiater nå som du har bygget Psykiatri.",
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
      value     = utf8 "Sykehuset ditt må ha en verdi på over %d for at du skal kunne fullföre dette nivået.",
    },
    lose = {
      kill       = utf8 "Drep %d pasienter til for å tape dette nivået!",
    },
  },
  
  -- Warnings
  warnings = {
    charges_too_low       = utf8 "Du tar deg for lite betalt. Dette vil tiltrekke mange syke mennesker til sykehuset ditt, men du tjener mindre pr. pasient.",
    charges_too_high       = utf8 "Dine priser er for höye. Dette gir deg god profitt på kort sikt, men på lengre sikt vil de höye prisene skremme bort pasientene.",
    plants_thirsty         = utf8 "Du må huske på plantene dine. De er törste.",
    staff_overworked       = utf8 "Personalet ditt er meget overarbeidet. De blir ineffektive og gjör fatale feil når di er trötte.",
    queue_too_long_at_reception = utf8 "Du har for mange pasienter som venter ved Resepsjonen. Plasser ut flere Resepsjoner og ansett en Resepsjonist til.",
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
    nurses_tired         = utf8 "Sykepleierne dine er trötte. Gi dem hvile nå.",
    machine_severely_damaged   = utf8 "%s er veldig nær å bli totalskadet.",
    reception_bottleneck     = utf8 "Det er en flaskehals i Resepsjonen. Ansett en Resepsjonist til.",
    bankruptcy_imminent     = utf8 "Hallo! Du nærmer deg konkurs. Vær forsiktig!",
    receptionists_tired     = utf8 "Resepsjonistene dine er meget trötte. Gi dem hvile nå.",
    too_many_plants       = utf8 "Du har for mange planter. Dette er jo rene jungelen.",
    many_killed         = utf8 "Du har nå drept %d mennesker. Poenget er liksom å gjöre de friske, vet du.",
    need_staffroom         = utf8 "Bygg et Personalrom slik at dine ansatte kan slappe av.",
    staff_too_hot         = utf8 "Dine ansatte holder på å smelte bort. Skru ned temperaturen eller fjern noen ovner fra rommene deres.",
    patients_unhappy       = utf8 "Pasientene misliker sykehuset ditt. Du burde gjöre noe for å forbedre miljöet på sykehuset.",
    people_did_it_on_the_floor       = utf8 "Noen av pasientene dine klarte ikke å holde seg. Oppryddingen vil bli en stor jobb for noen.", -- Bruke ordet opprydning eller vasking?
    patients_very_thirsty       = utf8 "Pasientene dine er virkelig törste. Om du ikke setter opp noen Brusautomater snart, vil du snart se at alle går hjem for å hente cola.",
    machinery_very_damaged       = utf8 "Hastesak! Få en Vaktmester til å reparere maskinene dine öyeblikkelig! De kommer til å sprenge!",
    handymen_tired2       = utf8 "Vaktmestrene dine er helt utkjörte. Gi dem litt hvile med en gang.",
    desperate_need_for_watering       = utf8 "Du trenger sårt å ansette en Vaktmester for å stelle med plantene dine.",
    too_much_litter       = utf8 "Det er et söppelproblem. Flere Vaktmestere kan være svaret.",
    place_plants4       = utf8 "Få pasientene i bedre humör ved å sette ut litt flere planter rundt omkring.",
    change_priorities_to_plants       = utf8 "Du må endre prioriteringene for Vaktmestrene dine slik at de bruker mer tid på plantene.",
    finanical_trouble2       = utf8 "Du må få inn litt penger snart, ellers er du snart ute på söppeldynga. Du vil tape nivået om du mister %d til.",
    litter_everywhere       = utf8 "Det er söppel over alt. Sett noen Vaktmestere på saken.",
    nurses_tired2       = utf8 "Sykepleierne dine er veldig trötte. La dem hvile med en gang.",
    plants_dying       = utf8 "Plantene dine dör. De er desperate etter vannr. Få flere Vaktmestere til å jobbe med dette. Pasientene liker ikke döde planter.",
    reduce_staff_rest_threshold       = utf8 "Pröv å endre Personalets hvileterskel i Sykehuspolicy-vinduet, slik at Personalet hviler oftere. Det var bare en idé.",
    more_toilets       = utf8 "Du trenger flere Toaletter. Folk begynner å få præriehunder.", --"People are getting the turtle's head"
    hospital_is_rubbish       = utf8 "Folk sier åpenlyst at sykehuset ditt bare er söppel. För du vet ordet av det, så tar de med seg sykdommene sine til et annet sted.",
    pay_back_loan       = utf8 "Du har masse penger. Hvorfor har du ikke tenkt på å betale tilbake lånet?",
    financial_trouble3       = utf8 "Banksaldoen din ser bekymringsfull ut. Tenk på å skaffe mer penger. Du er %d unna fra en katastrofe.",
    build_toilet_now       = utf8 "Bygg et Toalett nå. Folk kan ikke holde seg lenger. Ikke glis - Dette er seriöst.",
    more_benches       = utf8 "Tenk på å plassere flere benker. Syke folk anser det som en fornærmelse å måtte stå oppreist.",
    many_epidemics       = utf8 "Det ser ut som du har mer enn en epidemi på samme tid. Dette kan bli en kjempekatastrofe, så du må handle raskt.",
    place_plants_to_keep_people       = utf8 "Folk stikker av. Å plassere noen planter kan kanskje overtale dem til å bli.",
    patients_thirsty2       = utf8 "Folk klager over at de er törste. Du burde plassere noen fler Brusmaskiner eller flytte de eksisterende nærmere dem.",
    people_freezing       = utf8 "Utrolig, i denne alderen av sentralfyring så klager noen av pasientene din over at det er iskaldt. Sett ut noen radiatorer for å varme dem opp, og skru opp temperaturen.",
    patients_very_cold       = utf8 "Pasientene er veldig kalde. Pröve å skru opp temperaturen eller å plassere flere radiatorer i sykehuset.",
    build_toilets       = utf8 "Bygg et Toalett med en gang, ellers vil du se noe virklig ubehagelig. Og forestill deg hva sykehuset ditt vil lukte da.",
    place_plants2       = utf8 "Folk går hjem. Litt flere planter ville kanskje holdt dem her lenger.",
    staff_tired       = utf8 "Dine ansatte er veldig slitne. Om du ikke lar dem få litt hvile i Personalrommet, så kan noen knekke av presset.",
    place_plants3       = utf8 "Pasientene din er utilfreds. Plasser litt flere planter for muntre dem opp.",
    staff_unhappy2       = utf8 "Personalet ditt er generelt ulykkelige. Snart vil de ha mer penger.",
    cash_low_consider_loan       = utf8 "Pengesituasjonen din er ganske dårlig. Har du tenkt på å ta opp et lån?",
    financial_trouble       = utf8 "Du er i en seriös finansiell krise. Få orden på ökonomien med en gang! Om du taper %d til, så har du kastet bort dette nivået!",
    doctors_tired2       = utf8 "Legene dine er utrolig slitne. De burde hvule umiddelbart.",
    patient_leaving       = utf8 "En pasient drar hjem. Grunnen til det? Ditt dårlig styrte, dårlig bemannet og dårlig utstyrt sykehus.",
    machinery_damaged2       = utf8 "Du må ansette en Vaktmester for å reparere maskinene dine snart.",
    patients_leaving       = utf8 "Pasientene forlater sykehuset. Forbedre sykehuset for de besökende ved å plassere planter, benker, brusmaskiner og så videre.",
    epidemic_getting_serious       = utf8 "Den smittsomme sykdommen begynner å bli alvorlig. Du må gjöre noe snart!",
    machinery_damaged       = utf8 "Reparer maskinene dine snart. Det er ikke lenge för de begynner å falle fra hverandre.",
    people_have_to_stand       = utf8 "Lidende mennesker må stå oppreist. Skaff flere sitteplasser nå.",
    build_staffroom       = utf8 "Bygg et Personalrom nå. Personalet ditt jobber for hardt og er på randen til kollaps. Kom igjen - se sammenhengen!",
    machinery_slightly_damaged       = utf8 "Sykehusmaskineriet ditt er lettere skadet. Ikke glem å få det vedlikeholdt ved en anledning.",
    patients_getting_hot       = utf8 "Pasientene er veldig varme. Pröv å skru ned temperaturen litt, eller til og med fjerne noen radiatorer.",
    machinery_deteriorating       = utf8 "Maskinene dine har nettopp begynt å bli dårligere på grunn av overforbruk. Hold et öye med dem.",
    litter_catastrophy       = utf8 "Söppelsituasjonen er bunnlös. Få et lag av Vaktmestere til å ta fatt i det nå!",
    staff_very_cold       = utf8 "Personalet klager over at det er kaldt. Skru opp temperaturen eller plasser flere radiatorer.",
    deal_with_epidemic_now       = utf8 "Om den epidemien ikke blir behandlet med en gang, så vil få tröbbel helt opp til örene. Få opp farten!",
    patients_really_thirsty       = utf8 "Pasientene er virkelig törste. Plasser flere brusmaskiner, eller flytt de eksisterende nærmere de störste köene.",
    some_litter       = utf8 "Vaktmestere kan bli kvitt söpla för den blir et alvorlig problem.",
    patients_annoyed       = utf8 "Folk er utrolig misfornöyd med måten du driver sykehuset ditt. Og jeg kan ikke si jeg klandrer dem. Ta deg sammen eller ta konsekvensene!",
    receptionists_tired2       = utf8 "Resepsjonistene din er veldig slitne. La dem hvile med en gang.",
    doctor_crazy_overwork = utf8 "Å nei! En av dine Doktorer har blitt gal på grunn av overarbeid. Han kan komme seg hvis du lar ham hvile umiddelbart.",
    no_desk = utf8 "Du burde bygge en resepsjon og ansette en Resepsjonist snart.",
    no_desk_1 = utf8  "Om du vil at pasienter skal komme til sykehuset ditt bör du ansette en Resepsjonsist og bygge en resepsjon der hun kan arbeide!",
    no_desk_2 = utf8 "Bra gjort! Dette må være en verdensrekord: nesten ett år uten å få noen pasienter! Om du vil fortsette som sjef for dette sykehuset bör du ansette en Resepsjonist og bygg en respsjon der hun kan arbede!",
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
    handyman_adjust         = utf8 "Du kan gjöre Vaktmestrene mer effektiv ved å justere deres prioriteringer.",
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
      psychiatric_symbol = utf8 "Leger med spesialisering innen Psykiatri gjenkjennes med symbolet: |",
      decrease_heating = utf8 "Folk på sykehuset ditt svetter. Skru ned sentralvarmen. Dette gjöres på Områdekartet.",
      surgeon_symbol = utf8 "Leger kan utföre kirurgiske inngrep om de har symbolet: {",
      first_emergency = utf8 "Akutte pasienter har et blinkende blått lys over hodet. Behandle dem i tide, ellers dör de.",
      first_epidemic = utf8 "Du har en epidemi på sykehuset ditt! Avgjör om du vil rydde opp, eller legge deg paddeflat.",
      taking_your_staff = utf8 "Noen pröver å stjele personalet ditt. Du må kjempe for å beholde de.",
      place_radiators = utf8 "Pasientene fryser - du kan plassere flere ovner ved å gå inn på oversikten med gjenstander.",
      epidemic_spreading = utf8 "Det er smittefare på sykehuset. Kurer infiserte pasienter för de forlater sykehuset.",
      research_symbol = "Forskere er leger med symbolet: }",
      machine_needs_repair = utf8 "Du har utstyr som trenger reparasjon. Finn utstyret - det ryker av det - og klikk på den. Klikk deretter på Vaktmestersymbolet.",
      increase_heating = utf8 "Folk fryser. Skru opp sentralvarmen på Områdekartet.",
      first_VIP = utf8 "Du er i ferd med å ta imot ditt förste VIP-besök. Sörg for at VIP-er ikke ser noe uhygienisk eller pasienter som henger med hodet.",
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
  quit                 = utf8 "Du har valgt å avslutte. Er du sikker på at du vil forlate spillet?",
  return_to_blueprint  = utf8 "Er du sikker på at du vil returnere til Blåkopi-modus?",
  replace_machine      = utf8 "Er du sikker på at du vil erstatte %s for $%d?", -- %s (machine name) %d (price)
  overwrite_save       = utf8 "Et spill er allerede lagret her. Er du sikker på at du vil overskrive det?",
  delete_room          = utf8 "Önsker du virkelig å fjerne dette rommet?",
  sack_staff           = utf8 "Er du sikker på at du vil si opp denne personen?",
  restart_level        = utf8 "Er du sikker på at du vil starte dette nivået på nytt?",
}

-- Bank manager
bank_manager = {
  hospital_value    = "Sykehusets verdi",
  balance           = "Din balanse",
  current_loan      = utf8 "Nåværende lån",
  interest_payment  = "Rentekostnader",
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

-- Progress Report window
progress_report = {
  quite_unhappy = utf8 "Folket ditt er i dårlig humör. ",
  header = "Progresjonsrapport",
  very_unhappy = utf8 "Folket ditt er i svært dårlig humör. ",
  more_drinks_machines = "Bygg flere Brusautomater. ",
  too_cold = utf8 "Det er alt for kaldt. Sett ut noen ovner. ",
  too_hot = utf8 "Du bör regulere sentralvarmen. Det er alt for varmt. ",
  percentage_pop = utf8 "% befolkning",
  win_criteria = utf8 "KRITERIER FOR Å VINNE",
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
    [2] = utf8 "Hallo igjen. Du tok ikke vår forrige utfordring, der vi tilba deg en alle tiders stilling på et nytt sykehus, og en ökt lönn på $%d. Vi mener, derimot, at du bör revurdere beslutningen din. Vi har den perfekte jobben for deg, skjönner du.//",
    [3] = utf8 "Tar du imot stillingen på sykehuset %s? Vær så snill?",
  },
  [9] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Du har nok en gang bevist at du er den beste innen helseadministrasjon. Ingen tvil! En slik betydningsfull prestasjon må belönnes, så vi önsker å tilby deg stillingen som Administrerende Direktör for Alle Sykehus. Dette er en ærefull stilling, og gir deg en lönn på hele $%d. Du får din egen Ticker-Tape parade, og folk kommer til å vise sin takknemlighet ovenfor deg, hvor enn du går.//",
    [3] = utf8 "Takk for alt du har gjort. Vi önsker deg en lang og trivelig pensjonstid.//",
    [4] = "",
  },
  [10] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Gratulerer! Du har driftet alle sykehus vi har gitt deg på en utmerket måte. En slik prestasjon kvalifiserer deg for friheten til å reise rundt i verden. Du blir belönnet med en pensjon på $%d, pluss en limousin, og alt vi ber om er at du reiser fra by til by, möter dine lidenskaplige fans, og promoterer sykehusets arbeid hvor enn du måtte befinne deg.//",
    [3] = utf8 "Vi er alle stolte av deg. Det er ikke en av oss som ikke er takknemlig for ditt harde arbeid som livredder.//",
    [4] = "",
  },
  [11] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Din karriere har vært eksemplarisk, og du er en stor inspirasjon for oss alle. Takk for at du har driftet så mange sykehus, og gjort det så bra i alle jobbene. Vi önsker å gi deg en livslang lönn på $%d, og alt vi ber deg om er å reise offisielt med kabriolet fra by til by, og fortelle folk hvordan du tjente så mye penger så fort.//",
    [3] = utf8 "Du er et prakteksempel for alle höyrepolitiske mennesker, og alle i verden, uten unntak, er dine kjæreste eiendeler.//",
    [4] = "",
  },
  [12] = {
    [1] = utf8 "Kjære %s//",
    [2] = utf8 "Din suksessrike karriere som den beste sykehusadministratoren siden Moses sin tid er ved veis ende. Men siden du har hatt så stor innvirkning på den koselige medisinverdenen, önsker departementet å tilby deg en lönn på $%d bare for å være til stede på våre vegne i åpne fester, sjösette skip og stille opp på show. Hele verden etterlyser deg og det ville vært god PR for oss alle!//",
    [3] = utf8 "Vær så snill å ta imot denne stillingen, det blir ikke hardt arbeid!//",
    [4] = "",
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
  health_minister = "Helseministeren",
  utf8 "Ordföreren i Greater Trumpton", -- the rest is better organized in an array.
  "Lawrence Nightingale",
  "Kong Bernard av Nederland",
  "Aung Sang Su Kyi, den Burmesisk Demokratiske Opposisjonslederen",
  "Sir Reginald Crumbly",
  "Billy Savile OBE",
  utf8 "Rådgiver Crawford Purves",
  "Rocket Ronnie Jepson",
  "En Fotballspiller i Eliteserien",
  "L. F. Probst, III",
}

-- Deseases
diseases = {
  general_practice       = { 
    name     = "Allmennpraksis", 
  },
  bloaty_head        = { 
    name     = "Ballonghode", 
    cause     = utf8 "Årsak - Pasienten har sniffet ost og drukket forurenset vann.", 
    symptoms   = utf8 "Symptomer - Den rammede er meget ukomfortabel.", 
    cure     = utf8 "Behandling - Man stikker hull på det oppsvulmede hodet, og pumper det opp igjen til korrekt PSI med en intelligent maskin.", 
  },
  hairyitis              = { 
    name     = "Pelssyndrom", 
    cause     = utf8 "Årsak - Fullmåne.", 
    symptoms   = utf8 "Symptomer - Ökt luktesans.", 
    cure    = utf8 "Behandling - En elektrosjokkmaskin fjerner håret og tetter igjen porene.", 
  },
  king_complex           = { 
    name     = "Rock'n'Roll syndrom", 
    cause     = utf8 "Årsak - Elivs' ånd tar over kontrollen over pasientens hode", 
    symptoms   = utf8 "Symptomer - Går med fargede lærsko, og spiser cheeseburgere", 
    cure     = utf8 "Behandling - En Psykiater forteller pasienten hvor tåpelig han eller hun ser ut", 
  },
  invisibility           = { 
    name     = "Usynlighet", 
    cause     = utf8 "Årsak - Bitt av en radioaktiv (og usynlig) maur", 
    symptoms   = utf8 "Symptomer - Pasienten lider ikke - tvert imot! De utnytter situasjonen, og lurer familie og venner trill rundt", 
    cure     = utf8 "Behandling - En fargerik kur fra apoteket gjör pasienten fullt synlig igjen", 
  },
  serious_radiation      = { 
    name     = utf8 "Alvorlig stråling", 
    cause     = utf8 "Årsak - Har forvekslet plutonium-isotoper med tyggegummi.", 
    symptoms   = utf8 "Symptomer - Pasienten föler seg meget ukomfortabel.", 
    cure     = utf8 "Behandling - Pasienten blir plassert i en saneringsdusj og renset fullstendig.", 
  },
  slack_tongue           = { 
    name     = utf8 "Lös tunge", 
    cause     = utf8 "Årsak - Kronisk overivrig i diskusjoner om såpeopera.", 
    symptoms   = "Symptomer - Tungen hever seg til det femdoble.", 
    cure     = "Behandling - Tungen blir plassert i en tungekutter. Hevelsen fjernes deretter hurtig, effektivt og smertefullt.",
  },
  alien_dna              = { 
    name     = "Utenomjordisk DNA", 
    cause     = utf8 "Årsak - Bitt av facehuggere utstyrt med intelligent utenomjordisk blod.", 
    symptoms   = utf8 "Symptomer - Er under gradvis forvandling til romvesen, og har et önske om å ta over våre byer.", 
    cure     = "Behandling - Alt DNA blir fjernet mekanisk, renset for utenomjordiske celler, og blir hurtig erstattet.",
  },
  fractured_bones        = { 
    name     = "Benbrudd",
    cause     = utf8 "Årsak - Fall fra store höyder mot betong.", 
    symptoms   = utf8 "Symptomer - Höye knaselyder og liten bevegelighet på utsatte steder.", 
    cure     = "Behandling - Gipsen blir fjernet ved hjelp av en laserstyrt gipsfjerner.", 
  },
  baldness               = { 
    name     = "Flintskalle", 
    cause     = utf8 "Årsak - Forteller lögner og dikter opp historier for å öke sin popularitet.", 
    symptoms   = "Symptomer - Forlegen pasient med skinnende skalle.", 
    cure     = utf8 "Behandling - Hår blir hurtig smeltet fast til pasientens hode med en smertefull hårmaskin.",
  },
  discrete_itching       = { 
    name     = "Skrapesyke", 
    cause     = utf8 "Årsak - Små insekter med skarpe tenner.", 
    symptoms   = utf8 "Symptomer - Pasienten klör intenst, og huden flasser.", 
    cure     = utf8 "Behandling - En Sykepleier gir pasienten en sirupaktig drikk som leger huden og hindrer videre klöe.",
  },
  jellyitis              = { 
    name     = utf8 "Gelésyndrom", 
    cause     = utf8 "Årsak - Gelatinrik diett og for mye mosjon.", 
    symptoms   = utf8 "Symptomer - Meget ustödig og faller mye.", 
    cure     = utf8 "Behandling - Pasienten blir presset ned i en gelétönne i et spesielt rom.",
  },
  sleeping_illness       = { 
    name     = utf8 "Sövnsyke", 
    cause     = utf8 "Forårsaket av overaktive sövnkjertler i munnens gane.", 
    symptoms   = utf8 "Symptomer - Sterkt önske om å sove, hvor og når som helst.", 
    cure     = "Behandling - En sterk dose stimulerende medisin blir delt ut av en Sykepleier.",
  },
  pregnancy              = { 
    name     = "Graviditet", 
    cause     = utf8 "Forårsaket av strömbrudd i urbane strök.", 
    symptoms   = utf8 "Symptomer - Lei av å spise med konstant ölmage.", 
    cure     = "Behandling - Spedbarnet blir fjernet med keisersnitt, blir deretter vasket og presentert for sin nye mor.",
  },   -- unused
  transparency           = { 
    name     = "Gjennomsiktighet", 
    cause     = utf8 "Årsak - Slikket folien på et gammelt yoghurtbeger.", 
    symptoms   = "Symptomer - Kroppen blir gjennomsiktig og ekkel.", 
    cure     = utf8 "Behandling - En kald og fargerik drikk fra apoteket gjör susen.",
  },
  uncommon_cold          = { 
    name     = utf8 "Forkjölelse",
    cause     = utf8 "Årsak - Små snörrpartikler i luften.", 
    symptoms   = "Symptomer - Rennende nese, hoste og misfarget slim fra lungene.", 
    cure     = utf8 "Behandling - En real slurk hostesaft fra apoteket vil gjöre susen.", 
  },
  broken_wind            = { 
    name     = "Forurensende gasser", 
    cause     = utf8 "Årsak - Har löpt på 3d-mölle rett etter middag.", 
    symptoms   = "Symptomer - Ubehag hos folk som befinner seg rett bak pasienten.", 
    cure     = utf8 "Behandling - En sterk blanding av spesielle vannatomer må svelges hurtig.",
  },
  spare_ribs             = { 
    name     = "Juleribbe", 
    cause     = utf8 "Årsak - Pasienten har sittet på kalde steingulv.", 
    symptoms   = utf8 "Symptomer - Ubehagelig fölelse i brystet.", 
    cure     = "Behandling - Ribben fjernes av to Kirurger, og leveres til pasienten i en doggybag.",
  },
  kidney_beans           = { 
    name     = "Kikkerter", 
    cause     = utf8 "Årsak - Pasienten har spist isbiter.", 
    symptoms   = utf8 "Symptomer - Smerte og hyppige turer til toalettet.", 
    cure     = utf8 "Behandling - To Kirurger fjerner de erteliknende parasittene, uten å beröre nyrene!",
  },
  broken_heart           = { 
    name     = "Knust hjerte",
    cause     = utf8 "Årsak - Noen er rikere, yngre og slankere enn pasienten.", 
    symptoms   = utf8 "Symptomer - Hysterisk gråtende. Blodsprengte fingertupper etter å ha revet opp feriebilder.", 
    cure     = "Behandling - To Kirurger spretter opp brystet og setter deretter hjertet forsiktig sammen, mens de holder pusten.", 
  },
  ruptured_nodules       = { 
    name     = utf8 "Knekte nötter", 
    cause     = utf8 "Årsak - Strikkhopp om vinteren.", 
    symptoms   = utf8 "Symptomer - Umulig å sitte behagelig.", 
    cure     = utf8 "Behandling - To kvalifiserte Kirurger må fjerne nöttene med stödige hender.",
  },
  tv_personalities       = { 
    name     = "Programledersyndrom", 
    cause     = utf8 "Årsak - TV-titting på dagtid.", 
    symptoms   = utf8 "Symptomer - Forestiller seg at han eller hun er programleder i frokost-tv, og elsker å introdusere kjökkenseansen.", 
    cure     = utf8 "Behandling - En Psykiater må overtale pasienten til å selge fjernsynet og heller kjöpe radio.",
  },
  infectious_laughter    = { 
    name     = "Smittsom latter", 
    cause     = utf8 "Årsak - Klassisk situasjonskomedie på TV.", 
    symptoms   = utf8 "Symptomer - Ler hjelpelöst hele tiden, og repeterer stadig dårlige poeng som absolutt ikke er morsomme.", 
    cure     = utf8 "Behandling - En kvalifisert Psykiater må minne pasienten på at dette faktisk er en alvorlig tilstand.",
  },
  corrugated_ankles      = { 
    name      = utf8 "Böyde ankler", 
    cause     = utf8 "Årsak - Busskjöring over fartsdempere.", 
    symptoms   = "Symptomer - Skoene passer ikke.", 
    cure     = utf8 "Behandling - En giftig blanding av urter og krydder må drikkes for å rette ut anklene.",
  },
  chronic_nosehair       = { 
    name     = utf8 "Kronisk nesehår", 
    cause     = utf8 "Årsak - Snöfter med forakt på folk med lavere inntekt.", 
    symptoms   = utf8 "Symptomer - Så mye nesehår at en grevling kunne bodd der.", 
    cure     = utf8 "Behandling - En ekkel hårfjernende drikk blir inntatt gjennom munnen. Fås på apoteket.",
  },
  third_degree_sideburns = { 
    name     = "Tredjegrads koteletter", 
    cause     = utf8 "Årsak - Lengter tilbake til 70-tallet.", 
    symptoms   = utf8 "Symptomer - Stort hår, tettsittende klær, langt skinnskjegg og glitter.", 
    cure     = utf8 "Behandling - Psykiatrisk personell må, ved hjelp av nåtidens teknikker, overbevise pasienten om at parykk er noe tull.",
  },
  fake_blood             = { 
    name     = "Teaterblod", 
    cause     = utf8 "Årsak - Pasienten er ofte utsatt for narrestreker.", 
    symptoms   = utf8 "Symptomer - Rödt blod som dunster ved kontakt med klær.", 
    cure     = utf8 "Behandling - Eneste måten å behandle dette på, er å få en Psykiater til å roe ned pasienten.",
  },
  gastric_ejections      = { 
    name     = utf8 "Krydrede oppstöt", 
    cause     = utf8 "Årsak - Sterkt krydret meksikansk eller indisk mat har skylden.", 
    symptoms   = "Symptomer - Gulper karrikylling og tacolefser.", 
    cure     = utf8 "Behandling - En Sykepleier gir pasienten en bindende indisk kumelk-blanding som forhindrer nye oppstöt.",
  },
  the_squits             = { 
    name     = utf8 "Lös mage", 
    cause     = utf8 "Årsak - Har spist pizzabiter som har falt bak komfyren.", 
    symptoms   = utf8 "Symptomer - Æsj! Tipper du vet symptomene.", 
    cure     = utf8 "Behandling - En klebrig blanding kjemikalier må drikkes for å stabilisere magen innvendig.",
  },
  iron_lungs             = { 
    name     = "Jernlunger", 
    cause     = utf8 "Årsak - Forurenset byluft blandet med kebabrester.", 
    symptoms   = utf8 "Symptomer - Kan puste flammer og bröle höyt under vann.", 
    cure     = "Behandling - To Kirurger mykner de solide lungene i operasjonssalen.",
  },
  sweaty_palms           = { 
    name     = utf8 "Håndsvette", 
    cause     = utf8 "Årsak - Er livredd jobbintervjuer.", 
    symptoms   = utf8 "Symptomer - Å håndhilse på pasienten er som å ta tak i en våt svamp.", 
    cure     = utf8 "Behandling - En Psykiater må snakke pasienten ut av denne oppdiktede lidelsen.",
  },
  heaped_piles           = { 
    name     = "Hemoroider", 
    cause     = utf8 "Årsak - Står i nærheten av drikkevannskjölere.", 
    symptoms   = utf8 "Symptomer - Pasienten föler at han eller hun sitter på en pose med stein.", 
    cure     = utf8 "Behandling - En behagelig, men meget syrlig drikk, lösner opp hemoroidene innenifra.",
  },
  gut_rot                = { 
    name     = utf8 "Mageråte", 
    cause     = utf8 "Årsak - Onkel Georgs miks av hostesaft og whisky.", 
    symptoms   = "Symptomer - Ingen hoste, men ingen magesekk heller.", 
    cure     = "Behandling - En Sykepleier skriver ut en rekke kjemikalier og gjenskaper veggen i magesekken.",
  },
  golf_stones            = { 
    name     = "Golfsteiner", 
    cause     = utf8 "Årsak - Utsatt for giftige gasser fra golfballer.", 
    symptoms   = utf8 "Symptomer - Forvirring og kraftig skamfölelse.", 
    cure     = "Behandling - Steinene fjernes kjapt og effektivt av to Kirurger.",
  },
  unexpected_swelling    = { 
    name     = "Uventet hevelse", 
    cause     = utf8 "Årsak - Hva som helst uventet.", 
    symptoms   = "Symptomer - Hevelse.", 
    cure     = utf8 "Behandling - Hevelsen må skjæres bort av to Kirurger.",
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
    location = "Det har skjedd en ulykke ved %s", 
    num_disease = "Det er %d mennesker med %s som trenger akutt behandling.",
    num_disease_singular = "Det er 1 person med %s som trenger akutt behandling.",
    cure_possible_drug_name_efficiency = utf8 "Du har det som trengs av nödvendig utstyr og ferdigheter, og du har medisinen de trenger. Det er %s og medisinen er %d prosent effektiv.", 
    cure_possible              = utf8 "Du har nödvendig utstyr og de ferdigheter som trengs for å ta deg av dette.", 
    cure_not_possible_build_and_employ = utf8 "Du vil måtte bygge  %s og ansette en %s",
    cure_not_possible_build            = utf8 "Du mangler %s for å håndtere dette",
    cure_not_possible_employ           = utf8 "Du mangler en %s for å kunne håndtere dette",
    cure_not_possible                  = utf8 "Du kan ikke behandle denne sykdommen for öyeblikket",
    bonus                              = utf8 "Om du klarer å håndtere dette nödstilfellet, vil du få en bonus på maksimalt %d. Om du feiler derimot, vil ryktet ditt få en kraftig smell.",
    
    locations = {      
      utf8 "A.Toms Våpenkjeller",
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
    saved_people   = "Du reddet %d personer av totalt %d.",
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
    
    disease_name             = utf8 "Dine Leger har oppdaget en svært smittsom form for %s.",
    declare_explanation_fine = utf8 "Om du offentliggjör epidemien, må du betale en bot på %d, ditt rykte får en smell, og samtlige pasienter blir vaksinert automatisk.",
    cover_up_explanation_1   = utf8 "Om du derimot forsöker å holde epidemien skjult, må du behandle samtlige infiserte pasienter för helsemyndighetene får rede på det.",
    cover_up_explanation_2   = utf8 "Om en Helseinspektör kommer på besök og finner ut at du pröver å skjule epidemien, kan han gå drastisk til verks.",
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
    rep_boost  = utf8 "Ditt rykte i nærområdet har fått en opptur.",
    rep_loss   = utf8 "Ditt rykte har fått seg en smell.",
    
    remarks = {
      super = {
        "For et flott sykehus. Neste gang jeg blir alvorlig syk vil jeg hit.",
        "Dette er hva jeg kaller et sykehus.",
        utf8 "Et supert sykehus. Og jeg vet hva jeg snakker om, for jeg har vært med på en del.",
      },
      good = {
        "For et velorganisert sykehus. Takk for at jeg fikk komme hit.",
        utf8 "Hmm. Ingen dårlig medisinsk institusjon dette, det skal være visst.",
        utf8 "Jeg likte ditt sjarmerende sykehus. Forresten, noen som blir med å spise indisk?",
      },
      mediocre = {
        utf8 "Vel, jeg har sett verre. Men du burde gjöre noen forbedringer.",
        utf8 "Å kjære min tid. Dette er ikke stedet å gå om du föler deg dårlig.",
        utf8 "Et helt alminnelig sykehus, for å være ærlig. Jeg hadde forventet meg noe mer.",
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
    situation = utf8 "Vi har brukt alle våre diagnosemetoder på denne pasienten, men vi vet fremdeles ikke sikkert hva som er galt.",
    what_to_do_question = utf8 "Hva skal vi gjöre med pasienten?",
    partial_diagnosis_percentage_name = "Det er %d prosent sannsynlighet for at vi vet hvilken type %s pasienten har.",
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
    [1] = utf8 "Siste advarsel - hold öye med omdömmet ditt - det er dette som tiltrekker pasienter til sykehuset ditt. ",
    [2] = utf8 "Om du ikke dreper for mange mennesker og samtidig holder pasientene noenlunde i godt humör, skal du ikke ha for store problemer med dette nivået!//",
    [3] = utf8 "Nå må du klare deg selv. Lykke til med det.",
  },
  level1 = {
    [1] = utf8 "Velkommen til ditt förste sykehus!//",
    [2] = utf8 "Få stedet opp og gå ved å plassere en Resepsjon, bygge en Allmennpraksis, og ansette en Resepsjonist og en Lege. ",
    [3] = utf8 "Vent så til det begynner å skje ting.",
    [4] = utf8 "Det er smart å bygge Psykiatri og ansette en Lege med fordypning innenfor psykiatri. ",
    [5] = utf8 "Et Apotek og en Sykepleier er essensielt for å kurere pasientene dine. ",
    [6] = utf8 "Se opp for mange tilfeller av Ballonghode - et Pumperom vil fort kunne være til stor hjelp. ",
    [7] = utf8 "Du må kurere 10 pasienter og sörge for at omdömmet ditt ikke blir mindre enn 200. ",
  },
  level9 = {
    [1] = utf8 "Etter å ha fylt opp Ministerens bankkonto og finansiert Ministerens nye limousin, kan du nå konsentrere deg om å lage et omsorgsfullt og velfungerende sykehus for de trengende. ",
    [2] = utf8 "Du må forvente å stöte på en rekke problemer her.",
    [3] = utf8 "Om du har nok av rom og flinke ansatte, skal du kunne ha dette under kontroll. ",
    [4] = utf8 "Sykehuset ditt må ha en verdi på $200,000, og du må ha $400,000 i banken. ",
    [5] = utf8 "Med noe mindre får du ikke fullfört dette nivået.",
  },
  level2 = {
    [1] = utf8 "Det er et större spekter av plager i dette området. ",
    [2] = utf8 "Bygg sykehuset for å behandle flere pasienter, og planlegg en egen Forskningsavdeling. ",
    [3] = utf8 "Husk å holde institusjonen ren, og streb etter så höyt omdömme som mulig - du vil måtte håndtere plager som Lös tunge, så du trenger en Tungeklinikk. ",
    [4] = utf8 "Du kan også bygge Kardiorom for å forbedre diagnostisering. ",
    [5] = utf8 "Begge disse rommene vil måtte forskes på för du kan bygge de. Du kan også utvide sykehustomten slik at du får mer plass å boltre deg på - Bruk Områdekartet til dette. ",
    [6] = utf8 "Streb etter et omdömme på 300 og en banksaldo på $10,000, samt 40 kurerte pasienter. ",
  },
  level7 = {
    [1] = utf8 "Her vil du være under nöye gransking fra Helsedepartementet, så sörg for at kontoene dine viser at du tjener en masse penger, og at omdömmet ditt er svært bra. ",
    [2] = utf8 "Vi har ikke råd til unödvendige dödsfall - det er dårlig for forretningene. ",
    [3] = utf8 "Sörg for at personalet er i tipp-topp form, og at du har alt utstyret du trenger. ",
    [4] = utf8 "Få et omdömme på 600, pluss $200,000 i banken.",
  },
  level5 = {
    [1] = utf8 "Dette blir et travelt sykehus, siden du må håndtere et bredt spekter av tilfeller. ",
    [2] = utf8 "Legene du kan ansette kommer rett fra skolen, så det kommer til å være avgjörende for deg å bygge et Klasserom og skolere dem til et akseptabelt nivå. ",
    [3] = utf8 "Du har kun tre Konsulenter til å lære opp de uerfarne medarbeiderne, så hold dem lykkelige slik at de ikke slutter. ",
    [4] = utf8 "Merk deg også at sykehusets fundament står på en grunn full av geologiske feil. ",
    [5] = utf8 "Faren for jordskjelv er alltid tilstedeværende. ",
    [6] = utf8 "De vil forårsake betydelig skade på maskiner, og forstyrre den jevne driften av sykehuset. ",
    [7] = utf8 "Få omdömmet ditt opp til 400, og ha $50,000 i banken for å lykkes. Du må også kurere 200 pasienter.",
  },
  level4 = {
    [1] = utf8 "Hold alle pasientene dine fornöyde, ta deg av dem så effektivt som mulig og hold dödsfall til et absolutt minimum. ",
    [2] = utf8 "Ditt omdömme står på spill, så sörg for at du får det så höyt som mulig. ",
    [3] = utf8 "Ikke bekymre deg for mye over penger - det vil komme etter som ditt vitale omdömme vokser. ",
    [4] = utf8 "Du vil kunne skolere Leger til å utvide sine evner. ",
    [5] = utf8 "Du kan komme til få pasienter som synes å være mer gjennomsiktig enn de fleste. ", --sjekk english.lua er det bra nok oversettelse?
    [6] = utf8 "Oppnå et omdömme på over 500.",
  },
  level14 = {
    [1] = utf8 "Det er nok en utfordring - det helt uventede overraskelsessykehuset. ",
    [2] = utf8 "Om du klarer å gjöre en suksess ut av dette, vil du bli vinneren over alle andre vinnere. ",
    [3] = utf8 "Ikke forvent at det skal være fort gjort, ettersom det er det töffeste oppdraget du noensinne vil få. ",
    [4] = "Lykke til!",
  },
  level15 = {
    [1] = utf8 "Ok, det var den grunnleggende teknikken i å sette et sykehus sammen.//",
    [2] = utf8 "Legene dine kommer til å trenge all den hjelpen de kan få til å diagnostisere noen av disse pasientene. Du kan hjelpe dem ved å ",
    [3] = utf8 "bygg et ny diagnoserom, for eksempel Generell Diagnose.",
  },
  level8 = {
    [1] = utf8 "Det er opp til deg å sette opp det mest effektive og kostnadseffektive sykehuset som mulig. ",
    [2] = utf8 "Menneskene rundt her er ganske velstående, så flå dem for så mye grunker du bare klarer. ",
    [3] = utf8 "Husk at det å kurere mennesker er veldig fint, men du trenger virkelig pengene det bringer. ",
    [4] = utf8 "Behandle disse syke personene med Pengeutsugeren. ",
    [5] = utf8 "Samle opp en pengehaug på $300,000 for å fullföre dette nivået.",
  },
  level13 = {
    [1] = utf8 "Din enestående dyktighet som sykehusadministrator har blitt oppdaget av Hemmelig Super-avdeling fra Superhemmelige Tjenester. ",
    [2] = utf8 "De har en spesiell bonus for deg; det er et rotteinfisert sykehus som trenger en effektiv Terminator. ",
    [3] = utf8 "Du må skyte så mange rotter som mulig för Vaktmesterne rydder opp all söpla. ",
    [4] = "Tror du at du klarer oppgaven?",
  },
  level16 = {
    [1] = utf8 "Når du har diagnostisert noen av pasientene må du bygge behandlingsrom og klinikker for å kurere dem - en god idé å begynne ",
    [2] = utf8 "med Apoteket. Du trenger også en Sykepleier for å utlevere ulike legemidler fra Apoteket.",
  },
  level6 = {
    [1] = utf8 "Bruk all din kunnskap til å sette opp et velsmurt og kompetent sykehus som gjör et sunt overskudd og kan håndtere alt som den sykelige offentligheten kan kaste på det. ",  --todo - godt nok oversatt?
    [2] = utf8 "Du bör være klar over at atmosfæren rundt her er kjent for å bære med seg bakterier og infeksjoner. ",
    [3] = utf8 "Med mindre du klarer å holde institusjonen din omhyggelig ren, kan du stå overfor en rekke epidemier blant pasientene. ",
    [4] = utf8 "Pass på at du skaffer deg $150,000, og at sykehuset er verdt over $140,000.",
  },
  level12 = {
    [1] = utf8 "Du har fått moderen av alle utfordringer nå. ",
    [2] = utf8 "Departementet er imponert over din suksess, og har skaffet toppjobben for deg; de vil at du skal bygge enda et storslagent sykehus, skaffe en stor haug med penger og få et bra utrolig rykte. ",
    [3] = utf8 "Det forventes at du kjöper opp alle områdene du klarer, kurerer alle sykdommer (og da mener vi alle) og vinner alle premiene. ",
    [4] = "Tror du at du klarer det?",
    [5] = utf8 "Tjen $650,000, kurer 750 pasienter og få et omdömme på 800 for å vinne dette nivået.",
  },
  level3 = {
    [1] = utf8 "Du setter opp et sykehus i et velstående område denne gangen. ",
    [2] = utf8 "Helsedepartementet er ute etter at du klarer å sikre en sunn profitt her. ",
    [3] = utf8 "Du må få et godt rykte til å begynne med, men når sykehuset går av seg selv, så konsentrer deg om å tjene så mye penger du klarer. ",
    [4] = utf8 "Det er også en sjanse for at nödssituasjoner oppstår. ",
    [5] = utf8 "Dette er når store mengder mennesker kommer på en gang med samme tilstand. ",
    [6] = utf8 "Kurerer du alle innen tidsfristen så får du et bedre rykte, og en stor xbonus. ",
    [7] = utf8 "Sykdommer som Rock'n'Roll-syndrom kan inntreffe og du bör budsjettere for en Operasjonssal med en Sykestue i nærheten. ",
    [8] = utf8 "Tjen opp $20,000 for å klare nivået.",
  },
  level10 = {
    [1] = utf8 "I tillegg til å få bukt med alle sykdommene som dukker opp i denne skogkanten, så vil Departementet at du bruker litt tid på å konsentrere deg om effektiviteten av legemidlene dine. ",
    [2] = utf8 "Det har kommet noen klager fra Ofsick, Helsedepartementets vakthund, så for at alt skal se bra ut du må sörge for at alle legemidler er svært effektive. ", --todo (bytte ut "Ofsick" med et norskt navn).
    [3] = utf8 "Kontroller også at sykehuset i tillegg er uklanderlig. Hold dödsfallene nede. ",
    [4] = utf8 "Som et hint, så kanskje du bör holde av litt plass til en Gelétönne. ",
    [5] = utf8 "Utvikle alle dine medisiner til minst 80 prosent effektivitet, få et omdömme på 650 og gjem unna $500,000 i banken for å vinne. ",
  },
  level11 = {
    [1] = utf8 "Du har fått muligheten til å bygge det ultimate innen sykehus. ",
    [2] = utf8 "Dette er et meget prestisjefylt område, og Departementet önsker å se det best mulige sykehuset. ",
    [3] = utf8 "Vi vil forvente at du gjör store penger, har et ypperlig og godt omdömme og dekker alle mulige hendelser. ",
    [4] = "Dette er en viktig jobb. ",
    [5] = utf8 "Du må være virkelig begavet for å gjennomföre det. ",
    [6] = utf8 "Merk også at det har vært observasjoner av UFO-er i området. Sörg for at personalet er forberedt på noen uventede gjester. ",
    [7] = utf8 "Sykehuset ditt må være verdt $240,000, du må ha $500,000 i banken og ditt omdömme må være på minst 700.",
  },
  level18 = {
  },
  demo = {
    [1] = "Velkommen til demonstrasjonssykehuset!",
    [2] = utf8 "Uheldigvis inneholder demoversjonen kun dette nivået (bortsett fra brukerdefinerte nivåer). Uansett så er det mer enn nok å gjöre her for å holde deg opptatt en stund!",
    [3] = utf8 "Du vil möte på forskjellige sykdommer som krever forskjellige rom for å kureres. Fra tid til annen kan nödstilfeller oppstå. Du må også forske frem nye rom ved hjelp av en forskningsavdeling.",
    [4] = utf8 "Målet ditt er å tjene $100,000, ha et sykehus som er verdt $70,000 og et omdömme på 700, samt kurert minst 75% av pasientene.",
    [5] = utf8 "Pass på at omdömmet ditt ikke faller under 300 og at du ikke dreper mer enn 40% av pasientene, for ellers vil du tape nivået.",
    [6] = "Lykke til!",
  },
}


-- Miscellangelous
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

-- Original credits (untranslated)
original_credits = {
  [1] = " ",
  [2] = " ",
  [3] = " ",
  [4] = " ",
  [5] = " ",
  [6] = " ",
  [7] = " ",
  [8] = " ",
  [9] = " ",
  [10] = " ",
  [11] = " ",
  [12] = ":Designed and Created by",
  [13] = ":Bullfrog Productions",
  [14] = " ",
  [15] = ":Pluto Development Team",
  [16] = ",",
  [17] = "Mark Webley",
  [18] = "Gary Carr",
  [19] = "Matt Chilton",
  [20] = "Matt Sullivan",
  [21] = "Jo Rider",
  [22] = "Rajan Tande",
  [23] = "Wayne Imlach",
  [24] = "Andy Bass",
  [25] = "Jon Rennie",
  [26] = "Adam Coglan",
  [27] = "Natalie White",
  [28] = " ",
  [29] = " ",
  [30] = " ",
  [31] = ":Programming",
  [32] = ",",
  [33] = "Mark Webley",
  [34] = "Matt Chilton",
  [35] = "Matt Sullivan",
  [36] = "Rajan Tande",
  [37] = " ",
  [38] = " ",
  [39] = " ",
  [40] = ":Art",
  [41] = ",",
  [42] = "Gary Carr",
  [43] = "Jo Rider",
  [44] = "Andy Bass",
  [45] = "Adam Coglan",
  [46] = " ",
  [47] = " ",
  [48] = " ",
  [49] = ":Additional Programming",
  [50] = ",",
  [51] = "Ben Deane",
  [52] = "Gary Morgan",
  [53] = "Jonty Barnes",
  [54] = " ",
  [55] = " ",
  [56] = " ",
  [57] = ":Additional Art",
  [58] = ",",
  [59] = "Eoin Rogan",
  [60] = "George Svarovsky",
  [61] = "Saurev Sarkar",
  [62] = "Jason Brown",
  [63] = "John Kershaw",
  [64] = "Dee Lee",
  [65] = " ",
  [66] = " ",
  [67] = " ",
  [68] = ":Intro Sequence",
  [69] = ",",
  [70] = "Stuart Black",
  [71] = " ",
  [72] = " ",
  [73] = " ",
  [74] = ":Music and Sound Effects",
  [75] = ",",
  [76] = "Russell Shaw",
  [77] = "Adrian Moore",
  [78] = " ",
  [79] = " ",
  [80] = " ",
  [81] = ":Additional Music",
  [82] = ",",
  [83] = "Jeremy Longley",
  [84] = "Andy Wood",
  [85] = " ",
  [86] = " ",
  [87] = " ",
  [88] = ":Announcer Voiceover",
  [89] = ",",
  [90] = "Rebecca Green",
  [91] = " ",
  [92] = " ",
  [93] = " ",
  [94] = ":Level Design",
  [95] = ",",
  [96] = "Wayne Imlach",
  [97] = "Natalie White",
  [98] = "Steven Jarrett",
  [99] = "Shin Kanaoya",
  [100] = " ",
  [101] = " ",
  [102] = " ",
  [103] = ":Scripting",
  [104] = ",",
  [105] = "James Leach",
  [106] = "Sean Masterson",
  [107] = "Neil Cook",
  [108] = " ",
  [109] = " ",
  [110] = " ",
  [111] = ":R&D",
  [112] = " ",
  [113] = ":Graphics Engine",
  [114] = ",",
  [115] = "Andy Cakebread",
  [116] = "Richard Reed",
  [117] = " ",
  [118] = " ",
  [119] = " ",
  [120] = ":R&D Support",
  [121] = ",",
  [122] = "Glenn Corpes",
  [123] = "Martin Bell",
  [124] = "Ian Shaw",
  [125] = "Jan Svarovsky",
  [126] = " ",
  [127] = " ",
  [128] = " ",
  [129] = ":Library and Tools",
  [130] = " ",
  [131] = "Dos and Win 95 Library",
  [132] = ",",
  [133] = "Mark Huntley",
  [134] = "Alex Peters",
  [135] = "Rik Heywood",
  [136] = " ",
  [137] = " ",
  [138] = " ",
  [139] = ":Network Library",
  [140] = ",",
  [141] = "Ian Shippen",
  [142] = "Mark Lamport",
  [143] = " ",
  [144] = " ",
  [145] = " ",
  [146] = ":Sound Library",
  [147] = ",",
  [148] = "Russell Shaw",
  [149] = "Tony Cox",
  [150] = " ",
  [151] = " ",
  [152] = " ",
  [153] = ":Installer Programming",
  [154] = ",",
  [155] = "Andy Nuttall",
  [156] = "Tony Cox",
  [157] = "Andy Cakebread",
  [158] = " ",
  [159] = " ",
  [160] = " ",
  [161] = ":Moral Support",
  [162] = ",",
  [163] = "Peter Molyneux",
  [164] = " ",
  [165] = " ",
  [166] = " ",
  [167] = ":Testing Manager",
  [168] = ",",
  [169] = "Andy Robson",
  [170] = " ",
  [171] = " ",
  [172] = " ",
  [173] = ":Lead Testers",
  [174] = ",",
  [175] = "Wayne Imlach",
  [176] = "Jon Rennie",
  [177] = " ",
  [178] = " ",
  [179] = " ",
  [180] = ":Play Testers",
  [181] = ",",
  [182] = "Jeff Brutus",
  [183] = "Wayne Frost",
  [184] = "Steven Lawrie",
  [185] = "Tristan Paramor",
  [186] = "Nathan Smethurst",
  [187] = " ",
  [188] = "Ryan Corkery",
  [189] = "Simon Doherty",
  [190] = "James Dormer",
  [191] = "Martin Gregory",
  [192] = "Ben Lawley",
  [193] = "Joel Lewis",
  [194] = "David Lowe",
  [195] = "Robert Monczak",
  [196] = "Dominic Mortoza",
  [197] = "Karl O'Keeffe",
  [198] = "Michael Singletary",
  [199] = "Andrew Skipper",
  [200] = "Stuart Stephen",
  [201] = "David Wallington",
  [202] = " ",
  [203] = "And all our other Work Experience Play Testers",
  [204] = " ",
  [205] = " ",
  [206] = " ",
  [207] = ":Technical Support",
  [208] = ",",
  [209] = "Kevin Donkin",
  [210] = "Mike Burnham",
  [211] = "Simon Handby",
  [212] = " ",
  [213] = " ",
  [214] = " ",
  [215] = ":Marketing",
  [216] = ",",
  [217] = "Pete Murphy",
  [218] = "Sean Ratcliffe",
  [219] = " ",
  [220] = " ",
  [221] = " ",
  [222] = ":With thanks to:",
  [223] = ",",
  [224] = "Tamara Burke",
  [225] = "Annabel Roose",
  [226] = "Chris Morgan",
  [227] = "Pete Larsen",
  [228] = " ",
  [229] = " ",
  [230] = " ",
  [231] = ":PR",
  [232] = ",",
  [233] = "Cathy Campos",
  [234] = " ",
  [235] = " ",
  [236] = " ",
  [237] = ":Documentation",
  [238] = ",",
  [239] = "Mark Casey",
  [240] = "Richard Johnston",
  [241] = "James Lenoel",
  [242] = "Jon Rennie",
  [243] = " ",
  [244] = " ",
  [245] = " ",
  [246] = ":Documentation & Packaging Design",
  [247] = ",",
  [248] = "Caroline Arthur",
  [249] = "James Nolan",
  [250] = " ",
  [251] = " ",
  [252] = " ",
  [253] = ":Localisation Project Manager",
  [254] = ",",
  [255] = "Carol Aggett",
  [256] = " ",
  [257] = " ",
  [258] = " ",
  [259] = ":Localisation",
  [260] = ",",
  [261] = "Sandra Picaper",
  [262] = "Sonia 'Sam' Yazmadjian",
  [263] = " ",
  [264] = "Bettina Klos",
  [265] = "Alexa Kortsch",
  [266] = "Bianca Normann",
  [267] = " ",
  [268] = "C.T.O. S.p.A. Zola Predosa (BO)",
  [269] = "Gian Maria Battistini",
  [270] = "Maria Ziino",
  [271] = "Gabriele Vegetti",
  [272] = " ",
  [273] = "Elena Ruiz de Velasco",
  [274] = "Julio Valladares",
  [275] = "Ricardo Martínez",
  [276] = " ",
  [277] = "Kia Collin",
  [278] = "CBG Consult",
  [279] = "Ulf Thor",
  [280] = " ",
  [281] = " ",
  [282] = " ",
  [283] = ":Production",
  [284] = ",",
  [285] = "Rachel Holman",
  [286] = " ",
  [287] = " ",
  [288] = " ",
  [289] = ":Producer",
  [290] = ",",
  [291] = "Mark Webley",
  [292] = " ",
  [293] = " ",
  [294] = " ",
  [295] = ":Associate Producer",
  [296] = ",",
  [297] = "Andy Nuttall",
  [298] = " ",
  [299] = " ",
  [300] = " ",
  [301] = ":Operations",
  [302] = ",",
  [303] = "Steve Fitton",
  [304] = " ",
  [305] = " ",
  [306] = " ",
  [307] = ":Company Administration",
  [308] = ",",
  [309] = "Audrey Adams",
  [310] = "Annette Dabb",
  [311] = "Emma Gibbs",
  [312] = "Lucia Gobbo",
  [313] = "Jo Goodwin",
  [314] = "Sian Jones",
  [315] = "Kathy McEntee",
  [316] = "Louise Ratcliffe",
  [317] = " ",
  [318] = " ",
  [319] = " ",
  [320] = ":Company Management",
  [321] = ",",
  [322] = "Les Edgar",
  [323] = "Peter Molyneux",
  [324] = "David Byrne",
  [325] = " ",
  [326] = " ",
  [327] = ":All at Bullfrog Productions",
  [328] = " ",
  [329] = " ",
  [330] = " ",
  [331] = ":Special Thanks to",
  [332] = ",",
  [333] = "Everyone at Frimley Park Hospital",
  [334] = " ",
  [335] = ":Especially",
  [336] = ",",
  [337] = "Beverley Cannell",
  [338] = "Doug Carlisle",
  [339] = " ",
  [340] = " ",
  [341] = " ",
  [342] = ":Keep On Thinking",
  [343] = " ",
  [344] = " ",
  [345] = " ",
  [346] = " ",
  [347] = " ",
  [348] = " ",
  [349] = " ",
  [350] = " ",
  [351] = " ",
  [352] = " ",
  [353] = " ",
  [354] = " ",
  [355] = " ",
  [356] = " ",
  [357] = " ",
  [358] = " ",
  [359] = " ",
  [360] = " ",
  [361] = ".",
}
