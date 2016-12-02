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

public class TabEarthquakes extends JScrollPane {

    private static final long serialVersionUID = -5841183676154086892L;

    // variables
    static ArrayList<Quake> quakeList = new ArrayList<Quake>();

    // components
    static GridPanel earthquakes = new GridPanel(1);

    JPanel buttonsPanel = new JPanel();
    JButton addButt = new JButton("Add");
    JButton removeButt = new JButton("Remove");

    static JLabel randomQuakesLabel = new JLabel(
            "Random earthquakes are enabled.");

    public TabEarthquakes() {
        // set scroll speed
        getVerticalScrollBar().setUnitIncrement(20);
        getHorizontalScrollBar().setUnitIncrement(20);
        
        setViewportView(earthquakes);
        earthquakes.setInsets(0);
        // earthquakes panel
        earthquakes.add(buttonsPanel);
        earthquakes.add(randomQuakesLabel);
        buttonsPanel.add(addButt);
        addButt.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                addQuake();
            }
        });
        buttonsPanel.add(removeButt);
        removeButt.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                removeQuake();
            }
        });
    }

    protected static void addQuake() {
        earthquakes.remove(randomQuakesLabel);

        final Quake quake = new Quake();
        quakeList.add(quake);

        // get the index of this particular arraylist member
        final int index = (quakeList.indexOf(quake));

        quakeList.get(index).quakePanel.add(new JLabel("Start month:"));
        quakeList.get(index).quakePanel.add(quakeList.get(index).startMonthTF);
        quakeList.get(index).startMonthTF.addFocusListener(new FocusListener() {
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
                        quakeList.get(index).startMonth = Integer
                                .parseInt(Gui.tempValue);
                        quakeList.get(index).startMonthTF
                                .setText(Gui.tempValue);
                    } else
                        quakeList.get(index).startMonth = input;
                } catch (NumberFormatException nfe) {
                    quakeList.get(index).startMonth = Integer
                            .parseInt(Gui.tempValue);
                    quakeList.get(index).startMonthTF.setText(Gui.tempValue);
                }
                // if start month is bigger than endmonth, make them equal.
                if (quakeList.get(index).startMonth > quakeList.get(index).endMonth) {
                    quakeList.get(index).endMonth = quakeList.get(index).startMonth;
                    quakeList.get(index).endMonthTF.setText(quakeList
                            .get(index).startMonthTF.getText());
                }
            }
        });
        quakeList.get(index).quakePanel.add(new JLabel("End month:"));
        quakeList.get(index).quakePanel.add(quakeList.get(index).endMonthTF);
        quakeList.get(index).endMonthTF.addFocusListener(new FocusListener() {
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
                        quakeList.get(index).endMonth = Integer
                                .parseInt(Gui.tempValue);
                        quakeList.get(index).endMonthTF.setText(Gui.tempValue);
                    } else
                        quakeList.get(index).endMonth = input;
                } catch (NumberFormatException nfe) {
                    quakeList.get(index).endMonth = Integer
                            .parseInt(Gui.tempValue);
                    quakeList.get(index).endMonthTF.setText(Gui.tempValue);

                }
                // if start month is bigger than endmonth, make them equal.
                if (quakeList.get(index).startMonth > quakeList.get(index).endMonth) {
                    quakeList.get(index).endMonth = quakeList.get(index).startMonth;
                    quakeList.get(index).endMonthTF.setText(quakeList
                            .get(index).startMonthTF.getText());
                }
            }
        });
        quakeList.get(index).quakePanel.add(new JLabel("Severity:"));
        quakeList.get(index).quakePanel.add(quakeList.get(index).severityTF);
        quakeList.get(index).severityTF.addFocusListener(new FocusListener() {
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
                        quakeList.get(index).severity = 1;
                        quakeList.get(index).severityTF.setText(Integer
                                .toString(quakeList.get(index).severity));
                    } else if (input > 99) {
                        quakeList.get(index).severity = 99;
                        quakeList.get(index).severityTF.setText(Integer
                                .toString(quakeList.get(index).severity));
                    } else
                        quakeList.get(index).severity = input;
                } catch (NumberFormatException nfe) {
                    quakeList.get(index).severity = Integer
                            .parseInt(Gui.tempValue);
                    quakeList.get(index).severityTF.setText(Gui.tempValue);
                }
            }
        });

        earthquakes.add(quakeList.get(index).quakePanel);
        earthquakes.updateUI();

        // increment startMonth, endMonth with each add
        if (quakeList.size() > 1) {
            quakeList.get(index).startMonth = quakeList.get(index - 1).endMonth + 6;
            int endMonthPlus = Integer
                    .parseInt(quakeList.get(index - 1).endMonthTF.getText()) + 6;
            quakeList.get(index).startMonthTF.setText(Integer
                    .toString(endMonthPlus));

            quakeList.get(index).endMonth = quakeList.get(index).startMonth + 12;
            int startMonthPlus = Integer
                    .parseInt(quakeList.get(index).startMonthTF.getText()) + 12;
            quakeList.get(index).endMonthTF.setText(Integer
                    .toString(startMonthPlus));
        }

    }

    protected static void removeQuake() {
        int lastIndex = quakeList.size() - 1;
        if (lastIndex >= 0) {
            // remove panel
            earthquakes.remove(quakeList.get(lastIndex).quakePanel);
            earthquakes.updateUI();
            // remove object from the arraylist
            quakeList.remove(lastIndex);
            if (quakeList.isEmpty())
                earthquakes.add(randomQuakesLabel);
        }

    }
}
