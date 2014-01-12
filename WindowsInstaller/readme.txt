To "compile" the script you will need NSIS (Nullsoft Scriptable Install System).
Note that now that we support languages such as Chinese and 
Russian the Unicode version of NSIS is needed.

It can be found here: http://www.scratchpaper.com/

The 'normal' version is here: http://nsis.sourceforge.net/Main_Page

To add an additional language, make a new group of strings in the 
LanguageStrings.nsh file, and then insert 
'!insertmacro MUI_LANGUAGE "<Language_name>"' at roughly line 97 
in Win32Script.nsi.

When packaging, make sure that architecture specific files are in two
folders called x64 and x86 respectively. All other files (lua etc) 
should be as they are when checked out, i.e. "../CorsixTH/*".

You can find more information about creating a Windows installer here:
http://code.google.com/p/corsix-th/wiki/HowToPackageWindows.
