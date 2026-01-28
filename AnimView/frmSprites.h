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

#ifndef ANIMVIEW_FRMSPRITES_H_
#define ANIMVIEW_FRMSPRITES_H_

#include "config.h"

#include <wx/bitmap.h>
#include <wx/defs.h>
#include <wx/event.h>
#include <wx/frame.h>
#include <wx/string.h>
#include <wx/types.h>
#include <wx/vscroll.h>

#include <vector>

#include "th.h"

class wxTextCtrl;
class wxWindow;

static const int ROW_COUNT = 1000;

// Derived class to add scrollbars to the window.
class MyVScrolled : public wxVScrolledWindow {
 public:
  MyVScrolled(wxWindow* parent) : wxVScrolledWindow(parent, wxID_ANY) {
    iMyCount = ROW_COUNT;
  }

  wxCoord OnGetRowHeight(size_t row) const override { return 1; }

  wxCoord EstimateTotalHeight() const override { return iMyCount; }

  int iMyCount;
};

class frmSprites : public wxFrame {
 public:
  frmSprites();
  ~frmSprites() override = default;

  enum {
    ID_LOAD = wxID_HIGHEST + 1,
    ID_BROWSE_TABLE,
    ID_BROWSE_DATA,
    ID_BROWSE_PALETTE,
    ID_LOAD_COMPLEX,
    ID_NEXT,
  };

  void load(bool bComplex);

 protected:
  struct _sprite_t {
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
  DECLARE_EVENT_TABLE()
};

#endif
