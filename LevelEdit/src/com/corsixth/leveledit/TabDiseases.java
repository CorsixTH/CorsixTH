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

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;

import javax.swing.BorderFactory;
import javax.swing.ButtonGroup;
import javax.swing.JCheckBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JScrollPane;
import javax.swing.JTextField;


public class TabDiseases extends JScrollPane {

    private static final long serialVersionUID = 3970826882625493102L;

    // variables
    static Disease[] arDiseases = new Disease[36]; // index 0,1 are never used.
    static int[] expertiseResearch = new int[47]; // using the numbers of
                                                  // #expertise[]. index [0] is
                                                  // never used.
    static int[] known = new int[47]; // #expertise[]
    static int[] visuals = new int[14];
    static int[] nonVisuals = new int[20];
    static int[] visualsAvailable = new int[14];

    // components
    static JCheckBox[] visualsCB = new JCheckBox[14];
    static JCheckBox[] nonVisualsCB = new JCheckBox[20];
    static JCheckBox[] knownCB = new JCheckBox[47]; // #expertise[]
    static JTextField[] visualsAvailableTF = new JTextField[14];
    static JTextField[] expertiseResearchTF = new JTextField[47]; // #expertise[]

    GridPanel diseases = new GridPanel(1);
    JPanel topPanel = new JPanel();

    GridPanel drug = new GridPanel(5);
    GridPanel psych = new GridPanel(4);
    GridPanel clinic = new GridPanel(4);
    GridPanel op = new GridPanel(4);
    GridPanel selected = drug;

    // top panel
    ButtonGroup buttonGroup = new ButtonGroup();
    JLabel drugLabel = new JLabel("Pharmacy");
    JLabel psychLabel = new JLabel("Psychiatry");
    JLabel clinicLabel = new JLabel("Clinic");
    JLabel opLabel = new JLabel("OP Theatre");
    JRadioButton drugRB = new JRadioButton();
    JRadioButton psychRB = new JRadioButton();
    JRadioButton clinicRB = new JRadioButton();
    JRadioButton opRB = new JRadioButton();

    // column headings for each panel.
    // they are needed 4 times because they cannot be shared among panels
    JLabel existsLabel1 = new JLabel("Available");
    JLabel knownLabel1 = new JLabel("Known");
    JLabel availableLabel1 = new JLabel("Month");
    JLabel researchLabel = new JLabel("Research");
    static JCheckBox checkAllExistsCB1 = new JCheckBox();
    static JCheckBox checkAllKnownCB1 = new JCheckBox();

    JLabel existsLabel2 = new JLabel("Available");
    JLabel knownLabel2 = new JLabel("Known");
    JLabel availableLabel2 = new JLabel("Month");
    static JCheckBox checkAllExistsCB2 = new JCheckBox();
    static JCheckBox checkAllKnownCB2 = new JCheckBox();

    JLabel existsLabel3 = new JLabel("Available");
    JLabel knownLabel3 = new JLabel("Known");
    JLabel availableLabel3 = new JLabel("Month");
    static JCheckBox checkAllExistsCB3 = new JCheckBox();
    static JCheckBox checkAllKnownCB3 = new JCheckBox();

    JLabel existsLabel4 = new JLabel("Available");
    JLabel knownLabel4 = new JLabel("Known");
    JLabel availableLabel4 = new JLabel("Month");
    static JCheckBox checkAllExistsCB4 = new JCheckBox();
    static JCheckBox checkAllKnownCB4 = new JCheckBox();

    // visuals
    JLabel bloatyHeadLabel = new JLabel("Bloaty Head");
    JLabel hairyitusLabel = new JLabel("Hairyitus");
    JLabel elvisLabel = new JLabel("Elvis");
    JLabel invisibleLabel = new JLabel("Invisibility");
    JLabel radiationLabel = new JLabel("Serious Radiation");
    JLabel slackTongueLabel = new JLabel("Slack Tongue");
    JLabel alienLabel = new JLabel("Alien DNA");
    JLabel brokenBonesLabel = new JLabel("Broken Bones");
    JLabel baldnessLabel = new JLabel("Baldness");
    JLabel discreteItchingLabel = new JLabel("Discrete Itching");
    JLabel jellyitusLabel = new JLabel("Jellyitus");
    JLabel sleepingIllnessLabel = new JLabel("Sleeping Illness");
    JLabel pregnantLabel = new JLabel("(Pregnancy)");
    JLabel transparencyLabel = new JLabel("Transparency");
    // non visuals
    JLabel uncommonColdLabel = new JLabel("Uncommon Cold");
    JLabel brokenWindLabel = new JLabel("Broken Wind");
    JLabel spareRibsLabel = new JLabel("Spare Ribs");
    JLabel kidneyBeansLabel = new JLabel("Kidney Beans");
    JLabel brokenHeartLabel = new JLabel("Broken Heart");
    JLabel rupturedNodulesLabel = new JLabel("Ruptured Nodules");
    JLabel multipleTvPersonalitiesLabel = new JLabel(
            "Multiple TV Personalities");
    JLabel infectiousLaughterLabel = new JLabel("Infectious Laughter");
    JLabel corrugatedAnklesLabel = new JLabel("Corrugated Ankles");
    JLabel chronicNosehairLabel = new JLabel("Chronic Nosehair");
    JLabel thirdDegreeSideburnsLabel = new JLabel("3rd Degree Sideburns");
    JLabel fakeBloodLabel = new JLabel("Fake Blood");
    JLabel gastricEjectionsLabel = new JLabel("Gastric Ejections");
    JLabel theSquitsLabel = new JLabel("The Squits");
    JLabel ironLungsLabel = new JLabel("Iron Lungs");
    JLabel sweatyPalmsLabel = new JLabel("Sweaty Palms");
    JLabel heapedPilesLabel = new JLabel("Heaped Piles");
    JLabel gutRotLabel = new JLabel("Gut Rot");
    JLabel golfStonesLabel = new JLabel("Golf Stones");
    JLabel unexpectedSwellingLabel = new JLabel("Unexpected Swelling");

    public TabDiseases() {

        // set scroll speed
        getVerticalScrollBar().setUnitIncrement(20);
        getHorizontalScrollBar().setUnitIncrement(20);

        setViewportView(diseases);

        // initializing members of arrays, else they will be null.
        for (int i = 0; i < visualsCB.length; i++)
            visualsCB[i] = new JCheckBox();
        for (int i = 0; i < nonVisualsCB.length; i++)
            nonVisualsCB[i] = new JCheckBox();
        for (int i = 0; i < knownCB.length; i++)
            knownCB[i] = new JCheckBox();
        for (int i = 0; i < visualsAvailableTF.length; i++)
            visualsAvailableTF[i] = new JTextField(2);
        for (int i = 0; i < expertiseResearchTF.length; i++)
            expertiseResearchTF[i] = new JTextField(5);

        // top panel
        diseases.add(topPanel);
        buttonGroup.add(drugRB);
        buttonGroup.add(psychRB);
        buttonGroup.add(opRB);
        buttonGroup.add(clinicRB);
        topPanel.add(drugRB);
        drugRB.setActionCommand("drug");
        psychRB.setActionCommand("psych");
        opRB.setActionCommand("op");
        clinicRB.setActionCommand("clinic");
        ActionListener listener = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                GridPanel newSelection;
                switch (e.getActionCommand()) {
                    case "op": newSelection = op; break;
                    case "clinic": newSelection = clinic; break;
                    case "psych": newSelection = psych; break;
                    default: newSelection = drug;
                }

                diseases.swap(selected, newSelection);
                selected = newSelection;
                diseases.updateUI();
            }
        };
        drugRB.addActionListener(listener);
        topPanel.add(drugLabel);
        topPanel.add(psychRB);
        psychRB.addActionListener(listener);
        topPanel.add(psychLabel);
        topPanel.add(opRB);
        opRB.addActionListener(listener);
        topPanel.add(opLabel);
        topPanel.add(clinicRB);
        clinicRB.addActionListener(listener);
        topPanel.add(clinicLabel);
        diseases.add(drug);
        buttonGroup.setSelected(drugRB.getModel(), true);

        // create borders for 4 panels
        drug.setBorder(BorderFactory.createTitledBorder("Pharmacy"));
        psych.setBorder(BorderFactory.createTitledBorder("Psychiatry"));
        op.setBorder(BorderFactory.createTitledBorder("OP Theatre"));
        clinic.setBorder(BorderFactory.createTitledBorder("Clinic"));

        // drug panel
        drug.add(new JLabel("Check all"));
        drug.add(checkAllExistsCB1);
        checkAllExistsCB1.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    visualsCB[3].setSelected(true);
                    visualsCB[9].setSelected(true);
                    visualsCB[11].setSelected(true);
                    visualsCB[13].setSelected(true);
                    nonVisualsCB[0].setSelected(true);
                    nonVisualsCB[1].setSelected(true);
                    nonVisualsCB[8].setSelected(true);
                    nonVisualsCB[9].setSelected(true);
                    nonVisualsCB[12].setSelected(true);
                    nonVisualsCB[13].setSelected(true);
                    nonVisualsCB[16].setSelected(true);
                    nonVisualsCB[17].setSelected(true);
                } else {
                    visualsCB[3].setSelected(false);
                    visualsCB[9].setSelected(false);
                    visualsCB[11].setSelected(false);
                    visualsCB[13].setSelected(false);
                    nonVisualsCB[0].setSelected(false);
                    nonVisualsCB[1].setSelected(false);
                    nonVisualsCB[8].setSelected(false);
                    nonVisualsCB[9].setSelected(false);
                    nonVisualsCB[12].setSelected(false);
                    nonVisualsCB[13].setSelected(false);
                    nonVisualsCB[16].setSelected(false);
                    nonVisualsCB[17].setSelected(false);

                }
            }
        });
        drug.add(checkAllKnownCB1);
        checkAllKnownCB1.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    knownCB[5].setSelected(true);
                    knownCB[11].setSelected(true);
                    knownCB[13].setSelected(true);
                    knownCB[15].setSelected(true);
                    knownCB[16].setSelected(true);
                    knownCB[17].setSelected(true);
                    knownCB[24].setSelected(true);
                    knownCB[25].setSelected(true);
                    knownCB[28].setSelected(true);
                    knownCB[29].setSelected(true);
                    knownCB[32].setSelected(true);
                    knownCB[33].setSelected(true);
                } else {
                    knownCB[5].setSelected(false);
                    knownCB[11].setSelected(false);
                    knownCB[13].setSelected(false);
                    knownCB[15].setSelected(false);
                    knownCB[16].setSelected(false);
                    knownCB[17].setSelected(false);
                    knownCB[24].setSelected(false);
                    knownCB[25].setSelected(false);
                    knownCB[28].setSelected(false);
                    knownCB[29].setSelected(false);
                    knownCB[32].setSelected(false);
                    knownCB[33].setSelected(false);

                }
            }
        });
        drug.next(3);
        drug.add(existsLabel1);
        existsLabel1
                .setToolTipText("Whether the disease should appear at all in this level");
        drug.add(knownLabel1);
        knownLabel1
                .setToolTipText("Whether the disease should be known from the beginning in the drug casebook");
        drug.add(researchLabel);
        researchLabel
                .setToolTipText("How much research is required to improve this drug");
        drug.add(availableLabel1);
        availableLabel1
                .setToolTipText("In which month a visual disease should first appear (not implemented in the game yet?)");

        drug.add(invisibleLabel);
        drug.add(visualsCB[3]);
        drug.add(knownCB[5]);
        drug.add(expertiseResearchTF[5]);
        drug.add(visualsAvailableTF[3]);
        invisibleLabel.setToolTipText("worth $1400");
        visualsCB[3].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[3] = 1;
                else
                    visuals[3] = 0;
            }
        });
        knownCB[5].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[5] = 1;
                else
                    known[5] = 0;
            }
        });
        expertiseResearchTF[5].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = expertiseResearchTF[5].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(expertiseResearchTF[5]
                            .getText());
                    if (input < 1) {
                        expertiseResearch[5] = 1;
                        expertiseResearchTF[5].setText(Integer
                                .toString(expertiseResearch[5]));
                    } else
                        expertiseResearch[5] = input;
                } catch (NumberFormatException nfe) {
                    expertiseResearch[5] = Integer.parseInt(Gui.tempValue);
                    expertiseResearchTF[5].setText(Gui.tempValue);
                }
            }
        });
        visualsAvailableTF[3].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[3].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[3]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[3] = 0;
                        visualsAvailableTF[3].setText(Integer
                                .toString(visualsAvailable[3]));
                    } else
                        visualsAvailable[3] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[3] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[3].setText(Gui.tempValue);
                }
            }
        });

        drug.add(discreteItchingLabel);
        drug.add(visualsCB[9]);
        drug.add(knownCB[11]);
        drug.add(expertiseResearchTF[11]);
        drug.add(visualsAvailableTF[9]);
        discreteItchingLabel.setToolTipText("worth $700");
        visualsCB[9].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[9] = 1;
                else
                    visuals[9] = 0;
            }
        });
        knownCB[11].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[11] = 1;
                else
                    known[11] = 0;
            }
        });
        expertiseResearchTF[11].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = expertiseResearchTF[11].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(expertiseResearchTF[11]
                            .getText());
                    if (input < 1) {
                        expertiseResearch[11] = 1;
                        expertiseResearchTF[11].setText(Integer
                                .toString(expertiseResearch[11]));
                    } else
                        expertiseResearch[11] = input;
                } catch (NumberFormatException nfe) {
                    expertiseResearch[11] = Integer.parseInt(Gui.tempValue);
                    expertiseResearchTF[11].setText(Gui.tempValue);
                }
            }
        });
        visualsAvailableTF[9].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[9].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[9]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[9] = 0;
                        visualsAvailableTF[9].setText(Integer
                                .toString(visualsAvailable[9]));
                    } else
                        visualsAvailable[9] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[9] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[9].setText(Gui.tempValue);
                }
            }
        });

        drug.add(sleepingIllnessLabel);
        drug.add(visualsCB[11]);
        drug.add(knownCB[13]);
        drug.add(expertiseResearchTF[13]);
        drug.add(visualsAvailableTF[11]);
        sleepingIllnessLabel.setToolTipText("worth $750");
        visualsCB[11].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[11] = 1;
                else
                    visuals[11] = 0;
            }
        });
        knownCB[13].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[13] = 1;
                else
                    known[13] = 0;
            }
        });
        expertiseResearchTF[13].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = expertiseResearchTF[13].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(expertiseResearchTF[13]
                            .getText());
                    if (input < 1) {
                        expertiseResearch[13] = 1;
                        expertiseResearchTF[13].setText(Integer
                                .toString(expertiseResearch[13]));
                    } else
                        expertiseResearch[13] = input;
                } catch (NumberFormatException nfe) {
                    expertiseResearch[13] = Integer.parseInt(Gui.tempValue);
                    expertiseResearchTF[13].setText(Gui.tempValue);
                }
            }
        });
        visualsAvailableTF[11].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[11].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[11]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[11] = 0;
                        visualsAvailableTF[11].setText(Integer
                                .toString(visualsAvailable[11]));
                    } else
                        visualsAvailable[11] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[11] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[11].setText(Gui.tempValue);
                }
            }
        });

        drug.add(transparencyLabel);
        drug.add(visualsCB[13]);
        drug.add(knownCB[15]);
        drug.add(expertiseResearchTF[15]);
        drug.add(visualsAvailableTF[13]);
        transparencyLabel.setToolTipText("worth $800");
        visualsCB[13].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[13] = 1;
                else
                    visuals[13] = 0;
            }
        });
        knownCB[15].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[15] = 1;
                else
                    known[15] = 0;
            }
        });
        expertiseResearchTF[15].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = expertiseResearchTF[15].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(expertiseResearchTF[15]
                            .getText());
                    if (input < 1) {
                        expertiseResearch[15] = 1;
                        expertiseResearchTF[15].setText(Integer
                                .toString(expertiseResearch[15]));
                    } else
                        expertiseResearch[15] = input;
                } catch (NumberFormatException nfe) {
                    expertiseResearch[15] = Integer.parseInt(Gui.tempValue);
                    expertiseResearchTF[15].setText(Gui.tempValue);
                }
            }
        });
        visualsAvailableTF[13].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[13].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[13]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[13] = 0;
                        visualsAvailableTF[13].setText(Integer
                                .toString(visualsAvailable[13]));
                    } else
                        visualsAvailable[13] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[13] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[13].setText(Gui.tempValue);
                }
            }
        });

        drug.add(uncommonColdLabel);
        drug.add(nonVisualsCB[0]);
        drug.add(knownCB[16]);
        drug.add(expertiseResearchTF[16]);
        drug.next();
        uncommonColdLabel.setToolTipText("worth $300");
        nonVisualsCB[0].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[0] = 1;
                else
                    nonVisuals[0] = 0;
            }
        });
        knownCB[16].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[16] = 1;
                else
                    known[16] = 0;
            }
        });
        expertiseResearchTF[16].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = expertiseResearchTF[16].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(expertiseResearchTF[16]
                            .getText());
                    if (input < 1) {
                        expertiseResearch[16] = 1;
                        expertiseResearchTF[16].setText(Integer
                                .toString(expertiseResearch[16]));
                    } else
                        expertiseResearch[16] = input;
                } catch (NumberFormatException nfe) {
                    expertiseResearch[16] = Integer.parseInt(Gui.tempValue);
                    expertiseResearchTF[16].setText(Gui.tempValue);
                }
            }
        });

        drug.add(brokenWindLabel);
        drug.add(nonVisualsCB[1]);
        drug.add(knownCB[17]);
        drug.add(expertiseResearchTF[17]);
        drug.next();
        brokenWindLabel.setToolTipText("worth $1300");
        nonVisualsCB[1].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[1] = 1;
                else
                    nonVisuals[1] = 0;
            }
        });
        knownCB[17].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[17] = 1;
                else
                    known[17] = 0;
            }
        });
        expertiseResearchTF[17].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = expertiseResearchTF[17].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(expertiseResearchTF[17]
                            .getText());
                    if (input < 1) {
                        expertiseResearch[17] = 1;
                        expertiseResearchTF[17].setText(Integer
                                .toString(expertiseResearch[17]));
                    } else
                        expertiseResearch[17] = input;
                } catch (NumberFormatException nfe) {
                    expertiseResearch[17] = Integer.parseInt(Gui.tempValue);
                    expertiseResearchTF[17].setText(Gui.tempValue);
                }
            }
        });

        drug.add(corrugatedAnklesLabel);
        drug.add(nonVisualsCB[8]);
        drug.add(knownCB[24]);
        drug.add(expertiseResearchTF[24]);
        drug.next();
        corrugatedAnklesLabel.setToolTipText("worth $800");
        nonVisualsCB[8].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[8] = 1;
                else
                    nonVisuals[8] = 0;
            }
        });
        knownCB[24].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[24] = 1;
                else
                    known[24] = 0;
            }
        });
        expertiseResearchTF[24].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = expertiseResearchTF[24].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(expertiseResearchTF[24]
                            .getText());
                    if (input < 1) {
                        expertiseResearch[24] = 1;
                        expertiseResearchTF[24].setText(Integer
                                .toString(expertiseResearch[24]));
                    } else
                        expertiseResearch[24] = input;
                } catch (NumberFormatException nfe) {
                    expertiseResearch[24] = Integer.parseInt(Gui.tempValue);
                    expertiseResearchTF[24].setText(Gui.tempValue);
                }
            }
        });

        drug.add(chronicNosehairLabel);
        drug.add(nonVisualsCB[9]);
        drug.add(knownCB[25]);
        drug.add(expertiseResearchTF[25]);
        drug.next();
        chronicNosehairLabel.setToolTipText("worth $800");
        nonVisualsCB[9].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[9] = 1;
                else
                    nonVisuals[9] = 0;
            }
        });
        knownCB[25].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[25] = 1;
                else
                    known[25] = 0;
            }
        });
        expertiseResearchTF[25].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = expertiseResearchTF[25].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(expertiseResearchTF[25]
                            .getText());
                    if (input < 1) {
                        expertiseResearch[25] = 1;
                        expertiseResearchTF[25].setText(Integer
                                .toString(expertiseResearch[25]));
                    } else
                        expertiseResearch[25] = input;
                } catch (NumberFormatException nfe) {
                    expertiseResearch[25] = Integer.parseInt(Gui.tempValue);
                    expertiseResearchTF[25].setText(Gui.tempValue);
                }
            }
        });

        drug.add(gastricEjectionsLabel);
        drug.add(nonVisualsCB[12]);
        drug.add(knownCB[28]);
        drug.add(expertiseResearchTF[28]);
        drug.next();
        gastricEjectionsLabel.setToolTipText("worth $650");
        nonVisualsCB[12].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[12] = 1;
                else
                    nonVisuals[12] = 0;
            }
        });
        knownCB[28].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[28] = 1;
                else
                    known[28] = 0;
            }
        });
        expertiseResearchTF[28].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = expertiseResearchTF[28].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(expertiseResearchTF[28]
                            .getText());
                    if (input < 1) {
                        expertiseResearch[28] = 1;
                        expertiseResearchTF[28].setText(Integer
                                .toString(expertiseResearch[28]));
                    } else
                        expertiseResearch[28] = input;
                } catch (NumberFormatException nfe) {
                    expertiseResearch[28] = Integer.parseInt(Gui.tempValue);
                    expertiseResearchTF[28].setText(Gui.tempValue);
                }
            }
        });

        drug.add(theSquitsLabel);
        drug.add(nonVisualsCB[13]);
        drug.add(knownCB[29]);
        drug.add(expertiseResearchTF[29]);
        drug.next();
        theSquitsLabel.setToolTipText("worth $400");
        nonVisualsCB[13].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[13] = 1;
                else
                    nonVisuals[13] = 0;
            }
        });
        knownCB[29].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[29] = 1;
                else
                    known[29] = 0;
            }
        });
        expertiseResearchTF[29].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = expertiseResearchTF[29].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(expertiseResearchTF[29]
                            .getText());
                    if (input < 1) {
                        expertiseResearch[29] = 1;
                        expertiseResearchTF[29].setText(Integer
                                .toString(expertiseResearch[29]));
                    } else
                        expertiseResearch[29] = input;
                } catch (NumberFormatException nfe) {
                    expertiseResearch[29] = Integer.parseInt(Gui.tempValue);
                    expertiseResearchTF[29].setText(Gui.tempValue);
                }
            }
        });

        drug.add(heapedPilesLabel);
        drug.add(nonVisualsCB[16]);
        drug.add(knownCB[32]);
        drug.add(expertiseResearchTF[32]);
        drug.next();
        heapedPilesLabel.setToolTipText("worth $400");
        nonVisualsCB[16].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[16] = 1;
                else
                    nonVisuals[16] = 0;
            }
        });
        knownCB[32].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[32] = 1;
                else
                    known[32] = 0;
            }
        });
        expertiseResearchTF[32].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = expertiseResearchTF[32].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(expertiseResearchTF[32]
                            .getText());
                    if (input < 1) {
                        expertiseResearch[32] = 1;
                        expertiseResearchTF[32].setText(Integer
                                .toString(expertiseResearch[32]));
                    } else
                        expertiseResearch[32] = input;
                } catch (NumberFormatException nfe) {
                    expertiseResearch[32] = Integer.parseInt(Gui.tempValue);
                    expertiseResearchTF[32].setText(Gui.tempValue);
                }
            }
        });

        drug.add(gutRotLabel);
        drug.add(nonVisualsCB[17]);
        drug.add(knownCB[33]);
        drug.add(expertiseResearchTF[33]);
        drug.next();
        gutRotLabel.setToolTipText("worth $350");
        nonVisualsCB[17].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[17] = 1;
                else
                    nonVisuals[17] = 0;
            }
        });
        knownCB[33].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[33] = 1;
                else
                    known[33] = 0;
            }
        });
        expertiseResearchTF[33].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = expertiseResearchTF[33].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(expertiseResearchTF[33]
                            .getText());
                    if (input < 1) {
                        expertiseResearch[33] = 1;
                        expertiseResearchTF[33].setText(Integer
                                .toString(expertiseResearch[33]));
                    } else
                        expertiseResearch[33] = input;
                } catch (NumberFormatException nfe) {
                    expertiseResearch[33] = Integer.parseInt(Gui.tempValue);
                    expertiseResearchTF[33].setText(Gui.tempValue);
                }
            }
        });

        // psych panel
        psych.add(new JLabel("Check all"));
        psych.add(checkAllExistsCB2);
        checkAllExistsCB2.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    visualsCB[2].setSelected(true);
                    nonVisualsCB[6].setSelected(true);
                    nonVisualsCB[7].setSelected(true);
                    nonVisualsCB[10].setSelected(true);
                    nonVisualsCB[11].setSelected(true);
                    nonVisualsCB[15].setSelected(true);
                } else {
                    visualsCB[2].setSelected(false);
                    nonVisualsCB[6].setSelected(false);
                    nonVisualsCB[7].setSelected(false);
                    nonVisualsCB[10].setSelected(false);
                    nonVisualsCB[11].setSelected(false);
                    nonVisualsCB[15].setSelected(false);
                }
            }
        });
        psych.add(checkAllKnownCB2);
        checkAllKnownCB2.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    knownCB[4].setSelected(true);
                    knownCB[22].setSelected(true);
                    knownCB[23].setSelected(true);
                    knownCB[26].setSelected(true);
                    knownCB[27].setSelected(true);
                    knownCB[31].setSelected(true);
                } else {
                    knownCB[4].setSelected(false);
                    knownCB[22].setSelected(false);
                    knownCB[23].setSelected(false);
                    knownCB[26].setSelected(false);
                    knownCB[27].setSelected(false);
                    knownCB[31].setSelected(false);
                }
            }
        });
        psych.next(2);
        psych.add(existsLabel2);
        existsLabel2
                .setToolTipText("Whether the disease should appear at all in this level");

        psych.add(knownLabel2);
        knownLabel2
                .setToolTipText("Whether the disease should be known from the beginning in the drug casebook");

        psych.add(availableLabel2);
        availableLabel2
                .setToolTipText("In which month the disease should first appear (not implemented in the game yet?)");

        psych.add(elvisLabel);
        psych.add(visualsCB[2]);
        psych.add(knownCB[4]);
        psych.add(visualsAvailableTF[2]);
        elvisLabel.setToolTipText("worth $1600");
        visualsCB[2].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[2] = 1;
                else
                    visuals[2] = 0;
            }
        });
        knownCB[4].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[4] = 1;
                else
                    known[4] = 0;
            }
        });
        visualsAvailableTF[2].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[2].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[2]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[2] = 0;
                        visualsAvailableTF[2].setText(Integer
                                .toString(visualsAvailable[2]));
                    } else
                        visualsAvailable[2] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[2] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[2].setText(Gui.tempValue);
                }
            }
        });

        psych.add(multipleTvPersonalitiesLabel);
        psych.add(nonVisualsCB[6]);
        psych.add(knownCB[22]);
        psych.next();
        multipleTvPersonalitiesLabel.setToolTipText("worth $800");
        nonVisualsCB[6].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[6] = 1;
                else
                    nonVisuals[6] = 0;
            }
        });
        knownCB[22].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[22] = 1;
                else
                    known[22] = 0;
            }
        });

        psych.add(infectiousLaughterLabel);
        psych.add(nonVisualsCB[7]);
        psych.add(knownCB[23]);
        psych.next();
        infectiousLaughterLabel.setToolTipText("worth $1500");
        nonVisualsCB[7].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[7] = 1;
                else
                    nonVisuals[7] = 0;
            }
        });
        knownCB[23].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[23] = 1;
                else
                    known[23] = 0;
            }
        });

        psych.add(thirdDegreeSideburnsLabel);
        psych.add(nonVisualsCB[10]);
        psych.add(knownCB[26]);
        psych.next();
        thirdDegreeSideburnsLabel.setToolTipText("worth $550");
        nonVisualsCB[10].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[10] = 1;
                else
                    nonVisuals[10] = 0;
            }
        });
        knownCB[26].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[26] = 1;
                else
                    known[26] = 0;
            }
        });

        psych.add(fakeBloodLabel);
        psych.add(nonVisualsCB[11]);
        psych.add(knownCB[27]);
        psych.next();
        fakeBloodLabel.setToolTipText("worth $800");
        nonVisualsCB[11].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[11] = 1;
                else
                    nonVisuals[11] = 0;
            }
        });
        knownCB[27].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[27] = 1;
                else
                    known[27] = 0;
            }
        });

        psych.add(sweatyPalmsLabel);
        psych.add(nonVisualsCB[15]);
        psych.add(knownCB[31]);
        psych.next();
        sweatyPalmsLabel.setToolTipText("worth $600");
        nonVisualsCB[15].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[15] = 1;
                else
                    nonVisuals[15] = 0;
            }
        });
        knownCB[31].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[31] = 1;
                else
                    known[31] = 0;
            }
        });

        // op panel
        op.add(new JLabel("Check all"));
        op.add(checkAllExistsCB3);
        checkAllExistsCB3.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    visualsCB[12].setSelected(true);
                    nonVisualsCB[2].setSelected(true);
                    nonVisualsCB[3].setSelected(true);
                    nonVisualsCB[4].setSelected(true);
                    nonVisualsCB[5].setSelected(true);
                    nonVisualsCB[14].setSelected(true);
                    nonVisualsCB[18].setSelected(true);
                    nonVisualsCB[19].setSelected(true);
                } else {
                    visualsCB[12].setSelected(false);
                    nonVisualsCB[2].setSelected(false);
                    nonVisualsCB[3].setSelected(false);
                    nonVisualsCB[4].setSelected(false);
                    nonVisualsCB[5].setSelected(false);
                    nonVisualsCB[14].setSelected(false);
                    nonVisualsCB[18].setSelected(false);
                    nonVisualsCB[19].setSelected(false);
                }
            }
        });
        op.add(checkAllKnownCB3);
        checkAllKnownCB3.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    knownCB[14].setSelected(true);
                    knownCB[18].setSelected(true);
                    knownCB[19].setSelected(true);
                    knownCB[20].setSelected(true);
                    knownCB[21].setSelected(true);
                    knownCB[30].setSelected(true);
                    knownCB[34].setSelected(true);
                    knownCB[35].setSelected(true);
                } else {
                    knownCB[14].setSelected(false);
                    knownCB[18].setSelected(false);
                    knownCB[19].setSelected(false);
                    knownCB[20].setSelected(false);
                    knownCB[21].setSelected(false);
                    knownCB[30].setSelected(false);
                    knownCB[34].setSelected(false);
                    knownCB[35].setSelected(false);
                }
            }
        });
        op.next(2);

        op.add(existsLabel3);
        existsLabel3
                .setToolTipText("Whether the disease should appear at all in this level");

        op.add(knownLabel3);
        knownLabel3
                .setToolTipText("Whether the disease should be known from the beginning in the drug casebook");

        op.add(availableLabel3);
        availableLabel3
                .setToolTipText("In which month the disease should first appear (not implemented in the game yet?)");

        op.add(pregnantLabel);
        op.add(visualsCB[12]);
        op.add(knownCB[14]);
        op.add(visualsAvailableTF[12]);
        pregnantLabel.setToolTipText("not implemented!");
        visualsCB[12].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[12] = 1;
                else
                    visuals[12] = 0;
            }
        });
        knownCB[14].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[14] = 1;
                else
                    known[14] = 0;
            }
        });
        visualsAvailableTF[12].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[13].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[12]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[12] = 0;
                        visualsAvailableTF[12].setText(Integer
                                .toString(visualsAvailable[12]));
                    } else
                        visualsAvailable[12] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[12] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[12].setText(Gui.tempValue);
                }
            }
        });

        op.add(spareRibsLabel);
        op.add(nonVisualsCB[2]);
        op.add(knownCB[18]);
        op.next();
        spareRibsLabel.setToolTipText("worth $1100");
        nonVisualsCB[2].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[2] = 1;
                else
                    nonVisuals[2] = 0;
            }
        });
        knownCB[18].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[18] = 1;
                else
                    known[18] = 0;
            }
        });

        op.add(kidneyBeansLabel);
        op.add(nonVisualsCB[3]);
        op.add(knownCB[19]);
        op.next();
        kidneyBeansLabel.setToolTipText("worth $1050");
        nonVisualsCB[3].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[3] = 1;
                else
                    nonVisuals[3] = 0;
            }
        });
        knownCB[19].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[19] = 1;
                else
                    known[19] = 0;
            }
        });

        op.add(brokenHeartLabel);
        op.add(nonVisualsCB[4]);
        op.add(knownCB[20]);
        op.next();
        brokenHeartLabel.setToolTipText("worth $1950");
        nonVisualsCB[4].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[4] = 1;
                else
                    nonVisuals[4] = 0;
            }
        });
        knownCB[20].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[20] = 1;
                else
                    known[20] = 0;
            }
        });

        op.add(rupturedNodulesLabel);
        op.add(nonVisualsCB[5]);
        op.add(knownCB[21]);
        op.next();
        rupturedNodulesLabel.setToolTipText("worth $1600");
        nonVisualsCB[5].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[5] = 1;
                else
                    nonVisuals[5] = 0;
            }
        });
        knownCB[21].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[21] = 1;
                else
                    known[21] = 0;
            }
        });

        op.add(ironLungsLabel);
        op.add(nonVisualsCB[14]);
        op.add(knownCB[30]);
        op.next();
        ironLungsLabel.setToolTipText("worth $1700");
        nonVisualsCB[14].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[14] = 1;
                else
                    nonVisuals[14] = 0;
            }
        });
        knownCB[30].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[30] = 1;
                else
                    known[30] = 0;
            }
        });

        op.add(golfStonesLabel);
        op.add(nonVisualsCB[18]);
        op.add(knownCB[34]);
        op.next();
        golfStonesLabel.setToolTipText("worth $1600");
        nonVisualsCB[18].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[18] = 1;
                else
                    nonVisuals[18] = 0;
            }
        });
        knownCB[34].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[34] = 1;
                else
                    known[34] = 0;
            }
        });

        op.add(unexpectedSwellingLabel);
        op.add(nonVisualsCB[19]);
        op.add(knownCB[35]);
        unexpectedSwellingLabel.setToolTipText("worth $500");
        nonVisualsCB[19].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    nonVisuals[19] = 1;
                else
                    nonVisuals[19] = 0;
            }
        });
        knownCB[35].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[35] = 1;
                else
                    known[35] = 0;
            }
        });

        // clinic panel
        clinic.add(new JLabel("Check all"));
        clinic.add(checkAllExistsCB4);
        checkAllExistsCB4.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    visualsCB[0].setSelected(true);
                    visualsCB[1].setSelected(true);
                    visualsCB[4].setSelected(true);
                    visualsCB[5].setSelected(true);
                    visualsCB[6].setSelected(true);
                    visualsCB[7].setSelected(true);
                    visualsCB[8].setSelected(true);
                    visualsCB[10].setSelected(true);
                } else {
                    visualsCB[0].setSelected(false);
                    visualsCB[1].setSelected(false);
                    visualsCB[4].setSelected(false);
                    visualsCB[5].setSelected(false);
                    visualsCB[6].setSelected(false);
                    visualsCB[7].setSelected(false);
                    visualsCB[8].setSelected(false);
                    visualsCB[10].setSelected(false);
                }
            }
        });
        clinic.add(checkAllKnownCB4);
        checkAllKnownCB4.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    knownCB[2].setSelected(true);
                    knownCB[3].setSelected(true);
                    knownCB[6].setSelected(true);
                    knownCB[7].setSelected(true);
                    knownCB[8].setSelected(true);
                    knownCB[9].setSelected(true);
                    knownCB[10].setSelected(true);
                    knownCB[12].setSelected(true);
                } else {
                    knownCB[2].setSelected(false);
                    knownCB[3].setSelected(false);
                    knownCB[6].setSelected(false);
                    knownCB[7].setSelected(false);
                    knownCB[8].setSelected(false);
                    knownCB[9].setSelected(false);
                    knownCB[10].setSelected(false);
                    knownCB[12].setSelected(false);
                }
            }
        });
        clinic.next(2);
        clinic.add(existsLabel4);
        existsLabel4
                .setToolTipText("Whether the disease should appear at all in this level");

        clinic.add(knownLabel4);
        knownLabel4
                .setToolTipText("Whether the disease should be known from the beginning in the drug casebook");

        clinic.add(availableLabel4);
        availableLabel4
                .setToolTipText("In which month the disease should first appear (not implemented in the game yet?)");

        clinic.add(radiationLabel);
        clinic.add(visualsCB[4]);
        clinic.add(knownCB[6]);
        clinic.add(visualsAvailableTF[4]);
        radiationLabel.setToolTipText("worth $1800");
        visualsCB[4].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[4] = 1;
                else
                    visuals[4] = 0;
            }
        });
        knownCB[6].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[6] = 1;
                else
                    known[6] = 0;
            }
        });
        visualsAvailableTF[4].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[4].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[4]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[4] = 0;
                        visualsAvailableTF[4].setText(Integer
                                .toString(visualsAvailable[4]));
                    } else
                        visualsAvailable[4] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[4] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[4].setText(Gui.tempValue);
                }
            }
        });

        clinic.add(slackTongueLabel);
        clinic.add(visualsCB[5]);
        clinic.add(knownCB[7]);
        clinic.add(visualsAvailableTF[5]);
        slackTongueLabel.setToolTipText("worth $900");
        visualsCB[5].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[5] = 1;
                else
                    visuals[5] = 0;
            }
        });
        knownCB[7].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[7] = 1;
                else
                    known[7] = 0;
            }
        });
        visualsAvailableTF[5].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[5].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[5]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[5] = 0;
                        visualsAvailableTF[5].setText(Integer
                                .toString(visualsAvailable[5]));
                    } else
                        visualsAvailable[5] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[5] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[5].setText(Gui.tempValue);
                }
            }
        });

        clinic.add(alienLabel);
        clinic.add(visualsCB[6]);
        clinic.add(knownCB[8]);
        clinic.add(visualsAvailableTF[6]);
        alienLabel.setToolTipText("worth $2000");
        visualsCB[6].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[6] = 1;
                else
                    visuals[6] = 0;
            }
        });
        knownCB[8].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[8] = 1;
                else
                    known[8] = 0;
            }
        });
        visualsAvailableTF[6].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[6].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[6]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[6] = 0;
                        visualsAvailableTF[6].setText(Integer
                                .toString(visualsAvailable[6]));
                    } else
                        visualsAvailable[6] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[6] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[6].setText(Gui.tempValue);
                }
            }
        });

        clinic.add(brokenBonesLabel);
        clinic.add(visualsCB[7]);
        clinic.add(knownCB[9]);
        clinic.add(visualsAvailableTF[7]);
        brokenBonesLabel.setToolTipText("worth $450");
        visualsCB[7].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[7] = 1;
                else
                    visuals[7] = 0;
            }
        });
        knownCB[9].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[9] = 1;
                else
                    known[9] = 0;
            }
        });
        visualsAvailableTF[7].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[7].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[7]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[7] = 0;
                        visualsAvailableTF[7].setText(Integer
                                .toString(visualsAvailable[7]));
                    } else
                        visualsAvailable[7] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[7] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[7].setText(Gui.tempValue);
                }
            }
        });

        clinic.add(baldnessLabel);
        clinic.add(visualsCB[8]);
        clinic.add(knownCB[10]);
        clinic.add(visualsAvailableTF[8]);
        baldnessLabel.setToolTipText("worth $950");
        visualsCB[8].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[8] = 1;
                else
                    visuals[8] = 0;
            }
        });
        knownCB[10].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[10] = 1;
                else
                    known[10] = 0;
            }
        });
        visualsAvailableTF[8].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[8].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[8]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[8] = 0;
                        visualsAvailableTF[8].setText(Integer
                                .toString(visualsAvailable[8]));
                    } else
                        visualsAvailable[8] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[8] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[8].setText(Gui.tempValue);
                }
            }
        });

        clinic.add(jellyitusLabel);
        clinic.add(visualsCB[10]);
        clinic.add(knownCB[12]);
        clinic.add(visualsAvailableTF[10]);
        jellyitusLabel.setToolTipText("worth $1000");
        visualsCB[10].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[10] = 1;
                else
                    visuals[10] = 0;
            }
        });
        knownCB[12].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[12] = 1;
                else
                    known[12] = 0;
            }
        });
        visualsAvailableTF[10].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[10].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[10]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[10] = 0;
                        visualsAvailableTF[10].setText(Integer
                                .toString(visualsAvailable[10]));
                    } else
                        visualsAvailable[10] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[10] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[10].setText(Gui.tempValue);
                }
            }
        });

        clinic.add(bloatyHeadLabel);
        clinic.add(visualsCB[0]);
        clinic.add(knownCB[2]);
        clinic.add(visualsAvailableTF[0]);
        bloatyHeadLabel.setToolTipText("worth $850");
        visualsCB[0].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[0] = 1;
                else
                    visuals[0] = 0;
            }
        });
        knownCB[2].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[2] = 1;
                else
                    known[2] = 0;
            }
        });
        visualsAvailableTF[0].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[0].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[0]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[0] = 0;
                        visualsAvailableTF[0].setText(Integer
                                .toString(visualsAvailable[0]));
                    } else
                        visualsAvailable[0] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[0] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[0].setText(Gui.tempValue);
                }
            }
        });

        clinic.add(hairyitusLabel);
        clinic.add(visualsCB[1]);
        clinic.add(knownCB[3]);
        clinic.add(visualsAvailableTF[1]);
        hairyitusLabel.setToolTipText("worth $1150");
        visualsCB[1].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    visuals[1] = 1;
                else
                    visuals[1] = 0;
            }
        });
        knownCB[3].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    known[3] = 1;
                else
                    known[3] = 0;
            }
        });
        visualsAvailableTF[1].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = visualsAvailableTF[1].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(visualsAvailableTF[1]
                            .getText());
                    if (input < 0) {
                        visualsAvailable[1] = 0;
                        visualsAvailableTF[1].setText(Integer
                                .toString(visualsAvailable[1]));
                    } else
                        visualsAvailable[1] = input;
                } catch (NumberFormatException nfe) {
                    visualsAvailable[1] = Integer.parseInt(Gui.tempValue);
                    visualsAvailableTF[1].setText(Gui.tempValue);
                }
            }
        });
    }

}
