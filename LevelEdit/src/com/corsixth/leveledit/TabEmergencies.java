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
import java.util.ArrayList;
import java.util.Random;

import javax.swing.BorderFactory;
import javax.swing.ButtonGroup;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JScrollPane;
import javax.swing.JTextField;

public class TabEmergencies extends JScrollPane {

    private static final long serialVersionUID = 415938853978498463L;
    // variables
    static ArrayList<Emergency> emergencyList = new ArrayList<Emergency>();
    static int emergencyInterval = 120;
    static int emergencyIntervalVariance = 30;

    // components
    static GridPanel emergencies = new GridPanel(1);
    JScrollPane scrollPane = new JScrollPane(emergencies);
    JPanel emergencyMode = new JPanel();
    JPanel semirandom = new JPanel();
    JPanel emergencyButtons = new JPanel();
    JButton addEmergencyButt = new JButton("Add");
    JButton removeEmergencyButt = new JButton("Remove");
    ButtonGroup buttonGroup = new ButtonGroup();

    static JRadioButton randomEmergenciesRB = new JRadioButton();
    static JRadioButton semiRandomEmergenciesRB = new JRadioButton();
    static JRadioButton controlledEmergenciesRB = new JRadioButton();
    static JLabel randomDescription = new JLabel(
            "Random emergencies are enabled.");
    static JLabel noEmergenciesDescription = new JLabel(
            "No emergencies will happen.");
    static JLabel emergencyIntervalLabel = new JLabel("Interval:");
    static JLabel emergencyIntervalVarianceLabel = new JLabel("Variance:");
    static JTextField emergencyIntervalTF = new JTextField(
            Integer.toString(emergencyInterval), 3);
    static JTextField emergencyIntervalVarianceTF = new JTextField(
            Integer.toString(emergencyIntervalVariance), 3);

    public TabEmergencies() {
        // set scroll speed
        getVerticalScrollBar().setUnitIncrement(20);
        getHorizontalScrollBar().setUnitIncrement(20);

        emergencies.setInsets(0);
        setViewportView(emergencies);
        // mode set
        buttonGroup.add(randomEmergenciesRB);
        buttonGroup.add(semiRandomEmergenciesRB);
        buttonGroup.add(controlledEmergenciesRB);

        emergencies.add(emergencyMode);
        emergencyMode.setBorder(BorderFactory.createTitledBorder("Mode"));
        emergencyMode.add(randomEmergenciesRB);
        randomEmergenciesRB.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Emergency.emergencyMode = 0;
                showRandomEmergencies();
            }
        });
        emergencyMode.add(new JLabel("Random"));

        emergencyMode.add(semiRandomEmergenciesRB);
        semiRandomEmergenciesRB.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Emergency.emergencyMode = 1;
                showSemiRandomEmergencies();
            }
        });
        emergencyMode.add(new JLabel("Semi-random"));

        emergencyMode.add(controlledEmergenciesRB);
        controlledEmergenciesRB.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                Emergency.emergencyMode = 2;
                showControlledEmergencies();
            }
        });
        emergencyMode.add(new JLabel("Controlled"));

        // emergency control
        showControlledEmergencies();
        emergencyButtons.add(addEmergencyButt);
        addEmergencyButt.addActionListener(new ActionListener() {
            // on click add button
            @Override
            public void actionPerformed(ActionEvent e) {
                addEmergency();
            }
        });

        emergencyButtons.add(removeEmergencyButt);
        removeEmergencyButt.addActionListener(new ActionListener() {
            // on click remove button
            @Override
            public void actionPerformed(ActionEvent e) {
                removeEmergency();
            }
        });

        semirandom.add(emergencyIntervalLabel);
        emergencyIntervalLabel
                .setToolTipText("Days between emergencies = interval +- variance");
        semirandom.add(emergencyIntervalTF);
        emergencyIntervalTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                try {
                    int input = Integer.parseInt(tf.getText());
                    if (input <= 0) {
                        tf.setText(Gui.tempValue);
                        emergencyInterval = Integer.parseInt(Gui.tempValue);
                    } else
                        emergencyInterval = input;
                } catch (NumberFormatException nfe) {
                    tf.setText(Gui.tempValue);
                    emergencyInterval = Integer.parseInt(Gui.tempValue);
                }
                // if variance is equal or bigger than interval, make variance
                // equal to interval -1
                if (emergencyIntervalVariance >= emergencyInterval) {
                    emergencyIntervalVariance = emergencyInterval - 1;
                    int intervalMinusOne = Integer.parseInt(emergencyIntervalTF
                            .getText()) - 1;
                    emergencyIntervalVarianceTF.setText(Integer
                            .toString(intervalMinusOne));
                }

            }
        });
        semirandom.add(emergencyIntervalVarianceLabel);
        emergencyIntervalVarianceLabel
                .setToolTipText("Days between emergencies = interval +- variance");
        semirandom.add(emergencyIntervalVarianceTF);
        emergencyIntervalVarianceTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                try {
                    int input = Integer.parseInt(tf.getText());
                    if (input < 0) {
                        tf.setText(Gui.tempValue);
                        emergencyIntervalVariance = Integer
                                .parseInt(Gui.tempValue);
                    } else
                        emergencyIntervalVariance = input;
                } catch (NumberFormatException nfe) {
                    tf.setText(Gui.tempValue);
                    emergencyIntervalVariance = Integer.parseInt(Gui.tempValue);
                }
                // if variance is equal or bigger than interval, make variance
                // equal to interval -1
                if (emergencyIntervalVariance >= emergencyInterval) {
                    emergencyIntervalVariance = emergencyInterval - 1;
                    int intervalMinusOne = Integer.parseInt(emergencyIntervalTF
                            .getText()) - 1;
                    emergencyIntervalVarianceTF.setText(Integer
                            .toString(intervalMinusOne));
                }

            }
        });
    }

    public static void addEmergency() {
        emergencies.remove(noEmergenciesDescription);

        final Emergency emergency = new Emergency();
        emergencyList.add(emergency);

        // get the index of this particular arraylist member
        final int index = (emergencyList.indexOf(emergency));

        // this code seems weird. I was trying to give each disease in the
        // combobox
        // some sort of ID number which is independant of the position and name,
        // but haven't figured it out yet.
        for (int i = 2; i < TabDiseases.arDiseases.length; i++) {
            switch (i) {
            case 2:
                TabDiseases.arDiseases[i] = new Disease("Bloaty Head");
                break;
            case 3:
                TabDiseases.arDiseases[i] = new Disease("Hairyitus");
                break;
            case 4:
                TabDiseases.arDiseases[i] = new Disease("Elvis");
                break;
            case 5:
                TabDiseases.arDiseases[i] = new Disease("Invisibility");
                break;
            case 6:
                TabDiseases.arDiseases[i] = new Disease("Serious Radiation");
                break;
            case 7:
                TabDiseases.arDiseases[i] = new Disease("Slack Tongue");
                break;
            case 8:
                TabDiseases.arDiseases[i] = new Disease("Alien DNA");
                break;
            case 9:
                TabDiseases.arDiseases[i] = new Disease("Broken Bones");
                break;
            case 10:
                TabDiseases.arDiseases[i] = new Disease("Baldness");
                break;
            case 11:
                TabDiseases.arDiseases[i] = new Disease("Discrete Itching");
                break;
            case 12:
                TabDiseases.arDiseases[i] = new Disease("Jellyitus");
                break;
            case 13:
                TabDiseases.arDiseases[i] = new Disease("Sleeping Illness");
                break;
            case 14:
                TabDiseases.arDiseases[i] = new Disease("Pregnancy");
                break;
            case 15:
                TabDiseases.arDiseases[i] = new Disease("Transparency");
                break;
            case 16:
                TabDiseases.arDiseases[i] = new Disease("Uncommon Cold");
                break;
            case 17:
                TabDiseases.arDiseases[i] = new Disease("Broken Wind");
                break;
            case 18:
                TabDiseases.arDiseases[i] = new Disease("Spare Ribs");
                break;
            case 19:
                TabDiseases.arDiseases[i] = new Disease("Kidney Beans");
                break;
            case 20:
                TabDiseases.arDiseases[i] = new Disease("Broken Heart");
                break;
            case 21:
                TabDiseases.arDiseases[i] = new Disease("Ruptured Nodules");
                break;
            case 22:
                TabDiseases.arDiseases[i] = new Disease(
                        "Multiple TV Personalities");
                break;
            case 23:
                TabDiseases.arDiseases[i] = new Disease("Infectious Laughter");
                break;
            case 24:
                TabDiseases.arDiseases[i] = new Disease("Corrugated Ankles");
                break;
            case 25:
                TabDiseases.arDiseases[i] = new Disease("Chronic Nosehair");
                break;
            case 26:
                TabDiseases.arDiseases[i] = new Disease("3rd Degree Sideburns");
                break;
            case 27:
                TabDiseases.arDiseases[i] = new Disease("Fake Blood");
                break;
            case 28:
                TabDiseases.arDiseases[i] = new Disease("Gastric Ejections");
                break;
            case 29:
                TabDiseases.arDiseases[i] = new Disease("The Squits");
                break;
            case 30:
                TabDiseases.arDiseases[i] = new Disease("Iron Lungs");
                break;
            case 31:
                TabDiseases.arDiseases[i] = new Disease("Sweaty Palms");
                break;
            case 32:
                TabDiseases.arDiseases[i] = new Disease("Heaped Piles");
                break;
            case 33:
                TabDiseases.arDiseases[i] = new Disease("Gut Rot");
                break;
            case 34:
                TabDiseases.arDiseases[i] = new Disease("Golf Stones");
                break;
            case 35:
                TabDiseases.arDiseases[i] = new Disease("Unexpected Swelling");
                break;
            }

        }
        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).illnessCombo);
        emergencyList.get(index).illnessCombo
                .addActionListener(new ActionListener() {
                    @Override
                    public void actionPerformed(ActionEvent e) {
                        JComboBox cb = (JComboBox) e.getSource();
                        for (int i = 2; i < TabDiseases.arDiseases.length; i++) {
                            if (cb.getSelectedItem() == TabDiseases.arDiseases[i].name) {
                                emergencyList.get(index).illness = i;
                            }
                        }
                    }
                });

        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).startMonthLabel);
        emergencyList.get(index).startMonthLabel
                .setToolTipText("The emergency will appear between start month and end month.");
        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).startMonthTF);
        emergencyList.get(index).startMonthTF
                .addFocusListener(new FocusListener() {
                    @Override
                    public void focusGained(FocusEvent e) {
                        JTextField tf = (JTextField) e.getComponent();
                        tf.selectAll();
                        Gui.tempValue = tf.getText();
                    }

                    @Override
                    public void focusLost(FocusEvent e) {
                        JTextField tf = (JTextField) e.getComponent();
                        try {
                            int input = Integer.parseInt(tf.getText());
                            if (input < 1) {
                                tf.setText(Gui.tempValue);
                                emergencyList.get(index).startMonth = Integer
                                        .parseInt(Gui.tempValue);
                            } else
                                emergencyList.get(index).startMonth = input;
                        } catch (NumberFormatException nfe) {
                            tf.setText(Gui.tempValue);
                            emergencyList.get(index).startMonth = Integer
                                    .parseInt(Gui.tempValue);
                        }
                        // if endmonth is smaller than startmonth, make endmonth
                        // equal to startmonth
                        if (emergencyList.get(index).endMonth < emergencyList
                                .get(index).startMonth) {
                            emergencyList.get(index).endMonth = emergencyList
                                    .get(index).startMonth;
                            emergencyList.get(index).endMonthTF
                                    .setText(emergencyList.get(index).startMonthTF
                                            .getText());
                        }

                    }
                });
        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).endMonthLabel);
        emergencyList.get(index).endMonthLabel
                .setToolTipText("The emergency will appear between start month and end month.");
        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).endMonthTF);
        emergencyList.get(index).endMonthTF
                .addFocusListener(new FocusListener() {
                    @Override
                    public void focusGained(FocusEvent e) {
                        JTextField tf = (JTextField) e.getComponent();
                        tf.selectAll();
                        Gui.tempValue = tf.getText();
                    }

                    @Override
                    public void focusLost(FocusEvent e) {
                        JTextField tf = (JTextField) e.getComponent();
                        try {
                            int input = Integer.parseInt(tf.getText());
                            if (input < 1) {
                                tf.setText(Gui.tempValue);
                                emergencyList.get(index).endMonth = Integer
                                        .parseInt(Gui.tempValue);
                            } else
                                emergencyList.get(index).endMonth = input;
                        } catch (NumberFormatException nfe) {
                            tf.setText(Gui.tempValue);
                            emergencyList.get(index).endMonth = Integer
                                    .parseInt(Gui.tempValue);
                        }
                        // if endmonth is smaller than startmonth, make endmonth
                        // equal to startmonth
                        if (emergencyList.get(index).endMonth < emergencyList
                                .get(index).startMonth) {
                            emergencyList.get(index).endMonth = emergencyList
                                    .get(index).startMonth;
                            emergencyList.get(index).endMonthTF
                                    .setText(emergencyList.get(index).startMonthTF
                                            .getText());
                        }
                    }
                });

        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).minPatientsLabel);
        emergencyList.get(index).minPatientsLabel
                .setToolTipText("Minimum number of patients to come from the emergency");
        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).minPatientsTF);
        emergencyList.get(index).minPatientsTF
                .addFocusListener(new FocusListener() {
                    @Override
                    public void focusGained(FocusEvent e) {
                        JTextField tf = (JTextField) e.getComponent();
                        tf.selectAll();
                        Gui.tempValue = tf.getText();
                    }

                    @Override
                    public void focusLost(FocusEvent e) {
                        JTextField tf = (JTextField) e.getComponent();
                        try {
                            int input = Integer.parseInt(tf.getText());
                            if (input < 1) {
                                tf.setText(Gui.tempValue);
                                emergencyList.get(index).minPatients = Integer
                                        .parseInt(Gui.tempValue);
                            } else
                                emergencyList.get(index).minPatients = input;
                        } catch (NumberFormatException nfe) {
                            tf.setText(Gui.tempValue);
                            emergencyList.get(index).minPatients = Integer
                                    .parseInt(Gui.tempValue);
                        }
                        // if maxPatients is smaller than minPatients, make
                        // maxPatients equal to minPatients
                        if (emergencyList.get(index).maxPatients < emergencyList
                                .get(index).minPatients) {
                            emergencyList.get(index).maxPatients = emergencyList
                                    .get(index).minPatients;
                            emergencyList.get(index).maxPatientsTF
                                    .setText(emergencyList.get(index).minPatientsTF
                                            .getText());
                        }

                    }
                });
        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).maxPatientsLabel);
        emergencyList.get(index).maxPatientsLabel
                .setToolTipText("Maximum number of patients to come from the emergency");
        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).maxPatientsTF);
        emergencyList.get(index).maxPatientsTF
                .addFocusListener(new FocusListener() {
                    @Override
                    public void focusGained(FocusEvent e) {
                        JTextField tf = (JTextField) e.getComponent();
                        tf.selectAll();
                        Gui.tempValue = tf.getText();
                    }

                    @Override
                    public void focusLost(FocusEvent e) {
                        JTextField tf = (JTextField) e.getComponent();
                        try {
                            int input = Integer.parseInt(tf.getText());
                            if (input < 1) {
                                tf.setText(Gui.tempValue);
                                emergencyList.get(index).maxPatients = Integer
                                        .parseInt(Gui.tempValue);
                            } else
                                emergencyList.get(index).maxPatients = input;
                        } catch (NumberFormatException nfe) {
                            tf.setText(Gui.tempValue);
                            emergencyList.get(index).maxPatients = Integer
                                    .parseInt(Gui.tempValue);
                        }
                        // if maxPatients is smaller than minPatients, make
                        // maxPatients equal to minPatients
                        if (emergencyList.get(index).maxPatients < emergencyList
                                .get(index).minPatients) {
                            emergencyList.get(index).maxPatients = emergencyList
                                    .get(index).minPatients;
                            emergencyList.get(index).maxPatientsTF
                                    .setText(emergencyList.get(index).minPatientsTF
                                            .getText());
                        }

                    }
                });
        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).percWinLabel);
        emergencyList.get(index).percWinLabel
                .setToolTipText("How many percent of the patients must be cured to receive the bonus");
        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).percWinTF);
        emergencyList.get(index).percWinTF
                .addFocusListener(new FocusListener() {
                    @Override
                    public void focusGained(FocusEvent e) {
                        JTextField tf = (JTextField) e.getComponent();
                        tf.selectAll();
                        Gui.tempValue = tf.getText();
                    }

                    @Override
                    public void focusLost(FocusEvent e) {
                        JTextField tf = (JTextField) e.getComponent();
                        try {
                            int input = Integer.parseInt(tf.getText());
                            if (input < 0) {
                                emergencyList.get(index).percWin = 0;
                                emergencyList.get(index).percWinTF
                                        .setText(Integer.toString(emergencyList
                                                .get(index).percWin));
                            } else if (input > 100) {
                                emergencyList.get(index).percWin = 100;
                                emergencyList.get(index).percWinTF
                                        .setText(Integer.toString(emergencyList
                                                .get(index).percWin));
                            } else {
                                emergencyList.get(index).percWin = input;
                            }
                        } catch (NumberFormatException nfe) {
                            tf.setText(Gui.tempValue);
                            emergencyList.get(index).percWin = Integer
                                    .parseInt(Gui.tempValue);
                        }
                    }
                });
        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).bonusLabel);
        emergencyList.get(index).bonusLabel
                .setToolTipText("Cash bonus for each patient cured");
        emergencyList.get(index).emergencyPanel
                .add(emergencyList.get(index).bonusTF);
        emergencyList.get(index).bonusTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                try {
                    int input = Integer.parseInt(tf.getText());
                    if (input > 1)
                        emergencyList.get(index).bonus = input;
                    else {
                        tf.setText(Gui.tempValue);
                        emergencyList.get(index).bonus = Integer
                                .parseInt(Gui.tempValue);
                    }
                } catch (NumberFormatException nfe) {
                    tf.setText(Gui.tempValue);
                    emergencyList.get(index).bonus = Integer
                            .parseInt(Gui.tempValue);

                }
            }
        });

        emergencies.add(emergencyList.get(index).emergencyPanel);
        emergencies.updateUI();

        // increase month with each add
        if (emergencyList.size() > 1) {
            emergencyList.get(index).startMonth = emergencyList.get(index - 1).endMonth + 3;
            int endMonthPlus = Integer
                    .parseInt(emergencyList.get(index - 1).endMonthTF.getText()) + 3;
            emergencyList.get(index).startMonthTF.setText(Integer
                    .toString(endMonthPlus));

            emergencyList.get(index).endMonth = emergencyList.get(index).startMonth + 3;
            int startMonthPlus = Integer
                    .parseInt(emergencyList.get(index).startMonthTF.getText()) + 3;
            emergencyList.get(index).endMonthTF.setText(Integer
                    .toString(startMonthPlus));
        }

        // randomize illnesses
        Random rand = new Random();
        // get a random int between 2 and 35, as in: (0 to 33) + 2
        int randomInt = (rand.nextInt(34) + 2);
        emergencyList.get(index).illness = randomInt;
        emergencyList.get(index).illnessCombo
                .setSelectedItem(TabDiseases.arDiseases[randomInt].name);
    }

    public static void removeEmergency() {
        int lastIndex = emergencyList.size() - 1;
        if (lastIndex >= 0) {
            // remove panel
            emergencies.remove(emergencyList.get(lastIndex).emergencyPanel);
            emergencies.updateUI();
            // remove object from the arraylist
            emergencyList.remove(lastIndex);

            if (emergencyList.size() <= 0)
                emergencies.add(noEmergenciesDescription);
        }

    }

    // random
    protected void showRandomEmergencies() {
        hideControlledEmergencies();
        hideSemiRandomEmergencies();
        emergencies.remove(noEmergenciesDescription);
        emergencies.add(randomDescription);
        emergencies.updateUI();

    }

    // semi-random
    protected void showSemiRandomEmergencies() {

        emergencies.remove(randomDescription);
        emergencies.remove(noEmergenciesDescription);
        hideControlledEmergencies();

        emergencies.add(semirandom);
        emergencies.updateUI();

    }

    // semi-random
    protected void hideSemiRandomEmergencies() {
        emergencies.remove(semirandom);
        emergencies.updateUI();
    }

    // controlled
    protected void showControlledEmergencies() {
        emergencies.remove(randomDescription);
        emergencies.remove(noEmergenciesDescription);
        hideSemiRandomEmergencies();
        emergencies.add(emergencyButtons);
        for (int i = 0; i < emergencyList.size(); i++)
            emergencies.add(emergencyList.get(i).emergencyPanel);
        if (emergencyList.size() <= 0)
            emergencies.add(noEmergenciesDescription);
        emergencies.updateUI();

    }

    // controlled
    public void hideControlledEmergencies() {

        for (int i = 0; i < emergencyList.size(); i++) {
            emergencies.remove(emergencyList.get(i).emergencyPanel);
        }
        emergencies.remove(emergencyButtons);
        emergencies.updateUI();
    }
}
