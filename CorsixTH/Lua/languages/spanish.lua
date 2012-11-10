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
misc.hospital_open = "Hospital abierto"
misc.save_success = "Partida guardada correctamente"
misc.save_failed = "ERROR: No se ha podido guardar la partida"

-- tooltip.staff_list.next_person, prev_person is rather next/prev page (also in german, maybe more languages?)
tooltip.staff_list.next_person = utf8 "Mostrar la página siguiente"
tooltip.staff_list.prev_person = utf8 "Mostrar la página anterior"
tooltip.status.reputation = utf8 "Tu reputación no debe estar por debajo de %d. Actualmente tienes %d"
tooltip.status.balance = utf8 "No debes tener menos de %d $ en el banco. Actualmente tienes %d"

fax.vip_visit_result.remarks.mediocre[2] = utf8 "¡Oh, cielos! No es un lugar agradable para ir si estás pachucho."
fax.vip_visit_result.remarks.mediocre[3] = utf8 "Si le soy sincero, es un hospital normalucho. Francamente, yo esperaba más."
fax.vip_visit_result.remarks.very_bad[1] = utf8 "¡Vaya tugurio! Voy a intentar clausurarlo."
introduction_texts.level1[7] = utf8 "Tendrás que curar a 10 personas y asegurarte de que tu reputación no sea inferior a 200. "
fax.emergency.num_disease = "Hay %d personas con %s y necesitan ser atendidas inmediatamente."

tooltip.handyman_window.close = "Cerrar ventana"
tooltip.machine_window.close = "Cerrar ventana"
tooltip.queue_window.close = "Cerrar ventana"
tooltip.jukebox.rewind = utf8 "Rebobinar reproductor de música"
tooltip.jukebox.loop = utf8 "El reproductor de música funciona continuamente"
tooltip.jukebox.stop = utf8 "Parar reproductor de música"
tooltip.jukebox.close = utf8 "Cerrar reproductor de música"
tooltip.jukebox.current_title = utf8 "Reproductor de música"
tooltip.jukebox.play = utf8 "Encender reproductor de música"
tooltip.jukebox.fast_forward = utf8 "Avance rápido del reproductor de música"
tooltip.patient_window.close = "Cerrar ventana"
tooltip.staff_window.close = "Cerrar ventana"
tooltip.build_room_window.close = "Salir de esta ventana y volver al juego"
menu_options.jukebox = utf8 "  REPRODUCTOR DE MúSICA  "

-- Improve tooltips in staff window to mention hidden features
tooltip.staff_window.face = "Rostro de la persona - pulsa para abrir pantalla de recursos."
tooltip.staff_window.center_view = utf8 "Botón izquierdo para fijarse en la persona, botón derecho para rotar entre los miembros del personal."

-- These strings are missing in some versions of TH (unpatched?)
confirmation.restart_level = utf8 "¿Seguro que quieres reiniciar el nivel?"
-- TODO adviser.multiplayer.objective_completed
-- TODO adviser.multiplayer.objective_failed

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
confirmation.quit = utf8 "¿Seguro que quieres salir del juego?                       "

-------------------------------  NEW STRINGS  -------------------------------
date_format = {
  daymonth = "%1% %2:months%",
}

object.litter = "Basura"
tooltip.objects.litter = utf8 "Basura: Tirada en el suelo por un paciente porque no ha encontrado una papelera donde tirarla."

tooltip.fax.close = "Cierra esta ventana sin borrar el mensaje."
tooltip.message.button = utf8 "Botón izquierdo del ratón para abrir el mensaje."
tooltip.message.button_dismiss = utf8 "Botón izquierdo para abrir el mensaje, botón derecho para rechazarlo."
tooltip.casebook.cure_requirement.hire_staff = utf8 "Necesitas contratar a empleados para realizar este tratamiento."
tooltip.casebook.cure_type.unknown = utf8 "Todavía no conoces la forma de curar esta enfermedad."
tooltip.research_policy.no_research = utf8 "En este momento no se está investigando ningún apartado de esta categoría."
tooltip.research_policy.research_progress = utf8 "Progreso para terminar el siguiente descubrimiento de esta categoría: %1%/%2%"

menu_options = {
  lock_windows = "  BLOQUEAR VENTANAS  ",
  edge_scrolling = "  DESPLAZAR POR BORDES  ",
  settings = utf8 "  CONFIGURACIóN  ",
  adviser_disabled = "  CONSEJERO  ",
}

menu_options_game_speed = {
  pause               = "  (P) PAUSA  ",
  slowest             = "  (1) MUY LENTA  ",
  slower              = "  (2) LENTA  ",
  normal              = "  (3) NORMAL  ",
  max_speed           = utf8 "  (4) VELOCIDAD MáXIMA  ",
  and_then_some_more  = "  (5) VELOCIDAD ABSURDA  ",
}

-- The demo does not contain this string
menu_file.restart = "  REINICIAR  "

menu_debug = {
  jump_to_level               = "  CAMBIAR DE NIVEL  ",
  transparent_walls           = "  (X) PAREDES TRANSPARENTES  ",
  limit_camera                = utf8 "  LIMITAR CáMARA  ",
  disable_salary_raise        = "  DESACTIVAR SUBIDA DE SUELDO  ",
  make_debug_fax              = utf8 "  (F8) CREAR FAX DE DEPURACIóN  ",
  make_debug_patient          = utf8 "  (F9) CREAR PACIENTE DE DEPURACIóN  ",
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
  flags                       = "  BANDERAS  ",
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
  room_forbidden_non_reachable_parts = utf8 "Si colocas la habitación en este lugar, bloquearás el acceso a ciertas partes del hospital.",
  warnings = {
    no_desk = utf8 "¡Deberías construir una mesa de recepción y contratar a una recepcionista en algún momento!",
    no_desk_1 = utf8 "¡Si quieres que los pacientes vayan a tu hospital, necesitas contratar a una recepcionista y construir una mesa donde pueda trabajar!",
    no_desk_2 = utf8 "¡Enhorabuena, has batido un récord mundial: ha pasado un año y no ha aparecido ni un paciente! ¡Si quieres seguir mandando en este hospital, tendrás que contratar a una recepcionista y construirla una mesa donde pueda trabajar!",
    no_desk_3 = utf8 "¡Fabuloso, casi ha pasado un año y no tienes personal de recepción! ¿Cómo quieres que vengan a ti los pacientes? ¡Arréglalo y deja de perder el tiempo!",
    cannot_afford = utf8 "¡No tienes dinero en el banco para contratar a esa persona!", -- I can't see anything like this in the original strings
    falling_1 = utf8 "¡Eh! Eso no tiene gracia. Mira dónde haces clic con ese ratón, ¡vas a hacerle daño a alguien!",
    falling_2 = utf8 "¿Te importaría dejar de perder el tiempo?",
    falling_3 = utf8 "¡Ay! Eso ha tenido que doler. ¡Llamen a un médico!",
    falling_4 = utf8 "¡Esto es un hospital, no un parque de atracciones!",
    falling_5 = utf8 "¡Este no es el lugar para tumbar a personas, que están enfermas!",
    falling_6 = utf8 "¡Esto no es una bolera, no deberías tratar así a los enfermos!",
    research_screen_open_1 = utf8 "Tienes que construir un Departamento de Investigación para poder acceder a la pantalla de investigación.",
    research_screen_open_2 = "No se pueden realizar investigaciones en este nivel.",
  },
  cheats = {
    th_cheat = utf8 "¡Felicidades, has desbloqueado los trucos!",
    crazy_on_cheat = utf8 "¡Oh, no! ¡Todos los médicos se han vuelto locos!",
    crazy_off_cheat = utf8 "Uf... los médicos han recuperado la cordura.",
    roujin_on_cheat = utf8 "¡Desafío de Roujin activado! Buena suerte...",
    roujin_off_cheat = utf8 "Desafío de Roujin desactivado.",
    hairyitis_cheat = utf8 "¡Truco de peludismo activado!",
    hairyitis_off_cheat = utf8 "Truco de peludismo desactivado.",
    bloaty_cheat = utf8 "¡Truco de cabezudos activado!",
    bloaty_off_cheat = utf8 "Truco de cabezudos desactivado.",
  },
}

dynamic_info.patient.actions.no_gp_available = utf8 "Esperando a que construyas una consulta"
dynamic_info.staff.actions.heading_for = utf8 "Dirigiéndose a %s"
dynamic_info.staff.actions.fired = "Despedido"

progress_report.free_build = utf8 "CONSTRUCCIÓN GRATUITA"

fax = {
  choices = {
    return_to_main_menu = utf8 "Volver al menú principal",
    accept_new_level = utf8 "Continuar al siguiente nivel",
    decline_new_level = utf8 "Seguir jugando un poco más",
  },
  emergency = {
    num_disease_singular = utf8 "Hay 1 persona que tiene %s y necesita atención inmediata.",
    free_build = utf8 "Si tienes éxito, mejorarás tu reputación, pero si fracasas tu reputación caerá en picado.",
  },
  vip_visit_result = {
    remarks = {
      free_build = {
        utf8 "¡Tienes un muy buen hospital! No es difícil mantenerlo sin limitaciones económicas, ¿eh?",
        utf8 "No soy economista, pero hasta yo podría dirigir este hospital, si me entiendes...",
        utf8 "Un hospital muy bien cuidado. ¡Pero ojo con la crisis financiera! Ah... que tú no tienes que preocuparte por eso.",
      }
    }
  }
}

letter = {
  dear_player = utf8 "Estimado %s",
  custom_level_completed = utf8 "¡Bien hecho! ¡Has completado todos los objetivos de este nivel personalizado!",
  return_to_main_menu = utf8 "¿Quieres volver al menú principal o seguir jugando?",
}

install = {
  title = utf8 "--------------------------------- Configuración de CorsixTH ---------------------------------",
  th_directory = utf8 "CorsixTH necesita una copia de los archivos de datos del Theme Hospital original (o de la demo) para poder funcionar. Utiliza el selector de debajo para localizar la carpeta de instalación de Theme Hospital.",
  exit = "Salir",
}

misc.not_yet_implemented = utf8 "(aún no implementado)"
misc.no_heliport = utf8 "O no se han descubierto enfermedades, o no hay un helipuerto en este nivel."

main_menu = {
  new_game = "Nueva partida",
  custom_level = "Nivel personalizado",
  load_game = "Cargar partida",
  options = "Opciones",
  savegame_version = utf8 "Versión del guardado: ",
  version = utf8 "Versión: ",
  exit = "Salir",
}

tooltip.main_menu = {
  new_game = utf8 "Empezar una partida completamente nueva desde el principio",
  custom_level = utf8 "Construir tu hospital en un nivel personalizado",
  load_game = utf8 "Cargar una partida guardada",
  options = utf8 "Ajustar la configuración",
  exit = utf8 "¡No, no, por favor, no te vayas!",
}

load_game_window = {
  caption = "Cargar partida",
}

tooltip.load_game_window = {
  load_game = "Cargar partida %s",
  load_game_number = "Cargar partida %d",
  load_autosave = "Cargar autoguardado",
}

custom_game_window = {
  caption = "Partida personalizada",
  free_build = utf8 "Construcción libre",
}

tooltip.custom_game_window = {
  start_game_with_name = "Cargar el nivel %s",
  free_build = "Marca esta casilla si quieres jugar sin condiciones para ganar, para perder y sin dinero",
}

save_game_window = {
  caption = "Guardar partida",
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
  name = utf8 "Pulsa aquí para ordenar la lista por el nombre",
  save_date = utf8 "Pulsa aquí para ordenar la lista por la última fecha de modificación",
  back = "Cerrar esta ventana",
}

options_window = {
  fullscreen = "Pantalla completa",
  width = "Ancho",
  height = "Alto",
  change_resolution = utf8 "Cambiar resolución",
  browse = "Buscar...",
  new_th_directory = utf8 "Aquí puedes especificar una nueva carpeta de instalación de Theme Hospital. En el momento en el que selecciones la nueva carpeta, el juego se reiniciará.",
  cancel = "Cancelar",
  back = "Volver",
}

tooltip.handyman_window = {
  parcel_select = "La parcela donde el bedel acepta encargos, haz clic para cambiar el ajuste"
}

handyman_window = {
  all_parcels = "Todas las parcelas",
  parcel = "Parcela"
}

tooltip.options_window = {
  fullscreen_button = utf8 "Pulsa para activar el modo de pantalla completa",
  width = utf8 "Introduce el ancho de pantalla deseado",
  height = utf8 "Introduce el alto de pantalla deseado",
  change_resolution = utf8 "Cambia la resolución de la ventana a las dimensiones indicadas a la izquierda",
  language = utf8 "Seleccionar el idioma %s",
  original_path = utf8 "La carpeta actualmente seleccionada con la instalación original de Theme Hospital",
  browse = utf8 "Buscar otra ubicación de una instalación de Theme Hospital",
  back = utf8 "Cerrar la ventana de opciones",
}

new_game_window = {
  easy = utf8 "Novato (Fácil)",
  medium = utf8 "Médico (Normal)",
  hard = utf8 "Especialista (Difícil)",
  tutorial = "Tutorial",
  cancel = "Cancelar",
}

tooltip.new_game_window = {
  easy = utf8 "Si acabas de conocer los juegos de simulación, esta dificultad es para ti.",
  medium = utf8 "Esta es la dificultad intermedia, si no estás seguro de a dónde quieres ir.",
  hard = utf8 "Si ya estás acostumbrado a este tipo de juegos y quieres un buen desafío, aquí lo tendrás.",
  tutorial = "Selecciona esta casilla si necesitas ayuda para empezar a jugar.",
  tutorial = "Tutorial",
  cancel = utf8 "¡Perdón, yo no quería empezar una nueva partida!",
}

lua_console = {
  execute_code = "Ejecutar",
  close = "Cerrar",
}

tooltip.lua_console = {
  textbox = utf8 "Introduce aquí el código Lua que quieres ejecutar",
  execute_code = utf8 "Ejecutar el códugo Lua que has introducido",
  close = "Cerrar la consola",
}

errors = {
  dialog_missing_graphics = utf8 "Los archivos de datos de la demo no contienen esta ventana.",
  save_prefix = utf8 "Error al guardar la partida: ",
  load_prefix = utf8 "Error al cargar la partida: ",
  map_file_missing = utf8 "¡No se ha podido encontrar el archivo de mapa %s de este nivel!",
  minimum_screen_size = utf8 "Introduce un tamaño de pantalla como mínimo de 640x480.",
  maximum_screen_size = utf8 "Introduce un tamaño de pantalla como máximo de 3000x2000.",
  unavailable_screen_size = utf8 "El tamaño de pantalla que has seleccionado no está disponible en el modo de pantalla completa.",
}

confirmation = {
  needs_restart = utf8 "Para cambiar este ajuste, antes debes reiniciar CorsixTHo. Se perderá todo el progreso que no hayas guardado. ¿Seguro que quieres continuar?",
  abort_edit_room = utf8 "Ahora mismo estás construyendo o editando una habitación. Si has colocado todos los objetos necesarios será terminada, de lo contrario se borrará. ¿Quieres continuar?",
}

information = {
  custom_game = utf8 "Bienvenido a CorsixTH. ¡Diviértete con este mapa personalizado!",
  no_custom_game_in_demo = utf8 "Lamentándolo mucho, la versión demo no permite jugar a mapas personalizados.",
  cannot_restart = utf8 "Por desgracia esta partida personalizada se guardó antes de que se implementara la característica de reiniciar.",
  very_old_save = utf8 "Desde que empezaste a jugar en este nivel, el juego ha recibido muchas actualizaciones. Para asegurarte de que todas las características funcionen como es debido, considera empezarlo de nuevo.",
  level_lost = {
    utf8 "¡Qué pena! Has fracasado en este nivel. ¡Mejor suerte la próxima vez!",
    utf8 "La razón por la que has perdido es:",
    reputation = utf8 "Tu reputación ha caído por debajo de %d.",
    balance = utf8 "Tu cuenta bancaria ha llegado a tener menos de %d.",
    percentage_killed = utf8 "Has matado a más de un %d por ciento de los pacientes.",
  },
  cheat_not_possible = utf8 "No puedes usar ese truco en este nivel. No sabes ni hacer trampas, ¿a que no tiene gracia?",
}

tooltip.information = {
  close = utf8 "Cerrar la ventana de información",
}

totd_window = {
  tips = {
    utf8 "Todo hospital necesita una mesa de recepción y una consulta para empezar a funcionar. Después de eso, depende del tipo de pacientes que visite tu hospital. Eso sí, una farmacia siempre es una buena opción.",
    utf8 "Las máquinas como el inflador necesitan mantenimiento. Utiliza a un bedel o dos para reparar tus máquinas, o te arriesgarás a herir a tus pacientes y a tu personal.",
    utf8 "Tras un tiempo, tu personal se cansará. Asegúrate de construir una sala de personal, para que puedan relajarse.",
    utf8 "Coloca varios radiadores para mantener calentitos a tu personal y empleados, o se enfadarán. Usa el mapa superior para buscar los puntos de tu hospital que no tengan calefacción.",
    utf8 "El nivel de habilidad de un doctor influye significativamente la calidad y la velocidad de sus diagnósticos. Coloca a un doctor habilidoso en tu consulta, y no necesitarás tantas salas de diagnóstico adicionales.",
    utf8 "Los doctores pueden mejorar sus habilidades aprendiendo de un asesor en la sala de entrenamiento. Si el asesor tiene una calificación especial (cirujano, psiquiatra o investigador), también pasará sus conocimientos a sus pupilos.",
    utf8 "¿Has probado a meter el número de emergencias (112) en el fax? ¡Asegúrate de tener el sonido activado!",
    utf8 "Puedes ajustar algunos parámetros como la resolución y el idioma del juego en la ventana de Opciones que encontrarás tanto en el menú principal como dentro del juego.",
    utf8 "¿Has seleccionado el Castellano, pero sigues viendo textos en inglés en algún lugar? ¡Ayúdanos avisando de las líneas de texto que estén en inglés para que podamos traducirlas!",
    utf8 "¡El equipo de CorsixTH busca refuerzos! ¿Te interesa programar, traducir o crear gráficos para CorsixTH? Contáctanos en nuestro foro, lista de correo o canal IRC (corsix-th en freenode).",
    utf8 "Si encuentras un fallo, infórmalo en nuestro registro de fallos: th-issues.corsix.org",
    utf8 "Cada nivel tiene unos requisitos concretos que debes conseguir antes de poder continuar al siguiente nivel. Mira en la ventana de estado para ver como llevas los objetivos del nivel.",
    utf8 "Si quieres editar o quitar una habitación ya existente, puedes hacerlo con el botón de Editar habitación que verás en la barra de herramientas inferior.",
    utf8 "Cuando tengas muchos pacientes esperando, puedes averiguar rápidamente quienes están esperando para una habitación en concreto pasando el cursor del ratón por encima de la habitación.",
    utf8 "Pulsa en la puerta de una habitación para ver su cola. Aquí puedes manipular ciertos aspectos, como reordenar la cola o mandar a un paciente hacia otra habitación.",
    utf8 "El personal que no esté contento pedirá aumentos de sueldo con frecuencia. Asegúrate de que tu personal trabaja en un entorno cómodo para evitar que esto ocurra.",
    utf8 "Los pacientes tendrán sed mientras esperan en tu hospital, ¡y aún más si subes la calefacción! Coloca máquinas de bebidas en lugares estratégicos para ganar un dinerillo extra.",
    utf8 "Puedes cancelar el progreso del diagnóstico de un paciente de forma prematura y adivinar la cura si ya has descubierto la enfermedad. Ten en cuenta que esto aumentará el riesgo de darle el tratamiento equivocado, lo que matará al paciente.",
    utf8 "Las emergencias pueden ser una buena forma de llevarte algo de dinero extra, siempre y cuando tengas la capacidad suficiente para ocuparte de los pacientes de la emergencia a tiempo.",
  },
  previous = utf8 "Siguiente consejo",
  next = utf8 "Consejo anterior",
}

tooltip.totd_window = {
  previous = utf8 "Mostrar el consejo anterior",
  next = utf8 "Mostrar el consejo siguiente",
}

debug_patient_window = {
  caption = utf8 "Paciente de depuración",
}

cheats_window = {
  caption = "Trucos",
  warning = utf8 "Advertencia: ¡No conseguirás bonificaciones al acabar este nivel si haces trampas!",
  cheated = {
    no = "Se han usado trucos: No",
    yes = utf8 "Se han usado trucos: Sí",
  },
  cheats = {
    money = "Truco de dinero",
    all_research = "Truco de todo investigado",
    emergency = "Crear una emergencia",
    vip = "Crear un VIP",
    earthquake = "Crear terremoto",
    create_patient = "Crear un paciente",
    end_month = "Fin de mes",
    end_year = utf8 "Fin del año",
    lose_level = "Perder el nivel",
    win_level = "Ganar el nivel",
  },
  close = "Cerrar",
}

tooltip.cheats_window = {
  close = "Cerrar la ventana de trucos",
  cheats = {
    money = utf8 "Añadir 10.000 dólares a tu cuenta bancaria.",
    all_research = "Completar todas las investigaciones.",
    emergency = "Crear una emergencia.",
    vip = "Crear un VIP.",
    earthquake = "Crear un terremoto.",
    create_patient = "Crear un paciente en el borde del mapa.",
    end_month = "Avanza hasta el fin del mes actual.",
    end_year = utf8 "Avanza hasta el final del año actual.",
    lose_level = "Perder el nivel actual.",
    win_level = "Ganar el nivel actual.",
  }
}

introduction_texts = {
  demo = {
    utf8 "¡Bienvenido al hospital de demostración!",
    utf8 "Por desgracia, la versión de demostración solo contiene este nivel (además de los niveles personalizados). Sin embargo, tienes más que suficiente para estar entretenido por un rato.",
    utf8 "Te enfrentarás a varias enfermedades que necesitan de ciertas habitaciones para su cura. De vez en cuando pueden surgir emergencias. Y necesitarás investigar sobre las enfermedades construyendo un Departamento de investigación.",
    utf8 "Tu objetivo es ganar 100.000 dólares, que el valor de tu hospital llegue hasta 70.000 dólares y tengas una reputación de 700, con un porcentaje de pacientes curados del 75%.",
    utf8 "Procura que tu reputación no caiga por debajo de 300 y que no mates a más del 40% de tus pacientes, o fracasarás.",
    utf8 "¡Buena suerte!",
  },
}

calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = "%d llamadas; %d asignadas",
  staff = "%s - %s",
  watering = "Regando @ %d,%d",
  repair = "Reparar %s",
  close = "Cerrar",
}

tooltip.calls_dispatcher = {
  task = utf8 "Lista de tareas - puslsa en una tarea para abrir la ventana del personal asignado y desplázate hasta la posición de la tarea.",
  assigned = utf8 "Esta opción está activada si alguien ha sido asignado a la tarea correspondiente.",
  close = utf8 "Cerrar la ventana de llamadas de control.",
}
