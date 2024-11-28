' needs:
' C:\Program Files\NSClient++\nsclient.ini: check_backup_fileage=check_backup\check_backup_fileage.vbs $ARG1$ $ARG2$ $ARG3$

const intOK = 0
const intWarning = 1 
const intCritical = 2

Set objFSO = CreateObject("Scripting.FileSystemObject")
objStartFolder = WScript.Arguments(1)
dtmYoungestDate = 0

Set objFolder = objFSO.GetFolder(objStartFolder)
Set colFiles = objFolder.Files

if objFolder.files.Count <> 0 then

    For Each objFile in colFiles
		If objFile.DateCreated > dtmYoungestDate Then
			strYoungestFile = objFile.Path
		dtmYoungestDate = objFile.DateCreated
		
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
