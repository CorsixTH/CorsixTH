--[[ Copyright (c) 2010 Manuel "Roujin" Wolf, "Fabiomsouto"
Copyright (c) 2011 Sérgio "Get_It" Ribeiro
Copyright (c) 2012 <Filipe "Aka" Carvalho>

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


Language(utf8 "Português", "Portuguese", "pt", "pt")
Inherit("english")

-------------------------------  OVERRIDE  ----------------------------------
adviser.warnings.money_low = "Estás a ficar sem dinheiro!" -- Funny. Exists in German translation, but not existent in english?
-- TODO: tooltip.graphs.reputation -- this tooltip talks about hospital value. Actually it should say reputation.
-- TODO: tooltip.status.close -- it's called status window, not overview window.

-- The originals of these two contain one space too much
fax.emergency.cure_not_possible_build = "Vais precisar de construir %s"
fax.emergency.cure_not_possible_build_and_employ = "Vais precisar de construir um %s e empregar um %s"

-- Improve tooltips in staff window to mention hidden features
tooltip.staff_window.face = "A cara desta pessoa - clique para abrir o ecrã de gestão de pessoal"
tooltip.staff_window.center_view = "Clique esquerdo para ir para onde está a pessoa, clique direito para navegador através dos funcionários"

-- These strings are missing in some versions of TH (unpatched?)
confirmation.restart_level = "Tem a certeza que deseja reiniciar este nível?"

-------------------------------  NEW STRINGS  -------------------------------
confirmation.maximum_screen_size = "A resolução de ecrã que escolheu é maior que 3000 x 2000. Resoluções mais altas são possíveis, mas requerem melhor hardware de forma a manter uma taxa de fotogramas (FPS) jogável. De certeza que deseja continuar?"
confirmation.music_warning = "Antes de escolher usar mp3 para a música dentro do jogo, necessita de ter o smpeg.dll ou equivalente para o seu sistema operativo, caso contrário, não terá música no jogo. Actualmente não existe equivalente para sistemas 64bit. Deseja continuar?"
menu_options_wage_increase.deny = "    NEGAR "
menu_options_wage_increase.grant = "    PERMITIR "
tooltip.options_window.audio_button = "Ligar ou desligar todo o som do jogo"
tooltip.options_window.audio_toggle = "Ligar ou desligar"
tooltip.options_window.folder_button = "Opções de pastas"
tooltip.options_window.customise_button = "Mais opões que pode alterar para personalizar a sua experiência de jogo."
tooltip.update_window.download = "Vá para a página de transferências para a última versão de CorsixTH"
tooltip.update_window.ignore = "Ignorar esta actualização agora. Será notificado de novo na próxima vez que inicializar CorsixTH"
tooltip.folders_window.browse_font = "Procurar outro tipo de letra (localização actual: %1% )"
tooltip.folders_window.screenshots_location = "Por defeito, as capturas de ecrã são armazenadas numa pasta junto do ficheiro de configuração. Caso isto não seja apropriado, pode escolher a sua própria, simplesmente indique qual a pasta que deseja utilizar."
tooltip.folders_window.reset_to_default = "Reinicializar a directoria para a localização por defeito"
tooltip.folders_window.back = "Fechar este menu e voltar às definições."
tooltip.folders_window.music_location = "Escolha a localização dos seus ficheiros mp3. A pasta já deve ter sido criada, e agora escolha o directório que acabou de criar."
tooltip.folders_window.font_location = "Localização de um tipo de letra capaz de mostrar caracteres Unicode requeridos pela sua língua. Se isto não for especificado, não será capaz de escolher línguas que necessitam de mais caracteres que o jogo original consegue fornecer. Exemplo: Russo e Chinês."
tooltip.folders_window.savegames_location = "Por defeito, os jogos gravados são armazenados numa pasta junto do ficheiro de configuração. Caso isto não seja apropriado, pode escolher a sua própria, simplesmente indique qual a pasta que deseja utilizar."
tooltip.folders_window.browse_data = "Escolha outra localização da instalação do Theme Hospital (localização actual: %1% )"
tooltip.folders_window.browse = "Escolha a localização da pasta"
tooltip.folders_window.browse_screenshots = "Escolha outra localização para a pasta das capturas de ecrã (Localização actual: %1%) "
tooltip.folders_window.browse_music = "Escolha outra localização para a pasta da música (Localização actual: %1%) "
tooltip.folders_window.no_font_specified = "Nenhum tipo de letra especificado!"
tooltip.folders_window.not_specified = "Nenhuma pasta especificada!"
tooltip.folders_window.browse_saves = "Escolha outra localização para a pasta dos jogos gravados (Localização actual: %1%) "
tooltip.folders_window.default = "Localização por defeito"
tooltip.folders_window.data_location = "O directório da instalação do Theme Hospital original, que é necessário para correr o CorsixTH"
tooltip.customise_window.aliens = "Devido à falta de animações apropriadas, colocamos por defeito que pacientes com ADN Extraterrestre só possam surgir numa emergência. Para permitir que estes pacientes possam visitar o hospital de outra forma, desligue esta opção."
tooltip.customise_window.average_contents = "Se quer que o jogo lhe lembre que objectos adicionais costuma adicionar quando cria uma sala, ligue esta opção."
tooltip.customise_window.back = "Fechar este menu e voltar às definições."
tooltip.customise_window.movies = "Controle geral de vídeos, isto irá permitir desligar todos os vídeos"
tooltip.customise_window.fractured_bones = "Devido a uma má animação colocamos por defeito que não existem pacientes femininas com Ossos Partidos. De forma a permitir que pacientes femininas com Ossos Partidos visitem o hospital, desligue esta opção."
tooltip.customise_window.volume = "Se o botão para baixar o volume está a abrir também o livro médico, ligue esta opção para mudar o atalho para o livro médico para Shift + C"
tooltip.customise_window.intro = "Ligar ou desligar o vídeo de introdução, o controle geral de vídeos tem que estar ligado se quer ver a introdução cada vez que começa o CorsixTH"
tooltip.customise_window.paused = "No Theme Hospital o jogador apenas podia utilizar o menu de topo se o jogo estivesse pausado. Esta é também a opção por defeito no CorsixTH, mas ao activar esta opção, tudo é permitido com o jogo pausado."
update_window.caption = "Actualização Disponível!"
update_window.new_version = "Nova Versão:"
update_window.current_version = "Versão Actual:"
update_window.download = "Ir à página de transferências"
update_window.ignore = "Saltar e ir para o menu principal"
errors.fractured_bones = "AVISO: A animação para pacientes femininas com Ossos Partidos não é perfeita."
errors.alien_dna = "AVISO: Não existem animação para pacientes Extraterrestres a sentarem-se, abrir ou bater em portas, etc. Então, como no Theme Hospital, para executarem estas animações eles ficam com um aspecto normal, e depois voltam ao aspecto original. Pacientes com ADN Extraterrestre só irão aparecer se estiver previsto no nível."
errors.load_quick_save = "Erro, não foi possível carregar o quick save já que não existe. Nada de preocupações, já que criamos agora um para si!"
folders_window.data_label = "Dados TH"
folders_window.music_location = "Escolha a directoria que usar para a sua música"
folders_window.music_label = "MP3's"
folders_window.new_th_location = "Aqui pode especificar uma nova pasta de instalação do Theme Hospital. Assim que escolher a nova directoria, o jogo irá reiniciar."
folders_window.caption = "Localizações de pastas"
folders_window.screenshots_label = "Capturas de ecrã"
folders_window.font_label = "Tipos de letra"
folders_window.savegames_label = "Jogos gravados"
folders_window.back = "Retroceder"
folders_window.savegames_location = "Escolha a directoria que usar para jogos gravados"
folders_window.screenshots_location = "Escolha a directoria que usar para capturas de ecrã"
customise_window.average_contents = "Itens comuns"
customise_window.option_on = "Ligado"
customise_window.paused = "Construir com o jogo pausado"
customise_window.option_off = "Desligado"
customise_window.intro = "Reproduzir vídeo de introdução"
customise_window.caption = "Definições Personalizadas"
customise_window.back = "Retroceder"
customise_window.movies = "Controle Geral de Vídeos"
customise_window.volume = "Atalho para baixar o volume"
customise_window.aliens = "Pacientes Extraterrestres"
customise_window.fractured_bones = "Ossos Partidos"
options_window.folder = "Pastas"
options_window.customise = "Personalizar"
options_window.audio = "Som Geral"
menu_options.twentyfour_hour_clock = "  RELÓGIO DE 24 HORAS  "
menu_options.wage_increase = "  EXIGÊNCIAS SALARIAIS"
install.ok = "OK"
install.cancel = "Cancelar"
adviser.research.drug_improved_1 = "A droga para %s foi melhorada pelo Departamento de Pesquisa"
adviser.warnings.no_desk_7 = "Já construiu o balcão de atendimento, então que tal contratar uma recepcionista? Não irá atender clientes até que resolva isto!"
adviser.warnings.researcher_needs_desk_1 = "Um Investigador precisa de ter uma secretária onde trabalhar."
adviser.warnings.no_desk_6 = "Já tem a recepcionista, então que tal construir uma balcão de atendimento para ela trabalhar?"
adviser.warnings.nurse_needs_desk_1 = "Cada Enfermeira necessita de uma secretária onde trabalhar."
adviser.warnings.researcher_needs_desk_2 = "O seu Investigador está satisfeito que o tenha deixado descansar um pouco. Se quer ter mais pessoal a fazer pesquisa, então precisa de dar uma secretária a cada um deles."
adviser.warnings.no_desk_5 = "Está na hora, devem estar a chegar pacientes a qualquer momento!"
adviser.warnings.no_desk_4 = "Uma recepcionista precisa de ter o seu posto de trabalho para atender os pacientes assim que chegam."
adviser.warnings.researcher_needs_desk_3 = "Cada Investigador necessita de uma secretária onde trabalhar."
adviser.warnings.cannot_afford_2 = "Não tem dinheiro suficiente no banco para fazer essa compra!"
adviser.warnings.nurse_needs_desk_2 = "A sua Enfermeira está satisfeita que a tenha deixado descansar um pouco. Se quer ter mais que uma a trabalhar na enfermaria, então precisa de dar uma secretária a cada uma delas."
object.litter = "Lixo"
tooltip.objects.litter = "Lixo: Deitado fora por um paciente porque não encontrou um caixote do lixo onde o colocar."

menu_options.lock_windows = "  BLOQUEAR JANELAS  "
menu_options_game_speed.pause = "  PAUSA  "

menu_debug = {
  transparent_walls           = "  PAREDES TRANSPARENTES  ",
  limit_camera                = "  LIMITAR CAMARA  ",
  disable_salary_raise        = "  DESACTIVAR AUMENTO DOS SALÁRIOS  ",
  make_debug_patient          = "  MAKE DEBUG PATIENT  ",
  spawn_patient               = "  GERAR PACIENTE  ",
  make_adviser_talk           = "  MAKE ADVISER TALK  ",
  show_watch                  = "  MOSTRAR RELÓGIO  ",
  create_emergency            = "  CRIAR EMERGENCIA  ",
  place_objects               = "  COLOCAR OBJECTOS  ",
  dump_strings                = "  DUMP DAS STRINGS  ",
  map_overlay                 = "  OVERLAY DO MAPA  ",
  sprite_viewer               = "  VISUALIZAR SPRITES  ",
}
menu_debug_overlay = {
  none                        = "  NENHUM  ",
  flags                       = "  FLAGS  ",
  positions                   = "  POSIÇOES  ",
  byte_0_1                    = "  BYTE 0 & 1  ",
  byte_floor                  = "  BYTE FLOOR  ",
  byte_n_wall                 = "  BYTE N WALL  ",
  byte_w_wall                 = "  BYTE W WALL  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  PARCEL  ",
}
adviser.room_forbidden_non_reachable_parts = "Colocar o espaço neste sítio bloquearia o acesso a zonas do hospital."

dynamic_info.patient.actions.no_gp_available = "À espera que seja construidos um consultório de CG."
dynamic_info.staff.actions.heading_for = "Indo para %s"

misc.not_yet_implemented = "(not yet implemented)"
misc.no_heliport = "Hm... Ou não foram desocbertas novas doenças ou não existe um heliporto neste mapa."

main_menu = {
  new_game = "Novo jogo",
  custom_level = "Nível Personalizado",
  load_game = "Carregar Jogo",
  options = "Opçoes",
  exit = "Sair",
}

tooltip.main_menu = {
  new_game = "Começar um jogo de raíz",
  custom_level = "Construir o meu hospital",
  load_game = "Carregar um jogo",
  options = "Ajustar preferencias",
  exit = "Nao, por favor, nao saias!",
}

load_game_window = {
  back = "Voltar",
}

tooltip.load_game_window = {
  load_game_number = "Carregar o jogo %d",
  load_autosave = "Carregar o jogo gravado automaticamente",
  back = "Fechar a janela de carregamento",
}


errors = {
  dialog_missing_graphics = "Desculpa, mas a versão de demonstração não tem este diálogo!",
  save_prefix = "Erro durante a gravação do jogo: ",
  load_prefix = "Erro durante o carregamento do jogos: ",
}

totd_window = {
  tips = {
    "Todos os hospitais precisam de uma recepção e de um consultório de CG para começar. Depois disso, depende do tipo de pacientes que recebes. Uma farmácia é sempre uma boa escolha, no entanto.",
    "Máquinas como a Bomba de Encher Cabeças precisam de manutenção. Contrata um ou dois funcionários para reparar as tuas máquinas, ou arriscas-te a que o pessoal ou os pacientes se aleijem quando elas avariarem.",
    "Após algum tempo, o teu pessoal vai ficar cansado. Constrói um Quarto do Pessoal, para que eles possam relaxar.",
    "Coloca radiadores em quantidade suficiente para que o teu pessoal e pacientes estejam quentinhos... caso contrário irao ficar aborrecidos!",
    "O nível de perícia de um médico influencia a qualidade e velocidade do seu diagnóstico. Coloca um médico com perícia nas salas de CGs, e não precisarás de tantas salas de diagnóstico.",
    "Médicos júniores e regulares podem aumentar a sua perícia se aprenderem com um consultante numa Sala de Treino. Se o consultante for especialista (cirurgiao, psiquiatra ou investigador), também ensinará a sua especialização aos seus pupilos.",
    "Já tentaste escrever o número de emergência (112) no fax? Não te esqueças de ligar as colunas!",
    "O menu de opçoes ainda não está implementado, mas podes ajustar algumas preferencias tais como resoluçao e língua no ficheiro config.txt na pasta do jogo.",
    "Seleccionaste outra linguagem além do Ingles, mas ves Ingles em todo o lado? Ajuda-nos a traduzir esse texto!",
    "A equipa do CorsixTH está à procura de reforços! Estás interessado em programar, traduzir ou criar arte gráfica para o CorsixTH? Contacta-nos no fórum, IRC (corsix-th no freenode) ou via Mailing List.",
    "Se encontrares um bug, diz-nos em: th-issues.corsix.org",
    "Tens que cumprir certos requisitos para poder avançar de nível. Consulta a tua janela de status para veres o progresso em relaçao aos objectivos do nível.", -- dicas juntas
    "Se quiseres alterar ou remover alguma sala existente,utiliza o botao editar na barra de ferramentas em baixo no teu ecra.",
    "Se tiveres muitos pacientes na fila de espera, podes saber rapidamente quais estao à espera de uma determinada sala passando com o cursor por cima desta.",
    "Clica numa porta para ver a lista de espera.Podes alterar a ordem dos pacientes ou mandá-los para outra sala.",
    "Staffs descontentes irao pedir aumentos de salário frequentemente , assegura que tens um bom ambiente de trabalho para isto não acontecer!",
    "Os pacientes ficarao com sede enquanto esperam no hospital,ainda mais se os radiadores estiverem muito quentes.Coloca máquinas de bebidas em locais estratégicos para ganhares mais uns trocos.",
    "Podes abortar o processo de diagnóstico para um paciente e tentar adivinhar a cura caso já tenhas descoberto a doença. Cuidado que este processo pode aumentar o risco de uma cura errada levando à morte do paciente.",
    "Emergencias sao uma boa forma de ganhar algum dinheiro extra,garante que o teu hospital tem condiçoes para as completar.",
  },
  previous = "Dica anterior",
  next = "Próxima dica",
}

tooltip.totd_window = {
  previous = "Mostrar dica anterior",
  next = "Mostrar a próxima dica",
}


debug_patient_window.caption = "Debug Paciente"



totd_window = {
  tips = {
    "Tens que cumprir certos requisitos para poder avançar de nível. Consulta a tua janela de status para veres o progresso em relaçao aos objectivos do nível.",
    "Se quiseres alterar ou remover alguma sala existente,utiliza o botao editar na barra de ferramentas em baixo no teu ecra.",
    "Se tiveres muitos pacientes na fila de espera, podes saber rapidamente quais estao à espera de uma determinada sala passando com o cursor por cima desta.",
    "Clica numa porta para ver a lista de espera.Podes alterar a ordem dos pacientes ou mandá-los para outra sala.",
    "Staffs descontentes irao pedir aumentos de salário frequentemente , assegura que tens um bom ambiente de trabalho para isto não acontecer!",
    "Os pacientes ficarao com sede enquanto esperam no hospital,ainda mais se os radiadores estiverem muito quentes.Coloca máquinas de bebidas em locais estratégicos para ganhares mais uns trocos.",
    "Podes abortar o processo de diagnóstico para um paciente e tentar adivinhar a cura caso já tenhas descoberto a doença. Cuidado que este processo pode aumentar o risco de uma cura errada levando à morte do paciente.",
    "Emergencias sao uma boa forma de ganhar algum dinheiro extra,garante que o teu hospital tem condiçoes para as completar.",
  },
}



tooltip.casebook.cure_requirement.hire_staff = "Precisas de contratar alguém para fazer este tratamento."
tooltip.casebook.cure_type.unknown = "Ainda não sabes tratar esta doença."
tooltip.information.close = "Fecha o diálogo de informação"
tooltip.load_game_window.load_game = "Ler jogo: %s"



tooltip = {
  message = {
    button = "Clica com o botão esquerdo para abrir a mensagem.",
    button_dismiss = "Click esquerdo para abrir a mensagem,click direito para apagar",
  },


  custom_game_window = {
    start_game_with_name = "Ir para o nível %s",
  },


  cheats_window = {
    close = "Fecha a janela dos truques",

    cheats = {
      end_month = "Salta para o final do mês.",
      create_patient =  "Cria um paciente no mapa.",
      money = "Adiciona 10000 à tua conta bancária",
      emergency = "Cria uma emergência",
      win_level = "Vence o nível.",
      lose_level = "Perde o nível.",
      vip = "Cria um VIP.",
      all_research = "Completa toda a pesquisa.",
      end_year = "Salta para o final do ano.",
      },
    },





  menu_list_window = {
    save_date = "Coloca a lista por data de modificação.",
    name = "Coloca a lista por nome.",
    back = "Fecha esta janela.",
    },


  new_game_window = {
    hard = "Se estás habituado a este tipo de jogos e procuras um desafio escolhe esta opçao.",
    cancel = "Oh mas eu não queria começar um jogo de novo!",
    tutorial = "Se precisas de umas dicas para começar a jogar,marca esta caixa.",
    easy = "Se és novo em jogos de simulaçoes,esta é a opçao para ti.",
    medium = "Se já te sentes à vontade tenta a opção média!",
    },


  save_game_window = {
    new_save_game = "Nome para salvar o jogo.",
    save_game = "Gravar por cima da gravação? %s",
    },


  calls_dispatcher = {
    assigned = "Esta caixa estrá marcada, se alguém esttiver a tratar da tarefa correspondente.",
    task = "Lista de tarefas - Clica em tarefas para abrir as tarefas atribuídas ao staff e encontrares a localização de determinada tarefa.",
    close = "Fecha a janela de diálogo do expedidor de chamadas.",
    },


  research_policy = {
    research_progress = "Progresso em relação à próxima descoberta: %1%/%2%",
    no_research = "Não está a ser feita nenhuma pesquisa de momento.",
    },


    lua_console = {
    textbox = "Coloca aqui o código Lua para executar",
    execute_code = "Executa o código colocado.",
    close =  "Fecha a consola.",
    },


    fax = {
      close = "Fecha esta janela sem apagar a mensagem.",
    },


  options_window = {
    fullscreen_button = "Clica para modo de tela cheia",
    original_path = "A directoria da instalaçao original de Theme Hospital",
    browse = "Procura outra localizaçao da instalaçao original. %1%",
    change_resolution = "Altera a resoluçao da janela para as dimensoes colocadas à esquerda",
    height = "Coloca a altura desejada.",
    width = "Coloca a largura desejada.",
    language = "Escolhe %s como a tua linguagem.",
    back = "Fecha a janela de opçoes.",
    },

}



custom_game_window.caption = "Jogo Customizado"



cheats_window = {
  cheats = {
    end_month = "Fim do Mês",
    create_patient = "Criar Paciente",
    money = "Truque para Dinheiro",
    emergency = "Criar emergência",
    win_level = "Vencer nível",
    lose_level = "Perder nível",
    vip = "Criar VIP",
    all_research = "Pesquisa Completa",
    end_year = "Fim do Ano",
    },

    close = "Fechar",
    caption = "Truques",

  cheated = {
    no = "Truques usados?: Nao",
    yes = "Truques usados?: Sim",
    },

    warning = "Aviso:Se utilizares truques não irás ganhar pontos de reputação no final do nível!",
}



errors = {
  unavailable_screen_size = "Esta resolução não está disponível no modo de tela cheia.",
  maximum_screen_size = "Resolução máxima de 3000x2000.",
  map_file_missing = "Não foi encontrado o ficheiro do mapa %s para este nível!",
  minimum_screen_size = "Resolução mínima de 640x480.",
}



date_format.daymonth = "%1% - %2% -"



menu_debug = {
  lua_console = "  (F12) CONSOLA LUA",
  make_debug_fax = "  DEBUG FAX",
  calls_dispatcher = "  CHAMAR EXPEDIDOR",
  cheats = "  (F11) TRUQUES",
  dump_gamelog = "  (CTRL+D) CRIAR LOG DO JOGO",
  jump_to_level = "  SALTAR PARA OUTRO NIVEL",
}


menu_options = {
  edge_scrolling = "  EDGE SCROLLING  ",
  settings = "  PREFERENCIAS  ",
}



lua_console = {
  execute_code = "Executar",
  close = "Fechar",
}



install= {
  exit = "Sair",
  th_directory = "CorsixTH precisa dos ficheiros de dados da instalação original de Theme Hospital(ou demo) para funcionar. Localize a sua instalação atráves da caixa em baixo.",
  title = "--------------------------------- Instalação CorsixTH  ---------------------------------",
}



load_game_window.caption = "Ler Jogo"



adviser = {
 cheats = {
    th_cheat = "Parabéns batoteiro! Acabaste de desbloquear os truques!",
    hairyitis_cheat = "Activado cheat da doença Olfatis",
    roujin_on_cheat = "Activado o desafio Roujin! Boa sorte...",
    crazy_on_cheat = "Oh não! Os teus médicos estão malucos!",
    bloaty_off_cheat = "Desactivado truque das Cabeças Gigantes!",
    bloaty_cheat = "Activado truque das Cabeças Gigantes!",
    crazy_off_cheat = "Ufa... os teus médicos voltaram ao normal.",
    roujin_off_cheat = "Desafio Roujin desactivado.",
    hairyitis_off_cheat = "Desactivado truque da doença Olfatis",
    },


  warnings = {
    no_desk_2 = "Bom trabalho! Deve ser um recorde mundial: quase um ano completo e não há pacientes! Se desejas continuar a gerir este hospital tens que contratar uma recepcionista e construir uma recepção para receberes os pacientes!",
    no_desk = "Constrói uma recepçao e uma recepcionista para começar!",
    no_desk_1 = "Se queres que os pacientes venham ao teu hospital vais precisar de uma recepçao e uma recepcionista!",
    },
}


calls_dispatcher = {
  repair = "Reparar %s",
  summary = "%d Chamadas; %d atribuídas",
  close = "Fechar",
  watering = "Regar @ %d,%d",
  staff = "%s - %s ",
}

information = {
  level_lost = {
    "Que chatice! Perdeste. Mais sorte para a próxima!",
    "Razões da derrota:",
    reputation = "A tua reputação ficou abaixo de %d.",
    balance = "A tua conta bancària ficou abaixo de %d.",
    percentage_killed = "Mataste mais do que %d por cento dos pacientes.",
  },

  cannot_restart = "Infelizmente este jogo customizado foi gravado antes da implementação da função de reinício.",
  custom_game = "Bem-vindo ao CorsixTH. Diverte-te neste mapa customizado!",
}


new_game_window = {
  hard = "Consultor (Difícil)",
  cancel = "Cancelar",
  tutorial = "Tutorial ",
  easy = "Junior (Fácil)",
  medium = "Doutor (Médio)",
}


options_window = {
  fullscreen = "Tela cheia",
  cancel = "Cancelar",
  browse = "Procurar...",
  width = "Largura",
  height = "Altura",
  new_th_directory = "Aqui podes escolher uma nova localizaçao da instalaçao de Theme Hospital,assim que o fizeres o jogo será reiniciado.",
  change_resolution = "Alterar resoluçao",
  back = "Voltar",
}


menu_list_window = {
  save_date = "Modificado",
  name = "Nome",
  back = "Voltar",
}


save_game_window = {
  caption = "Gravar jogo",
  new_save_game = "Nova gravaçao",
}



fax.emergency.num_disease_singular = "Existe uma pessoa com %s e necessita de atenção imediata!"



fax.choices = {
  decline_new_level = "Continuar a jogar",
  accept_new_level = "Avançar para o nível seguinte",
  return_to_main_menu = "Voltar para o menu principal",
}



menu_debug_overlay.heat = "  TEMPERATURA  "


confirmation.abort_edit_room = "Estás a construir ou a editar uma sala. Se todos os objectos necessários estiverem colocados a sala estará terminada, caso contrário será eliminada. Continuar?"
confirmation.needs_restart = "Estas alterações requerem que reinicies o jogo,O progresso não gravado será perdido. Desejas continuar?"


dynamic_info.staff.actions.fired = "Despedido"



introduction_texts.demo = {
  "Bem-vindo ao hospital do demo!",
  "Infelizmente este demo só tem este nível.Contudo existe aqui muito trabalho para te manter ocupado!",
  "Encontrarás várias doenças que requerem salas diferentes para os seus tratamentos.Ao longo do tempo irão ocorrer algumas emergências e precisarás de descobrir novos tratamentos atráves da sala de pesquisa.",
  "O teu objectivo é ganhar 100,000$,ter um hospital avaliado em 70,000$,uma reputação de 700 e uma cura de 75% dos pacientes.",
  "Garante que a tua reputação não cai abaixo de 300 e que não mates 40% dos teus pacientes senão perderás o nível.",
  "Boa sorte!",
}



letter = {
  custom_level_completed = "Bom trabalho!Completaste todos os objectivos deste nível!",
  dear_player = "Caro %s",
  return_to_main_menu = "Desejas regressar ao menu principal ou continuar a jogar?",
}

staff_class = {
  nurse                 = "Enfermeira",
  doctor                = "Doutor",
  handyman              = "Contínuo",
  receptionist          = "Recepcionista",
  surgeon               = "Cirurgião",
}

-- Staff titles
-- these are titles used e.g. in the dynamic info bar
staff_title = {
  receptionist          = "Recepcionista",
  general               = "General", -- unused?
  nurse                 = "Enfermeira",
  junior                = "Junior",
  doctor                = "Doutor",
  surgeon               = "Cirurgião",
  psychiatrist          = "Psiquiatra",
  consultant            = "Consultor",
  researcher            = "Pesquisador",
}

staff_list = {
  morale       = "MORAL",
  tiredness    = "CANSAÇO",
  skill        = "QUALIFICAÇOES",
  total_wages  = "SALÁRIO",
}


-- Objects
object = {
  desk                  = "Secretária",
  cabinet               = "Arquivador",
  door                  = "Porta",
  bench                 = "Banco",
  table1                = "Mesa", -- unused object
  chair                 = "Cadeira",
  drinks_machine        = "Máquina de Bebidas",
  bed                   = "Cama",
  inflator              = "Inflador",
  pool_table            = "Mesa de Bilhar",
  reception_desk        = "Recepçao",
  table2                = "Mesa", -- unused object & duplicate
  cardio                = "Cardio",
  scanner               = "Scanner",
  console               = "Consola",
  screen                = "Ecra",
  litter_bomb           = "Bomba de lixo",
  couch                 = "Sofá",
  sofa                  = "Sofá",
  crash_trolley         = "Trolley",
  tv                    = "TV",
  ultrascanner          = "Ultrascanner",
  dna_fixer             = "Fixador de DNA",
  cast_remover          = "Removedor de Gesso",
  hair_restorer         = "Recuperador de Cabelo",
  slicer                = "Fatiador",
  x_ray                 = "Raio-X",
  radiation_shield      = "Escudo de Radiaçao",
  x_ray_viewer          = "Visualizador de Radiação",
  operating_table       = "Mesa de Operação",
  lamp                  = "Lampâda", -- unused object
  toilet_sink           = "Pia",
  op_sink1              = "Pia",
  op_sink2              = "Pia",
  surgeon_screen        = "Ecra de Operaçao",
  lecture_chair         = "Cadeira de aluno",
  projector             = "Projector",
  bed2                  = "Cama", -- unused duplicate
  pharmacy_cabinet      = "Gabinete de Farmácia",
  computer              = "Computador",
  atom_analyser         = "Analisador de Átomos",
  blood_machine         = "Máquina de Análise Sanguínea",
  fire_extinguisher     = "Extintor",
  radiator              = "Radiador",
  plant                 = "Planta",
  electrolyser          = "Electrolisador",
  jelly_moulder         = "Moldador gelatinoso",
  gates_of_hell         = "Portões do Inferno",
  bed3                  = "Cama", -- unused duplicate
  bin                   = "Balde do lixo",
  toilet                = "WC",
  swing_door1           = "Porta",
  swing_door2           = "Porta",
  shower                = "Chuveiro",
  auto_autopsy          = "Auto-Autópsia",
  bookcase              = "Estante",
  video_game            = "Máquina de Arcade",
  entrance_left         = "Entrada esquerda",
  entrance_right        = "Entrada direita",
  skeleton              = "Esqueleto",
  comfortable_chair     = "Cadeira de conforto",
}


-- Months
months = {
  "Jan",
  "Fev",
  "Mar",
  "Abr",
  "Mai",
  "Jun",
  "Jul",
  "Ago",
  "Set",
  "Out",
  "Nov",
  "Dez",
}

-- Rooms short
-- NB: includes some special "rooms"
-- reception, destroyed room and "corridor objects"
rooms_short = {
  reception         = "Recepçao",
  destroyed         = "Destruído",
  corridor_objects  = "Objectos de Corredor",

  gps_office        = "Consultório Geral",
  psychiatric       = "Psiquiatria",
  ward              = "Enfermaria",
  operating_theatre = "Sala de Operações",
  pharmacy          = "Farmácia",
  cardiogram        = "Cardio",
  scanner           = "Scanner",
  ultrascan         = "Ultrascanner",
  blood_machine     = "Sala de Análises Sanguíneas",
  x_ray             = "Raio-X",
  inflation         = "Inflador",
  dna_fixer         = "Fixador de DNA",
  hair_restoration  = "Recuperador de Cabelo",
  tongue_clinic     = "Fatiador",
  fracture_clinic   = "Clínica de Fracturas",
  training_room     = "Sala de Aprendizagem",
  electrolysis      = "Sala de Electrolisador",
  jelly_vat         = "Moldador Gelatinoso",
  staffroom         = "Sala do Pessoal",
  -- rehabilitation = "Reabilitação", -- unused
  general_diag      = "Diagnóstico Geral",
  research_room     = "Sala de Pesquisa",
  toilets           = "Casas de Banho",
  decontamination   = "Descontaminação",
}


-- Menu Options Game Speed
menu_options_game_speed = {
  slowest             = "  MUITO LENTO  ",
  slower              = "  LENTO  ",
  normal              = "  NORMAL  ",
  max_speed           = "  RAPIDO  ",
  and_then_some_more  = "  AINDA MAIS RAPIDO  ",
}

-- Menu Display
menu_display = {
  high_res            = "  ALTA RESOLUÇAO  ",
  mcga_lo_res         = "  BAIXA RESOLUCAO  ",
  shadows             = "  SOMBRAS  ",
}

-- Menu Charts
menu_charts = {
  statement           = "  INDICACOES  ",
  casebook            = "  PONTUARIO DE DOENÇAS  ",
  policy              = "  POLITICAS DO HOSPITAL  ",
  research            = "  PESQUISA  ",
  graphs              = "  GRAFICOS  ",
  staff_listing       = "  LISTA DO STAFF  ",
  bank_manager        = "  CONTA BANCARIA  ",
  status              = "  STATUS  ",
  briefing            = "  BRIEFING  ",
}


menu = {
  file                  = "  FICHEIRO  ",
  options               = "  OPÇOES  ",
  display               = "  DISPLAY",
  charts                = "  TABELAS ",
  debug                 = "  DEBUG  ",
}

-- Menu File
menu_file = {
  load                  = "  LER JOGO  ",
  save                  = "  SALVAR JOGO  ",
  restart               = "  REINICIAR  ",
  quit                  = "  SAIR  ",
}


-- Menu Options
menu_options = {
  sound               = "  SOM  ",
  announcements       = "  ANUNCIOS  ",
  music               = "  MUSICA  ",
  sound_vol           = "  VOLUME DOS SONS  ",
  announcements_vol   = "  SOM DOS ANUNCIOS  ",
  music_vol           = "  VOLUME DA MUSICA  ",
  autosave            = "  AUTOSAVE  ",
  game_speed          = "  VELOCIDADE DO JOGO  ",
  jukebox             = "  JUKEBOX  ",
}

-- Menu Options Volume
menu_options_volume = {
  [10] = "  10%  ",
  [20] = "  20%  ",
  [30] = "  30%  ",
  [40] = "  40%  ",
  [50] = "  50%  ",
  [60] = "  60%  ",
  [70] = "  70%  ",
  [80] = "  80%  ",
  [90] = "  90%  ",
  [100] = "  100%  ",
}

confirmation = {
  abort_edit_room = "Estás a construir ou a editar uma sala. Se todos os objectos necessários estiverem colocados a sala estará terminada, caso contrário será eliminada. Continuar?",
  return_to_blueprint = "Tens a certeza que desejas voltar ao modo de desenho?",
  restart_level = "Tens a certeza que queres reiniciar o nível?",
  delete_room = "Desejas apagar esta sala?",
  quit = "Queres mesmo sair do jogo?",
  needs_restart = "Estas alterações requerem que reinicies o jogo,O progresso não gravado será perdido. Desejas continuar?",
  overwrite_save = "Já existe uma gravação nesta slot.Desejas gravar por cima?",
  sack_staff = "Queres mesmo despedir este membro do staff?",
  replace_machine = "Queres mesmo repor %s por $%d?",
}


vip_names = {
  [1] = "Presidente da Cruz Vermelha",
  [2] = "Ricardo Araújo Pereira",
  [3] = "D. Duarte Pio de Bragança",
  [4] = "Joe Berardo",
  [5] = "José Mourinho",
  [6] = "Alberto João Jardim",
  [7] = "Marcelo Rebelo de Sousa",
  [8] = "Cavaco Silva",
  [9] = "Cristiano Ronaldo",
  [10] = "Tradutor Filipe Carvalho",
  health_minister = "Ministro da Saúde",
}

-- Rooms
room_classes = {
  -- S[19][2] -- "corridors" - unused for now
  diagnosis  = "Diagnóstico",
  treatment  = "Tratamento",
  clinics    = "Clínicas",
  facilities = "Acomodaçoes",
}

