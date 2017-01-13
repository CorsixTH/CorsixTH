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

import java.awt.Image;
import java.awt.Toolkit;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JOptionPane;

/**
 * Create menu and tabBar, set window size, location and on-exit-behaviour.
 * 
 * @author Koanxd
 * 
 */
public class Gui extends JFrame {

    // this is insignificant but apparently its needed because JFrame is
    // serializable
    private static final long serialVersionUID = 5696773542922343319L;

    // this string is changed on every focusGained event.
    static String tempValue = "";

    ReaderWriter readerWriter = new ReaderWriter();
    FileChooser fileChooser = new FileChooser(this);

    public Gui() {
        List<Image> icons = new ArrayList<>();
        icons.add(Toolkit.getDefaultToolkit().getImage(
                ClassLoader.getSystemResource("icon256.png")));
        icons.add(Toolkit.getDefaultToolkit().getImage(
                ClassLoader.getSystemResource("icon128.png")));
        icons.add(Toolkit.getDefaultToolkit().getImage(
                ClassLoader.getSystemResource("icon64.png")));
        icons.add(Toolkit.getDefaultToolkit().getImage(
                ClassLoader.getSystemResource("icon48.png")));
        icons.add(Toolkit.getDefaultToolkit().getImage(
                ClassLoader.getSystemResource("icon32.png")));
        icons.add(Toolkit.getDefaultToolkit().getImage(
                ClassLoader.getSystemResource("icon24.png")));
        icons.add(Toolkit.getDefaultToolkit().getImage(
                ClassLoader.getSystemResource("icon16.png")));
        setIconImages(icons);

        setTitle("CorsixTH Level Editor");

        setSize(800, 600);
        setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
        addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent event) {
                onExit();
            }
        });

        // set location to center
        setLocationRelativeTo(null);

        // The JFrame is just used to get our icon in the filechooser.
        setJMenuBar(new Menu(this));

        setContentPane(new TabBar());
    }

    /**
     * Gives the user a chance to save any changes before exiting.
     */
    protected void onExit() {
        JOptionPane exit = new JOptionPane("Would you like to save your level?");
        Object[] options = new String[] { "Save", "Don't save", "Cancel" };
        exit.setOptions(options);

        JDialog exitDialog = exit.createDialog(this, "Exit");
        exitDialog.setVisible(true);

        if (exit.getValue() == options[0]) {
            try {
                File file = (fileChooser.saveAs());
                if (file != null) {
                    readerWriter.saveAs(file);
                    System.exit(0);
                }
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        } else if (exit.getValue() == options[1]) {
            System.exit(0);
        }

    }

}
