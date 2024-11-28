' needs:
' C:\Program Files\NSClient++\nsclient.ini: check_db_log=check_logfiles\check_db_log.vbs $ARG1$ $ARG2$ $ARG3$ $ARG4$ $ARG5$

const intOK = 0
const intWarning = 1 
const intCritical = 2
const intUnknown = 3

Set fso = CreateObject("Scripting.FileSystemObject")

If fso.FileExists(WScript.Arguments(1)) Then

Set objFSO = CreateObject("Scripting.FileSystemObject")
set objFile = objFSO.GetFile(WScript.Arguments(1))
Set listFile = fso.OpenTextFile(WScript.Arguments(1))

For i = 1 to CInt(WScript.Arguments(2))
    listFile.ReadLine
Next

fName = listFile.ReadLine()
   If InStr(fName , "Critical:") = 1 Then
	Wscript.Echo fName
	wscript.quit(intCritical)
   End If

   If InStr(fName , "Warning:") = 1 Then
	Wscript.Echo fName
	wscript.quit(intWarning)
   End If

   If InStr(fName , WScript.Arguments(3)) = 0 Then
	Wscript.Echo "Unknown: " & fName
	wscript.quit(intUnknown)
   End If

dtmOldestDate = Now
dtmOldestDate = objFile.DateLastModified
strOldestFile = objFile.Path

Age = DateDiff("n",dtmOldestDate, Now)

If Age > CInt(WScript.Arguments(4)) Then
	Wscript.Echo "Critical: " & strOldestFile & ", is " & Age & " min old."
	wscript.quit(intCritical)

End If

If Age > CInt(WScript.Arguments(5)) Then
	Wscript.Echo "Warning: " & strOldestFile & ", is " & Age & " min old."
	wscript.quit(intWarning)

End If

Wscript.Echo "OK: " & fName
wscript.quit(intOK)

End If

Wscript.Echo "Critical: No log file found"
wscript.quit(intCritical)
