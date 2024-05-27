;Credit: https://github.com/GitCommons/cpp-redist-nsis
;Inspired by:
; https://gist.github.com/bogdibota/062919938e1ed388b3db5ea31f52955c
; https://stackoverflow.com/questions/34177547/detect-if-visual-c-redistributable-for-visual-studio-2013-is-installed
; https://stackoverflow.com/a/54391388

;Find latests downloads here:
; https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist

!include LogicLib.nsh

Section "customInit"
  Var /GLOBAL VCRedistDownload
  Var /GLOBAL isInstalled
  ${If} ${RunningX64}
    ;check H-KEY registry
    ReadRegDWORD $isInstalled HKLM "SOFTWARE\Wow6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" "Installed"
    StrCpy $VCRedistDownload "http://aka.ms/vs/17/release/vc_redist.x64.exe"
  ${Else}
    ReadRegDWORD $isInstalled HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" "Installed"
    StrCpy $VCRedistDownload "http://aka.ms/vs/17/release/vc_redist.x86.exe"
  ${EndIf}


  ${If} $isInstalled != "1"
    MessageBox MB_YESNO "NOTE: This application requires$\r$\n\
      'Microsoft Visual C++ Redistributable'$\r$\n\
      to function properly.$\r$\n$\r$\n\
      Download and install now?" /SD IDYES IDNO VSRedistInstalled

    ;if no goto executed, install vcredist
    ;create temp dir
    CreateDirectory $TEMP\app-name-setup
    ;download installer
    NSISdl::download "$VCRedistDownload" $TEMP\app-name-setup\vcppredist.exe
    ;exec installer
    ExecWait "$TEMP\app-name-setup\vcppredist.exe /install /passive /norestart"
  ${EndIf}


  VSRedistInstalled:
  ;jumped from message box, nothing to do here
SectionEnd
