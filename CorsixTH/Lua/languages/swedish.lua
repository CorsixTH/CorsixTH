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

-- override
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

-- new strings
object.litter = utf8 "Skräp"
tooltip.objects.litter = utf8 "Skräp: Lämnat åt sitt öde eftersom patienten inte kunde hitta någon papperskorg."

menu_options = {
  lock_windows = utf8 "  LÅS FÖNSTER  ",
  edge_scrolling = "  KANTRULLNING  ",
  settings = utf8 "  INSTÄLLNINGAR  ",
}

menu_options_game_speed.pause = "  PAUSA  "

menu_file.restart = "  STARTA OM  "

menu_debug = {
  transparent_walls           = utf8 "  TRANSPARENTA VÄGGAR  ",
  limit_camera                = utf8 "  BEGRÄNSA KAMERAN  ",
  disable_salary_raise        = utf8 "  STÄNG AV LÖNEÖKNINGAR  ",
  make_debug_patient          = "  SKAPA DEBUGPATIENT  ",
  spawn_patient               = "  GENERERA VANLIG PATIENT  ",
  make_adviser_talk           = utf8 "  LÅT RÅDGIVAREN PRATA  ",
  show_watch                  = "  VISA KLOCKA  ",
  create_emergency            = "  SKAPA AKUTFALL  ",
  place_objects               = "  PLACERA OBJEKT  ",
  dump_strings                = "  SKAPA TEXTFILER  ",
  dump_gamelog                = "  DUMPA SPELLOGG  ",
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

adviser.room_forbidden_non_reachable_parts = utf8 "Rummet kan inte placeras här eftersom delar av sjukhuset då blir oåtkomliga."

dynamic_info.patient.actions.no_gp_available = utf8 "Väntar på att du ska bygga en allmänpraktik"
dynamic_info.staff.actions.heading_for = utf8 "På väg till %s"
dynamic_info.staff.actions.fired = "Sparkad"

fax = {
  welcome = {
    beta1 = {
      utf8 "Välkommen till CorsixTH, en klon i öppen källkod av det klassiska spelet Theme Hospital av Bullfrog!",
      utf8 "Detta är den första spelbara betan av CorsixTH. Även om många rum, sjukdomar och funktioner implementerats saknas fortfarande mycket.",
      utf8 "Om du gillar projektet kanske du vill hjälpa oss? Till exempel genom att rapportera buggar eller rentav börja koda något själv.",
      utf8 "Hur som helst, börja med att njuta av spelet! Här är några starttips: Bygg en reception (korridorsutrustning) och en allmänpraktik (diagnosrum). Diverse kliniker kommer också att behövas.",
      "-- Gruppen bakom CorsixTH, th.corsix.org",
      utf8 "PS: Kan du hitta påskäggen?",
    },
    beta2 = {
      utf8 "Välkommen till den andra betan av CorsixTH, det klassiska spelet Theme Hospital av Bullfrog i ny förpackning!",
      utf8 "Många funktioner har lagts till sen förra betan. Kolla in ändringsloggen för en nästan komplett lista.",
      utf8 "Men innan dess är det dags att spela! Det verkar som att ett meddelande väntar. Stäng detta fönster och klicka på frågetecknet nere till vänster.",
      "-- Gruppen bakom CorsixTH, th.corsix.org",
    },
  },
  tutorial = {
    utf8 "Välkommen till ditt första Sjukhus!",
    utf8 "Vill du ha hjälp att komma igång?",
    utf8 "Ja, det behövs.",
    utf8 "Det är lugnt, jag kan sånt här.",
  },
  choices = {
    return_to_main_menu = utf8 "Gå till huvudmenyn",
    accept_new_level = utf8 "Gå vidare till nästa bana",
    decline_new_level = utf8 "Fortsätt spela ett tag till",
  },
}

letter = {
  dear_player = utf8 "Käre %s",
  custom_level_completed = utf8 "Bra gjort! Du klarade alla mål på den här specialbanan!",
  return_to_main_menu = utf8 "Vill du gå tillbaka till huvudmenyn eller fortsätta spela?",
  level_lost = utf8 "Attans! Du förlorade. Bättre lycka nästa gång!",
}

install = {
  title = "--------------------------------- CorsixTH Setup ---------------------------------",
  th_directory = utf8 "CorsixTH behöver en kopia av filerna från det ursprungliga spelet (eller dess demo) för att kunna köras. Använd väljaren nedan för att lokalisera mappen där Theme Hospital installerats.",
}

misc.not_yet_implemented = utf8 "(ej tillgänglig ännu)"
misc.no_heliport = utf8 "Antingen har inga sjukdomar upptäckts ännu, eller så finns det ingen helikopterplatta på den här banan."

main_menu = {
  new_game = "Nytt spel",
  custom_level = utf8 "Specialnivå",
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
  back = "Tillbaka",
}

tooltip.menu_list_window = {
  back = utf8 "Stäng detta fönster",
}

options_window = {
  fullscreen = utf8 "Helskärm",
  width = "Bredd",
  height = utf8 "Höjd",
  change_resolution = utf8 "Ändra upplösning",
  back = "Tillbaka",
}

tooltip.options_window = {
  fullscreen_button = utf8 "Klicka för att gå mellan fönster och helskärm",
  width = utf8 "Fyll i önskad skärmbredd",
  height = utf8 "Fyll i önskad skärmhöjd",
  change_resolution = utf8 "Ändra upplösning till de dimensioner ifyllda till vänster",
  language = utf8 "Ändra till %s som språk",
  back = utf8 "Stäng alternativmenyn",
}

errors = {
  dialog_missing_graphics = utf8 "Tyvärr innehåller demon inte den här dialogrutan.",
  save_prefix = utf8 "Fel när spelet skulle sparas: ",
  load_prefix = utf8 "Fel när spelet skulle laddas: ",
  map_file_missing = utf8 "Kunde inte hitta kartfilen %s till den här nivån!",
  minimum_screen_size = "Skärmupplösningen måste vara åtminstone 640x480.",
}

confirmation = {
  needs_restart = utf8 "Att ändra denna inställning kräver en omstart av spelet. Osparad data kommer att gå förlorad. Är du säker på att du vill göra detta?"
}

information = {
  custom_game = utf8 "Välkommen till CorsixTH. Ha nu riktigt kul med den här specialbanan!",
  cannot_restart = utf8 "Tyvärr sparades detta spel innan funktionen att starta om hade implementerats.",
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
    utf8 "Teamet bakom CorsixTH söker förstärkning! Vill du koda, översätta eller skapa grafik till spelet? Kontakta oss i forumet, på mejllistan eller i IRC-kanalen (corsix-th at freenode).",
    utf8 "Om du hittar en bugg, rapportera den gärna i vår bugghanterare på adressen th-issues.corsix.org.",
    utf8 "Du spelar beta 3 av CorsixTH som släpptes den 24 juni 2010.",
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
