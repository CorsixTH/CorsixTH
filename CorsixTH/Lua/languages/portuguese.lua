--[[ Copyright (c) 2010 Manuel "Roujin" Wolf, "Fabiomsouto"
Copyright (c) 2011 Sérgio "Get_It" Ribeiro

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

Font("unicode")
Language("Português", "Portuguese", "pt", "pt")
Inherit("english")
Encoding(utf8)

-------------------------------  OVERRIDE  ----------------------------------
adviser.warnings.money_low = utf8 "Estás a ficar sem dinheiro!" -- Funny. Exists in German translation, but not existent in english?
-- TODO: tooltip.graphs.reputation -- this tooltip talks about hospital value. Actually it should say reputation.
-- TODO: tooltip.status.close -- it's called status window, not overview window.

-- tooltip.staff_list.next_person, prev_person is rather next/prev page (also in german, maybe more languages?)
tooltip.staff_list.next_person = "Próxima página"
tooltip.staff_list.prev_person = "Página anterior"

-- The originals of these two contain one space too much
fax.emergency.cure_not_possible_build = "Vais precisar de construir %s"
fax.emergency.cure_not_possible_build_and_employ = "Vais precisar de construir um %s e empregar um %s"
fax.emergency.num_disease = utf8 "Existem %d pessoas diagnosticadas com %s que precisam de atenção imediata."
fax.emergency.num_disease_singular = utf8 "Existe 1 pessoa diagnosticada com %s e que precisa de atenção imediata."
adviser.goals.lose.kill = utf8 "Mata mais %d pacientes para perder este nível!"

-- Improve tooltips in staff window to mention hidden features
tooltip.staff_window.face = utf8 "A cara desta pessoa - clique para abrir o ecrã de gestão de pessoal"
tooltip.staff_window.center_view = utf8 "Clique esquerdo para ir para onde está a pessoa, clique direito para navegador através dos funcionários"

-- These strings are missing in some versions of TH (unpatched?)
confirmation.restart_level = utf8 "Tem a certeza que deseja reiniciar este nível?"
-- TODO adviser.multiplayer.objective_completed
-- TODO adviser.multiplayer.objective_failed

-- A small error in the introduction text of level 2
introduction_texts.level2[6] = utf8 "Atinja uma reputação de 300, um saldo bancário de $10.000 e 40 pessoas curadas."

-------------------------------  NEW STRINGS  -------------------------------
date_format = {
  daymonth = "%1% %2:months%",
}

object.litter = "Lixo"
tooltip.objects.litter = utf8 "Lixo: Deitado fora por um paciente porque não encontrou um caixote do lixo onde o colocar."

tooltip.fax.close = "Fechar esta janela sem apagar a mensagem"
tooltip.message.button = "Clique esquerdo para abrir mensagem"
tooltip.message.button_dismiss = "Clique esquerdo para abrir mensagem, clique direito para descartar"
tooltip.casebook.cure_requirement.hire_staff = "Precisa de contratar pessoal para tratar deste tratamento"
tooltip.casebook.cure_type.unknown = utf8 "Ainda não sabe como tratar esta doença"
tooltip.research_policy.no_research = utf8 "Não existe uma investigação a ser feita nesta categoria neste momento"
tooltip.research_policy.research_progress = utf8 "Progresso no sentido da próxima descoberta nesta categoria: %1%/%2%"

menu_options = {
  lock_windows = "  BLOQUEAR JANELAS  ",
  edge_scrolling = "  EDGE SCROLLING  ",
  settings = utf8 "  PREFERÊNCIAS  ",
}

menu_options_game_speed = {
  pause               = "  (P) PAUSAR  ",
  slowest             = "  (1) MUITO LENTA  ",
  slower              = "  (2) LENTA  ",
  normal              = "  (3) NORMAL  ",
  max_speed           = utf8 "  (4) MUITO RÁPIDA  ",
  and_then_some_more  = "  (5) E AGORA UM POUCO MAIS  ",
}

-- The demo does not contain this string
menu_file.restart = "  REINICIAR  "

menu_debug = {
  jump_to_level               = utf8 "  SALTAR PARA NÍVEL ",
  transparent_walls           = "  PAREDES TRANSPARENTES  ",
  limit_camera                = utf8 "  LIMITAR CÂMARA  ",
  disable_salary_raise        = utf8 "  DESACTIVAR AUMENTO DOS SALÁRIOS  ",
  make_debug_fax              = "  (F8) GERAR FAX DE TESTE  ",
  make_debug_patient          = "  GERAR PACIENTE DE TESTE  ",
  spawn_patient               = "  GERAR PACIENTE  ",
  make_adviser_talk           = "  FAZER CONSELHEIRO FALAR  ",
  show_watch                  = utf8 "  MOSTRAR RELÓGIO  ",
  create_emergency            = utf8 "  CRIAR EMERGÊNCIA  ",
  place_objects               = "  COLOCAR OBJECTOS  ",
  dump_strings                = "  DUMP DAS STRINGS  ",
  map_overlay                 = "  OVERLAY DO MAPA  ",
  sprite_viewer               = "  VISUALIZAR SPRITES  ",
  cheats                      = "  (F11) BATOTAS  ",
  lua_console                 = "  (F12) CONSOLA LUA  ",
}
menu_debug_overlay = {
  none                        = "  NENHUM  ",
  flags                       = "  FLAGS  ",
  positions                   = utf8 "  POSIÇÕES  ",
  heat                        = "  TEMPERATURA  ",
  byte_0_1                    = "  BYTE 0 & 1  ",
  byte_floor                  = "  BYTE FLOOR  ",
  byte_n_wall                 = "  BYTE N WALL  ",
  byte_w_wall                 = "  BYTE W WALL  ",
  byte_5                      = "  BYTE 5  ",
  byte_6                      = "  BYTE 6  ",
  byte_7                      = "  BYTE 7  ",
  parcel                      = "  PARCEL  ",
}
adviser = {
  room_forbidden_non_reachable_parts = utf8 "Colocar o espaço neste sítio bloquearia o acesso a zonas do hospital.",

  cheats = {  
    th_cheat = utf8 "Parabéns, desbloqueou as batotas do jogo!",
    crazy_on_cheat = utf8 "Oh não! Todos os médicos ficaram malucos!",
    crazy_off_cheat = utf8 "Ufa... Os médicos voltaram a ficar bons da cabeça.",
    roujin_on_cheat = "O desafio do Roujin foi activado! Boa sorte...",
    roujin_off_cheat = "Desactivado o desafio do Roujin.",
    hairyitis_cheat = "Batota de Hairyitis activada!",
    hairyitis_off_cheat = "Batota de Hairyitis desactivada.",
    bloaty_cheat = utf8 "Batota de Doença de Cabeça Inchada activada!",
    bloaty_off_cheat = utf8 "Batota de Doença de Cabeça Inchada desactivada.",
  },
}

dynamic_info.patient.actions.no_gp_available = utf8 "À espera que seja construido um consultório de CG."
dynamic_info.staff.actions.heading_for = "Indo para %s"
dynamic_info.staff.actions.fired = "Despedido"

fax = {
  choices = {
    return_to_main_menu = "Voltar ao menu principal",
    accept_new_level = utf8 "Continuar para o próximo nível",
    decline_new_level = "Continuar a jogar durante um pouco mais",
  },
}

letter = {
  dear_player = "Caro %s",
  custom_level_completed = "Excelente trabalho! Completou todos os objectivos deste nível personalizado!",
  return_to_main_menu = "Gostaria de voltar ao menu principal ou continuar a jogar?",
}

install = {
  title = "--------------------------------- CorsixTH Setup ---------------------------------",
  th_directory = "O CorsixTH  precisa de uma cópia dos ficheiros do jogo Theme Hospital original (ou da demonstração) de modo a poder correr. Por favor utilize o seleccionar abaixo para localizar a pasta de instalação do Theme Hospital.",
  exit = "Sair",
}

misc.not_yet_implemented = utf8 "(ainda não implementado)"
misc.no_heliport = utf8 "Hm... Ou não foram descobertas novas doenças ou não existe um heliporto neste mapa."

main_menu = {
  new_game = "Novo jogo",
  custom_level = utf8 "Nível Personalizado",
  load_game = "Carregar Jogo",
  options = utf8 "Opções",
  exit = "Sair",
}

tooltip.main_menu = {
  new_game = utf8 "Começar um jogo novo de raíz",
  custom_level = "Construir o meu hospital",
  load_game = "Carregar um jogo",
  options = utf8 "Ajustar preferências",
  exit = utf8 "Não, por favor, não saias!",
}

load_game_window = {
  caption = "Carregar Jogo",
}

tooltip.load_game_window = {
  load_game = "Carregar o jogo %s",
  load_game_number = "Carregar o jogo %d",
  load_autosave = "Carregar o jogo gravado automaticamente",
}

custom_game_window = {
  caption = "Jogo Personalizado",
}

tooltip.custom_game_window = {
  start_game_with_name = utf8 "Carregar o nível %s",
}

save_game_window = {
  caption = "Guardar Jogo",
  new_save_game = "Novo jogo guardado",
}

tooltip.save_game_window = {
  save_game = "Substituir jogo guardado %s",
  new_save_game = "Introduza o nome para um novo jogo guardado",
}

menu_list_window = {
  back = "Voltar",
}

tooltip.menu_list_window = {
  back = "Fechar esta janela",
}

options_window = {
  fullscreen = utf8 "Ecrã inteiro",
  width = "Comprimento",
  height = "Altura",
  change_resolution = utf8 "Alterar resolução",
  browse = "Procurar...",
  new_th_directory = utf8 "Aqui  pode especificar uma nova localização da pasta de instalação do Theme Hospital. Quando seleccionar  uma nova pasta o jogo será reiniciado.",
  cancel = "Cancelar",
  back = "Voltar",
}

tooltip.options_window = {
  fullscreen_button = utf8 "Clique para alternar entre o modo de ecrã inteiro",
  width = utf8 "Introduza o comprimento de ecrã desejado",
  height = utf8 "Introduza a altura de ecrã desejada",
  change_resolution = utf8 "Alterar a resolução da janela para as dimensões introduzidas à esquerda",
  language = "Seleccionar %s como idioma",
  original_path = utf8 "A pasta de instalação do Theme Hospital original actualmente escolhida",
  browse = utf8 "Procurar por outra localização dos ficheiros de instalação do Theme Hospital",
  back = utf8 "Fechar a janela de opções",
}

new_game_window = {
  easy = utf8 "Estagiário (Fácil)",
  medium = utf8 "Doutor (Médio)",
  hard = utf8 "Médico Chefe (Difícil)",
  tutorial = "Tutorial",
  cancel = "Cancelar",
}

tooltip.new_game_window = {
  easy = utf8 "Caso seja a primeira vez que joga um jogo de simulação esta é a opção ideal para si",
  medium = utf8 "Esta é a opção a meio caminho caso não tenha a certeza de qual opção escolher",
  hard = utf8 "Caso já conheça o jogo e queira um desafio maior escolha esta opção",
  tutorial = utf8 "Caso queira alguma ajuda para começar o jogo escolha esta opção",
  cancel = "Oh, eu realmente não queria começar um novo jogo!",
}

lua_console = {
  execute_code = "Executar",
  close = "Fechar",
}

tooltip.lua_console = {
  textbox = "Introduza código Lua para correr aqui",
  execute_code = "Correr o código que introduziu",
  close = "Fechar a consola",
}

errors = {
  dialog_missing_graphics = utf8 "Desculpa, mas os ficheiros da versão de demonstração não têm este diálogo.",
  save_prefix = utf8 "Erro durante a gravação do jogo: ",
  load_prefix = "Erro durante o carregamento do jogo: ",
  map_file_missing = utf8 "Não foi possível encontrar o ficheiro de mapa %s para este nível!",
  minimum_screen_size = utf8 "Por favor introduza um tamanho de ecrã de pelo menos 640x480.",
  maximum_screen_size = utf8 "Por favor introduza um tamanho de ecrã de no máximo 3000x2000.",
  unavailable_screen_size = utf8 "O tamanho de ecrã que escolheu não encontra-se disponível no modo de ecrã inteiro.",
}

confirmation = {
  needs_restart = utf8 "Alterar esta configuração requer que o CorsixTH seja reiniciado. Qualquer progresso não guardado será perdido. Tem a certeza que deseja fazer isto?",
  abort_edit_room = utf8 "Esta  actualmente a construir ou a editar um espaço. Caso todos os objectos necessários sejam colocados o espaço será construido, caso contrário o espaço será eliminado. Deseja continuar?",
}

information = {
  custom_game = "Bem-vindo ao CorsixTH. Divirta-se neste mapa personalizado!",
  cannot_restart = "Infelizmente este jogo personalizado foi guardado antes da funcionalidade de reiniciar ter sido implementada.",
  level_lost = {
    "Que pena, falhaste este nível. Mais sorte para a próxima!",
    "O motivo pelo qual perdeste:",
    reputation = "A tua reputação caiu abaixo de %d.",
    balance = "O teu saldo bancário caiu abaixo de %d.",
    percentage_killed = "Morreram mais de %d porcento dos pacientes.",
  },
}

tooltip.information = {
  close = "Fechar a caixa de informação",
}

totd_window = {
  tips = {
    utf8 "Todos  os hospitais precisam de uma recepção e de um consultório de CG para  começar. Depois disso, depende do tipo de pacientes que recebes. Uma  farmácia é sempre uma boa escolha, no entanto.", -- "Every  hospital needs a reception desk and a GP's office to get going. After  that, it depends on what kind of patients are visiting your hospital. A  pharmacy is always a good choice, though."
    utf8 "Máquinas  como a Bomba de Encher Cabeças precisam de manutenção. Contrata um ou  dois funcionários para reparar as tuas máquinas, ou arriscas-te a que o  pessoal ou os pacientes se aleijem quando elas avariarem.", -- "Machines  such as the Inflation need maintenance. Employ a handyman or two to  repair your machines, or you'll risk your staff and patients getting  hurt."
    utf8 "Após algum tempo, o teu pessoal vai ficar cansado. Constrói um Quarto do Pessoal, para que eles possam descansar.", -- "After a while, your staff will get tired. Be sure to build a staff room, so they can relax."
    utf8 "Coloca  radiadores em quantidade suficiente para que o teu pessoal e pacientes  estejam quentinhos... caso contrário irão ficar descontentes! Utiliza o mapa da cidade para encontrar pontos no teu hospital que precisem de mais aquecimento.", -- "Place  enough radiators to keep your staff and patients warm, or they will  become unhappy. Use the town map to locate any spots in your hospital  that need more heating."
    utf8 "O  nível de perícia de um médico influencia a qualidade e velocidade do seu  diagnóstico. Coloca um médico com perícia nas salas de CGs, e não  precisarás de tantas salas de diagnóstico.", -- "A  doctor's skill level greatly influences the quality and speed of his  diagnoses. Place a skilled doctor in your GP's office, and you won't  need as many additional diagnosis rooms."
    utf8 "Médicos  estagiários e de clínica geral podem aumentar a sua perícia se aprenderem com um  médico chefe numa Sala de Treino. Se o médico chefe for especialista  (cirurgião, psiquiatra ou investigador), também ensinará a sua  especialização aos seu(s) pupilo(s).", -- "Juniors  and doctors can improve their skills by learning from a consultant in  the training room. If the consultant has a special qualification  (surgeon, psychiatrist or researcher), he will also pass on this  knowledge to his pupil(s)."
    utf8 "Já tentaste escrever o número de emergência (112) no fax? Não te esqueças de ligar as colunas!", -- "Did you try to enter the European emergency number (112) into the fax machine? Make sure your sound is on!"
    utf8 "Podes ajustar algumas preferências tais como resolução e idioma no menu principal do jogo.", -- "You can adjust some settings such as the resolution and language in the options window found both in the main menu and ingame."
    utf8 "Seleccionaste outra linguagem além do Inglês, mas vês Inglês em todo o lado? Ajuda-nos a traduzir esse texto!", -- "You  selected a language other than English, but there's English text all  over the place? Help us by translating missing texts into your  language!"
    utf8 "A  equipa do CorsixTH está à procura de reforços! Estás interessado em  programar, traduzir ou criar gráficos e animações para o CorsixTH? Contacta-nos  no fórum, IRC (corsix-th no freenode) ou via Mailing List.", -- "The  CorsixTH team is looking for reinforcements! Are you interested in  coding, translating or creating graphics for CorsixTH? Contact us at our  Forum, Mailing List or IRC Channel (corsix-th at freenode)."
    "Se encontrares um bug, diz-nos em: th-issues.corsix.org", -- "If you find a bug, please report it at our bugtracker: th-issues.corsix.org"
    "Cada nível tem os seus próprios objectivos a serem completados antes que poderes continuar para  o próximo. Verifica a janela de estado para veres a tua progressão ao longo  do jogo.", -- "Each  level has certain requirements to fulfill before you can move on to the  next one. Check the status window to see your progression towards the  level goals."
    "Caso queiras editar ou remover uma sala, podes o fazer com o botão de editar sala que poderás encontrar na barra de ferramentas.", -- "If you want to edit or remove an existing room, you can do so with the edit room button found in the bottom toolbar."
    "Numa montanha de pacientes em espera podes rapidamente encontrar quais   estão na fila de espera de uma certa clínica passando o rato por cima dessa mesma clínica.", -- "In  a horde of waiting patients, you can quickly find out which ones are  waiting for a particular room by hovering over that room with your mouse  cursor."
    "Clica na porta de uma sala para ver a sua fila de espera. Podes fazer ajustes muito úteis lá, tais como reordenar a fila ou mandar pacientes para outra sala.", -- "Click  on the door of a room to see its queue. You can do useful fine tuning  here, such as reordering the queue or sending a patient to another  room."
    "Funcionários insatisfeitos vão pedir frequentemente aumentos de salário. Tem a certeza que os teus funcionários estão a trabalhar num ambiente confortável para impedir que tal aconteça.", -- "Unhappy  staff will ask for salary rises frequently. Make sure your staff is  working in a comfortable environment to keep that from happening."
    "Os pacientes vão ficar com sede enquanto esperam no teu hospital, e ainda mais se estiver muito quente! Coloca máquinas de venda automática em locais estratégicos para ganhar mais algum dinheiro.", -- "Patients  will get thirsty while waiting in your hospital, even more so if you  turn up the heating! Place vending machines in strategic positions for  some extra income."
    "Podes abortar o progresso de diagnóstico para um paciente prematuramente e adivinhar a cura, caso já tenhas alguma vez visto esta doença. Cuidado que ao tentar adivinhar a cura poderá aumentar o risco de uma cura errada, resultado na morte do paciente.", -- "You  can abort the diagnosis progress for a patient prematurely and guess  the cure, if you already encountered the disease. Beware that this may  increase the risk of a wrong cure, resulting in death for the patient."
    "As emergências médicas podem ser uma boa fonte de algum dinheiro adicional, caso tenhas capacidade suficiente para curar os pacientes da emergência a tempo.", -- "Emergencies  can be a good source for some extra cash, provided that you have enough  capacities to handle the emergency patients in time."
  },
  previous = "Dica anterior",
  next = utf8 "Próxima dica",
}

tooltip.totd_window = {
  previous = "Mostrar dica anterior",
  next = utf8 "Mostrar a próxima dica",
}

debug_patient_window = {
  caption = "Debug Paciente",
}

cheats_window = {
  caption = "Batotas",
  warning = "Aviso: Não irá receber quaisquer pontos bónus no final deste nível se fizer batota!",
  cheated = {
    no = "Batota utilizada: Não",
    yes = "Batota utilizada: Sim",
  },
  cheats = {
    money = "Batota de Dinheiro",
    all_research = "Batota de Todas as Pesquisas",
    emergency = utf8 "Criar Emergência Médica",
    create_patient = "Criar Paciente",
    end_month = utf8 "Fim do mês",
    end_year = "Fim do ano",
    lose_level = utf8 "Perder Nível",
    win_level = utf8 "Vencer Nível",
  },
  close = "Fechar",
}

tooltip.cheats_window = {
  close = "Fechar a caixa de batota",
  cheats = {
    money = utf8 "Acrescenta 10.000 ao seu saldo bancário.",
    all_research = utf8 "Completa toda a investigação.",
    emergency = utf8 "Cria uma emergência médica.",
    create_patient = "Cria um paciente na borda do mapa.",
    end_month = utf8 "Salta para o fim do mês.",
    end_year = "Salta para o fim do ano.",
    lose_level = utf8 "Perde o nível actual.",
    win_level = utf8 "Vence o nível actual.",
  }
}

introduction_texts = {
  demo = {
    utf8 "Bem-vindo à demonstração do hospital!",
    utf8 "Infelizmente a versão de demonstração apenas contem este nível (além dos níveis personalizados).  Contudo, há muito que fazer por aqui para o manter ocupado por algum tempo!",
    utf8 "Irá  encontrar várias doenças que requerem diferentes tipos de salas para curar os pacientes.  Algumas emergências poderão ocorrer de tempo a tempo. E irá precisar de pesquisar salas de tratamento adicionais utilizando uma sala de investigação.",
    utf8 "O seu objectivo é de ganhar $100.000, o valor do hospital ser de $70.000 e ter uma  reputação de 700, enquanto tendo curado pelo menos 75% dos seus pacientes.",
    utf8 "Tenha a certeza que a sua reputação não caia abaixo de 300 e que não morrem  mais de 40% dos seus pacientes, ou irá perder.",
    "Boa sorte!",
  },
}

calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = utf8 "%d chamadas; %d atribuído",
  staff = "%s - %s",
  watering = "Regar @ %d,%d",
  repair = "Consertar %s",
  close = "Fechar",
}

tooltip.calls_dispatcher = {
  task = utf8 "Lista de tarefas - clique numa tarefa para abrir a janela do pessoal a quem foi atribuída a tarefa e navegue até à localização da tarefa",
  assigned = utf8 "Esta caixa encontra-se marcada se a tarefa correspondente foi atribuída a alguém.",
  close = "Fechar a caixa de chamadas",
}
