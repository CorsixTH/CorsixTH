--[[ Copyright (c) 2016 Víctor González a.k.a. "mccunyao"

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
fax.emergency.locations[1] = "Planta química González"
fax.emergency.locations[3] = "Centro de plantas acuáticas"
fax.emergency.locations[5] = "Congreso de bailarines rusos"
fax.emergency.locations[8] = "La casa del curry"
fax.emergency.locations[9] = "Emporio petroquímico usado Díaz y Díaz"
fax.epidemic.cover_up_explanation_2 = "Si un inspector sanitario te visita y encuentra una epidemia encubierta tomará medidas drásticas en tu contra."
fax.epidemic.disease_name = "Tus médicos han descubierto una variedad contagiosa de %s."
tooltip.main_menu.continue = "Continuar la última partida guardada."
tooltip.watch.epidemic = "Epidemia: tiempo que queda para encubrir la epidemia. Cuando este tiempo expire O un paciente contagioso abandone tu hospital, un Inspector de Sanidad puede visitarte. El botón activa o desactiva el modo vacuna. Pulsa en un paciente para que lo vacune una Enfermera."
tooltip.watch.hospital_opening = "Tiempo de construcción: es el tiempo que queda para que tu hospital sea declarado abierto. Si pulsas el botón verde abrirás el hospital inmediatamente."
rooms_short.decontamination = "Descontaminación"
adviser.room_requirements.op_need_another_surgeon = "Tienes que contratar a otro cirujano para poder usar el quirófano."
adviser.information.patient_abducted = "Los alienígenas han raptado a uno de tus pacientes."
adviser.praise.plants_thriving = "Muy bien. Tus plantas están muy lozanas. Tienen un aspecto maravilloso. Si las mantienes así podrás ganar un premio."
adviser.level_progress.reputation_good_enough = "De acuerdo, tu reputación lo es bastante buena para ganar este nivel, manténla por encima de %d y soluciona otros problemas para terminar."
adviser.staff_place_advice.only_nurses_in_room = "Sólo pueden trabajar las Enfermeras en el(la) %s"
adviser.tutorial.select_receptionists = "Haz click en el icono que parpadea para ver qué recepcionistas están disponibles."
rooms_long.decontamination = "Consulta de Descontaminación"
dynamic_info.staff.ability = "Habilidad"
dynamic_info.staff.actions.going_to_repair = "Yendo a reparar %s"
dynamic_info.object.queue_expected = "Fila esperada: %d"
fax.vip_visit_result.remarks.super[1] = "¡Qué hospital tan eficaz! La próxima vez que esté gravemente enfermo, llevadme allí."
research.categories.drugs = "Investigación farmacéutica"
transactions = {
  machine_replacement = "Coste de máquina de reemplazo",
  eoy_trophy_bonus = "Primas por trofeo Fin de Año",
  drinks = "Ingreso: Máquinas de bebidas",
  jukebox = "Ingreso: Gramolas",
  cheat = "Dinero de trampas",
  eoy_bonus_penalty = "Primas/Multas en fin de año",
}
confirmation.return_to_blueprint = "¿Seguro que quieres sustituir el(la) %s por $%d?"
staff_descriptions = {
  misc = {
    [9] = "Le gusta hacer surf. ",
    [10] = "Le gusta el piragüismo. ",
    [11] = "Destila whisky. ",
    [12] = "Es un experto en formación. ",
    [13] = "Le gusta el cine francés. ",
    [15] = "Conduce coches de carreras. ",
    [25] = "Participó en un concurso. ",
    [26] = "Colecciona metralla de la segunda guerra mundial. ",
    [29] = "Pone furiosos a los insectos rociándolos con desodorante. ",
  },
  good = {
    [3] = "Sabe de todo.",
  },
}
progress_report.percentage_pop = "% población"
letter = {
  [1] = {
    [1] = "¡Hola, %s!//",
    [2] = "¡Estupendo! Diriges este hospital de una manera excelente. Los peces gordos del Ministerio de Sanidad queremos saber si estarías interesado en hacerte cargo de un gran proyecto. Hay un trabajo para el que creemos eres la persona perfecta. El sueldo sería de %d. Piénsalo.//",
  },
  [2] = {
    [1] = "¡Hola, %s!//",
    [2] = "¡Felicidades! Has realizado notables mejoras en tu hospital. Tenemos otra cosa de la que podrías encargarte, si te apetece un cambio y afrontar nuevos retos. No tienes que aceptar, pero estaría bien que lo hicieras. El sueldo es de %d//",
  },
  [3] = {
    [1] = "¡Hola, %s!//",
    [2] = "Has dirigido con notable acierto este hospital. Creemos que tienes un brillante futuro y nos gustaría ofrecerte un puesto en otra parte. El sueldo sería de %d y creemos que te encantaría el reto que ello supondría.//",
  },
  [4] = {
    [1] = "¡Hola, %s!//",
    [2] = "¡Felicidades! En el Ministerio estamos muy impresionados por tu capacidad como director de hospital. Eres sin duda una persona valiosa para el Departamento de Sanidad, pero creemos que preferirías un trabajo más cualificado. Recibirías un sueldo de %d, si bien la decisión es tuya.//",
  },
  [5] = {
    [1] = "¡Hola, %s!//",
    [2] = "Saludos de nuevo. Respetamos tus deseos de no trasladarte de tu estupendo hospital, pero te pedimos que lo reconsideres. Te ofreceremos un mejor sueldo de %d si decides marcharte a otro hospital y te encargas de la dirección del mismo.//",
  },
  [6] = {
    [1] = "¡Hola, %s!//",
    [2] = "Recibe nuestros saludos. Sabemos lo mucho que has disfrutado de tu estancia en esta institución, tan agradable y bien dirigida, pero creemos que ahora deberías pensar en tu futuro. Naturalmente, tendrías un sueldo de %d si decidieras trasladarte. Merece la pena que lo pienses.//",
  },
  [7] = {
    [1] = "¡Hola, %s!//",
    [2] = "¡Buenos días! El Ministerio de Sanidad quisiera saber si vas a reconsiderar tu decisión de quedarte en tu hospital. Comprendemos que tienes un estupendo hospital, pero creemos que harías muy bien en aceptar un trabajo más estimulante, con un sueldo de %d.//",
  },
  [8] = {
    [1] = "¡Hola, %s!//",
    [2] = "Buenas de nuevo. Recibimos tu negativa a nuestra última carta, en la que te ofrecíamos un puesto de dirección en otro hospital y un alto sueldo de %d. No obstante, creemos que deberías reconsiderar esta decisión. Como verás, tenemos el trabajo perfecto para ti.//",
  },
  [9] = {
    [1] = "¡Hola, %s!//",
    [2] = "Has demostrado ser el mejor director de hospital en la larga y azarosa historia de la medicina. Este importantísimo logro no puede quedar sin recompensa, por lo que nos gustaría ofrecerte el puesto de Director Jefe de Todos los Hospitales. Es un puesto honorífico, con un sueldo de %d. Tendrás una presentación con todos los honores y la gente te demostrará su reconocimiento vayas donde vayas.//",
  },
  [10] = {
    [1] = "¡Hola, %s!//",
    [2] = "Felicidades por dirigir con éxito todos los hospitales que te hemos asignado. Esta soberbia actuación te capacita para viajar libremente por todo el mundo. Recibirás una pensión de %d y una limusina, a cambio de que viajes de ciudad en ciudad, saludando a tu incondicional público y fomentando la labor que se realiza en todos los hospitales.//",
  },
  [11] = {
    [1] = "¡Hola, %s!//",
    [3] = "Eres un ejemplo para todos los hombres de bien y todo el mundo, sin excepción, te considera una persona de enorme valía.//",
  },
  [12] = {
    [1] = "¡Hola, %s!//",
    [2] = "Tu exitosa carrera como el mejor director de hospital desde Moisés está llegando a su fin. No obstante, has provocado tal efecto en los círculos médicos, que el Ministerio quiere ofrecerte un sueldo de %s sólo por actuar en nuestro nombre inaugurando festejos, botando barcos y organizando coloquios. ¡El mundo entero te aclamaría y serías un excelente relaciones públicas!//",
  },
}
tooltip.staff_window.ability = "Nivel de cualificación"
tooltip.policy.diag_termination = "Se mantendrá el diagnóstico de un paciente hasta que los médicos estén seguros del porcentaje de DETENER, o hasta que se hayan usado todos los diagnosticadores"
tooltip.staff_list.ability = "Muestra el nivel de habilidad de estos empleados"

introduction_texts = {
  level1 =
    "¡Bienvenido a tu primer hospital! " ..
    "Para hacer que empiece a funcionar, coloca una recepción, construye una consulta y contrata a una recepcionista y a un médico. " ..
    "Luego espera a que lleguen los pacientes. " ..
    "Sería una buena idea que construyeras una consulta de psiquiatría y contrataras a un psiquiatra. " ..
    "Una farmacia y una enfermera son fundamentales para curar a tus pacientes. " ..
    "Cuidado con los casos malignos de pacientes cabezudos; se solucionan pronto en la consulta de inflatoterapia. " ..
    "Tendrás que curar a 10 personas y asegurarte de que tu reputación no sea inferior a 200.",

  level2 =
    "Hay una gran variedad de indisposiciones en esta zona.//" ..
    "Prepara tu hospital para tratar a más pacientes y proyecta la construcción de un Departamento de Investigación. " ..
    "Recuerda que debes mantener limpio el hospital y procura conseguir que tu reputación sea lo más alta posible. Tratarás enfermedades como la Lengua Larga, así que necesitarás una consulta de laringología. " ..
    "También puedes construir un cardiómetro para diagnosticar nuevas enfermedades. " ..
    "Estas dos consultas deberán ser investigadas antes de construirlas. También puedes comprar más terreno para ampliar tu hospital. Para ello, utiliza un mapa de la ciudad. ",
    "Intenta alcanzar una reputación de 300, un saldo bancario de 10.000 dólares y cura a 40 personas.",

  level3 =
    "Esta vez colocarás tu hospital en una zona acaudalada.//" ..
    "El Ministerio de Sanidad espera que consigas curar a muchos pacientes. " ..
    "Tendrás que ganarte una buena reputación para empezar, pero una vez que el hospital empiece a funcionar, concéntrate en ganar todo el dinero que puedas. " ..
    "También puede haber urgencias. " ..
    "Se producen cuando llega mucha gente que padece la misma enfermedad. " ..
    "Si los curas dentro de un plazo determinado, conseguirás aumentar tu reputación y ganar una prima extra. " ..
    "Habrá enfermedades, como el síndrome de rey, y deberás tener presupuesto para construir un quirófano y una enfermería adyacente. " ..
    "Tienes que ganar 20.000 dólares para superar este nivel.",

  level4 =
    "Haz que todos tus pacientes estén contentos, atiéndelos con la mayor eficacia e intenta que mueran los menos posibles.//" ..
    "Tu reputación está en juego, así que procura aumentarla todo lo que puedas. " ..
    "No te preocupes demasiado por el dinero; Lo irás ganando a medida que crezca tu reputación. " ..
    "También podrás formar a tus médicos para ampliar sus conocimientos: " ..
    "ellos podrán curar a los pacientes más difíciles. " ..
    "Alcanza una reputación por encima de 500.",

  level5 =
    "Este será un hospital concurrido, que tratará casos muy variados.//" ..
    "Tus médicos acaban de salir de la facultad, por lo que es fundamental que construyas una sala de formación para que alcancen el nivel de formación necesario. " ..
    "Sólo tienes tres especialistas para enseñar a tu personal inexperto, así que procura que estén contentos. " ..
    "Tienes que tener en cuenta que el hospital está ubicado encima de la falla geológica de San Androide. " ..
    "Siempre hay riesgo de terremoto. " ..
    "Los terremotos provocarán daños importantes en tus máquinas y alterarán el buen funcionamiento de tu hospital. " ..
    "Aumenta tu reputación hasta 400 y consigue unos ingresos de 50.000 dólares para triunfar. También debes curar a 200 pacientes. ",

  level6 =
    "Utiliza toda tu capacidad para conseguir un hospital que funcione bien y consiga curar a muchos pacientes y que pueda tratar cualquier caso que presenten los enfermos.//" ..
    "Estás avisado de que el ambiente, aquí, es especialmente propenso a gérmenes e infecciones. " ..
    "A menos que mantengas una escrupulosa limpieza en tu institución, tendrás que hacer frente a una serie de epidemias entre los pacientes. " ..
    "Procura obtener unos ingresos de 20.000 dólares y que el valor de tu hospital supere los 140.000 dólares. ",

  level7 =
    "Aquí estarás bajo la estricta vigilancia del Ministerio de Sanidad, así que procura que tus cuentas tengan unos ingresos excelentes y que aumente tu reputación.//" ..
    "No podemos permitirnos que haya muertes innecesarias; no son nada buenas para el negocio. " ..
    "Asegúrate de que tu personal está en plena forma y de que tienes todos los equipos necesarios. " ..
    "Consigue una reputación de 600, y un saldo bancario de 200.000 dólares.",

  level8 =
    "De ti depende que puedas construir el hospital más eficiente y rentable posible.//" ..
    "La gente de por aquí es bastante adinerada, así que sabléalos todo lo que puedas. " ..
    "Recuerda, curar a la gente está muy bien, pero lo que de verdad NECESITAS es su dinero. " ..
    "Despluma vivos a estos pacientes. " ..
    "Acumula 300.000 dólares para completar este nivel. ",

  level9 =
    "Después de ingresar dinero en la cuenta bancaria del Ministerio y pagar una nueva limusina para el Ministro, ahora puedes dedicarte a crear un buen hospital para cuidar a los enfermos y necesitados. " ..
    "Aquí tendrás un montón de problemas diferentes. " ..
    "Si tu personal tiene una buena formación y cuentas con suficientes consultas, podrás resolver cualquier situación. " ..
    "Tu hospital tendrá que valer 200.000 dólares y necesitarás tener 400.000 dólares en el banco. " ..
    "Si no lo consigues no podrás terminar el nivel.",

  level10 =
    "Además de ocuparte de curar todas las enfermedades que pueda haber, el Ministerio te pide que emplees algo de tiempo en aumentar la eficacia de tus medicinas.//" ..
    "Ha habido algunas quejas por parte de D. Salutísimo, el Perro Guardián de la Salud, así que debes procurar que todas tus medicinas sean sumamente eficaces para quedar bien. " ..
    "También debes asegurarte de que tu hospital tenga una reputación intachable. Procura que mueran pocos pacientes. " ..
    "Como sugerencia, deberías dejar espacio para un baño gelatinoso. " ..
    "Para ganar, tus medicinas deberán tener una eficacia de, al menos, un 80%, tienes que conseguir una reputación de 650 y guardar 500.000 dólares en el banco.",

  level11 =
    "Tienes la oportunidad de construir el no va más en hospitales. " ..
    "Esta es una zona de enorme prestigio y al Ministerio le gustaría que éste fuera el mejor hospital. " ..
    "Esperamos que ganes mucho dinero, alcances una excelente reputación y te ocupes de todos los casos que se presenten. " ..
    "Este es un trabajo importante. " ..
    "Tendrás que ser muy hábil para llevarlo a cabo. " ..
    "También debes tener en cuenta que se han visto ovnis en la zona. Asegúrate de que tu personal esté preparado para recibir alguna visita inesperada. " ..
    "Tu hospital tendrá que alcanzar un valor de 240.000 dólares, necesitarás tener 500.000 dólares en el banco y una reputación de 700.",

  level12 =
    "Ahora te enfrentas al mayor de los retos. " ..
    "El Ministerio ha quedado impresionado con tus logros y tiene una tarea difícil para ti, quieren que se construya otro magnífico hospital, que tenga unos excelentes ingresos y una reputación increíble. " ..
    "También se espera que compres todo el terreno que puedas, cures todo (y queremos decir todas las enfermedades) y ganes todos los premios. " ..
    "¿Crees que podrás conseguirlo? " ..
    "Gana 650.000 dólares, cura a 750 personas y consigue una reputación de 800 para ganar este nivel. ",

  level13 =
    "Tu increíble habilidad como director de hospital ha atraído la atención de la División Secreta Especial del Servicio Secreto Especial. " ..
    "Tienen un trabajo especial para ti. Hay un hospital infestado de ratas que necesita un exterminador eficiente. " ..
    "Tienes que matar todas las ratas que puedas antes de que el personal de Mantenimiento limpie toda la suciedad. " ..
    "¿Crees que eres apto para la misión?",

  level14 =
    "Aún tienes un reto más: el hospital sorpresa totalmente imprevisible. " ..
    "Si consigues tener éxito, serás el ganador de todos los ganadores. " ..
    "Y no esperes que sea pan comido, porque es la tarea más difícil que jamás afrontarás. " ..
    "¡Buena suerte!",

  level15 =
    "Bien, estos son los mecanismos básicos para poner en marcha un hospital.//" ..
    "Tus Médicos van a necesitar toda la ayuda que puedan obtener para diagnosticar a algunos de los pacientes. " ..
    "Puedes ayudarles construyendo otros equipos de diagnóstico como la Sala de Diagnóstico General.",

  level16 =
    "Una vez que hayas diagnosticado a alguno de los pacientes necesitarás construir salas de tratamiento y clínicas para curarles: " ..
    "puedes comenzar con una Farmacia, y necesitarás una Enfermera que dispense las medicinas en la Farmacia.",

  level17 =
    "Un último aviso: estate atento a tu Reputación, es lo que atraerá pacientes a tu establecimiento. " ..
    "¡Si no matas a mucha gente y los mantienes razonablemente felices no deberías tener muchos problemas en este nivel!//" ..
    "Ahora es cosa tuya, buena suerte y todo eso.",

  demo =
    "¡Bienvenido al hospital de demostración!" ..
    "Por desgracia, la versión de demostración solo contiene este nivel. Sin embargo, tienes más que suficiente para estar entretenido por un rato." ..
    "Te enfrentarás a varias enfermedades que necesitan de ciertas habitaciones para su cura. De vez en cuando pueden surgir emergencias. Y necesitarás " ..
    "investigar sobre las enfermedades construyendo un Departamento de investigación." ..
    "Tu objetivo es ganar 100.000 dólares, que el valor de tu hospital llegue hasta 70.000 dólares y tengas una reputación de 700, con un porcentaje de pacientes curados del 75%." ..
    "Procura que tu reputación no caiga por debajo de 300 y que no mates a más del 40% de tus pacientes, o fracasarás." ..
    "¡Buena suerte!",
}

town_map.area = "Zona"
trophy_room = {
  rats_killed = {
    trophies = {
      [2] = "Mereces este premio de la Federación Matarratas por tu excepcional habilidad para eliminar ratas, demostrándolo al acabar con %s ejemplares.",
      [3] = "Se te concede el Trofeo Exterminador de Ratas por tu gran habilidad para eliminar %d ratas en tu hospital el año pasado.",
    },
  },
  hosp_value = {
    penalty = {
      [1] = "Tu hospital no ha alcanzado un valor razonable. Has administrado mal el dinero. Recuerda, un buen hospital también es un hospital caro.",
    },
    regional = {
      [1] = "Eres una promesa de los negocios. Tu hospital es el más valioso de toda la zona.",
    },
  },
  happy_patients = {
    awards = {
      [2] = "Los pacientes que visitaron tu hospital se sintieron más contentos con su tratamiento que en el resto de los hospitales.",
    },
    penalty = {
      [1] = "La gente que acude al hospital tiene una experiencia terrible. Tendrás que esforzarte más si quieres ganarte el respeto del Ministerio.",
      [2] = "La gente que fue atendida en tu hospital se quejó del estado del mismo. Deberías tener más en cuenta el bienestar de los pacientes.",
    },
  },
  research = {
    penalty = {
      [1] = "Has sido poco eficiente investigando curaciones, máquinas y medicinas nuevas. Esto no es bueno, ya que el avance tecnológico es algo fundamental.",
    },
    regional_bad = {
      [1] = "Los demás hospitales son mejores que el tuyo en investigación. En el Ministerio están furiosos, tu hospital debería concederle más importancia.",
    },
  },
  many_cured = {
    regional = {
      [1] = "Se te concede el premio a la curación total por haber curado a más gente que todos los demás hospitales juntos.",
    },
    awards = {
      [1] = "Felicidades por curar a un montón de gente el año pasado. Un gran número de personas se sienten mucho mejor gracias a tu trabajo.",
    },
  },
  best_value_hosp = {
    penalty = {
      [1] = "Todos los hospitales de la zona valen más que el tuyo. Haz algo respecto a esta vergonzosa situación. ¡Consigue cosas más caras!",
    },
  },
  healthy_plants = {
    trophies = {
      [2] = "Salvar a las Plantas quiere concederte el Premio del Ecologista Mayor por mantener bien sanas las plantas de tu hospital durante el pasado año.",
    },
  },
  high_rep = {
    regional = {
      [1] = "Por favor, acepta el Premio Bullfrog por dirigir el mejor hospital del año. ¡Disfrútalo, te lo has ganado!",
    },
  },
  consistant_rep = {
    trophies = {
      [2] = "Felicidades por ganar el Premio Sábanas Limpias por ser el hospital con la mejor reputación del año. Te lo has merecido.",
    },
  },
  wait_times = {
    penalty = {
      [1] = "En tu hospital, los pacientes esperan demasiado tiempo. Siempre hay colas inaceptables. Podrías tratar a tus pacientes con más eficacia si quisieras.",
    },
  },
  happy_staff = {
    awards = {
      [2] = "Tu personal está tan contento de trabajar para ti que no pueden dejar de sonreír. Eres un director excelente.",
    },
    trophies = {
      [1] = "Has ganado el Premio Médico Sonriente por mantener lo más contento posible a tu personal.",
      [3] = "Te concedemos el premio Copa de la Sonrisa Radiante por mantener contento a todo tu personal por encima de todo durante el año pasado.",
    },
  },
  emergencies = {
    award = {
      [1] = "¡Felicidades! Has ganado este premio por la eficacia con la que has solucionado las urgencias. Buen trabajo.",
    },
  },
}
diseases = {
  corrugated_ankles = {
    cause = "Causa: Atropellar señales de tráfico en la carretera.",
    symptoms = "Síntomas: Los pies no entran en los zapatos.",
    cure = "Cura: Los tobillos se enderezan bebiendo una infusión ligeramente tóxica de hierbas y plantas.",
  },
  jellyitis = {
    cause = "Causa: Una dieta rica en gelatina y demasiado ejercicio.",
    symptoms = "Síntomas: Un temblor excesivo y caerse al suelo muchas veces.",
    cure = "Cura: Se sumerge al paciente durante un rato en el baño gelatinoso en una consulta especial.",
  },
  kidney_beans = {
    cause = "Causa: Masticar los cubitos de hielo de las bebidas.",
    symptoms = "Síntomas: Dolor e ir con frecuencia al baño.",
    cure = "Cura: Dos cirujanos extraen los cálculos sin rozar los bordes del riñón.",
  },
  fractured_bones = {
    cause = "Causa: Caída de cosas voluminosas sobre el cemento.",
    symptoms = "Síntomas: Un gran crujido y la imposibilidad de usar los miembros afectados.",
    cure = "Cura: Se pone una escayola, que después se quita con un láser quitaescayolas.",
  },
  spare_ribs = {
    cause = "Causa: Sentarse sobre suelos muy fríos.",
    symptoms = "Síntomas: Malestar en el pecho.",
    cure = "Cura: Dos cirujanos extraen las costillas y se las dan al paciente en una bolsita.",
  },
  alien_dna = {
    cause = "Causa: Enfrentarse a gigantes que tienen sangre alienígena inteligente.",
    symptoms = "Síntomas: Metamorfosis gradual en alienígena y deseos de destruir nuestras ciudades.",
    cure = "Cura: Se extrae el ADN con una máquina, se purifica de elementos alienígenas y se vuelve a inyectar rápidamente.",
  },
  invisibility = {
    cause = "Causa: El picotazo de una hormiga radiactiva (e invisible).",
    symptoms = "Síntomas: Los pacientes no sufren. Muchos aprovechan su enfermedad para gastar bromas a sus familiares.",
    cure = "Cura: Beber un líquido coloreado en la farmacia que hará completamente visible al paciente.",
  },
  infectious_laughter = {
    cause = "Causa: Una comedia clásica de situación",
    symptoms = "Síntomas: No poder parar de reír y repetir frases hechas nada divertidas.",
    cure = "Cura: Un psiquiatra cualificado debe recordar al paciente que su enfermedad es grave.",
  },
  broken_wind = {
    cause = "Causa: Usar un aparato gimnástico después de las comidas.",
    symptoms = "Síntomas: Molestar a la gente que está justo detrás del paciente.",
    cure = "Cura: En la farmacia se bebe rápidamente una fuerte mezcla de átomos acuosos.",
  },
  chronic_nosehair = {
    cause = "Causa: Oler con desprecio a aquellos que están peor que el paciente.",
    symptoms = "Síntomas: Tener tanto pelo en la nariz como para hacer una peluca.",
    cure = "Cura: Se toma por vía oral un jarabe quitapelo preparado en la farmacia.",
  },
  bloaty_head = {
    name = "Paciente cabezudo",
    cause = "Causa: Oler queso y beber agua de lluvia no purificada.",
    symptoms = "Síntomas: Muy incómodos para el paciente.",
    cure = "Cura: Se pincha la cabeza hinchada y luego se vuelve a inflar hasta el tamaño correcto con una máquina inteligente.",
  },
  serious_radiation = {
    name = "Radiación grave",
    cause = "Causa: Confundir isótopos de plutonio con chicle.",
    symptoms = "Síntomas: Los pacientes que padecen esta enfermedad se sienten muy, pero que muy mal.",
    cure = "Cura: Se debe dar al paciente una buena ducha descontaminadora.",
  },
  ruptured_nodules = {
    cause = "Causa: Tirarse de cabeza al agua fría.",
    symptoms = "Síntomas: Imposibilidad de sentarse cómodamente.",
    cure = "Cura: Dos cirujanos cualificados colocan ciertas partes con manos firmes.",
  },
  gastric_ejections = {
    cause = "Causa: Comida mejicana o india muy condimentada.",
    symptoms = "Síntomas: El paciente vomita la comida a medio digerir en cualquier momento.",
    cure = "Cura: Beber un preparado astringente especial para detener los vómitos.",
  },
  hairyitis = {
    cause = "Causa: Exposición prolongada a la luna.",
    symptoms = "Síntomas: Los pacientes experimentan un aumento del olfato.",
    cure = "Cura: Una máquina de electrólisis elimina el vello y cierra los poros.",
  },
  sweaty_palms = {
    cause = "Causa: Temer las entrevistas de trabajo.",
    symptoms = "Síntomas: Dar la mano al paciente es como coger una esponja empapada.",
    cure = "Cura: Un psiquiatra debe discutir a fondo con el paciente sobre esta enfermedad inventada.",
  },
  diag_x_ray = {
    name = "Diag. de rayos X",
  },
  the_squits = {
    cause = "Causa: Comer pizza que se ha encontrado debajo de la cocina.",
    symptoms = "Síntomas: ¡Agh! Seguro que te los puedes imaginar.",
    cure = "Cura: Una mezcla de sustancias viscosas preparada en la farmacia solidifica las tripas del paciente.",
  },
  slack_tongue = {
    name = "Lengua caída",
    cause = "Causa: Hablar sin parar sobre culebrones.",
    symptoms = "Síntomas: La lengua crece hasta cinco veces su tamaño original.",
    cure = "Cura: Se coloca la lengua en el acortalenguas y se elimina de forma rápida, eficaz y dolorosa.",
  },
  pregnancy = {
    cause = "Causa: Cortes de electricidad en zonas urbanas.",
    symptoms = "Síntomas: Comer por antojo con el consecuente malestar de estómago.",
    cure = "Cura: Se extrae al bebé en el quirófano, se limpia y se entrega al paciente.",
  },
  sleeping_illness = {
    cause = "Causa: Una glándula del sueño hiperactiva en el paladar.",
    symptoms = "Síntomas: Deseo imperioso de echarse una cabezadita en cualquier parte.",
    cure = "Cura: Una enfermera administra una elevada dosis de un poderoso estimulante.",
  },
  transparency = {
    cause = "Causa: Lamer el yogur que queda en las tapas de los envases.",
    symptoms = "Síntomas: La carne se transparenta y se ve horrible.",
    cure = "Cura: Tomar un preparado de agua enfriada y coloreada en la farmacia.",
  },
  broken_heart = {
    cause = "Causa: Alguien más rico, más joven y más delgado que el paciente.",
    symptoms = "Síntomas: Llorar y reír después de pasarse horas rompiendo fotos de las vacaciones",
    cure = "Cura: Dos cirujanos abren el pecho y miman con delicadeza el corazón mientras contienen la respiración.",
  },
  unexpected_swelling = {
    cause = "Causa: Cualquier cosa imprevista.",
    symptoms = "Síntomas: Inflamación.",
    cure = "Cura: Sólo puede reducirse la inflamación con una lanceta durante una operación que requiere dos cirujanos.",
  },
  discrete_itching = {
    cause = "Causa: Insectos diminutos con los dientes afilados.",
    symptoms = "Síntomas: Rascarse, lo que conduce a una inflamación de la parte afectada.",
    cure = "Cura: El paciente bebe un jarabe pegajoso que evita que la piel pique.",
  },
  third_degree_sideburns = {
    cause = "Causa: Anhelar con ansia los años 70.",
    symptoms = "Síntomas: Pelo largo, ropa ancha, zapatos con plataformas y mucho maquillaje.",
    cure = "Cura: El personal psiquiátrico debe, empleando técnicas actualizadas, convencer al paciente de que esta moda es horrible.",
  },
  uncommon_cold = {
    cause = "Causa: Pequeñas partículas de moco en el aire.",
    symptoms = "Síntomas: Mucosidad, estornudos y pulmones descoloridos.",
    cure = "Cura: Beber un gran trago de una medicina para la tos anormal que se fabrica en la farmacia con ingredientes especiales.",
  },
  heaped_piles = {
    cause = "Causa: Permanecer de pie junto a refrigeradores de agua.",
    symptoms = "Síntomas: El paciente se siente como si se sentara sobre una bolsa de canicas.",
    cure = "Cura: Una bebida agradable, aunque muy ácida, disuelve las hemorroides internas.",
  },
  golf_stones = {
    cause = "Causa: Inhalar el gas venenoso que contienen las pelotas de golf.",
    symptoms = "Síntomas: Delirar y sentir mucha vergüenza.",
    cure = "Cura: Dos cirujanos operan para extraer los cálculos.",
  },
  baldness = {
    cause = "Causa: Contar mentiras e inventar historias para ser famoso.",
    symptoms = "Síntomas: Tener la cabeza brillante y pasar vergüenza.",
    cure = "Cura: El pelo se cose a la cabeza del paciente con una dolorosa máquina.",
  },
  fake_blood = {
    cause = "Causa: El paciente suele ser la víctima de todas las bromas.",
    symptoms = "Síntomas: Fluido rojo en las venas que se evapora al contacto con la ropa.",
    cure = "Cura: Este problema sólo se resuelve con tratamiento psiquiátrico.",
  },
  gut_rot = {
    cause = "Causa: El jarabe para la tos, a base de whisky, de la Sra. McGuiver.",
    symptoms = "Síntomas: El paciente no tose, pero tampoco tiene paredes en el estómago.",
    cure = "Cura: Una enfermera administra una variada disolución de sustancias químicas para revestir el estómago.",
  },
  iron_lungs = {
    cause = "Causa: Contaminación urbana mezclada con restos de kebab.",
    symptoms = "Síntomas: Capacidad para aspirar fuego y gritar debajo del agua.",
    cure = "Cura: Dos cirujanos realizan una operación para eliminar las partes duras del pulmón en el quirófano.",
  },
  king_complex = {
    cause = "Causa: El espíritu del rey se introduce en la mente del paciente y se apodera de ella.",
    symptoms = "Síntomas: Calzar unos zapatos de ante teñidos y comer hamburguesas.",
    cure = "Cura: Un psiquiatra le dice al paciente lo ridículo o ridícula que está.",
  },
  tv_personalities = {
    cause = "Causa: Ver la televisión durante el día.",
    symptoms = "Síntomas: Tener la ilusión de presentar en la tele un programa de cocina.",
    cure = "Cura: Un psiquiatra experto debe convencer al paciente de que venda su televisor y se compre una radio.",
  },
}
room_descriptions = {
  staff_room = {
    [1] = "Sala de personal//",
    [2] = "Tu personal se cansa cuando realiza su trabajo. Necesitan esta sala para descansar y reponer energías. El personal cansado es más lento, pide más dinero, comete más errores y al final dimite. Merece la pena construir una sala para el personal que tenga muchos pasatiempos. Asegúrate de que hay sitio para varios miembros del personal al mismo tiempo. ",
  },
  gp = {
    [2] = "Esta es la consulta más importante de tu hospital. Los nuevos pacientes son enviados aquí para averiguar qué es lo que les pasa. Entonces, o se les hace otro diagnóstico o se les manda a una consulta donde puedan ser curados. Quizá quieras construir otra consulta si la primera tiene mucho trabajo. Cuanto más grande sea la consulta y cuantos más objetos pongas en ella, mayor prestigio tendrá el médico. Lo mismo sucede con todas las consultas abiertas.//",
  },
  blood_machine = {
    [3] = "El transfusiómetro requiere un médico. También necesita mantenimiento. ",
  },
  x_ray = {
    [2] = "Los rayos X fotografían el interior del paciente empleando una radiación especial para ayudar al personal a descubrir lo que le pasa.//",
    [3] = "La consulta de rayos X requiere un médico. También necesita mantenimiento. ",
  },
  ultrascan = {
    [1] = "Ultra escáner//",
  },
  training = {
    [1] = "Sala de formación//",
  },
  fracture_clinic = {
    [2] = "Los pacientes que tienen la desgracia de tener fracturas vienen aquí. El quitaescayolas emplea un potente láser industrial para cortar las escayolas más duras, causando al paciente sólo una pequeña molestia.//",
  },
  slack_tongue = {
    [2] = "Los pacientes a los que se les diagnostica lengua caída en la consulta serán enviados aquí para recibir tratamiento. El médico utilizará una máquina de alta tecnología para estirar la lengua y acortarla, con lo que el paciente volverá a estar sano.//",
  },
  jelly_vat = {
    [1] = "Baño gelatinoso//",
  },
  general_diag = {
    [1] = "Diagnosis general//",
  },
}

-- An override for the squits becoming the the squits see issue 1646
adviser.research.drug_improved_1 = "Tu departamento de investigación ha mejorado el medicamento para la %s."
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
tooltip.research_policy.research_progress = "Progreso del siguiente descubrimiento de esta categoría: %1%/%2%"

menu["player_count"] = "CANTIDAD DE JUGADORES"

menu_file = {
  load =    " (MAYUS+L) CARGAR   ",
  save =    " (MAYUS+S) GUARDAR   ",
  restart = " (MAYUS+R) REINICIAR  ",
  quit =    " (MAYUS+Q) SALIR   "
}
--These menus lack uppercase accented characters, so lowercase are a must.
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
  grant = "    CONCEDER  ",
  deny =  "    RECHAZAR  ",
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
  connect_debugger            = "  (CTRL + C) CONECTAR A SERVIDOR DBGp LUA  ",
  transparent_walls           = "  (X) PAREDES TRANSPARENTES  ",
  limit_camera                = "  LIMITAR CáMARA  ",
  disable_salary_raise        = "  DESACTIVAR SUBIDA DE SUELDO  ",
  make_debug_fax              = "  CREAR FAX DE DEPURACIóN  ",
  make_debug_patient          = "  CREAR PACIENTE DE DEPURACIóN  ",
  cheats                      = "  (F11) TRUCOS  ",
  lua_console                 = "  (F12) CONSOLA LUA  ",
  debug_script                = "  (MAYúS + D) EJECUTAR SCRIPT DE DEPURACIóN  ",
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
menu_player_count = {
  players_1 = "  1 JUGADOR  ",
  players_2 = "  2 JUGADORES  ",
  players_3 = "  3 JUGADORES  ",
  players_4 = "  4 JUGADORES  ",
}
adviser = {
  room_forbidden_non_reachable_parts = "Si colocas la habitación ahí bloquearás el acceso a ciertas partes del hospital.",
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
    research_screen_open_1 = "Para acceder a la pantalla de investigación, tienes que construir un departamento de investigación.",
    research_screen_open_2 = "No se pueden realizar investigaciones en este nivel.",
    researcher_needs_desk_1 = "Un investigador necesita una mesa en la que trabajar.",
    researcher_needs_desk_2 = "Tu investigador agradece que le hayas dado un descanso. Si pretendías tener a más personas investigando, tienes que dar a cada uno una mesa para que trabajen.",
    researcher_needs_desk_3 = "Cada investigador necesita una mesa para trabajar.",
    nurse_needs_desk_1 = "Cada enfermera necesita una mesa para trabajar.",
    nurse_needs_desk_2 = "Tu enfermera agradece que le hayas dado un descanso. Si pretendías tener a más personas trabajando en la enfermería, tienes que dar a cada una una mesa para que trabajen.",
    low_prices = "Estás cobrando muy poco por el uso de %s. Así atraerás a más personas a tu hospital, pero no te darán muchos beneficios.",
    high_prices = "Estás cobrando mucho por el uso de %s. Así tendrás muchos beneficios a corto plazo, pero harás que los pacientes dejen de venir.",
    fair_prices = "El precio de %s parece justo.",
    patient_not_paying = "¡Un paciente se ha ido sin pagar por %s porque es demasiado caro!",
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
dynamic_info.patient.actions.epidemic_vaccinated = "Ya no soy contagioso"

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
        "¡Su hospital es muy bueno! No es difícil mantenerlo sin limitaciones económicas, ¿eh?",
        "No soy economista, pero hasta yo podría dirigir este hospital, si usted me entiende...",
        "Un hospital muy bien cuidado. ¡Pero ojo con la crisis financiera! Ah... que a usted no le afecta.",
      },
      mediocre = {
        [1] = "Bueno, los he visto peores. Pero debería hacer algunas mejoras.",
        [2] = "¡Oh, cielos! No es un lugar agradable para ir si estás pachucho.",
        [3] = "Si le soy sincero, es un hospital normalucho. Francamente, yo esperaba más.",
      },
      very_bad = {
        [1] = "¡Vaya tugurio! Voy a intentar clausurarlo.",
        [2] = "Nunca he visto un hospital tan espantoso. ¡Qué vergüenza!",
        [3] = "Estoy horrorizado. ¡Y a esto lo llama un hospital! Me voy de cañas...",
      },
    }
  }
}

letter = {
  dear_player = "Estimado %s,",
  custom_level_completed = "¡Bien hecho! ¡Has completado todos los objetivos de este nivel personalizado!",
  return_to_main_menu = "¿Quieres volver al menú principal o seguir jugando?",
  campaign_level_completed = "¡Buen trabajo! Has superado este nivel, ¡pero aún no has acabado!\n ¿Te interesaría aceptar un puesto en el hospital %s?",
  campaign_completed = "¡Increíble! Has conseguido superar todos los niveles. Ya puedes relajarte y disfrutar mientras hablas de tus logros en los foros de Internet. ¡Buena suerte!",
  campaign_level_missing = "Parece que el siguiente nivel de esta campaña está desaparecido. (Nombre: %s)",
}

install = {
  title = "--------------------------------- Configuración de CorsixTH ---------------------------------",
  th_directory = "CorsixTH necesita una copia de los archivos de datos del Theme Hospital original (o de la demo) para poder funcionar. Utiliza el selector de debajo para localizar la carpeta de instalación de Theme Hospital.",
  ok = "Aceptar",
  exit = "Salir",
  cancel = "Cancelar",
}

misc.not_yet_implemented = "(aún no implementado)"
misc.no_heliport = "O no se han descubierto enfermedades, o no hay un helipuerto en este nivel.  Quizás te haga falta comprar una mesa de recepción y contratar a una recepcionista."

main_menu = {
  new_game = "Campaña",
  custom_campaign = "Campaña personalizada",
  custom_level = "Misión individual",
  continue = "Continuar partida",
  load_game = "Cargar partida",
  options = "Opciones",
  map_edit = "Editor de mapas",
  savegame_version = "Versión del guardado: ",
  version = "Versión: ",
  exit = "Salir",
}

tooltip.main_menu = {
  new_game = "Empezar el primer nivel de la campaña.",
  custom_campaign = "Juega una campaña creada por la comunidad.",
  custom_level = "Construir tu hospital en un nivel concreto.",
  continue = "Reanuda tu última partida guardada.",
  load_game = "Cargar una partida guardada.",
  options = "Ajustar la configuración.",
  map_edit = "Crear un mapa personalizado.",
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
  load_selected_level = "Comenzar",
}

tooltip.custom_game_window = {
  choose_game = "Haz clic en un nivel para ver más información sobre el mismo.",
  free_build = "Marca esta casilla si quieres jugar sin dinero ni condiciones para ganar o perder.",
  load_selected_level = "Cargar e iniciar el nivel seleccionado.",
}

custom_campaign_window = {
  caption = "Campaña personalizada",
  start_selected_campaign = "Comenzar campaña",
}

tooltip.custom_campaign_window = {
  choose_campaign = "Selecciona una campaña para ver más información sobre la misma.",
  start_selected_campaign = "Cargar el primer nivel de esta campaña.",
}

save_game_window = {
  caption = "Guardar partida (%1%)",
  new_save_game = "Nueva partida guardada",
}

tooltip.save_game_window = {
  save_game = "Sobrescribir guardado %s",
  new_save_game = "Introduce el nombre de la partida guardada.",
}

save_map_window = {
  caption = "Guardar mapa (%1%)",
  new_map = "Nuevo mapa",
}

tooltip.save_map_window = {
  map = "Sobrescribir el mapa %s.",
  new_map = "Introduce el nombre del mapa guardado.",
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
  custom_resolution = "Personalizar...",
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
  fullscreen = "Ejecuta el juego en pantalla completa o en una ventana.",
  fullscreen_button = "Pulsa aquí para activar el modo de pantalla completa.",
  resolution = "Cambia la resolución en la que funcionará el juego.",
  select_resolution = "Selecciona una nueva resolución.",
  width = "Introduce el ancho de la pantalla.",
  height = "Introduce la altura de la pantalla.",
  apply = "Aplica la resolución seleccionada.",
  cancel = "Vuelve sin cambiar la resolución.",
  audio_button = "Activa o desactiva todos los sonidos del juego.",
  audio_toggle = "Activa o desactiva el sonido.",
  customise_button = "Más opciones para personalizar tu experiencia de juego.",
  folder_button = "Opciones de carpetas.",
  language = "Selecciona el idioma de los textos.",
  select_language = "Selecciona el idioma del juego.",
  language_dropdown_item = "Seleccionar el idioma %s.",
  back = "Cierra la ventana de opciones.",
}

customise_window = {
  caption = "Opciones personalizadas",
  option_on = "Activado",
  option_off = "Desactivado",
  back = "Volver",
  movies = "Control de vídeos",
  intro = "Mostrar introducción",
  paused = "Construir en pausa",
  volume = "Tecla de volumen",
  aliens = "Pacientes alienígenas",
  fractured_bones = "Fracturas óseas",
  average_contents = "Contenidos habituales",
}

tooltip.customise_window = {
  movies = "Control global de vídeos, permite desactivar todos los vídeos.",
  intro = "Activa o desactiva el vídeo de introducción. Necesitas activar el control global de vídeos si quieres ver la introducción cada vez que arranques CorsixTH.",
  paused = "En Theme Hospital el jugador solo podía utilizar el menú superior si la partida estaba en pausa. CorsixTH funciona así de forma predeterminada, pero al activar esta opción se puede acceder a todo mientras el juego esté en pausa.",
  volume = "Si la tecla de bajar volumen abre también el botiquín, utiliza esta opción para cambiar el acceso directo a Mayúsculas + C.",
  aliens = "Debido a la falta de animaciones decentes disponibles, hemos hecho que los pacientes con ADN alienígena solo aparezcan en una emergencia. Para permitir que los pacientes con ADN alienígena puedan visitar tu hospital, desactiva esta opción.",
  fractured_bones = "Debido a una animación deficiente, hemos hecho que no existan pacientes con Fracturas óseas femeninas. Para permitir que las pacientes con Fracturas óseas visiten tu hospital, desactiva esta opción.",
  average_contents = "Activa esta opción si quieres que el juego recuerde los objetos adicionales que sueles añadir cuando construyes habitaciones.",
  back = "Cerrar este menú y volver al menú de opciones.",
}

folders_window = {
  caption = "Ubicación de carpetas",
  data_label = "Datos de TH",
  font_label = "Fuente",
  music_label = "MP3",
  savegames_label = "Part. guardadas",
  screenshots_label = "Capt. de pantalla",
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
  savegames_location = "La carpeta de partidas guardadas se ubica de forma predeterminada junto al archivo de configuración y se utilizará para almacenar las partidas guardadas. Si no te gusta, puedes seleccionar otra buscando la carpeta que quieres usar.",
  screenshots_location = "Las capturas de pantalla se guardan de forma predeterminada en una carpeta junto al archivo de configuración. Si no te gusta, puedes seleccionar otra buscando la carpeta que quieres usar.",
  music_location = "Selecciona una carpeta con tus archivos de música en formato MP3. Necesitas una carpeta ya existente, entonces podrás buscarla.",
  browse_data = "Buscar otra ubicación con una instalación de Theme Hospital. (Ubicación actual: %1%)",
  browse_font = "Buscar otro archivo de fuente de letra. (Ubicación actual: %1%)",
  browse_saves = "Buscar otra ubicación para tu carpeta de partidas guardadas. (Ubicación actual: %1%)",
  browse_screenshots = "Buscar otra ubicación para tu carpeta de capturas de pantalla. (Ubicación actual: %1%)",
  browse_music = "Buscar otra ubicación para tu carpeta de música. (Ubicación actual: %1%)",
  no_font_specified = "¡No se ha especificado una carpeta de fuentes!",
  not_specified = "¡No se ha especificado una carpeta!",
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
  option_on = "Activado",
  option_off = "Desactivado",
  difficulty = "Dificultad",
  easy = "Novato (Fácil)",
  medium = "Médico (Normal)",
  hard = "Especialista (Difícil)",
  tutorial = "Tutorial",
  start = "Comenzar",
  cancel = "Cancelar",
}

tooltip.new_game_window = {
  player_name = "Introduce el nombre que usará el juego para dirigirse a ti.",
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
  execute_code = "Ejecutar el código Lua que has introducido",
  close = "Cerrar la consola",
}

errors = {
  dialog_missing_graphics = "Los archivos de datos de la demo no contienen esta ventana.",
  save_prefix = "Error al guardar la partida: ",
  load_prefix = "Error al cargar la partida: ",
  no_games_to_contine = "No hay partidas guardadas.",
  load_quick_save = "Error, no existe el guardado rápido y por tanto no se puede cargar, pero tranquilo, que acabamos de generar uno para ti.",
  map_file_missing = "¡No se ha podido encontrar el archivo de mapa %s de este nivel!",
  minimum_screen_size = "Introduce un tamaño de pantalla como mínimo de 640x480.",
  unavailable_screen_size = "El tamaño de pantalla que has seleccionado no está disponible en el modo de pantalla completa.",
  alien_dna = "NOTA: Los pacientes alienígenas no tienen animaciones para sentarse, abrir puertas, llamar a puertas, etc. Por lo tanto, al igual que en Theme Hospital, para hacer estas cosas aparentarán cambiar a una imagen normal y luego volverán a su estado.  Los pacientes con ADN alienígena solo aparecerán si el archivo del nivel lo indica.",
  fractured_bones = "NOTA: La animación de las pacientes femeninas con Fracturas óseas no es perfecta.",
  could_not_load_campaign = "Error al cargar la campaña %s.",
  could_not_find_first_campaign_level = "No se ha encontrado el primer nivel de la campaña %s.",
}

warnings = {
  levelfile_variable_is_deprecated = "Aviso: El nivel %s contiene una definición de variable obsoleta en el archivo del nivel." ..
                                     "'%LevelFile' ha sido renombrado como '%MapFile'. Avisa al creador del mapa para que actualice el nivel.",
}

confirmation = {
  needs_restart = "Para cambiar este ajuste debes reiniciar CorsixTH. Se perderá todo el progreso que no hayas guardado. ¿Seguro que quieres continuar?",
  abort_edit_room = "Ahora mismo estás construyendo o editando una habitación. Si has colocado todos los objetos necesarios será terminada, de lo contrario se borrará. ¿Quieres continuar?",
  maximum_screen_size = "El tamaño de pantalla que has introducido es mayor que 3000x2000.  Es posible utilizar una resolución más grande, pero necesitarás un ordenador potente para que la velocidad de fotogramas sea aceptable. ¿Seguro que quieres continuar?",
  music_warning = "Nota: Necesitas el archivo smpeg.dll o el equivalente para tu sistema operativo, de lo contrario no tendrás música en el juego. ¿Quieres continuar?",
}

information = {
  custom_game = "Bienvenido a CorsixTH. ¡Diviértete con este mapa personalizado!",
  no_custom_game_in_demo = "La versión demo no permite jugar a mapas personalizados.",
  cannot_restart = "Esta partida personalizada se guardó antes de que se implementara la característica de reiniciar.",
  very_old_save = "Desde que empezaste a jugar en este nivel, el juego ha recibido muchas actualizaciones. Para asegurarte de que todas las características funcionen como es debido, deberías pensar en volver a empezar.",
  level_lost = {
    "¡Qué pena! Has fracasado en este nivel. ¡Ya tendrás más suerte la próxima vez!",
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
    "Todo hospital necesita una mesa de recepción y una consulta para empezar a funcionar. A partir de ahí depende del tipo de pacientes que visite tu hospital. Eso sí, una farmacia siempre es una buena opción.",
    "Las máquinas como el inflador necesitan mantenimiento. Contrata a un par de bedeles para que reparen tus máquinas o podrías herir a tus pacientes y a tu personal.",
    "Tu personal se cansará pasado un tiempo. Procura construir una sala de personal para que puedan relajarse.",
    "Coloca varios radiadores para mantener calentitos a tu personal y empleados o se enfadarán. Usa el mapa de la ciudad para buscar las zonas que no tienen calefacción en tu hospital.",
    "El nivel de cualificación de un médico influye en la calidad y la velocidad de sus diagnósticos. Si asignas un médico cualificado a tu consulta no necesitarás tantas consultas de diagnosis.",
    "Los principiantes y los médicos pueden mejorar su cualificación si un especialista les enseña en la sala de formación. Si el especialista tiene una cualificación especial (cirujano, psiquiatra o investigador), también enseñará sus conocimientos a sus alumnos.",
    "¿Has probado a meter el número de emergencias (112) en el fax? ¡Asegúrate de tener el sonido activado!",
    "Puedes ajustar algunos parámetros como la resolución y el idioma del juego en la ventana de opciones, que se encuentra tanto en el menú principal como dentro del juego.",
    "¿Has seleccionado el castellano, pero sigues viendo textos en inglés en algún lugar? ¡Avísanos de qué líneas de texto están en inglés para que podamos traducirlas!",
    "¡El equipo de CorsixTH busca refuerzos! ¿Te interesa programar, traducir o crear gráficos para CorsixTH? Contáctanos en nuestro foro, lista de correo o canal IRC (corsix-th en freenode).",
    "Si encuentras un fallo, puedes enviarnos un informe en nuestro registro de fallos: th-issues.corsix.org",
    "Cada nivel tiene unos requisitos concretos que debes conseguir antes de poder avanzar al siguiente nivel. Mira en la ventana de estado para ver como llevas los objetivos del nivel.",
    "Si quieres editar o quitar una habitación ya existente, puedes hacerlo con el botón Editar habitación, en la barra de herramientas inferior.",
    "Cuando tengas muchos pacientes esperando, puedes averiguar quienes están esperando para una habitación en concreto pasando el cursor por encima de la habitación.",
    "Pulsa en la puerta de una habitación para ver su cola. Aquí puedes afinar ciertas cosas, como el orden la cola o mandar a un paciente hacia otra habitación.",
    "El personal que no esté contento pedirá aumentos de sueldo con frecuencia. Asegúrate de que tu personal trabaja en un entorno cómodo para evitar que esto ocurra.",
    "Los pacientes tendrán sed mientras esperan en tu hospital, ¡y más si subes la calefacción! Coloca máquinas de bebidas en lugares estratégicos para ganar un dinerillo extra.",
    "Puedes cancelar el progreso del diagnóstico de un paciente y adivinar la cura si ya has descubierto la enfermedad. Ten en cuenta que esto aumentará el riesgo de darle el tratamiento equivocado, lo que matará al paciente.",
    "Las emergencias pueden ser una buena forma de ganar un dinerillo extra, siempre y cuando tengas la capacidad suficiente para ocuparte de los pacientes de la emergencia a tiempo.",
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
    epidemic = "Generar un paciente contagioso",
    toggle_infected = "Mostrar/ocultar iconos de infección",
    create_patient = "Crear un paciente",
    end_month = "Fin de mes",
    end_year = "Fin del año",
    lose_level = "Perder el nivel",
    win_level = "Ganar el nivel",
    increase_prices = "Subir precios",
    decrease_prices = "Bajar precios",
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
    epidemic = "Crea un paciente contagioso que podría provocar una epidemia.",
    toggle_infected = "Muestra u oculta los iconos de infección para la epidemia activa.",
    create_patient = "Crea un paciente en el borde del mapa.",
    end_month = "Avanza hasta el fin del mes actual.",
    end_year = "Avanza hasta el final del año actual.",
    lose_level = "Hace que pierdas el nivel actual.",
    win_level = "Hace que ganes el nivel actual.",
    increase_prices = "Aumenta los precios en un 50% (200% máximo).",
    decrease_prices = "Reduce los precios en un 50% (50% mínimo).",
  }
}

introduction_texts = {
  demo =
    "¡Bienvenido al hospital de demostración!" ..
    "Por desgracia, la demo sólo contiene este nivel. ¡Pero tiene más que suficiente para distraerte un buen rato!" ..
    "Te enfrentarás a varias enfermedades que deberás curar construyendo varias salas. De vez en cuando pueden aparecer emergencias. Necesitarás investigar varios tipos de consultas utilizando una consulta de investigación." ..
    "Tu objetivo es ganar 100.000 dólares, una reputación de 700, que tu hospital tenga un valor de 70.000 dólares y que hayas curado al menos al 75% de tus pacientes." ..
    "Procura que tu reputación no caiga por debajo de 300 y no mates a más del 40% de tus pacientes o perderás el nivel." ..
    "¡Suerte!",
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
  task = "Lista de tareas: Pulsa en una tarea para abrir la ventana del personal asignado y desplázate hasta la posición de la tarea.",
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

map_editor_window = {
  pages = {
    inside = "Interior",
    outside = "Exterior",
    foliage = "Vegetación",
    hedgerow = "Setos",
    pond = "Estaque",
    road = "Camino",
    north_wall = "Muro norte",
    west_wall = "Muro oeste",
    helipad = "Helipuerto",
    delete_wall = "Borrar muros",
    parcel_0 = "Parcela 0",
    parcel_1 = "Parcela 1",
    parcel_2 = "Parcela 2",
    parcel_3 = "Parcela 3",
    parcel_4 = "Parcela 4",
    parcel_5 = "Parcela 5",
    parcel_6 = "Parcela 6",
    parcel_7 = "Parcela 7",
    parcel_8 = "Parcela 8",
    parcel_9 = "Parcela 9",
    camera_1 = "Cámara 1",
    camera_2 = "Cámara 2",
    camera_3 = "Cámara 3",
    camera_4 = "Cámara 4",
    heliport_1 = "Helipuerto 1",
    heliport_2 = "Helipuerto 2",
    heliport_3 = "Helipuerto 3",
    heliport_4 = "Helipuerto 4",
    paste = "Pegar zona",
  }
}

--------------------------------  UNUSED  -----------------------------------
------------------- (kept for backwards compatibility) ----------------------

options_window.change_resolution = "Cambiar resolución"
tooltip.options_window.change_resolution = "Cambia la resolución de la ventana utilizando la dimensión indicada a la izquierda."
