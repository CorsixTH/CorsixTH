--[[ Copyright (c) 2010 Manuel "Roujin" Wolf
Copyright (c) 2012 Henrique Poyatos

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
SOFTWARE.
Language(utf8 "Português do Brasil", "Brazilian Portuguese", "pt_br", "br")
 --]]

Language("Português do Brasil", "Brazilian Portuguese", "pt_br", "br")
Inherit("English")
Encoding(utf8)

--[[
1. Menus e Janelas de Sistema
2. Menu Superior

--]]

-- 1. Menus e Janelas de Sistema

main_menu = {
  new_game = "Novo Jogo",
  custom_level = "Fase Personalizada",
  load_game = "Carregar Jogo",
  options = "Opções",
  savegame_version = "versão de jogo salvo: ",
  version = "Versão: ",
  exit = "Sair",
}

tooltip.main_menu = {
  new_game = "Iniciar na primeira fase do jogo",
  custom_level = "Construir seu hospital para uma única fase",
  load_game = "Carregar um jogo salvo anteriormente",
  options = "Modifique várias configurações",
  exit = "Não se vá!",
}

new_game_window = {
  easy = "Júnior (Fácil)",
  medium = "Pleno (Médio)",
  hard = "Sênior (Difícil)",
  tutorial = "Tutorial",
  cancel = "Cancelar",
}

tooltip.new_game_window = {
  easy = "Se você é novo em jogos de simulação esta é a opção para você",
  medium = "Este é o meio do campinho se você está inseguro do que deve escolher",
  hard = "Se você está acostumado com este tipo de jogo e quer mais desafios, escolha esta opção",
  tutorial = "Se você precisa de ajuda para começar a jogar, escolha esta opção",
  tutorial = "Tutorial",
  cancel = "Ah, eu não queria começar um novo jogo !",
}

custom_game_window = {
  caption = "Jogo Customizado",
  free_build = "Construção Livre",
}

tooltip.custom_game_window = {
  start_game_with_name = "Carregando fase %s",
  free_build = "Escolha esta opção se você quer jogar sem dinheiro ou objetivos de jogo",
}

load_game_window = {
  caption = "Carregar Jogo",
}

tooltip.load_game_window = {
  load_game = "Carregar jogo %s",
  load_game_number = "Carregar jogo %d",
  load_autosave = "Carregar jogo salvo automaticamente",
}

menu_list_window = {
  name = "Nome",
  save_date = "Modificado",
  back = "Voltar",
}

tooltip.menu_list_window = {
  name = "Clique aqui para ordenar por nome",
  save_date = "Clique aqui para ordenar por data de última modificação",
  back = "Fechar esta janela",
}

options_window = {
  fullscreen = "Tela cheia",
  width = "Largura",
  height = "Altura",
  change_resolution = "Mudar resolução de tela",
  browse = "Procurar",
  new_th_directory = "Aqui você pode indicar outro diretório onde o jogo Theme Hospital está instalado, entretando se mudar o diretório o jogo será reiniciado.",
  cancel = "Cancelar",
  back = "Voltar",
}

tooltip.options_window = {
  fullscreen_button = "Clique para mudar para tela cheia",
  width = "Digite a largura desejada",
  height = "Digite a altura desejada",
  change_resolution = "Mude a resolução da janela para os valores inseridos à esquerda",
  language = "Selecionar '%s' como linguagem",
  original_path = "Diretório informado como sendo da instalação do Theme Hospital original",
  browse = "Procurar outro diretório de instalação do Theme Hospital. %1%",
  back = "Fechar a janela de opções",
}

lua_console = {
  execute_code = "Executar",
  close = "Fechar",
}

tooltip.lua_console = {
  textbox = "Digite um código Lua para rodar aqui",
  execute_code = "Run the code you have entered",
  close = "Fechar o console",
}

save_game_window = {
  caption = "Salvar Jogo",
  new_save_game = "Novo Jogo Salvo",
}

tooltip.save_game_window = {
  save_game = "Sobrescrevendo jogo salvo %s",
  new_save_game = "Digite o nome para este jogo salvo",
}

totd_window = {
  tips = {
    "Todo hospital precisa de um balção de recepção e uma Sala de Clínica Geral para começar. Depois disso, dependará do tipo de pacientes que visitará seu hospital. Ter uma farmácia é sempre uma boa idéia, entretanto.",
    "Máquina como o Inflador precisam de constante manutenção. Contrate um ou dois funcionários da Manutenção para reparos nestas máquinas, ou colocará seus funcionários e pacientes em risco.",
    "Depois de um certo período de trabalho, seus funcionários ficarão cansados. Certifique-se de construir uma Sala de Relaxamento, para que posam descansar.",
    "Instale radiadores o suficiente para manter seus funcionários e pacientes aquecidos, do contrário ficarão infelizes. Use o Mapa da Cidade para localizar pontos do hospital que precisem ser aquecidos.",
    "O nível de habilidade de um médico reflexe na qualidade e velocidade dos diagnósticos. Coloque um médico experiente na Sala de Clínica Geral, assim não precisará de muitas salas de diagnósticos adicionais.",
    "Médicos de níveis 'Junior' e 'Pleno' podem melhorar suas habilidades aprendendo com um Sênior na Sala de Treinamento. Se o Sênior possuir alguma qualificação especial (Cirurgião, Psiquiatra ou Pesquisador), ele irá passar este conhecido ao(s) seu(s) pupilo(s).",
    "Você já tentou digitar o numéro europeu de emergência (112) no aparelho de fax ? Certifique-se que o seu som esteja ligado !",
    "Você pode ajustar algumas configurações como a resolução de tela e linguagem na janela de opções que pode ser acessar no menu inicial e dentro do jogo.",
    "Você selecionou uma linguagem que não o inglês, mas existem textos em inglês por todos os lugares? Ajude-nos a traduzir os textos restantes para sua língua !",
    "A comunidade do Jogo CorsixTH está precisando de reforços em sua equipe ! Você está interessado em codificar, traduzir ou criar gráficos para o CorsixTH? Entre em contato conosco pelo nosso Fórum, Lista de Discussão ou canal de IRC (#corsix-th no freenode).",
    "Se localizar um bug, por favor reporte-o em nosso bugtracker: th-issues.corsix.org",
    "Cada fase possui certas metas a serem atingidas antes de passar para a próxima fase. Cheque a janela de situação para acompanhar seu progresso a fim de atingir seus objetivos.",
    "Se você deseja editar ou remover um sala existente, pode fazê-lo com o botão de edição de sala na barra inferior.",
    "Caso haja uma multidão de pacientes esperando, você deve descobrir rapidamente quais deles estão aguardando por uma sala em particular passando o ponteiro do mouse por cima desta sala.",
    "Clique nas portas das salas para ver sua fila. Isso pode ser muito útil, já que pode reordenar a fila ou encaminhar um paciente para outra sala.",
    "Funcionários infelizes irão pedir aumentos de salários com mais frequência. Certifique-se que sua equipe esteja trabalho em um ambiente de trabalho confortável para mantê-los felizes.",
    "Pacientes podem ficar com sede enquanto esperam em seu hospital, ainda mais se ligar o aquecimento! Instale máquinas de venda de refrigerantes em pontos estratégicos para um ganho extra.",
    "Você pode abortar o processo de diagnóstico prematuramente e presupor a cura, se você já tiver descoberto a doença. Atente-se que desta maneira aumenta-se o risco de um tratamento errado, resultando na morte do paciente.",
    "Emergências podem ser uma boa fonte de grana extra, desde que você possua plena capacidade e recursos de lidar com os pacientes à tempo.",
  },
  previous = "Dica anterior",
  next = "Próxima Dica",
}

tooltip.totd_window = {
  previous = "Mostrar a dica anterior",
  next = "Mostrar a próxima dica",
}

-- 2. Menu Superior

menu = {
  file                  = "  ARQUIVO  ",
  options               = "  OPÇÕES  ",
  display               = "  DISPLAY",
  charts                = "  GRÁFICOS ",
  debug                 = "  DEBUG  ",
}

-- Menu File
menu_file = {
  load                  = "  CARREGAR JOGO  ",
  save                  = "  SALVAR JOGO  ",
  restart               = "  REINICIAR  ",
  quit                  = "  SAIR  ",
}


-- Menu Options
menu_options = {
  sound               = "  SOM  ",
  announcements       = "  ANÚNCIOS  ",
  music               = "  MÚSICA  ",
  sound_vol           = "  VOLUME DOS SONS  ",
  announcements_vol   = "  SOM DOS ANÚNCIOS  ",
  music_vol           = "  VOLUME DA MUSICA  ",
  autosave            = "  AUTOSALVAR  ",
  game_speed          = "  VELOCIDADE DO JOGO  ",
  jukebox             = "  JUKEBOX  ",
}


-- Menu Display
menu_display = {
  high_res            = "  ALTA RESOLUÇÃO  ",
  mcga_lo_res         = "  BAIXA RESOLUÇÃO  ",
  shadows             = "  SOMBRAS  ",
}

-- Menu Charts
menu_charts = {
  statement           = "  EXTRATO BANCÁRIO  ",
  casebook            = "  PRONTUÁRIO DE DOENÇAS  ",
  policy              = "  POLÍTICAS DO HOSPITAL  ",
  research            = "  PESQUISA  ",
  graphs              = "  GRÁFICOS  ",
  staff_listing       = "  QUADRO DE FUNCIONÁRIOS  ",
  bank_manager        = "  GERENTE DO BANCO  ",
  status              = "  STATUS  ",
  briefing            = "  OBJETIVO DESTA FASE  ",
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

 menu_options = {
  lock_windows = "  TRAVAR JANELAS  ",
  edge_scrolling = "  EDGE SCROLLING  ",
  settings = "  CONFIGURAÇÕES  ",
  adviser_disabled = "  NOTIFICAÇÕES  ",
  warmth_colors = "  WARMTH COLOURS",
}

menu_options_game_speed = {
  pause               = "  (P) PAUSADO ",
  slowest             = "  (1) MUITO LENTO ",
  slower              = "  (2) LENTO  ",
  normal              = "  (3) NORMAL  ",
  max_speed           = "  (4) RÁPIDO  ",
  and_then_some_more  = "  (5) AINDA MAIS RÁPIDO  ",
}

menu_options_warmth_colors = {
  choice_1 = "   Vermelho ",
  choice_2 = "   Azul Verde Vermelho ",
  choice_3 = "   Amarelo Laranja Vermelho ",
}

-- The demo does not contain this string
menu_file.restart = "  REINICIAR  "

menu_debug = {
  jump_to_level               = "  IR PARA A FASE  ",
  transparent_walls           = "  (X) PAREDES TRANSPARENTES  ",
  limit_camera                = "  LIMIT CAMERA  ",
  disable_salary_raise        = "  DESABILITAR AUMENTOS DE SALÁRIO  ",
  make_debug_fax              = "  (F8) MAKE DEBUG FAX  ",
  make_debug_patient          = "  (F9) MAKE DEBUG PATIENT  ",
  cheats                      = "  (F11) CHEATS  ",
  lua_console                 = "  (F12) CONSOLE LUA  ",
  calls_dispatcher            = "  CALLS DISPATCHER  ",
  dump_strings                = "  DUMP STRINGS  ",
  dump_gamelog                = "  (CTRL+D) DUMP GAME LOG  ",
  map_overlay                 = "  MAP OVERLAY  ",
  sprite_viewer               = "  SPRITE VIEWER  ",
}
menu_debug_overlay = {
  none                        = "  NENHUM  ",
  flags                       = "  FLAGS  ",
  positions                   = "  POSIÇÕES  ",
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

dynamic_info = {
  patient = {
--    emergency = "Чрезвычайная ситуация: %s",
--    guessed_diagnosis = "Диагноз навскидку: %s ",
    diagnosis_progress = "Diagnóstico em:",
    actions = {
--      sent_to_other_hospital = "Отправлен в другую больницу",
--      prices_too_high = "У вас слишком дорого, - я иду домой",
--      no_gp_available = "Ждет постройки кабинета терапевта",
--      waiting_for_treatment_rooms = "Ждет постройки кабинета для лечения",
--      dying = "Умирает!",
      no_diagnoses_available = "Sem diagnóstico - Indo para a casa",
--      epidemic_sent_home = "Отправлен домой инспектором",
      cured = "Curado !",
      waiting_for_diagnosis_rooms = "Esperando você construir novas salas de diagnóstico",
--      epidemic_contagious = "Заразный",
      awaiting_decision = "Esperando por sua decisão",
      sent_home = "Alta - Indo para casa",
--      fed_up = "Сыт по горло и уходит",
      no_treatment_available = "Sem tratamento - Indo para a casa",
      on_my_way_to = "À caminho do %s",
      queueing_for = "Na fila de espera do(a) %s",
    },
    diagnosed = "Diagnóstico: %s ",
  },
--  health_inspector = "Инспектор",
--  vip = "Шишка",
  object = {
    times_used = "Vezes que foi usado(a): %d",
    queue_size = "Tamanho da fila: %d",
--    strength = "Прочность: %d",
    queue_expected = "Tamanho esperado da fila: %d",
  },
  staff = {
    actions = {
      going_to_repair = "Indo reparar %s",
      fired = "Demitido",
      waiting_for_patient = "Esperando por um paciente",
      wandering = "Andando sem rumo",
      heading_for = "Indo para %s",
    },
    tiredness = "Nível de Stress: ",
  },
}

-- 3. Staff?

-- Staff titles
-- these are titles used e.g. in the dynamic info bar
staff_title = {
  receptionist          = "Recepcionista",
  general               = "General", -- unused?
  nurse                 = "Enfermeira",
  junior                = "Júnior",
  doctor                = "Doutor",
  surgeon               = "Cirurgião",
  psychiatrist          = "Psiquiatra",
  consultant            = "Doutor Sênior",
  researcher            = "Pesquisador",
}

staff_list = {
  morale       = "MORAL",
  tiredness    = "CANSAÇO",
  skill        = "QUALIFICAÇÕES",
  total_wages  = "SALÁRIO",
}



bank_manager = {
  current_loan = "Empréstimo atual",
  balance = "Balanço",
  interest_payment = "Pagamento de Juros",
  hospital_value = "Valor do Hospital",
  interest_rate = "Taxa de Juros",
  inflation_rate = "Taxa Inflação",
  insurance_owed = "Seguro Inadimplência",
  statistics_page = {
    balance = "Saldo",
    details = "Detalhe",
    date = "Data",
    current_balance = "Saldo Atual",
    money_in = "Entrada",
    money_out = "Saída",
  },
}


transactions = {
  severance = "Demissão",
  research = "Custos de Pesquisa",
--  eoy_trophy_bonus = "Bonificação VIP", // VIP cash award
  buy_object = "Compra",
  cure_colon = "Cura:",
  wages = "Custos com Folha de Pagamento",
  personal_bonus = "Pagamento de Bonificação Pessoal",
  drug_cost = "Medicação",
  heating = "Custos de Aquecimento",
  treat_colon = "Tratamento:",
  hire_staff = "Contratação",
  bank_loan = "Empréstimo Bancário",
  insurance_colon = "Seguro:",
  sell_object = "Venda",
--  loan_interest = "Выплата процента по займу",
--  loan_repayment = "Возврат по займу",
  buy_land = "Compra de Terreno",
--  machine_replacement = "Замена машины",
  build_room = "Construção",
  drinks = "Receita: Máq. de Refrigerante",
--  "vip_cash_award"?
}

town_map = {
  number = "Número",
  not_for_sale = "Não está à venda",
  price = "Preço",
  for_sale = "À Venda",
  owner = "Dono",
  area = "Área",
}

high_score = {
  categories = {
--    deaths = "Óbitos",
--    total_value = "Общая стоимость",
--    money = "Самый богатый",
--    cures = "Пациентов вылечено",
--    visitors = "Количество посетителей",
--    salary = "",
  },
}

research = {
--  allocated_amount = "Распределенное количество",
--  funds_allocation = "Распределение финасирования",
  categories = {
    improvements = "Melhorias",
    drugs = "Novos Medicamentos",
    diagnosis = "Equip. para Diagnóstico",
    cure = "Equip. para Tratamento",
    specialisation = "Especializações",
  },
}

policy = {
  header = "POLÍTICA DO HOSPITAL",
  diag_termination = "Finalização de Diagnóstico",
  sliders = {
    guess = "Determinar Cura",
    send_home = "Mandar p/ casa",
    stop = "Parar",
    staff_room = "Ir descansar",
  },
  diag_procedure = "Procedimento de Diagnóstico",
  staff_rest = "Descanso dos Funcionários",
  staff_leave_rooms = "Funcionário deixar sala",
}

casebook = {
  sent_home = "enviados para casa",
  deaths = "óbitos",
  treatment_charge = "custo do tratamento",
  reputation = "reputação",
--  research = "Сосредоточить исследования",
  cure = "curas",
  cured = "curados",
  earned_money = "valor do tratamento",
}

--[[
progress_report = {
  quite_unhappy = "Люди вами недовольны",
  header = "Отчет об успехах",
  very_unhappy = "Люди вас не любят. Уделяйте им больше внимания",
  more_drinks_machines = "Пациенты умирают от жажды. Поставьте автоматы с напитками",
  too_cold = "У вас слишком холодно, поставьте еще батарей",
  too_hot = "Настройте систему отопления, у вас слишком жарко",
  percentage_pop = "Доля клиентов",
  win_criteria = "Условия для победы",
}
]]
tooltip = {
--[[
  staff_list = {
        = "Предыдущая страница",
    next_person = "Следующая страница",
    detail = "Внимание к деталям",
    happiness = "Насколько ваши сотрудники довольны своей работой в целом",
    tiredness = "Показывает сколько ваши сотрудники еще смогут поработать без отдыха",
    ability = "Квалификация ваших сотрудников в среднем по больнице",
    happiness_2 = "Моральное состояние",
    ability_2 = "Профессиональные навыки",
    tiredness_2 = "Запас сил",
    researcher_train = "На %d%% готов к получению диплома исследователя",
    surgeon_train = "На %d%% готов к получению диплома хирурга",
    psychiatrist_train = "На %d%% готов к получению диплома психиатра",
    researcher = "Дипломированый исследователь",
    psychiatrist = "Дипломированый психиатр",
    surgeon = "Дипломированый хирург",
    handymen = "Показать список всех рабочих вашей больницы",
    nurses = "Показать список всех медсестер вашей больницы",
    doctors = "Показать список всех докторов вашей больницы",
    receptionists = "Показать список всех регистраторов вашей больницы",
    pay_rise = "Поднять оклад на 10%",
    bonus = "Выплатить премию в размере 10% от оклада",
    salary = "Текущая зарплата",
    close = "Назад к игре",
    sack = "Вышвырнуть на улицу",
    doctor_seniority = "Авторитет доктора",
    view_staff = "Наблюдать за работой",
    skills = "Дополнительные умения",
    total_wages = "Общая зарплата",
  },]]
  town_map = {
    close = "Fechar",
    plants = "Exibir plantas",
    fire_extinguishers = "Exibir plantas",
    people = "Exibir pessoas",
    balance = "Saldo",
    heat_dec = "Diminuir aquecimento",
    heating_bill = "Preço do aquecimento",
    radiators = "Exibir radiadores",
    objects = "Exibir objetos",
    heat_level = "Temperatura do aquecimento",
    heat_inc = "Aumentar aquecimento",
  },
--[[
  policy = {
    diag_termination = "Обследование пациента будет продолжаться, пока доктора не будут на столько процентов уверены в диагнозе или пока у них не закончатся средства диагностики",
    close = "Закрыть окно политики",
    staff_leave = "Нажмите здесь чтобы разрешить сотрудникам покидать кабинеты и идти туда где нужна их помощь",
    diag_procedure = "Если доктор уверен в своем диагнозе менее, чем значение «Отправить домой», пациент будет отправлен домой. Если же шансы выше чем «Диагноз наугад», он будет отправлен на лечение. В остальных случаях потребуется ваше решение",
    staff_rest = "Насколько усталым должен быть сотрудник, чтобы получить право на отдых",
    staff_stay = "Нажмите здесь чтобы сотрудники оставались в тех кабинетах, где вы их поставили",
  },
  bank_manager = {
    graph = "График ожидаемых выплат от %s",
    close = "Закрыть окно",
    hospital_value = "Текущая стоимость госпиталя вместе со всем оборудованием",
    graph_return = "Вернуться назад",
    current_loan = "Размер текущего займа",
    borrow_5000 = "Занять у банка 5000$",
    balance = "Ваш баланс",
    interest_payment = "Ежемесячные выплаты по займу",
    inflation_rate = "Размер инфляции за год",
    interest_rate = "Годовой процент по займу",
    repay_5000 = "Отдать банку 5000$",
    show_graph = "Показать график ожидаемых выплат от %s",
    insurance_owed = "Сколько денег вам должны %s",
  },
  casebook = {
    sent_home = "Количество пациентов, которым было отказано в лечении",
    increase = "Поднять стоимость",
    decrease = "Снизить стоимость",
    up = "Вверх",
    down = "Вниз",
    reputation = "Общая репутация этой практики",
    research = "Нажмите чтобы сосредоточить бюджет специальных исследований на этой проблеме",
    close = "Закрыть",
    earned_money = "Всего заработано на этом",
    deaths = "Количество летальных исходов",
    cured = "Количество вылеченных",
    treatment_charge = " Стоимость для пациентов",
    cure_type = {
      psychiatrist = "Это лечит психиатр",
      drug_percentage = "От этого есть лекарство. Ваше эффективно на %d%",
      machine = "Для лечения нужно специальное оборудование",
      surgery = "Cura требует операции",
    },
    cure_requirement = {
      possible = "Вы можете это вылечить",
      build_room = "Вам нужно построить специальный кабинет для лечения",
      research_machine = "Для лечения нужно изобрести машину",
      hire_staff = "Вам нужно нанять специалиста для лечения",
    },
  },
  status = {
    population_chart = "Показывает соотношение числа посетителей в разных больницах",
    percentage_cured = "Вам нужно вылечить %d% всех посетителей. На данный момент вам удалось вылечить %d%",
    num_cured = "Вам нужно вылечить %d людей. Пока вам удалось исцелить %d",
    thirst = "Средний уровень жажды людей в больнице",
    close = "Закрыть окно",
    win_progress_own = "Показать успехи вашей больницы",
    reputation = "Ваша репутация должна достигать %d. Сейчас она составляет %d",
    population = "Добейтесь чтобы к вам приходили лечиться %d%% всех пациентов",
    warmth = "Средняя температура по больнице",
    percentage_killed = "Постарайтесь не убивать более чем %d%% посетителей. На данный момент вы угробили %d%%",
    balance = "На вашем счету должно быть не менее %d$. Сейчас у вас %d$",
    value = "Ваша больница должна стоить %d$. Сейчас она стоит %d$",
    win_progress_other = "Показать как идут дела у %s",
    happiness = "Общее состояние пациентов в вашей больнице",
  },
--]]
  buy_objects_window = {
    price = "Preço",
    cancel = "Cancelar",
    confirm = "Comprar itens",
    total_value = "Total",
    decrease = "Comprar menos",
    increase = "Comprar mais",
  },
  hire_staff_window = {
    doctors             = "Ver Doutores disponíveis para contratação",
    nurses              = "Ver Enfermeiras disponíveis para contratação",
    handymen            = "Ver Zeladores disponíveis para contratação",
    receptionists       = "Ver Recepcionistas disponíveis para contratação",
    prev_person         = "Próxima pessoa",
    next_person         = "Pessoa anterior",
    hire                = "Contratar",
    cancel              = "Cancelar",
    doctor_seniority    = "Experiência (Júnior, Pleno, Sênior)",
    staff_ability       = "Habilidade",
    salary              = "Salário",
    qualifications      = "Qualificações extras",
    surgeon             = "Cirurgião",
    psychiatrist        = "Psiquiatra",
    researcher          = "Pesquisador",
  },
}

-- 5. Doenças

diseases = {
  general_practice = {
    name = "Prática geral",
  },
  diag_ward = {
    name = "Diag: Enfermaria",
  },
  diag_ultrascan = {
    name = "Diag: Ultrasom",
  },
  diag_blood_machine = {
    name = "Diag: Análise Sanguinea",
  },
  diag_x_ray = {
    name = "Diag: Raio-X",
  },
  diag_psych = {
    name = "Diag: Psiquiatria",
  },
  diag_general_diag = {
    name = "Diag: Diagnóstico Geral",
  },
  diag_cardiogram = {
    name = "Diag: Eletrocardiograma",
  },
  diag_scanner = {
    name = "Diag: Scanner",
  },
  autopsy = {
    name = "Autópsia",
  },
  third_degree_sideburns = {
--    cause = "Causa - непреодолимая тоска по семидесятым.",
--    cure = "Cura - психиатр должен, используя самые современные методы, убедить пациента, что чрезмерная волосатость уже не в моде.",
    name = "Queimaduras de Terceiro Grau",
--    symptoms = "Sintomas - длинные волосы, смешные штаны, обувь на платформе и сверкающий макияж.",
  },
  discrete_itching = {
--    cause = "Causa - крошечные насекомые с очень острыми зубами.",
--    cure = "Cura - пациент выпивает липкий фармацевтический сироп, который защищает кожу.",
    name = "Coceira Discreta",
--    symptoms = "Sintomas - интенсивное чесание вплоть до воспламенения.",
  },
  the_squits = {
    cause = "Causa - Comer um pedaço de pizza encontrada embaixo do fogão.",
    cure = "Cura - Uma mistura glutinoso de químicos farmacêuticos pegajosos solidificará as entranhas do paciente.",
    name = "Disenteria",
    symptoms = "Sintomas - Argh, tenho certeza que você pode imaginar.",
  },
  spare_ribs = {
--    cause = "Causa - сидение на холодном каменном полу.",
--    cure = "Cura - два хирурга должны удалить лишние ребра и завернуть их пациенту с собой.",
    name = "Rim Extra",
--    symptoms = "Sintomas - неприятные ощущения от массивной груди.",
  },
  king_complex = {
--    cause = "Causa - дух Короля, который захватил контроль над разумом пациента.",
--    cure = "Cura - психиатр рассказывает пациенту как нелепо тот выглядит.",
    name = "Complexo de Rei",
--    symptoms = "Sintomas - слабость к цветастой замшевой обуви и чизбургерам.",
  },
  fake_blood = {
--    cause = "Causa - скорее всего, пациент стал жертвой розыгрыша.",
--    cure = "Cura - психиатр должен помочь пациенту успокоиться.",
    name = "Sangue falso",
--    symptoms = "Sintomas - красная жидкость в венах, которая испаряется при контакте с одеждой.",
  },
  invisibility = {
--    cause = "Causa - укус радиоактивного (и, само собой, невидимого) муравья.",
--    cure = "Cura - напиток насыщенного цвета, приготовленный в аптеке, восстанавливает видимость пациента.",
    name = "Invisibilidade",
--    symptoms = "Sintomas - пациент чувствует себя нормально и даже может использовать болезнь чтобы разыгрывать близких.",
  },
  golf_stones = {
--    cause = "Causa - вдыхание ядовитого газа, содержащегося в мячиках для гольфа.",
--    cure = "Cura - образования удаляются хирургами в операционной.",
    name = "Pedras de Golf",
--    symptoms = "Sintomas - бред и чувство стыда.",
  },
  infectious_laughter = {
  --  cause = "Causa - просмотр классических комедий.",
  --  cure = "Cura - квалифицированный психиатр должен напомнить пациенту, что не все в этой жизни смешно.",
    name = "Risada contagiosa",
  --  symptoms = "Sintomas - непроизвольное фырканье и повторение несмешных шуток.",
  },
  baldness = {
  --  cause = "Causa - вранье и придумавание небылиц с целью привлечения внимания.",
  --  cure = "Cura - в ходе болезненной процедуры специальная машина плавно восстанавливает волосяной покров.",
    name = "Calvíce",
  --  symptoms = "Sintomas - блестящесть и смущение.",
  },
  heaped_piles = {
    cause = "Causa - Ficar muito perto de refrigeradores de água.",
    cure = "Cura - Um agradável porém poderoso acído dissolverá as hemorróidas por dentro.",
    name = "Hemorróidas",
    symptoms = "Sintomas - Paciente tem a sensação de estar sentado em um saco de bolinhas de gude.",
  },
  unexpected_swelling = {
  --  cause = "Causa - все внезапное.",
  --  cure = "Cura - возбухание может быть уменьшено хирургами при помощи автогена.",
    name = "Inchaço inesperado",
  --  symptoms = "Симптом - возбухание.",
  },
  jellyitis = {
  --  cause = "Causa - пища, богатая желатином и избыток физической активности.",
  --  cure = "Cura - пациента помещают в разжелетиватель в специальном кабинете.",
    name = "Gelatinite",
  --  symptoms = "Sintomas - пациент чрезмерно трясется и часто падает.",
  },
  hairyitis = {
  --  cause = "Causa - длительные прогулки в свете луны.",
  --  cure = "Cura - электролизатор удаляет волосы и запаивает поры.",
    name = "Cabelulite",
  --  symptoms = "Sintomas - обостренное обоняние.",
  },
  alien_dna = {
  --  cause = "Causa - прыгающие личинки разумных видов пришельцев.",
  --  cure = "Cura - в специальной машине ДНК извлекается, очищается от фрагментов пришельцев и быстро вставляется на место.",
    name = "DNA alienígena",
  --  symptoms = "Sintomas - постепенное превращение в пришельца и стремление уничтожить человечество.",
  },
  bloaty_head = {
    cause = "Causa - Cheirar queijo e beber água de chuva não purificada.",
    cure = "Cura - A cabeça inchada é estourada e reinflada no PSI correto usando uma máquina inteligente.",
    name = "Cabeça inchada",
    symptoms = "Sintomas - Muito desconforto para o sofredor.",
  },
  gastric_ejections = {
  --  cause = "Causa - острая мексиканская и индийская пища.",
  --  cure = "Cura - выпивание специального связующего состава предотвращает какие бы то ни было извержения.",
    name = "Vômitos",
  --  symptoms = "Sintomas - полупереваренная пища извергается из пациента в случайных местах.",
  },
  uncommon_cold = {
    cause = "Causa - pequenas partículas de muco no ar.",
    cure = "Cura - Um bom gole de um xarope incomum feito a partir de ingredientes especiais na Farmária poderá curar isso.",
    name = "Frio incomum",
    symptoms = "Sintomas - Barulho constante, espirros e pulmões descolorados.",
  },
  corrugated_ankles = {
  --  cause = "Causa - езда через асфальтовые гребни на дорогах.",
  --  cure = "Cura - слегка токсичная смесь трав и специй позволяет пациенту выпрямить лодыжки.",
    name = "Tornozelos tortos",
  --  symptoms = "Sintomas - привычная обувь больше не подходит пациенту.",
  },
  sleeping_illness = {
    cause = "Causa - Superatividade da glândula de sono localizada no céu da boca.",
    cure = "Cura - Uma alta dosagem de um poderoso estimulante será administrado pela Enfermeira.",
    name = "Encefalite letárgica",
    symptoms = "Sintomas - Vontade incontrolável de desabar e dormir em qualquer lugar.",
  },
  sweaty_palms = {
  --  cause = "Causa - боязнь собеседований.",
  --  cure = "Cura - психиатр должен уговорить пациента избавиться от этой выдуманной болезни.",
    name = "Mãos suadas",
  --  symptoms = "Sintomas - рукопожатие пациента напоминает сжимание мокрой губки.",
  },
  serious_radiation = {
  --  cause = "Causa - жевание изотопов плутония.",
  --  cure = "Cura - пациента нужно как следует промыть под обеззараживающим душем.",
    name = "Radiação severa",
  --  symptoms = "Sintomas - пациент себя очень, очень плохо чувствует.",
  },
  gut_rot = {
    cause = "Causa - Mistura de Whisky 12 anos Mrs. O'Mallley's com xarope.",
    cure = "Cura - A Enfermeira pode administrar uma seleção de químicos dissolventes que podem revestir o estômago.",
    name = "Intestino podre",
    symptoms = "Sintomas - sem tosse mas sem parede do estômago também.",
  },
  iron_lungs = {
  --  cause = "Causa - городской смог и дым от шашлыков.",
  --  cure = "Cura - два хирурга проводят операцию чтобы удалить затвердевшие легкие.",
    name = "Pulmões de Aço",
  --  symptoms = "Sintomas - способность выдыхать огонь и громко кричать под водой.",
  },
  broken_wind = {
  --  cause = "Causa - упражнения на беговой дорожке после еды.",
  --  cure = "Cura - насыщенная особыми водянистыми атомами микстура выпивается залпом.",
    name = "Vento quebrado",
  --  symptoms = "Sintomas - представляют опасность для находящих позади пациента.",
  },
  kidney_beans = {
  --  cause = "Causa - разгрызание ледяных кубиков в напитках.",
  --  cure = "Cura - два хирурга должны удалить бобы, не прикасаясь к почкам.",
    name = "Pedras no rim",
  --  symptoms = "Sintomas - боль и частые визиты в туалет.",
  },
  transparency = {
  --  cause = "Causa - слизывание йогурта с крышечек упаковок.",
  --  cure = "Cura - специально охлажденная и подкрашенная в аптеке вода вылечит эту болезнь.",
    name = "Transparência",
  --  symptoms = "Sintomas - плоть становится прозрачной и ужасно выглядит.",
  },
  broken_heart = {
  --  cause = "Causa - кто-нибудь более молодой, богатый и стройный чем пациент.",
  --  cure = "Cura - два хирурга вскрывают грудную клетку и, затаив дыхание, аккуратно собирают сердце.",
    name = "Coração partido",
  --  symptoms = "Sintomas - плач и боли в мышцах от разрывания праздничных фотографий.",
  },
  slack_tongue = {
  --  cause = "Causa - хроническое обсуждение мыльных опер.",
  --  cure = "Cura - язык помещается в языкорезку и укорачивается быстро, точно, безжалостно.",
    name = "Língua negligente",
  --  symptoms = "Sintomas - язык примерно в пять раз увеличен в размерах.",
  },
  tv_personalities = {
    cause = "Causa - Assistar à televisão o dia todo.",
    cure = "Cura - Um psiquiatra bem treinado deverá convencer o paciente à vender a TV e comprar um rádio.",
    name = "Personalidade da TV",
    symptoms = "Sintomas - Ilusões sobre ser capaz de apresentar um programa de variedades matinal.",
  },
  ruptured_nodules = {
  --  cause = "Causa - прыжки с тарзанкой в холодную погоду.",
  --  cure = "Cura - хирург удаляет грыжу твердой, уверенной рукой.",
    name = "Ruptura de Nódulos",
  --  symptoms = "Sintomas - невозможность сидеть с комфортом.",
  },
  fractured_bones = {
  --  cause = "Causa - падение с большой высоты на бетонные поверхности.",
  --  cure = "Cura - сперва накладывается гипс, затем он удаляется при помощи устройства с лазером.",
    name = "Fratura nos ossos",
  --  symptoms = "Sintomas - громкий треск и неспособность использовать поврежденные конечности.",
  },
  chronic_nosehair = {
  --  cause = "Causa - высокомерное фыркание в присутствии менее успешных людей.",
  --  cure = "Cura - отвратительное противоволосяное зелье приготавливается в аптеке.",
    name = "Pêlos no nariz crônicos",
  --  symptoms = "Sintomas - нособорода, в которой можно свить гнездо.",
  },
}


-- 6. Faxes

  --[[
  epidemic = {
    cover_up_explanation_1 = "Или вы можете попытаться вылечить всех зараженных, пока про это не узнали в министерстве здравоохранения.",
    cover_up_explanation_2 = "Если к приезду инспектора эпидемия все еще будет бушевать, приготовьтесь к неприятностям.",
    choices = {
      cover_up = "Попытаться вылечить всех зараженных пациентов пока есть время и пока он еще в больнице.",
      declare = "Объявить об эпидемии. Признать свою вину и заплатить штраф.",
    },
    disease_name = "Ваши доктора обнаружили особо заразный подвид %s.",
    declare_explanation_fine = "Вы можете объявить об эпидемии, заплатить штраф в %d$, тогда вам немедленно окажут помощь в вакцинации. Ваша репутация несколько пострадает.",
  },
  epidemic_result = {
    fine_amount = "Правительство объявило чрезвычайное положение, а вас оштрафовали на %d$.",
    close_text = "Ура!",
    hospital_evacuated = "У комиссии не осталось другого выбора, кроме как объявить эвакуацию.",
    succeeded = {
      part_1_name = "До департамента здоровья дошли слухи, что в вашей больнице бушует эпидемия %s.",
      part_2 = "Однако, инспектору не удалось найти им подтверждение.",
    },
    compensation_amount = "Правительство решило компенсировать ущерб, который эти враки нанесли репутации вашей больницы, в сумме %d$.",
    failed = {
      part_1_name = "В попытке скрыть наличие заразной инфекции %s,",
      part_2 = "ваши сотрудники вызвали распространение болезни по округе.",
    },
    rep_loss_fine_amount = "Журналисты уже заточили карандаши. Ваша репутация серьезно пострадает. К тому же, вас оштрафовали на %d$.",
  },
  --]]

fax = {
  --  VIP
  vip_visit_query = {
    choices = {
      invite = "Enviar um convite oficial ao V.I.P.",
      refuse = "Despiste o V.I.P. com desculpas.",
    },
    vip_name = "%s expressou a vontade de visitar seu hospital",
  },
  vip_visit_result = {
    --telegram = "Телеграмма!",
    remarks = {
      --good = {
      --  [1] = "Какая хорошая больница! Спасибо за приглашение.",
      --  [2] = "Хмм... Определенно, неплохое медицинское учреждение.",
      --  [3] = "Мне очень понравилась ваша милая больничка. Ну, кто со мной в ресторан?",
      --},
      super = {
        [1] = "É um super hospital! Eu deveria saber, já estive aqui algumas vezes.",
      },
      --[[
      bad = {
        [1] = "Не надо было мне приходить. Лучше бы я просидел четырехчасовую оперу!",
        [2] = "Мне до сих пор не по себе. Они правда называют свое заведение больницей? Больше похоже на свинарник!",
        [3] = "Я сыт по горло визитами в подобные выгребные ямы и постоянным вниманием прессы! Я подаю в отставку.",
      },
      mediocre = {
        [1] = "Что ж, я видал и похуже. Им есть куда расти.",
        [2] = "Не знаю, стоит ли туда обращаться, если почувствуете себя неважно.",
        [3] = "Что я могу сказать, больница как больница. Я ожидал большего.",
      },
      very_bad = {
        [1] = "Ну и свалка! Я приложу все усилия чтобы ее закрыли.",
        [2] = "Никогда не видел больницы хуже. Какой позор!",
        [3] = "Я потрясен. Это нельзя назвать больницей! Мне надо выпить.",
      },

      --]]
      -- tem good? Recebi um 'Now that's what I call a hospital'
    },
    rep_boost = "Sua reputação na comunidade acaba de aumentar.",
    vip_remarked_name = "Após visitar seu hospital, %s declarou:",
    cash_grant = "Você foi recompensado com uma quantia de $ %d.",
    --rep_loss = "Ваша репутация пострадала.",
    close_text = "Obrigado por visitar o hospital.",

  },
  --  Descoberta de Nova Doença
  disease_discovered = {
    discovered_name = "Sua equipe descobriu uma nova condição : %s",
  },

  disease_discovered_patient_choice = {
    need_to_build = "Você precisa construir um %s para lidar com ela.",
    --need_to_employ = "Наймите %s чтобы вылечить это.",
    what_to_do_question = "O que deve ser feito com o paciente ?",
    --guessed_percentage_name = "Мы не совсем уверены, что с этим пациентом. Существует вероятность в %d% что это %s",
    choices = {
      send_home = "Mandar o paciente para casa",
      research = "Encaminhar o paciente ao Departamento de Pesquisas.",
      wait = "Pedir ao paciente esperar um pouco no Hospital.",
    },
    disease_name = "Sua equipe descobriu uma nova condição: %s",
    --need_to_build_and_employ = "Можно будет попробовать, если вы построите %s и наймете %s .",
    can_not_cure = "Você não pode curar esta doença.",
  },
  diagnosis_failed = {
    choices = {
      send_home = "Enviar o Paciente para casa.",
      take_chance = "Dar ao Paciente um possibilidade de cura.",
      wait = "Pedir ao Paciente aguardar enquanto você construir mais salas de diagnóstico.",
    },
    situation = "Nós esgotamos todas as possibilidades de diagnóstico e ainda não temos certeza do que há de errado com o paciente.",
    what_to_do_question = "O que deve ser feito com o paciente ?",
    partial_diagnosis_percentage_name = "Existe, entretanto, uma possibilidade de %d% de termos identificado que tipo de %s o paciente contraiu.",
  },
  --[[
  emergency = {
  locations = {
    [1] = "Новоуренгойский химзавод",
    [2] = "Фальшивый Университет",
    [3] = "Центр Принудительного Озеленения",
    [4] = "Институт Разработки Опасных Штук",
    [5] = "Клуб Хороших Танцоров",
    [6] = "Издательство «МакулатураПресс»",
    [7] = "Похоронное бюро «Безенчук и нимфы»",
    [8] = "Китайский ресторанчик дяди Вонга",
    [9] = "ГлавХимСбытСтыдЗагранПоставка",
  },
    num_disease = "У нас тут %d человек с диагнозом %s и им требуется немедленное лечение.",
    cure_possible_drug_name_efficiency = "У вас есть все необходимое оборудование и специалисты. У вас есть нужное лекарство. Это %s и оно эффективно на %d%",
    cure_not_possible_employ = "Вам потребуется нанять %s",
    cure_not_possible = "Сейчас вы не можете это вылечить.",
    cure_possible = "У вас есть все необходимое оборудование и специалисты, так что вы, наверное, справитесь.",
    choices = {
      accept = "Да. Я разберусь с этой ситуацией.",
      refuse = "Нет. Я отказываюсь в этом участвовать.",
    },
    location = "На предприятии %s чрезвычайная ситуация.",
    cure_not_possible_build = "Вам надо будет построить %s",
    cure_not_possible_build_and_employ = "Вам надо будет построить %s и нанять %s",
    bonus = "Вознаграждение за помощь составит %d. Если вы не справитесь, ваша репутация серьезно пострадает.",
  },
  --]]
  emergency_result = {
    earned_money = "De um bônus total de $ %d, você ganhou $ %d.",
    close_text = "Clique para sair.",
    saved_people = "Você salvou %d de um total de %d pacientes.",
  },
}

-------------------------------  OVERRIDE  ----------------------------------
adviser.warnings.money_low = "Você está ficando sem dinheiro!" -- Funny. Exists in German translation, but not existent in english?
-- TODO: tooltip.graphs.reputation -- this tooltip talks about hospital value. Actually it should say reputation.
-- TODO: tooltip.status.close -- it's called status window, not overview window.

-- tooltip.staff_list.next_person, prev_person is rather next/prev page (also in german, maybe more languages?)
tooltip.staff_list.next_person = "Próxima página"
tooltip.staff_list.prev_person = "Página anterior"
tooltip.status.reputation = "Sua reputação não deve ficar abaixo de %d. Atualmente é de %d"
tooltip.status.balance = "Seu saldo bancário não deve vicar abaixo de %d. Atualmente é de %d"

-- The originals of these two contain one space too much
fax.emergency.cure_not_possible_build = "Você precisará construir um(a) %s"
fax.emergency.cure_not_possible_build_and_employ = "Você precisará construir um(a) %s e empregar um(a) %s"
fax.emergency.num_disease = "Existem %d pessoas com %s e eles precisam urgente de sua atenção."
adviser.goals.lose.kill = "Se matar mais %d pacientes perderá esta fase!"

-- Improve tooltips in staff window to mention hidden features
tooltip.staff_window.face = "This person's face - click to open management screen"
tooltip.staff_window.center_view = "Clique com o botão esquerdo para dar um zoom no quadro de funcionários e botão direito para circular membros da equipe"

-- These strings are missing in some versions of TH (unpatched?)
confirmation.restart_level = "Tem certeza que deseja reiniciar esta fase?"
-- TODO adviser.multiplayer.objective_completed
-- TODO adviser.multiplayer.objective_failed

-------------------------------  NEW STRINGS  -------------------------------
date_format = {
  daymonth = "%1% %2:months%",
}

object.litter = "Lixo"
tooltip.objects.litter = "Lixo: Um paciente jogou no chão porque não achou uma lixeira próxima."

tooltip.fax.close = "Fechar esta janela sem apagar a mensagem"
tooltip.message.button = "Clique com o botão esquerdo para abrir a mensagem"
tooltip.message.button_dismiss = "Clique com o botão esquerdo para abrir a mensagem, e com o botão direito para descartá-la"
tooltip.casebook.cure_requirement.hire_staff = "Você precisa contratar funcionários para administrar este tratamento"
tooltip.casebook.cure_type.unknown = "Você ainda não sabe como tratar esta doença"
tooltip.research_policy.no_research = "Nenhuma pesquisa desta categoria está sendo conduzida neste momento"
tooltip.research_policy.research_progress = "Progresso para uma nova descoberta nesta categoria: %1%/%2%"


adviser = {
  room_forbidden_non_reachable_parts = "Construir a sala neste local resultará em alas do hospital que não poderão ser acessadas.",
  warnings = {
    no_desk = "Você precisa comprar um balcão de recepção e contratar uma recepcionista em algum momento!",
    no_desk_1 = "Se você quer que os pacientes venham ao seu hospital, você precisa contratar uma recepcionista e comprar um balcão para recepcioná-los!",
    no_desk_2 = "Excelente, isso provavelmente é um recorde mundial - quase um ano e nenhum paciente! Se você deseja continuar administrando este hospital, você precisa urgente contratar uma recepcionista e comprar um balcão para que ela possa trabalhar!",
    no_desk_3 = "That's just brilliant, nearly a year and you don't have a staffed reception! How do you expect to get any patients, now get it sorted out and stop messing around!",
    cannot_afford = "Seu saldo bancário é insuficiente para contratar esta pessoa!", -- I can't see anything like this in the original strings
    falling_1 = "Hey! Isso não é engraçado, cuidado onde aponta este mouse; alguém pode se machucar!",
    falling_2 = "Gostou da queda? Pare de bagunçar!",
    falling_3 = "Ai, isso dói, alguém chame um médico!",
    falling_4 = "Isto é um Hospital, não um parque de diversões!",
    falling_5 = "Este não é o local para empurar as pessoas, elas estão doentes sabia?!",
    falling_6 = "Aqui não é uma pista de boliche, pessoas doentes não deveriam ser tratadas desta forma!",
    research_screen_open_1 = "Você precisa construir um Departamento de Pesquisas antes de acessar a tela de Pesquisas.",
    research_screen_open_2 = "Pesquisas estão desabilitadas nesta fase.",
  },
  cheats = {
    th_cheat = "Parabéns, você habilitou os códigos de trapaça!",
    crazy_on_cheat = "Oh não! Todos os médicos ficaram malucos!",
    crazy_off_cheat = "Ufa… o médicos recobraram sua sanidade.",
    roujin_on_cheat = "Desafio Roujin ativado! Boa sorte...",
    roujin_off_cheat = "Desafio Roujin desativado.",
    hairyitis_cheat = "Trapaça de Cabelulite ativada!",
    hairyitis_off_cheat = "Trapaça de Cabelulite desativada.",
    bloaty_cheat = "Bloaty Head cheat activated!",
    bloaty_off_cheat = "Bloaty Head cheat deactivated.",
  },
}

dynamic_info.patient.actions.no_gp_available = "Waiting for you to build a GP's office"
dynamic_info.staff.actions.heading_for = "Indo para %s"
dynamic_info.staff.actions.fired = "Demitido"

progress_report.free_build = "CONSTRUÇÃO LIVRE"

fax = {
  choices = {
    return_to_main_menu = "Retornar ao menu principal",
    accept_new_level = "Ir para a próxima fase",
    decline_new_level = "Continuar jogando nesta fase um pouco mais",
  },
  emergency = {
    num_disease_singular = "Existe uma pessoa com %s que precisa urgente de sua atenção.",
    free_build = "Se você for bem sucedido sua reputação aumentará, mas se você falhar sua reputação será bastante prejudicada.",
  },
  vip_visit_result = {
    remarks = {
      free_build = {
        "Que hospital maravilhoso! Não é tão difícil manter tudo funcionando com dinheiro ilimitado, não é mesmo?",
        "Eu não sou economista, mas acho que eu também conseguiria administrar esse hospital, se é que você me entende...",
        "Um hospital em ótimo funcionamento. Mas cuidado com a recessão! Ah, me esqueci... você não teve que se preocupar com isso.",
      }
    }
  }
}

letter = {
  dear_player = "Prezado(a) %s",
  custom_level_completed = "Parabéns! Você completou todos os objetivos desta fase customizada!",
  return_to_main_menu = "Deseja retornar ao menu principal ou continuar jogando?",
}

install = {
  title = "--------------------------------- CorsixTH Setup ---------------------------------",
  th_directory = "CorsixTH precisa de uma cópia dos arquivos de dados do jogo original - Theme Hospital (ou demo) para executar. Utilize o seletor abaixo para localizar o diretório onde o jogo Theme Hospital está instalado.",
  exit = "Sair",
}

misc.not_yet_implemented = "(não foi implementado ainda)"
misc.no_heliport = "Ou você ainda não descobriu nenhuma doença ou este hospital não possui heliporto. Você pode também necessitar construir uma recepção e contratar uma recepcionista."






tooltip.handyman_window = {
  parcel_select = "O prédio no qual este funcionário executará suas tarefas, clique para mudar"
}

handyman_window = {
  all_parcels = "Todos os prédios",
  parcel = "Prédio"
}



errors = {
  dialog_missing_graphics = "Desculpe, os arquivos de dados da demo não contém este diálogo.",
  save_prefix = "Erro ao salvar jogo: ",
  load_prefix = "Erro ao carregar jogo: ",
  map_file_missing = "Não foi possível encontrar o arquivo de mapa %s para esta fase!",
  minimum_screen_size = "Favor digitar dimensões de tela de pelo menos 640x480.",
  maximum_screen_size = "Favor digitar dimensões de tela de no máximo 3000x2000.",
  unavailable_screen_size = "O tamanho da tela que você digitou não está disponível em tela cheia.",
}

confirmation = {
  needs_restart = "Para alterar esta configuração é necessário reiniciar o CorsixTH. Qualquer alteração não salva será perdida. Tem certeza que deseja fazer isso?",
  abort_edit_room = "Você está editando uma sala. Se todos os objetos necessário estiverem colocados ela será completada, caso contrário ela será removida. Continuar?",
}

information = {
  custom_game = "Bem-vindo ao CorsixTH. Se divirta neste mapa personalizado!",
  no_custom_game_in_demo = "Desculpe, mas a versão de demonstração não pode jogar mapas pesonalizados.",
  cannot_restart = "Infelizmente este mapa personalizado foi salvo antes que a funcionalidade de reiniciação fosse implementada.",
  very_old_save = "Houveram muitas mudanças no jogo desde que você começou a jogar este mapa. Para ter certeza que todas as funcionalidades estão funcionando considere recomeçar o mapa.",
  level_lost = {
    "Parabéns! Você perdeu a fase. Mais sorte na próxima vez!",
    "Você perdeu porque:",
    reputation = "Sua reputação caiu abaixo de %d.",
    balance = "Seu saldo no banco caiu abaixo de %d.",
    percentage_killed = "Você matou mais de %d porcento dos pacientes.",
  },
  cheat_not_possible = "Você não pode usar esta trapaça nesta fase. Até na hora de trapacear você falha, irônico não?",
}

tooltip.information = {
  close = "Fechar a janela de informações",
}



debug_patient_window = {
  caption = "Depurar Paciente",
}

cheats_window = {
  caption = "Cheats/Trapaças",
  warning = "Aviso: você não ganhará nenhum ponto bônus no final desta fase se você trapacear!",
  cheated = {
    no = "Trapaças usadas: Não",
    yes = "Trapaças usadas: Sim",
  },
  cheats = {
    money = "Trapaça Financeira",
    all_research = "Trapaça Todas as Pesquisas Realizadas",
    emergency = "Criar Emergência",
    vip = "Criar visitante VIP",
    earthquake = "Criar Terremoto",
    create_patient = "Criar Paciente",
    end_month = "Final de Mês",
    end_year = "Final de Ano",
    lose_level = "Perder a Fase",
    win_level = "Ganhar a Fase",
  },
  close = "Fechar",
}

tooltip.cheats_window = {
  close = "Fechar a janela de trapaças",
  cheats = {
    money = "Adicionar 10.000 no saldo bancário.",
    all_research = "Completar todas as pesquisas.",
    emergency = "Criar uma emergência.",
    vip = "Criar um visitante VIP.",
    earthquake = "Criar um terremoto.",
    create_patient = "Criar um Paciente na borda do mapa.",
    end_month = "Pular para o final do mês.",
    end_year = "Pular para o final do ano.",
    lose_level = "Perder esta fase.",
    win_level = "Ganhar esta fase.",
  }
}

calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = "%d chamadas; %d assinaladas",
  staff = "%s - %s",
  watering = "Regando @ %d,%d",
  repair = "Consertar %s",
  close = "Fechar",
}

tooltip.calls_dispatcher = {
  task = "Lista de tarefas - clique na tarefa para abrir a janela do funcionário responsável e ir para o local da tarefa.",
  assigned = "Esta janela será marcada se alguém for designado para a tarefa correspondente.",
  close = "Fechar a janela de calls dispatcher",
}



staff_class = {
  nurse                 = "Enfermeira",
  doctor                = "Doutor",
  handyman              = "Funcionário da Manutenção",
  receptionist          = "Recepcionista",
  surgeon               = "Cirurgião",
}




-- Objects
object = {
  desk                  = "Secretária",
  cabinet               = "Arquivo",
  door                  = "Porta",
  bench                 = "Banco",
  table1                = "Mesa", -- unused object
  chair                 = "Cadeira",
  drinks_machine        = "Máquina de Bebidas",
  bed                   = "Cama",
  inflator              = "Inflador",
  pool_table            = "Mesa de Bilhar",
  reception_desk        = "Recepção",
  table2                = "Mesa", -- unused object & duplicate
  cardio                = "Máquina de Eletrocardiograma",
  scanner               = "Scanner",
  console               = "Console",
  screen                = "Tela",
  litter_bomb           = "Bomba de lixo",
  couch                 = "Sofá",
  sofa                  = "Sofá",
  crash_trolley         = "Trolley",
  tv                    = "TV",
  ultrascanner          = "Ultrasom",
  dna_fixer             = "Fixador de DNA",
  cast_remover          = "Removedor de Gesso",
  hair_restorer         = "Restaurador de Cabelo",
  slicer                = "Fatiador",
  x_ray                 = "Raio-X",
  radiation_shield      = "Escudo de Radiação",
  x_ray_viewer          = "Visualizador de Raio-X",
  operating_table       = "Mesa de Operação",
  lamp                  = "Lampâda", -- unused object
  toilet_sink           = "Pia",
  op_sink1              = "Pia",
  op_sink2              = "Pia",
  surgeon_screen        = "Tela de Operação",
  lecture_chair         = "Cadeira de aluno",
  projector             = "Projetor",
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
  bin                   = "Lixeira",
  toilet                = "Cabine de Toalete",
  swing_door1           = "Porta",
  swing_door2           = "Porta",
  shower                = "Chuveiro",
  auto_autopsy          = "Auto-Autópsia",
  bookcase              = "Estante de Livros",
  video_game            = "Fliperama",
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
  reception         = "Recepção",
  destroyed         = "Destruído",
  corridor_objects  = "Objetos de Corredor",

  gps_office        = "Clínica Geral",
  psychiatric       = "Psiquiatria",
  ward              = "Enfermaria",
  operating_theatre = "Sala de Operações",
  pharmacy          = "Farmácia",
  cardiogram        = "Máq. de Eletrocardiograma",
  scanner           = "Scanner",
  ultrascan         = "Ultrasom",
  blood_machine     = "Sala de Análises Sanguíneas",
  x_ray             = "Raio-X",
  inflation         = "Inflador",
  dna_fixer         = "Fixador de DNA",
  hair_restoration  = "Recuperador de Cabelo",
  tongue_clinic     = "Fatiador",
  fracture_clinic   = "Clínica de Fraturas",
  training_room     = "Sala de Aula",
  electrolysis      = "Sala de Electrolisador",
  jelly_vat         = "Moldador Gelatinoso",
  staffroom         = "Sala de Relaxamento",
  -- rehabilitation = "Reabilitação", -- unused
  general_diag      = "Diagnóstico Geral",
  research_room     = "Departamento de Pesquisas",
  toilets           = "Toaletes",
  decontamination   = "Descontaminação",
}



-- 8.  Objetivos da Fase
introduction_texts = {
  demo = {
    "Bem-vindo ao hospital de demonstração!",
    "Infelizmente esta versão demo são possui esta fase. Entretanto, teremos aqui o suficiente para mantê-lo ocupado por enquanto !",
    "Você encontrará várias doenças que necessitarão de salas diferentes para cura. De tempos em tempos, emergências ocorrerão. E você precisará pesquisar por salas adicionais usando o Departamento de Pesquisas.",
    "Seu objetivo é ter um saldo bancário de $100.000,00, o valor do hospital em $ 70.000,00 e uma reputação de 700, enquanto você cura pelo menos 75% de seus pacientes.",
    "Certifique-se que sua reputação não fique abaixo de 300 e você não mate mais de 40% dos seus pacientes, senão você perde.",
    "Boa sorte!",
  },
  level1 = {
    [1] = "Bem-vindo(a) ao seu primeiro hospital !//",
    [2] = "Tenha-o pronto e rodando colocando um balcão de recepção, construindo um consultório de clínica geral e contratando uma recepcionista e médico. ",
    [3] = "Então espere os negócios prosperarem.",
    [4] = "É uma boa idéia construir um departamento de psiquiatria e contratar um médico psiquiatra, além de uma farmácia e enfermeira que também serão essenciais para curar seus pacientes. ",
    [5] = "Cuidado com os casos de 'Cabeça inchada' - Uma sala com um Inflador resolverá os casos rapidamente.",
    [6] = "Seu objetivo será curar 10 pessoas e garantir que sua reputação não fique abaixo de 200.",
    [7] = "",
  },
  level2 = {
    [1] = "Há uma grande variedade de doenças nesta área, sendo assim planeje seu hospital para lidar com mais pacientes, além de construir um Departamento de Pesquisas. ",
    [2] = "Lembre-se de manter o estabelecimento limpo e procure manter sua reputação a mais alta possível - você estará lidando com doenças como Língua negligente, então precisará de um Fatiador. Adicionalmente, poderá construir uma máquina de Eletrocardiograma para ajudá-lo a diagnosticar novas doenças",
    [3] = "Ambas precisarão ser pesquisadas antes de serem construídas. Agora você poderá comprar lotes de terreno extras para expandir seu hospital - use o Mapa da Cidade para fazê-lo.",
    [4] = "Tenha como objetivo uma reputação de 300, um saldo bancário de $10.000,00 e 40 pessoas curadas.",
    [5] = "",
    [6] = "",
  },
  level3 = {
    [1] = "Desta vez, você irá construir seu hospital em uma área nobre da cidade.",
    [2] = "O Ministro da Saúde está contando com você para manter os níveis da saúde por aqui.",
    [3] = "Você precisa ganhar uma boa reputação para começar, mas uma vez que seu hospital esteja estabelecido, concentre-se em lucrar a maior quantidade de dinheiro que puder.",
    [4] = "Há uma grande possibilidade de ter de lidar com Emergências - isso acontece quando um grande número de pessoas chega de uma só vez, na mesma condição clínica - Curando-as à tempo você ganhará uma boa reputação e um grande bônus.",
    [5] = "Doenças como o Complexo de Rei podem ocorrer, e você deverá planejar seu orçamento para construir uma Sala de Operações com uma Enfermaria ao lado. ",
    [6] = "Consiga $ 20.000,00 em dinheiro para vencer a fase.",
    [7] = "",
    [8] = "",
  },
  level4 = {
    [1] = "Mantenha seus pacientes felizes, lide com eles da forma mais eficiente que puder e mantenha o número de óbitos no mínimo.",
    [2] = "Sua reputação está em jogo, portanto mantenha-a a mais alta que conseguir.",
    [3] = "Não se preocupe tanto com dinheiro - ele virá a medida que sua reputação cresce.",
    [4] = "Você terá a possibilidade de treinar seus médicos para ampliar suas habilidades também, pois ele poderão ter que lidar com pacientes mais opacos que a maioria.",
    [5] = "Consiga uma reputação acima de 500 para vencer a fase.",
    [6] = "",
  },
  level5 = {
    [1] = "Você administrará agora um hospital ocupado, lidando com um grande variedade de casos.",
    [2] = "Seus médicos são todos calouros da escola de medicina, portanto será de vital importância construir um sala de treinamento e treiná-los até um nível aceitável.",
    [3] = "Você possui apenas três médicos sêniores para ajudá-lo a ensinar sua inexperiente equipe, portanto mantenha-os felizes.",
    [4] = "Note, também, que as fundações deste hospital ficam no centro da falha geológica de São Android - existe um risco eminente de terremotos. que causarão um estrago significativo em seus equipamentos, atrapalhando uma calma administração de seu hospital.",
    [5] = "Sua reputação deve ultrapassar a marca de 400, e um saldo bancário de $ 50.000,00 para ter sucesso - além de curar pelo menos 200 pacientes.",
    [6] = "",
    [7] = "",
  },
  level6 = {
    [1] = "Utilize todo seu know-how para montar um hospital eficiente que gere lucro e possa lidar com qualquer coisa que o público doente colocar em suas mãos.",
    [2] = "Você deve estar ciente que a atmosfera do local é propícia para alastrar germes e infecções - Mantenha a instituição espetacularmente limpa se não quiser enfrentar uma série de epidemias envolvendo os pacientes.",
    [3] = "Suas metas são fazer $ 150.000,00 em dinheiro e o valor do hospital deve valer pelo menos   $140.000,00",
    [4] = "",
  },
  level7 = {
    [1] = "Você está sendo observado de perto pelo Ministro de Saúde, então certifique-se que seus números indiquem que você está ganhando muito dinheiro e reputação crescente.",
    [2] = "Não se dê ao luxo de mortes desnecessárias - elas são ruins para os negócios",
    [3] = "Certifique-se que seu quadro de funcionários seja hábil e que você possua todos os equipamentos que precisa.",
    [4] = "Obtenha uma reputação de 600 e $ 200.000,00 de saldo bancário.",
  },
  level8 = {
    [1] = "Só depende de você construir o hospital mais rentável e eficiente possível.",
    [2] = "As pessoas por aqui são bem afortunadas, portanto 'enfie a faca' como puder. ",
    [3] = "Lembre-se, curar pessoas é uma coisa muito legal, mas do que você realmente PRECISA é da grana que elas trarão.",
    [4] = "Limpe estas pessoas doentes, consiga incríveis $ 300.000,00 para vencer esta fase.",
    [5] = "",
  },
  level9 = {
    [1] = "Tendo enchido os bolsos e custeado a nova limousine do Ministro da Saúde, finalmente você pode voltar a criar um hospital modelo em benefício dos mais necessitados. ",
    [2] = "Você pode esperar muitos e diversos problemas por aqui - Treine muito bem seus funcionários, tenha boas salas para cobrir todas as possibilidades.",
    [3] = "Seu hospital precisa valer $200.000,00 e precisará de $400.000,00 no balco - qualquer coisa menos do que isso você não poderá terminar esta fase.",
    [4] = "",
    [5] = "",
  },
  level10 = {
    [1] = "Assim que você cuidar de todas as doenças que surgirem por estas bandas, o Ministro solicitou que você se concentre na eficiência de seus medicamentos. ",
    [2] = "Existem algumas queixas feitas no 'SemDoenças' - que faz Auditorias na área da Saúde - então para ficar bonito na foto certifique-se que seus medicamentos sejam extremamente eficientes. Portanto, o hospital precisar ficar ótimo. Mantenha os óbitos em níveis baixos.",
    [3] = "Fica a dica, deixe espaço livre para o Moldador Gelatinoso.",
    [4] = "Pesquise e crie todos os medicamento com pelo menos 80% de eficiência, obtenha uma reputação de 650 e um saldo bancário de $500.000,00 para vencer! ",
    [5] = "",
  },
  level11 = {
    [1] = "Você está tendo a oportunidade de construir a última palavra em hospitais. Está em uma área extremamente privilegiada, e o ministro gostaria de ver o melhor hospital possível.",
    [2] = "A expectativa é que você faça muito dinheiro, tenha uma reputação soberba e esteja preparado para qualquer eventualidade.",
    [4] = "É um trabalho importante este. ",
    [5] = "Você precisa ser especial para conseguir se dar bem nessa fase.",
    [6] = "Existem vários relatos de OVNIs nessa área. Certifique-se que seus funcionários estejam preparados para um eventual contato imediato.",
    [7] = "Seu hospital precisa valer $240,000, você precisará de $500,000 no banco e uma reputação de 700.",
  },
  level12 = {
  },
  level13 = {
  },
  level14 = {
  },
  level15 = {
  },
  level16 = {
  },
  level17 = {
  },
  level18 = {
  },
}

graphs = {
  money_in   = "Receitas",
  money_out  = "Despesas",
  wages      = "Salários",
  balance    = "Balanço",
  visitors   = "Visitantes",
  cures      = "Curas",
  deaths     = "Óbitos",
  reputation = "Reputação",

  time_spans = {
    S[7][12],
    S[7][13],
    S[7][14],
  }
}

tooltip = {
  toolbar = {
    bank_button = "Clique com o botão esquerdo para consultar o Gerente do Banco, botão direito para extrato bancário",
    balance = "Seu saldo bancário",
    reputation = "Sua reputação",
    date = "Calendário",
    rooms = "Construir Salas",
    objects = "Оbjetos de corredor",
    edit = "Editar Salas",
    hire = "Contratação de Pessoal",
    staff_list = "Quadro de Funcionários",
    town_map = "Mapa de Cidade",
    casebook = "Livro de Diagnósticos",
    research = "Pesquisa",
    status = "Situação",
    charts = "Gráficos",
    policy = "Políticas",
  },
}

-- Rooms
room_classes = {
  -- S[19][2] -- "corridors" - unused for now
  diagnosis  = "Diagnóstico",
  treatment  = "Tratamento",
  clinics    = "Clínicas",
  facilities = "Acomodações",
}

--]]
confirmation = {
  abort_edit_room = "Está construindo ou editando uma sala. Se todos os objectos necessários estiverem colocados a sala estará terminada, caso contrário será eliminada. Continuar?",
  return_to_blueprint = "Voltar ao modo de desenho?",
  restart_level = "Deseja realmente reiniciar esta fase?",
  delete_room = "Deseja realmente remover esta sala?",
  quit = "Sair do jogo?",
  needs_restart = "Estas alterações requerem reiniciar o jogo, todo progresso não gravado será perdido. Continuar?",
  overwrite_save = "Já existe uma gravação neste arquivo. Gravar por cima?",
  sack_staff = "Demitir este funcionário ?",
  replace_machine = "Quer substituir %s por $%d?",
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

room_descriptions = {
  ultrascan = {
    [1] = "Ultrasom//",
    [2] = "O ultrasom é a última palavra em equipamento de diagnóstico. Custa caro, mais vale a pena se deseja um diagnóstico soberbo em seu hospital.//",
    [3] = "The Ultrasom precisa de manutenção e um médico (qualquer nível) para funcionamento. ",
  },
  gp = {
    [1] = "Clínica Geral//",
    [2] = "Esta é a sala de diagnósticos primordial de um hospital. Novos pacientes sentarão aqui para descobrir o que há de errado com eles. Serão enviados posteriormente para outras salas de dianóstico ou para serem curados. Você poderá construir outra Sala de Clínica Geral se esta ficar muito ocupada. Quanto maior a sala for, mais objetos adicionais podem ser colocados nela, e maior o prestígio do médico. Isso vale igualmente para todas as outras salas.//",
    [3] = "A Sala de Clínica Geral precisa de um médico de qualquer nível. ",
  },
  fracture_clinic = {
    [1] = "Clínica de Fraturas//",
    [2] = "Aqueles pacientes azarados o bastante por terem seus ossos quebrados vem aqui. A máquina de remover gesso irá empregar lasers industriais para partir o mais duro gesso, causando apenas um ligeira agonia ao paciente.//",
    [3] = "A Clínica de Fraturas precisa de uma Enfermeira para funcionamento e contínua manutenção. ",
  },
  tv_room = {
    [1] = "TV ROOM NOT USED",
  },
  inflation = {
    [1] = "Inflador//",
    [2] = "Pacientes que sofrerem da dolorosa-porém-engraçada condição de 'Cabeça Inchada' devem vir ao Inflador, onde seu avantajado crânico será estourado e reinflado instantaneamente na pressão correta.//",
    [3] = "O Inflador precisa de um médico de qualquer nível, além de cuidados constantes de um Funcionário da Manutenção. ",
  },
  jelly_vat = {
    [1] = "Clínica de Geléia//",
    [2] = "Pacientes amaldiçoados com a rídicula Geléite devem ser encaminhados para a Clínica de Geléia, e colocados no tanque de Geléia, sendo curados de uma maneira até então não compreendida totalmente pela medicina.//",
    [3] = "A Clínica de Geléia precisa de um médico de qualquer nível, e de cuidados dos funcionários da manutenção. ",
  },
  scanner = {
    [1] = "Ressonância Magnética//",
    [2] = "Os pacientes são diagnosticados de forma precisa usando esta máquina de Ressonância Magnética. Eles irão então ver um médico na Clínica Geral para tratamento posterior.//",
    [3] = "A máquina de Ressonância Magnética precisa de um médico de qualquer nível, além de manutenção. ",
  },
  blood_machine = {
    [1] = "Máquina de Sangue//",
    [2] = "A Máquina de Sangue é uma parte do arsenal de diagnósticos que verifica as células no sangue do paciente para descobrir o que há de errado com ele.//",
    [3] = "A Máquina de Sangue precisa de um médico de qualquer nível, além de manutenção. ",
  },
  pharmacy = {
    [1] = "Farmácia//",
    [2] = "Pacientes que tenham sido diagnosticados e seu tratamento prevê algum medicamento devem visitar a Farmácia para tomá-lo. Conforme novos medicamentos vão sendo pesquisados e disponibilizados, a sala vai ficando movimentada, portanto você pode ter a necessidade de construir outra no futuro.//",
    [3] = "A Farmácia precisa de uma Enfermeira. ",
  },
  cardiogram = {
    [1] = "Eletrocardiograma//",
    [2] = "Pacientes são diagnosticados e checados aqui, antes de voltarem à Sala de Clínica Geral para um diagnóstico final.//",
    [3] = "O Eletrocardiograma precisa de um médico de qualquer nível, além de manutenção. ",
  },
  ward = {
    [1] = "Enfermaria//",
    [2] = "Pacientes que forem mantidos aqui sob observação de uma Enfermeira durante diagnóstico. Eles permanecem aqui antes de serem operados.//",
    [3] = "A Enfermaria precisa de uma Enfermeira. ",
  },
  psych = {
    [1] = "Psiquiatria//",
    [2] = "Pacientes diagnosticados com males psiquiátricos devem visitar o Departamento de Psiquiatria para receber aconselhamento. Psiquiatras podem ainda fazer diagnósticos, descobrindo que tipo de mal o paciente possui, se há origem mental, tratando-se no divã.//",
    [3] = "O Departamento de Psiquiatria precisa de um Psiquiatra. ",
  },
  staff_room = {
    [1] = "Sala de Relaxamento//",
    [2] = "Sua equipe fica estressada ao longo de um dia de trabalho. Eles precisam desta sala para relaxar e descansar. Funcionários cansados trabalham em marcha lenta, exigem mais dinheiro e eventualmente pedem demissão, além de cometer mais erros. Construa uma sala de relaxamento com muitas possibilidades de entretenimento é muito interessante. Certifique-se que a sala comporte vários funcionários de uma só vez. ",
  },
  operating_theatre = {
    [1] = "Sala de Operações//",
    [2] = "Esta importante instalação é onde uma série de condições serão tratadas. Deve ter um bom tamanho, e deve ser ocupado com o equipamento correto. Ele é vital para seu hospital.//",
    [3] = "A Sala de Operações precisa de dois Cirurgiões. ",
  },
  training = {
    [1] = "Sala de Treinamento//",
    [2] = "Seus médicos de nível junior e pleno podem adquirir qualificações extras estudando nesta sala. Um Cirurgião, Pesquisador e/ou Psiquiatra Sênior pode passar este conhecimento para quaisquer médicos sendo treinados, e aqueles que já possuírem estas habilidades poderão aprimorá-las aqui.//",
    [3] = "A Sala de Treinamento precisa de um Doutor Sênior. ",
  },
  dna_fixer = {
    [1] = "Clínica de DNA//",
    [2] = "Pacientes que foram abduzidos por alienígenas de outro mundo deve ter seu DNA substituído nesta sala. A máquina de fixação de DNA é um equipamento complexo e pode ser sensato manter um extintor de incêndio dentro da sala, por via das dúvidas.//",
    [3] = "A máquina de fixação de DNA deverá ter manutenção constante de um funcionário, precisando de um Pesquisador para operá-la. ",
  },
  research = {
    [1] = "Departamento de Pesquisas//",
    [2] = "Novos medicamentos e cruas são inventados e aprimorados no Departamento de Pesquisas. Vital para seu hospital, fará maravilhas em seu percentual de curas.//",
    [3] = "A Departamento de Pesquisas precisa de um Pesquisador. ",
  },
  hair_restoration = {
    [1] = "Clínica de Restauração de Cabelos//",
    [2] = "Pacientes que sofrem de uma condição de calvície extrema serão encaminhados para a máquina de restauração de cabelos desta Clínica. Um médico irá operar a máquina, que irá fazer crescer quase instantaneamente um cabelo novo.//",
    [3] = "A Clínica de Restauração de Cabelos precisa de um médico de qualquer nível, além de cuidados de um funcionário da manutenção. ",
  },
  general_diag = {
    [1] = "Diagnósticos Gerais//",
    [2] = "Pacientes que necessitem de uma investigação mais profunda são analisados aqui. Se a Clínica Geral não encontrar o que há de errado com eles, Diagnósticos Gerais geralmente irá. Daqui ele é enviado de volta à Clínica Geral para análise dos resultados produzidos aqui.//",
    [3] = "O Diagnósticos Gerais precisa de um médico de qualquer nível.",
  },
  electrolysis = {
    [1] = "Sala de Eletrólise//",
    [2] = "Pacientes com Pelulite são encaminhados para esta sala, onde uma máquina especial chamada Eletrolizador arranca os pêlos e esteriliza os poros eletricamente usando um composto similar à uma argamassa.//",
    [3] = "A Sala de Eletrólise precisa de um médico de qualquer nível, além de cuidados de um funcionário da manutenção. ",
  },
  slack_tongue = {
    [1] = "Clínica de Língua Negligente//",
    [2] = "Paciente diagnosticados na Clínica Geral com Língua Negligente serão enviados para esta clínica para tratamento. O médico irá usando um maquinário de última geração para extender a língua e cortá-la fora, restaurando a saúde do paciente.//",
    [3] = "A Clínica de Língua Negligente precisa de um médico de qualquer nível, e manutenção frequente. ",
  },
  toilets = {
    [1] = "Toalete//",
    [2] = "Pacientes que ouvirem o chamado da natureza irão se aliviar no conforto deste toalete. Você poderá construir baias e lavatórios extras se houver a expectativa de muitos visitantes. Em alguns casos, considere construir toaletes em outros pontos do hospital. ",
  },
  no_room = {
    [1] = "",
  },
  x_ray = {
    [1] = "Raio-X//",
    [2] = "A máquina de Raio-X fotografa as pessoas por dentro usando radiação especial, fornecendo à equipe uma boa idéia do que há de errado com elas.//",
    [3] = "O Raio-X precisa de um médico de qualquer nível, além de manutenção.  ",
  },
  decontamination = {
    [1] = "Clínica de Descontaminação//",
    [2] = "Pacientes que foram expostos à radiação devem ser levados rapidamente à Clínica de Descontaminação. Esta sala contém um chuveiro lavar toda a horrível radiação e.. sujeira.//",
    [3] = "O chuveiro de descontaminação precisa de um médico de qualquer nível, além de cuidados de um funcionário da manutenção. ",
  },
}

pay_rise = {
  definite_quit = "Nada que você fizer vai me manter aqui, pra mim chega.",
  regular = {
    [1] = "Estou em frangalhos. Preciso de um bom descanso, além de um aumento de %d se você não quer me ver por aqui neste trabalho enfadonho.",
    [2] = "Estou muito cansado. Preciso de um descanso e um aumento de salário de %d, indo para %d. Faça agora, seu tirano!",
    [3] = "Veja bem, estou trabalhando como uma mula! Quero um bônus de %d para ficar neste hospital.",
    [4] = "Estou infeliz. Exijo um aumento de %d, aumentando meus honorários para %d, caso contrário estou fora.",
    [5] = "Meus pais haviam me dito que a área médica pagava bem. Então me dê um aumento de %d ou largo a área para fazer jogos de computador.",
    [6] = "Estou de saco cheio. Pague-me um salário decente, um aumento de %d deve bastar.",
  },
  poached = "Recebi uma proposta de %d feita pelo %s. Pague-me o mesmo ou estou fora.",
}

level_names = {
  [1] = "Toxilândia",
  [2] = "Sleepy Hollow",
  [3] = "Peito largo",
  [4] = "Frimpton-on-Sea",
  [5] = "Simplolândia",
  [6] = "Festering-on-the-Wold",
  [7] = "Greenpool",
  [8] = "Manquay",
  [9] = "Vila do Leste",
  [10] = "Eggsenham",
  [11] = "Croaking",
  [12] = "Battenburg",
  [13] = "Chumleigh",
  [14] = "Sova",
  [15] = "Enterra Enterra",
}

staff_descriptions = {
  good = {
    [1] = "Trabalha muito rápido e aplicado(a). ",
    [2] = "Muito consciente. Importa-se profundamente. ",
    [3] = "Possui várias habilidades. ",
    [4] = "Amistoso(a) e adora uma gargalhada. ",
    [5] = "Resistência admirável, trabalha pesado. ",
    [6] = "Educado(a) e cordial de forma notável. ",
    [7] = "Incrivelmente talentoso(a) e capaz. ",
    [8] = "Dedica-se muito ao trabalho designado. ",
    [9] = "Perfeccionista e persistente. ",
    [10] = "Dedicado(a) a ajudar pessoas com um sorriso no rosto. ",
    [11] = "Charmoso(a), educado(a) e prestativo(a). ",
    [12] = "Frequentemente muito motivado(a) e dedicado(a). ",
    [13] = "Bem-humorado(a) e muito trabalhador(a). ",
    [14] = "Leal e amigável. ",
    [15] = "Cuidadoso(a) e confiável em uma emergência.",
  },
  misc = {
    [1] = "Joga golfe. ",
    [2] = "Pratica mergulho. ",
    [3] = "Faz esculturas no gelo. ",
    [4] = "Bebe vinho. ",
    [5] = "Participa de rally. ",
    [6] = "Faz bungee-jump. ",
    [7] = "Coleciona latas de cerveja. ",
    [8] = "Gosta de mergulhar no público nos shows. ",
    [9] = "Jogar de praticar surf. ",
    [10] = "Jogar de praticar raffiting. ",
    [11] = "Destila whisky. ",
    [12] = "Especialista no 'faça-você-mesmo'. ",
    [13] = "Gosta de filmes de arte franceses. ",
    [14] = "Joga 'Theme Park' muito. ",
    [15] = "Possui carteira de habilitação E. ",
    [16] = "Corre de motocicleta. ",
    [17] = "Toca violino e violoncelo clássicos. ",
    [18] = "Adora colisões de trens. ",
    [19] = "Amante de cães. ",
    [20] = "Ouve rádio. ",
    [21] = "Toma banho frequentemente. ",
    [22] = "Instrutor de tricô. ",
    [23] = "Tira o miolo dos vegetais para usar como porta sabão. ",
    [24] = "Policial especial meio-período. ",
    [25] = "Ex-apresentador de programa de calouros. ",
    [26] = "Coleciona estilhaços da Segunda Guerra. ",
    [27] = "Restaurador de mobília. ",
    [28] = "Ouve rave e trip-hop. ",
    [29] = "Extermina insetos com desodorante spray. ",
    [30] = "Ridiculariza comediantes ruins. ",
    [31] = "Arruma confusão em reunião de condomínio. ",
    [32] = "Jardineiro incorrigível. ",
    [33] = "Contrabandeia relógios falsificados. ",
    [34] = "Vocalista de uma banda de rock and roll. ",
    [35] = "Adora os programas da televisão vespertina. ",
    [36] = "Cutuca trutas. ",
    [37] = "Isca turistas em museus. ",
  },
  bad = {
    [1] = "Lento e inquieto. ",
    [2] = "Preguiçoso e pouco motivado. ",
    [3] = "Mal treinado e ineficaz. ",
    [4] = "Rude e áspero. Afasta as pessoas. ",
    [5] = "Resistência terrível - tem uma gênio ruim. ",
    [6] = "Surdo como uma porta. Cheira à repolho. ",
    [7] = "Péssimo(a) no trabalho, meramente responsável. ",
    [8] = "Imprudente e distraído. ",
    [9] = "Estressado com tendência e cometer erros. ",
    [10] = "Retorcido e ressentido - explodindo de raiva. ",
    [11] = "Descuidado e propenso à acidentes. ",
    [12] = "Não se preocupa com o trabalho. Muito preguiçoso. ",
    [13] = "Tolo que gosta se assumir riscos e não se importa com nada. ",
    [14] = "Dissimulado, malandro e subversivo. ",
    [15] = "Arrogante e convencido. ",
  },
}
