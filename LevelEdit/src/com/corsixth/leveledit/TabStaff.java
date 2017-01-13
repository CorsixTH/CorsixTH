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
import java.util.ArrayList;
import java.util.Random;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextField;

public class TabStaff extends JScrollPane {

    private static final long serialVersionUID = -6211357935747302151L;

    VarManipulator variableManipulator = new VarManipulator();

    // variables
    static ArrayList<StartStaff> startStaffList = new ArrayList<StartStaff>();
    static ArrayList<StaffLevels> staffLevelsList = new ArrayList<StaffLevels>();
    static int[] staffSalary = new int[4];
    static int[] salaryAdd = new int[9]; // index 0,1,2 are not used.

    // components
    GridPanel staff = new GridPanel(1);
    JScrollPane scrollPane = new JScrollPane(staff);

    GridPanel salary = new GridPanel(1);
    JLabel salaryLabel = new JLabel("   Minimum salary");
    JLabel salaryAddLabel = new JLabel("   Added salary");
    static JTextField[] staffSalaryTF = new JTextField[4];
    static JTextField[] salaryAddTF = new JTextField[9];// index 0,1,2 are not
                                                        // used.

    static JPanel levels = new GridPanel(1);
    JPanel levelsButtons = new JPanel();
    JButton addLevelsButt = new JButton("Add");
    JButton removeLevelsButt = new JButton("Remove");

    static GridPanel start = new GridPanel(1);
    JPanel startButtons = new JPanel();
    JButton addStartButt = new JButton("Add");
    JButton removeStartButt = new JButton("Remove");

    public TabStaff() {
        // set scroll speed
        getVerticalScrollBar().setUnitIncrement(20);
        getHorizontalScrollBar().setUnitIncrement(20);

        salary.setInsets(0);
        start.setInsets(0);
        setViewportView(staff);
        // initializing members of checkbox and textfield arrays, else they will
        // be null.
        for (int i = 0; i < staffSalaryTF.length; i++)
            staffSalaryTF[i] = new JTextField(3);
        for (int i = 0; i < salaryAddTF.length; i++)
            salaryAddTF[i] = new JTextField(3);

        // salary panel
        staff.add(salary);
        salary.setBorder(BorderFactory.createTitledBorder("Salary"));
        salary.add(salaryLabel);
        salaryLabel.setToolTipText("Minimum salary for each staff type");

        JPanel minSalary = new JPanel();
        minSalary.add(new JLabel("Nurse:"));
        minSalary.add(staffSalaryTF[0]);
        staffSalaryTF[0].addFocusListener(new FocusListener() {
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
                        staffSalary[0] = 1;
                        tf.setText(Integer.toString(staffSalary[0]));
                    } else
                        staffSalary[0] = input;
                } catch (NumberFormatException nfe) {
                    staffSalary[0] = Integer.parseInt(Gui.tempValue);
                    tf.setText(Gui.tempValue);
                }
            }
        });

        minSalary.add(new JLabel("Doctor:"));
        minSalary.add(staffSalaryTF[1]);
        staffSalaryTF[1].addFocusListener(new FocusListener() {
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
                        staffSalary[1] = 1;
                        tf.setText(Integer.toString(staffSalary[1]));
                    } else
                        staffSalary[1] = input;
                } catch (NumberFormatException nfe) {
                    staffSalary[1] = Integer.parseInt(Gui.tempValue);
                    tf.setText(Gui.tempValue);
                }
            }
        });

        minSalary.add(new JLabel("Handyman:"));
        minSalary.add(staffSalaryTF[2]);
        staffSalaryTF[2].addFocusListener(new FocusListener() {
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
                        staffSalary[2] = 1;
                        tf.setText(Integer.toString(staffSalary[2]));
                    } else
                        staffSalary[2] = input;
                } catch (NumberFormatException nfe) {
                    staffSalary[2] = Integer.parseInt(Gui.tempValue);
                    tf.setText(Gui.tempValue);
                }
            }
        });

        minSalary.add(new JLabel("Receptionist:"));
        minSalary.add(staffSalaryTF[3]);
        salary.add(minSalary);
        staffSalaryTF[3].addFocusListener(new FocusListener() {
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
                        staffSalary[3] = 1;
                        tf.setText(Integer.toString(staffSalary[0]));
                    } else
                        staffSalary[3] = input;
                } catch (NumberFormatException nfe) {
                    staffSalary[3] = Integer.parseInt(Gui.tempValue);
                    tf.setText(Gui.tempValue);
                }
            }
        });

        salary.add(salaryAddLabel);
        salaryAddLabel
                .setToolTipText("Salary modifiers for different doctor attributes");

        JPanel addSalary = new JPanel();
        addSalary.add(new JLabel("Junior:"));
        addSalary.add(salaryAddTF[3]);
        salaryAddTF[3].addFocusListener(new FocusListener() {
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
                    salaryAdd[3] = Integer.parseInt(tf.getText());
                } catch (NumberFormatException nfe) {
                    salaryAdd[3] = Integer.parseInt(Gui.tempValue);
                    tf.setText(Gui.tempValue);
                }
            }
        });

        addSalary.add(new JLabel("Doctor:"));
        addSalary.add(salaryAddTF[4]);
        salaryAddTF[4].addFocusListener(new FocusListener() {
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
                    salaryAdd[4] = Integer.parseInt(tf.getText());
                } catch (NumberFormatException nfe) {
                    salaryAdd[4] = Integer.parseInt(Gui.tempValue);
                    tf.setText(Gui.tempValue);
                }
            }
        });

        addSalary.add(new JLabel("Consultant:"));
        addSalary.add(salaryAddTF[7]);
        salaryAddTF[7].addFocusListener(new FocusListener() {
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
                    salaryAdd[7] = Integer.parseInt(tf.getText());
                } catch (NumberFormatException nfe) {
                    salaryAdd[7] = Integer.parseInt(Gui.tempValue);
                    tf.setText(Gui.tempValue);
                }
            }
        });

        addSalary.add(new JLabel("Surgeon:"));
        addSalary.add(salaryAddTF[5]);
        salaryAddTF[5].addFocusListener(new FocusListener() {
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
                    salaryAdd[5] = Integer.parseInt(tf.getText());
                } catch (NumberFormatException nfe) {
                    salaryAdd[5] = Integer.parseInt(Gui.tempValue);
                    tf.setText(Gui.tempValue);
                }
            }
        });

        addSalary.add(new JLabel("Psychiatrist:"));
        addSalary.add(salaryAddTF[6]);
        salaryAddTF[6].addFocusListener(new FocusListener() {
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
                    salaryAdd[6] = Integer.parseInt(tf.getText());
                } catch (NumberFormatException nfe) {
                    salaryAdd[6] = Integer.parseInt(Gui.tempValue);
                    tf.setText(Gui.tempValue);
                }
            }
        });

        addSalary.add(new JLabel("Researcher:"));
        addSalary.add(salaryAddTF[8]);
        salary.add(addSalary);
        salaryAddTF[8].addFocusListener(new FocusListener() {
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
                    salaryAdd[8] = Integer.parseInt(tf.getText());
                } catch (NumberFormatException nfe) {
                    salaryAdd[8] = Integer.parseInt(Gui.tempValue);
                    tf.setText(Gui.tempValue);
                }
            }
        });

        // staff distribution
        staff.add(levels);
        levels.add(levelsButtons);
        levels.setBorder(BorderFactory.createTitledBorder("Staff distribution"));

        levelsButtons.add(addLevelsButt);
        addLevelsButt.addActionListener(new ActionListener() {
            // on click add button
            @Override
            public void actionPerformed(ActionEvent e) {
                addStaffLevels();
            }
        });

        levelsButtons.add(removeLevelsButt);
        removeLevelsButt.addActionListener(new ActionListener() {
            // on click remove button
            @Override
            public void actionPerformed(ActionEvent e) {
                removeStaffLevels();
            }
        });

        // starting staff panel
        staff.add(start);
        start.add(startButtons);
        start.setBorder(BorderFactory.createTitledBorder("Starting staff"));

        startButtons.add(addStartButt);
        addStartButt.addActionListener(new ActionListener() {
            // on click add button
            @Override
            public void actionPerformed(ActionEvent e) {
                addStartStaff();
            }
        });

        startButtons.add(removeStartButt);
        removeStartButt.addActionListener(new ActionListener() {
            // on click remove button
            @Override
            public void actionPerformed(ActionEvent e) {
                removeStartStaff();
            }
        });

    }

    public static void addStartStaff() {
        // creates a new startStaff object and adds it to the arraylist
        // not sure why it has to be final
        final StartStaff startStaff = new StartStaff();
        startStaffList.add(startStaff);

        // get the index of this particular startStaff member
        final int index = (startStaffList.indexOf(startStaff));

        // when staff member selection changes
        startStaffList.get(index).staffMemberCombo
                .addActionListener(new ActionListener() {
                    @Override
                    public void actionPerformed(ActionEvent e) {

                        JComboBox cb = (JComboBox) e.getSource();
                        if (cb.getSelectedItem() == "Doctor") {
                            startStaffList.get(index).doctor = 1;
                            startStaffList.get(index).nurse = 0;
                            startStaffList.get(index).handyman = 0;
                            startStaffList.get(index).receptionist = 0;

                            startStaffList.get(index).startStaffPanel
                                    .add(startStaffList.get(index).shrinkLabel);
                            startStaffList.get(index).startStaffPanel
                                    .add(startStaffList.get(index).shrinkCB);
                            startStaffList.get(index).startStaffPanel
                                    .add(startStaffList.get(index).surgeonLabel);
                            startStaffList.get(index).startStaffPanel
                                    .add(startStaffList.get(index).surgeonCB);
                            startStaffList.get(index).startStaffPanel
                                    .add(startStaffList.get(index).researcherLabel);
                            startStaffList.get(index).startStaffPanel
                                    .add(startStaffList.get(index).researcherCB);
                            startStaffList.get(index).startStaffPanel
                                    .add(startStaffList.get(index).skillLabel);
                            startStaffList.get(index).startStaffPanel.add(
                                    startStaffList.get(index).skillTF);
                            startStaffList.get(index).startStaffPanel
                                    .updateUI();
                        } else {
                            startStaffList.get(index).doctor = 0;
                            startStaffList.get(index).shrink = 0;
                            startStaffList.get(index).surgeon = 0;
                            startStaffList.get(index).researcher = 0;
                            if (cb.getSelectedItem() == "Nurse") {
                                startStaffList.get(index).nurse = 1;
                                startStaffList.get(index).handyman = 0;
                                startStaffList.get(index).receptionist = 0;
                            }
                            if (cb.getSelectedItem() == "Handyman") {
                                startStaffList.get(index).handyman = 1;
                                startStaffList.get(index).nurse = 0;
                                startStaffList.get(index).receptionist = 0;
                            }
                            if (cb.getSelectedItem() == "Receptionist") {
                                startStaffList.get(index).receptionist = 1;
                                startStaffList.get(index).nurse = 0;
                                startStaffList.get(index).handyman = 0;
                            }

                            startStaffList.get(index).startStaffPanel
                                    .remove(startStaffList.get(index).shrinkLabel);
                            startStaffList.get(index).startStaffPanel
                                    .remove(startStaffList.get(index).shrinkCB);
                            startStaffList.get(index).startStaffPanel
                                    .remove(startStaffList.get(index).surgeonLabel);
                            startStaffList.get(index).startStaffPanel
                                    .remove(startStaffList.get(index).surgeonCB);
                            startStaffList.get(index).startStaffPanel
                                    .remove(startStaffList.get(index).researcherLabel);
                            startStaffList.get(index).startStaffPanel
                                    .remove(startStaffList.get(index).researcherCB);
                            startStaffList.get(index).startStaffPanel
                                    .updateUI();

                        }
                    }
                });

        startStaffList.get(index).startStaffPanel
                .add(startStaffList.get(index).staffMemberCombo);
        startStaffList.get(index).startStaffPanel
                .add(startStaffList.get(index).shrinkLabel);
        startStaffList.get(index).startStaffPanel
                .add(startStaffList.get(index).shrinkCB);
        startStaffList.get(index).shrinkCB.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    startStaffList.get(index).shrink = 1;
                else
                    startStaffList.get(index).shrink = 0;
            }
        });
        startStaffList.get(index).startStaffPanel
                .add(startStaffList.get(index).surgeonLabel);
        startStaffList.get(index).startStaffPanel
                .add(startStaffList.get(index).surgeonCB);
        startStaffList.get(index).surgeonCB.addItemListener(new ItemListener() {
            @Override
            public void itemStateChanged(ItemEvent e) {
                if (e.getStateChange() == ItemEvent.SELECTED)
                    startStaffList.get(index).surgeon = 1;
                else
                    startStaffList.get(index).surgeon = 0;
            }
        });
        startStaffList.get(index).startStaffPanel
                .add(startStaffList.get(index).researcherLabel);
        startStaffList.get(index).startStaffPanel
                .add(startStaffList.get(index).researcherCB);
        startStaffList.get(index).researcherCB
                .addItemListener(new ItemListener() {
                    @Override
                    public void itemStateChanged(ItemEvent e) {
                        if (e.getStateChange() == ItemEvent.SELECTED)
                            startStaffList.get(index).researcher = 1;
                        else
                            startStaffList.get(index).researcher = 0;
                    }
                });
        startStaffList.get(index).startStaffPanel
                .add(startStaffList.get(index).skillLabel);
        startStaffList.get(index).skillLabel
                .setToolTipText("45 gives doctor, 90 gives consultant");
        startStaffList.get(index).startStaffPanel.add(
                startStaffList.get(index).skillTF);
        startStaffList.get(index).skillTF.addFocusListener(new FocusListener() {
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
                    int value = Integer.parseInt(tf.getText());
                    if (value > 100) {
                        startStaffList.get(index).skill = 100;
                        tf.setText("100");
                    } else if (value < 1) {
                        startStaffList.get(index).skill = 1;
                        tf.setText("1");
                    } else
                        startStaffList.get(index).skill = value;
                } catch (NumberFormatException nfe) {
                    startStaffList.get(index).skill = Integer
                            .parseInt(Gui.tempValue);
                    tf.setText(Gui.tempValue);
                }
            }
        });

        startStaffList.get(index).startStaffPanel.updateUI();

        start.add(startStaffList.get(index).startStaffPanel);
        start.updateUI();
    }

    public static void removeStartStaff() {
        int lastIndex = startStaffList.size() - 1;
        if (lastIndex >= 0) {
            // remove the panel
            start.remove(startStaffList.get(lastIndex).startStaffPanel);
            start.updateUI();
            // remove the object from the arraylist
            startStaffList.remove(lastIndex);
        }
    }

    public static void addStaffLevels() {
        final StaffLevels staffLevels = new StaffLevels();
        staffLevelsList.add(staffLevels);

        // get the index of this particular arraylist member
        final int index = (staffLevelsList.indexOf(staffLevels));

        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).monthLabel);
        staffLevelsList.get(index).monthLabel
                .setToolTipText("In which month the new staff distribution will take effect");
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).monthTF);
        staffLevelsList.get(index).monthTF
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
                            int value = Integer.parseInt(tf.getText());
                            if (value >= 0)
                                staffLevelsList.get(index).month = value;
                            else {
                                staffLevelsList.get(index).month = 0;
                                tf.setText("0");
                            }
                        } catch (NumberFormatException nfe) {
                            staffLevelsList.get(index).month = Integer
                                    .parseInt(Gui.tempValue);
                            tf.setText(Gui.tempValue);
                        }
                        // make sure that there are no duplicate month entries
                        for (int i = 0; i < staffLevelsList.size(); i++) {
                            for (int ii = index; i < ii; i++) {
                                if (staffLevelsList.get(i).month == staffLevelsList
                                        .get(ii).month) {
                                    staffLevelsList.get(ii).month = staffLevelsList
                                            .get(i).month + 1;
                                    staffLevelsList.get(ii).monthTF
                                            .setText(Integer
                                                    .toString(staffLevelsList
                                                            .get(ii).month));
                                }
                            }
                            for (int ii = index; i > ii; ii++) {
                                if (staffLevelsList.get(i).month == staffLevelsList
                                        .get(ii).month) {
                                    staffLevelsList.get(i).month = staffLevelsList
                                            .get(ii).month + 1;
                                    staffLevelsList.get(i).monthTF
                                            .setText(Integer
                                                    .toString(staffLevelsList
                                                            .get(i).month));
                                }
                            }
                        }

                    }

                });
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).doctorsLabel);
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).doctorsTF);
        staffLevelsList.get(index).doctorsTF
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
                            int value = Integer.parseInt(tf.getText());
                            if (value >= 0)
                                staffLevelsList.get(index).doctors = value;
                            else {
                                staffLevelsList.get(index).doctors = 0;
                                tf.setText("0");
                            }
                        } catch (NumberFormatException nfe) {
                            staffLevelsList.get(index).doctors = Integer
                                    .parseInt(Gui.tempValue);
                            tf.setText(Gui.tempValue);
                        }
                    }

                });
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).nursesLabel);
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).nursesTF);
        staffLevelsList.get(index).nursesTF
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
                            int value = Integer.parseInt(tf.getText());
                            if (value >= 0)
                                staffLevelsList.get(index).nurses = value;
                            else {
                                staffLevelsList.get(index).nurses = 0;
                                tf.setText("0");
                            }
                        } catch (NumberFormatException nfe) {
                            staffLevelsList.get(index).nurses = Integer
                                    .parseInt(Gui.tempValue);
                            tf.setText(Gui.tempValue);
                        }
                    }

                });
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).handymenLabel);
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).handymenTF);
        staffLevelsList.get(index).handymenTF
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
                            int value = Integer.parseInt(tf.getText());
                            if (value >= 0)
                                staffLevelsList.get(index).handymen = value;
                            else {
                                staffLevelsList.get(index).handymen = 0;
                                tf.setText("0");
                            }
                        } catch (NumberFormatException nfe) {
                            staffLevelsList.get(index).handymen = Integer
                                    .parseInt(Gui.tempValue);
                            tf.setText(Gui.tempValue);
                        }
                    }

                });
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).receptionistsLabel);
        staffLevelsList.get(index).staffLevelsPanel.add(
                staffLevelsList.get(index).receptionistsTF);
        staffLevelsList.get(index).receptionistsTF
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
                            int value = Integer.parseInt(tf.getText());
                            if (value >= 0)
                                staffLevelsList.get(index).receptionists = value;
                            else {
                                staffLevelsList.get(index).receptionists = 0;
                                tf.setText("0");
                            }
                        } catch (NumberFormatException nfe) {
                            staffLevelsList.get(index).receptionists = Integer
                                    .parseInt(Gui.tempValue);
                            tf.setText(Gui.tempValue);
                        }
                    }

                });

        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).shrinkRateLabel);
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).shrinkRateTF);
        staffLevelsList.get(index).shrinkRateTF
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
                            String input = tf.getText();
                            // if input matches 1 divided by any number
                            if (input.matches("1/\\d+")) {
                                // remove the "1/" so the value can be saved
                                // properly
                                input = (input.replaceFirst("1/", ""));
                                int value = Integer.parseInt(input);
                                staffLevelsList.get(index).shrinkRate = value;
                            }
                            // if input is not a fraction, but still a number
                            else if (input.matches("\\d+")) {
                                int value = Integer.parseInt(input);
                                staffLevelsList.get(index).shrinkRate = value;
                                tf.setText("1/" + value);
                            } else {
                                staffLevelsList.get(index).shrinkRate = Integer
                                        .parseInt(Gui.tempValue.replaceFirst(
                                                "1/", ""));
                                tf.setText(Gui.tempValue);
                            }
                        } catch (NumberFormatException nfe) {
                            staffLevelsList.get(index).shrinkRate = Integer
                                    .parseInt(Gui.tempValue.replaceFirst("1/",
                                            ""));
                            tf.setText(Gui.tempValue);
                        }
                    }

                });
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).surgeonRateLabel);
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).surgeonRateTF);
        staffLevelsList.get(index).surgeonRateTF
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
                            String input = tf.getText();
                            // if input matches 1 divided by any number
                            if (input.matches("1/\\d+")) {
                                // remove the "1/" so the value can be saved
                                // properly
                                input = (input.replaceFirst("1/", ""));
                                int value = Integer.parseInt(input);
                                staffLevelsList.get(index).surgeonRate = value;
                            }
                            // if input is not a fraction, but still a number
                            else if (input.matches("\\d+")) {
                                int value = Integer.parseInt(input);
                                staffLevelsList.get(index).surgeonRate = value;
                                staffLevelsList.get(index).surgeonRateTF
                                        .setText("1/" + value);
                            } else {
                                staffLevelsList.get(index).surgeonRate = Integer
                                        .parseInt(Gui.tempValue.replaceFirst(
                                                "1/", ""));
                                tf.setText(Gui.tempValue);
                            }
                        } catch (NumberFormatException nfe) {
                            staffLevelsList.get(index).surgeonRate = Integer
                                    .parseInt(Gui.tempValue.replaceFirst("1/",
                                            ""));
                            tf.setText(Gui.tempValue);
                        }
                    }

                });
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).researcherRateLabel);
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).researcherRateTF);
        staffLevelsList.get(index).researcherRateTF
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
                            String input = tf.getText();
                            // if input matches 1 divided by any number
                            if (input.matches("1/\\d+")) {
                                // remove the "1/" so the value can be saved
                                // properly
                                input = (input.replaceFirst("1/", ""));
                                int value = Integer.parseInt(input);
                                staffLevelsList.get(index).researcherRate = value;
                            }
                            // if input is not a fraction, but still a number
                            else if (input.matches("\\d+")) {
                                int value = Integer.parseInt(input);
                                staffLevelsList.get(index).researcherRate = value;
                                staffLevelsList.get(index).researcherRateTF
                                        .setText("1/" + value);
                            } else {
                                staffLevelsList.get(index).researcherRate = Integer
                                        .parseInt(Gui.tempValue.replaceFirst(
                                                "1/", ""));
                                tf.setText(Gui.tempValue);
                            }
                        } catch (NumberFormatException nfe) {
                            staffLevelsList.get(index).researcherRate = Integer
                                    .parseInt(Gui.tempValue.replaceFirst("1/",
                                            ""));
                            tf.setText(Gui.tempValue);
                        }
                    }

                });
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).consultantRateLabel);
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).consultantRateTF);
        staffLevelsList.get(index).consultantRateTF
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
                            String input = tf.getText();
                            // if input matches 1 divided by any number
                            if (input.matches("1/\\d+")) {
                                // remove the "1/" so the value can be saved
                                // properly
                                input = (input.replaceFirst("1/", ""));
                                int value = Integer.parseInt(input);
                                staffLevelsList.get(index).consultantRate = value;
                            }
                            // if input is not a fraction, but still a number
                            else if (input.matches("\\d+")) {
                                int value = Integer.parseInt(input);
                                staffLevelsList.get(index).consultantRate = value;
                                staffLevelsList.get(index).consultantRateTF
                                        .setText("1/" + value);
                            } else {
                                staffLevelsList.get(index).consultantRate = Integer
                                        .parseInt(Gui.tempValue.replaceFirst(
                                                "1/", ""));
                                tf.setText(Gui.tempValue);
                            }
                        } catch (NumberFormatException nfe) {
                            staffLevelsList.get(index).consultantRate = Integer
                                    .parseInt(Gui.tempValue.replaceFirst("1/",
                                            ""));
                            tf.setText(Gui.tempValue);
                        }
                    }

                });
        staffLevelsList.get(index).staffLevelsPanel.add(staffLevelsList
                .get(index).juniorRateLabel);
        staffLevelsList.get(index).staffLevelsPanel.add(
                staffLevelsList.get(index).juniorRateTF);
        staffLevelsList.get(index).juniorRateTF
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
                            String input = tf.getText();
                            // if input matches 1 divided by any number
                            if (input.matches("1/\\d+")) {
                                // remove the "1/" so the value can be saved
                                // properly
                                input = (input.replaceFirst("1/", ""));
                                int value = Integer.parseInt(input);
                                staffLevelsList.get(index).juniorRate = value;
                            }
                            // if input is not a fraction, but still a number
                            else if (input.matches("\\d+")) {
                                int value = Integer.parseInt(input);
                                staffLevelsList.get(index).juniorRate = value;
                                staffLevelsList.get(index).juniorRateTF
                                        .setText("1/" + value);
                            } else {
                                staffLevelsList.get(index).juniorRate = Integer
                                        .parseInt(Gui.tempValue.replaceFirst(
                                                "1/", ""));
                                tf.setText(Gui.tempValue);
                            }
                        } catch (NumberFormatException nfe) {
                            staffLevelsList.get(index).juniorRate = Integer
                                    .parseInt(Gui.tempValue.replaceFirst("1/",
                                            ""));
                            tf.setText(Gui.tempValue);
                        }
                    }

                });

        levels.add(staffLevelsList.get(index).staffLevelsPanel);
        levels.updateUI();

        // increase starting month with each new add
        if (staffLevelsList.size() > 1) {
            staffLevelsList.get(index).month = staffLevelsList.get(index - 1).month + 6;
            int monthPlus = Integer
                    .parseInt(staffLevelsList.get(index - 1).monthTF.getText()) + 6;
            staffLevelsList.get(index).monthTF.setText(Integer
                    .toString(monthPlus));
        }

        // randomize staff distribution
        int randomInt = (new Random().nextInt(5) - 2);
        staffLevelsList.get(index).doctors += randomInt;
        staffLevelsList.get(index).doctorsTF.setText(Integer
                .toString(staffLevelsList.get(index).doctors));
        randomInt = (new Random().nextInt(4) - 5);
        staffLevelsList.get(index).nurses += randomInt;
        staffLevelsList.get(index).nursesTF.setText(Integer
                .toString(staffLevelsList.get(index).nurses));
        randomInt = (new Random().nextInt(3));
        staffLevelsList.get(index).handymen += randomInt;
        staffLevelsList.get(index).handymenTF.setText(Integer
                .toString(staffLevelsList.get(index).handymen));
        randomInt = (new Random().nextInt(4) - 1);
        staffLevelsList.get(index).receptionists += randomInt;
        staffLevelsList.get(index).receptionistsTF.setText(Integer
                .toString(staffLevelsList.get(index).receptionists));
    }

    public static void removeStaffLevels() {
        int lastIndex = staffLevelsList.size() - 1;
        if (lastIndex >= 0) {
            // remove panel
            levels.remove(staffLevelsList.get(lastIndex).staffLevelsPanel);
            levels.updateUI();
            // remove object from the arraylist
            staffLevelsList.remove(lastIndex);
        }

    }

}
