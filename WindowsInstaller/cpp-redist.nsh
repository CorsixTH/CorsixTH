;Original credit: https://github.com/GitCommons/cpp-redist-nsis
;Inspired by:
; https://gist.github.com/bogdibota/062919938e1ed388b3db5ea31f52955c
; https://stackoverflow.com/questions/34177547/detect-if-visual-c-redistributable-for-visual-studio-2013-is-installed
; https://stackoverflow.com/a/54391388

;Find latest downloads here:
; https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist

!include LogicLib.nsh

Section "customInit"
  MessageBox MB_YESNO "$(cpp_redist)" /SD IDYES IDNO VSRedistInstalled

  ;if no goto executed, install vcredist
  ;download installer
  ${If} ${RunningX64}
    NSISdl::download "http://aka.ms/vs/17/release/vc_redist.x64.exe" $TEMP\vcppredist.exe
  ${Else}
    NSISdl::download "http://aka.ms/vs/17/release/vc_redist.x86.exe" $TEMP\vcppredist.exe
  ${EndIf}
  ;exec installer
  ExecWait "$TEMP\vcppredist.exe /install /passive /norestart"

  VSRedistInstalled:
  ;jumped from message box, nothing to do here
SectionEnd
