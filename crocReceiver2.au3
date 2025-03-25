#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Images\CrocReceiveGui.ico
#AutoIt3Wrapper_Outfile=CrocReceiverGui.Exe
#AutoIt3Wrapper_Outfile_x64=CrocReceiverGui.Exe
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=GUI written in AutoIt for easier usage of Croc from Schollz. Allows easier sharing between friends by using URI Registration and creating Links, that are usabel in Discord via a redirecting Webpage.
#AutoIt3Wrapper_Res_Description=Simple GUI for easier Croc Usage
#AutoIt3Wrapper_Res_Fileversion=0.9.0.8
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_ProductVersion=2
#AutoIt3Wrapper_Res_CompanyName=noorg
#AutoIt3Wrapper_Res_LegalCopyright=-
#AutoIt3Wrapper_Res_LegalTradeMarks=-
#AutoIt3Wrapper_Res_HiDpi=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#EndRegion 
;**** Directives created by AutoIt3Wrapper_GUI ****
;Created with ISN AutoIt Studio v. 1.15
;*****************************************

;Make this script high DPI aware
;AutoIt3Wrapper directive for exe files, DllCall for au3/a3x files
If not @Compiled then DllCall("User32.dll", "bool", "SetProcessDPIAware")

#NoTrayIcon

;Includes
#include <GUIConstants.au3>
#include <GUIListView.au3>
#include <WinAPIEx.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <Constants.au3>
#include <mnemonic.au3>

;When already one Process of CrocReceiverGui.exe is running the file will be saveed in a temp directory which will be processed during
;runtime. In the temp files the information about the target files are saved. Sadly there is one file for every file which will be send.
;After processing the temp files will be deleted. But still multiple read and writes on the harddisk :(
;Filename will automatically be read through the temp files by the existing (main) CrocReceiverGui.exe, added to the file list and then deleted.

;Even when low chance making sure that there are no duplicate files with Random and Checks for existing files

DirCreate ( @ScriptDir & "\tmpfiles\" )

$processpid = ProcessExists("CrocReceiverGui.exe")
if $processpid <> @AutoItPID Then
	if $CmdLine[0] <> "0" Then
			if StringInStr($CmdLine[1], "croc://") <> 1 Then
				while 1
					$rand = Random(1,  999999999999)
					If FileExists( @ScriptDir & "\tmpfiles\" & $rand ) <> 1  Then
						FileWriteLine ( @ScriptDir & "\tmpfiles\" & $rand , $CmdLine[1] )
						Exit 
					EndIf
				WEnd 
			EndIf
	EndIf

EndIf

;Check if croc.exe is available
if FileExists(@ScriptDir & "\croc.exe") = 0 Then
	msgbox(0, "Croc missing", "Please put file into folder with croc.exe. Program will not work without CROC in the Script Folder")
	Exit
EndIf

;Include the GUI File
#include "crocLink.isf"
#include "crocGui.isf"

;Register Drag & Drop
Global $__aGUIDropFiles = 0, $crocGui = 0
GUIRegisterMsg($WM_DROPFILES, 'WM_DROPFILES')

;If Code in Argument Disable the Send and Info Part of the GUI
;Else Add Argument into the ListView -> File or Folder
if $CmdLine[0] <> "0" Then
	if StringInStr($CmdLine[1], "croc://") = 1 Then
		GUICtrlSetState($gui_code, $GUI_DISABLE)
		GUICtrlSetState($gui_group_send, $GUI_DISABLE)
		GUICtrlSetState($info_files, $GUI_DISABLE)
		GUICtrlSetState($gui_files, $GUI_DISABLE)
		GUICtrlSetState($gui_clearlist, $GUI_DISABLE)
		GUICtrlSetState($gui_startsend, $GUI_DISABLE)
		GUICtrlSetState($gui_group_info, $GUI_DISABLE)
		GUICtrlSetState($gui_info, $GUI_DISABLE)
		GUICtrlSetState($gui_uninstall, $GUI_DISABLE)
		GuiCtrlSetData($gui_code, StringTrimRight(StringTrimLeft($CmdLine[1], 7), 1))
	Else
		_GUICtrlListView_AddItem($gui_files, $CmdLine[1])
	EndIf
EndIf

$versionTested = "10.2.2"
VersionCheck() 

;Check Registry if registered and set text accordingly
Call("RegCheck")

;Read Ini File to set last used download path
if IniRead(@ScriptDir & "\config.ini", "path", "save", "0") <> "0" Then
	GuiCtrlSetData($gui_savelocation, IniRead(@ScriptDir & "\config.ini", "path", "save", "0"))
EndIf

;Create GUI
GUISetState()

;Loop and wait for Cases
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $GUI_EVENT_DROPPED
			For $i = 1 To $__aGUIDropFiles[0]
				_GUICtrlListView_AddItem($gui_files, $__aGUIDropFiles[$i])
			Next
		Case $gui_clearlist
			_GUICtrlListView_DeleteAllItems($gui_files)
		Case $gui_browse
			Call("set_save_path")
		Case $gui_startreceive
			Call("receive_files")
		Case $gui_startsend
			Call("Send_Files")
		Case $gui_uninstall
			Call("RegCheckDo")
	EndSwitch

; Process temp files while runtime and add to ListView, runs till programm is terminated
	$firstFile = FileFindFirstFile ( @ScriptDir & "\tmpfiles\*" )
	if $firstFile <> -1 Then
	   $nextFile = FileFindNextFile( $firstFile )
	   $filetoadd = FileReadLine( @ScriptDir & "\tmpfiles\" & $nextFile, 1 )
	   _GUICtrlListView_AddItem($gui_files, $filetoadd)
	   FileDelete ( @ScriptDir & "\tmpfiles\" & $nextFile )
	EndIf
WEnd

;Functions

;Get Admin Rights for Registry Installation
Func _GetAdminRight($sCmdLineRaw = "")
	If Not IsAdmin() Then
		If Not $sCmdLineRaw Then $sCmdLineRaw = $CmdLineRaw
		ShellExecute(@AutoItExe, $sCmdLineRaw, "", "runas")
		ProcessClose(@AutoItPID)
		Exit
	EndIf
EndFunc   ;==>_GetAdminRight

;Check Registry for Installation and change text
Func RegCheck()
	if RegRead("HKEY_CLASSES_ROOT\croc\shell\open\command", "") = "" Then
		GUICtrlSetData($gui_info, "Registry Extension NOT INSTALLED. Click to install")
	ElseIf RegRead("HKEY_CLASSES_ROOT\croc\shell\open\command", "") <> "" Then
		GUICtrlSetData($gui_info, "Registry Extension INSTALLED. Click to remove from registry")
	EndIf
EndFunc   ;==>RegCheck

;Install or Uninstall to Registry, Decision 
Func RegCheckDo()
	if RegRead("HKEY_CLASSES_ROOT\croc\shell\open\command", "") = "" Then
		RegInstall()
	ElseIf RegRead("HKEY_CLASSES_ROOT\croc\shell\open\command", "") <> "" Then
		RegUninstall()
	EndIf
	Call("RegCheck")
EndFunc   ;==>RegCheckDo

;Install or Uninstall to Registry, Uninstall
Func RegUninstall()
	If Not IsAdmin() Then _GetAdminRight()
	RegDelete("HKEY_CLASSES_ROOT\croc")
	RegDelete("HKEY_CLASSES_ROOT\*\shell\croc")
	RegDelete("HKEY_CLASSES_ROOT\Directory\shell\croc")
	msgbox(0, "CrocReceiver", "CrocReceiver is now uninstalled")
EndFunc   ;==>RegUninstall

;Install or Uninstall to Registry, Install
Func RegInstall()
	If Not IsAdmin() Then _GetAdminRight()
	RegWrite("HKEY_CLASSES_ROOT\croc\shell\open\command", "", "REG_SZ", '"' & @ScriptDir & '\CrocReceiverGUI.exe" "%1"')
	RegWrite("HKEY_CLASSES_ROOT\croc", "URL Protocol", "REG_SZ", "")
	RegWrite("HKEY_CLASSES_ROOT\*\shell\croc\command", "", "REG_SZ", '"' & @ScriptDir & '\CrocReceiverGUI.exe" "%1"')
	RegWrite("HKEY_CLASSES_ROOT\*\shell\croc", "", "REG_SZ", "Send it with Croc")
	RegWrite("HKEY_CLASSES_ROOT\*\shell\croc", "MultiSelectModel", "REG_SZ", "Player")
	RegWrite("HKEY_CLASSES_ROOT\Directory\shell\croc\command", "", "REG_SZ", '"' & @ScriptDir & '\CrocReceiverGUI.exe" "%1"')
	RegWrite("HKEY_CLASSES_ROOT\Directory\shell\croc", "", "REG_SZ", "Send it with Croc")
	RegWrite("HKEY_CLASSES_ROOT\Directory\shell\croc", "MultiSelectModel", "REG_SZ", "Player")
	msgbox(0, "CrocReceiver", "CrocReceiver is now installed")
EndFunc   ;==>RegInstall

;Send Files Button
Func Send_Files()
	;Check Listview for entries and Build a String with all files
	Local $file_string
	$listview_count = _GUICtrlListView_GetItemCount($gui_files)
	if $listview_count = "0" Then
		msgbox(0, "No Files", "No files selected, please select files or folders for sending")
	Else
		for $f = 0 To $listview_count - 1
			$file_string = $file_string & ' "' & _GUICtrlListView_GetItemText($gui_files, $f) & '"'
		Next
		;Prepare string by removing Linebreaks and add croc parameters 
		;For better checking a Code-Phrase will be generated and used in the Croc Parameters
		;mnemonic words are the same as croc has. 4numbers+3words will be generated
		$secret =  GenPassPhrase()
		$file_string = StringReplace($file_string, @CRLF, '')
		$file_string = "send --code " & $secret & $file_string
		GuiSetState(@SW_HIDE, $crocGui)
		ShellExecute(@ScriptDir & "\croc.exe", $file_string, @ScriptDir )
		;Wait for Clipboard Input -> Code-Phrase is set to clipboard from Croc autoamtically
		;Will be checked against $secret by crocReceive. If they match croc is done with the preparation of the files
		While 1
			sleep(500)
			$ClipTest =  ClipGet()
			;When Clipboard is changed and Checks are correct open Gui for Selection (Copy only Code or with URL)
			if $ClipTest =  $secret Then
				$code_code = $secret
				$code_url = "https://shvnrg.github.io/crocdirect.html?" & $secret
				GUISetState(@SW_SHOW, $crocLink)
				WinActivate( "crocLink")
				GuiCtrlSetData($code_croccode, $code_code)
				GuiCtrlSetData($code_crocurl, $code_url)
				;Loop and wait for Cases
				While 1
					$nMsg = GUIGetMsg()
					Switch $nMsg
						Case $GUI_EVENT_CLOSE
							Exit
						Case $copy_code
							ClipPut($code_croccode)
							Exit 
						Case $copy_url
							ClipPut($code_url)
							Exit 
					EndSwitch
				WEnd
			EndIf
			
			
		Wend
	EndIf
EndFunc   ;==>Send_Files

;Check for Code and Save Location and start croc with parameters
Func receive_files()
	if GuiCtrlRead($gui_savelocation) = "" Or GUICtrlRead($gui_code) = "" Then
		msgbox(0, "Error", 'Please enter values for "Code" and "Save to"')
	Else
		ShellExecute(@scriptDir & '\croc.exe', GUICtrlRead($gui_code), GuiCtrlRead($gui_savelocation))
		Exit

	EndIf
EndFunc   ;==>receive_files

;Browse the Save Location and when choosen write in Ini File, Default is "My Computter"
Func set_save_path()
	$default_path = IniRead(@ScriptDir & "\config.ini", "path", "save", "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
	$save_path = FileSelectFolder("Choose Folder to Save Files", $default_path)
	if $save_path = "" Then
		$save_path = $default_path
	EndIf
	GuiCtrlSetData($gui_savelocation, $save_path)
	IniWrite(@ScriptDir & "\config.ini", "path", "save", $save_path)
EndFunc   ;==>set_save_path

;Functin for Drag and Drop Files into the GUI
Func WM_DROPFILES($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $lParam
	Switch $iMsg
		Case $WM_DROPFILES
			Local Const $aReturn = _WinAPI_DragQueryFileEx($wParam)
			If UBound($aReturn) Then
				$__aGUIDropFiles = $aReturn
			Else
				Local Const $aError[1] = [0]
				$__aGUIDropFiles = $aError
			EndIf
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_DROPFILES

Func VersionCheck()
	$crocStream = Run(@ScriptDir & "\croc.exe -v",@ScriptDir,@SW_HIDE,$STDOUT_CHILD)
	$l = 50
	While $l > 0
	   $StreamOut = StdoutRead($crocStream)
	   If StringInStr($StreamOut, "version") Then
		  $versionCroc = StringReplace( $StreamOut, "croc version v", "")
		  ExitLoop
	   EndIf
	   $l = $l - 1
	   Sleep(100)
	WEnd
	$versionCroc = StringReplace($versionCroc, @crlf, "")
	$versionCroc = StringReplace($versionCroc, @cr, "")
	$versionCroc = StringReplace($versionCroc, @lf, "")
	if $versionCroc = $versionTested Then
		GuiCtrlSetData($guiVersionInfo, "Croc Version: v" & $versionCroc & " (tested)" )
	Else
		GuiCtrlSetData($guiVersionInfo, "Croc Version: v" & $versionCroc & " (untested. latest tested Version: v" & $versionTested & ")" )

	EndIf
EndFunc

;Quit the Programm
Func quit()
	Exit
EndFunc   ;==>quit
