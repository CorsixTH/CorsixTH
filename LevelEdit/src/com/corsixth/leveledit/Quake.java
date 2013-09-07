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

import javax.swing.JPanel;
import javax.swing.JTextField;

public class Quake {
    static final int START_MONTH = 6;
    static final int END_MONTH = 18;
    static final int SEVERITY = 1;

    int startMonth = START_MONTH;
    int endMonth = END_MONTH;
    int severity = SEVERITY;

    JPanel quakePanel = new JPanel();

    JTextField startMonthTF = new JTextField(Integer.toString(startMonth), 2);
    JTextField endMonthTF = new JTextField(Integer.toString(endMonth), 2);
    JTextField severityTF = new JTextField(Integer.toString(severity), 2);
}
