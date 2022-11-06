#Prompts you for a username and amount of days when script is run
$user = Read-Host -Prompt 'Enter the Username of account'
$days = Read-Host -Prompt 'How many previous days to search (Example: 3):'

$user1 = '$_.Message -contains "*$user*"'
$StartDate = (Get-Date) - (New-TimeSpan -Day $days)

#Shows all sessions on device script is run on (haven't found a nice way to filter this yet as quser output is a bit weird)
$quser = quser

#This command looks for any scheduled tasks where the Run As User is the username you enter
$schtask = schtasks.exe /query /V /FO CSV | ConvertFrom-Csv | Select-Object HostName,TaskName,Status,"Next Run Time","Run As User" | Where-Object {($_."Run As User" -contains "$user") -and ($_.Status -ne "Disabled")}

#Looks for any services running as the entered username
$srvs = Get-WMIObject Win32_Service | Where-Object {$_.STARTNAME -like "*$user*"} | select startname, name

#Searches event viewer Security logs for successful logon events associated with username
$logon = Get-WinEvent -FilterHashtable @{LogName='Security';Keywords='9007199254740992'} | Where-Object -Property Message -Match $user | Format-List -Property TimeCreated, Message

#Searches event viewer Security logs for RDP related events associated with entered username (WORK IN PROGRESS, needs better filtering on this)
$rdpconnect = Get-WinEvent -LogName Microsoft-Windows-TerminalServices-LocalSessionManager/Operational | Where-Object { ([Scriptblock]::Create($user1)) -and ($_.TimeCreated -ge $StartDate)} | Format-List -Property MachineName, TimeCreated, Message


#THIS BELOW SECTION IS FOR PRINTING THE OUTPUT IN A NICE READABLE FORMAT IN THE CONSOLE (nothing special)
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
    "This is showing all RDP connection logs relating to provided username:"
    foreach ($rdp in $rdpconnect)
{
"---------- NEXT RDP RELATED EVENT ----------"
$rdp
" "
}
} Else {
    "No RDP related logs were found!"
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

