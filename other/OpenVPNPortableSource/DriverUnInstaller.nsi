;Copyright (C) 2004-2005 John T. Haller
;Portions Copyright 2007 Lukas Landis

;This software is OSI Certified Open Source Software.
;OSI Certified is a certification mark of the Open Source Initiative.

;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation; either version 2
;of the License, or (at your option) any later version.

;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.

;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

!include "StrFunc.nsh"
!include "DriverCommon.nsh"
!include "CommonVariables.nsh"
!include "UAC.nsh"

!insertmacro DEFINES "DriverUnInstaller"
!insertmacro PROGRAM_DETAILS
!insertmacro RUNTIME_SWITCHES
!insertmacro PROGRAM_ICON ${NAME}

WindowIcon Off
SilentInstall Silent

!system 'md "${OutputFolder}"'

# Variables
Var INIPATH
Var PROGRAMDIRECTORY
Var WindowsVersion
Var CPU

# Include language files
!include "Lang\DriverUnInstaller\*.nsh"

# Call to initialize
${StrRep}
${StrLoc}

Section "Main"
	uac_tryagain:
	!insertmacro UAC_RunElevated
	${Switch} $0
	${Case} 0
		${IfThen} $1 = 1 ${|} Quit ${|}
		${IfThen} $3 <> 0 ${|} ${Break} ${|}
		${If} $1 = 3
			MessageBox mb_YesNo|mb_IconExclamation|mb_TopMost|mb_SetForeground "This app requires admin privileges, try again" /SD IDNO IDYES uac_tryagain IDNO 0
		${EndIf}
	${Case} 1223
		MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "This app requires admin privileges, aborting!"
		Quit
	${Case} 1062
		MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Logon service not running, aborting!"
		Quit
	${Default}
		MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Unable to elevate , error $0"
		Quit
	${EndSwitch}

	nsisos::osversion
	${If} "$0" == "5"
		StrCpy "$WindowsVersion" "XP"
	${Else}
		StrCpy "$WindowsVersion" "Vista"
	${EndIf}
	
	System::Call "kernel32::GetCurrentProcess() i .s"
	System::Call "kernel32::IsWow64Process(i s, *i .r0)"
	
	${If} $0 == 0
		StrCpy $CPU `win32`
	${Else}
		StrCpy $CPU `win64`
	${EndIf}
	
	IfFileExists "$EXEDIR\Data\OpenVPNPortable.ini" "" NoINI
		StrCpy "$INIPATH" "$EXEDIR\Data"
	
		ReadINIStr $0 "$INIPATH\OpenVPNPortable.ini" "OpenVPNPortable" "OpenVPNDirectory"
		${StrRep} "$PROGRAMDIRECTORY" "$EXEDIR\$0" "%WinVer%" "$WindowsVersion"

		Goto EndINI

	NoINI:		
		${StrRep} "$PROGRAMDIRECTORY" "$EXEDIR\${DEFAULTAPPDIR}" "%WinVer%" "$WindowsVersion"
	
	EndINI:		
		Push "ExecDos::End" ;Add a marker for the loop to test for.
		ExecDos::exec /TOSTACK `"$PROGRAMDIRECTORY\tapinstall$CPU.exe" remove "${DRIVERNAME}"` ""
		Pop $0
		${If} $0 != "0" ;If we got an error...
			Goto ErrorInstalling
		${ElseIF} $0 == "0" ;If it was successfully uninstalled...## Loop through stack.
			Loop:
				Pop $1
				StrCmp $1 "ExecDos::End" ExitLoop
				${StrLoc} $0 "$1" "failed" "<"
				${IfNotThen} $0 == "" ${|} Goto ErrorInstalling ${|}
				Goto Loop
			ExitLoop:

			Goto Salir
		${EndIf}

		Goto Salir
		
	ErrorInstalling:
		MessageBox MB_OK|MB_ICONEXCLAMATION `$(MAIN_UnInstall_Tap_Error)`
		Abort
		
	Salir:
SectionEnd