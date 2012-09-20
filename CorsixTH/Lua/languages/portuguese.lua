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

Language(utf8 "Português", "Portuguese", "pt", "pt")
Inherit("english")
Inherit("original_strings", 0)

-- override
adviser.warnings.money_low = utf8 "Estás a ficar sem dinheiro!" -- Funny. Exists in German translation, but not existent in english?
-- TODO: tooltip.graphs.reputation -- this tooltip talks about hospital value. Actually it should say reputation.
-- TODO: tooltip.status.close -- it's called status window, not overview window.

-- The originals of these two contain one space too much
fax.emergency.cure_not_possible_build = "Vais precisar de construir %s"
fax.emergency.cure_not_possible_build_and_employ = "Vais precisar de construir um %s e empregar um %s"

-- new strings
object.litter = "Lixo"
tooltip.objects.litter = utf8 "Lixo: Deitado fora por um paciente porque não encontrou um caixote do lixo onde o colocar."

menu_options.lock_windows = "  BLOQUEAR JANELAS  "
menu_options_game_speed.pause = "  PAUSA  "

menu_debug = {
  transparent_walls           = "  PAREDES TRANSPARENTES  ",
  limit_camera                = utf8 "  LIMITAR CAMARA  ",
  disable_salary_raise        = utf8 "  DESACTIVAR AUMENTO DOS SALÁRIOS  ",
  make_debug_patient          = "  MAKE DEBUG PATIENT  ",
  spawn_patient               = "  GERAR PACIENTE  ",
  make_adviser_talk           = "  MAKE ADVISER TALK  ",
  show_watch                  = utf8 "  MOSTRAR RELÓGIO  ",
  create_emergency            = utf8 "  CRIAR EMERGENCIA  ",
  place_objects               = "  COLOCAR OBJECTOS  ",
  dump_strings                = "  DUMP DAS STRINGS  ",
  map_overlay                 = "  OVERLAY DO MAPA  ",
  sprite_viewer               = "  VISUALIZAR SPRITES  ",
}
menu_debug_overlay = {
  none                        = "  NENHUM  ",
  flags                       = "  FLAGS  ",
  positions                   = utf8 "  POSIÇOES  ",
  byte_0_1                    = "  BYTE 0 & 1  ",
  byte_floor                  = "  BYTE FLOOR  ",
  byte_n_wall                 = "  BYTE N WALL  ",
  byte_w_wall                 = "  BYTE W WALL  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  PARCEL  ",
}
adviser.room_forbidden_non_reachable_parts = utf8 "Colocar o espaço neste sítio bloquearia o acesso a zonas do hospital."

dynamic_info.patient.actions.no_gp_available = utf8 "À espera que seja construidos um consultório de CG."
dynamic_info.staff.actions.heading_for = "Indo para %s"

misc.not_yet_implemented = "(not yet implemented)"
misc.no_heliport = utf8 "Hm... Ou não foram desocbertas novas doenças ou não existe um heliporto neste mapa."

main_menu = {
  new_game = "Novo jogo",
  custom_level = utf8 "Nível Personalizado",
  load_game = "Carregar Jogo",
  options = utf8 "Opçoes",
  exit = "Sair",
}

tooltip.main_menu = {
  new_game = utf8 "Começar um jogo de raíz",
  custom_level = "Construir o meu hospital",
  load_game = "Carregar um jogo",
  options = utf8 "Ajustar preferencias",
  exit = utf8 "Nao, por favor, nao saias!",
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
  dialog_missing_graphics = utf8 "Desculpa, mas a versão de demonstração não tem este diálogo!",
  save_prefix = utf8 "Erro durante a gravação do jogo: ",
  load_prefix = "Erro durante o carregamento do jogos: ",
}

totd_window = {
  tips = {
    utf8 "Todos os hospitais precisam de uma recepção e de um consultório de CG para começar. Depois disso, depende do tipo de pacientes que recebes. Uma farmácia é sempre uma boa escolha, no entanto.",
    utf8 "Máquinas como a Bomba de Encher Cabeças precisam de manutenção. Contrata um ou dois funcionários para reparar as tuas máquinas, ou arriscas-te a que o pessoal ou os pacientes se aleijem quando elas avariarem.",
    utf8 "Após algum tempo, o teu pessoal vai ficar cansado. Constrói um Quarto do Pessoal, para que eles possam relaxar.",
    utf8 "Coloca radiadores em quantidade suficiente para que o teu pessoal e pacientes estejam quentinhos... caso contrário irao ficar aborrecidos!",
    utf8 "O nível de perícia de um médico influencia a qualidade e velocidade do seu diagnóstico. Coloca um médico com perícia nas salas de CGs, e não precisarás de tantas salas de diagnóstico.",
    utf8 "Médicos júniores e regulares podem aumentar a sua perícia se aprenderem com um consultante numa Sala de Treino. Se o consultante for especialista (cirurgiao, psiquiatra ou investigador), também ensinará a sua especialização aos seus pupilos.",
    utf8 "Já tentaste escrever o número de emergência (112) no fax? Não te esqueças de ligar as colunas!",
    utf8 "O menu de opçoes ainda não está implementado, mas podes ajustar algumas preferencias tais como resoluçao e língua no ficheiro config.txt na pasta do jogo.",
    utf8 "Seleccionaste outra linguagem além do Ingles, mas ves Ingles em todo o lado? Ajuda-nos a traduzir esse texto!",
    utf8 "A equipa do CorsixTH está à procura de reforços! Estás interessado em programar, traduzir ou criar arte gráfica para o CorsixTH? Contacta-nos no fórum, IRC (corsix-th no freenode) ou via Mailing List.",
    "Se encontrares um bug, diz-nos em: th-issues.corsix.org",
    utf8 "Tens que cumprir certos requisitos para poder avançar de nível. Consulta a tua janela de status para veres o progresso em relaçao aos objectivos do nível.", -- dicas juntas
    utf8 "Se quiseres alterar ou remover alguma sala existente,utiliza o botao editar na barra de ferramentas em baixo no teu ecra.",
    utf8 "Se tiveres muitos pacientes na fila de espera, podes saber rapidamente quais estao à espera de uma determinada sala passando com o cursor por cima desta.",
    utf8 "Clica numa porta para ver a lista de espera.Podes alterar a ordem dos pacientes ou mandá-los para outra sala.",
    utf8 "Staffs descontentes irao pedir aumentos de salário frequentemente , assegura que tens um bom ambiente de trabalho para isto não acontecer!",
    utf8 "Os pacientes ficarao com sede enquanto esperam no hospital,ainda mais se os radiadores estiverem muito quentes.Coloca máquinas de bebidas em locais estratégicos para ganhares mais uns trocos.",
    utf8 "Podes abortar o processo de diagnóstico para um paciente e tentar adivinhar a cura caso já tenhas descoberto a doença. Cuidado que este processo pode aumentar o risco de uma cura errada levando à morte do paciente.",
    utf8 "Emergencias sao uma boa forma de ganhar algum dinheiro extra,garante que o teu hospital tem condiçoes para as completar.", 
  },
  previous = "Dica anterior",
  next = utf8 "Próxima dica",
}

tooltip.totd_window = {
  previous = "Mostrar dica anterior",
  next = utf8 "Mostrar a próxima dica",
}




--[[ Copyright (c) 2012 <Filipe "Aka" Carvalho>

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

debug_patient_window.caption = "Debug Paciente"



totd_window = {
  tips = {
    utf8 "Tens que cumprir certos requisitos para poder avançar de nível. Consulta a tua janela de status para veres o progresso em relaçao aos objectivos do nível.",
    utf8 "Se quiseres alterar ou remover alguma sala existente,utiliza o botao editar na barra de ferramentas em baixo no teu ecra.",
    utf8 "Se tiveres muitos pacientes na fila de espera, podes saber rapidamente quais estao à espera de uma determinada sala passando com o cursor por cima desta.",
    utf8 "Clica numa porta para ver a lista de espera.Podes alterar a ordem dos pacientes ou mandá-los para outra sala.",
    utf8 "Staffs descontentes irao pedir aumentos de salário frequentemente , assegura que tens um bom ambiente de trabalho para isto não acontecer!",
    utf8 "Os pacientes ficarao com sede enquanto esperam no hospital,ainda mais se os radiadores estiverem muito quentes.Coloca máquinas de bebidas em locais estratégicos para ganhares mais uns trocos.",
    utf8 "Podes abortar o processo de diagnóstico para um paciente e tentar adivinhar a cura caso já tenhas descoberto a doença. Cuidado que este processo pode aumentar o risco de uma cura errada levando à morte do paciente.",
    utf8 "Emergencias sao uma boa forma de ganhar algum dinheiro extra,garante que o teu hospital tem condiçoes para as completar.",
  },
}



tooltip.casebook.cure_requirement.hire_staff = utf8 "Precisas de contratar alguém para fazer este tratamento."
tooltip.casebook.cure_type.unknown = utf8 "Ainda não sabes tratar esta doença."
tooltip.information.close = utf8 "Fecha o diálogo de informação"
tooltip.load_game_window.load_game = "Ler jogo: %s"



tooltip = {
  message = {
    button = utf8 "Clica com o botão esquerdo para abrir a mensagem.",
    button_dismiss = utf8 "Click esquerdo para abrir a mensagem,click direito para apagar",
  },


  custom_game_window = {
    start_game_with_name = utf8 "Ir para o nível %s",
  },

  
  cheats_window = {
    close = utf8 "Fecha a janela dos truques",
    
    cheats = {
      end_month = utf8 "Salta para o final do mês.",
      create_patient =  "Cria um paciente no mapa.",
      money = utf8 "Adiciona 10000 à tua conta bancária",
      emergency = utf8 "Cria uma emergência",
      win_level = utf8 "Vence o nível.",
      lose_level = utf8 "Perde o nível.",
      vip = "Cria um VIP.",
      all_research = "Completa toda a pesquisa.",
      end_year = "Salta para o final do ano.",
      }, 
    },
    
    
   


  menu_list_window = {
    save_date = utf8 "Coloca a lista por data de modificação.",
    name = utf8 "Coloca a lista por nome.",
    back = "Fecha esta janela.",
    },


  new_game_window = {
    hard = utf8 "Se estás habituado a este tipo de jogos e procuras um desafio escolhe esta opçao.",
    cancel = utf8 "Oh mas eu não queria começar um jogo de novo!",
    tutorial = utf8 "Se precisas de umas dicas para começar a jogar,marca esta caixa.",
    easy = utf8 "Se és novo em jogos de simulaçoes,esta é a opçao para ti.",
    medium = utf8 "Se já te sentes à vontade tenta a opção média!",
    },

    
  save_game_window = {
    new_save_game = utf8 "Nome para salvar o jogo.",
    save_game = utf8 "Gravar por cima da gravação? %s",
    },


  calls_dispatcher = {
    assigned = utf8 "Esta caixa estrá marcada, se alguém esttiver a tratar da tarefa correspondente.",
    task = utf8 "Lista de tarefas - Clica em tarefas para abrir as tarefas atribuídas ao staff e encontrares a localização de determinada tarefa.",
    close = utf8 "Fecha a janela de diálogo do expedidor de chamadas.",
    },


  research_policy = {
    research_progress = utf8 "Progresso em relação à próxima descoberta: %1%/%2%",
    no_research = utf8 "Não está a ser feita nenhuma pesquisa de momento.",
    },

     
    lua_console = {
    textbox = utf8 "Coloca aqui o código Lua para executar",
    execute_code = utf8 "Executa o código colocado.",
    close =  "Fecha a consola.",
    },
    

    fax = {
      close = "Fecha esta janela sem apagar a mensagem.",
    },


  options_window = {
    fullscreen_button = "Clica para modo de tela cheia",
    original_path = utf8 "A directoria da instalaçao original de Theme Hospital",
    browse = utf8 "Procura outra localizaçao da instalaçao original.",
    change_resolution = utf8 "Altera a resoluçao da janela para as dimensoes colocadas à esquerda",
    height = "Coloca a altura desejada.",
    width = "Coloca a largura desejada.",
    language = utf8 "Escolhe %s como a tua linguagem.",
    back = utf8 "Fecha a janela de opçoes.",
    },

}



custom_game_window.caption = "Jogo Customizado"



cheats_window = {
  cheats = {
    end_month = utf8 "Fim do Mês",
    create_patient = "Criar Paciente",
    money = "Truque para Dinheiro",
    emergency = utf8 "Criar emergência",
    win_level = utf8 "Vencer nível",
    lose_level = utf8 "Perder nível",
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
    
    warning = utf8 "Aviso:Se utilizares truques não irás ganhar pontos de reputação no final do nível!",
}



errors = {
  unavailable_screen_size = utf8 "Esta resolução não está disponível no modo de tela cheia.",
  maximum_screen_size = utf8 "Resolução máxima de 3000x2000.",
  map_file_missing = utf8 "Não foi encontrado o ficheiro do mapa %s para este nível!",
  minimum_screen_size = utf8 "Resolução mínima de 640x480.",
}



date_format.daymonth = "%1% - %2% -"



menu_debug = {
  lua_console = "  (F12) CONSOLA LUA",
  make_debug_fax = "  (F8) DEBUG FAX",
  calls_dispatcher = "  CHAMAR EXPEDIDOR",
  cheats = "  (F11) TRUQUES",
  dump_gamelog = "  (CTRL+D) CRIAR LOG DO JOGO",
  jump_to_level = utf8 "  SALTAR PARA OUTRO NIVEL",
}


menu_options = {
  edge_scrolling = "  EDGE SCROLLING  ",
  settings = utf8 "  PREFERENCIAS  ",
}



lua_console = {
  execute_code = "Executar",
  close = "Fechar",
}



install= {
  exit = "Sair",
  th_directory = utf8 "CorsixTH precisa dos ficheiros de dados da instalação original de Theme Hospital(ou demo) para funcionar. Localize a sua instalação atráves da caixa em baixo.",
  title = utf8 "--------------------------------- Instalação CorsixTH  ---------------------------------",
}



load_game_window.caption = "Ler Jogo"



adviser = {
 cheats = {
    th_cheat = utf8 "Parabéns batoteiro! Acabaste de desbloquear os truques!",
    hairyitis_cheat = "Activado cheat da doença Olfatis",
    roujin_on_cheat = "Activado o desafio Roujin! Boa sorte...",
    crazy_on_cheat = utf8 "Oh não! Os teus médicos estão malucos!",
    bloaty_off_cheat = "Desactivado truque das Cabeças Gigantes!",
    bloaty_cheat = "Activado truque das Cabeças Gigantes!",
    crazy_off_cheat = utf8 "Ufa... os teus médicos voltaram ao normal.",
    roujin_off_cheat = "Desafio Roujin desactivado.",
    hairyitis_off_cheat = "Desactivado truque da doença Olfatis",
    },


  warnings = {
    no_desk_2 = utf8 "Bom trabalho! Deve ser um recorde mundial: quase um ano completo e não há pacientes! Se desejas continuar a gerir este hospital tens que contratar uma recepcionista e construir uma recepção para receberes os pacientes!",
    no_desk = utf8 "Constrói uma recepçao e uma recepcionista para começar!",
    no_desk_1 = utf8 "Se queres que os pacientes venham ao teu hospital vais precisar de uma recepçao e uma recepcionista!",
    },
}


calls_dispatcher = {
  repair = "Reparar %s",
  summary = utf8 "%d Chamadas; %d atribuídas",
  close = "Fechar",
  watering = utf8 "Regar @ %d,%d",
  staff = "%s - %s ",
}

information = {
  level_lost = {
    utf8 "Que chatice! Perdeste. Mais sorte para a próxima!",
    utf8 "Razões da derrota:",
    reputation = utf8 "A tua reputação ficou abaixo de %d.",
    balance = utf8 "A tua conta bancària ficou abaixo de %d.",
    percentage_killed = "Mataste mais do que %d por cento dos pacientes.",
  },

  cannot_restart = utf8 "Infelizmente este jogo customizado foi gravado antes da implementação da função de reinício.",
  custom_game = utf8 "Bem-vindo ao CorsixTH. Diverte-te neste mapa customizado!",
}


new_game_window = {
  hard = utf8 "Consultor (Difícil)",
  cancel = "Cancelar",
  tutorial = "Tutorial ",
  easy = utf8 "Junior (Fácil)",
  medium = utf8 "Doutor (Médio)",
}


options_window = {
  fullscreen = "Tela cheia",
  cancel = "Cancelar",
  browse = "Procurar...",
  width = "Largura",
  height = "Altura",
  new_th_directory = utf8 "Aqui podes escolher uma nova localizaçao da instalaçao de Theme Hospital,assim que o fizeres o jogo será reiniciado.",
  change_resolution = utf8 "Alterar resoluçao",
  back = "Voltar",
}


menu_list_window = {
  save_date = "Modificado",
  name = "Nome",
  back = "Voltar",
}


save_game_window = {
  caption = "Gravar jogo",
  new_save_game = utf8 "Nova gravaçao",
}



fax.emergency.num_disease_singular = utf8 "Existe uma pessoa com %s e necessita de atenção imediata!"



fax.choices = {
  decline_new_level = "Continuar a jogar",
  accept_new_level = utf8 "Avançar para o nível seguinte",
  return_to_main_menu = "Voltar para o menu principal",
}



menu_debug_overlay.heat = "  TEMPERATURA  "


confirmation.abort_edit_room = utf8 "Estás a construir ou a editar uma sala. Se todos os objectos necessários estiverem colocados a sala estará terminada, caso contrário será eliminada. Continuar?"
confirmation.needs_restart = utf8 "Estas alterações requerem que reinicies o jogo,O progresso não gravado será perdido. Desejas continuar?"


dynamic_info.staff.actions.fired = "Despedido"



introduction_texts.demo = {
  "Bem-vindo ao hospital do demo!",
  utf8 "Infelizmente este demo só tem este nível(excluindo os níveis customizados).Contudo existe aqui muito trabalho para te manter ocupado!",
  utf8 "Encontrarás várias doenças que requerem salas diferentes para os seus tratamentos.Ao longo do tempo irão ocorrer algumas emergências e precisarás de descobrir novos tratamentos atráves da sala de pesquisa.",
  utf8 "O teu objectivo é ganhar 100,000$,ter um hospital avaliado em 70,000$,uma reputação de 700 e uma cura de 75% dos pacientes.",
  utf8 "Garante que a tua reputação não cai abaixo de 300 e que não mates 40% dos teus pacientes senão perderás o nível.",
  utf8 "Boa sorte!",
}



letter = {
  custom_level_completed = utf8 "Bom trabalho!Completaste todos os objectivos deste nível!",
  dear_player = utf8 "Caro %s",
  return_to_main_menu = utf8 "Desejas regressar ao menu principal ou continuar a jogar?",
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
  total_wages  = utf8 "SALÁRIO",
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
  litter_bomb           = utf8 "Bomba de lixo",
  couch                 = utf8 "Sofá",
  sofa                  = utf8 "Sofá",
  crash_trolley         = "Trolley",
  tv                    = "TV",
  ultrascanner          = "Ultrascanner",
  dna_fixer             = "Fixador de DNA",
  cast_remover          = "Removedor de Gesso",
  hair_restorer         = "Recuperador de Cabelo",
  slicer                = "Fatiador",
  x_ray                 = utf8 "Raio-X",
  radiation_shield      = utf8 "Escudo de Radiaçao",
  x_ray_viewer          = utf8 "Visualizador de Radiação",
  operating_table       = "Mesa de Operação",
  lamp                  = utf8 "Lampâda", -- unused object
  toilet_sink           = "Pia",
  op_sink1              = "Pia",
  op_sink2              = "Pia",
  surgeon_screen        = "Ecra de Operaçao",
  lecture_chair         = "Cadeira de aluno",
  projector             = "Projector",
  bed2                  = "Cama", -- unused duplicate
  pharmacy_cabinet      = "Gabinete de Farmácia",
  computer              = "Computador",
  atom_analyser         = utf8 "Analisador de Átomos",
  blood_machine         = utf8 "Máquina de Análise Sanguínea",
  fire_extinguisher     = "Extintor",
  radiator              = "Radiador",
  plant                 = "Planta",
  electrolyser          = "Electrolisador",
  jelly_moulder         = "Moldador gelatinoso",
  gates_of_hell         = utf8 "Portões do Inferno",
  bed3                  = "Cama", -- unused duplicate
  bin                   = "Balde do lixo",
  toilet                = "WC",
  swing_door1           = utf8 "Porta",
  swing_door2           = utf8 "Porta",
  shower                = "Chuveiro",
  auto_autopsy          = utf8 "Auto-Autópsia",
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
  destroyed         = utf8 "Destruído",
  corridor_objects  = "Objectos de Corredor",
  
  gps_office        = utf8 "Consultório Geral",
  psychiatric       = "Psiquiatria",
  ward              = "Enfermaria",
  operating_theatre = "Sala de Operações",
  pharmacy          = "Farmácia",
  cardiogram        = "Cardio",
  scanner           = "Scanner",
  ultrascan         = "Ultrascanner",
  blood_machine     = "Sala de Análises Sanguíneas",
  x_ray             = utf8 "Raio-X",
  inflation         = "Inflador",
  dna_fixer         = "Fixador de DNA",
  hair_restoration  = utf8 "Recuperador de Cabelo",
  tongue_clinic     = "Fatiador",
  fracture_clinic   = "Clínica de Fracturas",
  training_room     = "Sala de Aprendizagem",
  electrolysis      = "Sala de Electrolisador",
  jelly_vat         = utf8 "Moldador Gelatinoso",
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
  [2] = utf8 "Ricardo Araújo Pereira",
  [3] = "D. Duarte Pio de Bragança",
  [4] = "Joe Berardo",
  [5] = utf8 "José Mourinho",
  [6] = "Alberto João Jardim",
  [7] = "Marcelo Rebelo de Sousa",
  [8] = "Cavaco Silva",
  [9] = "Cristiano Ronaldo",
  [10] = "Tradutor Filipe Carvalho",
  health_minister = utf8 "Ministro da Saúde",
}

-- Rooms
room_classes = {
  -- S[19][2] -- "corridors" - unused for now
  diagnosis  = "Diagnóstico",
  treatment  = "Tratamento",
  clinics    = "Clínicas",
  facilities = "Acomodaçoes",
}

