; This software is provided 'as-is', without any express or implied warranty. 
; In no event will the authors be held liable for any damages arising from the 
; use of this software.

; Permission is granted to anyone to use this software for any purpose, 
; including commercial applications, and to alter it and redistribute it freely, 
; subject to the following restrictions:

;    1. The origin of this software must not be misrepresented; you must not claim 
;       that you wrote the original software. If you use this software in a product, 
;       an acknowledgment in the product documentation would be appreciated but is not 
;       required.
;    2. Altered source versions must be plainly marked as such, and must not be 
;       misrepresented as being the original software.
;    3. This notice may not be removed or altered from any source distribution. 

; Function to replace text in a file, Author: Datenbert

!macro ReplaceInFile SOURCE_FILE SEARCH_TEXT REPLACEMENT
  Push "${SOURCE_FILE}"
  Push "${SEARCH_TEXT}"
  Push "${REPLACEMENT}"
  Call RIF
!macroend

Function RIF
 
  ClearErrors  ; want to be a newborn
 
  Exch $0      ; REPLACEMENT
  Exch
  Exch $1      ; SEARCH_TEXT
  Exch 2
  Exch $2      ; SOURCE_FILE
 
  Push $R0     ; SOURCE_FILE file handle
  Push $R1     ; temporary file handle
  Push $R2     ; unique temporary file name
  Push $R3     ; a line to sar/save
  Push $R4     ; shift puffer
 
  IfFileExists $2 +1 RIF_error      ; knock-knock
  FileOpen $R0 $2 "r"               ; open the door
 
  GetTempFileName $R2               ; who's new?
  FileOpen $R1 $R2 "w"              ; the escape, please!
 
  RIF_loop:                         ; round'n'round we go
    FileRead $R0 $R3                ; read one line
    IfErrors RIF_leaveloop          ; enough is enough
    RIF_sar:                        ; sar - search and replace
      Push "$R3"                    ; (hair)stack
      Push "$1"                     ; needle
      Push "$0"                     ; blood
      Call StrReplace               ; do the bartwalk
      StrCpy $R4 "$R3"              ; remember previous state
      Pop $R3                       ; gimme s.th. back in return!
      StrCmp "$R3" "$R4" +1 RIF_sar ; loop, might change again!
    FileWrite $R1 "$R3"             ; save the newbie
  Goto RIF_loop                     ; gimme more
 
  RIF_leaveloop:                    ; over'n'out, Sir!
    FileClose $R1                   ; S'rry, Ma'am - clos'n now
    FileClose $R0                   ; me 2
 
    Delete "$2.old"                 ; go away, Sire
    Rename "$2" "$2.old"            ; step aside, Ma'am
    Rename "$R2" "$2"               ; hi, baby!
 
    ClearErrors                     ; now i AM a newborn
    Goto RIF_out                    ; out'n'away
 
  RIF_error:                        ; ups - s.th. went wrong...
    SetErrors                       ; ...so cry, boy!
 
  RIF_out:                          ; your wardrobe?
  Pop $R4
  Pop $R3
  Pop $R2
  Pop $R1
  Pop $R0
  Pop $2
  Pop $0
  Pop $1
 
FunctionEnd