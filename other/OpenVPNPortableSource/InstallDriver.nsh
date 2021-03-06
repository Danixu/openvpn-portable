!macro DEFINES PNAME
       !define NAME "${PNAME}"
       !define FRIENDLYNAME "OpenVPN Driver install"
       !define VER "1.7.7.0"	;Version of the Portable App, Version of OpenVPN is found on .\app\appinfo\appinfo.ini
       ;!define SUBVER "RC4"
       !define WEBSITE "http://www.sourceforge.net/projects/ovpnp"
       !define DEFAULTAPPDIR "app\bin"
       !define DEFAULTDRVDIR "app\driver"
       !define TAPINSTALLEXE32 "tapinstallWin32.exe"
       !define TAPINSTALLEXE64 "tapinstallWin64.exe"
       !define DRIVERFILE "OemWin2k.inf"
       !define DRIVERNAME "tap0901"
       !define DRIVERID "{4d36e972-e325-11ce-bfc1-08002be10318}"
!macroend

!macro PROGRAM_DETAILS
       ;=== Program Details
       Name "${NAME}"
       OutFile "${NAME}.exe"
       Caption "${FRIENDLYNAME} - OpenVPN Made Portable"
       VIProductVersion "${VER}"
       VIAddVersionKey FileDescription "${FRIENDLYNAME}"
       VIAddVersionKey LegalCopyright "Lukas Landis"
       VIAddVersionKey OriginalFilename "${NAME}.exe"
       VIAddVersionKey FileVersion "${VER}"
!macroend

!macro RUNTIME_SWITCHES
       ;=== Runtime Switches
       CRCCheck On
       ;WindowIcon Off
       ;SilentInstall Silent
       AutoCloseWindow True
       SetCompressor /SOLID LZMA
       RequestExecutionLevel admin
!macroend

!macro PROGRAM_ICON ICONNAME
       ;=== Program Icon
       Icon "${ICONNAME}.ico"
       !define MUI_ICON "${ICONNAME}.ico"
!macroend

