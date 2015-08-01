 --[[ Copyright (c) 2010 Manuel "Roujin" Wolf

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

-- Thanks to Michael "michederoide" Armbruster for some additional corrections!

-- Note: This file contains UTF-8 text. Make sure your editor is set to UTF-8.

Language("Deutsch", "German", "de", "ger", "deu")
Inherit("english")
Inherit("original_strings", 2)

-------------------------------  OVERRIDE  ----------------------------------
diseases.broken_wind.cure = " Therapie: Eine spezielle Mixtur aus der Pharma-Theke sorgt für Windstille." -- original string mentioned inflation, which is plain wrong.
diseases.corrugated_ankles.cure = "Therapie: Eine Schwester verabreicht dem Patienten ein leicht toxisches Gebräu, welches das Bein wieder strafft." -- original string mentioned applying a cast, which is wrong and misleads people to think of fracture clinic
fax.vip_visit_query.vip_name = "%s hat den Wunsch geäußert, ihr Krankenhaus besuchen zu wollen." -- text was missing
fax.vip_visit_query.choices.invite = "Lassen Sie dem V.I.P. eine offizielle Einladung zukommen." -- text was ferusing instead of inviting

fax.vip_visit_query.choices.refuse = "Speisen Sie den V.I.P. mit einer Entschuldigung ab." -- text was missing

fax.vip_visit_result.remarks.super[1] = "Was für ein Spitzen-Krankenhaus! Wenn ich das nächste Mal ernsthaft krank bin, will ich hier hin!" -- storming should not be translated with 'turbulent' here

fax.vip_visit_result.vip_remarked_name = "%s hat Ihr Krankenhaus besucht."
fax.vip_visit_result.cash_grant = "Ihnen wurde ein Geldbonus von %d gewährt."
fax.vip_visit_result.rep_boost = "Ihr Ruf in der Öffentlichkeit hat sich gebessert."
fax.vip_visit_result.rep_loss = "Ihr Ruf hat gelitten."
fax.vip_visit_result.close_text = "Danke, dass Sie unser Krankenhaus besucht haben." -- text was missing

fax.emergency.choices.accept = "Ja, ich übernehme diesen Notfall!"
fax.emergency.choices.refuse = "Nein, ich weigere mich diesen Notfall zu übernehmen!"
fax.emergency.location = "Wir haben einen Notruf aus dem %s erhalten." -- wrong spelling
fax.emergency.num_disease = "Es handelt sich um %d Personen mit %s, die sofort behandelt werden müssen." -- wrong spelling
fax.emergency.num_disease_singular = "Es handelt sich um eine Person mit %s, die sofort behandelt werden muss." -- wrong spelling
fax.emergency.cure_possible = "Wir können diesen Notfall übernehmen."
fax.emergency.cure_not_possible_build_and_employ = "Um den Notfall übernehmen zu können, müssen wir eine %s bauen und zusätzliches Personal einstellen."
fax.emergency.cure_not_possible_build = "Um den Notfall übernehmen zu können, müssen wir eine %s bauen."
fax.emergency.cure_not_possible_employ = "Um den Notfall übernehmen zu können, müssen wir zusätzliches Personal einstellen."
fax.emergency.cure_not_possible = "Wir können diesen Notfall im Moment keinesfalls übernehmen."
fax.emergency.bonus = "Wenn wir keinen Patienten verlieren, erhalten wir einen Geldbonus von maximal %d. Sollten wir es jedoch vermasseln, wird unser Ruf Schaden nehmen."
fax.emergency_result.close_text = "Danke, ich habe gerne geholfen."
fax.emergency_result.earned_money = "Sie erhalten von maximal %d einen Geldbonus von %d."
fax.emergency_result.saved_people = "Vielen Dank für Ihre Hilfe! Sie haben %d von insgesamt %d gerettet."

fax.disease_discovered_patient_choice.choices.send_home = "Schicken Sie den Patienten nach Hause." -- wrong text for button
fax.disease_discovered_patient_choice.choices.wait = "Sorgen Sie dafür, dass der Patient eine Weile im Krankenhaus wartet." -- wrong text for button
fax.disease_discovered_patient_choice.choices.research = "Schicken Sie den Patienten in die Forschungsabteilung." -- wrong text for button
fax.disease_discovered_patient_choice.need_to_build_and_employ = "Um diese Krankheit heilen zu können, müssen wir eine %s bauen und zusätzliches Personal einstellen." -- text was missing
fax.disease_discovered_patient_choice.need_to_build = "Um diese Krankheit heilen zu können, müssen wir eine %s bauen." -- text was missing
fax.disease_discovered_patient_choice.need_to_employ = "Um diese Krankheit heilen zu können, müssen wir zusätzliches Personal einstellen."
fax.disease_discovered_patient_choice.can_not_cure = "Im Moment können wir diese Krankheit nicht behandeln."
fax.disease_discovered_patient_choice.disease_name = "Unser Ärzteteam hat herausgefunden, an was für einer Art von %s der Patient leidet." -- text was missing
fax.disease_discovered_patient_choice.what_to_do_question = "Was sollen wir jetzt mit dem Patienten anstellen?" -- text was missing
fax.disease_discovered_patient_choice.guessed_percentage_name = "Unser Ärzteteam ist sich zu %d Prozent sicher, dass der Patient an einer Form von %s leidet." -- text was missing
fax.disease_discovered.close_text = "Eine neue Krankheit wurde entdeckt."
fax.disease_discovered.can_cure = "Wir können diese Krankheit problemlos behandeln." -- text was missing
fax.disease_discovered.need_to_build_and_employ = "Um diese Krankheit heilen zu können, müssen wir eine %s bauen und zusätzliches Personal einstellen." -- text was missing
fax.disease_discovered.need_to_build = "Um diese Krankheit heilen zu können, müssen wir eine %s bauen." -- text was missing
fax.disease_discovered.need_to_employ = "Um diese Krankheit heilen zu können, müssen wir zusätzliches Personal einstellen."
fax.disease_discovered.discovered_name = "Unser Ärzteteam hat einen Fall von %s entdeckt."

fax.diagnosis_failed.choices.send_home = "Schicken Sie den Patienten nach Hause." -- wrong text for button
fax.diagnosis_failed.choices.take_chance = "Nehmen Sie die wahrscheinliche Möglichkeit zur Heilung wahr." -- wrong text for button
fax.diagnosis_failed.choices.wait = "Der Patient soll eine Weile im Krankenhaus warten, wir stellen bald neue Diagnosearten zur Verfügung."
fax.diagnosis_failed.situation = "Dieser Patient hat all unsere Diagnosegeräte zum qualmen gebracht. Trotzdem wissen wir immer noch nicht genau, was ihm fehlt." -- text was missing
fax.diagnosis_failed.what_to_do_question = "Was sollen wir jetzt mit dem Patienten anstellen?" -- wrong spelling
fax.diagnosis_failed.partial_diagnosis_percentage_name = "Unser Ärzteteam ist sich zu %d Prozent sicher, dass der Patient an einer Form von %s leidet."

fax.epidemic.choices.declare = "Wir melden die Epidemie und zahlen die Geldstrafe!"
fax.epidemic.choices.cover_up = "Wir versuchen die Epidemie einzudämmen bevor sie das Krankenhaus verlässt!"
fax.epidemic.declare_explanation_fine = "Wenn wir die Epidemie melden, zahlen wir eine Strafe von %d und unser Ruf leidet. Dafür werden die Patienten automatisch geimpft." -- extend to mention reputation hit and automatic vaccination
fax.epidemic.cover_up_explanation_1 = "Wenn wir versuchen, die Epidemie zu vertuschen, müssen wir die Infizierten heilen, bevor das Gesundheitsministerium davon Wind bekommt."
fax.epidemic.cover_up_explanation_2 = "Wenn der Gesundheitsinspektor die Vertuschungsaktion bemerkt, wird das Konsequenzen haben."
fax.epidemic.disease_name = "Unser Ärzteteam hat eine hochgradig ansteckende Form von %s entdeckt!"
fax.epidemic_result.close_text = "Hurra!"
fax.epidemic_result.failed.part_1_name = "Ihr Versuch diese %s-Epidemie zu vertuschen ist fehlgeschlagen! Sie konnten nicht verhindern,"
fax.epidemic_result.failed.part_2 = "dass sich die Epidemie in Ihrem ganzen Krankenhaus ausbreitet."
fax.epidemic_result.succeeded.part_1_name = "Dem Gesundheitsinspektor ist zu Ohren gekommen, dass Sie mit einem schweren Fall von %s zu kämpfen haben."
fax.epidemic_result.succeeded.part_2 = "Allerdings hat er dafür keine Beweise finden können."
fax.epidemic_result.compensation_amount = "Die Behörden haben beschlossen, Sie wegen Ihrer Lügen zu einer Geldstrafe von %d zu verurteilen."
fax.epidemic_result.fine_amount = "Die Behörden haben den nationalen Notstand ausgerufen und sie zu einer Geldstrafe von %d verurteilt."
fax.epidemic_result.rep_loss_fine_amount = "Die Zeitungen haben Wind von der Epidemie bekommen und ziehen Ihren Ruf in den Dreck. Darüber hinaus hat man zu einer Geldstrafe von %d verurteilt."
fax.epidemic_result.hospital_evacuated = "Die Behörden haben keine andere Wahl, als ihr Krankenhaus zu evakuieren."

dynamic_info.patient.actions.dying = "Ins Jenseits befördert!" -- wrong verb case
dynamic_info.patient.actions.epidemic_vaccinated = "Ich bin nicht mehr infiziert."
adviser.research.drug_fully_researched = "Sie haben die Effektivität Ihres %s-Medikaments auf 100% gesteigert." -- grammatical error in original
tooltip.graphs.reputation = "Ruf ein- und ausschalten" -- original mentioned hospital value, while it's actually reputation.
staff_title.researcher = "Forscher" -- one of the most annoying (since prominent) wrong strings in original
bank_manager.insurance_owed = "Zahlungen von Vers." -- original was too long
graphs.deaths = "Todesfälle" -- origin was too long
insurance_companies[7] = "Leben-und-Tod KG" -- %% in original string (maybe this was rendered as &)
object.skeleton = "Skelett" -- second most annoying mistake in german translation
tooltip.staff_list.detail = "Aufmerksamkeit" -- was translated as an imperative
tooltip.staff_list.surgeon_train = "Wurde zu %d%% zum Chirurgen ausgebildet." -- the three strings made no sense grammatically
tooltip.staff_list.psychiatrist_train = "Wurde zu %d%% zum Psychiater ausgebildet."
tooltip.staff_list.researcher_train = "Wurde zu %d%% zum Forscher ausgebildet."
-- tooltip.staff_list.next_person, prev_person is rather next/prev page (also in english)
tooltip.staff_list.next_person = "Zur nächsten Seite blättern"
tooltip.staff_list.prev_person = "Zur vorherigen Seite blättern"

tooltip.queue_window.inc_queue_size = "Warteschlange vergrößern"
tooltip.queue_window.dec_queue_size = "Warteschlange verkleinern"

-- Improve tooltips in staff window to mention hidden features
tooltip.staff_window.face = "Gesicht dieser Person - klicken, um das Personal-Management zu öffnen"
tooltip.staff_window.center_view = "Linksklick, um zur Person zu springen, Rechtsklick um durch das Personal zu blättern"

-- These strings are missing in some versions of TH (unpatched?)
confirmation.restart_level = "Sind Sie sicher, dass Sie das aktuelle Level von vorne beginnen möchten?"

-------------------------------  NEW STRINGS  -------------------------------
date_format = {
  daymonth = "%1%. %2:months%",
}

object.litter = "Müll"
tooltip.objects.litter = "Müll: Wurde von einem Patienten fallengelassen, nachdem er keinen Mülleimer fand."

tooltip.fax.close = "Das Fenster schließen, ohne die Nachricht zu löschen"
tooltip.message.button = "Linksklick, um die Nachricht zu öffnen"
tooltip.message.button_dismiss = "Linksklick, um die Nachricht zu öffnen, Rechtsklick um sie zu entfernen"
tooltip.casebook.cure_requirement.hire_staff = "Sie müssen Personal einstellen, um diese Behandlung durchführen zu können"
tooltip.casebook.cure_type.unknown = "Sie wissen noch nicht, wie Sie diese Krankheit behandeln können"
tooltip.research_policy.no_research = "In dieser Kategorie wird momentan keine Forschung durchgeführt"
tooltip.research_policy.research_progress = "Fortschritt in dieser Kategorie: %1%/%2%"

menu_options = {
  lock_windows     = "  FENSTER FESTHALTEN  ",
  edge_scrolling   = "  AM BILDSCHIRMRAND SCROLLEN  ",
  adviser_disabled = "  BERATER  ",
  warmth_colors    = "  FARBEN FÜR WÄRMEDARSTELLUNG  ",
  twentyfour_hour_clock = "  24-STUNDEN-UHR  ",
  wage_increase = "  GEHALTSERHÖHUNGEN  ",
}

menu_options_wage_increase = {
  deny = "    ABLEHNEN ",
  grant = "    GEWÄHREN ",
}

menu_options_game_speed = {
  pause               = "  (P) PAUSE  ",
  slowest             = "  (1) AM LANGSAMSTEN  ",
  slower              = "  (2) LANGSAM  ",
  normal              = "  (3) NORMAL  ",
  max_speed           = "  (4) MAXIMALE GESCHWINDIGKEIT  ",
  and_then_some_more  = "  (5) UND NOCH MEHR  ",
}

menu_options_warmth_colors = {
  choice_1 = "  ROTTÖNE  ",
  choice_2 = "  BLAU-GRÜN-ROT  ",
  choice_3 = "  GELB-ORANGE-ROT  ",
}

menu_charts = {
  bank_manager  = "  (F1) BANK-MANAGER  ",
  statement     = "  (F2) BILANZ  ",
  staff_listing = "  (F3) PERSONALLISTE  ",
  town_map      = "  (F4) ÜBERSICHTSKARTE  ",
  casebook      = "  (F5) BEHANDLUNGSMAPPE  ",
  research      = "  (F6) FORSCHUNG  ",
  status        = "  (F7) STATUS  ",
  graphs        = "  (F8) DIAGRAMME  ",
  policy        = "  (F9) EINSTELLUNGEN  ",
}

customise_window = {
  option_on = "Ein",
  option_off = "Aus",
  average_contents = "Einrichtung merken",
  paused = "In Pause bauen",
  intro = "Introfilm abspielen",
  caption = "Spezialeinstellungen",
  back = "Zurück",
  movies = "Alle Filme zeigen",
  aliens = "Außerird. Patienten",
  fractured_bones = "Gebrochene Knochen",
  volume = "Leiser-Taste",
}

tooltip.customise_window = {
  aliens = "Aufgrund des Fehlens einer anständigen Animation haben wir standardmäßig Patienten mit außerirdischer DNA deaktiviert, damit sie nur zu einem Notfall kommen. Um Patienten mit außerirdischer DNA es zu erlauben, Ihr Krankenhaus nicht nur bei Notfällen zu besuchen, schalten Sie dies ab.",
  average_contents = "Wenn Sie möchten, dass sich das Spiel merkt, welche zusätzlichen Objekte Sie üblicherweise beim Gebäudebau hinzufügen, dann schalten Sie diese Option ein.",
  back = "Dieses Menü schließen und zum Einstellungsmenü zurückkehren",
  movies = "Globale Filmsteuerung: Hiermit können Sie sämtliche Filme abschalten",
  fractured_bones = "Aufgrund einer armseligen Animation haben wir uns entschieden, dass es standardmäßig keine weiblichen Patienten mit gebrochenen Knochen gibt. Wenn weibliche Patienten mit gebrochenen Knochen ihr Krankenhaus besuchen sollen, dann schalten Sie dies ab.",
  volume = "Wenn die Leiser-Taste auch das Fallbuch öffnet, dann schalten Sie dies ein, um die Schnellzugriffstaste für das Fallbuch auf Umschalt + C zu wechseln.",
  intro = "Den Introfilm abschalten. Das Intro wird nur gespielt, wenn Sie nicht auch gleichzeitig alle Filme abgeschaltet haben.",
  paused = "In Theme Hospital würde es dem Spieler während der Pause nur gestattet sein, das obere Menü zu benutzen. Dies ist in CorsixTH ebenfalls die Standardeinstellung, aber wenn Sie dies einschalten, ist alles in der Pause erlaubt.",
}

-- The demo does not contain this string
menu_file.restart = "  NEUSTART  "

menu_debug = {
  jump_to_level             = "  SPRINGE ZU LEVEL  ",
  transparent_walls    = "  (X) DURCHSICHTIGE WÄNDE  ",
  limit_camera              = "  KAMERA BEGRENZEN  ",
  disable_salary_raise = "  KEINE GEHALTSERHÖHUNGEN  ",
  make_debug_fax            = "  DEBUG-FAX ERSTELLEN  ",
  make_debug_patient        = "  DEBUG-PATIENTEN ERSTELLEN  ",
  cheats                    = "  (F11) CHEATS  ",
  lua_console               = "  (F12) LUA-KONSOLE  ",
  calls_dispatcher          = "  AUFRUF-VERTEILER  ",
  dump_strings              = "  TEXTE ABSPEICHERN  ",
  dump_gamelog              = "  (STRG+D) SPIELPROTOKOLL ABSPEICHERN  ",
  map_overlay               = "  KARTEN-OVERLAY  ",
  sprite_viewer             = "  SPRITE-BETRACHTER  ",
  connect_debugger          = "  (STRG + C) ZUM LUA-DEBUG-SERVER VERBINDEN  ",
  debug_script              = "  (UMSCHALT + D) DEBUG-SKRIPT STARTEN  ",
}
menu_debug_overlay = {
  none                      = "  KEIN  ",
  flags                     = "  FLAGS  ",
  positions                 = "  POSITION  ",
  heat                      = "  TEMPERATUR  ",
  byte_0_1                  = "  BYTE 0 & 1  ",
  byte_floor                = "  BYTE BODEN  ",
  byte_n_wall               = "  BYTE N WAND  ",
  byte_w_wall               = "  BYTE W WAND  ",
  byte_5                    = "  BYTE 5  ",
  byte_6                    = "  BYTE 6  ",
  byte_7                    = "  BYTE 7  ",
  parcel               = "  GRUNDSTÜCK  ",
}

adviser = {
  room_forbidden_non_reachable_parts = "Sie können den Raum hier nicht bauen, da dann Teile des Krankenhauses nicht mehr erreichbar wären.",
  warnings = {
    no_desk ="Sie sollten beizeiten mal eine Rezeption bauen und eine Empfangsdame einstellen!",
    no_desk_1 = "Wenn Sie wollen, dass Patienten in Ihr Krankenhaus kommen, müssen Sie eine Empfangsdame einstellen und eine Rezeption für sie bauen!",
    no_desk_2 = "Na Klasse, das muss ja ein Weltrekord sein: Fast ein Jahr ohne einen einzigen Patienten! Wenn Sie dieses Krankenhaus weiter leiten wollen, müssen Sie eine Empfangsdame einstellen und eine Rezeption bauen!",
    no_desk_3 = "Ich glaub ich spinne, fast ein Jahr ist um und Sie haben keine besetzte Rezeption! Wie denken Sie denn, dass die Patienten zu Ihnen finden? Schauen Sie mal zu, dass Sie Ihren Kram auf die Reihe bekommen!",
    no_desk_4 = "Eine Empfangsdame muss ihren eigenen Arbeitsplatz haben, um die Patienten bei ihrer Ankunft zu begrüßen.",
    no_desk_5 = "Na, das wurde aber auch Zeit! Sie sollten in Kürze ein paar Patienten hier eintreffen sehen!",
    no_desk_6 = "Sie haben eine Empfangsdame, also sollten Sie eine Rezeption für sie bauen.",
    no_desk_7 = "Sie haben die Rezeption gebaut, also wie wäre es damit, eine Empfangsdame einzustellen? Sie werden keine Patienten sehen, bis sie das geregelt haben, wissen Sie?",
    falling_1 = "He! Vorsicht mit dem Mauszeiger, jemand könnte sich verletzen!",
    falling_2 = "Hören Sie schon auf damit, wie würde das Ihnen denn gefallen?",
    falling_3 = "Autsch, das sah schmerzhaft aus. Ruft einen Arzt!",
    falling_4 = "Dies ist ein Krankenhaus, kein Vergnügungspark!",
    falling_5 = "Sie sind nicht hier um Leute umzustoßen. Sie sind krank, okay?",
    falling_6 = "Dies ist keine Bowlingbahn. Patienten sollten nicht so behandelt werden!",
    cannot_afford = "Sie haben nicht genügend Geld auf dem Konto, um diese Person einzustellen!",
    cannot_afford_2 = "Sie haben nicht genügend Geld auf dem Konto, um dies zu kaufen!",
    research_screen_open_1 = "Sie müssen eine Forschungseinrichtung errichten, um auf das Forschungsmenü zugreifen zu können.",
    research_screen_open_2 = "Forschung ist im aktuellen Level nicht verfügbar.",
    researcher_needs_desk_1 = "Ein Forscher braucht einen Schreibtisch, um daran arbeiten zu können.",
    researcher_needs_desk_2 = "Ihr Forscher ist froh darüber, dass Sie ihm eine Pause gegönnt haben. Falls Sie vorhatten, dass noch mehr Personal forscht, dann müssen Sie jedem Forscher einen eigenen Schreibtisch zur Verfügung stellen.",
    researcher_needs_desk_3 = "Jeder Forscher braucht einen eigenen Schreibtisch, an dem er arbeiten kann.",
    nurse_needs_desk_1 = "Jede Krankenschwester braucht ihren eignen Schreibtisch, an dem sie arbeiten kann.",
    nurse_needs_desk_2 = "Ihre Krankenschwester ist froh darüber, dass Sie ihr eine Pause gegönnt haben. Falls Sie vorhatten, dass mehr als nur eine Krankenschwester in der Station arbeitet, dann müssen Sie jeder Krankenschwester einen eigenen Schreibtisch zur Verfügung stellen.",
  },
  research = {
    drug_improved = "Die Effektivität Ihres %s-Medikaments wurde von Ihrer Forschungsabteilung verbessert.",
    drug_improved_1 = "Das Medikament %s wurde von Ihrer Forschungsabteilung verbessert.",
  },
  cheats = {
    th_cheat = "Gratulation, Sie haben die Cheats aktiviert!",
    roujin_on_cheat = "Roujins Herausforderungs-Cheat aktiviert! Viel Glück ...",
    roujin_off_cheat = "Roujins Herausforderung deaktiviert.",
  },
}

dynamic_info.patient.actions.no_gp_available = "Wartet darauf, dass Sie eine Allgemeinmedizin bauen"
dynamic_info.staff.actions.heading_for = "Geht zu: %s"
dynamic_info.staff.actions.fired = "Gefeuert"

fax = {
  choices = {
    return_to_main_menu = "Ins Hauptmenü zurückkehren",
    accept_new_level = "Zum nächsten Level wechseln",
    decline_new_level = "Noch ein wenig im aktuellen Level weiterspielen",
  },
  vip_visit_result = {
    remarks = {
      free_build = {
        "Echt ein hübsches Krankenhaus haben Sie da! War aber wohl nicht so schwer zum Laufen zu bekommen, so ohne finanzielle Beschränkungen, was? Haha ...",
        "Ich bin zwar kein BWLer, aber ich denke, dieses Krankenhaus könnte ich auch führen. Sie wissen schon, was ich meine.",
        "Ein gut organisiertes Krankenhaus. Aber hüten Sie sich vor der Finanzkrise! Ach ja ... da müssen Sie sich ja keine Sorgen machen.",
      },
    },
  },
  emergency = {
    num_disease_singular = "Hier ist eine Person mit %s, sie braucht sofortige Aufmerksamkeit.",
    free_build = "Wenn wir erfolgreich sind, wird unser Ruf steigen. Falls wir versagen, wird unser Ruf Schaden nehmen.",
  },
}

letter = {
  dear_player = "Hallo %s",
  custom_level_completed = "Gut gemacht! Sie haben alle Ziele dieses eigenen Levels erreicht!",
  return_to_main_menu = "Möchten Sie ins Hauptmenü zurückkehren, oder weiterspielen?",
}

install = {
  title = "----------------------------- CorsixTH-Konfiguration -----------------------------",
  th_directory = "CorsixTH benötigt einige Dateien des Originalspiels Theme Hospital (oder der Demo davon), um zu funktionieren. Bitte das Installationsverzeichnis von Theme Hospital auswählen.",
  exit = "Beenden",
  ok = "OK",
  cancel = "Abbrechen",
}

misc.not_yet_implemented = "(noch nicht implementiert)"
misc.no_heliport = "Entweder wurden noch keine Krankheiten entdeckt, oder es existiert kein Heliport auf dieser Karte."

main_menu = {
  new_game = "Neues Spiel",
  custom_level = "Eigenes Level",
  load_game = "Spiel laden",
  options = "Optionen",
  exit = "Verlassen",
  version = "Version: ",
  savegame_version = "Spielstandsversion: ",
  continue = "Spiel fortsetzen",
}

tooltip.main_menu = {
  new_game = "Ein komplett neues Spiel anfangen",
  custom_level = "Ein Krankenhaus in einem eigenen Level errichten",
  load_game = "Ein zuvor gespeichertes Spiel fortsetzen",
  options = "Diverse Einstellungen verändern",
  exit = "Bitte lassen Sie mich nicht allein!",
  quit = "Sie sind im Begriff, CorsixTH zu verlassen. Sind Sie sich sicher, dass Sie das tun wollen?",
}

load_game_window = {
  caption = "Spiel laden",
}

tooltip.load_game_window = {
  load_game = "Spiel %s laden",
  load_game_number = "Spiel %d laden",
  load_autosave = "Automatisch gespeichertes Spiel laden",
}

custom_game_window = {
  caption = "Eigenes Level",
  free_build = "Freies Spiel",
}

tooltip.custom_game_window = {
  start_game_with_name = "Level %s starten",
  free_build = "Auswählen, um ohne Geld und Sieg-/Niederlagebedingungen zu spielen",
}

save_game_window = {
  caption = "Spiel Speichern",
  new_save_game = "Neuer Spielstand",
}

tooltip.save_game_window = {
  save_game = "Spielstand %s überschreiben",
  new_save_game = "Namen für einen neuen Spielstand eingeben",
}

menu_list_window = {
  name = "Dateiname",
  save_date = "Änderungsdatum",
  back = "Zurück",
}

tooltip.menu_list_window = {
  name = "Hier klicken, um nach Dateinamen zu sortieren",
  save_date = "Hier klicken, um nach dem letzten Änderungsdatum zu sortieren",
  back = "Das Fenster schließen",
}

options_window = {
  caption = "Einstellungen",
  option_on = "Ein",
  option_off = "Aus",
  fullscreen = "Vollbild",
  resolution = "Auflösung",
  custom_resolution = "Benutzerdefiniert ...",
  width = "Breite",
  height = "Höhe",
  apply = "Akzeptieren",
  cancel = "Abbrechen",
  language = "Spielsprache",
  cancel = "Abbrechen",
  back = "Zurück",
  folder = "Verzeichnisse",
  customise = "Spezialeinstellungen",
  audio = "Globales Audio",
}

tooltip.options_window = {
  fullscreen = "Darstellung im Vollbild- oder Fenstermodus",
  fullscreen_button = "Klicken, um zwischen Vollbild- und Fenstermodus zu wechseln",
  resolution = "Die Bildschirmauflösung, in der das Spiel läuft",
  select_resolution = "Eine neue Auflösung auswählen",
  width = "Gewünschte Bildschirmbreite eingeben",
  height = "Gewünschte Bildschirmhöhe eingeben",
  apply = "Die eingegebene Auflösung akzeptieren",
  cancel = "Zurückkehren, ohne die Auflösung zu ändern",
  language = "Die Sprache, in der Texte im Spiel erscheinen",
  select_language = "Die Spielsprache ändern",
  language_dropdown_item = "%s als Sprache auswählen",
  back = "Das Optionsfenster schließen",
  audio_button = "Sämtliche Toneffekte im Spiel ein- bzw. ausschalten",
  audio_toggle = "Ein- oder ausschalten",
  customise_button = "Weitere Einstellungen, die Sie ändern können, um Ihr Spielerlebnis anzupassen",
  folder_button = "Verzeichniseinstellungen",
}

font_location_window.caption = "Schrift auswählen (%1%)"

new_game_window = {
  caption = "Neues Spiel",
  option_on = "Ein",
  option_off = "Aus",
  difficulty = "Schwierigkeit",
  easy = "AIP (Einfach)",
  medium = "Arzt (Mittel)",
  hard = "Berater (Schwer)",
  tutorial = "Einführung",
  start = "Start",
  cancel = "Abbrechen",
  player_name = "Spielername",
}

tooltip.new_game_window = {
  difficulty = "Hier kann der Schwierigkeitsgrad des Spiels eingestellt werden",
  easy = "Die richtige Option für Simulations-Neulinge",
  medium = "Der Mittelweg - für diejenigen, die sich nicht entscheiden können",
  hard = "Wer diese Art von Spielen schon gewöhnt ist und eine Herausforderung will, sollte hier klicken",
  tutorial = "Dieses Feld abhaken, um zu Beginn des Spieles eine Einführung zu erhalten",
  start = "Das Spiel mit den gewählten Einstellungen starten",
  cancel = "Oh, eigentlich wollte ich gar kein neues Spiel starten!",
  player_name = "Geben Sie den Namen ein, mit dem Sie im Spiel genannt werden möchten",
}

lua_console = {
  execute_code = "Ausführen",
  close = "Schließen",
}

tooltip.lua_console = {
  textbox = "Hier Lua-Code zum Ausführen eingeben",
  execute_code = "Den eingegebenen Code ausführen",
  close = "Die Konsole schließen",
}

errors = {
  dialog_missing_graphics = "Entschuldigung, aber dieses Fenster ist in den Demo-Dateien nicht enthalten.",
  save_prefix = "Fehler beim Speichern: ",
  load_prefix = "Fehler beim Laden: ",
  map_file_missing = "Die Kartendatei %s für das Level konnte nicht gefunden werden!",
  minimum_screen_size = "Bitte eine Auflösung von mindestens 640×480 eingeben.",
  unavailable_screen_size = "Die gewünschte Auflösung ist im Vollbildmodus nicht verfügbar.",
  no_games_to_contine = "Es gibt keine Spielstände.",
  fractured_bones = "BEACHTEN SIE: Die Animation für weibliche Patienten mit gebrochenen Knochen ist nicht perfekt.",
  load_quick_save = "Fehler: Der Schnellspeicherspielstand konnte nicht geladen werden, weil er nicht existiert. Kein Grund zur Sorge, wir haben nun einen für Sie erzeugt!",
  alien_dna = "BEACHTEN SIE: Für außerirdische Patienten gibt es keine Animationen für das Sitzen, das Öffnen von Türen, das Anklopfen, usw. Daher werden sie, wie bei Theme Hospital, normal aussehen und sich dann wieder zurückverwandeln. Patienten mit außerirdischer DNA werden nur auftauchen, wenn sie in der Leveldatei gesetzt sind.",
}

confirmation = {
  needs_restart = "Um diese Änderung, vorzunehmen muss CorsixTH neu gestartet werden. Nicht gespeicherter Fortschritt geht verloren. Sicher, dass Sie fortfahren wollen?",
  abort_edit_room = "Sie bauen oder ändern gerade einen Raum. Wenn alle benötigten Objekte platziert sind, wird der Raum fertiggestellt, ansonsten wird er gelöscht. Fortfahren?",
  maximum_screen_size = "Die von Ihnen gewählte Bildschirmauflösung ist größer als 3000×2000. Größere Auflösungen sind möglich, aber erfordern eine bessere Hardware, um eine akzeptable Bildwiederholrate zu gewährleisten. Sind Sie sich sicher, dass Sie fortfahren möchten?",
  music_warning = "Bevor Sie sich dafür entscheiden, MP3s für Ihre Spielmusik verwenden, müssen Sie smpeg.dll oder eine entsprechende Datei für Ihr Betriebssystem haben, ansonsten werden Sie keine Musik im Spiel haben. Momentan gibt es keine entsprechende Datei für 64-Bit-Systeme. Möchten Sie fortfahren?",
}

information = {
  custom_game = "Willkommen zu CorsixTH. Viel Spaß mit diesem eigenen Level!",
  cannot_restart = "Leider wurde dieses eigene Level vor Implementierung des Neustart-Features gespeichert.",
  level_lost = {
  },
  level_lost = {
    "So ein Mist! Sie haben das Level leider nicht geschafft. Vielleicht klappts ja beim nächsten Mal!",
    "Der Grund, warum Sie verloren haben:",
    reputation = "Ihr Ruf ist unter %d gesunken.",
    balance = "Ihr Kontostand ist unter %d gesunken.",
    percentage_killed = "Sie haben mehr als %d Prozent der Patienten getötet.",
    cheat = "Sie haben das selbst so gewollt. Oder haben Sie etwa auf den falschen Knopf gedrückt? Sie können also nichtmal richtig cheaten. Traurig.",
  },
  very_old_save = "Seit dieses Level gestartet wurde, wurden einige Änderungen am Spiel durchgeführt. Sie sollten ein neues Spiel starten, damit alle Änderungen wirksam werden.",
  no_custom_game_in_demo = "Tut uns Leid, aber in der Demo-Version sind keine eigenen Level spielbar.",
  cheat_not_possible = "Dieser Cheat ist in diesem Level nicht verfügbar. Sogar beim Cheaten versagen Sie, wie armselig!",
}

tooltip.information = {
  close = "Das Informationsfenster schließen",
}

totd_window = {
  tips = {
    "Zu Beginn benötigt jedes Krankenhaus eine Rezeption und eine Allgemeinmedizin. Danach kommt es darauf an, was für Patienten im Krankenhaus auftauchen. Eine Pharma-Theke ist aber immer eine gute Wahl.",
    "Maschinen wie die Entlüftung müssen gewartet werden. Stellen Sie ein paar Handlanger ein, oder die Patienten und das Personal könnte verletzt werden.",
    "Nach einer Weile wird das Personal müde. Bauen Sie unbedingt einen Personalraum, damit es sich ausruhen kann.",
    "Platzieren Sie genug Heizkörper, um das Personal und die Patienten warm zu halten, sonst werden sie unglücklich. Benutzen Sie die Übersichtskarte, um Stellen im Krankenhaus zu finden, die noch etwas besser beheizt werden müssen.",
    "Der Fähigkeiten-Level eines Arztes beeinflusst die Qualität und Geschwindigkeit seiner Diagnosen deutlich. Ein geübter Arzt in der Allgemeinmedizin erspart so manchen zusätzlichen Diagnoseraum.",
    "AIPler und Ärzte können ihre Fähigkeiten verbessern, indem sie in der Ausbildung von Beratern lernen. Wenn der Berater eine zusätzliche Qualifikation (Chirurg, Psychiater oder Forscher) besitzt, gibt er dieses Wissen ebenfalls weiter.",
    "Haben Sie schon versucht, die europäische Notruf-Nummer (112) in das Faxgerät einzugeben? Schalten Sie vorher den Sound an!",
    "Im Options-Menü hier im Hauptmenü oder im laufenden Spiel können Einstellungen wie die Auflösung oder die Sprache geändert werden.",
    "Haben Sie eine andere Sprache als Englisch ausgewählt, aber es erscheinen englische Texte? Helfen Sie uns, die Übersetzung zu vervollständigen, indem Sie fehlende Texte in Ihre Sprache übersetzten!",
    "Das CorsixTH-Team sucht Verstärkung! Haben Sie Interesse, beim Programmieren, Übersetzen oder der Grafikerstellung zu helfen? Kontaktieren Sie uns in unserem Forum, der Mailing-Liste oder unserem IRC-Channel (#Corsix-TH auf Freenode).",
    "Wenn Sie einen Bug finden, bitte melden Sie ihn in unserem Bug-Tracker: th-issues.corsix.org",
    "In jedem Level müssen bestimmte Voraussetzungen erfüllt werden, bevor man zum Nächsten wechseln kann. Im Status-Fenster können Sie Ihren Fortschritt bezüglich der Levelziele sehen.",
    "Um existierende Räume zu bearbeiten oder gar zu löschen, kann man den Raum-Bearbeiten-Knopf in der unteren Werkzeugleiste verwenden.",
    "Um aus einer Horde wartender Patienten diejenigen zu finden, die für einen bestimmten Raum warten, einfach mit dem Mauszeiger über den entsprechenden Raum fahren.",
    "Klicken Sie auf die Tür eines Raumes, um seine Warteschlange zu sehen. Hier kann man nützliche Feineinstellungen vornehmen, wie etwa die Warteschlange umzusortieren oder einen Patienten zu einem anderen Raum zu senden.",
    "Unglückliches Personal verlangt öfter Gehaltserhöhungen. Gestalten Sie die Arbeitsumgebung Ihres Personals möglichst angenehm, um dies zu verhindern.",
    "Patienten werden beim Warten durstig, besonders wenn die Heizungen aufgedreht sind! Strategisch platzierte Getränkeautomaten sind eine nette zusätzliche Einnahmequelle.",
    "Sie können die Diagnose für einen Patienten vorzeitig abbrechen und ihn direkt zur Behandlung schicken, falls seine Krankheit zuvor schon entdeckt wurde. Allerdings erhöht sich dadurch das Risiko, dass das Heilmittel falsch ist und der Patient stirbt.",
    "Notfälle können eine gute Einnahmequelle abgeben, sofern genügend Kapazitäten vorhanden sind, um die Notfallpatienten rechtzeitig zu behandeln.",
  },
  previous = "Vorheriger Tipp",
  next = "Nächster Tipp",
}

tooltip.totd_window = {
  previous = "Den vorherigen Tipp anzeigen",
  next = "Den nächsten Tipp anzeigen",
}

debug_patient_window = {
  caption = "Debug-Patient",
}

update_window = {
  caption = "Update verfügbar!",
  new_version = "Neue Version:",
  current_version = "Aktuelle Version:",
  download = "Zur Downloadseite gehen",
  ignore = "Überspringen und zum Hauptmenü gehen",
}

tooltip.update_window = {
  download = "Zur Downloadseite für die allerneueste Version von CorsixTH gehen",
  ignore = "Dieses Update im Moment ignorieren. Sie werden erneut benachrichtigt, wenn Sie CorsixTH das nächste Mal starten.",
}

cheats_window = {
  caption = "Cheats",
  warning = "Warnung: Cheater bekommen am Ende des Levels keine Bonus-Punkte!",
  cheated = {
    no = "Cheats benutzt: Nein",
    yes = "Cheats benutzt: Ja",
  },
  cheats = {
    money = "Geld-Cheat",
    all_research = "Alle-Forschungen-Cheat",
    emergency = "Notfall erzeugen",
    vip = "VIP erzeugen",
    earthquake = "Erdbeben starten",
    create_patient = "Patienten erzeugen",
    end_month = "Ende des Monats",
    end_year = "Ende des Jahres",
    lose_level = "Level verlieren",
    win_level = "Level gewinnen",
    epidemic = "Infizierten Patienten erzeugen",
    toggle_infected = "Infektions-Symbole umschalten",
  },
  close = "Schließen",
}

tooltip.cheats_window = {
  close = "Das Cheat-Fenster schließen",
  cheats = {
    money = "10.000 zum Konto hinzufügen.",
    all_research = "Alle Forschungen abschließen.",
    emergency = "Einen Notfall erzeugen.",
    vip = "Einen VIP vorbeischicken.",
    earthquake = "Ein Erdbeben starten.",
    create_patient = "Einen Patienten am Kartenrand erzeugen.",
    end_month = "Zum Monatsende springen.",
    end_year = "Zum Jahresende springen.",
    lose_level = "Das aktuelle Level verlieren.",
    win_level = "Das aktuelle Level gewinnen.",
    epidemic = "Einen infizierten Patienten, der eine Epidemie auslösen kann, erzeugen.",
    toggle_infected = "Die Infektions-Symbole für die aktive, entdeckte Epidemie umschalten.",
  }
}

folders_window = {
  data_label = "TH-Daten",
  music_location = "Wählen Sie hier das Verzeichnis, welches Sie für Ihre Musik benutzen möchten, aus.",
  music_label = "MP3s",
  new_th_location = "Hier können Sie ein neues Theme-Hospital-Installationsverzeichnis auswählen. Sobald Sie das neue Verzeichnis auswählen, wird das Spiel neu gestartet.",
  caption = "Verzeichnisort",
  screenshots_label = "Screenshots",
  font_label = "Schrift",
  savegames_label = "Spielstände",
  back = "Zurück",
  savegames_location = "Wählen Sie das Verzeichnis, welches Sie für Spielstände benutzen möchten, aus.",
  screenshots_location = "Wählen Sie das Verzeichnis, welches Sie für Screenshots benutzen möchten, aus.",
}

tooltip.folders_window = {
  browse_font = "Nach einer anderen Schriftdatei suchen (aktueller Ort: %1%)",
  browse_screenshots = "Nach einem anderem Ort für ihr Screenshotverzeichnis suchen (aktueller Ort: %1%)",
  reset_to_default = "Das Verzeichnis zur Standardeinstellung zurücksetzen",
  back = "Dieses Menü schließen und zum Einstellungsmenü zurückkehren",
  music_location = "Wählen Sie einen Ort für ihre MP3-Musikddateien aus. Sie müssen dieses Verzeichnis bereits erstellt haben, dann wählen Sie ebendieses Verzeichnis aus.",
  font_location = "Pfad einer Schrift-Datei, die Unicode-Zeichen Ihrer Sprache unterstützt. Wenn diese Einstellung nicht vorgenommen wird, können Sie keine Sprachen auswählen, die mehr Zeichen benötigen, als das Originalspiel unterstützt. Beispiel: Russisch und Chinesisch.",
  savegames_location = "Standardmäßig wird das Spielstandsverzeichnis im selben Verzeichnis wie die Konfigurationsdatei gespeichert und es wird benutzt, um die Spielstände darin abzuspeichern. Sollte das nicht erwünscht sein, können Sie sich ihr eigenes Verzeichnis aussuchen, wählen Sie einfach das Verzeichnis, das Sie verwenden möchten",
  screenshots_location = "Standardmäßig wird das Screenshotverzeichnis im selben Verzeichnis wie die Konfigurationsdatei gespeichert. Sollte das nicht erwünscht sein, können Sie sich ihr eigenes Verzeichnis aussuchen, wählen Sie einfach das Verzeichnis, das Sie verwenden möchten",
  browse_data = "Nach einem anderem Ort einer Theme-Hospital-Installation durchsuchen (aktueller Ort: %1%)",
  browse = "Nach einem Verzeichnis durchsuchen",
  browse_music = "Nach einem anderem Ort für Ihr Musikverzeichnis durchsuchen (aktueller Ort: %1%)",
  no_font_specified = "Es wurde kein Schriftverzeichnis festgelegt!",
  not_specified = "Es wurde kein Verzeichnis festgelegt!",
  browse_saves = "Nach einem anderem Ort für Ihr Spielstandsverzeichnis durchsuchen (aktueller Ort: %1%)",
  default = "Standardort",
  data_location = "Das Verzeichnis der Original-Theme-Hospital-Installation, welche benötigt wird, um CorsixTH zu spielen",
}

introduction_texts = {
  demo = {
    "Willkommen im Demo-Krankenhaus!",
    "Leider beinhaltet die Demo-Version nur dieses eine Level. Dafür gibt es hier aber mehr als genug zu tun, um Sie eine Weile zu beschäftigen!",
    "Sie werden diversen Krankheiten begegnen, die unterschiedliche Räume zur Behandlung benötigen. Ab und zu können auch Notfälle eintreffen. Und Sie werden mithilfe einer Forschungsabteilung neue Räume erforschen müssen.",
    "Ihr Ziel ist es, 100.000 DM zu verdienen, einen Krankenhauswert von 70.000 DM und einen Ruf von 700 vorzuweisen, und gleichzeitig mindestens 75% der Patienten erfolgreich zu behandeln.",
    "Stellen Sie sicher, dass Ihr Ruf nicht unter 300 fällt und dass Sie nicht mehr als 40% ihrer Patienten sterben lassen, oder Sie werden verlieren.",
    "Viel Glück!",
  },
}

calls_dispatcher = {
  summary = "%d Aufrufe; %d zugewiesen",
  staff = "%s - %s",
  watering = "Bewässern @ %d,%d",
  repair = "Repariert %s",
  close = "Schließen",
}

tooltip.calls_dispatcher = {
  task = "Liste der Aufgaben - Aufgabe anklicken, um das Fenster des zugewiesenen Personalmitglieds zu öffnen und zum Ort der Aufgabe zu scrollen.",
  assigned = "Diese Box ist markiert, wenn jemand der Aufgabe zugewiesen ist.",
  close = "Das Aufruf-Verteiler-Fenster schließen",
}

handyman_window = {
  all_parcels = "Alle Grundstücke",
  parcel = "Grundstück",
}

tooltip.handyman_window = {
  parcel_select = "Der Arbeitsbereich des Handlangers. Klicken zum Ändern.",
}

progress_report = {
  free_build = "FREIES SPIEL",
}

-------------------------------  FIX FOR MISSING CREDITS LINES  ----------------------------------

original_credits[301] = " "
original_credits[302] = " "
original_credits[303] = " "
original_credits[304] = " "
original_credits[305] = " "
original_credits[306] = " "
original_credits[307] = " "
original_credits[308] = " "
original_credits[309] = " "
original_credits[310] = " "
original_credits[311] = " "
original_credits[312] = " "
original_credits[313] = " "
original_credits[314] = " "
original_credits[315] = " "
original_credits[316] = " "
original_credits[317] = " "
original_credits[318] = " "
original_credits[319] = " "
original_credits[320] = " "
original_credits[321] = " "
original_credits[322] = " "
original_credits[323] = " "
original_credits[324] = " "
original_credits[325] = " "
original_credits[326] = " "
original_credits[327] = " "
original_credits[328] = " "
original_credits[329] = " "
original_credits[330] = " "
original_credits[331] = " "
original_credits[332] = " "
original_credits[333] = " "
original_credits[334] = " "
original_credits[335] = " "
original_credits[336] = " "
original_credits[337] = " "
original_credits[338] = " "
original_credits[339] = " "
original_credits[340] = " "
original_credits[341] = " "
original_credits[342] = " "
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
original_credits[361] = " "

--------------------------------  UNUSED  -----------------------------------
------------------- (kept for backwards compatibility) ----------------------

options_window.change_resolution = "Auflösung ändern"
tooltip.options_window.change_resolution = "Die Fensterauflösung auf die links eingegebenen Werte ändern"
