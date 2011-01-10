--[[ Copyright (c) 2011 Sergei Larionov

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
Language("Русский", "Russian", "ru", "rus")
Inherit("English")
Encoding(utf8)

-- Главное меню
main_menu = {
  new_game = "Новая игра",
  custom_level = "Дополнительные уровни",
  load_game = "Загрузить игру",
  options = "Настройки",
  exit = "Выход",
}
new_game_window = {
  tutorial = "Обучение",
  easy = "Младший сотрудник (Легкий)",
  medium = "Доктор (Средний)",
  hard = "Консультант (Трудный)",
  cancel = "Отмена",
}
custom_game_window = {
  caption = "Дополнительные уровни",
  back = "Назад",
}
load_game_window = {
  caption = "Загрузить игру",
}
save_game_window = {
  caption = "Сохранить игру",
  new_save_game = "Новое сохранение",
}
options_window = {
  fullscreen = "Во весь экран",
  height = "Высота",
  width = "Ширина",
  change_resolution = "Сменить разрешение",
  back = "Назад",
}
tooltip = {
  main_menu = {
    exit = "Стой! Пожалуйста, не уходи!",
    custom_level = "Играть отдельный уровень",
    options = "Изменить всякие параметры",
    new_game = "Начать совершенно новую игру с самого начала",
    load_game = "Загрузить сохраненную ранее игру",
  },
  new_game_window = {
    tutorial = "Поставьте галочку здесь, если хотите узнать, как играть в эту игру",
    easy = "Нажимайте сюда, если вы новичок в подобных играх",
    medium = "Самый обычный средний уровень сложности",
    hard = "Выберите этот вариант, если хотите усложнить себе игру",
    cancel = "Ой, не та кнопка!",
  },
  load_game_window = {
    load_game = "Загрузить игру «%s»",
    load_autosave = "Загрузить автосохранение",
--    load_game_number = "Загрузить игру %d",
  },
  save_game_window = {
    new_save_game = "Введите имя для сохраненной игры",
    save_game = "Перезаписать игру «%s»",
  },
  options_window = {
    fullscreen_button = "Щелкните здесь чтобы переключить оконный режим",
    change_resolution = "Сменить разрешение экрана на указанное слева",
    height = "Введите разрешение экрана по вертикали",
    width = "Введите разрешение экрана по горизонтали",
    language = "Select %s as language",
    back = "Закрыть окно настроек",
  },
}

-- Игровое меню
menu = {
  file =    "  Файл",
--  display = "  Экран",
  options = "  Опции",
  charts =  "  Отчеты",
--  debug =   "  Отладка",
}
menu_file = {
  save =    "  Сохранить",
  load =    "  Загрузить",
  restart = "  Начать заново",
  quit =    "  Выйти в главное меню",
}
menu_options = {
  game_speed =        "    Скорость игры",
  sound_vol =         "    Громкость звука",
  music_vol =         "    Громкость музыки",
  edge_scrolling =    "    Прокрутка мышью",
  announcements =     "    Сообщения",
  lock_windows =      "    Не двигать окна",
  settings =          "    Настройки",
  sound =             "    Звуки",
  announcements_vol = "    Громкость сообщений",
  music =             "    Музыка",
  autosave =          "    Автосохранение",
  jukebox =           "    Музыкальный автомат",
}
menu_options_game_speed = {
  pause =              "    (P) Пауза",
  slowest =            "    (1) Черепашья",
  slower =             "    (2) Медленная",
  normal =             "    (3) Обычная",
  max_speed =          "    (4) Быстрая",
  and_then_some_more = "    (5) Еще быстрее",
}
menu_charts = {
  statement =     "  Баланс банка",
  casebook =      "  Лабораторный журнал",
  policy =        "  Политика",
  research =      "  Исследования",
  graphs =        "  Графики",
  staff_listing = "  Список сотрудников",
  bank_manager =  "  Управлящий банка",
  status =        "  Состояние",
  briefing =      "  Инструктаж",
}



