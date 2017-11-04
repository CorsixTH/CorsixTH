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

import java.awt.FlowLayout;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;

import javax.swing.BorderFactory;
import javax.swing.JCheckBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextField;

public class TabGoals extends JScrollPane {

    private static final long serialVersionUID = 1413048579654855631L;
    // variables
    static boolean winReputation = false;
    static boolean winBalance = false;
    static boolean winPercentage = false;
    static boolean winCureCount = false;
    static boolean winValue = false;
    static boolean loseReputation = false;
    static boolean loseBalance = false;
    static boolean losePercentageKilled = false;

    static final int MIN_REPUTATION = 300;
    static final int MIN_BALANCE = 1000;
    static final int MIN_PERCENTAGE = 40;
    static final int MIN_CURE_COUNT = 10;
    static final int MIN_VALUE = 55000;
    static final int MAX_REPUTATION = 200;
    static final int MAX_BALANCE = -20000;
    static final int MIN_PERCENTAGE_KILLED = 50;

    static int minReputation = MIN_REPUTATION;
    static int minBalance = MIN_BALANCE;
    static int minPercentage = MIN_PERCENTAGE;
    static int minCureCount = MIN_CURE_COUNT;
    static int minValue = MIN_VALUE;

    static int maxReputation = MAX_REPUTATION;
    static int maxBalance = MAX_BALANCE;
    static int minPercentageKilled = MIN_PERCENTAGE_KILLED;

    static int warnReputation;
    static int warnBalance;
    static int warnPercentageKilled;

    // components
    static GridPanel winCriteria = new GridPanel(3);
    static GridPanel loseCriteria = new GridPanel(5);

    static JLabel minReputationLabel = new JLabel("Reputation:");
    static JLabel minBalanceLabel = new JLabel("Bank balance:");
    static JLabel minPercentageLabel = new JLabel("Percentage treated:");
    static JLabel minCureCountLabel = new JLabel("Cure count:");
    static JLabel minValueLabel = new JLabel("Hospital Value:");
    static JLabel maxReputationLabel = new JLabel("Reputation:");
    static JLabel maxBalanceLabel = new JLabel("Bank balance:");
    static JLabel minPercentageKilledLabel = new JLabel("Percentage killed:");
    static JLabel warnReputationLabel = new JLabel("Warn player at:");
    static JLabel warnBalanceLabel = new JLabel("Warn player at:");
    static JLabel warnPercentageKilledLabel = new JLabel("Warn player at:");

    static JTextField minReputationTF = new JTextField(
            Integer.toString(minReputation), 5);
    static JTextField minBalanceTF = new JTextField(
            Integer.toString(minBalance), 5);
    static JTextField minPercentageTF = new JTextField(
            Integer.toString(minPercentage), 5);
    static JTextField minCureCountTF = new JTextField(
            Integer.toString(minCureCount), 5);
    static JTextField minValueTF = new JTextField(Integer.toString(minValue), 5);
    static JTextField maxReputationTF = new JTextField(
            Integer.toString(maxReputation), 5);
    static JTextField maxBalanceTF = new JTextField(
            Integer.toString(maxBalance), 5);
    static JTextField minPercentageKilledTF = new JTextField(
            Integer.toString(minPercentageKilled), 5);
    static JTextField warnReputationTF = new JTextField(
            Integer.toString(warnReputation), 5);
    static JTextField warnBalanceTF = new JTextField(
            Integer.toString(warnBalance), 5);
    static JTextField warnPercentageKilledTF = new JTextField(
            Integer.toString(warnPercentageKilled), 5);

    static JCheckBox winReputationCB = new JCheckBox();
    static JCheckBox winBalanceCB = new JCheckBox();
    static JCheckBox winPercentageCB = new JCheckBox();
    static JCheckBox winCureCountCB = new JCheckBox();
    static JCheckBox winValueCB = new JCheckBox();
    static JCheckBox loseReputationCB = new JCheckBox();
    static JCheckBox loseBalanceCB = new JCheckBox();
    static JCheckBox losePercentageKilledCB = new JCheckBox();

    JPanel goals = new JPanel();

    public TabGoals() {
        // set scroll speed
        getVerticalScrollBar().setUnitIncrement(20);
        getHorizontalScrollBar().setUnitIncrement(20);

        FlowLayout layout = new FlowLayout(FlowLayout.LEADING);
        layout.setAlignOnBaseline(true);
        goals.setLayout(layout);
        setViewportView(goals);
        // win criteria
        goals.add(winCriteria);
        winCriteria.setBorder(BorderFactory.createTitledBorder("Win Criteria"));
        winCriteria.add(minReputationLabel);
        winCriteria.add(winReputationCB);
        winReputationCB.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    winReputation = true;
                    minReputationTF.setEditable(true);
                } else {
                    winReputation = false;
                    minReputationTF.setEditable(false);
                }
            }
        });
        winCriteria.add(minReputationTF);
        minReputationTF.setEditable(false);
        minReputationTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(((JTextField) e.getComponent())
                            .getText());
                    if (input < 1) {
                        minReputation = 1;
                        minReputationTF.setText(Integer.toString(minReputation));
                    } else if (input > 999) {
                        minReputation = 999;
                        minReputationTF.setText(Integer.toString(minReputation));
                    } else
                        minReputation = input;
                } catch (NumberFormatException nfe) {
                    minReputation = Integer.parseInt(Gui.tempValue);
                    minReputationTF.setText(Gui.tempValue);
                }
            }
        });

        winCriteria.add(minBalanceLabel);
        winCriteria.add(winBalanceCB);
        winBalanceCB.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    winBalance = true;
                    minBalanceTF.setEditable(true);
                } else {
                    winBalance = false;
                    minBalanceTF.setEditable(false);
                }
            }
        });
        winCriteria.add(minBalanceTF);
        minBalanceTF.setEditable(false);
        minBalanceTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(((JTextField) e.getComponent())
                            .getText());
                    if (input < 1) {
                        minBalance = 1;
                        minBalanceTF.setText(Integer.toString(minBalance));
                    } else
                        minBalance = input;
                } catch (NumberFormatException nfe) {
                    minBalance = Integer.parseInt(Gui.tempValue);
                    minBalanceTF.setText(Gui.tempValue);
                }
            }
        });

        winCriteria.add(minPercentageLabel);
        winCriteria.add(winPercentageCB);
        winPercentageCB.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    winPercentage = true;
                    minPercentageTF.setEditable(true);
                } else {
                    winPercentage = false;
                    minPercentageTF.setEditable(false);
                }
            }
        });
        winCriteria.add(minPercentageTF);
        minPercentageTF.setEditable(false);
        minPercentageTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(((JTextField) e.getComponent())
                            .getText());
                    if (input < 1) {
                        minPercentage = Integer.parseInt(Gui.tempValue);
                        minPercentageTF.setText(Gui.tempValue);
                    } else if (input > 100) {
                        minPercentage = 100;
                        minPercentageTF.setText(Integer.toString(minPercentage));
                    } else
                        minPercentage = input;
                } catch (NumberFormatException nfe) {
                    minPercentage = Integer.parseInt(Gui.tempValue);
                    minPercentageTF.setText(Gui.tempValue);
                }
            }
        });

        winCriteria.add(minCureCountLabel);
        winCriteria.add(winCureCountCB);
        winCureCountCB.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    winCureCount = true;
                    minCureCountTF.setEditable(true);
                } else {
                    winCureCount = false;
                    minCureCountTF.setEditable(false);
                }
            }
        });
        winCriteria.add(minCureCountTF);
        minCureCountTF.setEditable(false);
        minCureCountTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(((JTextField) e.getComponent())
                            .getText());
                    if (input < 1) {
                        minCureCount = 1;
                        minCureCountTF.setText(Integer.toString(minCureCount));
                    } else
                        minCureCount = input;
                } catch (NumberFormatException nfe) {
                    minCureCount = Integer.parseInt(Gui.tempValue);
                    minCureCountTF.setText(Gui.tempValue);
                }
            }
        });

        winCriteria.add(minValueLabel);
        winCriteria.add(winValueCB);
        winValueCB.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    winValue = true;
                    minValueTF.setEditable(true);
                } else {
                    winValue = false;
                    minValueTF.setEditable(false);
                }
            }
        });
        winCriteria.add(minValueTF);
        minValueTF.setEditable(false);
        minValueTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(((JTextField) e.getComponent())
                            .getText());
                    if (input < 1) {
                        minValue = 1;
                        minValueTF.setText(Integer.toString(minValue));
                    } else
                        minValue = input;
                } catch (NumberFormatException nfe) {
                    minValue = Integer.parseInt(Gui.tempValue);
                    minValueTF.setText(Gui.tempValue);
                }
            }
        });

        // lose criteria
        goals.add(loseCriteria);
        loseCriteria.setBorder(BorderFactory
                .createTitledBorder("Lose Criteria"));
        loseCriteria.add(maxReputationLabel);
        loseCriteria.add(loseReputationCB);
        loseReputationCB.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    loseReputation = true;
                    maxReputationTF.setEditable(true);
                    warnReputationTF.setEditable(true);
                } else {
                    loseReputation = false;
                    maxReputationTF.setEditable(false);
                    warnReputationTF.setEditable(false);
                }
            }
        });
        loseCriteria.add(maxReputationTF);
        maxReputationTF.setEditable(false);
        maxReputationTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(((JTextField) e.getComponent())
                            .getText());
                    if (input < 1) {
                        maxReputation = 1;
                        maxReputationTF.setText(Integer.toString(maxReputation));
                    } else if (input > 999) {
                        maxReputation = 999;
                        maxReputationTF.setText(Integer.toString(maxReputation));
                    } else
                        maxReputation = input;
                } catch (NumberFormatException nfe) {
                    maxReputation = Integer.parseInt(Gui.tempValue);
                    maxReputationTF.setText(Gui.tempValue);
                }
                if (warnReputation < maxReputation) {
                    warnReputation = maxReputation;
                    warnReputationTF.setText(Integer.toString(maxReputation));
                }
            }
        });

        loseCriteria.add(warnReputationLabel);
        warnReputationLabel
                .setToolTipText("At which point the status graph will display the"
                        + " lose condition instead of the winning condition, as a warning to the player");
        loseCriteria.add(warnReputationTF);
        warnReputationTF.setEditable(false);
        warnReputationTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(((JTextField) e.getComponent())
                            .getText());
                    if (input < 1) {
                        warnReputation = 1;
                        warnReputationTF.setText(Integer
                                .toString(warnReputation));
                    } else if (input > 999) {
                        warnReputation = 999;
                        warnReputationTF.setText(Integer
                                .toString(warnReputation));
                    } else
                        warnReputation = input;
                } catch (NumberFormatException nfe) {
                    warnReputation = Integer.parseInt(Gui.tempValue);
                    warnReputationTF.setText(Gui.tempValue);
                }
                if (warnReputation < maxReputation) {
                    warnReputation = maxReputation;
                    warnReputationTF.setText(Integer.toString(maxReputation));
                }
            }
        });

        loseCriteria.add(maxBalanceLabel);
        loseCriteria.add(loseBalanceCB);
        loseBalanceCB.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    loseBalance = true;
                    maxBalanceTF.setEditable(true);
                    warnBalanceTF.setEditable(true);
                } else {
                    loseBalance = false;
                    maxBalanceTF.setEditable(false);
                    warnBalanceTF.setEditable(false);
                }
            }
        });
        loseCriteria.add(maxBalanceTF);
        maxBalanceTF.setEditable(false);
        maxBalanceTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(((JTextField) e.getComponent())
                            .getText());
                    maxBalance = input;
                } catch (NumberFormatException nfe) {
                    maxBalance = Integer.parseInt(Gui.tempValue);
                    maxBalanceTF.setText(Gui.tempValue);
                }
                if (warnBalance < maxBalance) {
                    warnBalance = maxBalance;
                    warnBalanceTF.setText(Integer.toString(maxBalance));
                }
            }
        });
        loseCriteria.add(warnBalanceLabel);
        warnBalanceLabel
                .setToolTipText("At which point the status graph will display the"
                        + " lose condition instead of the winning condition, as a warning to the player");
        loseCriteria.add(warnBalanceTF);
        warnBalanceTF.setEditable(false);
        warnBalanceTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(((JTextField) e.getComponent())
                            .getText());
                    warnBalance = input;
                } catch (NumberFormatException nfe) {
                    warnBalance = Integer.parseInt(Gui.tempValue);
                    warnBalanceTF.setText(Gui.tempValue);
                }
                if (warnBalance < maxBalance) {
                    warnBalance = maxBalance;
                    warnBalanceTF.setText(Integer.toString(maxBalance));
                }
            }
        });

        loseCriteria.add(minPercentageKilledLabel);
        loseCriteria.add(losePercentageKilledCB);
        losePercentageKilledCB.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    losePercentageKilled = true;
                    minPercentageKilledTF.setEditable(true);
                    warnPercentageKilledTF.setEditable(true);
                } else {
                    losePercentageKilled = false;
                    minPercentageKilledTF.setEditable(false);
                    warnPercentageKilledTF.setEditable(false);
                }
            }
        });
        loseCriteria.add(minPercentageKilledTF);
        minPercentageKilledTF.setEditable(false);
        minPercentageKilledTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(((JTextField) e.getComponent())
                            .getText());
                    if (input < 1) {
                        minPercentageKilled = 1;
                        minPercentageKilledTF.setText(Integer
                                .toString(minPercentageKilled));
                    } else if (input > 100) {
                        minPercentageKilled = 100;
                        minPercentageKilledTF.setText(Integer
                                .toString(minPercentageKilled));
                    } else
                        minPercentageKilled = input;
                } catch (NumberFormatException nfe) {
                    minPercentageKilled = Integer.parseInt(Gui.tempValue);
                    minPercentageKilledTF.setText(Gui.tempValue);
                }
                if (warnPercentageKilled > minPercentageKilled) {
                    warnPercentageKilled = minPercentageKilled;
                    warnPercentageKilledTF.setText(Integer
                            .toString(minPercentageKilled));
                }
            }
        });
        loseCriteria.add(warnPercentageKilledLabel);
        warnPercentageKilledLabel
                .setToolTipText("At which point the status graph will display the"
                        + " lose condition instead of the winning condition, as a warning to the player");
        loseCriteria.add(warnPercentageKilledTF);
        warnPercentageKilledTF.setEditable(false);
        warnPercentageKilledTF.addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                JTextField tf = (JTextField) e.getComponent();
                tf.selectAll();
                Gui.tempValue = tf.getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(((JTextField) e.getComponent())
                            .getText());
                    if (input < 1) {
                        warnPercentageKilled = 1;
                        warnPercentageKilledTF.setText(Integer
                                .toString(warnPercentageKilled));
                    } else if (input > 100) {
                        warnPercentageKilled = 100;
                        warnPercentageKilledTF.setText(Integer
                                .toString(warnPercentageKilled));
                    } else
                        warnPercentageKilled = input;
                } catch (NumberFormatException nfe) {
                    warnPercentageKilled = Integer.parseInt(Gui.tempValue);
                    warnPercentageKilledTF.setText(Gui.tempValue);
                }
                if (warnPercentageKilled > minPercentageKilled) {
                    warnPercentageKilled = minPercentageKilled;
                    warnPercentageKilledTF.setText(Integer
                            .toString(minPercentageKilled));
                }
            }
        });
    }
}
