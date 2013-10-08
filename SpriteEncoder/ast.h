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

#ifndef AST_H
#define AST_H

#include <set>
#include <deque>
#include <string>

class Output;

class Sprite
{
public:
    Sprite();

    void SetRecolour(const std::string &filename);
    void Check() const;
    void Write(Output *out) const;

    int m_iLine;                  // Line number of the sprite.
    int m_iSprite;                // Sprite number.
    int m_iLeft;                  // Left coordinate in the images.
    int m_iTop;                   // Top coordinate in the images.
    int m_iWidth;                 // Width of the images.
    int m_iHeight;                // Height of the images.
    std::string m_sBaseImage;     // Full-colour RGBA base image.
    std::string m_sRecolourImage; // Name of overlay image (if set).
    unsigned char m_aNumber[256]; // Layer number of the recolouring.
};

inline static bool operator<(const Sprite &s1, const Sprite &s2)
{
    return s1.m_iSprite < s2.m_iSprite;
}

struct ScannerData
{
    int line;
    int number;
    std::string text;
    Sprite *m_pSprite;
};

#define YYSTYPE ScannerData
extern YYSTYPE yylval;
int yylex();
int yyparse();
void yyerror(const char *msg);
void SetupScanner(const char *fname, FILE *new_file);

extern std::set<Sprite> g_oSprites;

#endif

