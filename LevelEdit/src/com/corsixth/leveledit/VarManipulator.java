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

import javax.swing.JCheckBox;
import javax.swing.JTextField;

public class VarManipulator {

    // TODO: the arguments are weird. they should probably refer to an actual
    // variable,
    // instead of using a string which can cause errors.
    public void setValue(String variable, String value) {
        if ("name".equals(variable)) {
            TabGeneral.name = value;
            TabGeneral.nameTF.setText(value);
        }

        else if ("mapFile".equals(variable)) {
            TabGeneral.mapFile = value;
            TabGeneral.mapFileTF.setText(value);
        }

        else if ("briefing".equals(variable)) {
            TabGeneral.briefing = value;
            TabGeneral.briefingTA.setText(value);
        }

        else if ("startCash".equals(variable)) {
            TabGeneral.startCash = Integer.parseInt(value);
            TabGeneral.startCashTF.setText(value);
        }

        else if ("interest".equals(variable)) {
            TabGeneral.interest = Double.parseDouble(value);
            TabGeneral.interestTF.setText(value);
        }

        else if ("drugStartRating".equals(variable)) {
            TabGeneral.drugStartRating = Integer.parseInt(value);
            TabGeneral.drugStartRatingTF.setText(value);
        } else if ("drugImproveRate".equals(variable)) {
            TabGeneral.drugImproveRate = Integer.parseInt(value);
            TabGeneral.drugImproveRateTF.setText(value);
        }

        else if ("drugStartCost".equals(variable)) {
            TabGeneral.drugStartCost = Integer.parseInt(value);
            TabGeneral.drugStartCostTF.setText(value);
        }

        else if ("drugMinCost".equals(variable)) {
            TabGeneral.drugMinCost = Integer.parseInt(value);
            TabGeneral.drugMinCostTF.setText(value);
        }

        else if ("landCostPerTile".equals(variable)) {
            TabGeneral.landCostPerTile = Integer.parseInt(value);
            TabGeneral.landCostPerTileTF.setText(value);
        }

        else if ("autopsyResearchPercent".equals(variable)) {
            TabGeneral.autopsyResearchPercent = Integer.parseInt(value);
            TabGeneral.autopsyResearchPercentTF.setText(value);
        }

        else if ("autopsyRepHitPercent".equals(variable)) {
            TabGeneral.autopsyRepHitPercent = Integer.parseInt(value);
            TabGeneral.autopsyRepHitPercentTF.setText(value);
        }

        else if ("researchUpgradeCost".equals(variable)) {
            TabGeneral.researchUpgradeCost = Integer.parseInt(value);
            TabGeneral.researchUpgradeCostTF.setText(value);
        }

        else if ("researchUpgradeIncrementCost".equals(variable)) {
            TabGeneral.researchUpgradeIncrementCost = Integer.parseInt(value);
            TabGeneral.researchUpgradeIncrementCostTF.setText(value);
        }

        else if ("strengthIncrement".equals(variable)) {
            TabGeneral.strengthIncrement = Integer.parseInt(value);
            TabGeneral.strengthIncrementTF.setText(value);
        }

        else if ("maxStrength".equals(variable)) {
            TabGeneral.maxStrength = Integer.parseInt(value);
            TabGeneral.maxStrengthTF.setText(value);
        } else if ("cansOfCoke".equals(variable)) {
            TabAwards.cansOfCoke = Integer.parseInt(value);
            TabAwards.cansOfCokeTF.setText(value);
        } else if ("cansOfCokeBonus".equals(variable)) {
            TabAwards.cansOfCokeBonus = Integer.parseInt(value);
            TabAwards.cansOfCokeBonusTF.setText(value);
        } else if ("reputation".equals(variable)) {
            TabAwards.reputation = Integer.parseInt(value);
            TabAwards.reputationTF.setText(value);
        } else if ("reputationBonus".equals(variable)) {
            TabAwards.reputationBonus = Integer.parseInt(value);
            TabAwards.reputationBonusTF.setText(value);
        } else if ("noDeathsBonus".equals(variable)) {
            TabAwards.noDeathsBonus = Integer.parseInt(value);
            TabAwards.noDeathsBonusTF.setText(value);
        }
    }

    // set value on a certain index of an array
    // same as above with the string arguments.
    public void setValueForTable(String variable, int index, int value) {
        if ("visuals".equals(variable)) {
            TabDiseases.visuals[index] = value;
            if (value == 0) {
                TabDiseases.visualsCB[index].setSelected(false);
                TabDiseases.visuals[index] = 0;
            } else {
                TabDiseases.visualsCB[index].setSelected(true);
                TabDiseases.visuals[index] = 1;
            }
        } else if ("nonVisuals".equals(variable)) {
            if (value == 0) {
                TabDiseases.nonVisualsCB[index].setSelected(false);
                TabDiseases.nonVisuals[index] = 0;
            } else {
                TabDiseases.nonVisualsCB[index].setSelected(true);
                TabDiseases.nonVisuals[index] = 1;
            }
        } else if ("known".equals(variable)) {
            if (value == 1) {
                TabDiseases.knownCB[index].setSelected(true);
                TabDiseases.known[index] = 1;
            } else {
                TabDiseases.knownCB[index].setSelected(false);
                TabDiseases.known[index] = 0;
            }
        } else if ("visualsAvailable".equals(variable)) {
            TabDiseases.visualsAvailableTF[index].setText(Integer
                    .toString(value));
            TabDiseases.visualsAvailable[index] = value;
        } else if ("expertiseResearch".equals(variable)) {
            TabDiseases.expertiseResearchTF[index].setText(Integer
                    .toString(value));
            TabDiseases.expertiseResearch[index] = value;
        } else if ("objectsStrength".equals(variable)) {
            TabObjects.objectsStrengthTF[index]
                    .setText(Integer.toString(value));
            TabObjects.objectsStrength[index] = value;
        } else if ("objectsResearch".equals(variable)) {
            TabObjects.objectsResearchTF[index]
                    .setText(Integer.toString(value));
            TabObjects.objectsResearch[index] = value;
        } else if ("objectsAvail".equals(variable)) {
            if (value == 1) {
                TabObjects.objectsAvailCB[index].setSelected(true);
                TabObjects.objectsAvail[index] = 1;
            } else {
                TabObjects.objectsAvailCB[index].setSelected(false);
                TabObjects.objectsAvail[index] = 0;
            }
        } else if ("objectsStartAvail".equals(variable)) {
            if (value == 1) {
                TabObjects.objectsStartAvailCB[index].setSelected(true);
                TabObjects.objectsStartAvail[index] = 1;
            } else {
                TabObjects.objectsStartAvailCB[index].setSelected(false);
                TabObjects.objectsStartAvail[index] = 0;
            }
        } else if ("startStaff.doctor".equals(variable)) {
            if (value == 1) {
                // make sure that only as many objects as needed are created
                if (index - 1 == TabStaff.startStaffList.size())
                    TabStaff.addStartStaff();
                TabStaff.startStaffList.get(index - 1).doctor = 1;
                TabStaff.startStaffList.get(index - 1).staffMemberCombo
                        .setSelectedItem("Doctor");
            }
        } else if ("startStaff.nurse".equals(variable)) {
            if (value == 1) {
                // make sure that only as many objects as needed are created
                if (index - 1 == TabStaff.startStaffList.size())
                    TabStaff.addStartStaff();
                TabStaff.startStaffList.get(index - 1).nurse = 1;
                TabStaff.startStaffList.get(index - 1).staffMemberCombo
                        .setSelectedItem("Nurse");
            }
        } else if ("startStaff.handyman".equals(variable)) {
            if (value == 1) {
                // make sure that only as many objects as needed are created
                if (index - 1 == TabStaff.startStaffList.size())
                    TabStaff.addStartStaff();
                TabStaff.startStaffList.get(index - 1).handyman = 1;
                TabStaff.startStaffList.get(index - 1).staffMemberCombo
                        .setSelectedItem("Handyman");
            }
        } else if ("startStaff.receptionist".equals(variable)) {
            if (value == 1) {
                // make sure that only as many objects as needed are created
                if (index - 1 == TabStaff.startStaffList.size())
                    TabStaff.addStartStaff();
                TabStaff.startStaffList.get(index - 1).receptionist = 1;
                TabStaff.startStaffList.get(index - 1).staffMemberCombo
                        .setSelectedItem("Receptionist");
            }
        } else if ("startStaff.skill".equals(variable)) {
            TabStaff.startStaffList.get(index - 1).skill = value;
            TabStaff.startStaffList.get(index - 1).skillTF.setText(Integer
                    .toString(value));
        } else if ("startStaff.shrink".equals(variable)) {
            // making sure that the staff member has been created
            if (TabStaff.startStaffList.size() > index - 1) {
                // making sure that the staff member is a doctor before adding
                // other qualifications.
                if (value == 1
                        && TabStaff.startStaffList.get(index - 1).doctor == 1) {
                    TabStaff.startStaffList.get(index - 1).shrink = 1;
                    TabStaff.startStaffList.get(index - 1).shrinkCB
                            .setSelected(true);
                } else {
                    TabStaff.startStaffList.get(index - 1).shrink = 0;
                    TabStaff.startStaffList.get(index - 1).shrinkCB
                            .setSelected(false);
                }
            }
        } else if ("startStaff.surgeon".equals(variable)) {
            // making sure that the staff member has been created
            if (TabStaff.startStaffList.size() > index - 1) {
                // making sure that the staff member is a doctor before adding
                // other qualifications.
                if (value == 1
                        && TabStaff.startStaffList.get(index - 1).doctor == 1) {
                    TabStaff.startStaffList.get(index - 1).surgeon = 1;
                    TabStaff.startStaffList.get(index - 1).surgeonCB
                            .setSelected(true);
                } else {
                    TabStaff.startStaffList.get(index - 1).surgeon = 0;
                    TabStaff.startStaffList.get(index - 1).surgeonCB
                            .setSelected(false);
                }
            }
        } else if ("startStaff.researcher".equals(variable)) {
            // making sure that the staff member has been created
            if (TabStaff.startStaffList.size() > index - 1) {
                // making sure that the staff member is a doctor before adding
                // other qualifications.
                if (value == 1) {
                    TabStaff.startStaffList.get(index - 1).researcher = 1;
                    TabStaff.startStaffList.get(index - 1).researcherCB
                            .setSelected(true);
                } else {
                    TabStaff.startStaffList.get(index - 1).researcher = 0;
                    TabStaff.startStaffList.get(index - 1).researcherCB
                            .setSelected(false);
                }
            }
        } else if ("staffSalary".equals(variable)) {
            TabStaff.staffSalary[index] = value;
            TabStaff.staffSalaryTF[index].setText(Integer.toString(value));
        } else if ("salaryAdd".equals(variable)) {
            TabStaff.salaryAdd[index] = value;
            TabStaff.salaryAddTF[index].setText(Integer.toString(value));
        } else if ("staffLevels.month".equals(variable)) {
            // make sure that only as many objects as needed are created
            if (index == TabStaff.staffLevelsList.size())
                TabStaff.addStaffLevels();
            TabStaff.staffLevelsList.get(index).month = value;
            TabStaff.staffLevelsList.get(index).monthTF.setText(Integer
                    .toString(value));
        } else if ("staffLevels.nurses".equals(variable)) {
            TabStaff.staffLevelsList.get(index).nurses = value;
            TabStaff.staffLevelsList.get(index).nursesTF.setText(Integer
                    .toString(value));
        } else if ("staffLevels.doctors".equals(variable)) {
            TabStaff.staffLevelsList.get(index).doctors = value;
            TabStaff.staffLevelsList.get(index).doctorsTF.setText(Integer
                    .toString(value));
        } else if ("staffLevels.handymen".equals(variable)) {
            TabStaff.staffLevelsList.get(index).handymen = value;
            TabStaff.staffLevelsList.get(index).handymenTF.setText(Integer
                    .toString(value));
        } else if ("staffLevels.receptionists".equals(variable)) {
            TabStaff.staffLevelsList.get(index).receptionists = value;
            TabStaff.staffLevelsList.get(index).receptionistsTF.setText(Integer
                    .toString(value));
        } else if ("staffLevels.shrinkRate".equals(variable)) {
            TabStaff.staffLevelsList.get(index).shrinkRate = value;
            TabStaff.staffLevelsList.get(index).shrinkRateTF.setText("1/"
                    + Integer.toString(value));
        } else if ("staffLevels.surgeonRate".equals(variable)) {
            TabStaff.staffLevelsList.get(index).surgeonRate = value;
            TabStaff.staffLevelsList.get(index).surgeonRateTF.setText("1/"
                    + Integer.toString(value));
        } else if ("staffLevels.researcherRate".equals(variable)) {
            TabStaff.staffLevelsList.get(index).researcherRate = value;
            TabStaff.staffLevelsList.get(index).researcherRateTF.setText("1/"
                    + Integer.toString(value));
        } else if ("staffLevels.consultantRate".equals(variable)) {
            TabStaff.staffLevelsList.get(index).consultantRate = value;
            TabStaff.staffLevelsList.get(index).consultantRateTF.setText("1/"
                    + Integer.toString(value));
        } else if ("staffLevels.juniorRate".equals(variable)) {
            TabStaff.staffLevelsList.get(index).juniorRate = value;
            TabStaff.staffLevelsList.get(index).juniorRateTF.setText("1/"
                    + Integer.toString(value));
        } else if ("emergency.Random".equals(variable))
            TabEmergencies.randomEmergenciesRB.doClick();
        else if ("emergencyInterval".equals(variable)) {
            TabEmergencies.semiRandomEmergenciesRB.doClick();
            TabEmergencies.emergencyInterval = value;
            TabEmergencies.emergencyIntervalTF.setText(Integer.toString(value));
        } else if ("emergencyIntervalVariance".equals(variable)) {
            TabEmergencies.emergencyIntervalVariance = value;
            TabEmergencies.emergencyIntervalVarianceTF.setText(Integer
                    .toString(value));
        } else if ("emergency.startMonth".equals(variable)) {
            // make sure that only as many objects as needed are created
            if (index == TabEmergencies.emergencyList.size())
                TabEmergencies.addEmergency();
            TabEmergencies.emergencyList.get(index).startMonth = value;
            TabEmergencies.emergencyList.get(index).startMonthTF
                    .setText(Integer.toString(value));
        } else if ("emergency.endMonth".equals(variable)) {
            TabEmergencies.emergencyList.get(index).endMonth = value;
            TabEmergencies.emergencyList.get(index).endMonthTF.setText(Integer
                    .toString(value));
        } else if ("emergency.minPatients".equals(variable)) {
            TabEmergencies.emergencyList.get(index).minPatients = value;
            TabEmergencies.emergencyList.get(index).minPatientsTF
                    .setText(Integer.toString(value));
        } else if ("emergency.maxPatients".equals(variable)) {
            TabEmergencies.emergencyList.get(index).maxPatients = value;
            TabEmergencies.emergencyList.get(index).maxPatientsTF
                    .setText(Integer.toString(value));
        } else if ("emergency.illness".equals(variable)) {
            if (value != 0) {
                TabEmergencies.emergencyList.get(index).illness = value;
                TabEmergencies.emergencyList.get(index).illnessCombo
                        .setSelectedItem(TabDiseases.arDiseases[value].name);
            }
        } else if ("emergency.percWin".equals(variable)) {
            TabEmergencies.emergencyList.get(index).percWin = value;
            TabEmergencies.emergencyList.get(index).percWinTF.setText(Integer
                    .toString(value));
        } else if ("emergency.bonus".equals(variable)) {
            TabEmergencies.emergencyList.get(index).bonus = value;
            TabEmergencies.emergencyList.get(index).bonusTF.setText(Integer
                    .toString(value));
        } else if ("quake.startMonth".equals(variable)) {
            // make sure that only as many objects as needed are created
            if (index == TabEarthquakes.quakeList.size())
                TabEarthquakes.addQuake();
            TabEarthquakes.quakeList.get(index).startMonth = value;
            TabEarthquakes.quakeList.get(index).startMonthTF.setText(Integer
                    .toString(value));
        } else if ("quake.endMonth".equals(variable)) {
            TabEarthquakes.quakeList.get(index).endMonth = value;
            TabEarthquakes.quakeList.get(index).endMonthTF.setText(Integer
                    .toString(value));
        } else if ("quake.severity".equals(variable)) {
            TabEarthquakes.quakeList.get(index).severity = value;
            TabEarthquakes.quakeList.get(index).severityTF.setText(Integer
                    .toString(value));
        } else if ("population.month".equals(variable)) {
            // make sure that only as many objects as needed are created
            if (index == TabPopulation.populationList.size())
                TabPopulation.addPopulation();
            TabPopulation.populationList.get(index).month = value;
            TabPopulation.populationList.get(index).monthTF.setText(Integer
                    .toString(value));
        } else if ("population.change".equals(variable)) {
            TabPopulation.populationList.get(index).change = value;
            TabPopulation.populationList.get(index).changeTF.setText(Integer
                    .toString(value));
        }

    }

    // set value for win/lose criteria.
    // same as above with the string arguments.
    public void setCriteria(String variable, boolean exists, int value,
            int value2) {
        if ("winCriteria.value".equals(variable)) {
            if (value == 1) {
                TabGoals.winReputation = exists;
                TabGoals.minReputation = value2;
                TabGoals.winReputationCB.setSelected(exists);
                TabGoals.minReputationTF.setText(Integer.toString(value2));
            }
            if (value == 2) {
                TabGoals.winBalance = exists;
                TabGoals.minBalance = value2;
                TabGoals.winBalanceCB.setSelected(exists);
                TabGoals.minBalanceTF.setText(Integer.toString(value2));
            }
            if (value == 3) {
                TabGoals.winPercentage = exists;
                TabGoals.minPercentage = value2;
                TabGoals.winPercentageCB.setSelected(exists);
                TabGoals.minPercentageTF.setText(Integer.toString(value2));
            }
            if (value == 4) {
                TabGoals.winCureCount = exists;
                TabGoals.minCureCount = value2;
                TabGoals.winCureCountCB.setSelected(exists);
                TabGoals.minCureCountTF.setText(Integer.toString(value2));
            }
            if (value == 6) {
                TabGoals.winValue = exists;
                TabGoals.minValue = value2;
                TabGoals.winValueCB.setSelected(exists);
                TabGoals.minValueTF.setText(Integer.toString(value2));
            }
        } else if ("loseCriteria.value".equals(variable)) {
            if (value == 1) {
                TabGoals.loseReputation = exists;
                TabGoals.maxReputation = value2;
                TabGoals.loseReputationCB.setSelected(exists);
                TabGoals.maxReputationTF.setText(Integer.toString(value2));
            }
            if (value == 2) {
                TabGoals.loseBalance = exists;
                TabGoals.maxBalance = value2;
                TabGoals.loseBalanceCB.setSelected(exists);
                TabGoals.maxBalanceTF.setText(Integer.toString(value2));
            }
            if (value == 5) {
                TabGoals.losePercentageKilled = exists;
                TabGoals.minPercentageKilled = value2;
                TabGoals.losePercentageKilledCB.setSelected(exists);
                TabGoals.minPercentageKilledTF
                        .setText(Integer.toString(value2));
            }
        } else if ("loseCriteria.bound".equals(variable)) {
            if (value == 1 && TabGoals.loseReputation == true) {
                TabGoals.warnReputation = value2;
                TabGoals.warnReputationTF.setText(Integer.toString(value2));
            }
            if (value == 2 && TabGoals.loseBalance == true) {
                TabGoals.warnBalance = value2;
                TabGoals.warnBalanceTF.setText(Integer.toString(value2));
            }
            if (value == 5 && TabGoals.losePercentageKilled == true) {
                TabGoals.warnPercentageKilled = value2;
                TabGoals.warnPercentageKilledTF.setText(Integer
                        .toString(value2));
            }
        }

    }

    // set everything to default
    public void setDefault() {
        clearLists();
        setDefaultTF(TabGeneral.nameTF);
        setDefaultTF(TabGeneral.mapFileTF);
        setDefaultTF(TabGeneral.startCashTF);
        setDefaultTF(TabGeneral.interestTF);
        setDefaultTF(TabGeneral.drugStartRatingTF);
        setDefaultTF(TabGeneral.drugImproveRateTF);
        setDefaultTF(TabGeneral.drugStartCostTF);
        setDefaultTF(TabGeneral.drugMinCostTF);
        setDefaultTF(TabGeneral.landCostPerTileTF);
        setDefaultTF(TabGeneral.autopsyResearchPercentTF);
        setDefaultTF(TabGeneral.autopsyRepHitPercentTF);
        setDefaultTF(TabGeneral.researchUpgradeCostTF);
        setDefaultTF(TabGeneral.researchUpgradeIncrementCostTF);
        setDefaultTF(TabGeneral.strengthIncrementTF);
        setDefaultTF(TabGeneral.maxStrengthTF);
        setDefaultTF(TabEmergencies.emergencyIntervalTF);
        setDefaultTF(TabEmergencies.emergencyIntervalVarianceTF);

        // briefing
        TabGeneral.briefing = TabGeneral.BRIEFING;
        TabGeneral.briefingTA.setText(TabGeneral.BRIEFING);

        // awards
        TabAwards.cansOfCoke = TabAwards.CANS_OF_COKE;
        TabAwards.cansOfCokeTF
                .setText(Integer.toString(TabAwards.CANS_OF_COKE));
        TabAwards.cansOfCokeBonus = TabAwards.CANS_OF_COKE_BONUS;
        TabAwards.cansOfCokeBonusTF.setText(Integer
                .toString(TabAwards.CANS_OF_COKE_BONUS));
        TabAwards.reputation = TabAwards.REPUTATION;
        TabAwards.reputationTF.setText(Integer.toString(TabAwards.REPUTATION));
        TabAwards.reputationBonus = TabAwards.REPUTATION_BONUS;
        TabAwards.reputationBonusTF.setText(Integer
                .toString(TabAwards.REPUTATION_BONUS));
        TabAwards.noDeathsBonus = TabAwards.NO_DEATHS_BONUS;
        TabAwards.noDeathsBonusTF.setText(Integer
                .toString(TabAwards.NO_DEATHS_BONUS));

        setCriteria("winCriteria.value", false, 1, TabGoals.MIN_REPUTATION);
        setCriteria("winCriteria.value", false, 2, TabGoals.MIN_BALANCE);
        setCriteria("winCriteria.value", false, 3, TabGoals.MIN_PERCENTAGE);
        setCriteria("winCriteria.value", false, 4, TabGoals.MIN_CURE_COUNT);
        setCriteria("winCriteria.value", false, 6, TabGoals.MIN_VALUE);
        setCriteria("loseCriteria.value", false, 1, TabGoals.MAX_REPUTATION);
        setCriteria("loseCriteria.value", false, 2, TabGoals.MAX_BALANCE);
        setCriteria("loseCriteria.value", false, 5,
                TabGoals.MIN_PERCENTAGE_KILLED);
        TabGoals.warnReputation = TabGoals.maxReputation + 50;
        TabGoals.warnReputationTF.setText(Integer
                .toString(TabGoals.warnReputation));
        TabGoals.warnBalance = TabGoals.maxBalance + 10000;
        TabGoals.warnBalanceTF.setText(Integer.toString(TabGoals.warnBalance));
        TabGoals.warnPercentageKilled = TabGoals.minPercentageKilled / 2;
        TabGoals.warnPercentageKilledTF.setText(Integer
                .toString(TabGoals.warnPercentageKilled));

        TabEmergencies.controlledEmergenciesRB.doClick();
        TabStaff.addStaffLevels();
        TabPopulation.addPopulation();
        TabPopulation.addPopulation();
        for (JTextField visualsAvailableTF : TabDiseases.visualsAvailableTF) {
            setDefaultTF(visualsAvailableTF);
        }
        for (JCheckBox visualsCB : TabDiseases.visualsCB) {
            setDefaultCB(visualsCB);
        }
        for (JCheckBox nonVisualsCB : TabDiseases.nonVisualsCB) {
            setDefaultCB(nonVisualsCB);
        }
        for (JCheckBox knownCB : TabDiseases.knownCB) {
            setDefaultCB(knownCB);
        }
        for (JTextField expertiseResearchTF : TabDiseases.expertiseResearchTF) {
            setDefaultTF(expertiseResearchTF);
        }
        for (JCheckBox objectsAvailCB : TabObjects.objectsAvailCB) {
            setDefaultCB(objectsAvailCB);
        }
        for (JCheckBox objectsStartAvailCB : TabObjects.objectsStartAvailCB) {
            setDefaultCB(objectsStartAvailCB);
        }
        for (JTextField objectsResearchTF : TabObjects.objectsResearchTF) {
            setDefaultTF(objectsResearchTF);
        }
        for (JTextField objectsStrengthTF : TabObjects.objectsStrengthTF) {
            setDefaultTF(objectsStrengthTF);
        }
        for (JTextField staffSalaryTF : TabStaff.staffSalaryTF) {
            setDefaultTF(staffSalaryTF);
        }
        // index 0,1,2 are not used. start from 3
        for (int i = 3; i < TabStaff.salaryAddTF.length; i++)
            setDefaultTF(TabStaff.salaryAddTF[i]);
    }

    // clears dynamic arrays (arraylists). called by setDefault.
    public void clearLists() {
        for (; TabStaff.startStaffList.size() > 0;)
            TabStaff.removeStartStaff();
        for (; TabStaff.staffLevelsList.size() > 0;)
            TabStaff.removeStaffLevels();
        for (; TabEmergencies.emergencyList.size() > 0;)
            TabEmergencies.removeEmergency();
        for (; TabEarthquakes.quakeList.size() > 0;)
            TabEarthquakes.removeQuake();
        for (; TabPopulation.populationList.size() > 0;)
            TabPopulation.removePopulation();
    }

    // this method is called by setDefault.
    // in the future, it could be called by rightclicking an individual
    // textfield.
    // then again, that can be handled locally, instead of here.
    // i don't like how setDefault is split into several methods.
    // argument should probably refer to a variable, instead of a component.
    public void setDefaultTF(JTextField tf) {
        if (tf == TabGeneral.nameTF)
            setValue("name", TabGeneral.NAME);
        else if (tf == TabGeneral.mapFileTF)
            setValue("mapFile", TabGeneral.MAP_FILE);
        // else if (tf == briefingTF)
        // setValue("briefing", BRIEFING);
        else if (tf == TabGeneral.startCashTF)
            setValue("startCash", Integer.toString(TabGeneral.START_CASH));
        else if (tf == TabGeneral.interestTF)
            setValue("interest", Double.toString(TabGeneral.INTEREST));
        else if (tf == TabGeneral.drugStartRatingTF)
            setValue("drugStartRating",
                    Integer.toString(TabGeneral.DRUG_START_RATING));
        else if (tf == TabGeneral.drugImproveRateTF)
            setValue("drugImproveRate",
                    Integer.toString(TabGeneral.DRUG_IMPROVE_RATE));
        else if (tf == TabGeneral.drugStartCostTF)
            setValue("drugStartCost",
                    Integer.toString(TabGeneral.DRUG_START_COST));
        else if (tf == TabGeneral.drugMinCostTF)
            setValue("drugMinCost", Integer.toString(TabGeneral.DRUG_MIN_COST));
        else if (tf == TabGeneral.landCostPerTileTF)
            setValue("landCostPerTile",
                    Integer.toString(TabGeneral.LAND_COST_PER_TILE));
        else if (tf == TabGeneral.autopsyResearchPercentTF)
            setValue("autopsyResearchPercent",
                    Integer.toString(TabGeneral.AUTOPSY_RESEARCH_PERCENT));
        else if (tf == TabGeneral.autopsyRepHitPercentTF)
            setValue("autopsyRepHitPercent",
                    Integer.toString(TabGeneral.AUTOPSY_REPHIT_PERCENT));
        else if (tf == TabGeneral.researchUpgradeCostTF)
            setValue("researchUpgradeCost",
                    Integer.toString(TabGeneral.RESEARCH_UPGRADE_COST));
        else if (tf == TabGeneral.researchUpgradeIncrementCostTF)
            setValue(
                    "researchUpgradeIncrementCost",
                    Integer.toString(TabGeneral.RESEARCH_UPGRADE_INCREMENT_COST));
        else if (tf == TabGeneral.strengthIncrementTF)
            setValue("strengthIncrement",
                    Integer.toString(TabGeneral.STRENGTH_INCREMENT));
        else if (tf == TabGeneral.maxStrengthTF)
            setValue("maxStrength", Integer.toString(TabGeneral.MAX_STRENGTH));
        else if (tf == TabEmergencies.emergencyIntervalTF) {
            TabEmergencies.emergencyIntervalTF.setText("120");
            TabEmergencies.emergencyInterval = 120;
        } else if (tf == TabEmergencies.emergencyIntervalVarianceTF) {
            TabEmergencies.emergencyIntervalVarianceTF.setText("30");
            TabEmergencies.emergencyIntervalVariance = 30;
        }

        else if (TabDiseases.visualsAvailableTF[0] == tf)
            setValueForTable("visualsAvailable", 0, 0);
        else if (TabDiseases.visualsAvailableTF[1] == tf)
            setValueForTable("visualsAvailable", 1, 12);
        else if (TabDiseases.visualsAvailableTF[2] == tf)
            setValueForTable("visualsAvailable", 2, 3);
        else if (TabDiseases.visualsAvailableTF[3] == tf)
            setValueForTable("visualsAvailable", 3, 12);
        else if (TabDiseases.visualsAvailableTF[4] == tf)
            setValueForTable("visualsAvailable", 4, 18);
        else if (TabDiseases.visualsAvailableTF[5] == tf)
            setValueForTable("visualsAvailable", 5, 6);
        else if (TabDiseases.visualsAvailableTF[6] == tf)
            setValueForTable("visualsAvailable", 6, 0);
        else if (TabDiseases.visualsAvailableTF[7] == tf)
            setValueForTable("visualsAvailable", 7, 6);
        else if (TabDiseases.visualsAvailableTF[8] == tf)
            setValueForTable("visualsAvailable", 8, 12);
        else if (TabDiseases.visualsAvailableTF[9] == tf)
            setValueForTable("visualsAvailable", 9, 0);
        else if (TabDiseases.visualsAvailableTF[10] == tf)
            setValueForTable("visualsAvailable", 10, 18);
        else if (TabDiseases.visualsAvailableTF[11] == tf)
            setValueForTable("visualsAvailable", 11, 0);
        else if (TabDiseases.visualsAvailableTF[12] == tf)
            setValueForTable("visualsAvailable", 12, 0);
        else if (TabDiseases.visualsAvailableTF[13] == tf)
            setValueForTable("visualsAvailable", 13, 6);

        else if (tf == TabDiseases.expertiseResearchTF[0])
            setValueForTable("expertiseResearch", 0, 0);
        else if (tf == TabDiseases.expertiseResearchTF[1])
            setValueForTable("expertiseResearch", 1, 0);
        else if (tf == TabDiseases.expertiseResearchTF[2])
            setValueForTable("expertiseResearch", 2, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[3])
            setValueForTable("expertiseResearch", 3, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[4])
            setValueForTable("expertiseResearch", 4, 60000);
        else if (tf == TabDiseases.expertiseResearchTF[5])
            setValueForTable("expertiseResearch", 5, 60000);
        else if (tf == TabDiseases.expertiseResearchTF[6])
            setValueForTable("expertiseResearch", 6, 60000);
        else if (tf == TabDiseases.expertiseResearchTF[7])
            setValueForTable("expertiseResearch", 7, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[8])
            setValueForTable("expertiseResearch", 8, 60000);
        else if (tf == TabDiseases.expertiseResearchTF[9])
            setValueForTable("expertiseResearch", 9, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[10])
            setValueForTable("expertiseResearch", 10, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[11])
            setValueForTable("expertiseResearch", 11, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[12])
            setValueForTable("expertiseResearch", 12, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[13])
            setValueForTable("expertiseResearch", 13, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[14])
            setValueForTable("expertiseResearch", 14, 30000);
        else if (tf == TabDiseases.expertiseResearchTF[15])
            setValueForTable("expertiseResearch", 15, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[16])
            setValueForTable("expertiseResearch", 16, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[17])
            setValueForTable("expertiseResearch", 17, 60000);
        else if (tf == TabDiseases.expertiseResearchTF[18])
            setValueForTable("expertiseResearch", 18, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[19])
            setValueForTable("expertiseResearch", 19, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[20])
            setValueForTable("expertiseResearch", 20, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[21])
            setValueForTable("expertiseResearch", 21, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[22])
            setValueForTable("expertiseResearch", 22, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[23])
            setValueForTable("expertiseResearch", 23, 60000);
        else if (tf == TabDiseases.expertiseResearchTF[24])
            setValueForTable("expertiseResearch", 24, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[25])
            setValueForTable("expertiseResearch", 25, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[26])
            setValueForTable("expertiseResearch", 26, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[27])
            setValueForTable("expertiseResearch", 27, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[28])
            setValueForTable("expertiseResearch", 28, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[29])
            setValueForTable("expertiseResearch", 29, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[30])
            setValueForTable("expertiseResearch", 30, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[31])
            setValueForTable("expertiseResearch", 31, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[32])
            setValueForTable("expertiseResearch", 32, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[33])
            setValueForTable("expertiseResearch", 33, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[34])
            setValueForTable("expertiseResearch", 34, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[35])
            setValueForTable("expertiseResearch", 35, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[36])
            setValueForTable("expertiseResearch", 36, 40000);
        else if (tf == TabDiseases.expertiseResearchTF[37])
            setValueForTable("expertiseResearch", 37, 50000);
        else if (tf == TabDiseases.expertiseResearchTF[38])
            setValueForTable("expertiseResearch", 38, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[39])
            setValueForTable("expertiseResearch", 39, 30000);
        else if (tf == TabDiseases.expertiseResearchTF[40])
            setValueForTable("expertiseResearch", 40, 60000);
        else if (tf == TabDiseases.expertiseResearchTF[41])
            setValueForTable("expertiseResearch", 41, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[42])
            setValueForTable("expertiseResearch", 42, 20000);
        else if (tf == TabDiseases.expertiseResearchTF[43])
            setValueForTable("expertiseResearch", 43, 20000);

        else if (tf == TabStaff.staffSalaryTF[0])
            setValueForTable("staffSalary", 0, 60);
        else if (tf == TabStaff.staffSalaryTF[1])
            setValueForTable("staffSalary", 1, 75);
        else if (tf == TabStaff.staffSalaryTF[2])
            setValueForTable("staffSalary", 2, 25);
        else if (tf == TabStaff.staffSalaryTF[3])
            setValueForTable("staffSalary", 3, 20);

        else if (tf == TabStaff.salaryAddTF[3])
            setValueForTable("salaryAdd", 3, -30);
        else if (tf == TabStaff.salaryAddTF[4])
            setValueForTable("salaryAdd", 4, 30);
        else if (tf == TabStaff.salaryAddTF[5])
            setValueForTable("salaryAdd", 5, 40);
        else if (tf == TabStaff.salaryAddTF[6])
            setValueForTable("salaryAdd", 6, 30);
        else if (tf == TabStaff.salaryAddTF[7])
            setValueForTable("salaryAdd", 7, 100);
        else if (tf == TabStaff.salaryAddTF[8])
            setValueForTable("salaryAdd", 8, 20);

        else {
            for (int i = 0; i < TabObjects.objectsStrength.length; i++) {
                if (tf == TabObjects.objectsStrengthTF[i]) {
                    switch (i) {
                        case 9:
                            setValueForTable("objectsStrength", i, 8);
                            break;
                        case 13:
                            setValueForTable("objectsStrength", i, 13);
                            break;
                        case 14:
                            setValueForTable("objectsStrength", i, 12);
                            break;
                        case 22:
                            setValueForTable("objectsStrength", i, 9);
                            break;
                        case 23:
                            setValueForTable("objectsStrength", i, 7);
                            break;
                        case 24:
                            setValueForTable("objectsStrength", i, 11);
                            break;
                        case 25:
                            setValueForTable("objectsStrength", i, 8);
                            break;
                        case 26:
                            setValueForTable("objectsStrength", i, 10);
                            break;
                        case 27:
                            setValueForTable("objectsStrength", i, 12);
                            break;
                        case 30:
                            setValueForTable("objectsStrength", i, 12);
                            break;
                        case 42:
                            setValueForTable("objectsStrength", i, 10);
                            break;
                        case 46:
                            setValueForTable("objectsStrength", i, 8);
                            break;
                        case 47:
                            setValueForTable("objectsStrength", i, 7);
                            break;
                        case 54:
                            setValueForTable("objectsStrength", i, 10);
                            break;
                        default:
                            setValueForTable("objectsStrength", i, 10);
                            break;
                    }
                }
            }
            for (int i = 0; i < TabObjects.objectsResearch.length; i++) {
                if (tf == TabObjects.objectsResearchTF[i]) {
                    switch (i) {
                        case 8:
                            setValueForTable("objectsResearch", i, 20000);
                            break;
                        case 9:
                            setValueForTable("objectsResearch", i, 40000);
                            break;
                        case 13:
                            setValueForTable("objectsResearch", i, 20000);
                            break;
                        case 14:
                            setValueForTable("objectsResearch", i, 40000);
                            break;
                        case 18:
                            setValueForTable("objectsResearch", i, 20000);
                            break;
                        case 20:
                            setValueForTable("objectsResearch", i, 20000);
                            break;
                        case 22:
                            setValueForTable("objectsResearch", i, 60000);
                            break;
                        case 23:
                            setValueForTable("objectsResearch", i, 60000);
                            break;
                        case 24:
                            setValueForTable("objectsResearch", i, 20000);
                            break;
                        case 25:
                            setValueForTable("objectsResearch", i, 40000);
                            break;
                        case 26:
                            setValueForTable("objectsResearch", i, 40000);
                            break;
                        case 27:
                            setValueForTable("objectsResearch", i, 30000);
                            break;
                        case 30:
                            setValueForTable("objectsResearch", i, 20000);
                            break;
                        case 37:
                            setValueForTable("objectsResearch", i, 20000);
                            break;
                        case 39:
                            setValueForTable("objectsResearch", i, 20000);
                            break;
                        case 40:
                            setValueForTable("objectsResearch", i, 30000);
                            break;
                        case 41:
                            setValueForTable("objectsResearch", i, 30000);
                            break;
                        case 42:
                            setValueForTable("objectsResearch", i, 50000);
                            break;
                        case 46:
                            setValueForTable("objectsResearch", i, 40000);
                            break;
                        case 47:
                            setValueForTable("objectsResearch", i, 40000);
                            break;
                        case 54:
                            setValueForTable("objectsResearch", i, 60000);
                            break;
                        default:
                            setValueForTable("objectsResearch", i, 0);
                            break;
                    }
                }
            }
        }
    }

    // this method is called by setDefault.
    // argument should probably refer to a variable, instead of a component.
    public void setDefaultCB(JCheckBox cb) {
        for (int i = 0; i < TabDiseases.visualsCB.length; i++) {
            if (TabDiseases.visualsCB[i] == cb) {
                setValueForTable("visuals", i, 0);
                TabDiseases.visualsCB[i].setSelected(false);
            }
        }

        for (int i = 0; i < TabDiseases.nonVisualsCB.length; i++) {
            if (TabDiseases.nonVisualsCB[i] == cb) {
                setValueForTable("nonVisuals", i, 0);
                TabDiseases.nonVisualsCB[i].setSelected(false);
            }
        }

        for (int i = 0; i < TabDiseases.knownCB.length; i++) {
            if (TabDiseases.knownCB[i] == cb) {
                setValueForTable("known", i, 0);
                TabDiseases.knownCB[i].setSelected(false);
            }
        }
        for (int i = 0; i < TabObjects.objectsAvail.length; i++) {
            if (TabObjects.objectsAvailCB[i] == cb) {
                if (i == 9 | i == 13 | i == 14 | i == 22 | i == 23 | i == 24
                        | i == 25 | i == 26 | i == 27 | i == 30 | i == 37
                        | i == 40 | i == 41 | i == 42 | i == 46 | i == 47
                        | i == 54 | i == 57) {
                    setValueForTable("objectsAvail", i, 0);
                    TabObjects.objectsAvailCB[i].setSelected(false);
                } else {
                    setValueForTable("objectsAvail", i, 1);
                    TabObjects.objectsAvailCB[i].setSelected(true);
                }
            }
        }
        for (int i = 0; i < TabObjects.objectsStartAvail.length; i++) {
            if (TabObjects.objectsStartAvailCB[i] == cb) {
                if (i == 9 | i == 13 | i == 14 | i == 22 | i == 23 | i == 24
                        | i == 25 | i == 26 | i == 27 | i == 30 | i == 37
                        | i == 40 | i == 41 | i == 42 | i == 46 | i == 47
                        | i == 54 | i == 57) {
                    setValueForTable("objectsStartAvail", i, 0);
                    TabObjects.objectsStartAvailCB[i].setSelected(false);
                } else {
                    setValueForTable("objectsStartAvail", i, 1);
                    TabObjects.objectsStartAvailCB[i].setSelected(true);
                }
            }
        }

    }

    public void setAllDiseasesAvailable() {
        TabDiseases.checkAllExistsCB1.setSelected(false);
        TabDiseases.checkAllExistsCB2.setSelected(false);
        TabDiseases.checkAllExistsCB3.setSelected(false);
        TabDiseases.checkAllExistsCB4.setSelected(false);
        TabDiseases.checkAllExistsCB1.setSelected(true);
        TabDiseases.checkAllExistsCB2.setSelected(true);
        TabDiseases.checkAllExistsCB3.setSelected(true);
        TabDiseases.checkAllExistsCB4.setSelected(true);
    }

}
