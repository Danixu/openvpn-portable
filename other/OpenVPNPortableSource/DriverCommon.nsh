!macro DEFINES PNAME
       !define NAME "${PNAME}"
       !define FRIENDLYNAME "${PNAME}"
       !define APP "${PNAME}"
       !define VER "1.0.0.0"	;Version of the Portable App, Version of OpenVPN is found on .\app\appinfo\appinfo.ini
       !define WEBSITE "https://bitbucket.org/Danixu86/openvpn-portable"
       !define DEFAULTDRVDIR "app\%WinVer%\driver\%CPU%"
	   !define DEFAULTAPPDIR "app\%WinVer%\bin"
       !define DRIVERFILE "OemWin2k.inf"
       !define DRIVERNAME "tap0901"
       !define DRIVERID "{4d36e972-e325-11ce-bfc1-08002be10318}"
!macroend

!macro PROGRAM_DETAILS
       ;=== Program Details
       Name "${NAME}"
	   ;= Moved to variables.nsh
       ;OutFile "${OutputFolder}\${NAME}.exe"
       Caption "${FRIENDLYNAME} - OpenVPN Made Portable"
       VIProductVersion "${VER}"
       VIAddVersionKey FileDescription "${FRIENDLYNAME}"
       VIAddVersionKey LegalCopyright "Daniel Carrasco"
       VIAddVersionKey Comments "Allows ${APP} to be run from a removable drive."
       VIAddVersionKey OriginalFilename "${NAME}.exe"
       VIAddVersionKey FileVersion "${VER}"
	   OutFile "${OutputFolder}\${NAME}.exe"
!macroend

!macro RUNTIME_SWITCHES
       CRCCheck On
       AutoCloseWindow True
       SetCompressor /SOLID LZMA
       RequestExecutionLevel user
!macroend

!macro PROGRAM_ICON ICONNAME
       ;=== Program Icon
       Icon "${ICONNAME}.ico"
       !define MUI_ICON "${ICONNAME}.ico"
!macroend