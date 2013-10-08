/*
Copyright (c) 2013 Albert "Alberth" Hofkamp

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

%{
#include <cstdio>
#include <string>
#include "ast.h"
#include "tokens.h"

int line = 1;
std::string filename;
%}

%x IN_STRING
%x IN_COMMENT

%option noyywrap

%%

"{"             { yylval.line = line; return CURLY_OPEN; }
"}"             { yylval.line = line; return CURLY_CLOSE; }
"="             { yylval.line = line; return EQUAL; }
";"             { yylval.line = line; return SEMICOL; }

"sprite"        { yylval.line = line; return SPRITEKW; }
"left"          { yylval.line = line; return LEFTKW; }
"top"           { yylval.line = line; return TOPKW; }
"width"         { yylval.line = line; return WIDTHKW; }
"height"        { yylval.line = line; return HEIGHTKW; }
"base"          { yylval.line = line; return BASEIMGKW; }
"recolour"      { yylval.line = line; return RECOLOURKW; }
"layer"         { yylval.line = line; return LAYERKW; }

"0"             { yylval.line = line;
                  yylval.number = 0;
                  return NUMBER; }

[1-9][0-9]*     { yylval.line = line;
                  yylval.number = atoi(yytext);
                  return NUMBER; }

\"              { yylval.text = "";
                  yylval.line = line;
                  BEGIN(IN_STRING); }

<IN_STRING>\"   { BEGIN(INITIAL);
                  return STRING; }

<IN_STRING>.    { yylval.text += yytext; }

"//"            { BEGIN(IN_COMMENT); }

<IN_COMMENT>\n  { BEGIN(INITIAL);
                  line++; }

<IN_COMMENT>.   { }

" "             { }

\t              { }

\n              { line++; }

.               { fprintf(stderr, "Unrecognized character encountered at line %d\n", line);
                  exit(1); }

<IN_COMMENT><<EOF>> { BEGIN(INITIAL); }
<IN_STRING><<EOF>>  { BEGIN(INITIAL); }

%%

void SetupScanner(const char *fname, FILE *new_file)
{
    if (new_file == NULL || fname == NULL)
    {
        new_file = stdin;
    }
    yyrestart(new_file);
    BEGIN(INITIAL);

    filename = (fname == NULL) ? "<stdin>" : fname;
    line = 1;
}

