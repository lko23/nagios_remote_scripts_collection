
If (Result.Count < intJobNum_warn) Then
	return_code = 0
	return_msg = "OK: PrintQueue " & strPrintQueue & " has " & Result.Count & " print jobs. | number_of_printjobs=" & Result.Count
End If
If (Result.Count >= intJobNum_warn) Then
	return_code = 1
	return_msg = "WARNING: PrintQueue " & strPrintQueue & " has " & Result.Count & " print jobs. | number_of_printjobs=" & Result.Count
End If
If (Result.Count >= intJobNum_crit) Then
	return_code = 2
	return_msg = "CRITICAL: PrintQueue " & strPrintQueue & " has " & Result.Count & " print jobs. | number_of_printjobs=" & Result.Count
End If

Wscript.Echo return_msg
Wscript.Quit(return_code)

Sub Include( cNameScript )
    Set oFile = fso.OpenTextFile( cNameScript )
    ExecuteGlobal oFile.ReadAll()
    oFile.Close
End Sub
