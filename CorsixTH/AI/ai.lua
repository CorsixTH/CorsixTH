function getRoomCost(pRoomID)
    -- check if passed values are valid
        -- get room cost from pRoomID
        -- return room cost
    -- return "Error getRoomCost() not vaild"
end

function getRoomAvailability(pRoomID)
    -- check if passed values are valid
        -- Check if the current room is unlocked in order to be built
            -- return true
    -- return "Error getRoomAvailability() not vaild"
end

--Builds a new room
function buildRoom(pRoomID, pLength, pWidth, pRoomLocation, pDoorLoc, pWindowArray, pItemArray, pItemLocationArray, pItemRotationArray)
    -- check if passed values are valid
    -- check if the ai has enough money
        -- Set room Length (pLength) and Width (pWidth)
            -- check if room size is valid
                -- Set room location from pRoomLocation
                    -- check if room location is valid
                        -- Set door location from pDoorLoc
                            -- check if room door location is valid
                                -- Set window locations from pWindowArray
                                    -- check if window location is valid
                                        -- Buy items for room from pItemArray
                                            -- check if the ai has enough money
                                                -- check if item is valid 
                                                    -- Set item positions from pItemLocationArray
                                                        --check if item location is valid
    -- if build is successful create the room and return the pRoomID else return "error" as room is invalid  
end
-- local result = buildRoom(pRoomID, 5,4,location, slot1,windowArray,itemArray,itemLocationArray)

function deleteRoom(pRoomID)
    -- check if passed values are valid
        -- check if pRoomID is a owned room
            -- edit room wait for room to be empty
                -- delete room
                    -- return "Room pRoomID is deleted"
    -- return "deleteRoom() error"
end

function getRoomQue(pRoomID)
    -- check if passed values are valid
        -- get room queue size
            -- return room queue size
    -- return "getRoomQue() error"
end

function setRoomQue(pRoomID)
    -- check if passed values are valid
        -- set room queue size
            -- return true
    -- return "setRoomQue() error"
end

function getRoomCurrentQue(pRoomID)
    -- check if passed values are valid
        -- get current number of Patients in queue 
            -- return current room queue size
    -- return "getRoomCurrentQue() error" 
end

function getRoomQuePatients(pRoomID)
    -- check if passed values are valid
        -- return array of patient in queue 
    -- return "getRoomQuePatients() error" 
end

function setRoomQuePatients(pRoomID, pPatientArray)
    -- check if passed values are valid
        -- Set the patient queue from a array
            --return true
    -- return "setRoomQuePatients() error" 
end

function addItemToRoom(pRoomID, pAddItem, pItemLocaiton, pItemRotation)
    -- check if passed values are valid
        -- check if pRoomID is owned
            -- check if the ai has enough money 
                --add item to room, save room and return true
    -- return "addItemToRoom() error" 
end

function addCorridorItem(pItemID, pPosition)
    -- check if passed values are valid
        -- check if player has enough money
            -- place item 
                -- return true
    -- return "addCorridorItem() error" 
end

function getBuildTimeActive()
    -- get build Time Status return true or false
end

function endBuildTimer()
    -- check if getBuildTimeActive is true 
        -- if true start build return true
    -- return false
end

--Bank manager
function getHospitalValue()
    -- get the current hospital value
        -- return hospital value
end

function getBalance()
    -- get the current balance
        -- return current balance
end

function getCurrentLoan()
    -- get the current loan
        -- return current loan
end

function getInterestPayment()
    -- get the current interest payment
        -- return interest payment
end

function getReputation()
    -- get the current Reputation value
        -- return Reputation
end

function getDate()
    -- get the current date
        -- return date
end

function getHireAvailableDoctors()
    --in a loop return the current doctors id's
    --Doctor object
        -- id
        -- name
        -- seniority
        -- ablity
        -- qualifications
        -- Salary
        -- Store all doctor object in an array
    -- return array of objects
end

function getHireAvailableNurses()
    --in a loop return the current Nurses id
    --Nurse object
        -- id
        -- name
        -- ablity
        -- Salary
        --Store all nurses object in an array
    -- return array of objects
end

function getHireAvailableHandymen()
    --in a loop return the current Handymen id
    --Handymen object
        -- id
        -- name
        -- ablity
        -- Salary
        --Store all Handymen object in an array
    -- return array of objects
end

function getHireAvailableReceptionists()
    --in a loop return the current Receptionists id
    --Receptionists object
        -- id
        -- name
        -- ablity
        -- Salary
        --Store all Receptionists object in an array
    -- return array of objects
end

function hireStaff(pStaffID, pLocation)
    -- check if passed values are valid
        -- check if pStaffID matches available staff  
            -- check if the ai has enough money
                -- check if location is valid
                    -- hire staff member and place them
                        --reurn true
    -- return "hireStaff() error" 
end

--Staff management
function getAllStaffType(pStaffType)
    -- check if passed values are valid
        -- return array of all owned staff of passed type
    -- return "getAllStaffType() error" 
end

function getStaff(pStaffID, pValue)
    -- check if passed values are valid
        --create new object to store staff info
            -- id
            -- name
            -- detail
            -- Salary
            -- Morale
            -- Tiredness
            -- Skill
            -- seniority
            -- ablity
            -- qualifications
            -- return staff object
    -- return "getStaff() error" 
end

function getStaffBonusCost(pStaffID)
    -- check if passed values are valid
        -- return bonus cost
    -- return "getStaffBonusCost() error" 
end

function payStaffBonus(pStaffID)
    -- check if passed values are valid
        -- check if the ai has enough money
            -- pay bonus
                -- return true
    -- return "payStaffBonus() error" 
end

function getStaffPay(pStaffID)
    -- check if passed values are valid
        -- return staff pay
    -- return "getStaffPay() error" 
end

function raiseStaffPay(pStaffID)
    -- check if passed values are valid
        -- check if the ai has enough money
            -- raise staff pay
                --return true
    -- return "raiseStaffPay() error" 
end

function sackStaff(pStaffID)
    -- check if passed values are valid
        -- sack staff member
            --return true
    -- return "sackStaff() error" 
end

--Townmap
function getPlots()
    -- get array of plots that the ai can buy
        --return array
end

function buyPlot(pPlotID)
    -- check if passed values are valid
        -- Check if the ai has enough money
            -- buy Plot
                -- return true
    -- return "buyPlot() error" 
end

function getHeatValue()
    --return heat value
end

function getHeatCost()
    --return heat cost
end

function setHeatValue(pValue)
    -- check if passed values are valid
        -- set heat value
            --return true
    -- return "setHeatValue() error" 
end

function getTotalPeople()
    -- return total people
end

function getTotalPlants()
    -- return total plants
end

function getTotalFire()
    -- return total fire extinguishers 
end

function getTotalObjects()
    -- return total objects
end

function getTotalRadiators()
    -- return total Radiators
end

--Drug casebook
function getTreatments()
    -- return an array of the current list of Treatments unlocked
end

function getTreatmentReputation(pTreatmentID)
    -- check if passed values are valid
        -- return the treatment Reputation
    -- return "getTreatmentReputation() error"
end

function getTreatmentCharge(pTreatmentID)
    -- check if passed values are valid
        -- return the charge for the Treatment
    -- return "getTreatmentCharge() error"
end

function setTreatmentCharge(pTreatmentID,pValue)
    -- check if passed values are valid
        -- set TreatmentCharge
            -- return true
    -- return "setTreatmentCharge() error"
end

function getTreatmentMoneyEarned(pTreatmentID)
    -- check if passed values are valid
        -- return money earned
    -- return "getTreatmentMoneyEarned() error"
end

function getTreatmentRecoveries(pTreatmentID)
    -- check if passed values are valid
        -- return Treatment Recoveries
    -- return "getTreatmentRecoveries() error"
end

function getTreatmentFatalities(pTreatmentID)
    -- check if passed values are valid
        -- return Treatment Fatalities
    -- return "getTreatmentFatalities() error"
end

function getTreatmentTurnedAway(pTreatmentID)
    -- check if passed values are valid
        -- return Treatment TurnedAway
    -- return "getTreatmentTurnedAway() error"
end

function getTreatmentCureStatus(pTreatmentID)
    -- check if passed values are valid
        -- return Cures
    -- return "getTreatmentCureStatus() error"
end

function getTreatmentEffectiveness(pTreatmentID)
    -- check if passed values are valid
        -- return Treatment Effectiveness
    -- return "getTreatmentEffectiveness() error"
end

function getTreatmentHandle(pTreatmentID)
    -- check if passed values are valid
        -- return Treatmen tHandle
    -- return "getTreatmentHandle() error"
end

function getTreatmentRequirement(pTreatmentID)
    -- check if passed values are valid
        -- return Treatment Requirement
    -- return "getTreatmentRequirement() error"
end

function setResearchFocus(pTreatmentID)
    -- check if passed values are valid
        -- set focus 
            -- return true
    -- return "setResearchFocus() error"
end

function getResearchFocus()
    -- return Treatment Focus
end

--Reearch
function getResearchValue(pResearchType)
    -- check if passed values are valid
        -- return research type value
    -- return "getResearchValue() error"
end

function setResearchValue(pResearchType)
    -- check if passed values are valid
        -- check if total % is not over 100 
            -- return true
    -- return "setResearchValue() error"
end

function getResearchAllocaiton()
    -- return the number of allocaiton used for research
end

--stats
function getHappiness()
    -- return happiness level
end

function getThirst()
    -- return thirst level
end

function getWarmth()
    -- return warmth level
end

function getBalanceGoal()
    -- return balance goal
end

function getTreatedGoal()
    -- return treated goal
end

function getCureGoal()
    -- return cure goal
end

function getWorthGoal()
    -- return worth goal
end

--charts
function getChartMoneyIn()
    -- return money in
end

function ggetChartMoneyOut()
    -- return money out
end

function getChartWages()
    -- return total wages
end

function getChartBalance()
    -- return balance
end

function getChartVisitors()
    -- return total visitors
end

function getChartCures()
    -- return cures
end

function getChartDeaths()
    -- return deaths
end

-- Hospital Policy
function getProcedure(pValue)
    -- check if passed values are valid
        -- return either the send hone or cure value
    -- return "getProcedure() error"
end

function setProcedure(pSendHome,pCure)
    -- check if passed values are valid
        --Check if pSendHome is < pCure and pCure <= 100 and pSendHome >= 0
            --return true
    -- return "setProcedure() error"
end

function getTermination()
    -- return termination value
end

function setTermination(pValue)
    -- check if passed values are valid
        --check if pValue is >= 100 and <= 200
            --return true
    -- return "setTermination() error"
end

function getRest()
    -- return rest value
end

function setRest(pValue)
    -- check if passed values are valid
        -- check if value is >= 0 and <= 100
            -- return true
    -- return "setRest() error"
end

function getLeaveRoom()
    -- return leave room value
end

function setLeaveRoom(pValue)
    -- check if passed values are valid
        -- set leave room value
            -- return true
    -- return "setLeaveRoom() error"
end

function getStaffPayRise()
    -- return array of staff objects that need a pay rise
end

function getEpidemicStaus()
    -- return true or false on epidemic status
end

function getAllUnvaccinatedPatients()
    -- return array of Patients objects that need Vaccination during an Epidemic
end

function setVaccination(pPatientID)
    -- check if passed values are valid
        -- Vaccinate patient
            -- return true
    -- return "setVaccination() error"
end

function getPatientVaccination(pPatientID)
    -- check if passed values are valid
        -- get patient Vaccinate status
            -- return true
    -- return "getPatientVaccination() error"
end

function getVIPrequest()
    -- check to see if there is a VIP request return true or false
end

function setVIP(pValue)
    -- check if passed values are valid
        --accept or deny
            --return true
    -- return "setVIP() error"
end

function getPatientMessage()
    -- return an array of objects of Patient Messages
end

function sendPatientToCure(pPatientID)
    -- check if passed values are valid
        -- send patient to cure
            --return true 
    -- return "sendPatientToCure() error"
end

function sendPatientHome(pPatientID)
    -- check if passed values are valid
        -- send patient home
            --return true 
    -- return "sendPatientHome() error"
end

function sendPatientToResearch(pPatientID)
    -- check if passed values are valid
        -- send patient to Research
            --return true 
    -- return "sendPatientToResearch() error"
end
--sabotage
--function setLitterBomb(pValue)
 --   return value
--end
