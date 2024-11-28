' needs:
' C:\Program Files\NSClient++\nsclient.ini: check_dhcp_backup=check_dhcp\check_dhcp_backup.vbs $ARG1$ $ARG2$ $ARG3$ $ARG4$ $ARG5$

const intOK = 0
const intWarning = 1 
const intCritical = 2

Set fso = CreateObject("Scripting.FileSystemObject")

If fso.FileExists(WScript.Arguments(1)) Then

Set objFSO = CreateObject("Scripting.FileSystemObject")
set objFile = objFSO.GetFile(WScript.Arguments(1))
Set listFile = fso.OpenTextFile(WScript.Arguments(1))

For i = 1 to CInt(WScript.Arguments(2))
    listFile.ReadLine
Next

fName = listFile.ReadLine()
   If InStr(fName , WScript.Arguments(3)) = 0 Then
	Wscript.Echo "Critical: " & fName
	wscript.quit(intCritical)
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

Wscript.Echo "Critical: Es ist kein Log File vorhanden"
wscript.quit(intCritical)
