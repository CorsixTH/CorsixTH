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

Language("Castellano", "Spanish", "es", "spa", "esp")
Inherit("english")
Inherit("original_strings", 4)

-- override
misc.hospital_open = "Hospital abierto"
misc.save_success = "Partida guardada correctamente"
misc.save_failed = "ERROR: No se ha podido guardar la partida"

fax = {
  vip_visit_result = {
      very_bad = {
        [1] = utf8 "¡Vaya tugurio! Voy a intentar clausurarlo.",
      },
  },
}
fax.emergency.num_disease = "Hay %d personas con %s y necesitan ser atendidas inmediatamente."

tooltip.handyman_window.close = "Cerrar ventana"
tooltip.machine_window.close = "Cerrar ventana"
tooltip.queue_window.close = "Cerrar ventana"
tooltip.jukebox.rewind = utf8 "Rebobinar reproductor de música"
tooltip.jukebox.loop = utf8 "Funcionamiento contínuo del reproductor de música"
tooltip.jukebox.stop = utf8 "Parar reproductor de música"
tooltip.jukebox.close = utf8 "Cerrar reproductor de música"
tooltip.jukebox.current_title = utf8 "Reproductor de música"
tooltip.jukebox.play = utf8 "Encender reproductor de música"
tooltip.jukebox.fast_forward = utf8 "Avance rápido del reproductor de música"
tooltip.patient_window.close = "Cerrar ventana"
tooltip.staff_window.close = "Cerrar ventana"
tooltip.build_room_window.close = "Salir de esta ventana y volver al juego"

-- Improve tooltips in staff window to mention hidden features
tooltip.staff_window.face = "Rostro de la persona - pulsa para abrir pantalla de recursos."
tooltip.staff_window.center_view = utf8 "Botón izquierdo del ratón para enfocar al personal, botón derecho del ratón para rotar entre los miembros del personal."

-- new strings
object.litter = "Basura"
tooltip.objects.litter = utf8 "Basura: Tirada en el suelo por un paciente porque no ha encontrado una papelera donde tirarla."

tooltip.fax.close = "Cierra esta ventana sin borrar el mensaje."
tooltip.message.button = utf8 "Botón izquierdo del ratón para abrir el mensaje."
tooltip.message.button_dismiss = utf8 "Botón izquierdo para abrir el mensaje, botón derecho para rechazarlo."

menu_options = {
  lock_windows = "  BLOQUEAR VENTANAS  ",
  edge_scrolling = "  DESPLAZAR POR BORDES  ",
  settings = utf8 "  CONFIGURACIÓN  ",
}
menu_options_game_speed.pause = "  PAUSA  "

-- The demo does not contain this string
menu_file.restart = "  REINICIAR  "

menu_debug = {
  jump_to_level               = "  CAMBIAR DE NIVEL  ",
  transparent_walls           = "  PAREDES TRANSPARENTES  ",
  limit_camera                = utf8 "  LIMITAR CÁMARA  ",
  disable_salary_raise        = "  DESACTIVAR SUBIDA DE SUELDO  ",
  make_debug_patient          = utf8 "  CREAR PACIENTE DE DEPURACIÓN  ",
  spawn_patient               = "  CREAR PACIENTE  ",
  make_adviser_talk           = "  HACER HABLAR AL CONSEJERO  ",
  show_watch                  = "  MOSTRAR RELOJ  ",
  create_emergency            = "  CREAR EMERGENCIA  ",
  place_objects               = "  COLOCAR OBJETOS  ",
  dump_strings                = "  VOLCAR TEXTOS DEL JUEGO  ",
  dump_gamelog                = "  VOLCAR REGISTRO DEL JUEGO  ",
  map_overlay                 = "  SOBREPONER MAPA  ",
  sprite_viewer               = "  VISUALIZADOR DE ANIMACIONES  ",
  lua_console                 = "  CONSOLA LUA  ",
}
menu_debug_overlay = {
  none                        = utf8 "  NINGUNO/A  ",
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
  room_forbidden_non_reachable_parts = utf8 "Colocar la habitación en este lugar hará que ciertas partes del hospital no sean accesibles.",

  warnings = {
    pay_back_loan = utf8 "Tienes bastante dinero. ¿Por qué no pagas ese préstamo que tienes pendiente?",
  },
  cheats = {
    cash_cheat = utf8 "¡Has activado el truco de dinero aleatorio!  Te gusta hacer trampas, ¿eh, majo? Pero ten cuidado, ¡si usas demasiado este truco, tu reputación caerá!",
    cash_cheat_warn = utf8 "¡Te he avisado por hacer trampas, los tramposos no prosperan!  El público ha empezado a enterarse de tus trampas, ¡puedes estar seguro de que tu reputación se va a hundir!",
    th_cheat = utf8 "¡Felicidades, has desbloqueado los trucos! ...O eso hubieras hecho si estuvieras jugando al juego original. Prueba con otra cosa.",
    crazy_on_cheat = utf8 "¡Oh, no! ¡Todos los médicos se han vuelto locos!",
    crazy_off_cheat = utf8 "Uff... los médicos han recuperado la cordura.",
    roujin_on_cheat = utf8"¡Desafío de Roujin activado! Buena suerte...",
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

fax = {
  welcome = {
    beta1 = {
      utf8 "¡Bienvenido a CorsixTH, un clon de código abierto del juego Theme Hospital de Bullfrog!",
      utf8 "Esta es la beta jugable 1 de CorsixTH. Se han implementado varias habitaciones, enfermedades y características, pero aún faltan muchas cosas.",
      utf8 "Si te gusta este proyecto, puedes ayudarnos a desarrollarlo, por ejemplo, informando de errores o programando algo por tu cuenta.",
      utf8 "¡Pero ahora diviértete con el juego! Para los que Theme Hospital no les suene de nada: Empieza construyendo una mesa de recepción (en el menú de objetos) y una consulta (salas de diagnóstico). También necesitarás varias salas de tratamiento.",
      utf8 "-- El equipo de CorsixTH, th.corsix.org",
      utf8 "PD: ¿Puedes encontrar los huevos de pascua que hemos metido?",
    },
    beta2 = {
      utf8 "¡Bienvenido a la segunda beta de CorsixTH, un clon de código abierto del juego Theme Hospital de Bullfrog!",
      utf8 "Se han incorportado un montón de características nuevas desde la última versión. Mira en el registro de cambios para ver la lista incompleta.",
      utf8 "¡Pero primero, a jugar! Parece que tienes un mensaje esperándote. Cierra esta ventana y pulsa en el signo de interrogación sobre el panel inferior.",
      utf8 "-- El equipo de CorsixTH, th.corsix.org",
    },
  },
  tutorial = {
    utf8 "¡Bienvenido a tu primer hospital!",
    utf8 "¿Quieres ver un corto tutorial?",
    utf8 "Sí, enséñame lo básico.",
    utf8 "No, ya me conozco todo esto.",
  },
  choices = {
    return_to_main_menu = utf8 "Volver al menú principal",
    accept_new_level = utf8 "Continuar al siguiente nivel",
    decline_new_level = utf8 "Seguir jugando un poco más",
  },
}

letter = {
  dear_player = utf8 "Estimado %s",
  custom_level_completed = utf8 "¡Bien hecho! ¡Has completado todos los objetivos de este nivel personalizado!",
  return_to_main_menu = utf8 "¿Quieres volver al menú principal o seguir jugando?",
  level_lost = utf8 "¡Qué pena! Has fallado este nivel. ¡Mejor suerte la próxima vez!",
}

install = {
  title = utf8 "--------------------------------- Configuración de CorsixTH ---------------------------------",
  th_directory = utf8 "CorsixTH necesita una copia de los archivos de datos del Theme Hospital original (o de la demo) para poder funcionar. Utiliza el selector de debajo para localizar la carpeta de instalación de Theme Hospital.",
}

misc.not_yet_implemented = utf8 "(aún no implementado)"
misc.no_heliport = utf8 "O no se han descubierto enfermedades, o no hay un helipuerto en este nivel."

main_menu = {
  new_game = "Nueva partida",
  custom_level = "Nivel personalizado",
  load_game = "Cargar partida",
  options = "Opciones",
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
}

tooltip.custom_game_window = {
  start_game_with_name = "Cargar el nivel %s",
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
  back = "Volver",
}

tooltip.menu_list_window = {
  back = "Cerrar esta ventana",
}

options_window = {
  fullscreen = "Pantalla completa",
  width = "Ancho",
  height = "Alto",
  change_resolution = utf8 "Cambiar resolución",
  back = "Volver",
}

tooltip.options_window = {
  fullscreen_button = utf8 "Pulsa para activar el modo de pantalla completa",
  width = utf8 "Introduce el ancho de pantalla deseado",
  height = utf8 "Introduce el alto de pantalla deseado",
  change_resolution = utf8 "Cambia la resolución de la ventana a las dimensiones indicadas a la izquierda",
  language = utf8 "Seleccionar el idioma %s",
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
  tutorial = utf8 "¿Necesitas ayuda para entender cómo funciona el juego? Selecciona esta opción.",
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
  restart = utf8 "¿Seguro que quieres reiniciar el nivel?",
}

information = {
  custom_game = utf8 "Bienvenido a CorsixTH. ¡Diviértete con este mapa personalizado!",
  cannot_restart = utf8 "Por desgracia esta partida personalizada se guardó antes de que se implementara la característica de reiniciar.",
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
