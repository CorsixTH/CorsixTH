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
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;

import javax.swing.JCheckBox;
import javax.swing.JLabel;
import javax.swing.JScrollPane;
import javax.swing.JTextField;

public class TabObjects extends JScrollPane {

    private static final long serialVersionUID = 1176963244482675840L;
    // variables
    static int[] objectsAvail = new int[62]; // index [0] is never used.
    static int[] objectsStartAvail = new int[62];
    static int[] objectsStrength = new int[62];
    static int[] objectsResearch = new int[62];

    // components
    GridPanel objects = new GridPanel(5); // Row gaps
    JScrollPane scrollPane = new JScrollPane(objects);

    JLabel availableLabel = new JLabel("Available");
    JLabel startLabel = new JLabel("From start");
    JLabel strengthLabel = new JLabel("Strength");
    JLabel researchLabel = new JLabel("Research");
    JCheckBox checkAllAvailableCB = new JCheckBox();
    JCheckBox checkAllStartCB = new JCheckBox();
    static JCheckBox[] objectsAvailCB = new JCheckBox[62];
    static JCheckBox[] objectsStartAvailCB = new JCheckBox[62];
    // static JTextField[] objectsCostTF = new JTextField[62];
    static JTextField[] objectsStrengthTF = new JTextField[62];
    static JTextField[] objectsResearchTF = new JTextField[62];

    // JLabel costLabel = new JLabel("cost");

    public TabObjects() {
        // set scroll speed
        getVerticalScrollBar().setUnitIncrement(20);
        getHorizontalScrollBar().setUnitIncrement(20);

        setViewportView(objects);
        objects.setInsets(2, 7, 2, 7);
        // initializing members of checkbox and textfield arrays, else they will
        // be null.
        for (int i = 0; i < objectsAvailCB.length; i++)
            objectsAvailCB[i] = new JCheckBox();
        for (int i = 0; i < objectsStartAvailCB.length; i++)
            objectsStartAvailCB[i] = new JCheckBox();
        for (int i = 0; i < objectsStrengthTF.length; i++)
            objectsStrengthTF[i] = new JTextField(2);
        for (int i = 0; i < objectsResearchTF.length; i++)
            objectsResearchTF[i] = new JTextField(5);
        // for (int i=0; i<objectsCostTF.length; i++)
        // objectsCostTF[i] = new JTextField(5);

        // column headings
        objects.add(new JLabel("Check all"));
        objects.add(checkAllAvailableCB);
        checkAllAvailableCB.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    objectsAvailCB[8].setSelected(true);
                    objectsAvailCB[20].setSelected(true);
                    objectsAvailCB[18].setSelected(true);
                    objectsAvailCB[22].setSelected(true);
                    objectsAvailCB[39].setSelected(true);
                    objectsAvailCB[9].setSelected(true);
                    objectsAvailCB[13].setSelected(true);
                    objectsAvailCB[47].setSelected(true);
                    objectsAvailCB[26].setSelected(true);
                    objectsAvailCB[27].setSelected(true);
                    objectsAvailCB[30].setSelected(true);
                    objectsAvailCB[23].setSelected(true);
                    objectsAvailCB[24].setSelected(true);
                    objectsAvailCB[14].setSelected(true);
                    objectsAvailCB[25].setSelected(true);
                    objectsAvailCB[41].setSelected(true);
                    objectsAvailCB[42].setSelected(true);
                    objectsAvailCB[54].setSelected(true);
                    objectsAvailCB[46].setSelected(true);
                    objectsAvailCB[40].setSelected(true);
                    objectsAvailCB[37].setSelected(true);
                    objectsAvailCB[57].setSelected(true);
                } else {
                    objectsAvailCB[8].setSelected(false);
                    objectsAvailCB[20].setSelected(false);
                    objectsAvailCB[18].setSelected(false);
                    objectsAvailCB[22].setSelected(false);
                    objectsAvailCB[39].setSelected(false);
                    objectsAvailCB[9].setSelected(false);
                    objectsAvailCB[13].setSelected(false);
                    objectsAvailCB[47].setSelected(false);
                    objectsAvailCB[26].setSelected(false);
                    objectsAvailCB[27].setSelected(false);
                    objectsAvailCB[30].setSelected(false);
                    objectsAvailCB[23].setSelected(false);
                    objectsAvailCB[24].setSelected(false);
                    objectsAvailCB[14].setSelected(false);
                    objectsAvailCB[25].setSelected(false);
                    objectsAvailCB[41].setSelected(false);
                    objectsAvailCB[42].setSelected(false);
                    objectsAvailCB[54].setSelected(false);
                    objectsAvailCB[40].setSelected(false);
                    objectsAvailCB[46].setSelected(false);
                    objectsAvailCB[37].setSelected(false);
                    objectsAvailCB[57].setSelected(false);
                }
            }
        });
        objects.add(checkAllStartCB);
        checkAllStartCB.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED) {
                    objectsStartAvailCB[8].setSelected(true);
                    objectsStartAvailCB[20].setSelected(true);
                    objectsStartAvailCB[18].setSelected(true);
                    objectsStartAvailCB[22].setSelected(true);
                    objectsStartAvailCB[39].setSelected(true);
                    objectsStartAvailCB[9].setSelected(true);
                    objectsStartAvailCB[13].setSelected(true);
                    objectsStartAvailCB[47].setSelected(true);
                    objectsStartAvailCB[26].setSelected(true);
                    objectsStartAvailCB[27].setSelected(true);
                    objectsStartAvailCB[30].setSelected(true);
                    objectsStartAvailCB[23].setSelected(true);
                    objectsStartAvailCB[24].setSelected(true);
                    objectsStartAvailCB[14].setSelected(true);
                    objectsStartAvailCB[25].setSelected(true);
                    objectsStartAvailCB[41].setSelected(true);
                    objectsStartAvailCB[42].setSelected(true);
                    objectsStartAvailCB[54].setSelected(true);
                    objectsStartAvailCB[46].setSelected(true);
                    objectsStartAvailCB[40].setSelected(true);
                } else {
                    objectsStartAvailCB[8].setSelected(false);
                    objectsStartAvailCB[20].setSelected(false);
                    objectsStartAvailCB[18].setSelected(false);
                    objectsStartAvailCB[22].setSelected(false);
                    objectsStartAvailCB[39].setSelected(false);
                    objectsStartAvailCB[9].setSelected(false);
                    objectsStartAvailCB[13].setSelected(false);
                    objectsStartAvailCB[47].setSelected(false);
                    objectsStartAvailCB[26].setSelected(false);
                    objectsStartAvailCB[27].setSelected(false);
                    objectsStartAvailCB[30].setSelected(false);
                    objectsStartAvailCB[23].setSelected(false);
                    objectsStartAvailCB[24].setSelected(false);
                    objectsStartAvailCB[14].setSelected(false);
                    objectsStartAvailCB[25].setSelected(false);
                    objectsStartAvailCB[41].setSelected(false);
                    objectsStartAvailCB[42].setSelected(false);
                    objectsStartAvailCB[54].setSelected(false);
                    objectsStartAvailCB[46].setSelected(false);
                    objectsStartAvailCB[40].setSelected(false);
                }
            }
        });
        objects.next(3);
        objects.add(availableLabel);
        availableLabel
                .setToolTipText("Whether the object should appear at all in this level");

        objects.add(startLabel);
        startLabel
                .setToolTipText("Whether the object should be available from the start of the level");

        // objects.add(costLabel);
        // costLabel.setToolTipText("The starting cost. Research will also lower the cost.");

        objects.add(researchLabel);
        researchLabel
                .setToolTipText("How much research is required to discover the object");

        objects.add(strengthLabel);
        strengthLabel
                .setToolTipText("The starting strength of a machine. "
                        + "High strength makes the machine less vulnerable to earthquakes and overuse.");

        // starting rooms
        objects.add(new JLabel("Ward"));
        objects.add(objectsAvailCB[8]);
        objects.add(objectsStartAvailCB[8]);
        objects.add(objectsResearchTF[8]);
        objects.next();
        objectsAvailCB[8].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[8] = 1;
                else
                    objectsAvail[8] = 0;
            }
        });
        objectsStartAvailCB[8].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[8] = 1;
                else
                    objectsStartAvail[8] = 0;
            }
        });
        objectsResearchTF[8].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[8].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[8].getText());
                    if (input < 1) {
                        objectsResearch[8] = 1;
                        objectsResearchTF[8].setText(Integer
                                .toString(objectsResearch[8]));
                    } else
                        objectsResearch[8] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[8] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[8].setText(Integer
                            .toString(objectsResearch[8]));
                }
            }
        });

        objects.add(new JLabel("Standard Diagnosis"));
        objects.add(objectsAvailCB[20]);
        objects.add(objectsStartAvailCB[20]);
        objects.add(objectsResearchTF[20]);
        objects.next();
        objectsAvailCB[20].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[20] = 1;
                else
                    objectsAvail[20] = 0;
            }
        });
        objectsStartAvailCB[20].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[20] = 1;
                else
                    objectsStartAvail[20] = 0;
            }
        });
        objectsResearchTF[20].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[20].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[20]
                            .getText());
                    if (input < 1) {
                        objectsResearch[20] = 1;
                        objectsResearchTF[20].setText(Integer
                                .toString(objectsResearch[20]));
                    } else
                        objectsResearch[20] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[20] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[20].setText(Integer
                            .toString(objectsResearch[20]));
                }
            }
        });

        objects.add(new JLabel("Psychiatry"));
        objects.add(objectsAvailCB[18]);
        objects.add(objectsStartAvailCB[18]);
        objects.add(objectsResearchTF[18]);
        objects.next();
        objectsAvailCB[18].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[18] = 1;
                else
                    objectsAvail[18] = 0;
            }
        });
        objectsStartAvailCB[18].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[18] = 1;
                else
                    objectsStartAvail[18] = 0;
            }
        });
        objectsResearchTF[18].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[18].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[18]
                            .getText());
                    if (input < 1) {
                        objectsResearch[18] = 1;
                        objectsResearchTF[18].setText(Integer
                                .toString(objectsResearch[18]));
                    } else
                        objectsResearch[18] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[18] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[18].setText(Integer
                            .toString(objectsResearch[18]));
                }
            }
        });

        objects.add(new JLabel("Pharmacy"));
        objects.add(objectsAvailCB[39]);
        objects.add(objectsStartAvailCB[39]);
        objects.add(objectsResearchTF[39]);
        objects.next();
        objectsAvailCB[39].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[39] = 1;
                else
                    objectsAvail[39] = 0;
            }
        });
        objectsStartAvailCB[39].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[39] = 1;
                else
                    objectsStartAvail[39] = 0;
            }
        });
        objectsResearchTF[39].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[39].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[39]
                            .getText());
                    if (input < 1) {
                        objectsResearch[39] = 1;
                        objectsResearchTF[39].setText(Integer
                                .toString(objectsResearch[39]));
                    } else
                        objectsResearch[39] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[39] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[39].setText(Integer
                            .toString(objectsResearch[39]));
                }
            }
        });

        // machines
        objects.add(new JLabel("Inflator Machine"));
        objects.add(objectsAvailCB[9]);
        objects.add(objectsStartAvailCB[9]);
        objects.add(objectsResearchTF[9]);
        objects.add(objectsStrengthTF[9]);
        objectsAvailCB[9].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[9] = 1;
                else
                    objectsAvail[9] = 0;
            }
        });
        objectsStartAvailCB[9].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[9] = 1;
                else
                    objectsStartAvail[9] = 0;
            }
        });
        objectsResearchTF[9].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[9].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[9].getText());
                    if (input < 1) {
                        objectsResearch[9] = 1;
                        objectsResearchTF[9].setText(Integer
                                .toString(objectsResearch[9]));
                    } else
                        objectsResearch[9] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[9] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[9].setText(Integer
                            .toString(objectsResearch[9]));
                }
            }
        });
        objectsStrengthTF[9].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[9].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[9].getText());
                    if (input < 1) {
                        objectsStrength[9] = 1;
                        objectsStrengthTF[9].setText(Integer
                                .toString(objectsStrength[9]));
                    } else if (input > 99) {
                        objectsStrength[9] = 99;
                        objectsStrengthTF[9].setText(Integer
                                .toString(objectsStrength[9]));
                    } else
                        objectsStrength[9] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[9] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[9].setText(Integer
                            .toString(objectsStrength[9]));
                }
            }
        });

        objects.add(new JLabel("Cardiogram"));
        objects.add(objectsAvailCB[13]);
        objects.add(objectsStartAvailCB[13]);
        objects.add(objectsResearchTF[13]);
        objects.add(objectsStrengthTF[13]);
        objectsAvailCB[13].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[13] = 1;
                else
                    objectsAvail[13] = 0;
            }
        });
        objectsStartAvailCB[13].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[13] = 1;
                else
                    objectsStartAvail[13] = 0;
            }
        });
        objectsResearchTF[13].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[13].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[13]
                            .getText());
                    if (input < 1) {
                        objectsResearch[13] = 1;
                        objectsResearchTF[13].setText(Integer
                                .toString(objectsResearch[13]));
                    } else
                        objectsResearch[13] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[13] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[13].setText(Integer
                            .toString(objectsResearch[13]));
                }
            }
        });
        objectsStrengthTF[13].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[13].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[13]
                            .getText());
                    if (input < 1) {
                        objectsStrength[13] = 1;
                        objectsStrengthTF[13].setText(Integer
                                .toString(objectsStrength[13]));
                    } else if (input > 99) {
                        objectsStrength[13] = 99;
                        objectsStrengthTF[13].setText(Integer
                                .toString(objectsStrength[13]));
                    } else
                        objectsStrength[13] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[13] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[13].setText(Integer
                            .toString(objectsStrength[13]));
                }
            }
        });

        objects.add(new JLabel("Slack Tongue Slicer"));
        objects.add(objectsAvailCB[26]);
        objects.add(objectsStartAvailCB[26]);
        objects.add(objectsResearchTF[26]);
        objects.add(objectsStrengthTF[26]);
        objectsAvailCB[26].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[26] = 1;
                else
                    objectsAvail[26] = 0;
            }
        });
        objectsStartAvailCB[26].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[26] = 1;
                else
                    objectsStartAvail[26] = 0;
            }
        });
        objectsResearchTF[26].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[26].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[26]
                            .getText());
                    if (input < 1) {
                        objectsResearch[26] = 1;
                        objectsResearchTF[26].setText(Integer
                                .toString(objectsResearch[26]));
                    } else
                        objectsResearch[26] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[26] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[26].setText(Integer
                            .toString(objectsResearch[26]));
                }
            }
        });
        objectsStrengthTF[26].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[26].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[26]
                            .getText());
                    if (input < 1) {
                        objectsStrength[26] = 1;
                        objectsStrengthTF[26].setText(Integer
                                .toString(objectsStrength[26]));
                    } else if (input > 99) {
                        objectsStrength[26] = 99;
                        objectsStrengthTF[26].setText(Integer
                                .toString(objectsStrength[26]));
                    } else
                        objectsStrength[26] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[26] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[26].setText(Integer
                            .toString(objectsStrength[26]));
                }
            }
        });

        objects.add(new JLabel("X-Ray"));
        objects.add(objectsAvailCB[27]);
        objects.add(objectsStartAvailCB[27]);
        objects.add(objectsResearchTF[27]);
        objects.add(objectsStrengthTF[27]);
        objectsAvailCB[27].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[27] = 1;
                else
                    objectsAvail[27] = 0;
            }
        });
        objectsStartAvailCB[27].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[27] = 1;
                else
                    objectsStartAvail[27] = 0;
            }
        });
        objectsResearchTF[27].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[27].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[27]
                            .getText());
                    if (input < 1) {
                        objectsResearch[27] = 1;
                        objectsResearchTF[27].setText(Integer
                                .toString(objectsResearch[27]));
                    } else
                        objectsResearch[27] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[27] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[27].setText(Integer
                            .toString(objectsResearch[27]));
                }
            }
        });
        objectsStrengthTF[27].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[27].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[27]
                            .getText());
                    if (input < 1) {
                        objectsStrength[27] = 1;
                        objectsStrengthTF[27].setText(Integer
                                .toString(objectsStrength[27]));
                    } else if (input > 99) {
                        objectsStrength[27] = 99;
                        objectsStrengthTF[27].setText(Integer
                                .toString(objectsStrength[27]));
                    } else
                        objectsStrength[27] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[27] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[27].setText(Integer
                            .toString(objectsStrength[27]));
                }
            }
        });

        objects.add(new JLabel("Operating Table"));
        objects.add(objectsAvailCB[30]);
        objects.add(objectsStartAvailCB[30]);
        objects.add(objectsResearchTF[30]);
        objects.add(objectsStrengthTF[30]);
        objectsAvailCB[30].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[30] = 1;
                else
                    objectsAvail[30] = 0;
            }
        });
        objectsStartAvailCB[30].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[30] = 1;
                else
                    objectsStartAvail[30] = 0;
            }
        });
        objectsResearchTF[30].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[30].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[30]
                            .getText());
                    if (input < 1) {
                        objectsResearch[30] = 1;
                        objectsResearchTF[30].setText(Integer
                                .toString(objectsResearch[30]));
                    } else
                        objectsResearch[30] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[30] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[30].setText(Integer
                            .toString(objectsResearch[30]));
                }
            }
        });
        objectsStrengthTF[30].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[30].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[30]
                            .getText());
                    if (input < 1) {
                        objectsStrength[30] = 1;
                        objectsStrengthTF[30].setText(Integer
                                .toString(objectsStrength[30]));
                    } else if (input > 99) {
                        objectsStrength[30] = 99;
                        objectsStrengthTF[30].setText(Integer
                                .toString(objectsStrength[30]));
                    } else
                        objectsStrength[30] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[30] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[30].setText(Integer
                            .toString(objectsStrength[30]));
                }
            }
        });

        objects.add(new JLabel("Cast Remover"));
        objects.add(objectsAvailCB[24]);
        objects.add(objectsStartAvailCB[24]);
        objects.add(objectsResearchTF[24]);
        objects.add(objectsStrengthTF[24]);
        objectsAvailCB[24].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[24] = 1;
                else
                    objectsAvail[24] = 0;
            }
        });
        objectsStartAvailCB[24].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[24] = 1;
                else
                    objectsStartAvail[24] = 0;
            }
        });
        objectsResearchTF[24].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[24].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[24]
                            .getText());
                    if (input < 1) {
                        objectsResearch[24] = 1;
                        objectsResearchTF[24].setText(Integer
                                .toString(objectsResearch[24]));
                    } else
                        objectsResearch[24] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[24] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[24].setText(Integer
                            .toString(objectsResearch[24]));
                }
            }
        });
        objectsStrengthTF[24].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[24].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[24]
                            .getText());
                    if (input < 1) {
                        objectsStrength[24] = 1;
                        objectsStrengthTF[24].setText(Integer
                                .toString(objectsStrength[24]));
                    } else if (input > 99) {
                        objectsStrength[24] = 99;
                        objectsStrengthTF[24].setText(Integer
                                .toString(objectsStrength[24]));
                    } else
                        objectsStrength[24] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[24] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[24].setText(Integer
                            .toString(objectsStrength[24]));
                }
            }
        });

        objects.add(new JLabel("Scanner"));
        objects.add(objectsAvailCB[14]);
        objects.add(objectsStartAvailCB[14]);
        objects.add(objectsResearchTF[14]);
        objects.add(objectsStrengthTF[14]);
        objectsAvailCB[14].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[14] = 1;
                else
                    objectsAvail[14] = 0;
            }
        });
        objectsStartAvailCB[14].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[14] = 1;
                else
                    objectsStartAvail[14] = 0;
            }
        });
        objectsResearchTF[14].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[14].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[14]
                            .getText());
                    if (input < 1) {
                        objectsResearch[14] = 1;
                        objectsResearchTF[14].setText(Integer
                                .toString(objectsResearch[14]));
                    } else
                        objectsResearch[14] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[14] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[14].setText(Integer
                            .toString(objectsResearch[14]));
                }
            }
        });
        objectsStrengthTF[14].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[14].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[14]
                            .getText());
                    if (input < 1) {
                        objectsStrength[14] = 1;
                        objectsStrengthTF[14].setText(Integer
                                .toString(objectsStrength[14]));
                    } else if (input > 99) {
                        objectsStrength[14] = 99;
                        objectsStrengthTF[14].setText(Integer
                                .toString(objectsStrength[14]));
                    } else
                        objectsStrength[14] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[14] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[14].setText(Integer
                            .toString(objectsStrength[14]));
                }
            }
        });

        objects.add(new JLabel("Hair Restorer"));
        objects.add(objectsAvailCB[25]);
        objects.add(objectsStartAvailCB[25]);
        objects.add(objectsResearchTF[25]);
        objects.add(objectsStrengthTF[25]);
        objectsAvailCB[25].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[25] = 1;
                else
                    objectsAvail[25] = 0;
            }
        });
        objectsStartAvailCB[25].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[25] = 1;
                else
                    objectsStartAvail[25] = 0;
            }
        });
        objectsResearchTF[25].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[25].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[25]
                            .getText());
                    if (input < 1) {
                        objectsResearch[25] = 1;
                        objectsResearchTF[25].setText(Integer
                                .toString(objectsResearch[25]));
                    } else
                        objectsResearch[25] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[25] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[25].setText(Integer
                            .toString(objectsResearch[25]));
                }
            }
        });
        objectsStrengthTF[25].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[25].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[25]
                            .getText());
                    if (input < 1) {
                        objectsStrength[25] = 1;
                        objectsStrengthTF[25].setText(Integer
                                .toString(objectsStrength[25]));
                    } else if (input > 99) {
                        objectsStrength[25] = 99;
                        objectsStrengthTF[25].setText(Integer
                                .toString(objectsStrength[25]));
                    } else
                        objectsStrength[25] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[25] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[25].setText(Integer
                            .toString(objectsStrength[25]));
                }
            }
        });

        objects.add(new JLabel("Blood Machine"));
        objects.add(objectsAvailCB[42]);
        objects.add(objectsStartAvailCB[42]);
        objects.add(objectsResearchTF[42]);
        objects.add(objectsStrengthTF[42]);
        objectsAvailCB[42].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[42] = 1;
                else
                    objectsAvail[42] = 0;
            }
        });
        objectsStartAvailCB[42].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[42] = 1;
                else
                    objectsStartAvail[42] = 0;
            }
        });
        objectsResearchTF[42].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[42].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[42]
                            .getText());
                    if (input < 1) {
                        objectsResearch[42] = 1;
                        objectsResearchTF[42].setText(Integer
                                .toString(objectsResearch[42]));
                    } else
                        objectsResearch[42] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[42] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[42].setText(Integer
                            .toString(objectsResearch[42]));
                }
            }
        });
        objectsStrengthTF[42].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[42].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[42]
                            .getText());
                    if (input < 1) {
                        objectsStrength[42] = 1;
                        objectsStrengthTF[42].setText(Integer
                                .toString(objectsStrength[42]));
                    } else if (input > 99) {
                        objectsStrength[42] = 99;
                        objectsStrengthTF[42].setText(Integer
                                .toString(objectsStrength[42]));
                    } else
                        objectsStrength[42] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[42] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[42].setText(Integer
                            .toString(objectsStrength[42]));
                }
            }
        });

        objects.add(new JLabel("Electrolysis Machine"));
        objects.add(objectsAvailCB[46]);
        objects.add(objectsStartAvailCB[46]);
        objects.add(objectsResearchTF[46]);
        objects.add(objectsStrengthTF[46]);
        objectsAvailCB[46].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[46] = 1;
                else
                    objectsAvail[46] = 0;
            }
        });
        objectsStartAvailCB[46].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[46] = 1;
                else
                    objectsStartAvail[46] = 0;
            }
        });
        objectsResearchTF[46].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[46].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[46]
                            .getText());
                    if (input < 1) {
                        objectsResearch[46] = 1;
                        objectsResearchTF[46].setText(Integer
                                .toString(objectsResearch[46]));
                    } else
                        objectsResearch[46] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[46] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[46].setText(Integer
                            .toString(objectsResearch[46]));
                }
            }
        });
        objectsStrengthTF[46].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[46].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[46]
                            .getText());
                    if (input < 1) {
                        objectsStrength[46] = 1;
                        objectsStrengthTF[46].setText(Integer
                                .toString(objectsStrength[46]));
                    } else if (input > 99) {
                        objectsStrength[46] = 99;
                        objectsStrengthTF[46].setText(Integer
                                .toString(objectsStrength[46]));
                    } else
                        objectsStrength[46] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[46] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[46].setText(Integer
                            .toString(objectsStrength[46]));
                }
            }
        });

        objects.add(new JLabel("Decontamination Shower"));
        objects.add(objectsAvailCB[54]);
        objects.add(objectsStartAvailCB[54]);
        objects.add(objectsResearchTF[54]);
        objects.add(objectsStrengthTF[54]);
        objectsAvailCB[54].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[54] = 1;
                else
                    objectsAvail[54] = 0;
            }
        });
        objectsStartAvailCB[54].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[54] = 1;
                else
                    objectsStartAvail[54] = 0;
            }
        });
        objectsResearchTF[54].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[54].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[54]
                            .getText());
                    if (input < 1) {
                        objectsResearch[54] = 1;
                        objectsResearchTF[54].setText(Integer
                                .toString(objectsResearch[54]));
                    } else
                        objectsResearch[54] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[54] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[54].setText(Integer
                            .toString(objectsResearch[54]));
                }
            }
        });
        objectsStrengthTF[54].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[54].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[54]
                            .getText());
                    if (input < 1) {
                        objectsStrength[54] = 1;
                        objectsStrengthTF[54].setText(Integer
                                .toString(objectsStrength[54]));
                    } else if (input > 99) {
                        objectsStrength[54] = 99;
                        objectsStrengthTF[54].setText(Integer
                                .toString(objectsStrength[54]));
                    } else
                        objectsStrength[54] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[54] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[54].setText(Integer
                            .toString(objectsStrength[54]));
                }
            }
        });

        objects.add(new JLabel("Ultrascan"));
        objects.add(objectsAvailCB[22]);
        objects.add(objectsStartAvailCB[22]);
        objects.add(objectsResearchTF[22]);
        objects.add(objectsStrengthTF[22]);
        objectsAvailCB[22].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[22] = 1;
                else
                    objectsAvail[22] = 0;
            }
        });
        objectsStartAvailCB[22].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[22] = 1;
                else
                    objectsStartAvail[22] = 0;
            }
        });
        objectsResearchTF[22].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[22].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[22]
                            .getText());
                    if (input < 1) {
                        objectsResearch[22] = 1;
                        objectsResearchTF[22].setText(Integer
                                .toString(objectsResearch[22]));
                    } else
                        objectsResearch[22] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[22] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[22].setText(Integer
                            .toString(objectsResearch[22]));
                }
            }
        });
        objectsStrengthTF[22].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[22].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[22]
                            .getText());
                    if (input < 1) {
                        objectsStrength[22] = 1;
                        objectsStrengthTF[22].setText(Integer
                                .toString(objectsStrength[22]));
                    } else if (input > 99) {
                        objectsStrength[22] = 99;
                        objectsStrengthTF[22].setText(Integer
                                .toString(objectsStrength[22]));
                    } else
                        objectsStrength[22] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[22] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[22].setText(Integer
                            .toString(objectsStrength[22]));
                }
            }
        });

        objects.add(new JLabel("Jellyitus Moulding Machine"));
        objects.add(objectsAvailCB[47]);
        objects.add(objectsStartAvailCB[47]);
        objects.add(objectsResearchTF[47]);
        objects.add(objectsStrengthTF[47]);
        objectsAvailCB[47].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[47] = 1;
                else
                    objectsAvail[47] = 0;
            }
        });
        objectsStartAvailCB[47].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[47] = 1;
                else
                    objectsStartAvail[47] = 0;
            }
        });
        objectsResearchTF[47].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[47].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[47]
                            .getText());
                    if (input < 1) {
                        objectsResearch[47] = 1;
                        objectsResearchTF[47].setText(Integer
                                .toString(objectsResearch[47]));
                    } else
                        objectsResearch[47] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[47] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[47].setText(Integer
                            .toString(objectsResearch[47]));
                }
            }
        });
        objectsStrengthTF[47].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[47].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[47]
                            .getText());
                    if (input < 1) {
                        objectsStrength[47] = 1;
                        objectsStrengthTF[47].setText(Integer
                                .toString(objectsStrength[47]));
                    } else if (input > 99) {
                        objectsStrength[47] = 99;
                        objectsStrengthTF[47].setText(Integer
                                .toString(objectsStrength[47]));
                    } else
                        objectsStrength[47] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[47] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[47].setText(Integer
                            .toString(objectsStrength[47]));
                }
            }
        });

        objects.add(new JLabel("DNA Restorer"));
        objects.add(objectsAvailCB[23]);
        objects.add(objectsStartAvailCB[23]);
        objects.add(objectsResearchTF[23]);
        objects.add(objectsStrengthTF[23]);
        objectsAvailCB[23].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[23] = 1;
                else
                    objectsAvail[23] = 0;
            }
        });
        objectsStartAvailCB[23].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[23] = 1;
                else
                    objectsStartAvail[23] = 0;
            }
        });
        objectsResearchTF[23].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[23].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[23]
                            .getText());
                    if (input < 1) {
                        objectsResearch[23] = 1;
                        objectsResearchTF[23].setText(Integer
                                .toString(objectsResearch[23]));
                    } else
                        objectsResearch[23] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[23] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[23].setText(Integer
                            .toString(objectsResearch[23]));
                }
            }
        });
        objectsStrengthTF[23].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsStrengthTF[23].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsStrengthTF[23]
                            .getText());
                    if (input < 1) {
                        objectsStrength[23] = 1;
                        objectsStrengthTF[23].setText(Integer
                                .toString(objectsStrength[23]));
                    } else if (input > 99) {
                        objectsStrength[23] = 99;
                        objectsStrengthTF[23].setText(Integer
                                .toString(objectsStrength[23]));
                    } else
                        objectsStrength[23] = input;
                } catch (NumberFormatException nfe) {
                    objectsStrength[23] = Integer.parseInt(Gui.tempValue);
                    objectsStrengthTF[23].setText(Integer
                            .toString(objectsStrength[23]));
                }
            }
        });

        // others
        objects.add(new JLabel("Research Computer"));
        objects.add(objectsAvailCB[40]);
        objects.add(objectsStartAvailCB[40]);
        objects.add(objectsResearchTF[40]);
        objects.next();
        objectsAvailCB[40].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[40] = 1;
                else
                    objectsAvail[40] = 0;
            }
        });
        objectsStartAvailCB[40].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[40] = 1;
                else
                    objectsStartAvail[40] = 0;
            }
        });
        objectsResearchTF[40].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[40].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[40]
                            .getText());
                    if (input < 1) {
                        objectsResearch[40] = 1;
                        objectsResearchTF[40].setText(Integer
                                .toString(objectsResearch[40]));
                    } else
                        objectsResearch[40] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[40] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[40].setText(Integer
                            .toString(objectsResearch[40]));
                }
            }
        });

        objects.add(new JLabel("Atom Analyser"));
        objects.add(objectsAvailCB[41]);
        objects.add(objectsStartAvailCB[41]);
        objects.add(objectsResearchTF[41]);
        objects.next();
        objectsAvailCB[41].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[41] = 1;
                else
                    objectsAvail[41] = 0;
            }
        });
        objectsStartAvailCB[41].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsStartAvail[41] = 1;
                else
                    objectsStartAvail[41] = 0;
            }
        });
        objectsResearchTF[41].addFocusListener(new FocusListener() {
            @Override
            public void focusGained(FocusEvent e) {
                ((JTextField) e.getComponent()).selectAll();
                Gui.tempValue = objectsResearchTF[41].getText();
            }

            @Override
            public void focusLost(FocusEvent e) {
                try {
                    int input = Integer.parseInt(objectsResearchTF[41]
                            .getText());
                    if (input < 1) {
                        objectsResearch[41] = 1;
                        objectsResearchTF[41].setText(Integer
                                .toString(objectsResearch[41]));
                    } else
                        objectsResearch[41] = input;
                } catch (NumberFormatException nfe) {
                    objectsResearch[41] = Integer.parseInt(Gui.tempValue);
                    objectsResearchTF[41].setText(Integer
                            .toString(objectsResearch[41]));
                }
            }
        });

        objects.add(new JLabel("Training"));
        objects.add(objectsAvailCB[37]);
        objects.next(3);
        objectsAvailCB[37].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[37] = 1;
                else
                    objectsAvail[37] = 0;
            }
        });

        objects.add(new JLabel("Video Game"));
        objects.add(objectsAvailCB[57]);
        objectsAvailCB[57].addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    objectsAvail[57] = 1;
                else
                    objectsAvail[57] = 0;
            }
        });
    }
}
