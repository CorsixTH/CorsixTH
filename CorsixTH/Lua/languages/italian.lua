--[[ Copyright (c) 2010 Manuel "Roujin" Wolf, 2024 Peppe "Inkub0" Malara,
   2024 Sebastiano Pistore

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
fax.emergency.cure_not_possible_build = "E' necessario costruire un %s" -- È unsupported by TH font
fax.emergency.cure_not_possible_build_and_employ = "E' necessario costruire un %s e assumere un %s" -- È unsupported in TH font

-- An override for the squits becoming the the squits see issue 1646
adviser.research.drug_improved_1 = "Il medicinale per %s è stato migliorato dal Reparto ricerca."

-------------------------------  NEW STRINGS  -------------------------------
date_format = {
  daymonth = "%1% %2:months%",
}

object.litter = "Spazzatura"
tooltip.objects.litter = "Spazzatura: Lasciata sul pavimento da un paziente perché non ha trovato un cestino in cui gettarla."

object.rathole = "Tana di ratti"
tooltip.objects.rathole = "Casa di una famiglia di ratti che trova l'ospedale abbastanza sporco da poterci vivere."

tooltip.fax.close = "Chiudi questa finestra senza cancellare il messaggio"
tooltip.message.button = "Click sinistro per aprire il messaggio"
tooltip.message.button_dismiss = "Click sinistro per aprire il messaggio, click destro per eliminarlo"
tooltip.casebook.cure_requirement.hire_staff = "Hai bisogno di assumere personale per somministrare questa cura"
tooltip.casebook.cure_type.unknown = "Ancora non sei a conoscenza di una cura per questa malattia"
tooltip.research_policy.no_research = "Non c'è nessuna ricerca in corso in questa categoria al momento"
tooltip.research_policy.research_progress = "Progresso verso una nuova scoperta in questa categoria: %1%/%2%"

menu["player_count"] = "CONTA GIOCATORI"

menu_file = {
  load =    " (%1%) CARICA   ",
  save =    " (%1%) SALVA   ",
  restart = " (%1%) RIAVVIA",
  quit =    " (%1%) ESCI   "
}

menu_options = {
  sound = "  (%1%) SONORO   ",
  announcements = "  (%1%) ANNUNCI   ",
  music = "  (%1%) MUSICA   ",
  jukebox = "  (%1%) JUKEBOX  ",
  lock_windows = "  BLOCCA FINESTRE  ",
  edge_scrolling = "  SCORRIMENTO AI LATI  ",
  capture_mouse = "  INTRAPPOLA MOUSE  ",
  adviser_disabled = "  (%1%) CONSIGLIERE  ",
  warmth_colors = "  COLORI RISCALDAMENTO  ",
  wage_increase = "  RICHIESTE STIPENDI",
  twentyfour_hour_clock = "  OROLOGIO 24 ORE  "
}

menu_options_game_speed = {
  pause               = "  (%1%) PAUSA  ",
  slowest             = "  (%1%) LENTISSIMO  ",
  slower              = "  (%1%) LENTO  ",
  normal              = "  (%1%) NORMALE  ",
  max_speed           = "  (%1%) VELOCITA' MASSIMA  ",
  and_then_some_more  = "  (%1%) E ANCORA DI PIU'  ",
}

menu_options_warmth_colors = {
  choice_1 = "  ROSSO  ",
  choice_2 = "  BLU VERDE ROSSO  ",
  choice_3 = "  GIALLO ARANCIONE ROSSO  ",
}

menu_options_wage_increase = {
  grant = "    CONCEDI ",
  deny =  "    NEGA ",
}

-- Add F-keys to entries in charts menu (except briefing), also town_map was added.
menu_charts = {
  bank_manager  = "  (%1%) BANCA  ",
  statement     = "  (%1%) RENDICONTO  ",
  staff_listing = "  (%1%) PERSONALE  ",
  town_map      = "  (%1%) MAPPA CITTADINA  ",
  casebook      = "  (%1%) REGISTRO CURE  ",
  research      = "  (%1%) RICERCA  ",
  status        = "  (%1%) RIEPILOGO  ",
  graphs        = "  (%1%) GRAFICI  ",
  policy        = "  (%1%) GESTIONE  ",
}


-- The demo does not contain this string
menu_file.restart = "  RIAVVIA  "

menu_debug = {
  jump_to_level               = "  SALTA AL LIVELLO  ",
  connect_debugger            = "  (%1%) CONNETTI SERVER LUA DBGp  ",
  transparent_walls           = "  (%1%) MURI TRASPARENTI  ",
  limit_camera                = "  LIMITA TELECAMERA  ",
  disable_salary_raise        = "  DISABILITA AUMENTI DI SALARIO  ",
  make_debug_fax              = "  CREA FAX DI DEBUG  ",
  make_debug_patient          = "  CREA PAZIENTE DI DEBUG  ",
  cheats                      = "  (%1%) CHEAT  ",
  lua_console                 = "  (%1%) CONSOLE LUA  ",
  debug_script                = "  (%1%) ESEGUI SCRIPT DI DEBUG  ",
  calls_dispatcher            = "  GESTORE CHIAMATE  ",
  dump_strings                = "  (%1%) DUMP DELLE STRINGHE  ",
  dump_gamelog                = "  (%1%) DUMP DEL GAMELOG  ",
  map_overlay                 = "  MAPPA IN SOVRAPPOSIZIONE  ",
  sprite_viewer               = "  VISUALIZZATORE SPRITE  ",
  allow_blocking_off_areas    = " CONSENTI IL BLOCCO DI ALCUNE AREE ",
}
menu_debug_overlay = {
  none                        = "  NESSUN OVERLAY  ",
  flags                       = "  FLAG  ",
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
menu_player_count = {
    players_1 = "  1 GIOCATORE  ",
    players_2 = "  2 GIOCATORI  ",
    players_3 = "  3 GIOCATORI  ",
    players_4 = "  4 GIOCATORI  ",
}
adviser = {
  room_forbidden_non_reachable_parts = "Mettere la stanza in questa posizione bloccherebbe l'accesso ad alcune parti dell'ospedale.",
  staff_place_advice = {
    not_enough_lecture_chairs = "Ogni studente medico ha bisogno di uno sgabello su cui sedersi!",
  },
  warnings = {
    no_desk = "Prima o poi dovrai costruire un banco di accettazione ed assumere una receptionist!",
    no_desk_1 = "Se vuoi che i pazienti vengano nel tuo ospedale dovrai assumere una receptionist e costruirle una scrivania dove farla lavorare!",
    no_desk_2 = "Ben fatto, deve essere un record mondiale: quasi un anno e nessun paziente! Se vuoi continuare come Manager di questo ospedale dovrai assumere una receptionist e costruire un banco di accettazione dove farla lavorare!",
    no_desk_3 = "Grandioso, quasi un anno e ancora non hai personale all'accettazione! Come ti aspetti di trovare pazienti, ora vedi di rimediare e di non fare più casini!",
    no_desk_4 = "Una receptionist ha bisogno della sua stazione di lavoro per accogliere i clienti quando arrivano",
    no_desk_5 = "Beh, era ora, presto dovresti cominciare a vedere arrivare i pazienti!",
    no_desk_6 = "Hai una receptionist, che ne dici quindi di costruirle un banco di accettazione dove poter lavorare?",
    no_desk_7 = "Hai costruito il banco di accettazione, quindi che ne dici di assumere una receptionist? Non vedrai pazienti finché non risolvi questa cosa!",
    cannot_afford = "Non hai abbastanza soldi in banca per assumere quella persona!", -- I can't see anything like this in the original strings
    cannot_afford_2 = "Non hai abbastanza soldi in banca per fare quell'acquisto!",
    falling_1 = "Ehi! Non è divertente, attento a dove clicchi: qualcuno potrebbe farsi male!",
    falling_2 = "Basta fare casini, a te piacerebbe?",
    falling_3 = "Ahi, deve far male, qualcuno chiami un dottore!",
    falling_4 = "Questo è un ospedale, non un parco giochi!",
    falling_5 = "Non è il luogo adatto per far cadere le persone, sono malate sai!",
    falling_6 = "Non è una sala da bowling, i malati non dovrebbero essere trattati così!",
    research_screen_open_1 = "Devi costruire un Reparto Ricerca prima di poter accedere alla schermata Ricerca.",
    research_screen_open_2 = "La ricerca è disabilitata in questo livello.",
    researcher_needs_desk_1 = "Un ricercatore ha bisogno di una scrivania su cui lavorare.",
    researcher_needs_desk_2 = "Al tuo ricercatore ha fatto piacere tu gli abbia concesso una pausa. Se invece volevi assegnare più personale alla ricerca devi procurare a ognuno di loro una scrivania sulla quale lavorare.",
    researcher_needs_desk_3 = "Ogni ricercatore ha bisogno della propria scrivania su cui poter lavorare.",
    nurse_needs_desk_1 = "Ogni infermiera ha bisogno della propria scrivania su cui poter lavorare.",
    nurse_needs_desk_2 = "Alla tua infermiera ha fatto piacere tu le abbia concesso una pausa. Se invece volevi assegnare più personale al reparto devi procurare a ognuna di loro una scrivania sulla quale lavorare.",
    low_prices = "I tuoi prezzi per %s sono troppo bassi. Questo attirerà più persone nel tuo ospedale, ma non guadagnerai molto da ognuno di loro.",
    high_prices = "I tuoi prezzi per %s sono alti. In questo modo vedrai buoni guadagni sul breve periodo, ma a lungo andare spingerai molte persone ad andarsene.",
    fair_prices = "I tuoi prezzi per %s sembrano giusti ed equilibrati.",
    patient_not_paying = "Un paziente è andato via senza pagare %s perché è troppo costosa!",
    another_desk = "Dovrai costruire un'altra scrivania per la nuova receptionist.",
    cannot_afford_machine = "Ti servono almeno $%1% in banca per pagare %2%!",
  },
  cheats = {
    th_cheat = "Congratulazioni, hai sbloccato i cheat!",
    roujin_on_cheat = "Sfida di Roujin attivata! Buona fortuna...",
    roujin_off_cheat = "Sfida di Roujin disattivata.",
    norest_off_cheat = "Uff! Sembra che quel ronzio finalmente sia svanito. Ora il tuo staff riposerà adeguatamente.",
    norest_on_cheat = "Oh no! Sembra che il tuo personale abbia assunto troppa caffeina e non senta più il bisogno di riposare.",
  },
}

dynamic_info.patient.actions.no_gp_available = "Aspetta che venga costruito un ambulatorio"
dynamic_info.staff.actions.heading_for = "Sta andando verso %s"
dynamic_info.staff.actions.fired = "Licenziato"
dynamic_info.patient.actions.epidemic_vaccinated = "Non sono più infetto"
dynamic_info.object.strength_extra_info = "Forza %d (Migliorabile a %d)"
dynamic_info.staff.actions.vaccine = "Sta vaccinando un paziente"

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
  dear_player = "Caro %s\n",
  custom_level_completed = "Ben fatto! Hai completato tutti gli obiettivi di questo livello personalizzato!",
  return_to_main_menu = "Vuoi tornare al menu principale o vuoi continuare a giocare?",
  campaign_level_completed = "Ottimo lavoro! Hai battuto il livello. Ma non è ancora finita!\n Saresti interessato a una posizione nell'ospedale %s?",
  campaign_completed = "Incredibile! Sei riuscito a completare tutti i livelli. Ora puoi rilassarti e divertirti a riempire i forum su internet con i tuoi fantastici risultati. Buona fortuna!",
  campaign_level_missing = "Mi dispiace, ma sembra che il livello successivo di questa campagna non sia presente. (Nome: %s)",
}

install = {
  title = "----------------------------- Installazione CorsixTH -----------------------------",
  th_directory = "CorsixTH ha bisogno di una copia dei file dati di Theme Hospital (o della demo) per essere eseguito. Per favore indica la posizione della cartella HOSP nell'installazione di Theme Hospital.",
  ok = "Ok",
  exit = "Esci",
  cancel = "Annulla",
}

misc = {
  not_yet_implemented = "(non ancora implementato)",
  no_heliport = "Non è stata ancora scoperta nessuna malattia, non c'è un eliporto sulla mappa oppure potrebbe essere necessario costruire un banco accettazione e assumere una receptionist",
  epidemic_no_icon_to_toggle = "Impossibile mostrare/nascondere icone infezione - non ci sono epidemie in corso che non siano gia' state rivelate",
  epidemic_no_diseases = "Impossibile creare epidemia - non ci sono malattie contagiose disponibili.",
  cant_treat_emergency = "Il tuo ospedale non può affrontare questa emergenza perché la sua malattia non è stata scoperta. Sentiti libero di riprovare.",
  earthquakes_on = "I terremoti sono riabilitati",
  epidemics_on = "Le epidemie sono riabilitate",
  epidemic_no_receptionist = "Impossibile creare epidemia - nessuna reception funzioante",
  epidemics_off = "Le epidemie sono abilitate",
  earthquakes_off = "I terremoti sono abilitati",
}

hotkeys_file_err.file_err_01 = "Impossibile caricare il file hotkeys.txt. Assicurati che CorsixTH abbia permessi in lettura/scrittura "
hotkeys_file_err.file_err_02 = ", oppure usa l'opzione --hotkeys-file=filename in riga di comando per specificare un file con tali permessi. Per riferimento, l'errore durante il caricamento era: "

main_menu = {
  new_game = "Nuova partita",
  custom_campaign = "Campagna personalizzata",
  custom_level = "Livello personalizzato",
  continue = "Continua partita",
  load_game = "Carica partita",
  options = "Opzioni",
  map_edit = "Editor mappe",
  savegame_version = "Versione salvataggi: ",
  version = "Versione: ",
  exit = "Esci",
  updates_off = "Niente controllo aggiornamenti",
}

tooltip.main_menu = {
  new_game = "Inizia una nuova partita",
  custom_campaign = "Gioca una campagna creata dalla comunità",
  custom_level = "Costruisci il tuo ospedale in un livello personalizzato",
  load_game = "Carica una partita salvata in precedenza",
  options = "Modifica le impostazioni",
  map_edit = "Crea una mappa personalizzata",
  exit = "No, per favore non andartene!",
}

load_game_window = {
  caption = "Carica partita (%1%)",
}

tooltip.load_game_window = {
  load_game = "Carica la partita %s",
  load_game_number = "Carica la partita %d",
  load_autosave = "Carica autosalvataggio",
}

custom_game_window = {
  caption = "Partita personalizzata",
  free_build = "Costruzione libera",
  load_selected_level = "Inizia",
}

tooltip.custom_game_window = {
  choose_game = "Clicca su un livello per avere più informazioni",
  free_build = "Spunta questa casella per giocare senza soldi, né vittoria o sconfitta",
  load_selected_level = "Carica e gioca il livello selezionato",
}

custom_campaign_window = {
  caption = "Campagna personalizzata",
  start_selected_campaign = "Inizia campagna",
}

tooltip.custom_campaign_window = {
  choose_campaign = "Seleziona una campagna per avere più informazioni",
  start_selected_campaign = "Carica il primo livello di questa campagna",
}

save_game_window = {
  caption = "Salva partita (%1%)",
  new_save_game = "Nuovo salvataggio",
}

tooltip.save_game_window = {
  save_game = "Sovrascrivere salvataggio %s",
  new_save_game = "Inserisci il nome per un nuovo salvataggio",
}

save_map_window = {
  caption = "Salva mappa (%1%)",
  new_map = "Nuova mappa",
}

tooltip.save_map_window = {
  map = "Sovrascrivi mappa %s",
  new_map = "Inserisci il nome per salvataggio mappa",
}

menu_list_window = {
  name = "Nome",
  save_date = "Modificata",
  back = "Indietro",
  ok = "OK",
}

tooltip.menu_list_window = {
  name = "Clicca qui per ordinare la lista in ordine alfabetico",
  save_date = "Clicca qui per ordinare la lista in base alla data dell'ultima modifica",
  back = "Chiudi questa finestra",
  ok = "Conferma scelta",
}

-- Width / height's translation doesn't fit - had to write "larghezza" and "altezza" shorter
options_window = {
  caption = "Opzioni",
  option_on = "On",
  option_off = "Off",
  fullscreen = "Schermo intero",
  resolution = "Risoluzione",
  capture_mouse = "Cattura Mouse",
  custom_resolution = "Personalizzata...",
  width = "Largh",
  option_enabled = "Attiv.",
  height = "Alt",
  audio = "Audio globale",
  scrollspeed = "Vel. scorrimento",
  shift_scrollspeed = "Vel. scorrimento veloce",
  zoom_speed = "Velocità zoom",
  check_for_updates = "Cerca aggiornamenti",
  customise = "Personalizza",
  folder = "Cartelle",
  language = "Lingua del gioco",
  apply = "Applica",
  hotkey = "Scorciatoie",
  cancel = "Cancella",
  back = "Indietro",
  scrollspeed = "Velocità scorrimento",
  option_disabled = "Disabilitato",
  hotkey = "Scorciatoie",
  option_enabled = "Abilitato",
  zoom_speed = "Velocità zoom",
  shift_scrollspeed = "Velocità di scorrimento con Maiusc",
  jukebox = "Jukebox",
  right_mouse_scrolling_option_right = "Bottone Destro",
  right_mouse_scrolling_option_middle = "Bottone Centrale",
  check_for_updates = "Cerca  aggiornamenti",
  right_mouse_scrolling = "Scorrimento con Mouse",
}

tooltip.options_window = {
  fullscreen = "Decide se il gioco verrà eseguito a schermo intero o in finestra",
  fullscreen_button = "Clicca per attivare o disattivare la modalità a schermo intero",
  resolution = "La risoluzione a cui il gioco dovrebbe essere eseguito",
  select_resolution = "Seleziona una nuova risoluzione",
  capture_mouse = "Clicca per attivare o disattivare la cattura del puntatore all'interno della finestra di gioco",
  width = "Inserisci la larghezza dello schermo desiderata",
  height = "Inserisci l'altezza dello schermo desiderata",
  apply = "Applica la risoluzione inserita",
  cancel = "Esci senza cambiare la risoluzione",
  audio_button = "Attiva o disattiva tutti i suoni del gioco",
  audio_toggle = "Audio on o off",
  customise_button = "Altre impostazioni che puoi cambiare per personalizzare la tua esperienza di gioco",
  folder_button = "Opzioni cartelle",
  language = "La lingua in cui verrà mostrato il testo",
  select_language = "Seleziona la lingua del gioco",
  language_dropdown_item = "Seleziona %s come lingua",
  scrollspeed = "Imposta la velocità di scorrimento con il mouse tra 1 (più bassa) e 10 (più veloce). Il default è 2.",
  shift_scrollspeed = "Imposta la velocità di scorrimento con il tasto MAIUSC premuto tra 1 (più bassa) e 10 (più veloce). Il default è 4.",
  back = "Chiudi la finestra delle opzioni",
  scrollspeed = "Imposta la velocità di scorrimento tra 1 (minimo) e 10 (massimo). Il valore predefinito è 2.",
  shift_scrollspeed = "Imposta la velocità di scorrimento mentre si tiene premuto il tasto Maiusc. Da 1 (minimo) a 10 (massimo). Il valore predefinito è 4.",
  hotkey = "Cambia le scorciatoie da tastiera.",
  apply_shift_scrollspeed = "Applica la velocità di scorrimento dello spostamento selezionata.",
  right_mouse_scrolling = "Attiva/disattiva il pulsante del mouse utilizzato per scorrere la mappa",
  cancel_scrollspeed = "Torna senza cambiare la velocità di scorrimento.",
  jukebox = "Apri il Jukebox per controllare la musica",
  zoom_speed = "Imposta la velocità di zoom della telecamera da 10 (minimo) a 1000 (massimo). Il valore predefinito è 80.",
  language_dropdown_no_font = "Seleziona un font nelle impostazioni delle cartelle per abilitare questa lingua",
  cancel_zoomspeed = "Torna senza cambiare la velocità di zoom",
  cancel_shift_scrollspeed = "Torna senza cambiare la velocità di scorrimento con Maiusc.",
  check_for_updates = "Imposta se il gioco debba cercare aggiornamenti all'avvio.",
  apply_zoomspeed = "Applica la velocità di zoom selezionata.",
  apply_scrollspeed = "Applica la velocità di scorrimento selezionata.",
}

customise_window = {
  caption = "Impostazioni personalizzate",
  option_on = "On",
  option_off = "Off",
  back = "Indietro",
  movies = "Controllo filmati globale",
  intro = "Riproduci filmato introduttivo",
  paused = "Costruzione durante la pausa",
  volume = "Scorciatoia volume basso",
  aliens = "Pazienti alieni",
  fractured_bones = "Ossa rotte",
  average_contents = "Oggetti frequenti",
  remove_destroyed_rooms = "Rimuovi stanze distrutte",
}

tooltip.customise_window = {
  movies = "Controllo filmati globale, questo ti permette di disattivare tutti i filmati",
  intro = "Disattiva o attiva la riproduzione del filmato introduttivo. I filmati globali devono essere attivati se vuoi che il filmato introduttiva venga riprodotto ogni volta che avvii CorsixTH",
  paused = "In Theme Hospital al giocatore è consentito utilizzare il menu in alto solo se il gioco è in pausa. Questa è l'impostazione predefinita anche in CorsixTH, ma attivandola tutto è consentito mentre il gioco è in pausa",
  volume = "Se il pulsante per abbassare il volume ti fa aprire anche il Registro Cure, attiva questa opzione per impostare Shift + C come scorciatoia per il Registro Cure",
  aliens = "A causa dell'assenza delle giuste animazioni abbiamo fatto sì che i pazienti con DNA Alieno possano arrivare solo con un'emergenza. Per permettere ai pazienti con DNA Alieno di visitare il tuo ospedale anche al di fuori delle emergenze disattiva questa opzione",
  fractured_bones = "A causa della scarsa qualità di alcune animazioni abbiamo fatto sì che non ci siano pazienti donne con Ossa Rotte. Per far sì che donne con Ossa Rotte visitino il tuo ospedale, disattiva questa opzione",
  average_contents = "Se vuoi che il gioco ricordi quali oggetti extra aggiungi di solito quando crei una stanza attiva questa opzione",
  back = "Chiudi questo menù e torna al menù delle impostazioni",
  remove_destroyed_rooms = "Se desideri poter rimuovere le stanze distrutte a pagamento, attiva questa opzione",
}

folders_window = {
  caption = "Posizione cartelle",
  data_label = "Posizione TH",
  font_label = "Font",
  music_label = "Musica",
  savegames_label = "Salvataggi",
  screenshots_label = "Screenshot",
  -- next four are the captions for the browser window, which are called from the folder setting menu
  new_th_location = "Qui puoi specificare una nuova directory di installazione di Theme Hospital o un file ISO. Non appena scegli la nuova directory, il gioco verrà riavviato. Tieni presente che le estensioni dei file non sono attualmente visualizzate.",
  savegames_location = "Seleziona la cartella che vuoi usare per i salvataggi",
  music_location = "Seleziona la cartella che vuoi usare per la tua musica",
  screenshots_location = "Seleziona la cartella che vuoi usare per i tuoi screenshot",
  back  = "Indietro",
}

tooltip.folders_window = {
  browse = "Sfoglia le cartelle",
  data_location = "La cartella dell'installazione originale di Theme Hospital, che è richiesto per eseguire CorsixTH",
  font_location = "Posizione di un font che è in grado di mostrare i caratteri Unicode richiesti dalla tua lingua. Se non specificata, non potrai scegliere lingue che hanno bisogno di più caratteri rispetto a quelli di cui dispone il gioco originale. Esempio: Russo e Cinese",
  savegames_location = "Per impostazione predefinita, la cartella dei salvataggi si trova accanto al file di configurazione e verrà utilizzata per archiviare i giochi salvati. In alternativa, puoi usarne un'altra selezionando quella che desideri utilizzare.",
  screenshots_location = "Per impostazione predefinita, la cartella dei salvataggi si trova accanto al file di configurazione. In alternativa, puoi usarne un'altra selezionando quella che desideri utilizzare.",
  music_location = "Seleziona la posizione per i tuoi file MP3. Devi aver già creato la cartella e poi selezionare la cartella che hai creato.",
  browse_data = "Sfoglia per selezionare un percorso diverso per l'installazione di Theme Hospital ( Percorso attuale: %1% )",
  browse_font = "Sfoglia per selezionare un altro file font ( posizione attuale: %1% )",
  browse_saves = "Sfoglia per selezionare un percorso diverso per la tua cartella dei salvataggi ( Percorso attuale: %1% ) ",
  browse_screenshots = "Sfoglia per selezionare percorso diverso per la tua cartella degli screenshot ( Percorso attuale: %1% ) ",
  browse_music = "Sfoglia per selezionare un percorso diverso per la tua cartella della musica ( Percorso attuale: %1% ) ",
  no_font_specified = "Non è stata ancora specificata nessuna posizione per il font!",
  not_specified = "Non è stato ancora specificato nessun percorso per la cartella!",
  default = "Posizione di default",
  reset_to_default = "Ripristina la cartella al suo percorso originario",
  back  = "Chiudi questo menù e torna al menù delle impostazioni",
}

hotkey_window = {
  button_accept = "Accetta",
  button_back = "Indietro",
  button_cancel = "Cancella",
  button_defaults = "Ripristina impostazioni predefinite",
  button_gameSpeedKeys = "Tasti Velocità Gioco",
  button_recallPosKeys = "Richiama tasti Posizione",
  button_toggleKeys = "Attiva/Disattiva Tasti",
  caption_main = "Assegnazione Scorciatoie",
  caption_panels = "Tasti Pannello",
  global_cancel = "Cancella",
  global_cancel_alt = "Cancel Alt",
  global_confirm = "Conferma",
  global_confirm_alt = "Conferma Alt",
  global_connectDebugger = "Debugger",
  global_exitApp = "Esci da App",
  global_fullscreen_toggle = "Schermo Intero",
  global_releaseMouse = "Rilascia Puntatore",
  global_resetApp = "Reset App",
  global_runDebugScript = "Script per Debug",
  global_screenshot = "Screenshot",
  global_showLuaConsole = "Console Lua",
  global_stop_movie_alt = "Ferma Video",
  global_window_close_alt = "Chiudi Finestra",
  ingame_gamespeed_max = "Max",
  ingame_gamespeed_normal = "Normale",
  ingame_gamespeed_slower = "Rallenta",
  ingame_gamespeed_slowest = "Lentissimo",
  ingame_gamespeed_speedup = "Accellera",
  ingame_gamespeed_thensome = "E ancora",
  ingame_jukebox = "Jukebox",
  ingame_loadMenu = "Carica Gioco",
  ingame_openFirstMessage = "Messaggio Livello",
  ingame_panel_bankManager = "Azioni Banca",
  ingame_panel_bankStats = "Saldo in Banca",
  ingame_panel_buildRoom = "Costruisci Stanza",
  ingame_panel_casebook = "Casebook",
  ingame_panel_casebook_alt = "Casebook 2",
  ingame_panel_casebook_alt02 = "Casebook 3",
  ingame_panel_charts = "Grafici",
  ingame_panel_editRoom = "Modifica Stanza",
  ingame_panel_furnishCorridor = "Arreda Corridoio",
  ingame_panel_hireStaff = "Assumi Personale",
  ingame_panel_map_alt = "Mappa Città 2",
  ingame_panel_policy = "Policy",
  ingame_panel_research = "Ricerca",
  ingame_panel_research_alt = "Ricerca 2",
  ingame_panel_staffManage = "Gestisci il Personale",
  ingame_panel_status = "Status",
  ingame_panel_townMap = "Mappa Città",
  ingame_patient_gohome = "Manda a Casa",
  ingame_pause = "Pausa",
  ingame_poopLog = "Visualizza Log",
  ingame_poopStrings = "Visualizza Stringhe",
  ingame_quickLoad = "Carica Salvataggio Veloce",
  ingame_quickSave = "Salvataggio Veloce",
  ingame_quitLevel = "Esci dal Livello",
  ingame_recallPosition_0 = "10",
  ingame_recallPosition_1 = "1",
  ingame_recallPosition_2 = "2",
  ingame_recallPosition_3 = "3",
  ingame_recallPosition_4 = "4",
  ingame_recallPosition_5 = "5",
  ingame_recallPosition_6 = "6",
  ingame_recallPosition_7 = "7",
  ingame_recallPosition_8 = "8",
  ingame_recallPosition_9 = "9",
  ingame_reset_zoom = "Reimposta Zoom",
  ingame_restartLevel = "Riavvia Livello",
  ingame_rotateobject = "Ruota Oggetto",
  ingame_saveMenu = "Salva Gioco",
  ingame_scroll_down = "Scorri in Basso",
  ingame_scroll_left = "Scorri a Sinistra",
  ingame_scroll_right = "Scorri a Destra",
  ingame_scroll_shift = "Velocità Maiusc",
  ingame_scroll_up = "Scorri in Alto",
  ingame_setTransparent = "Trasparente",
  ingame_showCheatWindow = "Menu Cheat",
  ingame_showmenubar = "Mostra barra dei Menu",
  ingame_storePosition_0 = "10",
  ingame_storePosition_1 = "1",
  ingame_storePosition_2 = "2",
  ingame_storePosition_3 = "3",
  ingame_storePosition_4 = "4",
  ingame_storePosition_5 = "5",
  ingame_storePosition_6 = "6",
  ingame_storePosition_7 = "7",
  ingame_storePosition_8 = "8",
  ingame_storePosition_9 = "9",
  ingame_toggleAdvisor = "Consulente",
  ingame_toggleAnnouncements = "Annunci",
  ingame_toggleInfo = "Info",
  ingame_toggleMusic = "Musica",
  ingame_toggleSounds = "Suoni",
  ingame_zoom_in = "Zoom",
  ingame_zoom_in_more = "Ingrandisci",
  ingame_zoom_out = "Rimpicciolisci",
  ingame_zoom_out_more = "Rimpicciolisci",
  panel_altPanelKeys = "Tasti Pannello Alternativi",
  panel_debugKeys = "Tasti Debug",
  panel_gameSpeedKeys = "Tasti Velocità Gioco",
  panel_generalInGameKeys = "Tasti Generali di Gioco",
  panel_globalKeys = "Tasti Generali",
  panel_recallPosKeys = "Richiama Tasti di Posizione",
  panel_scrollKeys = "Tasti Scorrimento",
  panel_storePosKeys = "Salvare Tasti di Posizione",
  panel_toggleKeys = "Attiva/Disattiva Tasti",
  panel_zoomKeys = "Tasti Zoom",
}

font_location_window = {
  caption = "Scegli il font (%1%)",
}

handyman_window = {
  all_parcels = "Tutti i lotti",
  parcel = "Lotto"
}

tooltip.handyman_window = {
  parcel_select = "Il lotto dove l'inserviente può operare, clicca per cambiarlo"
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
  cancel = "Annulla",
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
  no_games_to_contine = "Non ci sono partite salvate.",
  load_quick_save = "Errore, non è possibile caricare il salvataggio veloce perché non esiste, ma non preoccuparti: ne abbiamo appena creato uno al posto tuo!",
  map_file_missing = "Non ho potuto trovare la mappa %s per questo livello!",
  minimum_screen_size = "Per favore inserisci almeno una risoluzione di 640x480.",
  unavailable_screen_size = "La risoluzione che hai richiesto non è disponibile a schermo intero.",
  alien_dna = "NOTA: Non ci sono animazioni per i pazienti Alieni per quando si siedono, aprono o bussano sulle porte etc. Quindi, così come in Theme Hospital, mentre fanno queste cose appariranno normali per poi tornare ad apparire alieni. I pazienti con DNA Alieno appariranno solo se impostati dal file del livello",
  fractured_bones = "NOTA: L'animazione per i pazienti donne con Ossa Rotte non è perfetta",
  could_not_load_campaign = "Errore nel caricare la campagna: %s",
  could_not_find_first_campaign_level = "Non è stato possibile trovare il primo livello di questa campagna: %s",
  load_map_prefix = "Errore nel caricamento della Mappa: ",
  save_to_tmp = "Il file al percorso %s non può essere usato. Il gioco è stato salvato qui %s. Errore: %s",
  load_level_prefix = "Errore durante il caricamento del livello: ",
  compatibility_error = {
    new_in_old = "Mi dispiace, ma questo salvataggio è stato creato con una versione più recente di CorsixTH e non è compatibile. Per favore, aggiorna a una versione più recente.",
    full_in_demo = "Mi dispicae, non puoi aprire un salvataggio completo del gioco con i file demo caricati. Aggiorna il percorso della cartella Dati di TH.",
    demo_in_full = "Spiacenti, non puoi aprire un salvataggio demo con i file di gioco completi caricati. Aggiorna il percorso della cartella Dati di TH.",
  },
  dialog_empty_queue = "Mi dispiace, un umanoide aveva una coda di azioni vuota, il che significa che non sapeva cosa doveva fare. Consultare la finestra di comando per informazioni più dettagliate. È stato aperto un dialogo con l'umanoide incriminato. Vorresti che lasciasse l'ospedale?",
}

warnings = {
  levelfile_variable_is_deprecated = "Attenzione: Il livello %s contiene una definizione di variabile deprecata nel file di livello." ..
                                     "'%LevelFile' è stato rinominato in '%MapFile'. Per favore richiedi al creatore della mappa di aggiornare il livello.",
  newersave = "Attenzione, hai caricato un salvataggio da una versione più recente di CorsixTH. Non è consigliabile continuare poiché potrebbero verificarsi arresti anomali. Gioca a tuo rischio.",
}

confirmation = {
  needs_restart = "Cambiare questa impostazione richiede che CorsixTH sia riavviato. Ogni progresso non salvato sarà perduto. Sei sicuro di volerlo fare?",
  abort_edit_room = "Stai attualmente costruendo o modificando una stanza. Se tutti gli oggetti richiesti sono stati posizionati sarà completata, altrimenti sarà cancellata. Continuare?",
  maximum_screen_size = "La risoluzione che hai inserito è superiore a 3000x2000. Risoluzioni maggiori sono supportate, ma richiederanno un hardware migliore per mantenere un livello di frame rate giocabile. Sei sicuro di voler continuare?",
  music_warning = "Nota: è necessario avere la libreria smpeg.dll o equivalente nel tuo sistema operativo, altrimenti non sentirai alcuna musica nel gioco. Vuoi continuare?",
 --This next line isn't in the english.lua, but when strings are dump it is reported missing
  restart_level = "Sei sicuro di voler riavviare il livello?",
}

information = {
  custom_game = "Benvenuto in CorsixTH. Divertiti con questa mappa personalizzata!",
  no_custom_game_in_demo = "Spiacente, ma nella versione demo non puoi giocare mappe personalizzate.",
  cannot_restart = "Sfortunatamente questa mappa personalizzata è stata salvata prima che venisse implementata la funzione per riavviare.",
  very_old_save = "Il gioco è stato molto aggiornato da quando hai avviato questo livello. Per assicurarti che tutto funzioni a dovere, considera l'idea di riavviarlo.",
  level_lost = {
    "Peccato! Hai perso il livello. Avrai più fortuna la prossima volta!",
    "Hai perso perchè:",
    reputation = "Hai ucciso più del %d percento dei pazienti.",
    balance = "Il tuo conto in banca è sceso sotto %d.",
    percentage_killed = "Hai ucciso più del %d dei pazienti.",
    cheat = "È stata una tua scelta o hai selezionato il pulsante sbagliato? Non riesci nemmeno a barare correttamente. Divertente, vero?",
  },
  cheat_not_possible = "Non puoi usare questo cheat in questo livello. Non riesci nemmeno a barare correttamente. Divertente, vero?",
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
    "Hai selezionato la tua lingua, ma è tutto in Inglese? Aiutaci a tradurre il gioco!",
    "Il team di CorsixTH sta cercando rinforzi!  Ti piacerebbe programmare, tradurre o creare nuovi elementi grafici per CorsixTH? Contattaci nei forum, tramite mail o sul canale IRC (corsix-th su freenode).",
    "Hai trovato un bug? Vuoi segnalare un errore di qualsiasi genere? Invia una segnalazione al nostro bug tracker: th-issues.corsix.org",
    "Ogni livello ha degli obiettivi da raggiungere prima di poter passare al successivo. Controlla la finestra di riepilogo per vedere a che punto sei.",
    "Se vuoi modificare o rimuovere una stanza esistente, puoi farlo con il tasto modifica stanza nella barra degli strumenti in basso.",
    "In un'orda di pazienti in attesa, puoi vedere velocemente chi sta aspettando il proprio turno per una stanza particolare spostando il mouse sulla stanza.",
    "Clicca sulla porta di una stanza per vederne la coda. Puoi fare diverse cose utili, come riordinare la coda o mandare il paziente in un'altra stanza.",
    "Se il personale è infelice chiederà spesso aumenti di salario. Assicurati che il tuo staff stia lavorando in un'ambiente di lavoro confortevole per evitare che accada.",
    "I pazienti avranno sete durante le attese, soprattutto se alzi il riscaldamento! Piazza i distributori di bevande in posizioni strategiche per un po' di guadagni extra. ",
    "Puoi cancellare prematuramente il processo di diagnosi per un paziente e deciderne la cura se hai già incontrato la malattia. Fai attenzione però, dato che fare ciò può incrementare il rischio di una cura sbagliata, risultando nella morte del paziente.",
    "Le emergenze possono essere una buona fonte di guadagno extra, sempre che tu abbia i mezzi sufficienti a gestire l'emergenza in tempo.",
    "Sapevi che puoi assegnare i Tuttofare ad aree specifiche? Basta fare clic sul testo Tutte le aree nel profilo dello staff per scorrerle!",
  },
  previous = "Suggerimento precedente",
  next = "Suggerimento successivo",
}

tooltip.totd_window = {
  previous = "Passa al suggerimento precedente",
  next = "Passa al suggerimento successivo",
}

debug_patient_window = {
  caption = "Debug paziente",
}

tooltip.debug_patient_window = {
  item = "Crea un paziente debug con %s",
}

cheats_window = {
  caption = "Cheat",
  warning = "Attenzione: non riceverai alcun punto bonus alla fine del livello se usi i trucchi!",
  cheated = {
    no = "Cheat usati: No",
    yes = "Cheat usati: Sì",
  },
  cheats = {
    money = "Cheat soldi",
    all_research = "Completa ricerche",
    emergency = "Crea emergenza",
    vip = "Crea VIP",
    earthquake = "Crea terremoto",
    epidemic = "Genera paziente contagioso",
    toggle_infected = "Attiva o disattiva icone infetti",
    create_patient = "Crea paziente",
    end_month = "Fine mese",
    end_year = "Fine anno",
    lose_level = "Perdi livello",
    win_level = "Vinci livello",
    increase_prices = "Aumenta prezzi",
    decrease_prices = "Diminuisci prezzi",
    toggle_earthquake = "Attiva/Disattiva terremoti",
    reset_death_count = "Azzera il conto dei decessi",
    max_reputation = "Reputazione Massima",
    toggle_epidemic = "Attiva/Disattiva epidemie",
    show_infected = "Mostra/Nascondi icone infezione",
  },
  close = "Chiudi",
}

tooltip.cheats_window = {
  close = "Chiudi il menu dei trucchi",
  cheats = {
    money = "Aggiunge 10.000 al tuo conto in banca.",
    all_research = "Completa tutte le ricerche.",
    emergency = "Crea un'emergenza.",
    vip = "Crea un VIP.",
    earthquake = "Crea un terremoto.",
    epidemic = "Crea un paziente contagioso che potrebbe causare un'epidemia",
    toggle_infected = "Attiva o disattiva le icone infetti per le epidemie attive scoperte",
    create_patient = "Crea un paziente sul bordo della mappa.",
    end_month = "Salta alla fine del mese.",
    end_year = "Salta alla fine dell'anno.",
    lose_level = "Perdi il livello corrente.",
    win_level = "Vinci il livello corrente.",
    increase_prices = "Aumenta tutti i prezzi del 50% (max 200%)",
    decrease_prices = "Diminuisci tutti i prezzi del 50% (min 50%)",
    toggle_earthquake = "Attiva/Disattiva terremoti",
    reset_death_count = "Azzerare il conteggio dei decessi in ospedale",
    max_reputation = "Imposta la reputazione dell'ospedale al massimo",
    toggle_epidemic = "Attiva/Disattiva la possibilità di epidemie",
    show_infected = "Mostra/nascondi le icone infezione per l'epidemia attiva e scoperta",
  }
}

introduction_texts = {
  demo =
    "Benvenuto nell'ospedale demo!//" ..
    "Sfortunatamente la versione demo contiene solo questo livello. Ad ogni modo c'è abbastanza da fare per tenerti occupato per un bel po'! " ..
    "Incontrerai diverse malattie che richiederanno diverse cliniche per essere curate. Ogni tanto potrebbero presentarsi delle emergenze. " ..
    "E avrai bisogno di ricercare nuove strumentazioni tramite il centro ricerche. " ..
    "Il tuo obiettivo è di guadagnare $100,000, avere un ospedale che valga $70,000 e una reputazione di 700, oltre che curare almeno il 75% dei tuoi pazienti. " ..
    "Assicurati che la tua reputazione non scenda al di sotto di 300 e di non uccidere più del 40% dei tuoi pazienti, o perderai.//" ..
    "Buona fortuna!",
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

update_window = {
  caption = "Aggiornamento disponibile!",
  new_version = "Nuova versione:",
  current_version = "Versione attuale:",
  download = "Vai alla pagina del download",
  ignore = "Salta e vai al menù principale",
}

tooltip.update_window = {
  download = "Vai alla pagina di download per trovare l'ultima versione di CorsixTH",
  ignore = "Ignora l'aggiornamento per ora. Questa notifica apparirà di nuovo al prossimo avvio di CorsixTH",
}

map_editor_window = {
  pages = {
    inside = "Interno",
    outside = "Esterno",
    foliage = "Fogliame",
    hedgerow = "Siepe",
    pond = "Laghetto",
    road = "Strada",
    north_wall = "Muro nord",
    west_wall = "Muro ovest",
    helipad = "Eliporto",
    delete_wall = "Cancella muri",
    parcel = "Pacco %d",
    set_parcel = "Imposta num pacco",
    set_parcel_tooltip = "Scegli un numero e premi Invio.",
    camera_1 = "Telecamera 1",
    camera_2 = "Telecamera 2",
    camera_3 = "Telecamera 3",
    camera_4 = "Telecamera 4",
    heliport_1 = "Eliporto 1",
    heliport_2 = "Eliporto 2",
    heliport_3 = "Eliporto 3",
    heliport_4 = "Eliporto 4",
    paste = "Incolla area",
  },
  checks = {
    spawn_points_and_path = "Avvertenza: i pazienti non possono raggiungere l'ospedale. Hanno bisogno di caselle 'strada' o caselle grigie 'esterne' sul bordo della mappa e di un percorso fino all'ingresso dell'ospedale.",
  },
}

tooltip = {
  hotkey_window = {
    button_accept = "Accetta e salva i tasti scorciatoia",
    button_cancel = "Cancella l'assegnazione e torna al menu opzioni",
    button_recallPosKeys = "Apri una finestra per impostare scorciatoie per salvare e richiamare posizioni della telecamera",
    caption_panels = "Open window to assign panel keys",
    button_back_02 = "Torna alla finestra principale delle scorciatoie. Cio' che hai cambiato in questa finestra può essere salvato li'",
    button_defaults = "Ripristina tutte le scorciatoie alle impostazioni predefinite del programma",
    button_gameSpeedKeys = "Apri la finestra per impostare i tasti che controllano la velocità del gioco",
  }
}

level_progress = {
  cured_enough_patients = "Hai curato abbastanza pazienti, ma devi migliorare ancora il tuo ospedale per vincere il livello.",
  hospital_value_enough = "Mantieni il valore del tuo ospedale al di sopra di %d e occupati dei tuoi altri problemi per vincere il livello.",
}

disease_discovered_patient_choice.need_to_employ = "Assumi un %s per poter gestire questa sitazione."

transactions.remove_room = "Costruzione: rimuovi stanza distrutta"

multiplayer.everyone_failed = "Nessuno è riuscito ad arrivare a duell'ultimo obiettivo. Quindi tutti possono continuare a giocare!"
multiplayer.players_failed = "I seguenti giocatori non sono riusciti a raggiungere l'ultimo obiettivo:"


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
