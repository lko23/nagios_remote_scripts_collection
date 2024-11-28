' needs:
' C:\Program Files\NSClient++\nsclient.ini: check_backup_newestfolder=check_backup\check_backup_newestfolder.vbs $ARG1$ $ARG2$ $ARG3$

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
age_threshold_crit = CInt(WScript.Arguments(2))
age_threshold_warn = CInt(WScript.Arguments(3))


Dim fso, f
Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.getFolder(folder_path)

Dim crit_file_not_found
Dim warn_file_not_found
crit_file_found = 0
warn_file_found = 0

For Each fldr In f.SubFolders
    ''find the newest folder..
    If fldr.DateLastModified > LastDate Or IsEmpty(LastDate) Then
        LastFolder = fldr.Name
        LastDate = fldr.DateLastModified
    End If
Next

'' compare date of newest folder against tresholds
  Dim age
  age = DateDiff("n", LastDate, Now)
  ' Check against Critical-Treshold
  If age > age_threshold_crit Then
    crit_file_found = 1
	Wscript.Echo "Critical: Newest folder named '" & LastFolder & "' is older than " & age_threshold_crit & " minutes. (modification timestamp: '" & LastDate & "')"
	wscript.quit(intCritical)
  End If
  ' Check against Warning-Treshold
  If age > age_threshold_warn Then
    warn_file_found = 1
	Wscript.Echo "Warning: Newest folder named '" & LastFolder & "' is older than " & age_threshold_warn & " minutes. (modification timestamp: '" & LastDate & "')"
	wscript.quit(intWarning)
  End If

Wscript.Echo "OK: Latest Backup Folder in  " & f & " named '" & LastFolder & "' is from: '" & LastDate & "'; which was " & age & " minutes ago."
wscript.quit(intOK)
