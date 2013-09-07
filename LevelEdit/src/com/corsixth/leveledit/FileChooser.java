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

import java.io.File;
import java.io.IOException;

import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.filechooser.FileNameExtensionFilter;

/**
 * A custom JFileChooser
 * 
 * @author Koanxd
 * 
 */
public class FileChooser extends JFileChooser {

    // this is insignificant but apparently its needed because JFrame is
    // serializable
    private static final long serialVersionUID = 2153326271573582591L;

    ReaderWriter readerWriter = new ReaderWriter();

    FileNameExtensionFilter corsixTH = new FileNameExtensionFilter(
            "CorsixTH level files (.level)", "level");
    FileNameExtensionFilter originalTH = new FileNameExtensionFilter(
            "Theme Hospital Level files (.SAM)", "SAM");

    // Used to get the CorsixTH icon in the top bar of the dialog.
    JFrame mainFrame;

    public FileChooser(JFrame frame) {
        setCurrentDirectory(readerWriter.getLastFilePath());
        setFileFilter(corsixTH);
        mainFrame = frame;
    }

    public File open() {
        addChoosableFileFilter(originalTH);
        setAcceptAllFileFilterUsed(true);
        int returnVal = showOpenDialog(mainFrame);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
            readerWriter.saveLastFilePath(getSelectedFile().getPath());
            return getSelectedFile();
        } else {
            return null;
        }
    }

    public File saveAs() throws IOException {
        removeChoosableFileFilter(originalTH);
        setAcceptAllFileFilterUsed(false);
        setFileFilter(corsixTH);
        int returnVal = showSaveDialog(mainFrame);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
            File file = getSelectedFile();
            readerWriter.saveLastFilePath(file.getPath());

            if (file.exists()) {
                // confirm to overwrite file
                JOptionPane overwrite = new JOptionPane("Overwrite file?");
                Object[] options = new String[] { "Yes", "No" };
                overwrite.setOptions(options);

                JDialog dialog = overwrite.createDialog(null, "Confirm");
                dialog.setVisible(true);

                if ((overwrite.getValue()) == options[0])
                    return (getSelectedFile());
                else
                    return null;

            } else {
                // if no file extension is given, append one.
                if (!file.getPath().endsWith(".level")) {
                    file = new File(file.getPath() + ".level");
                }
                return file;
            }
        } else {
            return null;
        }
    }
}
