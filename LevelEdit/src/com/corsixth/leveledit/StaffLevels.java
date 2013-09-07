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

import javax.swing.JLabel;
import javax.swing.JTextField;

public class StaffLevels {
    int month = 0;
    int nurses = 8;
    int doctors = 8;
    int handymen = 3;
    int receptionists = 2;
    int shrinkRate = 10;
    int surgeonRate = 10;
    int researcherRate = 10;
    int consultantRate = 10;
    int juniorRate = 5;

    GridPanel staffLevelsPanel = new GridPanel(10);

    JLabel monthLabel = new JLabel("Starting from month:");
    JLabel nursesLabel = new JLabel("Nurses:");
    JLabel doctorsLabel = new JLabel("Doctors:");
    JLabel handymenLabel = new JLabel("Handymen:");
    JLabel receptionistsLabel = new JLabel("Receptionists:");
    JLabel shrinkRateLabel = new JLabel("Psychiatrist chance:");
    JLabel surgeonRateLabel = new JLabel("Surgeon chance:");
    JLabel researcherRateLabel = new JLabel("Researcher chance:");
    JLabel consultantRateLabel = new JLabel("Consultant chance:");
    JLabel juniorRateLabel = new JLabel("Junior chance:");

    JTextField monthTF = new JTextField("0", 3);
    JTextField nursesTF = new JTextField("8", 3);
    JTextField doctorsTF = new JTextField("8", 3);
    JTextField handymenTF = new JTextField("3", 3);
    JTextField receptionistsTF = new JTextField("2", 3);
    JTextField shrinkRateTF = new JTextField("1/10", 3);
    JTextField surgeonRateTF = new JTextField("1/10", 3);
    JTextField researcherRateTF = new JTextField("1/10", 3);
    JTextField consultantRateTF = new JTextField("1/10", 3);
    JTextField juniorRateTF = new JTextField("1/5", 3);

}
