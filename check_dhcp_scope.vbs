' needs:
' C:\Program Files\NSClient++\nsclient.ini: check_dhcp_scope=check_dhcp\check_dhcp_scope.vbs $ARG1$ $ARG2$
'  Script:	check_dhcp_scope.vbs
'  Description:	Check the health status of scopes on the local DHCP server
'  History:     v1.0 : first version

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set tfolder = objfso.GetSpecialFolder(2)

filetoparse= tfolder&"\EXPORT_DHCP_SCOPE.TXT"

bdebug=FALSE

stroutCritical=""
stroutWarning=""
strout=""

Critical_Limit=Int(WScript.Arguments(2))
Warning_Limit=Int(WScript.Arguments(1))

function parse(strtoparse)
	parse=mid(strtoparse,instr(strtoparse,"=")+2,len(strtoparse)-instr(strtoparse,"=")-2)
end function

strthecommand="cmd.exe /c netsh dhcp server show all > "&filetoparse&" 2>&1"

WScript.Sleep(5000)  

	ScopeCount=0
	ScopeOk=0
	ScopeDisabled=0
	ScopeWarning=0
	ScopeCritical=0

	Const ForReading = 1
	Const ForWriting = 2
	Const ForAppending = 8

	Set objFileSorg = objFSO.OpenTextFile(filetoparse, ForReading)

	oldstr2=""
	oldstr3=""	
	oldstr=""	

	Do While objFileSorg.AtEndOfStream <> True  
		strSorg = objFileSorg.ReadLine
		if instr(oldstr2,"Subnet") then
			scopecount=scopecount+1

			SubnetIP=parse(oldstr2)
			FreeIP=parse(strsorg)
			UsedIP=parse(oldstr)
			'Calc relUsed
			relUsed=round((int(UsedIP)/(int(FreeIP)+int(UsedIP)+1))*100)

			if bdebug then wscript.echo SubnetIP&" "&UsedIP&" "&FreeIP

			if UsedIP=0 then 
				if bdebug then wscript.echo "-"&SubnetIP&" is disabled"
				ScopeDisabled=ScopeDisabled+1
			elseif int(relUsed)>=Critical_Limit then 
				if bdebug then wscript.echo "-"&SubnetIP&" is Critical ("&relUsed&"% used)"
				StrOutCritical=StroutCritical&SubnetIP&" is Critical ("&relUsed&"% used). "
				ScopeCritical=ScopeCritical+1
			elseif int(relUsed)>=Warning_Limit then 
				if bdebug then wscript.echo "-"&SubnetIP&" is Warning ("&relUsed&"% used)"
				StrOutWarning=StroutWarning&SubnetIP&" is Warning ("&relUsed&"% used). "
				ScopeWarning=ScopeWarning+1
			end if

		end if
		
		oldstr3=oldstr2
		oldstr2=oldstr
		oldstr=strsorg
	loop
	objFileSorg.Close
	if not ((StrOutCritical="") AND (StrOutWarning="")) then 
		strout=StroutCritical+StrOutWarning
	ElseIf(StrOutCritical<>"") then
		strout=StrOutCritical
	ElseIf(StrOutWarning<>"") then
		strout=StrOutWarning
	End If
	

	if not strout="" then wscript.echo strout
	
	if ScopeCritical then wscript.quit(2)
	if ScopeWarning then wscript.quit(1)

	wscript.echo scopecount&" Scopes OK"
	wscript.quit(0)
