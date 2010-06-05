--[[ Copyright (c) 2010 "mccunyao"

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
misc = {
  hospital_open = "Hospital abierto",
  save_success = "Partida guardada correctamente",
  save_failed = "ERROR: No se ha podido guardar la partida",
}

fax = {
  vip_visit_result = {
      very_bad = {
        [1] = utf8 "¡Vaya tugurio! Voy a intentar clausurarlo.",
      },
  },
  emergency = {
    num_disease = "Hay %d personas con %s y necesitan ser atendidas inmediatamente.",
  },
}
tooltip = {
  handyman_window = {
    close = "Cerrar ventana",
  },
}


-- new strings
object.litter = "Basura"
tooltip.objects.litter = utf8 "Basura: Tirada en el suelo por un paciente porque no ha encontrado una papelera donde tirarla."

menu_options.lock_windows = "  BLOQUEAR VENTANAS  "
menu_options.settings = utf8 "  CONFIGURACIÓN  "
menu_options_game_speed.pause = "  PAUSA  "

-- The demo does not contain this string
menu_file.restart = "  REINICIAR  "

menu_debug = {
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
  dump_gamelog                = "  VOLCAR REGISTRO DEL JUEGO",
  map_overlay                 = "  SOBREPONER MAPA  ",
  sprite_viewer               = "  VISUALIZADOR DE ANIMACIONES  ",
}
menu_debug_overlay = {
  none                        = utf8 "  NINGUNO/A  ",
  flags                       = "  BANDERAS  ",
  positions                   = "  POSICIONES  ",
  byte_0_1                    = "  BYTE 0 Y 1  ",
  byte_floor                  = "  BYTE SUELO  ",
  byte_n_wall                 = "  BYTE PARED NORTE  ",
  byte_w_wall                 = "  BYTE PARED OESTE  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  PARCELA  ",
}
adviser.room_forbidden_non_reachable_parts = utf8 "Colocar la habitación en este lugar hará que ciertas partes del hospital no sean accesibles."

dynamic_info.patient.actions.no_gp_available = utf8 "Esperando a que construyas una consulta"
dynamic_info.staff.actions.heading_for = utf8 "Dirigiéndose a %s"

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
    utf8 "¡Bienvenido a tu primer Hospital!",
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

misc.not_yet_implemented = utf8"(aún no implementado)"
misc.no_heliport = utf8 "O no se han descubierto enfermedades, o no hay un helipuerto en este nivel."

main_menu = {
  new_game = utf8 "Nueva partida",
  custom_level = utf8 "Nivel personalizado",
  load_game = utf8 "Cargar partida",
  options = utf8 "Opciones",
  exit = utf8 "Salir",
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

errors = {
  dialog_missing_graphics = utf8 "Los archivos de datos de la demo no contienen esta ventana.",
  save_prefix = utf8 "Error al guardar la partida: ",
  load_prefix = utf8 "Error al cargar la partida: ",
}

confirmation = {
  needs_restart = utf8 "Cambiar este parámetro necesita que CorsixTH sea reiniciado. Se perdera todo el progreso que no hayas guardado. ¿Seguro que quieres hacer esto?"
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
    utf8 "Coloca varios radiadores para mantener calentitos a tu personal y empleados, o se enfadarán.",
    utf8 "El nivel de habilidad de un doctor influye significativamente la calidad y la velocidad de sus diagnósticos. Coloca a un doctor habilidoso en tu consulta, y no necesitarás tantas salas de diagnóstico adicionales.",
    utf8 "Los doctores pueden mejorar sus habilidades aprendiendo de un asesor en la sala de entrenamiento. Si el asesor tiene una calificación especial (cirujano, psiquiatra o investigador), también pasará sus conocimientos a sus pupilos.",
    utf8 "¿Has probado a meter el número de emergencias (112) en el fax? ¡Asegúrate de tener el sonido activado!",
    utf8 "El menú de opciones todavía no está implementado, pero puedes ajustar algunos parámetros como la resolución y el idioma editando el archivo config.txt en la carpeta raíz de CorsixTH.",
    utf8 "¿Has seleccionado el Castellano, pero sigues viendo textos en inglés por todas partes? ¡Ayúdanos traduciendo los textos que faltan al Castellano",
    utf8 "¡El equipo de CorsixTH busca refuerzos! ¿Te interesa programar, traducir o crear gráficos para CorsixTH? Contáctanos en nuestro foro, lista de correo o canal IRC (corsix-th en freenode).",
    utf8 "Si encuentras un fallo, infórmalo en nuestro registro de fallos: th-issues.corsix.org",
    utf8 "CorsixTH fue hecho público por primera vez el 24 de julio de 2009. La primera versión fue la beta jugable 1 publicada el 24 de diciembre de 2009. Tres meses más tarde, estamos orgullosos de mostrar la beta 2 (publicada el 24 de marzo de 2010).",
  },
  previous = utf8 "Siguiente consejo",
  next = utf8 "Consejo anterior",
}

tooltip.totd_window = {
  previous = utf8 "Mostrar el consejo anterior",
  next = utf8 "Mostrar el consejo siguiente",
}
