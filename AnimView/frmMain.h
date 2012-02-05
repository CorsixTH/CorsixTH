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
#include <wx/frame.h>
#include <wx/button.h>
#include <wx/spinctrl.h>
#include <wx/checkbox.h>
#include <wx/textctrl.h>
#include <wx/panel.h>
#include <wx/timer.h>
#include <wx/listbox.h>
#include <wx/dcclient.h>
#include <wx/txtstrm.h>
#include "th.h"
//#include <vector>

class frmMain : public wxFrame
{
public:
    frmMain();
    ~frmMain();

    enum
    {
        ID_FIRST_ANIM = wxID_HIGHEST + 1,
        ID_PREV_ANIM,
        ID_ANIM_INDEX,
        ID_NEXT_ANIM,
        ID_LAST_ANIM,
        ID_PREV_FRAME,
        ID_NEXT_FRAME,
        ID_PLAY_PAUSE,
        ID_TIMER_ANIMATE,
        ID_SEARCH_LAYER_ID,
        ID_SEARCH_FRAME,
        ID_SEARCH_SOUND,
        ID_SEARCH_RESULTS,
        ID_GHOST_0,
        ID_GHOST_1,
        ID_GHOST_2,
        ID_GHOST_3,
        ID_LOAD,
        ID_BROWSE,
        ID_EXPORT,
        ID_DRAW_MOOD,
        ID_DRAW_COORDINATES,
        ID_LAYER_CHECKS, // Must be last ID
    };

    void load();
    void export_png();
    void exportSpritesPage(bool bComplex, wxString sPath, wxString sFilename, wxString spPath=L"", wxString sPalette=L"MPALETTE.DAT");
    //std::vector<_sprite_t> m_vSprites;

protected:
    void _onLoad(wxCommandEvent& evt);
    void _onBrowse(wxCommandEvent& evt);
    void _onExport(wxCommandEvent& evt);
    void _onFirstAnim(wxCommandEvent& evt);
    void _onPrevAnim(wxCommandEvent& evt);
    void _onNextAnim(wxCommandEvent& evt);
    void _onLastAnim(wxCommandEvent& evt);
    void _onPrevFrame(wxCommandEvent& evt);
    void _onNextFrame(wxCommandEvent& evt);
    void _onPlayPause(wxCommandEvent& evt);
    void _onToggleMask(wxCommandEvent& evt);
    void _onToggleDrawMood(wxCommandEvent& evt);
    void _onToggleDrawCoordinates(wxCommandEvent& evt);
    void _onSearchLayerId(wxCommandEvent& evt);
    void _onSearchFrame(wxCommandEvent& evt);
    void _onSearchSoundIndex(wxCommandEvent& evt);
    void _onGotoSearchResult(wxCommandEvent& evt);
    void _onAnimChar(wxCommandEvent& evt);
    void _onGhostFileChange(wxCommandEvent& evt);
    void _onGhostIndexChange(wxSpinEvent& evt);
    void _onPanelPaint(wxPaintEvent& evt);
    void _onPanelClick(wxMouseEvent& evt);
    void _onTimer(wxTimerEvent& evt);

    void _onAnimChange(size_t iIndex);

    void _drawCoordinates(wxPaintDC& DC, int i, int j);
    wxString _getCaseSensitivePath(const wxString& sInsensitivePathPart, const wxString& sPath);

    THAnimations m_oAnims;
    THLayerMask m_mskLayers;
    wxImage m_imgBackground;
    wxTimer m_tmrAnimate;
    size_t m_iCurrentAnim;
    size_t m_iCurrentFrame;
    int m_iGhostFile;
    int m_iGhostIndex;
    int m_iMoodDrawX;
    int m_iMoodDrawY;
    bool m_bPlayingAnimation;
    bool m_bDrawMood;
    bool m_bDrawCoordinates;

    wxButton* m_btnPlayPause;
    wxButton* m_btnExport;
    wxTextCtrl* m_txtTHPath;
    wxTextCtrl* m_txtAnimIndex;
    wxTextCtrl* m_txtAnimCount;
    wxTextCtrl* m_txtFrameIndex;
    wxTextCtrl* m_txtFrameCount;
    wxTextCtrl* m_txtFrameFlags[2];
    wxTextCtrl* m_txtMoodPosition[2];
    wxCheckBox* m_chkFrameFlags[16];
    wxListBox* m_lstSearchResults;
    wxPanel* m_panFrame;
    DECLARE_EVENT_TABLE();
};
