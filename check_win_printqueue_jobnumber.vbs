' needs:
' C:\Program Files\NSClient++\nsclient.ini: check_win_printqueue_jobnumber=check_print\check_win_printqueue_jobnumber.vbs $ARG1$ $ARG2$ $ARG3$

Const PROGNAME = "check_win_printqueue_spooler"
Const VERSION = "1.0"

Set wshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting_FileSystemObject")

strComputer = "localhost"

strPrintQueue = WScript.Arguments.Item(1)
intJobNum_warn = CInt(WScript.Arguments.Item(2))
intJobNum_crit = CInt(WScript.Arguments.Item(3))

' Default return, 0: OK, 1: WARNING, 2: CRITICAL, 3: UNKNOWN
return_code = 3
return_msg = "PrintQueue does not exist or can not be read."

' Create WMI object
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

' Fetch all Print Jobs in specified Printer Queue
strWMIQuery = "Select * From Win32_PrintJob Where Name LIKE '" & strPrintQueue & "%'"
Set Result = objWMIService.ExecQuery(strWMIQuery)

If (Result.Count < intJobNum_warn) Then
	return_code = 0
	return_msg = "OK: PrintQueue " & strPrintQueue & " has " & Result.Count & " print jobs. | number_of_printjobs=" & Result.Count
End If
If (Result.Count >= intJobNum_warn) Then
	return_code = 1
	return_msg = "WARNING: PrintQueue " & strPrintQueue & " has " & Result.Count & " print jobs. | number_of_printjobs=" & Result.Count
End If
If (Result.Count >= intJobNum_crit) Then
	return_code = 2
	return_msg = "CRITICAL: PrintQueue " & strPrintQueue & " has " & Result.Count & " print jobs. | number_of_printjobs=" & Result.Count
End If

Wscript.Echo return_msg
Wscript.Quit(return_code)

Sub Include( cNameScript )
    Set oFile = fso.OpenTextFile( cNameScript )
    ExecuteGlobal oFile.ReadAll()
    oFile.Close
End Sub
