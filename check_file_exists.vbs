' needs:
' C:\Program Files\NSClient++\nsclient.ini: check_file_exists=check_files\check_file_exists.vbs $ARG1$

const intOK = 0
const intWarning = 1 
const intCritical = 2

objFile= WScript.Arguments(1)

Set fso = CreateObject("Scripting.FileSystemObject")
If (fso.FileExists(objFile)) Then
	Wscript.Echo "OK"
	wscript.quit(intOK)
Else
	Wscript.Echo "Critical: " & objFile & " is missing."
	wscript.quit(intCritical)
End If
