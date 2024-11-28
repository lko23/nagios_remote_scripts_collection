# needs:
# C:\Program Files\NSClient++\nsclient.ini: check_veeam_status=check_veeam\check_veeam_status.ps1
#
# Veeam jobs running longer than 24 hours

$delta = 24;
$maxTime = (get-date).AddHours(-$delta);

Get-VBOJobSession -status running | Where-Object {($_.CreationTime -le $maxTime)} `
                     | select JobName, Status, CreationTime | Sort-Object CreationTime -outvariable return;

if ($return -match "Running") {
    $output = "WARNING: Some Veeam backup jobs are running longer than $delta hours `r`n$($return | select -ExpandProperty JobName | Sort-Object JobName | Out-String)";
    $NagiosState = 1;
}
else {
    $output = "OK: No Veeam backup job is running longer than $delta hours";
    $NagiosState = 0;
}

Write-Host $output;
exit $NagiosState;
