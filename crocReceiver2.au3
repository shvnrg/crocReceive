#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Images\CrocReceiveGui.ico
#AutoIt3Wrapper_Outfile=CrocReceiverGui.Exe
#AutoIt3Wrapper_Outfile_x64=CrocReceiverGui.Exe
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_HiDpi=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;crocReceiver2.au3 by shiva
;Erstellt mit ISN AutoIt Studio v. 1.15
;*****************************************

;Make this script high DPI aware
;AutoIt3Wrapper directive for exe files, DllCall for au3/a3x files
#AutoIt3Wrapper_Res_HiDpi=y
If not @Compiled then DllCall("User32.dll", "bool", "SetProcessDPIAware")

#include <GUIConstants.au3>
#include <GUIListView.au3>
#include <WinAPIEx.au3>
#include <WindowsConstants.au3>

Global $FromOtherScript

$processpid =  ProcessExists("CrocReceiverGui.Exe")
if  $processpid <> @AutoItPID  Then
	
	if $CmdLine[0] <> "0" Then
		if StringInStr( $CmdLine[1], "croc://" ) = 1 Then 
			 
		Else
			msgbox(0, "FetchMeIAmAFile! " & Random(1 , 999999999999999999999), $CmdLine[1], 15)
			Exit 
		EndIf 
	EndIf 
	
EndIf


FileDelete( @ScriptDir & "\output.tmp.del")

if FileExists( @ScriptDir & "\croc.exe") = 0 Then 
	msgbox(0, "Croc missing",  "Please put file into folder with croc.exe. Program will not work without CROC in the Script Folder") 
	Exit 
EndIf

#include "crocGui.isf"

Global $__aGUIDropFiles = 0, $crocGui = 0
GUIRegisterMsg($WM_DROPFILES, 'WM_DROPFILES')

;Test für Nur Empfangen



if $CmdLine[0] <> "0" Then
	if StringInStr( $CmdLine[1], "croc://" ) = 1 Then 
		GUICtrlSetState($gui_code, $GUI_DISABLE )
		GUICtrlSetState($gui_group_send, $GUI_DISABLE )
		GUICtrlSetState($info_files, $GUI_DISABLE )
		GUICtrlSetState($gui_files, $GUI_DISABLE )
		GUICtrlSetState($gui_clearlist, $GUI_DISABLE )
		GUICtrlSetState($gui_startsend, $GUI_DISABLE )
		GUICtrlSetState($gui_group_info, $GUI_DISABLE )
		GUICtrlSetState($gui_info, $GUI_DISABLE )
		GUICtrlSetState($gui_uninstall, $GUI_DISABLE )
		
		GuiCtrlSetData($gui_code, StringTrimRight(StringTrimLeft($CmdLine[1], 7), 1))
	Else 
		for $e = 1 To $CmdLine[0]
			_GUICtrlListView_AddItem ( $gui_files, $CmdLine[$e] )
		Next 		
	EndIf 
EndIf 

Call ("RegCheck")

if IniRead ( "config.ini", "path", "save", "0" ) <>  "0" Then 
	GuiCtrlSetData($gui_savelocation, IniRead ( "config.ini", "path", "save", "0" ) )
EndIf

GUISetState()


While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            Exit
		Case $GUI_EVENT_DROPPED
            For $i = 1 To $__aGUIDropFiles[0]
				_GUICtrlListView_AddItem ( $gui_files, $__aGUIDropFiles[$i] )
             Next
		Case $gui_clearlist
			_GUICtrlListView_DeleteAllItems ( $gui_files )
		Case $gui_browse
			Call ("set_save_path")
		Case $gui_startreceive
			Call("receive_files")
		Case $gui_startsend
			Call ("Send_Files")
		Case $gui_uninstall
			Call ("RegCheckDo")
	EndSwitch
	
	if WinExists("FetchMeIAmAFile!") Then 
		$window =  WinGetTitle ( "FetchMeIAmAFile!" )
		_GUICtrlListView_AddItem ( $gui_files, StringTrimRight(StringTrimLeft(WinGetText($window),3), 1))
		WinClose ( $window )
	EndIf

WEnd

Func _GetAdminRight($sCmdLineRaw = "")
    If Not IsAdmin() Then
        If Not $sCmdLineRaw Then $sCmdLineRaw = $CmdLineRaw
        ShellExecute(@AutoItExe, $sCmdLineRaw, "", "runas")
        ProcessClose(@AutoItPID)
        Exit
    EndIf
EndFunc

Func RegCheck()
	if RegRead ( "HKEY_CLASSES_ROOT\croc\shell\open\command", "" ) =  "" Then 
		GUICtrlSetData($gui_info, "Registry Extension NOT INSTALLED. Click to install")
		
	ElseIf  RegRead ( "HKEY_CLASSES_ROOT\croc\shell\open\command", "" ) <> "" Then 
		GUICtrlSetData($gui_info, "Registry Extension INSTALLED. Click to remove from registry")
		
	EndIf
EndFunc

Func RegCheckDo()
	if RegRead ( "HKEY_CLASSES_ROOT\croc\shell\open\command", "" ) =  "" Then 
		RegInstall()
		
	ElseIf  RegRead ( "HKEY_CLASSES_ROOT\croc\shell\open\command", "" ) <> "" Then 
		RegUninstall()
		
	EndIf
	Call ("RegCheck")
EndFunc

Func RegUninstall()
	
	If Not IsAdmin() Then _GetAdminRight()
		
		RegDelete ( "HKEY_CLASSES_ROOT\croc")
		RegDelete ( "HKEY_CLASSES_ROOT\*\shell\croc")
		RegDelete ( "HKEY_CLASSES_ROOT\Directory\shell\croc")
		
		msgbox(0,  "CrocReceiver",  "CrocReceiver is now uninstalled")
	
EndFunc

Func RegInstall()
	
		If Not IsAdmin() Then _GetAdminRight()
		
		RegWrite ( "HKEY_CLASSES_ROOT\croc\shell\open\command" , "", "REG_SZ", '"' & @ScriptDir &  '\CrocReceiverGUI.exe" "%1"' )
		RegWrite ( "HKEY_CLASSES_ROOT\croc" , "URL Protocol", "REG_SZ", "" )
		
		RegWrite ( "HKEY_CLASSES_ROOT\*\shell\croc\command" , "", "REG_SZ", '"' & @ScriptDir &  '\CrocReceiverGUI.exe" "%1"' )
		RegWrite ( "HKEY_CLASSES_ROOT\*\shell\croc" , "", "REG_SZ", "Send it with Croc" )
		
		RegWrite ( "HKEY_CLASSES_ROOT\Directory\shell\croc\command" , "", "REG_SZ", '"' & @ScriptDir &  '\CrocReceiverGUI.exe" "%1"' )
		RegWrite ( "HKEY_CLASSES_ROOT\Directory\shell\croc" , "", "REG_SZ", "Send it with Croc" )
		
		msgbox(0,  "CrocReceiver",  "CrocReceiver is now installed")
	
EndFunc






Func Send_Files()
	
	FileDelete("output.tmp.del")
	
	Local $file_string
	
	$listview_count=  _GUICtrlListView_GetItemCount ( $gui_files )
	if $listview_count = "0" Then 
		msgbox(0, "No Files",  "No files selected, please select files or folders for sending")
	Else 
		for $f = 0 To $listview_count - 1
			$file_string = $file_string & ' "' & _GUICtrlListView_GetItemText ( $gui_files, $f ) & '"'
			
		Next
		$file_string = StringReplace($file_string, @CRLF, '')
		$file_string = "--debug send" & $file_string
		
		Run(@ComSpec & ' /k ""' & @ScriptDir & '\croc.exe" ' & $file_string & ' > output.tmp.del"', @ScriptDir)
		
		
		$search =  1
		while $search =  1
			$debug_file =  FileRead ( @ScriptDir & "\output.tmp.del" )
			if StringInStr($debug_file, "Debug:true", 1) Then
				$search = 0
				$debug_file =  StringTrimLeft($debug_file, StringInStr($debug_file, "SharedSecret:", 1) + 12)
				$debug_file =  StringTrimRight($debug_file, StringLen($debug_file) - StringInStr($debug_file, "Debug:true", 1) + 2 )
				$code_url =  "https://shvnrg.github.io/crocdirect.html?" & $debug_file
				ClipPut($code_url)
				msgbox(0, "Code extracted",  "Code was copied to Clipboard. Program closing. Have fun :)")
				Exit 
				
			EndIf

		Wend
		


	EndIf
	
	
	
EndFunc




Func receive_files()
	 if GuiCtrlRead($gui_savelocation) = "" Or  GUICtrlRead($gui_code) = "" Then 
		msgbox (0, "Error",  'Please enter values for "Code" and "Save to"')
	 Else
		ShellExecute(@scriptDir & '\croc.exe', GUICtrlRead($gui_code), GuiCtrlRead($gui_savelocation) )
		Exit
		 
	 EndIf
EndFunc

Func set_save_path()
	$default_path =  IniRead ( "config.ini", "path", "save", "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" )
	$save_path =  FileSelectFolder ( "Choose Folder to Save Files", $default_path)
	if $save_path = "" Then
		$save_path = $default_path
	EndIf
	GuiCtrlSetData($gui_savelocation, $save_path)
	IniWrite ( "config.ini", "path", "save", $save_path )
EndFunc

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

Func quit()
    Exit
EndFunc