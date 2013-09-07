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
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

public class StartStaff {
    int doctor = 1;
    int shrink = 0;
    int surgeon = 0;
    int researcher = 0;
    int nurse = 0;
    int handyman = 0;
    int receptionist = 0;
    int skill = 50;
    String[] staffChoice = { "Doctor", "Nurse", "Handyman", "Receptionist" };

    JPanel startStaffPanel = new JPanel();

    JComboBox staffMemberCombo = new JComboBox(staffChoice);
    JCheckBox shrinkCB = new JCheckBox();
    JCheckBox surgeonCB = new JCheckBox();
    JCheckBox researcherCB = new JCheckBox();
    JLabel shrinkLabel = new JLabel("Psychiatrist");
    JLabel surgeonLabel = new JLabel("Surgeon");
    JLabel researcherLabel = new JLabel("Researcher");
    JLabel skillLabel = new JLabel("Skill");
    JTextField skillTF = new JTextField("50", 5);

}
