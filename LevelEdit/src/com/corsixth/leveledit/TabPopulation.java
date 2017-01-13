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

import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextField;

public class TabPopulation extends JScrollPane {

    private static final long serialVersionUID = -7707325095353711104L;

    // variables
    static ArrayList<Population> populationList = new ArrayList<Population>();

    // components
    static GridPanel populations = new GridPanel(1);

    JPanel buttonsPanel = new JPanel();
    JButton addButt = new JButton("Add");
    JButton removeButt = new JButton("Remove");
    static JLabel overflowWarning = new JLabel();

    public TabPopulation() {
        // set scroll speed
        getVerticalScrollBar().setUnitIncrement(20);
        getHorizontalScrollBar().setUnitIncrement(20);

        populations.setInsets(0);
        setViewportView(populations);
        // population panel
        populations.add(buttonsPanel);

        buttonsPanel.add(addButt);
        addButt.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                addPopulation();
            }
        });

        buttonsPanel.add(removeButt);
        removeButt.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                removePopulation();
            }
        });

    }

    public static void addPopulation() {
        populations.remove(overflowWarning);
        final Population population = new Population();
        populationList.add(population);

        // get the index of this particular arraylist member
        final int index = (populationList.indexOf(population));

        // add month
        populationList.get(index).populationPanel
                .add(populationList.get(index).monthLabel);
        populationList.get(index).monthLabel
                .setToolTipText("The new population will apply starting from this month.");
        populationList.get(index).populationPanel
                .add(populationList.get(index).monthTF);
        populationList.get(index).monthTF.addFocusListener(new FocusListener() {
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
                        populationList.get(index).month = Integer
                                .parseInt(Gui.tempValue);
                        populationList.get(index).monthTF
                                .setText(Gui.tempValue);
                    } else
                        populationList.get(index).month = input;
                } catch (NumberFormatException nfe) {
                    populationList.get(index).month = Integer
                            .parseInt(Gui.tempValue);
                    populationList.get(index).monthTF.setText(Gui.tempValue);
                }
                // make sure that there are no duplicate month entries
                // and all entries are in chronological order.
                for (int i = 0; i < populationList.size(); i++) {
                    for (int ii = index; i < ii; i++) {
                        if (populationList.get(i).month >= populationList
                                .get(ii).month) {
                            populationList.get(ii).month = populationList
                                    .get(i).month + 1;
                            populationList.get(ii).monthTF.setText(Integer
                                    .toString(populationList.get(ii).month));
                        }
                    }
                    for (int ii = index; i > ii; ii++) {
                        if (populationList.get(i).month <= populationList
                                .get(ii).month) {
                            populationList.get(i).month = populationList
                                    .get(ii).month + 1;
                            populationList.get(i).monthTF.setText(Integer
                                    .toString(populationList.get(i).month));
                        }
                    }
                }

                calculateNumberOfPatients();
            }
        });

        // add change
        populationList.get(index).populationPanel
                .add(populationList.get(index).changeLabel);
        populationList.get(index).changeLabel
                .setToolTipText("Each month, increase/decrease number of patients by this amount");
        populationList.get(index).populationPanel
                .add(populationList.get(index).changeTF);
        populationList.get(index).changeTF
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
                            populationList.get(index).change = input;
                        } catch (NumberFormatException nfe) {
                            populationList.get(index).change = Integer
                                    .parseInt(Gui.tempValue);
                            populationList.get(index).changeTF
                                    .setText(Gui.tempValue);
                        }
                        calculateNumberOfPatients();
                    }
                });

        // add number of patients
        if (populationList.size() > 1) {
            populationList.get(index).populationPanel.add(populationList
                    .get(index).spawnLabel);
            populationList.get(index).spawnLabel
                    .setToolTipText("Number of patients that will arrive in this month. This number is then divided among competing hospitals");
        }

        populations.add(populationList.get(index).populationPanel);
        populations.updateUI();

        // set default for the first population
        if (populationList.size() == 1) {
            populationList.get(index).change = 4;
            populationList.get(index).changeTF.setText("4");
        }

        // increase month with each new add
        if (populationList.size() > 1) {
            int lastMonth = populationList.get(index - 1).month;
            int month = lastMonth + 1;
            populationList.get(index).month = month;
            populationList.get(index).monthTF.setText(Integer.toString(month));
        }

        calculateNumberOfPatients();
    }

    public static void removePopulation() {
        populations.remove(overflowWarning);
        int lastIndex = populationList.size() - 1;
        if (lastIndex >= 0) {
            // remove panel
            populations.remove(populationList.get(lastIndex).populationPanel);
            populations.updateUI();
            // remove object from the arraylist
            populationList.remove(lastIndex);
        }
        calculateNumberOfPatients();
    }

    public static void calculateNumberOfPatients() {
        for (int i = 1; i < populationList.size(); i++) {
            int monthsDifference = (populationList.get(i).month)
                    - (populationList.get(i - 1).month);
            int lastChange = populationList.get(i - 1).change;
            int lastSpawn = populationList.get(i - 1).spawn;

            int spawn = lastSpawn + lastChange * monthsDifference;
            populationList.get(i).spawn = spawn;
            populationList.get(i).spawnLabel.setText("Number of patients: "
                    + Integer.toString(spawn));
        }
        // give a warning if the last change is not 0.
        int size = populationList.size();
        if (size > 0) {
            if (populationList.get(populationList.size() - 1).change > 0) {
                populations.add(overflowWarning);
                overflowWarning
                        .setText("Warning: patient count will increase infinitely after month "
                                + populationList.get(size - 1).month + "!");
            } else if (populationList.get(populationList.size() - 1).change < 0) {
                populations.add(overflowWarning);
                overflowWarning
                        .setText("Warning: patient count will decrease infinitely after month "
                                + populationList.get(size - 1).month + "!");
            }
        } else {
            populations.add(overflowWarning);
            overflowWarning
                    .setText("Warning: You need to define at least one month to get any patients!");
        }
        populations.updateUI();
    }
}
