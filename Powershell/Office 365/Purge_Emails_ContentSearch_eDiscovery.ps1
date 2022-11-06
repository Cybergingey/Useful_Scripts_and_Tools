#Prompts for O365 admin email
$email = Read-Host -Prompt 'Input the admin account email'

#Added 2 connections here as purging didn't seem to work with only the 1...... Thanks MS
Connect-ExchangeOnline -UserPrincipalName $email
Connect-IPPSSession -Credential $UserCredential

#Prompts for the content search or eDiscovery search name
$searchname = Read-Host -Prompt 'Input the search name'

#This will run a SOFTDELETE (removes from user mailboxes, emails still recoverable by admins (change to 'HardDelete' for full purge from existence))
New-ComplianceSearchAction -SearchName $searchname -Purge -PurgeType SoftDelete