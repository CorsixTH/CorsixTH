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

import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import javax.swing.JLabel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.text.AbstractDocument;
import javax.swing.text.AttributeSet;
import javax.swing.text.BadLocationException;
import javax.swing.text.DocumentFilter;

//creates the general panel
public class TabGeneral extends JScrollPane {

    private static final long serialVersionUID = -1025120107673788464L;

    // variables
    static final String NAME = "Example Town";
    static final String MAP_FILE = "Example.map";
    static final String BRIEFING = "No briefing yet!";
    static final int START_CASH = 40000;
    static final double INTEREST = 1.0;
    static final int DRUG_START_RATING = 100;
    static final int DRUG_IMPROVE_RATE = 5;
    static final int DRUG_START_COST = 100;
    static final int DRUG_MIN_COST = 50;
    static final int LAND_COST_PER_TILE = 25;
    static final int AUTOPSY_RESEARCH_PERCENT = 33;
    static final int AUTOPSY_REPHIT_PERCENT = 25;
    static final int RESEARCH_UPGRADE_COST = 10;
    static final int RESEARCH_UPGRADE_INCREMENT_COST = 10;
    static final int STRENGTH_INCREMENT = 2;
    static final int MAX_STRENGTH = 20;

    static String name = NAME;
    static String mapFile = MAP_FILE;
    static String briefing = BRIEFING;
    static int startCash = START_CASH;
    static double interest = INTEREST;
    static int drugStartRating = DRUG_START_RATING;
    static int drugImproveRate = DRUG_IMPROVE_RATE;
    static int drugStartCost = DRUG_START_COST;
    static int drugMinCost = DRUG_MIN_COST;
    static int landCostPerTile = LAND_COST_PER_TILE;
    static int autopsyResearchPercent = AUTOPSY_RESEARCH_PERCENT;
    static int autopsyRepHitPercent = AUTOPSY_REPHIT_PERCENT;
    static int researchUpgradeCost = RESEARCH_UPGRADE_COST;
    static int researchUpgradeIncrementCost = RESEARCH_UPGRADE_INCREMENT_COST;
    static int strengthIncrement = STRENGTH_INCREMENT;
    static int maxStrength = MAX_STRENGTH;

    // components
    GridPanel general = new GridPanel(2);
    // JScrollPane scrollPane = new JScrollPane(general);

    JLabel nameLabel = new JLabel("Name:");
    JLabel mapFileLabel = new JLabel("Map file:");
    JLabel briefingLabel = new JLabel("Briefing:");
    JLabel startCashLabel = new JLabel("Start cash:");
    JLabel interestRateLabel = new JLabel("Interest in %:");
    JLabel drugStartRatingLabel = new JLabel("Drug effectiveness:");
    JLabel drugImproveRateLabel = new JLabel("Drug improve rate:");
    JLabel drugStartCostLabel = new JLabel("Drug starting cost:");
    JLabel drugMinCostLabel = new JLabel("Minimum drug cost:");
    JLabel landCostPerTileLabel = new JLabel("Land cost per tile:");
    JLabel autopsyResearchPercentLabel = new JLabel("Autopsy research:");
    JLabel autopsyRepHitPercentLabel = new JLabel("Autopsy reputation hit:");
    JLabel researchUpgradeCostLabel = new JLabel("Upgrade research required:");
    JLabel researchUpgradeIncrementCostLabel = new JLabel(
            "Upgrade research increment:");
    JLabel strengthIncrementLabel = new JLabel("Strength Increment:");
    JLabel maxStrengthLabel = new JLabel("Max Object Strength:");

    static JTextField nameTF = new JTextField(50);
    static JTextField mapFileTF = new JTextField(50);
    static JTextArea briefingTA = new JTextArea(3, 50);
    static JTextField startCashTF = new JTextField(10);
    static JTextField interestTF = new JTextField(10);
    static JTextField drugStartRatingTF = new JTextField(10);
    static JTextField drugStartCostTF = new JTextField(10);
    static JTextField drugImproveRateTF = new JTextField(10);
    static JTextField drugMinCostTF = new JTextField(10);
    static JTextField landCostPerTileTF = new JTextField(10);
    static JTextField autopsyResearchPercentTF = new JTextField(10);
    static JTextField autopsyRepHitPercentTF = new JTextField(10);
    static JTextField researchUpgradeCostTF = new JTextField(10);
    static JTextField researchUpgradeIncrementCostTF = new JTextField(10);
    static JTextField strengthIncrementTF = new JTextField(10);
    static JTextField maxStrengthTF = new JTextField(10);

    public TabGeneral() {

        // set scroll speed
        getVerticalScrollBar().setUnitIncrement(20);
        getHorizontalScrollBar().setUnitIncrement(20);

        setViewportView(general);
        general.add(nameLabel);
        general.add(nameTF);
        nameLabel
                .setToolTipText("Name to be displayed on the town map or when choosing a level");

        // when the keyboard focus (the cursor) is put on the textfield or
        // leaves the textfield,
        // perform an action as specified in the TabItem class.
        nameTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
            }

            @Override
            public void focusLost(FocusEvent e) {
                name = nameTF.getText();
            }
        });

        general.add(mapFileLabel);
        general.add(mapFileTF);
        mapFileLabel
                .setToolTipText("Must be a .map file or one of the original levels (Level.L1 - Level.L44). "
                        + "If a custom map is used, it must be in the levels directory of CorsixTH.");
        mapFileTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
            }

            @Override
            public void focusLost(FocusEvent e) {
                String input = mapFileTF.getText();
                // if the input is not a .map file or one of the original
                // levels (level.l1 - level.l44), append ".map" automatically.
                if ((input.toLowerCase().matches(".*\\.map")) == true
                        || (input.toLowerCase()
                                .matches("(level\\.l[1-9])|(level\\.l[1-3]\\d)|(level\\.l4[0-4])")) == true) {
                    mapFile = input;
                } else {
                    mapFile = input + ".map";
                    mapFileTF.setText(mapFile);
                }
            }
        });

        general.add(briefingLabel);
        general.add(briefingTA);
        briefingLabel
                .setToolTipText("The text to be displayed when starting a level");
        briefingTA.setLineWrap(true);
        briefingTA.setWrapStyleWord(true);
        // the document filter restricts newline characters.
        ((AbstractDocument) briefingTA.getDocument())
                .setDocumentFilter(new DocumentFilter() {
                    @Override
                    public void insertString(DocumentFilter.FilterBypass fb,
                            int offset, String text, AttributeSet attr)
                            throws BadLocationException {
                        fb.insertString(offset, text.replaceAll("\n", ""), attr);
                    }

                    @Override
                    public void replace(DocumentFilter.FilterBypass fb,
                            int offset, int length, String text,
                            AttributeSet attr) throws BadLocationException {
                        fb.replace(offset, length, text.replaceAll("\n", ""),
                                attr);
                    }
                });
        briefingTA.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
            }

            @Override
            public void focusLost(FocusEvent e) {
                briefing = briefingTA.getText();
            }
        });

        general.add(startCashLabel);
        general.add(startCashTF);
        startCashLabel.setToolTipText("Cash at the start of the level");
        startCashTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = startCashTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(startCashTF.getText());
                    startCash = input;
                } catch (NumberFormatException nfe) {
                    startCash = Integer.parseInt(Gui.tempValue);
                    startCashTF.setText(Integer.toString(startCash));
                }
            }
        });

        general.add(interestRateLabel);
        general.add(interestTF);
        interestRateLabel.setToolTipText("Interest payment per year");
        interestTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = interestTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    String inputString = interestTF.getText().replaceAll(",",
                            ".");
                    double inputInterest = Double.parseDouble(inputString);
                    interestTF.setText(inputString);
                    if (inputInterest < 0) {
                        interest = 0;
                        interestTF.setText(Double.toString(interest));
                    } else if (inputInterest >= 100) {
                        interest = 99.9;
                        interestTF.setText(Double.toString(interest));
                    } else
                        interest = inputInterest;
                } catch (NumberFormatException nfe) {
                    interest = Double.parseDouble(Gui.tempValue);
                    interestTF.setText(Double.toString(interest));
                }
            }
        });

        general.add(drugStartRatingLabel);
        general.add(drugStartRatingTF);
        drugStartRatingLabel
                .setToolTipText("Drug effectiveness in % to start with");
        drugStartRatingTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = drugStartRatingTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(drugStartRatingTF.getText());
                    if (input <= 0) {
                        drugStartRating = 1;
                        drugStartRatingTF.setText(Integer
                                .toString(drugStartRating));
                    } else if (input > 100) {
                        drugStartRating = 100;
                        drugStartRatingTF.setText(Integer
                                .toString(drugStartRating));
                    } else
                        drugStartRating = input;
                } catch (NumberFormatException nfe) {
                    drugStartRating = Integer.parseInt(Gui.tempValue);
                    drugStartRatingTF.setText(Integer.toString(drugStartRating));
                }
            }
        });

        general.add(drugImproveRateLabel);
        general.add(drugImproveRateTF);
        drugImproveRateLabel
                .setToolTipText("When a drug is improved by research, "
                        + "increase its effectiveness by this amount");
        drugImproveRateTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = drugImproveRateTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(drugImproveRateTF.getText());
                    if (input <= 0) {
                        drugImproveRate = 1;
                        drugImproveRateTF.setText(Integer
                                .toString(drugImproveRate));
                    } else if (input > 100) {
                        drugImproveRate = 100;
                        drugImproveRateTF.setText(Integer
                                .toString(drugImproveRate));
                    } else
                        drugImproveRate = input;
                } catch (NumberFormatException nfe) {
                    drugImproveRate = Integer.parseInt(Gui.tempValue);
                    drugImproveRateTF.setText(Integer.toString(drugImproveRate));
                }
            }
        });

        general.add(drugStartCostLabel);
        general.add(drugStartCostTF);
        drugStartCostLabel
                .setToolTipText("How much it costs each time a drug is used");
        drugStartCostTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = drugStartCostTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(drugStartCostTF.getText());
                    if (input < 0) {
                        drugStartCost = 0;
                        drugStartCostTF.setText(Integer.toString(drugStartCost));
                    } else if (input > 10000) {
                        drugStartCost = 10000;
                        drugStartCostTF.setText(Integer.toString(drugStartCost));
                    } else
                        drugStartCost = input;
                } catch (NumberFormatException nfe) {
                    drugStartCost = Integer.parseInt(Gui.tempValue);
                    drugStartCostTF.setText(Integer.toString(drugStartCost));
                }
                if (drugMinCost > drugStartCost) {
                    drugMinCost = drugStartCost;
                    drugMinCostTF.setText(Integer.toString(drugMinCost));
                }
            }
        });

        general.add(drugMinCostLabel);
        general.add(drugMinCostTF);
        drugMinCostLabel
                .setToolTipText("The lowest drug cost you can get by researching");
        drugMinCostTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = drugMinCostTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(drugMinCostTF.getText());
                    if (input < 0) {
                        drugMinCost = 0;
                        drugMinCostTF.setText(Integer.toString(drugMinCost));
                    } else
                        drugMinCost = input;
                } catch (NumberFormatException nfe) {
                    drugMinCost = Integer.parseInt(Gui.tempValue);
                    drugMinCostTF.setText(Integer.toString(drugMinCost));
                }
                if (drugMinCost > drugStartCost) {
                    drugMinCost = drugStartCost;
                    drugMinCostTF.setText(Integer.toString(drugMinCost));
                }
            }
        });

        general.add(landCostPerTileLabel);
        general.add(landCostPerTileTF);
        landCostPerTileLabel
                .setToolTipText("Cost for purchasing a single square tile of land");
        landCostPerTileTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = landCostPerTileTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(landCostPerTileTF.getText());
                    if (input < 0) {
                        landCostPerTile = 0;
                        landCostPerTileTF.setText(Integer
                                .toString(landCostPerTile));
                    } else if (input > 1000) {
                        landCostPerTile = 1000;
                        landCostPerTileTF.setText(Integer
                                .toString(landCostPerTile));
                    } else
                        landCostPerTile = input;
                } catch (NumberFormatException nfe) {
                    landCostPerTile = Integer.parseInt(Gui.tempValue);
                    landCostPerTileTF.setText(Integer.toString(landCostPerTile));
                }
            }
        });

        general.add(autopsyResearchPercentLabel);
        general.add(autopsyResearchPercentTF);
        autopsyResearchPercentLabel
                .setToolTipText("% of research completed for an autopsy");
        autopsyResearchPercentTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = autopsyResearchPercentTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(autopsyResearchPercentTF
                            .getText());
                    if (input < 1) {
                        autopsyResearchPercent = 1;
                        autopsyResearchPercentTF.setText(Integer
                                .toString(autopsyResearchPercent));
                    } else if (input > 100) {
                        autopsyResearchPercent = 100;
                        autopsyResearchPercentTF.setText(Integer
                                .toString(autopsyResearchPercent));
                    } else
                        autopsyResearchPercent = input;
                } catch (NumberFormatException nfe) {
                    autopsyResearchPercent = Integer.parseInt(Gui.tempValue);
                    autopsyResearchPercentTF.setText(Integer
                            .toString(autopsyResearchPercent));
                }
            }
        });

        general.add(autopsyRepHitPercentLabel);
        general.add(autopsyRepHitPercentTF);
        autopsyRepHitPercentLabel
                .setToolTipText("% reputation hit for discovered autopsy");
        autopsyRepHitPercentTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = autopsyRepHitPercentTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(autopsyRepHitPercentTF
                            .getText());
                    if (input < 0) {
                        autopsyRepHitPercent = 0;
                        autopsyRepHitPercentTF.setText(Integer
                                .toString(autopsyRepHitPercent));
                    } else if (input > 99) {
                        autopsyRepHitPercent = 99;
                        autopsyRepHitPercentTF.setText(Integer
                                .toString(autopsyRepHitPercent));
                    } else
                        autopsyRepHitPercent = input;
                } catch (NumberFormatException nfe) {
                    autopsyRepHitPercent = Integer.parseInt(Gui.tempValue);
                    autopsyRepHitPercentTF.setText(Integer
                            .toString(autopsyRepHitPercent));
                }
            }
        });

        general.add(researchUpgradeCostLabel);
        general.add(researchUpgradeCostTF);
        researchUpgradeCostLabel
                .setToolTipText("How many percent of the original research points of a machine are required to improve it.");
        researchUpgradeCostTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = researchUpgradeCostTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(researchUpgradeCostTF
                            .getText());
                    if (input < 1) {
                        researchUpgradeCost = 1;
                        researchUpgradeCostTF.setText(Integer
                                .toString(researchUpgradeCost));
                    } else if (input > 1000) {
                        researchUpgradeCost = 1000;
                        researchUpgradeCostTF.setText(Integer
                                .toString(researchUpgradeCost));
                    } else
                        researchUpgradeCost = input;
                } catch (NumberFormatException nfe) {
                    researchUpgradeCost = Integer.parseInt(Gui.tempValue);
                    researchUpgradeCostTF.setText(Integer
                            .toString(researchUpgradeCost));
                }
            }
        });

        general.add(researchUpgradeIncrementCostLabel);
        general.add(researchUpgradeIncrementCostTF);
        researchUpgradeIncrementCostLabel
                .setToolTipText("How many additional percentage points are added to the above value for each upgrade.");
        researchUpgradeIncrementCostTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = researchUpgradeIncrementCostTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(researchUpgradeIncrementCostTF
                            .getText());
                    if (input < 0) {
                        researchUpgradeIncrementCost = 0;
                        researchUpgradeIncrementCostTF.setText(Integer
                                .toString(researchUpgradeIncrementCost));
                    } else if (input > 1000) {
                        researchUpgradeIncrementCost = 1000;
                        researchUpgradeIncrementCostTF.setText(Integer
                                .toString(researchUpgradeIncrementCost));
                    } else
                        researchUpgradeIncrementCost = input;
                } catch (NumberFormatException nfe) {
                    researchUpgradeIncrementCost = Integer
                            .parseInt(Gui.tempValue);
                    researchUpgradeIncrementCostTF.setText(Integer
                            .toString(researchUpgradeIncrementCost));
                }
            }
        });

        general.add(strengthIncrementLabel);
        general.add(strengthIncrementTF);
        strengthIncrementLabel
                .setToolTipText("Increase object strength by this amount when researching");
        strengthIncrementTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = strengthIncrementTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(strengthIncrementTF.getText());
                    if (input < 1) {
                        strengthIncrement = 1;
                        strengthIncrementTF.setText(Integer
                                .toString(strengthIncrement));
                    } else if (input > 99) {
                        strengthIncrement = 99;
                        strengthIncrementTF.setText(Integer
                                .toString(strengthIncrement));
                    } else
                        strengthIncrement = input;
                } catch (NumberFormatException nfe) {
                    strengthIncrement = Integer.parseInt(Gui.tempValue);
                    strengthIncrementTF.setText(Integer
                            .toString(strengthIncrement));
                }
            }
        });

        general.add(maxStrengthLabel);
        general.add(maxStrengthTF);
        maxStrengthLabel
                .setToolTipText("Maximum strength value an object can be improved to (by research)");
        maxStrengthTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = maxStrengthTF.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(maxStrengthTF.getText());
                    if (input < 1) {
                        maxStrength = 1;
                        maxStrengthTF.setText(Integer.toString(maxStrength));
                    } else if (input > 99) {
                        maxStrength = 99;
                        maxStrengthTF.setText(Integer.toString(maxStrength));
                    } else
                        maxStrength = input;
                } catch (NumberFormatException nfe) {
                    maxStrength = Integer.parseInt(Gui.tempValue);
                    maxStrengthTF.setText(Integer.toString(maxStrength));
                }
            }
        });
    }

}
