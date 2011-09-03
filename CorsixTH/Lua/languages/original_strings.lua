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
Encoding(utf8)

-- Fix inconsistencies/bugs in german lang file.
local function fixGermanStrings(lang_num)
  if lang_num ~= 2 then
    return
  end
  
  -- Strings [44][168] (which contains a %s) and [44][169] (contains %d) were
  -- replaced with a single string [44][168] with %s and %d in german full version.
  -- Due to this, the remaining strings in section 44 were also off by one.
  -- Solve it by splitting the string into two.
  -- NB: ONLY in full version, in demo this is NOT broken (thus do length check)
  if #S[44][168] == 108 then
    for str = 218, 169, -1 do
      S[44][str+1] = S[44][str]
    end
    S[44][169] = S[44][168]:sub(46)
    S[44][168] = S[44][168]:sub(1, 45)
  end
  
  -- German spelling reform: eszett changed to double s in a number of words.
  -- Mass-apply this change here, so we don't have to override all those strings.
  local repl = {
    ["daß"] = "dass",
    ["muß"] = "muss", -- includes occurrences of mußte, mußten
    ["läßt"] = "lässt", -- includes occurrences of verläßt
    ["Engpaß"] = "Engpass",
    ["bißchen"] = "bisschen",
    ["Streß"] = "Stress",
    ["Biß"] = "Biss",
    ["Freßpaket"] = "Fresspaket",
    ["Paßt"] = "Passt",
    ["Läßt"] = "Lässt",
    ["verantwortungsbewußt"] = "verantwortungsbewusst",
    ["verläßlich"] = "verlässlich",
    ["Schlußlicht"] = "Schlusslicht",
    ["unerläßlich"] = "unerlässlich",
  }
  
  for c, cat in ipairs(S) do
    for s, str in ipairs(cat) do
      for from, to in pairs(repl) do
        while str:find(from) do
          str = str:gsub(from, to)
        end
      end
      S[c][s] = str
    end
  end
  
  -- good and bad (but not misc) staff description strings are missing space at the end
  for s, _ in ipairs(S[47]) do
    S[47][s] = S[47][s] .. " "
  end
  for s, _ in ipairs(S[48]) do
    S[48][s] = S[48][s] .. " "
  end
end

fixGermanStrings(...)

deprecated = S -- For compatibility

-- each of these corresponds to a sprite
staff_class = {
  nurse                 = S[1][1],
  doctor                = S[1][2],
  handyman              = S[1][3],
  receptionist          = S[1][4],
  surgeon               = S[1][5],
  -- S[1][6] unused
}

-- these are titles used e.g. in the dynamic info bar
staff_title = {
  receptionist          = S[34][1],
  general               = S[34][2], -- unused?
  nurse                 = S[34][3],
  junior                = S[34][4],
  doctor                = S[34][5],
  surgeon               = S[34][6],
  psychiatrist          = S[34][7],
  consultant            = S[34][8],
  researcher            = S[34][9],
}

object = {
  -- S[2][ 1] unused
  desk                  = S[2][ 2],
  cabinet               = S[2][ 3],
  door                  = S[2][ 4],
  bench                 = S[2][ 5],
  table1                = S[2][ 6], -- unused object
  chair                 = S[2][ 7],
  drinks_machine        = S[2][ 8],
  bed                   = S[2][ 9],
  inflator              = S[2][10],
  pool_table            = S[2][11],
  reception_desk        = S[2][12],
  table2                = S[2][13], -- unused object & duplicate
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
  lamp                  = S[2][32], -- unused object
  toilet_sink           = S[2][33],
  op_sink1              = S[2][34],
  op_sink2              = S[2][35],
  surgeon_screen        = S[2][36],
  lecture_chair         = S[2][37],
  projector             = S[2][38],
  bed2                  = S[2][39], -- unused duplicate
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
  bed3                  = S[2][50], -- unused duplicate
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

--  S[3][1]: unused
--  S[3][2]: what's this for? Apparently some command line option of original TH
--           let you start a specific level directly - on difficult and named HORZA.

pay_rise = {
  definite_quit = S[3][3],
  regular = {
    S[3][ 4], -- %d (rise)
    S[3][ 5], -- %d (rise) %d (new total)
    S[3][ 6], -- %d (rise)
    S[3][ 7], -- %d (rise) %d (new total)
    S[3][ 8], -- %d (rise)
    S[3][ 9], -- %d (rise)
  },
  poached = S[3][10], -- %d (new total) %s (competitor)
}

place_objects_window = {
  drag_blueprint                = S[3][11],
  place_door                    = S[3][12],
  place_windows                 = S[3][13],
  place_objects                 = S[3][14],
  confirm_or_buy_objects        = S[3][15],
  pick_up_object                = S[3][16],
  place_objects_in_corridor     = S[3][17],
}

-- Category of strings that fit nowhere else or we are not sure where they belong.
-- If you think a string of these fits somewhere else, please move it there.
-- Don't forget to change all references in the code and other language files.
misc = {
  grade_adverb = {
    mildly     = S[3][18],
    moderately = S[3][19],
    extremely  = S[3][20],
  },
  done  = S[3][21],
  pause = S[3][22],
  
  send_message     = S[3][23], -- %d (player number)
  send_message_all = S[3][24],
  
  save_success = S[3][25],
  save_failed  = S[3][26],
  
  hospital_open = S[3][27],
  out_of_sync   = S[3][28],
  
  load_failed  = S[3][29],
  low_res      = S[3][30],
  balance      = S[3][31],
  
  mouse        = S[11][5],
  force        = S[11][6],
}

-- 4: diseases. This also already handles disease descriptions in 44.
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

competitor_names = {
  S[5][ 1],
  S[5][ 3],
  S[5][ 2],
  S[5][ 4],
  S[5][ 5],
  S[5][ 6],
  S[5][ 7],
  S[5][ 8],
  S[5][17],
  S[5][ 9],
  S[5][15],
  S[5][12],
  "CORSIX", -- Main developers just for fun.
  "ROUJIN",
  "EDVIN",
  S[5][10],
  S[5][11],
  S[5][13],
  S[5][14],
  S[5][16],
  S[5][18],
  S[5][19],
  S[5][20],
  S[5][21],
}

months = {
  S[6][ 1],
  S[6][ 2],
  S[6][ 3],
  S[6][ 4],
  S[6][ 5],
  S[6][ 6],
  S[6][ 7],
  S[6][ 8],
  S[6][ 9],
  S[6][10],
  S[6][11],
  S[6][12],
}

-- S[7][ 1], -- not needed?
-- S[7][ 2], -- unused(?)
-- S[7][ 3], -- unused(?)

graphs = {
  money_in   = S[7][ 4],
  money_out  = S[7][ 5],
  wages      = S[7][ 6],
  balance    = S[7][ 7],
  visitors   = S[7][ 8],
  cures      = S[7][ 9],
  deaths     = S[7][10],
  reputation = S[7][11],
  
  time_spans = {
    S[7][12],
    S[7][13],
    S[7][14],
  }
}

transactions = {
  --null               = S[8][ 1], -- not needed
  wages                = S[8][ 2],
  hire_staff           = S[8][ 3],
  buy_object           = S[8][ 4],
  build_room           = S[8][ 5],
  cure                 = S[8][ 6],
  buy_land             = S[8][ 7],
  treat_colon          = S[8][ 8],
  final_treat_colon    = S[8][ 9],
  cure_colon           = S[8][10],
  deposit              = S[8][11],
  advance_colon        = S[8][12],
  research             = S[8][13],
  drinks               = S[8][14],
  jukebox              = S[8][15], -- unused
  cheat                = S[8][16],
  heating              = S[8][17],
  insurance_colon      = S[8][18],
  bank_loan            = S[8][19],
  loan_repayment       = S[8][20],
  loan_interest        = S[8][21],
  research_bonus       = S[8][22],
  drug_cost            = S[8][23],
  overdraft            = S[8][24],
  severance            = S[8][25],
  general_bonus        = S[8][26],
  sell_object          = S[8][27],
  personal_bonus       = S[8][28],
  emergency_bonus      = S[8][29],
  vaccination          = S[8][30],
  epidemy_coverup_fine = S[8][31],
  compensation         = S[8][32],
  vip_award            = S[8][33],
  epidemy_fine         = S[8][34],
  eoy_bonus_penalty    = S[8][35],
  eoy_trophy_bonus     = S[8][36],
  machine_replacement  = S[8][37],
}

humanoid_name_starts = S[9] -- 33 entries
humanoid_name_ends = S[10]  -- 26 entries

adviser = {
  tutorial = {
    -- 1) build reception
    build_reception               = S[11][30], -- start of the tutorial
    order_one_reception           = S[11][41],
    accept_purchase               = S[11][43],
    rotate_and_place_reception    = S[11][42],
    reception_invalid_position    = S[11][47],
    
    -- 2) hire receptionist
    hire_receptionist             = S[11][31],
    select_receptionists          = S[11][34],
    next_receptionist             = S[11][38],
    prev_receptionist             = S[11][39],
    choose_receptionist           = S[11][35],
    place_receptionist            = S[11][37],
    receptionist_invalid_position = S[11][61],
    
    -- 3) build GP's office
    -- 3.1) room window
    build_gps_office              = S[11][33],
    select_diagnosis_rooms        = S[11][44],
    click_gps_office              = S[11][45],
    
    -- 3.2) blueprint
    -- [11][58] was maybe planned to be used in this place, but is not needed.
    click_and_drag_to_build       = S[11][48],
    room_in_invalid_position      = S[11][52],
    room_too_small                = S[11][53],
    room_too_small_and_invalid    = S[11][62],
    room_big_enough               = S[11][57],
    
    -- 3.3) door and windows
    place_door                    = S[11][49],
    door_in_invalid_position      = S[11][54],
    place_windows                 = S[11][50],
    window_in_invalid_position    = S[11][55],
    
    -- 3.4) objects
    place_objects                 = S[11][51],
    object_in_invalid_position    = S[11][56],
    confirm_room                  = S[11][59],
    information_window            = S[11][64],
    
    -- 4) hire doctor
    hire_doctor                   = S[11][32],
    select_doctors                = S[11][36],
    choose_doctor                 = S[11][46],
    place_doctor                  = S[11][40],
    doctor_in_invalid_position    = S[11][60],
    
    -- (currently) unused
    start_tutorial                = S[11][63],
    build_pharmacy                = S[11][65],
  },
  
  staff_advice = {
    need_doctors                  = S[11][  8],
    too_many_doctors              = S[11][  9],
    -- too_many_doctors_2            = S[21][  4] -- duplicate
    need_handyman_litter          = S[11][ 70],
    need_handyman_plants          = S[11][ 93],
    need_handyman_machines        = S[11][ 94],
    need_nurses                   = S[11][101],
    too_many_nurses               = S[11][102],
  },
  
  -- used when you place staff in a wrong place
  staff_place_advice = {
    only_researchers              = S[11][124], -- in research center
    only_surgeons                 = S[11][125], -- in operating theatre
    only_psychiatrists            = S[11][126], -- in psychiatry
    only_nurses_in_room           = S[11][127], -- %s (room name)
    doctors_cannot_work_in_room   = S[11][128], -- %s (room name)
    nurses_cannot_work_in_room    = S[11][129], -- %s (room name)
    only_doctors_in_room          = S[11][130], -- %s (room name)
    receptionists_only_at_desk    = S[11][131],
  },
  
  build_advice = {
    blueprint_invalid             = S[21][5],
    blueprint_would_block         = S[21][6],
    door_not_reachable            = S[21][7],
    placing_object_blocks_door    = S[21][8],
  },
  
  -- these are used when completing a room with certain requirements (if they are not met yet)
  room_requirements = {
    psychiatry_need_psychiatrist  = S[11][ 79],
    pharmacy_need_nurse           = S[11][ 80],
    training_room_need_consultant = S[11][ 81],
    research_room_need_researcher = S[11][ 84],
    op_need_two_surgeons          = S[11][ 85],
    op_need_another_surgeon       = S[11][ 86],
    op_need_ward                  = S[11][ 87],
    ward_need_nurse               = S[11][ 88],
    gps_office_need_doctor        = S[11][105],
    reception_need_receptionist   = S[11][106],
  },
  
  surgery_requirements = {
    need_surgeons_ward_op         = S[11][103],
    need_surgeon_ward             = S[11][104],
  },
  
  warnings = {
    money_low                     = S[11][  2],
    money_very_low_take_loan      = S[11][ 73],
    cash_low_consider_loan        = S[28][ 16],
    bankruptcy_imminent           = S[11][  3],
    financial_trouble             = S[28][ 29], -- %d amount left before level is lost
    finanical_trouble2            = S[28][ 30], -- %d same as above
    financial_trouble3            = S[28][ 31], -- %d same again
    
    pay_back_loan                 = S[28][ 57],
    
    machines_falling_apart        = S[11][  4],
    no_patients_last_month        = S[11][ 10],
    nobody_cured_last_month       = S[11][ 11],
    queues_too_long               = S[11][ 12],
    patient_stuck                 = S[11][ 13],
    
    patients_unhappy              = S[11][ 15],
    patient_leaving               = S[28][ 50],
    patients_leaving              = S[28][ 51],
    patients_really_thirsty       = S[28][ 52],
    patients_annoyed              = S[28][  8],
    
    patients_thirsty              = S[11][ 16],
    patients_thirsty2             = S[28][  5],
    patients_very_thirsty         = S[28][  6],
    
    patients_too_hot              = S[11][ 18],
    patients_getting_hot          = S[28][ 53],
    patients_very_cold            = S[28][ 54],
    people_freezing               = S[28][ 14],

    staff_overworked              = S[11][ 17],
    staff_tired                   = S[28][  9],
    
    staff_too_hot                 = S[11][ 19],
    staff_very_cold               = S[28][ 55],
    staff_unhappy                 = S[11][ 89],
    staff_unhappy2                = S[28][ 15],
    doctor_crazy_overwork         = S[11][ 95],
    
    reduce_staff_rest_threshold   = S[28][ 45],
    nurses_tired                  = S[11][ 96],
    doctors_tired                 = S[11][ 97],
    handymen_tired                = S[11][ 98],
    receptionists_tired           = S[11][ 99],
    
    nurses_tired2                 = S[28][ 46],
    doctors_tired2                = S[28][ 47],
    handymen_tired2               = S[28][ 48],
    receptionists_tired2          = S[28][ 49], -- What?
    
    need_toilets                  = S[11][ 20],
    build_toilets                 = S[28][ 11],
    build_toilet_now              = S[28][ 39],
    more_toilets                  = S[28][ 12],
    people_did_it_on_the_floor    = S[28][ 13],
    
    need_staffroom                = S[11][ 74],
    build_staffroom               = S[28][ 10],
    
    many_killed                   = S[11][ 77], -- %d (number of killed patients)
    
    plants_thirsty                = S[11][ 91],
    too_many_plants               = S[11][ 92],
    
    charges_too_high              = S[11][119],
    charges_too_low               = S[11][120],
    
    machine_severely_damaged      = S[11][121], -- %s (name of machine)
    machinery_slightly_damaged    = S[28][ 32],
    machinery_damaged             = S[28][ 33],
    machinery_damaged2            = S[28][ 34],
    machinery_very_damaged        = S[28][ 35],
    machinery_deteriorating       = S[28][ 36],
    
    queue_too_long_send_doctor    = S[11][132], -- %s (name of room)
    queue_too_long_at_reception   = S[11][133],
    reception_bottleneck          = S[11][134], -- TODO find out why there's 133 and 134.
    
    epidemic_getting_serious      = S[28][  2],
    deal_with_epidemic_now        = S[28][  3],
    many_epidemics                = S[28][  4],

    hospital_is_rubbish           = S[28][  7],
    
    more_benches                  = S[28][ 25],
    people_have_to_stand          = S[28][ 28],
    
    too_much_litter               = S[28][ 17],
    litter_everywhere             = S[28][ 18],
    litter_catastrophy            = S[28][ 19],
    some_litter                   = S[28][ 20],
    
    place_plants_to_keep_people   = S[28][ 21],
    place_plants2                 = S[28][ 22],
    place_plants3                 = S[28][ 23],
    place_plants4                 = S[28][ 24],
    
    desperate_need_for_watering   = S[28][ 40],
    change_priorities_to_plants   = S[28][ 41],
    plants_dying                  = S[28][ 42],

  },
  
  praise = {
    many_plants                   = S[11][75],
    plants_are_well               = S[28][43],
    plants_thriving               = S[28][44],
    
    many_benches                  = S[11][76],
    plenty_of_benches             = S[28][26],
    few_have_to_stand             = S[28][27],
    
    patients_cured                = S[11][82], -- %d (number of cured patients)
  },
  
  information = {
    epidemic                      = S[11][ 14],
    emergency                     = S[11][ 22],
    promotion_to_doctor           = S[11][ 23],
    promotion_to_specialist       = S[11][ 69], -- %s (type: psychiatrist, scientist, surgeon)
    promotion_to_consultant       = S[11][138],
    
    first_death                   = S[11][ 72],
    first_cure                    = S[11][ 83],
    
    place_windows                 = S[11][108],
    larger_rooms                  = S[11][109],
    extra_items                   = S[11][110],
    
    patient_abducted              = S[11][111], -- what the heck is this? I never got that far in the original...
    patient_leaving_too_expensive = S[11][118],
    
    pay_rise                      = S[11][ 29], -- TODO only in tutorial / first time?
    handyman_adjust               = S[11][ 71], -- TODO only in tutorial / first time?
    fax_received                  = S[11][136], -- Once only
    
    vip_arrived                   = S[21][  9], -- %s (name of VIP)
    epidemic_health_inspector     = S[21][ 10],
    
    initial_general_advice = {
      research_now_available      = S[62][02],
      research_symbol             = S[62][03],
      surgeon_symbol              = S[62][04],
      psychiatric_symbol          = S[62][05],
      rats_have_arrived           = S[62][06],
      autopsy_available           = S[62][07],
      first_epidemic              = S[62][08],
      first_VIP                   = S[62][09],
      taking_your_staff           = S[62][10],
      machine_needs_repair        = S[62][11],
      epidemic_spreading          = S[62][12],
      increase_heating            = S[62][13],
      place_radiators             = S[62][14],
      decrease_heating            = S[62][15],
      first_patients_thirsty      = S[62][16],
      first_emergency             = S[62][17],
    },
  },
  
  earthquake = {
    alert                         = S[11][107],
    damage                        = S[11][100], -- %d (damaged machines) %d (injured people)
    ended                         = S[11][ 78], -- %d (severance of earthquake)
  },
  
  boiler_issue = {
    maximum_heat                  = S[21][ 11],
    minimum_heat                  = S[21][ 12],
    resolved                      = S[21][ 13],
  },
  
  vomit_wave = {
    started                       = S[21][ 14],
    ended                         = S[21][ 15],
  },
  
  goals = {
    win = {
      money                       = S[11][ 21], -- %d (remaining amount)
      reputation                  = S[11][ 67], -- %d (required amount)
      value                       = S[11][ 68], -- %d (required amount)
      cure                        = S[11][137], -- %d (remaining amount)
    },
    lose = {
      kill                        = S[11][ 66], -- %d (remaining amount)
    },
  },
  
  level_progress = {
    nearly_won                    = S[11][112],
    three_quarters_won            = S[11][113],
    halfway_won                   = S[11][114],
    nearly_lost                   = S[11][115],
    three_quarters_lost           = S[11][116],
    halfway_lost                  = S[11][117],
    
    another_patient_cured         = S[28][37],
    another_patient_killed        = S[28][38],
    
    financial_criteria_met        = S[28][56], -- %d money threshold for the level
    cured_enough_patients         = S[28][58],
    dont_kill_more_patients       = S[28][59],
    reputation_good_enough        = S[28][60], -- %d rep threshold for the level
    improve_reputation            = S[28][61], -- %d amount to improve by
    hospital_value_enough         = S[28][62], -- %d keep it above this value
    close_to_win_increase_value   = S[28][63],
    
  },
  
  research = {
    new_machine_researched        = S[11][ 24], -- %s (machine(?) name)
    new_drug_researched           = S[11][ 25], -- %s (disease name)
    drug_improved                 = S[11][ 26], -- %s (disease name)
    machine_improved              = S[11][ 27], -- %s (machine name)
    new_available                 = S[11][ 28], -- %s TODO What is this? Where to use this and where [11][24]?
    -- ANSWER: It is used if research is not conducted in an area for very long. Some diagnosis equipment
    -- becomes available anyway after some years. Then this message is displayed instead of [11][24]
    drug_fully_researched         = S[11][122], -- %s (drug(?) name)
    autopsy_discovered_rep_loss   = S[11][123],
  },
  
  competitors = {
    hospital_opened               = S[11][135], -- %s (competitor name)
    land_purchased                = S[11][  7], -- %s (competitor name)
    staff_poached                 = S[11][ 90],
  },
  
  multiplayer = {
    -- S[21][1] unused
    everyone_failed               = S[21][ 2],
    players_failed                = S[21][ 3],
    
    poaching = {
      already_poached_by_someone  = S[21][16],
      not_interested              = S[21][17],
      in_progress                 = S[21][18],
    },
    
    objective_completed           = S[21][19], -- missing in some TH versions
    objective_failed              = S[21][20], -- missing in some TH versions
  },
  
  placement_info = {
    -- S[22][1] unused
    room_cannot_place             = S[22][ 2],
    room_cannot_place_2           = S[22][ 3], -- hmm. why? maybe the previous one should've been "can"
    reception_can_place           = S[22][ 4],
    reception_cannot_place        = S[22][ 5],
    door_can_place                = S[22][ 6],
    door_cannot_place             = S[22][ 7],
    window_can_place              = S[22][ 8],
    window_cannot_place           = S[22][ 9],
    staff_can_place               = S[22][10],
    staff_cannot_place            = S[22][11],
    object_can_place              = S[22][12],
    object_cannot_place           = S[22][13],
  },

  epidemic = {
    -- S[28][1] unused
    serious_warning               = S[28][ 2],
    hurry_up                      = S[28][ 3],
    multiple_epidemies            = S[28][ 4],
  },
}

level_names = {
  -- S[12][ 1] -- unused
  S[12][ 2],
  S[12][ 3],
  S[12][ 4],
  S[12][ 5],
  S[12][ 6],
  S[12][ 7],
  S[12][ 8],
  S[12][ 9],
  S[12][10],
  S[12][11],
  S[12][12],
  S[12][13],
  S[12][14],
  S[12][15],
  S[12][16],
}

town_map = {
  -- S[13][ 1] -- unused
  chat         = S[13][ 2],
  for_sale     = S[13][ 3],
  not_for_sale = S[13][ 4],
  number       = S[13][ 5], 
  owner        = S[13][ 6],
  area         = S[13][ 7],
  price        = S[13][ 8],
}

-- NB: includes some special "rooms"
-- reception, destroyed room and "corridor objects"
rooms_short = {
  -- S[14][1] -- unused
  -- S[14][3] -- unused
  reception         = S[14][ 2],
  destroyed         = S[14][ 4],
  corridor_objects  = S[14][29],
  
  gps_office        = S[14][ 5],
  psychiatric       = S[14][ 6],
  ward              = S[14][ 7],
  operating_theatre = S[14][ 8],
  pharmacy          = S[14][ 9],
  cardiogram        = S[14][10],
  scanner           = S[14][11],
  ultrascan         = S[14][12],
  blood_machine     = S[14][13],
  x_ray             = S[14][14],
  inflation         = S[14][15],
  dna_fixer         = S[14][16],
  hair_restoration  = S[14][17],
  tongue_clinic     = S[14][18],
  fracture_clinic   = S[14][19],
  training_room     = S[14][20],
  electrolysis      = S[14][21],
  jelly_vat         = S[14][22],
  staffroom         = S[14][23],
  -- rehabilitation = S[14][24], -- unused
  general_diag      = S[14][25],
  research_room     = S[14][26],
  toilets           = S[14][27],
  decontamination   = S[14][28],
}

rooms_long = {
  -- S[53][1] -- unused
  general           = S[53][2], -- unused?
  emergency         = S[53][3],
  corridors         = S[53][29],
  
  gps_office        = S[53][ 5],
  psychiatric       = S[53][ 6],
  ward              = S[53][ 7],
  operating_theatre = S[53][ 8],
  pharmacy          = S[53][ 9],
  cardiogram        = S[53][10],
  scanner           = S[53][11],
  ultrascan         = S[53][12],
  blood_machine     = S[53][13],
  x_ray             = S[53][14],
  inflation         = S[53][15],
  dna_fixer         = S[53][16],
  hair_restoration  = S[53][17],
  tongue_clinic     = S[53][18],
  fracture_clinic   = S[53][19],
  training_room     = S[53][20],
  electrolysis      = S[53][21],
  jelly_vat         = S[53][22],
  staffroom         = S[53][23],
  -- rehabilitation = S[53][24], -- unused
  general_diag      = S[53][25],
  research_room     = S[53][26],
  toilets           = S[53][27],
  decontamination   = S[53][28],
}

-- TODO where is this used?
drug_companies = {
  -- S[15][1], -- unused
  S[15][2],
  S[15][3],
  S[15][4],
  S[15][5],
  S[15][6],
}

build_room_window = {
  -- S[16][1], -- unused
  pick_department   = S[16][2],
  pick_room_type    = S[16][3],
  cost              = S[16][5],
}

buy_objects_window = {
  choose_items      = S[16][4],
  price             = S[16][6],
  total             = S[16][7],
}

research = {
  categories = {
    cure            = S[17][1],
    diagnosis       = S[17][2],
    drugs           = S[17][3],
    improvements    = S[17][4],
    specialisation  = S[17][5],
  },
  
  funds_allocation  = S[17][6],
  allocated_amount  = S[17][7],
}

policy = {
  header            = S[18][1],
  diag_procedure    = S[18][2],
  diag_termination  = S[18][3],
  staff_rest        = S[18][4],
  staff_leave_rooms = S[18][5],
  
  sliders = {
    guess           = S[18][6], -- belongs to diag_procedure
    send_home       = S[18][7], -- also belongs to diag_procedure
    stop            = S[18][8], -- belongs to diag_termination
    staff_room      = S[18][9], -- belongs to staff_rest
  }
}

room_classes = {
  -- S[19][1] -- unused
  -- S[19][2] -- "corridors" - unused for now
  -- S[19][3] -- unused
  diagnosis  = S[19][4],
  treatment  = S[19][5],
  clinics    = S[19][6],
  facilities = S[19][7],
}

-- These are better of in a list with numbers
insurance_companies = {
  out_of_business   = S[20][ 1],
  S[20][ 2],
  S[20][ 3],
  S[20][ 4],
  S[20][ 5],
  S[20][ 6],
  S[20][ 7],
  S[20][ 8],
  S[20][ 9],
  S[20][10],
  S[20][11],
  S[20][12],
}

-- 21 and 22: some more adviser strings, see above.

-- 23: menu strings
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
    M[6][20],
    M[6][21],
    M[6][22],
    M[6][23],
    M[6][24],
    M[6][25],
    M[6][26],
  },
}

staff_list = {
  -- S[24][1] unused
  -- S[24][2] -- I have no idea what this is.
  morale       = S[24][3],
  tiredness    = S[24][4],
  skill        = S[24][5],
  total_wages  = S[24][6],
}

high_score = {
  -- S[25][1] unused
  pos          = S[25][2],
  player       = S[25][3],
  score        = S[25][4],
  best_scores  = S[25][5],
  worst_scores = S[25][6],
  killed       = S[25][7], -- is this used?
  
  categories = {
    money             = S[26][ 1],
    salary            = S[26][ 2],
    clean             = S[26][ 3],
    cures             = S[26][ 4],
    deaths            = S[26][ 5],
    cure_death_ratio  = S[26][ 6],
    patient_happiness = S[26][ 7],
    staff_happiness   = S[26][ 8],
    staff_number      = S[26][ 9],
    visitors          = S[26][10],
    total_value       = S[26][11],
  },
}

trophy_room = {
  -- S[27][1] unused
  many_cured = {
    awards = {
      S[27][ 2],
      S[55][ 5],
      S[55][ 6],
      S[55][ 7],
    },
    trophies = {
      S[27][ 3],
      S[27][ 4],
    },
  },
  all_cured = {
    awards = {
      S[27][29],
    },
    trophies = {
      S[27][30],
      S[27][31],
    },
  },
  high_rep = {
    awards = {
      S[27][ 5],
      S[27][ 7],
      S[55][ 2],
      S[55][ 3],
      S[55][ 4],
    },
    trophies = {
      S[27][ 6],
    },
  },
  happy_staff = {
    awards = {
    },
    trophies = {
      S[27][ 8],
      S[27][ 9],
      S[27][10],
    },
  },
  happy_vips = {
    awards = {
      S[27][11],
      S[27][13],
    },
    trophies = {
      S[27][12],
    },
  },
  no_deaths = {
    awards = {
      S[27][14],
      S[55][ 8],
      S[55][ 9],
      S[55][10],
    },
    trophies = {
      S[27][15],
      S[27][16],
    },
  },
  rats_killed = {
    awards = {
    },
    trophies = {
      S[27][17], -- %d (number of rats)
      S[27][18], -- %d (number of rats)
      S[27][19], -- %d (number of rats)
    },
  },
  rats_accuracy = {
    awards = {
    },
    trophies = {
      S[27][20], -- %d (accuracy percentage)
      S[27][21], -- %d (accuracy percentage)
      S[27][22], -- %d (accuracy percentage)
    },
  },
  healthy_plants = {
    awards = {
      S[27][23],
    },
    trophies = {
      S[27][24],
      S[27][25],
    },
  },
  sold_drinks = {
    awards = {
    },
    trophies = {
      S[27][26],
      S[27][27],
      S[27][28],
    },
  },
  pop_percentage = {
    awards = {
      S[55][11],
      S[55][12],
      S[55][13],
    },
  },
  -- Strings used in the plaques to show what has been won
  reputation = S[63][1],
  cash       = S[63][2],
}

-- Section 28: more adviser strings (see above)

casebook = {
  reputation           = S[29][ 1],
  treatment_charge     = S[29][ 2],
  earned_money         = S[29][ 3],
  cured                = S[29][ 4],
  deaths               = S[29][ 5],
  sent_home            = S[29][ 6],
  research             = S[29][ 7],
  cure                 = S[29][ 8],
  cure_desc = {
    build_room         = S[29][ 9], -- %s (room name)
    build_ward         = S[29][10],
    hire_doctors       = S[29][11],
    hire_surgeons      = S[29][12],
    hire_psychiatrists = S[29][13],
    hire_nurses        = S[29][14],
    no_cure_known      = S[29][15],
    cure_known         = S[29][16],
    improve_cure       = S[29][17],
  },
}

-- 30, 31: multiplayer. not needed for now.

tooltip = {
  -- S[32][1] unused
  build_room_window = {
    room_classes = {
      diagnosis        = S[32][  2],
      treatment        = S[32][  3],
      clinic           = S[32][  4],
      facilities       = S[32][  5],
    },
    cost               = S[32][  6],
    close              = S[32][  7],
  },
  
  toolbar = {
    bank_button        = S[32][  8],
    balance            = S[32][  9],
    reputation         = S[32][ 10], -- NB: no %d! Append " ([reputation])".
    date               = S[32][ 11],
    rooms              = S[32][ 12],
    objects            = S[32][ 13],
    edit               = S[32][ 14],
    hire               = S[32][ 15],
    staff_list         = S[32][ 16],
    town_map           = S[32][ 17],
    casebook           = S[32][ 18],
    research           = S[32][ 19],
    status             = S[32][ 20],
    charts             = S[32][ 21],
    policy             = S[32][ 22],
  },
  
  hire_staff_window = {
    doctors            = S[32][ 23],
    nurses             = S[32][ 24],
    handymen           = S[32][ 25],
    receptionists      = S[32][ 26],
    prev_person        = S[32][ 27],
    next_person        = S[32][ 28],
    hire               = S[32][ 29],
    cancel             = S[32][ 30],
    doctor_seniority   = S[32][ 31],
    staff_ability      = S[32][ 32],
    salary             = S[32][ 33],
    qualifications     = S[32][ 34],
    surgeon            = S[32][ 35],
    psychiatrist       = S[32][ 36],
    researcher         = S[32][ 37],
  },
  
  buy_objects_window = {
    price              = S[32][ 38],
    total_value        = S[32][ 39],
    confirm            = S[32][ 40],
    cancel             = S[32][ 41],
    decrease           = S[32][ 42],
    increase           = S[32][ 43],
  },
  
  staff_list = {
    doctors            = S[32][ 44],
    nurses             = S[32][ 45],
    handymen           = S[32][ 46],
    receptionists      = S[32][ 47],
    
    happiness          = S[32][ 48],
    tiredness          = S[32][ 49],
    ability            = S[32][ 50],
    salary             = S[32][ 51],
    
    happiness_2        = S[32][ 52],
    tiredness_2        = S[32][ 53],
    ability_2          = S[32][ 54],
    
    prev_person        = S[32][ 55],
    next_person        = S[32][ 56],
    
    bonus              = S[32][ 57],
    sack               = S[32][ 58],
    pay_rise           = S[32][ 59],
    
    close              = S[32][ 60],
    
    doctor_seniority   = S[32][ 61],
    detail             = S[32][ 62],
    
    view_staff         = S[32][ 63],
    
    surgeon            = S[32][ 64],
    psychiatrist       = S[32][ 65],
    researcher         = S[32][ 66],
    surgeon_train      = S[32][ 67], -- %d (percentage trained)
    psychiatrist_train = S[32][ 68], -- %d (percentage trained)
    researcher_train   = S[32][ 69], -- %d (percentage trained)
    
    skills             = S[32][ 70],
  },
  
  queue_window = {
    num_in_queue       = S[32][ 71],
    num_expected       = S[32][ 72],
    num_entered        = S[32][ 73],
    max_queue_size     = S[32][ 74],
    dec_queue_size     = S[32][ 75],
    inc_queue_size     = S[32][ 76],
    front_of_queue     = S[32][ 77],
    end_of_queue       = S[32][ 78],
    close              = S[32][ 79],
    patient            = S[32][ 80],
    patient_dropdown = {
      reception        = S[32][186],
      send_home        = S[32][187],
      hospital_1       = S[32][188],
      hospital_2       = S[32][189],
      hospital_3       = S[32][190],
    },
  },
  
  main_menu = {
    new_game           = S[32][ 81],
    load_game          = S[32][ 82],
    continue           = S[32][ 83],
    network            = S[32][ 84],
    quit               = S[32][ 85],
    load_menu = {
      load_slot        = S[41][  1], -- NB: no %d! Append " [slotnumber]".
      empty_slot       = S[41][  2],
    },
  },
  
  window_general = {
    cancel             = S[32][ 86],
    confirm            = S[32][ 87],
  },
  
  patient_window = {
    close              = S[32][ 88],
    graph              = S[32][ 89],
    happiness          = S[32][ 90],
    thirst             = S[32][ 91],
    warmth             = S[32][ 92],
    casebook           = S[32][ 93],
    send_home          = S[32][ 94],
    center_view        = S[32][ 95],
    abort_diagnosis    = S[32][ 96],
    queue              = S[32][ 97],
  },
  
  staff_window = {
    name               = S[32][ 98],
    close              = S[32][ 99],
    face               = S[32][100],
    happiness          = S[32][101],
    tiredness          = S[32][102],
    ability            = S[32][103],
    doctor_seniority   = S[32][104],
    skills             = S[32][105],
    surgeon            = S[32][106],
    psychiatrist       = S[32][107],
    researcher         = S[32][108],
    salary             = S[32][109],
    center_view        = S[32][110],
    sack               = S[32][111],
    pick_up            = S[32][112],
  },
  
  machine_window = {
    name               = S[32][113],
    close              = S[32][114],
    times_used         = S[32][115],
    status             = S[32][116],
    repair             = S[32][117],
    replace            = S[32][118],
  },
  
  -- Apparently handymen have their own set of strings (partly) containing "handyman".
  -- We could just get rid of this category and include the three prios into staff_window.
  handyman_window = {
    name               = S[32][119], -- contains "handyman"
    close              = S[32][120],
    face               = S[32][121], -- contains "handyman"
    happiness          = S[32][122],
    tiredness          = S[32][123],
    ability            = S[32][124],
    prio_litter        = S[32][125], -- contains "handyman"
    prio_plants        = S[32][126], -- contains "handyman"
    prio_machines      = S[32][127], -- contains "handyman"
    salary             = S[32][128],
    center_view        = S[32][129], -- contains "handyman"
    sack               = S[32][130],
    pick_up            = S[32][131],
  },
  
  place_objects_window = {
    cancel             = S[32][132],
    buy_sell           = S[32][133],
    pick_up            = S[32][134],
    confirm            = S[32][135],
  },
  
  casebook = {
    up                 = S[32][136],
    down               = S[32][137],
    close              = S[32][138],
    reputation         = S[32][139],
    treatment_charge   = S[32][140],
    earned_money       = S[32][141],
    cured              = S[32][142],
    deaths             = S[32][143],
    sent_home          = S[32][144],
    decrease           = S[32][145],
    increase           = S[32][146],
    research           = S[32][147],
    cure_type = {
      drug             = S[32][148],
      drug_percentage  = S[32][149], -- %d (effectiveness percentage)
      psychiatrist     = S[32][150],
      surgery          = S[32][151],
      machine          = S[32][152],
    },
    cure_requirement = {
      possible         = S[32][153],
      research_machine = S[32][154],
      build_room       = S[32][155],
      hire_surgeons    = S[32][156], -- unused
      hire_surgeon     = S[32][157], -- unused
      hire_staff_old   = S[32][158], -- %s (staff type), unused. Use hire_staff instead.
      build_ward       = S[32][159], -- unused
      ward_hire_nurse  = S[32][160], -- unused
      not_possible     = S[32][161], -- unused
    },
  },
  
  statement = {
    close              = S[32][162],
  },
  
  research = {
    close              = S[32][163],
    cure_dec           = S[32][164],
    diagnosis_dec      = S[32][165],
    drugs_dec          = S[32][166],
    improvements_dec   = S[32][167],
    specialisation_dec = S[32][168],
    cure_inc           = S[32][169],
    diagnosis_inc      = S[32][170],
    drugs_inc          = S[32][171],
    improvements_inc   = S[32][172],
    specialisation_inc = S[32][173],

    -- S[32][174] unused
    allocated_amount   = S[32][175],
  },
  
  graphs = {
    close              = S[32][176],
    scale              = S[32][177],
    money_in           = S[32][178],
    money_out          = S[32][179],
    wages              = S[32][180],
    balance            = S[32][181],
    visitors           = S[32][182],
    cures              = S[32][183],
    deaths             = S[32][184],
    reputation         = S[32][185],
  },
  
  -- S[32][186] through S[32][190] inserted further above
  
  town_map = {
    people             = S[32][191],
    plants             = S[32][192],
    fire_extinguishers = S[32][193],
    objects            = S[32][194],
    radiators          = S[32][195],
    heat_level         = S[32][196],
    heat_inc           = S[32][197],
    heat_dec           = S[32][198],
    heating_bill       = S[32][199],
    balance            = S[32][200],
    close              = S[32][201],
  },
  
  -- S[32][202] unused.
  jukebox = {
    current_title      = S[32][203],
    close              = S[32][204],
    play               = S[32][205],
    rewind             = S[32][206],
    fast_forward       = S[32][207],
    stop               = S[32][208],
    loop               = S[32][209],
  },
  
  bank_manager = {
    hospital_value     = S[32][210],
    balance            = S[32][211],
    current_loan       = S[32][212],
    repay_5000         = S[32][213],
    borrow_5000        = S[32][214],
    interest_payment   = S[32][215],
    inflation_rate     = S[32][216],
    interest_rate      = S[32][217],
    close              = S[32][218],
    insurance_owed     = S[32][219], -- %s (name of debitor)
    show_graph         = S[32][220], -- %s (name of debitor)
    graph              = S[32][221], -- %s (name of debitor)
    graph_return       = S[32][222],
  },
  
  status = {
    win_progress_own   = S[32][223],
    win_progress_other = S[32][224], -- %s (name of competitor)
    population_chart   = S[32][225],
    happiness          = S[32][226],
    thirst             = S[32][227],
    warmth             = S[32][228],
    close              = S[32][229],
    
    -- Criteria to win
    reputation         = S[64][  1],
    balance            = S[64][  2],
    population         = S[64][  3],
    num_cured          = S[64][  4],
    percentage_killed  = S[64][  5],
    value              = S[64][  6],
    percentage_cured   = S[64][  7],
  },
  
  policy = {
    close              = S[32][230],
    staff_leave        = S[32][231],
    staff_stay         = S[32][232],
    diag_procedure     = S[32][233],
    diag_termination   = S[32][234],
    staff_rest         = S[32][235],
  },
  
  pay_rise_window = {
    accept             = S[32][236],
    decline            = S[32][237],
  },
  
  watch = {
    hospital_opening   = S[32][238],
    emergency          = S[32][239],
    epidemic           = S[32][240],
  },
  
  rooms = {
    -- S[33][1] through S[33][7] unused.
    gps_office         = S[33][ 8],
    psychiatry         = S[33][ 9],
    ward               = S[33][10],
    operating_theatre  = S[33][11],
    pharmacy           = S[33][12],
    cardiogram         = S[33][13],
    scanner            = S[33][14],
    ultrascan          = S[33][15],
    blood_machine      = S[33][16],
    x_ray              = S[33][17],
    inflation          = S[33][18],
    dna_fixer          = S[33][19],
    hair_restoration   = S[33][20],
    tongue_clinic      = S[33][21],
    fracture_clinic    = S[33][22],
    training_room      = S[33][23],
    electrolysis       = S[33][24],
    jelly_vat          = S[33][25],
    staffroom          = S[33][26],
    -- rehabilitation  = S[33][27], -- unused
    general_diag       = S[33][28],
    research_room      = S[33][29],
    toilets            = S[33][30],
    decontamination    = S[33][31],
  },
  
  objects = {
    -- S[40][1] unused.
    -- NB: most objects do not have a tooltip because they're not (extra-)buyable
    desk                 = S[40][ 2],
    cabinet              = S[40][ 3],
    door                 = S[40][ 4],
    bench                = S[40][ 5],
    table1               = S[40][ 6], -- unused
    chair                = S[40][ 7],
    drinks_machine       = S[40][ 8],
    bed                  = S[40][ 9],
    inflator             = S[40][10],
    pool_table           = S[40][11],
    reception_desk       = S[40][12],
    table2               = S[40][13], -- unused & duplicate
    cardio               = S[40][14], -- no description
    scanner              = S[40][15], -- no description
    console              = S[40][16], -- no description
    screen               = S[40][17], -- no description
    litter_bomb          = S[40][18],
    couch                = S[40][19], -- no description
    sofa                 = S[40][20],
    crash_trolley        = S[40][21], -- no description
    tv                   = S[40][22],
    ultrascanner         = S[40][23], -- no description
    dna_fixer            = S[40][24], -- no description
    cast_remover         = S[40][25], -- no description
    hair_restorer        = S[40][26], -- no description
    slicer               = S[40][27], -- no description
    x_ray                = S[40][28], -- no description
    radiation_shield     = S[40][29], -- no description
    x_ray_viewer         = S[40][30], -- no description
    operating_table      = S[40][31], -- no description
    lamp                 = S[40][32], -- unused
    toilet_sink          = S[40][33],
    op_sink1             = S[40][34], -- no description
    op_sink2             = S[40][35], -- no description
    surgeon_screen       = S[40][36], -- no description
    lecture_chair        = S[40][37],
    projector            = S[40][38], -- no description
    bed2                 = S[40][39], -- unused duplicate
    pharmacy_cabinet     = S[40][40],
    computer             = S[40][41],
    atom_analyser        = S[40][42],
    blood_machine        = S[40][43], -- no description
    fire_extinguisher    = S[40][44],
    radiator             = S[40][45],
    plant                = S[40][46],
    electrolyser         = S[40][47], -- no description
    jelly_moulder        = S[40][48], -- no description
    gates_of_hell        = S[40][49], -- no description
    bed3                 = S[40][50], -- unused duplicate
    bin                  = S[40][51],
    toilet               = S[40][52],
    swing_door1          = S[40][53], -- no description
    swing_door2          = S[40][54], -- no description
    shower               = S[40][55], -- no description
    auto_autopsy         = S[40][56],
    bookcase             = S[40][57],
    video_game           = S[40][58],
    entrance_left        = S[40][59], -- no description
    entrance_right       = S[40][60], -- no description
    skeleton             = S[40][61],
    comfortable_chair    = S[40][62], -- no description
  },
}

-- 34: staff titles, inserted further above

confirmation = {
  quit                 = S[35][1],
  return_to_blueprint  = S[35][2],
  replace_machine      = S[35][3], -- %s (machine name) %d (price)
  overwrite_save       = S[35][4],
  delete_room          = S[35][5],
  sack_staff           = S[35][6],
  restart_level        = S[35][7], -- missing in some TH versions
}

bank_manager = {
  hospital_value    = S[36][1],
  balance           = S[36][2],
  current_loan      = S[36][3],
  interest_payment  = S[36][4],
  insurance_owed    = S[36][5],
  inflation_rate    = S[36][6],
  interest_rate     = S[36][7],
  statistics_page = {
    date            = S[37][1],
    details         = S[37][2],
    money_out       = S[37][3],
    money_in        = S[37][4],
    balance         = S[37][5],
    current_balance = S[37][6],
  },
}

newspaper = {
  -- Seven categories of funny headlines. I think each category is related
  -- to one criterium you can lose to. TODO: categorize
  { S[38][ 1], S[38][ 2], S[38][ 3], S[38][ 4], S[38][ 5]            },
  { S[38][ 7], S[38][ 8], S[38][ 9], S[38][10], S[38][11], S[38][12] },
  { S[38][14], S[38][15], S[38][16], S[38][17]                       },
  { S[38][19], S[38][20], S[38][21], S[38][22]                       },
  { S[38][24], S[38][25], S[38][26], S[38][27], S[38][28], S[38][29] },
  { S[38][31], S[38][32], S[38][33], S[38][34],                      },
  { S[38][36], S[38][37], S[38][38], S[38][39], S[38][40]            },
}

-- 39: letters
-- Letters are organized in another level, just like menu strings.
local L = {{""}}
do
  local i = 1
  local section = 1
  while true do
    local s = S[39][i]
    if s == "." then
      section = section + 1
      L[section] = {}
      L[section][1] = ""
    elseif s == ".." then
      L[section] = nil
      break
    else
      L[section][#L[section]] = L[section][#L[section]] .. s
      if s:find("//") then
        L[section][#L[section] + 1] = ""
      end
    end
    i = i + 1
  end
end

letter = L
-- table of 12 tables (one for each level)
-- each sub-table contains a varying number of strings that form the letter together

-- 40: object tooltips, inserted further above
-- 41: load menu, inserted further above

vip_names = {
  health_minister = S[42][1],
  S[42][ 2], -- the rest is better organized in an array.
  S[42][ 3],
  S[42][ 4],
  S[42][ 5],
  S[42][ 6],
  S[42][ 7],
  S[42][ 8],
  S[42][ 9],
  S[42][10],
  S[42][11],
}

-- 43: credits
-- Maybe we could include them somewhere as a tribute. Maybe not.
-- Translators, please do not bother translating these...
original_credits = S[43]

-- 44: faxes and disease descriptions (cause/symptoms/cure)
-- diseases were already covered above
fax = {
  debug_fax = {
    -- never seen this, must be a debug option of original TH
    -- TODO: make this nicer if we ever want to make use of it
    close_text = S[44][ 1],
    text1      = S[44][ 3], -- %d
    text2      = S[44][ 4], -- %d %d
    text3      = S[44][ 5], -- %d %d %d %d %d
    text4      = S[44][ 6], -- %d %d %d %d %d
    text5      = S[44][ 7], -- %d %d %d %d %d
    text6      = S[44][ 8],
    text7      = S[44][ 9], -- %d %d %d
    text8      = S[44][10], -- %d %d %d
    text9      = S[44][11], -- %d %d %d %d
    text10     = S[44][12], -- %d %d %d %d
    text11     = S[44][13], -- %d
  },
    
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

-- 45: strange texts, maybe linked to some cheat codes..
-- Seems we won't need them.

staff_descriptions.misc = S[46]
staff_descriptions.good = S[47]
staff_descriptions.bad  = S[48]

-- remove last string from each category (".")
staff_descriptions.misc[38] = nil
staff_descriptions.good[16] = nil
staff_descriptions.bad[16] = nil

queue_window = {
  num_in_queue       = S[49][1],
  num_expected       = S[49][2],
  num_entered        = S[49][3],
  max_queue_size     = S[49][4],
}

-- TODO: continue here with section 50
-- ...

-- 54:  Introduction texts to each level
local T = {}
local level_index = 0
local text_index = 2
while true do
  local text = S[54][text_index]
  if text == "." then
    level_index = level_index + 1
    T["level" .. level_index] = {}
  elseif text == ".." then
    break
  else
    T["level" .. level_index][#T["level" .. level_index] + 1] = text
  end
  text_index = text_index + 1
end
introduction_texts = T

-- 55: Award texts inserted in the trophy room section (27)

-- 57: Information texts for the different rooms
local R = {}
-- Note that if an id of a room is changed this will need to be changed too.
-- TODO: A better solution maybe?
local ids = {
  "gp", 
  "psych", 
  "ward", 
  "operating_theatre", 
  "pharmacy", 
  "cardiogram", 
  "scanner",
  "ultrascan",
  "blood_machine",
  "x_ray",
  "inflation",
  "dna_fixer",
  "hair_restoration",
  "slack_tongue",
  "fracture_clinic",
  "training",
  "electrolysis",
  "jelly_vat",
  "staff_room",
  "tv_room",
  "general_diag",
  "research",
  "toilets",
  "decontamination",
  "no_room",
}
local id_index = 0
text_index = 14
while true do
  local text = S[57][text_index]
  if text == "." then
    id_index = id_index + 1
    R[ids[id_index]] = {""}
  elseif text == ".." then
    break
  else
    R[ids[id_index]][#R[ids[id_index]]] = R[ids[id_index]][#R[ids[id_index]]] .. text
    if R[ids[id_index]][#R[ids[id_index]]]:sub(-1) == "." then
      R[ids[id_index]][#R[ids[id_index]]] = R[ids[id_index]][#R[ids[id_index]]] .. " "
    end
    if text:find("//") then
      R[ids[id_index]][#R[ids[id_index]] + 1] = ""
    end
  end
  text_index = text_index + 1
end
room_descriptions = R

-- 59: The dynamic info bar

dynamic_info = {
  patient = {
    actions = {
      dying                       = S[59][ 5],
      awaiting_decision           = S[59][ 6],
      queueing_for                = S[59][ 7], -- %s
      on_my_way_to                = S[59][ 8], -- %s
      cured                       = S[59][ 9],
      fed_up                      = S[59][10],
      sent_home                   = S[59][11],
      sent_to_other_hospital      = S[59][12],
      no_diagnoses_available      = S[59][16],
      no_treatment_available      = S[59][17],
      waiting_for_diagnosis_rooms = S[59][18],
      waiting_for_treatment_rooms = S[59][19],
      prices_too_high             = S[59][20],
      epidemic_sent_home          = S[59][25],
      epidemic_contagious         = S[59][26],
    },
    diagnosed                   = S[59][13], -- %s
    guessed_diagnosis           = S[59][14], -- %s
    diagnosis_progress          = S[59][15],
    emergency                   = S[59][23], -- %s (disease name)
  },
  vip                           = S[59][21],
  health_inspector              = S[59][22],
  
  staff = {
    psychiatrist_abbrev         = S[59][27],
    actions = {
      waiting_for_patient         = S[59][24],
      wandering                   = S[59][28],
      going_to_repair             = S[59][35], -- %s (name of machine)
    },
    tiredness                   = S[59][29],
    ability                     = S[59][30], -- unused?
  },
  
  object = {
    strength                    = S[59][31], -- %d (max. uses)
    times_used                  = S[59][32], -- %d (times used)
    queue_size                  = S[59][33], -- %d (num of patients)
    queue_expected              = S[59][34], -- %d (num of patients)
  },
}

-- 60: The progress report window

progress_report = {
  header                = S[60][1],
  very_unhappy          = S[60][2],
  quite_unhappy         = S[60][3],
  more_drinks_machines  = S[60][4],
  too_hot               = S[60][5],
  too_cold              = S[60][6],
  percentage_pop        = S[60][7],
  win_criteria          = S[60][8],
}

-- 62: Some initial advice from the adviser. These are under the adviser variable above.
-- 63: Two strings inserted in trophy_room, used for trophies.
-- 64: Tooltip for the winning conditions
-- These are inserted in the tooltip section under status.

-- ...
