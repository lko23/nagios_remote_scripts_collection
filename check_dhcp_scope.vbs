
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
