' needs:
' C:\Program Files\NSClient++\nsclient.ini: check_fileage=check_files\check_fileage.vbs $ARG1$ $ARG2$ $ARG3$

const intOK = 0
const intWarning = 1 
const intCritical = 2

Set objFSO = CreateObject("Scripting.FileSystemObject")
set objFile = objFSO.GetFile(WScript.Arguments(1))
dtmOldestDate = Now

dtmOldestDate = objFile.DateLastModified
strOldestFile = objFile.Path

Age = DateDiff("n",dtmOldestDate, Now)

If Age > CInt(WScript.Arguments(2)) Then
	Wscript.Echo "Critical: " & strOldestFile & ", is " & Age & " min old."
	wscript.quit(intCritical)

End If

If Age > CInt(WScript.Arguments(3)) Then
	Wscript.Echo "Warning: " & strOldestFile & ", is " & Age & " min old."
	wscript.quit(intWarning)

End If

Wscript.Echo "OK"
wscript.quit(intOK)
