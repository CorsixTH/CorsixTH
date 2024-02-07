--[[ Copyright (c) 2012 lwglwsss

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

-- Note: This file contains UTF-8 text. Make sure your editor is set to UTF-8.

Font("unicode")
Language("简体中文", "Chinese (simplified)", "zh(s)", "chi(s)", "zho(s)")
Inherit("english")
Encoding(utf8)

-- Search OVERRIDE and NEW STRINGS for workspace

-------------------------------  OLD STRINGS  -------------------------------
-- Generated from official Simplified Chinese datapack, do not modify!
-- Use OVERRIDE if errors present

staff_class = {
  nurse                 = "护士",
  doctor                = "医生",
  handyman              = "清洁工",
  receptionist          = "接待员",
  surgeon               = "外科医生",
}

staff_title = {
  receptionist          = "接待员",
  general               = "普通人", -- unused?
  nurse                 = "护士",
  junior                = "实习医生",
  doctor                = "医生",
  surgeon               = "外科医生",
  psychiatrist          = "精神病医生",
  consultant            = "专家",
  researcher            = "研究员",
}

object = {
  desk                  = "办公桌",
  cabinet               = "文件柜",
  door                  = "房门",
  bench                 = "长椅",
  table1                = "桌子", -- unused object
  chair                 = "椅子",
  drinks_machine        = "饮料机",
  bed                   = "床",
  inflator              = "充气机",
  pool_table            = "台球桌",
  reception_desk        = "接待台",
  table2                = "桌子", -- unused object & duplicate
  cardio                = "心电图仪",
  scanner               = "扫描仪",
  console               = "控制台",
  screen                = "屏风",
  litter_bomb           = "垃圾炸弹",
  couch                 = "长沙发椅",
  sofa                  = "沙发",
  crash_trolley         = "诊断仪器小推车",
  tv                    = "电视机",
  ultrascanner          = "超级扫描仪",
  dna_fixer             = "DNA 修复装置",
  cast_remover          = "石膏剥离装置",
  hair_restorer         = "毛发恢复机",
  slicer                = "舌头治疗机",
  x_ray                 = "X 光机",
  radiation_shield      = "射线防护",
  x_ray_viewer          = "X 光透视仪",
  operating_table       = "手术台",
  lamp                  = "灯", -- unused object
  toilet_sink           = "洗手池",
  op_sink1              = "洗手池",
  op_sink2              = "洗手池",
  surgeon_screen        = "外科屏风",
  lecture_chair         = "教室座位",
  projector             = "放映机",
  bed2                  = "床", -- unused duplicate
  pharmacy_cabinet      = "医药柜",
  computer              = "计算机",
  atom_analyser         = "原子分析仪",
  blood_machine         = "血液机器",
  fire_extinguisher     = "灭火器",
  radiator              = "暖气",
  plant                 = "植物",
  electrolyser          = "电分解机器",
  jelly_moulder         = "胶桶",
  gates_of_hell         = "地狱之门",
  bed3                  = "床", -- unused duplicate
  bin                   = "垃圾桶",
  toilet                = "厕所",
  swing_door1           = "转门",
  swing_door2           = "转门",
  shower                = "淋浴",
  auto_autopsy          = "自动验尸仪",
  bookcase              = "书柜",
  video_game            = "电视游戏",
  entrance_left         = "右入口",
  entrance_right        = "左入口",
  skeleton              = "骨骼模型",
  comfortable_chair     = "舒适座椅",
}

pay_rise = {
  definite_quit = "不论您做什么都无法留住我了。",
  regular = {
    "我真的太累了。如果您不希望我辞职的话，请让我好好休息，并增加工资%d 。", -- %d (rise)
    "我真的太累了。我需要休息，以及增加工资%d 。立即答应，你这个暴君。", -- %d (rise) %d (new total)
    "好吧。我在这里工作就象一只狗一样。给我奖金%d 我就还留在这个医院里。", -- %d (rise)
    "我很不快乐。我要求增加工资%d ，使我的工资达到%d ，否则我就不干了。", -- %d (rise) %d (new total)
    "我的父母告诉我医学专家的待遇是很高的。因此，请给我加薪%d ，否则我将辞职去做电脑游戏。", -- %d (rise)
    "我已经受够了。请调整我的工资到合理程度。我希望加薪%d 。", -- %d (rise)
  },
  poached = "%s 答应给我工资%d 。如果您无法达到这个数目，那么我就要跳槽了。", -- %d (new total) %s (competitor)
}

place_objects_window = {
  drag_blueprint                = "拉伸蓝图直到您满意的尺寸",
  place_door                    = "设置房门",
  place_windows                 = "请设置一些窗户，点击鼠标表示确定",
  place_objects                 = "可以设置并移动这些物品直到满意为止，随后再确定",
  confirm_or_buy_objects        = "您可以确认该房间，或买入或移动其中的一些物品",
  pick_up_object                = "点击物品可以将其拾起，也可以选择不同的选项",
  place_objects_in_corridor     = "将物品放在走廊上",
}

misc = {
  grade_adverb = {
    mildly     = "柔和的",
    moderately = "适当的",
    extremely  = "极端的",
  },
  done  = "完成",
  pause = "暂停",

  send_message     = "向玩家%d 发送信息", -- %d (player number)
  send_message_all = "向所有玩家发送信息",

  save_success = "游戏存档成功",
  save_failed  = "错误：无法存档",

  hospital_open = "医院开门",
  out_of_sync   = "游戏失去同步",

  load_failed  = "存档游戏没有被读取",
  low_res      = "低清晰度",
  balance      = "难度选择：",

  mouse        = "老鼠",
  force        = "力量",
  cant_treat_emergency = "你的医院尚未了解这种新的疾病。请下次再试。",
}

diseases = {
  golf_stones = {
    cure = "治疗－由两名外科医生执行手术。",
    name = "高尔夫症",
    cause = "病因－吸入了高尔夫球内部的有毒气体。",
    symptoms = "症状－神经错乱且胡言乱言。",
  },
  uncommon_cold = {
    cure = "治疗－服用药房配制的特效药。",
    name = "感冒",
    cause = "病因－吸进了空气中的灰尘。",
    symptoms = "症状－流鼻涕，打喷嚏。",
  },
  third_degree_sideburns = {
    cure = "治疗－精神病医生必须使用最新科技，使病人认识到这些奇装异服都是垃圾。",
    name = "络腮胡子",
    cause = "病因－向往20 世纪70 年代。",
    symptoms = "症状－长头发，全身闪闪发光。",
  },
  heaped_piles = {
    cure = "治疗－服用药剂。",
    name = "痔疮",
    cause = "病因－站立在水冷却器旁边。",
    symptoms = "症状－病人感觉就象坐在大理石上。",
  },
  broken_heart = {
    cure = "治疗－由两名外科医生打开病人的胸腔，轻轻地修补其心脏缺陷。",
    name = "破碎的心",
    cause = "病因－一些人比病人富有，年轻，瘦。",
    symptoms = "症状－痛哭流涕。",
  },
  kidney_beans = {
    cure = "治疗－由两名外科医生执行手术。",
    name = "肾豆",
    cause = "病因－饮料中加入了大量冰块。",
    symptoms = "症状－疼痛且经常去厕所。",
  },
  pregnancy = {
    cure = "治疗－在手术中心中将婴儿取出，洗净送到病人面前。",
    name = "产妇",
    cause = "病因－怀孕",
    symptoms = "症状－不断增大的啤酒肚。",
  },
  chronic_nosehair = {
    cure = "治疗－口服令人厌恶的毛发去除剂，该药剂由护士在药房配制。",
    name = "鼻毛过多症",
    cause = "病因－经常对不如自己的人嗤之以鼻。",
    symptoms = "症状－鼻毛过长过多，快成鸟巢了。",
  },
  infectious_laughter = {
    cure = "治疗－一位精神病医生必须让病人了解其当前严重的病情。",
    name = "狂笑症",
    cause = "病因－观看古典喜剧。",
    symptoms = "症状－不住狂笑。",
  },
  the_squits = {
    cure = "治疗－服用粘性药剂修补病人的内脏。",
    name = "呕吐",
    cause = "病因－吃了变质的比萨饼。",
    symptoms = "症状－噢。想必您也可以猜得到。",
  },
  fractured_bones = {
    cure = "治疗－将已打好的石膏使用仪器去除。",
    name = "骨折",
    cause = "病因－从高处摔到混凝土地面上。",
    symptoms = "症状－剧痛且无法使用四肢。",
  },
  general_practice = {
    name = "一般诊断",
  },
  ruptured_nodules = {
    cure = "治疗－两名称职的外科医生必须使用稳定的双手切除肿瘤。",
    name = "肿瘤",
    cause = "病因－在寒冷的季节中跳跃。",
    symptoms = "症状－无法舒适地坐下。",
  },
  sweaty_palms = {
    cure = "治疗－精神病医生使病人走出心理误区。",
    name = "手心出汗症",
    cause = "病因－害怕找工作时的面试。",
    symptoms = "症状－当与病人握手时，感觉就象攥着一块吸满了水的海绵。",
  },
  diag_cardiogram = {
    name = "心电图仪诊断",
  },
  slack_tongue = {
    cure = "治疗－将舌头放入舌头切片机中，将快速有效地得到治疗。",
    name = "舌头松弛症",
    cause = "病因－过多地讨论肥皂剧。",
    symptoms = "症状－舌头增长到正常的5 倍。",
  },
  diag_general_diag = {
    name = "一般诊断",
  },
  broken_wind = {
    cure = "治疗－服用药房配制的特效药。",
    name = "臭屁症",
    cause = "病因－饭后使用健身房的脚踏车进行运动。",
    symptoms = "症状－使身后的人感到极度的不舒服。",
  },
  invisibility = {
    cure = "治疗－在药房喝下彩色液体，将很快使病人恢复正常。",
    name = "隐身",
    cause = "病因－被有放射性的蚂蚁叮咬。",
    symptoms = "症状－病人本身感觉不到任何不适，并常常和家里人开玩笑。",
  },
  baldness = {
    cure = "治疗－使用仪器将头发缝合到病人的头上。",
    name = "秃顶",
    cause = "病因－向公众说谎话。",
    symptoms = "症状－脑门发亮，十分困窘。",
  },
  sleeping_illness = {
    cure = "治疗－由护士配制一剂威力强大的兴奋剂给病人服用。",
    name = "嗜睡症",
    cause = "病因－内分泌失调",
    symptoms = "症状－无论走到那里都想睡觉。",
  },
  gastric_ejections = {
    cure = "治疗－服用特殊凝固剂从而阻止呕吐。",
    name = "反胃症",
    cause = "病因－吃了过辣的四川菜。",
    symptoms = "症状－半消化的食物被病人不时吐出。",
  },
  transparency = {
    cure = "治疗－服用药房配制的特殊清凉彩色冲剂就可以治愈疾病。",
    name = "透明症",
    cause = "病因－舔了打开的容器的铅箔上的酸乳酪。",
    symptoms = "症状－肌肉变得透明，对光敏感。",
  },
  corrugated_ankles = {
    cure = "治疗－服用少量毒草和香料制成的药剂，从而打通关节。",
    name = "脚踝弯曲",
    cause = "病因－驾驶时间过长。",
    symptoms = "症状－脚踝感觉不舒服。",
  },
  diag_ultrascan = {
    name = "超级扫描仪诊断",
  },
  serious_radiation = {
    cure = "治疗－病人必须被放置在净化淋浴器内彻底清洗。",
    name = "放射病",
    cause = "病因－不小心错误吞吃了含有钚元素的口香糖。",
    symptoms = "症状－病人感到非常非常的不舒服。",
  },
  iron_lungs = {
    cure = "治疗－两名外科医生在手术中心执行手术。",
    name = "铁肺",
    cause = "病因－城市中浑浊的空气。",
    symptoms = "症状－浑身难受。",
  },
  bloaty_head = {
    cure = "治疗－打破肿胀脑袋，并使用充气机使脑袋恢复正常。",
    name = "头部肿胀",
    cause = "病因－闻到了坏乳酪并喝了不干净的雨水。",
    symptoms = "症状－非常不舒服。",
  },
  diag_scanner = {
    name = "扫描仪诊断",
  },
  hairyitis = {
    cure = "治疗－使用电分解机器去掉毛发并填补遗留的毛孔。",
    name = "多毛症",
    cause = "病因－在月光下停留过长时间。",
    symptoms = "症状－嗅觉特别灵敏。",
  },
  diag_x_ray = {
    name = "X 光诊断",
  },
  fake_blood = {
    cure = "治疗－只有精神病医生才能使病人安静下来。",
    name = "假血",
    cause = "病因－病人常常开玩笑。",
    symptoms = "症状－流出红色液体。",
  },
  jellyitis = {
    cure = "治疗－将病人浸入到胶桶中。",
    name = "失衡症",
    cause = "病因－日常饮食含有过多的胶状物并完成太多的练习。",
    symptoms = "症状－走路摇摇晃晃并不时摔倒。",
  },
  alien_dna = {
    cure = "治疗－利用仪器快速清除病人体内的DNA 。",
    name = "外星人DNA",
    cause = "病因－拥有了外星人的DNA",
    symptoms = "症状－逐渐蜕变成外星人并阴谋摧毁我们的城市。",
  },
  gut_rot = {
    cure = "治疗－由护士配制药剂，交给病人服下。",
    name = "内脏腐烂",
    cause = "病因－喝了太多的威士忌酒。",
    symptoms = "症状－不咳嗽，但胃壁也没有了。",
  },
  king_complex = {
    cure = "治疗－由精神病医生告诉病人其荒谬的举止。",
    name = "猫王综合症",
    cause = "病因－猫王的思想进入病人大脑并取而代之。",
    symptoms = "症状－穿着举止怪异。",
  },
  tv_personalities = {
    cure = "治疗－一位精神病医生必须使病人有信心卖掉电视机，而购买收音机。",
    name = "电视病",
    cause = "病因－日间电视节目。",
    symptoms = "症状－产生错觉，以为自己正在表演。",
  },
  diag_blood_machine = {
    name = "血液机器诊断",
  },
  discrete_itching = {
    cure = "治疗－病人喝下胶状糖浆阻止皮肤发痒。",
    name = "搔痒症",
    cause = "病因－昆虫叮咬。",
    symptoms = "症状－到处乱抓，引起全身发炎。",
  },
  unexpected_swelling = {
    cure = "治疗－由两名外科医生实行手术。",
    name = "肿胀",
    cause = "病因－意外事件。",
    symptoms = "症状－肿胀。",
  },
  autopsy = {
    name = "验尸",
  },
  diag_ward = {
    name = "病房诊断",
  },
  spare_ribs = {
    cure = "治疗－由两名外科医生执行手术。",
    name = "瘦骨",
    cause = "病因－坐在冰冷的石地板上。",
    symptoms = "症状－胸部感觉不适。",
  },
  diag_psych = {
    name = "精神病诊断",
  },
}

competitor_names = {
  "神谕",
  "巨人",
  "黑尔",
  "马笛维克",
  "冬青树",
  "沉思",
  "禅",
  "里昂",
  "玛文",
  "晶体",
  "母亲",
  "洁尼",
  "CORSIX", -- Main developers just for fun.
  "ROUJIN",
  "EDVIN",
  "萨姆",
  "查理",
  "亚瑟",
  "马格尼斯",
  "赛尔",
  "约书亚",
  "丹尼尔",
  "奥利文",
  "尼克",
}

months = {
  "1 月",
  "2 月",
  "3 月",
  "4 月",
  "5 月",
  "6 月",
  "7 月",
  "8 月",
  "9 月",
  "10 月",
  "11 月",
  "12 月",
}

-- "Null", -- not needed?
-- "银行帐户", -- unused(?)
-- "现金", -- unused(?)

graphs = {
  money_in   = "收入",
  money_out  = "支出",
  wages      = "工资",
  balance    = "现金",
  visitors   = "访问者",
  cures      = "治愈",
  deaths     = "死亡",
  reputation = "声望",

  time_spans = {
    "1 年",
    "12 年",
    "48 年",
  }
}

transactions = {
  --null               = "Null", -- not needed
  wages                = "工资",
  hire_staff           = "雇佣员工",
  buy_object           = "购买物品",
  build_room           = "建造房屋",
  cure                 = "治愈",
  buy_land             = "购买土地",
  treat_colon          = "治疗",
  final_treat_colon    = "最终治疗",
  cure_colon           = "治疗：",
  deposit              = "治疗收入",
  advance_colon        = "进步：",
  research             = "研究花费",
  drinks               = "收入：饮料机",
  jukebox              = "收入：投币音乐盒", -- unused
  cheat                = "骗钱",
  heating              = "供暖费",
  insurance_colon      = "保险费：",
  bank_loan            = "银行贷款",
  loan_repayment       = "贷款偿还",
  loan_interest        = "贷款利率",
  research_bonus       = "研究奖金",
  drug_cost            = "药品花费",
  overdraft            = "透支利率",
  severance            = "隔离花费",
  general_bonus        = "支付一般奖金",
  sell_object          = "卖出物品",
  personal_bonus       = "支付个人奖金",
  emergency_bonus      = "支付紧急事件奖金",
  vaccination          = "接种疫苗",
  epidemy_coverup_fine = "隐瞒传染病罚款",
  compensation         = "政府赔偿金",
  vip_award            = "贵宾现金奖励",
  epidemy_fine         = "传染病罚款",
  eoy_bonus_penalty    = "年度奖金/ 罚款",
  eoy_trophy_bonus     = "年度物品奖励",
  machine_replacement  = "汰换机器花费",
  remove_room = "移除已毁坏的房间",
}

humanoid_name_starts = {
  "欧得",
  "黑尔",
  "安德",
  "本",
  "班",
  "比尔",
  "维",
  "瓦特",
  "宝得",
  "金",
  "巴",
  "派特",
  "曼",
  "宝艾",
  "沃",
  "杰克",
  "克来伯",
  "费什",
  "瓦特",
  "米尔",
  "白",
  "芬",
  "里奇",
  "斯科特",
  "伯尔",
  "派克",
  "科",
  "维特",
  "比恩",
  "宝恩",
  "伯格",
  "怀特",
  "科尔",
}
humanoid_name_ends = {
  "斯密斯",
  "威克",
  "克利夫",
  "桑",
  "因格顿",
  "贝里",
  "顿",
  "桑",
  "李",
  "伯利",
  "波姆",
  "兰",
  "汉默",
  "希尔",
  "温",
  "莱特",
  "艾尔斯",
  "顿",
  "蒙德",
  "曼",
  "爱尔顿",
  "依",
  "摩",
  "摩尔",
  "莱特",
  "林",
}

adviser = {
  tutorial = {
    -- 1) build reception
    build_reception               = "你好。首先，您的医院需要一个接待台，您可以从布置走廊菜单中选取。", -- start of the tutorial
    order_one_reception           = "使用鼠标左键单击闪动的光条，可以定购一个接待台。",
    accept_purchase               = "点击闪动的像标表示购买。",
    rotate_and_place_reception    = "点击鼠标右键可以旋转桌子，并用鼠标左键将其放在医院中合适位置。",
    reception_invalid_position    = "如果接待台是灰色的，则表示当前位置是非法的。应尝试移动或旋转它。",

    -- 2) hire receptionist
    hire_receptionist             = "您也需要一位接待员来接待病人。",
    select_receptionists          = "使用鼠标左键单击闪动的像标来查看当前可选择的接待员。像标下方的数字表示共有多少个接待员可供选择。",
    next_receptionist             = "这是接待员列表中的第一个。左键单击闪动的像标可以浏览下一个可供选用的接待员。",
    prev_receptionist             = "左键单击闪动的像标将可以浏览到前一个可供选择的接待员。",
    choose_receptionist           = "判断哪一个接待员拥有好的能力与合适的工资，再左键单击闪动的像标来雇佣她。",
    place_receptionist            = "移动接待员并将她放到任意位置。她将很聪明地自己走到接待台。",
    receptionist_invalid_position = "您不能将接待员放在那里。",

    -- 3) build GP's office
    -- 3.1) room window
    build_gps_office              = "您必须建造一般诊断室才可以诊断病人。",
    select_diagnosis_rooms        = "点击闪动的像标将弹出诊断类房间列表。",
    click_gps_office              = "点击闪动光条表示选择一般诊断室。",

    -- 3.2) blueprint
    -- [11][58] was maybe planned to be used in this place, but is not needed.
    click_and_drag_to_build       = "建造一般诊断室时应先决定具体的尺寸。点击并按住鼠标左键可以设置房间尺寸。",
    room_in_invalid_position      = "该蓝图是非法的，红色区域表示蓝图与其它房间或墙壁重叠。",
    room_too_small                = "该房间的蓝图为红色是因为其尺寸太小了。通过拖动使其尺寸增大。",
    room_too_small_and_invalid    = "蓝图尺寸太小了且处于非法位置。",
    room_big_enough               = "蓝图尺寸已经足够大了。当您松开鼠标按键表示确认。如果需要的话，以后还可以根据需要移动或改变其尺寸。",

    -- 3.3) door and windows
    place_door                    = "沿着蓝图墙壁移动鼠标，寻找放置房门的合适位置。",
    door_in_invalid_position      = "房门设置位置非法。请尝试蓝图墙壁上的其它位置。",
    place_windows                 = "设置窗户的方法与设置房门的方法相同。您可以不需要窗户，但是当您的员工可以从窗户向外张望时，他们将感到快乐。",
    window_in_invalid_position    = "该窗口处于非法位置。请尝试蓝图墙壁上的其它位置。",

    -- 3.4) objects
    place_objects                 = "右击可以旋转房屋中的各种物品，再左击表示确认。",
    object_in_invalid_position    = "该物品当前位置非法。请要么将其放到其它位置，要么对其进行旋转。",
    confirm_room                  = "左键单击闪动像标就可以开业了，也可以通过点击交叉按钮返回上一步。",
    information_window            = "帮助条将告诉您刚刚建造的一般诊断室信息。",

    -- 4) hire doctor
    hire_doctor                   = "您需要一个医生来诊断和治疗病人。",
    select_doctors                = "点击闪动的像标挑选可被雇佣的医生。",
    choose_doctor                 = "在选择医生之前，应重点考虑其能力。",
    place_doctor                  = "将医生放在医院中的任意位置。他将直奔一般诊断室，为病人诊断。",
    doctor_in_invalid_position    = "嗨！您不能将医生放在那里。",

    -- (currently) unused
    start_tutorial                = "阅读任务简报，随后点击鼠标左键就可以启动教程。",
    build_pharmacy                = "恭喜！现在应建造一个药房并雇佣一位护士，使医院正常运转。",
  },

  staff_advice = {
    need_doctors                  = "您需要更多的医生。请将最得力的医生放在排队等候人数最多的房间内。",
    too_many_doctors              = "您雇佣的医生太多了。其中有一些人当前正闲着。",
    -- too_many_doctors_2            = "您雇佣的医生太多了。" -- duplicate
    need_handyman_litter          = "医院中出现了垃圾。请雇佣一个清洁工人打扫垃圾。",
    need_handyman_plants          = "您需要雇佣一位清洁工人来为植物浇水。",
    need_handyman_machines        = "如果希望维护医院内的各种医疗机器，则需要雇佣清洁工人。",
    need_nurses                   = "您需要雇佣更多的护士。病房和药房都需要护士。",
    too_many_nurses               = "我认为您现在雇佣了太多的护士。",
  },

  -- used when you place staff in a wrong place
  staff_place_advice = {
    only_researchers              = "只有拥有研究技能的医生才可以在研究部门工作。", -- in research center
    only_surgeons                 = "只有拥有外科技能的医生才可以在手术中心工作。", -- in operating theatre
    only_psychiatrists            = "只有具有精神病治疗技能的医生才可以在精神病诊断治疗室中工作。", -- in psychiatry
    only_nurses_in_room           = "只有护士可以在%s 中工作", -- %s (room name)
    doctors_cannot_work_in_room   = "医生无法在%s 中工作", -- %s (room name)
    nurses_cannot_work_in_room    = "护士无法在%s 中工作", -- %s (room name)
    only_doctors_in_room          = "只有医生可以在%s 中工作", -- %s (room name)
    receptionists_only_at_desk    = "接待员只能在接待台工作。",
    not_enough_lecture_chairs = "每名医生学员需要一个教室座位",
  },

  build_advice = {
    blueprint_invalid             = "蓝图位置非法。",
    blueprint_would_block         = "蓝图与其它房间重叠了。请尝试重新设置蓝图尺寸，或移动蓝图位置。",
    door_not_reachable            = "病人无法进入那扇门。仔细想一想。",
    placing_object_blocks_door    = "设置该物品可以阻止其他人接近",
  },

  -- these are used when completing a room with certain requirements (if they are not met yet)
  room_requirements = {
    psychiatry_need_psychiatrist  = "您需要雇佣一位精神病医生，现在您已经建成了一个精神病诊断治疗室。",
    pharmacy_need_nurse           = "您应该为药房雇佣一位护士。",
    training_room_need_consultant = "您应该为培训室雇佣一位专家，负责讲演。",
    research_room_need_researcher = "您需要为研究室雇佣一个拥有研究技巧的医生。",
    op_need_two_surgeons          = "请为手术中心雇佣两名外科医生完成手术。",
    op_need_another_surgeon       = "您至少还需要为手术中心雇佣一名外科医生。",
    op_need_ward                  = "您必须为外科手术前的患者建造病房。",
    ward_need_nurse               = "您需要为病房雇佣一名护士。",
    gps_office_need_doctor        = "您需要为一般诊断室雇佣一名医生。",
    reception_need_receptionist   = "您必须为病人雇佣一位接待员。",
  },

  surgery_requirements = {
    need_surgeons_ward_op         = "您需要雇佣两位外科医生，并修建一个病房和手术中心，这样才可以完成外科手术。",
    need_surgeon_ward             = "为了完成外科手术，您还需要雇佣一名外科医生，以及修建一个病房。",
  },

  warnings = {
    money_low                     = "",
    money_very_low_take_loan      = "您的现金量太少了。您可以尝试贷款。",
    cash_low_consider_loan        = "您的流动资金状况十分不妙。是否考虑贷款？",
    bankruptcy_imminent           = "嗨! 您快破产了。小心啊!",
    financial_trouble             = "您正面临着严重的财政危机。立即整理帐户！如果您再亏损$%d ，本关任务将失败。", -- %d amount left before level is lost
    finanical_trouble2            = "多增加一些收入。如果再亏损$%d 任务就会失败。", -- %d same as above
    financial_trouble3            = "您的现金状况不太妙。想办法增加一些收入。您距离失败还差$%d 。", -- %d same again

    pay_back_loan                 = "您已经挣到了很多钱。为什么不考虑偿还贷款？",

    machines_falling_apart        = "您的机器快爆炸了。请立即让清洁工进行维修！",
    no_patients_last_month        = "上个月，没有新的病人前来您的医院。太可怕了！",
    nobody_cured_last_month       = "上个月几乎没有治愈一个病人。",
    queues_too_long               = "队伍太长了。",
    patient_stuck                 = "有人被卡住了，更好地规划您的医院。",

    patients_unhappy              = "病人不喜欢您的医院。您必须为提高环境质量做一些事情。",
    patient_leaving               = "一个病人离开了。原因？医院管理不善，员工工作不力，再加上设施不全。",
    patients_leaving              = "病人们正在离去。在医院中多摆放一些植物，长椅，饮料机等物品将有助于挽留他们。",
    patients_really_thirsty       = "病人们感到口渴。多放置一些饮料机，或将已有的饮料机移动到最长的队伍旁边。",
    patients_annoyed              = "人们对医院的管理感到极端愤怒。我不能责备他们，抓紧时间解决问题吧！",

    patients_thirsty              = "人们感到口渴。也许您应该向他们提供饮料机。",
    patients_thirsty2             = "人们抱怨口渴。您应该在医院中多设置一些饮料机，或将已有的饮料机移动到他们身边。",
    patients_very_thirsty         = "人们感到太口渴了。如果您不立即设置一些饮料机，则将看到大多数人回家去喝可乐。",

    patients_too_hot              = "病人们感到太热了。要么拆除一些暖气，调低供热标准，要么为他们多设置一些饮料机。",
    patients_getting_hot          = "病人们感到太热了。请降低医院的供热，或移走一些暖气。",
    patients_very_cold            = "病人们感到太冷了。请增加医院的供热，或在医院中多摆放一些暖气。",
    people_freezing               = "无法相信，在这个拥有中央空调的时代，您的一些病人竟然快被冻僵了。赶快摆放一些暖气并打开供暖开关使他们感到温暖。",

    staff_overworked              = "您的员工已经劳累过度。他们的办事效率正在下降，并将有可能发生医疗事故。",
    staff_tired                   = "您的员工感到太疲倦了。如果您再不让他们到员工休息室休息一会儿，则某些人会由于长时间的紧张疲劳导致崩溃。",

    staff_too_hot                 = "您的工作人员感到太热了。请调低供热标准或拆除房间内的暖气。",
    staff_very_cold               = "员工们感觉太冷了。请增加医院的供热，或在医院中多摆放一些暖气。",
    staff_unhappy                 = "您的工作人员不是很快乐。可以尝试给他们一些奖金，或为他们建造一个员工休息室。您也可以在医院制度画面中调整员工需要休息时的疲劳程度。",
    staff_unhappy2                = "您的员工都不是很快乐。很快他们就会要求发奖金。",
    doctor_crazy_overwork         = "喔，不！您的一位医生已经由于劳累过度快要发狂了。如果能够立即让他休息，他将得到恢复。",

    reduce_staff_rest_threshold   = "尝试在医院制度画面中减少员工休息时的疲劳程度，这样员工将经常休息。这只是一个主意。",
    nurses_tired                  = "您的护士感到疲倦了。立即让她们休息。",
    doctors_tired                 = "您的医生太累了。立即让他们休息。",
    handymen_tired                = "您的清洁工人太劳累了。立即让他们休息。",
    receptionists_tired           = "您的接待员太疲劳了。立即让她们休息。",

    nurses_tired2                 = "您的护士太疲倦了。立即让她们休息。",
    doctors_tired2                = "您的医生太疲倦了。立即让他们休息。",
    handymen_tired2               = "您的清洁工太疲倦了。立即让他们休息。",
    receptionists_tired2          = "您的接待员太疲倦了。立即让她们休息。", -- What?

    need_toilets                  = "病人需要洗手间。请在一些易找的地方建造洗手间。",
    build_toilets                 = "立即建造一个洗手间，否则您将看到非常不雅的事情发生。想象一下医院中将会出现的味道。",
    build_toilet_now              = "立即建造洗手间。人们已经忍无可忍了。别傻笑，这可是一个严重问题。",
    more_toilets                  = "您需要更多的马桶。人们都已急不可待了。",
    people_did_it_on_the_floor    = "您的一些病人坚持不住了。赶快打扫干净。",

    need_staffroom                = "建造一个员工休息室使您的员工得以休息。",
    build_staffroom               = "立即建造一个员工休息室。您的员工工作太辛苦了，而且将要精神崩溃了。快点！",

    many_killed                   = "您已经杀死了%d 个病人。您本应该治愈他们的病。", -- %d (number of killed patients)

    plants_thirsty                = "您需要对植物进行照料。它们正感到干渴。",
    too_many_plants               = "您已经布置了足够多的植物了。医院都快变成丛林了",

    charges_too_high              = "治疗费用太高了。短期内它将产生很好的效益，但最终会把病人吓跑的。",
    charges_too_low               = "治疗费用太低了。它将使更多的病人到医院就诊，但您无法从每个病人身上获取太多的利润。",

    machine_severely_damaged      = "%s 已经快彻底毁坏了。", -- %s (name of machine)
    machinery_slightly_damaged    = "您的医疗仪器有轻微损伤。别忘了维护。",
    machinery_damaged             = "立即修理您的机器。它们无法支撑太久。",
    machinery_damaged2            = "您必须立即雇佣一名清洁工去负责修理维护机器。",
    machinery_very_damaged        = "紧急！立即派清洁工去修理机器！它们要爆炸了！",
    machinery_deteriorating       = "您的机器由于过度使用已经出现老化现象。小心。",

    queue_too_long_send_doctor    = "您的%s 队伍太长了。请确认房间中是否有医生。", -- %s (name of room)
    queue_too_long_at_reception   = "在接待台前排队等待的病人太多了。请再建一个接待台并雇佣一名接待员。",
    reception_bottleneck          = "接待台已无法满足需要。再雇佣一名接待员。", -- TODO find out why there's 133 and 134.

    epidemic_getting_serious      = "传染病疫情越来越严重。您必须立即行动！",
    deal_with_epidemic_now        = "如果无法立即控制传染病那么您的医院将出大乱子。加油！",
    many_epidemics                = "看来医院里同时有不只一种传染病。这将是一场空前灾难，加油！",

    hospital_is_rubbish           = "人们在到处宣扬您的医院是垃圾。要知道您的医院很快就会臭名远洋。",

    more_benches                  = "是否考虑多摆放一些长椅。一些病情严重的病人现在正被迫站着等待治疗。",
    people_have_to_stand          = "病人不得不站立等待。立即多摆放一些长椅。",

    too_much_litter               = "医院中的废弃物不断增多。派几个清洁工人就可以解决。",
    litter_everywhere             = "医院中的废弃物到处都是。多派几个清洁工人就可以解决。",
    litter_catastrophy            = "医院中的废弃物太多了。立即派一队清洁工人解决这个问题。",
    some_litter                   = "清洁工人可以在垃圾成堆之前清除所有垃圾。",

    place_plants_to_keep_people   = "人们正在离开。多摆放一些植物可以挽留他们。",
    place_plants2                 = "人们正在离开。多摆放一些植物可以使他们多停留一会儿。",
    place_plants3                 = "人们的情绪很糟。多摆放一些植物使他们快乐。",
    place_plants4                 = "在医院中多摆放一些植物使所有病人感到快乐。",

    desperate_need_for_watering   = "您需要雇佣一名清洁工照料医院中的植物。",
    change_priorities_to_plants   = "您必须改变清洁工的工作优先级，使他们更多地为植物浇水。",
    plants_dying                  = "您的植物快干死了。它们需要水。多为植物派些清洁工。病人可不愿意看到枯死的植物。",

    another_desk = "新雇用的接待员需要添加一个接待台",
  },

  praise = {
    many_plants                   = "太可爱了。您已经布置了足够的植物。病人将感到满意。",
    plants_are_well               = "太棒了。植物被照料得很好。",
    plants_thriving               = "太棒了。医院中的植物生长得很茂盛。它们看起来令人感到惊奇。坚持。，您将有可能赢得一个大奖。",

    many_benches                  = "病人拥有足够的座位。太棒了。",
    plenty_of_benches             = "座椅已经足够了。",
    few_have_to_stand             = "在您的医院中几乎每个人都有座位。所有的病人都感到快乐。",

    patients_cured                = "已经治愈了%d 个病人。", -- %d (number of cured patients)
  },

  information = {
    epidemic                      = "在您的医院中发现了一种传染病。您必须立即处理！",
    emergency                     = "紧急情况！快！快！快！",
    promotion_to_doctor           = "您的一个实习医生提升为医生了。",
    promotion_to_specialist       = "您的一个医生被提升为%s 。", -- %s (type: psychiatrist, scientist, surgeon)
    promotion_to_consultant       = "您的一名医生已经提升为专家了。",

    first_death                   = "这是您第一次杀死病人。感觉如何？",
    first_cure                    = "干得好！您已经治愈了第一个病人。",

    place_windows                 = "设置窗户将使房间更加明亮，并振奋员工的精神。",
    larger_rooms                  = "大的房间将使员工感觉到自己的重要，并提高他们的表现。",
    extra_items                   = "房间中摆放物品将使员工感到舒服并提高他们的表现。",

    patient_abducted              = "您的一位病人被外星人诱拐了。", -- what the heck is this? I never got that far in the original...
    patient_leaving_too_expensive = "一位病人没有为%s 付款就离开了。这损失太大了。",

    pay_rise                      = "您的一个员工威胁要辞职。选择是否同意其请求，或将其解雇。点击屏幕左下方的像标可以查看威胁要辞职的员工信息。", -- TODO only in tutorial / first time?
    handyman_adjust               = "您可以通过调整清洁工人工作的优先级使其打扫得更干净。", -- TODO only in tutorial / first time?
    fax_received                  = "在屏幕左下角刚刚弹出的像标表示一些重要事件的相关信息，或某些需要您决定的事情。", -- Once only

    vip_arrived                   = "小心！%s 正准备访问您的医院！保持医院运转正常，这样才能使他感到愉快。", -- %s (name of VIP)
    epidemic_health_inspector     = "您的医院中出现传染病的消息已经到达了卫生部。卫生巡查员很快就要到达，快做准备。",

    initial_general_advice = {
      research_now_available      = "您已经建造了第一个研究房间。现在您可以进入研究画面。",
      research_symbol             = "拥有研究技能的医生后跟符号：}",
      surgeon_symbol              = "拥有外科手术技能的医生后跟符号：{",
      psychiatric_symbol          = "拥有精神病技能的医生后跟符号：|",
      rats_have_arrived           = "老鼠在您的医院中到处乱跑。使用鼠标打死它们。",
      autopsy_available           = "自动验尸机被研制出来了。通过它，您可以处置惹麻烦或不欢迎的病人，还可以对他们进行研究。要注意－能否使用该机器还有很大的争议。",
      first_epidemic              = "在医院中爆发了传染病请决定是掩盖病情还是将其清除出去。",
      first_VIP                   = "您要接待来访的第一位贵宾。一定要确保贵宾没有看到任何不良事件，或其他不高兴的病人。",
      taking_your_staff           = "有人想要挖走您的员工。您要抓紧与他们进行斗争。",
      machine_needs_repair        = "您有一台机器需要维修。确定机器位置－它可能正在冒烟－在机器上点击一下，再点击清洁工人按钮。",
      epidemic_spreading          = "您的医院中发现传染病。在病人离开医院之前一定要治愈他们。",
      increase_heating            = "人们感到寒冷。打开城镇地图画面中的供暖设施。",
      place_radiators             = "医院中的人们感到寒冷－您可以多摆放一些暖气。",
      decrease_heating            = "医院中的人们感到太热了。在城镇地图画面中，降低供热量。",
      first_patients_thirsty      = "医院中的人们感到口渴。为他们多摆放一些饮料机。",
      first_emergency             = "急救病人的头顶有一个闪亮的蓝色急救灯。在死亡之前或时间倒数结束之前治愈他们。",
    },
  },

  earthquake = {
    alert                         = "地震警报。在地震过程中，医院中的机器将受损。如果它们没有得到及时维护将彻底毁坏。",
    damage                        = "地震损坏了医院中%d 台机器，并使%d 个人受伤。", -- %d (damaged machines) %d (injured people)
    ended                         = "我认为这是一个大家伙－按照理查标准为%d 。", -- %d (severance of earthquake)
  },

  boiler_issue = {
    maximum_heat                  = "锅炉快失控了。暖气的供暖能力已经达到极限了。医院里的人都快被熔化了！多设置一些饮料机。",
    minimum_heat                  = "噢，终于找到您了。锅炉坏了。也就是说医院里的人将感到有点冷。",
    resolved                      = "好消息。锅炉和暖气现在工作正常。气温很快就可以恢复到正常水平。",
  },

  vomit_wave = {
    started                       = "请赶快处理医院中的呕吐物，否则呕吐现象会四处传播。也许您需要多雇佣几个清洁工人。",
    ended                         = "嗨！呕吐现象已被控制。今后一定要保持医院的清洁。",
  },

  goals = {
    win = {
      money                       = "您还需要%d 才能完成本关中的财政指标。", -- %d (remaining amount)
      reputation                  = "提高声望%d 将达到胜利完成本任务的要求", -- %d (required amount)
      value                       = "您需要增加医院收入到$%d", -- %d (required amount)
      cure                        = "再治愈%d 个病人您就可以满足本关任务的要求了。", -- %d (remaining amount)
    },
    lose = {
      kill                        = "再杀死%d 病人将导致本任务失败", -- %d (remaining amount)
    },
  },

  level_progress = {
    nearly_won                    = "您已经距离胜利非常接近了。",
    three_quarters_won            = "您距离胜利还差四分之三。",
    halfway_won                   = "您距离胜利还差一半。",
    nearly_lost                   = "您距离失败只有一步之遥了。",
    three_quarters_lost           = "您距离失败还差四分之三。",
    halfway_lost                  = "您距离失败还差一半。",

    another_patient_cured         = "干得好－治愈了一个病人。收入$%d 。",
    another_patient_killed        = "哦，不！您已经杀死了一个病人。这已经是第%d 个了。",

    financial_criteria_met        = "您已经完成了本任务要求达到的财政目标。现在请保持现金在%d 以上，使我们确信您的医院运行良好。", -- %d money threshold for the level
    cured_enough_patients         = "您已经治愈了足够多的病人，但是您只有达到更高的标准才能胜利完成任务。",
    dont_kill_more_patients       = "您实际上无力支付太多的医疗事故赔款！",
    reputation_good_enough        = "好的，您的声望已经达到任务要求了。保持在%d 以上，并解决好其它方面的问题。", -- %d rep threshold for the level
    improve_reputation            = "您需要提高声望%d ，这样才能有机会完成任务。", -- %d amount to improve by
    hospital_value_enough         = "保持医院价值在%d 以上，并解决好其它问题，就能胜利完成任务了。", -- %d keep it above this value
    close_to_win_increase_value   = "您距离胜利只有一步之遥了。再增加医院价值%d 。",

  },

  research = {
    new_machine_researched        = "一个新的%s 刚刚被成功研究出来。", -- %s (machine(?) name)
    new_drug_researched           = "治疗%s 的一种新药被研究成功。", -- %s (disease name)
    drug_improved                 = "治疗%s 的药品被您的研究部门改良了。", -- %s (disease name)
    drug_improved_1                 = "治疗%s 的药品被您的研究部门改良了。", -- %s (disease name)
    machine_improved              = "%s 的疗效被您的研究部门增强了。", -- %s (machine name)
    new_available                 = "一种新的%s 可以使用了", -- %s TODO What is this? Where to use this and where [11][24]?
    -- ANSWER: It is used if research is not conducted in an area for very long. Some diagnosis equipment
    -- becomes available anyway after some years. Then this message is displayed instead of [11][24]
    drug_fully_researched         = "您已经研究%s 到达100% 了。", -- %s (drug(?) name)
    autopsy_discovered_rep_loss   = "您的自动验尸机已经研制成功。对公众将产生副作用。",
  },

  competitors = {
    hospital_opened               = "竞争对手%s 的医院在本区域内已经开张了。", -- %s (competitor name)
    land_purchased                = "%s 已经购买了一些土地。", -- %s (competitor name)
    staff_poached                 = "您的一位员工被其它医院挖走了。",
  },

  multiplayer = {
    -- "NULL" unused
    everyone_failed               = "每个人都没有完成最终目标。因此每个人都要继续努力！",
    players_failed                = "下面的玩家没有完成最终目标：",

    poaching = {
      already_poached_by_someone  = "没门！有人想要挖走这个人。",
      not_interested              = "哈哈！他们对为您工作不感兴趣－他们希望找寻自我价值。",
      in_progress                 = "我将让您了解这个人是否愿意为您工作。",
    },

    objective_completed           = "您已经完成任务了。恭喜！", -- missing in some TH versions
    objective_failed              = "任务失败。", -- missing in some TH versions
  },

  placement_info = {
    -- "Null" unused
    room_cannot_place             = "您无法在这里建房。",
    room_cannot_place_2           = "您无法在这里建房。", -- hmm. why? maybe the previous one should've been "can"
    reception_can_place           = "您可以在这里放置接待台。",
    reception_cannot_place        = "您无法在这里放置接待台",
    door_can_place                = "如果您愿意的话可以在这里设置房门。",
    door_cannot_place             = "抱歉，您无法在这里设置房门。",
    window_can_place              = "你可以在这里设置窗户，这样很好。",
    window_cannot_place           = "您实际上无法在这里设置窗户。",
    staff_can_place               = "您可以在这里安置员工。",
    staff_cannot_place            = "您无法在这里安置员工。对不起。",
    object_can_place              = "您可以在这里摆放物品。",
    object_cannot_place           = "嗨，您无法在这里摆放物品。",
  },

  epidemic = {
    -- "NULL" unused
    serious_warning               = "传染病疫情越来越严重。您必须立即行动！",
    hurry_up                      = "如果无法立即控制传染病那么您的医院将出大乱子。加油！",
    multiple_epidemies            = "看来医院里同时有不只一种传染病。这将是一场空前灾难，加油！",
  },
}

level_names = {
  -- "Null" -- unused
  "毒气城",
  "昏睡城",
  "大柴斯特城",
  "福来明顿城",
  "新普顿城",
  "世界之疮",
  "绿池城",
  "曼葵城",
  "依斯特威尔",
  "爱格森海姆城",
  "蛙鸣城",
  "巴登堡",
  "查姆雷城",
  "小爪槟城",
  "葬礼城",
}

town_map = {
  -- "Null" -- unused
  chat         = "城镇细节",
  for_sale     = "出售",
  not_for_sale = "不可购买",
  number       = "地区编号",
  owner        = "地区所有",
  area         = "地区面积",
  price        = "地区售价",
}

-- NB: includes some special "rooms"
-- reception, destroyed room and "corridor objects"
rooms_short = {
  -- "Null" -- unused
  -- "尚未使用" -- unused
  reception         = "接待台",
  destroyed         = "已毁坏",
  corridor_objects  = "走廊物品",

  gps_office        = "一般诊断室",
  psychiatric       = "精神病诊疗室",
  ward              = "病房",
  operating_theatre = "手术中心",
  pharmacy          = "药房",
  cardiogram        = "心电图仪",
  scanner           = "扫描仪",
  ultrascan         = "超级扫描仪",
  blood_machine     = "血液机器",
  x_ray             = "X 光仪器",
  inflation         = "充气机",
  dna_fixer         = "DNA 修复装置",
  hair_restoration  = "毛发恢复机器",
  tongue_clinic     = "舌头治疗机",
  fracture_clinic   = "骨折诊所",
  training_room     = "培训室",
  electrolysis      = "电分解诊所",
  jelly_vat         = "胶桶诊所",
  staffroom         = "员工休息室",
  -- rehabilitation = "病人复原室", -- unused
  general_diag      = "高级诊断室",
  research_room     = "研究部门",
  toilets           = "洗手间",
  decontamination   = "净化设备",
}

rooms_long = {
  -- "Null" -- unused
  general           = "一般", -- unused?
  emergency         = "紧急事件",
  corridors         = "走廊",

  gps_office        = "一般诊断室",
  psychiatric       = "精神病诊断治疗室",
  ward              = "病房",
  operating_theatre = "手术中心",
  pharmacy          = "药房",
  cardiogram        = "心电图仪房间",
  scanner           = "扫描仪房间",
  ultrascan         = "终极扫描仪房间",
  blood_machine     = "血液机器房间",
  x_ray             = "X 光房间",
  inflation         = "充气房间",
  dna_fixer         = "DNA 修复装置",
  hair_restoration  = "毛发恢复装置",
  tongue_clinic     = "舌头松弛诊治所",
  fracture_clinic   = "骨折诊所",
  training_room     = "培训室",
  electrolysis      = "电分解诊所",
  jelly_vat         = "胶桶",
  staffroom         = "员工休息室",
  -- rehabilitation = "没有使用", -- unused
  general_diag      = "高级诊断室",
  research_room     = "研究部门",
  toilets           = "洗手间",
  decontamination   = "净化",
}

disease_discovered_patient_choice = {
  need_to_employ = "雇用一名%s就可以处理该情况。",
}

drug_companies = {
  -- "Null", -- unused
  "良药公司",
  "名医公司",
  "小药片公司",
  "普芬公司",
  "欧米尼公司",
}

build_room_window = {
  -- "Null", -- unused
  pick_department   = "选择部门",
  pick_room_type    = "选择房间类型",
  cost              = "花费：",
}

buy_objects_window = {
  choose_items      = "选择物品",
  price             = "价格：",
  total             = "总共：",
}

research = {
  categories = {
    cure            = "治疗仪器",
    diagnosis       = "诊断仪器",
    drugs           = "药品研究",
    improvements    = "改良",
    specialisation  = "专项",
  },

  funds_allocation  = "资金配置",
  allocated_amount  = "已分配量",
}

policy = {
  header            = "医院制度",
  diag_procedure    = "诊断程序",
  diag_termination  = "诊断结束",
  staff_rest        = "员工休息",
  staff_leave_rooms = "员工离开房间",

  sliders = {
    guess           = "尝试治疗", -- belongs to diag_procedure
    send_home       = "遣送回家", -- also belongs to diag_procedure
    stop            = "停止治疗", -- belongs to diag_termination
    staff_room      = "去员工休息室", -- belongs to staff_rest
  }
}

room_classes = {
  -- "Null" -- unused
  -- "走廊" -- "corridors" - unused for now
  -- "尚未使用" -- unused
  diagnosis  = "诊断室",
  treatment  = "治疗室",
  clinics    = "诊所",
  facilities = "附属设施",
}

-- These are better of in a list with numbers
insurance_companies = {
  out_of_business   = "无",
  "天鹅绒有限公司",
  "诺福克洋葱公司",
  "双峰公司",
  "刀疤有限公司",
  "潜水艇有限公司",
  "诚实的泰瑞公司",
  "矮胖先生股份有限公司",
  "里昂猫公司",
  "普里邦有限公司",
  "快乐保险公司",
  "辛迪加保险公司",
}

menu = {
  file                = " 文件 ",
  options             = " 选项 ",
  display             = " 显示 ",
  charts              = " 图表 ",
  debug               = " DEBUG  ",
}

menu_file = {
  load                = " 读取 ",
  save                = " 存储 ",
  restart             = " 重新开始 ",
  quit                = " 退出 ",
}

menu_file_load = {
  " 存档一 ",
  " 存档二 ",
  " 存档三 ",
  " 存档四 ",
  " 存档五 ",
  " 存档六 ",
  " 存档七 ",
  " 存档八 ",
}
menu_file_save = menu_file_load

menu_options = {
  sound               = " 音效 ",
  announcements       = " 语音 ",
  music               = " 音乐 ",
  sound_vol           = " 音效音量 ",
  announcements_vol   = " 语音音量 ",
  music_vol           = " 音乐音量 ",
  autosave            = " 自动存盘 ",
  game_speed          = " 游戏速度 ",
  jukebox             = " 音乐盒 ",
}

menu_options_volume = { -- redundant in original strings: M[10] and M[11]
  [100]                = " 100%  ",
  [ 90]                = " 90%  ",
  [ 80]                = " 80%  ",
  [ 70]                = " 70%  ",
  [ 60]                = " 60%  ",
  [ 50]                = " 50%  ",
  [ 40]                = " 40%  ",
  [ 30]                = " 30%  ",
  [ 20]                = " 20%  ",
  [ 10]                = " 10%  ",
}

menu_options_game_speed = {
  slowest             = " 非常慢 ",
  slower              = " 较慢 ",
  normal              = " 正常 ",
  max_speed           = " 快速 ",
  and_then_some_more  = " 极快 ",
}

menu_display = {
  high_res            = " 阴影",
  -- mcga_lo_res         = M[4][2],
  -- shadows             = M[4][3],
}

menu_charts = {
  statement           = " 银行帐户 ",
  casebook            = " 治疗手册 ",
  policy              = " 制度 ",
  research            = " 研究 ",
  graphs              = " 图表 ",
  staff_listing       = " 员工列表 ",
  bank_manager        = " 银行经理 ",
  status              = " 状态 ",
  briefing            = " 任务简报 ",
}

menu_debug = {
  object_cells        = " OBJECT CELLS         ",
  entry_cells         = " ENTRY CELLS          ",
  keep_clear_cells    = " KEEP CLEAR CELLS     ",
  nav_bits            = " NAV BITS             ",
  remove_walls        = " REMOVE WALLS         ",
  remove_objects      = " REMOVE OBJECTS       ",
  display_pager       = " DISPLAY PAGER        ",
  mapwho_checking     = " MAPWHO CHECKING      ",
  plant_pagers        = " PLANT PAGERS         ",
  porter_pagers       = " PORTER PAGERS        ",
  pixbuf_cells        = " PIXBUF CELLS         ",
  enter_nav_debug     = " ENTER NAV DEBUG      ",
  show_nav_cells      = " SHOW NAV CELLS       ",
  machine_pagers      = " MACHINE PAGERS       ",
  display_room_status = " DISPLAY ROOM STATUS  ",
  display_big_cells   = " DISPLAY BIG CELLS    ",
  show_help_hotspot   = " SHOW HELP HOTSPOTS   ",
  win_game_anim       = " WIN GAME ANIM        ",
  win_level_anim      = " WIN LEVEL ANIM       ",
  lose_game_anim = {
    " LOSE GAME 1 ANIM     ",
    " LOSE GAME 2 ANIM     ",
    " LOSE GAME 3 ANIM     ",
    " LOSE GAME 4 ANIM     ",
    " LOSE GAME 5 ANIM     ",
    " LOSE GAME 6 ANIM     ",
    " LOSE GAME 7 ANIM     ",
  },
}

staff_list = {
  -- "NULL" unused
  -- "工作          名字                     技能    工资 士气疲劳程度" -- I have no idea what this is.
  morale       = "士气",
  tiredness    = "疲劳程度",
  skill        = "技能",
  total_wages  = "工资总额",
}

high_score = {
  -- "Null" unused
  pos          = "名次",
  player       = "玩家",
  score        = "分数",
  best_scores  = "荣誉堂",
  worst_scores = "耻辱堂",
  killed       = "杀死病人数目", -- is this used?

  categories = {
    money             = "最富有",
    salary            = "工资最高",
    clean             = "最干净",
    cures             = "治愈人数",
    deaths            = "死亡人数",
    cure_death_ratio  = "医治无效死亡率",
    patient_happiness = "顾客满意",
    staff_happiness   = "员工满意",
    staff_number      = "员工数目最多",
    visitors          = "访问者最多",
    total_value       = "总价值",
  },
}

trophy_room = {
  -- "NULL" unused
  many_cured = {
    awards = {
      "恭喜您在过去一年中治愈了这么多的病人。很多人都感觉不错，感谢您的工作。",
      "由于您的医院治愈了比其它医院更多的病人，所以请接受这个奖励。您的表现太棒了。",
    },
    penalty = {
      "您的医院无法使病人得到很好的治疗。请关注并加以改进。",
      "您的医院对病人的治疗效果不如其它医院。您使卫生部和您自己都名声扫地。下不为例。",
    },
    trophies = {
      "由于您的医院在过去一年中成功地治疗了几乎所有病人，特此恭喜您荣获玛丽治疗奖。",          -- for around 100% cure rate
      "由于您的医院在过去一年中治愈了大量患者，国际治疗基金会特此向您颁发悬壶济世奖。",          -- for around 100% cure rate
      "由于您的医院在过去一年中治愈了大量患者，特此颁发疾病克星奖。",          -- for around 100% cure rate
    },
    regional = {
      "由于您的医院治愈的病人数目比其它医院的总和还多，特此颁发奖励。",
    },
  },
  all_cured = {
    awards = {
      "由于您的医院在过去一年中成功地治疗了所有病人，特此颁发玛丽治疗奖。",          -- for 100% treat rate (does that mean none sent home or killed?)
    },
    trophies = {
      "由于您的医院在过去一年中成功地治疗了就诊的每个病人，国际治疗基金会特此向您颁发全部治愈奖。",          -- for 100% cure rate
      "由于您的医院在过去一年中治愈了大量患者，特此颁发急病克星奖。",          -- for 100% cure rate
    },
  },
  hosp_value = {
    awards = {
      "由于您的医院价值不菲，因此卫生部向您表示恭喜。",
    },
    penalty = {
      "您的医院价值太低了。您的理财能力太次了。记住一个好的医院通常也是价值最高的医院。",
    },
    regional = {
      "您真是一个理财高手。您的医院的价值比其它医院的总和还要多。",
    },
  },
   best_value_hosp = {
    trophies = {
      "由于您的医院在过去一年中赢得了最高的声望，特此颁发白衣天使奖。这是您应得的。",
    },
    regional = {
      "恭喜您管理的医院成为最有价值的医院。干得好。保持下去。",
    },
    penalty = {
      "周围每个医院都比您的医院富有。您要加油啊。多购买一些昂贵的东西。",
    },
  },
  consistant_rep = {
    trophies = {
      "由于您的医院在过去一年中无懈可击的运营以及最高的声望，您被授予内阁大臣奖。干得好。",
      "由于您的医院在过去一年中赢得了最高的声望，特此颁发白衣天使奖。这是您应得的。",
    },
  },
  high_rep = {
    awards = {
      "干得好。在上一个年度，由于您获得了很高的声望，特此颁发一个小小的奖励。",
      "太棒了! 由于您在过去一年中取得了很高的声望，特此颁发奖励。",
    },
    penalty = {
      "在过去一年中，您赢得了很低的声望。以后一定要加油啊。",     -- is this the penalty for consistant poor rep?
      "您的声望是本区域最低的。真丢人。加油干。",
    },
    regional = {
      "由于您的医院在过去一年中赢得了最高的声望，特此颁发牛蛙奖。这是您应得的。",
      "在这一年中，您的医院的声望超过了其它所有医院的总和。真是一项伟大的成就。",
    },
  },
  happy_staff = {
    awards = {
      "您的员工表示要向您颁奖。他们说虽然还有很多需要改进的地方，但您对待他们的态度使他们感到很快乐。",
      "您的员工感到能够为您工作是一件非常快乐的事情，他们的笑容挂在脸上。您真是一个超级管理人才。",
    },
    penalty = {
      "您的员工希望您知道他们非常不高兴。好的员工就是最有价值的资产。使他们快乐，否则您将在一天之内失去全部。",
    },
    regional_good = {
      "您的员工比其它医院的员工都要快乐。快乐的员工意味着更高的利润和更低的死亡率。卫生部感到非常高兴。",
    },
    regional_bad = {
      "您的员工在上一年度中非常不幸。您一定要加以留意。其它医院的员工都比您的员工快乐。",
    },
    trophies = {
      "由于您的医院在过去一年中使努力工作的员工保持快乐，特此颁发微笑奖。",
      "由于您的医院在过去一年中没有不快乐的员工，特此颁发阿达尼学院奖。",
      "由于您的医院在过去一年中使努力工作的员工保持快乐，特此颁发笑星奖杯。快乐地笑吧！",
    },
  },
  happy_vips = {
     trophies = {
      "由于您的医院在过去一年中给来访的贵宾们留下了深深地好感，特此向您颁发诺贝尔奖。",
      "由于您的医院使每位造访贵宾都感到快乐，特此由名人机构颁发著名人士奖。您已经成为我们名人行列中的一员。",
      "由于您的医院在过去一年中使每一位来访贵宾都感到了员工的工作热情，特此颁发贵宾满意奖。",
    },
  },
  no_deaths = {
    awards = {
      "由于您的医院在本年度保持了很低的死亡人数，特此颁发奖励。太棒了。",
      "由于您的天才管理使医院的死亡人数达到最低点。这真是令人高兴的事情。",
    },
    penalty = {
      "在过去一年中，您的医院的死亡人数始终很高。一定要多加注意。以后一定要确保病人的存活。", -- this may need an over-ride as it looks wrong  "unacceptably" not "acceptably" IMO
      "您的医院对于病人的健康简直就是在冒险。您应该治愈大量的病人，而不是让他们加速死亡。",
    },
    trophies = {
      "由于您的医院在过去一年中没有发生任何病人死亡事件，特此颁发安全奖。",
      "由于您的医院在过去一年中没有发生病人死亡事件，特此由生命发展组织向您颁奖。",
      "由于您的医院在过去一年中避免发生病人死亡事件，特此颁发挽留妙手回春奖。",
    },
    regional = {
      "您的医院的死亡人数比其它医院都低。请接受这个奖励。",
    },
  },
  rats_killed = {

    trophies = {
      "由于您的医院在过去一年中共击毙了%d 只老鼠，特此颁发除害奖。", -- %d (number of rats)
      "由于您高超的击鼠技巧共击毙老鼠%d 只，特此颁发联邦灭鼠奖。", -- %d (number of rats)
      "由于您的医院在过去一年中共击毙了%d 只老鼠，特此颁发老鼠克星奖。", -- %d (number of rats)
    },
  },
  rats_accuracy = {
    trophies = {
      "由于您击打老鼠的命中率为%d%% ，特此颁发极道枭雄2 射击准确奖。", -- %d (accuracy percentage)
      "由于您的医院在过去一年中以难以置信的命中率%d%% 击毙老鼠，特此颁奖。", -- %d (accuracy percentage)
      "由于您的医院在过去一年中击毙了%d%% 的老鼠，特此颁发地下城守护者除害奖。恭喜！", -- %d (accuracy percentage)
    },
  },
  healthy_plants = {
    awards = {
      "由于您的医院在过去一年中是植物保持健康成长，特此颁发茁壮成长奖。",
    },
    trophies = {
      "由于您的医院在过去十二个月中使所有植物长势良好，特此盆栽植物协会向您颁发绿色健康奖。",
      "由于您的医院在过去一年中使所有植物长势良好，特此颁发绿色名人奖。",
    },
  },
  sold_drinks = {
    trophies = {
      "由于您的医院在过去一年中售出了大量的罐装饮料，特此由全球牙医联合会向您颁奖。",
      "由于您的医院在过去一年中卖出大量饮料，特此软饮料零售组织向您颁发清凉饮料奖。",
      "由于您的医院在过去一年中卖出大量软饮料，特此由DK 填充公司向您颁发巧克力奖杯。",
    },
  },
  pop_percentage = {
    awards = {
      "在过去一年中，您的医院在城镇人口中获得了很高的份额。干得好。",
      "恭喜。访问您的医院的居民人数超过了其它任何一个医院。",
      "干得好。访问您的医院的居民人数超过了其它医院的总和。",
    },
    penalty = {
      "在过去一年中，您的医院只有很少的就诊病人。如果希望赚钱，就应该先付出。",
      "在本区域中的每个医院都比您拥有更多的占有额。您应该感到羞愧。",
    },
  },
  gen_repairs = {
    awards = {
      "由于您的清洁工人使医院内的仪器设备运行良好，特此颁发特别奖金。干得好。假期愉快。",
      "您的清洁工人比其它医院的都要好。这真是一件值得庆祝的事情。",
      "您的仪器维护得很好。这一切都离不开清洁工人的努力。干得好。",
    },
    penalty = {
      "您的清洁工人在维护机器方面表现不是很好。您应该让他们更多地关心维护保养工作，或者再多雇佣几名清洁工人。",
      "维修工作一团糟。您的清洁工人无法很好的照料各种医疗仪器。",
    },
  },
  curesvdeaths = {
    awards = {
      "恭喜您在过去一年中使医院保持了很高的治愈率和很低的死亡率。",
    },
    penalty = {
      "您的治愈率实在是太低了。您应该使治愈的病人多于死亡的病人。不要颠倒了。",
    },
  },
  research = {
    awards = {
      "您的研究使您的医院始终紧跟最新发展。这是您的科研人员应得的奖励。",
      "在过去一年中，您比其它医院研究出更多的药品和仪器设备。请接受卫生部颁发的这个奖励。",
    },
    penalty = {
      "您研究开发新治疗方案，仪器和药品的速度太慢了。这将无法赶上时代的步伐。",
    },
    regional_good = {
      "您的研究使您的医院始终紧跟最新发展。这是您的科研人员应得的奖励。",
    },
    regional_bad = {
      "本区域中的每个医院在研究方面都强于您的医院。这一点使卫生部感到震怒。",
    },
  },
  cleanliness = {
    award = {
      "卫生巡查员注意到您的医院非常干净。干净的医院意味着安全的医院。坚持下去。",
    },
    regional_good = {
      "您的医院是最脏乱的医院之一。一个脏乱的医院不仅味道难闻，而且是十分危险的。请密切留意。",
    },
    regional_bad = {
      "您的医院是本区域中最脏乱的。其它医院都使走廊保持整洁。您使医学界蒙羞。",
    },
  },
  emergencies = {
    award = {
      "恭喜：由于您的努力和卓有成效的紧急事件处理能力，使您荣获该特别大奖。干得好。",
      "您处理紧急事件的能力非常突出。由于您最佳的处理能力，特此颁发奖励。",
    },
    penalty = {
      "您处理紧急事件的能力实在太差了。前来就诊的急救病人并没有得到正确的治疗。",
    },
    regional_good = {
      "卫生部认识到您的医院在处理紧急事件时比其它医院都要好，特此颁发奖励。",
    },
    regional_bad = {
      "您的医院是本区域中处理紧急事件最差的。这都是您的过错。",
    },
  },
  wait_times = {
    award = {
      "恭喜。您的医院的排队等待时间非常短。这是给您的奖励。",
    },
    penalty = {
      "病人在您的医院中排队等待时间太长了。您应该好好地管理前来就诊的病人。",
    },
  },
  happy_patients = {
    awards = {
      "在过去一年中，您的医院使所有访问的病人都感到快乐，您将为此感到骄傲。",
      "访问您的医院的病人比其它医院内的病人要快乐得多。",
    },
    penalty = {
      "前去您的医院就诊的病人感到非常不满。您必须改进提高才可以获得卫生部的尊重。",
      "在您的医院中接受治疗的病人感到非常不高兴。您应多为病人的福利着想。",
    },
  },
  -- Strings used in the plaques to show what has been won
  reputation = "声望",
  cash       = "现金",
}

-- Section 28: more adviser strings (see above)

casebook = {
  reputation           = "声望",
  treatment_charge     = "治疗花费",
  earned_money         = "收入",
  cured                = "恢复",
  deaths               = "事故",
  sent_home            = "遣送回家",
  research             = "集中研究",
  cure                 = "治疗",
  cure_desc = {
    build_room         = "我建议您修建%s", -- %s (room name)
    build_ward         = "您仍需要建造一个病房。",
    hire_doctors       = "您需要雇佣一些医生。",
    hire_surgeons      = "您需要雇佣一些外科医生。",
    hire_psychiatrists = "您需要雇佣一些精神病医生。",
    hire_nurses        = "您需要雇佣一些护士。",
    no_cure_known      = "未治愈。",
    cure_known         = "治愈。",
    improve_cure       = "提高疗效。",
  },
}

-- 30, 31: multiplayer. not needed for now.

tooltip = {
  -- "没有帮助" unused
  build_room_window = {
    room_classes = {
      diagnosis        = "选择诊断类房间",
      treatment        = "选择处理类房间",
      clinic           = "选择治疗类房间",
      facilities       = "选择附属类房间",
    },
    cost               = "当前被选择房间价格",
    close              = "取消并返回游戏",
  },

  toolbar = {
    bank_button        = "左击进入银行经理画面，右击进入银行帐户",
    balance            = "现金",
    reputation         = "声望", -- NB: no %d! Append " ([reputation])".
    date               = "日期",
    rooms              = "建造房屋",
    objects            = "设置走廊",
    edit               = "编辑房间/ 物品",
    hire               = "雇佣员工",
    staff_list         = "员工管理",
    town_map           = "城镇地图",
    casebook           = "治疗手册",
    research           = "研究",
    status             = "状态",
    charts             = "图表",
    policy             = "制度",
  },

  hire_staff_window = {
    doctors            = "查看可雇佣的医生",
    nurses             = "查看可雇佣的护士",
    handymen           = "查看可雇佣的清洁工人",
    receptionists      = "查看可雇佣的接待员",
    prev_person        = "查看前一个人",
    next_person        = "查看后一个人",
    hire               = "雇佣",
    cancel             = "取消",
    doctor_seniority   = "医生资历（实习医生，医生，专家）",
    staff_ability      = "员工能力",
    salary             = "工作",
    qualifications     = "医生的特殊技能",
    surgeon            = "外科医生",
    psychiatrist       = "精神病医生",
    researcher         = "科研人员",
  },

  buy_objects_window = {
    price              = "物品价格",
    total_value        = "定购物品总值",
    confirm            = "购买物品",
    cancel             = "取消",
    decrease           = "少买一个",
    increase           = "多买一个",
  },

  staff_list = {
    doctors            = "查看医院中被雇佣医生名单",
    nurses             = "查看医院中被雇佣护士名单",
    handymen           = "查看医院中被雇佣清洁工人名单",
    receptionists      = "查看医院中被雇佣接待员名单",

    happiness          = "显示员工满意程度",
    tiredness          = "显示员工疲劳程度",
    ability            = "显示员工能力水平",
    salary             = "该员工当前工资",

    happiness_2        = "员工士气",
    tiredness_2        = "员工的疲劳程度",
    ability_2          = "员工的能力水平",

    prev_person        = "选择名单上一页",
    next_person        = "选择名单下一页",

    bonus              = "付给该员工10% 奖金",
    sack               = "解雇员工",
    pay_rise           = "提高员工工资10%",

    close              = "退出并返回游戏",

    doctor_seniority   = "医生资历",
    detail             = "细心程度",

    view_staff         = "查看员工工作情况",

    surgeon            = "合格外科医生",
    psychiatrist       = "合格精神病医生",
    researcher         = "合格研究人员",
    surgeon_train      = "已经接受了%d%% 的外科培训", -- %d (percentage trained)
    psychiatrist_train = "已经接受了%d%% 的精神病治疗培训", -- %d (percentage trained)
    researcher_train   = "已经接受了%d%% 的研究技能培训", -- %d (percentage trained)

    skills             = "特殊技能",
  },

  queue_window = {
    num_in_queue       = "排队等候的病人数目",
    num_expected       = "即将加入队伍的病人数目",
    num_entered        = "到目前为止该房间已处理病人数目",
    max_queue_size     = "接待员允许的最大排队人数",
    dec_queue_size     = "减少队伍的最大长度",
    inc_queue_size     = "增加队伍的最大长度",
    front_of_queue     = "拖动一位病人到该按钮处，将使其移动到队首",
    end_of_queue       = "拖动一位病人到该按钮处，将使其移动到队尾",
    close              = "关闭面板",
    patient            = "拖动病人将改变其排队位置。右击某个病人可以选择将其遣送回家或遣送到竞争对手的医院。",
    patient_dropdown = {
      reception        = "将病人送到接待员处",
      send_home        = "让病人离开医院",
      hospital_1       = "将病人送到其它医院",
      hospital_2       = "将病人送到其它医院",
      hospital_3       = "将病人送到其它医院",
    },
  },

  main_menu = {
    new_game           = "开始新游戏",
    load_game          = "读入进度",
    continue           = "继续游戏",
    network            = "开始网络游戏",
    quit               = "退出",
    load_menu = {
      load_slot        = "读取进度", -- NB: no %d! Append " [slotnumber]".
      empty_slot       = "空",
    },
  },

  window_general = {
    cancel             = "取消",
    confirm            = "确定",
  },

  patient_window = {
    close              = "取消请求",
    graph              = "通过点击可以在健康情况和病史之间切换",
    happiness          = "快乐程度",
    thirst             = "干渴程度",
    warmth             = "温暖程度",
    casebook           = "查看有关疾病的详细情况",
    send_home          = "把病人赶出医院",
    center_view        = "切换到当前人物",
    abort_diagnosis    = "无需诊断直接去治疗",
    queue              = "查看队伍详细资料",
  },

  staff_window = {
    name               = "员工名字",
    close              = "取消面板",
    face               = "面孔",
    happiness          = "快乐程度",
    tiredness          = "疲劳程度",
    ability            = "能力",
    doctor_seniority   = "资历－是实习医生，医生还是专家",
    skills             = "特殊技术",
    surgeon            = "外科",
    psychiatrist       = "精神病",
    researcher         = "研究",
    salary             = "月薪",
    center_view        = "切换到当前人物",
    sack               = "解雇",
    pick_up            = "拾起",
  },

  machine_window = {
    name               = "名字",
    close              = "取消请求",
    times_used         = "机器被使用次数",
    status             = "机器状况",
    repair             = "呼叫清洁工维修机器",
    replace            = "汰换机器",
  },

  -- Apparently handymen have their own set of strings (partly) containing "handyman".
  -- We could just get rid of this category and include the three prios into staff_window.
  handyman_window = {
    name               = "清洁工的名字", -- contains "handyman"
    close              = "取消请求",
    face               = "清洁工的面孔", -- contains "handyman"
    happiness          = "快乐程度",
    tiredness          = "疲劳程度",
    ability            = "能力",
    prio_litter        = "提高清洁工清除垃圾的优先级", -- contains "handyman"
    prio_plants        = "提高清洁工给植物浇水的优先级", -- contains "handyman"
    prio_machines      = "提高清洁工维修机器的优先级", -- contains "handyman"
    salary             = "工资",
    center_view        = "切换到当前人物", -- contains "handyman"
    sack               = "解雇",
    pick_up            = "拾起",
  },

  place_objects_window = {
    cancel             = "取消",
    buy_sell           = "买/ 卖物品",
    pick_up            = "拾起物品",
    confirm            = "确认",
  },

  casebook = {
    up                 = "向上滚动",
    down               = "向下滚动",
    close              = "关闭治疗手册",
    reputation         = "治疗或诊断接待台",
    treatment_charge   = "花费",
    earned_money       = "总收入",
    cured              = "治愈人数",
    deaths             = "事故人数",
    sent_home          = "遣送回家人数",
    decrease           = "减少",
    increase           = "增加",
    research           = "点击这里可以为治疗使用专门研究预算",
    cure_type = {
      drug             = "治疗时将使用药品",
      drug_percentage  = "治疗使用药品－其疗效为%d%%", -- %d (effectiveness percentage)
      psychiatrist     = "由精神病医生完成治疗工作",
      surgery          = "该疾病需要手术",
      machine          = "该疾病需要仪器辅助治疗",
    },
    cure_requirement = {
      possible         = "您有能力治疗这种疾病",
      research_machine = "您需要研究一些仪器来治疗这种疾病",
      build_room       = "您需要修建一个房间来治疗这种疾病",
      hire_surgeons    = "您需要雇佣两名外科医生完成手术", -- unused
      hire_surgeon     = "您需要雇佣第二位外科医生来完成手术", -- unused
      hire_staff_old   = "您需要雇佣一名%s 来治疗该疾病", -- %s (staff type), unused. Use hire_staff instead.
      build_ward       = "您需要建造一个病房来治疗该疾病", -- unused
      ward_hire_nurse  = "您需要一位护士在病房中照料病人", -- unused
      not_possible     = "您还没有能力治疗该种疾病", -- unused
    },
  },

  statement = {
    close              = "关闭银行帐户画面",
  },

  research = {
    close              = "关闭研究画面",
    cure_dec           = "降低疗效研究百分比",
    diagnosis_dec      = "降低科研百分比",
    drugs_dec          = "降低药品研究百分比",
    improvements_dec   = "降低改良研究百分比",
    specialisation_dec = "降低专门研究百分比",
    cure_inc           = "提高科研百分比",
    diagnosis_inc      = "提高仪器研究百分比",
    drugs_inc          = "提高药品研究百分比",
    improvements_inc   = "提高改良研究百分比",
    specialisation_inc = "提高专门研究百分比",

    -- "" unused
    allocated_amount   = "已分配预算",
  },

  graphs = {
    close              = "关闭图表画面",
    scale              = "比例尺",
    money_in           = "切换收入",
    money_out          = "切换支出",
    wages              = "切换工资",
    balance            = "切换现金",
    visitors           = "切换访问人数",
    cures              = "切换治愈人数",
    deaths             = "切换死亡人数",
    reputation         = "切换医院价值",
  },

  -- "将病人送到接待员处" through "将病人送到其它医院" inserted further above

  town_map = {
    people             = "切换人员",
    plants             = "切换植物",
    fire_extinguishers = "切换灭火器",
    objects            = "切换物品",
    radiators          = "切换暖气",
    heat_level         = "供热强度",
    heat_inc           = "增加供热",
    heat_dec           = "减少供热",
    heating_bill       = "供暖费",
    balance            = "现金",
    close              = "退出城镇地图画面",
  },

  -- "" unused.
  jukebox = {
    current_title      = "音乐盒",
    close              = "关闭音乐盒",
    play               = "播放",
    rewind             = "向后",
    fast_forward       = "向前",
    stop               = "停止播放",
    loop               = "循环播放",
  },

  bank_manager = {
    hospital_value     = "医院当前价值",
    balance            = "银行现金",
    current_loan       = "当前未偿还贷款",
    repay_5000         = "向银行偿还$5000",
    borrow_5000        = "向银行借款$5000",
    interest_payment   = "每月利息支付",
    inflation_rate     = "年通货膨胀率",
    interest_rate      = "年利率",
    close              = "关闭银行经理画面",
    insurance_owed     = "%s 欠款的金额", -- %s (name of debitor)
    show_graph         = "显示%s 支付曲线", -- %s (name of debitor)
    graph              = "显示%s 支付曲线", -- %s (name of debitor)
    graph_return       = "返回上个画面",
  },

  status = {
    win_progress_own   = "显示当前进展情况",
    win_progress_other = "显示当前%s 方面的进展情况", -- %s (name of competitor)
    population_chart   = "图表显示每个医院对当地居民的吸引程度",
    happiness          = "医院中所有人的总体快乐程度",
    thirst             = "医院中所有人的总体干渴程度",
    warmth             = "医院中所有人的总体温暖程度",
    close              = "关闭总览画面",

    -- Criteria to win
    reputation         = "您的声望必须至少有%d 。当前值为%d",
    balance            = "您的现金必须至少有$%d 。当前值为$%d",
    population         = "您至少需要总人口的%d%% 来访问您的医院",
    num_cured          = "您的目标是治愈%d 个病人。现在您已经治愈%d",
    percentage_killed  = "任务要求最多只能杀死%d 个就诊病人。到目前为止，您已经杀死了%d%% 个病人。",
    value              = "您的医院价值必须至少有$%d 。当前值为$%d",
    percentage_cured   = "您需要治疗%d%% 个前来就诊的病人。当前您已经治疗了%d%%",
  },

  policy = {
    close              = "关闭制度画面",
    staff_leave        = "点击这里可以让处于空闲状态的员工帮助其他员工",
    staff_stay         = "点击这里可以使所有员工停留在设定的房间内",
    diag_procedure     = "如果医生的诊断结果为，治愈概率小于设定的遣送回家百分比，则该病人将被自动遣送回家。如果治愈概率大于设定的尝试治疗百分比，则该病人将被自动送去进行治疗",
    diag_termination   = "对于一个病人的诊断将一直持续到设定的治疗结束百分比，或所有的诊断机器都已经尝试一遍",
    staff_rest         = "员工休息时的最低疲劳程度",
  },

  pay_rise_window = {
    accept             = "满足要求",
    decline            = "不付款－将他们解雇",
  },

  watch = {
    hospital_opening   = "建造计时器：它主要用来指示距离医院开门的时间多少。直接点击开门按钮就可以立即开门迎接客人。",
    emergency          = "紧急情况：剩余时间内尽快治愈所有急救病人。",
    epidemic           = "传染。：剩余时间内尽快阻止传染病蔓延。当时间耗尽或一个被传染病人离开医院，则卫生巡查员将出现。通过按钮可以切换预防接种模式开或者关。点击病人就可以让护士为其接种。",
  },

  rooms = {
    -- "" through "" unused.
    gps_office         = "病人在一般诊断室内接受初始诊断",
    psychiatry         = "精神病诊断治疗室可以治疗精神病患者同时也能帮助诊断其他病人，但是需要一位拥有精神病治疗技能的医生",
    ward               = "病房对于诊断和治疗都是非常有用的。病人手术前要在病房中观察一段时间。病房需要护士",
    operating_theatre  = "手术中心需要两名具备外科技能的医生",
    pharmacy           = "护士在药房为病人配药治疗",
    cardiogram         = "医生使用心电图室诊断病人",
    scanner            = "医生使用扫描仪房间诊断病人",
    ultrascan          = "医生使用超级扫描仪房间诊断病人",
    blood_machine      = "医生使用血液机器房间诊断病人",
    x_ray              = "医生使用X 光房间诊断病人",
    inflation          = "医生使用充气机房间治疗头部肿胀病人",
    dna_fixer          = "医生使用DNA 恢复装置房间治疗外星人DNA 病人",
    hair_restoration   = "医生使用毛发恢复房间治疗秃顶病人",
    tongue_clinic      = "医生使用舌头松弛诊断室治疗舌头松弛症病人",
    fracture_clinic    = "护士使用骨折诊所治疗骨折病人",
    training_room      = "专家使用培训室对其他医生进行培训",
    electrolysis       = "医生使用电分解房间治疗多毛症病人",
    jelly_vat          = "医生使用胶桶诊所治疗失衡患者",
    staffroom          = "医生和护士在员工休息室内可以恢复疲劳",
    -- rehabilitation  = "电视间报废", -- unused
    general_diag       = "医生使用高级诊断室为患者进行基本诊断。花费很少但效率很高",
    research_room      = "拥有研究技能的医生可以在研究部门开发新的药品和机器。",
    toilets            = "建造洗手间可以防止病人把医院弄得一团糟！",
    decontamination    = "医生使用净化淋浴装置可以治疗放射病",
  },

  objects = {
    -- "0 NULL OBJECT" unused.
    -- NB: most objects do not have a tooltip because they're not (extra-)buyable
    desk                 = "办公桌：医生可以在上面放置电脑。",
    cabinet              = "文件柜：包含了病人文件，备忘录以及研究档案。",
    door                 = "房门：人们出入房间时必需。",
    bench                = "长椅：为病人提供一个座位，使其可以比较舒适地等待。",
    table1               = "桌子（已删除）：摆放大量杂志，使等待的病人感到快乐。", -- unused
    chair                = "椅子：供病人使用，以讨论病情。",
    drinks_machine       = "饮料机：为病人止渴，也是收入来源之一。",
    bed                  = "床：病情严重的病人需要卧床。",
    inflator             = "充气机：治疗头部肿胀病患者。",
    pool_table           = "台球桌：帮助员工放松。",
    reception_desk       = "接待台：需要一名接待员为病人服务。",
    table2               = "12 OB_BTABLE", -- unused & duplicate
    cardio               = "13 OB_CARDIO", -- no description
    scanner              = "14 OB_SCANNER", -- no description
    console              = "15 OB_SCANNER_CONSOLE", -- no description
    screen               = "16 OB_SCREEN", -- no description
    litter_bomb          = "垃圾炸弹：来自对手医院的破坏活动",
    couch                = "18 OB_COUCH", -- no description
    sofa                 = "沙发：摆放在员工休息室中，员工如果没有更好的放松方式，则可以坐在上面恢复疲劳。",
    crash_trolley        = "20 OB_CRASH", -- no description
    tv                   = "电视：使员工不会错过喜爱的节目。",
    ultrascanner         = "22 OB_ULTRASCAN", -- no description
    dna_fixer            = "23 OB_DNA_FIXER", -- no description
    cast_remover         = "24 OB_CAST_REMOVE", -- no description
    hair_restorer        = "25 OB_HAIR_RESTORER", -- no description
    slicer               = "26 OB_SLICER", -- no description
    x_ray                = "27 OB_XRAY", -- no description
    radiation_shield     = "28 OB_RAD_SHIELD", -- no description
    x_ray_viewer         = "29 OB_XRAY_VIEWER", -- no description
    operating_table      = "30 OB_OP_TABLE", -- no description
    lamp                 = "灯：照明用。", -- unused
    toilet_sink          = "洗手池：讲卫生的病人可以在洗手池中洗净脏手。如果没有足够的洗手池，病人将感到不高兴。",
    op_sink1             = "33 OB_OP_SINK_1", -- no description
    op_sink2             = "34 OB_OP_SINK_2", -- no description
    surgeon_screen       = "35 OB_SURGEON_SCREEN", -- no description
    lecture_chair        = "教室座位：接受培训的医生坐在上面，收听无聊的演讲。座位摆放得越多，则教室越大。",
    projector            = "37 OB_PROJECTOR", -- no description
    bed2                 = "未使用", -- unused duplicate
    pharmacy_cabinet     = "药房：用来保存药品",
    computer             = "计算机：关键的研究部件",
    atom_analyser        = "化学混合器：摆放在研究部门中，该机器可以加速全部研究进程。",
    blood_machine        = "42 OB_BLOOD_MC", -- no description
    fire_extinguisher    = "灭火器：降低治疗仪器爆炸所产生的危险。",
    radiator             = "暖气：保持医院内的温度。",
    plant                = "植物：使病人快乐并净化空气。",
    electrolyser         = "46 OB_ELECTRO", -- no description
    jelly_moulder        = "47 OB_JELLY_VAT", -- no description
    gates_of_hell        = "48 OB_HELL", -- no description
    bed3                 = "未使用", -- unused duplicate
    bin                  = "垃圾桶：放置垃圾。",
    toilet               = "洗手间：提供给病人使用。",
    swing_door1          = "52 OB_DOUBLE_DOOR1", -- no description
    swing_door2          = "53 OB_DOUBLE_DOOR2", -- no description
    shower               = "54 OB_DECON_SHOWER", -- no description
    auto_autopsy         = "验尸机：对研究新的治疗方法有很大帮助。",
    bookcase             = "书柜：放置医生的参考资料。",
    video_game           = "视频游戏：让您的员工在游戏中彻底放松。",
    entrance_left        = "58 OB_ENT_LDOOR", -- no description
    entrance_right       = "59 OB_ENT_RDOOR", -- no description
    skeleton             = "骨骼模型：主要用于培训",
    comfortable_chair    = "61 OB_COMFY_CHAIR", -- no description
  },
}

-- 34: staff titles, inserted further above

confirmation = {
  quit                 = "您已经选择了退出。您是否确定真的要退出游戏？",
  return_to_blueprint  = "您是否确定返回蓝图模式？",
  replace_machine      = "您是否确定将%s 汰换，需花费$%d ？", -- %s (machine name) %d (price)
  overwrite_save       = "该位置已储存游戏进度。您是否确定要将其覆盖？",
  delete_room          = "您是否希望拆除这个房间？",
  sack_staff           = "您是否确定要解雇该员工？",
  restart_level        = "您是否希望重新开始这个任务？", -- missing in some TH versions
  remove_destroyed_room = "你希望支付 $%d 拆除这个房间吗？",
  replace_machine_extra_info = "新机器的强度为 %d (现在 %d).",
}

bank_manager = {
  hospital_value    = "医院价值",
  balance           = "现金",
  current_loan      = "当前贷款",
  interest_payment  = "应付利息",
  insurance_owed    = "保险公司欠款",
  inflation_rate    = "通货膨胀率",
  interest_rate     = "利率",
  statistics_page = {
    date            = "日期",
    details         = "细节",
    money_out       = "支出",
    money_in        = "收入",
    balance         = "现金",
    current_balance = "当前现金",
  },
}

newspaper = {
  -- Seven categories of funny headlines. I think each category is related
  -- to one criterion you can lose to. TODO: categorize
  { "医生震惊四座", "玩弄上帝", "科学狂人的震撼", "实验室地板上摆放着什么", "查获一项危险的研究"            },
  { "酗酒", "外科医生醉酒", "挑剔的顾问", "外科医生的酒量", "外科医生痛饮失态", "外科医生的灵魂" },
  { "粗鲁的医生", "医生臭名远扬", "医生完了", "贪得无厌的医生"                       },
  { "篡改数据", "器官买卖犯罪", "银行危机", "调查基金数据"                       },
  { "医学工作者盗墓", "医生盗墓", "医生盗墓，人赃并获", "医生死期不远了", "超级渎职", "医生盗墓" },
  { "医生？庸医！", "庸医露馅了", "令人诅咒的诊断", "笨蛋专家",                      },
  { "医生真情放纵", "医生自我“手术”", "医生完了", "医生大丑闻", "医生搞得一团糟"            },
}

-- 39: letters
-- Letters are organized in another level, just like menu strings.
letter = {
  {
    "亲爱的%s//",
    "太令人惊奇了！您已经成功地经营了这个医院。卫生部的官员想要知道您是否有兴趣接手一个大项目。我们认为有一个工作对您很适合。薪水将达到$%d。怎么样。//",
    "您是否对%s医院的工作感兴趣？",
  },
  {
    "亲爱的%s//",
    "太棒了！您的医院经营得很好。我们又有了一些新的任务如果您喜欢新的挑战，可以接受这项任务。您不要勉强，但这项工作确实很适合您。薪水是$%d//",
    "您希望接管%s医院吗？",
  },
  {
    "亲爱的%s//",
    "在您接管这座医院期间，管理非常成功。因此，我们对您寄予厚望，并为您找到了一个新的工作。薪水将达到$%d，同时我们也希望您喜欢新的挑战。//",
    "您希望接手%s医院吗？",
  },
  {
    "亲爱的%s//",
    "恭喜！部门官员对您的能力赞不绝口。您是卫生部的第一高手。我们觉得您一定喜欢更困难的工作。您的薪水将达到$%d，但决定权在您手中。//",
    "您是否愿意在%s医院工作？",
  },
  {
    "亲爱的%s//",
    "您好。我们尊重您不希望离开这个迷人的医院，但是提醒您要仔细考虑。您的薪水将达到$%d，如果您愿意到其它医院工作并将其运行得很好。//",
    "您现在是否愿意移动到%s医院？",
  },
  {
    "亲爱的%s//",
    "恭喜。我们理解您在这个可爱的运行良好医院中工作的快乐心情，但是我们认为您现在应该为未来考虑。您的薪水将达到$%d，如果您决定调任。这是很值得考虑的。//",
    "您是否愿意接手%s医院？",
  },
  {
    "亲爱的%s//",
    "您好！卫生部想要知道您经过重新考虑是否决定仍然留在当前的医院中。我们很欣赏您现在那个可爱的医院，但我们觉得您如果愿意接受这个极富挑战性的工作，也一定能干得很好，并且您的薪水将达到$%d。//",
    "您是否愿意接手%s医院？",
  },
  {
    "亲爱的%s//",
    "您好。您否定了我们上一封信中提供的新医院，以及薪水$%d。我们觉得不论怎样，您必须重新考虑这个决定。我们已经为您准备了一个很好的工作。//",
    "您是否愿意接手%s医院？怎么样？",
  },
  {
    "亲爱的%s//",
    "您已经成功地证明了自己是医学界有史以来最棒的管理者。这样的成就一定要给予奖励，因此我们决定任命您为所有医院的至尊主席。这是一项光荣的工作，且薪水可以达到$%d。不论您走到那里，都将受到人们的热烈欢迎。//",
    "感谢您的努力工作。希望您好好享受未来的半退休生活。//",
    "",
  },
  {
    "亲爱的%s//",
    "恭喜您在我们指派的每个医院中的成功管理。您的成功表现使您可以自由出入世界各大城市。您将获得退休金$%d，再加上一辆轿车，我们希望您在旅途中能够促进各个医院管理水平的提高。//",
    "我们都为您感到骄傲。我们中间每个人都为您挽救生命感到由衷的感谢。//",
    "",
  },
  {
    "亲爱的%s//",
    "您的工作十分成功，我们从您身上获得了灵感。谢谢您管理了这么多个医院，并使它们都运行得很出色。我们将给予您终身工资$%d，并提供政府敞蓬轿车使您可以从一个城市到另一个城市，发表演讲告诉公众您是怎样在这么短的时间内达到如此成就。//",
    "您是所有人的榜样，毫无例外，世界上每个人都以您为荣。//",
    "",
  },
  {
    "亲爱的%s//",
    "您的成就使您成为最好的医院管理者。卫生部将向您提供$%d作为奖励，并召开庆祝会。整个世界都在为您沸腾，太棒了！//",
    "请接受我们的安排。如果您不再希望辛苦工作，我们将向您提供一辆轿车，且无论走到那里，都有警察为您开路。//",
    "",
  },
}

-- 40: object tooltips, inserted further above
-- 41: load menu, inserted further above

vip_names = {
  health_minister = "卫生部部长",
  "伟大的查普顿市长", -- the rest is better organized in an array.
  "南丁格尔",
  "来自荷兰的伯那德国王",
  "缅甸民主党领袖：昂山苏蒂",
  "克朗伯先生",
  "比利先生",
  "克劳福议员",
  "罗尼",
  "一个超级联赛球星",
  "拉里普罗斯特",
}

-- 43: credits
-- Maybe we could include them somewhere as a tribute. Maybe not.
-- Translators, please do not bother translating these...
original_credits = {
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  ":设计制作",
  ":牛蛙制造",
  "",
  ":冥王星开发组",
  ",",
  "Mark Webley",
  "Gary Carr",
  "Matt Chilton",
  "Matt Sullivan",
  "Jo Rider",
  "Rajan Tande",
  "Wayne Imlach",
  "Andy Bass",
  "Jon Rennie",
  "Adam Coglan",
  "Natalie White",
  "",
  "",
  "",
  ":编程",
  ",",
  "Mark Webley",
  "Matt Chilton",
  "Matt Sullivan",
  "Rajan Tande",
  "",
  "",
  "",
  ":美工",
  ",",
  "Gary Carr",
  "Jo Rider",
  "Andy Bass",
  "Adam Coglan",
  "",
  "",
  "",
  ":助理编程",
  ",",
  "Ben Deane",
  "Gary Morgan",
  "Jonty Barnes",
  "",
  "",
  "",
  ":助理美工",
  ",",
  "Eoin Rogan",
  "George Svarovsky",
  "Saurev Sarkar",
  "Jason Brown",
  "John Kershaw",
  "Dee Lee",
  "",
  "",
  "",
  ":游戏介绍",
  ",",
  "Stuart Black",
  "",
  "",
  "",
  ":音乐音效",
  ",",
  "Russell Shaw",
  "Adrian Moore",
  "",
  "",
  "",
  ":助理音乐",
  ",",
  "Jeremy Longley",
  "Andy Wood",
  "",
  "",
  "",
  ":配音",
  ",",
  "Rebecca Green",
  "",
  "",
  "",
  ":任务设计",
  ",",
  "Wayne Imlach",
  "Natalie White",
  "Steven Jarrett",
  "Shin Kanaoya",
  "",
  "",
  "",
  ":剧本",
  ",",
  "James Leach",
  "Sean Masterson",
  "Neil Cook",
  "",
  "",
  "",
  ":R&D",
  "",
  ":图形引擎",
  ",",
  "Andy Cakebread",
  "Richard Reed",
  "",
  "",
  "",
  ":R&D 支持",
  ",",
  "Glenn Corpes",
  "Martin Bell",
  "Ian Shaw",
  "Jan Svarovsky",
  "",
  "",
  "",
  ":库和工具",
  "",
  "Dos 和Win 95 库",
  ",",
  "Mark Huntley",
  "Alex Peters",
  "Rik Heywood",
  "",
  "",
  "",
  ":网络库",
  ",",
  "Ian Shippen",
  "Mark Lamport",
  "",
  "",
  "",
  ":声音库",
  ",",
  "Russell Shaw",
  "Tony Cox",
  "",
  "",
  "",
  ":安装程序",
  ",",
  "Andy Nuttall",
  "Tony Cox",
  "Andy Cakebread",
  "",
  "",
  "",
  ":支持",
  ",",
  "Peter Molyneux",
  "",
  "",
  "",
  ":测试经理",
  ",",
  "Andy Robson",
  "",
  "",
  "",
  ":测试主管",
  ",",
  "Wayne Imlach",
  "Jon Rennie",
  "",
  "",
  "",
  ":测试",
  ",",
  "Jeff Brutus",
  "Wayne Frost",
  "Steven Lawrie",
  "Tristan Paramor",
  "Nathan Smethurst",
  "",
  "Ryan Corkery",
  "Simon Doherty",
  "James Dormer",
  "Martin Gregory",
  "Ben Lawley",
  "Joel Lewis",
  "David Lowe",
  "Robert Monczak",
  "Dominic Mortoza",
  "Karl O'Keeffe",
  "Michael Singletary",
  "Andrew Skipper",
  "Stuart Stephen",
  "David Wallington",
  "",
  "And all our other Work Experience Play Testers",
  "",
  "",
  "",
  ":技术支持",
  ",",
  "Kevin Donkin",
  "Mike Burnham",
  "Simon Handby",
  "",
  "",
  "",
  ":市场",
  ",",
  "Pete Murphy",
  "Sean Ratcliffe",
  "",
  "",
  "",
  ":特别感谢",
  ",",
  "Tamara Burke",
  "Annabel Roose",
  "Chris Morgan",
  "Pete Larsen",
  "",
  "",
  "",
  ":公关",
  ",",
  "Cathy Campos",
  "",
  "",
  "",
  ":文档",
  ",",
  "Mark Casey",
  "Richard Johnston",
  "James Lenoel",
  "Jon Rennie",
  "",
  "",
  "",
  ":文档及包装盒设计",
  ",",
  "Caroline Arthur",
  "James Nolan",
  "",
  "",
  "",
  ":本地化项目经理",
  ",",
  "Carol Aggett",
  "",
  "",
  "",
  ":本地化工作",
  ",",
  "Sandra Picaper",
  "Sonia 'Sam' Yazmadjian",
  "",
  "Bettina Klos",
  "Alexa Kortsch",
  "Bianca Normann",
  "",
  "C 。T 。O 。S 。p 。A 。Zola Predosa (BO)",
  "Gian Maria Battistini",
  "Maria Ziino",
  "Gabriele Vegetti",
  "",
  "Elena Ruiz de Velasco",
  "Julio Valladares",
  "Ricardo Mart*nez",
  "",
  "Kia Collin",
  "CBG Consult",
  "Ulf Thor",
  "",
  "",
  "",
  ":生产",
  ",",
  "Rachel Holman",
  "",
  "",
  "",
  ":制片人",
  ",",
  "Mark Webley",
  "",
  "",
  "",
  ":联合制片人",
  ",",
  "Andy Nuttall",
  "",
  "",
  "",
  ":运作",
  ",",
  "Steve Fitton",
  "",
  "",
  "",
  ":行政",
  ",",
  "Audrey Adams",
  "Annette Dabb",
  "Emma Gibbs",
  "Lucia Gobbo",
  "Jo Goodwin",
  "Sian Jones",
  "Kathy McEntee",
  "Louise Ratcliffe",
  " ",
  " ",
  " ",
  ":公司管理",
  ",",
  "Les Edgar",
  "Peter Molyneux",
  "David Byrne",
  " ",
  " ",
  ":All at Bullfrog Productions",
  " ",
  " ",
  " ",
  ":特别感谢",
  ",",
  "弗莱利公园医院中每个人",
  "",
  ": 特别是",
  ",",
  "Beverley Cannell",
  "Doug Carlisle",
  "",
  "",
  "",
  ":中文版制作",
  ",",
  "飞龙工作室",
  "",
  "",
  "",
  ":监制/项目主管",
  ",",
  "曲洋",
  "",
  "",
  ":翻译：刘波",
  "",
  ":录音师：蓝信刚",
  "",
  "",
  ":配音：夏莉莉",
  "",
  "",
  "",
  ":中文版包装/手册设计",
  ",",
  "骆智中王越鹏",
  "",
  "",
  ":生产",
  ",",
  "杨平 张威",
  "",
  "",
  "",
  ":测试",
  ",",
  "罗耀 陈雷 赫闻 汤宇力",
  "",
  "",
  ":特别感谢",
  ",",
  "Les Edgar",
  "Rajan Tande",
  "Steve Fitton",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
  ".",
}

-- 44: faxes and disease descriptions (cause/symptoms/cure)
-- diseases were already covered above
fax = {
  debug_fax = {
    -- never seen this, must fbe a debug option of original TH
    -- TODO: make this nicer i we ever want to make use of it
    close_text = "嗨，哈，哈！",
    text1      = "BEST COUNT %d", -- %d
    text2      = "TOTAL PEOPLE IN HOSPITAL %d CHECKING AGAINST %d", -- %d %d
    text3      = "FIGURES  : DOCS %d  NURSES %d  AREA %d  ROOMS %d  PRICING %d", -- %d %d %d %d %d
    text4      = "FACTORS  : DOCS %d  NURSES %d  AREA %d  ROOMS %d  PRICING %d", -- %d %d %d %d %d
    text5      = "CONTRIBN : DOCS %d  NURSES %d  AREA %d  ROOMS %d  PRICING %d PERCENT", -- %d %d %d %d %d
    text6      = "THE FOLLOWING FACTORS ARE ALSO APPLIED",
    text7      = "REPUTATION: %d EXPECTED %d REDUCTION %d", -- %d %d %d
    text8      = "AMENITIES %d PEEPS HANDLED %d REDUCTION %d", -- %d %d %d
    text9      = "DISASTERS %d ALLOWED (MTHS) %d (%d)REDUCTION %d", -- %d %d %d %d
    text10     = "KILLS %d ALLOWED (MTHS) %d (%d) REDUCTION %d", -- %d %d %d %d
    text11     = "PEOPLE THIS MONTH %d", -- %d
  },

  emergency = {
    choices = {
      accept = "好的。我已做好准备处理紧急事件。",
      refuse = "不。我拒绝处理这个紧急事件。",
    },

    location = "在%s 发生了事故",
    num_disease = "%d 个病人患有%s ，他们需要紧急治疗。",
    cure_possible_drug_name_efficiency = "您已经拥有了要求的设备和技能。您拥有他们所需要的药品。药品%s 的疗效为%d%% 。",
    cure_possible = "由于您拥有准备和技能，所以您应该可以处理这个紧急事件。",
    cure_not_possible_build_and_employ = "您将需要建造一间%s 并雇佣一名%s",
    cure_not_possible_build            = "您将需要建造一间%s",
    cure_not_possible_employ           = "您将需要雇佣一名%s",
    cure_not_possible                  = "现在您还不能治疗这种疾病。",
    bonus                              = "处理这个紧急事件的最大奖金额为%d 。如果您失败了，则您的声望将大幅下降。",

    locations = {
      "赛澈化学药品工厂。",
      "斯尼得大学。",
      "派拉奎特园艺中心。",
      "危险物质研究机构。",
      "莫理斯舞蹈家协会。",
      "青蛙与公牛酒店。",
      "大戴维殡葬馆",
      "太子制革店。",
      "伯特二手石化产品商场",
    },
  },

  emergency_result = {
    close_text = "点击这里退出。",

    earned_money = "最大奖金额为$%d ，您得到了$%d 。",
    saved_people = "您挽救了%d 个病人，总共需要治愈%d 个。",
  },

  disease_discovered_patient_choice = {
    choices = {
      send_home = "送病人回家。",
      wait      = "让病人在医院中等一会儿。",
      research  = "将病人送到研究部门。",
    },

    need_to_build_and_employ = "如果您建造了一个%s 并雇佣了一名%s ，则您将获胜。",
    need_to_build            = "您必需建造一个%s 才能处理该疾病。",
    need_to_employ           = "雇佣一名%s 就可以处理该情况。",
    can_not_cure             = "您无法治疗该疾病。",

    disease_name             = "发现了新情况。该疾病为%s",
    what_to_do_question      = "您打算怎样处理这个病人？",
    guessed_percentage_name  = "您的员工正在尝试治疗该病人。我们有%d%% 的几率治愈该病：%s",
  },

  disease_discovered = {
    close_text = "新发现了一种疾病。",

    can_cure = "您可以处理这种疾病。",
    need_to_build_and_employ = "如果您建造了一个%s 并雇佣了一名%s ，则您将获胜。",
    need_to_build            = "您必需建造一个%s 才能处理该疾病。",
    need_to_employ           = "雇佣一名%s 就可以处理这种危机。",

    discovered_name          = "您的员工发现了一种新的疾病。它是%s",
    -- After this come cause, symptoms and cure of disease
  },

  epidemic = {
    choices = {
      declare  = "宣布一种传染病。支付罚款且名誉受损。",
      cover_up = "在指定时间内且病人离开医院之前，尽量治愈所有被感染的病人。",
    },

    disease_name             = "医生发现了传染病%s 。",
    declare_explanation_fine = "如果您宣布出现传染。，则您将支付罚款%d ，且名誉受损。所有病人将自动被接种疫苗。",
    cover_up_explanation_1   = "如果您想要掩盖传染。，您将必须在有限时间内，即卫生巡查员到来之前，治愈所有被传染的病人。",
    cover_up_explanation_2   = "如果卫生巡查员到达，并发现了您正在试图掩盖传染。，则他将对您采取严厉的惩罚。",
  },

  epidemic_result = {
    close_text = "哈！",

    failed = {
      part_1_name = "尝试掩盖病情，他们正面临着传染病%s 爆发。",
      part_2      = "医院中的员工已经制止了传染病向医院附近居民传播。",
    },
    succeeded = {
      part_1_name = "卫生巡查员听到了传闻，您的医院正在处理严重疾病%s 。",
      part_2      = "然而他还没有能够找到证实传闻的证据。",
    },

    compensation_amount  = "政府决定奖励您%d 作为补偿谣言对您医院声誉所造成的损失。",
    fine_amount          = "政府宣布全国紧急状态，并对您罚款%d 。",
    rep_loss_fine_amount = "报纸将整版报道此事。您的声望将大幅受损。另外，还要缴纳罚款%d 。",
    hospital_evacuated   = "会议决定只能疏散您的医院。",
  },

  vip_visit_query = {
    choices = {
      invite = "向贵宾发出邀请。",
      refuse = "找借口阻止贵宾访问。",
    },

    vip_name = "%s 希望能够访问您的医院！",
  },

  vip_visit_result = {
    close_text = "感谢您访问医院。",

    telegram          = "电报！",
    vip_remarked_name = "%s 访问医院结束后发表评论：",

    cash_grant = "您将得到奖金%d 。",
    rep_boost  = "您的声望在公众中是很好的。",
    rep_loss   = "您的声望因此受到损害。",

    remarks = {
      [1] = "医院太棒了。下次我生病一定要到那里去就诊。",
      [2] = "那就是我访问的医院。",
      [3] = "那是一个超级医院。并且我想知道更多一点。",
      [4] = "医院经营得太棒了。感谢您能够邀请我来访问。",
      [5] = "嗯。医院经营得还可以。",
      [6] = "我很欣赏您的医院。",
      [7] = "喔，有点差劲。您应多做一些改进。",
      [8] = "喔，亲爱的。这个地方可不怎么样。",
      [9] = "这是一个比较一般的医院。但坦白地讲，我希望能够做得更好。",
      [10] = "我为什么烦恼？这比看一场持续4 个小时的歌剧好多了！",
      [11] = "我为我所看到的感到恶心。这也是医院？胡说八道！",
      [12] = "我已经受够了！",
      [13] = "真是一个垃圾。我要争取关闭它。",
      [14] = "我从没有见过这样可怕的医院。真是丢人！",
      [15] = "我被震惊了。这也能称为医院！给我一点酒。",
    },
  },

  diagnosis_failed = {
    choices = {
      send_home   = "送病人回家。",
      take_chance = "尝试治疗病人。",
      wait        = "让病人多等待一会儿，您需要多建造一些诊断室。",
    },

    situation           = "我们已经对该病人尝试了所有可供使用的机器，但是仍然没有发现病因。",
    what_to_do_question = "我们将怎样处置这个病人？",
    partial_diagnosis_percentage_name = "我们有%d%% 的概率确定该病人所患疾病类型。",
  },
}

-- 45: strange texts, maybe linked to some cheat codes..
-- Seems we won't need them.

staff_descriptions = {
  misc = {
    "打高尔夫球。",
    "潜水运动。",
    "冰雕。",
    "喝葡萄酒。",
    "拉力车赛。",
    "蹦跳。",
    "收集啤酒盖子。",
    "喜欢跳水。",
    "喜欢冲浪运动。",
    "喜欢游泳。",
    "蒸馏威士忌酒。",
    "DIY专家。",
    "喜欢欣赏法国电影。",
    "玩地下城守护者游戏。",
    "拥有HGV执照。",
    "摩托车比赛。",
    "弹奏古典提琴。",
    "训练营救员。",
    "喜欢养狗。",
    "听收音机。",
    "经常洗澡。",
    "工作指导。",
    "种植蔬菜。",
    "义务巡警。",
    "展览。",
    "收集二战武器。",
    "重新摆放家具。",
    "听刺激音乐。",
    "杀虫。",
    "喜剧演员。",
    "议会调查人员。",
    "园艺家。",
    "走私假手表。",
    "唱歌。",
    "喜欢日间电视。",
    "喜欢鲑鱼。",
    "向观光者介绍博物馆。",
  },
  good = {
    "手脚勤快并努力的员工。",
    "很有责任心。非常细心。",
    "掌握了很多技术。",
    "很友善并爱笑。",
    "富有活力。",
    "很有礼貌并和蔼可亲。",
    "富有才干和能力。",
    "工作能力极强。",
    "意志坚强。",
    "微笑着为病人服务。",
    "迷人的，有礼貌的并爱帮助别人。",
    "专注于工作。",
    "本性善良，工作努力。",
    "忠实且待人友善。",
    "细心并能够独立处理紧急事件。",
  },
  bad = {
    "动作缓慢，且爱烦恼。",
    "懒惰。",
    "培训很少且没有精神。",
    "待人粗鲁。",
    "态度恶劣。",
    "耳聋。且身上有一股卷心菜的味道。",
    "不用心工作。",
    "鲁莽而且容易犯错误。",
    "容易犯错误。",
    "心理变态。",
    "粗心大意。",
    "懒散。",
    "愚蠢。",
    "狡猾且有破坏欲。",
    "傲慢自大。",
  },
}

queue_window = {
  num_in_queue       = "队伍长度",
  num_expected       = "预期",
  num_entered        = "访问者人数",
  max_queue_size     = "最大长度",
}

-- TODO: continue here with section 50
-- ...

-- 54:  Introduction texts to each level
introduction_texts = {
  level1 =
    "欢迎来到您的第一座医院！//" ..
    "首先要摆放接待台，建造一般诊断室，并雇佣一名接待员和一名医生。" ..
    "随后就可以等待开张了。" ..
    "建造精神病诊断治疗室并雇佣一名精神病医生是一个好主意。" ..
    "药房和护士也是治疗病人所必需的。" ..
    "建造一个充气机房间就可以治疗头部肿胀患者。" ..
    "您需要治愈10个病人，并使声望保持在200以上。",
  level2 =
    "在该区域内还有一些其它的疾病。" ..
    "建造医院从而可以治疗更多的病人，并应该考虑建造研究部门。" ..
    "记住保持内部的清洁，从而使声望尽可能地高－您将遇到患有舌头松弛症的病人，因此需要建造舌头诊治房间。" ..
    "您也可以建造心电图房间来帮助诊断疾病。" ..
    "这些房间都需要经过研究才能够被建造。现在你可以购买其它土地扩展医院－使用城镇地图就可以购买土地。" ..
    "目标是声望300，银行现金为10000，且治愈40个病人。",
  level3 =
    "这次您将在一个富裕地区建造医院。" ..
    "卫生部希望您能够在这里赚取更多的利润。" ..
    "开始时您被要求获取好的声望，但是一旦医院步入正轨，就可以集中精力赚取更多的钱。" ..
    "有可能会发生紧急事件。" ..
    "也就是说一次会有大量病人就诊，且他们的病情都一样。" ..
    "在时间限制内如果能够治愈他们，则不仅可以拿到奖金，声望也会提高。" ..
    "一些疾病如猫王综合症等有可能发生，因此最好建造一间手术中心和附属病房。" ..
    "胜利条件是赚取$20,000。",
  level4 =
    "使所有的病人快乐，保持治疗的高效率并尽量降低死亡人数。" ..
    "声望是十分重要的，因此尽量赢得更高的声望。" ..
    "不要太多担心收入情况－当声望提高了，收入也自然会提高。" ..
    "您需要培训您的医生，拓宽他们的能力。" ..
    "这样他们就可以更好的为病人服务。" ..
    "胜利条件是声望达到500以上。",
  level5 =
    "医院将非常繁忙，处理各种各样的病人。" ..
    "医生都是刚刚毕业的实习医生，因此需要建造一间培训室对他们进行培训，提高能力。" ..
    "您只有3名专家可以帮助培训这些员工，因此一定要让专家快乐。" ..
    "另外要注意的是，医院的位置不是很好。" ..
    "经常会发生地震。" ..
    "地震将对医院中的机器产生损坏，从而影响医院的运营。" ..
    "使您声望达到400以上，现金达到$50,000。另外需要治愈200个病人。",
  level6 =
    "使用您的所有知识来建造一个运行平稳的医院，从而可以赚取利润并处理任何问题。" ..
    "您需要注意一点，医院周围的空气对细菌繁殖，传染病流行非常适宜。" ..
    "如果您没有保持医院的清洁，则将面对传染病的流行。" ..
    "赚取$150,000，并使医院价值超过$140,000。",
  level7 =
    "在这里您将受到卫生部的密切监察，因此要在赚钱的同时，努力提高自己的声望。" ..
    "我们无法处理太多的医疗事故－这对于医院的运营是十分不利的。" ..
    "确认所有员工都很快乐，并确认已经购买了所有需要的仪器装备。" ..
    "声望需要达到600，且银行里需要有$200,000。",
  level8 =
    "需要您来建造一座高效的医院。" ..
    "很多人都无事可做，因此需要适量的裁员以保持高效。" ..
    "记住治愈病人是很重要的一件事情，但是您更要从中赚钱。" ..
    "让恶心呕吐的病人靠近清洁工人。" ..
    "需要赚取$300,000就可以过关。",
  level9 =
    "当填满了卫生部的银行帐户并为部长大人购买了一辆轿车后，您现在又要开始新的工作了。" ..
    "在这里您要面对很多问题。" ..
    "只有拥有足够经验充分的员工和房间，您才能够顺利过关。" ..
    "医院价值需要达到$200,000，且银行帐户上要有$400,000。" ..
    "如果无法达到上述要求，则无法胜利完成任务。",
  level10 =
    "随着您的经验不断增长，卫生部要求您集中精力提高药品的治疗效果。" ..
    "有人对您颇有微辞，为此您必须使所有的药物都非常有效。" ..
    "另外，一定要降低医疗事故的发生次数，减少死亡人数。" ..
    "作为提示，您需要为建造胶桶留一些空地。" ..
    "使所有药物的疗效都达到80%%，声望达到650且在银行帐户上有$500,000，这样就可以胜利过关。",
  level11 =
    "现在您有机会建造一座终极医院。" ..
    "该地区享有极高的声望，因此卫生部希望能够看到最好的医院建造在这里。" ..
    "我们希望您能够赚取大量的金钱，获得很高的声望，并能够成功地处理任何事件。" ..
    "这是一项非常重要的工作。" ..
    "这需要您的努力工作。" ..
    "注意一点，该区域常常会看到不明飞行物。因此请让您的员工做好准备迎接不速之客。" ..
    "您的医院价值需要达到$240,000，在银行帐户内需要$500,000，且声望需要达到700。",
  level12 =
    "您现在遇到了最大的挑战。" ..
    "我们为您的成功感到由衷地高兴，卫生部为您准备了一项顶级工作；他们需要有人建造另一个超级医院，赚钱的同时获取较高的声望。" ..
    "您可以购买任何需要的土地，治疗各种疾病赢得各种奖励。" ..
    "动心了吗？" ..
    "赚取$650,000，治愈750个病人，使声望达到800就可以胜利过关。",
  level13 =
    "您的高超管理技能被特殊机密部门获知。" ..
    "他们将向您提高特别奖金，因为他们有一座被老鼠困扰的医院需要有效管理。" ..
    "您必须杀死尽可能多的老鼠，并让清洁工人打扫干净。" ..
    "接受这个任务？",
  level14 =
    "这里还有一个挑战－一个充满惊奇的医院。" ..
    "如果您能够成功完成这个任务，则您将成为所有胜利者中的佼佼者。" ..
    "不要认为完成这个任务就象吃蛋糕一样，这将是您所遇到的最艰苦的工作。" ..
    "祝您好运！",
  level15 =
    "好的，下面是管理医院的一些技巧。//" ..
    "医生需要各种帮助来诊断病人。您可以" ..
    "建造另一个诊断类房间，例如高级诊断室。",
  level16 =
    "当对病人完成诊断后，需要建造处理和治疗类房间完成对病人的治疗工作。可以从" ..
    "建造药房开始。在药房中需要一名护士分配各种药品。",
  level17 =
    "最后的警告－时刻关注您的声望－这是真正吸引病人前来就诊的关键。" ..
    "如果您没有杀死太多的病人，且使就诊病人保持快乐，则不必太担心声望！" ..
    "决定权就在您的手中。祝您好运。",
  level18 = "",
}

-- 55: Award texts inserted in the trophy room section (27)

-- 57: Information texts for the different rooms
room_descriptions = {
  ultrascan = {
    "超级扫描仪//",
    "超级扫描仪是诊断类仪器中最重要的。它虽然花费惊人，但效果卓著，可以使医院对病人的诊断达到完美。//",
    "超级扫描仪需要医生。它也需要维护。",
  },
  gp = {
    "一般诊断室//",
    "这是您的医院中一个基本诊断房间。就诊病人将到这里来检查病因。随后再决定是做进一步的诊断还是立即治疗。如果一间普通诊断室不够用，则您可以再建造另一间。房间越大，则可以在里面摆放更多的特殊物品，从而使医生的威信越高。这对于其它房间也是一样的。//",
    "一般诊断室需要一名医生。",
  },
  fracture_clinic = {
    "骨折诊所//",
    "骨折患者将到这里来接受治疗。石膏剥离装置将使用高能激光将坚硬的石膏切开，而病人只需忍受很小的痛苦。//",
    "骨折诊所需要一名护士。它也需要日常维护。",
  },
  tv_room = {
    "电视房间没有使用",
  },
  inflation = {
    "充气机诊所//",
    "患有头部肿胀症的病人需要在充气机诊所接受治疗，病人膨胀的头盖骨将被去掉，并对脑袋重新充气到正常大小。//",
    "充气机诊所需要医生。它也需要清洁工人的维护。",
  },
  jelly_vat = {
    "胶桶诊所//",
    "对于患有失衡症的患者需要到胶桶诊所接受治疗，在这里将被放入胶桶中。该治疗方法的原理医学界目前还无法完全理解。//",
    "胶桶诊所需要医生。它也需要清洁工维护机器。",
  },
  scanner = {
    "扫描仪//",
    "通过扫描仪病人得到确诊。随后他们就可以到一般诊断室接受进一步的治疗指示。//",
    "扫描仪需要医生。它也同样需要维护。",
  },
  blood_machine = {
    "血液机器//",
    "血液机器也是一种诊断用仪器，通过它可以检查病人的血液细胞，从而找出病人的病因。//",
    "血液机器需要医生。它也需要维护。",
  },
  pharmacy = {
    "药房//",
    "被诊断且需要接受药物治疗的病人一定要到药房去抓药。当越来越多的药品被研制出来。该房间也将变得越来越繁忙。这时就需要再建造一间药房。//",
    "药房需要一名护士。",
  },
  cardiogram = {
    "心电图仪//",
    "病人在这里被诊断检查，随后再到一般诊断室接受治疗提示。//",
    "心电图仪需要医生。当然它也需要维护。",
  },
  ward = {
    "病房//",
    "病人在病房中停留一段时间，以便护士进行观察。随后再做手术。//",
    "病房需要一名护士。",
  },
  psych = {
    "精神病诊断治疗室//",
    "被诊断为精神有问题的病人必须到精神病诊断治疗室中接受治疗。精神病医生可以对病人进行诊断，发现其病因，且如果确实是心理问题，将使用长沙发椅对其进行治疗。//",
    "精神病诊断治疗室需要一名具有精神病治疗技能的医生。",
  },
  staff_room = {
    "员工休息室//",
    "您的员工感觉疲劳时，需要房间来放松紧张的神经，从而恢复疲劳。处于极度疲劳的员工效率很低，并不时要求加薪，甚至不辞而别。他们还会常常犯错误。建造一个员工休息室，并在里面摆放尽可能多的物品，这是十分值得的。请确认该房间可以同时使多名员工得到休息。",
  },
  operating_theatre = {
    "手术中心//",
    "它可以提供非常重要的治疗手段。手术中心必须要有足够的尺寸，必须配置适当的仪器设备。它将是医院中最重要的部门。//",
    "手术中心需要两名拥有外科技能的医生。",
  },
  training = {
    "培训室//",
    "您的实习医生和医生在该房间内可以得到特殊技能的培训。拥有外科，研究或精神病技能的专家将把自己的经验传授给接受培训的医生。对于已拥有这些技能的医生，他们的能力将大幅提高。//",
    "培训室需要一名专家。",
  },
  dna_fixer = {
    "DNA诊所//",
    "这些有外星人DNA的病人必须在这里恢复其原有的DNA。DNA修复装置是最复杂的仪器，因此一定要在其房间内摆放一个灭火器，以防万一。//",
    "这台DNA修复装置需要清洁工不时维护。它也需要一名具有研究能力的医生才能够正常工作。",
  },
  research = {
    "研究室//",
    "在研究室可以研制新的药品和治疗方法，并对各种仪器进行改进提高。这是医院中的一个重要部门，并对提高医院的治愈率产生绝对影响。//",
    "研究室需要一名拥有研究技能的医生。",
  },
  hair_restoration = {
    "毛发恢复诊所//",
    "对于身患秃顶的病人将被送到该毛发恢复诊所，使用其中的毛发恢复装置进行治疗。需要一名医生操作机器，且该机器将很快地使病人的脑袋长满头发。//",
    "毛发恢复诊所需要医生。它也需要维护。",
  },
  general_diag = {
    "高级诊断室//",
    "需要进一步诊断的病人将被送到这里。如果一般诊断室无法发现病人的病因，高级诊断室将有可能找出。诊断结束后，他们将返回一般诊断室分析结果。//",
    "高级诊断室需要医生。",
  },
  electrolysis = {
    "电分解房间//",
    "多毛症患者将到该房间接受电分解机器的治疗，该机器将猛拉毛发并使用一种混合物填充毛孔。//",
    "电分解房间需要医生。它也需要清洁工进行维护。",
  },
  slack_tongue = {
    "舌头松弛治疗诊所//",
    "在普通诊断室中被诊断为舌头松弛的病人将被送到该诊所接受治疗。医生将使用一种高科技的仪器使舌头伸直并切掉多余部分，从而使病人恢复正常。//",
    "舌头松弛诊所需要医生。它也需要日常维护。",
  },
  toilets = {
    "洗手间//",
    "当病人感到需要上厕所时就需要洗手间这类设施。如果您希望洗手间多一些访问者，可以在其中多摆放洗手池和马桶请考虑在医院的其它位置也建造一些附属设施。",
  },
  no_room = {
    "",
  },
  x_ray = {
    "X光机//",
    "X光机可以使用特殊辐射为病人照内部透视照片。它对于医生诊断病因有很大帮助。//",
    "X光机需要医生。它也需要维护。",
  },
  decontamination = {
    "净化诊所//",
    "对于被暴露在强放射性的病人需要快速送到净化诊所。该房间包含了一个淋浴器，可以将病人身上的放射能清除干净。//",
    "净化淋浴器需要医生。它也需要清洁工人维护。",
  },
}

-- 59: The dynamic info bar

dynamic_info = {
  patient = {
    actions = {
      dying                       = "快死了！",
      awaiting_decision           = "等待您的决定",
      queueing_for                = "排队等待%s", -- %s
      on_my_way_to                = "在去%s 的路上", -- %s
      cured                       = "治愈！",
      fed_up                      = "受够了，要离开",
      sent_home                   = "遣送回家",
      sent_to_other_hospital      = "指派到其它医院",
      no_diagnoses_available      = "无法诊断－我要回家了",
      no_treatment_available      = "无法治疗－我要回家了",
      waiting_for_diagnosis_rooms = "等待建造更多的诊断室",
      waiting_for_treatment_rooms = "等待为我建造一间治疗室",
      prices_too_high             = "费用太高了－我要回家了",
      epidemic_sent_home          = "被巡查员赶回家",
      epidemic_contagious         = "我有传染病",
    },
    diagnosed                   = "诊断：%s", -- %s
    guessed_diagnosis           = "尝试诊断：%s", -- %s
    diagnosis_progress          = "诊断过程",
    emergency                   = "紧急情况：%s", -- %s (disease name)
  },
  vip                           = "来访贵宾",
  health_inspector              = "卫生巡查员",

  staff = {
    psychiatrist_abbrev         = "精神分析",
    actions = {
      waiting_for_patient         = "等待病人",
      wandering                   = "正在到处走动",
      going_to_repair             = "前往维修%s", -- %s (name of machine)
      vaccine = "正在注射疫苗",
    },
    tiredness                   = "疲劳",
    ability                     = "能力", -- unused?
  },

  object = {
    strength                    = "强度%d", -- %d (max. uses)
    times_used                  = "使用次数%d", -- %d (times used)
    queue_size                  = "排队人数%d", -- %d (num of patients)
    queue_expected              = "即将加入队伍人数%d", -- %d (num of patients)
    strength_extra_info = "强度 %d (升级到 %d)",
  },
}

-- 60: The progress report window

progress_report = {
  header                = "进展报告",
  very_unhappy          = "人们感到非常不高兴。",
  quite_unhappy         = "人们有点不高兴。",
  more_drinks_machines  = "多摆放一些饮料机。",
  too_hot               = "调节供热系统。太热了。",
  too_cold              = "太冷了。多摆放一些暖气。",
  percentage_pop        = "% 人口",
  win_criteria          = "获胜条件",
}


-------------------------------  OVERRIDE  ----------------------------------
vip_names[4] = "缅甸民主党领袖：昂山素季"  -- 昂山苏蒂
menu.debug = " 调试  "
progress_report.win_criteria = "获胜条件"


-------------------------------  NEW STRINGS  -------------------------------
date_format = {
  daymonth = "%2%月 %1%日",
}

object.litter = "废弃物"
tooltip.objects.litter = "废弃物：病人找不到垃圾桶，所以随意丢在了地上。"

object.rathole = "老鼠洞"
tooltip.objects.rathole = "老鼠一家，您的医院够脏了，住着很舒服。"

tooltip.fax.close = "关闭此窗口，但不删除消息"
tooltip.message.button = "点击打开消息"
tooltip.message.button_dismiss = "点击打开消息，右键点击忽略"
tooltip.casebook.cure_requirement.hire_staff = "您需要雇佣人员来治疗该疾病"
tooltip.casebook.cure_type.unknown = "您还不知道如何治疗该疾病"
tooltip.research_policy.no_research = "当前没有任何此类研究在进行中"
tooltip.research_policy.research_progress = "此类研究下次发现的进度: %1%/%2%"

menu["player_count"] = "玩家数"

menu_file = {
  load =    "  (%1%) 读取",
  save =    "  (%1%) 存储",
  restart = "  (%1%) 重新开始",
  quit =    "  (%1%) 退出"
}

menu_options = {
  sound = "  (%1%) 音效   ",
  announcements = "  (%1%) 公告   ",
  music = "  (%1%) 音乐   ",
  jukebox = "  (%1%) 音乐盒  ",
  lock_windows = "  锁定窗口  ",
  edge_scrolling = "  边缘滚动  ",
  capture_mouse = "  捕获鼠标  ",
  adviser_disabled = "  (%1%) 建议  ",
  warmth_colors = "  暖气区域显示  ",
  wage_increase = "  涨工资要求  ",
  twentyfour_hour_clock = "  24小时时钟  "
}

menu_options_game_speed = {
  pause               = "  (%1%) 暂停  ",
  slowest             = "  (%1%) 非常慢  ",
  slower              = "  (%1%) 较慢  ",
  normal              = "  (%1%) 正常  ",
  max_speed           = "  (%1%) 快速  ",
  and_then_some_more  = "  (%1%) 极快  ",
}

menu_options_warmth_colors = {
  choice_1 = "  红  ",
  choice_2 = "  蓝 绿 红  ",
  choice_3 = "  黄 橙 红  ",
}

menu_options_wage_increase = {
  grant = "    允许 ",
  deny =  "    拒绝 ",
}

-- Add F-keys to entries in charts menu (except briefing), also town_map was added.
menu_charts = {
  bank_manager  = "  (%1%) 银行经理",
  statement     = "  (%1%) 银行账户",
  staff_listing = "  (%1%) 员工管理",
  town_map      = "  (%1%) 城镇地图",
  casebook      = "  (%1%) 治疗手册",
  research      = "  (%1%) 研究",
  status        = "  (%1%) 状态",
  graphs        = "  (%1%) 图表",
  policy        = "  (%1%) 制度",
}

menu_debug = {
  jump_to_level               = "  跳关  ",
  connect_debugger            = "  (%1%) 连接 LUA DBGp 服务器  ",
  transparent_walls           = "  (%1%) 透明墙壁  ",
  limit_camera                = "  限制镜头  ",
  disable_salary_raise        = "  关闭涨工资要求  ",
  allow_blocking_off_areas    = "  允许导致空间无法到达的建造  ",
  make_debug_fax              = "  创建调试传真  ",
  make_debug_patient          = "  创建调试病人   ",
  cheats                      = "  (%1%) 作弊  ",
  lua_console                 = "  (%1%) LUA 控制台  ",
  debug_script                = "  (%1%) 运行调试脚本  debug_script.lua",
  calls_dispatcher            = "  签派窗口  ",
  dump_strings                = "  (%1%) 转存字符串  ",
  dump_gamelog                = "  (%1%) 转存游戏日志  ",
  map_overlay                 = "  地图层次  ",
  sprite_viewer               = "  贴图浏览器  ",
}
menu_debug_overlay = {
  none                        = "  无  ",
  flags                       = "  标记  ",
  positions                   = "  坐标  ",
  heat                        = "  温度  ",
  byte_0_1                    = "  字节 0 & 1  ",
  byte_floor                  = "  字节 地板  ",
  byte_n_wall                 = "  字节 北墙  ",
  byte_w_wall                 = "  字节 西墙  ",
  byte_5                      = "  字节 5  ",
  byte_6                      = "  字节 6  ",
  byte_7                      = "  字节 7  ",
  parcel                      = "  地区  ",
}
menu_player_count = {
  players_1 = "  1 玩家  ",
  players_2 = "  2 玩家  ",
  players_3 = "  3 玩家  ",
  players_4 = "  4 玩家  ",
}
adviser = {
  room_forbidden_non_reachable_parts = "在这个地方放置房间会导致医院的部分空间无法到达。",
  warnings = {
    no_desk = "你总得有个接待台吧！",
    no_desk_1 = "你得有个接待台，这样才会有病人来！",
    no_desk_2 = "干的不错，基本上也是个世界纪录了吧：快一年了，一个病人都没有！如果你想继续当这个经理的话，你需要去雇一个接待员，然后给她一张接待台工作！",
    no_desk_3 = "你真是个天才，一年了连个接待台都没有！你怎么可能有任何的病人来？赶紧给我搞定，别在那里不务正业了！",
    no_desk_4 = "接待台需要一位接待员来接待来访的病人",
    no_desk_5 = "行了，接下来就是时间问题，应该很快就会有病人来！",
    no_desk_6 = "你已经雇了一位接待员，要不要给她建个接待台？",
    no_desk_7 = "你已经建了一个接待台，要不要雇一位接待员？除非解决这个问题，否则不会有病人来！",
    cannot_afford = "你没有足够的存款来雇这个人！", -- I can't see anything like this in the original strings
    cannot_afford_2 = "你没有足够的存款来做这件事！",
    falling_1 = "嘿！别开玩笑了，看看你都是怎么点鼠标的，你可能会伤到人！",
    falling_2 = "不要再胡搞了，跟有病似的？",
    falling_3 = "啊~有人受伤了，赶紧叫医生！",
    falling_4 = "这里是医院，不是主题公园！",
    falling_5 = "这里不适合逗人玩，他们是病人好吗？",
    falling_6 = "这里不是保龄球馆，应该对待病人如春天般温暖！",
    research_screen_open_1 = "你需要建设一个研究科室才能访问研究页面。",
    research_screen_open_2 = "这一关不能开展研究。",
    researcher_needs_desk_1 = "研究员需要一张桌子展开工作。",
    researcher_needs_desk_2 = "你的研究员对你允许他休息片刻表示感谢，但如果你想让每个人都工作，你需要给每个人一张桌子。",
    researcher_needs_desk_3 = "每个研究院需要自己的桌子。",
    nurse_needs_desk_1 = "每个护士都需要自己的桌子。",
    nurse_needs_desk_2 = "你的护士对你允许他休息片刻表示感谢，但如果你想让每个人都工作，你需要给每个人一张桌子。",
    low_prices = "%s的收费太低了。虽然来的人很多，但你赚不到什么钱。",
    high_prices = "%s的收费太贵了。虽然短期内能获得可观的利润，但最终没人会愿意来。",
    fair_prices = "%s的收费看起来很合理。",
    patient_not_paying = "病人没有支付%s的医药费，因为太贵！",
  },
  cheats = {
    th_cheat = "恭喜，你解锁了作弊选项！",
    roujin_on_cheat = "Roujin's challenge 已经开启！祝你好运...",
    roujin_off_cheat = "Roujin's challenge 关闭。",
    norest_on_cheat = "哇喔！似乎咖啡因使你的员工十分兴奋，永远不用休息。",
    norest_off_cheat = "呼～精神亢奋剂的效力过去了，员工现在恢复正常作息",
  },
}

dynamic_info.patient.actions.no_gp_available = "您需要建造一般诊断室"
dynamic_info.staff.actions.heading_for = "前往%s"
dynamic_info.staff.actions.fired = "已解雇"
dynamic_info.patient.actions.epidemic_vaccinated = "我已经没有传染性"

progress_report.free_build = "自由建设"

fax = {
  choices = {
    return_to_main_menu = "返回到主菜单",
    accept_new_level = "接手下一个医院",
    decline_new_level = "继续经营这个医院",
  },
  emergency = {
    num_disease_singular = "那里有一个人患了%s，他们需要马上救治。",
    free_build = "成功的话，你的声望就会上升，但你要是失败了，就会一落千丈。",
  },
  vip_visit_result = {
    remarks = {
      free_build = {
        "你的医院相当不错！没有预算的限制，搞定很容易吧？",
        "我不是一个经济学家，但我要是你我也行。你懂我啥意思……",
        "医院经营的不错。但要小心经济不景气。哦对了，你才不操那个心。",
      }
    }
  }
}

letter = {
  dear_player = "亲爱的 %s",
  custom_level_completed = "做得好！你已完成自定义游戏的所有目标！",
  return_to_main_menu = "你想要回到主菜单还是继续游戏？",
  campaign_level_completed = "干得好！你完成了这一关。但是还没有结束！\n您想在%s医院工作吗？",
  campaign_completed = "难以置信！你成功完成了所有关卡。你现在可以放松一下，然后去网上炫耀一番。祝你好运！",
  campaign_level_missing = "很抱歉，游戏的下一关似乎已丢失。（名称：%s）",
}

install = {
  title = "-------------------------------- CorsixTH  游戏设置 -------------------------------",
  th_directory = "CorsixTH 需要原版主题医院（或演示版）的数据文件才能运行。请指定原版主题医院游戏的安装文件夹。",
  ok = "确定",
  exit = "退出",
  cancel = "取消",
}

misc.not_yet_implemented = "（尚未实现）"
misc.no_heliport = "还没有疾病被发现，或者地图上需要一个直升机场。你可能需要建一个接待台，并雇用一位接待员"

main_menu = {
  new_game = "开始游戏",
  custom_campaign = "自定义任务",
  custom_level = "场景游戏",
  continue = "继续游戏",
  load_game = "载入游戏",
  options = "选项",
  map_edit = "地图编辑器",
  savegame_version = "存档版本：",
  updates_off = "已禁用更新检查",
  version = "版本：",
  exit = "退出",
}

tooltip.main_menu = {
  new_game = "从第一关开始新游戏",
  custom_campaign = "玩由社区设计的任务",
  custom_level = "在一个场景下建医院",
  continue = "从最近的存档继续玩",
  load_game = "载入存档",
  options = "调整各种设置",
  map_edit = "创建自定义地图",
  exit = "不要，不要，请不要退出游戏！",
  quit = "你将退出 CorsixTH。确定？",
}

load_game_window = {
  caption = "载入游戏 (%1%)",
}

tooltip.load_game_window = {
  load_game = "载入游戏 %s",
  load_game_number = "载入游戏 %d",
  load_autosave = "载入自动保存的游戏",
}

custom_game_window = {
  caption = "自定义游戏",
  free_build = "自由建设",
  load_selected_level = "开始",
}

tooltip.custom_game_window = {
  choose_game = "点击一个关卡以了解更多信息",
  free_build = "勾选此框，你将不需要为钱以及胜利失败而操心",
  load_selected_level = "加载并玩选定的关卡",
}

custom_campaign_window = {
  caption = "自定义任务",
  start_selected_campaign = "开始任务",
}

tooltip.custom_campaign_window = {
  choose_campaign = "点击一项任务以了解更多信息",
  start_selected_campaign = "加载任务第一关",
}

save_game_window = {
  caption = "保存游戏 (%1%)",
  new_save_game = "新游戏存档",
}

tooltip.save_game_window = {
  save_game = "覆盖游戏存档 %s",
  new_save_game = "输入新存档的名称",
}

save_map_window = {
  caption = "保存地图 (%1%)",
  new_map = "新地图",
}

tooltip.save_map_window = {
  map = "覆盖地图 %s",
  new_map = "输入新地图的名称",
}

menu_list_window = {
  name = "名称",
  save_date = "已修改",
  back = "返回",
  ok = "确定",
}

tooltip.menu_list_window = {
  name = "点击此按名称排序",
  save_date = "点击此按最后修改日期排序",
  back = "关闭此窗口",
  ok = "确定选取",
}

options_window = {
  caption = "设置",
  option_on = "开",
  option_off = "关",
  option_enabled = "已启用",
  option_disabled = "已禁用",
  fullscreen = "全屏幕",
  resolution = "分辨率",
  capture_mouse = "捕获鼠标",
  custom_resolution = "自定义...",
  width = "宽度",
  height = "高度",
  audio = "全局音效",
  customise = "自定义",
  folder = "文件夹",
  language = "语言",
  apply = "应用",
  cancel = "取消",
  back = "返回",
  scrollspeed = "滚动速度",
  shift_scrollspeed = "加速滚动速度",
  zoom_speed = "缩放速度",
  hotkey = "快捷键",
  check_for_updates = "自动检查更新",
}

tooltip.options_window = {
  fullscreen = "应该在全屏还是窗口模式运行",
  fullscreen_button = "点击切换全屏模式",
  resolution = "在此分辨率下运行游戏",
  select_resolution = "选择新的分辨率",
  capture_mouse = "点击切换是否将光标捕获在游戏窗口中",
  width = "输入想要的屏幕宽度",
  height = "输入想要的屏幕高度",
  apply = "应用此分辨率",
  cancel = "返回而不更改分辨率",
  audio_button = "开关所有的声音",
  audio_toggle = "切换开关",
  customise_button = "更多可以改变游戏体验的选项",
  folder_button = "文件夹选项",
  language = "游戏文字使用的语言",
  select_language = "选择语言",
  language_dropdown_item = "选择 %s 为语言",
  back = "关闭设置窗口",
  scrollspeed = "将滚动速度设为1（最慢）到10（最快）。默认为2。",
  shift_scrollspeed = "设定在滚动时按下 Shift 键时的滚动速度。1（最慢）到10（最快）。默认：4。",
  zoom_speed = "将相机变焦速度设为10（最慢）到1000（最快）。默认值为80。",
  apply_scrollspeed = "应用输入的滚动速度。",
  cancel_scrollspeed = "返回而不更改滚动速度。",
  apply_shift_scrollspeed = "应用输入的加速滚动速度。",
  cancel_shift_scrollspeed = "返回而不更改加速滚动速度。",
  apply_zoomspeed = "应用输入的缩放速度。",
  cancel_zoomspeed = "返回而不更改缩放速度。",
  hotkey = "更改键盘热键。",
  check_for_updates = "游戏启动时自动检查更新",
}

customise_window = {
  caption = "自定义设置",
  option_on = "开",
  option_off = "关",
  back = "返回",
  movies = "全局 CG 控制",
  intro = "播放启动 CG",
  paused = "建造时暂停",
  volume = "减小音量热键",
  aliens = "外星人只限紧急情况",
  fractured_bones = "骨折只限男性",
  average_contents = "房间常用物件",
  remove_destroyed_rooms = "移除已毁坏的房间",
}

tooltip.customise_window = {
  movies = "全局 CG 控制，这将允许您禁用所有 CG",
  intro = "关闭或打开启动 CG，如果您希望每次启动 CorsixTH 时都播放启动 CG，则必须打开全局 CG",
  paused = "在主题医院中，只有在游戏暂停的情况下，才允许玩家使用顶部菜单，这也是 CorsixTH 的默认设置。但是将此选项打开，游戏暂停时可以进行所有操作",
  volume = "如果减小音量按钮同时打开了治疗手册，请将打开治疗手册的快捷键更改为 Shift + C",
  aliens = "因为缺少合适的动画，默认外星人 DNA 病人只会来自紧急事件。要允许紧急事件外出现外星人 DNA 病人，请关闭此选项",
  fractured_bones = "由于动画效果不佳，默认不会有女性骨折患者。要允许女性骨折患者就诊，请关闭此功能",
  average_contents = "如果您想让游戏记住在建造房间时通常会添加哪些其他对象，请启用此选项。",
  remove_destroyed_rooms = "打开这个选项，使已毁坏的房间可以付费移除。",
  back = "关闭此菜单，并返回设置菜单",
}

folders_window = {
  caption = "文件夹位置",
  data_label = "TH 数据",
  font_label = "字体",
  music_label = "音乐",
  savegames_label = "存档",
  screenshots_label = "截图",
  -- next four are the captions for the browser window, which are called from the folder setting menu
  new_th_location = "您可以在此处指定新的主题医院安装目录。选择新目录后，游戏将重新启动。",
  savegames_location = "选择要用于保存的目录",
  music_location = "选择您要用于音乐的目录",
  screenshots_location = "选择您要用于屏幕截图的目录",
  back  = "返回",
}

tooltip.folders_window = {
  browse = "浏览文件夹位置",
  data_location = "原版主题医院安装的目录，CorsixTH 运行所必需",
  font_location = "选择可以显示您的语言所需 Unicode 字体的位置。如果没有指定，您将不能使用原游戏提供字体之外的语言，例如中文和俄语。（你一定已经选了，要不怎么可以看到这句话呢？）",
  savegames_location = "默认情况下，游戏存档存储在配置文件旁边的文件夹中。如果不合适，可以选择自己的目录，只需浏览到要使用的目录即可。",
  screenshots_location = "默认情况下，屏幕快照存储在配置文件旁边的文件夹中。如果不合适，可以选择自己的目录，只需浏览到要使用的目录即可。",
  music_location = "选择存储音乐文件的位置。此目录必须已经存在，然后才能浏览到刚创建的目录。",
  browse_data = "浏览另一处主题医院安装位置（当前位置：%1%）",
  browse_font = "浏览另一个字体（当前位置：%1%）",
  browse_saves = "浏览另一处游戏存档储存位置（当前位置：%1%）",
  browse_screenshots = "浏览另一处屏幕截图储存位置（当前位置：%1%）",
  browse_music = "浏览另一处音乐储存位置（当前位置：%1%）",
  no_font_specified = "没有指定字体的位置！",
  not_specified = "没有指定文件夹位置！",
  default = "默认位置",
  reset_to_default = "重置到默认文件夹",
  back = "关闭此菜单，并返回设置菜单",
}

hotkey_window = {
  caption_main = "快捷键分配",
  caption_panels = "面板键",
  button_accept = "接受",
  button_defaults = "重置为默认值",
  button_cancel = "取消",
  button_back = "返回",
  button_toggleKeys = "切换键",
  button_gameSpeedKeys = "游戏速度键",
  button_recallPosKeys = "载入视点键",
  panel_globalKeys = "全局键",
  panel_generalInGameKeys = "一般游戏内键",
  panel_scrollKeys = "滚动键",
  panel_zoomKeys = "缩放键",
  panel_gameSpeedKeys = "游戏速度键",
  panel_toggleKeys = "切换键",
  panel_debugKeys = "调试键",
  panel_storePosKeys = "保存视点键",
  panel_recallPosKeys = "载入视点键",
  panel_altPanelKeys = "替代面板键",
  global_confirm = "确认",
  global_confirm_alt = "确认（替代）",
  global_cancel = "取消",
  global_cancel_alt = "取消（替代）",
  global_fullscreen_toggle = "全屏",
  global_exitApp = "退出应用",
  global_resetApp = "重置应用",
  global_releaseMouse = "释放鼠标",
  global_connectDebugger = "调试器",
  global_showLuaConsole = " Lua 控制台",
  global_runDebugScript = "调试脚本",
  global_screenshot = "屏幕截图",
  global_stop_movie_alt = "停止 CG",
  global_window_close_alt = "关闭窗口",
  ingame_scroll_up = "向上滚动",
  ingame_scroll_down = "向下滚动",
  ingame_scroll_left = "向左滚动",
  ingame_scroll_right = "向右滚动",
  ingame_scroll_shift = "速度切换",
  ingame_zoom_in = "放大",
  ingame_zoom_in_more = "放大更多",
  ingame_zoom_out = "缩小",
  ingame_zoom_out_more = "缩小更多",
  ingame_reset_zoom = "重置缩放",
  ingame_showmenubar = "显示菜单栏",
  ingame_showCheatWindow = "作弊菜单",
  ingame_loadMenu = "载入游戏",
  ingame_saveMenu = "保存游戏",
  ingame_jukebox = "音乐盒",
  ingame_openFirstMessage = "关卡消息",
  ingame_pause = "暂停",
  ingame_gamespeed_slowest = "非常慢",
  ingame_gamespeed_slower = "较慢",
  ingame_gamespeed_normal = "正常",
  ingame_gamespeed_max = "快速",
  ingame_gamespeed_thensome = "极快",
  ingame_gamespeed_speedup = "加速",
  ingame_panel_bankManager = "银行经理",
  ingame_panel_bankStats = "银行状态",
  ingame_panel_staffManage = "员工管理",
  ingame_panel_townMap = "城镇地图",
  ingame_panel_casebook = "治疗手册",
  ingame_panel_research = "研究",
  ingame_panel_status = "状态",
  ingame_panel_charts = "图表",
  ingame_panel_policy = "制度",
  ingame_panel_map_alt = "城镇地图2",
  ingame_panel_research_alt = "研究2",
  ingame_panel_casebook_alt = "治疗手册2",
  ingame_panel_casebook_alt02 = "治疗手册3",
  ingame_panel_buildRoom = "建造房间",
  ingame_panel_furnishCorridor = "设置走廊",
  ingame_panel_editRoom = "编辑房间/物品",
  ingame_panel_hireStaff = "雇佣员工",
  ingame_rotateobject = "旋转对象",
  ingame_quickSave = "快速保存",
  ingame_quickLoad = "快速加载",
  ingame_restartLevel = "重启关卡",
  ingame_quitLevel = "退出关卡",
  ingame_setTransparent = "透明墙壁",
  ingame_toggleAnnouncements = "公告",
  ingame_toggleSounds = "声音",
  ingame_toggleMusic = "音乐",
  ingame_toggleAdvisor = "顾问",
  ingame_toggleInfo = "信息",
  ingame_poopLog = "转储日志",
  ingame_poopStrings = "转储字符串",
  ingame_patient_gohome = "遣送回家",
  ingame_storePosition_1 = "1",
  ingame_storePosition_2 = "2",
  ingame_storePosition_3 = "3",
  ingame_storePosition_4 = "4",
  ingame_storePosition_5 = "5",
  ingame_storePosition_6 = "6",
  ingame_storePosition_7 = "7",
  ingame_storePosition_8 = "8",
  ingame_storePosition_9 = "9",
  ingame_storePosition_0 = "10",
  ingame_recallPosition_1 = "1",
  ingame_recallPosition_2 = "2",
  ingame_recallPosition_3 = "3",
  ingame_recallPosition_4 = "4",
  ingame_recallPosition_5 = "5",
  ingame_recallPosition_6 = "6",
  ingame_recallPosition_7 = "7",
  ingame_recallPosition_8 = "8",
  ingame_recallPosition_9 = "9",
  ingame_recallPosition_0 = "10",
}

tooltip.hotkey_window = {
  button_accept = "接受上面的热键分配，并将其保存到磁盘",
  button_defaults = "将所有热键重置为程序的默认值",
  button_cancel = "取消分配，并返回选项菜单",
  caption_panels = "打开分配面板键的窗口",
  button_gameSpeedKeys = "开启游戏速度热键的窗口",
  button_recallPosKeys = "打开窗口以设置用于存储和调用摄像机位置的键",
  button_back_02 = "返回主热键窗口。在此窗口中更改的热键可在此处接受",
}

font_location_window = {
  caption = "选择字体 (%1%)",
}

handyman_window = {
  all_parcels = "所有地区",
  parcel = "地区"
}

tooltip.handyman_window = {
  parcel_select = "清洁工工作的地区，单击以更改设置"
}

new_game_window = {
  caption = "竞争上岗",
  player_name = "玩家名称",
  option_on = "开",
  option_off = "关",
  difficulty = "难度",
  easy = "实习医生（容易）",
  medium = "医生（一般）",
  hard = "专家（难）",
  tutorial = "游戏教程",
  start = "开始",
  cancel = "返回",
}

tooltip.new_game_window = {
  player_name = "输入你游戏中的名字",
  difficulty = "选择您要玩的游戏难度等级",
  easy = "如果您刚开始玩模拟游戏，选择此项",
  medium = "如果不确定要选择什么，选择中间这项",
  hard = "如果您熟悉这个游戏，想要有点挑战，选择此项",
  tutorial = "单击此处启用游戏上手教程",
  start = "使用当前设置开始游戏",
  cancel = "哦，我没打算真的开始新游戏！",
}

lua_console = {
  execute_code = "执行",
  close = "关闭",
}

tooltip.lua_console = {
  textbox = "输入 Lua 代码以运行",
  execute_code = "运行输入的代码",
  close = "关闭控制台",
}

errors = {
  dialog_missing_graphics = "哎呀，演示版数据文件不包含这个对话框。",
  save_prefix = "保存游戏失败：",
  load_prefix = "载入游戏失败：",
  no_games_to_contine = "无游戏存档。",
  load_quick_save = "错误，不存在快速存档，无法加载。不用担心，我们已经为您创建了一个！",
  map_file_missing = "找不到该关卡的地图文件 %s！",
  minimum_screen_size = "最小屏幕大小为 640x480。",
  unavailable_screen_size = "您设置的屏幕大小无法应用于全屏模式。",
  alien_dna = "注意：对于外星人病人来说，坐下、打开或敲门等都没有动画。因此，像在主题医院中做这些事情一样，它们看起来会恢复正常外观，然后又变回原状。外星人 DNA 仅当它们在关卡文件中设置启动时才会显示",
  fractured_bones = "注意：女性骨折患者的动画效果不理想",
  could_not_load_campaign = "无法加载任务：%s",
  could_not_find_first_campaign_level = "找不到该任务的第一关：%s",
  save_to_tmp = "文件无法保存到 %s 。文件改为保存到 %s 。问题: %s",
  dialog_empty_queue = "抱歉，程序遇到bug了。弹出窗口显示的这个人员没有被安排指令（empty action queue），请你决定把他叫离医院或进行其他动作。",
  compatibility_error = {
    demo_in_full = "抱歉，这是演示版的游戏存档，无法在完整版中打开。请更新原版主题医院目录内容。",
    full_in_demo = "抱歉，这是完整版的游戏存档，无法在演示版中打开。请更新原版主题医院目录内容。",
    new_in_old = "抱歉，此游戏存档需要较新版本的 CorsixTH 才能打开。",
  },
}

warnings = {
  levelfile_variable_is_deprecated = "注意：关卡'%s'在关卡文件中包含弃用的变量定义。" ..
                                     "'%LevelFile'已重命名为'%MapFile'。请建议地图创建者更新关卡。",
  newersave = "警告：此游戏存档是由较新版本 CorsixTH 创建的。不建议继续进行游戏，否则可能会出现错误。一般来说，仅作测试用途。",
}

confirmation = {
  needs_restart = "这项设置的改动需要重新启动 CorsixTH。尚未保存的进度将会丢失。确定要这么做吗？",
  abort_edit_room = "您正在修建或者修改一间房间。如果所有必需的物品都被放置了就没有问题，否则所做的修改将被删除。继续吗？",
  maximum_screen_size = "您输入的屏幕尺寸大于 3000x2000。可以使用更大的分辨率，但需要更好的硬件才能保持可播放的帧速率。继续吗？",
}

information = {
  custom_game = "欢迎来到 CorsixTH。尽情享受自定义地图吧！",
  no_custom_game_in_demo = "抱歉，在演示版本中，您无法玩任何自定义地图。",
  cannot_restart = "不幸的是这个自定义地图是在 重新开始 功能开发之前创建的。",
  very_old_save = "从您开始玩此关以来，游戏已有许多更新。为确保所有功能均按预期工作，请考虑重新启动它。",
  level_lost = {
    "您失败了！游戏结束。下次好运！",
    "由于：",
    reputation = "声望低于%d。",
    balance = "银行账户资金低于%d。",
    percentage_killed = "杀死了多于%d%%的病人。",
    cheat = "这是你的选择，还是选择了错误的按钮？你甚至连作弊都不会，不是那么有趣吧？",
  },
  cheat_not_possible = "无法在这关上使用此项作弊。你甚至连作弊都失败了，不是那么有趣吧？",
}

tooltip.information = {
  close = "关闭信息对话框",
}

totd_window = {
  tips = {
    "医院想开张就需要一个前台桌子和一个问诊室。这之后还需要根据不同病人建立各种房间。但有个药房总是对的。",
    "有一些机器需要维护，比如说充气机。所以雇一两个修理人员还是必要的，不然那就是个定时炸弹。",
    "你的员工会不时感到疲倦。所以建一间休闲室也很必要。",
    "多放点几个暖气，让你的员工和病人感到春天般温暖。用全景地图来查看它们的覆盖面积以决定是否还需要多放些。",
    "一个医生的医疗水平很大程度影响他的诊断速度。把最牛逼的医生放在问诊室，这样你会省下其他的问诊室。",
    "实习生和医生们可以通过在学习室向专家学习来提高水平。如果请来的专家拥有某一项专长（外科医生，精神病医生或研究员），他也会教给他的学生们。",
    "有没有试过在传真机上拨112？这是欧洲的急救电话。记得将音量调到最大！",
    "在主菜单和游戏菜单里面，找到选项窗口，在那里可以调整分辨率和语言。",
    "你选择了中文，但是你还是可能会在游戏中不停地看到英文。把他们翻译了吧，我们需要你的帮助！",
    "CorsixTH 小组正在壮大！如果你对编程、翻译、创作主题医院需要的图片等等任何方面感兴趣，可以到 CorsixTH 网站找到开发、社群等信息。",
    "如果你碰到了 bug，请提交给我们: th-issues.corsix.org",
    "每一关都需要满足特定的条件才能过关。你可以通过状态窗口看到你的进度。",
    "如果你需要编辑或者删除一间房间，屏幕下方找到工具栏，然后点编辑房间按钮。",
    "在成群结队等待就诊的病人中，你可以通过指向房间的门来找到哪些病人在等。",
    "点击房间门可以看到等待队列。你可以做些调整让某些人走个后门，或者送到另一个房间去。",
    "不开心的员工只有通过涨薪来平衡自己了。你要保证你的员工的工作环境像家一样，才能让他们甘心给你卖命。",
    "病人等的时间长了，会口渴，如果开了暖气，口渴得会更快！放些自动贩卖机吧，还能多些零花钱。",
    "如果你见过某种病，你可以中断诊疗过程直接去治，治死了不要找我。",
    "从紧急事件总能赚一大笔，但是你要按时处理好才行。",
    "你知道可以指定清洁工人工作的地区吗？打开他的数据窗口，点击“所有地区”文字便可设置地区。",
  },
  previous = "前一项提示",
  next = "下一项提示",
}

tooltip.totd_window = {
  previous = "显示上一项提示",
  next = "显示下一项提示",
}

debug_patient_window = {
  caption = "调试病人",
}

cheats_window = {
  caption = "作弊",
  warning = "警告: 如果作弊关卡结束时你将得不到任何奖励！",
  cheated = {
    no = "作弊了吗: 否",
    yes = "作弊了吗: 是",
  },
  cheats = {
    money = "给我钱！！",
    all_research = "所有研究",
    emergency = "紧急事件",
    vip = "贵宾",
    earthquake = "地震",
    epidemic = "生成传染性病人",
    toggle_infected = "切换感染图标",
    create_patient = "生成病人",
    end_month = "月末",
    end_year = "年末",
    lose_level = "失败",
    win_level = "获胜",
    increase_prices = "涨价",
    decrease_prices = "降价",
  },
  close = "关闭",
}

tooltip.cheats_window = {
  close = "关闭作弊对话框",
  cheats = {
    money = "增加10,000存款。",
    all_research = "完成所有的研究。",
    emergency = "创建一次紧急事件。",
    vip = "创建一位贵宾。",
    earthquake = "制造一次地震。",
    epidemic = "创建一位可能导致流行病传染的传染性患者",
    toggle_infected = "切换感染图标，以发现活跃的流行病",
    create_patient = "在地图的边缘生成一个病人。",
    end_month = "跳到月末。",
    end_year = "跳到年末。",
    lose_level = "在当前关卡败北。",
    win_level = "赢得当前关卡。",
    increase_prices = "所有项目涨价50%（最大200%）",
    decrease_prices = "所有项目降价50%（最小50%）",
  },
}

introduction_texts = {
  demo =
    "欢迎来到演示版医院！//" ..
    "演示版本只有当前这一个关卡。但有一堆事情足够你忙一阵了！ " ..
    "你将会遇到各种疾病需要各种医疗室来救治。紧急情况也会经常性地发生。你需要通过研究室来研发更多的医疗室。" ..
    "你的目标是挣够$100,000，使医院的价值达到$70,000以及得到700声望值，同时你还需要救治超过75%的病人。" ..
    "确保你的声望值不会掉到300以下，你的病人死亡率不超过40%，否则你就完了。//" ..
    "祝你好运！",
}

calls_dispatcher = {
  -- Dispatcher description message. Visible in Calls Dispatcher dialog
  summary = "%d项呼叫；%d项已分配",
  staff = "%s - %s",
  watering = "浇水 @ %d，%d",
  repair = "修理 %s",
  close = "关闭",
}

tooltip.calls_dispatcher = {
  task = "任务列表 - 点击任务打开人员分配窗口，然后滚动到任务的位置",
  assigned = "这个框代表是否有人被分配给此任务。",
  close = "关闭签派窗口",
}

update_window = {
  caption = "可升级新版本！",
  new_version = "新版本：",
  current_version = "当前版本：",
  download = "打开下载页面",
  ignore = "回到主菜单"
}

tooltip.update_window = {
  download = "前往下载页面下载最新版 CorsixTH",
  ignore = "忽略这次更新。您将在下次启动 CorsixTH 时再次收到通知",
}

map_editor_window = {
  pages = {
    inside = "内部",
    outside = "外部",
    foliage = "灌木",
    hedgerow = "树篱",
    pond = "池塘",
    road = "道路",
    north_wall = "北墙",
    west_wall = "西墙",
    helipad = "停机坪",
    delete_wall = "删除墙壁",
    parcel_0 = "包 0",
    parcel_1 = "包 1",
    parcel_2 = "包 2",
    parcel_3 = "包 3",
    parcel_4 = "包 4",
    parcel_5 = "包 5",
    parcel_6 = "包 6",
    parcel_7 = "包 7",
    parcel_8 = "包 8",
    parcel_9 = "包 9",
    camera_1 = "相机 1",
    camera_2 = "相机 2",
    camera_3 = "相机 3",
    camera_4 = "相机 4",
    heliport_1 = "直升机场 1",
    heliport_2 = "直升机场 2",
    heliport_3 = "直升机场 3",
    heliport_4 = "直升机场 4",
    paste = "Paste area",
  }
}

hotkeys_file_err = {
  file_err_01 = "无法加载 hotkeys.txt 文件。请确保 CorsixTH " ..
        "具有读/写权限",
  file_err_02 = "，或使用 --hotkeys-file=filename 命令行选项指定一个可写文件。" ..
        "作为参考，加载快捷键文件的错误是：",
}

-- Override for level progress typo
level_progress.hospital_value_enough = "保持医院价值在%d以上，并解决好其他问题，就能完成任务了。"
level_progress.cured_enough_patients = "您已经治愈了足够多的病人，但是您只有达到更高的标准才能完成任务。"

-- Override for multiplayer typos
multiplayer.players_failed =  "以下玩家没有完成最终目标："
multiplayer.everyone_failed = "所有玩家都没有完成最终目标。因此每个人都要继续努力！"

--------------------------------  UNUSED  -----------------------------------
------------------- (kept for backwards compatibility) ----------------------

options_window.change_resolution = "更改分辨率"
tooltip.options_window.change_resolution = "更改窗口分辨率为左方的值"

--[[ Compatibility mapping for VIP result faxes in old saves (< 0.66). Using non-
standard string formatting here, which should not be repeated in normal
circumstances. This mapping will cause the legacy string to print in English but only
for the relevant fax. These should be deleted on 2024 release. ]]--
fax = {
  vip_visit_result = {
    ordered_remarks = {
      [1] = fax.vip_visit_result.remarks[1],
      [2] = fax.vip_visit_result.remarks[2],
      [3] = fax.vip_visit_result.remarks[3],
      [4] = fax.vip_visit_result.remarks[4],
      [5] = fax.vip_visit_result.remarks[5],
      [6] = fax.vip_visit_result.remarks[6],
      [7] = fax.vip_visit_result.remarks[7],
      [8] = fax.vip_visit_result.remarks[8],
      [9] = fax.vip_visit_result.remarks[9],
      [10] = fax.vip_visit_result.remarks[10],
      [11] = fax.vip_visit_result.remarks[11],
      [12] = fax.vip_visit_result.remarks[12],
      [13] = fax.vip_visit_result.remarks[13],
      [14] = fax.vip_visit_result.remarks[14],
      [15] = fax.vip_visit_result.remarks[15],
    },
    remarks = {
      super = {
        fax.vip_visit_result.remarks[1],
        fax.vip_visit_result.remarks[2],
        fax.vip_visit_result.remarks[3],
      },
      good = {
        fax.vip_visit_result.remarks[4],
        fax.vip_visit_result.remarks[5],
        fax.vip_visit_result.remarks[6],
      },
      mediocre = {
        fax.vip_visit_result.remarks[7],
        fax.vip_visit_result.remarks[8],
        fax.vip_visit_result.remarks[9],
      },
      bad = {
        fax.vip_visit_result.remarks[10],
        fax.vip_visit_result.remarks[11],
        fax.vip_visit_result.remarks[12],
      },
      very_bad = {
        fax.vip_visit_result.remarks[13],
        fax.vip_visit_result.remarks[14],
        fax.vip_visit_result.remarks[15],
      }
    }
  }
}
