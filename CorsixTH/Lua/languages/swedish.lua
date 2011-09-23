--[[ Copyright (c) 2010 Manuel "Roujin" Wolf, Edvin "Lego3" Linge

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

Language("Svenska", "Swedish", "sv", "swe")
Inherit("english")
Inherit("original_strings", 5)
Encoding(utf8)

-------------------------------  OVERRIDE  ----------------------------------
object.reception_desk = "Reception"

-- "Psyket" means something entirely different than "Psykiatrin"
rooms_long.psychiatric = "Den psykiatriska avdelningen"
rooms_short.psychiatric = "Psykiatri"
tooltip.rooms.psychiatry = utf8 "I den psykiatriska avdelningen kureras galningar och man hjälper också till med diagnoser av andra patienter. Här behövs en läkare med psykiatrisk kompetens"
adviser.staff_place_advice.only_psychiatrists = utf8 "Läkare utan psykiatrisk examen kan inte arbeta inom psykiatrin."
adviser.room_requirements.psychiatry_need_psychiatrist = utf8 "Nu när du byggt en psykiatrisk avdelning måste du också anställa en psykiater."
room_descriptions.psych = {
  "Den psykiatriska avdelningen//",
  utf8 "Patienter som får diagnosen psykisk sjukdom måste uppsöka den psykiatriska avdelningen för att få behandling. Psykiatriker kan också ställa diagnoser, ta reda på vilken typ av sjukdom patienterna har och, i det fall det är mentalt behandla dem på den pålitliga gamla britsen.//",
  utf8 "Här behövs en läkare utbildad i psykiatri. "
}
introduction_texts.level1[4] = utf8 "En bra ide vore att bygga en psykiatrisk avdelning och anställa en läkare med psykiatrisk kompetens."

tooltip.staff_list.next_person = utf8 "Visa nästa sida"
tooltip.staff_list.prev_person = utf8 "Visa föregående sida"

-- Improve tooltips in staff window to mention hidden features
tooltip.staff_window.face = utf8 "Vederbörandes ansikte - klicka för att öppna personalhanteraren"
tooltip.staff_window.center_view = utf8 "Vänsterklicka för att komma till personen, högerklicka för att gå igenom personalen en och en"

confirmation.restart_level = utf8 "Är du säker på att du vill starta om nivån?"

-------------------------------  NEW STRINGS  -------------------------------
object.litter = utf8 "Skräp"
tooltip.objects.litter = utf8 "Skräp: Lämnat åt sitt öde eftersom patienten inte kunde hitta någon papperskorg."

tooltip.fax.close = utf8 "Stäng fönstret utan att ta bort meddelandet"
tooltip.message.button = utf8 "Vänsterklicka för att öppna meddelandet"
tooltip.message.button_dismiss = utf8 "Vänsterklicka för att öppna meddelandet, högerklicka för att ta bort det"
tooltip.casebook.cure_requirement.hire_staff = utf8 "Du behöver anställa personal att hantera behandlingen"
tooltip.casebook.cure_type.unknown = utf8 "Du vet ännu inte hur denna sjukdom botas"
tooltip.research_policy.no_research = "Det pågår ingen forskning i den här kategorin just nu"
tooltip.research_policy.research_progress = "Framsteg inför nästa upptäckt i denna kategori: %1%/%2%"

menu_options = {
  lock_windows = utf8 "  LÅS FÖNSTER  ",
  edge_scrolling = "  KANTRULLNING  ",
  settings = utf8 "  INSTÄLLNINGAR  ",
}

menu_options_game_speed = {
  pause               = "  (P) PAUSA  ",
  slowest             = utf8 "  (1) LÅNGSAMMAST  ",
  slower              = utf8 "  (2) LÅNGSAMMARE  ",
  normal              = "  (3) NORMAL  ",
  max_speed           = "  (4) MAXHASTIGHET  ",
  and_then_some_more  = utf8 "  (5) OCH SÅ LITE TILL  ",
}

menu_file.restart = "  STARTA OM  "

menu_debug = {
  jump_to_level               = utf8 "  HOPPA TILL NIVÅ  ",
  transparent_walls           = utf8 "  (X) TRANSPARENTA VÄGGAR  ",
  limit_camera                = utf8 "  BEGRÄNSA KAMERAN  ",
  disable_salary_raise        = utf8 "  STÄNG AV LÖNEÖKNINGAR  ",
  make_debug_fax              = "  (F8) SKAPA DEBUGFAX  ",
  make_debug_patient          = "  (F9) SKAPA DEBUGPATIENT  ",
  cheats                      = "  (F11) FUSK  ",
  lua_console                 = "  (F12) LUATERMINAL  ",
  calls_dispatcher            = "  ANROPSKLARERARE  ",
  dump_strings                = "  SKAPA TEXTFILER  ",
  dump_gamelog                = "  (CTRL+D) DUMPA SPELLOGG  ",
  map_overlay                 = utf8 "  KARTÖVERSIKT  ",
  sprite_viewer               = "  GRAFIKVISARE  ",
}
menu_debug_overlay = {
  none                        = "  INGET  ",
  flags                       = "  FLAGGOR  ",
  positions                   = "  KOORDINATER  ",
  heat                        = "  TEMPERATUR  ",
  byte_0_1                    = "  BYTE 0 & 1  ",
  byte_floor                  = "  BYTE GOLV  ",
  byte_n_wall                 = utf8 "  BYTE N VÄGG  ",
  byte_w_wall                 = utf8 "  BYTE W VÄGG  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  TOMT  ",
}

adviser = {
  room_forbidden_non_reachable_parts = utf8 "Rummet kan inte placeras här eftersom delar av sjukhuset då blir oåtkomliga.",
  warnings = {
    no_desk = "Det kanske börjar bli dags att bygga en reception och anställa en receptionist?",
    no_desk_1 = "Om du vill att det ska komma patienter till sjukhuset så behövs en receptionist och en reception där hon kan jobba!",
    no_desk_2 = "Fantastiskt, det måste vara ett världsrekord: nästan ett år och inte en enda patient! Om du vill fortsätta som chef på det här sjukhuset så måste du anställa en receptionist och bygga en reception som hon kan jobba i!",
  },
  cheats = {
    th_cheat = utf8 "Ojoj, nån vill fuska sig till segern!",
    crazy_on_cheat = utf8 "Åh nej!! Alla läkare har blivit galna!",
    crazy_off_cheat = utf8 "Vilken tur... läkarna har återfått förståndet.",
    roujin_on_cheat = "Roujin's utmaning aktiverad! Lycka till...",
    roujin_off_cheat = "Roujin's utmaning avaktiverad.",
    hairyitis_cheat = "Pälssyndromsfusket aktiverat!",
    hairyitis_off_cheat = "Pälssyndromsfusket avaktiverat.",
    bloaty_cheat = "Pöshuvudsfusket aktiverat!",
    bloaty_off_cheat = "Pöshuvudsfusket avaktiverat.",
  },
}

dynamic_info.patient.actions.no_gp_available = utf8 "Väntar på att du ska bygga en allmänpraktik"
dynamic_info.staff.actions.heading_for = utf8 "På väg till %s"
dynamic_info.staff.actions.fired = "Sparkad"

fax = {
  choices = {
    return_to_main_menu = utf8 "Gå till huvudmenyn",
    accept_new_level = utf8 "Gå vidare till nästa bana",
    decline_new_level = utf8 "Fortsätt spela ett tag till",
  },
  emergency = {
    num_disease_singular = "Vi har 1 person som kräver omedelbar vård med %s.",
  },
}

letter = {
  dear_player = utf8 "Käre %s",
  custom_level_completed = utf8 "Bra gjort! Du klarade alla mål på den här specialbanan!",
  return_to_main_menu = utf8 "Vill du gå tillbaka till huvudmenyn eller fortsätta spela?",
}

install = {
  title = "--------------------------------- CorsixTH Setup ---------------------------------",
  th_directory = utf8 "CorsixTH behöver en kopia av filerna från det ursprungliga spelet (eller dess demo) för att kunna köras. Använd väljaren nedan för att lokalisera mappen där Theme Hospital installerats.",
  exit = "Avsluta",
}

misc.not_yet_implemented = utf8 "(ej tillgänglig ännu)"
misc.no_heliport = utf8 "Antingen har inga sjukdomar upptäckts ännu, eller så finns det ingen helikopterplatta på den här banan."

main_menu = {
  new_game = "Nytt spel",
  custom_level = "Specialnivå",
  load_game = "Ladda spel",
  options = "Alternativ",
  exit = "Avsluta",
}

tooltip.main_menu = {
  new_game = utf8 "Starta ett helt nytt spel från början",
  custom_level = utf8 "Bygg ditt sjukhus i en specialnivå",
  load_game = "Ladda ett sparat spel",
  options = utf8 "Fixa till dina inställningar",
  exit = utf8 "Nej! Du vill väl inte sluta redan?",
}

load_game_window = {
  caption = "Ladda spel",
}

tooltip.load_game_window = {
  load_game = "Ladda %s",
  load_game_number = "Ladda spel %d",
  load_autosave = "Ladda autosparningen",
}

custom_game_window = {
  caption = "Specialbanor",
}

tooltip.custom_game_window = {
  start_game_with_name = utf8 "Ladda banan %s",
}

save_game_window = {
  caption = "Spara spel",
  new_save_game = "Ny sparfil",
}

tooltip.save_game_window = {
  save_game = utf8 "Skriv över %s",
  new_save_game = utf8 "Skriv namnet på den nya filen",
}

menu_list_window = {
  name = "Namn",
  save_date = "Senast ändrad",
  back = "Tillbaka",
}

tooltip.menu_list_window = {
  name = "Klicka här för att sortera listan efter namn",
  save_date = "Klicka här för att sortera listan efter daturm då spelen sparades",
  back = utf8 "Stäng detta fönster",
}

options_window = {
  fullscreen = utf8 "Helskärm",
  width = "Bredd",
  height = utf8 "Höjd",
  change_resolution = utf8 "Ändra upplösning",
  browse = "Bläddra...",
  new_th_directory = "Här kan du välja en ny plats här Theme Hospital installerats. Så fort du väljer den nya mappen kommer spelet att startas om.",
  back = "Tillbaka",
  cancel = "Avbryt",
}

tooltip.options_window = {
  fullscreen_button = utf8 "Klicka för att gå mellan fönster och helskärm",
  width = utf8 "Fyll i önskad skärmbredd",
  height = utf8 "Fyll i önskad skärmhöjd",
  change_resolution = utf8 "Ändra upplösning till de dimensioner ifyllda till vänster",
  language = utf8 "Ändra till %s som språk",
  original_path = "Den just nu valda mappen där Theme Hospital installerats",
  browse = "Bläddra efter en annan Theme Hospital installation",
  back = utf8 "Stäng alternativmenyn",
}

new_game_window = {
  easy = utf8 "Junior (Lätt)",
  medium = utf8 "Läkare (Medel)",
  hard = utf8 "Konsult (Svår)",
  tutorial = utf8 "Starthjälp",
  cancel = "Avbryt",
}

tooltip.new_game_window = {
  easy = utf8 "Om du känner dig ny på denna typ av spel är detta läget för dig",
  medium = utf8 "Detta är den gyllene medelvägen om du är osäker på vad du ska välja",
  hard = utf8 "Känner du för en utmaning och är van vid den här typen av spel är det här rätt val",
  tutorial = utf8 "Vill du ha lite hjälp på traven i början, tryck ner den här rutan",
  cancel = "Oj, det var ju egentligen inte meningen att starta ett nytt spel!",
}

lua_console = {
  execute_code = utf8 "Exekvera",
  close = utf8 "Stäng",
}

tooltip.lua_console = {
  textbox = utf8 "Skriv in Luakod att köra här",
  execute_code = utf8 "Kör koden du skrivit",
  close = utf8 "Stäng terminalen",
}

errors = {
  dialog_missing_graphics = utf8 "Tyvärr innehåller demon inte den här dialogrutan.",
  save_prefix = utf8 "Fel när spelet skulle sparas: ",
  load_prefix = utf8 "Fel när spelet skulle laddas: ",
  map_file_missing = utf8 "Kunde inte hitta kartfilen %s till den här nivån!",
  minimum_screen_size = utf8 "Skärmupplösningen måste vara åtminstone 640x480.",
  maximum_screen_size = utf8 "Skärmupplösningen kan inte vara större än 3000x2000.",
  unavailable_screen_size = utf8 "Skärmupplösningen du valde finns inte i fullskärmsläge.",
}

confirmation = {
  needs_restart = utf8 "Att ändra denna inställning kräver en omstart av spelet. Osparad data kommer att gå förlorad. Är du säker på att du vill göra detta?",
  abort_edit_room = utf8 "Du håller på att bygga eller ändra ett rum. Om alla obligatoriska föremål är placerade kommer rummet att färdigställas som det är, annars tas det bort. Fortsätta?",
}

information = {
  custom_game = utf8 "Välkommen till CorsixTH. Ha nu riktigt kul med den här specialbanan!",
  cannot_restart = utf8 "Tyvärr sparades detta spel innan funktionen att starta om hade implementerats.",
  level_lost = {
    utf8 "Attans! Du förlorade. Bättre lycka nästa gång!",
    utf8 "Anledning till att du förlorade:",
    reputation = utf8 "Ditt anseende föll under %d.",
    balance = utf8 "Din bankbalans sjönk till under %d.",
    percentage_killed = utf8 "Du dödade mer än %d procent av dina patienter.",
  },
}

tooltip.information = {
  close = utf8 "Stäng informationsrutan",
}

totd_window = {
  tips = {
    utf8 "Alla sjukhus behöver en reception och en allmänpraktik för att fungera. Sedan beror allt på vad det är för patienter som besöker sjukhuset. Ett hett tips är att börja med ett apotek.",
    utf8 "Maskiner som till exempel pumpen behöver underhåll då och då. Anställ en vaktmästare eller två för att reparera dem, annars riskeras personalens och patienternas hälsa.",
    utf8 "Efter ett tag kommer din personal att bli trött. Se till att göra ett personalrum så att de kan slappna av lite.",
    utf8 "För att inte dina anställda och alla patienter ska bli arga gäller det att ha tillräckligt med element utplacerade lite här och där. Använd stadskartan för att hitta ställen som behöver mer värme.",
    utf8 "En läkares kompetensnivå påverkar kvaliteten och hastigheten på hans diagnoser ganska mycket. Sätt en riktigt kompetent läkare i allmänpraktiken så behövs det inte så många andra diagnosrum.",
    utf8 "Juniorer och läkare kan höja sin kompetensnivå genom att gå i träning hos en konsult i utbildningsrummet. Om konsulten har någon färdighet (kirurg, psykiater eller forskare) kommer han också att lära ut detta till sina elever.",
    utf8 "Har du testat att slå numret till SOS Alarm på faxen? Se till att ljudet är påslaget...",
    utf8 "Det går att göra vissa inställningar som till exempel upplösning och språk i alternativmenyn som finns både i huvudmenyn och inuti spelet.",
    utf8 "Hittar du en massa text på engelska i spelet? Hjälp oss översätta färdigt till Svenska!",
    utf8 "Teamet bakom CorsixTH söker förstärkning! Vill du koda, översätta eller skapa grafik till spelet? Kontakta oss i forumet, på mejllistan eller i IRC-kanalen (corsix-th at freenode).",
    utf8 "Om du hittar en bugg, rapportera den gärna i vår bugghanterare på adressen th-issues.corsix.org.",
    utf8 "Varje bana har vissa krav som ska uppfyllas innan du kan gå vidare till nästa. Kolla statusfönstret för att se hur nära målen du är.",
    utf8 "Om du vill ändra eller ta bort ett existerande rum kan du göra det med hjälp av ändra rum-knappen i panelen längst ner (saxen).",
    utf8 "Om du ur högen av patienter vill ta reda på vilka som köar till ett visst rum är det bara att föra muspekaren över rummet.",
    utf8 "Klicka på dörren till ett rum för att se kön till det. Sedan går det att genomföra finlir som att ändra ordning eller skicka en patient till ett annat likadant rum.",
    utf8 "Olycklig personal frågar efter löneökning ofta. Se till att de jobbar i en behaglig miljö så händer det inte.",
    utf8 "Patienter blir törstiga när de väntar på sin tur, ännu mer om du sätter upp värmen! Sätt ut läskautomater på strategiska platser för lite extra inkomst.",
    utf8 "Det går att avbryta diagnosprocessen för en patient i förtid och gissa behandling om sjukdomen är känd. Notera att detta ökar risken för felbehandling - och dödsfall.",
    utf8 "Akutfall kan vara ett smidigt sätt att få in lite extra stålar, såvida du har kapacitet att hantera alla patienter i tid vill säga.",
  },
  previous = utf8 "Föregående tips",
  next = utf8 "Nästa tips",
}

tooltip.totd_window = {
  previous = utf8 "Visa föregående tips",
  next = utf8 "Visa nästa tips",
}

debug_patient_window = {
  caption = "Debug Patient",
}

cheats_window = {
  caption = "Fusk",
  warning = utf8 "Varning: Du kommer inte att få bonuspoäng på slutet av nivån om du fuskar!",
  cheated = {
    no = "Har fuskat: Nej",
    yes = "Har fuskat: Ja",
  },
  cheats = {
    money = "Pengar",
    all_research = "All forskning",
    emergency = "Skapa akutfall",
    vip = "Skapa VIP",
    create_patient = "Skapa patient",
    end_month = utf8 "Månadsslut",
    end_year = utf8 "Hoppa till nyår",
    lose_level = utf8 "Förlora nivå",
    win_level = utf8 "Vinn nivå",
  },
  close = utf8 "Stäng",
}

tooltip.cheats_window = {
  close = utf8 "Stäng fuskfönstret",
  cheats = {
    money = utf8 "Ökar din balans med 10 000.",
    all_research = utf8 "Färdigställer all forskning.",
    emergency = "Skapar ett akutfall.",
    vip = "Skapar en Mycket Viktig Person (VIP)",
    create_patient = "Skapar en patient vid kanten av kartan.",
    end_month = utf8 "Hoppar till slutet av månaden.",
    end_year = utf8 "Hoppar till slutet av året.",
    lose_level = utf8 "Förlora nuvarande nivå.",
    win_level = utf8 "Vinn nuvarande nivå.",
  }
}

introduction_texts = {
  demo = {
    utf8 "Välkommen till demosjukhuset!",
    utf8 "Tyvärr innehåller demon bara denna nivå (förutom specialnivåer). Ändå finns det garanterat tillräckligt att göra ett tag framöver!",
    utf8 "Du kommer att råka ut för diverse sjukdomar som kräver olika rum för att botas. Ibland kan olyckor hända, så att det kommer akutfall till sjukhuset. Dessutom behöver du forska för att upptäcka fler rum.",
    utf8 "Målet är att tjäna $100,000, ha ett sjukhusvärde av $70,000 och 700 i anseende, samtidigt som du botar minst 75% av patienterna.",
    utf8 "Se till att ditt anseende inte sjunker under 300 och att du inte dödar mer än 40% av dina patienter, annars förlorar du.",
    "Lycka till!",
  },
}

calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = "%d anrop; %d tilldelade",
  staff = "%s - %s",
  watering = "Vattnar @ %d,%d",
  repair = "Reparera %s",
  close = utf8 "Stäng",
}

tooltip.calls_dispatcher = {
  task = utf8 "Lista över uppgifter - klicka på en uppgift för att öppna tilldelad personals fönster och flytta vyn till det ställe där uppgiften finns.",
  assigned = utf8 "Denna ruta är markerad om någon har fått uppgiften tilldelad till sig.",
  close = utf8 "Stäng anropsklarerardialogen",
}
