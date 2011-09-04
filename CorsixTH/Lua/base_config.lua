--[[ Copyright (c) 2010 Edvin "Lego3" Linge

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

-- To keep in line with the original, tables start their indexing at 0. 
-- NOTE: This makes index iterations over tables omit the first element!
local configuration = {

  -----------------------------------------------------------
  --      New configuration values added in CorsixTH       --
  -----------------------------------------------------------
  town = {
    InterestRate = 0.01,
    StartCash = 40000,
  },
  
  -- New value, but should only be defined if starting staff is included.
  --start_staff = {
  --  {Doctor = 0, Shrink = 0, Skill = 0},
  --},
  
  -----------------------------------------------------------
  --           Original configuration values               --
  -----------------------------------------------------------
  staff = {
    [0] = {MinSalary = 60}, -- Nurse
    {MinSalary = 75}, -- Doctor
    {MinSalary = 25}, -- Handyman
    {MinSalary = 20}, -- Receptionist
  },
  gbv = {
    SalaryAdd = {
      {},
      {},
      -30, -- Junior
      30,  -- Doctor
      40,  -- Surgeon
      30,  -- Psychiatrist
      100, -- Consultant
      20,  -- Research
    },
    -- Divides ability to find an extra salary addition. must be > 0
    SalaryAbilityDivisor   = 10, 
    -- Divides research input to arrive at research points. must be > 0
    ResearchPointsDivisor  = 5, 
    -- When a drug is researched what rating does it have
    StartRating            = 100, 
    -- When a drug is researched how much does it cost
    StartCost              = 100, 
    -- Minimum Drug Cost
    MinDrugCost            = 50, 
    -- If contagious how much - rand up to this figure. higher = more contagious. must be > 0
    HowContagious          = 25, 
    -- 0-100 Higher equals more chance of spreading.
    ContagiousSpreadFactor = 25, 
    -- Reduce cont illnesses until X months have passed
    ReduceContMonths       = 14, 
    -- Reduce cont illnesses until X peep have arrived
    ReduceContPeepCount    = 20, 
    -- Rate to reduce cont illneses to - 0 means do not produce contagious illnesses at all
    ReduceContRate         = 0, 
    -- Hold all visual illnesses until x months. 0 never hold
    HoldVisualMonths       = 2, 
    -- Hold all visual illnesses until x peeps have arrived. 0 never hold
    HoldVisualPeepCount    = 6, 
    -- Maximum strength value an object can be improved to (by research)
    MaxObjectStrength      = 20, 
    -- Increase object strength by this amount when researching
    ResearchIncrement      = 2, 
    -- x Start Score for level = ceiling for normal score increases (2 dp)
    ScoreMaxInc            = 300, 
    -- Cost per vaccination
    VacCost                = 50, 
    -- If epidemic coverup fails - how much per person you are fined max 20000
    EpidemicFine           = 2000, 
    -- If an epidemic coverup succeeds how much compensation is received - lo value 
    EpidemicCompLo         = 1000, 
    -- If an epidemic coverup succeeds how much compensation is received - hi value max 20000
    EpidemicCompHi         = 15000, 
    -- % of research completed for an autopsy
    AutopsyRschPercent     = 33, 
    -- % rep hit for discovered autopsy
    AutopsyRepHitPercent   = 25, 
    -- Frequency of Mayor visits. Lower is more frequent.
    MayorLaunch            = 150, 
    -- Add to student doctor's ability when being taught MIN 1 MAX 255
    TrainingRate           = 40, 
    -- MIN 1 MAX 100 (Percentage)
    DrugImproveRate        = 5, 
    -- How many months until population allocation is done for real
    AllocDelay             = 3,

    AbilityThreshold = {
      [0] = {Value = 75}, -- SURGEON
      {Value = 60}, -- PSYCHIATRIST  
      {Value = 45}, -- RESEARCHER
    },
    TrainingValue = {
      [0] = {Value = 10}, -- Projector
      {Value = 15}, -- Skeleton
      {Value = 20}, -- Bookcase
    },
    -- >This value gives doctor
    DoctorThreshold = 250, 
    -- >This value gives consultant
    ConsultantThreshold = 750, 
    -- % of original rsch cost required to improve
    RschImproveCostPercent = 10, 
    -- %-point increase in improve cost per improvement
    RschImproveIncrementPercent = 10, 
  },
  
  towns = {
    {StartCash = 40000, InterestRate = 100}, -- Level 1
    {StartCash = 40000, InterestRate = 200}, --  Level 2
    {StartCash = 50000, InterestRate = 300}, --  Level 3
    {StartCash = 50000, InterestRate = 400}, --  Level 4
    {StartCash = 50000, InterestRate = 500}, --  Level 5
    {StartCash = 50000, InterestRate = 600}, --  Level 6
    {StartCash = 50000, InterestRate = 700}, --  Level 7
    {StartCash = 60000, InterestRate = 700}, --  Level 8
    {StartCash = 60000, InterestRate = 800}, --  Level 9
    {StartCash = 60000, InterestRate = 800}, --  Level 10
    {StartCash = 70000, InterestRate = 900}, --  Level 11
    {StartCash = 70000, InterestRate = 900}, --  Level 12
    {StartCash = 70000, InterestRate = 900}, --  Level 12
  },
  popn = {
    [0] = {Month = 0, Change = 4}, -- Standard: 4 patients the first month.
    [1] = {Month = 1, Change = 1}, -- Then increase by one per month.
  },
  expertise = {
    {StartPrice = 100, Known = 1, RschReqd = 0}, -- GENERAL_PRACTICE
    {StartPrice = 850, Known = 0, RschReqd = 40000, MaxDiagDiff = 700}, -- BLOATY_HEAD
    {StartPrice = 1150, Known = 0, RschReqd = 40000, MaxDiagDiff = 250}, --  HAIRYITUS
    {StartPrice = 1600, Known = 0, RschReqd = 60000, MaxDiagDiff = 250}, --  ELVIS
    {StartPrice = 1400, Known = 0, RschReqd = 60000, MaxDiagDiff = 250}, --  INVIS
    {StartPrice = 1800, Known = 0, RschReqd = 60000, MaxDiagDiff = 250}, --  RADIATION
    {StartPrice = 900, Known = 0, RschReqd = 40000, MaxDiagDiff = 250}, --  SLACK_TONGUE
    {StartPrice = 2000, Known = 0, RschReqd = 60000, MaxDiagDiff = 350}, --  ALIEN
    {StartPrice = 450, Known = 0, RschReqd = 20000, MaxDiagDiff = 250}, --  BROKEN_BONES
    {StartPrice = 950, Known = 0, RschReqd = 40000, MaxDiagDiff = 250}, --  BALDNESS
    {StartPrice = 700, Known = 0, RschReqd = 40000, MaxDiagDiff = 700}, --  DISCRETE_ITCHING
    {StartPrice = 1000, Known = 0, RschReqd = 40000, MaxDiagDiff = 1000}, --  JELLYITUS
    {StartPrice = 750, Known = 0, RschReqd = 40000, MaxDiagDiff = 700}, --  SLEEPING_ILLNESS
    {StartPrice = 0, Known = 0, RschReqd = 5000, MaxDiagDiff = 400}, --  PREGNANT
    {StartPrice = 800, Known = 0, RschReqd = 40000, MaxDiagDiff = 350}, --  TRANSPARENCY
    {StartPrice = 300, Known = 0, RschReqd = 20000, MaxDiagDiff = 350}, --  UNCOMMON_COLD
    {StartPrice = 1300, Known = 0, RschReqd = 60000, MaxDiagDiff = 1000}, --  BROKEN_WIND
    {StartPrice = 1100, Known = 0, RschReqd = 20000, MaxDiagDiff = 350}, --  SPARE_RIBS
    {StartPrice = 1050, Known = 0, RschReqd = 20000, MaxDiagDiff = 700}, --  KIDNEY_BEANS
    {StartPrice = 1900, Known = 0, RschReqd = 20000, MaxDiagDiff = 700}, --  BROKEN_HEART
    {StartPrice = 1600, Known = 0, RschReqd = 20000, MaxDiagDiff = 700}, --  RUPTURED_NODULES
    {StartPrice = 800, Known = 0, RschReqd = 40000, MaxDiagDiff = 350}, --  MULTIPLE_TV_PERSONALITIES
    {StartPrice = 1500, Known = 0, RschReqd = 60000, MaxDiagDiff = 350}, --  INFECTIOUS_LAUGHTER
    {StartPrice = 800, Known = 0, RschReqd = 40000, MaxDiagDiff = 700}, --  CORRUGATED_ANKLES
    {StartPrice = 800, Known = 0, RschReqd = 40000, MaxDiagDiff = 700}, --  CHRONIC_NOSEHAIR
    {StartPrice = 550, Known = 0, RschReqd = 40000, MaxDiagDiff = 700}, --  3RD_DEGREE_SIDEBURNS
    {StartPrice = 800, Known = 0, RschReqd = 40000, MaxDiagDiff = 350}, --  FAKE_BLOOD
    {StartPrice = 650, Known = 0, RschReqd = 40000, MaxDiagDiff = 700}, --  GASTRIC_EJECTIONS
    {StartPrice = 400, Known = 0, RschReqd = 20000, MaxDiagDiff = 1000}, --  THE_SQUITS
    {StartPrice = 1700, Known = 0, RschReqd = 20000, MaxDiagDiff = 700}, --  IRON_LUNGS
    {StartPrice = 600, Known = 0, RschReqd = 40000, MaxDiagDiff = 1000}, --  SWEATY_PALMS
    {StartPrice = 400, Known = 0, RschReqd = 20000, MaxDiagDiff = 700}, --  HEAPED_PILES
    {StartPrice = 350, Known = 0, RschReqd = 20000, MaxDiagDiff = 1000}, --  GUT_ROT
    {StartPrice = 1600, Known = 0, RschReqd = 20000, MaxDiagDiff = 700}, --  GOLF_STONES
    {StartPrice = 500, Known = 0, RschReqd = 20000, MaxDiagDiff = 700}, --  UNEXPECTED_SWELLING
    {StartPrice = 300, Known = 0, RschReqd = 40000}, --    I_D_SCANNER  
    {StartPrice = 250, Known = 0, RschReqd = 50000}, --    I_D_BLOOD_MACHINE       DIAGNOSIS
    {StartPrice = 150, Known = 0, RschReqd = 20000}, --    I_D_CARDIO              DIAGNOSIS
    {StartPrice = 200, Known = 0, RschReqd = 30000}, --    I_D_XRAY                DIAGNOSIS
    {StartPrice = 250, Known = 0, RschReqd = 60000}, --    I_D_ULTRASCAN           DIAGNOSIS
    {StartPrice = 150, Known = 0, RschReqd = 20000}, --    I_D_STANDARD            DIAGNOSIS
    {StartPrice = 100, Known = 0, RschReqd = 20000}, --    I_D_WARD                DIAGNOSIS
    {StartPrice = 200, Known = 0, RschReqd = 20000}, --    I_D_SHRINK              DIAGNOSIS
    {StartPrice = 500, Known = 0, RschReqd = 15000}, --    I_X_RESEARCH virtual treatment,auto autopsy
    {StartPrice = 500, Known = 0, RschReqd = 30000}, --    I_X_MIXER virtual treatment,atom analyser
    {StartPrice = 500, Known = 0, RschReqd = 30000}, --    I_X_COMPUTER virtual treatment,research computer
  },
  objects = {
    {StartCost = 100, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  1 Desk
    {StartCost = 100, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  2 Cabinet
    {StartCost = 0, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  3 Door
    {StartCost = 40, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  4 Bench
    {StartCost = 60, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  5 Table
    {StartCost = 20, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  6 Chair
    {StartCost = 500, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  7 Drinks
    {StartCost = 200, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  8 Bed
    {StartCost = 2500, StartAvail = 0, WhenAvail = 0, StartStrength = 8, AvailableForLevel = 0}, --  9 Inflator Machine
    {StartCost = 150, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  10 Snooker Table
    {StartCost = 150, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  11 New Receptionists Station
    {StartCost = 5, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  12 Build Room Tressle Table
    {StartCost = 1000, StartAvail = 0, WhenAvail = 0, StartStrength = 13, AvailableForLevel = 0}, --  13 Cardiogram
    {StartCost = 5000, StartAvail = 0, WhenAvail = 0, StartStrength = 12, AvailableForLevel = 0}, --  14 Scanner
    {StartCost = 3000, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  15 Scanner Console
    {StartCost = 30, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  16 Screen
    {StartCost = 5000, StartAvail = 0, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 0}, --  17 Jukebox
    {StartCost = 100, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  18 Couch
    {StartCost = 150, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  19 Sofa
    {StartCost = 250, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  20 Crash Trolley
    {StartCost = 50, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  21 TV set
    {StartCost = 6000, StartAvail = 0, WhenAvail = 0, StartStrength = 9, AvailableForLevel = 0}, --  22 Ultrascan
    {StartCost = 10000, StartAvail = 0, WhenAvail = 0, StartStrength = 7, AvailableForLevel = 0}, --  23 DNA Restorer
    {StartCost = 2000, StartAvail = 0, WhenAvail = 0, StartStrength = 11, AvailableForLevel = 0}, --  24 Cast Remover
    {StartCost = 1000, StartAvail = 0, WhenAvail = 0, StartStrength = 8, AvailableForLevel = 0}, --  25 Hair restorer
    {StartCost = 1500, StartAvail = 0, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 0}, --  26 Slicer for slack tongues
    {StartCost = 4000, StartAvail = 0, WhenAvail = 0, StartStrength = 12, AvailableForLevel = 0}, --  27 X-Ray
    {StartCost = 2000, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  28 Radiation Shield
    {StartCost = 500, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  29 X-Ray Viewer
    {StartCost = 5000, StartAvail = 0, WhenAvail = 0, StartStrength = 12, AvailableForLevel = 0}, --  30 Operating Table
    {StartCost = 2000, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  31 Lamp
    {StartCost = 30, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  32 Bathroom Sink
    {StartCost = 50, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  33 Op Sink 1
    {StartCost = 50, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  34 Op Sink 2
    {StartCost = 200, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  35 Surgeon Screen
    {StartCost = 50, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  36 Lecture Chair
    {StartCost = 100, StartAvail = 0, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 0}, --  37 Projector
    {StartCost = 200, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  38 Bed Screen Open
    {StartCost = 1000, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  39 Pharmacy Cabinet
    {StartCost = 5000, StartAvail = 0, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 0}, --  40 Research Computer
    {StartCost = 10000, StartAvail = 0, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 0}, --  41 Chemical Mixer 
    {StartCost = 3000, StartAvail = 0, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 0}, --  42 Blood Machine
    {StartCost = 25, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  43 Fire Extinguisher
    {StartCost = 20, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  44 Radiator
    {StartCost = 5, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  45 Plant1
    {StartCost = 3500, StartAvail = 0, WhenAvail = 0, StartStrength = 8, AvailableForLevel = 0}, --  46 Electrolysis Machine
    {StartCost = 6500, StartAvail = 0, WhenAvail = 0, StartStrength = 7, AvailableForLevel = 0}, --  47 Jellyitus Moulding Machine
    {StartCost = 0, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  48 Gates to Hell
    {StartCost = 200, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  49 Bed Screen Closed
    {StartCost = 5, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  50 Bin
    {StartCost = 300, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  51 Toilet
    {StartCost = 0, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  52 Double Door Part #1
    {StartCost = 0, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  53 Double Door Part #2
    {StartCost = 6500, StartAvail = 0, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 0}, --  54 Decontamination Shower
    {StartCost = 4000, StartAvail = 0, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 0}, --  55 Autopsy Research Machine
    {StartCost = 350, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  56 Bookcase
    {StartCost = 200, StartAvail = 0, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 0}, --  57 Video Game
    {StartCost = 0, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  58 Entrance Left Door
    {StartCost = 0, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  59 Entrance Right Door
    {StartCost = 450, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  60 Skeleton
    {StartCost = 100, StartAvail = 1, WhenAvail = 0, StartStrength = 10, AvailableForLevel = 1}, --  61 Comfy Chair
  },
  -- Cost for the room itself without any objects.
  -- For some reason it starts at 7, 
  -- but that must be retained in order to work with the original.
  rooms = {
    [7] = {Cost = 2280}, -- GP_OFFICE
    [8] = {Cost = 2270}, -- PSYCHO
    [9] = {Cost = 1700}, -- WARD
    [10] = {Cost = 2250}, -- OP_THEATRE
    [11] = {Cost = 500}, -- PHARMACY
    [12] = {Cost = 470}, -- CARDIO
    [13] = {Cost = 3970}, -- SCANNER
    [14] = {Cost = 2000}, -- ULTRASCAN
    [15] = {Cost = 3000}, -- BLOOD_MACHINE
    [16] = {Cost = 2000}, -- XRAY
    [17] = {Cost = 1500}, -- INFLATOR
    [18] = {Cost = 7000}, -- ALIEN
    [19] = {Cost = 500}, -- HAIR_RESTORER
    [20] = {Cost = 1500}, -- SLACK_TONGUE
    [21] = {Cost = 500}, -- FRACTURE
    [22] = {Cost = 1850}, -- TRAINING
    [23] = {Cost = 500}, -- ELECTRO
    [24] = {Cost = 4500}, -- JELLY_VAT
    [25] = {Cost = 1350}, -- STAFF ROOM
    [26] = {Cost = 5}, -- TV ??
    [27] = {Cost = 720}, -- GENERAL_DIAG
    [28] = {Cost = 800}, -- RESEARCH
    [29] = {Cost = 1170}, -- TOILETS
    [30] = {Cost = 5500}, -- DECON_SHOWER
  },
  visuals = {
    [0] = {Value = 0}, -- I_BLOATY_HEAD
    {Value = 0}, -- I_HAIRYITUS
    {Value = 0}, -- I_ELVIS
    {Value = 0}, -- I_INVIS
    {Value = 0}, -- I_RADIATION
    {Value = 0}, -- I_SLACK_TONGUE
    {Value = 0}, -- I_ALIEN
    {Value = 0}, -- I_BROKEN_BONES
    {Value = 0}, -- I_BALDNESS
    {Value = 0}, -- I_DISCRETE_ITCHING
    {Value = 0}, -- I_JELLYITUS
    {Value = 0}, -- I_SLEEPING_ILLNESS
    {Value = 0}, -- I_PREGNANT
    {Value = 0}, -- I_TRANSPARENCY
  },
  non_visuals = {
    [0] = {Value = 0}, -- I_UNCOMMON_COLD
    {Value = 0}, -- I_BROKEN_WIND
    {Value = 0}, -- I_SPARE_RIBS
    {Value = 0}, -- I_KIDNEY_BEANS
    {Value = 0}, -- I_BROKEN_HEART
    {Value = 0}, -- I_RUPTURED_NODULES
    {Value = 0}, -- I_MULTIPLE_TV_PERSONALITIES
    {Value = 0}, -- I_INFECTIOUS_LAUGHTER
    {Value = 0}, -- I_CORRUGATED_ANKLES
    {Value = 0}, -- I_CHRONIC_NOSEHAIR
    {Value = 0}, -- I_3RD_DEGREE_SIDEBURNS
    {Value = 0}, -- I_FAKE_BLOOD
    {Value = 0}, -- I_GASTRIC_EJECTIONS
    {Value = 0}, -- I_THE_SQUITS
    {Value = 0}, -- I_IRON_LUNGS
    {Value = 0}, -- I_SWEATY_PALMS
    {Value = 0}, -- I_HEAPED_PILES
    {Value = 0}, -- I_GUT_ROT
    {Value = 0}, -- I_GOLF_STONES
    {Value = 0}, -- I_UNEXPECTED_SWELLING
  },
  visuals_available = {
    [0] = {Value = 0}, -- I_BLOATY_HEAD
    {Value = 12}, -- I_HAIRYITUS
    {Value = 3}, -- I_ELVIS
    {Value = 12}, -- I_INVIS
    {Value = 18}, -- I_RADIATION
    {Value = 6}, -- I_SLACK_TONGUE
    {Value = 0}, -- I_ALIEN
    {Value = 6}, -- I_BROKEN_BONES
    {Value = 12}, -- I_BALDNESS
    {Value = 0}, -- I_DISCRETE_ITCHING
    {Value = 18}, -- I_JELLYITUS
    {Value = 0}, -- I_SLEEPING_ILLNESS
    {Value = 0}, -- I_PREGNANT
    {Value = 6}, -- I_TRANSPARENCY
  },

  win_criteria = {
    [0] = {Criteria = 0, MaxMin = 0, Value = 0, Group = 0, Bound = 0},
    {Criteria = 0, MaxMin = 0, Value = 0, Group = 0, Bound = 0},
    {Criteria = 0, MaxMin = 0, Value = 0, Group = 0, Bound = 0},
    {Criteria = 0, MaxMin = 0, Value = 0, Group = 0, Bound = 0},
    {Criteria = 0, MaxMin = 0, Value = 0, Group = 0, Bound = 0},
    {Criteria = 0, MaxMin = 0, Value = 0, Group = 0, Bound = 0},
  },
  lose_criteria = {
    [0] = {Criteria = 0, MaxMin = 0, Value = 0, Group = 0, Bound = 0},
    {Criteria = 0, MaxMin = 0, Value = 0, Group = 0, Bound = 0},
    {Criteria = 0, MaxMin = 0, Value = 0, Group = 0, Bound = 0},
    {Criteria = 0, MaxMin = 0, Value = 0, Group = 0, Bound = 0},
    {Criteria = 0, MaxMin = 0, Value = 0, Group = 0, Bound = 0},
    {Criteria = 0, MaxMin = 0, Value = 0, Group = 0, Bound = 0},
  },

  staff_levels = {
    [0] = {Month = 0, Nurses = 8, Doctors = 8, Handymen = 3, Receptionists = 2, 
           ShrkRate = 10, SurgRate = 10, RschRate = 10, ConsRate = 10, JrRate = 5},
  },
  
  emergency_control = {
    [0] = {StartMonth = 0, EndMonth = 0, Min = 0, Max = 0, Illness = 0, PercWin = 0, Bonus = 0},
  },
  computer = {
    [0] = {Playing = 0}, -- ORAC
    {Playing = 0}, -- COLOSSUS
    {Playing = 0}, -- HAL
    {Playing = 0}, -- MULTIVAC
    {Playing = 0}, -- HOLLY
    {Playing = 0}, -- DEEP THOUGHT
    {Playing = 0}, -- ZEN
    {Playing = 0}, -- SKYNET
    {Playing = 0}, -- MARVIN
    {Playing = 0}, -- CEREBRO
    {Playing = 0}, -- MOTHER
    {Playing = 0}, -- JAYNE
    {Playing = 0}, -- CORSIX
    {Playing = 0}, -- ROUJIN
    {Playing = 0}, -- EDVIN
  },
  awards_trophies = {
  
    -- Trophy win conditions
    
    -- Sell more than this number of cans to win the award MIN 0
    CansofCoke = 100, 
    -- If player's reputation is >x all through the year then win trophy MIN 0 MAX 1000
    Reputation = 400, 

    -- Trophy win bonuses
    
    -- Bonus - MIN 0 (MONEY BONUS)
    CansofCokeBonus = 1000,
    -- Bonus - MIN 0 (MONEY BONUS)
    TrophyReputationBonus = 2000,
    -- Bonus to money for NO DEATHS in the year (MONEY BONUS)
    TrophyDeathBonus = 10000,
  },
}

return configuration
