#include "CrocReceiver_GUI.isf"
#include <MsgBoxConstants.au3>
#include <TrayConstants.au3>
#NoTrayIcon

Global $path,  $code

if FileExists( @ScriptDir & "\croc.exe") =  0 Then 
	
	if Not IsAdmin() then 
		msgbox(0, "Croc missing",  "Please put file into folder with croc.exe. Registry will be cleaned if old entries are found.") 
	EndIf 
		
	if RegRead ( "HKEY_CLASSES_ROOT\croc\shell\open\command", "" ) <> "" Then 
		
		RegUninstall()
		
	EndIf
	
	Exit 
	
EndIf

if $CmdLine[0] = "0" Then 
	if RegRead ( "HKEY_CLASSES_ROOT\croc\shell\open\command", "" ) =  "" Then 
		
		RegInstall()
		
	ElseIf  RegRead ( "HKEY_CLASSES_ROOT\croc\shell\open\command", "" ) <> "" Then 
		
		RegUninstall()
		
	EndIf
	Exit 
EndIf

if StringInStr( $CmdLine[1], "croc://" ) = 0 Then 
	$CmdLine[1] = '"' & $CmdLine[1] & '"'
	SendIt() 
EndIf

$CmdLine[1] =  StringTrimLeft( $CmdLine[1], 7)
$CmdLine[1] =  StringTrimRight( $CmdLine[1], 1)

WinSetTitle( $crocreceiver_gui, "", $CmdLine[1] )

GUISetIcon("shell32.dll", 50)
GUISetState(@SW_SHOW, $crocreceiver_gui)
GUICtrlSetState($gui_save, $GUI_DISABLE )

While 1
	Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            EndIt()
		Case $gui_pathselect
			PathSelect()
		Case $gui_save
			SaveIt()
    EndSwitch
Wend

func PathSelect()
	
	$path =  FileSelectFolder ( "Select Path to Save Files", "" )
	if $path <> "" Then 
		GUICtrlSetData($gui_pathselect, $path )
		GUICtrlSetState($gui_save, $GUI_ENABLE )
	EndIf 
		
EndFunc

func SaveIt()

	Run(@ComSpec & " /k " & @ScriptDir & '\croc.exe ' & $CmdLine[1], $path, @SW_SHOW)
	Exit 
	
EndFunc

func EndIt()
	Exit 
EndFunc

Func _GetAdminRight($sCmdLineRaw = "")
    If Not IsAdmin() Then
        If Not $sCmdLineRaw Then $sCmdLineRaw = $CmdLineRaw
        ShellExecute(@AutoItExe, $sCmdLineRaw, "", "runas")
        ProcessClose(@AutoItPID)
        Exit
    EndIf
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
		
		RegWrite ( "HKEY_CLASSES_ROOT\croc\shell\open\command" , "", "REG_SZ", '"' & @ScriptDir &  '\CrocReceiver.exe" "%1"' )
		RegWrite ( "HKEY_CLASSES_ROOT\croc" , "URL Protocol", "REG_SZ", "" )
		
		RegWrite ( "HKEY_CLASSES_ROOT\*\shell\croc\command" , "", "REG_SZ", '"' & @ScriptDir &  '\CrocReceiver.exe" "%1"' )
		RegWrite ( "HKEY_CLASSES_ROOT\*\shell\croc" , "", "REG_SZ", "Send it with Croc" )
		
		RegWrite ( "HKEY_CLASSES_ROOT\Directory\shell\croc\command" , "", "REG_SZ", '"' & @ScriptDir &  '\CrocReceiver.exe" "%1"' )
		RegWrite ( "HKEY_CLASSES_ROOT\Directory\shell\croc" , "", "REG_SZ", "Send it with Croc" )
		
		msgbox(0,  "CrocReceiver",  "CrocReceiver is now installed")
	
EndFunc

func SendIt()
	
	Run(@ComSpec & " /k " & @ScriptDir & '\croc.exe ' &  $CmdLine[1], "", @SW_SHOW)


	Opt("WinTitleMatchMode", 2)
	$hCmd =  "croc.exe  " & $CmdLine[1]
	WinWait($hCmd)
	While not WinActive($hCmd)
		WinActivate($hCmd)
	Wend
	SendKeepActive($hCmd)
	Send("Y{ENTER}")
		
	$waitcmd = 0
	
	While $waitcmd = 0
	
		While not WinActive($hCmd)
			WinActivate($hCmd)
		Wend
		Send( "^a{Enter}" )
		$cmdtext = ClipGet()
	
		$waitcmd = StringInStr($cmdtext,  "Code is:")
	
	WEnd 

	$cmdtext =  StringTrimLeft( $cmdtext, StringLen($cmdtext) - 40)
	$pos = StringInStr($cmdtext,  "croc ")
	$cmdtext =  StringTrimLeft($cmdtext, $pos + 4)
	$cmdtext =  StringTrimRight($cmdtext,  2)

	$cmdtext =  "<croc://" & $cmdtext & ">"

	ClipPut($cmdtext)
	
	TrayTip ( "Croc Code", "$cmdtext", 10 )

	Exit
	
EndFunc