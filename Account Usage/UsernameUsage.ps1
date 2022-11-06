user = Read-Host -Prompt 'Enter the Username of account'
$user1 = '$_.Message -contains "*$user*"'
$StartDate = (Get-Date) - (New-TimeSpan -Day 3)

$quser = quser
$schtask = schtasks.exe /query /V /FO CSV | ConvertFrom-Csv | Select-Object HostName,TaskName,Status,"Next Run Time","Run As User" |
Where-Object {($_."Run As User" -contains "$user") -and ($_.Status -ne "Disabled")}
$srvs = Get-WMIObject Win32_Service | Where-Object {$_.STARTNAME -like "*$user*"} | select startname, name
$logon = Get-WinEvent -FilterHashtable @{LogName='Security';Keywords='9007199254740992'} | Where-Object -Property Message -Match $user | Format-List -Property TimeCreated, Message
$rdpconnect = Get-WinEvent -LogName Microsoft-Windows-TerminalServices-LocalSessionManager/Operational | Where-Object { ([Scriptblock]::Create($user1)) -and ($_.TimeCreated -ge $StartDate)} | Format-List -Property MachineName, TimeCreated, Message

Write-Host " "
Write-Host "This is showing ALL user sessions:"
$quser
Write-Host " "
Write-Host "---------------------------------------------------------------------------------------------"

If($schtask) {
    "This is showing all Scheduled tasks which are not disabled relating to the provided username:"
    foreach ($sch in $schtask)
{
"---------- NEXT SCHEDULED TASK ----------"
$sch
" "
}
} Else {
    "No Scheduled tasks were found!"
}
Write-Host " "
Write-Host "---------------------------------------------------------------------------------------------"
If($srvs) {
    "This is showing all services relating to provided username:"
    $srvs
} Else {
    "No services were found!"
}
Write-Host " "
Write-Host "---------------------------------------------------------------------------------------------"
If($rdpconnect) {
    "This is showing all RDP connection logs relating to provided username (last 3 days):"
    foreach ($rdp in $rdpconnect)
{
"---------- NEXT RDP EVENT ----------"
$rdp
" "
}
} Else {
    "No RDP logs were found!"
}
Write-Host " "
Write-Host "---------------------------------------------------------------------------------------------"
If($logon) {
    foreach ($logn in $logon)
{
"---------- NEXT LOGON EVENT ----------"
" "
$logn
" "
}
} Else {
    "No logon logs were found!"
}

