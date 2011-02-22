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
  limit_camera                = utf8 "  LIMITAR CÂMARA  ",
  disable_salary_raise        = utf8 "  DESACTIVAR AUMENTO DOS SALÁRIOS  ",
  make_debug_patient          = "  MAKE DEBUG PATIENT  ",
  spawn_patient               = "  GERAR PACIENTE  ",
  make_adviser_talk           = "  MAKE ADVISER TALK  ",
  show_watch                  = utf8 "  MOSTRAR RELÓGIO  ",
  create_emergency            = utf8 "  CRIAR EMERGÊNCIA  ",
  place_objects               = "  COLOCAR OBJECTOS  ",
  dump_strings                = "  DUMP DAS STRINGS  ",
  map_overlay                 = "  OVERLAY DO MAPA  ",
  sprite_viewer               = "  VISUALIZAR SPRITES  ",
}
menu_debug_overlay = {
  none                        = "  NENHUM  ",
  flags                       = "  FLAGS  ",
  positions                   = utf8 "  POSIÇÕES  ",
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
  options = utf8 "Opções",
  exit = "Sair",
}

tooltip.main_menu = {
  new_game = utf8 "Começar um jogo de raíz",
  custom_level = "Construir o meu hospital",
  load_game = "Carregar um jogo",
  options = utf8 "Ajustar preferências",
  exit = utf8 "Não, por favor, não saias!",
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
    utf8 "Coloca radiadores em quantidade suficiente para que o teu pessoal e pacientes estejam quentinhos... caso contrário irão ficar aborrecidos!",
    utf8 "O nível de perícia de um médico influencia a qualidade e velocidade do seu diagnóstico. Coloca um médico com perícia nas salas de CGs, e não precisarás de tantas salas de diagnóstico.",
    utf8 "Médicos júniores e regulares podem aumentar a sua perícia se aprenderem com um consultante numa Sala de Treino. Se o consultante for especialista (cirurgião, psiquiatra ou investigador), também ensinará a sua especialização aos seus pupilos.s",
    utf8 "Já tentaste escrever o número de emergência (112) no fax? Não te esqueças de ligar as colunas!",
    utf8 "O menu de opções ainda não está implementado, mas podes ajustar algumas preferências tais como resolução e lingua no ficheiro config.txt na pasta do jogo.",
    utf8 "Seleccionaste outra linguagem além do Inglês, mas vês Inglês em todo o lado? Ajuda-nos a traduzir esse texto!",
    utf8 "A equipa do CorsixTH está à procura de reforços! Estás interessado em programar, traduzir ou criar arte gráfica para o CorsixTH? Contacta-nos no fórum, IRC (corsix-th no freenode) ou via Mailing List.",
    "Se encontrares um bug, diz-nos em: th-issues.corsix.org",
  },
  previous = "Dica anterior",
  next = utf8 "Próxima dica",
}

tooltip.totd_window = {
  previous = "Mostrar dica anterior",
  next = utf8 "Mostrar a próxima dica",
}
