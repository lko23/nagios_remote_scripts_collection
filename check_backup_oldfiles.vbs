' needs:
' C:\Program Files\NSClient++\nsclient.ini: check_backup_oldfiles=check_backup\check_backup_oldfiles.vbs $ARG1$ $ARG2$ $ARG3$

' Nagios/Icinga2 constants
const intOK = 0
const intWarning = 1 
const intCritical = 2

' File age threshold in minutes
Dim age_threshold_crit
Dim age_threshold_warn
Dim folder_path

' check # of arguments
If WScript.Arguments.Count < 3 Then
  wscript.Echo "Critical: " & "Not enough arguments. Need Folder-Path (1), Critical-Time (2) and Warning-Time (3) in minutes."
  wscript.quit(intCritical)
End If

' initialize arguments
folder_path = WScript.Arguments(1)
age_threshold_crit = CLng(WScript.Arguments(2))
age_threshold_warn = CLng(WScript.Arguments(3))

Dim fso, f
Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.getFolder(folder_path)

Dim crit_file_not_found
Dim warn_file_not_found
crit_file_found = 0
warn_file_found = 0

For Each file in f.Files
  Dim age
  age = DateDiff("n", file.DateLastModified, Now)
  ' Check against Critical-Treshold
  If age > age_threshold_crit Then
    crit_file_found = 1
	Wscript.Echo "Critical: " & file & " is older than " & age_threshold_crit & " minutes. (modification timestamp: " & file.DateLastModified & ")"
	wscript.quit(intCritical)
    Exit For
  End If
  ' Check against Warning-Treshold
  If age > age_threshold_warn Then
    warn_file_found = 1
	Wscript.Echo "Warning: " & file & " is older than " & age_threshold_warn & " minutes. (modification timestamp: " & file.DateLastModified & ")"
	wscript.quit(intWarning)
    Exit For
  End If
Next

Wscript.Echo "OK: All files in " & f & " are not older than " & age_threshold_warn & " minutes."
wscript.quit(intOK)
