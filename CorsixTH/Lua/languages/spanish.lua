--[[ Copyright (c) 2010 Víctor González a.k.a. "mccunyao"

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

Language("Castellano", "Spanish", "es", "spa", "esp", "sp")
Inherit("english")
Inherit("original_strings", 4)

-------------------------------  OVERRIDE  ----------------------------------
adviser.warnings.money_low = "Te estás quedando sin dinero."
tooltip.graphs.reputation = "Cambiar reputación"
tooltip.status.close = "Cerrar pantalla de estado"

-- tooltip.staff_list.next_person, prev_person is rather next/prev page (also in german, maybe more languages?)
tooltip.staff_list.next_person = "Mostrar la página siguiente"
tooltip.staff_list.prev_person = "Mostrar la página anterior"
tooltip.status.reputation = "Tu reputación no debe estar por debajo de %d. Actualmente tienes %d"
tooltip.status.balance = "No debes tener menos de %d $ en el banco. Actualmente tienes %d"

-- Improve tooltips in staff window to mention hidden features
tooltip.staff_window.face = "Rostro de la persona - pulsa para abrir pantalla de recursos."
tooltip.staff_window.center_view = "Botón izquierdo para fijarse en la persona, botón derecho para rotar entre los miembros del personal."

-- These strings are missing in some versions of TH (unpatched?)
confirmation.restart_level = "¿Seguro que quieres reiniciar el nivel?"
-- TODO adviser.multiplayer.objective_completed
-- TODO adviser.multiplayer.objective_failed

fax.vip_visit_result.remarks.mediocre[2] = "¡Oh, cielos! No es un lugar agradable para ir si estás pachucho."
fax.vip_visit_result.remarks.mediocre[3] = "Si le soy sincero, es un hospital normalucho. Francamente, yo esperaba más."
fax.vip_visit_result.remarks.very_bad[1] = "¡Vaya tugurio! Voy a intentar clausurarlo."
introduction_texts.level1[7] = "Tendrás que curar a 10 personas y asegurarte de que tu reputación no sea inferior a 200."
fax.emergency.num_disease = "Hay %d personas con %s y necesitan ser atendidas inmediatamente."

tooltip.handyman_window.close = "Cerrar ventana"
tooltip.machine_window.close = "Cerrar ventana"
tooltip.queue_window.close = "Cerrar ventana"
tooltip.jukebox.rewind = "Rebobinar reproductor de música"
tooltip.jukebox.loop = "El reproductor de música funciona continuamente"
tooltip.jukebox.stop = "Parar reproductor de música"
tooltip.jukebox.close = "Cerrar reproductor de música"
tooltip.jukebox.current_title = "Reproductor de música"
tooltip.jukebox.play = "Encender reproductor de música"
tooltip.jukebox.fast_forward = "Avance rápido del reproductor de música"
tooltip.patient_window.close = "Cerrar ventana"
tooltip.staff_window.close = "Cerrar ventana"
tooltip.build_room_window.close = "Salir de esta ventana y volver al juego"

misc.hospital_open = "Hospital abierto"
misc.save_success = "Partida guardada correctamente"
misc.save_failed = "ERROR: No se ha podido guardar la partida"
misc.out_of_sync = "Partida desincronizada"

-- Some overrides as original texts were too long see issue 1355 MarkL
high_score = {
  categories = {
    deaths = "FALLECIMIENTOS",
    total_value = "VALOR TOTAL",
    money = "RIQUEZA",
    cures = "CURACIONES",
    visitors = "VISITANTES",
    staff_number = "PLANTILLA",
    cure_death_ratio = "PROPORCION",
    patient_happiness = "CLIENTES CONTENTOS",
    staff_happiness = "PERSONAL CONTENTO",
    salary = "SUELDO MAS ALTO",
    clean = "LIMPIEZA",
  },
  player = "JUGADOR",
  score = "PUNTOS",
  pos = "POS",
  best_scores = "TABLA DEL HONOR",
  worst_scores = "TABLA DE LA VERGUENZA",
  killed = "Muerto"
}

--String text gets outside of window
confirmation.quit = "¿Seguro que quieres salir del juego?                       "

--Typos found on the official Spanish translation
tooltip.rooms.dna_fixer = "El médico usa el Reparador de ADN para curar a los pacientes con ADN alienígena"
diseases.broken_heart.cause = "Causa - alguien más rico, más joven y más delgado que el paciente."
fax.vip_visit_result.remarks.very_bad = "Estoy horrorizado. ¡Y a esto lo llama un hospital! Me voy de cañas..."
fax.emergency.locations[1] = "Planta química González"
fax.emergency.locations[3] = "Centro de plantas acuáticas"
fax.emergency.locations[5] = "Congreso de bailarines rusos"
fax.emergency.locations[8] = "La casa del curry"
fax.emergency.locations[9] = "Emporio petroquímico usado Díaz y Díaz"
fax.epidemic.cover_up_explanation_2 = "Si un inspector sanitario te visita y encuentra una epidemia encubierta tomará medidas drásticas en tu contra."
fax.epidemic.disease_name = "Tus médicos han descubierto una variedad contagiosa de %s."

-- An override for the squits becoming the the squits see issue 1646
adviser.research.drug_improved_1 = "Tu Departamento de Investigación ha mejorado el medicamento para la %s."
-------------------------------  NEW STRINGS  -------------------------------
date_format = {
  daymonth = "%1% %2:months%",
}

object.litter = "Basura"
tooltip.objects.litter = "Basura: Un paciente la ha tirado porque no ha encontrado una papelera."

tooltip.fax.close = "Cierra esta ventana sin borrar el mensaje."
tooltip.message.button = "Haz clic izquierdo para abrir el mensaje."
tooltip.message.button_dismiss = "Haz clic izquierdo para abrir el mensaje, clic derecho para rechazarlo."
tooltip.casebook.cure_requirement.hire_staff = "Necesitas contratar empleados para realizar este tratamiento."
tooltip.casebook.cure_type.unknown = "Todavía no sabes cómo curar esta enfermedad."
tooltip.research_policy.no_research = "En este momento no se está investigando ningún apartado de esta categoría."
tooltip.research_policy.research_progress = "Progreso para terminar el siguiente descubrimiento de esta categoría: %1%/%2%"

menu_file = {
  load =    " (MAYUS+L) CARGAR   ",
  save =    " (MAYUS+S) GUARDAR   ",
  restart = " (MAYUS+R) REINICIAR",
  quit =    " (MAYUS+Q) SALIR   "
}

menu_options = {
  sound = "  (ALT+S)  SONIDO  ",
  announcements = "  (ALT+A)  ANUNCIOS  ",
  music = "  (ALT+M)  MúSICA  ",
  jukebox = "  (J) REPRODUCTOR DE MúSICA  ",
  lock_windows = "  BLOQUEAR VENTANAS  ",
  edge_scrolling = "  DESPLAZAR POR BORDES  ",
  adviser_disabled = "  (MAYUS+A) CONSEJERO  ",
  warmth_colors = "  COLORES DE TEMPERATURA  ",
  wage_increase = "  PETICIONES DE SUELDO  ",
  twentyfour_hour_clock = "  RELOJ DE 24 HORAS  "
}

menu_options_game_speed = {
  pause               = "  (P) PAUSA  ",
  slowest             = "  (1) MUY LENTA  ",
  slower              = "  (2) LENTA  ",
  normal              = "  (3) NORMAL  ",
  max_speed           = "  (4) VELOCIDAD MáXIMA  ",
  and_then_some_more  = "  (5) VELOCIDAD ABSURDA  ",
}

menu_options_warmth_colors = {
  choice_1 = "  ROJO  ",
  choice_2 = "  AZUL, VERDE, ROJO  ",
  choice_3 = "  AMARILLO, NARANJA, ROJO  ",
}

menu_options_wage_increase = {
  grant = "    CONCEDER ",
  deny =  "    RECHAZAR ",
}

-- Add F-keys to entries in charts menu (except briefing), also town_map was added.
menu_charts = {
  bank_manager  = "  (F1) DIRECTOR DEL BANCO  ",
  statement     = "  (F2) ESTADO DE CUENTAS  ",
  staff_listing = "  (F3) LISTA DE PERSONAL  ",
  town_map      = "  (F4) MAPA DE LA CIUDAD  ",
  casebook      = "  (F5) HISTORIAL  ",
  research      = "  (F6) INVESTIGACIóN  ",
  status        = "  (F7) ESTADO  ",
  graphs        = "  (F8) GRáFICAS  ",
  policy        = "  (F9) NORMAS  ",
}

menu_debug = {
  jump_to_level               = "  CAMBIAR DE NIVEL  ",
  transparent_walls           = "  (X) PAREDES TRANSPARENTES  ",
  limit_camera                = "  LIMITAR CáMARA  ",
  disable_salary_raise        = "  DESACTIVAR SUBIDA DE SUELDO  ",
  make_debug_fax              = "  CREAR FAX DE DEPURACIóN  ",
  make_debug_patient          = "  CREAR PACIENTE DE DEPURACIóN  ",
  cheats                      = "  (F11) TRUCOS  ",
  lua_console                 = "  (F12) CONSOLA LUA  ",
  calls_dispatcher            = "  LLAMAR A CONTROLADOR  ",
  dump_strings                = "  VOLCAR TEXTOS DEL JUEGO  ",
  dump_gamelog                = "  (CTRL+D) VOLCAR REGISTRO DEL JUEGO  ",
  map_overlay                 = "  SOBREPONER MAPA  ",
  sprite_viewer               = "  VISUALIZADOR DE ANIMACIONES  ",
}
menu_debug_overlay = {
  none                        = "  NADA  ",
  flags                       = "  MARCAS  ",
  positions                   = "  POSICIONES  ",
  heat                        = "  TEMPERATURA  ",
  byte_0_1                    = "  BYTE 0 Y 1  ",
  byte_floor                  = "  BYTE SUELO  ",
  byte_n_wall                 = "  BYTE PARED NORTE  ",
  byte_w_wall                 = "  BYTE PARED OESTE  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  PARCELA  ",
}
adviser = {
  room_forbidden_non_reachable_parts = "Si colocas la habitación en este lugar, bloquearás el acceso a ciertas partes del hospital.",
  warnings = {
    no_desk = "¡Deberías construir una mesa de recepción y contratar a una recepcionista en algún momento!",
    no_desk_1 = "¡Si quieres que los pacientes vayan a tu hospital, necesitas contratar a una recepcionista y construir una mesa donde pueda trabajar!",
    no_desk_2 = "¡Enhorabuena, has batido un récord mundial: ha pasado un año y no ha aparecido ni un paciente! ¡Si quieres seguir mandando en este hospital, tendrás que contratar a una recepcionista y construir una mesa donde pueda trabajar!",
    no_desk_3 = "¡Fabuloso, casi ha pasado un año y no tienes recepcionistas! ¿Cómo quieres que vengan los pacientes? ¡Arréglalo y deja de perder el tiempo!",
    no_desk_4 = "Una recepcionista necesita una mesa para atender a los pacientes que vengan.",
    no_desk_5 = "¡Ya era hora! Los pacientes empezarán a llegar pronto.",
    no_desk_6 = "Tienes una recepcionista, ¿qué tal si construyes una mesa de recepción para que pueda trabajar?",
    no_desk_7 = "Has construido una mesa de recepción, ¿y si contratas a una recepcionista? No verás a ningún paciente hasta que lo arregles, ¿lo sabes, no?",
    cannot_afford = "¡No tienes dinero para contratar a esa persona!", -- I can't see anything like this in the original strings
    cannot_afford_2 = "¡No tienes dinero para comprar eso!",
    falling_1 = "¡Eh! No tiene gracia. Mira dónde haces clic con ese ratón, ¡vas a hacer daño a alguien!",
    falling_2 = "¿Te importaría dejar de perder el tiempo?",
    falling_3 = "¡Ay! Eso ha tenido que doler. ¡Llamen a un médico!",
    falling_4 = "¡Esto es un hospital, no un parque de atracciones!",
    falling_5 = "¡Este no es lugar para tirar personas al suelo, que están enfermas!",
    falling_6 = "¡Esto no es una bolera, no trates así a los enfermos!",
    research_screen_open_1 = "Para acceder a la pantalla de investigación, tienes que construir un Departamento de Investigación.",
    research_screen_open_2 = "No se pueden realizar investigaciones en este nivel.",
    researcher_needs_desk_1 = "Un investigador necesita una mesa en la que trabajar.",
    researcher_needs_desk_2 = "Tu investigador agradece que le hayas dado un descanso. Si pretendías tener a más personas investigando, tienes que dar a cada uno una mesa para que trabajen.",
    researcher_needs_desk_3 = "Cada investigador necesita una mesa para trabajar.",
    nurse_needs_desk_1 = "Cada enfermera necesita una mesa para trabajar.",
    nurse_needs_desk_2 = "Tu enfermera agradece que le hayas dado un descanso. Si pretendías tener a más personas trabajando en la enfermería, tienes que dar a cada una una mesa para que trabajen.",
  },
  cheats = {
    th_cheat = "¡Felicidades, has desbloqueado los trucos!",
    roujin_on_cheat = "¡Desafío de Roujin activado! Buena suerte...",
    roujin_off_cheat = "Desafío de Roujin desactivado.",
  },
}

dynamic_info.patient.actions.no_gp_available = "Esperando a que construyas una consulta"
dynamic_info.staff.actions.heading_for = "Dirigiéndose a %s"
dynamic_info.staff.actions.fired = "Despedido"

progress_report.free_build = "CONSTRUCCIÓN LIBRE"

fax = {
  choices = {
    return_to_main_menu = "Volver al menú principal",
    accept_new_level = "Continuar al siguiente nivel",
    decline_new_level = "Seguir jugando un poco más",
  },
  emergency = {
    num_disease_singular = "Hay 1 persona con %s y necesita ser atendida inmediatamente.",
    free_build = "Si tienes éxito, mejorarás tu reputación, pero si fracasas tu reputación caerá en picado.",
  },
  vip_visit_result = {
    remarks = {
      free_build = {
        "¡Tienes un muy buen hospital! No es difícil mantenerlo sin limitaciones económicas, ¿eh?",
        "No soy economista, pero hasta yo podría dirigir este hospital, si me entiendes...",
        "Un hospital muy bien cuidado. ¡Pero ojo con la crisis financiera! Ah... que no tienes que preocuparte de eso.",
      }
    }
  }
}

letter = {
  dear_player = "Estimado %s,",
  custom_level_completed = "¡Bien hecho! ¡Has completado todos los objetivos de este nivel personalizado!",
  return_to_main_menu = "¿Quieres volver al menú principal o seguir jugando?",
}

install = {
  title = "--------------------------------- Configuración de CorsixTH ---------------------------------",
  th_directory = "CorsixTH necesita una copia de los archivos de datos del Theme Hospital original (o de la demo) para poder funcionar. Utiliza el selector de debajo para localizar la carpeta de instalación de Theme Hospital.",
  ok = "Aceptar",
  exit = "Salir",
  cancel = "Cancelar",
}

misc.not_yet_implemented = "(aún no implementado)"
misc.no_heliport = "O no se han descubierto enfermedades, o no hay un helipuerto en este nivel.  Quizás necesitas comprar una mesa de recepción y contratar a una recepcionista."

main_menu = {
  new_game = "Campaña",
  custom_level = "Misión individual",
  load_game = "Cargar partida",
  options = "Opciones",
  savegame_version = "Versión del guardado: ",
  version = "Versión: ",
  exit = "Salir",
}

tooltip.main_menu = {
  new_game = "Empezar el primer nivel de la campaña.",
  custom_level = "Construir tu hospital en un nivel concreto.",
  load_game = "Cargar una partida guardada.",
  options = "Ajustar la configuración.",
  exit = "¡No, no, por favor, no te vayas!",
  quit = "Estás a punto de salir de CorsixTH.   ¿Seguro que quieres continuar?",
}

load_game_window = {
  caption = "Cargar partida (%1%)",
}

tooltip.load_game_window = {
  load_game = "Cargar partida %s",
  load_game_number = "Cargar partida %d",
  load_autosave = "Cargar autoguardado",
}

custom_game_window = {
  caption = "Partida personalizada",
  free_build = "Construcción libre",
}

tooltip.custom_game_window = {
  start_game_with_name = "Información de este escenario, que utiliza: %s           Informe: %s",
  free_build = "Marca esta casilla si quieres jugar sin dinero ni condiciones para ganar o perder.",
}

save_game_window = {
  caption = "Guardar partida (%1%)",
  new_save_game = "Nueva partida guardada",
}

tooltip.save_game_window = {
  save_game = "Sobrescribir guardado %s",
  new_save_game = "Introduce el nombre de la nueva partida guardada",
}

menu_list_window = {
  name = "Nombre",
  save_date = "Modificado",
  back = "Volver",
}

tooltip.menu_list_window = {
  name = "Pulsa aquí para ordenar la lista por nombres.",
  save_date = "Pulsa aquí para ordenar la lista por la última fecha de modificación.",
  back = "Cerrar esta ventana.",
}

options_window = {
  caption = "Opciones",
  option_on = "Sí",
  option_off = "No",
  fullscreen = "Pantalla completa",
  resolution = "Resolución",
  custom_resolution = "Personalizada...",
  width = "Ancho",
  height = "Alto",
  audio = "Sonido",
  customise = "Personalizar",
  folder = "Carpetas",
  language = "Idioma del juego",
  apply = "Aplicar",
  cancel = "Cancelar",
  back = "Volver",
}

tooltip.options_window = {
  fullscreen = "Hace que el juego se ejecute en pantalla completa o en una ventana.",
  fullscreen_button = "Pulsa aquí para activar el modo de pantalla completa.",
  resolution = "Cambia la resolución en la que funcionará el juego.",
  select_resolution = "Selecciona una nueva resolución.",
  width = "Introduce el ancho de la pantalla.",
  height = "Introduce la altura de la pantalla.",
  apply = "Aplica la resolución seleccionada.",
  cancel = "Vuelve sin cambiar la resolución.",
  audio_button = "Activa o desactiva todos los sonidos del juego.",
  audio_toggle = "Activar o desactivar",
  customise_button = "Más opciones para personalizar tu experiencia de juego.",
  folder_button = "Opciones de carpeta",
  language = "Selecciona el idioma de los textos.",
  select_language = "Selecciona el idioma del juego.",
  language_dropdown_item = "Utilizar el idioma %s.",
  back = "Cierra la ventana de opciones.",
}

customise_window = {
  caption = "Opciones personalizadas",
  option_on = "Activado",
  option_off = "Desactivado",
  back = "Volver",
  movies = "Control global de vídeos",
  intro = "Reproducir introducción",
  paused = "Construir durante una pausa",
  volume = "Tecla para bajar el volumen",
  aliens = "Pacientes alienígenas",
  fractured_bones = "Fracturas óseas",
  average_contents = "Contenidos normales",
}

tooltip.customise_window = {
  movies = "Control global de vídeos, esto permite desactivar todos los vídeos.",
  intro = "Activa o desactiva el vídeo de introducción, necesitas tener activado el control global de vídeos si quieres ver la introducción cada vez que arranques CorsixTH.",
  paused = "En Theme Hospital, el jugador solo podía utilizar el menú superior si la partida estaba en pausa. Esto también se hace en CorsixTH de forma predeterminada, pero al activar esta opción, podrás acceder a ese menú mientras el juego esté en pausa.",
  volume = "Si la tecla de bajar volumen abre también el botiquín, utiliza esta opción para cambiar el acceso directo a Mayúsculas + C.",
  aliens = "Debido a la falta de animaciones decentes disponibles, hemos hecho que los pacientes con ADN alienígena solo aparezcan en una emergencia. Para permitir que los pacientes con ADN alienígena puedan visitar tu hospital, desactiva esta opción.",
  fractured_bones = "Debido a una animación deficiente, hemos hecho que no existan pacientes con Fracturas óseas femeninas. Para permitir que las pacientes con Fracturas óseas visiten tu hospital, desactiva esta opción.",
  average_contents = "Activa esta opción si quieres que el juego recuerde que objetos adicionales sueles añadir cuando construyes habitaciones.",
  back = "Cerrar este menú y volver al menú de Opciones",
}

folders_window = {
  caption = "Ubicación de carpetas",
  data_label = "Datos de TH",
  font_label = "Fuente",
  music_label = "MP3s",
  savegames_label = "Partidas guardadas",
  screenshots_label = "Capturas de pantalla",
  -- next four are the captions for the browser window, which are called from the folder setting menu
  new_th_location = "Aquí puedes especificar una nueva carpeta de instalación de Theme Hospital. El juego se reiniciará en cuanto selecciones la nueva carpeta.",
  savegames_location = "Selecciona la carpeta que quieres utilizar para tus partidas guardadas.",
  music_location = "Selecciona la carpeta que quieres utilizar para tu música.",
  screenshots_location = "Selecciona la carpeta que quieres utilizar para tus capturas de pantalla.",
  back  = "Volver",
}

tooltip.folders_window = {
  browse = "Buscar la ubicación de la carpeta",
  data_location = "La carpeta con la instalación del Theme Hospital original, necesario para ejecutar CorsixTH.",
  font_location = "La ubicación de una fuente de letra capaz de mostrar caracteres Unicode necesarios para tu idioma. Si no se indica, no podrás seleccionar idiomas que tengan más caracteres de los que puede dar el juego original, por ejemplo, ruso y chino.",
  savegames_location = "La carpeta de partidas guardadas está junto al archivo de configuración de forma predeterminada, y se utilizará para almacenar las partidas guardadas. En caso de que no sea lo más adecuado, puedes seleccionar otra carpeta buscando la carpeta que quieres usar.",
  screenshots_location = "Las capturas de pantalla se guardan de forma predeterminada en una carpeta junto al archivo de configuración. En caso de que no sea lo más adecuado, puedes seleccionar otra carpeta buscando la carpeta que quieres usar.",
  music_location = "Selecciona una carpeta con tus archivos de música en formato MP3. Necesitas una carpeta ya existente, entonces podrás buscarla.",
  browse_data = "Buscar otra ubicación con una instalación de Theme Hospital. (Ubicación actual: %1%)",
  browse_font = "Buscar otro archivo de fuente de letra. (Ubicación actual: %1%)",
  browse_saves = "Buscar otra ubicación para tu carpeta de partidas guardadas. (Ubicación actual: %1%)",
  browse_screenshots = "Buscar otra ubicación para tu carpeta de capturas de pantalla. (Ubicación actual: %1%)",
  browse_music = "Buscar otra ubicación para tu carpeta de música. (Ubicación actual: %1%)",
  no_font_specified = "¡Aún no has especificado la ubicación de la fuente!",
  not_specified = "¡Aún no has especificado una carpeta!",
  default = "Ubicación predeterminada",
  reset_to_default = "Vuelve a asignar la carpeta a su ubicación predeterminada.",
 -- original_path = "Carpeta actual con la instalación del Theme Hospital original", -- where is this used, I have left if for the time being?
  back  = "Cerrar este menú y volver al menú de Opciones.",
}

font_location_window = {
  caption = "Seleccionar fuente (%1%)",
}

handyman_window = {
  all_parcels = "Todas las parcelas",
  parcel = "Parcela"
}

tooltip.handyman_window = {
  parcel_select = "Parcela donde el bedel acepta encargos, haz clic para cambiar el ajuste"
}

new_game_window = {
  caption = "Campaña",
  player_name = "Nombre",
  option_on = "Activada",
  option_off = "Desactivada",
  difficulty = "Dificultad",
  easy = "Novato (Fácil)",
  medium = "Médico (Normal)",
  hard = "Especialista (Difícil)",
  tutorial = "Tutorial",
  start = "Comenzar",
  cancel = "Cancelar",
}

tooltip.new_game_window = {
  player_name = "Introduce el nombre con el que te llamará el juego.",
  difficulty = "Selecciona el nivel de dificultad con el que quieres jugar.",
  easy = "Si acabas de conocer los juegos de simulación, esta dificultad es para ti.",
  medium = "Esta es la dificultad intermedia, si no estás seguro de a dónde quieres ir.",
  hard = "Si ya estás acostumbrado a este tipo de juegos y quieres un buen desafío, aquí lo tendrás.",
  tutorial = "Selecciona esta casilla si necesitas ayuda para empezar a jugar.",
  start = "Empezar la partida con la configuración seleccionada.",
  cancel = "¡Perdón, yo no quería empezar una nueva partida!",
}

lua_console = {
  execute_code = "Ejecutar",
  close = "Cerrar",
}

tooltip.lua_console = {
  textbox = "Introduce aquí el código Lua que quieres ejecutar",
  execute_code = "Ejecutar el códugo Lua que has introducido",
  close = "Cerrar la consola",
}

errors = {
  dialog_missing_graphics = "Los archivos de datos de la demo no contienen esta ventana.",
  save_prefix = "Error al guardar la partida: ",
  load_prefix = "Error al cargar la partida: ",
  load_quick_save = "Error, no existe el guardado rápido y por tanto no se puede cargar, pero tranquilo, que acabamos de generar uno para ti.",
  map_file_missing = "¡No se ha podido encontrar el archivo de mapa %s de este nivel!",
  minimum_screen_size = "Introduce un tamaño de pantalla como mínimo de 640x480.",
  unavailable_screen_size = "El tamaño de pantalla que has seleccionado no está disponible en el modo de pantalla completa.",
  alien_dna = "NOTA: Los pacientes alienígenas no tienen animaciones para sentarse, abrir puertas, llamar a puertas, etc. Por lo tanto, al igual que en Theme Hospital, para hacer estas cosas aparentarán cambiar a una imagen normal y luego volverán a su estado.  Los pacientes con ADN alienígena solo aparecerán si el archivo del nivel lo indica.",
  fractured_bones = "NOTA: La animación de las pacientes femeninas con Fracturas óseas no es perfecta.",
}

confirmation = {
  needs_restart = "Para cambiar este ajuste, antes debes reiniciar CorsixTH. Se perderá todo el progreso que no hayas guardado. ¿Seguro que quieres continuar?",
  abort_edit_room = "Ahora mismo estás construyendo o editando una habitación. Si has colocado todos los objetos necesarios será terminada, de lo contrario se borrará. ¿Quieres continuar?",
  maximum_screen_size = "El tamaño de pantalla que has introducido es mayor que 3000 x 2000.  Es posible utilizar una resolución más grande, pero necesitará de un ordenador mejor para que la velocidad de fotogramas sea aceptable. ¿Seguro que quieres continuar?",
  music_warning = "Antes de seleccionar el uso de MP3s para tu música dentro del juego, necesitarás tener el archivo smpeg.dll, o el equivalente para tu sistema operativo, o de lo contrario no tendrás música en el juego.  Actualmente no existe un archivo equivalente para sistemas de 64 bits. ¿Quieres continuar?",
}

information = {
  custom_game = "Bienvenido a CorsixTH. ¡Diviértete con este mapa personalizado!",
  no_custom_game_in_demo = "La versión demo no permite jugar a mapas personalizados.",
  cannot_restart = "Esta partida personalizada se guardó antes de que se implementara la característica de reiniciar.",
  very_old_save = "Desde que empezaste a jugar en este nivel, el juego ha recibido muchas actualizaciones. Para asegurarte de que todas las características funcionen como es debido, considera empezarlo de nuevo.",
  level_lost = {
    "¡Qué pena! Has fracasado en este nivel. ¡Mejor suerte la próxima vez!",
    "La razón por la que has perdido es:",
    reputation = "Tu reputación ha caído por debajo de %d.",
    balance = "Tu cuenta bancaria ha llegado a tener menos de %d.",
    percentage_killed = "Has matado a más de un %d por ciento de los pacientes.",
    cheat = "¿Lo has elegido tú o te has equivocado de botón? No sabes ni hacer trampas como es debido... ¿a que no tiene gracia?",
  },
  cheat_not_possible = "No puedes usar ese truco en este nivel. No sabes ni hacer trampas, ¿a que no tiene gracia?",
}

tooltip.information = {
  close = "Cerrar la ventana de información",
}

totd_window = {
  tips = {
    "Todo hospital necesita una mesa de recepción y una consulta para empezar a funcionar. Después de eso, depende del tipo de pacientes que visite tu hospital. Eso sí, una farmacia siempre es una buena opción.",
    "Las máquinas como el inflador necesitan mantenimiento. Utiliza a un bedel o dos para reparar tus máquinas, o te arriesgarás a herir a tus pacientes y a tu personal.",
    "Tras un tiempo, tu personal se cansará. Asegúrate de construir una sala de personal, para que puedan relajarse.",
    "Coloca varios radiadores para mantener calentitos a tu personal y empleados, o se enfadarán. Usa el mapa superior para buscar los puntos de tu hospital que no tengan calefacción.",
    "El nivel de habilidad de un doctor influye significativamente la calidad y la velocidad de sus diagnósticos. Coloca a un doctor habilidoso en tu consulta, y no necesitarás tantas salas de diagnóstico adicionales.",
    "Los doctores pueden mejorar sus habilidades aprendiendo de un asesor en la sala de entrenamiento. Si el asesor tiene una calificación especial (cirujano, psiquiatra o investigador), también pasará sus conocimientos a sus pupilos.",
    "¿Has probado a meter el número de emergencias (112) en el fax? ¡Asegúrate de tener el sonido activado!",
    "Puedes ajustar algunos parámetros como la resolución y el idioma del juego en la ventana de Opciones que encontrarás tanto en el menú principal como dentro del juego.",
    "¿Has seleccionado el Castellano, pero sigues viendo textos en inglés en algún lugar? ¡Ayúdanos avisando de las líneas de texto que estén en inglés para que podamos traducirlas!",
    "¡El equipo de CorsixTH busca refuerzos! ¿Te interesa programar, traducir o crear gráficos para CorsixTH? Contáctanos en nuestro foro, lista de correo o canal IRC (corsix-th en freenode).",
    "Si encuentras un fallo, infórmalo en nuestro registro de fallos: th-issues.corsix.org",
    "Cada nivel tiene unos requisitos concretos que debes conseguir antes de poder continuar al siguiente nivel. Mira en la ventana de estado para ver como llevas los objetivos del nivel.",
    "Si quieres editar o quitar una habitación ya existente, puedes hacerlo con el botón de Editar habitación que verás en la barra de herramientas inferior.",
    "Cuando tengas muchos pacientes esperando, puedes averiguar rápidamente quienes están esperando para una habitación en concreto pasando el cursor del ratón por encima de la habitación.",
    "Pulsa en la puerta de una habitación para ver su cola. Aquí puedes manipular ciertos aspectos, como reordenar la cola o mandar a un paciente hacia otra habitación.",
    "El personal que no esté contento pedirá aumentos de sueldo con frecuencia. Asegúrate de que tu personal trabaja en un entorno cómodo para evitar que esto ocurra.",
    "Los pacientes tendrán sed mientras esperan en tu hospital, ¡y aún más si subes la calefacción! Coloca máquinas de bebidas en lugares estratégicos para ganar un dinerillo extra.",
    "Puedes cancelar el progreso del diagnóstico de un paciente de forma prematura y adivinar la cura si ya has descubierto la enfermedad. Ten en cuenta que esto aumentará el riesgo de darle el tratamiento equivocado, lo que matará al paciente.",
    "Las emergencias pueden ser una buena forma de llevarte algo de dinero extra, siempre y cuando tengas la capacidad suficiente para ocuparte de los pacientes de la emergencia a tiempo.",
  },
  previous = "Siguiente consejo",
  next = "Consejo anterior",
}

tooltip.totd_window = {
  previous = "Mostrar el consejo anterior",
  next = "Mostrar el consejo siguiente",
}

debug_patient_window = {
  caption = "Paciente de depuración",
}

cheats_window = {
  caption = "Trucos",
  warning = "Advertencia: ¡No conseguirás bonificaciones al acabar este nivel si haces trampas!",
  cheated = {
    no = "Se han usado trucos: No",
    yes = "Se han usado trucos: Sí",
  },
  cheats = {
    money = "Truco de dinero",
    all_research = "Truco de todo investigado",
    emergency = "Crear una emergencia",
    vip = "Crear un VIP",
    earthquake = "Crear terremoto",
    create_patient = "Crear un paciente",
    end_month = "Fin de mes",
    end_year = "Fin del año",
    lose_level = "Perder el nivel",
    win_level = "Ganar el nivel",
  },
  close = "Cerrar",
}

tooltip.cheats_window = {
  close = "Cerrar la ventana de trucos",
  cheats = {
    money = "Añade 10.000 dólares a tu cuenta bancaria.",
    all_research = "Completa todas las investigaciones.",
    emergency = "Crea una emergencia.",
    vip = "Crea un VIP.",
    earthquake = "Crea un terremoto.",
    create_patient = "Crea un paciente en el borde del mapa.",
    end_month = "Avanza hasta el fin del mes actual.",
    end_year = "Avanza hasta el final del año actual.",
    lose_level = "Hace que pierdas el nivel actual.",
    win_level = "Hace que ganes el nivel actual.",
  }
}

introduction_texts = {
  demo = {
    "¡Bienvenido al hospital de demostración!",
    "Por desgracia, la versión de demostración solo contiene este nivel. Sin embargo, tienes más que suficiente para estar entretenido por un rato.",
    "Te enfrentarás a varias enfermedades que necesitan de ciertas habitaciones para su cura. De vez en cuando pueden surgir emergencias. Y necesitarás investigar sobre las enfermedades construyendo un Departamento de investigación.",
    "Tu objetivo es ganar 100.000 dólares, que el valor de tu hospital llegue hasta 70.000 dólares y tengas una reputación de 700, con un porcentaje de pacientes curados del 75%.",
    "Procura que tu reputación no caiga por debajo de 300 y que no mates a más del 40% de tus pacientes, o fracasarás.",
    "¡Buena suerte!",
  },
}

calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = "%d llamadas, %d asignadas",
  staff = "%s - %s",
  watering = "Regando @ %d,%d",
  repair = "Reparar %s",
  close = "Cerrar",
}

tooltip.calls_dispatcher = {
  task = "Lista de tareas - puslsa en una tarea para abrir la ventana del personal asignado y desplázate hasta la posición de la tarea.",
  assigned = "Esta opción está activada si alguien ha sido asignado a la tarea correspondiente.",
  close = "Cerrar la ventana de llamadas de control.",
}

update_window = {
  caption = "¡Actualización disponible!",
  new_version = "Versión nueva:",
  current_version = "Versión actual:",
  download = "Ir a la página de descargas",
  ignore = "Saltar e ir al menú principal",
}

tooltip.update_window = {
  download = "Ir a la página de descargas para obtener la última versión de CorsixTH.",
  ignore = "Ignorar esta actualización por el momento. Volverás a ser notificado la próxima vez que ejecutes CorsixTH.",
}

--------------------------------  UNUSED  -----------------------------------
------------------- (kept for backwards compatibility) ----------------------

options_window.change_resolution = "Cambiar resolución"
tooltip.options_window.change_resolution = "Cambia la resolución de la ventana utilizando la dimensión indicada a la izquierda."
