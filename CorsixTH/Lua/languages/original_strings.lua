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

-- Note: This is a pseudo language that defines the mapping between new string
-- identifiers and original strings. This language cannot be selected directly.
Language("original_strings")
SetSpeechFile("Sound-".. ... ..".dat")
local S = LoadStrings("Lang-".. ... ..".dat")

-- Fix inconsistency/bug in german lang file.
-- Strings [44][168] (which contains a %s) and [44][169] (contains %d) were
-- replaced with a single string [44][168] with %s and %d in german.
-- Due to this, the remaining strings in section 44 were also off by one.
-- Solve it by splitting the string into two.
local function fixGermanStrings(lang_num)
  if lang_num ~= 2 then
    return
  end
  for str = 218, 169, -1 do
    S[44][str+1] = S[44][str]
  end
  S[44][169] = strsub(S[44][168], 46)
  S[44][168] = strsub(S[44][168], 1, 45)
end

fixGermanStrings(...)

deprecated = S -- For compatibility

staff_class = {
  nurse                 = S[1][1],
  doctor                = S[1][2],
  handyman              = S[1][3],
  receptionist          = S[1][4],
  surgeon               = S[1][5],
  null                  = S[1][6],
}

object = {
  null                  = S[2][ 1],
  desk                  = S[2][ 2],
  cabinet               = S[2][ 3],
  door                  = S[2][ 4],
  bench                 = S[2][ 5],
  table_1               = S[2][ 6],
  chair                 = S[2][ 7],
  drinks_machine        = S[2][ 8],
  bed1                  = S[2][ 9],
  inflator              = S[2][10],
  pool_table            = S[2][11],
  reception_desk        = S[2][12],
  table_2               = S[2][13],
  cardio                = S[2][14],
  scanner               = S[2][15],
  console               = S[2][16],
  screen                = S[2][17],
  litter_bomb           = S[2][18],
  couch                 = S[2][19],
  sofa                  = S[2][20],
  crash_trolley         = S[2][21],
  tv                    = S[2][22],
  ultrascanner          = S[2][23],
  dna_fixer             = S[2][24],
  cast_remover          = S[2][25],
  hair_restorer         = S[2][26],
  slicer                = S[2][27],
  x_ray                 = S[2][28],
  radiation_shield      = S[2][29],
  x_ray_viewer          = S[2][30],
  operating_table       = S[2][31],
  lamp                  = S[2][32],
  sink1                 = S[2][33],
  sink2                 = S[2][34], -- unused (useless?) duplicate
  sink3                 = S[2][35], -- unused (useless?) duplicate
  surgeon_screen        = S[2][36],
  lecture_chair         = S[2][37],
  projector             = S[2][38],
  bed2                  = S[2][39], -- unused (useless?) duplicate
  pharmacy_cabinet      = S[2][40],
  computer              = S[2][41],
  atom_analyser         = S[2][42],
  blood_machine         = S[2][43],
  fire_extinguisher     = S[2][44],
  radiator              = S[2][45],
  plant                 = S[2][46],
  electrolyser          = S[2][47],
  jelly_moulder         = S[2][48],
  gates_of_hell         = S[2][49],
  bed3                  = S[2][50], -- unused (useless?) duplicate
  bin                   = S[2][51],
  toilet                = S[2][52],
  swing_door1           = S[2][53],
  swing_door2           = S[2][54],
  shower                = S[2][55],
  auto_autopsy          = S[2][56],
  bookcase              = S[2][57],
  video_game            = S[2][58],
  entrance_left         = S[2][59],
  entrance_right        = S[2][60],
  skeleton              = S[2][61],
  comfortable_chair     = S[2][62],
}

-- ...

humanoid_name_starts = S[9]
humanoid_name_ends = S[10]

-- ...

-- Menu strings are a little complicated: Different versions of the original
-- game have slightly different menu strings. The strings are also organised
-- by more levels than traditional strings. For the most part, this extra
-- organisation can be use to offset the differences in menu string indicies.
local M = {{}}
do
  local i = 2
  local section = 1
  while true do
    local s = S[23][i]
    if s == "." then
      section = section + 1
      M[section] = {}
    elseif s == ".." then
      break
    else
      M[section][#M[section] + 1] = s
    end
    i = i + 1
  end
end

menu = {
  file                = M[1][1],
  options             = M[1][2],
  display             = M[1][3],
  charts              = M[1][4],
  debug               = M[1][5],
}

menu_file = {
  load                = M[2][1],
  save                = M[2][2],
  restart             = #M[2] == 4 and M[2][3] or "(no string) restart",
  quit                = M[2][#M[2]],
}

menu_file_load = M[7]
menu_file_save = menu_file_load --[[{
  [1]              = S[23][73],
  [2]              = S[23][74],
  [3]              = S[23][75],
  [4]              = S[23][76],
  [5]              = S[23][77],
  [6]              = S[23][78],
  [7]              = S[23][79],
  [8]              = S[23][80],
}]]

menu_options = {
  sound               = M[3][1],
  announcements       = M[3][2],
  music               = M[3][3],
  sound_vol           = M[3][4],
  announcements_vol   = M[3][5],
  music_vol           = M[3][6],
  autosave            = M[3][7],
  game_speed          = M[3][8],
  jukebox             = M[3][9],
}

menu_options_volume = { -- redundant in original strings: M[10] and M[11]
  [100]                = M[9][ 1],
  [ 90]                = M[9][ 2],
  [ 80]                = M[9][ 3],
  [ 70]                = M[9][ 4],
  [ 60]                = M[9][ 5],
  [ 50]                = M[9][ 6],
  [ 40]                = M[9][ 7],
  [ 30]                = M[9][ 8],
  [ 20]                = M[9][ 9],
  [ 10]                = M[9][10],
}

menu_options_game_speed = {
  slowest             = M[12][1],
  slower              = M[12][2],
  normal              = M[12][3],
  max_speed           = M[12][4],
  and_then_some_more  = M[12][5],
}

menu_display = {
  high_res            = M[4][1],
  mcga_lo_res         = M[4][2],
  shadows             = M[4][3],
}

menu_charts = {
  statement           = M[5][1],
  casebook            = M[5][2],
  policy              = M[5][3],
  research            = M[5][4],
  graphs              = M[5][5],
  staff_listing       = M[5][6],
  bank_manager        = M[5][7],
  status              = M[5][8],
  briefing            = M[5][#M[5]],
}

menu_debug = {
  object_cells        = M[6][ 1],
  entry_cells         = M[6][ 2],
  keep_clear_cells    = M[6][ 3],
  nav_bits            = M[6][ 4],
  remove_walls        = M[6][ 5],
  remove_objects      = M[6][ 6],
  display_pager       = M[6][ 7],
  mapwho_checking     = M[6][ 8],
  plant_pagers        = M[6][ 9],
  porter_pagers       = M[6][10],
  pixbuf_cells        = M[6][11],
  enter_nav_debug     = M[6][12],
  show_nav_cells      = M[6][13],
  machine_pagers      = M[6][14],
  display_room_status = M[6][15],
  display_big_cells   = M[6][16],
  show_help_hotspot   = M[6][17],
  win_game_anim       = M[6][18],
  win_level_anim      = M[6][19],
  lose_game_anim = {
    [1]  = M[6][20],
    [2]  = M[6][21],
    [3]  = M[6][22],
    [4]  = M[6][23],
    [5]  = M[6][24],
    [6]  = M[6][25],
    [7]  = M[6][26],
  },
}

-- ...

-- helper function for diseases
local function D(name_str, cause_str)
  local list = {}
  list.name = S[4][name_str]
  if cause_str then
    list.cause    = S[44][cause_str]
    list.symptoms = S[44][cause_str + 1]
    list.cure     = S[44][cause_str + 2]
  end
  return list
end

diseases = {
  -- none                = D( 1), -- not used/needed?
  general_practice       = D( 2),
  bloaty_head            = D( 3,  62),
  hairyitis              = D( 4,  65),
  king_complex           = D( 5,  68),
  invisibility           = D( 6,  71),
  serious_radiation      = D( 7,  74),
  slack_tongue           = D( 8,  77),
  alien_dna              = D( 9,  80),
  fractured_bones        = D(10,  83),
  baldness               = D(11,  86),
  discrete_itching       = D(12,  89),
  jellyitis              = D(13,  92),
  sleeping_illness       = D(14,  95),
  pregnancy              = D(15,  98),   -- unused
  transparency           = D(16, 101),
  uncommon_cold          = D(17, 104),
  broken_wind            = D(18, 107),
  spare_ribs             = D(19, 110),
  kidney_beans           = D(20, 113),
  broken_heart           = D(21, 116),
  ruptured_nodules       = D(22, 119),
  tv_personalities       = D(23, 122),
  infectious_laughter    = D(24, 125),
  corrugated_ankles      = D(25, 128),
  chronic_nosehair       = D(26, 131),
  third_degree_sideburns = D(27, 134),
  fake_blood             = D(28, 137),
  gastric_ejections      = D(29, 140),
  the_squits             = D(30, 143),
  iron_lungs             = D(31, 146),
  sweaty_palms           = D(32, 149),
  heaped_piles           = D(33, 152),
  gut_rot                = D(34, 155),
  golf_stones            = D(35, 158),
  unexpected_swelling    = D(36, 161),
  diag_scanner           = D(37),
  diag_blood_machine     = D(38),
  diag_cardiogram        = D(39),
  diag_x_ray             = D(40),
  diag_ultrascan         = D(41),
  diag_general_diag      = D(42),
  diag_ward              = D(43),
  diag_psych             = D(44),
  autopsy                = D(45),
  -- mixer               = D(46), -- not used/needed?
}

fax = {
  emergency = {
    choices = {
      accept = S[44][15],
      refuse = S[44][16],
    },

    location = S[44][18],
    num_disease = S[44][19],
    cure_possible_drug_name_efficiency = S[44][20],
    cure_possible = S[44][21],
    cure_not_possible_build_and_employ = S[44][22],
    cure_not_possible_build            = S[44][23],
    cure_not_possible_employ           = S[44][24],
    cure_not_possible                  = S[44][25],
    bonus                              = S[44][26],
    
    locations = {
      S[44][27],
      S[44][28],
      S[44][29],
      S[44][30],
      S[44][31],
      S[44][32],
      S[44][33],
      S[44][34],
      S[44][35],
    },
  },

  emergency_result = {
    close_text = S[44][38],

    earned_money = S[44][40],
    saved_people = S[44][41],
  },  
  
  disease_discovered_patient_choice = {
    choices = {
      send_home = S[44][43],
      wait      = S[44][44],
      research  = S[44][45],
    },
    
    need_to_build_and_employ = S[44][47],
    need_to_build            = S[44][48],
    need_to_employ           = S[44][49],
    can_not_cure             = S[44][50],
    
    disease_name             = S[44][51],
    what_to_do_question      = S[44][52],
    guessed_percentage_name  = S[44][53],
  },
  
  disease_discovered = {
    close_text = S[44][55],
    
    can_cure = S[44][57],
    need_to_build_and_employ = S[44][58],
    need_to_build            = S[44][59],
    need_to_employ           = S[44][60],
    
    discovered_name          = S[44][61],
    -- After this come cause, symptoms and cure of disease
  },
  
  epidemic = {
    choices = {
      declare  = S[44][165],
      cover_up = S[44][166],
    },
    
    disease_name             = S[44][168],
    declare_explanation_fine = S[44][169],
    cover_up_explanation_1   = S[44][170],
    cover_up_explanation_2   = S[44][171],
  },
  
  epidemic_result = {
    close_text = S[44][173],
    
    failed = {
      part_1_name = S[44][175],
      part_2      = S[44][176],
    },
    succeeded = {
      part_1_name = S[44][177],
      part_2      = S[44][178],
    },
    
    compensation_amount  = S[44][179],
    fine_amount          = S[44][180],
    rep_loss_fine_amount = S[44][181],
    hospital_evacuated   = S[44][182],
  },
  
  vip_visit_query = {
    choices = {
      invite = S[44][184],
      refuse = S[44][185],
    },
    
    vip_name = S[44][187],
  },
  
  vip_visit_result = {
    close_text = S[44][189],
    
    telegram          = S[44][191],
    vip_remarked_name = S[44][192],
    
    cash_grant = S[44][193],
    rep_boost  = S[44][194],
    rep_loss   = S[44][195],
    
    remarks = {
      super = {
        S[44][196],
        S[44][197],
        S[44][198],
      },
      good = {
        S[44][199],
        S[44][200],
        S[44][201],
      },
      mediocre = {
        S[44][202],
        S[44][203],
        S[44][204],
      },
      bad = {
        S[44][205],
        S[44][206],
        S[44][207],
      },
      very_bad = {
        S[44][208],
        S[44][209],
        S[44][210],
      },
    },
  },
  
  diagnosis_failed = {
    choices = {
      send_home   = S[44][212],
      take_chance = S[44][213],
      wait        = S[44][214],
    },
    
    situation           = S[44][216],
    what_to_do_question = S[44][217],
    partial_diagnosis_percentage_name = S[44][218],
  },
}

-- ...

staff_descriptions.misc = S[46]
staff_descriptions.good = S[47]
staff_descriptions.bad  = S[48]

-- ...
