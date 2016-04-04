--[[ Copyright (c) 2013 nullstein

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
Language("한국어", "Korean", "kor", "ko")
Inherit("English")
Encoding(utf8)

misc = {
  hospital_open = "병원이 문을 열었습니다",
  save_success = "게임이 저장되었습니다",
  save_failed = "오류: 게임을 저장하지 못했습니다",
  low_res = "저해상도",
  no_heliport = "아직 아무 질병도 발견되지 않았거나 이 지도에 헬리콥터 이착륙장이 없습니다.  아니면 접수대를 배치하고 접수원을 고용해야 될지도 모릅니다.",
  grade_adverb = {
    extremely = "매우",
    mildly = "약간",
    moderately = "적당히",
  },
  not_yet_implemented = "(미구현)",
  send_message = "플레이어 %d 에게 메시지를 보냅니다",
  out_of_sync = "게임 동기화에 실패했습니다",
  balance = "밸런스 파일:",
  load_failed = "저장된 게임을 불러오지 못했습니다",
  mouse = "마우스",
  done = "모두 완료됨",
  --[[force = "Force",--]]
  pause = "일시 정지",
  send_message_all = "모든 플레이어에게 메시지를 보냅니다",
}
font_location_window = {
  caption = "폰트를 선택하세요 (%1%)",
}
staff_list = {
  morale = "사기",
  tiredness = "피로도",
  skill = "기술",
  total_wages = "전체 임금",
}
research = {
  allocated_amount = "할당량",
  funds_allocation = "자금 할당",
  categories = {
    improvements = "개선",
    drugs = "신약 개발",
    diagnosis = "진단 장비",
    cure = "치료 장비",
    specialisation = "집중 연구",
  },
}
debug_patient_window = {
  caption = "환자 디버그",
}
totd_window = {
  previous = "이전 팁",
  tips = {
    [1] = "모든 병원은 접수대와 진료실이 있어야 돌아갑니다. 그 이후에는 어떤 종류의 환자가 방문하는지에 달려있습니다. 약국을 설치하는건 언제나 좋은 선택이지만요.",
    [2] = "팽창기와 같은 기계들은 정비를 해줘야 합니다. 잡역부를 한 두명 고용해서 기계들을 수리하지 않으면, 직원들이나 환자들이 다첼 수 있습니다.",
    [3] = "어느 정도 지나면 직원들은 지치게 됩니다. 직원 휴게실을 만들어서 직원들이 쉴 수 있게 해주세요.",
    [4] = "라디에이터를 충분히 배치해서 직원들과 환자들을 따뜻하게 해주지 않으면 그들이 점차 불행해질 겁니다. 마을 지도를 이용해서 난방이 더 필요한 지점을 찾으세요.",
    [5] = "의사의 숙련도는 진단의 정확도와 속도에 큰 영향을 미칩니다. 진료실에 숙련된 의사를 배치하면 추가적인 진단 시설이 많이 필요하지 않게 됩니다.",
    [6] = "수련의와 전공의는 교육실에서 전문의에게 배움으로써 숙련도를 올릴 수 있습니다. 가르치는 전문의가 전문 분야 자격이 있다면 (외과, 정신과, 또는 연구), 전문 지식도 함께 전수됩니다.",
    [7] = "팩스 기계에 비상전화 번호(112)를 입력해 보셨나요? 소리가 켜져있는지 꼭 확인하세요!",
    [8] = "화면 해상도나 언어등의 설정은 메인 메뉴 혹은 게임 내의 옵션 창에서 조절할 수 있습니다.",
    [9] = "영어가 아닌 언어를 선택했지만 여기저기에 영어로된 글들이 보이시나요? 빠진 글들을 여러분의 언어로 번역하는 일을 도와주세요!",
    [10] = "CorsixTX 팀에는 증원 부대가 필요합니다! CorsixTH 의 코딩, 번역, 혹은 그래픽 작업에 관심이 있으신가요? 포럼, 메일링 리스트, 또는 IRC 채널 (freenode의 corsix-th)을 통해서 우리에게 연락 주세요.",
    [11] = "버그를 발견하면 버그 트래커(th-issues.corsix.org) 에 제보해주세요",
    [12] = "각 레벨은 다음 레벨로 넘어가기 위해 달성해야할 복표들이 있습니다. 레벨 목표 달성의 진행 상황을 보려면 상태 창을 확인하세요.",
    [13] = "이미 지어진 방을 삭제하거나 편집하기 원할 때는 아래쪽 툴바에 있는 편집 버튼을 사용하면 됩니다.",
    [14] = "기다리는 환자가 너무 많을 때에는, 마우스 커서를 특정 방 위에 올려서 그 방에 기다리고 있는 환자들이 누구인지 금방 알아낼 수 있습니다.",
    [15] = "특정 방의 문을 클릭하면 그 방의 대기열을 볼 수 있습니다. 여기서 대기 순서를 변경하거나 환자를 다른 방으로 보내는 등의 유용한 조율이 가능합니다.",
    [16] = "불행한 직원은 급여 인상을 자주 요구할 것입니다. 이런 일이 일어나지 않도록 직원들이 일하기 편안한 환경을 조성해주세요.",
    [17] = "환자들은 병원 안에서 기다리는 동안 목이 말라지며, 난방이 강할 수록 더욱 그렇습니다! 자판기를 전략적인 위치에 설치해서 추가 수입을 노리세요.",
    [18] = "환자의 진단 절차를 중단하고 추측에 의한 치료를 하는 것이 가능합니다 (해당 질병을 만났던 적이 있는 경우). 하지만 잘못된 치료를 해 환자를 죽음에 이르게 할 위험을 감수해야 합니다.",
    [19] = "응급 환자들을 시간 내에 치료할 수 있는 설비를 충분히 갖추고 있다는 전제 하에, 응급 사태는 좋은 추가 수입원이 될 수 있습니다.",
  },
  next = "다음 팁",
}
queue_window = {
  num_in_queue = "줄 길이",
  num_entered = "방문자 수",
  max_queue_size = "최대 줄 길이",
  num_expected = "예상",
}
staff_class = {
  doctor = "의사",
  handyman = "잡역부",
  receptionist = "접수원",
  nurse = "간호사",
  surgeon = "외과의",
}
tooltip = {
  hire_staff_window = {
    prev_person = "이전 사람 보기",
    cancel = "취소",
    psychiatrist = "정신과 의사",
    salary = "급여",
    next_person = "다음 사람 보기",
    nurses = "고용 가능한 간호사 보기",
    surgeon = "외과 의사",
    handymen = "고용 가능한 잡역부 보기",
    doctors = "고용 가능한 의사 보기",
    doctor_seniority = "의사의 계급 (수련의, 전공의, 전문의)",
    hire = "고용",
    researcher = "연구원",
    qualifications = "전문 분야 자격",
    receptionists = "고용 가능한 접수원 보기",
    staff_ability = "직원 능력",
  },
  handyman_window = {
    parcel_select = "잡역부가 일하는 구획입니다. 설정을 변경하려면 클릭하세요.",
    close = "요청 취소",
    ability = "능력",
    face = "잡역부의 얼굴",
    prio_machines = "기계 수리의 우선순위를 높입니다.",
    prio_litter = "바닥 쓰레기 청소의 우선순위를 높입니다.",
    happiness = "행복도",
    prio_plants = "화초 물주기의 우선순위를 높입니다.",
    name = "잡역부의 이름",
    tiredness = "피로도",
    center_view = "잡역부 살펴보기",
    salary = "급여",
    sack = "해고",
    pick_up = "집어 들기",
  },
  staff_list = {
    ability_2 = "고용인의 능력",
    next_person = "다음 페이지 보기",
    detail = "세부 사항에 대한 주의력",
    happiness = "고용인들이 얼마나 만족하고 있는지 보여줍니다",
    researcher_train = "연구원 교육을 %d%% 이수함",
    handymen = "이 병원에 고용된 잡역부 목록 보기",
    tiredness = "고용인들이 얼마나 피곤한지 보여줍니다",
    researcher = "연구원 자격 소지",
    happiness_2 = "고용인의 행복도",
    pay_rise = "이 사람의 급여를 10% 인상",
    bonus = "이 사람에게 10%의 보너스 지급",
    prev_person = "이전 페이지 보기",
    nurses = "이 병원에 고용된 간호사 목록 보기",
    psychiatrist = "정신과 의사 자격 소지",
    salary = "이 사람의 현재 급여",
    ability = "고용인들의 능력 수치를 보여줍니다",
    close = "게임으로 돌아가기",
    sack = "이 사람을 해고",
    surgeon = "외과 의사 자격 소지",
    tiredness_2 = "고용인의 피로도",
    doctors = "이 병원에 고용된 의사 목록 보기",
    doctor_seniority = "의사의 계급",
    view_staff = "이 사람이 일하는 모습 보기",
    surgeon_train = "외과 의사 교육을 %d%% 이수함",
    skills = "특수 기술",
    receptionists = "이 병원에 고용된 접수원 목록 보기",
    psychiatrist_train = "정신과 의사 교육을 %d%% 이수함",
  },
  research = {
    cure_dec = "치료 장비 연구 비율 감소",
    cure_inc = "치료 장비 연구 비율 증가",
    diagnosis_dec = "진단 장비 연구 비율 감소",
    diagnosis_inc = "진단 장비 연구 비율 증가",
    drugs_dec = "신약 개발 연구 비율 감소",
    drugs_inc = "신약 개발 연구 비율 증가",
    improvements_dec = "개선 연구 비율 감소",
    improvements_inc = "개선 연구 비율 증가",
    specialisation_dec = "집중 연구 비율 감소",
    specialisation_inc = "집중 연구 비율 증가",
    allocated_amount = "할당된 예산",
    close = "연구 화면 닫기",
  },
  customise_window = {
    intro = "인트로 영상을 켜거나 끕니다. CorsixTH 를 플레이할 때마다 인트로 영상을 재생하게 하려면 영상 컨트롤이 켜져 있어야 합니다",
    fractured_bones = "조잡한 애니메이션의 문제로, 기본적으로 여성 골절 환자는 등장하지 않도록 되어있습니다. 여성 골절 환자들이 병원을 방문하게 하려면 이 옵션을 끄세요",
    movies = "이 옵션을 끄면 게임 내의 모든 영상이 재생되지 않습니다",
    volume = "음량 감소 버튼이  약물 사례집을 열게 되는 경우, 이 옵션을 켜서 약물 사례집 단축키를 Shift + C 로 변경하세요",
    aliens = "적절한 애니메이션의 부재로, 외계인 DNA 환자들은 응급 상황에서만 방문하도록 되어있습니다. 외계 DNA 환자들이 병원을 평소에도 방문하게 하려면 이 옵션을 끄세요",
    paused = "테마 병원에서 기본적으로 플레이어는 게임이 일시 정지 되었을 때 상위 메뉴만을 사용할 수 있고, CorsixTH 에서도 마찬가지 입니다. 이 옵션을 켜면 게임이 정지된 상태에서도 모든 기능이 활성화 됩니다",
    average_contents = "방을 건설할 때 당신이 보통 어떤 비품들을 추가로 배치하는지 게임이 기억하도록 하려면 이 옵션을 켜세요",
    back = "이 메뉴를 닫고 옵션 메뉴로 돌아감",
  },
  machine_window = {
    repair = "잡역부를 불러서 수리하기",
    name = "이름",
    close = "요청 취소",
    times_used = "기계가 사용된 횟수",
    status = "기계의 상태",
    replace = "기계 교환",
  },
  place_objects_window = {
    confirm = "확인",
    cancel = "취소",
    pick_up = "물건 집어 들기",
    buy_sell = "물건 구매/판매",
  },
  totd_window = {
    previous = "이전 팁 보기",
    next = "다읍 팁 보기",
  },
  status = {
    percentage_cured = "당신은 병원에서 %d 명의 환자를 치료해야 합니다. 지금까지 %d 명을 치료했습니다.",
    population_chart = "각 병원이 현지 손님을 끌어오는 비율을 나타내는 도표",
    win_progress_own = "당신의 병원의 승리 요건 진행 상황 보기",
    win_progress_other = "%s 병원의 승리 요건 진행 상황 보기",
    reputation = "당신의 평판은 %d 이상이어야 합니다. 현재 평판은 %d 입니다.",
    population = "당신은 %d%% 이상의 현지 손님을 끌어와야 합니다.",
    percentage_killed = "이 목표는 %d%% 미만의 환자를 죽이는 것입니다. 지금까지 당신은 %d%% 의 환자를 죽였습니다.",
    balance = "당신의 은행 잔고는 %d 이상이어야 합니다. 현재 잔고는 %d 입니다.",
    value = "당신의 병원 가치는 $%d 이상이어야 합니다. 현재 가치는 $%d 입니다.",
    num_cured = "이 목표는 %d 명의 환자를 치료하는 것입니다. 지금까지 당신은 %d 명을 치료했습니다.",
    happiness = "당신의 병원에 있는 사람들의 전체적인 행복도",
    thirst = "당신의 병원에 있는 사람들의 전체적인 목마름 정도",
    warmth = "당신의 병원에 있는 사람들의 전체적인 온도",
    close = "개요 창 닫기",
  },
  queue_window = {
    front_of_queue = "환자를 줄 맨 앞으로 보내려면 드래그해서 이 아이콘 위에 놓으세요",
    end_of_queue = "환자를 줄 맨 끝으로 보내려면 드래그해서 이 아이콘 위에 놓으세요",
    num_entered = "지금까지 이 방에서 치료된 환자 수",
    num_in_queue = "대기중인 환자 수",
    num_expected = "접수원이 예상하는 이 곳에서 곧 추가로 대기하게 될 환자 수",
    dec_queue_size = "최대 줄 길이 감소",
    max_queue_size = "접수원이 유지하려고 노력해야 하는 최대 줄 길이",
    inc_queue_size = "최대 줄 길이 증가",
    patient = "환자를 줄 내에 특정 위치로 옮기려면 드래그 하세요. 오른클릭으로 집으로 돌려 보내거나 경쟁 병원에 보내세요.",
    patient_dropdown = {
      send_home = "환자를 병원에서 내보냄",
      hospital_1 = "환자에게 다른 병원 소개하기",
      hospital_2 = "환자에게 다른 병원 소개하기",
      hospital_3 = "환자에게 다른 병원 소개하기",
      reception = "환자를 접수원에게 보내기",
    },
    close = "닫기",
  },
  jukebox = {
    rewind = "주크박스 되감기",
    loop = "주크박스 반복 재생",
    stop = "주크박스 정지",
    current_title = "주크박스",
    play = "주크박스 재생",
    fast_forward = "주크박스 빨리 감기",
    close = "주크박스 닫기",
  },
  graphs = {
    deaths = "죽은 환자 수 켜기/끄기",
    scale = "그래프 비율",
    money_out = "돈 지출 켜기/끄기",
    visitors = "방문자 수 켜기/끄기",
    wages = "급여 켜기/끄기",
    balance = "잔고 켜기/끄기",
    money_in = "돈 수입 켜기/끄기",
    cures = "치료 수 켜기/끄기",
    reputation = "병원 가치 켜기/끄기",
    close = "그래프 창 닫기",
  },
  toolbar = {
    reputation = "당신의 평판",
    casebook = "약물 사례집",
    edit = "방/아이템 편집",
    staff_list = "직원 관리",
    policy = "정책",
    date = "날짜",
    charts = "도표",
    objects = "복도에 물건 설치",
    balance = "당신의 잔고",
    research = "연구",
    hire = "작원 고용",
    status = "상태",
    town_map = "마을 지도",
    rooms = "방 만들기",
    bank_button = "은행 지점장을 보려면 왼쪽 클릭, 명세서를 보려면 오른쪽 클릭",
  },
  message = {
    button = "메시지를 보려면 왼쪽 클릭",
    button_dismiss = "메시지를 보려면 왼쪽 클릭, 무시하려면 오른쪽 클릭",
  },
  pay_rise_window = {
    accept = "급여 인상 요구를 들어줌",
    decline = "인상하지 않음 - 해고",
  },
  town_map = {
    people = "사람 켜기/끄기",
    plants = "화초 켜기/끄기",
    fire_extinguishers = "소화기 켜기/끄기",
    objects = "기물 켜기/끄기",
    radiators = "라디에이터 켜기/끄기",
    heat_dec = "난방 감소",
    heat_inc = "난방 증가",
    heat_level = "난방 정도",
    heating_bill = "난방비",
    balance = "잔고",
    close = "마을 창 닫기",
  },
  custom_game_window = {
    start_game_with_name = "%s 레벨 불러오기",
    free_build = "돈이나 승리/패배 조건 없이 자유롭게 플레이하려면 체크하세요",
  },
  cheats_window = {
    cheats = {
      end_month = "이 달의 마지막으로 점프",
      create_patient = "지도 가장자리에 환자를 생성",
      money = "은행 잔고에 10.000 추가",
      emergency = "응급 상황 만들기",
      win_level = "현재 레벨 승리",
      vip = "VIP 생성",
      lose_level = "현재 레벨 패배",
      earthquake = "지진 생성",
      all_research = "모든 연구 완료",
      end_year = "이 해의 마지막으로 이동",
    },
    close = "치트 창 닫기",
  },
  casebook = {
    reputation = "치료 혹은 진단 평판",
    treatment_charge = "치료 비용",
    decrease = "비용 감소",
    increase = "비용 증가",
    earned_money = "지금까지 벌어들인 돈",
    cured = "치료 환자 수",
    deaths = "사망 환자 수",
    sent_home = "돌려보낸 환자 수",
    research = "집중 연구 예산을 이 치료에 투자하려면 클릭하세요",
    cure_type = {
      psychiatrist = "정신과 의사가 치료할 수 있습니다",
      drug_percentage = "약물로 치료 가능합니다 - 당신의 약은 %d%% 효과가 있습니다",
      drug = "약물로 치료 가능합니다",
      machine = "치료하기 위해서는 치료 장비가 필요합니다",
      surgery = "수술로 치료 가능합니다",
      unknown = "당신은 이 병을 어떻게 치료하는지 모릅니다",
    },
    cure_requirement = {
      hire_staff_old = "치료를 위해서는 %s를 한 명 고용해야 합니다",
      hire_staff = "치료를 위해서는 직원을 고용해야 합니다",
      possible = "당신은 이 병을 치료할 수 있습니다",
      not_possible = "당신은 아직 이 병을 치료할 수 없습니다",
      ward_hire_nurse = "치료를 위해서는 병동에서 일하는 간호사가 필요합니다",
      hire_surgeon = "수술하기 위해서는 두 명째 외과 의사를 고용해야 합니다",
      research_machine = "치료를 위한 장비를 연구해야 합니다",
      build_room = "치료를 위해서는 방을 만들어야 합니다",
      build_ward = "치료를 위해서는 병동을 만들어야 합니다",
      hire_surgeons = "수술하기 위해서는 두 명의 외과 의사를 고용해야 합니다",
    },
    up = "위로 스크롤",
    down = "아래로 스크롤",
    close = "사례집 닫기",
  },
  policy = {
    diag_procedure = "의사의 진단이 [돌려 보내기] 퍼센트 미만으로 확실할 경우에는 환자를 집으로 돌려 보냅니다. 진단이 [추측에 의한 치료] 퍼센트 이상으로 확실할 경우에는 환자를 적절한 치료 시설로 보냅니다.",
    diag_termination = "환자에 대한 진단은 의사들이 [절차 중지] 퍼센트 만큼 확신이 있거나, 모든 진단 장비들을 시도해볼 때까지 계속됩니다.",
    staff_rest = "직원이 휴식을 취하러 갈 수 있는 최소한의 피로도",
    staff_leave = "바쁘지 않은 직원이 도움을 필요로 하는 동료를 돕도록 하려면 여기를 클릭하세요.",
    staff_stay = "특정 직원이 배치된 방 안에서 계속 일하도록 하려면 여기를 클릭하세요.",
    close = "정책 화면 닫기",
  },
  bank_manager = {
    hospital_value = "당신의 병원의 현재 가치",
    balance = "당신의 은행 잔고",
    current_loan = "지불해야할 대출금",
    repay_5000 = "은행에 $5000 갚기",
    borrow_5000 = "은행에서 $5000 빌리기",
    interest_payment = "매달 지불하는 이자",
    insurance_owed = "%s 가 당신에게 지불해야할 금액",
    show_graph = "%s 의 예상 지불 그래프 보기",
    graph = "%s 의 예상 지불 그래프",
    inflation_rate = "연간 인플레이션 비율",
    interest_rate = "연간 이자율",
    graph_return = "이전 화면으로 돌아가기",
    close = "은행 지점장 화면 닫기",
  },
  main_menu = {
    exit = "안돼요, 제발 나가지 마세요!",
    custom_level = "단일 시나리오 내에서 병원을 짓기",
    network = "네트워크 게임 시작",
    quit = "종료",
    continue = "지난 게임 이어하기",
    options = "설정 변경",
    load_menu = {
      load_slot = "게임 불러오기",
      empty_slot = "비어있음",
    },
    new_game = "캠페인 시작",
    load_game = "저장된 게임 불러오기",
  },
  patient_window = {
    graph = "이 사람의 건강 그래프와 병력 사이를 오가려면 클릭",
    close = "닫기",
    queue = "이 사람이 속한 줄 자세히 보기",
    happiness = "이 사람의 행복도",
    thirst = "이 사람의 목마름 정도",
    warmth = "이 사람의 따뜻함 정도",
    casebook = "이 사람의 병에 대해 자세히 보기",
    center_view = "이 사람의 위치로 이동",
    send_home = "이 사람을 집으로 돌려보내기",
    abort_diagnosis = "진단 끝나기 기다리지 않고 이 사람을 치료 시설로 보냄",
  },
  menu_list_window = {
    save_date = "마지막으로 수정된 날짜를 기준으로 목록을 정렬하려면 여기를 클릭",
    name = "이름을 기준으로 목록을 정렬하려면 여기를 클릭",
    back = "이 창 닫기",
  },
  watch = {
    emergency = "응급 상황: 응급 환자들을 모두 치료하기 위해 남은 시간",
    hospital_opening = "건설 시간: 이 시간은 당신의 병원이 개원을 선언하기까지 남은 시간입니다. 버튼을 누르면 병원 문을 즉시 엽니다.",
    epidemic = "전염병: 전염병을 처리하기 위해 남은 시간. 제한 시간이 다 지나거나 또는 전염병에 걸린 환자가 당신의 병원을 떠나게 되면, 건강 검사관이 병원을 방문할 것입니다. 버튼을 누르면 백신 모드가 켜지거나 꺼집니다. 환자를 클릭하여 간호사에게 예방 접종을 맞게 할 수 있습니다.",
  },
  new_game_window = {
    player_name = "게임 내에서 당신이 불리기 원하는 이름을 입력하세요",
    tutorial = "클릭하여 게임 내에서 플레이하는 방법을 배울 수 있습니다",
    difficulty = "게임의 난이도를 선택하세요",
    easy = "시뮬레이션 게임을 처음 접한다면, 이것이 당신을 위한 옵션입니다",
    medium = "어떤 난이도를 선택할지 잘 모르겠다면 중간 난이도로 플레이 하세요",
    hard = "이런 종류의 게임에 익숙하며 좀 더 도전하고 싶다면 이 옵션을 선택하세요",
    start = "선택한 설정으로 게임을 시작합니다",
    cancel = "새 게임을 시작할 생각은 없었어요!",
  },
  save_game_window = {
    new_save_game = "저장될 게임의 이름을 입력하세요",
    save_game = "저장된 게임 %s 덮어쓰기",
  },
  update_window = {
    download = "가장 최신 버전의 CorsixTH 다운로드 페이지로 이동합니다",
    ignore = "이 업데이트를 무시합니다. 다음 번에 CorsixTH 를 열 때 다시 알립니다",
  },
  calls_dispatcher = {
    assigned = "누군가가 해당 과업에 할당되어 있으면 이 상자가 표시됩니다",
    task = "과업 목록 - 할당된 직원의 정보와 과업의 위치를 보려면 과업을 클릭하세요",
    close = "콜 디스패쳐 창 닫기",
  },
  research_policy = {
    research_progress = "이 분야에서 새로운 발견을 하기 위한 진행 상황: %1%/%2%",
    no_research = "지금은 이 분야에 대한 연구가 이뤄지고 있지 않습니다",
  },
  information = {
    close = "정보 창 닫기",
  },
  lua_console = {
    textbox = "실행할 루아 코드를 여기 입력하세요",
    execute_code = "입력한 코드 실행",
    close = "콘솔 닫기",
  },
  folders_window = {
    browse_font = "다른 폰트 파일을 지정합니다 ( 현재 위치: %1% )",
    screenshots_location = "기본적으로, 스크린샷들은 설정 파일이 있는 곳에 함께 저장됩니다. 필요한 경우 스크린샷을 원하는 곳에 저장할 수 있습니다. 사용하기 원하는 디렉토리를 선택하세요.",
    browse_music = "다른 음악 디렉토리를 지정합니다 ( 현재 위치: %1% )",
    music_location = "mp3 음악 파일들이 있는 위치를 지정하세요. 디렉토리는 미리 만들어져 있어야 합니다.",
    data_location = "오리지널 테마 병원 설치 경로 (CorsixTH 를 플레이 하기 위해 필요)",
    browse_data = "테마 병원 설치 경로를 다시 설정합니다 ( 현재 위치: %1% )",
    savegames_location = "기본적으로, 저장된 게임들은 설정 파일이 있는 곳에 함께 저장됩니다. 필요한 경우 저장된 게임들을 원하는 곳에 저장할 수 있습니다. 사용하기 원하는 디렉토리를 선택하세요.",
    back = "이 메뉴를 닫고 설정 메뉴로 돌아갑니다",
    browse_saves = "다른 저장 디렉토리를 지정합니다 ( 현재 위치: %1% )",
    browse = "폴더 위치를 지정합니다",
    browse_screenshots = "다른 스크린샷 디렉토리를 지정합니다 ( 현재 위치: %1% )",
    not_specified = "폴더 위치 지정되지 않음!",
    font_location = "사용중인 언어를 표시하는데 필요한 폰트 파일의 위치를 지정합니다. 이것을 설정하지 않으면 오리지널 게임에 포함되지 않은 문자들은 표시되지 않습니다 (예: 러시아어, 중국어)",
    reset_to_default = "디렉토리를 기본 위치로 되돌립니다",
    default = "기본 위치",
    no_font_specified = "폰트 위치 지정되지 않음!",
  },
  staff_window = {
    name = "직원 이름",
    face = "이 사람의 얼굴 - 관리 화면을 보려면 클릭",
    happiness = "행복도",
    tiredness = "피로도",
    ability = "능력",
    doctor_seniority = "계급 - 수련의, 전공의, 또는 전문의",
    skills = "전문 분야 자격",
    surgeon = "외과 의사",
    psychiatrist = "정신과 의사",
    researcher = "연구원",
    salary = "월급",
    center_view = "왼쪽 클릭으로 직원 보기, 오른쪽 클릭으로 다음 직원으로 넘어가기",
    sack = "해고",
    pick_up = "집어 들기",
    close = "닫기",
  },
  rooms = {
    gps_office = "환자는 진료실에서 최초의 상담을 받습니다",
    general_diag = "의사는 일반 진단실을 사용해 환자들의 기본 진단을 수행합니다. 값이 싸고 매우 효과적인 편입니다",
    psychiatry = "정신과에서는 미친 환자들을 치료하거나, 다른 환자들의 진단을 도울 수 있지만 정신과 의사 자격이 있는 의사가 필요합니다",
    cardiogram = "의사는 심전도실을 사용해 환자들을 진단합니다",
    scanner = "의사는 스캐너실을 사용해 환자들을 진단합니다",
    x_ray = "의사는 X-레이실을 사용해서 환자들을 진단합니다",
    ultrascan = "의사는 울트라스캔 시설을 사용해 환자들을 진단합니다",
    blood_machine = "의사는 혈액 분석실을 사용해 환자들을 진단합니다",
    pharmacy = "간호사는 약국에서 환자들을 치료할 약을 조제합니다",
    ward = "병동은 진단과 치료에 모두 유용합니다. 환자들을 이곳에 보내서 간호사를 통해 관찰하거나 수술 후 회복기간을 갖게 합니다",
    operating_theatre = "수술실에는 외과 의사 자격이 있는 의사 두 명이 필요합니다",
    inflation = "의사는 팽창기를 사용해서 부은 머리를 치료합니다",
    tongue_clinic = "의사는 혀 절단실을 사용해 늘어진 혀를 치료합니다",
    fracture_clinic = "간호사는 골절 클리닉을 사용해서 부러진 뼈를 고칩니다",
    jelly_vat = "의사는 젤리통으로 젤리염을 치료합니다",
    electrolysis = "의사는 전기분해실을 사용해서 모발과다증을 치료합니다",
    hair_restoration = "의사는 모발 재생기를 사용해 대머리를 치료합니다",
    decontamination = "의사는 오염제거 샤워를 통해 방사능 오염을 치료합니다",
    dna_fixer = "의사는 DNA 정정실을 사용해 외계인 DNA를 가진 환자들을 치료합니다",
    research_room = "연구원 자격을 가진 의사들은 연구실에서 신약과 새로운 기계등을 발견해낼 수 있습니다",
    training_room = "교육실에서는 전문의가 다른 의사들을 교육시킬 수 있습니다",
    toilets = "화장실을 지어 환자들이 당신의 병원을 어지럽히는걸 막으세요!",
    staffroom = "의사들과 간호사들은 직원 휴게실에서 긴장을 풀고 피로를 풉니다",
  },
  statement = {
    close = "명세서 화면 닫기",
  },
  buy_objects_window = {
    price = "이 물건의 가격",
    confirm = "선택된 기물(들) 구매",
    cancel = "취소",
    decrease = "이 물건 하나 덜 구매",
    increase = "이 물건 하나 더 구매",
    total_value = "주문하는 물건들의 총 가격",
  },
  load_game_window = {
    load_game = "%s 게임 불러오기",
    load_autosave = "자동 저장 불러오기",
    load_game_number = "%d번 게임 불러오기",
  },
  window_general = {
    confirm = "확인",
    cancel = "취소",
  },
  fax = {
    close = "메시지를 삭제하지 않고 창 닫기",
  },
  objects = {
    chair = "의자: 환자들이 여기 앉아서 병에 대해 상담합니다",
    litter = "쓰레기: 환자가 버릴 쓰레기통을 찾기 못해서 바닥에 버려짐",
    sofa = "소파: 직원 휴게실에서 쉬는 직원들은 특별히 나은 휴식 방법이 없다면 소파에 조용히 앉아있습니다",
    bench = "벤치: 환자 한 명이 편하게 앉아서 기다릴 수 있는 자리를 제공합니다",
    video_game = "비디오 게임: 당신의 직원이 Hi-Octane 을 즐기며 긴장을 풀게 해줍니다",
    lamp = "전등: 빛을 비춰서 직원들이 볼 수 있게 합니다",
    door = "문: 사람들이 시도 때도 없이 열고 닫습니다",
    auto_autopsy = "자동부검기: 새로운 치료법을 발견하는 데 큰 도움을 줍니다",
    reception_desk = "접수대: 환자들을 의사들에게 안내하는 접수원을 필요로 합니다",
    tv = "TV: 당신의 직원이 좋아하는 방송을 놓치지 않게 해주세요",
    litter_bomb = "쓰레기 폭탄: 경쟁 병원을 고의로 방해합니다",
    inflator = "팽창기: 부은 머리 환자들을 치료합니다",
    desk = "책상: 의사가 PC를 사용하는 데 필요합니다",
    pool_table = "당구대: 당신의 직원이 긴장을 푸는 데 좋습니다",
    bed = "침대: 굉장히 아픈 사람들이 침대에 눕습니다",
    drinks_machine = "자판기: 환자들이 목마르지 않게 하고 이윤을 남깁니다",
    bookcase = "책장: 의사들의 참고 자료",
    skeleton = "해골: 교육과 할로윈 용도로 사용",
    computer = "컴퓨터: 핵심 연구 요소",
    bin = "쓰레기통: 환자들이 쓰레기를 여기 버립니다",
    pharmacy_cabinet = "약장: 약이 보관되는 장소",
    radiator = "라디에이터: 당신의 병원이 추워지지 않게 합니다",
    atom_analyser = "화학 혼합기: 연구소에 배치되어 연구 프로세스 전체를 가속화 합니다",
    plant = "화초: 환자들이 행복하게 하고 공기를 정화합니다",
    toilet = "변소: 환자들이 이걸, 음, 어쨌든 사용합니다",
    fire_extinguisher = "소화기: 오동작하는 기계의 위험을 최소화합니다",
    lecture_chair = "강의 의자: 교육 받는 의사들이 여기에 앉아서 필기하고, 지루해하며 빈둥거립니다. 의자를 많이 배치할 수록 많은 학생이 수업을 들을 수 있습니다",
    toilet_sink = "세면대: 위생에 신경쓰는 환자들은 여기서 더러운 손을 씻을지도 모릅니다. 충분한 수의 세면대가 없으면 환자들은 불행해집니다",
    cabinet = "캐비넷: 환자들에 대한 서류철, 노트, 연구 문서 등을 보관합니다",
  },
  build_room_window = {
    cost = "현재 선택된 방의 비용",
    room_classes = {
      diagnosis = "진료 시설을 선택",
      treatment = "일반 치료 시설을 선택",
      clinic = "특화 클리닉 시설을 선택",
      facilities = "편의, 특수 시설 선택",
    },
    close = "요청을 취소하고 게임으로 돌아감",
  },
  options_window = {
    fullscreen = "게임을 전체화면으로 플레이할 것인지 설정합니다",
    cancel = "해상도를 변경하지 않고 돌아갑니다",
    back = "옵션 창을 닫습니다",
    language = "게임 내의 글을 표시할 언어",
    apply = "입력된 해상도를 적용합니다",
    change_resolution = "왼쪽에 입력된 해상도로 변경합니다",
    fullscreen_button = "전체화면 설정을 변경하려면 클릭하세요",
    width = "원하는 화면 너비를 입력하세요",
    language_dropdown_item = "%s 을(를) 언어로 선택합니다",
    height = "원하는 화면 높이를 입력하세요",
    select_language = "게임 언어를 선택하세요",
    select_resolution = "새로운 해상도를 선택하세요",
    resolution = "게임이 실행될 해상도",
    audio_button = "게임 전체의 오디오를 켜고 끕니다",
    folder_button = "폴더 옵션",
    audio_toggle = "켜고 끄기",
    customise_button = "게임 플레이 경험을 커스터마이즈 하기 위한 세부 설정",
  },
}
menu_charts = {
  bank_manager =    "  (F1) 은행 지점장  ",
  statement =       "  (F2) 명세서  ",
  staff_listing =   "  (F3) 직원 목록  ",
  town_map =        "  (F4) 마을 지도  ",
  casebook =        "  (F5) 사례집  ",
  research =        "  (F6) 연구  ",
  status =          "  (F7) 상태  ",
  graphs =          "  (F8) 그래프  ",
  policy =          "  (F9) 정책  ",
  briefing =        "  브리핑  ",
}
town_map = {
  number = "구획 번호",
  not_for_sale = "소유 불가",
  price = "구획 가격",
  for_sale = "판매중",
  owner = "구획 소유주",
  area = "구획 면적",
}
custom_game_window = {
  caption = "커스텀 게임",
  free_build = "자유 건설",
}
cheats_window = {
  caption = "치트",
  warning = "경고: 치트를 사용하면 레벨이 끝나고 보너스 점수를 전혀 받을 수 없게 됩니다!",
  cheats = {
    money = "돈 치트",
    all_research = "모든 연구 치트",
    emergency = "응급 상황 생성",
    vip = "VIP 생성",
    earthquake = "지진 생성",
    create_patient = "환자 생성",
    end_month = "월말",
    end_year = "연말",
    lose_level = "레벨 패배",
    win_level = "레벨 승리",
  },
  close = "닫기",
  cheated = {
    no = "치트 사용됨: 아니오",
    yes = "치트 사용됨: 예",
  },
}
room_descriptions = {
  ultrascan = {
    [1] = "울트라스캔//",
    [2] = "울트라스캔은 궁극의 진단 장비라고 할 수 있습니다. 비용이 많이 들지만 최고의 진단을 원한다면 충분히 가치가 있습니다.//",
    [3] = "울트라스캔을 작동하려면 의사가 필요합니다. 기계의 정비 또한 필요합니다.",
  },
  gp = {
    [1] = "진료실//",
    [2] = "이것은 병원의 가장 기본이 되는 진료실입니다. 새로 방문한 환자는 어떤 이상이 있는지 알아보기 위해 일단 진료실로 보내집니다. 그러고 나서는 다른 진단 시설로 보내지거나 치료할 수 있는 시설로 보내집니다. 만약 이 진료실이 너무 바빠진다면 다른 진료실을 추가로 지을 수도 있습니다. 방의 크기가 클 수록, 추가 기물들을 많이 배치할 수록 의사의 위신이 서게 됩니다. 이것은 다른 방들에 대해서도 마찬가지로 적용됩니다.//",
    [3] = "진료실에는 의사가 필요합니다.",
  },
  fracture_clinic = {
    [1] = "골절 클리닉//",
    [2] = "운이 없이 뼈가 부러진 환자들이 이곳으로 옵니다. 깁스 제거기는 강력한 공업용 레이저로 굳은 깁스를 잘라내면서 환자에게는 아주 미약한 통증만을 유발합니다.//",
    [3] = "골절 클리닉에는 간호사가 필요합니다. 그리고 기계도 자주 정비해 주어야 합니다.",
  },
  tv_room = {
    [1] = "TV실은 사용되지 않음",
  },
  inflation = {
    [1] = "팽창 클리닉//",
    [2] = "고통스럽지만 우스운 모습의 부은 머리 증상을 가진 환자들이 팽창 클리닉에 오면, 그들의 대두를 터뜨려서 곧바로 적정 압력으로 부풀립니다.//",
    [3] = "팽창 클리닉에는 의사가 필요합니다. 그리고 잡역부가 기계를 정비해 주어야 합니다.",
  },
  jelly_vat = {
    [1] = "젤리 클리닉//",
    [2] = "우스운 병인 젤리염의 저주를 받은 환자들은 비틀거리며 젤리 클리닉에 와서 젤리 통에 들어가야 합니다. 그러면 의학적으로 완전히 해명되지 않은 신기한 방법으로 치료됩니다.//",
    [3] = "젤리 클리닉에는 의사가 필요합니다. 그리고 잡역부의 정비도 필요합니다.",
  },
  scanner = {
    [1] = "스캐너//",
    [2] = "정교한 스캐너로 환자들을 정확히 진단합니다. 그러고 나서 환자들은 다시 진료실로 돌아가 다음 처방을 받습니다.//",
    [3] = "스캐너에는 의사가 필요합니다. 그리고 정비도 필요합니다.",
  },
  blood_machine = {
    [1] = "혈액 분석기//",
    [2] = "혈액 분석기는 환자의 혈액 내의 세포를 확인하여 어디가 잘못되었는지 확인하는 진단 장비입니다.//",
    [3] = "혈액 분석기에는 의사가 필요합니다. 그리고 정비도 필요합니다.",
  },
  pharmacy = {
    [1] = "약국//",
    [2] = "약물 처방을 받은 환자들은 약국에 가서 약을 받아야 합니다. 더 많은 약물 치료법이 연구될수록 약국은 더 바빠집니다. 나중에는 약국을 더 짓는 것도 좋습니다.//",
    [3] = "약국에는 간호사가 필요합니다.",
  },
  cardiogram = {
    [1] = "심전도실//",
    [2] = "환자들은 다시 진료실에 돌아가서 처방을 받기 전에 이곳에 와서 진단을 받습니다.//",
    [3] = "심전도실에는 의사가 필요합니다. 그리고 정비도 필요합니다.",
  },
  ward = {
    [1] = "병동//",
    [2] = "환자들의 진단 도중 이곳에 와서 간호사가 살펴볼 수 있습니다. 환자들은 수술을 받기 전까지 이곳에 머무릅니다.//",
    [3] = "병동에는 간호사가 필요합니다.",
  },
  psych = {
    [1] = "정신과//",
    [2] = "정진 질환으로 판명된 환자들은 정신과에 방문해서 상담을 받아야 합니다. 정신과 의사들은 또한 환자들이 어떤 병이 있는지 진단도 가능하고, 그것이 정신 질환인 경우에는 침상을 사용해 치료할 수 있습니다.//",
    [3] = "정신과에는 정신과 교육을 받은 의사가 필요합니다.",
  },
  staff_room = {
    [1] = "직원 휴게실//",
    [2] = "직원들도 일을 하다보면 지치게 됩니다. 그들은 긴장을 풀고 생기를 찾기 위해서 이 방을 필요로 합니다. 피로한 직원은 일하는 속도가 느려지고, 급여를 더 요구하며, 결국에는 병원을 나가게 됩니다. 또한 피로한 직원들은 실수를 더 자주 합니다. 다양한 할 것들이 있는 직원 휴게실은 지을 만한 가치가 있습니다. 여러 명의 직원이 동시에 쉴 수 있는 공간이 나오도록 해주세요.",
  },
  operating_theatre = {
    [1] = "수술실//",
    [2] = "이 중요한 시설에서 다양한 증상들이 치료됩니다. 수술실의 크기는 적절해야 하며, 올바른 장비들로 채워져야 합니다. 이 시설은 병원에 필수 불가결한 존재입니다.//",
    [3] = "수술실에는 외과 의사 자격이 있는 의사 두 명이 필요합니다.",
  },
  training = {
    [1] = "교육실//",
    [2] = "수련의와 전공의는 여기서 교육받으면서 추가 자격을 취득할 수 있습니다. 외과, 연구원, 정신과 자격을 가진 전문의는 자신에게 교육받는 의사들에게 이런 전문 분야 지식도 함께 전수하게 됩니다. 이미 자격이 있는 의사들은, 여기서 교육받는 동안 해당 지식을 어떻게 더 잘 사용할 수 있는지 깨우치게 될 겁니다.//",
    [3] = "교육실에는 전문의가 한 명 필요합니다.",
  },
  dna_fixer = {
    [1] = "DNA 클리닉//",
    [2] = "다른 세계에서 온 외계인에게 감염된 환자들은 그들의 DNA 를 교체받아야 합니다. DNA 정정기는 굉장히 복잡한 설비이므로, 만약을 위해 소화기를 비치해 두는 것이 현명할 것입니다.//",
    [3] = "DNA 정정기는 잡역부가 주기적으로 정비해주어야 합니다. 또한, DNA 정정기를 작동하려면 연구원 자격을 갖춘 의사가 필요합니다.",
  },
  research = {
    [1] = "연구실//",
    [2] = "연구실에서는 신약과 치료법 등이 새로 발견되거나 개선됩니다. 병원의 중요한 부분으로서, 당신의 치료율에 기적을 선사할 것입니다.//",
    [3] = "연구실에는 연구원 자격이 있는 의사가 필요합니다.",
  },
  hair_restoration = {
    [1] = "모발 재생 클리닉//",
    [2] = "극단적인 탈모를 겪는 환자들은 이 클리닉의 모발 재생기로 오게 됩니다. 의사가 기계를 작동하면, 환자의 머리에 새로운 머리카락이 신속하게 심겨집니다.//",
    [3] = "모발 재생 클리닉에는 의사가 필요합니다. 그리고 주기적인 정비가 필요합니다.",
  },
  general_diag = {
    [1] = "일반 진단실//",
    [2] = "더 진단받아야 하는 환자들은 이곳으로 보내집니다. 진료실에서 이상을 발견하지 못한 경우, 일반 진단실에서는 대개 발견됩니다. 여기서 나온 결과를 분석하기 위해 환자들은 다시 진료실로 보내집니다.//",
    [3] = "일반 진단실에는 의사가 필요합니다.",
  },
  electrolysis = {
    [1] = "전기분해실//",
    [2] = "모발 과다증 환자들이 이곳으로 보내지며, 여기서는 전기분해기 라고 불리는 특수한 기계로 털을 확 잡아뺀 뒤, 시멘트와 크게 다르지 않은 물질로 모공을 전기적으로 봉쇄합니다.//",
    [3] = "전기분해실에는 의사가 필요합니다. 그리고 잡역부가 정비해 주어야 합니다.",
  },
  slack_tongue = {
    [1] = "늘어진 혀 클리닉//",
    [2] = "진료실에서 늘어진 혀로 진단받은 환자들은 이 클리닉에 와서 치료 받게 됩니다. 의사는 고도 기술의 기계로 혀를 연장해서 잘라내어 환자를 일상의 건강한 상태로 돌려놓습니다.//",
    [3] = "늘어진 혀 클리닉에는 의사가 필요합니다. 그리고 자주 정비해 주어야 합니다.",
  },
  toilets = {
    [1] = "화장실//",
    [2] = "생리 현상을 느끼는 환자들은 화장실에 가서 일을 봐 주어야 합니다. 방문자가 아주 많을 것으로 예상된다면, 당신은 추가로 칸이나 세면대를 더 지을 수 있습니다. 어떤 경우에는 병원 안의 다른 곳에 화장실 시설을 더 짓는 것을 고려해야 할 지도 모릅니다.",
  },
  no_room = {
    [1] = "",
  },
  x_ray = {
    [1] = "X-레이//",
    [2] = "X-레이 기계는 특수 방사선을 통해서 인체의 내부 사진을 찍어서, 환자의 어디가 이상이 있는지 더 잘 이해하게 해 줍니다.//",
    [3] = "X-레이에는 의사가 필요합니다. 그리고 정비도 필요합니다.",
  },
  decontamination = {
    [1] = "오염제거 클리닉//",
    [2] = "방사선에 노출된 환자들은 신속하게 오염 제거 클리닉으로 오게 됩니다. 이 방에는 온갖 무시무시한 방사능과 진창을 씻어주는 샤워기가 설치되어 있습니다.//",
    [3] = "오염제거 클리닉에는 의사가 필요합니다. 그리고 잡역부가 정비해 주어야 합니다.",
  },
}
errors = {
  unavailable_screen_size = "요청한 화면 크기는 전체화면에서 지원되지 않습니다.",
  dialog_missing_graphics = "죄송합니다, 데모 데이터 파일은 이 대화창이 포함되어 있지 않습니다.",
  load_prefix = "게임을 불러오는 중 오류 발생: ",
  load_quick_save = "에러, 빠른 저장이 존재하지 않아 읽어올 수 없습니다. 지금 막 빠른 저장 파일을 생성했습니다!",
  save_prefix = "게임을 저장하는 중 오류 발생: ",
  map_file_missing = "이 레벨의 맵 파일(%s)을 찾을 수 없습니다!",
  minimum_screen_size = "최소 640x480 의 화면 크기를 입력해 주세요.",
  alien_dna = "주의: 외계인 환자들이 앉을 때, 문을 열거나 두드릴 때 등의 애니메이션이 없습니다. 따라서, 원본 테마 병원에서와 같이 환자들은 이런 행동을 취할 때 잠시동안 평상시의 모습으로 변했다가 되돌아오게 됩니다. 외계 DNA 환자들은 해당 레벨에서 나타나도록 설정되어 있을 경우에만 나타납니다",
  fractured_bones = "주의: 여성 골절 환자들의 애니메이션은 완전하지 못합니다",
}
menu_options_warmth_colors = {
  choice_2 = "  파랑 초록 빨강  ",
  choice_1 = "  빨강  ",
  choice_3 = "  노랑 주황 빨강  ",
}
bank_manager = {
  hospital_value = "병원 가치",
  balance = "잔고",
  current_loan = "대출금",
  interest_payment = "이자",
  insurance_owed = "보험금",
  inflation_rate = "인플레이션 비율",
  interest_rate = "이자율",
  statistics_page = {
    date = "날짜",
    details = "상세",
    money_out = "지출",
    money_in = "수입",
    balance = "잔고",
    current_balance = "현재 잔고",
  },
}
main_menu = {
  exit = "종료",
  custom_level = "단일 시나리오",
  version = "버전: ",
  new_game = "캠페인",
  load_game = "불러오기",
  options = "옵션",
  savegame_version = "저장 버전: ",
}
date_format = {
  daymonth = "%2%월 %1%일",
}
menu_display = {
  mcga_lo_res = "  MCGA 저해상도  ",
  shadows = "  그림자  ",
  high_res = "  고해상도  ",
}
pay_rise = {
  definite_quit = "당신이 무슨짓을 해도 날 붙잡을 수 없습니다. 여기와는 이제 끝이에요.",
  regular = {
    [1] = "난 너무 지쳤어요. 이 망할 직장 때려치는 것 보고싶지 않으면, 좀 쉬게 해주고, %d 만큼 급여를 올려주세요.",
    [2] = "정말 피곤합니다. 휴식도 좀 필요하고, 월급을 %d 만큼 올려서 %d 로 만들어줘요. 지금 당장이요, 노동력 착취자 양반.",
    [3] = "이봐요. 난 지금 개처럼 일하고 있어요. %d 만큼 보너스를 주면 이 병원에 남도록 하죠.",
    [4] = "난 굉장히 불행해요. 급여를 %d 인상해서 %d 로 만들어주지 않으면 난 나가겠어요.",
    [5] = "우리 부모님은 의료계로 오면 돈 잘 벌거라고 하셨는데. 그러니까 %d 만큼 급여 인상해주지 않으면 컴퓨터 게임 제작자가 돼버리고 말겠어요.",
    [6] = "이젠 넌덜머리가 나요. 월급을 웬만큼 올려주세요. %d 정도 인상해주면 적당할 것 같군요.",
  },
  poached = "저에게 %d 만큼 주겠다고 %s 에서 이직 제의가 왔어요. 최소한 이만큼 주지 않으면 떠나겠어요.",
}
menu_debug = {
  jump_to_level = "  다음 레벨로 점프  ",
  transparent_walls = "  (X) 투명한 벽  ",
  limit_camera = "  카메라 제한  ",
  disable_salary_raise = "  급여 인상 비활성화  ",
  make_debug_fax = "  디버그 팩스 만들기  ",
  make_debug_patient = "  디버그 환자 만들기  ",
  cheats = "  (F11) 치트  ",
  lua_console = "  (F12) 루아 콘솔  ",
  calls_dispatcher = "  콜 디스패쳐  ",
  dump_strings = "  문자열 덤프  ",
  dump_gamelog = "  (CTRL+D) 게임 로그 덤프  ",
  map_overlay = "  맵 오버레이  ",
  sprite_viewer = "  스프라이트 뷰어  ",
}
progress_report = {
  free_build = "자유 건설",
  too_hot = "난방 시스템을 좀 추려내세요. 지금은 너무 더워요.",
  percentage_pop = "% 인구",
  win_criteria = "승리 요건",
  very_unhappy = "사람들이 굉장히 불행합니다.",
  quite_unhappy = "사람들이 꽤 불행합니다.",
  header = "진행 상황 보고서",
  too_cold = "너무 춥습니다. 라디에이터를 좀 설치하세요.",
  more_drinks_machines = "자판기를 더 설치하세요.",
}
menu_options = {
  sound = "  효과음   ",
  announcements = "  공지   ",
  music = "  음악   ",
  sound_vol = "  효과음 볼륨   ",
  announcements_vol = "  공지 볼륨  ",
  music_vol = "  음악 볼륨  ",
  jukebox = "  (J) 주크박스  ",
  lock_windows = "  창 잠그기  ",
  edge_scrolling = "  가장자리 스크롤  ",
  adviser_disabled = "  (SHIFT+A) 조언자  ",
  twentyfour_hour_clock = "  24 시간 시계  ",
  warmth_colors = "  온도 표시 색  ",
  game_speed = "  게임 속도  ",
  autosave = "  자동 저장  ",
  wage_increase = "  급여 인상  ",
}
menu_options_game_speed = {
  pause = "  (P) 일시 정지  ",
  slowest = "  (1) 가장 느림  ",
  slower = "  (2) 느림  ",
  normal = "  (3) 보통  ",
  max_speed = "  (4) 최고 속도  ",
  and_then_some_more = "  (5) 에서 더 빠르게  ",
}
rooms_short = {
  gps_office = "진료실",
  general_diag = "일반 진단실",
  ultrascan = "울트라스캔",
  research_room = "연구실",
  fracture_clinic = "골절 클리닉",
  destroyed = "파괴됨",
  staffroom = "직원 휴게실",
  jelly_vat = "젤리 클리닉",
  scanner = "스캐너",
  decontamination = "오염제거 클리닉",
  pharmacy = "약국",
  cardiogram = "심전도실",
  reception = "접수처",
  training_room = "교육실",
  corridor_objects = "복도 기물",
  operating_theatre = "수술실",
  dna_fixer = "DNA 정정기",
  ward = "병동",
  psychiatric = "정신과",
  hair_restoration = "모발 재생 클리닉",
  inflation = "팽창 클리닉",
  tongue_clinic = "늘어진 혀 클리닉",
  toilets = "화장실",
  electrolysis = "전기분해실",
  x_ray = "X-레이",
  blood_machine = "혈액 분석기",
}
lua_console = {
  execute_code = "실행",
  close = "닫기",
}
staff_descriptions = {
  good = {
    [1] = "상당히 빠르고 성실함. ",
    [2] = "굉장히 세심하고 사려깊음. ",
    [3] = "다양한 능력을 보유. ",
    [4] = "굉장히 친절하고 잘 웃음. ",
    [5] = "체력이 뛰어남. 오래 지속할 수 있음. ",
    [6] = "놀랄만큼 공손하고 온화함. ",
    [7] = "재능이 특출남. ",
    [8] = "주어진 일에 최선을 다함. ",
    [9] = "포기하지 않는 완벽주의자. ",
    [10] = "미소로 사람들을 돕는데 전념함. ",
    [11] = "매력적이고, 공손하며, 도움이 됨. ",
    [12] = "의욕적이고 헌신적임. ",
    [13] = "사람이 좋고 아주 열심히 일함. ",
    [14] = "성실하고 친근함. ",
    [15] = "신중하고 응급 상황에 믿을만함. ",
  },
  misc = {
    [1] = "골프를 침. ",
    [2] = "스쿠버 다이버. ",
    [3] = "얼음 조각상 제작. ",
    [4] = "와인 애호가. ",
    [5] = "경주용 자동차 운전. ",
    [6] = "번지 점프를 함. ",
    [7] = "맥주잔 받침 수집가. ",
    [8] = "무대 아래로 뛰어내리는 것을 즐김. ",
    [9] = "방귀대장. ",
    [10] = "강을 넓히는 것을 즐김. ",
    [11] = "위스키를 증류. ",
    [12] = "DIY 에 능숙함. ",
    [13] = "프랑스 예술 영화를 즐김. ",
    [14] = "테마 공원을 플레이 함. ",
    [15] = "대형 트럭 운전 면허 소지자. ",
    [16] = "오토바이 경주에 나감. ",
    [17] = "클래식 바이올린과 첼로를 연주. ",
    [18] = "철도 약탈에 능함. ",
    [19] = "개 애호가. ",
    [20] = "라디오 청취자. ",
    [21] = "목욕을 자주 즐김. ",
    [22] = "짚 공예 강사. ",
    [23] = "채소 속을 파내어 비누통으로 사용함. ",
    [24] = "파트타임 특수 경찰. ",
    [25] = "전 퀴즈 쇼 진행자. ",
    [26] = "WW2 유산탄 파편 수집가. ",
    [27] = "가구 재배치를 즐김. ",
    [28] = "광란의 댄스 음악을 감상. ",
    [29] = "데오드란트 스프레이로 곤충들의 화를 돋굼. ",
    [30] = "재미없는 개그맨들에게 야유함. ",
    [31] = "의회를 기웃거리며 도청함. ",
    [32] = "은밀한 정원사. ",
    [33] = "짝퉁 시계들을 거래. ",
    [34] = "락앤롤 밴드에서 노래함. ",
    [35] = "오후 시간대 텔레비전에 열광함. ",
    [36] = "송어 간지럼의 대가. ",
    [37] = "박물관에서 여행객들을 꼬심. ",
  },
  bad = {
    [1] = "느리고 귀찮음. ",
    [2] = "게으르고 동기 부여가 안됨. ",
    [3] = "훈련이 덜되고 무능함. ",
    [4] = "무례하고 불쾌함. 사람들을 적대시함. ",
    [5] = "최악의 체력 - 태도가 불량함. ",
    [6] = "귀머거리. 양배추 냄새 같은 것이 남. ",
    [7] = "일하는 데 거치적거림. 없는게 나을 수 있음. ",
    [8] = "성질 급하고 쉽게 산만해짐. ",
    [9] = "스트레스가 심하고 실수가 잦음. ",
    [10] = "심성이 뒤틀려있고 화를 잘 냄 - 미움으로 가득 차 있음. ",
    [11] = "주의력이 없고 사고를 잘 냄. ",
    [12] = "일에 신경을 쓰지 않음. 엄청나게 게으름. ",
    [13] = "바보같이 위험을 감수하려 함. ",
    [14] = "교활하고 간사하며, 질서를 파괴함. ",
    [15] = "거만하고 잘난체 함. ",
  },
}
room_classes = {
  diagnosis = "진단",
  clinics = "클리닉",
  facilities = "부대시설",
  treatment = "치료",
}
install = {
  ok = "확인",
  cancel = "취소",
  exit = "종료",
  th_directory = "CorsixTH 를 실행하기 위해서는 테마병원 원본 (또는 데모) 게임 데이터가 필요합니다. 아래의 선택 버튼을 눌러서 테마 병원 설치 디렉토리를 지정하세요.",
  title = "--------------------------------- CorsixTH 설치 ---------------------------------",
}
place_objects_window = {
  drag_blueprint = "마음에 드는 크기가 될 때까지 청사진을 드래그 하세요",
  place_door = "문을 배치하세요",
  place_windows = "원하는 만큼 창문을 배치하고 확인 버튼을 누르세요",
  confirm_or_buy_objects = "방의 모습을 확정짓거나, 기물들을 구매/이동시킬 수 있습니다",
  place_objects_in_corridor = "기물들을 복도에 배치하세요",
  pick_up_object = "물건을 클릭해서 집어 올리거나, 다른 기능을 선택하세요",
  place_objects = "마음에 들 때까지 기물들을 배치/이동시키고 확인을 누르세요",
}
load_game_window = {
  caption = "게임 불러오기 (%1%)",
}
staff_title = {
  junior = "수련의",
  psychiatrist = "정신과 의사",
  consultant = "전문의",
  surgeon = "외과 의사",
  doctor = "전공의",
  researcher = "연구원",
  nurse = "간호사",
  receptionist = "접수원",
  general = "일반",
}
graphs = {
  deaths = "사망",
  money_in = "수입",
  money_out = "지출",
  visitors = "방문자",
  wages = "급여",
  balance = "잔액",
  time_spans = {
    [1] = "1 년",
    [2] = "12 년",
    [3] = "48 년",
  },
  cures = "치료",
  reputation = "평판",
}
adviser = {
  tutorial = {
    hire_receptionist = "환자들을 접수하려면 접수원도 고용해야 할 겁니다.",
    build_pharmacy = "축하합니다! 이제 병원이 제대로 돌아가게 하려면 약국을 짓고 간호사를 고용하면 됩니다.",
    hire_doctor = "아픈 사람들을 진단하고 치료하려면 의사를 고용해야 합니다.",
    place_receptionist = "접수원을 데려다가 아무 데나 놓아보세요. 똑똑하게도, 알아서 접수대 쪽으로 이동할 것입니다.",
    place_windows = "문을 설치한 것과 동일한 방식으로 창문들을 배치하세요. 꼭 창문이 있어야 하는 것은 아니지만, 밖에 볼 것이 있으면 직원들이 더 행복해 할 것입니다.",
    confirm_room = "점멸하는 아이콘을 왼쪽 클릭해서 방을 가동하거나 X 버튼을 클릭해서 뒤로 돌아가세요.",
    rotate_and_place_reception = "오른쪽 클릭으로 책상을 돌리거나 왼쪽 버튼으로 책상을 병원 내에 배치하세요.",
    build_reception = "안녕하세요. 우선, 당시늬 병원에는 접수대가 필요합니다. 복도 기물 메뉴에서 접수대를 선택하세요.",
    doctor_in_invalid_position = "이봐요! 여기에는 의사를 배치할 수 없어요.",
    start_tutorial = "임무 브리핑을 읽고 나서 튜토리얼을 시작하기 위해 마우스 왼쪽 버튼을 클릭하세요.",
    receptionist_invalid_position = "접수원을 여기에 배치할 수 없습니다.",
    room_too_small_and_invalid = "청사진이 너무 작거나 잘못된 곳에 배치되었습니다. 제대로 해보세요.",
    window_in_invalid_position = "창문이 잘못된 곳에 배치되었습니다. 벽 위의 다른 곳에 설치해 보세요.",
    choose_doctor = "고용할 의사를 고르기 전에 능력이 얼마나 되는지 잘 살펴보세요.",
    information_window = "정보 창은 당신이 방금 지은 진료실에 대한 모든 것을 알려줍니다.",
    build_gps_office = "환자들의 질병을 진단하기 시작하려면 먼저 진료실을 지어야 합니다.",
    select_doctors = "점멸하는 아이콘을 왼쪽 클릭하여 고용할 수 있는 의사들의 목록을 보세요.",
    select_diagnosis_rooms = "점멸하는 아이콘을 왼쪽 클릭하여 진단 시설들의 목록을 보세요.",
    select_receptionists = "점멸하는 아이콘을 클릭하여 고용할 수 있는 접수원들의 목록을 보세요. 아이콘에 적힌 숫자는 몇 명의 접수원 중에서 고를 수 있는지를 나타냅니다.",
    order_one_reception = "점멸하는 아이템을 왼쪽 클릭하여 접수대를 하나 주문하세요.",
    choose_receptionist = "어느 접수원이 괜찮은 능력을 가졌으며 적절한 급료를 원하는지 정한 후에 점멸하는 아이콘을 클릭하여 고용하세요.",
    prev_receptionist = "점멸하는 아이콘을 왼쪽 클릭하여 고용 가능한 이전 접수원을 확인하세요.",
    accept_purchase = "점멸하는 아이콘을 왼쪽 클릭하여 구매하세요.",
    place_door = "청사진상의 벽 주위로 마우스를 움직여서 원하는 곳에 출입문을 배치하세요.",
    click_and_drag_to_build = "진료실을 짓기 위해서는 우선 얼마나 크게 지을 것인지를 결정해야 합니다. 왼쪽 마우스 버튼을 클릭한 채로 드래그 하여 방의 크기를 결정하세요.",
    room_in_invalid_position = "이런! 이 청사진은 부적절합니다 - 붉은 영역은 병원의 벽 밖으로 나갔거나 다른 방과 겹치는 부분을 나타냅니다.",
    place_objects = "오른쪽 클릭으로 기물을 회전시키고, 왼쪽 클릭으로 기물을 배치하세요.",
    room_too_small = "이 방의 청사진은 너무 작기 때문에 붉은 색으로 표시됩니다. 드래그 하여 방을 더 크게 만드세요.",
    click_gps_office = "점멸하는 아이템을 왼쪽 클릭해서 진료실을 선택하세요.",
    reception_invalid_position = "접수대가 회색으로 표시되는 이유는 배치할 수 없는 위치에 있기 때문입니다. 다른 곳으로 옮기거나 회전시켜 보세요.",
    next_receptionist = "이 사람이 목록의 첫 번째 접수원입니다. 점멸하는 아이콘을 왼쪽 클릭해서 다음 사람을 확인하세요.",
    room_big_enough = "이제 청사진이 충분히 큽니다. 마우스 버튼을 놓으면 방이 배치됩니다. 원한다면 이 상태에서 방의 위치를 옮기거나 크기를 변경할 수도 있습니다.",
    object_in_invalid_position = "이 기물은 잘못된 위치에 있습니다. 다른 곳으로 옮기거나 회전시켜서 기물이 들어맞도록 조정하세요.",
    door_in_invalid_position = "아차! 잘못된 위치에 출입문을 설치하려고 했군요. 청사진 벽의 다른 곳에 시도해 보세요.",
    place_doctor = "의사를 병원 내의 아무 곳에나 배치하세요. 진료받을 환자가 생기면 의사가 알아서 진료실로 이동할 것입니다.",
  },
  epidemic = {
    hurry_up = "전염병이 지금 당장 해결되지 않으면, 당신은 곤경에 처하게 될 겁니다. 빨리 빨리 움직이세요!",
    serious_warning = "그 전염성 질병은 점점 심각해 지고 있습니다. 빠른 시간 내에 뭔가 조치를 취해야 합니다!",
    multiple_epidemies = "두 가지 이상의 전염병이 동시에 돌고 있는 것 같네요. 어마어마한 재앙이 될지 모르니 신속하게 움직이세요.",
  },
  staff_advice = {
    need_handyman_machines = "병원 내에 있는 기계 장치들을 정비하려면 잡역부를 고용해야 합니다.",
    need_doctors = "의사가 더 많이 필요합니다. 당신의 가장 뛰어난 의사들을 대기열이 긴 방에 배치하도록 해 보세요.",
    need_handyman_plants = "화초에 물을 주려면 잡역부를 고용해야 합니다.",
    need_handyman_litter = "사람들이 병원에 쓰레기를 버리기 시작했습니다. 잡역부를 고용해서 바닥을 청소하도록 하세요.",
    need_nurses = "간호사가 더 필요합니다. 병동과 약국에는 간호사가 필요합니다.",
    too_many_doctors = "의사가 너무 많습니다. 몇몇에게는 아예 할 일이 배정되지 않았습니다.",
    too_many_nurses = "간호가를 너무 많이 고용한 것 같습니다.",
  },
  earthquake = {
    damage = "지진이 %d 개의 기계 장치와 %d 명의 사람들에게 피해를 입혔습니다.",
    alert = "지진 경보. 지진이 일어나면 기계 장치들이 피해를 입게 됩니다. 제대로 정비되지 않은 기계들은 부서지는 수도 있습니다.",
    ended = "휴. 거대한 지진이었네요. 리히터 척도로 진도 %d 의 지진이었습니다.",
  },
  multiplayer = {
    everyone_failed = "마지막 목표를 아무도 달성하지 못했습니다. 따라서 모두가 계속해서 플레이 합니다!",
    players_failed = "다음 플레이어가 마지막 목표를 달성하지 못했습니다:",
    poaching = {
      in_progress = "이 사람이 당신과 함께 일하기 원하는지 알아보겠습니다.",
      not_interested = "허 참! 그들은 당신과 일하는 데에 별 관심이 없군요 - 지금 있는 곳이 만족스럽답니다.",
      already_poached_by_someone = "이런! 다른 사람이 이미 이 사람에게 접촉중입니다.",
    },
  },
  surgery_requirements = {
    need_surgeons_ward_op = "수술을 위해서 두 명의 외과 의사를 고용하고, 병동과 수술질을 지어야 합니다.",
    need_surgeon_ward = "외과 의사를 한 명 더 고용하고 병동을 지어야 수술을 시작할 수 있습니다.",
  },
  vomit_wave = {
    started = "병원에 구토 바이러스가 퍼진 것 같네요. 애초에 병원을 깨끗하게 관리했다면 벌어지지 않았을 일입니다. 잡역부를 더 고용해야 할 것 같습니다.",
    ended = "휴! 구토를 유발하던 바이러스가 거의 잡힌 것 같네요. 앞으로 병원을 깨끗하게 유지하세요.",
  },
  cheats = {
    th_cheat = "축하합니다, 치트를 해제했습니다!",
    roujin_on_cheat = "로우진의 도전이 활성화 되었습니다! 행운을 빌어요...",
    roujin_off_cheat = "로우진의 도전이 비활성화 되었습니다.",
  },
  level_progress = {
    halfway_lost = "레벨 패배 조건에 절반정도 도달했습니다.",
    dont_kill_more_patients = "더 이상 환자들을 죽게 하면 안됩니다!",
    another_patient_killed = "이런! 또다른 환자가 사망했군요. 지금까지 총 %d 명의 환자가 사망했습니다.",
    halfway_won = "이 레벨을 승리하는 데 절반정도 왔습니다.",
    close_to_win_increase_value = "승리가 눈앞에 있습니다. 병원 가치를 %d 만큼 끌어올리세요.",
    financial_criteria_met = "이 레벨의 재정 관련 목표는 모두 달성했습니다. 은행 잔고를 %d 이상으로 유지하고 병원이 효율적으로 돌아가도록 신경쓰세요.",
    nearly_won = "이 레벨을 거의 승리했습니다.",
    hospital_value_enough = "병원 가치를 %d 이상으로 유지하면서 다른 문제들을 해결하면 승리할 수 있습니다.",
    another_patient_cured = "잘 했어요 - 또 한 명의 환자를 치료했군요. 지금까지 총 %d 명을 치료했습니다.",
    three_quarters_lost = "이 레벨을 패배하는데 3/4 정도 왔습니다.",
    reputation_good_enough = "좋아요, 당신의 평판은 레벨을 클리어하기에 충분할 정도로 올라갔습니다. %d 이상으로 유지하면서 다른 문제들을 해결하면 승리할 수 있습니다.",
    cured_enough_patients = "충분한 수의 환자들을 치료했지만, 병원을 더 잘 운영해야 승리할 수 있습니다.",
    nearly_lost = "이 레벨을 거의 실패했습니다.",
    improve_reputation = "당신은 평판을 %d 만큼 더 올려야 이 레벨을 승리할 수 있습니다.",
    three_quarters_won = "이 레벨을 승리하는 데 3/4 정도 왔습니다.",
  },
  staff_place_advice = {
    receptionists_only_at_desk = "접수원들은 접수대에서만 일할 수 있습니다.",
    only_psychiatrists = "의사들은 정신과 자격이 있는 경우에만 정신과실에서 일할 수 있습니다.",
    only_surgeons = "의사들은 외과 자격이 있는 경우에만 수술실에서 일할 수 있습니다.",
    only_nurses_in_room = "간호사들만이 %s에서 일할 수 있습니다.",
    only_doctors_in_room = "의사들만이 %s에서 일할 수 있습니다.",
    only_researchers = "의사들은 연구 자격이 있는 경우에만 연구소에서 일할 수 있습니다.",
    nurses_cannot_work_in_room = "간호사는 %s에서 일할 수 없습니다.",
    doctors_cannot_work_in_room = "의사는 %s에서 일할 수 없습니다.",
  },
  room_forbidden_non_reachable_parts = "방을 이 곳에 배치하면 당신의 병원의 사람들이 갈 수 없는 지역이 생기게 됩니다.",
  research = {
    machine_improved = "%s 기계가 연구소에서 개선되었습니다.",
    autopsy_discovered_rep_loss = "당신의 자동 부검 기계가 발명되었습니다. 대중에게서 부정적인 반응이 나올 것은 각오하세요.",
    drug_fully_researched = "%s 약을 100% 연구했습니다.",
    new_machine_researched = "새로운 %s 기계가 성공적으로 연구되었습니다.",
    drug_improved = "%s 약이 연구소에서 개선되었습니다.",
    drug_improved_1 = "%s 약이 연구소에서 개선되었습니다.",
    new_available = "새로운 %s 을(를) 사용할 수 있습니다.",
    new_drug_researched = "%s 질병의 치료약이 연구되었습니다.",
  },
  boiler_issue = {
    minimum_heat = "아, 거기 계셨군요. 지하의 보일러가 고장입니다. 병원 안의 사람들이 한동안 춥겠군요.",
    maximum_heat = "지하의 보일러가 발광하고 있습니다. 라디에이터 출력이 최대로 고정되어 버렸습니다. 사람들이 녹아내리기 시작할 겁니다! 음료 자판기를 더 설치하는 것이 도움이 될 지도 모릅니다.",
    resolved = "좋은 소식입니다. 보일러와 라디에이터가 다시 정상적으로 작동하시 시작했습니다. 환자들과 직원들을 위한 실내 온도가 적절히 유지될 것입니다.",
  },
  competitors = {
    staff_poached = "당신의 직원 중 한 명이 다른 병원으로부터 스카웃 당했습니다.",
    hospital_opened = "%s 지역에 경쟁 병원이 개원했습니다.",
    land_purchased = "%s 이(가) 약간의 토지를 매입했습니다.",
  },
  room_requirements = {
    research_room_need_researcher = "연구실을 사용하기 위해서는 연구 능력을 갖춘 의사를 고용해야 합니다.",
    op_need_another_surgeon = "수술실을 사용하기 위해서는 외과 의사가 한 명 더 필요합니다.",
    op_need_ward = "환자들이 수술을 받으려면 먼저 병동을 지어서 수술전 처방을 받도록 해야 합니다.",
    reception_need_receptionist = "환자들을 보려면 먼저 접수원을 고용해야 합니다.",
    psychiatry_need_psychiatrist = "정신과실을 지었으니 이제 정신과 의사를 고용해야 합니다.",
    pharmacy_need_nurse = "그 약국을 돌아가게 하려면 간호사를 고용해야 합니다.",
    ward_need_nurse = "이 병동에서 일할 간호사를 고용해야 할 것입니다.",
    op_need_two_surgeons = "수술실에서 수술을 진행하려면 두 명의 외과 의사를 고용하세요.",
    training_room_need_consultant = "그 교육실에서 의사들을 훈련시키려면 전문의를 고용해서 강의하게 해야 합니다.",
    gps_office_need_doctor = "의사를 고용해서 진료실에서 일하도록 하세요.",
  },
  goals = {
    win = {
      money = "%d 만큼 더 벌어야 이 레벨의 재정 조건을 만족할 수 있습니다.",
      cure = "%d 명의 환자를 더 치료하면 이 레벨을 승리하는데 필요한 수를 채우게 됩니다.",
      reputation = "당신의 평판을 %d 까지 올려서 승리 조건을 만족하세요.",
      value = "당신은 병원의 가치를 %d 만큼 올려야 합니다.",
    },
    lose = {
      kill = "%d 명의 환자를 더 죽이게 되면 이 레벨을 실패하게 됩니다!",
    },
  },
  warnings = {
    bankruptcy_imminent = "이봐요! 당신 지금 파산으로 치닫고 있습니다. 조심하세요!",
    build_staffroom = "지금 당장 직원 휴게실을 지어주세요. 당신의 직원들은 너무 과하게 일하고 있고 부서지기 직전입니다. 상식적으로 생각을 좀 해보세요!",
    build_toilet_now = "지금 화장실을 지으세요. 사람들은 더 이상 참지 못하고 있습니다. 웃지 마요, 지금 심각합니다.",
    build_toilets = "지금 당장 화장실을 짓지 않으면 굉장히 불쾌한 것을 보게될지도 모릅니다. 그리고 당신의 병원에 어떤 냄새가 날지 한 번 상상해 보세요.",
    cannot_afford = "그 사람을 고용할만큼의 충분한 돈이 없습니다!",
    cannot_afford_2 = "그것을 구매할만큼 충분한 돈이 은행에 없습니다!",
    cash_low_consider_loan = "당신 현금 사정이 매우 좋지 않네요. 대출은 고려해 보셨습니까?",
    change_priorities_to_plants = "잡역부들의 업무 우선순위를 바꿔서 화초에 물을 잘 주도록 해야 합니다.",
    charges_too_high = "당신은 너무 많이 청구하고 있습니다. 단기적으로 보면 이윤이 많이 남겠지만, 결과적으로 환자들을 많이 잃게 될 것입니다.",
    charges_too_low = "당신은 환자들에게 너무 적게 청구하고 있습니다. 물론 더 많은 사람들이 병원에 방문하겠지만, 각 환자로부터 얻는 이득은 미미할 것입니다.",
    deal_with_epidemic_now = "그 전염병이 지금 당장 처리되지 않으면, 못볼 꼴을 보게 될 겁니다. 당장 움직여요!",
    desperate_need_for_watering = "당신의 화초들을 돌볼 잡역부가 절실히 필요합니다.",
    doctor_crazy_overwork = "이런! 당신의 의사들중 한 명이 과로로 인해 정신이 나갔습니다. 당장 쉬게 해주면 회복될 수 있을 것입니다.",
    doctors_tired = "당신의 의사들은 많이 지쳤습니다. 가끔씩 쉬게끔 해 주세요.",
    doctors_tired2 = "의사들이 말도 안되게 지쳐있습니다. 그들은 즉시 휴식을 취해야 합니다.",
    epidemic_getting_serious = "그 전염성 질병이 점점 심각해지고 있습니다. 당장 뭔가 해줘야 합니다!",
    falling_1 = "이봐요! 그거 장난이 아니에요. 마우스로 어디를 클릭하는지 잘 보세요. 누군가 다칠 수도 있어요!",
    falling_2 = "그만 장난치세요, 그러면 좋아요?",
    falling_3 = "아야, 다쳤잖아요, 누가 의사좀 불러줘!",
    falling_4 = "여긴 병원이지 놀이 공원이 아니에요!",
    falling_5 = "여긴 사람들을 넘어뜨리는 곳이 아니에요. 아픈 사람들이라고요, 알잖아요!",
    falling_6 = "여긴 볼링장이 아니에요. 아픈 사람들을 그렇게 다루면 안돼요!",
    financial_trouble = "당신은 지금 심각한 재정난을 겪고 있습니다. 재정 상황을 당장 확인하세요! %d 만큼 더 손해를 보면 이 레벨에 실패하게 될겁니다!",
    finanical_trouble2 = "돈이 더 들어오도록 하지 않으면 당신은 완전히 쓸모없어질 것입니다. %d 만큼을 더 잃으면 이 레벨을 실패하게 됩니다.",
    financial_trouble3 = "당신의 은행 잔고가 불안해 보이는군요. 돈을 더 벌도록 하세요. 실패하는데 %d 밖에 남지 않았습니다.",
    handymen_tired = "잡역부들이 많이 지쳤습니다. 좀 쉬게 해주세요.",
    handymen_tired2 = "잡역부들이 완전히 기진맥진 했습니다. 지금 당장 어떻게든 좀 쉬게 해주세요.",
    hospital_is_rubbish = "사람들이 공공연하게 당신의 병원이 지저분하다고 말하고 다닙니다. 이대로라면 사람들이 점점 다른 병원을 찾게 될 것입니다.",
    litter_catastrophy = "쓰레기 상황이 아주 지옥같습니다. 지금 잡역부 팀을 꾸려서 쓰레기들을 정리하도록 하세요!",
    litter_everywhere = "온통 쓰레기 천지입니다. 잡역부에게 일을 좀 시키세요.",
    machine_severely_damaged = "%s 기계가 고칠 수 없는 상황에 거의 다다랐습니다.",
    machines_falling_apart = "당신의 기계들이 고장나고 있습니다. 지금 당장 잡역부들이 고치도록 하세요!",
    machinery_slightly_damaged = "병원의 기계들이 약간 손상되었습니다. 어느 시점에서 수리해 주는 것을 잊지 마세요.",
    machinery_deteriorating = "당신의 기계 장치들이 지나친 사용으로 악화되고 있습니다. 주의 깊게 지켜보세요.",
    machinery_damaged = "당신의 기계들을 빠른 시일 내에 수리하세요. 고장나기 시작하는데 그리 오래 걸리지 않을겁니다.",
    machinery_damaged2 = "잡역부를 고용해서 어서 기계들을 수리해주어야 합니다.",
    machinery_very_damaged = "긴급상황! 지금 당장 잡역부를 불러서 기계들을 수리하세요! 폭발하기 직전입니다!",
    many_epidemics = "둘 이상의 전염병이 동시에 돌고 있는 것으로 보이는군요. 이거 아주 엄청난 재난이 될지도 모르니 어서 조치를 취하세요.",
    many_killed = "지금까지 %d 명의 환자를 죽였군요. 알고 있겠지만 더 잘 해야 합니다.",
    money_low = "돈이 거의 바닥나고 있습니다!",
    money_very_low_take_loan = "은행 잔고가 절망적으로 낮습니다. 필요하다면 대출을 할 수도 있습니다.",
    more_benches = "벤치를 더 배치하는 것을 고려해 보세요. 아픈 사람들은 서서 기다려야 하는 것을 원망합니다.",
    more_toilets = "화장실이 더 필요합니다. 사람들에게 변비가 생기고 있어요.",
    need_staffroom = "직원 휴게실을 지어서 직원들이 쉴 수 있게 해 주세요.",
    need_toilets = "환자들이 화장실을 필요로 합니다. 쉽게 접근할 수 있는 곳에 배치해 주세요.",
    no_desk = "어느 시점에는 반드시 접수대를 배치하고 접수원을 고용해야 합니다!",
    no_desk_1 = "환자들이 병원에 방문하도록 하려면, 접수원을 고용하고 접수원이 일할 접수대를 마련해 주어야 합니다!",
    no_desk_2 = "아주 좋~아요, 아마 세계 기록이겠군요: 1년이 다 되어가는데 환자가 한 명도 없다니! 이 병원의 관리자로 계속 남고 싶다면, 접수원을 고용하고 접수대를 설치해주어야 할 겁니다!",
    no_desk_3 = "아주 끝내주는군요, 1년이 다 되었는데 접수원조차 없다니! 환자가 방문하길 바라기는 하는건지 모르겠군요. 어서 해결하세요!",
    no_desk_4 = "접수원은 방문하는 환자들을 안내하기 위해서 일할 장소가 필요합니다.",
    no_desk_5 = "흠, 이제 시간이 되었군요. 이제 곧 환자들이 방문하는 것을 볼 수 있을 것입니다!",
    no_desk_6 = "접수원을 고용했으니, 이제 접수원이 일할 접수대를 설치해주는 것이 어때요?",
    no_desk_7 = "접수대를 설치했으니 이제 접수원을 고용하는 것이 어때요? 아시겠지만 이게 제대로 해결되지 않으면 환자들이 방문하지 않을겁니다!",
    no_patients_last_month = "지난 달에 새로운 환자가 한 명도 오지 않았습니다. 충격이네요!",
    nobody_cured_last_month = "지난달에는 정말 아무도 치료하지 못했군요.",
    nurse_needs_desk_1 = "각 간호사는 일할 책상이 필요합니다.",
    nurse_needs_desk_2 = "당신의 간호사는 당신이 허락한 휴식에 즐거워하고 있습니다. 병동에 두 명 이상의 간호사가 일하도록 하려면 한 사람당 책상 하나씩을 배치해 주어야 합니다.",
    nurses_tired = "간호사들이 지쳤습니다. 좀 쉬게 해주세요.",
    nurses_tired2 = "간호사들이 매우 지쳤습니다. 지금 바로 휴식을 취하게 해주세요.",
    patient_leaving = "환자가 떠나고 있군요. 이유가 뭐냐고요? 당신 병원의 형편없는 운영과 불친절한 직원들, 부족한 설비 때문이죠.",
    patient_stuck = "누군가가 길을 잃었네요. 병원 설계를 좀 더 잘 해보세요.",
    patients_annoyed = "사람들은 당신이 병원을 운영하는 방식에 굉장히 불만이 많습니다. 그 사람들을 뭐라고 할 수가 없네요. 제대로 관리하거나 아니면 그에 따르는 결과를 직면하세요!",
    patients_getting_hot = "환자들이 굉장히 더워하고 있습니다. 온도를 낮추거나 라디에이터가 너무 많다면 조금씩 제거해주세요.",
    patients_leaving = "환자들이 떠나고 있습니다. 화초, 벤치, 자판기 등을 더 설치해서 병원을 방문하는 사람들에게 좋은 인상을 주세요.",
    patients_really_thirsty = "환자들이 매우 목마릅니다. 음료 자판기를 더 설치하거나, 긴 대기열 주변으로 위치를 옮겨보세요.",
    patients_thirsty = "사람들이 목말라 하고 있습니다. 자판기를 더 설치해면 좋을 것 같네요.",
    patients_thirsty2 = "사람들이 목마르다고 불평하고 있습니다. 자판기를 더 설치하거나 이미 있는 자판기들을 사람들 근처로 옮겨 보세요.",
    patients_too_hot = "환자들이 너무 더워합니다. 라디에이터들을 좀 제거하거나, 온도를 낮추거나, 아니면 음료 자판기들을 더 많이 배치해 주세요.",
    patients_unhappy = "환자들이 당신의 병원을 싫어합니다. 병원 환경을 개선하기 위해서 뭔가 해야 합니다.",
    patients_very_cold = "환자들이 매우 추워합니다. 난방을 올리거나 병원에 라디에이터를 더 많이 배치하세요.",
    patients_very_thirsty = "환자들이 심각한 갈증을 느끼고 있습니다. 어서 음료 자판기를 설치하지 않으면, 사람들이 콜라를 마시러 집으로 돌아가버릴지도 모릅니다.",
    pay_back_loan = "돈이 많이 쌓여있습니다. 대출금을 상환하는 것은 어떤가요?",
    people_did_it_on_the_floor = "몇몇 환자들이 생리현상을 참지 못했군요. 치우려면 누군가가 고생하겠네요.",
    people_freezing = "놀랍군요. 이런 중앙 난방의 시대에 얼어죽을만큼 추워하는 환자들이 있다니요. 라디에이터들을 더 설치하고 온도를 높여서 환자들을 따뜻하게 해주세요.",
    people_have_to_stand = "앓고 있는 사람들이 서서 기다려야 합니다. 지금 당장 앉을 자리를 더 만들어 주세요.",
    place_plants_to_keep_people = "사람들이 떠나고 있습니다. 화초들을 배치하면 그들이 머물도록 설득하는 데 도움이 될 수 있습니다.",
    place_plants2 = "사람들이 나가고 있습니다. 화초를 더 많이 배치하면 그들을 여기 좀 더 오래 머물게 할 수 있을지도 모릅니다.",
    place_plants3 = "환자들의 불행해 하고 있습니다. 화초를 좀 더 배치해서 기분을 풀어주세요.",
    place_plants4 = "더 많은 화초로 이 곳 주변의 환자들을 격려해 주세요.",
    plants_dying = "화초들이 죽어갑니다. 물을 절실히 필요로 하고 있습니다. 잡역부들을 시켜서 물을 주게 하세요. 환자들은 죽은 화초를 보고 싫어 합니다.",
    plants_thirsty = "화초를 좀 돌봐야 하겠습니다. 화초들이 목말라 하고 있어요.",
    queue_too_long_at_reception = "접수대에서 안내를 기다리는 환자들이 너무 많습니다. 접수대를 추가로 설치하고 접수원을 새로 고용하세요.",
    queue_too_long_send_doctor = "당신의 %s 대기열이 너무 깁니다. 방에 의사가 있는지 반드시 확인하세요.",
    queues_too_long = "대기열이 너무 깁니다.",
    reception_bottleneck = "접수대가 병목이 되고 있습니다. 접수원을 더 고용하세요.",
    receptionists_tired = "접수원들이 심하게 지쳤습니다. 지금 바로 쉬게 해주세요.",
    receptionists_tired2 = "접수원들이 많이 피로한 상태입니다. 바로 휴식을 좀 취하게 해주세요.",
    reduce_staff_rest_threshold = "직원들이 더 자주 휴식을 취할 수 있도록, 정책 화면에서 직원 휴식 문턱을 낮춰보세요. 그냥 아이디어 입니다.",
    research_screen_open_1 = "연구 화면을 사용하려면 먼저 연구실을 지어야 합니다.",
    research_screen_open_2 = "이 레벨에서는 연구 기능을 사용할 수 없습니다.",
    researcher_needs_desk_1 = "연구원에게는 일할 책상이 필요합니다.",
    researcher_needs_desk_2 = "당신의 연구원은 당신이 쉴 수 있도록 해준 것에 감사하고 있습니다. 더 많은 연구원을 배치하고 싶었던 것이라면, 한 사람당 책상 하나씩을 배치해 주어야 합니다.",
    researcher_needs_desk_3 = "각각의 연구원은 자신이 일할 책상이 있어야 합니다.",
    some_litter = "잡역부는 쓰레기 문제가 심각해지기 전에 그것들을 없앨 수 있습니다.",
    staff_overworked = "당신의 직원은 심각하게 과로한 상태입니다. 그들은 점점 비효율적이 되어 가고 끔찍한 실수들을 저지르기 시작할 겁니다.",
    staff_tired = "당신의 직원들이 말도안되게 지쳤습니다. 직원 휴게실에서 쉬게 해주지 않으면 그들이 무리해서 완전히 녹초가 되어버릴 겁니다.",
    staff_too_hot = "당신의 직원들이 과열되고 있습니다. 난방을 낮추거나 방에 배치한 라디에이터들을 제거하세요.",
    staff_unhappy = "직원들이 불행합니다. 보너스를 지급해 주거나, 아니면 직원 휴게실을 지어 주는 것이 더 낫겠습니다. 또한 병원 정책 화면에서 직원 휴식 정책을 조정할 수도 있습니다.",
    staff_unhappy2 = "당신의 직원들은 이래저래 불만입니다. 그리고 곧 돈을 더 달라고 요구하게 될 겁니다.",
    staff_very_cold = "직원들이 춥다고 불평하고 있습니다. 난방을 올리거나 라디에이터를 더 설치하세요.",
    too_many_plants = "화초가 지나치게 많습니다. 이거 뭐 완전히 정글이네요.",
    too_much_litter = "바닥의 쓰레기가 문제가 되고 있습니다. 잡역부를 더 고용하는 것이 답이겠지요.",
  },
  placement_info = {
    door_can_place = "원한다면 문을 여기에 설치할 수 있습니다.",
    door_cannot_place = "죄송하시만 문을 여기에 설치할 수 없습니다.",
    window_can_place = "창문을 여기 설치할 수 있습니다.",
    window_cannot_place = "아. 여기에는 창문을 설치할 수 없습니다.",
    object_can_place = "이 물건을 여기 배치할 수 있습니다.",
    object_cannot_place = "저기, 여기에는 이 물건을 배치할 수 없습니다.",
    reception_can_place = "이 접수대를 여기 설치할 수 있습니다.",
    reception_cannot_place = "이 접수대는 여기에 설치할 수 없습니다.",
    staff_can_place = "이 직원을 여기 배치할 수 있습니다.",
    staff_cannot_place = "미안하지만, 이 직원을 여기 배치할 수 없습니다.",
    room_cannot_place = "이 방을 여기 배치할 수 없습니다.",
    room_cannot_place_2 = "이 방을 여기 배치할 수 없습니다.",
  },
  praise = {
    many_benches = "환자들을 앉힐 의자가 충분하군요. 잘했어요.",
    many_plants = "멋지군요. 화초가 아주 많네요. 환자들이 좋아할 겁니다.",
    plants_are_well = "화초들을 잘 관리하고 있군요. 아주 좋아요.",
    few_have_to_stand = "병원 내의 사람들이 서 있어야 하는 일이 거의 없군요. 환자들이 기뻐할 것입니다.",
    plenty_of_benches = "앉을 자리가 충분하니 문제 없을 겁니다.",
    plants_thriving = "아주 좋아요. 화초들이 무럭무럭 자라고 있군요. 아주 멋져 보입니다. 계속 잘 관리한다면 상을 받을 수도 있겠군요.",
    patients_cured = "%d 명의 환자가 치료되었습니다.",
  },
  information = {
    larger_rooms = "방이 크면 클수록 직원들이 자신을 중요하게 여기며 성과가 올라갑니다.",
    extra_items = "방에 있는 추가저인 기물들은 직원들을 편안하게 하며 그들의 성과를 높입니다.",
    epidemic = "당신의 병원에 전염병이 들어왔습니다. 당장 조치를 취해야 합니다!",
    promotion_to_doctor = "당신의 수련의중 한 명이 전공의가 되었습니다.",
    emergency = "응급 상황입니다! 어서 움직여요! 어서!",
    patient_abducted = "환자들중 한 명이 외계인에 의해 납치되고 있습니다.",
    first_cure = "잘 했습니다! 첫 환자를 치료했군요.",
    promotion_to_consultant = "당신의 전공의중 한 명이 전문의가 되었습니다.",
    handyman_adjust = "당신은 잡역부의 업무 우선순위를 조정해서 더욱 효과적으로 일하도록 할 수 있습니다.",
    promotion_to_specialist = "당신의 의사중 한 명이 %s로 승진했습니다.",
    initial_general_advice = {
      rats_have_arrived = "병원에 쥐가 창궐했습니다. 마우스로 쥐들을 날려버리세요.",
      autopsy_available = "자동 부검 기계가 연구되었습니다. 이것으로 문제를 일삼거나 귀찮은 환자를 처치할 수 있고, 남은 것으로 연구도 진행할 수 있습니다. 주의하세요 - 이 기계를 사용하면 엄청난 물의를 일으키게 될 겁니다.",
      first_patients_thirsty = "병원 내에 목말라하는 사람들이 있습니다. 그런 사람들을 위해 음료 자판기들을 배치하세요.",
      research_now_available = "당신의 첫 연구실을 지었군요. 이제 당신은 연구 화면을 사용할 수 있습니다.",
      psychiatric_symbol = "정신과 훈련을 받은 의사들은 다음과 같은 표식을 지닙니다: |",
      decrease_heating = "병원이 너무 덥습니다. 난방을 좀 낮추세요. 마을 지도 화면에서 조절할 수 있습니다.",
      surgeon_symbol = "수술을 집도할 수 있는 의사들은 다음과 같은 표식을 지닙니다: {",
      first_emergency = "응급 환자들의 머리 위에는 파란 불이 깜빡거립니다. 그들이 사망하기 전에, 혹은 제한된 시간이 지나기 전에 치료하세요.",
      first_epidemic = "병원에 전염병이 돌기 시작했군요! 이 사실을 숨긴채 조용히 처리할지, 아니면 사실대로 공개할지 결정하세요.",
      taking_your_staff = "누군가가 당신의 직원을 꼬시고 있습니다. 직원들을 뺏기지 않으려면 싸워야 할 겁니다.",
      place_radiators = "병원이 너무 춥습니다 - 복도 기물 메뉴에서 추가로 라디에이터를 주문해서 병원에 배치할 수 있습니다.",
      epidemic_spreading = "병원에 전염병이 돌고 있습니다. 감염된 환자들이 떠나기 전에 치료하도록 시도하세요.",
      research_symbol = "연구 능력이 있는 의사들은 다음과 같은 표식을 지닙니다: }",
      machine_needs_repair = "수리가 필요한 기계가 있습니다. 우선 기계를 찾아낸 뒤 - 연기가 나고 있을 거예요 - 클릭하세요. 그런 뒤 잡역부 버튼을 누르세요.",
      increase_heating = "사람들이 추워합니다. 마을 지도 화면으로 가서 난방을 올리세요.",
      first_VIP = "당신의 첫 VIP가 곧 방문할 예정입니다. VIP가 비위생적인 모습이나 불행해보이는 환자를 보지 못하도록 주의를 기울이세요.",
    },
    patient_leaving_too_expensive = "환자가 %s 의 비용을 지불하지 않고 병원을 떠납니다. 너무 비싸요.",
    vip_arrived = "조심하세요! - %s 이(가) 당신의 병원을 방문했습니다! 모든 것이 원만하게 돌아가도록 하고 그를 만족시키세요.",
    epidemic_health_inspector = "보건부에 당신의 전염병 상황이 보고되었습니다. 건강 감시관의 방문에 대비하세요.",
    first_death = "첫 번째 환자를 죽였군요. 기분이 어때요?",
    pay_rise = "직원중 한 명이 그만두겠다고 협박하고 있습니다. 요구를 들어줄지 해고해 버릴지 결정하세요. 왼쪽 아래에 있는 아이콘을 클릭해서 어떤 직원이 협박하고 있는지 확인하세요.",
    place_windows = "창문을 배치하면 방이 밝아지고 직원의 사기가 올라갑니다.",
    fax_received = "화면 왼쪽 아래에 방금 나타난 아이콘은 중요한 정보 혹은 당신이 결정해야할 상황을 알려줍니다.",
  },
  build_advice = {
    placing_object_blocks_door = "그 물건을 거기 배치하면 사람들이 문을 사용하지 못하게 됩니다.",
    blueprint_would_block = "그 청사진은 다른 방을 가로막을 겁니다. 방의 크기를 조절하거나 다른 곳으로 옮기세요!",
    door_not_reachable = "사람들은 그 문을 사용할 수 없을 것입니다. 생각을 해보세요.",
    blueprint_invalid = "올바른 청사진이 아닙니다.",
  },
}
update_window = {
  new_version = "새 버전:",
  caption = "업데이트 가능!",
  download = "다운로드 페이지로 이동",
  current_version = "현재 버전:",
  ignore = "건너 뛰고 메인 메뉴로 이동",
}
calls_dispatcher = {
  repair = "%s 을(를) 수리",
  summary = "%d 건의 요청; %d 건 할당됨",
  close = "닫기",
  watering = "%d,%d 에서 물주는 중",
  staff = "%s - %s",
}
information = {
  cheat_not_possible = "이 레벨에서는 해당 치트를 사용할 수 없습니다. 치트하면서까지 실패하네요, 웃기지 않아요?",
  very_old_save = "이 레벨을 시작한 이후로 수많은 업데이트가 있었습니다. 모든 기능이 원활히 동작하게 하려면 재시작하는 것을 권합니다.",
  no_custom_game_in_demo = "죄송합니다. 데모 버전에서는 커스텀 맵을 플레이할 수 없습니다.",
  cannot_restart = "안타깝지만, 이 커스텀 게임은 재시작 기능이 구현되기 전에 만들어졌습니다.",
  custom_game = "CorsixTH 에 오신 것을 환영합니다. 이 커스텀 맵을 마음껏 즐겨주세요!",
  level_lost = {
    [1] = "이런! 당신은 이 레벨을 실패했습니다. 다음 기회에!",
    [2] = "실패한 이유:",
    reputation = "당신의 평판이 %d 아래로 떨어졌습니다.",
    balance = "당신의 은행 잔고가 %d 아래로 떨어졌습니다.",
    percentage_killed = "당신은 %d 퍼센트보다 많은 환자를 사망하게 했습니다.",
    cheat = "당신이 일부러 그랬거나 버튼을 잘못 눌렀나봐요? 치트도 하나 제대로 못하다니 어이없죠?",
  },
}
new_game_window = {
  hard = "전문의 (어려움)",
  cancel = "취소",
  tutorial = "튜토리얼",
  option_on = "켜짐",
  option_off = "꺼짐",
  difficulty = "난이도",
  easy = "수련의 (쉬움)",
  caption = "캠페인",
  player_name = "플레이어 이름",
  start = "시작",
  medium = "전공의 (보통)",
}
casebook = {
  sent_home = "돌려 보냄",
  deaths = "치사",
  treatment_charge = "치료 비용",
  reputation = "평판",
  research = "집중 연구",
  cure = "치료방법",
  cured = "치료",
  earned_money = "벌어들인 돈",
  cure_desc = {
    hire_doctors = "당신은 의사들을 고용해야 합니다.",
    hire_psychiatrists = "당신은 정신과 의사를 고용해야 합니다.",
    hire_surgeons = "당신은 외과 의사들을 고용해야 합니다.",
    hire_nurses = "간호사들을 고용해야 합니다.",
    build_ward = "당신은 여전히 병동을 지어야 합니다.",
    no_cure_known = "알려진 치료법 없음.",
    improve_cure = "치료법 개선.",
    cure_known = "치료 가능.",
    build_room = "%s 을(를) 지을 것을 추천합니다.",
  },
}
handyman_window = {
  all_parcels = "모든 구획",
  parcel = "구획",
}
folders_window = {
  screenshots_location = "스크린샷을 저장할 디렉토리를 선택하세요",
  music_label = "MP3들",
  back = "뒤로",
  savegames_label = "저장된 게임들",
  caption = "폴더 위치",
  savegames_location = "게임을 저장할 디렉토리를 선택하세요",
  font_label = "폰트",
  new_th_location = "여기서 테마 병원 설치 디렉토리를 새로 지정할 수 있습니다. 새 위치를 지정하는 즉시 게임이 재시작 됩니다.",
  screenshots_label = "스크린샷",
  music_location = "음악을 재생할 디렉토리를 선택하세요",
  data_label = "테마 병원 데이터",
}
customise_window = {
  movies = "영상 컨트롤",
  option_on = "켜짐",
  option_off = "꺼짐",
  back = "뒤로",
  paused = "정지 상태에서 건설",
  intro = "인트로 영상 재생",
  volume = "음량 감소 단축키",
  caption = "커스텀 설정",
  fractured_bones = "골절",
  average_contents = "일반 비품",
  aliens = "외계인 환자",
}
diseases = {
  alien_dna = {
    name = "외계 DNA",
    cause = "원인 - 사람의 얼굴에 달라붙는 지적인 외계 생명의 혈액.",
    symptoms = "증상 - 서서히 외계 생명체로 변해가며 인간의 도시를 파괴하고 싶은 욕망이 생김.",
    cure = "치료 - 환자의 DNA 를 기계적으로 추출한 뒤, 외계 요소를 제거하고 다시 집어 넣음.",
  },
  autopsy = {
    name = "부검",
  },
  baldness = {
    name = "대머리",
    cause = "원인 - 인기를 얻기 위해 거짓말을 하고 지어낸 이야기들을 함.",
    symptoms = "증상 - 반짝이는 머리와 동반되는 부끄러움.",
    cure = "치료 - 고통스러운 기계를 사용해 환자의 두부에 머리카락을 심음.",
  },
  bloaty_head = {
    name = "부은 머리",
    cause = "원인 - 치즈 냄새를 맡고 정수되지 않은 빗물을 마심.",
    symptoms = "증상 - 굉장히 불편해짐.",
    cure = "치료 - 팽창된 머리를 뻥 터뜨린 뒤, 똑똑한 기계를 사용해 정확한 압력으로 재 팽창시킴.",
  },
  broken_heart = {
    name = "가슴 앓이",
    cause = "원인 - 환자보다 부유하거나 젊고 날씬한 사람.",
    symptoms = "증상 - 울음과 나들이 사진들을 반복적으로 찢어서 생기는 근육 손상.",
    cure = "치료 - 외과 의사 두 명이 환자의 흉부를 열고 숨을 참은 채로 조심스레 심장을 고침.",
  },
  broken_wind = {
    name = "지속성 방귀",
    cause = "원인 - 식사 직후에 헬스장에서 런닝머신을 뜀.",
    symptoms = "증상 - 환자 바로 뒤에 있는 사람들을 불편하게 함.",
    cure = "치료 - 물같은 특수한 물질들을 섞은 혼합 용액을 약국에서 신속하게 마심.",
  },
  chronic_nosehair = {
    name = "만성 콧털",
    cause = "원인 - 환자보다 가난한 사람들을 심하게 경멸하며 코웃음 침.",
    symptoms = "증상 - 오소리가 둥지를 틀어도 될만큼 거대한 콧털.",
    cure = "치료 - 약국에서 간호사가 조제한 역겨운 모발 제거 물약을 마심.",
  },
  corrugated_ankles = {
    name = "주름잡힌 발목",
    cause = "원인 - 도로 상의 서행 표지를 차로 밟고 지나감.",
    symptoms = "증상 - 신발 등을 신기가 매우 불편해짐.",
    cure = "치료 - 발목을 펴기 위해 약간의 독성이 있는 허브와 향신료 혼합물을 마심.",
  },
  diag_blood_machine = {
    name = "혈액 분석기 진단",
  },
  diag_cardiogram = {
    name = "심전도 진단",
  },
  diag_general_diag = {
    name = "일반 진단",
  },
  diag_psych = {
    name = "정신과 진단",
  },
  diag_scanner = {
    name = "스캐너 진단",
  },
  diag_ultrascan = {
    name = "울트라스캔 진단",
  },
  diag_ward = {
    name = "병동 진단",
  },
  diag_x_ray = {
    name = "X-레이 진단",
  },
  fake_blood = {
    name = "가짜피",
    cause = "원인 - 환자가 짓궂은 장난에 너무 쉽게 당함.",
    symptoms = "증상 - 정맥에 혈액 대신 천에 닿으면 증발하는 붉은 액체가 흐름.",
    cure = "치료 - 정신과적인 진정이 유일한 해결책.",
  },
  discrete_itching = {
    name = "간헐성 가려움증",
    cause = "원인 - 날카로운 이빨을 지닌 작은 곤충.",
    symptoms = "증상 - 심하게 긁어서 몸 여기저기에 염증이 생김.",
    cure = "치료 - 피부의 가려움을 방지하기 위해 끈적끈적한 시럽을 마심.",
  },
  fractured_bones = {
    name = "골절",
    cause = "원인 - 높은 곳에서 콘크리트 위로 떨어짐.",
    symptoms = "증상 - 쿵 하는 소리와 함께 부러진 팔/다리를 사용할 수 없게 됨.",
    cure = "치료 - 깁스를 한 뒤 레이저 기반 제거 기계로 제거함.",
  },
  gastric_ejections = {
    name = "위액 분출",
    cause = "원인 - 아주 매운 멕시코, 인도 음식.",
    symptoms = "증상 - 반쯤 소화된 음식이 환자에게서 닥치는 대로 분출됨.",
    cure = "치료 - 특수한 경화 용액을 마셔서 토하는 것을 막음.",
  },
  general_practice = {
    name = "진료",
  },
  golf_stones = {
    name = "골프 결석",
    cause = "원인 - 골프공 내부의 독가스에 노출됨.",
    symptoms = "증상 - 정신 착란 증세와 심각한 수치심.",
    cure = "치료 - 두 명의 외과 의사가 수술을 통해 결석을 제거해야 함.",
  },
  gut_rot = {
    name = "썩은 창자",
    cause = "원인 - O'Malley 부인의 끝내주는 기침약 위스키.",
    symptoms = "증상 - 기침이 사라지지만, 위장벽의 보호막도 함께 사라짐.",
    cure = "치료 - 간호사가 적절히 선택한 용해 혼합물로 위장벽을 코팅.",
  },
  hairyitis = {
    name = "모발 과다증",
    cause = "원인 - 달빛에 오랫동안 노출됨.",
    symptoms = "증상 - 환자들은 후각이 굉장히 예민해짐.",
    cure = "치료 - 전기분해 기계로 모발을 제거하고 모공을 봉함.",
  },
  heaped_piles = {
    name = "치질",
    cause = "원인 - 냉각기 주위에 서있음.",
    symptoms = "증상 - 마치 구슬 주머니 위에 앉아있는 것 같은 느낌을 받음.",
    cure = "치료 - 기분좋은, 그러나 아주 강력한 산성의 음료를 마셔서 장에 쌓인 물질을 녹임.",
  },
  infectious_laughter = {
    name = "전염성 웃음병",
    cause = "원인 - 고전 상황 코메디.",
    symptoms = "증상 - 끝없이 킥킥거리며 웃고 재미없는 캐치프레이즈를 반목해서 말함.",
    cure = "치료 - 자격을 갖춘 정신과 의사가 환자에게 지금 상황이 얼마나 심각한지 상기시킴.",
  },
  invisibility = {
    name = "투명인간",
    cause = "원인 - 눈에 안보이는 방사능 개미에게 물림.",
    symptoms = "증상 - 환자는 특별히 불편하지 않음. 사실 많은 환자들은 이 병으로 가족들에게 짓궂은 장난을 침.",
    cure = "치료 - 약국에서 다채로운 색의 액체를 마시면 곧 눈에 보이게 됨.",
  },
  iron_lungs = {
    name = "철화된 폐",
    cause = "원인 - 도시 내의 스모그와 케밥 찌꺼기가 섞여서 생김.",
    symptoms = "증상 - 불을 뿜거나 깊은 물 속에서 소리지를 수 있음.",
    cure = "치료 - 두 명의 외과 의사가 수술실에서 폐의 굳은 부분을 제거함.",
  },
  jellyitis = {
    name = "젤리염",
    cause = "원인 - 젤라틴 성분이 풍부한 식단과 너무 과한 운동.",
    symptoms = "증상 - 엄청난 비틀거림과 자주 넘어짐.",
    cure = "치료 - 특수한 방에서 젤리통에 환자의 몸을 잠시동안 담금.",
  },
  kidney_beans = {
    name = "콩팥콩",
    cause = "원인 - 음료수에 든 얼음을 씹어먹음.",
    symptoms = "증상 - 통증과 잦은 화장실 출입.",
    cure = "치료 - 두명의 외과 의사가 콩팥을 유지한 채 콩만 제거해내야 함.",
  },
  king_complex = {
    name = "왕자병",
    cause = "원인 - 왕의 영혼이 환자의 정신을 지배함.",
    symptoms = "증상 - 색상이 화려한 스웨이드 신발을 신으며 치즈버거를 먹음.",
    cure = "치료 - 정신과 의사가 지금 환자가 얼마나 우습게 보이는지 말해줌.",
  },
  pregnancy = {
    name = "임신",
    cause = "원인 - 도시 지역의 정전.",
    symptoms = "증상 - 변덕스럽게 음식을 먹으며 결과적으로 배불뚝이가 됨.",
    cure = "치료 - 수술실에서 아기를 받아 씻긴 뒤 환자에게 돌려줌.",
  },
  ruptured_nodules = {
    name = "혹 파열",
    cause = "원인 - 추운 날씨에 번지 점프를 함.",
    symptoms = "증상 - 편안하게 앉지를 못함.",
    cure = "치료 - 두 명의 자격있는 외과 의사가 떨림 없는 손으로 혹을 제거해야 함.",
  },
  serious_radiation = {
    name = "심각한 방사능 오염",
    cause = "원인 - 플루토늄 동위 원소를 껌으로 착각함.",
    symptoms = "증상 - 이 상태의 환자는 아주 많이 기분이 좋지 않음.",
    cure = "치료 - 환자를 오염제거 샤워기로 깨끗하게 씻어줘야 함.",
  },
  slack_tongue = {
    name = "늘어진 혀",
    cause = "원인 - 아침 드라마에 대한 지속적인 과다 논쟁.",
    symptoms = "증상 - 혀가 원래 크기의 다섯 배 정도로 팽창함.",
    cure = "치료 - 혀를 절단기에 넣고 효과적이지만 고통스러운 방법으로 재빨리 절단해냄.",
  },
  sleeping_illness = {
    name = "수면증",
    cause = "원인 - 입 천장의 수면 분비선의 과활성화.",
    symptoms = "증상 - 아무데서나 일어나는 압도적인 수면욕.",
    cure = "치료 - 간호사의 관리 하에 강력한 자극제를 충분히 투약.",
  },
  spare_ribs = {
    name = "여분의 늑골",
    cause = "원인 - 차가운 돌바닥에 앉음.",
    symptoms = "증상 - 가슴 부위의 불편한 느낌.",
    cure = "치료 - 2명의 외과 의사가 여분의 늑골을 제거한 뒤, 강아지 간식용 봉투에 넣어 환자에게 돌려줌.",
  },
  sweaty_palms = {
    name = "다한증",
    cause = "원인 - 구직 면접에 대한 두려움.",
    symptoms = "증상 - 환자와 악수하는 것이 마치 방금 물에 푹 적신 스펀지를 잡는 것 같음.",
    cure = "치료 - 정신과 의사가 환자와 대화하여 이 만들어진 병에서 벗어나게 해야 함.",
  },
  the_squits = {
    name = "설사병",
    cause = "원인 - 오븐 밑에 떨어져 있던 피자를 섭취.",
    symptoms = "증상 - 으. 말 안해도 알겠죠.",
    cure = "치료 - 섬유질 성분의 점성의 액체로 환자의 내부를 굳힘.",
  },
  third_degree_sideburns = {
    name = "3도 구렛나룻",
    cause = "원인 - 70년대에 대한 진한 향수",
    symptoms = "증상 - 풍성한 머리, 나팔바지, 플랫폼과 현란한 화장.",
    cure = "치료 - 정신과 의사가 최신 기술들을 사용해서 이런 북실북실한 치장은 지저분해 보인다고 확신시켜야 함.",
  },
  transparency = {
    name = "투과증",
    cause = "원인 - 열려 있던 항아리 뚜껑에 묻은 요구르트를 핥음.",
    symptoms = "증상 - 살이 투명해지며 속이 비쳐 끔찍한 모습이 됨.",
    cure = "치료 - 특수하게 냉각 및 착색된 음료를 약국에서 마심.",
  },
  tv_personalities = {
    name = "TV 중독",
    cause = "원인 - 낮시간 텔레비전 프로그램.",
    symptoms = "증상 - 자신이 요리 프로그램을 상영할 수 있을거라는 착각.",
    cure = "치료 - 훈련된 정신과 의사가 환자를 설득해서 TV를 팔고 라디오를 구매하도록 함.",
  },
  uncommon_cold = {
    name = "희한한 감기",
    cause = "원인 - 공기중에 떠다니는 작은 콧물 방울.",
    symptoms = "증상 - 흐르는 콧물, 재채기, 변색된 폐.",
    cure = "치료 - 약국에서 조제한 특이 감기약을 쭉 들이키면 나음.",
  },
  unexpected_swelling = {
    name = "뜻밖의 팽창",
    cause = "원인 - 뭔가 예상치 못한 것.",
    symptoms = "증상 - 팽창.",
    cure = "치료 - 두 명의 외과 의사가 수술을 통해 팽창된 부분을 찔러서 터뜨리는 수 밖에 없음.",
  },
}
policy = {
  header = "병원 정책",
  diag_procedure = "진단 절차",
  diag_termination = "진단 종료",
  staff_rest = "직원의 휴식",
  staff_leave_rooms = "직원이 방을 떠남",
  sliders = {
    guess = "추측에 의한 치료",
    send_home = "돌려 보내기",
    stop = "절차 중지",
    staff_room = "직원 휴게실로 이동",
  },
}
options_window = {
  fullscreen = "전체화면",
  cancel = "취소",
  custom_resolution = "커스텀...",
  option_on = "켜짐",
  option_off = "꺼짐",
  back = "뒤로",
  caption = "옵션",
  language = "게임 언어",
  apply = "적용",
  width = "너비",
  change_resolution = "해상도 변경",
  height = "높이",
  resolution = "해상도",
  folder = "폴더",
  audio = "오디오",
  customise = "커스터마이즈",
}
trophy_room = {
  all_cured = {
    awards = {
      [1] = "작년 한해 동안 모든 환자들을 성공적으로 치료한 것으로 '마리 퀴리 상 (Marie Curie Award)'을 수상하게 된 것을 축하합니다.",
    },
    trophies = {
      [1] = "국제 치료 재단은 당신이 작년 한해 동안 모든 사람을 치료했다는 사실을, '전원치료 트로피 (Cure-All Trophy)'를 수여하는 것으로 기리고자 합니다.",
      [2] = "당신은 작년에 방문한 모든 환자를 치료한 공로로 '무병 가글러 트로피 (No-ill Gargler Trophy)'를 수상했습니다.",
    },
  },
  best_value_hosp = {
    trophies = {
      [1] = "작년 한해 동안 가장 높은 평가를 받은 병원에게 주어지는 '완전무결 트로피 (SqueakiKlean Trophy)'를 수상하게 된 것을 축하합니다. 당신은 충분히 받을 자격이 있습니다.",
    },
    penalty = {
      [1] = "주변의 모든 병원이 당신 병원보다 더 가치가 있습니다. 이 수치스러운 상황을 수습해 보세요. 비싼 물건들을 좀 들여놓으세요!",
    },
    regional = {
      [1] = "게임 내에서 가장 가치 있는 병원을 가진 것을 축하드립니다. 잘 해냈군요. 계속 분발해 주세요.",
    },
  },
  consistant_rep = {
    trophies = {
      [1] = "금년에 가장 모범이 되며 가장 높은 평판을 유지한 것에 의거, 당신은 '내각 장관 상 (Cabinet Minister's Award)'을 수상했습니다. 훌륭합니다.",
      [2] = "작년 한해 동안 가장 높은 평가를 받은 병원에게 주어지는 '완전무결 트로피 (SqueakiKlean Trophy)'를 수상하게 된 것을 축하합니다. 당신은 충분히 받을 자격이 있습니다.",
    },
  },
  cleanliness = {
    regional_good = {
      [1] = "당신의 병원은 지역 내에서 가장 깨끗하지 못한 병원 중 하나로 꼽혔습니다. 지저분한 병원은 냄새나고 위험합니다. 당신은 이 어지러운 것들에 신경을 더 써야 합니다.",
    },
    award = {
      [1] = "검사관들은 당신의 병원이 매우 청결하다고 평가했습니다. 청결한 병원은 안전한 병원입니다. 계속 힘써주세요.",
    },
    regional_bad = {
      [1] = "당신의 병원은 지역 내에서 가장 지저분한 병원입니다. 다른 모든 병원 책임자들은 그들의 복도를 더 깨끗하게 유지해 냈습니다. 당신은 의료계의 수치입니다.",
    },
  },
  curesvdeaths = {
    awards = {
      [1] = "작년 당신의 병원이 인상적인 치료대 사망 비율을 달성한 것에 진심어린 축하를 드립니다.",
    },
    penalty = {
      [1] = "당신의 치료수 대 사망 수는 극도로 나쁩니다. 죽는 환자의 수 보다 치료하는 환자의 수가 훨씬 많아지도록 유지해야 합니다. 우리를 실망시키지 마세요.",
    },
  },
  emergencies = {
    regional_good = {
      [1] = "보건부는 작년 한해 동안 당신이 다른 어떤 병원보다 응급상황을 잘 처리한 것을 감사하며 이 상을 수여합니다.",
    },
    penalty = {
      [1] = "당신은 응급상황을 제대로 처리하지 못했습니다. 응급 환자들에게 필요한 신속하고 정확한 처치를 하는 데 실패했습니다.",
    },
    regional_bad = {
      [1] = "당신의 병원은 지역 내에서 응급상황을 처리하는데 최악이었습니다. 지역내 응급 처치 순위권에서 최하위로 머물게 된 것은 모두 당신 책임입니다.",
    },
    award = {
      [1] = "축하합니다: 당신의 신속하고 효과적인 응급 처치가 이 특별 상을 수상하게 했습니다. 잘 했습니다.",
      [2] = "당신의 응급 처리는 특별합니다. 이 상은 대규모의 환자들을 치료하는 데 절대적으로 최고임을 증명한 당신에게 수여합니다.",
    },
  },
  gen_repairs = {
    awards = {
      [1] = "당신의 잡역부들이 빈틈없이 병원의 기계 장치들을 정비한 것에 대한 특별 상을 수여합니다. 잘 했습니다. 휴가라도 다녀오세요.",
      [2] = "당신의 잡역부들은 다른 어떤 병원의 잡역부들 보다 잘 일해주었습니다. 이것은 축하받을 만한 주요 성과입니다.",
      [3] = "당신의 기계들은 최상의 상태로 정비되었습니다. 잡역부들의 헌신적인 노력은 놀랄 만한 일입니다. 당신은 이 권위있는 상을 받을 자격이 있습니다. 훌륭합니다.",
    },
    penalty = {
      [1] = "당신의 잡역부들은 기계들을 제대로 정비하지 못했습니다. 그들을 더 잘 관리하거나 좀 더 고용해서 일을 분담시킬 필요가 있을 것 같군요.",
      [2] = "기계들을 정비하는 데 아주 엉망입니다. 직원들이 설비들을 신속하고 세심하게 정비하도록 해야 합니다.",
    },
  },
  happy_patients = {
    awards = {
      [1] = "작년 한해 동안 귀하의 병원내의 사람들이 매우 만족했다는 것은 자랑할만 한 일입니다.",
      [2] = "당신의 병원을 방문하는 사람들은 게임 내의 다른 병원에 방문한 사람들보다 평균적으로 치료에 더 만족했습니다.",
    },
    penalty = {
      [1] = "당신의 병원에 방문하는 사람들은 아주 형편없는 취급을 받고 있습니다. 보건부로부터 인정을 받고 싶다면 더 잘해야 할 겁니다.",
      [2] = "당신의 병원에서 치료받는 사람들은 이 곳의 상태에 대해 굉장히 불만족스러워 합니다. 환자들의 복지를 좀 더 세심하게 신경써야 합니다.",
    },
  },
  happy_staff = {
    trophies = {
      [1] = "열심히 일하는 당신의 직원들을 계속 행복하게 유지한 공로로 '미소 트로피 (Smiley Trophy)'를 수여합니다.",
      [2] = "'아다미 행복 연구소'는 작년 한해 동안 불행한 직원이 하나도 없도록 관리한 것에 대한 보상으로 이 트로피를 수여합니다.",
      [3] = "이 트로피, '더욱 환한 미소 컵 (Beam-more Cup)'은 작년 한해간 일반적인 기대를 훨씬 뛰어 넘도록 귀하의 직원들을 행복하게 해준 당신에게 수여합니다. 모두에게 미소를!",
    },
    awards = {
      [1] = "당신의 직원들이 이 상을 줍니다. 직원들의 말에 따르면, 약간의 개선의 여지는 있지만 당신의 처우는 전체적으로 좋았다는군요.",
      [2] = "당신의 직원들은 당신 밑에서 일하는 것이 너무 즐거워서 웃음이 떠나지 않는다고 합니다. 당신은 훌륭한 매니저 입니다.",
    },
    penalty = {
      [1] = "당신의 직원들은 지금의 처우에 대해 굉장히 불만스럽다는 것을 알리고 싶어 합니다. 좋은 직원들은 재산입니다. 그들을 행복하게 해주지 못한다면 당신을 떠나버리고 말 겁니다.",
    },
    regional_good = {
      [1] = "당신의 직원들은 다른 모든 병원들에 비해 만족도가 높았습니다. 행복한 직원은 곧 높은 이윤과 적은 사망으로 이어집니다. 보건부는 이 소식에 기쁨을 표합니다.",
    },
    regional_bad = {
      [1] = "당신의 직원들은 작년 내내 아주 최악의 대우를 받았습니다. 당신도 눈치를 좀 챘어야 합니다. 지금 상태로는 다른 모든 병원들이 당신보다 더 행복한 직원들을 데리고 있는 셈입니다.",
    },
  },
  happy_vips = {
    trophies = {
      [1] = "귀하는 '노벨 VIP 감명 상 (Nobel Prize for Impressing VIPs)'을 수상했습니다. 작년에 당신의 병원을 방문한 VIP 들 모두가 입이 마르도록 칭찬을 하고 있습니다.",
      [2] = "'유명인사국'은 귀하에게 당신의 기관을 방문한 모든 VIP 를 만족시킨 공로로 '유명인 트로피 (Celebrity Trophy)'를 수여하고자 합니다.",
      [3] = "'VIP 여행상 (VIP TRIP award)'을 수상하게된 것을 축하합니다. 이 상은 공공의 눈 아래에서 열심히 일하는 유명 인사들을 만족시킨 공로를 기리기 위함입니다. 훌륭합니다.",
    },
  },
  healthy_plants = {
    awards = {
      [1] = "작년 내내 화초들을 매우 생생하게 관리한 공로로 '무럭무럭 비료 상 (Gro-More Fertiliser award)'을 수상하게 된 것을 축하합니다.",
    },
    trophies = {
      [1] = "화분 식물 연합 일동은 '건강의 녹색 트로피 (Green Trophy of Health)'로 당신이 지난 12개월간 화초들을 건강하게 관리해준 것을 기리고자 합니다.",
      [2] = "트리피드 연합은 당신의 병원 화초들을 작년 한해 동안 최고의 상태로 유지한 것에 대해 '녹색손가락 트로피 (Greenfinger Trophy)'를 수여합니다.",
    },
  },
  high_rep = {
    penalty = {
      [1] = "당신은 작년 한해간 평판이 형편없었던 것에 대해 징계를 받게 될겁니다. 추후에는 개선될 수 있도록 해주세요.",
      [2] = "당신 병원의 평판은 지역 내에서 가장 나쁩니다. 아주 불명예스럽군요. 앞으로 더 잘 하거나 다른 직업을 찾아보시죠.",
    },
    awards = {
      [1] = "잘 하셨습니다. 작년에 꽤 인상적인 좋은 평판을 남겼던 공로로 소정의 상을 수여합니다.",
      [2] = "훌륭합니다! 귀하의 병원에 작년 한해동안 가장 높은 명성을 쌓은 것으로 이 상을 수여합니다.",
    },
    regional = {
      [1] = "작년 한해간 모든 병원중에 가장 높은 평판을 쌓은 병원에게 주어지는 '불프로그 상 (Bullfrog Award)'을 받아주세요. 즐기세요 - 당신은 받을 만한 자격이 있습니다.",
      [2] = "이번 해에 당신 병원의 평판은, 다른 모든 병원의 평판을 합친 것을 상회했습니다. 두드러진 성과입니다.",
    },
  },
  hosp_value = {
    penalty = {
      [1] = "당신 병원의 가치를 일정 수준 이상으로 유지하는데 실패했습니다. 돈과 관련된 잘못된 결정을 많이 내렸군요. 기억하세요, 좋은 병원은 또한 값비싼 병원이기도 합니다.",
    },
    awards = {
      [1] = "보건부는 이 자리를 빌어 전체적으로 매우 높은 귀하의 병원 가치를 축하하고자 합니다.",
    },
    regional = {
      [1] = "당신은 재정분야의 귀재로군요. 당신의 병원은 지역 내의 다른 병원들을 모두 합친 것보다 가치가 높습니다.",
    },
  },
  many_cured = {
    trophies = {
      [1] = "작년 한해 동안 거의 모든 환자들을 성공적으로 치료한 것으로 '마리 퀴리 상 (Marie Curie Award)'을 수상하게 된 것을 축하합니다.",
      [2] = "국제 치료 재단은 당신이 작년 한해 동안 대단히 많은 사람을 치료했다는 사실을, '많이치료 트로피 (Cure-A-Lot Trophy)'를 수여하는 것으로 기리고자 합니다.",
      [3] = "당신은 작년에 방문한 환자들의 대다수를 치료한 공로로 '무병 가글러 트로피 (No-ill Gargler Trophy)'를 수상했습니다.",
    },
    penalty = {
      [1] = "당신의 병원은 환자들에게 필요한 적절한 치료를 제공해주지 못하고 있습니다. 치료법들이 더 잘 듣도록 개선하는 데 집중하세요.",
      [2] = "당신의 병원은 다른 모든 병원들에 비해 환자를 치료하는데 덜 능숙합니다. 당신 자신 뿐만 아니라 보건부의 얼굴에 먹칠을 하고 있군요. 더 긴 말 하지 않겠습니다.",
    },
    awards = {
      [1] = "작년동안 대량의 환자들을 치료한 것을 축하드립니다. 많은 사람들이 당신 덕분에 몸이 한결 좋아졌습니다.",
      [2] = "다른 모든 병원보다 더 많은 환자들을 치료한 것에 대한 이 상을 받아주세요. 아주 확실한 성과입니다.",
    },
    regional = {
      [1] = "당신은 다른 모든 병원의 치료 환자 수를 합친 것보다도 더 많은 환자를 치료한 공로로 궁극의 치료 상을 수상했습니다.",
    },
  },
  no_deaths = {
    trophies = {
      [1] = "당신은 작년동안 100%의 환자를 살린 공로로 '해치지 않아요 상 (No-Croak Award)'을 수상했습니다.",
      [2] = "'사단 법인 지속되는 인생'은 작년동안 아무도 죽게 하지 않은 것에 대해 이 트로피를 수여합니다.",
      [3] = "당신은 올해에 어떠한 사망자도 나오지 않도록 하는 데 성공한 공로로 '생존 트로피 (Staying Alive Trophy)'를 수상했습니다. 훌륭합니다.",
    },
    penalty = {
      [1] = "작년도 당신의 병원 내 사망자 수는 너무 많았습니다. 더 신경을 써 주세요. 추후에는 반드시 더 많은 사람이 살아남도록 하세요.",
      [2] = "당신의 병원은 환자들의 건강에 있어 위험요소 입니다. 당신의 일은 많은 사람들을 치료하는 것이지, 그들을 죽게 놔두는 것이 아닙니다.",
    },
    awards = {
      [1] = "올해 귀 병원의 적은 사망자 수를 기념하기 위해 이 상을 수여합니다.",
      [2] = "당신의 능력이 병원의 사망자 수를 최소한으로 유지했습니다. 아주 기뻐할만한 성과입니다.",
    },
    regional = {
      [1] = "작년 귀 병원의 치사율은 다른 어떤 병원보다도 낮았습니다. 이 상을 받아주세요.",
    },
  },
  pop_percentage = {
    awards = {
      [1] = "작년 한해간 귀 병원이 도시 인구의 높은 점유율을 기록했음을 주목하세요. 잘 하셨습니다.",
      [2] = "축하합니다. 다른 기관들보다 당신의 병원에 더 많은 지역 주민들이 방문하였습니다.",
      [3] = "멋지군요. 당신의 병원은 다른 병원들의 환자 수를 합친 것보다 더 많은 환자들을 끌어들였습니다.",
    },
    penalty = {
      [1] = "올해 당신의 병원에는 사람들이 거의 오지 않았습니다. 돈을 벌기 위해서는 돈을 내 줄 환자들이 필요하겠죠.",
      [2] = "지역 내의 다른 모든 병원은 당신의 병원보다 많은 비율의 환자들을 데려오는 데 성공했습니다. 부끄러운줄 아세요.",
    },
  },
  rats_accuracy = {
    trophies = {
      [1] = "당신은 쥐들을 저격하는 데 %d%% 의 정확도를 가진 것을 기념하여 '신디케이트 워즈 저격 트로피 (Syndicate Wars Accurate Shooting Trophy)'를 수상하였습니다.",
      [2] = "이 트로피는 작년동안 쥐를 %d%% 의 확률로 사살한 당신의 놀라운 정확도를 기념하기 위함입니다.",
      [3] = "당신의 병원에 나타는 쥐들을 %d%% 박멸한 것을 기념하기 위해 '던전 키퍼 해수제로 트로피 (Dungeon Keeper Vermin-Free Trophy)'를 수여합니다. 축하합니다!",
    },
  },
  rats_killed = {
    trophies = {
      [1] = "당신은 작년에 병원 내에서 %d 마리의 쥐를 저격한 공로로 '반-해수 트로피 (Anti-Vermin Trophy)'를 수상하였습니다.",
      [2] = "당신은 놀라운 쥐 저격 능력을 %d 마리의 쥐를 퇴치하여 '쥐 퇴치 연맹' 으로부터 이 트로피를 받을 자격을 갖추었습니다.",
      [3] = "귀하는 작년에 병원내의 %d 마리의 쥐를 해치움으로써 '날려버리쥐 트로피 (Ratblast Trophy)'를 수상할 자격을 얻었습니다.",
    },
  },
  research = {
    regional_good = {
      [1] = "귀하의 연구 수준은 최신 기술들과 어깨를 나란히 했습니다. 귀하의 연구진은 이 상을 받을 자격이 있습니다. 잘 하셨습니다.",
    },
    penalty = {
      [1] = "당신은 새로운 치료법, 기계, 약물 등을 개발하는 데 매우 부진했습니다. 기술적인 진보가 필수라는 것을 감안할 때, 이것은 매우 나쁜 징조입니다.",
    },
    regional_bad = {
      [1] = "지역 내의 다른 모든 병원들은 당신의 병원보다 연구 수준이 높습니다. 연구가 병원에 끼치는 중요한 역할에 기인하여 보건부는 귀 병원에 분노하고 있습니다.",
    },
    awards = {
      [1] = "귀하의 연구 수준은 최신 기술들과 어깨를 나란히 했습니다. 귀하의 연구진은 이 상을 받을 자격이 있습니다. 잘 하셨습니다.",
      [2] = "작년 한해 동안 귀하는 사람들의 기대 이상으로 많은 신약과 치료장비들을 연구해냈습니다. 보건부의 모두가 드리는 이 상을 받아주세요.",
    },
  },
  sold_drinks = {
    trophies = {
      [1] = "'세계 치과 의사 연맹'은 당신의 병원에서 대량의 캔음료를 판매한 것에 대해 이 트로피와 상장을 수여합니다.",
      [2] = "당신의 병원은 작년에 병원에서 팔린 막대한 양의 탄산 음료를 기념하여 이 '탄산 트로피 (Fizzy-Bizz Trophy)'를 수상했습니다.",
      [3] = "주식회사 'DK Fillings'를 대표하여, 이 초콜릿 덮인 트로피로 올해 당신의 병원이 탄산 음료를 특출나게 많이 판매한 것을 기념하고자 합니다.",
    },
  },
  wait_times = {
    award = {
      [1] = "축하합니다. 당신의 병원은 꾸준하게 짧은 대기시간을 유지해왔습니다. 이것은 아주 중요한 상입니다.",
    },
    penalty = {
      [1] = "당신 병원의 환자들은 너무 오랫동안 기다려야 합니다. 어디를 가든 납득이 안되는 긴 줄이 있습니다. 할 마음만 있다면 환자들을 좀 더 효율적으로 관리할 수 있을 겁니다.",
    },
  },
  reputation = "평판",
  cash = "소지금",
}
buy_objects_window = {
  price = "가격: ",
  choose_items = "기물 선택",
  total = "합계: ",
}
menu_list_window = {
  save_date = "수정됨",
  name = "이름",
  back = "뒤로",
}
menu_options_volume = {
  [50] = "  50%  ",
  [100] = "  100%  ",
  [30] = "  30%  ",
  [60] = "  60%  ",
  [90] = "  90%  ",
  [10] = "  10%  ",
  [20] = "  20%  ",
  [40] = "  40%  ",
  [80] = "  80%  ",
  [70] = "  70%  ",
}
menu_file_load = {
  [1] = "  게임 1  ",
  [2] = "  게임 2  ",
  [3] = "  게임 3  ",
  [4] = "  게임 4  ",
  [5] = "  게임 5  ",
  [6] = "  게임 6  ",
  [7] = "  게임 7  ",
  [8] = "  게임 8  ",
}
menu_file = {
  quit = " (SHIFT+Q) 종료   ",
  save = " (SHIFT+S) 저장   ",
  load = " (SHIFT+L) 불러오기   ",
  restart = " (SHIFT+R) 재시작",
}
menu_options_wage_increase = {
  deny = "    거절 ",
  grant = "    승인 ",
}
save_game_window = {
  caption = "저장 게임 (%1%)",
  new_save_game = "새로운 저장 게임",
}
rooms_long = {
  ultrascan = "울트라스캔실",
  research_room = "연구 부서",
  general = "일반",
  gps_office = "진료실",
  inflation = "팽창실",
  staffroom = "직원 휴게실",
  jelly_vat = "젤리 통",
  scanner = "스캐너실",
  emergency = "응급실",
  decontamination = "오염 제거실",
  corridors = "복도",
  cardiogram = "심전도실",
  ward = "병동",
  training_room = "교육실",
  psychiatric = "정신과실",
  operating_theatre = "수술실",
  dna_fixer = "DNA 정정기",
  tongue_clinic = "늘어진 혀 클리닉",
  hair_restoration = "모발 재생 클리닉",
  general_diag = "일반 진단실",
  pharmacy = "약국",
  fracture_clinic = "골절 클리닉",
  toilets = "화장실",
  electrolysis = "전기분해 클리닉",
  x_ray = "X-레이실",
  blood_machine = "혈액 분석실",
}
fax = {
  epidemic_result = {
    fine_amount = "정부는 국가적 비상사태를 선언했으며 당신에게 %d 의 벌금을 청구합니다.",
    close_text = "만세!",
    hospital_evacuated = "보건 위원회는 당신의 병원을 비우는 수 밖에 없었습니다.",
    succeeded = {
      part_1_name = "건강 검사관은 당신의 기관이 악성의 %s 을(를) 겪고 있다는 소문을 들었습니다.",
      part_2 = "그러나 이러한 소문을 뒷받침하는 어떤 근거도 찾을 수 없었습니다.",
    },
    compensation_amount = "정부는 이러한 거짓말이 당신의 병원의 명성에 끼친 악영향에 대해 %d 만큼의 보상을 지불하기로 결정했습니다.",
    failed = {
      part_1_name = "전염성 %s 을(를) 겪고 있다는 사실을 숨기려 함으로써",
      part_2 = "당신의 병원 직원들은 질병이 병원 주변의 대중에게 퍼져나가도록 방치했습니다.",
    },
    rep_loss_fine_amount = "언론사들이 이를 집중 취재할 것이며, 당신의 평판은 심각하게 훼손될 것입니다. 또한, 당신은 %d 의 벌금을 물게 될 것입니다.",
  },
  vip_visit_query = {
    choices = {
      invite = "공식적으로 V.I.P. 를 초대",
      refuse = "적당한 핑계로 V.I.P. 를 회피",
    },
    vip_name = "%s 이(가) 당신의 병원을 방문하고 싶어합니다",
  },
  vip_visit_result = {
    telegram = "전문!",
    remarks = {
      good = {
        [1] = "괜찮게 운영되는 병원이군요. 초대해 주셔서 감사합니다.",
        [2] = "흠. 확실히 나쁘지 않은 의료 시설이로군요.",
        [3] = "좋은 병원을 방문하게 되어 즐거웠습니다. 이제 저와 함께 괜찮은 카레라도 드실 분?",
      },
      super = {
        [1] = "훌륭한 병원이군요. 제가 다음에 많이 아프게 되면 거기로 데려다 주세요.",
        [2] = "바로 이런게 병원이라 불릴 만 하죠.",
        [3] = "굉장한 병원이네요. 몇몇 다른 병원들도 둘러보았으니 확실히 말할 수 있어요.",
      },
      bad = {
        [1] = "내가 뭐하러 방문했나 몰라요? 네시간 짜리 오페라를 보러가는 것보다도 나빴어요!",
        [2] = "거기서 본 것 때문에 메스껍네요. 그게 병원이라고요? 돼지우리에 더 가깝죠!",
        [3] = "공인으로서 이런 냄새나는 소굴을 방문해야 하는 것도 질렸어요! 이젠 그만두겠어요.",
      },
      free_build = {
        [1] = "굉장히 멋진 병원이네요! 그치만 돈 제한 없이 이렇게 운영하는게 크게 어려운일은 아니죠, 안그래요?",
        [2] = "내가 특별히 경제학자이거나 한 것은 아니지만, 나라도 이런 병원은 운영할 수 있겠네요.. 무슨말인지 알죠?",
        [3] = "훌륭하게 운영되는 병원이네요. 그치만 불경기를 조심하세요! 아, 그러고보니... 당신은 그런 걱정 할 필요가 없군요.",
      },
      mediocre = {
        [1] = "뭐, 더 심한곳도 봤는걸요. 그래도 당신 병원은 좀 개선할 필요가 있겠어요.",
        [2] = "오 이런. 아플 때 갈만한 장소는 아니로군요.",
        [3] = "솔직히 말해서 그냥 평범한 병원이네요. 사실 좀 더 낫길 바랐어요.",
      },
      very_bad = {
        [1] = "이런 지저분할 데가. 어떻게든 이 병원 문을 닫게끔 해야겠어요.",
        [2] = "이런 끔찍한 병원은 본 적이 없어요. 이런 망신이 있나요!",
        [3] = "충격적이군요. 이런건 병원이라고 할 수도 없어요! 가서 한잔 해야겠어요.",
      },
    },
    rep_boost = "당신의 평판이 올랐습니다.",
    vip_remarked_name = "당신의 병원을 방문한 뒤, %s 이(가) 말했습니다:",
    cash_grant = "당신은 현찰로 %d 의 지원금을 받았습니다.",
    rep_loss = "이로인해 당신의 평판이 떨어졌습니다.",
    close_text = "병원에 방문해 주셔서 감사합니다.",
  },
  disease_discovered_patient_choice = {
    need_to_build = "이것을 해결하기 위해서 당신은 %s 을(를) 지어야 합니다.",
    need_to_employ = "이 상황을 해결하려면 %s 을(를) 고용해야 합니다.",
    what_to_do_question = "이 환자를 어떻게 하시겠습니까?",
    guessed_percentage_name = "당신의 의료진은 환자의 상태에 대해서 추측할 수 밖에 없었습니다. 이 환자는 %d 의 확률로 %s 입니다.",
    choices = {
      send_home = "환자를 집으로 돌려보냄.",
      research = "환자를 연구실로 보냄.",
      wait = "환자를 얼마동안 병원 안에서 기다리도록 함.",
    },
    disease_name = "당신의 의료진은 새로운 병을 발견했습니다. %s 입니다.",
    need_to_build_and_employ = "당신이 %s 을(를) 짓고 %s 을(를) 고용하면 치료할 수 있습니다.",
    can_not_cure = "당신은 이 질병을 치료할 수 없습니다.",
  },
  emergency_result = {
    earned_money = "최대로 받을 수 있는 보너스 %d 중에서 당신은 %d 만큼 벌었습니다.",
    close_text = "나가려면 클릭.",
    saved_people = "당신은 %d 명의 환자를 구했습니다. (총 %d 명의 응급환자 중)",
  },
  disease_discovered = {
    discovered_name = "당신의 의료진은 새로운 병을 발견했습니다. %s 입니다.",
    need_to_employ = "이 상황을 해결하려면 %s 을(를) 고용해야 합니다.",
    need_to_build_and_employ = "당신이 %s 을(를) 짓고 %s 을(를) 고용하면 치료할 수 있습니다.",
    need_to_build = "이것을 해결하기 위해서 당신은 %s 을(를) 지어야 합니다.",
    close_text = "새로운 질병이 발견되었습니다.",
    can_cure = "당신은 이 병을 치료할 수 있습니다.",
  },
  emergency = {
    num_disease = "%d 명의 환자들이 %s 을(를) 앓고 있으며, 당장 치료해야만 합니다.",
    cure_possible_drug_name_efficiency = "당신은 이미 치료에 필요한 장비와 능력을 갖추고 있습니다. 당신은 그들에게 필요한 약을 가지고 있습니다. %s 병에 대한 당신의 약은 %d 퍼센트의 효과가 있습니다.",
    cure_not_possible_employ = "당신은 %s 을(를) 고용해야 합니다.",
    free_build = "당신이 성공하면 평판이 오르겠지만, 실패할 경우 당신의 평판은 심각하게 훼손될 것입니다.",
    cure_not_possible = "지금은 이 질병을 치료할 수 없습니다.",
    num_disease_singular = "한 명의 환자가 %s 을(를) 앓고 있으며, 당장 치료해야만 합니다.",
    cure_possible = "당신은 치료에 필요한 장비와 능력을 갖추고 있으며, 이 응급상황을 해결할 수 있을 것입니다.",
    choices = {
      accept = "예. 이 응급 환자들을 치료하겠습니다.",
      refuse = "아니오. 이 응급 상황을 해결하는 것을 거절합니다.",
    },
    location = "%s 에서 사건이 일어났습니다.",
    cure_not_possible_build = "당신은 %s 을(를) 지어야 할 것입니다.",
    cure_not_possible_build_and_employ = "당신은 %s 을(를) 짓고 %s 을(를) 고용해야 할 것입니다.",
    bonus = "이 응급 상황을 해결하면 최대 %d 의 보너스를 받을 수 있습니다. 하지만 실패한다면, 당신의 평판은 심각하게 훼손될 것입니다.",
  },
  choices = {
    decline_new_level = "얼마간 더 플레이 하기",
    accept_new_level = "다음 레벨로 넘어가기",
    return_to_main_menu = "메인 메뉴로 돌아가기",
  },
  epidemic = {
    cover_up_explanation_1 = "하지만, 당신이 전염병을 숨기고 직접 치료하려 하면, 당신은 보건 당국이 눈치채기 전에 감염된 모든 환자를 제한된 시간 내에 치료해야 합니다.",
    cover_up_explanation_2 = "만약 건강 검사관이 방문하여 전염병 치료가 여전히 진행중인 것을 알게되면, 그는 당신의 병원에 강경한 조치를 취할 수 있습니다.",
    choices = {
      cover_up = "주어진 시간 내에, 그리고 아무도 병원에서 나가기 전에 모든 감염된 환자들의 치료를 시도함",
      declare = "전염병을 선언함. 벌금을 물고 평판 하락을 감수함.",
    },
    disease_name = "당신의 의사들이 유행성의 %s 을(를) 발견했습니다.",
    declare_explanation_fine = "당신이 전염병이 돌고 있다고 선언하면, %d 의 벌금을 물고 평판이 하락하겠지만 당신의 모든 환자들은 자동으로 백신을 맞게 됩니다.",
  },
  diagnosis_failed = {
    choices = {
      send_home = "환자를 집으로 돌려보냄.",
      take_chance = "가능한 치료를 시도해봄.",
      wait = "진단 시설을 좀 더 짓는 동안 환자가 병원 안에서 기다리도록 함",
    },
    situation = "병원의 모든 진단 장비들을 동원해 보았지만 이 환자의 문제를 정확히 알아내지 못했습니다.",
    what_to_do_question = "이 환자를 어떻게 할까요?",
    partial_diagnosis_percentage_name = "%d 퍼센트의 확률로 이 환자가 %s 의 질병을 가지고 있다는 것을 알아냈습니다.",
  },
}
confirmation = {
  abort_edit_room = "현재 방을 짓거나 편집하는 중입니다. 모든 기물들이 배치되면 완료되지만, 그렇지 않은 경우 방이 삭제될 것입니다. 계속하시겠습니까?",
  return_to_blueprint = "정말로 청사진 모드로 돌아가기 원합니까?",
  restart_level = "정말로 현재 레벨을 처음부터 다시 시작하기 원합니까?",
  delete_room = "정말로 이 방을 삭제합니까?",
  quit = "종료를 선택했습니다. 정말로 게임을 끝내기 원합니까?",
  needs_restart = "이 설정을 바꾸려면 CorsixTH 를 재시작해야 합니다. 저장되지 않은 부분은 모두 잃어버리게 됩니다. 정말로 바꾸기 원합니까?",
  overwrite_save = "이 슬롯에 이미 다른 게임이 저장되어 있습니다. 정말로 덮어쓰기 원합니까?",
  sack_staff = "정말로 이 직원을 해고하기 원합니까?",
  replace_machine = "정말로 %s 기계를 $%d 의 비용으로 교체합니까?",
  maximum_screen_size = "입력한 화면 크기가 3000 x 2000 보다 큽니다. 큰 해상도도 가능하지만, 플레이할만한 프레임 수를 유지하려면 하드웨어 성능이 충분히 좋아야 합니다. 계속하시겠습니까?",
  music_warning = "게임중에 mp3 파일들을 재생하도록 하기 전에, smpeg.dll 파일이나 그에 상응하는 파일이 운영 체제에 설치되어 있어야 합니다. 그렇지 않으면 음악이 재생되지 않을 것입니다. 계속하시겠습니까?",
}
months = {
  [1] = "1월",
  [2] = "2월",
  [3] = "3월",
  [4] = "4월",
  [5] = "5월",
  [6] = "6월",
  [7] = "7월",
  [8] = "8월",
  [9] = "9월",
  [10] = "10월",
  [11] = "11월",
  [12] = "12월",
}
dynamic_info = {
  patient = {
    emergency = "응급: %s",
    guessed_diagnosis = "추측된 진단: %s ",
    diagnosis_progress = "진단 프로세스",
    actions = {
      sent_to_other_hospital = "다른 병원을 소개받음",
      prices_too_high = "가격이 너무 비싸요 - 그냥 집에 갈래요",
      no_gp_available = "당신이 진료실을 짓기를 기다리고 있음",
      waiting_for_diagnosis_rooms = "당신이 진료 시설을 더 짓기를 기다리고 있음",
      waiting_for_treatment_rooms = "당신이 치료 시설을 짓기를 기다리고 있음",
      dying = "죽어감!",
      no_diagnoses_available = "더이상 진단할 방법이 없군요 - 돌아갈래요",
      epidemic_sent_home = "검사관에 의해 돌려보내짐",
      cured = "치료됨!",
      epidemic_contagious = "전염병에 걸렸어요",
      awaiting_decision = "당신의 결정을 기다리는 중",
      sent_home = "집으로 돌려보내짐",
      fed_up = "질려서 떠나는중",
      no_treatment_available = "치료할 방법이 없네요 - 돌아갈래요",
      on_my_way_to = "%s에 가는 중",
      queueing_for = "%s에 대기 중",
    },
    diagnosed = "진단: %s ",
  },
  health_inspector = "건강 검사관",
  vip = "VIP 방문자",
  object = {
    times_used = "사용된 횟수 %d",
    queue_size = "대기열 길이 %d",
    strength = "힘 %d",
    queue_expected = "예상 대기열 %d",
  },
  staff = {
    ability = "능력",
    psychiatrist_abbrev = "정신과 의사",
    actions = {
      going_to_repair = "다음 기계를 수리하러 가는 중: %s",
      fired = "해고됨",
      waiting_for_patient = "환자를 기다리는 중",
      wandering = "그냥 돌아다니는 중",
      heading_for = "다음으로 향하는 중: %s",
    },
    tiredness = "피로도",
  },
}
introduction_texts = {
  demo =
    "데모 병원에 오신 것을 환영합니다!" ..
    "안타깝게도 데모 버전에서는 (커스텀 레벨을 제외하면) 이 레벨만 플레이할 수 있습니다. 그렇지만, 여기에도 당신을 한동안 바쁘게 할만큼의 일거리는 충분히 있습니다! " ..
    "당신은 치료를 위해 다른 종류의 시설을 필요로 하는 다양한 질병을 만나게 될 것입니다. 가끔은 응급 상황이 발생할지도 모릅니다. 그리고 당신은 연구실을 지어 새로운 시설들을 연구해야 할 것입니다. " ..
    "당신의 목표는 $100,000 를 벌고, 병원 가치를 $70,000 만큼 올리며, 평판을 700 만큼 유지하고, 방문하는 환자의 75% 이상을 완치시키는 것입니다. " ..
    "당신의 평판이 300 아래로 떨어지거나 40% 이상의 환자들을 죽게 하지 마세요. 어느 하나라도 발생하면 당신은 게임에서 지게 됩니다. " ..
    "행운을 바랍니다!",
  level1 =
    "당신의 첫 병원에 오신 것을 환영합니다!//" ..
    "접수대와 진료실을 짓고 접수원과 의사를 고용해서 이 곳이 제대로 돌아가게끔 하세요. " ..
    "그러고 나서 할일이 생길 때까지 어느 정도 기다리세요. " ..
    "정신과를 짓고 정신과 자격이 있는 의사를 고용하는 것은 좋은 생각입니다. " ..
    "약국을 짓고 간호사를 고용하는 것도 환자들을 치료하는 데 꼭 필요합니다. " ..
    "부은 머리 증상을 호소하는 환자들을 주의하세요 - 팽창실을 지으면 이 문제를 해결할 수 있을 것입니다. " ..
    "당신의 목표는 10 명의 환자를 치료하고 평판이 200 아래로 떨어지지 않도록 하는 것입니다.",
  level2 =
    "이 지역에는 더 다양한 병이 도사리고 있습니다. " ..
    "더 많은 환자들을 치료할 수 있도록 병원을 구성하고, 연구 시설을 지을 계획을 세우세요. " ..
    "당신의 시설들을 깨끗하게 유지하는 것을 잊지 말고, 평판을 최대한 높에 유지하도록 노력하세요. 당신은 늘어진 혀를 발견하게 될텐데, 늘어진 혀 클리닉을 지어서 치료할 수 있습니다. " ..
    "또한, 심전도실을 지으면 새로운 질병들을 진단하는 데 도움이 될 것입니다. " ..
    "이 두 가지 방을 짓기 위해서는 먼저 연구를 해야 합니다. 그리고 이제 당신은 병원을 확장하기 위한 새로운 토지를 구매할 수도 있습니다. 그러려면 마을 지도를 사용하세요. " ..
    "300 의 평판과, $10,000 의 은행 잔고, 그리고 40 명의 환자를 치료하는 것을 목표로 하세요.",
  level3 =
    "이번에는 부유한 지역에 당신의 병원을 세우게 될 것입니다. " ..
    "보건부는 이 곳에서 당신이 상당한 이익을 남기기를 바라고 있습니다. " ..
    "처음에는 어느 정도 평판을 쌓아야 하겠지만, 병원이 안정적으로 돌아가기 시작하면, 최대한 돈을 많이 버는 것에 집중하세요. " ..
    "또한 응급 상황이 발생할 가능성도 있습니다. " ..
    "응급 상황에는 동일한 질병을 가진 많은 사람들이 한꺼번에 몰려오게 됩니다. " ..
    "제한된 시간 내에 모두를 치료하게 되면 당신의 평판이 올라가며 큰 보너스를 받게 됩니다. " ..
    "왕자병과 같은 질병이 발생할 수 있으며, 당신은 수술실을 짓고 또한 가까운 곳에 병동을 지을 예산을 마련해 두어야 할 것입니다. " ..
    "성공하기 위해 $20,000 만큼을 버세요.",
  level4 =
    "모든 환자들을 행복하게 해주고, 그들을 가능한한 효율적으로 치료하며, 사망자의 수는 정말 최소한으로 유지하세요. " ..
    "당신의 평판이 이 레벨의 성공을 좌우하므로, 평판을 최대한 높게 유지하도록 노력하세요. " ..
    "돈에 대해서는 너무 신경쓰지 마세요. 돈은 평판이 높아지면 자연스럽게 따라오게 될 겁니다. " ..
    "또한, 당신은 이제 의사들의 능력을 향상시키기 위해 그들을 교육시키는 것도 가능합니다. " ..
    "교육받은 의사들은, 어떤 질병인지 아주 확실치 않은 환자들을 더 잘 치료할 수 있을 것입니다. " ..
    "500 이상의 평판을 달성하세요.",
  level5 =
    "여기는 가지각색의 질병들을 치료하느라 아주 분주한 병원이 될 겁니다. " ..
    "당신이 고용할 수 있는 의사들은 모두 의대를 갓 졸업한 신입들이기 때문에, 교육실을 지어서 적정 수준으로 훈련시키는 것이 필수입니다. " ..
    "의사들을 교육할 수 있는 딱 세 명의 전문의들만 주어져 있으므로, 이들을 행복하게 해 주세요. " ..
    "또 유념해야할 것은, 병원이 샌 안드로이드 단층 위에 지어져 있다는 것입니다. " ..
    "다시말해, 이 병원은 언제나 지진의 위험에 노출되어 있습니다. " ..
    "지진은 당신의 기계들을 손상시키고, 병원을 원만하게 운영하는 것을 방해할 것입니다. " ..
    "성공하려면 평판을 400 만큼 올리고, $50,000 를 예금하세요. 또한, 200 명의 환자를 치료하세요.",
  level6 =
    "당신의 모든 지식을 동원해서, 적절한 이윤을 남기면서도 병약한 대중이 가진 온갖 질병들을 치료할 수 있도록 원만하게 운영되는 병원을 지으세요. " ..
    "이 곳 주변의 공기는 특별히 세균과 질병을 옮기는 데 좋다는 것을 알아두세요. " ..
    "병원을 정말 구석구석 깨끗하게 유지하지 않으면, 환자들 사이에서 아주 심각한 전염병이 도는 것을 보게 될 것입니다. " ..
    "돈을 $150,000 만큼 벌고, 병원의 가치가 $140,000 이상이 되도록 하세요.",
  level7 =
    "이번에는 당신의 병원이 보건부의 철저한 감시 하에 놓여있게 될 것이므로, 당신이 돈을 충분히 많이 벌고 있다는 것을 은행 잔고로 보여주고, 평판을 올리도록 하세요. " ..
    "환자들이 사망하는 것은 최대한 피해야 합니다 - 사업하는데 전혀 도움이 안되니까요. " ..
    "최고의 직원들을 고용하도록 하고, 필요한 장비들을 갖추도록 하세요. " ..
    "600 의 평판과 $200,000 의 잔고를 얻으세요.",
  level8 =
    "얼마나 비용대비 효율이 높은 병원을 짓는 것은 당신에게 달렸습니다. " ..
    "이 주변 주민들은 상당히 부유한 편이니, 할 수 있는 만큼 쥐어 짜내세요. " ..
    "사람들을 치료하는 것도 좋지만, 돈을 모으는 것이 목표라는 것을 기억해야 합니다. " ..
    "이 아픈 사람들을 아주 빈털터리로 만들어 버리세요. " ..
    "이 레벨을 완료하려면 재산을 $300,000 만큼 쌓아야 합니다.",
  level9 =
    "보건부의 재산을 좀 불려주고 장관님께 리무진도 한 대 뽑아드렸으니, 이제 다시 몸이 아픈 사람들을 잘 돌보는 훌륭한 병원을 짓는 일을 재개할 수 있습니다. " ..
    "여기서는 굉장히 다양한 문제들을 마주치게 될 것입니다. " ..
    "당신이 충분히 훈련받은 직원들과 필요한 시설들을 갖춘다면, 이 천사 같은 사람들을 회복시켜줄 수 있습니다. " ..
    "당신의 병원 가치가 $200,000 이상이 되어야 하고, 은행에 $400,000 만큼의 돈이 있어야 합니다. " ..
    "이것 보다 적다면 이 레벨을 클리어 하는 것은 어림도 없습니다.",
  level10 =
    "이 동네에 창궐하는 질병들을 치료하는 것 뿐만 아니라, 보건부는 당신의 의약품의 효용성을 높일 것을 요구합니다. " ..
    "보건 검사관인 Ofsick 으로부터 불만이 접수되었기 때문에, 좋은 인상을 주기 위해서는 당신의 약들이 엄청나게 잘 듣도록 만들어야 합니다. " ..
    "또한, 당신의 병원이 비난 받지 않도록 하는 것도 잊지 마세요. 사망자 수를 낮게 유지하세요. " ..
    "힌트를 주자면, 젤리통을 지을 공간을 미리 확보해 두는 것이 좋을 겁니다. " ..
    "모든 약의 효율을 80% 이상으로 끌어 올리고, 650 의 평판과 $500,000 을 벌면 승리할 수 있습니다.",
  level11 =
    "당신은 궁극의 병원을 지을 기회를 얻었습니다. " ..
    "이 곳은 굉장히 이름난 지역이고, 보건부는 가능한 최고의 병원을 보고 싶어 합니다. " ..
    "우리는 당신이 큰 돈을 벌고, 엄청나게 높은 평판을 얻으며 모든 질병들을 치료할 있기를 기대합니다. " ..
    "이건 굉장히 중요한 일입니다. " ..
    "성공하기 위해서는 당신은 특별한 사람이 되어야 할 겁니다. " ..
    "또 주의할 것은, 이 지역에서 UFO 가 여러번 목격되었다는 것입니다. 당신의 직원들이 뜻밖의 방문에 대비할 수 있도록 해 주세요. " ..
    "당신의 병원은 $240,000 이상의 가치를 해야 하고, 은행에 $500,000 의 돈과 700 의 평판을 얻어야 할 겁니다.",
  level12 =
    "당신은 최고의 도전에 직면해 있습니다. " ..
    "지금까지의 당신의 성공에 크게 인상을 받은 보건부가 당신을 최고의 자리에 앉혀주었습니다. 그들은 당신이 또다른 궁극의 병원을 짓고, 막대한 돈을 벌며 놀라운 평판을 얻기를 원합니다. " ..
    "또한 당신이 매입할 수 있는 모든 부지를 사들이고, 모든 질병을 치료하며 (정말 '모든' 질병 말이에요), 모든 상을 수상하기를 원합니다. " ..
    "도전해 볼 준비가 되었나요?" ..
    "$650,000 을 벌고, 750 명의 환자를 치료하며, 800 의 평판을 얻어 이 레벨을 클리어 하세요.",
  level13 =
    "병원 책임자로서의 놀라운 능력을 보고 '비밀 특수 관청'의 '비밀 특수 부서'에서 당신에게 관심을 가지기 시작했습니다. " ..
    "그들이 당신에게 주는 보너스가 있습니다. 쥐가 득실거리는 병원에서 쥐를 없애야 합니다. " ..
    "당신은 잡역부들이 더러운 것들을 치우기 전에 최대한 쥐들을 쏘아 맞춰야 합니다. " ..
    "준비 되셨나요?",
  level14 =
    "또다른 도전입니다 - 전혀 예상치 못한 놀라운 병원을 짓는 것이죠. " ..
    "이것을 성공한다면, 당신은 승자 중의 승자로 기억될 것입니다. " ..
    "쉬운 일이 될 것이라고 기대하지 마세요. 당신이 마주하게 될 가장 어려운 과제가 될 테니까요. " ..
    "행운을 빕니다!",
  level15 =
    "좋아요, 그게 바로 병원을 운영하는 기본적인 방법입니다.//" ..
    "당신의 의료진은 특정 환자들을 진단하기 위해서 도움을 필요로 할 수 있습니다." ..
    "일반 진단실 등과 같은 진단 설비들을 더 많이 지어서 의료진이 정확한 진단을 할 수 있도록 도울 수 있습니다.",
  level16 =
    "환자들을 진단한 후에는, 치료 시설과 클리닉 등을 지어서 환자들을 치료해야 합니다. " ..
    "약국에서부터 시작하는 것이 좋습니다. 약국에서 제대로 약을 조제하기 위해서는 간호사도 필요할 것입니다.",
  level17 =
    "마지막 당부입니다 - 당신의 평판에서 눈을 떼지 마세요. 평판이 높아야 더 먼 곳의 환자들을 끌어올 수 있습니다. " ..
    "너무 많은 환자들을 죽게 하지 않고 적절히 행복도를 유지해 준다면 이 레벨을 클리어 하는 데 큰 문제는 없을 것입니다!//" ..
    "이제 모든 것은 당신에게 달렸습니다. 행운을 빌어요.",
}
transactions = {
  severance = "퇴직금",
  research = "연구비",
  eoy_trophy_bonus = "연말 기념 보너스",
  buy_object = "기물 구매",
  cure_colon = "치료:",
  epidemy_coverup_fine = "전염병 은폐 벌금",
  final_treat_colon = "최종 처방:",
  jukebox = "수입: 주크박스",
  loan_interest = "대출 이자",
  overdraft = "당좌 대월 이자",
  wages = "급여",
  loan_repayment = "대출 상환",
  personal_bonus = "개인 보너스 지급",
  drug_cost = "약물 비용",
  cure = "치료",
  heating = "난방비",
  treat_colon = "처방:",
  compensation = "정부 보상금",
  epidemy_fine = "전염병 벌금",
  buy_land = "토지 매입",
  research_bonus = "연구 보너스",
  general_bonus = "일반 보너스 지급",
  deposit = "처방 보증금",
  eoy_bonus_penalty = "연말 보너스/벌금",
  cheat = "돈 치트",
  drinks = "수입: 음료 자판기",
  vaccination = "백신",
  advance_colon = "가불:",
  vip_award = "VIP 현금 상여",
  hire_staff = "직원 고용",
  bank_loan = "은행 이자",
  machine_replacement = "기계 교환 비용",
  emergency_bonus = "응급 상황 보너스 지급",
  build_room = "방 건설",
  insurance_colon = "보험:",
  sell_object = "기물 판매",
}
object = {
  chair = "의자",
  litter = "쓰레기",
  sofa = "소파",
  operating_table = "수술대",
  bed2 = "침대",
  bench = "벤치",
  scanner = "스캐너",
  couch = "침상",
  blood_machine = "혈액 분석기",
  table1 = "탁자",
  video_game = "비디오 게임",
  lamp = "전등",
  op_sink2 = "세면대",
  door = "문",
  auto_autopsy = "자동부검기",
  reception_desk = "접수대",
  hair_restorer = "모발 재생기",
  projector = "영사기",
  crash_trolley = "운반차",
  tv = "TV",
  ultrascanner = "울트라스캐너",
  surgeon_screen = "외과 의사용 스크린",
  litter_bomb = "쓰레기 폭탄",
  inflator = "팽창기",
  table2 = "탁자",
  desk = "책상",
  pool_table = "당구대",
  x_ray_viewer = "X-레이 뷰어",
  radiation_shield = "방사선 차폐기",
  bed = "침대",
  swing_door2 = "여닫이 문",
  console = "콘솔",
  op_sink1 = "세면대",
  bookcase = "책장",
  drinks_machine = "자판기",
  comfortable_chair = "안락의자",
  skeleton = "해골",
  computer = "컴퓨터",
  bin = "쓰레기통",
  pharmacy_cabinet = "약장",
  radiator = "라디에이터",
  cast_remover = "깁스 제거기",
  atom_analyser = "원자 분석기",
  plant = "화초",
  jelly_moulder = "젤리 주형기",
  cardio = "심전도",
  toilet = "변소",
  electrolyser = "전기분해기",
  fire_extinguisher = "소화기",
  bed3 = "침대",
  swing_door1 = "여닫이 문",
  lecture_chair = "강의 의자",
  screen = "스크린",
  toilet_sink = "세면대",
  shower = "샤워",
  gates_of_hell = "지옥의 문",
  entrance_right = "우측 문",
  entrance_left = "좌측 문",
  slicer = "절단기",
  dna_fixer = "DNA-정정기",
  x_ray = "X-레이",
  cabinet = "서류 캐비넷",
}
letter = {
  [1] = {
    [1] = "%s 님에게//",
    [2] = "멋지군요! 당신은 이 병원을 운영하는 일을 훌륭하게 해냈습니다. 우리 보건부 고위 인사들은 당신이 더 큰 프로젝트를 진행할 생각이 있는지 궁금합니다. 당신에게 딱 맞는 자리가 있습니다. 연봉은 $%d 만큼 드릴 수 있습니다. 생각해 보시고 연락 부탁드립니다.//",
    [3] = "%s 병원에서 일해볼 생각이 있습니까?",
  },
  [2] = {
    [1] = "%s 님에게//",
    [2] = "아주 좋아요! 당신은 병원을 뛰어나게 발전시켰습니다. 당신이 다른 풍경과 새로운 도전을 원한다면, 우리가 찾아낸 곳이 있습니다. 이 제의를 반드시 수락해야 하는 것은 아니지만, 수락할만한 가치는 있을 것입니다. 급여는 $%d 입니다.//",
    [3] = "%s 병원의 자리를 원하십니까?",
  },
  [3] = {
    [1] = "%s 님에게//",
    [2] = "이 병원에서 재직하는 중 당신은 대단히 큰 성공을 거두었습니다. 우리는 당신의 가능성을 높이 평가하며, 다른 곳에서의 포지션을 제의하고자 합니다. 연봉은 $%d 가 될 것이고, 당신이 이 새로운 곳에서의 도전을 즐기리라고 믿습니다.//",
    [3] = "%s 병원에서의 일하고 싶습니까?",
  },
  [4] = {
    [1] = "%s 님에게//",
    [2] = "축하드립니다! 보건부의 우리는 병원을 운영하는 당신의 능력에 큰 인상을 받고 있습니다. 당신은 확실히 보건계의 큰 손입니다. 하지만 당신이 조금 더 어려운 일을 하기 원하지 않을까 싶군요. 당신은 $%d 의 급여를 받게 되겠지만, 결정은 당신 몫입니다.//",
    [3] = "%s 병원에서 일하는 것에 흥미가 있습니까?",
  },
  [5] = {
    [1] = "%s 님에게//",
    [2] = "오랜만이군요. 이 매력적인 병원에 남기 원하는 당신의 생각은 존중하지만, 그것에 대해 재고해보셨으면 합니다. 당신이 우리가 지정하는 다른 병원으로 옮겨서 원만하게 운영해 낸다면 $%d 의 높은 급여를 드릴 의향이 있습니다.//",
    [3] = "%s 병원으로 지금 이직하시겠습니까?",
  },
  [6] = {
    [1] = "%s 님에게//",
    [2] = "안녕하세요. 당신이 이렇게 부드럽게 돌아가는 멋진 병원에 있는 것을 얼마나 행복하게 여기는지는 잘 알지만, 우리는 당신의 커리어를 좀 더 키우는 것이 좋을 것이라고 생각합니다. 물론 이직하실 경우 $%d 만큼의 돈은 드리겠습니다. 고려해볼만 할 겁니다.//",
    [3] = "%s 병원의 자리를 수락하시겠습니까?",
  },
  [7] = {
    [1] = "%s 님에게//",
    [2] = "안녕하십니까! 보건부는 당신이 지금의 병원에 머물겠다는 생각을 재고해볼 여지가 있는지 궁금합니다. 당신의 멋진 병원은 높이 평가하고 있지만, $%d 의 급료를 받고 더 도전적인 일을 해보는 것은 어떨까 하고 생각합니다.//",
    [3] = "%s 병원의 포지션을 수락하시겠습니까?",
  },
  [8] = {
    [1] = "%s 님에게//",
    [2] = "안녕하세요. 지난 번에 당신은 $%d 의 급료와 최상의 조건으로 이직하겠냐는 제안을 거절했습니다. 하지만 이 제안을 다시 고려해보실 것을 부탁 드립니다. 단언컨대, 당신에게 꼭 맞는 완벽한 자리입니다.//",
    [3] = "%s 병원에서 일하라는 제안을 수락하시겠습니까? 제발요?",
  },
  [9] = {
    [1] = "%s 님에게//",
    [2] = "당신은 변화무쌍한 의료계 역사상 최고의 병원 책임자로서의 자신의 능력을 증명했습니다. 이런 중대한 업적에 대한 보상의 의미로, 당신을 모든 병원의 최고 책임자로 모시려 합니다. 이것은 명예로운 직책이며, $%d 의 연봉이 보장됩니다. 당신을 위해 사람들이 색종이 테이프를 뿌리며 행진할 것이고, 당신이 어디를 가든지 사람들이 감사를 표할 것입니다.//",
    [3] = "당신이 이룩한 모든 것에 감사합니다. 당신이 은퇴 생활을 즐기기를 바랍니다.//",
    [4] = "",
  },
  [10] = {
    [1] = "%s 님에게//",
    [2] = "우리가 배정한 모든 병원을 성공적으로 운영한 것을 축하드립니다. 이러한 놀라운 성과로 볼 때, 당신은 세계의 모든 도시들을 자유롭게 방문할 자격이 있습니다. 당신은 $%d 만큼의 연금과 리무진을 방게 될 것이며, 다만 우리가 당신에게 원하는 것은 각 도시들을 여행하며 당신을 동경하는 대중을 만나고, 여기 저기에 있는 병원을 고무시키는 것입니다.//",
    [3] = "우리는 당신을 자랑스럽게 생각합니다. 단 한 사람도 인명을 구하는 일에 헌신한 당신의 노력에 감사를 표하지 않는 사람이 없습니다.//",
    [4] = "",
  },
  [11] = {
    [1] = "%s 님에게//",
    [2] = "귀하의 커리어는 타의 모범이 되며, 우리 모두에게 영감을 줍니다. 그렇게 많은 병원을 운영하면서 모든 일을 훌륭히 처리해낸 것에 감사를 표합니다. 우리는 당신에게 평생 $%d 의 급료를 지급하고자 하며, 단 한가지 부탁드리는 것은 공식 오픈카를 타고 이 도시 저 도시를 여행하며, 어떻게 그 짧은 기간동안 그렇게 많은 일을 이룰 수 있었는지 강연을 해주셨으면 합니다.//",
    [3] = "당신은 바른 생각을 가진 모든 사람들의 귀감이며, 한 사람도 예외 없이 당신을 귀한 재산으로 여기고 있습니다.//",
    [4] = "",
  },
  [12] = {
    [1] = "%s 님에게//",
    [2] = "모세 이후의 최고의 병원 책임자로서의 당신의 커리어가 끝을 향해가고 있습니다. 그러나, 의료계에서의 당신의 영향력은 지대하며, 보건부는 당신에게 $%d 의 급료를 지급하고 우리를 대표해서 여기 저기에서 행사에 참여하고 토크쇼 등에 출연해주셨으면 합니다. 온 세계가 당신으로 인해 떠들썩한 이 때에, 우리를 홍보하는 데 큰 도움이 될 겁니다!//",
    [3] = "이 제안을 꼭 수락해 주세요. 크게 어려운 일은 아닐 것이고, 승용차도 지급할 것이며 어디로 가시든지 경찰의 에스코트가 동반될 것입니다.//",
    [4] = "",
  },
  custom_level_completed = "잘했습니다! 이 커스텀 레벨의 목표를 모두 달성했습니다!",
  dear_player = "%s 님에게",
  return_to_main_menu = "메인 메뉴로 돌아갑니까, 아니면 계속 플레이 합니까?",
}
high_score = {
  categories = {
    deaths = "사망 수",
    total_value = "총 가치",
    money = "돈",
    cures = "치료 수",
    visitors = "방문자 수",
    staff_number = "직원 수",
    cure_death_ratio = "치료 사망 비율",
    patient_happiness = "고객 만족도",
    staff_happiness = "직원 만족도",
    salary = "높은 임금",
    clean = "청결함",
  },
  player = "플레이어",
  score = "점수",
  best_scores = "명예의 전당",
  worst_scores = "수치의 전당",
  killed = "죽임",
}
menu_file_save = {
  [1] = "  게임 1  ",
  [2] = "  게임 2  ",
  [3] = "  게임 3  ",
  [4] = "  게임 4  ",
  [5] = "  게임 5  ",
  [6] = "  게임 6  ",
  [7] = "  게임 7  ",
  [8] = "  게임 8  ",
}
build_room_window = {
  pick_department = "범주를 선택하세요",
  pick_room_type = "방 종류를 선택하세요",
  cost = "가격: ",
}
menu = {
  debug = "  디버그  ",
  display = "  화면 표시  ",
  file = "  파일  ",
  options = "  옵션  ",
  charts = "  도표  ",
}
