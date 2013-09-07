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

import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

/**
 * The main entry point of the Level Editor that simply sets the L&F and starts
 * the {@link Gui}. The source file also contains a list of TODOs for the
 * project.
 * 
 * @author Koanxd
 * 
 */
public class Main {
    public static final double VERSION = 0.14;

    public static void main(String[] args) {
        try {
            // Set System L&F
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (UnsupportedLookAndFeelException e) {
            // handle exception
        } catch (ClassNotFoundException e) {
            // handle exception
        } catch (InstantiationException e) {
            // handle exception
        } catch (IllegalAccessException e) {
            // handle exception
        }
        Gui gui = new Gui();
        gui.setVisible(true);

        VarManipulator variableManipulator = new VarManipulator();
        variableManipulator.setDefault();
        variableManipulator.setAllDiseasesAvailable();
    }
}

/*
 * TODO known issues file can be saved without any file extension on exit > save
 * > cancel, the program should not close.
 * 
 * TODO improvements TabEmergencies: it should not be possible to choose
 * non-existant diseases TabDiseases: if disease is set to non-existant, set the
 * other fields to uneditable. textfields: option to reset to default
 * individually give warning when there is no way a disease can be cured. should
 * only ask for saving changes on exit if changes have been made. show current
 * file on the window title save function (not save as) save documentation to
 * file? error handling multilingual support (priority: disease names)
 * 
 * TODO testing compatibility with sam files why do the sam files have values
 * other than 0 or 1 for #visuals / #non_visuals? does it affect the frequency
 * of each disease? is it implemented in CTH yet? TabStaff: do the staff
 * distribution entries have to be chronological?
 */