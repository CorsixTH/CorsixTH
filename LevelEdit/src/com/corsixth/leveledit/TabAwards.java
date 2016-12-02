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
import javax.swing.JTextField;

public class TabAwards extends JScrollPane {

    private static final long serialVersionUID = -244055170654039024L;

    // variables
    static final int CANS_OF_COKE = 100;
    static final int CANS_OF_COKE_BONUS = 1000;
    static final int REPUTATION = 400;
    static final int REPUTATION_BONUS = 2000;
    static final int NO_DEATHS_BONUS = 10000;

    static int cansOfCoke = CANS_OF_COKE;
    static int cansOfCokeBonus = CANS_OF_COKE_BONUS;
    static int reputation = REPUTATION;
    static int reputationBonus = REPUTATION_BONUS;
    static int noDeathsBonus = NO_DEATHS_BONUS;

    // components
    GridPanel awards = new GridPanel(4);

    static JLabel cansOfCokeLabel = new JLabel("Cans of coke:");
    static JLabel cansOfCokeBonusLabel = new JLabel("Cans of coke bonus:");
    static JLabel reputationLabel = new JLabel("Reputation:");
    static JLabel reputationBonusLabel = new JLabel("Reputation bonus:");
    static JLabel noDeathsBonusLabel = new JLabel("No deaths bonus:");

    static JTextField cansOfCokeTF = new JTextField(
            Integer.toString(cansOfCoke), 5);
    static JTextField cansOfCokeBonusTF = new JTextField(
            Integer.toString(cansOfCokeBonus), 5);
    static JTextField reputationTF = new JTextField(
            Integer.toString(reputation), 5);
    static JTextField reputationBonusTF = new JTextField(
            Integer.toString(reputationBonus), 5);
    static JTextField noDeathsBonusTF = new JTextField(
            Integer.toString(noDeathsBonus), 5);

    public TabAwards() {

        // set scroll speed
        getVerticalScrollBar().setUnitIncrement(20);
        getHorizontalScrollBar().setUnitIncrement(20);

        setViewportView(awards);

        // cans of coke
        awards.add(cansOfCokeLabel);
        cansOfCokeLabel
                .setToolTipText("Sell more than this number of cans to win the award");
        awards.add(cansOfCokeTF);
        cansOfCokeTF.addFocusListener(new FocusListener() {
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
                        cansOfCoke = 1;
                        cansOfCokeTF.setText(Integer.toString(cansOfCoke));
                    } else
                        cansOfCoke = input;
                } catch (NumberFormatException nfe) {
                    cansOfCoke = Integer.parseInt(Gui.tempValue);
                    cansOfCokeTF.setText(Gui.tempValue);
                }
            }
        });

        awards.add(cansOfCokeBonusLabel);
        cansOfCokeBonusLabel.setToolTipText("Cash bonus for this award");
        awards.add(cansOfCokeBonusTF);
        cansOfCokeBonusTF.addFocusListener(new FocusListener() {
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
                        cansOfCokeBonus = 1;
                        cansOfCokeBonusTF.setText(Integer
                                .toString(cansOfCokeBonus));
                    } else
                        cansOfCokeBonus = input;
                } catch (NumberFormatException nfe) {
                    cansOfCokeBonus = Integer.parseInt(Gui.tempValue);
                    cansOfCokeBonusTF.setText(Gui.tempValue);
                }
            }
        });

        // reputation
        awards.add(reputationLabel);
        reputationLabel
                .setToolTipText("Reputation that is needed through the whole year to win the award");
        awards.add(reputationTF);
        reputationTF.addFocusListener(new FocusListener() {
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
                        reputation = 1;
                        reputationTF.setText(Integer.toString(reputation));
                    } else if (input > 999) {
                        reputation = 999;
                        reputationTF.setText(Integer.toString(reputation));
                    } else
                        reputation = input;
                } catch (NumberFormatException nfe) {
                    reputation = Integer.parseInt(Gui.tempValue);
                    reputationTF.setText(Gui.tempValue);
                }
            }
        });
        awards.add(reputationBonusLabel);
        reputationBonusLabel.setToolTipText("Cash bonus for this award");
        awards.add(reputationBonusTF);
        reputationBonusTF.addFocusListener(new FocusListener() {
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
                        reputationBonus = 1;
                        reputationBonusTF.setText(Integer
                                .toString(reputationBonus));
                    } else
                        reputationBonus = input;
                } catch (NumberFormatException nfe) {
                    reputationBonus = Integer.parseInt(Gui.tempValue);
                    reputationBonusTF.setText(Gui.tempValue);
                }
            }
        });

        // no deaths
        awards.add(noDeathsBonusLabel);
        noDeathsBonusLabel
                .setToolTipText("Cash bonus for killing no patients the whole year");
        awards.add(noDeathsBonusTF);
        noDeathsBonusTF.addFocusListener(new FocusListener() {
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
                        noDeathsBonus = 1;
                        noDeathsBonusTF.setText(Integer.toString(noDeathsBonus));
                    } else
                        noDeathsBonus = input;
                } catch (NumberFormatException nfe) {
                    noDeathsBonus = Integer.parseInt(Gui.tempValue);
                    noDeathsBonusTF.setText(Gui.tempValue);
                }
            }
        });
    }
}
