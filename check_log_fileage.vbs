' needs:
' C:\Program Files\NSClient++\nsclient.ini: check_log_fileage=check_logfiles\check_log_fileage.vbs $ARG1$ $ARG2$ $ARG3$

const intOK = 0
const intWarning = 1 
const intCritical = 2

Set objFSO = CreateObject("Scripting.FileSystemObject")
objStartFolder = WScript.Arguments(1)
dtmYoungestDate = 0

Set objFolder = objFSO.GetFolder(objStartFolder)
Set colFiles = objFolder.Files

if objFolder.files.Count <> 0 then
	'Alte Datei finden
    For Each objFile in colFiles
		If objFile.DateLastModified > dtmYoungestDate Then
			strYoungestFile = objFile.Path
		dtmYoungestDate = objFile.DateLastModified
		
		End If

	Next
		
	Age = DateDiff("n",dtmYoungestDate, Now)

	If Age > CInt(WScript.Arguments(2)) Then
		Wscript.Echo "Critical: " & strYoungestFile & ", is " & Age & " min old."
		wscript.quit(intCritical)

	End If

	If Age > CInt(WScript.Arguments(3)) Then
		Wscript.Echo "Warning: " & strYoungestFile & ", is " & Age & " min old."
		wscript.quit(intWarning)

	End If

end if

Wscript.Echo "OK"
wscript.quit(intOK)

