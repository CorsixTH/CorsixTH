/*
Copyright (c) 2013 Edvin "Lego3" Linge

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

import java.awt.Component;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.util.ArrayList;

import javax.swing.BorderFactory;
import javax.swing.JPanel;

/**
 * A panel that uses the GridBagLayout to layout its components. This is a
 * rudimentary implementation tailored for the LevelEdit project. It supplies
 * similar functionality as MigLayout, but only the parts we need. The
 * constructor takes a column argument that specifies the number of columns used
 * in the grid. Each added component is put at the end of the grid left to
 * right, top to bottom.
 * 
 * @author Edvin "Lego3" Linge
 * 
 */
public class GridPanel extends JPanel {

    private static final long serialVersionUID = 6388650541048165610L;
    private static final int INSETS = 2;
    private static final int BORDER = 3;

    private int columns = 0;
    private int rows = 0;

    private GridBagConstraints c = new GridBagConstraints();

    // Used to add a dummy JPanel to the end so that we can achieve top left
    // alignment.
    private GridBagConstraints fillerC = new GridBagConstraints();

    private JPanel panelFiller = new JPanel();

    private ArrayList<Component>[] contents;

    @SuppressWarnings("unchecked")
    public GridPanel(int noColumns) {
        c.insets = new Insets(INSETS, INSETS, INSETS, INSETS);
        c.gridx = 0;
        c.gridy = 0;
        c.anchor = GridBagConstraints.WEST;
        columns = noColumns;

        fillerC.gridx = 1;
        fillerC.gridy = 1;
        fillerC.weighty = 1;
        fillerC.weightx = 1;

        setBorder(BorderFactory.createEmptyBorder(BORDER, BORDER, BORDER,
                BORDER));
        setLayout(new GridBagLayout());

        contents = (ArrayList<Component>[]) new ArrayList[noColumns];
        for (int i = 0; i < noColumns; i++) {
            contents[i] = new ArrayList<Component>();
        }
    }

    /**
     * Set insets in all directions to 'inset' all for each object added in the
     * future.
     * 
     * @param inset
     *            Inset to use in all directions.
     */
    public void setInsets(int inset) {
        setInsets(inset, inset, inset, inset);
    }

    /**
     * Set insets in each direction according to the parameters, will be used
     * for all objects added to the JGridPanel from this point onwards.
     * 
     * @param top
     *            Top inset value
     * @param left
     *            Left inset value
     * @param bottom
     *            Bottom inset value
     * @param right
     *            Right inset value
     */
    public void setInsets(int top, int left, int bottom, int right) {
        c.insets = new Insets(top, left, bottom, right);
    }

    @Override
    public Component add(Component comp) {
        super.remove(panelFiller);
        contents[c.gridx].add(comp);
        add(comp, c);
        next();
        add(panelFiller, fillerC);

        return comp;
    }

    /**
     * Adds a new component to the container and advances one row i newRow is
     * true. If the component is added to the last column in the current row the
     * advancement is still only one row.
     * 
     * @param comp
     *            Component to add.
     * @param newRow
     *            Whether to advance one row after adding the new component.
     * @return
     */
    public Component add(Component comp, boolean newRow) {
        int row = rows;
        add(comp);
        if (row == rows && newRow) {
            nextRow();
        }
        return comp;
    }

    @Override
    public void remove(Component comp) {
        boolean found = false;
        for (int i = 0; i < columns; i++) {
            int index = contents[i].indexOf(comp);
            if (index != -1) {
                super.remove(comp);
                contents[i].remove(comp);
                found = true;
                break;
            }
        }
        if (found) {
            int max = 0;
            for (int i = 0; i < columns; i++) {
                max = Math.max(max, contents[i].size());
            }
            if (max <= rows) {
                removeRow();
            }
        }
    }

    /**
     * Finds the oldComp in the grid of added components and swaps it for the
     * newComp.
     * 
     * @param oldComp
     * @param newComp
     */
    public void swap(Component oldComp, Component newComp) {
        for (int i = 0; i < columns; i++) {
            int index = contents[i].indexOf(oldComp);
            if (index != -1) {
                contents[i].remove(index);
                contents[i].add(index, newComp);
                super.remove(oldComp);
                int tempX = c.gridx;
                int tempY = c.gridy;
                c.gridx = i;
                c.gridy = index;
                add(newComp);
                c.gridx = tempX;
                c.gridy = tempY;
                break;
            }
        }
    }

    /**
     * Skips 'times' cells in the grid so that the next component will be added furhter down.
     * @param times how many cells to skip.
     */
    public void next(int times) {
        for (int i = 0; i < times; i++) {
            next();
        }
    }

    /**
     * Skips one cell in the grid.
     */
    public void next() {
        c.gridx++;
        if (c.gridx >= columns) {
            nextRow();
        }
        fillerC.gridx = columns + 1;
        fillerC.gridy = c.gridy + 1;
    }

    /**
     * Advances the layout one row so that the next added component will be on a new one.
     */
    public void nextRow() {
        c.gridx = 0;
        c.gridy++;
        rows++;
    }

    private void removeRow() {
        c.gridx = 0;
        c.gridy--;
        rows--;
    }

}
