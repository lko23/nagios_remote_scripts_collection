# needs:
# C:\Program Files\NSClient++\nsclient.ini: check_dhcp_scopefailoverconfig=check_dhcp\CheckDhcpScopesFailoverConfig.ps1 $ARG1$
<#
   *  FileName:		CheckDhcpScopesFailoverConfig.ps1
   *  Useage:		powershell.exe -File "C:\Program Files\NSClient++\scripts\check_dhcp_scopefailoverconfig\CheckDhcpScopesFailoverConfig.ps1" -DhcpServer server.domain.tld -ShowDetails yes|no
   *  Parameter:	-DhcpServer server.domain.tld
#>
param(
  [string]$DhcpServer,
  [Parameter(Mandatory=$false)]
  [ValidateSet("yes","no")]
  [string] $ShowDetails = "no"
)

if ($DhcpServer -eq ""){
  $DhcpServer =  "server.domain.tld" 
}

$gb_ShowDetails = $false
If ($ShowDetails -eq "yes"){
  $gb_ShowDetails = $true 
}

$ErrorCounter = 0
$Status = 0
$OutputScope = ""

$Scopes = get-DhcpServerv4Scope -Computername $DhcpServer
If ($gb_ShowDetails) {Write-Host "$($Scopes.Count) Scopes auf Server $($DhcpServer)"}

If ($gb_ShowDetails) {Write-Host "-------------------------------------------------------------------------"}
foreach  ($Scope in $Scopes) {
  If ($gb_ShowDetails) {Write-Host "Scope $($scope.ScopeId)`t" -NoNewline}
  $ScopeStatus = 0
  $OutputScopeStatus = ""
  $OutputScopeFailover = ""

  if ($scope.state -like "Active") {
    $OutputScopeStatus = "OK Scope-Status=$($scope.state)"
    if ($gb_ShowDetails) {Write-Host " OK Scope-Status $($scope.state)`t`t" -NoNewline -ForegroundColor Green}
  } else {
    $ErrorCounter += 1
    $Status = 1
    $ScopeStatus = 1
    $OutputScopeStatus = "Scope-Status=$($scope.state)"
    if ($gb_ShowDetails) {Write-Host " Error Scope-Status $($scope.state)`t" -NoNewline -ForegroundColor Red}
  }

  $error.clear()
  $FailoverInfos = Get-DhcpServerv4Failover -Computername $DhcpServer -ScopeId $Scope.ScopeId -ErrorAction SilentlyContinue
  if ($error) {
    $ErrorCounter += 1
    $Status = 1
    $ScopeStatus = 1
    $OutputScopeFailover = "Failoverrolle=Inactive"
    If ($gb_ShowDetails) {Write-Host "Error Failover Inactive" -ForegroundColor Red}
  } else {
    $OutputScopeFailover = "Failoverrolle=$($FailoverInfos.ServerRole)"
    If ($gb_ShowDetails) {Write-Host "OK Failover $($FailoverInfos.ServerRole)" -ForegroundColor Green}
  }
  if ($ScopeStatus) {
    $OutputScope = $OutputScope + "Error bei Scope $($scope.ScopeId): $($OutputScopeStatus), $($OutputScopeFailover)`n"
  }
}

$OutputScope = $OutputScope[0..950] -join ""

Switch ($Status) {
  0 {$OutputNagios = "OK: DHCP-Server $($DhcpServer) Scope-Status and Failoverder $($Scopes.Count) Scopes OK"}
  1 {$OutputNagios = "WARNING: $($ErrorCounter) Errors on DHCP-Server $($DhcpServer)`nScope-Status or Failover Error:`n$OutputScope"}
}

Write-Host $OutputNagios

exit $Status
