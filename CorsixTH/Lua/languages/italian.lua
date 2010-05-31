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

Language("Italiano", "Italian", "it", "ita")
Inherit("english")
Inherit("original_strings", 3)

-- override
-- TODO? Any more original strings that are off in italian translation?
adviser.warnings.money_low = "Stai finendo i soldi!"
-- TODO: tooltip.graphs.reputation -- this tooltip talks about hospital value. Actually it should say reputation.
-- TODO: tooltip.status.close -- it's called status window, not overview window.

-- The originals of these two contain one space too much
fax.emergency.cure_not_possible_build = "E' necessario costruire un %s"
fax.emergency.cure_not_possible_build_and_employ = "E' necessario costruire un %s e assunere un %s"

-- new strings
object.litter = "Spazzatura"
tooltip.objects.litter = utf8 "Spazzatura: Lasciata da un paziente perché non ha trovato un cestino dove gettarla."

menu_options.lock_windows = "  BLOCCA FINESTRE  "
menu_options_game_speed.pause = "  PAUSA  "

menu_debug = {
  transparent_walls           = "  MURA TRASPARENTI  ",
  limit_camera                = "  LIMITA TELECAMERA  ",
  disable_salary_raise        = "  DISABILITA AUMENTI DI SALARIO  ",
  make_debug_patient          = "  CREA UN PAZIENTE DI DEBUG  ",
  spawn_patient               = "  GENERA PAZIENTE  ",
  make_adviser_talk           = "  FA' PARLARE IL CONSIGLIERE  ",
  show_watch                  = "  MOSTRA OROLOGIO  ",
  create_emergency            = "  CREA EMERGENZA  ",
  place_objects               = "  PIAZZA OGGETTI  ",
  dump_strings                = "  CREA UN DUMP DELLE STRINGHE  ",
  map_overlay                 = "  MAPPA IN SOVRAPPOSIZIONE  ",
  sprite_viewer               = "  VISUALIZZATORE DI SPRITE  ",
}
menu_debug_overlay = {
  none                        = "  NESSUN OVERLAY  ",
  flags                       = "  FLAGS  ",
  positions                   = "  POSIZIONI  ",
  byte_0_1                    = "  BYTE 0 & 1  ",
  byte_floor                  = "  BYTE PAVIMENTO  ",
  byte_n_wall                 = "  BYTE N MURO  ",
  byte_w_wall                 = "  BYTE W MURO  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  PARCEL  ",
}
adviser.room_forbidden_non_reachable_parts = "Mettere la stanza in questa posizione risulterebbe nel blocco dell'accesso ad alcune parti dell'ospedale."

dynamic_info.patient.actions.no_gp_available = "Aspettando che venga costruito un ambulatorio"
dynamic_info.staff.actions.heading_for = "Andando verso %s"

fax = {
  welcome = {
    beta1 = {
      utf8 "Benvenuto in CorsixTH! Questo è un clone open source di Theme Hospital, un classico videogioco della Bullfrog.",
      utf8 "Questa è la prima beta giocabile di CorsixTH. Molte stanze, malattie e altre cose sono state implementate, ma molto è ancora in lavorazione.",
      "Se ti piace o se sei interessato al progetto, puoi aiutarci con lo sviluppo, ad esempio riportando dei bug che noti o addirittura programmando qualcosa tu stesso.",
      utf8 "Per il momento, però, divertiti con il gioco! Per chi non è familiare con il gioco, iniziate costruendo un banco della reception (dal menu degli oggetti) e un ambulatorio (dal menu stanze). Saranno necessarie anche stanze per la diagnosi e per il trattamento delle malattie.",
      "-- Il team di CorsixTH, th.corsix.org",
      "PS: Abbiamo anche aggiunto varie piccole 'sorprese', riuscirai a trovarle?",
    },
    beta2 = {
      utf8 "Benvenuto alla seconda beta di CorsixTH! Questo è un clone open source di Theme Hospital, un classico videogioco della Bullfrog.",
      utf8 "Molto è stato implementato rispetto alla scorsa versione (beta 1). Per una lista incompleta dei cambiamenti, consulta il changelog.",
      "Ma per prima cosa, giochiamo! Sembra che ci sia un messaggio che ti aspetta. Chiudi questa finestra e clicca sull'icona che contiene il punto di domanda appena sopra il pannello in fondo.",
      "-- Il team di CorsixTH, th.corsix.org",
    },
  },
  tutorial = {
    "Benvenuto nel tuo primo ospedale!",
    "Hai bisogno di un veloce tutorial?",
    "Si grazie, mostrami le basi del gioco.",
    "No grazie, conosco già il gioco.",
  },
}

misc.not_yet_implemented = "(non ancora implementato)"
misc.no_heliport = "Non è stata scoperta nessuna malattia, oppure non c'è eliporto sulla mappa."

main_menu = {
  new_game = "Nuova partita",
  custom_level = "Livello personalizzato",
  load_game = "Carica partita",
  options = "Opzioni",
  exit = "Esci",
}

tooltip.main_menu = {
  new_game = "Inizia una nuova partita",
  custom_level = "Costruisci il tuo ospedale in un livello personalizzabile",
  load_game = "Carica una partita salvata in precedenza",
  options = "Modifica le impostazioni",
  exit = "No, non andartene!",
}

load_game_window = {
  back = "Indietro",
}

tooltip.load_game_window = {
  load_game_number = "Carica la partita %d",
  load_autosave = "Carica l'ultimo autosalvataggio",
  back = "Chiudi la finestra 'Carica partita'",
}

errors = {
  dialog_missing_graphics = "I file dei dati della demo non contengono questa stringa.",
  save_prefix = "Errore durante il salvataggio: ",
  load_prefix = "Errore durante il caricamento: ",
}

totd_window = {
  tips = {
    utf8 "Ogni ospedale per funzionare ha bisogno di alcune strutture di base. Inizia con una reception e un ambulatorio, e il personale necessario. Una volta iniziato, dipenderà tutto dal tipo di pazienti che visiteranno il tuo ospedale. Qualche stanza per le diagnosi e una farmacia sono una buona scelta per iniziare.",
    utf8 "I macchinari come la Pompa hanno bisogno di manutenzione più o meno costante. Assumi qualche tuttofare per ripararle, o rischierai che i pazienti e il tuo staff si facciano male.",
    "Il tuo staff lavora duramente, e ogni tanto ha bisogno di riposare. Costruisci una sala del personale per loro.",
    "Ricordati di fornire il tuo ospedale di un impianto di riscaldamento funzionante, o lo staff ed i pazienti rimarranno infelici e infreddoliti.",
    utf8 "Il livello di competenza influenza in maniera enorme la qualità e la velocità delle diagnosi. Assegnando un dottore molto abile al tuo ambulatorio non avrai bisogno di costruire molte strutture di diagnosi addizionali.",
    utf8 "Assistenti e dottori possono aumentare il loro livello di competenza imparando da un consulente nella sala tirocinio. Se il consulente è anche uno specialista (chirurgo, psichiatra e/o ricercatore), passerà le sue conoscente ai suoi studenti.",
    "Hai provato a digitare il numero di emergenza europea (112) nel fax? Assicurati di avere l'audio attivato!",
    "Il menu d'opzioni non è ancora implementato, ma puoi regolare le impostazioni modificando il file config.txt nella directory di gioco.",
    utf8 "Hai selezionato il tuo linguaggio, ma tutto è in inglese? Aiutaci a convertire il gioco in più linguaggi!",
    "Il team di CorsixTH sta cercando rinforzi! Sei interessato in programmare, tradurre o creare nuovi elementi grafici per CorsixTH? Contattaci nei forum, tramite mail o sul canale IRC (corsix-th su freenode).",
    "Trovato un bug? Vuoi segnalare un errore di qualsiasi genere? Inviaci un rapporto su ciò che hai trovato al nostro bug tracker: th-issues.corsix.org",
    "CorsixTH è stato reso pubblico il 24 luglio 2009. La prima release è stata la beta 1 giocabile, il 24 dicembre 2009. Dopo tre mesi, il 24 marzo 2010, siamo fieri di presentare la versione beta 2.",
  },
  previous = "Suggerimento Precedente",
  next = "Suggerimento Successivo",
}

tooltip.totd_window = {
  previous = "Passa al suggerimento precedente",
  next = "Passa al suggerimento successivo",
}
