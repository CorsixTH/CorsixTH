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
--Font("unicode") --todo: Add unicode/freefont
Language("Norsk", "Norwegian", "nb", "nob")
Inherit("english")
Encoding(utf8)


-- 2. Faxes
fax = {
  choices = {
    return_to_main_menu = "Gå tilbake til hovedmenyen",
    accept_new_level = "Fortsett til neste nivå",
    decline_new_level = "Fortsett å spille litt til",
  },
}
letter = {
  dear_player = "Kjære %s",
  custom_level_completed = "Bra gjort! Du har fullfört alle utfordringene på dette brukerdefinerte brettet.!",
  return_to_main_menu = "Vil du gå tilbake til hovedmenyen eller fortsette å spille?",
}

install = {
  title = "--------------------------------- CorsixTH Setup ---------------------------------",
  exit = "Avslutt",
  th_directory = "CorsixTH trenger en kopi av datafilene fra et ekte Theme Hospital spill (eller demo) for å kjöre. Vennligst velg plasseringen til originalspillet nedenfor.",
  ok = "Ok",
  cancel = "Avbryt",
}

-- 3. Objects
object = {
  litter               = "Söppel",
}

tooltip.fax.close = "Lukk dette vinduet uten å slette meldingen"
tooltip.message.button = "Venstreklikk for å lese faksen"
tooltip.message.button_dismiss = "Venstreklikk for å åpne faksen, höyreklikk for å ignorere den"

-- 4. Menu
menu_options = {
  lock_windows = "  LÅS VINDUER  ",
  edge_scrolling = "  KANTSCROLLING  ",
  settings = "  INNSTILLINGER  ",
  adviser_disabled = "  RÅDGIVER  ",
  warmth_colors = "  VARMEFARGER", --Todo: Open for suggestions for a better word for it (warmth colours).
}

menu_options_game_speed.pause   = "  PAUSE  "

-- The demo does not contain this string
menu_file.restart = "  RESTART  "

menu_debug = {
  jump_to_level                 = "  GÅ TIL NIVÅ  ",
  transparent_walls             = "  GJENNOMSIKTIGE VEGGER  ",
  limit_camera                  = "  BEGRENS KAMERA  ",
  disable_salary_raise          = "  DEAKTIVER LÖNNSÖKNINGER  ",
  make_debug_patient            = "  LAG TESTPASIENT  ",
  cheats                        = "  (F11) JUKSEKODER  ",
  make_debug_fax                = "  LAG DEBUG FAKS  ",
  dump_strings                  = "  DUMP SPRÅKSTRENGER  ",
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
  parcel                        = "  TOMT  ",
}

-- 5. Adviser
adviser = {
  room_forbidden_non_reachable_parts = "Ved å plassere et rom her vil noen områder på sykehuset bli utilgjengelig.",
  praise = {
    plants_are_well = "Det er fint. Du tar godt vare på plantene dine. Storartet.",
    few_have_to_stand = "Nesten ingen trenger å stå i Sykehuset ditt. Pasientene dine vil være glade for det.",
    plenty_of_benches = "Det er masse sitteplasser, så det er ikke noe problem.",
    plants_thriving = "Veldig bra. Plantene dine blomstrer. De ser fantastiske ut. Fortsett slik, så vinner du kanskje en trofé for dem."
  },
}

-- 6. Dynamic info
dynamic_info.patient.actions.no_gp_available   = "Venter på at du skal bygge Allmennpraksis"
dynamic_info.staff.actions.heading_for       = "På vei til %s"
dynamic_info.staff.actions.fired = "Sparket"

-- 7. Tooltip
tooltip.objects.litter     = "Söppel: Slengt på gulvet av en pasient, fordi vedkommende ikke fant en söppelbötte å kaste det i."

-- Misc
misc.not_yet_implemented   = "(ikke implementert enda)"
misc.no_heliport       = "Enten er ingen sykdommer utforsket enda, eller så er det ingen heliport ved dette sykehuset."

-- Main menu
main_menu = {
  new_game     = "Ny karriere",
  custom_level   = "Valgfritt brett",
  load_game   = "Last inn",
  options     = "Innstillinger",
  version = "Versjon: ",
  savegame_version = "Lagringsversjon: ", --todo: en bedre oversettelse eller omskriving?
  exit       = "Avslutt",
}

tooltip.main_menu = {
  new_game     = "Start et nytt spill fra begynnelsen",
  custom_level   = "Bygg sykehuset ditt på et valgfritt område",
  load_game   = "Last inn et tidligere spill",
  options     = "Endre diverse innstillinger",
  exit       = "Nei, nei, vær så snill å ikke stikk!",
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
  free_build = "Bygg fritt",
}

tooltip.custom_game_window = {
  start_game_with_name = "Last nivå %s",
  free_build = "Huk av denne boksen om du vil spille uten penger og uten bestemte forutsetninger for vinne eller tape", --todo: finne en bedre oversettelse eller omskrive
}
save_game_window = {
  caption = "Lagre spill",
  new_save_game = "Nytt spill",
}
tooltip.save_game_window = {
  save_game = "Overskriv spill %s",
  new_save_game = "Skriv navn på nytt spill",
}
menu_list_window = {
  back = "Tilbake",
  name = "Navn",
  save_date = "Endret",
}
tooltip.menu_list_window = {
  back = "Lukk dette vinduet",
  name = "Klikk her for å sortere listen etter navn",
  save_date = "Klikk her for å sortere listen etter siste endringer",
}
options_window = {
  fullscreen = "Fullskjerm",
  width = "Bredde",
  height = "Höyde",
  change_resolution = "Endre opplösning",
  back = "Tilbake",
  browse = "Bla gjennom...",
  cancel = "Avbryt",
  new_th_directory = "Her kan du spesifisere en annen installasjonsmappe for Theme Hospital. Så fort du velger en ny mappe vil spillet starte på nytt.",  --kalle det "corsixth" isteden for "theme hospital"?
  custom_resolution = "Egendefinert...",
  option_on = "På",
  option_off = "Av",
  caption = "Innstillinger",
  language = "Språk",
  apply = "Bruk",
  data_location = "Data-beliggenhet",
  font_location = "Font-beliggenhet",
  resolution = "Opplösning",
  folder = "Mapper",
  audio = "Global lyd",
  customise = "Tilpass",
}
tooltip.options_window = {
  fullscreen_button = "Klikk for å gå i fullskjermmodus",
  width = "Skriv inn önsket skjermbredde",
  height = "Skriv inn önsket skjermhöyde",
  change_resolution = "Endre opplösningen til dimensjonene du har angitt til venstre.",
  language = "Velg %s som språk",
  back = "Lukk vinduet med innstillinger",
  original_path = "Valgt mappe for Theme Hospital installasjonen",
  browse = "Bla gjennom mappene for å finne et annet sted for Theme Hospital-installasjonen. %1%",
  fullscreen = "Om spillet skal kjöre i fullskjerm eller vindusmodus",
  cancel = "Returner uten å endre opplösning",
  font_location = "Beliggenhet av en font-fil som klarer å vise Unicode-bokstaver som brukes i det valgte språket. Om dette ikke er spesifisert, så vil ikke ha mulighet til å velge språk som krever andre bokstaver enn i originalspillet. For eksempel: Russisk eller Kinesisk",
  apply = "Bruk den innskrevne opplösningen",
  browse_font = "Se etter en annen font-fil (nåværende beliggenhet: %1%)",
  data_location = "Beliggenheten av den originale Theme Hospital installasjonen, som trengs for å kjöre CorsixTH",
  language_dropdown_item = "Velg %s som språk",
  no_font_specified = "Ingen beliggenhet spesifisert!",
  select_language = "Velg språk",
  select_resolution = "Velg en ny opplösning",
  resolution = "Opplösningen spillet skal kjöres i.",
  audio_button = "Slå av eller på all lyd",
  folder_button = "Mappeinnstillinger",
  audio_toggle = "Slå av eller på",
  customise_button = "¨Flere innstillinger", --todo: mer beskrivelse? var "More settings you can change to customise your game play experience"
}

folders_window = {
  screenshots_location = "Velg banen du vil bruke for skjermdumper",
  music_label = "MP3", --todo: annet ordvalg? "MP3's"
  back = "Tilbake",
  savegames_label = "Lagrede spill", --todo: annet ordvalg? "saves"
  caption = "Mappebane", --todo: annet ordvalg? "folder locations"
  savegames_location = "Velg banen du vil bruke for lagrede spill",
  font_label = "Font",
  new_th_location = "Her kan du spesifisere en ny bane for Theme Hospital. Spillet startes på nytt når du velger en ny bane.",
  screenshots_label = "Skjermdumper",
  music_location = "Velg banen du vil bruke for musikk",
  data_label = "TH-data", --todo: annet ordvalg? "TH Data"
}

tooltip.folders_window = { --todo: skrive mer konsekvent på "se etter", "velg" osv.
  browse_font = "Se etter en annen font-fil ( nåværende beliggenhet: %1% )",
  screenshots_location = "Skjermdumper er normalt lagret i en mappe sammen med konfigurasjonsfila. Om du önsker kan du plassere den et annet sted.",
  browse_music = "Se etter en annen lokasjon for musikk ( nåværende beliggenhet: %1% ) ",
  music_location = "Velg en lokasjon for mp3-musikk. Mappen må være laget på forhånd.",
  data_location = "Banen til den originale Theme Hospital-installasjonen, som du trenger for å spille CorsixTH",
  browse_data = "Se etter en annen lokasjon for Theme Hospital-installasjonen ( nåværende beliggenhet: %1%)",
  savegames_location = "Normalt er de lagrede spillene lagret i en mappe sammen med konfigurasjonsfila. Om du önsker kan du plassere den et annet sted.",
  back = "Lukk denne menyen og gå tilbake",
  browse_saves = "Se etter en annen lokasjon for dine lagrede spill  ( nåværende beliggenhet: %1% ) ",
  browse = "Se etter mappelokasjon",
  browse_screenshots = "Se etter en annen lokasjon for skjermdumper  ( nåværende beliggenhet: %1% ) ",
  not_specified = "Ingen mappe er valgt enda!",
  font_location = "Lokasjon for en font som kan vise Unicode-bokstaver som er nödvendig for ditt språk. Om denne ikke velges så er bokstavtyåene begrenset til de som er i Theme Hospital.",
  reset_to_default = "Tilbakestill mappen til standard lokasjon",
  default = "Standard lokasjon",
  no_font_specified = "Ingen font-fil er valgt enda!",
}


update_window = {
  current_version = "Gjeldende versjon:",
  ignore = "Hopp over og gå til hovedmenyen",
  new_version = "Ny versjon:",
  caption = "Oppdatering tilgjengelig!",
  download = "Gå til nedlastingsside",
}

tooltip.update_window = {
  download = "Gå til nedlastingssiden for den seneste versjonen av CorsixTH",
  ignore = "Ignorer oppdateringen denne gangen. Du vil få en ny beskjed neste gang du starter CorsixTH",
}

font_location_window = {
  caption = "Velg font (%1%)",
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
  task = "Liste over oppdrag - Klikk på oppdrag for å se lokasjonen",
  close = "Lukk ekspedisjonsvinduet",
}

cheats_window = {
  close = "Lukk",
  caption = "Juksekoder",
  warning = "Advarsel: Du vil ikke få noen bonuspoeng på slutten av nivået om du bruker juksekoder!",

  cheated = {
    no = "Juksekoder benyttet: Nei",
    yes = "Juksekoder benyttet: Ja",
  },

  cheats = {
    end_month = "Slutten av måneden",
    emergency = "Lag nödstilfelle",
    win_level = "Vinn nivå",
    create_patient = "Lag pasient",
    vip = "Lag VIP",
    money = "Penger",
    lose_level = "Tap nivå",
    all_research = "All forskning",
    end_year = "Slutten av året",
    earthquake = "Lag jordskjelv",
  },
}

tooltip.cheats_window = {
  close = "Lukk juksekodevinduet",
  cheats = {
  end_month = "Gå til slutten av denne måneden.",
  emergency = "Lag en nödssituasjon.",
  win_level = "Vinn dette nivået.",
  create_patient = "Lag en pasient på enden av kartet.",
  vip = "Lag en VIP.",
  money = "Sett 10,000 i bankkontoen din.",
  lose_level = "Tap dette nivået.",
  all_research = "Fullförer all forskning.",
  end_year = "Gå til slutten av dette året.",
  earthquake = "Forårsaker et jordskjelv.",
  },
}

new_game_window = {
  easy = "Turnuslege (Lett)",
  medium = "Lege (Medium)",
  hard = "Konsulent (Vanskelig)",
  tutorial = "Innföring",
  cancel = "Avbryt",
  option_on = "På",
  option_off = "Av",
  difficulty = "Vanskelighetsgrad",
  caption = "Karriere",
  player_name = "Spillernavn",
  start = "Start",
}

customise_window = {
  movies = "Global videostyring",
  option_on = "På",
  option_off = "Av",
  back = "Tilbake",
  paused = "Bygging i pause",
  intro = "Spill introvideo",
  volume = "Hurtigtast volumsenking",
  caption = "Egendefinerte innstillinger",
  fractured_bones = "Benbrudd",
  average_contents = "Gjennomsnittlig rominnhold",
  aliens = "Utenomjordiske pasienter",
}

tooltip.customise_window = { --todo kanskje en opprensking her. få det mer konsekvent.
intro_button = "Klikk for å slå av eller på",
movies = "Slår av alle videoer i spillet",
aliens = "På grunn av manglende standardanimasjoner ble pasienter med utenomjordisk DNA satt til å kun komme gjennom nödstilfeller. For å la pasienter med denne sykdommen komme til sykehuset på vanlig måte, så må du slå denne av.",
volume_button = "Klikk for å endre hurtigtast. Benyttes hvis volumsenkings-knappen på tastaturet åpner en meny i spillet.",
paused = " I Theme Hospital ville spilleren kun få lov til å bruke toppmenyen om spillet var satt til pause. Dette er standard i CorsixTH også, men ved å slå denne på, så er alle bevegelser lov",
average_contents_button = "Lar deg få de mest brukte gjenstandene (gjennomsnittlig) inn i rombyggeren automatisk.",
back = "Gå tilbake",
movies_button = "Slå av eller på filmsnutter i spillet",
paused_button = "Tillat bevegelser når spillet er satt til pause",
intro = "Slå av eller på introfilmen. Den andre filminnstillingen må også være på for å spille av introfilmen hver ganger du starter spillet",
volume = "Om en fysisk volum ned-knapp åpner Medisinboka i spillet, så kan du slå på denne for å endre hurtigtasten til Shift+C",
fractured_bones_button = "Slå denne innstillingen på eller av",
fractured_bones = "På grunn av mangelfulle animasjoner har vi gjort stilt standardoppsettet til å slå av kvinnelige benbrudd. For å tillate dette, slå denne av",
aliens_button = "Slå denne innstillingen på eller av",
average_contents = "Om du önsker at spillet skal huske hvilke objekter du vanligvis kjöper til hver rom (gjennomsnittlig), så bör du slå på denne",
}

tooltip.new_game_window = {
  easy = "Om du ikke har erfaring med simulatorspill er dette tingen for deg",
  medium = "Om du er usikker på hva du skal velge, så er dette mellomtingen",
  hard = "Om du er komfortabel med slike spill og önsker utfordring, bör du velge dette.",
  tutorial = "Om du önsker litt hjelp for å komme i gang må du merke av denne boksen.",
  cancel = "Hmm... Det var ikke meningen å starte et nytt spill!",
  difficulty = "Velg vanskelighetsgrad du vil spille på",
  start = "Start spillet med de valgte innstillingene",
  player_name = "Skriv inn hva du vil hete i spillet",
}

lua_console = {
  execute_code = "Kjör",
  close = "Lukk",
}

tooltip.lua_console = {
  textbox = "Skriv Lua-kode du vil kjöre her",
  execute_code = "Kjör koden",
  close = "Lukk konsollen",
}

errors = {
  dialog_missing_graphics   = "Beklager, datafilene i demoen tillater ikke denne dialogen.",
  save_prefix = "Feil under lagring av spill: ",
  load_prefix = "Feil under lasting av spill: ",
  load_quick_save = "Spillet kunne ikke laste inn sist hurtiglagring, siden den ikke eksisterer. Vi har ikke tenkt til å lage en for deg!",
  map_file_missing = "Kunne ikke finne kartfilen %s for dette nivået!",
  minimum_screen_size = "Vennligst sett opplösningen til minst 640x480.",
  maximum_screen_size = "Vennligst velg en skjermopplösning ikke större enn 3000x2000.",
  unavailable_screen_size = "Skjermopplösningen du valgte er ikke tilgjengelig i fullskjermmodus.",
  alien_dna = "Merk: Det er ingen originale animasjoner for utenomjordiske pasienter som sitter, åpner eller banker på dörer osv. Utenomjordiske vil bare komme på besök om det er slått på i levelfila", --todo: bedre beskrivelse? levelfila? var "NOTE: There are no animations for Alien patients for sitting down, opening or knocking on doors etc. So, like with Theme Hospital to do these things they will appear to change to normal looking and then change back.  Patients with Alien DNA will only appear if they are set to in the level file"
  fractured_bones = "Merk: De originale animasjonene for kvinnelige personer med benbrudd er ikke perfekte",
}

confirmation = {
  needs_restart = "Å forandre denne innstillingen krever en omstart av CorsixTH. Spill som ikke er lagret vil gå tapt. Er du sikker på at du vil endre innstillingen?",
  abort_edit_room = "Du holder på å bygge eller endre et rom. Om alle obligatoriske gjenstander er plassert ut, ferdigstilles rommet. Om ikke, slettes rommet. Fortsette?",
}

information = {
  custom_game = "Velkommen til CorsixTH. Kos deg med dette egenutviklede kartet!",
  no_custom_game_in_demo = "Unnskyld, men i demoversjonen kan du ikke spille egenutviklede kart.",
  cannot_restart = "Dette spillet ble dessverre lagret för restartfunksjonen ble implementert.",
  very_old_save = "Det har vært mange oppdateringer siden du startet på dette nivået. For å være sikker på at alle funksjoner virker riktig, vennligst vurder å starte nivået på nytt.",
  cheat_not_possible = "Juksekoder kan ikke brukes på dette nivået. Du klarer ikke engang å jukse!",
  level_lost = {
    "Kjipt! Du klarte ikke brettet. Bedre lykke neste gang!",
    "Grunnen til at du tapte:",
    reputation = "Omdömmet ditt gikk under %d.",
    balance = "Banksaldoen din (minus lån) falt under %d.",
    percentage_killed = "Du drepte mer enn %d prosent av pasientene.", --bruke %-tegn?
    cheat = "Dette var ditt eget valg, eller trykket du bare på feil knapp? Du klarer ikke engang å jukse skikkelig. Det var ikke så morsomt likevel?",
  },
}
tooltip.information = {
  close = "Lukk informasjonsdialogen",
}
-- Tips
totd_window = {
  tips = {
    "Ethvert sykehus trenger en Resepsjon og en Allmennpraksis for å fungere. Etter det avhenger det av hvilke pasienter som besöker sykehuset. Apotek er som regel en god start.",
    "Maskiner som f.eks. Pumpen i Pumperommet trenger vedlikehold. Ansett en Vaktmester eller to for å vedlikeholde maskinene, ellers risikerer du å skade ansatte og pasienter.",
    "Etter en stund blir personalet ditt trött. Sörg for å bygge et Personalrom så de kan hvile seg.",
    "Plasser radiatorer nok til å holde pasientene og personalet varme, ellers blir de fort misfornöyd. Bruk kartet for å lokalisere områder på sykehuset ditt som trenger mer varme.",
    "En Lege sine evner påvirker hvor langt tid han bruker på å stille diagnose, samt kvaliteten på diagnosen. Plasser en flink Lege i Allmennpraksisen, da trenger du færre diagnoserom.",
    "Turnusleger og Doktorer kan utvikle sine evner ved å bli undervist av en Konsulent i Klasserommet. Om Konsulenten har spesielle kvalifikasjoner (Kirurgi, Psykiatri eller Forskning) vil han også lære sine elever dette.",
    "Har du prövd å slå inn det europeiske nödnummeret (112) på faksen? Sörg for at lyden er på!",
    "Du kan forandre noen innstillinger som opplösning og språk i innstillinger-vinduet som du finner på hovedmenyen eller på menyen inne i spillet.",
    "Hvert nivå har en rekke utfordringer som må fullföres för du kan gå videre til neste nivå. Sjekk statusen på utfordringene for nivået i Statusvinduet.",
    "Om du vil endre eller fjerne et rom, kan du gjöre det med å klikke på Endre Rom knappen på panelet i bunnen av skjermen.",
    "Du kan alltids finne fort ut hvilke pasienter som venter på å slippe inn i de ulike rommene, ved å flytte musepekeren over rommet.",
    "Klikk på dören til et rom for å se köen. Du kan gjöre nyttige finjusteringer her, som å organisere köen og sende pasienter til andre lignende rom.",
    "Irritert personale vil spörre om lönnspålegg jevnlig. Sörg for at dine ansatte jobber i komfortable omgivelser for å hindre at det skjer.",
    "Pasientene svetter av spenning når de venter på behandling, og gjerne enda mer om du fyrer opp varmen. Plasser noen Brusautomater i strategiske punkter på sykehuset for å tjene noen ekstra lapper.",
    "Du kan avbryte diagnose-prosessen ganske tidlig og gjette på riktig behandling, dersom du allerede har truffet på tilfeller av sykdommen. Vær oppmerksom på at dette öker sjangsen for feilbehandling. Du vil vel ikke avlive pasientene dine, vel?",
    "Nödtilfeller kan gjöre deg rik, så sant du har kapasitet til å behandle pasientene i tide.",
    "Har du valgt norsk språk, men ser likevel engelsk tekst rundt omkring i spillet? Hjelp oss å oversette resten av spillet til norsk!",
    "CorsixTH-teamet er ute etter forsterkninger! Er du interessert i å programmere, oversette, eller kanskje lage grafikk til CorsixTH? Kontakt oss gjennom Forum, Nyhetsbrev eller IRC (corsix-th på freenode).",
    "Om du finner feil eller mangler, vær snill å rapportere det gjennom vår feilmeldingstjeneste: th-issues.corsix.org",
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
  definite_quit = "Du kan ikke gjöre noe for å beholde meg lenger. Jeg er ferdig her!",
  regular = {
    "Jeg er helt utslitt. Jeg trenger en god pause, pluss en lönnsökning på %d om du ikke vil se meg gå rundt å sutre i korridorene.", -- %d (rise)
    "Jeg er veldig trött. Jeg trenger hvile og en lönnsökning på %d, totalt %d. Fiks det nå, din tyrann!", -- %d (rise) %d (new total)
    "Kom igjen. Jeg jobber som en hund her. Gi meg en bonus på %d og jeg blir på sykehuset ditt.", -- %d (rise)
    "Jeg er så deppa. Jeg krever en lönnsökning på %d, som blir totalt %d, ellers er jeg ferdig her.", -- %d (rise) %d (new total)
    "Foreldrene mine sa at medisinyrket ville gi meg mye penger. Så gi meg en lönnsökning på %d, ellers blir jeg spillutvikler istedenfor.", -- %d (rise)
    "Nå er jeg sint. Gi meg en anstendig lönn. Jeg tror en ökning på %d skal gjöre susen.", -- %d (rise)
  },
  poached = "Jeg er blitt tilbudt %d av %s. Om ikke du gir meg det samme, så stikker jeg.", -- %d (new total) %s (competitor)
}

-- Staff descriptions
staff_descriptions = {
  good = {
    [1] = "Veldig rask og flittig arbeider. ",
    [2] = "Veldig pliktoppfyllende. Meget omsorgsfull. ",
    [3] = "Er meget allsidig. ",
    [4] = "Vennlig og alltid i godt humör. ",
    [5] = "Ekstremt utholden. Jobber dag og natt. ",
    [6] = "Utrolig höflig og har gode manerer. ",
    [7] = "Utrolig talentfull og dyktig. ",
    [8] = "Er meget opptatt av å prestere på jobben. ",
    [9] = "Er en perfeksjonist som aldri gir opp. ",
    [10] = "Hjelper alltid mennesker med et smil. ",
    [11] = "Sjarmerende, höflig og hjelpsom. ",
    [12] = "Godt motivert og dedikert til jobben. ",
    [13] = "Snill av natur og meget hardt arbeidende. ",
    [14] = "Lojal og vennlig. ",
    [15] = "Omtenksom og til å stole på i akutte situasjoner. ",
  },
  misc = {
    [1] = "Spiller golf. ",
    [2] = "Dykker etter kamskjell. ",
    [3] = "Lager isskulpturer. ",
    [4] = "Drikker vin. ",
    [5] = "Kjörer rally. ",
    [6] = "Bedriver strikkhopping på fritiden. ",
    [7] = "Samler på ölbrikker. ",
    [8] = "Liker å stage-dive. ",
    [9] = "Morer seg med fjert-surfing. ",
    [10] = "Liker å utvide elver. ",
    [11] = "Destillerer whisky. ",
    [12] = "Gjör-det-selv ekspert. ",
    [13] = "Liker franske kunstfilmer. ",
    [14] = "Spiller mye Theme Park. ",
    [15] = "Har sertifikat klasse C. ",
    [16] = "Deltar i motorsykkelrace. ",
    [17] = "Spiller klassisk fiolin og cello. ",
    [18] = "Entusiastisk tog-vraker. ",
    [19] = "Hundeelsker. ",
    [20] = "Hörer på radio. ",
    [21] = "Bader ofte. ",
    [22] = "Instruktör i bambusfletting. ",
    [23] = "Lager såpeholdere av grönnsaker. ",
    [24] = "Deltids minerydder. ",
    [25] = "Quizvert. ",
    [26] = "Samler på splinter fra 2.verdenskrig. ",
    [27] = "Liker å ommöblere. ",
    [28] = "Hörer på rave og trip-hop musikk. ",
    [29] = "Dreper insekter med deodorantspray. ",
    [30] = "Piper ut dårlige standupartiser. ",
    [31] = "Gjör innkjöp for sykehusrådet. ",
    [32] = "Hemmelighetsfull gartner. ",
    [33] = "Smugler falske klokker. ",
    [34] = "Vokalist i et rockeband. ",
    [35] = "Forguder tv-titting på dagtid. ",
    [36] = "Fisker etter örret. ",
    [37] = "Lurer turister på museum. ",
  },
  bad = {
    [1] = "Langsom og masete. ",
    [2] = "Lat og lite motivert. ",
    [3] = "Dårlig trent og ubrukelig. ",
    [4] = "Dum og slitsom. Er en reserve. ",
    [5] = "Lav utholdenhet. Har en dårlig holdning. ",
    [6] = "Döv som et papir. Lukter kål. ",
    [7] = "Skitner til jobben. Tar lite ansvar. ",
    [8] = "Konsentrasjonsvansker og lett distrahert. ",
    [9] = "Stresset og gjör mye feil. ",
    [10] = "Lett antennelig. Sitter inne med mye hat. ",
    [11] = "Uforsiktig og uheldig. ",
    [12] = "Bryr seg ikke om jobben. Inaktiv. ",
    [13] = "Dumdristig og bryr seg lite. ",
    [14] = "Slu, utspekulert og baksnakker andre. ",
    [15] = "Arrogant og ovenpå. ",
  },
}

-- Staff list
staff_list = {
  morale       = "MORAL",
  tiredness    = "TRETTHET",
  skill        = "FERDIGHETER",
  total_wages  = "TOTAL LÖNN",
}

-- Objects
object = {
  desk                  = "Kontorpult",
  cabinet               = "Arkivskap",
  door                  = "Dör",
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
  litter_bomb           = "Söppelbombe",
  couch                 = "Sofa",
  sofa                  = "Sofa",
  crash_trolley         = "Tralle",
  tv                    = "TV",
  ultrascanner          = "Ultraskanner",
  dna_fixer             = "DNA-fikser",
  cast_remover          = "Gipsfjerner",
  hair_restorer         = "Hårrenoverer",
  slicer                = "Tungekutter",
  x_ray                 = "Röntgen",
  radiation_shield      = "Strålingsvern",
  x_ray_viewer          = "Röntgenfremviser",
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
  radiator              = "Radiator",
  plant                 = "Plante",
  electrolyser          = "Elektrolysator",
  jelly_moulder         = "Gelétönne",
  gates_of_hell         = "Helvetesporten",
  bed3                  = "Seng", -- unused duplicate
  bin                   = "Söppelbötte",
  toilet                = "Toalett",
  swing_door1           = "Svingdör",
  swing_door2           = "Svingdör",
  shower                = "Saneringsdusj",
  auto_autopsy          = "Obdksjonsautomat",
  bookcase              = "Bokhylle",
  video_game            = "Videospill",
  entrance_left         = "Inngang venstre dör",
  entrance_right        = "Inngang höyre dör",
  skeleton              = "Skjelett",
  comfortable_chair     = "Komfortabel stol",
}

-- Place objects window
place_objects_window = {
  drag_blueprint                = "Juster blåkopien til du er fornöyd med störrelsen",
  place_door                    = "Velg hvor dören skal være",
  place_windows                 = "Lag noen vinduer om du vil. Bekreft når du er ferdig",
  place_objects                 = "Plasser gjenstandene. Bekreft når du er fornöyd",
  confirm_or_buy_objects        = "Du kan ferdigstille rommet, evt. fortsette å kjöpe eller flytte gjenstander",
  pick_up_object                = "Klikk på gjenstander for å plukke de opp, eller gjör et annet valg fra boksen",
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
  wages      = "Lönninger",
  balance    = "Balanse",
  visitors   = "Besökende",
  cures      = "Kurerte",
  deaths     = "Dödsfall",
  reputation = "Omdömme",

  time_spans = {
    "1 år",
    "12 år",
    "48 år",
  }
}

-- Transactions
transactions = {
  --null               = S[8][ 1], -- not needed
  wages                = "Lönninger",
  hire_staff           = "Ansett personale",
  buy_object           = "Kjöp inv.",
  build_room           = "Bygg rom",
  cure                 = "Kur",
  buy_land             = "Kjöp område",
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
  bank_loan            = "Banklån",
  loan_repayment       = "Bankinnskudd",
  loan_interest        = "Lånerente",
  research_bonus       = "Forskningsbonus",
  drug_cost            = "Medisinkostnader",
  overdraft            = "Strafferente",
  severance            = "Oppsigelseskostnader",
  general_bonus        = "Bonus Generell",
  sell_object          = "Salg inventar",
  personal_bonus       = "Bonusutbetaling Personale",
  emergency_bonus      = "Bonusutbetaling Nödstilfeller",
  vaccination          = "Vaksinering",
  epidemy_coverup_fine = "Opprydningskostnader epidemiutbrudd",
  compensation         = "Statlig erstatning",
  vip_award            = "Pengepremier VIP",
  epidemy_fine         = "Epidemiböter",
  eoy_bonus_penalty    = "Årsbonus/böter",
  eoy_trophy_bonus     = "Årets trofé bonus",
  machine_replacement  = "Utskiftning av maskiner",
}


-- Level names
level_names = {
  "Giftigby",
  "Soveby",
  "Storestad",
  "Frimpton-på-Sjöen",
  "Lettåker",
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
  area         = "Tomt område",
  price        = "Tomt pris",
}


-- Rooms short
-- NB: includes some special "rooms"
-- reception, destroyed room and "corridor objects"
rooms_short = {
  reception         = "Resepsjon",
  destroyed         = "Ödelagt",
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
  x_ray             = "Röntgen",
  inflation         = "Pumperom",
  dna_fixer         = "DNA-klinikk",
  hair_restoration  = "Hårklinikk",
  tongue_clinic     = "Tungeklinikk",
  fracture_clinic   = "Benbruddsklinikk",
  training_room     = "Klasserom",
  electrolysis      = "Elektrolyseklinikk",
  jelly_vat         = "Gelétönne",
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
  emergency         = "Nödstilfelle",
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
  x_ray             = "Röntgenrom",
  inflation         = "Pumperom",
  dna_fixer         = "DNA-klinikk",
  hair_restoration  = "Hårklinikk",
  tongue_clinic     = "Tungeklinikk",
  fracture_clinic   = "Benbruddsklinikk",
  training_room     = "Klasserom",
  electrolysis      = "Elektrolyseklinikk",
  jelly_vat         = "Gelétönnerom",
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
    [2] = "Ultraskanneren er virtuelt i toppklassen innenfor diagnoseutstyr. Den koster mye, men det lönner seg om du vil ha superb diagnostisering på ditt sykehus.//",
    [3] = "Ultraskanneren kan kun håndteres av ".. staff_class.doctor .."r. Den krever også vedlikehold. ",
  },
  gp = {
    [1] = "Allmennpraksis//",
    [2] = "Dette er det fundamentale diagnoserommet på ditt sykehus. Nye pasienter blir sendt hit for å finne ut hva som feiler dem. Videre blir de sendt enten til dypere diagnostisering eller til et rom hvor de kan få behandling for sine plager. Du trenger sannsynligvis flere Allmennpraksiser om det oppstår lange köer. Jo större rommet er og jo mer utstyr du plasserer i rommet, desto bedre presterer Legen. Dette gjelder også for alle andre rom.//",
    [3] = "Allmennpraksisen kan kun håndteres av Leger. ",
  },
  fracture_clinic = {
    [1] = "Benbruddsklinikk//",
    [2] = "Pasienter som uheldigvis har Benbrudd vil bli behandlet her. Gipsfjerneren bruker en kraftig industrilaser for å kutte vekk gipsen, og forårsaker bare litt smerte for pasienten.//",
    [3] = "Benbruddsklinikken kan kun håndteres av Sykepleiere. Den krever også vedlikehold. ",
  },
  tv_room = {
    [1] = "TV ROOM NOT USED",
  },
  inflation = {
    [1] = "Pumperom//",
    [2] = "Pasienter med sitt smertefulle, men dog humoristiske Ballonghode, må behandles på Pumperommet. Her blir hodet stukket hull på, trykket forsvinner, og en Lege pumper hodet opp til riktig trykknivå.//",
    [3] = "Pumperommet kan kun håndteres av Leger. Regelmessig vedlikehold er også viktig. ",
  },
  jelly_vat = {
    [1] = "Gelétönne//",
    [2] = "Pasienter med den snodige sykdommen gelésyndrom må skjelve seg fram til gelétönnerommet, for så å bli plassert i gelétönnen. Dette vil kurere dem på en måte som ikke er helt begripelig for det medisinske faget.//",
    [3] = "Gelétönnen kan kun håndteres av Leger. Det kreves også vedlikehold. ",
  },
  scanner = {
    [1] = "Skanner//",
    [2] = "Pasienter får veldig nöyaktig diagnostisert sin sykdom ved bruk av den sofistikerte Skanneren. Deretter går de til Allmennpraksisen og snakker med en Lege for videre behandling.//",
    [3] = "Skanneren kan kun håndteres av Leger. Det kreves også vedlikehold. ",
  },
  blood_machine = {
    [1] = "Blodmaskin//",
    [2] = "Blodmaskinen er et diagnoseverktöy som sjekker alle cellene i pasientens blod for å finne ut hva som feiler dem.//",
    [3] = "Blodmaskinen kan kun håndteres av Leger. Det kreves også vedlikehold. ",
  },
  pharmacy = {
    [1] = "Apotek//",
    [2] = "Pasienter som har blitt diagnostisert og trenger behandling av et medikament må besöke Apoteket for å få medisinen sin. Ettersom fler og fler medisinkurer er forsket på og blir tilgjengelige, blir dette rommet stadig travlere. Du önsker kanskje å bygge et nytt Apotek senere.//",
    [3] = "Apoteket kan kun håndteres av Sykepleiere. ",
  },
  cardiogram = {
    [1] = "Kardiorom//",
    [2] = "Pasienter blir undersökt og diagnostisert her, för de går tilbake til Allmennpraksisen for å få utpekt en kur.//",
    [3] = "Kardiorommet kan kun håndteres av Leger. Det kreves også vedlikehold. ",
  },
  ward = {
    [1] = "Sykestue//",
    [2] = "Pasientene blir lagt inn her for observasjon av en Sykepleier mens de diagnostiseres. De forblir her til de er klare for å legges under kniven på Operasjonssalen.//",
    [3] = "Sengeavdelingen kan kun håndteres av Sykepleiere. ",
  },
  psych = {
    [1] = "Psykiatri//",
    [2] = "Pasienter diagnostisert med psykiske lidelser må gå til Psykiatrien for å få rådgivning. Psykiatrene kan kjöre diagnose for å finne ut hva slags type sykdom pasientene lider av, og hvis mental opprinnelse, så behandle dem ved å benytte den trygge sofaen.//",
    [3] = "Psykiatrien kan kun håndteres av kvalifisert Psykiater. ",
  },
  staff_room = {
    [1] = "Personalrom//",
    [2] = "De ansatte blir slitne etter hvert som de utförer pliktene sine. De trenger dette rommet for å slappe av og heve humöret. Om de ansatte er slitne, så blir de tregere, krever mer lönn og vil til slutt si opp. De gjör også flere feilgrep. Å bygge et Personalrom med masse aktiviteter for dem er vel anvendte penger. Pass på at det er plass til flere ansatte på en gang. ",
  },
  operating_theatre = {
    [1] = "Operasjonssal//",
    [2] = "Denne viktige installasjonen er der en rekke forhold blir behandlet. Operasjonssalen må være av en god störrelse, og må fylles med riktig utstyr. Det er en viktig del av sykehuset.//",
    [3] = "Operasjonssalen kan kun håndteres av to Kvalifiserte Kirurger. ",
  },
  training = {
    [1] = "Klasserom//",
    [2] = "Turnuslegene og Doktorene dine kan få, verdifulle, ekstra kvalifikasjoner ved å studere i dette rommet. En Konsulent med Kirurgi-, Forsker- eller Psykiatri-fordypning vil lære bort dette til de Legene som sitter i rommet. Leger som allerede har disse ferdighetene vil bli enda flinkere mens de er her.//",
    [3] = "Klasserommet kan kun håndteres av en Konsulent. ",
  },
  dna_fixer = {
    [1] = "DNA-klinikk//",
    [2] = "Pasienter som har befattet seg med romvesener fra en annen verden må få DNA-et sitt byttet ut i dette rommet. DNA-fikseren er en veldig kompleks maskin, og det ville være fornuftig å holde et brannslukningsapparat i nærheten av den, bare i tilfelle.//",
    [3] = "DNA-fikseren kan kun håndteres av en kvalifisert Forsker. Den behöver periodisk vedlikehold av en Vaktmester. ",
  },
  research = {
    [1] = "Forskningsavdeling//",
    [2] = "Nye medikamenter og kurer blir funnet opp og forbedret i Forskningsavdelingen. Det er en vital del av sykehuset ditt, og vil gjöre underverker for kureringsstatistikken din.//",
    [3] = "Forskningsavdelingen kan kun håndteres av en kvalifisert Forsker. ",
  },
  hair_restoration = {
    [1] = "Hårklinikk//",
    [2] = "Pasienter som lider av ekstreme tilfeller av Flintskallethet må henvende seg til Hårrenoveringsmaskinen i denne klinikken. En Lege vil operere maskinen, og den vil sette avleggere i pasientens hode som raskt blir til nytt hår.//",
    [3] = "Hårklinikken kan kun håndteres av Leger. Det kreves også periodisk vedlikehold. ",
  },
  general_diag = {
    [1] = "Generell Diagnose//",
    [2] = "Pasienter som trenger videre diagnose blir sendt hit for undersökelse. Om Allmennpraksisen ikke finner ut hva som feiler dem, så vil Generell Diagnose ofte finne det ut. Herfra vil de bli sendt tilbake til Allmennpraksisen for analyse av resultatet.//",
    [3] = "Generell Diagnose kan kun håndteres av Leger. ",
  },
  electrolysis = {
    [1] = "Elektrolyseklinikk//",
    [2] = "Pasienter med Pelssyndrom blir sendt hit, hvor en spesialmaskin brenner av håret og forsegler porene elektrisk med en sammensetning som ikke er ulik fugemasse.//",
    [3] = "Elektrolyseklinikken kan kun håndteres av Leger. Den behöver vedlikehold av en Vaktmester. ",
  },
  slack_tongue = {
    [1] = "Tungeklinikk//",
    [2] = "Pasienter som blir diagnostisert med Lös tunge fra Allmennpraksisen, vil bli sendt til denne klinikken for behandling. Legen bruker en höyteknologisk maskin som forlenger tungen og kutter den av, dermed bringes pasienten tilbake til normal, god helse.//",
    [3] = "Tungekutteren kan kun håndteres av Leger. Det kreves også vedlikehold nok så ofte. ",
  },
  toilets = {
    [1] = "Toalett//",
    [2] = "Pasienter som föler at naturen kaller, må gå og lette på trykket i dine behagelige toalettfasiliteter. Du kan bygge ekstra toalettbåser og vasker om du forventer mange besökende. I noen tilfeller bör du kanskje vurdere å bygge flere Toaletter andre steder i sykehuset. ",
  },
  no_room = {
    [1] = "",
  },
  x_ray = {
    [1] = "Röntgenrom//",
    [2] = "Röntgenmaskinen fotograferer pasientenes innside ved bruk av spesiell stråling for å gi en god indikasjon på hva som er galt med dem.//",
    [3] = "Röntgenmaskinen kan kun håndteres av Leger. Det kreves også vedlikehold. ",
  },
  decontamination = {
    [1] = "Saneringsklinikk//",
    [2] = "Pasienter som har blitt utsatt for Stråling blir fort henvist til Saneringsklinikken. Dette rommet inneholder en dusj som skyller av dem all den vemmelige Radioaktiviteten og skitt.//",
    [3] = "Saneringsdusjen kan kun håndteres av Leger. Den behöver vedlikehold av en Vaktmester. ",
  },
}

-- Drug companies
drug_companies = {
  "Medisiner-For-Deg",
  "Kur R Oss",
  "Runde Små Piller Co.",
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
  allocated_amount  = "Tildelt belöp",
}

-- Research policy tooltip
tooltip.research_policy = {
research_progress = "Progresjon mot den nesten oppdagelsen i denne kategorien: %1%/%2%",
no_research = "Ingen forskning blir utfört i denne kategorien for öyeblikket",
}

-- Policy screen
policy = {
  header            = "SYKEHUSPOLICY",
  diag_procedure    = "diagnoserutiner",
  diag_termination  = "diagnostisering",
  staff_rest        = "pauserutiner",
  staff_leave_rooms = "forlate rom",

  sliders = {
    guess           = "GJETT KUR", -- belongs to diag_procedure
    send_home       = "SEND HJEM", -- also belongs to diag_procedure
    stop            = "AVBRYT PROSESS", -- belongs to diag_termination
    staff_room      = "TIL PERSONALROM", -- belongs to staff_rest
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
  "Nykjöpt Lök",
  "Böljan Blå",
  "Årlige Forskudd AS",
  "Stygge Arr Co.",
  "Svömmeblære Co.",
  "Dönn Ærlig AS",
  "Sverres Beholdninger",
  "Kate Pus Og Kompani",
  "Larsen Jr. Forsikring",
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
  restart               = "  START PÅ NYTT  ",
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
  twentyfour_hour_clock = "  24 TIMERS KLOKKE  ",
  wage_increase = "  LÖNNSBEGJÆRINGER", --todo: annet ord? "wage requests"
}

menu_options_wage_increase = {
  deny = "    AVSLÅ ",
  grant = "    GODKJENN ",
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
  and_then_some_more  = "  ENDA LITT RASKERE  ",
}

-- Menu Options Warmth Colours
menu_options_warmth_colors = {
choice_1 = "  RÖD  ",
choice_2 = "  BLÅ GRÖNN RÖD  ",
choice_3 = "  GUL ORANGE RÖD  ",
}

-- Menu Display
menu_display = {
  high_res            = "  HÖY OPPLÖSNING  ",
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
  town_map            = "  BYKART (F4)  ",
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

-- Trophy room
trophy_room = {
  reputation = "OMDÖMME",
  cash = "KONTANTER",
  wait_times = {
    award = {
      [1] = "Gratulerer. Sykehuset ditt har lav kötid i lang tid. Dette er en viktig pris.", --todo: skal det brukes ordet "pris"?
    },
    penalty = {
      [1] = "Pasienter i sykehuset ditt må stå for lenge i kö. Det er alltid uakseptabelt lange köer. Du kunne behandlet pasientene dine mer effektivt, om du bare hadde gått inn for det.",
    },
  },
  pop_percentage = {
    awards = {
      [1] = "Legg merke til at du har fått en höy andel av byen befolkning til ditt sykehus det siste året. Bra gjort",
      [2] = "Gratulerer. En höyere andel av lokalbefolkningen besöker sykehuset ditt enn noen andre institusjoner.",
      [3] = "Strålende. Du har lokket mer av befolkningen inn ditt sykehus enn det som har besökt alle de andre sykehusene til sammen.",
    },
    penalty = {
      [1] = "Merk deg at du fikk en höy andel av byen befolkningen til sykehuset ditt det siste året. Godt gjort.",
      [2] = "Gratulerer. En höyere andel av lokalbefolkningen besöker sykehuset ditt enn noen av de andre institusjonene.",
    },
  },
  many_cured = {
    awards = {
      [1] = "Gratulerer med Marie Curie Prisen for å ha klart å kurere nesten alle pasientene på sykehuset ditt i fjor.",
      [2] = "Gratulerer med å ha kurert mengder av pasienter det siste året. Mange mennesker föler seg mye bedre på grunn av ditt arbeid.",
    },
    trophies = {
      [1] = "Den Internasjonale Behandlingsstiftelsen önsker å ære deg fordi du kurerte en haug med mennesker på sykehuset ditt i fjor. De gir deg derfor Kurert-En-Haug Trofeet.",
      [2] = "Du er blitt tildelt Ingen-Syke-Gurglere troféet for å ha kurert en stor prosent av pasientene på sykehuset ditt i fjor.",
      [3] = "Du er blitt tildelt Ingen-Syke-Gurglere troféet for å ha kurert en stor prosent av pasientene på sykehuset ditt i fjor.", --todo: Denne er overflödig (dobbelt opp), men debug-strings-diff.txt insisterer på at denne linjen skal være her.
    },
    penalty = {
      [1] = "Ditt sykehus klarer ikke å gi effektive botemidler til pasienter som trenger det. Konsentrer deg om dine kurer for å gjöre dem mer effektive.",
      [2] = "Ditt sykehus er mindre effektivt ved kurering av pasienter enn noen annen. Du har sviktet departementet og du har sviktet deg selv. Vi sier ikke mer.",
    },
    regional = {
      [1] = "Du er herved tildelt Den-Ultimate-Kur-prisen for å ha kurert flere mennesker enn alle de andre sykehusene til sammen.",
    },
  },
  research = {
    regional_good = {
      [1] = "Din forskning har holdt ditt sykehus à jour med den siste utviklingen. Ditt forskningspersonale fortjener denne prisen. Godt gjort.",
    },
  regional_bad = {
      [1] = "Alle andre sykehus i regionen er bedre på forskning enn deg. Forskning bör være en avgjörende del av sykehuset ditt. Departementet er rasende.",
    },
    penalty = {
      [1] = "Du har vært dårlig på å forske på nye kurer, utstyr og legemidler. Dette er svært dårlig. Teknologisk utvikling er viktig.",
    },
    awards = {
      [1] = "Din forskning har holdt ditt sykehus à jour med den siste utviklingen. Ditt forskningspersonale fortjener denne prisen. Godt gjort.",
      [2] = "I löpet av det siste året, har du forsket på flere legemidler og utstyr enn noen kunne ha håpet på. Vennligst godta denne prisen fra alle oss i departementet.",
    },
  },
  gen_repairs = {
    awards = {
      [1] = "Du er tildelt en spesiell premie for dine Vaktmesteres evne til å holde sykehusets maskiner velholdt. Godt gjort. Ta en ferie.",
      [2] = "Dine Vaktmestere har gjort det bedre enn noen andre sykehus. Dette er en stor prestasjon for deg.",
      [3] = "Dine maskiner er praktfullt vedlikeholdt. Dedikasjonen til dine Vaktmestere er ekstraordinær. Dere fortjener denne utmerkelsen. Strålende arbeid.",
    },
    penalty = {
      [1] = "Vaktmesterne har ikke vedlikeholdt dine maskiner godt. Du bör kontrollere dem mer nöye, eller ansette flere til å håndtere arbeidsmengden.",
      [2] = "Du har gjort et dårlig vedlikehold. Vaktmesterne bör se til utstyret straks.",
    },
  },
  curesvdeaths = {
    awards = {
      [1] = "Solide gratulasjoner på å oppnå et imponerende kurerte kontra dödsfall-forhold på sykehuset det siste året.",
  },
    penalty = {
      [1] = "Din andel av kurerte-vs-dödsfall-forhold er ekstremt dårlig. Du bör sörge for at du kurerer mange flere mennesker enn du lot dö. Ikke svikt oss.",
    },
  },
  emergencies = {
    regional_good = {
      [1] = "Departementet erkjenner at sykehuset håndterte kriser bedre enn noen andre sykehus i fjor og gir deg denne prisen.",
    },
    regional_bad = {
      [1] = "Ditt sykehus er det verste i regionen til å håndtere kriser. Det er din skyld at du blir liggende nederst i den lokale akuttbehandlingsligaen.",
    },
    penalty = {
      [1] = "Du har vært dårlig til å håndtere kriser. Innkommende beredskap pasientene fortjener rask og nöyaktig oppmerksomhet, som du har unnlatt å gi.",
    },
    award = {
      [1] = "Gratulerer: din effektive håndtering av kriser har gjort deg fortjent til denne spesielle prisen. Godt arbeid.",
      [2] = "Din håndtering av kriser er eksepsjonell. Denne prisen er for å være den absolutt beste på å håndtere stor tilströmning av syke og lidende.",
    },
  },
  cleanliness = {
    award = {
      [1] = "Inspektörer gjör oppmerksom på at sykehuset er veldig rent. Rene sykehus er trygge sykehus. Hold oppe det gode arbeidet.",
    },
    regional_good ={
      [1] = "Ditt sykehus har blitt bemerket som en av de minst rene i området. Et skitten sykehus er stinkende og farlig. Du bör sette mer oppmerksomhet på å fjerne rot.",
    },
      regional_bad = {
      [1] = "Ditt sykehus er det skitneste i regionen. Alle andre har klart å beholde sine korridorer renere. Du er en skam for den medisinske profesjon.",
    },
  },
  happy_patients = {
    awards ={
      [1] = "Du kan være selvtilfreds om det faktum at folk i sykehuset har vært svært fornöyde i löpet av det siste året.",
      [2] = "Personer som besöker sykehuset ditt var gjennomsnittlig lykkeligere under deres behandling hos deg enn på noe annet sykehus i spillet.",
  },
    penalty = {
      [1] = "Folk som kommer til sykehuset ditt synes opplevelsen er elendig. Du må gjöre det mye bedre hvis du önsker å få respekt av departementet.",
      [2] = "Folk som får behandling på sykehuset ditt var svært misfornöyd med tilstanden der. Du bör sette mer fokus på pasientenes velferd.",
    },
  },
    consistant_rep = {
      trophies = {
        [1] = "Du er herved tildelt statsrådens pris for de mest plettfrie standarder og höyest mulig omdömme i år. Bra gjort.",
        [2] = "Gratulerer. Du mottar GnukkiRen-Troféet for sykehuset med best omdömme det siste året. Vel fortjent er det også.",
      },
  },
  all_cured = {
    awards = {
      "Gratulerer med Marie Curie Prisen for å ha klart å kurere alle pasienter på sykehuset ditt i fjor.",
    },
    trophies = {
      "Den Internasjonale Behandlingsstiftelsen önsker å ære deg fordi du kurerte alle pasienter på sykehuset ditt i fjor. De gir deg derfor Kurert-Alle Trofeet.",
      "Du er blitt tildelt Ingen-Syke-Gurglere Trofeet for å ha kurert alle pasienter på sykehuset ditt i fjor.",
    },
  },
  high_rep = {
    awards = {
      [1] = "Du er herved tildelt statsministerens Glitrende Sykehusstandard Pris, som tildeles sykehuset med best omdömme i fjor. Flott!",
      [2] = "Vær snill å ta imot Bullfrog-prisen som tildeles sykehuset med best omdömme i fjor. Nyt det - det er vel fortjent!",
    },
    penalty = {
      [1] = "Man skal være veldig disiplinert for å klare å opprettholde et så dårlig rykte gjennom hele det siste året. Sörg for at det forbedrer i fremtiden.",
      [2] = "Ditt Sykehus sitt omdömme er det verste i området. Du er en skam. Gjör det bedre eller få deg en annen jobb.",
    },
    regional = {
      [1] = "Vennligst godta Bullfrog-prisen for det höyeste omdömmet det siste året. Nyt det - du har fortjent det.",
      [2] = "I år har ditt sykehus sitt omdömme overgått alle de andre sykehusene til sammen. En stor prestasjon.",
    },
  },
  happy_staff = {
    awards = {
      [1] = "De ansatte gir deg denne prisen. De sier det er rom for forbedringer, men behandlingen av dem var generelt god.",
      [2] = "De ansatte er så glad å arbeide for deg at kan de ikke holde smilet borte fra ansiktene sine. Du er en ypperlig sjef.",
    },
    trophies = {
      "Du er tildelt Smilefjes Trofeet for å holde ditt hardt-arbeidende personale så blid og fornöyd som mulig.",
      "Instituttet for Humörspredere berömmer deg for at du ikke hadde noen sure og sinte ansatte på sykehuset ditt i fjor, og gir deg derfor dette trofeet.",
      "Dette troféet, Stråle Mer Begeret, er herved tildelt deg for å ha klart å holde alt personell blid og fornöyd, tross en iherdig arbeidsinnsats i fjor. Dine ansatte stråler!",
    },
    penalty = {
      [1] = "De ansatte önsker det skal bli kjent at de er svært misfornöyde. Gode ansatte er en ressurs. Gjör dine lykkeligere, ellers vil du miste dem en dag.",
  },
    regional_good = {
      [1] = "De ansatte er lykkeligere enn på noe annet sykehus. Glade ansatte betyr mer overskudd og mindre död. Departementet er fornöyd.",
    },
    regional_bad = {
      [1] = "De ansatte har alle vært veldig sure det siste året. Du burde ha lagt merke til at alle andre sykehus har lykkeligere personalet enn deg.",
    },
  },
  happy_vips = {
    trophies = {
      [1] = "Du har vunnet Nobelprisen for Mest Imponerte VIP-er. Alle som besökte sykehuset i fjor var svært komplimenterende.",
      [2] = "Byrået for Kjente Personer vil belönne deg med Kjendistroféet for å ha tatt godt vare på alle VIP-er som besökte institusjonen din i fjor. Du nærmer deg kjendis-status, nesten en av oss.",
      [3] = "Gratulerer med VIP-prisen for å ha gjort livene til hardtarbeidende kjendiser bedre, ved å sette alle som besökte sykehuset ditt i fjor i et bedre lys. Fantastisk.",
    },
  },
  no_deaths = {
    awards = {
      [1] = "Du har vunnet Leve Lenge-troféet for å holde 100 prosent av pasientene levende i hele fjor.",
      [2] = "Du har fått denne prisen til minne om lavt antall dödsfall på ditt sykehus dette året. Dette er flott.",
    },
    trophies = {
      [1] = "Livet Går Videre Stiftelsen belönner deg med dette trofeet for å ha oppnådd null dödsfall i hele fjor.",
      [2] = "Du er tildelt Holde Seg I Live-troféet for å ha unngått dödsfall på ditt flotte sykehus dette året. Storartet.",
      [3] = "Du er tildelt Holde Seg I Live-troféet for å ha unngått dödsfall på ditt flotte sykehus dette året. Storartet.", --todo: Denne er overflödig (dobbelt opp), men debug-strings-diff.txt insisterer på at denne linjen skal være her.
    },
    penalty = {
      [1] = "Antallet dödsfall i sykehuset ditt i fjor var uakseptabelt höyt. Gi mer oppmerksomhet til ditt arbeid. Vær sikker på at flere mennesker overlever i fremtiden.",
      [2] = "Ditt sykehus er en risiko for pasientenes helse. Du forventes å kurere mange mennesker, ikke la dem dö.",
    },
    regional = {
      [1] = "Dödstallene i ditt sykehus i fjor var lavere enn noen andre sykehus. Vennligst godta denne prisen.",
    },
  },
  rats_killed = {
    awards = {
    },
    trophies = {
      "Du er tildelt Null Uhyrer Trofeet for å ha skutt %d rotter på sykehuset ditt i löpet av fjoråret.", -- %d (number of rats)
      "Du mottar dette trofeet fra Organisasjonen Mot Rotter og Mus, pga. dine unike rotteskytende evner. Du drepte %d dyr i fjor.", -- %d (number of rats)
      "Du mottar Rotteskytter Trofeet for å ha vist unike evner i utryddelsen av %d rotter på sykehuset ditt i fjor.", -- %d (number of rats)
    },
  },
  rats_accuracy = {
    awards = {
    },
    trophies = {
      "Du er tildelt Nöyaktige Skudd I Håplös Krig Trofeet for å ha en treffprosent på %d%% i jakten på ekle rotter.", -- %d (accuracy percentage)
      "Dette trofeet er for å berömme din nöyaktighet ved å drepe %d%% av rottene du sköyt på i fjor.", -- %d (accuracy percentage)
      "For å hedre prestasjonen det er å drepe %d%% av alle rottene på sykehuset ditt, blir du tildelt Dungeon Keepers Skadedyrfrie Trofe, gRATulerer!", -- %d (accuracy percentage)
    },
  },
  healthy_plants = {
    awards = {
      "Gratulerer med Voks-Videre prisen for å ha holdt plantene dine ekstremt friske i hele år.",
    },
    trophies = {
      "Venner Av Potteplanter önsker å gi deg Grönn Helse Trofeet, for å ha tatt godt vare på plantene dine de siste tolv måneder.",
      "Foreningen For Grönne Gamlinger önsker å gi deg Grönnfinger Trofeet for å ha holdt plantene dine friske i hele fjor.",
    },
  },
  hosp_value = {
      awards = {
      [1] = "Helsedepartementet vil gjerne benytte anledningen til å gratulere deg med den imponerende samlede verdien av sykehuset ditt.",
    },
    penalty = {
      [1] = "Ditt sykehus har unnlatt å oppnå en anstendig verdi. Du har gjort dårlige pengebeslutninger. Husk at et godt sykehus også er et kostbart sykehus.",
    },
    regional = {
      [1] = "Du er en fremgangsrik ung forretningsmann. Ditt sykehus er mer verdifullt enn alle de andre sykehusene i området til sammen.",
    },
  },
  best_value_hosp = {
    trophies  = {
    [1] = "Gratulerer. Du mottar GnukkiRen-Troféet for sykehuset med best omdömme det siste året. Vel fortjent er det også.",
    },
  penalty = {
    [1] = "Hvert sykehus i nærområdet er verdt mer enn ditt. Gjör noe med denne skammelige situasjonen. Få inn noen dyrere ting!",
    },
    regional = {
    [1] = "Gratulerer med å ha det mest verdifulle sykehuset i spillet. Godt arbeid. Pröv å holde det slik.",
    },
  },
  sold_drinks = {
    awards = {
    },
    trophies = {
      "Foreningen for Globale Tannleger er stolt over å kunne gi deg dette trofeet for å ha solgt store menger brus på sykehuset ditt i fjor.",
      "Sykehuset ditt er blitt tildelt Sprudlende-Begjær Trofeet for antall leskedrikker som ble solgt på sykehuset ditt i fjor.",
      "På vegne av DK Fyllinger Co., tildeles du herved dette trofeet dekket av sjokolade, for å ha solgt enorme mengder leskedrikker på sykehuset ditt forrige år.",
    },
  },
}



-- Casebook screen
casebook = {
  reputation           = "omdömme",
  treatment_charge     = "behandlingspris",
  earned_money         = "totale inntekter",
  cured                = "behandlet",
  deaths               = "dödsfall",
  sent_home            = "sendt hjem",
  research             = "konsentrer forskning",
  cure                 = "kur",
  cure_desc = {
    build_room         = "Jeg anbefaler deg å bygge %s", -- %s (room name)
    build_ward         = "Du trenger fremdeles en Sykestue.",
    hire_doctors       = "Du må ansette noen Leger.",
    hire_surgeons      = "Du må ansette Kirurger.",
    hire_psychiatrists = "Du må ansette Psykiatere.",
    hire_nurses        = "Du må ansette Sykepleiere.",
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
    bank_button        = "Venstreklikk for Bankmanager, höyreklikk for Kontoutskrift",
    balance            = "Din Balanse",
    reputation         = "Ditt omdömme: ", -- NB: no %d! Append " ([reputation])".
    date               = "Dato",
    rooms              = "Bygg rom",
    objects            = "Kjöp gjenstander",
    edit               = "Endre rom/gjenstander",
    hire               = "Ansett personale",
    staff_list         = "Personalbehandling",
    town_map           = "Områdekart",
    casebook           = "Medisinbok",
    research           = "Forskning",
    status             = "Status",
    charts             = "Diagrammer",
    policy             = "Sykehuspolicy",
  },

  -- Hire staff window
  hire_staff_window = {
    doctors            = "Vis Leger tilgjengelig på arbeidsmarkedet",
    nurses             = "Vis Sykepleiere tilgjengelig på arbeidsmarkedet",
    handymen           = "Vis Vaktmestere tilgjengelig på arbeidsmarkedet",
    receptionists      = "Vis Resepsjonister tilgjengelig på arbeidsmarkedet",
    prev_person        = "Vis forrige person",
    next_person        = "Vis neste person",
    hire               = "Ansett person",
    cancel             = "Avbryt",
    doctor_seniority   = "Legens erfaring (Turnuslege, Doktor, Konsulent)",
    staff_ability      = "Evner",
    salary             = "Lönnskrav",
    qualifications     = "Legens spesialisering",
    surgeon            = "Kirurg",
    psychiatrist       = "Psykiater",
    researcher         = "Forsker",
  },

  -- Buy objects window
  buy_objects_window = {
    price              = "Pris på gjenstand",
    total_value        = "Total verdi på kjöpte gjenstander",
    confirm            = "Kjöp gjenstand(er)",
    cancel             = "Avbryt",
    increase           = "Kjöp en til av denne gjenstanden",
    decrease           = "Kjöp en mindre av denne gjenstanden",
  },

  -- Staff list
  staff_list = {
    doctors            = "Se en oversikt over dine Leger",
    nurses             = "Se en oversikt over dine Sykepleiere",
    handymen           = "Se en oversikt over dine Vaktmestere",
    receptionists      = "Se en oversikt over dine Resepsjonister",
    happiness          = "Viser hvordan humöret på dine ansatte er",
    tiredness          = "Viser hvor trött dine ansatte er",
    ability            = "Viser evnene til dine ansatte",
    salary             = "Den enkeltes gjeldende lönn",
    happiness_2        = "Den ansattes moral",
    tiredness_2        = "Den ansattes tretthetsnivå",
    ability_2          = "Den ansattes evner",
    prev_person        = "Velg forrige side",
    next_person        = "Velg neste side",
    bonus              = "Gi denne ansatte 10% bonus",
    sack               = "Si opp denne ansatte",
    pay_rise           = "Hev lönnen til denne ansatte med 10%",
    close              = "Lukk og returner til spillet",
    doctor_seniority   = "Legens erfaring",
    detail             = "Oppmerksom på detaljer",
    view_staff         = "Vis ansatt på jobb",
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
    num_in_queue       = "Antall pasienter i köen",
    num_expected       = "Antall pasienter Resepsjonisten forventer i köen innen kort tid",
    num_entered        = "Antall pasienter som er behandlet i dette rommet så langt",
    max_queue_size     = "Maksimal lengde på köen som Resepsjonisten skal etterstrebe",
    dec_queue_size     = "Senk maksimal kölengde",
    inc_queue_size     = "Ök maksimal kölengde",
    front_of_queue     = "Dra en pasient hit for å stille han/henne fremst i köen",
    end_of_queue       = "Dra en pasient hit for å stille han/henne bakerst i köen",
    close              = "Lukk vindu",
    patient            = "Dra en pasient for å flytte han/henne i köen. Höyreklikk på en pasient for å sende han/henne hjem eller til et konkurrerende sykehus",
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
    quit               = "Du er på vei til å avslutte spillet. Er du sikker på at du vil dette?", --todo: Her tror jeg det er valgt feil navn/sted for "quit". Denne viser til spörsmålet man får ved å trykke på Avslutt i hovedmenyen.
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
    graph              = "Klikk for å veksle mellom graf med personens helse og personens behandlingshistorikk",
    happiness          = "Personens humör",
    thirst             = "Personens törste",
    warmth             = "Personens temperatur",
    casebook           = "Vis detaljer for pasientens sykdom",
    send_home          = "Send pasienten hjem fra sykehuset",
    center_view        = "Sentrer personen i skjermbildet",
    abort_diagnosis    = "Send personen til behandling istedenfor å vente til diagnosen er ferdigstilt",
    queue              = "Se köen pasienten befinner seg i",
  },
  -- window
  staff_window = {
    name               = "Den ansattes navn",
    close              = "Lukk vindu",
    face               = "Ansiktet til personen - Klikk for å administrere de ansatte",
    happiness          = "Humörnivå",
    tiredness          = "Tretthetsnivå",
    ability            = "Evner",
    doctor_seniority   = "Stilling (Turnuslege, Doktor, Konsulent)",
    skills             = "Spesialisering",
    surgeon            = "Kirurg",
    psychiatrist       = "Psykiater",
    researcher         = "Forsker",
    salary             = "Månedslönn",
    center_view        = "Venstreklikk for å finne den ansatte, höyreklikk for å bla gjennom de ansatte.",
    sack               = "Si opp",
    pick_up            = "Plukk opp",
  },
  -- Machine window
  machine_window = {
    name               = "Navn",
    close              = "Lukk vindu",
    times_used         = "Antall gangen maskinen er brukt",
    status             = "Maskinstatus",
    repair             = "Kall på Vaktmester for å fikse maskinen",
    replace            = "Erstatt maskin",
  },


  -- Handyman window
  -- Apparently handymen have their own set of strings (partly) containing "handyman".
  -- We could just get rid of this category and include the three prios into staff_window.
  handyman_window = {
    name               = "Vaktmesterens navn", -- contains "handyman"
    close              = "Lukk vindu",
    face               = "Vaktmesterens ansikt", -- contains "handyman"
    happiness          = "Humörnivå",
    tiredness          = "Tretthetsnivå",
    ability            = "Evner",
    prio_litter        = "Be Vaktmesteren om å prioritere rengjöring av gulv höyere", -- contains "handyman"
    prio_plants        = "Be Vaktmesteren om å prioritere vanning av planter höyere", -- contains "handyman"
    prio_machines      = "Be Vaktmesteren om å prioritere reparasjon av maskiner höyere", -- contains "handyman"
    salary             = "Månedslönn",
    center_view        = "Sentrer i skjermbildet", -- contains "handyman"
    sack               = "Si opp",
    pick_up            = "Plukk opp",
    parcel_select      = "Steder hvor Vaktmesteren utförer oppgaver. Klikk for å endre innstilling.",
  },

  -- Place objects window
  place_objects_window = {
    cancel             = "Avbryt",
    buy_sell           = "Kjöp/Selg gjenstander",
    pick_up            = "Plukk opp en gjenstand",
    confirm            = "Bekreft",
  },

  -- Casebook
  casebook = {
    up                 = "Rull oppover",
    down               = "Rull nedover",
    close              = "Lukk medisinbok",
    reputation         = "Ryktet behandlingen eller diagnosen har i nærområdet",
    treatment_charge   = "Pris for behandling",
    earned_money       = "Totalt opptjente penger frem til i dag",
    cured              = "Antall kurerte pasienter",
    deaths             = "Antall pasienter drept som fölge av behandlingen",
    sent_home          = "Antall pasienter som har snudd og gått hjem",
    decrease           = "Senk pris",
    increase           = "Ök pris",
    research           = "Trykk her for å bruke forskingsbudsjettet for spesialisering til å forske på denne behandlingen",
    cure_type = {
      drug             = "Denne behandlingen krever medisin",
      drug_percentage  = "Denne behandlingen krever medisin - din er %d%% effektiv", -- %d (effectiveness percentage)
      psychiatrist     = "En Psykiater kreves for behandling",
      surgery          = "Denne sykdommen krever en operasjon",
      machine          = "Denne sykdommen krever en maskin for behandling",
      unknown          = "Du vet ikke hvordan du skal behandle denne sykdommen enda",
    },

    cure_requirement = {
      possible         = "Du kan gjennomföre behandling",
      research_machine = "Du må forske på maskiner for å gjennomföre behandlingen",
      build_room       = "Du må bygge et rom for å gjennomföre behandlingen", -- NB: no %s!
      hire_surgeons    = "Du trenger to Kirurger for å gjennomföre behandlingen",
      hire_surgeon     = "Du trenger en Kirurg til for å gjennomföre behandlingen",
      hire_staff       = "Du må ansette en %s for å gjennomföre behandlingen", -- %s (staff type)
      hire_staff_old   = "Du må ansette en %s for å gjennomföre behandlingen",
      build_ward       = "Du må bygge en Sykestue for å kunne gjennomföre behandlingen",
      ward_hire_nurse  = "Du trenger en Sykepleier på Sengeavdelingen for å gjennomföre behandlingen",
      not_possible     = "Du kan ikke håndtere denne behandlingen enda",
    },
  },

  -- Statement
  statement = {
    close              = "Lukk kontoutskriften",
  },

  -- Research
  research = {
    close              = "Gå ut av forskningsavdelingen",
    cure_dec           = "Senk prioritering av forskning på behandlingsutstyr",
    diagnosis_dec      = "Senk prioritering av forskning på diagnoseutstyr",
    drugs_dec          = "Senk prioritering av forskning på medisiner",
    improvements_dec   = "Senk prioritering av forskning på forbedringer",
    specialisation_dec = "Senk prioritering av forskning på spesialiseringer",
    cure_inc           = "Ök prioritering av forskning på behandlingsutstyr",
    diagnosis_inc      = "Ök prioritering av forskning på diagnoseutstyr",
    drugs_inc          = "Ök prioritering av forskning på medisiner",
    improvements_inc   = "Ök prioritering av forskning på forbedringer",
    specialisation_inc = "Ök prioritering av forskning på spesialiseringer",
    allocated_amount   = "Penger satt av til forskning",
  },

  -- Graphs
  graphs = {
    close              = "Gå ut av diagramvinduet",
    scale              = "Skala på diagram",
    money_in           = "Vis/skjul Inntekter",
    money_out          = "Vis/skjul Utgifter",
    wages              = "Vis/skjul Lönninger",
    balance            = "Vis/skjul Balanse",
    visitors           = "Vis/skjul Besökende",
    cures              = "Vis/skjul Kurerte",
    deaths             = "Vis/skjul Dödsfall",
    reputation         = "Vis/skjul Omdömme",
  },

  -- Town map
  town_map = {
    people             = "Vis/Skjul mennesker",
    plants             = "Vis/Skjul planter",
    fire_extinguishers = "Vis/Skjul brannslukningsapparat",
    objects            = "Vis/Skjul gjenstander",
    radiators          = "Vis/Skjul radiatorer",
    heat_level         = "Temperatur",
    heat_inc           = "Skru opp temperaturen",
    heat_dec           = "Skru ned temperaturen",
    heating_bill       = "Varmekostnader",
    balance            = "Balanse",
    close              = "Lukk områdekart",
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
    hospital_value     = "Nåværende verdi på sykehuset ditt",
    balance            = "Din balanse i banken",
    current_loan       = "Gjeldende lån i banken",
    repay_5000         = "Betal tilbake 5000 til banken",
    borrow_5000        = "Lån 5000 av banken",
    interest_payment   = "Månedlige rentekostnader",
    inflation_rate     = "Årlig inflasjon",
    interest_rate      = "Årlig rente",
    close              = "Lukk bankmanageren",
    insurance_owed     = "Penger %s skylder deg", -- %s (name of debitor)
    show_graph         = "Vis forventet tilbakebetalingsplan fra %s", -- %s (name of debitor)
    graph              = "Forventet tilbakebetalingsplan fra %s", -- %s (name of debitor)
    graph_return       = "Returner til forrige visning",
  },

  -- Status
  status = {
    percentage_cured   = "Du må kurere %d% besökende på sykehuset ditt. Nå har du kurert %d%",
    thirst             = "Gjennomsnittlig törste på personene på ditt sykehus",
    close              = "Lukk oversikten",
    population_chart   = "Figur som viser hvor stor andel av lokalbefolkningen hvert sykehus tiltrekker seg",
    win_progress_own   = "Vis progresjon i forhold til kravene for dette nivået",
    reputation        = "Omdömmet ditt må være minst %d. Nå er det %d",
    population        = "Du må ha %d%% av befolkningen til å bruke ditt sykehus",
    warmth             = "Gjennomsnittlig temperatur på personene på ditt sykehus",
    percentage_killed  = "Du må drepe færre enn %d%% av dine besökende. Så langt har du tatt livet av %d%%",
    balance        = "Din bankbalanse må være på minst %d. Nå er den %d",
    value          = "Sykehuset ditt må være verdt $%d. Så langt er det verdt $%d",
    win_progress_other = "Vis progresjon i forhold til kravene for dette nivået for %s", -- %s (name of competitor)
    num_cured        = "Du må kurere %d mennesker. Så langt har du kurert %d",
    happiness          = "Gjennomsnittlig humör på personene på ditt sykehus",
  },

  -- Policy
  policy = {
    close              = "Lukk sykehuspolicy",
    staff_leave        = "Klikk her for å få personale som ikke er opptatt til å hjelpe kollegaer som trenger det",
    staff_stay         = "Klikk her for å få personale til å bli i rommene du plasserer dem i",
    diag_procedure     = "Om en Leges stilte diagnose er mindre sikker enn SEND HJEM prosenten, vil pasienten bli sendt hjem. Om diagnosen er sikrere enn GJETT KUR prosenten, vil pasienten sendes til aktuell behandling",
    diag_termination   = "En pasients diagnostisering vil fortsette helt til Legene er så sikker som AVBRYT PROSESS prosenten, eller til alle diagnosemaskiner er forsökt på pasienten",
    staff_rest         = "Hvor trött personalet må være för de kan hvile",
  },

  -- Pay rise window
  pay_rise_window = {
    accept             = "Imötekom kravene",
    decline            = "Ikke godta kravene - Si opp istedenfor",
  },

  -- Watch
  watch = {
    hospital_opening   = "Byggetid: Dette er tiden du har igjen för sykehuset åpner. Klikk på ÅPNE-knappen, så vil sykehuset åpne umiddelbart.",
    emergency          = "Nödstilfelle: Tid som gjenstår til å behandle alle akutte pasienter.",
    epidemic           = "Epidemi: Tid som gjenstår til å skjule epidemien. Når tiden er ute ELLER en smittsom pasient forlater sykehuset, så kommer en Helseinspektör på besök. Knappen skrur av og på vaksineringsmodus. Klikk på pasienter for å få en Sykepleier til å vaksinere dem.",
  },

  -- Rooms
  rooms = {
    gps_office         = "Pasientene får sin förste konsultasjon og tilhörende resultater på Allmennpraksisen",
    psychiatry         = "Psykiatrien kurerer gale pasienter og hjelper til med diagnostiseringen av andre pasienter, men trenger en Lege med spesialisering innenfor Psykiatri",
    ward               = "Sengeavdelinger er nyttige for både diagnostisering og behandling. Pasienter blir sendt hit for observasjon men også for overvåkning etter operasjoner. Sengeavdelingen krever en Sykepleier",
    operating_theatre  = "Operasjonssalen krever to Leger med spesialisering innenfor Kirurgi",
    pharmacy           = "Sykepleieren skriver ut medisiner på apoteket for å kurere pasienter",
    cardiogram         = "En Lege bruker Kardio for å diagnostisere pasienter",
    scanner            = "En Lege bruker Skanneren for å diagnostisere pasienter",
    ultrascan          = "En Lege bruker Ultraskanneren for å diagnostisere pasienter",
    blood_machine      = "En Lege bruker Blodmaskinen for å diagnostisere pasienter",
    x_ray              = "En Lege bruker Röntgen for å diagnostisere pasienter",
    inflation          = "En Lege bruker Pumperommet for å behandle pasienter med Ballonghode",
    dna_fixer          = "En Lege bruker DNA-maskinen for å behandle pasienter med Utenomjordisk DNA",
    hair_restoration   = "En Lege bruker Hårklinikken for å behandle pasienter med Flintskalle",
    tongue_clinic      = "En Lege bruker Tungekutteren for å behandle pasienter med Lös tunge",
    fracture_clinic    = "En Sykepleier bruker Benbruddsklinikken for å reparere Benbrudd",
    training_room      = "Et klasserom med en Konsulent kan brukes til å lære opp andre Leger",
    electrolysis       = "En Lege bruker Elektrolyseklinikken for å behandle pasienter med Pelssyndrom",
    jelly_vat          = "En Lege bruker Gelétönnen for å behandle pasienter med Gelésyndrom",
    staffroom          = "Leger, Sykepleiere og Vaktmestre bruker personalrommet for å hvile og heve humöret",
    -- rehabilitation  = S[33][27], -- unused
    general_diag       = "En Lege bruker trallen for å stille grunnleggende diagnose på pasienter. Billig og ofte veldig effektivt",
    research_room      = "Leger med spesialisering innen Forskning kan forske frem nye medisiner og maskiner på Forskningsavdelingen",
    toilets            = "Bygg toaletter for å få pasientene til å stoppe å skitne til sykehuset!",
    decontamination    = "En Lege bruker Saneringsdusjen for å behandle pasienter med Alvorlig Stråling",
  },

  -- Objects
  objects = {
    -- NB: most objects do not have a tooltip because they're not (extra-)buyable
    desk                 = "Pult: en Lege kan bruke pulten til PC-en sin.",
    cabinet              = "Kabinett: inneholder pasientdata, notater og forskningsdokumenter.",
    door                 = "Dör: personer åpner og lukker disse en del.",
    bench                = "Benk: gir pasienter en plass å sitte og gjör ventingen mer komfortabel.",
    table1               = S[40][ 6], -- unused
    chair                = "Stol: Pasienter sitter her og diskuterer sine problemer.",
    drinks_machine       = "Brusautomat: hindrer pasientene å bli törste og genererer inntekter.",
    bed                  = "Seng: virkelig syke pasienter ligger i disse.",
    inflator             = "Pumpe: Kurerer pasienter med Ballonghode.",
    pool_table           = "Biljardbord: Hjelper personalet ditt med å slappe av.",
    reception_desk       = "Resepsjon: trenger en Resepsjonist som kan henvise pasienter videre.",
    table2               = S[40][13], -- unused & duplicate
    cardio               = S[40][14], -- no description
    scanner              = S[40][15], -- no description
    console              = S[40][16], -- no description
    screen               = S[40][17], -- no description
    litter_bomb          = "Söppelbombe: saboterer konkurrenters sykehus",
    couch                = S[40][19], -- no description
    sofa                 = "Sofa: ansatte som slapper av på Personalrommet vil sitte stille i en sofa så fremt det ikke er en bedre måte å slappe av på.",
    crash_trolley        = S[40][21], -- no description
    tv                   = "TV: sörg for at personalet ditt ikke går glipp av favorittprogrammet sitt.",
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
    toilet_sink          = "Vask: dine hygienebevisste pasienter kan vaske sine tilgrisede hender i disse. Om det ikke er nok vasker, blir pasientene sure.",
    op_sink1             = S[40][34], -- no description
    op_sink2             = S[40][35], -- no description
    surgeon_screen       = S[40][36], -- no description
    lecture_chair        = "Forelesningsstol: dine Legestudenter sitter her og tar notater, kjeder seg og rabler ivrig. Jo flere stoler du har, jo större kan klassen være.",
    projector            = S[40][38], -- no description
    bed2                 = S[40][39], -- unused duplicate
    pharmacy_cabinet     = "Apotekskap: medisinbeholdningen din finnes her",
    computer             = "Datamaskin: genialt forskningsverktöy",
    atom_analyser        = "Atomanalyser: plassert i Forskningsavdelingen, gjör denne gjenstanden hele forskningsprosessen raskere.",
    blood_machine        = S[40][43], -- no description
    fire_extinguisher    = "Brannslukningsapparat: minimerer faren for feil i dine maskiner.",
    radiator             = "Radiator: sörger for at sykehuset ditt ikke blir kaldt.",
    plant                = "Plante: holder pasientenes humör oppe og renser luften.",
    electrolyser         = S[40][47], -- no description
    jelly_moulder        = S[40][48], -- no description
    gates_of_hell        = S[40][49], -- no description
    bed3                 = S[40][50], -- unused duplicate
    bin                  = "Söppelbötte: pasientene kaster söppelet her.",
    toilet               = "Toalett: pasientene, æh..., bruker dette.",
    swing_door1          = S[40][53], -- no description
    swing_door2          = S[40][54], -- no description
    shower               = S[40][55], -- no description
    auto_autopsy         = "Obduksjonsautomat: flott hjelpemiddel for å oppdage nye behandlingsmetoder.",
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
    start_tutorial         = "Les Oppdragsbriefingen og klikk venstre museknapp for å starte innföring.",
    information_window         = "Hjelpeboksen forteller deg alt om den fine Allmennpraksisen du nettopp har bygd.",
    build_reception         = "Heisann. Först, trenger sykehuset ditt en Resepsjon. Velg en fra Inventarmenyen.",
    order_one_reception       = "Klikk en gang på den blinkende linjen med venstre museknapp for å kjöpe en Resepsjon.",
    accept_purchase         = "Venstreklikk på den blinkende linjen for å kjöpe den.",
    rotate_and_place_reception     = "Klikk med höyre museknapp for å rotere Resepsjonen, og venstreklikk for å plassere den i sykehuset.",
    reception_invalid_position     = "Resepsjonen er nå grå fordi det er en ugyldig plassering. Pröv å flytte eller rotere den.",
    hire_receptionist         = "Du trenger nå en Resepsjonist til å stå i resepsjonen og henvise dine pasienter.",
    select_receptionists       = "Venstreklikk på det blinkende ikonet for å se gjennom tilgjengelige Resepsjonister. Nummeret på ikonet viser antall som er tilgjengelig.",
    next_receptionist         = "Dette er den förste Resepsjonisten i listen. Venstreklikk på det blinkende ikonet for å se på neste person.",
    prev_receptionist         = "Venstreklikk på det blinkende ikonet for å se på forrige person.",
    choose_receptionist       = "Avgjör hvilken Resepsjonist som har gode evner og akseptable lönnskrav, og venstreklikk på det blinkende ikonet for å ansette henne.",
    place_receptionist         = "Flytt Resepsjonisten og plasser henne hvor som helst. Hun klarer å finne veien til resepsjonen selv.",
    receptionist_invalid_position   = "Du kan ikke plassere henne der.",
    window_in_invalid_position     = "Dette vinduet kan ikke være her. Pröv å plassere det en annen plass på veggen, er du snill.",
    choose_doctor           = "Se nöye gjennom evnene til hver enkelt Lege för du bestemmer deg for hvem du vil ansette.",
    click_and_drag_to_build       = "For å bygge en Allmennpraksis, må du först avgjöre hvor stor den skal være. Klikk og hold inne venstre museknapp for å justere rommets störrelse.",
    build_gps_office         = "For å starte å diagnostisere pasientene dine, må du ha en Allmennpraksis.",
    door_in_invalid_position     = "Oj, sann! Du prövde å plassere dören i en ugyldig posisjon. Pröv en annen plass på veggen av blåkopien.",
    confirm_room           = "Venstreklikk på det blinkende ikonet for å ferdigstille rommet ditt, eller klikk på X-en for å gå et trinn tilbake.",
    select_diagnosis_rooms       = "Venstreklikk på det blinkende ikonet for å se en liste over diagnoserom du kan bygge.",
    hire_doctor           = "Du trenger en Lege for å diagnostisere og behandle syke mennesker.",
    select_doctors           = "Venstreklikk på det blinkende ikonet for å se hvilke Leger som er tilgjengelig i arbeidsmarkedet.",
    place_windows           = "Plasser vinduer på samme måten som du plasserte dören. Du trenger ikke vinduer, men de ansatte setter veldig pris på det, og blir blidere når de har noe å se ut gjennom.",
    place_doctor           = "Plasser Legen hvor som helst i Sykehuset. Han vil spasere til Allmennpraksisen så snart noen trenger å diagnostiseres.",
    room_in_invalid_position     = "Oj! Denne blåkopien er ikke gyldig - det röde området indikerer hvor du har overlappet et annet rom eller sykehusets vegger.",
    doctor_in_invalid_position     = "Hei! Du kan ikke slippe Legen her.",
    place_objects           = "Höyreklikk for å rotere gjenstander, og venstreklikk for å plassere dem.",
    room_too_small           = "Denne blåkopien er röd fordi den er for liten. Strekk den ut for å gjöre den större.",
    click_gps_office         = "Venstreklikk på den blinkende linjen for å velge en Allmennpraksis.",
    room_too_small_and_invalid     = "Blåkopien er for liten og er ugyldig plassert. Kom igjen.",
    object_in_invalid_position     = "Denne gjenstanden er ugyldig plassert. Vær vennlig å plasser den et annet sted, eller roter den for å få den til å passe.",
    place_door             = "Flytt musen rundt om kring på blåkopiens vegger for å plassere dören der du vil ha den.",
    room_big_enough         = "Blåkopien er nå stor nok. Når du slipper museknappen, plasserer du den. Du kan allikevel fortsette å flytte den eller endre störrelse om du vil.",
    build_pharmacy           = "Gratulerer! Nå må du bygge et Apotek og ansette en Sykepleier for å ha et fungerende sykehus.",
  },

  -- Cheats
  cheats = {
    th_cheat = "Gratulerer du har låst opp juksekodene!",
    hairyitis_cheat = "Pelssyndom-kode aktivert!",
    hairyitis_off_cheat = "Pelssyndom-kode deaktivert.",
    roujin_on_cheat = "Roujins utfordring aktivert! Lykke til...",
    roujin_off_cheat = "Roujins utfordring deaktivert.",
    crazy_on_cheat = "Å nei! Alle Legene har blitt gale!",
    crazy_off_cheat = "Puh... Legene har fått tilbake forstanden.",
    bloaty_cheat = "Ballonghode-kode aktivert!",
    bloaty_off_cheat = "Ballonghode-kode deaktivert.",
  },

  -- Epidemic
  epidemic = {
    hurry_up         = "Om du ikke tar deg av epidemien nå, får du store problemer. Fort deg!",
    serious_warning     = "Den smittsomme sykdomen begynner å bli et seriöst problem. Du må gjöre noe snart!",
    multiple_epidemies     = "Det ser ut som at du har mer enn en epidemi gående samtidig. Dette kan bli en enorm katastrofe, så fort deg.",
  },

  -- Staff advice
  staff_advice = {
    need_handyman_machines   = "Du må ansette Vaktmestre om du vil holde maskinene dine ved like.",
    need_doctors       = "Du trenger flere Leger. Pröv å plassere dine beste Leger i rommene med lengst kö.",
    need_handyman_plants   = "Du må ansette en Vaktmester for å vanne plantene.",
    need_handyman_litter   = "Folk har begynt å forsöple sykehuset ditt. Ansett en Vaktmester for å rydde opp etter pasientene dine.",
    need_nurses       = "Du trenger flere Sykepleiere. Sengeavdelinger og Apotek kan bare driftes av Sykepleiere.",
    too_many_doctors     = "Du har for mange Leger. Noen av dem har ingenting å gjöre.",
    too_many_nurses     = "Jeg tror du har for mange Sykepleiere.",
  },

  -- Earthquake
  earthquake = {
    damage     = "Det jordskjelvet skadet %d maskiner og %d pasienter på sykehuset.", -- %d (count machines), &d (count patients)
    alert     = "Jordskjelv-varsel. Under et jordskjelv blir maskinene dine skadet. De kan bli ödelagt om de er dårlig vedlikeholdt.",
    ended     = "Puh. Jeg trodde det var et stort skjelv - Det målte %d på Richters skala.",
  },

  -- Multiplayer
  multiplayer = {
    objective_completed       = "Du har fullfört utfordringene for dette nivået. Gratulerer!",
    everyone_failed         = "Ingen klarte de forrige utfordringene. Så alle får spille videre !",
    players_failed           = "Fölgende spiller(e) klarte ikke den forrige utfordringen : ",

    poaching = {
      in_progress           = "Jeg skal si ifra om denne personen vil komme å jobbe for deg.",
      not_interested         = "Ha! De er ikke interessert i å jobbe for deg - de har det bra der de er.",
      already_poached_by_someone   = "Ikke snakk om! Noen pröver allerede å overtale personen.",
    },
    objective_failed         = "Du har ikke lykkes i å fullföre utfordringene.",
  },

  -- Surgery requirements
  surgery_requirements = {
    need_surgeons_ward_op   = "Du trenger to Kirurger og en Sykestue i tillegg til Operasjonssal for å gjöre kirurgiske inngrep.",
    need_surgeon_ward     = "Du trenger en Kirurg til og en Sykestue for å gjöre kirurgiske inngrep.",
  },

  -- Vomit wave
  vomit_wave = {
    started   = "Ser ut som du har et magevirus på sykehuset ditt. Om du hadde holdt det renere ville ikke dette skjedd. Kanskje du burde hatt flere Vaktmestre.",
    ended     = "Puh! Ser ut som viruset som forårsaket bölgen med oppkast er så godt som borte. Hold sykehuset ditt rent i fremtiden.",
  },

  -- Level progress
  level_progress = {
    nearly_won       = "Du har nesten fullfört dette nivået nå.",
    three_quarters_lost = "Du er nå tre fjerdedeler på vei til å tape dette nivået.",
    halfway_won     = "Du er nå omtrent halvveis på dette nivået.",
    halfway_lost     = "Du er omtrent halvveis til å tape dette nivået.",
    nearly_lost     = "Det er like för du taper dette nivået nå.",
    three_quarters_won   = "Du er nå tre fjerdedeler på vei til å fullföre dette nivået.",
    dont_kill_more_patients   = "Du har virkelig ikke råd til å drepe flere pasienter!",
    another_patient_killed   = "Å nei! Du har drept enda en pasient. Du har drept %d nå.",
    close_to_win_increase_value   = "Du er virkelig nær ved å vinne. Ök sykehusets verdi med %d.",
    financial_criteria_met   = "Du har tilfredsstilt de finansielle kriteriene for dette nivået. Hold banksaldoen din over %d, mens du passer på at sykehuset ditt drives effektivt.",
    hospital_value_enough   = "Hold verdien av ditt sykehus over %d og forsök å fölge med på de andre problemene for å vinne dette nivået.",
    another_patient_cured   = "Bra jobbet - enda en pasient kurert. Det blir den %d.",
    reputation_good_enough   = "Ok, omdömmet ditt er er godt nok for å vinne dette nivået. Hold det over %d og fiks eventuelle andre problemet for klare det.",
    cured_enough_patients   = "Du har kurert nok pasienter, men du trenger å få sykehuset ditt i bedre stand for å vinne dette nivået.",
    improve_reputation   = "Du må forbedre omdömmet ditt med %d for å ha en sjanse til å vinne dette nivået.",
  },

  -- Staff place advice
  staff_place_advice = {
    receptionists_only_at_desk     = "Resepsjonister kan kun jobbe i Resepsjoner.",
    only_psychiatrists         = "Leger kan bare jobbe i Psykiatri dersom de er kvalifiserte Psykiatere.",
    only_surgeons           = "Leger kan bare jobbe i Operasjonssalen dersom de er kvalifiserte Kirurger.",
    only_nurses_in_room       = "Det er kun Sykepleiere som kan jobbe på %s",
    only_doctors_in_room       = "%s kan kun håndteres av Leger",
    only_researchers         = "Leger kan bare jobbe på Forskningsavdelingen dersom de er kvalifiserte Forskere.",
    nurses_cannot_work_in_room     = "%s kan ikke håndteres av Sykepleiere",
    doctors_cannot_work_in_room   = "%s kan ikke håndteres av Leger",
  },

  -- Research
  research = {
    machine_improved         = "%s er forbedret av Forskningsavdelingen.",
    autopsy_discovered_rep_loss   = "Din Obduseringsautomat er blitt offentlig kjent. Forvent en negativ reaksjon fra allmennheten.",
    drug_fully_researched       = "Du har utforsket %s til 100%.",
    new_machine_researched       = "En ny %s er akkurat utviklet.",
    drug_improved           = "%s medisinen er forbedret av Forskningsavdelingen din.",
    drug_improved_1           = "%s medisinen er forbedret av Forskningsavdelingen din.", --todo: Denne er overflödig (dobbelt opp), men debug-strings-diff.txt insisterer på at denne linjen skal være her.
    new_available           = "En ny %s er tilgjengelig.",
    new_drug_researched       = "En ny medisin for å kurere %s er utviklet.",
  },

  -- Boiler issue
  boiler_issue = {
    minimum_heat   = "Der er du! Sentralfyren i kjelleren er gått i stykker. Ser ut som at personene på sykehuset ditt kommer til å fryse litt.",
    maximum_heat   = "Sentralfyren i kjelleren er löpt löpsk. Radiatorene har hengt seg opp på maksimal varme. Folk kommer til å smelte! Plasser ut flere Brusautomater.",
    resolved     = "Gode nyheter. Sentralvarmen fungerer slik som den skal nå. Temperaturen skal nå være grei både for pasientene og personalet.",
  },

  -- Competitors
  competitors = {
    staff_poached     = "En av dine ansatte har fått seg jobb på et annet sykehus.",
    hospital_opened   = "Et konkurrerende sykehus er åpnet i området av %s.",
    land_purchased     = "%s har akkurat kjöpt en tomt.",
  },

  -- Room requirements
  room_requirements = {
    research_room_need_researcher   = "Du må ansette en Lege med spesialisering innenfor Forskning for å kunne ta i bruk Forskningsavdelingen.",
    op_need_another_surgeon     = "Du trenger fremdeles en Kirurg til, for å kunne ta i bruk Operasjonssalen.",
    op_need_ward           = "Du må bygge en Sykestue for å overvåke pasienter som skal opereres.",
    reception_need_receptionist   = "Du må ansette en Resepsjonist for å ta imot pasientene.",
    psychiatry_need_psychiatrist   = "Du må ansette en Psykiater nå som du har bygget Psykiatri.",
    pharmacy_need_nurse       = "Du må ansette en Sykepleier for å drifte Apoteket.",
    ward_need_nurse         = "Du må ansette en Sykepleier som kan jobbe på denne Sengeavdelingen.",
    op_need_two_surgeons       = "Ansett to Kirurger for å utföre kirurgiske inngrep i Operasjonssalen.",
    training_room_need_consultant   = "Du må ansette en Konsulent som kan undervise i Klasserommet.",
    gps_office_need_doctor       = "Du må ansette en Lege som kan jobbe på Allmennpraksisen.",
  },

  -- Goals
  goals = {
    win = {
      money     = "Du trenger %d til for å oppnå de finansielle kriteriene på dette nivået.",
      cure       = "Kurer %d pasienter til og du har kurert nok for å fullföre dette nivået.",
      reputation   = "Sörg for å ha et omdömme på over %d for at du skal kunne fullföre nivået.",
      value     = "Sykehuset ditt må ha en verdi på over %d for at du skal kunne fullföre dette nivået.",
    },
    lose = {
      kill       = "Drep %d pasienter til for å tape dette nivået!",
    },
  },

  -- Warnings
  warnings = {
    charges_too_low       = "Du tar deg for lite betalt. Dette vil tiltrekke mange syke mennesker til sykehuset ditt, men du tjener mindre pr. pasient.",
    charges_too_high       = "Dine priser er for höye. Dette gir deg god profitt på kort sikt, men på lengre sikt vil de höye prisene skremme bort pasientene.",
    plants_thirsty         = "Du må huske på plantene dine. De er törste.",
    staff_overworked       = "Personalet ditt er meget overarbeidet. De blir ineffektive og gjör fatale feil når de er trötte.",
    queue_too_long_at_reception = "Du har for mange pasienter som venter ved Resepsjonen. Plasser ut flere Resepsjoner og ansett en Resepsjonist til.",
    queue_too_long_send_doctor   = "Köen til %s er for lang. Sörg for at det er en Lege i rommet.",
    handymen_tired         = "Dine Vaktmestere er veldig trött. Gi dem hvile nå.",
    money_low           = "Du begynner å gå tom for penger!",
    money_very_low_take_loan   = "Din bankbalanse er ganske så lav. Du kan jo alltids låne penger av banken.",
    staff_unhappy         = "Personalet ditt er i dårlig humör. Pröv å gi dem bonuser, eller bedre, bygg et Personalrom. Du kan også forandre Hvilepraksisen på Sykehuspolicy-skjermen.",
    no_patients_last_month     = "Ingen nye pasienter besökte sykehuset ditt forrige måned. Sjokkerende!",
    queues_too_long       = "Köene dine er for lange.",
    patient_stuck         = "Noen har gått seg vill. Du må organisere sykehuset ditt bedre.",
    patients_too_hot       = "Pasientene er for varme. Du må enten fjerne noen radiatorer, skru ned temperaturen, eller plassere ut flere Brusautomater.",
    doctors_tired         = "Dine Leger er veldig trötte. Gi dem hvile snarest.",
    need_toilets         = "Pasientene trenger toaletter. Bygg dem på lett tilgjengelige steder.",
    machines_falling_apart     = "Maskinene dine faller sammen. Få Vaktmestre til å fikse de snarest!",
    nobody_cured_last_month   = "Absolutt ingen ble kurert forrige måned.",
    patients_thirsty       = "Pasientene dine er törste. Du burde gi dem tilgang på brus.",
    nurses_tired         = "Sykepleierne dine er trötte. Gi dem hvile nå.",
    machine_severely_damaged   = "%s er veldig nær å bli totalskadet.",
    reception_bottleneck     = "Det er en flaskehals i Resepsjonen. Ansett en Resepsjonist til.",
    bankruptcy_imminent     = "Hallo! Du nærmer deg konkurs. Vær forsiktig!",
    receptionists_tired     = "Resepsjonistene dine er meget trötte. Gi dem hvile nå.",
    too_many_plants       = "Du har for mange planter. Dette er jo rene jungelen.",
    many_killed         = "Du har nå drept %d mennesker. Poenget er liksom å gjöre de friske, vet du.",
    need_staffroom         = "Bygg et Personalrom slik at dine ansatte kan slappe av.",
    staff_too_hot         = "Dine ansatte holder på å smelte bort. Skru ned temperaturen eller fjern noen radiatorer fra rommene deres.",
    patients_unhappy       = "Pasientene misliker sykehuset ditt. Du burde gjöre noe for å forbedre miljöet på sykehuset.",
    people_did_it_on_the_floor       = "Noen av pasientene dine klarte ikke å holde seg. Oppryddingen vil bli en stor jobb for noen.", -- Bruke ordet opprydning eller vasking?
    patients_very_thirsty       = "Pasientene dine er virkelig törste. Om du ikke setter opp noen Brusautomater snart, vil du snart se at alle går hjem for å hente cola.",
    machinery_very_damaged       = "Hastesak! Få en Vaktmester til å reparere maskinene dine öyeblikkelig! De kommer til å sprenge!",
    handymen_tired2       = "Vaktmestrene dine er helt utkjörte. Gi dem litt hvile med en gang.",
    desperate_need_for_watering       = "Du trenger sårt å ansette en Vaktmester for å stelle med plantene dine.",
    too_much_litter       = "Det er et söppelproblem. Flere Vaktmestere kan være svaret.",
    place_plants4       = "Få pasientene i bedre humör ved å sette ut litt flere planter rundt omkring.",
    change_priorities_to_plants       = "Du må endre prioriteringene for Vaktmestrene dine slik at de bruker mer tid på plantene.",
    finanical_trouble2       = "Du må få inn litt penger snart, ellers er du snart ute på söppeldynga. Du vil tape nivået om du mister %d til.",
    litter_everywhere       = "Det er söppel over alt. Sett noen Vaktmestere på saken.",
    nurses_tired2       = "Sykepleierne dine er veldig trötte. La dem hvile med en gang.",
    plants_dying       = "Plantene dine dör. De er desperate etter vannr. Få flere Vaktmestere til å jobbe med dette. Pasientene liker ikke döde planter.",
    reduce_staff_rest_threshold       = "Pröv å endre Personalets hvileterskel i Sykehuspolicy-vinduet, slik at Personalet hviler oftere. Det var bare en idé.",
    more_toilets       = "Du trenger flere Toaletter. Folk begynner å få præriehunder.", --"People are getting the turtle's head"
    hospital_is_rubbish       = "Folk sier åpenlyst at sykehuset ditt bare er söppel. För du vet ordet av det, så tar de med seg sykdommene sine til et annet sted.",
    pay_back_loan       = "Du har masse penger. Hvorfor har du ikke tenkt på å betale tilbake lånet?",
    financial_trouble3       = "Banksaldoen din ser bekymringsfull ut. Vurder å skaffe mer penger. Du er %d unna fra en katastrofe.",
    build_toilet_now       = "Bygg et Toalett nå. Folk kan ikke holde seg lenger. Ikke glis - Dette er seriöst.",
    more_benches       = "Vurder å plassere flere benker. Syke folk anser det som en fornærmelse å måtte stå oppreist.",
    many_epidemics       = "Det ser ut som du har mer enn en epidemi på samme tid. Dette kan bli en kjempekatastrofe, så du må handle raskt.",
    place_plants_to_keep_people       = "Folk stikker av. Å plassere noen planter kan kanskje overtale dem til å bli.",
    patients_thirsty2       = "Folk klager over at de er törste. Du burde plassere noen fler Brusmaskiner eller flytte de eksisterende nærmere dem.",
    people_freezing       = "Utrolig, med nåtidens sentralfyring, så klager noen av pasientene dine over at det er iskaldt. Sett ut noen radiatorer for å varme dem opp, og skru opp temperaturen.",
    patients_very_cold       = "Pasientene er veldig kalde. Pröve å skru opp temperaturen eller å plassere flere radiatorer i sykehuset.",
    build_toilets       = "Bygg et Toalett med en gang, ellers vil du se noe virkelig ubehagelig. Og forestill deg hva sykehuset ditt vil lukte da.",
    place_plants2       = "Folk går hjem. Litt flere planter ville kanskje holdt dem her lenger.",
    staff_tired       = "Dine ansatte er veldig slitne. Om du ikke lar dem få litt hvile i Personalrommet, så kan noen knekke av presset.",
    place_plants3       = "Pasientene din er utilfreds. Plasser litt flere planter for muntre dem opp.",
    staff_unhappy2       = "Personalet ditt er generelt ulykkelige. Snart vil de ha mer penger.",
    cash_low_consider_loan       = "Pengesituasjonen din er ganske dårlig. Har du tenkt på å ta opp et lån?",
    financial_trouble       = "Du er i en seriös finansiell krise. Få orden på ökonomien med en gang! Om du taper %d til, så har du kastet bort dette nivået!",
    doctors_tired2       = "Legene dine er utrolig slitne. De burde hvule umiddelbart.",
    patient_leaving       = "En pasient drar hjem. Grunnen til det? Ditt dårlig styrte, dårlig bemannet og dårlig utstyrt sykehus.",
    machinery_damaged2       = "Du må ansette en Vaktmester for å reparere maskinene dine snart.",
    patients_leaving       = "Pasientene forlater sykehuset. Forbedre sykehuset for de besökende ved å plassere planter, benker, brusmaskiner og så videre.",
    epidemic_getting_serious       = "Den smittsomme sykdommen begynner å bli alvorlig. Du må gjöre noe snart!",
    machinery_damaged       = "Reparer maskinene dine snart. Det er ikke lenge för de begynner å falle fra hverandre.",
    people_have_to_stand       = "Lidende mennesker må stå oppreist. Skaff flere sitteplasser nå.",
    build_staffroom       = "Bygg et Personalrom nå. Personalet ditt jobber for hardt og er på randen til kollaps. Kom igjen - se sammenhengen!",
    machinery_slightly_damaged       = "Sykehusmaskineriet ditt er lettere skadet. Ikke glem å få det vedlikeholdt ved en anledning.",
    patients_getting_hot       = "Pasientene er veldig varme. Pröv å skru ned temperaturen litt, eller til og med fjerne noen radiatorer.",
    machinery_deteriorating       = "Maskinene dine har nettopp begynt å bli dårligere på grunn av overforbruk. Hold et öye med dem.",
    litter_catastrophy       = "Söppelsituasjonen er bunnlös. Få et lag av Vaktmestere til å ta fatt i det nå!",
    staff_very_cold       = "Personalet klager over at det er kaldt. Skru opp temperaturen eller plasser ut flere radiatorer.",
    deal_with_epidemic_now       = "Om den epidemien ikke blir behandlet med en gang, så vil få tröbbel helt opp til örene. Få opp farten!",
    patients_really_thirsty       = "Pasientene er virkelig törste. Plasser flere brusmaskiner, eller flytt de eksisterende nærmere de störste köene.",
    some_litter       = "Vaktmestere kan bli kvitt söpla för den blir et alvorlig problem.",
    patients_annoyed       = "Folk er utrolig misfornöyd med måten du driver sykehuset ditt. Og jeg kan ikke si jeg klandrer dem. Ta deg sammen eller ta konsekvensene!",
    receptionists_tired2       = "Resepsjonistene din er veldig slitne. La dem hvile med en gang.",
    doctor_crazy_overwork = "Å nei! En av dine Doktorer har blitt gal på grunn av overarbeid. Han kan komme seg hvis du lar ham hvile umiddelbart.",
    no_desk = "Du burde bygge en resepsjon og ansette en Resepsjonist snart.",
    no_desk_1 =  "Om du vil at pasienter skal komme til sykehuset ditt bör du ansette en Resepsjonsist og bygge en resepsjon der hun kan arbeide!",
    no_desk_2 = "Bra gjort! Dette må være en verdensrekord: nesten ett år uten å få noen pasienter! Om du vil fortsette som sjef for dette sykehuset bör du ansette en Resepsjonist og bygg en respsjon der hun kan arbede!",
    no_desk_3 = "Glimrende! Nesten et år har gått og du har ikke engang en betjent resepsjon! Hvordan tror du at du skal få noen pasienter? Slutt å tulle rundt og få orden på problemet!",
    no_desk_4 = "En Resepsjonist må ha sin egen arbeidsplass for å motta pasientene som ankommer",
    no_desk_5 = "Det var på tide! Du burde se noen pasienter ankomme snart.",
    no_desk_6 = "Du har en Resepsjonist, så hva med å sette opp en resepsjon hun kan jobbe i?",
    no_desk_7 = "Du har bygd en resepsjon, så hva med å ansette en Resepsjonist? Du får ingen pasienter för du har fikset dette!",
    nurse_needs_desk_1 = "Hver Sykepleier trenger sin egen kontorpult å arbeide ved.",
    nurse_needs_desk_2 = "Sykepleieren din er glad for at du har gitt henne en pause. Om hensikten var å ha mer enn én Sykepleier arbeidende her, så må du gi dem begge en kontorpult.",
    cannot_afford = "Du har ikke nok penger på konto til å ansette denne personen!",
    cannot_afford_2 = "Du har ikke nok penger på konto til å gjöre dette kjöpet!",
    falling_1 = "Hei! Det der er ikke moro. Pass på hvor du klikker med den musa; noen kan bli skadet!",
    falling_2 = "Slutt å tulle. Hvordan ville du likt det?",
    falling_3 = "Au, det måtte gjöre vondt. Noen burde ringe etter en Lege!",
    falling_4 = "Dette er et sykehus, ikke en temapark!",
    falling_5 = "Dette er ikke et sted der du kan dytte folk over ende, de er jo syke!",
    falling_6 = "Dette er ingen bowlingbane. Syke folk bör ikke behandles slik!",
    research_screen_open_1 = "Du må bygge en forskningsavdeling för du får tilgang til forskningsvinduet.",
    research_screen_open_2 = "Forskning er deaktivert for dette nivået.",
    researcher_needs_desk_2 = "En av dine Forskere er glad for at du gir ham en pause. Om du önsker å ha flere ansatte som faktisk forsker, så må du gi dem et skrivebord hver.",
    researcher_needs_desk_1 = "En Forsker må ha et skrivebord for å kunne arbeide.",
    researcher_needs_desk_3 = "Hver Forsker må ha hvert sitt skrivebord for å kunne gjöre jobben sin.",
  },

  -- Placement info
  placement_info = {
    door_can_place       = "Du kan plassere dören her, om du vil.",
    window_can_place     = "Du kan plassere vinduet her. Det går fint.",
    door_cannot_place     = "Beklager, men du kan ikke plassere dören her.",
    object_can_place     = "Du kan plassere gjenstanden her.",
    reception_can_place   = "Du kan plassere Resepsjonen her.",
    staff_cannot_place     = "Du kan ikke plassere den ansatte her. Beklager.",
    staff_can_place     = "Du kan plassere den ansatte her. ",
    object_cannot_place   = "Hallo, du kan ikke plassere gjenstanden her.",
    room_cannot_place     = "Du kan ikke plassere rommet her.",
    room_cannot_place_2   = "Du kan ikke bygge rommet her.",
    window_cannot_place   = "Ah. Du kan faktisk ikke plassere vinduet her.",
    reception_cannot_place   = "Du kan ikke plassere Resepsjonen her.",
  },

  -- Praise
  praise = {
    many_benches   = "Pasientene har nok sitteplasser nå. Fint.",
    many_plants   = "Flott. Du har mange planter. Pasientene vil sette pris på det.",
    patients_cured   = "%d pasienter kurert.",
  },

  -- Information
  information = {
    larger_rooms           = "Större rom gjör at de ansatte föler seg viktigere, og det forbedrer deres prestasjoner.",
    extra_items           = "Ekstra gjenstander i rommene får de ansatte til å föle seg mer komfortabel og prestasjonene blir bedre.",
    epidemic             = "Du har en smittsom epidemi på sykehuset ditt. Det må du gjöre noe med nå!",
    promotion_to_doctor       = "En av dine TURNUSLEGER er nå blitt DOKTOR.",
    emergency             = "Nödstilfelle! Unna vei! Flytt dere!",
    patient_abducted         = "En av dine pasienter er blitt bortfört av romvesen.",
    first_cure             = "Bra jobbet! Du har akkurat kurert din förste pasient.",
    promotion_to_consultant     = "En av dine DOKTORER er nå blitt KONSULENT.",
    handyman_adjust         = "Du kan gjöre Vaktmestrene mer effektiv ved å justere deres prioriteringer.",
    promotion_to_specialist     = "En av dine Leger er blitt forfremmet til %s.",
    patient_leaving_too_expensive   = "En pasient forlater sykehuset ditt uten å gjöre opp for seg ved %s. Det er for dyrt.",
    vip_arrived           = "Pass på! - %s har akkurat ankommet sykehuset ditt! La alt gå på skinner nå, for å tilfredstille han.",
    epidemic_health_inspector     = "Helseministeren har nå fått med seg nyhetene om epidemien din. Du må forberede deg på et besök av ministeren ganske snart.",
    first_death           = "Du har akkurat drept din förste pasient. Hvordan föles det?",
    pay_rise             = "En av dine ansatte truer med å si opp. Velg om du vil gå med på lönnskravene eller om du vil sparke han/henne. Klikk på ikonet nede i venstre hjörne for å se hvem som truer med oppsigelse.",
    place_windows           = "Vinduer gjör rommene lysere og öker arbeidslysten til dine ansatte.",
    fax_received           = "Ikonet som akkurat poppet opp nede i venstre hjörne av skjermen, varsler deg om viktig informasjon og beslutninger du må ta.",

    initial_general_advice = {
      rats_have_arrived = "Rotter har infisert sykehuset ditt. Pröv å skyt dem med musen din.",
      autopsy_available = "Obduksjonsautomaten er nå ferdigutviklet. Med denne kan du kvitte deg med tröblete eller ikke-velkomne pasienter, og gjöre forskning ut av restene. Advarsel - Å benytte denne er svært kontroversielt.",
      first_patients_thirsty = "Flere av pasientene dine begynner å bli dehydrert. De ville satt pris på en Brusautomat.",
      research_now_available = "Du har bygd din förste Forskningsavdeling. Du har nå tilgang til Forskningsskjermen.",
      psychiatric_symbol = "Leger med spesialisering innen Psykiatri gjenkjennes med symbolet: |",
      decrease_heating = "Folk på sykehuset ditt svetter. Skru ned sentralvarmen. Dette gjöres på Områdekartet.",
      surgeon_symbol = "Leger kan utföre kirurgiske inngrep om de har symbolet: {",
      first_emergency = "Akutte pasienter har et blinkende blått lys over hodet. Behandle dem i tide, ellers dör de.",
      first_epidemic = "Du har en epidemi på sykehuset ditt! Avgjör om du vil rydde opp, eller legge deg paddeflat.",
      taking_your_staff = "Noen pröver å stjele personalet ditt. Du må kjempe for å beholde de.",
      place_radiators = "Pasientene fryser - du kan plassere flere radiatorer ved å gå inn på oversikten med gjenstander.",
      epidemic_spreading = "Det er smittefare på sykehuset. Kurer infiserte pasienter för de forlater sykehuset.",
      research_symbol = "Forskere er leger med symbolet: }",
      machine_needs_repair = "Du har utstyr som trenger reparasjon. Finn utstyret - det ryker av det - og klikk på den. Klikk deretter på Vaktmestersymbolet.",
      increase_heating = "Folk fryser. Skru opp sentralvarmen på Områdekartet.",
      first_VIP = "Du er i ferd med å ta imot ditt förste VIP-besök. Sörg for at VIP-er ikke ser noe uhygienisk eller pasienter som henger med hodet.",
    },
  },


  -- Build advice
  build_advice = {
    placing_object_blocks_door     = "Om du plasserer gjenstander der, kommer ikke folk seg til dören.",
    blueprint_would_block       = "Den blåkopien kommer til å blokkere andre rom. Pröv å endre rommets störrelse, eller flytt det en annen plass!",
    door_not_reachable         = "Folk kommer ikke til å komme seg til den dören. Tenk litt.",
    blueprint_invalid         = "Det er ikke en gyldig blåkopi.",
  },
}

-- Confirmation
confirmation = {
  quit                 = "Du har valgt å avslutte. Er du sikker på at du vil forlate spillet?",
  return_to_blueprint  = "Er du sikker på at du vil returnere til Blåkopi-modus?",
  replace_machine      = "Er du sikker på at du vil erstatte %s for $%d?", -- %s (machine name) %d (price)
  overwrite_save       = "Et spill er allerede lagret her. Er du sikker på at du vil overskrive det?",
  delete_room          = "Önsker du virkelig å fjerne dette rommet?",
  sack_staff           = "Er du sikker på at du vil si opp denne personen?",
  restart_level        = "Er du sikker på at du vil starte dette nivået på nytt?",
  maximum_screen_size = "Opplösningen du har valgt er större enn 3000 x 2000.  Större opplösninger er mulig, men det krever bedre maskinvare om det ikke skal hakke.  Önsker du å fortsette?",
  music_warning = "För du får brukt mp3-er som spillmusikk, så må du ha smpeg.dll eller tilsvarende for operativsystemet ditt. Eller vil du ikke få musikk i spillet.  Forelöpig fins det ikke noe tilsvarende for 64-bit systemer.  Önsker du å fortsette?",

}

-- Bank manager
bank_manager = {
  hospital_value    = "Sykehusets verdi",
  balance           = "Din balanse",
  current_loan      = "Nåværende lån",
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
  quite_unhappy = "Folket ditt er i dårlig humör. ",
  header = "Progresjonsrapport",
  very_unhappy = "Folket ditt er i svært dårlig humör. ",
  more_drinks_machines = "Bygg flere Brusautomater. ",
  too_cold = "Det er alt for kaldt. Sett ut noen radiatorer. ",
  too_hot = "Du bör regulere sentralvarmen. Det er alt for varmt. ",
  percentage_pop = "% befolkning",
  win_criteria = "KRITERIER FOR Å VINNE",
  free_build = "FRI BYGGING",
}

-- Newspaper headlines
newspaper = {
  -- Seven categories of funny headlines. I think each category is related
  -- to one criterion you can lose to. TODO: categorize
  { "DR SKREKK OG GRU", "SKUMMEL LEGE LEKER GUD", "DR ACULA SJOKKERER", "HVEM FALT FOR KNIVEN?", "FARLIG FORSKNING STOPPET ETTER RAZZIA" },
  { "DR ANKER", "KNUST KIRURG", "KONSULENT PÅ KJÖRET", "KIRURGISK SHOT", "KIRURG DRIKKER OPP", "KIRURGISK SPIRIT" },
  { "LEKENDE KIRURG", "DOKTOR PANTSDOWN", "DOKTOR LANGT NEDE", "GLUPSK KIRURG" },
  { "LEGE TUKLER MED BALANSEN", "ORGAN-ISERT KRIMINALITET", "BANKMESSIG BYPASS-OPERASJON", "LEGE MED KONTANTBEHOLDNING" },
  { "MEDISINSK RAID AV KISTER", "DOKTOR TÖMMER GRAVPLASS", "LIK I GARDEROBEN", "FIN DAG FOR DR DÖD", "SISTE FEILBEHANDLING", "GRAVENDE DOKTOR OPPDAGET" },
  { "LEGE SPIST OPP!", "SLAKK KVAKK", "LIVSFARLIG DIAGNOSE", "UFORSIKTIG KONSULENT", },
  { "DOKTOR BLÅSER LETTET UT", "KIRURG 'OPERERER' SEG SELV", "LEGE MED UTBLÅSNING", "DOKTOR LEGGER KABEL", "MEDISIN ER NOE DRITT" },
}

-- Letters
-- TODO
letter = {
    --original line-ends:             5          4               2    3
  [1] = {
    [1] = "Kjære %s//",
    [2] = "Fantastisk! Dette sykehuset har du driftet helt utmerket. Vi i departementet vil vite om du er interessert i å gå lös på et större prosjekt. Vi har en jobbstilling vi tror du ville passet perfekt i. Vi kan friste deg med en lönn på $%d. Tenk litt på det.//",
    [3] = "Er du interessert i å jobbe på sykehuset %s?",
  },
  [2] = {
    [1] = "Kjære %s//",
    [2] = "Veldig bra! Sykehuset ditt har hatt en fantastisk utvikling. Vi har en annen institusjon vi vil du skal ta over, om du er klar for forandringer. Du MÅ ikke ta utfordringen, men det vil nok lönne seg. Lönnen er $%d//",
    [3] = "Vil du jobbe på sykehuset %s?",
  },
  [3] = {
    [1] = "Kjære %s//",
    [2] = "Din tid på dette sykehuset har vært enormt vellykket. Vi spår en stor fremtid for deg, og önsker å tilby deg en stilling et annet sted. Lönnen vil være $%d, og vi tror du vil elske de nye utfordringene stillingen förer med seg.//",
    [3] = "Vil du ha stillingen på sykehuset %s?",
  },
  [4] = {
    [1] = "Kjære %s//",
    [2] = "Gratulerer! Vi i departementet er meget imponert over dine evner til å drifte sykehus. Du er definitivt en gullgutt i Helsedepartementet. Vi tror derimot at du foretrekker en litt töffere jobb. Du får en lönn på $%d, men det er din beslutning.//",
    [3] = "Er du interessert i å jobbe på sykehuset %s?",
  },
  [5] = {
    [1] = "Kjære %s//",
    [2] = "Hei igjen. Vi respekterer dine önsker om å ikke forlate dette sjarmerende sykehuset, men vi ber deg om å ta en ny vurdering. Vi vil tilby deg en god lönn på $%d om du er klar for å flytte til et annet sykehus, og får opp driften til et respektabelt nivå.//",
    [3] = "Er du interessert i å flytte til sykehuset %s nå?",
  },
  [6] = {
    [1] = "Kjære %s//",
    [2] = "Departementet hilser deg. Vi vet hvor glad du er blitt i denne nydelige, velorganiserte institusjonen, men vi tror du bör vurdere å fremme karrieren din nå. Du vil få en respektabel lederlönn på $%d om du bestemmer deg for å flytte. Det er verdt å tenke på det i hvertfall.//",
    [3] = "Vil du ta imot stillingen på sykehuset %s?",
  },
  [7] = {
    [1] = "Kjære %s//",
    [2] = "God dag! Helseministeren lurer på om du vil revurdere din stilling på ditt nåværende sykehus. Vi setter pris på ditt nydelige sykehus, men vi tror du vil gjöre mye for en litt mer utfordrende stilling, og en lönn på $%d.//",
    [3] = "Tar du utfordringen på sykehuset %s?",
  },
  [8] = {
    [1] = "Kjære %s//",
    [2] = "Hallo igjen. Du tok ikke vår forrige utfordring, der vi tilba deg en alle tiders stilling på et nytt sykehus, og en ökt lönn på $%d. Vi mener, derimot, at du bör revurdere beslutningen din. Vi har den perfekte jobben for deg, skjönner du.//",
    [3] = "Tar du imot stillingen på sykehuset %s? Vær så snill?",
  },
  [9] = {
    [1] = "Kjære %s//",
    [2] = "Du har nok en gang bevist at du er den beste innen helseadministrasjon. Ingen tvil! En slik betydningsfull prestasjon må belönnes, så vi önsker å tilby deg stillingen som Administrerende Direktör for Alle Sykehus. Dette er en ærefull stilling, og gir deg en lönn på hele $%d. Du får din egen Ticker-Tape parade, og folk kommer til å vise sin takknemlighet ovenfor deg, hvor enn du går.//",
    [3] = "Takk for alt du har gjort. Vi önsker deg en lang og trivelig pensjonstid.//",
    [4] = "",
  },
  [10] = {
    [1] = "Kjære %s//",
    [2] = "Gratulerer! Du har driftet alle sykehus vi har gitt deg på en utmerket måte. En slik prestasjon kvalifiserer deg for friheten til å reise rundt i verden. Du blir belönnet med en pensjon på $%d, pluss en limousin, og alt vi ber om er at du reiser fra by til by, möter dine lidenskaplige fans, og promoterer sykehusets arbeid hvor enn du måtte befinne deg.//",
    [3] = "Vi er alle stolte av deg. Det er ikke en av oss som ikke er takknemlig for ditt harde arbeid som livredder.//",
    [4] = "",
  },
  [11] = {
    [1] = "Kjære %s//",
    [2] = "Din karriere har vært eksemplarisk, og du er en stor inspirasjon for oss alle. Takk for at du har driftet så mange sykehus, og gjort det så bra i alle jobbene. Vi önsker å gi deg en livslang lönn på $%d, og alt vi ber deg om er å reise offisielt med kabriolet fra by til by, og fortelle folk hvordan du tjente så mye penger så fort.//",
    [3] = "Du er et prakteksempel for alle höyrepolitiske mennesker, og alle i verden, uten unntak, er dine kjæreste eiendeler.//",
    [4] = "",
  },
  [12] = {
    [1] = "Kjære %s//",
    [2] = "Din suksessrike karriere som den beste sykehusadministratoren siden Moses sin tid er ved veis ende. Men siden du har hatt så stor innvirkning på den koselige medisinverdenen, önsker departementet å tilby deg en lönn på $%d bare for å være til stede på våre vegne i åpne fester, sjösette skip og stille opp på show. Hele verden etterlyser deg og det ville vært god PR for oss alle!//",
    [3] = "Vær så snill å ta imot denne stillingen, det blir ikke hardt arbeid!//",
    [4] = "",
  },
}



-- Humanoid start of names
humanoid_name_starts = {
  [1] = "BJÖRN",
  [2] = "HÖY",
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
  [13] = "MÖRKE",
  [14] = "BLÅ",
  [15] = "KRIG",
  [16] = "LAT",
  [17] = "KRABBE",
  [18] = "FISK",
  [19] = "VÅT",
  [20] = "SEN",
  [21] = "GRAV",
  [22] = "BAK",
  [23] = "LAVE",
  [24] = "UT",
  [25] = "ENGE",
  [26] = "GRÖN",
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
  [12] = "BÖ",
  [13] = "GAARD",
  [14] = "GÅRD",
  [15] = "HAUG",
  [16] = "LUND",
  [17] = "LOFT",
  [18] = "VER",
  [19] = "SAND",
  [20] = "LIE",
  [21] = "VOLD",
  [22] = "STRÖM",
  [23] = "LI",
  [24] = "DALEN",
  [25] = "DAHL",
  [26] = "BAKKEN",
}


-- VIP names
vip_names = {
  health_minister = "Helseministeren",
  "Ordföreren i Greater Trumpton", -- the rest is better organized in an array.
  "Lawrence Nightingale",
  "Kong Bernard av Nederland",
  "Aung Sang Su Kyi, den Burmesisk Demokratiske Opposisjonslederen",
  "Sir Reginald Crumbly",
  "Billy Savile OBE",
  "Rådgiver Crawford Purves",
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
    cause     = "Årsak - Pasienten har sniffet ost og drukket forurenset vann.",
    symptoms   = "Symptomer - Den rammede er meget ukomfortabel.",
    cure     = "Behandling - Man stikker hull på det oppsvulmede hodet, og pumper det opp igjen til korrekt PSI med en intelligent maskin.",
  },
  hairyitis              = {
    name     = "Pelssyndrom",
    cause     = "Årsak - Fullmåne.",
    symptoms   = "Symptomer - Ökt luktesans.",
    cure    = "Behandling - En elektrosjokkmaskin fjerner håret og tetter igjen porene.",
  },
  king_complex           = {
    name     = "Rock'n'Roll syndrom",
    cause     = "Årsak - Elivs' ånd tar over kontrollen over pasientens hode",
    symptoms   = "Symptomer - Går med fargede lærsko, og spiser cheeseburgere",
    cure     = "Behandling - En Psykiater forteller pasienten hvor tåpelig han eller hun ser ut",
  },
  invisibility           = {
    name     = "Usynlighet",
    cause     = "Årsak - Bitt av en radioaktiv (og usynlig) maur",
    symptoms   = "Symptomer - Pasienten lider ikke - tvert imot! De utnytter situasjonen, og lurer familie og venner trill rundt",
    cure     = "Behandling - En fargerik kur fra apoteket gjör pasienten fullt synlig igjen",
  },
  serious_radiation      = {
    name     = "Alvorlig stråling",
    cause     = "Årsak - Har forvekslet plutonium-isotoper med tyggegummi.",
    symptoms   = "Symptomer - Pasienten föler seg meget ukomfortabel.",
    cure     = "Behandling - Pasienten blir plassert i en saneringsdusj og renset fullstendig.",
  },
  slack_tongue           = {
    name     = "Lös tunge",
    cause     = "Årsak - Kronisk overivrig i diskusjoner om såpeopera.",
    symptoms   = "Symptomer - Tungen hever seg til det femdoble.",
    cure     = "Behandling - Tungen blir plassert i en tungekutter. Hevelsen fjernes deretter hurtig, effektivt og smertefullt.",
  },
  alien_dna              = {
    name     = "Utenomjordisk DNA",
    cause     = "Årsak - Bitt av facehuggere utstyrt med intelligent utenomjordisk blod.",
    symptoms   = "Symptomer - Er under gradvis forvandling til romvesen, og har et önske om å ta over våre byer.",
    cure     = "Behandling - Alt DNA blir fjernet mekanisk, renset for utenomjordiske celler, og blir hurtig erstattet.",
  },
  fractured_bones        = {
    name     = "Benbrudd",
    cause     = "Årsak - Fall fra store höyder mot betong.",
    symptoms   = "Symptomer - Höye knaselyder og liten bevegelighet på utsatte steder.",
    cure     = "Behandling - Gipsen blir fjernet ved hjelp av en laserstyrt gipsfjerner.",
  },
  baldness               = {
    name     = "Flintskalle",
    cause     = "Årsak - Forteller lögner og dikter opp historier for å öke sin popularitet.",
    symptoms   = "Symptomer - Forlegen pasient med skinnende skalle.",
    cure     = "Behandling - Hår blir hurtig smeltet fast til pasientens hode med en smertefull hårmaskin.",
  },
  discrete_itching       = {
    name     = "Skrapesyke",
    cause     = "Årsak - Små insekter med skarpe tenner.",
    symptoms   = "Symptomer - Pasienten klör intenst, og huden flasser.",
    cure     = "Behandling - En Sykepleier gir pasienten en sirupaktig drikk som leger huden og hindrer videre klöe.",
  },
  jellyitis              = {
    name     = "Gelésyndrom",
    cause     = "Årsak - Gelatinrik diett og for mye mosjon.",
    symptoms   = "Symptomer - Meget ustödig og faller mye.",
    cure     = "Behandling - Pasienten blir presset ned i en gelétönne i et spesielt rom.",
  },
  sleeping_illness       = {
    name     = "Sövnsyke",
    cause     = "Forårsaket av overaktive sövnkjertler i munnens gane.",
    symptoms   = "Symptomer - Sterkt önske om å sove, hvor og når som helst.",
    cure     = "Behandling - En sterk dose stimulerende medisin blir delt ut av en Sykepleier.",
  },
  pregnancy              = {
    name     = "Graviditet",
    cause     = "Forårsaket av strömbrudd i urbane strök.",
    symptoms   = "Symptomer - Lei av å spise med konstant ölmage.",
    cure     = "Behandling - Spedbarnet blir fjernet med keisersnitt, blir deretter vasket og presentert for sin nye mor.",
  },   -- unused
  transparency           = {
    name     = "Gjennomsiktighet",
    cause     = "Årsak - Slikket folien på et gammelt yoghurtbeger.",
    symptoms   = "Symptomer - Kroppen blir gjennomsiktig og ekkel.",
    cure     = "Behandling - En kald og fargerik drikk fra apoteket gjör susen.",
  },
  uncommon_cold          = {
    name     = "Forkjölelse",
    cause     = "Årsak - Små snörrpartikler i luften.",
    symptoms   = "Symptomer - Rennende nese, hoste og misfarget slim fra lungene.",
    cure     = "Behandling - En real slurk hostesaft fra apoteket vil gjöre susen.",
  },
  broken_wind            = {
    name     = "Forurensende gasser",
    cause     = "Årsak - Har löpt på 3d-mölle rett etter middag.",
    symptoms   = "Symptomer - Ubehag hos folk som befinner seg rett bak pasienten.",
    cure     = "Behandling - En sterk blanding av spesielle vannatomer må svelges hurtig.",
  },
  spare_ribs             = {
    name     = "Juleribbe",
    cause     = "Årsak - Pasienten har sittet på kalde steingulv.",
    symptoms   = "Symptomer - Ubehagelig fölelse i brystet.",
    cure     = "Behandling - Ribben fjernes av to Kirurger, og leveres til pasienten i en doggybag.",
  },
  kidney_beans           = {
    name     = "Kikkerter",
    cause     = "Årsak - Pasienten har spist isbiter.",
    symptoms   = "Symptomer - Smerte og hyppige turer til toalettet.",
    cure     = "Behandling - To Kirurger fjerner de erteliknende parasittene, uten å beröre nyrene!",
  },
  broken_heart           = {
    name     = "Knust hjerte",
    cause     = "Årsak - Noen er rikere, yngre og slankere enn pasienten.",
    symptoms   = "Symptomer - Hysterisk gråtende. Blodsprengte fingertupper etter å ha revet opp feriebilder.",
    cure     = "Behandling - To Kirurger spretter opp brystet og setter deretter hjertet forsiktig sammen, mens de holder pusten.",
  },
  ruptured_nodules       = {
    name     = "Knekte nötter",
    cause     = "Årsak - Strikkhopp om vinteren.",
    symptoms   = "Symptomer - Umulig å sitte behagelig.",
    cure     = "Behandling - To kvalifiserte Kirurger må fjerne nöttene med stödige hender.",
  },
  tv_personalities       = {
    name     = "Programledersyndrom",
    cause     = "Årsak - TV-titting på dagtid.",
    symptoms   = "Symptomer - Forestiller seg at han eller hun er programleder i frokost-tv, og elsker å introdusere kjökkenseansen.",
    cure     = "Behandling - En Psykiater må overtale pasienten til å selge fjernsynet og heller kjöpe radio.",
  },
  infectious_laughter    = {
    name     = "Smittsom latter",
    cause     = "Årsak - Klassisk situasjonskomedie på TV.",
    symptoms   = "Symptomer - Ler hjelpelöst hele tiden, og repeterer stadig dårlige poeng som absolutt ikke er morsomme.",
    cure     = "Behandling - En kvalifisert Psykiater må minne pasienten på at dette faktisk er en alvorlig tilstand.",
  },
  corrugated_ankles      = {
    name      = "Böyde ankler",
    cause     = "Årsak - Busskjöring over fartsdempere.",
    symptoms   = "Symptomer - Skoene passer ikke.",
    cure     = "Behandling - En giftig blanding av urter og krydder må drikkes for å rette ut anklene.",
  },
  chronic_nosehair       = {
    name     = "Kronisk nesehår",
    cause     = "Årsak - Snöfter med forakt på folk med lavere inntekt.",
    symptoms   = "Symptomer - Så mye nesehår at en grevling kunne bodd der.",
    cure     = "Behandling - En ekkel hårfjernende drikk blir inntatt gjennom munnen. Fås på apoteket.",
  },
  third_degree_sideburns = {
    name     = "Tredjegrads koteletter",
    cause     = "Årsak - Lengter tilbake til 70-tallet.",
    symptoms   = "Symptomer - Stort hår, tettsittende klær, langt skinnskjegg og glitter.",
    cure     = "Behandling - Psykiatrisk personell må, ved hjelp av nymoderne teknikker, overbevise pasienten om at parykk er noe tull.",
  },
  fake_blood             = {
    name     = "Teaterblod",
    cause     = "Årsak - Pasienten er ofte utsatt for narrestreker.",
    symptoms   = "Symptomer - Rödt blod som dunster ved kontakt med klær.",
    cure     = "Behandling - Eneste måten å behandle dette på, er å få en Psykiater til å roe ned pasienten.",
  },
  gastric_ejections      = {
    name     = "Krydrede oppstöt",
    cause     = "Årsak - Sterkt krydret meksikansk eller indisk mat har skylden.",
    symptoms   = "Symptomer - Gulper karrikylling og tacolefser.",
    cure     = "Behandling - En Sykepleier gir pasienten en bindende indisk kumelk-blanding som forhindrer nye oppstöt.",
  },
  the_squits             = {
    name     = "Lös mage",
    cause     = "Årsak - Har spist pizzabiter som har falt bak komfyren.",
    symptoms   = "Symptomer - Æsj! Tipper du vet symptomene.",
    cure     = "Behandling - En klebrig blanding kjemikalier må drikkes for å stabilisere magen innvendig.",
  },
  iron_lungs             = {
    name     = "Jernlunger",
    cause     = "Årsak - Forurenset byluft blandet med kebabrester.",
    symptoms   = "Symptomer - Kan puste flammer og bröle höyt under vann.",
    cure     = "Behandling - To Kirurger mykner de solide lungene i operasjonssalen.",
  },
  sweaty_palms           = {
    name     = "Håndsvette",
    cause     = "Årsak - Er livredd jobbintervjuer.",
    symptoms   = "Symptomer - Å håndhilse på pasienten er som å ta tak i en våt svamp.",
    cure     = "Behandling - En Psykiater må snakke pasienten ut av denne oppdiktede lidelsen.",
  },
  heaped_piles           = {
    name     = "Hemoroider",
    cause     = "Årsak - Står i nærheten av drikkevannskjölere.",
    symptoms   = "Symptomer - Pasienten föler at han eller hun sitter på en pose med stein.",
    cure     = "Behandling - En behagelig, men meget syrlig drikk, lösner opp hemoroidene innenifra.",
  },
  gut_rot                = {
    name     = "Mageråte",
    cause     = "Årsak - Onkel Georgs miks av hostesaft og whisky.",
    symptoms   = "Symptomer - Ingen hoste, men ingen magesekk heller.",
    cure     = "Behandling - En Sykepleier skriver ut en rekke kjemikalier og gjenskaper veggen i magesekken.",
  },
  golf_stones            = {
    name     = "Golfsteiner",
    cause     = "Årsak - Utsatt for giftige gasser fra golfballer.",
    symptoms   = "Symptomer - Forvirring og kraftig skamfölelse.",
    cure     = "Behandling - Steinene fjernes kjapt og effektivt av to Kirurger.",
  },
  unexpected_swelling    = {
    name     = "Uventet hevelse",
    cause     = "Årsak - Hva som helst uventet.",
    symptoms   = "Symptomer - Hevelse.",
    cure     = "Behandling - Hevelsen må skjæres bort av to Kirurger.",
  },
  diag_scanner           = { name = "Diag Skanner", },
  diag_blood_machine     = { name = "Diag Blodmaskin", },
  diag_cardiogram        = { name = "Diag Kardio", },
  diag_x_ray             = { name = "Diag Röntgen", },
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
      accept = "Ja, jeg er klar til å håndtere dette",
      refuse = "Nei, jeg nekter å ta meg av dette",
    },
    location = "Det har skjedd en ulykke ved %s",
    num_disease = "Det er %d mennesker med %s som trenger akutt behandling.",
    num_disease_singular = "Det er 1 person med %s som trenger akutt behandling.",
    cure_possible_drug_name_efficiency = "Du har det som trengs av nödvendig utstyr og ferdigheter, og du har medisinen de trenger. Det er %s og medisinen er %d prosent effektiv.",
    cure_possible = "Du har nödvendig utstyr og de ferdigheter som trengs for å ta deg av dette.",
    cure_not_possible_build_and_employ = "Du vil måtte bygge  %s og ansette en %s",
    cure_not_possible_build = "Du mangler %s for å håndtere dette",
    cure_not_possible_employ = "Du mangler en %s for å kunne håndtere dette",
    cure_not_possible = "Du kan ikke behandle denne sykdommen for öyeblikket",
    bonus = "Om du klarer å håndtere dette nödstilfellet, vil du få en bonus på maksimalt %d. Om du feiler derimot, vil ryktet ditt få en kraftig smell.",
  free_build = "Hvis du lykkes, vil ditt omdömme vil öke. Men hvis du mislykkes, vil ditt omdömme bli alvorlig svekket!",

    locations = {
      "A.Toms Våpenkjeller",
      "Snobbeuniversitetet",
      "Buskerud Hagesenter",
      "Forskningsinstituttet For Farlige Emner",
      "Foreningen For Folkedansende Menn",
      "puben Frosk Og Kyr",
      "Hallgeir Juniors Begravelsesbyrå Og Spritbutikk",
      "Mama-Tai Krydderhus",
      "Berts Varehus For Brukt Petrokjemi",
    },
  },

  emergency_result = {
    close_text     = "Klikk for å gå ut",
    earned_money   = "Av en maksimal bonus på %d, har du tjent %d.",
    saved_people   = "Du reddet %d personer av totalt %d.",
  },

  -- Disease discovered
  disease_discovered_patient_choice = {
    choices = {
      send_home = "Send pasienten hjem.",
      wait      = "Få pasienten til å vente litt på sykehuset.",
      research  = "Send pasienten til forskningsavdelingen.",
    },
    need_to_build_and_employ = "Om du bygger %s og ansetter en %s kan du löse problemet med en gang.",
    need_to_build            = "Du må bygge %s for å håndtere dette.",
    need_to_employ           = "Ansett en %s for å hjelpe pasienten.",
    can_not_cure             = "Du kan ikke behandle denne sykdommen.",
    disease_name             = "Dine ansatte har stött på et tilfelle av %s.",
    what_to_do_question      = "Hva vil du gjöre med pasienten?",
    guessed_percentage_name  = "Teamet ditt mener de vet hva som feiler pasienten. Det er %d prosent sannsynlighet for at det er %s",
  },

  disease_discovered = {
    close_text          = "En ny sykdom er oppdaget.",
    can_cure          = "Du kan behandle denne sykdommen.",
    need_to_build_and_employ = "Om du bygger %s og ansetter en %s kan du håndtere dette.",
    need_to_build            = "Du må bygge %s for å håndtere dette.",
    need_to_employ           = "Ansett en %s for å behandle pasienter med denne sykdommen.",
    discovered_name          = "Ditt team har oppdaget et tilfelle av %s.",
  },

  -- Epidemic
  epidemic = {
    choices = {
      declare  = "Offentliggjör epidemi, betal boten og godta at ryktet ditt blir svekket.",
      cover_up = "Forsök å behandle alle infiserte pasienter för tiden renner ut, og för noen forlater sykehuset.",
    },

    disease_name             = "Dine Leger har oppdaget en svært smittsom form for %s.",
    declare_explanation_fine = "Om du offentliggjör epidemien, må du betale en bot på %d, ditt rykte får en smell, og samtlige pasienter blir vaksinert automatisk.",
    cover_up_explanation_1   = "Om du derimot forsöker å holde epidemien skjult, må du behandle samtlige infiserte pasienter för helsemyndighetene får rede på det.",
    cover_up_explanation_2   = "Om en Helseinspektör kommer på besök og finner ut at du pröver å skjule epidemien, kan han gå drastisk til verks.",
  },

  -- Epidemic result
  epidemic_result = {
    close_text = "Hurra!",

    failed = {
      part_1_name = "Gjennom forsöket på å skjule det faktum at vi sto ovenfor et smittsomt utbrudd av %s",
      part_2      = "klarte personalet ditt selvfölgelig å spre epidemien ut til alle sykehusets naboer.",
    },
    succeeded = {
      part_1_name = "Helseinspektören hörte rykter om at institusjonen din slet med et alvorlig tilfelle av %s.",
      part_2      = "Han har derimot ikke lykkes i å finne beviser som bekrefter ryktene.",
    },

    compensation_amount  = "Myndighetene har besluttet å gi deg %d i kompensasjon for skaden disse lögnene har påfört ditt gode rykte.",
    fine_amount          = "Myndighetene har erklært nasjonal unntakstilstand og bötelegger deg med %d.",
    rep_loss_fine_amount = "Avisene har nå nytt forsidestoff, og ditt rykte får en kraftig smell. I tillegg blir du bötelagt med %d.",
    hospital_evacuated   = "Helserådet har ikke annet valg enn å evakuere sykehuset ditt.",
  },

  -- VIP visit query
  vip_visit_query = {
    choices = {
      invite = "Send offisiell invitasjon til V.I.P.",
      refuse = "Avvis forespörselen fra V.I.P med dårlige unnskyldninger.",
    },

    vip_name = "%s har ytret et önske om å få besöke sykehuset ditt",
  },

  -- VIP visit result
  vip_visit_result = {
    close_text = "Takk for at du besökte sykehuset.",
    telegram          = "Telegram!",
    vip_remarked_name = "Etter sitt besök på sykehuset ditt, sa %s fölgende:",
    cash_grant = "Du er blitt tildelt %d i kontanter.",
    rep_boost  = "Ditt rykte i nærområdet har fått en opptur.",
    rep_loss   = "Ditt rykte har fått seg en smell.",

    remarks = {
    free_build = {
        [1] = "Det er et veldig fint sykehus du har der! Men det er ikke veldig vanskelig å få det til å fungerer uten pengebegrensninger.",
        [2] = "Jeg er ingen ökonom, men jeg tror jeg kunne styrt dette sykehuset også, hvis du skjönner hva jeg mener.",
        [3] = "Et meget veldrevet sykehus. Men se opp for ökonomiske nedgangstider! Å, det er sant. Du trenger ikke å bekymre deg for det.",
      },
      super = {
        "For et flott sykehus. Neste gang jeg blir alvorlig syk vil jeg hit.",
        "Dette er hva jeg kaller et sykehus.",
        "Et supert sykehus. Og jeg vet hva jeg snakker om, for jeg har vært med på en del.",
      },
      good = {
        "For et velorganisert sykehus. Takk for at jeg fikk komme hit.",
        "Hmm. Ingen dårlig medisinsk institusjon dette, det skal være visst.",
        "Jeg likte ditt sjarmerende sykehus. Forresten, noen som blir med å spise indisk?",
      },
      mediocre = {
        "Vel, jeg har sett verre. Men du burde gjöre noen forbedringer.",
        "Å kjære min tid. Dette er ikke stedet å gå om du föler deg dårlig.",
        "Et helt alminnelig sykehus, for å være ærlig. Jeg hadde forventet meg noe mer.",
      },
      bad = {
        "Hva gjör jeg her egentlig? Dette her var verre enn en firetimers opera!",
        "Dette var ekkelt. Kaller du dette et sykehus? Ser mer ut som en svinesti!",
        "Jeg er lei av å være en offentlig person og lei stinkende hull som dette! Jeg sier opp.",
      },
      very_bad = {
        "For et syn. Dette sykehuset skal jeg pröve å få lagt ned.",
        "Jeg har aldri sett på maken. For en skandale!",
        "Jeg er sjokkert. Du kan ikke kalle dette et sykehus! Jeg går og tar meg en sterk drink.",
      },
    },
  },

  -- Diagnosis failed
  diagnosis_failed = {
    choices = {
      send_home   = "Send pasienten hjem",
      take_chance = "Gjett sannsynlig behandling.",
      wait        = "Få pasienten til å vente mens du bygger flere diagnoserom.",
    },
    situation = "Vi har brukt alle våre diagnosemetoder på denne pasienten, men vi vet fremdeles ikke sikkert hva som er galt.",
    what_to_do_question = "Hva skal vi gjöre med pasienten?",
    partial_diagnosis_percentage_name = "Det er %d prosent sannsynlighet for at vi vet hvilken type %s pasienten har.",
  },
}

-- Queue window
queue_window = {
  num_in_queue       = "Kölengde",
  num_expected       = "Ventet",
  num_entered        = "Antall besök",
  max_queue_size     = "Maks str.",
}

-- Handyman window
handyman_window = {
    parcel           = "Tomt",
    all_parcels      = "Alle tomter",
}
-- Dynamic info
dynamic_info = {
  patient = {
    actions = {
      dying                       = "Döende",
      awaiting_decision           = "Venter din beslutning",
      queueing_for                = "I köen til %s", -- %s
      on_my_way_to                = "På vei til %s", -- %s
      cured                       = "Kurert!",
      fed_up                      = "Sint, forlater sykehuset",
      sent_home                   = "Sendt hjem",
      sent_to_other_hospital      = "Henvist til annet sykehus",
      no_diagnoses_available      = "Ingen flere diagnosemuligheter",
      no_treatment_available      = "Ingen behandling mulig - Jeg går hjem",
      waiting_for_diagnosis_rooms = "Venter på at du skal bygge flere diagnoserom for meg",
      waiting_for_treatment_rooms = "Venter på at du skal bygge behandlingsrom for meg",
      prices_too_high             = "Prisene er for höye - Jeg går hjem",
      epidemic_sent_home          = "Sendt hjem av inspektör",
      epidemic_contagious         = "Jeg er smittsom",
    },
    diagnosed                   = "Diagnose: %s", -- %s
    guessed_diagnosis           = "Gjettet diagnose: %s", -- %s
    diagnosis_progress          = "Diagnoseprosess",
    emergency                   = "Akutt: %s", -- %s (disease name)
  },
  vip                           = "Besökende VIP",
  health_inspector              = "Helseinspektör",

  staff = {
    psychiatrist_abbrev         = "Psyk.",
    actions = {
      waiting_for_patient         = "Venter på pasient",
      wandering                   = "Vandrer rundt omkring",
      going_to_repair             = "Skal reparere %s", -- %s (name of machine)
    },
    tiredness                   = "Tretthet",
    ability                     = "Evner", -- unused?
  },

  object = {
    strength                    = "Holdbarhet: %d", -- %d (max. uses)
    times_used                  = "Ganger brukt: %d", -- %d (times used)
    queue_size                  = "Kölengde: %d", -- %d (num of patients)
    queue_expected              = "Forventet kölengde: %d", -- %d (num of patients)
  },
}


introduction_texts = {
  level17 = {
    [1] = "Siste advarsel - hold öye med omdömmet ditt - det er dette som tiltrekker pasienter til sykehuset ditt. ",
    [2] = "Om du ikke dreper for mange mennesker og samtidig holder pasientene noenlunde i godt humör, skal du ikke ha for store problemer med dette nivået!//",
    [3] = "Nå må du klare deg selv. Lykke til med det.",
  },
  level1 = {
    [1] = "Velkommen til ditt förste sykehus!//",
    [2] = "Få stedet opp og gå ved å plassere en Resepsjon, bygge en Allmennpraksis, og ansette en Resepsjonist og en Lege. ",
    [3] = "Vent så til det begynner å skje ting.",
    [4] = "Det er smart å bygge Psykiatri og ansette en Lege med fordypning innenfor psykiatri. ",
    [5] = "Et Apotek og en Sykepleier er essensielt for å kurere pasientene dine. ",
    [6] = "Se opp for mange tilfeller av Ballonghode - et Pumperom vil fort kunne være til stor hjelp. ",
    [7] = "Du må kurere 10 pasienter og sörge for at omdömmet ditt ikke blir mindre enn 200. ",
  },
  level9 = {
    [1] = "Etter å ha fylt opp Ministerens bankkonto og finansiert Ministerens nye limousin, kan du nå konsentrere deg om å lage et omsorgsfullt og velfungerende sykehus for de trengende. ",
    [2] = "Du må forvente å stöte på en rekke problemer her.",
    [3] = "Om du har nok av rom og flinke ansatte, skal du kunne ha dette under kontroll. ",
    [4] = "Sykehuset ditt må ha en verdi på $200,000, og du må ha $400,000 i banken. ",
    [5] = "Med noe mindre får du ikke fullfört dette nivået.",
  },
  level2 = {
    [1] = "Det er et större spekter av plager i dette området. ",
    [2] = "Bygg sykehuset for å behandle flere pasienter, og planlegg en egen Forskningsavdeling. ",
    [3] = "Husk å holde institusjonen ren, og streb etter så höyt omdömme som mulig - du vil måtte håndtere plager som Lös tunge, så du trenger en Tungeklinikk. ",
    [4] = "Du kan også bygge Kardiorom for å forbedre diagnostisering. ",
    [5] = "Begge disse rommene vil måtte forskes på för du kan bygge de. Du kan også utvide sykehustomten slik at du får mer plass å boltre deg på - Bruk Områdekartet til dette. ",
    [6] = "Streb etter et omdömme på 300 og en banksaldo på $10,000, samt 40 kurerte pasienter. ",
  },
  level7 = {
    [1] = "Her vil du være under nöye gransking fra Helsedepartementet, så sörg for at kontoene dine viser at du tjener en masse penger, og at omdömmet ditt er svært bra. ",
    [2] = "Vi har ikke råd til unödvendige dödsfall - det er dårlig for forretningene. ",
    [3] = "Sörg for at personalet er i tipp-topp form, og at du har alt utstyret du trenger. ",
    [4] = "Få et omdömme på 600, pluss $200,000 i banken.",
  },
  level5 = {
    [1] = "Dette blir et travelt sykehus, siden du må håndtere et bredt spekter av tilfeller. ",
    [2] = "Legene du kan ansette kommer rett fra skolen, så det kommer til å være avgjörende for deg å bygge et Klasserom og skolere dem til et akseptabelt nivå. ",
    [3] = "Du har kun tre Konsulenter til å lære opp de uerfarne medarbeiderne, så hold dem lykkelige slik at de ikke slutter. ",
    [4] = "Merk deg også at sykehusets fundament står på en grunn full av geologiske feil. ",
    [5] = "Faren for jordskjelv er alltid tilstedeværende. ",
    [6] = "De vil forårsake betydelig skade på maskiner, og forstyrre den jevne driften av sykehuset. ",
    [7] = "Få omdömmet ditt opp til 400, og ha $50,000 i banken for å lykkes. Du må også kurere 200 pasienter.",
  },
  level4 = {
    [1] = "Hold alle pasientene dine fornöyde, ta deg av dem så effektivt som mulig og hold dödsfall til et absolutt minimum. ",
    [2] = "Ditt omdömme står på spill, så sörg for at du får det så höyt som mulig. ",
    [3] = "Ikke bekymre deg for mye over penger - det vil komme etter som ditt vitale omdömme vokser. ",
    [4] = "Du vil kunne skolere Leger til å utvide sine evner. ",
    [5] = "Du kan komme til få pasienter som synes å være mer gjennomsiktig enn de fleste. ", --sjekk english.lua er det bra nok oversettelse?
    [6] = "Oppnå et omdömme på over 500.",
  },
  level14 = {
    [1] = "Det er nok en utfordring - det helt uventede overraskelsessykehuset. ",
    [2] = "Om du klarer å gjöre en suksess ut av dette, vil du bli vinneren over alle andre vinnere. ",
    [3] = "Ikke forvent at det skal være fort gjort, ettersom det er det töffeste oppdraget du noensinne vil få. ",
    [4] = "Lykke til!",
  },
  level15 = {
    [1] = "Ok, det var den grunnleggende teknikken i å sette et sykehus sammen.//",
    [2] = "Legene dine kommer til å trenge all den hjelpen de kan få til å diagnostisere noen av disse pasientene. Du kan hjelpe dem ved å ",
    [3] = "bygg et ny diagnoserom, for eksempel Generell Diagnose.",
  },
  level8 = {
    [1] = "Det er opp til deg å sette opp det mest effektive og kostnadseffektive sykehuset som mulig. ",
    [2] = "Menneskene rundt her er ganske velstående, så flå dem for så mye grunker du bare klarer. ",
    [3] = "Husk at det å kurere mennesker er veldig fint, men du trenger virkelig pengene det bringer. ",
    [4] = "Behandle disse syke personene med Pengeutsugeren. ",
    [5] = "Samle opp en pengehaug på $300,000 for å fullföre dette nivået.",
  },
  level13 = {
    [1] = "Din enestående dyktighet som sykehusadministrator har blitt oppdaget av Hemmelig Super-avdeling fra Superhemmelige Tjenester. ",
    [2] = "De har en spesiell bonus for deg; det er et rotteinfisert sykehus som trenger en effektiv Terminator. ",
    [3] = "Du må skyte så mange rotter som mulig för Vaktmesterne rydder opp all söpla. ",
    [4] = "Tror du at du klarer oppgaven?",
  },
  level16 = {
    [1] = "Når du har diagnostisert noen av pasientene må du bygge behandlingsrom og klinikker for å kurere dem - en god idé å begynne ",
    [2] = "med Apoteket. Du trenger også en Sykepleier for å utlevere ulike legemidler fra Apoteket.",
  },
  level6 = {
    [1] = "Bruk all din kunnskap til å sette opp et velsmurt og kompetent sykehus som gjör et sunt overskudd og kan håndtere alt som den sykelige offentligheten kan kaste på det. ",  --todo - godt nok oversatt?
    [2] = "Du bör være klar over at atmosfæren rundt her er kjent for å bære med seg bakterier og infeksjoner. ",
    [3] = "Med mindre du klarer å holde institusjonen din omhyggelig ren, kan du stå overfor en rekke epidemier blant pasientene. ",
    [4] = "Pass på at du skaffer deg $150,000, og at sykehuset er verdt over $140,000.",
  },
  level12 = {
    [1] = "Du har fått moderen av alle utfordringer nå. ",
    [2] = "Departementet er imponert over din suksess, og har skaffet toppjobben for deg; de vil at du skal bygge enda et storslagent sykehus, skaffe en stor haug med penger og få et bra utrolig rykte. ",
    [3] = "Det forventes at du kjöper opp alle områdene du klarer, kurerer alle sykdommer (og da mener vi alle) og vinner alle premiene. ",
    [4] = "Tror du at du klarer det?",
    [5] = "Tjen $650,000, kurer 750 pasienter og få et omdömme på 800 for å vinne dette nivået.",
  },
  level3 = {
    [1] = "Du setter opp et sykehus i et velstående område denne gangen. ",
    [2] = "Helsedepartementet er ute etter at du klarer å sikre en sunn profitt her. ",
    [3] = "Du må få et godt rykte til å begynne med, men når sykehuset går av seg selv, så konsentrer deg om å tjene så mye penger du klarer. ",
    [4] = "Det er også en sjanse for at nödssituasjoner oppstår. ",
    [5] = "Dette er når store mengder mennesker kommer på en gang med samme tilstand. ",
    [6] = "Kurerer du alle innen tidsfristen så får du et bedre rykte, og en stor xbonus. ",
    [7] = "Sykdommer som Rock'n'Roll-syndrom kan inntreffe og du bör budsjettere for en Operasjonssal med en Sykestue i nærheten. ",
    [8] = "Tjen opp $20,000 for å klare nivået.",
  },
  level10 = {
    [1] = "I tillegg til å få bukt med alle sykdommene som dukker opp i denne skogkanten, så vil Departementet at du bruker litt tid på å konsentrere deg om effektiviteten av legemidlene dine. ",
    [2] = "Det har kommet noen klager fra Ofsick, Helsedepartementets vakthund, så for at alt skal se bra ut du må sörge for at alle legemidler er svært effektive. ", --todo (bytte ut "Ofsick" med et norskt navn).
    [3] = "Kontroller også at sykehuset i tillegg er uklanderlig. Hold dödsfallene nede. ",
    [4] = "Som et hint, så kanskje du bör holde av litt plass til en Gelétönne. ",
    [5] = "Utvikle alle dine medisiner til minst 80 prosent effektivitet, få et omdömme på 650 og gjem unna $500,000 i banken for å vinne. ",
  },
  level11 = {
    [1] = "Du har fått muligheten til å bygge det ultimate innen sykehus. ",
    [2] = "Dette er et meget prestisjefylt område, og Departementet önsker å se det best mulige sykehuset. ",
    [3] = "Vi vil forvente at du gjör store penger, har et ypperlig og godt omdömme og dekker alle mulige hendelser. ",
    [4] = "Dette er en viktig jobb. ",
    [5] = "Du må være virkelig begavet for å gjennomföre det. ",
    [6] = "Merk også at det har vært observasjoner av UFO-er i området. Sörg for at personalet er forberedt på noen uventede gjester. ",
    [7] = "Sykehuset ditt må være verdt $240,000, du må ha $500,000 i banken og ditt omdömme må være på minst 700.",
  },
  level18 = {
  },
  demo = {
    [1] = "Velkommen til demonstrasjonssykehuset!",
    [2] = "Uheldigvis inneholder demoversjonen kun dette nivået. Uansett så er det mer enn nok å gjöre her for å holde deg opptatt en stund!",
    [3] = "Du vil möte på forskjellige sykdommer som krever forskjellige rom for å kureres. Fra tid til annen kan nödstilfeller oppstå. Du må også forske frem nye rom ved hjelp av en forskningsavdeling.",
    [4] = "Målet ditt er å tjene $100,000, ha et sykehus som er verdt $70,000 og et omdömme på 700, samt kurert minst 75% av pasientene.",
    [5] = "Pass på at omdömmet ditt ikke faller under 300 og at du ikke dreper mer enn 40% av pasientene, for ellers vil du tape nivået.",
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

  hospital_open = "Sykehus åpent",
  out_of_sync   = "Spillet ute av synk",

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
