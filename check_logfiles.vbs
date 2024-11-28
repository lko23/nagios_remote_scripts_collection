' needs:
' C:\Program Files\NSClient++\nsclient.ini: check_logfiles=check_logfiles\check_logfiles.vbs

dim thisMonth: thisMonth = cstr(month(date))
if (len(thisMonth) = 1) then thisMonth = "0" & thisMonth

dim thisDay: thisDay = cstr(day(date))
if (len(thisDay) = 1) then thisDay = "0" & thisDay

Set fso = CreateObject("Scripting.FileSystemObject")
Set listFile = fso.OpenTextFile("C:\Path\To\SomeLog" & thisDay & thisMonth & ".log")
do while not listFile.AtEndOfStream 
     fName = listFile.ReadLine()
     If InStr(fName , "Ok") = 0 Then
	Wscript.Echo "Critical: in current log file is an error."
	wscript.quit(intCritical)
     End If
loop

Wscript.Echo "OK"
wscript.quit(intOK)
