
Option Explicit

Dim WSHShell, fso, oArgs
Dim root, target, directory, fileList, file
Dim line, FileIn, FileOut, vsettings, tempdir, temp, nsis

Set WSHShell = WScript.CreateObject("WScript.Shell") 
Set fso      = WScript.CreateObject("Scripting.FileSystemObject") 
set oArgs    = Wscript.Arguments

function WSHShellRun(exe, arg)
  WSHShell.Run exe & " " & arg, , true
end function

root=fso.GetFolder(".")
nsis="C:\Program Files (x86)\NSIS\Unicode\makensis.exe"

'Load settings
If fso.FileExists( root & "\settings" ) then
	Set FileIn   = fso.OpenTextFile( root & "\settings" , 1, true)
	Do While Not ( FileIn.atEndOfStream )
	    ' wenn Datei nicht zu Ende ist, weiter machen
		line = FileIn.Readline
		
		vsettings = Split( line, "=" )

		If vsettings(0) = "nsis" then nsis=vsettings(1)
	Loop

FileIn.Close
Set FileIn = nothing
End If

If not fso.FileExists(nsis) then nsis = InputBox("makensis.exe (Please full path incl. file)?")

'Save settings
Set FileOut = fso.CreateTextFile(root & "\settings", true)
FileOut.WriteLine( "nsis=" & nsis )
FileOut.Close
Set FileOut = nothing

delFolderIfExists root & "\OutFolder"

If fso.FileExists(nsis) then
	WSHShellRun """" & nsis & """", """" & root & "\other\OpenVPNPortableSource\DriverInstaller.nsi"""
	WSHShellRun """" & nsis & """", """" & root & "\other\OpenVPNPortableSource\DriverUninstaller.nsi"""
	
	WSHShellRun """" & nsis & """", """" & root & "\other\OpenVPNPortableSource\OpenVPNPortable.nsi"""
	WSHShellRun """" & nsis & """", "/DAdmin=true """ & root & "\other\OpenVPNPortableSource\OpenVPNPortable.nsi"""
	    
    WSHShellRun """" & nsis & """", """" & root & "\other\TinyOpenVPNGuiNSIS\TinyOpenVPNGui.nsi"""

	WSHShellRun """" & nsis & """", """" & root & "\other\OpenVPNPortableSource\Installer.nsi"""
Else
	MsgBox("File """ & nsis & """ does not exist. Script ends")
	WScript.Quit
End If

delFolderIfExists root & "\OutFolder"

MsgBox "Script successful finished"

WScript.Quit

Sub delFolderIfExists(folder)
	If fso.FolderExists(folder) then 
        fso.DeleteFolder folder, true
    End If
End Sub

Sub delFileIfExists(file)
	If fso.FileExists(file) then
        MsgBox(file & "exists -> delete file")
        fso.DeleteFile file, true
    End If
End Sub
