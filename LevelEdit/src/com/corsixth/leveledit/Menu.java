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
import java.io.File;
import java.io.IOException;

import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;

//creates FileChooser, MenuItems, JMenu
public class Menu extends JMenuBar {

    // this is insignificant but apparently its needed because JFrame is
    // serializable
    private static final long serialVersionUID = 5339035000069193766L;

    ReaderWriter readerWriter = new ReaderWriter();
    VarManipulator var = new VarManipulator();
    FileChooser fileChooser;

    JMenuItem fileNew = new JMenuItem("New");
    JMenuItem fileOpen = new JMenuItem("Open");
    // JMenuItem fileSave = new JMenuItem("Save");
    JMenuItem fileSaveAs = new JMenuItem("Save As");

    JMenuItem about = new JMenuItem("About");

    public Menu(JFrame frame) {
        JMenu menuFile = new JMenu("File");
        menuFile.add(fileNew);
        menuFile.add(fileOpen);
        // menuFile.add(fileSave);
        menuFile.add(fileSaveAs);

        JMenu menuHelp = new JMenu("Help");
        menuHelp.add(about);

        fileChooser = new FileChooser(frame);
        

        // new
        fileNew.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                var.setDefault();
                var.setAllDiseasesAvailable();
            }
        });

        // open
        fileOpen.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

                File file = (fileChooser.open());
                if (file != null) {
                    if (!file.getPath().toLowerCase().endsWith(".level")) {
                        JOptionPane optionPane = new JOptionPane(
                                "This file type is not "
                                        + "fully supported. Proceed anyway?");
                        Object[] options = new String[] { "Ok", "Cancel" };
                        optionPane.setOptions(options);

                        JDialog dialog = optionPane.createDialog(null,
                                "Warning");
                        dialog.setVisible(true);

                        if (optionPane.getValue() == options[1])
                            return;
                    }
                    // set all variables to default first in case some values
                    // are missing inside the file.
                    var.setDefault();
                    readerWriter.open(file);
                }
            }
        });

        // save as
        fileSaveAs.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                try {
                    File file = (fileChooser.saveAs());
                    if (file != null)
                        readerWriter.saveAs(file);
                } catch (IOException e1) {
                    // TODO Auto-generated catch block
                    e1.printStackTrace();
                }
            }
        });

        about.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                JOptionPane aboutPane = new JOptionPane("Version: "
                        + Main.VERSION + "\n\n"
                        + "Programmers: snowblind aka koanxd\n"
                        + "Logo Artist: Wolter\n");
                Object[] options = new String[] { "Ok" };
                aboutPane.setOptions(options);

                JDialog dialog = aboutPane.createDialog(null, "About");
                dialog.setVisible(true);
            }
        });

        add(menuFile);
        add(menuHelp);
    }
}
