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

# Force Admin App
;!define Admin "true"
!include "LogicLib.nsh"
!include "StrFunc.nsh"
!include "OpenVPNPortable.nsh"
!include "UAC.nsh"
!include "CommonVariables.nsh"

!insertmacro DEFINES "OpenVPNPortable"
!insertmacro PROGRAM_DETAILS
!insertmacro RUNTIME_SWITCHES
!insertmacro PROGRAM_VARIABLES
!insertmacro PROGRAM_ICON ${NAME}

WindowIcon Off
SilentInstall Silent

!include "logging.nsh"

!system 'md "${OutputFolder}"'

# Include language files
!include "Lang\OpenVPNPortable\*.nsh"

# Variables
Var INIPATH
Var PROGRAMDIRECTORY
Var DRIVERDIRECTORY
Var TAPINSTALLED
Var CONFIGDIRECTORY
Var LOGDIRECTORY
Var EXECSTRING
Var EXECBINARY
Var SHOWSPLASH
Var INSTBEHAVIOUR
Var UNINSTBEHAVIOUR
Var AUTOCONNECT
Var WindowsVersion
Var CPU

# Call to initialize
${StrRep}

Section "Main"
	CreateDirectory "$EXEDIR\Data\log"

	# Ckeck if the app is running
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "${NAME}Mutex") i .r1 ?e'
    Pop $R5
    StrCmp $R5 0 +3
    MessageBox MB_OK|MB_ICONQUESTION|MB_TOPMOST `$(MAIN_App_Running)`
    Quit


	# Get the OS version (5 = XP, other = Vista+)
	nsisos::osversion
	${If} "$0" == "5"
		StrCpy "$WindowsVersion" "XP"
	${Else}
		StrCpy "$WindowsVersion" "Vista"
	${EndIf}
	

	# Check the OS Architecture
	System::Call "kernel32::GetCurrentProcess() i .s"
	System::Call "kernel32::IsWow64Process(i s, *i .r0)"
	
	${If} $0 == 0
		StrCpy $CPU `win32`
	${Else}
		StrCpy $CPU `win64`
	${EndIf}

	
	# Check if ini file exists and read the options
	IfFileExists "$EXEDIR\Data\OpenVPNPortable.ini" "" NoINI
		StrCpy "$INIPATH" "$EXEDIR"

	ReadINIStr $0 "$INIPATH\OpenVPNPortable.ini" "OpenVPNPortable" "OpenVPNDirectory"
	${StrRep} "$PROGRAMDIRECTORY" "$EXEDIR\$0" "%WinVer%" "$WindowsVersion"
			
	ReadINIStr $0 "$INIPATH\OpenVPNPortable.ini" "Drivers" "DriverDirectory"
	${StrRep} "$DRIVERDIRECTORY" "$EXEDIR\$0" "%WinVer%" "$WindowsVersion"
			
	ReadINIStr $0 "$INIPATH\OpenVPNPortable.ini" "OpenVPNPortable" "ConfigDirectory"
	StrCpy $CONFIGDIRECTORY "$EXEDIR\$0"

	ReadINIStr $0 "$INIPATH\OpenVPNPortable.ini" "OpenVPNPortable" "LogDirectory"
	StrCpy $LOGDIRECTORY "$EXEDIR\$0"
	
	ReadINIStr $0 "$INIPATH\OpenVPNPortable.ini" "OpenVPNPortable" "ShowSplash"
	StrCpy $SHOWSPLASH "$0"

	ReadINIStr $0 "$INIPATH\OpenVPNPortable.ini" "OpenVPNPortable" "DriverInstBehaviour"
	StrCpy $INSTBEHAVIOUR "$0"

	ReadINIStr $0 "$INIPATH\OpenVPNPortable.ini" "OpenVPNPortable" "DriverUnInstBehaviour"
	StrCpy $UNINSTBEHAVIOUR "$0"

	ReadINIStr $0 "$INIPATH\OpenVPNPortable.ini" "OpenVPNPortable" "AutoConnect"
	StrCpy $AUTOCONNECT "$0"

	ReadINIStr $0 "$INIPATH\OpenVPNPortable.ini" "OpenVPNPortable" "ShowGUI"
	StrCpy $EXECBINARY "$0"
	
	IfErrors NoINI
	
	Goto ProgramCheck

	
	
NoINI:	
	StrCpy "$PROGRAMDIRECTORY" "$EXEDIR\${DEFAULTAPPDIR}"
	StrCpy $EXECBINARY ${DEFAULTEXE}

	StrCpy "$DRIVERDIRECTORY" "$EXEDIR\${DEFAULTDRVDIR}"

	StrCpy $CONFIGDIRECTORY "$EXEDIR\${DEFAULTCONFIGDIR}"

	StrCpy $SHOWSPLASH "true"

	StrCpy $INSTBEHAVIOUR "ask"

	StrCpy $UNINSTBEHAVIOUR "ask"

	StrCpy $AUTOCONNECT "false"

	StrCpy $LOGDIRECTORY "$EXEDIR\${DEFAULTLOGDIR}"

	
ProgramCheck:
	${StrRep} "$PROGRAMDIRECTORY" "$PROGRAMDIRECTORY" "%WinVer%" "$WindowsVersion"
	${StrRep} "$DRIVERDIRECTORY" "$DRIVERDIRECTORY" "%WinVer%" "$WindowsVersion"
	${StrRep} "$DRIVERDIRECTORY" "$DRIVERDIRECTORY" "%CPU%" "$CPU"

	IfFileExists "$PROGRAMDIRECTORY\${DEFAULTEXE}" "" NoProgramEXE
	IfFileExists "$DRIVERDIRECTORY\${DRIVERFILE}" "" NoDriverFile
	IfFileExists "$CONFIGDIRECTORY\${CONFIGFILE}" "" NoConfigFile
	Goto logCheck
	
	NoProgramEXE:
		MessageBox MB_OK|MB_ICONEXCLAMATION `$PROGRAMDIRECTORY\${DEFAULTEXE} $(MAIN_Not_Found)`
		Abort
		
	NoDriverFile:
		MessageBox MB_OK|MB_ICONEXCLAMATION `$DRIVERDIRECTORY\${DRIVERFILE} $(MAIN_Not_Found)`
		Abort
		
	NoConfigFile:
		MessageBox MB_OK|MB_ICONEXCLAMATION `$(MAIN_No_Config)`
		Abort


LogCheck:
	IfFileExists "$LOGDIRECTORY\*.*" LogDirExists ""
		CreateDirectory "$LOGDIRECTORY"


LogDirExists:
	InstDrv::InitDriverSetup /NOUNLOAD "${DRIVERID}" "${DRIVERNAME}"
	InstDrv::CountDevices
	Pop $0
	${If} "$0" == "0"
		${If} $INSTBEHAVIOUR == "ask"
			MessageBox MB_YESNO|MB_ICONQUESTION `$(MAIN_Install_Tap)` IDNO Salir
		${EndIf}
	
		SetOutPath "$EXEDIR"
		File "${OutputFolder}\DriverInstaller.exe"
		ExecWait "$EXEDIR\DriverInstaller.exe" $0
		Delete "$EXEDIR\DriverInstaller.exe"

		${If} "$0" == "0"
			StrCpy $TAPINSTALLED true
		${Else}
			MessageBox MB_OK|MB_ICONEXCLAMATION `$(MAIN_Install_Tap_Error)`
			Abort
		${EndIf}
	${EndIf}
	
	${If} $EXECBINARY == ${DEFAULTEXE}
		StrCpy $EXECSTRING `"$PROGRAMDIRECTORY\${DEFAULTEXE}" --config_dir "$CONFIGDIRECTORY" --ext_string "ovpn" --exe_path "$PROGRAMDIRECTORY\openvpn.exe" --log_dir "$LOGDIRECTORY" --priority_string "NORMAL_PRIORITY_CLASS" --append_string "0"`
	
		Call GetParameters
		Pop $0	
		${If} "$0" != ""
			StrCpy "$EXECSTRING" "$EXECSTRING $0"
		${EndIf}
	${Else}
		StrCpy $EXECSTRING `"$PROGRAMDIRECTORY\${TINYEXE}" --config_dir "$CONFIGDIRECTORY" --exe_path "$PROGRAMDIRECTORY"`
	${EndIf}
	
	${If} $AUTOCONNECT != "false"
		StrCpy "$EXECSTRING" "$EXECSTRING --connect_to $AUTOCONNECT"
	${EndIf}
	
	InstDrv::InitDriverSetup /NOUNLOAD "${DRIVERID}" "${DRIVERNAME}"
	InstDrv::CountDevices
		Pop $0
		${If} "$0" == "0"
			MessageBox MB_OK|MB_ICONEXCLAMATION `$(MAIN_Install_Tap_Error)`
			Abort
		${EndIf}

	${If} $SHOWSPLASH == "true"
		File /oname=$PLUGINSDIR\splash.jpg "${NAME}.jpg"
		newadvsplash::show /NOUNLOAD 2000 400 400 -1 /NOCANCEL $PLUGINSDIR\splash.jpg
	${EndIf}

	ExecWait $EXECSTRING
	;INSERT HERE new command	
	
	


	${If} $TAPINSTALLED == true
		${If} $UNINSTBEHAVIOUR == "ask"
			MessageBox MB_YESNO|MB_ICONQUESTION `$(MAIN_Uninstall_Tap)` IDNO Salir
		${ElseIf} $UNINSTBEHAVIOUR == "false"
			Goto Salir
		${EndIf}
	
		SetOutPath "$EXEDIR"
		File "${OutputFolder}\DriverUninstaller.exe"
		ExecWait "$EXEDIR\DriverUninstaller.exe" $0
		Delete "$EXEDIR\DriverUninstaller.exe"

		${If} "$0" != "0"
			MessageBox MB_OK|MB_ICONEXCLAMATION `$(MAIN_UnInstall_Tap_Error)`
			Abort
		${Else}
			MessageBox MB_OK `$(MAIN_Uninstall_Tap_Ok)`
			Goto Salir
		${EndIf}
	${EndIf}
	
	
	Salir:
		newadvsplash::stop /WAIT
		Sleep 2000*/
		${LogWithTime} "---------------------------------------------------------------------------------------------------"
		SetErrorLevel 0
SectionEnd

Function GetParameters
	; GetParameters
	; input, none
	; output, top of stack (replaces, with e.g. whatever)
	; modifies no other variables. 

	Push $R0
	Push $R1
	Push $R2
	Push $R3

	StrCpy $R2 1
	StrLen $R3 $CMDLINE

	;Check for quote or space
	StrCpy $R0 $CMDLINE $R2
	StrCmp $R0 '"' 0 +3
		StrCpy $R1 '"'
		Goto loop
	StrCpy $R1 " "

	loop:
		IntOp $R2 $R2 + 1
		StrCpy $R0 $CMDLINE 1 $R2
		StrCmp $R0 $R1 get
		StrCmp $R2 $R3 get
		Goto loop
  
	get:
		IntOp $R2 $R2 + 1
		StrCpy $R0 $CMDLINE 1 $R2
		StrCmp $R0 " " get
		StrCpy $R0 $CMDLINE "" $R2

	Pop $R3
	Pop $R2
	Pop $R1
	Exch $R0
FunctionEnd