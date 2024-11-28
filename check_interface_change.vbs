' needs:
' C:\Program Files\NSClient++\nsclient.ini: check_interface_change=check_interface\check_interface_change.vbs $ARG1$ $ARG2$ $ARG3$

const intOK = 0
const intWarning = 1 
const intCritical = 2

Set objFSO = CreateObject("Scripting.FileSystemObject")
objStartFolder = WScript.Arguments(1)
dtmOldestDate = Now

Set objFolder = objFSO.GetFolder(objStartFolder)
Set colFiles = objFolder.Files

if objFolder.files.Count <> 0 then
	'Aelteste Datei finden
    For Each objFile in colFiles
		If objFile.DateLastModified < dtmOldestDate Then
			strOldestFile = objFile.Path
			dtmOldestDate = objFile.DateLastModified 
		
		End If

	Next
		
	Age = DateDiff("n",dtmOldestDate, Now)


	If Age > CLng(WScript.Arguments(2)) Then
		Wscript.Echo "Critical: " & strOldestFile & ", is " & Age & " min old."
		wscript.quit(intCritical)

	End If

	If Age > CLng(WScript.Arguments(3)) Then
		Wscript.Echo "Warning: " & strOldestFile & ", is " & Age & " min old."
		wscript.quit(intWarning)

	End If

end if

Wscript.Echo "OK"
wscript.quit(intOK)

