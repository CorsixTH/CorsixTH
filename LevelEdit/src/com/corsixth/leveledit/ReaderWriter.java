/*
Copyright (c) 2013 Koanxd aka Snowblind

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
 */

package com.corsixth.leveledit;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

/**
 * Reads .level and .SAM files and writes the currently opened data to .level
 * files.
 * 
 * @author Koanxd
 * 
 */
public class ReaderWriter {

    VarManipulator varManipulator = new VarManipulator();

    public void open(File file) {
        try {
            if (file != null) {

                BufferedReader read = new BufferedReader(new FileReader(file));

                String line;
                // keep reading, as long as current line is not null
                while ((line = read.readLine()) != null) {
                    if (line.startsWith("%Name"))
                        readFromFile(line, "name");
                    else if (line.startsWith("%LevelFile"))
                        readFromFile(line, "mapFile");
                    else if (line.startsWith("%LevelBriefing"))
                        readFromFile(line, "briefing");

                    else if (line.startsWith("#town")) {
                        readFromFile(line, "StartCash", "startCash");
                        readFromFile(line, "InterestRate", "interest");
                    } else if (line.startsWith("#gbv")) {
                        readTableFromFile(line, "SalaryAdd", "salaryAdd");
                        readFromFile(line, "StartRating", "drugStartRating");
                        readFromFile(line, "DrugImproveRate", "drugImproveRate");
                        readFromFile(line, "StartCost", "drugStartCost");
                        readFromFile(line, "MinDrugCost", "drugMinCost");
                        readFromFile(line, "LandCostPerTile", "landCostPerTile");
                        readFromFile(line, "RschImproveCostPercent",
                                "researchUpgradeCost");
                        readFromFile(line, "RschImproveIncrementPercent",
                                "researchUpgradeIncrementCost");
                        readFromFile(line, "MaxObjectStrength", "maxStrength");
                        readFromFile(line, "ResearchIncrement",
                                "strengthIncrement");
                        readFromFile(line, "AutopsyRschPercent",
                                "autopsyResearchPercent");
                        readFromFile(line, "AutopsyRepHitPercent",
                                "autopsyRepHitPercent");
                    } else if (line.startsWith("#visuals[")) {
                        readTableFromFile(line, null, "visuals");
                    } else if (line.startsWith("#non_visuals[")) {
                        readTableFromFile(line, null, "nonVisuals");
                    } else if (line.startsWith("#expertise[")) {
                        readTableFromFile(line, "Known", "known");
                        readTableFromFile(line, "RschReqd", "expertiseResearch");
                    } else if (line.startsWith("#visuals_available[")) {
                        readTableFromFile(line, null, "visualsAvailable");
                    } else if (line.startsWith("#objects[")) {
                        readTableFromFile(line, "StartAvail",
                                "objectsStartAvail");
                        readTableFromFile(line, "StartStrength",
                                "objectsStrength");
                        readTableFromFile(line, "AvailableForLevel",
                                "objectsAvail");
                        readTableFromFile(line, "RschReqd", "objectsResearch");
                    } else if (line.startsWith("#start_staff[")) {
                        readTableFromFile(line, "Doctor", "startStaff.doctor");
                        readTableFromFile(line, "Shrink", "startStaff.shrink");
                        readTableFromFile(line, "Surgeon", "startStaff.surgeon");
                        readTableFromFile(line, "Researcher",
                                "startStaff.researcher");
                        readTableFromFile(line, "Nurse", "startStaff.nurse");
                        readTableFromFile(line, "Handyman",
                                "startStaff.handyman");
                        readTableFromFile(line, "Receptionist",
                                "startStaff.receptionist");
                        readTableFromFile(line, "Skill", "startStaff.skill");
                    } else if (line.startsWith("#staff_levels[")) {
                        readTableFromFile(line, "Month", "staffLevels.month");
                        readTableFromFile(line, "Nurses", "staffLevels.nurses");
                        readTableFromFile(line, "Doctors",
                                "staffLevels.doctors");
                        readTableFromFile(line, "Handymen",
                                "staffLevels.handymen");
                        readTableFromFile(line, "Receptionists",
                                "staffLevels.receptionists");
                        readTableFromFile(line, "ShrkRate",
                                "staffLevels.shrinkRate");
                        readTableFromFile(line, "SurgRate",
                                "staffLevels.surgeonRate");
                        readTableFromFile(line, "RschRate",
                                "staffLevels.researcherRate");
                        readTableFromFile(line, "ConsRate",
                                "staffLevels.consultantRate");
                        readTableFromFile(line, "JrRate",
                                "staffLevels.juniorRate");
                    } else if (line.startsWith("#staff[")) {
                        readTableFromFile(line, "MinSalary", "staffSalary");
                    } else if (line.startsWith("#emergency_control[")) {
                        readTableFromFile(line, "Random", "emergency.Random");
                        readTableFromFile(line, "Mean", "emergencyInterval");
                        readTableFromFile(line, "Variance",
                                "emergencyIntervalVariance");
                        readTableFromFile(line, "StartMonth",
                                "emergency.startMonth");
                        readTableFromFile(line, "EndMonth",
                                "emergency.endMonth");
                        readTableFromFile(line, "Min", "emergency.minPatients");
                        readTableFromFile(line, "Max", "emergency.maxPatients");
                        readTableFromFile(line, "Illness", "emergency.illness");
                        readTableFromFile(line, "PercWin", "emergency.percWin");
                        readTableFromFile(line, "Bonus", "emergency.bonus");
                    } else if (line.startsWith("#quake_control[")) {
                        readTableFromFile(line, "StartMonth",
                                "quake.startMonth");
                        readTableFromFile(line, "EndMonth", "quake.endMonth");
                        readTableFromFile(line, "Severity", "quake.severity");
                    } else if (line.startsWith("#popn[")) {
                        readTableFromFile(line, "Month", "population.month");
                        readTableFromFile(line, "Change", "population.change");
                    } else if (line.startsWith("#awards_trophies")) {
                        readFromFile(line, "CansofCoke", "cansOfCoke");
                        readFromFile(line, "CansofCokeBonus", "cansOfCokeBonus");
                        readFromFile(line, "Reputation", "reputation");
                        readFromFile(line, "TrophyReputationBonus",
                                "reputationBonus");
                        readFromFile(line, "TrophyDeathBonus", "noDeathsBonus");
                    } else if (line.startsWith("#win_criteria[")) {
                        readFromFile(line, "Criteria", "Value",
                                "winCriteria.value");
                    } else if (line.startsWith("#lose_criteria[")) {
                        readFromFile(line, "Criteria", "Value",
                                "loseCriteria.value");
                        readFromFile(line, "Criteria", "Bound",
                                "loseCriteria.bound");
                    }

                }
                read.close();
                TabPopulation.calculateNumberOfPatients();
            }
        } catch (IOException e1) {
            // TODO Auto-generated catch block
            e1.printStackTrace();
        }
    }

    public void saveAs(File file) {

        try {
            if (file != null) {
                BufferedWriter write = new BufferedWriter(new FileWriter(file));

                write.write("Only lines beginning with % or # as explained below will "
                        + "be considered by the game. ");
                write.newLine();
                write.newLine();
                write.write("Each line beginning with a %-sign are directives to use when "
                        + "loading the game, such as what the level is called and where "
                        + "to find the map file. Available commands:");
                write.newLine();
                write.newLine();
                write.write("- Name: What the level should be called (within quotes)");
                write.newLine();
                write.newLine();
                write.write("- LevelFile: The name of the binary map file to load. ");
                write.write("First the Levels directory of the original game will be "
                        + "searched, and then the Levels directory of CorsixTH.");
                write.newLine();
                write.newLine();
                write.write("Lines that begin with # defines all parameters for the "
                        + "level. By default there are no diseases and only some "
                        + "basic rooms are available. Note that if a player is using "
                        + "the demo files on the contrary everything is available "
                        + "unless specified otherwise in the level file.");
                write.newLine();
                write.newLine();

                write.write("---------------------- General -------------------------");
                write.newLine();
                write.newLine();

                write.write("%Name = \"" + (TabGeneral.name) + "\"");
                write.newLine();

                write.write("%LevelFile = \"" + (TabGeneral.mapFile) + "\"");
                write.newLine();

                write.write("%LevelBriefing = \"" + (TabGeneral.briefing)
                        + "\"");
                write.newLine();

                write.write("#town.StartCash.InterestRate "
                        + (TabGeneral.startCash) + " "
                        + interestToInt(TabGeneral.interest));
                write.newLine();
                write.newLine();

                write.write("#gbv.StartRating " + (TabGeneral.drugStartRating));
                write.write(" When a drug is researched, what effectiveness does it have");
                write.newLine();

                write.write("#gbv.DrugImproveRate "
                        + (TabGeneral.drugImproveRate));
                write.newLine();

                write.write("#gbv.StartCost " + (TabGeneral.drugStartCost));
                write.newLine();

                write.write("#gbv.MinDrugCost " + (TabGeneral.drugMinCost));
                write.newLine();

                write.write("#gbv.LandCostPerTile "
                        + (TabGeneral.landCostPerTile));
                write.write(" Cost to buy a single map square");
                write.newLine();

                write.write("#gbv.RschImproveCostPercent "
                        + (TabGeneral.researchUpgradeCost));
                write.write(" How many percent of the original research points "
                        + "that are required to improve the machine.");
                write.newLine();

                write.write("#gbv.RschImproveIncrementPercent "
                        + (TabGeneral.researchUpgradeIncrementCost));
                write.write(" How many additional percentage points are added to "
                        + "the above value for each upgrade.");
                write.newLine();

                write.write("#gbv.MaxObjectStrength "
                        + (TabGeneral.maxStrength));
                write.write(" Maximum strength value an object can be improved to (by research)");
                write.newLine();

                write.write("#gbv.ResearchIncrement "
                        + (TabGeneral.strengthIncrement));
                write.write(" Increase object strength by this amount when researching");
                write.newLine();

                write.write("#gbv.AutopsyRschPercent "
                        + (TabGeneral.autopsyResearchPercent));
                write.write(" % of research completed for an autopsy");
                write.newLine();

                write.write("#gbv.AutopsyRepHitPercent "
                        + (TabGeneral.autopsyRepHitPercent));
                write.write(" % rep hit for discovered autopsy");
                write.newLine();
                write.newLine();
                write.newLine();

                write.write("---------------------- Diseases -------------------------");
                write.newLine();
                write.newLine();
                write.write("The following table contains all diagnoses "
                        + "and treatments that shows up in the drug casebook "
                        + "in the game. Known specifies whether it should "
                        + "show up from the beginning of the level and "
                        + "RschReqd how much research is required to discover "
                        + "the treatment room for the disease.");
                write.newLine();
                // start at index 1. 0 is never used by the game.
                for (int i = 1; i < TabDiseases.known.length; i++) {
                    write.write("#expertise[" + i + "].Known.RschReqd" + " "
                            + TabDiseases.known[i] + " "
                            + TabDiseases.expertiseResearch[i]);
                    write.newLine();
                }
                write.newLine();
                write.newLine();

                write.write("| Diseases available | Value property to be determined | Comment");
                write.newLine();
                for (int i = 0; i < TabDiseases.visuals.length; i++) {
                    write.write("#visuals[" + i + "] " + TabDiseases.visuals[i]);
                    write.newLine();
                }
                for (int i = 0; i < TabDiseases.nonVisuals.length; i++) {
                    write.write("#non_visuals[" + i + "] "
                            + TabDiseases.nonVisuals[i]);
                    write.newLine();
                }
                write.newLine();
                write.newLine();
                for (int i = 0; i < TabDiseases.visualsAvailable.length; i++) {
                    write.write("#visuals_available[" + i + "] "
                            + TabDiseases.visualsAvailable[i]);
                    write.newLine();
                }
                write.newLine();
                write.newLine();

                write.write("---------------------- Objects -------------------------");
                write.newLine();
                write.newLine();
                write.write("| Objects available | Available from the start | Strength | Available for this level | Comment");
                write.newLine();
                // start at index 1. 0 is never used by the game.
                for (int i = 1; i < TabObjects.objectsAvail.length; i++) {
                    write.write("#objects[" + i + "].StartAvail.StartStrength"
                            + ".AvailableForLevel.RschReqd" + " "
                            + TabObjects.objectsStartAvail[i] + " "
                            + TabObjects.objectsStrength[i] + " "
                            + TabObjects.objectsAvail[i] + " "
                            + TabObjects.objectsResearch[i]);
                    write.newLine();
                }
                write.newLine();
                write.newLine();

                write.write("---------------------- Staff Configuration -------------------------");
                write.newLine();
                write.newLine();
                // starts at index 1. 0 is never used by the game.
                for (int i = 0; i < TabStaff.startStaffList.size(); i++) {
                    write.write("#start_staff["
                            + (i + 1)
                            + "].Doctor.Shrink.Surgeon.Researcher.Nurse.Handyman.Receptionist.Skill "
                            + TabStaff.startStaffList.get(i).doctor + " "
                            + TabStaff.startStaffList.get(i).shrink + " "
                            + TabStaff.startStaffList.get(i).surgeon + " "
                            + TabStaff.startStaffList.get(i).researcher + " "
                            + TabStaff.startStaffList.get(i).nurse + " "
                            + TabStaff.startStaffList.get(i).handyman + " "
                            + TabStaff.startStaffList.get(i).receptionist + " "
                            + TabStaff.startStaffList.get(i).skill);
                    write.newLine();
                }
                write.newLine();
                write.newLine();

                write.write("The minimum salary for each staff type");
                write.newLine();
                for (int i = 0; i < TabStaff.staffSalary.length; i++) {
                    write.write("#staff[" + i + "].MinSalary "
                            + TabStaff.staffSalary[i]);
                    write.newLine();
                }
                write.newLine();
                write.newLine();

                write.write("Salary modifiers for different doctor attributes");
                write.newLine();
                // index 0,1,2 not used. start with 3.
                for (int i = 3; i < TabStaff.salaryAdd.length; i++) {
                    write.write("#gbv.SalaryAdd[" + i + "] "
                            + TabStaff.salaryAdd[i]);
                    write.newLine();
                }
                write.newLine();
                write.newLine();

                write.write("Each entry states how many staff members of each "
                        + "category are available a given month. The number of entries is not fixed.");
                write.newLine();
                write.write("| A list | Month it gets active (start at 0) | Each group |");
                write.newLine();
                for (int i = 0; i < TabStaff.staffLevelsList.size(); i++) {
                    write.write("#staff_levels[" + (i)
                            + "].Month.Nurses.Doctors.Handymen.Receptionists."
                            + "ShrkRate.SurgRate.RschRate.ConsRate.JrRate "
                            + TabStaff.staffLevelsList.get(i).month + " "
                            + TabStaff.staffLevelsList.get(i).nurses + " "
                            + TabStaff.staffLevelsList.get(i).doctors + " "
                            + TabStaff.staffLevelsList.get(i).handymen + " "
                            + TabStaff.staffLevelsList.get(i).receptionists
                            + " " + TabStaff.staffLevelsList.get(i).shrinkRate
                            + " " + TabStaff.staffLevelsList.get(i).surgeonRate
                            + " "
                            + TabStaff.staffLevelsList.get(i).researcherRate
                            + " "
                            + TabStaff.staffLevelsList.get(i).consultantRate
                            + " " + TabStaff.staffLevelsList.get(i).juniorRate);
                    write.newLine();
                }
                write.newLine();
                write.newLine();
                write.write("#gbv.TrainingRate	45");
                write.newLine();
                write.write("#gbv.AbilityThreshold[0]  75 Surgeon");
                write.newLine();
                write.write("#gbv.AbilityThreshold[1]  60 Psychiatrist");
                write.newLine();
                write.write("#gbv.AbilityThreshold[2]  45 Researcher");
                write.newLine();
                write.write("#gbv.TrainingValue[0]     10 Projector");
                write.newLine();
                write.write("#gbv.TrainingValue[1]     25 Skeleton");
                write.newLine();
                write.write("#gbv.TrainingValue[2]     30 Bookcase");
                write.newLine();
                write.newLine();

                write.write("----------------------- Emergency Control --------------------------");
                write.newLine();
                write.newLine();
                switch (Emergency.emergencyMode) {
                    case 0:
                        write.write("#emergency_control[0].Random 0");
                        write.newLine();
                        break;
                    case 1:
                        write.write("#emergency_control[0].Mean.Variance "
                                + TabEmergencies.emergencyInterval + " "
                                + TabEmergencies.emergencyIntervalVariance);
                        write.newLine();
                        break;
                    case 2:
                        for (int i = 0; i < TabEmergencies.emergencyList.size(); i++) {
                            write.write("#emergency_control["
                                    + i
                                    + "].StartMonth.EndMonth.Min.Max.Illness.PercWin.Bonus "
                                    + TabEmergencies.emergencyList.get(i).startMonth
                                    + " "
                                    + TabEmergencies.emergencyList.get(i).endMonth
                                    + " "
                                    + TabEmergencies.emergencyList.get(i).minPatients
                                    + " "
                                    + TabEmergencies.emergencyList.get(i).maxPatients
                                    + " "
                                    + TabEmergencies.emergencyList.get(i).illness
                                    + " "
                                    + TabEmergencies.emergencyList.get(i).percWin
                                    + " "
                                    + TabEmergencies.emergencyList.get(i).bonus);
                            write.newLine();
                        }   break;
                    default:
                        break;
                }
                write.newLine();
                write.newLine();

                write.write("----------------------- Quake Control --------------------------");
                write.newLine();
                write.newLine();
                for (int i = 0; i < TabEarthquakes.quakeList.size(); i++) {
                    write.write("#quake_control[" + i
                            + "].StartMonth.EndMonth.Severity "
                            + TabEarthquakes.quakeList.get(i).startMonth + " "
                            + TabEarthquakes.quakeList.get(i).endMonth + " "
                            + TabEarthquakes.quakeList.get(i).severity);
                    write.newLine();
                }
                write.newLine();
                write.newLine();

                write.write("----------------------- Population Growth ----------------------------");
                write.newLine();
                write.newLine();
                for (int i = 0; i < TabPopulation.populationList.size(); i++) {
                    write.write("#popn[" + i + "].Month.Change "
                            + TabPopulation.populationList.get(i).month + " "
                            + TabPopulation.populationList.get(i).change);
                    write.newLine();
                }
                write.newLine();
                write.newLine();

                write.write("---------------------- Awards and Trophies -------------------------");
                write.newLine();
                write.newLine();
                write.write("#awards_trophies.CansofCoke "
                        + TabAwards.cansOfCoke);
                write.newLine();

                write.write("#awards_trophies.CansofCokeBonus "
                        + TabAwards.cansOfCokeBonus);
                write.newLine();

                write.write("#awards_trophies.Reputation "
                        + TabAwards.reputation);
                write.newLine();

                write.write("#awards_trophies.TrophyReputationBonus "
                        + TabAwards.reputationBonus);
                write.newLine();

                write.write("#awards_trophies.TrophyDeathBonus "
                        + TabAwards.noDeathsBonus);
                write.newLine();
                write.newLine();
                write.newLine();

                write.write("------------------ Winning and Losing Conditions -------------------");
                write.newLine();
                write.newLine();
                write.write("1 Total reputation");
                write.newLine();
                write.write("2 Balance total");
                write.newLine();
                write.write("3 Percentage people your hospital has handled");
                write.newLine();
                write.write("4 Cure count");
                write.newLine();
                write.write("5 Percentage people have been killed");
                write.newLine();
                write.write("6 Hospital value");
                write.newLine();
                write.newLine();

                int numberOfCriteria = 0;
                if (TabGoals.winReputation) {
                    write.write("#win_criteria[" + numberOfCriteria
                            + "].Criteria.MaxMin.Value.Group.Bound ");
                    write.write(1 + " " + 1 + " " + TabGoals.minReputation
                            + " " + 1 + " " + 0);
                    numberOfCriteria++;
                    write.newLine();
                }

                if (TabGoals.winBalance) {
                    write.write("#win_criteria[" + numberOfCriteria
                            + "].Criteria.MaxMin.Value.Group.Bound ");
                    write.write(2 + " " + 1 + " " + TabGoals.minBalance + " "
                            + 1 + " " + 0);
                    numberOfCriteria++;
                    write.newLine();
                }

                if (TabGoals.winPercentage) {
                    write.write("#win_criteria[" + numberOfCriteria
                            + "].Criteria.MaxMin.Value.Group.Bound ");
                    write.write(3 + " " + 1 + " " + TabGoals.minPercentage
                            + " " + 1 + " " + 0);
                    numberOfCriteria++;
                    write.newLine();
                }

                if (TabGoals.winCureCount) {
                    write.write("#win_criteria[" + numberOfCriteria
                            + "].Criteria.MaxMin.Value.Group.Bound ");
                    write.write(4 + " " + 1 + " " + TabGoals.minCureCount + " "
                            + 1 + " " + 0);
                    numberOfCriteria++;
                    write.newLine();
                }

                if (TabGoals.winValue) {
                    write.write("#win_criteria[" + numberOfCriteria
                            + "].Criteria.MaxMin.Value.Group.Bound ");
                    write.write(6 + " " + 1 + " " + TabGoals.minValue + " " + 1
                            + " " + 0);
                    write.newLine();
                }
                write.newLine();

                numberOfCriteria = 0;
                if (TabGoals.loseReputation) {
                    write.write("#lose_criteria[" + numberOfCriteria
                            + "].Criteria.MaxMin.Value.Group.Bound ");
                    write.write(1 + " " + 0 + " " + TabGoals.maxReputation
                            + " " + 1 + " " + TabGoals.warnReputation);
                    numberOfCriteria++;
                    write.newLine();
                }

                if (TabGoals.loseBalance) {
                    write.write("#lose_criteria[" + numberOfCriteria
                            + "].Criteria.MaxMin.Value.Group.Bound ");
                    write.write(2 + " " + 0 + " " + TabGoals.maxBalance + " "
                            + 2 + " " + TabGoals.warnBalance);
                    numberOfCriteria++;
                    write.newLine();
                }

                if (TabGoals.losePercentageKilled) {
                    write.write("#lose_criteria[" + numberOfCriteria
                            + "].Criteria.MaxMin.Value.Group.Bound ");
                    write.write(5 + " " + 1 + " "
                            + TabGoals.minPercentageKilled + " " + 3 + " "
                            + TabGoals.warnPercentageKilled);
                    write.newLine();
                }

                write.close();

            }
        } catch (IOException e1) {
            // TODO Auto-generated catch block
            e1.printStackTrace();
        }
    }

    // read a variable from the file.
    public void readFromFile(String line, String parameter, String variable) {

        // consider the line "#town.StartCash.InterestRate 100000 300"
        // to get the number of parameters, split the line along "\\." dots
        // result: "#town", "StartCash", "InterestRate 100000 300"
        // start from i = 1, so the first part "#town" is ignored. we have 2
        // parameters.
        int parameterCount = line.split("[\\.]").length;
        for (int i = 1; i < (parameterCount); i++) {
            // we want to check only the actual content of the parameters,
            // so the line must be split up along "\\." dots and "\\s+"
            // whitespaces
            // result: "#town", "StartCash", "InterestRate", "100000", "300"
            // we check the position of each parameter, so we know which value
            // belongs to which parameter.
            if ((line.split("[\\.\\s+]")[i]).matches(parameter))
                if (!"interest".equals(variable)) {

                    // to get only the actual value, split along "\\s+"
                    // whitespaces.
                    // result: "#town.Start.Cash.InterestRate", "100000", "300"
                    // again, the first part is ignored because we started
                    // counting at i = 1, not 0.
                    // now all values are in the same position as their
                    // corresponding parameter.
                    varManipulator.setValue(variable, line.split("\\s+")[i]);
                }

                else {
                    // interest in the level file is an integer, like 300 = 3%.
                    // convert the value to double and divide by 100.
                    double interest2 = (Double
                            .parseDouble(line.split("\\s+")[i])) / 100;
                    // convert back to string so it fits the arguments of
                    // setVariable
                    varManipulator.setValue(variable,
                            Double.toString(interest2));
                }
        }
    }

    // this method exists for %Level parameters because they are only a single
    // variable inside quotes
    public void readFromFile(String line, String variable) {
        varManipulator.setValue(variable, (line.split("\"")[1]));

    }

    // this method exists for win/lose criteria.
    public void readFromFile(String line, String parameter, String parameter2,
            String variable) {

        int parameterCount = line.split("[\\.]").length;
        for (int i = 1; i < (parameterCount); i++) {
            if ((line.split("[\\.\\s+]")[i]).matches(parameter)) {
                for (int ii = 1; ii < (parameterCount); ii++) {
                    if ((line.split("[\\.\\s+]")[ii]).matches(parameter2)) {
                        varManipulator.setCriteria(variable, true,
                                (Integer.parseInt(line.split("\\s+")[i])),
                                (Integer.parseInt(line.split("\\s+")[ii])));
                    }
                }
            }
        }
    }

    // this method exists for tables like #expertise[]
    public void readTableFromFile(String line, String parameter, String variable) {
        if (parameter != null) {
            int parameterCount = line.split("[\\.]").length;
            for (int i = 1; i < (parameterCount); i++) {
                // gbv.SalaryAdd[] has its parameter (SalaryAdd) before the
                // brackets
                if ("SalaryAdd".equals(parameter)) {
                    if ((line.split("[\\.\\s+]")[i]).matches(parameter
                            + "\\[\\d\\]")) {
                        // split the line to get the value inside [ ] (the
                        // index).
                        // then split by "\\s+" whitespaces to get the value
                        varManipulator.setValueForTable(variable,
                                (Integer.parseInt(line.split("[\\[\\]]")[1])),
                                (Integer.parseInt(line.split("\\s+")[i])));
                    }
                } else {
                    if ((line.split("[\\.\\s+]")[i]).matches(parameter)) {
                        // split the line to get the value inside [ ] (the
                        // index).
                        // then split by "\\s+" whitespaces to get the value
                        varManipulator.setValueForTable(variable,
                                (Integer.parseInt(line.split("[\\[\\]]")[1])),
                                (Integer.parseInt(line.split("\\s+")[i])));
                    }
                }
            }
        } else // if a parameter null is given, then there is only one variable
               // like #visuals[]
        {
            varManipulator.setValueForTable(variable,
                    (Integer.parseInt(line.split("[\\[\\]]")[1])),
                    (Integer.parseInt(line.split("\\s+")[1])));
        }

    }

    public void saveLastFilePath(String filepath) {
        File file = new File("lastFilePath.txt");
        try {
            BufferedWriter write = new BufferedWriter(new FileWriter(file));
            write.write(filepath);
            write.close();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

    }

    public File getLastFilePath() {
        File returnFile = null;
        try {
            if (new File("lastFilePath.txt").exists()) {
                BufferedReader read = new BufferedReader(new FileReader(
                        "lastFilePath.txt"));
                returnFile = new File(read.readLine());
                read.close();
            }
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return returnFile;
    }

    // convert interest to an int value up to 2 decimals precision.
    public int interestToInt(double interest2) {
        Double fInterest = interest2;
        fInterest = fInterest * 100;
        Integer iInterest = fInterest.intValue();
        return iInterest;

    }

    // because the briefing in the level file does not allow newlines:
    // replace newlines with an appropriate amount of spaces,
    // to create a newline effect in the game.
    // public String briefingToSingleLine()
    // {
    // //split the input briefing along newlines, creating a new string for each
    // line.
    // String[] briefingLines = TabGeneral.briefing.split("\n");
    // String returnBriefing = "";
    // int spacesRequired = 0;
    // for (int i=0; i<briefingLines.length; i++)
    // {
    // //make every line 50 characters long by filling in spaces.
    // if (briefingLines[i].length()%50 != 0)
    // {
    // int lineCharactersCount = 0;
    // String[] lineWords = briefingLines[i].split(" ");
    // for (int ii=0; ii<lineWords.length; ii++)
    // {
    // if (lineCharactersCount + lineWords[ii].length() > 50)
    // {
    // StringBuffer spaces = new StringBuffer();
    // spacesRequired = 50 - lineCharactersCount;
    // for (int iii=0; iii<spacesRequired; iii++)
    // {
    // spaces.append(" ");
    // }
    // returnBriefing += spaces.toString() + lineWords[ii] + " ";
    // lineCharactersCount = lineWords[ii].length()+1;
    // System.out.println(returnBriefing);
    // }
    // else
    // {
    // returnBriefing += lineWords[ii] + " ";
    // lineCharactersCount += lineWords[ii].length()+1;
    // System.out.println(returnBriefing);
    // }
    // }
    // StringBuffer spaces = new StringBuffer();
    // spacesRequired = 50 - (briefingLines[i].length()%50);
    // for (int iii=0; iii<spacesRequired; iii++)
    // {
    // spaces.append(" ");
    // }
    // returnBriefing += spaces.toString();
    // System.out.println(returnBriefing);
    // }
    // if (briefingLines[i].length() == 0)
    // {
    // StringBuffer spaces = new StringBuffer();
    // spacesRequired = 50;
    // for (int iii=0; iii<spacesRequired; iii++)
    // {
    // spaces.append(" ");
    // }
    // returnBriefing += spaces.toString();
    // System.out.println(returnBriefing);
    // }
    // // if (briefingLines[i].length() == 0 || briefingLines[i].length()%50 !=
    // 0)
    // // {
    // // int spacesRequired = 50 - (briefingLines[i].length()%50);
    // // StringBuffer spaces = new StringBuffer();
    // // for (int ii=0; ii<spacesRequired; ii++)
    // // {
    // // spaces.append(" ");
    // // }
    // // //don't put spaces if it's the last line.
    // // if (i == briefingLines.length-1)
    // // {
    // // returnBriefing += briefingLines[i];
    // // System.out.println(briefingLines[i]);
    // //
    // // }
    // // else
    // // {
    // // returnBriefing += briefingLines[i] + spaces.toString();
    // // System.out.println(briefingLines[i] + " + " + spacesRequired +
    // " spaces");
    // //
    // // }
    // //
    // // }
    // }
    // return returnBriefing;
    // }

}
