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
fax.vip_visit_query.vip_name = "%s hat den Wunsch geäußert, Ihr Krankenhaus besuchen zu wollen." -- text was missing
fax.vip_visit_query.choices.invite = "Lassen Sie dem V.I.P. eine offizielle Einladung zukommen." -- text was ferusing instead of inviting

fax.vip_visit_query.choices.refuse = "Speisen Sie den V.I.P. mit einer Entschuldigung ab." -- text was missing

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
fax.epidemic_result.compensation_amount = "Die Behörden haben beschlossen, Sie für die entstandene Rufschädigung mit %d zu entschädigen."
fax.epidemic_result.fine_amount = "Die Behörden haben den nationalen Notstand ausgerufen und sie zu einer Geldstrafe von %d verurteilt."
fax.epidemic_result.rep_loss_fine_amount = "Die Zeitungen haben Wind von der Epidemie bekommen und ziehen Ihren Ruf in den Dreck. Darüber hinaus hat man zu einer Geldstrafe von %d verurteilt."
fax.epidemic_result.hospital_evacuated = "Die Behörden haben keine andere Wahl, als Ihr Krankenhaus zu evakuieren."

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



-- reported as missing, although they are only in OVERRIDE section of english.lua
level_progress.hospital_value_enough = "Halten Sie den Wert des Krankenhauses über %d und kümmern Sie sich um ihre anderen Probleme um das Level zu gewinnen."
level_progress.cured_enough_patients = "Sie haben genug Patienten geheilt, aber die Qualität des Krankenhauses muss zunehmen um das Level zu gewinnen."

--
multiplayer.players_failed = "Der/die folgende(n) Spieler hat/haben das letzte Ziel nicht erreicht:"
multiplayer.everyone_failed = "Alle haben das letzte Ziel nicht erreicht. Also können alle weiterspielen!"

--
disease_discovered_patient_choice.need_to_employ = "Stellen Sie eine(n) %s ein um diese Situation lösen zu können."


-- remove invisible hyphens. unfortunately it is impossible to fix the wrong case, since
-- the case determines the font
policy = {
  diag_termination = "diagnoseerstellung",
  diag_procedure = "diagnoseverfahren",
}

-- remove hyphen since it makes it use the wrong font. again, the case cannot be fixed
casebook = {
  deaths = "ablebensfälle", --the ä looks weird as well
}

-- only drug_improved_1 is in OVERRIDE section of english.lua
-- ..._1 is used to prevent 'the the squits' AKA orig [4,30], which is simply "Durchfall"
-- so the sane thing is to duplicate drug_improved
adviser = {
  research = {
    drug_improved = "Die Effektivität Ihres %s-Medikaments wurde von Ihrer Forschungsabteilung verbessert.",
    drug_improved_1 = "Die Effektivität Ihres %s-Medikaments wurde von Ihrer Forschungsabteilung verbessert.",
  },
}

-------------------------------  NEW STRINGS  -------------------------------
date_format = {
  daymonth = "%1%. %2:months%",
}

object.litter = "Müll"
tooltip.objects.litter = "Müll: Wurde von einem Patienten fallen gelassen, nachdem er keinen Mülleimer fand."

object.rathole = "Rattenloch"
tooltip.objects.rathole = "Heimat einer Rattenfamilie, die Ihr Krankenhaus dreckig genug fand um hier zu leben."

tooltip.fax.close = "Das Fenster schließen, ohne die Nachricht zu löschen"
tooltip.message.button = "Linksklick, um die Nachricht zu öffnen"
tooltip.message.button_dismiss = "Linksklick, um die Nachricht zu öffnen, Rechtsklick um sie zu entfernen"
tooltip.casebook.cure_requirement.hire_staff = "Sie müssen Personal einstellen, um diese Behandlung durchführen zu können"
tooltip.casebook.cure_type.unknown = "Sie wissen noch nicht, wie Sie diese Krankheit behandeln können"
tooltip.research_policy.no_research = "In dieser Kategorie wird momentan keine Forschung durchgeführt"
tooltip.research_policy.research_progress = "Fortschritt in dieser Kategorie: %1%/%2%"

menu["player_count"] = "SPIELERZAHL"

menu_file = {
  load =    "  (%1%) LADEN  ",
  save =    "  (%1%) SPEICHERN   ",
  restart = "  (%1%) NEUSTART",
  quit =    "  (%1%) VERLASSEN   "
}

menu_options = {
  sound = "  (%1%) AUDIO   ",
  announcements = "  (%1%) DURCHSAGEN   ",
  music = "  (%1%) MUSIK   ",
  jukebox = "  (%1%) JUKEBOX  ",
  lock_windows     = "  FENSTER FESTHALTEN  ",
  edge_scrolling   = "  AM BILDSCHIRMRAND SCROLLEN  ",
  capture_mouse = "  MAUSZEIGER EINFANGEN  ",
  adviser_disabled = "  (%1%) BERATER  ",
  warmth_colors    = "  FARBEN FÜR WÄRMEDARSTELLUNG  ",
  wage_increase = "  GEHALTSERHÖHUNGEN  ",
  twentyfour_hour_clock = "  24-STUNDEN-UHR  ",
}

menu_options_game_speed = {
  pause               = "  (%1%) PAUSE  ",
  slowest             = "  (%1%) AM LANGSAMSTEN  ",
  slower              = "  (%1%) LANGSAM  ",
  normal              = "  (%1%) NORMAL  ",
  max_speed           = "  (%1%) MAXIMALE GESCHWINDIGKEIT  ",
  and_then_some_more  = "  (%1%) UND NOCH MEHR  ",
}

menu_options_warmth_colors = {
  choice_1 = "  ROTTÖNE  ",
  choice_2 = "  BLAU-GRÜN-ROT  ",
  choice_3 = "  GELB-ORANGE-ROT  ",
}

menu_options_wage_increase = {
  grant = "    GEWÄHREN ",
  deny =  "    ABLEHNEN ",
}

-- Add F-keys to entries in charts menu (except briefing), also town_map was added.
menu_charts = {
  bank_manager  = "  (%1%) BANK-MANAGER  ",
  statement     = "  (%1%) BILANZ  ",
  staff_listing = "  (%1%) PERSONALLISTE  ",
  town_map      = "  (%1%) ÜBERSICHTSKARTE  ",
  casebook      = "  (%1%) BEHANDLUNGSMAPPE  ",
  research      = "  (%1%) FORSCHUNG  ",
  status        = "  (%1%) STATUS  ",
  graphs        = "  (%1%) DIAGRAMME  ",
  policy        = "  (%1%) EINSTELLUNGEN  ",
}



-- The demo does not contain this string
menu_file.restart = "  NEUSTART  "

menu_debug = {
  jump_to_level               = "  SPRINGE ZU LEVEL  ",
  connect_debugger            = "  (%1%) ZUM LUA-DEBUG-SERVER VERBINDEN  ",
  transparent_walls           = "  (%1%) DURCHSICHTIGE WÄNDE  ",
  limit_camera                = "  KAMERA BEGRENZEN  ",
  disable_salary_raise        = "  KEINE GEHALTSERHÖHUNGEN  ",
  allow_blocking_off_areas    = "  ERLAUBE BEREICHE ZU SPERREN  ",
  make_debug_fax              = "  DEBUG-FAX ERSTELLEN  ",
  make_debug_patient          = "  DEBUG-PATIENTEN ERSTELLEN  ",
  cheats                      = "  (%1%) CHEATS  ",
  lua_console                 = "  (%1%) LUA-KONSOLE  ",
  debug_script                = "  (%1%) DEBUG-SKRIPT STARTEN  ",
  calls_dispatcher            = "  AUFRUF-VERTEILER  ",
  dump_strings                = "  TEXTE ABSPEICHERN  ",
  dump_gamelog                = "  (STRG+D) SPIELPROTOKOLL ABSPEICHERN  ",
  map_overlay                 = "  KARTEN-OVERLAY  ",
  sprite_viewer               = "  SPRITE-BETRACHTER  ",
}
menu_debug_overlay = {
  none                        = "  KEIN  ",
  flags                       = "  FLAGS  ",
  positions                   = "  POSITION  ",
  heat                        = "  TEMPERATUR  ",
  byte_0_1                    = "  BYTE 0 & 1  ",
  byte_floor                  = "  BYTE BODEN  ",
  byte_n_wall                 = "  BYTE N-WAND  ",
  byte_w_wall                 = "  BYTE W-WAND  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  GRUNDSTÜCK  ",
}
menu_player_count = {
  players_1 = "  1 Spieler  ",
  players_2 = "  2 Spieler  ",
  players_3 = "  3 Spieler  ",
  players_4 = "  4 Spieler  ",
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
    another_desk = "Sie müssen einen weitere Rezeption für die neue Empfangsdame bauen.",
    cannot_afford = "Sie haben nicht genügend Geld auf dem Konto, um diese Person einzustellen!",
    cannot_afford_2 = "Sie haben nicht genügend Geld auf dem Konto, um dies zu kaufen!",
    falling_1 = "He! Vorsicht mit dem Mauszeiger, jemand könnte sich verletzen!",
    falling_2 = "Hören Sie schon auf damit, wie würde das Ihnen denn gefallen?",
    falling_3 = "Autsch, das sah schmerzhaft aus. Ruft einen Arzt!",
    falling_4 = "Dies ist ein Krankenhaus, kein Vergnügungspark!",
    falling_5 = "Sie sind nicht hier um Leute umzustoßen. Sie sind krank, okay?",
    falling_6 = "Dies ist keine Bowlingbahn. Patienten sollten nicht so behandelt werden!",
    research_screen_open_1 = "Sie müssen eine Forschungseinrichtung errichten, um auf das Forschungsmenü zugreifen zu können.",
    research_screen_open_2 = "Forschung ist im aktuellen Level nicht verfügbar.",
    researcher_needs_desk_1 = "Ein Forscher braucht einen Schreibtisch, um daran arbeiten zu können.",
    researcher_needs_desk_2 = "Ihr Forscher ist froh darüber, dass Sie ihm eine Pause gegönnt haben. Falls Sie vorhatten, dass noch mehr Personal forscht, dann müssen Sie jedem Forscher einen eigenen Schreibtisch zur Verfügung stellen.",
    researcher_needs_desk_3 = "Jeder Forscher braucht einen eigenen Schreibtisch, an dem er arbeiten kann.",
    nurse_needs_desk_1 = "Jede Krankenschwester braucht ihren eignen Schreibtisch, an dem sie arbeiten kann.",
    nurse_needs_desk_2 = "Ihre Krankenschwester ist froh darüber, dass Sie ihr eine Pause gegönnt haben. Falls Sie vorhatten, dass mehr als nur eine Krankenschwester in der Station arbeitet, dann müssen Sie jeder Krankenschwester einen eigenen Schreibtisch zur Verfügung stellen.",
    low_prices = "Sie berechnen zu wenig für %s. Dadurch bekommen Sie viele Patienten, verdienen aber wenig an jedem einzelnen von ihnen.",
    high_prices = "Sie berechnen zu viel für %s. Dadurch verdienen Sie kurzfristig viel Geld, aber langfristig vertreiben Sie die damit Patienten aus ihrem Krankenhaus.",
    fair_prices = "Die Behandlungskosten für %s sind fair und angemessen.",
    patient_not_paying = "Ein Patient ist gegangen ohne für %s zu bezahlen weil es zu teuer ist!",
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
dynamic_info.staff.actions.vaccine = "Impft einen Patienten"
dynamic_info.patient.actions.epidemic_vaccinated = "Ich bin nicht mehr ansteckend"
dynamic_info.object.strength_extra_info = "Stärke %d (Regenerierbar zu %d)" -- literal translation would be "erweiterbar"

progress_report.free_build = "FREIES SPIEL"

fax = {
  choices = {
    return_to_main_menu = "Ins Hauptmenü zurückkehren",
    accept_new_level = "Zum nächsten Level wechseln",
    decline_new_level = "Noch ein wenig im aktuellen Level weiterspielen",
  },
  emergency = {
    num_disease_singular = "Hier ist eine Person mit %s, sie braucht sofortige Aufmerksamkeit.",
    free_build = "Wenn wir erfolgreich sind, wird unser Ruf steigen. Falls wir versagen, wird unser Ruf Schaden nehmen.",
  },
  vip_visit_result = {
    remarks = {
      free_build = {
        "Echt ein hübsches Krankenhaus haben Sie da! War aber wohl nicht so schwer zum Laufen zu bekommen, so ohne finanzielle Beschränkungen, was? Haha ...",
        "Ich bin zwar kein BWLer, aber ich denke, dieses Krankenhaus könnte ich auch führen. Sie wissen schon, was ich meine.",
        "Ein gut organisiertes Krankenhaus. Aber hüten Sie sich vor der Finanzkrise! Ach ja ... da müssen Sie sich ja keine Sorgen machen.",
      }
    }
  }
}

letter = {
  dear_player = "Hallo %s\n",
  custom_level_completed = "Gut gemacht! Sie haben alle Ziele dieses eigenen Levels erreicht!",
  return_to_main_menu = "Möchten Sie ins Hauptmenü zurückkehren, oder weiterspielen?",
  campaign_level_completed = "Gute Arbeit! Sie haben das Level geschafft. Aber es ist noch nicht vorbei!\n Möchten Sie eine Position im %s Krankenhaus?",
  campaign_completed = "Unglaublich! Sie haben alle Level abgeschlossen. Nun können Sie sich entspannen und genießen Foren mit Berichten ihrer Heldentaten zu fluten. Viel Glück!",
  campaign_level_missing = "Entschuldigung, aber das nächste Level dieser Kampagne scheint zu fehlen. (Name: %s)",
}

install = {
  title = "----------------------------- CorsixTH-Konfiguration -----------------------------",
  th_directory = "CorsixTH benötigt einige Dateien des Originalspiels Theme Hospital (oder der Demo davon), um zu funktionieren. Bitte das Installationsverzeichnis von Theme Hospital auswählen.",
  ok = "OK",
  exit = "Beenden",
  cancel = "Abbrechen",
}

misc.not_yet_implemented = "(noch nicht implementiert)"
misc.no_heliport = "Entweder wurden noch keine Krankheiten entdeckt, oder es existiert kein Heliport auf dieser Karte."
misc.cant_treat_emergency = "Ihr Krankenhaus kann diesen Notfall nicht behandeln, da die entsprechende Krankheit noch nicht entdeckt wurde. Versuchen Sie es später wieder."

main_menu = {
  new_game = "Kampagne",
  custom_campaign = "Benutzerdef. Kampagne", -- everything sensible is too long
  custom_level = "Einzelnes Level",
  continue = "Spiel fortsetzen",
  load_game = "Spiel laden",
  options = "Optionen",
  map_edit = "Karten-Editor",
  savegame_version = "Spielstandsversion: ",
  version = "Version: ",
  exit = "Verlassen",
}

tooltip.main_menu = {
  new_game = "Das erste Level der Kampagne beginnen",
  custom_campaign = "Eine von Nutzern erstellte Kampagne spielen",
  custom_level = "Ein Krankenhaus in einem einzelnem Level errichten",
  continue = "Den letzten Spielstand fortsetzen",
  load_game = "Ein zuvor gespeichertes Spiel fortsetzen",
  options = "Diverse Einstellungen verändern",
  map_edit = "Eine eigene Karte erstellen",
  exit = "Bitte lassen Sie mich nicht allein!",
  quit = "Sie sind im Begriff, CorsixTH zu verlassen. Sind Sie sich sicher, dass Sie das tun wollen?",
}

load_game_window = {
  caption = "Spiel laden (%1%)",
}

tooltip.load_game_window = {
  load_game = "Spiel %s laden",
  load_game_number = "Spiel %d laden",
  load_autosave = "Automatisch gespeichertes Spiel laden",
}

custom_game_window = {
  caption = "Einzelnes Level",
  free_build = "Freies Spiel",
  load_selected_level = "Los",
}

tooltip.custom_game_window = {
  choose_game = "Ein Level auswählen, um mehr über es zu erfahren",
  free_build = "Auswählen, um mit unbegrenztem Geld und ohne Sieg- bzw. Niederlagebedingungen zu spielen",
  load_selected_level = "Ausgewähltes Level laden und spielen",
}

custom_campaign_window = {
  caption = "Eigene Kampagne",
  start_selected_campaign = "Kampagne starten",
}

tooltip.custom_campaign_window = {
  choose_campaign = "Eine Kampagne auswählen, um mehr über sie zu erfahren",
  start_selected_campaign = "Das erste Level dieser Kampagne laden",
}

save_game_window = {
  caption = "Spiel Speichern",
  new_save_game = "Neuer Spielstand",
}

tooltip.save_game_window = {
  save_game = "Spielstand %s überschreiben",
  new_save_game = "Namen für einen neuen Spielstand eingeben",
}

save_map_window = {
  caption = "Karte speichern (%1%)",
  new_map = "Neue Karte",
}

tooltip.save_map_window = {
  map = "Karte %s überschreiben",
  new_map = "Namen für Karten-Speicherstand eingeben",
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

-- Scroll vs Scrolling: I would tend to use Scroll, but Duden suggests Scrolling
options_window = {
  caption = "Einstellungen",
  option_on = "Ein",
  option_off = "Aus",
  fullscreen = "Vollbild",
  resolution = "Auflösung",
  capture_mouse = "Maus einfangen",
  custom_resolution = "Benutzerdefiniert...",
  width = "Breite",
  height = "Höhe",
  customise = "Spezialeinstellungen",
  folder = "Pfade",
  language = "Spielsprache",
  apply = "Übernehmen",
  cancel = "Abbrechen",
  back = "Zurück",
  scrollspeed = "Scrolling", -- "Scrolling-Geschwindigkeit" is too long
  shift_scrollspeed = "Scrolling (Mod.)", --"schnelles Scrollen" or "Umschalt-Scrolling-Geschwindigkeit" are worse
  zoom_speed = "Zoomen", --"Zoom-Geschwindigkeit" is too long
  hotkey = "Tastenkürzel",
}

tooltip.options_window = {
  fullscreen = "Darstellung im Vollbild- oder Fenstermodus",
  fullscreen_button = "Klicken, um zwischen Vollbild- und Fenstermodus zu wechseln",
  resolution = "Die Bildschirmauflösung, in der das Spiel läuft",
  select_resolution = "Eine neue Auflösung auswählen",
  capture_mouse = "Ein- bzw. Ausschalten, ob der Mauszeiger das Fenster verlassen kann",
  width = "Gewünschte Bildschirmbreite eingeben",
  height = "Gewünschte Bildschirmhöhe eingeben",
  apply = "Die eingegebene Auflösung übernehmen",
  cancel = "Zurückkehren, ohne die Auflösung zu ändern",
  customise_button = "Weitere Einstellungen, die Sie ändern können, um Ihr Spielerlebnis anzupassen",
  folder_button = "Verzeichniseinstellungen",
  language = "Die Sprache, in der Texte im Spiel erscheinen",
  select_language = "Die Spielsprache ändern",
  language_dropdown_item = "%s als Sprache auswählen",
  back = "Das Optionsfenster schließen",
  scrollspeed = "Scrolling-Geschwindigkeit von 1 (langsamste) bis 10 (schnellste) einstellen. Standard ist 2.",
  shift_scrollspeed = "Scrolling-Geschwindigkeit während der Modifikator (Standard: Umschalttaste) gedrückt wird einstellen. 1 (langsamste) bis 10 (schnellste). Standard ist 4.",
  zoom_speed = "Zoom-Geschwindigkeit der Kamera von 10 (langsamste) bis 1000 (schnellste) einstellen. Standard ist 80.",
  apply_scrollspeed = "Eingegebene Scrolling-Geschwindigkeit anwenden.",
  cancel_scrollspeed = "Ohne Änderung der Scrolling-Geschwindigkeit zurückkehren.",
  apply_shift_scrollspeed = "Eingegebene Modifikator-Scrolling-Geschwindigkeit anwenden.",
  cancel_shift_scrollspeed = "Ohne Änderung der Modifikator-Scrolling-Geschwindigkeit zurückkehren.",
  apply_zoomspeed = "Eingegebene Zoom-Geschwindigkeit anwenden.",
  cancel_zoomspeed = "Ohne Änderung der Zoom-Geschwindigkeit zurückkehren.",
  hotkey = "Tastenkürzel ändern.",
}

audio_window = {
  audio = "Audio", -- "Globale Audio-Einstellungen" would match eng, but it's too long
  jukebox = "Jukebox",
  back = "Zurück",
}

tooltip.audio_window = {
  audio_button = "Sämtliche Toneffekte des Spiels ein- bzw. ausschalten",
  audio_toggle = "Ein- oder ausschalten",
}

customise_window = {
  caption = "Spezialeinstellungen",
  option_on = "Ein",
  option_off = "Aus",
  back = "Zurück",
  movies = "Alle Filme zeigen",
  intro = "Introfilm abspielen",
  paused = "In Pause bauen",
  volume = "Leiser-Taste",
  aliens = "Alien-Patienten", -- "Außerirdische Patienten"/"Ex­t­ra­ter­res­t­risch Patienten" is too long
  fractured_bones = "Gebrochene Knochen",
  average_contents = "Einrichtung merken",
  remove_destroyed_rooms = "Behebbare Zerstörung", -- "Entfernbare zerstörte Räume" is too long
}

tooltip.customise_window = {
  movies = "Globale Filmsteuerung: Hiermit können Sie sämtliche Filme abschalten",
  intro = "Den Introfilm abschalten. Das Intro wird nur gespielt, wenn Sie nicht auch gleichzeitig alle Filme abgeschaltet haben.",
  paused = "In Theme Hospital würde es dem Spieler während der Pause nur gestattet sein, das obere Menü zu benutzen. Dies ist in CorsixTH ebenfalls die Standardeinstellung, aber wenn Sie dies einschalten, ist alles in der Pause erlaubt.",
  volume = "Wenn die Leiser-Taste auch das Fallbuch öffnet, dann schalten Sie dies ein, um die Schnellzugriffstaste für das Fallbuch auf Umschalt + C zu wechseln.",
  aliens = "Aufgrund des Fehlens einer anständigen Animation haben wir standardmäßig Patienten mit außerirdischer DNA deaktiviert, damit sie nur zu einem Notfall kommen. Um Patienten mit außerirdischer DNA es zu erlauben, Ihr Krankenhaus nicht nur bei Notfällen zu besuchen, schalten Sie dies ab.",
  fractured_bones = "Aufgrund einer armseligen Animation haben wir uns entschieden, dass es standardmäßig keine weiblichen Patienten mit gebrochenen Knochen gibt. Wenn weibliche Patienten mit gebrochenen Knochen Ihr Krankenhaus besuchen sollen, dann schalten Sie dies ab.",
  average_contents = "Wenn Sie möchten, dass sich das Spiel merkt, welche zusätzlichen Objekte Sie üblicherweise beim Gebäudebau hinzufügen, dann schalten Sie diese Option ein.",
  remove_destroyed_rooms = "Aktivieren Sie diese Option wenn Sie wollen, dass zerstörte Räume nach Zahlung einer Gebühr entfernt werden können.",
  back = "Dieses Menü schließen und zum Einstellungsmenü zurückkehren",
}

folders_window = {
  caption = "Pfade",
  data_label = "TH-Daten",
  font_label = "Schrift",
  music_label = "Musik",
  savegames_label = "Spielstände",
  screenshots_label = "Screenshots",
  --
  new_th_location = "Hier können Sie ein neues Theme-Hospital-Installationsverzeichnis auswählen. Sobald Sie das neue Verzeichnis auswählen, wird das Spiel neu gestartet.",
  savegames_location = "Wählen Sie das Verzeichnis aus, das für Spielstände benutzt werden soll.",
  music_location = "Wählen Sie hier das Verzeichnis aus, in dem sich Ihre Musik befindet.",
  screenshots_location = "Wählen Sie das Verzeichnis aus, das für Screenshots benutzt werden soll.",
  back = "Zurück",
}

tooltip.folders_window = {
  browse = "Nach einem Verzeichnis durchsuchen",
  data_location = "Das Verzeichnis der original Theme-Hospital-Installation, die benötigt wird, um CorsixTH zu spielen",
  font_location = "Pfad einer Schrift-Datei, die Unicode-Zeichen Ihrer Sprache unterstützt. Wenn diese Einstellung nicht vorgenommen wird, können Sie keine Sprachen auswählen, die mehr Zeichen benötigen, als das Originalspiel unterstützt. Beispiel: Russisch und Chinesisch.",
  savegames_location = "Standardmäßig wird das Spielstandsverzeichnis im selben Verzeichnis wie die Konfigurationsdatei gespeichert und es wird benutzt, um die Spielstände darin abzuspeichern. Sollte das nicht erwünscht sein, können Sie sich ihr eigenes Verzeichnis aussuchen, wählen Sie einfach das Verzeichnis, das Sie verwenden möchten",
  screenshots_location = "Standardmäßig wird das Screenshotverzeichnis im selben Verzeichnis wie die Konfigurationsdatei gespeichert. Sollte das nicht erwünscht sein, können Sie sich ihr eigenes Verzeichnis aussuchen, wählen Sie einfach das Verzeichnis, das Sie verwenden möchten",
  music_location = "Wählen Sie einen Ort für ihre Musikddateien aus. Das Verzeichnis muss bereits vorhanden sein.",
  browse_data = "Nach einem anderem Ort einer Theme-Hospital-Installation durchsuchen (aktueller Ort: %1%)",
  browse_font = "Nach einer anderen Schriftdatei suchen (aktueller Ort: %1%)",
  browse_saves = "Nach einem anderem Ort für Ihr Spielstandsverzeichnis durchsuchen (aktueller Ort: %1%)",
  browse_screenshots = "Nach einem anderem Ort für ihr Screenshotverzeichnis suchen (aktueller Ort: %1%)",
  browse_music = "Nach einem anderem Ort für Ihr Musikverzeichnis durchsuchen (aktueller Ort: %1%)",
  no_font_specified = "Kein Schriftverzeichnis festgelegt!",
  not_specified = "Kein Verzeichnis festgelegt!",
  default = "Standard",
  reset_to_default = "Das Verzeichnis zur Standardeinstellung zurücksetzen",
  --
  back = "Dieses Menü schließen und zum Einstellungsmenü zurückkehren",
}

hotkey_window = {
  caption_main = "Tastenkürzel-Zuweisungen",
  caption_panels = "Dialog-Tasten",
  button_accept = "Übernehmen",
  button_defaults = "Einstellungen zurücksetzen",
  button_cancel = "Abbrechen",
  button_back = "Zurück",
  button_toggleKeys = "Umschalt-Tasten",
  button_gameSpeedKeys = "Spielgeschwindigkeits-Tasten",
  button_recallPosKeys = "Positions-Tasten",
  panel_globalKeys = "Globale Tasten",
  panel_generalInGameKeys = "Generelle Tasten",
  panel_scrollKeys = "Scrolling-Tasten",
  panel_zoomKeys = "Zoom-Tasten",
  panel_gameSpeedKeys = "Spielgeschwindigkeits-Tasten",
  panel_toggleKeys = "Umschalt-Tasten",
  panel_debugKeys = "Debug-Tasten",
  panel_storePosKeys = "Position merken",
  panel_recallPosKeys = "Position abrufen",
  panel_altPanelKeys = "Alternative Dialog-Tasten",
  global_confirm = "Bestätigen",
  global_confirm_alt = "Bestätigen (alternativ)",
  global_cancel = "Abbrechen",
  global_cancel_alt = "Abbrechen (alternativ)",
  global_fullscreen_toggle = "Vollbild",
  global_exitApp = "App verlassen",
  global_resetApp = "App zurücksetzen",
  global_releaseMouse = "Mauszeiger freigeben",
  global_connectDebugger = "Debugger",
  global_showLuaConsole = "Lua-Konsole",
  global_runDebugScript = "Skript debuggen",
  global_screenshot = "Screenshot",
  global_stop_movie_alt = "Film abbrechen",
  global_window_close_alt = "Fenster schließen",
  ingame_scroll_up = "Nach oben scrollen",
  ingame_scroll_down = "Nach unten scrollen",
  ingame_scroll_left = "Nach links scrollen",
  ingame_scroll_right = "Nach rechts scrollen",
  ingame_scroll_shift = "Geschwindigkeitsmodifikator",
  ingame_zoom_in = "Herein zoomen",
  ingame_zoom_in_more = "Weiter herein zoomen",
  ingame_zoom_out = "Heraus zoomen",
  ingame_zoom_out_more = "Weiter heraus zoomen",
  ingame_reset_zoom = "Zoom zurücksetzen",
  ingame_showmenubar = "Menüleiste zeigen",
  ingame_showCheatWindow = "Cheat-Menü",
  ingame_loadMenu = "Spiel laden",
  ingame_saveMenu = "Spiel speichern",
  ingame_jukebox = "Jukebox",
  ingame_openFirstMessage = "Level-Nachrichten",
  ingame_pause = "Pause",
  ingame_gamespeed_slowest = "Langsamst",
  ingame_gamespeed_slower = "Langsam",
  ingame_gamespeed_normal = "Normal",
  ingame_gamespeed_max = "Maximum",
  ingame_gamespeed_thensome = "Noch mehr",
  ingame_gamespeed_speedup = "Beschleunigen",
  ingame_panel_bankManager = "Bank-Manager",
  ingame_panel_bankStats = "Bank-Status",
  ingame_panel_staffManage = "Personal verwalten",
  ingame_panel_townMap = "Übersichtskarte",
  ingame_panel_casebook = "Behandlungsmappe",
  ingame_panel_research = "Forschung",
  ingame_panel_status = "Status",
  ingame_panel_charts = "Diagramme",
  ingame_panel_policy = "Einstellungen",
  ingame_panel_map_alt = "Übersichtskarte 2",
  ingame_panel_research_alt = "Forschung 2",
  ingame_panel_casebook_alt = "Behandlungsmappe 2",
  ingame_panel_casebook_alt02 = "Behandlungsmappe 3",
  ingame_panel_buildRoom = "Raum bauen",
  ingame_panel_furnishCorridor = "Flur möblieren",
  ingame_panel_editRoom = "Raum bearbeiten",
  ingame_panel_hireStaff = "Personal einstellen",
  ingame_rotateobject = "Gegenstand rotieren",
  ingame_quickSave = "Schnellspeichern",
  ingame_quickLoad = "Schnellladen",
  ingame_restartLevel = "Level zurücksetzen",
  ingame_quitLevel = "Level verlassen",
  ingame_setTransparent = "Transparenz",
  ingame_toggleAnnouncements = "Durchsagen",
  ingame_toggleSounds = "Klänge",
  ingame_toggleMusic = "Musik",
  ingame_toggleAdvisor = "Ratgeber",
  ingame_toggleInfo = "Info",
  ingame_poopLog = "Protokoll-Dump", -- Duden says it's okay
  ingame_poopStrings = "Übersetzungs-Dump",
  ingame_patient_gohome = "Nach Hause schicken",
  ingame_storePosition_1 = "1",
  ingame_storePosition_2 = "2",
  ingame_storePosition_3 = "3",
  ingame_storePosition_4 = "4",
  ingame_storePosition_5 = "5",
  ingame_storePosition_6 = "6",
  ingame_storePosition_7 = "7",
  ingame_storePosition_8 = "8",
  ingame_storePosition_9 = "9",
  ingame_storePosition_0 = "10",
  ingame_recallPosition_1 = "1",
  ingame_recallPosition_2 = "2",
  ingame_recallPosition_3 = "3",
  ingame_recallPosition_4 = "4",
  ingame_recallPosition_5 = "5",
  ingame_recallPosition_6 = "6",
  ingame_recallPosition_7 = "7",
  ingame_recallPosition_8 = "8",
  ingame_recallPosition_9 = "9",
  ingame_recallPosition_0 = "10",
}

tooltip.hotkey_window = {
  button_accept = "Tastenkürzel-Zuweisungen übernehmen und speichern",
  button_defaults = "Alle Tastenkürzel auf Standard zurücksetzen",
  button_cancel = "Zuweisung abbrechen und zum Optionsmenü zurückkehren",
  caption_panels = "Fenster zur Zuweisung von Dialog-Tasten öffnen",
  button_gameSpeedKeys = "Fenster zur Zuweisung von Tasten zur Steuerung der Spielgeschwindigkeit öffnen",
  button_recallPosKeys = "Fenster zur Zuweisung von Tasten zum Merken und Abrufen der Kameraposition öffnen",
  button_back_02 = "Zurück zum generellen Tastenkürzel-Fenster. Geänderte Tastenkürzel aus diesem Fenster können dort akzeptiert werden",
}

font_location_window = {
  caption = "Schrift wählen (%1%)",
}

handyman_window = {
  all_parcels = "Alle Grundstücke",
  parcel = "Grundstück",
}

tooltip.toolbar = {
  machine_menu = "Maschinenmenü",
}

tooltip.handyman_window = {
  parcel_select = "Der Arbeitsbereich des Handlangers. Klicken zum Ändern.",
}

new_game_window = {
  caption = "Neues Spiel",
  player_name = "Spielername",
  option_on = "Ein",
  option_off = "Aus",
  difficulty = "Schwierigkeit",
  easy = "AIP (Einfach)",
  medium = "Arzt (Mittel)",
  hard = "Berater (Schwer)",
  tutorial = "Tutorial", -- Duden says it's okay
  start = "Start",
  cancel = "Abbrechen",
}

tooltip.new_game_window = {
  player_name = "Geben Sie den Namen ein, mit dem Sie im Spiel genannt werden möchten",
  difficulty = "Hier kann der Schwierigkeitsgrad des Spiels eingestellt werden",
  easy = "Die richtige Option für Simulations-Neulinge",
  medium = "Der Mittelweg - für diejenigen, die sich nicht entscheiden können",
  hard = "Wer diese Art von Spielen schon gewöhnt ist und eine Herausforderung will, sollte hier klicken",
  tutorial = "Dieses Feld abhaken, um zu Beginn des Spieles eine Einführung zu erhalten",
  start = "Das Spiel mit den gewählten Einstellungen starten",
  cancel = "Oh, eigentlich wollte ich gar kein neues Spiel starten!",
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
  no_games_to_contine = "Es gibt keine Spielstände.",
  load_quick_save = "Fehler: Der Schnellspeicherspielstand konnte nicht geladen werden, weil er nicht existiert. Kein Grund zur Sorge, wir haben nun einen für Sie erzeugt!",
  map_file_missing = "Die Kartendatei %s für das Level konnte nicht gefunden werden!",
  minimum_screen_size = "Bitte eine Auflösung von mindestens 640×480 eingeben.",
  unavailable_screen_size = "Die gewünschte Auflösung ist im Vollbildmodus nicht verfügbar.",
  alien_dna = "BEACHTEN SIE: Für außerirdische Patienten gibt es keine Animationen für das Sitzen, das Öffnen von Türen, das Anklopfen, usw. Daher werden sie, wie bei Theme Hospital, normal aussehen und sich dann wieder zurückverwandeln. Patienten mit außerirdischer DNA werden nur auftauchen, wenn sie in der Leveldatei gesetzt sind.",
  fractured_bones = "BEACHTEN SIE: Die Animation für weibliche Patienten mit gebrochenen Knochen ist nicht perfekt.",
  could_not_load_campaign = "Konnte die Kampagne nicht laden: %s",
  could_not_find_first_campaign_level = "Konnte das erste Level dieser Kampagne nicht finden: %s",
  save_to_tmp = "Die Datei %s konnte nicht verwendet werden. Das Spiel wurde als %s gespeichert. Fehler: %s",
  dialog_empty_queue = "Entschuldigung, eine Person hat keine weiteren Aktionen geplant und weiß nicht weiter. Weitere Details hierzu können der Konsole entnommen werden. Soll die Person das Krankenhaus verlassen?",
  compatibility_error = {
    new_in_old = "Entschuldigung, dieser Spielstand wurde mit einer neueren Version von CorsixTH erstellt und ist inkompatibel. Bitte wechseln Sie zu einer aktuelleren Version.",
    demo_in_full = "Entschuldigung, ein Spielstand der Demo kann nicht mit den Spieldaten der Vollversion geladen werden. Bitte passen Sie ihre TH-Daten-Einstellung an.",
    full_in_demo = "Entschuldigung, ein Spielstand der Vollversion kann nicht mit den Spieldaten der Demo geladen werden. Bitte passen Sie ihre TH-Daten-Einstellung an.",
  },
}

warnings = {
  levelfile_variable_is_deprecated = "Hinweise: Das Level '%s' enthält eine veraltete Variablendefinition." ..
                                     "'%LevelFile' wurde in '%MapFile' umbenannt. Bitte informieren Sie den Autor, dass er das Level aktualisieren sollte.",
  newersave = "Warnung: Sie haben einen Spielstand von einer neueren Version von CorsixTH geladen. Es ist nicht empfehlenswert fortzufahren, da es zu Abstürzen kommen kann. Weiterspielen auf eigenes Risiko."
}

confirmation = {
  needs_restart = "Um diese Änderung, vorzunehmen muss CorsixTH neu gestartet werden. Nicht gespeicherter Fortschritt geht verloren. Sicher, dass Sie fortfahren wollen?",
  abort_edit_room = "Sie bauen oder ändern gerade einen Raum. Wenn alle benötigten Objekte platziert sind, wird der Raum fertiggestellt, ansonsten wird er gelöscht. Fortfahren?",
  maximum_screen_size = "Die von Ihnen gewählte Bildschirmauflösung ist größer als 3000×2000. Größere Auflösungen sind möglich, aber erfordern eine bessere Hardware, um eine akzeptable Bildwiederholrate zu gewährleisten. Sind Sie sich sicher, dass Sie fortfahren möchten?",
  remove_destroyed_room = "Möchten Sie den Raum für $%d entfernen?",
  replace_machine_extra_info = "Die neue Maschine wird eine Stärke von %d haben (aktuell %d).",
}

information = {
  custom_game = "Willkommen zu CorsixTH. Viel Spaß mit diesem eigenen Level!",
  no_custom_game_in_demo = "Tut uns Leid, aber in der Demo-Version sind keine eigenen Level spielbar.",
  cannot_restart = "Leider wurde dieses eigene Level vor Implementierung des Neustart-Features gespeichert.",
  very_old_save = "Seit dieses Level gestartet wurde, wurden einige Änderungen am Spiel durchgeführt. Sie sollten ein neues Spiel starten, damit alle Änderungen wirksam werden.",
  level_lost = {
    "So ein Mist! Sie haben das Level leider nicht geschafft. Vielleicht klappt's ja beim nächsten Mal!",
    "Der Grund, warum Sie verloren haben:",
    reputation = "Ihr Ruf ist unter %d gesunken.",
    balance = "Ihr Kontostand ist unter %d gesunken.",
    percentage_killed = "Sie haben mehr als %d Prozent der Patienten getötet.",
    cheat = "Sie haben das selbst so gewollt. Oder haben Sie etwa auf den falschen Knopf gedrückt? Sie können also nicht mal richtig schummeln. Traurig.",
  },
  cheat_not_possible = "Dieser Cheat ist in diesem Level nicht verfügbar. Sogar beim Schummeln versagen Sie, wie armselig!",
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
    "Im Optionsmenü hier im Hauptmenü oder im laufenden Spiel können Einstellungen wie die Auflösung oder die Sprache geändert werden.",
    "Haben Sie eine andere Sprache als Englisch ausgewählt, aber es erscheinen englische Texte? Helfen Sie uns, die Übersetzung zu vervollständigen, indem Sie fehlende Texte in Ihre Sprache übersetzten!",
    "Das CorsixTH-Team sucht Verstärkung! Haben Sie Interesse, beim Programmieren, Übersetzen oder der Grafikerstellung zu helfen? Kontaktieren Sie uns in unserem Forum, der Mailing-Liste oder unserem IRC-Kanal (#Corsix-TH auf Freenode).",
    "Wenn Sie einen Bug finden, bitte melden Sie ihn in unserem Bug-Tracker: th-issues.corsix.org",
    "In jedem Level müssen bestimmte Voraussetzungen erfüllt werden, bevor man zum Nächsten wechseln kann. Im Status-Fenster können Sie Ihren Fortschritt bezüglich der Levelziele sehen.",
    "Um existierende Räume zu bearbeiten oder gar zu löschen, kann man den Raum-Bearbeiten-Knopf in der unteren Werkzeugleiste verwenden.",
    "Um aus einer Horde wartender Patienten diejenigen zu finden, die für einen bestimmten Raum warten, einfach mit dem Mauszeiger über den entsprechenden Raum fahren.",
    "Klicken Sie auf die Tür eines Raumes, um seine Warteschlange zu sehen. Hier kann man nützliche Feineinstellungen vornehmen, wie etwa die Warteschlange umsortieren oder einen Patienten zu einem anderen Raum senden.",
    "Unglückliches Personal verlangt öfter Gehaltserhöhungen. Gestalten Sie die Arbeitsumgebung Ihres Personals möglichst angenehm, um dies zu verhindern.",
    "Patienten werden beim Warten durstig, besonders wenn die Heizungen aufgedreht sind! Strategisch platzierte Getränkeautomaten sind eine nette zusätzliche Einnahmequelle.",
    "Sie können die Diagnose für einen Patienten vorzeitig abbrechen und ihn direkt zur Behandlung schicken, falls seine Krankheit zuvor schon entdeckt wurde. Allerdings erhöht sich dadurch das Risiko, dass das Heilmittel falsch ist und der Patient stirbt.",
    "Notfälle können eine gute Einnahmequelle abgeben, sofern genügend Kapazitäten vorhanden sind, um die Notfallpatienten rechtzeitig zu behandeln.",
    "Wussten Sie, dass sie Handlangern spezifische Grundstücke zuweisen können? Klicken Sie einfach auf den Text 'Alle Grundstücke' im Personalprofil um zwischen ihnen zu wechseln!",
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
    epidemic = "Infizierten Patienten erzeugen",
    toggle_infected = "Infektions-Symbole umschalten",
    create_patient = "Patienten erzeugen",
    end_month = "Ende des Monats",
    end_year = "Ende des Jahres",
    lose_level = "Level verlieren",
    win_level = "Level gewinnen",
    increase_prices = "Preise erhöhen",
    decrease_prices = "Preise senken",
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
    epidemic = "Einen infizierten Patienten, der eine Epidemie auslösen kann, erzeugen.",
    toggle_infected = "Die Infektions-Symbole für die aktive, entdeckte Epidemie umschalten.",
    create_patient = "Einen Patienten am Kartenrand erzeugen.",
    end_month = "Zum Monatsende springen.",
    end_year = "Zum Jahresende springen.",
    lose_level = "Das aktuelle Level verlieren.",
    win_level = "Das aktuelle Level gewinnen.",
    increase_prices = "Alle Preise um 50% erhöhen (Max. 200%)",
    decrease_prices = "Alle Preise um 50% senken (Min. 50%)",
  }
}

introduction_texts = {
  demo =
    "Willkommen im Demo-Krankenhaus!//" ..
    "Leider beinhaltet die Demo-Version nur dieses eine Level. Dafür gibt es hier aber mehr als genug zu tun, um Sie eine Weile zu beschäftigen! " ..
    "Sie werden diversen Krankheiten begegnen, die unterschiedliche Räume zur Behandlung benötigen. Ab und zu können auch Notfälle eintreffen. " ..
    "Und Sie werden mithilfe einer Forschungsabteilung neue Räume erforschen müssen. " ..
    "Ihr Ziel ist es, 100.000 DM zu verdienen, einen Krankenhauswert von 70.000 DM und einen Ruf von 700 vorzuweisen, und gleichzeitig mindestens 75% der Patienten erfolgreich zu behandeln. " ..
    "Stellen Sie sicher, dass Ihr Ruf nicht unter 300 fällt und dass Sie nicht mehr als 40% ihrer Patienten sterben lassen, oder Sie werden verlieren.//" ..
    "Viel Glück!",
}

calls_dispatcher = {
  --
  summary = "%d Aufrufe; %d zugewiesen",
  staff = "%s - %s",
  watering = "Bewässert @ %d,%d",
  repair = "Repariert %s",
  close = "Schließen",
}

tooltip.calls_dispatcher = {
  task = "Liste der Aufgaben - Aufgabe anklicken, um das Fenster des zugewiesenen Personalmitglieds zu öffnen und zum Ort der Aufgabe zu scrollen.",
  assigned = "Diese Box ist markiert, wenn jemand der Aufgabe zugewiesen ist.",
  close = "Das Aufruf-Verteiler-Fenster schließen",
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

map_editor_window = {
  pages = {
    inside = "Innen",
    outside = "Außen",
    foliage = "Grünzeug",
    hedgerow = "Hecke",
    pond = "Teich",
    road = "Straße",
    north_wall = "Nord-Wand",
    west_wall = "West-Wand",
    helipad = "Helipad",
    delete_wall = "Wände löschen",
    parcel_0 = "Grundstück 0",
    parcel_1 = "Grundstück 1",
    parcel_2 = "Grundstück 2",
    parcel_3 = "Grundstück 3",
    parcel_4 = "Grundstück 4",
    parcel_5 = "Grundstück 5",
    parcel_6 = "Grundstück 6",
    parcel_7 = "Grundstück 7",
    parcel_8 = "Grundstück 8",
    parcel_9 = "Grundstück 9",
    camera_1 = "Kamera 1",
    camera_2 = "Kamera 2",
    camera_3 = "Kamera 3",
    camera_4 = "Kamera 4",
    heliport_1 = "Heliport 1",
    heliport_2 = "Heliport 2",
    heliport_3 = "Heliport 3",
    heliport_4 = "Heliport 4",
    paste = "Bereich einfügen",
  }
}

hotkeys_file_err = {
  file_err_01 = "Konnte hotkeys.txt nicht laden. Bitte stellen Sie sicher, " ..
        "dass CorsixTH Lese-/Schreibrechte hat ",
  file_err_02 = ", oder verwenden Sie die --hotkeys-file=filename Kommandozeilenoption um eine schreibbare Datei anzugeben. " ..
        "Für Referenzzwecke, der Fehler beim laden der Tastenlürzel-Datei war: ",
}

transactions.remove_room = "Bauen: Entferne zerstörten Raum"

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
