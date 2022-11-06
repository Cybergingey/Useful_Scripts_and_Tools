#Prompts you for a username when script is run
$user = Read-Host -Prompt 'Enter the Username of account'

#Looks for any services running as the entered username
$srvs = Get-WMIObject Win32_Service | Where-Object {$_.STARTNAME -like "*$user*"} | select startname, name