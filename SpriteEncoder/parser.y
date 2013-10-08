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
#include <list>
#include "ast.h"
#include <cstdio>

std::set<Sprite> g_oSprites;
%}


%token CURLY_OPEN CURLY_CLOSE EQUAL SEMICOL
%token LEFTKW TOPKW WIDTHKW HEIGHTKW BASEIMGKW RECOLOURKW SPRITEKW LAYERKW

%token<number> NUMBER
%token<text> STRING

%type<m_pSprite> SpriteSettings Sprite

%start Program


%%

Program : /* empty */
          { g_oSprites.clear(); }
        | Program Sprite
          { g_oSprites.insert(*$2); delete $2; }
        ;

Sprite : SPRITEKW NUMBER CURLY_OPEN SpriteSettings CURLY_CLOSE
         { $$ = $4; $$->m_iSprite = $2; }
       ;

SpriteSettings : /* empty */
                 { $$ = new Sprite; }
               | SpriteSettings LEFTKW EQUAL NUMBER SEMICOL
                 { $$ = $1; $$->m_iLeft = $4; }
               | SpriteSettings TOPKW EQUAL NUMBER SEMICOL
                 { $$ = $1; $$->m_iTop = $4; }
               | SpriteSettings WIDTHKW EQUAL NUMBER SEMICOL
                 { $$ = $1; $$->m_iWidth = $4; }
               | SpriteSettings HEIGHTKW EQUAL NUMBER SEMICOL
                 { $$ = $1; $$->m_iHeight = $4; }
               | SpriteSettings BASEIMGKW EQUAL STRING SEMICOL
                 { $$ = $1; $$->m_sBaseImage = $4; }
               | SpriteSettings RECOLOURKW EQUAL STRING SEMICOL
                 { $$ = $1; $$->SetRecolour($4); }
               | SpriteSettings LAYERKW NUMBER EQUAL NUMBER SEMICOL
                 { $$ = $1; $$->m_aNumber[($3) & 0xFF] = ($5) & 0xFF; }
               ;

%%

void yyerror(const char *msg)
{
    fprintf(stderr, "Parse error at line %d: %s\n", yylval.line, msg);
    exit(1);
}
