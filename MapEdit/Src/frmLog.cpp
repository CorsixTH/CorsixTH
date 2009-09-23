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
#include "frmLog.h"

BEGIN_EVENT_TABLE(frmLog, wxFrame)
END_EVENT_TABLE()

frmLog::frmLog()
  : wxFrame(NULL, wxID_ANY, L"CorsixTH Lua Log Window", wxDefaultPosition,
            wxSize(400, 480), wxCAPTION | wxRESIZE_BORDER)
{
    m_pTextCtrl = new wxTextCtrl(this, wxID_ANY, L"", wxDefaultPosition,
        wxDefaultSize, wxTE_READONLY | wxTE_MULTILINE);

    wxSizer *pTopSizer = new wxBoxSizer(wxVERTICAL);
    pTopSizer->Add(m_pTextCtrl, 1, wxEXPAND);
    SetSizer(pTopSizer);

    Show();
}

frmLog::~frmLog()
{
}
