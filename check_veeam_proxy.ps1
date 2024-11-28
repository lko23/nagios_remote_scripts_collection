# needs:
# C:\Program Files\NSClient++\nsclient.ini: check_veeam_proxy=check_veeam\check_veeam_proxy.ps1
#
# Check Veeam host status down

Get-VBOServerComponents -Name Proxy | Where-Object {($_.IsOnline -eq 0)} | select ServerName, IsOnline | Sort-Object ServerName -outvariable return;

if ($return -match "False") {
    $output = "WARNING: Some Veeam proxys are not running `r`n$($return | select -ExpandProperty ServerName | Sort-Object ServerName | Out-String)";
    $NagiosState = 1;
}
else {
    $output = "OK: All Veeam proxys are running";
    $NagiosState = 0;
}

Write-Host $output;
exit $NagiosState;
