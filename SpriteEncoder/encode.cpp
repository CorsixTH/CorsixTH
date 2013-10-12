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
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "ast.h"
#include "output.h"

int main(int iArgc, char *pArgv[])
{
    FILE *pInfile = NULL;
    const char *pOutfname = NULL;
    if (iArgc == 1)
    {
        SetupScanner(NULL, NULL);
    }
    else if (strcmp(pArgv[1], "-h") == 0 || strcmp(pArgv[1], "--help") == 0)
    {
        printf("Usage: encode <sprite-file> [<output-file>]\n");
        exit(0);
    }
    else if (iArgc == 2)
    {
        pInfile = fopen(pArgv[1], "r");
        SetupScanner(pArgv[1], pInfile);
    }
    else if (iArgc == 3)
    {
        pInfile = fopen(pArgv[1], "r");
        SetupScanner(pArgv[1], pInfile);
        pOutfname = pArgv[2];
    }
    else
    {
        fprintf(stderr, "Too many arguments, try 'encode -h'\n");
        exit(1);
    }

    int iRet = yyparse();
    if (pInfile != NULL) fclose(pInfile);

    if (iRet != 0)
    {
        exit(iRet);
    }

    for (std::set<Sprite>::iterator iter = g_oSprites.begin(); iter != g_oSprites.end(); iter++)
    {
        iter->Check();
    }

    Output out;
    out.Uint8('C'); out.Uint8('T'); out.Uint8('H'); out.Uint8('G');
    out.Uint8(2); out.Uint8(0);

    for (std::set<Sprite>::iterator iter = g_oSprites.begin(); iter != g_oSprites.end(); iter++)
    {
        iter->Write(&out);
    }

    if (pOutfname != NULL)
    {
        out.Write(pOutfname);
    }

    exit(0);
}

// vim: et sw=4 ts=4 sts=4

