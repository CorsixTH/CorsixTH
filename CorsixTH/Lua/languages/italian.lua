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

-------------------------------  NEW STRINGS  -------------------------------
date_format = {
  daymonth = "%1% %2:months%",
}

object.litter = "Spazzatura"
tooltip.objects.litter = "Spazzatura: Lasciata sul pavimento da un paziente perché non ha trovato un cestino in cui gettarla."

tooltip.fax.close = "Chiudi questa finestra senza cancellare il messaggio"
tooltip.message.button = "Click sinistro per aprire il messaggio"
tooltip.message.button_dismiss = "Click sinistro per aprire il messaggio, click destro per eliminarlo"
tooltip.casebook.cure_requirement.hire_staff = "Hai bisogno di assumere personale per somministrare questa cura"
tooltip.casebook.cure_type.unknown = "Ancora non sei a conoscenza di un modo per curare questa malattia"
tooltip.research_policy.no_research = "Non c'è nessuna ricerca in corso in questa categoria al momento"
tooltip.research_policy.research_progress = "Progresso verso una nuova scoperta in questa categoria: %1%/%2%"

menu_options = {
  lock_windows = "  BLOCCA FINESTRE  ",
  edge_scrolling = "  SCORRIMENTO AI LATI  ",
  settings = "  IMPOSTAZIONI  ",
  adviser_disabled = "  CONSIGLIERE  ",
  warmth_colors = "  COLORI RISCALDAMENTO  ",
}

menu_options_game_speed = {
  pause               = "  (P) PAUSA  ",
  slowest             = "  (1) LENTISSIMO  ",
  slower              = "  (2) LENTO  ",
  normal              = "  (3) NORMALE  ",
  max_speed           = "  (4) VELOCITA' MASSIMA  ",
  and_then_some_more  = "  (5) E ANCORA DI PIU'  ",
}

menu_options_warmth_colors = {
  choice_1 = "  ROSSO  ",
  choice_2 = "  BLU VERDE ROSSO  ",
  choice_3 = "  GIALLO ARANCIONE ROSSO  ",
}

-- Add F-keys to entries in charts menu (except briefing), also town_map was added.
menu_charts = {
  bank_manager  = "  (F1) BANCA  ",
  statement     = "  (F2) RENDICONTO  ",
  staff_listing = "  (F3) PERSONALE  ",
  town_map      = "  (F4) MAPPA CITTADINA  ",
  casebook      = "  (F5) REGISTRO CURE  ",
  research      = "  (F6) RICERCA  ",
  status        = "  (F7) RIEPILOGO  ",
  graphs        = "  (F8) GRAFICI  ",
  policy        = "  (F9) GESTIONE  ",
}


-- The demo does not contain this string
menu_file.restart = "  RIAVVIA  "

menu_debug = {
  jump_to_level               = "  SALTA AL LIVELLO  ",
  transparent_walls           = "  (X) MURA TRASPARENTI  ",
  limit_camera                = "  LIMITA TELECAMERA  ",
  disable_salary_raise        = "  DISABILITA AUMENTI DI SALARIO  ",
  make_debug_fax              = "  CREA FAX DI DEBUG  ",
  make_debug_patient          = "  CREA UN PAZIENTE DI DEBUG  ",
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
  parcel                      = "  LOTTO  ",
}
adviser = {
  room_forbidden_non_reachable_parts = "Mettere la stanza in questa posizione risulterebbe nel blocco dell'accesso ad alcune parti dell'ospedale.",
  warnings = {
    no_desk = "Prima o poi dovrai costruire un banco di accettazione ed assumere una receptionist!",
    no_desk_1 = "Se vuoi che i pazienti vengano nel tuo ospedale dovrai assumere una receptionist e costruirle una scrivania dove farla lavorare!",
    no_desk_2 = "Ben fatto, deve essere un record mondiale: quasi un anno e nessun paziente! Se vuoi continuare come Manager di questo ospedale dovrai assumere una receptionist e costruire un banco di accettazione dove farla lavorare!",
    no_desk_3 = "Grandioso, quasi un anno e ancora non hai personale all'accettazione! Come ti aspetti di trovare pazienti, ora vedi di rimediare e di non fare più casini!",
    cannot_afford = "Non hai abbastanza soldi in banca per assumere questa persona!", -- I can't see anything like this in the original strings
    falling_1 = "Ehi! Non è divertente, attento a dove clicchi: qualcuno potrebbe farsi male!",
    falling_2 = "Basta fare casini, a te piacerebbe?",
    falling_3 = "Ahi, deve far male, qualcuno chiami un dottore!",
    falling_4 = "Questo è un ospedale, non un parco giochi!",
    falling_5 = "Non è il luogo adatto per far cadere le persone, sono malate sai!",
    falling_6 = "Non è una sala da bowling, i malati non dovrebbero essere trattati così!",
    research_screen_open_1 = "Devi costruire un Reparto Ricerca prima di poter accedere alla schermata Ricerca.",
    research_screen_open_2 = "La Ricerca è disabilitata in questo livello.",
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

progress_report.free_build = "COSTRUZIONE LIBERA"

fax = {
   choices = {
    return_to_main_menu = "Ritorna al menu principale",
    accept_new_level = "Vai al livello successivo",
    decline_new_level = "Continua a giocare un altro po'",
  },
  emergency = {
    num_disease_singular = "C'è una persona con %s che richiede la tua immediata attenzione.",
    free_build = "Se hai successo la tua reputazione aumenterà, ma se fallisci la tua reputazione verrà intaccata pesantemente.",
  },
  vip_visit_result = {
    remarks = {
      free_build = {
        "Hai proprio un bell'ospedale! Anche se non è difficile ottenerlo con fondi illimitati, eh?",
        "Non sono un economista, ma penso che anch'io avrei potuto dirigere quest'ospedale, non so se mi spiego...",
        "Un ospedale molto ben gestito. Attento alla crisi economica però! Ah, giusto... non te ne sei dovuto preoccupare.",
      }
    }
  }
}

letter = {
  dear_player = "Caro %s",
  custom_level_completed = "Ben fatto! Hai completato tutti gli obiettivi di questo livello personalizzato!",
  return_to_main_menu = "Vuoi tornare al menu principale o vuoi continuare a giocare?",
}

install = {
  title = "----------------------------- Installazione CorsixTH -----------------------------",
  th_directory = "CorsixTH ha bisogno di una copia dei file dati di Theme Hospital (o della demo) per essere eseguito. Per favore indica la posizione della cartella di installazione di Theme Hospital.",
  exit = "Esci",
}

misc.not_yet_implemented = "(non ancora implementato)"
misc.no_heliport = "O non è stata ancora scoperta nessuna malattia, oppure non c'è un eliporto sulla mappa. Oppure potrebbe essere necessario costruire un banco accettazione e assumere una receptionist"

main_menu = {
  new_game = "Nuova partita",
  custom_level = "Livello personalizzato",
  load_game = "Carica partita",
  options = "Opzioni",
  savegame_version = "Versione salvataggi: ",
  version = "Versione: ",
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
  caption = "Carica Partita (%1%)",
}

tooltip.load_game_window = {
  load_game = "Carica la partita %s",
  load_game_number = "Carica la partita %d",
  load_autosave = "Carica autosalvataggio",
}

custom_game_window = {
  caption = "Partita personalizzata",
  free_build = "Costruzione Libera",
}

tooltip.custom_game_window = {
  start_game_with_name = "Carica il livello %s",
  free_build = "Spunta questa casella per giocare senza soldi, né vittoria o sconfitta",
}

save_game_window = {
  caption = "Salva Partita (%1%)",
  new_save_game = "Nuovo Salvataggio",
}

tooltip.save_game_window = {
  save_game = "Sovrascrivere salvataggio %s",
  new_save_game = "Inserisci il nome per un nuovo salvataggio",
}

menu_list_window = {
  name = "Nome",
  save_date = "Modificata",
  back = "Indietro",
}

tooltip.menu_list_window = {
  name = "Clicca qui per ordinare la lista in ordine alfabetico",
  save_date = "Clicca qui per ordinare la lista in base alla data dell'ultima modifica",
  back = "Chiudi questa finestra",
}

-- Width / height's translation doesn't fit - had to write "larghezza" and "altezza" shorter
options_window = {
  caption = "Opzioni",
  option_on = "On",
  option_off = "Off",
  fullscreen = "Schermo intero",
  resolution = "Risoluzione",
  custom_resolution = "Personalizzata...",
  width = "Largh",
  height = "Alt",
  apply = "Applica",
  data_location = "Posizione dati",
  font_location = "Posizione font",
  browse = "Sfoglia...",
  new_th_directory = "Qui puoi specificare una nuova cartella di installazione di Theme Hospital. Appena scegli la nuova cartella il gioco verrà riavviato.",
  language = "Lingua del gioco",
  cancel = "Cancella",
  back = "Indietro",
}

tooltip.options_window = {
  fullscreen = "Decide se il gioco verrà eseguito a tutto schermo o in finestra",
  fullscreen_button = "Clicca per selezionare o deselezionare la modalità a schermo intero",
  resolution = "La risoluzione a cui il gioco dovrebbe essere eseguito",
  select_resolution = "Seleziona una nuova risoluzione",
  width = "Inserisci la larghezza dello schermo desiderata",
  height = "Inserisci l'altezza dello schermo desiderata",
  apply = "Applica la risoluzione inserita",
  cancel = "Esci senza cambiare la risoluzione",
  data_location = "La cartella dove è installato il Theme Hospital originale, che è richiesto per eseguire CorsixTH",
  font_location = "La posizione di un font che è in grado di mostrare caratteri Unicode richiesti dalla tua lingua. Se non specificata, non potrai scegliere lingue che hanno bisogno di più caratteri rispetto a quelli di cui dispone il gioco originale. Esempio: Russo e Cinese",
  language = "La lingua in cui verrà mostrato il testo",
  select_language = "Seleziona la lingua del gioco",
  language_dropdown_item = "Seleziona %s come lingua",
  original_path = "La cartella dell'installazione di Theme Hospital originale attualmente selezionata",
  browse = "Seleziona un'altra cartella di installazione di Theme Hospital (posizione corrente: %1%)",
  browse_font = "Seleziona un altro file font (posizione corrente: %1%)",
  no_font_specified = "Non hai ancora specificato alcuna posizione!",
  back = "Chiudi la finestra delle opzioni",
}

font_location_window = {
  caption = "Scegli il font (%1%)",
}

handyman_window = {
  all_parcels = "Tutti i lotti",
  parcel = "Lotto"
}

tooltip.handyman_window = {
  parcel_select = "Il lotto dove l'inserviente può operare. Clicca per cambiarlo."
}

new_game_window = {
  caption = "Campagna",
  player_name = "Nome del giocatore",
  option_on = "On",
  option_off = "Off",
  difficulty = "Difficoltà",
  easy = "Assistente (Facile)",
  medium = "Dottore (Medio)",
  hard = "Consulente (Difficile)",
  tutorial = "Tutorial",
  start = "Comincia",
  cancel = "Cancella",
}

tooltip.new_game_window = {
  player_name = "Inserisci il nome col quale vuoi essere chiamato nel gioco",
  difficulty = "Seleziona il livello di difficoltà a cui vuoi giocare",
  easy = "Se non sei pratico di simulatori questa è l'opzione per te",
  medium = "Questa è la via di mezzo se non sei sicuro su cosa scegliere",
  hard = "Se sei abituato a questo tipo di giochi e vuoi una sfida più impegnativa, scegli questa opzione",
  tutorial = "Se vuoi aiuto per cominciare mentre sei in gioco, spunta questa casella",
  start = "Avvia il gioco con le impostazioni scelte",
  cancel = "Oh, non volevo davvero cominciare una nuova partita!",
}

lua_console = {
  execute_code = "Esegui",
  close = "Chiudi",
}

tooltip.lua_console = {
  textbox = "Inserisci qui il codice Lua da eseguire",
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
  needs_restart = "Cambiare questa impostazione richiede che CorsixTH sia riavviato. Ogni progresso non salvato sarà perduto. Sei sicuro di volerlo fare?",
  abort_edit_room = "Stai attualmente costruendo o modificando una stanza. Se tutti gli oggetti richiesti sono stati posizionati sarà completata, altrimenti sarà cancellata. Continuare?",
  restart_level = "Sei sicuro di voler riavviare il livello?",
}

information = {
  custom_game = "Benvenuto in CorsixTH. Divertiti con questa mappa personalizzata!",
  no_custom_game_in_demo = "Spiacente, ma nella versione demo non puoi giocare mappe personalizzate.",
  cannot_restart = "Sfortunatamente questa mappa personalizzata è stata salvata prima che venisse implementata la funzione per riavviare.",
  very_old_save = "Il gioco è stato molto aggiornato da quando hai avviato questo livello. Per assicurarti che tutto funzioni come dovrebbe prendi in considerazione l'idea di riavviarlo.",
  level_lost = {
    "Peccato! Hai perso il livello. Avrai più fortuna la prossima volta!",
    "Hai perso perchè:",
    reputation = "La tua reputazione è scesa sotto %d.",
    balance = "Il tuo conto in banca è sceso sotto %d.",
    percentage_killed = "Hai ucciso più del %d dei pazienti.",
    cheat = "È stata una tua scelta o hai selezionato il pulsante sbagliato? Non riesci nemmeno a barare correttamente, non è così divertente, eh?",
  },
  cheat_not_possible = "Non puoi usare cheat in questo livello. Fallisci anche nel barare, non è così divertente, eh?",
}

tooltip.information = {
  close = "Chiudi la finestra delle informazioni",
}

totd_window = {
  tips = {
    "Ogni ospedale per funzionare ha bisogno di alcune strutture di base. Inizia con una reception e un ambulatorio, e il personale necessario. Una volta iniziato, dipenderà tutto dal tipo di pazienti che visiteranno il tuo ospedale. Qualche stanza per le diagnosi e una farmacia sono una buona scelta per iniziare.",
    "I macchinari come la Pompa hanno bisogno di manutenzione più o meno costante. Assumi qualche tuttofare per ripararle, o rischierai che i pazienti e il tuo staff si facciano male.",
    "Il tuo staff lavora duramente, e ogni tanto ha bisogno di riposare. Costruisci una sala del personale per loro.",
    "Ricordati di fornire il tuo ospedale di un impianto di riscaldamento funzionante, o lo staff ed i pazienti rimarranno infelici e infreddoliti.",
    "Il livello di competenza influenza in maniera enorme la qualità e la velocità delle diagnosi. Assegnando un dottore molto abile al tuo ambulatorio non avrai bisogno di costruire molte strutture di diagnosi addizionali.",
    "Assistenti e dottori possono aumentare il loro livello di competenza imparando da un consulente nella sala tirocinio. Se il consulente è anche uno specialista (chirurgo, psichiatra e/o ricercatore), passerà le sue conoscente ai suoi studenti.",
    "Hai provato a digitare il numero di emergenza europea (112) nel fax? Assicurati di avere l'audio attivato!",
    "Il menu d'opzioni non è ancora implementato, ma puoi regolare le impostazioni modificando il file config.txt nella directory di gioco.",
    "Hai selezionato il tuo linguaggio, ma tutto è in inglese? Aiutaci a convertire il gioco in più linguaggi!",
    "Il team di CorsixTH sta cercando rinforzi! Sei interessato in programmare, tradurre o creare nuovi elementi grafici per CorsixTH? Contattaci nei forum, tramite mail o sul canale IRC (corsix-th su freenode).",
    "Trovato un bug? Vuoi segnalare un errore di qualsiasi genere? Inviaci un rapporto su ciò che hai trovato al nostro bug tracker: th-issues.corsix.org",
    "Ogni livello ha degli obiettivi da raggiungere prima di poter passare al successivo. Controlla la finestra del riepilogo per vedere a che punto sei.",
    "Se vuoi modificare o rimuovere una stanza esistente, puoi farlo con il tasto modifica stanza nella barra degli strumenti in basso.",
    "In un'orda di pazienti in attesa, puoi vedere velocemente chi sta aspettando il proprio turno per una stanza particolare spostando il mouse sulla stanza.",
    "Clicca sulla porta di una stanza per vederne la coda. Puoi fare diverse cose utili, come riordinare la coda o mandare il paziente in un'altra stanza.",
    "Se il personale è infelice chiederà spesso aumenti di salario. Assicurati che il tuo staff stia lavorando in un'ambiente di lavoro confortevole per evitare che accada.",
    "I pazienti avranno sete durante le attese, soprattutto se alzi il riscaldamento! Piazza i distributori di bevande in posizioni strategiche per un po' di guadagni extra. ",
    "Puoi cancellare prematuramente il processo di diagnosi per un paziente e deciderne la cura se hai già incontrato la malattia. Fai attenzione però, dato che fare ciò può incrementare il rischio di una cura sbagliata, risultando nella morte del paziente.",
    "Le emergenze possono essere una buona fonte di guadagno extra, sempre che tu abbia i mezzi sufficienti a gestire l'emergenza in tempo.",
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
    yes = "Cheats usati: Sì",
  },
  cheats = {
    money = "Cheat soldi",
    all_research = "Cheat Completa Ricerche",
    emergency = "Crea Emergenza",
    vip = "Crea VIP",
    earthquake = "Crea Terremoto",
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
    emergency = "Crea un'emergenza.",
    vip = "Crea un VIP.",
    earthquake = "Crea un terremoto.",
    create_patient = "Crea un Paziente sul bordo della mappa.",
    end_month = "Salta alla fine del mese.",
    end_year = "Salta alla fine dell'anno.",
    lose_level = "Perdi il livello corrente.",
    win_level = "Vinci il livello corrente.",
  }
}

introduction_texts = {
  demo = {
    "Benvenuto nell'ospedale demo!",
    "Sfortunatamente la versione demo contiene solo questo livello. Ad ogni modo c'è abbastanza da fare per tenerti occupato per un bel po'!",
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


--------------------------------  UNUSED  -----------------------------------
------------------- (kept for backwards compatibility) ----------------------

options_window.change_resolution = "Cambia risoluzione"
tooltip.options_window.change_resolution = "Cambia la risoluzione della finestra con le dimensioni inserite a sinistra"

-- I added those lines because I didn't like 'em to show up in every diff dump!
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
original_credits[327] = ":Tutti alla Bullfrog Productions"
original_credits[328] = " "
original_credits[329] = " "
original_credits[330] = " "
original_credits[331] = ":Un Ringraziamento Speciale A"
original_credits[332] = ","
original_credits[333] = "Tutti al Frimley Park Hospital"
original_credits[334] = " "
original_credits[335] = ":Specialmente"
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
