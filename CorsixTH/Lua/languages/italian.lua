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
Encoding(utf8)

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

tooltip.fax.close = "Chiudi questa finestra senza cancellare il messaggio"
tooltip.message.button = "Click sinistro per aprire il messaggio"
tooltip.message.button_dismiss = "Click sinistro per aprire il messaggio, click destro per eliminarlo"
tooltip.casebook.cure_requirement.hire_staff = "Hai bisogno di assumere personale per somministrare questa cura"
tooltip.casebook.cure_type.unknown = "Ancora non sei a conoscenza di un modo per curare questa malattia"
tooltip.research_policy.no_research = utf8 "Non c'è nessuna ricerca in corso in questa categoria al momento"
tooltip.research_policy.research_progress = "Progresso verso una nuova scoperta in questa categoria: %1%/%2%"

menu_options = {
  lock_windows = "  BLOCCA FINESTRE  ",
  edge_scrolling = "  SCORRIMENTO AI LATI  ",
  settings = "  IMPOSTAZIONI  ",
}
menu_options_game_speed.pause = "  PAUSA  "

-- The demo does not contain this string
menu_file.restart = "  RIAVVIA  "

menu_debug = {
  jump_to_level               = "  SALTA AL LIVELLO  ",
  transparent_walls           = "  (X) MURA TRASPARENTI  ",
  limit_camera                = "  LIMITA TELECAMERA  ",
  disable_salary_raise        = "  DISABILITA AUMENTI DI SALARIO  ",
  make_debug_fax              = "  (F8) CREA FAX DI DEBUG  ",
  make_debug_patient          = "  (F9) CREA UN PAZIENTE DI DEBUG  ",
  cheats                      = "  (F11) CHEAT  ",
  lua_console                 = "  (F12) CONSOLE LUA  ",
  calls_dispatcher            = "  GESTORE CHIAMATE  ",
  dump_strings                = "  FAI IL DUMP DELLE STRINGHE  ",
  dump_gamelog                = "  (CTRL+D) FAI IL DUMP DEL GAMELOG  ",
  map_overlay                 = "  MAPPA IN SOVRAPPOSIZIONE  ",
  sprite_viewer               = "  VISUALIZZATORE SPRITE  ",
}
menu_debug_overlay = {
  none                        = "  NESSUN OVERLAY  ",
  flags                       = "  FLAGS  ",
  positions                   = "  POSIZIONI  ",
  heat                        = "  TEMPERATURA  ",
  byte_0_1                    = "  BYTE 0 & 1  ",
  byte_floor                  = "  BYTE PAVIMENTO  ",
  byte_n_wall                 = "  BYTE N MURO  ",
  byte_w_wall                 = "  BYTE W MURO  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  PARCEL  ",
}
adviser = {
  room_forbidden_non_reachable_parts = "Mettere la stanza in questa posizione risulterebbe nel blocco dell'accesso ad alcune parti dell'ospedale.",
  warnings = {
    no_desk ="Prima o poi dovrai costruire un banco di accettazione ed assumere una receptionist!",
    no_desk_1 = "Se vuoi che i pazienti vengano nel tuo ospedale dovrai assumere una receptionist e costruirle una scrivania dove farla lavorare!",
    no_desk_2 = "Ben fatto, deve essere un record mondiale: quasi un anno e nessun paziente! Se vuoi continuare come Manager di questo ospedale avrai bisogno di assumere una receptionist e costruire un banco di accettazione dove farla lavorare!",
  },

  cheats = {  
    th_cheat = "Congratulazioni, hai sbloccato i cheat!",
    crazy_on_cheat = "Oh no! Tutti i dottori sono impazziti!",
    crazy_off_cheat = "Phew... i dottori sono di nuovo sani.",
    roujin_on_cheat = "Sfida di Roujin attivata! Buona fortuna...",
    roujin_off_cheat = "Sfida di Roujin disattivata.",
    hairyitis_cheat = "Cheat Cespuglite attivato!",
    hairyitis_off_cheat = "Cheat Cespuglite disattivato.",
    bloaty_cheat = "Cheat Testa Gonfia attivato!!",
    bloaty_off_cheat = "Cheat Testa Gonfia disattivato.",
  },
}

dynamic_info.patient.actions.no_gp_available = "Aspettando che venga costruito un ambulatorio"
dynamic_info.staff.actions.heading_for = "Andando verso %s"
dynamic_info.staff.actions.fired = "Licenziato"

fax = {
   choices = {
    return_to_main_menu = "Ritorna al menu principale",
    accept_new_level = "Vai al livello successivo",
    decline_new_level = utf8 "Continua a giocare un altro po'",
  },
  emergency = {
    num_disease_singular = utf8 "C'è una persona con %s che richiede la tua immediata attenzione.",
  }
}

letter = {
  dear_player = "Caro %s",
  custom_level_completed = "Ben fatto! Hai completato tutti gli obiettivi di questo livello personalizzato!",
  return_to_main_menu = "Vuoi tornare al menu principale o vuoi continuare a giocare?",
}

install = {
  title = "--------------------------------- Installazione CorsixTH ---------------------------------",
  th_directory = "CorsixTH ha bisogno di una copia dei file dati di Theme Hospital (o della demo) per essere eseguito. Per favore indica la posizione della cartella di installazione di Theme Hospital.",
  exit = "Esci",
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
  custom_level = "Costruisci il tuo ospedale in un livello personalizzato",
  load_game = "Carica una partita salvata in precedenza",
  options = "Modifica le impostazioni",
  exit = "No, per favore non andartene!",
}

load_game_window = {
  caption = "Carica Partita",
}

tooltip.load_game_window = {
  load_game = "Carica la partita %s",
  load_game_number = "Carica la partita %d",
  load_autosave = "Carica l'ultimo autosalvataggio",
}

custom_game_window = {
  caption = "Partita personalizzata",
}

tooltip.custom_game_window = {
  start_game_with_name = "Carica il livello %s",
}

save_game_window = {
  caption = "Salva Partita",
  new_save_game = "Nuovo Salvataggio",
}

tooltip.save_game_window = {
  save_game = "Sovrascrivere salvataggio %s",
  new_save_game = "Inserisci il nome per un nuovo salvataggio",
}

menu_list_window = {
  back = "Indietro",
}

tooltip.menu_list_window = {
  back = "Chiudi questa finestra",
}
-- Width / height's translation doesn't fit - had to write "larghezza" and "altezza" shorter
options_window = {
  fullscreen = "Schermo intero",
  width = "Largh",
  height = "Alt",
  change_resolution = "Cambia risoluzione",
  browse = "Sfoglia...",
  new_th_directory = utf8 "Qui puoi specificare una nuova cartella di installazione di Theme Hospital. Appena scegli la nuova cartella il gioco verrà riavviato.",
  cancel = "Cancella",
  back = "Indietro",
}

tooltip.options_window = {
  fullscreen_button = utf8 "Clicca per selezionare o deselezionare la modalità a schermo intero",
  width = "Inserisci la larghezza dello schermo desiderata",
  height = utf8 "Inserisci l'altezza dello schermo desiderata",
  change_resolution = "Cambia la risoluzione della finestra alle dimensioni inserite a sinistra",
  language = "Seleziona %s come lingua",
  original_path = utf8 "La cartella dell'installazione di Theme Hospital originale attualmente selezionata",
  browse = utf8 "Seleziona la cartella di un'altra installazione di Theme Hospital",
  back = "Chiudi la finestra delle opzioni",
}

new_game_window = {
  easy = "Assistente (Facile)",
  medium = "Dottore (Medio)",
  hard = "Consulente (Difficile)",
  tutorial = "Tutorial",
  cancel = "Cancella",
}

tooltip.new_game_window = {
  easy = utf8 "Se non sei pratico di simulatori questa è l'opzione per te",
  medium = utf8 "Questa è la via di mezzo se non sei sicuro su cosa scegliere",
  hard = utf8 "Se sei abituato a questo tipo di giochi e vuoi una sfida più impegnativa, scegli questa opzione",
  tutorial = "Se vuoi aiuto per cominciare mentre sei in gioco, spunta questa casella",
  cancel = "Oh, non volevo davvero cominciare una nuova partita!",
}

lua_console = {
  execute_code = "Esegui",
  close = "Chiudi",
}

tooltip.lua_console = {
  textbox = "Inserisci il codice Lua da eseguire qui",
  execute_code = "Esegui il codice che hai inserito",
  close = "Chiudi la console",
}

errors = {
  dialog_missing_graphics = "I file dei dati della demo non contengono questa stringa.",
  save_prefix = "Errore durante il salvataggio: ",
  load_prefix = "Errore durante il caricamento: ",
  map_file_missing = "Non ho potuto trovare la mappa %s per questo livello!",
  minimum_screen_size = "Per favore inserisci almeno una risoluzione di 640x480.",
  maximum_screen_size = "Per favore inserisci al massimo una risoluzione di 3000x2000.",
  unavailable_screen_size = "La risoluzione che hai richiesto non è disponibile a schermo intero.",
}

confirmation = {
  needs_restart = utf8 "Cambiare questa impostazione richiede che CorsixTH sia riavviato. Ogni progresso non salvato sarà perduto. Sei sicuro di volerlo fare?",
  abort_edit_room = utf8 "Stai attualmente costruendo o modificando una stanza. Se tutti gli oggetti richiesti sono stati posizionati sarà completata, altrimenti sarà cancellata. Continuare?",
  restart_level = "Sei sicuro di voler riavviare il livello?"
}

information = {
  custom_game = "Benvenuto in CorsixTH. Divertiti con questa mappa personalizzata!",
  cannot_restart = utf8 "Sfortunatamente questa mappa personalizzata è stata salvata prima che venisse implementata la funzione per riavviare.",
  level_lost = {
    utf8 "Peccato! Hai perso il livello. Avrai più fortuna la prossima volta!",
    utf8 "Hai perso perchè:",
    reputation = utf8 "La tua reputazione è scesa sotto %d.",
    balance = utf8 "Il tuo conto in banca è sceso sotto %d.",
    percentage_killed = utf8 "Hai ucciso più del %d dei pazienti.",
  },
}

tooltip.information = {
  close = "Chiudi la finestra delle informazioni",
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
    "Ogni livello ha degli obiettivi da raggiungere prima di poter passare al successivo. Controlla la finestra del riepilogo per vedere a che punto sei.",
    "Se vuoi modificare o rimuovere una stanza esistente, puoi farlo con il tasto modifica stanza nella barra degli strumenti in basso.",
    utf8 "In un'orda di pazienti in attesa, puoi vedere velocemente chi sta aspettando il proprio turno per una stanza particolare spostando il mouse sulla stanza.",
    utf8 "Clicca sulla porta di una stanza per vederne la coda. Puoi fare diverse cose utili, come riordinare la coda o mandare il paziente in un'altra stanza.",
    utf8 "Se il personale è infelice chiederà spesso aumenti di salario. Assicurati che il tuo staff stia lavorando in un'ambiente di lavoro confortevole per evitare che accada.",
    utf8 "I pazienti avranno sete durante le attese, soprattutto se alzi il riscaldamento! Piazza i distributori di bevande in posizioni strategiche per un po' di guadagni extra. ",
    utf8 "Puoi cancellare prematuramente il processo di diagnosi per un paziente e deciderne la cura se hai già incontrato la malattia. Fai attenzione però, dato che fare ciò può incrementare il rischio di una cura sbagliata, risultando nella morte del paziente.",
    utf8 "Le emergenze possono essere una buona fonte di guadagno extra, sempre che tu abbia i mezzi sufficienti a gestire l'emergenza in tempo.",
  },
  previous = "Suggerimento Precedente",
  next = "Suggerimento Successivo",
}

tooltip.totd_window = {
  previous = "Passa al suggerimento precedente",
  next = "Passa al suggerimento successivo",
}

debug_patient_window = {
  caption = "Debug Paziente",
}

cheats_window = {
  caption = "Cheat",
  warning = "Attenzione: Non riceverai alcun punto bonus alla fine del livello se usi i cheat!",
  cheated = {
    no = "Cheat usati: No",
    yes = "Cheats usati: Yes",
  },
  cheats = {
    money = "Cheat soldi",
    all_research = "Cheat Completa Ricerche",
    emergency = "Crea Emergenza",
    vip = "Crea VIP",
    create_patient = "Crea Paziente",
    end_month = "Fine Mese",
    end_year = "Fine Anno",
    lose_level = "Perdi Livello",
    win_level = "Vinci Livello",
  },
  close = "Chiudi",
}

tooltip.cheats_window = {
  close = "Chiudi il menu dei cheat",
  cheats = {
    money = "Aggiunge 10.000 al tuo conto in banca.",
    all_research = "Completa tutte le ricerche.",
    emergency = utf8 "Crea un'emergenza.",
    vip = "Crea un VIP.",
    create_patient = "Crea un Paziente a bordo mappa.",
    end_month = "Salta alla fine del mese.",
    end_year = "Salta alla fine dell'anno.",
    lose_level = "Perdi il livello corrente.",
    win_level = "Vinci il livello corrente.",
  }
}

introduction_texts = {
  demo = {
    utf8 "Benvenuto nell'ospedale demo!",
    utf8 "Sfortunatamente la versione demo contiene solo questo livello (oltre ai livelli personalizzati). Ad ogni modo c'è abbastanza da fare per tenerti occupato per un bel po'!",
    "Incontrerai diverse malattie che richiederanno diverse cliniche per essere curate. Ogni tanto potrebbero presentarsi delle emergenze. E avrai bisogno di ricercare nuove strumentazioni tramite il centro ricerche.",
    "Il tuo obiettivo è di guadagnare $100,000, avere un ospedale che valga $70,000 e una reputazione di 700, oltre che curare almeno il 75% dei tuoi pazienti.",
    "Assicurati che la tua reputazione non scenda al di sotto di 300 e di non uccidere più del 40% dei tuoi pazienti, o perderai.",
    "Buona fortuna!",
  },
}

calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = "%d chiamate; %d assegnate",
  staff = "%s - %s",
  watering = "Annaffiare @ %d,%d",
  repair = "Riparazione %s",
  close = "Chiudi",
}

tooltip.calls_dispatcher = {
  task = "Lista dei compiti - clicca il compito per aprire la finestra del membro del personale assegnato e scorrere alla posizione del compito",
  assigned = "Questo box è segnato se qualcuno è assegnato al compito corrispondente.",
  close = "Chiude la finestra del gestore chiamate",
}

