;Copyright 2007 John T. Haller

;Website: http://PortableApps.com/

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

;EXCEPTION: Can be used with non-GPLed open source apps distributed by PortableApps.com

;=== Include
!include MUI.nsh
!include FileFunc.nsh
!include "CommonVariables.nsh"

!define NAME "OpenVPN Portable"
!define SHORTNAME "OpenVPNPortable"
!define VERSION "1.8.4.0"
!define FILENAME "OpenVPNPortable_1.8.4"
!define CHECKRUNNING "openvpn-gui.exe"
!define CLOSENAME "OpenVPN"

;=== Program Details
Name "${NAME}"
OutFile "..\..\${FILENAME}.paf.exe"
InstallDir "\${SHORTNAME}"
Caption "${NAME} | PortableApps.com Installer"
VIProductVersion "${VERSION}"
VIAddVersionKey ProductName "${NAME}"
VIAddVersionKey Comments "For additional details, visit PortableApps.com"
;VIAddVersionKey CompanyName "PortableApps.com"
VIAddVersionKey LegalCopyright "Lukas Landis and contributors"
VIAddVersionKey FileDescription "${NAME}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey InternalName "${NAME}"
;VIAddVersionKey LegalTrademarks "PortableApps.com is a Trademark of Rare Ideas, LLC."
VIAddVersionKey OriginalFilename "${FILENAME}.paf.exe"
;VIAddVersionKey PrivateBuild ""
;VIAddVersionKey SpecialBuild ""
BrandingText "OpenVPN Portable - Your private network, Anywhere™"

;=== Runtime Switches
;SetDatablockOptimize on
;SetCompress off
SetCompressor /SOLID lzma
CRCCheck on
RequestExecutionLevel user
ShowInstDetails show

!insertmacro GetOptions
!insertmacro GetDrives

;=== Program Icon
Icon "${SHORTNAME}.ico"

# MUI defines
!define MUI_ICON "${SHORTNAME}.ico"
!define MUI_WELCOMEPAGE_TITLE "${NAME}"
!define MUI_WELCOMEPAGE_TEXT "$(welcome)"
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CheckForRunningApp
;!define MUI_LICENSEPAGE_RADIOBUTTONS
!define MUI_FINISHPAGE_TEXT "$(finish)"

;=== Pages and their order
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!define MUI_FINISHPAGE_NOAUTOCLOSE
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Languages
!include "Installer_Lang_*.nsh"

;=== Variables
Var FOUNDPORTABLEAPPSPATH
Var BINPACKURL

Function .onInit
	;StrCpy $FOUNDPORTABLEAPPSPATH ''
	
	!insertmacro MUI_LANGDLL_DISPLAY

	${GetOptions} "$CMDLINE" "/DESTINATION=" $R0

	IfErrors CheckLegacyDestination
		StrCpy $INSTDIR "$R0${SHORTNAME}"
		Goto CheckUrlOption

	CheckLegacyDestination:
		ClearErrors
		${GetOptions} "$CMDLINE" "-o" $R0
		IfErrors NoDestination
			StrCpy $INSTDIR "$R0${SHORTNAME}"
			Goto CheckUrlOption

	NoDestination:
		ClearErrors
		${GetDrives} "HDD+FDD" GetDrivesCallBack
		StrCmp $FOUNDPORTABLEAPPSPATH "" DefaultDestination
			StrCpy $INSTDIR "$FOUNDPORTABLEAPPSPATH\${SHORTNAME}"
			Goto CheckUrlOption
		
	DefaultDestination:
		StrCpy $INSTDIR "$EXEDIR\${SHORTNAME}"

	CheckUrlOption:
		${GetOptions} "$CMDLINE" "/BINPACKURL=" $R0

	IfErrors CheckSecondUrlOption
		StrCpy $BINPACKURL "$R0"
		Goto InitDone
		
	CheckSecondUrlOption:
		ClearErrors
		${GetOptions} "$CMDLINE" "url" $R0

	IfErrors DefaultUrl
		StrCpy $BINPACKURL "$R0"
		Goto InitDone
		
	DefaultUrl:
		ClearErrors
		StrCpy $BINPACKURL "https://bitbucket.org/Danixu86/openvpn-portable/downloads"
	
	InitDone:
FunctionEnd

Function GetDrivesCallBack
	;=== Skip usual floppy letters
	StrCmp $8 "FDD" "" CheckForPortableAppsPath
	StrCmp $9 "A:\" End
	StrCmp $9 "B:\" End
	
	CheckForPortableAppsPath:
		IfFileExists "$9PortableApps" "" End
			StrCpy $FOUNDPORTABLEAPPSPATH "$9PortableApps"

	End:
		Push $0
FunctionEnd

Function CheckForRunningApp
	;=== Does it already exist? (upgrade)
	IfFileExists "$INSTDIR" "" End
		;=== Check if app is running?
		StrCmp ${CHECKRUNNING} "" End
			;=== Is it running?
			CheckRunning:
				FindProcDLL::FindProc "${CHECKRUNNING}"
				StrCmp $R0 "1" "" End
					MessageBox MB_OK|MB_ICONINFORMATION `$(runwarning)`
					Goto CheckRunning
	
	End:
FunctionEnd

SubSection $(SECTION_App)
	Section $(SECTION_App_OVpn_XP) OVpn_XP
		StrCmp "$BINPACKURL" "." CopyCurrent
			StrCpy $2 "$BINPACKURL/current_XP.txt"
			
			;get the latest version of the package.
			inetc::get /SILENT "$2" "$TEMP\new.txt" /END
			Pop $R0 ;Get the return value
				StrCmp $R0 "OK" 0 DownloadFailed
				Goto ReadFile
		
		CopyCurrent:
			StrCpy $2 "$EXEDIR/current_XP.txt"
			CopyFiles "$2" "$TEMP/new.txt"
			IfErrors DownloadFailed
				
		ReadFile:
			FileOpen $0 "$TEMP\new.txt" r
			FileRead $0 $1
			FileClose $0
			Delete /REBOOTOK "$TEMP\new.txt"
		
		StrCpy $2 "0.0.0"
		
		IfFileExists "$INSTDIR\current_XP.txt" 0 Compare
			FileOpen $0 "$INSTDIR\current_XP.txt" r
			FileRead $0 $2
			FileClose $0
		
		Compare:
			StrCmp "$1" "$2" End 0
		
		StrCmp "$BINPACKURL" "." CopyBinpack
			StrCpy $2 "$BINPACKURL/$1_XP.zip"
			
			;Download the package.
			inetc::get /POPUP "" /CAPTION "Get latest openvpn binaries..." $2 "$TEMP\current.zip" /END
			Pop $R0 ;Get the return value
				StrCmp $R0 "OK" Extract DownloadFailed
					
		CopyBinpack:
			StrCpy $2 "$EXEDIR/$1.zip"
			CopyFiles "$2" "$TEMP\current.zip"
			IfErrors DownloadFailed
			
		Extract:
			nsisunz::UnzipToLog "$TEMP\current.zip" "$INSTDIR"
			Pop $R0
			StrCmp $R0 "success" +2
				DetailPrint "$R0" ;print error message to log

			Delete /REBOOTOK "$TEMP\current.zip"
			
			FileOpen $0 $INSTDIR\current_XP.txt w
			FileWrite $0 $1
			FileClose $0
			
		CreateFolders:
			CreateDirectory "$INSTDIR\data"
			CreateDirectory "$INSTDIR\data\config"
			CreateDirectory "$INSTDIR\data\log"
			
			Goto End
		
		DownloadFailed:
			MessageBox MB_OK|MB_ICONSTOP "Unable to download file $2 ($R0)"
		
		End:
	SectionEnd
	
	Section $(SECTION_App_OVpn_Vista) OVpn_Vista
		StrCmp "$BINPACKURL" "." CopyCurrent
			StrCpy $2 "$BINPACKURL/current_Vista.txt"
			
			;get the latest version of the package.
			inetc::get /SILENT "$2" "$TEMP\new.txt" /END
			Pop $R0 ;Get the return value
				StrCmp $R0 "OK" 0 DownloadFailed
				Goto ReadFile
		
		CopyCurrent:
			StrCpy $2 "$EXEDIR/current_Vista.txt"
			CopyFiles "$2" "$TEMP/new.txt"
			IfErrors DownloadFailed
				
		ReadFile:
			FileOpen $0 "$TEMP\new.txt" r
			FileRead $0 $1
			FileClose $0
			Delete /REBOOTOK "$TEMP\new.txt"
		
		StrCpy $2 "0.0.0"
		
		IfFileExists "$INSTDIR\current_Vista.txt" 0 Compare
			FileOpen $0 "$INSTDIR\current_Vista.txt" r
			FileRead $0 $2
			FileClose $0
		
		Compare:
			StrCmp "$1" "$2" End 0
		
		StrCmp "$BINPACKURL" "." CopyBinpack
			StrCpy $2 "$BINPACKURL/$1_Vista.zip"
			
			;Download the package.
			inetc::get /POPUP "" /CAPTION "Get latest openvpn binaries..." $2 "$TEMP\current.zip" /END
			Pop $R0 ;Get the return value
				StrCmp $R0 "OK" Extract DownloadFailed
					
		CopyBinpack:
			StrCpy $2 "$EXEDIR/$1.zip"
			CopyFiles "$2" "$TEMP\current.zip"
			IfErrors DownloadFailed
			
		Extract:
			nsisunz::UnzipToLog "$TEMP\current.zip" "$INSTDIR"
			Pop $R0
			StrCmp $R0 "success" +2
				DetailPrint "$R0" ;print error message to log

			Delete /REBOOTOK "$TEMP\current.zip"
			
			FileOpen $0 $INSTDIR\current_Vista.txt w
			FileWrite $0 $1
			FileClose $0
			
		CreateFolders:
			CreateDirectory "$INSTDIR\data"
			CreateDirectory "$INSTDIR\data\config"
			CreateDirectory "$INSTDIR\data\log"
			
			Goto End
		
		DownloadFailed:
			MessageBox MB_OK|MB_ICONSTOP "Unable to download file $2 ($R0)"
		
		End:
	SectionEnd
	
	Section $(SECTION_App_User) App_User
		SetOutPath $INSTDIR

		File OpenVPNPortable.ini
		File ${OutputFolder}\OpenVPNPortable.exe
		
		SetOutPath $INSTDIR\app\AppInfo
		File /r "..\..\app\AppInfo\*.*"
		
		SectionGetFlags ${OVpn_XP} $R0
		${If} "$R0" == "0"
			SetOutPath $INSTDIR\app\XP\bin
			File ${OutputFolder}\TinyOpenVPNGui.exe
			
			SetOutPath $INSTDIR\app\XP\bin
			File ${OutputFolder}\TinyOpenVPNGui.exe			
		${EndIf}
		
		SectionGetFlags ${OVpn_XP} $R0
		${If} "$R0" == "1"
			SetOutPath $INSTDIR\app\XP\bin
			File ${OutputFolder}\TinyOpenVPNGui.exe
			
			SetOutPath $INSTDIR\app\XP\bin
			File /r "..\..\app\bin\*.*"			
		${EndIf}
		
		SectionGetFlags ${OVpn_Vista} $R0
		${If} "$R0" == "1"
			SetOutPath $INSTDIR\app\Vista\bin
			File ${OutputFolder}\TinyOpenVPNGui.exe
			
			SetOutPath $INSTDIR\app\Vista\bin
			File /r "..\..\app\bin\*.*"			
		${EndIf}
	SectionEnd

	Section $(SECTION_App_Admin) App_Admin
		SetOutPath $INSTDIR

		File OpenVPNPortable.ini
		SectionGetFlags ${App_User} $R0
		${If} "$R0" == "0"
			File "/oname=OpenVPNPortable.exe" ${OutputFolder}\OpenVPNPortable_admin.exe
		${Else}
			File ${OutputFolder}\OpenVPNPortable_admin.exe
		${EndIf}
		
		
		SetOutPath $INSTDIR\app\AppInfo
		File /r "..\..\app\AppInfo\*.*"
		
		SectionGetFlags ${OVpn_XP} $R0
		${If} "$R0" == "1"
			SetOutPath $INSTDIR\app\XP\bin
			File ${OutputFolder}\TinyOpenVPNGui.exe
			
			SetOutPath $INSTDIR\app\XP\bin
			File /r "..\..\app\bin\*.*"			
		${EndIf}
		
		SectionGetFlags ${OVpn_Vista} $R0
		${If} "$R0" == "1"
			SetOutPath $INSTDIR\app\Vista\bin
			File ${OutputFolder}\TinyOpenVPNGui.exe
			
			SetOutPath $INSTDIR\app\Vista\bin
			File /r "..\..\app\bin\*.*"			
		${EndIf}
	SectionEnd
SubSectionEnd

SubSection $(SECTION_Source)
	Section $(SECTION_Source_OpenVPNGui) App_Source_OpenVPNGui
		SetOutPath $INSTDIR\other\openvpn-gui-source
		File /r "..\..\other\openvpn-gui-source\*.*"
	SectionEnd

	Section $(SECTION_Source_OpenVPN) App_Source
		SetOutPath $INSTDIR\other\OpenVPNPortableSource
		File /r "..\..\other\OpenVPNPortableSource\*.*"
	SectionEnd

	Section $(SECTION_Source_TinyVpn) Tiny_Source
		SetOutPath $INSTDIR\other\TinyOpenVPNGuiNSIS
		File /r "..\..\other\TinyOpenVPNGuiNSIS\*.*"
	SectionEnd
SubSectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${App_User} $(DESC_App_User)
	!insertmacro MUI_DESCRIPTION_TEXT ${App_Admin} $(DESC_App_Admin)
	!insertmacro MUI_DESCRIPTION_TEXT ${OVpn_XP} $(DESC_OVpn_XP)
	!insertmacro MUI_DESCRIPTION_TEXT ${OVpn_Vista} $(DESC_OVpn_Vista)
	!insertmacro MUI_DESCRIPTION_TEXT ${App_Source} $(DESC_App_Source)
	!insertmacro MUI_DESCRIPTION_TEXT ${Tiny_Source} $(DESC_Tiny_Source)
!insertmacro MUI_FUNCTION_DESCRIPTION_END