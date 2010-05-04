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

-- Note: This file contains UTF-8 text. Make sure your editor is set to UTF-8.

Language("german", "de", "ger", "deu")
Inherit("english")
Inherit("original_strings", 2)

-- override

diseases.broken_wind.cure = utf8 " Therapie: Eine spezielle Mixtur aus der Pharma-Theke sorgt für Windstille." -- original string mentioned inflation, which is plain wrong.
diseases.corrugated_ankles.cure = utf8 "Therapie: Eine Schwester verabreicht dem Patienten ein leicht toxisches Gebräu, welches das Bein wieder strafft." -- original string mentioned applying a cast, which is wrong and misleads people to think of fracture clinic
fax.vip_visit_result.remarks.super[1] = utf8 "Was für ein Spitzen-Krankenhaus! Wenn ich das nächste mal ernsthaft krank bin, will ich hier hin!" -- storming should not be translated with 'turbulent' here
fax.epidemic.declare_explanation_fine = utf8 "Wenn Sie die Epidemie melden, zahlen Sie eine Strafe von %d und Ihr Ruf leidet. Dafür werden die Patienten automatisch geimpft." -- extend to mention reputation hit and automatic vaccination
fax.emergency_result.saved_people = "Sie haben %d der %d Notfall-Patienten gerettet." -- swapped %d's
dynamic_info.patient.actions.dying = utf8 "Ins Jenseits befördert!" -- wrong verb case
adviser.research.drug_fully_researched = utf8 "Sie haben die Effektivität Ihres %s-Medikaments auf 100% gesteigert." -- grammatical error in original
tooltip.graphs.reputation = "Ruf ein- und ausschalten" -- original mentioned hospital value, while it's actually reputation.
staff_title.researcher = "Forscher" -- one of the most annoying (since prominent) wrong strings in original
bank_manager.insurance_owed = "Zahlungen von Vers." -- original was too long
insurance_companies[7] = "Leben-und-Tod KG" -- %% in original string (maybe this was rendered as &)
object.skeleton = "Skelett" -- second most annoying mistake in german translation
tooltip.staff_list.detail = "Aufmerksamkeit" -- was translated as an imperative
tooltip.staff_list.surgeon_train = "Wurde zu %d%% zum Chirurgen ausgebildet." -- the three strings made no sense grammatically
tooltip.staff_list.psychiatrist_train = "Wurde zu %d%% zum Psychiater ausgebildet."
tooltip.staff_list.researcher_train = "Wurde zu %d%% zum Forscher ausgebildet."
-- TODO: tooltip.staff_list.next_person, prev_person is rather next/prev page (also in english)

tooltip.queue_window.inc_queue_size = utf8 "Warteschlange vergrößern"
tooltip.queue_window.dec_queue_size = "Warteschlange verkleinern"

-- new strings

object.litter = utf8 "Müll"
tooltip.objects.litter = utf8 "Müll: Wurde von einem Patienten fallengelassen, nachdem er keinen Mülleimer fand."

menu_options.lock_windows = "  FENSTER FESTHALTEN  "
menu_options_game_speed.pause        = "  PAUSE"

menu_debug = {
  transparent_walls    = utf8 "  DURCHSICHTIGE WÄNDE",
  limit_camera              = "  KAMERA BEGRENZEN",
  disable_salary_raise = utf8 "  KEINE GEHALTSERHÖHUNGEN",
  make_debug_patient        = "  DEBUG-PATIENTEN ERSTELLEN",
  spawn_patient             = "  PATIENTEN ERZEUGEN",
  make_adviser_talk         = "  BERATER REDEN LASSEN",
  show_watch                = "  UHR ANZEIGEN",
  create_emergency          = "  NOTFALL ERZEUGEN  ",
  place_objects             = "  OBJEKTE PLATZIEREN",
  dump_strings              = "  TEXTE ABSPEICHERN  ",
  map_overlay               = "  KARTEN-OVERLAY",
  sprite_viewer             = "  SPRITE-BETRACHTER",
}
menu_debug_overlay = {
  none                      = "  KEIN",
  flags                     = "  FLAGS",
  byte_0_1                  = "  BYTE 0 & 1",
  byte_floor                = "  BYTE BODEN",
  byte_n_wall               = "  BYTE N WAND",
  byte_w_wall               = "  BYTE W WAND",
  byte_5                    = "  BYTE 5",
  byte_6                    = "  BYTE 6",
  byte_7                    = "  BYTE 7",
  parcel               = utf8 "  GRUNDSTÜCK"
}

adviser.room_forbidden_non_reachable_parts = utf8 "Sie können den Raum hier nicht bauen, da dann Teile des Krankenhauses nicht mehr erreichbar wären."

dynamic_info.patient.actions.no_gp_available = "Wartet darauf, dass Sie eine Allgemeinmedizin bauen"
dynamic_info.staff.actions.heading_for = "Geht zu: %s"

fax = {
  welcome = {
    beta1 = {
      "Willkommen zu CorsixTH, einem Open-Source-Klon von Bullfrogs Spieleklassiker Theme Hospital!",
      utf8 "Dies ist die spielbare Beta 1 von CorsixTH. Viele Räume, Krankheiten etc. wurden implementiert, aber es fehlen auch noch einige Dinge.",
      utf8 "Wenn dir das Projekt gefällt, kannst du uns unterstützen, z.B. indem du Fehler berichtest oder uns bei der Programmierung hilfst.",
      utf8 "Jetzt wünschen wir aber erstmal viel Spaß mit dem Spiel! Falls du Theme Hospital nicht kennst: Baue eine Rezeption (aus dem Objekte-Menü) und eine Allgemeinmedizin (Diagnoseraum), dann diverse Behandlungsräume.",
      "-- Das CorsixTH-Team, th.corsix.org",
      "PS: Kannst du die Geheimnisse finden, die wir eingebaut haben?",
    },
    beta2 = {
      "Willkommen zur zweiten Beta von CorsixTH, einem Open-Source-Klon von Bullfrogs Spieleklassiker Theme Hospital!",
      utf8 "Viele neue Funktionen wurden seit der vorherigen Version implementiert. Eine unvollständige Auflistung findet sich im Changelog.",
      utf8 "Jetzt wird aber erstmal gespielt! Anscheinend wartet eine Nachricht auf dich. Schließe dieses Fenster und klicke auf das Fragezeichen links unten über der Leiste.",
      "-- Das CorsixTH-Team, th.corsix.org",
    },
  },
  tutorial = {
    "Willkommen in Ihrem ersten Krankenhaus!",
    utf8 "Möchten Sie eine kurze Einführung?",
    utf8 "Ja, bitte führen Sie mich herum.",
    utf8 "Nö, ich weiß schon wie hier alles abläuft.",
  },
}

misc.not_yet_implemented = "(noch nicht implementiert)"
misc.no_heliport = "Entweder wurden noch keine Krankheiten entdeckt, oder es existiert kein Heliport auf dieser Karte."

main_menu = {
  new_game = "Neues Spiel",
  custom_level = "Eigenes Level",
  load_game = "Spiel Laden",
  options = "Optionen",
  exit = "Verlassen",
}

tooltip.main_menu = {
  new_game = "Ein komplett neues Spiel anfangen",
  custom_level = "Ein Krankenhaus in einem eigenen Level errichten",
  load_game = "Ein zuvor gespeichertes Spiel fortsetzen",
  options = utf8 "Diverse Einstellungen verändern",
  exit = "Bitte geh nicht fort!",
}

load_game_window = {
  back = utf8 "Zurück",
}

tooltip.load_game_window = {
  load_game_number = "Spiel %d laden",
  load_autosave = "Automatisch gespeichertes Spiel laden",
  back = utf8 "Das Ladefenster schließen",
}

errors = {
  dialog_missing_graphics = "Entschuldigung, aber dieses Fenster ist in den Demo-Dateien nicht enthalten.",
  save_prefix = "Fehler beim Speichern: ",
  load_prefix = "Fehler beim Laden: ",
}

totd_window = {
  tips = {
    utf8 "Zu Beginn benötigt jedes Krankenhaus eine Rezeption und eine Allgemeinmedizin. Danach kommt es darauf an, was für Patienten im Krankenhaus auftauchen. Eine Pharma-Theke ist aber immer eine gute Wahl.",
    utf8 "Maschinen wie die Entlüftung müssen gewartet werden. Stelle ein paar Handlanger ein, oder die Patienten und das Personal könnte verletzt werden.",
    utf8 "Nach einer Weile wird das Personal müde. Baue unbedingt einen Personalraum, damit es sich ausruhen kann.",
    utf8 "Platziere genug Heizkörper, um das Personal und die Patienten warm zu halten, sonst werden sie unglücklich.",
    utf8 "Der Fähigkeits-Level eines Arztes beeinflusst die Qualität und Geschwindigkeit seiner Diagnosen deutlich. Ein geübter Arzt in der Allgemeinmedizin erspart so manchen zusätzlichen Diagnoseraum.",
    utf8 "AIPler und Ärzte können ihre Fähigkeiten verbessern, indem sie in der Ausbildung von Beratern lernen. Wenn der Berater eine zusätzliche Qualifikation (Chirurg, Psychiater oder Forscher) besitzt, gibt er dieses Wissen ebenfalls weiter.",
    utf8 "Hast du schon versucht, die Europäische Notruf-Nummer (112) in das Faxgerät einzugeben? Mach vorher den Sound an!!",
    utf8 "Das Options-Menü ist noch nicht verfügbar, aber es können einige Einstellungen wie die Auflösung oder die Sprache verändert werden, indem man die config.txt im Spielverzeichnis editiert.",
    utf8 "Du hast eine andere Sprache als Englisch ausgewählt, aber es erscheinen Englische Texte? Hilf uns die Übersetzung zu vervollständigen, indem du fehlende Texte in deine Sprache Übersetzt!",
    utf8 "Das CorsixTH-Team sucht Verstärkung! Hast du Interesse, beim Programmieren, Übersetzen oder Grafiken erstellen zu helfen? Kontaktiere uns in unserem Forum, der Mailing List oder unserem IRC-Channel (corsix-th im freenode).",
    utf8 "Wenn du einen Bug findest, bitte melde ihn in unserem Bug-Tracker: th-issues.corsix.org",
    utf8 "CorsixTH wurde am 24.Juli 2009 erstmals öffentlich vorgestellt. Der erste Release war die spielbare Beta 1 am 24.Dezember 2009. Nach drei weiteren Monaten sind wir nun stolz, Beta 2 präsentieren zu dürfen (am 24.März 2010 veröffentlicht).",
  },
  previous = "Vorheriger Tipp",
  next = utf8 "Nächster Tipp",
}

tooltip.totd_window = {
  previous = "Den vorherigen Tipp anzeigen",
  next = utf8 "Den nächsten Tipp anzeigen",
}
