#Prompts you for a username when script is run
$user = Read-Host -Prompt 'Enter the Username of account'

#This command looks for any scheduled tasks where the Run As User is the username you enter
$schtask = schtasks.exe /query /V /FO CSV | ConvertFrom-Csv | Select-Object HostName,TaskName,Status,"Next Run Time","Run As User" | Where-Object {($_."Run As User" -contains "$user") -and ($_.Status -ne "Disabled")}
