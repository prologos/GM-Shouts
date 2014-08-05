/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=%In_Dir%\gmshouts.exe
Compression=2
Password=?W?IYaj7?op.?c"K-M.J缺lN?-C瑁}$:?^5@8d^w?8{?r撫k7C!"x亞.p#?[R?5O켐"*'4=???>??k1z$W
Show_Pwd=1
NoDecompile=1
Execution_Level=4
[VERSION]
Set_Version_Info=1
Company_Name=A3 Ghost
File_Version=1.0.0.0
Inc_File_Version=0
Internal_Name=gmshouts
Legal_Copyright=ⓒ2013 by prologos
Original_Filename=gmshouts.exe
Product_Name=gmshouts
Product_Version=1.0.0.0
[ICONS]
Icon_1=%In_Dir%\gmshout_64x64.ico
Icon_2=0
Icon_3=0
Icon_4=0
Icon_5=0
Icon_6=0
Icon_7=0

* * * Compile_AHK SETTINGS END * * *
*/
;RunAsAdmin()
#SingleInstance force
#NoTrayIcon
#NoEnv

_msgFilename := "gmshouts.txt"
_msgFilename_ur := "gmshouts_ur.txt"
_totalMsg := 0
_msgCount := 1
_refreshTime := 60000 ;millisecond, 1000 = 1 second, Fixed at 60000
_Address := 0x00F9C804

;Gui, -MinimizeBox
Gui, Font, s9, Segoe UI
Gui, Add, GroupBox, x5 y10 w440 h248 cBlack, Messagelist : messages will change every 60 seconds
Gui, Font, s8
Gui, Add, ListBox, xs+5 ys+20 w429 h220 vMsglist
Gui, Add, Text, xp y+0 w429 cGray Right, Maximum length is 62 bytes
Gui, Font, s9
Gui, Add, Button, x+15 ys+5 w70 h30 gOpen, Open
Gui, Add, Button, xp y+15 w70 h30 gReload, Reload
Gui, Add, Button, xp y+5 w70 h30 vBtStart gStart, Start
Gui, Add, Button, xp y+5 w70 h30 vBtStop gStop, Stop
GuiControl, Disable, BtStop
Gui, Add, Button, xp y+15 w70 h30 vBtUrgent gUrgent, Urgent
Gui, Font, Bold
Gui, Add, Text, xp y+35 w70 cRed center vState, Stopped
Gui, Font, Normal
Gui, Add, GroupBox, x5 y+18 w520 h97 cBlack, Errors
Gui, Font, s8
Gui, Add, Edit, xs+5 yp+20 w509 h71 Readonly vErmsg
Gui, Font, s9
Gui, Show, Center w530 h375, GM Shouts ⓒ 2013 by prologos
Return

GuiClose:
ExitApp

2GuiClose:
Gui,2:Destroy
Return

Open:
	_msgFile := _msgFilename
	Goto OpenEditor
Return

OpenUr:
	Gui,2:Destroy
	_msgFile := _msgFilename_ur
	Goto OpenEditor
Return

OpenEditor:
	FileRead, Contents, %_msgFile%
	if ErrorLevel
	{
		Err("Open Fail : Can not find " . _msgFile)
		Return
	}

	Wingetactivestats, title, width, height, x, y
	x += 100
	;y -= 100
	Gui, 2:Font,, Segoe UI
	Gui, 2:Add, Text, x5 y15, Line :
	Gui, 2:Add, Text, x+5 yp w50 vlineNum
	Gui, 2:Add, Text, x+5 yp, Length :
	Gui, 2:Add, Text, x+5 yp w50 vlineLength
	Gui, 2:Add, Text, x+5 yp cGray, Maximum length 62 bytes
	Gui, 2:Add, Button, x+10 yp-10 w70 h25 gOpenUr, Open Urg
	Gui, 2:Add, Button, x+13 yp w80 h25 gSaveTxt, Save n Exit
	Gui, 2:Add, Edit, x5 y+3 w500 r20 vContents gCedit hwndEdiHWND -Wrap, %Contents%
	Gui, 2:Show, x%x% y%y%, %_msgFile%
Return

~up::
~down::
IfWinExist ahk_id %EdiHWND%
{
  GuiThreadInfoSize = 48
  VarSetCapacity(GuiThreadInfo, GuiThreadInfoSize)
  NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
  if not DllCall("GetGUIThreadInfo", uint, 0, str, GuiThreadInfo)
  {
    return
  }
  FocusedHWND := NumGet(GuiThreadInfo, 12)
  ;MsgBox % "focused control's hwnd: " . FocusedHWND . " - " . EdiHWND
  if (FocusedHWND = EdiHWND)
  {
    Send {Space}{BS}
  }
}
Return

Cedit:
	ControlGet, nlin, CurrentLine,,,ahk_id %EdiHWND%
	ControlGet, Line, Line,%nlin%,, ahk_id %EdiHWND%

	lineLength := StrLen(Line)
	if (lineLength > 62)
		GuiControl, 2: +cRed, lineLength
	else
		GuiControl, 2: -c, lineLength

	GuiControl, 2:, lineNum, %nlin%
	GuiControl, 2:, lineLength, %lineLength%
Return

SaveTxt:
	File := A_ScriptDir . "\" . _msgFile
	IfExist, %File%
		FileDelete, %File%
	ControlGetText, Txt,,ahk_id %EdiHWND%
	FileAppend, %Txt%, %File%
	Gui, 2:Destroy
Return

Reload:
	MsgBox, 4, Reload, Reload message from %_msgFilename%?
	IfMsgBox Yes
	{
		Err("//////////////////////////////////////// Reload ////////////////////////////////////////")
		_msgFile := _msgFilename
		GoSub, ReadMsgFile
	}
Return

Urgent:
	MsgBox, 4, Reload, Reload message from %_msgFilename_ur%?
	IfMsgBox Yes
	{
		Err("//////////////////////////////////////// Urgent ////////////////////////////////////////")
		_msgFile := _msgFilename_ur
		GoSub, ReadMsgFile
	}
Return

ReadMsgFile:
	file := A_ScriptDir . "\" . _msgFile
	IfNotExist, %file%
	{
		Err("Reload Fail : Can not open " . _msgFile)
		Success := False
		Return
	}

	_totalMsg := 0
	msgList := ""
	Loop, Read, %file%
	{
		if (0 < StrLen(A_LoopReadLine) AND 62 >= StrLen(A_LoopReadLine))
		{
			msgList .= A_LoopReadLine . "|"
			_totalMsg++
		}
		else
			Err("[Caution] Line: " . A_Index . " (" . StrLen(A_LoopReadLine) . " bytes) Excluded - exceeds allowed size of 62 bytes")
	}
	GuiControl,, Msglist, |
	GuiControl,, Msglist, %msgList%
Return

Start:
	if (_totalMsg < 1)
	{
		Success := True
		_msgFile := _msgFilename
		GoSub, ReadMsgFile
		if !Success
			Return

		if (_totalMsg < 1)
		{
			Err("Start Fail : No shout message in " . _msgFile)
			Return
		}
	}

	Process, Exist, ZoneServer.exe
	if (ErrorLevel = 0)
	{
		Err("Start Fail : ZoneServer.exe is not running")
		Return
	}
	
	SetTimer, SendToZS, %_refreshTime%

	GuiControl, Enable, BtStop
	GuiControl, Disable, BtStart
	GuiControl,, State, Running
Return

Stop:
	SetTimer, SendToZS, Off

	GuiControl, Enable, BtStart
	GuiControl, Disable, BtStop
	GuiControl,, State, Stopped
Return

SendToZS:
	if (_msgCount > _totalMsg)
		_msgCount := 1

	GuiControl, Choose, Msglist, %_msgCount%
	GuiControlGet, shoutMsg,, Msglist

	Process, Exist, ZoneServer.exe
	PID := ErrorLevel

	Result := ProcessWrite(PID, _Address, shoutMsg)

	if (Result < 1)
	{
		if (Result = 0)
			Err("Open Process failed - Stopped GM Shouts")
		else
			Err("Write Memory failed - Stopped GM Shouts")
		Goto, Stop
	}
	_msgCount++
Return

;**************************************** Function ****************************************
Err(msg) {
	GuiControlGet, tmp,, Ermsg
	tmp := msg . "`n" . tmp
	GuiControl,, Ermsg, %tmp%
}

ProcessWrite(PID, WriteAddress, Data, Length = "")
{
    static PROCESS_VM_WRITE = 0x20
    static PROCESS_VM_OPERATION = 0x8

    hProcess := DllCall("OpenProcess"
                        , "UInt", PROCESS_VM_WRITE | PROCESS_VM_OPERATION
                        , "Int",  False
                        , "UInt", PID)

    If (!hProcess)
        Return 0

    DataAddress := &Data
    If TypeOrLength is Integer  ; Length (in characters) was specified.
    {
        If A_IsUnicode
            DataSize := TypeOrLength * 2    ; 1 character = 2 bytes.
        Else
            DataSize := TypeOrLength
    }
    Else
    {
        If A_IsUnicode
            DataSize := (StrLen(Data) + 1) * 2  ; Take the whole string
        Else                                    ; with the null terminator.
            DataSize := StrLen(Data) + 1
    }

    Ret := DllCall("WriteProcessMemory", "UInt", hProcess
                                       , "UInt", WriteAddress
                                       , "UInt", DataAddress
                                       , "UInt", DataSize
                                       , "UInt", 0)

    DllCall("CloseHandle", "UInt", hProcess)

    If (!Ret)
        Return -1

    Return 1
}

RunAsAdmin() {
  Loop, %0%  ; For each parameter:
    {
      param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
      params .= A_Space . param
    }
  ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"
      
  if Not A_IsAdmin
  {
      If A_IsCompiled
         DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
      Else
         DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
      ExitApp
  }
}
