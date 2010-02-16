To "compile" the script NSIS (Nullsoft Scriptable Install System) is needed.

It can be found here: http://nsis.sourceforge.net/Main_Page

To add an additional language, make a new group of strings in the 
LanguageStrings.nsh file, and then insert '!insertmacro MUI_LANGUAGE "<Language_name>"' 
at roughly line 90 in Win32Script.nsi.

When packaging, make sure that the executables are in the x64 and x86 folders,
and needed dlls are in the dll folder. All other files (lua etc) should be as they
are when checked out, i.e. "../CorsixTH/*"
