!include "TimeStamp.nsh"

!define LogWithTime "!insertmacro LogWithTime"
!macro LogWithTime text
	Push `${text}`
	Call LogWithTime
!macroend

Function LogWithTime
	Pop $0
	${TimeStamp} $1
	LogEx::Write "$1 - $0"
FunctionEnd