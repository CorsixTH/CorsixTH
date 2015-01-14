/*
Copyright (c) 2009 Peter "Corsix" Cawley

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

#pragma once
#include <wx/bitmap.h>
#include <wx/frame.h>
#include <wx/button.h>
#include <wx/checkbox.h>
#include <wx/textctrl.h>
#include <wx/panel.h>
#include <wx/timer.h>
#include <wx/listbox.h>
#include <wx/vscroll.h>
#include "th.h"
#include <vector>

static const int ROW_COUNT = 1000;

// Derived class to add scrollbars to the window.
class MyVScrolled : public wxVScrolledWindow {
public:
    MyVScrolled(wxWindow *parent) : wxVScrolledWindow(parent, wxID_ANY) { iMyCount = ROW_COUNT; }

    wxCoord OnGetRowHeight(size_t  row) const { return 1; }

    wxCoord EstimateTotalHeight() const { return iMyCount; }

    int iMyCount;
};

class frmSprites : public wxFrame
{
public:
    frmSprites();
    ~frmSprites();

    enum
    {
        ID_LOAD = wxID_HIGHEST + 1,
        ID_BROWSE_TABLE,
        ID_BROWSE_DATA,
        ID_BROWSE_PALETTE,
        ID_LOAD_COMPLEX,
        ID_NEXT,
    };

    void load(bool bComplex);
protected:
    struct _sprite_t
    {
        wxBitmap bitmap;
        wxString caption;
    };

    void _onNext(wxCommandEvent& evt);
    void _onLoad(wxCommandEvent& evt);
    void _onLoadComplex(wxCommandEvent& evt);
    void _onPanelPaint(wxPaintEvent& evt);
    void _onBrowseData(wxCommandEvent& evt);
    void _onBrowsePalette(wxCommandEvent& evt);
    void _onBrowseTable(wxCommandEvent& evt);

    std::vector<_sprite_t> m_vSprites;
    THAnimations m_oAnims;

    wxTextCtrl* m_txtTable;
    wxTextCtrl* m_txtData;
    wxTextCtrl* m_txtPalette;
    MyVScrolled* m_panFrame;
    DECLARE_EVENT_TABLE();
};
