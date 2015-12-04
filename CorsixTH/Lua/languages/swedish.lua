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
tooltip.rooms.psychiatry = "I den psykiatriska avdelningen kureras galningar och man hjälper också till med diagnoser av andra patienter. Här behövs en läkare med psykiatrisk kompetens"
adviser.staff_place_advice.only_psychiatrists = "Läkare utan psykiatrisk examen kan inte arbeta inom psykiatrin."
adviser.room_requirements.psychiatry_need_psychiatrist = "Nu när du byggt en psykiatrisk avdelning måste du också anställa en psykiater."
room_descriptions.psych = {
  "Den psykiatriska avdelningen//",
  "Patienter som får diagnosen psykisk sjukdom måste uppsöka den psykiatriska avdelningen för att få behandling. Psykiatriker kan också ställa diagnoser, ta reda på vilken typ av sjukdom patienterna har och, i det fall det är mentalt behandla dem på den pålitliga gamla britsen.//",
  "Här behövs en läkare utbildad i psykiatri. "
}
introduction_texts.level1 = "Välkommen till ditt första sjukhus!//Sätt igång genom att placera ut en reception och bygga en allmänpraktik, anställ en receptionist och en läkare. " ..
                            "Vänta därefter på att jobben ska trilla in. En bra idé vore att bygga en psykmottagning och anställa en läkare med psykiatrisk kompetens. " ..
                            "Ett apotek och en syster behövs också för att du ska kunna bota dina patienter. Se upp för svåra fall av pöshuvud - ett pumprum behövs för att greja dessa. " ..
                            "Försök bota 10 personer och se till att ditt anseende inte sjunker under 200."

tooltip.staff_list.next_person = "Visa nästa sida"
tooltip.staff_list.prev_person = "Visa föregående sida"

-- Improve tooltips in staff window to mention hidden features
tooltip.staff_window.face = "Vederbörandes ansikte - klicka för att öppna personalhanteraren"
tooltip.staff_window.center_view = "Vänsterklicka för att komma till personen, högerklicka för att gå igenom personalen en och en"

confirmation.restart_level = "Är du säker på att du vill starta om nivån?"

-- In English the squits becomes the the squits, see issue 1646. In Swedish it stays the same, but it
-- still needs to be defined.
adviser.research.drug_improved_1 = "Medicinen mot %s har förbättrats av din forskaravdelning."
-------------------------------  NEW STRINGS  -------------------------------
object.litter = "Skräp"
tooltip.objects.litter = "Skräp: Lämnat åt sitt öde eftersom patienten inte kunde hitta någon papperskorg."

tooltip.fax.close = "Stäng fönstret utan att ta bort meddelandet"
tooltip.message.button = "Vänsterklicka för att öppna meddelandet"
tooltip.message.button_dismiss = "Vänsterklicka för att öppna meddelandet, högerklicka för att ta bort det"
tooltip.casebook.cure_requirement.hire_staff = "Du behöver anställa personal att hantera behandlingen"
tooltip.casebook.cure_type.unknown = "Du vet ännu inte hur denna sjukdom botas"
tooltip.research_policy.no_research = "Det pågår ingen forskning i den här kategorin just nu"
tooltip.research_policy.research_progress = "Framsteg inför nästa upptäckt i denna kategori: %1%/%2%"

handyman_window.all_parcels = "Alla tomter"
handyman_window.parcel = "Tomt"

tooltip.handyman_window.parcel_select = "Tomten där vaktmästaren accepterar uppdrag. Klicka för att ändra"
tooltip.new_game_window.player_name = "Skriv in det namn du vill kallas i spelet"
new_game_window.player_name = "Namn"

menu_options = {
  lock_windows = "  LÅS FÖNSTER  ",
  edge_scrolling = "  KANTRULLNING  ",
  adviser_disabled = "  MEDHJÄLPARE  ",
  warmth_colors = "  VÄRMEFÄRGER  ",
  wage_increase = "  LÖNFÖRFRÅGNINGAR  ",
  twentyfour_hour_clock = "  24-TIMMARSKLOCKA  "
}

menu_options_game_speed = {
  pause               = "  (P) PAUSA  ",
  slowest             = "  (1) LÅNGSAMMAST  ",
  slower              = "  (2) LÅNGSAMMARE  ",
  normal              = "  (3) NORMAL  ",
  max_speed           = "  (4) MAXHASTIGHET  ",
  and_then_some_more  = "  (5) OCH SÅ LITE TILL  ",
}

menu_options_warmth_colors = {
  choice_1 = "  RÖD  ",
  choice_2 = "  BLÅ GRÖN RÖD  ",
  choice_3 = "  GUL ORANGE RÖD  ",
}

menu_options_wage_increase = {
  grant = "    BEVIJLA ",
  deny =  "    NEKA ",
}

-- Add F-keys to entries in charts menu (except briefing), also town_map was added.
menu_charts = {
  bank_manager  = "  (F1) BANKKAMRER  ",
  statement     = "  (F2) KONTOUTDRAG  ",
  staff_listing = "  (F3) PERSONALLEDNING  ",
  town_map      = "  (F4) STADSKARTA  ",
  casebook      = "  (F5) MEDICINJOURNAL  ",
  research      = "  (F6) FORSKNING  ",
  status        = "  (F7) STATUS  ",
  graphs        = "  (F8) GRAFER  ",
  policy        = "  (F9) POLICY  ",
}

menu_file.restart = "  STARTA OM  "

menu_debug = {
  jump_to_level               = "  HOPPA TILL NIVÅ  ",
  transparent_walls           = "  (X) TRANSPARENTA VÄGGAR  ",
  limit_camera                = "  BEGRÄNSA KAMERAN  ",
  disable_salary_raise        = "  STÄNG AV LÖNEÖKNINGAR  ",
  make_debug_fax              = "  SKAPA DEBUGFAX  ",
  make_debug_patient          = "  SKAPA DEBUGPATIENT  ",
  cheats                      = "  (F11) FUSK  ",
  lua_console                 = "  (F12) LUATERMINAL  ",
  debug_script                = "  (SHIFT + D) KÖR DEBUGSKRIPT  ",
  calls_dispatcher            = "  ANROPSKLARERARE  ",
  dump_strings                = "  SKAPA TEXTFILER  ",
  dump_gamelog                = "  (CTRL+D) DUMPA SPELLOGG  ",
  map_overlay                 = "  KARTÖVERSIKT  ",
  sprite_viewer               = "  GRAFIKVISARE  ",
}
menu_debug_overlay = {
  none                        = "  INGET  ",
  flags                       = "  FLAGGOR  ",
  positions                   = "  KOORDINATER  ",
  heat                        = "  TEMPERATUR  ",
  byte_0_1                    = "  BYTE 0 & 1  ",
  byte_floor                  = "  BYTE GOLV  ",
  byte_n_wall                 = "  BYTE N VÄGG  ",
  byte_w_wall                 = "  BYTE W VÄGG  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  TOMT  ",
}

adviser = {
  room_forbidden_non_reachable_parts = "Rummet kan inte placeras här eftersom delar av sjukhuset då blir oåtkomliga.",
  warnings = {
    no_desk = "Det kanske börjar bli dags att bygga en reception och anställa en receptionist?",
    no_desk_1 = "Om du vill att det ska komma patienter till sjukhuset så behövs en receptionist och en reception där hon kan jobba!",
    no_desk_2 = "Snyggt jobbat, det måste vara ett världsrekord: nästan ett år och inte en enda patient! Om du vill fortsätta som chef på det här sjukhuset så måste du anställa en receptionist och bygga en reception som hon kan jobba i!",
    no_desk_3 = "Helt otroligt, nästan ett år och du har fortfarande ingen bemannad reception! Tror du det kommer några patienter då? Sluta leka omkring och fixa till det här nu!",
    no_desk_4 = "En receptionist behöver ha en egen disk som hon kan hälsa patienterna välkomna vid",
    no_desk_5 = "Det var på tiden, nu borde det snart börja dyka upp patienter!",
    no_desk_6 = "Du har en receptionist, det kanske är dags att bygga en reception som hon kan arbeta vid?",
    no_desk_7 = "Nu har du en reception, vad sägs om att anlita en receptionist också? Det lär inte komma några patienter förrän du gjort det!",
    cannot_afford = "Du har inte tillräckligt med pengar på banken för att anställa den personen!",
    cannot_afford_2 = "du har inte tillräckligt med pengar på banken för att genomföra det köpet!",
    falling_1 = "Nämen! Det där inte kul, om du inte ser dig för var du klickar så kan någon skada sig!",
    falling_2 = "Sluta strula omkring, hur tror du det känns?",
    falling_3 = "Ajaj, det måste ha gjort ont. Ring en läkare!",
    falling_4 = "Det här är ett sjukhus, inte ett nöjesfält!",
    falling_5 = "Jag tror inte det här är rätt arena att knuffa omkull folk på, det är sjuka vet du!",
    falling_6 = "Det här är inte en bowlinghall, sjuka människor ska inte behandlas så!",
    research_screen_open_1 = "Du behöver bygga en forskningsavdelning innan du får tillgång till forskningsskärmen.",
    research_screen_open_2 = "På den här nivån finns det ingen möjlighet till forskning.",
    researcher_needs_desk_1 = "Varje forskare behöver ett skrivbord att jobba vid.",
    researcher_needs_desk_2 = "Din forskare är nöjd över att få en välbehövlig paus. Om du ville ha flera forskare aktiva samtidigt så behöver de få var sitt skrivbord.",
    researcher_needs_desk_3 = "En forskare behöver alltid ett skrivbord.",
    nurse_needs_desk_1 = "Varje sköterska behöver ett eget skrivbord.",
    nurse_needs_desk_2 = "Din sköterska är glad att få en paus. Du kanske ville ha flera personer att jobba på avdelningen? Då behöver de var sitt skrivbord.",
  },
  cheats = {
    th_cheat = "Ojoj, nån vill fuska sig till segern!",
    roujin_on_cheat = "Roujin's utmaning aktiverad! Lycka till...",
    roujin_off_cheat = "Roujin's utmaning avaktiverad.",
  },
}

dynamic_info.patient.actions.no_gp_available = "Väntar på att du ska bygga en allmänpraktik"
dynamic_info.staff.actions.heading_for = "På väg till %s"
dynamic_info.staff.actions.fired = "Sparkad"
dynamic_info.patient.actions.epidemic_vaccinated = "Jag smittar inte längre"

progress_report.free_build = "FRITT BYGGANDE"

fax = {
  choices = {
    return_to_main_menu = "Gå till huvudmenyn",
    accept_new_level = "Gå vidare till nästa bana",
    decline_new_level = "Fortsätt spela ett tag till",
  },
  emergency = {
    num_disease_singular = "Vi har 1 person som kräver omedelbar vård med %s.",
    free_build = "Om du lyckas ökar ditt anseende, men om du misslyckas kommer ditt anseende att få en rejäl känga."
  },
  vip_visit_result = {
    remarks = {
      free_build = {
        "Det var ju ett trevligt sjukhus du har! Inte så svårt att få det så bra utan begränsande budget dock, eller hur?",
        "Jag är ingen ekonom, men jag tror att jag också hade kunnat driva det här sjukhuset, om du förstår vad jag menar...",
        "Ett mycket väld fungerande sjukhus må jag säga. Akta lågkonjunkturen bara! Just det... du behöver inte oroa dig över pengar nä.",
      }
    }
  }
}

letter = {
  dear_player = "Käre %s",
  custom_level_completed = "Bra gjort! Du klarade alla mål på den här specialbanan!",
  return_to_main_menu = "Vill du gå tillbaka till huvudmenyn eller fortsätta spela?",
}

install = {
  title = "--------------------------------- CorsixTH Setup ---------------------------------",
  th_directory = "CorsixTH behöver en kopia av filerna från det ursprungliga spelet (eller dess demo) för att kunna köras. Använd väljaren nedan för att lokalisera mappen där Theme Hospital installerats.",
  ok = "OK",
  exit = "Avsluta",
  cancel = "Avbryt",
}

misc.not_yet_implemented = "(ej tillgänglig ännu)"
misc.no_heliport = "Antingen har inga sjukdomar upptäckts ännu, eller så finns det ingen helikopterplatta på den här banan."

main_menu = {
  new_game = "Kampanj",
  custom_level = "Enskild nivå",
  continue = "Fortsätt spel",
  load_game = "Ladda spel",
  options = "Alternativ",
  savegame_version = "Sparningsversion: ",
  version = "Version: ",
  exit = "Avsluta",
}

tooltip.main_menu = {
  new_game = "Starta bana ett i kampanjen",
  custom_level = "Bygg ditt sjukhus på en valfri nivå",
  load_game = "Ladda ett sparat spel",
  options = "Fixa till dina inställningar",
  exit = "Nej! Du vill väl inte sluta redan?",
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
  free_build = "Bygg fritt",
}

tooltip.custom_game_window = {
  start_game_with_name = "Ladda banan %s",
  free_build = "Bocka för den här rutan om du vill spela utan pengar och vinst- och förlustkriterier",
}

save_game_window = {
  caption = "Spara spel",
  new_save_game = "Ny sparfil",
}

tooltip.save_game_window = {
  save_game = "Skriv över %s",
  new_save_game = "Skriv namnet på den nya filen",
}

menu_list_window = {
  name = "Namn",
  save_date = "Senast ändrad",
  back = "Tillbaka",
}

tooltip.menu_list_window = {
  name = "Klicka här för att sortera listan efter namn",
  save_date = "Klicka här för att sortera listan efter daturm då spelen sparades",
  back = "Stäng detta fönster",
}

options_window = {
  caption = "Alternativ",
  option_on = "På",
  option_off = "Av",
  fullscreen = "Helskärm",
  resolution = "Upplösning",
  custom_resolution = "Anpassad...",
  width = "Bredd",
  height = "Höjd",
  audio = "Globalt ljud",
  customise = "Anpassa",
  folder = "Mappar",
  language = "Spelspråk",
  apply = "Tillämpa",
  cancel = "Avbryt",
  back = "Tillbaka",
}

tooltip.options_window = {
  fullscreen = "Om spelet ska köras i fullskärmsläge eller fönsterläge",
  fullscreen_button = "Klicka för att gå mellan fönster och helskärm",
  resolution = "Upplösning spelet ska köras i",
  select_resolution = "Välj en ny upplösning",
  width = "Fyll i önskad skärmbredd",
  height = "Fyll i önskad skärmhöjd",
  apply = "Tillämpa den valda upplösningen",
  cancel = "Återvänd utan att ändra upplösning",
  audio_button = "Stäng av eller sätt på allt ljud i spelet",
  audio_toggle = "Slå av eller på",
  customise_button = "Fler inställningar som kan ändras för att anpassa din spelupplevelse",
  folder_button = "Mappinställningar",
  language = "Text i spelet kommer att visas på det här språket",
  select_language = "Väljs spelspråk",
  language_dropdown_item = "Ändra till %s som språk",
  back = "Stäng alternativmenyn",
}

customise_window = {
  caption = "Extra inställningar",
  option_on = "På",
  option_off = "Av",
  back = "Tillbaka",
  movies = "Global filmkontroll",
  intro = "Spela introfilmen",
  paused = "Bygg i pausläge",
  volume = "Tangent: volym ner",
  aliens = "Utomjordingar",
  fractured_bones = "Krossad patient",
  average_contents = "Genomsnittsinnehåll",
}

tooltip.customise_window = {
  movies = "Välj om filmer ska spelas överhuvudtaget",
  intro = "Skippa introfilmen när du startar spelet. Global filmkontroll måste vara påslagen om du spela introfilmen varje gång du laddar CorsixTH",
  paused = "I Theme Hospital fick spelaren bara använda verktygsfältet längst upp när spelet var pausat. Så är det i CorsixTH också såvida du inte aktiverar funktionen att bygga även när spelet är pausat här",
  volume = "Om du råkat ut för att tangenten som sänker volymen även öppnar medicinjournalen, slå på det här alternativet för att ändra snabbkommando till medicinjournalen till Shift + C",
  aliens = "Eftersom det inte finns ordentliga animeringar har vi gjort så att patienter med utomjordiskt DNA endast dyker upp som akutfall. Stäng av det här för att kunna få utomjordiskt DNA-fall även som vanliga besök",
  fractured_bones = "På grund av en dålig animering har vi stängt av kvinnliga patienter med frakturer (Krossad patient). Stäng av det här, så kommer det att dyka upp även kvinnor med den åkomman",
  average_contents = "Om du vill att spelet ska komma ihåg vilka extra föremål du normalt sett brukar handla till nya rum, slå på detta alternativ",
  back = "Stäng den här menyn och gå tillbaka till Alternativmenyn",
}

folders_window = {
  caption = "Mappinställningar",
  data_label = "TH Data",
  font_label = "Typsnitt",
  music_label = "MP3",
  savegames_label = "Sparningar",
  screenshots_label = "Skärmbilder",
  -- next four are the captions for the browser window, which are called from the folder setting menu
  new_th_location = "Här kan du välja en ny sökväg där Theme Hospital ligger. Så fort du väljer en ny mapp kommer spelet att startas om!",
  savegames_location = "Välj var sparade spel ska läggas.",
  music_location = "Välj en mapp med musik i för att spela den i spelet.",
  screenshots_location = "Välj vilken mapp du vill spara skärmbilder till.",
  back  = "Tillbaka",
}

tooltip.folders_window = {
  browse = "Bläddra efter mappsökväg",
  data_location = "Mapp där originalspelet Theme Hospital finns. Krävs för att spela CorsixTH",
  font_location = "Sökväg till en typsnittsfil som kan visa Unicode-tecken som krävs för ditt språk. Om detta inte är specificerat kommer du inte att kunna välja sådana språk, till exempel ryska och kinesiska",
  savegames_location = "Som standard läggs sparade spel i en mapp som ligger bredvid konfigurationsfilen. Om det inte fungerar kan du välja en egen här",
  screenshots_location = "Skärmbilder sparas som standard i en mapp bredvid konfigurationsfilen. Här kan du välja en annan mapp istället",
  music_location = "Välj en sökväg där du har mp3-filer. Mappen måste redan finnas",
  browse_data = "Bläddra efter en ny sökväg till Theme Hospital  ( nuvarande sökväg: %1% )",
  browse_font = "Bläddra efter en annan typsnittsfil  ( nuvarande sökväg:: %1% )",
  browse_saves = "Bläddra efter en annan mapp att lägga sparade spel i  ( nuvarande sökväg:: %1% ) ",
  browse_screenshots = "Bläddra efter en annan mapp för skärmbilder  ( nuvarande sökväg:: %1% ) ",
  browse_music = "Bläddra efter en annan mapp med musik  ( nuvarande sökväg:: %1% ) ",
  no_font_specified = "Ingen typsnittsfil vald än!",
  not_specified = "Ingen sökväg vald än!",
  default = "Standardsökväg",
  reset_to_default = "Återställ mappen till standardsökvägen",
  back  = "Stäng den här dialogen och återgå till alternativmenyn",
}

font_location_window = {
  caption = "Välj typsnitt (%1%)",
}

new_game_window = {
  caption = "Kampanj",
  option_on = "På",
  option_off = "Av",
  difficulty = "Svårighetsgrad",
  easy = "Junior (Lätt)",
  medium = "Läkare (Medel)",
  hard = "Konsult (Svår)",
  tutorial = "Starthjälp",
  start = "Börja",
  cancel = "Avbryt",
}

tooltip.new_game_window = {
  easy = "Om du känner dig ny på denna typ av spel är detta läget för dig",
  medium = "Detta är den gyllene medelvägen om du är osäker på vad du ska välja",
  hard = "Känner du för en utmaning och är van vid den här typen av spel är det här rätt val",
  difficulty = "Välj vilken svårighetsgrad spelet ska ha",
  start = "Börja spela med dessa inställningar",
  tutorial = "Vill du ha lite hjälp på traven i början, tryck ner den här rutan",
  cancel = "Oj, det var ju egentligen inte meningen att starta ett nytt spel!",
}

lua_console = {
  execute_code = "Exekvera",
  close = "Stäng",
}

tooltip.lua_console = {
  textbox = "Skriv in Luakod att köra här",
  execute_code = "Kör koden du skrivit",
  close = "Stäng terminalen",
}

errors = {
  dialog_missing_graphics = "Tyvärr innehåller demon inte den här dialogrutan.",
  save_prefix = "Fel när spelet skulle sparas: ",
  load_prefix = "Fel när spelet skulle laddas: ",
  no_games_to_contine = "Det finns inga sparade spel.",
  load_quick_save = "Fel, kan inte ladda en snabbsparning eftersom det inte finns någon. Men oroa dig inte, nu har vi skapat en åt dig!",
  map_file_missing = "Kunde inte hitta kartfilen %s till den här nivån!",
  minimum_screen_size = "Skärmupplösningen måste vara åtminstone 640x480.",
  unavailable_screen_size = "Skärmupplösningen du valde finns inte i fullskärmsläge.",
  alien_dna = "NOTERA: Det finns inga animeringar för patienter med utomjordiskt DNA när de sitter ner, öppnar dörrar osv. Precis som i Theme Hospital gör de därför det i mänsklig skepnad. Dessa patienter anländer som vanligt endast om nivån du spelar definierat att sjukdomen ska finnas",
  fractured_bones = "NOTERA: Animeringen för kvinnliga Krossade patienter är inte perfekt",
}

confirmation = {
  needs_restart = "Att ändra denna inställning kräver en omstart av spelet. Osparad data kommer att gå förlorad. Är du säker på att du vill göra detta?",
  abort_edit_room = "Du håller på att bygga eller ändra ett rum. Om alla obligatoriska föremål är placerade kommer rummet att färdigställas som det är, annars tas det bort. Fortsätta?",
  maximum_screen_size = "Upplösningen du valt är större än 3000 x 2000. Större upplösningar är möjliga, men kräver bättre hårdvara. Är du säker på att du vill fortsätta?",
  music_warning = "Notera: När du väljer att använda mp3-filer som spelmusik behövs smpeg.dll eller motsvarande för ditt operativsystem, annars blir det ingen musik i spelet. Vill du fortsätta?",
}

information = {
  custom_game = "Välkommen till CorsixTH. Ha nu riktigt kul med den här specialbanan!",
  no_custom_game_in_demo = "Ledsen, men det går inte att spela enskilda nivåer med demofilerna.",
  cannot_restart = "Tyvärr sparades detta spel innan funktionen att starta om hade implementerats.",
  very_old_save = "Det har hänt en hel del med spelet sedan du startade den här banan. För att vara säker på att allt fungerar som det är tänkt kan det vara bra att överväga att starta om banan.",
  level_lost = {
    "Attans! Du förlorade. Bättre lycka nästa gång!",
    "Anledning till att du förlorade:",
    reputation = "Ditt anseende föll under %d.",
    balance = "Din bankbalans sjönk till under %d.",
    percentage_killed = "Du dödade mer än %d procent av dina patienter.",
    cheat = "Var det verkligen ditt val eller tryckte du bara på fel knapp? Så du kan inte ens fuska ordentligt, tråkigt för dig...",
  },
  cheat_not_possible = "Det går inte att använda det fusket på den här nivån. Du misslyckas till och med att fuska, det kan inte vara roligt!",
}

tooltip.information = {
  close = "Stäng informationsrutan",
}

totd_window = {
  tips = {
    "Alla sjukhus behöver en reception och en allmänpraktik för att fungera. Sedan beror allt på vad det är för patienter som besöker sjukhuset. Ett hett tips är att börja med ett apotek.",
    "Maskiner som till exempel pumpen behöver underhåll då och då. Anställ en vaktmästare eller två för att reparera dem, annars riskeras personalens och patienternas hälsa.",
    "Efter ett tag kommer din personal att bli trött. Se till att göra ett personalrum så att de kan slappna av lite.",
    "För att inte dina anställda och alla patienter ska bli arga gäller det att ha tillräckligt med element utplacerade lite här och där. Använd stadskartan för att hitta ställen som behöver mer värme.",
    "En läkares kompetensnivå påverkar kvaliteten och hastigheten på hans diagnoser ganska mycket. Sätt en riktigt kompetent läkare i allmänpraktiken så behövs det inte så många andra diagnosrum.",
    "Juniorer och läkare kan höja sin kompetensnivå genom att gå i träning hos en konsult i utbildningsrummet. Om konsulten har någon färdighet (kirurg, psykiater eller forskare) kommer han också att lära ut detta till sina elever.",
    "Har du testat att slå numret till SOS Alarm på faxen? Se till att ljudet är påslaget...",
    "Det går att göra vissa inställningar som till exempel upplösning och språk i alternativmenyn som finns både i huvudmenyn och inuti spelet.",
    "Hittar du en massa text på engelska i spelet? Hjälp oss översätta färdigt till Svenska!",
    "Teamet bakom CorsixTH söker förstärkning! Vill du koda, översätta eller skapa grafik till spelet? Kontakta oss i forumet, på mejllistan eller i IRC-kanalen (corsix-th at freenode).",
    "Om du hittar en bugg, rapportera den gärna i vår bugghanterare på adressen th-issues.corsix.org.",
    "Varje bana har vissa krav som ska uppfyllas innan du kan gå vidare till nästa. Kolla statusfönstret för att se hur nära målen du är.",
    "Om du vill ändra eller ta bort ett existerande rum kan du göra det med hjälp av ändra rum-knappen i panelen längst ner (saxen).",
    "Om du ur högen av patienter vill ta reda på vilka som köar till ett visst rum är det bara att föra muspekaren över rummet.",
    "Klicka på dörren till ett rum för att se kön till det. Sedan går det att genomföra finlir som att ändra ordning eller skicka en patient till ett annat likadant rum.",
    "Olycklig personal frågar efter löneökning ofta. Se till att de jobbar i en behaglig miljö så händer det inte.",
    "Patienter blir törstiga när de väntar på sin tur, ännu mer om du sätter upp värmen! Sätt ut läskautomater på strategiska platser för lite extra inkomst.",
    "Det går att avbryta diagnosprocessen för en patient i förtid och gissa behandling om sjukdomen är känd. Notera att detta ökar risken för felbehandling - och dödsfall.",
    "Akutfall kan vara ett smidigt sätt att få in lite extra stålar, såvida du har kapacitet att hantera alla patienter i tid vill säga.",
  },
  previous = "Föregående tips",
  next = "Nästa tips",
}

tooltip.totd_window = {
  previous = "Visa föregående tips",
  next = "Visa nästa tips",
}

debug_patient_window = {
  caption = "Debug Patient",
}

cheats_window = {
  caption = "Fusk",
  warning = "Varning: Du kommer inte att få bonuspoäng på slutet av nivån om du fuskar!",
  cheated = {
    no = "Har fuskat: Nej",
    yes = "Har fuskat: Ja",
  },
  cheats = {
    money = "Pengar",
    all_research = "All forskning",
    emergency = "Skapa akutfall",
    vip = "Skapa VIP",
    earthquake = "Skapa jordbävning",
    epidemic = "Skapa en smittande patient",
    toggle_infected = "Visa infekterad-ikonen",
    create_patient = "Skapa patient",
    end_month = "Månadsslut",
    end_year = "Hoppa till nyår",
    lose_level = "Förlora nivå",
    win_level = "Vinn nivå",
  },
  close = "Stäng",
}

tooltip.cheats_window = {
  close = "Stäng fuskfönstret",
  cheats = {
    money = "Ökar din balans med 10 000.",
    all_research = "Färdigställer all forskning.",
    emergency = "Skapar ett akutfall.",
    vip = "Skapar en Mycket Viktig Person (VIP)",
    earthquake = "Skapar en jordbävning med slumpad styrka",
    epidemic = "Skapar en person som smittar så att en epidemi kan starta",
    toggle_infected = "Växlar mellan att visa ikoner vid en upptäckt, aktiv epidemi",
    create_patient = "Skapar en patient vid kanten av kartan.",
    end_month = "Hoppar till slutet av månaden.",
    end_year = "Hoppar till slutet av året.",
    lose_level = "Förlora nuvarande nivå.",
    win_level = "Vinn nuvarande nivå.",
  }
}

introduction_texts = {
  demo =
    "Välkommen till demosjukhuset!" ..
    "Tyvärr innehåller demon bara denna nivå. Ändå finns det garanterat tillräckligt att göra ett tag framöver!" ..
    "Du kommer att råka ut för diverse sjukdomar som kräver olika rum för att botas. " ..
    "Ibland kan olyckor hända, så att det kommer akutfall till sjukhuset. Dessutom behöver du forska för att upptäcka fler rum." ..
    "Målet är att tjäna $100,000, ha ett sjukhusvärde av $70,000 och 700 i anseende, samtidigt som du botar minst 75% av patienterna." ..
    "Se till att ditt anseende inte sjunker under 300 och att du inte dödar mer än 40% av dina patienter, annars förlorar du." ..
    "Lycka till!",
}

calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = "%d anrop; %d tilldelade",
  staff = "%s - %s",
  watering = "Vattnar @ %d,%d",
  repair = "Reparera %s",
  close = "Stäng",
}

tooltip.calls_dispatcher = {
  task = "Lista över uppgifter - klicka på en uppgift för att öppna tilldelad personals fönster och flytta vyn till det ställe där uppgiften finns.",
  assigned = "Denna ruta är markerad om någon har fått uppgiften tilldelad till sig.",
  close = "Stäng anropsklarerardialogen",
}

update_window = {
  caption = "Updatering tillgänglig!",
  new_version = "Ny version:",
  current_version = "Din version:",
  download = "Gå till nedladdningssidan",
  ignore = "Skippa och gå till huvudmenyn",
}

tooltip.update_window = {
  download = "gå till nedladdningssidan där du hittar den absolut senaste versionen av CorsixTH",
  ignore = "Skippa updateringen just nu. Du kommer att få en ny notis nästa gång du öppnar CorsixTH",
}

date_format.daymonth = "%1% %2:months%"

original_credits[301] = ":Operations"
original_credits[302] = ","
original_credits[303] = "Steve Fitton"
original_credits[304] = " "
original_credits[305] = " "
original_credits[306] = " "
original_credits[307] = ":Company Administration"
original_credits[308] = ","
original_credits[309] = "Audrey Adams"
original_credits[310] = "Annette Dabb"
original_credits[311] = "Emma Gibbs"
original_credits[312] = "Lucia Gobbo"
original_credits[313] = "Jo Goodwin"
original_credits[314] = "Sian Jones"
original_credits[315] = "Kathy McEntee"
original_credits[316] = "Louise Ratcliffe"
original_credits[317] = " "
original_credits[318] = " "
original_credits[319] = " "
original_credits[320] = ":Company Management"
original_credits[321] = ","
original_credits[322] = "Les Edgar"
original_credits[323] = "Peter Molyneux"
original_credits[324] = "David Byrne"
original_credits[325] = " "
original_credits[326] = " "
original_credits[327] = ":All at Bullfrog Productions"
original_credits[328] = " "
original_credits[329] = " "
original_credits[330] = " "
original_credits[331] = ":Special Thanks to"
original_credits[332] = ","
original_credits[333] = "Everyone at Frimley Park Hospital"
original_credits[334] = " "
original_credits[335] = ":Especially"
original_credits[336] = ","
original_credits[337] = "Beverley Cannell"
original_credits[338] = "Doug Carlisle"
original_credits[339] = " "
original_credits[340] = " "
original_credits[341] = " "
original_credits[342] = ":Keep On Thinking"
original_credits[343] = " "
original_credits[344] = " "
original_credits[345] = " "
original_credits[346] = " "
original_credits[347] = " "
original_credits[348] = " "
original_credits[349] = " "
original_credits[350] = " "
original_credits[351] = " "
original_credits[352] = " "
original_credits[353] = " "
original_credits[354] = " "
original_credits[355] = " "
original_credits[356] = " "
original_credits[357] = " "
original_credits[358] = " "
original_credits[359] = " "
original_credits[360] = " "
original_credits[361] = "."



--------------------------------  UNUSED  -----------------------------------
------------------- (kept for backwards compatibility) ----------------------

options_window.change_resolution = "Ändra upplösning"
tooltip.options_window.change_resolution = "Ändra upplösning till de dimensioner ifyllda till vänster"
