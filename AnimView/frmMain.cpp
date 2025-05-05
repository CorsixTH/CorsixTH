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

#include "frmMain.h"

#include "config.h"

#include <wx/bitmap.h>
#include <wx/dcclient.h>
#include <wx/dcmemory.h>
#include <wx/defs.h>
#include <wx/dir.h>
#include <wx/dirdlg.h>
#include <wx/filename.h>
#include <wx/image.h>
#include <wx/msgdlg.h>
#include <wx/numdlg.h>
#include <wx/radiobut.h>
#include <wx/sizer.h>
#include <wx/stattext.h>
#include <wx/tokenzr.h>
#include <wx/wfstream.h>
#include <regex>

#include "backdrop.h"

BEGIN_EVENT_TABLE(frmMain, wxFrame)
  EVT_BUTTON(ID_LOAD, frmMain::_onLoad)
  EVT_BUTTON(ID_BROWSE, frmMain::_onBrowse)
  EVT_BUTTON(ID_FIRST_ANIM, frmMain::_onFirstAnim)
  EVT_BUTTON(ID_PREV_ANIM, frmMain::_onPrevAnim)
  EVT_BUTTON(ID_NEXT_ANIM, frmMain::_onNextAnim)
  EVT_BUTTON(ID_LAST_ANIM, frmMain::_onLastAnim)
  EVT_BUTTON(ID_PREV_FRAME, frmMain::_onPrevFrame)
  EVT_BUTTON(ID_NEXT_FRAME, frmMain::_onNextFrame)
  EVT_BUTTON(ID_PLAY_PAUSE, frmMain::_onPlayPause)
  EVT_BUTTON(ID_SEARCH_LAYER_ID, frmMain::_onSearchLayerId)
  EVT_BUTTON(ID_SEARCH_FRAME, frmMain::_onSearchFrame)
  EVT_BUTTON(ID_SEARCH_SOUND, frmMain::_onSearchSoundIndex)
  EVT_LISTBOX(ID_SEARCH_RESULTS, frmMain::_onAnimChar)
  EVT_RADIOBUTTON(ID_GHOST_0, frmMain::_onGhostFileChange)
  EVT_RADIOBUTTON(ID_GHOST_1, frmMain::_onGhostFileChange)
  EVT_RADIOBUTTON(ID_GHOST_2, frmMain::_onGhostFileChange)
  EVT_RADIOBUTTON(ID_GHOST_3, frmMain::_onGhostFileChange)
  EVT_SPINCTRL(wxID_ANY, frmMain::_onGhostIndexChange)
  EVT_TEXT(ID_ANIM_INDEX, frmMain::_onAnimChar)
  EVT_TIMER(ID_TIMER_ANIMATE, frmMain::_onTimer)
  EVT_CHECKBOX(ID_DRAW_MOOD, frmMain::_onToggleDrawMood)
  EVT_CHECKBOX(ID_DRAW_COORDINATES, frmMain::_onToggleDrawCoordinates)
  EVT_BUTTON(ID_MOOD_FRAME, frmMain::_onMoodFrameApply)
  EVT_BUTTON(ID_MOOD_LEFT, frmMain::_onMoodLeft)
  EVT_BUTTON(ID_MOOD_RIGHT, frmMain::_onMoodRight)
  EVT_BUTTON(ID_MOOD_UP, frmMain::_onMoodUp)
  EVT_BUTTON(ID_MOOD_DOWN, frmMain::_onMoodDown)
END_EVENT_TABLE()

namespace {
constexpr int make_id(int layer, int id) {
  return frmMain::ID_LAYER_CHECKS + (layer * 25) + id;
}
}  // namespace

frmMain::frmMain()
    : wxFrame(nullptr, wxID_ANY, L"Theme Hospital Animation Viewer") {
  wxSizer* pMainSizer = new wxBoxSizer(wxHORIZONTAL);

  wxSizer* pSidebarSizer = new wxBoxSizer(wxVERTICAL);

  wxSizerFlags fillSizerFlags(0);
  fillSizerFlags.Expand().Border(wxALL, 0);

  wxSizerFlags fillBorderSizerFlags(0);
  fillBorderSizerFlags.Expand().Border(wxALL, 1);

  wxSizerFlags buttonSizerFlags(0);
  buttonSizerFlags.Align(wxALIGN_CENTER_VERTICAL).Border(wxALL, 1);

  wxStaticBoxSizer* pThemeHospital =
      new wxStaticBoxSizer(wxHORIZONTAL, this, L"Theme Hospital");
  pThemeHospital->Add(
      new wxStaticText(this, wxID_ANY, L"Directory:"),
      wxSizerFlags(0).Align(wxALIGN_CENTER_VERTICAL).Border(wxALL, 1));
  pThemeHospital->Add(
      m_txtTHPath = new wxTextCtrl(this, wxID_ANY, L"", wxDefaultPosition,
                                   wxDefaultSize, wxTE_CENTRE),
      wxSizerFlags(1).Align(wxALIGN_CENTER_VERTICAL).Border(wxALL, 1));
  pThemeHospital->Add(new wxButton(this, ID_BROWSE, L"Browse..."),
                      buttonSizerFlags);
  pThemeHospital->Add(new wxButton(this, ID_LOAD, L"Load"), buttonSizerFlags);
  pSidebarSizer->Add(pThemeHospital, fillSizerFlags);

  wxStaticBoxSizer* pPalette =
      new wxStaticBoxSizer(wxVERTICAL, this, L"Palette");
  wxBoxSizer* pPaletteTop = new wxBoxSizer(wxHORIZONTAL);
  pPaletteTop->Add(new wxRadioButton(this, ID_GHOST_0, L"Standard"), 1);
  pPaletteTop->Add(new wxRadioButton(this, ID_GHOST_1, L"Ghost 1"), 1);
  pPaletteTop->Add(new wxRadioButton(this, ID_GHOST_2, L"Ghost 2"), 1);
  pPaletteTop->Add(new wxRadioButton(this, ID_GHOST_3, L"Ghost 66"), 1);
  m_iGhostFile = 0;
  m_iGhostIndex = 0;
  pPalette->Add(pPaletteTop, fillBorderSizerFlags);
  pPalette->Add(
      new wxSpinCtrl(this, wxID_ANY, wxEmptyString, wxDefaultPosition,
                     wxDefaultSize, wxSP_ARROW_KEYS | wxSP_WRAP, 0, 255),
      wxSizerFlags(0).Center().Border(wxALL, 1));
  pSidebarSizer->Add(pPalette, fillSizerFlags);

  wxStaticBoxSizer* pAnimation =
      new wxStaticBoxSizer(wxHORIZONTAL, this, L"Animation");
  pAnimation->Add(new wxButton(this, ID_FIRST_ANIM, L"<<", wxDefaultPosition,
                               wxDefaultSize, wxBU_EXACTFIT),
                  buttonSizerFlags);
  pAnimation->Add(new wxButton(this, ID_PREV_ANIM, L"<", wxDefaultPosition,
                               wxDefaultSize, wxBU_EXACTFIT),
                  buttonSizerFlags);
  m_txtAnimIndex = new wxTextCtrl(this, ID_ANIM_INDEX, L"0", wxDefaultPosition,
                                  wxDefaultSize, wxTE_CENTRE);
  pAnimation->Add(
      m_txtAnimIndex,
      wxSizerFlags(1).Align(wxALIGN_CENTER_VERTICAL).Border(wxALL, 1));
  pAnimation->Add(
      new wxStaticText(this, wxID_ANY, L"of"),
      wxSizerFlags(0).Align(wxALIGN_CENTER_VERTICAL).Border(wxALL, 1));
  m_txtAnimCount = new wxTextCtrl(this, wxID_ANY, L"?", wxDefaultPosition,
                                  wxDefaultSize, wxTE_CENTRE | wxTE_READONLY);
  pAnimation->Add(
      m_txtAnimCount,
      wxSizerFlags(1).Align(wxALIGN_CENTER_VERTICAL).Border(wxALL, 1));
  pAnimation->Add(new wxButton(this, ID_NEXT_ANIM, L">", wxDefaultPosition,
                               wxDefaultSize, wxBU_EXACTFIT),
                  buttonSizerFlags);
  pAnimation->Add(new wxButton(this, ID_LAST_ANIM, L">>", wxDefaultPosition,
                               wxDefaultSize, wxBU_EXACTFIT),
                  buttonSizerFlags);
  pSidebarSizer->Add(pAnimation, fillSizerFlags);

  wxStaticBoxSizer* pFrame = new wxStaticBoxSizer(wxHORIZONTAL, this, L"Frame");
  pFrame->Add(new wxButton(this, ID_PREV_FRAME, L"<", wxDefaultPosition,
                           wxDefaultSize, wxBU_EXACTFIT),
              buttonSizerFlags);
  pFrame->Add(
      m_txtFrameIndex = new wxTextCtrl(this, wxID_ANY, L"0", wxDefaultPosition,
                                       wxDefaultSize, wxTE_CENTRE),
      wxSizerFlags(1).Align(wxALIGN_CENTER_VERTICAL).Border(wxALL, 1));
  pFrame->Add(new wxStaticText(this, wxID_ANY, L"of", wxDefaultPosition,
                               wxDefaultSize, wxALIGN_CENTRE),
              wxSizerFlags(0).Align(wxALIGN_CENTER_VERTICAL).Border(wxALL, 1));
  m_txtFrameCount = new wxTextCtrl(this, wxID_ANY, L"?", wxDefaultPosition,
                                   wxDefaultSize, wxTE_CENTRE | wxTE_READONLY);
  pFrame->Add(m_txtFrameCount,
              wxSizerFlags(1).Align(wxALIGN_CENTER_VERTICAL).Border(wxALL, 1));
  pFrame->Add(new wxButton(this, ID_NEXT_FRAME, L">", wxDefaultPosition,
                           wxDefaultSize, wxBU_EXACTFIT),
              buttonSizerFlags);
  m_btnPlayPause = new wxButton(this, ID_PLAY_PAUSE, L"Pause");
  pFrame->Add(m_btnPlayPause,
              wxSizerFlags(1).Align(wxALIGN_CENTER_VERTICAL).Border(wxALL, 1));
  m_bPlayingAnimation = true;
  // m_bPlayingAnimation = false;
  pSidebarSizer->Add(pFrame, fillSizerFlags);

  wxSizerFlags layerSizerFlags(0);
  layerSizerFlags.Align(wxALIGN_CENTER).Border(wxALL, 1);

  wxStaticBoxSizer* pLayer0 =
      new wxStaticBoxSizer(wxHORIZONTAL, this, L"Layer 0 (Patient Head)");
  pLayer0->Add(new wxCheckBox(this, make_id(0, 0), L"0"), layerSizerFlags);
  pLayer0->Add(new wxCheckBox(this, make_id(0, 2), L"2"), layerSizerFlags);
  pLayer0->Add(new wxCheckBox(this, make_id(0, 4), L"4"), layerSizerFlags);
  pLayer0->Add(new wxCheckBox(this, make_id(0, 6), L"6"), layerSizerFlags);
  pLayer0->Add(new wxCheckBox(this, make_id(0, 8), L"8"), layerSizerFlags);
  pLayer0->Add(new wxCheckBox(this, make_id(0, 10), L"10"), layerSizerFlags);
  pLayer0->Add(new wxCheckBox(this, make_id(0, 12), L"12"), layerSizerFlags);
  pLayer0->Add(new wxCheckBox(this, make_id(0, 14), L"14"), layerSizerFlags);
  pLayer0->Add(new wxCheckBox(this, make_id(0, 16), L"16"), layerSizerFlags);
  pLayer0->Add(new wxCheckBox(this, make_id(0, 18), L"18"), layerSizerFlags);
  pLayer0->Add(new wxCheckBox(this, make_id(0, 20), L"20"), layerSizerFlags);
  pLayer0->Add(new wxCheckBox(this, make_id(0, 22), L"22"), layerSizerFlags);
  pSidebarSizer->Add(pLayer0, fillSizerFlags);

  wxStaticBoxSizer* pLayer1 =
      new wxStaticBoxSizer(wxHORIZONTAL, this, L"Layer 1 (Patient Clothes)");
  pLayer1->Add(new wxCheckBox(this, make_id(1, 0), L"0"), layerSizerFlags);
  pLayer1->Add(new wxCheckBox(this, make_id(1, 2), L"2 (A)"), layerSizerFlags);
  pLayer1->Add(new wxCheckBox(this, make_id(1, 4), L"4 (B)"), layerSizerFlags);
  pLayer1->Add(new wxCheckBox(this, make_id(1, 6), L"6 (C)"), layerSizerFlags);
  pLayer1->Add(new wxCheckBox(this, make_id(1, 8), L"8"), layerSizerFlags);
  pLayer1->Add(new wxCheckBox(this, make_id(1, 10), L"10"), layerSizerFlags);
  pSidebarSizer->Add(pLayer1, fillSizerFlags);

  wxStaticBoxSizer* pLayer2 = new wxStaticBoxSizer(
      wxHORIZONTAL, this, L"Layer 2 (Bandages / Patient Accessory)");
  pLayer2->Add(new wxCheckBox(this, make_id(2, 2), L"2 (Head / Alt Shoes)"),
               layerSizerFlags);
  pLayer2->Add(new wxCheckBox(this, make_id(2, 4), L"4 (Arm / Hat)"),
               layerSizerFlags);
  pLayer2->Add(new wxCheckBox(this, make_id(2, 6), L"6"), layerSizerFlags);
  pSidebarSizer->Add(pLayer2, fillSizerFlags);

  wxStaticBoxSizer* pLayer3 =
      new wxStaticBoxSizer(wxHORIZONTAL, this, L"Layer 3 (Bandages / Colour)");
  pLayer3->Add(new wxCheckBox(this, make_id(3, 0), L"0"), layerSizerFlags);
  pLayer3->Add(new wxCheckBox(this, make_id(3, 2), L"2 (? / Yellow)"),
               layerSizerFlags);
  pLayer3->Add(new wxCheckBox(this, make_id(3, 4), L"4 (L Foot / Blue)"),
               layerSizerFlags);
  pLayer3->Add(new wxCheckBox(this, make_id(3, 6), L"6 (? / White)"),
               layerSizerFlags);
  pLayer3->Add(new wxCheckBox(this, make_id(3, 8), L"8 (R Arm)"),
               layerSizerFlags);
  pLayer3->Add(new wxCheckBox(this, make_id(3, 10), L"10 (R Foot)"),
               layerSizerFlags);
  pSidebarSizer->Add(pLayer3, fillSizerFlags);

  wxStaticBoxSizer* pLayer4 =
      new wxStaticBoxSizer(wxHORIZONTAL, this, L"Layer 4 (Bandages / Repair)");
  pLayer4->Add(new wxCheckBox(this, make_id(4, 0), L"0"), layerSizerFlags);
  pLayer4->Add(new wxCheckBox(this, make_id(4, 2), L"2 (Head / Repair)"),
               layerSizerFlags);
  pLayer4->Add(new wxCheckBox(this, make_id(4, 4), L"4 (L Root)"),
               layerSizerFlags);
  pLayer4->Add(new wxCheckBox(this, make_id(4, 6), L"6"), layerSizerFlags);
  pLayer4->Add(new wxCheckBox(this, make_id(4, 8), L"8 (R Arm)"),
               layerSizerFlags);
  pLayer4->Add(new wxCheckBox(this, make_id(4, 10), L"10 (R Foot)"),
               layerSizerFlags);
  pSidebarSizer->Add(pLayer4, fillSizerFlags);

  wxStaticBoxSizer* pLayer5 =
      new wxStaticBoxSizer(wxHORIZONTAL, this, L"Layer 5 (Staff Head)");
  pLayer5->Add(new wxCheckBox(this, make_id(5, 0), L"0"), layerSizerFlags);
  pLayer5->Add(new wxCheckBox(this, make_id(5, 2), L"2 (W1)"), layerSizerFlags);
  pLayer5->Add(new wxCheckBox(this, make_id(5, 4), L"4 (B1)"), layerSizerFlags);
  pLayer5->Add(new wxCheckBox(this, make_id(5, 6), L"6 (W2)"), layerSizerFlags);
  pLayer5->Add(new wxCheckBox(this, make_id(5, 8), L"8 (B2)"), layerSizerFlags);
  pLayer5->Add(new wxCheckBox(this, make_id(5, 10), L"10"), layerSizerFlags);
  pSidebarSizer->Add(pLayer5, fillSizerFlags);

  wxStaticBoxSizer* pLayer10 = new wxStaticBoxSizer(
      wxHORIZONTAL, this, L"Layer 10 (Wall Colour / Smoke)");
  pLayer10->Add(new wxCheckBox(this, make_id(10, 2), L"2 (Yellow / Smoke)"),
                layerSizerFlags);
  pLayer10->Add(new wxCheckBox(this, make_id(10, 4), L"4 (Blue)"),
                layerSizerFlags);
  pLayer10->Add(new wxCheckBox(this, make_id(10, 6), L"6 (White)"),
                layerSizerFlags);
  pSidebarSizer->Add(pLayer10, fillSizerFlags);

  wxStaticBoxSizer* pLayer11 = new wxStaticBoxSizer(
      wxHORIZONTAL, this, L"Layer 11 (Wall Colour / Smoke / Screen)");
  pLayer11->Add(
      new wxCheckBox(this, make_id(11, 2), L"2 (Yellow / Smoke / On)"),
      layerSizerFlags);
  pLayer11->Add(new wxCheckBox(this, make_id(11, 4), L"4 (Blue)"),
                layerSizerFlags);
  pLayer11->Add(new wxCheckBox(this, make_id(11, 6), L"6 (Green)"),
                layerSizerFlags);
  pSidebarSizer->Add(pLayer11, fillSizerFlags);

  wxStaticBoxSizer* pLayer12 =
      new wxStaticBoxSizer(wxHORIZONTAL, this, L"Layer 12 (Smoke)");
  pLayer12->Add(new wxCheckBox(this, make_id(12, 2), L"2 (Smoke)"),
                layerSizerFlags);
  pSidebarSizer->Add(pLayer12, fillSizerFlags);

  wxStaticBoxSizer* pMoodOverlay =
      new wxStaticBoxSizer(wxVERTICAL, this, L"Overlays");
  pMoodOverlay->Add(new wxCheckBox(this, ID_DRAW_MOOD, L"Draw mood overlay"),
                    fillBorderSizerFlags);
  wxBoxSizer* pMoodRow = new wxBoxSizer(wxHORIZONTAL);
  pMoodRow->Add(
      new wxStaticText(this, wxID_ANY, L"Marker position (click to move it):"),
      wxSizerFlags(0).Expand().Border(wxRIGHT, 2));
  pMoodRow->Add(
      m_txtMoodPosition[0] = new wxTextCtrl(this, wxID_ANY, L"{0, 0}"),
      wxSizerFlags(1).Expand().Border(wxRIGHT, 1));
  pMoodRow->Add(
      m_txtMoodPosition[1] = new wxTextCtrl(this, wxID_ANY, L"{0, 0, \"px\"}"),
      wxSizerFlags(1).Expand());
  pMoodOverlay->Add(pMoodRow, wxSizerFlags(1).Expand().Border(wxALL, 2));

  wxSizerFlags moodAdjustFlags(0);
  moodAdjustFlags.Align(wxALIGN_CENTER).Border(wxALL, 1);

  layerSizerFlags.Align(wxALIGN_CENTER).Border(wxALL, 1);
  wxBoxSizer* pMoodAdjustRow = new wxBoxSizer(wxHORIZONTAL);
  m_txtMoodFramePos = new wxTextCtrl(this, ID_MOOD_POS, L"{0.0, 0.0}",
                                     wxDefaultPosition, wxDefaultSize,
                                     wxTE_CENTRE);
  pMoodAdjustRow->Add(m_txtMoodFramePos, wxSizerFlags(1).Expand());
  pMoodAdjustRow->Add(new wxButton(this, ID_MOOD_FRAME, L"This frame"),
                      moodAdjustFlags);
  pMoodAdjustRow->Add(new wxButton(this, ID_MOOD_LEFT, L"<", wxDefaultPosition,
                      wxDefaultSize, wxBU_EXACTFIT), moodAdjustFlags);
  pMoodAdjustRow->Add(new wxButton(this, ID_MOOD_RIGHT, L">", wxDefaultPosition,
                      wxDefaultSize, wxBU_EXACTFIT), moodAdjustFlags);
  pMoodAdjustRow->Add(new wxButton(this, ID_MOOD_UP, L"^", wxDefaultPosition,
                      wxDefaultSize, wxBU_EXACTFIT), moodAdjustFlags);
  pMoodAdjustRow->Add(new wxButton(this, ID_MOOD_DOWN, L"v", wxDefaultPosition,
                      wxDefaultSize, wxBU_EXACTFIT), moodAdjustFlags);
  pMoodOverlay->Add(pMoodAdjustRow, wxSizerFlags(1).Expand().Border(wxALL, 2));

  pMoodOverlay->Add(
      new wxCheckBox(this, ID_DRAW_COORDINATES, L"Draw tile coordinates"),
      fillSizerFlags);
  pSidebarSizer->Add(pMoodOverlay, fillSizerFlags);
  m_bDrawMood = false;
  m_bDrawCoordinates = false;
  m_iMoodDrawX = 0;
  m_iMoodDrawY = 0;

  for (int iLayer = 0; iLayer < 13; ++iLayer) {
    wxCheckBox* pCheck =
        wxDynamicCast(FindWindow(make_id(iLayer, 0)), wxCheckBox);
    if (pCheck != nullptr) {
      pCheck->SetValue(true);
      m_mskLayers.set(iLayer, 0);
    }
  }

  Connect(make_id(0, 0), make_id(12, 24), wxEVT_COMMAND_CHECKBOX_CLICKED,
          (wxObjectEventFunction)&frmMain::_onToggleMask);

  wxStaticBoxSizer* pSearch = new wxStaticBoxSizer(wxVERTICAL, this, L"Search");
  wxBoxSizer* pSearchButtons = new wxBoxSizer(wxHORIZONTAL);
  pSearchButtons->Add(new wxButton(this, ID_SEARCH_LAYER_ID, L"Layer/ID"),
                      buttonSizerFlags);
  pSearchButtons->Add(new wxButton(this, ID_SEARCH_FRAME, L"Frame"),
                      buttonSizerFlags);
  pSearchButtons->Add(new wxButton(this, ID_SEARCH_SOUND, L"Sound"),
                      buttonSizerFlags);
  pSearch->Add(pSearchButtons, 0);
  m_lstSearchResults = new wxListBox(this, ID_SEARCH_RESULTS);
  pSearch->Add(m_lstSearchResults, wxSizerFlags(1).Expand().Border(wxALL, 1));

  wxStaticBoxSizer* pFrameFlags =
      new wxStaticBoxSizer(wxHORIZONTAL, this, L"Frame Flags");
  wxSizerFlags frameSizerFlags(0);
  frameSizerFlags.Expand().Border(wxALL, 2);
  wxBoxSizer* pFlags1 = new wxBoxSizer(wxVERTICAL);
  m_txtFrameFlags[0] = new wxTextCtrl(this, wxID_ANY);
  pFlags1->Add(m_txtFrameFlags[0], frameSizerFlags);
  m_chkFrameFlags[0] = new wxCheckBox(this, wxID_ANY, L"2^0");
  m_chkFrameFlags[1] = new wxCheckBox(this, wxID_ANY, L"2^1");
  m_chkFrameFlags[2] = new wxCheckBox(this, wxID_ANY, L"2^2");
  m_chkFrameFlags[3] = new wxCheckBox(this, wxID_ANY, L"2^3");
  m_chkFrameFlags[4] = new wxCheckBox(this, wxID_ANY, L"2^4");
  m_chkFrameFlags[5] = new wxCheckBox(this, wxID_ANY, L"2^5");
  m_chkFrameFlags[6] = new wxCheckBox(this, wxID_ANY, L"2^6");
  m_chkFrameFlags[7] = new wxCheckBox(this, wxID_ANY, L"2^7");
  pFlags1->Add(m_chkFrameFlags[0], frameSizerFlags);
  pFlags1->Add(m_chkFrameFlags[1], frameSizerFlags);
  pFlags1->Add(m_chkFrameFlags[2], frameSizerFlags);
  pFlags1->Add(m_chkFrameFlags[3], frameSizerFlags);
  pFlags1->Add(m_chkFrameFlags[4], frameSizerFlags);
  pFlags1->Add(m_chkFrameFlags[5], frameSizerFlags);
  pFlags1->Add(m_chkFrameFlags[6], frameSizerFlags);
  pFlags1->Add(m_chkFrameFlags[7], frameSizerFlags);
  pFrameFlags->Add(pFlags1, wxSizerFlags(1).Expand());
  wxBoxSizer* pFlags2 = new wxBoxSizer(wxVERTICAL);

  m_txtFrameFlags[1] = new wxTextCtrl(this, wxID_ANY);

  pFlags2->Add(m_txtFrameFlags[1], frameSizerFlags);
  m_chkFrameFlags[8] = new wxCheckBox(this, wxID_ANY, L"2^8 (Animation Start)");
  m_chkFrameFlags[9] = new wxCheckBox(this, wxID_ANY, L"2^9");
  m_chkFrameFlags[10] = new wxCheckBox(this, wxID_ANY, L"2^10");
  m_chkFrameFlags[11] = new wxCheckBox(this, wxID_ANY, L"2^11");
  m_chkFrameFlags[12] = new wxCheckBox(this, wxID_ANY, L"2^12");
  m_chkFrameFlags[13] = new wxCheckBox(this, wxID_ANY, L"2^13");
  m_chkFrameFlags[14] = new wxCheckBox(this, wxID_ANY, L"2^14");
  m_chkFrameFlags[15] = new wxCheckBox(this, wxID_ANY, L"2^15");
  pFlags2->Add(m_chkFrameFlags[8], frameSizerFlags);
  pFlags2->Add(m_chkFrameFlags[9], frameSizerFlags);
  pFlags2->Add(m_chkFrameFlags[10], frameSizerFlags);
  pFlags2->Add(m_chkFrameFlags[11], frameSizerFlags);
  pFlags2->Add(m_chkFrameFlags[12], frameSizerFlags);
  pFlags2->Add(m_chkFrameFlags[13], frameSizerFlags);
  pFlags2->Add(m_chkFrameFlags[14], frameSizerFlags);
  pFlags2->Add(m_chkFrameFlags[15], frameSizerFlags);
  pFrameFlags->Add(pFlags2, wxSizerFlags(1).Expand());

  pMainSizer->Add(pSidebarSizer, wxSizerFlags(0).Expand().Border(wxALL, 2));

  wxSizer* pRightHandSizer = new wxBoxSizer(wxVERTICAL);
  pRightHandSizer->AddSpacer(1);

  m_panFrame = new wxPanel(this, wxID_ANY, wxDefaultPosition, wxDefaultSize,
                           wxBORDER_SIMPLE);
  pRightHandSizer->Add(m_panFrame, wxSizerFlags(0).Expand().Border(wxALL, 2));
  m_panFrame->Connect(wxEVT_PAINT,
                      (wxObjectEventFunction)&frmMain::_onPanelPaint, nullptr,
                      this);
  m_panFrame->Connect(wxEVT_LEFT_UP,
                      (wxObjectEventFunction)&frmMain::_onPanelClick, nullptr,
                      this);
  m_panFrame->SetMinSize(m_panFrame->ClientToWindowSize(wxSize(402, 402)));

  pRightHandSizer->AddSpacer(1);
  pRightHandSizer->Add(pSearch, wxSizerFlags(1).Expand().Border(wxALL, 0));
  pRightHandSizer->Add(pFrameFlags, fillSizerFlags);
  pMainSizer->Add(pRightHandSizer, wxSizerFlags(1).Expand().Border(wxALL, 0));

  SetSizer(pMainSizer);

  SetMinSize(ClientToWindowSize(pMainSizer->CalcMin()));
  SetSize(GetMinSize());

  load();

  m_tmrAnimate.SetOwner(this, ID_TIMER_ANIMATE);
  m_tmrAnimate.Start(100);
}

void frmMain::_onBrowse(wxCommandEvent& WXUNUSED(evt)) {
  m_txtTHPath->SetValue(::wxDirSelector(L"Choose Theme Hospital root folder",
                                        m_txtTHPath->GetValue(), 0,
                                        wxDefaultPosition, this));
}

void frmMain::_onLoad(wxCommandEvent& WXUNUSED(evt)) {
  ::wxInitAllImageHandlers();
  load();
}

void frmMain::load() {
  wxBusyCursor oBusy;
  wxString sPath = m_txtTHPath->GetValue();
  if (sPath.IsEmpty()) return;
  if (sPath.Mid(sPath.Len() - 1) != wxFileName::GetPathSeparator()) {
    sPath += wxFileName::GetPathSeparator();
  }
  if (!wxFileName::DirExists(sPath)) {
    ::wxMessageBox(L"Theme Hospital path non-existent", L"Load Animations",
                   wxOK | wxICON_ERROR, this);
    return;
  }
  sPath = _getCaseSensitivePath(L"DATA", sPath);
  sPath += wxFileName::GetPathSeparator();
  wxString aPath = _getCaseSensitivePath(L"VSPR-0", sPath);
  aPath += wxFileName::GetPathSeparator();
  m_oAnims.setSpritePath(aPath);

  if (!m_oAnims.loadAnimationFile(
          _getCaseSensitivePath(L"VSTART-1.ANI", sPath)) ||
      !m_oAnims.loadFrameFile(_getCaseSensitivePath(L"VFRA-1.ANI", sPath)) ||
      !m_oAnims.loadListFile(_getCaseSensitivePath(L"VLIST-1.ANI", sPath)) ||
      !m_oAnims.loadElementFile(_getCaseSensitivePath(L"VELE-1.ANI", sPath)) ||
      !m_oAnims.loadTableFile(_getCaseSensitivePath(L"VSPR-0.TAB", sPath)) ||
      !m_oAnims.loadSpriteFile(_getCaseSensitivePath(L"VSPR-0.DAT", sPath)) ||
      !m_oAnims.loadPaletteFile(
          _getCaseSensitivePath(L"MPALETTE.DAT", sPath)) ||
      !m_oAnims.loadGhostFile(
          _getCaseSensitivePath(L"../QDATA/GHOST1.DAT", sPath), 1) ||
      !m_oAnims.loadGhostFile(
          _getCaseSensitivePath(L"../QDATA/GHOST2.DAT", sPath), 2) ||
      !m_oAnims.loadGhostFile(
          _getCaseSensitivePath(L"../QDATA/GHOST66.DAT", sPath), 3)) {
    ::wxMessageBox(L"Cannot load one or more data files", L"Load Animations",
                   wxOK | wxICON_ERROR, this);
  }
  m_oAnims.markDuplicates();

  m_txtAnimCount->SetValue(
      wxString::Format(L"%zu", m_oAnims.getAnimationCount()));

  m_imgBackground.Create(400, 400);
  {
    unsigned char* pData = m_imgBackground.GetData();
    unsigned char cPrimary = 0xFF;
    unsigned char cSecondary = 0xE0;
    for (int y = 0; y < 400; ++y) {
      for (int x = 0; x < 400; x += 8) {
        memset(pData, cPrimary, 4 * 3);
        pData += 4 * 3;
        memset(pData, cSecondary, 4 * 3);
        pData += 4 * 3;
      }
      if (y % 4 == 3) {
        cPrimary ^= cSecondary;
        cSecondary ^= cPrimary;
        cPrimary ^= cSecondary;
      }
    }
    wxBitmap bmpBackdrop(backdrop_xpm);
    wxBitmap bmpBackground(m_imgBackground);
    {
      wxMemoryDC dcBlit;
      dcBlit.SelectObject(bmpBackground);
      dcBlit.DrawBitmap(bmpBackdrop, 78, 170, true);
    }
    m_imgBackground = bmpBackground.ConvertToImage();
  }

  _onAnimChange(0);
}

void frmMain::_onToggleMask(wxCommandEvent& evt) {
  int iID = evt.GetId() - ID_LAYER_CHECKS;
  int iLayer = iID / 25;
  iID %= 25;

  if (evt.IsChecked())
    m_mskLayers.set(iLayer, iID);
  else
    m_mskLayers.clear(iLayer, iID);

  m_panFrame->Refresh(false);
}

void frmMain::_onFirstAnim(wxCommandEvent& evt) {
  if (m_iCurrentAnim > 0) _onAnimChange(0);
}

void frmMain::_onPrevAnim(wxCommandEvent& evt) {
  size_t iAnim = m_iCurrentAnim;
  while (iAnim > 0) {
    --iAnim;
    if (!m_oAnims.isAnimationDuplicate(iAnim)) {
      _onAnimChange(iAnim);
      break;
    }
  }
}

void frmMain::_onNextAnim(wxCommandEvent& evt) {
  size_t iAnim = m_iCurrentAnim + 1;
  while (iAnim < m_oAnims.getAnimationCount()) {
    if (!m_oAnims.isAnimationDuplicate(iAnim)) {
      _onAnimChange(iAnim);
      break;
    }
    iAnim++;
  }
}

void frmMain::_onLastAnim(wxCommandEvent& evt) {
  if (m_iCurrentAnim < m_oAnims.getAnimationCount() - 1)
    _onAnimChange(m_oAnims.getAnimationCount() - 1);
}

void frmMain::_onAnimChar(wxCommandEvent& evt) {
  long conv;
  if (evt.GetString().ToLong(&conv)) {
    if (conv < 0 || conv >= m_oAnims.getAnimationCount()) {
      return;
    }
    size_t iAnim = static_cast<size_t>(conv);
    _onAnimChange(iAnim);
  }
}

void frmMain::_onGhostFileChange(wxCommandEvent& evt) {
  m_iGhostFile = evt.GetId() - ID_GHOST_0;
  m_oAnims.setGhost(m_iGhostFile, m_iGhostIndex);
  m_panFrame->Refresh(false);
}

void frmMain::_onGhostIndexChange(wxSpinEvent& evt) {
  m_iGhostIndex = evt.GetPosition();
  m_oAnims.setGhost(m_iGhostFile, m_iGhostIndex);
  m_panFrame->Refresh(false);
}

void frmMain::_onAnimChange(size_t iIndex) {
  m_iCurrentAnim = iIndex;
  m_txtAnimIndex->ChangeValue(wxString::Format(L"%zu", iIndex));
  m_iCurrentFrame = 0;

  THLayerMask oMask;
  m_oAnims.getAnimationMask(iIndex, oMask);
  for (int iLayer = 0; iLayer < 13; ++iLayer) {
    for (int iId = 0; iId < 32; ++iId) {
      wxCheckBox* pCheck = wxDynamicCast(
          FindWindow(ID_LAYER_CHECKS + iLayer * 25 + iId), wxCheckBox);
      if (pCheck) {
        pCheck->Enable(oMask.isSet(iLayer, iId));
      }
    }
  }

  m_panFrame->Refresh(false);
  m_txtFrameIndex->SetValue(wxString::Format(L"0"));
  m_txtFrameCount->SetValue(
      wxString::Format(L"%zu", m_oAnims.getFrameCount(iIndex)));
}

void frmMain::_onPlayPause(wxCommandEvent& evt) {
  m_bPlayingAnimation = !m_bPlayingAnimation;
  if (m_bPlayingAnimation)
    m_btnPlayPause->SetLabel(L"Pause");
  else
    m_btnPlayPause->SetLabel(L"Play");
}

void frmMain::_onPrevFrame(wxCommandEvent& evt) {
  if (m_oAnims.getAnimationCount() == 0) return;

  if (m_iCurrentFrame == 0)
    m_iCurrentFrame = m_oAnims.getFrameCount(m_iCurrentAnim) - 1;
  else
    m_iCurrentFrame =
        (m_iCurrentFrame - 1) % m_oAnims.getFrameCount(m_iCurrentAnim);
  m_txtFrameIndex->SetValue(wxString::Format(L"%zu", m_iCurrentFrame));
  m_panFrame->Refresh(false);
}

void frmMain::_onNextFrame(wxCommandEvent& evt) {
  if (m_oAnims.getAnimationCount() == 0) return;

  m_iCurrentFrame =
      (m_iCurrentFrame + 1) % m_oAnims.getFrameCount(m_iCurrentAnim);
  m_txtFrameIndex->SetValue(wxString::Format(L"%zu", m_iCurrentFrame));
  m_panFrame->Refresh(false);
}

void frmMain::_onTimer(wxTimerEvent& evt) {
  if (m_bPlayingAnimation) {
    if (m_oAnims.getAnimationCount() == 0) return;

    m_iCurrentFrame =
        (m_iCurrentFrame + 1) % m_oAnims.getFrameCount(m_iCurrentAnim);
    m_txtFrameIndex->SetValue(wxString::Format(L"%zu", m_iCurrentFrame));
    m_panFrame->Refresh(false);
  }
}

void frmMain::_onToggleDrawMood(wxCommandEvent& evt) {
  m_bDrawMood = evt.IsChecked();
  m_panFrame->Refresh(false);
}

void frmMain::_onToggleDrawCoordinates(wxCommandEvent& evt) {
  m_bDrawCoordinates = evt.IsChecked();
  m_panFrame->Refresh(false);
}

void frmMain::_onPanelPaint(wxPaintEvent& evt) {
  wxPaintDC DC(m_panFrame);

  wxImage imgCanvas(400, 400, false);
  if (m_imgBackground.IsOk()) {
    memcpy(imgCanvas.GetData(), m_imgBackground.GetData(), 400 * 400 * 3);
  } else {
    memset(imgCanvas.GetData(), 0xFF, 400 * 400 * 3);
  }
  if (!imgCanvas.HasAlpha()) {
    imgCanvas.InitAlpha();
  }
  for (int iX = 0; iX < 400; ++iX) {
    for (int iY = 0; iY < 400; ++iY) {
      // set completely opaque
      imgCanvas.SetAlpha(iX, iY, (unsigned char)255);
    }
  }
  wxSize oSize;
  m_oAnims.drawFrame(imgCanvas, m_iCurrentAnim, m_iCurrentFrame, &m_mskLayers,
                     oSize);
  if (m_bDrawMood) {
    m_oAnims.drawFrame(imgCanvas, 4048, 0, &m_mskLayers, oSize,
                       m_iMoodDrawX - 1, m_iMoodDrawY - 80);
  }
  th_frame_t* pFrame = m_oAnims.getFrameStruct(m_iCurrentAnim, m_iCurrentFrame);
  uint16_t iFlags = 0;
  if (pFrame) {
    iFlags = pFrame->flags;
  }
  int iFlags1 = (int)(iFlags & 0xFF);
  int iFlags2 = (int)(iFlags >> 8);
  m_txtFrameFlags[0]->SetValue(
      wxString::Format(L"0x%02x (%03i)", iFlags1, iFlags1));
  m_txtFrameFlags[1]->SetValue(
      wxString::Format(L"0x%02x00 (256 * %03i)", iFlags2, iFlags2));
  for (int i = 0; i < 16; ++i)
    m_chkFrameFlags[i]->SetValue((iFlags & (1 << i)) != 0);

  wxBitmap bmpCanvas(imgCanvas);

  DC.DrawBitmap(bmpCanvas, 1, 1, false);

  // Draw relative tile coordinates
  if (m_bDrawCoordinates) {
    for (int i = -1; i <= 1; ++i) {
      for (int j = -1; j <= 1; ++j) {
        _drawCoordinates(DC, i, j);
      }
    }
  }
}

void frmMain::_onPanelClick(wxMouseEvent& evt) {
  updateMoodPosition(evt.GetX() - 143, evt.GetY() - 203);
}

void frmMain::updateMoodPosition(int centerX, int centerY) {
  m_iMoodDrawX = centerX;
  m_iMoodDrawY = centerY;
  {
    double fX = (double)m_iMoodDrawX;
    double fY = (double)m_iMoodDrawY;
    fY = fY / 32.0;
    fX = fX / 64.0;
    fY -= fX;
    fX *= 2.0;
    fX += fY;
    m_txtMoodPosition[0]->SetValue(wxString::Format(L"{%.2f, %.2f}", fX, fY));
  }
  m_txtMoodPosition[1]->SetValue(
      wxString::Format(L"{%i, %i, \"px\"}", m_iMoodDrawX, m_iMoodDrawY));
  if (m_bDrawMood) m_panFrame->Refresh(false);
}

void frmMain::_onMoodFrameApply(wxCommandEvent &evt) {
  wxString wxText = m_txtMoodFramePos->GetLineText(0);
  std::string text = wxText.ToStdString();

  std::regex tilePosRegex("\\{ *([-0-9]+[.][0-9]*) *, *([-0-9]+[.][0-9]*) *\\}");
  std::regex pixelPosRegex("\\{ *([-0-9]+) *, *([-0-9]+) *, *[\"]px[\"] *\\}");

  std::smatch m;
  if (std::regex_match(text, m, tilePosRegex)) {
    double x, y;
    try {
        x = std::stod(m[1].str());
        y = std::stod(m[2].str());
    }
    catch (...) {
      return;
    }

    // Convert the fractions to a pixel position.
    x -= y;
    x /= 2.0;
    y += x;
    x *= 64.0;
    y *= 32.0;
    updateMoodPosition(round(x), round(y));
  }

  if (std::regex_match(text, m, pixelPosRegex)) {
    int x, y;
    try {
        x = std::stoi(m[1].str());
        y = std::stoi(m[2].str());
    }
    catch (...) {
      return;
    }

    updateMoodPosition(x, y);
  }
}

void frmMain::_onMoodLeft(wxCommandEvent &evt) {
  updateMoodPosition(m_iMoodDrawX - 1, m_iMoodDrawY);
}

void frmMain::_onMoodRight(wxCommandEvent &evt) {
  updateMoodPosition(m_iMoodDrawX + 1, m_iMoodDrawY);
}

void frmMain::_onMoodUp(wxCommandEvent &evt) {
  updateMoodPosition(m_iMoodDrawX, m_iMoodDrawY - 1);
}

void frmMain::_onMoodDown(wxCommandEvent &evt) {
  updateMoodPosition(m_iMoodDrawX, m_iMoodDrawY + 1);
}

void frmMain::_onSearchLayerId(wxCommandEvent& evt) {
  long input = ::wxGetNumberFromUser(
      L"Enter the layer number to search in (0 - 12)", L"Layer:",
      L"Search for Layer / ID Combo", 0, 0, 13, this);
  if (input < 0 || input > 12) return;
  int iLayer = static_cast<int>(input);

  input = ::wxGetNumberFromUser(L"Enter the ID number to search for (0 - 24)",
                                L"ID:", L"Search for Layer / ID Combo", 0, 0,
                                24, this);
  if (input < 0 || input > 24) return;
  int iID = static_cast<int>(input);

  m_lstSearchResults->Clear();
  wxBusyCursor oBusy;
  for (size_t i = 0; i < m_oAnims.getAnimationCount(); ++i) {
    if (m_oAnims.isAnimationDuplicate(i)) continue;

    THLayerMask mskAnim;
    m_oAnims.getAnimationMask(i, mskAnim);
    if (mskAnim.isSet(iLayer, iID)) {
      m_lstSearchResults->Append(wxString::Format(L"%zu", i));
    }
  }
}

void frmMain::_onSearchFrame(wxCommandEvent& evt) {
  long input =
      ::wxGetNumberFromUser(L"Enter the frame number to search for.", L"Frame:",
                            L"Search for frame", 0, 0, 20000, this);
  if (input == -1) return;
  size_t iFrame = static_cast<size_t>(input);

  m_lstSearchResults->Clear();
  wxBusyCursor oBusy;
  for (size_t i = 0; i < m_oAnims.getAnimationCount(); ++i) {
    if (m_oAnims.isAnimationDuplicate(i)) continue;
    if (m_oAnims.doesAnimationIncludeFrame(i, iFrame)) {
      m_lstSearchResults->Append(wxString::Format(L"%zu", i));
    }
  }
}

void frmMain::_onSearchSoundIndex(wxCommandEvent& evt) {
  long input = ::wxGetNumberFromUser(L"Enter the sound index to search for.",
                                     L"Sound index:", L"Search for sound", 0, 0,
                                     256, this);
  if (input == -1) return;
  size_t iFrame = static_cast<size_t>(input);

  m_lstSearchResults->Clear();
  wxBusyCursor oBusy;
  for (size_t i = 0; i < m_oAnims.getAnimationCount(); ++i) {
    if (m_oAnims.isAnimationDuplicate(i)) continue;
    size_t iCount = m_oAnims.getFrameCount(i);
    for (size_t j = 0; j < iCount; ++j) {
      if ((m_oAnims.getFrameStruct(i, j)->flags & 0xFF) == iFrame) {
        m_lstSearchResults->Append(wxString::Format(L"%zu", i));
        break;
      }
    }
  }
}

void frmMain::_drawCoordinates(wxPaintDC& DC, int i, int j) {
  int x = 122;  // tile (0, 0) text start x-coordinate
  int y = 226;  // tile (0, 0) text start y-coordinate
  wxString s;
  s.Printf(_T("(%2d,%2d)"), i, j);
  DC.DrawText(s, 32 * (i - j) + x, 16 * (i + j - 2) + y);
}

wxString frmMain::_getCaseSensitivePath(const wxString& sInsensitivePathPart,
                                        const wxString& sPath) {
  if (!wxFileName::IsCaseSensitive()) {
    return sPath + sInsensitivePathPart;
  }

  wxString retStr(sPath);

  wxStringTokenizer pathTokenizer(sInsensitivePathPart,
                                  wxFileName::GetPathSeparator());
  while (pathTokenizer.HasMoreTokens()) {
    wxDir dir(retStr);
    if (!dir.IsOpened()) {
      break;
    }

    wxString pathPart = pathTokenizer.GetNextToken();

    wxString realName;
    bool cont =
        dir.GetFirst(&realName, wxEmptyString,
                     wxDIR_DIRS | wxDIR_FILES | wxDIR_HIDDEN | wxDIR_DOTDOT);

    bool found = false;
    while (cont) {
      if (realName.Upper() == pathPart.Upper()) {
        if (retStr.Last() != wxFileName::GetPathSeparator()) {
          retStr += wxFileName::GetPathSeparator();
        }
        retStr += realName;
        found = true;
        break;
      }
      cont = dir.GetNext(&realName);
    }

    if (!found) {
      retStr += wxFileName::GetPathSeparator();
      retStr += pathPart;
      break;
    }
  }

  while (pathTokenizer.HasMoreTokens()) {
    wxString pathPart = pathTokenizer.GetNextToken();
    if (retStr.Last() != wxFileName::GetPathSeparator()) {
      retStr += wxFileName::GetPathSeparator();
    }
    retStr += pathPart;
  }

  return retStr;
}
